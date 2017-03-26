/**
 * Matrix3D（回転成分）の球面線形補間。
 * 「rotate」ボタンで内側のキューブがランダムに回転して、
 * 外側のフレームがキューブの姿勢に球面線形補間で近づきます。
 * 
 * Matrix3D周りの処理にちょっと自信がありません。
 * 
 * 参考サイト
 * http://marupeke296.com/DXG_No57_SheareLinearInterWithoutQu.html
 */
package {
	import alternativ7.engine3d.core.Geometry;
	import alternativ7.engine3d.materials.FillMaterial;
	import alternativ7.engine3d.objects.Mesh;
	import alternativ7.engine3d.primitives.Box;
	import alternativ7.engine3d.primitives.Plane;
	import com.bit101.components.PushButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	public class SlerpMatrix extends Sprite {
		public var scene:Scene3D;
		public var cameraDrag:SphericalDragger;
		public var cube:Box;
		public var frame:Mesh;
		public var targetRotation:Vector3D = new Vector3D();
		public var topColor:FillMaterial = new FillMaterial(0xFFF954);
		public var bottomColor:FillMaterial = new FillMaterial(0xFF58A7);
		public var leftColor:FillMaterial = new FillMaterial(0xFD9A31);
		public var rightColor:FillMaterial = new FillMaterial(0x4B60FF);
		public var backColor:FillMaterial = new FillMaterial(0x95FF61);
		public var frontColor:FillMaterial = new FillMaterial(0xA65EDD);
		
		public function SlerpMatrix() {
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(...arg):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			//テンプレートを作成して画面に配置
			scene = new Scene3D(Scene3D.CONFLICT, 465, 465, 0x222222);
			addChild(scene.view);
			
			//各種オブジェクトを生成してルートコンテナに追加
			frame = createFrame();
			frame.scaleX = frame.scaleY = frame.scaleZ = 2;
			cube = new Box(120, 120, 120, 1, 1, 1, false, false, leftColor, rightColor, backColor, frontColor, bottomColor, topColor);
			var grid:FillMaterial = new FillMaterial(0x444444, 0, 1, 0xAAAAAA);
			scene.root.addChild(new Plane(1200, 1200, 4, 4, true, false, false, grid, grid)).z = -140;
			scene.root.addChild(cube);
			scene.root.addChild(frame);
			
			//キューブをランダムに回転するボタン
			var btn:PushButton = new PushButton(this, 0, 0, "rotate", onClickRotate);
			btn.setSize(60, 20);
			btn.scaleX = btn.scaleY = 2;
			
			//カメラをマウスでドラッグするクラス
			cameraDrag = new SphericalDragger(scene.view, -45, 25, 600);
			cameraDrag.wheelEnabled = false;
			cameraDrag.onMovePosition = onMoveCamera;
			cameraDrag.notify();
			
			//処理開始
			addEventListener(Event.ENTER_FRAME, onTick);
		}
		
		//毎フレーム処理
		private function onTick(e:Event):void {
			//キューブを回転
			cube.rotationX += (targetRotation.x - cube.rotationX) * 0.5;
			cube.rotationY += (targetRotation.y - cube.rotationY) * 0.5;
			cube.rotationZ += (targetRotation.z - cube.rotationZ) * 0.5;
			
			//フレームの回転成分の球面線形補間（外側のフレームが内側のキューブの姿勢に近づく）
			var rotateMtx:Matrix3D = VectorUtil.slerpMatrix(frame.matrix, cube.matrix, 0.1);
			
			//位置とスケールは元のままにしたいので回転をリセットしてからappend()してます（もっといい方法があるかも）
			frame.rotationX = frame.rotationY = frame.rotationZ = 0;
			var mtx:Matrix3D = frame.matrix;
			mtx.append(rotateMtx);
			frame.matrix = mtx;
			
			//レンダリング
			scene.render();
		}
		
		//ボタンクリック時
		private function onClickRotate(e:MouseEvent):void {
			targetRotation.x = Math.random() * Math.PI * 2;
			targetRotation.y = Math.random() * Math.PI * 2;
			targetRotation.z = Math.random() * Math.PI * 2;
		}
		
		//画面をドラッグしたらカメラを動かす
		private function onMoveCamera(point:Vector3D):void {
			scene.controller.setObjectPos(point);
			scene.controller.lookAtXYZ(0, 0, 0);
		}
		
		//フレームオブジェクトを作る
		private function createFrame():Mesh {
			var scale:Number = 10;
			var materials:Array = [bottomColor, topColor, new FillMaterial(0xcbcbcb), new FillMaterial(0xb1b1b1), new FillMaterial(0x969696), rightColor, leftColor, backColor, frontColor];
			var vts:Array = [
				[-5,-5,-5],[-5,5,-5],[5,5,-5],[5,-5,-5],[-5,-5,5],[5,-5,5],[5,5,5],[-5,5,5],[-4,-5,-4],[-4,5,-4],[4,-5,-4],[4,5,-4],[4,-5,4],[4,5,4],[-4,-5,4],[-4,5,4],[4,-4,-5],[4,-4,5],[4,-4,-4],[4,-4,4],[-4,-4,-5],[-4,-4,5],[-4,-4,-4],[-4,-4,4],[4,4,-5],[4,4,5],[4,4,-4],[4,4,4],[-4,4,-5],[-4,4,5],
				[-4,4,-4],[-4,4,4],[5,4,-4],[-5,4,-4],[5,-4,-4],[-5,-4,-4],[5,-4,4],[-5,-4,4],[5,4,4],[-5,4,4]
			];
			var ids:Array = [
				[20,0,1],[0,20,16],[3,0,16],[3,16,24],[2,3,24],[2,24,28],[1,2,28],[20,1,28],[25,6,7],[6,25,17],[5,6,17],[5,17,21],[4,5,21],[4,21,29],[7,4,29],[25,7,29],[22,8,10],[10,18,22],[19,12,14],[14,23,19],[11,9,30],[30,26,11],[31,15,13],[13,27,31],[26,18,34],[34,32,26],[36,19,27],[27,38,36],[39,31,23],[23,37,39],
				[30,33,35],[35,22,30],[22,18,16],[16,20,22],[26,30,28],[28,24,26],[27,25,29],[29,31,27],[17,19,23],[23,21,17],[34,18,19],[19,36,34],[26,32,38],[38,27,26],[31,39,33],[33,30,31],[22,35,37],[37,23,22],[22,20,28],[28,30,22],[26,24,16],[16,18,26],[31,29,21],[21,23,31],[27,19,17],[17,25,27],[23,14,8],[8,22,23],[19,18,10],[10,12,19],
				[31,30,9],[9,15,31],[27,13,11],[11,26,27],[3,2,34],[3,34,36],[5,3,36],[5,36,38],[32,34,2],[38,32,2],[38,2,6],[5,38,6],[1,0,33],[1,33,39],[7,1,39],[7,39,37],[35,33,0],[37,35,0],[37,0,4],[7,37,4],[0,3,8],[0,8,14],[4,0,14],[4,14,12],[10,8,3],[12,10,3],[12,3,5],[4,12,5],[7,6,15],[7,15,9],
				[1,7,9],[1,9,11],[13,15,6],[11,13,6],[11,6,2],[1,11,2]
			];
			var mts:Array = [0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,5,5,5,5,5,5,5,5,6,6,6,6,6,6,6,6,7,7,7,7,7,7,7,7,8,8,8,8,8,8,8,8];
			var geom:Geometry = new Geometry();
			for each (var vt:Array in vts) geom.addVertex(vt[0] * scale, vt[1] * scale, vt[2] * scale);
			for (var i:int; i < ids.length; i++) geom.addTriFace(geom.vertices[ids[i][0]], geom.vertices[ids[i][1]], geom.vertices[ids[i][2]], materials[mts[i]]);
			var mesh:Mesh = new Mesh();
			mesh.geometry = geom;
			return mesh;
		}
	}
}

import alternativ7.engine3d.containers.BSPContainer;
import alternativ7.engine3d.containers.ConflictContainer;
import alternativ7.engine3d.containers.DistanceSortContainer;
import alternativ7.engine3d.containers.KDContainer;
import alternativ7.engine3d.controllers.SimpleObjectController;
import alternativ7.engine3d.core.Camera3D;
import alternativ7.engine3d.core.Object3DContainer;
import alternativ7.engine3d.core.View;
import flash.display.InteractiveObject;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.MouseEvent;
import flash.geom.Matrix3D;
import flash.geom.Point;
import flash.geom.Vector3D;
/**
 * Vector3D系クラス
 */
class VectorUtil {
	static private var _fromN:Vector3D = new Vector3D;
	static private var _toN:Vector3D = new Vector3D;
	static private var _fromY:Vector3D = new Vector3D;
	static private var _fromZ:Vector3D = new Vector3D;
	static private var _toY:Vector3D = new Vector3D;
	static private var _toZ:Vector3D = new Vector3D;
	/**
	 * Matrix3Dの回転成分をfromからtoへt（0～1）の割合だけ球面線形補間した新しいMatrix3Dを返す
	 * @param	from
	 * @param	to
	 * @param	t
	 * @return
	 */
	static public function slerpMatrix(from:Matrix3D, to:Matrix3D, t:Number):Matrix3D {
		setXYZ(_fromY, from.rawData[4], from.rawData[5], from.rawData[6]);
		setXYZ(_fromZ, from.rawData[8], from.rawData[9], from.rawData[10]);
		setXYZ(_toY, to.rawData[4], to.rawData[5], to.rawData[6]);
		setXYZ(_toZ, to.rawData[8], to.rawData[9], to.rawData[10]);
		var sy:Vector3D = slerpVector(_fromY, _toY, t);
		var sz:Vector3D = slerpVector(_fromZ, _toZ, t);
		var sx:Vector3D = cross(sy, sz);
		sy = cross(sz, sx);
		sx.normalize();
		sy.normalize();
		var m:Matrix3D = new Matrix3D();
		m.rawData = Vector.<Number>([
			sx.x, sx.y, sx.z, 0,
			sy.x, sy.y, sy.z, 0,
			sz.x, sz.y, sz.z, 0,
			0, 0, 0, 1
		]);
		return m;
	}
	
	/**
	 * ベクトルの向きをfromからtoへt（0～1）の割合だけ球面線形補間した新しい単位ベクトルを返す
	 * @param	from
	 * @param	to
	 * @param	t
	 * @return
	 */
	static public function slerpVector(from:Vector3D, to:Vector3D, t:Number):Vector3D {
		if (!from.lengthSquared || !from.lengthSquared || from.equals(to)) return from.clone();
		copy(from, _fromN);
		copy(to, _toN);
		_fromN.normalize();
		_toN.normalize();
		var angle:Number = getAngleUnit(_fromN, _toN);
		//2つのベクトルが真逆を向いていると補間できないのでずらしてます（強引かもしれない）
		if (angle == Math.PI) {
			_fromN.x += 0.000001;
			if (!_fromN.y && !_fromN.z) _fromN.y += 0.000001;
			_fromN.normalize();
			angle = getAngleUnit(_fromN, _toN);
		}
		var sin:Number = Math.sin(angle);
		if (!sin) return _fromN.clone();
		var sinf:Number = Math.sin(angle * (1 - t));
		var sint:Number = Math.sin(angle * t);
		var v:Vector3D = new Vector3D();
		if (sin) {
			v.x = (_fromN.x * sinf + _toN.x * sint) / sin;
			v.y = (_fromN.y * sinf + _toN.y * sint) / sin;
			v.z = (_fromN.z * sinf + _toN.z * sint) / sin;
		}
		v.normalize();
		return v;
	}
	
	/**
	 * ベクトルのxyzを設定する
	 * @param	v
	 * @param	x
	 * @param	y
	 * @param	z
	 */
	static public function setXYZ(v:Vector3D, x:Number, y:Number, z:Number):void {
		v.x = x;
		v.y = y;
		v.z = z;
	}
	
	/**
	 * 2つのベクトルの外積を求める
	 * @param	a
	 * @param	b
	 * @return
	 */
	static public function cross(a:Vector3D, b:Vector3D):Vector3D {
		return new Vector3D((a.y * b.z) - (a.z * b.y), (a.z * b.x) - (a.x * b.z), (a.x * b.y) - (a.y * b.x));
	}
	
	/**
	 * fromのxyzwをtoへコピーする
	 * @param	from
	 * @param	to
	 */
	static public function copy(from:Vector3D, to:Vector3D):void {
		to.x = from.x;
		to.y = from.y;
		to.z = from.z;
		to.w = from.w;
	}
	
	/**
	 * 2つのベクトルの角度をラジアン角で返す。
	 * Vector3D.angleBetween()がNaNを返す時があるのでそれの修正版。
	 * @param	a
	 * @param	b
	 * @return
	 */
	static public function getAngle(a:Vector3D, b:Vector3D):Number {
		var dot:Number = (a.x * b.x + a.y * b.y + a.z * b.z) / (a.length * b.length);
		if (dot > 1) dot = 1;
		else if (dot < -1) dot = -1;
		return Math.acos(dot);
	}
	
	/**
	 * 2つの「単位」ベクトルの角度をラジアン角で返す。（getAngleより少し速い）
	 * @param	a
	 * @param	b
	 * @return
	 */
	static public function getAngleUnit(a:Vector3D, b:Vector3D):Number {
		var dot:Number = (a.x * b.x + a.y * b.y + a.z * b.z);
		if (dot > 1) dot = 1;
		else if (dot < -1) dot = -1;
		return Math.acos(dot);
	}
}

/**
 * 簡単なサンプル用のAlternativa3Dテンプレート
 */
class Scene3D {
	public var view:Sprite = new Sprite();
	public var bg:Sprite = new Sprite();
	public var root:Object3DContainer;
	public var camera:Camera3D;
	public var controller:SimpleObjectController;
	static public const DISTANCE:String = "distance";
	static public const BSP:String = "bsp";
	static public const KD:String = "kd";
	static public const CONFLICT:String = "conflict";
	/**
	 * @param	container
	 * @param	width
	 * @param	height
	 * @param	bgColor
	 */
	public function Scene3D(container:String = CONFLICT, width:Number = 465, height:Number = 465, bgColor:uint = 0x000000) {
		switch(container) {
			case DISTANCE: root = new DistanceSortContainer(); break;
			case BSP: root = new BSPContainer(); break;
			case KD: root = new KDContainer(); break;
			case CONFLICT: root = new ConflictContainer(); break;
			default: root = new ConflictContainer();
		}
		camera = new Camera3D();
		camera.view = new View(width, height, true);
		camera.fov = 60 * Math.PI / 180;
		root.addChild(camera);
		bg.graphics.beginFill(bgColor, 1);
		bg.graphics.drawRect(0, 0, width, height);
		bg.graphics.endFill();
		view.addChild(bg);
		view.addChild(camera.view);
		controller = new SimpleObjectController(view, camera, 1);
	}
	public function render():void {
		// new View()の第三引数をtrueにしていた場合は、
		// Camera3D.viewがstageにアクセスできない状態でレンダリングしようとするとエラーになる
		if (camera.view.stage) camera.render();
	}
}

/**
 * シーンをマウスでぐるぐる(Alternativa3D軸)
 */
class SphericalDragger extends EventDispatcher {
	/**カメラの距離*/
	public var distance:Range = new Range();
	/**横方向の回転*/
	public var rotation:Range = new Range();
	/**縦方向の回転*/
	public var angle:Range = new Range();
	/**ドラッグが可能か*/
	public var dragEnabled:Boolean = true;
	/**ホイールズームが可能か*/
	public var wheelEnabled:Boolean = true;
	private var _eventObject:InteractiveObject;
	private var _clickPoint:Point;
	private var _position:Vector3D = new Vector3D();
	private const RADIAN:Number = Math.PI / 180;
	/**座標が変わると呼ばれる*/
	public var onMovePosition:Function;
	/**球面座標*/
	public function get position():Vector3D { return _position; }
	
	/**
	 * @param	obj	マウスイベントを登録する場所
	 * @param	rotation	初期の横方向角度
	 * @param	angle	初期の縦方向角度
	 * @param	distance	初期の中心点からの距離
	 */
	public function SphericalDragger(obj:InteractiveObject, rotation:Number = 0, angle:Number = 30, distance:Number = 1000) {
		this.distance.position = distance;
		this.distance.speed = 1.2;
		this.angle.position = angle;
		this.angle.min = -(this.angle.max = 89);
		this.rotation.position = rotation;
		_eventObject = obj;
		_eventObject.addEventListener(MouseEvent.MOUSE_DOWN, onMsDown);
		_eventObject.addEventListener(MouseEvent.MOUSE_WHEEL, onMsWheel);
		updatePosition();
	}
	public function notify():void {
		dispatchEvent(new Event(Event.CHANGE));
		if (onMovePosition != null) onMovePosition(_position);
	}
	private function onMsWheel(e:MouseEvent):void {
		if (!dragEnabled || !wheelEnabled) return;
		distance.position *= Math.pow(distance.speed, (e.delta < 0)? 1 : -1);
		distance.checkLimit();
		updatePosition();
	}
	private function onMsDown(e:MouseEvent):void {
		if (!dragEnabled) return;
		_eventObject.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMsMove);
		_eventObject.stage.addEventListener(MouseEvent.MOUSE_UP, onMsUp);
		rotation.save = rotation.position;
		angle.save = angle.position;
		_clickPoint = new Point(_eventObject.mouseX, _eventObject.mouseY);
	}
	private function onMsMove(e:MouseEvent):void {
		if (!dragEnabled) return;
		var dragOffset:Point = new Point(_eventObject.mouseX, _eventObject.mouseY).subtract(_clickPoint);
		rotation.position = rotation.save - dragOffset.x * rotation.speed;
		rotation.checkLimit();
		angle.position = angle.save + dragOffset.y * angle.speed;
		angle.checkLimit();
		updatePosition();
	}
	private function onMsUp(...rest):void {
		_eventObject.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMsMove);
		_eventObject.stage.removeEventListener(MouseEvent.MOUSE_UP, onMsUp);
		updatePosition();
	}
	private function updatePosition():void {
		var per:Number = Math.cos(RADIAN * angle.position);
		var px:Number = Math.cos(RADIAN * rotation.position) * distance.position * per;
		var py:Number = Math.sin(RADIAN * rotation.position) * distance.position * per;
		var pz:Number = Math.sin(RADIAN * angle.position) * distance.position;
		_position = new Vector3D(px, py, pz);
		notify();
	}
}
class Range {
	public var min:Number = NaN;
	public var max:Number = NaN;
	public var save:Number = NaN;
	public var speed:Number = 1;
	public var position:Number = 0;
	public function Range() {
	}
	public function checkLimit():void {
		if (!isNaN(min) && position < min) position = min;
		else if (!isNaN(max) && position > max) position = max;
	}
}
/**
 * ベクトルの球面線形補間
 * 
 * 参考サイト（参考というか補間部分のコードはほぼそのまま）
 * http://marupeke296.com/DXG_No57_SheareLinearInterWithoutQu.html
 */
package {
	import alternativ7.engine3d.controllers.SimpleObjectController;
	import alternativ7.engine3d.core.Geometry;
	import alternativ7.engine3d.materials.FillMaterial;
	import alternativ7.engine3d.objects.Mesh;
	import alternativ7.engine3d.primitives.Plane;
	import alternativ7.engine3d.primitives.Sphere;
	import com.bit101.components.PushButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;
	public class SlerpTest extends Sprite {
		public var scene:Scene3D;
		public var sceneDrag:SphericalDragger;
		public var arrow:Mesh;
		public var arrowController:SimpleObjectController;
		public var redSphere:Sphere;
		public var arrowVec:Vector3D = new Vector3D(0, 0, 1);
		public var lookVec:Vector3D = new Vector3D(0, 0, 1);
		public var spheres:Vector.<Sphere> = new Vector.<Sphere>();
		public var radius:Number = 250;
		public function SlerpTest() {
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		private function init(...arg):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			//テンプレートを作成して画面に配置
			scene = new Scene3D(Scene3D.CONFLICT, 465, 465, 0x222222);
			addChild(scene.view);
			
			//各種オブジェクトを生成してルートコンテナに追加
			arrow = createArrow(0xFFF319, 0xC89F05);
			arrow.scaleX = arrow.scaleY = arrow.scaleZ = 3.5;
			arrowController = new SimpleObjectController(this, arrow, 1);
			redSphere = new Sphere(20, 8, 6, false, new FillMaterial(0xFF0000));
			var grid:FillMaterial = new FillMaterial(0x444444, 0, 1, 0xAAAAAA);
			scene.root.addChild(new Plane(1200, 1200, 4, 4, true, false, false, grid, grid));
			scene.root.addChild(arrow);
			scene.root.addChild(redSphere);
			for (var i:int = 0; i < 10; i++) {
				var sphere:Sphere = new Sphere(5, 3, 2, false, new FillMaterial(0xFF << 16 | 0xFF * (1-i/10) << 8, 1));
				sphere.visible = false;
				spheres.push(sphere);
				scene.root.addChild(sphere);
			}
			
			//赤点をランダムに動かすボタン
			var btn:PushButton = new PushButton(this, 0, 0, "slerp", onClickSlerp);
			btn.setSize(60, 20);
			btn.scaleX = btn.scaleY = 2;
			
			//カメラをマウスでドラッグするクラス
			sceneDrag = new SphericalDragger(scene.view, -45, 45, 900);
			sceneDrag.wheelEnabled = false;
			sceneDrag.onMovePosition = onMoveCamera;
			sceneDrag.notify();
			
			//赤い玉を上に動かす
			setTargetPosition(0, 0, 1);
			
			//処理開始
			addEventListener(Event.ENTER_FRAME, onTick);
		}
		//毎フレーム処理
		private function onTick(e:Event):void {
			//球面線形補間
			arrowVec = VectorUtil.slerpVector(arrowVec, lookVec, 0.2);
			//プリミティブをlookAtしたら後ろを向いてしまったので逆を向かせてます
			arrowController.lookAtXYZ(-arrowVec.x, -arrowVec.y, -arrowVec.z);
			scene.render();
		}
		//ボタンクリック時
		private function onClickSlerp(e:MouseEvent):void {
			setTargetPosition(Math.random() - 0.5, Math.random() - 0.5, Math.random() - 0.5);
			for (var i:int = 0; i < spheres.length; i++) {
				var v:Vector3D = VectorUtil.slerpVector(arrowVec, lookVec, i / 10);
				v.scaleBy(radius);
				spheres[i].visible = true;
				spheres[i].x = v.x;
				spheres[i].y = v.y;
				spheres[i].z = v.z;
			}
		}
		//赤点を指定の方向へ移動
		private function setTargetPosition(x:Number, y:Number, z:Number):void {
			lookVec.x = x;
			lookVec.y = y;
			lookVec.z = z;
			//原点だったらずらす
			if (!lookVec.lengthSquared) lookVec.z = 1;
			lookVec.normalize();
			lookVec.scaleBy(radius);
			redSphere.x = lookVec.x;
			redSphere.y = lookVec.y;
			redSphere.z = lookVec.z;
		}
		//画面をドラッグしたらカメラを動かす
		private function onMoveCamera(point:Vector3D):void {
			scene.controller.setObjectPos(point);
			scene.controller.lookAtXYZ(0, 0, 0);
		}
		//矢印メッシュを作る
		private function createArrow(fill1:uint = 0xFFFFFF, fill2:uint = 0xFFFFFF):Mesh {
			var materials:Array = [new FillMaterial(fill1, 1), new FillMaterial(fill2, 1)];
			var vts:Array = [[-3,1,-2],[3,1,-2],[-3,1,2],[3,1,2],[-3,-39,-2],[3,-39,-2],[-3,-39,2],[3,-39,2],[0,-59,-2],[0,-59,2],[7,-39,-2],[7,-39,2],[-7,-39,2],[-7,-39,-2]];
			var ids:Array = [[0,2,3],[3,1,0],[1,3,7],[7,5,1],[2,0,4],[4,6,2],[10,11,9],[9,8,10],[12,13,8],[8,9,12],[5,7,11],[11,10,5],[8,13,4],[0,1,5],[4,0,5],[8,4,5],[8,5,10],[6,4,13],[13,12,6],[9,11,7],[3,2,6],[7,3,6],[9,7,6],[9,6,12]];
			var mts:Array = [1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,1,1,0,0,0,0,0];
			var geom:Geometry = new Geometry();
			for each (var vt:Array in vts) geom.addVertex(vt[0], vt[1], vt[2]);
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
import flash.geom.Point;
import flash.geom.Vector3D;
/**
 * Vector3D系クラス
 */
class VectorUtil {
	static private var _fromN:Vector3D = new Vector3D;
	static private var _toN:Vector3D = new Vector3D;
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
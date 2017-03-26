/**
 * ねぎ玉牛丼
 */
package  {
	import alternativ7.engine3d.core.Geometry;
	import alternativ7.engine3d.core.Object3DContainer;
	import alternativ7.engine3d.core.Sorting;
	import alternativ7.engine3d.materials.FillMaterial;
	import alternativ7.engine3d.objects.Mesh;
	import com.actionsnippet.qbox.QuickBox2D;
	import com.actionsnippet.qbox.QuickContacts;
	import com.bit101.components.PushButton;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import net.hires.debug.Stats;
	
	public class NegitamaGyudon extends Sprite {
		private var _sim:QuickBox2D;
		private var _contact:QuickContacts;
		private var _boxScene:BoxSceneData;
		private var _scene:Scene3D;
		private var _canvas:MovieClip;
		private var _cameraDrag:SphericalDragger;
		private var _lookAtPoint:Vector3D = new Vector3D();
		private var _isPlaying:Boolean = true;
		private var _cameraType:int = 0;
		private var _hitbits:uint = 0x000;
		private var _gyudon:Mesh;
		private var _isComplete:Boolean = false;
		//BOX2Dサイズ→Alt3Dサイズ
		private const SCALE_ALT3D:Number = 20;
		
		public function NegitamaGyudon() {
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(...arg):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			stage.frameRate = 60;
			stage.quality = StageQuality.MEDIUM;
			
			_canvas = new MovieClip();
			_canvas.visible = false;
			_scene = new Scene3D(Scene3D.BSP, 465, 465, 0xC0CCDE);
			_cameraDrag = new SphericalDragger(_scene.display);
			_cameraDrag.wheelEnabled = false;
			_cameraDrag.notify();
			//フルスクリーンにしたらホイールズームを有効にする
			_scene.onResizeStage = function(w:Number, h:Number):void {
				if (w != 465 || h != 465) _cameraDrag.wheelEnabled = true;
			}
			_scene.startAutoResize(stage);
			
			addChild(_canvas);
			addChild(_scene.display);
			addChild(new Stats());
			new PushButton(this, 75, 5, "PAUSE", onClickPause);
			new PushButton(this, 180, 5, "CAMERA", onClickCamera);
			new PushButton(this, 285, 5, "RESET", onClickReset);
			
			//牛丼とテーブルを作る
			_gyudon = createDonburi();
			_gyudon.x = 17.8 * SCALE_ALT3D;
			_gyudon.z = -17.5 * SCALE_ALT3D;
			_gyudon.y = 1 * SCALE_ALT3D;
			_gyudon.scaleX = _gyudon.scaleY = _gyudon.scaleZ = 0.125 * SCALE_ALT3D;
			var table:Mesh = createTable();
			table.matrix = _gyudon.matrix.clone();
			table.sorting = _gyudon.sorting = Sorting.DYNAMIC_BSP;
			table.z -= 0.15 * SCALE_ALT3D;
			_scene.root.addChild(table);
			_scene.root.addChild(_gyudon);
			
			format();
		}
		
		private function format():void {
			_isComplete = false;
			_isPlaying = true;
			_hitbits = 0x000;
			_cameraType = 0;
			updateCamera();
			_sim = new QuickBox2D(_canvas);
			_contact = _sim.addContactListener();
			_contact.addEventListener(QuickContacts.ADD, onCollide);
			
			_boxScene = QboxModeler.createByXML(_sim, Box2DXML.data, 1, SCALE_ALT3D);
			//Alt3Dオブジェクトをルートコンテナに配置
			var qdata:QboxData;
			for each (qdata in _boxScene.groupList)
				_scene.root.addChild(qdata.primitive);
			for each (qdata in _boxScene.bodyList)
				if (!qdata.inGroup) _scene.root.addChild(qdata.primitive);
			
			//シミュレーション開始
			_sim.start();
			addEventListener(Event.ENTER_FRAME, onTickSimulate);
		}
		
		//全衝突判定
		private function onCollide(e:Event):void {
			//青い板が跳ね上がって上のストッパーにあたった
			if (!(_hitbits & 0x00F) && _contact.isCurrentContact(_boxScene.root["bar"].qobject, _boxScene.root["barstopper"].qobject)) _hitbits |= 0x00F;
			//卵が牛丼に乗った
			if (!(_hitbits & 0x0F0) && _contact.isCurrentContact(_boxScene.root["egg"].qobject, _boxScene.root["donburi"].qobject)) _hitbits |= 0x0F0;
			//ネギを運ぶ箱がストッパーにあたった
			if (!(_hitbits & 0xF00) && _contact.isCurrentContact(_boxScene.root["negibox"].qobject, _boxScene.root["negistopper"].qobject)) _hitbits |= 0xF00;
			//たぶん完成
			if (_hitbits == 0xFFF) {
				_contact.removeEventListener(QuickContacts.ADD, onCollide);
				_isComplete = true;
				_cameraType = 0;
				updateCamera();
			}
		}
		
		//全部リセット
		private function onClickReset(e:MouseEvent):void {
			_contact.removeEventListener(QuickContacts.ADD, onCollide);
			_boxScene.destroy();
			_sim.destroy();
			while (_canvas.numChildren) _canvas.removeChildAt(_canvas.numChildren-1);
			format();
		}
		
		//カメラ切り替え
		private function onClickCamera(e:MouseEvent):void {
			_cameraType = ++_cameraType % 2;
			updateCamera();
		}
		
		//一時停止/再生
		private function onClickPause(e:MouseEvent):void{
			_isPlaying = !_isPlaying;
			if (_isPlaying) _sim.start();
			else _sim.stop();
		}
		
		//テーブルを作る
		private function createTable():Mesh {
			var materials:Array = [new FillMaterial(0x502a1e),new FillMaterial(0x2a2a2a),new FillMaterial(0x6e532e),new FillMaterial(0xa79660),new FillMaterial(0xa47638)];
			var vts:Array = [[-41,-142,0],[41,-142,0],[-41,142,0],[41,142,0],[-41,-142,-12],[41,-142,-12],[-41,142,-12],[41,142,-12],[20,142,-12],[20,-142,-12],[-19,142,-12],[-19,-142,-12],[20,-142,-100],[-19,-142,-100],[-19,142,-100],[20,142,-100]];
			var ids:Array = [[0,1,3],[3,2,0],[6,10,11],[11,4,6],[7,5,9],[9,8,7],[15,12,13],[13,14,15],[0,4,11],[0,11,9],[0,9,5],[0,5,1],[3,7,8],[3,8,10],[3,10,6],[3,6,2],[9,11,13],[13,12,9],[10,8,15],[15,14,10],[1,5,7],[7,3,1],[2,6,4],[4,0,2],[11,10,14],[14,13,11],[8,9,12],[12,15,8]];
			var mts:Array = [0,0,1,1,1,1,1,1,2,2,2,2,2,2,2,2,2,2,2,2,3,3,3,3,4,4,4,4];
			var geom:Geometry = new Geometry();
			for each (var vt:Array in vts) geom.addVertex(vt[0], vt[1], vt[2]);
			for (var i:int; i < ids.length; i++) geom.addTriFace(geom.vertices[ids[i][0]], geom.vertices[ids[i][1]], geom.vertices[ids[i][2]], materials[mts[i]]);
			var mesh:Mesh = new Mesh();
			mesh.geometry = geom;
			return mesh;
		}
		
		//牛丼を作る
		private function createDonburi():Mesh {
			var scale:Number = 0.1;
			var materials:Array = [new FillMaterial(0xd3caae),new FillMaterial(0xa79660),new FillMaterial(0x2a2a2a),new FillMaterial(0xa47638),new FillMaterial(0x20439d),new FillMaterial(0x1d2b68),new FillMaterial(0xffffff)];
			var vts:Array = [
				[129,8,0],[68,114,0],[-55,114,0],[-116,8,0],[-55,-98,0],[68,-98,0],[129,8,60],[68,114,60],[-55,114,60],[-116,8,60],[-55,-98,60],[68,-98,60],[227,8,129],[117,199,129],[-104,199,129],[-214,8,129],[-104,-183,129],[117,-183,129],[254,8,252],[130,222,252],[-117,222,252],[-240,8,252],[-117,-206,252],[130,-206,252],[223,8,211],[115,195,211],[-101,195,211],[-209,8,211],[-101,-179,211],[115,-179,211],
				[186,28,211],[96,176,211],[-74,172,211],[-167,50,211],[-114,-109,211],[83,-151,211]
			];
			var ids:Array = [
				[0,1,7],[7,6,0],[4,5,11],[11,10,4],[5,0,6],[6,11,5],[19,20,26],[26,25,19],[20,21,27],[27,26,20],[21,22,28],[28,27,21],[1,2,8],[8,7,1],[2,3,9],[9,8,2],[3,4,10],[10,9,3],[18,19,25],[25,24,18],[22,23,29],[29,28,22],[23,18,24],[24,29,23],[4,3,2],[2,1,0],[4,2,0],[5,4,0],[31,32,33],[33,34,35],
				[31,33,35],[30,31,35],[6,7,13],[13,12,6],[10,11,17],[17,16,10],[11,6,12],[12,17,11],[12,13,19],[19,18,12],[16,17,23],[23,22,16],[17,12,18],[18,23,17],[7,8,14],[14,13,7],[8,9,15],[15,14,8],[9,10,16],[16,15,9],[13,14,20],[20,19,13],[14,15,21],[21,20,14],[15,16,22],[22,21,15],[24,25,31],[31,30,24],[25,26,32],[32,31,25],
				[26,27,33],[33,32,26],[27,28,34],[34,33,27],[28,29,35],[35,34,28],[29,24,30],[30,35,29]
			];
			var mts:Array = [0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,2,2,2,2,3,3,3,3,4,4,4,4,4,4,4,4,4,4,4,4,5,5,5,5,5,5,5,5,5,5,5,5,6,6,6,6,6,6,6,6,6,6,6,6];
			var geom:Geometry = new Geometry();
			for each (var vt:Array in vts) geom.addVertex(vt[0] * scale, vt[1] * scale, vt[2] * scale);
			for (var i:int; i < ids.length; i++) geom.addTriFace(geom.vertices[ids[i][0]], geom.vertices[ids[i][1]], geom.vertices[ids[i][2]], materials[mts[i]]);
			var mesh:Mesh = new Mesh();
			mesh.geometry = geom;
			return mesh;
		}
		
		//シミュレーション中
		private function onTickSimulate(e:Event):void {
			
			if (_cameraType == 0) {
				if (_isComplete) {
					_lookAtPoint = _gyudon.matrix.position;
					_lookAtPoint.z += 2.5 * SCALE_ALT3D;
				} else if (_boxScene.trackingList.length) {
					//カメラで追跡するオブジェクトがあれば追う
					var p:Point = _boxScene.getTrackingPoint();
					_lookAtPoint.x = p.x * SCALE_ALT3D;
					_lookAtPoint.z = -p.y * SCALE_ALT3D;
				}
			} else {
				_lookAtPoint.x = 2.5 * SCALE_ALT3D;
				_lookAtPoint.z = 0;
			}
			
			var qdata:QboxData;
			//グループオブジェクトの位置更新
			for each(qdata in _boxScene.groupList) {
				var obj:Object3DContainer = qdata.primitive as Object3DContainer;
				//可動オブジェクト
				if (!qdata.qobject.body.IsStatic()) {
					obj.x = qdata.qobject.x * SCALE_ALT3D;
					obj.z = -qdata.qobject.y * SCALE_ALT3D;
					obj.rotationY = qdata.qobject.angle;
				}
			}
			//剛体オブジェクトの位置更新
			for each(qdata in _boxScene.bodyList) {
				//可動オブジェクト
				if (!qdata.qobject.body.IsStatic()) {
					if (!qdata.inGroup) {
						qdata.primitive.x = qdata.qobject.x * SCALE_ALT3D;
						qdata.primitive.z = -qdata.qobject.y * SCALE_ALT3D;
					}
					//角度が大きすぎると色々と問題があるので-360～360°に収める
					if (Math.abs(qdata.qobject.angle) > Math.PI * 2) qdata.qobject.angle = qdata.qobject.angle % (Math.PI * 2);
					qdata.primitive.rotationY = qdata.qobject.angle;
				}
			}
			//カメラ位置更新
			_scene.controller.setObjectPos(_cameraDrag.position.add(_lookAtPoint));
			_scene.controller.lookAt(_lookAtPoint);
			_scene.render();
		}
		
		//カメラ位置設定
		private function updateCamera():void {
			if (_isComplete && !_cameraType) {
				_cameraDrag.angle.position = 45;
				_cameraDrag.rotation.position = -45;
				_cameraDrag.distance.position = 25 * SCALE_ALT3D;
			} else {
				_cameraDrag.rotation.position = -70;
				_cameraDrag.angle.position = 12;
				_cameraDrag.distance.position = [27, 50][_cameraType] * SCALE_ALT3D;
			}
			_cameraDrag.updatePosition();
		}
		
	}
}

import alternativ7.engine3d.containers.BSPContainer;
import alternativ7.engine3d.containers.ConflictContainer;
import alternativ7.engine3d.containers.DistanceSortContainer;
import alternativ7.engine3d.containers.KDContainer;
import alternativ7.engine3d.controllers.SimpleObjectController;
import alternativ7.engine3d.core.Camera3D;
import alternativ7.engine3d.core.Geometry;
import alternativ7.engine3d.core.Object3D;
import alternativ7.engine3d.core.Object3DContainer;
import alternativ7.engine3d.core.Sorting;
import alternativ7.engine3d.core.View;
import alternativ7.engine3d.materials.FillMaterial;
import alternativ7.engine3d.materials.TextureMaterial;
import alternativ7.engine3d.objects.Mesh;
import alternativ7.engine3d.primitives.Box;
import alternativ7.engine3d.primitives.Plane;
import Box2D.Collision.Shapes.b2MassData;
import Box2D.Dynamics.b2Body;
import com.actionsnippet.qbox.QuickBox2D;
import com.actionsnippet.qbox.QuickObject;
import flash.display.BitmapData;
import flash.display.InteractiveObject;
import flash.display.Sprite;
import flash.display.Stage;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Vector3D;
import flash.utils.Dictionary;

/**
 * 簡単なサンプル用のAlternativa3Dテンプレート
 */
class Scene3D {
	public var display:Sprite = new Sprite();
	public var bg:Sprite = new Sprite();
	public var root:Object3DContainer;
	public var camera:Camera3D;
	public var controller:SimpleObjectController;
	public var onResizeStage:Function;
	private var _bgColor:uint;
	private var _stage:Stage;
	static public const DISTANCE:String = "distance";
	static public const BSP:String = "bsp";
	static public const KD:String = "kd";
	static public const CONFLICT:String = "conflict";
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
		display.addChild(bg);
		display.addChild(camera.view);
		_bgColor = bgColor;
		controller = new SimpleObjectController(display, camera, 1);
		setSize(width, height);
	}
	public function render():void {
		if (camera.view.stage) camera.render();
	}
	public function startAutoResize(stage:Stage):void {
		_stage = stage;
		_stage.scaleMode = StageScaleMode.NO_SCALE;
		_stage.align = StageAlign.TOP_LEFT;
		_stage.addEventListener(Event.RESIZE, onResize);
		onResize(null);
	}
	private function onResize(e:Event):void {
		setSize(_stage.stageWidth, _stage.stageHeight);
		if (onResizeStage != null) onResizeStage(_stage.stageWidth, _stage.stageHeight);
	}
	public function setSize(width:Number, height:Number):void {
		camera.view.width = width;
		camera.view.height = height;
		bg.graphics.clear();
		bg.graphics.beginFill(_bgColor, 1);
		bg.graphics.drawRect(0, 0, width, height);
		bg.graphics.endFill();
	}
}

/**
 * 円テクスチャを貼ってポリ数を減らした円柱
 */
class ColorCylinder extends Mesh {
	public function ColorCylinder(radius:Number = 50, height:Number = 50, segmentsW:int = 8, segmentsH:int = 1, color1:uint = 0x808080, color2:uint = 0x808080, fillAlpha:Number = 1) {
		var material:FillMaterial = new FillMaterial(color1, fillAlpha);
		var bmd:BitmapData = new BitmapData(100, 100, true, 0);
		var sp:Sprite = new Sprite();
		sp.graphics.beginFill(color2, fillAlpha);
		sp.graphics.drawCircle(50, 50, 50);
		sp.graphics.beginFill(0x000000, 0.5 * fillAlpha);
		sp.graphics.drawRect(50, 48, 50, 4);
		bmd.draw(sp);
		var texture:TextureMaterial = new TextureMaterial(bmd, false, false);
		var geom:Geometry = new Geometry();
		var i:int, px:Number, py:Number;
		for (i = 0; i <= segmentsW; i++) {
			var rot:Number = (i % segmentsW) / segmentsW * Math.PI * 2;
			px = Math.cos(rot) * radius;
			py = Math.sin(rot) * radius;
			geom.addVertex(px, height / 2, py, 0, 0);
			geom.addVertex(px, -height / 2, py, 0, 0);
		}
		for (i = 0; i < segmentsW * 2; i += 2)
			geom.addQuadFace(geom.vertices[i], geom.vertices[i+2], geom.vertices[i+3], geom.vertices[i+1], material);
		var h:Number = height / 2;
		for (var n:int = i + 2; n <= i + 6; n += 4) {
			geom.addVertex( -radius, h, -radius, 0, 0);
			geom.addVertex(radius, h, -radius, 1, 0);
			geom.addVertex(radius, h, radius, 1, 1);
			geom.addVertex( -radius, h, radius, 0, 1);
			if (h < 0) geom.addQuadFace(geom.vertices[n], geom.vertices[n + 1], geom.vertices[n + 2], geom.vertices[n + 3], texture);
			else geom.addQuadFace(geom.vertices[n], geom.vertices[n + 3], geom.vertices[n + 2], geom.vertices[n + 1], texture);
			h *= -1;
		}
		this.geometry = geom;
	}
}

/**
 * シーンデータ
 */
class BoxSceneData {
	public var trackingList:Vector.<QboxData> = new Vector.<QboxData>();
	public var jointList:Vector.<QboxData> = new Vector.<QboxData>();
	public var bodyList:Vector.<QboxData> = new Vector.<QboxData>();
	public var groupList:Vector.<QboxData> = new Vector.<QboxData>();
	public var group:Object = {};
	public var body:Object = {};
	public var root:Object = {};
	public function BoxSceneData() {
	}
	public function destroy():void {
		var item:QboxData;
		for each (item in bodyList) item.destroy();
		for each (item in groupList) item.destroy();
		for each (item in jointList) item.destroy();
		trackingList.length = jointList.length = bodyList.length = groupList.length = 0;
		group = { };
		body = { };
		root = { };
	}
	public function getTrackingPoint():Point {
		var p:Point = new Point(), add:Point = new Point(), qdata:QboxData, rp:Point;
		for each(qdata in trackingList) {
			add.x = add.y = 0;
			if (qdata.inGroup) {
				rp = PointUtil.rotatePoint(qdata.qobject.x, qdata.qobject.y, qdata.parentGroup.qobject.angle);
				add.x = qdata.parentGroup.qobject.x + rp.x;
				add.y = qdata.parentGroup.qobject.y + rp.y;
			} else {
				add.x = qdata.qobject.x;
				add.y = qdata.qobject.y;
			}
			if (isNaN(add.x) || isNaN(add.y)) {
				trackingList.splice(trackingList.indexOf(qdata), 1);
			} else {
				p.x += add.x;
				p.y += add.y;
			}
		}
		if (trackingList.length) {
			p.x /= trackingList.length;
			p.y /= trackingList.length;
		} else p.x = p.y = 0;
		return p;
	}
}

class QboxData {
	public var tag:String = "";
	public var qobject:QuickObject;
	public var parentGroup:QboxData;
	public var primitive:Object3D;
	public var inGroup:Boolean = false;
	public function QboxData() {
	}
	public function destroy():void {
		if (primitive && primitive.parent) primitive.parent.removeChild(primitive);
		parentGroup = null;
		primitive = null;
		qobject = null;
	}
}

class QboxModeler {
	static private var _objectsGID:Object;
	static private var _objectsID:Object;
	static private var _primitives:Array;
	/**
	 * XMLからQuickBoxシーンとAlt3Dメッシュモデルを生成
	 */
	static public function createByXML(sim:QuickBox2D, xml:XML, boxScale:Number = 1, altScale:Number = 20):BoxSceneData {
		var layerDepth:Number = 30;
		var scene:BoxSceneData = new BoxSceneData();
		var S:Number = boxScale;
		var joints:Array = [];
		var groups:Array = [];
		var node:Object;
		var primitiveOffset:Dictionary = new Dictionary();
		_primitives = [];
		_objectsGID = { };
		_objectsID = { };
		//オブジェクトの種類別にリストに格納
		for each(var item:XML in xml.children()) {
			node = { density:2, fricyion:0.5, restitution:0.5, strength:0.25, damping:0.1, density:2, motorSpeed:15, reverse:false, motorTorque:100 };
			for each(var atr:XML in item.attributes()) node[String(atr.name())] = XMLtoVALUE(atr.toString());
			if(item.name() == "primitive") _primitives.push(node);
			if(item.name() == "joint") joints.push(node);
			if(item.name() == "list") groups.push(node);
		}
		_primitives.sortOn("z", Array.NUMERIC);
		
		//背景固定用ダミーオブジェクト
		var bgData:QboxData = new QboxData();
		bgData.qobject = sim.addCircle( { x:0, y:0, radius:0.1, density:0, maskBits:0, categoryBits:0, skin:"none" } );
		primitiveOffset[bgData] = new Point();
		var fixList:Object = new Object();
		
		var qdata:QboxData;
		var qbox:QuickObject;
		
		//剛体
		for each(node in _primitives) {
			var unitOffset:Point = new Point();
			if (node.maskbits == null) node.maskbits = 1;
			
			//衝突判定のレイヤーからポリゴンの厚みを決める
			var min:int = 6;
			var max:int = 0;
			for (var i:int = 0; i < 7; i++) {
				if (node.maskbits >> i & 1) {
					if (i > max) max = i;
					if (i < min) min = i;
				}
			}
			if (min > max) min = max = 0;
			var depth:int = (max - min + 1) * layerDepth;
			var offsetY:Number = 0;
			
			//衝突判定無効
			if (node.nocollision) node.maskbits = 0;
			
			//Box2Dオブジェクト生成時に渡すパラメータ
			var param:Object = {
				skin: "none",
				lineAlpha: int(node.border),
				fillColor: node.color,
				fillAlpha: node.alpha,
				x: node.position[0] * S,
				y: -node.position[1] * S,
				angle: -node.angle,
				friction: node.friction,
				restitution: node.restitution,
				maskBits:node.maskbits,
				categoryBits:node.maskbits,
				density: node.density,
				isBullet: false
			}
			
			var mesh:Mesh;
			var map0:FillMaterial = new FillMaterial(param.fillColor, node.alpha);
			var map1:FillMaterial = new FillMaterial(Palette.mix(param.fillColor, 0xFFFFFF, 0.2), node.alpha);
			var map2:FillMaterial = new FillMaterial(Palette.mix(param.fillColor, 0xFFFFFF, 0.1), node.alpha);
			
			//地面・壁
			if (node.type == "wall") {
				var unitPos:Point = new Point(node.position[0] * S, -node.position[1] * S);
				var adjust:Point = adjustPlanePos(unitPos.x, unitPos.y, node.angle + Math.PI / 2).subtract(unitPos);
				var wallSize:Number = 30;
				var heightOffset:Point = new Point(Math.cos(node.angle) * -wallSize / 2 * S, Math.sin(node.angle) * wallSize / 2 * S);
				unitOffset = heightOffset.add(adjust);
				param.x = unitPos.x + unitOffset.x,
				param.y = unitPos.y + unitOffset.y,
				param.width = wallSize * S;
				param.height = 300 * S;
				param.density = 0;
				qbox = sim.addBox(param);
				mesh = new Plane(param.height * altScale, depth, 1, 1, true, false, false, null, map0);
				mesh.x = (param.x - heightOffset.x) * altScale;
				mesh.z = -(param.y - heightOffset.y) * altScale;
				mesh.y = min * layerDepth + depth/2 + offsetY;
				mesh.rotationY = param.angle + Math.PI / 2;
			}
			//ボックス
			if (node.type == "box") {
				param.width = node.size[0] * S;
				param.height = node.size[1] * S;
				qbox = sim.addBox(param);
				if (node.plane) {
					mesh = new Plane(param.width * altScale, param.height * altScale, 1, 1, true, false, false, map1, map1);
					mesh.rotationX = Math.PI / 2;
					offsetY = layerDepth / 2;
				} else {
					mesh = new Box(param.width * altScale, depth, param.height * altScale, 1, 1, 1, false, false, map0, map0, map1, map1, map2, map2);
				}
			}
			//円
			if (node.type == "circle") {
				param.radius = node.radius * S;
				qbox = sim.addCircle(param);
				var seg:int = (param.radius>3)? 16 : (param.radius>0.3)? 8 : 4;
				mesh = new ColorCylinder(param.radius * altScale, depth, seg, 1, param.fillColor, Palette.mix(param.fillColor, 0xFFFFFF, 0.3), param.fillAlpha);
			}
			
			if (node.type != "wall") {
				mesh.x = param.x * altScale;
				mesh.z = -param.y * altScale;
				mesh.y = min * layerDepth + depth/2 + offsetY;
				mesh.rotationY = param.angle;
			}
			mesh.visible = node.visible !== false && param.fillAlpha;
			mesh.sorting = (node.type == "wall" || node.sort == "bsp")? Sorting.DYNAMIC_BSP : Sorting.AVERAGE_Z;
			if (node.scalez != null) mesh.scaleY *= node.scalez;
			
			qdata = new QboxData();
			qdata.tag = node.tag;
			qdata.primitive = mesh;
			qdata.qobject = qbox;
			
			primitiveOffset[qdata] = unitOffset;
			scene.bodyList.push(qdata);
			if(node.group != null) _objectsGID[node.group] = qdata;
			if(node.id != null) _objectsID[node.id] = qdata;
			
			//タグがついていたら
			if (node.tag != null) {
				scene.body[node.tag] = qdata;
				scene.root[node.tag] = qdata;
			}
			if (node.fix != null) {
				if (fixList["_" + node.fix] == null) fixList["_" + node.fix] = [qdata];
				else fixList["_" + node.fix].push(qdata);
			}
		}
		//グループ
		for (var k:String in fixList) {
			if (k == "_0") {
				//背景に固定
				for each(var qdt:QboxData in fixList[k]) qdt.qobject.body.SetMass(new b2MassData());
			} else {
				//グループ化
				var qd:QboxData;
				var xy:Point = new Point();
				for each(qd in fixList[k]) xy.offset(qd.qobject.x, qd.qobject.y);
				var center:Point = new Point(xy.x / fixList[k].length, xy.y / fixList[k].length);
				for each(qd in fixList[k]) qd.qobject.setLoc(qd.qobject.x - center.x, qd.qobject.y - center.y);
				
				var objects:Array = [];
				for each(qd in fixList[k]) objects.push(qd.qobject);
				var container3d:Object3DContainer = new Object3DContainer();
				
				qdata = new QboxData();
				qdata.qobject = sim.addGroup( { objects:objects, x:center.x, y:center.y, skin:"none" } );
				qdata.primitive = container3d;
				for each(qd in fixList[k]) {
					qd.inGroup = true;
					qd.parentGroup = qdata;
					qd.primitive.x = qd.qobject.x * altScale;
					qd.primitive.z = -qd.qobject.y * altScale;
					container3d.addChild(qd.primitive);
					//グループ内のオブジェクトにタグがついていたら
					if (qd.tag != null) {
						scene.group[qd.tag] = qdata;
						scene.root[qd.tag] = qdata;
					}
				}
				scene.groupList.push(qdata);
			}
		}
		
		//カメラ追跡オブジェクトがあれば配列に保存
		for each(node in groups) {
			if (node.name == "tracked") {
				for each(var id:Number in node.groups) {
					if (_objectsGID[id]) scene.trackingList.push(_objectsGID[id]);
				}
			}
		}
		
		//ヒンジ・バネ
		for each(node in joints) {
			var prim0:QboxData = (!node.target0)? bgData : _objectsID[node.target0];
			var prim1:QboxData = (!node.target1)? bgData : _objectsID[node.target1];
			if (!prim0 || !prim1 || (!node.target0 && !node.target1) || (prim0.qobject.body.IsStatic() && prim1.qobject.body.IsStatic())) continue;
			var pos0:Point = new Point(prim0.qobject.x, prim0.qobject.y).add(PointUtil.rotatePoint(node.offset0[0] * S, -node.offset0[1] * S, prim0.qobject.angle)).subtract(primitiveOffset[prim0]);
			var pos1:Point = new Point(prim1.qobject.x, prim1.qobject.y).add(PointUtil.rotatePoint(node.offset1[0] * S, -node.offset1[1] * S, prim1.qobject.angle)).subtract(primitiveOffset[prim1]);
			if (prim0.inGroup) pos0.offset(prim0.parentGroup.qobject.x, prim0.parentGroup.qobject.y);
			if (prim1.inGroup) pos1.offset(prim1.parentGroup.qobject.x, prim1.parentGroup.qobject.y);
			var pos:Point = Point.interpolate(pos0, pos1, 0.5);
			var body0:b2Body = (prim0.inGroup)? prim0.parentGroup.qobject.body : prim0.qobject.body;
			var body1:b2Body = (prim1.inGroup)? prim1.parentGroup.qobject.body : prim1.qobject.body;
			//バネ
			if (node.type == "spring")
				qbox = sim.addJoint({
					type: "distance",
					lineAlpha: 1,
					a: body0,
					b: body1,
					x1: pos0.x,
					y1: pos0.y,
					x2: pos1.x,
					y2: pos1.y,
					length: node.length * S,
					collideConnected: true,
					dampingRatio: node.damping,
					frequencyHz: node.strength * 100
				});
			//ヒンジ
			if (node.type == "hinge")
				qbox = sim.addJoint( {
					type: "revolute",
					lineAlpha: 0,
					enableMotor: node.motor,
					maxMotorTorque: node.motorTorque,
					motorSpeed: node.motorSpeed * (int(node.reverse)*2 - 1),
					collideConnected: false,
					a: body0,
					b: body1,
					x1: pos.x,
					y1: pos.y
				});
			qdata = new QboxData();
			qdata.qobject = qbox;
			scene.jointList.push(qdata);
		}
		_primitives = null;
		_objectsGID = null;
		_objectsID = null;
		return scene;
	}
	static private function XMLtoVALUE(data:String):* {
		if (data == "true" || data == "false") return (data == "true");
		if (data.substr(0, 1) == "[" && data.substr( -1) == "]") {
			var values:Array = data.substr(1, data.length - 2).split(",");
			for (var i:int = 0; i < values.length; i++) values[i] = Number(values[i]);
			return values;
		}
		if (isNaN(Number(data))) return String(data);
		return Number(data);
	}
	static private function adjustPlanePos(x:Number, y:Number, angle:Number):Point {
		return PointUtil.crossVertical(new Point(x, y), new Point(x + Math.cos(angle) * 100, y - Math.sin(angle) * 100), new Point(0, 0));
	}
}

class Palette {
	/**
	 * 色を混ぜる
	 */
	static public function mix(rgb1:uint, rgb2:uint, per:Number = 1):Number {
		var per2:Number = (1 - per);
		var r:uint = (rgb1 >> 16 & 0xFF) * per2 + (rgb2 >> 16 & 0xFF) * per;
		var g:uint = (rgb1 >> 8 & 0xFF) * per2 + (rgb2 >> 8 & 0xFF) * per;
		var b:uint = (rgb1 & 0xFF) * per2 + (rgb2 & 0xFF) * per;
		return r << 16 | g << 8 | b;
	}
}

class PointUtil {
	/**
	 * 2点を通る直線とある点からおろした垂線との交点を求める
	 */
	static public function crossVertical(p1:Point, p2:Point, p3:Point):Point {
		var x1:Number = p1.x, y1:Number = p1.y;
		var x2:Number = p2.x, y2:Number = p2.y;
		var x3:Number = p3.x, y3:Number = p3.y;
		var xgap:Number = x1 - x2, ygap:Number = y1 - y2;
		if (ygap == 0) return new Point(p3.x, p1.y);
		var a1:Number = -xgap / ygap;
		var c1:Number = xgap * x3 / ygap + y3;
		var a2:Number = -ygap;
		var b2:Number = xgap;
		var c2:Number = -x1 * a2 + y1 * -b2;
		var z:Number = a1 * b2 + a2;
		return new Point(( -c2 - b2 * c1) / z, (a2 * c1 - a1 * c2) / z);
	}
	static public function rotatePoint(x:Number, y:Number, rad:Number):Point {
		var px:Number = x * Math.cos(rad) - y * Math.sin(rad);
		var py:Number = x * Math.sin(rad) + y * Math.cos(rad);
		return new Point(px, py);
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
	public function updatePosition():void {
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

/**
 * Box2Dで生成するオブジェクトをまとめたXML
 */
class Box2DXML {
	static public var data:XML = <box2d>
		<primitive type="circle" position="[-0.0963,9.9165]" id="276" radius="5.3" group="466" alpha="0.76" color="4545841" border="true" fix="373" z="0" angle="-0.6346" maskbits="8"/>
		<primitive type="circle" fix="375" position="[15.7505,-5.0704]" id="277" radius="0.8217" group="467" alpha="0.367" color="15825530" border="true" visible="false" z="1" angle="-1.252" maskbits="8"/>
		<primitive type="box" size="[0.26,4.3929]" position="[-1.1649,-1.31]" id="278" group="468" alpha="1" color="10172500" border="true" fix="0" z="2" angle="0" maskbits="8"/>
		<primitive type="box" size="[14.6,0.25]" position="[5.9277,-4.9381]" id="279" group="469" alpha="1" color="10172500" border="true" fix="0" z="3" angle="-0.1569" maskbits="8"/>
		<primitive type="box" size="[24.2878,0.3]" position="[15.8296,0.0894]" id="280" group="470" alpha="1" color="10172500" border="true" fix="0" z="4" angle="0.1373" maskbits="8"/>
		<primitive type="box" size="[6.8,0.38]" position="[-5.2535,-3.6529]" id="281" group="471" alpha="1" color="4473924" border="true" fix="380" z="5" angle="-0.1394" maskbits="4"/>
		<primitive type="box" size="[0.35,0.76]" position="[-2.0269,-3.8962]" id="282" group="472" alpha="1" color="4473924" border="true" fix="380" z="6" angle="-0.1529" maskbits="6"/>
		<primitive type="box" fix="383" size="[0.43,2.283]" position="[-2.2842,-2.7115]" id="283" group="473" alpha="1" color="11972482" border="true" tag="negibox" z="7" angle="-0.1422" maskbits="4"/>
		<primitive type="box" size="[0.35,1.8385]" position="[-3.1889,-0.8164]" id="284" group="474" alpha="1" color="11972482" border="true" z="8" maskbits="4" angle="-0.1714"/>
		<primitive type="box" size="[1.145,0.155]" position="[-3.3871,-3.1702]" id="285" group="475" alpha="1" color="2643986" border="true" z="9" maskbits="2" angle="-0.1422"/>
		<primitive type="box" size="[1.145,0.155]" position="[-3.2727,-2.7758]" id="286" group="476" alpha="1" color="2643986" border="true" z="10" maskbits="2" angle="-0.1422"/>
		<primitive type="box" size="[1.145,0.155]" position="[-3.3139,-2.3576]" id="287" group="477" alpha="1" color="2643986" border="true" z="11" maskbits="2" angle="-0.1422"/>
		<primitive type="box" size="[1.145,0.155]" position="[-3.2427,-2.987]" id="288" group="478" alpha="1" color="2643986" border="true" z="12" maskbits="2" angle="-0.1422"/>
		<primitive type="box" size="[1.145,0.155]" position="[-3.2365,-2.5578]" id="289" group="479" alpha="1" color="2643986" border="true" z="13" maskbits="2" angle="-0.1422"/>
		<primitive type="box" size="[1.145,0.155]" position="[-3.2324,-2.1244]" id="290" group="480" alpha="1" color="2643986" border="true" z="14" maskbits="2" angle="-0.1422"/>
		<primitive type="box" size="[2.2129,0.4]" restitution="0" friction="0" position="[-3.0087,-1.6452]" id="291" group="481" alpha="1" color="11972482" border="true" z="15" maskbits="2" angle="-0.1422" fix="383"/>
		<primitive type="box" size="[2.1906,0.4]" position="[-3.2933,-3.4984]" id="292" group="482" alpha="1" color="11972482" border="true" fix="383" z="16" angle="-0.1422" maskbits="2"/>
		<primitive type="box" fix="0" size="[27.2,0.7]" density="2" position="[9.4438,-2.8586]" id="293" group="483" alpha="1" color="3425350" border="true" sort="bsp" z="17" angle="-0.1431" maskbits="2"/>
		<primitive type="box" fix="402" size="[0.33,1.18]" density="2" position="[13.0446,-11.5861]" id="294" group="484" alpha="1" color="8043667" border="true" visible="false" z="18" angle="-0.0796" maskbits="0"/>
		<primitive type="box" size="[4.5421,1.15]" position="[-17.1227,-9.3686]" id="295" group="485" alpha="1" color="2708131" border="true" fix="0" z="19" angle="0"/>
		<primitive type="box" fix="405" size="[2.3723,0.2777]" density="11" friction="0.72" id="296" position="[-2.6795,7.6345]" group="486" alpha="1" color="9211020" border="true" visible="false" z="20" angle="0.001" maskbits="0"/>
		<primitive type="circle" position="[6.8612,-10.59]" id="297" radius="4.85" group="487" alpha="0.76" color="3424598" border="true" fix="407" z="21" angle="-1.5987" maskbits="16"/>
		<primitive type="box" size="[2.8663,2.834]" density="1.7" position="[3.7519,9.3024]" id="298" group="488" alpha="1" color="2631720" border="true" z="23" maskbits="4" angle="-0.0039" fix="409"/>
		<primitive type="box" fix="0" size="[12.95,0.35]" density="2" restitution="0" friction="0" id="299" position="[-10.1504,-8.4162]" group="489" alpha="1" color="14461952" border="true" sort="bsp" z="25" angle="-0.0771" maskbits="12"/>
		<primitive type="box" size="[0.53,1.68]" position="[-13.1707,2.581]" id="300" group="490" alpha="1" color="15119877" border="true" fix="0" z="26" angle="0" maskbits="8"/>
		<primitive type="box" size="[0.53,1.68]" position="[-12.3192,2.581]" id="301" group="491" alpha="1" color="15119877" border="true" fix="0" z="27" angle="0" maskbits="8"/>
		<primitive type="box" size="[0.31,2.8921]" density="30" restitution="0" friction="0.1" id="302" position="[-12.7504,1.8972]" group="492" alpha="1" color="9211020" border="true" z="28" maskbits="8" angle="-0.0084" fix="414"/>
		<primitive type="circle" position="[-12.3978,-3.2088]" id="303" radius="4.6593" group="493" alpha="0.76" color="11442770" border="true" fix="416" z="29" angle="-3.1358" maskbits="2"/>
		<primitive type="circle" density="1" restitution="0" friction="0.72" id="304" position="[-3.7529,7.6297]" radius="0.4977" group="494" alpha="1" color="3750201" border="true" z="31" angle="2.2577"/>
		<primitive type="circle" density="1" restitution="0" friction="0.72" id="305" position="[-1.6041,7.6318]" radius="0.4913" group="495" alpha="1" color="3750201" border="true" z="33" angle="-1.7267"/>
		<primitive type="box" size="[7.745,0.5863]" position="[-6.9349,-9.9872]" id="306" group="496" alpha="1" color="2708131" border="true" fix="0" z="35" angle="-0.3125"/>
		<primitive type="box" size="[7.4623,0.5617]" restitution="0" position="[-14.1904,-9.1255]" id="307" group="497" alpha="1" color="2708131" border="true" fix="0" z="37" angle="0.0841"/>
		<primitive type="box" size="[0.2469,1.6508]" density="1.5" restitution="0" friction="2" id="308" position="[-3.797,9.0089]" group="498" alpha="1" color="7208961" border="true" z="38" fix="405" angle="0.0009"/>
		<primitive type="box" size="[0.2469,2.2188]" density="1.5" restitution="0" friction="2" id="309" position="[-2.6596,8.3083]" group="499" alpha="1" color="7208961" border="true" z="39" fix="405" angle="-1.5699"/>
		<primitive type="box" size="[0.2469,1.6508]" density="1.5" restitution="0" friction="2" id="310" position="[-1.5027,9.0148]" group="500" alpha="1" color="7208961" border="true" z="40" fix="405" angle="0.0009"/>
		<primitive type="circle" restitution="0" friction="0" id="311" position="[-6.6337,10.7505]" radius="0.226" group="501" alpha="1" color="15007744" border="true" z="41" angle="-1.2859"/>
		<primitive type="circle" restitution="0" friction="0" id="312" position="[-5.2222,11.004]" radius="0.226" group="502" alpha="1" color="15007744" border="true" z="42" angle="1.1278"/>
		<primitive type="circle" restitution="0" friction="0" id="313" position="[-6.1921,10.1755]" radius="0.226" group="503" alpha="1" color="15007744" border="true" z="43" angle="2.222"/>
		<primitive type="circle" restitution="0" friction="0" id="314" position="[-5.9103,10.6635]" radius="0.226" group="504" alpha="1" color="15007744" border="true" z="44" angle="2.222"/>
		<primitive type="circle" restitution="0" friction="0" id="315" position="[-5.4722,10.3087]" radius="0.226" group="505" alpha="1" color="15007744" border="true" z="45" angle="2.7912"/>
		<primitive type="box" size="[3.15,0.329]" density="20" position="[-14.0407,-0.6192]" id="316" group="506" alpha="1" color="7933197" border="true" fix="416" z="46" angle="-1.0472"/>
		<primitive type="box" size="[3.15,0.329]" density="20" position="[-14.678,-1.1691]" id="317" group="507" alpha="1" color="7933197" border="true" fix="416" z="47" angle="-0.513"/>
		<primitive type="box" size="[2.9561,0.3087]" density="20" restitution="0" position="[-13.9099,-3.1685]" id="318" group="508" alpha="1" color="7933197" border="true" z="48" fix="416" angle="-2.0128"/>
		<primitive type="box" size="[6.2178,0.3165]" density="20" restitution="0" friction="0.07" id="319" position="[-11.7056,-2.564]" group="509" alpha="1" color="7933197" border="true" sort="bsp" z="49" angle="-2.1825" fix="416"/>
		<primitive type="box" size="[0.717,0.329]" friction="0" position="[-12.4286,1.6163]" id="320" group="510" alpha="1" color="7933197" border="true" z="50" maskbits="4" angle="1.5766" fix="416"/>
		<primitive type="box" size="[1.89,0.8]" position="[-16.1977,2.1711]" id="321" group="511" alpha="1" color="10592673" border="true" fix="0" z="53" angle="0" maskbits="2"/>
		<primitive type="box" size="[0.31,0.4254]" density="17" restitution="0" friction="0" id="322" position="[-12.7488,1.3902]" group="512" alpha="1" color="4144959" border="true" z="55" maskbits="4" angle="-0.0084" fix="414"/>
		<primitive type="box" size="[0.31,0.4254]" density="25" restitution="0" friction="0" id="323" position="[-12.7342,3.1158]" group="513" alpha="1" color="4144959" border="true" z="56" maskbits="4" angle="-0.0084" fix="414"/>
		<primitive type="box" size="[11.0801,0.4806]" restitution="0" position="[-2.3091,-3.3722]" id="324" group="514" alpha="1" color="8163669" border="true" sort="bsp" z="61" angle="0.4628" fix="0"/>
		<primitive type="box" size="[5.81,0.35]" density="8" restitution="0" friction="0.1" position="[-14.9212,2.744]" id="325" group="515" alpha="1" color="3554128" border="true" z="63" maskbits="2" angle="-0.0034" fix="446"/>
		<primitive type="box" size="[0.28,0.34]" friction="0" position="[-12.7352,2.7334]" id="326" group="516" alpha="1" color="4802889" border="true" fix="446" z="64" angle="-0.0034" maskbits="4"/>
		<primitive type="box" size="[1.87,1.04]" position="[-16.193,3.4454]" id="327" group="517" alpha="1" color="10592673" border="true" fix="0" z="66" angle="0" maskbits="2"/>
		<primitive type="box" size="[3.6178,0.48]" restitution="0" position="[-15.9171,-8.5827]" id="328" group="518" alpha="1" color="3554128" border="true" fix="450" z="69" angle="0"/>
		<primitive type="box" size="[0.45,0.7547]" restitution="0" position="[-14.3066,-8.173]" id="329" group="519" alpha="1" color="3554128" border="true" fix="450" z="70" angle="0"/>
		<primitive type="box" size="[0.35,11.62]" position="[-17.9616,-2.9526]" id="330" group="520" alpha="1" color="3554128" border="true" sort="bsp" z="71" angle="0.0071" maskbits="3"/>
		<primitive type="box" size="[0.615,0.315]" position="[-14.3715,2.7469]" id="331" group="521" alpha="1" color="4802889" border="true" fix="446" z="74" angle="-0.0096"/>
		<primitive type="box" size="[0.38,3.241]" position="[-13.9161,4.5913]" id="332" group="522" alpha="1" color="5578013" border="true" fix="0" z="76" angle="0"/>
		<primitive type="box" size="[0.38,6.58]" position="[-14.8106,6.2608]" id="333" group="523" alpha="1" color="5578013" border="true" fix="0" z="77" angle="0"/>
		<primitive type="box" size="[0.36,1.6472]" position="[-14.9038,1.709]" id="334" group="524" alpha="1" color="5578013" border="true" fix="0" z="79" angle="0"/>
		<primitive type="box" size="[0.36,1.2261]" position="[-13.8686,1.9217]" id="335" group="525" alpha="1" color="5578013" border="true" fix="0" z="80" angle="0"/>
		<primitive type="box" size="[8.7,0.4]" position="[-9.8906,7.5216]" id="336" group="526" alpha="1" color="4923681" border="true" fix="0" z="84" angle="0.3524"/>
		<primitive type="box" size="[8.318,0.4282]" restitution="0" position="[6.6207,-0.7549]" id="337" group="527" alpha="1" color="8163669" border="true" fix="0" z="86" angle="0"/>
		<primitive type="box" size="[0.24,0.652]" density="2" restitution="0.61" friction="0" id="338" position="[-2.6665,8.0441]" group="528" alpha="1" color="3750201" border="true" z="88" maskbits="0" angle="0.001" fix="405"/>
		<primitive type="box" size="[6.5401,0.6]" position="[0.1664,-11.4697]" id="339" group="529" alpha="1" color="2708131" border="true" fix="0" z="89" angle="0"/>
		<primitive type="box" size="[0.65,0.65]" density="2" position="[-2.6671,5.7684]" id="340" group="530" alpha="1" color="2236962" border="true" fix="373" z="91" angle="1.0075" maskbits="7"/>
		<primitive type="box" size="[11.3652,0.75]" position="[0.0216,6.5934]" id="341" group="531" alpha="1" color="9838867" border="true" sort="bsp" z="92" angle="0.001"/>
		<primitive type="box" size="[0.5,3.1]" density="0.47" position="[2.4559,9.2961]" id="342" group="532" alpha="1" color="4473924" border="true" fix="409" z="94" angle="-0.0039" maskbits="2"/>
		<primitive type="box" size="[0.5,3.1]" friction="1.17" position="[-12.152,19.1797]" id="343" group="533" alpha="1" color="4473924" border="true" z="95" maskbits="2" angle="-0.374" fix="468"/>
		<primitive type="box" size="[0.5,3.1]" density="0.47" position="[5.0522,9.2506]" id="344" group="534" alpha="1" color="4473924" border="true" fix="409" z="96" angle="-0.0039" maskbits="2"/>
		<primitive type="box" size="[0.5,3.1]" position="[-14.721,20.0947]" id="345" group="535" alpha="1" color="4473924" border="true" fix="468" z="97" angle="-0.374" maskbits="2"/>
		<primitive type="box" size="[0.5,3.1]" density="0.47" position="[3.749,7.984]" id="346" group="536" alpha="1" color="4473924" border="true" fix="409" z="98" angle="-1.5747" maskbits="2"/>
		<primitive type="box" size="[0.5,3.1]" friction="0" position="[-13.9772,18.4366]" id="347" group="537" alpha="1" color="4473924" border="true" z="99" maskbits="2" angle="1.1968" fix="468"/>
		<primitive type="box" size="[8.3744,0.75]" restitution="0" position="[9.9539,5.5115]" id="348" group="538" alpha="1" color="9838867" border="true" fix="0" z="105" angle="0"/>
		<primitive type="box" fix="0" size="[12.15,0.45]" density="2" position="[-10.1044,16.4401]" id="349" group="539" alpha="1" color="6268250" border="true" sort="bsp" z="107" angle="-0.3631" maskbits="2"/>
		<primitive type="box" size="[7.9716,0.45]" position="[-1.952,12.4879]" id="350" group="540" alpha="1" color="6268250" border="true" fix="0" z="108" angle="0" maskbits="2"/>
		<primitive type="box" size="[0.45,6.25]" position="[5.072,13.9639]" id="351" group="541" alpha="1" color="6268250" border="true" fix="0" z="109" angle="0" maskbits="2"/>
		<primitive type="box" size="[0.7338,9.8784]" density="2" restitution="0" friction="0.78" id="352" position="[15.5295,0.982]" group="542" alpha="1" color="8163669" border="true" z="111" fix="0" angle="-1.2148"/>
		<primitive type="box" size="[4.5561,0.3478]" friction="0" position="[-1.3313,-9.0063]" id="353" group="543" alpha="1" color="14461952" border="true" z="116" maskbits="12" angle="0" fix="0"/>
		<primitive type="box" size="[0.3565,3.4795]" restitution="0" friction="1.12" position="[3.3208,-8.5503]" id="354" group="544" alpha="1" color="14461952" border="true" z="118" maskbits="4" angle="0" fix="0"/>
		<primitive type="box" size="[0.33,1.61]" restitution="0" friction="0.75" position="[3.3249,-11.1134]" id="355" group="545" alpha="1" color="14461952" border="true" z="121" maskbits="4" angle="0" fix="407"/>
		<primitive type="box" size="[1,0.33]" restitution="0" friction="0.75" position="[2.8061,-11.7476]" id="356" group="546" alpha="1" color="14461952" border="true" z="122" maskbits="4" angle="0" fix="407"/>
		<primitive type="box" size="[0.31,1.295]" restitution="0" friction="0.75" position="[2.3025,-11.2888]" id="357" group="547" alpha="1" color="14461952" border="true" z="123" maskbits="4" angle="0.3317" fix="407"/>
		<primitive type="box" size="[0.52,0.52]" density="12.5" restitution="0" friction="0" position="[-12.9609,18.8392]" id="358" group="548" alpha="1" color="12426770" border="true" z="127" maskbits="2" angle="0"/>
		<primitive type="box" size="[0.52,0.52]" density="12.5" restitution="0" friction="0" position="[-13.1939,20.3145]" id="359" group="549" alpha="1" color="12426770" border="true" z="128" maskbits="2" angle="0"/>
		<primitive type="box" size="[0.52,0.52]" density="12.5" restitution="0" friction="0" position="[-13.6135,19.0894]" id="360" group="550" alpha="1" color="12426770" border="true" z="129" maskbits="2" angle="0"/>
		<primitive type="box" size="[0.52,0.52]" density="12.5" restitution="0" friction="0" position="[-13.8216,20.4897]" id="361" group="551" alpha="1" color="12426770" border="true" z="130" maskbits="2" angle="0"/>
		<primitive type="box" size="[0.52,0.52]" density="12.5" restitution="0" friction="0" position="[-12.9476,19.4306]" id="362" group="552" alpha="1" color="12426770" border="true" z="131" maskbits="2" angle="0"/>
		<primitive type="box" size="[0.52,0.52]" density="12.5" restitution="0" friction="0" position="[-12.5184,20.0312]" id="363" group="553" alpha="1" color="12426770" border="true" z="132" maskbits="2" angle="0"/>
		<primitive type="box" size="[0.52,0.52]" density="12.5" restitution="0" friction="0" position="[-13.7003,19.7183]" id="364" group="554" alpha="1" color="12426770" border="true" z="133" maskbits="2" angle="0"/>
		<primitive type="box" size="[0.52,0.52]" density="12.5" restitution="0" friction="0" position="[-14.2956,19.2818]" id="365" group="555" alpha="1" color="12426770" border="true" z="134" maskbits="2" angle="0"/>
		<primitive type="box" size="[9.3939,0.6]" density="1.3" restitution="0" friction="0.91" id="366" position="[8.4977,-11.8777]" group="556" alpha="1" color="2708131" border="true" sort="bsp" tag="bar" z="135" angle="-0.0631" fix="402"/>
		<primitive type="box" size="[0.3359,1.8824]" density="0.028" restitution="0" friction="2" id="367" position="[13.1219,-10.4034]" group="557" alpha="1" color="2708131" border="true" z="136" fix="402" angle="-0.0631"/>
		<primitive type="box" size="[2.27,0.4]" position="[-5.5994,9.6537]" id="368" group="558" alpha="1" color="3835913" border="true" fix="502" z="138" angle="0"/>
		<primitive type="box" size="[0.4,1.83]" position="[-4.6589,10.4155]" id="369" group="559" alpha="1" color="3835913" border="true" fix="502" z="139" angle="0"/>
		<primitive type="box" size="[0.4,1.83]" position="[-7.2167,10.0069]" id="370" group="560" alpha="1" color="3835913" border="true" fix="502" z="140" angle="1.2063"/>
		<primitive type="box" size="[0.55,4.7403]" restitution="0" friction="1.08" id="371" position="[12.8844,-3.3366]" group="561" alpha="1" color="2708131" border="true" tag="barstopper" z="149" angle="0" fix="0"/>
		<primitive type="box" fix="0" size="[0.75,3]" friction="0" position="[15.5613,-15.6869]" id="372" group="562" alpha="1" color="16777215" border="true" visible="false" z="151" angle="0.3184" maskbits="3"/>
		<primitive type="box" fix="0" size="[4.5949,2.9913]" restitution="0.105" position="[17.8138,-16.351]" id="373" group="563" alpha="1" color="16777215" border="true" visible="false" tag="donburi" z="152" angle="0" maskbits="3"/>
		<primitive type="box" fix="0" size="[0.7,2.95]" friction="0" position="[20.0534,-15.6321]" id="374" group="564" alpha="1" color="16777215" border="true" visible="false" z="153" angle="-0.2605" maskbits="3"/>
		<primitive type="box" size="[0.62,0.62]" density="3.5" position="[10.3224,-12.7117]" id="375" group="565" alpha="1" color="5657913" border="true" fix="407" z="156" angle="-0.7854" maskbits="15"/>
		<primitive type="box" size="[1.035,0.268]" density="7.7" position="[-2.6703,7.6346]" id="376" group="566" alpha="1" color="3881787" border="true" fix="405" z="158" angle="0"/>
		<primitive type="box" size="[4.9989,0.86]" restitution="0" friction="1.62" position="[21.3173,3.9498]" id="377" group="567" alpha="1" color="7626831" border="true" z="164" maskbits="9" angle="0" fix="0"/>
		<primitive type="box" size="[0.7834,6.3022]" density="5" restitution="0" friction="0.21" id="378" position="[18.9998,7.5746]" group="568" alpha="1" color="7626831" border="true" z="165" maskbits="9" angle="0"/>
		<primitive type="circle" position="[-3.079,-0.0904]" id="379" radius="0.61" group="569" alpha="1" color="11972482" border="true" z="169" maskbits="2" angle="-1.5201"/>
		<primitive type="box" fix="0" size="[0.4,1.4]" restitution="0.39" position="[22.3835,-6.2472]" id="380" group="570" alpha="1" color="3425350" border="true" tag="negistopper" z="173" angle="-0.1688" maskbits="2"/>
		<primitive type="circle" restitution="0" friction="0.13" position="[15.7513,-5.0744]" id="381" radius="0.8" group="571" alpha="1" color="14145495" border="true" z="175" maskbits="0" angle="-1.2864" fix="375"/>
		<primitive type="box" size="[0.54,0.2831]" density="2.6" restitution="0" friction="0" id="382" position="[15.1828,-5.0518]" group="572" alpha="1" color="9685242" border="true" visible="false" z="176" angle="1.5708" fix="375"/>
		<primitive type="box" size="[0.54,0.2831]" restitution="0" friction="0" id="383" position="[16.3364,-5.0648]" group="573" alpha="1" color="9685242" border="true" visible="false" z="177" angle="1.5708" fix="375"/>
		<primitive type="box" size="[0.54,0.2988]" restitution="0" friction="0" id="384" position="[15.7668,-5.635]" group="574" alpha="1" color="9685242" border="true" visible="false" z="178" angle="0" fix="375"/>
		<primitive type="circle" density="4" restitution="0" friction="0.1" id="385" position="[15.7494,-5.088]" radius="0.4105" group="575" alpha="1" color="16756224" border="true" scalez="0.5" tag="egg" z="179" angle="-1.332"/>
		<primitive type="circle" density="1.8" restitution="0" friction="0.01" id="386" position="[23.6239,5.3185]" radius="0.8933" group="576" alpha="1" color="3480582" border="true" z="181" maskbits="8" angle="-1.3258"/>
		<primitive type="box" size="[0.303,5.2]" position="[28.0576,4.5735]" id="387" group="577" alpha="1" color="10172500" border="true" fix="0" z="182" angle="0" maskbits="8"/>
		<primitive type="box" size="[0.38,0.38]" position="[-10.4292,-7.0538]" id="388" group="578" alpha="1" color="5574661" border="true" fix="416" z="185" angle="0.4957" maskbits="4"/>
		<primitive type="box" size="[3.0136,0.278]" position="[14.6942,-6.087]" id="389" group="579" alpha="1" color="10172500" border="true" fix="0" z="189" angle="0" maskbits="9"/>
		<primitive type="box" size="[0.28,1.69]" position="[14.7093,-5.0524]" id="390" group="580" alpha="1" color="12462392" border="true" fix="529" z="192" angle="0"/>
		<primitive type="box" size="[0.28,1.69]" position="[14.7128,-5.0524]" id="391" group="581" alpha="1" color="12462392" border="true" fix="529" z="193" angle="0" maskbits="8"/>
		<primitive type="box" fix="529" size="[0.28,0.3225]" position="[14.7147,-5.7362]" id="392" group="582" alpha="1" color="12462392" border="true" z="194" nocollision="true" angle="0" maskbits="6"/>
		<primitive type="box" size="[0.3,1.25]" restitution="0.28" friction="0.1" id="393" position="[16.2942,-8.3399]" group="583" alpha="1" color="5197647" border="true" fix="0" z="197" angle="0"/>
		<primitive type="box" size="[0.3,1.25]" restitution="0.28" friction="0.1" id="394" position="[16.6122,-9.1307]" group="584" alpha="1" color="5197647" border="true" fix="0" z="198" angle="0.6888"/>
		<primitive type="box" size="[0.3,1.25]" restitution="0.28" friction="0.1" id="395" position="[18.8346,-8.3399]" group="585" alpha="1" color="5197647" border="true" fix="0" z="199" angle="0"/>
		<primitive type="box" size="[0.3,1.25]" restitution="0.28" friction="0.1" id="396" position="[18.4959,-9.1521]" group="586" alpha="1" color="5197647" border="true" fix="0" z="200" angle="-0.7456"/>
		<primitive type="box" size="[1.3,0.29]" position="[17.5658,-9.5736]" id="397" group="587" alpha="1" color="5197647" border="true" fix="0" z="203" angle="0" maskbits="0"/>
		<primitive type="box" size="[2.3,0.3]" position="[19.878,-7.9031]" id="398" group="588" alpha="1" color="5197647" border="true" fix="0" z="207" angle="0"/>
		<primitive type="box" fix="0" size="[0.3,1.25]" restitution="0.28" friction="0.1" position="[16.2873,-8.3342]" id="399" group="589" alpha="0.395" color="15566916" border="true" visible="false" z="218" angle="0" maskbits="8"/>
		<primitive type="box" fix="0" size="[0.3,1.25]" restitution="0.28" friction="0.1" position="[16.6052,-9.125]" id="400" group="590" alpha="0.395" color="15566916" border="true" visible="false" z="219" angle="0.6888" maskbits="8"/>
		<primitive type="box" fix="0" size="[0.3,1.25]" restitution="0.28" friction="0.1" position="[18.8277,-8.3342]" id="401" group="591" alpha="0.395" color="15566916" border="true" visible="false" z="220" angle="0" maskbits="8"/>
		<primitive type="box" fix="0" size="[0.3,1.25]" restitution="0.28" friction="0.1" position="[18.489,-9.1464]" id="402" group="592" alpha="0.395" color="15566916" border="true" visible="false" z="221" angle="-0.7456" maskbits="8"/>
		<primitive type="box" fix="0" size="[10.2427,7.3]" position="[17.8254,-21.2535]" id="403" group="593" alpha="1" color="16777215" border="true" visible="false" z="222" angle="0" maskbits="3"/>
		<primitive type="box" fix="407" size="[0.3262,0.3768]" position="[3.3245,-10.4989]" id="404" group="594" alpha="1" color="13542687" border="true" z="224" nocollision="true" angle="0" maskbits="8"/>
		<joint type="hinge" target1="0" group="595" offset1="[6.8612,-10.59]" offset0="[0,0]" size="0.7892" z="22" alpha="1" color="16491386" target0="297"/>
		<joint type="hinge" target1="0" group="596" offset1="[-0.0964,9.9165]" offset0="[0,0]" size="0.9064" z="24" alpha="1" color="15766441" target0="276"/>
		<joint type="hinge" target1="0" group="597" motorTorque="1.79769313486231e+308" offset1="[-12.3978,-3.2088]" offset0="[0,0]" size="0.3765" z="30" motorSpeed="62.8319" alpha="1" color="4848363" target0="303"/>
		<joint type="hinge" target1="296" group="598" offset1="[-1.0733,-0.0038]" offset0="[0,0]" size="0.0941" z="32" alpha="1" color="5633677" target0="304"/>
		<joint type="hinge" target1="296" group="599" offset1="[1.0756,-0.0038]" offset0="[0,0]" size="0.0941" z="34" alpha="1" color="5633677" target0="305"/>
		<joint type="hinge" target1="0" group="612" offset1="[-17.9895,-1.5295]" offset0="[-0.0179,1.4233]" size="0.7921" z="72" alpha="1" color="4847461" target0="330"/>
		<joint type="hinge" target1="0" group="622" offset1="[5.2503,6.6034]" offset0="[5.2288,0.0049]" size="0.598" z="93" alpha="1" color="14718373" target0="341"/>
		<joint type="hinge" target1="276" group="627" offset1="[2.7266,2.7824]" offset0="[-0.0078,1.2384]" size="0.3435" z="104" alpha="1" color="10421254" target0="298"/>
		<joint type="hinge" target1="0" group="643" offset1="[-6.6817,9.4929]" offset0="[-1.0824,-0.1609]" size="0.1603" z="143" alpha="1" color="1373807" target0="368"/>
		<joint type="hinge" target1="0" group="648" offset1="[12.0719,-12.11]" offset0="[3.5817,-0.0064]" size="0.3672" z="148" alpha="1" color="5056852" target0="366"/>
		<joint type="hinge" target1="284" group="661" offset1="[-0.0156,0.7342]" offset0="[0,0]" size="0.1013" z="170" alpha="1" color="10027843" target0="379"/>
		<joint type="hinge" target1="291" group="663" offset1="[-0.3026,0.0095]" offset0="[0.0163,-0.7852]" size="0.1535" z="172" alpha="1" color="16163646" target0="284"/>
		<joint type="hinge" target1="0" group="669" offset1="[-4.7984,-3.6597]" offset0="[0.4516,0.0565]" size="0.5346" z="187" alpha="1" color="1582482" target0="281"/>
		<joint type="hinge" target1="0" group="674" offset1="[14.7077,-4.3398]" offset0="[-0.0016,0.7126]" size="0.307" z="196" alpha="1" color="12186424" target0="390"/>
		<list type="list" groups="[499]" name="tracked"/>
	</box2d>;
}
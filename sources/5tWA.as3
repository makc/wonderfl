/**
 * 難しいね
 */
package  {
	import com.actionsnippet.qbox.*;
	import com.actionsnippet.qbox.objects.*;
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.utils.*;
	import mx.utils.*;
	public class QboxWalker extends Sprite {
		private const BOX2D_SCALE:Number = 30;
		private const CAMERA_SCALE:Number = 1;
		private const SCENE_SCALE:Number = 0.35;
		private const QBOX_CODE:XML = <code>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</code>;
		private var sim:QuickBox2D;
		private var scene:SceneData;
		private var container:MovieClip;
		private var bg:Sprite;
		private var bgImage:BitmapData;
		private var bgMatrix:Matrix = new Matrix();
		//コンストラクタ
		public function QboxWalker() {
			Wonderfl.disable_capture();
			//Wonderfl.capture_delay(3);
			bgImage = new BitmapData(100, 20, false, 0xffEEEEEE);
			bgImage.fillRect(new Rectangle(0, 0, 50, 20), 0xFFE0E0E0);
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.addEventListener(Event.RESIZE, onResizeStage)
			bg = addChild(new Sprite()) as Sprite;
			container = addChild(new MovieClip()) as MovieClip;
			container.scaleX = container.scaleY = CAMERA_SCALE;
			refreshBackground()
			decode(QBOX_CODE);
		}
		//ステージサイズ変更時
		private function onResizeStage(e:Event):void {
			refreshBackground();
		}
		//背景パターン塗り直し
		private function refreshBackground():void {
			bgMatrix.tx = container.x;
			bgMatrix.ty = container.y;
			bg.graphics.clear();
			bg.graphics.beginBitmapFill(bgImage, bgMatrix, true, false);
			bg.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
		}
		//コードをBase64デコードしてシーンを生成する
		private function decode(code:String):void {
			var base64:Base64Decoder = new Base64Decoder();
			base64.decode(code);
			var ba:ByteArray = base64.toByteArray();
			ba.uncompress();
			var qbox:QboxModeler = new QboxModeler();
			sim = new QuickBox2D(container);
			scene = qbox.createByXML(new XML(ba.toString()), sim, SCENE_SCALE);
			setCameraPosition(0, 0);
			sim.mouseDrag();
			sim.start();
			addEventListener(Event.ENTER_FRAME, onSimulate);
		}
		//カメラ位置設定
		private function setCameraPosition(x:Number, y:Number):void {
			container.x = stage.stageWidth / 2 - x * BOX2D_SCALE * CAMERA_SCALE;
			container.y = stage.stageHeight / 2 - y * BOX2D_SCALE * CAMERA_SCALE;
			refreshBackground();
		}
		//シミュレーション中
		private function onSimulate(e:Event):void {
			//カメラで追跡するオブジェクトがあれば追う
			if (scene.trackingList.length) {
				var xx:Number = 0;
				var yy:Number = 0;
				for each(var qo:QuickObject in scene.trackingList) {
					var px:Number = 0;
					var py:Number = 0;
					if (scene.group[qo]) {
						var rp:Point = Coordinate.rotatePoint(new Point(qo.x, qo.y), scene.group[qo].angle);
						px = scene.group[qo].x + rp.x;
						py = scene.group[qo].y + rp.y;
					} else {
						px = qo.x;
						py = qo.y;
					}
					if (isNaN(px) || isNaN(py)) {
						scene.trackingList.splice(scene.trackingList.indexOf(qo), 1);
					} else {
						xx += px;
						yy += py;
					}
				}
				xx /= scene.trackingList.length;
				yy /= scene.trackingList.length;
				if (scene.trackingList.length) {
					container.x += ((stage.stageWidth / 2 - xx * BOX2D_SCALE * CAMERA_SCALE) - container.x) * 0.2;
					container.y += ((stage.stageHeight / 2 - yy * BOX2D_SCALE * CAMERA_SCALE) - container.y) * 0.2;
					refreshBackground();
				}
			}
			//角度が大きすぎると描画できなくなるので-360～360°に収める
			for each(var qbody:QuickObject in scene.bodyList) {
				if (!qbody.body.IsStatic() && Math.abs(qbody.angle) > Math.PI * 2) qbody.angle = qbody.angle % (Math.PI * 2);
			}
		}
	}
}
import Box2D.Collision.Shapes.*;
import com.actionsnippet.qbox.*;
import com.actionsnippet.qbox.objects.*;
import flash.events.*;
import flash.geom.*;
import flash.utils.*;
class QboxModeler {
	private var primitives:Array;
	public function QboxModeler() {
	}
	/**
	 * XMLからQuickBoxシーンを生成
	 */
	public function createByXML(xml:XML, sim:QuickBox2D, scale:Number = 1):SceneData {
		var scene:SceneData = new SceneData();
		var S:Number = scale;
		var joints:Array = new Array();
		var groups:Array = new Array();
		var unit:Object;
		primitives = new Array();
		for each(var node:XML in xml.children()) {
			unit = { density:2, fricyion:0.5, restitution:0.5, strength:0.25, damping:0.1, density:2, motorSpeed:15, reverse:false, motorTorque:100 };
			for each(var atr:XML in node.attributes()) unit[String(atr.name())] = XMLtoVALUE(atr.toString());
			if(node.name() == "primitive") primitives.push(unit);
			if(node.name() == "joint") joints.push(unit);
			if(node.name() == "list") groups.push(unit);
		}
		primitives.sortOn("z", Array.NUMERIC);
		var primitiveOffset:Dictionary = new Dictionary();
		var bg:QuickObject = sim.addCircle( { x:0, y:0, radius:0.1, density:0, maskBits:0, categoryBits:0, lineAlpha:0, fillAlpha:0 } );
		primitiveOffset[bg] = new Point();
		var fixList:Object = new Object();
		for each(unit in primitives) {
			var unitOffset:Point = new Point();
			var param:Object = {
				lineAlpha: int(unit.border),
				fillColor: unit.color,
				fillAlpha: unit.alpha,
				x: unit.position[0] * S,
				y: -unit.position[1] * S,
				angle: -unit.angle,
				friction: unit.friction,
				restitution: unit.restitution,
				maskBits:unit.maskbits,
				categoryBits:unit.maskbits,
				density: unit.density,
				isBullet: false
			}
			if (unit.type == "wall") {
				var unitPos:Point = new Point(unit.position[0] * S, -unit.position[1] * S);
				var adjust:Point = adjustPlanePos(unitPos.x, unitPos.y, unit.angle + Math.PI / 2).subtract(unitPos);
				unitOffset = new Point(Math.cos(unit.angle) * -15 * S, Math.sin(unit.angle) * 15 * S).add(adjust);
				param.x = unitPos.x + unitOffset.x,
				param.y = unitPos.y + unitOffset.y,
				param.width = 30 * S;
				param.height = 300 * S;
				param.density = 0;
				unit.qbox = sim.addBox(param);
			}
			if (unit.type == "box") {
				param.width = unit.size[0] * S;
				param.height = unit.size[1] * S;
				unit.qbox = sim.addBox(param);
			}
			if (unit.type == "circle") {
				param.radius = unit.radius * S;
				unit.qbox = sim.addCircle(param);
			}
			primitiveOffset[unit.qbox] = unitOffset;
			scene.bodyList.push(unit.qbox);
			if (unit.fix != null) {
				if (fixList["_" + unit.fix] == null) fixList["_" + unit.fix] = [unit.qbox];
				else fixList["_" + unit.fix].push(unit.qbox);
			}
		}
		for (var k:String in fixList) {
			if (k == "_0") {
				for each(var qo:QuickObject in fixList[k]) qo.body.SetMass(new b2MassData());
			} else {
				var o:QuickObject;
				var xy:Point = new Point();
				for each(o in fixList[k]) xy.offset(o.x, o.y);
				var center:Point = new Point(xy.x / fixList[k].length, xy.y / fixList[k].length);
				for each(o in fixList[k]) o.setLoc(o.x - center.x, o.y - center.y);
				var group:GroupObject = sim.addGroup( { objects:fixList[k], x:center.x, y:center.y } ) as GroupObject;
				for each(o in fixList[k]) scene.group[o] = group;
			}
		}
		for each(unit in groups) {
			if (unit.name == "tracked") {
				for each(var id:Number in unit.groups) {
					var obj:QuickObject = getObjectByGroup(id);
					if(obj) scene.trackingList.push(obj);
				}
			}
		}
		for each(unit in joints) {
			var prim0:QuickObject = (!unit.target0)? bg : getObjectByID(unit.target0);
			var prim1:QuickObject = (!unit.target1)? bg : getObjectByID(unit.target1);
			if (!prim0 || !prim1 || (!unit.target0 && !unit.target1) || (prim0.body.IsStatic() && prim1.body.IsStatic())) continue;
			var pos0:Point = new Point(prim0.x, prim0.y).add(Coordinate.rotatePoint(new Point(unit.offset0[0] * S, -unit.offset0[1] * S), prim0.angle)).subtract(primitiveOffset[prim0]);
			var pos1:Point = new Point(prim1.x, prim1.y).add(Coordinate.rotatePoint(new Point(unit.offset1[0] * S, -unit.offset1[1] * S), prim1.angle)).subtract(primitiveOffset[prim1]);
			if (scene.group[prim0]) pos0.offset(scene.group[prim0].x, scene.group[prim0].y);
			if (scene.group[prim1]) pos1.offset(scene.group[prim1].x, scene.group[prim1].y);
			var pos:Point = Point.interpolate(pos0, pos1, 0.5);
			var body0:* = (scene.group[prim0])? scene.group[prim0].body : prim0.body;
			var body1:* = (scene.group[prim1])? scene.group[prim1].body : prim1.body;
			if (unit.type == "spring")
				unit.qbox = sim.addJoint( {
					type: "distance",
					lineAlpha: 1,
					a: body0,
					b: body1,
					x1: pos0.x,
					y1: pos0.y,
					x2: pos1.x,
					y2: pos1.y,
					length: unit.length * S,
					collideConnected: true,
					dampingRatio: unit.damping,
					frequencyHz: unit.strength * 100
				} );
			if (unit.type == "nut"){
				unit.qbox = sim.addJoint( {
					type: "revolute",
					lineAlpha: 0,
					enableMotor: unit.motor,
					maxMotorTorque: unit.motorTorque,
					motorSpeed: unit.motorSpeed * (int(unit.reverse)*2 - 1),
					collideConnected: false,
					a: body0,
					b: body1,
					x1: pos.x,
					y1: pos.y
				});
			}
			scene.jointList.push(unit.qbox);
		}
		return scene;
	}
	private function XMLtoVALUE(data:String):* {
		if (data == "true" || data == "false") return (data == "true");
		if (data.substr(0, 1) == "[" && data.substr( -1) == "]") {
			var values:Array = data.substr(1, data.length - 2).split(",");
			for (var i:int = 0; i < values.length; i++) values[i] = Number(values[i]);
			return values;
		}
		if (isNaN(Number(data))) return String(data);
		return Number(data);
	}
	private function adjustPlanePos(x:Number, y:Number, angle:Number):Point {
		return Line.crossVertical(new Point(x, y), new Point(x + Math.cos(angle) * 100, y - Math.sin(angle) * 100), new Point(0, 0));
	}
	private function getObjectByGroup(groupID:int):QuickObject {
		for each(var unit:Object in primitives) if (groupID == unit.group) return unit.qbox;
		return null;
	}
	private function getObjectByID(id:int):QuickObject {
		for each(var unit:Object in primitives) if (id == unit.id) return unit.qbox;
		return null;
	}
}
/**
 * シーンデータ
 */
class SceneData {
	public var group:Dictionary = new Dictionary();
	public var trackingList:Array = new Array();
	public var bodyList:Array = new Array();
	public var jointList:Array = new Array();
	public function SceneData() {
	}
}
class Line {
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
		return new Point((-c2 - b2 * c1) / z, (a2 * c1 - a1 * c2) / z);
	}	
}
class Coordinate {
	/**
	 * 回転後の座標を取得
	 */
	static public function rotatePoint(p:Point, rad:Number):Point {
		var x:Number = p.x * Math.cos(rad) - p.y * Math.sin(rad);
		var y:Number = p.x * Math.sin(rad) + p.y * Math.cos(rad);
		return new Point(x, y);
	}
}
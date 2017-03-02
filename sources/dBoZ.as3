/**
 * よたよた
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
		private const QBOX_CODE:XML = <code>eNrFm9tyG8cRhu/zFCxek+vp83SVlco7JHcuXdASZDOmRIWkEttPn55Z7A4Ou8AuAlVYJRVIAuD39/T03z1D/vjz8+/48a9/ubn58evL4+fHt8d/b27e/vi6eXf7n4enp9ubX16ev319dwvp9ubr82t8//nLu9ufIKU76TQzMfjmHvj97c3Dl1+e4mX31AGDOMrtzafH39/dxiv/rP9/fnj97efHt9d4N7Tbm8eP5UG87unrrw/x8Pbmw/PT80t96s/PLx838fDt5dvm9ocFeLCHd49dZgRLle0uaHf4oBNL5sp7fDDNRxfzRWBvb14f/9yUcEHHajlJBC255oQYQB83X4L4j3jDjlL9OFBh2KGLkt/dK3SZNCO934Jx095iGG80ifnp4el1s5ULVvXiGJDUJUjEWUgXhZr2IUsq7IQ37UWVpqMq/8+o5hxRdeASVexSQjYdoqpNJl8SVb44qnIqge/3Mng6gWU61HadUHcJyS3lOy2PKFTthtoO8pa6nA1YI8LWYaKgHSKcm2RdFWHEKlPbRk6dJUXGhFdXkL1zEXOpCuJ1QjYo8KbA1ingqsD2FAChYr66gKDm5GVv3KtHkrNn3ArA1ATkpQKCO+8mmOyKQMIsHom+1akr5NgoB06tB3USO1mhygFTojzIgSbHV8jxeTkMSSj5ICd/jw1izlgWhzpCARnE4CimLNNiMcWex8JjgS9Z5XvsiozA2Sq3JG+LQI0b1nDDDrd6LGuE/YLkwZN7QTvPrMQVOx5y2wvNRhHXcO/ZpxFaRBy+R9onyIKFnDsQ1jSSSyOnNeS0Sy65OGHUsWnyD48vH542J/LYuqSk2FtpjnbQh0IfReDm5eHj47fX8oOc4llRhRozr2AuS9P2akv14pKBT6AX8nvEVxWcamZEkSTjgd9O88safprnDwuzfGn8a2kXrJmNXeSg0dAgRtU6ya9r+HmaP14ZpR/ZL41/jsYNYwGg8jukSKCB30/z2xp+meXn7Il5iWFhdF3mnv0uHELQM6CcKvESzWlGxypNGFSGLpOaAeMaA6Y0k0apA00pGgm6vg6PJju7bXVE4Uo8dELUnBfXOC/BCR1lPRY1dCt1aO7ADan3XBQigEFHM11aY7qEc2kVRYW9NBErdGjTgacsgTuM1d6aGUMY8rDlqZkwrTFhonkdBMmZl+goixcqxDisjSDkE57ZH7Er2Kq1ZU4EY161bU5rTJln1yO694jrotbiWAbmM9sjdkcuo04pZgl9cBBqDk1rHJpnl0PQPFrfC2XQmd2RHVMx8nh+dCU8FGJqMzGtMW2eNQ2MDiyZ5jUyaJGMsjkI+6TSToBTHlfDCu7nzw9f4pO//fP58ctb07XGzHnWTFCNNNuS5SnFCNAhx6aPLRw5VqvqweFPvJl5v89zYh2GBGozNK2xcZldkQQeRSUqyWXo/v7ohEVjHMwVPXp65XEV2vBMaxxcZoOeEEqBQrwOutV5LKtVuwtLER9sgptt0xrbFp1nT6X5cLtS2L2LgUKs76bQo7McpgVuVk1rrFrsBLsHOS+ZMjWIo4cIz4LYz2HCyRYd1MU3DEPo3b2U8xiN9nDQ0yyb0yUHdaorTuoO1gF823ZArth7YqDz/uNAC3QYNc/6Ngoghq5xbZpt8xrbVp9dm5SyRZDR4HJFB/QZojHTfk6KiVTGXdHMmteYtaXL6Yex4mXz+vb49q2nLAfPL48f+k9wCydHbp2j9eNcj5GExaVsojZnqFX9O9l15gJg6nxPdu8aSCXm/f9diR61TzFdKFhVErs+bPKMEl6hpD9rNf0eSo49G0SipN3dW2yeGOf1nBJZoST3Sux7KMlHTVQKx0CrSgxLc35Gia5Qor2SvFzJfidltSwh35UjeZEw/INdztEyxSxPfU4lSZCHkZWbb7MtYi4HxjtHTdcnjK2czAdDkGbOnBcD8lnAvUsa3i/qFCYbtaTcz5RmLWaMVKriYd6cvLXJ09c2AhMaNKozJz1U0oPXjnYL/eVb9LZvDy+/bN5g78qlROn506fX+vWf7kutjbErvDkqYihAk1wPkPrnpJ3nWGR29BXYRbvCVE8h+2WLVcspZ9M+PU9cm/VAqVaXs8wt30ooJpgjFr5lNpdJZnEuJ5NbZpJZZlnATGeZd+5VBKeY44fCGGecjjO7SEPOs8i6AJnPI7e2UGgKOTp3G8Icrj8d5sjalhq1RZtmtgXMcj41WsNRBpodZuoghr9ympg6TpxJ4ZiYhAlAOESxZc9oO7zR7McsT32LeOJybFUqt/m5TDFHvEYy8KJN86Zy5bLlrSVmmtevksa78dVdXukg5kQKlBh1DSRpHY2OcGMMjlLR45rKHO6J+601KbwbXjvGRaUBN9CmcXOjnU2GE7dalyZvuU99fnt++cfzy7++bcrZY3y0H4/I0WXrfvXjLgsQQTRLqYvkjVZ9v/aVOx31+LL6XRWYNBPUVag/bHvjXyXp9mt//7rZlNm8wwUaddWK+EUaw5EsF7sJjSHSbcqUyrxIiTwW7m77eYyK0t+QHWm1S7TamvXUtF4rxeQb66lcpUb9jG7uaD3LRwhVFqnP67+AwirJp7TmS7TmNetaVFymFSmPWo1hSmtZ1Xg/a1odALVOnEda/RKtft4Yd7QeenkxkKjUdS045ng+SE6IKTo6JOjTsoyx0T35+6no/HnyTHUEpnQe2BowTQInHYD7AeuIOP6NxGLzwAu6JYLzwK0rVZ4C5pTHCEcdn4xxspE4dgTNIi/olui8k2NrSlWmkCXDiByfTAbZfUCOcmXzyAuaJVrQk7ZZU/WwwYvuo1yfl4unaEcl+mXbQ4byi5xGufQn8eSYEnw+K/J10ridhalN8WZiGXj7G6NDXsYR1+ov9k3z+nWyeKf+5yne2Eo+8ALlqfh6HoFB8xwwp+vkcLuUKueHE8BoNgIzTwU4+QBMPIsL18nfVoftcHbF8BIKzrLlFB3SQZGo1xpAhoR35Zc7kHPa7Uap3PyXu//Ku6RE8JoybDDJ25fhykuTuEQ64KLO4i4pD7KmCBtO4UpfhCtuRpkCFhAa42uzwEvqg64pwUZTwGregB0mgNFJxwjvHWTsAy8pELbm8MX2bC5gcvJYY66eAZ48IR9PKOBRFxC1DNiuxgp5DlnSVXJ45+zFZALZU6YRWdmmkWMwGZBlzzb2keE6edyOXkynkBnyiHxQhQdirW34+SDjdRK5nbyYHRNLsowjcZpKi0gXYh+JEWaJ6SqZvFsr8j5x9BBMIjUrYvZ3UfA9Yoo5LokL9JNaDKSZ+7PbgTjqiFL5hZlKvKRY5FXFwieI+1GkB85yDKwxi4zAqi6zvEtqha+JcD46qKXICIB6SWdR3RAOZuItMdpAbC6Is8i6oFZwWhPiDFPI6LUfq8jpYO7YZoVhywoS51nkBbWCYU1LkQ89DyCp5NrfGGpUuoODZS4XPKB9jAm9PHc+xHidLG4tRaYpXqsNZOVV5UlgbMS6N4ruA9N10ngnwAeWB5bLiU1fKLhc3xy08Ftg6XviAqxhN/Mh5utk8U6IZYpYB+CsPgmsImOEzXG2sqlcJ4d3tt1RLbaImdYUjnZT8uGpZ+w6ju9sj5LKU8T3zKOc6Icd9reNS/YcreI9nDosx+RpfRFw8hgizI6Iy1952RYZo9EXFpxDXrDtmNdksR/fmnH5tUspVzUxKsUuNKt/OLFX22IhvD+ggFLlks4B03VivAMM+zkRnTsm0H5sixlaGPGQVrycu931vQVFFZQ8x8srAvz0+DrglodbxNcyTOJd/bPRLw+fN+VE7+HDb5uP5VU//tD/Tep/AZ5a8gg=</code>;
		private var sim:QuickBox2D;
		private var scene:SceneData;
		private var container:MovieClip;
		private var bg:Sprite;
		private var bgImage:BitmapData;
		private var bgMatrix:Matrix = new Matrix();
		//コンストラクタ
		public function QboxWalker() {
			Wonderfl.disable_capture();
			//Wonderfl.capture_delay(10);
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
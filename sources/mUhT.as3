/**
 * シャドウボリューム法を参考に無理やり影生成をしてみました。
 * 色々と間違ってる気がします。もの凄く重い。
 */
package  {
	import com.bit101.components.*;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import org.papervision3d.cameras.Camera3D;
	import org.papervision3d.core.clipping.FrustumClipping;
	import org.papervision3d.core.geom.renderables.Triangle3D;
	import org.papervision3d.core.geom.renderables.Vertex3D;
	import org.papervision3d.core.geom.TriangleMesh3D;
	import org.papervision3d.core.math.Number3D;
	import org.papervision3d.materials.ColorMaterial;
	import org.papervision3d.materials.utils.MaterialsList;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.primitives.Cube;
	import org.papervision3d.objects.primitives.Plane;
	import org.papervision3d.objects.primitives.Sphere;
	import org.papervision3d.Papervision3D;
	import org.papervision3d.render.BasicRenderEngine;
	import org.papervision3d.render.QuadrantRenderEngine;
	import org.papervision3d.scenes.Scene3D;
	import org.papervision3d.view.BitmapViewport3D;
	import org.papervision3d.view.Viewport3D;
	public class Shadow extends Sprite {
		private var scene:Scene3D;
		private var render:BasicRenderEngine;
		private var camera:Camera3D;
		private var viewport:Viewport3D;
		private var cameraTarget:DisplayObject3D;
		private var light:Sphere;
		private var plane:Plane;
		private var kaidan:Plane;
		private var wall:Plane;
		private var floor:Plane;
		private var points:Array;
		private var indexes:Array;
		private var bg:Sprite;
		private var shadowScene:Scene3D;
		private var shadowViewport:BitmapViewport3D
		private var shadowRender:QuadrantRenderEngine;
		private var shadowModel:Cube;
		private var shadowMap:BitmapData;
		private var fillMaterial:ColorMaterial;
		private var maskMaterial:ColorMaterial;
		private var topColor:ColorMaterial;
		private var sideColor:ColorMaterial;
		private var shadowClones:Dictionary;
		private var totalShadow:Sprite;
		private var view1:Bitmap;
		private var view2:Bitmap;
		private var sceneDragger:SceneDragger;
		private var lightDragger:LightDragger;
		private var shadowBitmap:Bitmap;
		//コンストラクタ
		public function Shadow() {
			Style.LABEL_TEXT = 0xFFFFFF;
			var size:Array = [100, 450];
			bg = new Sprite();
			bg.graphics.beginFill(0x333333);
			bg.graphics.drawRect(0, 0, 465, 465);
			points = [new Number3D(size[0]/2, -size[1]/2, -600), new Number3D(-size[0]/2, -size[1]/2, -600), new Number3D(size[0]/2, size[1]/4, -600), new Number3D(-size[0]/2, size[1]/2, -600)];
			indexes = [0,1,2,3,6,7,4,5];
			scene = new Scene3D();
			render = new BasicRenderEngine();
			render.clipping = new FrustumClipping(FrustumClipping.NEAR);
			viewport = new Viewport3D(465, 465, false);
			camera = new Camera3D();
			cameraTarget = scene.addChild(new DisplayObject3D());
			cameraTarget.position = new Number3D(0, 0, 0);
			//color
			fillMaterial = new ColorMaterial(0x000000);
			maskMaterial = new ColorMaterial(0xFFFFFF);
			topColor = new ColorMaterial(0x969696);
			sideColor = new ColorMaterial(0xD5D5D5);
			//model
			createModels();
			//shadow
			shadowScene = new Scene3D();
			shadowRender = new QuadrantRenderEngine(QuadrantRenderEngine.ALL_FILTERS);
			shadowViewport = new BitmapViewport3D(465, 465, false, false, 0x000000);
			shadowModel = new Cube(new MaterialsList( { all:maskMaterial } ), 100, 100, 100, 1, 1, 1);
			scene.addChild(plane);
			scene.addChild(wall);
			scene.addChild(floor);
			scene.addChild(kaidan);
			scene.addChild(light);
			shadowScene.addChild(shadowModel);
			var clones:Array = [kaidan, plane, wall, floor];
			shadowClones = new Dictionary();
			for each(var model:DisplayObject3D in clones) {
				var tm:TriangleMesh3D = shadowScene.addChild(model.clone()) as TriangleMesh3D;
				for each(var tri:Triangle3D in tm.geometry.faces) tri.material = fillMaterial;
				shadowClones[model] = tm;
			}
			shadowMap = new BitmapData(465, 465, false, 0x00000000);
			totalShadow = new Sprite();
			view1 = totalShadow.addChild(new Bitmap(new BitmapData(465, 465, true))) as Bitmap;
			view2 = totalShadow.addChild(new Bitmap(new BitmapData(465, 465, false))) as Bitmap;
			view2.blendMode = BlendMode.SUBTRACT;
			shadowBitmap = new Bitmap(shadowMap);
			shadowBitmap.alpha = 0.2;
			shadowBitmap.filters = [new BlurFilter(5, 5, 1)];
			shadowBitmap.blendMode = BlendMode.SUBTRACT;
			sceneDragger = new SceneDragger(bg, -120, 15);
			sceneDragger.addEventListener(Event.CHANGE, onMoveCamera);
			lightDragger = new LightDragger();
			lightDragger.addEventListener(Event.CHANGE, onChangeLight);
			viewport.mouseChildren = false;
			viewport.mouseEnabled = false;
			addChild(bg);
			addChild(viewport);
			addChild(shadowBitmap);
			addChild(lightDragger);
			createButtons();
			updateLight();
			refresh();
		}
		private function createButtons():void {
			var vox:VBox = new VBox(this, 7, 115);
			new RadioButton(vox, 0, 0, "NORMAL", true, onSelectMode).tag = 0;
			new RadioButton(vox, 0, 0, "VIEW1", false, onSelectMode).tag = 1;
			new RadioButton(vox, 0, 0, "VIEW2", false, onSelectMode).tag = 2;
			new Label(this, 3, 465-20, "DRAG TO ROTATE CAMERA");
		}
		private function onSelectMode(e:MouseEvent):void{
			switch(RadioButton(e.currentTarget).tag) {
				case 0:
					view1.visible = true;
					view2.visible = true;
					view2.blendMode = BlendMode.SUBTRACT;
					shadowBitmap.filters = [new BlurFilter(5, 5, 1)];
					shadowBitmap.alpha = 0.2;
					break;
				case 1:
					view1.visible = true;
					view2.visible = false;
					shadowBitmap.alpha = 0.4;
					shadowBitmap.filters = [];
					break;
				case 2:
					view1.visible = false;
					view2.visible = true;
					view2.blendMode = BlendMode.NORMAL;
					shadowBitmap.filters = [];
					shadowBitmap.alpha = 0.4;
					break;
			}
			refresh();
		}
		private function createModels():void {
			var i:int;
			var slide:Number = 500;
			var stepDepth:Number = 150;
			var stepHeight:Number = 60;
			var stepNum:Number = 5;
			var stepWidth:Number = 1000;
			var planeColor:ColorMaterial = new ColorMaterial(0xEEEEEE);
			planeColor.doubleSided = true;
			plane = new Plane(planeColor, 100, 500, 1, 1);
			for (i = 0; i < plane.geometry.vertices.length; i++) {
				plane.geometry.vertices[i].x = points[i].x;
				plane.geometry.vertices[i].y = points[i].y;
				plane.geometry.vertices[i].z = points[i].z - 5;
			}
			kaidan = new Plane(null, 100, stepWidth, stepNum*2, 1);
			kaidan.rotationY = kaidan.rotationX = 90;
			kaidan.z = slide;
			for (i = 0; i < kaidan.geometry.faces.length; i++)
				kaidan.geometry.faces[i].material = (int(i/2)%2)? sideColor : topColor;
			for (i = 0; i < kaidan.geometry.vertices.length; i++) {
				var v:Vertex3D = kaidan.geometry.vertices[i];
				v.z = int(i / 4) * stepHeight;
				v.x = int((i+2) / 4) * stepDepth;
			}
			floor = new Plane(topColor, stepWidth, 500, 1, 1);
			floor.z = -stepDepth * stepNum + slide - 500/2;
			floor.y = -stepHeight * stepNum;
			floor.rotationX = 90;
			wall = new Plane(sideColor, stepWidth, 1000, 1, 1);
			wall.y = 1000/2;
			wall.z = slide;
			light = new Sphere(new ColorMaterial(0xFFAA00, 0.5), 50, 8, 4);
			light.position = new Number3D(0, 300, -1000);
		}
		private function onChangeLight(e:Event):void {
			updateLight();
			refresh();
		}
		private function onMoveCamera(e:Event):void {
			refresh();
		}
		private function updateLight():void {
			var pos:Point = lightDragger.getPosition();
			light.x = pos.x * 500;
			light.y = pos.y * 500 - 200;
			for (var i:int = 0; i < 4; i++) {
				shadowModel.geometry.vertices[indexes[i]].x = points[i].x;
				shadowModel.geometry.vertices[indexes[i]].y = points[i].y;
				shadowModel.geometry.vertices[indexes[i]].z = points[i].z;
				var stretch:Number3D = Number3D.sub(points[i], light.position);
				stretch.multiplyEq(5);
				stretch.plusEq(light.position);
				shadowModel.geometry.vertices[indexes[i + 4]].x = stretch.x;
				shadowModel.geometry.vertices[indexes[i + 4]].y = stretch.y;
				shadowModel.geometry.vertices[indexes[i + 4]].z = stretch.z;
			}
		}
		private function refresh():void {
			camera.position = sceneDragger.getPosition(2000);
			camera.lookAt(cameraTarget);
			for(var m:* in shadowClones) m.transform = shadowClones[m].transform;
			render.renderScene(scene, camera, viewport);
			drawShadow();
		}
		private function drawShadow():void {
			shadowRender.renderScene(shadowScene, camera, shadowViewport);
			view1.bitmapData.copyPixels(shadowViewport.bitmapData, shadowViewport.bitmapData.rect, new Point());
			shadowModel.geometry.flipFaces();
			shadowRender.renderScene(shadowScene, camera, shadowViewport);
			view2.bitmapData.copyPixels(shadowViewport.bitmapData, shadowViewport.bitmapData.rect, new Point());
			shadowMap.draw(totalShadow);
			shadowModel.geometry.flipFaces();
		}
	}
}
import com.bit101.components.Label;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import org.papervision3d.core.math.Number3D;
/**
 * ライト位置をマウスで動かす
 */
class LightDragger extends Sprite {
	private var position:Point;
	private var circle:Sprite;
	private var grid:BitmapData;
	public function LightDragger() {
		position = new Point(50, 70);
		grid = new BitmapData(10, 10, false, 0xFFA0A0A0);
		grid.fillRect(new Rectangle(0, 0, 10, 1), 0xFF888888);
		grid.fillRect(new Rectangle(0, 0, 1, 10), 0xFF888888);
		graphics.clear();
		graphics.beginBitmapFill(grid);
		graphics.drawRect(0, 0, 100, 100);
		circle = new Sprite();
		circle.graphics.beginFill(0x000000);
		circle.graphics.drawCircle(0, 0, 5);
		circle.graphics.beginFill(0xFFFFFF);
		circle.graphics.drawCircle(0, 0, 4);
		circle.mouseChildren = false;
		circle.mouseEnabled = false;
		addChild(circle);
		draw(position.x, position.y);
		buttonMode = true;
		addEventListener(MouseEvent.MOUSE_DOWN, onMsDown);
		new Label(this, 3, 3, "LIGHT POSITION");
	}
	public function getPosition():Point {
		return new Point((position.x - 50) / 50, 1 - (position.y - 50) / 50);
	}
	private function onMsUp(e:MouseEvent):void {
		stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMsMove);
		stage.removeEventListener(MouseEvent.MOUSE_UP, onMsUp);
		draw();
	}
	private function onMsDown(e:MouseEvent):void {
		stage.addEventListener(MouseEvent.MOUSE_MOVE, onMsMove);
		stage.addEventListener(MouseEvent.MOUSE_UP, onMsUp);
		draw();
	}
	private function onMsMove(e:MouseEvent):void {
		draw();
	}
	private function draw(px:Number = NaN, py:Number = NaN):void {
		if (isNaN(px)) px = Math.max(0, Math.min(100, mouseX));
		if (isNaN(py)) py = Math.max(0, Math.min(100, mouseY));
		circle.x = px;
		circle.y = py;
		position.x = px;
		position.y = py;
		dispatchEvent(new Event(Event.CHANGE));
	}
}
/**
 * シーンをマウスでぐるぐる
 */
class SceneDragger extends EventDispatcher {
	private var _rotation:Number;
	private var _angle:Number;
	private var _sprite:Sprite;
	private var _saveRotation:Number;
	private var _saveAngle:Number;
	private var _saveMousePos:Point;
	public function SceneDragger(sprite:Sprite, rotation:Number = 0, angle:Number = 30) {
		_angle = angle;
		_rotation = rotation;
		_sprite = sprite;
		_sprite.addEventListener(MouseEvent.MOUSE_DOWN, onMsDown);
		_sprite.addEventListener(MouseEvent.MOUSE_UP, onMsUp);
	}
	private function onMsDown(e:MouseEvent):void {
		_sprite.addEventListener(MouseEvent.MOUSE_MOVE, onMsMove);
		_saveRotation = _rotation;
		_saveAngle = _angle;
		_saveMousePos = new Point(_sprite.mouseX, _sprite.mouseY);
	}
	private function onMsMove(e:MouseEvent):void {
		var dragOffset:Point = new Point(_sprite.mouseX, _sprite.mouseY).subtract(_saveMousePos);
		_rotation = _saveRotation - dragOffset.x * 0.5;
		_angle = Math.max(-89, Math.min(89, _saveAngle + dragOffset.y * 0.5));
		dispatchEvent(new Event(Event.CHANGE));
	}
	private function onMsUp(...rest):void {
		_sprite.removeEventListener(MouseEvent.MOUSE_MOVE, onMsMove);
		dispatchEvent(new Event(Event.CHANGE));
	}
	public function getPosition(distance:Number):Number3D {
		var per:Number = Math.cos(Math.PI / 180 * _angle);
		var px:Number = Math.cos(Math.PI / 180 * _rotation) * distance * per;
		var py:Number = Math.sin(Math.PI / 180 * _angle) * distance;
		var pz:Number = Math.sin(Math.PI / 180 * _rotation) * distance * per;
		return new Number3D(px, py, pz);
	}
}
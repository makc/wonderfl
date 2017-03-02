/**
 * レンズフレアのテスト
 */
package {
	import com.bit101.components.PushButton;
	import com.bit101.components.Style;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.utils.getTimer;
	import net.hires.debug.Stats;
	import org.papervision3d.core.geom.Lines3D;
	import org.papervision3d.core.geom.renderables.Triangle3D;
	import org.papervision3d.core.geom.renderables.Vertex3D;
	import org.papervision3d.core.geom.TriangleMesh3D;
	import org.papervision3d.core.math.Number3D;
	import org.papervision3d.materials.BitmapMaterial;
	import org.papervision3d.materials.ColorMaterial;
	import org.papervision3d.materials.special.LineMaterial;
	import org.papervision3d.materials.utils.MaterialsList;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.primitives.Cube;
	import org.papervision3d.objects.primitives.Plane;
	import org.papervision3d.Papervision3D;
	import org.papervision3d.view.BasicView;
	import org.papervision3d.view.BitmapViewport3D;
	
	[SWF(width = "465", height = "465", frameRate = "60", backgroundColor = "#000000")]
	public class Lensflare extends Sprite {
		private const RADIAN:Number = Math.PI / 180;
		private var _bgColor:uint = 0x4DA7FA;
		private var _horizonColor:uint = 0x9CC8F5;
		
		private var _sky:Sprite;
		private var _lensEfx:LensEffect;
		private var _view:BasicView;
		private var _cars:Vector.<Car> = new Vector.<Car>();
		private var _sun:DisplayObject3D;
		private var _cameraPos:Number3D = new Number3D();
		private var _cameraTarget:DisplayObject3D;
		private var _horizonTarget:DisplayObject3D;
		
		private var _cameraMode:Boolean = true;
		private var _isDrag:Boolean = false;
		private var _clickPosition:Point;
		private var _saveRotation:Number;
		private var _saveAngle:Number;
		private var _cameraRotation:Number = 120;
		private var _cameraAngle:Number = 1;
		private var _cameraRadius:Number = 370;
		
		public function Lensflare() {
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			stage.frameRate = 60;
			stage.quality = StageQuality.LOW;
			Display.setSize(stage.stageWidth, stage.stageHeight);
			
			Papervision3D.PAPERLOGGER.unregisterLogger(Papervision3D.PAPERLOGGER.traceLogger);
			_view = new BasicView(Display.width, Display.height, true, false, "Free");
			_view.viewport = new BitmapViewport3D(Display.width, Display.height, false, true);
			
			//マウス操作用
			_clickPosition = new Point();
			_view.viewport.addEventListener(MouseEvent.MOUSE_DOWN, onMsDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMsUp);
			stage.addEventListener(Event.MOUSE_LEAVE, onMsUp);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMsMove);
			
			//背景
			_sky = new Sprite();
			_sky.addChild(Painter.createGradientRect(Display.width, Display.height, [_bgColor, _horizonColor], [1, 1], [], 90, 0, -Display.height));
			_sky.addChild(Painter.createGradientRect(Display.width, Display.height, [0x000000, 0x444444], [1, 1], [], 90));
			
			//スクリーン座標取得用の太陽
			_sun = _view.scene.addChild(new DisplayObject3D());
			_sun.position = new Number3D(20000, 10500, -20000);
			_sun.autoCalcScreenCoords = true;
			_horizonTarget = _view.scene.addChild(new DisplayObject3D());
			_horizonTarget.autoCalcScreenCoords = true;
			_cameraTarget = _view.scene.addChild(new DisplayObject3D());
			
			//街モデル生成
			_view.scene.addChild(createCity());
			
			//車配置
			for (var i:int = 0; i < 8; i++) {
				var car:Car = new Car(i * 60, !(i % 2));
				_cars.push(car);
				_view.scene.addChild(car);
			}
			
			//レンズフレア
			_lensEfx = new LensEffect();
			_lensEfx.init(stage);
			_lensEfx.x = Display.center.x;
			_lensEfx.y = Display.center.y;
			
			addChild(Painter.createGradientRect(Display.width, Display.height, [_bgColor], [1]));
			addChild(_sky);
			addChild(_view.viewport);
			addChild(_lensEfx);
			addChild(new Stats());
			Style.BUTTON_FACE = Style.BACKGROUND = 0;
			Style.LABEL_TEXT = 0xFFFFFF;
			new PushButton(this, 360, 5, "CAMERA: AUTO", onClickCamera);
			
			//レンダリング開始
			onEnter(null);
			addEventListener(Event.ENTER_FRAME, onEnter);
		}
		
		private function onClickCamera(e:MouseEvent):void{
			_cameraMode = !_cameraMode;
			PushButton(e.currentTarget).label = "CAMERA: " + ["DRAG", "AUTO"][int(_cameraMode)];
		}
		
		private function onMsDown(e:MouseEvent):void {
			_isDrag = true;
			_clickPosition = new Point(stage.mouseX, stage.mouseY);
			_saveAngle = _cameraAngle;
			_saveRotation = _cameraRotation;
		}
		
		private function onMsUp(...arg):void {
			_isDrag = false;
		}
		
		private function onMsMove(e:MouseEvent):void {
			if (!_isDrag || _cameraMode) return;
			_cameraRotation = _saveRotation - (stage.mouseX - _clickPosition.x) / 10;
			_cameraAngle = Math.max(1, Math.min(40, _saveAngle + (stage.mouseY - _clickPosition.y) / 10));
		}
		
		//毎フレーム処理
		private function onEnter(e:Event):void {
			var time:int = getTimer() + 88400;
			
			//車を動かす
			for each (var car:Car in _cars) car.update();
			
			//カメラ移動
			if (_cameraMode) {
				_cameraTarget.x = Math.cos(RADIAN * (time / 24)) * 100;
				_cameraTarget.z = Math.sin(RADIAN * (time / 28)) * 100;
				_cameraTarget.y = 100;
				_cameraPos.reset(Math.cos(RADIAN * (time / 40)) * 350, 15, Math.cos(RADIAN * (time / 50)) * 350);
			} else {
				_cameraTarget.x = 0;
				_cameraTarget.y = 100;
				_cameraTarget.z = 0;
				var perXZ:Number = Math.cos(RADIAN * _cameraAngle);
				_cameraPos.x = Math.cos(RADIAN * _cameraRotation) * _cameraRadius * perXZ;
				_cameraPos.z = Math.sin(RADIAN * _cameraRotation) * _cameraRadius * perXZ;
				_cameraPos.y = Math.sin(RADIAN * _cameraAngle) * _cameraRadius;
			}
			_view.camera.position = _cameraPos;
			_view.camera.lookAt(_cameraTarget);
			
			//地平線用オブジェクトをカメラの前方に移動
			var lookRadian:Number = Math.atan2(_cameraTarget.z - _view.camera.z, _cameraTarget.x - _view.camera.x);
			_horizonTarget.x = _view.camera.x + Math.cos(lookRadian) * 100000;
			_horizonTarget.z = _view.camera.z + Math.sin(lookRadian) * 100000;
			
			//レンダリング
			_view.singleRender();
			
			//地平線の高さに背景を合わせる
			_sky.y = _horizonTarget.screen.y + Display.center.y;
			
			var sunPos:Point = new Point(_sun.screen.x + Display.center.x, _sun.screen.y + Display.center.y);
			//太陽が遮蔽物にどのくらいの割合で隠れているかの割合を計算
			var blurArea:int = 3;
			var per1:Number = 0;
			for (var px:int = sunPos.x - blurArea; px <= sunPos.x + blurArea; px++) {
				for (var py:int = sunPos.y - blurArea; py <= sunPos.y + blurArea; py++) {
					per1 += 1 - (BitmapViewport3D(_view.viewport).bitmapData.getPixel32(px, py) >>> 24) / 0xFF;
				}
			}
			per1 /= (blurArea * 2 + 1) * (blurArea * 2 + 1);
			//太陽が画面中央にどれだけ近いかの割合を計算
			var per2:Number = Math.max(0, 1 - sunPos.subtract(Display.center).length / 600);
			var efxPower:Number = (_sun.screen.z <= 0 )? 0 : per1 * per2;
			_lensEfx.rotateFlash();
			_lensEfx.setSunPosition(_sun.screen.x, _sun.screen.y);
			_lensEfx.setPower(efxPower);
		}
		
		//ステージモデルを生成
		private function createCity():DisplayObject3D {
			var planeColor:ColorMaterial = new ColorMaterial(0x000000);
			planeColor.doubleSided = true;
			var sideColor:ColorMaterial = new ColorMaterial(0x000000);
			var gradientBmp:BitmapData = new BitmapData(50, 50, true, 0x00000000);
			gradientBmp.draw(Painter.createGradientRect(50, 50, [0x000000, 0x000000], [1, 0], [0.5, 1], -90));
			var gradientColor:BitmapMaterial = new BitmapMaterial(gradientBmp);
			gradientColor.doubleSided = true;
			var d:DisplayObject3D = new DisplayObject3D();
			
			var roadWidth:Number = 30;
			var poleWidth:Number = 5;
			//螺旋状の道路
			var roadMesh:TriangleMesh3D = d.addChild(new TriangleMesh3D(planeColor, [], [])) as TriangleMesh3D;
			var lines:Lines3D = d.addChild(new Lines3D(new LineMaterial(0x000000, 1))) as Lines3D;
			var i:int;
			for (i = 0; i <= 720; i += 20) {
				var radius:Number = 80 + i / 3;
				var h:Number = i / 6;
				var v0:Vertex3D = new Vertex3D(Math.cos(RADIAN * i) * radius, h, Math.sin(RADIAN * i) * radius);
				var v1:Vertex3D = new Vertex3D(Math.cos(RADIAN * i) * (radius + roadWidth), h, Math.sin(RADIAN * i) * (radius + roadWidth));
				roadMesh.geometry.vertices.push(v0, v1);
				if (i) {
					var pole1:Plane = d.addChild(new Plane(planeColor, poleWidth, h, 1, 1)) as Plane;
					var pole2:Plane = d.addChild(new Plane(planeColor, poleWidth, h, 1, 1)) as Plane;
					pole1.position = new Number3D(Math.cos(RADIAN * i) * (radius + poleWidth/2), h/2, Math.sin(RADIAN * i) * (radius + poleWidth/2));
					pole2.position = new Number3D(Math.cos(RADIAN * i) * (radius + roadWidth - poleWidth/2), h/2, Math.sin(RADIAN * i) * (radius + roadWidth - poleWidth/2));
					pole1.rotationY = pole2.rotationY = -i % 360;
					if (i/20 % 2) {
						lines.addNewLine(2, pole1.x, h, pole1.z, pole1.x, h+10, pole1.z);
						lines.addNewLine(2, pole2.x, h, pole2.z, pole2.x, h+10, pole2.z);
						lines.addNewLine(2, pole1.x, h + 10, pole1.z, pole2.x, h + 10, pole2.z);
					}
				}
			}
			for (i = 0; i < roadMesh.geometry.vertices.length - 2; i += 2) {
				var vt0:Vertex3D = roadMesh.geometry.vertices[i];
				var vt1:Vertex3D = roadMesh.geometry.vertices[i + 1];
				var vt2:Vertex3D = roadMesh.geometry.vertices[i + 2];
				var vt3:Vertex3D = roadMesh.geometry.vertices[i + 3];
				roadMesh.geometry.faces.push(new Triangle3D(roadMesh, [vt0, vt1, vt3]));
				roadMesh.geometry.faces.push(new Triangle3D(roadMesh, [vt0, vt3, vt2]));
			}
			roadMesh.geometry.ready = true;
			roadMesh.geometry.flipFaces();
			
			var road2:Plane = d.addChild(new Plane(gradientColor, roadWidth, 400, 1, 4)) as Plane;
			road2.position = new Number3D(320+roadWidth/2, 120, 400/2);
			road2.rotationX = 90;
			
			//高層ビル
			var sizeX:int = 5;
			var sizeY:int = 7;
			var padding:Number = 25;
			var noiseMap:BitmapData = new BitmapData(sizeX, sizeY, true, 0xFFFFFFFF);
			noiseMap.noise(1234, 0, 255, 7, true);
			noiseMap.applyFilter(noiseMap, noiseMap.rect, new Point(), new GlowFilter(0x000000, 1, 2, 2, 2, 2, true));
			var len:int = sizeX * sizeY;
			for (i = 0; i < len; i++) {
				var px:int = i % sizeX;
				var py:int = i / sizeY;
				var per:Number = (noiseMap.getPixel(px, py) >> 16 & 0xFF) / 0xFF;
				if (per > 0.1 && px != 2 && py != 3) {
					var cubeHeight:Number = per * 400;
					var building:Cube = d.addChild(new Cube(new MaterialsList( { all:sideColor } ), 20, 20, cubeHeight)) as Cube;
					building.position = new Number3D((px - sizeX / 2) * padding, cubeHeight / 2, (py - sizeY / 2) * padding);
				}
			}
			return d;
		}
	}
}

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.display.Sprite;
import flash.display.Stage;
import flash.display.StageQuality;
import flash.filters.BlurFilter;
import flash.filters.GlowFilter;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.utils.Dictionary;
import flash.utils.getTimer;
import org.papervision3d.materials.ColorMaterial;
import org.papervision3d.materials.utils.MaterialsList;
import org.papervision3d.objects.primitives.Cube;

class Painter {
	/**
	 * グラデーションスプライト生成
	 */
	static public function createGradientRect(width:Number, height:Number, colors:Array, alphas:Array, ratios:Array = null, rotation:Number = 0, x:Number = 0, y:Number = 0):Sprite {
		var i:int;
		if (!ratios) ratios = [];
		if(!ratios.length) for (i = 0; i < colors.length; i++) ratios.push(int(255 * i / (colors.length - 1)));
		else for (i = 0; i < ratios.length; i++) ratios[i] = Math.round(ratios[i] * 255);
		var sp:Sprite = new Sprite();
		var mtx:Matrix = new Matrix();
		mtx.createGradientBox(width, height, Math.PI / 180 * rotation, 0, 0);
		if (colors.length == 1 && alphas.length == 1) sp.graphics.beginFill(colors[0], alphas[0]);
		else sp.graphics.beginGradientFill("linear", colors, alphas, ratios, mtx);
		sp.graphics.drawRect(0, 0, width, height);
		sp.graphics.endFill();
		sp.x = x;
		sp.y = y;
		return sp;
	}
	
	/**
	 * スプライトをキャプチャしてBitmap化する
	 * @param	target	キャプチャするSprite
	 * @param	smooth	Bitmapのsmoothに設定する値
	 * @param	stage	Stageクラスを渡すと最高画質でキャプチャします
	 */
	static public function captureSprite(target:Sprite, smooth:Boolean = true, stage:Stage = null):Sprite {
		var sp:Sprite = new Sprite();
		sp.blendMode = target.blendMode;
		
		if (stage) {
			//キャプチャする瞬間だけ最高画質にする
			var saveQuality:String = stage.quality;
			stage.quality = StageQuality.BEST;
		}
		
		var rect:Rectangle = getFilterBounds(target);
		var bmd:BitmapData = new BitmapData(rect.width, rect.height, true, 0);
		bmd.draw(target, new Matrix(1, 0, 0, 1, -rect.x, -rect.y));
		
		if(stage) stage.quality = saveQuality;
		var bmp:Bitmap = sp.addChild(new Bitmap(bmd, "auto", smooth)) as Bitmap;
		bmp.x = rect.x;
		bmp.y = rect.y;
		return sp;
	}
	
	/**
	 * フィルターも含めたSpriteの矩形範囲を返す
	 * @param	target	サイズを調べるSprite
	 * @return
	 */
	static public function getFilterBounds(target:Sprite):Rectangle {
		var rect:Rectangle = target.getBounds(target);
		if (!rect.width) rect.width = 1;
		if (!rect.height) rect.height = 1;
		var bmd:BitmapData;
		var basePos:Point = rect.topLeft;
		rect.x = rect.y = 0;
		for each (var filter:* in target.filters) {
			bmd = new BitmapData(rect.width, rect.height, true, 0);
			rect = bmd.generateFilterRect(rect, filter);
			basePos.offset(rect.x, rect.y);
			rect.x = rect.y = 0;
		}
		rect.offsetPoint(basePos);
		return rect;
	}
}

/**
 * レンズフレアクラス
 * このスプライトを画面中央に配置して使う
 */
class LensEffect extends Sprite {
	private const ORB_COLOR:uint = 0xC7C677;
	private var _ratios:Dictionary = new Dictionary();
	private var _ghosts:Vector.<Sprite> = new Vector.<Sprite>();
	private var _sun:Sprite;
	private var _sunRing:Sprite;
	private var _sunStar:Sprite;
	private var _sunGlow:Sprite;
	private var _sunGlow2:Sprite;
	private var _sunLine:Sprite;
	private var _sunFlash1:Sprite;
	private var _sunFlash2:Sprite;
	private var _stage:Stage;
	
	public function LensEffect() {
	}
	
	public function init(stage:Stage):void {
		_stage = stage;
		mouseChildren = mouseEnabled = false;
		_sun = addChild(createSun()) as Sprite;
		//リングを生成
		var ringSizes:Array = [60, 120];
		var ringRatios:Array = [-0.3, -0.7];
		for (var i:int = 0; i < ringSizes.length; i++) {
			var ring:Sprite = addChild(createFlare(ringSizes[i])) as Sprite;
			_ghosts.push(ring);
			_ratios[ring] = ringRatios[i];
		}
		//オーブを生成
		var orbSizes:Array = [15, 5, 10, 6, 60];
		for (var n:int = 0; n < orbSizes.length; n++) {
			var orb:Sprite = addChild(createOrb(orbSizes[n], ORB_COLOR)) as Sprite;
			_ghosts.push(orb);
			_ratios[orb] = 0.7 - n * 0.4;
		}
	}
	
	/**
	 * 太陽の放射エフェクトを回転
	 */
	public function rotateFlash():void {
		var rot:Number = getTimer() / 200 % 360;
		_sunFlash1.rotation = -rot;
		_sunFlash2.rotation = rot;
	}
	
	/**
	 * レンズフレアの強さ（0～1）を設定
	 * @param	per
	 */
	public function setPower(per:Number):void {
		visible = !!per;
		if (!per) return;
		_sunRing.alpha = 0.1 * per;
		_sunStar.scaleX = _sunStar.scaleY = per;
		_sunFlash1.alpha = 0.2 * per;
		_sunFlash2.alpha = 0.1 * per;
		_sunLine.width = 500 * per * 2;
		_sunLine.height = 15 * per * 2;
		_sunLine.alpha = 0.2 * per;
		_sunGlow.scaleX = _sunGlow.scaleY = per;
		_sunGlow2.alpha = per * 0.5 - 0.2;
		for each(var orb:Sprite in _ghosts) orb.alpha = per;
	}
	
	/**
	 * 太陽の位置を画面の中心からのオフセットで指定
	 * @param	px
	 * @param	py
	 */
	public function setSunPosition(px:Number, py:Number):void {
		_sun.x = int(px);
		_sun.y = int(py);
		for each(var orb:Sprite in _ghosts) {
			orb.x = int(px * _ratios[orb]);
			orb.y = int(py * _ratios[orb]);
			//虹リングだった場合
			if (orb.numChildren >= 2) {
				var ringRay:Sprite = orb.getChildAt(1) as Sprite;
				ringRay.x = int(px / 5);
				ringRay.y = int(py / 5);
			}
		}
	}
	
	//太陽セットを生成
	private function createSun():Sprite {
		var sp:Sprite = new Sprite();
		_sunRing = sp.addChild(createRing(100)) as Sprite;
		_sunFlash1 = sp.addChild(createFlash(150, 20, 0x5977AD)) as Sprite;
		_sunFlash2 = sp.addChild(createFlash(120, 50, 0xFFFFFF)) as Sprite;
		_sunStar = sp.addChild(createStar(100, 6, 0.03, 0xFFFFFF, 4)) as Sprite;
		_sunStar.rotation = 15;
		_sunLine = sp.addChild(createGlow(500, 0xFFFFFF)) as Sprite;
		_sunGlow = sp.addChild(createGlow(30, 0xFFFFFF)) as Sprite;
		_sunGlow2 = sp.addChild(createGlow(150, 0xFFDD88)) as Sprite;
		sp.blendMode = BlendMode.ADD;
		return sp;
	}
	
	//虹リングセットを生成
	private function createFlare(size:Number = 100):Sprite {
		var ring:Sprite = createRing(size);
		ring.alpha = 0.5;
		var ray:Sprite = new Sprite();
		ray.addChild(createStar(size*2, 100, 0.2));
		ray.addChild(createStar(size*2.5, 175, 0.15));
		ray.addChild(createGlow(size, 0x000000));
		var sp:Sprite = new Sprite();
		sp.addChild(ring);
		sp.addChild(Painter.captureSprite(ray, false, _stage));
		sp.blendMode = BlendMode.ADD;
		return sp;
	}
	
	//光の放射イメージを生成
	private function createFlash(size:Number = 100, count:int = 50, color:uint = 0xffffff):Sprite {
		var sp:Sprite = new Sprite();
		sp.graphics.lineStyle();
		var mat:Matrix = new Matrix();
		mat.createGradientBox(size * 2, size * 2, 0, -size, -size);
		sp.graphics.beginGradientFill("radial", [color, color], [1, 0], [0, 255], mat);
		sp.graphics.drawCircle(0, 0, size);
		sp.graphics.endFill();
		sp.graphics.beginFill(0x000000, 1);
		var random:Array = new Array();
		var total:Number = 0;
		for (var n:int = 0; n < count*2; n ++) {
			total += Math.random() * 50 + 10;
			random.push(total);
		}
		for (var m:int = 0; m < random.length; m ++) {
			random[m] /= total / 360;
			var px:Number = Math.cos(Math.PI/180 * random[m]) * (size*1.2);
			var py:Number = Math.sin(Math.PI/180 * random[m]) * (size*1.2);
			if (m % 2) {
				sp.graphics.moveTo(px, py);
			}else {
				sp.graphics.lineTo(px, py);
				sp.graphics.lineTo(0, 0);
			}
		}
		sp.graphics.endFill();
		sp.filters = [new BlurFilter(2, 2, 3)];
		return Painter.captureSprite(sp, false, _stage);
	}
	
	//オーブイメージを生成
	private function createOrb(size:Number = 100, color:uint = 0xFFFFFF):Sprite {
		var sp:Sprite = new Sprite();
		sp.graphics.lineStyle();
		var mat:Matrix = new Matrix();
		mat.createGradientBox(size * 2, size * 2, 0, -size, -size);
		sp.graphics.beginGradientFill("radial", [color, color], [0.2, 1], [0, 255], mat);
		sp.graphics.drawCircle(0, 0, size);
		sp.graphics.endFill();
		sp.filters = [new GlowFilter(color, 1, 3, 3, 1, 3, false, true), new BlurFilter(2, 2, 3)];
		sp.blendMode = BlendMode.ADD;
		return Painter.captureSprite(sp, false, _stage);
	}
	
	//グローイメージを生成
	private function createGlow(size:Number = 100, color:uint = 0xFFFFFF):Sprite {
		var sp:Sprite = new Sprite();
		sp.graphics.lineStyle();
		var mat:Matrix = new Matrix();
		mat.createGradientBox(size * 2, size * 2, 0, -size, -size);
		sp.graphics.beginGradientFill("radial", [color, color], [1, 0], [0, 255], mat);
		sp.graphics.drawCircle(0, 0, size);
		sp.graphics.endFill();
		return Painter.captureSprite(sp, false, _stage);
	}
	
	//虹リングイメージを生成
	private function createRing(size:Number = 100):Sprite {
		var sp:Sprite = new Sprite();
		sp.graphics.lineStyle();
		var mat:Matrix = new Matrix();
		mat.createGradientBox(size * 2, size * 2, 0, -size, -size);
		sp.graphics.beginGradientFill("radial", [0xFF0000, 0xFFdd00, 0x00FF00, 0x0066FF, 0x0000FF], [0, 1, 1, 0.5, 0], [180, 205, 215, 235, 255], mat);
		sp.graphics.drawCircle(0, 0, size);
		sp.graphics.endFill();
		return Painter.captureSprite(sp, false, _stage);
	}
	
	//星イメージを生成
	private function createStar(size:Number = 100, count:uint = 8, per:Number = 0.05, color:uint = 0x000000, blur:Number = 0):Sprite {
		var sp:Sprite = new Sprite();
		sp.graphics.lineStyle();
		sp.graphics.beginFill(color, 1);
		var step:Number = 360 / (count * 2);
		for (var i:int = 0; i < count * 2; i ++) {
			var radius:Number = (i % 2)? size * per : size;
			var px:Number = Math.cos(Math.PI / 180 * i * step) * radius;
			var py:Number = Math.sin(Math.PI / 180 * i * step) * radius;
			if (i == 0) sp.graphics.moveTo(px, py);
			else sp.graphics.lineTo(px, py);
		}
		sp.graphics.endFill();
		sp.filters = (blur)? [new BlurFilter(blur, blur, 3)] : [];
		return Painter.captureSprite(sp, false, _stage);
	}
}

/**
 * 画面サイズ
 */
class Display {
	static public var width:Number;
	static public var height:Number;
	static public var size:Rectangle = new Rectangle();
	static public var center:Point = new Point();
	static public function setSize(width:Number, height:Number):void {
		Display.width = size.width = width;
		Display.height = size.height = height;
		center.x = width / 2;
		center.y = height / 2;
	}
}

/**
 * 道路を走る車
 */
class Car extends Cube {
	private var _offset:Number;
	private var _speed:Number;
	private var _line:Number;
	
	public function Car(position:Number = 0, direction:Boolean = true) {
		super(new MaterialsList( { all:new ColorMaterial(0x000000) } ), 4, 8, 4, 1, 1, 1);
		_offset = position;
		_speed = (direction)? 0.1 : -0.1;
		_line = (direction)? 13 : 23;
		rotationX = -4;
	}
	
	public function update():void {
		var rot:Number = ((getTimer() * 0.05 * _speed + _offset) % 720 + 720) % 720;
		var radius:Number = 80 + rot / 3;
		x = Math.cos(Math.PI / 180 * rot) * (radius + _line);
		z = Math.sin(Math.PI / 180 * rot) * (radius + _line);
		y = rot / 6 + 2;
		rotationY = -rot;
	}
}
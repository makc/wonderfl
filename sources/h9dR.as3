/**
 * 雲海
 * クリックでカメラを切り替えられます
 */
package  {
	import flash.display.*;
	import flash.events.*;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import net.hires.debug.Stats;
	import org.papervision3d.core.geom.renderables.Triangle3D;
	import org.papervision3d.core.geom.renderables.Vertex3D;
	import org.papervision3d.core.geom.TriangleMesh3D;
	import org.papervision3d.core.math.Number3D;
	import org.papervision3d.core.math.NumberUV;
	import org.papervision3d.core.proto.MaterialObject3D;
	import org.papervision3d.materials.ColorMaterial;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.Papervision3D;
	import org.papervision3d.view.BasicView;
	
	[SWF(width = "465", height = "465", frameRate = "30", backgroundColor = "#000000")]
	public class Clouds extends Sprite {
		/**雲の数*/
		public const CLOUD_NUM:int = 120;
		/**雲画像のパターン数*/
		public const PATTERN_NUM:int = 35;
		/**雲のサイズ*/
		public const CLOUD_SIZE:Rectangle = new Rectangle(0, 0, 400, 200);
		/**perlinNoiseに使うとまずいシード値（画像に穴があくかもしれない）*/
		public const ERROR_SEEDS:Array = [346, 514, 1155, 1519, 1690, 1977, 2327, 2337, 2399, 2860, 2999, 3099, 4777, 4952, 5673, 6265, 7185, 7259, 7371, 7383, 7717, 7847, 8032, 8350, 8676, 8963, 8997, 9080, 9403, 9615, 9685];
		
		public const PI:Number = Math.PI / 180;
		public var loading:LoadingScene;
		public var cameraCtrl:CameraController;
		public var view:BasicView;
		public var horizonTarget:DisplayObject3D;
		public var airplane:TriangleMesh3D;
		public var canvas1:BitmapData;
		public var canvas2:BitmapData;
		public var bg:BackGround;
		public var ground:Sprite;
		public var clouds:Vector.<Cloud> = new Vector.<Cloud>();
		public var drawObjects:Vector.<Cloud> = new Vector.<Cloud>();
		public var cloudImages:Vector.<BitmapData> = new Vector.<BitmapData>();
		public var clearColor:ColorTransform = new ColorTransform(1, 1, 1, 0);
		
		public function Clouds() {
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			Display.setSize(465, 465);
			stage.frameRate = 60;
			stage.quality = "low";
			Papervision3D.PAPERLOGGER.unregisterLogger(Papervision3D.PAPERLOGGER.traceLogger);
			
			view = new BasicView(Display.width, Display.height, false, false, "Free");
			horizonTarget = view.scene.addChild(new DisplayObject3D());
			horizonTarget.autoCalcScreenCoords = true;
			addChild(Painter.createGradientRect(Display.width, Display.height, [Color.sky1], [1]));
			ground = Painter.createGradientRect(Display.width, Display.height, [Color.ground], [1]);
			bg = new BackGround();
			bg.x = Display.center.x;
			bg.mask = addChild(Painter.createGradientRect(Display.width, Display.height, [0x000000], [1]));
			canvas1 = new BitmapData(Display.width, Display.height, true, 0x00FFFFFF);
			canvas2 = new BitmapData(Display.width, Display.height, true, 0x00FFFFFF);
			loading = new LoadingScene();
			
			//色々配置
			addChild(ground);
			addChild(bg);
			addChild(new Bitmap(canvas1));
			addChild(view.viewport);
			addChild(new Bitmap(canvas2));
			addChild(new Stats({bg:0x808080, fps:0xFFFFFF})).blendMode = BlendMode.OVERLAY;
			addChild(loading);
			
			//雲生成
			for (var i:int = 0; i < CLOUD_NUM; i++) {
				var cloud:Cloud = new Cloud();
				clouds.push(cloud);
				cloud.setPosition(Math.random() * 3500 - 1750, Math.random() * -300 + 9000, Math.random() * 4000 - 2000);
			}
			
			//飛行機生成
			airplane = createAirplane();
			airplane.y = 10000;
			airplane.autoCalcScreenCoords = true;
			view.scene.addChild(airplane);
			
			//カメラ初期化
			cameraCtrl = new CameraController();
			cameraCtrl.init(view.scene, view.camera);
			
			//雲画像生成開始
			addEventListener(Event.ENTER_FRAME, onLoading);
		}
		
		//航空機モデルを生成
		private function createAirplane():TriangleMesh3D {
			var scale:Number = 0.1;
			var vts:Array = [
				[0,26,-1242],[70,-46,-258],[71,176,-991],[98,167,-369],[0,183,323],[79,142,438],[0,220,1206],[32,63,-1221],[116,33,-949],[137,38,-258],[114,90,471],[14,174,1150],[16,136,806],[373,185,1170],[388,208,1276],[33,-46,-923],[-33,-46,-923],[-70,-46,-258],[40,20,427],[-40,20,427],[0,188,1230],[0,109,-1219],[-71,176,-991],[0,227,-1004],[-98,167,-369],[0,223,-369],[-79,142,438],[-32,63,-1221],[-116,33,-949],[-137,38,-258],
				[-114,90,471],[-14,174,1150],[-16,136,806],[-373,185,1170],[-388,208,1276],[0,198,1186],[0,198,798],[0,493,1272],[0,495,1166],[56,-19,-494],[1206,92,176],[59,-19,-20],[1249,92,323],[-59,-19,-20],[-56,-19,-494],[-1206,92,176],[-1249,92,323],[547,19,64],[547,21,-199],[-547,21,-199],[-547,19,64],[444,-16,-140],[409,-16,-140],[392,-46,-140],[409,-75,-140],[444,-75,-140],[461,-46,-140],[482,-46,-411],[454,1,-411],[399,1,-411],
				[371,-46,-411],[399,-94,-411],[454,-94,-411],[783,20,71],[749,20,71],[731,-9,71],[749,-39,71],[783,-39,71],[800,-9,71],[821,-9,-199],[793,38,-199],[738,38,-199],[710,-9,-199],[738,-57,-199],[793,-57,-199],[-461,-46,-140],[-444,-16,-140],[-409,-16,-140],[-392,-46,-140],[-409,-75,-140],[-444,-75,-140],[-482,-46,-411],[-454,1,-411],[-399,1,-411],[-371,-46,-411],[-399,-94,-411],[-454,-94,-411],[-800,-9,71],[-783,20,71],[-749,20,71],
				[-731,-9,71],[-749,-39,71],[-783,-39,71],[-821,-9,-199],[-793,38,-199],[-738,38,-199],[-710,-9,-199],[-738,-57,-199],[-793,-57,-199]
			];
			var ids:Array = [
				[21,2,23],[23,2,3],[3,25,23],[25,3,5],[5,4,25],[4,5,6],[0,7,21],[0,15,8],[8,7,0],[15,1,9],[9,8,15],[1,18,10],[10,9,1],[18,20,10],[7,8,2],[2,21,7],[8,9,3],[3,2,8],[9,10,5],[5,3,9],[10,20,6],[6,5,10],[12,13,14],[14,11,12],[13,12,11],[11,14,13],[0,16,15],[15,16,17],[17,1,15],[1,17,19],
				[19,18,1],[18,19,20],[23,22,21],[23,25,24],[24,22,23],[25,4,26],[26,24,25],[4,6,26],[0,21,27],[0,27,28],[28,16,0],[16,28,29],[29,17,16],[17,29,30],[30,19,17],[19,30,20],[27,21,22],[22,28,27],[28,22,24],[24,29,28],[29,24,26],[26,30,29],[30,26,6],[6,20,30],[32,31,34],[34,33,32],[33,34,31],[31,32,33],[35,36,38],[38,37,35],
				[38,36,35],[35,37,38],[40,42,47],[47,48,40],[47,48,39],[39,41,47],[50,46,45],[45,49,50],[49,50,43],[43,44,49],[47,42,40],[40,48,47],[41,39,48],[48,47,41],[45,46,50],[50,49,45],[49,44,43],[43,50,49],[54,53,52],[52,51,56],[54,52,56],[55,54,56],[58,59,60],[60,61,62],[58,60,62],[57,58,62],[56,51,58],[58,57,56],[51,52,59],[59,58,51],
				[52,53,60],[60,59,52],[53,54,61],[61,60,53],[54,55,62],[62,61,54],[55,56,57],[57,62,55],[66,65,64],[64,63,68],[66,64,68],[67,66,68],[70,71,72],[72,73,74],[70,72,74],[69,70,74],[68,63,70],[70,69,68],[63,64,71],[71,70,63],[64,65,72],[72,71,64],[65,66,73],[73,72,65],[66,67,74],[74,73,66],[67,68,69],[69,74,67],[75,76,77],[77,78,79],
				[75,77,79],[80,75,79],[86,85,84],[84,83,82],[86,84,82],[81,86,82],[75,81,82],[82,76,75],[76,82,83],[83,77,76],[77,83,84],[84,78,77],[78,84,85],[85,79,78],[79,85,86],[86,80,79],[80,86,81],[81,75,80],[87,88,89],[89,90,91],[87,89,91],[92,87,91],[98,97,96],[96,95,94],[98,96,94],[93,98,94],[87,93,94],[94,88,87],[88,94,95],[95,89,88],
				[89,95,96],[96,90,89],[90,96,97],[97,91,90],[91,97,98],[98,92,91],[92,98,93],[93,87,92]
			];
			var material:MaterialObject3D = new ColorMaterial(Color.planeSkin, 1);
			var mesh:TriangleMesh3D = new TriangleMesh3D(material, [], []);
			var vertexes:Array = [];
			for each (var vt:Array in vts) vertexes.push(new Vertex3D(vt[0]*scale, vt[1]*scale, vt[2]*scale));
			for each (var id:Array in ids) mesh.geometry.faces.push(new Triangle3D(mesh, [vertexes[id[0]], vertexes[id[1]], vertexes[id[2]]], null, [new NumberUV(), new NumberUV(), new NumberUV()]));
			mesh.geometry.vertices = vertexes;
			mesh.geometry.ready = true;
			return mesh;
		}
		
		//雲画像生成中
		private function onLoading(...arg):void {
			for (var i:int = 0; i < 3; i++) {
				if(cloudImages.length >= PATTERN_NUM){
					start();
					break;
				}
				var seed:int = Math.random() * 10000 + 1;
				if (ERROR_SEEDS.indexOf(seed) >= 0) seed++;
				var ct:Number = (Math.random() < 0.3)? Math.random() * 0.3 : Math.random() * 1.5;
				cloudImages.push(Painter.createCloud(CLOUD_SIZE.width, CLOUD_SIZE.height, seed, ct, Color.cloudBase, Color.cloudLight, Color.cloudShadow));
				loading.setProgress(cloudImages.length / PATTERN_NUM);
			}
		}
		
		//レンダリング開始
		private function start():void {
			removeEventListener(Event.ENTER_FRAME, onLoading);
			removeChild(loading);
			var index:int = -1;
			for each (var cloud:Cloud in clouds) {
				index = ++index % cloudImages.length;
				cloud.image = cloudImages[index];
			}
			stage.addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent):void {
				cameraCtrl.switchCamera();
			});
			Time.start();
			addEventListener(Event.ENTER_FRAME, onEnter);
			onEnter(null);
		}
		
		//毎フレーム処理
		private function onEnter(e:Event):void {
			var c:Cloud;
			Time.update();
			var time:int = Time.count;
			
			//飛行機を傾ける
			airplane.rotationZ = Math.sin(PI * time / 150) * 30;
			
			//カメラ位置更新
			cameraCtrl.setAirplaneRoll(airplane.rotationZ);
			cameraCtrl.update();
			
			//地平線用ダミーモデルをカメラの前方に配置
			horizonTarget.position = new Number3D(Math.cos(cameraCtrl.lookDirection) * 10000, 10000, Math.sin(cameraCtrl.lookDirection) * 10000);
			
			//PV3Dレンダリング
			view.singleRender();
			
			//雲を動かす
			var area:int = 2000;
			for each(c in clouds) {
				c.z = ((c.startPosition.z + time * 0.42) + area) % (area * 2) - area;
				var loop:int = int(((c.startPosition.z + time * 0.42) + area) / (area * 2));
				if (c.loop != loop) {
					//周回数が変化する度に雲の配置を変化させる
					c.loop = loop;
					c.x = Math.random() * 3500 - 1750;
					c.y = Math.random() * -300 + 10000;
				}
				cameraCtrl.calculateScreen(c.screen, c.x, c.y, c.z);
			}
			
			//背景画像を地平線の高さに移動
			bg.y = horizonTarget.screen.y + Display.center.y;
			bg.rotation = cameraCtrl.roll;
			bg.slide(cameraCtrl.lookDirection / (Math.PI * 2));
			ground.visible = horizonTarget.screen.y + Display.center.y < Display.height;
			
			//雲画像処理
			canvas1.lock();
			canvas2.lock();
			canvas1.colorTransform(Display.size, clearColor);
			canvas2.colorTransform(Display.size, clearColor);
			//描画対象の雲を絞り込む
			drawObjects.length = 0;
			for each(c in clouds) {
				if (c.screen.z > 10) {
					c.update();
					if (c.alpha <= 0) continue;
					if (c.screen.x + Display.center.x < -CLOUD_SIZE.width * c.scale / 2) continue;
					if (c.screen.x + Display.center.x > Display.width + CLOUD_SIZE.width * c.scale / 2) continue;
					drawObjects.push(c);
				}
			}
			drawObjects.sort(function(a:Cloud, b:Cloud):Number { return int(b.screen.z - a.screen.z); } );
			//雲描画
			for each(c in drawObjects) {
				var target:BitmapData = (airplane.screen.z < c.screen.z)? canvas1 : canvas2;
				var ct:ColorTransform = new ColorTransform(1, 1, 1, c.alpha, 0, 0, 0, 0);
				var mtx:Matrix = new Matrix();
				mtx.scale(c.scale, c.scale);
				mtx.rotate(PI * view.camera.localRotationZ);
				var dx:Number = c.scale * CLOUD_SIZE.width / 2;
				var dy:Number = c.scale * CLOUD_SIZE.height / 2;
				var cos:Number = Math.cos(PI * cameraCtrl.roll);
				var sin:Number = Math.sin(PI * cameraCtrl.roll);
				var px:Number = c.screen.x + Display.center.x - cos * dx + sin * dy;
				var py:Number = c.screen.y + Display.center.y - sin * dx - cos * dy;
				mtx.translate(px, py);
				target.draw(c.image, mtx, ct);
			}
			canvas1.unlock();
			canvas2.unlock();
		}
	}
}

import flash.display.*;
import flash.filters.*;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.utils.getTimer;
import org.papervision3d.cameras.Camera3D;
import org.papervision3d.core.math.Number3D;
import org.papervision3d.core.proto.CameraObject3D;
import org.papervision3d.objects.DisplayObject3D;
import org.papervision3d.scenes.Scene3D;

/**
 * 画面サイズ
 */
class Display {
	static public var width:Number;
	static public var height:Number;
	static public var size:Rectangle;
	static public var center:Point;
	static public function setSize(width:Number, height:Number):void {
		Display.width = width;
		Display.height = height;
		size = new Rectangle(0, 0, width, height);
		center = new Point(width / 2, height / 2);
	}
}

/**
 * 色
 */
class Color {
	/**航空機の色*/
	static public var planeSkin:uint = 0xFFFFFF;
	/**雲の色*/
	static public var cloudBase:uint = 0xD7DDE5;
	/**雲のハイライト色*/
	static public var cloudLight:uint = 0xFFFFFF;
	/**雲の影の色*/
	static public var cloudShadow:uint = 0x6D8790;
	/**空の色（上）*/
	static public var sky1:uint = 0x1F437F;
	/**空の色（下）*/
	static public var sky2:uint = 0x6290C1;
	/**地平線付近の色*/
	static public var horizon:uint = 0xA0BCD1;
	/**地上の色*/
	static public var ground:uint = 0xA1ACA4;
}

/**
 * 経過時間
 */
class Time {
	static private var _start:int;
	static public var count:int;
	static public function update():void {
		count = getTimer() - _start + 7000;
	}
	static public function start():void {
		_start = getTimer();
	}
}

/**
 * 雲
 */
class Cloud {
	public var x:Number = 0;
	public var y:Number = 0;
	public var z:Number = 0;
	public var screen:Number3D = new Number3D();
	public var loop:int;
	public var startPosition:Number3D;
	public var image:BitmapData;
	public var alpha:Number;
	public var scale:Number;
	public function Cloud() {
	}
	/**
	 * 雲の初期位置を設定
	 */
	public function setPosition(x:Number, y:Number, z:Number):void {
		startPosition = new Number3D(x, y, z);
		this.x = x;
		this.y = y;
		this.z = z;
	}
	/**
	 * スケールと透明度を更新
	 */
	public function update():void {
		scale = 600 / screen.z;
		var perMin:Number = screen.z / 200;
		var perMax:Number = 1 - (screen.z - 1500) / 800;
		if (perMin > 1) perMin = 1;
		if (perMax > 1) perMax = 1;
		alpha = perMin * perMax * 2;
	}
}

/**
 * カメラ操作
 */
class CameraController {
	private const RADIAN:Number = Math.PI / 180;
	private var _calculateObject:DisplayObject3D = new DisplayObject3D();
	private var _lookAtTarget:DisplayObject3D = new DisplayObject3D();
	private var _camera:Camera3D;
	private var _type:int = 0;
	private var _airplaneRoll:Number = 0;
	public var roll:Number;
	public var angle:Number;
	public var rotation:Number;
	public var distance:Number;
	public var lookDirection:Number;
	public function CameraController() {
	}
	/**
	 * シーンとカメラを渡して初期化
	 */
	public function init(scene:Scene3D, camera:CameraObject3D):void {
		_camera = camera as Camera3D;
		scene.addChild(_calculateObject);
		scene.addChild(_lookAtTarget);
	}
	/**
	 * (x,y,z)のスクリーン座標を計算してscreenに設定する
	 */
	public function calculateScreen(screen:Number3D, x:Number, y:Number, z:Number):void {
		_calculateObject.x = x;
		_calculateObject.y = y;
		_calculateObject.z = z;
		_calculateObject.view.calculateMultiply(_camera.eye, _calculateObject.transform);
		_calculateObject.calculateScreenCoords(_camera);
		screen.copyFrom(_calculateObject.screen);
	}
	/**
	 * カメラ変更
	 */
	public function switchCamera():void {
		_type = ++_type % 5;
	}
	/**
	 * 飛行機の傾きを渡す
	 */
	public function setAirplaneRoll(roll:Number):void {
		_airplaneRoll = roll;
	}
	/**
	 * カメラ位置更新
	 */
	public function update():void {
		var time:int = Time.count;
		switch(_type) {
			case 0:
				distance = Math.sin(RADIAN * time / 80) * 200 + 600;
				rotation = time / 1000 * 60 * 0.2;
				roll = Math.sin(RADIAN * time / 50) * 20;
				angle = Math.sin(RADIAN * time / 100) * 100 + 50;
				_lookAtTarget.position = new Number3D(0, 10000, 0);
				break;
			case 1:
				distance = 280;
				rotation = Math.sin(RADIAN * time / 110) * 20 + 90;
				roll = -_airplaneRoll;
				angle = Math.sin(RADIAN * time / 90) * 50 + 30;
				_lookAtTarget.position = new Number3D(0, 10000, -10000);
				break;
			case 2:
				distance = 500;
				rotation = Math.sin(RADIAN * time / 110) * 10;
				roll = 0;
				angle = Math.sin(RADIAN * -time / 70) * 200;
				_lookAtTarget.position = new Number3D(0, 10000, 0);
				break;
			case 3:
				distance = 800;
				rotation = -time / 200;
				roll = 0;
				angle = -400;
				_lookAtTarget.position = new Number3D(0, 10000, 0);
				break;
			case 4:
				distance = 40;
				rotation = 50;
				roll = -_airplaneRoll / 2;
				angle = 30 + _airplaneRoll;
				_lookAtTarget.position = new Number3D(1000, 10000, -700);
				break;
		}
		_camera.position = new Number3D(Math.cos(RADIAN * rotation) * distance, angle + 10000, Math.sin(RADIAN * rotation) * distance);
		_camera.lookAt(_lookAtTarget);
		_camera.roll(roll);
		lookDirection = Math.atan2(_lookAtTarget.z - _camera.z, _lookAtTarget.x - _camera.x);
	}
}

class Painter {
	/**
	 * 雲画像生成
	 * @param	width	幅
	 * @param	height	高さ
	 * @param	seed	ランダムシード値
	 * @param	contrast	コントラスト0～
	 * @param	color	ベースの色
	 * @param	light	明るい色
	 * @param	shadow	暗い色
	 */
	static public function createCloud(width:int, height:int, seed:int, contrast:Number = 1, color:uint = 0xFFFFFF, light:uint = 0xFFFFFF, shadow:uint = 0xDDDDDD):BitmapData {
		var gradiation:Sprite = new Sprite();
		var drawMatrix:Matrix = new Matrix();
		drawMatrix.createGradientBox(width, height);
		gradiation.graphics.beginGradientFill("radial", [0x000000, 0x000000], [0, 1], [0, 255], drawMatrix);
		gradiation.graphics.drawRect(0, 0, width, height);
		gradiation.graphics.endFill();
		var alphaBmp:BitmapData = new BitmapData(width, height);
		alphaBmp.perlinNoise(width / 3, height / 2.5, 5, seed, false, true, 1|2|4, true);
		var zoom:Number = 1 + (contrast - 0.1) / (contrast + 0.9);
		if (contrast < 0.1) zoom = 1;
		if (contrast > 2.0) zoom = 2;
		var ctMatrix:Array = [contrast + 1, 0, 0, 0, -128 * contrast, 0, contrast + 1, 0, 0, -128 * contrast, 0, 0, contrast + 1, 0, -128 * contrast, 0, 0, 0, 1, 0];
		alphaBmp.draw(gradiation, new Matrix(zoom, 0, 0, zoom, -(zoom - 1) / 2 * width, -(zoom - 1) / 2 * height));
		alphaBmp.applyFilter(alphaBmp, alphaBmp.rect, new Point(), new ColorMatrixFilter(ctMatrix));
		var image:BitmapData = new BitmapData(width, height, true, 0xFF << 24 | color);
		image.copyChannel(alphaBmp, alphaBmp.rect, new Point(), 4, 8);
		image.applyFilter(image, image.rect, new Point(), new GlowFilter(light, 1, 4, 4, 1, 3, true));
		var bevelSize:Number = Math.min(width, height) / 30;
		image.applyFilter(image, image.rect, new Point(), new BevelFilter(bevelSize, 45, light, 1, shadow, 1, bevelSize/5, bevelSize/5, 1, 3));
		var image2:BitmapData = new BitmapData(width, height, true, 0);
		image2.draw(Painter.createGradientRect(width, height, [light, color, shadow], [1, 0.2, 1], null, 90), null, null, BlendMode.MULTIPLY);
		image2.copyChannel(alphaBmp, alphaBmp.rect, new Point(), 4, 8);
		image.draw(image2, null, null, BlendMode.MULTIPLY);
		alphaBmp.dispose();
		return image;
	}
	/**
	 * グラデーションスプライト生成
	 */
	static public function createGradientRect(width:Number, height:Number, colors:Array, alphas:Array, ratios:Array = null, rotation:Number = 0):Sprite {
		var i:int, rts:Array = new Array();
		if(ratios == null) for (i = 0; i < colors.length; i++) rts.push(int(255 * i / (colors.length - 1)));
		else for (i = 0; i < ratios.length; i++) rts[i] = Math.round(ratios[i] * 255);
		var sp:Sprite = new Sprite();
		var mtx:Matrix = new Matrix();
		mtx.createGradientBox(width, height, Math.PI / 180 * rotation, 0, 0);
		if (colors.length == 1 && alphas.length == 1) sp.graphics.beginFill(colors[0], alphas[0]);
		else sp.graphics.beginGradientFill("linear", colors, alphas, rts, mtx);
		sp.graphics.drawRect(0, 0, width, height);
		sp.graphics.endFill();
		return sp;
	}
}

/**
 * 遠景画像
 */
class BackGround extends Sprite {
	private var _imageWidth:int = 2000;
	private var _viewWidth:int = 600;
	private var _cloudWidth:int = 120;
	private var _cloudHeight:int = 60;
	private var _image:BitmapData;
	private var _cloudSprite:Sprite;
	public function BackGround() {
		_viewWidth = Display.width * 1.5;
		var sky:Sprite = addChild(Painter.createGradientRect(Display.width*2, Display.height, [Color.sky1, Color.sky2, Color.horizon], [1, 1, 1], [0, 0.9, 1], 90)) as Sprite;
		sky.x = -Display.width;
		sky.y = -Display.height;
		var ground:Sprite = addChild(Painter.createGradientRect(Display.width*2, Display.height, [Color.horizon, Color.ground], [1, 1], null, 90)) as Sprite;
		ground.y = -1;
		ground.x = -Display.width;
		//遠景画像作成
		_image = new BitmapData(_imageWidth, _cloudHeight, true, 0x00FFFFFF);
		for (var n:int = 0; n < 80; n++) {
			var cloud:BitmapData = Painter.createCloud(_cloudWidth, _cloudHeight, n+200, 1, Color.cloudBase, Color.cloudLight, Color.cloudShadow);
			_image.copyPixels(cloud, cloud.rect, new Point(Math.random() * (_imageWidth - _cloudWidth), 0), null, null, true);
		}
		_image.applyFilter(_image, _image.rect, new Point(), new BlurFilter(2, 2, 1));
		
		_cloudSprite = new Sprite();
		_cloudSprite.x = -_viewWidth / 2;
		_cloudSprite.y = -_cloudHeight / 2;
		addChild(_cloudSprite);
	}
	/**
	 * 遠景画像をスライドする
	 */
	public function slide(per:Number):void {
		per %= 1;
		_cloudSprite.graphics.clear();
		_cloudSprite.graphics.beginBitmapFill(_image, new Matrix(1, 0, 0, 1, _imageWidth * per, 0), true, true);
		_cloudSprite.graphics.drawRect(0, 0, _viewWidth, _cloudHeight);
	}
}

/**
 * 画像生成中画面
 */
class LoadingScene extends Sprite {
	private var _lineWidth:Number = 200;
	private var _loadedLine:Sprite;
	public function LoadingScene() {
		var bg:Sprite = addChild(Painter.createGradientRect(Display.width, Display.height, [0x000000], [1])) as Sprite;
		var baseLine:Sprite = addChild(Painter.createGradientRect(_lineWidth, 2, [0x444444], [1])) as Sprite;
		_loadedLine = addChild(Painter.createGradientRect(_lineWidth, 2, [0x7DA3C8], [1])) as Sprite;
		baseLine.x = _loadedLine.x = int((Display.width - _lineWidth) / 2);
		baseLine.y = _loadedLine.y = int((Display.height - baseLine.height) / 2);
		setProgress(0);
	}
	public function setProgress(per:Number):void {
		_loadedLine.width = _lineWidth * per;
	}
}
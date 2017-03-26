/**
 * 画面ドラッグでカメラを回転して、右のボタンで地形をランダムに変形します。
 */
package {
	import com.bit101.components.*;
	import flash.display.*;
	import flash.events.*;
	import flash.filters.BlurFilter;
	import flash.filters.GlowFilter;
	import flash.geom.ColorTransform;
	import org.papervision3d.core.effects.BitmapColorEffect;
	import org.papervision3d.core.effects.BitmapLayerEffect;
	import org.papervision3d.core.effects.utils.BitmapDrawCommand;
	import org.papervision3d.core.geom.Pixels;
	import org.papervision3d.core.geom.renderables.Pixel3D;
	import org.papervision3d.core.math.Number3D;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.view.BasicView;
	import org.papervision3d.view.layer.BitmapEffectLayer;
	
	public class Waterfall extends Sprite {
		private var _modelView:ModelView;
		private var _waterView:BasicView;
		private var _layer:BitmapEffectLayer;
		private var _cameraTarget:DisplayObject3D;
		private var _drag:SphericalDragger;
		private var _terrain:Terrain;
		private var _waterPixels:Pixels;
		private var _waters:Vector.<WaterDrop> = new Vector.<WaterDrop>();
		private var _calculateObject:DisplayObject3D;
		private var _sprayEfx:SprayEffect;
		private var _loader:ImageLoader;
		private var _countID:int;
		private var _waterIndex:int = -1;
		
		public function Waterfall() {
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			stage.frameRate = 30;
			stage.quality = StageQuality.LOW;
			addChild(Painter.createColorRect(Param.DISPLAY.width, Param.DISPLAY.height, 0));
			_loader = new ImageLoader();
			_loader.addImage("http://assets.wonderfl.net/images/related_images/1/15/15d5/15d555224e78afd2bb8f004fbdf8835cfec21f9d", "stone");
			_loader.addImage("http://assets.wonderfl.net/images/related_images/e/e5/e526/e52615ecac7d880ac41cbdd5a673cd973e283d33", "sky");
			_loader.load(onReady);
		}
		
		private function onReady():void {
			_terrain = new Terrain(1200, 1200);
			_terrain.noise(Param.DEFAULT_SEED);
			
			//BasicView
			_modelView = new ModelView(Param.DISPLAY.width, Param.DISPLAY.height);
			_waterView = new BasicView(Param.DISPLAY.width, Param.DISPLAY.height, false, false, "Free");
			_modelView.mouseChildren = _waterView.mouseChildren = false;
			_modelView.mouseEnabled = _waterView.mouseEnabled = false;
			_modelView.init(_terrain, _loader.data);
			
			//水用レイヤを生成
			_layer = new BitmapEffectLayer(_waterView.viewport, Param.DISPLAY.width, Param.DISPLAY.height, true);
			_layer.addEffect(new BitmapLayerEffect(new BlurFilter(3, 3, 1)));
			_layer.addEffect(new BitmapLayerEffect(new GlowFilter(Param.WATERGLOW_COLOR, 1, 2, 2, 0.05, 1)));
			_layer.addEffect(new BitmapColorEffect(1, 1, 1, 0.97));
			_layer.drawCommand = new BitmapDrawCommand(null, null, BlendMode.NORMAL);
			_waterView.viewport.containerSprite.addLayer(_layer);
			_waterPixels = new Pixels(_layer);
			_waterView.scene.addChild(_waterPixels);
			_calculateObject = new DisplayObject3D();
			_waterView.scene.addChild(_calculateObject);
			
			//水しぶき用エフェクト
			_sprayEfx = new SprayEffect(Param.DISPLAY.width, Param.DISPLAY.height);
			addChild(_modelView);
			addChild(_waterView);
			addChild(_sprayEfx);
			new PushButton(this, 360, 440, "RANDOM TERRAIN", onClickGenerate);
			new FPSButton(this, 5, 440, 30, 120);
			
			//カメラの注視点用ダミーオブジェクト
			_cameraTarget = new DisplayObject3D();
			_cameraTarget.position = Param.CENTER;
			
			//画面ドラッグ管理
			_drag = new SphericalDragger(stage, -50, -5, 950);
			_drag.angle.min = -10;
			_drag.angle.max = 89;
			_drag.rotation.min = -180;
			_drag.rotation.max = 0;
			_drag.addEventListener(Event.CHANGE, onMoveCamera);
			onMoveCamera(null);
			
			//シミュレーション開始
			_waterView.startRendering();
			addEventListener(Event.ENTER_FRAME, onTickSimulate);
		}
		
		/**
		 * スクリーン座標を取得する
		 */
		private function calculateScreen(x:Number, y:Number, z:Number):Number3D {
			_calculateObject.x = x;
			_calculateObject.y = y;
			_calculateObject.z = z;
			//viewプロパティを更新しないとレンダリングするまで座標が更新できないっぽい
			_calculateObject.view.calculateMultiply(_waterView.camera.eye, _calculateObject.transform);
			_calculateObject.calculateScreenCoords(_waterView.camera);
			return _calculateObject.screen.clone();
		}
		
		/**
		 * 地形生成ボタンクリック時
		 */
		private function onClickGenerate(e:MouseEvent):void {
			_layer.canvas.colorTransform(_layer.canvas.rect, new ColorTransform(1, 1, 1, 0.8, 0, 0, 0, 0));
			_terrain.noise();
			_modelView.updateTerrain(_terrain);
		}
		
		/**
		 * カメラを動かした時だけモデルをレンダリング
		 */
		private function onMoveCamera(e:Event):void {
			_layer.canvas.colorTransform(_layer.canvas.rect, new ColorTransform(1, 1, 1, 0.95, 0, 0, 0, 0));
			var pos:Number3D = Number3D.add(_drag.position, _cameraTarget.position);
			_modelView.camera.position = pos;
			_waterView.camera.position = pos;
			_modelView.camera.lookAt(_cameraTarget);
			_waterView.camera.lookAt(_cameraTarget);
			_modelView.singleRender();
		}
		
		/**
		 * 水を追加（多すぎたら一番古い水を使いまわして使う）
		 */
		private function addWater(x:Number = 0, y:Number = 0, z:Number = 0):WaterDrop {
			var w:WaterDrop;
			if (_waterPixels.pixels.length >= Param.WATER_LIMIT) {
				_waterIndex = ++_waterIndex % _waters.length;
				w = _waters[_waterIndex];
				w.x = x;
				w.y = y;
				w.z = z;
				w.vx = w.vy = w.vz = 0;
				w.pixel.color = w.color;
			} else {
				var color:uint = 0xFF << 24 | Painter.blendColor(Param.WATER1_COLOR, Param.WATER2_COLOR, Math.random());
				var p:Pixel3D = new Pixel3D(color, x, y, z);
				_waterPixels.addPixel3D(p);
				w = new WaterDrop(p);
				w.color = color;
				w.id = _countID = ++_countID % 100;
				_waters.push(w);
			}
			w.isRemove = false;
			w.isSplash = (w.id % 2 > 0);
			return w;
		}
		
		/**
		 * 水のシミュレーション
		 * （色々処理をはしょってるので滑らかな地形以外ではバグります）
		 */
		private function onTickSimulate(e:Event):void {
			var i:int, w:WaterDrop, px:Number, pz:Number, h:Number, vx:Number, vz:Number, ix:int, iz:int, per:Number;
			//滝の水を追加しつづける
			for (i = 0; i < 8; i++) addWater(Param.tapPosition.x + Math.random() * 160 - 80, Param.tapPosition.y, Param.tapPosition.z - Math.random() * 10).vz = Math.random() * -5 - 7;
			//水を動かす
			_sprayEfx.bitmapData.lock();
			for each(w in _waters) {
				if (w.isRemove) continue;
				w.vy -= Param.gravity;
				w.vx += Param.wind.x;
				w.vz += Param.wind.y;
				w.x += w.vx;
				w.y += w.vy;
				w.z += w.vz;
				if (!w.isSplash && w.y <= Param.WATER_LEVEL + 1) {
					w.isSplash = true;
					_sprayEfx.addSmoke(calculateScreen(w.x, w.y, w.z));
				}
				px = w.x - Param.CENTER.x;
				pz = w.z - Param.CENTER.z;
				if (px * px + pz * pz > _terrain.radius) {
					w.isRemove = true;
					w.pixel.color = 0;
					continue;
				}
				h = _terrain.getHeight(w.x, w.z);
				if (w.y < h + 0.1) {
					w.y = h + 0.1;
					w.vy = 0;
					vx = 0;
					vz = 0;
					for (ix = -1; ix <= 1; ix++) {
						for (iz = -1; iz <= 1; iz++) {
							if (ix == 0 && iz == 0) continue;
							per = (h - _terrain.getHeight(ix + w.x, iz + w.z)) >> 1;
							if (per > 0) {
								vx += per * ix;
								vz += per * iz;
							}
						}
					}
					w.vx += vx + Math.random() - 0.5;
					w.vz += vz + Math.random() - 0.5;
					w.vx *= Param.friction;
					w.vz *= Param.friction;
				} else {
					w.vx *= Param.airResistance;
					w.vz *= Param.airResistance;
				}
				w.pixel.x = w.x;
				w.pixel.y = w.y;
				w.pixel.z = w.z;
			}
			_sprayEfx.tick();
			_sprayEfx.bitmapData.unlock();
		}
	}
}

import com.bit101.components.*;
import flash.display.*;
import flash.events.*;
import flash.filters.BlurFilter;
import flash.filters.GlowFilter;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.net.URLRequest;
import flash.system.LoaderContext;
import org.papervision3d.core.geom.renderables.Pixel3D;
import org.papervision3d.core.geom.renderables.Triangle3D;
import org.papervision3d.core.geom.renderables.Vertex3D;
import org.papervision3d.core.geom.TriangleMesh3D;
import org.papervision3d.core.math.Number3D;
import org.papervision3d.materials.BitmapMaterial;
import org.papervision3d.objects.primitives.Plane;
import org.papervision3d.view.BasicView;

/**
 * 各種パラメータ
 */
class Param {
	static public const DISPLAY:Rectangle = new Rectangle(0, 0, 465, 465);	//画面サイズ
	static public const CENTER:Number3D = new Number3D(600, 250, 600);	//空間の中心
	static public const DEFAULT_SEED:int = 5489;	//地形のランダムシード初期値
	static public const WATER_LEVEL:Number = -50;	//水面の高さ
	static public const WATER_LIMIT:int = 1200;	//水の表示限界
	static public var tapPosition:Number3D = new Number3D(600, 800, 1200);	//滝の位置
	static public var wind:Point = new Point(0, 0);	//風の強さ
	static public var airResistance:Number = 0.97;	//空気抵抗
	static public var friction:Number = 0.9;	//岩の摩擦
	static public var gravity:Number = 0.8;	//重力
	static public const WATER1_COLOR:uint = 0xC1CAD3;	//水の色1
	static public const WATER2_COLOR:uint = 0xC9D4D6;	//水の色2
	static public const WATERGLOW_COLOR:uint = 0x30AEF9;	//水の発光色
	static public const SURFACE_COLOR:uint = 0x748CA3;	//水面の色
	static public const FOG_COLOR:uint = 0x0D2A14;	//フォグの色
	static public const MOSS_COLOR:uint = 0x539526;	//コケの色
	static public const SUNGLOW_COLOR:uint = 0xD1E8FF;	//にじむ光の色
}

/**
 * FPS切り替えボタン
 */
class FPSButton extends PushButton {
	private var _minFps:int = 30;
	private var _maxFps:int = 60;
	private var _fpsMeter:FPSMeter;
	private var _limitLabel:Label;
	public function FPSButton(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0, min:Number = 30, max:Number = 60) {
		_minFps = min;
		_maxFps = max;
		super(null, xpos, ypos, "", onClickButton);
		addEventListener(Event.ADDED_TO_STAGE, onAddStage);
		if (parent) parent.addChild(this);
		setSize(75, height);
	}
	private function onAddStage(e:Event):void {
		removeEventListener(Event.ADDED_TO_STAGE, onAddStage);
		_fpsMeter = new FPSMeter(this, 5, 0, "FPS: ");
		_limitLabel = new Label(this, 42, 0, "");
		_limitLabel.text = " / " + stage.frameRate;
	}
	private function onClickButton(e:MouseEvent):void {
		stage.frameRate = (stage.frameRate != _minFps)? _minFps : _maxFps;
		_limitLabel.text = " / " + stage.frameRate;
	}
}

/**
 * テクスチャ画像
 */
class ImageLoader {
	public var data:Object = { };
	private var _images:Array = [];
	private var _count:int;
	private var _completeFunc:Function;
	private var _errorFunc:Function;
	public function ImageLoader() {
	}
	/**
	 * ロードする画像URLを登録
	 */
	public function addImage(src:String, name:String):void {
		_images.push( { src:src, name:name } );
	}
	/**
	 * テクスチャ読み込み開始
	 */
	public function load(complete:Function, error:Function = null):void {
		_count = -1;
		_completeFunc = complete;
		_errorFunc = error;
		next();
	}
	private function next():void {
		if (++_count >= _images.length) {
			if(_completeFunc != null) _completeFunc.apply(null, []);
			return;
		}
		var loader:Loader = new Loader();
		loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
		loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
		loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
		loader.load(new URLRequest(_images[_count].src), new LoaderContext(true));
	}
	private function removeEvent(target:LoaderInfo):void {
		target.removeEventListener(Event.COMPLETE, onComplete);
		target.removeEventListener(IOErrorEvent.IO_ERROR, onError);
		target.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
	}
	private function onError(e:ErrorEvent):void {
		removeEvent(e.currentTarget as LoaderInfo);
		if (_errorFunc != null) _errorFunc.apply(null, []);
	}
	private function onComplete(e:Event):void {
		var info:LoaderInfo = e.currentTarget as LoaderInfo;
		removeEvent(info);
		data[_images[_count].name] = Bitmap(info.content).bitmapData;
		next();
	}
}

/**
 * 水滴
 */
class WaterDrop {
	public var pixel:Pixel3D;
	public var color:uint;
	public var id:int = 0;
	public var x:Number = 0;
	public var y:Number = 0;
	public var z:Number = 0;
	public var vx:Number = 0;
	public var vy:Number = 0;
	public var vz:Number = 0;
	public var isSplash:Boolean = false;
	public var isRemove:Boolean = false;
	public function WaterDrop(pixel:Pixel3D) {
		this.pixel = pixel;
		x = pixel.x;
		y = pixel.y;
		z = pixel.z;
	}
}

/**
 * 地形モデル描画用BasicView
 */
 class ModelView extends BasicView {
	private var _sky:TriangleMesh3D;
	private var _cliff:TriangleMesh3D;
	private var _texture:BitmapData;
	private var _textureData:Object;
	public function ModelView(width:Number, height:Number) {
		super(width, height, false, false, "Free");
	}
	/**
	 * 地形モデル初期化
	 */
	public function init(terrain:Terrain, textureData:Object):void {
		_textureData = textureData;
		var bg:Sprite = Painter.createColorRect(Param.DISPLAY.width, Param.DISPLAY.height, Param.FOG_COLOR);
		viewport.addChildAt(bg, 0);
		_sky = new Plane(new BitmapMaterial(textureData.sky, true), 1000, 1200, 2, 2);
		for each(var v:Vertex3D in _sky.geometry.vertices) v.y += 600;
		_sky.position = Param.tapPosition;
		_sky.rotationX = -65;
		_texture = _textureData.stone.clone();
		var material:BitmapMaterial = new BitmapMaterial(_texture);
		_cliff = new Plane(material, terrain.size.width, terrain.size.height, 30, 30);
		_cliff.x = terrain.size.width / 2;
		_cliff.z = terrain.size.height / 2;
		_cliff.rotationX = 90;
		scene.addChild(_sky);
		scene.addChild(_cliff);
		viewport.containerSprite.getChildLayer(_sky).filters = [new GlowFilter(Param.SUNGLOW_COLOR, 1, 30, 30, 1.5, 2)];
		updateTerrain(terrain);
	}
	/**
	 * 地形マップに合わせて地形モデルを変形する
	 */
	public function updateTerrain(terrain:Terrain):void {
		//テクスチャを更新
		var scale:Matrix = new Matrix();
		scale.scale(_texture.width / terrain.map.width, _texture.height / terrain.map.height);
		_texture.copyPixels(_textureData.stone, _textureData.stone.rect, new Point());
		_texture.draw(terrain.map, scale, null, BlendMode.MULTIPLY);
		_texture.draw(terrain.map, scale, null, BlendMode.OVERLAY);
		//こけ
		var moss:BitmapData = new BitmapData(terrain.noiseMap.width, terrain.noiseMap.height, true, 0xFF << 24 | Param.MOSS_COLOR);
		moss.copyChannel(terrain.noiseMap, terrain.noiseMap.rect, new Point(), BitmapDataChannel.RED, BitmapDataChannel.ALPHA);
		_texture.draw(moss, scale, null, BlendMode.OVERLAY);
		moss.dispose();
		//水
		_texture.draw(terrain.waterMask, scale, null, BlendMode.ADD);
		//フォグ
		var fog:Sprite = Painter.createGradientRect(_texture.width, _texture.height, false, [Param.FOG_COLOR, Param.FOG_COLOR, Param.FOG_COLOR], [0, 0, 1], [0, 0.6, 1]);
		_texture.draw(fog, null, null, BlendMode.NORMAL);
		//地形モデルの頂点を動かす
		for each(var v:Vertex3D in _cliff.geometry.vertices) v.z = -terrain.getHeight(v.x + _cliff.x, v.y + _cliff.z);
		for each(var face:Triangle3D in _cliff.geometry.faces) face.createNormal();
		singleRender();
	}
}

/**
 * 地形データ
 */
class Terrain {
	public var map:BitmapData;
	public var noiseMap:BitmapData;
	public var size:Rectangle;
	public var radius:Number;
	public var waterMask:BitmapData;
	public var data:Vector.<Number>;
	private var _yMax:Number = 600;
	private var _yMin:Number = -400;
	private var _padding:int = 1;
	private const ERROR_SEED:Array = [346, 514, 1155, 1519, 1690, 1977, 2327, 2337, 2399, 2860, 2999, 3099, 4777, 4952, 5673, 6265, 7185, 7259, 7371, 7383, 7717, 7847, 8032, 8350, 8676, 8963, 8997, 9080, 9403, 9615, 9685];
	//コンストラクタ
	public function Terrain(w:Number, h:Number) {
		data = new Vector.<Number>();
		size = new Rectangle(0, 0, w, h);
		map = new BitmapData(150, 150, false);
		noiseMap = new BitmapData(150, 150, true);
		waterMask = new BitmapData(150, 150, true);
		radius = Math.pow(Math.min(size.width, size.height) / 2, 2);
	}
	/**
	 * ランダムな地形を生成
	 */
	public function noise(seed:int = -1):void {
		//地形用BitmapDataを作る
		if(seed == -1) seed = Math.random() * 10000;
		if (ERROR_SEED.indexOf(seed) != -1) seed++;
		map.perlinNoise(map.width/2, map.height/2, 3, seed, false, true, BitmapDataChannel.RED, true);
		noiseMap.copyPixels(map, map.rect, new Point());
		noiseMap.draw(Painter.createColorRect(map.width, map.height, 0x000000), null, null, BlendMode.OVERLAY);
		noiseMap.draw(map, null, null, BlendMode.OVERLAY);
		var grad1:Sprite = Painter.createGradientRect(map.width, map.height, true, [0x000000, 0xCCCCCC], [0.1, 1], null, -90);
		var grad2:Sprite = Painter.createGradientRect(map.width, map.height, true, [0x505050, 0xFFFFFF, 0xFFFFFF, 0x505050], [1, 1, 1, 1], [0, 0.1, 0.9, 1], 0);
		var grad3:Sprite = Painter.createGradientRect(map.width, map.height, true, [0x505050, 0x808080], [1, 0], [0, 0.5], -90);
		map.draw(grad1, null, null, BlendMode.OVERLAY);
		map.draw(grad1, null, null, BlendMode.OVERLAY);
		map.draw(grad2, null, null, BlendMode.DARKEN);
		map.draw(grad3, null, null, BlendMode.NORMAL);
		var minColor:uint = Math.max(0, Math.min(0xFF, (Param.WATER_LEVEL - _yMin) / (_yMax - _yMin) * 0xFF));
		var splitColor:uint = 0xFF << 24 | minColor << 16 | minColor << 8 | minColor;
		map.threshold(map, map.rect, new Point(), "<", splitColor, splitColor);
		
		waterMask.copyPixels(map, map.rect, new Point());
		waterMask.threshold(waterMask, waterMask.rect, new Point(), "!=", splitColor, 0x00000000);
		var ct:ColorTransform = new ColorTransform();
		ct.color = Param.SURFACE_COLOR;
		waterMask.colorTransform(waterMask.rect, ct);
		waterMask.applyFilter(waterMask, waterMask.rect, new Point(), new BlurFilter(6, 6, 2));
		
		//生成した地形の高度をVectorに保存しておく
		var width:Number = map.width + _padding * 2;
		var height:Number = map.height + _padding * 2;
		var leng:int = width * height;
		for (var i:int = 0; i < leng; i++) {
			var px:int = i % width;
			var py:int = (height - 1) - int(i / width);
			if (px == 0 || px == width - 1 || py == 0 || py == height -1) {
				data[i] = Number.MAX_VALUE;
			} else {
				data[i] = (map.getPixel(px - 1, py - 1) >> 16) / 0xFF * (_yMax - _yMin) + _yMin;
			}
		}
	}
	/**
	 * 指定座標の高さを求める
	 */
	public function getHeight(x:Number, y:Number):Number {
		var px:int = (x / size.width) * (map.width - 1) + 1;
		var py:int = (y / size.height) * (map.height - 1) + 1;
		return data[px + py * (map.width + 2)];
	}
}

/**
 * 水しぶきエフェクト
 */
class SprayEffect extends Bitmap {
	private var _ct:ColorTransform;
	private var _smoke:BitmapData;
	private var _count:int = 0;
	private var _scaleW:Number;
	private var _scaleH:Number;
	public function SprayEffect(width:Number, height:Number) {
		var zoom:Number = 0.75;
		_ct = new ColorTransform(1, 1, 1, 0.95, 0, 0, 0, 0);
		super(new BitmapData(width * zoom, height * zoom, true, 0));
		_scaleW = this.width / width;
		_scaleH = this.height / height;
		_smoke = Painter.createSmoke(70 * _scaleW, 70 * _scaleH, 0xFFFFFF, 0.07, 10);
		this.width = width;
		this.height = height;
	}
	/**
	 * スクリーン座標を渡してエフェクトを追加する
	 */
	public function addSmoke(pos:Number3D):void {
		var px:Number = (pos.x + width / 2) * _scaleW - _smoke.width / 2;
		var py:Number = (pos.y + height / 2) * _scaleH - _smoke.height / 2;
		bitmapData.copyPixels(_smoke, _smoke.rect, new Point(px, py), null, null, true);
	}
	/**
	 * 時間を進める
	 */
	public function tick():void {
		if (++_count % 2) return;
		bitmapData.applyFilter(bitmapData, bitmapData.rect, new Point(0, -2), new BlurFilter(6, 6, 1));
		bitmapData.colorTransform(bitmapData.rect, _ct);
	}
}

class Painter {
	/**
	 * 2つの色を指定の割合で混ぜる
	 */
	static public function blendColor(rgb1:uint, rgb2:uint, per:Number):uint {
		var r:uint = (rgb1 >> 16 & 0xFF) * per + (rgb2 >> 16 & 0xFF) * (1 - per);
		var g:uint = (rgb1 >> 8 & 0xFF) * per + (rgb2 >> 8 & 0xFF) * (1 - per);
		var b:uint = (rgb1 & 0xFF) * per + (rgb2 & 0xFF) * (1 - per);
		return (r << 16 | g << 8 | b);
	}
	/**
	 * 煙画像生成
	 */
	static public function createSmoke(width:Number, height:Number, color:uint = 0xFFFFFF, alpha:Number = 1, seed:int = 1234):BitmapData {
		var bmp:BitmapData = new BitmapData(width, height, true, 0xFF << 24 | color);
		var alph:BitmapData = bmp.clone();
		alph.perlinNoise(width/2, height/2, 4, seed, true, true, BitmapDataChannel.RED, true);
		alph.draw(createGradientRect(width, height, false, [0x000000, 0x000000], [1 - alpha, 1], [0, 1]));
		bmp.copyChannel(alph, alph.rect, new Point(), BitmapDataChannel.RED, BitmapDataChannel.ALPHA);
		alph.dispose();
		return bmp;
	}
	/**
	 * 一色塗りスプライト生成
	 */
	static public function createColorRect(width:Number, height:Number, color:uint = 0x000000, alpha:Number = 1):Sprite {
		var sp:Sprite = new Sprite();
		sp.graphics.beginFill(color, alpha);
		sp.graphics.drawRect(0, 0, width, height);
		sp.graphics.endFill();
		return sp;
	}
	/**
	 * グラデーションスプライト生成
	 */
	static public function createGradientRect(width:Number, height:Number, isLinear:Boolean, colors:Array, alphas:Array, ratios:Array = null, r:Number = 0):Sprite {
		var i:int, ratioList:Array = new Array();
		if (ratios == null) for (i = 0; i < colors.length; i++) ratioList.push(int(255 * i / (colors.length - 1)));
		else for (i = 0; i < ratios.length; i++) ratioList[i] = Math.round(ratios[i] * 255);
		var sp:Sprite = new Sprite();
		var mtx:Matrix = new Matrix();
		mtx.createGradientBox(width, height, Math.PI / 180 * r, 0, 0);
		if (colors.length == 1 && alphas.length == 1) sp.graphics.beginFill(colors[0], alphas[0]);
		else sp.graphics.beginGradientFill((isLinear)? "linear" : "radial", colors, alphas, ratioList, mtx);
		sp.graphics.drawRect(0, 0, width, height);
		sp.graphics.endFill();
		return sp;
	}
}

/**
 * シーンをマウスでぐるぐる
 */
class SphericalDragger extends EventDispatcher {
	/**カメラの距離*/
	public var distance:Number;
	/**横方向の回転*/
	public var rotation:SphericalData = new SphericalData();
	/**縦方向の回転*/
	public var angle:SphericalData = new SphericalData();
	/**球面座標*/
	public var position:Number3D = new Number3D();
	private var _eventObject:InteractiveObject;
	private var _clickPoint:Point;
	private const RADIAN:Number = Math.PI / 180;
	
	/**座標が変わると呼ばれる*/
	public var onMovePosition:Function;
	
	/**
	 * @param	obj	マウスイベントを登録する場所
	 * @param	rotation	横方向角度
	 * @param	angle	縦方向角度
	 * @param	distance	中心点からの距離
	 */
	public function SphericalDragger(obj:InteractiveObject, rotation:Number = 0, angle:Number = 30, distance:Number = 1000) {
		this.distance = distance;
		this.angle.position = angle;
		this.angle.min = -(this.angle.max = 89);
		this.rotation.position = rotation;
		_eventObject = obj;
		_eventObject.addEventListener(MouseEvent.MOUSE_DOWN, onMsDown);
		updatePosition();
	}
	private function onMsDown(e:MouseEvent):void {
		_eventObject.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMsMove);
		_eventObject.stage.addEventListener(MouseEvent.MOUSE_UP, onMsUp);
		rotation.save = rotation.position;
		angle.save = angle.position;
		_clickPoint = new Point(_eventObject.mouseX, _eventObject.mouseY);
	}
	private function onMsMove(e:MouseEvent):void {
		var dragOffset:Point = new Point(_eventObject.mouseX, _eventObject.mouseY).subtract(_clickPoint);
		rotation.position = rotation.save - dragOffset.x * rotation.speed;
		rotation.checkLimit();
		angle.position = angle.save + dragOffset.y * angle.speed;
		angle.checkLimit();
		updatePosition();
	}
	private function onMsUp(...arg):void {
		_eventObject.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMsMove);
		_eventObject.stage.removeEventListener(MouseEvent.MOUSE_UP, onMsUp);
		updatePosition();
	}
	public function updatePosition():void {
		var per:Number = Math.cos(RADIAN * angle.position);
		var px:Number = Math.cos(RADIAN * rotation.position) * distance * per;
		var pz:Number = Math.sin(RADIAN * rotation.position) * distance * per;
		var py:Number = Math.sin(RADIAN * angle.position) * distance;
		position.reset(px, py, pz);
		notify();
	}
	public function notify():void {
		dispatchEvent(new Event(Event.CHANGE));
		if (onMovePosition != null) onMovePosition(position);
	}
}
class SphericalData {
	public var min:Number = NaN;
	public var max:Number = NaN;
	public var save:Number = NaN;
	public var speed:Number = 0.5;
	public var position:Number = 0;
	public function SphericalData() {
	}
	public function checkLimit():void {
		if (!isNaN(min) && position < min) position = min;
		else if (!isNaN(max) && position > max) position = max;
	}
}
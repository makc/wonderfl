// forked from PESakaTFM's forked from: SmolderEffect (changed colors and speed)
// I don't write English well. But, we can read ActionScript.>_<
// forked from tail_y's SmolderEffect
// Man, I wish I could read Japanese...  
// or that everyone wrote their comments in English.
// 背景はこれ使ってます http://wonderfl.net/c/A53P
package
{
	/*
	 カードが、ラスボスのように細かくなって消えていく演出。
	 カードグラフィックはエジエレキ（edielec）さんの作品だよ。
	 次のゲームで使いたくて作ったけど、キラキラ部分がキラキラしすぎたので、その部分は消すかも。 
	 */
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.display.BlendMode;
	import flash.display.GradientType;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.system.Security;

	public class SmolderEffect extends Sprite
	{
		public static const STAGE_W:uint = 465;
		public static const STAGE_H:uint = 465;
		
		// 設定
		private static const _CLOUD_SIZE:int = 150;
		private static const _NUM_OCTVES:int = 8;
		private static const _GRADIENT_STRENGTH:Number = 0.5;
		private static const _EFFECT_FRAME:int = 450;    //Slow it down for a more dramatic effect
		private static const _FIRE_COLOR:uint = 0xff220000; //Ashes should be black, ne?
		private static const _PARTICLE_COLOR:uint = 0xffffffff;
		private static const _PARTICLE_MOVE:int = -1;
		private static const _PARTICLE_MARGIN:int = 15;
		private static const _TWINCLE_SIZE:int = 4;
		private static const _TWINCLE_ALPHA:Number = 0.8;
		
		private static const _CARD_URL:Array = [
												"http://asset.sipo.jp/wonderfl/img/smolderEffect/cardSample1.png",
												"http://asset.sipo.jp/wonderfl/img/smolderEffect/cardSample2.png",
												"http://asset.sipo.jp/wonderfl/img/smolderEffect/cardSample3.png"
												];
		private static const _BG_URL:String = "http://asset.sipo.jp/wonderfl/img/smolderEffect/bg1.jpg";
		
		// ロード
		private var _loadNum:int = 0;
		private var _loadNumMax:int = 0;
		
		// 表示系
		private var _cardDisplayList:Array = [];
		private var _bgSprite:Sprite;	
		private var _displayData:BitmapData;
		private var _mainSprite:Sprite;	// エフェクト対象。これ自体は表示されない
		private var _display:Bitmap;
		private var _particle:Bitmap;
		private var _twincle:Bitmap;
		
		// エフェクト要素
		private var _effectW:int;
		private var _effectH:int;
		private var _point:Point = new Point();
		private var _rect:Rectangle;
		private var _effectCount:int;
		private var _shadow:DropShadowFilter = new DropShadowFilter(2, 90, 0x000000, 0.5, 32, 32, 1, 3);
		private var _particleColorTrans:ColorTransform = new ColorTransform(0.8, 0.9, 0.9);
		private var _particlePoint:Point = new Point(0, _PARTICLE_MOVE);
		private var _twincleMatrix:Matrix = new Matrix(1/_TWINCLE_SIZE, 0, 0, 1/_TWINCLE_SIZE);
		private var _reverseColor:ColorTransform = new ColorTransform(-1, -1, -1, 1, 255, 255, 255);
		
		// 使用画像
		private var _baseData:BitmapData;	// 最終的に表示されるビットマップ（加算以外）
		private var _clear:BitmapData;	// 消去用ビットマップ
		private var _black:BitmapData;	// 消去用ビットマップ（黒）
		private var _cloud:BitmapData;	// 雲
		private var _card:BitmapData;	// カードの部分
		private var _fire:BitmapData;	// 炎の部分
		private var _fireClear:BitmapData;
		private var _noise:BitmapData;
		private var _particleMask:BitmapData;
		private var _particleFire:BitmapData;
		private var _particleClear:BitmapData;
		private var _particleDisplay:BitmapData;	// パーティクル（加算になるので、別扱いする。）
		private var _twincleDisplay:BitmapData;
		
		public function SmolderEffect()
		{
			addEventListener(Event.ADDED_TO_STAGE, init);	// flexBuilderとの互換性。
			//Wonderfl.capture_delay(5);	// キャプチャ時間
		}
		
		private function init(e:Event):void {	// ここから開始
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// SWF設定
			stage.frameRate = 60;
			stage.quality = StageQuality.HIGH;
			// wonderflではキャプチャに背景色が反映されないので、背景を覆う。
			var bgBitmapData:BitmapData = new BitmapData(STAGE_W, STAGE_H, false, 0xFFFFFF);
			addChild(new Bitmap(bgBitmapData));
			
			_bgSprite = new CloudEffect1();
			addChild(_bgSprite);
			
			_mainSprite = new Sprite();
			_display = new Bitmap();
			_display.filters = [_shadow, new GlowFilter(0xF9BF10)];
			_display.blendMode = BlendMode.ADD;
			addChild(_display);
			_particle = new Bitmap();
			_particle.blendMode = BlendMode.ADD; // MULTIPLY can be used (Though it is necessary to darken the color of particle). 
			addChild(_particle);
			_twincle = new Bitmap();
			_twincle.blendMode = BlendMode.ADD;
			_twincle.scaleX = _twincle.scaleY = _TWINCLE_SIZE;
			_twincle.alpha = _TWINCLE_ALPHA
			addChild(_twincle);
			
			Security.loadPolicyFile("http://asset.sipo.jp/wonderfl/crossdomain.xml");
			var context:LoaderContext = new LoaderContext(true);
			// カードグラフィックの読み込み
			for (var i:int=0; i < _CARD_URL.length; i++){
				var loader:Loader = new Loader();
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, cardLoadEnd);
				_loadNumMax++;
				loader.load(new URLRequest(_CARD_URL[i]), context);
			}
			
			/*loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, bgLoadEnd);
			_loadNumMax++;
			loader.load(new URLRequest(_BG_URL), context);*/
		}
		
		private function cardLoadEnd(e:Event):void{
			_cardDisplayList.push(e.target.content);
			countUp();
		}
		private function bgLoadEnd(e:Event):void{
			_bgSprite.addChild(e.target.content);
			var lightSprite:Sprite = new Sprite();
			lightSprite.blendMode = BlendMode.ADD;
			lightSprite.graphics.beginFill(0xffffff, 0.5);
			lightSprite.graphics.drawRect(0, 0, STAGE_W, STAGE_H);
			_bgSprite.addChild(lightSprite);
			countUp();
		}
		
		private function countUp():void{
			_loadNum++;
			if (_loadNumMax <= _loadNum) startEffect();
		}
		
		private function startEffect():void{	// エフェクトの開始
			_mainSprite.addChild(_cardDisplayList[int(Math.random()*_CARD_URL.length)])
			// 表示用MCの準備
			_effectW = Math.ceil(_mainSprite.width);
			_effectH = Math.ceil(_mainSprite.height) + _PARTICLE_MARGIN*2;
			_rect = new Rectangle(0, 0, _effectW, _effectH);
			
			_clear = new BitmapData(_effectW, _effectH, true, 0x00000000);
			_black = new BitmapData(_effectW, _effectH, true, 0xff000000);
			_displayData = _clear.clone();
			_display.bitmapData = _displayData;
			_baseData = _clear.clone();
			_baseData.draw(_mainSprite, new Matrix(1, 0, 0, 1, 0, _PARTICLE_MARGIN));
			_card = _black.clone();
			_card.copyPixels(_baseData, _rect, _point, null, null, true);
			_fireClear = new BitmapData(_effectW, _effectH, true, _FIRE_COLOR);
			_fire = _fireClear.clone();
			_particleMask = _black.clone();
			_particleFire = _fireClear.clone();
			_particleClear = new BitmapData(_effectW, _effectH, true, _PARTICLE_COLOR);
			_particleDisplay = _clear.clone();
			_particle.bitmapData = _particleDisplay;
			_twincleDisplay = new BitmapData(_effectW/4, _effectH/4, true, 0x00000000);
			_twincle.bitmapData = _twincleDisplay;
			_twincle.smoothing = true;
			// 中央に配置
			_display.x = (STAGE_W - _effectW) / 2;
			_display.y = (STAGE_W - _effectH) / 2 - _PARTICLE_MARGIN;
			_particle.x = (STAGE_W - _effectW) / 2;
			_particle.y = (STAGE_W - _effectH) / 2 - _PARTICLE_MARGIN;
			_twincle.x = (STAGE_W - _effectW) / 2;
			_twincle.y = (STAGE_W - _effectH) / 2 - _PARTICLE_MARGIN;
			
			
			// 雲模様の作成
			_cloud = new BitmapData(_effectW, _effectH);
			_cloud.perlinNoise(_CLOUD_SIZE, _CLOUD_SIZE, _NUM_OCTVES, int(Math.random()*500), false, true, 0, true);
			var tmpGradient:Sprite = new Sprite();
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(_effectW, _effectH, Math.PI / 2, 0, 0);
			tmpGradient.graphics.beginGradientFill(GradientType.LINEAR, [0x000000, 0xffffff], [_GRADIENT_STRENGTH, _GRADIENT_STRENGTH], [0, 255], matrix);
			tmpGradient.graphics.drawRect(0, 0, _effectW, _effectH);
			_cloud.draw(tmpGradient);
			
			// ノイズの作成
			var originalNoise:BitmapData = _clear.clone();
			originalNoise.noise(int(Math.random()*int.MAX_VALUE), 0, 255, 7, true);
			_noise = _black.clone();
			
			
			_noise.threshold(originalNoise, _rect, _point, ">", 0x00f00000, 0x00000000, 0x00ff0000, false);
			
			
						
			// フレーム開始
			_effectCount = 50;
			addEventListener(Event.ENTER_FRAME, frame);
		}
		
		private function frame(e:Event):void{
			_effectCount++;
			_display.x = (STAGE_W - _effectW) / 2;
			_display.y = (STAGE_W - _effectH) / 2 - _PARTICLE_MARGIN;
			_display.x += Math.random() * 10-5;
			_display.y += Math.random() * 10 - 5;
			_bgSprite.alpha -= 0.0007;
			draw();
		}
		
		private function draw():void{
			_displayData.lock();
			_particleDisplay.lock();
			
			_displayData.copyPixels(_black, _rect, _point);
			var threshold:int = _effectCount * 0xff0000 / _EFFECT_FRAME;
			//_card.threshold(_cloud, _rect, _point, "<", threshold, 0x00000000, 0x00ff0000, false);
			_displayData.copyPixels(_card, _rect, _point);
			
			_fire.copyPixels(_fireClear, _rect, _point);
			_fire.threshold(_cloud, _rect, _point, ">", threshold, 0x00000000, 0x00ff0000, false);
			threshold = (_effectCount - 1) * 0xff0000 / _EFFECT_FRAME;
			_fire.threshold(_cloud, _rect, _point, "<", threshold, 0x00000000, 0x00ff0000, false);
			
			_displayData.copyPixels(_fire, _rect, _point, null, null, true);
			_displayData.copyChannel(_baseData, _rect, _point, BitmapDataChannel.ALPHA, BitmapDataChannel.ALPHA);
			_displayData.threshold(_cloud, _rect, _point, "<", threshold, 0x00000000, 0x00ff0000, false);
			
			_particleMask.copyPixels(_black, _rect, _point);
			_fire.colorTransform(_rect, _reverseColor); // _fire should be white.
			_fire.copyChannel(_baseData, _rect, _point, BitmapDataChannel.ALPHA, BitmapDataChannel.ALPHA);
			_particleMask.copyPixels(_fire, _rect, _point, null, null, true);
			_particleMask.copyPixels(_noise, _rect, _point, null, null, true);
			
			_particleFire.copyPixels(_particleClear, _rect, _point);
			_particleFire.copyChannel(_particleMask, _rect, _point, BitmapDataChannel.RED, BitmapDataChannel.ALPHA);
			
			_particleDisplay.copyPixels(_particleFire, _rect, _point, null, null, true);
			_particleDisplay.colorTransform(_rect, _particleColorTrans);
			_particleDisplay.copyPixels(_particleDisplay, _rect, _particlePoint);
			
			_twincleDisplay.copyPixels(_clear, _rect, _point);
			_twincleDisplay.draw(_particleDisplay, _twincleMatrix);
			
			_displayData.unlock();
			_particleDisplay.unlock();
			
			
			
			if (_EFFECT_FRAME <= _effectCount) end();
		}
		
		private function end():void{
			// 終了して、ユーザー操作待ち
			removeEventListener(Event.ENTER_FRAME, frame);;
			_mainSprite.removeChildAt(0);
			_displayData.copyPixels(_clear, _rect, _point);
			_particleDisplay.copyPixels(_clear, _rect, _point);
			addEventListener(MouseEvent.CLICK, clickRestart);
		}
		private function clickRestart(e:Event):void{
			removeEventListener(MouseEvent.CLICK, clickRestart);
			startEffect();
		}
	}
}

// forked from tail_y's CloudEffect
	/*
	 若干立体感のある、雲っぽい映像を作るよ。
	 はっきり言って重いので、実用性がちょっと無いよ！！
	 その代わり、リアルタイムで色合いとか変えられるから、時間に合わせて夕焼けになったりできるかも。
	 
	 仕組み的にはPhotoShopでの常套手段をFlashで再現したもの。
	 数値を変えるとかなりリアルなのも作れるけど、これ以上立体感を出すには他の工夫が必要。
	 台形変形とか、影の位置をずらしたりとかできれば・・・。
	 
	 雲模様の生成が遅いのはなんとかならないかな～
	 １オクターブずつ用意して、横にずれた分だけを新しく生成するとかさ。
	 ちょっと考えてみたけど頭痛くなったからやらなかったよ。
	 */
        /*
         びかーっとさせてみた。
         重いよ！！
        */
	
	import flash.display.*;
	import flash.events.*;
	import flash.filters.*;
	import flash.geom.*;
	
	class CloudEffect1 extends Sprite
	{
		public static const STAGE_W:uint = 465;
		public static const STAGE_H:uint = 465;
		
		public static const _H_RATE:Number = 4;	// 上下の圧縮割合
		
		// 雲模様関係
		private var _perlinNoiseBitmapData:BitmapData;
		private var _seed:int = Math.random()*int.MAX_VALUE;
		private var _perlinNoiseSize:Number = 0.20;	// 雲模様を画面全体に描画するのは重くて無理なので、サイズを減らす。
		private var _perlinNoiseSizeW:int = STAGE_W*_perlinNoiseSize;
		private var _perlinNoiseSizeH:int = STAGE_H*_perlinNoiseSize*_H_RATE;
		private var _cloudSize:int = _perlinNoiseSize * 100;
		private var _octaves:int = 4;	// 雲模様オクターブ数。レイヤー数みたいなもの。多いほど細かいけど、死ぬほど重くなる。
		private var _offsetList:Array = [];	// 雲のズレ。オクターブの数だけPointが必要。
		private var _offsetSpeedListX:Array = [0.4, 0.3, 0.2, -0.05];	// 雲をずらす量。
		private var _offsetSpeedListY:Array = [0.2, 0.1, -0.05, -0.1];
		
		// 立体化関係
		private var _displacementBitmapData:BitmapData;
		private var _displacementMapFilter:DisplacementMapFilter;
		private var _offsetMatrix:Matrix;
		
		// 射光関係
		private var _brightLength:uint = 8;
		private var _brightMatrices:Vector.<Matrix>;
		private var _colorTransform1:ColorTransform = new ColorTransform(1.3, 1.3, 1.3, 1, 0, 0, 0, 0);
		private var _colorTransform2:ColorTransform = new ColorTransform(0.5, 0.5, 0.5, 1, 100, 100, 100, 0);
		private var _colorTransform3:ColorTransform = new ColorTransform(0.25, 0.25, 0.25, 1, 0, 0, 0, 0);
		private var _colorTransform4:ColorTransform = new ColorTransform(0.25, 0.25, 0.25, 1, -10, -10, -10, 0);
		
		// 色変換関係
		private var _paletteBitmapData:BitmapData;
		private var _palette:Array = [];
		private var _nullPalette:Array = [];
		
		// 引き伸ばした画像データ
		private var _scaleChangeBitmap:Bitmap;
		
		// ちょっとしたカバー
		private var _cover:Shape;
		
		// その他
		private var _point:Point = new Point(0, 0);
		private var _rectSmall:Rectangle = new Rectangle(0, 0, _perlinNoiseSizeW, _perlinNoiseSizeH);
		
		function CloudEffect1()
		{
			//Wonderfl.disable_capture();
			addEventListener(Event.ADDED_TO_STAGE, init);	// flexBuilderとの互換性。
		}
		
		// ここから開始
		private function init(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			var i:int;
						
			// 雲模様データを用意する
			_perlinNoiseBitmapData = new BitmapData(_perlinNoiseSizeW, _perlinNoiseSizeH, false);
			for (i = 0; i < _octaves; i++) {
				_offsetList.push(new Point());
			}
			
			// 立体化データを用意する
			_displacementBitmapData = new BitmapData(_perlinNoiseSizeW, _perlinNoiseSizeH, false);
			_displacementMapFilter = new DisplacementMapFilter(_perlinNoiseBitmapData, _point, 0, BitmapDataChannel.RED, 0,
									 -120, DisplacementMapFilterMode.CLAMP);
			_offsetMatrix = new Matrix();
			_offsetMatrix.scale(1, 0.95);
			
			// 射光データを用意する
			_brightMatrices = new Vector.<Matrix>(_brightLength, false);
			for (i = 0; i < _brightLength; i++)
			{
				if(i == 0) {
					_brightMatrices[i] = new Matrix();
				}
				else {
					_brightMatrices[i] = _brightMatrices[i-1].clone();
				}
				_brightMatrices[i].translate(-_perlinNoiseSizeW/2, 0);
				_brightMatrices[i].scale(1.03, 1.01);
				_brightMatrices[i].translate(_perlinNoiseSizeW/2, 2);
			}
			
			// 色変換データを用意する
			createGradation();
			
			// サイズ
			_scaleChangeBitmap = new Bitmap(_displacementBitmapData);
			_scaleChangeBitmap.scaleX = 1/_perlinNoiseSize;
			_scaleChangeBitmap.scaleY = 1/_perlinNoiseSize/_H_RATE;
			_scaleChangeBitmap.smoothing = true;
			
			// 白っぽいカバー
			_cover = new Shape();
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(_perlinNoiseSizeW, _perlinNoiseSizeH, Math.PI/2);
			_cover.graphics.beginGradientFill(GradientType.LINEAR, [0x808080, 0x202020], [1, 1], [128, 255], matrix);
			_cover.graphics.drawRect(0, 0, _perlinNoiseSizeW, _perlinNoiseSizeH);
			
			// 表示
			addChild(_scaleChangeBitmap);
			
			addEventListener(Event.ENTER_FRAME, frame);
		}
		
		// グラデーションを作るよ
		private function createGradation():void
		{
			var tmpShape:Shape = new Shape();
			var tmpBitmap:BitmapData = new BitmapData(256, 1, false);
			var matrix:Matrix = new Matrix();
			var colorList:Array = [0x100010, 0x301020, 0x602030, 0xD08040, 0xFFF080, 0xFFFFF0];
			var alphaList:Array = [1,        1,        1,        1,        1,        1];
			var ratioList:Array = [0,       20,       80,      160,      220,      255];
			
			matrix.createGradientBox(255, 0);
			tmpShape.graphics.beginGradientFill(GradientType.LINEAR, colorList, alphaList, ratioList, matrix);
			tmpShape.graphics.drawRect(0, 0, 256, 1);
			tmpBitmap.draw(tmpShape);
			
			for (var i:int=0; i<256; i++)
			{
				_palette.push(tmpBitmap.getPixel(i, 0));
				_nullPalette.push(0x000000);
			}
		}
		
		private function frame(event:Event):void
		{	
			var i:int;
			
			// 雲模様のオフセットを決める
			for (i = 0; i < _octaves; i++)
			{
				_offsetList[i].x += _offsetSpeedListX[i];
				_offsetList[i].y += _offsetSpeedListY[i];
			}
			
			// 雲模様を作成
			_perlinNoiseBitmapData.perlinNoise(_cloudSize, _cloudSize, _octaves, _seed, false, true, 0, true, _offsetList);
			
			_displacementBitmapData.lock();
			
			// 立体感を出す
			_displacementBitmapData.applyFilter(_perlinNoiseBitmapData, _rectSmall, _point, _displacementMapFilter);
			_displacementBitmapData.draw(_perlinNoiseBitmapData, null, _colorTransform1, BlendMode.HARDLIGHT);
			_displacementBitmapData.draw(_perlinNoiseBitmapData, _offsetMatrix, _colorTransform2, BlendMode.SUBTRACT);
			_displacementBitmapData.scroll(0, 20);
			_displacementBitmapData.fillRect(new Rectangle(0, 0, _displacementBitmapData.width, 20), 0x000000)
			_displacementBitmapData.draw(_perlinNoiseBitmapData, null, _colorTransform3, BlendMode.ADD);
			
			// 光らせる
			for (i = 0; i < _brightLength; i++) {
				_displacementBitmapData.draw(_displacementBitmapData, _brightMatrices[i], _colorTransform4, BlendMode.ADD, null, true);
			}
			
			// パレットマップで変換
			_displacementBitmapData.paletteMap(_displacementBitmapData, _rectSmall, _point, _palette, _nullPalette, _nullPalette);
			
			_displacementBitmapData.draw(_cover, null, null, BlendMode.OVERLAY);
			_displacementBitmapData.unlock();
		}
		
	}










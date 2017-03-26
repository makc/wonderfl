// forked from tail_y's SmolderEffect
package
{
	/* しっぽのエフェクトと炎を組み合わせてみたよ
	 * エフェクト終了後にクリックで赤、青、黒の三種類の炎が切り替わるよ
	 * あと、とても重い
	 * 
	 **************************************************************************
	 * 
	 * カードが、ラスボスのように細かくなって消えていく演出。
	 * カードグラフィックはエジエレキ（edielec）さんの作品だよ。
	 * 次のゲームで使いたくて作ったけど、キラキラ部分がキラキラしすぎたので、その部分は消すかも。 
	 */
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.GradientType;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.ConvolutionFilter;
	import flash.filters.DropShadowFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.system.Security;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	public class BlazingEffect extends Sprite
	{
		// ステージ
		private const STAGE_W:uint   = 465;
		private const STAGE_H:uint   = 465;
		private const ZEROS:Point    = new Point(0, 0);
		private const RECT:Rectangle = new Rectangle(0, 0, STAGE_W, STAGE_H);
		
		// 設定
		private static const _CLOUD_SIZE:int           = 150;
		private static const _NUM_OCTVES:int           = 8;
		private static const _GRADIENT_STRENGTH:Number = 0.5;
		private static const _EFFECT_FRAME:int         = 200;
		private static const _FIRE_COLOR:uint          = 0xffffffff;
		private static const _PARTICLE_MOVE:int        = -1;
		private static const _PARTICLE_MARGIN:int      = 15;
		
		// URL
		private static const _CARD_URL:Array =
		[
			"http://asset.sipo.jp/wonderfl/img/smolderEffect/cardSample1.png",
			"http://asset.sipo.jp/wonderfl/img/smolderEffect/cardSample2.png",
			"http://asset.sipo.jp/wonderfl/img/smolderEffect/cardSample3.png"
		];
		private static const _BG_URL:String    = "http://asset.sipo.jp/wonderfl/img/smolderEffect/bg1.jpg";
		private static const _BLAZE_URL:String = "http://lab.alumican.net/wonderfl/blazing_effect/color_map.png";
		
		// ロード
		private var _loadNum:int    = 0;
		private var _loadNumMax:int = 0;
		
		// 表示系
		private var _cardDisplayList:Array = [];
		private var _bgSprite:Sprite;	
		private var _displayData:BitmapData;
		private var _mainSprite:Sprite;	// エフェクト対象。これ自体は表示されない
		private var _display:Bitmap;
		
		// エフェクト要素
		private var _effectW:int;
		private var _effectH:int;
		private var _point:Point = new Point();
		private var _rect:Rectangle;
		private var _effectCount:int;
		private var _shadow:DropShadowFilter = new DropShadowFilter(2, 90, 0x000000, 0.5, 32, 32, 1, 3);
		
		// 使用画像
		private var _baseData:BitmapData;	// 最終的に表示されるビットマップ（加算以外）
		private var _clear:BitmapData;	// 消去用ビットマップ
		private var _black:BitmapData;	// 消去用ビットマップ（黒）
		private var _cloud:BitmapData;	// 雲
		private var _card:BitmapData;	// カードの部分
		private var _fire:BitmapData;	// 炎の部分
		private var _fireClear:BitmapData;
		private var _noise:BitmapData;
		
		// 炎
		private var _blazeIndex:int;
		
		private var _blazeEmitter:BitmapData;
		private var _blazeEffect:BitmapData;
		
		private var _blazeCooling:BitmapData;
		private var _blazeCoolingOffset:Array;
		
		private var _blazeSpreadFilter:ConvolutionFilter;
		private var _blazeColorFilter:ColorMatrixFilter;
		
		private var _blazePaletteSource:BitmapData;
		private var _blazePalette:Array;
		private var _zeroPalette:Array;
		
		public function BlazingEffect():void
		{
			addEventListener(Event.ADDED_TO_STAGE, init); // flexBuilderとの互換性。
			Wonderfl.disable_capture();                   // キャプチャ時間
		}
		
		private function init(e:Event):void
		{
			// ここから開始
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			// SWF設定
			stage.frameRate = 30;
			stage.quality = StageQuality.LOW;
			
			// wonderflではキャプチャに背景色が反映されないので、背景を覆う。
			var bgBitmapData:BitmapData = new BitmapData(STAGE_W, STAGE_H, false, 0x888888);
			addChild(new Bitmap(bgBitmapData));
			
			_bgSprite = new Sprite();
			addChild(_bgSprite);
			
			_mainSprite = new Sprite();
			_display = new Bitmap();
			_display.filters = [_shadow];
			addChild(_display);
			
			Security.loadPolicyFile("http://asset.sipo.jp/wonderfl/crossdomain.xml");
			var context:LoaderContext = new LoaderContext(true);
			
			// カードグラフィックの読み込み
			for (var i:int=0; i < _CARD_URL.length; i++){
				var loader:Loader = new Loader();
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, cardLoadEnd);
				_loadNumMax++;
				loader.load(new URLRequest(_CARD_URL[i]), context);
			}
			
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, bgLoadEnd);
			_loadNumMax++;
			loader.load(new URLRequest(_BG_URL), context);
			
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, blazeLoadEnd);
			_loadNumMax++;
			loader.load(new URLRequest(_BLAZE_URL), context);
		}
		
		private function cardLoadEnd(e:Event):void
		{
			_cardDisplayList.push(e.target.content);
			countUp();
		}
		
		private function bgLoadEnd(e:Event):void
		{
			_bgSprite.addChild(e.target.content);
			countUp();
		}
		
		/**
		 * 炎エフェクトの初期設定
		 * Saqooshaさんのを元に、透過対応にしたりと改造して作ってます
		 * http://wonderfl.net/code/bffb3437de866ffdfcdd5015b1fba5ca37fff72a
		 */		private function blazeLoadEnd(e:Event):void
		{
			_blazePaletteSource = Bitmap(e.target.content).bitmapData;
			
			_blazeEmitter = new BitmapData(STAGE_W, STAGE_H, true, 0x0);
			_blazeCooling = new BitmapData(STAGE_W, STAGE_H, true, 0x0);
			_blazeEffect  = new BitmapData(STAGE_W, STAGE_H, true, 0x0);
			
			//発火元の拡張フィルター
			_blazeSpreadFilter = new ConvolutionFilter(3, 3, [
				0, 1, 0,
				1, 1, 1,
				0, 1, 0], 5
			);
			
			//冷却用雲模様のオフセット
			_blazeCoolingOffset = [
				new Point(0, 0),
				new Point(0, 0)
			];
			
			//
			_blazeColorFilter = new ColorMatrixFilter(
			[
				0.16, 0   , 0   , 0, 0,
				0   , 0.16, 0   , 0, 0,
				0   , 0   , 0.16, 0, 0,
				0   , 0   , 0   , 1, 0
			]);
			
			_createBlazePalette(_blazeIndex = 0);
			
			countUp();
		}
		
		private function _createBlazePalette(idx:int):void
		{
			_blazePalette = new Array();
			_zeroPalette  = new Array();
			for (var i:int = 0; i < 256; i++)
			{
				_blazePalette.push(_blazePaletteSource.getPixel32(i, idx * 32));
				_zeroPalette.push(0);
			}
		}
		
		private function countUp():void
		{
			_loadNum++;
			if (_loadNumMax <= _loadNum) startEffect();
		}
		
		private function startEffect():void
		{
			// エフェクトの開始
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
			
			// 中央に配置
			_display.x = (STAGE_W - _effectW) / 2;
			_display.y = (STAGE_H - _effectH) / 2 - _PARTICLE_MARGIN;
			
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
			
			//addChild(new Bitmap(_blazeEffect));
			
			// フレーム開始
			_effectCount = 0;
			addEventListener(Event.ENTER_FRAME, frame);
		}
		
		private function frame(e:Event):void
		{
			_effectCount++;
			draw();
		}
		
		private function draw():void
		{
			_displayData.lock();
			_blazeEmitter.lock();
			_blazeCooling.lock();
			_blazeEffect.lock();
			
			_displayData.copyPixels(_black, _rect, _point);
			var threshold:int = _effectCount * 0xff0000 / _EFFECT_FRAME;
			_displayData.copyPixels(_card, _rect, _point);
			
			_fire.copyPixels(_fireClear, _rect, _point);
			_fire.threshold(_cloud, _rect, _point, ">", threshold, 0x00000000, 0x00ff0000, false);
			threshold = (_effectCount - 1) * 0xff0000 / _EFFECT_FRAME;
			_fire.threshold(_cloud, _rect, _point, "<", threshold, 0x00000000, 0x00ff0000, false);
			
			//発火元の生成
			_blazeEmitter.copyPixels(_fire, RECT, ZEROS, null, null, true);
			_blazeEmitter.copyChannel(_baseData, RECT, ZEROS, BitmapDataChannel.ALPHA, BitmapDataChannel.ALPHA);
			_blazeEmitter.applyFilter(_blazeEmitter, RECT, ZEROS, _blazeSpreadFilter);
			
			//炎用の雲模様の生成
			_blazeCooling.perlinNoise(50, 50, 2, 982374, false, false, BitmapDataChannel.RED, true, _blazeCoolingOffset);
			_blazeCoolingOffset[0].x += 2.0;
			_blazeCoolingOffset[1].y += 10.0;
			_blazeCooling.applyFilter(_blazeCooling, RECT, ZEROS, _blazeColorFilter);
			
			//発火元に雲模様を合成
			_blazeEmitter.draw(_blazeCooling, null, null, BlendMode.SUBTRACT);
			_blazeEffect.paletteMap(_blazeEmitter, RECT, ZEROS, _blazePalette, _zeroPalette, _zeroPalette, _zeroPalette);
			_blazeEmitter.scroll(0, -3);
			//_blazeEffect.copyChannel(_blazeEffect, RECT, ZEROS, BitmapDataChannel.RED, BitmapDataChannel.ALPHA);
			
			//表示
			_displayData.copyChannel(_baseData, _rect, _point, BitmapDataChannel.ALPHA, BitmapDataChannel.ALPHA);
			_displayData.threshold(_cloud, _rect, _point, "<", threshold, 0x00000000, 0x00ff0000, false);
			_displayData.draw(_blazeEffect);
			
			_blazeEmitter.unlock();
			_blazeCooling.unlock();
			_blazeEffect.unlock();
			_displayData.unlock();
			
			if (_EFFECT_FRAME <= _effectCount) end();
		}
		
		private function end():void
		{
			// 終了して、ユーザー操作待ち
			removeEventListener(Event.ENTER_FRAME, frame);;
			_mainSprite.removeChildAt(0);
			_displayData.copyPixels(_clear, _rect, _point);
			addEventListener(MouseEvent.CLICK, clickRestart);
		}
		
		private function clickRestart(e:Event):void
		{
			removeEventListener(MouseEvent.CLICK, clickRestart);
			
			//炎エフェクトの切り替え
			if (++_blazeIndex == int(_blazePaletteSource.height / 32)) _blazeIndex = 0;
			_createBlazePalette(_blazeIndex);
			
			startEffect();
		}
	}
}
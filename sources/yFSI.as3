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
		private static const _EFFECT_FRAME:int = 150;
		private static const _FIRE_COLOR:uint = 0xffffffff;
		private static const _PARTICLE_MOVE:int = -1;
		private static const _PARTICLE_MARGIN:int = 15;
		private static const _TWINCLE_SIZE:int = 4;
		private static const _TWINCLE_ALPHA:Number = 0.5;
		
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
		private var _particleColorTrans:ColorTransform = new ColorTransform(0.8, 0.85, 0.9);
		private var _particlePoint:Point = new Point(0, _PARTICLE_MOVE);
		private var _twincleMatrix:Matrix = new Matrix(1/_TWINCLE_SIZE, 0, 0, 1/_TWINCLE_SIZE);
		
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
		private var _particleDisplay:BitmapData;	// パーティクル（加算になるので、別扱いする。）
		private var _twincleDisplay:BitmapData;
		
		public function SmolderEffect()
		{
			addEventListener(Event.ADDED_TO_STAGE, init);	// flexBuilderとの互換性。
			Wonderfl.capture_delay(2.7);	// キャプチャ時間
		}
		
		private function init(e:Event):void {	// ここから開始
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// SWF設定
			stage.frameRate = 30;
			stage.quality = StageQuality.HIGH;
			// wonderflではキャプチャに背景色が反映されないので、背景を覆う。
			var bgBitmapData:BitmapData = new BitmapData(STAGE_W, STAGE_H, false, 0x888888);
			addChild(new Bitmap(bgBitmapData));
			
			_bgSprite = new Sprite();
			addChild(_bgSprite);
			
			_mainSprite = new Sprite();
			_display = new Bitmap();
			_display.filters = [_shadow];
			addChild(_display);
			_particle = new Bitmap();
			_particle.blendMode = BlendMode.ADD;
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
			
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, bgLoadEnd);
			_loadNumMax++;
			loader.load(new URLRequest(_BG_URL), context);
		}
		
		private function cardLoadEnd(e:Event):void{
			_cardDisplayList.push(e.target.content);
			countUp();
		}
		private function bgLoadEnd(e:Event):void{
			_bgSprite.addChild(e.target.content);
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
			_effectCount = 0;
			addEventListener(Event.ENTER_FRAME, frame);
		}
		
		private function frame(e:Event):void{
			_effectCount++;
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
			_fire.copyChannel(_baseData, _rect, _point, BitmapDataChannel.ALPHA, BitmapDataChannel.ALPHA);
			_particleMask.copyPixels(_fire, _rect, _point, null, null, true);
			_particleMask.copyPixels(_noise, _rect, _point, null, null, true);
			
			_particleFire.copyPixels(_fireClear, _rect, _point);
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











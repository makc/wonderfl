package 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.filters.BlurFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	import flash.utils.Timer;
	import frocessing.color.ColorHSV;
	import idv.cjcat.stardust.common.clocks.SteadyClock;
	import idv.cjcat.stardust.twoD.renderers.PixelRenderer;
	
	/**
	 * マウスぐりぐり動かすと楽しいかも
	 * @author paq89
	 */
	[SWF(width = 465, height = 465, backgroundColor = 0x000000, frameRate = 60)]
	public class Main extends Sprite 
	{
		private static const ZERO_POINT:Point = new Point(0, 0);
		private static const STAGE_RECT:Rectangle = new Rectangle(0, 0, 465, 465);
		
		private var _bitmap:Bitmap;
		private var _bitmapData:BitmapData;
		private var _blurBitmap:Bitmap;
		private var _blurBitmapData:BitmapData;
		private var _emitter:PixelEmitter;
		private var _forcemap:BitmapData;
		private var _blur:BlurFilter;
		private var _color:uint;
		private var _hsv:ColorHSV;
		
		/**
		 * コンストラクタ
		 */
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			// 変数を初期化
			_blur = new BlurFilter(2, 2, 1);
			_color = 0;
			
			// 背景
			graphics.beginFill(0x000000); graphics.drawRect(0, 0, 465, 465);
			
			// 画質を低にする
			stage.quality = StageQuality.LOW;
			
			// パーティクルシステムの構築
			initStardust();
			
			// イベントリスナー
			addEventListener(Event.ENTER_FRAME, loop);
		}
		
		private function initStardust():void
		{
			// パーティクルを表示するビットマップを作成
			_bitmapData = new BitmapData(465, 465, true, 0x00000000);
			_bitmap = new Bitmap(_bitmapData);
			_blurBitmapData = new BitmapData(465, 465, false, 0x000000);
			_blurBitmap = new Bitmap(_blurBitmapData);
			addChild(_blurBitmap);
			addChild(_bitmap);
			
			_emitter = new PixelEmitter(new SteadyClock(3));
			_hsv = new ColorHSV(_color, 0.7);
			var renderer:PixelRenderer = new PixelRenderer(_bitmapData);
			renderer.addEmitter(_emitter);
			
			_forcemap = new BitmapData(465, 465);
			var timer:Timer = new Timer(1500);
			timer.addEventListener(TimerEvent.TIMER, tick);
			timer.start();
			tick();
		}
		
		/*
		 * エンターフレームイベント
		*/
		private function loop(e:Event):void 
		{
			// パーティクルの色を変更
			_color++;
			_hsv.h = _color;
			_emitter.color.color = _hsv.value;
			
			// 残像エフェクト
			_blurBitmapData.draw(_bitmapData);
            _blurBitmapData.applyFilter(_blurBitmapData, STAGE_RECT, ZERO_POINT, _blur);
			_bitmapData.fillRect(STAGE_RECT, 0x00000000);
			
			// エミッター更新
			_emitter.step();
			
			// エミッターの速度をマウス位置に合わせて変更
			_emitter.stepTimeInterval = mouseY*0.01;
		}
		
		/*
		 * タイマーイベント
		*/
		private function tick(e:TimerEvent = null):void 
		{
			// フォースマップを作成
			_forcemap.perlinNoise(100, 100, 2, getTimer(), true, true, BitmapDataChannel.RED | BitmapDataChannel.GREEN);
			
			// フォースマップをエミッターに適用
			_emitter.field.update(_forcemap);
		}
	}
	
}
import idv.cjcat.stardust.common.actions.Age;
import idv.cjcat.stardust.common.actions.DeathLife;
import idv.cjcat.stardust.common.clocks.Clock;
import idv.cjcat.stardust.common.initializers.Color;
import idv.cjcat.stardust.common.initializers.Life;
import idv.cjcat.stardust.common.initializers.Mass;
import idv.cjcat.stardust.common.math.UniformRandom;
import idv.cjcat.stardust.twoD.actions.Deflect;
import idv.cjcat.stardust.twoD.actions.Gravity;
import idv.cjcat.stardust.twoD.actions.Move;
import idv.cjcat.stardust.twoD.actions.SpeedLimit;
import idv.cjcat.stardust.twoD.deflectors.WrappingBox;
import idv.cjcat.stardust.twoD.emitters.Emitter2D;
import idv.cjcat.stardust.twoD.fields.BitmapField;
import idv.cjcat.stardust.twoD.initializers.Position;
import idv.cjcat.stardust.twoD.initializers.Velocity;
import idv.cjcat.stardust.twoD.zones.LazySectorZone;
import idv.cjcat.stardust.twoD.zones.SinglePoint;


class PixelEmitter extends Emitter2D
{
	public var field:BitmapField;
	public var color:Color;
	
	public function PixelEmitter(clock:Clock):void 
	{
		super(clock);
		
		color = new Color();
		addInitializer(color);
		addInitializer(new Position(new SinglePoint(232.5, 232.5)));
		addInitializer(new Mass(new UniformRandom(3, 1)));
		addInitializer(new Velocity(new LazySectorZone(10, 4)));
		addInitializer(new Life(new UniformRandom(200, 0)));
			
		field = new BitmapField(0, 60);
		field.massless = false;
		var gravity:Gravity = new Gravity();
		gravity.addField(field);
		
		var deflect:Deflect = new Deflect();
		deflect.addDeflector(new WrappingBox(0, 0, 465, 465));
		
		addAction(gravity);
		addAction(deflect);
		addAction(new Move());
		addAction(new Age());
		addAction(new DeathLife());
		addAction(new SpeedLimit(2));
	}
}
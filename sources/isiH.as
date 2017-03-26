package{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.system.Security;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	/**
	 * しっぽ流デザインパターン講座（F-site講演資料）
	 * （http://sipo.jp/blog/2010/11/f-site.html）
	 * で使用されているエフェクト効果です。
	 * 文字や絵が何もしなくても手が込んでる感じになるので
	 * とても便利です。
	 * 文字は入力可能。
	 */
	public class TearPaperEffect extends Sprite{
		public function TearPaperEffect(){
			WonderflTemplate.Initialize(this, Initialize, 20, 0x888888, 5);
		}
		
		private var _bg:Loader;
		private var _clear:BitmapData;
		private var _display:BitmapData;
		private var _point:Point = new Point();
		private var _rect:Rectangle = new Rectangle(0, 0, WonderflTemplate.WIDTH, WonderflTemplate.HEIGHT);
		
		private var _hide:Sprite;	// 表示されない部分（マウスの入力を受け取る）
		private var _original:Sprite;	// 描画される元となる部分
		private var _displayBmp:Bitmap;	// 実際に表示される部分
		
		private var _tf:TextField;
		
		private var _glow:GlowFilter = new GlowFilter(0xffffff, 1, 16, 16, 2, 2);
		private var _subGlow:GlowFilter = new GlowFilter(0xffffff, 1, 2, 2, 2, 2);
		private var _shadow:DropShadowFilter = new DropShadowFilter(5, 90, 0x000000, 0.8, 16, 16);
		
		public function Initialize():void{
			_clear = new BitmapData(WonderflTemplate.WIDTH, WonderflTemplate.HEIGHT, true, 0x00000000);
			_display = _clear.clone();
			
			_bg = new Loader();
			Security.loadPolicyFile("http://asset.sipo.jp/wonderfl/crossdomain.xml");
			_bg.load(new URLRequest("http://asset.sipo.jp/wonderfl/img/tearPaperEffect/greenDot.jpg"));
			addChild(_bg);
			
			_hide = new Sprite();
			_original = new Sprite();
			_displayBmp = new Bitmap(_display);
			_displayBmp.smoothing = true;

			addChild(_displayBmp);
			addChild(_hide);
			_hide.addChild(_original);
			_hide.alpha = 0;
			
			_tf = new TextField();
			_tf.x = 0;
			_tf.y = 180;
			_tf.width = WonderflTemplate.WIDTH;
			_tf.height = WonderflTemplate.HEIGHT;
			_tf.type = TextFieldType.INPUT;
			_tf.multiline = true;
			var format:TextFormat = _tf.getTextFormat();
			format.size = 40;
			format.align = TextFormatAlign.CENTER;
			_tf.defaultTextFormat = format;
			_tf.text = "TearPaperEffect\n破れた紙効果";
			_original.addChild(_tf);
			stage.focus = _tf;
			_tf.setSelection(_tf.text.length, _tf.text.length);
			
			draw();
			addEventListener(Event.ENTER_FRAME, frame);
		}
		
		private function frame(event:Event):void{
			draw();
		}
		
		/* メイン処理*/
		private function draw():void{
			var originalBmd:BitmapData = _clear.clone();
			originalBmd.draw(_original);
			_display.applyFilter(originalBmd, _rect, _point, _glow);
			_display.threshold(_display, _rect, _point, ">", 0x00000000, 0xffffffff, 0xff000000, true);
			_display.applyFilter(_display, _rect, _point, _subGlow);
			_display.applyFilter(_display, _rect, _point, _shadow);
			_display.copyPixels(originalBmd, _rect, _point, null, null, true);
		}
	}
}

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.Event;


/* 初期化テンプレート*/
class WonderflTemplate{
	public static const WIDTH:int = 465;
	public static const HEIGHT:int = 465;
	
	private static var _target:Sprite;
	private static var _handler:Function;
	
	public static function Initialize(target:Sprite, handler:Function, fps:Number, bgColor:uint, captureDelay:int):void{
		_target = target;
		_handler = handler;

		target.stage.frameRate = fps;
		
		var bg:Bitmap = new Bitmap(new BitmapData(WIDTH, HEIGHT, false, bgColor));
		target.addChild(bg);

		Wonderfl.capture_delay(captureDelay);
		
		target.addEventListener(Event.ADDED_TO_STAGE, addToStageHandler);
	}
	private static function addToStageHandler(event:Event):void{
		_target.removeEventListener(Event.ADDED_TO_STAGE, addToStageHandler);
		_handler();
	}
}
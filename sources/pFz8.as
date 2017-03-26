/**
 * 
 * @author yooKo@selflash
 * @version 1.0
 *
 * パーティクルで時計
 * クリックで別画像に切り替え可
 * Let's click!
 * 最適化してないから重いかも・・
 *
 * メモリリークしてるな～
 *
 * 2009/9/26 
 * 少し改変。Loaderからdraw()できなかった件で
 * ton1517のForkしてくれたやつではなぜかすんなりいってた、、orz
 * 本来やりたかった画像の切り替えを３っつに増やした。
 */
package {
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFieldAutoSize;
	import flash.display.Sprite;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.filters.BlurFilter;
	import flash.geom.ColorTransform;
	import flash.filters.BitmapFilterQuality;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.events.MouseEvent;
	import flash.system.LoaderContext;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	import net.hires.debug.Stats;
	
	[SWF(width = "500", height = "500", backgroundColor = "#000000", frameRate = "60")]
	
	public class RyukyuClock extends Sprite {
		private const IMAGE_URL:String = "http://assets.wonderfl.net/images/related_images/7/77/778c/778cc2dcf7decc4d18424bf5d6344fe25ccebbaf";
		private const PARTICLE_MAX:int = 10000;
		private const TRANSFORM_COLOR:ColorTransform = new ColorTransform(1, 1, 1, .95, 0, 0, 0, 0);	
		private const FILTER_BLUR:BlurFilter = new BlurFilter(4, 4, BitmapFilterQuality.LOW);
                private const POINT:Point = new Point();	
		private const DEGREE:Number = 1;
	    private const RADIAN:Number = DEGREE * Math.PI / 180;
		private const COS_RADIAN:Number = Math.cos(RADIAN);
		private const SIN_RADIAN:Number = Math.sin(RADIAN);
		
		private var _startTime:int ;
		private var _loader:Loader;
		private var _currentNum:int = 0;
		private var _maineParticles:Array = [];
		private var _particlesList:Array = [];
		private var _clock:Clock;
		private var _canvas:BitmapData;
		
		//========================================================================
		// コンストラクタ
		//========================================================================
		public function RyukyuClock() {
			_loader = new Loader();  
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadComplete);
			_loader.load(new URLRequest(IMAGE_URL), new LoaderContext(true));		
		}
		
		//========================================================================
		// Loader読み込み完了後の処理
        //========================================================================
        private function loadComplete(e:Event):void {
			var o:LoaderInfo = e.target as LoaderInfo;
			o.removeEventListener(Event.COMPLETE, loadComplete);
			
			var bmd:BitmapData = new BitmapData(o.content.width, o.content.height, false, 0x000000);
			bmd.draw(_loader);
			_particlesList.push(createParticle(bmd));
			_loader.unload();
			
			init();
		}
		
		//========================================================================
		// 初期化
		//========================================================================
		private function init():void {
			var tf:TextField = new TextField();
			tf.defaultTextFormat = new TextFormat("_sans", 30, 0xFFFFFF); 
			tf.autoSize = TextFieldAutoSize.LEFT;
			tf.text = "http://selflash.jp";
			
			_canvas = new BitmapData(stage.stageWidth, stage.stageHeight, false, 0x000000);
			addChild(new Bitmap(_canvas));
			
			createMainParticle();
			
			_clock = new Clock();			
			upDate();
			_clock.addEventListener(Event.CHANGE, upDate);
			
			var bmd:BitmapData = new BitmapData(tf.width, tf.height, false, 0x000000);
			bmd.draw(tf);
			_particlesList.push(createParticle(bmd));	
			
			var timer:Timer = new Timer(1);
			timer.addEventListener(TimerEvent.TIMER, loop);
			timer.start();
			
			stage.addEventListener(MouseEvent.CLICK, onClick);
			
			addChild(new Stats());	
		}
		
		//========================================================================
		// メインで使うパーティクルを作成
		//========================================================================
		private function createMainParticle():void {
			for (var i:int = 0; i < PARTICLE_MAX; i++) {
				var p:Particle = new Particle();
				var rad:Number = Math.random() * ( Math.PI * 2 );
				p.x = stage.stageWidth / 2 + 150 * Math.cos( rad );
				p.y = stage.stageHeight / 2 + 150 * Math.sin( rad );
				p.ex = p.x;
				p.ey = p.y;
				p.tx = p.x;
				p.ty = p.y;
				p.c = 0xFFFFFF;
				_maineParticles.push(p);
			}
		}
					
		//========================================================================
		// 実行される度に時計の表示に必要なパーティクルを作り直す		
		//========================================================================
		private function upDate(e:Event = null):void {
			var o:Sprite = _clock;
			var bmd:BitmapData = new BitmapData(o.width, o.height, false, 0x000000);
			bmd.draw(o);

			_particlesList[1] = createParticle(bmd);	
		}		

		//========================================================================
		//  引数のBitmapDataのパーティクルを作成して返す
		//========================================================================
		private function createParticle(bmd:BitmapData):Array {
			var particles:Array = [];
			for ( var _x:Number = 0; _x < bmd.width; _x++ ) {
				for ( var _y:Number = 0; _y < bmd.height; _y++ ) {
					var c:uint = bmd.getPixel( _x, _y );
					if ( c != 0x000000 ) {
						var p:Particle = new Particle();
						p.x = _x + stage.stageWidth / 2 - bmd.width / 2;
						p.y = _y + stage.stageHeight / 2 - bmd.height / 2;
						p.c = c;						
						particles.push( p );
					}
				}
			}
			return particles;
		}
				
		//========================================================================
		// loopメソッド
		//========================================================================
		private function loop(e:TimerEvent):void {
			var wait:Number;
			var now:int = getTimer();
			
			_canvas.lock();
			_canvas.colorTransform(_canvas.rect, TRANSFORM_COLOR);
			_canvas.applyFilter(_canvas, _canvas.rect, POINT, FILTER_BLUR);	
			for ( var i:int = 0; i < PARTICLE_MAX; i++ ) {
				var p:Particle = _maineParticles[i];
				var _x:Number = p.ex - stage.stageWidth / 2;
				var _y:Number = p.ey - stage.stageHeight / 2;
				var x1:Number = COS_RADIAN * _x - SIN_RADIAN * _y;
				var y1:Number = COS_RADIAN * _y + SIN_RADIAN * _x;
				p.ex = stage.stageWidth / 2 + x1 + ((Math.random() - .5) * .5);
				p.ey = stage.stageHeight / 2 + y1 + ((Math.random() - .5) * .5);			
				if (_particlesList[_currentNum][i]) {
					var cp:Particle = _particlesList[_currentNum][i]; 
					wait = ( 1 - ( cp.x / 350  ) ) * 4000;
					if ( _startTime + wait > now ) continue ; 	
					
					if (Math.abs(cp.x - p.x) < .5 && Math.abs(cp.y - p.y) < .5) {
						p.x = cp.x;
						p.y = cp.y;
					}else {
						p.x += (cp.x - p.x) * .08;
						p.y += (cp.y - p.y) * .08;
					}
				}else {
					if (Math.abs(p.ex - p.x) < .5 && Math.abs(p.ey - p.y) < .5) {
						p.x = p.ex;
						p.y = p.ey;
					}else {
						p.x += (p.ex - p.x) * .05;
						p.y += (p.ey - p.y) * .05;
					}
				}
				_canvas.setPixel( p.x, p.y, p.c );
			}	
			_canvas.unlock();
		}
		
		//========================================================================
		// クリック時の処理		
		//========================================================================
		private function onClick(e:MouseEvent = null):void {
			_startTime = getTimer();
			(_currentNum < 2) ? _currentNum++ : _currentNum = 0;			
			
			shuffle(_maineParticles);
		}
		
		//========================================================================
		// 引数で渡された配列の中身をシャッフルする
		//========================================================================
		private function shuffle(list:Array):void{
			var i:int = list.length;
			while (--i) {
				var j:Number = Math.floor(Math.random() * (i + 1));
				if (i == j) continue;
				var k:Particle = list[i];
				list[i] = list[j];
				list[j] = k;
			}
		}		
	}
}


//========================================================================
// Particleクラス
//========================================================================
class Particle {
	public var x:Number = 0;
	public var y:Number = 0;
	public var tx:Number = 0;
	public var ty:Number = 0;
	public var ex:Number = 0;
	public var ey:Number = 0;
	public var c:int = 0;
}

//========================================================================
// Clockクラス
//========================================================================
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.TimerEvent;
import flash.text.TextField;
import flash.events.Event;
import flash.text.TextFormat;
import flash.text.TextFieldAutoSize;
import flash.utils.Timer;
	
class Clock extends Sprite {
		// 各テキストフィールド	
		private var _hoursField:TextField;
		private var _minutesField:TextField;
		private var _secondsField:TextField;
		private var _dotField:TextField;
		private var _txtFormat:TextFormat;
		// 時刻
		private var _hours:String;
		private var _minutes:String;
		private var _seconds:String;
		// TeraClock
		private var _clock:TeraClock;
		
		public function Clock() {
			// テキストフォーマット		
			_txtFormat = new TextFormat();
			_txtFormat.font = "BPdotsUnicaseSquare"
			_txtFormat.size = 39;
			_txtFormat.color = 0xFFFFFF;
			_txtFormat.kerning = true;			
			// 時を表示するテキストフィールドを作成する			
			_hoursField = new TextField();
			_txtFormat.size = 60;
			_hoursField.defaultTextFormat = _txtFormat;
			_hoursField.autoSize = TextFieldAutoSize.LEFT;
			_hoursField.x = 13;
			_hoursField.y = 10;
			this.addChild(_hoursField);				
			// 分を表示するテキストフィールドを作成する	
			_minutesField = new TextField();
			_minutesField.defaultTextFormat = _txtFormat;
			_minutesField.x = 103;
			_minutesField.y = 10;
			this.addChild(_minutesField);			
			// 秒を表示するテキストフィールドを作成する			
			_secondsField = new TextField();
			_secondsField.defaultTextFormat = _txtFormat;
			_secondsField.x = 190;
			_secondsField.y = 10;
			this.addChild(_secondsField);			
			// コロンを表示するテキストフィールドを作成する	
			_dotField = new TextField();
			_dotField.defaultTextFormat = _txtFormat;
			_dotField.text = ":";
			_dotField.x = 75;
			_dotField.y = 10;
			this.addChild(_dotField);			
			_dotField = new TextField();
			_dotField.defaultTextFormat = _txtFormat;
			_dotField.text = ":";
			_dotField.x = 165;
			_dotField.y = 10;
			this.addChild(_dotField);			
			// TeraClockを使用して時計の表示を更新する
			_clock = new TeraClock();
			_hoursField.text = _clock.hours2;
			_minutesField.text = _clock.minutes2;			
			_secondsField.text = _clock.seconds2;			
			
			_clock.addEventListener(TeraClock.HOURS_CHANGED, _hoursChangeHandler);
			_clock.addEventListener(TeraClock.SECONDS_CHANGED, _secondsChangeHandler);
			_clock.addEventListener(TeraClock.MINUTES_CHANGED, _minutesChangeHandler);
			
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		// 1時間毎に表示を更新してCHANGEイベントをdispatchする。		
		private function _hoursChangeHandler(e:Event):void {
			_hoursField.text = _clock.hours2;	
			dispatchEvent(new Event(Event.CHANGE));		
		}		
		// 1分毎に表示を更新してCHANGEイベントをdispatchする。	
		private function _minutesChangeHandler(e:Event):void {
			_minutesField.text = _clock.minutes2;	
			dispatchEvent(new Event(Event.CHANGE));			
		}		
		// 1秒毎に表示を更新してCHANGEイベントをdispatchする。		
		private function _secondsChangeHandler(e:Event):void {
			_secondsField.text = _clock.seconds2;			
			dispatchEvent(new Event(Event.CHANGE));
		}
}














/***********************************************************************************************************************
//========================================================================
// これより下trick7さんのTeraClockライブラリの中身をそのまま記述
//========================================================================

/**
 * trick7さんのTeraClockライブラリ
 * @author tera 
 * ソース　
 * http://www.trick7.com/blog/2008/09/02-074335.php
 */

import flash.display.*;
import flash.events.Event;
import flash.events.EventDispatcher;	

class TeraClock extends Sprite {
		public static const HOURS_CHANGED:String = "hoursChanged";
		public static const MINUTES_CHANGED:String = "minutesChanged";
		public static const SECONDS_CHANGED:String = "secondsChanged";
		private var _hours:int;
		private var _minutes:int;
		private var _seconds:int;
		private var _preSeconds:int;
		private var _gmt:int;
		public function TeraClock(GMT:int = 9) {
			_gmt = GMT%24;
			this.enterFrameListener(null);
			addEventListener(Event.ENTER_FRAME, enterFrameListener);
		}
		
		private function enterFrameListener(e:Event):void {
			var date:Date = new Date();
			if(_gmt>=0){
				_hours = (date.getUTCHours() + _gmt) % 24;
			}else {
				_hours = (24+(date.getUTCHours() + _gmt)) % 24;
			}
			_minutes = date.getUTCMinutes();
			_seconds = date.getUTCSeconds();
			if (_seconds != _preSeconds) {
				dispatchEvent(new Event(SECONDS_CHANGED));
				if (_seconds == 0) {
					dispatchEvent(new Event(MINUTES_CHANGED));
					if (_minutes == 0) {
						dispatchEvent(new Event(HOURS_CHANGED));
					}
				}
			}
			_preSeconds = _seconds;
		}
		public function get hours():int { return _hours; }
		public function get minutes():int { return _minutes; }
		public function get seconds():int { return _seconds; }
		public function get milliseconds():int { return (new Date()).getUTCMilliseconds(); }
		
		public function get hoursUpper():int { return _hours / 10; }
		public function get minutesUpper():int { return _minutes / 10; }
		public function get secondsUpper():int { return _seconds / 10; }
		
		public function get hoursLower():int { return _hours % 10; }
		public function get minutesLower():int  { return _minutes % 10; }
		public function get secondsLower():int { return _seconds % 10; }
		
		public function get hours2():String { return niketa(_hours); }
		public function get minutes2():String { return niketa(_minutes); }
		public function get seconds2():String { return niketa(_seconds); }
		
		public function get milliseconds2():String { return niketa((new Date()).getUTCMilliseconds() / 10); }
		
		public function get milliseconds3():String { return keta((new Date()).getUTCMilliseconds(), 3); }
		
		private function niketa(num:int):String {
			if (num < 10) {
				return String("0"+num);
			}else {
				return String(num);
			}
		}
		
		private function keta(num:int, keta:int):String {
			var str:String = String(num);
			while(str.length < keta) str = "0" + str;
			return str;
		}
		
		public function get hoursDegree():Number {
			return ((_hours % 12) * 30) + (_minutes / 2) + (_seconds/120);
		}
		public function get minutesDegree():Number {
			return (_minutes * 6) + (_seconds / 10);
		}
		public function get secondsDegree():Number {
			return _seconds * 6;
		}
		
		public function getDifferenceTime(s:int, m:int, h:int):Object {
			var time:Array = [_seconds, _minutes, _hours, 0];
			var dt:Array   = [s, m, h];
			var cap:Array  = [60, 60, 24];
			for(var i:int = 0; i < 3; ++i) {
				time[i] += dt[i];
				if(time[i] < 0) {
					time[i + 1] += Math.floor(time[i] / cap[i]);
					time[i] = time[i] % cap[i] + cap[i];
					continue;
				}
				if(time[i] >= cap[i]) {
					time[i + 1] += Math.floor(time[i] / cap[i]);
					time[i] = time[i] % cap[i];
					continue;
				}
			}
			return { seconds:time[0], minutes:time[1], hours:time[2], date:time[3] };
		}
}
	




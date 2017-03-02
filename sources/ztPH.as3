////////////////////////////////////////////////////////////////////////////////
// マウスを避けるドット(ロゴ)
////////////////////////////////////////////////////////////////////////////////

package {

	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.net.URLRequest;
	import flash.system.Security;
	import flash.events.Event;
	import flash.geom.Rectangle;

	[SWF(backgroundColor="#000000", width="465", height="465", frameRate="30")]

	public class Main extends Sprite {
		private var loader:Loader;
		private static var filePath:String = "http://www.project-nya.jp/images/flash/logo.swf";
		private var content:MovieClip;
		private static var sw:uint = 465;
		private static var sh:uint = 465;
		private static var tw:uint = 420;
		private static var th:uint = 200;
		private var escapeDot:EscapeDot;

		public function Main() {
			Wonderfl.capture_delay(4);
			init();
		}

		private function init():void {
			graphics.beginFill(0x000000);
			graphics.drawRect(0, 0, 465, 465);
			graphics.endFill();
			Security.allowDomain("www.project-nya.jp");
			// 読み込む logo.swf に以下のスクリプトを記述
			// Security.allowDomain("wonderfl.net");
			// Security.allowDomain("swf.wonderfl.net");
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.INIT, initialize, false, 0, true);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, complete, false, 0, true);
			try {
				loader.load(new URLRequest(filePath));
			} catch (err:Error) {
				trace(err.message);
			}
			var rect:Rectangle = new Rectangle(0, 0, sw, sh);
			escapeDot = new EscapeDot(rect);
			addChild(escapeDot);
		}
		private function initialize(evt:Event):void {
			content = MovieClip(loader.content);
			content.x = uint((sw - tw)/2);
			content.y = uint((sh - th)/2);
			//addChild(content);
			escapeDot.setTarget(content);
			escapeDot.start();
		}
		private function complete(evt:Event):void {
			loader.contentLoaderInfo.removeEventListener(Event.INIT, initialize);
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, complete);
		}

	}

}


import flash.display.Sprite;
import flash.display.MovieClip;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.Rectangle;
import flash.events.Event;

class EscapeDot extends Sprite {
	private var rect:Rectangle;
	private static var tw:uint = 420;
	private static var th:uint = 200;
	private static var accuracy:uint = 2;
	private var detection:DetectDot;
	private var target:MovieClip;
	private var area:Rectangle;
	private static var threshold:uint = 0x80FFFFFF;
	private var map:Array;
	private var dots:Array;
	private var canvas:BitmapData;
	private static var radius:uint = 150;
	private static var acceleration:Number = 0.1;
	private static var deceleration:Number = 0.2;

	public function EscapeDot(r:Rectangle) {
		rect = r;
		init();
	}

	private function init():void {
		detection = new DetectDot(accuracy);
		canvas = new BitmapData(rect.width, rect.height, true, 0x00000000);
		var bitmap:Bitmap = new Bitmap(canvas);
		bitmap.x = rect.x;
		bitmap.y = rect.y;
		addChild(bitmap);
	}
	public function setTarget(t:MovieClip):void {
		target = t;
		area = new Rectangle(0, 0, tw, th);
		detection.search(target, area, threshold);
		map = detection.pixels();
		createDots();
	}
	private function createDots():void {
		dots = new Array();
		for (var n:uint = 0; n < map.length; n++) {
		var dw:uint = uint(tw + target.x*2);
		var dh:uint = uint(th + target.y*2);
		var tx:uint = map[n].x + target.x + accuracy/2;
		var ty:uint = map[n].y + target.y + accuracy/2;
		var dot:Dot = new Dot(tx, ty);
		dot.id = n;
		dot.x = Math.floor(Math.random()*dw);
		dot.y = Math.floor(Math.random()*dh);
		dots.push(dot);
		}
	}
	public function start():void {
		addEventListener(Event.ENTER_FRAME, draw, false, 0, true);
	}
	public function stop():void {
		removeEventListener(Event.ENTER_FRAME, draw);
	}
	private function draw(evt:Event):void {
		canvas.lock();
		canvas.fillRect(canvas.rect, 0x00000000);
		for (var n:uint = 0; n < dots.length; n++) {
		var dot:Dot = dots[n];
		var angle:Number = Math.atan2(dot.y - mouseY, dot.x - mouseX);
		var distance:Number = Math.sqrt(Math.pow(mouseX - dot.x, 2) + Math.pow(mouseY  - dot.y, 2));
		var circle:Number = radius/distance;
		if (distance < 50) {
			dot.x += circle*Math.cos(angle) + (dot.tx - dot.x)*acceleration;
			dot.y += circle*Math.sin(angle) + (dot.ty - dot.y)*acceleration;
		} else {
			dot.x += (dot.tx - dot.x)*deceleration;
			dot.y += (dot.ty - dot.y)*deceleration;
			if (Math.abs(dot.tx - dot.x) < 0.5 && Math.abs(dot.ty - dot.y) < 0.5) {
			dot.x = dot.tx;
			dot.y = dot.ty;
			}
		}
		canvas.setPixel32(dot.x, dot.y, 0xFFFFFFFF);
		}
		canvas.unlock();
	}

}


import flash.display.Sprite;
import flash.display.BitmapData;
import flash.geom.Rectangle;
import flash.geom.Point;
import flash.geom.Matrix;
import flash.display.MovieClip;

class DetectDot extends Sprite {
	private var target:MovieClip;
	private var rect:Rectangle;
	private var map:BitmapData;
	private var mapList:Array;
	private var accuracy:uint;
	private var threshold:uint = 0x80FFFFFF;

	public function DetectDot(a:uint = 1) {
		accuracy = a;
	}

	public function search(t:MovieClip, r:Rectangle, th:uint = 0x80FFFFFF):void {
		target = t;
		rect = r;
		threshold = th;
		var w:uint = rect.width/accuracy;
		var h:uint = rect.height/accuracy;
		detect(w, h);
	}
	private function detect(w:uint, h:uint):void {
		map = new BitmapData(w, h, true, 0x00000000);
		var matrix:Matrix = new Matrix();
		matrix.scale(1/accuracy, 1/accuracy);
		map.lock();
		map.draw(target, matrix);
		map.unlock();
		mapList = new Array();
		for (var x:uint = 0; x < w; x++) {
		for (var y:uint = 0; y < h; y++) {
			var color:uint = map.getPixel32(x, y);
			if (color >= threshold) {
			var px:int = x*accuracy + rect.x;
			var py:int = y*accuracy + rect.y;
			var point:Point = new Point(px, py);
			mapList.push(point);
			}
		}
		}
	}
	public function pixels():Array {
		return mapList;
	}

}


class Dot {
	public var id:uint;
	public var x:Number = 0;
	public var y:Number = 0;
	public var tx:Number = 0;
	public var ty:Number = 0;

	public function Dot(px:Number, py:Number) {
		tx = px;
		ty = py;
	}

}

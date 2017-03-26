// forked from ProjectNya's ズキュウウウンひよこ(改)
// forked from ProjectNya's ズキュウウウンひよこ
// forked from ahchang's ズキュウウウン
// forked from minon's 漫画っぽい集中線
/**
 * ジョジョのディオのあれ
 * @author minon
 */
////////////////////////////////////////////////////////////////////////////////
// ひよこちゃんズキュウウウン(改)
////////////////////////////////////////////////////////////////////////////////
//　ごめんなさい
package {

	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.display.Loader;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;

	[SWF(backgroundColor="#FFFFFF", width="465", height="465", frameRate="30")]

	public class Main extends Sprite {
		private var loader:Loader;
		private static var chickPath:String = "http://www.project-nya.jp/images/flash/chick.swf";
		private var trianglelines:TriangleLines;

		public function Main() {
			//Wonderfl.capture_delay(1);
			init();
		}

		private function init():void {
			var sky:Sky = new Sky(465, 350);
			addChild(sky);
			var ground:Ground = new Ground(465, 115);
			addChild(ground);
			ground.y = 350;
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, complete, false, 0, true);
			loader.load(new URLRequest(chickPath), new LoaderContext(true));
			addChild(loader);
			loader.x = 232;
			loader.y = 380;
			loader.scaleX = loader.scaleY = 5;
			var rect:Rectangle = new Rectangle(0, 0, 465, 465);
			trianglelines = new TriangleLines(rect, 0x000000);
			addChild(trianglelines);
		}
		private function complete(evt:Event):void {
			var hiyo:MovieClip = loader.content as MovieClip;
			hiyo.scaleX = hiyo.scaleY = 0.6;
			var body:MovieClip = hiyo.getChildAt(1) as MovieClip;
			body.getChildAt(1).rotation = 130;
			body.getChildAt(2).rotation = -130;
			body.getChildAt(1).y = -77;
			body.getChildAt(2).y = -77;
			var head:MovieClip = body.getChildAt(3) as MovieClip;
			head.y -= 65;
			head.rotation = 180;
			head.getChildAt(1).y += 10;
			head.getChildAt(2).y += 10;
			trianglelines.start();
		}

	}

}


import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Rectangle;
import flash.display.BitmapData;
import flash.display.Bitmap;
import flash.display.Graphics;
import flash.geom.Matrix;

class TriangleLines extends Sprite {
	private var rect:Rectangle;
	private var canvas:BitmapData;
	private static var radian:Number = Math.PI/180;
	private var color:uint;

	public function TriangleLines(r:Rectangle, c:uint) {
		rect = r;
		color = c;
		init();
	}

	private function init():void {
		canvas = new BitmapData(rect.width, rect.height, true, 0x00000000);
		addChild(new Bitmap(canvas));
	}
	public function start():void {
		drawLines();
		addEventListener(Event.ENTER_FRAME, update, false, 0, true);
	}
	private function update(evt:Event):void {
		canvas.lock();
		canvas.fillRect(rect, 0x00000000);
		drawLines();
		canvas.unlock();
	}
	private function drawLines():void {
		var line:Sprite = new Sprite();
		drawTriangle(line.graphics);
		var a:uint = 2;
		var rw:uint = rect.width;
		var rh:uint = rect.height;
		var length:uint = rw/2*Math.sqrt(2);
		for (var n:uint = 0; n < 360; n += Math.round(Math.random()*a)) {
			var dx:Number = Math.sin(n*radian)*length + rw/2;
			var dy:Number = Math.cos(n*radian)*length + rh/2;
			var matrix:Matrix = new Matrix();
			matrix.scale(5, Math.random()*length + length/2);
			matrix.rotate(-n*radian);
			matrix.translate(dx, dy);
			canvas.draw(line, matrix, null, null, null, false);
		}
		line = null;
	}
	private function drawTriangle(g:Graphics):void {
		g.beginFill(color);
		g.moveTo(-0.5, 0);
		g.lineTo(0.5, 0);
		g.lineTo(0, -0.5);
		g.lineTo(-0.5, 0);
		g.endFill();
	}

}


import flash.display.Shape;
import flash.geom.Matrix;
import flash.display.GradientType;

class Sky extends Shape {
	private static var _width:uint;
	private static var _height:uint;
	private static var color1:uint = 0x3F68AB;
	private static var color2:uint = 0x77B2EE;

	public function Sky(w:uint, h:uint) {
		_width = w;
		_height = h;
		draw();
	}

	private function draw():void {
		var colors:Array = [color1, color2];
		var alphas:Array = [1, 1];
		var ratios:Array = [0, 255];
		var matrix:Matrix = new Matrix();
		matrix.createGradientBox(_width, _height, 0.5*Math.PI, 0, 0);
		graphics.beginGradientFill(GradientType.LINEAR, colors, alphas, ratios, matrix);
		graphics.drawRect(0, 0, _width, _height);
		graphics.endFill();
	}

}


import flash.display.Shape;
import flash.geom.Matrix;
import flash.display.GradientType;

class Ground extends Shape {
	private static var _width:uint;
	private static var _height:uint;
	private static var color1:uint = 0x99CC33;
	private static var color2:uint = 0x7EB133;

	public function Ground(w:uint, h:uint) {
		_width = w;
		_height = h;
		draw();
	}

	private function draw():void {
		var colors:Array = [color1, color2];
		var alphas:Array = [1, 1];
		var ratios:Array = [0, 255];
		var matrix:Matrix = new Matrix();
		matrix.createGradientBox(_width, _height, 0.5*Math.PI, 0, 0);
		graphics.beginGradientFill(GradientType.LINEAR, colors, alphas, ratios, matrix);
		graphics.drawRect(0, 0, _width, _height);
		graphics.endFill();
	}

}


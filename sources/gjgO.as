////////////////////////////////////////////////////////////////////////////////
// [AS3.0] ドットの光 (6)
// http://www.project-nya.jp/modules/weblog/details.php?blog_id=1095
////////////////////////////////////////////////////////////////////////////////

package {

	import flash.display.Sprite;
	import flash.geom.Rectangle;

	[SWF(backgroundColor="#000000", width="465", height="465", frameRate="30")]

	public class Main extends Sprite {
		private var light:DotLight;

		public function Main() {
			Wonderfl.capture_delay(60);
			init();
		}

		private function init():void {
			graphics.beginFill(0x000000);
			graphics.drawRect(0, 0, 465, 465);
			graphics.endFill();
			light = new DotLight(new Rectangle(0, 0, 465, 465));
			addChild(light);
			light.start();
		}

	}

}


import flash.display.Sprite;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.PixelSnapping;
import flash.display.BlendMode;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import flash.geom.Point;
import flash.geom.ColorTransform;
import flash.filters.BlurFilter;
import flash.events.Event;
import flash.utils.getTimer;

class DotLight extends Sprite {
	private var rect:Rectangle;
	private var canvas:BitmapData;
	private var map:BitmapData;
	private var sparkle:BitmapData;
	private var afterglow:BitmapData;
	private static var scale:uint = 4;
	private var aMatrix:Matrix;
	private var colorTrans:ColorTransform;
	private var blur:BlurFilter;
	private var sMatrix:Matrix;
	private var offsets:Array;
	private var seed:uint;
	private var light:EmitLight;

	public function DotLight(r:Rectangle) {
		rect = r;
		init();
	}

	private function init():void {
		afterglow = new BitmapData(rect.width*2/scale, rect.height*2/scale, false, 0xFF000000);
		var aBitmap:Bitmap = new Bitmap(afterglow, PixelSnapping.AUTO, true);
		aBitmap.scaleX = aBitmap.scaleY = scale/2;
		addChild(aBitmap);
		canvas = new BitmapData(rect.width, rect.height, true, 0x00000000);
		var cBitmap:Bitmap = new Bitmap(canvas);
		cBitmap.blendMode = BlendMode.ADD;
		addChild(cBitmap);
		map = new BitmapData(rect.width/scale, rect.height/scale, false, 0xFF000000);
		offsets = [new Point(), new Point()];
		seed = Math.floor(Math.random()*1000);
		sparkle = new BitmapData(rect.width/scale, rect.height/scale, true, 0x00000000);
		var sBitmap:Bitmap = new Bitmap(sparkle);
		sBitmap.smoothing = true;
		sBitmap.blendMode = BlendMode.ADD;
		sBitmap.scaleX = sBitmap.scaleY = scale;
		addChild(sBitmap);
		aMatrix = new Matrix(2/scale, 0, 0, 2/scale, 0, 0);
		colorTrans = new ColorTransform(0.1, 0.1, 0.1);
		blur = new BlurFilter(2, 2, 1);
		sMatrix = new Matrix(1/scale, 0, 0, 1/scale, 0, 0);
		light = new EmitLight(canvas, map, scale);
	}
	public function start():void {
		addEventListener(Event.ENTER_FRAME, draw, false, 0, true);
	}
	public function stop():void {
		removeEventListener(Event.ENTER_FRAME, draw);
	}
	private function draw(evt:Event):void {
		var offset:Number = getTimer()*0.05;
		offsets[0].x = offsets[1].y = offset;
		map.perlinNoise(rect.width/scale, rect.height/scale, 2, seed, true, true, 1, false, offsets);
		light.create(10);
		canvas.lock();
		canvas.fillRect(canvas.rect, 0x00000000);
		light.emit();
		canvas.unlock();
		sparkle.lock();
		sparkle.fillRect(sparkle.rect, 0x00000000);
		sparkle.draw(canvas, sMatrix);
		sparkle.unlock();
		afterglow.lock();
		afterglow.draw(canvas, aMatrix, colorTrans, BlendMode.ADD);
		afterglow.applyFilter(afterglow, afterglow.rect, new Point(), blur);
		afterglow.unlock();
	}

}


import flash.display.BitmapData;
import flash.geom.Rectangle;
import frocessing.color.ColorHSV;

class EmitLight {
	private var canvas:BitmapData;
	private var map:BitmapData;
	private var rect:Rectangle;
	private var scale:uint;
	private var cx:uint;
	private var cy:uint;
	private var radius:uint;
	private static var yScale:Number = 0.25;
	private var dots:Array;
	private static var acceleration:Number = 0.01;
	private static var gravity:Number = 0.03;
	private static var deceleration:Number = 0.008;
	private var color:ColorHSV;
	private static var length:Number = 2;
	private var manager:Bresenham;

	public function EmitLight(c:BitmapData, m:BitmapData, s:uint) {
		canvas = c;
		map = m;
		rect = canvas.rect;
		scale = s;
		cx = rect.width*0.5;
		cy = rect.height*0.85;
		radius = rect.width*0.4;
		init();
	}

	private function init():void {
		dots = new Array();
		color = new ColorHSV(0, 0.4);
		manager = new Bresenham(canvas);
	}
	public function create(max:uint):void {
		for (var n:uint = 0; n < max; n++) {
			var angle:Number = Math.random()*360;
			var power:Number = Math.random() + 0.5;
			var dot:Dot = new Dot(cx, cy, angle, power);
			dot.x = cx + Math.cos(angle*Math.PI/180)*radius;
			dot.y = cy + Math.sin(angle*Math.PI/180)*radius*yScale;
			dot.px = dot.x;
			dot.py = dot.y;
			color.h = 60;
			dot.rgb = color.value;
			dots.push(dot);
		}
	}
	public function emit():void {
		for (var n:uint = 0; n < dots.length; n++) {
			var dot:Dot = dots[n];
			var c:uint = map.getPixel(dot.x/scale, dot.y/scale);
			dot.cx += ((((c >> 16) & 0xFF) - 0x80) / 0x80)*5;
			dot.vy += gravity*dot.power;
			dot.vy *= 0.99;
			dot.vx += acceleration;
			dot.angle += dot.vx;
			dot.cy -= dot.vy;
			var px:Number = Math.cos(dot.angle*Math.PI/180)*radius;
			var py:Number = Math.sin(dot.angle*Math.PI/180)*radius*yScale;
			dot.x = dot.cx + px*(dot.energy*0.4 + 0.2);
			dot.y = dot.cy + py*(dot.energy*0.4 + 0.2);
			dot.energy -= deceleration;
			var x0:int = dot.x;
			var y0:int = dot.y;
			var x1:int = dot.x - (dot.x - dot.px)*length;
			var y1:int = dot.y - (dot.y - dot.py)*length;
			color.h = 60*dot.energy*0.5;
			dot.rgb = color.value;
			manager.draw(x0, y0, x1, y1, dot.rgb, dot.energy*0.5);
			dot.px = dot.x;
			dot.py = dot.y;
			if (dot.energy < 0) {
				dots.splice(n, 1);
				dot = null;
			}
		}
	}

}


class Dot {

	public var x:Number = 0;
	public var y:Number = 0;
	public var vx:Number = 0;
	public var vy:Number = 0;
	public var cx:Number = 0;
	public var cy:Number = 0;
	public var px:Number = 0;
	public var py:Number = 0;
	public var angle:Number = 0;
	public var power:Number = 1;
	public var energy:Number = 2;
	public var rgb:uint = 0xFFFFFF;

	public function Dot(_x:Number, _y:Number, a:Number, p:Number) {
		cx = _x;
		cy = _y;
		angle =a;
		power = p;
	}

}


import flash.display.BitmapData;

class Bresenham {

	private var canvas:BitmapData;

	public function Bresenham(c:BitmapData) {
		canvas = c;
	}

	public function draw(x0:int, y0:int, x1:int, y1:int, color:uint, alpha:Number):void {
		var steep:Boolean = Math.abs(y1 - y0) > Math.abs(x1 - x0);
		var t:int;
		if (steep) {
			t = x0;
			x0 = y0;
			y0 = t;
			t = x1;
			x1 = y1;
			y1 = t;
		}
		if (x0 > x1) {
			t = x0;
			x0 = x1;
			x1 = t;
			t = y0;
			y0 = y1;
			y1 = t;
		}
		var dx:int = x1 - x0;
		var dy:int = Math.abs(y1 - y0);
		var e:int = dx*0.5;
		var ys:int = (y0 < y1) ? 1 : -1;
		var y:int = y0;
		for (var x:int = x0; x <= x1; x++) {
			if (steep) {
				plot(y, x, color, alpha);
			} else {
				plot(x, y, color, alpha);
			}
			e = e - dy;
			if (e < 0) {
				y = y + ys;
				e = e + dx;
			}
		}
	}
	private function plot(x:int, y:int, c:uint, a:Number):void {
		canvas.setPixel32(x, y, c | ((a*0xFF) << 24));
	}

}

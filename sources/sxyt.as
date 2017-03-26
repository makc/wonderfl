////////////////////////////////////////////////////////////////////////////////
// [AS3.0] ドットの光 (8)
// http://www.project-nya.jp/modules/weblog/details.php?blog_id=1097
// 画面クリックで花火があがるよ。
////////////////////////////////////////////////////////////////////////////////

package {

	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.geom.Rectangle;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import net.hires.debug.Stats;

	[SWF(backgroundColor="#000000", width="465", height="465", frameRate="30")]

	public class Main extends Sprite {
		private var light:DotLight;
		private var counter:TextField;
		private var clicked:uint = 0;

		public function Main() {
			Wonderfl.capture_delay(8);
			init();
			addChild(new Stats());
		}

		private function init():void {
			graphics.beginFill(0x000000);
			graphics.drawRect(0, 0, 465, 455);
			graphics.beginFill(0x003366);
			graphics.drawRect(0, 450, 465, 15);
			graphics.endFill();
			light = new DotLight(new Rectangle(0, 0, 465, 450));
			addChild(light);
			stage.addEventListener(MouseEvent.CLICK, launch, false, 0, true);
			counter = new TextField();
			addChild(counter);
			counter.x = 365;
			counter.width = 100;
			counter.type = TextFieldType.DYNAMIC;
			counter.selectable = false;
			var tf:TextFormat = new TextFormat();
			tf.size = 10;
			tf.align = TextFormatAlign.RIGHT;
			counter.defaultTextFormat = tf;
			counter.textColor = 0xFFFFFF;
			counter.text = String(clicked);
		}
		private function launch(evt:MouseEvent):void {
			light.launch();
			clickedup();
		}
		private function clickedup():void {
			clicked ++;
			counter.text = String(clicked);
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

class DotLight extends Sprite {
	private var rect:Rectangle;
	private var canvas:BitmapData;
	private var glow:BitmapData;
	private var sky:BitmapData;
	private var sparkle:BitmapData;
	private var afterglow:BitmapData;
	private static var scale:uint = 4;
	private var gMatrix:Matrix;
	private var sMatrix:Matrix;
	private var aMatrix:Matrix;
	private var colorTrans:ColorTransform;
	private var blur:BlurFilter;
	private var light:EmitLight;
	private var fireworks:Array;
	private var garbage:Array;
	private var colorList:Array;

	public function DotLight(r:Rectangle) {
		rect = r;
		init();
	}

	private function init():void {
		sky = new BitmapData(rect.width, rect.height, false, 0xFF000000);
		var bitmap:Bitmap = new Bitmap(sky);
		addChild(bitmap);
		sparkle = new BitmapData(rect.width/scale, rect.height/scale, false, 0xFF000000);
		var sBitmap:Bitmap = new Bitmap(sparkle);
		sBitmap.smoothing = true;
		sBitmap.blendMode = BlendMode.ADD;
		sBitmap.scaleX = sBitmap.scaleY = scale;
		addChild(sBitmap);
		afterglow = new BitmapData(rect.width*2/scale, rect.height*2/scale, false, 0xFF000000);
		var aBitmap:Bitmap = new Bitmap(afterglow, PixelSnapping.AUTO, true);
		aBitmap.blendMode = BlendMode.ADD;
		aBitmap.scaleX = aBitmap.scaleY = scale/2;
		addChild(aBitmap);
		canvas = new BitmapData(rect.width, 20, false, 0xFF000000);
		var cBitmap:Bitmap = new Bitmap(canvas);
		cBitmap.y = rect.height - 20;
		addChild(cBitmap);
		glow = new BitmapData(rect.width/scale, 20/scale, false, 0xFF000000);
		var gBitmap:Bitmap = new Bitmap(glow, PixelSnapping.NEVER, true);
		gBitmap.scaleX = gBitmap.scaleY = scale;
		gBitmap.blendMode = BlendMode.ADD;
		gBitmap.y = rect.height - 20;
		addChild(gBitmap);
		sMatrix = new Matrix(1/scale, 0, 0, 1/scale, 0, 0);
		aMatrix = new Matrix(2/scale, 0, 0, 2/scale, 0, 0);
		colorTrans = new ColorTransform(0.05, 0.05, 0.05);
		blur = new BlurFilter(2, 2, 1);
		gMatrix = new Matrix(1/scale, 0, 0, 1/scale, 0, 0);
		light = new EmitLight(canvas);
		fireworks = new Array();
		garbage = new Array();
		colorList = new Array();
		colorList.push([0, 60]);
		colorList.push([48, 60]);
		colorList.push([60, 120]);
		colorList.push([300, 270]);
		colorList.push([180, 240]);
		addEventListener(Event.ENTER_FRAME, draw, false, 0, true);
	}
	public function launch():void {
		var firework:Fireworks = new Fireworks(sky);
		firework.id = fireworks.length;
		var colors:Array = colorList[Math.floor(Math.random()*colorList.length)];
		firework.create(colors);
		firework.addEventListener(Fireworks.COMPLETE, complete, false, 0, true);
		fireworks.push(firework);
	}
	private function draw(evt:Event):void {
		light.create(10);
		canvas.lock();
		canvas.fillRect(canvas.rect, 0x00000000);
		light.emit();
		canvas.unlock();
		if (fireworks.length > 0) {
		sky.lock();
		sky.fillRect(sky.rect, 0x00000000);
		if (garbage.length > 0) remove();
		for (var n:uint = 0; n < fireworks.length; n++) {
			var firework:Fireworks = fireworks[n];
			firework.emit();
		}
		sky.unlock();
		sparkle.lock();
		sparkle.fillRect(sparkle.rect, 0x00000000);
		sparkle.draw(sky, sMatrix);
		sparkle.unlock();
		}
		glow.lock();
		glow.draw(canvas, gMatrix);
		glow.unlock();
		afterglow.lock();
		afterglow.draw(sky, aMatrix, colorTrans, BlendMode.ADD);
		afterglow.applyFilter(afterglow, afterglow.rect, new Point(), blur);
		afterglow.unlock();
	}
	private function complete(evt:Event):void {
		var firework:Fireworks = Fireworks(evt.target);
		firework.removeEventListener(Fireworks.COMPLETE, complete);
		garbage.push(firework.id);
	}
	private function remove():void {
		for (var n:uint = 0; n < garbage.length; n++) {
		var id:uint = garbage[n];
		var firework:Fireworks = fireworks[id];
		firework = null;
		fireworks.splice(id, 1);
		}
		reset();
	}
	private function reset():void {
		for (var n:uint = 0; n < fireworks.length; n++) {
		var firework:Fireworks = fireworks[n];
		firework.id = n;
		}
		garbage = new Array();
	}

}


import flash.display.BitmapData;
import flash.geom.Rectangle;
import frocessing.color.ColorHSV;

class EmitLight {
	private var canvas:BitmapData;
	private var rect:Rectangle;
	private var dots:Array;
	private static var deceleration:Number = 0.1;
	private var color:ColorHSV;

	public function EmitLight(c:BitmapData) {
		canvas  = c;
		rect = canvas.rect;
		init();
	}

	private function init():void {
		dots = new Array();
		color = new ColorHSV(0, 0.4);
	}
	public function create(max:uint):void {
		for (var n:uint = 0; n < max; n++) {
			var px:Number = Math.random()*rect.width;
			var py:Number = rect.height - Math.random()*5;
			var energy:Number = Math.random() + 0.5;
			var dot:Dot = new Dot(px, py, energy);
			color.h = Math.random()*360;
			dot.rgb = color.value;
			dots.push(dot);
		}
	}
	public function emit():void {
		for (var n:uint = 0; n < dots.length; n++) {
			var dot:Dot = dots[n];
			dot.energy -= deceleration;
			canvas.setPixel(dot.x, dot.y, dot.rgb);
			if (dot.energy < 0) {
				dots.splice(n, 1);
				dot = null;
			}
		}
	}

}



import flash.events.EventDispatcher;
import flash.display.BitmapData;
import flash.geom.Rectangle;
import flash.geom.Point;
import flash.events.Event;
import frocessing.color.ColorHSV;

class Fireworks extends EventDispatcher {
	public var id:uint;
	private var sky:BitmapData;
	private var rect:Rectangle;
	private var launcher:Dot;
	private var dots:Array;
	private static var speed:Number = 10;
	private static var deceleration:Number = 0.95;
	private static var gravity:Number = 0.05;
	private var color:ColorHSV;
	private var colors:Array;
	private static var length:Number = 2;
	private var manager:Bresenham;
	public var emit:Function;
	private var se:SoundEffect;
	private var source:String = "http://www.project-nya.jp/images/flash/explosion.mp3";
	public static const COMPLETE:String = Event.COMPLETE;

	public function Fireworks(s:BitmapData) {
		sky  = s;
		rect = sky.rect;
		init();
	}

	private function init():void {
		dots = new Array();
		color = new ColorHSV(0, 0.4);
		manager = new Bresenham(sky);
		emit = ready;
		se = new SoundEffect();
		//se.init(Explosion, "explosion");
		se.load(source, "explosion");
	}
	public function create(list:Array):void {
		colors = list;
		var px:Number = (0.2 + Math.random()*0.6)*rect.width;
		launcher = new Dot(px, rect.height);
		launcher.vy = - speed*(1 + Math.random()*0.1);
		color.h = colors[0];
		launcher.rgb = color.value;
		emit = launch;
	}
	private function ready():void {
	}
	private function launch():void {
		launcher.vy += gravity;
		launcher.y += launcher.vy;
		sky.setPixel(launcher.x, launcher.y, launcher.rgb);
		if (Math.abs(launcher.vy) < 9) {
			explode(200, new Point(launcher.x, launcher.y), launcher.rgb);
			launcher = null;
		}
	}
	private function explode(max:uint, point:Point, rgb:uint):void {
		for (var n:uint = 0; n < max; n++) {
			var energy:Number = Math.random()*5;
			var angle:Number = Math.random()*360;
			var dot:Dot = new Dot(point.x, point.y, energy, angle);
			dot.velocity = Math.random()*5;
			dot.vx = Math.cos(dot.angle*Math.PI/180)*dot.velocity;
			dot.vy = Math.sin(dot.angle*Math.PI/180)*dot.velocity;
			dot.px = dot.x;
			dot.py = dot.y;
			dot.rgb = rgb;
			dots.push(dot);
		}
		emit = spread;
		se.play("explosion", 0.6);
	}
	private function spread():void {
		for (var n:uint = 0; n < dots.length; n++) {
			var dot:Dot = dots[n];
			dot.vx *= deceleration;
			dot.vy *= deceleration;
			dot.vy += gravity;
			dot.x += dot.vx;
			dot.y += dot.vy;
			dot.energy *= deceleration;
			var x0:int = dot.x;
			var y0:int = dot.y;
			var x1:int = dot.x - (dot.x - dot.px)*length;
			var y1:int = dot.y - (dot.y - dot.py)*length;
			color.h = colors[1] + (colors[0] - colors[1])*dot.energy*0.2;
			dot.rgb = color.value;
			manager.draw(x0, y0, x1, y1, dot.rgb, 1);
			dot.px = dot.x;
			dot.py = dot.y;
			if (dot.energy < 0.05) {
				dots.splice(n, 1);
				dot = null;
				if (dots.length < 1) {
					dispatchEvent(new Event(Fireworks.COMPLETE));
				}
			}
		}
	}

}


class Dot {
	public var x:Number = 0;
	public var y:Number = 0;
	public var vx:Number = 0;
	public var vy:Number = 0;
	public var px:Number = 0;
	public var py:Number = 0;
	public var energy:Number = 1;
	public var angle:Number = 0;
	public var velocity:Number = 1;
	public var rgb:uint = 0xFFFFFF;

	public function Dot(_x:Number, _y:Number, e:Number = 1, a:Number = 0):void {
		x = _x;
		y = _y;
		energy = e;
		angle = a;
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


import flash.events.EventDispatcher;
import flash.events.Event;
import flash.events.ProgressEvent;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.media.SoundTransform;
import flash.events.ProgressEvent;
import flash.net.URLRequest;

class SoundEffect extends EventDispatcher {
	private static var soundList:Object;
	private var sound:Sound;
	private var channel:SoundChannel;
	private static var initialized:Boolean = false;
	private var volume:Number;
	private var looping:Boolean = false;

	public function SoundEffect() {
		if (!initialized) initialize();
	}

	private static function initialize():void {
		initialized = true;
		soundList = new Object();
	}
	public function init(Snd:Class, id:String):void {
		var snd:Sound = new Snd();
		soundList[id] = snd;
	}
	public function load(file:String, id:String):void {
		var snd:Sound = new Sound();
		snd.load(new URLRequest(file));
		snd.addEventListener(ProgressEvent.PROGRESS, progress, false, 0, true);
		snd.addEventListener(Event.COMPLETE, loaded, false, 0, true);
		soundList[id] = snd;
	}
	public function play(id:String, vol:Number, loop:Boolean = false):void {
		if (channel != null) channel.stop();
		sound = soundList[id];
		volume = vol;
		looping = loop;
		channel = sound.play();
		var transform:SoundTransform = channel.soundTransform;
		transform.volume = volume;
		channel.soundTransform = transform;
		if (looping) {
			channel.addEventListener(Event.SOUND_COMPLETE, complete, false, 0, true);
		}
	}
	public function stop():void {
		if (channel != null) {
			channel.stop();
			channel.removeEventListener(Event.SOUND_COMPLETE, complete);
		}
	}
	private function progress(evt:ProgressEvent):void {
		dispatchEvent(evt);
	}
	private function loaded(evt:Event):void {
		dispatchEvent(evt);
	}
	private function complete(evt:Event):void {
		channel.removeEventListener(Event.SOUND_COMPLETE, complete);
		if (looping) {
			channel = sound.play(0);
			channel.addEventListener(Event.SOUND_COMPLETE, complete, false, 0, true);
			var transform:SoundTransform = channel.soundTransform;
			transform.volume = volume;
			channel.soundTransform = transform;
		}
	}

}

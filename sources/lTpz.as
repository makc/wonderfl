// forked from Saqoosha's Force Field with Bresenham's line
// forked from Saqoosha's Force Field
package {
	
	import __AS3__.vec.Vector;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.PixelSnapping;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.filters.BlurFilter;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	import frocessing.color.ColorHSV;
	
	import net.hires.debug.Stats;
	
	[SWF(backgroundColor=0x0, frameRate=60)]
	
	public class ForceField3 extends Sprite {
		
		private static const ZERO_POINT:Point = new Point();
		
		private static const MAP_SCALE:Number = 0.25;
		private static const TRAIL_SCALE:Number = 2;
		private static const DRAW_SCALE:Number = 0.5;
		
		private var _timer:Timer;
		private var _seed:Number = new Date().getTime();
		private var _offsets:Array = [new Point(), new Point()];
		private var _forcemap:BitmapData;
		private var _count:int = 0;
		
		private var _particles:Vector.<Particle>;
		private var _canvas:BitmapData;
		private var _fade:BitmapData;
		private var _darken:ColorMatrixFilter = new ColorMatrixFilter([
			1, 0, 0, 0, -2,
			0, 1, 0, 0, -2,
			0, 0, 1, 0, -2,
			0, 0, 0, 1,  0
		]);
		private var _blur:BlurFilter = new BlurFilter(2, 2, 1);
		private var _sparkle:BitmapData;
		private var _sparkleDrawMatrix:Matrix = new Matrix(0.25, 0, 0, 0.25, 0, 0);
		
		private var _drawMatrix:Matrix = new Matrix(DRAW_SCALE, 0, 0, DRAW_SCALE, 0, 0);
		private var _drawColor:ColorTransform = new ColorTransform(0.1, 0.1, 0.1);
		
		public function ForceField3() {
			this.stage.quality = StageQuality.MEDIUM;
			
			this._timer = new Timer(500, 0);
			this._timer.addEventListener(TimerEvent.TIMER, this._onTimer);
			this._timer.start();
			this._forcemap = new BitmapData(475 * MAP_SCALE, 475 * MAP_SCALE, false, 0x0);
			
			this._particles = new Vector.<Particle>();
			
			this._fade = new BitmapData(475 * DRAW_SCALE, 475 * DRAW_SCALE, false, 0x0);
			var bm:Bitmap = this.addChild(new Bitmap(this._fade, PixelSnapping.AUTO, true)) as Bitmap;
			bm.scaleX = bm.scaleY = 1 / DRAW_SCALE;
			
			this._canvas = new BitmapData(475, 475, true, 0x0);
			var b:Bitmap = this.addChild(new Bitmap(this._canvas)) as Bitmap;
			b.blendMode = BlendMode.ADD;
			
			this._sparkle = new BitmapData(118, 118, true, 0x0);
			b = this.addChild(new Bitmap(this._sparkle)) as Bitmap;
			b.smoothing = true;
			b.blendMode = BlendMode.ADD;
			b.scaleX = b.scaleY = 4;
			
			this.addEventListener(Event.ENTER_FRAME, this._onEnterFrame);

			this.stage.addChild(new Stats());
		}
		
		private function _onTimer(e:TimerEvent = null):void {
			var t:int = getTimer();
			this._offsets[0].x = t / 20;
			this._offsets[1].y = t / 35;
			this._forcemap.perlinNoise(150, 150, 2, this._seed, true, true, 3, false, this._offsets);
		}
		
		private var color:ColorHSV = new ColorHSV(0, 0.5); 
		private function _onEnterFrame(e:Event):void {
			var n:int = 10;
			while (n--) {
				var a:Number = getTimer() / 1000 + Math.random() * Math.PI;
				color.h = (getTimer() / 20000) * 360;
				var p:Particle = new Particle(237, 237, Math.cos(a), Math.sin(a), color.value);
				this._particles.push(p);
			}
			
//			var g:Graphics = this._canvas.graphics;
//			g.clear();
			
			this._canvas.lock();
			this._canvas.fillRect(this._canvas.rect, 0x0);
			
			n = this._particles.length;
			while (n--) {
				p = this._particles[n];
				var c:uint = this._forcemap.getPixel(p.x * MAP_SCALE, p.y * MAP_SCALE);
				p.vx += (((c >> 16) & 0xff) - 0x80) / 0x80 * 0.2;
				p.vy += (((c >> 8) & 0xff) - 0x80) / 0x80 * 0.2;
				p.x += p.vx;
				p.y += p.vy;
				p.life -= 0.005;
				if (p.life < 0 || p.x < -50 || p.x > 525 || p.y < -50 || p.y > 525) {
					this._particles.splice(n, 1);
				} else {
					this._drawLine(p.x, p.y, p.x - (p.x - p.px) * TRAIL_SCALE, p.y - (p.y - p.py) * TRAIL_SCALE, p.color, 0.5 * p.life);
					p.px = p.x;
					p.py = p.y;
				}
			}
			
			this._canvas.unlock();
			
			this._sparkle.lock();
			this._sparkle.fillRect(this._sparkle.rect, 0x0);
			this._sparkle.draw(this._canvas, this._sparkleDrawMatrix);
			this._sparkle.unlock();
			
			if (this._count & 1) {
				this._fade.lock();
				this._fade.draw(this._canvas, this._drawMatrix, this._drawColor, BlendMode.ADD);
				this._fade.applyFilter(this._fade, this._fade.rect, ZERO_POINT, this._blur);
				this._fade.unlock();
			}
			if (this._count & 0x4) {
				this._onTimer();
			}
			this._count++;
		}
		
		private function _drawLine(x0:int, y0:int, x1:int, y1:int, color:int, alpha:Number):void {
			var steep:Boolean = Math.abs(y1 - y0) > Math.abs(x1 - x0);
			var tmp:int;
			if (steep) {
				tmp = x0;
				x0 = y0;
				y0 = tmp;
				tmp = x1;
				x1 = y1;
				y1 = tmp;
			}
			if (x0 > x1) {
				tmp = x0;
				x0 = x1;
				x1 = tmp;
				tmp = y0;
				y0 = y1;
				y1 = tmp;
			}
			var deltax:int = x1 - x0;
			var deltay:int = Math.abs(y1 - y0);
			var error:int = deltax / 2;
			var ystep:int;
			var y:int = y0;
			if (y0 < y1) {
				ystep = 1;
			} else {
				ystep = -1;
			}
			for (var x:int = x0; x <= x1; x++) {
				if (steep) {
					this._canvas.setPixel32(y, x, color | ((alpha * 0xff) << 24));
				} else {
					this._canvas.setPixel32(x, y, color | ((alpha * 0xff) << 24));
				}
				error = error - deltay;
				if (error < 0) {
					y = y + ystep;
					error = error + deltax;
				}
			}
		}
	}
}



class Particle {
	public var x:Number = 0;
	public var y:Number = 0;
	public var px:Number = 0;
	public var py:Number = 0;
	public var vx:Number = 0;
	public var vy:Number = 0;
	public var life:Number = 2;
	public var color:uint = 0xffffff;
	public function Particle(x:Number = 0, y:Number = 0, vx:Number = 0, vy:Number = 0, color:uint = 0xffffff) {
		this.x = this.px = x;
		this.y = this.py = y;
		this.vx = vx;
		this.vy = vy;
		this.color = color;
	}
}
package {
	
	import __AS3__.vec.Vector;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.Graphics;
	import flash.display.PixelSnapping;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.filters.BlurFilter;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.GlowFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	import frocessing.color.ColorHSV;
	
	import net.hires.debug.Stats;
	
	[SWF(backgroundColor=0x0, frameRate=60)]
	
	public class FlashTest extends Sprite {
		
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
		private var _canvas:Shape;
		private var _fade:BitmapData;
		private var _darken:ColorMatrixFilter = new ColorMatrixFilter([
		1, 0, 0, 0, -2,
		0, 1, 0, 0, -2,
		0, 0, 1, 0, -2,
		0, 0, 0, 1, 0
		]);
		private var _blur:BlurFilter = new BlurFilter(2, 2, 1);
		
		private var _drawMatrix:Matrix = new Matrix(DRAW_SCALE, 0, 0, DRAW_SCALE, 0, 0);
		private var _drawColor:ColorTransform = new ColorTransform(0.1, 0.1, 0.1);
		
		public function FlashTest() {
//			this.stage.quality = StageQuality.MEDIUM;
			
			this._timer = new Timer(500, 0);
			this._timer.addEventListener(TimerEvent.TIMER, this._onTimer);
			this._timer.start();
			this._forcemap = new BitmapData(475 * MAP_SCALE, 475 * MAP_SCALE, false, 0x0);
//			this.addChild(new Bitmap(this._forcemap));
			
			this._particles = new Vector.<Particle>();
			
			this._fade = new BitmapData(475 * DRAW_SCALE, 475 * DRAW_SCALE, false, 0x0);
			var bm:Bitmap = this.addChild(new Bitmap(this._fade, PixelSnapping.AUTO, true)) as Bitmap;
			bm.scaleX = bm.scaleY = 1 / DRAW_SCALE;
			
			this._canvas = this.addChild(new Shape()) as Shape;
			this._canvas.blendMode = BlendMode.ADD;
//			this._canvas.filters = [new GlowFilter(0xffffff, 1, 2, 2, 2)];
			
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
			
			var g:Graphics = this._canvas.graphics;
			g.clear();
//			g.lineStyle(0, 0xffffff, 0.5);
//			g.beginFill(0xffffff);
			
			n = this._particles.length;
			while (n--) {
				p = this._particles[n];
				var c:uint = this._forcemap.getPixel(p.x * MAP_SCALE, p.y * MAP_SCALE);
				p.vx += (((c >> 16) & 0xff) - 0x80) / 0x80 * 0.3;
				p.vy += (((c >> 8) & 0xff) - 0x80) / 0x80 * 0.3;
				p.x += p.vx;
				p.y += p.vy;
				p.life -= 0.005;
				if (p.life < 0 || p.x < -10 || p.x > 485 || p.y < -10 || p.y > 485) {
					this._particles.splice(n, 1);
				} else {
					g.lineStyle(0, p.color, 0.5 * p.life);
					g.moveTo(p.x, p.y);
	//				g.lineTo(p.px, p.py);
					g.lineTo(p.x - (p.x - p.px) * TRAIL_SCALE, p.y - (p.y - p.py) * TRAIL_SCALE);
					p.px = p.x;
					p.py = p.y;
	//				g.drawRect(p.x, p.y, 2, 2);
				}
			}
			
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
	}
}



class Particle {
	public var x:Number = 0;
	public var y:Number = 0;
	public var px:Number = 0;
	public var py:Number = 0;
	public var vx:Number = 0;
	public var vy:Number = 0;
	public var life:Number = 1;
	public var color:uint = 0xffffff;
	public function Particle(x:Number = 0, y:Number = 0, vx:Number = 0, vy:Number = 0, color:uint = 0xffffff) {
		this.x = this.px = x;
		this.y = this.py = y;
		this.vx = vx;
		this.vy = vy;
		this.color = color;
	}
}
// 色々参考にさせて頂いてます
package
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.PixelSnapping;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.filters.BlurFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	[SWF(width = "465", height = "465", backgroundColor = "0x000000", frameRate = "30")]
	
	public class Hanabi extends Sprite
	{
		private const WIDTH:Number = 465;
		private const HEIGH:Number = 465;
		
		private var _particles:Array;
		private var _canvas:BitmapData;
		private var _glow:BitmapData;
		private var _rect:Rectangle;
		private var cTra:ColorTransform;
		private var timer:Timer;
		
		private var sx:Number;
		private var sy:Number;
		
		
		public function Hanabi()
		{
			init();
		}
		
		private function init():void
		{
			_particles = [];
			_canvas = new BitmapData(WIDTH, HEIGH, false, 0x0);
			addChild(new Bitmap(_canvas)) as Bitmap;
			
			_glow = new BitmapData(WIDTH/4, HEIGH/4, false, 0x0);
			var bm:Bitmap = addChild(new Bitmap(_glow, PixelSnapping.NEVER, true)) as Bitmap;
			bm.scaleX = bm.scaleY = 4;
			bm.blendMode = BlendMode.ADD;
			
			_rect = new Rectangle(0, 0, WIDTH, HEIGH);
			cTra = new ColorTransform(.8, .8, .9, 1.0);
			
			this.stage.addEventListener(Event.ENTER_FRAME, enterframeHandler);
			
			timer = new Timer(100);
			timer.addEventListener(TimerEvent.TIMER, resetFunc);
			timer.start();
		}
		
		private function resetFunc(e:TimerEvent):void
		{
			(cTra.redMultiplier > 0.9)? cTra.redMultiplier = 0.8 : cTra.redMultiplier += 0.01;
			
			hanabi();
		}
		
		private function hanabi():void 
		{
			var i:int = 200;
			sx = Math.random()*WIDTH;
			sy = Math.random()*HEIGH/3;
			while (i--) createParticle();
		}
		
		private function createParticle():void {
			var p:Particle = new Particle();
			p.x = sx;
			p.y = sy;
			var radius:Number = Math.sqrt(Math.random())*10;
			var angle:Number = Math.random()*(Math.PI)*2;
			p.vx = Math.cos(angle) * radius;
			p.vy = Math.sin(angle) * radius;
			_particles.push(p);
		}
		
		private function enterframeHandler(e:Event):void
		{
			update();
		}
		
		private function update():void {
			_canvas.lock();
			_canvas.applyFilter(_canvas, _rect, new Point(), new BlurFilter(1, 1));
			_canvas.colorTransform(_rect, cTra);
			var i:int = _particles.length;
			while (i--) {
				var p:Particle = _particles[i];
				p.vy += 0.2;
				p.vx *= 0.9;
				p.vy *= 0.9;
				p.x += p.vx;
				p.y += p.vy;
				_canvas.setPixel32(p.x, p.y, p.c);
				if ((p.x > stage.stageWidth || p.x < 0) || (p.y < 0 || p.y > stage.stageHeight) || Math.abs(p.vx) < .01 || Math.abs(p.vy) < .01)
				{
					this._particles.splice(i, 1);
				}
			}
			_canvas.unlock();
			_glow.draw(_canvas, new Matrix(0.25, 0, 0, 0.25));
		}
	}
}

class Particle
{
	public var x:Number = 0;
	public var y:Number = 0;
	public var vx:Number = 0;
	public var vy:Number = 0;
	public var c:uint = 0xFFFFFFFF;
	
	public function Particle() {}
}


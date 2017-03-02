package
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	
	[SWF(width = "465", height = "465", backgroundColor = "0xffffff", frameRate = "24")] 
	/**
	 * the anta(Uji Uji Uji Uji...)
	 * @author naoto koshikawa
	 */
	public class Main6 extends Sprite
	{
		// _____________________________________________________ Property
		/** count of particles */
		private static const PARTICLES:uint = 1000;
		
		/** base container which virtual stage */
		private var _base:Sprite;
		
		/** particle list */
		private var _particles:Array;
		
		/** campus */
		private var _campus:Bitmap;
		
		// _____________________________________________________ Method
		/**
		 * constructor
		 */
		public function Main6() 
		{
			_particles = [];
			createBase();
			createParticles();
			addEventListener(Event.ENTER_FRAME, enterFrameListener);
		}
		
		/**
		 * create base container which move center position in virtual
		 */
		private function createBase():void
		{
			_base = new Sprite();
			_base.x = stage.stageWidth / 2;
			_base.y = stage.stageHeight / 2;
			var dotData:BitmapData = new BitmapData(2, 2, true, 0x00000000);
			dotData.setPixel32(0, 0, 0x33000000 | 0x00FFFFFF * Math.random());
			dotData.setPixel32(1, 1, 0x33000000 | 0x00FFFFFF * Math.random());
			var dot:Shape = new Shape();
			dot.graphics.beginBitmapFill(dotData);
			dot.graphics.drawRect(-_base.x, -_base.y, stage.stageWidth, stage.stageHeight);
			_base.addChild(dot);
			addChild(_base);
		}
		
		/**
		 * create particles
		 * @param	event
		 */
		private function createParticles():void
		{
			for (var i:uint = 0; i < PARTICLES; i++)
			{
				var particle:Shape = new Shape();
				var gr:Graphics = particle.graphics;
				var bitmapData:BitmapData = new BitmapData(1, 1, true, 0x00000000);
				bitmapData.setPixel32(0, 0, 0x33000000);
				gr.beginBitmapFill(bitmapData);
				gr.drawRect(0, 0, 1, 1);
				_base.addChild(particle);
				_particles.push(particle);
			}
			_campus = new Bitmap(new BitmapData(stage.stageWidth, stage.stageHeight, true, 0x33000000));
			addChild(_campus);
		}
		
		// _____________________________________________________ Listener
		private function enterFrameListener(event:Event):void
		{
			for (var i:uint = 0; i < _particles.length; i++)
			{
				var particle:Shape = _particles[i];
				var radian:Number = Math.random() * Math.PI * 2;
				particle.x += Math.cos(radian);
				particle.y += Math.sin(radian);
				_campus.bitmapData.setPixel32(particle.x + _base.x, particle.y + _base.y, 0x00000000);
			}
		}
		
	}
	
}
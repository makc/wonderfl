package  
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	
	/**
	* Ebbinghaus illusion - does it work on you?
	* @see http://en.wikipedia.org/wiki/Ebbinghaus_illusion
	* @author makc
	*/
	[SWF(width=465, height=465)]
	public class Ebbinghaus extends Sprite
	{
		public function Ebbinghaus() 
		{
			var s:Sprite = new Sprite;

			var g:Graphics = s.graphics;
			g.beginFill (0xFF7F00, 0.8);
			g.drawCircle (465 / 4, 3 * 465 / 4, 30);
			g.drawCircle (3 * 465 / 4, 465 / 4, 30);

			var i:int;
			circlesA = new Sprite;
			addChild (circlesA); circlesA.x = 465 / 4; circlesA.y = 3 * 465 / 4;
			circlesB = new Sprite;
			addChild (circlesB); circlesB.x = 3 * 465 / 4; circlesB.y = 465 / 4;
			addChild (s);

			for (i = 0; i < 7; i++) {
				s = new Sprite;
				s.graphics.beginFill (0x7FFF);
				s.graphics.drawCircle (80, 0, 30);
				circlesA.addChild (s); s.rotation = 51.43 * i;
			}
			for (i = 0; i < 7; i++) {
				s = new Sprite;
				s.graphics.beginFill (0x7FFF);
				s.graphics.drawCircle (80, 0, 30);
				circlesB.addChild (s); s.rotation = 51.43 * i;
			}

			addEventListener (Event.ENTER_FRAME, rockAndRoll);
		}

		public function rockAndRoll (e:Event):void
		{
			circlesA.rotation += 0.1;
			circlesA.scaleX = circlesA.scaleY = 0.8 + 0.7 * Math.cos (0.01745329252 * circlesA.rotation);
			circlesB.rotation -= 0.1;
			circlesB.scaleX = circlesB.scaleY = 0.8 + 0.7 * Math.sin (0.01745329252 * circlesB.rotation);
		}

		public var circlesA:Sprite;
		public var circlesB:Sprite;
	}
	
}
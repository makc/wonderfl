package {
	import flash.display.Sprite;
	import flash.events.Event;
	public class Butterfly extends Sprite{
		public function Butterfly () {
			graphics.lineStyle (0);
			graphics.moveTo (465 / 2, 465 / 2);
			addEventListener (Event.ENTER_FRAME, loop);
		}
		private var t:Number = -0.2;
		private function loop(e:Event):void {
			var r:Number = Math.exp (Math.sin (t)) - 2 * Math.cos (4 * t) + Math.pow (Math.sin ((t - Math.PI / 2) / 12), 5);
			graphics.lineTo (465 / 2 + 50 * r * Math.cos (t), 465 / 2 - 30 * r * Math.sin (t));
			t += 0.03;
		}
	}
}
package  {
	import flash.display.Sprite;
	import flash.events.Event;
	[SWF (width=465, height=465)]
	public class Clock extends Sprite {
		public function Clock () {
			super (); x = y = 465 / 2; rotation = -90;
			addEventListener (Event.ENTER_FRAME, function (e:Event):void {
				var d:Date = new Date;
				var s:Number = d.getSeconds () * 2 * Math.PI / 60;
				var m:Number = d.getMinutes () * 2 * Math.PI / 60;
				var h:Number = d.getHours () * 2 * Math.PI / 12;
				graphics.clear (); graphics.lineStyle (2);
				graphics.lineTo (200 * Math.cos (s), 200 * Math.sin (s)); graphics.moveTo (0, 0);
				graphics.lineTo (150 * Math.cos (m), 150 * Math.sin (m)); graphics.moveTo (0, 0);
				graphics.lineTo (100 * Math.cos (h), 100 * Math.sin (h));
			});
		}
	}
}
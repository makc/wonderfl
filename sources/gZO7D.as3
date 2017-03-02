package  {
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.geom.Matrix;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	/**
	 * Our amazing planet - infographic by Karl Tate
	 * @see http://www.ouramazingplanet.com/oap-0249
	 */
	public class AmazingPlanet extends Sprite {
		public var parts:Vector.<String>;
		public var cat:Vector.<Loader>;
		public var count:int;
		public var line:int;
		public function AmazingPlanet () {
			parts = Vector.<String> ([
				"http://assets.wonderfl.net/images/related_images/a/af/af21/af2161b8a78eb616c4e37ecf886a9ba5929f4f0f",
				"http://assets.wonderfl.net/images/related_images/e/e9/e99a/e99aea04386f1b072345c7168bfc619899969c72",
				"http://assets.wonderfl.net/images/related_images/8/86/863d/863d712f9da1974f890735a931e153786e61f6ed",
				"http://assets.wonderfl.net/images/related_images/3/34/3467/3467cff635a5ffa923b419694f608d6ae8cd25f4",
				"http://assets.wonderfl.net/images/related_images/6/64/64e6/64e6d4aa6117fb77b3dee619aaf9d46e52787583"
			]);
			cat = new Vector.<Loader> (parts.length);
			for (var i:int = 0; i < cat.length; i++) {
				cat [i] = new Loader;
				cat [i].contentLoaderInfo.addEventListener (ProgressEvent.PROGRESS, bar);
				cat [i].contentLoaderInfo.addEventListener (Event.COMPLETE, done);
				cat [i].load (new URLRequest (parts [i]), new LoaderContext (true));
			}
			count = 0; line = 1e5;
		}
		public function bar (e:ProgressEvent):void {
			var loaded:Number = 0, total:Number = 0;
			for (var i:int = 0; i < cat.length; i++) {
				loaded += cat [i].contentLoaderInfo.bytesLoaded;
				total += (cat[i].contentLoaderInfo.bytesTotal > 0) ?
					 cat[i].contentLoaderInfo.bytesTotal : 350000;
			}
			graphics.clear ();
			graphics.lineStyle (2);
			graphics.drawRect (80, 220, 304, 34);
			graphics.lineStyle ();
			graphics.beginFill (0);
			graphics.drawRect (82, 222, 300 * loaded / total, 30);
			graphics.endFill ();
		}
		public function done (e:Event):void {
			count++; if (count == cat.length) {
				addEventListener (Event.ENTER_FRAME, loop);
			}
		}
		public function loop (e:Event):void {
			line = line + 23 * (mouseY / 465 - 0.5);
			line = Math.min (11390 - 465, Math.max (0, line));
			var i:int = line / 2278, h:int = 2278 - line % 2278;
			var bi:BitmapData = BitmapData (cat [i].content ["bitmapData"]);
			var mi:Matrix = new Matrix (1, 0, 0, 1, 0, h);
			graphics.clear ();
			graphics.beginBitmapFill (bi, mi);
			graphics.drawRect (0, 0, 465, Math.min (h, 465));
			graphics.endFill ();
			if (h < 465) {
				bi = BitmapData (cat [i + 1].content ["bitmapData"]);
				graphics.beginBitmapFill (bi, mi);
				graphics.drawRect (0, h, 465, 465 - h);
				graphics.endFill ();
			}
		}
	}
}
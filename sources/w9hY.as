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
	 * Thanks to flash player evolution original long cat swf
	 * no longer works :(
	 * 
	 * Original long cat was 300 * 59 = 17700 pixels, this one
	 * is 2528 * 7 = 17696, I decided to crop top 4 pixels.
	 */
	public class LongCat extends Sprite {
		public var parts:Vector.<String>;
		public var cat:Vector.<Loader>;
		public var count:int;
		public var line:int;
		public function LongCat () {
			parts = Vector.<String> ([
				"http://assets.wonderfl.net/images/related_images/f/f5/f5a3/f5a3cc8a864ae7d6033630c4a798b8045f4224f9",
				"http://assets.wonderfl.net/images/related_images/a/aa/aaa2/aaa2f938299537c890c6bf5454c76f5fdea40dc0",
				"http://assets.wonderfl.net/images/related_images/9/9d/9dfb/9dfb3734db89044ef6409774afca36399115a0fd",
				"http://assets.wonderfl.net/images/related_images/e/ec/ecf9/ecf91cbab43186408d90f2ae55df586519979aa7",
				"http://assets.wonderfl.net/images/related_images/0/02/02d7/02d75f7af831627d494db229a707f93f78debcd2",
				"http://assets.wonderfl.net/images/related_images/c/c0/c0e7/c0e79a0f5ca24af0d308ade29b8950c540522fd5",
				"http://assets.wonderfl.net/images/related_images/b/b1/b16d/b16de6b47d148f7d7e7c4d818b70d9b7ed13cacc"
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
					 cat[i].contentLoaderInfo.bytesTotal : 150000;
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
			line = Math.min (17696 - 465, Math.max (0, line));
			var i:int = line / 2528, h:int = 2528 - line % 2528;
			var bi:BitmapData = BitmapData (cat [i].content ["bitmapData"]);
			var mi:Matrix = new Matrix (1, 0, 0, 1, 82, h);
			graphics.clear ();
			graphics.beginBitmapFill (bi, mi);
			graphics.drawRect (82, 0, 300, Math.min (h, 465));
			graphics.endFill ();
			if (h < 465) {
				bi = BitmapData (cat [i + 1].content ["bitmapData"]);
				graphics.beginBitmapFill (bi, mi);
				graphics.drawRect (82, h, 300, 465 - h);
				graphics.endFill ();
			}
		}
	}
}
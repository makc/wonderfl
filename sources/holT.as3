package  {
	import flash.display.*;
	import flash.events.Event;
	import flash.geom.*;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;

	/**
	 * There's a nice site allRGB.com that collects
	 * images with one pixel for every RGB color.
	 * Typical allRGB image is 4096x4096 pixels to
	 * hold 256³ colors. To fit wonderfl 465x465
	 * size standard, I propose this "mini" version
	 * of the game: fit 60³ colors. It takes almost
	 * all of 465x465, except 225 (or 15²) blank
	 * pixels. You are free to leave these pixels
	 * in any image area you want, of course. To
	 * play the game, fork this and change create()
	 * method into something creative :)
	 */

	[SWF(width=465,height=465)]
	public class allRGBMini extends Sprite {
		/**
		 * Replace me :)
		 * @param	bd	Empty locked 465x465 BitmapData.
		 */
		public function create (bd:BitmapData, image:BitmapData):void {
			var pixels:Array = [];
			for (var i:int = 0; i < 60; i++)
			for (var j:int = 0; j < 60; j++)
			for (var k:int = 0; k < 60; k++) {
				pixels.push (new Point (rgb (i, j, k),
					i + j + k
				));
			}

			pixels.sortOn ("y", Array.NUMERIC);

			// make HDR-like grayscale image
			var img:Array = [], c:int, r:int, g:int, b:int;
			for (i = 0; i < 465; i++)
			for (j = 0; j < 465; j++) {
				k = 0;
				c = image.getPixel (i * 2 + 2, j * 2 + 2);
				r = (c >> 16) & 255; g = (c >> 8) & 255; b = c & 255;
				k += r + g + b;
				c = image.getPixel (i * 2 + 3, j * 2 + 2);
				r = (c >> 16) & 255; g = (c >> 8) & 255; b = c & 255;
				k += r + g + b;
				c = image.getPixel (i * 2 + 2, j * 2 + 3);
				r = (c >> 16) & 255; g = (c >> 8) & 255; b = c & 255;
				k += r + g + b;
				c = image.getPixel (i * 2 + 3, j * 2 + 3);
				r = (c >> 16) & 255; g = (c >> 8) & 255; b = c & 255;
				k += r + g + b;
				img.push (new Vector3D (i, j, k));
			}

			img.sortOn ("z", Array.NUMERIC);

			while (pixels.length > 0) {
				var v:Vector3D = img.pop ();
				bd.setPixel (v.x, v.y, Point (pixels.pop ()).x);
			}
		}

		/**
		 * Makes normal color out of 60x60x60 cube
		 * for rendering purposes.
		 */
		public function rgb (r:uint, g:uint, b:uint):uint {
			var R:uint = r * 4.323;
			var G:uint = g * 4.323;
			var B:uint = b * 4.323;
			return (R << 16) + (G << 8) + B;
		}

		public function allRGBMini () {
			var loader:Loader = new Loader;
			loader.contentLoaderInfo.addEventListener (Event.COMPLETE, gotImage);
			loader.load (new URLRequest ("http://farm4.static.flickr.com/3063/3024878711_9fafb30945_o.jpg"),
				new LoaderContext (true));
		}

		public function gotImage (e:Event):void {
			var loaderInfo:LoaderInfo = LoaderInfo (e.target);
			var bd:BitmapData = new BitmapData (465, 465, false, 0);
			bd.lock (); create (bd, Bitmap (loaderInfo.content).bitmapData); bd.unlock (); addChild (new Bitmap (bd));
		}
	}
}
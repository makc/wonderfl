package  {
	import flash.display.*;

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
		public function create (bd:BitmapData):void {
			var k:int = 0;
			for (var i:int = 0; i < 31; i++)
			for (var j:int = 0; j < 31; j++) {
				if ((i == 0) && (j == 0)) continue;

				var u:int = k % 4;
				var v:int = (k / 4) % 4;
				var w:int = (k / 16);

				for (var p:int = 0; p < 15; p++)
				for (var q:int = 0; q < 15; q++) {
					bd.setPixel (i * 15 + p, j * 15 + q,
						rgb (15 * u + p, 15 * v + q, w)
					);
				}
				k++;
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
			var bd:BitmapData = new BitmapData (465, 465, false, 0);
			bd.lock (); create (bd); bd.unlock (); addChild (new Bitmap (bd));
		}
	}
}
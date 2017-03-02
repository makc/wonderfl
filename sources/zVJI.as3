package  {
	import flash.display.*;
	import flash.geom.*;

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
			var pixels:Array = [];
			for (var i:int = 0; i < 60; i++)
			for (var j:int = 0; j < 60; j++)
			for (var k:int = 0; k < 60; k++) {
				pixels.push (new Point (rgb (i, j, k),
					0.2126 * i + 0.7152 * j + 0.0722 * k
				));
			}

			// sort on luminance
			pixels.sortOn ("y", Array.NUMERIC);

			i = 0; var di:int = -1;
			j = 0; var dj:int = +1;
			while (pixels.length > 0) {
				bd.setPixel (i, j, Point (pixels.pop ()).x);

				// somebody could do this in under three lines :(
				if (i + di < 0) {
					di = 0; dj = 1;
				} else {
					if (di == 0) {
						if (i == 0) {
							di = +1; dj = -1;
						} else {
							di = -1; dj = +1;
						}
					} else if (i + di > 464) {
						di = 0; dj = 1;
					}
				}

				if (j + dj < 0) {
					di = 1; dj = 0;
				} else {
					if (dj == 0) {
						if (j == 0) {
							di = -1; dj = +1;
						} else {
							di = +1; dj = -1;
						}
					} else if (j + dj > 464) {
						di = 1; dj = 0;
					}
				}

				if ((i == 464) && (j == 0)) {
					di = -1; dj = +1;
				}

				i += di;
				j += dj;
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
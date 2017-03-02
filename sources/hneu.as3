package {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	/**
	 * Trying to viz-e AS3 native sort.
	 */
	public class SortViz extends Sprite {
		private var bd:BitmapData;
		private var ar:Array = [];
		private var a2:Array = [];
		private var count:int, limit:int;
		private function partialSort (a:int, b:int):int {
			if (count++ > limit) {
				// stop sort
				return 0;
			}
			if (a > b) return +1;
			if (a < b) return -1;
			return 0;
		}
		public function SortViz () {
			bd = new BitmapData (465, 256);
			var i:int, j:int, k:int;
			for (i = 0; i < 256; i++) ar [i] = i;
			for (i = 0; i < 256; i++) {
				j = i; while (j == i) j = int (Math.random () * 256) % 256;
				k = ar [i]; ar [i] = ar [j]; ar [j] = k;
			}
			for (i = 0; i < 256; i++) a2 [i] = ar [i];
			for (i = 0; i < 465; i++) {
				count = 0; limit = (i + 1) * 5;
				ar.sort (partialSort);
				for (j = 0; j < 256; j++) {
					bd.setPixel (i, j, hsv2rgb (1.40625 * ar [j]));
					// restore unsorted
					ar [j] = a2 [j];
				}
			}
			addChild (new Bitmap (bd));
		}
		/**
		 * @see http://wonderfl.net/c/dtn8
		 * @author matacat
		 */
		private function hsv2rgb (h:Number, s:Number = 1, v:Number = 1):uint {
			var rgb:uint = 0;

			if (s == 0) {  // gray scale
				rgb = 0xFF * v << 16 | 0xFF * v << 8 | 0xFF * v << 0;
				return rgb;
			}
			
			h = int (h) >= 360 ? int (h) % 360 : (int (h) < 0 ? int (h) % 360 + 360 : int (h));
			
			var i:int = int(h / 60);
			var f:Number = h / 60 - i;
			var p:Number = v * (1 - s);
			var q:Number = v * (1 - s * f);
			var t:Number = v * (1 - s * (1 - f));
			
			switch (i) {
				case 0: rgb = 0xFF * v << 16 | 0xFF * t << 8 | 0xFF * p << 0; break;
				case 1: rgb = 0xFF * q << 16 | 0xFF * v << 8 | 0xFF * p << 0; break;
				case 2: rgb = 0xFF * p << 16 | 0xFF * v << 8 | 0xFF * t << 0; break;
				case 3: rgb = 0xFF * p << 16 | 0xFF * q << 8 | 0xFF * v << 0; break;
				case 4: rgb = 0xFF * t << 16 | 0xFF * p << 8 | 0xFF * v << 0; break;
				case 5: rgb = 0xFF * v << 16 | 0xFF * p << 8 | 0xFF * q << 0;
			}

			return rgb;
		}
	}
}
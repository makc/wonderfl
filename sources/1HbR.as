package {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	/**
	 * Fowler vs Ebert & Co, Ebert wins
	 */
	public class FowlerAngleTest extends Sprite{
		private var bd:BitmapData = new BitmapData (400, 400);
		public function FowlerAngleTest () {
			var E:Number = 1410;
			bd.lock ();
			for (var i:int = 0; i < 200; i++)
			for (var j:int = 0; j < 200; j++) {
				var dx:Number = i - 99.5;
				var dy:Number = j - 99.5;
				var a1:Number = 4 + 4 * Math.atan2 (dy, dx) / Math.PI;
				var a2:Number = FowlerAngle (-dy, -dx);
				bd.setPixel (i, j, 0x10101 * int ( 32 * a2 ));
				bd.setPixel (i + 200, j, 0x10101 * int ( 128 + E * (a2 - a1) ));
			}
			for (i = 0; i < 200; i++)
			for (j = 0; j < 200; j++) {
				dx = i - 99.5;
				dy = j - 99.5;
				a1 = 4 + 4 * Math.atan2 (dy, dx) / Math.PI;
				a2 = 4 + 4 * atan2 (dy, dx) / Math.PI;
				bd.setPixel (i, j + 200, 0x10101 * int ( 32 * a2 ));
				bd.setPixel (i + 200, j + 200, 0x10101 * int ( 128 + E * (a2 - a1) ));
			}
			bd.unlock ();
			addChild (new Bitmap (bd));
		}
		/**
		 * @see http://paulbourke.net/geometry/fowler/
		   This function is due to Rob Fowler.  Given dy and dx between 2 points
		   A and B, we calculate a number in [0.0, 8.0) which is a monotonic
		   function of the direction from A to B. 

		   (0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0) correspond to
		   (  0,  45,  90, 135, 180, 225, 270, 315, 360) degrees, measured
		   counter-clockwise from the positive x axis.
		*/
		private function FowlerAngle (dy:Number, dx:Number):Number {
			var adx:Number, ady:Number;    /* Absolute Values of Dx and Dy */
			var code:int;        /* Angular Region Classification Code */

			adx = (dx < 0) ? -dx : dx;  /* Compute the absolute values. */
			ady = (dy < 0) ? -dy : dy;

			code = (adx < ady) ? 1 : 0;
			if (dx < 0)  code += 2;
			if (dy < 0)  code += 4;

			switch (code)
			{
				case 0: return (dx==0) ? 0 : ady/adx;  /* [  0, 45] */
				case 1: return (2.0 - (adx/ady));      /* ( 45, 90] */
				case 3: return (2.0 + (adx/ady));      /* ( 90,135) */
				case 2: return (4.0 - (ady/adx));      /* [135,180] */
				case 6: return (4.0 + (ady/adx));      /* (180,225] */
				case 7: return (6.0 - (adx/ady));      /* (225,270) */
				case 5: return (6.0 + (adx/ady));      /* [270,315) */
				case 4: return (8.0 - (ady/adx));      /* [315,360) */
			}

			// never happens, but "Error: Function does not return a value."
			return 8;
		}
		/**
		 * Computes and returns the angle of the point <code>y/x</code> in radians, when measured counterclockwise
		 * from a circle's <em>x</em> axis (where 0,0 represents the center of the circle).
		 * The return value is between positive pi and negative pi.
		 *
		 * @author Eugene Zatepyakin
		 * @author Joa Ebert
		 * @author Patrick Le Clec'h
		 *
		 * @param y A number specifying the <em>y</em> coordinate of the point.
		 * @param x A number specifying the <em>x</em> coordinate of the point.
		 *
		 * @return A number.
		 */
		public static function atan2(y:Number, x:Number):Number {
			var sign:Number = 1.0 - (int(y < 0.0) << 1)
			var absYandR:Number = y * sign + 2.220446049250313e-16
			var partSignX:Number = (int(x < 0.0) << 1) // [0.0/2.0]
			var signX:Number = 1.0 - partSignX // [1.0/-1.0]
			absYandR = (x - signX * absYandR) / (signX * x + absYandR)
			return ((partSignX + 1.0) * 0.7853981634 + (0.1821 * absYandR * absYandR - 0.9675) * absYandR) * sign
		}
	}
}
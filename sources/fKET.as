/*
 * Simple complex arithmetics.
 * Euler identity, e^(i*2pi) = 1.
 */
package {
	import flash.display.Sprite;
	import flash.events.Event;
	public class Test extends Sprite {
		private var A:Complex = new Complex;
		private var B:Complex = new Complex;
		private var N:int = 1;

		public function Test () {
			addEventListener (Event.ENTER_FRAME, calculate);
		}

		public function calculate (e:Event):void {
			graphics.clear ();
			graphics.lineStyle (2, 0);
			graphics.moveTo (465 / 2, 0); graphics.lineTo (465 / 2, 465);
			graphics.moveTo (0, 465 / 2); graphics.lineTo (465, 465 / 2);
			graphics.lineStyle (1, 0);
			graphics.moveTo (465 / 4, 0); graphics.lineTo (465 / 4, 465);
			graphics.moveTo (0, 465 / 4); graphics.lineTo (465, 465 / 4);
			graphics.moveTo (3 * 465 / 4, 0); graphics.lineTo (3 * 465 / 4, 465);
			graphics.moveTo (0, 3 * 465 / 4); graphics.lineTo (465, 3 * 465 / 4);

			A.x = 1; A.y = 0;
			Complex.Temp (1, 0).add (Complex.Temp (0, 2 * Math.PI).div (Complex.Temp (N, 0))).saveTo (B);
			for (var i:int = 0; i < N; i++) {
				// according to Euler identity this should converge back to (1,0)
				var ax:Number = A.x, ay:Number = A.y;
				A.mul (B).saveTo (A);
				arrow (
					465 / 2 + 465 / 4 * ax,  465 / 2 - 465 / 4 * ay,
					465 / 2 + 465 / 4 * A.x, 465 / 2 - 465 / 4 * A.y,
					0x7FFF
				);
			}

			N = (N + Math.max (1, N / 20)); if (N > 9000) N = 1;
		}

		private function arrow (x0:Number, y0:Number, x1:Number, y1:Number, c:uint):void {
			var idx:Number = x1 - x0;
			var idy:Number = y1 - y0;
			var iL:Number = Math.sqrt (idx * idx + idy * idy);
			idx /= 10//iL;
			idy /= 10//iL;
			graphics.lineStyle (0, c);
			graphics.moveTo (x0, y0);
			graphics.lineTo (x1, y1);
			graphics.lineTo (x1 - 2 * idx - idy, y1 - 2 * idy + idx);
			graphics.moveTo (x1, y1);
			graphics.lineTo (x1 - 2 * idx + idy, y1 - 2 * idy - idx);
		}
	}
}

class Complex {
	public var x:Number;
	public var y:Number;

	private static var pool:Vector.<Complex> = new Vector.<Complex>;
	private static var index:int = 0;

	private static function pick ():Complex {
		if (index == pool.length) {
			pool [index] = new Complex;
		}
		index++;
		return pool [index - 1];
	}
	
	public static function Temp (x:Number = 0, y:Number = 0):Complex {
		var tmp:Complex = pick (); tmp.x = x; tmp.y = y; return tmp;
	}

	public function saveTo (result:Complex):void {
		result.x = x;
		result.y = y;
		index = 0;
	}

	public function copy (z:Complex):Number {
		var e:Number = (x - z.x) * (x - z.x) + (y - z.y) * (y - z.y);
		x = z.x;
		y = z.y;
		return e;
	}

	public function Complex (x:Number = 0, y:Number = 0) {
		this.x = x;
		this.y = y;
	}

	public function add (b:Complex):Complex {
		var c:Complex = pick ();
		c.x = x + b.x;
		c.y = y + b.y;
		return c;
	}

	public function sub (b:Complex):Complex {
		var c:Complex = pick ();
		c.x = x - b.x;
		c.y = y - b.y;
		return c;
	}

	public function mul (b:Complex):Complex {
		var c:Complex = pick ();
		c.x = x * b.x - y * b.y;
		c.y = y * b.x + x * b.y;
		return c;
	}

	public function div (b:Complex):Complex {
		var c:Complex = pick ();
		var D:Number = b.x * b.x + b.y * b.y;
		c.x = (x * b.x + y * b.y) / D;
		c.y = (y * b.x - x * b.y) / D;
		return c;
	}

	public function pow (n:uint):Complex {
		var c:Complex = pick (); c.x = 1; c.y = 0;
		for (var i:int = 0; i < n; i++) {
			var _x:Number = x * c.x - y * c.y;
			var _y:Number = y * c.x + x * c.y;
			c.x = _x;
			c.y = _y;
		}
		return c;
	}

	public function toString (p:uint = 4):String {
		return x.toPrecision (p) + " " + ((y > 0) ? "+" : "") + y.toPrecision (p) + "i";
	}
}
/*
 * Found them :)
 */
package {
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	public class Test extends Sprite {
		private var A:Complex = new Complex;
		private var B:Complex = new Complex;
		private var C:Complex = new Complex;
		private var D:Complex = new Complex;
		private var p:Complex = new Complex;
		private var q:Complex = new Complex;
		private var r:Complex = new Complex;
		private var s:Complex = new Complex;
		private var P:Complex = new Complex;
		private var Q:Complex = new Complex;
		private var R:Complex = new Complex;
		private var S:Complex = new Complex;
		private var seed:Complex = new Complex (0.4, 0.9);
		private var out:TextField;
		private var values:Vector.<Number> = new Vector.<Number>;
		private var min_rs:Number = Number.MAX_VALUE;
		private var min_cs:Vector.<Number> = new Vector.<Number> (4, true);

		public function Test () {
			// prevent drawing API bugs
			stage.quality = "low";

			min_cs [0] = 0.21334181974695104;
			min_cs [1] = 0.9185696207011521;
			min_cs [2] = 0.971476866769487;
			min_cs [3] = 0.03437845939820224;

			TextField (addChild (out = new TextField)).autoSize = "left";

			addEventListener (Event.ENTER_FRAME, calculate);
		}

		public function calculate (e:Event):void {
			values.length = 0;

			var range:Number = (min_rs > 1) ? 0 : 10 * min_rs;

			A.x = min_cs [0] + range * (Math.random () - Math.random ());
			B.x = min_cs [1] + range * (Math.random () - Math.random ());
			C.x = min_cs [2] + range * (Math.random () - Math.random ());
			D.x = min_cs [3] + range * (Math.random () - Math.random ());

			// f(z)
			var equation:String = "z^4 + " +
				A.x.toPrecision (4) + " z^3 + " +
				B.x.toPrecision (4) + " z^2 +" +
				C.x.toPrecision (4) + " z +" +
				D.x.toPrecision (4) + " = 0";

			// http://en.wikipedia.org/wiki/Durand-Kerner_method#Explanation
			seed.pow (0).saveTo (p);
			seed.pow (1).saveTo (q);
			seed.pow (2).saveTo (r);
			seed.pow (3).saveTo (s);

			var N:int = 0;
			while (N < 100) {
				values.push (p.x, p.y, q.x, q.y, r.x, r.y, s.x, s.y);

				if (N == 2) {
					var rs:Number = Math.sqrt ((r.x - s.x) * (r.x - s.x) + (r.y - s.y) * (r.y - s.y));
					if (rs < min_rs) {
						min_rs = rs;
						min_cs [0] = A.x;
						min_cs [1] = B.x;
						min_cs [2] = C.x;
						min_cs [3] = D.x;
					}
				}

				// P = p-f(p)/((p-q)(p-r)(p-s))
				p.sub (
					     ( p.pow (4) )
					.add ( p.pow (3).mul (A) )
					.add ( p.pow (2).mul (B) )
					.add ( p.mul (C) )
					.add ( D )
					.div (
						( p.sub (q) ).mul( p.sub (r) ).mul( p.sub (s) )
					)
				).saveTo (P);
				// Q = q-f(q)/((q-p)(q-r)(q-s))
				q.sub (
					     ( q.pow (4) )
					.add ( q.pow (3).mul (A) )
					.add ( q.pow (2).mul (B) )
					.add ( q.mul (C) )
					.add ( D )
					.div (
						( q.sub (p) ).mul( q.sub (r) ).mul( q.sub (s) )
					)
				).saveTo (Q);
				// R = r-f(r)/((r-p)(r-q)(r-s))
				r.sub (
					     ( r.pow (4) )
					.add ( r.pow (3).mul (A) )
					.add ( r.pow (2).mul (B) )
					.add ( r.mul (C) )
					.add ( D )
					.div (
						( r.sub (p) ).mul( r.sub (q) ).mul( r.sub (s) )
					)
				).saveTo (R);
				// S = s-f(s)/((s-p)(s-q)(s-r))
				s.sub (
					     ( s.pow (4) )
					.add ( s.pow (3).mul (A) )
					.add ( s.pow (2).mul (B) )
					.add ( s.mul (C) )
					.add ( D )
					.div (
						( s.sub (p) ).mul( s.sub (q) ).mul( s.sub (r) )
					)
				).saveTo (S);

				if (p.copy (P) + q.copy (Q) + r.copy (R) + s.copy (S) < 1e-8) {
					break;
				} else {
					// on to next iteration
					N++;
				}
			}

			out.htmlText = N + " iterations, roots:\n " + p + ",\n " + q + ",\n " + r + ",\n " + s +
				"\n\nr-s distance at iteration №2: " + rs + " (min " + min_rs + ")" +
				"\n\ncoefficients: " +
				"\n\t" + min_cs.join ("\n\t");

			graphics.clear ();
			graphics.lineStyle (2, 0);
			graphics.moveTo (465 / 2, 0); graphics.lineTo (465 / 2, 465);
			graphics.moveTo (0, 465 / 2); graphics.lineTo (465, 465 / 2);
			graphics.lineStyle (1, 0);
			graphics.moveTo (465 / 4, 0); graphics.lineTo (465 / 4, 465);
			graphics.moveTo (0, 465 / 4); graphics.lineTo (465, 465 / 4);
			graphics.moveTo (3 * 465 / 4, 0); graphics.lineTo (3 * 465 / 4, 465);
			graphics.moveTo (0, 3 * 465 / 4); graphics.lineTo (465, 3 * 465 / 4);
			graphics.drawCircle (
				465 / 2 + 465 / 4 * p.x,
				465 / 2 - 465 / 4 * p.y,
				2);
			graphics.drawCircle (
				465 / 2 + 465 / 4 * q.x,
				465 / 2 - 465 / 4 * q.y,
				2);
			graphics.drawCircle (
				465 / 2 + 465 / 4 * r.x,
				465 / 2 - 465 / 4 * r.y,
				2);
			graphics.drawCircle (
				465 / 2 + 465 / 4 * s.x,
				465 / 2 - 465 / 4 * s.y,
				2);
			for (var i:int = 1; i < values.length / 8; i++) {
				for (var j:int = 0; j < 4; j++) {
					var x0:Number = values [8 * (i - 1) + 2 * j];
					var y0:Number = values [8 * (i - 1) + 2 * j + 1];
					var x1:Number = values [8 * i + 2 * j];
					var y1:Number = values [8 * i + 2 * j + 1];
					arrow (
						465 / 2 + 465 / 4 * x0, 465 / 2 - 465 / 4 * y0,
						465 / 2 + 465 / 4 * x1, 465 / 2 - 465 / 4 * y1,
						255 * (((j + 1) & 1) + 256 * ((((j + 1) >> 1) & 1) + 256 * (((j + 1) >> 2) & 1)))
					);					
				}
			}
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

	private function pick ():Complex {
		if (index == pool.length) {
			pool [index] = new Complex;
		}
		index++;
		return pool [index - 1];
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
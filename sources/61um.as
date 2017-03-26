/*
 * Simple complex arithmetics.
 * Solving random 4th power polynomials as an example.
 */
package {
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import net.hires.debug.Stats;
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

		public function Test () {
			addChild (new Stats);
			with (addChild (out = new TextField)) { autoSize = "left"; y = 100; }
			addEventListener (Event.ENTER_FRAME, calculate);
		}

		public function calculate (e:Event):void {

			A.x = Math.random ();
			B.x = Math.random ();
			C.x = Math.random ();
			D.x = Math.random ();

			// f(z)
			out.text = "equation z^4 + " +
				A.x.toPrecision (4) + " z^3 + " +
				B.x.toPrecision (4) + " z^2 +" +
				C.x.toPrecision (4) + " z +" +
				D.x.toPrecision (4) + " = 0";

			// http://en.wikipedia.org/wiki/Durand-Kerner_method#Explanation
			seed.pow (0).saveTo (p);
			seed.pow (1).saveTo (q);
			seed.pow (2).saveTo (r);
			seed.pow (3).saveTo (s);

			var N:int = 20;
			while (N-->0) {
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
				// on to next iteration
				p.copy (P); q.copy (Q); r.copy (R); s.copy (S);
			}

			out.appendText ("\nroots " + p + ", " + q + ", " + r + ", " + s);
			out.appendText ("\n" + Complex.Debug ());
		}
	}
}

class Complex {
	public var x:Number;
	public var y:Number;

	private static var pool:Vector.<Complex> = new Vector.<Complex>;
	private static var index:int = 0;

	public static function Debug ():String {
		return "Pool length " + pool.length + ", index " + index;
	}

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

	public function copy (z:Complex):void {
		x = z.x;
		y = z.y;
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
		return "(" + x.toPrecision (p) + " " + ((y > 0) ? "+" : "") + y.toPrecision (p) + "i)";
	}
}
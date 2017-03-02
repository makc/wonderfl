// forked from makc3d's Solving a system of linear equations
package {
	import com.bit101.components.InputText;
	import com.bit101.components.Label;
	import com.bit101.components.PushButton;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	/**
	 * Parabola through three points.
	 * @author makc
	 */
	public class Test1 extends Sprite {
		public var X1:InputText;
		public var Y1:InputText;
		public var X2:InputText;
		public var Y2:InputText;
		public var X3:InputText;
		public var Y3:InputText;
		public var A:InputText;
		public var B:InputText;
		public var C:InputText;
		public function Test1 () {
			new Label (this, 10, 10, "X1:");
			(X1 = new InputText (this, 30, 10, "-1")).width = 50;
			new Label (this, 10, 40, "Y1:");
			(Y1 = new InputText (this, 30, 40, "1")).width = 50;

			new Label (this, 90, 10, "X2:");
			(X2 = new InputText (this, 110, 10, "0")).width = 50;
			new Label (this, 90, 40, "Y2:");
			(Y2 = new InputText (this, 110, 40, "-1")).width = 50;

			new Label (this, 170, 10, "X3:");
			(X3 = new InputText (this, 190, 10, "1")).width = 50;
			new Label (this, 170, 40, "Y3:");
			(Y3 = new InputText (this, 190, 40, "1")).width = 50;

			new PushButton (this, 10, 70, "SOLVE", findParabola);

			new Label (this, 10, 100, "x²·");
			(A = new InputText (this, 30, 100)).width = 50;

			new Label (this, 85, 100, "+ x¹·");
			(B = new InputText (this, 110, 100)).width = 50;

			new Label (this, 170, 100, "+");
			(C = new InputText (this, 190, 100)).width = 50;

			findParabola ();
		}

		public function findParabola (whatever:*= null):void {
			var x1:Number = parseFloat (X1.text);
			var y1:Number = parseFloat (Y1.text);
			var x2:Number = parseFloat (X2.text);
			var y2:Number = parseFloat (Y2.text);
			var x3:Number = parseFloat (X3.text);
			var y3:Number = parseFloat (Y3.text);

			var solver:LinearSolver = new LinearSolver;
			solver.prepare (3);
			// we have three equations A * x² + B * x + C = y
			solver.A [0] [0] = x1 * x1; solver.A [0] [1] = x1; solver.A [0] [2] = 1;
			solver.A [1] [0] = x2 * x2; solver.A [1] [1] = x2; solver.A [1] [2] = 1;
			solver.A [2] [0] = x3 * x3; solver.A [2] [1] = x3; solver.A [2] [2] = 1;
			solver.b [0] = y1;
			solver.b [1] = y2;
			solver.b [2] = y3;
			solver.solve ();

			A.text = solver.x [0].toFixed (4);
			B.text = solver.x [1].toFixed (4);
			C.text = solver.x [2].toFixed (4);

			var rect:Rectangle =
			new Rectangle (x1, y1, Number.MIN_VALUE, Number.MIN_VALUE).union (
			new Rectangle (x2, y2, Number.MIN_VALUE, Number.MIN_VALUE).union (
			new Rectangle (x3, y3, Number.MIN_VALUE, Number.MIN_VALUE)));
			rect.inflate (rect.width / 2, rect.height / 2);

			trace (rect)

			graphics.clear ();
			graphics.lineStyle ();
			graphics.beginFill (255 * 256);

			var p:Point = new Point (x1, y1);
			transformIntoScreenSpace (p, rect);
			graphics.drawCircle (p.x, p.y, 10);

			p.x = x2; p.y = y2;
			transformIntoScreenSpace (p, rect);
			graphics.drawCircle (p.x, p.y, 10);

			p.x = x3; p.y = y3;
			transformIntoScreenSpace (p, rect);
			graphics.drawCircle (p.x, p.y, 10);

			graphics.endFill ();
			graphics.lineStyle (1, 255 * 256 * 256);

			for (var i:int = 0; i < 100; i++) {
				p.x = rect.x + 0.01 * i * rect.width;
				p.y = solver.x [0] * p.x * p.x + solver.x [1] * p.x + solver.x [2];
				transformIntoScreenSpace (p, rect);
				graphics [(i < 1) ? "moveTo" : "lineTo"] (p.x, p.y);
			}
		}

		public function transformIntoScreenSpace (pt:Point, rect:Rectangle):void {
			// map from rect to 465x465
			pt.x = 465 * (pt.x - rect.x) / rect.width;
			pt.y = 465 * (pt.y - rect.y) / rect.height;

			pt.y = 465 - pt.y;
		}
	}
}

/**
 * Analytically solves the linear system Ax = b.
 * 
 * <p>A is first decomposed into a lower triangular matrix, L and an
 * upper triangular matrix U:
 * 
 * <pre>
 * Ax = b
 * LUx = b
 * 
 * Then, using forward substitution it solves the equation:
 * 
 * Ly = b
 * 
 * Finally, taking the solution to this system (y), we can solve for x
 * with back substitution:
 * 
 * Ux = y
 * </pre>
 * 
 * @author Drew Cummins, http://lab.generalrelativity.org/file/MatrixND.as
 * @author makc, distilled the solver, hacked L[i][i] to be != 0
 */
class LinearSolver {
	public var n:int = -1;
	public var A:Vector.<Vector.<Number>>;
	public var L:Vector.<Vector.<Number>>;
	public var U:Vector.<Vector.<Number>>;
	public var b:Vector.<Number>;
	public var x:Vector.<Number>;
	public function prepare (numOfVars:int):void {
		if (n != numOfVars) {
			n = numOfVars;
			A = new Vector.<Vector.<Number>> (n, true);
			L = new Vector.<Vector.<Number>> (n, true);
			U = new Vector.<Vector.<Number>> (n, true);
			b = new Vector.<Number> (n, true); // zeroes
			x = new Vector.<Number> (n, true); // zeroes
		} else {
			// zero b, x
			for (var i:int = 0; i < n; i++) {
				b [i] = 0; x [i] = 0;
			}
		}

		for (i = 0; i < n; i++) {
			var Ai:Vector.<Number> = A [i];
			if (Ai == null) {
				A [i] = new Vector.<Number> (n, true); // zeroes
				L [i] = new Vector.<Number> (n, true); // zeroes
				U [i] = new Vector.<Number> (n, true); U [i] [i] = 1; // identity in U
			} else {
				var Li:Vector.<Number> = L [i];
				var Ui:Vector.<Number> = U [i];
				for (var j:int = 0; j < n; j++) {
					// zero matrices A, L, identity in U
					Ai [j] = 0; Li [j] = 0; Ui [j] = (i == j) ? 1 : 0;
				}
			}
		}
	}
	public function solve ():void {
		var dot:Number;
		// non-pivoting Crout algorithm to decompose A into LU
		for (var k:int = 0; k < n; k++) {
			for (var i:int = k; i < n; i++) {
				dot = 0;
				var Li:Vector.<Number> = L [i];
				for (var p:int = 0; p < k; p++) {
					dot += Li [p] * U [p] [k];
				}
				Li [k] = A [i] [k] - dot;
				// a hack to work around non-pivoting algorithm limitation:
				// http://mymathlib.webtrellis.net/matrices/linearsystems/crout.html
				// "If the matrix A is positive definite symmetric or if the matrix is
				// diagonally dominant, then pivoting is not necessary; otherwise the
				// version using pivoting should be used"
				if ((i == k) && (Math.abs (Li [k]) < 1e-13)) Li [k] = 1e-13;
			}
			var Ak:Vector.<Number> = A [k];
			var Lk:Vector.<Number> = L [k];
			var Uk:Vector.<Number> = U [k];
			for (var j:int = k + 1; j < n; j++) {
				dot = 0;
				for (p = 0; p < k; p++) {
					dot += Lk [p] * U [p] [j];
				}
				Uk [j] = ( Ak [j] - dot ) / Lk [k];
			}
		}
		// forward substitution to solve Ly = b
		// (x is used to hold y and x)
		for (i = 0; i < n; i++) {
			dot = 0;
			Li = L [i];
			for (j = 0; j < i; j++) {
				dot += Li [j] * x [j];
			}
			x [i] = ( b [i] - dot ) / Li [i];
			
		}
		// backward substitution to solve for Ux = y
		for (i = n - 1; i >= 0; i--) {
			dot = 0;
			var Ui:Vector.<Number> = U [i];
			for (j = i + 1; j < n; j++) {
				dot += Ui [j] * x [j];
			}
			// y vector only accessed before solution is set at that index: (x [i] - dot)
			// this is why we don't need another structure to hold y
			x [i] = ( x [i] - dot ) / Ui [i];
		}
	}
}
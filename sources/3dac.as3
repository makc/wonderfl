package {
	import com.actionscriptbible.Example;
	/**
	 * Solving a system of linear equations.
	 * @author makc
	 */
	public class Test1 extends Example {
		public function Test1 () {
			var solver:LinearSolver = new LinearSolver;
			solver.prepare (3);
			solver.A [0] [0] = 1;
				solver.A [1] [1] = 2;
					solver.A [2] [2] = 1;
			solver.b [0] = 1;
			solver.b [1] = 4;
			solver.b [2] = 3;
			solver.solve ();
			trace (solver.x); // 1,2,3
			solver.prepare (3);
					solver.A [0] [2] = 1;
				solver.A [1] [1] = 2;
			solver.A [2] [0] = 1;
			solver.b [0] = 1;
			solver.b [1] = 4;
			solver.b [2] = 3;
			solver.solve ();
			trace (solver.x); // 3,2,1
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
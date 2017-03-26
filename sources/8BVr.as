// forked from makc3d's Parabola through 3 points
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
	 * Fixed using explicit version.
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

			// handle ds == 0, right...
			var d1:Number = x1 * (x1 - x2 - x3) + x2 * x3;
			var d2:Number = x2 * (x2 - x1 - x3) + x1 * x3;
			var d3:Number = x3 * (x3 - x1 - x2) + x1 * x2;

			var a:Number = y1 / d1 + y2 / d2 + y3 / d3;
			var b:Number = - y1 * (x2 + x3) / d1 - y2 * (x1 + x3) / d2 - y3 * (x1 + x2) / d3;
			var c:Number = y1 - a * x1 * x1 - b * x1;

			A.text = a.toFixed (4);
			B.text = b.toFixed (4);
			C.text = c.toFixed (4);

			var rect:Rectangle =
			new Rectangle (x1, y1, Number.MIN_VALUE, Number.MIN_VALUE).union (
			new Rectangle (x2, y2, Number.MIN_VALUE, Number.MIN_VALUE).union (
			new Rectangle (x3, y3, Number.MIN_VALUE, Number.MIN_VALUE)));
			rect.inflate (rect.width / 2, rect.height / 2);

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
				p.y = a * p.x * p.x + b * p.x + c;
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
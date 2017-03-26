package  
{
	import flash.display.Sprite;
	import flash.geom.Point;
	
	/**
	* A circle through three points.
	* @author makc
	* @license WTFPLv2, http://sam.zoy.org/wtfpl/
	*/
	public class Circle3 extends Sprite
	{
		public var p1:Point = new Point (465 * Math.random (), 465 * Math.random ());
		public var p2:Point = new Point (465 * Math.random (), 465 * Math.random ());
		public var p3:Point = new Point (465 * Math.random (), 465 * Math.random ());
		public var v1:Point = new Point (Math.random () - Math.random (), Math.random () - Math.random ());
		public var v2:Point = new Point (Math.random () - Math.random (), Math.random () - Math.random ());
		public var v3:Point = new Point (Math.random () - Math.random (), Math.random () - Math.random ());

		public function Circle3 () 
		{
			// speed up
			v1.normalize (5);
			v2.normalize (5);
			v3.normalize (5);

			addEventListener ("enterFrame", loop);
		}

		public function loop (e:*):void
		{
			// move points around randomly
			p1 = p1.add (v1);
			if ((p1.x < 0) || (p1.x > 465)) { p1.x = Math.max (0, Math.min (465, p1.x)); v1.x *= -1; }
			if ((p1.y < 0) || (p1.y > 465)) { p1.y = Math.max (0, Math.min (465, p1.y)); v1.y *= -1; }
			p2 = p2.add (v2);
			if ((p2.x < 0) || (p2.x > 465)) { p2.x = Math.max (0, Math.min (465, p2.x)); v2.x *= -1; }
			if ((p2.y < 0) || (p2.y > 465)) { p2.y = Math.max (0, Math.min (465, p2.y)); v2.y *= -1; }
			p3 = p3.add (v3);
			if ((p3.x < 0) || (p3.x > 465)) { p3.x = Math.max (0, Math.min (465, p3.x)); v3.x *= -1; }
			if ((p3.y < 0) || (p3.y > 465)) { p3.y = Math.max (0, Math.min (465, p3.y)); v3.y *= -1; }

			// prepare graphics
			graphics.clear ();
			graphics.lineStyle (0, 0x7FFF);
			graphics.beginFill (0, 0);

			// find circle center
			var c:Point = findCircleCenter (p1, p2, p3);
			if (c != null) {
				// find circle radius
				var r:Point = c.subtract (p1);
				// draw circle
				graphics.drawCircle (c.x, c.y, r.length);
			} else {
				// draw line
				var line:Point = p2.subtract (p1);
				if (line.length == 0) {
					line = p2.subtract (p3);
					if (line.length == 0) {
						line.x = 1;
					}
				}

				line.normalize (1000);

				graphics.moveTo (p2.x - line.x, p2.y - line.y);
				graphics.lineTo (p2.x + line.x, p2.y + line.y);
			}

			graphics.endFill ();

			// draw points
			graphics.lineStyle ();
			graphics.beginFill (0xFF0000);
			graphics.drawCircle (p1.x, p1.y, 3.5);
			graphics.drawCircle (p2.x, p2.y, 3.5);
			graphics.drawCircle (p3.x, p3.y, 3.5);
		}

		/*
		* Finds circle center from three points.
		* @see http://mathforum.org/library/drmath/view/54323.html
		*/
		public function findCircleCenter (p1:Point, p2:Point, p3:Point):Point
		{
			var bc:Number = (p1.length * p1.length - p2.length * p2.length) * 0.5;
			var cd:Number = (p2.length * p2.length - p3.length * p3.length) * 0.5;
			var det:Number = (p1.x - p2.x) * (p2.y - p3.y) - (p2.x - p3.x) * (p1.y - p2.y);

			if (det == 0) {
				// center at infinity
				return null;
			}

			return new Point (
				(bc * (p2.y - p3.y) - cd * (p1.y - p2.y)) / det,
				(cd * (p1.x - p2.x) - bc * (p2.x - p3.x)) / det
			);
		}

	}

}
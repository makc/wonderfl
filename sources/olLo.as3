package  {
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Point;
	/**
	 * Exploring formula in Jim Armstrong "Cardinal Splines Part 4"
	 * @see http://algorithmist.wordpress.com/2009/10/06/cardinal-splines-part-4/
	 */
	[SWF(frameRate="60")]
	public class CS4 extends Sprite {
		public function CS4 () {
			time = 0;
			addEventListener ("enterFrame", loop);

			// generate 7 random points
			var i:int, ptsShape:Shape;
			pts = [];
			ptsShape = new Shape; addChild (ptsShape);
			ptsShape.graphics.beginFill (0x123456, 1);
			for (i = 0; i < 7; i++) {
				var pt:Point = new Point (
					40 + (465 - 2 * 40) * Math.random (),
					40 + (465 - 2 * 40) * Math.random ()
				);
				ptsShape.graphics.drawCircle (pt.x, pt.y, 5);
				pts.push (pt);
			}
		}
		private var time:Number;
		private var pts:Array;
		private function loop (e:*):void {
			// pulse s
			time += 0.1; if (time > 6.2831853) time -= 6.2831853;
			var s:Number = 2 * Math.sin (time);
			// draw spline
			var i:int, j:int;
			graphics.clear ();
			graphics.lineStyle (0, 0xFF);
			for (i = 0; i < pts.length - 1; i++) {
				var P1:Point = (i < 1) ? pts [pts.length - 1] : pts [i - 1];
				var P2:Point = pts [i];
				var P3:Point = pts [i + 1];
				var P4:Point = (i < pts.length - 2) ? pts [i + 2] : pts [0];
				for (j = 0; j < 100 + 1; j++) {
					var t:Number = j * 0.01;
					var Pt:Point = new Point (
						// x
						s * ( -t * t * t + 2 * t * t - t) * P1.x +
						s * ( -t * t * t + t * t) * P2.x +
						(2 * t * t * t - 3 * t * t + 1) * P2.x +
						s * (t * t * t - 2 * t * t + t) * P3.x +
						( -2 * t * t * t + 3 * t * t) * P3.x +
						s * (t * t * t - t * t) * P4.x,
						// y
						s * ( -t * t * t + 2 * t * t - t) * P1.y +
						s * ( -t * t * t + t * t) * P2.y +
						(2 * t * t * t - 3 * t * t + 1) * P2.y +
						s * (t * t * t - 2 * t * t + t) * P3.y +
						( -2 * t * t * t + 3 * t * t) * P3.y +
						s * (t * t * t - t * t) * P4.y
					);
					if (i + j == 0)
						graphics.moveTo (Pt.x, Pt.y);
					else
						graphics.lineTo (Pt.x, Pt.y);
				}
			}
		}
	}
}
package  
{
	import flash.events.MouseEvent;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	/**
	 * <<< DIRTY GEOMETRY >>>
	 * 
	 * Computes the closest point to a bezier curve
	 * 
	 * @author Andre Michelle
	 */
	[SWF(width='465',height='490',frameRate='50',backgroundColor='0x202020')]
	public class BezierClosestPoint extends Sprite 
	{
		private const point: Point = new Point();
		
		private const pointA: AnchorPoint = new AnchorPoint();
		private const pointB: AnchorPoint = new AnchorPoint();
		private const pointC: AnchorPoint = new AnchorPoint();
		private const pointD: AnchorPoint = new AnchorPoint();

		private const EPSILON: Number = 1e-8;
		private const R: Vector.<Number> = new Vector.<Number>( 3, true );
		
		private const textField: TextField = new TextField();
		
		private var dragAnchor: AnchorPoint;

		public function BezierClosestPoint()
		{
			pointA.x = 140.0;
			pointA.y = 140.0;
			addChild( pointA );

			pointB.x = 300;
			pointB.y = 300;
			addChild( pointB );

			pointC.x = 200;
			pointC.y = 320;
			addChild( pointC );

			pointD.x = 120;
			pointD.y = 300;
			addChild( pointD );
			
			textField.mouseEnabled = false;
			textField.selectable = false;
			textField.autoSize = TextFieldAutoSize.LEFT;
			textField.defaultTextFormat = new TextFormat( 'Arial', 10, 0x999999 );
			addChild( textField );

			addEventListener( Event.ENTER_FRAME, enterFrame );
			addEventListener( MouseEvent.MOUSE_DOWN, mouseDown );
			addEventListener( MouseEvent.MOUSE_UP, mouseUp );
		}
		
		private function mouseDown( event: MouseEvent ): void
		{
			dragAnchor = event.target as AnchorPoint;
		}

		private function mouseUp( event: MouseEvent ): void
		{
			dragAnchor = null;
		}

		private function enterFrame( event: Event ): void
		{
			if( dragAnchor == pointA )
			{
				pointA.x = mouseX;
				pointA.y = mouseY;
			}
			else
			if( dragAnchor == pointB )
			{
				pointB.x = mouseX;
				pointB.y = mouseY;
			}
			else
			if( dragAnchor == pointC )
			{
				pointC.x = mouseX;
				pointC.y = mouseY;
			}
			else
			if( dragAnchor == pointD )
			{
				pointD.x = mouseX;
				pointD.y = mouseY;
			}
			
			var x0: Number = pointA.x;
			var y0: Number = pointA.y;
			var x1: Number = pointC.x;
			var y1: Number = pointC.y;
			var x2: Number = pointB.x;
			var y2: Number = pointB.y;

			graphics.clear();
			graphics.lineStyle( 0, 0xFF9900 );
			graphics.moveTo( x0, y0 );
			graphics.curveTo( x1, y1, x2, y2 );
			
			point.x = pointD.x;
			point.y = pointD.y;

			var distance: Number = getClosestPoint( x0, y0, x1, y1, x2, y2, point );
			
			textField.text = 'Distance to bezier: ' + distance.toFixed( 2 );

			graphics.lineStyle( 0, 0x777777 );
			graphics.moveTo( pointD.x, pointD.y );
			graphics.lineTo( point.x, point.y );
		}

		private function getClosestPoint( x0: Number, y0: Number, x1: Number, y1: Number, x2: Number, y2: Number, point: Point ): Number
		{
			var ax: Number;
			var ay: Number;
			var dx: Number;
			var dy: Number;
			var px: Number = point.x;
			var py: Number = point.y;
			var dd: Number = Number.MAX_VALUE;

			var t: Number;

			var i: int = 0;
			var n: int = getClosestT( x0, y0, x1, y1, x2, y2, px, py );

			for( ; i < n ; ++i )
			{
				t = R[i];

				if( t <= 0.0 )
				{
					ax = x0;
					ay = y0;
				}
				else
				if( t >= 1.0 )
				{
					ax = x2;
					ay = y2;
				}
				else
				{
					ax = eval( x0, x1, x2, t );
					ay = eval( y0, y1, y2, t );
				}

				dx = px - ax;
				dy = py - ay;

				if( dx * dx + dy * dy < dd )
				{
					point.x = ax;
					point.y = ay;

					dd = dx * dx + dy * dy;
				}
			}

			return Math.sqrt( dd );
		}
		
		private function eval( v0: Number, v1: Number, v2: Number, t: Number ): Number
		{
			var t1: Number = 1.0 - t;

			return v0 * t1 * t1 + v1 * 2.0 * t1 * t + v2 * t * t;
		}
		
		private function getClosestT( x0: Number, y0: Number, x1: Number, y1: Number, x2: Number, y2: Number, px: Number, py: Number ): int 
		{
			var dx: Number = x0 - px;
			var dy: Number = y0 - py;

			var ex: Number = x0 - 2.0 * x1 + x2;
			var ey: Number = y0 - 2.0 * y1 + y2;
			var fx: Number = 2.0 * x1 - 2.0 * x0;
			var fy: Number = 2.0 * y1 - 2.0 * y0;

			var d: Number = 2.0 * ( ex * ex + ey * ey );

			var a: Number;
			var b: Number;
			
			var u: Number;
			var v: Number;
			var w: Number;
			
			var p: Number;
			var q: Number;
			var r: Number;
			var x: Number;

			if( 0.0 == d )
			{
				b = ( fx * fx + fy * fy ) + 2.0 * ( dx * ex + dy * ey );

				if( b < 0.0 )
				{
					if( -b > EPSILON )
						return 0;
				}
				else
				if( b < EPSILON )
					return 0;

				R[ 0 ] = -( fx * dx + fy * dy ) / b;
				return 1;
			}
			else
			{
				var dInv: Number = 1.0 / d;

				a = 3.0 * ( fx * ex + fy * ey ) * dInv;
				b = ( ( fx * fx + fy * fy ) + 2.0 * ( dx * ex + dy * ey ) ) * dInv;
				p = -a * a * 0.33333333333 + b;
				q = a * a * a * 0.074074074074074 - a * b * 0.33333333333 + ( fx * dx + fy * dy ) * dInv;
				r = q * q * 0.25 + p * p * p * 0.037037037037037;

				if( r >= 0.0 ) 
				{
					r = Math.sqrt( r );
					x = sqrt3( -q * 0.5 + r ) + sqrt3( -q * 0.5 - r ) - a * 0.33333333333;
				}
				else
				{
					x = 2.0 * Math.sqrt( -p * 0.33333333333 ) * Math.cos( Math.atan2( Math.sqrt( -r ), -q * 0.5 ) * 0.33333333333 ) - a * 0.33333333333;
				}

				u = x + a;
				v = x * x + a * x + b;
				w = u * u - 4.0 * v;

				if( w < 0.0 )
				{
					R[ 0 ] = x;
					return 1;
				}

				if( w > 0.0 )
				{
					w = Math.sqrt( w );
					
					R[ 0 ] = x;
					R[ 1 ] = -( u + w ) * 0.5;
					R[ 2 ] =  ( w - u ) * 0.5;
					return 3;
				}

				R[ 0 ] = x;
				R[ 1 ] = -u * 0.5;
				return 2;
			}
		}

		private function sqrt3( x: Number ): Number 
		{
			if( x > 0.0 ) 
				return Math.pow( x, 0.33333333333 );
			else
			if( x < 0.0 ) 
				return -Math.pow( -x, 0.33333333333 );

			return 0.0;
		}
	}
}

import flash.display.Sprite;

class AnchorPoint extends Sprite
{
	public function AnchorPoint()
	{
		graphics.beginFill( 0xFFFFFF, 0.1 );
		graphics.drawCircle( 0.0, 0.0, 8.0 );
		graphics.endFill();

		graphics.beginFill( 0xFFFFFF, 0.8 );
		graphics.drawCircle( 0.0, 0.0, 2.0 );
		graphics.endFill();
	}
}
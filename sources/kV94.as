package  
{

	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	/**
	 * @author http://www.dreamincode.net/forums/user/112276-atik97/
	 * original PYTHON snippet available here http://www.dreamincode.net/code/snippet2911.htm
	 *	
	 * @author Nicolas Barradeau
	 * http://en.nicoptere.net
	 */
	public class LeastSquares extends Sprite 
	{
		private var points:Vector.<Point> = new Vector.<Point>();
		
		public function LeastSquares() 
		{
			stage.addEventListener( MouseEvent.MOUSE_DOWN, reset );
		}
		
		private function reset(e:MouseEvent):void 
		{
			graphics.clear();
			graphics.lineStyle( 0 );

			var p:Point = new Point( mouseX, mouseY );
			points.push( p );
			for each( p in points )
			{
				graphics.drawCircle( p.x, p.y, 2 );
			}
			
			var x:int = stage.stageWidth;
                        
			p = leastSquares( points );//least squares computation
			
			graphics.lineStyle( 0, 0xFF0000 );
			graphics.moveTo( 0, p.x * 0 + p.y );
			graphics.lineTo( x, p.x * x + p.y );
			
		}
		
		private function leastSquares( points:Vector.<Point> ):Point
		{
			
			var n:int = points.length;
			var sum_x:Number = 0, sum_y:Number = 0, sum_xx:Number = 0, sum_xy:Number = 0;
			
			for each( var p:Point in points )
			{
				sum_x += p.x;
				sum_y += p.y;
				sum_xx += ( p.x * p.x );
				sum_xy += ( p.x * p.y );
			}
			
			var a:Number = ( -sum_x * sum_xy + sum_xx * sum_y ) / ( n * sum_xx - sum_x * sum_x );
			var b:Number = ( -sum_x * sum_y + n * sum_xy ) / ( n * sum_xx - sum_x * sum_x );
			
			return new Point( b, a );
		}
		
	}
}

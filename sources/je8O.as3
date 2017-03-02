// forked from nicoptere's least squares straight line
package  
{

	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	
	/**
	 * @author Sardelis, D. and Valahas, T. 
	 * http://mathworld.wolfram.com/LeastSquaresFittingPerpendicularOffsets.html
	 *	
	 * @author makc
	 * http://makc3d.wordpress.com
	 */
	public class LeastSquares extends Sprite 
	{
		private var points:Vector.<Point> = new Vector.<Point>();
		
		public function LeastSquares() 
		{
			stage.quality = "medium"; // some lines could be pretty extreme
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
                        
			var v:Vector3D = leastSquares( points );//least squares computation
			
			graphics.lineStyle( 0, 0xFF0000 );
			graphics.moveTo( 0, v.x * 0 + v.y );
			graphics.lineTo( x, v.x * x + v.y );
			
			graphics.lineStyle( 0, 0x00FFFF );
			graphics.moveTo( 0, v.z * 0 + v.w );
			graphics.lineTo( x, v.z * x + v.w );
		}
		
		private function leastSquares( points:Vector.<Point> ):Vector3D
		{
			
			var n:int = points.length;
			var sum_x:Number = 0, sum_y:Number = 0, sum_xx:Number = 0, sum_xy:Number = 0;
			var sum_yy:Number = 0;
			
			for each( var p:Point in points )
			{
				sum_x += p.x;
				sum_y += p.y;
				sum_xx += ( p.x * p.x );
				sum_xy += ( p.x * p.y );
				sum_yy += ( p.y * p.y );
			}
			
			var B:Number = (
				(sum_yy - sum_y * sum_y / n) - (sum_xx - sum_x * sum_x / n)
			) / (
				2 * (sum_x * sum_y / n - sum_xy)
			);

			var root:Number = Math.sqrt (B * B + 1);
			var b1:Number = -B -root;
			var b2:Number = -B +root;

			var a1:Number = (sum_y - b1 * sum_x) / n;
			var a2:Number = (sum_y - b2 * sum_x) / n;
			
			return new Vector3D (b1, a1, b2, a2);
		}
		
	}
}

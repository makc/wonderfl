/**
* IKで糸の束っぽいもの（　少し重いです。　）
*/
package {
    import flash.display.Sprite;
    public class FlashTest extends Sprite {
        public function FlashTest() {
            // write as3 code here..
			stage.addChild( new TailLine() );           
        }
    }
}
        
    	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
		
	internal class TailLine extends Bitmap
	{
		private var lines	:Array;
		
		public function TailLine():void
		{
			addEventListener( Event.ADDED_TO_STAGE, init );
		}
		
		private function init( e:Event ):void
		{
			removeEventListener( Event.ADDED_TO_STAGE, init );
			
			bitmapData = new BitmapData( stage.stageWidth, stage.stageHeight, true, 0x00000000 );
			
			lines = [];
			for (var i:int = 0; i < 50; i++)
			{
				var radius	:Number = Math.random() * 10;
				var radian	:Number = Math.random() * Math.PI*2;
				
				var line:IKline = new IKline();
				line.x = Math.cos( radian ) * radius;
				line.y = Math.sin( radian ) * radius;
				line.segmentLeng = 20;	
				line.segmentNum	 = 8;
				line.gravity	 = 0;	
				line.friction	 = Math.random() * 0.2 + 0.7;	
				line.color = 0x334422;
				lines.push( line );
			}
			
			addEventListener( Event.ENTER_FRAME, loop );
		}
		
		private function loop( evt:Event ):void
		{
			var _x	:Number	= stage.mouseX;
			var _y	:Number	= stage.mouseY;
			
			bitmapData.lock();
			bitmapData.fillRect( bitmapData.rect, 0x00 );
			
			for each(var line:IKline in lines ) 
			{
				line.nextFrame( _x, _y );
				bitmapData.draw( drawLine( line ), new Matrix( 1,0,0,1,line.x,line.y ) );
			}
			bitmapData.unlock();
		}
		
		private function drawLine( line:IKline ):Shape
		{
			var segments:Array	= line.segments;
			var leng	:int	= segments.length;
			var shape	:Shape	= new Shape();
			var g		:Graphics = shape.graphics;
			
			g.moveTo( segments[0].x, segments[0].y );
			for ( var i :int = 0; i < leng-2; i++ )
			{
				var xc:Number = ( segments[i].x + segments[i + 1].x ) / 2;
				var yc:Number = ( segments[i].y + segments[i + 1].y ) / 2;
				
				g.lineStyle( 1-i/(leng-2), line.color, 1-i/(leng-2) );
				g.curveTo( segments[i].x, segments[i].y, xc, yc );
			}
			
			return shape;
		}
	}
     
	internal class IKline
	{
		public var segments /*Segment*/:Array = [];
		
		public var x			:Number = 0;
		public var y			:Number = 0;
		
		public var segmentLeng	:int = 20;
		public var segmentNum	:int = 8;
		public var gravity		:Number = 0;
		public var friction		:Number = 1;
		public var color		:uint = 0x888888;
		
		public function IKline():void
		{
			this.gravity	= gravity;
			this.friction	= friction;
			
			var segment:Segment = new Segment( 0 * i );
			segments.push( segment );
			
			for (var i:int = 1; i < segmentNum; i++) 
			{
				segment = new Segment( segmentLeng-0.5 * i );
				segments.push( segment );
			}
		}
		
		public function nextFrame( _x:int, _y:int ):void
		{
			drag( segments[0], _x, _y );
			for ( var i:int = 1; i < segmentNum; i++ )
			{
				var segmentA:Segment = segments[i];
				var segmentB:Segment = segments[i - 1];
				drag( segmentA, segmentB.x, segmentB.y );
			}
		}
		
		private function drag( segment:Segment, xpos:Number, ypos:Number ):void
		{
			segment.next();
			
			var dx		:Number = xpos - segment.x;
			var dy		:Number = ypos - segment.y;
			var radian	:Number = Math.atan2( dy, dx );
			segment.rotation = radian * 180 / Math.PI;
			
			var pin	:Point	= segment.getPin();
			var w	:Number = pin.x - segment.x;
			var h	:Number = pin.y - segment.y;
			
			segment.x = xpos - w;
			segment.y = ypos - h;
			segment.setVector();
			
			segment.vx *= friction;
			segment.vy *= friction;
			segment.vy += gravity;
		}
	}
    
	internal class Segment extends Sprite
	{
		private var segmentLeng	:Number;
		public  var vx			:Number = 0;
		public  var vy			:Number = 0;
		
		private var prevX		:Number = 0;
		private var prevY		:Number = 0;
		
		public function Segment( segmentLeng:Number ):void
		{
			this.segmentLeng = segmentLeng;
		}
		
		public function next():void
		{
			x += vx;
			y += vy;
		}
		
		public function setVector():void
		{
			if( prevX ) vx = x - prevX;
			if( prevY ) vy = y - prevY;
			
			prevX = x;
			prevY = y;
		}
		
		public function getPin():Point
		{
			var angle	:Number = rotation * Math.PI / 180;
			var xpos	:Number = x + Math.cos( angle ) * segmentLeng;
			var ypos	:Number = y + Math.sin( angle ) * segmentLeng;
			
			return new Point( xpos, ypos );
		}
	}   
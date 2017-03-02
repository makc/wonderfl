package
{
	import flash.display.Sprite;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.geom.ColorTransform;
	import flash.filters.BlurFilter;
	import net.hires.debug.Stats;

	public class MetaBall extends Sprite
	{
		private var _size:int = 60;
		private var _num:int = 10;
		private var _canvas:BitmapData = new BitmapData( 600,  600 , true , 0x00000000 );
		private var _bmpData:BitmapData = new BitmapData( 600,  600 , true , 0x00000000 );
		private var _rect:Rectangle = new Rectangle( 0 , 0 , 600 , 600 );
		private var _objAry:Array = new Array();
		private var _alphaArray:Array = new Array();
		private var _container:Sprite = new Sprite();
		
		public function MetaBall()
		{
			addChild( new Stats() );
    
			_container.visible = false;
			addChild( _container );
			
			var adjust:Number = _size / ( 1636 / 2 ); 
			
			var matrix:Matrix = new Matrix();
			matrix.identity();
			matrix.scale( adjust , adjust );
			
			for ( var i:uint = 0; i < _num; i ++ )
			{
				var sp:Sprite = new Sprite();
				drawGradationCircle( sp.graphics , matrix );
				sp.x = 135 + 100 * int( i % 3 );
				sp.y = 135 + 100 * int( i / 3 );
				
				_container.addChild( sp );
				_objAry.push( sp );
			}
			addChild( new Bitmap( _canvas ) );
			
			for ( var j:int = 0; j < 256; j ++ )
			{
				if ( j < 200 ) _alphaArray.push( 0 );
				else _alphaArray.push( 0xFF000000 );
			}
			
			addEventListener( Event.ENTER_FRAME , enterFrameHandler );
		}
		
		private function enterFrameHandler( e:Event ):void
		{
			_objAry[ _num - 1 ].x = mouseX;
			_objAry[ _num - 1 ].y = mouseY;
			
			_bmpData.fillRect( _rect , 0x000000 );
			_bmpData.draw( _container );
			_bmpData.paletteMap( _bmpData , _rect , _rect.topLeft , null , null , null , _alphaArray );
			
			_canvas.colorTransform( _rect , new ColorTransform( 1 , 1 , 1 , 0.95 ) );
			_canvas.applyFilter( _canvas , _canvas.rect , new Point( 0 , 0 ) , new BlurFilter( 8 , 8 ) );
			_canvas.draw( _bmpData );
			_canvas.applyFilter( _canvas , _canvas.rect , new Point( 0 , 0 ) , new BlurFilter( 2 , 2 ) );
		}
		
		private function drawGradationCircle( g:Graphics , m:Matrix ):void
		{
			g.beginGradientFill( "radial", [ 0x000000 , 0x000000] , [ 1 , 0 ] ,  [ 110 , 255 ] , m );
			g.drawCircle( 0 , 0 , _size );
			g.endFill();
		}
	}
}
////////////////////////////////////////////////////////////////////////////////
//
//  外部画像を1pxの列ごとに表示
//
////////////////////////////////////////////////////////////////////////////////
package
{
	import flash.display.* ;
	import flash.events.* ;
	import flash.net.* ;
	import flash.system.* ;
	import caurina.transitions.Tweener ;
	
	[SWF(width="500", height="500", backgroundColor="0xFFFFFF", frameRate="30")]
	public class SliceEffect extends Sprite
	{
		private var _loader:Loader ;
		private var _loaderInfo:LoaderInfo ;
		
		public function SliceEffect( )
		{
			init( ) ;
		}
		
		private function init( ):void
		{
			stage.scaleMode = StageScaleMode.NO_SCALE ;
			stage.align = StageAlign.TOP_LEFT ;
			
			Security.loadPolicyFile( "http://www.twist-cube.com/wonderfl/crossdomain.xml" ) ;
			
			var loaderContext:LoaderContext = new LoaderContext( ) ;
			loaderContext.checkPolicyFile = true ;
			
			_loader = new Loader( ) ;
			_loader.load( new URLRequest( "http://www.twist-cube.com/wonderfl/logo.png" ), loaderContext ) ;
			
			_loaderInfo = _loader.contentLoaderInfo ;
			_loaderInfo.addEventListener( Event.COMPLETE, onLoadComplete ) ;
		}
		
		private function onLoadComplete( event:Event ):void
		{
			_loaderInfo.removeEventListener( Event.COMPLETE, onLoadComplete ) ;
			var bitmapList:SliceBitmap = new SliceBitmap( _loader ) ;
			
			var nStartX:Number = Math.floor( ( stage.stageWidth - _loader.width ) / 2 ) ;
			var nStartY:Number = Math.floor( ( stage.stageHeight - _loader.height ) / 2 ) ;
			
			var nLength:uint = bitmapList.list.length ;
			var bmp:Bitmap ;
			for ( var i:uint = 0; i < nLength; i++ )
			{
				bmp = bitmapList.list[ i ] ;
				bmp.alpha = 0 ;
				bmp.x = nStartX + 1000 * Math.random( ) - 500 ;
				bmp.y = nStartY + i + 1000 * Math.random( ) - 500 ;
				addChild( bmp ) ;
				
				Tweener.addTween(
					bmp, 
					{
						alpha : 1,
						x     : nStartX,
						y     : nStartY + i,
						time  : 1.5,
						delay : 0.005 * i,
						transition : "easeOutElastic"
					}
				) ;
			}
		}
	}
}


import flash.display.* ;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Rectangle;

class SliceBitmap
{
	private var _originImage:DisplayObject ;
	private var _list:Array = new Array( ) ;
	
	public function SliceBitmap( _originImage:DisplayObject )
	{
		this._originImage = _originImage ;
		init( ) ;
	}
	
	private function init( ):void
	{
		var mtx:Matrix = new Matrix( ) ;
		var clip:Rectangle = new Rectangle( 0, 0, _originImage.width, 1 ) ;
		
		var nLength:uint = _originImage.height ;
		for ( var i:uint = 0; i < nLength; i++ )
		{
			var bmpData:BitmapData = new BitmapData( _originImage.width, 1, true, 0x00FFFFFF ) ;
			bmpData.draw( _originImage, mtx, new ColorTransform(), null, clip, false ) ; 
			
			var bmp:Bitmap = new Bitmap( bmpData ) ;
			_list.push( bmp ) ;
			
			mtx.translate( 0, -1 ) ;
		}
	}
	
	public function get list( ):Array
	{
		return _list ;
	}
}
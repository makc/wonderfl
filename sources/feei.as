////////////////////////////////////////////////////////////////////////////////
//
//  外部画像を1pxごとに表示[2]
//  
//  (1)http://wonderfl.net/c/2CNH
//  (2)http://wonderfl.net/c/1qQx
//  
//  (1)のコードを参考に、(2)を調整
//  
////////////////////////////////////////////////////////////////////////////////
package
{
	import flash.display.* ;
	import flash.events.* ;
	import flash.filters.ColorMatrixFilter ;
	import flash.net.* ;
	import flash.system.* ;
	import flash.utils.getTimer ;
	import flash.geom.ColorTransform ;
	
	[SWF(width="500", height="500", backgroundColor="0xFFFFFF", frameRate="30")]
	public class ParticleEffect2 extends Sprite
	{
		private var _loader:Loader ;
		private var _loaderInfo:LoaderInfo ;
		private var _particleList:ParticleList ;
		private var _canvas:BitmapData ;
		private var _startTime:int ;
		
		public function ParticleEffect2( )
		{
			init( ) ;
		}
		
		private function init( ):void
		{
			stage.scaleMode = StageScaleMode.NO_SCALE ;
			stage.align = StageAlign.TOP_LEFT ;
			stage.quality = StageQuality.LOW ;
			
			Security.loadPolicyFile( "http://www.twist-cube.com/wonderfl/crossdomain.xml" ) ;
			
			var loaderContext:LoaderContext = new LoaderContext( ) ;
			loaderContext.checkPolicyFile = true ;
			
			_loader = new Loader( ) ;
			_loader.load( new URLRequest( "http://www.twist-cube.com/wonderfl/logo02.png" ), loaderContext ) ;
			
			_loaderInfo = _loader.contentLoaderInfo ;
			_loaderInfo.addEventListener( Event.COMPLETE, onLoadComplete ) ;
		}
		
		private function onLoadComplete( event:Event ):void
		{
			_loaderInfo.removeEventListener( Event.COMPLETE, onLoadComplete ) ;
			
			var nStartX:Number = Math.floor( ( stage.stageWidth - _loader.width ) / 2 ) ;
			var nStartY:Number = Math.floor( ( stage.stageHeight - _loader.height ) / 2 ) ;
			
			_particleList = new ParticleList( _loader ) ;
			
			var current:Particle ;
			var nLength:uint = _particleList.list.length ;
			for ( var i:uint = 0; i < nLength; i++ )
			{
				current = _particleList.list[ i ] ;
				current.x = nStartX + current.tx ;
				current.y = nStartY + current.ty - stage.stageHeight - 5000 * Math.random( ) ;
			}
			
			_canvas = new BitmapData( stage.stageWidth, stage.stageHeight, true, 0xFFFFFFFF ) ;
			addChild( new Bitmap( _canvas ) ) ;
			
			_startTime = getTimer( ) ;
			addEventListener( Event.ENTER_FRAME, onRender );
		}
		
		private function onRender( event:Event ):void
		{
			var nStartX:Number = Math.floor( ( stage.stageWidth - _loader.width ) / 2 ) ;
			var nStartY:Number = Math.floor( ( stage.stageHeight - _loader.height ) / 2 ) ;
			var current:Particle ;
			var nLength:uint = _particleList.list.length ;
			var now:int = getTimer( ) ;
			var wait:Number ;
			
			_canvas.lock( ) ;
			//_canvas.fillRect( _canvas.rect, 0xFFFFFFFF ) ;
			
			var nTargetX:Number ;
			var nTargetY:Number ;
			var nDiffX:Number ;
			var nDiffY:Number ;
			var nStepX:Number ;
			var nStepY:Number ;
			for ( var i:uint = 0; i < nLength; i++ )
			{
				current = _particleList.list[ i ] ;
				
				// 下から吸着させる
				wait = ( 1 - ( current.ty / _loader.height ) ) * 8000 ;
				
				if ( _startTime + wait > now ) continue ; 
				
				nTargetX = nStartX + current.tx ;
				nTargetY = nStartY + current.ty ;
				nDiffX = nTargetX - current.x ;
				nDiffY = nTargetY - current.y ;
				nStepX = nDiffX * .2 ;
				nStepY = nDiffY * .2 ;
				
				if ( Math.abs( nDiffX ) < 1 )
				{
					current.x = nTargetX ;
				}
				else
				{
					current.x += nStepX ;
				}
				
				if ( Math.abs( nTargetY ) < 1 )
				{
					current.y = nStartY ;
				}
				else
				{
					current.y += nStepY ;
				}
				
				_canvas.setPixel( current.x, current.y, current.color ) ;
			}
			
			_canvas.unlock( ) ;
			_canvas.colorTransform( _canvas.rect, new ColorTransform( 1, 1, 1, 1, 15, 15, 15 ) );
		}
	}
}


import flash.display.* ;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Rectangle;

class ParticleList
{
	private var _originImage:DisplayObject ;
	private var _list:Array = new Array( ) ;
	
	public function ParticleList( _originImage:DisplayObject )
	{
		this._originImage = _originImage ;
		init( ) ;
	}
	
	private function init( ):void
	{
		var nW:Number = _originImage.width ;
		var nH:Number = _originImage.height 
		var originBitmapData:BitmapData = new BitmapData( _originImage.width, _originImage.height, true, 0xFFFFFFFF ) ;
		originBitmapData.draw( _originImage ) ;
		
		var originBitmap:Bitmap = new Bitmap( originBitmapData ) ;
		
		for ( var i:uint = 0; i < nW; i++ )
		{
			for ( var j:int = 0; j < nH; j++ )
			{
				var color:uint = originBitmapData.getPixel32( i, j ) ;
				if ( color == 0xFFFFFFFF ) continue ;
				
				_list.push( new Particle( i, j, color ) ) ;
			}
		}
	}
	
	public function get list( ):Array
	{
		return _list ;
	}
	
	public function set list( _list:Array ):void
	{
		this._list = _list ;
	}
}


class Particle
{
	public var tx:Number = 0 ;
	public var ty:Number = 0 ;
	public var x:Number = 0 ;
	public var y:Number = 0 ;
	public var color:int = 0 ;
	
	public function Particle( x:Number, y:Number, color:int )
	{
		this.tx = x ;
		this.ty = y ;
		this.x = x ;
		this.y = y ;
		this.color = color ;
	}
}
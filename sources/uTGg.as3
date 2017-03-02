// forked from northprint's ExtendBlur
package
{
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.filters.*;
	import flash.net.*;
	import flash.system.*;

	[SWF(width="465", height="465", backgroundColor="0x000000", frameRate="20")]

	public class ExtendBlur extends Sprite
	{  
		private var _imgloader:Loader;
		private var _screen:Bitmap;
		
		private var _x:Number = 260;
		private var _y:Number = 50;
		private var _dx:Number = 260;
		private var _dy:Number = 50;
		
		private var _buffer:BitmapData;
		private var _source_l:BitmapData;
		private var _source_b:BitmapData;
		private var _noise:BitmapData;
		private var _offset:Array = [new Point(), new Point()];
		private var _matrix:Matrix = new Matrix(1, 0, 0, 1, 0, 0);
		
		function ExtendBlur()
		{
			Security.loadPolicyFile("http://narayama.heteml.jp/crossdomain.xml");
			
			//imageの取得
			_imgloader = new Loader();
			_imgloader.contentLoaderInfo.addEventListener(Event.COMPLETE,ImgLoadHandler);
			_imgloader.load(new URLRequest("http://narayama.heteml.jp/test/pixelbender/tokyo.jpg"), new LoaderContext(true));
			
			_buffer = new BitmapData(stage.stageWidth, stage.stageHeight, false, 0);
			_noise = new BitmapData(stage.stageWidth/5, stage.stageHeight/3, false, 0);
			
			stage.fullScreenSourceRect = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
			stage.addEventListener(MouseEvent.CLICK, stageClick);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		}

		private function ImgLoadHandler(e:Event):void
		{
			var loaderInfo:LoaderInfo = LoaderInfo(e.currentTarget);
			var loader:Loader = loaderInfo.loader;
			var bitmapData:BitmapData = new BitmapData(loader.width+1, loader.height, true);
			bitmapData.draw(loader);
			
			_source_l = bitmapData.clone();
			_source_b = bitmapData.clone();
			
			_source_l.applyFilter(_source_l, _source_l.rect, new Point(), new BlurFilter(3, 3));
			_source_l.colorTransform(_source_l.rect, new ColorTransform(1, 1, 1, 1, 48, 48, 48, 0));
			_source_l.colorTransform(_source_l.rect, new ColorTransform(1, 1, 1, 1, -160, -160, -160, 0));
			_source_l.colorTransform(_source_l.rect, new ColorTransform(0.1, 0.1, 0.1, 1));
			_source_b.colorTransform(_source_l.rect, new ColorTransform(0.5, 0.5, 0.5, 1, 0, 0, 0, 0));
			
			_screen = new Bitmap(_buffer);
			_screen.scaleX = _screen.scaleY = stage.stageWidth / loader.height;
			_screen.smoothing = true;
			
			addChild(_screen);
			
			stage.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		private function enterFrameHandler(e:Event):void
		{
			_x = (_x + _dx) / 2;
			_y = (_y + _dy) / 2;
			
			_buffer.lock();
			_buffer.copyPixels(_source_b, _source_b.rect, new Point(0, 0));
			
			_offset[0].x += 0.8;
			_offset[0].y += 0.2;
			_noise.perlinNoise(40, 16, 2, 0, false, false, 0, true, _offset);
			_noise.colorTransform(_noise.rect, new ColorTransform(1, 1, 1, 1, 200, 200, 200, 0));
			_noise.colorTransform(_noise.rect, new ColorTransform(1, 1, 1, 1, -254, -254, -255, 0));
			
			var temp:BitmapData = _source_l.clone();
			
			_matrix.identity();
			_matrix.scale(5, 3);
			temp.draw(_noise, _matrix, null, BlendMode.SUBTRACT);
			
			for(var i:int = 0; i < 15; i++)
			{
				_matrix.identity();
				_matrix.translate(-_x, -_y);
				_matrix.scale(1 + 0.03*i, 1 + 0.03*i);
				_matrix.translate(_x, _y);
				_buffer.draw(temp, _matrix, null, BlendMode.ADD);
			}
			
			_source_l.scroll(1, 0);
			_source_b.scroll(1, 0);
			_source_l.copyPixels(_source_l, new Rectangle(_source_l.width-1, 0, 1, _source_l.height), new Point(0, 0));
			_source_b.copyPixels(_source_b, new Rectangle(_source_b.width-1, 0, 1, _source_b.height), new Point(0, 0));
			
			_buffer.unlock();
		}
		
		private function onMouseMove( e:MouseEvent ) :void
		{
			_dx = Math.min(Math.max(stage.mouseX, 0), stage.stageWidth);
			_dy = Math.min(Math.max(stage.mouseY, 0), stage.stageHeight) / 2;
		}
		
		private function stageClick( e:MouseEvent ) :void
		{
			switch(stage.displayState) {
			case StageDisplayState.NORMAL:
				stage.displayState = StageDisplayState.FULL_SCREEN;
				break;
			case StageDisplayState.FULL_SCREEN:
			default:
				stage.displayState = StageDisplayState.NORMAL;
				break;
			}
		}
	}
}
//-----------------------------------------------------
// title : Ripple
// 波紋効果の練習
//-----------------------------------------------------
package 
{
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.BitmapDataChannel;
    import flash.display.BlendMode;
    import flash.display.Loader;
    import flash.display.Sprite;
    import flash.display.StageQuality;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.filters.ConvolutionFilter;
    import flash.filters.DisplacementMapFilter;
    import flash.filters.DisplacementMapFilterMode;
    import flash.geom.ColorTransform;
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.net.URLRequest;
    import flash.system.LoaderContext; 
    
    [SWF(backgroundColor="0x000000", frameRate="30")]
    public class AnimationsProject extends Sprite
    {
        
       
		private const IMAGE_URL:String = "http://www.chutaicho.com/image/leafs.jpg";
		private const RIPPLE_SIZE:int = 20; //波紋サイズ
		private const BUFFER_SCALE:Number = 0.2; //バッファ用ビットマップのサイズ
        
        private var _sample:Bitmap;
        private var _buffer1:BitmapData;
        private var _buffer2:BitmapData;
        private var _defData:BitmapData;
        private var _scale:Number;
        private var _matrix:Matrix; 
        private var _fullRect:Rectangle;
        private var _drawRect:Rectangle;
        private var _origin:Point;
        private var _filter:DisplacementMapFilter;
        private var _convoFilter:ConvolutionFilter;
        private var _colorTransform:ColorTransform;
		
        public function AnimationsProject()
        {
        	init();
        }	
        private function init():void
        {
        	stage.quality = StageQuality.MEDIUM;
        	var req:URLRequest = new URLRequest(IMAGE_URL);
        	var loader:Loader = new Loader();
        	loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadComplete);	
        	loader.load( req, new LoaderContext(true));
        }
        private function loadComplete(e:Event):void
        {    
            e.target.removeEventListener(Event.COMPLETE, loadComplete);
            var sw:int = stage.stageWidth;
            var sh:int = stage.stageHeight;
            
            // 読み込んだ画像を一旦リサイズ
            var source:Bitmap = e.target.loader.content as Bitmap;
            var resizeData:BitmapData = new BitmapData(sw, sh);
            source.width = sw;
            source.height = sh;
            resizeData.draw( source );
            
            _sample = new Bitmap(resizeData);
            addChild(_sample);
			
			// ちょっと傾ける
			rotationX = -30;
			
            
            
            _buffer1 = new BitmapData(_sample.width*BUFFER_SCALE, _sample.height*BUFFER_SCALE, false, 0x000000);
            _buffer2 = new BitmapData(_buffer1.width, _buffer1.height, false, 0x000000);
            _defData = new BitmapData(_sample.width, _sample.height, false, 0x7f7f7f);

            
            _fullRect = new Rectangle(0, 0, _buffer1.width, _buffer1.height);
            _drawRect = new Rectangle();
            
            _filter = new DisplacementMapFilter(_buffer1, new Point(), BitmapDataChannel.BLUE, BitmapDataChannel.BLUE, 50, 50, DisplacementMapFilterMode.WRAP);
            _sample.filters = [_filter];
        
            addEventListener(Event.ENTER_FRAME, enterFrameHandler);
        
            _convoFilter = new ConvolutionFilter(3, 3, [0.5, 1, 0.5, 1, 0, 1, 0.5, 1, 0.5], 3);
            _colorTransform = new ColorTransform(1, 1, 1, 1, 0, 128, 128);       
            _matrix = new Matrix(_defData.width/_buffer1.width, 0, 0, _defData.height/_buffer1.height);
            
            stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseHandler);
        }
		private function mouseHandler(e:MouseEvent):void
        {
            var rad:int = RIPPLE_SIZE/2 * -1;
            _drawRect.x = ( rad + _sample.mouseX ) * BUFFER_SCALE;	
            _drawRect.y = ( rad + _sample.mouseY ) * BUFFER_SCALE;
            _drawRect.width = _drawRect.height = RIPPLE_SIZE * BUFFER_SCALE;
            _buffer1.fillRect(_drawRect, 0xFF);
        }
        private function enterFrameHandler(event : Event) : void
        {
            var temp:BitmapData = _buffer2.clone();
            _buffer2.applyFilter(_buffer1, _fullRect, new Point(), _convoFilter);
            _buffer2.draw(temp, null, null, BlendMode.SUBTRACT, null, false);
            _defData.draw(_buffer2, _matrix, _colorTransform, null, null, true);
            _filter.mapBitmap = _defData;
            _sample.filters = [_filter];
            temp.dispose();
            switchBuffers();
        }
        // バッファの入れ替え
        private function switchBuffers():void
        {
            var temp : BitmapData;
            temp = _buffer1;
            _buffer1 = _buffer2;
            _buffer2 = temp;
        }
    }
}
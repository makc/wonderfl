package {
    import flash.events.*;
    import flash.display.*;
    import flash.geom.*;
    import flash.text.*;
    import flash.filters.*;
    
    public class FlashTest extends Sprite {
    		private var _canvas : BitmapData;
    		private var W : Number = stage.stageWidth;
    		private var H : Number = stage.stageHeight;
    		private var _dst : BitmapData;
    		
        public function FlashTest() {
        		_canvas = new BitmapData(W, H, false, 0x000000);
            _dst = _canvas.clone();
            addEventListener(Event.ENTER_FRAME, onEnterFrame);
            addChild(new Bitmap(_canvas));
        }
        
        private var _t : uint = 0;
        
        private function onEnterFrame(e : Event) : void
        {
        		_canvas.lock();
        		for(var i : uint = 0;i < 40;i++){
	        		var cx : int = Math.random() * W;
	        		var cy : int = Math.random() * H;
	        		var w : int = Math.random() * 50;
	        		var h : int = Math.random() * 50;
	        		var r : Number = Math.sqrt(
	        			(H / 2 - cy) * (H / 2 - cy) +
	        			(W / 2 - cx) * (W / 2 - cx)
	        			);
	        		var phase : Number = -_t * 0.02 + r / 50;
	        		var cmf : ColorMatrixFilter = new ColorMatrixFilter([
	        			0, 0.5, 0.5, 0, Math.sin(phase) * 40,
	        			0.5, 0, 0.5, 0, Math.sin(phase + Math.PI * 1 / 3) * 40,
	        			0.5, 0.5, 0, 0, Math.sin(phase + Math.PI * 2 / 3) * 40,
	        			0, 0, 0, 0, 0
        			]);
        			_canvas.applyFilter(_canvas, new Rectangle(int(cx - w/2), int(cy - h/2), w, h), new Point(int(cx - w/2), int(cy - h/2)), cmf);
        		}
        		_canvas.unlock();
        		_t++;
        }
    }
}
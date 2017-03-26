package {
    import flash.display.*;
    import flash.events.*;
    import flash.geom.*;
    import flash.net.*;
    import flash.system.*;
    public class FlashTest extends Sprite {
        
        // standard deviation for gaussian blur
        private static const SIGMA:Number = 8;
        // alpha for exponential averaging
        // low values cause quantization error and slow focus change
        // bug I think the gradual focus change and inital fade-in is nice...
        // high values lead to shakiness
        // but a little shaking makes it look more 3D..
        private static const MIX:ColorTransform = new ColorTransform(1, 1, 1, 1. / 16);
        
        private var src:BitmapData;
        private var dst:BitmapData;
        private var ih:Number;
        private var b:Bitmap;
        private var m:Matrix = new Matrix();
        
        public function FlashTest() {
            loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, function (e:UncaughtErrorEvent):void { Wonderfl.log(e.error); });
            var l:Loader = new Loader();
            l.contentLoaderInfo.addEventListener(Event.COMPLETE, complete);
            l.load(new URLRequest('http://farm1.static.flickr.com/169/466833793_ea8e0e3de6_b.jpg'), new LoaderContext(true));
        }
        
        private function complete(e:Event):void {
            src = e.target.content.bitmapData;
            dst = new BitmapData(src.width, src.height, false, 0xffffff);
            ih = 1. / src.height;
            b = new Bitmap(dst);
            b.x = (stage.stageWidth - src.width) / 2;
            b.y = (stage.stageHeight - src.height) / 2;
            addChild(b);
            stage.addEventListener(Event.ENTER_FRAME, enterFrame);
        }
        
        private function enterFrame(e:Event):void {
            // use Box-Muller method to generate two random variables
            var u:Number = Math.sqrt(-2 * Math.log(Math.random())) * SIGMA;
            var v:Number = Math.random() * 2 * Math.PI;
            var dx:Number = u * Math.cos(v);
            var dy:Number = u * Math.sin(v);
            
            // set matrix to skew around the cursor
            var focus:Number = b.mouseY * ih;
            m.tx = dx * focus;
            m.ty = dy * focus;
            m.c = -dx * ih;
            m.d = 1 - dy * ih;
            
            // exponential average contribution
            dst.draw(src, m, MIX);
        }
        
    }
}
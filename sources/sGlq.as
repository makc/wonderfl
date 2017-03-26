package {
    import flash.display.*;
    import flash.events.*;
    import flash.geom.*;
    import flash.net.*;
    import flash.system.*;
    import com.actionscriptbible.*;
    public class FlashTest extends Example {
        
        public var bitmap:Bitmap;
        
        public function FlashTest() {
            // this line matters
            Security.allowDomain("*");
            // okay, let's load some random picture
            var request:URLRequest = new URLRequest ("http://www.google.me/images/srpr/logo3w.png");
            // we are going to load in bitmap loader
            var loader:Loader = new Loader;
            // do smth unexpected: http://www.flasher.ru/forum/blog.php?b=588
            loader.addEventListener (Event.ADDED, onBitmapAdded);
            // wait for complete
            loader.contentLoaderInfo.addEventListener (Event.COMPLETE, onImageLoaded);
            // load it
            loader.load (request);
            
        }
        
        public function onBitmapAdded (e:Event):void {
            if (bitmap == null) bitmap = e.target as Bitmap;
        }
        
        public function onImageLoaded (e:Event):void {
            if (bitmap == null) return;
            
            var bd:BitmapData = bitmap.bitmapData.clone();
                
            var ct:ColorTransform = new ColorTransform (0, 1, 0);
            bd.colorTransform (bd.rect, ct);
            
            with (addChild (new Bitmap (bd))) { x = 100; y = 200; } 
        }
    }
}
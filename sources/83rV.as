/*
 * 
 * Draw a Tasty Ramen !
 * 
 * You can edit and modify every piece of this code.
 * Load more pictures of GU (ingredients of ramen)
 * from flickr or draw one by yourself.
 * Make it look tasty.
 *
 */
package{
    import flash.display.Sprite;
    import flash.display.*;
    import flash.events.*;
    import flash.net.*;
    import flash.system.*;

    [SWF(width="460", height="460", backgroundColor="0xFFFFFF", frameRate="30")]

    public class FlashTest extends Sprite{
        private var _loader        :Loader;
        private var _loaderInfo    :LoaderInfo;
        private var _loader_GU     :Loader;
        private var _loaderInfo_GU :LoaderInfo;

        private var RAMEN_URL :String   = "http://farm3.static.flickr.com/2589/3787648401_0b3d62a314_o.png";
        private var NARUTO1_URL :String = "http://farm3.static.flickr.com/2466/3787648415_1f857d46cf_o.png";
        private var NARUTO2_URL :String = "http://farm4.static.flickr.com/3560/3788456920_5101174e6c_o.png";
        private var MENMA_URL :String   = "http://farm3.static.flickr.com/2628/3788456906_91e357245f_o.png";

        public function FlashTest(){
            init();
        }
        private function init():void{
            stage.scaleMode=StageScaleMode.NO_SCALE;
            stage.align=StageAlign.TOP_LEFT;

            _loader=new Loader();
            _loader.load(new URLRequest(RAMEN_URL));

            _loaderInfo=_loader.contentLoaderInfo;
            _loaderInfo.addEventListener(Event.COMPLETE,onLoadComplete);
        }
        private function onLoadComplete(event:Event):void{
            _loaderInfo.removeEventListener(Event.COMPLETE,onLoadComplete);
            addChild(_loader);
            load_GU();
        }
        private function load_GU():void{
            _loader_GU=new Loader();
            _loader_GU.load(new URLRequest(NARUTO1_URL));

            _loaderInfo_GU=_loader_GU.contentLoaderInfo;
            _loaderInfo_GU.addEventListener(Event.COMPLETE,onLoadComplete_GU);
        }
        private function onLoadComplete_GU(event:Event):void{
            _loaderInfo_GU.removeEventListener(Event.COMPLETE,onLoadComplete_GU);

            // position adjustment for GU
            _loader_GU.x = 160;
            _loader_GU.y = 160;
            addChild(_loader_GU);
        }

    }
}

package {
    import flash.display.*;
    import flash.events.*;
    import flash.net.*;
    import flash.system.*;
    import org.si.b3.*;

    [SWF(frameRate="12")]
    public class FlashTest extends Sprite {
        public function FlashTest() {
            var url:String = "http://assets.wonderfl.net/images/related_images/d/d5/d5ef/d5efb19c4e6af524be0c935a932a653b475d2200";
            var loader:Loader = new Loader;
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoad);
            loader.load(new URLRequest(url), new LoaderContext(true));
        }

        private var mc:CMLMovieClip;
        private var tex:CMLMovieClipTexture;
        private var frame:int = 0;

        private function onLoad(e:Event):void {
            var bmd:BitmapData = Bitmap(e.target.content).bitmapData;
            mc = new CMLMovieClip(this, 0, 0, 465, 465);
            tex = new CMLMovieClipTexture(bmd, 0, 0, bmd.width/4, bmd.height/3, true, 11);
            addEventListener("enterFrame", onEnterFrame);
        }

        private function onEnterFrame(e:Event):void {
            mc.clearScreen();
            //mc.drawTexture(tex, 0, 0, 1, 1, 0, null, null, frame); // why doesn't this work?
            mc.copyTexture(tex, 0, 0, frame);
            frame++;
            if(frame == tex.animationPattern.length) frame = 0;
        }
    }
}
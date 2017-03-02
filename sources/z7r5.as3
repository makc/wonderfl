package {
    import flash.display.*;
    import flash.events.*;
    import flash.net.*;
    import flash.system.*;
    import org.si.utils.ByteArrayExt;
    import org.si.sion.*;

    public class AmenBreak extends Sprite {
        private var _samples:Vector.<Number> = new Vector.<Number>;
        private var _driver:SiONDriver = new SiONDriver();

        public function AmenBreak() {
            var url:String = "http://assets.wonderfl.net/images/related_images/3/39/39a4/39a4a6ce8a3e260ce6a141f9aa2c8fa894b0f80a";
            var loader:Loader = new Loader;
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoad);
            loader.load(new URLRequest(url), new LoaderContext(true));
        }

        private function onLoad(e:Event):void {
            var bae:ByteArrayExt = new ByteArrayExt;
            bae.fromBitmapData(Bitmap(e.target.content).bitmapData);
            bae.endian="littleEndian";
            for(var cnt:Number = bae.length/2; cnt; cnt--) {
                _samples.push(bae.readShort() / 0x8000);
            }
            _driver.setSamplerWave(0, _samples);
            _driver.play();
            _driver.playSound(0);
        }
    }
}
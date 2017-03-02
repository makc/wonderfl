package {
    import flash.display.*;
    import flash.events.*;
    import flash.media.*;
    import flash.utils.*;
    public class FlashTest extends Sprite {
        
        // adjusted after experimental results
        private static const freq_low:Array = [16, 18, 20, 22];
        private static const freq_high:Array = [27, 30, 34];
        
        private var player:Object;
        private var ba:ByteArray;
        
        public function FlashTest() {
            stage.scaleMode = StageScaleMode.EXACT_FIT;
            ba = new ByteArray();
            addEventListener(Event.ENTER_FRAME, frame);
            stage.frameRate = 60;
        }
        
        private static function i2x(index:int):Number {
           return index * 465. / 256;
        }
        
        private function readSingle(index:int, _:int=0, __:Array=null):Number {
            ba.position = index * 4;
            return ba.readFloat();
        }
        
        private function frame(e:Event):void {
            try { SoundMixer.computeSpectrum(ba, true, 0); } catch (e:Error) { return; }
            graphics.clear();
            graphics.beginFill(0x000000);
            graphics.moveTo(0, 465);
            ba.position = 0;
            for (var i:int = 0; i < 256; i++) {
                graphics.lineTo(i2x(i), 465 - 465 * ba.readFloat());
            }
            graphics.lineTo(465, 465);
            graphics.endFill();
            graphics.lineStyle(0, 0xff0000, 0.5);
            for each (var fl:int in freq_low) {
                graphics.moveTo(i2x(fl), 0);
                graphics.lineTo(i2x(fl), 465);
            }
            graphics.lineStyle(0, 0x00ffff, 0.5);
            for each (var fh:int in freq_high) {
                graphics.moveTo(i2x(fh), 0);
                graphics.lineTo(i2x(fh), 465);
            }
            var low:Array = freq_low.map(readSingle);
            var high:Array = freq_high.map(readSingle);
            graphics.lineStyle(0, 0x000000);
            for (var il:int = 0; il < 4; il++) {
                for (var ih:int = 0; ih < 3; ih++) {
                    var alpha:Number = low[il] * high[ih];
                    graphics.beginFill(0xff00ff, alpha);
                    graphics.drawRect(30 * ih + 100, 30 * il, 30, 30);
                    graphics.endFill();
                }
            }
            graphics.lineStyle(NaN);
        }
        
    }
}
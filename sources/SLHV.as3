// forked from H.S's forked from: ff[2]: Mouse Position Gradation 
// forked from makc3d's ff[2]: Mouse Position Gradation 
// forked from H.S's forked from: Mouse Position Gradation 
// forked from kawamura's Mouse Position Gradation 
package {
    import flash.display.*;
    import flash.events.Event;
    import flash.geom.*;
    import flash.media.*;
    import flash.net.URLRequest;
    import flash.system.LoaderContext;
    import flash.utils.getTimer;
    public class FlashTest extends Sprite {
        private var sprite:Sprite;
        private var loaderArray:Array = [];
        private var soundArray:Array = [];
        public function FlashTest() {
            // write as3 code here..
            if (stage) init();
            else addEventListener(Event.ADDED_TO_STAGE, init);
        }
        private var day:SoundChannel, stDay:SoundTransform = new SoundTransform(0, 0);
        private var evening:SoundChannel, stEvening:SoundTransform = new SoundTransform(0, 0);
        private var night:SoundChannel, stNight:SoundTransform = new SoundTransform(0, 0);
        private var midnight:SoundChannel, stMidnight:SoundTransform = new SoundTransform(0, 0);
        private var insects:BitmapData = new BitmapData (64, 64, true), insectsRect:Rectangle = insects.rect;
        private function init(e:Event = null):void 
        {
            removeEventListener(Event.ADDED_TO_STAGE, init);
            // entry point
            day = (new Sound(new URLRequest("http://chococornet.sakura.ne.jp/sound/sound_1.mp3"))).play (0, int.MAX_VALUE, stDay);
            evening = (new Sound(new URLRequest("http://chococornet.sakura.ne.jp/sound/sound_2.mp3"))).play (0, int.MAX_VALUE, stEvening);
            night = (new Sound(new URLRequest("http://chococornet.sakura.ne.jp/sound/sound_3.mp3"))).play (0, int.MAX_VALUE, stNight);
            midnight = (new Sound(new URLRequest("http://chococornet.sakura.ne.jp/sound/mute.mp3"))).play (0, int.MAX_VALUE, stMidnight);
            var i:int, s:Sprite, b:Bitmap;
            for (i = 0; i < 2; i++) {
                loaderArray.push(new Loader());
            }
            for (i = 0; i < 2; i++) {
                loaderArray.push(s = new Sprite());
                s.addChild(new Loader());
                s.addChild(b = new Bitmap(insects));
                b.x = b.y = 58; b.height = 96; b.scaleX = b.scaleY;
            }
            soundArray.push(stDay, stEvening, stNight, stMidnight);
            loaderArray[0].load(new URLRequest("http://chococornet.sakura.ne.jp/img/background_day_2.png"), new LoaderContext(true));
            loaderArray[0].name = "day";
            loaderArray[1].load(new URLRequest("http://chococornet.sakura.ne.jp/img/background_evening.png"), new LoaderContext(true));
            loaderArray[1].name = "evening";
            loaderArray[2].getChildAt(0).load(new URLRequest("http://chococornet.sakura.ne.jp/img/background_night_2.png"), new LoaderContext(true));
            loaderArray[2].name = "night";
            loaderArray[3].getChildAt(0).load(new URLRequest("http://chococornet.sakura.ne.jp/img/background_midnight.png"), new LoaderContext(true));
            loaderArray[3].name = "midnight";
            stage.addChildAt(loaderArray[0], 0);
            addChild(loaderArray[1]);
            sprite = new Sprite();
            addChild(sprite);
            blendMode = "layer";
            sprite.blendMode = "alpha";
            var g:Graphics;
            g = sprite.graphics;
            var type:String = GradientType.LINEAR;
            var colors:Array = [0x0, 0x0];
            var alphas:Array = [1.0, 0.0];
            var ratios:Array = [0.0, 0xFF];
            var matrix:Matrix = new Matrix();
            matrix.createGradientBox(20, 100, 0.0 * Math.PI, 80, 0);
            g.beginGradientFill(type, colors, alphas, ratios, matrix);
            g.drawRect(0, 0, 100, 100);
            sprite.width = stage.stageWidth;
            sprite.height = stage.stageHeight;
            addEventListener(Event.ENTER_FRAME, enterFrameHandler);
        }
        private function enterFrameHandler(e:Event):void 
        {
            var t:int = getTimer ();
            insects.fillRect (insectsRect, 0);
            insects.lock ();
            for (var i:int = 15; i < 75; i++) {
                var ix:int = 32 * Math.sin (t * 1e-4 * i + Math.sin (i));
                var iy:int = 64 * Math.sin (t * 1.234e-4 * Math.sqrt (i) - i * i);
                var ia:int = 200 - 2.5 * Math.sqrt (ix * ix + iy * iy);
                insects.setPixel32 (32 + ix, iy, (ia << 24) + 0xFFFFAF);
            }
            insects.unlock (insectsRect);

            var rate:Number = stage.mouseX / stage.stageWidth;
            if (rate > 0.95) rate = 1;
            if (rate < 0.05) rate = 0;
            var name:String = stage.getChildAt(0).name
            soundArray[0].volume = (name=="day" || name=="night")? 1 - rate : rate;
            soundArray[1].volume = 1 - soundArray[0].volume;
            soundArray[2].volume = 0;
            soundArray[3].volume = 0; midnight.soundTransform = stMidnight;
            day.soundTransform = stDay; evening.soundTransform = stEvening;
            night.soundTransform = stNight;
            var g:Graphics;
            g = sprite.graphics;
            g.clear();
            var type:String = GradientType.LINEAR;
            var colors:Array = [0x0, 0x0];
            var alphas:Array = [1.0, 0.0];
            var ratios:Array = [0.0, 0xFF];
            var matrix:Matrix = new Matrix();
            matrix.createGradientBox(30, 100, 0.0 * Math.PI, -30 + 130 * rate, 0);
            g.beginGradientFill(type, colors, alphas, ratios, matrix);
            g.drawRect(0, 0, 100, 100);
            if ((rate > 0.95 && (name == "day" || name == "night")) || (rate < 0.05 && (name == "evening" || name == "midnight")) ) {
                loaderArray.push(loaderArray.shift());
                soundArray.push(soundArray.shift());
                stage.removeChildAt(0);
                removeChildAt(0);
                stage.addChildAt(loaderArray[0], 0);
                addChildAt(loaderArray[1], 0);
                sprite.blendMode = (sprite.blendMode == "alpha")? "erase" : "alpha";
            }
        }
    }
}
// forked from makc3d's ff[6]: Mouse Position Gradation 
// forked from H.S's ff[5]: Mouse Position Gradation 
// forked from makc3d's ff[4]: Mouse Position Gradation 
// forked from H.S's forked from: ff[2]: Mouse Position Gradation 
// forked from makc3d's ff[2]: Mouse Position Gradation 
// forked from H.S's forked from: Mouse Position Gradation 
// forked from kawamura's Mouse Position Gradation 
package {
    import com.bit101.components.CheckBox;
    import com.bit101.components.Slider;
    import com.bit101.components.Style;
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
        private var kiki:Shape, kikiLoader:Loader, kikiData:BitmapData, matrix:Matrix = new Matrix;
        private var autoMoveFlag:Boolean;
        public var rate:Number = 0;
        public var speed:Number = 0.005
        private function kikiLoads(event:Event):void {
            kikiData = Bitmap(LoaderInfo(event.target).content).bitmapData; kikiLoader = null;
        }
        public function FlashTest() {
            // write as3 code here..
            if (stage) init();
            else addEventListener(Event.ADDED_TO_STAGE, init);
        }
        private var day:SoundChannel, stDay:SoundTransform = new SoundTransform(0, 0);
        private var evening:SoundChannel, stEvening:SoundTransform = new SoundTransform(0, 0);
        private var night:SoundChannel, stNight:SoundTransform = new SoundTransform(0, 0);
        private var midnight:SoundChannel, stMidnight:SoundTransform = new SoundTransform(0, 0);
        private var rain:SoundChannel, stRain:SoundTransform = new SoundTransform(0, 0);
        private var insects:BitmapData = new BitmapData (64, 64, true), insectsRect:Rectangle = insects.rect;
        private function init(e:Event = null):void 
        {
            removeEventListener(Event.ADDED_TO_STAGE, init);
            // entry point
            day = (new Sound(new URLRequest("http://chococornet.sakura.ne.jp/sound/sound_1.mp3"))).play (0, int.MAX_VALUE, stDay);
            evening = (new Sound(new URLRequest("http://chococornet.sakura.ne.jp/sound/sound_2.mp3"))).play (0, int.MAX_VALUE, stEvening);
            night = (new Sound(new URLRequest("http://chococornet.sakura.ne.jp/sound/sound_3.mp3"))).play (0, int.MAX_VALUE, stNight);
            midnight = (new Sound(new URLRequest("http://chococornet.sakura.ne.jp/sound/mute.mp3"))).play (0, int.MAX_VALUE, stMidnight);
            rain = (new Sound(new URLRequest("http://chococornet.sakura.ne.jp/sound/sound_rain.mp3"))).play (0, int.MAX_VALUE, stRain);            
            var i:int, s:Sprite, b:Bitmap;
            for (i = 0; i < 5; i++) {
                loaderArray.push(s = new Sprite());
                s.addChild(new Loader());
                if (i == 0) {
                    var spriteSky:Sprite = new Sprite();
                    spriteSky.scrollRect = new Rectangle (0, 0, 465, 465);
                    s.addChild(spriteSky);
                    kikiLoader = new Loader();
                    kikiLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, kikiLoads);
                    kikiLoader.load(new URLRequest("http://assets.wonderfl.net/images/related_images/3/39/391d/391d6edbb3af07bacf345c1da6142af6d76e013b"), new LoaderContext(true));
                    var loader:Loader = new Loader();
                    loader.load(new URLRequest("http://chococornet.sakura.ne.jp/img/background_mask.png"), new LoaderContext(true));
                    spriteSky.addChild(kiki = new Shape);
                    spriteSky.addChild(loader);
                    spriteSky.blendMode = "layer";
                    loader.blendMode = "erase";
                }
                if (i == 2 || i == 3) {
                    s.addChild(b = new Bitmap(insects));
                    b.x = b.y = 58; b.height = 96; b.scaleX = b.scaleY;
                }
            }
            soundArray.push(stDay, stEvening, stNight, stMidnight, stRain);
            loaderArray[0].getChildAt(0).load(new URLRequest("http://chococornet.sakura.ne.jp/img/background_day_2.png"), new LoaderContext(true));
            loaderArray[0].name = "day";
            loaderArray[1].getChildAt(0).load(new URLRequest("http://chococornet.sakura.ne.jp/img/background_evening.png"), new LoaderContext(true));
            loaderArray[1].name = "evening";
            loaderArray[2].getChildAt(0).load(new URLRequest("http://chococornet.sakura.ne.jp/img/background_night_2.png"), new LoaderContext(true));
            loaderArray[2].name = "night";
            loaderArray[3].getChildAt(0).load(new URLRequest("http://chococornet.sakura.ne.jp/img/background_midnight.png"), new LoaderContext(true));
            loaderArray[3].name = "midnight";
            loaderArray[4].getChildAt(0).load(new URLRequest("http://chococornet.sakura.ne.jp/img/background_rain.png"), new LoaderContext(true));
            loaderArray[4].name = "rain";
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
            
            with (Style) { BACKGROUND = 0xC0C0C0; LABEL_TEXT = 0xFFFFFF; BUTTON_FACE = 0x3C7FB1; }
            var checkBox:CheckBox = new CheckBox(stage, 308, 385, "AUTO", function(event:Event):void {
                autoMoveFlag = checkBox.selected;
            });
            var slider:Slider = new Slider("horizontal",stage, 353, 385, function(event:Event):void {
                if (checkBox.selected == false) checkBox.selected = autoMoveFlag = true;
                speed =  slider.value / 400;
            });
            slider.maximum = 8;
            slider.minimum = 0.5;
            slider.value = 2;
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

            var g:Graphics = kiki.graphics;
            g.clear(); g.beginFill(0,0.004); g.drawRect(0,0,465,465);
            if (kikiData) {
                var frame:int = (t / 100) % 6;
                var right:Boolean = int (t / 3000) % 2 > 0;
                var scale:Number = right ? -0.4 : 0.6;
                matrix.identity(); matrix.a = scale; matrix.d = Math.abs (scale);
                var kikix:Number, kikiy:Number, kikit:int = t % 3000;
                if (right) {
                    kikix = 0.2 * kikit * matrix.d;
                    kikiy = 120;
                } else {
                    kikix = 0.2 * (3000 - kikit) * matrix.d - 100;
                    kikiy = 75;
                }
                matrix.tx = kikix - 90 * frame * matrix.d;
                matrix.ty = kikiy;
                g.beginBitmapFill (kikiData, matrix, true, true);
                g.drawRect(kikix, kikiy, 90 * matrix.d, 65 * matrix.d);
            }

            if (autoMoveFlag) {
                if (sprite.blendMode == "alpha") rate += speed;
                else rate -= speed;
            }
            else {
                rate = stage.mouseX / stage.stageWidth;
                if (rate > 0.95) rate = 1;
                if (rate < 0.05) rate = 0;
            }
            var name:String = stage.getChildAt(0).name
            soundArray[0].volume = (sprite.blendMode == "alpha")? 1 - rate : rate;
            soundArray[1].volume = 1 - soundArray[0].volume;
            soundArray[2].volume = 0;
            soundArray[3].volume = 0;
            soundArray[4].volume = 0; midnight.soundTransform = stMidnight;
            day.soundTransform = stDay; evening.soundTransform = stEvening;
            night.soundTransform = stNight; rain.soundTransform = stRain;
            g = sprite.graphics;
            g.clear();
            var type:String = GradientType.LINEAR;
            var colors:Array = [0x0, 0x0];
            var alphas:Array = [1.0, 0.0];
            var ratios:Array = [0.0, 0xFF];
            matrix.createGradientBox(30, 100, 0.0 * Math.PI, -30 + 130 * rate, 0);
            g.beginGradientFill(type, colors, alphas, ratios, matrix);
            g.drawRect(0, 0, 100, 100);
            if ((rate >= 1 && (name == "day" || name == "night" || name == "rain")) || (rate <= 0 && (name == "evening" || name == "midnight")) ) {
                if (name == "day" && !Math.floor(Math.random() * 3) || name == "rain") {
                    loaderArray.unshift(loaderArray.pop());
                    loaderArray.push(loaderArray.splice(1, 1)[0]);
                    soundArray.unshift(soundArray.pop());
                    soundArray.push(soundArray.splice(1, 1)[0]);
                }
                loaderArray.splice(3, 0, loaderArray.shift());
                soundArray.splice(3, 0, soundArray.shift());
                stage.removeChildAt(0);
                removeChildAt(0);
                stage.addChildAt(loaderArray[0], 0);
                addChildAt(loaderArray[1], 0);
                sprite.blendMode = (sprite.blendMode == "alpha")? "erase" : "alpha";
            }
        }
    }
}
/**
 * sound from @gaina
 * @author jc at bk-zen.com
 */
package 
{
    import flash.display.Shape;
    import flash.display.Graphics;
    import flash.events.MouseEvent;
    import flash.utils.ByteArray;
    import flash.media.SoundMixer;
    import flash.events.Event;
    import flash.display.Sprite;
    import frocessing.color.ColorHSV;
    [SWF (backgroundColor = "0x000000", frameRate = "30", width = "465", height = "465")]
    public class FlashTest extends Sprite 
    {
        private var shape: Shape;
        private var _byte: ByteArray;
        private var color: uint;
        private var colorHSV: ColorHSV = new ColorHSV(Math.random() * 360);
        private var afterChangeColor: Boolean;
        private var stageWidth: uint;
        private var stageHeight: uint;
        public function FlashTest() 
        {
            // write as3 code here..
            if (stage) init();
            else addEventListener(Event.ADDED_TO_STAGE, init);
        }
        
        private function init(e: Event = null): void
        {
            addChild(shape = new Shape());
            var _sound:PlaySound = new PlaySound("http://www.takasumi-nagai.com/soundfiles/sound007.mp3");
            _byte = new ByteArray();
            addEventListener(Event.ENTER_FRAME, draw);
            stage.addEventListener(Event.RESIZE, onResize)
            stage.addEventListener(MouseEvent.CLICK, onClick);
            onResize();
            changeColor();
        }
        private function onResize(e: Event = null): void
        {
            stageWidth = stage.stageWidth;
            stageHeight = stage.stageHeight;
            graphics.clear();
            graphics.beginFill(0);
            graphics.drawRect(0, 0, stageWidth, stageHeight);
        }
        
        private function draw(e: Event): void 
        {
            if (afterChangeColor) changeColor();
            var g:Graphics = shape.graphics;
            SoundMixer.computeSpectrum(_byte, true, 0);
            var i: int;
            var n: Number = 0;
            var size: int = stageWidth >> 6;
            var centerX: int = stageWidth  >> 1;
            var centerY: int = stageHeight >> 1;
            g.clear();
            var p: Number = 0;
            while (i++ < 32)
            {
                n = _byte.readFloat();
                p += n;
                if (p > 8) afterChangeColor = true;
                g.beginFill(downColor(color, n), 1);
                g.drawCircle(centerX,  centerY, centerX - size * i);
                g.endFill();
            }
        }
        
        private function onClick(e: MouseEvent): void 
        {
            changeColor();
        }
        
        private static function downColor(argb: uint, n: Number): uint
        {
            var alpha: uint = argb >> 24 & 0xFF;
            var r: uint = argb >> 16 & 0xFF;
            var g: uint = argb >> 8 & 0xFF;
            var b: uint = argb & 0xFF;
            return (alpha << 24) | (((r * n) & 0xFF) << 16) | (((g * n) & 0xFF) << 8) | ((b * n) & 0xFF);
        }
        
        private function changeColor():void 
        {
            afterChangeColor = false;
            colorHSV.h += Math.random() * 10 + 30;
            color = colorHSV.value;
        }
    }
}
import flash.events.Event;
import flash.media.Sound;
import flash.media.SoundLoaderContext;
import flash.media.SoundTransform;
import flash.net.URLRequest;

class PlaySound
{
    private var sound:Sound;

        public function PlaySound(url:String)
        {
            sound = new Sound();
            var _context:SoundLoaderContext = new SoundLoaderContext(1000, true);
            sound.addEventListener(Event.COMPLETE, SoundLoadeComplete);
            sound.load(new URLRequest(url), _context);
        }
        
        private function SoundLoadeComplete(e:Event):void 
        {
            sound.play(0, 10, new SoundTransform(0.3, 0));
        }
}
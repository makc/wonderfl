package
{
    import com.bit101.components.*;
    import flash.display.*;
    import flash.events.*;
    import flash.geom.*;
    import flash.media.*;
    import flash.net.*;
    import flash.text.*;
    import flash.utils.*;
    
    [SWF(width = 465, height = 465, frameRate = 60)]
    public class Main extends Sprite
    {
        private const URL:String = "http://www.takasumi-nagai.com/soundfiles/sound001.mp3";
        
        private const W:int  = stage.stageWidth;
        private const H:int  = stage.stageHeight >> 2;
        private const CL:int = H;
        private const CR:int = H * 3;
        
        private var sound:Sound = new Sound();
        private var sndch:SoundChannel;
        
        private var waveL:Vector.<Number>;
        private var waveR:Vector.<Number>;
        private var length:uint;
        
        private var disp:BitmapData = new BitmapData(W, H << 2, false);
        private var rect:Rectangle  = new Rectangle(0, 0, 1, 0);
        private var scale:int       = 1;
        
        public function Main():void
        {
            loadSound();
        }
        
        private function loadSound():void
        {
            var tf:TextField
                        = new TextField();
            tf.x        = stage.stageWidth - tf.width >> 1;
            tf.y        = stage.stageHeight - tf.height >> 1;
            tf.autoSize = TextFieldAutoSize.CENTER;
            tf.text     = "loading...";
            addChild(tf);
            
            sound.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):void
            {
                tf.text = e.text.replace(/ /g, "\n");
            });
            sound.addEventListener(ProgressEvent.PROGRESS, function(e:ProgressEvent):void
            {
                tf.text = "loading... " + (e.bytesLoaded / e.bytesTotal * 100).toFixed(0) + "%";
            });
            sound.addEventListener(Event.COMPLETE, function(e:Event):void
            {
                removeChild(tf);
                playSound();
            });
            
            sound.load(new URLRequest(URL), new SoundLoaderContext(1000, true));
        }
        
        private function playSound():void
        {
            initDisp();
            initTable();
            
            sndch = sound.play();
            sndch.addEventListener(Event.SOUND_COMPLETE, onSoundComplete);
            
            addEventListener(Event.ENTER_FRAME, onEnterFrame);
        }
        
        private function initDisp():void
        {
            var s:HSlider = new HSlider(this, 0, 0, function():void
            {
                scale  = s.value;
                l.text = "1 : " + scale;
            });
            s.minimum = 1;
            s.maximum = 441;
            s.tick    = 1;
            s.width   = (441 - 1) * 1 + 10;
            
            var l:Label = new Label(this, 0, s.height, "1 : 1");
            
            graphics.lineStyle(3, 0x000080, 0.5);
            graphics.moveTo(W >> 1, 0);
            graphics.lineTo(W >> 1, H << 2);
            
            stage.addChildAt(new Bitmap(disp), 0);
        }
        
        private function initTable():void
        {
            var bytes:ByteArray = new ByteArray();
            sound.extract(bytes, sound.length * 44.1);
            
            length = bytes.length >> 3;
            waveL  = new Vector.<Number>(length, true);
            waveR  = new Vector.<Number>(length, true);
            
            bytes.position = 0;
            for (var i:int = 0; i < length; i++) {
                waveL[i] = bytes.readFloat();
                waveR[i] = bytes.readFloat();
            }
        }
        
        private function onSoundComplete(e:Event):void
        {
            sndch.removeEventListener(Event.SOUND_COMPLETE, onSoundComplete);
            sndch = sound.play();
            sndch.addEventListener(Event.SOUND_COMPLETE, onSoundComplete);
        }
        
        private function onEnterFrame(e:Event):void
        {
            disp.lock();
            disp.fillRect(disp.rect, 0xffffff);
            
            var p:Number = sndch.position * 44.1 - (scale * W >> 1);
            
            for (var i:int = 0; i < W; i++, p += scale) {
                var uL:Number = -1,
                    dL:Number =  1,
                    uR:Number = -1,
                    dR:Number =  1,
                    n:Number;
                
                for (var j:int = 0; j < scale; j++) {
                    var k:int = p + j;
                    
                    if (k >= 0 && k < length) {
                        n = waveL[k];
                        if (n > uL) uL = n;
                        if (n < dL) dL = n;
                        
                        n = waveR[k];
                        if (n > uR) uR = n;
                        if (n < dR) dR = n;
                        
                    } else {
                        uL = uR = dL = dR = 0;
                    }
                }
                
                rect.x = i;
                
                uL = uL * H + CL;
                dL = dL * H + CL;
                n  = uL - dL;
                if (n < 2) {
                    disp.setPixel(i, uL, 0x800000);
                } else {
                    rect.y      = dL;
                    rect.height = n;
                    disp.fillRect(rect, 0x800000);
                }
                
                uR = uR * H + CR;
                dR = dR * H + CR;
                n  = uR - dR;
                if (n < 2) {
                    disp.setPixel(i, uR, 0x008000);
                } else {
                    rect.y      = dR;
                    rect.height = n;
                    disp.fillRect(rect, 0x008000);
                }
            }
            
            disp.unlock();
        }
    }
}

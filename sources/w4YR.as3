// forked from gaina's soundtest6
/**
 * Copyright gaina ( http://wonderfl.net/user/gaina )
 * MIT License ( http://www.opensource.org/licenses/mit-license.php )
 * Downloaded from: http://wonderfl.net/c/dllp
 */

package {
    import flash.display.BlendMode;
    import flash.display.StageQuality;
    import flash.filters.GlowFilter;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.media.Sound;
    import flash.media.SoundChannel;
    import flash.media.SoundLoaderContext;
    import flash.media.SoundMixer;
    import flash.net.URLRequest;
    import flash.utils.ByteArray;

    [SWF(backgroundColor="#000000", frameRate="60", width="465", height="465")]

    public class SoundSpectrum extends Sprite {

        private var leftRightSpList:Array;
        private var snd:Sound;
        private var FFTswitch:Boolean = false;
        private var grows:Array;

        function SoundSpectrum() {
                
            graphics.beginFill(0x000000);
            graphics.drawRect(0, 0, 465, 465);
            graphics.endFill();
            
            stage.quality=StageQuality.LOW;
            
            grows=[new GlowFilter(0x4994d5,1,4,4,4),new GlowFilter(0x54a4ed,1,4,4,4),new GlowFilter(0xe6e6e6,1,4,4,4)];                
            leftRightSpList = makeLeftRightSpList();
                
            playSound("http://www.takasumi-nagai.com/soundfiles/sound001.mp3");
            addEventListener(Event.ENTER_FRAME, onEnterFrame);
            Wonderfl.capture_delay(5);
        }

        private function playSound(sndUrl:String):void {
            snd = new Sound();
            var context:SoundLoaderContext = new SoundLoaderContext(10, true);
            var req:URLRequest = new URLRequest(sndUrl);
            snd.load(req, context);
            var sndChannel:SoundChannel = new SoundChannel();
            sndChannel = snd.play(0, 9999);
        }

        private function onEnterFrame(event:Event):void {
            var sp:Sprite = new Sprite();
            var bytes:ByteArray = new ByteArray();
            SoundMixer.computeSpectrum(bytes, FFTswitch, 0);
            var i:uint, j:uint;
            for (i = 0;i < 2;i++) {
                var spList:Array = leftRightSpList[i];
                for (j = 0;j < 256;j++) {
                    sp = spList[j];
                    var rf:Number = bytes.readFloat();
                    var scale:Number = Math.max(0.05, 1 + rf * 100);
                    sp.scaleX = scale;
                    sp.scaleY = scale/5+1;
                    
                    sp.filters=((Math.random()*10>>0)%2)?[grows[Math.random()*3>>0]]:null;
                        
                    if(!FFTswitch) {
                        sp.x += sp.x * rf * 5 + 8;
                    } else {
                        sp.x = sp.x * rf * 5 + 8;
                    }
                }
            }
        }

        private function makeLeftRightSpList():Array {
            var spLRList:Array = new Array();
            var n:uint;
            var i:uint;
            for (n = 0;n < 2;n++) {
                var spList:Array = new Array();
                for (i = 0;i < 256;i++) {
                    var sp:Sprite = new Sprite();
                    sp.graphics.beginFill(0x000000);
                    sp.blendMode = BlendMode.ADD;
                    sp.graphics.drawRect(0, 0, 5, 1);
                    sp.graphics.endFill();
                    sp.y = stage.stageHeight / 256 * i;
                    addChild(sp);
                    spList.push(sp);
                }
                spLRList.push(spList);
            }
            return spLRList;
        }
    }
}
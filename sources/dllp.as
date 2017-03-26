//こっそりとSoundMixer.computeSpectrumの第二引数を
//stageクリックでかえれるようにしてみた。
//trueとfalseでの動きの違いを確かめる。

package  
    {
        import flash.display.Sprite;
        import flash.events.Event;
        import flash.events.MouseEvent;
        import flash.media.Sound;
        import flash.media.SoundChannel;
        import flash.media.SoundLoaderContext;
        import flash.media.SoundMixer;
        import flash.net.URLRequest;
        import flash.utils.ByteArray;
        
        //import flash.filters.BlurFilter;
        
        
        [SWF(width=465,height=465,backgroundColor=0x0)]
        public class soundSpectrum extends Sprite
        {
            private var leftRightSpList:Array;
            private var snd:Sound;
            private var FFTswitch:Boolean = false;
            
            //private var fil:Array = [];
            
            function soundSpectrum() 
            {
                graphics.beginFill(0x000000);
                graphics.drawRect(0, 0, 465, 465);
                graphics.endFill();
                
                leftRightSpList = makeLeftRightSpList();
                
                playSound("http://www.takasumi-nagai.com/soundfiles/sound001.mp3");
                addEventListener(Event.ENTER_FRAME, onEnterFrame);
                stage.addEventListener(MouseEvent.CLICK, FFTswitcher);
                //fil = [new BlurFilter(4, 4, 2)];
                Wonderfl.capture_delay( 15 );
            }
            
            private function playSound(sndUrl:String):void
            {
                snd = new Sound();
                var context:SoundLoaderContext = new SoundLoaderContext(10,true);
                var req:URLRequest = new URLRequest(sndUrl);
                snd.load(req, context);
                var sndChannel:SoundChannel=new SoundChannel();
                sndChannel = snd.play(0, 5);
                
            }
            
            private function FFTswitcher(e:MouseEvent):void 
        {
            if (FFTswitch) { FFTswitch = false; } else { FFTswitch = true;}
        }
            
            private function onEnterFrame(event:Event):void {
                var sp:Sprite=new Sprite();
                var bytes:ByteArray = new ByteArray();
                SoundMixer.computeSpectrum(bytes, FFTswitch, 0);
                var i:uint, j:uint;
                for (i = 0; i < 2; i++)
                {
                    var spList:Array = leftRightSpList[i];
                    for (j = 0; j < 256; j++)
                    {
                        sp = spList[j];
                        var rf:Number = bytes.readFloat();
                        var scale:Number = Math.max(0.05, 1 + rf * 15);
                        sp.scaleX = sp.scaleY = scale;
                        
                        if(!FFTswitch){
                            sp.x += sp.x *rf * 5 + 8;
                        }else{
                            sp.x = sp.x *rf * 5 + 8;
                        }


                        
                        
                        //sp.filters = fil;

                    }
                }
            }
                    
            private function makeLeftRightSpList():Array
            {
                var spLRList:Array = new Array();
                var circle_r:uint = 2;
                var n:uint;
                var i:uint;
                for (n = 0; n < 2; n++)
                {
                    var spList:Array = new Array();
                    for (i = 0; i < 256; i++) {
                        var sp:Sprite = new Sprite();
                        if (n == 0) {
                            sp.graphics.beginFill(0, 0);
                            sp.graphics.lineStyle(0.5, 0xFFFFFF);
                            sp.graphics.drawCircle(0, 0, circle_r);
                        }else {
                            sp.graphics.beginFill(0xFFFFFF);
                            sp.graphics.drawCircle(0, 0, circle_r);
                        }
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
package  
{
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.geom.ColorTransform;
    import flash.media.Sound;
    import flash.media.SoundChannel;
    import flash.media.SoundLoaderContext;
    import flash.media.SoundMixer;
    import flash.net.URLRequest;
    import flash.utils.ByteArray;
    
    
    [SWF(width=465,height=465,backgroundColor=0x0)]
    public class soundSpectrum extends Sprite
    {
        private var leftRightSpList:Array;
        private var snd:Sound;
        
        function soundSpectrum() 
        {
            leftRightSpList = makeLeftRightSpList();
            
            playSound("http://www.takasumi-nagai.com/soundfiles/sound001.mp3");
            addEventListener(Event.ENTER_FRAME, onEnterFrame);

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
        
        private function onEnterFrame(event:Event):void {
            var sp:Sprite=new Sprite();
            var bytes:ByteArray = new ByteArray();
            SoundMixer.computeSpectrum(bytes, false, 0);
            var i:uint, j:uint;
            for (i = 0; i < 2; i++)
            {
                var spList:Array = leftRightSpList[i];
                for (j = 0; j < 256; j++)
                {
                    sp = spList[j];
                    var rf:Number = bytes.readFloat();
                    var scale:Number = Math.max(0.05, 1 + rf * 5);
                    sp.scaleX = sp.scaleY = scale;
                    
                    //これ外しても面白い動き。
                    //sp.x+=sp.x*rf*5+8;
                    
                    //if(rf>0.3){
                    //    var colorInfo:ColorTransform = sp.transform.colorTransform;
                    //    colorInfo.color = Math.random()*0xFFFFFF * scale;
                    //    sp.transform.colorTransform = colorInfo;
                    //}else{
                    //    var colorInfo02:ColorTransform = sp.transform.colorTransform;
                    //    colorInfo02.color = 0xFFFFFF;
                    //    sp.transform.colorTransform = colorInfo02;
                    //}

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
                    sp.graphics.beginFill(0xFFFFFF);
                    sp.graphics.drawCircle(0, 0, circle_r);
                    sp.graphics.endFill();
                    sp.x = stage.stageWidth/2+200 * Math.cos((n * 180 + (180 / 256*i)) * Math.PI / 180);
                    sp.y = stage.stageHeight/2+200 * Math.sin((n * 180 + (180 / 256+i)) * Math.PI / 180);
                    addChild(sp);
                    spList.push(sp);
                }
                spLRList.push(spList);
            }
            return spLRList;
        }
        
    }

}
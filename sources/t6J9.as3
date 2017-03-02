package
{
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Graphics;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.media.Sound;
    import flash.media.SoundChannel;
    import flash.media.SoundTransform;
    import flash.net.URLRequest;
    import flash.text.TextField;
    import flash.text.TextFormat;
    
    import org.si.sion.SiONDriver;
    import org.si.sion.events.SiONTrackEvent;
    import org.si.sion.utils.BPMAnalyzer;
    
    
    [SWF( width = '465', height = '465', frameRate = '30', backgroundColor = '0' )]
    
    public class SiONBeatExample extends Sprite
    {
        private var _testMusic:Sound;
        
        private var _driver:SiONDriver;
        private var _count:int;
        
        private var _bg:Sprite = new Sprite();
        private var tx:TextField = new TextField();
        
        public function SiONBeatExample()
        {    
            addChild( new Bitmap( new BitmapData( 465, 465, false, 0 ) ) );
            
            addChild( _bg );
            setup();
            
            var tf:TextFormat = new TextFormat( "_typewriter", 14, 0xFFFFFF );
            tf.align = "center";
            tx.y = 220;
            tx.width = 465;
            tx.defaultTextFormat = tf;
            tx.text = "sound loading...";
            addChild( tx );
        }
        
        
        private function setup():void
        {    
            _driver = new SiONDriver();
            
            var sc:SoundChannel = new SoundChannel();
            var st:SoundTransform = new SoundTransform( .4, 0 );
            _testMusic = new Sound( new URLRequest( "http://www.digifie.jp/files/funk1.mp3" ));
            _testMusic.addEventListener(Event.COMPLETE, onLoaded );
        }
        
        private function onLoaded( e:Event ):void
        {
            _testMusic.removeEventListener(Event.COMPLETE, onLoaded );
            tx.text = "";
            
            var _bpmAnlizer:BPMAnalyzer = new BPMAnalyzer();
            _driver.bpm = _bpmAnlizer.estimateBPM( _testMusic );
            _driver.setBeatCallbackInterval( 1 );
            _driver.addEventListener( SiONTrackEvent.BEAT, onBeat );
            
            _driver.setSamplerSound( 60, _testMusic );
            _driver.play();
            _driver.playSound( 60 );
        }
        
        private function onBeat( e:SiONTrackEvent ):void
        {
            var g:Graphics = _bg.graphics;
            
            _count++;
            
            if( _count == 16 )
            {
                g.clear();
                _count = 0;
            }
            else
            {
                g.lineStyle( Math.random() * 10 + 4 | 0, Math.random() * 0xFFFFFF | 0 );
                g.drawCircle( 465 * .5, 465 * .5, (Math.random() * 180 + 25) | 0 );
            }
        }
    }
}
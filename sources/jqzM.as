package {
    import flash.display.DisplayObject;
    import flash.display.Sprite;
    import flash.events.UncaughtErrorEvent;
    import flash.media.Sound;
    import flash.text.TextField;
    public class FlashTest extends Sprite {
        
        private var the_internet:Object = Internet.the;
        
        public function FlashTest() {
            loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, function (e:UncaughtErrorEvent):void { Wonderfl.log(e.error); });
            
            var jpg:DisplayObject = the_internet['http://wonderfl.net/img/common/logo.png'];
            jpg.scaleX = 2;
            jpg.scaleY = 2;
            addChild(jpg);
            
            var mp3:Sound = the_internet['http://www.apmmusic.com/audio/BR/BRU_BR_0514/BRU_BR_0514_01101.mp3'];
            mp3.play();
            
            var txt:TextField = the_internet['http://www.pcre.org/readme.txt'];
            txt.width = 465;
            txt.height = 405;
            txt.y = 60;
            addChild(txt);
        }
        
    }
}

import flash.display.Loader;
import flash.events.Event;
import flash.media.Sound;
import flash.media.SoundLoaderContext;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.system.Security;
import flash.text.TextField;
import flash.utils.Proxy;
import flash.utils.flash_proxy;

internal class Internet extends Proxy {
    
    public static var the:Internet = new Internet();
    
    public function Internet() {
        Security.loadPolicyFile('http://p.jsapp.us/crossdomain.xml');
    }
    
    override flash_proxy function getProperty(url:*):* {
        // can't check Content-Type header since this must be synchronous
        // and don't know the desired return type
        // just guess by file extension...
        url = String(url);
        var extension:String = /^[^?]*\.(\w+)(?:$|\?)/.exec(url)[1];
        var request:URLRequest = new URLRequest('http://p.jsapp.us/proxy/' + url);
        
        switch (extension) {
            case 'jpg':
            case 'gif':
            case 'png':
            case 'swf':
                var l:Loader = new Loader();
                l.load(request);
                return l;
            
            case 'mp3':
            case 'wav':
                var s:Sound = new Sound(request);
                return s;
            
            case 'txt':
            case 'html':
            case 'htm':
                var tf:TextField = new TextField();
                var ul:URLLoader = new URLLoader(request);
                ul.addEventListener(Event.COMPLETE, function (e:Event):void {
                    if (extension == 'text') tf.text = ul.data;
                    else tf.htmlText = ul.data;
                });
                return tf;
            
            // default return undefined
        }
    }
    
}

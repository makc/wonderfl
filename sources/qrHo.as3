package {
    import flash.events.*;
    import flash.display.*;
    import flash.net.*;
    
    import com.bit101.components.*;
    public class FlashTest extends Sprite {
        
        private var wordField:InputText;
        private var rhymeField:Label;
        
        public function FlashTest() {
            wordField = new InputText(this, 10, 10, 'finance');
            wordField.height = 20;
            new PushButton(this, 120, 10, 'rhyme', rhymeClick);
            rhymeField = new Label(this, 10, 40);
            loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, function (e:UncaughtErrorEvent):void { rhymeField.text = e.error; });
            rhymeClick(null);
        }
        
        private function rhymeClick(e:MouseEvent):void {
            var word:String = wordField.text;
            rhymeField.text = 'loading';
            var ur:URLRequest = new URLRequest('http://rhymebrain.com/talk?function=getRhymes&word=' + encodeURIComponent(word) + '&maxResults=25&jsonp=GIF89a');
            hax(ur, function (response:String):void {
                var json:String = response.substr(7, response.length - 10);
                var rhymes:Array = JSON.parse(json) as Array;
                var words:Array = [];
                for each (var rhyme:Object in rhymes) words.push(rhyme.word);
                rhymeField.text = words.join('\n');
            });
        }
        
    }
}

import flash.net.URLRequest;
import flash.display.Loader;
import flash.events.Event;
import flash.utils.ByteArray;

internal function hax(request:URLRequest, callback:Function):void {
    var l:Loader = new Loader();
    l.contentLoaderInfo.addEventListener(Event.COMPLETE, function (e:Event):void {
        // nb: the data comes wrapped in a SWF file
        var swf:ByteArray = e.target.bytes;
        swf.position = 48;
        callback(swf.readUTFBytes(e.target.bytesLoaded));
    });
    l.load(request);
}
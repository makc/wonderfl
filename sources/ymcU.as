// forked from 9re's forked from: Guess the tag!
// forked from makc3d's Guess the tag!
package {
    import com.bit101.components.PushButton;
    import flash.net.URLRequest;
    import flash.events.Event;
    import flash.net.URLLoader;
    import flash.display.*;
    import flash.text.TextField;
    import net.wonderfl.score.basic.BasicScoreForm;
    import net.wonderfl.score.basic.BasicScoreRecordViewer;
    import com.actionscriptbible.Example;
    public class MediaRSSReader extends Example {

        private var media:Namespace = new Namespace ("http://search.yahoo.com/mrss/");

        private var tags:Vector.<String> = Vector.<String>([
            "mammals", "reptiles", "birds", "amphibia", "fish"
        ]);

        private var images:Vector.<ImageEntry> = new Vector.<ImageEntry>;
        private var listsLoaded:int = 0;

        private var entry:ImageEntry;
        private var score:int = 0;

        private function guess (e:Event):void {
            if (e != null) {
                if (PushButton (e.target).label == entry.tag) {
                    result.htmlText = "<font size='24' color='#007F00'>Right!</font>";
                    score++;
                } else {
                    result.htmlText = "<font size='24' color='#7F0000'>Wrong.</font>";
                    score--;
                }
                removeChild (entry.sprite);
            } else {
                result.htmlText = "<font size='24'>Guess the tag!</font>";
            }
            if (images.length > 0) {
                var i:int = int (images.length * Math.random ()) % images.length;
                entry = images [i]; images.splice (i, 1);
                addChild (entry.sprite); entry.load ();
            } else {
                // end of game
                trace(this);
                trace("numChildren: " + this.numChildren);

                var _this:Sprite = this;
                x = y = 0;
                //while (numChildren > 0) removeChildAt (0);
                //new BasicScoreForm (this, 100, 100, score);
                new PushButton (this, int (465 / 2) - 40, int (465 / 2), "see rankings", function (e:*):void {
                    trace(this);
                    trace("numChildren: " + this.numChildren);
                    
                    // doesn't removeChild because numChildren is null
                    //while (numChildren > 0) removeChildAt (0);
                    new BasicScoreRecordViewer (this, 100, 100);
                });
            }
        }

        private var result:TextField;

        public function MediaRSSReader() {
            x = y = int (465 / 2);
            result = new TextField;
            result.autoSize = "left";
            result.htmlText = "<font size='24'>Wait for it...</font>";
            result.x = - result.width / 2;
            result.y = - 465 / 2;
            addChild (result);
            for (var i:int = 0; i < tags.length; i++) {
                // make buttons
                new RingButton (this, i, tags.length, 150, tags [i], guess);
                // load image lists
                var ldr:ImageListLoader = new ImageListLoader;
                ldr.tag = tags [i]; trace ("Ordered " + ldr.tag);
                ldr.addEventListener (Event.COMPLETE, function _load (event:Event):void {
                    var ldr:ImageListLoader = ImageListLoader (event.target);
                    ldr.removeEventListener (Event.COMPLETE, _load);
                    //trace ("Got " + ldr.tag);
                    var a:Array = XML(ldr.data)..media::thumbnail.@url.toXMLString().split('\n');
                    for (var j:int = 0; j < 1; j++) {
                        if (a [j] == "") continue;
                        var e:ImageEntry = new ImageEntry;
                        e.tag = ldr.tag; e.loader = new Loader;
                        e.loader.x = e.loader.y = +7;
                        e.sprite = new Sprite; e.sprite.addChild (e.loader);
                        e.sprite.x = e.sprite.y = -45;
                        var k:int, m:int;
                        with (Sprite (e.sprite).graphics) {
                            beginFill (0, 0.5);
                            for (k = 0; k < 90; k += 10)
                            for (m = 0; m < 2; m ++) {
                                moveTo (m * 90, k); lineTo (m * 90, k + 5);
                                lineTo (k + 5, m * 90); lineTo (k, m * 90);
                                lineTo (m * 90, k);
                            }
                            endFill ();
                        }
                        e.url = a [j];
                        images.push (e);
                    }
                    listsLoaded++;
                    if (listsLoaded == tags.length) guess (null);
                });
                ldr.load (new URLRequest ("http://api.flickr.com/services/feeds/photos_public.gne?tags=" +
                    tags [i] + "&format=rss_200"));
            }
        }
    }
}
import com.bit101.components.PushButton;
import flash.display.DisplayObjectContainer;
import flash.geom.Point;
import flash.geom.Rectangle;
class RingButton extends PushButton {
    public function RingButton (parent:DisplayObjectContainer, i:int, n:int, r:uint, title:String, callBack:Function):void {
        var a:Point = Point.polar (r, 2 * Math.PI * (0.25 + i) / n);
        super (parent, a.x, a.y, title, callBack);
        x = int (x - width / 2); y = int (y - height / 2);
    }
}
import flash.display.Loader;
import flash.net.URLRequest;
import flash.system.LoaderContext;
class ImageEntry {
    public var tag:String, loader:Loader, sprite:DisplayObjectContainer, url:String;
    public function load ():void {
        //trace ("url:\"" + url + "\"");
        loader.load (new URLRequest (url), new LoaderContext (true));
    }
}
import flash.net.URLLoader;
class ImageListLoader extends URLLoader {
    public var tag:String;
}
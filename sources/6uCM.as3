// SporeAPISlide.as
//  Spore API test program.
//  http://www.spore.com/comm/developer/
package {
    import flash.display.Sprite;
    [SWF(width="465", height="465", backgroundColor="0", frameRate="30")]
    public class SporeAPISlide extends Sprite {
        public function SporeAPISlide() { main = this; initialize(); }
    }
}
import flash.display.*;
import flash.geom.*;
import flash.events.*;
import flash.net.*;
const SCREEN_WIDTH:int = 465, SCREEN_HEIGHT:int = 465;
var main:Sprite;
var screen:BitmapData = new BitmapData(SCREEN_WIDTH, SCREEN_HEIGHT, false, 0);
var loader:URLLoader = new URLLoader, imageLoader:Loader = new Loader;
// Initialize UIs.
function initialize():void {
    var rect:Rectangle = new Rectangle(0, 0, SCREEN_WIDTH, 1);
    var ci:int, c:int;
    for (var y:int = 0; y < SCREEN_HEIGHT; y++) {
        rect.y = y;
        ci = Math.sin((y - 150) * 0.007) * 100;
        if (ci < 0) c = (0xee + ci) * 0x10000 + (0xee + ci) * 0x100 + (0xee + ci / 2);
        else        c = (0xee - ci) * 0x10000 + int(0xee - ci / 2) * 0x100 + (0xee - ci);
        screen.fillRect(rect, c);
    }
    main.addChild(new Bitmap(screen));
    loader.addEventListener(Event.COMPLETE, gotFeed);
    imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, gotImage);
    main.addEventListener(Event.ENTER_FRAME, update);
    getNextFeed();
}
// Update the frame.
function update(event:Event):void {
    for (var i:int = 0; i < images.length; i++) {
        if (!images[i].update()) { images.splice(i, 1); i--; }
    }
}
// Get the next asset.
const SERVER_STRING:String = "http://www.spore.com";
var feedIndex:int = -1;
function getNextFeed():void {
    feedIndex++;
    loader.load(new URLRequest(SERVER_STRING + "/rest/assets/search/RANDOM/" + feedIndex + "/1"));
}
function gotFeed(e:Event):void {
    var xml:XML = new XML(e.target.data);
    namespace atomenv = "http://www.w3.org/2005/Atom";
    use namespace atomenv;
    var asset:XML = xml..asset[0];
    var id:String = asset..id.toString();
    var subId1:String = id.substr(0, 3), subId2:String = id.substr(3, 3), subId3:String = id.substr(6, 3);
    imageLoader.load(new URLRequest(SERVER_STRING + "/static/thumb/" +
                                    subId1 + "/" + subId2 + "/" + subId3 + "/" + id + ".png"));
}
// Asset's images.
var images:Vector.<Image> = new Vector.<Image>;
class Image {
    public var bitmap:Bitmap, targetX:Number;
    public function update():Boolean {
        bitmap.x += (targetX - bitmap.x) * 0.1;
        if (bitmap.x < -bitmap.width) {
            main.removeChild(bitmap);
            return false;
        }
        return true;
    }
}
function gotImage(e:Event):void {
    var image:Image = new Image;
    image.bitmap = e.target.content;
    image.bitmap.smoothing = true;
    image.bitmap.x = SCREEN_WIDTH;
    image.targetX = SCREEN_WIDTH - image.bitmap.width;
    image.bitmap.y = (SCREEN_HEIGHT - image.bitmap.height) * 0.6;
    for each (var i:Image in images) i.targetX -= image.bitmap.width;
    images.push(image);
    main.addChild(image.bitmap);
    getNextFeed();
}

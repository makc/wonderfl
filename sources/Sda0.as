// forked from H.S's flash on 2016-9-26
package {
    import com.bit101.components.HUISlider;
    import com.bit101.components.Style;
    import flash.display.Loader;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.net.URLRequest;
    import flash.system.LoaderContext;
    public class Main extends Sprite {
        public var stopFlag:Boolean = false;
        public var toaster:Toaster;
        public function Main():void {
            graphics.beginFill(0xF6DFAD);
            graphics.drawRect(0, 0, 93 * 5, 93 * 5);
            var loader:Loader = new Loader();
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadCompleteHandler);
            loader.load(new URLRequest("http://chococornet.sakura.ne.jp/img/bread_and_toaster.png"), new LoaderContext(true));
        }
        private function loadCompleteHandler(event:Event):void {
            for (var i:int; i < 6; i++) {
                var bread:Bread = new Bread(event.target.loader);
                bread.x = -93 * (i + 1);
                bread.y = 93;
                addChild(bread); 
            }
            toaster = new Toaster(event.target.loader);
            toaster.x = 93 * 2;
            toaster.y = 93 * 3;
            addChild(toaster);
            with (Style) { BACKGROUND = DROPSHADOW = 0x808080; LABEL_TEXT = 0x000000;  BUTTON_FACE = 0xFFFFFF; }
            var slider:HUISlider = new HUISlider(this, 149, 390, "LEVEL", sliderHandler);
            slider.maximum = 10;
            slider.minimum = 0;
            slider.value = 2;
            addEventListener(Event.ENTER_FRAME, enterFrameHandler);
        }
        private function sliderHandler(event:Event):void {
            toaster.level = Math.round(event.currentTarget.value);
        }
        private function enterFrameHandler(event:Event):void {
            for (var i:int; i < numChildren - 2; i++) {
                var bread:Bread = Bread(getChildAt(i));
                if (bread.x == toaster.x - 93 + 3) {
                    setChildIndex(bread, 0);
                }
                if (bread.x == toaster.x) {
                    stopFlag = true;
                    if (bread.toastFlag) bread.moveUp();
                    else if (bread.y < toaster.y)  bread.moveDown();
                    if (bread.y <= 93) stopFlag = false;
                    toaster.drawLever();
                }
                if (!stopFlag) {
                    bread.moveLeft();
                    if (bread.x >= 465) bread.reset();
                }
            }
        }
    }
}

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Loader;
import flash.events.Event;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
class Bread extends Bitmap {
    public var toastFlag:Boolean = false;
    private var happyFlag:Boolean = true;
    private var sourceBitmapData:BitmapData;
    private var matrix:Matrix = new Matrix();
    public function Bread(loader:Loader):void {
        bitmapData = new BitmapData(93, 93, true, 0x00000000);
        sourceBitmapData = Bitmap(loader.content).bitmapData;
        drawWhite();
    }
    public function drawWhite():void {
        bitmapData.draw(sourceBitmapData);
    }
    public function drawBrown():void {
        matrix.identity();
        matrix.translate(-93, 0);
        bitmapData.draw(sourceBitmapData, matrix, null, "multiply");
        if (happyFlag && ((bitmapData.getPixel(42,32) & 0xff00) < 0x2000)) {
            happyFlag = false;
            for (var i:int = 36; i <= 56; i++) {
                for (var j:int = 0; j < 3; j++) {
                    var a:uint = bitmapData.getPixel(i, 57 + j);
                    var b:uint = bitmapData.getPixel(i, 60 + j);
                    bitmapData.setPixel(i, 57 + j, b);
                    bitmapData.setPixel(i, 60 + j, a);
                }
            }
        }
    }
    public function reset():void {
        toastFlag = false;
        happyFlag = true;
        x = -93;
        drawWhite();
    }
    public function moveLeft():void {
        x += 3;
    }
    public function moveUp():void {
        y -= 6;
    }
    public function moveDown():void {
        y += 6;
    }
}

class Toaster extends Bitmap {
    private var counter:int = 0;
    private var matrix:Matrix = new Matrix();
    private var bread:Bread;
    public var level:int = 2;
    public function Toaster(loader:Loader):void {
        bitmapData = new BitmapData(93, 93, true, 0x00000000);
        addEventListener(Event.ENTER_FRAME, enterFrameHandler);
        matrix.translate(-93 * 2, 0);
        bitmapData.draw(loader, matrix);
    }
    private function enterFrameHandler(event:Event):void {
        bread = Bread(parent.getChildAt(0));
        if (hitTestObject(bread) && !bread.toastFlag) {
            counter++;
            if (counter % 30 == 0) {
                var time:int = (level <= 5)? 1 : level - 4;
                for (var i:int; i < time; i++) {
                    bread.drawBrown();
                }
            }
            if (counter >= 30 * level + 29) {
                bread.toastFlag = true;
                counter = 0;
            }
        }
    }
    public function drawLever():void {
        if (y - bread.y <= 18) {
            bitmapData.fillRect(new Rectangle(93 - 6, 0, 6, 93), 0x000000);
            bitmapData.fillRect(new Rectangle(93 - 6, bread.y + 75 - y, 6, 3), 0xFF402000);
        }
    }
}
////////////////////////////////////////////////////////////////////////////////
// [AS3.0] TransitFlareクラスに挑戦！
// http://www.project-nya.jp/modules/weblog/details.php?blog_id=1130
////////////////////////////////////////////////////////////////////////////////

package {

    import flash.display.Sprite;
    import flash.events.Event;
    import flash.system.Security;

    [SWF(backgroundColor="#000000", width="465", height="465", frameRate="30")]

    public class Main extends Sprite {
        private static var basePath:String = "http://assets.wonderfl.net/images/related_images/";
        private var photoList:Array;
        private var photo1:PhotoLoader;
        private var photo2:PhotoLoader;
        private var transit1:TransitFlare;
        private var transit2:TransitFlare;
        private var transitList:Array;
        private var transit:TransitFlare;
        private var transitID:uint = 1;
        private var loaded1:Boolean = false;
        private var loaded2:Boolean = false;

        public function Main() {
            Security.allowDomain("wonderfl.net");
            Security.allowDomain("swf.wonderfl.net");
            Security.allowDomain("assets.wonderfl.net");
            init();
        }

        private function init():void {
            graphics.beginFill(0x000000);
            graphics.drawRect(0, 0, 465, 465);
            graphics.endFill();
            photoList = new Array();
            photoList.push(basePath + "5/59/5947/59475c25ec077563a6f075c89f332f36ddffc305");
            photoList.push(basePath + "c/c3/c331/c331d0a4aefdac4c38ea1e4f652aad201cf793ca");
            photo1 = new PhotoLoader();
            photo1.addEventListener(PhotoLoader.COMPLETE, setup1, false, 0, true);
            photo1.load(photoList[0]);
            photo2 = new PhotoLoader();
            photo2.load(photoList[1]);
            photo2.addEventListener(PhotoLoader.COMPLETE, setup2, false, 0, true);
            transitList = new Array();
        }
        private function setup1(evt:Event):void {
            transit1 = new TransitFlare(photo1.content);
            transit1.x = 72;
            transit1.y = 112;
            transitList[1] = transit1;
            transit1.addEventListener(Event.COMPLETE, complete, false, 0, true);
            loaded1 = true;
            setup();
        }
        private function setup2(evt:Event):void {
            transit2 = new TransitFlare(photo2.content);
            transit2.x = 72;
            transit2.y = 112;
            transitList[2] = transit2;
            transit2.addEventListener(Event.COMPLETE, complete, false, 0, true);
            loaded2 = true;
            setup();
        }
        private function setup():void {
            if (loaded1 && loaded2) {
                addChild(transit2);
                addChild(transit1);
                transit = transitList[transitID];
                exchange();
                transit.start();
            }
        }
        private function complete(evt:Event):void {
            exchange();
            transit.start();
        }
        private function exchange():void {
            transitID = transitID%2 + 1;
            transit = transitList[transitID];
            removeChild(transit);
            addChild(transit);
        }

    }

}


import flash.display.Sprite;
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.net.URLRequest;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.HTTPStatusEvent;
import flash.events.SecurityErrorEvent;
import flash.display.Bitmap;
import flash.system.LoaderContext;

class PhotoLoader extends Sprite {
    private var loader:Loader;
    private var info:LoaderInfo;
    public var content:Bitmap;
    private var smoothing:Boolean;
    public static const IO_ERROR:String = IOErrorEvent.IO_ERROR;
    public static const HTTP_STATUS:String = HTTPStatusEvent.HTTP_STATUS;
    public static const SECURITY_ERROR:String = SecurityErrorEvent.SECURITY_ERROR;
    public static const INIT:String = Event.INIT;
    public static const COMPLETE:String = Event.COMPLETE;

    public function PhotoLoader() {
        loader = new Loader();
        info = loader.contentLoaderInfo;
    }

    public function load(file:String, s:Boolean = false):void {
        smoothing = s;
        info.addEventListener(IOErrorEvent.IO_ERROR, ioerror, false, 0, true);
        info.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpstatus, false, 0, true);
        info.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityerror, false, 0, true);
        info.addEventListener(Event.INIT, initialize, false, 0, true);
        info.addEventListener(Event.COMPLETE, complete, false, 0, true);
        try {
            loader.load(new URLRequest(file), new LoaderContext(true));
        } catch (err:Error) {
            trace(err.message);
        }
    }
    public function unload():void {
        loader.unload();
    }
    private function ioerror(evt:IOErrorEvent):void {
        loader.unload();
        dispatchEvent(new Event(PhotoLoader.IO_ERROR));
    }
    private function httpstatus(evt:HTTPStatusEvent):void {
        dispatchEvent(new Event(PhotoLoader.HTTP_STATUS));
    }
    private function securityerror(evt:SecurityErrorEvent):void {
        dispatchEvent(new Event(PhotoLoader.SECURITY_ERROR));
    }
    private function initialize(evt:Event):void {
        content = Bitmap(info.content);
        if (smoothing) content.smoothing = true;
        dispatchEvent(new Event(PhotoLoader.INIT));
    }
    private function complete(evt:Event):void {
        info.removeEventListener(IOErrorEvent.IO_ERROR, ioerror);
        info.removeEventListener(HTTPStatusEvent.HTTP_STATUS, httpstatus);
        info.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityerror);
        info.removeEventListener(Event.INIT, initialize);
        info.removeEventListener(Event.COMPLETE, complete);
        //addChild(loader);
        dispatchEvent(new Event(PhotoLoader.COMPLETE));
    }

}


import flash.display.Sprite;
import flash.display.Shape;
import flash.display.DisplayObject;
import flash.display.BitmapData;
import flash.display.Bitmap;
import flash.geom.Rectangle;
import flash.geom.Matrix;
import flash.events.Event;
import flash.filters.GlowFilter;
import flash.display.BlendMode;

class TransitFlare extends Sprite {
    private var base:Sprite;
    private var target:DisplayObject;
    private var rect:Rectangle;
    private var source:BitmapData;
    private var threshold:Threshold;
    private var bitmap:Bitmap;
    private var burn:Bitmap;
    private var area:Rectangle;
    private var flare:FlareMap;
    private var detection:DetectPixels;
    private var map:BitmapData;
    private var matrix:Matrix;
    private var operation:String = Threshold.OPERATION_HIGH;
    private var _threshold:uint = 0x000000;
    private static var speed:uint = 0x020202;
    private static var color:uint = 0x00000000;
    private static var _mask:uint = 0x00FFFFFF;
    private var glow:GlowFilter;
    private static var gColor:uint = 0x663300;
    public static const COMPLETE:String = Event.COMPLETE;

    public function TransitFlare(t:DisplayObject) {
        target = t;
        init();
    }

    private function init():void {
        base = new Sprite();
        addChild(base);
        base.addChild(target);
        rect = new Rectangle(0, 0, target.width+20, target.height+20);
        //area = new Rectangle(0, 0, target.width+20,  target.height+30);
        area = new Rectangle(0, 0, target.width+20,  target.height+112);
        var bitmapData:BitmapData = new BitmapData(rect.width, rect.height, false);
        bitmap = new Bitmap(bitmapData);
        base.addChild(bitmap);
        bitmap.x = -10;
        bitmap.y = -10;
        target.cacheAsBitmap = true;
        bitmap.cacheAsBitmap = true;
        target.mask = bitmap;
        glow = new GlowFilter(gColor, 1, 8, 8, 4, 2, true, true);
        var fire:BitmapData = new BitmapData(rect.width, rect.height, false);
        burn = new Bitmap(fire);
        base.addChild(burn);
        burn.x = -10;
        burn.y = -10;
        burn.filters = [glow];
        var frame:Shape = new Shape();
        frame.graphics.beginFill(0x000000);
        frame.graphics.drawRect(0, 0, target.width, target.height);
        frame.graphics.endFill();
        base.addChild(frame);
        base.mask = frame;
        flare = new FlareMap(area);
        addChild(flare);
        flare.x = target.width*0.5;
        flare.y = target.height;
        detection = new DetectPixels(4);
        map = new BitmapData(target.width, target.height, true, 0x00000000);
        matrix = new Matrix();
        matrix.translate(-10, -10);
    }
    public function start():void {
        var noise:PerlinNoise = new PerlinNoise(rect, 80, 4, 0);
        noise.colorize({r: 1.2, g: 1.2, b: 1.2}, {r: 0x00, g: 0x00, b: 0x00});
        source = noise;
        threshold = new Threshold(source);
        bitmap.bitmapData = threshold;
        burn.bitmapData = threshold;
        _threshold = 0x000000;
        threshold.reset(0x00000000);
        flare.start();
        addEventListener(Event.ENTER_FRAME, transit, false, 0, true);
    }
    public function stop():void {
        removeEventListener(Event.ENTER_FRAME, transit);
        flare.stop();
    }
    private function transit(evt:Event):void {
        _threshold += speed;
        threshold.apply(operation, _threshold, color, _mask);
        if (_threshold > 0xFFFFFF) {
            _threshold = 0xFFFFFF;
            removeEventListener(Event.ENTER_FRAME, transit);
            dispatchEvent(new Event(TransitFlare.COMPLETE));
            threshold.reset();
        }
        map.fillRect(map.rect, 0x00000000);
        map.draw(burn, matrix);
        //detection.search(map, new Rectangle(10, 30, target.width, target.height));
        detection.search(map, new Rectangle(0, 0, target.width, target.height));
        var mapList:Array = detection.pixels();
        var segments:uint = Math.floor(mapList.length/10);
        flare.offset = {x: 10, y: 112};
        flare.setup(6, 4, segments);
        flare.map = mapList;
    }

}


import flash.display.Sprite;
import flash.display.Shape;
import flash.display.BitmapData;
import flash.display.Bitmap;
import flash.events.Event;
import flash.geom.Rectangle;
import flash.geom.Point;
import flash.filters.BlurFilter;
import flash.display.BlendMode;
//import sketchbook.colors.ColorUtil;

class FlareMap extends Sprite {
    private var rect:Rectangle;
    private var fire:Rectangle;
    private var flare:BitmapData;
    private var bitmapData:BitmapData;
    private var bitmap:Bitmap;
    private var rPalette:Array;
    private var gPalette:Array;
    private var bPalette:Array;
    private static var point:Point = new Point(0, 0);
    private var speed:Point = new Point(0, -6);
    private var unit:uint = 8;
    private var segments:uint = 8;
    private var blur:BlurFilter;
    private var mapList:Array;
    public var offset:Object = {x: 0, y: 0};
    private var faded:uint = 0;
    public static const COMPLETE:String = Event.COMPLETE;

    public function FlareMap(r:Rectangle) {
        rect = r;
        initialize();
        draw();
    }

    public function setup(s:uint = 6, u:uint = 8, seg:uint = 8):void {
        speed.y = - s;
        unit = u;
        segments = seg;
    }
    public function set map(list:Array):void {
        mapList = list;
    }
    private function initialize():void {
        rPalette = new Array();
        gPalette = new Array();
        bPalette = new Array();
        for (var n:uint = 0; n < 256; n++) {
            var luminance:uint = (n < 128) ? n*2 : 0;
            //var rgb:Object = ColorUtil.HLS2RGB(n*360/256, luminance, 100);
            var rgb:Object = HLS2RGB(n*360/256, luminance, 100);
            var color:uint = rgb.r << 16 | rgb.g << 8 | rgb.b;
            rPalette[n] = color;
            gPalette[n] = 0;
            bPalette[n] = 0;
        }
        blur = new BlurFilter(2, 8, 3);
        blendMode = BlendMode.ADD;
    }
    private function draw():void {
        fire = new Rectangle(0, 0, rect.width, rect.height + 10);
        flare = new BitmapData(fire.width, fire.height, false, 0xFF000000);
        bitmapData = new BitmapData(rect.width, rect.height, false, 0xFF000000);
        bitmap = new Bitmap(bitmapData);
        addChild(bitmap);
        bitmap.x = - rect.width*0.5;
        bitmap.y = - rect.height;
    }
    public function start():void {
        addEventListener(Event.ENTER_FRAME, apply, false, 0, true);
    }
    public function stop():void {
        removeEventListener(Event.ENTER_FRAME, apply);
        faded = 0;
        addEventListener(Event.ENTER_FRAME, clear, false, 0, true);
    }
    private function apply(evt:Event):void {
        if (!mapList) return;
        flare.lock();
        bitmapData.lock();
        for (var n:uint = 0; n < segments; n++) {
            var id:uint = Math.random()*mapList.length;
            var px:int = mapList[id].x + offset.x;
            var py:int = mapList[id].y + offset.y;
            var range:Rectangle = new Rectangle(px, py, unit, 2)
            flare.fillRect(range, 0xFFFFFF);
        }
        flare.applyFilter(flare, fire, speed, blur);
        bitmapData.paletteMap(flare, rect, point, rPalette, gPalette, bPalette);
        flare.unlock();
        bitmapData.unlock();
    }
    private function clear(evt:Event):void {
        faded ++;
        flare.lock();
        bitmapData.lock();
        flare.applyFilter(flare, fire, speed, blur);
        bitmapData.paletteMap(flare, rect, point, rPalette, gPalette, bPalette);
        if (faded > 20) {
            bitmapData.fillRect(rect, 0x000000);
            removeEventListener(Event.ENTER_FRAME, clear);
            dispatchEvent(new Event(FlareMap.COMPLETE));
        }
        flare.unlock();
        bitmapData.unlock();
    }
    private function createEggMask(target:Shape):void {
        var w:Number = rect.width;
        var h:Number = rect.height*1.5;
        target.graphics.beginFill(0xFFFFFF);
        target.graphics.moveTo(-w*0.5, -h*0.2);
        target.graphics.curveTo(-w*0.4, -h, 0, -h);
        target.graphics.curveTo(w*0.4, -h, w*0.5, -h*0.2);
        target.graphics.curveTo(w*0.5, 0, 0, 0);
        target.graphics.curveTo(-w*0.5, 0, -w*0.5, -h*0.2);
        target.graphics.endFill();
    }
    private function HLS2RGB(h:Number, l:Number, s:Number):Object{
        var max:Number;
        var min:Number;
        h = (h < 0)? h % 360+360 : (h>=360)? h%360: h;
        l = (l < 0)? 0 : (l > 100)? 100 : l;
        s = (s < 0)? 0 : (s > 100)? 100 : s;
        l *= 0.01;
        s *= 0.01;
        if (s == 0) {
            var val:Number = l*255;
            return {r:val, g:val, b:val};
        }
        if (l < 0.5) {
            max = l*(1 + s)*255;
        } else {
            max = (l*(1 - s) + s)*255;
        }
        min = (2*l)*255 - max;
        return _hMinMax2RGB(h, min, max);
    }
    private function _hMinMax2RGB(h:Number, min:Number, max:Number):Object{
        var r:Number;
        var g:Number;
        var b:Number;
        var area:Number = Math.floor(h/60);
        switch(area){
            case 0:
                r = max;
                g = min + h * (max - min)/60;
                b = min;
                break;
            case 1:
                r = max - (h - 60)*(max - min)/60;
                g = max;
                b = min;
                break;
            case 2:
                r = min ;
                g = max;
                b = min + (h - 120)*(max - min)/60;
                break;
            case 3:
                r = min;
                g = max - (h - 180)*(max - min)/60;
                b =max;
                break;
            case 4:
                r = min + (h - 240)*(max - min)/60;
                g = min;
                b = max;
                break;
            case 5:
                r = max;
                g = min;
                b = max - (h - 300)*(max - min)/60;
                break;
            case 6:
                r = max;
                g = min + h*(max - min)/60;
                b = min;
                break;
        }
        r = Math.min(255, Math.max(0, Math.round(r)));
        g = Math.min(255, Math.max(0, Math.round(g)));
        b = Math.min(255, Math.max(0, Math.round(b)));
        return {r:r, g:g, b:b};
    }

}


import flash.display.BitmapData;
import flash.geom.Rectangle;
import flash.geom.Point;
import flash.geom.Matrix;
import flash.display.IBitmapDrawable;

class DetectPixels {
    private var bd:IBitmapDrawable;
    private var rect:Rectangle;
    private var map:BitmapData;
    private var mapList:Array;
    private var accuracy:uint;
    private var threshold:uint = 0x80FFFFFF;

    public function DetectPixels(a:uint = 1) {
        accuracy = a;
    }

    public function search(t:IBitmapDrawable, r:Rectangle, th:uint = 0x80FFFFFF):void {
        bd = t;
        rect = r;
        threshold = th;
        var w:uint = rect.width/accuracy;
        var h:uint = rect.height/accuracy;
        detect(w, h);
    }
    private function detect(w:uint, h:uint):void {
        map = new BitmapData(w, h, true, 0x00000000);
        var matrix:Matrix = new Matrix();
        matrix.translate(-rect.x, -rect.y);
        matrix.scale(1/accuracy, 1/accuracy);
        map.lock();
        map.draw(bd, matrix);
        map.unlock();
        mapList = new Array();
        for (var x:uint = 0; x < w; x++) {
            for (var y:uint = 0; y < h; y++) {
                var color:uint = map.getPixel32(x, y);
                if (color >= threshold) {
                    var px:int = x*accuracy + rect.x;
                    var py:int = y*accuracy + rect.y;
                    var point:Point = new Point(px, py);
                    mapList.push(point);
                }
            }
        }
    }
    public function pixels():Array {
        return mapList;
    }

}


import flash.display.BitmapData;
import flash.geom.Rectangle;
import flash.geom.Point;

class Threshold extends BitmapData {
    private var source:BitmapData;
    private static var point:Point = new Point();
    private var operation:String;
    private var _threshold:uint;
    private var color:uint;
    private var mask:uint;
    public static const OPERATION_LOW:String = "<=";
    public static const OPERATION_HIGH:String = ">=";

    public function Threshold(bd:BitmapData, o:String = OPERATION_LOW, t:uint = 0x000000, c:uint = 0x00000000, m:uint = 0xFFFFFFFF) {
        super(bd.rect.width, bd.rect.height, true, 0xFFFFFFFF);
        source = bd;
        apply(o, t, c, m);
    }

    public function apply(o:String, t:uint, c:uint, m:uint):void {
        operation = o;
        _threshold = t;
        color = c;
        mask = m;
        lock();
        reset();
        threshold(source, rect, point, operation, _threshold, color, mask, false);
        unlock();
    }
    public function reset(fill:uint = 0xFFFFFFFF):void {
        fillRect(rect, fill);
    }

}


import flash.display.BitmapData;
import flash.geom.Rectangle;
import flash.geom.Point;
import flash.geom.ColorTransform;

class PerlinNoise extends BitmapData {
    private var source:BitmapData;
    private var base:uint;
    private var octaves:uint;
    private var seed:uint;
    private static var point:Point = new Point();
    private var offsets:Array = [point, point];
    private var color:ColorTransform;
    private var multiplier:Object = {r: 1, g: 1, b: 1};
    private var offset:Object = {r: 0x00, g: 0x00, b: 0x00};

    public function PerlinNoise(rect:Rectangle, b:uint = 20, o:uint = 2, s:uint = 1) {
        super(rect.width, rect.height, false, 0xFF000000);
        source = new BitmapData(rect.width, rect.height, false, 0xFF000000);
        create(b, o, s);
    }

    public function create(b:uint, o:uint, s:uint):void {
        base = b;
        octaves = o;
        seed = s;
        if (seed == 0) seed = Math.floor(Math.random()*1000);
        lock();
        source.perlinNoise(base, base, octaves, seed, false, true, 0, true, offsets);
        draw(source);
        unlock();
    }
    public function colorize(m:Object, o:Object):void {
        multiplier = m;
        offset = o;
        color = new ColorTransform(multiplier.r, multiplier.g, multiplier.b, 1, offset.r, offset.g, offset.b, 0);
        lock();
        draw(source, null, color);
        unlock();
    }

}

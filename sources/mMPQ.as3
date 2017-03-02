////////////////////////////////////////////////////////////////////////////////
// [AS3.0] Flareクラスに挑戦！ (1)
// http://www.project-nya.jp/modules/weblog/details.php?blog_id=1127
////////////////////////////////////////////////////////////////////////////////

package {

    import flash.display.Sprite;
    import flash.display.Shape;
    import flash.display.MovieClip;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Rectangle;
    import flash.display.Loader;
    import flash.net.URLRequest;
    import flash.system.Security;
    import flash.system.LoaderContext;

    [SWF(backgroundColor="#000000", width="465", height="465", frameRate="30")]

    public class Main extends Sprite {
        private var flare:Flare;
        private static var cx:uint = 232;
        private static var cy:uint = 250;
        private static var fw:uint = 80;
        private static var fh:uint = 250;
        private var speed:uint = 6;
        private var unit:uint = 8;
        private var segments:uint = 8;
        private var fireBtn:Btn;
        private var clearBtn:Btn;
        private var loader:Loader;
        private var treePath:String = "http://www.project-nya.jp/images/flash/firetree.swf";
        private var tree:Sprite;

        public function Main() {
            Wonderfl.capture_delay(4);
            init();
        }

        private function init():void {
            graphics.beginFill(0x000000);
            graphics.drawRect(0, 0, 465, 465);
            graphics.endFill();
            tree = new Sprite();
            addChild(tree);
            tree.x = cx;
            tree.y = cy;
            var rect:Rectangle = new Rectangle(0, 0, fw, fh);
            flare = new Flare(rect);
            addChild(flare);
            flare.x = cx;
            flare.y = cy;
            //flare.scaleX = flare.scaleY = 1.2;
            flare.addEventListener(Event.COMPLETE, complete, false, 0, true);
            setup();
            Security.allowDomain("www.project-nya.jp");
            loader = new Loader();
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loaded, false, 0, true);
            loader.load(new URLRequest(treePath), new LoaderContext(true));
        }
        private function fire(evt:MouseEvent):void {
            flare.start();
            fireBtn.clicked = true;
            clearBtn.enabled = true;
        }
        private function clear(evt:MouseEvent):void {
            flare.stop();
            clearBtn.enabled = false;
        }
        private function complete(evt:Event):void {
            fireBtn.clicked = false;
        }
        private function change1(evt:CompoEvent):void {
            speed = evt.value;
            flare.setup(speed, unit, segments);
        }
        private function change2(evt:CompoEvent):void {
            unit = evt.value;
            flare.setup(speed, unit, segments);
        }
        private function change3(evt:CompoEvent):void {
            segments = evt.value;
            flare.setup(speed, unit, segments);
        }
        private function setup():void {
            fireBtn = new Btn();
            fireBtn.x = 192;
            fireBtn.y = 350;
            addChild(fireBtn);
            fireBtn.init({id: 0, label: "fire", type: 2});
            fireBtn.addEventListener(MouseEvent.CLICK, fire, false, 0, true);
            clearBtn = new Btn();
            clearBtn.x = 272;
            clearBtn.y = 350;
            addChild(clearBtn);
            clearBtn.init({id: 1, label: "clear", type: 2});
            clearBtn.addEventListener(MouseEvent.CLICK, clear, false, 0, true);
            clearBtn.enabled = false;
            var base:Shape = new Shape();
            addChild(base);
            base.graphics.beginFill(0xFFFFFF);
            base.graphics.drawRect(0, 385, 465, 80);
            base.graphics.endFill();
            var slider1:Slider = new Slider();
            slider1.x = 62;
            slider1.y = 395;
            addChild(slider1);
            slider1.init({label: "speed", width: 100, min: 0, max: 10, grid: 10, init: 6});
            slider1.addEventListener(CompoEvent.CHANGE, change1, false, 0, true);
            var slider2:Slider = new Slider();
            slider2.x = 182;
            slider2.y = 395;
            addChild(slider2);
            slider2.init({label: "unit", width: 100, min: 0, max: 20, grid: 10, init: 8});
            slider2.addEventListener(CompoEvent.CHANGE, change2, false, 0, true);
            var slider3:Slider = new Slider();
            slider3.x = 302;
            slider3.y = 395;
            addChild(slider3);
            slider3.init({label: "segments", width: 100, min: 0, max: 20, grid: 10, init: 8});
            slider3.addEventListener(CompoEvent.CHANGE, change3, false, 0, true);
        }
        private function loaded(evt:Event):void {
            loader.removeEventListener(Event.COMPLETE, complete);
            tree.addChild(evt.target.content);
        }

    }

}


//////////////////////////////////////////////////
// Flareクラス
//////////////////////////////////////////////////

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

class Flare extends Sprite {
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
    private var faded:uint = 0;
    public static const COMPLETE:String = Event.COMPLETE;

    public function Flare(r:Rectangle) {
        rect = r;
        initialize();
        draw();
    }

    public function setup(s:uint = 6, u:uint = 8, seg:uint = 8):void {
        speed.y = - s;
        unit = u;
        segments = seg;
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
        bitmapData = new BitmapData(rect.width, fire.height, false, 0xFF000000);
        bitmap = new Bitmap(bitmapData);
        addChild(bitmap);
        bitmap.x = - rect.width*0.5;
        bitmap.y = - rect.height;
        var _mask:Shape = new Shape();
        _mask.y = - 16;
        createEggMask(_mask);
        addChild(_mask);
        _mask.filters = [new BlurFilter(16, 16, 3)];
        _mask.cacheAsBitmap = true;
        bitmap.cacheAsBitmap = true;
        bitmap.mask = _mask;
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
        flare.lock();
        bitmapData.lock();
        for (var n:uint = 0; n < segments; n++) {
            var px:Number = Math.random()*(rect.width - 20 - unit) + 10;
            var range:Rectangle = new Rectangle(px, rect.height, unit, 2)
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
            dispatchEvent(new Event(Flare.COMPLETE));
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


//////////////////////////////////////////////////
// Sliderクラス
//////////////////////////////////////////////////

import flash.display.Sprite;
import flash.display.Shape;
import flash.text.TextField;
import flash.text.TextFieldType;
import flash.text.AntiAliasType;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flash.filters.DropShadowFilter;
import flash.filters.GlowFilter;
import flash.geom.Rectangle;
import flash.geom.Matrix;
import flash.display.GradientType;
import flash.display.SpreadMethod;
import flash.display.InterpolationMethod;
import flash.events.Event;
import flash.events.MouseEvent;

class Slider extends Sprite {
    private var hole:Shape;
    private var line:Sprite;
    private var thumb:Sprite;
    private var light:Shape;
    private var shade:Shape;
    private var base:Shape;
    private var title:TextField;
    private var txt:TextField;
    private var label:String = "";
    private static var fontType:String = "_ゴシック";
    private var _width:uint = 100;
    private static var tHeight:uint = 20;
    private static var bHeight:uint = 30;
    private var grid:uint = 5;
    private static var bColor:uint = 0xFFFFFF;
    private static var tColor:uint = 0x666666;
    private static var gColor:uint = 0x999999;
    private static var mColor:uint = 0x333333;
    private static var bgColor:uint = 0x0099FF;
    private static var sColor:uint = 0x000000;
    private static var offColor:uint = 0x999999;
    private var min:Number = 0;
    private var max:Number = 100;
    private var initValue:Number = 0;
    private var blueGlow:GlowFilter;
    private var shadeDrop:DropShadowFilter;
    private var value:Number;
    private var _enabled:Boolean = true;

    public function Slider() {
    }

    public function init(option:Object):void {
        if (option.label != undefined) label = option.label;
        if (option.width != undefined) _width = option.width;
        if (option.min != undefined) min = option.min;
        if (option.max != undefined) max = option.max;
        if (option.grid != undefined) grid = option.grid;
        if (option.init != undefined) initValue = option.init;
        draw();
    }
    private function draw():void {
        shadeDrop = new DropShadowFilter(1, 90, sColor, 0.5, 4, 4, 2, 3, false, false);
        blueGlow = new GlowFilter(bgColor, 0.6, 5, 5, 2, 3, false, true);
        hole = new Shape();
        line = new Sprite();
        title = new TextField();
        txt = new TextField();
        thumb = new Sprite();
        shade = new Shape();
        light = new Shape();
        base = new Shape();
        addChild(hole);
        addChild(line);
        addChild(title);
        addChild(txt);
        addChild(thumb);
        thumb.addChild(shade);
        thumb.addChild(light);
        thumb.addChild(base);
        hole.y = bHeight;
        createGradientHole(hole, _width, 3);
        line.y = bHeight;
        createGrid(line);
        title.height = tHeight-1;
        title.type = TextFieldType.DYNAMIC;
        title.selectable = false;
        //title.embedFonts = true;
        //title.antiAliasType = AntiAliasType.ADVANCED;
        title.textColor = tColor;
        title.autoSize = TextFieldAutoSize.LEFT;
        var tfl:TextFormat = new TextFormat();
        tfl.font = fontType;
        tfl.size = 12;
        tfl.align = TextFormatAlign.LEFT;
        title.defaultTextFormat = tfl;
        title.text = label;
        //txt.x = title.textWidth;
        txt.x = 40;
        txt.width = 50;
        txt.height = tHeight-1;
        txt.selectable = false;
        //txt.embedFonts = true;
        //txt.antiAliasType = AntiAliasType.ADVANCED;
        var tfr:TextFormat = new TextFormat();
        tfr.font = fontType;
        tfr.size = 12;
        tfr.align = TextFormatAlign.RIGHT;
        txt.defaultTextFormat = tfr;
        reset();
        thumb.y = bHeight;
        createThumb(shade, 8, 20, 12, sColor);
        shade.filters = [shadeDrop];
        createThumb(light, 8, 20, 12, bgColor);
        light.filters = [blueGlow];
        createThumb(base, 8, 20, 12, bColor);
        _up();
        enabled = true;
        thumb.mouseChildren = false;
    }
    private function rollOver(evt:MouseEvent):void {
        _over();
    }
    private function rollOut(evt:MouseEvent):void {
        _up();
    }
    private function press(evt:MouseEvent):void {
        _down();
        var rect:Rectangle = new Rectangle(0, bHeight, _width, 0);
        thumb.startDrag(false, rect);
        thumb.addEventListener(MouseEvent.MOUSE_UP, release, false, 0, true);
        stage.addEventListener(MouseEvent.MOUSE_UP, release, false, 0, true);
        stage.addEventListener(Event.MOUSE_LEAVE, leave, false, 0, true);
        thumb.addEventListener(Event.ENTER_FRAME, change, false, 0, true);
    }
    private function release(evt:MouseEvent):void {
        _up();
        thumb.stopDrag();
        checkValue();
        var e:CompoEvent = new CompoEvent(CompoEvent.SELECT, value);
        dispatchEvent(e);
        thumb.removeEventListener(MouseEvent.MOUSE_UP, release);
        stage.removeEventListener(MouseEvent.MOUSE_UP, release);
        stage.removeEventListener(Event.MOUSE_LEAVE, leave);
        thumb.removeEventListener(Event.ENTER_FRAME, change);
    }
    private function leave(evt:Event):void {
        _up();
        thumb.stopDrag();
        checkValue();
        var e:CompoEvent = new CompoEvent(CompoEvent.SELECT, value);
        dispatchEvent(e);
        thumb.removeEventListener(MouseEvent.MOUSE_UP, release);
        stage.removeEventListener(MouseEvent.MOUSE_UP, release);
        stage.removeEventListener(Event.MOUSE_LEAVE, leave);
        thumb.removeEventListener(Event.ENTER_FRAME, change);
    }
    private function _up():void {
        light.visible = false;
    }
    private function _over():void {
        light.visible = true;
    }
    private function _down():void {
        light.visible = true;
    }
    private function _off():void {
        light.visible = false;
        txt.textColor = offColor;
    }
    private function change(evt:Event):void {
        _down();
        checkValue();
        var e:CompoEvent = new CompoEvent(CompoEvent.CHANGE, value);
        dispatchEvent(e);
    }
    private function checkValue():void {
        value = min + Math.round(thumb.x/_width*(max-min));
        txt.text = String(value);
    }
    public function get enabled():Boolean {
        return _enabled;
    }
    public function set enabled(param:Boolean):void {
        _enabled = param;
        if (!_enabled) _off();
        thumb.buttonMode = _enabled;
        thumb.mouseEnabled = _enabled;
        thumb.useHandCursor = _enabled;
        if (_enabled) {
            thumb.addEventListener(MouseEvent.MOUSE_OVER, rollOver, false, 0, true);
            thumb.addEventListener(MouseEvent.MOUSE_OUT, rollOut, false, 0, true);
            thumb.addEventListener(MouseEvent.MOUSE_DOWN, press, false, 0, true);
            thumb.addEventListener(MouseEvent.MOUSE_UP, release, false, 0, true);
        } else {
            thumb.removeEventListener(MouseEvent.MOUSE_OVER, rollOver);
            thumb.removeEventListener(MouseEvent.MOUSE_OUT, rollOut);
            thumb.removeEventListener(MouseEvent.MOUSE_DOWN, press);
            thumb.removeEventListener(MouseEvent.MOUSE_UP, release);
        }
    }
    public function reset():void {
        thumb.x = _width*(initValue-min)/(max-min);
        value = initValue;
        txt.text = String(value);
    }
    private function createGrid(target:Sprite):void {
        for (var n:uint = 0; n <= grid; n++) {
            var w:uint = Math.floor(_width/grid);
            if (n == 0 || n == grid*0.5 || n == grid) {
                createGridLine(target, w*n, mColor);
                var _txt:TextField = new TextField();
                target.addChild(_txt);
                _txt.x = w*n - 20;
                _txt.y = 13;
                _txt.width = 40;
                _txt.height = 14;
                _txt.selectable = false;
                //_txt.embedFonts = true;
                //_txt.antiAliasType = AntiAliasType.ADVANCED;
                //_txt.antiAliasType = AntiAliasType.NORMAL;
                _txt.textColor = mColor;
                var tfc:TextFormat = new TextFormat();
                tfc.font = fontType;
                tfc.size = 8;
                tfc.align = TextFormatAlign.CENTER;
                _txt.defaultTextFormat = tfc;
                if (n == 0) _txt.text = String(min);
                if (n == grid*0.5) _txt.text = String(min+(max-min)*0.5);
                if (n == grid) _txt.text = String(max);
            } else {
                createGridLine(target, w*n, gColor);
            }
        }
    }
    private function createThumb(target:Shape, w:uint, h:uint, y:uint, color:uint, alpha:Number = 1):void {
        target.graphics.beginFill(color, alpha);
        target.graphics.drawRoundRect(-w*0.5, -y, w, h, w);
        target.graphics.endFill();
    }
    private function createGradientHole(target:Shape, w:uint, c:Number):void {
        var colors:Array = [0x000000, 0x000000];
        var alphas:Array = [0.4, 0];
        var ratios:Array = [0, 255];
        var matrix:Matrix = new Matrix();
        matrix.createGradientBox(w+c*2, c*2, 0.5*Math.PI, -c, -c);
        target.graphics.beginGradientFill(GradientType.LINEAR, colors, alphas, ratios, matrix, SpreadMethod.PAD, InterpolationMethod.RGB, 0);
        target.graphics.drawRoundRect(-c, -c, w+c*2, c*2, c*2);
        target.graphics.endFill();
    }
    private function createGridLine(target:Sprite, x:uint, color:uint):void {
        target.graphics.lineStyle(0, color);
        target.graphics.moveTo(x, 8);
        target.graphics.lineTo(x, 12);
    }

}


//////////////////////////////////////////////////
// CompoEventクラス
//////////////////////////////////////////////////

import flash.events.Event;

class CompoEvent extends Event {
    public static const SELECT:String = "select";
    public static const CHANGE:String = "change";
    public var value:*;

    public function CompoEvent(type:String, value:*) {
        super(type);
        this.value = value;
    }

    public override function clone():Event {
        return new CompoEvent(type, value);
    }

}


//////////////////////////////////////////////////
// Btnクラス
//////////////////////////////////////////////////

import flash.display.Sprite;
import flash.display.Shape;
import flash.text.TextField;
import flash.text.TextFieldType;
import flash.text.AntiAliasType;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flash.filters.GlowFilter;
import flash.events.MouseEvent;

class Btn extends Sprite {
    public var id:uint;
    private var shade:Shape;
    private var bottom:Shape;
    private var light:Shape;
    private var base:Shape;
    private var txt:TextField;
    private var label:String = "";
    private static var fontType:String = "_ゴシック";
    private var _width:uint = 60;
    private static var _height:uint = 20;
    private static var corner:uint = 5;
    private var type:uint = 1;
    private static var bColor:uint = 0xFFFFFF;
    private static var sColor:uint = 0x000000;
    private static var upColor:uint = 0x666666;
    private static var overColor:uint = 0x333333;
    private static var offColor:uint = 0x999999;
    private static var gColor:uint = 0x0099FF;
    private var blueGlow:GlowFilter;
    private var shadeGlow:GlowFilter;
    private var _clicked:Boolean = false;
    private var _enabled:Boolean = true;

    public function Btn() {
    }

    public function init(option:Object):void {
        if (option.id != undefined) id = option.id;
        if (option.label != undefined) label = option.label;
        if (option.width != undefined) _width = option.width;
        if (option.type != undefined) type = option.type;
        draw();
    }
    private function draw():void {
        switch (type) {
        case 1 :
            bColor = 0xFFFFFF;
            sColor = 0x000000;
            upColor = 0x666666;
            overColor = 0x333333;
            offColor = 0x999999;
            break;
        case 2 :
            bColor = 0x000000;
            sColor = 0xFFFFFF;
            upColor = 0x666666;
            overColor = 0x999999;
            offColor = 0x333333;
            break;
        }
        blueGlow = new GlowFilter(gColor, 0.6, 5, 5, 2, 3, false, true);
        shadeGlow = new GlowFilter(sColor, 0.3, 4, 4, 2, 3, false, true);
        shade = new Shape();
        bottom = new Shape();
        light = new Shape();
        base = new Shape();
        txt = new TextField();
        addChild(shade);
        addChild(bottom);
        addChild(light);
        addChild(base);
        addChild(txt);
        createBase(shade, _width, _height, corner, sColor);
        shade.filters = [shadeGlow];
        createBase(bottom, _width, _height, corner, sColor, 0.3);
        createBase(light, _width, _height, corner, gColor);
        light.filters = [blueGlow];
        createBase(base, _width, _height, corner, bColor);
        txt.x = -_width*0.5;
        txt.y = -_height*0.5;
        txt.width = _width;
        txt.height = _height - 1;
        txt.type = TextFieldType.DYNAMIC;
        txt.selectable = false;
        //txt.embedFonts = true;
        //txt.antiAliasType = AntiAliasType.ADVANCED;
        var tf:TextFormat = new TextFormat();
        tf.font = fontType;
        tf.size = 12;
        tf.align = TextFormatAlign.CENTER;
        txt.defaultTextFormat = tf;
        txt.text = label;
        enabled = true;
        mouseChildren = false;
    }
    private function rollOver(evt:MouseEvent):void {
        _over();
    }
    private function rollOut(evt:MouseEvent):void {
        _up();
    }
    private function press(evt:MouseEvent):void {
        _down();
    }
    private function release(evt:MouseEvent):void {
        _up();
    }
    private function click(evt:MouseEvent):void {
    }
    private function _up():void {
        txt.y = -_height*0.5;
        txt.textColor = upColor;
        base.y = -1;
        light.visible = false;
        light.y = -1;
    }
    private function _over():void {
        txt.y = -_height*0.5;
        txt.textColor = overColor;
        base.y = -1;
        light.visible = true;
        light.y = -1;
    }
    private function _down():void {
        txt.y = -_height*0.5 + 1;
        txt.textColor = overColor;
        base.y = 0;
        light.visible = true;
        light.y = 0;
    }
    private function _off():void {
        txt.y = -_height*0.5 + 1;
        txt.textColor = offColor;
        base.y = 0;
        light.visible = false;
        light.y = 0;
    }
    public function get clicked():Boolean {
        return _clicked;
    }
    public function set clicked(param:Boolean):void {
        _clicked = param;
        enabled = !_clicked;
        if (_clicked) {
            _down();
        } else {
            _up();
        }
    }
    public function get enabled():Boolean {
        return _enabled;
    }
    public function set enabled(param:Boolean):void {
        _enabled = param;
        buttonMode = _enabled;
        mouseEnabled = _enabled;
        useHandCursor = _enabled;
        if (_enabled) {
            _up();
            addEventListener(MouseEvent.MOUSE_OVER, rollOver, false, 0, true);
            addEventListener(MouseEvent.MOUSE_OUT, rollOut, false, 0, true);
            addEventListener(MouseEvent.MOUSE_DOWN, press, false, 0, true);
            addEventListener(MouseEvent.MOUSE_UP, release, false, 0, true);
            addEventListener(MouseEvent.CLICK, click, false, 0, true);
        } else {
            _off();
            removeEventListener(MouseEvent.MOUSE_OVER, rollOver);
            removeEventListener(MouseEvent.MOUSE_OUT, rollOut);
            removeEventListener(MouseEvent.MOUSE_DOWN, press);
            removeEventListener(MouseEvent.MOUSE_UP, release);
            removeEventListener(MouseEvent.CLICK, click);
        }
    }
    private function createBase(target:Shape, w:uint, h:uint, c:uint, color:uint, alpha:Number = 1):void {
        target.graphics.beginFill(color, alpha);
        target.graphics.drawRoundRect(-w*0.5, -h*0.5, w, h, c*2);
        target.graphics.endFill();
    }

}

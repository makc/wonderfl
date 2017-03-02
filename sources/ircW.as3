////////////////////////////////////////////////////////////////////////////////
// WaterEffect (5)
//
// 置き換えマップ効果 (3)
// http://www.project-nya.jp/modules/weblog/details.php?blog_id=480
// BitmapDataでノイズ生成 (3)
// http://www.project-nya.jp/modules/weblog/details.php?blog_id=481
// [AS3.0] PerlinNoiseクラスに挑戦！
// http://www.project-nya.jp/modules/weblog/details.php?blog_id=1114
//
// 動作を軽くするための方法 (東京てらこ7 @trick7)
// Bitmap.filters を使わず、BitmapData.applyFilter() を用いる
////////////////////////////////////////////////////////////////////////////////

package {

    import flash.display.Sprite;
    import flash.display.StageScaleMode;
    import flash.display.StageAlign;
    import flash.events.Event;
    import flash.geom.Rectangle;
    import flash.geom.Matrix;
    import flash.utils.Timer;
    import flash.events.TimerEvent;
    import flash.text.TextField;
    import flash.text.TextFieldType;
    import flash.text.TextFieldAutoSize;
    import flash.text.AntiAliasType;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;

    [SWF(backgroundColor="#000000", width="465", height="465", frameRate="30")]

    public class Main extends Sprite {
        private var water:WaterEffect;
        private var txt:TextField;
        private var faded:Boolean = true;
        private var matrix:Matrix;
        private var id:uint = 0;
        private var list:Array;

        public function Main() {
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
            init();
        }

        private function init():void {
            graphics.beginFill(0x000000);
            graphics.drawRect(0, 0, 465, 465);
            graphics.endFill();
            //
            var rect:Rectangle = new Rectangle(0, 0, 465, 465);
            water = new WaterEffect(rect);
            addChild(water);
            water.addEventListener(WaterEffect.COMPLETE, complete, false, 0, true);
            list = new Array();
            list.push("WaterEffect");
            list.push("wonderfl");
            list.push("build");
            list.push("flash");
            list.push("online");
            txt = new TextField();
            txt.width = 465;
            txt.height = 100;
            txt.autoSize = TextFieldAutoSize.CENTER;
            txt.selectable = false;
            //txt.embedFonts = true;
            //txt.antiAliasType = AntiAliasType.ADVANCED;
            var tf:TextFormat = new TextFormat();
            tf.font = "_ゴシック";
            tf.size = 60;
            tf.align = TextFormatAlign.CENTER;
            txt.defaultTextFormat = tf;
            txt.textColor = 0xFFFFFF;
            txt.text = list[id%list.length];
            matrix = new Matrix();
            matrix.translate(0, 182);
            water.setup(txt, matrix, 400);
            water.wave();
        }
        private function complete(evt:Event):void {
            faded = !faded;
            if (faded) {
                exchange();
            } else {
                var timer:Timer = new Timer(600, 1);
                timer.addEventListener(TimerEvent.TIMER_COMPLETE, wait, false, 0, true);
                timer.start();
            }
        }
        private function exchange():void {
            id ++;
            txt.text = list[id%list.length];
            water.setup(txt, matrix, 400);
            water.wave(0, 1);
        }
        private function wait(evt:TimerEvent):void {
            evt.target.removeEventListener(TimerEvent.TIMER_COMPLETE, wait);
            water.wave(1, 0);
        }

    }

}


//////////////////////////////////////////////////
// WaterEffectクラス
//////////////////////////////////////////////////

import flash.display.Sprite;
import flash.display.DisplayObject;
import flash.events.Event;
import flash.display.BitmapData;
import flash.display.Bitmap;
import flash.geom.Rectangle;
import flash.geom.Point;
import flash.geom.Matrix;
import flash.events.Event;
import flash.filters.DisplacementMapFilter;
import flash.display.BitmapDataChannel;
import flash.filters.DisplacementMapFilterMode;
import flash.filters.BlurFilter;
import org.libspark.betweenas3.BetweenAS3;
import org.libspark.betweenas3.tweens.ITween;
import org.libspark.betweenas3.events.TweenEvent;
import org.libspark.betweenas3.easing.Linear;
import org.libspark.betweenas3.easing.Quad;

class WaterEffect extends Sprite {
    private var rect:Rectangle;
    private var noise:PerlinNoise;
    private static var octaves:uint = 1;
    private static var channel:uint = BitmapDataChannel.RED;
    private var speeds:Array;
    private var target:DisplayObject;
    private var container:Bitmap;
    private var bitmapData:BitmapData;
    private var mapfilter:DisplacementMapFilter;
    private var blurfilter:BlurFilter;
    private static var baseScale:Number;
    private var _scale:Number = 0;
    private var _size:Number = 0;
    private static var time:Number = 2;
    public static const COMPLETE:String = Event.COMPLETE;

    public function WaterEffect(r:Rectangle) {
        rect = r;
        init();
    }

    private function init():void {
        noise = new PerlinNoise(rect, 32, 32, octaves, false, channel);
        speeds = new Array();
        for (var n:uint = 0; n < octaves; n++) {
            var sx:Number = (Math.random() - 0.5)*3;
            var sy:Number = (Math.random() - 0.5)*3 + 2.5;
            speeds.push(new Point(sx, sy));
        }
        bitmapData = new BitmapData(rect.width, rect.height, true, 0x00000000);
        container = new Bitmap(bitmapData);
        addChild(container);
        map = 0;
        blur = 0;
    }
    public function setup(t:DisplayObject, matrix:Matrix = null, bs:Number = 0):void {
        target = t;
        bitmapData.fillRect(rect, 0x00000000);
        bitmapData.draw(target, matrix, null, null, null, true);
        container.bitmapData = bitmapData.clone();
        baseScale = bs;
    }
    public function wave(from:Number = 0, to:Number = 1):void {
        tween(from, to);
    }
    private function tween(from:Number = 0, to:Number = 1):void {
        var itween:ITween = BetweenAS3.parallel(
            BetweenAS3.tween(container, {alpha: to}, {alpha: from}, time, Linear.easeNone), 
            BetweenAS3.tween(this, {map: to}, {map: from}, time, Quad.easeOut), 
            BetweenAS3.tween(this, {blur: to}, {blur: from}, time, Linear.easeNone)
        );
        itween.addEventListener(TweenEvent.UPDATE, update, false, 0, true);
        itween.addEventListener(TweenEvent.COMPLETE, complete, false, 0, true);
        itween.play();
    }
    private function update(evt:TweenEvent):void {
        noise.update(speeds);
        container.bitmapData.lock();
        container.bitmapData.applyFilter(bitmapData, bitmapData.rect, new Point(), mapfilter);
        container.bitmapData.applyFilter(container.bitmapData, bitmapData.rect, new Point(), blurfilter);
        container.bitmapData.unlock();
    }
    private function complete(evt:TweenEvent):void {
        dispatchEvent(new Event(COMPLETE));
    }
    public function get map():Number {
        return _scale;
    }
    public function set map(param:Number):void {
        _scale = param;
        var scale:Number = baseScale*(1 - _scale);
        mapfilter = new DisplacementMapFilter(noise, new Point(), channel, channel, scale, scale, DisplacementMapFilterMode.COLOR);
    }
    public function get blur():Number {
        return _size;
    }
    public function set blur(param:Number):void {
        _size = param;
        var size:Number = baseScale*(1 - _size)/10;
        blurfilter = new BlurFilter(size, size, 3);
    }

}


//////////////////////////////////////////////////
// PerlinNoiseクラス
//////////////////////////////////////////////////

import flash.display.BitmapData;
import flash.geom.Rectangle;
import flash.geom.Point;
import flash.geom.ColorTransform;

class PerlinNoise extends BitmapData {
    private var bx:uint;
    private var by:uint;
    private var octaves:uint;
    private var seed:uint;
    private var stitch:Boolean = true;
    private var fractalNoise:Boolean = true;
    private var channel:uint = 0;
    private var grayScale:Boolean = true;
    private var offsets:Array = new Array();

    public function PerlinNoise(rect:Rectangle, x:uint, y:uint, o:uint = 1, g:Boolean = true, c:uint = 0, s:uint = 1, st:Boolean = false, f:Boolean = true) {
        super(rect.width, rect.height, false, 0xFF000000);
        bx = x;
        by = y;
        octaves = o;
        grayScale = g;
        channel = c;
        if (grayScale) channel = 0;
        for (var n:uint = 0; n < octaves; n++) {
            var point:Point = new Point();
            offsets.push(point);
        }
        stitch = st;
        fractalNoise = f;
        create(s, offsets);
    }

    private function create(s:uint, o:Array = null):void {
        seed = s;
        offsets = o;
        if (offsets == null) offsets = [new Point()];
        lock();
        perlinNoise(bx, by, octaves, seed, stitch, fractalNoise, channel, grayScale, offsets);
        draw(this);
        unlock();
    }
    public function update(speeds:Array):void {
        for (var n:uint = 0; n < octaves; n++) {
            var offset:Point = offsets[n];
            var speed:Point = speeds[n];
            offset.x += speed.x;
            offset.y += speed.y;
        }
        lock();
        perlinNoise(bx, by, octaves, seed, stitch, fractalNoise, channel, grayScale, offsets);
        draw(this);
        unlock();
    }

}

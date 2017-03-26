// forked from ProjectNya's DotLight [Blue]
// forked from ProjectNya's DotLight
////////////////////////////////////////////////////////////////////////////////
// DotLight [Tornado]
////////////////////////////////////////////////////////////////////////////////

package {

    import flash.display.Sprite;
    import flash.geom.Rectangle;

    [SWF(backgroundColor="#000000", width="465", height="465", frameRate="30")]

    public class Main extends Sprite {
        private var light:DotLight;

        public function Main() {
            Wonderfl.capture_delay(10);
            init();
        }

        private function init():void {
            graphics.beginFill(0x000000);
            graphics.drawRect(0, 0, 465, 465);
            graphics.endFill();
            light = new DotLight(new Rectangle(0, 0, 465, 465));
            addChild(light);
            light.start();
        }

    }

}


import flash.display.Sprite;
import flash.display.Shape;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.PixelSnapping;
import flash.display.BlendMode;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import flash.geom.Point;
import flash.geom.ColorTransform;
import flash.filters.BlurFilter;
import flash.events.Event;
import flash.utils.getTimer;

class DotLight extends Sprite {
    private var rect:Rectangle;
    private var canvas:Shape;
    private var map:BitmapData;
    private var sparkle:BitmapData;
    private var afterglow:BitmapData;
    private static var scale:uint = 4;
    private var aMatrix:Matrix;
    private var colorTrans:ColorTransform;
    private var blur:BlurFilter;
    private var sMatrix:Matrix;
    private var offsets:Array;
    private var seed:uint;
    private var light:EmitLight;

    public function DotLight(r:Rectangle) {
        rect = r;
        init();
    }

    private function init():void {
        afterglow = new BitmapData(rect.width*2/scale, rect.height*2/scale, false, 0xFF000000);
        var aBitmap:Bitmap = new Bitmap(afterglow, PixelSnapping.AUTO, true);
        aBitmap.scaleX = aBitmap.scaleY = scale/2;
        addChild(aBitmap);
        canvas = new Shape();
        canvas.blendMode = BlendMode.ADD;
        addChild(canvas);
        map = new BitmapData(rect.width/scale, rect.height/scale, false, 0xFF000000);
        offsets = [new Point(), new Point()];
        seed = Math.floor(Math.random()*1000);
        sparkle = new BitmapData(rect.width/scale, rect.height/scale, true, 0x00000000);
        var sBitmap:Bitmap = new Bitmap(sparkle);
        sBitmap.smoothing = true;
        sBitmap.blendMode = BlendMode.ADD;
        sBitmap.scaleX = sBitmap.scaleY = scale;
        addChild(sBitmap);
        aMatrix = new Matrix(2/scale, 0, 0, 2/scale, 0, 0);
        //colorTrans = new ColorTransform(0.1, 0.1, 0.1);
        colorTrans = new ColorTransform(0.025, 0.025, 0.025);
        blur = new BlurFilter(2, 2, 1);
        sMatrix = new Matrix(1/scale, 0, 0, 1/scale, 0, 0);
        light = new EmitLight(canvas, map, scale);
    }
    public function start():void {
        addEventListener(Event.ENTER_FRAME, draw, false, 0, true);
    }
    public function stop():void {
        removeEventListener(Event.ENTER_FRAME, draw);
    }
    private function draw(evt:Event):void {
        var offset:Number = getTimer()*0.05;
        offsets[0].x = offsets[1].y = offset;
        map.perlinNoise(rect.width/scale, rect.height/scale, 2, seed, true, true, 1, false, offsets);
        light.create(10);
        canvas.graphics.clear();
        light.emit();
        sparkle.lock();
        sparkle.fillRect(sparkle.rect, 0x00000000);
        sparkle.draw(canvas, sMatrix);
        sparkle.unlock();
        afterglow.lock();
        afterglow.draw(canvas, aMatrix, colorTrans, BlendMode.ADD);
        afterglow.applyFilter(afterglow, afterglow.rect, new Point(), blur);
        afterglow.unlock();
    }

}


import flash.display.Shape;
import flash.display.BitmapData;
import flash.geom.Rectangle;
import frocessing.color.ColorHSV;

class EmitLight {
    private var canvas:Shape;
    private var map:BitmapData;
    private var rect:Rectangle = new Rectangle(0, 0, 465, 465);
    private var scale:uint;
    private var cx:uint;
    private var cy:uint;
    private var radius:uint;
    private static var yScale:Number = 0.25;
    private var dots:Array;
    //private static var acceleration:Number = 0.01;
    private static var acceleration:Number = 0.16;
    private static var gravity:Number = 0.03;
    //private static var deceleration:Number = 0.008;
    private static var deceleration:Number = 0.01;
    private var color:ColorHSV;
    private static var length:Number = 2;

    public function EmitLight(c:Shape, m:BitmapData, s:uint) {
        canvas = c;
        map = m;
        scale = s;
        cx = rect.width*0.5;
        cy = rect.height*0.9;
        //radius = rect.width*0.4;
        radius = rect.width*0.1;
        init();
    }

    private function init():void {
        dots = new Array();
        color = new ColorHSV(0, 0.4);
    }
    public function create(max:uint):void {
        for (var n:uint = 0; n < max; n++) {
            var angle:Number = Math.random()*360;
            //var power:Number = Math.random() + 0.5;
            var power:Number = Math.random()*2 + 1;
            var dot:Dot = new Dot(cx, cy, angle, power);
            dot.x = cx + Math.cos(angle*Math.PI/180)*radius;
            dot.y = cy + Math.sin(angle*Math.PI/180)*radius*yScale;
            dot.px = dot.x;
            dot.py = dot.y;
            color.h = 180;
            dot.rgb = color.value;
            dots.push(dot);
        }
    }
    public function emit():void {
        for (var n:uint = 0; n < dots.length; n++) {
            var dot:Dot = dots[n];
            var c:uint = map.getPixel(dot.x/scale, dot.y/scale);
            //dot.cx += ((((c >> 16) & 0xFF) - 0x80) / 0x80)*5;
            dot.cx += ((((c >> 16) & 0xFF) - 0x80) / 0x80)*10;
            dot.vy += gravity*dot.power;
            dot.vy *= 0.99;
            dot.vx += acceleration;
            dot.angle += dot.vx;
            dot.cy -= dot.vy;
            var px:Number = Math.cos(dot.angle*Math.PI/180)*radius;
            var py:Number = Math.sin(dot.angle*Math.PI/180)*radius*yScale;
            dot.x = dot.cx + px*(dot.energy*0.4 + 0.2);
            dot.y = dot.cy + py*(dot.energy*0.4 + 0.2);
            dot.energy -= deceleration;
            var x0:int = dot.x;
            var y0:int = dot.y;
            var x1:int = dot.x - (dot.x - dot.px)*length;
            var y1:int = dot.y - (dot.y - dot.py)*length;
            color.h = 210 - 20*dot.energy*0.5;
            dot.rgb = color.value;
            draw(x0, y0, x1, y1, dot.rgb, dot.energy*0.5);
            dot.px = dot.x;
            dot.py = dot.y;
            if (dot.energy < 0) {
                dots.splice(n, 1);
                dot = null;
            }
        }
    }
    public function draw(x0:int, y0:int, x1:int, y1:int, color:uint, alpha:Number):void {
        canvas.graphics.lineStyle(0, color, alpha);
        canvas.graphics.moveTo(x0, y0);
        canvas.graphics.lineTo(x1, y1);
    }

}


class Dot {

    public var x:Number = 0;
    public var y:Number = 0;
    public var vx:Number = 0;
    public var vy:Number = 0;
    public var cx:Number = 0;
    public var cy:Number = 0;
    public var px:Number = 0;
    public var py:Number = 0;
    public var angle:Number = 0;
    public var power:Number = 1;
    public var energy:Number = 2;
    public var rgb:uint = 0xFFFFFF;

    public function Dot(_x:Number, _y:Number, a:Number, p:Number) {
        cx = _x;
        cy = _y;
        angle =a;
        power = p;
    }

}

// forked from k0rin's Super Express
// It was a tricky task to scroll seamless mountains.
// Click to see how it works.

// Unfortunately the volumetric lighting effect is
// a bit of a CPU hog, but it looks nice if your
// hardware can pull it off.

// 繋ぎ目のない山を無限スクロールさせるのにちょっと悩みました。
// クリックでどうなってるのかネタバレします。

// 架線柱のティアリングがひどいなあ……。

package {
    import flash.display.*;
    import flash.events.*;
    import flash.geom.*;
    
    [SWF(width = "465", height = "465", frameRate = "40", backgroundColor = "0")]
    public class Main extends Sprite
    {
        public static const WIDTH:Number = 465;
        public static const HEIGHT:Number = 465;
        
        private var debug:Boolean = false;
        private var sun:SunLight;
        private var entities:Vector.<Entity> = new Vector.<Entity>();
        private var renderedScene:BitmapData = new BitmapData(WIDTH, HEIGHT);
        private var scene:Sprite = new Sprite;

        public function Main():void
        {
            Wonderfl.disable_capture();
            // 空を描画
            var matrix:Matrix = new Matrix();
            matrix.createGradientBox(WIDTH, HEIGHT, Math.PI / 2);
            graphics.beginGradientFill(GradientType.LINEAR, [0x51484A, 0x96543E], null, [0, 128], matrix);
            graphics.drawRect(0, 0, WIDTH, HEIGHT);
            graphics.endFill();
            
            var fogR:Number = 0x58;
            var fogG:Number = 0x39;
            var fogB:Number = 0x34;
            
            var mountainR:Number = 0x19;
            var mountainG:Number = 0x13;
            var mountainB:Number = 0x15;

            const NUMBER_OF_MOUNTAINS:int = 4;
            
            for (var i:int = 0; i < NUMBER_OF_MOUNTAINS; i++) {
                var blend:Number = i / (NUMBER_OF_MOUNTAINS - 1);
                
                var _r:Number = lerp(fogR, mountainR, blend);
                var _g:Number = lerp(fogG, mountainG, blend);
                var _b:Number = lerp(fogB, mountainB, blend);
                
                var baseHeight:Number = HEIGHT / 2 + i * 25;
                var color:uint = (_r << 16) | (_g << 8) | _b;
                
                var mountain:Mountain = new Mountain(-Math.pow(i + 1, 2), baseHeight, color);
                entities.push(scene.addChild(mountain));
            }
            
            entities.push(scene.addChild(new PoleAndWire()));
            entities.push(scene.addChild(new Tunnel()));
            addChild(scene);
            addChild(sun = new SunLight(renderedScene));
            
            var outline:Shape = new Shape();
            var g:Graphics = outline.graphics;
            g.lineStyle(1, 0x808080);
            g.drawRect( -1, -1, WIDTH + 2, HEIGHT + 2);
            addChild(outline);
            
            restoreFilters(debug);
            
            stage.addEventListener(MouseEvent.CLICK, clickHandler);
            addEventListener(Event.ENTER_FRAME, enterFrameHandler);
        }
        
        private function clickHandler(e:MouseEvent):void 
        {
            debug = !debug;
            
            var matrix:Matrix = new Matrix();
            if (debug) {
                // transformで表示領域外を確認。お手軽でいいと思う。
                matrix.scale(0.2, 0.2);
                matrix.translate(WIDTH * 0.4, HEIGHT * 0.4);
            }
            transform.matrix = matrix;
            
            restoreFilters(debug);
        }
        
        private function restoreFilters(debug:Boolean):void
        {
            for each (var entity:Entity in entities)
            {
                entity.restoreFilter(debug);
            }
        }
        
        private function enterFrameHandler(e:Event):void 
        {
            for each (var entity:Entity in entities)
            {
                entity.update();
            }
            renderedScene.fillRect(renderedScene.rect, 0);
            renderedScene.draw(scene);
            sun.update();
        }
    }
}

import flash.display.*;
import flash.filters.BlurFilter;
import flash.filters.GlowFilter;
import flash.geom.Matrix;

class Entity extends Sprite
{
    public function update():void { };
    public function restoreFilter(debug:Boolean):void { };
}

class SunLight extends Entity {
    public static const FXW:int = 0x100;
    public static const FXH:int = 0x100;

    private var src:BitmapData = new BitmapData(FXW, FXH, true, 0);
    private var dst:BitmapData = new BitmapData(FXW, FXH, true, 0);
    private var sun:Shape = new Shape;
    private var obstruction:Bitmap;
    private var scaleDown:Matrix = new Matrix;
    private var scaleUp:Matrix = new Matrix;
    private var mtx:Matrix = new Matrix;
    private var canvas:Bitmap = new Bitmap(dst);
    private var blur:BlurFilter = new BlurFilter(5,5,1);
    
    public function SunLight(obstruction:BitmapData) {
        this.blendMode = "add";
        this.obstruction = new Bitmap(obstruction);
        var m:Matrix = new Matrix;
        m.createGradientBox(FXW, FXH, 0, 0, 0);
        sun.graphics.beginGradientFill("radial", [0x0C0804, 0x0C0804, 0x060402, 0x030201, 0], [1, 1, 1, 1, 1], [0, 10, 14, 64, 255], m);
        sun.graphics.drawRect(0, 0, FXW, FXH);
        sun.graphics.endFill();
        sun.cacheAsBitmap = true;
        
        scaleDown.scale(FXW/Main.WIDTH, FXH/Main.HEIGHT);
        scaleUp.scale(Main.WIDTH/FXW, Main.HEIGHT/FXH);

        addChild(canvas);
        transform.matrix = scaleUp;
    }

    public override function update():void {
        src.lock();
        dst.lock();
        src.fillRect(src.rect, 0);
        src.draw(sun);
        src.draw(obstruction, scaleDown, null, "erase");
        canvas.bitmapData = process(src);
        src.unlock();
        dst.unlock();
    }
    
    private function process(src:BitmapData):BitmapData {
        var dst:BitmapData = this.dst;
        mtx.identity();
        mtx.translate(-FXW/34, -FXH/34);
        mtx.scale(17/16, 17/16);
        var cnt:int = 5;
        var tmp:BitmapData;
        while(cnt--) {
            mtx.concat(mtx);
            dst.copyPixels(src, src.rect, src.rect.topLeft);
            dst.draw(src, mtx, null, "add");
            dst.applyFilter(dst, dst.rect, dst.rect.topLeft, blur);
            tmp = src;
            src = dst;
            dst = tmp;
        }
        return src;
    }
}

class Mountain extends Entity
{
    private var heightMap:Vector.<Number> = new Vector.<Number>();
    private const SEGMENT_LENGTH:Number = 10;
    
    private var baseHeight:Number;
    private var color:uint;
    private var speed:Number;
    
    function Mountain(speed:Number, baseHeight:Number, color:uint)
    {
        this.baseHeight = baseHeight;
        this.color = color;
        this.speed = speed;
        
        generateHeightMap();
        createShape();
    }
    
    public override function update():void
    {
        x += speed;
        if (x < -(width - Main.WIDTH)) {
            var removeSegmentNumber:int = (width - Main.WIDTH) / SEGMENT_LENGTH;
            heightMap.splice(0, removeSegmentNumber);
            x += removeSegmentNumber * SEGMENT_LENGTH;
            
            generateHeightMap();
            createShape();
        }
    }
    
    private function generateHeightMap():void
    {
        // 再帰で分割していく
        divide(baseHeight, baseHeight, 0, 200);
        
        function divide(left:Number, right:Number, depth:int, offset:Number):void
        {
            if (depth < 6) {
                var half:Number = (left + right) / 2 + rnd( -offset / 2, offset / 2);
                
                divide(left, half, depth + 1, offset / 2);
                divide(half, right, depth + 1, offset / 2);
            } else {
                // 十分に分割したら順番に書き出し
                heightMap.push(left);
            }
        }
    }
    
    private function createShape():void
    {
        var g:Graphics = graphics;
        
        g.clear();
        g.beginFill(color);
        g.moveTo(0, Main.HEIGHT);
        for (var i:int = 0; i < heightMap.length; i++) {
            g.lineTo(i * SEGMENT_LENGTH, heightMap[i]);
        }
        g.lineTo((i - 1) * SEGMENT_LENGTH, Main.HEIGHT);
        g.endFill();
        
        // デバッグ表示
        g.lineStyle(1, color);
        g.moveTo(0, heightMap[0]);
        g.lineTo(0, Main.HEIGHT * 2);
    }
}

const SPEED:Number = 80;

class PoleAndWire extends Entity
{
    private const SPACING:Number = Main.WIDTH * 5;
    
    private const POLE_THICK:Number = 40;
    private const WIRE_TOP:Number = 20;
    private const WIRE_BOTTOM:Number = 100;
    
    function PoleAndWire()
    {
        var g:Graphics = graphics;
        
        g.beginFill(0x332222);
        g.drawRect(-POLE_THICK / 2, 0, POLE_THICK, Main.HEIGHT);
        g.endFill();
        
        g.lineStyle(1, 0x221111);
        g.moveTo(POLE_THICK / 2, WIRE_TOP);
        g.curveTo(SPACING / 2, WIRE_BOTTOM, SPACING - POLE_THICK, WIRE_TOP);
        g.moveTo(-POLE_THICK / 2, WIRE_TOP);
        g.curveTo(-SPACING / 2, WIRE_BOTTOM, -SPACING + POLE_THICK, WIRE_TOP);
        
        x = (SPACING + Main.WIDTH) / 2;
    }
    
    public override function update():void
    {
        x -= SPEED;
        if (x < (-SPACING + Main.WIDTH) / 2) {
            x += SPACING;
        }
    }
    
    public override function restoreFilter(debug:Boolean):void
    {
        filters = debug ? null : [ new BlurFilter(80, 0, 1) ];
    }
}

class Tunnel extends Entity
{
    // |ENTRANCE|SPACE|LIGHT|SPACE|ENTRANCE|
    // ^ origin
    
    private const LIGHT:Number = 100;
    private const SPACE:Number = Main.WIDTH * 1.4;
    private const ENTRANCE:Number = Main.WIDTH * 1.5;
    private const WIDTH:Number = LIGHT + SPACE * 2 + ENTRANCE * 2;
    
    private const ENTRANCE_COLOR:uint = 0x896857 >>> 1 & 0x7f7f7f;
    private const DARKNESS_COLOR:uint = 0x0A0908;
    private const LIGHT_COLOR:uint = 0xFFF0E0;
    
    private var lightCount:int;
    private var light:Shape;
    
    function Tunnel()
    {
        var g:Graphics = graphics;
        
        var matrix:Matrix = new Matrix();
        matrix.createGradientBox(ENTRANCE, Main.HEIGHT);
        g.beginGradientFill(GradientType.LINEAR, [ENTRANCE_COLOR, DARKNESS_COLOR], null, [0, 255], matrix);
        g.drawRect(0, 0, ENTRANCE, Main.HEIGHT);
        matrix.createGradientBox(ENTRANCE, Main.HEIGHT, 0, WIDTH - ENTRANCE, 0);
        g.beginGradientFill(GradientType.LINEAR, [DARKNESS_COLOR, ENTRANCE_COLOR], null, [0, 255], matrix);
        g.drawRect(WIDTH - ENTRANCE, 0, ENTRANCE, Main.HEIGHT);
        g.endFill();
        
        g.beginFill(DARKNESS_COLOR);
        g.drawRect(ENTRANCE, 0, LIGHT + SPACE * 2, Main.HEIGHT);
        g.endFill();
        
        light = new Shape();
        light.graphics.beginFill(LIGHT_COLOR);
        light.graphics.drawRect(WIDTH / 2, Main.HEIGHT * 0.55, LIGHT, 20);
        light.graphics.endFill();
        addChild(light);
        
        prepareNextTunnel();
        
        // 最初のトンネルまでは定距離にする。 - distance to 1st tunnel
        x = SPEED * 1200;
    }
    
    public override function update():void
    {
        x -= SPEED;
        if (x < -(WIDTH - ENTRANCE - Main.WIDTH)) {
            if (--lightCount >= 0) {
                // ライトをループ
                x += SPACE * 2 + LIGHT - Main.WIDTH;
                trace(length);
            }
        }
        if (x < -WIDTH * 2) {
            prepareNextTunnel();
        }
    }
    
    public override function restoreFilter(debug:Boolean):void
    {
        filters = debug ? null : [ new BlurFilter(80, 0, 1) ];
        light.filters = debug ? null : [ new GlowFilter(0xFF8000, 1, 50, 50, 3, 4) ];
    }
    
    private function prepareNextTunnel():void
    {
        x = SPEED * rnd(900, 3500);
        lightCount = rnd(6, 50);
    }
}

// 線形補間
function lerp(n0:Number, n1:Number, p:Number):Number
{
    return n0 * (1 - p) + n1 * p;
}

// [min, max)の乱数を取得
function rnd(min:Number, max:Number):Number
{
    return min + Math.random() * (max - min);
    //  return lerp(min, max, Math.random());
}



// ok, my turn, let's go for 3D
// (and get rid of that tonnel btw)
package {
    import flash.display.*;
    import flash.events.*;
    import flash.geom.*;
    
    [SWF(width = "465", height = "465", frameRate = "40", backgroundColor = "0")]
    public class Main extends Sprite
    {
        public static const WIDTH:Number = 465;
        public static const HEIGHT:Number = 465;
		public static const DELAY:int = 2; // 2+
        
        private var sun:SunLight;
        private var entities:Vector.<Entity> = new Vector.<Entity>();
        private var renderedScene:BitmapData = new BitmapData(WIDTH, HEIGHT);
        private var scene:Sprite = new Sprite;
		private var background:Shape = new Shape;

		private var cache:BitmapData = new BitmapData (WIDTH * DELAY, HEIGHT);
		private var cacheMatrix:Matrix = new Matrix (1, 0, 0, 1, WIDTH * (DELAY - 1));
		private var left:BitmapData = new BitmapData (WIDTH, HEIGHT);
		private var right:BitmapData = new BitmapData (WIDTH, HEIGHT);
		
        public function Main():void
        {
            // 空を描画
            var matrix:Matrix = new Matrix();
            matrix.createGradientBox(WIDTH, HEIGHT, Math.PI / 2);
            background.graphics.beginGradientFill(GradientType.LINEAR, [0x51484A, 0x96543E], null, [0, 128], matrix);
            background.graphics.drawRect(0, 0, WIDTH, HEIGHT);
            background.graphics.endFill();
            
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
            sun = new SunLight(renderedScene);
            
			addChild (new Bitmap (right)).transform.colorTransform =
				new ColorTransform (0, 1, 1);
			with (addChild (new Bitmap (left))) {
				transform.colorTransform = new ColorTransform (1, 0, 0);
				blendMode = BlendMode.ADD;
			}

            addEventListener(Event.ENTER_FRAME, enterFrameHandler);
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

			right.draw (background);
			right.draw (scene);
			right.draw (sun, sun.transform.matrix, null, sun.blendMode);
			cache.scroll ( -WIDTH, 0);
			cache.draw (right, cacheMatrix);
			left.draw (cache);
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
		/* anaglyph doesnt work well saturated colors
        sun.graphics.beginGradientFill("radial", [0x0C0804, 0x0C0804, 0x060402, 0x030201, 0], [1, 1, 1, 1, 1], [0, 10, 14, 64, 255], m);
		*/
		sun.graphics.beginGradientFill("radial", [0x090909, 0x080808, 0x040404, 0x020202, 0], [1, 1, 1, 1, 1], [0, 10, 14, 64, 255], m);
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
        this.speed = speed * SPEED / 80;
        
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

const SPEED:Number = 100;

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

		filters = [ new BlurFilter(80, 0, 1) ];
    }
    
    public override function update():void
    {
        x -= SPEED;
        if (x < (-SPACING + Main.WIDTH) / 2) {
            x += SPACING;
        }
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



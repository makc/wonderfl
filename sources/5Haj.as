// forked from yonatan's just some horses
// forked from yonatan's CMLMovieClipTexture
package {
    import flash.display.*;
    import flash.events.*;
    import flash.filters.*;
    import flash.geom.*;
    import flash.net.*;
    import flash.system.*;

    [SWF(width="465", height="465", frameRate="24", backgroundColor="0xc0c0c0")]
    public class FlashTest extends Sprite {
        private var horses:Array = [];
        private var frameCnt:int = 0;
        public static const FOCUS:Number = 300;
        public static const MAX_Z:Number = 4000;
        public static const MIN_Z:Number = 20;
        public static const NUM_HORSES:int = 40;

        public function FlashTest() {
            var url:String = "http://assets.wonderfl.net/images/related_images/d/d5/d5ef/d5efb19c4e6af524be0c935a932a653b475d2200";
            var loader:Loader = new Loader;
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoad);
            loader.load(new URLRequest(url), new LoaderContext(true));
            
            graphics.beginGradientFill("linear", [14731661,16365684,15116397,13341025,10843990],
                                        [0,1,1,1,1],[115,121,142,177,255], new Matrix/*(0.0000,0.2838,-0.2838,0.0000,232.5400,232.5400)*/,
                                        "reflect", "rgb", 0);
            graphics.drawRect(0, 0, 465, 465);
            graphics.endFill();
            
            var sac:SeaAndCloudsMain = new SeaAndCloudsMain
            sac.scaleY = 0.5
            addChild(sac)
            
            var se:SuperExpressMain = addChild(new SuperExpressMain) as SuperExpressMain
            se.scaleY = 0.6
            se.y = 50
        }

        private function onLoad(e:Event):void {
            var bmd:BitmapData = Bitmap(e.target.content).bitmapData;
            var vmargin:int = 10;
            var hmargin:int = 40;
            var w:int = bmd.width / 4 - hmargin*2;
            var h:int = bmd.height / 3 - vmargin*2;
            var rect:Rectangle = new Rectangle(0, 0, w, h);
            var frame:BitmapData;
            
            for(var y:int=0; y<3; y++) {
                for(var x:int=0; x<4; x++) {
                    frame = new BitmapData(w, h, true, 0);
                    rect.x = x*bmd.width/4+hmargin;
                    rect.y = y*bmd.height/3+vmargin;
                    frame.copyPixels(bmd, rect, frame.rect.topLeft);
                    Horse.animation.push(frame);
                }
            }
            Horse.animation.pop(); // lose last frame
            for each(frame in Horse.animation) createAlpha(frame);

            for(var i:int=0; i<NUM_HORSES; i++) {
                var horse:Horse = new Horse;
                var z:Number = MAX_Z - (MAX_Z-MIN_Z)/NUM_HORSES*i;
                horse.scaleX = horse.scaleY = 1/(z/FOCUS);
                horse.y = 310 - 50/(z/FOCUS);
                horse.x = Math.random()*465;
                horse.frame = Math.random() * Horse.animation.length*2;
                horses.push(horse);
                var blury:Number = Math.abs(z - (MIN_Z + MAX_Z)*0.3) / 1000;
                var blurx:Number = blury * horse.scaleX * 8;
                horse.filters = [new BlurFilter(blurx, blury)];
                addChild(horse);
            }
            addEventListener("enterFrame", onEnterFrame);
        }

        private function createAlpha(bmd:BitmapData):void {
            for(var x:int=0; x<bmd.width; x++) {
                for(var y:int=0; y<bmd.height; y++) {
                    var c:uint = bmd.getPixel(x, y);
                    var match:Number = (
                        Math.abs(0xb0 - (c & 0xff)) + 
                        Math.abs(0xb0 - ((c >> 8) & 0xff)) + 
                        Math.abs(0xb0 - ((c >> 16) & 0xff)));
                    match /= (3*0xb0);
                    match += 0.3;
                    match = Math.min(1, Math.pow(match, 5));
                    bmd.setPixel32(x, y, c | ((match*0xff) << 24));
                }
            }
        }

        private var bmp:Bitmap = new Bitmap;
        private function onEnterFrame(e:Event):void {
            for each(var horse:Horse in horses) horse.update();
        }
    }
}

import flash.display.*;

class Horse extends Bitmap {
    public static var animation:Array = [];
    public var frame:int;

    public function update():void {
        bitmapData = animation[frame>>1];
        x += 0.5*(width * (0.15 + (0.6+0.4*Math.cos(frame/22*Math.PI+1.6))*0.1));
        if(x > 465) x = -465 - width;
        if(++frame == 22) frame = 0;
    }
}


// It was a tricky task to scroll seamless mountains.
// Click to see how it works.

// 繋ぎ目のない山を無限スクロールさせるのにちょっと悩みました。
// クリックでどうなってるのかネタバレします。

// 架線柱のティアリングがひどいなあ……。

    import flash.display.*;
    import flash.events.*;
    import flash.geom.*;
    
    internal class SuperExpressMain extends Sprite
    {
        public static const WIDTH:Number = 465;
        public static const HEIGHT:Number = 465;
        
        private var debug:Boolean = false;

        private var entities:Vector.<Entity> = new Vector.<Entity>();

        public function SuperExpressMain():void
        {
            // 空を描画
            var fogR:Number = 116;
            var fogG:Number = 126;
            var fogB:Number = 143;
            
            var mountainR:Number = 23;
            var mountainG:Number = 21;
            var mountainB:Number = 32;
            
            const NUMBER_OF_MOUNTAINS:int = 3;
            
            for (var i:int = 0; i < NUMBER_OF_MOUNTAINS; i++) {
                var blend:Number = i / (NUMBER_OF_MOUNTAINS - 1);
                
                var _r:Number = lerp(fogR, mountainR, blend);
                var _g:Number = lerp(fogG, mountainG, blend);
                var _b:Number = lerp(fogB, mountainB, blend);
                
                var baseHeight:Number = HEIGHT / 2 + i * 25;
                var color:uint = (_r << 16) | (_g << 8) | _b;
                
                var mountain:Mountain = new Mountain(-Math.pow(i + 1, 2) / 5, baseHeight, color);
                entities.push(addChild(mountain));
            }
            
            addEventListener(Event.ENTER_FRAME, enterFrameHandler);
        }
        
        private function enterFrameHandler(e:Event):void 
        {
            for each (var entity:Entity in entities)
            {
                entity.update();
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
        if (x < -(width - SuperExpressMain.WIDTH)) {
            var removeSegmentNumber:int = (width - SuperExpressMain.WIDTH) / SEGMENT_LENGTH;
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
        g.moveTo(0, SuperExpressMain.HEIGHT);
        for (var i:int = 0; i < heightMap.length; i++) {
            g.lineTo(i * SEGMENT_LENGTH, heightMap[i]);
        }
        g.lineTo((i - 1) * SEGMENT_LENGTH, SuperExpressMain.HEIGHT);
        g.endFill();
        
        // デバッグ表示
        g.lineStyle(1, color);
        g.moveTo(0, heightMap[0]);
        g.lineTo(0, SuperExpressMain.HEIGHT * 2);
    }
}

const SPEED:Number = 80;

class PoleAndWire extends Entity
{
    private const SPACING:Number = SuperExpressMain.WIDTH * 5;
    
    private const POLE_THICK:Number = 40;
    private const WIRE_TOP:Number = 20;
    private const WIRE_BOTTOM:Number = 100;
    
    function PoleAndWire()
    {
        var g:Graphics = graphics;
        
        g.beginFill(0x333344);
        g.drawRect(-POLE_THICK / 2, 0, POLE_THICK, SuperExpressMain.HEIGHT);
        g.endFill();
        
        g.lineStyle(1, 0x222233);
        g.moveTo(POLE_THICK / 2, WIRE_TOP);
        g.curveTo(SPACING / 2, WIRE_BOTTOM, SPACING - POLE_THICK, WIRE_TOP);
        g.moveTo(-POLE_THICK / 2, WIRE_TOP);
        g.curveTo(-SPACING / 2, WIRE_BOTTOM, -SPACING + POLE_THICK, WIRE_TOP);
        
        x = (SPACING + SuperExpressMain.WIDTH) / 2;
    }
    
    public override function update():void
    {
        x -= SPEED;
        if (x < (-SPACING + SuperExpressMain.WIDTH) / 2) {
            x += SPACING;
        }
    }
}

class Tunnel extends Entity
{
    // |ENTRANCE|SPACE|LIGHT|SPACE|ENTRANCE|
    // ^ origin
    
    private const LIGHT:Number = 100;
    private const SPACE:Number = SuperExpressMain.WIDTH * 1.4;
    private const ENTRANCE:Number = SuperExpressMain.WIDTH * 1.5;
    private const WIDTH:Number = LIGHT + SPACE * 2 + ENTRANCE * 2;
    
    private const ENTRANCE_COLOR:uint = 0x888899;
    private const DARKNESS_COLOR:uint = 0x0A0908;
    private const LIGHT_COLOR:uint = 0xFFF0E0;
    
    private var lightCount:int;
    private var light:Shape;
    
    function Tunnel()
    {
        var g:Graphics = graphics;
        
        var matrix:Matrix = new Matrix();
        matrix.createGradientBox(ENTRANCE, SuperExpressMain.HEIGHT);
        g.beginGradientFill(GradientType.LINEAR, [ENTRANCE_COLOR, DARKNESS_COLOR], null, [0, 255], matrix);
        g.drawRect(0, 0, ENTRANCE, SuperExpressMain.HEIGHT);
        matrix.createGradientBox(ENTRANCE, SuperExpressMain.HEIGHT, 0, WIDTH - ENTRANCE, 0);
        g.beginGradientFill(GradientType.LINEAR, [DARKNESS_COLOR, ENTRANCE_COLOR], null, [0, 255], matrix);
        g.drawRect(WIDTH - ENTRANCE, 0, ENTRANCE, SuperExpressMain.HEIGHT);
        g.endFill();
        
        g.beginFill(DARKNESS_COLOR);
        g.drawRect(ENTRANCE, 0, LIGHT + SPACE * 2, SuperExpressMain.HEIGHT);
        g.endFill();
        
        light = new Shape();
        light.graphics.beginFill(LIGHT_COLOR);
        light.graphics.drawRect(WIDTH / 2, SuperExpressMain.HEIGHT * 0.55, LIGHT, 20);
        light.graphics.endFill();
        addChild(light);
        
        prepareNextTunnel();
        
        // 最初のトンネルまでは定距離にする。
        x = SPEED * 600;
    }
    
    public override function update():void
    {
        x -= SPEED;
        if (x < -(WIDTH - ENTRANCE - SuperExpressMain.WIDTH)) {
            if (--lightCount >= 0) {
                // ライトをループ
                x += SPACE * 2 + LIGHT - SuperExpressMain.WIDTH;
                trace(length);
            }
        }
        if (x < -WIDTH * 2) {
            prepareNextTunnel();
        }
    }
    
    private function prepareNextTunnel():void
    {
        x = SPEED * rnd(300, 1500);
        lightCount = rnd(6, 60);
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
//    return lerp(min, max, Math.random());
}





    import flash.display.*;
    import flash.events.*;
    import flash.geom.*;
    import net.hires.debug.Stats;
    
    internal class SeaAndCloudsMain extends Sprite
    {
        public static const WIDTH:Number = 465;
        public static const HEIGHT:Number = 465;
        
        private var debug:Boolean = false;
        private var sun:SunLight;
        private var entities:Vector.<Entity> = new Vector.<Entity>();
        private var sunBlock:BitmapData = new BitmapData(WIDTH, HEIGHT);
        private var renderedSky:BitmapData = new BitmapData(WIDTH, (HEIGHT+1)/2);
        private var scene:Sprite = new Sprite;
        private var clouds:Clouds
        private var sea:Sea;
        
        public static const CLOUD_NUM:int = 50;
        public static const ERROR_SEEDS:Array = [346, 514, 1155, 1519, 1690, 1977, 2327, 2337, 2399, 2860, 2999, 3099, 4777, 4952, 5673, 6265, 7185, 7259, 7371, 7383, 7717, 7847, 8032, 8350, 8676, 8963, 8997, 9080, 9403, 9615, 9685];
        public var loading:LoadingScene;

        public function SeaAndCloudsMain():void
        {
            if (stage) init();
            else addEventListener(Event.ADDED_TO_STAGE, init);
        }
        
        private function init(e:Event = null):void {
            removeEventListener(Event.ADDED_TO_STAGE, init);
            loading = new LoadingScene();
            addChild(loading);
            addEventListener(Event.ENTER_FRAME, onLoading);
        }

        // cloud constants
        public static const FOCUS:Number = 500;
        public static const MAX_Z:Number = 5000;
        public static const MIN_Z:Number = 300;

        private function onLoading(...arg):void {
            for (var i:int = 0; i < 3; i++) {
                if(Clouds.bmps.length >= CLOUD_NUM){
                    start();
                    break;
                }
                var seed:int = Math.random() * 10000 + 1;
                if (ERROR_SEEDS.indexOf(seed) >= 0) seed++;
                var ct:Number = (Math.random() < 0.2)? Math.random() * 0.3 : Math.random() * 1.5;
                var z:Number = MAX_Z - (MAX_Z-MIN_Z)/CLOUD_NUM*(Clouds.bmps.length);
                var w:Number = 400/(z/FOCUS);
                var h:Number = 200/(z/FOCUS);
                var bmp:Bitmap = new Bitmap(Painter.createCloud(w, h, seed, ct, Color.cloudBase, Color.cloudLight, Color.cloudShadow));
                bmp.x = Math.random() * (SeaAndCloudsMain.WIDTH + bmp.width) - bmp.width;
                bmp.y = HEIGHT*0.5 - HEIGHT*0.5 * FOCUS/z;
                Clouds.bmps.push(bmp);
                loading.setProgress(Clouds.bmps.length / CLOUD_NUM);
            }
        }

        public function start():void
        {
            removeEventListener(Event.ENTER_FRAME, onLoading);
            removeChild(loading);
            stage.quality = StageQuality.MEDIUM;

            var matrix:Matrix = new Matrix();
            matrix.createGradientBox(WIDTH, HEIGHT, Math.PI / 2);
            //graphics.beginGradientFill(GradientType.LINEAR, [0x45719B, 0xA08E74], null, [0, 128], matrix);
            graphics.beginGradientFill(GradientType.LINEAR, [0x35415B, 0xA08E74], null, [0, 128], matrix);
            graphics.drawRect(0, 0, WIDTH, HEIGHT);
            graphics.endFill();

            clouds = new Clouds;
            addChild(clouds);

            sea = new Sea(renderedSky);
            sea.y = HEIGHT/2;
            scene.addChild(sea);
           
            addChild(scene);
            sun = new SunLight(sunBlock);
            addChild(sun);
            sun.scrollRect = new Rectangle(0,0,WIDTH,(HEIGHT+1)/2);
            
            addEventListener(Event.ENTER_FRAME, enterFrameHandler);
        }
        
        private function enterFrameHandler(e:Event):void 
        {
            clouds.update();
            sunBlock.fillRect(sunBlock.rect, 0);
            sunBlock.draw(clouds);
            sunBlock.fillRect(new Rectangle(0, sea.y+2, WIDTH, (HEIGHT+1)/2-2), 0xff000000); // sea blocks sun rays (extra rows for smoother transition)
            sun.update();
            renderedSky.fillRect(renderedSky.rect, 0);
            renderedSky.draw(this);
            sea.update();
        }
    }


import flash.display.*;
import flash.filters.*;
import flash.geom.*;
import flash.utils.*;

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
    private var blur:BlurFilter = new BlurFilter(5, 5, 1);
    
    public function SunLight(obstruction:BitmapData) {
        this.blendMode = "add";
        this.obstruction = new Bitmap(obstruction);
        var m:Matrix = new Matrix;
        m.createGradientBox(FXW, FXH, 0, 0, 0);
        sun.graphics.beginGradientFill("radial", [0x0C0a08, 0x0a0806, 0x060504, 0x020201, 0], [1, 1, 1, 1, 1], [0, 10, 34, 64, 255], m);
        sun.graphics.drawRect(0, 0, FXW, FXH);
        sun.graphics.endFill();
        sun.cacheAsBitmap = true;
        
        scaleDown.scale(FXW/SeaAndCloudsMain.WIDTH, FXH/SeaAndCloudsMain.HEIGHT);
        scaleUp.scale(SeaAndCloudsMain.WIDTH/FXW, SeaAndCloudsMain.HEIGHT/FXH);

        addChild(canvas);
        canvas.transform.matrix = scaleUp;
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

class Clouds extends Entity {
    public static var bmps:Array = [];

    public function Clouds() {
        for each(var bmp:Bitmap in bmps) addChild(bmp);
    }

    public override function update():void {
        for each(var bmp:Bitmap in bmps) {
            bmp.x -= bmp.width * 0.002;
            if(bmp.x + bmp.width < 0) {
                bmp.x = SeaAndCloudsMain.WIDTH;
            }
        }
    }
}

class Sea extends Entity {
    private const nearScale:Number = 0.25;
    private var vertices:Vector.<Number> = new Vector.<Number>;
    private var uvt:Vector.<Number> = new Vector.<Number>;
    private var indices:Vector.<int> = new Vector.<int>;
    private const octaves:int = 3;
    private const seed:int = 1;
    private var offsets:Array = [];
    private var output:BitmapData = new BitmapData(SeaAndCloudsMain.WIDTH, (SeaAndCloudsMain.HEIGHT+1)/2, false);
    private var noise:BitmapData = new BitmapData(SeaAndCloudsMain.WIDTH/2, (SeaAndCloudsMain.HEIGHT+3)/4, true);
    private var upsideDown:BitmapData = new BitmapData(SeaAndCloudsMain.WIDTH, (SeaAndCloudsMain.HEIGHT+1)/2, true);
    private var seaShape:Shape = new Shape;
    private var seaBmd:BitmapData = new BitmapData(SeaAndCloudsMain.WIDTH, (SeaAndCloudsMain.HEIGHT+1)/2, true);
    private var seaBmp:Bitmap;
    private var ct:ColorTransform = new ColorTransform(1.5, 0.8, 0.75, 1, -128, 48, 64);
    private const seaMtx:Matrix = new Matrix(1, 0, 0, 1, 0, 0);
    private const upsideDownMtx:Matrix = new Matrix(1, 0, 0, -1, 0, SeaAndCloudsMain.HEIGHT/2);
    private var dispFilter:DisplacementMapFilter = new DisplacementMapFilter(seaBmd, null, 0, 8, 0, SeaAndCloudsMain.HEIGHT/-2, "clamp");
            //dispFilter = new DisplacementMapFilter(seaBmd, null, 0, 8, 0, Main.HEIGHT/2, "clamp");

    private var backdrop:BitmapData;
    private var cachedOctaves:Array = []; // precalculated perlin noise

    public function Sea(backdrop:BitmapData) {
        vertices.push(0, 0, SeaAndCloudsMain.WIDTH-1, 0, 0, SeaAndCloudsMain.HEIGHT/2-1, SeaAndCloudsMain.WIDTH-1, SeaAndCloudsMain.HEIGHT/2-1);
        uvt.push(
            0, 0, nearScale, 
            1, 0, nearScale, 
            (1-nearScale)/2, 1, 1,
            (1+nearScale)/2, 1, 1);
        indices.push(0, 1, 2, 2, 1, 3);

        this.backdrop = backdrop;
        seaBmp = new Bitmap(seaBmd);

        initNoise();
        addChild(new Bitmap(output));
    }

    private function initNoise():void {
        for(var i:int = 0; i < octaves; i++) {
            var bmd:BitmapData = new BitmapData(SeaAndCloudsMain.WIDTH/2, (SeaAndCloudsMain.HEIGHT+3)/4, true, 0);
            var pr:Number = 1/Math.pow(2, i);
            bmd.perlinNoise(24*pr, 2*pr, 1, 0, true, true, 0xF, false);
            pr /= 2;
            bmd.colorTransform(bmd.rect, new ColorTransform(pr, pr, pr, pr));
            cachedOctaves.push(bmd);
        }
    }

    private function fastPerlin(dst:BitmapData, xOffsets:Array):void {
        dst.fillRect(dst.rect, 0);
        for(var i:int = 0; i < octaves; i++) {
            var offset:int = xOffsets[i];
            if(offset >= 0) {
                offset %= dst.width;
            } else {
                offset = dst.width - (-offset % dst.width);
            }
            var mtx:Matrix = new Matrix;
            mtx.tx = offset;
            dst.draw(cachedOctaves[i], mtx, null, "add");
            mtx.tx = offset - dst.width;
            dst.draw(cachedOctaves[i], mtx, null, "add");
        }
    }

    override public function update():void {
        for(var i:int = 0; i < octaves; i++) offsets[i] = ((i&1)*2-1) * (1+i)*getTimer()/150;
        fastPerlin(noise, offsets);
        seaShape.graphics.clear();
        seaShape.graphics.beginBitmapFill(noise, null, false, true);
        seaShape.graphics.drawTriangles(vertices, indices, uvt);
        seaShape.graphics.endFill();
        seaBmd.fillRect(seaBmd.rect, 0);
        seaBmd.draw(seaShape, seaMtx);
        // reflection
        upsideDown.fillRect(upsideDown.rect, 0);
        upsideDown.draw(backdrop, new Matrix(1, 0, 0, -1, 0, SeaAndCloudsMain.HEIGHT/2));
        output.applyFilter(upsideDown, upsideDown.rect, upsideDown.rect.topLeft, dispFilter);
        output.colorTransform(output.rect, ct); // blue-green tint
    }
}

class Color {
    /**雲の色*/
    static public var cloudBase:uint = 0x725040;
    /**雲のハイライト色*/
    static public var cloudLight:uint = 0xFDDFC9;
    /**雲の影の色*/
    static public var cloudShadow:uint = 0x38231E;
}

class LoadingScene extends Sprite {
    private var _lineWidth:Number = 200;
    private var _loadedLine:Sprite;
    public function LoadingScene() {
        var bg:Sprite = addChild(Painter.createGradientRect(SeaAndCloudsMain.WIDTH, SeaAndCloudsMain.HEIGHT, [0x000000], [1])) as Sprite;
        var baseLine:Sprite = addChild(Painter.createGradientRect(_lineWidth, 2, [0x444444], [1])) as Sprite;
        _loadedLine = addChild(Painter.createGradientRect(_lineWidth, 2, [0x96644E], [1])) as Sprite;
        baseLine.x = _loadedLine.x = int((SeaAndCloudsMain.WIDTH - _lineWidth) / 2);
        baseLine.y = _loadedLine.y = int((SeaAndCloudsMain.HEIGHT - baseLine.height) / 2);
        setProgress(0);
    }
    public function setProgress(per:Number):void {
        _loadedLine.width = _lineWidth * per;
    }
}

class Painter {
    /**
    * 雲画像生成
    * @param    width    幅
    * @param    height    高さ
    * @param    seed    ランダムシード値
    * @param    contrast    コントラスト0～
    * @param    color    ベースの色
    * @param    light    明るい色
    * @param    shadow    暗い色
    */
    static public function createCloud(width:int, height:int, seed:int, contrast:Number = 1, color:uint = 0xFFFFFF, light:uint = 0xFFFFFF, shadow:uint = 0xDDDDDD):BitmapData {
        var gradiation:Sprite = new Sprite();
        var drawMatrix:Matrix = new Matrix();
        drawMatrix.createGradientBox(width, height);
        gradiation.graphics.beginGradientFill("radial", [0x000000, 0x000000], [0, 1], [0, 255], drawMatrix);
        gradiation.graphics.drawRect(0, 0, width, height);
        gradiation.graphics.endFill();
        var alphaBmp:BitmapData = new BitmapData(width, height);
        alphaBmp.perlinNoise(width / 3, height / 2.5, 5, seed, false, true, 1|2|4, true);
        var zoom:Number = 1 + (contrast - 0.1) / (contrast + 0.9);
        if (contrast < 0.1) zoom = 1;
        if (contrast > 2.0) zoom = 2;
        var ctMatrix:Array = [contrast + 1, 0, 0, 0, -128 * contrast, 0, contrast + 1, 0, 0, -128 * contrast, 0, 0, contrast + 1, 0, -128 * contrast, 0, 0, 0, 1, 0];
        alphaBmp.draw(gradiation, new Matrix(zoom, 0, 0, zoom, -(zoom - 1) / 2 * width, -(zoom - 1) / 2 * height));
        alphaBmp.applyFilter(alphaBmp, alphaBmp.rect, new Point(), new ColorMatrixFilter(ctMatrix));
        var image:BitmapData = new BitmapData(width, height, true, 0xFF << 24 | color);
        image.copyChannel(alphaBmp, alphaBmp.rect, new Point(), 4, 8);
        image.applyFilter(image, image.rect, new Point(), new GlowFilter(light, 1, 4, 4, 1, 3, true));
        var bevelSize:Number = Math.min(width, height) / 30;
        image.applyFilter(image, image.rect, new Point(), new BevelFilter(bevelSize, 45, light, 1, shadow, 1, bevelSize/5, bevelSize/5, 1, 3));
        var image2:BitmapData = new BitmapData(width, height, true, 0);
        image2.draw(Painter.createGradientRect(width, height, [light, color, shadow], [1, 0.2, 1], null, 90), null, null, BlendMode.MULTIPLY);
        image2.copyChannel(alphaBmp, alphaBmp.rect, new Point(), 4, 8);
        image.draw(image2, null, null, BlendMode.MULTIPLY);
        alphaBmp.dispose();
        return image;
    }
    /**
    * グラデーションスプライト生成
    */
    static public function createGradientRect(width:Number, height:Number, colors:Array, alphas:Array, ratios:Array = null, rotation:Number = 0):Sprite {
        var i:int, rts:Array = new Array();
        if(ratios == null) for (i = 0; i < colors.length; i++) rts.push(int(255 * i / (colors.length - 1)));
        else for (i = 0; i < ratios.length; i++) rts[i] = Math.round(ratios[i] * 255);
        var sp:Sprite = new Sprite();
        var mtx:Matrix = new Matrix();
        mtx.createGradientBox(width, height, Math.PI / 180 * rotation, 0, 0);
        if (colors.length == 1 && alphas.length == 1) sp.graphics.beginFill(colors[0], alphas[0]);
        else sp.graphics.beginGradientFill("linear", colors, alphas, rts, mtx);
        sp.graphics.drawRect(0, 0, width, height);
        sp.graphics.endFill();
        return sp;
    }
}

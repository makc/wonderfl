// forked from yonatan's Clouds and snow (cloud painter from tencho's Sea of Clouds - http://wonderfl.net/c/h9dR)
// forked from cjcat2266's Super Express Desert Sunset + Rain (Stardust ver.)
// forked from yonatan's Super Express Desert Sunset
// forked from k0rin's Super Express

package {
    import flash.display.*;
    import flash.events.*;
    import flash.geom.*;
    import net.hires.debug.Stats;
    
    [SWF(width = "465", height = "465", frameRate = "40")]
    public class Main extends Sprite
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

        public function Main():void
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
                bmp.x = Math.random() * (Main.WIDTH + bmp.width) - bmp.width;
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
            var stats:Stats = new Stats;
            stats.visible = false;
            addChild(stats);
            stage.addEventListener("click", function(e:*):void {stats.visible = !stats.visible});
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
}

import flash.display.*;
import flash.filters.*;
import flash.geom.*;
import flash.utils.*;

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
        
        scaleDown.scale(FXW/Main.WIDTH, FXH/Main.HEIGHT);
        scaleUp.scale(Main.WIDTH/FXW, Main.HEIGHT/FXH);

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
                bmp.x = Main.WIDTH;
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
    private var output:BitmapData = new BitmapData(Main.WIDTH, (Main.HEIGHT+1)/2, false);
    private var noise:BitmapData = new BitmapData(Main.WIDTH/2, (Main.HEIGHT+3)/4, true);
    private var upsideDown:BitmapData = new BitmapData(Main.WIDTH, (Main.HEIGHT+1)/2, true);
    private var seaShape:Shape = new Shape;
    private var seaBmd:BitmapData = new BitmapData(Main.WIDTH, (Main.HEIGHT+1)/2, true);
    private var seaBmp:Bitmap;
    private var ct:ColorTransform = new ColorTransform(1.5, 0.8, 0.75, 1, -128, 48, 64);
    private const seaMtx:Matrix = new Matrix(1, 0, 0, 1, 0, 0);
    private const upsideDownMtx:Matrix = new Matrix(1, 0, 0, -1, 0, Main.HEIGHT/2);
    private var dispFilter:DisplacementMapFilter = new DisplacementMapFilter(seaBmd, null, 0, 8, 0, Main.HEIGHT/-2, "clamp");
            //dispFilter = new DisplacementMapFilter(seaBmd, null, 0, 8, 0, Main.HEIGHT/2, "clamp");

    private var backdrop:BitmapData;
    private var cachedOctaves:Array = []; // precalculated perlin noise

    public function Sea(backdrop:BitmapData) {
        vertices.push(0, 0, Main.WIDTH-1, 0, 0, Main.HEIGHT/2-1, Main.WIDTH-1, Main.HEIGHT/2-1);
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
            var bmd:BitmapData = new BitmapData(Main.WIDTH/2, (Main.HEIGHT+3)/4, true, 0);
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
        upsideDown.draw(backdrop, new Matrix(1, 0, 0, -1, 0, Main.HEIGHT/2));
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
        var bg:Sprite = addChild(Painter.createGradientRect(Main.WIDTH, Main.HEIGHT, [0x000000], [1])) as Sprite;
        var baseLine:Sprite = addChild(Painter.createGradientRect(_lineWidth, 2, [0x444444], [1])) as Sprite;
        _loadedLine = addChild(Painter.createGradientRect(_lineWidth, 2, [0x96644E], [1])) as Sprite;
        baseLine.x = _loadedLine.x = int((Main.WIDTH - _lineWidth) / 2);
        baseLine.y = _loadedLine.y = int((Main.HEIGHT - baseLine.height) / 2);
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

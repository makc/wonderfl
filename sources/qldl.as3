// forked from cjcat2266's Super Express Desert Sunset + Rain (Stardust ver.)
// forked from yonatan's Super Express Desert Sunset

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
    // import net.hires.debug.Stats;
    import idv.cjcat.stardust.twoD.emitters.Emitter2D;
    
    [SWF(width = "465", height = "465", frameRate = "40")]
    public class Main extends Sprite
    {
        public static const WIDTH:Number = 465;
        public static const HEIGHT:Number = 465;
        
        private var debug:Boolean = false;
        private var sun:SunLight;
        private var entities:Vector.<Entity> = new Vector.<Entity>();
        private var renderedScene:BitmapData = new BitmapData(WIDTH, HEIGHT);
        private var scene:Sprite = new Sprite;
        
        private var emitter:Emitter2D;
        
        public static const CLOUD_NUM:int = 50;
        public static const ERROR_SEEDS:Array = [346, 514, 1155, 1519, 1690, 1977, 2327, 2337, 2399, 2860, 2999, 3099, 4777, 4952, 5673, 6265, 7185, 7259, 7371, 7383, 7717, 7847, 8032, 8350, 8676, 8963, 8997, 9080, 9403, 9615, 9685];
        public var loading:LoadingScene;

        /**perlinNoiseに使うとまずいシード値（画像に穴があくかもしれない）*/
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
        public static const MAX_Z:Number = 4000;
        public static const MIN_Z:Number = 250;

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
                bmp.y = HEIGHT*0.55 - HEIGHT*0.5 * FOCUS/z;
                Clouds.bmps.push(bmp);
                loading.setProgress(Clouds.bmps.length / CLOUD_NUM);
            }
        }

        public function start():void
        {
            removeEventListener(Event.ENTER_FRAME, onLoading);
            removeChild(loading);
            stage.quality = StageQuality.MEDIUM;
            // 空を描画
            var matrix:Matrix = new Matrix();
            matrix.createGradientBox(WIDTH, HEIGHT, Math.PI / 2);
            graphics.beginGradientFill(GradientType.LINEAR, [0x51484A, 0x96644E, 0x483B30], null, [0, 128, 160], matrix);
            graphics.drawRect(0, 0, WIDTH, HEIGHT);
            graphics.endFill();

            var clouds:Clouds = new Clouds;
            entities.push(scene.addChild(clouds));
            
            var fogR:Number = 0x40;
            var fogG:Number = 0x35;
            var fogB:Number = 0x2c;
            
            var mountainR:Number = 0x17;
            var mountainG:Number = 0x13;
            var mountainB:Number = 0x15;

            const NUMBER_OF_MOUNTAINS:int = 4;
            
            for (var i:int = 0; i < NUMBER_OF_MOUNTAINS; i++) {
                var blend:Number = i / (NUMBER_OF_MOUNTAINS - 1);
                
                var _r:Number = lerp(fogR, mountainR, blend);
                var _g:Number = lerp(fogG, mountainG, blend);
                var _b:Number = lerp(fogB, mountainB, blend);
                
                var baseHeight:Number = HEIGHT * 0.55 + i * 25;
                var color:uint = (_r << 16) | (_g << 8) | _b;
                
                var mountain:Mountain = new Mountain(-Math.pow(i + 1, 2), baseHeight, color);
                entities.push(scene.addChild(mountain));
            }
            
            entities.push(scene.addChild(new PoleAndWire()));
            entities.push(scene.addChild(new Tunnel()));
            
            //insert emitter
            emitter = new RainEmitter(scene);
            
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
            // addChild(new Stats);
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
            
            emitter.step();
            
            renderedScene.fillRect(renderedScene.rect, 0);
            renderedScene.draw(scene);
            sun.update();
        }
    }
}

import flash.display.*;
import flash.filters.*;
import flash.geom.*;
import idv.cjcat.stardust.common.actions.Die;
import idv.cjcat.stardust.common.actions.triggers.ActionTrigger;
import idv.cjcat.stardust.common.clocks.SteadyClock;
import idv.cjcat.stardust.common.initializers.Scale;
import idv.cjcat.stardust.common.math.UniformRandom;
import idv.cjcat.stardust.twoD.actions.Gravity;
import idv.cjcat.stardust.twoD.actions.Move;
import idv.cjcat.stardust.twoD.actions.Oriented;
import idv.cjcat.stardust.twoD.actions.RandomDrift;
import idv.cjcat.stardust.twoD.actions.triggers.ZoneTrigger;
import idv.cjcat.stardust.twoD.emitters.Emitter2D;
import idv.cjcat.stardust.twoD.fields.UniformField;
import idv.cjcat.stardust.twoD.handlers.DisplayObjectHandler;
import idv.cjcat.stardust.twoD.initializers.DisplayObjectClass;
import idv.cjcat.stardust.twoD.initializers.Position;
import idv.cjcat.stardust.twoD.initializers.Velocity;
import idv.cjcat.stardust.twoD.zones.LazySectorZone;
import idv.cjcat.stardust.twoD.zones.RectZone;
import idv.cjcat.stardust.twoD.zones.Zone;

class Rain extends Shape {
    
    public function Rain() {
        graphics.beginFill(0x303030);
        graphics.drawRect( -1, -15, 2, 30);
        
        blendMode = BlendMode.ADD;
        filters = [new BlurFilter(20, 0)];
    }
}

class RainEmitter extends Emitter2D {
    
    public function RainEmitter(container:DisplayObjectContainer) {
        super(new SteadyClock(2));
        
        //initializers
        addInitializer(new DisplayObjectClass(Rain));
        addInitializer(new Position(new RectZone(500, -50, 1, 500)));
        addInitializer(new Scale(new UniformRandom(1, 0.7)));
        
        var lazyRectZone:LazySectorZone = new LazySectorZone();
        lazyRectZone.direction.set(-1, 0);
        lazyRectZone.directionVar = 20;
        lazyRectZone.radius = 25;
        lazyRectZone.radiusVar = 15;
        addInitializer(new Velocity(lazyRectZone));
        
        //actions
        addAction(new Move());
        addAction(new Oriented());
        addAction(new RandomDrift(6, 4));
        
        //gravity
        var gravity:Gravity = new Gravity();
        gravity.addField(new UniformField(-2, 1));
        addAction(gravity);
        
        //death zone
        var deathZone:Zone = new RectZone( -50, -50, 600, 600);
        var zoneTrigger:ActionTrigger = new ZoneTrigger(deathZone);
        zoneTrigger.inverted = true;
        zoneTrigger.addAction(new Die());
        addAction(zoneTrigger);
        
        //particle handler
        particleHandler = new DisplayObjectHandler(container);
    }
}

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

class Clouds extends Entity {
    public static var bmps:Array = [];

    public function Clouds() {
        for each(var bmp:Bitmap in bmps) addChild(bmp);
    }

    public override function update():void {
        for each(var bmp:Bitmap in bmps) {
            bmp.x -= bmp.width * 0.001;
            if(bmp.x + bmp.width < 0) {
                bmp.x = Main.WIDTH;
            }
        }
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
        x = SPEED * 1800;
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
        x = SPEED * rnd(1300, 4000);
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

// copy-pasta from tencho's Sea of Clouds...

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

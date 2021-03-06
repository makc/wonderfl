// forked from paq's Clouds and snow + SE
// forked from yonatan's Clouds and snow
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

//Music : Course ( Yusaku Kishigami )
//http://www.geocities.jp/presence_of_music/home.html

package {
    import flash.display.*;
    import flash.events.*;
    import flash.filters.BlurFilter;
    import flash.geom.*;
    import flash.media.Sound;
    import flash.media.SoundChannel;
    import flash.media.SoundLoaderContext;
    import flash.media.SoundTransform;
    import flash.net.URLRequest;
    import flash.system.LoaderContext;
    import flash.utils.Timer;
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
        private var soundRun:Sound;
        private var soundSL:Sound;
        private var soundRunChannel:SoundChannel;
        
        private var bgmSound:Sound;
        private var sepiaCanvas:BitmapData;
        private var sepiaBmp:Bitmap;
        private var _mariji:Mariji;
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
            //
            var l:Loader = new Loader();
            l.contentLoaderInfo.addEventListener(Event.COMPLETE, _onLoadAssets);
            l.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, _onLoadAssets);
            l.load(new URLRequest("http://assets.wonderfl.net/images/related_images/e/e0/e046/e046ef99d94b80c5c5bcb74c85a72cab6a9b12df"), new LoaderContext(true));
            
            addEventListener(Event.ENTER_FRAME, onLoading);
        }
        private function _onLoadAssets(e:Event):void
        {
            var li:LoaderInfo = e.target as LoaderInfo;
            li.removeEventListener(Event.COMPLETE, _onLoadAssets);
            li.removeEventListener(IOErrorEvent.IO_ERROR, _onLoadAssets);
            if (e.type == Event.COMPLETE)
            {
                _mariji = new Mariji((li.content as Bitmap).bitmapData.clone());
                (li.content as Bitmap).bitmapData.dispose();
                if(Clouds.bmps.length >= CLOUD_NUM){
                    start();
                }
            }
        }
        // cloud constants
        public static const FOCUS:Number = 500;
        public static const MAX_Z:Number = 4000;
        public static const MIN_Z:Number = 250;

        private function onLoading(...arg):void {
            for (var i:int = 0; i < 3; i++) {
                if(Clouds.bmps.length >= CLOUD_NUM && Mariji.isReady){
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
                bmp.y = HEIGHT*0.6 - HEIGHT*0.5 * FOCUS/z;
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
            graphics.beginGradientFill(GradientType.LINEAR, [0x51484A, 0x96644E], null, [0, 128], matrix);
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
                
                var mountain:Mountain = new Mountain( -Math.pow(i + 1, 2), baseHeight, color);
                Mariji.setTarget(mountain);
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
            
            playSound();
            
            stage.addEventListener(MouseEvent.CLICK, clickHandler);
            addEventListener(Event.ENTER_FRAME, enterFrameHandler);
            // addChild(new Stats);
            
            var canvas:BitmapData = createOldFilmNoise(stage.stageWidth * 3, stage.stageHeight * 3);

            sepiaCanvas = createSepiaCanvas(stage.stageWidth * 3, stage.stageHeight * 3);
            sepiaCanvas.draw(canvas);
            sepiaBmp = this.addChild(new Bitmap(sepiaCanvas)) as Bitmap;
            
            var blackframeSprite:Sprite = new Sprite();
            blackframeSprite.graphics.beginFill(0x0);
            blackframeSprite.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
            blackframeSprite.graphics.drawRoundRect(10, 50, stage.stageWidth - 20, stage.stageHeight - 100, 20, 20);
            blackframeSprite.graphics.endFill();
            blackframeSprite.filters = [new BlurFilter(8, 8, 1)];
            this.addChild(blackframeSprite);
            
            scene.addChild(_mariji);
            //_mariji.setTarget(mountain);
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
            
            if (soundRunChannel && soundRunChannel.position >= 14025)
            {
                soundRunChannel.stop();
                soundRunChannel = soundRun.play(3169, 0, new SoundTransform(0.2));
                trace(soundRunChannel.position);
            }
            
            
            sepiaBmp.x = (stage.stageWidth - sepiaBmp.width) * Math.random();
            sepiaBmp.y = (stage.stageHeight - sepiaBmp.height) * Math.random();
            _mariji.update();
        }
        
        private function playSound():void
        {
            var context:SoundLoaderContext = new SoundLoaderContext(1000, true);
            soundRun = new Sound(new URLRequest("http://paq.s346.xrea.com/wonderfl/sound/sl_run.mp3"), context);
            soundSL = new Sound(new URLRequest("http://paq.s346.xrea.com/wonderfl/sound/sl.mp3"), context);
            bgmSound = new Sound(new URLRequest("http://melancholy.raindrop.jp/flash/wonderfl_4/Course.mp3"), context);
            
            soundRun.addEventListener(Event.COMPLETE, function():void {
                soundRun.removeEventListener(Event.COMPLETE, arguments.callee);
                soundRunChannel = soundRun.play(0, 0, new SoundTransform(0.2));
            });
            soundSL.addEventListener(Event.COMPLETE, function():void {
                soundSL.removeEventListener(Event.COMPLETE, arguments.callee);
                var timer:Timer = new Timer(3000);
                timer.addEventListener(TimerEvent.TIMER, function():void {
                    timer.removeEventListener(TimerEvent.TIMER, arguments.callee);
                    timer = null;
                    soundSL.play(0, 0, new SoundTransform(0.2));
                });
                timer.start();
            });
            
            bgmSound.addEventListener(Event.COMPLETE, function():void {
                bgmSound.removeEventListener(Event.COMPLETE, arguments.callee);
                bgmSound.play(0, int.MAX_VALUE);
            });
        }
        
        private function createOldFilmNoise(width:uint, height:uint):BitmapData
        {
            var canvas:BitmapData = new BitmapData(width, height, true, 0xFF000000);
            canvas.lock();
            
            var circleRadius:Number = 4;
            
            var circle:Sprite = new Sprite();
            circle.graphics.beginFill(0xFFFFFF, 1);
            circle.graphics.drawCircle(circleRadius, circleRadius, circleRadius);
            circle.graphics.endFill();
            
            var circleCanvas:BitmapData = new BitmapData(circle.width, circle.height, true, 0x0);
            circleCanvas.draw(circle, null, null, null, null, true);
            
            var i:int;
            var len:int = width * height * 0.17;
            
            for (i = 0; i < len; i++)
            {
                canvas.copyPixels(circleCanvas, circleCanvas.rect, new Point(Math.random() * canvas.width - circleRadius, Math.random() * canvas.height - circleRadius), circleCanvas, new Point(), true);
            }
            
            
            var canvas2:BitmapData = new BitmapData(canvas.width, canvas.height);
            canvas2.draw(canvas, new Matrix(2, 0, 0, 2), null, null, null, true);
            
            canvas.threshold(canvas2, canvas2.rect, new Point(), ">=", 0xFF880000, 0x00000000, 0xFFFF0000, true);
            
            
            var noiseBmpd:BitmapData = new BitmapData(canvas.width, canvas.height);
            noiseBmpd.noise(Math.random() * int.MAX_VALUE, 0, 255, 7, true);
            noiseBmpd.colorTransform(noiseBmpd.rect, new ColorTransform(1.5, 1.5 , 1.5, 0.8));
            
            len = canvas.width;
            var noiseLine:BitmapData = new BitmapData(1, canvas.height);
            noiseLine.lock();
            
            var j:int;
            var len2:int = canvas.height;
            var color:uint;
            for (i = 0; i < len; i++)
            {
                if (Math.random() > 0.999)
                {
                    
                    noiseLine.copyPixels(noiseBmpd, new Rectangle(i, 0, 1, canvas.height), new Point());
                    for (j = 0; j < len2; j++)
                    {
                        color = noiseLine.getPixel32(0, j);
                        color = ((color & 0xff) ^ 0xff) << 24 | (color & 0xFFFFFF);
                        noiseLine.setPixel32(0, j, color);
                    }
                    
                    canvas.copyPixels(noiseLine, new Rectangle(0, 0, 1, canvas.height), new Point(i, 0));
                    
                }
            }
            noiseLine.unlock();
            
            canvas.applyFilter(canvas, canvas.rect, new Point(), new BlurFilter(2, 2));
            canvas.unlock();
            return canvas;
        }
        
        
        
        
        private function createSepiaCanvas(width:uint, height:uint):BitmapData
        {
            
            var canvas:BitmapData = new BitmapData(width, height, true, 0x0);
            canvas.fillRect(canvas.rect, 0x55EE9955);
            
            return canvas;
        }
        
        
        
    }
}
import flash.events.*;
import flash.display.*;
import flash.filters.*;
import flash.geom.*;
import flash.utils.getTimer;
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
import org.libspark.betweenas3.BetweenAS3;
import org.libspark.betweenas3.easing.Sine;
import org.libspark.betweenas3.tweens.ITween;

class Rain extends Shape {
    
    public function Rain() {
        graphics.beginFill(0x303030);
        graphics.drawRect( -1, -15, 2, 30);
        
        blendMode = BlendMode.ADD;
        filters = [new BlurFilter(20, 0)];
    }
}
class Mariji extends Sprite
{
    private static var _baseDatas:Vector.<BitmapData>;
    private static function _init(baseData:BitmapData):void
    {
        var vec:Vector.<BitmapData> = new Vector.<BitmapData>(4, true),
            i:int = 0, len:int = 4,
            ctra:ColorTransform = new ColorTransform(.5, .2, .2, 1),
            bmd:BitmapData,
            mt:Matrix = new Matrix(.5, 0, 0, .5, 0, 0),
            clip:Rectangle = new Rectangle(0, 0, 15, 16);
        mt.translate(0, -16);
        for (i = 0; i < len; i ++)
        {
            bmd = new BitmapData(clip.width, clip.height, true, 0x000000);
            bmd.draw(baseData, mt, ctra, null, clip);
            vec[i] = bmd;
            mt.translate( -15, 0);
        }
        baseData.dispose();
        _baseDatas = vec;
    }
    private static var _mountains:Vector.<Mountain>;
    private namespace normal = "normal";
    private namespace jump   = "jump";
    private var _next:int;
    private var _pos:int = 0;
    private var _target:Mountain;
    private var _scale:Number = 0;
    private var _toScale:Number;
    private var _isJump:Boolean;
    private var _ns:Namespace;
    private var _bm:Bitmap;
    private var _t:int;
    private var _vy:Number;
    public function Mariji(baseData:BitmapData)
    {
        if (!_baseDatas) _init(baseData);
        addChild(_bm = new Bitmap(_baseDatas[0]));
        _bm.x = -7;
        _bm.y = -16;
        x = 200;
        _ns = normal;
        addEventListener(Event.ADDED_TO_STAGE, _addStage);
    }
    public function update():void
    {
        _ns::update();
        _ns::draw();
    }
    private function _getNextTime():Number
    {
        return Math.random() * 1000 + 1000 + getTimer();
    }
    normal function update():void
    {
        var by:Number = y;
        y = _target.getCurrentCenterHight(x + 7);
        
        if (_next < getTimer())
        {
            _vy =  -(Math.random() * 10 + 20);
            _t = 0;
            _bm.bitmapData = _baseDatas[3];
            _changeTarget();
            rotation = 0;
            _ns = jump;
            _isJump = false;
        }
    }
    jump function update():void
    {
        ++_t;
        var dy:Number = _vy + 2 * _t;
        y += dy;
        _scale += (_toScale - _scale) * .2;
        scaleX = scaleY = _scale;
        
        if (dy < 0) return;
        
        if (!_isJump) 
        {
            parent.setChildIndex(this, parent.getChildIndex(_target));
            _isJump = true;
        }
        
        var ny:Number = _target.getCurrentCenterHight(x + 7);
        if (y > ny)
        {
            y = ny;
            _ns = normal;
            _next = _getNextTime();
        }
    }
    jump function draw():void
    {
        //
    }
    normal function draw():void
    {
        _pos = ++ _pos > 3 ? 0 : _pos;
        _bm.bitmapData = _baseDatas[_pos];
    }
    private function _changeTarget():void
    {
        var index:int = int(Math.random() * _mountains.length);
        _target = _mountains[index];
        _toScale = index / (_mountains.length - 1) * 1.5 + 1;
    }
    private function _addStage(e:Event):void
    {
        removeEventListener(Event.ADDED_TO_STAGE, _addStage);
        _changeTarget();
        parent.setChildIndex(this, parent.getChildIndex(_target));
        _next = _getNextTime();
        _isJump = false;
    }
    public static function setTarget(target:Mountain):void
    {
        if (!_mountains) _mountains = new Vector.<Mountain>();
        _mountains.push(target);
    }
    public static function get isReady():Boolean { return _baseDatas != null; }
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
    public function getCurrentCenterHight(xpos:int):Number
    {
        xpos = (xpos - x) / SEGMENT_LENGTH;
        //trace(xpos, heightMap.length);
        if (heightMap.length <= xpos || xpos < 0) return 0;
        else return heightMap[xpos];
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
    
    public function getSpeed():Number 
    {
        return speed;
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
        _loadedLine = addChild(Painter.createGradientRect(_lineWidth, 2, [0x7DA3C8], [1])) as Sprite;
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
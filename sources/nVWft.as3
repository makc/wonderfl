/**
 * 操作はできません
 */
package  {
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.BlendMode;
    import flash.display.Graphics;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.filters.BlurFilter;
    import flash.geom.ColorTransform;
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    public class Causticsoid extends Sprite {
        private var causticses:Vector.<Caustics> = new Vector.<Caustics>();
        private var skyBmp:BitmapData;
        private var sea:Sprite;
        private var floor:Sprite;
        private var lightWave:Sprite;
        private var waveContainer:Sprite;
        private var waveList:Array = new Array();
        private var waveMap:WaveMap;
        private var waveTexture:BitmapData;
        //各種パラメータ
        private const DISPLAY:Rectangle = new Rectangle(0, 0, 465, 465);
        private const FLOOR_SIZE:Rectangle = new Rectangle(0, 0, 850, 800);
        private const HORIZON:Number = 150;
        private const WAVE_LAYER:int = 5;
        private const WAVE_SPLIT:int = 15;
        private const BG_COLOR:uint = 0x000000;
        private const SKY1_COLOR:uint = 0x58BFED;
        private const SKY2_COLOR:uint = 0xD2E9F4;
        private const WAVE_COLOR:uint = 0x8DCCF0;
        private const FOG_COLOR:uint = 0x0063B8;
        private const FLOOR_COLOR:uint = 0x5DA59F;
        //コースティクスのパラメータ
        private const CAUSTICS_NUM:int = 10;
        private const CAUSTICS_SIZE:Rectangle = new Rectangle(0, 0, 300, 300);
        private const CAUSTICS_SEED:int = 130;
        private const CAUSTICS_STRENGTH:Number = 0.015;
        private const CAUSTICS_ALPHA:Number = 0.3;
        private const CAUSTICS_COLOR:Number = 0xFFFFFF;
        private const CAUSTICS_BLUR_X:Number = 10;
        private const CAUSTICS_BLUR_Y:Number = 2;
        private const CAUSTICS_SPEED:Number = 1;
        /**
         * コンストラクタ
         */
        public function Causticsoid() {
            var i:int;
            stage.frameRate = 30;
            transform.perspectiveProjection.fieldOfView = 50;
            transform.perspectiveProjection.projectionCenter = new Point(DISPLAY.width / 2, HORIZON - 100);
            //背景
            var bg:Sprite = Painter.createColorRect(DISPLAY.width * 5, DISPLAY.height * 5, BG_COLOR);
            bg.x = bg.y = (DISPLAY.width - bg.width) / 2;
            //空
            skyBmp = new BitmapData(DISPLAY.width, HORIZON, false);
            skyBmp.draw(Painter.createGradientRect(DISPLAY.width, HORIZON, true, [SKY1_COLOR, SKY2_COLOR], [1, 1], null, 90));
            skyBmp.draw(Painter.createCloud(400, 50, 0.2, 0xFFFFFF, 1, 1234), new Matrix(1, 0, 0, 1, -100, HORIZON - 50));
            skyBmp.draw(Painter.createCloud(300, 50, 0.3, 0xFFFFFF, 1, 1237), new Matrix(1, 0, 0, 1, 250, HORIZON - 50));
            //波
            waveMap = new WaveMap(40, 40);
            waveContainer = new Sprite();
            waveContainer.y = HORIZON;
            waveContainer.addChild(Painter.createColorRect(DISPLAY.width, DISPLAY.height, WAVE_COLOR, 1));
            for (i = 0; i < WAVE_LAYER; i++) {
                var w:Sprite = waveContainer.addChild(new Sprite()) as Sprite;
                var paint:ColorTransform = new ColorTransform();
                paint.color = WAVE_COLOR;
                var per:Number = (WAVE_LAYER - i) / (WAVE_LAYER + 1);
                paint.redMultiplier = 1 - per;
                paint.greenMultiplier = 1 - per;
                paint.blueMultiplier = 1 - per;
                paint.redOffset *= per;
                paint.blueOffset *= per;
                paint.greenOffset *= per;
                w.transform.colorTransform = paint;
                waveList.push(w);
            }
            waveContainer.blendMode = BlendMode.LAYER;
            w.blendMode = BlendMode.ERASE;
            //水中
            sea = new Sprite();
            floor = new Sprite();
            lightWave = new Sprite();
            floor.addChild(Painter.createColorRect(FLOOR_SIZE.width, FLOOR_SIZE.height, FLOOR_COLOR));
            floor.addChild(lightWave);
            floor.addChild(Painter.createGradientRect(FLOOR_SIZE.width, FLOOR_SIZE.height, true, [FOG_COLOR, FOG_COLOR], [1, 0], [0.2, 1], -90));
            //コースティクス生成
            for (i = 0; i < CAUSTICS_NUM; i++) {
                var rad:Number = i / CAUSTICS_NUM * Math.PI * 2;
                var c:Caustics = new Caustics(FLOOR_SIZE.width, FLOOR_SIZE.height, rad);
                c.speed = CAUSTICS_SPEED;
                c.map = createCaustics(CAUSTICS_SIZE.width, CAUSTICS_SIZE.height, i + CAUSTICS_SEED);
                c.tick();
                causticses.push(c);
                lightWave.addChild(c.sprite);
            }
            lightWave.blendMode = BlendMode.ADD;
            floor.rotationX = 90;
            floor.y = 365;
            floor.x = (DISPLAY.width - FLOOR_SIZE.width) / 2;
            floor.z = -170;
            sea.addChild(Painter.createColorRect(DISPLAY.width, DISPLAY.height, FOG_COLOR)).y = HORIZON;
            sea.addChild(floor);
            sea.mask = sea.addChild(Painter.createColorRect(DISPLAY.width, DISPLAY.height, 0));
            //色々配置
            addChild(bg);
            addChild(new Bitmap(skyBmp));
            addChild(sea);
            addChild(new RandomRay(20, HORIZON, 150, 100, 1));
            addChild(new RandomRay(100, HORIZON, 150, 200, 2));
            addChild(new RandomRay(200, HORIZON, 200, 150, 3));
            addChild(waveContainer);
            //波用テクスチャ
            waveTexture = new BitmapData(DISPLAY.width, 165, false);
            var scale:Matrix = new Matrix();
            scale.scale(1, 0.2);
            waveTexture.draw(floor, scale);
            //処理開始
            addEventListener(Event.ENTER_FRAME, onEnterFrame);
        }
        /**
         * 毎フレーム処理
         */
        private function onEnterFrame(e:Event):void {
            for each(var c:Caustics in causticses) c.tick();
            waveMap.moveNoise();
            for (var n:int = 0; n < WAVE_LAYER; n++) {
                var yper:Number = (n + 1) / (WAVE_LAYER + 1);
                waveList[n].y = n * 3 - 20;
                var g:Graphics = waveList[n].graphics;
                g.clear();
                var matrix:Matrix = new Matrix(1, 0, 0, 1, 0, yper * -30);
                matrix.scale(yper * 0.2 + 1, yper + 0.3);
                g.beginBitmapFill(waveTexture, matrix);
                var cmds:Vector.<int> = Vector.<int>([1, 2]);
                var lines:Vector.<Number> = Vector.<Number>([DISPLAY.width, DISPLAY.height, 0, DISPLAY.height]);
                for (var i:int = 0; i <= WAVE_SPLIT; i++) {
                    cmds.push(2);
                    var xper:Number = i / WAVE_SPLIT;
                    lines.push(xper * DISPLAY.width, waveMap.getHeight(xper, yper) * 100 * (yper / 2 + 0.5));
                }
                g.drawPath(cmds, lines);
            }
        }
        /**
         * コースティクス用テクスチャ生成
         */
        private function createCaustics(width:Number, height:Number, seed:int):BitmapData {
            var bmp:BitmapData = new BitmapData(width, height, true);
            bmp.perlinNoise(width/3, height/3, 1, seed, true, false, 7, true);
            var bright:uint = 0xFF * CAUSTICS_STRENGTH;
            bmp.threshold(bmp, bmp.rect, new Point(), ">", 0xFF << 24 | bright << 16 | 0xFFFF, 0x00000000);
            var ct:ColorTransform = new ColorTransform();
            ct.color = CAUSTICS_COLOR;
            ct.alphaMultiplier = CAUSTICS_ALPHA;
            bmp.colorTransform(bmp.rect, ct);
            var sp:Sprite = new Sprite();
            sp.graphics.beginBitmapFill(bmp);
            var padding:int = Math.max(CAUSTICS_BLUR_X, CAUSTICS_BLUR_Y) + 5;
            sp.graphics.drawRect(0, 0, width + padding * 2, height + padding * 2);
            sp.filters = [new BlurFilter(CAUSTICS_BLUR_X, CAUSTICS_BLUR_Y, 3)];
            var result:BitmapData = new BitmapData(width, height, true, 0);
            result.draw(sp, new Matrix(1, 0, 0, 1, -padding, -padding));
            return result;
        }
    }
}
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.BitmapDataChannel;
import flash.display.BlendMode;
import flash.display.Sprite;
import flash.events.Event;
import flash.filters.BlurFilter;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
/**
 * 波用ノイズマップ
 */
class WaveMap {
    private var _offset:Array;
    private var _map:BitmapData;
    private var _size:Rectangle;
    public function get map():BitmapData { return _map; }
    public function WaveMap(width:Number, height:Number) {
        _size = new Rectangle(0, 0, width, height);
        _offset = [new Point(), new Point()];
        _map = new BitmapData(width, height, false, 0xFF000000);
        moveNoise();
    }
    public function moveNoise():void {
        _offset[0].x += 0.5;
        _offset[0].y += 0.3;
        _map.perlinNoise(_map.width / 2, _map.height / 2, 2, 1234, true, true, 1, false, _offset);
    }
    public function getHeight(x:Number, y:Number):Number {
        var pix:uint = _map.getPixel(x * (map.width - 1), y * (map.height - 1));
        var red:Number = pix >> 16 & 0xFF;
        return red / 0xFF;
    }
}
/**
 * 光の筋
 */
class RandomRay extends Bitmap {
    private var _bmp:BitmapData;
    private var _noise:BitmapData;
    private var _offset:int = 0;
    private var _ct:ColorTransform;
    public function RandomRay(x:Number, y:Number, width:Number, height:Number, seed:int = 1234) {
        _bmp = new BitmapData(width, 1, true, 0xFF000000);
        super(_bmp);
        this.x = x;
        this.y = y;
        _ct = new ColorTransform();
        _ct.color = 0xFFFFFF;
        _noise = new BitmapData(_bmp.width, 400, true, 0xFF000000);
        _noise.perlinNoise(30, 100, 5, seed, true, true, 1);
        _noise.threshold(_noise, _noise.rect, new Point(), "<", 0xFF990000, 0xFF000000);
        _noise.fillRect(new Rectangle(0, 0, 5, _noise.height), 0xFF000000);
        _noise.fillRect(new Rectangle(_noise.width - 5, 0, 5, _noise.height), 0xFF000000);
        _noise.applyFilter(_noise, _noise.rect, new Point(), new BlurFilter(5, 1, 3));
        blendMode = BlendMode.OVERLAY;
        this.height = height;
        addEventListener(Event.ENTER_FRAME, onEnterFrame);
        alpha = 0.2;
    }
    public function onEnterFrame(e:Event):void {
        _offset = (_offset + 1) % _noise.height;
        _bmp.fillRect(_bmp.rect, 0xFFFFFFFF);
        _bmp.copyChannel(_noise, new Rectangle(0,_offset, _noise.width, 1), new Point(0, 0), BitmapDataChannel.RED, BitmapDataChannel.ALPHA);
    }
}
/**
 * 水のコースティクス
 */
class Caustics {
    public var sprite:Sprite;
    public var map:BitmapData;
    public var size:Rectangle;
    public var speed:Number = 1;
    private var _slide:Number = 0;
    private var _matrix:Matrix = new Matrix();
    private var _angle:Number = 0;
    public function Caustics(width:Number = 100, height:Number = 100, angle:Number = 0) {
        _angle = angle;
        size = new Rectangle(0, 0, width, height);
        sprite = new Sprite();
        _matrix.rotate(_angle);
    }
    public function tick():void {
        _slide = (_slide + speed) % map.width;
        _matrix.tx = Math.cos(_angle) * _slide;
        _matrix.ty = Math.sin(_angle) * _slide;
        sprite.graphics.clear();
        sprite.graphics.beginBitmapFill(map, _matrix, true, false);
        sprite.graphics.drawRect(0, 0, size.width, size.height);
        sprite.graphics.endFill();
    }
}
class Painter {
    /**
     * 雲画像生成
     */
    static public function createCloud(width:Number, height:Number, scale:Number = 1, color:uint = 0xFFFFFF, alpha:Number = 1, seed:int = 1234):BitmapData {
        var bmp:BitmapData = new BitmapData(width, height, true, 0xFF << 24 | color);
        var alph:BitmapData = bmp.clone();
        alph.perlinNoise(width * scale, height * scale, 5, seed, true, true, BitmapDataChannel.RED, true);
        alph.draw(createGradientRect(width, height, false, [0x000000, 0x000000], [1 - alpha, 1], [0, 1]));
        bmp.copyChannel(alph, alph.rect, new Point(), BitmapDataChannel.RED, BitmapDataChannel.ALPHA);
        alph.dispose();
        return bmp;
    }
    /**
     * 一色塗りスプライト生成
     */
    static public function createColorRect(width:Number, height:Number, color:uint = 0x000000, alpha:Number = 1):Sprite {
        var sp:Sprite = new Sprite();
        sp.graphics.beginFill(color, alpha);
        sp.graphics.drawRect(0, 0, width, height);
        sp.graphics.endFill();
        return sp;
    }
    /**
     * グラデーションスプライト生成
     */
    static public function createGradientRect(width:Number, height:Number, isLinear:Boolean, colors:Array, alphas:Array, ratios:Array = null, r:Number = 0):Sprite {
        var i:int, ratioList:Array = new Array();
        if (ratios == null) {
            for (i = 0; i < colors.length; i++) ratioList.push(int(255 * i / (colors.length - 1)));
        } else {
            for (i = 0; i < ratios.length; i++) ratioList[i] = Math.round(ratios[i] * 255);
        }
        var sp:Sprite = new Sprite();
        var mtx:Matrix = new Matrix();
        mtx.createGradientBox(width, height, Math.PI / 180 * r, 0, 0);
        if (colors.length == 1 && alphas.length == 1) sp.graphics.beginFill(colors[0], alphas[0]);
        else {
            var type:String = (isLinear)? "linear" : "radial";
            sp.graphics.beginGradientFill(type, colors, alphas, ratioList, mtx);
        }
        sp.graphics.drawRect(0, 0, width, height);
        sp.graphics.endFill();
        return sp;
    }
}
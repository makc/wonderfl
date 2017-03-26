package {
    import flash.display.Sprite;
    import flash.display.Graphics;
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.BlendMode;
    import flash.events.Event;
    import flash.media.Camera;
    import flash.media.Video;
    import flash.geom.Point;
    import flash.geom.ColorTransform;
    import flash.geom.Matrix;
    import flash.geom.Rectangle;
    import flash.filters.BlurFilter;

    [SWF(frameRate=30)]
    public class CameraSample03 extends Sprite { 
        private var _camera:Camera;
        private var _video:Video;

        private var _canvasBitmapData:BitmapData;
        private var _eraseBitmapData:BitmapData;
        private var _nowBitmapData:BitmapData;
        private var _prevBitmapData:BitmapData;
        private var _zero:Point;
        private var _mirrorMatrix:Matrix;
        private var _blur:BlurFilter;
        private var _fillRect:Rectangle;
        private const VIDEO_WIDTH:Number = 240;
        private const VIDEO_HEIGHT:Number = 240;

        public function CameraSample03() {
            _camera = Camera.getCamera();
            if (_camera == null) {
                return;
            }
            
            _camera.setMode(VIDEO_WIDTH, VIDEO_HEIGHT, 15);

            _video = new Video(_camera.width, _camera.height);
            _video.attachCamera(_camera);
            
            _canvasBitmapData = new BitmapData(_camera.width, _camera.height, false, 0x000000);
            _eraseBitmapData = new BitmapData(_camera.width, _camera.height, true, 0x00000000);
            _nowBitmapData = new BitmapData(_camera.width, _camera.height, true, 0x00000000);
            _prevBitmapData = new BitmapData(_camera.width, _camera.height, false, 0x000000);

            _blur = new BlurFilter(10,10,2);
            _fillRect = new Rectangle(0, _eraseBitmapData.height - 5, _eraseBitmapData.width, 5);

            var scale:Number = 465/VIDEO_WIDTH;

            var canvas:Bitmap = addChild(new Bitmap(_canvasBitmapData)) as Bitmap;
            canvas.scaleX = canvas.scaleY = scale;

            var yugeMask:Bitmap = addChild(new Yuge(_canvasBitmapData.width, 
                                                    _canvasBitmapData.height)) as Bitmap;
            yugeMask.alpha = 1.4;
            yugeMask.scaleX = yugeMask.scaleY = scale;

            var yuge:Sprite = new Sprite();
            yuge.scaleX = yuge.scaleY = scale;
            var g:Graphics = yuge.graphics;
            g.beginFill(0xFFFFFF);
            g.drawRect(0,0,yugeMask.width, yugeMask.height);
            addChild(yuge);
            yuge.cacheAsBitmap = true; // alphaつきのmaskを有効にできる
            yuge.mask = yugeMask;

            // 湯気をeraseBitmapで逆にマスク
            var erase:Bitmap = yuge.addChild(new Bitmap(_eraseBitmapData)) as Bitmap;
            yuge.blendMode = "layer";
            erase.blendMode = "erase";
            
            // マスクを見えるように(debug)
            /*
            canvas.visible = false;
            yuge.visible = false;
            var debugErase:Bitmap = addChild(new Bitmap(_eraseBitmapData)) as Bitmap;
            debugErase.scaleX = debugErase.scaleY= scale;
            addChild(debugErase);
            */ 

            addEventListener(Event.ENTER_FRAME, enterFrameHandler);

            _zero = new Point();

            _mirrorMatrix = new Matrix();
            _mirrorMatrix.scale(-1, 1); // 反転                                                                                        
            _mirrorMatrix.translate(VIDEO_WIDTH, 0); // 元の位置に戻す

        }

        private function enterFrameHandler(e:Event):void {
            _canvasBitmapData.lock();
            _nowBitmapData.lock();
            _prevBitmapData.lock();
            _eraseBitmapData.lock();
            _canvasBitmapData.draw(_video, _mirrorMatrix);
            _nowBitmapData.copyPixels(_canvasBitmapData, _canvasBitmapData.rect, _zero);
            // 前回との差分を取る
            _nowBitmapData.draw(_prevBitmapData, null, null, BlendMode.DIFFERENCE);
            // 前回と違う部分を白く
            _nowBitmapData.threshold(_nowBitmapData, _nowBitmapData.rect, _zero, ">", 0xFF111111, 0xFFFFFFFF);
            // 前回と同じところは透明に
            _nowBitmapData.threshold(_nowBitmapData, _nowBitmapData.rect, _zero, "<", 0xFF111111, 0x00000000);
            _prevBitmapData.copyPixels(_canvasBitmapData, _canvasBitmapData.rect, _zero);
            _eraseBitmapData.draw(_nowBitmapData, null, new ColorTransform(1,1,1,0.3), BlendMode.ADD);
            // blurで塗りつぶされてしまわないように常に透明部分が存在するように
            _eraseBitmapData.fillRect(_fillRect, 0x00FFFFFF); 
            _eraseBitmapData.applyFilter(_eraseBitmapData, _eraseBitmapData.rect, _zero, _blur);
            _canvasBitmapData.unlock();
            _nowBitmapData.unlock();
            _prevBitmapData.unlock();
            _eraseBitmapData.unlock();
        }
    }
}

import flash.display.Sprite;
import flash.display.BitmapData;
import flash.display.Bitmap;
import flash.display.BitmapDataChannel;
import flash.events.Event;
import flash.geom.Point;
import flash.geom.ColorTransform;

class Yuge extends Bitmap {
    private var _canvas:BitmapData;
    private var _tmpBitmapData:BitmapData;
    private var _baseX:Number = 100;
    private var _baseY:Number = 100;
    private var _octaves:int = 3;
    private var _randomSeed:int;
    private var _offsets:Array;
    private var _speed:Array;

    private var _canvasWidth:Number;
    private var _canvasHeight:Number;

    public function Yuge(w:Number, h:Number) {
        _canvasWidth = w;
        _canvasHeight = h;
        _canvas = new BitmapData(w,h, true, 0x00FFFFFF);
        _tmpBitmapData = new BitmapData(w, h, true, 0x00FFFFFF);
        super(_canvas);

        _randomSeed = Math.random()*1000;

        _offsets = [];
        _speed = [];

        for (var i:int = 0; i<_octaves; i++) {
            _offsets[i] = new Point(Math.random()*_canvasWidth, Math.random()*_canvasHeight);
            _speed[i] = new Point(0, Math.random()*1 + 1);
        }

        addEventListener(Event.ENTER_FRAME, enterFrameHandler);
        cacheAsBitmap = true;
    }

    private function enterFrameHandler(e:Event):void {
        for (var i:int = 0; i < _octaves; i++) {
            _offsets[i].x += _speed[i].x;
            _offsets[i].y += _speed[i].y;
        }

        _canvas.perlinNoise(_baseX, _baseY, _octaves, _randomSeed, false, true, BitmapDataChannel.ALPHA, true, _offsets);
    }
}


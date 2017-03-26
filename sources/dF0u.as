// forked from Event's Button
package {
    import flash.display.*;
    import flash.media.Camera;
    import flash.media.Video;
    import flash.utils.Timer;
    import flash.events.*;
    import flash.geom.Point;
    import flash.net.URLRequest;
    import flash.system.LoaderContext;
    import org.papervision3d.view.BasicView;
    import org.papervision3d.objects.primitives.*;
    import org.papervision3d.objects.parsers.DAE;
    import org.papervision3d.objects.DisplayObject3D;
    import org.papervision3d.materials.*;
    import org.papervision3d.materials.utils.*;
    import org.papervision3d.view.layer.util.*;
    import org.papervision3d.events.FileLoadEvent;
    import org.papervision3d.events.InteractiveScene3DEvent;
    import org.papervision3d.core.geom.renderables.Vertex3D;
    import org.libspark.betweenas3.BetweenAS3;
    import org.libspark.betweenas3.tweens.ITween;
    import org.libspark.betweenas3.easing.*;
    import org.libspark.betweenas3.events.TweenEvent;
    import net.hires.debug.Stats;
    
    [SWF(width="465", height="465", backgroundColor="#000000", frameRate="30")] 
    
    public class Main extends BasicView {
        private const MOTION_FPS:int = 5;
        private var _messageLoader:Loader;
        private var _famiBmd:BitmapData;
        private var _motDet:MotionDetection;
        private var _famScr:FamiScreen;
        private var _faceRatePt:Point = new Point();    //0~1
        private var _tarX:Number = 0;
        private var _tarY:Number = 0;
        private var _cameraW:Number;
        private var _cameraH:Number;
        //
        private var _fami:DAE;
        private var _floor:DAE;
        private var _hitCube:Cube;
        private var _cursor:Plane;
        private var _targetObj:DisplayObject3D;
        private var _loadFlg:Boolean;
        //
        private var _cursorIt:ITween;
        public var _cameraRange:Number = 1;    //0~1
        public var _cameraBaseY:Number = 10;
        private var _messageBm:Bitmap;
        private var _messageTimer:Timer;
        private var _zoomIt:ITween;
        
        public function Main() {
            super(465, 465, true, true, "Target");
            stage.align = "TL";
            stage.scaleMode = "noScale";
            
            //FlashPlayer設定のダイアログボックスが表示されている状態でキャプチャが走ると下のエラーが表示されるっぽい。
            //ので10秒待つ。
            //「Error: SecurityError: Error #2121: セキュリティサンドボックス侵害」
            Wonderfl.capture_delay(10);
            
           var url:String = "http://buccchi.jp/wonderfl/201009/texture/message.gif";
            _messageLoader = new Loader();
            _messageLoader.load(new URLRequest(url), new LoaderContext(true));
            _messageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadComplete);
        }
            
        private function loadComplete(e:Event):void {
            e.target.removeEventListener(Event.COMPLETE, loadComplete);
            var messageBmd:BitmapData = new BitmapData(_messageLoader.width, _messageLoader.height);
            messageBmd.draw( _messageLoader );
            _messageBm = new Bitmap( messageBmd );
            _messageBm.alpha = .8;
            
            _messageTimer = new Timer(500, 1);
            
            var myCamera:Camera = Camera.getCamera();
            if (myCamera == null) return;
            myCamera.setMode(256, 256, MOTION_FPS);
            _cameraW = myCamera.width;
            _cameraH = myCamera.height;
            var video:Video = new Video(_cameraW, _cameraH);
            video.attachCamera(myCamera);
            
            _motDet = new MotionDetection( video );
            _motDet.addEventListener(MotionDetectionEvent.MOVE, moveFaceHandler);
            
            _famiBmd = new BitmapData(256, 240, false, 0x000000);
            _famScr = new FamiScreen( video, _famiBmd, messageBmd.clone() );
            
            var timer:Timer = new Timer(1000/MOTION_FPS);
            timer.addEventListener(TimerEvent.TIMER, update);
            timer.start();
            
            viewport.containerSprite.sortMode = ViewportLayerSortMode.INDEX_SORT;
            
            //テレビ、ファミコン生成
            var dispMaterial:BitmapMaterial = new BitmapMaterial( _famiBmd );
            dispMaterial.smooth = true;
            _fami = new DAE();
            _fami.load( "http://buccchi.jp/wonderfl/201009/tv.dae", new MaterialsList({"tv_dispMA":dispMaterial}) );
            _fami.scale = 25;
            _fami.addEventListener(FileLoadEvent.LOAD_COMPLETE, loadDaeComplete);
            scene.addChild(_fami);
            
            //背景生成
            _floor = new DAE();
            _floor.load("http://buccchi.jp/wonderfl/201009/floor.dae");
            _floor.scale = 25;
            _floor.addEventListener(FileLoadEvent.LOAD_COMPLETE, loadDaeComplete);
            scene.addChild(_floor);
            
            //クリック用透明Cube生成
            var cubeMaterial:BitmapMaterial = new BitmapMaterial( new BitmapData(1, 1, true, 0x00FF0000) );
            cubeMaterial.interactive = true;
            _hitCube = new Cube( new MaterialsList( {all:cubeMaterial}), 70, 70, 15 );
            _hitCube.x = 1.421 * 25;
            _hitCube.y = 1.566 * 25;
            _hitCube.z = -25.370 * 25;
            scene.addChild(_hitCube);
            _hitCube.addEventListener(InteractiveScene3DEvent.OBJECT_OVER, cubeOverHandler);
            _hitCube.addEventListener(InteractiveScene3DEvent.OBJECT_PRESS, cubePressHandler);
            
            //カーソルPlane生成
            var cursorMaterial:BitmapFileMaterial = new BitmapFileMaterial( "http://buccchi.jp/wonderfl/201009/texture/cursor.png" );
            cursorMaterial.doubleSided = true;
            cursorMaterial.interactive = true;
            _cursor = new Plane(cursorMaterial, 30, 45);
            var max:int = _cursor.geometry.vertices.length;
            for(var i:int=0; i<max; i++){
                var vertex:Vertex3D = _cursor.geometry.vertices[i];
                vertex.x += 7;
            }
            _cursor.x = _hitCube.x;
            _cursor.y = 60;
            _cursor.z = _hitCube.z;
            scene.addChild(_cursor);
            _cursor.addEventListener(InteractiveScene3DEvent.OBJECT_PRESS, cubePressHandler);
            //
            _targetObj = new DisplayObject3D();
            camera.target = _targetObj;
            camera.z = -1050;
            
            //カーソルアニメーション
            var curIt:ITween = BetweenAS3.bezier(_cursor, { y:60 }, null, { y:[110] }, 1, Linear.linear);
            curIt.stopOnComplete = false;
            curIt.play();
            
            //addChild( new Stats() );
            stage.addEventListener(Event.RESIZE, resizeHandler);
            resizeHandler(null);
        }
        
        //_hitCubeに重なった場合のみマウスカーソルを変更
        //カメラ移動でマウスオーバー、マウスアウトした場合は拾えない？
        private function cubeOverHandler(e:InteractiveScene3DEvent):void {
            if(_cursorIt != null) _cursorIt.stop();
            _cursorIt = BetweenAS3.tween(_cursor, { rotationY:360*4 }, { rotationY:0 }, 1.5, Quint.easeOut);
            _cursorIt.play();
        }
        
        private function cubePressHandler(e:InteractiveScene3DEvent):void {
            _hitCube.removeEventListener(InteractiveScene3DEvent.OBJECT_OVER, cubeOverHandler);
            _hitCube.removeEventListener(InteractiveScene3DEvent.OBJECT_PRESS, cubePressHandler);
            _cursor.removeEventListener(InteractiveScene3DEvent.OBJECT_PRESS, cubePressHandler);
            _famScr.isMessage = true;
            //カメラズームイン
            if(_zoomIt != null) _zoomIt.stop();
            _zoomIt = BetweenAS3.parallel(
                                BetweenAS3.tween(camera, { z:-500 }, null, 2, Quint.easeInOut),
                                BetweenAS3.tween(_targetObj, { y:10*25, z:7*25 }, null, 2, Quint.easeInOut),
                                BetweenAS3.tween(this, { _cameraRange:.2, _cameraBaseY:350 }, null, 2, Quint.easeInOut)
                            );
            _zoomIt.play();
            _messageTimer.addEventListener(TimerEvent.TIMER_COMPLETE, addMessage);
            _messageTimer.start();
        }
        
        private function addMessage(e:TimerEvent):void {
            _messageTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, addMessage);
            addChild(_messageBm);
            stage.addEventListener(MouseEvent.CLICK, clickHandler);
        }
        
        private function clickHandler(e:MouseEvent):void {
            stage.removeEventListener(MouseEvent.CLICK, clickHandler);
            _famScr.isMessage = false;
            //カメラズームアウト
            if(_zoomIt != null) _zoomIt.stop();
            _zoomIt = BetweenAS3.parallel(
                                BetweenAS3.tween(camera, { z:-1050 }, null, 2, Quint.easeInOut),
                                BetweenAS3.tween(_targetObj, { y:0, z:0 }, null, 2, Quint.easeInOut),
                                BetweenAS3.tween(this, { _cameraRange:1, _cameraBaseY:10 }, null, 2, Quint.easeInOut)
                            );
            _zoomIt.play();
            _messageTimer.addEventListener(TimerEvent.TIMER_COMPLETE, removeMessage);
            _messageTimer.start();
        }
        
        private function removeMessage(e:TimerEvent):void {
            _messageTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, removeMessage);
            removeChild(_messageBm);
            _hitCube.addEventListener(InteractiveScene3DEvent.OBJECT_OVER, cubeOverHandler);
            _hitCube.addEventListener(InteractiveScene3DEvent.OBJECT_PRESS, cubePressHandler);
            _cursor.addEventListener(InteractiveScene3DEvent.OBJECT_PRESS, cubePressHandler);
        }
        
        private function loadDaeComplete(e:FileLoadEvent):void {
            if(_loadFlg){
                viewport.getChildLayer(_fami).layerIndex = 1;
                viewport.getChildLayer(_floor).layerIndex = 0;
                viewport.getChildLayer(_hitCube).layerIndex = 3;
                viewport.getChildLayer(_cursor).layerIndex = 2;
                startRendering();
            }
            _loadFlg = true;
        }
        
        private function update(e:TimerEvent):void {
            _motDet.update();
            _famScr.update();
        }
        
        private function moveFaceHandler(e:MotionDetectionEvent):void {
            _faceRatePt.x = e.rateX;
            _faceRatePt.y = e.rateY;
        }
        
        private function resizeHandler(e:Event):void {
            _messageBm.scaleX = -stage.stageWidth/465*2;
            _messageBm.scaleY = stage.stageHeight/465*2;
            _messageBm.x = stage.stageWidth/2 + _messageBm.width/2;
            _messageBm.y = stage.stageHeight - _messageBm.height - 40;
        }
        
        //カメラ位置変更
        override protected function onRenderTick(event:Event = null):void {
            var rateX:Number = 1-_faceRatePt.x;
            var rateY:Number = 1-_faceRatePt.y;
            _tarX += (rateX-_tarX)*.05;
            _tarY += (rateY-_tarY)*.05;
            camera.x = (_tarX*1200-600) * _cameraRange;
            camera.y = (_tarY*800) * _cameraRange + _cameraBaseY;
            //
            super.onRenderTick(event);
        }
    }
}


import flash.display.*;
import flash.events.Event;
import flash.geom.*;
import flash.filters.*;
import flash.media.Video;
    
class MotionDetection extends Sprite {
    private var _video:Video;
    private var _nowBmd:BitmapData;
    private var _prevBmd:BitmapData;
    private var _rec:Rectangle;
    private var _pt:Point;
    private var noiseReduction:ConvolutionFilter;
    private var grayScale:ColorMatrixFilter;
    private var skin:ColorMatrixFilter;
    private var _objects:Vector.<MotionObject> = new Vector.<MotionObject>();
    
    public function MotionDetection( myVideo:Video ) {
        _video = myVideo;

        _nowBmd = new BitmapData(_video.width, _video.height, false);
        _prevBmd = new BitmapData(_video.width, _video.height, false);
        _rec = new Rectangle(0, 0, _video.width, _video.height);
        _pt = new Point();
        
        noiseReduction = new ConvolutionFilter(3, 3);
        noiseReduction.bias = -(0x1000 + 0x100 * 6);
        noiseReduction.matrix = [
            1,  1, 1,
            1, 16, 1,
            1,  1, 1
        ];
        grayScale = new ColorMatrixFilter([
            0.3, 0.59, 0.11, 0, 0,
            0.3, 0.59, 0.11, 0, 0,
            0.3, 0.59, 0.11, 0, 0,
            0, 0, 0, 1, 0
        ]);
        skin = new ColorMatrixFilter([
            0, 0, 0, 0, 0,
            -0.43, -0.85, 1.28, 0, 198.4,
            1.28, -1.07, -0.21, 0, 108.8,
            0, 0, 0, 1, 0
        ]);
        
        
    }

    public function update():void {
        var rect:Rectangle;
        var rects:Vector.<Rectangle> = getRects();
        var candidates:Vector.<MotionObject> = new Vector.<MotionObject>();
        var intersects:Vector.<MotionObject>;
        var object:MotionObject;
        var n:int = _objects.length;
        for (var i:int = 0, length:int = rects.length; i < length; i++) {
            rect = rects[i];
            if (rect.width * rect.height > _video.width * _video.height * 0.7) continue;
            
            intersects = new Vector.<MotionObject>();
            for (var j:int = 0; j < n; j++) {
                object = _objects[j];
                if (object.rect.intersects(rect)) intersects.push(object);
            }
            
            var len:int = intersects.length;
            switch (len) {
                case 0:
                    if (rect.width * rect.height > _video.width * _video.height * 0.02) {
                        candidates.push(new MotionObject(rect));
                    }
                    break;
                case 1:
                    intersects[0].move(rect);
                    break;
                default:
                    var result:MotionObject;
                    var intersection:Rectangle;
                    var size:int;
                    var max:int = 0;
                    while (len--) {
                        object = intersects[len];
                        intersection = rect.intersection(object.rect);
                        size = intersection.width * intersection.height;
                        if (size > max) {
                            result = object;
                            max = size;
                        }
                    }
                    result.move(rect);
            }
        }

        while (n--) {
            object = _objects[n];
            object.update();
            if (object.dead) _objects.splice(n, 1);
        }
        
        n = candidates.length;
        while (n--) {
            _objects.push(candidates[n]);
        }
        
        draw();
    }

    private function getRects():Vector.<Rectangle> {
        _nowBmd.draw(_video);
        var copy:BitmapData = _nowBmd.clone();
        _nowBmd.draw(_prevBmd, new Matrix(), new ColorTransform(), BlendMode.DIFFERENCE);
        _prevBmd = copy.clone();
        copy.applyFilter(_nowBmd, _rec, _pt, skin);
        _nowBmd.applyFilter(_nowBmd, _rec, _pt, grayScale);
        _nowBmd.threshold(_nowBmd, _rec, _pt, ">", 0xff111111, 0xffffffff);
        _nowBmd.threshold(copy, _rec, _pt, "!=", 0x008080, 0xff000000, 0x00c0c0);
        _nowBmd.applyFilter(_nowBmd, _rec, _pt, noiseReduction);

        var rects:Vector.<Rectangle> = new Vector.<Rectangle>();
        var rect:Rectangle;
        var bound:Rectangle = _nowBmd.getColorBoundsRect(0xffffff, 0xffffff);
        var line:BitmapData = new BitmapData(_rec.width, 1, false);
        var lineBound:Rectangle = new Rectangle(0, 0, _rec.width, 1);
        while (!bound.isEmpty()) {
            lineBound.y = bound.y;
            line.copyPixels(_nowBmd, lineBound, _pt);
            bound = line.getColorBoundsRect(0xffffff, 0xffffff);
            _nowBmd.floodFill(bound.x, lineBound.y, 0xff00ff);
            rect = _nowBmd.getColorBoundsRect(0xffffff, 0xff00ff);
            rect.inflate(4, 4);
            _nowBmd.fillRect(rect, 0x0000ff);
            rects.push(rect);
            bound = _nowBmd.getColorBoundsRect(0xffffff, 0xffffff);
        }

        var m:int, n:int = rects.length;
        var rect1:Rectangle, rect2:Rectangle;
        while (n-- > 1) {
            rect1 = rects[n];
            m = n;
            while (m--) {
                rect2 = rects[m];
                if (!rect1.intersects(rect2)) continue;
                rects[m] = rect1.union(rect2);
                rects.splice(n, 1);
                break;
            }
        }

        return rects;
    }

    // 検出矩形を描画
    private function draw():void {
        var pt:Point = new Point();
        var rate:Number = 0;
        var rect:Rectangle;
        for (var i:int = 0, length:int = _objects.length; i < length; i++) {
            if (!_objects[i].time) continue;
            rect = _objects[i].rect;
            var area:Number = rect.width * rect.height / 100;
            pt.x += (rect.x+rect.width/2) * area;
            pt.y += (rect.y+rect.height/2) * area;
            rate += area;
        }
        
        if(rate != 0){
            dispatchEvent( new MotionDetectionEvent(MotionDetectionEvent.MOVE, pt.x/rate/_video.width, pt.y/rate/_video.height) );
        }
    }
}


import flash.geom.Rectangle;

class MotionObject {
    public var time:int = 0;
    public var dead:Boolean = false;
    public var rect:Rectangle;
    private var rects:Vector.<Rectangle> = new Vector.<Rectangle>();
    private var count:int = 5;

    function MotionObject(rect:Rectangle) {
        this.rect = rect;
    }

    public function move(rect:Rectangle):void {
        rects.push(rect);
    }

    public function update():void {
        time++;
        var len:int = rects.length;
        switch (len) {
            case 0:
                count--;
                if (!count) dead = true;
                break;
            case 1:
                count = 5;
                rect = rects[0];
                break;
            default:
                count = 5;
                rect = rects[0];
                while (--len) {
                    rect = rect.union(rects[len]);
                }
        }
        if (rect.width > 8) rect.inflate(-4, 0);
        if (rect.height > 8) rect.inflate(0, -4);
        rects = new Vector.<Rectangle>();
    }
}



import flash.events.Event;

class MotionDetectionEvent extends Event {
    public static const MOVE:String="motion_detection_move";
    public var rateX:Number;
    public var rateY:Number;
    
    function MotionDetectionEvent(type:String, myX:Number, myY:Number) {
        super(type);
        rateX = myX;
        rateY = myY;
    }
    public override function clone():Event {
        return new MotionDetectionEvent(type, rateX, rateY);
    }
    public override function toString():String {
        return formatToString("MotionDetectionEvent","type","bubbles","cancelable","eventPhase","rateX","rateY");
    }
}


import flash.display.*;
import flash.media.Video;
import flash.geom.Matrix;
import flash.geom.Point;

class FamiScreen {
    private var _video:Video;
    private var _bmd:BitmapData;
    private var _mt:Matrix;
    private var _rArray:Array = new Array();
    private var _gArray:Array = new Array();
    private var _bArray:Array = new Array();
    private var _messageBmd:BitmapData;
    private var _messageMt:Matrix;
    private var _isMessage:Boolean;
    private var _scale:Number;
    
    public function FamiScreen( video:Video, bmd:BitmapData, messageBmd:BitmapData ) {
        _scale = bmd.width/256;
        _video = video;
        _bmd = bmd;
        _messageBmd = messageBmd;
        _mt = new Matrix();
        _mt.scale(bmd.width/video.width, bmd.height/video.height);
        //減色処理用
        var v:uint = 2;
        for (var i:uint=0; i<256; i++){
            var val:uint = uint(i/(256/v))*255/(v-1);  
            _rArray[i] = val << 16;  
            _gArray[i] = val <<  8;  
            _bArray[i] = val;  
        }
        _messageMt = new Matrix();
        _messageMt.scale(_scale, _scale);
        _messageMt.translate(bmd.width/2-messageBmd.width/2*_scale, bmd.height-messageBmd.height*_scale-30*_scale);
    }
    
    public function set isMessage(flg:Boolean):void {
        _isMessage = flg;
    }
    
    public function update():void {
        _bmd.draw( _video, _mt );
        _bmd.paletteMap(_bmd, _bmd.rect, new Point(), _rArray, _gArray, _bArray);
        if(_isMessage){
            _bmd.draw( _messageBmd, _messageMt );
        }
    }
}

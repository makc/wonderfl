package {
    /**
     * @author Anatoly Zenkov
     * http://anatolyzenkov.com/
     */
     // CLICK TO REGENERATE
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.BlendMode;
    import flash.display.DisplayObject;
    import flash.display.Loader;
    import flash.display.LoaderInfo;
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.MouseEvent;
    import flash.geom.ColorTransform;
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.net.URLRequest;
    import flash.system.LoaderContext;

    [SWF(backgroundColor=0x000000,frameRate=41)]
    public class Pyramids extends Sprite {
        private var _bitmap : Bitmap;
        private var _pyramids : Array;
        static public const DOUBLE_PI : Number = 2 * Math.PI;
        static public const HALF_PI : Number = .5 * Math.PI;
        static public var OFFSET_X : Number;
        static public var OFFSET_Y : Number;
        private var _pyramidLayer : Shape;
        private var _gradient : BitmapData;
        private var _currentBitmap : BitmapData;
        private const REFLECTIONS : int = 4;
        private const MAX_PYRAMIDS : int = 6;
        private const SIDES : int = 7;

        public function Pyramids() {
            addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
        }

        private function addedToStageHandler(event : Event) : void {
            removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
            stage.align = StageAlign.TOP_LEFT;
            stage.scaleMode = StageScaleMode.NO_SCALE;
            
            addChild(_bitmap = new Bitmap());
            _gradient = new BitmapData(600, 600, false);
            _currentBitmap = _gradient;
            var rect : Rectangle = new Rectangle(0, 0, 600, 600 / 255);
            for (var i : int = 0;i < 255;i++) {
                rect.y = i / 255 * 600;
                _currentBitmap.fillRect(rect, i << 16 | i << 8 | i);
            }
            _bitmap.bitmapData = _currentBitmap.clone();
            alignBitmap();
            load("http://assets.anatolyzenkov.com/misc/pool.jpg");
            
            _pyramidLayer = new Shape();
            
            stage.addEventListener(MouseEvent.CLICK, addPyramids);
            addPyramids(null);
            addEventListener(Event.ENTER_FRAME, updatePyramids);
        }

        private function updatePyramids(event : Event) : void {
            _bitmap.bitmapData.copyPixels(_currentBitmap, _currentBitmap.rect, new Point());
            var rects : Array = [];
            var p : Pyramid;
            for each (p in _pyramids) {
                p.update((stage.stageWidth * .5 - mouseX) / stage.stageWidth * 2, (stage.stageHeight * .5 - mouseY) / stage.stageHeight * 2);
                rects[rects.length] = p.getBoundRect();
            }
            var m : Number;
            for (var i : int = 0;i < REFLECTIONS;i++) {
                m = 0.9 + .1 * i / REFLECTIONS;
                var j : int = 0;
                var colortrans : ColorTransform = new ColorTransform(m, m, m);
                for each (p in _pyramids) {
                    _pyramidLayer.graphics.clear();
                    p.draw(_pyramidLayer.graphics, _bitmap.bitmapData);
                    _bitmap.bitmapData.draw(_pyramidLayer, new Matrix(1, 0, 0, 1, -OFFSET_X, -OFFSET_Y), colortrans, BlendMode.NORMAL, rects[j]);
                    j++;
                }
            }
        }

        private function addPyramids(event : MouseEvent) : void {
            _pyramids = [];
            var r : Number;
            var p : Pyramid;
            for (var i : int = 0;i < 2 + (MAX_PYRAMIDS - 2) * Math.random();i++) {
                var points : Array = [];
                for (var j : Number = 0;j < DOUBLE_PI;j += DOUBLE_PI / (2 + (SIDES - 2) * Math.random())) {
                    r = 100 + Math.random() * 50;
                    points[points.length] = new Point(r * Math.cos(j), r * Math.sin(j));
                }
                p = new Pyramid(points);
                p.x = 50 + (stage.stageWidth - 100) * Math.random();
                p.y = 50 + (stage.stageHeight - 100) * Math.random();
                p.scale = .6 + .6 * Math.random();
                p.scale *= p.scale;
                _pyramids[_pyramids.length] = p;
            }
            _pyramids.sortOn("scale");
        }

        private function alignBitmap() : void {
            _bitmap.x = OFFSET_X = int((stage.stageWidth - _bitmap.width) * .5);
            _bitmap.y = OFFSET_Y = int((stage.stageHeight - _bitmap.height) * .5);
        }

        ///////////////////////////////////////////////////////////////////////////////
        // imageLoader stuff
        ///////////////////////////////////////////////////////////////////////////////
        private function load(url : String) : void {
            var imageLoader : Loader = new Loader();
            imageLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, imageLoader_ioErrorEventHandler);
            imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, imageLoader_compelteEventHandler);
            imageLoader.load(new URLRequest(url), new LoaderContext(true));
        }

        private function imageLoader_compelteEventHandler(event : Event) : void {
            var content : DisplayObject = (event.target as LoaderInfo).content;
            _currentBitmap = (content as Bitmap).bitmapData;
            _bitmap.bitmapData = _currentBitmap.clone();
            alignBitmap();
            clearLoader(event.target as LoaderInfo);
        }

        private function imageLoader_ioErrorEventHandler(event : IOErrorEvent) : void {
            clearLoader(event.target as LoaderInfo);
        }

        private function clearLoader(loaderInfo : LoaderInfo) : void {
            loaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, imageLoader_ioErrorEventHandler);
            loaderInfo.removeEventListener(Event.COMPLETE, imageLoader_compelteEventHandler);
        }
        ///////////////////////////////////////////////////////////////////////////////
    }
}

import flash.display.BitmapData;
import flash.display.Graphics;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;

class Pyramid {
    private var _points : Array;
    private var _centralPoint : Point;
    private var _matrix : Matrix;
    private var _targetAngle : Number;
    public var scale : Number;
    public var angle : Number;
    public var x : Number;
    public var y : Number;
    private var _easyAngle : Number;
    private var _transformedPoints : Array;
    private var _targetMouseX : Number;
    private var _targetMouseY : Number;

    public function Pyramid(points : Array) {
        _centralPoint = new Point();
        _points = points;
        _matrix = new Matrix();
        _targetAngle = Pyramids.DOUBLE_PI * Math.random();
        _easyAngle = Pyramids.DOUBLE_PI * Math.random();
        _targetMouseX = 0;
        _targetMouseY = 0;
        scale = 1;
        angle = Pyramids.DOUBLE_PI * Math.random();
        x = 0;
        y = 0;
    }

    public function draw(graphics : Graphics, bitmapData : BitmapData) : void {
        _transformedPoints = [];
        for each (var p : Point in _points) {
            _transformedPoints[_transformedPoints.length] = _matrix.transformPoint(p);
        }
        var cp : Point = _matrix.transformPoint(_centralPoint);
        cp.x -= 50 * _targetMouseX * scale * scale;
        cp.y -= 50 * _targetMouseY * scale * scale;
        p = new Point();
        var p0 : Point = _transformedPoints[0];
        var p1 : Point;
        var sp : Point = new Point();
        var mtrx : Matrix = new Matrix();
        for (var i : int = 1;i <= _transformedPoints.length;i++) {
            p1 = _transformedPoints[i % _transformedPoints.length];
            sp.x = p0.x - Pyramids.OFFSET_X;
            sp.y = p0.y - Pyramids.OFFSET_Y;
            var a0 : Number = Math.atan2(sp.y, sp.x);
            var a1 : Number = Math.atan2(p0.y - p1.y, p0.x - p1.x);
            var d : Number = 2 * sp.length * Math.cos(Pyramids.HALF_PI - a1 + a0);
            var a : Number = a1 - Pyramids.HALF_PI;
            p.x = Math.cos(a) * d;
            p.y = Math.sin(a) * d;
            
            mtrx.identity();
            mtrx.scale(-1, 1);
            mtrx.rotate(2 * a);
            mtrx.translate(p.x + Pyramids.OFFSET_X, p.y + Pyramids.OFFSET_Y);
            with (graphics) {
                beginBitmapFill(bitmapData, mtrx, true, true);
                moveTo(p0.x, p0.y);
                lineTo(p1.x, p1.y);
                lineTo(cp.x, cp.y);
                lineTo(p0.x, p0.y);
                endFill();
            }
            p0 = p1;
        }
    }

    public function update(tx : Number, ty : Number) : void {
        if (Math.random() < .005) _targetAngle = (6 - 12 * Math.random()) * Pyramids.DOUBLE_PI;
        
        var da : Number = correctAngle(_targetAngle, _easyAngle);
        _easyAngle -= Math.min(Math.abs(da), 0.6) * .1 * sign(da);
        angle -= correctAngle(_easyAngle, angle) * .05;
        tx = Math.max(Math.min(tx, .7), -.7);
        ty = Math.max(Math.min(ty, .7), -.7);
        _targetMouseX += (tx - _targetMouseX) * .1;
        _targetMouseY += (ty - _targetMouseY) * .1;
        _matrix.identity();
        _matrix.scale(scale, scale);
        _matrix.rotate(angle);
        _matrix.translate(x - 300 * _targetMouseX * scale * scale, y - 300 * _targetMouseY * scale * scale);
    }

    public function getBoundRect() : Rectangle {
        var r : Rectangle = new Rectangle(Infinity, Infinity, -Infinity, -Infinity);
        for each (var p : Point in _transformedPoints) {
            if (p.x < r.x) r.x = p.x;
            if (p.y < r.y) r.y = p.y;
            if (p.x > r.width) r.width = p.x;
            if (p.y > r.height) r.height = p.y;
        }
        r.width = r.width - r.x + 2;
        r.height = r.height - r.y + 2;
        r.x -= Pyramids.OFFSET_X + 1;
        r.y -= Pyramids.OFFSET_Y + 1;
        return r;
    }

    public static function sign(n : Number) : Number {
        if (!n) return 0;
        return n > 0 ? 1 : -1;
    }

    public static function correctAngle(a0 : Number, a1 : Number) : Number {
        var d : Number = a1 - a0;
        if (d > Pyramids.HALF_PI) return d % Pyramids.DOUBLE_PI;
        if (d < -Pyramids.HALF_PI) return d % (-Pyramids.DOUBLE_PI);
        return d;
    }
}
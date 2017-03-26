package 
{
    import flash.display.Sprite;    
    import flash.events.Event;
    import flash.display.Graphics;
    import flash.geom.Point;
    import flash.display.BitmapData;
    import flash.display.Bitmap;
    import flash.geom.Matrix;
    import flash.geom.ColorTransform;
    import flash.filters.BlurFilter;
    import flash.events.MouseEvent;
    
    import net.hires.debug.Stats;
    
    [SWF(width = "465", height = "465", frameRate = "60", backgroundColor = "0")]
    public class Main extends Sprite
    {
        private const NUM_POINTS:int = 50;
        private const NUM_FUCTOR:int = 18;
        private const W:int = 465;
        private const H:int = 465;
        
        private var _parlinBmd:BitmapData;
        private var _canvas:BitmapData;
        private var _glow:BitmapData;
        private var _circles:Array = [];
        private var _points:Array = [];
        
        private var _vPoint:VecPoint = new VecPoint(W * .5, H * .5, W, H);
        private var _pList:Array = [];
        private var _g:Graphics;
        
        private var _ct:ColorTransform = new ColorTransform(.95, .95, .95);
        
        private var _isMouseDown:Boolean;
        
        public function Main()
        {
            stage.quality = "medium";            
            for(var i:int = 0; i<NUM_POINTS; i++){
                if(i == 0){
                    createPoint(15, 0xFF9900);
                }else if(i == NUM_POINTS - 1){
                    createPoint(10, 0xFF9900);
                }else{
                    createPoint((Math.random() * 8 + 2)|0, 0x88DDFF);
                }
            }
            
            _parlinBmd = new BitmapData(W, H, false, 0);
            _parlinBmd.perlinNoise(100, 100, 2, Math.random() * 0xFFFF | 0, false, true, 1 | 2);
            
            _canvas = new BitmapData(W, H, false, 0);
            addChild(new Bitmap(_canvas));
            
            _glow = _canvas.clone();
            var gBm:Bitmap = new Bitmap(_glow);
            gBm.blendMode = "add";
            addChild(gBm);
            
            var sp:Sprite = new Sprite();
            addChild(sp);
            
            _g = sp.graphics;
            
            addEventListener(Event.ENTER_FRAME, update);
            stage.addEventListener(MouseEvent.MOUSE_DOWN, onDown);
            stage.addEventListener(MouseEvent.MOUSE_UP, onUp);
        }
        
        
        private function createPoint(r:Number, col:int):void
        {
            _points.push(new PhysicsPoint(W * .5, H * .5));
            _pList.push([]);
            //
            var circle:Circle = new Circle(r, col);
            var bmd:BitmapData = new BitmapData(circle.width, circle.height, true, 0x00000000);
            bmd.draw(circle, new Matrix(1, 0, 0, 1, r, r));
            _circles.push(bmd);
        }
        
        private function update(e:Event):void
        {
            var vx:Number = 0;
            var vy:Number = 0;
            if(_isMouseDown){
                vx = mouseX;
                vy = mouseY;
            }else{
                vx = _vPoint.vPoint(_parlinBmd).x;
                vy = _vPoint.vPoint(_parlinBmd).y;
            }
            //
            _canvas.lock();
            _canvas.colorTransform(_canvas.rect, _ct);
            var l:int = _points.length;
            var plist:Array = [];
            for(var i:int = 0; i<l; i++){
                if(i == 0){
                    _points[i].setAcceleration((vx - _points[i].x) * NUM_FUCTOR, 
                                               (vy - _points[i].y) * NUM_FUCTOR);
                }else{
                    _points[i].setAcceleration((_points[i-1].x - _points[i].x) * (NUM_FUCTOR + i * .2), 
                                               (_points[i-1].y - _points[i].y) * (NUM_FUCTOR + i * .2));
                }
                _points[i].update();
                _canvas.copyPixels(_circles[i], _circles[i].rect, new Point(_points[i].x - _circles[i].width * .5,
                                                                            _points[i].y - _circles[i].height * .5));
                plist.push(_points[i]);
            }
            _canvas.applyFilter(_canvas, _canvas.rect, new Point(), new BlurFilter(8, 8));
            _canvas.unlock();
            _glow.lock();
            _glow.copyPixels(_canvas, _canvas.rect, new Point());
            _glow.unlock();
            //
            _g.clear();
            _g.lineStyle(1, 0xFFFFFF, .7);
            curveLine(plist, _g);
        }
        
        private function curveLine(pointList:Array, g:Graphics):void
        {
            if(pointList.length >= 3){
                g.moveTo(pointList[0].x, pointList[0].y);
                var l:int = pointList.length - 2;
                for(var i:int = 1; i<l; i++){
                    g.curveTo(pointList[i].x,
                              pointList[i].y,
                              (pointList[i].x + pointList[i+1].x) * .5,
                              (pointList[i].y + pointList[i+1].y) * .5);
                }
                g.curveTo(pointList[l].x, pointList[l].y,
                          pointList[l+1].x, pointList[l+1].y);
            }
        }
        
        private function onDown(e:MouseEvent):void
        {
            _isMouseDown = true;
            _parlinBmd.perlinNoise(100, 100, 2, Math.random() * 0xFFFF | 0, false, true, 1 | 2);
        }
        private function onUp(e:MouseEvent):void
        {
            _isMouseDown = false;
        }

    }

}


// ------------ PhysicsPoint ------------------/
import flash.geom.Point;
import flash.utils.Timer;
import flash.events.Event;

internal class PhysicsPoint extends Point
{

    private var _ax:Number, _ay:Number;
        
    public var vx:Number, vy:Number;
    public var resistance:Number;
    public var pastTime:Number;
        
    public function PhysicsPoint(px:Number, py:Number)
    {
        x = px;
        y = py;
        resistance = .9;
        vx = 0;
        vy = 0;
        _ax = 0;
        _ay = 0;
        pastTime = new Date().getTime();
    }
        
    public function update():void
    {
        var now:Number = new Date().getTime();
        var t:Number = (now - pastTime) * .001;
            
        x += vx * t + .5 * _ax * t * t;
        y += vy * t + .5 * _ay * t * t;
            
        vx += _ax * t;
        vy += _ay * t;
            
        vx *= resistance;
        vy *= resistance;
            
        _ax = 0;
        _ay = 0;
            
        pastTime = now;
    }
        
    public function setAcceleration(ax:Number, ay:Number):void
    {
        _ax += ax;
        _ay += ay;
    }
}



// ------------ VecPoint ------------------/
import flash.geom.Point;
import flash.display.BitmapData;

internal class VecPoint
{
    private var _av:Point = new Point();
    private var _vv:Point = new Point();
    private var _pv:Point = new Point();
    
    private var _limitW:Number;
    private var _limitH:Number;
    
    public function VecPoint(x:Number, y:Number, limitWidth:Number, limitHeight:Number)
    {
        _pv.x = x;
        _pv.y = y;
        _limitW = limitWidth;
        _limitH = limitHeight;
    }
    
    public function vPoint(map:BitmapData):Point
    {
        var c:Number = map.getPixel(_pv.x, _pv.y);
        var r:uint = c >> 16 & 0xFF;
        var g:uint = c >> 8 & 0xFF;
        _av.x += ( r - 128 ) * .0015;
        _av.y += ( g - 128 ) * .0015;
        _vv.x += _av.x;
        _vv.y += _av.y;
        _pv.x += _vv.x;
        _pv.y += _vv.y;
        _av.x *= .95;
        _av.y *= .95;
        _vv.x *= .9;
        _vv.y *= .9;
        (_pv.x > _limitW) ? _pv.x = 0 : 0;
        (_pv.x < 0) ? _pv.x = _limitW : 0;
        (_pv.y > _limitH) ? _pv.y = 0 : 0;
        (_pv.y < 0) ? _pv.y = _limitH : 0;
        
        return _pv;
    }
}



// ------------ Circle ------------------/
import flash.display.Sprite;
internal class Circle extends Sprite
{

    public function Circle(r:Number = 5, col:int = 0)
    {
        graphics.beginFill(col);
        graphics.drawCircle(0, 0, r);
    }

}
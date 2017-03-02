package
{
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.BlendMode;
    import flash.display.PixelSnapping;
    import flash.display.Sprite;
    import flash.display.Shape;
    import flash.display.Graphics;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.events.TimerEvent;
    import flash.filters.BlurFilter;
    
    import flash.geom.ColorTransform;
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.utils.Timer;
    
    [SWF(width = "465", height = "465", backgroundColor = "0x000000", frameRate = "30")]
    
    public class Main extends Sprite
    {
        private const WIDTH:Number = 465;
        private const HEIGH:Number = 465;
        
        private var _canvas:BitmapData;
        private var _glow:BitmapData;
        private var _rect:Rectangle;
        private var _cTra:ColorTransform;
        
        private var _shape:Shape;
        private var _timer:Timer;
        private var _pS:Points;
        
        public function Main()
        {
            init();
        }
        
        private function init():void
        {
            _canvas = new BitmapData(WIDTH, HEIGH, false, 0x0);
            addChild(new Bitmap(_canvas)) as Bitmap;
            
            _rect = new Rectangle(0, 0, WIDTH, HEIGH);
            _cTra = new ColorTransform(.8, .8, .9, 1.0);
            
            _glow = new BitmapData(WIDTH/2, HEIGH/2, false, 0x0);
            var bm:Bitmap = addChild(new Bitmap(_glow, PixelSnapping.NEVER, true)) as Bitmap;
            bm.scaleX = bm.scaleY = 2;
            bm.blendMode = BlendMode.ADD;
            
            var p:Points = new Points();
            _pS = p;
            for(var i:uint;i < 9;i++){
                p.next = new Points();
                p = p.next;
            }
            _shape = new Shape();
            //addChild(_shape);
            
            this.stage.addEventListener(MouseEvent.MOUSE_MOVE, moveEvent);
            addEventListener(Event.ENTER_FRAME, enterframeHandler);
        
            _timer = new Timer(100);
            _timer.addEventListener(TimerEvent.TIMER, timerHandler);
            _timer.start();
        }
        private function moveEvent(e:MouseEvent):void
        {
            update();
        }
        private var vr:Number = .1;
        private function update():void
        {
            _pS.px += (mouseX - _pS.px)/2;
            _pS.py += (mouseY - _pS.py)/2;
            if(_pS.r > 80) vr = -0.2;
            if(_pS.r < 40) vr = 0.2;
            _pS.r += vr;
            _pS.deg = (mouseX+mouseY)/3;
            trace(_pS.px);
        }
        
        private function enterframeHandler(e:Event):void
        {
            var p:Points = _pS;
            while(p.next){
                p.next.px += (p.px - p.next.px) / 4;
                p.next.py += (p.py - p.next.py) / 4;
                p.next.r += (p.r - p.next.r) / 4;
                p.next.deg += (p.deg - p.next.deg) / 4;
                p = p.next;
            }
            _shape.graphics.clear();
            draw();
        }
        private function draw():void
        {
            _canvas.lock();
            _canvas.applyFilter(_canvas, _rect, new Point(), new BlurFilter(1, 1));
            _canvas.colorTransform(_rect, _cTra);
            var gr:Graphics = _shape.graphics;
            gr.lineStyle(1,0xAAEEFF);
            var p:Points = _pS;
            while(p){
                gr.moveTo(p.px1,p.py1);
                gr.lineTo(p.px2,p.py2);
                gr.lineTo(p.px3,p.py3);
                gr.lineTo(p.px4,p.py4);
                gr.lineTo(p.px5,p.py5);
                gr.lineTo(p.px1,p.py1);
                if(p.next != null){
                    gr.moveTo(p.px1,p.py1);
                    gr.lineTo(p.next.px1,p.next.py1);
                    gr.moveTo(p.px2,p.py2);
                    gr.lineTo(p.next.px2,p.next.py2);
                    gr.moveTo(p.px3,p.py3);
                    gr.lineTo(p.next.px3,p.next.py3);
                    gr.moveTo(p.px4,p.py4);
                    gr.lineTo(p.next.px4,p.next.py4);
                    gr.moveTo(p.px5,p.py5);
                    gr.lineTo(p.next.px5,p.next.py5);
                }
                p = p.next;
            }
            _canvas.draw(_shape);
            _canvas.unlock();
            //_glow.draw(_canvas, new Matrix(0.5, 0, 0, 0.5));
        }
        
        private function timerHandler(e:TimerEvent):void
        {
            
        }
        
    }
}

class Points
{
    public var px:Number = 230;
    public var py:Number = 230;
    public var r:Number = 50;
    public var deg:Number = 0;
    public var next:Points;
    
    public function Particle():void
    {
    }
    
    public function get px1():Number{ return px + r * Math.cos(deg * Math.PI/180); }
    public function get px2():Number{ return px + r * Math.cos((deg+72) * Math.PI/180); }
    public function get px3():Number{ return px + r * Math.cos((deg+144) * Math.PI/180); }
    public function get px4():Number{ return px + r * Math.cos((deg+216) * Math.PI/180); }
    public function get px5():Number{ return px + r * Math.cos((deg+298) * Math.PI/180); }
    
    public function get py1():Number{ return py + r * Math.sin(deg * Math.PI/180); }
    public function get py2():Number{ return py + r * Math.sin((deg+72) * Math.PI/180); }
    public function get py3():Number{ return py + r * Math.sin((deg+144) * Math.PI/180); }
    public function get py4():Number{ return py + r * Math.sin((deg+216) * Math.PI/180); }
    public function get py5():Number{ return py + r * Math.sin((deg+298) * Math.PI/180); }
}

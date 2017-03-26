/**
 * Click : Zoom In
 * CTRL+Click : Zoom Out
 * Drag : Move
 * 1-5 : Somewhere
 */
package  {
    
    import com.bit101.components.*;
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.geom.ColorTransform;
    import flash.geom.Point;
    import frocessing.color.ColorHSV;
    
    public class Study extends Sprite {
        
        private var _bg:Sprite = new Sprite();
        private var _bmp:Bitmap;
        private var _bmd:BitmapData;
        private var _buffer:BitmapData;
        private var _md:Mandelbrot;
        
        private var _animate:Boolean = true;
        private var _fade:Boolean = true;
        private var _deep:Boolean = false;
        private var _ctrl:Boolean = false;
        private var _isMouseDown:Boolean = false;
        private var _isDrag:Boolean = false;
        private var _staticScale:Number = 1;
        private var _animationScale:Number = 0.5;
        private var _centerRI:Point = new Point();
        private var _downRI:Point = new Point();
        private var _downXY:Point = new Point();
        private var _alphaBlend:ColorTransform = new ColorTransform(1, 1, 1, 0.15, 0, 0, 0, 0);
        private var _checks:Vector.<CheckBox> = new Vector.<CheckBox>();
        private var _timer:ClockTimer = new ClockTimer();
        private var _drawScale:Number;
        private var _zoom:Number;
        
        public function Study() {
            if (stage) init();
            else addEventListener(Event.ADDED_TO_STAGE, init);
        }
        
        private function init(e:Event = null):void {
            removeEventListener(Event.ADDED_TO_STAGE, init);
            stage.frameRate = 60;
            
            _bmp = new Bitmap(_bmd, "auto", true);
            setCanvasScale(_animationScale);
            addChild(_bg);
            addChild(_bmp);
            createButtons();
            _bg.graphics.beginFill(0);
            _bg.graphics.drawRect(0, 0, 465, 465);
            
            _timer.start();
            _timer.time = 2000;
            _md = new Mandelbrot();
            _md.colors.length = 0;
            for (var c:int = 0; c < 256; c++)
                _md.colors[c] = !c ? 0xFFFFFFFF : (c < 128)    ? new ColorHSV(70 - 40 * c / 128, 1, 1).value32 : new ColorHSV(30, 1, 2 - c / 128).value32;
            _bg.addEventListener(MouseEvent.MOUSE_DOWN, onDownStage);
            stage.addEventListener(MouseEvent.MOUSE_MOVE, onDragStage);
            stage.addEventListener(MouseEvent.MOUSE_UP, onUpStage);
            
            addEventListener(Event.ENTER_FRAME, onEnterFrame);
            stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyInput);
            stage.addEventListener(KeyboardEvent.KEY_UP, onKeyInput);
            resetPosition();
            updateSettings();
        }
        
        private function createButtons():void {
            Style.PANEL = 0x222222;
            new Panel(this, 465 - 90, 0).setSize(90, 105);
            var vox:VBox = new VBox(this, 465 - 80, 6);
            Style.LABEL_TEXT = 0xFFFFFF;
            Style.BACKGROUND = 0x666666;
            new FPSMeter(vox, 0, 0);
            var labels:Array = ["ANIMATION", "BLUR", "DEEP"];
            for (var i:int = 0; i < labels.length; i++)
                _checks[i] = new CheckBox(vox, 0, 0, labels[i], updateSettings);
            Style.LABEL_TEXT = 0;
            new PushButton(vox, 0, 10, "RESET", resetPosition).setSize(70, 18);
            _checks[0].selected = _animate;
            _checks[1].selected = _fade;
            _checks[2].selected = _deep;
        }
        
        private function onKeyInput(e:KeyboardEvent):void {
            if (e.type == KeyboardEvent.KEY_UP) {
                switch(e.keyCode) {
                    ///case 32: System.setClipboard("jump(" + _centerRI.x.toFixed(String(int(_zoom)).length+2) + ", " + _centerRI.y.toFixed(String(int(_zoom)).length+2) + ", " + _zoom.toFixed(1) + ", " + _timer.time + ", "+_deep+");"); break;
                    case 49: case  97: jump( -0.32295, 0.000975, 0.8, 108841, false); break;
                    case 50: case  98: jump(-0.37453, 1.16594, 46, 165175, false); break;
                    case 51: case  99: jump(0.40441, -0.09875, 1995, 73081, true); break;
                    case 52: case 100: jump(-0.77836, 0.00102, 525, 38564, true); break;
                    case 53: case 101: jump(0.79734, 0.06116, 288, 34733, true); break;
                }
            }
            _ctrl = e.ctrlKey;
        }
        
        private function jump(x:Number, y:Number, zoom:Number, time:int, deep:Boolean):void {
            _timer.time = time;
            _centerRI = new Point(x, y);
            _zoom = zoom;
            _checks[0].selected = false;
            _checks[2].selected = deep;
            updateSettings();
            draw(true, _fade);
        }
        
        private function resetPosition(e:MouseEvent = null):void {
            _centerRI = new Point( -0.1, 0);
            _zoom = 0.7;
            draw(true, _fade);
        }
        
        private function updateSettings(e:Event = null):void {
            _animate = _checks[0].selected;
            _fade = _checks[1].selected;
            _deep = _checks[2].selected;
            _timer.setPlaying(_animate);
            _md.iteration = _deep? 120 : 30;
            setCanvasScale(_animate? _animationScale : _staticScale);
            draw(true, false);
        }
        
        private function onEnterFrame(e:Event):void {
            draw(_animate, _fade);
        }
        
        private function setCanvasScale(scale:Number):void {
            _drawScale = scale;
            if(_bmd) _bmd.dispose();
            if(_buffer) _buffer.dispose();
            _bmd = new BitmapData(465 * scale, 465 * scale, false, 0);
            _buffer = new BitmapData(465 * scale, 465 * scale, true, 0);
            _bmp.bitmapData = _bmd;
            _bmp.width = _bmp.height = 465;
        }
        
        private function onDownStage(e:MouseEvent):void {
            _isMouseDown = true;
            _isDrag = false;
            _downRI = _centerRI.clone();
            _downXY = new Point(mouseX, mouseY);
        }
        
        private function onUpStage(e:MouseEvent):void {
            if (!_isMouseDown) return;
            _isMouseDown = false;
            if (!_isDrag) {
                var m:int = _ctrl? -1 : 1;
                var tx:Number = (mouseX - _bmp.width / 2) * _md.SX / _zoom * m;
                var ty:Number = (mouseY - _bmp.height / 2) * _md.SY / _zoom * m;
                _centerRI.offset(tx, ty);
                _zoom *= Math.pow(1.5, m);
            }
            if (!_animate) setCanvasScale(_staticScale);
            draw(true, false);
        }
        
        private function onDragStage(e:MouseEvent):void {
            if (!_isMouseDown) return;
            if (!_isDrag) {
                if (Point.distance(new Point(_bmp.mouseX, _bmp.mouseY), _downXY) > 2) {
                    setCanvasScale(_animationScale);
                    draw(true, false);
                    _isDrag = true;
                }
                return;
            }
            _centerRI.x = _downRI.x - (mouseX - _downXY.x) * _md.SX / _zoom;
            _centerRI.y = _downRI.y - (mouseY - _downXY.y) * _md.SY / _zoom;
            if (!_animate) draw(true, _fade);
        }
        
        public function draw(calc:Boolean = true, fade:Boolean = true):void {
            if (calc) {
                var r:Number = _timer.time  * 0.007;
                _md.t = Math.sin(Math.PI / 180 * r*0.5) * 2;
                _md.x0 = Math.cos(Math.PI / 180 * r) * 0.8;
                _md.y0 = (Math.sin(Math.PI / 180 * r) + 2) * 0.2;
                _buffer.setVector(_bmd.rect, _md.getPixelsByCenter(_centerRI.x, _centerRI.y, _zoom * _drawScale, _zoom * _drawScale, _buffer.width, _buffer.height));
                if (fade) _buffer.colorTransform(_buffer.rect, _alphaBlend);
            }
            _bmd.copyPixels(_buffer, _buffer.rect, new Point(0, 0), null, null, true);
        }
        
    }
    
}

import flash.geom.Rectangle;
import flash.utils.getTimer;
import frocessing.color.ColorHSV;

class ClockTimer {
    
    private var _time:int = 0;
    private var _start:int = 0;
    private var _isPlaying:Boolean = false;
    
    public function get isPlaying():Boolean { return _isPlaying; }
    public function get time():int { return (!_isPlaying)? _time : _time + getTimer() - _start; }
    public function set time(value:int):void { setTime(value); }
    
    public function ClockTimer() {
    }
    
    public function reset():void {
        setTime(0);
    }
    
    private function setTime(value:int):void {
        _time = value;
        _start = getTimer();
    }
    
    public function setPlaying(play:Boolean):void {
        play? start() : stop();
    }
    
    public function start():void {
        if (_isPlaying) return;
        _start = getTimer();
        _isPlaying = true;
    }
    
    public function stop():void {
        _time = time;
        _isPlaying = false;
    }
    
}

class Mandelbrot {
    
    public var iteration:int = 100;
    public var t:Number = 2;
    public var x0:Number = 0;
    public var y0:Number = 0;
    public var colors:Vector.<uint> = new Vector.<uint>();
    public const SX:Number = 2.6 / 500;
    public const SY:Number = 2.6 / 500;
    
    public function Mandelbrot() {
        for (var i:int = 0; i < 360; i++)
            colors[i] = !i? 0xFF000000 : new ColorHSV(i, 0.8, 1.4).value32;
    }
    
    public function getPixelsByCenter(x:Number, y:Number, scaleX:Number = 1, scaleY:Number = 1, width:int = 465, height:int = 465):Vector.<uint> {
        var w:Number = SX / scaleX * width;
        var h:Number = SY / scaleY * height;
        return getPixels(new Rectangle(x - w / 2, y - h / 2, w, h), width, height);
    }

    public function getPixels(rect:Rectangle, width:int = 465, height:int = 465):Vector.<uint> {
        var i:int = 0, w:int, h:int, n:int, m:Number, dx:Number, dy:Number, cx:Number, cy:Number, x1:Number, y1:Number, x2:Number, y2:Number;
        var pixels:Vector.<uint> = new Vector.<uint>(width * height, true);
        dx = rect.width / width, dy = rect.height / height;
        cy = rect.y
        for (h = height; h > 0; h--) {
            cy += dy;
            cx = rect.x;
            for (w = width; w > 0; w--) {
                cx += dx;
                x1 = x0, y1 = y0;
                for (n = iteration; n > 0 && (x1 * x1 + y1 * y1) <= 100; n--) {
                    m = y1? x1 / y1 : Number.MAX_VALUE;
                    x2 = x1 * x1 - y1 * y1 + cy * m;
                    y2 = t * x1 * y1 + cx;
                    x1 = x2, y1 = y2;
                }
                pixels[i++] = colors[n / iteration * colors.length | 0];
            }
        }
        return pixels;
    }
    
}
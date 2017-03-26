package {
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.BlendMode;
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageQuality;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.filters.BitmapFilterQuality;
    import flash.filters.BlurFilter;
    import flash.filters.ColorMatrixFilter;
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.text.TextField;
    import flash.text.TextFormat;

    [SWF(backgroundColor='#000000', frameRate='30', width='465', height='465')]

    
    /**
     * PRESS ANY KEY
     */
    public class FormativeParticles extends Sprite {
        
        
        public static const WIDTH:int = 465;
        public static const HEIGHT:int = 465;
        public static const RECT:Rectangle = new Rectangle(0, 0, WIDTH, HEIGHT);
        public static const ZERO_POINT:Point = new Point();

        
        private var _text:TextField;
        private var _tmp1:BitmapData;
        private var _tmp2:BitmapData;
        private var _tmp3:BitmapData;
        private var _blur16:BlurFilter;
        private var _dimm:ColorMatrixFilter;
        private var _particles:ParticleField;
        private var _mtx:Matrix;

        
        public function FormativeParticles() {
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
            stage.quality = StageQuality.LOW;
            stage.fullScreenSourceRect = RECT;
            
            graphics.beginFill(0x0);
            graphics.drawRect(0, 0, WIDTH, HEIGHT);
            graphics.endFill();
            
            _text = new TextField();
            var fmt:TextFormat = new TextFormat('_sans', 500, 0xffffff);
            _text.defaultTextFormat = fmt;
            _text.width = WIDTH;
            _text.height = HEIGHT;
            _text.text = '';
            
            _tmp1 = new BitmapData(WIDTH, HEIGHT, false, 0x0);
            _tmp2 = _tmp1.clone();
            _mtx = new Matrix();
            _tmp3 = _tmp1.clone();
            _blur16 = new BlurFilter(16, 16, BitmapFilterQuality.MEDIUM);
            _dimm = new ColorMatrixFilter([
                0.99, 0, 0, 0, 0,
                0, 0.99, 0, 0, 0,
                0, 0, 0.99, 0, 0,
                0, 0, 0, 1, 0
            ]);
            
            _particles = new ParticleField(_tmp3);
            addChild(new Bitmap(_particles));
            
            addEventListener(Event.ENTER_FRAME, _onEnterFrame);
            stage.addEventListener(KeyboardEvent.KEY_DOWN, _onKeyDown);
        }

        
        private function _onEnterFrame(event:Event):void {
            _tmp3.draw(_tmp2, null, null, BlendMode.ADD);
            _tmp3.applyFilter(_tmp3, RECT, ZERO_POINT, _blur16);
            _tmp3.applyFilter(_tmp3, RECT, ZERO_POINT, _dimm);
            _particles.update();
        }

        
        private function _onKeyDown(event:KeyboardEvent):void {
            _text.text = String.fromCharCode(event.charCode);
            _tmp1.fillRect(RECT, 0x0);
            _tmp1.draw(_text);
            var r:Rectangle = _tmp1.getColorBoundsRect(0xff, 0x0, false);
            _tmp2.fillRect(RECT, 0x0);
            _mtx.identity();
            _mtx.translate(-r.x, -r.y);
            var a:Number = 300 / (Math.max(r.width, r.height));
            _mtx.scale(a, a);
            _mtx.translate((WIDTH - r.width * a) / 2, (HEIGHT - r.height * a) / 2);
            _tmp2.draw(_tmp1, _mtx);
        }
    }
}

import flash.display.BitmapData;
import flash.filters.ColorMatrixFilter;
import flash.geom.Point;


class ParticleField extends BitmapData {
    
    
    private static const ZERO_POINT:Point = new Point();
    
    private static const FORCE:Number = 0.3;
    private static const DRAG:Number = 0.998;
    
    
    private var _forceMap:BitmapData;
    private var _particles:Vector.<Particle>;
    private var _dimm:ColorMatrixFilter;

    
    public function ParticleField(forceMap:BitmapData) {
        super(forceMap.width, forceMap.height, true, 0x0);
        _forceMap = forceMap;
        _particles = new Vector.<Particle>();
        for (var i:int = 0; i < 5000; i++) {
            var p:Particle = new Particle(Math.random() * 465, Math.random() * 465);
            var a:Number = Math.random() * Math.PI * 2;
            p.vx = Math.cos(a) * 0.5;
            p.vy = Math.sin(a) * 0.5;
            _particles.push(p);
        }
        _dimm = new ColorMatrixFilter([
            1, 0, 0, 0, -8,
            0, 1, 0, 0, -2,
            0, 0, 1, 0, 0,
            0, 0, 0, 0.99, 0
        ]);
    }

    
    public function update():void {
        lock();
        var n:int = 3;
        while (n--) {
            applyFilter(this, rect, ZERO_POINT, _dimm);
            for each (var p:Particle in _particles) {
                var c1:Number = _forceMap.getPixel(p.x, p.y) & 0xff;
                var c2:Number = _forceMap.getPixel(p.x + 1, p.y) & 0xff;
                var c3:Number = _forceMap.getPixel(p.x, p.y + 1) & 0xff;
                p.vx += (c2 - c1) / 0x80 * FORCE;
                if ((p.vx > 0 ? p.vx : -p.vx) > 0.5) p.vx *= DRAG;
                p.x += p.vx;
                if (p.x <= 0) {
                    p.x = -p.x;
                    p.vx *= -1;
                } else if (465 <= p.x) {
                    p.x = 465 - (p.x - 465);
                    p.vx *= -1;
                }
                p.vy += (c3 - c1) / 0x80 * FORCE;
                if ((p.vy > 0 ? p.vy : -p.vy) > 0.5) p.vy *= DRAG;
                p.y += p.vy;
                if (p.y <= 0) {
                    p.y = -p.y;
                    p.vy *= -1;
                } else if (465 <= p.y) {
                    p.y = 465 - (p.y - 465);
                    p.vy *= -1;
                }
                setPixel32(p.x, p.y, 0xffffffff);
            }
        }
        unlock();
    }
}


class Particle {
    
    
    public var x:Number;
    public var y:Number;
    public var vx:Number;
    public var vy:Number;
    
    
    public function Particle(x:Number = 0, y:Number = 0) {
        this.x = x;
        this.y = y;
        vx = vy = 0;
    }
}

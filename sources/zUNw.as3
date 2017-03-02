// forked from cellfusion's Particle Sample
// Particle Sample Part2 http://wonderfl.net/code/22a06782b22470146ea62c1040ba435928fbf21c
// 浮かんで消える http://wonderfl.net/code/c4b218d595f245b5ac1eb97903e10e5fe973dbac
// write as3 code here..
// 光の表現のサンプルです。

package
{
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.display.StageQuality;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.filters.BlurFilter;
    import flash.geom.Matrix;
    import flash.geom.Point;
    //import net.hires.debug.Stats;

    [SWF(width="465", height="465", backgroundColor="0x000000", frameRate="30")]  
	
    public class LightEffect extends Sprite
    {
        private var _mirrorBmp:Bitmap = new Bitmap();
        private var _mirrorBmd:BitmapData = new BitmapData(465,465,false,0);
        private var _mirrorMtx:Matrix;
        private var _transPoint:Point = new Point(465/2, 465/2);
        
        private var _particleLayer:Sprite = new Sprite();
        
        private var _particles:Array = [];
        private var _emitter:Emitter;
        // 1フレーム間に発生させる Particle 数
        private const PARTICLE_NUM:uint = 1;

        public function LightEffect()
        {
            stage.quality = StageQuality.LOW;
            setup();
            //addChild(new Stats());
        }
        
        private function setup():void
        {
           	_mirrorBmp.bitmapData = _mirrorBmd;
           	addChild(_mirrorBmp);
           
            _emitter = new Emitter();
            addChild(_particleLayer);
            _particleLayer.addChild(_emitter);

            for (var i:uint = 0; i < 100; i++) {
                _particles.push(new Particle());
            }

            addEventListener(Event.ENTER_FRAME, draw);
            
            stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
        }
        
        private function draw(event:Event):void
        {
            _emitter.update();

            for each (var p:Particle in _particles) {
                if (!p.destroy) {
                    if (p.y >= 10) {
                       	p.vy *= -0.9;
                        p.vx *= -0.9
                    } 
                    p.update();
                }
            }
            
            //拡大反射
            _mirrorMtx = new Matrix();
            var ram:Number = 30+2*Math.random();
            _mirrorMtx.translate(-_transPoint.x, -_transPoint.y);
            _mirrorMtx.scale(ram,ram); 
            _mirrorMtx.translate(_transPoint.x, _transPoint.y);
            _mirrorBmd.fillRect(_mirrorBmd.rect, 0x00000000);
            _mirrorBmd.draw( _particleLayer, _mirrorMtx);
            
        }
        
        private function mouseDown(event:MouseEvent):void
        {
            addEventListener(Event.ENTER_FRAME, createParticle);
            stage.addEventListener(MouseEvent.MOUSE_UP, mouseUp);
            _transPoint.x = mouseX;
            _transPoint.y = mouseY;
        }

        private function mouseUp(event:MouseEvent):void
        {
            stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUp);
            removeEventListener(Event.ENTER_FRAME, createParticle);
        }
        
        private function createParticle(event:Event):void
        {
            var count:uint = 0;
            for each (var p:Particle in _particles) {
                // 停止している Particle を探す
                if (p.destroy) {
                    p.x = _emitter.x;
                    p.y = _emitter.y;
                    p.init();
                    _particleLayer.addChild(p);
                    count++;
                }
                if (count > PARTICLE_NUM) break;
            }
        }
    }
}


import flash.display.Sprite;
import flash.display.GradientType;

class Emitter extends Sprite
{
    public var vx:Number = 0;
    public var vy:Number = 0;

    public function Emitter(){}

    public function update():void
    {
        var dx:Number = root.mouseX - x;
        var dy:Number = root.mouseY - y;
        var d:Number = Math.sqrt(dx*dx+dy*dy) * 0.2;
        var rad:Number = Math.atan2(dy, dx);

        vx += Math.cos(rad)*d;
        vy += Math.sin(rad)*d;

        vx *= 0.7;
        vy *= 0.7;

        x += vx;
        y += vy;
    }
}


import flash.filters.BlurFilter;
import flash.geom.Matrix;
import flash.display.SpreadMethod;

class Particle extends Sprite
{
    public var vx:Number;
    public var vy:Number;
    public var life:Number;
    public var size:Number;

    private var _count:uint;
    private var _destroy:Boolean;
    
    /**
	 * ブラウン運動関連
	 */
	private var friction:Number = 0.99;
	private var vectx:Number = -0.4;
	private var vecty:Number = -0.8;
	private var xrandom:Number = 0.8;
	private var yrandom:Number = 0.3;

    public function Particle()
    {
        size = Math.random() * 30;
        
        var red:uint = Math.floor(Math.random()*100+156);
        var blue:uint = Math.floor(Math.random()*100+100);
        var green:uint = Math.floor(Math.random()*156);
        var color:Number = (red << 16) | (green << 8) | (blue);
        
        var fillType:String = GradientType.RADIAL;
        var colors:Array = [color , 0x000000];
        var alphas:Array = [100, 100];
        var ratios:Array = [0x00, 0xFF];
        var mat:Matrix = new Matrix();
        mat.createGradientBox(size * 2, size * 2, 0, -size, -size);
        var spreadMethod:String = SpreadMethod.PAD;

        graphics.clear();
        graphics.beginGradientFill(fillType, colors, alphas, ratios, mat, spreadMethod);
        graphics.drawCircle(0, 0, size);
        graphics.endFill();
        
        // 大量のオブジェクトを重ねるとおかしくなる
        blendMode = "add";

        _destroy = true;
    }

    public function init():void
    {
        vx = Math.random() * 20 - 10;
        vy = Math.random() * 20 - 10;
        life = Math.random() * 20 + 10;
        _count = 0;
        _destroy = false;
    }

    
    public function update():void
    {
        vx += Math.random()*xrandom + vectx;
		vy += Math.random()*yrandom + vecty;
		vx *= friction;
		vy *= friction;
		
        x += vx;
        y += vy;

        _count++;
        
        // 死亡フラグ
        if (life < _count) {
            _destroy = true;
            parent.removeChild(this);
        }
    }

    public function get destroy():Boolean
    {
        return _destroy;
    }
}
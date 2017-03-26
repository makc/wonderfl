// write as3 code here..
// 大量のパーティクルを発生させてみた
// マウスを押してる間でてくるよ
package
{
    import flash.display.Sprite;
    import flash.display.StageQuality;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import net.hires.debug.Stats;

    [SWF(width="465", height="465", backgroundColor="0x000000", frameRate="30")]  
	
    public class ParticleSample extends Sprite
    {
        private var _particles:Array = [];
        private var _emitter:Emitter;
        // 1フレーム間に発生させる Particle 数
        private const PARTICLE_NUM:uint = 50;

        public function ParticleSample()
        {
            stage.quality = StageQuality.BEST;
            setup();
            addChild(new Stats());
        }
        
        private function setup():void
        {
            _emitter = new Emitter();
            addChild(_emitter);

            for (var i:uint = 0; i < 10000; i++) {
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
                    p.vy += 0.98;
                    p.update();
                }
            }
        }
        
        private function mouseDown(event:MouseEvent):void
        {
            addEventListener(Event.ENTER_FRAME, createParticle);
            stage.addEventListener(MouseEvent.MOUSE_UP, mouseUp);
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
                    addChild(p);
                    count++;
                }
                if (count > PARTICLE_NUM) break;
            }
        }
    }
}


import flash.display.Sprite;

class Emitter extends Sprite
{
    public var vx:Number = 0;
    public var vy:Number = 0;

    public function Emitter()
    {       
        //graphics.beginFill(0x808080);
        //graphics.drawCircle(0, 0, 10);
        //graphics.endFill();
        
        //blendMode = "add";
    }

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

class Particle extends Sprite
{
    public var vx:Number;
    public var vy:Number;
    public var life:Number;
    public var size:Number;

    private var _count:uint;
    private var _destroy:Boolean;

    public function Particle()
    {
        size = Math.random() * 9 + 1;
        
        var red:uint = Math.floor(Math.random()*100+156);
        var blue:uint = Math.floor(Math.random()*100+100);
        var green:uint = Math.floor(Math.random()*156);
        var color:Number = (red << 16) | (green << 8) | (blue);      

        graphics.clear();
        graphics.beginFill(color);
        graphics.drawCircle(0, 0, size);
        graphics.endFill();
        
        //filters = [new BlurFilter(4,4,2)];
        
        // 大量のオブジェクトを重ねるとおかしくなる
        //blendMode = "add";

        _destroy = true;
    }

    public function init():void
    {
        vx = Math.random() * 20 - 10;
        vy = Math.random() * 20 - 10;
        life = Math.random() * 40 + 10;
        _count = 0;
        _destroy = false;
    }

    
    public function update():void
    {
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




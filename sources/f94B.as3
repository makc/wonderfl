// forked from esukei's forked from: forked from: forked from: forked from: 適当パーティクルエミッター0.2（未完成
// forked from esukei's forked from: forked from: forked from: 適当パーティクルエミッター0.2（未完成
// forked from esukei's forked from: forked from: 適当パーティクルエミッター0.2（未完成
// forked from esukei's forked from: 適当パーティクルエミッター0.2（未完成
// forked from esukei's 適当パーティクルエミッター0.2（未完成
// forked from esukei's forked from: 適当パーティクルエミッター（未完成
// forked from esukei's 適当パーティクルエミッター（未完成
package {
    import flash.geom.Rectangle;
    import flash.display.BitmapData;
    import flash.display.Bitmap;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.display.Sprite;
    import net.hires.debug.Stats;
    [SWF(frameRate="60", backgroundColor="0x000000")]
    public class FlashTest extends Sprite {
        
        public var emitter:Emitter;
        
        public var canvas:BitmapData;
        
        private var iParticles:uint = 0;
        private var particlesLength:uint = 0;
        
        private var console:Console;
        
        private var stats:Stats;
        
        public function FlashTest() {
            // write as3 code here..
            //emitter = new Emitter();
            emitter = new Emitter(0,0,0,0,0,0,.9,.9,2,3,100,100,100,.1);
            
            canvas = new BitmapData(465, 465, true, 0x00000000);
            addChild(new Bitmap(canvas));
            
            console = new Console();
            addChild(console);
            
            addEventListener(MouseEvent.MOUSE_MOVE, function(e:Event):void
            {
                //emitter.x = stage.mouseX;
                //emitter.y = stage.mouseY;
                //emitter.emit();
            });
            
            addEventListener(Event.ENTER_FRAME,function(e:Event):void
            {
                emitter.x = stage.mouseX;
                emitter.y = stage.mouseY;
                emitter.emit();
                
                console.clear();
                console.log('update');
                
                console.log('previous Particles:' + String(emitter.particles.length));
                
                emitter.update();
                
                console.log('current Particles:' + String(emitter.particles.length));
                
                particlesLength = emitter.particles.length;
                
                canvas.lock();
                canvas.fillRect(new Rectangle(0,0,465,465), 0x00000000);
                for(iParticles = 0; iParticles < particlesLength; iParticles++)
                {
                    var r:Number = emitter.particles[iParticles].lifeTime / emitter.particles[iParticles].maxLifeTime;
                    canvas.setPixel32(emitter.particles[iParticles].x, emitter.particles[iParticles].y, r * 255 << 24 | 255 << 16 | r * r * 255 << 8 | r * r * r * r * 255);
                    //canvas.setPixel32(emitter.particles[iParticles].x, emitter.particles[iParticles].y, 0xFFFFFFFF);
                }
                canvas.unlock();
            });
            
            stats = new Stats();
            stats.x = 400;
            addChild(stats);
        }
    }
}
import flash.display.AVM1Movie;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.display.BitmapData;
import flash.events.Event;
import flash.events.EventDispatcher;
class Emitter extends EventDispatcher {
    
    public var x:Number;
    public var y:Number;
    public var vx:Number = 0;
    public var vy:Number = 0;
    public var ivx:Number;
    public var ivy:Number;
    public var px:Number;
    public var py:Number;
    public var pvx:Number;
    public var pvy:Number;
    public var pax:Number;
    public var pay:Number;
    public var prx:Number;
    public var pry:Number;
    public var particles:Vector.<Particle>;
    public var lifeTime:uint;
    public var lifeTimeRandom:int;
    public var amounts:uint;
    public var motionInfluence:Number;
    
    public var explosion:Number;
    public var vibration:Number;
    
    public var velocityMin:Number = 0;
    
    public var nozzle:BitmapData;
    
    public var nozzleType:String = 'TRAIL';
    
    private var trailNozzle:Vector.<EmitPoint>;
    
    public function Emitter(x:Number = 0, y:Number = 0, pvx:Number = 0, pvy:Number = 0, pax:Number = 0, pay:Number = 0, prx:Number = 1.0, pry:Number = 1.0, explosion:Number = 0.0, vibration:Number = 0.0, amounts:uint = 1, lifeTime:uint = 1, lifeTimeRandom:int = 0, motionInfluence:Number = 0.0)
    {
        this.x = this.px = x;
        this.y = this.py = y;
        this.pvx = pvx;
        this.pvy = pvy;
        this.pax = pax;
        this.pay = pay;
        this.prx = prx;
        this.pry = pry;
        this.explosion = explosion;
        this.vibration = vibration;
        this.lifeTime = lifeTime;
        this.amounts = amounts;
        this.motionInfluence = motionInfluence;
        this.lifeTimeRandom = lifeTimeRandom;
        particles = new Vector.<Particle>();
        
        nozzle = new BitmapData(100,100);
        
        trailNozzle = new Vector.<EmitPoint>
    }

    private var iEmit:uint = 0;
    
    private var r:Number = 0;
    private var evx:Number = 0;
    private var evy:Number = 0;
    private var vibx:Number = 0;
    private var viby:Number = 0;
    private var rv:Number = 0;
    private var ta:Number = 0;
    
    private var e:Number = 0;
    private var ttx:Number = 0;
    private var tty:Number = 0;
    
    private var ti:Number = 0;
    private var tj:Number = 0;
    
    private var lx:Number = 0;
    private var ly:Number = 0;
    
    private var sx:Number = 0;
    private var sy:Number = 0;
    
    private var tvx:Number = 0;
    private var tvy:Number = 0;
    
    private var tmpx:Number = 0;
    private var tmpy:Number = 0;
    private var tmpP:uint = 0;
    
    public function emit():void
    {
        tvx = x - px;
        tvy = y - py;
        //vx,vy not correct?
        ivx = tvx * motionInfluence;
        ivy = tvy * motionInfluence;
        
        ta = amounts;//(Math.sqrt(vx * vx + vy * vy) > velocityMin) ? amounts : 0;
        
        //Make Trail Nozzle Vector
        tvx = x - px;
        tvy = y - py;
        
        lx = Math.abs(tvx);
        ly = Math.abs(tvy);
        
        sx = (lx != 0) ? (tvx) / lx : 1;
        sy = (ly != 0) ? (tvy) / ly : 1;
        
        ttx = 2 * lx;
        tty = 2 * ly;
        
        ti = 1;
        tj = 0;
        
        if(lx >= ly)
        {
            trailNozzle = new Vector.<EmitPoint>(lx,true);
            e = lx;
                
            for(ti; ti <= lx; ti++)
            {
                e += tty;
                if(e >= ttx)
                {
                    tj++;
                    e = e - ttx;
                }
                trailNozzle[ti-1] = new EmitPoint(sx * ti, sy * tj);
            }
        }
        else
        {
            trailNozzle = new Vector.<EmitPoint>(ly,true);
            e = ly;
                
            for(ti; ti <= ly; ti++)
            {
                e += ttx;
                if(e >= tty)
                {
                    tj++;
                    e = e - tty;
                }
                trailNozzle[ti-1] = new EmitPoint(sx * tj, sy * ti);
            }
        }
        
        for(iEmit = 0; iEmit < ta; iEmit++)
        {
            r = 360 * iEmit / amounts * Math.PI / 180;
            evx = Math.cos(r) * explosion;
            evy = Math.sin(r) * explosion;
            
            r = 2 * Math.random() * Math.PI;//360 * Math.random() * Math.PI / 180
            rv = vibration * Math.random();
            
            vibx = rv * Math.sin(r);           
            viby = rv * Math.cos(r);
            
            if(trailNozzle.length > 0)
            {
            tmpP = uint((trailNozzle.length-1) * Math.random());
            //trailNozzle[0];
            tmpx = trailNozzle[tmpP].x + px;
            tmpy = trailNozzle[tmpP].y + py;
            }
            else
            {
                tmpx = x;
                tmpy = y;
            }
            particles.push(new Particle(tmpx, tmpy, pvx + ivx + evx + vibx , pvy + ivy + evy + viby, pax, pay, prx, pry, lifeTime - int(Math.random() * lifeTimeRandom)));
            
            //particles.push(new Particle(x, y, pvx + ivx + evx + vibx , pvy + ivy + evy + viby, pax, pay, prx, pry, lifeTime - int(Math.random() * lifeTimeRandom)));
            
            //particles.push(new Particle(int(nozzle.width * Math.random()) + x, (nozzle.height * Math.random()) + y, pvx + ivx + evx + vibx , pvy + ivy + evy + viby, pax, pay, prx, pry, lifeTime - int(Math.random() * lifeTimeRandom)));
        }
        
    }
    
    private var iUpdate:int = 0;
    private var pLength:int = 0;
    public function update():void
    {
        vx = x - px;
        vy = y - py;
        px = x;
        py = y;
        
        pLength = particles.length;
        if(pLength == 0) return;
        
        iUpdate = pLength - 1;
        do
        {
            particles[iUpdate].vx += particles[iUpdate].ax;
            particles[iUpdate].vx *= particles[iUpdate].rx;
            particles[iUpdate].x += particles[iUpdate].vx;
            
            particles[iUpdate].vy += particles[iUpdate].ay;
            particles[iUpdate].vy *= particles[iUpdate].ry;
            particles[iUpdate].y += particles[iUpdate].vy;

            if(particles[iUpdate].lifeTime <= 0)
            {
                particles.splice(iUpdate,1);
                continue;
            }
            particles[iUpdate].lifeTime--;
        }
        while(iUpdate--);
    }
}

class EmitPoint {
    public var x:int;
    public var y:int;
    
    public function EmitPoint(x:int = 0, y:int = 0)
    {
        this.x = x;
        this.y = y;
    }
}

class Particle {
    
    public var x:Number;
    public var y:Number;
    public var vx:Number;
    public var vy:Number;
    public var ax:Number;
    public var ay:Number;
    public var rx:Number;
    public var ry:Number;
    public var maxLifeTime:uint;
    public var lifeTime:uint;
    
    public function Particle(x:Number = 0, y:Number = 0, vx:Number = 0, vy:Number = 0, ax:Number = 0, ay:Number = 0, rx:Number = 1.0, ry:Number = 1.0, lifeTime:uint = 1)
    {
        this.x = x;
        this.y = y;
        this.vx = vx;
        this.vy = vy;
        this.ax = ax;
        this.ay = ay;
        this.rx = rx;
        this.ry = ry;
        this.lifeTime = this.maxLifeTime =  lifeTime;
    }
}

import flash.text.TextField;
import flash.events.Event;
class Console extends TextField
{
    public function Console()
    {
        text = '';
        selectable = false;
        textColor = 0xFFFFFF;
        addEventListener(Event.ADDED_TO_STAGE, function(e:Event):void
        {
            removeEventListener(Event.ADDED_TO_STAGE, arguments.callee);
            width = stage.stageWidth;
            height = stage.stageHeight;
            
        });
    }
    
    public function log(message:String):void
    {
        this.appendText(message + '\n');
    }
    
    public function clear():void{
        this.text = '';
    }

}

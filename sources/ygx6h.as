package {
    import flash.display.BitmapData;
    import flash.display.Bitmap;
    import flash.events.Event;
    import flash.display.Sprite;
    [SWF(frameRate="60")]
    public class FlashTest extends Sprite {
        
        public var emitter:Emitter;
        
        public var canvas:BitmapData;
        
        public function FlashTest() {
            // write as3 code here..
            emitter = new Emitter(0,0,20,100);
            
            canvas = new BitmapData(465, 465, false, 0xFF000000);
            addChild(new Bitmap(canvas));
            
            addEventListener(Event.ENTER_FRAME,function(e:Event):void
            {
                emitter.x = stage.mouseX;
                emitter.y = stage.mouseY;
                emitter.emit();
                emitter.update(canvas);
            });
        }
    }
}
import flash.geom.Rectangle;
import flash.display.BitmapData;

class Emitter {
    
    public var x:Number;
    public var y:Number;
    public var particles:Array;
    public var lifeTime:uint;
    public var amounts:uint;
    
    public function Emitter(x:Number = 0, y:Number = 0, lifeTime:uint = 1, amounts:uint = 1)
    {
        this.x = x;
        this.y = y;
        this.lifeTime = lifeTime;
        this.amounts = amounts;
        particles = new Array();
    }

    private var iEmit:uint = 0;
    public function emit():void
    {
        for(iEmit = 0; iEmit < amounts; iEmit++)
        {
            var a:Number = (Math.random() * 360) * Math.PI / 180;
            particles.push(new Particle(x ,y, Math.sin(a) * 5 * Math.random(), Math.cos(a) * 5 * Math.random(), Math.sin(a) * 1 * Math.random(), Math.cos(a) * 1 * Math.random(), 1 + uint(Math.random() * lifeTime)));
        }
    }
    
    private var iUpdate:uint = 0;
    private var pLength:uint = 0;
    public function update(canvas:BitmapData = null):void
    {
        if(canvas)
        {
            canvas.lock();
            canvas.fillRect(new Rectangle(0,0,465,465),0xFF000000);
        }
        
        pLength = particles.length - 1;
        for(iUpdate = pLength; iUpdate > 0; iUpdate--)
        {
            particles[iUpdate].ax *= 1.05;
            particles[iUpdate].ay *= 1.05; 
            
            particles[iUpdate].vx += particles[iUpdate].ax;
            particles[iUpdate].x += particles[iUpdate].vx;
            
            particles[iUpdate].vy += particles[iUpdate].ay;
            particles[iUpdate].y += particles[iUpdate].vy;
            
            if(canvas)
            {
                canvas.setPixel32(particles[iUpdate].x, particles[iUpdate].y, 0xFF66AAFF);
            }

            particles[iUpdate].lifeTime--;
            if(particles[iUpdate].lifeTime < 1)
            {
                particles.splice(iUpdate, 1);
            }
        }

        if(canvas) canvas.unlock();

    }



}

class Particle {
    
    public var x:Number;
    public var y:Number;
    public var vx:Number;
    public var vy:Number;
    public var ax:Number;
    public var ay:Number;
    public var lifeTime:uint;
    
    public function Particle(x:Number = 0, y:Number = 0, vx:Number = 0, vy:Number = 0, ax:Number = 0, ay:Number = 0, lifeTime:uint = 1)
    {
        this.x = x;
        this.y = y;
        this.vx = vx;
        this.vy = vy;
        this.ax = ax;
        this.ay = ay;
        this.lifeTime = lifeTime;
    }
}


package 
{
    import flash.display.Sprite;
    import flash.display.BitmapData;
    import flash.display.Bitmap;
    import flash.events.Event;
    
    import flash.geom.Point;
    
    [SWF(width = "465", height = "465")]
    
    /**
     * ...
     * @author 
     */
    public class Main extends Sprite 
    {
        public static const WIDTH:int = 465;
        public static const HEIGHT:int = 465;
        
        private var canvas:BitmapData;
        
        private var particles:/*Particle*/Array;
        
        private var force:StarForce;
        
        public function Main():void 
        {
            if (stage) init();
            else addEventListener(Event.ADDED_TO_STAGE, init);
        }
        
        private function init(e:Event = null):void 
        {
            removeEventListener(Event.ADDED_TO_STAGE, init);
            // entry point
            graphics.beginFill(0);
            graphics.drawRect(0, 0, WIDTH, HEIGHT);
            graphics.endFill();
            
            canvas = new BitmapData(WIDTH, HEIGHT, true, 0);
            addChild( new Bitmap(canvas) );
            
            InitParticle();
            
            force = new StarForce();
            force.size = 100;
            
            addEventListener( Event.ENTER_FRAME, EnterFrameHandler );
        }
        
        private function InitParticle() : void
        {
            particles = [];
            
            for ( var y:int = 0; y < (HEIGHT/3); y++ )
            {
                for ( var x:int = 0; x < (WIDTH / 3); x++ )
                {
                    var particle:Particle = new Particle();
                    particle.x = x * 3;
                    particle.y = y * 3;
                    particle.basex = x * 3;
                    particle.basey = y * 3;
                    particles.push( particle );
                }
            }
            
        }
        
        private function EnterFrameHandler( e:Event ) : void
        {
            var i:int;
            var pnum:int = particles.length;
            
            force.SetPosition( mouseX, mouseY );
            
            canvas.lock();
            canvas.fillRect( canvas.rect, 0 );
            for ( i = 0; i < pnum; i++ )
            {
                var power:Point = force.GetPower( particles[i].x, particles[i].y );
                 particles[i].x = power.x + (particles[i].basex - particles[i].x) * 0.2;
                 particles[i].y = power.y + (particles[i].basey - particles[i].y) * 0.2;
                 if ( Math.abs(particles[i].basex - particles[i].x) < 0.5 && Math.abs( particles[i].basey - particles[i].y) < 0.5 )
                 {
                    particles[i].x = particles[i].basex;
                    particles[i].y = particles[i].basey;
                 }
                 
                canvas.setPixel32( particles[i].x, particles[i].y, 0xFFFFFFFF );
            }
            canvas.unlock();
            
        }
        
    }
    
}

import flash.geom.Point;


class Force {
    public var pos:Point;
    public var size:Number = 0;
    
    public function Force() {
        pos = new Point();
        size = 0;
    }
    
    public function SetPosition( x:Number, y:Number ) : void
    {
        pos.x = x;
        pos.y = y;
    }
    
}

class StarForce extends Force {
        
    public function StarForce() {
        super();
    }

    public function GetPower( targetX:Number, targetY:Number ) : Point
    {
        var power:Point = new Point();
        power.x = targetX;
        power.y = targetY;
        
        var targetlength:Number = Math.sqrt( (targetX - pos.x) * (targetX - pos.x) + (targetY - pos.y) * (targetY - pos.y) );
        
        if ( targetlength > size )    return    power;
        
        var anglerad:Number = Math.atan2( targetY - pos.y, targetX - pos.x );
        //    補正
        if ( anglerad < 0 )    anglerad += (Math.PI * 2);
        var angle:Number = anglerad * 180 / Math.PI;
        angle += 90;
        
        var sectorNo:int = int(angle / 36);
        var sectorRate:Number = (angle % 36) / 36;
        
        var powerlength:Number = 0;
        if ( sectorNo % 2 == 0 )    powerlength = size - (size / 2) * sectorRate;
        else                         powerlength = size - (size / 2) * (1 - sectorRate);
        
        if ( targetlength < powerlength )
        {
            power.x = pos.x + Math.cos( anglerad ) * powerlength;
            power.y = pos.y + Math.sin( anglerad ) * powerlength;
        }
        
        return    power;
    }
}


class Particle {
    public var x:Number;
    public var y:Number;
    public var basex:Number;
    public var basey:Number;
}
package
{
    import flash.display.Sprite;
    import flash.events.Event;

    public class Particles extends Sprite
    {
        public var stageWidth : int = stage.stageWidth - 8;
        public var stageHeight : int = stage.stageHeight - 8;

        private var particles : Array = new Array;
        private var particles_count : int = 100;

        public function Particles()
        {
            addEventListener( Event.ADDED_TO_STAGE, init );
        }
        
        private function init( e : Event ) : void
        {
            removeEventListener( Event.ADDED_TO_STAGE, init );

            for (var i : int = 0; i < particles_count; i++)
            {
                particles[i] = new Particle;
		particles[i].x = Math.random() * stageWidth;
		particles[i].y = Math.random() * stageHeight;
		particles[i].vx = Math.random() * 20 - 10;
		particles[i].vy = Math.random() * 20 - 10;

                addChild( particles[i] );
            }
            
            addEventListener(Event.ENTER_FRAME, loop);
        }

        private function loop( e : Event ) : void
        {
	    var distance : Object = {x:0, y:0};
	    var impact : Object = {x:0, y:0};
	    var impulse : Object = {x:0, y:0};
	    var impulseHalf : Object = {x:0, y:0};

            var gravity : Object = {x: (mouseX - (stageWidth >> 1)) / stageWidth, y: (mouseY - (stageHeight >> 1)) / stageHeight };

            for ( var i : int = 0; i < particles_count; i++)
            {
                var particle : Particle = particles[i];
			
                for( var j : int = 0; j < particles_count; j++)
                {
                    var particle2 : Particle = particles[j];
                    
                    if (particle2 == particle)
			continue;
				
                    distance.x = particle.x - particle2.x;
                    distance.y = particle.y - particle2.y;
								
                    var length : Number = Math.sqrt(distance.x * distance.x + distance.y * distance.y);
				
                    if (length < 16)
                    {					 	
                        impact.x = particle2.vx - particle.vx; //) * particle.restitution;
                        impact.y = particle2.vy - particle.vy; //) * particle.restitution;
					 
			impulse.x = particle2.x - particle.x;
			impulse.y = particle2.y - particle.y;
					
			var mag : Number = Math.sqrt(impulse.x * impulse.x + impulse.y * impulse.y);
			        
			if (mag > 0)
			{
			    mag = 1 / mag;
			    impulse.x *= mag;
			    impulse.y *= mag;
			}
					
			impulseHalf.x = impulse.x * .5;
			impulseHalf.y = impulse.y * .5;
					
			particle.x -= impulseHalf.x;
			particle.y -= impulseHalf.y;
					
			particle2.x += impulseHalf.x;
			particle2.y += impulseHalf.y;
				
			var dot : Number = impact.x * impulse.x + impact.y * impulse.y;
					
			impulse.x *= dot;
			impulse.y *= dot;
					
			particle.vx += impulse.x * .9; // * particle.restitution;
			particle.vy += impulse.y * .9; // * particle.restitution;
			particle2.vx -= impulse.x * .9; //particle.restitution;
			particle2.vy -= impulse.y * .9; //particle.restitution;
                    }
                }
			
		particle.x += particle.vx += gravity.x;
		particle.y += particle.vy += gravity.y;
		
		if (particle.y < 8 || particle.y > stageHeight)
		{
		    particle.vy *= -.8;
		    particle.vx *= .98;
		}
			
		particle.y = (particle.y < 8) ? 8 : (particle.y > stageHeight) ? stageHeight : particle.y;
			
		if (particle.x < 8 || particle.x > stageWidth)
		    particle.vx *= -.8;			
			
		particle.x = (particle.x < 8) ? 8 : (particle.x > stageWidth) ? stageWidth : particle.x;		
	    }
        }
    }
}

import flash.display.Sprite;

class Particle extends Sprite
{
    public var vx : Number = 0;
    public var vy : Number = 0;

    public function Particle()
    {
        graphics.beginFill(0x000000);
        graphics.drawCircle(0,0,8);
        graphics.endFill();
    }
}
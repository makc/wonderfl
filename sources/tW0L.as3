package 
{
    import flash.display.Sprite;
    import flash.events.Event;
    
    import flash.geom.Point;
    import flash.display.BitmapData;
    import flash.display.Bitmap;
    import flash.filters.ColorMatrixFilter;
    
    [SWF(width = "465", height = "465", frameRate = "60")]
    
    
    /**
     * ...
     * @author 
     */
    public class Main extends Sprite 
    {
        
        private var prev:Point;
        private var moveSize:Number;
        private var particleList:/*Particle*/Array;
        
        private var sprite:Sprite;
        private var canvas:BitmapData;
        private var filter:ColorMatrixFilter;
            
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
            graphics.drawRect(0, 0, 465, 465);
            graphics.endFill();
            
            sprite = new Sprite();
            canvas = new BitmapData( 465, 465, true, 0 );
            addChild( new Bitmap(canvas) );
            
            moveSize = 0;
            particleList = [];
            
            filter = new ColorMatrixFilter([
                1, 0, 0, 0, 0,
                0, 1, 0, 0, 0,
                0, 0, 1, 0, 0,
                0, 0, 0, 0.99, 0
            ]);
            
            
            addEventListener( Event.ENTER_FRAME, EnterFrameHandler );
        }
        
        private function EnterFrameHandler( e:Event ) : void
        {
            if ( prev == null )
            {
                prev = new Point(stage.mouseX, stage.mouseY);
            }
            var sx:Number = stage.mouseX - prev.x
            var sy:Number = stage.mouseY - prev.y;
            var i:int;
            
            for ( i = particleList.length - 1; i >= 0; i-- )
            {
                if ( particleList[i].life == 0 )    particleList.splice( i, 1 );
            }            
            for ( i = particleList.length - 1; i >= 0; i-- )
            {
                particleList[i].prevX = particleList[i].x;
                particleList[i].prevY = particleList[i].y;
                particleList[i].x += particleList[i].mx;
                particleList[i].y += particleList[i].my;
                
                //particleList[i].my += 0.2;
                
                particleList[i].life--;
                
                if ( particleList[i].life == 0 ){
                    if ( particleList[i].generation < Particle.MAX_GENERATION )
                    {
                        for ( var j:int = 0; j < 3; j++ )
                        {
                            particleList.push( CreateParticle(particleList[i], particleList[i].x, particleList[i].y, particleList[i].mx, particleList[i].my ) );
                        }
                    }    
                }
            }

            
            moveSize += Math.sqrt( sx * sx + sy * sy );
            if ( moveSize > 10 )
            {
                particleList.push( CreateParticle(null, stage.mouseX, stage.mouseY, sx, sy) );
                moveSize = 0;
            }
            
            
            sprite.graphics.clear();
            
            
            for ( i = 0; i < particleList.length; i++ )
            {
                sprite.graphics.lineStyle(1 + (Particle.MAX_GENERATION - particleList[i].generation), 0xFFFFFF);
                sprite.graphics.moveTo( particleList[i].prevX, particleList[i].prevY );
                sprite.graphics.lineTo( particleList[i].x, particleList[i].y );
            //    sprite.graphics.beginFill(0xFFFFFF);
            //    sprite.graphics.drawCircle( particleList[i].x, particleList[i].y, 1 + (Particle.MAX_GENERATION - particleList[i].generation) );
            //    sprite.graphics.endFill();
            }
            sprite.graphics.lineStyle(5, 0xFFFFFF);
            sprite.graphics.moveTo( stage.mouseX, stage.mouseY );
            sprite.graphics.lineTo( prev.x, prev.y );
            
            
            canvas.lock();
            canvas.applyFilter( canvas, canvas.rect, new Point(), filter );            
            canvas.draw( sprite );
            canvas.unlock();
            
            prev.x = stage.mouseX;
            prev.y = stage.mouseY;        
            
        }
        
        private function GetParticleLife( generation:int ) : int
        {
            return    (Particle.MAX_GENERATION - generation) * 5 + 2;
        }
    
        private function CreateParticle( parent:Particle, x:Number, y:Number, vecX:Number, vecY:Number ) : Particle
        {
            var particle:Particle = new Particle();
            particle.prevX = particle.x = x;
            particle.prevY = particle.y = y;
            if ( parent == null )    particle.generation = 0;
            else                     particle.generation = parent.generation + 1;
            particle.life = GetParticleLife( particle.generation ) * (Math.random() * 0.5 + 0.5);
            particle.angle = Math.atan2( vecY, vecX ) * 180 / Math.PI + (Math.random() * 160 - 80);
            
            var speedrate:Number = Math.random();
            particle.mx = Math.cos( particle.angle * Math.PI / 180 ) * 6 * speedrate;
            particle.my = Math.sin( particle.angle * Math.PI / 180 ) * 6 * speedrate;
            
            return    particle;
        }
        
    }
    
}


class Particle {
    public static const MAX_GENERATION:int = 4;
    
    public var x:Number;
    public var y:Number;
    public var prevX:Number;
    public var prevY:Number;
    public var generation:int;
    public var life:int;
    
    public var mx:Number;
    public var my:Number;
    public var angle:Number;
}
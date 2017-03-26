package 
{
    import flash.display.Sprite;
    import flash.events.Event;
    
    import flash.geom.Point;
    import flash.display.BitmapData;
    import flash.display.Bitmap;
    import flash.filters.ColorMatrixFilter;
    import flash.filters.BlurFilter;
    import flash.geom.ColorTransform;
    
    [SWF(width = "465", height = "465", frameRate = "60")]
    
    
    /**
     * ...
     * @author 
     */
    public class Main extends Sprite 
    {
        
        private var particleList:/*Particle*/Array;
        
        private var sprite:Sprite;
        private var canvas:BitmapData;
        private var backcanvas:BitmapData;
        private var filter:ColorMatrixFilter;
        private var blurfilter:BlurFilter;
        
        
        private var hanabi:SenkouHanabi;
        
        private var step:int = 0;
            
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
            
            hanabi = new SenkouHanabi();
            addChild( hanabi );
            hanabi.x = 465 / 2;
            hanabi.y = 0;
            var color:ColorTransform = new ColorTransform(0.8, 0.8, 0.8, 1);
            hanabi.transform.colorTransform = color;
            
            sprite = new Sprite();
            backcanvas = new BitmapData(465, 465, true, 0);
            addChild( new Bitmap(backcanvas) );
            canvas = new BitmapData( 465, 465, true, 0 );
            addChild( new Bitmap(canvas) );
            
            particleList = [];
            
            filter = new ColorMatrixFilter([
                1, 0, 0, 0, 0,
                0, 1, 0, 0, 0,
                0, 0, 1, 0, 0,
                0, 0, 0, 0.8, 0
            ]);
            
            blurfilter = new BlurFilter(4, 4, 3);
            
            
            addEventListener( Event.ENTER_FRAME, EnterFrameHandler );
        }
        
        private function EnterFrameHandler( e:Event ) : void
        {
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
                particleList[i].my += 0.1;
                //particleList[i].my += 0.2;
                
                particleList[i].life--;
                
                if ( particleList[i].life == 0 ){
                    if ( particleList[i].generation < Particle.MAX_GENERATION )
                    {
                        for ( var j:int = 0; j < 4; j++ )
                        {
                            particleList.push( CreateParticle(particleList[i], particleList[i].x, particleList[i].y ) );
                        }
                    }    
                }
            }

            if ( step++ % 3 == 0 )
            {
                particleList.push( CreateParticle(null, 465/2, 465/2 ) );
            }
            
            
            sprite.graphics.clear();
            
            
            sprite.graphics.beginFill(0xff8c00);
            sprite.graphics.drawCircle( 465 / 2, 465 / 2, 2+Math.random()*2 );
            sprite.graphics.endFill();
            for ( i = 0; i < particleList.length; i++ )
            {
                sprite.graphics.lineStyle(1.2, 0xff8c00);
                sprite.graphics.moveTo( particleList[i].prevX, particleList[i].prevY );
                sprite.graphics.lineTo( particleList[i].x, particleList[i].y );
            }
            
            
            
            canvas.lock();
            canvas.applyFilter( canvas, canvas.rect, new Point(), filter );            
            canvas.draw( sprite, null, null, "add" );
            canvas.unlock();    
            
            backcanvas.lock();
            backcanvas.draw( canvas );
            backcanvas.applyFilter( backcanvas, backcanvas.rect, new Point(), blurfilter );
            backcanvas.applyFilter( backcanvas, backcanvas.rect, new Point(), filter );
            backcanvas.unlock();
        }
        
        private function GetParticleLife( generation:int ) : int
        {
            return    (Particle.MAX_GENERATION - generation) * 1 + 3;
        }
    
        private function CreateParticle( parent:Particle, x:Number, y:Number ) : Particle
        {
            var particle:Particle = new Particle();
            particle.prevX = particle.x = x;
            particle.prevY = particle.y = y;
            if ( parent == null )    particle.generation = 0;
            else                     particle.generation = parent.generation + 1;
            particle.life = GetParticleLife( particle.generation ) * (Math.random() * 0.5 + 0.5);
            if ( parent == null )    particle.angle = Math.random() * 360;
            else                     particle.angle = parent.angle + (Math.random() * 160 - 80);
            
            var speedrate:Number = Math.random();
            particle.mx = Math.cos( particle.angle * Math.PI / 180 ) * 8 * speedrate;
            particle.my = Math.sin( particle.angle * Math.PI / 180 ) * 8 * speedrate;
            
            return    particle;
        }
        
    }
    
}
import flash.display.Sprite;

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

class SenkouHanabi extends Sprite {
    
    public function SenkouHanabi() {
        
        graphics.lineStyle(2, 0xc71585);
        graphics.moveTo(0, 0);
        graphics.lineTo(0, 5);
        graphics.lineStyle(2, 0xFFFFFF);
        graphics.moveTo(0, 5);
        graphics.lineTo(0, 15);
        graphics.lineStyle(2, 0xc71585);
        graphics.moveTo(0, 15);
        graphics.lineTo(0, 30);
        graphics.lineStyle(2, 0xFFFFFF);
        graphics.moveTo(0, 30);
        graphics.lineTo(0, 45);
        graphics.lineStyle(3, 0xff69b4);
        graphics.moveTo(0, 45);
        graphics.lineTo(0, 100);
        graphics.lineStyle(3, 0xffd700);
        graphics.moveTo(0, 100);
        graphics.lineTo(0, 150);
        graphics.lineStyle(3, 0x3cb371);
        graphics.moveTo(0, 150);
        graphics.lineTo(0, 155);
        graphics.lineStyle(3, 0xffd700);
        graphics.moveTo(0, 155);
        graphics.lineTo(0, 160);
        graphics.lineStyle(3, 0x3cb371);
        graphics.moveTo(0, 160);
        graphics.lineTo(0, 165);
        graphics.lineStyle(4, 0xffd700);
        graphics.moveTo(0, 165);
        graphics.lineTo(0, 185);
        graphics.lineStyle(5, 0xc71585);
        graphics.moveTo(0, 185);
        graphics.lineTo(0, 200);
        graphics.lineStyle(3, 0xc71585);
        graphics.moveTo(0, 200);
        graphics.lineTo(0, 220);
        graphics.lineStyle(2, 0xc71585);
        graphics.moveTo(0, 220);
        graphics.lineTo(0, 232);
        
        
        
    }
    
    
}
package {
    import flash.display.Sprite;
    import flash.display.Graphics;
    import flash.display.Stage;
    
    import flash.events.MouseEvent;
    import flash.events.Event;
    
    public class GlowParticles extends Sprite
    {
        
        private var g:Graphics;
        
        public function GlowParticles()
        {
            g = this.graphics;
            init();
        }
        
        private function init():void
        {
            g.beginFill(0x000000);
            g.drawRect(0,0,stage.stageWidth,stage.stageHeight);
            g.endFill();
            stage.addEventListener(MouseEvent.MOUSE_MOVE,createParticles);
        }
        
        private function createParticles(e:MouseEvent):void
        {
            var particle:Particle = new Particle(mouseX,mouseY);
            addChild(particle);
        }       

    }
}
import flash.display.Graphics;
import flash.filters.BlurFilter;

import flash.display.Sprite;
import flash.display.BlendMode;
import flash.events.Event;

internal class Particle extends Sprite
{
   
   private var g:Graphics;
    private var radius:Number = Math.random()*15+5;
    private var color:uint = 0xA0C1E8;
    private var blur:BlurFilter = new BlurFilter(10,10,1);
    
    private var vx:Number = Math.random()*2-1;
    private var vy:Number = Math.random()*-2;
    private var fade:Number = .02;
    
    public function Particle(startX:Number,startY:Number)
    {
        x = startX;
        y = startY;
        g = this.graphics;
        init();
    }
    
    private function init():void
    {
        g.beginFill(color);
        g.drawCircle(0,0,radius);
        g.endFill();
        
        this.filters = [blur];
        this.blendMode = BlendMode.ADD;
        this.addEventListener(Event.ENTER_FRAME,loop);
    }
    
    private function loop(e:Event):void
    {
        x += vx;
        y += vy;
        alpha -= fade;
        
        if(alpha<0)
        {
            destruct();
        }

    }
    
    private function destruct():void
    {
        this.removeEventListener(Event.ENTER_FRAME,loop);
        this.parent.removeChild(this);
    }
}
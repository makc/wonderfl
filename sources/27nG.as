// forked from yamat1011's flash on 2011-3-14
// bubble

package
{
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.events.Event;

    public class DotHackBubbleEffect extends Sprite
    {
        private static const _PADDING:Number = 20;
        
        private var _emitter:Emitter;
        private var _bubbles:Vector.<Bubble>;
        
        public function DotHackBubbleEffect()
        {
            _init();
        }
        
        private function _init():void
        {
            _emitter = new Emitter(this);
            _bubbles = new Vector.<Bubble>();
            
            addEventListener(Event.ENTER_FRAME, _enterFrameHandler, false, 0, true);
        }
        
        private function _enterFrameHandler(e:Event):void
        {
            //emitter
            _emitter.update();
            var vvv:Number = Math.sqrt(_emitter.vx + _emitter.vy);
            
            //create
            var n:uint = vvv;
            var radius:Number = 0;
            var b:Bubble;
            for(var i:int = 0; i < n; i++)
            {
                radius = Math.random() * 30 + 20;
                b = addChild(new Bubble(radius)) as Bubble;
                b.x = _emitter.x + (Math.random() - .5) * 30;
                b.y = _emitter.y + (Math.random() - .5) * 30;
                b.vx = (Math.random() - .5) * 3;
                
                _bubbles.push(b);
            }
            
            //update
            var nBubble:uint = _bubbles.length;
            for(i = nBubble - 1; i >= 0; i--){
                b = _bubbles[i];
                if(b.isDead)
                {
                    removeChild(b);
                    _bubbles.splice(i, 1);
                    nBubble--;
                    b = null;
                    
                    continue;
                }
                b.update();
            }
        }
    }
}
import flash.display.DisplayObjectContainer;

internal class Emitter
{
    private var _parent:DisplayObjectContainer;
    
    public var ax:Number = 0;
    public var ay:Number = 0;
    public var vx:Number = 0;
    public var vy:Number = 0;
    public var x:Number = 0;
    public var y:Number = 0;
    
    public function Emitter(parent:DisplayObjectContainer)
    {
        _parent = parent;
    }
    
    public function update():void
    {
        //ax *= .9;
        //ay *= .9; 
        vx *= .8;
        vy *= .8;
        
        ax = (_parent.stage.mouseX - x) / 20;
        ay = (_parent.stage.mouseY - y) / 20;
        vx += ax;
        vy += ay;
        x += vx;
        y += vy;
    }
}

import flash.display.BlendMode;
import flash.display.Graphics;
import flash.display.Shape;
import flash.filters.GlowFilter;

internal class Bubble extends Shape
{
    private static const _FURYOKU:Number = - 1.0;
    
    public var radius:Number;
    public var isDead:Boolean = false;
    
    public var vx:Number;
    public var vy:Number;
    
    public function Bubble(radius:Number)
    {
        this.radius = radius;
        this.blendMode = BlendMode.MULTIPLY;
        
        vx = 0;
        vy = 0;
              
        _draw();
    }
    
    private function _draw():void
    {
        var g:Graphics = this.graphics;
        
        //circle
        g.beginFill(0x000000, 1);
        g.drawCircle(0, 0, radius);
        g.endFill();
        
        //cross line
        g.lineStyle(1, 0xff0000, 1);
        g.moveTo(-4, 0);
        g.lineTo(4, 0);
        g.moveTo(0, -4);
        g.lineTo(0, 4);
        
        //filter
        var glow:GlowFilter = new GlowFilter(0xff0044, .5);
        this.filters = [glow];
    }
    
    public function update():void
    {
        this.vy = _FURYOKU;
        this.x += vx;
        this.y += vy;
        
        this.scaleX += (0 - this.scaleX ) / 5;
        this.scaleY += (0 - this.scaleY ) / 5;
        
        if(x < 0 - radius || x > stage.stageWidth + radius || y < 0 - radius || scaleX < .01 || scaleY < .01)    isDead = true;
    }
}
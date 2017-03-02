// forked from hacker_szoe51ih's spring ball
//「ActionScript3.0」アニメーション参照
package
{
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    
    [SWF(width="465", height="465", frameRate="30", backgroundColor="0xffffff")]
    public class Main extends Sprite
    {
        private var ball0:Ball;
        private var ball1:Ball;
        private var ball0Dragging:Boolean = false;
        private var ball1Dragging:Boolean = false;
        private var springGraphic:Spring;
        private var spring:Number = 0.04;
        private var gravity:Number = .5;
        private var friction:Number = 0.95;
        private var springLength:Number = 200;
        
        private var bounce:Number = -0.7;
        
        public function Main()
        {
            init();
        }
        
        private function init():void
        {
            springGraphic = addChild(new Spring()) as Spring;
            
            ball0 = new Ball(20,0x000000);
            ball0.x = Math.random() * stage.stageWidth;
            ball0.y = Math.random() * stage.stageHeight;
            ball0.addEventListener(MouseEvent.MOUSE_DOWN, downHandler);
            addChild(ball0);
            
            ball1 = new Ball(20,0x000000);
            ball1.x = Math.random() * stage.stageWidth;
            ball1.y = Math.random() * stage.stageHeight;
            ball1.addEventListener(MouseEvent.MOUSE_DOWN, downHandler);
            addChild(ball1);
            
            addEventListener(Event.ENTER_FRAME, onEnterFrame);
            stage.addEventListener(MouseEvent.MOUSE_UP, upHandler);
        }

        
        private function onEnterFrame(event:Event):void
        {
            if(!ball0Dragging)
            {
                springTo(ball0, ball1);
            }
            if(!ball1Dragging)
            {
                springTo(ball1, ball0);
            }
            springGraphic.x = ball0.x;
            springGraphic.y = ball0.y;
            springGraphic.rotation = 180 * Math.atan2(ball1.y - ball0.y, ball1.x - ball0.x) / Math.PI;
            springGraphic.length = Math.sqrt((ball1.x - ball0.x) * (ball1.x - ball0.x) + (ball1.y - ball0.y) * (ball1.y - ball0.y));
        /*
           graphics.clear();
           graphics.lineStyle(1);
           graphics.moveTo(ball0.x, ball0.y);
           graphics.lineTo(ball1.x, ball1.y);
         */
        }

        private function springTo(ballA:Ball, ballB:Ball):void
        {
            var dx:Number = ballB.x - ballA.x;
            var dy:Number = ballB.y - ballA.y;
            var angle:Number = Math.atan2(dy, dx);
            var targetX:Number = ballB.x - Math.cos(angle) * springLength;
            var targetY:Number = ballB.y - Math.sin(angle) * springLength;
            ballA.vx += (targetX - ballA.x) * spring;
            ballA.vy += (targetY - ballA.y) * spring;
            ballA.vx *= friction;
            ballA.vy *= friction;
            ballA.vy+=gravity;
            
            ballA.x += ballA.vx;
            ballA.y += ballA.vy;
            
            var left:Number = 0;
            var right:Number = stage.stageWidth;
            var top:Number = 0;
            var bottom:Number = stage.stageHeight;
            
            if(ballA.x + ballA.radius > right)
            {
                ballA.x = right - ballA.radius;
                ballA.vx *= bounce;
            }
            else if(ballA.x - ballA.radius < left)
            {
                ballA.x = left + ballA.radius;
                ballA.vx *= bounce;
            }
            if(ballA.y + ballA.radius > bottom)
            {
                ballA.y = bottom - ballA.radius;
                ballA.vy *= bounce;
            }
            else if(ballA.y - ballA.radius < top)
            {
                ballA.y = top + ballA.radius;
                ballA.vy *= bounce;
            }
            
            if(ballB.x + ballB.radius > right)
            {
                ballB.x = right - ballB.radius;
                ballB.vx *= bounce;
            }
            else if(ballB.x - ballB.radius < left)
            {
                ballB.x = left + ballB.radius;
                ballB.vx *= bounce;
            }
            if(ballB.y + ballB.radius > bottom)
            {
                ballB.y = bottom - ballB.radius;
                ballB.vy *= bounce;
            }
            else if(ballB.y - ballB.radius < top)
            {
                ballB.y = top + ballB.radius;
                ballB.vy *= bounce;
            }
        }
        
        private function downHandler(event:MouseEvent):void
        {
            event.target.startDrag();
            if(event.target == ball0)
            {
                ball0Dragging = true;
            }
            if(event.target == ball1)
            {
                ball1Dragging = true;
            }
        }
        
        private function upHandler(event:MouseEvent):void
        {
            ball0.stopDrag();
            ball1.stopDrag();
            ball0Dragging = false;
            ball1Dragging = false;
        }
    }
}

import flash.display.Sprite;

class Ball extends Sprite {
    public var radius:Number;
    public var color:uint;
    public var vx:Number=0;
    public var vy:Number=0;
    
    public function Ball(radius:Number=40, color:uint=0xff0000) {
        this.radius=radius;
        this.color=color;
        buttonMode=true;
        useHandCursor=true;
        init();
    }
    public function init():void {
        graphics.beginFill(color);
        graphics.drawCircle(0, 0, radius);
        graphics.endFill();
    }
}

import flash.display.Graphics;
class Spring extends Sprite
{
    private var _radius:Number;
    private var _numWind:uint;
    private var _color:uint;
    private var _lineStrength:Number;
    private var _length:Number = 200;

    private var _ratio:Number = 0.4;
    private var _mgn:int = 2;
    private var _springGraphic:Sprite;

    public function Spring(radius:Number = 30, numWind:uint = 5, lineStrength:Number = 3, color:uint = 0x0)
    {
        this._radius = radius;
        this._numWind = numWind;
        this._color = color;
        this._lineStrength = lineStrength;

        init();
    }

    private function init():void
    {
        this._springGraphic = new Sprite();
        var g:Graphics = this._springGraphic.graphics;
        g.clear();
        g.lineStyle(3, this._lineStrength);
        g.moveTo(0, 0);

        var interval:Number = this.length / (this._numWind + this._mgn * 2);

        g.lineTo(interval * this._mgn, 0);
        for(var i:int = this._mgn; i < this._numWind + this._mgn; i++)
        {
            g.curveTo(interval * i, -this._radius, interval * (1 + this._ratio) / 2 + interval * i, -this._radius);
            g.curveTo(interval * (1 + this._ratio) + interval * i, -this._radius, interval * (1 + this._ratio) + interval * i, 0);
            g.curveTo(interval * (1 + this._ratio) + interval * i, this._radius, interval * (i + 1) + interval * this._ratio / 2, this._radius);
            g.curveTo(interval * (i + 1), this._radius, interval * (i + 1), 0);
        }
        g.lineTo(interval * (this._numWind + this._mgn * 2), 0);

        this.addChild(this._springGraphic);
    }

    public function get length():Number
    {
        return this._length;
    }

    public function set length(newLength:Number):void
    {
        this._length = newLength;
        this._springGraphic.width = this._length;
    }


}
package {
    import com.bit101.components.PushButton;
    import flash.display.Sprite;
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.events.Event;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    
    public class FlashTest extends Sprite {
        
        public var centerX:Number = 465 / 2;
        public var centerY:Number = 465 / 2;
        
        public var _bitmap:Bitmap;
        public var _bitmapData:BitmapData;
        
        public var _baseBitmap:Bitmap;
        public var _baseBitmapData:BitmapData;
        
        public var hitBitmapData:BitmapData;
        
        public var particleNum:int = 5000;
        public var particles:Array = [];
    
        public function FlashTest() {
            // write as3 code here..
            
            _bitmapData = new BitmapData(465, 465, true, 0xff292929);
            _bitmap = new Bitmap(_bitmapData);
            addChild(_bitmap);
            
            _baseBitmapData = new BitmapData(465, 465, true, 0x00ffffff);
            _baseBitmapData.fillRect(new Rectangle(465 / 2 - 2, 465 / 2 - 2, 4, 4), 0xff00ffff);
            _baseBitmap = new Bitmap(_baseBitmapData);
            addChild(_baseBitmap);
            _baseBitmap.alpha = 1;
            
            hitBitmapData = new BitmapData(2, 2, true, 0xffffffff);
            
            initParticles();
            
            var _button:PushButton = new PushButton(this, 10, 465 - 30, "Hide", onShow);
            _button.alpha = 0.8;
            _button.toggle = true;
            _button.selected = true;
            
            addEventListener(Event.ENTER_FRAME, onLoop);
            
        }
        
        public function onShow(e:Event):void
        {
            if (e.target.selected == true)
            {
                e.target.label = "Hide";
                _baseBitmap.alpha = 1;
            }
            else
            {
                e.target.label = "Show";
                _baseBitmap.alpha = 0;
            }
        }
        
        public function onLoop(e:Event):void
        {
            _bitmapData.fillRect(_bitmapData.rect, 0xff292929);
            
            var i:int;
            var p:Particle;
            var tx:Number;
            var ty:Number;
            for (i = 0; i < particleNum; i += 1)
            {
                p = particles[i];
                tx = Math.round(p.x);
                ty = Math.round(p.y);
                
                if (_baseBitmapData.hitTest(new Point(_baseBitmapData.rect.x, _baseBitmapData.rect.y), 255, hitBitmapData, new Point(tx, ty)) == true)
                //if (_baseBitmap.hitTestPoint(Math.round(p.x), Math.round(p.y))==true)
                {
                    if (p.x > tx)
                    {
                        tx += 1;
                    }
                    if (p.y > ty)
                    {
                        ty += 1;
                    }
                    
                    _baseBitmapData.setPixel32(tx, ty, 0xff00ffff);
                    respawn(p);
                    
                }
                else
                {
                    p.vx += Math.random() * .1 - .05;
                    p.vy += Math.random() * .1 - .05;
                    p.x += p.vx;
                    p.y += p.vy;
                    p.vx *= .99;
                    p.vy *= .99;
                    
                    if (p.x > 465)
                    {
                        p.x -= 465;
                    }
                    else if (p.x < 0)
                    {
                        p.x += 465;
                    }
                    if (p.y > 465)
                    {
                        p.y -= 465;
                    }
                    else if (p.y < 0)
                    {
                        p.y += 465;
                    }
                    
                    _bitmapData.setPixel32(p.x, p.y, 0x20ffffff);
                }
            }
            
            
            
        }
        
        public function respawn(p:Particle):void
        {
            if (Math.random() < .5)
            {
                p.x = Math.random() * 465;
                p.y = Math.random() < .5 ? 0 : 465;
            }
            else
            {
                p.x = Math.random() < .5 ? 0 : 465;
                p.y = Math.random() * 465;
            }
        }
        
        public function initParticles():void
        {
            var i:int;
            var p:Particle;
            for (i = 0; i < particleNum; i += 1)
            {
                p = new Particle(Math.random() * 465, Math.random() * 465);
                particles.push(p);
            }

        }
    }
}

Class
{
    class Particle 
    {
        public var x:Number;
        public var y:Number;
        public var vx:Number;
        public var vy:Number;
        
        public function Particle(x:Number, y:Number) 
        {
            this.x = x;
            this.y = y;
            this.vx = Math.random() * .1 - .05;
            this.vy = Math.random() * .1 - .05;
        }
    }
}

package
{
    import flash.display.Sprite;
    import flash.display.Stage;
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.events.KeyboardEvent;
    import flash.geom.Point;
    import flash.geom.Matrix;

    [SWF(backgroundColor='#ffffff', frameRate='60')]

    public class BananaFun2 extends Sprite
    {
        static public const NUM_ROTS:int = 32;
        static public const MAX_PARTICLES:int = 2500;
        static public const MAX_SPEED:Number = 10.0;
        static public const ATTR_MULT:Number = 0.3;

        public var banana:Sprite = new Sprite();
        public var rotations:Vector.<BitmapData> = new Vector.<BitmapData>(NUM_ROTS);
        public var emptyPoint:Point = new Point(0, 0);
        public var empty:BitmapData;
        public var view:BitmapData;
        public var viewContainer:Bitmap;
        public var particles:Vector.<Banana> = new Vector.<Banana>(MAX_PARTICLES);
        public var numParticles:int = 16;
        public var sw:Number;
        public var sh:Number;
        public var md:Boolean = false;

        public function BananaFun2()
        {
            sw = stage.stageWidth;
            sh = stage.stageHeight;

            view = new BitmapData(sw, sh, true, 0x00000000);
            viewContainer = new Bitmap(view);
            empty = view.clone();

            addChild(viewContainer);

            var bananaScaleX:Number = 0.7;
            var bananaScaleY:Number = 0.7;

            banana.graphics.clear();
            banana.graphics.lineStyle(2, 0x70350D);
            banana.graphics.beginFill(0xFFFF00);
            banana.graphics.moveTo(12 * bananaScaleX, -22 * bananaScaleY);
            banana.graphics.curveTo(-12 * bananaScaleX, 0, 12 * bananaScaleX, 22 * bananaScaleY);
            banana.graphics.curveTo(6 * bananaScaleX, 0, 12 * bananaScaleX, -22 * bananaScaleY);
            banana.graphics.endFill();

            var i:int;
            var mat:Matrix = new Matrix();
            
            for(i = 0; i < NUM_ROTS; i++)
            {
                var rot:Number = Math.PI * 2 / NUM_ROTS * i;
                var bmp:BitmapData = new BitmapData(50 * bananaScaleX, 50 * bananaScaleX, true, 0x00000000);

                mat.identity();
                mat.rotate(rot);
                mat.translate(25 * bananaScaleX, 25 * bananaScaleY);

                bmp.draw(banana, mat);

                rotations[i] = bmp;
            }

            for(i = 0; i < MAX_PARTICLES; i++)
                particles[i] = new Banana(new Point(sw * 0.5, sh * 0.5));

            stage.addEventListener(Event.ENTER_FRAME, tick);
            stage.addEventListener(MouseEvent.CLICK, clicked);
            stage.addEventListener(MouseEvent.MOUSE_DOWN, mousedown);
            stage.addEventListener(MouseEvent.MOUSE_UP, mouseup);
            stage.addEventListener(MouseEvent.MOUSE_MOVE, mousemove);
            stage.addEventListener(KeyboardEvent.KEY_DOWN, keyboard);
        }

        public function tick(e:Event = null):void
        {
            // Clear
            view.copyPixels(empty, view.rect, emptyPoint);

            var attr:Point = new Point();

            attr.x = mouseX;
            attr.y = mouseY;

            for(var i:int = 0; i < numParticles; i++)
            {
                var p:Banana = particles[i];
                var rot:int = NUM_ROTS * ((p.rotation + Math.PI) / (Math.PI * 2));
                var bmp:BitmapData = rotations[(rot < 0 ? 0 : (rot >= NUM_ROTS ? NUM_ROTS - 1 : rot))];

                // Update particle position
                p.pos.x += p.vx;
                p.pos.y += p.vy;

                p.translated.x = p.pos.x - bmp.width * 0.5;
                p.translated.y = p.pos.y - bmp.height * 0.5;

                // Apply attraction towards nearest attractor
                var dx:Number = attr.x - p.pos.x;
                var dy:Number = attr.y - p.pos.y;
                var dist:Number = Math.sqrt(dx * dx + dy * dy);

                p.vx += (dx/dist) * ATTR_MULT;
                p.vy += (dy/dist) * ATTR_MULT;
                p.rotation += 0.01 * p.vx;

                // Make sure we're not going too fast
                var ad:Number;
                if((ad = Math.sqrt(p.vx * p.vx + p.vy * p.vy)) > MAX_SPEED)
                {
                    p.vx = (p.vx/ad) * MAX_SPEED;
                    p.vy = (p.vy/ad) * MAX_SPEED;
                }

                // Make sure particles don't leave the window
                if((p.pos.x + p.vx < 0 && p.vx < 0) || (p.pos.x + p.vx > sw && p.vx > 0)) p.vx = -p.vx;
                if((p.pos.y + p.vy < 0 && p.vy < 0) || (p.pos.y + p.vy > sh && p.vy > 0)) p.vy = -p.vy;

                // Make sure rotations don't go out of bounds
                if(p.rotation < -Math.PI) p.rotation += Math.PI * 2;
                if(p.rotation > Math.PI) p.rotation -= Math.PI * 2;

                view.copyPixels(bmp, bmp.rect, p.translated, bmp, emptyPoint, true);
            }
        }

        public function mousedown(e:MouseEvent):void { md = true; }
        public function mouseup(e:MouseEvent):void { md = false; }

        public function mousemove(e:MouseEvent):void
        {
            if(md)
                addBanana();
        }

        public function clicked(e:MouseEvent):void
        {
            addBanana();
        }

        public function keyboard(e:KeyboardEvent):void
        {
            if(e.keyCode == 90)
                numParticles = 1;

            if(e.keyCode == 88)
                numParticles = numParticles/2;

            if(e.keyCode == 67)
                numParticles = MAX_PARTICLES;

            if(e.keyCode == 32)
            {
                for(var i:int = 0; i < numParticles; i++)
                    particles[i].setVelocity();
            }

            if(numParticles == 0)
                numParticles = 1;
        }

        public function addBanana():void
        {
            if(numParticles >= MAX_PARTICLES)
                return;

            particles[numParticles++].setBanana(new Point(mouseX, mouseY));
        }
    } 
}

import flash.geom.Point;

class Banana
{
    public var pos:Point;
    public var translated:Point;
    public var vx:Number;
    public var vy:Number;
    public var rotation:Number;

    public function Banana(at:Point)
    {
        setBanana(at);
    }

    public function setBanana(at:Point):void
    {
        pos = at;
        translated = pos.clone();
        setVelocity();
        rotation = -Math.PI + (Math.PI * 2 * Math.random());
    }

    public function setVelocity():void
    {
        var angle:Number = Math.PI * 2 * Math.random();
        var force:Number = BananaFun2.MAX_SPEED * Math.random();
        vx = force * Math.cos(angle);
        vy = force * Math.sin(angle);
    }
}
package 
{
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.utils.getTimer;
    /**
     * ...
     * @author k3lab
     */
    [SWF(width="465", height="465", frameRate="60", backgroundColor="0")] 
    public class Main extends Sprite
    {
        private var h:int = 465,w:int = 465;
        private var fov0:Number = 300;
        private var fov1:Number = 600;
        private var count:int = 4000;
        private var hide_back:int = 10000;
        private var hide_front:int = -600;
        private var bit:BitmapData;
        private var degree:Number;    
        private var first:Particle;
        public function Main()
        {
           if (stage) init();
            else addEventListener(Event.ADDED_TO_STAGE, init);
        }
        private function init(e:Event=null):void
        {
            removeEventListener(Event.ADDED_TO_STAGE, init);
            bit = new BitmapData(w, h, false, 0);
            addChild(new Bitmap(bit));
            createDots(count);
            addEventListener(Event.ENTER_FRAME, run);
        }
        private function createDots(num:int):void
        {
            var p:Particle;
            var radian:Number = Math.PI / 180;
            degree = radian * 360 / num;
            var i:int;
            while (i < num) 
            {
                var px:Number = 200 * Math.sin(degree * i);
                var py:Number = 200 * Math.cos(degree * i);
                var pz:Number = -100 + i / 100;
                var particle:Particle = new Particle(px, py, pz)
                var dot:BitmapData = new BitmapData(20, 20, true, 0);
                var sprite:Sprite = new Sprite();
                var matrix:Matrix = new Matrix();
                sprite.graphics.beginFill(0xFFFFFF, 1);
                sprite.graphics.drawRect(0, 10 - 2, 20, 2);
                sprite.graphics.drawRect(10 - 2, 0, 2, 20);
                sprite.graphics.endFill();    
                matrix.translate(-10, -10);
                matrix.rotate(i / 100);
                matrix.translate(10, 10);
                dot.draw(sprite, matrix);
                particle.bit = dot.clone();
                if (!i)  first = particle;
                if (p) 
                {
                    p.next = particle;
                    particle.prev = p;
                }
                p = particle;
                particle.next = null;
                i++;
            }
            dot.dispose(); 
        }
        private function run(e:Event):void
        {
            var horizontal:Number = Math.sin(getTimer() / 2000) * 2;
            var vertical:Number = Math.sin(getTimer() / 30000) ;
            var cosY:Number = Math.cos(horizontal);
            var sinY:Number = Math.sin(horizontal);
            var cosX:Number = Math.cos(vertical);
            var sinX:Number = Math.sin(vertical);
            var i:int;
            var s:Number = 2500 + 1500 * Math.sin(getTimer() / 1000);
            var a:Number = s * 2 / count;
            var round:Number = degree * 2 * Math.sin(getTimer() / 10000);
            var current:Particle = first;
            bit.lock();
            bit.fillRect(bit.rect, 0);
            while (current) 
            {
                var size:Number = s * Math.sin(getTimer() / 10000 + i / 10);
                var radius:Number = size * Math.sin(degree / 2 * i);
                current.x = radius * Math.sin(round * i + getTimer() / 1000);
                current.y = radius * Math.cos(round * i + getTimer() / 1000);
                current.z = -s + i * a;
                var z1:Number = current.z * cosY + current.x * sinY;
                var z2:Number = z1 * cosX + current.y * sinX;
                if (z2 > hide_front && z2 < hide_back) 
                {
                    var perspective:Number = fov0 / (fov1 + z2);
                    var px:Number = w/2 + (current.x * cosY - current.z * sinY) * perspective;
                    var py:Number = h/2 + (current.y * cosX - z1 * sinX) * perspective;
                    if (px > -30 && px < w && py > -30 && py < h) 
                    {
                        var wi:Number = (z2 - 200) * -1 / 10;
                        if (wi < 1)  wi = 1;
                        var dotrect:Rectangle = new Rectangle();
                        dotrect.x = 10 - Math.round(wi / 2);
                        dotrect.y = 10 - Math.round(wi / 2);
                        dotrect.width = wi;
                        dotrect.height = wi;
                        bit.copyPixels(current.bit, dotrect, new Point(px,py));
                    }
                }
                i ++;
                current = current.next;
            }
            bit.unlock();
        }

    }
}
import flash.display.BitmapData;
class Particle extends Object
{
    public var next:Particle;
    public var prev:Particle;
    public var x:Number = 0, y:Number = 0, z:Number = 0, c:uint = 0;
    public var bit:BitmapData;
    public function Particle(x:Number=0, y:Number=0, z:Number=0)
    {
        this.x = x;
        this.y = y;
        this.z = z;
    } 
}
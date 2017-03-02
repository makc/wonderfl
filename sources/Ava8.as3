package 
{
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.geom.ColorTransform;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.display.BlendMode;
    import flash.display.GradientType;
    [SWF(width="465", height="465", frameRate="60")] 
    public class Main extends Sprite {
        private var canvas:BitmapData;
        private var circle_Array:Array = [];
        private var reset:Array = [];
        private var cirlce_Num:int = 10000; 
        private var color:ColorTransform = new ColorTransform(1, 1, 1, 1, -10, -35 * 20, -15 * 2); 
        private var planet:Sprite;
        public function Main():void {
            if (stage) init();
            else addEventListener(Event.ADDED_TO_STAGE, init);
        }
        private function init(e:Event = null):void {
            removeEventListener(Event.ADDED_TO_STAGE, init);
            createPos();
            setting();
            addEventListener(Event.ENTER_FRAME, update);
        }
        private function createPos():void {
            for (var i:int = 0; i < cirlce_Num; i++) {
                var p:Particle = new Particle()
                p.x = Math.random() * 465;
                p.y = Math.random() * 465;
                circle_Array[i] = p;
                var r:Number = i / cirlce_Num * 2 * Math.PI / 10;
                var resetPos:Object = { x: Math.cos(r * 100) * 100 + 240, y:Math.sin(r * 100) * 100 + 240 };
                reset[i]=resetPos;
            }
        }
        private function setting():void {
            canvas = new BitmapData(465, 465, false, 0);
            addChild(new Bitmap(canvas)) as Bitmap;	
            planet= addChild(new Sprite()) as Sprite;
            planet.graphics.beginGradientFill(GradientType.RADIAL,[0xF56800,0xFF0000],[0.1,0.4],[10,255],null,"pad","rgb",0)
            planet.graphics.drawCircle(0, 0, 100);
            planet.graphics.endFill();
            planet.blendMode="add"
            planet.x = 240;
            planet.y = 240;
        }
        private function update(e:Event):void {
            canvas.lock();
            canvas.colorTransform(canvas.rect, color); 
            for (var i:int = 0; i < cirlce_Num; i++) {
                var p:Particle = circle_Array[i];
                var r:Number = Math.PI * p.r / 180;
                var posX:Number = Math.sin(r) * p.n * planet.mouseX/100;
                var posY:Number = -(Math.cos(r)) * p.n * planet.mouseY/100;
                p.x += posX;
                p.y += posY;
                p.n += 0.09;
                if (p.x > 465 || p.x < 0 || p.y > 465 || p.y < 0) {
                    p.x = reset[i].x;
                    p.y = reset[i].y;
                    p.n = 0;
                }
                canvas.setPixel(p.x, p.y, 0xFFFFFF);
            }
            canvas.unlock();
        }
    }
}

class Particle {
    public var r:int;
    public var n:Number;
    public var x:Number;
    public var y:Number;
    public function Particle() {
        r = Math.random() * 360
        n = 0;
        x = 0;
        y = 0;
    }	
}
package {
    import flash.display.Sprite;
    import flash.geom.Point;
    public class FlashTest extends Sprite {
        public var a:Vector.<Anchor>;
        public function FlashTest() {
            // long time no code, huh...
            a = new Vector.<Anchor> (2, true);
            addChild (a [0] = new Anchor (100, 250));
            addChild (a [1] = new Anchor (200, 200));
            addEventListener("enterFrame", loop);
        }
        public var c:Point, v:Point;
        public function loop (...gettingRusty):void {
            var r:Number = Math.sqrt(
                (a[0].x - a[1].x) * (a[0].x - a[1].x) +
                (a[0].y - a[1].y) * (a[0].y - a[1].y)
            );
            var H:Number = 300;
            var cx:Number = 0.5 * (a[0].x + a[1].x);
            var cy:Number = 0.5 * (a[0].y + a[1].y) + H * Math.exp(-1.2 * r / H);
            if (c) {
                // change speed towards "perfect" center (cx, cy)
                var cvx:Number = cx - c.x;
                var cvy:Number = cy - c.y;
                v.x = 0.95 * 0.95 * v.x + 0.05 * cvx;
                v.y = 0.95 * 0.90 * v.y + 0.10 * cvy;
                c.x += v.x;
                c.y += v.y;
            } else {
                c = new Point (cx, cy); v = new Point;
            }
            graphics.clear ();
            graphics.lineStyle (3, 0xFF7F00);
            graphics.moveTo (a[0].x, a[0].y);
            graphics.curveTo (c.x, c.y, a[1].x, a[1].y);
        }
    }
}


import flash.display.Sprite;
import flash.events.MouseEvent;
class Anchor extends Sprite {
    public function Anchor (x0:int, y0:int) {
        x = x0; y = y0;
        graphics.beginFill (0xFF7F00, 1);
        graphics.drawRect (-6, -6, 12, 12);
        useHandCursor = buttonMode = true;
        addEventListener (MouseEvent.MOUSE_DOWN, startDragMe);
        addEventListener (MouseEvent.MOUSE_UP, stopDragMe);
    }
    public function startDragMe (e:MouseEvent):void {
        startDrag ();
    }
    public function stopDragMe (e:MouseEvent):void {
        stopDrag ();
    }
}
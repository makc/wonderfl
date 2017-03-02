// forked from makc3d's The rope.
package {
    import flash.display.Sprite;
    import flash.geom.Point;
    public class FlashTest extends Sprite {
        public var a:Vector.<Anchor>;
        public function FlashTest() {
            // let's try cubic curves
            a = new Vector.<Anchor> (2, true);
            addChild (a [0] = new Anchor (100, 250));
            addChild (a [1] = new Anchor (200, 200));
            addEventListener("enterFrame", loop);
        }
        public var c1:Point, v1:Point;
        public var c2:Point, v2:Point;
        public function loop (...gettingRusty):void {
            var r:Number = Math.sqrt(
                (a[0].x - a[1].x) * (a[0].x - a[1].x) +
                (a[0].y - a[1].y) * (a[0].y - a[1].y)
            );
            var H:Number = 150;
            var cx1:Number = a[0].x + 0.25 * (a[1].x - a[0].x);
            var cy1:Number = a[0].y + 0.25 * (a[1].y - a[0].y) + 4 * H * Math.exp(-0.5 * r / H) / 3;
            var cx2:Number = a[0].x + 0.75 * (a[1].x - a[0].x);
            var cy2:Number = a[0].y + 0.75 * (a[1].y - a[0].y) + 4 * H * Math.exp(-0.5 * r / H) / 3;
            if (c1) {
                // change speed towards "perfect" centers
                var cvx1:Number = cx1 - c1.x;
                var cvy1:Number = cy1 - c1.y;
                v1.x = 0.95 * (0.9 * v1.x + 0.1 * cvx1);
                v1.y = 0.95 * (0.9 * v1.y + 0.1 * cvy1);
                c1.x += v1.x;
                c1.y += v1.y;
                var cvx2:Number = cx2 - c2.x;
                var cvy2:Number = cy2 - c2.y;
                v2.x = 0.95 * (0.9 * v2.x + 0.1 * cvx2);
                v2.y = 0.95 * (0.9 * v2.y + 0.1 * cvy2);
                c2.x += v2.x;
                c2.y += v2.y;
            } else {
                c1 = new Point (cx1, cy1); v1 = new Point;
                c2 = new Point (cx2, cy2); v2 = new Point;
            }
            graphics.clear ();
            graphics.lineStyle (3, 0x7FFF);
            graphics.moveTo (a[0].x, a[0].y);
            graphics.cubicCurveTo (c1.x, c1.y, c2.x, c2.y, a[1].x, a[1].y);
        }
    }
}


import flash.display.Sprite;
import flash.events.MouseEvent;
class Anchor extends Sprite {
    public function Anchor (x0:int, y0:int) {
        x = x0; y = y0;
        graphics.beginFill (0x7FFF, 1);
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
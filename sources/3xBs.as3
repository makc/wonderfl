// Interactive Pythagoras Tree
package {
    import flash.display.Graphics;
    import flash.display.Sprite;
    import flash.geom.Matrix;
    import flash.geom.Point;

    public class FlashTest extends Sprite {
        private var count:Number = 0;

        private var left:Point = new Point;
        private var rotor:Matrix = new Matrix;
        private var s1:Point = new Point, s2:Point = new Point;

        // check out http://en.wikipedia.org/wiki/Pythagoras_tree
        private function ptree (at:Point, up:Point, g:Graphics):void {
            count += 1;
            // draw the square according to given position and direction
            left.x = -up.y; left.y = up.x;
            g.beginFill (0x31007*count);
            g.moveTo (at.x + up.x + left.x, at.y + up.y + left.y);
            g.lineTo (at.x + up.x - left.x, at.y + up.y - left.y);
            g.lineTo (at.x - up.x - left.x, at.y - up.y - left.y);
            g.lineTo (at.x - up.x + left.x, at.y - up.y + left.y);
            g.endFill ();
            // calculate radius
            var r:Point = rotor.transformPoint (up);
            // calculate half-sides
            s1.x = (r.x - left.x) * 0.5; s1.y = (r.y - left.y) * 0.5;
            s2.x = (r.x + left.x) * 0.5; s2.y = (r.y + left.y) * 0.5;
            // calculate directions
            var d1:Point = new Point (-s1.y, s1.x);
            var d2:Point = new Point (s2.y, -s2.x);
            // calculate positions of new squares
            var p1:Point = new Point (at.x + up.x + s2.x + d1.x, at.y + up.y + s2.y + d1.y);
            var p2:Point = new Point (at.x + up.x + s1.x + d2.x, at.y + up.y + s1.y + d2.y);
            // repeat twice
            if (count < 10) {
                ptree (p1, d1, g);
                ptree (p2, d2, g);
            }
            count -= 1;
        }

        public function FlashTest() {
            addEventListener("enterFrame", onEnterFrame);
        }

        private function onEnterFrame (e:*):void {
            rotor.identity ();
            rotor.rotate (2.0 * (mouseX - stage.stageWidth * 0.5) / stage.stageWidth);

            graphics.clear ();
            ptree (new Point (230, 340), new Point (0, -40), graphics);
        }
    }
}
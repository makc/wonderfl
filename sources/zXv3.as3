package {
    import flash.display.Graphics;
    import flash.display.Sprite;
    import flash.geom.Point;

    public class FlashTest extends Sprite {
        private var count:Number = 0;

        // check out http://en.wikipedia.org/wiki/Pythagoras_tree
        private function ptree (at:Point, up:Point, g:Graphics):void {
            count += 1;
            // draw the square according to given position and direction
            var left:Point = new Point (-up.y, up.x);
            g.beginFill (0);
            g.moveTo (at.x + up.x + left.x, at.y + up.y + left.y);
            g.lineTo (at.x + up.x - left.x, at.y + up.y - left.y);
            g.lineTo (at.x - up.x - left.x, at.y - up.y - left.y);
            g.lineTo (at.x - up.x + left.x, at.y - up.y + left.y);
            g.endFill ();
            // repeat twice
            if (count < 13) {
                ptree (new Point (at.x + 2 * up.x + left.x, at.y + 2 * up.y + left.y),
                    new Point (0.5 * (up.x + left.x), 0.5 * (up.y + left.y)), g);
                ptree (new Point (at.x + 2 * up.x - left.x, at.y + 2 * up.y - left.y),
                    new Point (0.5 * (up.x - left.x), 0.5 * (up.y - left.y)), g);
            }
            count -= 1;
        }

        public function FlashTest() {
            ptree (new Point (230, 340), new Point (0, -40), graphics);
        }
    }
}
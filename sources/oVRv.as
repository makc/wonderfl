package {
    import flash.display.BlendMode;
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.filters.BlurFilter;
    import flash.geom.Point;

    [SWF(backgroundColor="#000000")]
    public class FlashTest extends Sprite {
        private var c:int = 0;

        private function r ():Number {
            // don't you just hate these long lines...
            return Math.random ();
        }

        // yeah, those fake-looking explosions...
        private function boo (at:Point, side:Number):void {
            c++;

            var s:Shape = new Shape;
            s.graphics.beginFill (0x3f170d);
            s.graphics.drawRect (-0.5 * side, -0.5 * side,
                side, side); s.graphics.endFill ();
            s.x = at.x; s.y = at.y; s.rotation = 360 * r();
            s.blendMode = BlendMode.ADD;
            s.filters = [ new BlurFilter (side / 3, side / 3) ];
            addChild (s);

            if (c < 10) {
                boo (new Point (at.x + (r() - r()) * side,
                                at.y + (r() - r()) * side),
                    side * (0.7 + 0.3 * r()) );
                boo (new Point (at.x + (r() - r()) * side,
                                at.y + (r() - r()) * side),
                    side * (0.7 + 0.3 * r()) );
            }

            c--;
        }




        public function FlashTest() {
            // player goes all buggy in higher quality
            stage.quality = "low";

            // now is the time...
            boo (new Point (250, 250), 80);
        }
    }
}
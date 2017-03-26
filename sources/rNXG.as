// forked from makc3d's forked from: forked from: flash on 2012-7-28
// forked from makc3d's forked from: flash on 2012-7-28
// forked from makc3d's flash on 2012-7-28
package {
    import flash.display.*;
    import flash.geom.*;
    public class FlashTest extends Sprite {
        public var b:BitmapData;
        public var s:Shape;
        public function FlashTest() {
            // write as3 code here..
            b = new BitmapData (465, 465, false);
            b.noise (123, 0, 255, 7);
            //b.perlinNoise(64, 64, 7, 42, true, true);
            s = new Shape;
            var m:Matrix = new Matrix;
            m.translate(-465/2,-465/2);
            m.scale(1.001, 1.001); // stopper
            m.rotate (0.01);
            m.translate(465/2,465/2);
            s.graphics.beginBitmapFill (b, m, true);
            s.graphics.drawRect (0, 0, 465, 465);
            addChild (s);
            addEventListener ("enterFrame", loop);
        }
        public function loop(...yeah):void {
            s.cacheAsBitmap = true;
            b.draw (s);
            s.cacheAsBitmap = false;
        }
    }
}
// forked from Thumasz's forked from: forked from: forked from: flash on 2012-7-28
// forked from Thumasz's forked from: forked from: flash on 2012-7-28
// forked from makc3d's forked from: flash on 2012-7-28
// forked from makc3d's flash on 2012-7-28
package {
    import flash.display.*;
    import flash.geom.*;
    public class FlashTest extends Sprite {
        public var b:BitmapData;
        public var b2:BitmapData;
        public var s:Shape;
        public function FlashTest() {
            // write as3 code here..
            b = new BitmapData (465, 465, false);
            b2 = new BitmapData(465,465, false);
            b.noise (123, 0, 255, 7);
            b2.noise (123, 0, 255, 7);
            s = new Shape;
            var m:Matrix = new Matrix();
            m.scale(1.1,1.1);
            m.rotate(3);
            m.scale(0.95,0.95);
            m.translate(10,1);
            s.graphics.beginBitmapFill (b, m, true);
            s.graphics.drawRect (0, 0, 465, 465);
            addChild (s);
            addEventListener ("enterFrame", loop);
        }
        public function loop(...yeah):void {
            s.cacheAsBitmap = true;
            b.draw (s);
            b.draw(b2,new Matrix(),new ColorTransform(1,1,1,0.05));
            b2.draw(b);
            s.cacheAsBitmap = false;
        }
    }
}
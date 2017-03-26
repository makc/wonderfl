// forked from Thumasz's forked from: forked from: forked from: forked from: flash on 2012-7-28
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
            m.scale(1.2,1.2);
            m.rotate(Math.random()*5-2.5);
            m.scale(0.83,0.815);
            m.translate(Math.random()*100,1);
            s.graphics.beginBitmapFill (b, m, true);
            s.graphics.drawRect (0, 0, 465, 465);
            addChild (s);
            addEventListener ("enterFrame", loop);
        }
        public function loop(...yeah):void {
            s.cacheAsBitmap = true;
            b.draw (s);
            b.draw(b2,new Matrix(),new ColorTransform(1,1,1,0.06));
            b2.draw(b, new Matrix(), new ColorTransform(1.05,1.05,1.05,0.5,0,0,0));
            s.cacheAsBitmap = false;
        }
    }
}
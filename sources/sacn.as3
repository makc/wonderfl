// forked from makc3d's flash on 2013-2-6
package {
    import flash.display.*;
    public class FlashTest extends Sprite {
        public function FlashTest() {
            // write as3 code here..
            var bd:BitmapData = new BitmapData (465, 465);
            addChild (new Bitmap (bd)); bd.lock ();
            // let's try to modify this code to work with elliptic arc or sector
            // http://www.anderswallin.net/2009/05/uniform-random-points-in-a-circle-using-polar-coordinates/
            var cx:Number = 465/2, cy:Number = 465/2, a:Number = 200, b:Number = 100;
            var a0:Number = Math.PI *  Math.random ();
            var a1:Number = Math.PI * (Math.random () + 1);
            var r0:Number = 0.75 * Math.random (), r0s:Number = r0 * r0;
            var r1:Number = 1, r1s:Number = r1 * r1;
            for (var i:int = 0; i < 12345; i++) {
                var angle:Number = a0 + (a1 - a0) * Math.random ();
                var r:Number = Math.sqrt (r0s + (r1s - r0s) * Math.random ());
                var dx:Number = a * r * Math.sin (angle);
                var dy:Number = b * r * Math.cos (angle);
                bd.setPixel (cx + dx, cy + dy, 0xFFFF0000);
            }
            bd.unlock ();
        }
    }
}
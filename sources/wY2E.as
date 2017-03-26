// forked from makc3d's even distribution in elliptic arc or sector
// forked from makc3d's flash on 2013-2-6
package {
    import com.actionscriptbible.*;
    import flash.display.*;
    import flash.utils.*;
    public class FlashTest extends Example {
        public function FlashTest() {
            // for http://board.flashkit.com/board/showthread.php?829335
            var t:int = getTimer();
            var bd:BitmapData = new BitmapData (465, 465);
            addChildAt (new Bitmap (bd), 0); bd.lock ();
            var cx:Number = 465/2, cy:Number = 465/2, a:Number = 200, b:Number = 100;
            var a0:Number = Math.PI *  Math.random ();
            var a1:Number = Math.PI * (Math.random () + 1);
            var r0:Number = 0.75 * Math.random (), r0s:Number = r0 * r0;
            var r1:Number = 1, r1s:Number = r1 * r1;
            for (var i:int = 0; i < 1234567; i++) {
                var angle:Number = a0 + (a1 - a0) * Math.random ();
                var r:Number = Math.sqrt (r0s + (r1s - r0s) * Math.random ());
                var dx:Number = a * r * Math.sin (angle);
                var dy:Number = b * r * Math.cos (angle);
                bd.setPixel (cx + dx, cy + dy, 0xFFFF0000);
            }
            bd.unlock ();
            trace (0.001 * (getTimer() - t) + " seconds");
        }
    }
}
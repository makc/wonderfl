package {
    import flash.display.*;
    public class FlashTest extends Sprite {
        public function FlashTest() {
            // write as3 code here..
            var bd:BitmapData = new BitmapData (465, 465);
            addChild (new Bitmap (bd)); bd.lock ();
            // let's try to modify this code to work with ellipses
            // http://www.anderswallin.net/2009/05/uniform-random-points-in-a-circle-using-polar-coordinates/
            var cx:Number = 465/2, cy:Number = 465/2, a:Number = 200, b:Number = 100;
            for (var i:int = 0; i < 12345; i++) {
                var angle:Number = 2 * Math.PI * Math.random ();
                var r:Number = Math.sqrt (Math.random ());
                var dx:Number = a * r * Math.sin (angle);
                var dy:Number = b * r * Math.cos (angle);
                bd.setPixel (cx + dx, cy + dy, 0xFFFF0000);
            }
            bd.unlock ();
        }
    }
}
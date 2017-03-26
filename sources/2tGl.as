package  {
    
    import flash.display.*;
    import flash.geom.Rectangle;
    import frocessing.color.ColorHSV;
    
    public class Butterfly extends Sprite {
        
        public function Butterfly() {
            var i:int, n:int, ax:Number, ay:Number, bx:Number, by:Number, cx:Number, cy:Number, pixels:Vector.<uint> = Vector.<uint>([]);
            for (i = 0; i < 216225; i++) {
                ay = -1.6 + 3 / 465 * (i % 465);
                ax = -1.0 + 2 / 465 * (i / 465 | 0);
                bx = by = 0.2;
                for (n = 30;  n > 0 && bx * bx + by * by < 5; n--) {
                    cx = bx * bx - by * by + ax * bx / by;
                    cy = 1.7 * bx * by + ay;
                    bx = cx, by = cy;
                }
                pixels[i] = n? new ColorHSV(40, 1, 1 - n / 30).value : 0xFFFFDD;
            }
            addChild(new Bitmap(new BitmapData(465, 465, false)))["bitmapData"].setVector(new Rectangle(0, 0, 465, 465), pixels);
        }
        
    }

}
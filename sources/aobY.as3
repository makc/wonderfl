package {
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.geom.ColorTransform;

    public class Clouds extends Sprite {
        public function Clouds() {

            var bmd:BitmapData = new BitmapData(64, 64, false);
            var bm:Bitmap = new Bitmap(bmd);
            bm.rotationX = bm.scaleX = bm.scaleY = 55;
            bm.x = -1400;
            addChild(bm);

            var offset:Array = [new Point(), new Point()];
            var col:ColorTransform = new ColorTransform(0.5,0.5,0.5,1,128,128,192);

            addEventListener("enterFrame", function():void {
                offset[0].x+=0.2;
                offset[1].y+=1;

                bmd.perlinNoise(8, 16, 6, 
                    0, true, true,
                    0, true, offset);
                bmd.colorTransform(bmd.rect, col);
            });
       }
    }
}
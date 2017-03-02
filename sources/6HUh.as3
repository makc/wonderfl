// forked from yonatan's forked from: flash on 2011-6-15
// forked from 9re's flash on 2011-6-15
package {
    import flash.text.TextField;
    import flash.utils.setInterval;
    import flash.geom.ColorTransform;
    import flash.display.*;
    import flash.system.Capabilities;
    public class FlashTest extends Sprite {
        public function FlashTest() {
            var bd1:BitmapData = new BitmapData(1,1,true,0xffffffff);
            var bd2:BitmapData = new BitmapData(4,4,true,0xffffffff);
            var bmp1:Bitmap = new Bitmap(bd1);
            var bmp2:Bitmap = new Bitmap(bd2);
            addChild(bmp1);
            addChild(bmp2);
            bmp1.y = bmp2.y = bmp2.x = 100;
            bmp1.width = bmp1.height = 90;
            bmp2.width = bmp2.height = 90*4;
            bd1.setPixel32(0,0,0xff0000ff);
            bd2.setPixel32(0,0,0xff0000ff);
            var ctx:ColorTransform = new ColorTransform;
            ctx.blueOffset = -1;
            var tf:TextField = new TextField;
            tf.width = tf.height = 465;
            addChild(tf);
            
            
            setInterval(function ():void {
                bd1.colorTransform(bd1.rect, ctx);
                bd2.colorTransform(bd2.rect, ctx);
                tf.text = Capabilities.version + "\n"
                        + "bd1: " + bd1.getPixel32(0, 0).toString(16) + "\n"
                        + "bd2: " + bd2.getPixel32(0, 0).toString(16);
            }, 500);

        }
    }
}
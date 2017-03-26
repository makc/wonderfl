package {
    import flash.text.TextField;
    import flash.utils.setInterval;
    import flash.geom.ColorTransform;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    public class FlashTest extends Sprite {
        public function FlashTest() {
            var bd:BitmapData = new BitmapData(1,1);
            bd.setPixel(0,0,0xff);
            var ctx:ColorTransform = new ColorTransform;
            ctx.blueOffset = -1;
            var tf:TextField = new TextField;
            tf.width = tf.height = 465;
            addChild(tf);
            
            
            setInterval(function ():void {
                bd.colorTransform(bd.rect, ctx);
                tf.text = bd.getPixel(0, 0).toString(16);
            }, 100);

        }
    }
}
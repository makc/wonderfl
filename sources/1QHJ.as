// forked from shohei909's Mountain
//mountain 日本画風の山を描く


package {
    import flash.display.*;
    import mx.utils.ColorUtil;
    import flash.geom.*;
    public class FlashTest extends Sprite {
        public function FlashTest() {
            var map:BitmapData =  new BitmapData(465,701,false,0x000000);
            addChild( new Bitmap(map) );
            map.perlinNoise(256,256,7,Math.random()*100,false,true,4,true);
            for(var i:int=0;i<465;i++){
                for(var j:int=300;j<700;j++){
                    var l:uint = map.getPixel(i,j)/0x010101;
                    var color:uint = ColorUtil.adjustBrightness2(0xDDDDDD, Math.sin(Math.atan( (map.getPixel(i,j)-map.getPixel(i,j+20))/0x50000 ))*50-50);
                    map.fillRect(new Rectangle(i,j-l,1,l),color);
                }
            }
        }
    }
}
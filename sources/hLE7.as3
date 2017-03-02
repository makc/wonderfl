//mountain ただ山を描くくだけ,18行のコード

package {
    import flash.display.*;
    import flash.geom.*;
    public class FlashTest extends Sprite {
        public function FlashTest() {
            var map:BitmapData =  new BitmapData(465,801,false,0x000000);
            addChild( new Bitmap(map) );
            map.perlinNoise(256,256,9,Math.random()*100,false,true,4);
            for(var i:int=0;i<465;i++){
                for(var j:int=300;j<800;j++){
                    var rate:Number = Math.sin( Math.atan2(  map.getPixel(i,j-1)-map.getPixel(i,j)+3 , 10 ) );
                    var color:uint = ((0xA0 * rate) << 16) +  ((0xB0 * rate) << 8) + ((0x95 * rate) << 0);
                    map.fillRect(new Rectangle(i,j-map.getPixel(i,j),1,map.getPixel(i,j)),color);
                }
            }
        }
    }
}
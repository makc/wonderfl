// forked from TheCoolMuseum's forked from: ByteArrayを使用したビットマップ塗りつぶしのテスト
// forked from TheCoolMuseum's ByteArrayを使用したビットマップ塗りつぶしのテスト
// forked from TheCoolMuseum's flash on 2009-7-12
// ByteArrayを使用したビットマップ塗りつぶしのテスト
package {
    import flash.display.*;
    import flash.geom.*;
    import flash.utils.*;
    
    public class FlashTest extends Sprite {
        private var iWidth:int = 480;
        private var iHeight:int = 480;
        
        public function FlashTest() {
              var nrmMap:BitmapData = new BitmapData(iWidth, iHeight, true);
              var img:ByteArray = new ByteArray();
             
              
              for(var y:int=0; y<iHeight; y++){
                  var pos:int = y*iWidth*4;
                  for(var x:int=0; x<iWidth; x++){
                      var nrm:Vector3D = new Vector3D(x/iWidth*2-1,y/iHeight*2-1,0,0);
                      var len:Number = nrm.length;
                      if(len > 1){
                          nrm.z = 0;
                          nrm.normalize();
                      }else{
                          nrm.z = Math.sin(Math.acos(len));
                      }
                      img[pos] = 0xff;
                      img[pos+1] = uint(colorLimit((nrm.x+1)*127));
                      img[pos+2] = uint(colorLimit((nrm.y+1)*127));
                      img[pos+3] = uint(colorLimit((nrm.z+1)*127));
                      pos+=4;
                  }
              }
              nrmMap.setPixels(nrmMap.rect, img);
 
              addChild(new Bitmap(nrmMap));
        }
        private function colorLimit(n:Number):Number{
            n = Math.min(n, 255);
            n = Math.max(n, 0);
            return n;
        }
 
    }
}
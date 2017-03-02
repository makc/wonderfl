// forked from TheCoolMuseum's 法線マップ作成テスト
// forked from TheCoolMuseum's forked from: ByteArrayを使用したビットマップ塗りつぶしのテスト
// forked from TheCoolMuseum's ByteArrayを使用したビットマップ塗りつぶしのテスト
// forked from TheCoolMuseum's flash on 2009-7-12
// ByteArrayを使用したビットマップ塗りつぶしのテスト
package {
    import flash.display.*;
    import flash.geom.*;
    import flash.utils.*;
    import flash.events.*;
    
    public class FlashTest extends Sprite {
        private var iWidth:int;
        private var iHeight:int;
        private var frameBuffer:BitmapData;
        private var nrmMap:BitmapData;
        
        public function FlashTest() {
            iWidth = stage.stageWidth;
            iHeight = stage.stageHeight;
            frameBuffer = new BitmapData(iWidth, iHeight, true);
            nrmMap = new BitmapData(iWidth, iHeight, true);
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
 
            addChild(new Bitmap(frameBuffer));
            stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
        }
        private function colorLimit(n:Number):Number{
            n = Math.min(n, 255);
            n = Math.max(n, 0);
            return n;
        }
        private function mouseMove(e:MouseEvent):void{
            var frameImg:ByteArray = new ByteArray();

            var ray:Vector3D = new Vector3D();
            ray.x = mouseX/iWidth*2-1;
            ray.y = mouseY/iHeight*2-1;
            var len:Number = ray.length;
            if(len>1){
                ray.z = 0;
            }else{
                ray.z = Math.sin(Math.acos(len));
            }
            ray.normalize();
             for(var y:int=0; y<iHeight; y++){
                var pos:int = y*iWidth*4;
                for(var x:int=0; x<iWidth; x++){
                    var mapValue:uint = nrmMap.getPixel32(x,y);
                    var nrm:Vector3D = new Vector3D();
                    nrm.x = ((mapValue>>16)&0xff)/128-1;
                    nrm.y = ((mapValue>> 8)&0xff)/128-1;
                    nrm.z = ((mapValue    )&0xff)/128-1;
                    nrm.normalize();
                    var diffuse:Number = nrm.dotProduct(ray);
                    diffuse = Math.max(diffuse, 0);
                    frameImg[pos] = 0xff;
                    frameImg[pos+1] = uint(diffuse*256);
                    frameImg[pos+2] = uint(diffuse*256);
                    frameImg[pos+3] = uint(diffuse*256);
                    pos+=4;
                }
            }
            frameBuffer.setPixels(frameBuffer.rect, frameImg);
               
        }
    }
}
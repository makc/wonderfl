// forked from TheCoolMuseum's 法線マップテスト
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
        
        public function FlashTest() {
            iWidth = stage.stageWidth;
            iHeight = stage.stageHeight;
            frameBuffer = new BitmapData(iWidth, iHeight, true);
            
            _n = new Array(iWidth * iHeight);
             for(var y:int=0; y<iHeight; y++){
                var pos:int = y*iWidth;
                for(var x:int=0; x<iWidth; x++){
                    var nrm:Vector3D = new Vector3D(x/iWidth*2-1,y/iHeight*2-1,0,0);
                    var len:Number = nrm.length;
                    if(len > 1){
                        nrm.z = 0;
                    }else{
                        nrm.z = Math.sin(Math.acos(len));
                    }
                    nrm.normalize();
                    _n[pos] = nrm;
                    pos++;
                }
            }
 
            addChild(new Bitmap(frameBuffer));
            stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
        }

        private var _n : Array;
        
            private var frameImg:ByteArray = new ByteArray();
        private function mouseMove(e:MouseEvent):void{

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
            frameImg.position = 0;
             for(var y:int=0; y<iHeight; y++){
                var pos:int = y*iWidth*4;
                for(var x:int=0; x<iWidth; x++){
                    var v : Vector3D = _n[y*iWidth+x]; 

                    var diffuse : int = (v.x * ray.x + v.y * ray.y + v.z * ray.z) * 255;
                    if(diffuse <= 0)diffuse = 0;
                    frameImg[pos] = 0xff;
                    frameImg[pos+1] = diffuse;
                    frameImg[pos+2] = diffuse;
                    frameImg[pos+3] = diffuse;
                    pos+=4;
                }
            }
            
            frameBuffer.setPixels(frameBuffer.rect, frameImg);
               
        }
    }
}
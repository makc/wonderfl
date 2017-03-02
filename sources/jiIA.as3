// forked from uwi's 法線マップテストをちょっと高速化
// forked from TheCoolMuseum's 法線マップテスト
// forked from TheCoolMuseum's 法線マップ作成テスト
// forked from TheCoolMuseum's forked from: ByteArrayを使用したビットマップ塗りつぶしのテスト
// forked from TheCoolMuseum's ByteArrayを使用したビットマップ塗りつぶしのテスト
// forked from TheCoolMuseum's flash on 2009-7-12
package {
    import flash.display.*;
    import flash.geom.*;
    import flash.utils.*;
    import flash.events.*;
    import flash.net.*;
    import flash.text.*;
    import flash.system.*;
    
    public class FlashTest extends Sprite {
        private var iWidth:int;
        private var iHeight:int;
        private var _n : Array;
        private var frameImg:ByteArray = new ByteArray();
        private var frameBuffer:BitmapData;
        private var loader:Loader;
        
        public function FlashTest() {
            Security.loadPolicyFile("http://assets.wonderfl.net/crossdomain.xml");
            
            loader = new Loader();    
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, init);
            loader.load(new URLRequest("http://assets.wonderfl.net/images/related_images/a/aa/aab5/aab53a762223f3fe30fa6c6ca73f49d2f593444b"));
            //addChild(loader);
           
        }
        private function init(e:Event):void {
            var label:TextField = new TextField();
            addChild(label);
            try{
                var normalMap:BitmapData = (e.target.content.bitmapData);
            }catch(e:Error){
                label.text = "" + e;
                return;
            }
            
            var normalMapArray:ByteArray = normalMap.getPixels(normalMap.rect);
            
            iWidth = normalMap.width;
            iHeight = normalMap.height;

            frameBuffer = new BitmapData(iWidth, iHeight, true);
            
            _n = new Array(iWidth * iHeight);
            for(var i:int=0; i<_n.length; i++){
                    var nrm:Vector3D = new Vector3D(
                        normalMapArray[4*i+1]/128-1,
                        -(normalMapArray[4*i+2]/128-1),
                        normalMapArray[4*i+3]/128-1,0);
                    nrm.normalize();
                    _n[i] = nrm;
            }
            var bitmap:Bitmap = new Bitmap(frameBuffer, "auto", true);
            bitmap.scaleX = stage.stageWidth/iWidth;
            bitmap.scaleY = stage.stageHeight/iHeight;
            addChild(bitmap);
            stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
        }

        private function mouseMove(e:MouseEvent):void{

            var ray:Vector3D = new Vector3D();
            ray.x = mouseX/stage.stageWidth*2-1;
            ray.y = mouseY/stage.stageHeight*2-1;
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
// forked from TheCoolMuseum's 外部ファイルを用いた法線マップテスト
// forked from uwi's 法線マップテストをちょっと高速化
// forked from TheCoolMuseum's 法線マップテスト
// forked from TheCoolMuseum's 法線マップ作成テスト
// forked from TheCoolMuseum's forked from: ByteArrayを使用したビットマップ塗りつぶしのテスト
// forked from TheCoolMuseum's ByteArrayを使用したビットマップ塗りつぶしのテスト
// forked from TheCoolMuseum's flash on 2009-7-12
package {
    import flash.display.*;
    import flash.events.*;
    import flash.filters.ColorMatrixFilter;
    import flash.geom.*;
    import flash.net.*;
    import flash.system.*;
    import flash.text.*;
    import flash.utils.*;
    
    public class FlashTest extends Sprite {
        private var frameBuffer:BitmapData;
        private var loader:Loader;
        private var colorMatrixFilter:ColorMatrixFilter;
        private var normalMap:BitmapData;
        
        public function FlashTest() {
            Security.loadPolicyFile("http://colm.jp/crossdomain.xml");
            loader = new Loader();    
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, init);
            loader.load(new URLRequest("http://colm.jp/data/faceNormal.png"));
            
            colorMatrixFilter = new ColorMatrixFilter();
        }
        
        private function init(e:Event):void {
            try{
                normalMap = Bitmap(loader.content).bitmapData;
            }catch(e:Error){
	            var label:TextField = new TextField();
	            addChild(label);
                label.text = "" + e;
                return;
            }
            frameBuffer = normalMap.clone();
            var bitmap:Bitmap = new Bitmap(frameBuffer, "auto", true);
            bitmap.width = stage.stageWidth;
            bitmap.height = stage.stageHeight;
            addChild(bitmap);
            
            stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
        }
        private function mouseMove(e:MouseEvent):void{
            var ray:Vector3D = new Vector3D();
            ray.x = mouseX / stage.stageWidth * 2 - 1;
            ray.y = 1 - mouseY / stage.stageHeight * 2;
            var len:Number = ray.length;
            if (len > 1) {
                ray.z = 0;
            } else {
                ray.z = Math.sin(Math.acos(len));
            }
            ray.normalize();
            
            colorMatrixFilter.matrix = [
                2 * ray.x, 2 * ray.y, 2 * ray.z, 0, (ray.x + ray.y + ray.z) * -0xFF,
                2 * ray.x, 2 * ray.y, 2 * ray.z, 0, (ray.x + ray.y + ray.z) * -0xFF,
                2 * ray.x, 2 * ray.y, 2 * ray.z, 0, (ray.x + ray.y + ray.z) * -0xFF,
                0,           0,           0,           1, 0
            ];
            frameBuffer.applyFilter(normalMap, normalMap.rect, new Point(), colorMatrixFilter);
            e.updateAfterEvent();
        }
    }
}
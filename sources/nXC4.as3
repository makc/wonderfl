//http://hakuhin.hp.infoseek.co.jp/main/as/raster_efc.html#RASTER_EFC_03
//上記サンプルをAS3に移植
//クリックするとフルスクリーンになるという無駄な機能付きです
//フルスクリーン時の確認したら変だったけどとりあえず放置
package {
    import flash.display.*;
    import flash.events.*;
    import flash.geom.*;
    import flash.net.URLLoader;
    import flash.net.URLRequest;
    import flash.net.URLLoaderDataFormat;
    import flash.system.Security;
    import flash.filters.ShaderFilter;
    import flash.system.LoaderContext;

    [SWF(backgroundColor="#ffffff")]

    public class ExtendBlur extends MovieClip {  
        
        private var _imgloader:Loader;
        private var _bmp:Bitmap;
        
        private var _bmd:BitmapData;
        private var _bmdBuffer:BitmapData;
        
        private var _render:Sprite;
        
        private var _rectWidth:Number;
        private var _rectHeight:Number;
        
        public function ExtendBlur(){
            Security.loadPolicyFile("http://narayama.heteml.jp/crossdomain.xml");
            //imageの取得
            _imgloader = new Loader();
            _imgloader.contentLoaderInfo.addEventListener(Event.COMPLETE,ImgLoadHandler);
            _imgloader.load(new URLRequest("http://narayama.heteml.jp/test/pixelbender/tokyo.jpg"), new LoaderContext(true));
            
            _rectWidth = stage.stageWidth;
            _rectHeight = stage.stageHeight;
            
            _bmd = new BitmapData(_rectWidth, _rectHeight, true,0x00FFFFFF);
            _bmdBuffer = new BitmapData(_rectWidth, _rectHeight, true, 0x00FFFFFF);
            
            stage.addEventListener(MouseEvent.CLICK, stageClick);
        }

        private function ImgLoadHandler(e:Event):void{
            var loaderInfo:LoaderInfo = LoaderInfo(e.currentTarget);
            var loader:Loader = loaderInfo.loader;
            var bmd:BitmapData = new BitmapData(loader.width, loader.height, true);
            bmd.draw(loader);

            _bmp = new Bitmap(bmd);
            _bmp.scaleX = _bmp.scaleY = _rectHeight / loader.height;
            _bmp.smoothing = true;

            _bmp.x = (_rectWidth/2) - ((loader.width * _bmp.scaleX)/2);
            _bmp.y = (_rectHeight/2) - ((loader.height * _bmp.scaleY) / 2);

            _render = new Sprite();
            var trans:Transform = new Transform(_render);
            var color:ColorTransform = new ColorTransform(1, 1, 1, 0.9, 0, 0, 0, 0);
            trans.colorTransform = color;

            addChild(_bmp);
            addChild(_render);

            stage.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
        }
        private function enterFrameHandler(e:Event):void {
            //バッファから描画用ビットマップに転送
            _bmd.copyPixels(_bmdBuffer, new Rectangle(0, 0, _rectWidth, _rectHeight), new Point(0, 0));
            // バッファにキャプチャー
            var m1:Matrix = new Matrix(1, 0, 0, 1, 0, 0);
            _bmdBuffer.fillRect(new Rectangle(0, 0, _rectWidth, _rectHeight), 0x00FFFFFF);
            _bmdBuffer.draw(stage, m1);
            
            var m2:Matrix = new Matrix(1, 0, 0, 1, 0, 0);
            m2.translate(-1 * stage.mouseX, -1 * stage.mouseY);
            m2.scale(1.02, 1.02);
            m2.translate(stage.mouseX, stage.mouseY);
            
            _render.graphics.clear();
            _render.graphics.beginBitmapFill(_bmd, m2, true, true);
            _render.graphics.moveTo(0, 0);
            _render.graphics.lineTo(0, _rectHeight);
            _render.graphics.lineTo(_rectWidth, _rectHeight);
            _render.graphics.lineTo(_rectWidth, 0);
            _render.graphics.endFill();
            
        }
        private function stageClick( e:MouseEvent ) :void {
            switch(stage.displayState) {
            case StageDisplayState.NORMAL:
                stage.displayState = StageDisplayState.FULL_SCREEN;
                break;
            case StageDisplayState.FULL_SCREEN:
            default:
                stage.displayState = StageDisplayState.NORMAL;
                break;
            }
        }
    }
}
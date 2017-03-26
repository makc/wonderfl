package
{
    import flash.display.*;
    import flash.events.Event;
    import flash.filters.BlurFilter;
    import flash.geom.ColorTransform;
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.net.URLRequest;
    import flash.utils.Dictionary;
    import flash.system.Security;
    import flash.system.LoaderContext;
    
    [SWF(width = "465", height = "465", backgroundColor = "0", frameRate = "60")]
    
    public class Main extends Sprite
    {
        
        private const NUM_SAKURA:int = 250;
        private const IMG_URL:String = "http://www.digifie.jp/assets/images/sakura.png";
        
        private var _loader:Loader;
        private var _canvas:BitmapData;
        private var _ctf:ColorTransform;
        
        private var _dict:Dictionary = new Dictionary(true);
        
        private var _sakura:BitmapData;
        private var _sakuraList:Vector.<Sprite> = Vector.<Sprite>([]);
        
        public function Main()
        {
            Wonderfl.capture_delay(20);
            Security.loadPolicyFile("http://www.digifie.jp/crossdomain.xml");
            loadImage(IMG_URL);
        }
        
        private function loadImage(url:String):void
        {
            var context:LoaderContext = new LoaderContext;
            context.checkPolicyFile = true;
            _loader = new Loader();
            _loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaded);
            _loader.load(new URLRequest(url), context);
        }
        
        private function onLoaded(e:Event):void
        {
            _loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoaded);
            _sakura = new BitmapData(_loader.width, _loader.height, true, 0);
            _sakura.draw(_loader);
            setup();
            addEventListener(Event.ENTER_FRAME, update);
        }
        
        private function setup():void
        {
            _canvas = new BitmapData(465, 465, false, 0);
            addChild(new Bitmap(_canvas));
            _ctf = new ColorTransform(.75, .75, .75);
            addSakura();
        }
        
        private function addSakura():void
        {
            var n:int = NUM_SAKURA;
            while(n--){
                var sak:Sprite = new Sprite();
                var bmd:BitmapData = _sakura.clone();
                var bm:Bitmap = new Bitmap(bmd);
                sak.addChild(bm);
                bm.x = -bm.width * .5;
                bm.y = -bm.height * .5;
                sak.scaleX = sak.scaleY = Math.random() * 1.2 + .3;
                sak.x = Math.random() * 300 - 200;
                sak.y = Math.random() * -500 - 100;
                sak.filters = [new BlurFilter(4, 4)];
                sak.blendMode = "add";
                _dict[sak] = {vx:3 - sak.scaleX, vy:Math.random() * sak.scaleY + 1, inix:sak.x, iniy:sak.y};
                addChild(sak);
                _sakuraList.push(sak);
            }
        }
        
        private function fall(sak:Sprite):void
        {
            sak.rotationX += Math.random() * 10; 
            sak.rotationY += Math.random() * 10;
            var vx:Number = _dict[sak].vx;
            var vy:Number = _dict[sak].vy;
            vx = vx + (180 - (sak.rotationY % 360)) * .003;
            vy = vy - (180 - (sak.rotationX % 180)) * .008;
            sak.x += vx;
            sak.y += vy;
            if(sak.x > 500) sak.x = _dict[sak].inix;
            if(sak.y > 500) sak.y = _dict[sak].iniy;
        }
        
        private function update(e:Event):void
        {
            var n:int = NUM_SAKURA;
            while(n--){
                fall(_sakuraList[n]);
            }
            _canvas.lock();
            _canvas.draw(stage);
            _canvas.applyFilter(_canvas, _canvas.rect, new Point(), new BlurFilter(16, 16));
            _canvas.colorTransform(_canvas.rect, _ctf);
            _canvas.unlock();
        }
    }
}
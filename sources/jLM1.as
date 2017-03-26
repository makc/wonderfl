package
{
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.BitmapDataChannel;
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Rectangle;
    import flash.geom.Point;
    import flash.display.Graphics;
    
    import flash.display.LoaderInfo;
    import flash.display.Loader;
    import flash.net.URLLoader;
    import flash.net.URLRequest;
    import flash.system.LoaderContext;
    import flash.system.ApplicationDomain;
    import flash.system.SecurityDomain;
    
    [SWF(width = "465", height = "465", backgroundColor = "0xffffff", frameRate = "60")]
    
    public class Main extends Sprite
    {
        private const WIDTH:Number = 465;
        private const HEIGH:Number = 465;
        private const OX:Number = 465 / 2;
        private const OY:Number = 465 / 2;
        private const DIAMETER:Number = 20;
        private const OBJ_MAX:Number = 300;
        private const V:Number = 30;
        
        private var _container:Sprite;
        private var _mask:BitmapData;
        private var _bmp:Bitmap;
        private var _sp:Sprite;
        private var _sh:Shape;
        private var first:Hexagon;
        
        private var _source:BitmapData;
        
        private var _imgLoader:Loader;
        private var _imgLoaderInfo:LoaderInfo;
            
        public function Main()
        {
            _sh = new Shape();
            _sp = new Sprite();
            _container = new Sprite();
            
            var url:String = "http://assets.wonderfl.net/images/related_images/b/b2/b264/b264bc065fedd37289d37322282f49d09934a816";
            var urlReq:URLRequest = new URLRequest(url);
            var context:LoaderContext = new LoaderContext();
            context.checkPolicyFile = true;

            _imgLoader = new Loader();
            _imgLoaderInfo = _imgLoader.contentLoaderInfo;
            _imgLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onImageloaded);
            _imgLoader.load(urlReq,context);
            init();
        }
        private function onImageloaded(e:Event):void
        {
            _source = new BitmapData(_imgLoader.width,_imgLoader.height,true);
            _source.draw(_imgLoader);
            var bmp:Bitmap = new Bitmap(_source);
            _container.addChild(bmp);
            addChild(_container);
            addChild(_sp);
            addChild(_sh);
            _container.mask = _sp;
            
            stage.addEventListener(MouseEvent.CLICK,onClick);
            stage.addEventListener(Event.ENTER_FRAME,enterframeHandler);
        }
        
        private function init():void
        {
            createHexagon(OX,OY);
        }
        private function createHexagon(px:Number,py:Number):void
        {
            first = new Hexagon();
            first.ox = px;
            first.oy = py;
            first.v = 0;
            var p:Hexagon = first;
            
            for(var i:uint = 0;i < OBJ_MAX;i++){
                p.next = new Hexagon();
                var gp:Hexagon = first;
                while(1){
                    var ran:uint = Math.floor(Math.random() * 6);
                    if(!gp.link[ran]){
                        var ang:Number = Math.PI/180 * (60 * ran);
                        p.next.ox = gp.ox + DIAMETER * Math.cos(ang);
                        p.next.oy = gp.oy + DIAMETER * Math.sin(ang);
                        checkLink(p.next);
                        
                        break;
                    }else{
                        gp = gp.link[ran];
                    }
                }
                p.next.v = Math.random() * - 20 +  (-10 * i);
                p = p.next;
            }
        }
        //リンクセット
        private function checkLink(cp:Hexagon):void
        {
            for(var i:uint = 0;i < 6;i++){
                var ang:Number = Math.PI/180 * (60 * i);
                var cx:Number = cp.ox + DIAMETER * Math.cos(ang);
                var cy:Number = cp.oy + DIAMETER * Math.sin(ang);
                var p:Hexagon = first;
                while(p.next){
                    if(cx < p.ox + 2 && cx > p.ox - 2 && cy < p.oy + 2 && cy > p.oy - 2){
                        cp.link[i] = p;
                        p.link[(i+3)%6] = cp;
                    }
                    p = p.next;
                }
            }
        }
        
        private function enterframeHandler(e:Event):void
        {
            update();
        }
        
        private function onClick(e:MouseEvent):void
        {
            createHexagon(mouseX,mouseY);
        }
        
        private function update():void {
            var g:Graphics = _sh.graphics;
            var sg:Graphics = _sp.graphics;
            var p:Hexagon = first;
            var cnt:uint = 0;
            
            _sh.x = (mouseX - OX) / 100;
            _sh.y = (mouseY - OY) / 100;
            _sp.x = (mouseX - OX) / 100;
            _sp.y = (mouseY - OY) / 100;
            _container.x = -(mouseX - OX) / 100;
            _container.y = -(mouseY - OY) / 100;
            
            sg.clear();
            g.clear();
            g.lineStyle(1,0x000000);
            while(p){
                if(p.v < 610) p.v+=V;
                if(p.v >= 0){
                    if(p.v >= 600){
                        g.beginFill(0xFFFFFF,p.a/100 - (Math.random()));
                        if(p.a > 0) p.a-=5;
                        sg.beginFill(0xAAFFAA,0.1);
                    }
                    var bx:Number = 0;
                    var by:Number = 0;
                    for(var i:Number = 0;i <= 6;i++){
                        var ang:Number = Math.PI/180 * (60 * i - 90);
                        var lx:Number = p.ox + DIAMETER/2 * Math.cos(ang);
                        var ly:Number = p.oy + DIAMETER/2 * Math.sin(ang);
                        if(i == 0){
                            g.moveTo(lx,ly);
                            sg.moveTo(lx,ly);
                            bx = lx;
                            by = ly;
                        }else{
                            if(i*100 <= p.v){
                                g.lineTo(lx,ly);
                                if(p.v >= 600) sg.lineTo(lx,ly);
                                bx = lx;
                                by = ly;
                            }
                            if(i*100 > p.v && (i-1)*100 <= p.v){
                                g.lineTo(bx + (lx - bx) * (p.v%100)/100 , by + (ly - by) * (p.v%100)/100);
                            }
                        }
                    }
                    g.endFill();
                }
                p = p.next;
                cnt++;
            }
        }
    }
}

class Hexagon
{
    public var ox:Number;
    public var oy:Number;
    
    public var v:Number = 0;
    public var a:Number = 100;
    public var link:Array;
    public var next:Hexagon;
    
    public function Hexagon()
    {
        this.link = [];
    }
    
}

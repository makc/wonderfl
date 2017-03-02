package
{
    import flash.display.Loader;
    import flash.display.LoaderInfo;
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.BlendMode;
    import flash.display.PixelSnapping;
    import flash.display.Sprite;
    import flash.display.Shape;
    import flash.display.Graphics;
    import flash.events.IOErrorEvent;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.filters.BlurFilter;
    import flash.net.URLRequest;
    import flash.system.LoaderContext;
    
    import flash.geom.ColorTransform;
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    
    [SWF(width = "465", height = "465", backgroundColor = "0xFFFFFF", frameRate = "30")]
    
    public class OutlineTrace extends Sprite
    {
        private const WIDTH:Number = 465;
        private const HEIGH:Number = 465;
        
        private var _canvas:BitmapData;
        private var _glow:BitmapData;
        private var _rect:Rectangle;
        private var _cTra:ColorTransform;
        
        private var _shape:Shape;
        private var _pS:Points;
        
        private var _sX:uint;
        private var _sY:uint;
        private var _sMaxX:uint = 0;
        private var _sMaxY:uint = 0;
        private var _sP:Points;
        
        private var _OL:Array;
        private var _i:uint = 0;
        
        private var _color:uint;
        
        private var _imgLoader:Loader;
        private var _imgLoaderInfo:LoaderInfo;
        
        public function OutlineTrace()
        {
            init();
        }
        
        private function init():void
        {
            loadImage(); //画像読込み
            
            _rect = new Rectangle(0, 0, WIDTH, HEIGH);
            _cTra = new ColorTransform(.8, .8, .9, .8);
            
            _glow = new BitmapData(WIDTH/2, HEIGH/2, false, 0x0);
            var bm:Bitmap = addChild(new Bitmap(_glow, PixelSnapping.NEVER, true)) as Bitmap;
            bm.scaleX = bm.scaleY = 2;
            bm.blendMode = BlendMode.ADD;
            
            _shape = new Shape();
            _color = Math.random()*0xffffff;
        }
        
        public function loadImage():void
        {
            _imgLoader = new Loader();
            _imgLoaderInfo = _imgLoader.contentLoaderInfo;
            _imgLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onImageloaded);
            _imgLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onErr);
            var urlReq:URLRequest = new URLRequest("http://nyarineko.jp/common/img/og.jpg");
            
            _imgLoader.load(urlReq,new LoaderContext(true));
        }
        private function onImageloaded(e:Event):void
        {
            _imgLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onImageloaded);
            _canvas = new BitmapData(WIDTH, HEIGH, false, 0xFFFFFF);
            _canvas.draw(_imgLoader,new Matrix(1,0,0,1,(stage.stageWidth - _imgLoader.width)/2,(stage.stageHeight - _imgLoader.height)/2));
            addChild(new Bitmap(_canvas)) as Bitmap;
            
            getOutline(); //輪郭抽出
        }
        private function onErr(e:Event):void
        {
            //エラー
        }
        
        private function getOutline():void
        {
            var px:Number = 100;
            var py:Number = 100;
            var chkFlg:Boolean = false;
            var flg:Boolean = false;
            _OL = [];
            while(py < HEIGH - 100){
                if(_canvas.getPixel(px,py) < 0xCCCCCC){
                    if(!chkFlg){
                        for each(var o:* in _OL){
                            
                            while(o){
                                if(px == o.px && py == o.py){
                                    flg = true;
                                    break;
                                }
                                if(flg) continue;
                                o = o.next;
                            }
                        }
                        if(!flg){
                            _OL.push(traceOutline(px,py));
                            px = _sMaxX;
                            py = _sMaxY;
                            _sMaxX = _sMaxY = 0;
                        }
                        chkFlg = true;
                    }
                }else{
                    chkFlg = false;
                }
                
                if(px >= WIDTH - 70){
                    px = 70;
                    py+=1;
                }else{
                    px+=1;
                }
            }
            
            _sP = _OL[0];
            _shape.graphics.moveTo(_sP.px,_sP.py);
            addEventListener(Event.ENTER_FRAME, enterframeHandler);
        }
        private function traceOutline(x:Number,y:Number):Points
        {
            var px:Number = x;
            var py:Number = y;
            
            _sP = new Points();
            _sP.px = _sX = px;
            _sP.py = _sY = py;
            
            var p:Points;
            p = _sP;
            
            var vec:uint = 0;
            var buf:uint = 0;
            var cnt:uint = 0;
            while(cnt < 2000){
                cnt++;
                buf = (vec + 6)%8;
                while(buf != (vec%8)){
                    switch(vec%8){
                        case 0: //左上
                            px = p.px - 1;
                            py = p.py - 1;
                            break;
                        case 1: //左
                            px = p.px - 1;
                            py = p.py;
                            break;
                        case 2: //左下
                            px = p.px - 1;
                            py = p.py + 1;
                            break;
                        case 3: //下
                            px = p.px;
                            py = p.py + 1;
                            break;
                        case 4: //右下
                            px = p.px + 1;
                            py = p.py + 1;
                            break;
                        case 5: //右
                            px = p.px + 1;
                            py = p.py;
                            break;
                        case 6: //右上
                            px = p.px + 1;
                            py = p.py - 1;
                            break;
                        case 7: //上
                            px = p.px;
                            py = p.py - 1;
                            break;
                    }
                    if(_canvas.getPixel(px,py) < 0xCCCCCC){
                        switch(vec%8){
                            case 1:
                            case 2:
                                vec = 0;
                                break;
                            case 3:
                            case 4:
                                vec = 2;
                                break;
                            case 5:
                            case 6:
                                vec = 4;
                                break;
                            case 0:
                            case 7:
                                vec = 6;
                                break;
                        }
                        break;
                    }
                    vec++;
                    vec %= 8;
                }
                trace("_sX:_sY="+_sX + ":" + _sY + "[px:py=" + px + ":" + py + "]");
                if(_sX != px || _sY != py){
                    p.next = new Points();
                    p = p.next;
                    p.px = px;
                    p.py = py;
                    if(_sMaxX < px) _sMaxX = px;
                    if(_sMaxY < py) _sMaxY = py;
                }else{
                    break;
                }
            }
            trace(_OL.length);
            
            return _sP;
        }
        
        private function enterframeHandler(e:Event):void
        {
            draw();
        }
        
        private function draw():void
        {
            _canvas.lock();
            _canvas.applyFilter(_canvas, _rect, new Point(), new BlurFilter(16, 16));
            _canvas.colorTransform(_rect, _cTra);
            _shape.graphics.clear();
            _shape.graphics.lineStyle(2,0x00CCFF,0.2);
            
            var i:Number = Math.floor(Math.random()*20+5);
            while(i--){
                next(1);
                _shape.graphics.moveTo(mouseX,mouseY);
                _shape.graphics.lineTo(_sP.px,_sP.py);
            }
            for each(var o:* in _OL){
                while(o){
                    if(o.al > 0){
                        _canvas.setPixel(o.px,o.py, _color );
                    }else{
                        _canvas.setPixel(o.px,o.py, 0x000000 );
                    }
                    o = o.next;
                }
            }
            _canvas.draw(_shape);
            _canvas.unlock();
            _glow.draw(_canvas, new Matrix(0.5, 0, 0, 0.5));
            
        }
        
        private function next(ran:Number):void
        {
            while(ran--){
                _sP.al = (_sP.al == 0)? 1:0;
                if(_sP.next){
                    _sP = _sP.next;
                }else{
                    _i++;
                    if(_i >= _OL.length){
                        _i = 0;
                        if(_OL[0].al == 0) _color = Math.random()*0xffffff;
                    }
                    _sP = _OL[_i];
                    _shape.graphics.moveTo(_sP.px,_sP.py);
                }
            }
        }
        
    }
}

class Points
{
    public var px:uint;
    public var py:uint;
    public var al:Number = 0;
    public var next:Points;
    
    public function Points():void
    {
        
    }
}

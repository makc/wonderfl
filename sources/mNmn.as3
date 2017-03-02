package
{
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Rectangle;
    
    [SWF(width = "465", height = "465", backgroundColor = "0xFFFFFF", frameRate = "60")]
    
    public class Main extends Sprite
    {
        private const M_WIDTH:Number = 700;
        private const M_HEIGH:Number = 700;
        
        private var _canvas:BitmapData;
        private var _bmp:Bitmap;
        
        private var _objArray:Array;
        private var flg:Boolean = false;
        private var time:Number = 0;
        private var _sp:Sprite;
          
        //------------------------------------------------------
        //コンストラクタ
        //------------------------------------------------------
        public function Main()
        {
            _sp = new Sprite();
            _canvas = new BitmapData(M_WIDTH, M_HEIGH, true, 0x99FFFFFF);
            _bmp = new Bitmap(_canvas);
            _bmp.smoothing = true;
            _bmp.x = -M_WIDTH / 2;
            _bmp.y = -M_HEIGH / 2;
            _sp.addChild(_bmp);
            _sp.x = M_WIDTH / 2-110;
            _sp.y = M_HEIGH / 2-110;
            addChild(_sp);
            
            init();
            stage.addEventListener(MouseEvent.CLICK,onClick);
            stage.addEventListener(Event.ENTER_FRAME,enterframeHandler);
        }
        
        //------------------------------------------------------
        //初期化
        //------------------------------------------------------
        private function init():void
        {
            time = 0;
            _sp.rotation = Math.random()*360;
            _objArray = [];
            //パーティクルを初期化
            for(var i:uint = 0;i < 700;i+=50){
                for(var j:uint = 0;j < 700;j+=50){
                    var p:Particle = new Particle();
                    p.x = j;
                    p.y = i;
                    p.width = 50;
                    p.height = 50;
                    sliceObject(p);
                }
            }
            var m:Number = _objArray.length;
            for(var k:uint = 0;k < _objArray.length;k++){
                if(k < m/2){
                    _objArray[k].delay = (m/2 - k)/2 + (Math.random() * 50 - 25);
                }else{
                    _objArray[k].delay = (k - m/2)/2 + (Math.random() * 50 - 25);
                }
                if(Math.floor(p.y/50) % 2 == 0) p.y += 50;
                trace(_objArray[k].delay);
            }
        }
        
        private function sliceObject(p:Particle):void
        {
            if(p.width <= 10 || p.height <= 10 || Math.random() < 0.1){
                _objArray.push(p);
                return;
            }
            var r:Number = Math.random();
            var np:Particle = new Particle();
            if((r < 0.5 && p.width == p.height) || p.width > p.height){
                np.x = p.x+p.width/2;
                np.y = p.y;
                p.width /= 2;
            }else{
                np.x = p.x;
                np.y = p.y+p.height/2;
                p.height /= 2;
            }
            np.width = p.width;
            np.height = p.height;
            if(Math.random() < 0.5){
                _objArray.push(np);
                sliceObject(p);
            }else{
                _objArray.push(p);
                sliceObject(np);
            }
        }
        
        private function enterframeHandler(e:Event):void
        {
            update();
        }
        
        private function onClick(e:MouseEvent):void
        {
            flg = !flg;
            init();
        }
        
        //フレーム処理：描画
        private function update():void {
            /*if(flg)*/time++;
            _canvas.lock();
            _canvas.fillRect(new Rectangle(0, 0, 700, 700), 0xFFFFFF);
            var sh:Shape = new Shape();
            sh.graphics.beginFill(0x000000);
            for each(var p:Particle in _objArray){
                if(p.sc == 0) continue;
                sh.graphics.drawRect(p.x+((1-p.sc)*(p.width/2)),p.y+((1-p.sc)*(p.height/2)),p.width*p.sc,p.height*p.sc);
                sh.x = p.x;
                sh.y = p.y;
                if(p.delay < time) p.sc /= 1.05;
                if(p.sc < 0.05) p.sc = 0;
            }
            sh.graphics.endFill();
            _canvas.draw(sh);
            sh = null;
            _canvas.unlock();
        }
    }
}

class Particle
{
    public var x:Number;
    public var y:Number;
    public var width:Number;
    public var height:Number;
    
    public var sc:Number;
    public var delay:Number;
    
    public function Particle()
    {
        sc = 1;
        delay = 0;
    }
}
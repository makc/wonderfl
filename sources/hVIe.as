package
{
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    
    [SWF(width = "465", height = "465", backgroundColor = "0xFF0000", frameRate = "30")]
    
    public class Main extends Sprite
    {
        private const WIDTH:Number = 465;
        private const HEIGH:Number = 465;
        private var _canvas:BitmapData;
        
        //------------------------------------------------------
        //コンストラクタ
        //------------------------------------------------------
        public function Main()
        {
            init();
        }
        
        //------------------------------------------------------
        //初期化
        //------------------------------------------------------
        private function init():void
        {
            _canvas = new BitmapData(WIDTH, HEIGH, false, 0xAA0000);
            addChild(new Bitmap(_canvas)) as Bitmap;
            
            this.stage.addEventListener(MouseEvent.MOUSE_MOVE, moveEvent);
        }
        
        //------------------------------------------------------
        //マウス移動
        //------------------------------------------------------
        private function moveEvent(e:MouseEvent):void
        {
            if(e.buttonDown) update();
        }
        
        //マウス移動：描画
        private function update():void {
            _canvas.lock();
            drawPocky();
            _canvas.unlock();
        }
        
        //ポッキー！！
        private var ang:Number = -30;
        private var a:Number = 5;
        private function drawPocky():void
        {
            var p:Pocky = new Pocky();
            //p.rotationX = Math.random()*60-30;
            if(ang > 30) a = -5;
            if(ang < -30) a = 5;
            ang += a;
            p.rotationZ = ang + Math.random() * 4 - 2;
            p.x = mouseX;
            p.y = mouseY;
            var sp:Sprite = new Sprite();
            sp.addChild(p);
            _canvas.draw(sp);
        }
    }
}

import flash.display.Sprite;
import flash.geom.Matrix;
import flash.display.GradientType;

class Pocky extends Sprite
{
    public function Pocky():void
    {
        var d = 1.0 / 1638.4;
        var ran = Math.random()*20;
        var m : Matrix = new Matrix();
        m.identity();
        m.scale(d * 10 , d * 400);
        graphics.beginGradientFill(
            GradientType.LINEAR,
            [0x663300 , 0x221100 , 0x663300],
            [     1.0 ,      1.0 ,      1.0],
            [       0 ,      127 ,      255],
            m
        );
        graphics.drawRoundRect(0,-120+ran,10,350,10,10);
        graphics.endFill();
        graphics.beginGradientFill(
            GradientType.LINEAR,
            [0xeedd33 , 0xaa6633 , 0xeedd55],
            [     1.0 ,      1.0 ,      1.0],
            [       0 ,      187 ,      255],
            m
        );
        graphics.drawRoundRect(0,-170+ran,10,60,10,10);
    }
}
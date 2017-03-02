/*
比較的簡単に実装できそうな方法で
稲妻というか放電風のビリビリを作ってみました。

マウスクリックでビリビリの出現点が変化します。
*/

package {    
    import flash.display.BitmapData;
    import flash.display.Bitmap;
    import flash.events.Event;
    import flash.geom.Point;
    import flash.display.Sprite;
    import flash.geom.ColorTransform;
    import flash.geom.Matrix;
    import flash.filters.GlowFilter;
    import flash.events.MouseEvent;
    
    [SWF(width="465", height="465", backgroundColor="0", frameRate="30")]
    
    public class Main extends Sprite{
        private const W:Number = 465;
        private const H:Number = 465;
        private const RANGE:int = 5;
        private var _p:Point;
        private var _sp:Sprite;
        private var _ctf:ColorTransform;
        private var _canvas:BitmapData;
        private var _glow:BitmapData;

        public function Main() {
            init();
            addEventListener(Event.ENTER_FRAME, update)    ;
            stage.addEventListener(MouseEvent.CLICK, onDown);
        }
        
        private function init():void{
            _p = new Point(W / 2, 30);
            _sp = new Sprite();
            _sp.filters = [new GlowFilter(0xC9E6FC, 1, 10, 10, 4, 3, false, false)];
            _ctf = new ColorTransform(0.9, 0.96, 1, 0.9);
            _canvas = new BitmapData(W,H,false,0);
            
            var bm:Bitmap = new Bitmap(_canvas, "auto", true);
            _glow = new BitmapData(W / RANGE, H / RANGE, false, 0);
            
            var glowBm:Bitmap = new Bitmap(_glow, "never", true);
            glowBm.blendMode = "add";
            glowBm.scaleX = glowBm.scaleY = RANGE;
            
            addChild(bm);
            addChild(glowBm);
        }
        
        private function onDown(e:MouseEvent):void{
            _p = new Point(mouseX, mouseY);
        }
                
        private function update(e:Event):void{
            var p:Point = new Point();
            var num:int = Math.random() * 5;
            p.x = _p.x;
            p.y = _p.y;
            _sp.graphics.clear();
            _sp.graphics.lineStyle(num, 0xFFFFFF, 1-(num / 10));
            _sp.graphics.moveTo(p.x, p.y);
            var i:int = p.y;
            while(i < W){
                var n:int = Math.random() * 10;
                i += n;
                p.y = i;
                p.x += Math.random() * (n * 2) - n;
                _sp.graphics.lineTo(p.x, p.y);
            }
            _canvas.colorTransform(_canvas.rect, _ctf);
            _canvas.draw(_sp);
            _glow.draw(_canvas, new Matrix(1 / RANGE, 0, 0, 1 / RANGE));
        }
    }
}
// forked from toyoshim's マンデルブロ高速化
// forked from toyoshim's マンデルブロ @ Frocessing
package {
    import flash.display.*;
    import flash.text.*;
    import flash.events.*;
    import frocessing.color.ColorHSV;
    import net.hires.debug.Stats;

    [SWF(width="465", height="465", frameRate="30", backgroundColor="0x00000000")]
    public class Mandelbrot extends Sprite {
        private var bmp:Bitmap;
        private var img:BitmapData;
        private var txt:TextField;
        
        private var offset_x:Number = 150.0;
        private var offset_y:Number = 0.0;
        private var zoom:Number = 0.6;

        public function Mandelbrot() {
            // width x height, no transparent, ARGB=0x00000000
            img = new BitmapData(stage.stageWidth, stage.stageHeight, false, 0);
            bmp = new Bitmap(img);
            stage.addChild(bmp);
            
            // draw initial image
            draw();
            
            // add mouse event listener
            stage.addEventListener(MouseEvent.CLICK, onClick);

            // add debug status window
            stage.addChild(new Stats());
        }

        public function onClick(event:MouseEvent):void {
            offset_x = (offset_x + stage.mouseX - img.width / 2.0)
                        / zoom;
            offset_y = (offset_y + stage.mouseY - img.height / 2.0)
                        / zoom;
            zoom *= 1.2;
            offset_x *= zoom;
            offset_y *= zoom;
            draw();
        }
        
        private function calcDepth(x:int, y:int):int {
            var cx:Number = (x + offset_x - img.width * 2.2 / 3.0)
                        / (img.width / 2.0) / zoom;
            var cy:Number = (y + offset_y - img.height / 2.0)
                        / (img.height / 2.0) / zoom;
            var r:Number = 0.0;
            var i:Number = 0.0;
            var n:int;
            for (n = 0; n <= 36; n++) {
                var a:int = 1 - 2 * (n % 2);
                var nr:Number = r * r - i * i + a * cx;
                var ni:Number = 2.0 * r * i + a * cy;
                r = nr;
                i = ni;
                if ((r * r + i * i) > 4) break;
            }
            return 360 - n * 10;
        }
        
        private function calcColor(n:int):int {
            var hsv:ColorHSV = new ColorHSV(n, n, n);
            return hsv.value32;
        }

        private function draw():void {
            img.lock();
            for (var y:int = 0; y < img.height; y++) {
                for (var x:int = 0; x < img.width; x++) {
                    img.setPixel32(x, y, calcColor(calcDepth(x, y)));
                }
            }
            img.unlock();
        }
    }
}
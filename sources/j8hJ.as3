package {
    import frocessing.display.*;
    [SWF(width="465", height="465", frameRate="1")]
    public class FrocessingSample extends F5MovieClip2D {
        private var screen_width:int = 465;
        private var screen_height:int = 465;
        private var offset_x:Number = 0.0;
        private var offset_y:Number = 0.0;
        private var zoom:Number = 1.0;
        
        public function FrocessingSample() {
            super();
        }
        
        public function mousePressed():void {
            offset_x = (offset_x + mouseX - screen_width / 2.0)
                        / zoom;
            offset_y = (offset_y + mouseY - screen_height / 2.0)
                        / zoom;
            zoom *= 1.2;
            offset_x *= zoom;
            offset_y *= zoom;
            redraw();
        }

        public function calc_stroke(x:int, y:int):int {
            var cx:Number = (x + offset_x - screen_width * 2.2 / 3.0)
                        / (screen_width / 2.0) / zoom;
            var cy:Number = (y + offset_y - screen_height / 2.0)
                        / (screen_height / 2.0) / zoom;
            var r:Number = 0.0;
            var i:Number = 0.0;
            var n:int;
            for (n = 1; n < 32; n++) {
                var nr:Number = r * r - i * i + cx;
                var ni:Number = 2.0 * r * i + cy;
                r = nr;
                i = ni;
                if ((r * r + i * i) > 4) break;
            }
            return 256 - n * 8;
        }
        
        public function setup():void {
            size( screen_width, screen_height );
            background( 0 );
            colorMode(HSB, 255);
            noLoop();
            redraw();
        }
    
        public function draw():void {
            for (var y:int = 0; y < screen_height; y++) {
                for (var x:int = 0; x < screen_width; x++) {
                    var c:int = calc_stroke(x, y);
                    stroke(c, c, c);
                    point(x, y);
                }
            }
        }
    }    
}
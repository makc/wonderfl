package {
    import flash.display.Sprite;
    public class FlashTest extends Sprite {
        public var x1:Number, y1:Number, x2:Number, y2:Number;
        public function FlashTest() {
            // write as3 code here..
            x1 = Math.random() * 0.5 + 0.2;
            y1 = Math.random() * 0.5 + 0.2;
            addEventListener("enterFrame", loop);
        }
        public function loop(...daHoop):void{
            x2 = (mouseX - 232) / 100;
            y2 = (mouseY - 232) / 100;
            
            graphics.clear();
            
            // move your mouse here:
            var r0:Number = 0.8 * Math.sqrt (x1 * x1 + y1 * y1);
            var x0:Number = -y1, y0:Number = x1;
            
            graphics.lineStyle(1,0xFF);
            graphics.drawCircle(232 + 100*x0, 232 + 100*y0, 100*r0);
            
            x2 -= x0;
            y2 -= y0;
            var r2:Number = Math.sqrt (x2 * x2 + y2 * y2);
            var scale:Number = Math.min (r0, r2) / r2;
            x2 *= scale; x2 += x0;
            y2 *= scale; y2 += y0;
            
            graphics.lineStyle(2,0xFF0000);
            graphics.moveTo(232, 232);
            graphics.lineTo(232 + 100*x1, 232 + 100*y1);
            graphics.moveTo(232, 232);
            graphics.lineTo(232 + 100*x2, 232 + 100*y2);
            
            var x3:Number = x1 + y2, x4:Number = x2 - y1;
            var y3:Number = y1 - x2, y4:Number = y2 + x1;
            
            graphics.lineStyle(2,0xFF00);
            graphics.moveTo(232, 232);
            graphics.lineTo(232 + 100*x3, 232 + 100*y3);
            graphics.moveTo(232, 232);
            graphics.lineTo(232 + 100*x4, 232 + 100*y4);
        }
    }
}
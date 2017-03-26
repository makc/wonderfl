// forked from ahchang's forked from: forked from: forked from: とりあえずCircleを描いてみた
// forked from ahchang's forked from: forked from: とりあえずCircleを描いてみた
// forked from soundkitchen's forked from: とりあえずCircleを描いてみた
// forked from ahchang's とりあえずCircleを描いてみた
/**
* blog : http://tirirenge.undo.jp/?p=1726
*
* こちらを参考にして虹色のグラデーションできました！thx！
* http://wonderfl.kayac.com/code/2039da32bb0346bf7bd7723e75492995841be82a
**/

package
{
    import flash.display.Sprite;
    import frocessing.color.ColorHSV;
    import flash.display.Graphics;
    import flash.display.Shape;
    
    [SWF(width=465, height=465, frameRate=30, backgroundColor=0x000000)]
    
    public class CircleBasic extends Sprite
    {
        public static const NUM_CIRCLES:uint = 100;
        
        private var radius:Number;
        private var posX:Number;
        private var posY:Number;
        private var nAngle:Number;
        private var cAngle:Number;
        private var cx:Number, cy:Number;
        private var hsv:ColorHSV;
                
        public function CircleBasic()
        {
            init();
        }
        
        private function init():void
        {
            this.radius = 150;
            posX = stage.stageWidth /2;
            posY = stage.stageHeight /2;
            this.x = posX;
            this.y = posY;
            
            nAngle = Math.PI * 2 / NUM_CIRCLES;
            cAngle = 0;
                                                
            for (var i:uint=0; i<150; i++)
            {             
                cx = Math.cos(cAngle) * radius/2;
                cy = Math.sin(cAngle) * radius/2;

                hsv = new ColorHSV(0, 1, 1, 1);
                hsv.h = cAngle / Math.PI * 180;
                                
                graphics.drawCircle(cx, cy, radius);
                cAngle += nAngle;
                graphics.lineStyle(1, hsv.value, hsv.a);
            }
        }   
    }
}


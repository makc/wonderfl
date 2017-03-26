// forked from soundkitchen's forked from: とりあえずCircleを描いてみた
// forked from ahchang's とりあえずCircleを描いてみた
/**
 *　blog : http://tirirenge.undo.jp/?p=1709
**/
package {
    import flash.display.Sprite;

    [SWF(width=465, height=465, frameRate=30, backgroundColor=0xffffff)]
    
    public class CircleBasic extends Sprite {
        
        public static const NUM_CIRCLES:uint = 100;
        private var radius:Number;
        private var weight:Number;
        private var color:Number;
        private var posX:Number;
        private var posY:Number;
                
        public function CircleBasic() {
            this.radius = 100;
            posX = stage.stageWidth /2;
            posY = stage.stageHeight /2;
            init();
        }
        
        private function init():void {
            
            this.x = posX;
            this.y = posY;
             
            var nAngle:Number = Math.PI * 2 / NUM_CIRCLES;
            var cAngle:Number = 0;
            var cx:Number, cy:Number;
            
            graphics.lineStyle(0.2, 0x000000, 0.2); 
            graphics.endFill();
                        
            for (var i:uint=0; i<NUM_CIRCLES; i++) {
                cx = Math.cos(cAngle) * radius;
                cy = Math.sin(cAngle) * radius;
                graphics.drawCircle(cx, cy, radius);
                cAngle += nAngle;        
            }
            
            graphics.beginFill(0xffffff);
            graphics.drawCircle(0, 0, 70);
            graphics.endFill()
        }   
    }
}


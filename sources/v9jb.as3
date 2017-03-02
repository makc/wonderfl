// forked from ahchang's とりあえずCircleを描いてみた
/**
 *  結構近いんでないかい？
 *
 *  @see http://www.flickr.com/photos/birdbrid/3304636878/
 */
package {
    import flash.display.Sprite;

    [SWF(width=465, height=465, frameRate=30, backgroundColor=0x000000)]
    
    public class CircleBasic extends Sprite {
        public static const NUM_CIRCLES:uint = 150;
        //private var myContainer:Sprite;
        private var radius:Number;
        private var weight:Number;
        private var color:Number;
        private var posX:Number;
        private var posY:Number;
        
        public function CircleBasic() {
            //this.myContainer = myContainer;
            this.radius = 100;
            posX = stage.stageWidth /2;
            posY = stage.stageHeight /2;
            init();
        }
        
        private function init():void {
            graphics.lineStyle(1,0xffffff, .3);
            //graphics.drawCircle(0,0,radius);
            this.x = posX;
            this.y = posY;
            //myContainer.addChild(this);
            var nAngle:Number = Math.PI * 2 / NUM_CIRCLES;
            var cAngle:Number = 0;
            var cx:Number, cy:Number;

            for (var i:uint=0; i<NUM_CIRCLES; i++)
            {
                cx = Math.cos(cAngle) * radius;
                cy = Math.sin(cAngle) * radius;
                graphics.drawCircle(cx, cy, radius);

                cAngle += nAngle;
            }
        }   
    }
}


package {
    import flash.display.Sprite;
    
    public class CircleBasic extends Sprite {
        
        private var myContainer:Sprite;
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
            graphics.lineStyle(1,0xff0000);
            graphics.drawCircle(0,0,radius);
            this.x = posX;
            this.y = posY;
        }   
    }
}
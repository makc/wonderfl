package{
    import flash.display.Sprite;
    public class drawCircle3 extends Sprite {
        public function drawCircle3() {
            var centerX:Number = 100;
            var centerY:Number = 200;
            var r:Number = 50;
            
            graphics.lineStyle(2,0xff0006);
            graphics.moveTo(centerX+r, centerY);
            
            graphics.curveTo(r+centerX,Math.tan(Math.PI/8)*r+centerY,Math.sin(Math.PI/4)*r+centerX,Math.sin(Math.PI/4)*r+centerY);
            graphics.curveTo(Math.tan(Math.PI/8)*r+centerX,r+centerY,centerX,r+centerY);
            graphics.curveTo(-Math.tan(Math.PI/8)*r+centerX,r+centerY,-Math.sin(Math.PI/4)*r+centerX,Math.sin(Math.PI/4)*r+centerY);
            graphics.curveTo(-r+centerX,Math.tan(Math.PI/8)*r+centerY,-r+centerX,centerY);
            graphics.curveTo(-r+centerX,-Math.tan(Math.PI/8)*r+centerY,-Math.sin(Math.PI/4)*r+centerX,
            -Math.sin(Math.PI/4)*r+centerY);
            graphics.curveTo(Math.tan(Math.PI/8)*r+centerX,-r+centerY,Math.sin(Math.PI/4)*r+centerX,-Math.sin(Math.PI/4)*r+centerY);
            graphics.curveTo(r+centerX,-Math.tan(Math.PI/8)*r+centerY,r+centerX,centerY);
        
        }

    }

}

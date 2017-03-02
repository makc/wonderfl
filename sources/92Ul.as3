package {
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.display.CapsStyle;
    import flash.display.LineScaleMode;
    public class FlashTest extends Sprite {
        private var jackson:Sprite;
        private var prevX:int;
        private var prevY:int;
        private var startPosX:int;
        private var startPosY:int;
        private var disX:Number;
        private var disY:Number;
        private var color:uint;
        public function FlashTest() {
            jackson = addChild(new Sprite()) as Sprite;
            stage.addEventListener(MouseEvent.MOUSE_MOVE, _move);
            stage.addEventListener(MouseEvent.MOUSE_DOWN,_down)
            jackson .doubleClickEnabled = true;
            stage.addEventListener(MouseEvent.DOUBLE_CLICK,onMouseDoubleClick)
        }
        private function onMouseDoubleClick(e:MouseEvent):void{
             jackson.graphics.clear();
        }
        private function _down(e:MouseEvent):void {
            color = Math.random() * 0xFFFFFF;	
        }
        private function _move(e:MouseEvent):void {
            var distance:Number = Math.sqrt(Math.pow(prevX - startPosX, 2) + Math.pow(prevY - startPosY, 2))
            var a:Number = distance * 10 * (Math.pow(Math.random(), 2) - 0.5)
            var r:Number = Math.random() - 0.5
            var size:Number = Math.random() * 15 / distance
			
            disX = (prevX - startPosX) * Math.sin(0.5) + startPosX;
            disY = (prevY - startPosY) * Math.cos(0.5) + startPosY;
            startPosX = prevX;
            startPosY = prevY;
            prevX = mouseX
            prevY = mouseY
            
            jackson.graphics.moveTo(startPosX, startPosY);
            jackson.graphics.curveTo(disX,disY,prevX,prevY)
            jackson.graphics.lineStyle(((Math.random()+20/10-0.5)*size+(1-Math.random()+30/20-0.5)*size), color,1, false, LineScaleMode.NONE, CapsStyle.ROUND);	
            jackson.graphics.moveTo(startPosX + a, startPosY + a);
            jackson.graphics.lineTo(startPosX+r+a, startPosY+r+a);
            jackson.graphics.endFill();
        }
    }
}
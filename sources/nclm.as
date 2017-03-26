/*
ワープっぽく・・・見える？ｗ

mouseMove : move perspective point
mouseDown : speed up
mouseUp   : speed down
*/

package {
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.PerspectiveProjection;
    import flash.geom.Point;
    
    [SWF(width=465, height=465, backgroundColor=0x000000)]
    public class Warp extends Sprite {
        private const W:int = stage.stageWidth;
        private const H:int = stage.stageHeight;
        private const R:int = 5000;
        private const PI:Number = Math.PI;
            
        private var perspective:PerspectiveProjection;

            public function Warp() {
                perspective = this.transform.perspectiveProjection;
                perspective.fieldOfView = 175;
                addEventListener(Event.ENTER_FRAME, onEnterFrameHandler);
                stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDownHandler);
                stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUpHandler);
            }
            
        private function onMouseDownHandler(e:MouseEvent):void { Rect3D.moveZ = 100; }
        private function onMouseUpHandler(e:MouseEvent):void { Rect3D.moveZ = 30; }        
            
        private function onEnterFrameHandler(e:Event):void {
            perspective.projectionCenter = new Point(mouseX, mouseY);
            
            var n:int = Rect3D.moveZ / 6;
            for (var i:int = 0; i < n; i++){
                var rect:Rect3D = new Rect3D(Math.random() * 0xffffff, 200);
                var rad:Number = Math.random() * 2 * PI;
                rect.x = R * Math.cos(rad);
                rect.y = R * Math.sin(rad);
                rect.z = Math.random() * 100 + 3000;
                rect.rotationX = 180-Math.atan2(rect.y - H / 2, rect.x - W / 2) * 180 / PI;
                rect.rotationY = 90;
                addChild(rect);
            }
        }
    }
}

import flash.display.Sprite;
import flash.events.Event;
class Rect3D extends Sprite {
    public static var moveZ:int = 30;
    
    public function Rect3D(color:uint, size:int) {
        graphics.beginFill(color);
        graphics.drawRect( -size / 2, -size / 2, size, size);
        graphics.endFill();
        addEventListener(Event.ENTER_FRAME, onEnterFrameHandler);
    }
    
    private function onEnterFrameHandler(e:Event):void {
        this.z -= moveZ;
        if (this.z <= 0) {
            parent.removeChild(this);
            removeEventListener(e.type, arguments.callee);
        }
    }
}


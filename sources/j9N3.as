/*
 * PerspectiveProjection Basic Test
 * The object of Position(0,0,0) is not changed. 
 */
package {
    import flash.display.Sprite;
    public class TestPerspective extends Sprite {
        private const SW:Number = stage.stageWidth;
        private const SH:Number = stage.stageHeight;
        public function TestPerspective():void {
            // Object Container
            var canvas:Engine3D = new Engine3D(SW,SH);
            canvas.x = SW/2;
            canvas.y = SH/2;
            addChild(canvas);
            // Objects
            var blue:Panel   = new Panel(0x0000ff);
            blue.z = 50;
            var green:Panel = new Panel(0x00ff00);
            green.z = 0;
            var red:Panel   = new Panel(0xff0000);
            red.z = -50;
            canvas.addChild(blue);
            canvas.addChild(green);
            canvas.addChild(red);
        }
    }
}
import flash.display.Shape;
import flash.display.BlendMode;
class Panel extends Shape {
    public function Panel(color:int):void {
        graphics.beginFill(color);
        graphics.drawRect(-50,-50,100,100);
        graphics.endFill();
        blendMode = BlendMode.ADD;
    }
}
import flash.display.Sprite;
import flash.geom.PerspectiveProjection;
import flash.geom.Point;
import flash.events.MouseEvent;
class Engine3D extends Sprite {
    private var proj:PerspectiveProjection;
    private var W:Number;
    private var H:Number;
    public function Engine3D(w:Number, h:Number):void {
        W=w;
        H=h;
        graphics.beginFill(0);
        graphics.drawRect(-w/2,-h/2,w,h);
        graphics.endFill();
        addEventListener(MouseEvent.MOUSE_MOVE, viewChange);
    }
    private function viewChange(e:MouseEvent):void {
        proj = root.transform.perspectiveProjection;
        proj.projectionCenter = new Point(W/2-mouseX*2,H/2-mouseY*2);
    }
}
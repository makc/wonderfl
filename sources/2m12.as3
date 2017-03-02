package {
    import flash.events.*;
    import flash.display.*;
    import flash.filters.*;
    import flash.geom.*;
    public class FlashTest extends Sprite {
        
        private var phi:Number;
        private var mv:Matrix3D;
        private var q:Vector.<Vector3D>;
        private var s:Sprite;
        
        public function FlashTest() {
            transform.perspectiveProjection.focalLength = 200;
            
            phi = 0;
            mv = new Matrix3D();
            q = new Vector.<Vector3D>(3, true);
            q[0] = new Vector3D(-.5, -.5, 0, 1);
            q[1] = new Vector3D(0, 1, 0, 1);
            q[2] = new Vector3D(.5, -.5, 0, 1);
            addEventListener(Event.ENTER_FRAME, frame);
            
            s = new Sprite();
            s.graphics.lineStyle(0, 0x0000ff);
            s.graphics.moveTo(q[0].x * 200, q[0].y * 200);
            s.graphics.curveTo(q[1].x * 200, q[1].y * 200, q[2].x * 200, q[2].y * 200);
            s.graphics.drawCircle(q[0].x * 200, q[0].y * 200, 5);
            s.graphics.drawCircle(q[1].x * 200, q[1].y * 200, 5);
            s.graphics.drawCircle(q[2].x * 200, q[2].y * 200, 5);
            s.x = 232.5;
            s.y = 232.5;
            addChild(s);
        }
        
        private function frame(e:Event):void {
            mv.identity();
            mv.appendRotation(phi, Vector3D.Y_AXIS);
            mv.appendTranslation(0, 0, 1);
            var a:Vector3D = mv.transformVector(q[0]);
            a.scaleBy(1 / a.z);
            var b:Vector3D = mv.transformVector(q[1]);
            b.scaleBy(1 / b.z);
            var c:Vector3D = mv.transformVector(q[2]);
            c.scaleBy(1 / c.z);
            graphics.clear();
            graphics.lineStyle(0, 0xff0000);
            graphics.moveTo(a.x * 200 + 232.5, a.y * 200 + 232.5);
            graphics.curveTo(b.x * 200 + 232.5, b.y * 200 + 232.5, c.x * 200 + 232.5, c.y * 200 + 232.5);
            graphics.drawCircle(a.x * 200 + 232.5, a.y * 200 + 232.5, 5);
            graphics.drawCircle(b.x * 200 + 232.5, b.y * 200 + 232.5, 5);
            graphics.drawCircle(c.x * 200 + 232.5, c.y * 200 + 232.5, 5);
            phi++;
            
            s.rotationY = phi;
        }
        
    }
}
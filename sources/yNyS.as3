package {
    import flash.display.*;
    import flash.events.*;
    import flash.geom.*;
    public class FlashTest extends Sprite {
        
        private static const K:Number = 4 / 3 * (Math.SQRT2 - 1);
        private static const R1:Number = 32;
        private static const R2:Number = 30;
        private static const L:Number = 64;
        
        private var c:C;
        
        public function FlashTest() {
            c = new C();
            c.m = new Matrix3D();
            c.o = new Vector3D(stage.stageWidth / 2, stage.stageHeight / 2, 0, 0);
            click(null);
            stage.addEventListener(MouseEvent.CLICK, click);
            addEventListener(Event.ENTER_FRAME, frame);
            stage.frameRate = 60;
        }
        
        private function click(e:MouseEvent):void {
            c.v = uv();
            c.m.identity();
            c.m.appendRotation(2, uv());
        }
        
        private function frame(e:Event):void {
            c.v = c.m.transformVector(c.v);
            graphics.clear();
            r(graphics, c.o, c.v);
        }
        
        private static function uv():Vector3D {
            var v:Vector3D = new Vector3D(Math.random() - 0.5, Math.random() - 0.5, Math.random() - 0.5);
            v.normalize();
            return v;
        }
        
        private static function r(g:Graphics, o:Vector3D, v:Vector3D):void {
            var i:Vector3D = v.clone();
            var j:Vector3D = i.crossProduct(Vector3D.Z_AXIS);
            if (j.normalize() < 0.001) {
                g.drawCircle(o.x, o.y, R1);
                return;
            }
            var k:Vector3D = i.crossProduct(j);
            if (k.x * i.x + k.y * i.y > 0) {
                k.scaleBy(-1);
                rh(g, o, i, j, k, false);
                rh(g, o, i, j, k, true);
            } else {
                rh(g, o, i, j, k, true);
                rh(g, o, i, j, k, false);
            }
        }
        
        private static function rh(g:Graphics, o:Vector3D, i:Vector3D, j:Vector3D, k:Vector3D, h:Boolean):void {
            i = i.clone();
            i.scaleBy(h ? L : -L);
            j = j.clone();
            j.scaleBy(h ? R1 : -R2);
            k = k.clone();
            k.scaleBy(h ? R1 : -R2);
            
            g.beginFill(h ? 0xc00040: 0xffffff);
            g.lineStyle(2, 0x000000);
            g.moveTo(o.x + j.x, o.y + j.y);
            g.lineTo(o.x + j.x + i.x, o.y + j.y + i.y);
            g.cubicCurveTo(
                o.x + j.x + i.x - K * j.y, o.y + j.y + i.y + K * j.x,
                o.x + i.x - j.y + K * j.x, o.y + i.y + j.x + K * j.y,
                o.x + i.x - j.y, o.y + i.y + j.x
            );
            g.cubicCurveTo(
                o.x + i.x - j.y - K * j.x, o.y + i.y + j.x - K * j.y,
                o.x - j.x + i.x - K * j.y, o.y - j.y + i.y + K * j.x,
                o.x - j.x + i.x, o.y - j.y + i.y
            );
            g.lineTo(o.x - j.x, o.y - j.y);
            g.cubicCurveTo(
                o.x - j.x + K * k.x, o.y - j.y + K * k.y,
                o.x + k.x - K * j.x, o.y + k.y - K * j.y,
                o.x + k.x, o.y + k.y
            );
            g.cubicCurveTo(
                o.x + k.x + K * j.x, o.y + k.y + K * j.y,
                o.x + j.x + K * k.x, o.y + j.y + K * k.y,
                o.x + j.x, o.y + j.y
            );
        }
        
    }
}

internal class C {
    
    public var o:flash.geom.Vector3D;
    public var v:flash.geom.Vector3D;
    public var m:flash.geom.Matrix3D;
    
}
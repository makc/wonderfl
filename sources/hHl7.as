package {
    import flash.display.*;

    [SWF(backgroundColor="0x808080", frameRate="30")]
    public class FlashTest extends Sprite {
        private var thing:Thing = new Thing;

        public function FlashTest() {
            stage.quality = "low";
            x = y = 232.5;
            addChild(thing);
            addEventListener("enterFrame", loop);
            z=1000;
            rotationX = 45;
        }
        private function loop(e:*):void { 
            thing.rotationZ++; 
            Dot.sort(this, thing);
        }
    }
}

import flash.display.*;
import flash.geom.*;

class Dot extends Sprite {
    public static var instances:Array = [];
    public var worldZ:Number;
    
    public function Dot(color:uint = 0xff0000, alpha:Number = 1) {
        instances.push(this);
        for(var i:int=0; i<3; i++) {
            var s:Shape = new Shape;
            s.graphics.beginFill(color);
            s.graphics.drawCircle(0, 0, 100);
            s.graphics.endFill();
            s["rotation" + ["X","Y","Z"][i]] = 90;
            this.alpha = alpha;
            addChild(s);
        }
    }
    
    public function calcZ(world:Sprite):void {
        worldZ = transform.getRelativeMatrix3D(world).position.z;
    }

    public static function sort(world:Sprite, parent:Sprite):void {
        var dot:Dot
        for each(dot in instances) dot.calcZ(world);
        instances.sortOn("worldZ", Array.NUMERIC | Array.DESCENDING);
        for each(dot in instances) {
            dot.transform.matrix3D= dot.transform.getRelativeMatrix3D(parent);
            parent.addChild(dot);
        }
    }
}

class Arm extends Dot {
    public function Arm(level:int, color:uint, angle:Number) {
        if(level) {
            var other:Arm = new Arm(level-1, color+0x06060a, angle);
            other.x += 100;
            other.rotationY += angle;
            other.scaleX = 0.9;
            other.scaleY = 0.9;
            other.scaleZ = 0.9;
            addChild(other);
            super(color, 0.5);
        }
    }
}

class Thing extends Sprite {
    public function Thing() {
        for(var i:int=0, ii:int = 12; i<ii; i++) {
            var a:Arm = new Arm(25, 0x401000, 23 + 10*Math.sin(3*2*Math.PI*i/ii));
            a.z = a.z;
            a.transform.matrix3D.appendTranslation(150, 0, 0);
            a.transform.matrix3D.appendRotation(i*360/ii, Vector3D.Z_AXIS);
            addChild(a);
        }
    }
}
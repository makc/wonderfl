package  {

    import flash.events.MouseEvent;
    import flash.geom.Vector3D;
    import flash.geom.Point;
    import flash.events.Event;
    import flash.display.Sprite;

    /**
     * @author javid jafari 
     8-9-2013
     */
    public class JointTest extends Sprite {

        private var joints:Vector.<Joint>
        private var points:Vector.<Vector.<Point2D>>
        private var cols:Number=10
        private var rows:Number=10
        private var res:Number=20
        private  var offX:Number
        private  var offY:Number
        private var cp:Point2D
        private var gravity : Vector3D = new Vector3D(0, .3)
        private var h : int;
        private var w : int;

        public function JointTest() {

            stage.frameRate=60
            w=stage.stageWidth
            h=stage.stageHeight
             with(this.graphics){
                beginFill(0x101010)
                 drawRect(0,0,w,h)
             }
            offX=w/2-(res*cols)/2
            offY=h/7;

            joints=new Vector.<Joint>()
            points=new Vector.<Vector.<Point2D>>()
            addPointsAndJoints()

            points[0][0].pinned=true
            points[cols-1][0].pinned=true
        //    points[5][0].pinned=true

            stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown)
            stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp)
            addEventListener(Event.ENTER_FRAME, loop)

        }

        private function onMouseUp(event : MouseEvent) : void {
            if(cp) cp.isDragging=false
        }



        private function onMouseDown(event : MouseEvent) : void {
            
            var p:Point2D
            var m:*=stage.getObjectsUnderPoint(new Point(mouseX,mouseY))[1];
            if(m is Point2D){
            cp=m
            cp.isDragging=true
            }
        }


        private function addPointsAndJoints() : void {

            var j:int,i:int
            for (i = 0; i < cols; i++) {
                points.push(new Vector.<Point2D>());
                for (j = 0; j < rows; j++) {
                    var p:Point2D=new Point2D(i*res+offX, j*res+offY)
                    
                    points[i].push(p)
                    if( j!=0 ) {
                    var jo:Joint=new Joint(points[i][j], points[i][j-1])
                    addChild(jo)
                    joints.push(jo)
                    }

                    if( i!=0 ) {
                    var jo2:Joint=new Joint(points[i][j], points[i-1][j])
                    joints.push(jo2)
                    addChild(jo2)
                    }
                    addChild(p);

                }
            }
        }


        private function loop(event : Event) : void {
            update()
        }



        private function update() : void {

                if(cp!=null && cp.isDragging){
                cp.loc.x+=(mouseX-cp.loc.x)*.1
                cp.loc.y+=(mouseY-cp.loc.y)*.1
                }

            var j:int,i:int
            for (i = 0; i < cols; i++) {
                for (j = 0; j < rows; j++) {
                    var p:Point2D=points[i][j];
                    p.update()
                    p.applyForce(gravity)

                    /*if(i==0 || j==0 || i==cols || j==rows) return;
                    var jo:Joint=joints[i][j]
                    jo.update()*/
                }

            }

             for each(var jo:Joint in joints) {
                jo.update();
            }

        }

    }

}

import flash.geom.Vector3D;
import flash.display.Shape;

class Point2D extends Shape{

public var vel:Vector3D;
public var acc:Vector3D
public var loc:Vector3D
public var mass:Number=1.9
public var pinned:Boolean
public var isDragging:Boolean
public var maxVelo:Number;

public function Point2D(_x:Number,_y:Number):void{
    maxVelo=20
    loc=new Vector3D(_x,_y);
    vel=new Vector3D()
    acc=new Vector3D()
    
    with(this.graphics){
    beginFill(0,0);
    drawCircle(0, 0, 20);
    endFill();

    beginFill(0xffffff);
    drawCircle(0, 0, 2);
    endFill();

    }

    this.x=loc.x;
    this.y=loc.y;

}

public function applyForce(f:Vector3D):void{

     var force:Vector3D=f.clone()
    force.scaleBy(1/mass);
    acc=acc.add(force);
}

public function update():void{

    if(pinned || isDragging){
    vel.scaleBy(0);
    acc.scaleBy(0)
    }else{
    vel=vel.add(acc);
    vel=limit(vel, maxVelo)
    loc=loc.add(vel);
    acc.scaleBy(0);}
    //
    this.x=loc.x;
    this.y=loc.y;

}

private function limit(v:Vector3D,lim:Number):Vector3D{

 if(v.length>lim) v.normalize() , v.scaleBy(lim);
 return v;
}

}

import flash.geom.Vector3D;
import flash.display.Shape;
class Joint extends Shape{

    public static const K:Number=.5
    public static const DAMP:Number=.05
    public var p1:Point2D
    public var  p2:Point2D
    public var len:Number

    public function Joint(_p1:Point2D,_target:Point2D):void{

        p1=_p1;
        p2=_target;
        len=p1.loc.subtract(p2.loc).length


}

    public function update():void{

        var spring:Vector3D=p2.loc.subtract(p1.loc);
        var currentLen:Number=spring.length;
        var X:Number=currentLen-len;
        var fs:Number=K*X;
        spring.normalize()
        spring.scaleBy(fs);
        //calculate damping
        var damping:Vector3D=p2.vel.subtract(p1.vel);
        damping.scaleBy(DAMP);
        //add
        p1.applyForce(spring);
        p1.applyForce(damping)
        spring.scaleBy(-1)
        damping.scaleBy(-1)
        p2.applyForce(spring)
        p2.applyForce(damping)
        display()

    }

    private function display():void{

    with(this.graphics){
    clear()
    lineStyle(1,0xffffff)
    moveTo(p1.loc.x, p1.loc.y);
    lineTo(p2.loc.x, p2.loc.y);

    }
    }

}
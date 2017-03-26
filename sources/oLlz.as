// forked from J.J's Cloth Simulation
package  {

    import flash.events.MouseEvent;
    import flash.geom.Vector3D;
    import flash.geom.Point;
    import flash.events.Event;
    import flash.display.Sprite;
    
    import flash.display.Loader;
    import flash.display.Shape;
    import flash.net.URLRequest;

    /**
     * @author javid jafari 
     8-9-2013
     */
    public class JointTest extends Sprite {

        private var joints:Vector.<Joint>
        private var points:Vector.<Vector.<Point2D>>
        private var cols:Number=5
        private var rows:Number=9
        private var res:Number=20
        //private  var offX:Number
        //private  var offY:Number
        private var cp:Point2D
        private var gravity : Vector3D = new Vector3D(0, .3)
        private var h : int;
        private var w : int;
        
        private var clothColor:int = 0xFF0000;//布の色
        private var mouseFlag:int = 0;
        private var shapes:Vector.<Shape> = new Vector.<Shape>;
        private var initialPosition:Vector.<int>=Vector.<int>([70,181,110,181,150,181,190,181,232.5,181,275,181,315,181,355,181,395,181,65,221,106,221,148,221,190,221,232.5,221,275,221,317,221,359,221,400,221,72,254,111,261,153,266,192,264,232.5,257,273,264,312,266,354,261,393,254,89,287,128,302,167,311,201,306,232.5,291,264,306,298,311,337,302,376,287,112,324,158,352,188,357,212,346,232.5,326,253,346,277,357,307,352,353,324]);
        public function JointTest() {
            
            var loader:Loader = new Loader();
            loader.load(new URLRequest("http://blog-imgs-61.fc2.com/c/9/9/c9975/butt.png"));
            addChild(loader);
            
            var shape:Shape = new Shape;
            shape.graphics.beginFill(0xC0C0C0,1);
            shape.graphics.drawRect(0,0,465,465);
            shape.graphics.drawRect(1,1,463,463);
            addChild(shape);
            
            stage.frameRate=40
            w=stage.stageWidth
            h=stage.stageHeight
            /*with(this.graphics){
                beginFill(0x101010)
                drawRect(0,0,w,h)
             }
            offX=w/2-(res*cols)/2
            offY=h/7;*/

            joints=new Vector.<Joint>()
            points=new Vector.<Vector.<Point2D>>()
            addPointsAndJoints()

            points[0][0].pinned = true
            points[0][8].pinned = true
            points[1][0].pinned = true
            points[1][8].pinned = true
            points[4][4].pinned = true
        //    points[5][0].pinned=true

            stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown)
            stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp)
            addEventListener(Event.ENTER_FRAME, loop)

        }

        private function onMouseUp(event : MouseEvent) : void {
            
            mouseFlag = 0;
            if(cp) cp.isDragging=false
        }



        private function onMouseDown(event : MouseEvent) : void {

            mouseFlag = 1;
            /*var p:Point2D
            var m:*=stage.getObjectsUnderPoint(new Point(mouseX,mouseY))[1];
            if(m is Point2D){
            cp=m
            cp.isDragging=true
            }*/
        }
        private function onMouseDown2(event : MouseEvent) : void {
            
            if(cp) cp.isDragging=false
            cp = event.target as Point2D;
            cp.isDragging = true;
        }


        private function addPointsAndJoints() : void {

            var j:int, i:int
            for (i = 0; i < cols; i++) {
                points.push(new Vector.<Point2D>());
                for (j = 0; j < rows; j++) {
                        if(i!=cols && j != rows){
                        var shape:Shape = new Shape();
                        shape.alpha = 0.5;
                        shapes.push(shape);
                        addChild(shape);
                    }
                    
                    var p:Point2D = new Point2D(initialPosition[(i*rows+j) * 2], initialPosition[(i*rows+j) * 2 + 1])
                    p.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown2);
                    
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
            
            if(cp){
                if(cp.x<=1 || cp.x>=464 || cp.y<=1 || cp.y>=464){
                    mouseFlag = 0;
                    cp.isDragging=false
                }
            }
            update()
        }



        private function update() : void {

                if(cp!=null && cp.isDragging && !cp.pinned){
                cp.loc.x+=(mouseX-cp.loc.x)*.1
                cp.loc.y+=(mouseY-cp.loc.y)*.1
                }
                
            var j:int, i:int
            for (i = 0; i < cols; i++) {
                for (j = 0; j < rows; j++) {
                    var p:Point2D=points[i][j];
                    p.update()
                    
                    if(!mouseFlag){
                        gravity.x = (initialPosition[(i*rows+j) * 2] -p.x)/6;
                        gravity.y = (initialPosition[(i*rows+j) * 2 + 1] -p.y)/6;
                    }
                    else {
                        gravity.x = 0;//(initialPosition[(i*rows+j) * 2] -p.x)/10
                        gravity.y = 0;// (initialPosition[(i * rows + j) * 2 + 1] -p.y) / 10;
                    }
                    p.applyForce(gravity)

                    /*if(i==0 || j==0 || i==cols || j==rows) return;
                    var jo:Joint=joints[i][j]
                    jo.update()*/
                }

            }

             for each(var jo:Joint in joints) {
                jo.update();
            }
            
            for (i = 0; i < cols-1; i++) {
                for (j = 0; j < rows-1; j++) {
                     with(shapes[i*(rows-1)+j].graphics){
                        clear();
                        lineStyle(1,0xFFFFFF)
                        beginFill(clothColor); 
                        moveTo(points[i][j].x, points[i][j].y);
                        lineTo(points[i + 1][j].x, points[i + 1][j].y);
                        lineTo(points[i+1][j+1].x, points[i+1][j+1].y);
                        lineTo(points[i][j + 1].x, points[i][j + 1].y);
                        endFill();
                    }
                }
            }

        }

    }

}

import flash.geom.Vector3D;
import flash.display.Sprite
//import flash.display.Shape;

class Point2D extends Sprite{

public var vel:Vector3D;
public var acc:Vector3D
public var loc:Vector3D
public var mass:Number=1.9
public var pinned:Boolean
public var isDragging:Boolean
public var maxVelo:Number;

public function Point2D(_x:Number,_y:Number):void{
    
    maxVelo=100
    loc=new Vector3D(_x,_y);
    vel=new Vector3D()
    acc=new Vector3D()
    
    with(this.graphics){
    beginFill(0,0);
    drawRect(-20, -20, 40,40);
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
    vel = limit(vel, maxVelo)
    vel.x /= 1.4;
    vel.y /= 1.4;
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
        //display()

    }

    /*private function display():void{

    with(this.graphics){
    clear()
    lineStyle(1,0xffffff)
    moveTo(p1.loc.x, p1.loc.y);
    lineTo(p2.loc.x, p2.loc.y);

    }
    }*/

}
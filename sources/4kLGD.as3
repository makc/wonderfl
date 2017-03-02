package {

    import flash.events.MouseEvent;
    import flash.events.Event;
    import flash.display.Sprite;
    /**
     * @author J.J
     *use mouse to move objects
     */
          
    public class RayTest extends Sprite {
        
        private var bodies:Vector.<RigidBody>;
        private var isDown:Boolean=false;
        private var rays : Vector.<Ray>;
        private var testlist:Vector.<RigidBody>
        private var joint : JointConstraint;
        private const MAX_RAY_DIST:Number=1000;
        private var cam_height:Number=80;        
        public function RayTest() {
            var mc:Sprite=new Sprite()            
            this.graphics.beginFill(0x101010)
            this.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight)
            this.addChild(mc)
            stage.frameRate=60;
            bodies=new Vector.<RigidBody>();
            rays=new Vector.<Ray>();
            testlist=new Vector.<RigidBody>()
            Canvas.setCanvas(mc.graphics)
            var vrtx:Vector.<Vec2D>=new Vector.<Vec2D>();
            vrtx.push(new Vec2D(-12,-30),new Vec2D(12,-30))
            vrtx.push(new Vec2D(20,cam_height),new Vec2D(-20,cam_height))
            var flash:RigidBody=new RigidBody(new Polygon(vrtx))
            bodies.push(flash);
            flash.p.x=100;
            flash.p.y=100;            

            //joint 
            joint=new JointConstraint(.007, null)
            //body
            var body:RigidBody=new RigidBody(new Polygon(Polygon.createVertices(3, 100)))
            body.p.x=300
            body.p.y=300;
            body.setAngle(Math.PI/4)
            bodies.push(body)
             testlist.push(body)
            
            body=new RigidBody(new Polygon(Polygon.createVertices(4, 60)))
            body.p.x=100;
            body.p.y=300
            body.setAngle(Math.PI/4)
            bodies.push(body)
             testlist.push(body)            

            body=new RigidBody(new Polygon(Polygon.createVertices(5, 40)))
            body.p.x=280;
            body.p.y=150
            body.setAngle(Math.PI/4)
            bodies.push(body)
             testlist.push(body)            
            body=new RigidBody(new Cirlce(50))
            body.p.x=380;
            body.p.y=50
            bodies.push(body)
            testlist.push(body)
             //----------ray
             var o:Vec2D=flash.p;
             var pi:Number=Math.PI;
             var start:Number=pi/14;
             var step:Number=start/(5*2);
             for (var i : int = 0; i < 10*2; i++) {
                 var ray:Ray=new Ray(o, new Vec2D(Math.sin(start),Math.cos(start)))
                start-=step;
                rays.push(ray);
             }
              flash.torque=.1;
            this.addEventListener(Event.ENTER_FRAME, loop)
            stage.addEventListener(MouseEvent.MOUSE_DOWN, mdown);
            stage.addEventListener(MouseEvent.MOUSE_UP, mup)
        }
        private function mup(event : MouseEvent) : void {
            isDown=false;
        }
        private function mdown(event : MouseEvent) : void {            
            var m:Vec2D=new Vec2D(mouseX,mouseY);            
            for (var i : int = 0; i < bodies.length; i++) {
            var bd:RigidBody=bodies[i]
            var mat:Matrix2X2=bd.matrix;
            var p:Vec2D=new Vec2D(m.x,m.y)
            if(bd.shape.contains(p, bd.p, bd.matrix)){
                joint.ref=p;
                joint.body=bd;
                isDown=true;
                break;
                //bd.torque=.1;            
            }
            }

        }

         private function sortF(a:RigidBody,b:RigidBody):Number{
        var ray:Ray=rays[int(rays.length/2)]
        var dir:Vec2D=ray.dir;
        var o:Vec2D=bodies[0].p;
        var od:Number=dir.x*o.x+dir.y*o.y
        var ad:Number=(a.p.x*dir.x+a.p.y*dir.y)-od;
        var bd:Number=(b.p.x*dir.x+b.p.y*dir.y)-od;
        return ad-bd;
        }
        private function loop(event : Event) : void {
            
            Canvas.clear();
        
            var bdi:RigidBody=bodies[0];
            var mat:Matrix2X2=bdi.matrix;
            var x:Number,y:Number;
            testlist.sort(sortF);
            for each (var r : Ray in rays) {

                var d:Vec2D=r.odir;
                x=d.x*mat.c+d.y*mat.d;
                y=d.x*mat.a+d.y*mat.b;
                r.dir.x=x;
                r.dir.y=y;
                var bi:Vec2D=new Vec2D();
                var ci:Vec2D=new Vec2D();
                var LEN:int=testlist.length
                var i:int=0;
                var f:Boolean=false;
                while(i<LEN && f==false) {
                    
                    var bo:RigidBody=testlist[i]            
                    var t:Number;
                    if(bo.shape.getType()==ShapeType.POLYGON){
                    if(Polygon.testRayPolygon(r.o, r.dir,bo.shape as Polygon,bo.p,bo.matrix)){
                    t=Number(r.o.userData)
                    bi.x=r.dir.x*t
                    bi.y=r.dir.y*t;
                    bi.x+=r.o.x;
                    bi.y+=r.o.y;
                    ci.x=r.o.x+(r.dir.x*cam_height);
                    ci.y=r.o.y+(r.dir.y*cam_height);
                    Canvas.drawLine(ci,bi,0xff0011)
                    Canvas.drawDot(bi,1,0x00ffff)
                    f=true;
                    break;
                    }}
                    else{
                    if(Ray.testAgainstCircle(r.o, r.dir, bo.shape as Cirlce))
                    {                       
                    t=Number(r.dir.userData)
                    bi.x=r.dir.x*t
                    bi.y=r.dir.y*t;
                    bi.x+=r.o.x;
                    bi.y+=r.o.y;
                    ci.x=r.o.x+(r.dir.x*cam_height);
                    ci.y=r.o.y+(r.dir.y*cam_height);
                    Canvas.drawLine(ci,bi,0x00aaff)
                    Canvas.drawDot(bi,1,0x00ffff)
                    f=true;
                    break;
                    }
                    }
                      
                i++;}
                if(f==false){
                    bi.x=r.dir.x*MAX_RAY_DIST
                    bi.y=r.dir.y*MAX_RAY_DIST;
                    bi.x+=r.o.x;
                    bi.y+=r.o.y;
                    ci.x=r.o.x+(r.dir.x*cam_height);
                    ci.y=r.o.y+(r.dir.y*cam_height);
                     Canvas.drawLine(ci,bi,0xffffff)
                 }
            }
           
            var m:Vec2D=new Vec2D(mouseX,mouseY);
            for each (var b : RigidBody in bodies) {            

                Canvas.drawBody(b)
                Canvas.drawDot(m)
                if(isDown && joint.body==b){
                joint.loc.x=m.x;
                joint.loc.y=m.y;
                joint.update()
                }
                b.damping();
                b.integrate()
                 
            }
        }
    }
}

import flash.display.Graphics;
//rigid body
class RigidBody {
    //acceleration
    public var a:Vec2D;
    //position
    public var p:Vec2D;
    //velocity
    public var v:Vec2D;
    //angular acceleration
    public var alpha:Number;
    //angular velocity
    public var omega:Number;
    //rotation angle
    public var theta:Number;
    //moment of inertia
    public var moi:Number;
    //mass
   public var m:Number;
    //torque
    public var torque:Number;
    public var shape:IGeometricShape;
    public var matrix:Matrix2X2;

    public function RigidBody(shape:IGeometricShape,x:Number=1,y:Number=0,mass:Number=.5){

            this.shape=shape;
            this.m=mass;
            this.p=new Vec2D(x,y);
            if(shape.getType()==ShapeType.CIRCLE){
            (shape as Cirlce).center=p;            
            }
            this.a=new Vec2D();
            this.v=new Vec2D()
            this.alpha=0;
            this.omega=0;
            this.theta=0;
            this.torque=0;
            this.moi=shape.getMOI()
            matrix=new Matrix2X2(0)
        
    }

    public function setAngle(t:Number):void{
        theta=t;
      matrix.setAngle(t);
    }

    public function integrate():void{

        v.x+=a.x;
        v.y+=a.y;
        p.x+=v.x;
        p.y+=v.y;
        a.x=a.y=0;
        a.x*=0;
        a.y*=0;
        alpha+=torque;
        omega+=alpha;
        theta+=omega;
        torque=0;
        alpha=0;
        if(theta>Math.PI*2 || theta<-Math.PI*2) theta=0;
        this.setAngle(theta);                        
    }

    public function damping():void{

        var k:Number=-.03/m;
        var f:Vec2D=new Vec2D()
        a.x+=(v.x*k);
        a.y+=(v.y*k);
     this.omega=this.omega*.89;
    }    
}

class JointConstraint{

    public var k:Number;
    public var body:RigidBody;
    public var loc:Vec2D;
    public var ref:Vec2D;

    public function JointConstraint(k:Number,body:RigidBody){
    this.k=k;
    this.body=body;
    this.loc=new Vec2D();
    }

    public function isActive():Boolean{return this.ref!=null;}    
    public function update():void{
        if(isActive()){            
        var x:Number,y:Number;
        var u:Vec2D=new Vec2D(ref.x,ref.y)
        var matrix:Matrix2X2=this.body.matrix;
        x=u.x*matrix.c+u.y*matrix.d;
        y=u.x*matrix.a+u.y*matrix.b;
        u.x=x;
        u.y=y;
        u.x+=body.p.x;
        u.y+=body.p.y;
        Canvas.drawDot(u)

        //update

        var l:Vec2D=loc;
        var f:Vec2D=new Vec2D((l.x-u.x)*k,
        (l.y-u.y)*k)
        var torq:Number=-(f.x*(body.p.y-u.y)-f.y*(body.p.x-u.x))
        var alp:Number=torq/(body.moi*.00001*body.m)
        body.a.x+=f.x/body.m;
        body.a.y+=f.y/body.m;
        body.alpha=alp;
        }
    }
}

class Ray{

    public var o:Vec2D;
    public var dir:Vec2D;
    public var odir:Vec2D;
    public function Ray(o:Vec2D,dir:Vec2D){
    this.o=o;
    this.dir=dir;
    this.odir=new Vec2D(dir.x,dir.y)
    }

    public  static function testAgainstCircle(o:Vec2D,dir:Vec2D,circle:Cirlce):Boolean{    
        var cn:Vec2D=circle.getCenter()
        var r2:Number=circle.r*circle.r
        var m:Vec2D=new Vec2D(o.x-cn.x,o.y-cn.y)
        var b:Number=m.x*dir.x+m.y*dir.y
        var c:Number=(m.x*m.x+m.y*m.y)-r2
        if(c>0 && b>0) return false;
        var delt:Number=(b*b)-c;
        if(delt<=0) return false;
        var t:Number=-b-Math.sqrt(delt)
        t=t<0?0:t
        dir.userData=t;
        //(point.x*dir.x+point.y*dir.y)-(o.x*dir.x+o.y*dir.y);
        return true;
    }
}

class ShapeType{
public static const POLYGON:uint=1;
public static const CIRCLE:uint=2;
}

interface IGeometricShape {
     function getType():uint
     function getMOI():Number;
     function getCenter():Vec2D;
     function contains(p:Vec2D,pos:Vec2D,mat:Matrix2X2):Boolean;
}

class Canvas {
    private static var canvas:Graphics;
    public static function setCanvas(g:Graphics):void{
            canvas=g;
    }
    public static function drawDot(v:Vec2D,t:Number=1,c:uint=0xaa0000,r:Number=4):void{
    canvas.lineStyle(t,c)
    canvas.drawCircle(v.x, v.y, r);
    canvas.endFill()
    }
    public static function drawBody(body:RigidBody):void{
    var sh:IGeometricShape=body.shape;    
        if(sh.getType()==ShapeType.POLYGON) drawPoly(sh as Polygon,body.p,body.matrix);
        else drawCirlce(body.p, (sh as Cirlce).r)        
    }

    public static function clear():void{
        canvas.clear();
        }

    public static function drawLine(a:Vec2D,b:Vec2D,c:uint=0):void{

        canvas.lineStyle(1,c)
        canvas.moveTo(a.x, a.y);
        canvas.lineTo(b.x, b.y);
     }

     public static function drawCirlce(c:Vec2D,r:Number,cl:uint=0xffffff):void{
     canvas.lineStyle(1,cl)
     canvas.drawCircle(c.x, c.y, r);
     canvas.endFill()
     }

    public static function drawPoly(poly:Polygon,p:Vec2D,mat:Matrix2X2,c:uint=0xeeeeee):void{

        var n:int=poly.vertices.length;
        var v:Vector.<Vec2D>=poly.vertices;
        var x:Number,y:Number;
        var a:Vec2D=new Vec2D(v[0].x,v[0].y)
        x=a.x*mat.c+a.y*mat.d;
        y=a.x*mat.a+a.y*mat.b;
        a.x=x;
        a.y=y;
        a.x+=p.x;
        a.y+=p.y;
        canvas.lineStyle(1,c);
        canvas.moveTo(a.x, a.y)        
        for (var i : int = 0; i < n; i++) {

            var buf:Vec2D=v[(i+1)==n?0:i+1]
            a=new Vec2D(buf.x,buf.y)
            x=a.x*mat.c+a.y*mat.d;
            y=a.x*mat.a+a.y*mat.b;
            a.x=x;
            a.y=y;
            a.x+=p.x;
            a.y+=p.y;
            canvas.lineTo(a.x, a.y)
        }        
    }
}

class Cirlce implements IGeometricShape{

    public var center:Vec2D;
    public var I:Number;
    public var r:Number;
    public function Cirlce(r:Number){
    this.r=r;
    this.I=(Math.PI/2)/Math.pow(r,4);
    }
    public function getCenter():Vec2D{return this.center;}
    public function getMOI():Number{
    return this.I;
    }
    public function getType():uint{return ShapeType.CIRCLE;}
    public function contains(p:Vec2D,pos:Vec2D,mat:Matrix2X2):Boolean{
        var w:Vec2D=new Vec2D(p.x-pos.x,p.y-pos.y)
        p.x=w.x;
        p.y=w.y;
        Canvas.drawDot(p,1,0xff0000);
        var o:Boolean=((w.x*w.x+w.y*w.y)<=r*r)
    return o;
    }
}

class Polygon implements IGeometricShape{
        
     public var vertices:Vector.<Vec2D>;
     private var transformedVrtx:Vector.<Vec2D>;
     private var inertia:Number;
     private var center:Vec2D;
     public function Polygon(vertices:Vector.<Vec2D>){
     this.vertices=vertices;
     calcOtherThings();
     }

     public function getTransformedVertices():Vector.<Vec2D>{
     return null;     
     }

     public static function testRayPolygon(o:Vec2D,dir:Vec2D,poly:Polygon,pos:Vec2D,mat:Matrix2X2):Boolean{

        var len:int=poly.vertices.length;
        var v:Vector.<Vec2D>=poly.vertices;
        var c:int;
        var dist:Number=1000;
        for (var i : int = 0; i < len; i++) {            
            var bu:Vec2D=v[i];
            var q:Vec2D=new Vec2D(bu.x,bu.y)
            bu=(i+1)<len?v[i+1]:v[0];
            var p:Vec2D=new Vec2D(bu.x,bu.y)
            var x:Number,y:Number;
            var a:Vec2D=q;
            x=a.x*mat.c+a.y*mat.d;
            y=a.x*mat.a+a.y*mat.b;
            a.x=x;
            a.y=y;
            a.x+=pos.x;
            a.y+=pos.y;
            a=p;
            x=a.x*mat.c+a.y*mat.d;
            y=a.x*mat.a+a.y*mat.b;
            a.x=x;
            a.y=y;
            a.x+=pos.x;
            a.y+=pos.y;
            if(testLineIntesection(q, p, o, dir)){
            c++;
            dist=Math.min(dist,Math.abs(Number(dir.userData)));
            }
        }
        if(c>0 && (c & 1)==0){
            o.userData=dist;
        return true;

        }
         return false;
     }

     public static function testLineIntesection(a:Vec2D,b:Vec2D,o:Vec2D,dir:Vec2D):Boolean{         
     var n:Vec2D=new Vec2D(-dir.y,dir.x)
     var ab:Vec2D=new Vec2D((b.x-a.x),(b.y-a.y))
      var t:Number=((o.x*n.x+o.y*n.y)-(a.x*n.x+a.y*n.y))/(ab.x*n.x+ab.y*n.y);
      if(t<=1 && t>=0){
        // var point:Vec2D=new Vec2D(a.x+ab.x*t,a.y+ab.y*t)
       //  Canvas.drawDot(point,1,0xff0000)
        var t1:Number=((a.x+(ab.x*t))*dir.x+(a.y+(ab.y*t))*dir.y)
        t1-=o.x*dir.x+o.y*dir.y
    if(t1>0){
        dir.userData=t1;
      return true;}
      }
     return false;
     }

     public function contains(p:Vec2D,pos:Vec2D,mat:Matrix2X2):Boolean{

        var w:Vec2D=new Vec2D(p.x-pos.x,p.y-pos.y)
         var x:Number,y:Number;
        x=w.x*mat.c+w.y*mat.a;
        y=w.x*mat.d+w.y*mat.b;
        p.x=x;
        p.y=y;
        var vrtx:Vector.<Vec2D>=this.vertices;
        var n:int=vrtx.length;
        var ab:Vec2D=new Vec2D()
        var pp:Vec2D=new Vec2D()
         for (var i : int = 0; i < n; i++) {
                    var p1:Vec2D=vrtx[i]
                    var p2:Vec2D=(i+1)<n?vrtx[i+1]:vrtx[0];
                    var ec:Number=(p2.x-p1.x)*(p.y-p1.y)-(p2.y-p1.y)*(p.x-p1.x)
                    if(ec<0){
                    return false;
                    }                    
            }
        return true;
     }

     public function getType():uint{return ShapeType.POLYGON;}
     public function calcOtherThings():void{
             var d:Number=1;
            var center:Vec2D=new Vec2D()
            var area:Number=0
            var I:Number=0;
            var vrtx:Vector.<Vec2D>=this.vertices;
            var n:int=vrtx.length;
            var inv3:Number=1/3;
            for (var i : int = 0; i < n; i++) {
                var p1:Vec2D=vrtx[i];
                var p2:Vec2D=(i+1)<n?vrtx[i+1]:vrtx[0];
                var triArea:Number=.5*(p1.x*p2.y-p1.y*p2.x);
                area+=triArea;
                center.x+=(p1.x+p2.x)*inv3*triArea;
                center.y+=(p1.y+p2.y)*inv3*triArea;
                I += triArea * ((p2.x*p2.x+p2.y*p2.y) + (p2.x*p1.x+p2.y*p1.y) + (p1.x*p1.x+p1.y*p1.y));
            }
            var m:Number=area*d
            this.inertia=I;
            var tk:Number=1/area
            center.x*=tk;
            center.y*=tk;
            this.center=center;            
     }
     public function getMOI():Number{
     return this.inertia;
     }

     public function getCenter():Vec2D{
     return this.center;
     }

     public static function createVertices(n:int,r:Number):Vector.<Vec2D>{
        var vrtx:Vector.<Vec2D>=new  Vector.<Vec2D>();
        var _2PI:Number=Math.PI*2;
        var theta:Number=0;
         for (var i : int = 0; i < n; i++) {
            theta=_2PI*(i/n);
            vrtx.push(new Vec2D(r*Math.cos(theta),r*Math.sin(theta)))
         }
        return vrtx;
     }
}

//vector class
class Vec2D {
    
    public var x:Number;
    public var y:Number
    public var userData:Object;
    public function Vec2D(x:Number=0,y:Number=0):void{
    this.x=x;
    this.y=y;
    }
}

//mat RIX
class Matrix2X2{
    public var a:Number;
    public var b:Number;
    public var c:Number;
    public var d:Number
    public function Matrix2X2(t:Number){
    setAngle(t);
    }
    public function setAngle(t:Number):void{
    a=-Math.sin(t);
    b=Math.cos(t)
    c=b;
    d=-a;
    }
}
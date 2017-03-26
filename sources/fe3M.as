// forked from Kay's Rotation Cubes
/*
 * addChildやrotationXなど2Dインスタンスで使い慣れたメソッドを用いて
 * 3Dオブジェクトをコントロールする
 * カメラでいろいろ遊んでみるTEST
 */
package {
    import flash.display.Sprite;
    import flash.geom.Point;
    import flash.events.Event;
    import net.hires.debug.Stats;
    [ SWF (width = '465', height = '465', backgroundColor = '0xFFFFFF', frameRate = '60') ]
    public class Main extends Sprite {
        private var scene:Scene3D;
        private var body:Cube3D;
        private var head:Cube3D;
        private var armL:Cube3D;
        private var armR:Cube3D;
        private var legL:Cube3D;
        private var legR:Cube3D;
        public function Main():void {
            addChild( new Stats() );
            var canvas:Sprite=new Sprite();
            canvas.x=stage.stageWidth/2;
            canvas.y=stage.stageHeight/2;
            addChild(canvas);
            scene=new Scene3D(canvas);
            body = new Cube3D(40,50,20);
            scene.addChild(body);
            var jointHead:Joint3D = new Joint3D();
            jointHead.y = -85;
            body.addChild(jointHead);
            head = new Cube3D(30,30,30);
            jointHead.addChild(head);
            var jointArmL:Joint3D = new Joint3D();
            jointArmL.x = 65;
            jointArmL.y = -40;
            body.addChild(jointArmL);
            armL=new Cube3D(20,45,20);
            armL.vertsOffset(0,-45,0);
            jointArmL.addChild(armL);
            var jointArmR:Joint3D = new Joint3D();
            jointArmR.x = -65;
            jointArmR.y = -40;
            body.addChild(jointArmR);
            armR=new Cube3D(20,45,20);
            armR.vertsOffset(0,45,0);
            jointArmR.addChild(armR);
            var jointLegL:Joint3D = new Joint3D();
            jointLegL.x = 20;
            jointLegL.y = 80;
            body.addChild(jointLegL);
            legL=new Cube3D(20,20,20);
            jointLegL.addChild(legL);
            var jointLegR:Joint3D = new Joint3D();
            jointLegR.x = -20;
            jointLegR.y = 80;
            body.addChild(jointLegR);
            legR=new Cube3D(20,20,20);
            jointLegR.addChild(legR);
            addEventListener(Event.ENTER_FRAME,xRotation);
        }
        private function xRotation(e:Event):void {
            body.rotationY+=0.4;
            head.rotationY-=0.8;
            armL.rotationX+=4;
            armR.rotationX+=4;
            legL.rotationX+=2;
            legR.rotationX-=2;
            //scene.camera.focalLength = 600 + 500*Math.cos(body.rotationY/90*Math.PI);
            scene.camera.fieldOfView = 75 + 60*Math.cos(body.rotationY/45*Math.PI);
            //scene.camera.projectionCenter = new Point(800,800);
            scene.render();
        }
    }
}
import flash.display.Sprite;
import flash.geom.Point;
import flash.geom.Matrix3D;
import flash.geom.Vector3D;
import flash.geom.Utils3D;
import flash.geom.PerspectiveProjection;
import flash.display.TriangleCulling;
import frocessing.color.ColorHSV;
class Scene3D extends Sprite {
    public var camera:Camera3D;
    public var position:Vector3D;
    public var canvas:Sprite;
    public var objects:Array;
    public var matrix3D:Matrix3D = new Matrix3D();
    public function Scene3D(sprite:Sprite):void {
        camera=new Camera3D();
        canvas=sprite;
    }
    public function render():void {
        objects = new Array();
        getAllChildren(this);
        canvas.graphics.clear();
        //canvas.graphics.lineStyle(1);
        var viewPoint:Vector3D = new Vector3D(0,0,-camera.proj.focalLength);
        var lite3D:Vector3D = new Vector3D(-20,50,50);
        lite3D.normalize();
        var dispParts:Array = new Array();
        for each (var object:Object in objects) {
            object.matrix3D = new Matrix3D();
            object.matrix3D.appendRotation(object.rotationX,Vector3D.X_AXIS);
            object.matrix3D.appendRotation(object.rotationY,Vector3D.Y_AXIS);
            object.matrix3D.appendRotation(object.rotationZ,Vector3D.Z_AXIS);
            object.matrix3D.prependTranslation(object.x,object.y,object.z);
            object.matrix3D.append(object.parent.matrix3D);
            if (object.verts.length) {
                object.realVerts3D = new Vector.<Number>();
                object.projVerts2D = new Vector.<Number>();
                var uvts:Vector.<Number> = new Vector.<Number>();
                object.matrix3D.transformVectors(object.verts, object.realVerts3D);
                Utils3D.projectVectors(camera.matrix3D, object.realVerts3D, object.projVerts2D, uvts);
                var numParts:uint = object.indices.length/3;
                for (var i:uint = 0; i < numParts; i++) {
                    var part:Part = new Part(object);
                    part.indices.push(object.indices[i*3+0],object.indices[i*3+1],object.indices[i*3+2]);
                    var realVerts3D:Vector.<Number> = new Vector.<Number>();
                    part.verts = new Vector.<Number>();
                    var vectors:Array = new Array();
                    var nX:Number = 0;
                    var nY:Number = 0;
                    var nZ:Number = 0;
                    for (var j:uint = 0; j < 3; j++) {
                        var vector:Vector3D = new Vector3D(object.realVerts3D[part.indices[j]*3+0],
                                                           object.realVerts3D[part.indices[j]*3+1],
                                                           object.realVerts3D[part.indices[j]*3+2]);
                        vectors.push(vector);
                        nX += vector.x;
                        nY += vector.y;
                        nZ += vector.z;
                        part.verts.push(object.projVerts2D[part.indices[j]*2+0]);
                        part.verts.push(object.projVerts2D[part.indices[j]*2+1]);
                    }
                    part.z = nZ/3;
                    part.distance = Vector3D.distance(viewPoint, new Vector3D(nX/3,nY/3,nZ/3));
                    
                    var vA:Vector3D = vectors[0].subtract(vectors[1]);
                    var vB:Vector3D = vectors[0].subtract(vectors[2]);
                    
                    part.normal = vA.crossProduct(vB);
                    part.normal.normalize();
                    
                    var vV:Vector3D = vectors[0].subtract(new Vector3D(0,0,-camera.focalLength));
                    var dotProduct:Number = vV.dotProduct(part.normal);
                    if (dotProduct > 0) {
                        part.shadowRatio = lite3D.dotProduct(part.normal)/4+0.75;
                        dispParts.push(part);
                    }
                }
            }
        }
        dispParts.sortOn(["z","distance"], [Array.NUMERIC|Array.DESCENDING,Array.NUMERIC|Array.DESCENDING]);
        var numDispParts:uint = dispParts.length;
        for (i = 0; i < numDispParts; i++) {
            var hsv:ColorHSV = dispParts[i].object.colorHSV;
            hsv.v = dispParts[i].shadowRatio;
            var color:int = hsv.value;
            canvas.graphics.beginFill(color);
            canvas.graphics.drawTriangles(dispParts[i].verts);//, null, null, TriangleCulling.NEGATIVE);
            canvas.graphics.endFill();
        }
    }
    public function getAllChildren(container:Object):void {
        var numChild:uint = container.numChildren;
        for (var i:uint = 0; i < numChild; i++) {
            var child:Object = container.getChildAt(i);
            objects.push(child);
            if (child.numChildren > 0) {
                getAllChildren(child);
            }
        }
    }
    public function getNormal(verts:Vector.<Number>):Vector3D {
        var normal:Vector3D = new Vector3D();
        return normal;
    }
}
class Part {
    public var indices:Vector.<Number>;
    public var verts:Vector.<Number>;
    public var distance:Number;
    public var object:Object;
    public var z:Number;
    public var normal:Vector3D;
    public var shadowRatio:Number;
    public function Part(obj:Object):void {
        object = obj;
        indices = new Vector.<Number>();
    }
}
class Camera3D extends Sprite {
    public var nDistance:Number;
    public var matrix3D:Matrix3D;
    public var fllow:Boolean=false;
    public var proj:PerspectiveProjection;
    public var normal:Vector3D;
    public function Camera3D():void {
        proj = new PerspectiveProjection();
    }
    public function set focalLength(nNum:Number):void {
        proj.focalLength = nNum;
        setting();
    }
    public function get focalLength():Number {
        return proj.focalLength;
    }
    public function set fieldOfView(nNum:Number):void {
        proj.fieldOfView = nNum;
        setting();
    }
    public function get fieldOfView():Number {
        return proj.fieldOfView;
    }
    public function set projectionCenter(nP:Point):void {
        proj.projectionCenter = nP;
        setting();
    }
    public function get projectionCenter():Point {
        return proj.projectionCenter;
    }
    public function setting():void {
        matrix3D = new Matrix3D();
        matrix3D.appendTranslation(0,0,focalLength);
        matrix3D.append(proj.toMatrix3D());
        normal = Vector3D.Z_AXIS;
    }
}
class Object3D extends Sprite {
    public var matrix3D:Matrix3D = new Matrix3D();
    public var verts:Vector.<Number> = new Vector.<Number>();
    public var indices:Vector.<int>  = new Vector.<int>();
    public var parts:Array;
    public var realVerts3D:Vector.<Number>;
    public var projVerts2D:Vector.<Number>;
    public var colorHSV:ColorHSV = new ColorHSV(25,0.4,0.5);
    public function Object3D():void {
    }
    public function vertsOffset(nX:Number, nY:Number, nZ:Number):void {
        var matrix3D:Matrix3D = new Matrix3D();
        matrix3D.prependTranslation(nX,nY,nZ);
        matrix3D.transformVectors(verts,verts);
    }
}
class Joint3D extends Object3D {
    public function Joint3D():void {
    }
}
class Cube3D extends Object3D {
    public function Cube3D(nWidth:Number=100, nHeight:Number=100, nDepth:Number=100):void {
        verts.push(-nWidth,-nHeight,-nDepth);
        verts.push( nWidth,-nHeight,-nDepth);
        verts.push(-nWidth, nHeight,-nDepth);
        verts.push( nWidth, nHeight,-nDepth);
        verts.push(-nWidth,-nHeight, nDepth);
        verts.push( nWidth,-nHeight, nDepth);
        verts.push(-nWidth, nHeight, nDepth);
        verts.push( nWidth, nHeight, nDepth);
        indices.push(0,1,2,3,2,1);
        indices.push(1,5,3,7,3,5);
        indices.push(5,4,7,6,7,4);
        indices.push(4,0,6,2,6,0);
        indices.push(4,5,0,1,0,5);
        indices.push(7,6,3,2,3,6);
    }
}
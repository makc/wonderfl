package  {
    import flash.display.Sprite
    import flash.display.Loader;
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Shape;
    import flash.display.TriangleCulling;
    import flash.net.URLLoader;
    import flash.net.URLRequest;
    import flash.system.LoaderContext;
    import flash.utils.Dictionary;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Vector3D;
    import flash.geom.Matrix3D;
    import flash.geom.Point;
    import flash.geom.PerspectiveProjection;
    import flash.geom.Utils3D;
    import flash.events.KeyboardEvent;
    import com.bit101.components.Label;
    import com.bit101.components.HUISlider;
    import com.bit101.components.InputText;
    import com.bit101.components.PushButton;
    import com.bit101.components.RotarySelector;
    import com.bit101.components.NumericStepper;

    public class IcoSphere extends Sprite {
        private var icoSphere      :IcoSphereCreator      = new IcoSphereCreator(0,-400,0);
        private var matrix         :Matrix3D              = new Matrix3D();
        private var drag           :Boolean               = false;
        private var start_m        :Vector3D              = new Vector3D();
        private var old_mouse      :Vector3D              = new Vector3D();
        private var new_mouse      :Vector3D              = new Vector3D();
        private var center         :Point                 = new Point(stage.stageWidth/2, stage.stageHeight/2);
        
        private var loader         :Loader;
        private var MAP            :BitmapData;
        private var GRAPHIC_URL    :String                = "http://www.k3lab.com/wonderfl/Amphisbaena/photo.jpg";
        
        private var viewport       :Shape                 = new Shape();
        private var world          :Matrix3D              = new Matrix3D();
        private var projected      :Vector.<Number>       = new Vector.<Number>;
        private var projection     :PerspectiveProjection = new PerspectiveProjection();
        
        private var gwidth         :int                   = 200;
        private var gheight        :int                   = 200;
        private var land_bmpd      :BitmapData            = new BitmapData(1, 1,false,0x0);
        private var landVertices   :Vector.<Number>       = new Vector.<Number>(0, false);
        private var landProjected  :Vector.<Number>       = new Vector.<Number>(0, false);
        private var landIndices    :Vector.<int>          = new Vector.<int>(0, false);
        private var landUvtData    :Vector.<Number>       = new Vector.<Number>(0, false);
        
        private var dragging       :Point                 = new Point();
        private var mouseStart     :Point                 = new Point();
        private var mouse3D        :Vector3D              = new Vector3D();
        
        private var dragMode       :Boolean               = true;
        
        private var levelLabel     :Label;
        private var levelStepper   :NumericStepper;
        private var sizeSlider     :HUISlider;
        private var shapeSelector  :RotarySelector;
        private var regenButton    :PushButton;
        
        private var regen          :Boolean               = false;
        
        public function IcoSphere() {
            loader = new Loader();
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, init);
            loader.load(new URLRequest(GRAPHIC_URL), new LoaderContext(true));
        }
        
        private function init(e:Event):void
        {
            MAP = Bitmap(loader.content).bitmapData;
            viewport.x = stage.stageWidth / 2;
            viewport.y = stage.stageHeight / 2;

            addChild(viewport);
            var bitmap:Bitmap = new Bitmap(new BitmapData(stage.stageWidth, stage.stageHeight, true, 0x0));
            var hidden:Sprite = new Sprite();
            addChild(hidden);
            hidden.addChild(bitmap);
            var panel:Sprite = new Sprite();
            addChild(panel);
            levelLabel = new Label(panel, 5, 5, "Level");
            levelStepper = new NumericStepper(panel, 35, 5, null);
            sizeSlider = new HUISlider(panel, 5, 22, "size", null);
            shapeSelector = new RotarySelector(panel, 195, 8, "shape", null);
            new PushButton(panel, 90, 5, "Give me ball!", regenerateBall).setSize(83, 16);
            
            levelStepper.setSize(50, 20);
            levelStepper.value = 2;
            levelStepper.minimum = 0;
            levelStepper.maximum = 3;
            sizeSlider.value = 50;
            sizeSlider.minimum = 20;
            sizeSlider.maximum = 100;
            shapeSelector.setSize(20,20);
            shapeSelector.numChoices = 2;
            shapeSelector.choice = 0;
            /*
            levelSlider = new HUISlider(panel, 80, 10, "Level", updateBaseX);
            levelSlider.value = 2;
            levelSlider.minimum = 0;
            levelSlider.maximum = 3;
            /**/
            
            icoSphere.Create(2);
            constructLand();
            
            stage.addEventListener(KeyboardEvent.KEY_DOWN, onkeyDown);
            //stage.addEventListener(KeyboardEvent.KEY_UP, onkeyUp);
            hidden.addEventListener(MouseEvent.MOUSE_DOWN, onmouseDown);
            hidden.addEventListener(MouseEvent.MOUSE_MOVE, onmouseMove);
            stage.addEventListener(MouseEvent.MOUSE_UP, onmouseUp);
            addEventListener(Event.ENTER_FRAME, processing);
        }
        
        private function regenerateBall(...arg):void
        {
            regen = true;
        }
        
        private function constructLand():void
        {
            landVertices.push(-gwidth/2, GB._GROUND_LINE, gheight/2); //TR
            landVertices.push(gwidth/2, GB._GROUND_LINE, gheight/2); //BR
            landVertices.push(-gwidth/2, GB._GROUND_LINE, -gheight/2); //TL
            landVertices.push(gwidth/2, GB._GROUND_LINE, -gheight/2); //BL
            landUvtData.push(0, 0, 0); //0
            landUvtData.push(1, 0, 0); //1
            landUvtData.push(0, 1, 0); //2
            landUvtData.push(1, 1, 0); //3
            landIndices.push(0, 2, 1, 2, 3, 1);
        }
        
        private function processing(e:Event):void
        {
            update();
            paint();
            if(regen)
            {
                icoSphere = new IcoSphereCreator(0,-400,0);
                icoSphere.size = sizeSlider.value;
                icoSphere.shape = shapeSelector.choice;
                icoSphere.Create(levelStepper.value);
                projected = new Vector.<Number>;
                regen = !regen;
            }
        }
        
        private function update():void
        {
            icoSphere.update(matrix);
        }
        
        private function paint():void
        {
            world.identity();
            world.append(matrix);
            
            world.appendTranslation(0, 0, 500);
            world.append(projection.toMatrix3D());
            
            viewport.graphics.clear();
            
            Utils3D.projectVectors(world, landVertices, landProjected, landUvtData);
            viewport.graphics.beginBitmapFill(land_bmpd, null, false, false);
            viewport.graphics.drawTriangles(landProjected, landIndices, landUvtData, TriangleCulling.POSITIVE);
            viewport.graphics.endFill();
            
            Utils3D.projectVectors(world, icoSphere.vertices, projected, icoSphere.uvts);
            viewport.graphics.beginBitmapFill(MAP, null, false, false);
            viewport.graphics.drawTriangles(projected, icoSphere.sortedIndices, icoSphere.uvts, TriangleCulling.POSITIVE);
            viewport.graphics.endFill();
        }
        
        private function onkeyDown(e:KeyboardEvent):void
        {
            dragMode = !dragMode;
        }

        private function onmouseDown(e:MouseEvent):void
        {
            drag = true;
            old_mouse.x = mouseX;
            old_mouse.y = mouseY;
            
            
            mouseStart.x = mouseX;
            mouseStart.y = mouseY;
            var dist:Number = 99999;
            var finder:int = -1;
            var tv1:Vector3D = new Vector3D();
            var tv2:Vector3D = new Vector3D();
            var tp1:Point = new Point();
            var tp2:Point = new Point();
            var tvp:Vector3D = new Vector3D();
            var ratio:Number = 0;
            var focalLength:Number = 500;
            var i:int = 0;
            var currdist:Number = 0;
            var currdist3D:Number = 0;
            
            var joints:Vector.<Joint> = icoSphere.joints;
            for(i = 0; i < joints.length; i++)
            {
                tv1 = matrix.transformVector(joints[i]);
                ratio = focalLength/(focalLength + tv1.z);
                tp1.x = tv1.x * ratio + center.x;
                tp1.y = tv1.y * ratio + center.y;
                currdist = Point.distance(tp1, new Point(mouseX, mouseY));
                
                if(currdist < 10)
                {
                    tvp.x = tv1.x;
                    tvp.y = tv1.y;
                    tvp.z = tv1.z;
                    currdist3D = Vector3D.distance(tvp, new Vector3D(mouseX-center.x, mouseY-center.y, -10000));
                    
                    if(currdist3D < dist)
                    {
                        dist = currdist3D;
                        finder = i;
                    }
                }
            }
            dragMode = finder == -1;
            if(!dragMode) icoSphere.dragAt(finder);
            
        }
        
        private function onmouseUp(e:MouseEvent):void
        {
            drag = false;
            icoSphere.undrag();
        }
        
        private function onmouseMove(e:MouseEvent):void
        {
            new_mouse.x = mouseX;
            new_mouse.y = mouseY;
            
            if(drag)
            if(dragMode)
            {
                var difference:Vector3D = new Vector3D(new_mouse.x - old_mouse.x, new_mouse.y - old_mouse.y);
                var vector:Vector3D = new Vector3D(difference.x, difference.y, 0);
 
                var rotationAxis:Vector3D = vector.crossProduct(new Vector3D(0,0,1));
                rotationAxis.normalize();
                
                var distance:Number = Math.sqrt(difference.x * difference.x + difference.y * difference.y);
                var rotationMatrix:Matrix3D = new Matrix3D();
                rotationMatrix.appendRotation(distance/150*180/Math.PI, rotationAxis);
                matrix.append(rotationMatrix);
            }
            else
            {
                var vx:Number = mouseX - mouseStart.x;
                var vy:Number = mouseY - mouseStart.y;
                var im:Matrix3D = matrix.clone();
                im.invert();
                var new_offset:Vector3D = im.transformVector(new Vector3D(vx, vy, 0));
                icoSphere.updateOffset(new_offset);
            }
            
            old_mouse.x = mouseX;
            old_mouse.y = mouseY;
        }
    }
    
}
import flash.geom.Vector3D;
import flash.utils.Dictionary;

class TriangleIndices
{
    public var v1:int;
    public var v2:int;
    public var v3:int;

    public function TriangleIndices(A:int, B:int, C:int)
    {
        v1 = A;
        v2 = B;
        v3 = C;
    }
}

// Icosphere generator from http://blog.andreaskahler.com/2009/06/creating-icosphere-mesh-in-code.html
// with some modification
class IcoSphereCreator
{
    private var index:int;
    private var middlePointIndexCache:Dictionary;// = new Dictionary(true);
    public var ifaces:Vector.<TriangleIndices>;
    public var sfaces:Array = new Array();
    public var faces:Vector.<Face3D> = new Vector.<Face3D>();
    public var joints:Vector.<Joint> = new Vector.<Joint>();
    private var jointCache:Dictionary;
    public var position:Joint = new Joint();
    
    public var vertices:Vector.<Number> = new Vector.<Number>();
    public var indices:Vector.<int> = new Vector.<int>();
    public var uvts:Vector.<Number> = new Vector.<Number>();
    public var sortedIndices:Vector.<int> = new Vector.<int>();
    
    public var dragging:int = -1;
    public var locked:Joint = new Joint();
    private var offset:Joint = new Joint();
    
    public var size:Number = 50;
    public var shape:int = 0;

    public function IcoSphereCreator(px:Number = 0, py:Number = 0, pz:Number = 0) {position.read(px, py, pz);}

    // add vertex to mesh, fix position to be on unit sphere, return index
    private function addVertex(p:Vector3D):int
    {
        var length:Number = Math.sqrt(p.x * p.x + p.y * p.y + p.z * p.z);
        if(!shape)
               joints.push(new Joint(p.x/length, p.y/length, p.z/length));
        else
            joints.push(new Joint(p.x, p.y, p.z));
        return index++;
    }

    // return index of point in the middle of p1 and p2
    private function getMiddlePoint(p1:int, p2:int):int
    {
        // first check if we have it already
        var firstIsSmaller:Boolean = p1 < p2;
        var smallerIndex:uint = firstIsSmaller ? p1 : p2;
        var greaterIndex:uint = firstIsSmaller ? p2 : p1;
        var key:uint = (smallerIndex << 16) + greaterIndex;
        var ret:int;
        if (ret = middlePointIndexCache[key])
        {
            return ret;
        }

        // not in cache, calculate it
        var point1:Joint = joints[p1];
        var point2:Joint = joints[p2];
        var middle:Joint = new Joint((point1.x + point2.x) / 2.0, (point1.y + point2.y) / 2.0, (point1.z + point2.z) / 2.0);

        // add vertex makes sure point is on unit sphere
        var i:int = addVertex(middle); 

        // store it, return index
        middlePointIndexCache[key] = i;
        return i;
    }

    //public MeshGeometry3D Create(int recursionLevel)
    public function Create(recursionLevel:int):void
    {
        //this.geometry = new MeshGeometry3D();
        middlePointIndexCache = new Dictionary(true);
        index = 0;

        // create 12 vertices of a icosahedron
        var t:Number = (1.0 + Math.sqrt(5.0)) / 2.0;

        addVertex(new Joint(-1,  t,  0));
        addVertex(new Joint( 1,  t,  0));
        addVertex(new Joint(-1, -t,  0));
        addVertex(new Joint( 1, -t,  0));

        addVertex(new Joint( 0, -1,  t));
        addVertex(new Joint( 0,  1,  t));
        addVertex(new Joint( 0, -1, -t));
        addVertex(new Joint( 0,  1, -t));

        addVertex(new Joint( t,  0, -1));
        addVertex(new Joint( t,  0,  1));
        addVertex(new Joint(-t,  0, -1));
        addVertex(new Joint(-t,  0,  1));


        // create 20 triangles of the icosahedron
        ifaces = new Vector.<TriangleIndices>();

        // 5 faces around point 0
        ifaces.push(new TriangleIndices(0, 11, 5));
        ifaces.push(new TriangleIndices(0, 5, 1));
        ifaces.push(new TriangleIndices(0, 1, 7));
        ifaces.push(new TriangleIndices(0, 7, 10));
        ifaces.push(new TriangleIndices(0, 10, 11));

        // 5 adjacent faces 
        ifaces.push(new TriangleIndices(1, 5, 9));
        ifaces.push(new TriangleIndices(5, 11, 4));
        ifaces.push(new TriangleIndices(11, 10, 2));
        ifaces.push(new TriangleIndices(10, 7, 6));
        ifaces.push(new TriangleIndices(7, 1, 8));

        // 5 faces around point 3
        ifaces.push(new TriangleIndices(3, 9, 4));
        ifaces.push(new TriangleIndices(3, 4, 2));
        ifaces.push(new TriangleIndices(3, 2, 6));
        ifaces.push(new TriangleIndices(3, 6, 8));
        ifaces.push(new TriangleIndices(3, 8, 9));

        // 5 adjacent faces 
        ifaces.push(new TriangleIndices(4, 9, 5));
        ifaces.push(new TriangleIndices(2, 4, 11));
        ifaces.push(new TriangleIndices(6, 2, 10));
        ifaces.push(new TriangleIndices(8, 6, 7));
        ifaces.push(new TriangleIndices(9, 8, 1));

        var i:int = 0
        var tri:TriangleIndices;
        // refine triangles
        for (i = 0; i < recursionLevel; i++)
        {
            var faces2:Vector.<TriangleIndices> = new Vector.<TriangleIndices>();
            for each (tri in ifaces)
            {
                // replace triangle by 4 triangles
                var a:int = getMiddlePoint(tri.v1, tri.v2);
                var b:int = getMiddlePoint(tri.v2, tri.v3);
                var c:int = getMiddlePoint(tri.v3, tri.v1);

                faces2.push(new TriangleIndices(tri.v1, a, c));
                faces2.push(new TriangleIndices(tri.v2, b, a));
                faces2.push(new TriangleIndices(tri.v3, c, b));
                faces2.push(new TriangleIndices(a, b, c));
            }
            ifaces = faces2;
        }
        
        for(i = 0; i < joints.length; i++)
        {
            //positions[i].normalize();
            //joints[i].scaleBy(GB._RADIUS);
            joints[i].scaleBy(size);
            joints[i].x += position.x;
            joints[i].y += position.y;
            joints[i].z += position.z;
            joints[i].addConstraint(position);
            vertices.push(joints[i].x, joints[i].y, joints[i].z);
            uvts.push(0,0,0);
        }
        
        jointCache = new Dictionary(true);
        var f:int = 0;
        for(i = 0; i < ifaces.length; i++)
        {
            addJoint(ifaces[i].v1, ifaces[i].v2);
            addJoint(ifaces[i].v2, ifaces[i].v3);
            addJoint(ifaces[i].v1, ifaces[i].v3);
            f = faces.length;
            faces.push(createFace(ifaces[i].v1, ifaces[i].v2, ifaces[i].v3));
            sfaces.push(new Vector3D());
            joints[ifaces[i].v1].faces.push(faces[f]);
            joints[ifaces[i].v2].faces.push(faces[f]);
            joints[ifaces[i].v3].faces.push(faces[f]);
            indices.push(ifaces[i].v1, ifaces[i].v2, ifaces[i].v3);
            sortedIndices.push(ifaces[i].v1, ifaces[i].v2, ifaces[i].v3);
        }     
    }
    
    private function addJoint(A:int, B:int):void
    {
        // first check if we have it already
        var firstIsSmaller:Boolean = A < B;
        var smallerIndex:uint = firstIsSmaller ? A : B;
        var greaterIndex:uint = firstIsSmaller ? B : A;
        var key:uint = (smallerIndex << 16) + greaterIndex;
        if (jointCache[key])
        {
            return;
        }

        joints[A].addConstraint(joints[B]);

        // store it, return index
        jointCache[key] = true;
    }
    
    private function createFace(A:int, B:int, C:int):Face3D
    {
        return new Face3D(joints[A], joints[B], joints[C]);
    }
    
    private function calcNORMS():void
    {
        var i:int = 0;
        for(i = 0; i < faces.length; i++)
        {
            faces[i].calculateFaceNormal();
        }
    }
    
    public function updateOffset(m:Vector3D):void
    {
        offset.eat(m);
    }
    
    public function dragAt(i:int):void
    {
        locked.eat(joints[dragging = i]);
    }
    
    public function undrag():void
    {
        dragging = -1;
    }
    
    public function update(trans:Matrix3D):void
    {
        var j:Joint;
        for each(j in joints) j.updateRForce(dragging >= 0 && joints[dragging]==j);
        for each(j in joints) j.updateForce(dragging >= 0 && joints[dragging]==j, locked.add(offset)/**/);
        for each(j in joints) j.move();
        position.updateRForce();
        position.updateForce();
        position.move();
        calcNORMS();
        var i:int = 0;
        for(i = 0; i < joints.length; i++)
        {
            joints[i].calculateNorm();
            joints[i].norm = trans.transformVector(joints[i].norm);
            //joints[i].norm = joints[i].norm;
            vertices[i*3  ] = joints[i].x;
            vertices[i*3+1] = joints[i].y;
            vertices[i*3+2] = joints[i].z;
            uvts[i*3  ] = 0.5+joints[i].norm.x*0.5;
            uvts[i*3+1] = 0.5+joints[i].norm.y*0.5;
            uvts[i*3+2] = 0.5+joints[i].norm.z*0.5;
        }
        resort();
    }
    
    public function resort():void
    {
        var i:int = 0;
        var face:Vector3D;
        var inc:int = 0;
        var i1:uint = 0x0;
        var i2:uint = 0x0;
        var i3:uint = 0x0;
        for (i = 0; i < indices.length; i+=3){
            i1 = indices[ i+0 ];
            i2 = indices[ i+1 ];
            i3 = indices[ i+2 ];
            face = sfaces[inc];
            face.x = i1;
            face.y = i2;
            face.z = i3;
            face.w = (uvts[i1 * 3 + 2] + uvts[i2 * 3 + 2] + uvts[i3 * 3 + 2]) * 0.333333;
            inc++;
        }
        sfaces.sortOn("w", Array.DESCENDING | Array.NUMERIC);
        inc = 0;
        for each (face in sfaces){
            sortedIndices[inc++] = face.x;
            sortedIndices[inc++] = face.y;
            sortedIndices[inc++] = face.z;
        }
    }
}

import flash.geom.Vector3D;
import flash.geom.Matrix3D;

class Joint extends Vector3D
{
    private var vertices:Vector.<int> = new Vector.<int>();
    private var angles:Matrix3D = new Matrix3D();
    private var vr:Matrix3D = new Matrix3D();
    public var constraints:Vector.<Constraint> = new Vector.<Constraint>();
    public var faces:Vector.<Face3D> = new Vector.<Face3D>();
    public var fixed:Boolean = false;
    public var locked:Boolean = false;
    public var a:Vector3D = new Vector3D();
    public var vt:Vector3D = new Vector3D();
    public var norm:Vector3D = new Vector3D();
    
    //temp
    public var verts:Vector.<Vector3D> = new Vector.<Vector3D>();
    public var vert:Vector3D = new Vector3D();
    
    public function Joint(px:Number = 0, py:Number = 0, pz:Number = 0)
    {
        super(px, py, pz);
    }
    
    public function eat(j:Vector3D):Joint
    {
        x = j.x; y = j.y; z = j.z; return this;
    }
    
    public function read(px:Number = 0, py:Number = 0, pz:Number = 0):Joint
    {
        x = px; y = py; z = pz; return this;
    }
    
    public function checkConnection(v:Joint):void
    {
        if(!locked && v.locked && Vector3D.distance(Vector3D(this), v) < GB._DISTANCE)
        {
            addConstraint(v, GB._DISTANCE);
            locked = true;
        }
    }
    
    public function addConstraint(v:Joint, d:Number = -1):void
    {
        constraints.push(new Constraint(this, v, d));
    }
    
    public function has(v:Joint):Boolean
    {
        for each(var c:Constraint in constraints) if(c.to == v) return true;
        return false;
    }
    
    public function updateConnectRForce(c:Constraint):void
    {
        connectRForce(this, c.to, c.vTo);
        connectRForce(c.to, this, c.vFrom);
    }
    
    public function connectRForce(aj:Joint, bj:Joint, cv:Vector3D):void
    {
        var CURR_VECTOR:Vector3D = bj.subtract(Vector3D(aj));
        var NEW_VECTOR:Vector3D = aj.angles.transformVector(cv);
        var degree:Number = Vector3D.angleBetween(NEW_VECTOR, CURR_VECTOR);
        if(isNaN(degree)) degree = 0;
        var right:Vector3D = NEW_VECTOR.crossProduct(CURR_VECTOR);
        right.normalize();
        var matrix:Matrix3D = new Matrix3D();
        matrix.identity();
        matrix.appendRotation(degree/Math.PI*180, right);
        aj.vr.append(Matrix3D.interpolate(GB._originMATRIX, matrix, GB._ROTATION_RATE));
    }
    
    public function updateConnectForce(c:Constraint):void
    {
        connectForce(this, c.to, c.vTo);
        connectForce(c.to, this, c.vFrom);
    }
    
    public function connectForce(aj:Joint, bj:Joint, cv:Vector3D):void
    {
        var v:Vector3D = aj.angles.transformVector(cv);
        var toVector:Vector3D = aj.add(v);
        var ax:Number = (bj.x - toVector.x) * GB._VERTICAL_RATE;
        var ay:Number = (bj.y - toVector.y) * GB._VERTICAL_RATE;
        var az:Number = (bj.z - toVector.z) * GB._VERTICAL_RATE;
        aj.a.x += ax;
        aj.a.y += ay;
        aj.a.z += az;
        bj.a.x -= ax;
        bj.a.y -= ay;
        bj.a.z -= az;
    }
    
    public function move():void
    {
        a.x += -GB._FRICTION * vt.x;
        a.y += -GB._FRICTION * vt.y;
        a.z += -GB._FRICTION * vt.z;
        vt.x += a.x;
        vt.y += a.y;
        vt.z += a.z;
        x += vt.x;
        y += vt.y;
        z += vt.z;
        a.x = 0;
        a.y = 0;
        a.z = 0;
        if (GB._GROUND_LINE < y){
            y = GB._GROUND_LINE;
            vt.y *= -GB._GBOUNCE;
            if (vt.y < -30) vt.y = -50;
            vt.x *= GB._GROUND_FRICTION;
            vt.z *= GB._GROUND_FRICTION;
        }
        
        vert = angles.transformVector(new Vector3D(1,0,0));
        vert.scaleBy(20);
    }
    
    public function updateRForce(k:Boolean = false):void
    {
        for each(var cR:Constraint in constraints)
        {
            updateConnectRForce(cR);
        }
        vr = Matrix3D.interpolate(GB._originMATRIX, vr, (k)?GB._MOUSE_ROTATE_FRICTION:GB._ROTATE_FRICTION);
        angles.append(vr);
    }
    
    public function updateForce(k:Boolean = false, m:Vector3D = null):void
    {
        for each(var c:Constraint in constraints)
        {
            updateConnectForce(c);
        }
        a.y += GB._GRAVITY;
        if (k)
        {
            var point:Joint = pullForce(this, m, GB._MOUSE_PULL_RATE);
            a.x += point.x;
            a.y += point.y;
            a.z += point.z;
            
            vt.x *= GB._MOUSE_MOVE_FRICTION;
            vt.y *= GB._MOUSE_MOVE_FRICTION;
            vt.z *= GB._MOUSE_MOVE_FRICTION;
        }
    }
    
    private function pullForce(A:Vector3D, B:Vector3D, rate:Number):Joint {
        var dist:Number = Vector3D.distance(A,B);
        return (dist>0)?new Joint((B.x - A.x) / dist * rate, (B.y - A.y) / dist * rate, (B.z - A.z) / dist * rate):new Joint();
    }
    
    public function calculateNorm():void
    {
        var I:int = 0;
        //norm.x = x; norm.y = y; norm.z = z;
        //norm.normalize();
        norm.x = 0; norm.y = 0; norm.z = 0;
        for(I = 0; I < faces.length; I++)
        {
            norm.x += faces[I].norm.x;
            norm.y += faces[I].norm.y;
            norm.z += faces[I].norm.z;
        }
        norm.normalize();
    }
}

class Constraint
{
    public var to:Joint;
    public var vTo:Vector3D;
    public var vFrom:Vector3D;
    public function Constraint(J:Joint, v:Joint, d:Number = -1)
    {
        to = v;
        vTo = to.subtract(Vector3D(J));
        vFrom = J.subtract(Vector3D(to));
        if(d>=0)
        {
            vTo.normalize();
            vTo.scaleBy(d);
            vFrom.normalize();
            vFrom.scaleBy(d);
        }
    }
}

class Face3D
{
    public var vertex1:Joint;
    public var vertex2:Joint;
    public var vertex3:Joint;
    public var norm:Vector3D = new Vector3D();
    public function Face3D(A:Joint, B:Joint, C:Joint) {vertex1 = A; vertex2 = B; vertex3 = C;}
    
    public function calculateFaceNormal():void
    {
        var TV2:Vector3D = vertex2.subtract(vertex1);
        var TV3:Vector3D = vertex3.subtract(vertex1);
        norm = TV2.crossProduct(Vector3D(TV3));
        norm.normalize();
    }
}

class GB
{
    public static const _DISTANCE              :Number = 30;
    public static const _LIMIT_DISTANCE        :Number = 50;
    public static const _WALL_LEFT             :Number = 0;
    public static const _WALL_RIGHT            :Number = 465;
    public static const _GROUND_LINE           :Number = 150;
    
    public static const _DOT_CONNECT_MAX       :int    = 4;
    public static const _DERIVATION            :int    = 5;    // 計算の分割数。  //3
    public static const _MAP_SIZE              :Number = 400;
    
    public static const _PI                    :Number = Math.PI;
    public static const _PI2                   :Number = 2.0 * _PI;
    public static const _RADIAN90              :Number = _PI * 0.5;
    public static const _RADIAN180             :Number = _PI * 1.0;
    public static const _RADIAN270             :Number = _PI * -0.5;
////v0.2
    public static const _RADIAN360             :Number = _PI * 2;
    public static const _TO_DEGREE             :Number = 180 / _PI;
    
    public static const _RADIUS                :Number = 50;
    
    public static const _MAXCOMP               :Number = 0.0000133;
    public static const _COMP                  :Number = 0.0000133;  //0.1
    public static const _GRAVITY               :Number = 0.3 / _DERIVATION;  //0.3  //0.6
    public static const _ROTATION_RATE         :Number = 0.03 / _DERIVATION;    // 自身バネ（根元） //0.05
    public static const _VERTICAL_RATE         :Number = 0.01 / _DERIVATION;    // ターゲットバネ（さきっぽ） //0.2  //0.133
    public static const _MOUSE_PULL_RATE       :Number = 10 / _DERIVATION;
    
    public static const _GBOUNCE               :Number = 0.8;  // 0.8
    
    public static const _FRICTION              :Number = 0.1 / _DERIVATION;      // 0.1
    public static const _ROTATE_FRICTION       :Number = 1 - 0.2 / _DERIVATION;  // 1 - 0.2
    public static const _MOUSE_ROTATE_FRICTION :Number = 1 - 0.8 / _DERIVATION;  // 1 - 0.8
    public static const _MOUSE_MOVE_FRICTION   :Number = 1 - 0.5 / _DERIVATION;  // 1 - 0.5
    public static const _GROUND_FRICTION       :Number = 1 - 0.2 / _DERIVATION;  // 1 - 0.2
    public static const _originMATRIX          :Matrix3D = new Matrix3D();
    
    public function GB()
    {
        
    }
}
package  {
    import flash.text.TextField;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    import flash.filters.DisplacementMapFilter;
    import flash.display.DisplayObject;
    import flash.utils.Dictionary;
    import flash.geom.Vector3D;
    import flash.events.KeyboardEvent;
    
    import org.papervision3d.core.proto.*;
    import org.papervision3d.lights.*;
    import org.papervision3d.view.BasicView;
    import org.papervision3d.core.geom.*;
    import org.papervision3d.core.math.*;
    import org.papervision3d.core.utils.*;
    import org.papervision3d.materials.*;
    import org.papervision3d.materials.shadematerials.*;
    import org.papervision3d.materials.utils.*;
    import org.papervision3d.materials.special.*;
    import org.papervision3d.objects.primitives.*;
    import org.papervision3d.objects.DisplayObject3D;
    import org.papervision3d.events.InteractiveScene3DEvent;
    import org.papervision3d.core.render.data.RenderHitData;
    import org.papervision3d.view.layer.ViewportBaseLayer;
    import org.papervision3d.core.render.command.RenderTriangle;
    import org.papervision3d.core.geom.renderables.Vertex3D;
    
    import jiglib.math.*;
    import jiglib.geometry.*;
    import jiglib.physics.*;
    import jiglib.physics.constraint.*;
    import jiglib.plugin.papervision3d.*;
    
    import net.hires.debug.Stats;
    import org.papervision3d.core.geom.renderables.Triangle3D;
    
    [SWF(width=465,height=465,backgroundColor=0xFFFFFF,frameRate=60)]
    public class Main extends BasicView {
        private var _light : LightObject3D;
        private var cp:Point = new Point(stage.stageWidth/2, stage.stageHeight/2);
        private var mouse3D:Mouse3D;
        private var _pv3dp : Papervision3DPhysics;
        private var _potatos : Vector.<RigidBody> = new Vector.<RigidBody>();
        private var pauseIt:Boolean = false;
        private var remStart2D:Point = new Point();
        private var remEnd2D:Point = new Point();
        public function Main() {
            super(0, 0, true, false);
            init3D();
            addChild(new Stats());
            startRendering();
        }
        
        private function init3D():void
        {
            PhysicsSystem.getInstance().setGravity(new Vector3D(0, -30, 0));
            PhysicsSystem.getInstance().setSolverType("FAST");
            
            _light = new PointLight3D(true, true);
            _light.x = 100; _light.y = 100; _light.z = 0;

            camera.z = -300;
            viewport.interactive = true;
            Mouse3D.enabled=true;
            mouse3D=viewport.interactiveSceneManager.mouse3D;

            _pv3dp = new Papervision3DPhysics(scene, 5);
            
            stage.addEventListener(MouseEvent.MOUSE_DOWN, onmouseDown);
            stage.addEventListener(Event.ENTER_FRAME, processing);
            stage.addEventListener(KeyboardEvent.KEY_DOWN, onkeyDown);
        }
        
        private function onmouseDown(e:MouseEvent):void
        {
            var la:int = _potatos.length;
            var ml : MaterialsList = new MaterialsList();
            var obj3D:DisplayObject3D;
            var FSM:FlatShadeMaterial;
            var spectrum = Math.round( 0xEEEEEE);
            FSM = new FlatShadeMaterial(_light, spectrum);
            FSM.doubleSided = true;
            FSM.interactive = true;
            ml.addMaterial(FSM, "all");
            
            var potato : RigidBody = (Math.random() > 0.5)?_pv3dp.createSphere(FSM, 40, 10, 10):_pv3dp.createCube(ml, 30+Math.random()*40, 30+Math.random()*40, 30+Math.random()*40);
            obj3D = _pv3dp.getMesh(potato);
            addEvents(obj3D);
            potato.mass = 10;
            potato.y = -150;
            potato.x = 0;
            potato.z = 0;
            _potatos.push(potato);
            _potatos[la].addBodyForce(new Vector3D(0, 15000, 0), new Vector3D(0, 0, 0));
        }
        
        private function handleOver(e:InteractiveScene3DEvent):void
        {
            remStart2D.x = mouseX - cp.x;
            remStart2D.y = mouseY - cp.y;
        }
        
        private function handleOut (e:InteractiveScene3DEvent):void
        {
            var obj:* = e.displayObject3D;
            remEnd2D.x = mouseX - cp.x;
            remEnd2D.y = mouseY - cp.y;
            var normal:Number3D = new Number3D((remEnd2D.y-remStart2D.y), (remEnd2D.x-remStart2D.x),0);
            var mat3d:Matrix3D = new Matrix3D();
            mat3d.copy(obj.transform);
            mat3d.invert();
            Matrix3D.multiplyVector3x3(mat3d,normal);
            var point:Number3D = new Number3D(0,0,0);
            var cutObj:Plane3D = Plane3D.fromNormalAndPoint(normal,point);
            var mesh:Array = MeshUtil.cutTriangleMesh(TriangleMesh3D(obj), cutObj);
            if(mesh.length>1)
            {
                var newMesh:DisplayObject3D;
                var jsphere:JSphere;
                var stack:int = 0;
                var f:Triangle3D;
                for each(var m:TriangleMesh3D in mesh)
                {
                    newMesh = m;
                    
                    for each(f in m.geometry.faces) f.instance = newMesh;
                    
                    scene.addChild(newMesh);
                    addEvents(newMesh);
                    newMesh.copyTransform(obj);

                    jsphere = new JSphere(new Pv3dMesh(newMesh), 40);
                    _pv3dp.addBody(jsphere);
                    _potatos.push(jsphere);
                    jsphere.addBodyForce(new Vector3D(450*(stack%2?-1:1), 300, 0), new Vector3D(0, 10, 0));
                    jsphere.mass = 2;
                    jsphere.z = newMesh.z;
                    jsphere.y = newMesh.y;
                    jsphere.x = newMesh.x;
                    jsphere.rotationX = newMesh.rotationX;
                    jsphere.rotationY = newMesh.rotationY;
                    jsphere.rotationZ = newMesh.rotationZ;
                    stack++;
                }
                if(mesh.length > 0)
                for(var j:int = 0; j < scene.numChildren; j++)
                {
                    if(scene.objects[j] == obj)
                    {
                        var rb:RigidBody;
                        for(var k:int = 0; k < _potatos.length; k++)
                        {
                            rb = _potatos[k];
                            if(_pv3dp.getMesh(rb) == obj)
                            {
                                _pv3dp.removeBody(rb);
                                _potatos.splice(k,1);
                            }
                        }
                        scene.removeChild(obj);
                    }
                }
            }
        }
        private function onkeyDown(e:KeyboardEvent):void
        {
            pauseIt = !pauseIt;
        }
        override protected function onRenderTick(e : Event = null) : void
        {
            if(pauseIt) return;
            _pv3dp.step();
            super.onRenderTick(e);
        }
        private function processing(e:Event):void
        {
            var i:int, k:int = 0;
            for(i = 0; i < scene.numChildren; i++)
            {
                if(scene.objects[i].y < -200 || scene.objects[i].x < - 200 || scene.objects[i].y > 200)
                {
                    var rb:RigidBody;
                    for(k = 0; k < _potatos.length; k++)
                    {
                        rb = _potatos[k];
                        if(_pv3dp.getMesh(rb) == scene.objects[i])
                        {
                            _pv3dp.removeBody(rb);
                            _potatos.splice(k, 1);
                            
                        }
                    }
                    scene.removeChild(scene.objects[i]);
                }
            }
        }
        private function addEvents(m:DisplayObject3D):void
        {
            m.addEventListener(InteractiveScene3DEvent.OBJECT_OVER, handleOver);    
            m.addEventListener(InteractiveScene3DEvent.OBJECT_OUT,  handleOut);
        }
    }
}
/*===================================================*//**
 * Box2DAS3 and Papervision3D Demo
 * ドラッグで3Dを回転できます。
 * マウスホイールで拡大できます。
 * 後ろ側の緑色のはBox2Dの2次元表示です。
 * 
 * rsakane さんの投稿から Folk させていただきました。
 *
 * @author Yasu
 * @see http://clockmaker.jp/blog/
 * @since 2009.04.02
 *//*===================================================*/
package
{
    import Box2D.Collision.Shapes.*;
    import Box2D.Collision.b2AABB;
    import Box2D.Common.Math.b2Vec2;
    import Box2D.Dynamics.Joints.*;
    import Box2D.Dynamics.*;
    
    import org.papervision3d.cameras.CameraType;
    import org.papervision3d.materials.utils.MaterialsList;
    import org.papervision3d.render.QuadrantRenderEngine;
    
    import flash.display.*;
    import flash.events.*;
    import flash.geom.*;
    import flash.net.*;
    import flash.ui.*;
    import flash.utils.getTimer;
    import flash.utils.Timer;
    
    import org.papervision3d.events.*;
    import org.papervision3d.lights.*;
    import org.papervision3d.materials.shadematerials.*;
    import org.papervision3d.objects.*;
    import org.papervision3d.view.*;
    import org.papervision3d.objects.primitives.*;
    
    import caurina.transitions.Tweener;
    
    [SWF(width="465", height="465", frameRate="60", backgroundColor="0xFFFFFF")]
    public class Main extends BasicView
    {
        // const vars
        static public const OBJ_SIZE:int = 20;
        static public const OBJ_COLOR:uint = 0x666666;
        
        static private const CAMERA_DISTANCE:int = 1000;
        
        // vars for Box2D
        private var worldWidth:Number;
        private var worldHeight:Number;
        private var m_iterations:int;
        private var m_wallWidth:Number;
        private var m_wallHeight:Number;
        private var m_timeStep:Number;
        private var m_physScale:Number;
        private var m_world:b2World;
        private var m_mouseJoint:b2MouseJoint;
        private var m_draggedBody:b2Body;
        private var mouseXWorldPhys:Number;
        private var mouseYWorldPhys:Number;
        private var isMouseDown:Boolean;
        private var arrayIndex:int;
        
        // array of objs
        private var pv3dObjsArr:Vector.<DisplayObject3D> = new Vector.<DisplayObject3D>();
        private var box3dSpapesArr:Vector.<b2Body> = new Vector.<b2Body>();
        
        // pv3d objs
        private var light:PointLight3D;
        private var mat:FlatShadeMaterial;
        
        // timer count
        private var timerCnt:int = 0;
        
        /**
         * Constructor
         */
        public function Main()
        {
            stage.quality = StageQuality.MEDIUM;
            
            Mouse.cursor = MouseCursor.HAND;
            
            // init PV3D
            super(stage.stageWidth, stage.stageHeight, false, false, CameraType.FREE);
            
            // init PV3D World
            createPaervision3dWorld();
            
            // init Box2D World
            createBox2dWorld()
            
            // addEvent
            addEventListener(Event.ENTER_FRAME, enterFrameHandler);
            
            // Backgound
            createBackGround();
            //cerateFullScreenBtn();
            
            // mouse interactive
            stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
            stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
            stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
            stage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
        }
        
        
        
        /**
         * Create Papervision3D World
         */
        private function createPaervision3dWorld():void
        {
            camera.x = 0;
            camera.z = -CAMERA_DISTANCE;
            
            // heavy....
            //renderer = new QuadrantRenderEngine(QuadrantRenderEngine.CORRECT_Z_FILTER);
            
            // create light
            light = new PointLight3D();
            light.z = -100;
            
            mat = new FlatShadeMaterial(light, OBJ_COLOR);
            ballMat = new FlatShadeMaterial(light, 0x990000);
            
            cameraTarget = new DisplayObject3D();
            cameraTarget.x = -50; 
            cameraTarget.y = 50; 
        }
        
        /**
         * Create Box2D World
         */
        private function createBox2dWorld():void
        {
            // init Box2D
            worldWidth = stage.stageWidth;
            worldHeight = stage.stageHeight;
            m_iterations = 10;
            m_timeStep = 1 / stage.frameRate;
            m_physScale = 60;
            
            var worldAABB:b2AABB = new b2AABB();
            worldAABB.lowerBound.Set( -1000, -1000);
            worldAABB.upperBound.Set(1000, 1000);
            var gravity:b2Vec2 = new b2Vec2(0, 10);
            var doSleep:Boolean = true;
            m_world = new b2World(worldAABB, gravity, doSleep);
            
            var dbgDraw:b2DebugDraw = new b2DebugDraw();
            dbgDraw.m_sprite = this;
            dbgDraw.m_drawScale = SCALE;
            dbgDraw.m_fillAlpha = 0.3;
            dbgDraw.m_lineThickness = 1.0;
            dbgDraw.m_alpha = 1.0;
            dbgDraw.m_xformScale = 1.0
            dbgDraw.m_drawFlags = b2DebugDraw.e_shapeBit;
            m_world.SetDebugDraw(dbgDraw);
            
            // walls for Box2D
            createPolygon(stage.stageWidth / 2 / SCALE, 1.0, 354, 1.1, 0.1);
            createPolygon(stage.stageWidth / 4 / SCALE, 2.1, 20, 1.2, 0.1);
            createPolygon(stage.stageWidth / 2 / SCALE, 3.2, 354, 1.1, 0.1);
            createPolygon(stage.stageWidth / 4 / SCALE, 4.0, 12, 2.3, 0.1);
            createPolygon(0.5, 5.1, 0, 6, 0.5);
            createPolygon(0, stage.stageHeight / 2 / SCALE, 90, stage.stageHeight / 2 / SCALE, 0.1);
            createPolygon(3.32, stage.stageHeight / 2 / SCALE, 90, 1.5, 0.1);
            createPolygon(4.58, stage.stageHeight / 2 / SCALE, 90, stage.stageHeight / SCALE, 0.1);
            
            // walls for PV3D
            addCubeAtPv3dWorldNoSave(stage.stageWidth / 2 / SCALE, 1.0, 354, 1.1, 0.1);
            addCubeAtPv3dWorldNoSave(stage.stageWidth / 4 / SCALE, 2.1, 20, 1.2, 0.1);
            addCubeAtPv3dWorldNoSave(stage.stageWidth / 2 / SCALE, 3.2, 354, 1.1, 0.1);
            addCubeAtPv3dWorldNoSave(stage.stageWidth / 4 / SCALE, 4.0, 12, 2.3, 0.1);
            addCubeAtPv3dWorldNoSave(0.5, 5.1, 0, 6, 0.5);
            addCubeAtPv3dWorldNoSave(0, stage.stageHeight / 2 / SCALE, 90, stage.stageHeight / 2 / SCALE, 0.1);
            addCubeAtPv3dWorldNoSave(3.32, stage.stageHeight / 2 / SCALE, 90, 1.5, 0.1);
            addCubeAtPv3dWorldNoSave(4.58, stage.stageHeight / 2 / SCALE, 90, stage.stageHeight / SCALE, 0.1);
            
            
            // elevator
            for (var i:int = 0; i < 14; i++)
            {
                addCubeAtPv3dWorld(0.23, 0.1, true);
                if (i % 2) addRectAtBox2dWorld(3.7, i * 0.4, 0, 0.23, 0.1, "elevator");
                else       addRectAtBox2dWorld(4.2, i * 0.4, 0, 0.23, 0.1, "elevator");
            }
            
            // balls
            for (i = 0; i < 4; i++)
            {
                addSphereAtPv3dWorld(40, 30, OBJ_SIZE);
                addCircleAtBox2dWorld(40, 30, OBJ_SIZE);
            }
        }
        
        private function addCubeAtPv3dWorldNoSave(posX:Number, posY:Number, degree:Number, hx:Number, hy:Number, id:String = "", density:Number = 0.0, restitution:Number = 0.0,
                                     setMass:Boolean = false):void
        {
            var obj3d:DisplayObject3D = scene.addChild(
                new Cube(
                    new MaterialsList( { all: mat } ),
                    hx * m_physScale * 2, 
                    30, 
                    hy * m_physScale * 2));
            
            obj3d.x = + posX * m_physScale - worldWidth / 2;
            obj3d.y = - posY * m_physScale + worldHeight / 2;
            obj3d.rotationZ = - degree
        }
        
        /**
         * AddItem at Papervision3D World
         */
        private function addSphereAtPv3dWorld(posX:Number, posY:Number, radius:Number):void
        {
            var obj3d:DisplayObject3D = scene.addChild(new Sphere(ballMat, radius / 2, 6, 5));
            pv3dObjsArr.push(obj3d);
        }
        
        /**
         * AddItem at Papervision3D World
         */
        private function addCubeAtPv3dWorld(hx:Number, hy:Number, isSaveArray:Boolean):void
        {
            var obj3d:DisplayObject3D = scene.addChild(
                new Cube(
                    new MaterialsList( { all: mat } ),
                    hx * m_physScale * 2, 
                    hy * m_physScale * 2, 
                    10));
            if(isSaveArray) pv3dObjsArr.push(obj3d);
        }
        
        /**
         * AddItem at Box2D World
         */
        private function addCircleAtBox2dWorld(posX:Number, posY:Number, radius:Number):void
        {
            var obj3d:DisplayObject3D = pv3dObjsArr[pv3dObjsArr.length - 1];
                
            var circleShape:b2CircleDef = new b2CircleDef();
            circleShape.radius = radius / m_physScale / 2;
            circleShape.density = 1;
            circleShape.friction = 1;
            circleShape.restitution = 0.6;
            var bodyDef:b2BodyDef = new b2BodyDef();
            bodyDef.position.Set((posX + worldWidth / 2) / m_physScale, (posY + worldHeight / 2) / m_physScale);
            bodyDef.userData = { id:"", obj:obj3d };
            var body:b2Body = m_world.CreateBody(bodyDef);
            body.CreateShape(circleShape);
            //body.SetUserData( { obj:obj3d } );
            body.SetMassFromShapes();
            
            box3dSpapesArr.push(body);
        }
        
        /**
         * AddItem at Box2D World
         */
        private function addRectAtBox2dWorld(
            posX:Number, posY:Number, degree:Number, 
            hx:Number, hy:Number, id:String = "", 
            density:Number = 0.0, restitution:Number = 0.0,
            setMass:Boolean = false):void
        {
            var obj3d:DisplayObject3D = pv3dObjsArr[pv3dObjsArr.length - 1];
            
            var bodyDef:b2BodyDef = new b2BodyDef();
            bodyDef.position.Set(posX, posY);
            bodyDef.angle = degree * Math.PI / 180;
            if (id) bodyDef.userData = { id:id, obj:obj3d };
            
            var blockShape:b2PolygonDef = new b2PolygonDef();
            blockShape.SetAsBox(hx, hy);
            blockShape.density = density;
            blockShape.restitution = restitution;
            
            var body:b2Body = m_world.CreateBody(bodyDef);
            body.CreateShape(blockShape);
            //body.SetUserData(obj3d);
            
            if (setMass) body.SetMassFromShapes();
        }
        
        /**
         * Enter Frame
         * @param    event
         */
        private function enterFrameHandler(event:Event):void
        {
            // update Box2D step
            m_world.Step(m_timeStep, m_iterations);
            // sync position to PV3D from Box2D
            for (var bb:b2Body = m_world.GetBodyList(); bb; bb = bb.GetNext())
            {
                if (bb.m_userData)
                {
                    if (bb.m_userData.id == "elevator")
                    {
                        bb.SetXForm(new b2Vec2(bb.GetPosition().x, bb.GetPosition().y - 0.02), 0);
                        if (bb.GetPosition().y < -0.1) bb.SetXForm(new b2Vec2(bb.GetPosition().x, stage.stageHeight / SCALE + 1), 0);
                        if (bb.GetPosition().y < 0.8) bb.SetXForm(bb.GetPosition(), bb.GetAngle() - 0.2);
                    }
                    
                    if (bb.m_userData.obj is DisplayObject3D)
                    {
                        var obj:DisplayObject3D = bb.m_userData.obj;
                        
                        obj.x = bb.GetPosition().x * m_physScale - worldWidth / 2;
                        obj.y = -bb.GetPosition().y * m_physScale + worldHeight / 2;
                        obj.rotationZ = -bb.GetAngle() * (180 / Math.PI);
                    }
                }
            }
            
            // Mouse Interactive
            easePitch += (cameraPitch - easePitch) * 0.2
            easeYaw += (cameraYaw - easeYaw) * 0.2
            camera.orbit(easePitch, easeYaw, true, cameraTarget);
            
            camera.zoom += (easeZoom - camera.zoom) * 0.1;
            
            singleRender();
        }
        
        
        private function createBackGround():void
        {
            graphics.beginFill(0xFFFFFF);
            graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
        }
        
        //-------------------------------------------------------------------
        // forked from Box2Dの練習
        // http://wonderfl.net/c/sdpJ
        //-------------------------------------------------------------------
        
        private const SCALE:uint = 100;
        
        private function createPolygon(posX:Number, posY:Number, degree:Number, hx:Number, hy:Number, id:String = "", density:Number = 0.0, restitution:Number = 0.0,
                                     setMass:Boolean = false):void
        {
            var blockBodyDef:b2BodyDef = new b2BodyDef();
            blockBodyDef.position.Set(posX, posY);
            blockBodyDef.angle = degree * Math.PI / 180;
            if (id)
            {
                blockBodyDef.userData = new Object();
                blockBodyDef.userData.id = id;
            }
            
            var blockShape:b2PolygonDef = new b2PolygonDef();
            blockShape.SetAsBox(hx, hy);
            blockShape.density = density;
            blockShape.restitution = restitution;
            
            var blockBody:b2Body = m_world.CreateBody(blockBodyDef);
            blockBody.CreateShape(blockShape);
            
            if (setMass) blockBody.SetMassFromShapes();
        }
        
        
        
        // ----------------------------------------------
        // Mouse Interactive
        // http://wonderfl.net/c/685u
        // ----------------------------------------------
        
        private var isOribiting:Boolean;
        private var cameraPitch:Number = 90;
        private var cameraYaw:Number = 270;
        private var cameraTarget:DisplayObject3D = DisplayObject3D.ZERO;
        private var previousMouseX:Number;
        private var previousMouseY:Number;
        private var easePitch:Number = 90;
        private var easeYaw:Number = 270;
        private var easeZoom:Number = 100;
        private var ballMat:FlatShadeMaterial;
        
        private function onMouseDown(event:MouseEvent):void
        {
            isOribiting = true;
            previousMouseX = event.stageX;
            previousMouseY = event.stageY;
            singleRender();
        }
 
        private function onMouseUp(event:MouseEvent):void
        {
            isOribiting = false;
        }
 
        private function onMouseMove(event:MouseEvent):void
        {
            var differenceX:Number = event.stageX - previousMouseX;
            var differenceY:Number = event.stageY - previousMouseY;
 
            if(isOribiting)
            {
                cameraPitch += differenceY * 0.25;
                cameraYaw += differenceX * 0.25;
 
                cameraPitch %= 360;
 
                cameraPitch = cameraPitch > 0 ? cameraPitch : 0.0001;
                cameraPitch = cameraPitch < 180 ? cameraPitch : 179.9999;
 
                previousMouseX = event.stageX;
                previousMouseY = event.stageY;
            }
        }
        
        private function onMouseWheel(e:MouseEvent):void 
        {
            easeZoom += e.delta;
            easeZoom = Math.max(1, easeZoom);
        }
    }
}
package  
{
    import Box2D.Collision.b2AABB;
    import Box2D.Collision.Shapes.b2PolygonDef;
    import Box2D.Common.Math.b2Vec2;
    import Box2D.Dynamics.b2Body;
    import Box2D.Dynamics.b2BodyDef;
    import Box2D.Dynamics.b2DebugDraw;
    import Box2D.Dynamics.b2World;
    import Box2D.Dynamics.Joints.b2MouseJoint;
    import Box2D.Dynamics.Joints.b2MouseJointDef;
    import Box2D.Dynamics.Joints.b2RevoluteJointDef;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.text.TextField;
    /**
     * ...
     * @author Jacky Riawan
     */
    [SWF(backgroundColor=0, width=400, height=400, frameRate=40)]
    public class main extends Sprite
    {
        private var world:b2World
        private var myAABB:b2AABB
        private const ratio:int = 30
        private var joint:b2RevoluteJointDef = new b2RevoluteJointDef()
        private var prevBody:b2Body
        private var mouseJoint:b2MouseJoint;
        private var boxBody:b2Body;
        private var isHold:Boolean=false
        private var lightHandle:b2PolygonDef;
        private var heavyHandle:b2PolygonDef;
        private var bodyToDestroyList:Vector.<b2Body>=new Vector.<b2Body>()
        private var timer:int=0;
        public function main() 
        {
            setupHeavyAndLightDef()
            setupWorld()
            setupDebugDraw()
            createNunchuck()
            showInstruction()
            addEventListener(Event.ENTER_FRAME, render)
            stage.addEventListener(MouseEvent.MOUSE_DOWN, downHandler)
            stage.addEventListener(MouseEvent.MOUSE_UP,upHandler)
        }
        
        private function showInstruction():void
        {
            var txt:TextField = new TextField()
            txt.text = "Hold Mouse to use tight handling\nRelease mouse to use loose handling\nMove mouse to swing"
            txt.textColor = 0xFFF000
            txt.mouseEnabled=false
            txt.width=400
            txt.wordWrap=true
            addChild(txt)
        }
        
        private function setupHeavyAndLightDef():void
        {
            heavyHandle = new b2PolygonDef()
            heavyHandle.SetAsBox(20 / ratio, 2.5 / ratio)
            heavyHandle.density = 2000
            heavyHandle.filter.groupIndex = -1
            lightHandle = new b2PolygonDef()
            lightHandle.SetAsBox(20 / ratio, 2.5 / ratio)
            lightHandle.density = 10
            lightHandle.filter.groupIndex=-1
        }
        private function createObject():void {
            var shape:b2PolygonDef = new b2PolygonDef()
            shape.SetAsBox((Math.random() * 15 + 5) / ratio, (Math.random() * 15 + 5) / ratio)
            shape.filter.categoryBits=1
            shape.density=Math.random()/3+.1
            var bodyDef:b2BodyDef = new b2BodyDef()
            bodyDef.position.Set((Math.random() * 400) / ratio, 0)
            var body:b2Body = world.CreateBody(bodyDef)
            body.CreateShape(shape)
            body.SetMassFromShapes()
            bodyToDestroyList.push(body)
        }
        private function downHandler(e:MouseEvent):void 
        {
            boxBody.DestroyShape(boxBody.GetShapeList())
            boxBody.CreateShape(heavyHandle)
            boxBody.SetMassFromShapes()
            isHold=true
        }
        private function upHandler(e:MouseEvent):void 
        {
            boxBody.DestroyShape(boxBody.GetShapeList())
            boxBody.CreateShape(lightHandle)
            boxBody.SetMassFromShapes()
            isHold=false
        }
        private function createNunchuck():void
        {
            //part1
            var boxSD:b2PolygonDef = new b2PolygonDef()
            boxSD.SetAsBox(20 / ratio, 2.5 / ratio)
            boxSD.density = 10
            boxSD.filter.groupIndex=-1
            var boxBD:b2BodyDef = new b2BodyDef()
            boxBD.position.Set(mouseX / ratio, mouseY / ratio)
            boxBody = world.CreateBody(boxBD)
            boxBody.CreateShape(lightHandle)
            boxBody.SetMassFromShapes()
            prevBody=boxBody
            //part 2
            
            var boxBD2:b2BodyDef = new b2BodyDef()
            boxBD2.position.Set((mouseX+75) / ratio, mouseY / ratio)
            var boxBody2:b2Body = world.CreateBody(boxBD2)
            boxBody2.SetBullet(true)
            boxBody2.CreateShape(boxSD)
            boxBody2.SetMassFromShapes()
            //chain
            var chainBodyShape:b2PolygonDef = new b2PolygonDef()
            chainBodyShape.SetAsBox(2.5 / ratio, .25 / ratio)
            
            chainBodyShape.filter.groupIndex = -1
            chainBodyShape.filter.categoryBits=1
            for (var i:int = 0; i < 7; i++) {
                var chainSD:b2BodyDef = new b2BodyDef()
                chainBodyShape.density = 1000-i*50
                chainSD.position.Set((mouseX+22.5 + i * 5) / ratio, mouseY / ratio)
                var chainBody:b2Body = world.CreateBody(chainSD)
                chainBody.CreateShape(chainBodyShape)
                chainBody.SetMassFromShapes()
                joint.Initialize(prevBody, chainBody, new b2Vec2(((mouseX+22.5 + i * 5) - 2.5) / ratio, mouseY/ratio))
                world.CreateJoint(joint)
                prevBody=chainBody
            }
            
            joint.Initialize(prevBody, boxBody2, new b2Vec2(((mouseX+22.5 + 7 * 5) - 2.5) / ratio, mouseY / ratio))
            world.CreateJoint(joint)
            var mouseJointDef:b2MouseJointDef = new b2MouseJointDef()
            mouseJointDef.body2 = boxBody
            mouseJointDef.body1 = world.GetGroundBody()
            mouseJointDef.target.Set(mouseX / ratio, mouseY / ratio)
            mouseJointDef.maxForce = 10000000
            mouseJointDef.timeStep = 1 / 80
            mouseJoint=world.CreateJoint(mouseJointDef) as b2MouseJoint
        }
        
        private function render(e:Event):void 
        {
            if (isHold) {
                boxBody.SetAngularVelocity(0)//m_angularVelocity=0
            }
            timer++
            if (timer % 10 == 0) {
                createObject()
            }
            world.Step(1 / 40, 20)
            mouseJoint.SetTarget(new b2Vec2(mouseX / ratio, mouseY / ratio))
            for (var i:int = 0; i < bodyToDestroyList.length; i++) {
                var myBody:b2Body = bodyToDestroyList[i]
                var body_y:Number = myBody.GetPosition().y
                var body_x:Number = myBody.GetPosition().x
                if (body_x<0||body_x>400/ratio||body_y<0||body_y > 400 / ratio) {
                    world.DestroyBody(myBody)
                    bodyToDestroyList.splice(i,1)
                }
            }
        }
        
        private function setupDebugDraw():void
        {
            var sprite:Sprite = new Sprite()
            addChild(sprite)
            var debugMode:b2DebugDraw = new b2DebugDraw()
            debugMode.SetFlags(b2DebugDraw.e_shapeBit)
            debugMode.m_sprite=sprite
            debugMode.m_drawScale = ratio
            debugMode.m_fillAlpha = .3
            world.SetDebugDraw(debugMode)
            
        }
        
        private function setupWorld():void
        {
            myAABB=new b2AABB()
            myAABB.lowerBound.Set(-1000/ratio, -1000/ratio)
            myAABB.upperBound.Set(1000/ratio,1000/ratio)
            world=new b2World(myAABB,new b2Vec2(0,10),true)
        }
        
    }

}
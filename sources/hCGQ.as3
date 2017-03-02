package  
{
    import Box2D.Collision.b2AABB;
    import Box2D.Collision.Shapes.b2CircleDef;
    import Box2D.Collision.Shapes.b2PolygonDef;
    import Box2D.Common.Math.b2Vec2;
    import Box2D.Dynamics.b2Body;
    import Box2D.Dynamics.b2BodyDef;
    import Box2D.Dynamics.b2DebugDraw;
    import Box2D.Dynamics.b2World;
    import Box2D.Dynamics.Joints.b2Joint;
    import Box2D.Dynamics.Joints.b2MouseJoint;
    import Box2D.Dynamics.Joints.b2MouseJointDef;
    import Box2D.Dynamics.Joints.b2RevoluteJointDef;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.text.TextFieldAutoSize;
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
        private var bodyToDestroyList:Vector.<b2Body> = new Vector.<b2Body>()
        private var emoList:Vector.<Sprite> = new Vector.<Sprite>()
        private var faceList:Vector.<String>=Vector.<String>(["0_o","T_T","@_@",'(>_<")',"t(>o<t)","(X_X)","(>_<#)","(-_-)","(O.O;)","(~_~;)","(^_-;)","(T0T)","(T^T)","(*_*)","(+_+)","(o_ _)o"])
        private var timer:int=0;
        private var myTextFormat:TextFormat = new TextFormat("_sans", 10);
        private var ragdollBodyList:Vector.<Array>=new Vector.<Array>()
        public function main() 
        {
            setupHeavyAndLightDef()
            setupWorld()
            setupDebugDraw()
            setupRightWall()
            createNunchuck()
            showInstruction()
            addEventListener(Event.ENTER_FRAME, render)
            stage.addEventListener(MouseEvent.MOUSE_DOWN, downHandler)
            stage.addEventListener(MouseEvent.MOUSE_UP,upHandler)
        }
        
        private function setupRightWall():void
        {
            var wallShape:b2PolygonDef = new b2PolygonDef()
            wallShape.SetAsBox(5 / ratio, 200 / ratio)
            wallShape.filter.groupIndex=-1
            var wallDef:b2BodyDef = new b2BodyDef()
            wallDef.position.Set(400 / ratio, 200 / ratio)
            var wallBody:b2Body = world.CreateBody(wallDef)
            wallBody.CreateShape(wallShape)
            wallBody.SetUserData("")
            wallBody.SetMassFromShapes()
        }
        
        private function showInstruction():void
        {
            var txt:TextField = new TextField()
            txt.text = "After few hours of wasted time, the epic battle is still continue! now the ninjas evil plot are to side kick the solid wall!! why? i also wonder why?"
            txt.textColor = 0xFFF000
            txt.setTextFormat(myTextFormat)
            txt.mouseEnabled=false
            txt.autoSize = TextFieldAutoSize.LEFT
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
        private function createNinjaRagdoll(pos:b2Vec2, size:Number):void {
            var posx:Number = pos.x
            var posy:Number = pos.y
            var ninjaSize:Number = size
            var shape:b2PolygonDef = new b2PolygonDef()
            var bodyList:Array = new Array()
            shape.SetAsBox((8*ninjaSize) / ratio, (15*ninjaSize) / ratio)
            shape.filter.categoryBits=1
            shape.density = .3
            var head:b2CircleDef = new b2CircleDef()
            head.radius = 10*ninjaSize/ratio
            head.density = .3
            var limb1:b2PolygonDef = new b2PolygonDef()
            limb1.SetAsBox(12 * ninjaSize / ratio, 3 * ninjaSize / ratio)
            //limb1.SetAsOrientedBox(25 * ninjaSize / ratio, 3 * ninjaSize / ratio, new b2Vec2(24 * ninjaSize / ratio, 13 * ninjaSize / ratio), 3)
            limb1.density = .3
            var limb2:b2PolygonDef = new b2PolygonDef()
            limb2.SetAsBox(3 * ninjaSize / ratio, 12 * ninjaSize / ratio)
            //limb2.SetAsOrientedBox(3 * ninjaSize / ratio, 12 * ninjaSize / ratio, new b2Vec2( -7 * ninjaSize / ratio, 27 * ninjaSize / ratio), .4)
            limb2.density = .3
            var limb3:b2PolygonDef = new b2PolygonDef()
            limb3.SetAsBox(12 * ninjaSize / ratio, 3 * ninjaSize / ratio)
            //limb3.SetAsOrientedBox(12 * ninjaSize / ratio, 3 * ninjaSize / ratio, new b2Vec2( -2 * ninjaSize / ratio, 34 * ninjaSize / ratio), 3)
            limb3.density = .3
            var limb4:b2PolygonDef = new b2PolygonDef()
            limb4.SetAsBox(15 * ninjaSize / ratio, 3 * ninjaSize / ratio)
            //limb4.SetAsOrientedBox(15 * ninjaSize / ratio, 3 * ninjaSize / ratio, new b2Vec2( -18 * ninjaSize / ratio, -12 * ninjaSize / ratio), .3)
            limb4.density=.3
            var limb5:b2PolygonDef = new b2PolygonDef()
            limb5.SetAsBox(15 * ninjaSize / ratio, 3 * ninjaSize / ratio)
            //limb5.SetAsOrientedBox(15 * ninjaSize / ratio, 3 * ninjaSize / ratio, new b2Vec2(15 * ninjaSize / ratio, -20 * ninjaSize / ratio), 2.14)
            limb5.density = .3
            //
            var headDef:b2BodyDef = new b2BodyDef()
            headDef.position.Set(posx, posy-(25 * ninjaSize) / ratio)
            var headBody:b2Body = world.CreateBody(headDef)
            headBody.CreateShape(head)
            headBody.SetUserData("dead")
            headBody.SetMassFromShapes()
            
            //
            var bodyDef:b2BodyDef = new b2BodyDef()
            bodyDef.position.Set(posx, posy)
            var body:b2Body = world.CreateBody(bodyDef)
            body.CreateShape(shape)
            body.SetUserData("dead")
            body.SetMassFromShapes()
            //
            joint.Initialize(headBody, body,headBody.GetPosition())
            bodyList.push(world.CreateJoint(joint))
            //
            var bodyDef1:b2BodyDef = new b2BodyDef()
            bodyDef1.position.Set(posx+(15 * ninjaSize) / ratio, posy +(13 * ninjaSize) / ratio)
            bodyDef1.angle = 3
            var body1:b2Body = world.CreateBody(bodyDef1)
            body1.CreateShape(limb1)
            body1.SetUserData("dead")
            body1.SetMassFromShapes()
            //
            joint.Initialize(body, body1, body1.GetWorldPoint(new b2Vec2(10*ninjaSize/ratio,0)))
            world.CreateJoint(joint)
            bodyList.push(world.CreateJoint(joint))
            //
            var bodyDef2:b2BodyDef = new b2BodyDef()
            bodyDef2.position.Set(posx-(6 * ninjaSize) / ratio, posy +(25 * ninjaSize) / ratio)
            bodyDef2.angle = .4
            var body2:b2Body = world.CreateBody(bodyDef2)
            body2.CreateShape(limb2)
            body2.SetUserData("dead")
            body2.SetMassFromShapes()
            //
            joint.Initialize(body, body2, body2.GetWorldPoint(new b2Vec2(0,-10*ninjaSize/ratio)))
            world.CreateJoint(joint)
            bodyList.push(world.CreateJoint(joint))
            //
            var bodyDef3:b2BodyDef = new b2BodyDef()
            bodyDef3.position.Set(posx, posy + 32 * ninjaSize / ratio)
            bodyDef3.angle = 3
            var body3:b2Body = world.CreateBody(bodyDef3)
            body3.CreateShape(limb3)
            body3.SetUserData("dead")
            body3.SetMassFromShapes()
            //
            joint.Initialize(body2, body3, body3.GetWorldPoint(new b2Vec2(10 * ninjaSize / ratio,0)))
            world.CreateJoint(joint)
            bodyList.push(world.CreateJoint(joint))
            //
            var bodyDef4:b2BodyDef = new b2BodyDef()
            bodyDef4.position.Set(posx - 18 * ninjaSize / ratio, posy - 12 * ninjaSize / ratio)
            bodyDef4.angle = .3
            var body4:b2Body = world.CreateBody(bodyDef4)
            body4.CreateShape(limb4)
            body4.SetUserData("dead")
            body4.SetMassFromShapes()
            //
            joint.Initialize(body4, body, body4.GetWorldPoint(new b2Vec2(13 * ninjaSize / ratio, 0)))
            world.CreateJoint(joint)
            bodyList.push(world.CreateJoint(joint))
            //
            var bodyDef5:b2BodyDef = new b2BodyDef()
            bodyDef5.position.Set(posx +15 * ninjaSize / ratio, posy - 20 * ninjaSize / ratio)
            bodyDef5.angle = 2.14
            var body5:b2Body = world.CreateBody(bodyDef5)
            body5.SetUserData("dead")
            body5.CreateShape(limb5)
            body5.SetMassFromShapes()
            //
            joint.Initialize(body5, body, body5.GetWorldPoint(new b2Vec2(13 * ninjaSize / ratio, 0)))
            world.CreateJoint(joint)
            bodyList.push(world.CreateJoint(joint))
            //
            var bodyDef6:b2BodyDef = new b2BodyDef()
            bodyDef6.position.Set(posx+(37 * ninjaSize) / ratio, posy +(10 * ninjaSize) / ratio)
            bodyDef6.angle = 3
            var body6:b2Body = world.CreateBody(bodyDef6)
            body6.CreateShape(limb1)
            body6.SetUserData("dead")
            body6.SetMassFromShapes()
            //
            body.SetAngularVelocity((Math.random()-.5)*400)
            body.SetLinearVelocity(new b2Vec2(-(300+300*Math.random())/ratio,500*Math.random()/ratio))
            joint.Initialize(body1, body6, body6.GetWorldPoint(new b2Vec2(10*ninjaSize/ratio,0)))
            bodyList.push(world.CreateJoint(joint))
            bodyList.push(body,headBody, body1, body2, body3, body4, body5, body6)
            ragdollBodyList.push(bodyList)
        }
        private function createNinja():void {
            var ninjaSize:Number=.4+Math.random()/3
            var shape:b2PolygonDef = new b2PolygonDef()
            shape.SetAsBox((8*ninjaSize) / ratio, (15*ninjaSize) / ratio)
            shape.filter.categoryBits=1
            shape.density = .3
            var head:b2CircleDef = new b2CircleDef()
            head.radius = 10*ninjaSize/ratio
            head.localPosition = new b2Vec2(0, -25 * ninjaSize / ratio)
            head.density = .3
            var limb1:b2PolygonDef = new b2PolygonDef()
            limb1.SetAsOrientedBox(25 * ninjaSize / ratio, 3 * ninjaSize / ratio, new b2Vec2(24 * ninjaSize / ratio, 13 * ninjaSize / ratio), 3)
            limb1.density = .3
            var limb2:b2PolygonDef = new b2PolygonDef()
            limb2.SetAsOrientedBox(3 * ninjaSize / ratio, 12 * ninjaSize / ratio, new b2Vec2( -7 * ninjaSize / ratio, 27 * ninjaSize / ratio), .4)
            limb2.density = .3
            var limb3:b2PolygonDef = new b2PolygonDef()
            limb3.SetAsOrientedBox(12 * ninjaSize / ratio, 3 * ninjaSize / ratio, new b2Vec2( -2 * ninjaSize / ratio, 34 * ninjaSize / ratio), 3)
            limb3.density = .3
            var limb4:b2PolygonDef = new b2PolygonDef()
            limb4.SetAsOrientedBox(15 * ninjaSize / ratio, 3 * ninjaSize / ratio, new b2Vec2( -18 * ninjaSize / ratio, -12 * ninjaSize / ratio), .3)
            limb4.density=.3
            var limb5:b2PolygonDef = new b2PolygonDef()
            limb5.SetAsOrientedBox(15 * ninjaSize / ratio, 3 * ninjaSize / ratio, new b2Vec2(15 * ninjaSize / ratio, -20 * ninjaSize / ratio), 2.14)
            limb5.density=.3
            var bodyDef:b2BodyDef = new b2BodyDef()
            var spawnPos:Number=Math.random()*400
            bodyDef.position.Set(0 / ratio, spawnPos/ratio)
            var body:b2Body = world.CreateBody(bodyDef)
            body.CreateShape(shape)
            body.CreateShape(head)
            body.CreateShape(limb1)
            body.CreateShape(limb2)
            body.CreateShape(limb3)
            body.CreateShape(limb4)
            body.CreateShape(limb5)
            body.SetLinearVelocity(new b2Vec2((400+Math.random()*500)/ratio,(Math.random()*300-spawnPos)/ratio))
            body.SetMassFromShapes()
            body.m_userData=ninjaSize
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
            boxBody.m_userData=""
            prevBody=boxBody
            //part 2
            
            var boxBD2:b2BodyDef = new b2BodyDef()
            boxBD2.position.Set((mouseX+75) / ratio, mouseY / ratio)
            var boxBody2:b2Body = world.CreateBody(boxBD2)
            boxBody2.SetBullet(true)
            boxBody2.CreateShape(boxSD)
            boxBody2.SetMassFromShapes()
            boxBody2.m_userData=""
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
        private function addEmoticon(pos:b2Vec2):void {
            pos.Multiply(ratio)
            var holder:Sprite=new Sprite()
            var emo:TextField = new TextField()
            holder.x = pos.x
            holder.y = pos.y
            holder.mouseChildren = false
            emo.textColor = 0xFFFFFF
            emo.text = faceList[int(faceList.length*Math.random())]
            emo.setTextFormat(myTextFormat)
            
            holder.addChild(emo)
            addChild(holder)
            emoList.push(holder)
        }
        private function render(e:Event):void 
        {
            if (isHold) {
                boxBody.SetAngularVelocity(0)//m_angularVelocity=0
            }
            timer++
            if (timer % Math.max(25,int(50-timer/800)) == 0) {
                createNinja()
            }
            
            for (var j:int = 0; j < emoList.length; j++) {
                var myEmo:Sprite = emoList[j]
                myEmo.y--
                myEmo.alpha -= .02
                if (myEmo.alpha < 0) {
                    removeChild(myEmo)
                    emoList.splice(j,1)
                }
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
            if (world.m_contactCount > 0) {
                if (world.m_contactList.GetShape1().GetBody().GetUserData() < 10 && world.m_contactList.GetShape2().GetBody().GetUserData() == "") {
                    var ninja1:b2Body=world.m_contactList.GetShape1().GetBody()
                    createNinjaRagdoll(ninja1.GetPosition(),ninja1.GetUserData())
                    addEmoticon(world.m_contactList.GetShape1().GetBody().GetPosition())
                    bodyToDestroyList.splice(bodyToDestroyList.indexOf(ninja1, 0),1)
                    world.DestroyBody(ninja1)
                }else if (world.m_contactList.GetShape1().GetBody().GetUserData() == "" && world.m_contactList.GetShape2().GetBody().GetUserData() < 10) {
                    var ninja2:b2Body=world.m_contactList.GetShape2().GetBody()
                    createNinjaRagdoll(ninja2.GetPosition(),ninja2.GetUserData())
                    addEmoticon(ninja2.GetPosition())
                    bodyToDestroyList.splice(bodyToDestroyList.indexOf(ninja2, 0),1)
                    world.DestroyBody(ninja2)
                }
            }
            clearRagdoll()
        }
        private function clearRagdoll():void {
            for (var i:int = 0; i < ragdollBodyList.length; i++) {
                var bodyPos:int=ragdollBodyList[i].length
                var myBody:b2Body = ragdollBodyList[i][bodyPos - 1]
                var posx:Number = myBody.GetPosition().x
                var posy:Number = myBody.GetPosition().y
                if (posx > 400 / ratio||posy>400 / ratio||posx<0||posy<0) {
                    for (var j:int = 0; j<bodyPos; j++ ) {
                        if (ragdollBodyList[i][j] is b2Body == true) {
                            world.DestroyBody(ragdollBodyList[i][j])
                        }else {
                            world.DestroyJoint(ragdollBodyList[i][j])
                        }
                    }
                    ragdollBodyList.splice(i,1)
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
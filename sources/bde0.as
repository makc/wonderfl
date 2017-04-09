package
{
    import Box2D.Collision.*;
    import Box2D.Common.Math.*;
    import Box2D.Dynamics.*;
    import Box2D.Dynamics.Joints.b2DistanceJointDef;
    import Box2D.Collision.Shapes.*;
    import flash.display.Sprite;
    import flash.display.StageScaleMode;
    import flash.display.StageAlign;
    import flash.events.Event;
    
    [SWF(width="465", height="465", frameRate="30", backgroundColor="0x000000")]
    public class Test extends Sprite
    {
        private var iterations:int = 10;
        private var timeStep:Number = 1.0 / 60.0;
        private var world:b2World;
        private const SCALE = 100;
        
        public function Test()
        {
            stage.scaleMode = StageScaleMode.NO_SCALE;  
            stage.align = StageAlign.TOP_LEFT;
            
            box2dInit();
            addEventListener(Event.ENTER_FRAME, step, false, 0, true);
        }
        
        public function box2dInit():void
        {
            var worldAABB:b2AABB = new b2AABB();
            worldAABB.lowerBound.Set(-100.0, -100.0);
            worldAABB.upperBound.Set(100.0, 100.0);
            
            var gravity:b2Vec2 = new b2Vec2(0.0, 10);
            var doSleep:Boolean = true;
            
            world = new b2World(worldAABB, gravity, doSleep);
            
            
            var dbgDraw:b2DebugDraw = new b2DebugDraw();
            dbgDraw.m_sprite = this;
            dbgDraw.m_drawScale = SCALE;
            dbgDraw.m_fillAlpha = 0.3;
            dbgDraw.m_lineThickness = 0;
            dbgDraw.m_alpha = 0.5;
            dbgDraw.m_xformScale = 1.0
            dbgDraw.m_drawFlags = b2DebugDraw.e_shapeBit;
            world.SetDebugDraw(dbgDraw);
            
            {
                var bodyDef:b2BodyDef = new b2BodyDef();
                bodyDef.position.Set(0, stage.stageHeight / SCALE);
                bodyDef.angle = 0 * Math.PI / 180;
                var polygonDef:b2PolygonDef = new b2PolygonDef();
                polygonDef.SetAsBox(stage.stageWidth / SCALE, 0.4);
                var body:b2Body = world.CreateBody(bodyDef);
                body.CreateShape(polygonDef);
            }
        
            // 頭
            var bodyDef1:b2BodyDef = new b2BodyDef();
            bodyDef1.position.Set(2, 1);
            bodyDef1.userData = new Head();
            addChild(bodyDef1.userData);
            var polygonDef1:b2PolygonDef = new b2PolygonDef();
            polygonDef1.SetAsBox(0.8, 0.5);
            polygonDef1.density = 1;
            var body1:b2Body = world.CreateBody(bodyDef1);
            body1.CreateShape(polygonDef1);
            body1.SetMassFromShapes();
            
            // 体
            var bodyDef2:b2BodyDef = new b2BodyDef();
            bodyDef2.position.Set(2, 2.1);
            bodyDef2.userData = new Body();
            addChild(bodyDef2.userData);
            var polygonDef2:b2PolygonDef = new b2PolygonDef();
            polygonDef2.SetAsBox(0.5, 0.6);
            polygonDef2.density = 1;
            var body2:b2Body = world.CreateBody(bodyDef2);
            body2.CreateShape(polygonDef2);
            body2.SetMassFromShapes();
            
            // 左足
            var bodyDef3:b2BodyDef = new b2BodyDef();
            bodyDef3.position.Set(1.7, 3.1);
            var polygonDef3:b2PolygonDef = new b2PolygonDef();
            polygonDef3.SetAsBox(0.2, 0.4);
            polygonDef3.density = 100;
            var body3:b2Body = world.CreateBody(bodyDef3);
            body3.CreateShape(polygonDef3);
            body3.SetMassFromShapes();
            
            // 右足
            var bodyDef4:b2BodyDef = new b2BodyDef();
            bodyDef4.position.Set(2.3, 3.1);
            var polygonDef4:b2PolygonDef = new b2PolygonDef();
            polygonDef4.SetAsBox(0.2, 0.4);
            polygonDef4.density = 100;
            var body4:b2Body = world.CreateBody(bodyDef4);
            body4.CreateShape(polygonDef4);
            body4.SetMassFromShapes();
            
            // 左手
            var bodyDef5:b2BodyDef = new b2BodyDef();
            bodyDef5.position.Set(1.2, 1.9);
            bodyDef5.angle = 30 * Math.PI / 180;
            var polygonDef5:b2PolygonDef = new b2PolygonDef();
            polygonDef5.SetAsBox(0.2, 0.4);
            polygonDef5.density = 1;
            var body5:b2Body = world.CreateBody(bodyDef5);
            body5.CreateShape(polygonDef5);
            body5.SetMassFromShapes();
            
            // 右手
            var bodyDef6:b2BodyDef = new b2BodyDef();
            bodyDef6.position.Set(2.8, 1.9);
            bodyDef6.angle = 330 * Math.PI / 180;
            var polygonDef6:b2PolygonDef = new b2PolygonDef();
            polygonDef6.SetAsBox(0.2, 0.4);
            polygonDef6.density = 1;
            var body6:b2Body = world.CreateBody(bodyDef6);
            body6.CreateShape(polygonDef5);
            body6.SetMassFromShapes();
            
            // 頭と体をジョイント
            var distance1:b2DistanceJointDef = new b2DistanceJointDef();
            distance1.Initialize(body1, body2, new b2Vec2(1.6, 1.5), new b2Vec2(1.6, 1.51));
            world.CreateJoint(distance1);
            var distance2:b2DistanceJointDef = new b2DistanceJointDef();
            distance2.Initialize(body1, body2, new b2Vec2(2.4, 1.5), new b2Vec2(2.4, 1.51));
            world.CreateJoint(distance2);
            
            // 体と左足をジョイント
            distance1.Initialize(body2, body3, new b2Vec2(1.5, 2.7), new b2Vec2(1.5, 2.71));
            world.CreateJoint(distance1);
            distance2.Initialize(body2, body3, new b2Vec2(1.9, 2.7), new b2Vec2(1.9, 2.71));
            world.CreateJoint(distance2);
            
            // 体と右足をジョイント
            distance1.Initialize(body2, body4, new b2Vec2(2.1, 2.7), new b2Vec2(2.1, 2.71));
            world.CreateJoint(distance1);
            distance2.Initialize(body2, body4, new b2Vec2(2.5, 2.7), new b2Vec2(2.5, 2.71));
            world.CreateJoint(distance2);
        
            // 体と左手をジョイント
            distance1.Initialize(body2, body5, new b2Vec2(1.49, 1.5), new b2Vec2(1.5, 1.51));
            world.CreateJoint(distance1);
            distance2.Initialize(body2, body5, new b2Vec2(1.3, 1.5), body5.GetWorldCenter());
            world.CreateJoint(distance2);

            // 体と右手をジョイント
            distance1.Initialize(body2, body6, new b2Vec2(2.5, 1.5), new b2Vec2(2.51, 1.51));
            world.CreateJoint(distance1);
            distance2.Initialize(body1, body6, new b2Vec2(2.8, 1.5), body6.GetWorldCenter());
            world.CreateJoint(distance2);
        }
            
        private function step(event)
        {
            for (var bb:b2Body = world.m_bodyList; bb; bb = bb.m_next)
            {
                if (bb.m_userData is Sprite)
                {
                    bb.m_userData.x = bb.GetPosition().x * SCALE;
                    bb.m_userData.y = bb.GetPosition().y * SCALE;
                    bb.m_userData.rotation = bb.GetAngle() * 180 / Math.PI;
                }
            }
            world.Step(timeStep, iterations);
        }
    }
}

import flash.display.Sprite;

class Head extends Sprite
{
    public function Head()
    {
        graphics.beginFill(0x00000);
        graphics.drawCircle(-30, -15, 10);
        graphics.drawCircle(30, -15, 10);
        graphics.moveTo(0, 5);
        graphics.lineTo(-15, 23);
        graphics.lineTo(15, 23);
        graphics.lineTo(0, 5);
        graphics.endFill();
    }
}

class Body extends Sprite
{
    public function Body()
    {
        graphics.beginFill(0x777777);
        graphics.drawCircle(30, -45, 8);
        graphics.endFill();
        graphics.beginFill(0x000000);
        graphics.drawRect(26, -45, 8, 2);
        graphics.endFill();
    }
}

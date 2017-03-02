// forked from rsakane's Box2Dジョイントの練習でダンボーを作った(何故か左にスライド)
/*
 * 根本的に書き直した。（あまり意味はない）
 * ドラッグで動かせるようにした。
 * ダンボーを増やした。
 * 何となく手をブラブラ（体から取れそう）
 * 
 * 倒れても、自動で立ち上がるようになっています。（なんかカワイイ）
 * たまに倒れたままの事がある。
 * 
 * ダンボー同士がぶつかり合うとケンカになります。注意を。
 * ケンカをするとまれに足が骨折します。（足をつかむと完治します。）
 * 
 * ボール遊びが好きなようで、ボールを与えると投げて遊びます。
 * 
 *
 * 左にスライドする現象はとりあえずOKかな。
 * 
*/
package {

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;

	import Box2D.Dynamics.*;
	import Box2D.Collision.*;
	import Box2D.Collision.Shapes.*;
	import Box2D.Dynamics.Joints.*;
	import Box2D.Dynamics.Contacts.*;
	import Box2D.Common.*;
	import Box2D.Common.Math.*;
	
	[SWF(backgroundColor="0x000000", frameRate=60)]
	public class Main extends Sprite {

		public var m_sprite:Sprite;
		public var m_world:b2World;
		public var m_physScale:Number = 30.0;
		public var m_iterations:int = 10;
		public var m_timeStep:Number = 1.0/60.0;

		public var m_mouseJoint:b2MouseJoint;

		static public var mouseXWorldPhys:Number;
		static public var mouseYWorldPhys:Number;
		static public var mouseXWorld:Number;
		static public var mouseYWorld:Number;

		private var mousePVec:b2Vec2 = new b2Vec2();
		private var mouseDown:Boolean = false;

		public function Main():void
		{
			//コンテナ
			m_sprite = new Sprite();
			addChild(m_sprite);
			
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			stage.addEventListener(MouseEvent.CLICK, onMouseUp);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			stage.addEventListener(Event.MOUSE_LEAVE, onMouseLeave);

			addEventListener(Event.ENTER_FRAME, update, false, 0, true);

			//WORLD

			var worldAABB:b2AABB = new b2AABB();
			worldAABB.lowerBound.Set(-1000.0, -1000.0);
			worldAABB.upperBound.Set(1000.0, 1000.0);
			var gravity:b2Vec2 = new b2Vec2(0.0, 10.0);
			var doSleep:Boolean = true;
			m_world = new b2World(worldAABB, gravity, doSleep);

			//デバック用

			var dbgDraw:b2DebugDraw= new b2DebugDraw();
			var dbgSprite:Sprite= new Sprite();
			m_sprite.addChild(dbgSprite);
			dbgDraw.m_sprite= dbgSprite;
			dbgDraw.m_drawScale= 30.0;
			dbgDraw.m_fillAlpha = 0.3;
			dbgDraw.m_lineThickness= 1.0;
			dbgDraw.m_alpha=1.0;
			dbgDraw.m_xformScale=1.0;
			dbgDraw.m_drawFlags = b2DebugDraw.e_shapeBit;
			m_world.SetDebugDraw(dbgDraw);
			
			createDunbor(232/m_physScale, 1.1);
			createDunbor(232/m_physScale, 3.5);
			createDunbor(232/m_physScale, 5.1);
			createOtherObject();
			createWall();

		}
		private function createOtherObject():void
		{
			var circ:b2CircleDef = new b2CircleDef();
			var bd:b2BodyDef = new b2BodyDef();
			var body:b2Body;
			
			circ.radius = 10 / m_physScale;
			circ.density = 1.0;
			circ.friction = 0.0;
			circ.restitution = 0.0;
			bd = new b2BodyDef();
			bd.position.Set(50 / m_physScale, 100 / m_physScale);
			var circbd:b2Body = m_world.CreateBody(bd);
			circbd.CreateShape(circ);
			circbd.SetMassFromShapes();
		}
		private function createDunbor(x:Number,y:Number):void
		{
			// 頭
			var bodyDef1:b2BodyDef = new b2BodyDef();
			bodyDef1.position.Set(x, y);
			bodyDef1.userData = new Head();
			addChild(bodyDef1.userData);
			var polygonDef1:b2PolygonDef = new b2PolygonDef();
			polygonDef1.SetAsBox(0.8, 0.5);
			polygonDef1.density = 0.2;
			polygonDef1.friction = 0.4;
			polygonDef1.restitution = 2;
			var body1:b2Body = m_world.CreateBody(bodyDef1);
			body1.CreateShape(polygonDef1);
			body1.SetMassFromShapes();
			
			// 体
			var bodyDef2:b2BodyDef = new b2BodyDef();
			bodyDef2.position.Set(x, y+1.1);
			bodyDef2.userData = new Body();
			addChild(bodyDef2.userData);
			var polygonDef2:b2PolygonDef = new b2PolygonDef();
			polygonDef2.SetAsBox(0.5, 0.6);
			polygonDef2.density = 1;
			polygonDef2.friction = 0.4;
			polygonDef2.restitution = 5;
			var body2:b2Body = m_world.CreateBody(bodyDef2);
			body2.CreateShape(polygonDef2);
			body2.SetMassFromShapes();
			
			// 左足
			var bodyDef3:b2BodyDef = new b2BodyDef();
			bodyDef3.position.Set(x-0.3, y+2.1);
			var polygonDef3:b2PolygonDef = new b2PolygonDef();
			polygonDef3.SetAsBox(0.2, 0.4);
			polygonDef3.density = 10;
			polygonDef3.friction = 0.4;
			polygonDef3.restitution = 0.3;
			var body3:b2Body = m_world.CreateBody(bodyDef3);
			body3.CreateShape(polygonDef3);
			body3.SetMassFromShapes();
			
			// 右足
			var bodyDef4:b2BodyDef = new b2BodyDef();
			bodyDef4.position.Set(x+0.3, y+2.1);
			var polygonDef4:b2PolygonDef = new b2PolygonDef();
			polygonDef4.SetAsBox(0.2, 0.4);
			polygonDef4.density = 10;
			polygonDef4.friction = 0.4;
			polygonDef4.restitution = 0.3;
			var body4:b2Body = m_world.CreateBody(bodyDef4);
			body4.CreateShape(polygonDef4);
			body4.SetMassFromShapes();
			
			// 左手
			var bodyDef5:b2BodyDef = new b2BodyDef();
			bodyDef5.position.Set(x-0.8, y+0.9);
			bodyDef5.angle = 30 * Math.PI / 180;
			var polygonDef5:b2PolygonDef = new b2PolygonDef();
			polygonDef5.SetAsBox(0.2, 0.4);
			polygonDef5.density = 1;
			polygonDef5.friction = 0.4;
			polygonDef5.restitution = 0.3;
			var body5:b2Body = m_world.CreateBody(bodyDef5);
			body5.CreateShape(polygonDef5);
			body5.SetMassFromShapes();
			
			// 右手
			var bodyDef6:b2BodyDef = new b2BodyDef();
			bodyDef6.position.Set(x+0.8, y+0.9);
			bodyDef6.angle = 330 * Math.PI / 180;
			var polygonDef6:b2PolygonDef = new b2PolygonDef();
			polygonDef6.SetAsBox(0.2, 0.4);
			polygonDef6.density = 1;
			polygonDef6.friction = 0.4;
			polygonDef6.restitution = 0.3;
			var body6:b2Body = m_world.CreateBody(bodyDef6);
			body6.CreateShape(polygonDef5);
			body6.SetMassFromShapes();
			
			// 頭と体をジョイント
			var distance1:b2DistanceJointDef = new b2DistanceJointDef();
			distance1.Initialize(body1, body2, new b2Vec2(x-0.4, y+0.5), new b2Vec2(x-0.4, y+0.51));
			m_world.CreateJoint(distance1);
			var distance2:b2DistanceJointDef = new b2DistanceJointDef();
			distance2.Initialize(body1, body2, new b2Vec2(x+0.4, y+0.5), new b2Vec2(x+0.4, y+0.51));
			m_world.CreateJoint(distance2);
			
			// 体と左足をジョイント
			distance1.Initialize(body2, body3, new b2Vec2(x-0.5, y+1.7), new b2Vec2(x-0.5, y+1.71));
			m_world.CreateJoint(distance1);
			distance2.Initialize(body2, body3, new b2Vec2(x-0.1, y+1.7), new b2Vec2(x-0.1, y+1.71));
			m_world.CreateJoint(distance2);
			
			// 体と右足をジョイント
			distance1.Initialize(body2, body4, new b2Vec2(x+0.1, y+1.7), new b2Vec2(x+0.1, y+1.71));
			m_world.CreateJoint(distance1);
			distance2.Initialize(body2, body4, new b2Vec2(x+0.5, y+1.7), new b2Vec2(x+0.5, y+1.71));
			m_world.CreateJoint(distance2);
		
			// 体と左手をジョイント
			distance1.Initialize(body2, body5, new b2Vec2(x-0.51, y+0.5), new b2Vec2(x-0.51, y+0.51));
			m_world.CreateJoint(distance1);
			//distance2.Initialize(body2, body5, new b2Vec2(x-0.7, y+0.5), body5.GetWorldCenter());
			//m_world.CreateJoint(distance2);

			// 体と右手をジョイント
			distance1.Initialize(body2, body6, new b2Vec2(x+0.5, y+0.5), new b2Vec2(x+0.51, y+0.51));
			m_world.CreateJoint(distance1);
			//distance2.Initialize(body1, body6, new b2Vec2(x+0.8, y+0.5), body6.GetWorldCenter());
			//m_world.CreateJoint(distance2);
		}
		private function createWall():void
		{
			var wallObject:b2PolygonDef = new b2PolygonDef();
			wallObject.density = 0.0;
			var wallDef:b2BodyDef = new b2BodyDef();
			var wallBody:b2Body;

			//Left
			wallDef.position.Set(-6 / m_physScale, 465/2 / m_physScale);
			wallObject.SetAsBox(10/2 / m_physScale, 465/2 / m_physScale);
			wallBody = m_world.CreateBody(wallDef);
			wallBody.CreateShape(wallObject);
			wallBody.SetMassFromShapes();

			//Right
			wallDef.position.Set((465+14/2) / m_physScale, 465/2 / m_physScale);
			wallObject.SetAsBox(10/2 / m_physScale, 465/2 / m_physScale);
			wallBody = m_world.CreateBody(wallDef);
			wallBody.CreateShape(wallObject);
			wallBody.SetMassFromShapes();

			//Top
			wallDef.position.Set(465/2 / m_physScale, -7 / m_physScale);
			wallObject.SetAsBox(465/2 / m_physScale, 10/2 / m_physScale);
			wallBody = m_world.CreateBody(wallDef);
			wallBody.CreateShape(wallObject);
			wallBody.SetMassFromShapes();

			//Bottom
			wallDef.position.Set(465/2 / m_physScale, (465-10/2) / m_physScale);
			wallObject.SetAsBox(465/2 / m_physScale, 10/2 / m_physScale);
			wallBody = m_world.CreateBody(wallDef);
			wallBody.CreateShape(wallObject);
			wallBody.SetMassFromShapes();
		}
		
		private function update(event:Event):void
		{			
			m_world.Step(m_timeStep, m_iterations);
			m_sprite.graphics.clear();
			
			UpdateMouseWorld();
			MouseDrag();
			
			for (var bb:b2Body = m_world.m_bodyList; bb; bb = bb.m_next)
			{
				if (bb.m_userData is Sprite)
				{
					bb.m_userData.x = bb.GetPosition().x * 30;
					bb.m_userData.y = bb.GetPosition().y * 30;
					bb.m_userData.rotation = bb.GetAngle() * 180 / Math.PI;
				}
			}
			
			// joints
			for (var jj:b2Joint = m_world.m_jointList; jj; jj = jj.m_next){
				DrawJoint(jj);
			}
		}
		
		private function onMouseDown(event:MouseEvent):void
		{
			mouseDown = true;
		}
		
		private function onMouseUp(event:MouseEvent):void
		{
			mouseDown = false;
		}
		
		private function onMouseMove(event:MouseEvent):void
		{
			if (mouseDown != event.buttonDown){
				mouseDown = event.buttonDown;
			}
		}
		
		public function onMouseLeave(e:Event):void
		{
			mouseDown = false;
			MouseDrag();
		}
		
		//======================
		// Update mouseWorld
		//======================
		public function UpdateMouseWorld():void
		{
			mouseXWorldPhys = (mouseX)/m_physScale; 
			mouseYWorldPhys = (mouseY)/m_physScale; 
			
			mouseXWorld = (mouseX); 
			mouseYWorld = (mouseY); 
		}
		
		//======================
		// Mouse Drag 
		//======================
		public function MouseDrag():void
		{
			// mouse press
			if (mouseDown && !m_mouseJoint){
				
				var body:b2Body = GetBodyAtMouse();
				
				if (body)
				{
					var md:b2MouseJointDef = new b2MouseJointDef();
					md.body1 = m_world.GetGroundBody();
					md.body2 = body;
					md.target.Set(mouseXWorldPhys, mouseYWorldPhys);
					md.maxForce = 300.0 * body.GetMass();
					md.timeStep = m_timeStep;
					m_mouseJoint = m_world.CreateJoint(md) as b2MouseJoint;
					body.WakeUp();
				}
			}
			
			// mouse release
			if (!mouseDown){
				if (m_mouseJoint)
				{
					m_world.DestroyJoint(m_mouseJoint);
					m_mouseJoint = null;
				}
			}
			
			// mouse move
			if (m_mouseJoint)
			{
				var p2:b2Vec2 = new b2Vec2(mouseXWorldPhys, mouseYWorldPhys);
				m_mouseJoint.SetTarget(p2);
			}
		}
		
		//======================
		// GetBodyAtMouse
		//======================
		public function GetBodyAtMouse(includeStatic:Boolean = false):b2Body
		{
			// Make a small box.
			mousePVec.Set(mouseXWorldPhys, mouseYWorldPhys);
			var aabb:b2AABB = new b2AABB();
			aabb.lowerBound.Set(mouseXWorldPhys - 0.001, mouseYWorldPhys - 0.001);
			aabb.upperBound.Set(mouseXWorldPhys + 0.001, mouseYWorldPhys + 0.001);
			
			// Query the world for overlapping shapes.
			var k_maxCount:int = 10;
			var shapes:Array = new Array();
			var count:int = m_world.Query(aabb, shapes, k_maxCount);
			var body:b2Body = null;
			for (var i:int = 0; i < count; ++i)
			{
				if (shapes[i].GetBody().IsStatic() == false || includeStatic)
				{
					var tShape:b2Shape = shapes[i] as b2Shape;
					var inside:Boolean = tShape.TestPoint(tShape.GetBody().GetXForm(), mousePVec);
					if (inside)
					{
						body = tShape.GetBody();
						break;
					}
				}
			}
			return body;
		}

		//======================
		// Draw Joint 
		//======================
		public function DrawJoint(joint:b2Joint):void
		{
			var b1:b2Body = joint.m_body1;
			var b2:b2Body = joint.m_body2;
			
			var x1:b2Vec2 = b1.m_linearVelocity;
			var x2:b2Vec2 = b2.m_linearVelocity;
			var p1:b2Vec2 = joint.GetAnchor1();
			var p2:b2Vec2 = joint.GetAnchor2();
			
			m_sprite.graphics.lineStyle(1,0x44aaff,1/1);
			
			switch (joint.m_type)
			{
			case b2Joint.e_distanceJoint:
			case b2Joint.e_mouseJoint:
				m_sprite.graphics.moveTo(p1.x * m_physScale, p1.y * m_physScale);
				m_sprite.graphics.lineTo(p2.x * m_physScale, p2.y * m_physScale);
				break;
				
			case b2Joint.e_pulleyJoint:
				var pulley:b2PulleyJoint = joint as b2PulleyJoint;
				var s1:b2Vec2 = pulley.m_groundAnchor1;
				var s2:b2Vec2 = pulley.m_groundAnchor2;
				m_sprite.graphics.moveTo(s1.x * m_physScale, s1.y * m_physScale);
				m_sprite.graphics.lineTo(p1.x * m_physScale, p1.y * m_physScale);
				m_sprite.graphics.moveTo(s2.x * m_physScale, s2.y * m_physScale);
				m_sprite.graphics.lineTo(p2.x * m_physScale, p2.y * m_physScale);
				break;
				
			default:
				if (b1 == m_world.m_groundBody){
					m_sprite.graphics.moveTo(p1.x * m_physScale, p1.y * m_physScale);
					m_sprite.graphics.lineTo(x2.x * m_physScale, x2.y * m_physScale);
				}
				else if (b2 == m_world.m_groundBody){
					m_sprite.graphics.moveTo(p1.x * m_physScale, p1.y * m_physScale);
					m_sprite.graphics.lineTo(x1.x * m_physScale, x1.y * m_physScale);
				}
				else{
					m_sprite.graphics.moveTo(x1.x * m_physScale, x1.y * m_physScale);
					m_sprite.graphics.lineTo(p1.x * m_physScale, p1.y * m_physScale);
					m_sprite.graphics.lineTo(x2.x * m_physScale, x2.y * m_physScale);
					m_sprite.graphics.lineTo(p2.x * m_physScale, p2.y * m_physScale);
				}
			}
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
		
		scaleX = scaleY = 0.333;
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
		
		scaleX = scaleY = 0.333;
	}
}
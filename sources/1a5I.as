//ソース適当すぎるので見ないでぇぇ
package{
	
	import Box2D.Dynamics.Contacts.*;
	import flash.display.*;
	import flash.events.*;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	import Box2D.Dynamics.*;
	import Box2D.Collision.*;
	import Box2D.Collision.Shapes.*;
	import Box2D.Common.Math.*;
	import net.hires.debug.Stats;
	import flash.system.Security;

	[SWF(width = "465", height = "465", frameRate = "60", backgroundColor = "0xFFFFFF")]
	
	public class Onomatopoeia extends Sprite{
		
		public static var DRAW_SCALE:int = 30;
		
		public var m_iterations:int = 10;
		public var m_timeStep:Number = 1.0 / 30.0;
		
		private var _world:b2World;
		private var _oLayer:Sprite = new Sprite();
		private var _eLayer:Sprite = new Sprite();
		private var _wLayer:Sprite = new Sprite();
		
		private var _loader:Loader = new Loader();
		
		public function Onomatopoeia(){
                        Wonderfl.capture_delay( 20 );
			Security.loadPolicyFile("http://labs.minomix.net/crossdomain.xml");  
			_loader.contentLoaderInfo.addEventListener(Event.INIT, _loadInitHandler );
			//_loader.load( new URLRequest("../material/gion2.png") );
			_loader.load( new URLRequest("http://labs.minomix.net/img/gion.png") );
			
		}
		
		private function _loadInitHandler(e:Event):void {
			
			var tmp:BitmapData = new BitmapData( _loader.width, _loader.height, true, 0 );
			tmp.draw( _loader );
			
			CreateEffect.init( tmp );
			_init();
			
		}
		
		private function _init():void {
			
			this.addChild( _wLayer );
			this.addChild( _oLayer );
			this.addChild( _eLayer );
			_oLayer.visible = false;
			_wLayer.visible = false;
			
			// Add event for main loop
			addEventListener(Event.ENTER_FRAME, Update, false, 0, true);
			
			// Creat world AABB
			var worldAABB:b2AABB = new b2AABB();
			worldAABB.lowerBound.Set(-100, -100);
			worldAABB.upperBound.Set(465+100, 465+100);
			
			// Define the gravity vector
			var gravity:b2Vec2 = new b2Vec2(0.0, 10.0);
			
			// Allow bodies to sleep
			var doSleep:Boolean = true;
			
			// Construct a world object
			_world = new b2World(worldAABB, gravity, doSleep);
			
			_createWall( 0, 465 / 2, 50, 465, 0 );
			_createWall( 465, 465 / 2, 50, 465, 0 );
			_createWall( 465 / 2, 120, 300, 10, 0 );
			_createWall( 465 / 2 + 70, 210, 465, 10, -8 );
			_createWall( 465 / 2 - 70, 330, 465, 10, 5 );
			_createWall( 465 / 2 + 70, 440, 465, 10, -5 );
			
			//衝突判定のリスナをセットする
			_world.SetContactListener( new ContactListener( _eLayer ) );
			
			var t:Timer = new Timer( 1000 );
			t.addEventListener( TimerEvent.TIMER, _createBody );
			t.start();
			
			//debug();
			
			stage.addEventListener(MouseEvent.CLICK, _clickHandler );
			
		}
		
		private function _clickHandler(e:Event):void {
			_oLayer.visible = !_oLayer.visible;
			_wLayer.visible = !_wLayer.visible;
		}
		
		private function _createWall( x:int, y:int, w:int, h:int, r:int ):void {
			
			// Vars used to create bodies
			var body:b2Body;
			var bodyDef:b2BodyDef;
			var boxDef:b2PolygonDef;
			
			// Add ground body
			bodyDef = new b2BodyDef();
			
			bodyDef.position.Set(x / DRAW_SCALE, y / DRAW_SCALE);
			bodyDef.angle = r / (180 / Math.PI);
			
			boxDef = new b2PolygonDef();
			boxDef.SetAsBox(w / 2 / DRAW_SCALE, h / 2 / DRAW_SCALE);
			
			boxDef.friction = 0.3;
			boxDef.density = 0; // static bodies require zero density
			
			// Add sprite to body userData
			bodyDef.userData = new PhysBox();
			bodyDef.userData.width = w;
			bodyDef.userData.height = h; 
			bodyDef.userData.x = x;
			bodyDef.userData.y = y;
			bodyDef.userData.rotation = r;
			_wLayer.addChild(bodyDef.userData);
			body = _world.CreateBody(bodyDef);
			body.CreateShape(boxDef);
			
			body.SetMassFromShapes();
			
		}
		
		private function _createBody( e:TimerEvent ):void {
			
			var bodyDef:b2BodyDef;
			var circleDef:b2CircleDef;
			var body:b2Body;
			
			bodyDef = new b2BodyDef();
			bodyDef.position.x = ( Math.random() * 265 + 100 ) / 30 ;
			bodyDef.position.y = 0;
			var rX:Number = Math.random()/4 + 0.3;
			var rY:Number = Math.random()/4 + 0.3;
			
			// Circle
			circleDef = new b2CircleDef();
			circleDef.radius = rX;
			circleDef.density = 1.0;
			circleDef.friction = 0.4;
			circleDef.restitution = 0.5
			
			bodyDef.userData = new PhysCircle();
			bodyDef.userData.width = rX * 2 * DRAW_SCALE;
			bodyDef.userData.height = rX * 2 * DRAW_SCALE;
			
			body = _world.CreateBody(bodyDef);
			body.CreateShape(circleDef);
			
			body.SetMassFromShapes();
			_oLayer.addChild(bodyDef.userData);
			
		}
		
		public function debug():void {
			
			// set debug draw
			var dbgDraw:b2DebugDraw = new b2DebugDraw();
			var dbgSprite:Sprite = new Sprite();
			addChild(dbgSprite);
			dbgDraw.m_sprite = dbgSprite;
			dbgDraw.m_drawScale = 30.0;
			dbgDraw.m_fillAlpha = 0.0;
			dbgDraw.m_lineThickness = 0;
			dbgDraw.m_drawFlags = 0xFFFFFFFF;
			_world.SetDebugDraw(dbgDraw);
			
		}
		
		
		public function Update(e:Event):void{
			
			_world.Step(m_timeStep, m_iterations);
			
			
			//表示周りの更新
			for (var bb:b2Body = _world.m_bodyList; bb; bb = bb.m_next) {
				
				//画面外に出たときの判定
				var bx:Number = bb.GetPosition().x * DRAW_SCALE;
				var by:Number = bb.GetPosition().y * DRAW_SCALE;
				if ( bx < -100 || bx > 465+100 || by < -100 ) {
					_oLayer.removeChild( bb.GetUserData() );
					_world.DestroyBody( bb );
					break;
				}
				
				if (bb.m_userData is Sprite){
					bb.m_userData.x = bb.GetPosition().x * DRAW_SCALE;
					bb.m_userData.y = bb.GetPosition().y * DRAW_SCALE;
					bb.m_userData.rotation = bb.GetAngle() * (180 / Math.PI);
				}
				
			}
			
		}
		
	}
	
}

import Box2D.Collision.b2ContactPoint;
import Box2D.Collision.Shapes.b2Shape;
import Box2D.Dynamics.b2ContactListener;
import flash.display.*;
import flash.geom.*;
import flash.text.*;
import org.libspark.betweenas3.BetweenAS3;
import org.libspark.betweenas3.easing.Quad;
import org.libspark.betweenas3.events.TweenEvent;
import org.libspark.betweenas3.tweens.ITween;

class PhysBox extends Sprite {
	
	public var count:int = 0;
	
	public function PhysBox() {
		this.graphics.beginFill( 0x999999 );
		this.graphics.drawRect( -50, -50, 100, 100 );
		this.graphics.endFill();
	}
}

class PhysCircle extends Sprite {
	
	public var count:int = 0;
	
	public function PhysCircle() {
		this.graphics.beginFill( 0x999999 );
		this.graphics.drawCircle(0, 0, 100 );
		this.graphics.endFill();
	}
}

class CreateEffect extends Sprite {
	
	public static var _images:Vector.<BitmapData> = new Vector.<BitmapData>;
	
	public static function init( b:BitmapData ):void {
		
		for ( var i:int = 0 ; i < 5 ; i++ ) {
			
			var img:BitmapData = new BitmapData(120, 120, true, 0x0 );
			img.copyPixels( b, new Rectangle( 120*i, 0, 120, 120 ), new Point( 0, 0 ), null, null, true );
			
			_images.push( img );
			
		}
		
	}
	
	public function CreateEffect( px:Number, py:Number, f:Number ) {
		
		var b:Bitmap;
		if ( f > 7.5 )		b = Bitmap( addChild( new Bitmap( _images[0] ) ) );
		else if ( f > 6 )	b = Bitmap( addChild( new Bitmap( _images[1] ) ) );
		else if ( f > 3 )	b = Bitmap( addChild( new Bitmap( _images[2] ) ) );
		else if ( f > 0 )	b = Bitmap( addChild( new Bitmap( _images[3] ) ) );
		else				{ b = Bitmap( addChild( new Bitmap( _images[4] ) ) ); f = 3; }
		
		this.x = px
		b.x = -b.width/2;
		this.y = py
		b.y = -b.height/2;
		this.rotation = Math.random() * 90 - 45;
		
		var bt:ITween = BetweenAS3.tween( this, { alpha:0, scaleX:0.5, scaleY:0.5 }, null, 0.4, Quad.easeIn );
		bt.addEventListener( TweenEvent.COMPLETE, _complete );
		bt.play();
		
	}
	
	private function _complete(e:TweenEvent):void {
		this.parent.removeChild( this );
	}
	
}

class ContactListener extends b2ContactListener {
	
	private var _root:Sprite;
	
	public function ContactListener( root:Sprite ) {
		_root = root;
	}
	
	public override function Add(point:b2ContactPoint):void {
		
		var f:Number = point.shape1.GetBody().m_linearVelocity.Length() + point.shape2.GetBody().m_linearVelocity.Length();
		
		//trace("ガン！", f/*, point.position.x, point.position.y*/ );
		if ( f > 3 ) {
			_root.addChild( new CreateEffect( point.position.x * Onomatopoeia.DRAW_SCALE, point.position.y * Onomatopoeia.DRAW_SCALE, f ) );
		}
		
	}
	
	public override function Persist( point:b2ContactPoint ):void {
		
		var shape:b2Shape;
		
		if ( point.shape1.m_density == 0 && point.shape2.m_density == 1 ) shape = point.shape2;
		else if ( point.shape1.m_density == 1 && point.shape2.m_density == 0 ) shape = point.shape1;
		else return;
		
		shape.GetBody().GetUserData().count += Math.ceil( shape.GetBody().m_linearVelocity.Length() );
		
		if ( shape.GetBody().GetUserData().count > 0 ) {
			_root.addChild( new CreateEffect( point.position.x * Onomatopoeia.DRAW_SCALE, point.position.y * Onomatopoeia.DRAW_SCALE, -1 ) );
			shape.GetBody().GetUserData().count = -20;
		}
		
	}
	
	public override function Remove(point:b2ContactPoint):void {
		
		point.shape1.GetBody().m_userData.count = -5;
		point.shape2.GetBody().m_userData.count = -5;
		
	}
	
}


package  {
	import flash.display.*;
	import flash.events.*;
	import flash.filters.*;
	import flash.geom.*;
	import flash.media.Sound;
	import flash.media.SoundTransform;
	import flash.net.*;
	import flash.system.LoaderContext;
	import caurina.transitions.Tweener;
	import flash.utils.Timer;
	import net.hires.debug.Stats;
	
	import Box2D.Collision.*;
	import Box2D.Collision.Shapes.*;
	import Box2D.Common.Math.*;
	import Box2D.Dynamics.*;
	
	import com.bit101.components.*;
	
	[SWF(width="465", height="465", backgroundColor="0xFFFFFF", frameRate="60")]     
	public class Coins extends Sprite {
		private var imgs:Array = [];
		private var radiuses:Array = [
			10, 11, 11.75, 10.5, 11.3, 13.25
		];
		private var densities:Array = [
			2.066947313, 6.488961867, 7.980747225, 7.699105335, 7.038588188, 6.345800508
		];
		private var coinsThreshold:int = 20;
		private var coins:Array = [];
		
		private var sndCoin:Sound = new Sound(new URLRequest(
			"http://www.t-p.jp/wonderfl/sound/coin10.mp3"));
		private var sndFall:Sound = new Sound(new URLRequest(
			"http://www.t-p.jp/wonderfl/sound/coin7.mp3"));		
		private var st:SoundTransform = new SoundTransform(0.5);
		
		private static const DRAW_SCALE:Number = 100;
		private var world:b2World;
		
		public function Coins() {
			
			var g:Graphics = graphics;
			g.beginFill(0xdddddd);
			g.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			
			var urls:Array = 
[
"http://farm4.static.flickr.com/3510/3839291754_e052151b03_o.png",
"http://farm3.static.flickr.com/2431/3838502983_51a53798f8_o.png",
"http://farm4.static.flickr.com/3552/3838503031_68c19321d6_o.png",
"http://farm4.static.flickr.com/3497/3839291934_d68967a908_o.png",
"http://farm4.static.flickr.com/3104/3838503121_15d1263b89_o.png",
"http://farm3.static.flickr.com/2466/3839292046_cb9cacd41b_o.png",
"http://farm3.static.flickr.com/2538/3838503213_ed8af9fbd0_o.png",
"http://farm3.static.flickr.com/2608/3838503261_9fca2704ca_o.png",
"http://farm3.static.flickr.com/2493/3839292186_67b9c39a3a_o.png",
"http://farm4.static.flickr.com/3548/3838503371_bc956d6fbd_o.png",
"http://farm4.static.flickr.com/3507/3838503419_9de5074c7f_o.png",
"http://farm4.static.flickr.com/3577/3838503481_9b67b42bed_o.png"
];

			var pb:ProgressBar = new ProgressBar(this, stage.stageWidth / 2 - 100, stage.stageHeight / 2);
			pb.width = 200;
			pb.maximum = urls.length;
			pb.value = 0;
			var lb:Label = new Label(this, pb.x, pb.y - 20, "loading...");
			var date:String = new Date().valueOf().toString();
				
			for (var i:int = 0; i < pb.maximum; i++)
			{
				var loader:Loader = new Loader();
				loader.name = i.toString();		
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function (e:Event):void 
				{
					imgs[int(e.target.loader.name)] = e.target.loader.content as Bitmap;
					pb.value++;
					lb.text = pb.value.toString() + " / " + pb.maximum.toString();
					if (pb.value == pb.maximum)
					{
						removeChild(pb);
						pb = null;
						removeChild(lb);
						lb = null;
						g.clear();
						init();
					}
				});
				loader.load(new URLRequest(urls[i] + "?" + date), new LoaderContext(true));
			}
		}
		private function init():void 
		{
			//world
			var worldAABB:b2AABB = new b2AABB();
			worldAABB.lowerBound.Set(-100, -100);
			worldAABB.upperBound.Set(100, 100);
			var gravity:b2Vec2 = new b2Vec2(0, 10);
			world = new b2World(worldAABB, gravity, true);
			
			//wall
			makeWall();
			
			//debug
//			debugDraw();		
//			addChild(new Stats());
			
			//evts
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);

			var timer:Timer = new Timer(100);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, function ():void 
			{
				addCoin();
				timer.reset();
				timer.start();
				stage.addEventListener(MouseEvent.MOUSE_UP, function ():void 
				{
					timer.stop();
				});
			});
			timer.addEventListener(TimerEvent.TIMER, function ():void 
			{
				addCoin();
			});
		}
		private function addCoin():void 
		{
				sndCoin.play(0,0,st);
			var i:int = Math.floor(Math.random() * radiuses.length);
			addCircle(
				mouseX, mouseY, 
				radiuses[i] * 4, 
				densities[i], 
				imgs[Math.random() < 0.5 ? i * 2 : i * 2 + 1] as Bitmap );
		}
		private function debugDraw():void 
		{
			var debugDraw:b2DebugDraw = new b2DebugDraw();
			debugDraw.m_sprite = this;
			debugDraw.m_drawScale = DRAW_SCALE;
			debugDraw.m_fillAlpha = 0.3;
			debugDraw.m_lineThickness = 1;
			debugDraw.m_drawFlags = b2DebugDraw.e_shapeBit | b2DebugDraw.e_jointBit;
			world.SetDebugDraw(debugDraw);
		}
		private function makeWall():void {
			
			var bd:b2BodyDef = new b2BodyDef();
			bd.position.Set(0, 0);
			
			var wall:b2Body = world.CreateBody(bd);
			
			var w:Number = stage.stageWidth / DRAW_SCALE;
			var h:Number = stage.stageHeight / DRAW_SCALE;
			var wallSize:Number = 50 / DRAW_SCALE;
			
			var sd:b2PolygonDef = new b2PolygonDef();
			sd.filter.categoryBits = parseInt("010",2);
			
			//top
			sd.SetAsOrientedBox(w / 2 + wallSize * 2, wallSize, new b2Vec2(w / 2, -wallSize - h/2));
			wall.CreateShape(sd);
			//bottom
			sd.SetAsOrientedBox(w / 2 + wallSize * 2, wallSize, new b2Vec2(w / 2,  h + wallSize));
			wall.CreateShape(sd);
			//left
			sd.SetAsOrientedBox(wallSize, h, new b2Vec2(-wallSize, h / 2));
			wall.CreateShape(sd);
			//right
			sd.SetAsOrientedBox(wallSize, h, new b2Vec2(w + wallSize,  h / 2));
			wall.CreateShape(sd);

		}
		
		
		private function enterFrameHandler(event:Event):void {
			for (var b:b2Body = world.GetBodyList(); b; b = b.GetNext()) {
				if (b.GetUserData() is Sprite) {
					if (b.GetWorldCenter().y *DRAW_SCALE > 500)
					{
						removeChild(b.GetUserData());
						world.DestroyBody(b);
					}
					else
					{
						b.GetUserData().x = b.GetWorldCenter().x * DRAW_SCALE;
						b.GetUserData().y = b.GetWorldCenter().y * DRAW_SCALE;
						b.GetUserData().rotation = b.GetAngle() * 180 / Math.PI;
					}
				}
			}
			if (coinsThreshold < coins.length)
			{
				sndFall.play();
				var coinsLeft:int = coinsThreshold * Math.random() * 0.5;
				coinsThreshold = Math.random() * 10 + 20;
				while(coinsLeft < coins.length)
				{
					var b1:b2Body = coins.shift() as b2Body;
					var sp:b2Shape = b1.GetShapeList();
					var f:b2FilterData = new b2FilterData();
					
					f.maskBits = parseInt("001",2);
					sp.SetFilterData(f);
					world.Refilter(sp);
				}
			}
		
			world.Step(1 / stage.frameRate, 10);
		}
		
		private function addCircle(posX:Number , posY:Number, radius:Number, density:Number, bmpSource:Bitmap):void 
		{
			//body def
			var bd:b2BodyDef = new b2BodyDef();
			bd.position.Set(posX / DRAW_SCALE, posY / DRAW_SCALE);
			
			//shape def
			var sd:b2CircleDef = new b2CircleDef();
			sd.radius = radius / DRAW_SCALE;
			sd.density = density;
			sd.restitution = 0.5;
			
			var bmp:Bitmap = new Bitmap(bmpSource.bitmapData.clone());
			bmp.smoothing = true;
			//img
			bmp.width = 
			bmp.height = radius * 2;
			bmp.x = 
			bmp.y = -radius;
			
			//body
			var body:b2Body = world.CreateBody(bd);
			body.CreateShape(sd);
			body.SetMassFromShapes();
			var num:Number = Math.random() - 0.5;
			body.SetAngularVelocity(num * Math.PI*2 * 10);
			body.SetLinearVelocity(new b2Vec2(num * 10, -Math.random() * 2 - 5));
			
			body.m_userData = new Sprite();
			body.GetUserData().x = body.GetWorldCenter().x * DRAW_SCALE;
			body.GetUserData().y = body.GetWorldCenter().y * DRAW_SCALE;
			body.GetUserData().addChild(bmp);
			
			coins.push(body);
			addChild(body.GetUserData());
		}
	}
}


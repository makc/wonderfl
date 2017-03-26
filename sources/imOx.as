// forked from makc3d's Airlines
package {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import org.papervision3d.core.math.Number3D;
	import org.papervision3d.materials.MovieMaterial;
	import org.papervision3d.materials.special.ParticleMaterial;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.primitives.Sphere;
	import org.papervision3d.objects.special.ParticleField;
	import org.papervision3d.view.BasicView;
	/**
	 * Global air traffic simulation.
	 * 
	 * - data is for April 2010, converted from http://arm.64hosts.com/
	 * - data had no schedule information, this part is random
	 * - data had equipment info, but I was too lazy to look up
	 *   flight speeds for 310 models, so they all fly at same speed
	 * - earth map from http://visibleearth.nasa.gov/view_rec.php?id=2433
	 * 
	 * @author makc
	 * @license WTFPLv2, http://sam.zoy.org/wtfpl/
	 */
	public class Airlines extends Sprite {
		private var pv3d:BasicView;
		private var earth:Sphere;
		private var container:Sprite;
		private var cameraTarget:DisplayObject3D;
		private var glowPadding:int = 17;
		public function Airlines () {
			Wonderfl.disable_capture();
			//Wonderfl.capture_delay(8);
			routeStep = routeMax / routeNum;
			//+ background box
			var bg:Sprite = new Sprite();
			bg.graphics.beginFill(0); bg.graphics.drawRect(0, 0, 465, 465);
			//+ container of movie material
			container = new Sprite();
			addChild(bg);
			addChild(container);
			//+ setup Papervision3D
			pv3d = new BasicView(465 + glowPadding * 2, 465 + glowPadding * 2, false, false, "Free");
			pv3d.viewport.filters = [new GlowFilter(0xDDEEFF, 1, 50, 50, 1, 1, true), new GlowFilter(0x99DDFF, 1, 20, 20, 2, 1)];
			var mm:MovieMaterial = new MovieMaterial(container, false, true, false, new Rectangle(0, 0, 465, 465));
			earth = pv3d.scene.addChild(new Sphere(mm, 500, 36, 32)) as Sphere;
			cameraTarget = pv3d.scene.addChild(new DisplayObject3D());
			addChild(pv3d);
			pv3d.x = pv3d.y = -glowPadding;
			//+ add background star
			var stars:ParticleField = pv3d.scene.addChild(new ParticleField(new ParticleMaterial(0xFFFFFF, 1, 0, 1), 200, 100, 3000, 3000, 3000)) as ParticleField;
			//+ adjust star position
			for each(var star:* in stars.particles) {
				var position:Number3D = star.vertex3D.toNumber3D();
				position.normalize();
				position.multiplyEq(Math.random() * 15000 + 15000);
				star.x = position.x;
				star.y = position.y;
				star.z = position.z;
			}
			// load map
			var map:Loader = new Loader; container.addChild (map);
			map.load (new URLRequest (/*"earth.jpg"*/
				"http://assets.wonderfl.net/images/related_images/0/03/037b/037b0a54baa857c99f974c47c676ff0c53164cd3"
			), new LoaderContext (true));
			// load data
			var data:Loader = new Loader;
			data.contentLoaderInfo.addEventListener (Event.COMPLETE, onDataReady);
			data.load (new URLRequest (/*"airlines.png"*/
				"http://assets.wonderfl.net/images/related_images/9/99/9991/99916b6cd6bc516fdaa9247f809b2bde80fea5f5"
			), new LoaderContext (true));

		}
		public var p:int = 0, color:uint;
		public var airports:Vector.<Location>;
		public var data:BitmapData, bd:BitmapData, ct:ColorTransform;
		public var routes:Vector.<Vector.<Location>>;
		public var particles:Vector.<Particle>;
		private var routeMax:int = 60237;
		//+ used route num
		private var routeNum:int = 1500;
		private var routeStep:int;
		private var routeCount:int = 0;
		public function onDataReady (e:Event):void {
			data = Bitmap(LoaderInfo(e.target).content).bitmapData;
			bd = new BitmapData (465, 465, true, 0); container.addChild (new Bitmap (bd));
			ct = new ColorTransform (0.7, 1.0, 0.9, 0.9); 
			// unpack airports data
			airports = new Vector.<Location>(3338, true);
			while (p < 3338) {
				color = data.getPixel (p % 252, p / 252);
				airports [p] = new Location (
					(2 * (color & 4095) / 4095.0 - 1) * Math.PI,
					(1 - ((color >> 12) & 4095) / 4095.0) * Math.PI
				);
				//bd.setPixel32 (airports [p].sx, airports [p].sy, 0xFFFF0000);
				p++;
			}
			// unpack routes data
			// this takes some time, we have to async it...
			routes = new Vector.<Vector.<Location>>(routeNum, true);
			particles = new Vector.<Particle>(routeNum, true);
			addEventListener (Event.ENTER_FRAME, unpackRoutes);
		}
		public function unpackRoutes (e:Event):void {
			var count:int = 0;
			while (count++ < 1000) {
				color = data.getPixel (p % 252, p / 252);
				var a:Location = airports [(color >> 12) & 4095];
				var b:Location = airports [(color) & 4095];
				var omega:Number = Math.acos (a.x * b.x + a.y * b.y + a.z * b.z);
				var N:int = Math.max (3, omega / 0.006); // ~500 values for PI arc
				routes [routeCount] = new Vector.<Location> (N, true);
				particles [routeCount] = new Particle;
				particles [routeCount].i = int (Math.random () * (N - 1));
				for (var i:int = 0; i < N; i++)
					routes [routeCount] [i] = a.slerp (b, i / (N -1));
				routeCount++;
				p += routeStep; if (routeCount >= routeNum) {
					// launch simulation
					removeEventListener (Event.ENTER_FRAME, unpackRoutes);
					addEventListener (Event.ENTER_FRAME, simulation);
					//+ get some long routes
					for (var n:int = 0; n < routeCount; n+=10) if(routes [n].length > 100) trackingSeeds.push(n);
					trackingSeed = trackingSeeds[0];
					container.visible = false;
					stage.addEventListener (MouseEvent.CLICK, onClick);
					pv3d.startRendering();
					break;
				}
			}
			// show progress
			var r:Rectangle = new Rectangle (50, 300, 365, 20);
			bd.fillRect (r, 0x7F00FF00); r.width = 365 * routeCount / routeNum;
			bd.fillRect (r, 0xFF00FF00);
		}
		private var trackingSeed:int;
		private var trackingSeeds:Array = new Array();
		private var trackingIndex:int = 0;
		private function onClick(e:MouseEvent):void {
			//+ change tracking route
			trackingIndex = (trackingIndex + 1) % trackingSeeds.length;
			trackingSeed = trackingSeeds[trackingIndex];
		}
		public function simulation (e:Event):void {
			//var A:int = Math.max (0, Math.min (60237, 60237 * mouseX / 465));
			//var B:int = Math.max (0, Math.min (60237, 60237 * mouseY / 465));
			//if (A > B) { var tmp:int = A; A = B; B = tmp; }
			bd.lock ();
			for (var i:int = 0; i < routeNum; i++) {
				var route:Vector.<Location> = routes [i];
				var particle:Particle = particles [i];
				if(i != trackingSeed) bd.setPixel32 (route [particle.i].sx, route [particle.i].sy, 0xccFFFFFF);
				else bd.fillRect(new Rectangle(route [particle.i].sx , route [particle.i].sy , 2, 2), 0xffFFFF00);
				particle.i += particle.di;
				if ((particle.i < 0) || (particle.i > route.length - 1)) {
					particle.i -= particle.di; particle.di *= -1;
				}
			}
			bd.unlock (); bd.colorTransform (bd.rect, ct);
			//+ move camera position
			cameraPos.x = easing(cameraPos.x, routes[trackingSeed][particles[trackingSeed].i].sx, 0.2, 465);
			cameraPos.y = easing(cameraPos.y, routes[trackingSeed][particles[trackingSeed].i].sy, 0.2, 465);
			cameraRot = easing(cameraRot, Math.PI * (0.5 - (mouseX - 465 / 2) / 465), 0.05, Math.PI * 2);
			cameraH += (Math.max(580, 580 + mouseY / 465 * 1000) - cameraH) * 0.1;
			pv3d.camera.position = getCameraPosition(cameraPos.x + Math.cos(cameraRot) * -20, cameraPos.y - Math.sin(cameraRot) * -20, cameraH);
			cameraTarget.position = getCameraPosition(cameraPos.x + Math.cos(cameraRot) * 10, cameraPos.y - Math.sin(cameraRot) * 10, 500);
			pv3d.camera.lookAt(cameraTarget, pv3d.camera.position);
		}
		private var cameraPos:Point = new Point();
		private var cameraRot:Number = Math.PI * 1.5;
		private var cameraH:Number = 10000;
		//+ easy easing
		private function easing(value:Number, target:Number, easing:Number, loopLimit:Number):Number {
			var minus:Number = target - value;
			if (Math.abs(minus) > loopLimit / 2) target -= minus / Math.abs(minus) * loopLimit;
			return (value + (target - value) * easing + loopLimit) % loopLimit;
		}
		//+ get camera position on sphere
		private function getCameraPosition(px:Number, py:Number, d:Number):Number3D {
			var toRadian:Number = Math.PI / 180;
			var rotx:Number = px / 465 * 360;
			var roty:Number = 90 - py / 465 * 180;
			var perXZ:Number = Math.cos(roty * toRadian);
			return new Number3D(Math.cos(rotx * toRadian) * d * perXZ, Math.sin(roty * toRadian) * d, Math.sin(rotx * toRadian) * d * perXZ);
		}
	}
}

class Particle {
	public var i:int = 0;
	public var di:int = 1;
}

class Location {
	public var sx:uint, sy:uint; // screen 2D coords
	public var x:Number, y:Number, z:Number; // 3D coords
	public function Location (phi:Number /* -PI...+PI */, tet:Number /* 0...+PI */) {
		sx = 465 * (phi + Math.PI) / (2 * Math.PI);
		sy = 465 * tet / Math.PI;
		// http://en.wikipedia.org/wiki/Spherical_coordinate_system#Cartesian_coordinates
		x = Math.sin (tet) * Math.cos (phi);
		y = Math.sin (tet) * Math.sin (phi);
		z = Math.cos (tet);
	}
	public function slerp (b:Location, t:Number):Location {
		// http://en.wikipedia.org/wiki/Slerp
		var omega:Number = Math.acos (x * b.x + y * b.y + z * b.z);
		var sin_o:Number = Math.sin (omega)
		var c0:Number = Math.sin ((1 - t) * omega) / sin_o;
		var c1:Number = Math.sin (t * omega) / sin_o;
		var cx:Number = c0 * x + c1 * b.x;
		var cy:Number = c0 * y + c1 * b.y;
		var cz:Number = c0 * z + c1 * b.z;
		// http://en.wikipedia.org/wiki/Spherical_coordinate_system#Cartesian_coordinates
		var tet:Number = Math.acos (Math.max ( -1, Math.min ( +1, cz)));
		var phi:Number = Math.atan2 (cy, cx);
		return new Location (phi, tet);
	}
}
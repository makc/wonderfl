package {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
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
		public function Airlines () {
			// load map
			var map:Loader = new Loader; addChild (map);
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
		public function onDataReady (e:Event):void {
			data = Bitmap(LoaderInfo(e.target).content).bitmapData;
			bd = new BitmapData (465, 465, true, 0); addChild (new Bitmap (bd));
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
			routes = new Vector.<Vector.<Location>>(60237, true);
			particles = new Vector.<Particle>(60237, true);
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
				routes [p - 3338] = new Vector.<Location> (N, true);
				particles [p - 3338] = new Particle;
				particles [p - 3338].i = int (Math.random () * (N - 1));
				for (var i:int = 0; i < N; i++)
					routes [p - 3338] [i] = a.slerp (b, i / (N -1));
				p++; if (p - 3338 > 60237 - 1) {
					// launch simulation
					removeEventListener (Event.ENTER_FRAME, unpackRoutes);
					addEventListener (Event.ENTER_FRAME, simulation);
					break;
				}
			}
			// show progress
			var r:Rectangle = new Rectangle (50, 300, 365, 20);
			bd.fillRect (r, 0x7F00FF00); r.width = 365 * p / (3338 + 60237);
			bd.fillRect (r, 0xFF00FF00);
		}
		public function simulation (e:Event):void {
			var A:int = Math.max (0, Math.min (60237, 60237 * mouseX / 465));
			var B:int = Math.max (0, Math.min (60237, 60237 * mouseY / 465));
			if (A > B) { var tmp:int = A; A = B; B = tmp; }
			bd.lock ();
			for (var i:int = A; i < B; i++) {
				var route:Vector.<Location> = routes [i];
				var particle:Particle = particles [i];
				bd.setPixel32 (route [particle.i].sx, route [particle.i].sy, 0xFFFFFFFF);
				particle.i += particle.di;
				if ((particle.i < 0) || (particle.i > route.length - 1)) {
					particle.i -= particle.di; particle.di *= -1;
				}
			}
			bd.unlock (); bd.colorTransform (bd.rect, ct);
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
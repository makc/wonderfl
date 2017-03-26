package {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	/**
	 * Wait for damn thing to load, then click anywhere
	 * to release tee virus.
	 * 
	 * See how soon zombies are knocking at your door :)
	 * 
	 * Brains! Brrraaaains!!!
	 * 
	 * @author makc
	 * @license WTFPLv2, http://sam.zoy.org/wtfpl/
	 */
	public class Outbreak extends Sprite {
		public function Outbreak () {
			// load map
			var map:URLLoader = new URLLoader;
			map.dataFormat = URLLoaderDataFormat.BINARY;
			map.addEventListener (Event.COMPLETE, onMapLoaded);
			map.load (new URLRequest (/*"umbrella.gif"*/
				"http://assets.wonderfl.net/images/related_images/b/b1/b180/b18064b220cc1a257bbd9b8f37f85cdc8e676ac3"
			));
		}
		public function onMapLoaded (e:Event):void {
			var map:URLLoader = URLLoader (e.target);
			var ba0:ByteArray = ByteArray (map.data);
			var ba1:ByteArray = new ByteArray; ba1.writeBytes (ba0, 0, 5945);
			var ba2:ByteArray = new ByteArray; ba2.writeBytes (ba0, 5945);
			var bkg:Loader = new Loader;
			bkg.contentLoaderInfo.addEventListener (Event.COMPLETE, onBackgroundReady);
			addChild (bkg); bkg.loadBytes (ba1);
			var mp3:Loader = new Loader;
			addChild (mp3); mp3.loadBytes (ba2);

			// load data
			var data:Loader = new Loader;
			data.contentLoaderInfo.addEventListener (Event.COMPLETE, onDataReady);
			data.load (new URLRequest (/*"airlines.png"*/
				"http://assets.wonderfl.net/images/related_images/9/99/9991/99916b6cd6bc516fdaa9247f809b2bde80fea5f5"
			), new LoaderContext (true));
		}
		public var worldMap:BitmapData, red:BitmapData;
		public function onBackgroundReady (e:Event):void {
			var info:LoaderInfo = LoaderInfo (e.target);
			var bkg:BitmapData = Bitmap (info.content).bitmapData;
			// create mask for draw/multiply
			worldMap = new BitmapData (465, 465, true, 0);
			worldMap.threshold (bkg, bkg.rect, bkg.rect.topLeft, "==", 0xFF000000, 0xFFFFFFFF);
		}
		public var p:int = 0, color:uint;
		public var airports:Vector.<Location>;
		public var airportsInfected:Vector.<Boolean>;
		public var airportsRoutes:Vector.<Vector.<int>>;
		public var data:BitmapData, bd:BitmapData;
		public var ct:ColorTransform, ctr:ColorTransform;
		public var bf:BlurFilter;
		public var routes:Vector.<Vector.<Location>>;
		public var particles:Vector.<Particle>;
		public function onDataReady (e:Event):void {
			data = Bitmap(LoaderInfo(e.target).content).bitmapData;
			red = new BitmapData (465, 465, true, 0); addChild (new Bitmap (red));
			bd = new BitmapData (465, 465, true, 0); addChild (new Bitmap (bd));
			ct = new ColorTransform (1.0, 0.7, 0.7, 0.9);
			ctr = new ColorTransform (1.1);
			bf = new BlurFilter (1.1, 1.1, 1);
			// unpack airports data
			airports = new Vector.<Location>(3338, true);
			airportsInfected = new Vector.<Boolean>(3338, true);
			airportsRoutes = new Vector.<Vector.<int>>(3338, true);
			while (p < 3338) {
				color = data.getPixel (p % 252, p / 252);
				airports [p] = new Location (
					(2 * (color & 4095) / 4095.0 - 1) * Math.PI,
					(1 - ((color >> 12) & 4095) / 4095.0) * Math.PI
				);
				airportsRoutes [p] = new Vector.<int>();
				p++;
			}
			// unpack routes data
			// this takes some time, we have to async it...
			routes = new Vector.<Vector.<Location>>(60237, true);
			particles = new Vector.<Particle>();
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
				// tie routes to airports
				airportsRoutes [(color >> 12) & 4095].push (p - 3338);
				airportsRoutes [(color) & 4095].push (p - 3338);
				for (var i:int = 0; i < N; i++)
					routes [p - 3338] [i] = a.slerp (b, i / (N -1));
				p++; if (p - 3338 > 60237 - 1) {
					// launch simulation
					removeEventListener (Event.ENTER_FRAME, unpackRoutes);
					addEventListener (Event.ENTER_FRAME, simulation);
					stage.addEventListener (MouseEvent.CLICK, onClick);
					break;
				}
			}
			// show progress
			var r:Rectangle = new Rectangle (50, 300, 365, 20);
			bd.fillRect (r, 0x7FFF0000); r.width = 365 * p / (3338 + 60237);
			bd.fillRect (r, 0xFFFF0000);
		}
		public function simulation (e:Event):void {
			if (worldMap != null) {
				red.applyFilter (red, red.rect, red.rect.topLeft, bf);
				red.colorTransform (red.rect, ctr);
				red.copyChannel (worldMap, worldMap.rect, worldMap.rect.topLeft, 8, 8);
			}

			// check if airports are infected
			for (p = 0; p < airports.length; p++) {
				if (!airportsInfected [p])
				if (red.getPixel32 (airports [p].sx, airports [p].sy) == 0xFFFF0000) {
					airportsInfected [p] = true;
					// find all routes for this airport
					for (var j:int = 0; j < airportsRoutes [p].length; j++) {
						// create a particle
						var plane:Particle = new Particle;
						plane.r = airportsRoutes [p] [j];
						var loc_0:Location = routes [plane.r] [0];
						// slerp bug??
						if (Math.abs(loc_0.sx - airports [p].sx) + Math.abs(loc_0.sy - airports [p].sy) > 6) {
							plane.i = routes [plane.r].length - 1; plane.di = -1;
						}
						particles.push (plane);
					}
				}
			}

			bd.lock ();
			for (var i:int = 0; i < particles.length; i++) {
				var particle:Particle = particles [i];
				var route:Vector.<Location> = routes [particle.r];
				bd.setPixel32 (route [particle.i].sx, route [particle.i].sy, 0xFFFFFFFF);
				particle.i += particle.di;
				if ((particle.i < 0) || (particle.i > route.length - 1)) {
					// outbreak at destination
					particle.i -= particle.di;
					red.setPixel32 (route [particle.i].sx, route [particle.i].sy, 0xFFFF0000);
					// this flight has served its purpose
					particles.splice (i, 1); i--;
				}
			}
			bd.unlock (); bd.colorTransform (bd.rect, ct);
		}
		public function onClick (e:MouseEvent):void {
			if ((mouseY < 390 /* spare penguins */) && (worldMap != null)) {
				// outbreak at this location
				red.setPixel32 (mouseX, mouseY, 0xFFFF0000);
			}
		}
	}
}

class Particle {
	public var r:int = 0;
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
package {
	import com.bit101.components.PushButton;
	import com.bit101.components.TextArea;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.DisplacementMapFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	/**
	 * Curved text using DisplacementMapFilter
	 * Port of AS2 app made for Alan Zhao years ago
	 * 7px fonts are not really good for this, but duh
	 * @see http://makc.coverthesky.com/FlashFX/ffx.php?id=7
	 * @license WTFPLv2
	 * @author makc
	 */
	[SWF(width=465,height=465)]
	public class CurvedText extends Sprite {
		public function CurvedText () {
			stage.scaleMode = "noScale";
			ta = new TextArea (this, 0, 0, li); ta.setSize (465, 300);
			for (var i:int = -1; i < maps.length; i++)
				with (new PushButton (this, 25 * (i + 2), 430, (i + 1).toString (), onButtonClick)) width = height;
		}

		private var ta:TextArea;
		private var li:String =
			"Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.\n\n" +
			"Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.\n\n" +
			"Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.\n\n" +
			"Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.\n\n" +
			"Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.\n\n";

		private function onButtonClick (e:Event):void {
			var map:BitmapData = BitmapData (maps [parseInt (PushButton (e.target).label) - 1]);
			applyEffect (ta.textField, ta.textField.width, ta.textField.height, map);
		}

		private function applyEffect (clip:DisplayObject, w:Number, h:Number, map:BitmapData):void {
			// if there ever will be need in zoom, pass it
			var zoom:Number = 1;

			// if there is a filter already, remove it
			clip.filters = [];

			// if empty map supplied, resize clip to original size and do nothing else
			clip.scaleX = clip.scaleY = 1; if (map == null) return;

			// scale basic map up to required dimensions
			// (for some reason flash puts textbox border outside of rectangle, so we make larger map)
			var k:Number = 0.05 / zoom;
			var w1:Number = (1 + k) * w, x1:Number = -0.5 * k * w;
			var h1:Number = (1 + k) * h, y1:Number = -0.5 * k * h;
			var dst:BitmapData = new BitmapData (w1, h1, true);
			var m1:Matrix = new Matrix;
			m1.scale (w1 / map.width, h1 / map.height); m1.translate (x1, y1);
			dst.draw (map, m1, null, null, null, true);

			// make the filter out of dst and attach it to clip
			clip.filters = [new DisplacementMapFilter (dst, new Point, 4, 2, 256 * m1.a, 256 * m1.d, "clamp")];

			// resize clip to specified dimensions
			clip.scaleX = 1 / zoom * w / clip.width;
			clip.scaleY = 1 / zoom * h / clip.height;
		}

		private var maps:Array = [
			getArcMap (true), getArcMap (false),
			getBridgeOrValleyMap (true), getBridgeOrValleyMap (false),
			getBulgeMap (), getPinchMap (),
			getCurveMap (true), getCurveMap (false),
			getRoofMap (true), getRoofMap (false),
			getWedgeOrWidenMap (false), getWedgeOrWidenMap (true)
		];

		// base 512x256 maps --8<-----------------------------------
		private function getArcMap (up:Boolean):BitmapData {
			var rm:int = 65536, gm:int = 256, bm:int = 1;
			var b:BitmapData = new BitmapData (512, 256, true), w:int = b.width, h:int = b.height;
			// place curve center K (>1) times h below bitmap
			var K:Number = 1.65, xK:Number = w/2, yK:Number = K * h;
			// find upper intersection of bitmap rectanle with curve
			var B:Number = Math.sqrt (yK*yK - xK*xK);
			var yT:Number = yK - B;
			//
			for (var x:int = 0; x < w; x++)
			for (var y:int = 0; y < h; y++) {
				// dy from dx
				var dx:Number = xK - x, dy:Number = yK - Math.sqrt (yK*yK - dx*dx);
				// map to source rectangle
				var xS:int = x;
				var yS:int = Math.floor(h * (y - dy) / (h - yT)); if (yS < 0) yS = 0; if (yS > h-1) yS = h-1;
				// make color
				var c:uint = bm * (128 + xS - x) + gm * (128 + yS - y);
				// quick hack to support both directions
				b.setPixel (x, up ? y : h - 1 - y, up ? c : rm - 1 - c);
			}
			return b;
		}
		private function getBridgeOrValleyMap (valley:Boolean):BitmapData {
			var rm:int = 65536, gm:int = 256, bm:int = 1;
			var b:BitmapData = new BitmapData (512, 256, true), w:int = b.width, h:int = b.height;
			// place curve center K (>1) times h below bitmap
			var K:Number = 1.65, xK:Number = w/2, yK:Number = K * h;
			// find upper intersection of bitmap rectanle with curve
			var B:Number = Math.sqrt (yK*yK - xK*xK);
			var yT:Number = yK - B;
			//
			for (var x:int = 0; x < w; x++)
			for (var y:int = 0; y < h; y++) {
				// dy from dx
				var dx:Number = xK - x, dy:Number = yK - Math.sqrt (yK*yK - dx*dx);
				// map to source rectangle
				var xS:int = x;
				var yS:int = Math.floor(h * (y - dy) / (h - dy)); if (yS < 0) yS = 0; if (yS > h-1) yS = h-1;
				// make color
				var c:uint = bm * (128 + xS - x) + gm * (128 + yS - y);
				// quick hack to support both directions
				b.setPixel (x, valley ? y : h - 1 - y, valley ? c : rm - 1 - c);
			}
			return b;
		}
		private function getBulgeMap ():BitmapData {
			var rm:int = 65536, gm:int = 256, bm:int = 1;
			var b:BitmapData = new BitmapData (512, 256, true), w:int = b.width, h:int = b.height;
			// place curve center K (>1) times h below bitmap
			var K:Number = 1.65, xK:Number = w/2, yK:Number = K * h;
			// find upper intersection of bitmap rectanle with curve
			var M:Number = 0.8;
			var B:Number = Math.sqrt (yK*yK - xK*xK);
			var yT:Number = M * (yK - B);
			//
			for (var x:int = 0; x < w; x++)
			for (var y:int = 0; y < h; y++) {
				// dy from dx
				var dx:Number = xK - x, dy:Number = M * (yK - Math.sqrt (yK*yK - dx*dx));
				// map to source rectangle
				var xS:int = x;
				var yS:int = Math.floor(h * (y - dy) / (h - 2*dy)); if (yS < 0) yS = 0; if (yS > h-1) yS = h-1;
				// make color
				b.setPixel (x, y, bm * (128 + xS - x) + gm * (128 + yS - y));
			}
			return b;
		}
		private function getPinchMap ():BitmapData {
			var rm:int = 65536, gm:int = 256, bm:int = 1;
			var b:BitmapData = new BitmapData (512, 256, true), w:int = b.width, h:int = b.height;
			// place curve center K (>1) times h below bitmap
			var K:Number = 1.65, xK:Number = w/2, yK:Number = K * h;
			// find upper intersection of bitmap rectanle with curve
			var M:Number = 0.8;
			var B:Number = Math.sqrt (yK*yK - xK*xK);
			var yT:Number = M * (yK - B);
			//
			for (var x:int = 0; x < w; x++)
			for (var y:int = 0; y < h; y++) {
				// dy from dx
				var dx:Number = xK - x, dy:Number = M * ( yT/M - (yK - Math.sqrt (yK*yK - dx*dx)) );
				// map to source rectangle
				var xS:int = x;
				var yS:int = Math.floor(h * (y - dy) / (h - 2*dy)); if (yS < 0) yS = 0; if (yS > h-1) yS = h-1;
				// make color
				b.setPixel (x, y, bm * (128 + xS - x) + gm * (128 + yS - y));
			}
			return b;
		}
		private function getCurveMap (up:Boolean):BitmapData {
			var rm:int = 65536, gm:int = 256, bm:int = 1;
			var b:BitmapData = new BitmapData (512, 256, true), w:int = b.width, h:int = b.height;
			// place curve center K (>1) times h below bitmap
			var K:Number = 1.65, xK:Number = w/2, yK:Number = K * h;
			// find upper intersection of bitmap rectanle with curve
			var A:Number = Math.sqrt (yK*yK - xK*xK), aK:Number = Math.asin (xK / yK);
			// find distance to bottom intersection
			var rK:Number = yK * (yK - h) / A;
			//
			for (var x:int = 0; x < w; x++)
			for (var y:int = 0; y < h; y++) {
				// angle and distance for (x, y)
				var d:Number = Math.sqrt ((x - xK)*(x - xK) + (y - yK)*(y - yK));
				var a:Number = Math.asin ((x - xK) / d);
				// ratios to curve params
				var rd:Number = (d - rK) / (yK - rK), ra:Number = a / aK;
				rd = (rd > 1) ? 1 : ((rd < 0) ? 0 : rd);
				ra = (ra > 1) ? 1 : ((ra < -1) ? -1 : ra);
				// map to source rectangle
				var xS:int = Math.round (xK * (1 + ra));
				var yS:int = Math.round (h * (1 - rd));
				// make color
				var c:uint = bm * (128 + xS - x) + gm * (128 + yS - y);
				// quick hack to support both directions
				b.setPixel (up ? x : w - 1 - x, up ? y : h - 1 - y, up ? c : rm - 1 - c);
			}
			return b;
		}
		private function getRoofMap (up:Boolean):BitmapData {
			var rm:int = 65536, gm:int = 256, bm:int = 1;
			var b:BitmapData = new BitmapData (512, 256, true), w:int = b.width, h:int = b.height;
			//
			for (var x:int = 0; x < w; x++)
			for (var y:int = 0; y < h; y++) {
				// roof height
				var H:Number;
				if (x < 256)
					H = 128 + 128 * x / (0.5*w);
				else
					H = 128 + 128 * (512 - x) / (0.5*w);
				// ratio
				var r:Number = (h - y) / H;
				// map to source rectangle
				var xS:int = x;
				var yS:int = 255 - Math.floor (r * h); if (yS < 0) yS = 0;
				// make color
				var c:uint = bm * (128 + xS - x) + gm * (128 + yS - y);
				// quick hack to support both directions
				b.setPixel (x, up ? y : h - 1 - y, up ? c : rm - 1 - c);
			}
			return b;
		}
		private function getWedgeOrWidenMap (wedge:Boolean):BitmapData {
			var rm:int = 65536, gm:int = 256, bm:int = 1;
			var b:BitmapData = new BitmapData (512, 256, true), w:int = b.width, h:int = b.height;
			//
			for (var x:int = 0; x < w; x++)
			for (var y:int = 0; y < h; y++) {
				// wedge half-height
				var H:Number = 128 - 256 * x / w / 3;
				// ratio
				var r:Number = (y - h/2) / H;
				// map to source rectangle
				var xS:int = x;
				var yS:int = 128 + Math.floor (r * h/2); if (yS < 0) yS = 0; if (yS > h-1) yS = h-1;
				// make color
				var c:uint = bm * (128 + xS - x) + gm * (128 + yS - y);
				// quick hack to support both directions
				b.setPixel (wedge ? x : w - 1 - x, y, c);
			}
			return b;
		}
	}
}
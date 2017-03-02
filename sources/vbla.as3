package {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	
	/**
	 * Another drawTriangles based homography test
	 * @see http://twitter.com/makc3d/status/27978300665
	 */
	public class HTest extends Sprite {
		public function HTest () {
			var loader:Loader = new Loader;
			loader.contentLoaderInfo.addEventListener (Event.COMPLETE, onComplete);
			loader.load (new URLRequest (/*"basilica.jpg"*/"http://assets.wonderfl.net/images/related_images/c/cd/cd42/cd420f334c70f5c985e48cdecfef9f047fd250b4"), new LoaderContext (true));
		}
		public var image:BitmapData;
		public var anchors:Vector.<Anchor>;
		public var homography:Homography;
		public function onComplete (e:Event):void {
			var info:LoaderInfo = LoaderInfo (e.target);
			info.removeEventListener (Event.COMPLETE, onComplete);
			addChild (info.content);
			image = Bitmap (info.content).bitmapData;
			anchors = new Vector.<Anchor> (4, true);
			addChild (anchors [0] = new Anchor (100, 257));
			addChild (anchors [1] = new Anchor (122, 218));
			addChild (anchors [2] = new Anchor (131, 251));
			addChild (anchors [3] = new Anchor (111, 296));
			addChild (homography = new Homography);
			homography.x = homography.y = 350;
			homography.filters = [ new GlowFilter (0xFF7F00, 1, 2, 2, 200, 2) ];
			stage.addEventListener (MouseEvent.MOUSE_MOVE, onMouseMove);
			onMouseMove (null);
		}
		public function onMouseMove (e:MouseEvent):void {
			if ((e == null) || e.buttonDown) {
				homography.setTransform (image,
					new Point (anchors [0].x, anchors [0].y),
					new Point (anchors [1].x, anchors [1].y),
					new Point (anchors [2].x, anchors [2].y),
					new Point (anchors [3].x, anchors [3].y)
				);
			}
		}
	}
}

import flash.display.Sprite;
import flash.events.MouseEvent;
class Anchor extends Sprite {
	public function Anchor (x0:int, y0:int) {
		x = x0; y = y0;
		graphics.beginFill (0xFF7F00, 1);
		graphics.drawRect (-4, -4, 8, 8);
		graphics.drawRect (-2, -2, 4, 4);
		graphics.beginFill (0xFF7F00, 0);
		graphics.drawRect (-2, -2, 4, 4);
		useHandCursor = buttonMode = true;
		addEventListener (MouseEvent.MOUSE_DOWN, startDragMe);
		addEventListener (MouseEvent.MOUSE_UP, stopDragMe);
	}
	public function startDragMe (e:MouseEvent):void {
		startDrag ();
	}
	public function stopDragMe (e:MouseEvent):void {
		stopDrag ();
	}
}

/**
 * @author zeh, original idea
 * @author makc, inverted transform
 * @see http://zehfernando.com/2010/the-best-drawplane-distortimage-method-ever/
 */
import flash.display.BitmapData;
import flash.display.Graphics;
import flash.display.Shape;
import flash.geom.Point;
class Homography extends Shape {
	private var v6:Vector.<int> = Vector.<int> ([0, 1, 2, 0, 2, 3]);
	private var v8:Vector.<Number> = new Vector.<Number> (8, true);
	private var v12:Vector.<Number> = new Vector.<Number> (12, true);

	public function setTransform (src:BitmapData,
		p0:Point, p1:Point, p2:Point, p3:Point,
		destWidth:int = 100, destHeight:int = 100):void {

		// Find diagonals intersection point
		var pc:Point = new Point;

		var a1:Number = p2.y - p0.y;
		var b1:Number = p0.x - p2.x;
		var a2:Number = p3.y - p1.y;
		var b2:Number = p1.x - p3.x;

		var denom:Number = a1 * b2 - a2 * b1;
		if (denom == 0) {
			// something is better than nothing
			pc.x = 0.25 * (p0.x + p1.x + p2.x + p3.x);
			pc.y = 0.25 * (p0.y + p1.y + p2.y + p3.y);
		} else {
			var c1:Number = p2.x * p0.y - p0.x * p2.y;
			var c2:Number = p3.x * p1.y - p1.x * p3.y;
			pc.x = (b1 * c2 - b2 * c1) / denom;
			pc.y = (a2 * c1 - a1 * c2) / denom;
		}

		// Lengths of first diagonal
		var ll1:Number = Point.distance(p0, pc);
		var ll2:Number = Point.distance(pc, p2);

		// Lengths of second diagonal
		var lr1:Number = Point.distance(p1, pc);
		var lr2:Number = Point.distance(pc, p3);

		// Ratio between diagonals
		var f:Number = (ll1 + ll2) / (lr1 + lr2);

		var sw:Number = src.width, sh:Number = src.height;
		var dw:Number = destWidth, dh:Number = destHeight;

		v8 [2] = dw; v8 [4] = dw; v8 [5] = dh; v8 [7] = dh;

		v12 [0] = p0.x / sw; v12 [ 1] = p0.y / sh; v12 [ 2] = ll2 / f;
		v12 [3] = p1.x / sw; v12 [ 4] = p1.y / sh; v12 [ 5] = lr2;
		v12 [6] = p2.x / sw; v12 [ 7] = p2.y / sh; v12 [ 8] = ll1 / f;
		v12 [9] = p3.x / sw; v12 [10] = p3.y / sh; v12 [11] = lr1;

		graphics.clear ();
		graphics.beginBitmapFill (src, null, false, true);
		graphics.drawTriangles (v8, v6, v12);
	}
}
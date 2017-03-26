// forked from makc3d's Metaballs 3D
// Eyeball cropped from http://www.flickr.com/photos/36386430@N00/2955060788/ (pic by lorenzo romagnoli)
package {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.utils.*;
	import flash.filters.*;
	import org.libspark.betweenas3.*;
	import org.libspark.betweenas3.tweens.*;
	import org.libspark.betweenas3.easing.*;
//	import net.hires.debug.Stats;
	[SWF(width=465,height=465)]
	/**
	 * Hope you like balls. Black balls. Shiny black balls.
	 * @author makc
	 */
	public class MetaBalls3D extends Sprite {
		private var texture:BitmapData;
		private var sphere:BauerSphere;
		private var metaballs:MetaBalls;
		private var canvas:Shape;
		private var eyelid:Shape = new Shape;
		private var eyeball:Sprite = new Sprite;

		public function MetaBalls3D () {
			graphics.beginFill (0);
			graphics.drawRect (0, 0, 465, 465);

			addChild (canvas = new Shape);
			canvas.x = 465 / 2;
			canvas.y = 465 / 2;

			texture = new BitmapData(1,1);
			var loader:Loader = new Loader;
			loader.contentLoaderInfo.addEventListener (Event.COMPLETE, gotImage);
			loader.load (
				new URLRequest ("http://assets.wonderfl.net/images/related_images/8/8b/8ba8/8ba8845aba0f65467887ff35c4d0f6fb022ddd6fm"),
				new LoaderContext (true)
			);

			sphere = new BauerSphere;
			sphere.debug = false;
			sphere.build ();

			metaballs = new MetaBalls;

			addEventListener (Event.ENTER_FRAME, draw);
			//addChild(new Stats);
		}

		private function gotImage (e:Event):void {
			//texture.draw (LoaderInfo (e.target).content);
			var bmp:Bitmap = e.target.content;
			texture = bmp.bitmapData.clone();
			eyeball.addChild(bmp);
			eyeball.addChild(eyelid);
			eyelid.scaleY = 0;
			eyelid.graphics.beginFill(0);
			eyelid.graphics.drawEllipse(0,0,bmp.width,bmp.height);
			eyelid.graphics.endFill();
			eyelid.graphics.beginFill(0);
			eyelid.graphics.drawRect(0,-20,bmp.width,bmp.height/2+20);
			eyelid.graphics.endFill();
			eyelid.filters = [new BlurFilter(0, 15, 2)];
			blink();
		}

		private function blink(_:* = null):void {
			var close:ITween = BetweenAS3.tween(eyelid, {scaleY: 1}, null, 0.075);
			var open:ITween  = BetweenAS3.delay(BetweenAS3.tween(eyelid, {scaleY: 0}, null, 0.075), 0.1);
			BetweenAS3.serial(close, open).play();
			if(Math.random()<0.3) {
				setTimeout(blink, 100 + Math.random() * 200);
			} else {
				setTimeout(blink, Math.random() * 5000);
			}
		}

		private var m:Matrix4 = new Matrix4;
		private function draw (e:Event):void {
			// update texture
			texture.fillRect(texture.rect, 0);
			texture.draw(eyeball);

			// swing balls
			metaballs.a = 1 + Math.sin (0.00105 * getTimer ());

			// rotate scene
			m.rotate (0.00165 * getTimer ());

			var ranges:Vector.<Range> = metaballs.ranges ();
			if (ranges.length > 1) {
				// render sphere twice
				if (m.Zz < 0) {
					morphSphere (ranges [0]);

					sphere.transformVertices (m);
					sphere.render (canvas.graphics, texture);

					morphSphere (ranges [1]);

					sphere.transformVertices (m);
					sphere.render (canvas.graphics, texture, false);
				} else {
					morphSphere (ranges [1]);

					sphere.transformVertices (m);
					sphere.render (canvas.graphics, texture);

					morphSphere (ranges [0]);

					sphere.transformVertices (m);
					sphere.render (canvas.graphics, texture, false);
				}
			} else {
				// render sphere once
				morphSphere (ranges [0]);

				sphere.transformVertices (m);
				sphere.render (canvas.graphics, texture);
			}
		}

		private var p:Point = new Point, q:Vector3D = new Vector3D;
		private function morphSphere (range:Range):void {

			var aa:Number = (metaballs.a - 4 / 3) / 0.3;
			var cc:Number = 1.6 / (1 + aa * aa) - 0.8; // 0 to 0.8 to 0 when aa is -1 to 0 to +1

			sphere.resetVertices ();
			var i:int, L:int = sphere.tvertices.length;
			for (i = 0; i < L; i++) {
				var v:Vector3D = sphere.tvertices [i];
				p.x = v.x; p.y = v.y;
				var vz:Number = v.z;
				if (cc > 0) {
					// to get better triangulation near a = 4/3 map z to 0.2*z*|z| + 0.8*z
					if (vz < 0) {
						vz = (1 - cc) * vz - cc * vz * vz;
					} else {
						vz = (1 - cc) * vz + cc * vz * vz;
					}
				}
				var t:Number = 0.5 + 0.5 * vz;
				// shape as metaball
				v.z = range.x (t);
				p.normalize (metaballs.y (v.z));
				v.x = p.x; v.y = p.y;
				// metaball normal
				p.normalize (1);
				q = sphere.normals [i];
				q.x = p.x; q.y = p.y; q.z = -metaballs.y1 ();
				q.normalize ();
				// you could add scaled q to v here, like in
				// http://img851.imageshack.us/img851/5895/unledwhm.png
				// sphere.normals[i] = q;
			}
		}
	}
}

import flash.display.BitmapData;
import flash.display.Graphics;
import flash.display.TriangleCulling;
import flash.geom.Vector3D;

class Matrix4 {
	public var Xx:Number = 1, Yx:Number = 0, Zx:Number = 0, Tx:Number = 0;
	public var Xy:Number = 0, Yy:Number = 1, Zy:Number = 0, Ty:Number = 0;
	public var Xz:Number = 0, Yz:Number = 0, Zz:Number = 1, Tz:Number = 5;

	public function rotate (a:Number):void {
		Xx =  Math.cos (a); Xz = Math.sin (a);
		Zx = -Math.sin (a); Zz = Math.cos (a);
	}
}

class BauerSphere {
	public var debug:Boolean;

	// original
	public var overtices:Vector.<Vector3D>;
	// transformed
	public var tvertices:Vector.<Vector3D>;
	// vertex normals
	public var normals:Vector.<Vector3D>;

	// face map
	public var faceMap:Vector.<Vector.<int>>;

	// faces
	public var faceList1:Vector.<int>;
	public var faceList2:Vector.<int>;
	public var xy:Vector.<Number>;
	public var uv:Vector.<Number>;

	public function addFace (a:int, b:int, c:int):void {
		var L:int = faceList1.length/3;
		faceMap [a].push (L);
		faceMap [b].push (L);
		faceMap [c].push (L);
		faceList1.push (a, b, c);
		faceList2.unshift (c, a, b);
	}

	public function build (N:int = 500):void {
		overtices = new Vector.<Vector3D> (N, true);
		tvertices = new Vector.<Vector3D> (N, true);
		normals = new Vector.<Vector3D> (N, true);

		faceMap = new <Vector.<int>> [];

		faceList1 = new <int> [];
		faceList2 = new <int> [];
		xy = new Vector.<Number> (2 * N, true);
		uv = new Vector.<Number> (2 * N, true);

		// uniformly distributed directions:
		// Bauer, Robert, "Distribution of Points on a Sphere with Application to Star Catalogs",
		// Journal of Guidance, Control, and Dynamics, January-February 2000, vol.23 no.1 (130-137).
		var radius:Number = 1;
		for (var i:int = 1; i <= N; i++) {
			var phi:Number = Math.acos ( -1 + (2 * i -1) / N);
			var theta:Number = Math.sqrt (N * Math.PI) * phi;

			var rxy:Number = radius * Math.sin (phi);
			overtices [i - 1] = new Vector3D ( -rxy * Math.sin (theta), rxy * Math.cos (theta), radius * Math.cos (phi) );

			tvertices [i - 1] = overtices [i - 1].clone ();
			faceMap [i - 1] = new <int> [];

			normals [i - 1] = new Vector3D;
		}

		// make faces (and edges), 1st and last by hand
		addFace (0, 1, 2);

		var lastEdgeA:int = 0;
		var lastEdgeB:int = 2;

		while ((lastEdgeB < N - 1) || (lastEdgeA < N - 3)) {
			var vA:Vector3D = tvertices [lastEdgeA];
			var vB:Vector3D = tvertices [lastEdgeB];
			var vA1:Vector3D = tvertices [lastEdgeA + 1];
			var vB1:Vector3D; if (lastEdgeB < N - 1) vB1 = tvertices [lastEdgeB + 1];

			var canIncA:Boolean = (lastEdgeA < lastEdgeB - 2) &&
				(lastEdgeA < N - 3) &&
				// only if B-A-A1 angle < 90В°
				(vB.subtract (vA).dotProduct (vA1.subtract (vA)) > 0);

			var canIncB:Boolean = (vB1 != null) &&
				(lastEdgeB < N - 1) && 
				// only if B1-B-A angle < 90В°
				(vB1.subtract (vB).dotProduct (vA.subtract (vB)) > 0);

			if (!(canIncA || canIncB)) break;

			if (  canIncA && canIncB ) {
				// prefer shortest edge
				canIncA = (
					vB1.subtract (vA).lengthSquared > vA1.subtract (vB).lengthSquared
				);
			}

			if (canIncA) {
				// add face A-B-A1
				addFace (lastEdgeA, lastEdgeB, lastEdgeA + 1);

				// inc A
				lastEdgeA++;
			} else {
				// add face A-B-B1
				addFace (lastEdgeA, lastEdgeB, lastEdgeB + 1);

				// inc B
				lastEdgeB++;
			}
		}

		// last face
		addFace (N - 1, N - 2, N - 3);

		if (debug) trace ("Sphere stats:", tvertices.length, "vertices");
	}

	public function resetVertices ():void {
		var N:int = overtices.length;
		for (var i:int = 0; i < N; i++) {
			var t:Vector3D = tvertices [i];
			var o:Vector3D = overtices [i];
			t.x = o.x;
			t.y = o.y;
			t.z = o.z;
		}
	}

	public function transformVertices (m:Matrix4):void {
		var N:int = overtices.length;
		for (var i:int = 0; i < N; i++) {
			var t:Vector3D = tvertices [i];
			var x:Number = t.x;
			var y:Number = t.y;
			var z:Number = t.z;
			t.x = m.Xx * x + m.Yx * y + m.Zx * z + m.Tx;
			t.y = m.Xy * x + m.Yy * y + m.Zy * z + m.Ty;
			t.z = m.Xz * x + m.Yz * y + m.Zz * z + m.Tz;

			// normals
			t = normals [i]
			x = t.x;
			y = t.y;
			z = t.z;
			t.x = m.Xx * x + m.Yx * y + m.Zx * z;
			t.y = m.Xy * x + m.Yy * y + m.Zy * z;
			t.z = m.Xz * x + m.Yz * y + m.Zz * z;
		}
	}

	public var normal:Vector3D = new Vector3D;
	public function render (gfx:Graphics, bd:BitmapData, clear:Boolean = true):void {
		var focalLength:Number = 400;
		var N:int = tvertices.length;
		for (var i:int = 0; i < N; i++) {
			var j:int = 2 * i;
			var t:Vector3D = tvertices [i];

			// project
			var zoom:Number = focalLength / t.z;
			xy [j]     = t.x * zoom;
			xy [j + 1] = t.y * zoom;

			normal = normals[i];

			// env. mapping
			uv [j]     = 0.5 + 0.5 * normal.x;
			uv [j + 1] = 0.5 + 0.5 * normal.y;
		}

		if (clear) gfx.clear ();
		if (debug) gfx.lineStyle (0, 0xFF0000);
		gfx.beginBitmapFill (bd, null, true, true);
		gfx.drawTriangles (xy,
			// half-assed distance sorting
			(tvertices[1].z > tvertices[tvertices.length - 2].z) ? faceList1 : faceList2,
		uv, TriangleCulling.POSITIVE);
	}
}

class Range {
	public var a:Number;
	public var b:Number;
	public function Range (from:Number = 0, to:Number = 0) {
		a = from; b = to;
	}
	public function x (t:Number):Number {
		return a + (b - a) * t;
	}
}

/**
 * Metaballs calculator.
 * @see http://wonderfl.net/c/1TYy/read
 */
class MetaBalls {
	private var a1:Number, a2:Number, b2:Number;
	private var d1:Number, d2:Number;

	public function get a ():Number {
		return a1;
	}
	public function set a (A:Number):void {
		a1 = A;
		a2 = A * A;
		b2 = 1 + (A + a2) / 4; b2 *= b2;
		d1 = 3 * a2 - A - 4;
		d2 = 5 * a2 + A + 4;
	}

	private var x1:Number, x2:Number;
	private var s1:Number, s2:Number;

	public function y (x:Number):Number {
		x1 = x;
		x2 = x * x;
		s1 = Math.sqrt (Math.max (0, 4 * a2 * x2 + b2));
		s2 = Math.sqrt (Math.max (0, s1 - a2 - x2));
		return s2;
	}

	/** 1st derivative, dy/dx. y(x) is expected to be called 1st. */
	public function y1 ():Number {
		return (2 * a2 * x1 / s1 - x1) / s2;
	}

	private var r1:Vector.<Range> = new <Range> [ new Range ];
	private var r2:Vector.<Range> = new <Range> [ new Range, new Range ];

	public function ranges ():Vector.<Range> {
		var S2:Number = 0.5 * Math.sqrt (d2);
		if (d1 > 0) {
			var S1:Number = 0.5 * Math.sqrt (d1);
			r2 [0].a = -S2; r2 [0].b = -S1;
			r2 [1].a =  S1; r2 [1].b =  S2;
			return r2;
		}
		r1 [0].a = -S2; r1 [0].b = S2;
		return r1;
	}
}
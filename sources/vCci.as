package  {
	import alternativ5.engine3d.core.*;
	import alternativ5.engine3d.display.*;
	import alternativ5.engine3d.materials.*;
	import alternativ5.engine3d.primitives.*;
	import alternativ5.utils.*;
	import flash.display.*;
	import flash.events.*;
	import flash.filters.*;
	import flash.geom.*;
	
	/**
	 * Stereogram via DisplacementMapFilter.
	 * @author Vladimir Babushkin, 2D code
	 * @author makc, added 3D via ZShaderMaterial
	 * @see http://forum.alternativaplatform.com/posts/list/478.page#2513
	 */
	[SWF(width="465",height="465",frameRate="60")]
	public class Stereogram extends Sprite {
		private var delta:Number;
		private var _width:Number;
		private var _height:Number;
		private var counter:Number;
		private var repeat:Boolean;
		private var point:Point;
		private var rectangle:Rectangle;
		private var matrix:Matrix;
		private var map:BitmapData;
		private var stereo:BitmapData;
		private var stereoTemp:BitmapData;
		private var stereoView:Bitmap;
		private var part:BitmapData;
		private var displace:DisplacementMapFilter;
		private var box:Box;
		private var scene:Scene3D;
		private var view:View;
		private var dummy:Object3D;
		private var r0:Rectangle;
		private var c0:ColorTransform;

		public function Stereogram () {
			stage.align = "CM";
			stage.quality = "low";
			stage.scaleMode = "noScale";
			delta = 100;
			_width = 465 + delta;
			_height = 465;
			counter = 1;
			repeat = true;
			point = new Point;
			rectangle = new Rectangle(Math.round(-delta/2), 0, _width, _height);
			matrix = new Matrix(1, 0, 0, 1, -delta, 0);
			map = new BitmapData(_width, _height, false, 0xff808080);
			stereo = new BitmapData(_width, _height, false, 0);
			stereoTemp = stereo.clone();
			stereoView = new Bitmap (stereo);
			part = new BitmapData(delta, _height, false, 0);
			displace = new DisplacementMapFilter(map, point, 1, 0, 0.8 * delta);
			box = new Box (200, 200, 200);
			box.cloneMaterialToAllSurfaces (new ZShaderMaterial);
			scene = new Scene3D; scene.root = new Object3D; scene.root.addChild (box);
			view = new View; view.camera = new Camera3D;
			dummy = new Object3D; dummy.addChild (view.camera); scene.root.addChild (dummy);
			view.width = _width; view.height = _height; addChild (view); addChild (stereoView);
			FPS.init (this);
			box.rotationX = box.rotationZ = 1; view.camera.z = -500;
			r0 = new Rectangle (0, 400, 10, 10);
			c0 = new ColorTransform (1, 1, 1, 1, 255);

			addEventListener (Event.ENTER_FRAME, loop);
		}

		private function loop (e:Event):void {
			dummy.rotationY += 0.1;
			scene.calculate ();

			counter %= 256; counter += 1;
			part.noise (counter, 0, 255, 2);
			part.colorTransform(r0, c0);

			map.fillRect(map.rect, 0xff808080);
			map.draw(view, matrix);

			stereoTemp.draw(part);
			for (var z:int = 0; z < width / delta; z++) {
				// due to applyFilter() change in FP9 we have to loop :(
				stereoTemp.applyFilter(stereo, rectangle, point, displace);
				stereo.draw(stereoTemp);
			}
		}
	}
}

import alternativ5.engine3d.alternativa3d;
import alternativ5.engine3d.core.Camera3D;
import alternativ5.engine3d.display.Skin;
import alternativ5.engine3d.materials.DrawPoint;
import alternativ5.engine3d.materials.Material;
import alternativ5.engine3d.materials.SurfaceMaterial;
import flash.display.Graphics;
import flash.geom.Matrix;

use namespace alternativa3d;

/**
 * Material bazed on sandy3d Gouraud class.
 * @author makc
 */
class ZShaderMaterial extends SurfaceMaterial {

	private var m1:Matrix = new Matrix;
	private var m2:Matrix = new Matrix;

	override alternativa3d function draw(camera:Camera3D, skin:Skin, length:uint, points:Array):void {
		var point:DrawPoint;
		var p_oGraphics:Graphics = skin.gfx;
		var focalLength:Number = camera.focalLength;

		// set vertex colors according to sep / eyesep = featureZ / (featureZ + obsdist)
		var v0L:Number = points [0].z / (points [0].z + focalLength);
		var v1L:Number = points [1].z / (points [1].z + focalLength);
		var v2L:Number = points [2].z / (points [2].z + focalLength);

		// good old sandy code below...
		var v0:Number, v1:Number, v2:Number,
			u0:Number, u1:Number, u2:Number, tmp:Number;

		v0 = -100; v1 = 0; v2 = 100;

		u0 = -(v0L - 0.5) * (32768 * 0.05);
		u1 = -(v1L - 0.5) * (32768 * 0.05);
		u2 = -(v2L - 0.5) * (32768 * 0.05);

		m2.tx = points [0].x * focalLength / points [0].z;
		m2.ty = points [0].y * focalLength / points [0].z;

		// we have 3276.8 pixels per 256 colors (~0.07 colors per pixel)
		if ( (int (u0 * 0.1) == int (u1 * 0.1)) && (int (u1 * 0.1) == int (u2 * 0.1)) ) {
			// this is solid color case - so fill accordingly
			p_oGraphics.lineStyle();

			/// ???
			p_oGraphics.beginFill( 0x10101 * Math.round (0x7F * (1 - v0L)) + 0x808080 );
			p_oGraphics.moveTo( m2.tx, m2.ty );
			for each( point in points ) {
				p_oGraphics.lineTo( point.x * focalLength / point.z, point.y * focalLength / point.z );
			}
			p_oGraphics.endFill();
			return;
		}
			
		// in one line?
		if ((u2 - u1) * (u1 - u0) > 0) {
			tmp = v1; v1 = v2; v2 = tmp;
		}

		// prepare matrix
		m1.a = u1 - u0; m1.b = v1 - v0;
		m1.c = u2 - u0; m1.d = v2 - v0;
		m1.tx = u0; m1.ty = v0;
		m1.invert ();

		m2.a = points [1].x * focalLength / points [1].z - m2.tx;
		m2.b = points [1].y * focalLength / points [1].z - m2.ty;
		m2.c = points [2].x * focalLength / points [2].z - m2.tx;
		m2.d = points [2].y * focalLength / points [2].z - m2.ty;
		m1.concat (m2);

		// draw the map
		p_oGraphics.lineStyle();
		p_oGraphics.beginGradientFill ("linear", [0x808080, 0xFFFFFF], [1, 1], [0, 255], m1);
		p_oGraphics.moveTo( m2.tx, m2.ty );
		for each( point in points ) {
			p_oGraphics.lineTo( point.x * focalLength / point.z, point.y * focalLength / point.z );
		}
		p_oGraphics.endFill();
	}

	override alternativa3d function clear(skin:Skin):void {
		skin.gfx.clear();
	}

	override public function clone():Material {
		return new ZShaderMaterial();
	}
}
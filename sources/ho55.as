// forked from 3D Pythagoras tree - anaglyph version

// Three-dimensional Pythagoras tree
// First implementation ever, to my best knowledge :)
//
// Click anywhere to regenerate.
// Check http://en.wikipedia.org/wiki/Pythagoras_tree for more info on subject.

package {

	import flash.display.*
	import flash.events.*
	import flash.geom.ColorTransform;

	import alternativ5.engine3d.*
	import alternativ5.engine3d.controllers.*
	import alternativ5.engine3d.core.*
	import alternativ5.engine3d.display.*
	import alternativ5.engine3d.materials.*
	import alternativ5.engine3d.primitives.*
	import alternativ5.types.*

	use namespace alternativa3d;

	[SWF(width=465,height=465,frameRate=30,backgroundColor=0)]
	public class PythagorasTree3D extends Sprite {

		// tree elements (center positions, left and up vectors)
		// similar to http://wonderfl.net/c/3xBs
		private var atA:Point3D = new Point3D, ltA:Point3D = new Point3D, upA:Point3D = new Point3D;
		private var atB:Point3D = new Point3D, ltB:Point3D = new Point3D, upB:Point3D = new Point3D;
		private var atC:Point3D = new Point3D, ltC:Point3D = new Point3D, upC:Point3D = new Point3D;
		private var atD:Point3D = new Point3D, ltD:Point3D = new Point3D, upD:Point3D = new Point3D;
		private var ltE:Point3D = new Point3D (-1, 0, 0), upE:Point3D = new Point3D (0, -1, 0);
		private var matD:Matrix3D = new Matrix3D;
		private var matE:Matrix3D = new Matrix3D;
		private var sA:Number, sB:Number, sC:Number;
		private var rA:Point3D = new Point3D, rB:Point3D = new Point3D, rC:Point3D = new Point3D;
		private function calculateElements (c1:Number, c2:Number):void
		{
			// using c1 and c2 in 0..1 range, select such a, b, c and d that a^2 + b^2 + c^2 = d^2
			// this choise is almost completely free (we only need to make sure that d != 0)
			var a:Number = 0.1 + c1, c:Number = 1.1 - c1; // +
			var b:Number = ((c2 > 0.5) ? (c2 - 0.499999) : (c2 - 0.500001)) * 2; // + or -
			var d:Number = Math.sqrt (a * a + b * b + c * c); // +

			// define corresponding tree elements in some convenient frame
			// we are constrained by Pythagoras theorem, but orientation of planes is arbitrary
			// additionally, we want our tree to coincide with 2D one in boundary case of b = 0
			atA.x = +a/2; atA.y = 0; atA.z = -a/2;
			ltA.x = +a/2; ltA.y = 0; ltA.z =  0;
			upA.x =  0;   upA.y = 0; upA.z = -a/2;

			atC.x = -c/2; atC.y = b; atC.z = +c/2;
			ltC.x =  0;   ltC.y = 0; ltC.z = -c/2;
			upC.x = -c/2; upC.y = 0; upC.z =  0;

			atD.x = +a/2; atD.y = +b/2; atD.z = +c/2;
			ltD.x = +a/2; ltD.y = -b/2; ltD.z = -c/2;
			upD.x = -c; upD.y = 0; upD.z = -a; upD.normalize (); upD.multiply (ltD.length);
			atD.subtract (upD);

			ltB.x = 0; ltB.y = -b/2; ltB.z = 0;
			upB.copy (upD); upB.normalize (); upB.multiply (Math.abs (b/2));
			atB.copy (upB); atB.y = +b/2;

			// find transformation that aligns D element with 2x2 plane frame (E)
			// this 2x2 condition is there to use getRotations () method later
			var lxuD:Point3D = Point3D.cross (ltD, upD);
			lxuD.normalize (); lxuD.multiply (ltD.length);
			matD.a = -ltD.x; matD.e = -ltD.y; matD.i = -ltD.z;
			matD.b = -upD.x; matD.f = -upD.y; matD.j = -upD.z;
			matD.c = lxuD.x; matD.g = lxuD.y; matD.k = lxuD.z;

			var lxuE:Point3D = Point3D.cross (ltE, upE);
			matE.a = -ltE.x; matE.e = -ltE.y; matE.i = -ltE.z;
			matE.b = -upE.x; matE.f = -upE.y; matE.j = -upE.z;
			matE.c = lxuE.x; matE.g = lxuE.y; matE.k = lxuE.z;

			matD.invert (); matD.combine (matE);

			// transform A, B and C elements
			atA.subtract (atD); atA.transform (matD); ltA.transform (matD); upA.transform (matD);
			atB.subtract (atD); atB.transform (matD); ltB.transform (matD); upB.transform (matD);
			atC.subtract (atD); atC.transform (matD); ltC.transform (matD); upC.transform (matD);

			// calculate scales and normalize left/up vectors
			sA = ltA.length; ltA.normalize (); upA.normalize ();
			sB = ltB.length; ltB.normalize (); upB.normalize ();
			sC = ltC.length; ltC.normalize (); upC.normalize ();

			// finally, calculate corresponding rotations (re-using matE/lxuE variables)
			lxuE = Point3D.cross (ltA, upA);
			matE.a = -ltA.x; matE.e = -ltA.y; matE.i = -ltA.z;
			matE.b = -upA.x; matE.f = -upA.y; matE.j = -upA.z;
			matE.c = lxuE.x; matE.g = lxuE.y; matE.k = lxuE.z;
			matE.getRotations (rA);

			lxuE = Point3D.cross (ltB, upB);
			matE.a = -ltB.x; matE.e = -ltB.y; matE.i = -ltB.z;
			matE.b = -upB.x; matE.f = -upB.y; matE.j = -upB.z;
			matE.c = lxuE.x; matE.g = lxuE.y; matE.k = lxuE.z;
			matE.getRotations (rB);

			lxuE = Point3D.cross (ltC, upC);
			matE.a = -ltC.x; matE.e = -ltC.y; matE.i = -ltC.z;
			matE.b = -upC.x; matE.f = -upC.y; matE.j = -upC.z;
			matE.c = lxuE.x; matE.g = lxuE.y; matE.k = lxuE.z;
			matE.getRotations (rC);
		}

		private var planes:Array = [], planesDone:Array = [];
		private function step ():void {
			var pD:Plane = Plane (planes.shift ());
			if (pD == null) return;

			planesDone.push (pD);

			var scale:Number =
				pD.transformation.a * pD.transformation.a +
				pD.transformation.e * pD.transformation.e +
				pD.transformation.i * pD.transformation.i;
			if (scale < 0.001) return;


			var pA:Plane = createPlane ();
			pA.rotationX = rA.x;  pA.rotationY = rA.y;  pA.rotationZ = rA.z;
			pA.scaleX    = sA;    pA.scaleY    = sA;    pA.scaleZ    = sA;
			pA.x         = atA.x; pA.y         = atA.y; pA.z         = atA.z;
			pD.addChild (pA); planes.push (pA);

			var pB:Plane = createPlane ();
			pB.rotationX = rB.x;  pB.rotationY = rB.y;  pB.rotationZ = rB.z;
			pB.scaleX    = sB;    pB.scaleY    = sB;    pB.scaleZ    = sB;
			pB.x         = atB.x; pB.y         = atB.y; pB.z         = atB.z;
			pD.addChild (pB); planes.push (pB);

			var pC:Plane = createPlane ();
			pC.rotationX = rC.x;  pC.rotationY = rC.y;  pC.rotationZ = rC.z;
			pC.scaleX    = sC;    pC.scaleY    = sC;    pC.scaleZ    = sC;
			pC.x         = atC.x; pC.y         = atC.y; pC.z         = atC.z;
			pD.addChild (pC); planes.push (pC);
		}

		private function regenerate (c1:Number, c2:Number):void {
			var p:Plane;

			// delete all the planes
			for each (p in planesDone) destroyPlane (p);
			planesDone.length = 0; planes.length = 0;

			// create base plane
			p = createPlane (); planes.push (p); scene.root.addChild (p);

			// do the math
			calculateElements (c1, c2);

			// mark location
			loc.x = stage.stageWidth * c1;
			loc.y = stage.stageHeight * c2;
		}

		private function destroyPlane (p:Plane):void {
			// this is supposed to make alternativa trash GC-friendly
			if (p.parent != null) p.parent.removeChild (p);
			if (p.hasSurface ("back")) p.setMaterialToSurface (null, "back");
			if (p.hasSurface ("front")) p.setMaterialToSurface (null, "front");
			p.moveAllFacesToSurface (null, true);
		}

		private function createPlane ():Plane {
			var p:Plane = new Plane (2, 2);
			p.cloneMaterialToAllSurfaces (new FillMaterial (0x00FF));
			return p;
		}

		private function interpolateColor (fromColor:uint, toColor:uint, progress:Number):uint {
			var q:Number = 1-progress;
			var fromR:uint = (fromColor >> 16) & 0xFF;
			var fromG:uint = (fromColor >>  8) & 0xFF;
			var fromB:uint =  fromColor        & 0xFF;
			var toR:uint = (toColor >> 16) & 0xFF;
			var toG:uint = (toColor >>  8) & 0xFF;
			var toB:uint =  toColor        & 0xFF;
			var resultR:uint = fromR*q + toR*progress;
			var resultG:uint = fromG*q + toG*progress;
			var resultB:uint = fromB*q + toB*progress;
			var resultColor:uint = resultR << 16 | resultG << 8 | resultB;
			return resultColor;
		}

		private function lightPlane (p:Plane):void {
			var face:Face = p.faces.peek () as Face;
			var dot:Number = (face.globalNormal.x + face.globalNormal.y - face.globalNormal.z) / Math.sqrt (3);
			if (dot < -1) dot = -1; if (dot > 1) dot = 1;
			var lum:Number = 0.6 + 0.4 * Math.abs (dot);
			var color1:uint = 0x40302 * int (63 * lum); // yellow-ish
			var color2:uint = 0x20400 * int (63 * lum); // green-ish
			var m:Matrix3D = p.transformation;
			var prog:Number = Math.sqrt (m.a * m.a + m.e * m.e + m.i * m.i);
			var color:uint = interpolateColor (color2, color1, prog);
			var mat1:FillMaterial = FillMaterial (Surface (p.surfaces ["front"]).material); mat1.color = color;
			var mat2:FillMaterial = FillMaterial (Surface (p.surfaces ["back"]).material); mat2.color = color;
		}

		private var scene:Scene3D;
		private var tripod:Object3D;
		private var viewL:View;
		private var viewR:View;
		private var loc:Shape;

		public function PythagorasTree3D () {
			stage.quality = "best";

			scene = new Scene3D; scene.root = new Object3D;
			viewL = new View; viewL.camera = new Camera3D;
			viewL.camera.z = -6; viewL.camera.rotationX = -0.6; viewL.camera.y = -9;
			tripod = new Object3D; scene.root.addChild (tripod); tripod.addChild (viewL.camera);
			viewL.width = 500; viewL.height = 465; addChild (viewL); viewL.x = -26;
			viewL.transform.colorTransform = new ColorTransform (1, 0, 0);

			viewR = new View; viewR.camera = new Camera3D;
			viewR.camera.x = 0.8; viewL.camera.addChild (viewR.camera);
			viewR.width = 500; viewR.height = 465; addChild (viewR);
			viewR.transform.colorTransform = new ColorTransform (0, 0.9, 1);
			viewR.blendMode = "add";

			var s:Sprite = new Sprite; s.buttonMode = s.useHandCursor = true;
			s.graphics.beginFill (0, 0); s.graphics.drawRect (0, 0, 465, 465);
			addChild (s); s.addEventListener (MouseEvent.CLICK, onClick);

			addEventListener (Event.ENTER_FRAME, onEnterFrame);

			loc = new Shape;
			loc.graphics.lineStyle ();
			loc.graphics.beginFill (0xFFFFFF);
			loc.graphics.drawCircle (0, 0, 2);
			addChild (loc); loc.addEventListener (MouseEvent.CLICK, onClick);

			regenerate (0.5, 0.5);

			stage.addEventListener (KeyboardEvent.KEY_UP, onKeyUp);
		}

		private function onClick (e:MouseEvent):void {
			regenerate (mouseX / stage.stageWidth, mouseY / stage.stageHeight);
			if (e.shiftKey)
				trace ("\t\t\tnew Point ("
				+ (mouseX / stage.stageWidth).toFixed (5)
				+ ", "
				+ (mouseY / stage.stageHeight).toFixed (5)
				+ "),");
		}

		private function onEnterFrame (e:Event):void {
			// add 3 more planes
			var lastPlaneDone:int = planesDone.length;
			var grow:Boolean = (planesDone.length < 15000);
			if (grow) {
				for (var s:int = 0; s < 90; s++) step ();
			}
			scene.calculate ();
			// apply lighting after global normals were set
			if (grow || (lastPlaneDone < planesDone.length)) {
				for (var p:int = lastPlaneDone; p < planesDone.length; p++)
					lightPlane (planesDone [p]);
				for (var i:int = Math.max (0, planes.length - 9*3); i < planes.length; i++)
					lightPlane (planes [i]);
			}
		}

		private var dae:XML =
		<COLLADA version="1.4.0" xmlns="http://www.collada.org/2005/11/COLLADASchema">
			<asset>
				<unit meter="0.01" name="centimeter"/>
				<up_axis>Z_UP</up_axis>
			</asset>
			<library_geometries>
				<geometry id="Plane-Geometry" name="Plane-Geometry">
					<mesh>
						<source id="Plane-Geometry-Position">
							<float_array count="36" id="Plane-Geometry-Position-array">1.00000 1.00000 0.00000 1.00000 -1.00000 0.00000 -1.00000 -1.00000 0.00000 -1.00000 1.00000 0.00000</float_array>
							<technique_common>
								<accessor count="4" source="#Plane-Geometry-Position-array" stride="3">
									<param type="float" name="X"></param>
									<param type="float" name="Y"></param>
									<param type="float" name="Z"></param>
								</accessor>
							</technique_common>
						</source>
						<source id="Plane-Geometry-Normals">
							<float_array count="3" id="Plane-Geometry-Normals-array">0.00000 0.00000 1.00000</float_array>
							<technique_common>
								<accessor count="1" source="#Plane-Geometry-Normals-array" stride="3">
									<param type="float" name="X"></param>
									<param type="float" name="Y"></param>
									<param type="float" name="Z"></param>
								</accessor>
							</technique_common>
						</source>
						<vertices id="Plane-Geometry-Vertex">
							<input semantic="POSITION" source="#Plane-Geometry-Position"/>
						</vertices>
						<polygons count="1">
							<input offset="0" semantic="VERTEX" source="#Plane-Geometry-Vertex"/>
							<input offset="1" semantic="NORMAL" source="#Plane-Geometry-Normals"/>
							<p>0 0 1 0 2 0 3 0</p>
						</polygons>
					</mesh>
				</geometry>
			</library_geometries>
			<library_visual_scenes>
				<visual_scene id="Scene" name="Scene" />
			</library_visual_scenes>
			<scene>
				<instance_visual_scene url="#Scene"/>
			</scene>
		</COLLADA>;

		private function onKeyUp (e:KeyboardEvent):void {
			// export collada 1.4
			var scene:XML = <visual_scene id="Scene" name="Scene" />;
			for (var i:int = 0; i < planesDone.length; i++) {
				var pi:Plane = Plane (planesDone [i]);
				var mi:Matrix3D = pi.transformation;
				var ni:XML = new XML (
				"<node layer=\"L1\" id=\"Plane" + i + "\" name=\"Plane" + i + "\">" +
					"<matrix>" +
						mi.a + " " + mi.b + " " + mi.c + " " + mi.d + " " +
						mi.e + " " + mi.f + " " + mi.g + " " + mi.h + " " +
						mi.i + " " + mi.j + " " + mi.k + " " + mi.l + " " +
						"0.0 0.0 0.0 1.0" +
					"</matrix>" +
					"<instance_geometry url=\"#Plane-Geometry\"/>" +
				"</node>"
				);
				scene.appendChild (ni);
			}

			// dump to flash log
			dae.children() [2].setChildren (scene);
			trace ("<?xml version=\"1.0\" encoding=\"utf-8\"?>")
			trace (dae.toString ());
		}
	}
}
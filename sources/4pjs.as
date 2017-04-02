// Three-dimensional Pythagoras tree
// First implementation ever, to my best knowledge :)
//
// Click anywhere to regenerate.
// Check http://en.wikipedia.org/wiki/Pythagoras_tree for more info on subject.

package {

	import flash.display.*
	import flash.events.*

	import alternativ5.engine3d.controllers.*
	import alternativ5.engine3d.core.*
	import alternativ5.engine3d.display.*
	import alternativ5.engine3d.materials.*
	import alternativ5.engine3d.primitives.*
	import alternativ5.types.*
     
	[SWF(width=465,height=465,frameRate=30)]
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
			var b:Number = ((c2 > 0.5) ? (c2 - 0.49) : (c2 - 0.51)) * 2; // + or -
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
			var pD:Plane = Plane (planes.shift ()); planesDone.push (pD);

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
			p.cloneMaterialToAllSurfaces (new FillMaterial (0xFFFFFF * Math.random ()));
			return p;
		}

		private var scene:Scene3D;
		private var tripod:Object3D;
		private var view:View;

		public function PythagorasTree3D () {
			scene = new Scene3D; scene.root = new Object3D;
			view = new View; view.camera = new Camera3D;
			view.camera.z = -6; view.camera.rotationX = -0.4; view.camera.y = -6;
			tripod = new Object3D; scene.root.addChild (tripod); tripod.addChild (view.camera);
			view.width = view.height = 465; addChild (view);

			regenerate (0.5, 0.6);

			var s:Sprite = new Sprite; s.buttonMode = s.useHandCursor = true;
			s.graphics.beginFill (0, 0); s.graphics.drawRect (0, 0, 465, 465);
			addChild (s); s.addEventListener (MouseEvent.CLICK, onClick);

			addEventListener (Event.ENTER_FRAME, onEnterFrame);
		}

		private function onClick (e:MouseEvent):void {
			regenerate (mouseX / 465.0, mouseY / 465.0);
		}

		private function onEnterFrame (e:Event):void {
			if (planesDone.length < 50) step ();
			tripod.rotationY += 0.1; scene.calculate ();
		}
	}
}
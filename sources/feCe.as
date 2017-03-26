package {

	import flash.display.*;
	import flash.geom.*;
	import flash.events.*;


	[SWF(width = 500, height=500, backgroundColor = 0x000000)]

       public class QuadLights extends MovieClip {
		private var quadNum:int;
		private var verts:Vector.<Number>;
		private var pVerts:Vector.<Number>;
		private var uvts:Vector.<Number>;
		private var indices:Vector.<int>;
		private var sortedIndices:Vector.<int>;
		private var faces:Array;
		private var m:Matrix3D;
		private var quad:Vector.<Number>;
		private var transQuad:Vector.<Number>;
		private var i:int;
		private var inc:int;
		private var tex:BitmapData;
		private var grad:Shape;
		private var mat:Matrix;
		private var render:Shape;
		private var persp:PerspectiveProjection;
		private var proj:Matrix3D;
		private var dx:Number;
		private var dy:Number;


               public function QuadLights(){
                 init();
			

               }
               private function init():void{
                    // init
			x = stage.stageWidth / 2;
			y = stage.stageHeight / 2;
			quadNum = 2200;
			// standard Vectors for using drawTriangles
			verts = new Vector.<Number>();
			pVerts;
			uvts = new Vector.<Number>();
			indices = new Vector.<int>();
			// needed for z-sorting
			sortedIndices;
			faces = [];
			// we'll use this for tranforming points
			// and as the transformation matrix for our render
			m = new Matrix3D();
			// plot a quad
			quad;
			quad = Vector.<Number>([-10, -10, 0,
									10, -10, 0,
									-10, 10, 0,
									10, 10, 0]);
			// temp vect for any transformed quads
			transQuad = new Vector.<Number>();
			i;
			inc = 0;
			for (i = 0; i<quadNum; i++){
				m.identity();
				var s:Number = (int(Math.random()*50) == 1) ? 2 + Math.random()*2 : .1 + Math.random() * 2;
				m.appendScale(s, s, 1);
				m.appendRotation(90, Vector3D.Y_AXIS);
				var mult:Number = 100 + Math.random()*200;
				m.appendTranslation(mult, 0, 0);
				m.appendRotation(Math.random()*360, Vector3D.X_AXIS);
				m.appendRotation(Math.random()*360, Vector3D.Y_AXIS);
				m.appendRotation(Math.random()*360, Vector3D.Z_AXIS);
				m.transformVectors(quad, transQuad);
				verts = verts.concat(transQuad);
				faces.push(new Vector3D());
				faces.push(new Vector3D());
				var i4:int = i * 4;
				indices.push(0 + i4, 1 + i4, 2 + i4,
							 1 + i4, 3 + i4, 2 + i4);
				mult /= 300;
				uvts.push(mult,mult,0,
						  mult+.1,mult,0,
						  mult,mult - .1,0,
						  mult + .1,mult + .1,0);
			}
			sortedIndices = new Vector.<int>(indices.length, true);
			// create texture
			tex = new BitmapData(400,400,false, 0x000000);
			grad = new Shape();
			mat = new Matrix();
			mat.createGradientBox(400,400,0,0,0);
			with (grad.graphics){
				beginGradientFill(GradientType.LINEAR, [0xFFFFFF,0x002244], [1, 1], [100, 255], mat);
				drawRect(0,0,400,400);
			}
			tex.draw(grad);
			// create background
			mat.createGradientBox(1600,1200,0,-550, 0);
			with (grad.graphics){
				beginGradientFill(GradientType.RADIAL, [0x000000, 0x001133], [1, 1], [0, 255], mat);
				drawRect(0,0,500,500);
			}
			grad.x = -stage.stageWidth/2
			grad.y = -stage.stageHeight/2;
			addChild(grad);
			// triangles will be drawn to this
			render = Shape(addChild(new Shape()));
			// fix all vector lengths
			verts.fixed = true, uvts.fixed = true, indices.fixed = true
			pVerts = new Vector.<Number>(verts.length/3 * 2, true);
			// we need these if we want perspective
			persp = new PerspectiveProjection();
			persp.fieldOfView = 45;
			// projection matrix
			proj = persp.toMatrix3D();
			dx = 0, dy = 0;
			addEventListener(Event.ENTER_FRAME, onLoop);
}
               // private methods

		private function onLoop(evt:Event):void {
			dx += (mouseX - dx) / 4;
			dy += (mouseY - dy) / 4;
			m.identity();
			m.appendRotation(dy, Vector3D.X_AXIS);
			m.appendRotation(dx, Vector3D.Y_AXIS);
			m.appendTranslation(0,0,800);
			m.append(proj);
			Utils3D.projectVectors(m, verts, pVerts, uvts);
			var face:Vector3D;
			inc = 0;
			for (var i:int = 0; i<indices.length; i+=3){
				face = faces[inc];
				face.x = indices[i];
				face.y = indices[int(i + 1)];
				face.z = indices[int(i + 2)];
				var i3:int = i * 3;
				face.w = (uvts[int(face.x*3 + 2)] + uvts[int(face.y*3 + 2)] + uvts[int(face.z*3 + 2)]) * 0.333333;
				inc++;
			}
			faces.sortOn("w", Array.NUMERIC);
			inc = 0;
			for each (face in faces){
				sortedIndices[inc++] = face.x;
				sortedIndices[inc++] = face.y;
				sortedIndices[inc++] = face.z;
			}
			render.graphics.clear();
			render.graphics.beginBitmapFill(tex, null, false, false);
			render.graphics.drawTriangles(pVerts, sortedIndices, uvts, TriangleCulling.NEGATIVE);
		}
		

       }

}
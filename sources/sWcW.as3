package {
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.filters.*;


	[SWF(backgroundColor=0x000000)]
	
	dynamic public class Test extends MovieClip {
		private var squareNum:int;
		private var hw:Number;
		private var hh:Number;
		private var verts:Vector.<Number>;
		private var cmds:Vector.<int>;
		private var tempVerts:Vector.<Number>;
		private var newVerts:Vector.<Number>;
		private var pVerts:Vector.<Number>;
		private var uv:Vector.<Number>;
		private var vectors:Shape;
		private var canvas:BitmapData;
		private var blurred:BitmapData;
		private var blur:BlurFilter;
		private var m:Matrix3D;
		private var radius:Number;
		private var dx:Number;
		private var dy:Number;
		private var pnt:Point;

		
		public function Test(){
		   // init
			squareNum  = 1000;
			hw = stage.stageWidth / 2;
			hh = stage.stageHeight / 2;
			// verts defines a single square
			verts = Vector.<Number>([-20, 0, 0, 20, 0, 0, 20, 0, 40, -20, 0, 40, -20, 0, 0]);
			cmds = Vector.<int>([1,2,2,2,2]);
			tempVerts = new Vector.<Number>();
			newVerts = new Vector.<Number>();
			pVerts = new Vector.<Number>(10 * squareNum);
			uv = new Vector.<Number>(15 * squareNum);
			vectors = new Shape();
			canvas = new BitmapData(stage.stageWidth,stage.stageHeight,false, 0x000000);
			addChild(new Bitmap(canvas));
			blurred = new BitmapData(stage.stageWidth,stage.stageHeight,false, 0x000000);
			blur = new BlurFilter(20,20,1);
			m = new Matrix3D();
			radius = 200;
			// duplicate the verts array a bunch of times
			// each time moving the square to a random place on the
			// circumference of a sphere
			for (var i:int = 0; i<squareNum; i++){
				m.identity();
				var s:Number = Math.random()*.5 + .5;
				m.appendScale(s, s, s);
				m.appendRotation(90,Vector3D.X_AXIS);
				m.appendTranslation(0, 0, radius);
				m.appendRotation(Math.random()*360,Vector3D.X_AXIS);
				m.appendRotation(Math.random()*360,Vector3D.Y_AXIS);
				m.appendRotation(Math.random()*360,Vector3D.Z_AXIS);
				m.transformVectors(verts,tempVerts);
				newVerts = newVerts.concat(tempVerts);
				cmds = cmds.concat(Vector.<int>([1,2,2,2,2]));
			}
			newVerts.fixed = pVerts.fixed = uv.fixed = true;
			dx = 0, dy = 0;
			pnt = new Point();
			addEventListener(Event.ENTER_FRAME, onLoop);
			

		}
		// private methods

		private function onLoop(evt:Event):void {
			   dx += (mouseX - dx) / 4;
			   dy += (mouseY - dy) / 4;
			   m.identity();
			   m.appendRotation(dx,Vector3D.Z_AXIS);
			   m.appendRotation(dy,Vector3D.X_AXIS);
			   m.appendTranslation(hw,hh, 0);
			   Utils3D.projectVectors(m, newVerts, pVerts, uv);
			   with(vectors.graphics){
				   clear();
				   beginFill(0xFFFFFF);
				   drawCircle(hw, hh, radius+10);
				   beginFill(0x000000);
				   drawPath(cmds, pVerts, GraphicsPathWinding.NON_ZERO);
			   }
			   canvas.fillRect(canvas.rect, 0x000000);
			   canvas.draw(vectors);
			   blurred.copyPixels(canvas, canvas.rect, pnt);
			   blurred.applyFilter(blurred,blurred.rect, pnt, blur);
			   canvas.draw(blurred, null, null, BlendMode.SCREEN);
		}
		

	}

}
package {

        // interactive implicit 3D blobby plot
        
        // more info here: http://actionsnippet.com/?p=1318
        
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;


	
       [SWF(backgroundColor=0x000000)]
       
       public class ImplicitBlobby extends MovieClip {
		private var matrix:Matrix3D;
		private var verts:Vector.<Number>;
		private var pVerts:Vector.<Number>;
		private var uvts:Vector.<Number>;
		private var s:Number;
		private var brush:BitmapData;
		private var canvas:BitmapData;
		private var dx:Number;
		private var dy:Number;


               public function ImplicitBlobby(){
                  // init
			matrix = new Matrix3D();
			verts = new Vector.<Number>();
			pVerts = new Vector.<Number>();
			uvts = new Vector.<Number>();
			for (var i:Number = -2; i<2; i+=.04) {
				for (var j:Number = -2; j<2; j+=.04) {
					for (var k:Number = -2; k<2; k+=.04) {
						// blobby, from here www.iiit.net/techreports/ImplicitTR.pdf
			s=i*i+j*j+k*k+Math.sin(4*i)-Math.cos(4*j)+Math.sin(4*k)-1;
						if (s<0&&s>-.2) {
							verts.push(i * 60);
							verts.push(j * 60);
							verts.push(k * 60);
							pVerts.push(0),pVerts.push(0);
							uvts.push(0),uvts.push(0),uvts.push(0);
						}
					}
				}
			}
			brush=new BitmapData(3,2,true,0x41FFFFFF);
			canvas=new BitmapData(400,400,false,0x000000);
			addChild(new Bitmap(canvas));
			dx=0;
			dy=0;
			addEventListener(Event.ENTER_FRAME, onLoop);
			

               }
               // private methods

		private function onLoop(evt:Event):void {
			dx += (mouseX - dx)/4;
			dy += (mouseY - dy)/4;
			matrix.identity();
			matrix.appendRotation(dy,Vector3D.X_AXIS);
			matrix.appendRotation(dx,Vector3D.Y_AXIS);
			matrix.appendTranslation(200, 200, 0);
			Utils3D.projectVectors(matrix, verts, pVerts, uvts);
			canvas.lock();
			canvas.fillRect(canvas.rect, 0x000000);
			var p:Point = new Point();
			for (var i:int = 0; i<pVerts.length; i+=2) {
				p.x = pVerts[i];
				p.y = pVerts[i+1];
				canvas.copyPixels(brush, brush.rect, p, null, null, true);
			}
			canvas.unlock();
		}
		

       }

}
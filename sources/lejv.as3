// forked from shapevent's Implicit 3D Blobby
package {

        // interactive explicit 3D Klein bottle
        
        // more info here: http://wonderfl.net/c/6RzY/read
        
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;


	
       [SWF(backgroundColor=0x000000)]
       
       public class KleinBottle extends MovieClip {
		private var matrix:Matrix3D;
		private var verts:Vector.<Number>;
		private var pVerts:Vector.<Number>;
		private var uvts:Vector.<Number>;
		private var s:Number;
		private var brush:BitmapData;
		private var canvas:BitmapData;
		private var dx:Number;
		private var dy:Number;


               public function KleinBottle(){
                  // init
			matrix = new Matrix3D();
			verts = new Vector.<Number>();
			pVerts = new Vector.<Number>();
			uvts = new Vector.<Number>();
			var pos:int = 0;
			var pi:Number = Math.PI, pi2:Number = pi*2, SCALE:Number = 5;   
			var u:Number, v:Number, r:Number;
			var step:int = 18, step2:int = 5;
			for(var i:int = 0; i < pi2*step-1; i++) {
				for(var j:int = 0; j < pi2*step2-1; j++) {
					u = i/step; v = j/step2;
					r = 4*(1 - Math.cos(u)/2);
					if(u < pi) {
						verts[pos++] = (6*Math.cos(u)*(1 + Math.sin(u)) + r*Math.cos(u)*Math.cos(v))*SCALE;
						verts[pos++] = (16*Math.sin(u) + r*Math.sin(u)*Math.cos(v))*SCALE;
					}else if(u > pi) {
						verts[pos++] = (6*Math.cos(u)*(1 + Math.sin(u)) + r*Math.cos(v + Math.PI))*SCALE;
						verts[pos++] = (16*Math.sin(u))*SCALE;
					}
					verts[pos++] = r*Math.sin(v)*SCALE;

					pVerts.push(0),pVerts.push(0);
					uvts.push(u/pi2),uvts.push(0),uvts.push(0);
				}
			}
			brush = new BitmapData (360, 1, true);
			for (i = 0; i < 360; i++) brush.setPixel32 (i, 0, hsv2rgb (i) + 0x41000000);
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
			var r:Rectangle = new Rectangle(0,0,1,1);
			for (var i:int = 0; i<pVerts.length; i+=2) {
				p.x = pVerts[i];
				p.y = pVerts[i + 1];
				r.x = 360*uvts[3*i/2];
				canvas.copyPixels(brush, r, p, null, null, true);
			}
			canvas.unlock();
		}
		
		/**
		 * @see http://wonderfl.net/c/dtn8
		 * @author matacat
		 */
		private function hsv2rgb(h:Number, s:Number = 1, v:Number = 1):uint
		{
			var rgb:uint = 0;

			if (s == 0) {  // gray scale
				rgb = 0xFF * v << 16 | 0xFF * v << 8 | 0xFF * v << 0;
				return rgb;
			}
			
			h = int (h) >= 360 ? int (h) % 360 : (int (h) < 0 ? int (h) % 360 + 360 : int (h));
			
			var i:int = int(h / 60);
			var f:Number = h / 60 - i;
			var p:Number = v * (1 - s);
			var q:Number = v * (1 - s * f);
			var t:Number = v * (1 - s * (1 - f));
			
			switch (i) {
				case 0: rgb = 0xFF * v << 16 | 0xFF * t << 8 | 0xFF * p << 0; break;
				case 1: rgb = 0xFF * q << 16 | 0xFF * v << 8 | 0xFF * p << 0; break;
				case 2: rgb = 0xFF * p << 16 | 0xFF * v << 8 | 0xFF * t << 0; break;
				case 3: rgb = 0xFF * p << 16 | 0xFF * q << 8 | 0xFF * v << 0; break;
				case 4: rgb = 0xFF * t << 16 | 0xFF * p << 8 | 0xFF * v << 0; break;
				case 5: rgb = 0xFF * v << 16 | 0xFF * p << 8 | 0xFF * q << 0;
			}

			return rgb;
		}

       }

}
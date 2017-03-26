package {

	import flash.display.*;
	import flash.geom.*;
	import flash.events.*;
        import flash.filters.*;


	[SWF(frameRate=60, backgroundColor=0x000000, width=500, height=500)]

       public class SierpinskiGlitch extends MovieClip {
           
		private var canvas:BitmapData;
		private var clone:BitmapData;
		private var canvasRect:Rectangle;
		private var w:int;
		private var w2:Number;
		private var w10:Number;
		private var convert:Number;
		private var size:int;
		private var pix:Vector.<uint>;
		private var gray:ColorMatrixFilter;
		private var m:Matrix;
		private var sin:Number;
		private var cos:Number;
		private var dx:Number;
		private var dy:Number;
		private var pnt:Point;
		private var blur:BlurFilter;


               public function SierpinskiGlitch(){
                  // init
			canvas = new BitmapData(500,500,false, 0x000000);
			addChild(new Bitmap(canvas));
			clone = new BitmapData(500,500,false, 0x000000);
			canvasRect = canvas.rect;
			w = canvas.width;
			w2 = 1/w;
			w10 = 1/(w * 80);
			convert = Math.PI/180;
			size = canvas.width * canvas.height;
			pix = new Vector.<uint>(size, true);
			gray = new ColorMatrixFilter([1, 0.55, 0.55, 0,0,0.55, 0.9, 0.55, 0,0,0.55, 0.55, 0.550,0, 0,0,0,1,0]);
			m = new Matrix();
			m.scale(1,-1);
			m.translate(0,canvas.height);
			sin = 0, cos = 0;
			dx = 0, dy = 0;
			pnt = new Point();
			blur = new BlurFilter(10,10,1);
			addEventListener(Event.ENTER_FRAME, onLoop);
			

               }
               // private methods

		private function onLoop(evt:Event):void {
			canvas.lock();
			dx += (mouseX * 10 - 3000 - dx) / 8;
			dy += (mouseY * 4 - dy) / 8;
			for (var i:int = 0; i<size; i++){
				var xp:int = i % w;
				var yp:int = int(i * w2);
				var xp2:int = xp <<1;
				var t:Number;
				t = ((yp|xp) * (xp + dx) *w10) % 6.14687;
				
				//compute sine
				// technique from http://lab.polygonal.de/2007/07/18/fast-and-accurate-sinecosine-approximation/
				// by Michael Baczynski
				if (t<0) {
					sin=1.27323954*t+.405284735*t*t;
				} else {
					sin=1.27323954*t-0.405284735*t*t;
				}
				// compute cosine
				t = (xp2 + dy) * convert % 6.28;
				t+=1.57079632;
				if (t>3.14159265) {
					t-=6.28318531;
				}
				if (t<0) {
					cos=1.27323954*t+0.405284735*t*t;
				} else {
					cos=1.27323954*t-0.405284735*t*t;
				}
				var c1:int = 31 * (sin - cos);
				if (c1 <0) c1 = 256 - c1;
				c1 = (c1 <<3 | c1) ;
				pix[i] = c1 <<15 | c1 <<8 | c1;
			}
			canvas.setVector(canvasRect, pix);
			clone.copyPixels(canvas, canvasRect, pnt);
			canvas.draw(clone, m, null, BlendMode.SUBTRACT);
			clone.copyPixels(canvas, canvasRect, pnt);
			clone.applyFilter(clone, canvasRect, pnt, blur);
			canvas.draw(clone, null, null, BlendMode.ADD);
			canvas.unlock();
		}
		

       }

}
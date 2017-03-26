package {
	import flash.events.Event;
	import flash.display.Sprite;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
        import flash.geom.Rectangle;

	public class OldPlasma extends Sprite {
		const w:int = 232;
		const h:int = 232;
		const sx:int = 2;
		const sy:int = 2;
		const sinN:int = 4000;
		const pi2:Number = 2 * Math.PI;
		
		var step:Number = 2 * Math.PI / sinN;;
		
		var time:Number = 0;
		var ctr:int = 0;
		var ctr1:Number = 0;
		var ctr2:Number = 0;
		
		var x1:int = 0;
		var y1:int = 0;
		
		var v:Number;
		var color:Number;
		
		var a:Number;
		var b:Number;
		
		var shiftx:int = Math.random() * 100000 % pi2 / step;;
		var shifty:int = Math.random() * 100000 % pi2 / step;;
		
		const ssx:int = Math.random() * 10 + 5;;
		const ssy:int = Math.random() * 10 + 5;;

		var pixels:Vector.<uint>;
		var sinT:Vector.<Number>;

		var bmd:BitmapData;
		var bm:Bitmap;
		
		var i:int;
		
		public function OldPlasma() {
			pixels = new Vector.<uint>(w * h);
			
			sinT = new Vector.<Number>();
			
			bmd = new BitmapData(w, h);
			bm = new Bitmap(bmd);
			
			bm.scaleX = sx;
			bm.scaleY = sy;
			
			addChildAt(bm, 0);
			
			for(i = 0; i < sinN; i++){
				sinT.push(Math.sin(i * step));
			}
			
			for(x1 = 0; x1 < w; x1++){
				for(y1 = 0; y1 < h; y1++){
					pixels[y1 * w + x1] = 0;
					bmd.setPixel(x1, y1, 0);
				}
			}
			
			addEventListener(Event.ENTER_FRAME, handleEnterFrame);

		}
		
		private function handleEnterFrame(e:Event){
			ctr += 4;
			
			shiftx += ssx;
			shifty += ssy;
			
			if(ctr >= sinN) ctr -= sinN;
			if(shiftx >= sinN) shiftx -= sinN;
			if(shifty >= sinN) shifty -= sinN;
			
			ctr1 = sinT[int(shiftx)] * 300;
			ctr2 = sinT[int(shifty)] * 300;
			
			time = sinT[ctr] * 200;

//Clear screen and draw only new regions - amazing :)			
//			bmd.fillRect(new Rectangle(0, 0, w, h), 0xff000000);
		
			for(x1 = 0; x1 < w; x1++){
				for(y1 = 0; y1 < h; y1++){
					a = x1 + time - 32 + ctr1;
					b = y1 - 128 + ctr2;
					v = sinT[int(((a * a + b * b) / 20000) % pi2 / step)];
		
					a = x1 - ctr1;
					b = y1 - 64 + ctr2;
					v += sinT[int(((a * a + b * b) / 42000) % pi2 / step)];
					
					a = x1 - 192 + ctr1;
					b = y1 -  64 + ctr2;
					v += sinT[int(((a * a + b * b) / 63000) % pi2 / step)];
					
					a = x1 -  192 + ctr1;
					b = y1 + time / 20 - 100 + ctr2;
					v += sinT[int(((a * a + b * b) / 34000) % pi2 / step)];
		
					i = ((4 + v) * 2);
		
					color = i * 16
								+ ((i * 32) << 8)
								+ ((i * 64) << 16);
				
					i = y1 * w + x1;
					
					if(pixels[i] != color){
						pixels[i] = color;
						bmd.setPixel(x1, y1, color);
					}
				}
			}
		}
	}
}
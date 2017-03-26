package {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.BlurFilter;
	import flash.filters.ConvolutionFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Point;

	public class FingerPrints extends Sprite {
		private const OUTPUT_WIDTH : int = 465;
		private const OUTPUT_HIGHT : int = 465;
		private var bitmapData : BitmapData;
		private var displayBitmapData : BitmapData;
		
		private var blurFilter : BlurFilter;
		private var sharpConvFilter : ConvolutionFilter;
		private var colorTrans : ColorTransform;
		private var seed : uint = int(Math.random() * 10000);
		private var alphaArray : Array;
		
		private var pnt0 : Point;
		private var pnt1 : Point;
		private var pnt2 : Point;
		private var pnts : Array;
		
		private var n0 : int = 0;
		private var n1 : int = 0;
		private var n2 : int = 0;
		private const w : int = OUTPUT_HIGHT;
		private const h : int = OUTPUT_HIGHT;

		private var brdr0 : Number;
		private var brdr1 : Number;
		private const zeroPnt : Point = new Point();

		public function FingerPrints() {
                       stage.scaleMode = "noScale";
                       stage.align = "TL";
                        
                       graphics.beginFill(0);
			graphics.drawRect(0, 0, OUTPUT_WIDTH, OUTPUT_HIGHT);
			graphics.endFill();
    
			bitmapData = new BitmapData(OUTPUT_WIDTH, OUTPUT_HIGHT, true, 0x00000000);
			displayBitmapData = new BitmapData(OUTPUT_WIDTH, OUTPUT_HIGHT, true, 0x00000000);
			
			alphaArray = [];
			for (var i : int = 0;i < 255; i++) {
				alphaArray[i] = 0xFF000000;
			}
			
			pnt0 = new Point();
			pnt1 = new Point();
			pnt2 = new Point();
			pnts = [pnt0, pnt1, pnt2];
			
			colorTrans = new ColorTransform(0.8, 1.7, 2, 1);
			blurFilter = new BlurFilter(2, 2, 2);
			sharpConvFilter = new ConvolutionFilter(3, 3, new Array(0, -1, 0, -1, 10, -1, 0, -1, 0), 6);
			
			var bitmap:Bitmap = new Bitmap(displayBitmapData);
			addChild(bitmap);
			addEventListener(Event.ENTER_FRAME, redraw);
			
			brdr0 = 0x00808080;
			brdr1 = 0x008A8A8A;
		}

		private function redraw(event : Event) : void {
			
			n0 += 27.4 * .7 + 20 * Math.sin(n1 / 100);
			n1 += 28.2 * .5;
			n2 += 23.7 * .9;
			pnt0.x = w * Math.sin(n0 / 3000);
			pnt0.y = h * Math.cos(n1 / 5000);
			pnt1.x = -w * Math.cos(n2 / 2000) * Math.sin(n1 / 1000);
			pnt1.y = -h * Math.sin(n0 / 2000);
			pnt2.x = w * Math.sin(n0 / 1007);
			pnt2.y = h * Math.cos(n2 / 3000) * Math.sin(n0 / 3000);
			
			bitmapData.perlinNoise(OUTPUT_WIDTH, OUTPUT_HIGHT, 3, seed, true, true, 1, true, pnts);
			bitmapData.threshold(bitmapData, displayBitmapData.rect, zeroPnt, "<", brdr0, 0, 0x00FFFFFF, false);
			bitmapData.threshold(bitmapData, displayBitmapData.rect, zeroPnt, ">", brdr1, 0, 0x00FFFFFF, false);
			
			displayBitmapData.paletteMap(displayBitmapData, displayBitmapData.rect, zeroPnt, null, null, null, alphaArray);
			displayBitmapData.draw(bitmapData, null, colorTrans);
			displayBitmapData.applyFilter(displayBitmapData, displayBitmapData.rect, new Point(), blurFilter);
			displayBitmapData.applyFilter(displayBitmapData, displayBitmapData.rect, new Point(), sharpConvFilter);
		}
	}
}
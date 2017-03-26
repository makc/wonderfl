package 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.BlurFilter;
	import flash.geom.Point;

	public class Main extends Sprite 
	{
		
		public static const PERLIN_WIDTH:int = 40;
		public static const PERLIN_HEIGHT:int = 40;
		public static const WIDTH:int = 400;
		public static const HEIGHT:int = 400;
		
		private var px:Number = 0;
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			addEventListener(Event.ENTER_FRAME, loop);
			filters = [new BlurFilter(4,4)];
		}
		
		private function loop(e:Event):void {
			var bmpData :BitmapData = new BitmapData(PERLIN_WIDTH, PERLIN_HEIGHT);
			bmpData.perlinNoise(PERLIN_WIDTH, PERLIN_HEIGHT, 3, 6456, true, true, 2 | 1, false, [new Point(px += 0.5, 0), new Point( -px / 2, 0), new Point(0, 0)]);
			graphics.clear();
			graphics.beginFill(0x000000);
			graphics.drawRect(0, 0, WIDTH, HEIGHT);
			graphics.endFill();
			graphics.lineStyle(1, 0xFFFFFF, 0.1);
			for (var j:int = 0; j < PERLIN_HEIGHT - 1; j++) { 
				var value1:int = bmpData.getPixel(0, j);
				value1 = value1 >> 16;
				var value2:int = bmpData.getPixel(0 + 1, j);
				value2 = value2 >> 16;
				graphics.moveTo(0 * WIDTH / (PERLIN_WIDTH -1), value1 + HEIGHT / 2 - 128);
				//graphics.beginFill(0xFFFFFF, 0.1);
				for (var i:int = 0; i < PERLIN_WIDTH - 1; i++) {
					value1 = bmpData.getPixel(i, j);
					value1 = value1 >> 16;
					value2 = bmpData.getPixel(i + 1, j);
					value2 = value2 >> 16;
					
					graphics.curveTo(i * WIDTH / (PERLIN_WIDTH - 1), value1 + HEIGHT / 2 - 128, (i + 1) * WIDTH / (PERLIN_WIDTH - 1), value2 + HEIGHT / 2 - 128);
				}
			}
		}
		
	}
	
}
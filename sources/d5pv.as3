// forked from hacker_ij48yrxl's flash on 2009-5-10
/*
* blog@http://tirirenge.undo.jp/?p=1821
*/
package 
{
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.filters.BlurFilter;
    import flash.geom.Point;
    
    [SWF(width=465, height=465, frameRate=30, backgroundColor=0x000000)]
    
    public class Main extends Sprite
    {
        public static const PERLIN_WIDTH:int = 20;
        public static const PERLIN_HEIGHT:int = 60;
        public static const WIDTH:int = 600;
        public static const HEIGHT:int = 600;
        private var px:Number = 0;
        private var color:Number;
        
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
            filters = [new BlurFilter(5,5)];
        }
        private function loop(e:Event):void
        {
            var bmpData :BitmapData = new BitmapData(PERLIN_WIDTH, PERLIN_HEIGHT);
            var channels:uint = 2 | 1;
            bmpData.perlinNoise(
            PERLIN_WIDTH, PERLIN_HEIGHT, 2, 6456, true, true, channels, false, [new Point(px += 0.5, 0), new Point( -px / 2, 0), new Point(0, 0)]);
            graphics.clear();
            
            color = Math.random() * 0xff0000;
            graphics.lineStyle(0.1, color, 0.5);
            
            
            for (var j:int = 0; j < PERLIN_HEIGHT - 1; j++)
            {
                var value1:int = bmpData.getPixel(0, j);
                value1 = value1 >> 16;
                var value2:int = bmpData.getPixel(0 + 1, j);
                value2 = value2 >> 16;
                graphics.moveTo(0 * WIDTH / (PERLIN_WIDTH -1), value1 + HEIGHT / 2 - 128);
                
                //graphics.beginFill(0xFFFFFF, 0.1);
                for (var i:int = 0; i < PERLIN_WIDTH - 1; i++)
                {
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
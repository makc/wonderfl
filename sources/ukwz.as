// forked from hacker_ij48yrxl's flash on 2009-5-10
package 
{
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Graphics;
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.filters.BlurFilter;
    import flash.geom.ColorTransform;
    import flash.geom.Point;
    import net.hires.debug.Stats;
    
    [SWF(width="465", height="465", backgroundColor="0x000000", frameRate="30")]
    public class Asawon6 extends Sprite 
    {
        
        public static const PERLIN_WIDTH:int = 40;
        public static const PERLIN_HEIGHT:int = 40;
        public static const WIDTH:int = 500;
        public static const HEIGHT:int = 400;
        public static const num:Number = 255;
        
        private var px:Number = 0;
        private var offset:Array;
        private var sh:Shape;
        private var bmd:BitmapData;
        private var p:Point;
        private var blur:BlurFilter;
        private var colorTf:ColorTransform;
        private var bmpData:BitmapData;
        
        public function Asawon6():void 
        {
            if (stage) init();
            else addEventListener(Event.ADDED_TO_STAGE, init);
        }
        
        private function init(e:Event = null):void 
        {
            removeEventListener(Event.ADDED_TO_STAGE, init);
            // entry point
            //filters = [new BlurFilter(4,0)];
            offset = [new Point(px += 0.5, 0), new Point( -px / 2, 0), new Point(0, 0)];
            bmpData = new BitmapData(PERLIN_WIDTH, PERLIN_HEIGHT);
            
            sh = new Shape();
            bmd = new BitmapData(465, 465, false, 0x0);
            p = new Point();
            blur = new BlurFilter(8, 8);
            colorTf = new ColorTransform(1, 1, 1, 1, -2, -1, -1);
            addChild(new Bitmap(bmd, "auto", true));
            //addChild(new Stats());
            addEventListener(Event.ENTER_FRAME, loop);
        }
        
        private function loop(e:Event):void {
            Point(offset[0]).x = px += 0.5;
            Point(offset[1]).x = -px / 2;
            bmpData.perlinNoise(PERLIN_WIDTH, PERLIN_HEIGHT, 3, 6456, true, true, 2 | 1, false, offset);
            var g: Graphics = sh.graphics;
            g.clear();
            g.lineStyle(1, 0xFFFFFF, 0.15);
            for (var j:int = 0; j < PERLIN_HEIGHT - 1; j++) { 
                var value1:int = bmpData.getPixel(0, j);
                value1 = value1 >> 16;
                var value2:int = bmpData.getPixel(0 + 1, j);
                value2 = value2 >> 16;
                g.moveTo(0 * WIDTH / (PERLIN_WIDTH -1), value1 + HEIGHT / 2 - 128 + j * 3);
                for (var i:int = 0; i < PERLIN_WIDTH - 1; i++) {
                    
                    value1 = bmpData.getPixel(i, j);
                    value1 = value1 >> 16;
                    value2 = bmpData.getPixel(i + 1, j);
                    value2 = value2 >> 16;
                    g.curveTo(i * WIDTH / (PERLIN_WIDTH - 1), value1 + HEIGHT / 2 -128 + j * 3, (i + 1) * WIDTH / (PERLIN_WIDTH - 1), value2 + HEIGHT / 2 - 128 + j * 3);
                }
            }
            bmd.lock();
            bmd.draw(sh);
            bmd.applyFilter(bmd, bmd.rect, p, blur);
            bmd.colorTransform(bmd.rect, colorTf);
            bmd.unlock();
        }
        
    }
    
}
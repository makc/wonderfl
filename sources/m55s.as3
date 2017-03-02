package
{
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    
    public class Main extends Sprite
    {
        private const FLOOR:int = 0;
        private const WALL:int = 1;
        private const WIDTH:int = 64;
        private const HEIGHT:int = 64;
        private const ITERATIONS:int = 5;
        private var fillProbability:Number = 0.4;
        private var map:Array;
        private var temp:Array;
        private var bd:BitmapData;
        
        public function Main()
        {
            bd = new BitmapData(WIDTH, HEIGHT, false, 0x0);
            var bitmap:Bitmap = new Bitmap(bd);
            bitmap.scaleX = bitmap.scaleY = 7;
            addChild(bitmap);
            
            stage.addEventListener(MouseEvent.CLICK, onMouseClick);
            onMouseClick();
        }
        
        private function onMouseClick(event:MouseEvent = null):void
        {
            initMap();
            for (var i:int = 0; i < ITERATIONS; i++)
            {
                generateMap();
            }
            
            for (var y:int = 0; y < HEIGHT; y++)
            {
                for (var x:int = 0; x < WIDTH; x++)
                {
                    if (map[y][x] == FLOOR) bd.setPixel(x, y, 0xFFFFFF);
                    else bd.setPixel(x, y, 0x0);
                }
            }
        }
        
        private function initMap():void
        {
            map = [];
            temp = [];
            
            for (var y:int = 0; y < HEIGHT; y++)
            {
                map[y] = [];
                for (var x:int = 0; x < WIDTH; x++)
                {
                    map[y][x] = (Math.random() < fillProbability) ? WALL : FLOOR;
                }
            }
            
            for (y = 0; y < HEIGHT; y++)
            {
                temp[y] = [];
                for (x = 0; x < WIDTH; x++)
                {
                    temp[y][x] = WALL;
                }
            }
            
            for (y = 0; y < HEIGHT; y++)
            {
                map[y][0] = map[y][WIDTH - 1] = WALL;
            }
            for (x = 0; x < WIDTH; x++)
            {
                map[0][x] = map[HEIGHT -1][x] = WALL;
            }
        }
        
        private function generateMap():void
        {
            for (var y:int = 1; y < HEIGHT - 1; y++)
            {
                for (var x:int = 1; x < WIDTH - 1; x++)
                {
                    var count3_3:int = 0;
                    var count5_5:int = 0;
                    
                    for (var yy:int = -1; yy <= 1; yy++)
                    {
                        for (var xx:int = -1; xx <= 1; xx++)
                        {
                            if (map[y + yy][x + xx] == WALL)
                            {
                                count3_3++;
                            }
                        }
                    }
                    
                    for (yy = y - 2; yy <= y + 2; yy++)
                    {
                        for (xx = x - 2; xx <= x + 2; xx++)
                        {
                            if (Math.abs(yy - y) == 2 && Math.abs(xx - x) == 2)
                            {
                                continue;
                            }
                            if (yy < 0 || xx < 0 || yy >= HEIGHT || xx >= WIDTH)
                            {
                                continue;
                            }
                            if (map[yy][xx] == WALL)
                            {
                                count5_5++;
                            }
                        }
                    }
                    
                    if (5 <= count3_3 || count5_5 <= 2)
                    {
                        temp[y][x] = WALL;
                    }
                    else
                    {
                        temp[y][x] = FLOOR;
                    }
                }
            }
            
            for (y = 1; y < HEIGHT - 1; y++)
            {
                for (x = 1; x < WIDTH - 1; x++)
                {
                    map[y][x] = temp[y][x];
                }
            }
        }
    }
}
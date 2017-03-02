// forked from greentec's Barnsley Fern
package {
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.geom.Matrix;

    public class FlashTest extends Sprite {
        public var _bitmap:Bitmap;
        public var _bitmapData:BitmapData;
        
        public var centerX:Number = 465 / 2;
        public var centerY:Number = 465;
        public var table:Array = [
            [0,        0,        0,        0.16,    0,         0,        0.01],
            [0.85,    0.04,    -0.04,    0.85,    0,        1.6,    0.85],
            [0.2,    -0.26,    0.23,    0.22,    0,        1.6,    0.07],
            [-0.15,    0.28,    0.26,    0.24,    0,        0.44,    0.07]
        ];
        
        public var cpx:Number;
        public var cpy:Number;
        public var npx:Number;
        public var npy:Number;
        public var _shape:Shape;
        public var _shapeRadius:int = 1;
        public var mat:Matrix;
        public var iter:int = 300000;
        
        public var points:Vector.<Vector.<int>> = new Vector.<Vector.<int>>(465);
        
        public function FlashTest() {
            
            _bitmapData = new BitmapData(465, 465, true, 0xff292929);
            _bitmap = new Bitmap(_bitmapData);
            addChild(_bitmap);
            
            _shape = new Shape();
            _shape.graphics.beginFill(0xffffff);
            _shape.graphics.drawCircle(0, 0, _shapeRadius);
            _shape.graphics.endFill();
            
            cpx = centerX;
            cpy = centerY;
            
            
            var i:int;
            
            //initialize points Vector
            for (i = 0; i < 465; i += 1)
            {
                points[i] = new Vector.<int>(465);
            }
            
            
            var t:int;
            var px:int, py:int;
            
            for (i = 0; i < 50; i += 1) //first 50 points are discarded
            {
                t = getRandomTransform();
                
                npx = cpx * table[t][0] + cpy * table[t][1] + table[t][4];
                npy = cpx * table[t][2] + cpy * table[t][3] + table[t][5];
                
                cpx = npx;
                cpy = npy;
            }
            
            for (i = 0; i < iter; i += 1)
            {
                t = getRandomTransform();
                
                npx = cpx * table[t][0] + cpy * table[t][1] + table[t][4];
                npy = cpx * table[t][2] + cpy * table[t][3] + table[t][5];
                
                cpx = npx;
                cpy = npy;
                
                px = (cpx + 5) * 45;
                py = 465 - cpy * 45;
                
                points[px][py] += 1;
                
               
            }
            
            drawPointVector();
            
            
        }
        
        private function drawPointVector():void
        {
            var i:int;
            var j:int;
            
            var max:int = -1;
            var color:uint;
            var oneColor:uint;
            
            for (i = 0; i < 465; i += 1)
            {
                for (j = 0; j < 465; j += 1)
                {
                    points[i][j] = (points[i][j] != 0 ? Math.log(points[i][j]) : 0);
                    if (max < points[i][j])
                    {
                        max = points[i][j];
                    }
                }
            }
            
            _bitmapData.lock();
            
            for (i = 0; i < 465; i += 1)
            {
                for (j = 0; j < 465; j += 1)
                {
                    oneColor = 255 * points[i][j] / max;
                    color = oneColor << 16 | oneColor << 8 | oneColor;
                    
                    _bitmapData.setPixel(i, j, color);
                }
            }
            
            _bitmapData.unlock();
            
        }
        
        private function getRandomTransform():int
        {
            var randomNumber:Number = Math.random();
            var i:int;
            var row:Array;
            for (i = 0; i < table.length; i += 1)
            {
                if (randomNumber <= table[i][6])
                {
                    return i;
                }
                
                randomNumber -= table[i][6];
            }
            
            return -1;
        }
    }
}
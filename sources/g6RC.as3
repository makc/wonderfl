// forked from greentec's forked from: Barnsley Fern
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
        public var colors:Vector.<Vector.<Number>> = new Vector.<Vector.<Number>>(465);
        
        public var colorMap:Array = [[0, 0.2298057, 0.298717966, 0.753683153], [0.03125, 0.26623388, 0.353094838, 0.801466763], [0.0625, 0.30386891, 0.406535296, 0.84495867], [0.09375, 0.342804478, 0.458757618, 0.883725899], [0.125, 0.38301334, 0.50941904, 0.917387822], [0.15625, 0.424369608, 0.558148092, 0.945619588], [0.1875, 0.46666708, 0.604562568, 0.968154911], [0.21875, 0.509635204, 0.648280772, 0.98478814], [0.25, 0.552953156, 0.688929332, 0.995375608], [0.28125, 0.596262162, 0.726149107, 0.999836203], [0.3125, 0.639176211, 0.759599947, 0.998151185], [0.34375, 0.681291281, 0.788964712, 0.990363227], [0.375, 0.722193294, 0.813952739, 0.976574709], [0.40625, 0.761464949, 0.834302879, 0.956945269], [0.4375, 0.798691636, 0.849786142, 0.931688648], [0.46875, 0.833466556, 0.860207984, 0.901068838], [0.5, 0.865395197, 0.86541021, 0.865395561], [0.53125, 0.897787179, 0.848937047, 0.820880546], [0.5625, 0.924127593, 0.827384882, 0.774508472], [0.59375, 0.944468518, 0.800927443, 0.726736146], [0.625, 0.958852946, 0.769767752, 0.678007945], [0.65625, 0.96732803, 0.734132809, 0.628751763], [0.6875, 0.969954137, 0.694266682, 0.579375448], [0.71875, 0.966811177, 0.650421156, 0.530263762], [0.75, 0.958003065, 0.602842431, 0.481775914], [0.78125, 0.943660866, 0.551750968, 0.434243684], [0.8125, 0.923944917, 0.49730856, 0.387970225], [0.84375, 0.89904617, 0.439559467, 0.343229596], [0.875, 0.869186849, 0.378313092, 0.300267182], [0.90625, 0.834620542, 0.312874446, 0.259301199], [0.9375, 0.795631745, 0.24128379, 0.220525627], [0.96875, 0.752534934, 0.157246067, 0.184115123], [1, 0.705673158, 0.01555616, 0.150232812]];

        
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
                colors[i] = new Vector.<Number>(465);
            }
            
            
            var t:int;
            var px:int, py:int;
            var r:Number;
            var color:Number = Math.random();
            
            for (i = 0; i < 50; i += 1) //first 50 points are discarded
            {
                t = getRandomTransform();
                
                npx = cpx * table[t][0] + cpy * table[t][1] + table[t][4];
                npy = cpx * table[t][2] + cpy * table[t][3] + table[t][5];
                
                //r = 1 / Math.sqrt(npx * npx + npy * npy);
                
                cpx = npx;
                cpy = npy;
                
                //cpx = npx * r;
                //cpy = npy * r;
                
                //cpx = Math.sin(npx);
                //cpy = Math.sin(npy);
            }
            
            for (i = 0; i < iter; i += 1)
            {
                t = getRandomTransform();
                
                npx = cpx * table[t][0] + cpy * table[t][1] + table[t][4];
                npy = cpx * table[t][2] + cpy * table[t][3] + table[t][5];
                color = (color * table[t][0] + color * table[t][1] + table[t][4] + color * table[t][2] + color * table[t][3] + table[t][5]) / 2;
                
                //r = 1 / Math.sqrt(npx * npx + npy * npy);
                
                cpx = npx;
                cpy = npy;
                
                //cpx = npx * r;
                //cpy = npy * r;
                
                //cpx = Math.sin(npx);
                //cpy = Math.sin(npy);
                
                px = (cpx + 5) * 45;
                py = 465 - cpy * 45;
                
                if(px >= 0 && px < 465 && py >= 0 && py < 465)
                    points[px][py] += 1;
                    colors[px][py] = (colors[px][py] + color) / 2;
                
               
            }
            
            drawPointVector();
        }
        
        private function drawPointVector():void
        {
            var i:int;
            var j:int;
            
            var max:int = -1;
            var min:int = int.MAX_VALUE;
            var color:uint;
            //var oneColor:uint;
            var scalar:Number;
            var s:int;
            var r:uint;
            var g:uint;
            var b:uint;
            var len:int;
            
            for (i = 0; i < 465; i += 1)
            {
                for (j = 0; j < 465; j += 1)
                {
                    //points[i][j] = (points[i][j] != 0 ? Math.log(points[i][j]) : 0);
                    points[i][j] = (points[i][j] != 0 ? Math.log(points[i][j]) : 0);
                    //if (max < points[i][j])
                    //{
                        //max = points[i][j];
                    //}
                    if (max < colors[i][j])
                    {
                        max = colors[i][j];
                    }
                    if (min > colors[i][j])
                    {
                        min = colors[i][j];
                    }
                }
            }
            
            _bitmapData.lock();
            
            len = colorMap.length;
            
            for (i = 0; i < 465; i += 1)
            {
                for (j = 0; j < 465; j += 1)
                {
                    if (points[i][j] != 0)
                    {
                        //oneColor = 255 * points[i][j] / max;
                        //color = oneColor << 16 | oneColor << 8 | oneColor;
                        
                        //scalar = points[i][j] / max * 1.0;
                        scalar = colors[i][j] / Math.abs(max-min) * 1.0;
                        for (s = 0; s < len; s += 1)
                        {
                            if (colorMap[s][0] > scalar)
                            {
                                break;
                            }
                        }
                        
                        s -= 1;
                        
                        r = colorMap[s][1] * 255;
                        g = colorMap[s][2] * 255;
                        b = colorMap[s][3] * 255;
                        
                        
                        //r = (points[i][j] / max * Math.abs(colorMap[0][0] - colorMap[1][0]) + colorMap[0][0]) * 255;
                        //g = (points[i][j] / max * Math.abs(colorMap[0][1] - colorMap[1][1]) + colorMap[0][1]) * 255;
                        //b = (points[i][j] / max * Math.abs(colorMap[0][2] - colorMap[1][2]) + colorMap[0][2]) * 255;
                        
                        color = r << 16 | g << 8 | b;
                        
                        _bitmapData.setPixel(i, j, color);
                    }
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
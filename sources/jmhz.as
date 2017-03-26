package  
{
    import flash.events.MouseEvent;
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.geom.Rectangle;
    import flash.display.StageScaleMode;
    import flash.display.StageAlign;
    import flash.events.Event;
    import flash.display.Sprite;

    [SWF(backgroundColor = '0x00', width = '465', height = '465', frameRate=60)]
    
    //http://softologyblog.wordpress.com/2011/07/05/multi-scale-turing-patterns/

    /**
     * @author simoe
     */
     
    public class TuringPattern extends Sprite
    {
        private const WIDTH : Number = stage.stageWidth;
        private const HEIGHT : Number = stage.stageHeight;

        private var _grids : Vector.<Number>;
        private var _diffLeft : Vector.<Number>;
        private var _diffRight : Vector.<Number>;
        private var _blurBuffer : Vector.<Number>;
        private var _variations : Vector.<Number>;
        private var _bestVariation : Vector.<Number>;
        private var _bestLevel : Vector.<int>;
        private var _directions : Vector.<Boolean>;
        private var _stepSizes : Vector.<Number>;
        private var _radii : Vector.<Number>;

        private var n : Number;
        private var levels : Number;

        private var _bmpData : BitmapData;
        private var _bmp : Bitmap;
        private var _firstPixel : Particle3D;

        public function TuringPattern() : void
        {
            if (stage)
            {
                initStage(null);
                stage.removeEventListener(Event.ADDED_TO_STAGE, initStage);            
            } 
            else 
            {
                throw new Error("Stage not active");
                stage.addEventListener(Event.ADDED_TO_STAGE, initStage);
            }
        }

        private function initStage(event : Event) : void
        {
            stage.removeEventListener(Event.ADDED_TO_STAGE, initStage);
            stage.align = StageAlign.TOP_LEFT;
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.quality = "medium";
            stage.fullScreenSourceRect = new Rectangle(0, 0, 1024, 768);
            
            var base : Number = random(1.5, 2.4);
            var stepScale : Number = random(.005, .06);
            var stepOffset : Number = random(.0001, .02);
            
            n = WIDTH * HEIGHT;
            levels = int(Math.log(WIDTH) / Math.log(base));
            trace(levels);
            _radii = new Vector.<Number>(levels, true);
            _stepSizes = new Vector.<Number>(levels, true);
            _grids = new Vector.<Number>(n, true);
            _diffLeft = new Vector.<Number>(n, true);
            _diffRight = new Vector.<Number>(n, true);
            _blurBuffer = new Vector.<Number>(n, true);
            _bestLevel = new Vector.<int>(n, true);
            _variations = new Vector.<Number>(n, true);
            _bestVariation = new Vector.<Number>(n, true);
            _directions = new Vector.<Boolean>(n, true);
            
            _bmpData = new BitmapData(WIDTH, HEIGHT, false, 0x000000);
            _bmp = new Bitmap(_bmpData);
            addChild(_bmp);
            
            //determines the shape of the pattern
            for (var i : int = 0;i < levels;i++)
            {
                var radius : int = int(Math.pow(base, i));
                _radii[i] = radius;
                _stepSizes[i] = Math.log(radius) * stepScale + stepOffset;
            }
            
            //initialise the grid with random point between -1 and +1
            for (i = 0;i < n;i++)
            {
                _grids[i] = random(-1, 1);
            }
            getPixels();
            addEventListener(Event.ENTER_FRAME, update);
            stage.addEventListener(MouseEvent.CLICK, click);
        }

        private function step() : void
        {
            var activator : Vector.<Number> = _grids;
            var inhibitor : Vector.<Number> = _diffRight;
            
            for (var l : Number = 0;l < levels - 1;l++)
            {
                var radius : int = int(_radii[l]);
                fastBlur(activator, inhibitor, _blurBuffer, WIDTH, HEIGHT, radius);
                
                //calculates the absolute difference between activator and inhibitor

                for (var i : int = 0;i < n;i++)
                {
                    _variations[i] = activator[i] - inhibitor[i];
                    if(_variations[i] < 0)
                    {
                        _variations[i] = -_variations[i];
                    }
                }
                
                //if first level then set some initial values for bestLevel and bestVariation 
                if (l == 0)
                {
                    for (i = 0;i < n;i++)
                    {
                        _bestVariation[i] = _variations[i];
                        _bestLevel[i] = l;
                        _directions[i] = activator[i] > inhibitor[i];
                    }
                    activator = _diffRight;
                    inhibitor = _diffLeft;
                } 
                else 
                {
                    for (i = 0;i < n;i++)
                    {
                        if (_variations[i] < _bestVariation[i])
                        {
                            _bestVariation[i] = _variations[i];
                            _bestLevel[i] = l;
                            _directions[i] = activator[i] > inhibitor[i];
                        }
                    }
                    var swap : Vector.<Number> = activator;
                    activator = inhibitor;
                    inhibitor = swap;
                }
            }
            
            var smallest : Number = Infinity;
            var largest : Number = -Infinity;
            for (i = 0;i < n;i++)
            {
                var curStep : Number = _stepSizes[_bestLevel[i]];
                if (_directions[i])
                {
                    _grids[i] += curStep;
                } 
                else 
                {
                    _grids[i] -= curStep;
                }
                smallest = Math.min(smallest, _grids[i]);
                largest = Math.max(largest, _grids[i]);
            }
            var range : Number = (largest - smallest) / 2;
            for (i = 0;i < n;i++)
            {
                _grids[i] = ((_grids[i] - smallest) / range) - 1;
            }
        }

        private function click(event : MouseEvent) : void
        {
            var i : int;
            for (i = 0;i < n;i++)
            {
                _grids[i] = random(-1, 1);
                _diffLeft[i] = undefined;
                _diffRight[i] = undefined;
                _blurBuffer[i] = undefined;
                _bestLevel[i] = undefined;
                _variations[i] = undefined;
                _bestVariation[i] = undefined;
                _directions[i] = undefined;
            }
        }

        private function update(event : Event) : void
        {
            var p : Particle3D = _firstPixel;
            var i : int = 0;
            step();
            _bmpData.lock();
            do 
            {
                var color : uint = (int(0xff >> 1) + ((int(0xff >> 1) * _grids[i++])));
                _bmpData.setPixel(p.x, p.y, color << 16 | color << 8 | color);
                p = p.next;
            } while (p != null);
            _bmpData.unlock();
        }

        
        
        private function random(min : Number, max : Number = NaN) : Number
        {
            if (isNaN(max))
            {
                max = min;
                min = 0;
            }
            return Math.random() * (max - min) + min;
        }

        private function getPixels() : void
        {
            var x : Number;
            var y : Number;
            var prevPixel : Particle3D;
            
            _bmpData.lock();
            for (x = 0;x < WIDTH;x++) 
            {
                for (y = 0;y < HEIGHT;y++) 
                {
                    var color : uint = _bmpData.getPixel(x, y);
                    var pixel : Particle3D = new Particle3D(color);
                    pixel.x = x; 
                    pixel.y = y;
                    
                    pixel.next = prevPixel;
                    prevPixel = pixel;
                }
            }
            _firstPixel = pixel;
            _bmpData.unlock();
        }

        /*
         * Blur the image using sequential two step bluring technique
         * First blur the image vertically then horizontally.   
         */

        private function fastBlur(source : Vector.<Number>, dest : Vector.<Number>, buffer : Vector.<Number>, 
                                  w : Number, h : Number, radius : Number) : void
        {
            var y : int;
            var x : int;
            for (y = 0;y < h;y++)
            {
                for (x = 0;x < w;x++)
                {
                    var i : int = y * w + x;
                    if(y == 0 && x == 0)
                    {
                        buffer[i] = source[i];
                    } else if (y == 0)
                    {
                        buffer[i] = buffer[i - 1] + source[i];
                    } else if (x == 0)
                    {
                        buffer[i] = buffer[i - w] + source[i];
                    } 
                    else
                    {
                        buffer[i] = buffer[i - 1] + buffer[i - w] - buffer[i - w - 1] + source[i];
                    }
                }
            }
            
            for (y = 0;y < h;y++)
            {
                for (x = 0;x < w;x++)
                {
                    var minx : int = Math.max(0, x - radius);
                    var maxx : int = Math.min(x + radius, w - 1);
                    var miny : int = Math.max(0, y - radius);
                    var maxy : int = Math.min(y + radius, h - 1);
                    var area : int = (maxx - minx) * (maxy - miny);
                    
                    var nw : int = miny * w + minx;
                    var ne : int = miny * w + maxx;
                    var sw : int = maxy * w + minx;
                    var se : int = maxy * w + maxx;
                    
                    var n : int = y * w + x;
                    dest[n] = (buffer[se] - buffer[sw] - buffer[ne] + buffer[nw]) / area; 
                }
            }
        }
    }
}

internal class Point3D
{
    public var x : Number;
    public var y : Number;
    public var z : Number;

    public function Point3D(x : Number = 0, y : Number = 0, z : Number = 0) : void
    {
        this.x = x;
        this.y = y;
        this.z = z;
    }
}

internal class Particle3D extends Point3D
{
    public var red : uint;
    public var green : uint;
    public var blue : uint;
    public var color : uint;

    public var projX : Number;
    public var projY : Number;

    public var u : Number;
    public var v : Number;
    public var w : Number;

    public var next : Particle3D;
    public var onScreen : Boolean;

    public function Particle3D(color : uint = 0xFFFFFF) : void
    {
        this.color = color;
        this.red = getRed(color);
        this.green = getGreen(color);
        this.blue = getBlue(color);
    }

    public function getRed(c : uint) : uint
    {
        return c >> 16 & 0xff;
    }

    public function getGreen(c : uint) : uint
    {
        return c >> 0
        8 & 0xff;
    }

    public function getBlue(c : uint) : uint
    {
        return c >> 00 & 0xff;
    }
}

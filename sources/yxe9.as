package
{
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Graphics;
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.filters.BlurFilter;
    import flash.geom.ColorTransform;
    import flash.geom.Point;
    import flash.utils.getTimer;
    
    import net.hires.debug.Stats;

    [SW(width="400", height="400", frameRate="24", backgroundColor="0xFFFFFF")]
    public class LiquidTest extends Sprite
    {
        private var particles:Vector.<Particle> = new Vector.<Particle>();
        
        private var gsizeX:int = 100;
        private var gsizeY:int = 100;

        private var grid:Vector.<Vector.<Node>>;
        private var active:Vector.<Node> = new Vector.<Node>();
        private var g:Graphics;
        private var water:Material = new Material(1.0, 1.0, 1.0, 1.0, 1.0, 1.0);
        private var pressed:Boolean;
        private var pressedprev:Boolean;

        private var mx:int;
        private var my:int;
        private var mxprev:int;
        private var myprev:int;

        private var _canvas:BitmapData;
        private var _blur:BlurFilter = new BlurFilter();
        private var _color:ColorTransform = new ColorTransform(1.1, 1.1, 1.1);
        private var _g:Graphics;
        private var _s:Shape;
        private var _o:Point = new Point(0, 0);

        public function LiquidTest()
        {
            addEventListener(Event.ADDED_TO_STAGE, init);
        }

        public function init(event:Event):void
        {
            
            _canvas = new BitmapData(400, 400, false, 0xFFFFFF);
            var _bitmap:Bitmap = addChild(new Bitmap(this._canvas)) as Bitmap;

            _s = new Shape();
            _g = _s.graphics;

            var i:int, j:int;
            grid = new Vector.<Vector.<Node>>(gsizeX, true);
            for (i = 0; i < gsizeX; i++)
            {
                grid[i] = new Vector.<Node>(gsizeY, true);
                for (j = 0; j < gsizeY; j++)
                {
                    grid[i][j] = new Node();
                }
            }

            stage.addEventListener(Event.ENTER_FRAME, paint);

            stage.addEventListener(MouseEvent.MOUSE_DOWN, mousePressed);
            stage.addEventListener(MouseEvent.MOUSE_UP, mouseReleased);
            stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoved);

            var p:Particle;
            for (i = 0; i < 50; i++)
                for (j = 0; j < 30; j++)
                {
                    p = new Particle(water, i + 4, j + 4, 0.0, 0.0);
                    particles.push(p);
                }
            
            
            addChild(new Stats());
        }

        public function paint(event:Event):void
        {
            _canvas.colorTransform(_canvas.rect, _color);

            simulate();
            _canvas.lock();
            for each (var p:Particle in particles)
            {
                _canvas.setPixel32(int(4.0 * p.x), int(4.0 * p.y), 0x22000088);
                _canvas.setPixel32(int(4.0 * (p.x - p.u)), int(4.0 * (p.y - p.v)), 0x440000FF);
            }

            _canvas.draw(_s);
            _canvas.applyFilter(_canvas, _canvas.rect, _o, _blur);
            _canvas.unlock();
        }

        public function mouseMoved(event:MouseEvent):void
        {
            mx = event.localX;
            my = event.localY;
        }

        public function mousePressed(event:MouseEvent):void
        {
            pressed = true;
        }

        public function mouseReleased(event:MouseEvent):void
        {
            pressed = false;
        }

        public function simulate():void
        {
            var drag:Boolean = false;
            var mdx:Number = 0.0, mdy:Number = 0.0;
            if (pressed && pressedprev)
            {
                drag = true;
                mdx = 0.25 * (mx - mxprev);
                mdy = 0.25 * (my - myprev);
            }

            pressedprev = pressed;
            mxprev = mx;
            myprev = my;

            var n:Node, p:Particle;
            for each (n in active)
                n.clear();
            active.length = 0;

            var i:int, j:int;
            var x:Number, y:Number, phi:Number;
            var fx:Number = 0.0, fy:Number = 0.0;
            for each (p in particles)
            {
                p.cx = int(p.x - 0.5);
                p.cy = int(p.y - 0.5);

                x = p.cx - p.x;
                p.px[0] = (0.5 * x * x + 1.5 * x + 1.125);
                p.gx[0] = (x + 1.5);
                x += 1.0;
                p.px[1] = (-x * x + 0.75);
                p.gx[1] = (-2.0 * x);
                x += 1.0;
                p.px[2] = (0.5 * x * x - 1.5 * x + 1.125);
                p.gx[2] = (x - 1.5);

                y = p.cy - p.y;
                p.py[0] = (0.5 * y * y + 1.5 * y + 1.125);
                p.gy[0] = (y + 1.5);
                y += 1.0;
                p.py[1] = (-y * y + 0.75);
                p.gy[1] = (-2.0 * y);
                y += 1.0;
                p.py[2] = (0.5 * y * y - 1.5 * y + 1.125);
                p.gy[2] = (y - 1.5);

                for (i = 0; i < 3; i++)
                {
                    for (j = 0; j < 3; j++)
                    {
                        n = grid[p.cx + i][p.cy + j];
                        if (!n.active)
                        {
                            active.push(n);
                            n.active = true;
                        }
                        phi = p.px[i] * p.py[j];
                        n.m += phi * p.mat.m;
                        n.d += phi;
                        n.gx += p.gx[i] * p.py[j];
                        n.gy += p.px[i] * p.gy[j];
                    }
                }
            }

            var density:Number, pressure:Number, weight:Number;
            var n01:Node, n02:Node;
            var n11:Node, n12:Node;
            var cx:int, cy:int;
            var cxi:int, cyi:int;

            var pdx:Number, pdy:Number;
            var C20:Number, C02:Number, C30:Number, C03:Number;
            var csum1:Number, csum2:Number;
            var C21:Number, C31:Number, C12:Number, C13:Number, C11:Number;

            var u:Number, u2:Number, u3:Number;
            var v:Number, v2:Number, v3:Number;

            for each (p in particles)
            {
                cx = int(p.x);
                cy = int(p.y);
                cxi = cx + 1;
                cyi = cy + 1;

                n01 = grid[cx][cy];
                n02 = grid[cx][cyi];
                n11 = grid[cxi][cy];
                n12 = grid[cxi][cyi];

                pdx = n11.d - n01.d;
                pdy = n02.d - n01.d;
                C20 = 3.0 * pdx - n11.gx - 2.0 * n01.gx;
                C02 = 3.0 * pdy - n02.gy - 2.0 * n01.gy;
                C30 = -2.0 * pdx + n11.gx + n01.gx;
                C03 = -2.0 * pdy + n02.gy + n01.gy;
                csum1 = n01.d + n01.gy + C02 + C03;
                csum2 = n01.d + n01.gx + C20 + C30;
                C21 = 3.0 * n12.d - 2.0 * n02.gx - n12.gx - 3.0 * csum1 - C20;
                C31 = -2.0 * n12.d + n02.gx + n12.gx + 2.0 * csum1 - C30;
                C12 = 3.0 * n12.d - 2.0 * n11.gy - n12.gy - 3.0 * csum2 - C02;
                C13 = -2.0 * n12.d + n11.gy + n12.gy + 2.0 * csum2 - C03;
                C11 = n02.gx - C13 - C12 - n01.gx;

                u = p.x - cx;
                u2 = u * u;
                u3 = u * u2;
                v = p.y - cy;
                v2 = v * v;
                v3 = v * v2;
                density = n01.d + n01.gx * u + n01.gy * v + C20 * u2 + C02 * v2 + C30 * u3 + C03 * v3 + C21 * u2 * v + C31 * u3 * v + C12 * u * v2 + C13 * u * v3 + C11 * u * v;

                pressure = density - 1.0;
                if (pressure > 2.0)
                    pressure = 2.0;

                fx = 0.0;
                fy = 0.0;

                if (p.x < 4.0)
                    fx += p.mat.m * (4.0 - p.x);
                else if (p.x > gsizeX - 5)
                    fx += p.mat.m * (gsizeX - 5 - p.x);

                if (p.y < 4.0)
                    fy += p.mat.m * (4.0 - p.y);
                else if (p.y > gsizeY - 5)
                    fy += p.mat.m * (gsizeY - 5 - p.y);

                if (drag)
                {
                    var vx:Number = Math.abs(p.x - 0.25 * mx);
                    var vy:Number = Math.abs(p.y - 0.25 * my);
                    if ((vx < 10.0) && (vy < 10.0))
                    {
                        weight = p.mat.m * (1.0 - vx * 0.10) * (1.0 - vy * 0.10);
                        fx += weight * (mdx - p.u);
                        fy += weight * (mdy - p.v);
                    }
                }

                for (i = 0; i < 3; i++)
                {
                    for (j = 0; j < 3; j++)
                    {
                        n = grid[(p.cx + i)][(p.cy + j)];
                        phi = p.px[i] * p.py[j];
                        n.ax += -((p.gx[i] * p.py[j]) * pressure) + fx * phi;
                        n.ay += -((p.px[i] * p.gy[j]) * pressure) + fy * phi;
                    }
                }
            }

            for each (n in active)
            {
                if (n.m > 0.0)
                {
                    n.ax /= n.m;
                    n.ay /= n.m;
                    n.ay += 0.03;
                }
            }

            var mu:Number, mv:Number;
            for each (p in particles)
            {
                for (i = 0; i < 3; i++)
                {
                    for (j = 0; j < 3; j++)
                    {
                        n = grid[(p.cx + i)][(p.cy + j)];
                        phi = p.px[i] * p.py[j];
                        p.u += phi * n.ax;
                        p.v += phi * n.ay;
                    }
                }
                mu = p.mat.m * p.u;
                mv = p.mat.m * p.v;
                for (i = 0; i < 3; i++)
                {
                    for (j = 0; j < 3; j++)
                    {
                        n = grid[(p.cx + i)][(p.cy + j)];
                        phi = p.px[i] * p.py[j];
                        n.u += phi * mu;
                        n.v += phi * mv;
                    }
                }
            }

            for each (n in active)
            {
                if (n.m > 0.0)
                {
                    n.u /= n.m;
                    n.v /= n.m;
                }
            }

            var gu:Number, gv:Number;
            for each (p in particles)
            {
                gu = 0.0;
                gv = 0.0;
                for (i = 0; i < 3; i++)
                {
                    for (j = 0; j < 3; j++)
                    {
                        n = grid[(p.cx + i)][(p.cy + j)];
                        phi = p.px[i] * p.py[j];
                        gu += phi * n.u;
                        gv += phi * n.v;
                    }
                }
                p.x += gu;
                p.y += gv;
                p.u += 1.0 * (gu - p.u);
                p.v += 1.0 * (gv - p.v);
                if (p.x < 1.0)
                {
                    p.x = (1.0 + Math.random() * 0.01);
                    p.u = 0.0;
                }
                else if (p.x > gsizeX - 2)
                {
                    p.x = (gsizeX - 2 - Math.random() * 0.01);
                    p.u = 0.0;
                }
                if (p.y < 1.0)
                {
                    p.y = (1.0 + Math.random() * 0.01);
                    p.v = 0.0;
                }
                else if (p.y > gsizeY - 2)
                {
                    p.y = (gsizeY - 2 - Math.random() * 0.01);
                    p.v = 0.0;
                }
            }
        }
    }
}

class Node
{
    public var m:Number = 0;
    public var d:Number = 0;
    public var gx:Number = 0;
    public var gy:Number = 0;
    public var u:Number = 0;
    public var v:Number = 0;
    public var ax:Number = 0;
    public var ay:Number = 0;
    public var active:Boolean;
    
    public function clear():void
    {
        m = d = gx = gy = u = v = ax = ay = 0.0;
        active = false;
    }
}

class Particle
{
    public var mat:Material;
    public var x:Number;
    public var y:Number;
    public var u:Number;
    public var v:Number;
    public var dudx:Number = 0;
    public var dudy:Number = 0;
    public var dvdx:Number = 0;
    public var dvdy:Number = 0;
    public var cx:int;
    public var cy:int;
    public var px:Vector.<Number> = new Vector.<Number>(3, true);
    public var py:Vector.<Number> = new Vector.<Number>(3, true);
    public var gx:Vector.<Number> = new Vector.<Number>(3, true);
    public var gy:Vector.<Number> = new Vector.<Number>(3, true);
    
    public function Particle(mat:Material, x:Number, y:Number, u:Number, v:Number)
    {
        this.mat = mat;
        this.x = x;
        this.y = y;
        this.u = u;
        this.v = v;
    }
}

class Material
{
    public var m:Number;
    public var rd:Number;
    public var k:Number;
    public var v:Number;
    public var d:Number;
    public var g:Number;
    
    public function Material(m:Number, rd:Number, k:Number, v:Number, d:Number, g:Number)
    {
        this.m = m;
        this.rd = rd;
        this.k = k;
        this.v = v;
        this.d = d;
        this.g = g;
    }
}
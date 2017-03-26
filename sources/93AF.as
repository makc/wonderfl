package
{
    import flash.display.Shape;
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.BlendMode;
    import flash.display.DisplayObject;
    import flash.display.PixelSnapping;
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.events.Event;

    /**
     * 流体のプラクティスです。
     * ボートの推進力、風、マウスによって流体マップの速度と密度が操作されます。
     * アルゴリズムは以下の論文のものをそのまま使いました。
     * http://www.dgp.toronto.edu/people/stam/reality/Research/pdf/GDC03.pdf
     * 
     * @author imajuk
     */
    public class PaperBoat extends Sprite
    {
        private static const SIZE : int = 465;
        private var fluid : Fluid;
        private var vectorView : IFluidView;
        private var densityView : IFluidView;
        private var wind : Wind;
        private var boats : Boats;
        
        public function PaperBoat()
        {
            //Wonderfl.capture_delay(20);
            
            //=================================
            // stage setting
            //=================================
            stage.align = StageAlign.TOP_LEFT;
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.frameRate = 60;
            
            var shape:Shape = new Shape();
            shape.cacheAsBitmap = true;
            shape.graphics.beginFill(0);
            shape.graphics.drawRect(0, 0, SIZE, SIZE);
            mask = shape;
            
            //=================================
            // the grid size of fluid
            //=================================
            var fluidSize : uint = 50;

            //=================================
            // canvas
            //=================================
            var canvasSize : int = fluidSize + 2;
            
            //for visualize density field
            var canvas_density:BitmapData = new BitmapData(canvasSize, canvasSize, false);
            var bmp:DisplayObject = addChild(new Bitmap(canvas_density, PixelSnapping.NEVER, false));
            bmp.width = bmp.height = SIZE;
            
            //for visualize vector field
            var canvas_vector:BitmapData = new BitmapData(SIZE, SIZE, true, 0);
            addChild(new Bitmap(canvas_vector, PixelSnapping.NEVER, false)).blendMode = BlendMode.ADD;

            //=================================
            // fluid
            //=================================
            fluid = new Fluid(fluidSize);
            
            //=================================
            // mouse interaction
            //=================================
            new MouseInteraction(
                /**
                 * callback
                 * @param fx    x coordinates in fluid
                 * @param fy    y coordinates in fluid
                 * @param vx    velocity x
                 * @param vy    velocity y
                 */
                function(fx : int, fy : int, vx : Number, vy : Number) : void
                {
                    if (fx > fluidSize || fy > fluidSize) return;
                    // add force and density in fluid
                    var i : int = fluid._ix[fx][fy];
                    fluid.dens_prev[i] += Math.min(10, Math.sqrt(vx * vx + vy * vy));
                    fluid.u_prev[i]    += vx * 20;
                    fluid.v_prev[i]    += vy * 20;
                }, 
                stage, 
                fluidSize / SIZE
            );
                
            //=================================
            // rendering objects
            //=================================
            densityView = new DensityView(canvas_density);
            vectorView  = new VectorView(canvas_vector, canvas_vector.width / canvasSize); 
            
            //=================================
            // objects giving influence to fluid
            //=================================
            wind  = new Wind(fluid);
            boats = new Boats(fluid, this, SIZE, 10);
            
            //=================================
            // start main loop
            //=================================
            addEventListener(Event.ENTER_FRAME, enterFrameHandler);
        }
        
        /**
         * main loop
         */
        private function enterFrameHandler(event : Event) : void
        {
            //start to draw density and vector field in canvas
            vectorView.prepare();
            densityView.prepare();
            
            //=================================
            // iterate all cells of the fluid 
            //=================================
            const size : int = fluid.gridSize;
            var i:int, cx : int, cy : int;
            var dens : Number, vx:Number, vy:Number;
            while (cy < size)
            {
                while (cx < size)
                {
                    //sample density and velocity from fluid
                    vx   = fluid.u[i];
                    vy   = fluid.v[i];
                    dens = fluid.dens[i];
                    
                    //add velocity as wind to fluid
                    wind.oparate(cx, cy, i);
                    
                    //draw to canvas
                    vectorView.draw(cx, cy, vx, vy, dens);
                    densityView.draw(cx, cy, vx, vy, dens);
                    
                    i ++;
                    cx ++;
                }
                cx = 0;
                cy ++;
            }
            
            // finishing to draw
            vectorView.tearDown();
            densityView.tearDown();
            
            wind.update();
            boats.update();
            fluid.update();
        }
    }
}

import fl.motion.easing.Linear;

import flash.display.BitmapData;
import flash.display.Shape;
import flash.display.Sprite;
import flash.display.Stage;
import flash.events.MouseEvent;
import flash.filters.BlurFilter;
import flash.filters.DropShadowFilter;
import flash.geom.Point;
import flash.geom.Rectangle;

class MouseInteraction 
{
    private var callBack : Function;
    private var scale : Number;
    /**
     * previous mouse position (px, py)
     */
    private var px : Number = 0;
    private var py : Number = 0;

    public function MouseInteraction(callBack : Function, target:Stage, scale:Number) 
    {
        this.scale = scale;
        this.callBack = callBack;
        target.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
    }

    private function onMouseMove(e : MouseEvent) : void 
    {
        var x : Number = e.localX * scale;
        var y : Number = e.localY * scale;
        
        callBack(x, y, x - px, y - py);
        
        px = x;
        py = y;
    }
}

class Boats
{
    private var timeline : Sprite;
    private var ship : Vector.<Boat> = new Vector.<Boat>();
    private var fluid : Fluid;
    private var size : int;
    private var scale : Number;

    public function Boats(fluid : Fluid, timeline : Sprite, size:int, amount:int)
    {
        this.timeline = timeline;
        this.fluid = fluid;
        this.size = size;
        this.scale = fluid.gridSize / size;

        for (var i : int = 0; i < amount; i++)
        {
            var speed : Number = Linear.easeNone(i, 2.5, 4.5, amount);
            var dexterity : Number = Math.random() * .03 + .01;
            ship.push(timeline.addChild(new Boat(speed, dexterity)) as Boat);
        }
        
        ship.forEach(function(s : Boat, ...param) : void
        {
            s.x = Math.random() * size;
            s.y = Math.random() * size;
        });
    }

    public function update() : void
    {
        ship.forEach(function(s:Boat, ...param) : void
        {
            //=================================
            // add force and density caused by ship's movement to fluid 
            //=================================
            var ix : int = s.x * scale;
            var iy : int = s.y * scale;
            var i  : int = fluid._ix[ix][iy];
            fluid.u_prev[i]    += s.vx * -.3;
            fluid.v_prev[i]    += s.vy * -.3;
            fluid.dens_prev[i] += .5;
            
            //=================================
            // update ship's rotation
            //=================================
            var angle  : Number = s.angle;
            var target : Number = Math.atan2(timeline.mouseY - s.y, timeline.mouseX - s.x);
            var diff   : Number = MathUtil.getAngleDiff(angle, target);
            s.angle += diff * s.dexterity;
            
            //=================================
            // update ship's vector
            //=================================
            s.vx = Math.cos(angle) * s.speed;
            s.vy = Math.sin(angle) * s.speed;
            
            //=================================
            // update ship's position
            //=================================
            s.x += s.vx + fluid.u[i] * 50;
            s.y += s.vy + fluid.v[i] * 50;
            
            s.x = (s.x < 0) ? 0 : s.x;
            s.x = (s.x >= size) ? size-1 : s.x;
            s.y = (s.y < 0) ? 0 : s.y;
            s.y = (s.y >= size) ?size-1 : s.y;
        });
    }
}

class Boat extends Shape
{
    public var vx : Number = .01;
    public var vy : Number = 0;
    public var speed : Number;
    public var dexterity : Number;

    public function Boat(speed : Number, k : Number)
    {
        this.speed = speed;
        this.dexterity = k;
        
        graphics.clear();
        graphics.beginFill(0x0000FF, .6);
        graphics.drawEllipse(-5, -3, 12, 6);
        graphics.beginFill(0xFFFFFF, 1);
        graphics.drawEllipse(-5, -2, 10, 4);
        graphics.beginFill(0x0000FF, .5);
        graphics.drawEllipse(-5, -1.5, 6, 3);
        graphics.beginFill(0x33CC00);
        graphics.drawEllipse(-6, -1.5, 5, 3);

        filters = [new DropShadowFilter(2, 30, 0, .3, 4, 4)];
    }

    public function get angle() : Number
    {
        return MathUtil.degreesToRadians(rotation);
    }

    public function set angle(radians : Number) : void
    {
        rotation = MathUtil.radiansToDegrees(radians);
    }
}

interface IFluidView
{
    function prepare() : void;

    function draw(cx:int, cy:int, vx : Number, vy : Number, dens : Number) : void;

    function tearDown() : void;
}

class DensityView implements IFluidView
{
    private static const POINT : Point = new Point();
    private var canvas : BitmapData;
    private var blur : BlurFilter;
    private var rect : Rectangle;

    public function DensityView(canvas : BitmapData)
    {
        this.canvas = canvas;
        this.blur = new BlurFilter(4, 4, 4);
        this.rect = canvas.rect;
    }

    public function prepare() : void
    {
        canvas.lock();
    }
    
    public function tearDown() : void
    {
        canvas.applyFilter(canvas, rect, POINT, blur);
        canvas.unlock();
    }
    
    public function draw(cx:int, cy:int, vx : Number, vy : Number, dens:Number) : void
    {
        //=================================
        // convert density value to pixels (0x1111FF ~ 0xEEEEFF)
        //=================================
        var v : int = 0xFF - dens * 0xFF;
        v = (v < 0x11) ? 0x11 : v;
        v = (v > 0xEE) ? 0xEE : v;
        canvas.setPixel(cx, cy, uint(v << 16 | v << 8 | 0xFF));
    }
}

class VectorView implements IFluidView
{
    private var canvas : BitmapData;
    private var scale : Number;
    private var rect : Rectangle;

    public function VectorView(canvas : BitmapData, scale:Number)
    {
        this.canvas = canvas;
        this.scale = scale;
        this.rect = canvas.rect;
    }
    
    public function prepare() : void
    {
        canvas.lock();
        canvas.fillRect(rect, 0);
    }
    
    public function tearDown() : void
    {
        canvas.unlock();
    }
    
    public function draw(cx:int, cy:int, vx : Number, vy : Number, dens:Number) : void
    {
        //=================================
        // draw vector
        //=================================
        var l : int, len : int;
        len = Math.sqrt(vx * vx + vy * vy) * 10000;
        len = len > 400 ? 400 : len; 
        var a : int, r : int, g : int, b : int;
        var sx : int = cx * scale;
        var sy : int = cy * scale;
        while (l < len)
        {
            var n : Number = l / len;
            r = 0x44 * n;
            g = 0x44 * n;
            b = 0xCC * n;
            a = 0xFF * n;
            var cl : uint = uint(uint(a << 24) | r << 16 | g << 8 | b);
            canvas.setPixel32(sx + vx * l, sy + vy * l, cl);
            l += 10;
        }
    }
}

class Wind
{
    private const MAX : Number = .01;
    private var time : Number = 0;
    private var direction : Number = .75;
    private var fluid : Fluid;
    private var size : uint;
    private var windVelocity : Number;
    private var windDirection : Number;

    public function Wind(fluid : Fluid)
    {
        this.fluid = fluid;
        this.size = fluid.gridSize;
        
        update();
    }

    /**
     * add velocity to fluid as wind simulation
     */
    public function oparate(cx : int, cy : int, i : int) : void
    {
        var v : Number = Math.sin(Math.PI * (cy / size)) * windVelocity;

        fluid.u_prev[i] += Math.cos(windDirection) * v;
        fluid.v_prev[i] += Math.sin(windDirection) * v;
    }

    public function update() : void
    {
        time += .02;
        direction += .0001;
        direction = (direction > 1) ? 0 : direction;

        windVelocity = Math.cos(time) * MAX;
        windDirection = Math.PI * direction;
    }
}

class Fluid
{
    public var u : Vector.<Number>;
    public var v : Vector.<Number>;
    public var u_prev : Vector.<Number>;
    public var v_prev : Vector.<Number>;
    public var dens : Vector.<Number>;
    public var dens_prev : Vector.<Number>;
    
    private var N : uint;
    public var gridSize : uint;
    private var size : uint;
    public var _ix : Vector.<Vector.<Number>>;
    
    private var visc : Number = .0008;
    //拡散率
    private var diff : Number = 1;
    //単位時間
    private var dt : Number = .15;
    //精度        
    public var accuracy : int = 10;
    
    public function Fluid(N : uint)
    {
        this.N = N;
        this.gridSize = N + 2;
        this.size = (gridSize) * (gridSize);
        
        // 速度
        u = new Vector.<Number>(size, true);
        v = new Vector.<Number>(size, true);
        u_prev = new Vector.<Number>(size, true);
        v_prev = new Vector.<Number>(size, true);

        // 密度
        dens = new Vector.<Number>(size, true);
        dens_prev = new Vector.<Number>(size, true);
        
        for (var i : int = 0; i < size; i++)
        {
            u[i] = 0;
            u_prev[i] = 0;
            v[i] = 0;
            v_prev[i] = 0;
            dens[i] = 0;
            dens_prev[i] = 0;
        }
        
        _ix = new Vector.<Vector.<Number>>(size, true);
        for (var k : int = 0; k < gridSize; k++)
        {
            for (var j : int = 0; j < gridSize; j++)
            {
                var l : Vector.<Number> = _ix[k];
                if (l == null)
                {
                    l = new Vector.<Number>(gridSize, true);
                    _ix[k] = l;
                }

                l [j] = (k) + (gridSize) * (j);
            }
        }
    }
    
    private function add_source(x:Vector.<Number>, s:Vector.<Number>) : void
    {
        var i : int, sz : int;
        var dt2:Number;
        
        sz = size;
        dt2 = dt;
        
        for ( i = 0 ; i < sz ; i++ )
            x[i] += dt2 * s[i];
    }
    
    private function add_source_UV() : void
    {
        var i : int, sz : int;
        var dt2 : Number;
        var u2 : Vector.<Number>, v2 : Vector.<Number>, u_prev2 : Vector.<Number>, v_prev2 : Vector.<Number>;
        
        sz = size;
        dt2 = dt;
        u2 = u;
        v2 = v;
        u_prev2 = u_prev;
        v_prev2 = v_prev;
        
        for ( i = 0 ; i < sz ; i++ )
        {
            u2[i] += dt2 * u_prev2[i];
            v2[i] += dt2 * v_prev2[i];
        }
    }

    private function diffuse(b:int, x:Vector.<Number>, x0:Vector.<Number>, diff:Number) : void
    {
        var idx : int, n : int, n2 : int, i:int, j:int, k:int;
        var a : Number, c : Number;
        
        a = dt * diff * N * N;
        c = 1 / (1 + 4 * a);
        n = N;
        n2 = n + 2;
        
        for ( k = 0 ; k < accuracy ; k++ ){
            idx = _ix[1][1];
            for ( j = 1 ; j <= n ; j++ ){
                for ( i = 1 ; i <= n ; i++ ){
                    x[idx] = (x0[idx] + a * (x[int(idx - 1)] + x[int(idx + 1)] + x[int(idx - n2)] + x[int(idx + n2)])) * c;
                    idx++;
                }
                idx += 2;
            }
            set_bnd(b, x);
        }
    }
    
    private function diffuseUV() : void
    {
        var i : int, j : int, k : int;
        var a : Number = dt * visc * N * N;
        var b : Number = 1 / (1 + 4 * a);
        var idx : int;
        var n : int = N;
        var n2 : int = n + 2;
        var n3 : Number = _ix[1][1];
        var u2 : Vector.<Number> = u;
        var v2 : Vector.<Number> = v;
        var u_prev2 : Vector.<Number> = u_prev;
        var v_prev2 : Vector.<Number> = v_prev;
        
        for ( k=0 ; k<accuracy ; k++ ) { 
            idx = n3;
            for ( j=1 ; j<=n ; j++ ) { 
                for ( i=1 ; i<=n ; i++ ) { 
                    u2[idx] = (u_prev2[idx] + a*(u2[int(idx-1)]+u2[int(idx+1)]+ u2[int(idx-n2)]+u2[int(idx+n2)]))*b; 
                    v2[idx] = (v_prev2[idx] + a*(v2[int(idx-1)]+v2[int(idx+1)]+ v2[int(idx-n2)]+v2[int(idx+n2)]))*b; 
                    idx ++;
                } 
                idx += 2;
            }
            set_bnd(1, u2);
            set_bnd(2, v2);
        }
    }
    
     private function advect(b:int, d:Vector.<Number>, d0:Vector.<Number>, u:Vector.<Number>, v:Vector.<Number>):void
     {
        var i:int, j:int, i0 : int, i1 : int, j0 : int, j1 : int, idx:int, n:int, n2:int;
        var s0 : Number, s1 : Number, t0 : Number, t1 : Number, dt0 : Number, x : Number, y : Number;

        dt0 = dt * N; 
        n = N;            
        n2 = n + 2;
        idx = _ix[1][1];
        
        for ( j = 1 ; j <= n ; j++ ){
            for ( i = 1 ; i <= n ; i++ ){ 
                   x = i-dt0*u[idx]; y = j-dt0*v[idx]; 
                   if (x<0.5) x=0.5; if (x>n+0.5) x=n+0.5; i0=int(x); i1=i0+1; 
                   if (y<0.5) y=0.5; if (y>n+0.5) y=n+0.5; j0=int(y); j1=j0+1; 
                   s1 = x-i0; s0 = 1-s1; t1 = y-j0; t0 = 1-t1;
                   d[idx] = s0*(t0*d0[_ix[i0][j0]]+t1*d0[_ix[i0][j1]])+s1*(t0*d0[_ix[i1][j0]]+t1*d0[_ix[i1][j1]]); 
                   idx++;
            }
            idx += 2;
        } 
        set_bnd ( b, d ); 
     }
     
    private function advectUV() : void
    {
        var i:int, j:int, i0 : int, i1 : int, j0 : int, j1 : int, idx:int, n:int, n2:int;
        var s0 : Number, s1 : Number, t0 : Number, t1 : Number, dt0 : Number, x : Number, y : Number;
        var u2:Vector.<Number>, v2:Vector.<Number>, u_prev2:Vector.<Number>, v_prev2:Vector.<Number>;

        dt0 = dt * N; 
        idx = _ix[1][1];
        n = N;
        n2 = n + 2;
        u2 = u;
        v2 = v;
        u_prev2 = u_prev;
        v_prev2 = v_prev;
        
         for ( j=1 ; j<=n ; j++ ) { 
            for ( i=1 ; i<=n ; i++ ) { 
                   x = i-dt0*u_prev2[idx]; y = j-dt0*v_prev2[idx]; 
                   if (x<0.5) x=0.5; if (x>n+0.5) x=n+0.5; i0=int(x); i1=i0+1; 
                   if (y<0.5) y=0.5; if (y>n+0.5) y=n+0.5; j0=int(y); j1=j0+1; 
                   s1 = x-i0; s0 = 1-s1; t1 = y-j0; t0 = 1-t1;
                   u2[idx] = s0*(t0*u_prev2[int(_ix[i0][j0])]+t1*u_prev2[int(_ix[i0][j1])])+s1*(t0*u_prev2[int(_ix[i1][j0])]+t1*u_prev2[int(_ix[i1][j1])]); 
                   v2[idx] = s0*(t0*v_prev2[int(_ix[i0][j0])]+t1*v_prev2[int(_ix[i0][j1])])+s1*(t0*v_prev2[int(_ix[i1][j0])]+t1*v_prev2[int(_ix[i1][j1])]); 
                   idx++;
            }
            idx += 2;
        } 
        set_bnd ( 1, u2 ); 
        set_bnd ( 2, v2 ); 
    }
     
    private function swapUV() : void
    {
        var temp : Vector.<Number>;
        temp = u;
        u = u_prev;
        u_prev = temp;
        
        temp = v;
        v = v_prev;
        v_prev = temp;
    }
    
    private function project (u:Vector.<Number>, v:Vector.<Number>, p:Vector.<Number>, div:Vector.<Number> ):void
    {
        var i : int, j : int, k : int, idx : int, n : int, n2 : int;
        var h : Number, h2 : Number;
        var u2 : Vector.<Number>, v2 : Vector.<Number>;
        
        idx = _ix[1][1];
        n = N;
        n2 = n + 2;
        u2 = u;
        v2 = v;
        
        h = 1.0/n; 
        for ( j=1 ; j<=n ; j++ ) { 
            for ( i=1 ; i<=n ; i++ ) { 
                div[idx] = -0.5 * h * (u2[int(idx + 1)] - u2[int(idx - 1)] + v2[int(idx + n2)] - v2[int(idx - n2)]);
                p[idx] = 0; 
                idx ++;
            } 
            idx += 2;
        } 
        set_bnd ( 0, div ); set_bnd ( 0, p ); 
        
        
        for ( k=0 ; k<accuracy ; k++ ) { 
            idx= _ix[1][1];
            for ( j=1 ; j<=n ; j++ ) { 
                for ( i=1 ; i<=n ; i++ ) { 
                    p[idx] = (div[idx]+p[int(idx-1)]+p[int(idx+1)]+ p[int(idx-n2)]+p[int(idx+n2)])*.25; 
                    idx ++;  
                } 
                idx += 2;
            } 
            set_bnd ( 0, p ); 
         } 
         
        
        h2 = .5 * (1 / h);
        idx = _ix[1][1];
        for ( j=1 ; j<=n ; j++ ) { 
            for ( i=1 ; i<=n ; i++ ) { 
                u2[idx] -= 0.5*(p[int(idx+1)]-p[int(idx-1)])*h2; 
                v2[idx] -= 0.5*(p[int(idx+n2)]-p[int(idx-n2)])*h2; 
                idx++;
            } 
            idx += 2;
        } 
        set_bnd ( 1, u2 ); set_bnd ( 2, v2 ); 
    }

    private function set_bnd (b:int, x:Vector.<Number> ):void
    { 
        for ( var i:int=1; i<=N; i++ ){
            x[_ix[0][i]]   = b==1 ? x[_ix[1][i]]*-1 : x[_ix[1][i]]; 
            x[_ix[N+1][i]] = b==1 ? x[_ix[N][i]]*-1 : x[_ix[N][i]]; 
            x[_ix[i][0  ]] = b==2 ? x[_ix[i][1]]*-1 : x[_ix[i][1]]; 
            x[_ix[i][N+1]] = b==2 ? x[_ix[i][N]]*-1 : x[_ix[i][N]]; 
        }
        x[_ix[0  ][0  ]] = 0.5*(x[_ix[1][0  ]]+x[_ix[0  ][1]]); 
        x[_ix[0  ][N+1]] = 0.5*(x[_ix[1][N+1]]+x[_ix[0  ][N]]); 
        x[_ix[N+1][0  ]] = 0.5*(x[_ix[N][0  ]]+x[_ix[N+1][1]]); 
        x[_ix[N+1][N+1]] = 0.5*(x[_ix[N][N+1]]+x[_ix[N+1][N]]); 
    }
    
    public function update() : void
    {
        //=================================
        // velocity
        //=================================
        add_source_UV();
        swapUV();
        diffuseUV();
        project(u, v, u_prev, v_prev);
        swapUV();
        advectUV();
        project(u, v, u_prev, v_prev); 
        
        //=================================
        // density
        //=================================
        add_source(dens, dens_prev );
        diffuse(0, dens, dens_prev, diff );
        advect(0, dens, dens_prev, u, v);
        
        clear();
    }
    
    public function clear() : void
    {
        for (var i : int = 0; i < size; i++)
        {
            dens_prev[i] = dens[i] * .995;
            u_prev[i] = 0;
            v_prev[i] = 0;
        }
    }
}

class MathUtil
{
    //--------------------------------------------------------------------------
    //
    //  Class properties
    //
    //--------------------------------------------------------------------------
    /**
     * @private
     */
    private static const PI:Number = Math.PI;
    
    /**
     * 渡された任意のラジアンを角度に変換します.
     * 
     * @param radians　角度に変換したいラジアンを渡します.
     * @return ラジアンから角度に変換された値を返します.
     */
    public static function radiansToDegrees(radians:Number):Number 
    {
        return radians / PI * 180;
    }

    /**
     * 渡された任意の角度をラジアンに変換します.
     * 
     * @param degrees　ラジアンに変換したい角度を渡します.
     * @return 角度からラジアンに変換された値を返します.
     */
    public static function degreesToRadians(degrees:Number):Number 
    {
        return degrees * PI / 180;
    }

    /**
     * 2つのラジアン度の差を返します.
     * 
     * @param angle1    ラジアン度
     * @param angle2    ラジアン度
     * @return          2つのラジアン度の差
     */
    public static function getAngleDiff(angle1 : Number, angle2 : Number) : Number
    {
        var vx1:Number, vy1:Number, vx2:Number, vy2:Number;
        
        vx1 = Math.cos(angle1);
        vy1 = Math.sin(angle1);
        vx2 = Math.cos(angle2);
        vy2 = Math.sin(angle2);
        
        return Math.atan2(crossProduct(vx1, vy1, vx2, vy2), dotProduct(vx1, vy1, vx2, vy2));
    }
    
    /**
     * ベクトルの内積を返します
     */
    public static function dotProduct(vx1:Number, vy1:Number, vx2:Number, vy2:Number):Number
    {
        return vx1 * vx2 + vy1 * vy2;
    }
    
    /**
     * ベクトルの外積を返します
     */
    public static function crossProduct(vx1:Number, vy1:Number, vx2:Number, vy2:Number) : Number 
    {
        return vx1 * vy2 - vx2 * vy1;
    }
}
/**
 * Sketch of Voronoi
 * I will recommend seeing in "FULL SCREEN" mode. 
 * http://alumican.net/#/c/cells
 * 
 * based on 超速ボロノイ図 by fumix
 * @see http://wonderfl.net/c/3TKq/
 * 
 * Fortune's algorithm - Wikipedia, the free encyclopedia
 * @see http://en.wikipedia.org/wiki/Fortune's_algorithm
 * 
 * Controul > Speedy Voronoi diagrams in as3/flash
 * @see http://blog.controul.com/2009/05/speedy-voronoi-diagrams-in-as3flash/
 * 
 * @author Yukiya Okuda<alumican.net>
 */
package
{
    import com.flashdynamix.utils.SWFProfiler;
    import flash.display.Graphics;
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageQuality;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    
    public class Main extends Sprite
    {
        private const N:int = 700;
        
        private const PI:Number = Math.PI;
        private const PI2:Number = PI * 2;
        private const TO_DEGREE:Number = 180 / PI;
        private const TO_RADIAN:Number = PI / 180;
        
        private var _fortune:Fortune;
        private var _points:Vector.<Number2>;
        private var _pointCount:int;
        private var _first:Number2;
        private var _oldMouseX:Number;
        private var _oldMouseY:Number;
        private var _background:Shape;
        private var _canvas:Shape;
        private var _range:Number;
        
        public function Main():void
        {
            Wonderfl.disable_capture();
            addEventListener(Event.ADDED_TO_STAGE, _init);
        }
        
        private function _init(e:Event):void 
        {
            removeEventListener(Event.ADDED_TO_STAGE, _init);
            
            stage.align = StageAlign.TOP_LEFT;
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.quality = StageQuality.MEDIUM;
            stage.frameRate = 60;
            
            var sw:Number = stage.stageWidth,
                sh:Number = stage.stageHeight;
            
            _fortune = new Fortune();
            
            _background = addChild( new Shape() ) as Shape;
            _background.graphics.beginFill(0x0);
            _background.graphics.drawRect(0, 0, sw, sh);
            _background.graphics.endFill();
            
            _canvas = addChild( new Shape() ) as Shape;
            
            _points = new Vector.<Number2>(N);
            var p:Number2;
            var old:Number2;
            for (var i:int = 0; i < N; ++i) 
            {
                _points[i] = p = new Number2();
                
                if (_first == null)
                {
                    old = _first = p;
                }
                else
                {
                    old.next = p;
                    old = p;
                }
            }
            
            _oldMouseX = mouseX;
            _oldMouseY = mouseY;
            
            addEventListener(Event.ENTER_FRAME, _update);
            stage.addEventListener(Event.RESIZE, _resize);
            _resize(null);
            
            SWFProfiler.init(this);
        }
        
        private function _resize(e:Event):void
        {
            var sw:Number = stage.stageWidth,
                sh:Number = stage.stageHeight;
            
            _background.width = sw;
            _background.height = sh;
            _range = 100 * (Math.min(sw, sh) / 465);
            
            var p:Number2 = _first;
            do
            {
                var px:Number = p.x = Math.random() * sw;
                var py:Number = p.y = Math.random() * sh;
                var angle:Number = Math.atan2(py - sh * 0.5, px - sw * 0.5);
                p.defaultVx = p.vx = 0.3 * Math.cos(angle);
                p.defaultVy = p.vy = 0.3 * Math.sin(angle);
            }
            while (p = p.next);
        }
        
        private function _update(e:Event):void 
        {
            _interaction();
            _draw();
        }
        
        private function _interaction():void
        {
            var sw:Number = stage.stageWidth,
                sh:Number = stage.stageHeight,
                cx:Number = sw * 0.5,
                cy:Number = sh * 0.5,
                mx:Number = mouseX,
                my:Number = mouseY,
                dx:Number,
                dy:Number,
                dist2:Number,
                px:Number,
                py:Number,
                mvx:Number = mx - _oldMouseX,
                mvy:Number = my - _oldMouseY,
                ms2:Number = Math.sqrt(mvx * mvx + mvy * mvy),
                angle:Number,
                power:Number,
                mag:Number = _range * 0.5;
            
            var p:Number2 = _first;
            do
            {
                px = p.x;
                py = p.y;
                
                if (px < 0 || px > sw || py < 0 || py > sh)
                {
                    angle = Math.random() * PI2;
                    
                    p.x  = cx + (Math.random() - 0.5) * 5;
                    p.y  = cy + (Math.random() - 0.5) * 5;
                    p.vx = (Math.random() - 0.5) * 1 * Math.cos(angle);
                    p.vy = (Math.random() - 0.5) * 1 * Math.sin(angle);
                    p.defaultVx = p.vx;
                    p.defaultVy = p.vy;
                }
                else
                {
                    dx = px - mx;
                    dy = py - my;
                    
                    dist2 = dx * dx + dy * dy;
                    angle = Math.atan2(dy, dx);
                    
                    power = mag / dist2 * ms2;
                    p.vx += power * Math.cos(angle);
                    p.vy += power * Math.sin(angle);
                }
                
                p.defaultVx *= 1.005;
                p.defaultVy *= 1.005;
                
                p.vx += (p.defaultVx - p.vx) * 0.05;
                p.vy += (p.defaultVy - p.vy) * 0.05;
                
                p.x += p.vx;
                p.y += p.vy;
            }
            while (p = p.next);
            
            _fortune.points = _points;
            
            _oldMouseX = mx;
            _oldMouseY = my;
        }
        
        private function _draw():void
        {
            var segments:Vector.<Number2> = _fortune.compute(),
                g:Graphics = _canvas.graphics,
                p:Number2 = _first,
                i:int,
                n:int = segments.length,
                st:Number2,
                ed:Number2,
                dx:Number,
                dy:Number,
                dist2:Number,
                thickness:Number,
                range:Number = _range,
                mx:Number = mouseX,
                my:Number = mouseY,
                stX:Number,
                stY:Number,
                edX:Number,
                edY:Number;
            
            g.clear();
            for (i = 0; i < n; i += 2)
            {
                st = segments[i    ];
                ed = segments[i + 1];
                stX = st.x;
                stY = st.y;
                edX = ed.x;
                edY = ed.y;
                
                dx = (edX + stX) * 0.5 - mx;
                dy = (edY + stY) * 0.5 - my;
                dist2 = Math.sqrt(dx * dx + dy * dy);
                thickness = (dist2 < range) ? (10 * (range - dist2) / range) : 0;
                
                g.lineStyle(thickness, 0x333333);
                g.moveTo(stX, stY);
                g.lineTo(edX, edY);
            }
            
            g.lineStyle(0, 0xffffff, 0.8);
            do
            {
                g.drawCircle(p.x, p.y, 1);
            }
            while (p = p.next);
        }
    }
}





//package  
//{
    /*public*/ class Number2
    {
        public var x:Number;
        public var y:Number;
        public var vx:Number;
        public var vy:Number;
        public var next:Number2;
        public var defaultVx:Number;
        public var defaultVy:Number;
        
        public function Number2(x:Number = 0, y:Number = 0, vx:Number = 0, vy:Number = 0):void 
        {
            this.x = x;
            this.y = y;
            this.defaultVx = this.vx = vx;
            this.defaultVy = this.vy = vy;
        }
    }
//}





//package
//{
    /*public*/ class Arc
    {
        public var p        : Number2;
        public var next        : Arc;
        public var prev        : Arc;
    //    public var s0        : Seg;
    //    public var s1        : Seg;
        public var v0        : Number2;
        public var v1        : Number2;
        
        //    Circle event data :
        public var left        : Arc;
        public var right    : Arc;
        public var endX        : Number;
        public var endP        : Number2;
    }
//}





//package
//{
    /*
     * An implementation of Steve Fortune's algorithm for computing voronoi diagrams.
     * @author Matt Brubeck
     *
     * Modifications and optimisations:
     *  ** Data structures are adapted to what's available to as3.
     *  ** The beachline intersection lookup is optimised,
     *     intersecting begins only near the probable intersection.
     *  ** Functions are massively inlined.
     *
     * Todo list:
     *  ** Provide for bounding box intersection,
     *  ** Inline the 'intersection' method.
     *  ** Design a good datastructure for the solution, which would
     *     ideally contain enough neighbourhood info for region rendering,
     *     extrusion and intrusion of edges and pathfinding.
     *
     * Original c++ code
     * http://www.cs.hmc.edu/~mbrubeck/voronoi.html
     */

    /*public*/ class Fortune
    {


/////////
/////////
/////////    Datastructures.

        //    Points are provided as a vector, which is sorted by x (increasing) before the sweep.

        public var points    : Vector.<Number2>;

        //    Bounding box.

        private var x0        : Number;
//        private var x1        : Number;
//        private var y0        : Number;
//        private var y1        : Number;

        //    Root of the frontline and next arc to be removed.

        private var root    : Arc;
        private var next    : Arc;

        //    Reusable objects and pools.

        private var o                : Number2 = new Number2;
        private static var arcPoolD : Arc;



////////
////////
////////    API.

        /**
         * Computes the Voronoi decomposition of the plane.
         * @return A vector or vertices in pairs, describing segments ready for drawing.
         */

        public function compute () : Vector.<Number2>
        {
            //
            //
            //    Clear the output.

            var out : Vector.<Number2> = new Vector.<Number2>,
                len    : int = 0;

            //
            //
            //    Clear the state.

            root = null;
            next = null;

            //
            //
            //    Read the pools.

            var key : * ,
                arcPool : Arc = arcPoolD;

            //
            //
            //    Vars:

            var i        : int,
                j        : int,
                w        : Number,
                x        : Number,

                a        : Arc,
                b        : Arc,

//                s        : Seg,
                z        : Number2,

                p        : Number2 = points [ 0 ],
                points    : Vector.<Number2> = points,
                n        : int = points.length,

            //    Circle events check inlined.

                circle    : Boolean,
                eventX    : Number,

                c        : Arc,
                d        : Arc,

                aa        : Number2,
                bb        : Number2,
                cc        : Number2,

                A        : Number,
                B        : Number,
                C        : Number,
                D        : Number,
                E        : Number,
                F        : Number,
                G        : Number;


            //

//            y0 = p.y;
//            y1 = p.y;

            //
            //
            //    Sort points by x coord, compute the bounding box.

            /////    Currently insertion sort. Quicksort?

            w = points [ 0 ].x;

            for ( i = 1; i < n; i ++ )
            {
                p = points [ i ];

                //    Keep track of the bounding box.

//                if ( p.y < y0 )
//                    y0 = p.y;
//                else if ( p.y > y1 )
//                    y1 = p.y;

                //    Insertion sort.

                x = p.x;
                if ( x < w )
                {
                    j = i;
                    while ( ( j > 0 ) && ( points [ int ( j - 1 ) ].x > x ) )
                    {
                        points [ j ] = points [ int ( j - 1 ) ];
                        j--;
                    }
                    points [ j ] = p;
                }
                else
                    w = x;
            }

            //    Get x bounds.

            x0 = points [ 0 ].x;
//            x1 = points [ n - 1 ].x;

            //    Add margins to the bounding box.
/*
            var dx : Number = (x1 - x0 + 1) / 5.0,
                dy : Number = dy = (y1 - y0 + 1) / 5.0;
            x0 -= dx;
            x1 += dx;
            y0 -= dy;
            y1 += dy;

//            trace ( x0, x1, y0, y1 );
//*/
            //
            //
            //    Process.

            i = 0;
            p = points [ 0 ];
            x = p.x;

            for ( ;; )
            {

                //
                //    Check circle events. /////////////////////////

                if ( a )
                {
                    //    Check for arc a.

                    circle = false;

                    if ( a.prev && a.next )
                    {
                        aa = a.prev.p,
                        bb = a.p,
                        cc = a.next.p;

                        //    Algorithm from O'Rourke 2ed p. 189.

                        A = bb.x - aa.x,
                        B = bb.y - aa.y,
                        C = cc.x - aa.x,
                        D = cc.y - aa.y;

                        //    Check that bc is a "right turn" from ab.

                        if ( A * D - C * B <= 0 )
                        {
                            E = A * ( aa.x + bb.x ) + B * ( aa.y + bb.y ),
                            F = C * ( aa.x + cc.x ) + D * ( aa.y + cc.y ),
                            G = 2 * ( A * ( cc.y - bb.y ) - B * ( cc.x - bb.x ) );

                            //    Check for colinearity.

//                            if ( G > 0.000000001 || G < -0.000000001 )
                            if ( G )
                            {
                                //    Point o is the center of the circle.

                                o.x = ( D * E - B * F ) / G;
                                o.y = ( A * F - C * E ) / G;

                                //    o.x plus radius equals max x coordinate.

                                A = aa.x - o.x;
                                B = aa.y - o.y;
                                eventX = o.x + Math.sqrt ( A * A + B * B );

                                if ( eventX >= w )
                                    circle = true;
                            }
                        }
                    }

                    //    Remove from queue.

                    if ( a.right )
                        a.right.left = a.left;
                    if ( a.left )
                        a.left.right = a.right;
                    if ( a == next )
                        next = a.right;

                    //    Record event.

                    if ( circle )
                    {
                        a.endX = eventX;
                        if ( a.endP )
                        {
                            a.endP.x = o.x;
                            a.endP.y = o.y;
                        }
                        else
                        {
                            a.endP = o;
                            o = new Number2;
                        }

                        d = next;
                        if ( !d )
                        {
                            next = a;
                        }
                        else for ( ;; )
                        {
                            if ( d.endX >= eventX )
                            {
                                a.left = d.left;
                                if ( d.left )
                                    d.left.right = a;
                                if ( next == d )
                                    next = a;
                                a.right = d;
                                d.left = a;

                                break;
                            }
                            if ( !d.right )
                            {
                                d.right = a;
                                a.left = d;
                                a.right = null;

                                break;
                            }
                            d = d.right;
                        }
                    }
                    else
                    {
                        a.endX = NaN;
                        a.endP = null;
                        a.left = null;
                        a.right = null;
                    }

                    //    Push next arc to check.

                    if ( b )
                    {
                        a = b;
                        b = null;
                        continue;
                    }
                    if ( c )
                    {
                        a = c;
                        c = null;
                        continue;
                    }
                    a = null;
                }

                //////////////////////////////////////////////////
                //

                if ( next && next.endX <= x )
                {
                    //
                    //    Handle next circle event.

                    //    Get the next event from the queue. ///////////

                    a = next;
                    next = a.right;
                    if ( next )
                        next.left = null;
                    a.right = null;

        //DEBUG*/    Debug.frontRemove ( a, root );

                    //    Start a new edge.

//                    s = new Seg;
//                    s.start = a.endP;

                    //    Remove the associated arc from the front.

                    if ( a.prev )
                    {
                        a.prev.next = a.next;
//                        a.prev.s1 = s;
                        a.prev.v1 = a.endP;
                    }
                    if ( a.next )
                    {
                        a.next.prev = a.prev;
//                        a.next.s0 = s;
                        a.next.v0 = a.endP;
                    }

                    //    Finish the edges before and after a.
/*
                    if ( a.s0 && !a.s0.done )
                    {
                        a.s0.done = true;
//                        a.s0.end = a.endP;
                        out [ len ++ ] = a.s0.start;
                        out [ len ++ ] = a.endP;
                    }
                    if ( a.s1 && !a.s1.done )
                    {
                        a.s1.done = true;
//                        a.s1.end = a.endP;
                        out [ len ++ ] = a.s1.start;
                        out [ len ++ ] = a.endP;
                    }
*/
                    if ( a.v0 )
                    {
                        out [ len ++ ] = a.v0;
                        a.v0 = null;
                        out [ len ++ ] = a.endP;
                    }
                    if ( a.v1 )
                    {
                        out [ len ++ ] = a.v1;
                        a.v1 = null;
                        out [ len ++ ] = a.endP;
                    }

                    //    Keep a ref for collection.

                    d = a;

                    //    Recheck circle events on either side of p:

                    w = a.endX;
                    if ( a.prev )
                    {
                        b = a.prev;
                        a = a.next;
                    }
                    else
                    {
                        a = a.next;
                        b = null;
                    }
                    c = null;

                    //    Collect.

                    d.v0 = null;
                    d.v1 = null;
                    d.p = null;
                    d.prev = null;
                    d.endX = NaN;
                    d.endP = null;
                    d.next = arcPool;
                    arcPool = d;

                    //////////////////////////////////////////////////
                    //
                }
                else
                {
                    if ( !p )
                        break;

                    //
                    //    Handle next site event. //////////////////////

                    if ( !root ) {
//                        root = new Arc;
                        if ( arcPool )
                        {
                            root = arcPool;
                            arcPool = arcPool.next;
                            root.next = null;
                        }
                        else
                            root = new Arc;
                        root.p = p;
        //DEBUG*/        Debug.frontInsert ( root, root );
                    }
                    else
                    {

                        z = new Number2;

                        //    Find the first arc with a point below p,
                        //    and start searching for the intersection around it.

                        a = root.next;
                        if ( a )
                        {
                            while ( a.next )
                            {
                                a = a.next;
                                if ( a.p.y >= p.y )
                                    break;
                            }

                            //    Find the intersecting curve.

                            intersection ( a.prev.p, a.p, p.x, z );
                            if ( z.y <= p.y )
                            {
                                //    Search for the intersection to the south of i.

                                while ( a.next )
                                {
                                    a = a.next;
                                    intersection ( a.prev.p, a.p, p.x, z );
                                    if ( z.y >= p.y )
                                    {
                                        a = a.prev;
                                        break;
                                    }
                                }
                            }
                            else
                            {
                                //    Search for the intersection above i.

                                a = a.prev;
                                while ( a.prev )
                                {
                                    a = a.prev;
                                    intersection ( a.p, a.next.p, p.x, z );
                                    if ( z.y <= p.y )
                                    {
                                        a = a.next;
                                        break;
                                    }
                                }
                            }
                        }
                        else
                            a = root;

                        //    New parabola will intersect arc a. Duplicate a.

                        if ( a.next )
                        {
//                            b = new Arc;
                            if ( arcPool )
                            {
                                b = arcPool;
                                arcPool = arcPool.next;
                                b.next = null;
                            }
                            else
                                b = new Arc;
                            b.p = a.p;
                            b.prev = a;
                            b.next = a.next;
                            a.next.prev = b;
                            a.next = b;
                        }
                        else
                        {
//                            b = new Arc;
                            if ( arcPool )
                            {
                                b = arcPool;
                                arcPool = arcPool.next;
                                b.next = null;
                            }
                            else
                                b = new Arc;
                            b.p = a.p;
                            b.prev = a;
                            a.next = b;
                        }
//                        a.next.s1 = a.s1;
                        a.next.v1 = a.v1;

                        //    Find the point of intersection.

                        z.y = p.y;
                        z.x = ( a.p.x * a.p.x + ( a.p.y - p.y ) * ( a.p.y - p.y ) - p.x * p.x )
                                / ( 2 * a.p.x - 2 * p.x );

                        //    Add p between i and i->next.

//                        b = new Arc;
                        if ( arcPool )
                        {
                            b = arcPool;
                            arcPool = arcPool.next;
                            b.next = null;
                        }
                        else
                            b = new Arc;

                        b.p = p;
                        b.prev = a;
                        b.next = a.next;

                        a.next.prev = b;
                        a.next = b;

                        a = a.next;    //    Now a points to the new arc.

                        //    Add new half-edges connected to i's endpoints.
/*
                        s = new Seg;
                        s.start = z;
                        a.prev.s1 = a.s0 = s;
                        s = new Seg;
                        s.start = z;
                        a.next.s0 = a.s1 = s;
*/
                        a.prev.v1 = z;
                        a.next.v0 = z;
                        a.v0 = z;
                        a.v1 = z;

                        //    Check for new circle events around the new arc:

                        b = a.next;
                        a = a.prev;
                        c = null;
                        w = p.x;

            //DEBUG*/    Debug.frontInsert ( a, root );
                    }

                    //////////////////////////////////////////////////
                    //

                    i ++;
                    if ( i >= n )
                    {
                        p = null;
                        x = Number.MAX_VALUE;
                    }
                    else
                    {
                        p = points [ i ];
                        x = p.x;
                    }
                }
            }
//*/

/*
            //    Clean up dangling edges.

            //    Advance the sweep line so no parabolas can cross the bounding box.
            x = x1;
            x = x1 + ( x1 - x0 ) + ( y1 - y0 );
            x *= 2;

            //    Extend each remaining segment to the new parabola intersections.
            var arc : Arc = root;
            for ( ;; )
            {
                if ( arc.s1 )
                    arc.s1.finish ( intersection ( arc.p, arc.next.p, x, new Number2 ) );
                arc = arc.next;
                if ( !arc.next )
                    break;
            }
//*/
            //
            //
            //    Store the pools.

            arcPoolD = arcPool;

            //
            //
            //    Return the result ready for drawing.

            return out;
        }



        /**
         * Where do two parabolas intersect?
         * @param    p0 A Number2 object describing the site for the first parabola.
         * @param    p1 A Number2 object describing the site for the second parabola.
         * @param    l The location of the sweep line.
         * @param    res A Number2 object in which to store the intersection.
         * @return The point of intersection.
         */
        public function intersection ( p0 : Number2, p1 : Number2, l : Number, res : Number2 ) : Number2
        {
            var p    : Number2 = p0,
                ll    : Number = l * l;

            if ( p0.x == p1.x )
                res.y = ( p0.y + p1.y ) / 2;
            else if ( p1.x == l )
                res.y = p1.y;
            else if ( p0.x == l )
            {
                res.y = p0.y;
                p = p1;
            }
            else
            {
                //    Use the quadratic formula.

                var z0 : Number = 0.5 / ( p0.x - l ); // 1 / ( 2*(p0.x - l) )
                var z1 : Number = 0.5 / ( p1.x - l ); // 1 / ( 2*(p1.x - l) )

                var a : Number = z0 - z1;
                var b : Number = -2 * ( p0.y * z0 - p1.y * z1 );
                var c : Number = ( p0.y * p0.y + p0.x * p0.x - ll ) * z0
                               - ( p1.y * p1.y + p1.x * p1.x - ll ) * z1;

                res.y = ( - b - Math.sqrt ( b * b - 4 * a * c ) ) / ( 2 * a );
            }
            
            //    Plug back into one of the parabola equations.

            res.x = ( p.x * p.x + ( p.y - res.y ) * ( p.y - res.y ) - ll )
                    / ( 2 * p.x - 2 * l );
            return res;
        }

    }
//}
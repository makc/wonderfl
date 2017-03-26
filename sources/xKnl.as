/**
 * Voronoi Letter
 * Usase : key down "Alphabet" or "Number" or "Number of tenkey".
 *         if no reaction, click stage and key down.
 * 使い方 : アルファベットキー、数字キー、テンキーの数字キー、いずれかを押してください。
 *         反応しないときは、一度ステージをクリックしてからキーを押してください。
 *
 * Fortune's algorithm - Wikipedia, the free encyclopedia
 * @see http://en.wikipedia.org/wiki/Fortune's_algorithm
 * 
 * Controul > Speedy Voronoi diagrams in as3/flash
 * @see http://blog.controul.com/2009/05/speedy-voronoi-diagrams-in-as3flash/
 *
 * @see http://wonderfl.net/c/3TKq
 * @see http://wonderfl.net/c/iNy0
 * 
 * 解説 : http://aquioux.blog48.fc2.com/blog-entry-735.html
 *
 * @author Aquioux(Yoshida, Akio)
 */
package {
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Graphics;
    import flash.display.GraphicsEndFill;
    import flash.display.GraphicsPath;
    import flash.display.GraphicsPathCommand;
    import flash.display.GraphicsSolidFill;
    import flash.display.GraphicsStroke;
    import flash.display.IGraphicsData;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
    [SWF(width = "465", height = "465", frameRate = "30", backgroundColor = "#FFFFFF")]
    
    public class Main extends Sprite {
        // 母点生成用定数
        private const FONT_SIZE:uint  = 48;
        private const INTERVAL_X:Number = 9.5;
        private const INTERVAL_Y:Number = 9.5;
        private const W:Number = stage.stageWidth / INTERVAL_X;
        private const H:Number = stage.stageHeight / INTERVAL_Y;
        private const CX:Number = stage.stageWidth / 2;
        private const CY:Number = stage.stageHeight / 2;
        
        // 母点動作用定数
        private const SPRING:Number   = 0.05;            // バネ係数
        private const FRICTION:Number = 0.79;            // 摩擦係数
        private const PI2:Number = Math.PI * 2;
        private const FREQ:uint   = 8;
        private const FREQ2:uint  = FREQ * 2 + 1;
        private const OFFSET:uint  = 3;
        private const OFFSET2:uint = OFFSET * 2 + 1;
        
        // 文字を転写する BitmapData
        private var bmd_:BitmapData;
        
        // 母点格納
        private var generators_:Vector.<Number2>;

        // ボロノイ図作図クラス
        private var fortune_:Fortune;

        // キャンバス
        private var canvas_:Sprite;
        // GraphicsData
        private var graphicsData:Vector.<IGraphicsData>;
        private var path:GraphicsPath;
        
        
        // コンストラクタ
        public function Main() {
            // ボロノイ辺描画用 GraphicsData 生成
            createGraphicsData();
            // キャンバス生成
            canvas_ = new Sprite();
            addChild(canvas_);

            // ボロノイ辺作図クラス生成
            fortune_ = new Fortune();
            
            // 母点生成
            createGenerators("A");
            
            addEventListener(Event.ENTER_FRAME, enterFrameHandler);
            stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
        }
        
        // 母点生成
        private function createGenerators(letter:String):void {
            createGenerator(letter);
            fortune_.points = generators_;
        }
        private function createGenerator(letter:String):void {
            const TRANSPARENT:uint = 0x00000000;
            const COLOR:uint       = 0xFF000000;

            // TextField の生成
            var tFormat:TextFormat = new TextFormat("_sans", FONT_SIZE, COLOR);
            var tField:TextField = new TextField();
            tField.defaultTextFormat = tFormat;
            tField.text = letter;
            tField.autoSize = TextFieldAutoSize.LEFT;
            
            // TextField を BitmapData へ転写
            var bmd1:BitmapData = new BitmapData(tField.textWidth, tField.textHeight, true, TRANSPARENT);
            bmd1.draw(tField, new Matrix(1, 0, 0, 1, -2, -2));
            
            // 上記 BitmapData から 文字部分のみを抜き出す
            var rect:Rectangle = bmd1.getColorBoundsRect(0xFF000000, TRANSPARENT, false);
            
            // 文字部分のサイズの BitmapData へ転写
            var bmd2:BitmapData = new BitmapData(rect.width, rect.height, true, TRANSPARENT);
            bmd2.draw(bmd1, new Matrix(1, 0, 0, 1, -rect.x, -rect.y));
            
            // 上記 BitmapData をスキャン対象サイズの BitmapData へ転写
            bmd_ = new BitmapData(W, H, true, TRANSPARENT);
            bmd_.draw(bmd2, new Matrix(1, 0, 0, 1, (W - bmd2.width) / 2, (H - bmd2.height) / 2));
            
            // 使用済みの BitmapData を解放
            bmd1.dispose();
            bmd2.dispose();

            // BitmapData をスキャン
            var flg:Boolean = false;
            generators_ = new Vector.<Number2>();
            for (var y:int = 0; y < H; y++) {
                for (var x:int = 0; x < W; x++) {
                    var color:uint = bmd_.getPixel32(x, y);
                    var alpha:uint = (color >> 24) & 0xFF;
                    if (alpha > 0x79) {
                        flg = true;
                    } else {
                        if (Math.random() < 0.01) flg = true;
                    }
                    if (flg) {
                        var generator:Number2 = new Number2();
                        generator.localX = x * INTERVAL_X + int(Math.random() * OFFSET2) - OFFSET;
                        generator.localY = y * INTERVAL_Y + int(Math.random() * OFFSET2) - OFFSET;
                        var radian:Number = Math.random() * PI2;
                        generator.x = Math.cos(radian) * 300 + CX;
                        generator.y = Math.sin(radian) * 300 + CY;
                        generators_.push(generator);
                        flg = false;
                    }
                }
            }

            // 使用済みの BitmapData を解放
            bmd_.dispose();
        }
        
        // ボロノイ辺描画用 GraphicsData 生成
        private function createGraphicsData():void {
            // 線の定義
            var stroke:GraphicsStroke = new GraphicsStroke();
            stroke.thickness = 0;
            stroke.fill = new GraphicsSolidFill(0x000000);

            // パスの定義
            path = new GraphicsPath(null, null);

            // 描画データをパッケージング
            graphicsData = new Vector.<IGraphicsData>();
            graphicsData.push(stroke);
            graphicsData.push(path);
            graphicsData.push(new GraphicsEndFill());
        }
        
        
        private function enterFrameHandler(event:Event):void {
            // 母点位置更新
            var n:uint = generators_.length;
            for (var i:int = 0; i < n; i++) {
                generatorUpdate(generators_[i]);
            }

            // ボロノイ点更新
            var points:Vector.<Number2> = fortune_.compute();
            
            // ボロノイ辺の描画
            var start:Number2;    // ボロノイ辺の起点
            var end:Number2;    // ボロノイ辺の終点
            var commands:Vector.<int> = new Vector.<int>();
            var data:Vector.<Number>  = new Vector.<Number>();
            n = points.length;
            for (i = 0; i < n; i += 2) {
                start = points[i];
                end   = points[i + 1];
                commands.push(GraphicsPathCommand.MOVE_TO, GraphicsPathCommand.LINE_TO);
                data.push(start.x, start.y, end.x, end.y);
            }
            path.commands = commands;
            path.data     = data;
            
            var g:Graphics = canvas_.graphics;
            g.clear();
            g.drawGraphicsData(graphicsData);
        }
        
        // 各母点の位置更新
        private function generatorUpdate(generator:Number2):void {
            var localX:Number = generator.localX;
            var localY:Number = generator.localY;
            var vx:Number     = generator.vx;
            var vy:Number     = generator.vy;
            var x:Number      = generator.x;
            var y:Number      = generator.y;

            var diff:Number   = Math.floor(Math.random() * FREQ2) - FREQ;
            var radian:Number = Math.random() * PI2;
            var dx:Number = localX + Math.cos(radian) * diff;
            var dy:Number = localY + Math.sin(radian) * diff;
            
            vx += (dx - x) * SPRING;
            vy += (dy - y) * SPRING;
            vx *= FRICTION;
            vy *= FRICTION;
            x += vx;
            y += vy;
            
            generator.x  =  x;
            generator.y  =  y;
            generator.vx = vx;
            generator.vy = vy;
        }
        
        private function keyDownHandler(e:KeyboardEvent):void {
            var flg:Boolean = false;
            var keyCode:int = e.keyCode;
            if ((keyCode >= 48) && (keyCode <= 57))  flg = true;    // 数字キー（キーボード）
            if ((keyCode >= 96) && (keyCode <= 105)) flg = true;    // 数字キー（テンキー）
            if ((keyCode >= 65) && (keyCode <= 91))  flg = true;    // アルファベットキー（キーボード）

            if (flg) createGenerators(String.fromCharCode(e.charCode));
        }
    }
}


//package {
    /*public*/ class Number2 {
        // 既定座標
        public function get localX():Number { return _localX; }
        public function set localX(value:Number):void { _localX = value; }
        private var _localX:Number;

        public function get localY():Number { return _localY; }
        public function set localY(value:Number):void { _localY = value; }
        private var _localY:Number;
        
        // 現在座標
        public function get x():Number { return _x; }
        public function set x(value:Number):void { _x = value; }
        private var _x:Number;
        
        public function get y():Number { return _y; }
        public function set y(value:Number):void { _y = value; }
        private var _y:Number;
        
        // 速度
        public function get vx():Number { return _vx; }
        public function set vx(value:Number):void { _vx = value; }
        private var _vx:Number = 0;
        
        public function get vy():Number { return _vy; }
        public function set vy(value:Number):void { _vy = value; }
        private var _vy:Number = 0;
        
        
        public function Number2() {
        }
    }
//}


//package {
    /*public*/ class Arc
    {
        public var p        : Number2;
        public var next        : Arc;
        public var prev        : Arc;
//        public var s0        : Seg;
//        public var s1        : Seg;
        public var v0        : Number2;
        public var v1        : Number2;

        //    Circle event data :

        public var left        : Arc;
        public var right    : Arc;
        public var endX        : Number;
        public var endP        : Number2;
    }
//}


//package {
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

    /*public*/ class Fortune {


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

package
{
    import flash.geom.*;
    import flash.events.*;
    import flash.display.*;
    import flash.filters.*;
    import com.bit101.components.*;

    /**  @author SPANVEGA // CHRISTIAN  **/

    [ SWF (width = '465', height = '465', backgroundColor = '0x000000', frameRate = '50')]

    public class JOINING extends Sprite
    {
        private var w : uint = 465, h : uint = 465;
        private var r : Rectangle = new Rectangle (0, 0, w, h);
        private var b : BRESENHAM = new BRESENHAM (w, h, true, 0);
        private var f : BlurFilter = new BlurFilter (1.25, 1.25, 1);
        private var m : Matrix = new Matrix (), p : Point = new Point ();
        private var t : ColorTransform = new ColorTransform (1, 1, 1, 0.25);

        private var connected : Vector.<int> = new Vector.<int>(quantity, true);
        private var quantity_slider : HUISlider, distance_slider : HUISlider;
        private var pressed : Boolean = false, type : int;

        private var distance : uint, fade : Number, step : Number, ratio : Number;
        private var quantity : uint = 75, hue : Number = 160;
        private var d : Number, dx : Number, dy : Number;

        private var pool : POOL, pa : POINT, pb : POINT;
        private var lines : Array = [], line : LINE;
        private var shape : BitmapData, size : uint;

        private var i : int, j : int;


        public function JOINING ()
        {
            stage ? init () : addEventListener ('addedToStage', init);
        }

        private function init (e : Event = null) : void
        {
            if (hasEventListener ('addedToStage'))
            {removeEventListener ('addedToStage', init);}

            Wonderfl.disable_capture ();
            stage.scaleMode = 'noScale';
            stage.quality = 'low';

            graphics.beginFill (0, 1);
            graphics.drawRect  (0, 0, w, h);

            //

            var c : uint = 0xFFFFFFFF;

            shape = new BitmapData (size = 5, size, true, 0);
            shape.setVector (new Rectangle (0, 0, size, size), new <uint>
            [0, 0, c, 0, 0, 0, c, c, c, 0, c, c, c, c, c, 0, c, c, c, 0, 0, 0, c, 0, 0]);

            addChild (new Bitmap (b));

            gui ();

            //

            pool = new POOL (0, 0, w, h);

            for (i = 0; i < quantity; i++)
            {
                pool.add (point ());
            }

            _distance ();

            //

            stage.addEventListener ('mouseDown', press_left);
            stage.addEventListener ('mouseUp',   press_left);
            stage.addEventListener ('rightMouseDown', press_right);
            stage.addEventListener ('rightMouseUp',   press_right);

            render (); stage.addEventListener ('enterFrame', render);
        }

        private function point () : POINT
        {
            pa = new POINT ();
            pa.px = Math.random () * pool.width;
            pa.py = Math.random () * pool.height;
            pa.vx = -2.5 + Math.random () * 5;
            pa.vy = -2.5 + Math.random () * 5;
            return pa;
        }

        private function render (e : Event = null) : void
        {
            if (pressed)
            { check (); }

            pool.update ();

            lines.length = 0;

            b.lock ();
            b.fillRect (r, 0);

            for (i = 0; i < quantity; i++)
            {
                pa = pool.num (i);

                for (j = 0; j < quantity; j++)
                {
                    if (j == i) break;

                    pb = pool.num (j);

                    dx = pb.px - pa.px;
                    dy = pb.py - pa.py;
                    d  = Math.sqrt (dx * dx + dy * dy);

                    if (d < distance)
                    {
                        ratio = 0xFF;
                        if (d > fade)
                        {
                            ratio = 0x40 + ((distance - d) / step * 0xBE);
                        }

                        line = new LINE ();
                        line.px = pa.px; line.py = pa.py;
                        line.tx = pb.px; line.ty = pb.py;
                        line.color = ratio << 24 | hsv2rgb ((d + hue) % 360);
                        lines.push (line);

                        connected [i] = connected [j] = 1;

                        // SPRING

                        pa.vx += dx * 0.00025;
                        pa.vy += dy * 0.00025;
                        pb.vx -= dx * 0.00025;
                        pb.vy -= dy * 0.00025;
                    }
                }
            }

            // Z-SORT BY COLOR LINES

            lines.sortOn ('color', Array.NUMERIC);

            // RENDER LINES

            j = lines.length;
            for (i = 0; i < j; i++)
            {
                line = lines [i];

                b.line (line.px, line.py, line.tx, line.ty, line.color);
            }

            b.applyFilter (b, r, p, f);

            // RENDER POINTS

            for (i = 0; i < quantity; i++)
            {
                pa = pool.num (i);
                m.tx = ~~ (-size * 0.5 + pa.px);
                m.ty = ~~ (-size * 0.5 + pa.py);
                b.draw (shape, m, connected [i] == 0 ? t : null);

                // RESET STATUS

                connected [i] = 0;
            }

            b.unlock ();
        }

        private function check () : void
        {
            if (type == 0)
            {
                if (pool.len < quantity_slider.maximum)
                {
                    pa = point ();
                    pa.px = stage.mouseX;
                    pa.py = stage.mouseY;

                    pool.add (pa);
                    quantity += 1;
                }
            }

            if (type == 1)
            {
                if (pool.len > quantity_slider.minimum)
                {
                    pool.del (pool.len-1);
                    quantity -= 1;
                }
            }

            quantity_slider.value = quantity;

            connected = new Vector.<int>(quantity, true);
        }

        private function press_left (e : MouseEvent) : void
        {
            type = 0;

            if (e.type == 'mouseDown' && stage.mouseY < h - 25)
            {
                pressed = true;
            }
            if (e.type == 'mouseUp') { pressed = false; }
        }

        private function press_right (e : MouseEvent) : void
        {
            type = 1;

            if (e.type == 'rightMouseDown' && stage.mouseY < h - 25)
            {
                pressed = true;
            }
            if (e.type == 'rightMouseUp'){ pressed = false; }
        }

        private function gui () : void
        {
            with (Style) { BACKGROUND = LABEL_TEXT = 0xFFFFFF; DROPSHADOW = BUTTON_FACE = 0x000000; }

            with (addChild (new Sprite ()))
            { graphics.beginFill (0x404040, 0.25); graphics.drawRect (0, 440, 465, 25); }

            distance_slider = new HUISlider (this, 10, 445, 'DISTANCE', _distance);
            with (distance_slider) { setSliderParams (0, 100, 75); width = 160; labelPrecision = 0; tick = 1; }

            quantity_slider = new HUISlider (this, 170, 445, 'QUANTITY', _quantity);
            with (quantity_slider) { setSliderParams (0, 100, quantity); width = 160; labelPrecision = 0; tick = 1; }

            var h : HUISlider = new HUISlider (this, 327, 445, 'HUE', _hue);
            h.setSliderParams (0, 360, hue); h.width = 160; h.labelPrecision = 0; h.tick = 1;
        }

        //

        private function _distance (e : Event = null) : void
        {
            distance = distance_slider.value;

            fade = distance * 0.75;
            step = distance - fade;
        }

        private function _hue (e : Event) : void
        {
            hue = e.target.value;
        }

        private function _quantity (e : Event) : void
        {
            var num : int;

            quantity = e.target.value;

            if (quantity > pool.len)
            {
                num = quantity - pool.len;

                for (i = 0; i < num; i++)
                {
                    pool.add (point ());
                }
            }
            if (quantity < pool.len)
            {
                num = pool.len - quantity;

                for (i = 0; i < num; i++)
                {
                    pool.del (pool.len-1);
                }
            }

            connected = new Vector.<int>(quantity, true);
        }

        private function hsv2rgb (h : Number = 0, s : Number = 1, v : Number = 1) : uint
        {
            var i : int = int (h / 60);
            var f : Number = h / 60 - i;
            var p : Number = v * (1 - s);
            var q : Number = v * (1 - s * f);
            var t : Number = v * (1 - s * (1 - f));

            switch (i)
            {
                case 0: return v * 0xFF << 16 | t * 0xFF << 8 | p * 0xFF << 0;
                case 1: return q * 0xFF << 16 | v * 0xFF << 8 | p * 0xFF << 0;
                case 2: return p * 0xFF << 16 | v * 0xFF << 8 | t * 0xFF << 0;
                case 3: return p * 0xFF << 16 | q * 0xFF << 8 | v * 0xFF << 0;
                case 4: return t * 0xFF << 16 | p * 0xFF << 8 | v * 0xFF << 0;
                case 5: return v * 0xFF << 16 | p * 0xFF << 8 | q * 0xFF << 0;
            }

            return 0;

            //  http://wonderfl.net/c/dtn8
        }
    }
}

//

final class LINE
{
    public var px : Number, py : Number;
    public var tx : Number, ty : Number;
    public var color : uint;
}

//

import flash.geom.Rectangle;

final class POOL extends Rectangle
{
    private var points : Vector.<POINT>;

    private var p : POINT;


    public function POOL (x : Number, y : Number, width : Number, height : Number)
    {
        super (x, y, width, height);

        points = new <POINT> [];
    }

    public function update () : void
    {
        var i : int = len;
        while (--i > -1)
        {
            p = points [i];

            p.px += p.vx;
            p.py += p.vy;

            if (p.px < x) { p.px = x; p.vx = -p.vx; }
            if (p.py < y) { p.py = y; p.vy = -p.vy; }
            if (p.px > x + width)  { p.px = width  + x; p.vx = -p.vx; }
            if (p.py > y + height) { p.py = height + y; p.vy = -p.vy; }
        }
    }

    public function add (p : POINT) : void
    {
        points.push (p);
    }

    public function del (index : uint) : void
    {
        points.splice (index, 1);
    }

    public function mod (index : uint, p : POINT) : void
    {
        points [index] = p;
    }

    public function num (index : uint) : POINT
    {
        return points [index];
    }

    public function get len () : uint
    {
        return points.length;
    }
}

final class POINT
{
    public var px : Number, py : Number;
    public var vx : Number, vy : Number;
}

//

import flash.display.BitmapData;

final class BRESENHAM extends BitmapData
{
    // http://en.wikipedia.org/wiki/Bresenham%27s_line_algorithm

    public function BRESENHAM (width : uint, height : uint, transparent : Boolean = true, color : uint = 0)
    {
        super (width, height, transparent, color);
    }

    public function line (x0 : int, y0 : int, x1 : int, y1 : int, color : uint = 0) : void
    {
        var dx : int = x1 - x0;
        var dy : int = y1 - y0;
        var sx : int = dx >= 0 ? 1 : -1;
        var sy : int = dy >= 0 ? 1 : -1;
        dx = dx >= 0 ? dx : -dx;
        dy = dy >= 0 ? dy : -dy;
        var err : int = dx - dy, e2 : int;

        while (true)
        {
            setPixel32 (x0, y0, color);

            if (x0 == x1 && y0 == y1) break;

            e2 = err << 1;
            if (e2 > -dy) { err -= dy; x0 += sx; }
            if (e2 <  dx) { err += dx; y0 += sy; }
        }
    }
}
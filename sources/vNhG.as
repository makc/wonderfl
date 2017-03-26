// forked from codeonwort's some effect

package
{
    /*
    * CLICK TO REGENERATE
    */

    import flash.geom.Point;
    import flash.geom.Matrix;
    import flash.geom.ColorTransform;

    import flash.events.Event;
    import flash.events.MouseEvent;

    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.display.Bitmap;
    import flash.display.BitmapData;

    import flash.display.GraphicsPath;
    import flash.display.IGraphicsData;
    import flash.display.GraphicsStroke;
    import flash.display.GraphicsSolidFill;
    
    import frocessing.color.ColorHSV;


    [ SWF (width = '465', height = '465', backgroundColor = '0x000000', frameRate = '25')]

    public class DREAMLIKE extends Sprite
    {
        private var color : ColorHSV = new ColorHSV (Math.random() * 360);

        private var g_val : Vector.<IGraphicsData>;
        private var g_dat : Vector.<Number>;
        private var g_com : Vector.<int>;

        private var g_str : GraphicsStroke = new GraphicsStroke (1);
        private var g_fil : GraphicsSolidFill;
        private var g_pat : GraphicsPath;

        private var shape : Shape = new Shape ();
        private var build : Boolean = false;
        private var datas : BitmapData;
        private var clone : BitmapData;
        private var point : Vector.<P>;

        private var mat_01 : Matrix;
        private var mat_02 : Matrix;
        private var mat_03 : Matrix;
        private var mat_04 : Matrix;

        private var stageW : Number;
        private var stageH : Number;


        public function DREAMLIKE ()
        {
            stage ? init () : addEventListener (Event.ADDED_TO_STAGE, init);
        }

        private function init () : void
        {
            if (hasEventListener (Event.ADDED_TO_STAGE))
            {
                removeEventListener (Event.ADDED_TO_STAGE, init);
            }

            stageH = stage.stageHeight;
            stageW = stage.stageWidth;
        
            stage.scaleMode = 'noScale';

            //

            mat_01 = new Matrix
            (
                1.02, 0, 0, 1.02,
                -stageW * 0.02, -stageH * 0.02
            );
            mat_02 = new Matrix
            (
                -1, 0, 0, -1,
                stageW, stageH
            );
            mat_03 = new Matrix
            (
                0, -1, 1, 0,
                0, stageH
            )
            mat_04 = new Matrix
            (
                0.5, 0.5, -0.5, 0.5,
                stageW - mat_01.tx, 0
            )

            //

            datas = new BitmapData
            (
                stageW, stageH, false, 0
            );

            clone = datas.clone ();

            addChild (new Bitmap (datas));

            //

            onGenerate ();

            //

            stage.addEventListener (MouseEvent.CLICK, onGenerate);

            stage.addEventListener (Event.ENTER_FRAME, onRender);
        }

        private function onRender (e : Event) : void
        {
            for each (var p : P in point) p.update ();

            onDraw ();

            //

            datas.lock ();

            datas.colorTransform (datas.rect, new ColorTransform (1, 1, 1, .99));
            datas.draw (datas, mat_01, null, null, null, true);

            clone.draw (datas, mat_02);
            clone.draw (shape, mat_03);

            datas.draw (clone);
            datas.draw (clone, mat_04);

            datas.unlock ();
        }
        
        private function onDraw () : void
        {
            shape.graphics.clear ();

            g_str.fill = new GraphicsSolidFill (color.value);

            g_dat = new Vector.<Number>();

            for (var i : uint = 0; i < point.length-2; i += 2)
            {
                g_dat.push
                (
                    point[i].x, point[i].y,
                    point[i+1].x, point[i+1].y, point[i+2].x, point[i+2].y
                );
            }

            g_pat = new GraphicsPath (g_com, g_dat);

            g_val = new Vector.<IGraphicsData>();
            g_val.push (g_str, g_pat);

            shape.graphics.drawGraphicsData (g_val);

            //

            color.h += 0.5;
        }

        private function onGenerate (e : MouseEvent = null) : void
        {
            var n_curves : uint;

            if (build)                                                     // RANDOM VALUES
            {
                n_curves = 3 + Math.round(Math.random () * 9);    // CURVES WANTED (3 - 12)

                mat_01.a = 1.005 + (Math.random () * 0.02);
                mat_01.d = 1.005 + (Math.random () * 0.02);

                mat_01.tx = -stageW * (mat_01.a - 1);
                mat_01.ty = -stageH * (mat_01.d - 1);

                mat_04.tx = stageW - mat_01.tx;
            }
            else
            {
                n_curves = 9;      // USE HARD CODED MATRIX AND CURVES NUMBER AT FIRST RUN
            }

            var n_points : uint = 3 + (--n_curves * 2);                   // POINTS NEEDED

            point = new Vector.<P>;

            g_com = new Vector.<int>();

            for (var i : uint = 0; i < n_points; i++)
            {
                point [i] = new P
                (
                    i * (stageW / (n_points - 1)), stageW, stageH
                );

                g_com.push (1, 3); // UPDATE GRAPHICSPATH COMMMANDS LENGTH LINE TO / CURVE TO
            }

            datas.fillRect (datas.rect, 0); // FILL LAYER INSTEAD OF MERGING WITH THE NEW ONE

            build = true;
        }
    }
}

internal class P
{
    public var x : Number;
    public var y : Number;
    public var d : Number;
    public var v : Number;

    public function P (x : Number, y : Number, d : Number)
    {
        this.x = x;
        this.y = y;
        this.d = d;
        this.v = y;
    }

    public function update () : void
    {
        y += (y < v ? 1.5 : -1.5);

        if    (Math.abs (y - v) < 1)
        {
            v = d/2 + Math.random() * 100;
        }
    }
}

    /**
    *    @author SPANVEGA // CHRISTIAN //
    **/
package
{
    import flash.display.*;
    import com.bit101.components.*;

    /**  @author SPANVEGA // CHRISTIAN  **/

    [ SWF (width = '465', height = '465', backgroundColor = '0xFFFFFF', frameRate = '25')]

    public class P_F extends Sprite
    {
        public function P_F ()
        {
            stage.scaleMode = 'noScale';

            addChild (new Bitmap ());

            with (addChild (new Sprite ())) { graphics.beginFill (0xFFFFFF, 0.5); graphics.drawRect (0, 440, 465, 25); }

            with (Style) { LABEL_TEXT = BUTTON_FACE = 0x000000; BACKGROUND = DROPSHADOW = BUTTON_DOWN = 0xFFFFFF; }

            var h : HUISlider = new HUISlider (this, 10, 445, 'GRAIN', update); h.setSliderParams (0, 10, 5); h.width = 405;

            var c : CheckBox = new CheckBox (this, 410, 449, 'COLOR', update); c.selected = true;

            update ();

            //

            function update () : void
            {
                Bitmap (getChildAt(0)).bitmapData = new PLASMA_FRACTAL (465, 465, h.value, c.selected);
            }
        }
    }
}


import flash.display.BitmapData;

internal class PLASMA_FRACTAL extends BitmapData
{
    private var color : Boolean, grain : Number;

/*
    http://www.ic.sunysb.edu/Stu/jseyster/plasma/

    http://en.wikipedia.org/wiki/Diamond-square_algorithm
*/

    public function PLASMA_FRACTAL (w : uint, h : uint, grain : Number, color : Boolean) : void
    {
        super (w, h, false, 0xFFFFFF);

        this.grain = grain; this.color = color;

        divide (0, 0, w , h, Math.random (), Math.random (), Math.random (), Math.random ());
    }

    private function displace (n : Number) : Number
    {
        return (-0.5 + Math.random ()) * (n / (width + height) * grain);
    }

    private function rgb (n : Number) : uint
    {
        if (color)
        {
            var r : Number = (n < 0.5 ? n * 2 : (1.0 - n) * 2);
            var g : Number = (n >= 0.3 && n < 0.8 ? (n - 0.3) * 2 : (n < 0.3) ? (0.3 - n) * 2 : (1.3 - n) * 2);
            var b : Number = (n >= 0.5 ? (n - 0.5) * 2 : (0.5 - n) * 2);

            return r * 0xFF << 16 | g * 0xFF << 8 | b * 0xFF;
        }
        else
        {
            return n * 0xFF << 16 | n * 0xFF << 8 | n * 0xFF;
        }
    }

    private function divide (x : Number, y : Number, w : Number, h : Number, c1 : Number, c2 : Number, c3 : Number, c4 : Number) : void
    {
        var u : Number = w / 2;
        var v : Number = h / 2;

        var c : Number = (c1 + c2 + c3 + c4) / 4;

        if (w > 1 || h > 1)
        {
            var md : Number = c + displace (u + v);
            var e1 : Number = (c1 + c2) / 2;
            var e2 : Number = (c2 + c3) / 2;
            var e3 : Number = (c3 + c4) / 2;
            var e4 : Number = (c4 + c1) / 2;

            md = (md < 0 ? 0 : md > 1 ? 1 : md);
        
            divide (x, y, u, v, c1, e1, md, e4);
            divide (x + u, y, u, v, e1, c2, e2, md);
            divide (x + u, y + v, u, v, md, e2, c3, e3);
            divide (x, y + v, u, v, e4, md, e3, c4);
        }
        else
        {
            setPixel (x >> 0, y >> 0, rgb (c));
        }
    }
}
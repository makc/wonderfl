package
{
    // CLICK TO RESET

    import flash.geom.*;
    import flash.events.*;
    import flash.filters.*;
    import flash.display.*;

    /**  @author SPANVEGA // CHRISTIAN  **/

    [ SWF (width = '465', height = '465', backgroundColor = '0x000000', frameRate = '30')]

    public class SLICES extends Sprite
    {
        private var w : uint = 466, h : uint = 466;

        private var s : BitmapData = new BitmapData (w, h, true, 0);
        private var r : Rectangle  = new Rectangle (0, 0, w / 2, h / 2);
        private var e : BitmapData = new BitmapData (w / 2, h / 2, true, 0),
                    d : BitmapData = e.clone ();

        private var b : BlurFilter = new BlurFilter (1.5, 1.5, 2);
        private var o : Array = [new Point(), new Point()];
        private var v : Vector.<Matrix> = new <Matrix>
        [
            new Matrix ( 1, 0, 0, -1, 0, h),
            new Matrix (-1, 0, 0,  1, w, 0),
            new Matrix (-1, 0, 0, -1, w, h)
        ];
        private var a : Array = map ();
        private var seed : uint = 0xCC;

        private var n : Number = Math.random () * 360;
        private var c : uint;

        private var p : Point = new Point (0, 0);
        private var octaves : uint = 2;
        private var i : int;

        private var ca : ColorTransform = new ColorTransform (1, 1, 1, 0.99);
        private var cb : ColorTransform = new ColorTransform ();


        public function SLICES ()
        {
            stage.scaleMode = 'noScale';
            stage.quality = 'low';

            graphics.beginFill (0, 1);
            graphics.drawRect  (0, 0, w, h);

            addChild (new Bitmap (s));

            stage.addEventListener (Event.ENTER_FRAME, render);
            stage.addEventListener (MouseEvent.CLICK,  reset);
        }

        private function reset ($ : Event) : void
        {
            seed += 1;

            s.fillRect (s.rect, 0);

            for (i = 0; i < octaves; i++)

            o[i].offset (0, 0);
        }

        private function render ($ : Event) : void
        {
            o[1].y =- (o[0].y -= 0.5);

            c = hsv2rgb ((n += 0.25) % 360, 1, 1);

            e.perlinNoise (233, 233, octaves, seed, true, true, 1, true, o);

            d.paletteMap (e, r, p, a);
            d.threshold (d, r, p, '<', 0xFF800000, 0);
            d.applyFilter (d, r, p, b);

            cb.redOffset   = c <<  8 >>> 24;
            cb.greenOffset = c << 16 >>> 24;
            cb.blueOffset  = c << 24 >>> 24;

            d.colorTransform (r, cb);

            s.colorTransform (s.rect, ca);
            s.copyPixels (d, r, p, null, null, true);

            v.forEach (draw);
        }

        private function draw (m : Matrix, n : Number, v : Vector.<Matrix>) : void
        {
            s.draw (d, m, null, null, null, true);
        }

        private function map () : Array
        {
            a = [];

            for (i = 0; i < 0xFF; i++)

            a [i] = 0x50 + (i % 10 == 0 ? 0x3C : 0) << 16;

            return a;
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
        }
    }
}
package
{
    // CLICK TO RESET

    import flash.geom.*;
    import flash.filters.*;
    import flash.display.*;
    import flash.utils.getTimer;

    /**  @author SPANVEGA // CHRISTIAN  **/

    [ SWF (width = '465', height = '465', backgroundColor = '0xFFFFFF', frameRate = '25')]

    public class CUTS extends Sprite
    {
        private var r : Rectangle = new Rectangle (0, 0, 465, 465), p : Point = new Point (0, 0);
        private var s : BitmapData, e : BitmapData = new BitmapData (465, 465, true, 0);
        private var c : ColorTransform = new ColorTransform (1, 1, 1, 0.99999);
        private var b : BlurFilter = new BlurFilter (1.5, 1.5, 5);
        private var o : Array = [new Point (), new Point ()];
        private var n : uint = 0xAAA;
        private var t : Number;

        public function CUTS ()
        {
            Wonderfl.disable_capture ();
            stage.scaleMode = 'noScale';

            addChild (new Bitmap (s = e.clone ()));

            stage.addEventListener ('enterFrame', function () : void
            {
                t = getTimer ();

                o[1].x =- (o[0].x = Math.sin (t * 0.00005) * 250);
                o[1].y =- (o[0].y = Math.cos (t * 0.00005) * 250);

                e.perlinNoise (200, 200, 2, n, true, true, 7, true, o);

                e.threshold (e, r, p, '!=', 0xFF808080, 0);
                e.applyFilter (e, r, p, b);

                e.draw (e, null, null, 'add'); e.draw (e, null, null, 'add');
                e.threshold (e, r, p, '==', 0xFFFFFFFF, 0);

                s.colorTransform (r, c);
                s.copyPixels (e, r, p, null, null, true);
            });

            stage.addEventListener ('click', function () : void { s.fillRect (r, 0); n = Math.random () * 0xFFFF; });
        }
    }
}
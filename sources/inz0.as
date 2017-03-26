package
{
    // CLICK TO RESET

    import flash.events.*;
    import flash.display.*;
    import flash.utils.getTimer;
    import flash.filters.DisplacementMapFilter;
    
    /**  @author SPANVEGA // CHRISTIAN  **/

    [ SWF (width = '465', height = '465', backgroundColor = '0x000000', frameRate = '30')]

    public class BLU extends Sprite
    {
        private var e : BitmapData = new BitmapData (465, 465, false, 0), m : BitmapData = e.clone (), s : BitmapData = m.clone ();
        private var f : DisplacementMapFilter = new DisplacementMapFilter (m, m.rect.topLeft, 4, 4, 0, 0, 'wrap');

        public function BLU ()
        {
            Wonderfl.disable_capture ();
            stage.scaleMode = 'noScale';

            render ();

            addChild (new Bitmap (s));

            stage.addEventListener (Event.ENTER_FRAME, frame);
            stage.addEventListener (MouseEvent.CLICK, render);
        }

        private function render ($ : Event = null) : void
        {
            m.fillRect (m.rect, 0);

            for (var i : uint = 1; i <= 10; i++)
            {
                e.perlinNoise (50 * i, 50 * i, 2, Math.random () * 0xFFFF, true, true, 4, false);
                m.draw (e, null, null, 'difference');
            }
            m.draw (m, null, null, 'add');
        }

        private function frame ($ : Event) : void
        {
            f.scaleX = f.scaleY = Math.cos (getTimer () * 0.0005) * 250;

            s.copyPixels  (m, m.rect, m.rect.topLeft);
            s.applyFilter (s, s.rect, s.rect.topLeft, f);
        }
    }
}
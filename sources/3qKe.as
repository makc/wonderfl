// forked from christian's flash on 2012-2-23
package
{
    import flash.geom.*;
    import flash.filters.*;
    import flash.display.*;
    import flash.events.Event;
    import flash.utils.getTimer;

    [ SWF (width = '465', height = '465', backgroundColor = '0xFFFFFF', frameRate = '20')]

    public class FlashTest extends Sprite
    {
        private var e : BitmapData = new BitmapData (465, 465, true, 0x00), s : BitmapData = e.clone ();
        private var c : ColorTransform = new ColorTransform (1, 1, 1, 0.9999999);
        private var b : BlurFilter = new BlurFilter (1.5,1.5,15);
        private var o : Array = [new Point (), new Point ()];
        private var t : Number;
        private var r : Number = Math.random()*250 + 50;

        public function FlashTest ()
        {
            Wonderfl.disable_capture ();
            stage.scaleMode = 'noScale';

            addChild (new Bitmap (s));

            addEventListener (Event.ENTER_FRAME, render);
        }

        private function render ($ : Event = null) : void
        {
            t = getTimer ();

            o[1].x =- (o[0].x = Math.sin (t * 0.00005) * r);
            o[1].y =- (o[0].y = Math.cos (t * 0.00005) * r);

            e.perlinNoise (200, 200, 2, 0xAAA, true, true, 0, true, o);

            e.threshold (e, e.rect, e.rect.topLeft, '!=', 0xFF808080, 0x00000000);
            e.applyFilter (e, e.rect, e.rect.topLeft, b);

            e.draw (e, null, null, BlendMode.SCREEN, null, true);
            
            s.copyPixels (e, e.rect, e.rect.topLeft, null, null, true);
        }
    }
}
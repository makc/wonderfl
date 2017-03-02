package
{
    /*
    * CLICK TO REGENERATE
    */

    import flash.geom.Point;
    import flash.geom.Matrix;
    import flash.geom.Rectangle;

    import flash.events.Event;
    import flash.events.MouseEvent;

    import flash.display.BlendMode;
    import flash.display.BitmapData;
    
    import flash.filters.BlurFilter;

    import org.papervision3d.view.BasicView;
    import org.papervision3d.objects.primitives.Cube;

    import org.papervision3d.materials.BitmapMaterial;
    import org.papervision3d.materials.utils.MaterialsList;

    /**
    *    @author SPANVEGA // CHRISTIAN //
    **/

    [ SWF (width = '465', height = '465', backgroundColor = '0x000000', frameRate = '25')]

    public class BLUE_SKETCH extends BasicView
    {
        private var pn_off : Point = new Point (0.5, 0.5);
        private var pn_v01 : Point = new Point ();
        private var pn_v02 : Point = new Point ();

        private var pn_bsX : uint;
        private var pn_bsY : uint;
        private var pn_rsd : int;

        //

        private var model : BitmapData;
        private var pixel : BitmapData;
        private var colAr : Array;

        //

        private var brF_01 : BlurFilter;

        private var mat_01 : Matrix;
        private var mat_02 : Matrix;
        private var mat_03 : Matrix;
        private var mat_04 : Matrix;

        private var bdM_01 : String;
        private var bdM_02 : String;

        // --o PV3D

        private var bmat : BitmapMaterial;
        private var cube : Cube;

        //

        private var W : uint;
        private var H : uint;


        public function BLUE_SKETCH ()
        {
            Wonderfl.disable_capture ();

            stage ? init () : addEventListener (Event.ADDED_TO_STAGE, init);
        }

        private function init (e : Event = null) : void
        {
            if (hasEventListener (Event.ADDED_TO_STAGE))
            {
                removeEventListener (Event.ADDED_TO_STAGE, init);
            }

            stage.scaleMode = 'noScale';

            onResize ();

            //

            var size : uint = 200;

            mat_01 = new Matrix
            (
                -1, -1, -1,  0, size, size
            );
            mat_02 = new Matrix
            (
                -1, -1, 0, -1, size, size
            );
            mat_03 = new Matrix
            (
                -1, 0, 0, 1, size * 2, 0
            );
            mat_04 = new Matrix
            (
                1, 0, 0, -1, 0, size * 2
            );

            brF_01 = new BlurFilter
            (
                1.1, 1.1, 10
            );

            bdM_01 = BlendMode.ADD;

            bdM_02 = BlendMode.HARDLIGHT;

            onRandom ();

            //

            pixel = new BitmapData
            (
                size * 2, size * 2, true, 0
            );

            model = new BitmapData
            (
                size, size, true, 0
            );

            // --o PV3D

            bmat = new BitmapMaterial (pixel, true);
            bmat.doubleSided = true;

            cube = new Cube
            (   
                new MaterialsList ({ all : bmat }),
                250, 250, 250,
                1,   1,   1
            );
            cube.z = -500;

            super.scene.addChild (cube);

            super.startRendering ();

            //

            stage.addEventListener (Event.RESIZE, onResize);

            stage.addEventListener (MouseEvent.CLICK, onRandom);
        }

        private function onResize (e : Event = null) : void
        {
            H = stage.stageHeight;
            W = stage.stageWidth

            //

            var m : Matrix = new Matrix ();
            m.createGradientBox (10, H);
            m.rotate (45);

            graphics.clear ();
            graphics.beginGradientFill
            (
                'linear', [0x0000000, 0x000033], [1, 1], [204, 255], m, 'repeat'
            );
            graphics.drawRect  (0, 0, W, H);
        }

        private function onRandom (e : MouseEvent = null) : void
        {
            pn_rsd = Math.round (-250 + Math.random () * 500);

            pn_bsX = Math.round  (100 + Math.random () * 50);
            pn_bsY = Math.round  (100 + Math.random () * 50);

            //

            colAr = [];

            for (var i : uint = 0; i < 255; i++)
            {
                colAr.push (Math.random () * i);
            }
        }

         override protected function onRenderTick (e : Event = null) : void
        {
            pn_v01.x =- (pn_v02.x += pn_off.x);
            pn_v01.y =- (pn_v02.y += pn_off.y);

            // --o MODEL

            model.perlinNoise
            (
                pn_bsX, pn_bsY, 2, pn_rsd, false, true, 7, true, [pn_v01, pn_v02]
            );

            model.draw
            (
                model, null, null, bdM_01
            );

            model.paletteMap
            (
                model, model.rect, model.rect.topLeft, colAr, colAr, colAr
            );

            model.threshold
            (
                model, model.rect, model.rect.topLeft, '==', 0xFF000000, 0x00000000
            );

            model.draw
            (
                model, null, null, bdM_02
            );

            model.applyFilter
            (
                model, model.rect, model.rect.topLeft, brF_01
            );

            // --o COMPOSITE

            pixel.fillRect (pixel.rect, 0x00000000);

            // --o PIECES 1, 2

            pixel.draw (model, mat_01);
            pixel.draw (model, mat_02);

            // --o PIECES 3, 4

            pixel.draw (pixel, mat_03);

            // --o PIECES 5, 6, 7, 8

            pixel.draw (pixel, mat_04);

            //

            cube.rotationY += (mouseX - (W / 2)) / 100;
            cube.rotationX += (mouseY - (H / 2)) / 100;

            super.onRenderTick ();
        }
    }
}
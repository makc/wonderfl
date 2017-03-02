package
{
    // CLICK TO RANDOMIZE

    import flash.geom.*;
    import flash.events.*;
    import flash.display.*;

    import frocessing.color.ColorHSV;

    /**  @author SPANVEGA // CHRISTIAN  **/

    [ SWF (width = '465', height = '465', backgroundColor = '0x000000', frameRate = '25')]
    
    public class TERRACES extends Sprite
    {
        private var c : ColorTransform = new ColorTransform (1, 1, 1, 0.97);

        private var color : ColorHSV = new ColorHSV (Math.random () * 360);

        private var g_val : Vector.<IGraphicsData> = new <IGraphicsData>[];
        private var g_dat : Vector.<Number> = new <Number>[];
        private var g_com : Vector.<int> = new <int>[];

        private var g_str : GraphicsStroke = new GraphicsStroke (1);
        private var g_pat : GraphicsPath;

        private var image : BitmapData, map : BitmapData;
        private var shape : Shape = new Shape ();

        private var W : uint, H : uint, i : int;

        private var pn_of : Array = [new Point (), new Point ()];
        private var pn_bx : Number, pn_by : Number, pn_sd : int;


        public function TERRACES ()
        {
            Wonderfl.disable_capture ();

            stage ? init () : addEventListener (Event.ADDED_TO_STAGE, init);
        }

        private function init ($ : Event = null) : void
        {
            if (hasEventListener (Event.ADDED_TO_STAGE))
            {removeEventListener (Event.ADDED_TO_STAGE, init);}

            stage.scaleMode = 'noScale';
            stage.align = 'TL';

            W = stage.stageWidth;
            H = stage.stageHeight;

            graphics.beginFill (0, 1);
            graphics.drawRect  (0, 0, W, H);

            //

            addChild (new Bitmap (image = new BitmapData (W, H)));

            map = new BitmapData (W, 1);

            graphicsCommands ();

            random ();

            //

            stage.addEventListener (Event.ENTER_FRAME, render);
            stage.addEventListener (MouseEvent.CLICK, random);
        }

        private function render ($ : Event) : void
        {
            update_map ();

            shape.graphics.clear ();

            g_str.fill = new GraphicsSolidFill (color.value, 1);

            for (i = 0; i < map.width; i ++)

            g_dat.push (i, (H / 1.75 - 0xE8) + ((map.getPixel (i, 0) & 0xE8) * 2));

            //

            g_pat = new GraphicsPath (g_com, g_dat);

            g_val.push (g_str, g_pat);

            shape.graphics.drawGraphicsData (g_val);

            g_dat.length = g_val.length = 0;

            //

            image.colorTransform (image.rect, c);
            image.scroll (0, -1);
            image.draw (shape);

            color.h += 0.5;
        }

        private function random ($ : MouseEvent = null) : void
        {
            pn_sd = Math.random () * 0xFFFFFF;
            pn_bx = W * (0.5 + Math.random () * 0.5);
            pn_by = H * (0.5 + Math.random () * 0.5);

            image.fillRect (image.rect, 0);
        }

        private function graphicsCommands () : void
        {
            g_com = new <int> [1];
 
            for (i = 1; i < map.width; i++)

            g_com.push (2);
        }

        private function update_map () : void
        {
            pn_of[0].x =- (pn_of[1].x += 2);
            pn_of[0].y =- (pn_of[1].y += 2);

            map.perlinNoise (pn_bx, pn_by, 2, pn_sd, false, true, 1, true, pn_of);
        }
    }
}
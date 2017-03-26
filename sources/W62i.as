package
{
    import flash.display.Sprite;
    import flash.geom.Rectangle;

    import starling.core.Starling;

    /* @author SPANVEGA // CHRISTIAN */

    public class WARP extends Sprite
    {
        public function WARP ()
        { 
            with (stage) { align = 'TL'; frameRate = 60; scaleMode = 'noScale'; color = 0xFFFFFF; }

            var viewport : Rectangle = new Rectangle (0, 0, stage.stageWidth, stage.stageHeight);

            new Starling (Main, stage, viewport).start ();

            Wonderfl.disable_capture();
        }
    }
}


import flash.geom.*;
import flash.display.BitmapData;
import flash.display3D.textures.Texture;
// import flash.display3D.textures.RectangleTexture;

import starling.events.*;
import starling.display.*;
import starling.core.Starling;
import starling.textures.Texture;

class Main extends starling.display.Sprite
{
    private var o : Array = [new Point (), new Point ()];

    private var texture : starling.textures.Texture;

    private var b : BitmapData, t : BitmapData;

    private var seed : uint = SEED.generate ();

    private var w : uint, h : uint;

    private var iterations : int;

    private var speed : int = 25;


    public function Main ()
    {
        w = Starling.current.stage.stageWidth;
        h = Starling.current.stage.stageHeight;

        b = new BitmapData (w, h, false, 0xFFFFFF);

        t = new BitmapData (w, 1, true, 0);

        generate (h);

        texture = starling.textures.Texture.fromBitmapData (b);

        addChild (new Image (texture));

        addEventListener (Event.ENTER_FRAME, frame);

        Starling.current.stage.addEventListener (TouchEvent.TOUCH, touch);
    }

    private function generate (n : int) : void
    {
        for (var i : int = 0; i < n; i++)
        {
            Point (o[0]).x += 1.0;

            t.perlinNoise (155, 1, 4, seed, false, false, 15, false, o);

            b.scroll (0, 1);
            b.draw (t);
        }
    }

     private function frame (e : Event) : void
    {
        generate (iterations);

        flash.display3D.textures.Texture (texture.base).uploadFromBitmapData (b);
/*
        starling 2.0 fix
        flash.display3D.textures.RectangleTexture (texture.base).uploadFromBitmapData (b);
*/
    }

    private function touch (event : TouchEvent) : void
    {
        var touch : Touch = event.getTouch (Starling.current.stage);

        if (touch)
        {
            iterations = 1 + speed - (touch.globalY / h) * speed;

            if (touch.phase == TouchPhase.BEGAN)
            {
                SEED.generate ();

                generate (h);
            }
        }
    }
}

final class SEED
{
    public static function generate () : int
    {
        var n : int = Math.random () * 10000 + 1;

        if (ERROR_SEEDS.indexOf (n) >= 0) n++;

        return n;
    }

    public static const ERROR_SEEDS : Array = [346, 514, 1155, 1519, 1690, 1977, 2327,
               2337, 2399, 2860, 2999, 3099, 4777, 4952, 5673, 6265, 7185, 7259, 7371,
               7383, 7717, 7847, 8032, 8350, 8676, 8963, 8997, 9080, 9403, 9615, 9685];
}
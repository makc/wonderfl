package
{
    import flash.display.Sprite;
    import flash.geom.Rectangle;

    import starling.core.Starling;

    /* @author SPANVEGA // CHRISTIAN */

    public class DEPTHS extends flash.display.Sprite
    {
        public function DEPTHS ()
        {
            with (stage) { align = 'TL'; frameRate = 30; scaleMode = 'noScale'; color = 0x000000; }

            var viewport : Rectangle = new Rectangle (0, 0, stage.stageWidth, stage.stageHeight);

            new Starling (Main, stage, viewport).start ();

            Wonderfl.disable_capture ();
        }
    }
}


import flash.geom.*;
import flash.display.BlendMode;
import flash.display.BitmapData;
import flash.display3D.textures.RectangleTexture;

import starling.events.*;
import starling.core.Starling;
import starling.display.Image;
import starling.display.Sprite;
import starling.textures.Texture;

class Main extends starling.display.Sprite
{
    private var texture : starling.textures.Texture;

    private var px : Number, py : Number, // pivot

                w : uint, h : uint,

                dx : Number = 0,
                dy : Number = 0,

                speed : int = 4;

    private var depth : DEPTH;


    public function Main ()
    {
        depth = new DEPTH (w = Starling.current.stage.stageWidth,
                           h = Starling.current.stage.stageHeight,
                           0xFFFF80); // 0xFFF8DC

        px = w / 2; py = h / 2;

        texture = starling.textures.Texture.fromBitmapData (depth);

        addChild (new Image (texture));

        addEventListener (Event.ENTER_FRAME, frame);

        Starling.current.stage.addEventListener (TouchEvent.TOUCH, touch);
    }

     private function frame (e : Event) : void
    {
        depth.render (dx, dy);

        // Starling 2.0 fix 
        // RectangleTexture (texture.base).uploadFromBitmapData (depth);

        flash.display3D.textures.Texture (texture.base).uploadFromBitmapData (depth);
    }

    private function touch (event : TouchEvent) : void
    {
        var touch : Touch = event.getTouch (Starling.current.stage);

        if (touch)
        {
            dx = speed * (touch.globalX - px) / px % speed;
            dy = speed * (touch.globalY - py) / py % speed;
        }
    }
}

final class DEPTH extends BitmapData
{
    private var m : Matrix = new Matrix (2, 0, 0, 2);
    private var vx : Number = 0, vy : Number = 0;
    private var t : ColorTransform;
    private var b : BitmapData;


    public function DEPTH (width : int, height : int, tint : uint)
    {
        super (width, height);

        b = new BitmapData (even (width) / 2, even (height) / 2);

        t = new ColorTransform
        (
            (tint >> 16 & 0xFF) / 0xFF,
            (tint >>  8 & 0xFF) / 0xFF,
            (tint       & 0xFF) / 0xFF, 
            0.9
        );

        for (var i : int = 0; i < numOctaves; i++) { offsets [i] = new Point (0, 0); }
    }

    private function even (n : Number) : int
    {
        return n % 2 == 0 ? n : n + 1; 
    }

    public function render (dx : Number, dy : Number) : void
    {
        vx -= dx; 
        vy -= dy;

        for (var i : int = 1; i <= numOctaves; i++)
        {
            Point (offsets [i - 1]).x = vx / i;
            Point (offsets [i - 1]).y = vy / i;
        }

        b.perlinNoise (baseX * i, baseY * i, numOctaves, randomSeed, stitch, fractalNoise, channelOptions, grayScale, offsets);

        draw (b, m, null, BlendMode.DARKEN, null, false);

        colorTransform (rect, t);
    }

    public var baseX : Number = 50;

    public var baseY : Number = 50;

    public var numOctaves : uint = 6;

    public var randomSeed : int = SEED.generate ();

    public var stitch : Boolean = false;

    public var fractalNoise: Boolean = true;

    public var channelOptions : uint = 4;

    public var grayScale : Boolean = true;

    public var offsets : Array = new Array (numOctaves);
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
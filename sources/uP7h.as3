package
{
    import flash.geom.*;
    import flash.media.*;
    import flash.events.*;
    import flash.display.*;
    import flash.net.URLRequest;
    import flash.filters.GlowFilter;

    public class LOOPS extends Sprite
    {
        private var g : GlowFilter = new GlowFilter (0, 1, 5, 5, 10, 1);
        private var t : ColorTransform = new ColorTransform (1, 1, 1, 0.95);

        private var matrix : Matrix = new Matrix (), focale : Number;
        
        private var colors : Array = [0x000000, 0x404040, 0xFFFFFF];
        private var ratios : Array = [0, 128, 255];
        private var alphas : Array = [1, 1, 0];

        private var w : Number, h : Number, q : Number = 0;

        private var shape : Shape = new Shape ();
        private var image : BitmapData;

        private var pivot : Point = new Point ();

        private var player : NOTE_PLAYER;

        private var area : AREA;


        public function LOOPS () { addEventListener (Event.ADDED_TO_STAGE, init); }

        private function init (e : Event) : void
        {
            Wonderfl.disable_capture ();

            removeEventListener (Event.ADDED_TO_STAGE, init);

            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.color = 0x000000;
            stage.frameRate = 30;

            pivot.x = (h = 465) / 2;
            pivot.y = (w = 465) / 2;

            var s : Sound = new Sound ();
            s.addEventListener (Event.COMPLETE, setup);
            s.addEventListener (ProgressEvent.PROGRESS, progress);
            s.load (new URLRequest ('http://mm4d.free.fr/tracks/breaks/sample_c.mp3'), new SoundLoaderContext (1000, true));
        }
        
        private function progress (e : ProgressEvent) : void
        {
            graphics.clear ();
            graphics.lineStyle (1, 0x202020);
            graphics.drawRect (pivot.x - 102, pivot.y - 12, 204, 24);

            graphics.lineStyle (1, 0x404040);
            graphics.beginGradientFill
            (
                'linear',
                [0x000000, 0x202020, 0x808080, 0x202020, 0x000000],
                [0, 1, 1, 1, 0],
                [0, 64, 127, 192, 255],
                new Matrix (0.015, 0.015, -0.015, 0.015, q--, 0),
                'repeat'
            );
            graphics.drawRect (pivot.x - 100, pivot.y - 10, (e.bytesLoaded / e.bytesTotal) * 200, 20);
        }

        private function setup (e : Event = null) : void
        {
            removeEventListener (ProgressEvent.PROGRESS, progress);
            removeEventListener (Event.COMPLETE, setup);

            graphics.clear ();

            //

            area = new AREA (0, 0, w - 30, h - 30);
            area.addEventListener (AREA.HIT, hit);

            area.vx = w / 100;
            area.vy = h / 100;
            area.g  = 5;

            addChild (new Bitmap (image = new BitmapData (w, h, true, 0)));

            player = new NOTE_PLAYER (Sound (e.currentTarget));

            stage.addEventListener (Event.ENTER_FRAME, render);
        }

        private function render (e : Event = null) : void
        {
            area.update ();

            matrix.identity ();
            matrix.createGradientBox
            (
                w / (24 - Math.abs ((area.px - pivot.x) / pivot.x) * 12),
                w / (24 - Math.abs ((area.py - pivot.y) / pivot.y) * 12),
                0, area.px, area.py
            );

            focale =  ((area.px - pivot.x) / pivot.x) * 0.75;

            shape.graphics.clear ();
            shape.graphics.beginGradientFill ('radial', colors, alphas, ratios, matrix, 'reflect', 'rgb', focale);
            shape.graphics.drawRect (0, 0, w, h);

            image.colorTransform (image.rect, t);
            image.draw (shape, null, null, 'hardlight');

            if (q > 0)
            {
                g.color = hsv2rgb (Math.atan2 (pivot.x - area.px, pivot.y - area.py) / (Math.PI / 180), 1, 1);

                image.applyFilter (image, image.rect, image.rect.topLeft, g);

                q -= 10;
            }
        }

        private function hit (e : DATA_EVENT) : void
        {
            q += 100;

            switch (e.data)
            {
                case 'LEFT' : case 'RIGHT'  : player.noteOn (area.py / h, 0); break;
                case 'TOP'  : case 'BOTTOM' : player.noteOn (area.px / w, 1); break;
            }
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


import flash.events.*;
import flash.geom.Rectangle;

final class AREA extends Rectangle implements IEventDispatcher
{
    private var d : EventDispatcher;

    public var  g : Number = 0;
    public var vx : Number = 1;
    public var vy : Number = 1;
    public var px : Number;
    public var py : Number;

    /** Dispatch AREA.HIT Event **/

    static public const HIT : String = 'HIT';

    public function AREA (x : Number = 0, y : Number = 0, width : Number = 100, height : Number = 100)
    {
        d = new EventDispatcher ();

        super (x, y, width, height);

        px = x + Math.random () * width;
        py = y + Math.random () * height;
    }

    public function update () : void
    {
        px += vx;
        py += vy * (1 + (py - y) / height * g);

        if (px < x)
        {
            dispatchEvent (new DATA_EVENT (AREA.HIT, 'LEFT'));
            px = x;    vx = -vx;
        }
        if (px > x + width)
        {
            dispatchEvent (new DATA_EVENT (AREA.HIT, 'RIGHT'));
            px = x + width; vx = -vx;
        }
        if (py < y)
        {
            dispatchEvent (new DATA_EVENT (AREA.HIT, 'TOP'));
            py = y; vy = -vy;
        }
        if (py > y + height)
        {
            dispatchEvent (new DATA_EVENT (AREA.HIT, 'BOTTOM'));
            py = y + height; vy = -vy;
        }
    }

    public function addEventListener (type : String, listener : Function, useCapture : Boolean = false, priority : int = 0, useWeakReference : Boolean = false) : void
    {
        d.addEventListener(type, listener, useCapture, priority, useWeakReference);
    }

    public function removeEventListener (type : String, listener : Function, useCapture : Boolean = false) : void
    {
        d.removeEventListener (type, listener, useCapture);
    }   

    public function hasEventListener (type : String) : Boolean { return d.hasEventListener (type); }

    public function willTrigger (type : String) : Boolean { return d.willTrigger (type); }

    public function dispatchEvent (e : Event) : Boolean { return d.dispatchEvent (e); }
}


import flash.events.Event;

final class DATA_EVENT extends Event
{
    public var data : *;

    public function DATA_EVENT (type : String, data : * = null,  bubbles : Boolean = false, cancelable : Boolean = false)
    {
        super (type, bubbles, cancelable);

        this.data = data;
    }
}

import flash.media.Sound;
import org.si.sion.SiONVoice;
import org.si.sion.SiONDriver;
import org.si.sion.utils.SiONPresetVoice;
import org.si.sion.effector.SiEffectStereoDelay;

final class NOTE_PLAYER
{
    private var voice0 : SiONVoice  = new SiONPresetVoice () ['midi.pad8'];
    private var voice1 : SiONVoice  = new SiONPresetVoice () ['midi.drum24'];
    private var driver : SiONDriver = new SiONDriver ();

    public function NOTE_PLAYER (backgroundSound : Sound = null)
    {
        if (backgroundSound)

        driver.setBackgroundSound (backgroundSound, 0.20, 0);

        driver.fadeIn (10);
        driver.effector.setEffectorList (0, [new SiEffectStereoDelay (160, 0.9, true, 0.5)]);
        driver.play (null, false);
        driver.volume = 2.0;
    }

    public function noteOn (n : Number, v : int) : void 
    {
        driver.noteOff (-1, 0);                                   // TERNARY QUANTIZE
        driver.noteOn  (36 + int (n * 48), this ['voice' + v], 0, 0, 3, 0);
    }
}
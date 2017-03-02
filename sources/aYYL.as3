package
{
    import flash.geom.*;
    import flash.utils.*;
    import flash.events.*;
    import flash.display.*;
    import flash.media.Sound;
    import flash.net.URLRequest;
    import flash.filters.DisplacementMapFilter;

    import org.si.sion.SiONDriver;
    import org.si.utils.ByteArrayExt;
    import org.si.sion.utils.soundloader.SoundLoader;

    /**  @author SPANVEGA // CHRISTIAN  **/

    [ SWF (width = '465', height = '465', backgroundColor = '0x000000', frameRate = '30')]

    public class FACE extends Sprite
    {
        private var f : DisplacementMapFilter = new DisplacementMapFilter (b, p, 1, 2);
        private var m : Matrix = new Matrix ();
        private var p : Point = new Point ();
        private var l : SoundLoader;
        private var d : SiONDriver;
        private var b : BitmapData;
        private var c : BitmapData;
        private var o : BitmapData;
        private var r : Rectangle;
        private var t : Number;

        private var row : uint = 4, col : uint = 4;
        private var frames : uint = col * row;
        private var size : uint = 256;
        private var index : uint = 0;


        public function FACE ()
        {
            Wonderfl.disable_capture ();
            stage.scaleMode = 'noScale';

            graphics.beginFill (0, 1);
            graphics.drawRect (0, 0, 465, 465);

            l = new SoundLoader ();

            l.setURL (new URLRequest
            (
            'http://assets.wonderfl.net/images/related_images/7/7e/7e22/7e22434969ea2393130d8b21a7c56cc15531ae70'
            ),
            'spritesheet', 'img', true);

            l.setURL (new URLRequest
            (
            'http://assets.wonderfl.net/images/related_images/6/6c/6c0c/6c0ccd8e318992e483129046f3849fdf6827de00'
            ),
            'avatar', 'img', true);

            l.setURL (new URLRequest
            (
            'http://assets.wonderfl.net/images/related_images/f/f0/f048/f048bf16fc211a02973a9009860d138348fc928f'
            ),
            'sound', 'png', true);

            l.addEventListener (IOErrorEvent.IO_ERROR, function () : void {} );
            l.addEventListener (ProgressEvent.PROGRESS, progress);
            l.addEventListener (Event.COMPLETE, complete);

            l.loadAll ();
        }

        private function progress (e : ProgressEvent) : void
        {
            trace (((e.bytesLoaded / e.bytesTotal) * 100 | 0) + ' %');
        }

        private function complete (e : Event) : void
        {
            b = l.hash ['spritesheet'].bitmapData;
            b.draw (b, null, null, 'add');

            o = new BitmapData (size, size, false, 0);

            c = new BitmapData (size, size, false, 0xFFFFFF);

            var t : BitmapData = l.hash ['avatar'].bitmapData;
            m.ty = size - t.height >> 1;
            m.tx = size - t.width  >> 1;

            c.draw (t, m);

            r = new Rectangle (0, 0, size, size);

            with (addChild (new Bitmap (o)))
            { x = stage.stageWidth  - size >> 1;
              y = stage.stageHeight - size >> 1; };

            var bytes : ByteArrayExt = new ByteArrayExt ();
            bytes.fromBitmapData (l.hash ['sound'].bitmapData);

            var sound : Sound = new Sound ();
            sound.loadCompressedDataFromByteArray (bytes, bytes.length);
  
            d = new SiONDriver (2048, 2, 44100, 0);
            d.setBackgroundSound (sound, 0.5, 0);
            d.play ();

            setInterval (tick, 1000 / 30);
        }

        private function tick () : void
        {
            index += 1;
            index %= frames;

            r.x =     index % col  * size;
            r.y = ~~ (index / row) * size;

            o.copyPixels (b, r, p);
            o.draw (c, null, null, 'subtract');

            t = Math.sin (getTimer () / 100);

            f.mapBitmap = b;
            f.scaleX = -t;
            f.scaleY =  t;
            r.x = r.y = 0;

            o.applyFilter (o, r, p, f);
        }
    }
}
package
{
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageQuality;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    
    /*
     * THE FLASHMAFIA  |  ~ MAGIC DONUT ~
     *                 |  Genetically modified Midpoint circle algorithm
     *                 |  ref : http://en.wikipedia.org/wiki/Midpoint_circle_algorithm ,
     *                 |  and a touch of Particle Light.
     */
 
    [SWF(width = '465', height = '465', backgroundColor = '0x000000', frameRate = '32')]
    public class MagicDonut extends Sprite
    {
        private static var NUM_PARTICLES : int = 444444;
        private static var DEGREE : Number = 2.2;
        private static var RADIUS : Number = 888;
        private static var THICKNESS : Number = RADIUS / 3;
        private static var FREQ_X : Number = 444;
        private static var FREQ_Y : Number = 33;
        private var _p : Particle;
        private var _bitmapData : BitmapData;
        private var _buffer : Vector.<uint>;
        private var _zoom : Number;

        public function MagicDonut()
        {
            /* init canvas */

            var bmp : Bitmap = new Bitmap(_bitmapData = new BitmapData(stage.stageWidth, stage.stageWidth, false, 0x0));
            bmp.opaqueBackground = 0x0;
            addChild(bmp);
            _buffer = new Vector.<uint>(_bitmapData.width * _bitmapData.height, true);

            /* init display */

            mouseEnabled = mouseChildren = tabEnabled = tabChildren = false;
            stage.align = StageAlign.TOP_LEFT;
            stage.quality = StageQuality.LOW;
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.fullScreenSourceRect = _bitmapData.rect;

            /* setup data */

            var p : Particle = _p = new Particle();
            var th : Number = 0.0;

            var n : int = NUM_PARTICLES;
            while (--n != 0)
            {
                th += Math.PI * 2 / NUM_PARTICLES;
                p.x = p.ex = int((_bitmapData.width >> 1) + (RADIUS + THICKNESS * Math.sin(th * FREQ_X)) * Math.sin(th));
                p.y = p.ey = int((_bitmapData.height >> 1) + (RADIUS + THICKNESS * Math.cos(th * FREQ_Y)) * Math.cos(th));
                p.shx = 0.022 + 0.011 * Math.cos(th * FREQ_X);
                p.shy = 0.099 - p.shx;

                p = p.next = new Particle();
            }

            /* go */

            _zoom = 1;
            addEventListener(Event.ENTER_FRAME, animate);
        }

        private function animate(e : Event) : void
        {
            var sx : int = _bitmapData.width;
            var cx : int = sx >> 1;
            var cy : int = _bitmapData.height >> 1;

            _zoom *= 0.98;
            var ecos : Number = Math.cos((DEGREE * (1 + 5 * _zoom)) * Math.PI / 180);
            var esin : Number = Math.sin((DEGREE / (1 + 5 * _zoom)) * Math.PI / 180);
            var dx : Number;
            var dy : Number;

            // clear buffer
            var buflen : int = _buffer.length;
            var n : uint = buflen;
            while (--n != 0) _buffer[n] = 0x0;

            var p : Particle = _p;
            while (p != null)
            {
                /* ~ MAGIC ROTATION ~ */
                dx = p.ex - cx;
                dy = p.ey - cy;
                p.ex = cx + (ecos * dx - esin * dy);
                p.ey = cy + (ecos * dy + esin * dx);
                p.x += (p.ex - p.x) * p.shx;
                p.y += (p.ey - p.y) * p.shy;

                /* write buffer */
                n = p.y * sx + p.x;
                if (n < buflen) {
                    var c : uint = _buffer[n];
                    var r : uint = (c >> 16) + 44;
                    var g : uint = (c >> 8 & 0xFF) + 22;
                    var b : uint = (c & 0xFF) + 9;
                    r = (r > 255) ? 255 : r;
                    g = (g > 255) ? 255 : g;
                    b = (b > 255) ? 255 : b;

                    _buffer[n] = (r << 16) | (g << 8) | (g >> 1);
                }
                p = p.next;
            }
            _bitmapData.setVector(_bitmapData.rect, _buffer);
        }
    }
}

internal final class Particle
{
    public var x : int;
    public var y : int;
    public var ex : int;
    public var ey : int;
    public var shx : Number;
    public var shy : Number;
    public var next : Particle;
}
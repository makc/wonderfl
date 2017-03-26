package {
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.events.Event;

    [SWF(width = '465', height = '465')]
    public class DeathRay002 extends Sprite
    {
        private var bmd : BitmapData;
        private var buf : Vector.<uint>;
        private var mx : Number;
        private var my : Number;
        private var t : Number;
        private var fcnt : int;

        function DeathRay002()
        {
            stage.stageFocusRect = tabChildren = tabEnabled = mouseChildren = mouseEnabled = false;
            stage.scaleMode = "noScale";
            stage.align = "TL";
            stage.quality = "low";
            stage.frameRate = 64;
            opaqueBackground = 0x0;

            var bm : Bitmap = new Bitmap(bmd = new BitmapData(512, 512, false));
            bm.x = bm.y = (465 - 512) / 2;
            bm.opaqueBackground = 0x0;
            addChild(bm);

            buf = new Vector.<uint>(512 * 512, true);

            t = 314 * Math.random();
            mx = my = 256;

            stage.addEventListener(Event.ENTER_FRAME, oef);
        }

        private function oef(e : Event) : void
        {
            fcnt++;

            t = ((fcnt & 511) / 512) * 6.283185307179586;

            var wav1 : Number = Math.sin(t * 1.33);
            var wav2 : Number = Math.cos(t * 1.22);
            var wav3 : Number = Math.tan(t * -1.11);

            var mtx : Number = stage.mouseX + ((fcnt >> 4) & 1) * 128 * Math.random();
            var mty : Number = stage.mouseY + ((fcnt >> 5) & 1) * 256 * Math.random();

            mx += (mtx - mx) * 0.11;
            my += (mty - my) * 0.11;

            var cx : Number = -1 + 2 * (mx / 465);
            var cy : Number = -1 + 2 * (my / 465);

            /* eye */

            var ox : Number = cx + (0.1 / wav1);
            var oy : Number = cy + (0.1 / wav2);
            var oz : Number = -2 - (0.1 / wav3);

            /* lights */

            var lx0 : Number = cx + wav1;
            var ly0 : Number = cy;
            var lz0 : Number = cy;

            var lx1 : Number = cx;
            var ly1 : Number = cy + wav2;
            var lz1 : Number = cx;

            var lx2 : Number = cx + wav1;
            var ly2 : Number = cy + wav2;
            var lz2 : Number = (cx * cy) / 2;

            var lx3 : Number = cx;
            var ly3 : Number = cy;
            var lz3 : Number = cy;

            var step : uint = ((fcnt >> 4) & 1);
            var n : uint = (512 * 512) - 512 - (fcnt & 15);
            while (n > 512)
            {
                n--;
                n--;
                n--;
                n -= (step << ((fcnt >> 5) & 3));

                var px : uint = n & 511;
                var py : uint = n >> 9;

                var vx : Number = (px * (2 / 512)) - 1 - ox;
                var vy : Number = (py * (2 / 512)) - 1 - oy;

                var d0 : Number;
                var d1 : Number;
                var d2 : Number;
                var d3 : Number;

                var a : Number = ((1 - oz) / (-1 - oz) * vx) + ox;
                var b : Number = ((1 - oz) / (-1 - oz) * vy) + oy;

                if ((a >= -1) && (a <= 1) && (b >= -1) && (b <= 1)) // ===================================== OPPOSITE WALL
                {
                    d0 = 0xFF / ((a - lx0) * (a - lx0) + (b - ly0) * (b - ly0) + (1 - lz0) * (1 - lz0));
                    d1 = 0xFF / ((a - lx1) * (a - lx1) + (b - ly1) * (b - ly1) + (1 - lz1) * (1 - lz1));
                    d2 = 0xFF / ((a - lx2) * (a - lx2) + (b - ly2) * (b - ly2) + (1 - lz2) * (1 - lz2));
                    d3 = 0xFF / ((a - lx3) * (a - lx3) + (b - ly3) * (b - ly3) + (1 - lz3) * (1 - lz3));
                } else {
                    a = ((-1 - ox) / vx * (-1 - oz)) + oz;
                    b = ((-1 - ox) / vx * vy) + oy;

                    if ((a >= -1) && (a <= 1) && (b >= -1) && (b <= 1)) // ===================================== LEFT WALL
                    {
                        d0 = 0xFF / ((-1 - lx0) * (-1 - lx0) + (b - ly0) * (b - ly0) + (a - lz0) * (a - lz0));
                        d1 = 0xFF / ((-1 - lx1) * (-1 - lx1) + (b - ly1) * (b - ly1) + (a - lz1) * (a - lz1));
                        d2 = 0xFF / ((-1 - lx2) * (-1 - lx2) + (b - ly2) * (b - ly2) + (a - lz2) * (a - lz2));
                        d3 = 0xFF / ((-1 - lx3) * (-1 - lx3) + (b - ly3) * (b - ly3) + (a - lz3) * (a - lz3));
                    } else {
                        a = ((1 - ox) / vx * (-1 - oz)) + oz;
                        b = ((1 - ox) / vx * vy) + oy;

                        if ((a >= -1) && (a <= 1) && (b >= -1) && (b <= 1)) // ================================ RIGHT WALL
                        {
                            d0 = 0xFF / ((1 - lx0) * (1 - lx0) + (b - ly0) * (b - ly0) + (a - lz0) * (a - lz0));
                            d1 = 0xFF / ((1 - lx1) * (1 - lx1) + (b - ly1) * (b - ly1) + (a - lz1) * (a - lz1));
                            d2 = 0xFF / ((1 - lx2) * (1 - lx2) + (b - ly2) * (b - ly2) + (a - lz2) * (a - lz2));
                            d3 = 0xFF / ((1 - lx3) * (1 - lx3) + (b - ly3) * (b - ly3) + (a - lz3) * (a - lz3));
                        } else {
                            a = ((-1 - oy) / vy * vx) + ox;
                            b = ((-1 - oy) / vy * (-1 - oz)) + oz;

                            if ((a >= -1) && (a <= 1) && (b >= -1) && (b <= 1)) // =============================== CEILING
                            {
                                d0 = 0xFF / ((a - lx0) * (a - lx0) + (-1 - ly0) * (-1 - ly0) + (b - lz0) * (b - lz0));
                                d1 = 0xFF / ((a - lx1) * (a - lx1) + (-1 - ly1) * (-1 - ly1) + (b - lz1) * (b - lz1));
                                d2 = 0xFF / ((a - lx2) * (a - lx2) + (-1 - ly2) * (-1 - ly2) + (b - lz2) * (b - lz2));
                                d3 = 0xFF / ((a - lx3) * (a - lx3) + (-1 - ly3) * (-1 - ly3) + (b - lz3) * (b - lz3));
                            } else // ================================================================================ FLOOR
                            {
                                a = ((1 - oy) / vy * vx) + ox;
                                b = ((1 - oy) / vy * (-1 - oz)) + oz;

                                d0 = 0xFF / ((a - lx0) * (a - lx0) + (1 - ly0) * (1 - ly0) + (b - lz0) * (b - lz0));
                                d1 = 0xFF / ((a - lx1) * (a - lx1) + (1 - ly1) * (1 - ly1) + (b - lz1) * (b - lz1));
                                d2 = 0xFF / ((a - lx2) * (a - lx2) + (1 - ly2) * (1 - ly2) + (b - lz2) * (b - lz2));
                                d3 = 0xFF / ((a - lx3) * (a - lx3) + (1 - ly3) * (1 - ly3) + (b - lz3) * (b - lz3));
                            }
                        }
                    }
                }

                var cr : uint = ((d0 * 0.006 / (wav1 * wav1)) + (0.79 * d3)) >> 0;
                var cg : uint = ((d1 * 0.22 * (wav2 * wav2)) + (0.76 * d3)) >> 0;
                var cb : uint = ((d2 * 0.055) + (0.75 * d3)) >> 0;

                if (cr > 0xFF) cr = 0xFF;
                if (cg > 0xFF) cg = 0xFF;
                if (cb > 0xFF) cb = 0xFF;

                buf[n] = (cr << 16) | (cg << 8) | (cb >> 0);
            }

            bmd.setVector(bmd.rect, buf);
        }
    }
}
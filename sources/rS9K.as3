package {
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageQuality;
    import flash.display.StageScaleMode;
    import flash.events.Event;

    [SWF(width = '465', height = '465')]
    public class MSponge extends Sprite
    {
        private var buff : Vector.<uint>;
        private var bmd : BitmapData;
        private var tt : Number;
        private var fcnt : int;

        function MSponge()
        {
            stage.stageFocusRect = mouseEnabled = mouseChildren = tabEnabled = tabChildren = false;
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
            stage.quality = StageQuality.LOW;
            stage.frameRate = 64;
            opaqueBackground = 0x0;

            var bm : Bitmap = new Bitmap(bmd = new BitmapData(512, 512, false));
            bm.opaqueBackground = 0x0;
            bm.x = bm.y = -((512 - 465) >> 1);
            addChild(bm);

            buff = new Vector.<uint>(512 * 512, true);

            tt = Math.PI * 2 * Math.random();

            addEventListener(Event.ENTER_FRAME, oef);
        }

        private function oef(e : Event) : void
        {
            fcnt++;
            tt += 0.0005;

            var t : Number = (Math.PI * 16) * Math.sin(tt);
            var ex0 : Number = 0.5 + Math.sin(t * 0.5) * 0.1;
            var ey0 : Number = 0.5 + Math.cos(t * 0.47) * 0.1;
            var ez0 : Number = -t * 0.3 + 0.6 * Math.sin((t * 0.3) - 0.01);
            var sn : Number = Math.sin(t * 0.014);
            var cn : Number = Math.cos(t * 0.017);
            var flen : Number = 1.5 + 0.75 * cn;
            var dx : Number = 1.0 / 512 * flen;
            var dy : Number = 1.0 / 512 * flen;

            var pos : uint = buff.length - 1024 - (fcnt & 1);
            while (pos > 1023)
            {
                pos--;
                pos--;

                var posx : int = pos & 511;
                var posy : int = pos >> 9;

                if ((posy & 1) == 0) continue;

                var py : Number = -1.0 + posx * dx;
                var px : Number = -1.0 + posy * dy;

                var ex : Number = ex0;
                var ey : Number = ey0;
                var ez : Number = ez0;

                var sx : Number = ex;
                var sy : Number = ey;
                var sz : Number = ez;

                var rx : Number = cn + sn * px;
                var ry : Number = cn * px - sn * rx;

                var fx : Number = (rx > 0.0) ? 1.0 : 0.0;
                var fy : Number = (ry > 0.0) ? 1.0 : 0.0;
                var fz : Number = (py > 0.0) ? 1.0 : 0.0;

                var tx : Number = sx;
                var ty : Number = sy;
                var tz : Number = sz;

                var d : Number = 1.0;
                var i : uint = 6;
                while ((i-- != 0) && (d > 0.125))
                {
                    d *= 0.5833333333333334;

                    tx = (tx - (tx >> 0)) * 3.0;
                    ty = (ty - (ty >> 0)) * 3.0;
                    tz -= (tz >> 0);
                    tz = (tz < 0.0) ? ((tz + 1.0) * 3.0) : (tz * 3.0);

                    var ix : int = (tx >> 0);
                    var iy : int = (ty >> 0);
                    var iz : int = (tz >> 0);

                    if (((ix * ix + iy * iy + iz * iz) & 3) >= 2)
                    {
                        tx = (fx - (tx - ix)) * 1.0 / rx;
                        ty = (fy - (ty - iy)) * 1.0 / ry;
                        tz = (fz - (tz - iz)) * 1.0 / py;

                        var m : Number = (ty < tx) ? ty : tx;
                        m = (tz < m) ? tz : m;

                        d += 0.001;

                        tx = (ex += rx * (m * d));
                        ty = (ey += ry * (m * d));
                        tz = (ez += py * (m * d));

                        d = 1.0;
                    }
                }

                ex -= sx;
                ey -= sy;
                ez -= sz;

                var lum : uint = ((1.0 - Math.exp(-(1 / Math.sqrt(ex * ex + ey * ey + ez * ez)))) * 255) >> 0;
                var c : uint = (lum << 16) | (lum << 8) | lum;

                buff[pos] = c;
                buff[pos - 512] = c;
            }

            bmd.setVector(bmd.rect, buff);
        }
    }
}
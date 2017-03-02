package {
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.events.Event;

    [SWF(width = '465', height = '465')]
    public class MiauRay02 extends Sprite {
        private var bmd : BitmapData;
        private var buf : Vector.<uint>;
        private var th : Number;
        private var fcnt : int;

        function MiauRay02() {
            stage.stageFocusRect = tabChildren = tabEnabled = mouseChildren = mouseEnabled = false;
            stage.scaleMode = "noScale";
            stage.align = "TL";
            stage.quality = "low";
            stage.frameRate = 32;
            opaqueBackground = 0x0;

            var bm : Bitmap = new Bitmap(bmd = new BitmapData(512, 512, false));
            bm.x = bm.y = (465 - 512) / 2;
            bm.opaqueBackground = 0x0;
            addChild(bm);

            buf = new Vector.<uint>(512 * 512, true);

            th = 2 * Math.PI * Math.random();

            stage.addEventListener(Event.ENTER_FRAME, oef);
        }

        private function oef(e : Event) : void {
            fcnt++;

            th += 0.053;

            var cx : Number = -2 + 4 * (stage.mouseX / 465);
            var cy : Number = -2 + 4 * (stage.mouseY / 465);

            var amp1 : Number = 0.5 * Math.sin(th);
            var amp2 : Number = 0.5 * Math.cos(th / 4);
            var amp3 : Number = Math.sin(th / 9);

            var lx0 : Number = cx + amp1;
            var ly0 : Number = cy;
            var lz0 : Number = amp2;
            var lx1 : Number = cx;
            var ly1 : Number = cy + amp1;
            var lz1 : Number = amp2;
            var lx2 : Number = cx + amp2;
            var ly2 : Number = cy + amp1;
            var lz2 : Number = 0;
            var lx3 : Number = cx;
            var ly3 : Number = cy;
            var lz3 : Number = cy;

            var ox : Number = amp1;
            var oy : Number = amp2;
            var oz : Number = -2 - 0.9 * amp3;

            var vr : Number;
            var vg : Number;
            var vb : Number;

            var n : uint = (512 * 512) - 512 - (fcnt & 1);
            while (n > 512) {
                n--;
                n--;

                var nx : uint = n & 511;
                var ny : uint = n >> 9;

                var vx : Number = (nx * (2 / 512)) - 1 - ox;
                var vy : Number = (ny * (2 / 512)) - 1 - oy;
                var vz : Number = - 1 - oz;

                var a : Number = ((1 - oz) / vz * vx) + ox;
                var b : Number = ((1 - oz) / vz * vy) + oy;

                if ((a >= -1) && (a <= 1) && (b >= -1) && (b <= 1)) {
                    vr = a;
                    vg = b;
                    vb = 1;
                } else {
                    a = ((-1 - ox) / vx * vz) + oz;
                    b = ((-1 - ox) / vx * vy) + oy;

                    if ((b >= -1) && (b <= 1) && (a >= -1) && (a <= 1)) {
                        vr = -1;
                        vg = b;
                        vb = a;
                    } else {
                        a = ((1 - ox) / vx * vz) + oz;
                        b = ((1 - ox) / vx * vy) + oy;

                        if ((b >= -1) && (b <= 1) && (a >= -1) && (a <= 1)) {
                            vr = 1;
                            vg = b;
                            vb = a;
                        } else {
                            a = ((-1 - oy) / vy * vx) + ox;
                            b = ((-1 - oy) / vy * vz) + oz;

                            if ((a >= -1) && (a <= 1) && (b >= -1) && (b <= 1)) {
                                vr = a;
                                vg = -1;
                                vb = b;
                            } else {
                                vr = ((1 - oy) / vy * vx) + ox;
                                vg = 1;
                                vb = ((1 - oy) / vy * vz) + oz;
                            }
                        }
                    }
                }

                var lr : Number = 0xFF / (((vr - lx0) * (vr - lx0)) + ((vg - ly0) * (vg - ly0)) + ((vb - lz0) * (vb - lz0)));
                var lg : Number = 0xFF / (((vr - lx1) * (vr - lx1)) + ((vg - ly1) * (vg - ly1)) + ((vb - lz1) * (vb - lz1)));
                var lb : Number = 0xFF / (((vr - lx2) * (vr - lx2)) + ((vg - ly2) * (vg - ly2)) + ((vb - lz2) * (vb - lz2)));

                var d : Number = 0xFF / (((vr - lx3) * (vr - lx3)) + ((vg - ly3) * (vg - ly3)) + ((vb - lz3) * (vb - lz3)));
                lr += d * 0.5;
                lg += d * 0.5;

                if (lr > 0xFF) lr = 0xFF;
                if (lg > 0xFF) lg = 0xFF;
                if (lb > 0xFF) lb = 0xFF;

                buf[n] = (lr << 16) | (lg << 8) | lb;
            }

            bmd.setVector(bmd.rect, buf);
        }
    }
}
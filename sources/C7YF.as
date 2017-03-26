package {
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.events.Event;

    /*
     * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
     * Chaos Exploration | Hour 01
     * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
     * 
     * "It's been 1 hour now... coding in circles. This damn line keeps coming up everywhere i go.
     * It does something to the feedback that i don't understand... yet."
     *                                                                                        ~~ x
     *
     * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
     */
    [SWF(width = '465', height = '465')]
    public class ChaoXP01 extends Sprite {
        private var bmd : BitmapData;
        private var buff : Vector.<uint>;
        private var seed : uint = 1111;
        private var cnt : uint = 1;

        function ChaoXP01() {
            buff = new Vector.<uint>(512 * 512, true);

            var bm : Bitmap = new Bitmap(bmd = new BitmapData(512, 512, false));
            bm.x = bm.y = -(512 - 465) / 2;
            bm.opaqueBackground = 0x0;
            addChild(bm);

            addEventListener(Event.ENTER_FRAME, oef);
        }

        private function oef(e : Event) : void {
            this.cnt++;
            this.seed = (((this.seed & 1) - 1) & 0xF00FC7C8) ^ (this.seed >> 1);

            var cnt : int = this.cnt;
            var seed : int = this.seed;
            var cat : Number = 0.0;
            var sat : Number = 0.0;
            var fx : Number = stage.mouseX / 512;
            var fy : Number = stage.mouseY / 512;
            var a0 : Number = Math.PI + (Math.PI * 2) * fx;
            var af : Number = -1 + 2 * fy;

            var n : uint = buff.length - 1024;
            while (n-- > 1023) {
                cnt++;

                if ((cnt & 3) != 1)
                {
                    var c : uint = (buff[n] & 0xFF) >> 1;

                    c += (c >> 1);
                    c += (c >> 1);
                    c += (c >> 1);
                    c += (c >> 2);
                    c += (c >> 2);

                    c = (c >> 1) + (c >> 2);

                    buff[n] = (c << 16) | ((c - (c >> 5)) << 8) | (c - (c >> 3));
                }
                else
                {
                    seed = (((seed & 1) - 1) & 0xF00FC7C8) ^ (seed >> 1);
                    seed = (((seed & 1) - 1) & 0xF00FC7C8) ^ (seed >> 1);

                    var a : Number = (((seed & 511) / 512 * a0) << 1) * af;

                    cat += (cos(a) - cat) * fx;
                    sat += (sin(a) - sat) * fx;

                    buff[(((cat + 1) * 256) & 511) + ((((sat + 1) * 256) & 511) << 9)] = 0xFFFFFF;
                }
            }

            this.cnt = cnt;
            this.seed = seed;

            bmd.setVector(bmd.rect, buff);
        }

        private function sin(x : Number) : Number {
            x %= 6.283185307179586;
            if (x > 3.141592653589793) x -= 6.283185307179586;
            if (x < -3.141592653589793) x += 6.283185307179586;
            var s : Number = (x <= 0) ? 1.27323954 * x + 0.405284735 * x * x : 1.27323954 * x - 0.405284735 * x * x;
            return (s < 0) ? 0.225 * (s * -s - s) + s : 0.225 * (s * s - s) + s;
        }

        private function cos(x : Number) : Number {
            return sin(x + 1.5707963267948966);
        }
    }
}
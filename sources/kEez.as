package {
    import flash.display.Graphics;
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.events.Event;

    [SWF(width = "465", height = "465")]
    public class OZ extends Sprite
    {
        private var MAXARCS : uint = 32;
        private var RSP : Number = 0.01;
        private var LUM : Number = 1.0;
        private var OVERFLOW : Number = -2.0;
        private var ARCSNUM1 : uint = MAXARCS >> 1;
        private var ARCSNUM2 : uint = MAXARCS;
        private var ARCSNUM3 : uint = ARCSNUM1;
        private var STARTRADIUS1 : Number = 16.0;
        private var STARTRADIUS2 : Number = 32.0;
        private var STARTRADIUS3 : Number = 8;
        private var FITRATIO1 : Number = 1.0;
        private var FITRATIO2 : Number = 0.0;
        private var FITRATIO3 : Number = 0.5;
        private var COLOR1 : uint = 0xC0FF00;
        private var COLOR2 : uint = 0x303030;
        private var COLOR3 : uint = 0xFF00C0;
        /* */
        private var state : int = -1;
        private var arcs : Arc = new Arc();
        private var numArcs : uint = MAXARCS;
        private var sradius : Number = 0.0;
        private var fitRatio : Number = 0.0;
        private var sradiusT : Number = 0.0;
        private var gurf : Number = 0.0;
        private var gurfT : Number = 0.0;
        private var canvasRadius : Number = 0.0;
        private var chronoRadius : Number = 0.0;
        private var fcnt : int;
        private var container : Shape;
        private var g : Graphics;

        function OZ()
        {
            stage.stageFocusRect = mouseEnabled = tabEnabled = tabChildren = false;
            stage.scaleMode = "noScale";
            stage.align = "TL";
            stage.quality = "high";
            stage.frameRate = 64;
            opaqueBackground = 0x0;

            graphics.beginFill(0x0);
            graphics.drawRect(0, 0, 465, 465);

            var arc : Arc = arcs;
            var pole : Number = 1.0;
            var n : uint = MAXARCS;
            while (--n != 0) {
                arc.rsp = (pole = -pole) * RSP;
                arc = arc.next = new Arc();
            }

            addChild(container = new Shape());
            container.x = 465 >> 1;
            container.y = 465 >> 1;
            container.opaqueBackground = 0x0;
            g = container.graphics;

            canvasRadius = Math.sqrt(465 * 465 + 465 * 465) / 2;
            chronoRadius = 465 / 3;

            fit();

            setState(0);

            stage.addEventListener(Event.ENTER_FRAME, oef);
        }

        public function setState(state : int) : void
        {
            var lum : Number;
            var n : uint;
            var arc : Arc = arcs;

            switch (state)
            {
                case 0 :
                {
                    fitRatio = FITRATIO1;
                    sradiusT = STARTRADIUS1;

                    n = numArcs = ARCSNUM1;
                    while (arc != null)
                    {
                        arc.angB = (Math.PI * 2) * (n / ARCSNUM1);
                        arc.angD = shortestRotation(arc.angA, arc.angB);
                        arc.lenB = arc.angB;

                        lum = LUM * ((arc.rsp > 0) ? 0.5 : 1.0) * (n / ARCSNUM1);
                        arc.cB = (int((COLOR1 >> 16) * lum) << 16) | (int((COLOR1 >> 8 & 0xFF) * lum) << 8) | int((COLOR1 & 0xFF) * lum);

                        if (n-- == 0) return;
                        arc = arc.next;
                    }
                }
                case 1 :
                {
                    fitRatio = FITRATIO2;
                    sradiusT = STARTRADIUS2;

                    n = numArcs = ARCSNUM2;
                    while (arc != null)
                    {
                        arc.angB = (Math.PI * 2) * Math.random();
                        arc.angD = shortestRotation(arc.angA, arc.angB);
                        arc.lenB = arc.angB;

                        lum = LUM * (arc.lenB / (Math.PI * 2));
                        arc.cB = (int((COLOR2 >> 16) * lum) << 16) | (int((COLOR2 >> 8 & 0xFF) * lum) << 8) | int((COLOR2 & 0xFF) * lum);

                        if (n-- == 0) return;
                        arc = arc.next;
                    }
                }
                case 2 :
                {
                    fitRatio = FITRATIO3;
                    sradiusT = STARTRADIUS3;

                    n = numArcs = ARCSNUM3;
                    while (arc != null)
                    {
                        arc.angB = (Math.PI * 2) * (n / ARCSNUM3);
                        arc.angD = shortestRotation(arc.angA, arc.angB);
                        arc.lenB = arc.angB;

                        lum = LUM * ((arc.rsp < 0) ? 0.5 : 1.0) * (n / ARCSNUM3);
                        arc.cB = (int((COLOR3 >> 16) * lum) << 16) | (int((COLOR3 >> 8 & 0xFF) * lum) << 8) | int((COLOR3 & 0xFF) * lum);

                        if (n-- == 0) return;
                        arc = arc.next;
                    }
                }
            }

            fit();
        }

        private function shortestRotation(angleFrom : Number, angleTo : Number) : Number
        {
            return Math.atan2(Math.sin(angleTo - angleFrom), Math.cos(angleTo - angleFrom));
        }

        private function oef(e : Event) : void
        {
            fcnt++;

            if ((fcnt & 63) == 1) setState(state = ++state % 3);

            this.gurf += (gurfT - this.gurf) * 0.16;
            sradius += ((sradiusT + (fitRatio * chronoRadius)) - sradius) * 0.16;

            var gurf : Number = gurf * 2;
            var r : Number = sradius + (gurf / 2);
            var cA : uint;
            var cB : uint;
            var angA : Number;
            var lenA : Number;

            g.clear();

            var n : uint = numArcs;
            var arc : Arc = arcs;
            while (arc != null)
            {
                cB = arc.cB;
                cA = arc.cA;

                angA = (arc.angA += (arc.angB - arc.angA) * 0.16);
                lenA = (arc.lenA += (arc.lenB - arc.lenA) * 0.16);

                g.beginFill(arc.cA = ((((cA >> 16) + (((cB >> 16) - (cA >> 16)) >> 3)) << 16) | (((cA >> 8 & 0xFF) + (((cB >> 8 & 0xFF) - (cA >> 8 & 0xFF)) >> 3)) << 8) | ((cA & 0xFF) + (((cB & 0xFF) - (cA & 0xFF)) >> 3))), 1.0);
                g.moveTo(r * Math.cos(angA), r * Math.sin(angA));
                arcTo(r, angA, angA + lenA);

                r += OVERFLOW - gurf;
                angA += lenA;

                g.lineTo(r * Math.cos(angA), r * Math.sin(angA));
                arcTo(r, angA, angA - lenA);
                g.endFill();

                r += (gurf * 1.5) - OVERFLOW;

                if (n-- == 0) return;
                arc = arc.next;
            }
        }

        private function arcTo(radius : Number, a1 : Number, a2 : Number) : void
        {
            var num : uint = (Math.ceil(Math.abs((a2 - a1) / Math.PI))) << 2;
            var step : Number = (a2 - a1) / num;
            var ctla : Number = a1 - (step / 2);
            var ctlr : Number = radius * (1 / Math.cos(step / 2));

            while (num-- != 0)
            {
                a1 += step;
                ctla += step;
                g.curveTo(ctlr * Math.cos(ctla), ctlr * Math.sin(ctla), radius * Math.cos(a1), radius * Math.sin(a1));
            }
        }

        private function fit() : void
        {
            gurfT = ((canvasRadius - sradiusT) / numArcs) / 2;
        }
    }
}

internal class Arc {
    public var next : Arc;
    public var lenA : Number = 0.0;
    public var lenB : Number = 0.0;
    public var len1 : Number = 0.0;
    public var len2 : Number = 0.0;
    public var len3 : Number = 0.0;
    public var rsp : Number = 0.0;
    public var angA : Number = 0.0;
    public var angB : Number = 0.0;
    public var angD : Number = 0.0;
    public var cA : uint = 0x0;
    public var cB : uint = 0x0;

    function Arc() {
    }
}
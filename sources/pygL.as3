package {
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.GradientType;
    import flash.display.Graphics;
    import flash.display.InterpolationMethod;
    import flash.display.Shape;
    import flash.display.SpreadMethod;
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageQuality;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.filters.BitmapFilterQuality;
    import flash.filters.GlowFilter;
    import flash.geom.Matrix;
    import flash.geom.Rectangle;

    [SWF(width='465', height='465')]
    public class Elektro extends Sprite {
        /* */
        private const MAX_BRANCHES : uint = 22;
        /* */
        private var g : Graphics;
        private var arcRoot : Arc;
        private var alast : Arc;
        private var acnt : uint;
        private var fcnt : int;
        private var src : Sprite;
        private var emissionBmd : BitmapData;
        private var bloom : Bloom;
 
        public function Elektro() : void {
            /* */

            stage.stageFocusRect = tabChildren = tabEnabled = mouseChildren = mouseEnabled = false;
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
            stage.quality = StageQuality.MEDIUM;
            stage.frameRate = 64;
            stage.fullScreenSourceRect = new Rectangle(0, 0, 465, 465);
            opaqueBackground = 0x0;

            src = new Sprite();

            var mtx : Matrix = new Matrix();
            mtx.createGradientBox(465, 465, 0, 0, 0);
            src.graphics.beginGradientFill(GradientType.RADIAL, [0x504C44, 0x161614], [1, 1], [0, 255], mtx, SpreadMethod.PAD, InterpolationMethod.RGB, 0);
            src.graphics.drawRect(0, 0, 465, 465);
            src.graphics.endFill();

            /* */

            var sp : Shape = new Shape();
            g = sp.graphics;

            arcRoot = new Arc(null, g, 0, (465 / 2), 465, (465 / 2));

            arcRoot.y1 = arcRoot.y0;
            sp.filters = [new GlowFilter(0xFFFFF0, 1.0, 8.0, 8.0, 2, BitmapFilterQuality.MEDIUM)];

            src.addChild(sp);

            /* */

            bloom = new Bloom(465, 465);

            var bm : Bitmap = new Bitmap(emissionBmd = new BitmapData(465, 465, false));
            bm.opaqueBackground = 0x0;
            addChild(bm);

            /* */

            addEventListener(Event.ENTER_FRAME, oef);
        }

        private function oef(e : Event) : void {
            /* */

            fcnt++;

            /* add arcs */

            if (acnt < MAX_BRANCHES) {
                if ((fcnt & 31) == 31) {
                    if ((alast != null) && (alast.len > 4) && (Math.random() > 0.4)) {
                        alast.addChild(g);
                        acnt++;
                    } else {
                        alast = arcRoot.addChild(g);
                    }
                }
            }

            /* draw */

            g.clear();

            arcRoot.update();

            /* bloom! */

            emissionBmd.lock();
            emissionBmd.draw(src);
            bloom.mod(emissionBmd);
            emissionBmd.unlock();
        }
    }
}

import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.display.Graphics;
import flash.filters.BitmapFilterQuality;
import flash.filters.BlurFilter;
import flash.filters.ColorMatrixFilter;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Point;


internal class Arc {
    /* */
    private const RESOLUTION : uint = 64;
    private const SPEED1 : Number = 0.027;
    private const SPEED2 : Number = 0.022;
    private const WAVELENGTH1 : Number = 0.008;
    private const WAVELENGTH2 : Number = 0.31;
    private const AMP1 : Number = 0.05;
    private const AMP2 : Number = 0.8;
    private const SEED1 : int = int(int.MAX_VALUE * Math.random());
    private const SEED2 : int = int(int.MAX_VALUE * Math.random());
    /* */
    public var pos : Vector.<Pos>;
    public var len : int;
    public var x0 : Number;
    public var y0 : Number;
    public var x1 : Number;
    public var y1 : Number;
    /* */
    private var pn0 : int;
    private var pn1 : int;
    private var parent : Arc;
    private var children : Vector.<Arc>;
    private var graphics : Graphics;
    private var noiseA : BitmapData;
    private var noiseB : BitmapData;
    private var offsetsA : Array;
    private var offsetsB : Array;
    private var oA0 : Point;
    private var oB0 : Point;

    function Arc(parent : Arc, graphics : Graphics, x0 : Number = 0.0, y0 : Number = 0.0, x1 : Number = 0.0, y1 : Number = 0.0) {
        if (parent != null) {
            this.parent = parent;

            if (parent.len > 3) {
                pn0 = int((parent.len >> 1) * Math.random());
                pn1 = pn0 + int((parent.len >> 1) * Math.random());
                len = pn1 - pn0;
            }
        } else {
            len = RESOLUTION;
            this.x0 = x0;
            this.y0 = y0;
            this.x1 = x1;
            this.y1 = y1;
        }

        if (len > 3) {
            this.graphics = graphics;

            offsetsA = [new Point()];
            offsetsB = [new Point()];
            oA0 = offsetsA[0];
            oB0 = offsetsB[0];

            children = new Vector.<Arc>();

            pos = new Vector.<Pos>(len, true);

            var n : uint = len;
            while (n-- != 0) {
                pos[n] = new Pos();
            }

            noiseA = new BitmapData(len, 1, false);
            noiseB = new BitmapData(len, 1, false);
        }
    }

    public function update() : void {
        if (len < 4) return;

        if (parent != null) {
            x0 = parent.pos[pn0].x;
            y0 = parent.pos[pn0].y;
            x1 = parent.pos[pn1].x;
            y1 = parent.pos[pn1].y;

            graphics.lineStyle(1, 0xFFFFF0, 0.4, false, 'none', 'none');
        } else {
            graphics.lineStyle(2, 0xFFFFFF, 0.6, false, 'none', 'none');
        }

        oA0.x -= len * SPEED1;
        oB0.x -= len * SPEED2;

        noiseA.perlinNoise(len * WAVELENGTH1, 0, 2, SEED1, false, true, 0, true, offsetsA);
        noiseB.perlinNoise(len * WAVELENGTH2, 0, 2, SEED2, false, true, 0, true, offsetsB);

        /* draw */

        graphics.moveTo(x0, y0);

        var dx : Number = x1 - x0;
        var dy : Number = y1 - y0;
        var d : Number = Math.sqrt(dx * dx + dy * dy);

        var a : Number = Math.atan2(y1 - y0, x1 - x0);
        var sina : Number = Math.sin(a);
        var cosa : Number = Math.cos(a);

        var n : uint = 0;
        for each (var p : Pos in pos) {
            var m : Number = Math.sin((n / (len - 1)) * 3.141592653589793);
            var amp : Number = d * AMP1 * ((noiseA.getPixel(n, 0) - 0x808080) / 0xFFFFFF);
            var px : Number = sina * amp * m;
            var py : Number = cosa * amp * m;

            amp = d * AMP2 * ((noiseB.getPixel(n, 0) - 0x808080) / 0xFFFFFF);

            px = x0 + ((dx / (len - 1)) * n) + (px + (sina * amp * m));
            py = y0 + ((dy / (len - 1)) * n) - (py - (cosa * amp * m));

            p.x = px;
            p.y = py;

            graphics.lineTo(px, py);

            n++;
        }

        /* update sub arcs */
        if (children) {
            for each (var child : Arc in children) {
                child.update();
            }
        }
    }

    public function addChild(graphics : Graphics) : Arc {
        if (children && (len > 4)) {
            var arc : Arc = new Arc(this, graphics);
            if (arc.len > 3) {
                children.push(arc);
                return arc;
            } else {
                return null;
            }
        }
        return null;
    }
}

internal class Pos {
    public var x : Number;
    public var y : Number;

    function Pos() {
    }
}

internal class Bloom {
    /* */
    private const LORES_FACTOR : Number = 2;
    /* */
    private var offscr : BitmapData;
    private var loRes : BitmapData;
    private var loResMono : BitmapData;
    private var ct : ColorTransform;
    private var cmtx : ColorMatrixFilter;
    private var mtx : Matrix;
    private var imtx : Matrix;
    private var dstp : Point;
    private var blur : BlurFilter;

    function Bloom(width : int, height : int) {
        /* */

        loRes = new BitmapData((width >> LORES_FACTOR), (height >> LORES_FACTOR), false);
        loResMono = loRes.clone();
        offscr = loRes.clone();

        /* */

        dstp = new Point();

        mtx = new Matrix();
        mtx.scale((1 / (1 << LORES_FACTOR)), (1 / (1 << LORES_FACTOR)));

        imtx = mtx.clone();
        imtx.invert();

        /* */

        ct = new ColorTransform();
        cmtx = new ColorMatrixFilter([0.33, 0.59, 0.11, 0, 0, 0.33, 0.59, 0.11, 0, 0, 0.33, 0.59, 0.11, 0, 0, 0, 0, 0, 1, 0]);
        blur = new BlurFilter(8.0, 8.0, BitmapFilterQuality.MEDIUM);
    }

    public function mod(input : BitmapData, threshold : uint = 100, mul : Number = 0.125) : void {
        /* */

        loRes.draw(input, mtx);

        loResMono.applyFilter(loRes, loRes.rect, dstp, cmtx);
        loRes.threshold(loResMono, loRes.rect, dstp, '<', threshold, 0, 0x000000FF);

        loRes.applyFilter(loRes, loRes.rect, dstp, blur);

        ct.alphaMultiplier = mul;
        ct.redMultiplier = mul;
        ct.greenMultiplier = mul;
        ct.blueMultiplier = mul;
        offscr.draw(offscr, null, ct);

        ct.alphaMultiplier = 0.5;
        ct.redMultiplier = 1.0;
        ct.greenMultiplier = 1.0;
        ct.blueMultiplier = 0.9;
        offscr.draw(loRes, null, ct);

        input.draw(offscr, imtx, null, BlendMode.ADD, null, true);
    }
}
package {
    import flash.display.*;
    import flash.geom.*;
    import flash.filters.*;

    /**
     * The Eclipse.
     * This is quick AS3 port of my old AS2 stuff from '07.
     * See also http://eclipse.gsfc.nasa.gov/SEmono/TSE2009/TSE2009.html
     */
    [SWF(backgroundColor="#000000", frameRate="20")]
    public class Eclipse extends Sprite {
        // magic numbers
        private const H:Number = 465, W:Number = 465;
        private const T2:Number = 100.0, SR:Number = 18.3;
        private const A:Number = (1.0001 * W) / H;
        private const SY:Number = 2.0001 / H, SX:Number = 2.0001 / W;
        private const DY:Number = -30, DX:Number = A * DY;

        // more magic numbers
        private const FadeOut:ColorTransform = new ColorTransform(1, 1, 1, 1, -15, -10, -5, 0);
        private const MixPixels:BlurFilter = new BlurFilter(2, 2, 2);
        private const Origin:Point = new Point (0, 0);
        private const StarCopyMatrix:Matrix = new Matrix (1, 0, 0, 1, (W + 1)*0.5, (H + 1)*0.5);
        private const ScaleMatrix:Matrix = new Matrix(1 - SX * DX, 0, 0, 1 - SY * DY, DX /* hack: */-0.3, DY);

        private var T:Number = 0, starShineR:Number = 18;
        private var star:Sprite = new Sprite;
        private var starShine:Shape = new Shape;
        private var starMask:Shape = new Shape;
        private var starBitmap:Bitmap = new Bitmap;
        private var starBitmapData:BitmapData = new BitmapData (W, H, true, 0xFF000000);
        private var starBitmapData2:BitmapData = new BitmapData (W, H, true);
        private var skyPatch:Sprite = new Sprite;
        private var skyStars:Shape = new Shape;
        private var skyColor:Shape = new Shape;

        public function Eclipse () {
            // init all the stuff
            star.addChild (starShine); starShine.x = starShine.y = -20;
            star.addChild (starMask);
            starMask.graphics.beginFill (0); starMask.graphics.drawCircle (0, 0, 20); starMask.graphics.endFill ();
            starShine.mask = starMask;
            starBitmap.bitmapData = starBitmapData;
            addChild (starBitmap); addChild (skyPatch);
            skyPatch.addChild (skyStars); drawStars ();
            skyPatch.addChild (skyColor);
            skyColor.graphics.beginFill (0x1580); skyColor.graphics.drawRect (0, 0, W, H); skyColor.graphics.endFill ();
            skyStars.alpha = skyColor.alpha = 0;
            skyColor.blendMode = "lighten";

            addEventListener ("enterFrame", onEnterFrame);
        }

        private function onEnterFrame (e:*):void {
            // advance "time"
            T++;

            var dX:Number = 0;
            if (T < T2) {
                // this formula was probably supposed to be
                // independent of T2, but it is not :((
                dX = 20.5 / T2 * Math.sqrt(2) * (T2 - 1 - T);
            }

            if ((T > T2 * 0.8) && (skyColor.alpha > 0)) {
                // get rid of minimal color constraint, lit up damn stars
                skyColor.alpha -= 4 / T2; skyStars.alpha += 6 / T2;
            }

            if (T > T2 * 0.95) {
                // darken the sky after the eclipse by growing the moon
                if (starShineR < SR) starShineR += 4 / T2;
            }

            // draw star and moon
            starShine.graphics.clear();
            starShine.graphics.beginFill (0xFFFFFF);
            starShine.graphics.drawCircle (20, 20, 20);
            starShine.graphics.drawCircle (20 + dX, 20 + 0.3 * dX, starShineR);
            starShine.graphics.endFill ();

            // decide on filtering passes number
            var PassN:Number = 0;
            if (T == 1) {
                // initial moment
                PassN = 40; skyColor.alpha = 1;
            } else if ((T > T2 - 10) && (starShineR < SR)) {
                // try to avoid fire-like effect at eclipse first moments
                if (PassN < 30) PassN += 3;
            } else {
                // default
                PassN = 1;
            }

            // apply radial filtering
            for (var i:int = 0; i < PassN; i++) {
                starBitmapData.draw(star, StarCopyMatrix)
                starBitmapData2.applyFilter(starBitmapData, starBitmapData.rect, Origin, MixPixels);
                starBitmapData.draw(starBitmapData2, ScaleMatrix, FadeOut, "normal", starBitmapData.rect);
            }
        }

        private function drawStars ():void {
            // star helper (could be done with Bitmap/noise, I think)
            for (var z:int = 0; z < 100; z++) {
                var xp:Number = W * Math.random (), yp:Number = H * Math.random ();
                var p:Point = new Point (xp - W/2, yp - H/2); if (p.length > 20 + 40) {
                    skyStars.graphics.lineStyle(1, 0x8F8FFF, 50 + 50 * Math.random ());
                    skyStars.graphics.moveTo (xp, yp); skyStars.graphics.lineTo (xp +1, yp);
                }
            }
        }
    }
}
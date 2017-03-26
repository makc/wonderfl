// forked from flashmafia's Octopus
package
{
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageQuality;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.geom.*;
    import net.hires.debug.Stats;

    [SWF(width='465', height='465', backgroundColor='0', frameRate='64')]
    public class OctopusApp extends Sprite {
        private var _octopus : OctopusGenerator;
        public static var vpl : VolumetricPointLight;

        public function OctopusApp() {
            stage.stageFocusRect = mouseEnabled = tabEnabled = tabChildren = false;
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
            stage.quality = StageQuality.HIGH;
            stage.fullScreenSourceRect = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
            /* */

            addChild(vpl = new VolumetricPointLight(465, 465, new OctopusGenerator(465, 465), [0xff8040, 0x803820, 0], [1, 0.25, 0], [0, 24, 255]));
            vpl.startRendering();
            vpl.scale = 2;
            vpl.intensity = 6;

            //addChild(new Stats);
            graphics.beginFill(0);
            graphics.drawRect(0, 0, 465, 465);
        }
    }
}
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.display.DisplayObject;
import flash.display.LineScaleMode;
import flash.display.PixelSnapping;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.filters.GlowFilter;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import flash.geom.Vector3D;

internal class OctopusGenerator extends Bitmap {
    private const OFFSET : Number = 88;
    private const CURVE_QUANT : uint = 24;
    private const CURVE_LENGTH : uint = 6;
    private const NOISE_AMPLITUDE : Number = 49;
    private const TANGENT_OFFSET : Number = 0.9;
    private const TIME_SCALE : Number = 96;
    /* */
    private var _t : Number = 0;
    private var _controlPoints : Vector.<Vector.<Vector3D>> = new Vector.<Vector.<Vector3D>>(CURVE_QUANT, true);
    private var _startPoints : Vector.<Vector3D> = new Vector.<Vector3D>(CURVE_QUANT, true);
    private var _endPoints : Vector3D;
    private var _gurfs : Vector.<Number> = new Vector.<Number>(CURVE_QUANT, true);
    private var _colors : Vector.<uint> = Vector.<uint>([0xFFCC00, 0xFF8000, 0xFFFFCC, 0xFF4080, 0xAAFF40, 0xCCFF80, 0xFFFFFF]);
    private var _fadeCT : ColorTransform = new ColorTransform(1, 1, 1, 0.99);
    private var _colorIndex : uint = 0;
    private var _container : Sprite = new Sprite();
    private var _bezierMath : BezierMath = new BezierMath();

    public function OctopusGenerator(w : uint, h : uint) : void {
        super(new BitmapData(w, h, true, 0), PixelSnapping.AUTO, false);

        var n : uint = 0;
        while (n < CURVE_QUANT) {
            _gurfs[n] = 5 - 2 + 4 * Math.random();
            _controlPoints[n] = new Vector.<Vector3D>(0, false);
            ++n;
        }

        var nn : uint = 0;
        while (nn < CURVE_QUANT) {
            if (nn != 0) {
                _controlPoints[nn].push(_controlPoints[0][0]);
                n = 1;
                while (n < CURVE_LENGTH) {
                    var reference : Vector3D = _controlPoints[0][n];
                    _controlPoints[nn].push(new Vector3D(reference.x + ((Math.random() >= 0.5) ? 1 : -1) * NOISE_AMPLITUDE * Math.random(), reference.y + ((Math.random() >= 0.5) ? 1 : -1) * NOISE_AMPLITUDE * Math.random(), 0, reference.w));
                    ++n;
                }
            } else {
                _controlPoints[nn].push(new Vector3D(0, 0, 0, 1));
                n = 1;
                while (n < CURVE_LENGTH) {
                    _controlPoints[nn].push(new Vector3D(OFFSET + Math.random() * (w - 2 * OFFSET), OFFSET + Math.random() * (h - 2 * OFFSET), 0, 1));
                    ++n;
                }
            }
            ++nn;
        }

        n = CURVE_QUANT;
        while (--n) {
            _startPoints[n] = _controlPoints[n][0];
        }

        addEventListener(Event.ENTER_FRAME, render, false, 0, true);
    }

    private function colorInterpolation(c1 : uint, c2 : uint, ratio : Number) : uint {
        var r1 : uint = c1 >> 16 & 0xFF;
        var g1 : uint = c1 >> 8 & 0xFF;
        var b1 : uint = c1 & 0xFF;

        var r2 : uint = c2 >> 16 & 0xFF;
        var g2 : uint = c2 >> 8 & 0xFF;
        var b2 : uint = c2 & 0xFF;

        return ((r1 + int((r2 - r1) * ratio)) << 16) | ((g1 + int((g2 - g1) * ratio)) << 8) | b1 + int((b2 - b1) * ratio);
    }

    private function render(e : Event) : void {
        var n : uint = CURVE_QUANT;
        var xs:Number = 0, ys:Number = 0, zs:Number = 0;
        while (--n) {
            _endPoints = _bezierMath.bezier(_t / TIME_SCALE, _controlPoints[n]);
            _container.addChild(new GlowLine(_startPoints[n], _endPoints, 0, _gurfs[n], 1));
            xs += _endPoints.x;
            ys += _endPoints.y;
            zs += _endPoints.y;

            _startPoints[n] = _endPoints;
        }
        OctopusApp.vpl.srcX = xs / CURVE_QUANT;
        OctopusApp.vpl.srcY = ys / CURVE_QUANT;
        OctopusApp.vpl.intensity = 1 + Math.pow(2, (zs / CURVE_QUANT)/100);

        bitmapData.lock();
        bitmapData.colorTransform(bitmapData.rect, _fadeCT);
        bitmapData.draw(_container, null, null, null, null, false);
        bitmapData.unlock();

        while (_container.numChildren > 0) {
            _container.removeChildAt(_container.numChildren - 1);
        }

        _t++;

        if (_t == TIME_SCALE) {
            _t = n = 0;

            var vec1 : Vector3D;
            var vec2 : Vector3D;
            var vec3 : Vector3D;

            while (n < CURVE_QUANT) {
                vec1 = _controlPoints[n][CURVE_LENGTH - 2];
                (vec3 = (vec2 = _controlPoints[n][(CURVE_LENGTH - 1)]).subtract(vec1)).scaleBy(TANGENT_OFFSET);
                (vec3 = vec3.add(vec2)).w = 1;

                _controlPoints[n][0] = vec2;
                _controlPoints[n][1] = vec3;

                var nn : uint;
                if (n != 0) {
                    nn = 2;
                    while (nn < CURVE_LENGTH) {
                        var reference : Vector3D = _controlPoints[0][nn];
                        _controlPoints[n][nn] = new Vector3D(reference.x + ((Math.random() >= 0.5) ? 1 : -1) * NOISE_AMPLITUDE * Math.random(), reference.y + ((Math.random() >= 0.5) ? 1 : -1) * NOISE_AMPLITUDE * Math.random(), 0, reference.w);
                        ++nn;
                    }
                } else {
                    nn = 2;
                    while (nn < CURVE_LENGTH) {
                        _controlPoints[n][nn] = new Vector3D(OFFSET + Math.random() * (width - 2 * OFFSET), OFFSET + Math.random() * (height - 2 * OFFSET), 0, 1);
                        ++nn;
                    }
                }
                ++n;
            }

            _colorIndex++;

            if (_colorIndex > _colors.length - 2) {
                _colorIndex = 0;
            }
        }
    }
}
internal class GlowLine extends Shape {
    public function GlowLine(startVec : Vector3D, endVec : Vector3D, color : uint, gurf : Number, alpha : Number) {
        graphics.lineStyle(gurf, color, alpha, false, LineScaleMode.NONE);
        graphics.moveTo(startVec.x, startVec.y);
        graphics.lineTo(endVec.x, endVec.y);

        // filters = [new GlowFilter(color, 0.6, 24, 24, 5, 3)];
    }
}
internal class BezierMath {
    private const FACTORIAL_MAXEXACT : Number = 20;
    private const LNGAMMA_COEFFS : Vector.<Number> = Vector.<Number>([76.18009172947146, -86.50532032941677, 24.01409824083091, -1.231739572450155, 0.1208650973866179e-2, -0.5395239384953e-5]);
    /* */
    private var combinatoryData : Vector.<Vector.<Number>> = new Vector.<Vector.<Number>>(13, true);
    private var fcache : Object;

    public function BezierMath() {
        combinatoryData[0] = Vector.<Number>([0]);
        combinatoryData[1] = Vector.<Number>([1]);
        combinatoryData[2] = Vector.<Number>([1, 1]);
        combinatoryData[3] = Vector.<Number>([1, 2, 1]);
        combinatoryData[4] = Vector.<Number>([1, 3, 3, 1]);
        combinatoryData[5] = Vector.<Number>([1, 4, 6, 4, 1]);
        combinatoryData[6] = Vector.<Number>([1, 5, 10, 10, 5, 1]);
        combinatoryData[7] = Vector.<Number>([1, 6, 15, 20, 15, 6, 1]);
        combinatoryData[8] = Vector.<Number>([1, 7, 21, 35, 35, 21, 7, 1]);
        combinatoryData[9] = Vector.<Number>([1, 8, 28, 56, 70, 56, 28, 8, 1]);
        combinatoryData[10] = Vector.<Number>([1, 9, 36, 84, 126, 126, 84, 36, 9, 1]);
        combinatoryData[11] = Vector.<Number>([1, 10, 45, 120, 210, 252, 210, 120, 45, 10, 1]);
        combinatoryData[12] = Vector.<Number>([1, 11, 56, 165, 330, 462, 462, 330, 165, 56, 11, 1]);

        fcache = initFactorialCache(FACTORIAL_MAXEXACT);
    }

    public function bezier(t : Number, controlPoints : Vector.<Vector3D>) : Vector3D {
        var out : Vector3D = new Vector3D();

        var coefficients : Vector.<Number> = new Vector.<Number>(0, false);
        var lenght : Number = controlPoints.length;

        if (combinatoryData[lenght] == null) {
            combinatoryData[lenght] = new Vector.<Number>(0, false);

            var n : uint = 0;
            while (n < length) {
                combinatoryData[lenght].push(combinatoria(length - 1, n));
                ++n;
            }
        }

        n = 0;
        while (n <= (lenght - 1)) {
            coefficients[n] = combinatoryData[lenght][n] * Math.pow(t, n) * Math.pow((1 - t), (lenght - 1) - n);
            ++n;
        }

        var delta : Number = 0;

        n = 0;
        while (n <= (lenght - 1)) {
            out.x += coefficients[n] * controlPoints[n].x * controlPoints[n].w;
            out.y += coefficients[n] * controlPoints[n].y * controlPoints[n].w;
            out.z += coefficients[n] * controlPoints[n].z * controlPoints[n].w;

            delta += coefficients[n] * controlPoints[n].w;

            ++n;
        }

        out.x = out.x / delta;
        out.y = out.y / delta;
        out.z = out.z / delta;

        return out;
    }

    private function combinatoria(n : int, i : int) : Number {
        return factorial(n) / (factorial(i) * factorial(n - i));
    }

    private function factorial(n : int) : Number {
        var out : Number = fcache[n];
        return out ? out : fcache[n] = (n <= FACTORIAL_MAXEXACT) ? factorial(n - 1) : Math.exp(lnGamma(n));
    }

    private function lnGamma(n : Number) : Number {
        var y : Number = n;
        var tmp : Number = n + 5.5;
        tmp -= (n + 0.5) * Math.log(tmp);

        var ser : Number = 1.000000000190015;
        for (var j : int = 0; j <= 5; j++) {
            y += 1;
            ser += LNGAMMA_COEFFS[j] / y;
        }

        return -tmp + Math.log(2.5066282746310005 * ser / n);
    }

    private function initFactorialCache(max : int) : Object {
        var cache : Object = new Object();
        var fact : Number = 1;
        cache[0] = 1;
        for (var tmp : int = 1; tmp <= max; tmp++) {
            fact *= tmp;
            cache[tmp] = fact;
        }
        return cache;
    }
}

import flash.display.*;
import flash.events.*;
import flash.filters.*;
import flash.geom.*;

class EffectContainer extends Sprite {
    public var blur:Boolean = false;
    public var colorIntegrity:Boolean = false;
    public var intensity:Number = 4;
    public var passes:uint = 6;
    public var rasterQuality:String = null;
    public var scale:Number = 2;
    public var smoothing:Boolean = true;
    public var srcX:Number;
    public var srcY:Number;

    protected var _blurFilter:BlurFilter = new BlurFilter(2, 2);
    protected var _emission:DisplayObject;
    protected var _occlusion:DisplayObject;
    protected var _ct:ColorTransform = new ColorTransform;
    protected var _halve:ColorTransform = new ColorTransform(0.5, 0.5, 0.5);
    protected var _occlusionLoResBmd:BitmapData;
    protected var _occlusionLoResBmp:Bitmap;
    protected var _baseBmd:BitmapData;
    protected var _bufferBmd:BitmapData;
    protected var _lightBmp:Bitmap = new Bitmap;
    protected var _bufferSize:uint = 0x8000;
    protected var _bufferRect:Rectangle = new Rectangle;
    protected var _viewportWidth:uint;
    protected var _viewportHeight:uint;
    protected var _mtx:Matrix = new Matrix;
    protected var _zero:Point = new Point;

    public function EffectContainer(width:uint, height:uint, emission:DisplayObject, occlusion:DisplayObject = null) {
        if(!emission) throw(new Error("emission DisplayObject must not be null."));
        addChild(_emission = emission);
        if(occlusion) addChild(_occlusion = occlusion);
        setViewportSize(width, height);
        _lightBmp.blendMode = BlendMode.ADD;
        addChild(_lightBmp);
        srcX = width / 2;
        srcY = height / 2;
    }

    public function setViewportSize(width:uint, height:uint):void {
        _viewportWidth = width;
        _viewportHeight = height;
        scrollRect = new Rectangle(0, 0, width, height);
        _updateBuffers();
    }

    public function setBufferSize(size:uint):void {
        _bufferSize = size;
        _updateBuffers();
    }

    protected function _updateBuffers():void {
        var aspect:Number = _viewportWidth / _viewportHeight;
        _bufferRect.height = int(Math.max(1, Math.sqrt(_bufferSize / aspect)));
        _bufferRect.width  = int(Math.max(1, _bufferRect.height * aspect));
        dispose();
        _baseBmd           = new BitmapData(_bufferRect.width, _bufferRect.height, false, 0);
        _bufferBmd         = new BitmapData(_bufferRect.width, _bufferRect.height, false, 0);
        _occlusionLoResBmd = new BitmapData(_bufferRect.width, _bufferRect.height, true, 0);
        _occlusionLoResBmp = new Bitmap(_occlusionLoResBmd);
    }

    public function render(e:Event = null):void {
        if(!(_lightBmp.visible = intensity > 0)) return;
        var savedQuality:String = stage.quality;
        if(rasterQuality) stage.quality = rasterQuality;
        var mul:Number = colorIntegrity ? intensity : intensity/(1<<passes);
        _ct.redMultiplier = _ct.greenMultiplier = _ct.blueMultiplier = mul;
        _drawLoResEmission();
        if(_occlusion) _eraseLoResOcclusion();
        if(rasterQuality) stage.quality = savedQuality;
        var s:Number = 1 + (scale-1) / (1 << passes);
        var tx:Number = srcX/_viewportWidth*_bufferRect.width;
        var ty:Number = srcY/_viewportHeight*_bufferRect.height;
        _mtx.identity();
        _mtx.translate(-tx, -ty);
        _mtx.scale(s, s);
        _mtx.translate(tx, ty);
        _applyEffect(_baseBmd, _bufferRect, _bufferBmd, _mtx, passes);
        _lightBmp.bitmapData = _baseBmd;
        _lightBmp.width = _viewportWidth;
        _lightBmp.height = _viewportHeight;
        _lightBmp.smoothing = smoothing;
    }

    protected function _drawLoResEmission():void {
        _copyMatrix(_emission.transform.matrix, _mtx);
        _mtx.scale(_bufferRect.width / _viewportWidth, _bufferRect.height / _viewportHeight);
        _baseBmd.fillRect(_bufferRect, 0);
        _baseBmd.draw(_emission, _mtx, colorIntegrity ? null : _ct);
    }

    protected function _eraseLoResOcclusion():void {
        _occlusionLoResBmd.fillRect(_bufferRect, 0);
        _copyMatrix(_occlusion.transform.matrix, _mtx);
        _mtx.scale(_bufferRect.width / _viewportWidth, _bufferRect.height / _viewportHeight);
        _occlusionLoResBmd.draw(_occlusion, _mtx);
        _baseBmd.draw(_occlusionLoResBmp, null, null, BlendMode.ERASE);
    }

    public function startRendering():void {
        addEventListener(Event.ENTER_FRAME, render);
    }

    public function stopRendering():void {
        removeEventListener(Event.ENTER_FRAME, render);
    }

    protected function _applyEffect(bmd:BitmapData, rect:Rectangle, buffer:BitmapData, mtx:Matrix, passes:uint):void {
        while(passes--) {
            if(colorIntegrity) bmd.colorTransform(rect, _halve);
            buffer.copyPixels(bmd, rect, _zero);
            bmd.draw(buffer, mtx, null, BlendMode.ADD, null, true);
            mtx.concat(mtx);
        }
        if(colorIntegrity) bmd.colorTransform(rect, _ct);
        if(blur) bmd.applyFilter(bmd, rect, _zero, _blurFilter);
    }

    public function dispose():void {
        if(_baseBmd) _baseBmd.dispose();
        if(_occlusionLoResBmd) _occlusionLoResBmd.dispose();
        if(_bufferBmd) _bufferBmd.dispose();
        _baseBmd = _occlusionLoResBmd = _bufferBmd = _lightBmp.bitmapData = null;
    }

    protected function _copyMatrix(src:Matrix, dst:Matrix):void {
        dst.a = src.a;
        dst.b = src.b;
        dst.c = src.c;
        dst.d = src.d;
        dst.tx = src.tx;
        dst.ty = src.ty;
    }
}

import flash.display.*;
import flash.events.*;
import flash.geom.*;

class VolumetricPointLight extends EffectContainer {
    protected var _colors:Array;
    protected var _alphas:Array;
    protected var _ratios:Array;
    protected var _gradient:Shape = new Shape;
    protected var _gradientMtx:Matrix = new Matrix;
    protected var _gradientBmp:Bitmap = new Bitmap;
    protected var _lastSrcX:Number;
    protected var _lastSrcY:Number;
    protected var _lastIntensity:Number;
    protected var _lastColorIntegrity:Boolean = false;
    protected var _gradientLoResBmd:BitmapData;
    protected var _gradientLoResDirty:Boolean = true;

    public function VolumetricPointLight(width:uint, height:uint, occlusion:DisplayObject, colorOrGradient:*, alphas:Array = null, ratios:Array = null) {
        if(colorOrGradient is Array) {
            _colors = colorOrGradient.concat();
            _ratios = ratios || _colors.map(function(item:*, i:int, arr:Array):int { return 0x100*i/(colorOrGradient.length+i-1) });
            _alphas = alphas || _colors.map(function(..._):Number { return 1 });
        } else {
            _colors = [colorOrGradient, 0];
            _ratios = [0, 255];
        }
        super(width, height, _gradientBmp, occlusion);
        if(!occlusion) throw(new Error("An occlusion DisplayObject must be provided."));
        if(!(colorOrGradient is Array || colorOrGradient is uint)) throw(new Error("colorOrGradient must be either an Array or a uint."));
    }

    protected function _drawGradient():void {
        var size:Number = 2 * Math.sqrt(_viewportWidth*_viewportWidth + _viewportHeight*_viewportHeight);
        _gradientMtx.createGradientBox(size, size, 0, -size/2 + srcX, -size/2 + srcY);
        _gradient.graphics.clear();
        _gradient.graphics.beginGradientFill(GradientType.RADIAL, _colors, _alphas, _ratios, _gradientMtx);
        _gradient.graphics.drawRect(0, 0, _viewportWidth, _viewportHeight);
        _gradient.graphics.endFill();
        if(_gradientBmp.bitmapData) _gradientBmp.bitmapData.dispose();
        _gradientBmp.bitmapData = new BitmapData(_viewportWidth, _viewportHeight, true, 0);
        _gradientBmp.bitmapData.draw(_gradient);
    }

    override protected function _drawLoResEmission():void {
        if(_gradientLoResDirty) {
            super._drawLoResEmission();
            _gradientLoResBmd.copyPixels(_baseBmd, _bufferRect, _zero);
            _gradientLoResDirty = false;
        } else {
            _baseBmd.copyPixels(_gradientLoResBmd, _bufferRect, _zero);
        }
    }

    override protected function _updateBuffers():void {
        super._updateBuffers();
        _gradientLoResBmd = new BitmapData(_bufferRect.width, _bufferRect.height, false, 0);
        _gradientLoResDirty = true;
    }

    override public function setViewportSize(width:uint, height:uint):void {
        super.setViewportSize(width, height);
        _drawGradient();
        _gradientLoResDirty = true;
    }

    override public function render(e:Event = null):void {
        var srcChanged:Boolean = _lastSrcX != srcX || _lastSrcY != srcY;
        if(srcChanged) _drawGradient();
        _gradientLoResDirty ||= srcChanged;
        _gradientLoResDirty ||= (!colorIntegrity && (_lastIntensity != intensity));
        _gradientLoResDirty ||= (_lastColorIntegrity != colorIntegrity);
        _lastSrcX = srcX;
        _lastSrcY = srcY;
        _lastIntensity = intensity;
        _lastColorIntegrity = colorIntegrity;
        super.render(e);
    }

    override public function dispose():void {
        super.dispose();
        if(_gradientLoResBmd) _gradientLoResBmd.dispose();
        _gradientLoResBmd = null;
    }
}
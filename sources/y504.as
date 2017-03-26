package
{
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageQuality;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.geom.Rectangle;

    [SWF(width='465', height='465', backgroundColor='0x000000', frameRate='64')]
    public class OctopusApp extends Sprite {
        private var _lux : LuxMod;
        private var _octopus : OctopusGenerator;

        public function OctopusApp() {
            stage.stageFocusRect = mouseEnabled = tabEnabled = tabChildren = false;
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
            stage.quality = StageQuality.HIGH;
            stage.fullScreenSourceRect = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
            /* */

            _octopus = new OctopusGenerator(stage.stageWidth, stage.stageHeight);
            _lux = new LuxMod(_octopus);

            addChild(_lux);

            stage.addEventListener(Event.ENTER_FRAME, update, false, 0, true);
        }

        private function update(e : Event) : void {
            _lux.lightX = stage.stageWidth >> 1;
            _lux.lightY = stage.stageHeight >> 1;
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
    private const CURVE_QUANT : uint = 16;
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
    private var _fadeCT : ColorTransform = new ColorTransform(1, 1, 1, 0.999);
    private var _colorIndex : uint = 0;
    private var _container : Sprite = new Sprite();
    private var _bezierMath : BezierMath = new BezierMath();

    public function OctopusGenerator(w : uint, h : uint) : void {
        super(new BitmapData(w, h, false, 0), PixelSnapping.AUTO, false);

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
        while (--n) {
            _endPoints = _bezierMath.bezier(_t / TIME_SCALE, _controlPoints[n]);
            _container.addChild(new GlowLine(_startPoints[n], _endPoints, colorInterpolation(_colors[_colorIndex], _colors[_colorIndex + 1], _t / TIME_SCALE), _gurfs[n], _gurfs[n] / 4));
            _startPoints[n] = _endPoints;
        }

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

        filters = [new GlowFilter(color, 0.6, 24, 24, 5, 3)];
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
internal class LuxMod extends Sprite {
    public var lightX : Number;
    public var lightY : Number;
    /* */
    private var _passes : uint = 6;
    private var _scale : Number = 2.2;
    private var _smooth : Boolean = true;
    /* */
    private var _src : DisplayObject;
    private var _light : Bitmap = new Bitmap(null, PixelSnapping.AUTO, false);
    private var _cth : ColorTransform = new ColorTransform(0.5, 0.5, 0.5);
    private var _baseBmd : BitmapData;
    private var _offscrBmd : BitmapData;
    private var _bufferSize : uint = 0x8000;
    private var _bufferWidth : uint;
    private var _bufferHeight : uint;
    private var _sw : int;
    private var _sh : int;
    private var _matrix : Matrix = new Matrix();
    private var _tmp : BitmapData;

    public function LuxMod(emission : DisplayObject) {

        addChild(_src = emission);
        addChild(_light).blendMode = BlendMode.ADD;

        stage ? onStage(null) : addEventListener(Event.ADDED_TO_STAGE, onStage, false, 0, true);
    }

    private function onStage(e : Event) : void {
        if (e) removeEventListener(Event.ADDED_TO_STAGE, onStage);

        stage.addEventListener(Event.RESIZE, resize, false, 0, true);
        resize(null);

        go();
    }

    private function render(e : Event) : void {
        copyMatrix(_src.transform.matrix, _matrix);
        _matrix.scale(_bufferWidth / _sw, _bufferHeight / _sh);

        _baseBmd.fillRect(_baseBmd.rect, 0);
        _baseBmd.draw(_src, _matrix, null);

        var s : Number = 1 + (_scale - 1) / (1 << _passes);
        var dx : Number = lightX / _sw * _bufferWidth;
        var dy : Number = lightY / _sh * _bufferHeight;

        _matrix.identity();
        _matrix.translate(-dx, -dy);
        _matrix.scale(s, s);
        _matrix.translate(dx, dy);

        _light.bitmapData = modify(_baseBmd, _offscrBmd, _matrix, _passes);
        _light.width = _sw;
        _light.height = _sh;
        _light.smoothing = _smooth;
    }

    private function modify(source : BitmapData, buffer : BitmapData, matrix : Matrix, passes : uint) : BitmapData {
        while (passes--) {
            source.colorTransform(source.rect, _cth);

            buffer.copyPixels(source, source.rect, source.rect.topLeft);
            buffer.draw(source, matrix, null, BlendMode.ADD, null, true);
            matrix.concat(matrix);

            _tmp = source;
            source = buffer;
            buffer = _tmp;
        }

        return source;
    }

    private function resize(e : Event) : void {
        _sw = stage.stageWidth;
        _sh = stage.stageHeight;

        lightX = _sw >> 1;
        lightY = _sh >> 1;

        scrollRect = new Rectangle(0, 0, width, height);

        var aspect : Number = _sw / _sh;

        _bufferHeight = Math.max(1, Math.sqrt(_bufferSize / aspect));
        _bufferWidth = Math.max(1, _bufferHeight * aspect);

        if (_baseBmd) _baseBmd.dispose();
        if (_offscrBmd) _offscrBmd.dispose();

        _baseBmd = _offscrBmd = _light.bitmapData = null;

        _baseBmd = new BitmapData(_bufferWidth, _bufferHeight, false, 0);
        _offscrBmd = new BitmapData(_bufferWidth, _bufferHeight, false, 0);
    }

    public function go() : void {
        if (!hasEventListener(Event.ENTER_FRAME)) addEventListener(Event.ENTER_FRAME, render, false, 0, true);
    }

    public function no_go() : void {
        if (hasEventListener(Event.ENTER_FRAME)) removeEventListener(Event.ENTER_FRAME, render);
    }

    private function copyMatrix(src : Matrix, dst : Matrix) : void {
        dst.a = src.a;
        dst.b = src.b;
        dst.c = src.c;
        dst.d = src.d;
        dst.tx = src.tx;
        dst.ty = src.ty;
    }
}
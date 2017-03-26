/**
 * Copyright 9re ( http://wonderfl.net/user/9re )
 * MIT License ( http://www.opensource.org/licenses/mit-license.php )
 * Downloaded from: http://wonderfl.net/c/5wO8
 */

// forked from yonatan's VolumetricPointLight demo
// forked from k3lab's Grid
package {

	import com.adobe.serialization.json.JSON;

	import flash.display.*;
	import flash.events.*;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundLoaderContext;
	import flash.media.SoundMixer;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;

    [SWF(width="465", height="465", backgroundColor="0", frameRate="30")]
    public class PointLightDemo extends Sprite {
        private var fx:VolumetricPointLight;
        private var julia:JuliaSet = new JuliaSet;
        private var sun:SunIcon = new SunIcon;
        private var _t:Number = 0;
        private var _halfWidth:int;
		private var _halfHeight:int;
		private var bytes:ByteArray;
		private var vol:Number;
		private var snd:Sound;

        public function PointLightDemo():void {
            addEventListener(Event.ADDED_TO_STAGE, init);
            if(null != stage) init();
        }

        private function init(e:Event = null):void {
            removeEventListener(Event.ADDED_TO_STAGE, init);
            stage.quality = "medium";
            stage.align = "TL";
            stage.scaleMode = "noScale";

            // Create a VolumetricPointLight object, use the grid as the occlusion object.
			fx = new VolumetricPointLight(465, 465, julia, [0xFFFFFF * Math.random()+0xFFFFFF/2, 0xCCCCCC * Math.random()+0xFFFFFF/2, 0], [1, 1, 1], [0, 20, 30]);
            // You can also specify a single color instead of gradient params, for example:
            //   fx = new VolumetricPointLight(800, 600, grid, 0xc08040);
            // is equivalent to:
            //   fx = new VolumetricPointLight(800, 600, grid, [0xc08040, 0], [1, 1], [0, 255]);

            addChild(fx);
            // Render on every frame.
            fx.startRendering();

            stage.addEventListener(Event.RESIZE, onResize);
            stage.dispatchEvent(new Event(Event.RESIZE));

            // Sun icon used to control light source position
//            addChild(sun);

			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, loaded);
			
			loader.load(new URLRequest("http://api.beatport.com/catalog/most-popular/label?format=json&v=1.0&id=557&perPage=10&page=1"));
            
			bytes = new ByteArray();
            
            addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}

		private function loaded(e:Event):void {
			var json:Object = JSON.decode(e.target.data);
			snd = new Sound();
            var context:SoundLoaderContext = new SoundLoaderContext(10, true);
            var rank : int=-1+json.results.length*Math.random()>>0;
            var req:URLRequest = new URLRequest(json.results[rank].sampleUrl);
			trace('rank: ' + (rank));
			trace('json.results[rank].sampleUrl: ' + (json.results[rank].sampleUrl));
            snd.load(req, context);
            var sndChannel:SoundChannel = new SoundChannel();
            sndChannel = snd.play(0, 0);
        }
        
        private function onEnterFrame(event:Event):void {

			bytes.clear();
			SoundMixer.computeSpectrum(bytes, false, 255);
			vol = bytes.readFloat();

			_t += 0.05;
            var px:Number = _halfWidth * (1 + Math.cos(4 * _t));
            var py:Number = _halfHeight * (1 + Math.sin(5 * _t));
            fx.srcX = px; fx.srcY = py;
//            sun.x = px; sun.y = py;

			julia.value = vol * .5;
        }

        private function onResize(e:Event):void {
            var w:int = stage.stageWidth;
            var h:int = stage.stageHeight;
            _halfWidth = w >> 1;
            _halfHeight = h >> 1;
            fx.setViewportSize(w, h);
            sun.x = fx.srcX = _halfWidth;
            sun.y = fx.srcY = _halfHeight;
        }
    }
}

import flash.display.*;
import flash.events.*;
import flash.filters.*;
import flash.geom.*;

class SunIcon extends Sprite {
    public function SunIcon() {
        buttonMode = true;
        graphics.beginFill(0, 0);
        graphics.drawCircle(0, 0, 14);
        graphics.endFill();
        graphics.lineStyle(1, 0xffc040);
        graphics.drawCircle(0, 0, 4);
        filters = [new GlowFilter(0, 1, 4, 4, 8)];
        for(var i:int = 0; i < 10; i++) {
            var sin:Number = Math.sin(Math.PI*2*i/10);
            var cos:Number = Math.cos(Math.PI*2*i/10);
            graphics.moveTo(sin*7, cos*7);
            graphics.lineTo(sin*12, cos*12);
        }
    }
}


/**
* The EffectContainer class creates a volumetric light effect (also known as crepuscular or "god" rays).
* This is done in 2D with some bitmap processing of an emission object, and optionally an occlusion object.
*/
class EffectContainer extends Sprite {
    /**
    * When true a blur filter is applied to the final effect bitmap (can help when colorIntegrity == true).
    */
    public var blur:Boolean = true;
    /**
    * Selects rendering method; when set to true colors won't be distorted and performance will be
    * a little worse. Also, this might make the final output appear grainier.
    */
    public var colorIntegrity:Boolean = false;
    /**
    * Light intensity.
    */
    public var intensity:Number = 6;
    /**
    * Number of passes applied to buffer. Lower numbers mean lower quality but better performance,
    * anything above 8 is probably overkill.
    */
    public var passes:uint = 6;
    /**
    * Set this to one of the StageQuality constants to use this quality level when drawing bitmaps, or to
    * null to use the current stage quality. Mileage may vary on different platforms and player versions.
    * I think it should only be used when stage.quality is LOW (set this to BEST to get reasonable results).
    */
    public var rasterQuality:String = null;
    /**
    * Final scale of emission. Should always be more than 1.
    */
    public var scale:Number = 2;
    /**
    * Smooth scaling of the effect's final output bitmap.
    */
    public var smoothing:Boolean = true;
    /**
    * Light source x.
    * @default viewport center (set in constructor).
    */
    public var srcX:Number;
    /**
    * Light source y.
    * @default viewport center (set in constructor).
    */
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
    protected var _bufferWidth:uint;
    protected var _bufferHeight:uint;
    protected var _viewportWidth:uint;
    protected var _viewportHeight:uint;
    protected var _mtx:Matrix = new Matrix;

    /**
    * Creates a new effect container.
    *
    * @param width Viewport width in pixels.
    * @param height Viewport height in pixels.
    * @param emission A DisplayObject to which the effect will be applied. This object will be
    * added as a child of the container. When applying the effect the object's filters and color
    * matrix is ignored, if you want to use filters or a color matrix put your content in another
    * object and addChild it to this one instead.
    * @param occlusion An optional occlusion object, handled the same way as the emission object.
    */
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

    /**
    * Sets the container's size. This method recreates internal buffers (slow), do not call this on
    * every frame.
    *
    * @param width Viewport width in pixels
    * @param height Viewport height in pixels
    */
    public function setViewportSize(width:uint, height:uint):void {
        _viewportWidth = width;
        _viewportHeight = height;
        scrollRect = new Rectangle(0, 0, width, height);
        _updateBuffers();
    }

    /**
    * Sets the approximate size (in pixels) of the effect's internal buffers. Smaller number means lower
    * quality and better performance. This method recreates internal buffers (slow), do not call this on
    * every frame.
    *
    * @param size Buffer size in pixels
    */
    public function setBufferSize(size:uint):void {
        _bufferSize = size;
        _updateBuffers();
    }

    protected function _updateBuffers():void {
        var aspect:Number = _viewportWidth / _viewportHeight;
        _bufferHeight = Math.max(1, Math.sqrt(_bufferSize / aspect));
        _bufferWidth  = Math.max(1, _bufferHeight * aspect);
        dispose();
        _baseBmd           = new BitmapData(_bufferWidth, _bufferHeight, false, 0);
        _bufferBmd         = new BitmapData(_bufferWidth, _bufferHeight, false, 0);
        _occlusionLoResBmd = new BitmapData(_bufferWidth, _bufferHeight, true, 0);
        _occlusionLoResBmp = new Bitmap(_occlusionLoResBmd);
    }

    /**
    * Render a single frame.
    *
    * @param e In case you want to make this an event listener.
    */
    public function render(e:Event = null):void {
        var savedQuality:String = stage.quality;
        if(rasterQuality) stage.quality = rasterQuality;
        var mul:Number = colorIntegrity ? intensity : intensity/(1<<passes);
        _ct.redMultiplier = _ct.greenMultiplier = _ct.blueMultiplier = mul;
        _drawLoResEmission();
        if(_occlusion) _eraseLoResOcclusion();
        if(rasterQuality) stage.quality = savedQuality;
        var s:Number = 1 + (scale-1) / (1 << passes);
        var tx:Number = srcX/_viewportWidth*_bufferWidth;
        var ty:Number = srcY/_viewportHeight*_bufferHeight;
        _mtx.identity();
        _mtx.translate(-tx, -ty);
        _mtx.scale(s, s);
        _mtx.translate(tx, ty);
        _lightBmp.bitmapData = _applyEffect(_baseBmd, _bufferBmd, _mtx, passes);
        _lightBmp.width = _viewportWidth;
        _lightBmp.height = _viewportHeight;
        _lightBmp.smoothing = smoothing;
    }

    /**
    * Draws a scaled-down emission on _baseBmd.
    */
    protected function _drawLoResEmission():void {
        _copyMatrix(_emission.transform.matrix, _mtx);
        _mtx.scale(_bufferWidth / _viewportWidth, _bufferHeight / _viewportHeight);
        _baseBmd.fillRect(_baseBmd.rect, 0);
        _baseBmd.draw(_emission, _mtx, colorIntegrity ? null : _ct);
    }

    /**
    * Draws a scaled-down occlusion on _occlusionLoResBmd and erases it from _baseBmd.
    */
    protected function _eraseLoResOcclusion():void {
        _occlusionLoResBmd.fillRect(_occlusionLoResBmd.rect, 0);
        _copyMatrix(_occlusion.transform.matrix, _mtx);
        _mtx.scale(_bufferWidth / _viewportWidth, _bufferHeight / _viewportHeight);
        _occlusionLoResBmd.draw(_occlusion, _mtx);
        _baseBmd.draw(_occlusionLoResBmp, null, null, BlendMode.ERASE);
    }

    /**
    * Render the effect on every frame until stopRendering is called.
    */
    public function startRendering():void {
        addEventListener(Event.ENTER_FRAME, render);
    }

    /**
    * Stop rendering on every frame.
    */
    public function stopRendering():void {
        removeEventListener(Event.ENTER_FRAME, render);
    }

    /**
    * Low-level workhorse, applies the lighting effect to a bitmap. This function modifies the src and buffer
    * bitmaps and it's mtx argument.
    *
    * @param src The BitmapData to apply the effect on.
    * @param buffer Another BitmapData object for temporary storage. Must be the same size as src.
    * @param mtx Effect matrix.
    * @param passes Number of passes to make.
    * @return A processed BitmapData object (supllied in either src or buffer) with final effect output.
    */
    protected function _applyEffect(src:BitmapData, buffer:BitmapData, mtx:Matrix, passes:uint):BitmapData {
        var tmp:BitmapData;
        while(passes--) {
            if(colorIntegrity) src.colorTransform(src.rect, _halve);
            buffer.copyPixels(src, src.rect, src.rect.topLeft);
            buffer.draw(src, mtx, null, BlendMode.ADD, null, true);
            mtx.concat(mtx);
            tmp = src; src = buffer; buffer = tmp;
        }
        if(colorIntegrity) src.colorTransform(src.rect, _ct);
        if(blur) src.applyFilter(src, src.rect, src.rect.topLeft, _blurFilter);
        return src;
    }

    /**
    * Dispose of all intermediate buffers. After calling this the EffectContainer object will be unusable.
    */
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


/**
* VolumetricPointLight creates a simple effect container with a gradient emission pattern.
* The gradient's center is automatically moved to the (srcX, srcY) coordinates
* and it's radius is adjusted to the length of the viewport's diagonal, so if you
* set srcX and srcY to the viewport's center then only half of the gradient colors
* will be used.
*
* <p>This should also perform a little better than EffectContainer.</p>
*/
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

    /**
    * Creates a new effect container, with an emission created from the supplied color or gradient.
    * The constructor lets you use a shortcut syntax for creating simple single-color gradients.
    * @example The shortcut syntax:
    * <listing>new VolumetricPointLight(800, 600, occlusion, 0xc08040);</listing>
    * @example is equivalent to:
    * <listing>new VolumetricPointLight(800, 600, occlusion, [0xc08040, 0], [1, 1], [0, 255]);</listing>
    *
    * @param width Viewport width in pixels.
    * @param height Viewport height in pixels.
    * @param occlusion An occlusion object, will be overlayed above the lighting gradient and under the light effect bitmap.
    * @param colorOrGradient Either a gradient colors array, or a uint color value.
    * @param alphas Will only be used if colorOrGradient is an array. This will be passed to beginGradientFill.
    *               If not provided alphas will all be 1.
    * @param ratios Will only be used if colorOrGradient is an array. This will be passed to
    *               beginGradientFill. If colorOrGradient is an Array and ratios aren't provided default
    *               ones will be created automatically.
    */
    public function VolumetricPointLight(width:uint, height:uint, occlusion:DisplayObject, colorOrGradient:*, alphas:Array = null, ratios:Array = null) {
        if(colorOrGradient is Array) {
            _colors = colorOrGradient.concat();
            if(!ratios)    _ratios = colorOrGradient.map(function(item:*, i:int, arr:Array):int { return 0x100*i/(colorOrGradient.length+i-1) });
            if(!alphas) _alphas = _colors.map(function(..._):Number { return 1 });
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

    /**
    * Updates the lo-res gradient bitmap if neccesary and copies it to _baseBmd.
    */
    override protected function _drawLoResEmission():void {
        if(_gradientLoResDirty) {
            super._drawLoResEmission();
            _gradientLoResBmd.copyPixels(_baseBmd, _baseBmd.rect, _baseBmd.rect.topLeft);
            _gradientLoResDirty = false;
        } else {
            _baseBmd.copyPixels(_gradientLoResBmd, _baseBmd.rect, _baseBmd.rect.topLeft);
        }
    }

    /** @inheritDoc */
    override protected function _updateBuffers():void {
        super._updateBuffers();
        _gradientLoResBmd = new BitmapData(_bufferWidth, _bufferHeight, false, 0);
        _gradientLoResDirty = true;
    }

    /** @inheritDoc */
    override public function setViewportSize(width:uint, height:uint):void {
        super.setViewportSize(width, height);
        _drawGradient();
        _gradientLoResDirty = true;
    }

    /** @inheritDoc */
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
}

class JuliaSet extends Sprite {
    private static const MAX_ITER:int = 10;
    private var _bm:Bitmap;
    private var _canvas:BitmapData;
    private var _left:Number;
    private var _right:Number;
    private var _top:Number;
    private var _bottom:Number;
    private var _angle:Number = 0.0;
    private var _scaleFactor:Number = 2.0;
    private var _width:Number;
	private var _height:Number;
	private var _value:Number;
        
    public function JuliaSet() {
        stage ?
            init() : 
            addEventListener(Event.ADDED_TO_STAGE, init);
    }
        
    private function init(e:Event = null):void {
        if (e) removeEventListener(Event.ADDED_TO_STAGE, init);
        _bm = new Bitmap;
        _bm.scaleX = _bm.scaleY = _scaleFactor;
        addChild(_bm);
            
        _left = -1.7; _right = 1.7;
        _top = 1.0; _bottom = -1.0;
		_value = 0.0003;
        
        stage.addEventListener(Event.RESIZE, onResize);
        stage.dispatchEvent(new Event(Event.RESIZE));
            
        addEventListener(Event.ENTER_FRAME, onEnter);
    }
        
    private function onEnter(event:Event):void {
        _angle += _value;
       update();
    }
    
    private function onResize(e:Event):void {
        _width = stage.stageWidth / _scaleFactor;
        _height = stage.stageHeight / _scaleFactor;
        var r:Number = _width / _height;
        _left = r * _bottom;
        _right = r * _top;
        _canvas = new BitmapData(_width, _height, true);
        _bm.bitmapData = _canvas;
        update();
    }
        
    private function update():void {
        var i:int, j:int, px:Number, py:Number;
        var k:int, sqx:Number, sqy:Number;
        var tx:Number, cx:Number, cy:Number;
        var abs:Number, c:int, zx:Number, zy:Number;
        cx = 1.7 * Math.cos(_angle * 7);
        cy = 1.7 * Math.sin(_angle * 5);
        i = _width;
        _canvas.lock();
        _canvas.fillRect(_canvas.rect, 0xa0000000);
        while (i--) {
            j = _height;
            px = i / _width;
            px = px * _right + (1 - px) * _left;
            while (j--) {
                py = j / _height;
                py = py * _bottom + (1 - py) * _top;
                k = MAX_ITER;
                zx = px;
                zy = py;
                while (k--) {
                    sqx = zx * zx; sqy = zy * zy;
                    tx = sqx - sqy + cx;
                    zy = 2 * zx * zy + cy;
                    zx = tx;
                    if (sqx + sqy > 3.4) {
                        break;
                    }
                }
                k = k == MAX_ITER ? 0 : k;
                c = ((( k / MAX_ITER) * 0xff) << 24);
                _canvas.setPixel32(i >> 0, j >> 0, c);
            }
        }
		_canvas.unlock();
	}

	public function set value(value:Number):void {
		_value = value;
	}
}
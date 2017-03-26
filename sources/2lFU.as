// forked from yonatan's VolumetricPointLight demo
// forked from k3lab's Grid

package {
    import flash.display.*;
    import flash.events.*;

    [SWF(width="465", height="465", backgroundColor="0x000000", frameRate="30")]
    public class OldSkoolPointLight extends Sprite {
        private var fx:VolumetricPointLight;
        private var oldskool:OldSkool = new OldSkool;
        private var _t:Number = 0;
        private var _halfWidth:uint;
        private var _halfHeight:uint;

        public function OldSkoolPointLight():void {
            addEventListener(Event.ADDED_TO_STAGE, init);
            if(null != stage) init();
        }

        private function init(e:Event = null):void {
            removeEventListener(Event.ADDED_TO_STAGE, init);
            stage.quality = "medium";
            stage.align = "TL";
            stage.scaleMode = "noScale";

            // Create a VolumetricPointLight object, use the grid as the occlusion object.
            fx = new VolumetricPointLight(465, 465, oldskool,[0x6a4b00,0x000f13,0x0, 0x130013, 0x0]);//, 0x46497c]);
            // You can also specify a single color instead of gradient params, for example:
            //   fx = new VolumetricPointLight(800, 600, grid, 0xc08040);
            // is equivalent to:
            //   fx = new VolumetricPointLight(800, 600, grid, [0xc08040, 0], [1, 1], [0, 255]);
//ff9c00
            addChild(fx);
            // Render on every frame.
            fx.startRendering();

            stage.addEventListener(Event.RESIZE, onResize);
            stage.dispatchEvent(new Event(Event.RESIZE));
            addEventListener(Event.ENTER_FRAME, onEnterFrame);
        }

        private function onEnterFrame(event:Event):void {
            _t += .01 * Math.random();
            var px:Number = _halfWidth * (1 + Math.cos(4 * _t));
            var py:Number = _halfHeight * (1 + Math.sin(5 * _t));
            fx.srcX = px;
            fx.srcY = py;
        }

        private function onResize(e:Event):void {
            var w:int = stage.stageWidth;
            var h:int = stage.stageHeight;
            _halfWidth = w >> 1;
            _halfHeight = h >> 1;
            fx.setViewportSize(w, h);
        }
    }
}

import flash.display.*;
import flash.events.*;
import flash.filters.*;
import flash.geom.*;

/**
* The EffectContainer class creates a volumetric light effect (also known as crepuscular or "god" rays).
* This is done in 2D with some bitmap processing of an emission object, and optionally an occlusion object.
*/
class EffectContainer extends Sprite {
    /**
    * When true a blur filter is applied to the final effect bitmap (can help when colorIntegrity == true).
    */
    public var blur:Boolean = false;
    /**
    * Selects rendering method; when set to true colors won't be distorted and performance will be
    * a little worse. Also, this might make the final output appear grainier.
    */
    public var colorIntegrity:Boolean = false;
    /**
    * Light intensity.
    */
    public var intensity:Number = 5;
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
    public var scale:Number = 4;
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

import flash.display.*;
import flash.events.*;
import flash.geom.*;

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


import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Loader;
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.media.SoundMixer;
import flash.media.SoundTransform;
import flash.net.URLRequest;
import flash.system.Security;
import flash.system.LoaderContext;
import flash.utils.ByteArray;
import net.hires.debug.Stats;
import flash.text.*

    
    /**
     * old school demo effects: http://iquilezles.org/www/articles/deform/deform.htm
     * @author Devon O.
     * @optimisation Hasufel
     */

class OldSkool extends Sprite {
    private static const _rect:Rectangle = new Rectangle(0,0,512,512);
    private const _xres:uint = 512;
    private const _yres:uint = 512;
    private var _input:BitmapData;
    private var _output:BitmapData;        
    private var _lookUpTable:Vector.<uint> = new Vector.<uint>();
    private var _inputVector:Vector.<uint> = new Vector.<uint>();
    private var _time:uint = 0;
    private var _effect:int = 0;
    private var _maxEffects:int = 51; //you should add more, your imagination is the limit!
    private var _outputVector:Vector.<uint> = new Vector.<uint>();
    private var _channel:SoundChannel = new SoundChannel;
    private var _mySound:Sound = new Sound();
    private var _echo:uint = 0;
        
    public function OldSkool() {
        if (stage) loadImage();
            else addEventListener(Event.ADDED_TO_STAGE, loadImage);
    }
        
        private function loadImage(event:Event = null):void {
            removeEventListener(Event.ADDED_TO_STAGE, loadImage);
            Security.loadPolicyFile("http://www.ventoline.com/crossdomain.xml");
            var l:Loader = new Loader();
            l.contentLoaderInfo.addEventListener(Event.COMPLETE, onImageLoad);
            l.load(new URLRequest("http://assets.wonderfl.net/images/related_images/0/04/0412/04127fadbec78e6eb08545f38a7a4f553223ddb5"), new LoaderContext(true));
        }
        
        private function onImageLoad(event:Event):void {
            var l:Loader = event.currentTarget.loader;
            _input = (l.content as Bitmap).bitmapData;
            _inputVector = _input.getVector(_rect);
            init();
        }
        
        private function init():void {
            _output = new BitmapData(_xres, _yres, true, 0x00FFFFFF);
            var bmp:Bitmap = new Bitmap(_output);
            bmp.width = bmp.height = stage.stageHeight;
            addChild(bmp);
            addChild(new Stats());
            createLUT();
            addEventListener(Event.ENTER_FRAME, frameHandler);
            loadSound();
        }

        private function loadSound():void {
            _mySound.addEventListener(Event.COMPLETE, playSound);
            _mySound.load(new URLRequest("http://www.ventoline.com/music.mp3"));
        }

        private function playSound(e:Event):void {
            _channel = new SoundChannel();
            _channel = _mySound.play(0,999);
        }
        
        private function changeEffect():void {
            if (++_effect > _maxEffects) _effect = 0;
            if (_effect == 12) {_effect = 31};
            createLUT();
        }
        
        private function frameHandler(e:Event):void {
            renderDeformation();
            computeDaSound();
            _time += 5 + _echo;
            if (_echo>0){_echo--};
        }

        private function computeDaSound():void {
            var bytes:ByteArray = new ByteArray();
            SoundMixer.computeSpectrum(bytes, false, 0);
            bytes.position = 0;
            var rf:Number;
            var count:uint = 0;
            for (var q:uint = 0; q<256; ++q) {
                rf = bytes.readFloat();
                var t:Number = Math.abs(rf);
                if (t >= 0.4 ) {
                    count++;
                }
                if (count > 10 && count < 70) {_echo=count/2;}
            }
            if (count >= 100 && count<160) {changeEffect();}
        }
         
        private function renderDeformation():void {
            for(var j:uint=0; j < _yres; ++j) {
                for (var i:uint = 0; i < _xres; ++i) {            
                    var o:uint = ((j<<9) + i)>>0;
                    var u:uint = _lookUpTable[(o<<1)>>0] + _time;
                    var v:uint = _lookUpTable[((o<<1)+1)>>0] + _time;
                _outputVector[((j<<9) + i)>>0] = _inputVector[(((v & 511) <<9) + (u & 511))>>0];
                }
            }
            _output.lock();
            _output.setVector(_rect, _outputVector);
            _output.unlock();
        }                 
        
        private function createLUT():void {
            var k:uint = 0;
            for (var j:int = 0; j < _yres; ++j) {
                for (var i:int = 0; i < _xres; ++i) {
                    var xx:Number = -1.0 + 2.0 * i / _xres;
                    var yy:Number = -1.0 + 2.0 * j / _yres;
                    var d:Number = Math.sqrt(xx * xx + yy * yy);
                    var a:Number = Math.atan2(yy, xx);
                    var r:Number = 1;
                    // MAGIC FORMULAS!
                    var u:Number;
                    var v:Number;
                    switch(_effect) {
                        case 0 :
                            u = Math.cos( a ) / d;
                            v = Math.sin( a ) / d ;
                            break;
                        case 1 :
                            u = xx * Math.cos(2 * r) - yy * Math.sin(2 * r);
                            v = yy * Math.cos(2 * r) + xx * Math.sin(2 * r);
                            break;
                        case 2 :
                            u = .2 / Math.abs(yy);
                            v = .2 * xx / Math.abs(yy);
                            break;
                        case 3 :
                            u = Math.pow(yy,2);
                            v = Math.pow(xx,2);

                        break;
                        case 4 :
                            u = Math.pow(yy,3);
                            v = Math.pow(xx,2);

                        break;
                        case 5 :
                            u = .2 * xx / Math.sin(yy);
                            v = .2 * xx / Math.sin(yy);

                        break;
                        case 6 :
                            u = .2 * xx / Math.sin(yy);
                            v = .2 * yy / Math.cos(xx);

                        break;
                        case 7 :
                            u = xx / Math.tan(yy) * d;
                            v = yy / Math.cos(yy) * d;

                        break;
                        case 8 :
                            u = r * xx / Math.tan(yy) * d * Math.sin(a);
                            v = yy / Math.cos(yy) * d * Math.tan(a);

                        break;
                        case 9 :
                            u = Math.pow(a,2);
                            v = Math.pow(d,2);

                        break;
                        case 10 :
                            u = Math.pow((a + xx),2);
                            v = Math.pow((3*a - yy),2);

                        break;
                        case 11 :
                            u = (a + xx) * Math.cos(d) - yy* Math.cos((a/xx + 1) * d);
                            v = (a + yy) * Math.sin(d) - xx* Math.sin((a/yy + 1) * d);
                        break;
                        case 31 :
                            u = Math.sqrt(d * Math.PI) * xx;
                            v = Math.sqrt(r * Math.PI) * yy;
                        break;
                        case 32 :
                            u = xx * (Math.cos(d) + r * Math.sin(d));
                            v = yy * (Math.sin(d) + r * Math.cos(d));
                        break;
                        case 33 :
                            u = r * (Math.cos(xx) + r * Math.sin(a));
                            v = r * (Math.sin(yy) + r * Math.cos(a));
                        break;
                        case 34 :
                            u = Math.pow((Math.pow(xx,2) + Math.pow(yy,2) - 2 * a * xx),2);
                            v = d * (Math.pow(xx,2) + Math.pow(yy,2));
                        break;
                        case 36 :
                            u = Math.sin(r) * Math.pow(yy,2) + d * yy;
                            v = Math.cos(r) * Math.pow(xx,2) + d * xx;
                        break;
                        case 37 :
                            u = Math.cos( a ) / d;
                            v = Math.sin( a ) / d * xx;
                        break;
                        case 38 :
                            u = Math.cos( a ) / d - yy;
                            v = Math.sin( a ) / d * xx;
                        break;
                        case 39 :
                            u = Math.cos( a ) / d - yy;
                            v = Math.sin( a ) / d - xx;
                        break;
                        case 40 :
                            u = Math.cos( a ) / d * Math.cos(a)*.2;
                            v = Math.sin( a ) / d * Math.sin(a)*.2;
                        break;
                        case 41 :
                            u = Math.cos( a ) / d * Math.tan(a)*.2;
                            v = Math.sin( a ) / d * Math.cos(a)*.2;
                        break;
                        case 42 :
                            u = .1 / yy;
                            v = .1 * xx / Math.abs(yy);
                        break;
                        case 43 :
                            u = Math.PI * .1 / Math.abs(yy) + Math.pow(d * Math.PI,2);
                            v = .1 * xx / Math.abs(yy);
                        break;
                        case 44 :
                            u = .1 / (Math.abs(yy) + Math.pow(d * Math.PI,2));
                            v = .1 * xx / Math.abs(yy);
                        break;
                        case 45 :
                            u = Math.cos( a ) / d;
                            v = 10 * yy / Math.pow(Math.abs(d) * Math.PI, xx * yy * d);
                        break;
                        case 46 :
                            u = 10 * a / Math.PI;
                            v = .1 * yy / (Math.abs(d) * Math.PI,xx * yy * d);
                        break;
                        case 47 :
                            u = 50 * Math.pow(d, Math.PI);
                            v = 50 * Math.pow(d, Math.PI);
                        break;
                        case 48 :
                            u = 500 * Math.pow(d, Math.PI);
                            v = 50 * Math.pow(d, Math.PI);
                        break;
                        case 49 :
                            u = 500 * Math.pow(d, Math.PI);
                            v = 50 * Math.pow(r, Math.PI);
                        break;
                        case 50 :
                            u = 500 * Math.pow(d, Math.PI);
                            v = Math.sin( r ) * a;
                        break;
                        default :
                            u = xx / (yy);
                            v = 1 / (yy);
                    }
                    _lookUpTable[(k++)>>0] = (512.0 * u)>>0 & 511;
                    _lookUpTable[(k++)>>0] = (512.0 * v)>>0 & 511;
                }
            }
        }
}
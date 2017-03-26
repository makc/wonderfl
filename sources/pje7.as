// forked from yonatan's CMLMovieClipTexture
package {
    import flash.display.*;
    import flash.events.*;
    import flash.filters.*;
    import flash.geom.*;
    import flash.net.*;
    import flash.system.*;

    [SWF(width="465", height="465", frameRate="24", backgroundColor="0xc0c0c0")]
    public class FlashTest extends Sprite {
        private var horses:Array = [];
        private var frameCnt:int = 0;
        public static const FOCUS:Number = 300;
        public static const MAX_Z:Number = 4000;
        public static const MIN_Z:Number = 20;
        public static const NUM_HORSES:int = 40;
        private var occ:Sprite = new Sprite;
        private var vol:VolumetricPointLight;
        

        public function FlashTest() {
            var url:String = "http://assets.wonderfl.net/images/related_images/d/d5/d5ef/d5efb19c4e6af524be0c935a932a653b475d2200";
            var loader:Loader = new Loader;
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoad);
            loader.load(new URLRequest(url), new LoaderContext(true));
        }

        private function onLoad(e:Event):void {
            var bmd:BitmapData = Bitmap(e.target.content).bitmapData;
            var vmargin:int = 10;
            var hmargin:int = 40;
            var w:int = bmd.width / 4 - hmargin*2;
            var h:int = bmd.height / 3 - vmargin*2;
            var rect:Rectangle = new Rectangle(0, 0, w, h);
            var frame:BitmapData;
            
            for(var y:int=0; y<3; y++) {
                for(var x:int=0; x<4; x++) {
                    frame = new BitmapData(w, h, true, 0);
                    rect.x = x*bmd.width/4+hmargin;
                    rect.y = y*bmd.height/3+vmargin;
                    frame.copyPixels(bmd, rect, frame.rect.topLeft);
                    Horse.animation.push(frame);
                }
            }
            Horse.animation.pop(); // lose last frame
            for each(frame in Horse.animation) createAlpha(frame);

            for(var i:int=0; i<NUM_HORSES; i++) {
                var horse:Horse = new Horse;
                var z:Number = MAX_Z - (MAX_Z-MIN_Z)/NUM_HORSES*i;
                horse.scaleX = horse.scaleY = 1/(z/FOCUS);
                horse.y = 210-50/(z/FOCUS);
                horse.x = Math.random()*465;
                horse.frame = Math.random() * Horse.animation.length*2;
                horses.push(horse);
                var blury:Number = Math.abs(z - (MIN_Z + MAX_Z)*0.3) / 1000;
                var blurx:Number = blury * horse.scaleX * 8;
                horse.filters = [new BlurFilter(blurx, blury)];
                if(i<NUM_HORSES-3) {
                    occ.addChild(horse);
                } else {
                    addChild(horse);
                }
            }

            occ.graphics.beginGradientFill("linear",[14731661,16365684,15116397,13341025,10843990],[0,1,1,1,1],[115,121,142,177,255],new Matrix(0.0000,0.2838,-0.2838,0.0000,232.5400,232.5400),"reflect","rgb",0);
            occ.graphics.drawRect(0, 0, 465, 465);
            occ.graphics.endFill();
            vol = new VolumetricPointLight(465, 465, occ, [0xc0b0a0, 0x6080ff, 0x6080ff], [1, 0, 1], [0, 1, 2]);
            vol.srcX = 100;
            vol.srcY = 200;
            vol.scale = 4;
            vol.intensity = 0.5;
            vol.colorIntegrity = true;
            vol.startRendering();
            addChildAt(vol, 0);
            addEventListener("enterFrame", onEnterFrame);
        }

        private function createAlpha(bmd:BitmapData):void {
            for(var x:int=0; x<bmd.width; x++) {
                for(var y:int=0; y<bmd.height; y++) {
                    var c:uint = bmd.getPixel(x, y);
                    var match:Number = (
                        Math.abs(0xb0 - (c & 0xff)) + 
                        Math.abs(0xb0 - ((c >> 8) & 0xff)) + 
                        Math.abs(0xb0 - ((c >> 16) & 0xff)));
                    match /= (3*0xb0);
                    match += 0.3;
                    match = Math.min(1, Math.pow(match, 5));
                    bmd.setPixel32(x, y, c | ((match*0xff) << 24));
                }
            }
        }

        private var bmp:Bitmap = new Bitmap;
        private function onEnterFrame(e:Event):void {
            for each(var horse:Horse in horses) horse.update();
        }
    }
}

import flash.display.*;

class Horse extends Bitmap {
    public static var animation:Array = [];
    public var frame:int;

    public function update():void {
        bitmapData = animation[frame>>1];
        x += 0.5*(width * (0.15 + (0.6+0.4*Math.cos(frame/22*Math.PI+1.6))*0.1));
        if(x > 465) x = -465 - width;
        if(++frame == 22) frame = 0;
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
    public var intensity:Number = 4;
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
    * transform are ignored, if you want to use filters or a color transform put your content in
    * another object and addChild it to this one instead.
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
        if(!(_lightBmp.visible = intensity > 0)) return;
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
    * bitmaps and its mtx argument.
    *
    * @param src The BitmapData to apply the effect on.
    * @param buffer Another BitmapData object for temporary storage. Must be the same size as src.
    * @param mtx Effect matrix.
    * @param passes Number of passes to make.
    * @return A processed BitmapData object (supplied in either src or buffer) with final effect output.
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

    /** @inheritDoc */
    override public function dispose():void {
        super.dispose();
        if(_gradientLoResBmd) _gradientLoResBmd.dispose();
        _gradientLoResBmd = null;
    }
}

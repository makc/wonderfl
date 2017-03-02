//Rolling in the Deep
//@Hasufel 2011
//greetz to yonatan for his volumetric trick, devon_o for getting lookup running
//and to all of you!
//go wonderfl!


package {
    import flash.display.*;
    import flash.events.*;
    import flash.text.TextField;

    [SWF(width="465", height="465", backgroundColor="0xffffff", frameRate="30")]
    public class RollingInTheDeep extends Sprite {
        private var fx:VolumetricPointLight;
        private var oldskool:OldSkool = new OldSkool;
        private var _t:Number = 0;
        private var _halfWidth:uint;
        private var _halfHeight:uint;
        private var eff:uint;
        private var _loadMessage:TextField;
        
        public function RollingInTheDeep():void{
            addEventListener(Event.ADDED_TO_STAGE, init);
            if(null != stage) init();
        }

        private function init(e:Event = null):void {
            removeEventListener(Event.ADDED_TO_STAGE, init);
            Wonderfl.capture_delay(20);
            stage.quality = "medium";
            stage.align = "TL";
            stage.scaleMode = "noScale";
            _loadMessage = new TextField();
            _loadMessage.width = 465;
            _loadMessage.text = "Please wait. Rolling in the Deep is loading…";
            addChild(_loadMessage);
            fx = new VolumetricPointLight(465, 465, oldskool,[0x2c1400,0x020009,0x000400,0x000400]);
            fx.visible = false;
            addChild(fx);
            fx.startRendering();
            eff = oldskool._effect;
            stage.addEventListener(Event.RESIZE, onResize);
            stage.dispatchEvent(new Event(Event.RESIZE));
            this.mouseEnabled = false;
            this.mouseChildren = false;
            addEventListener(Event.ENTER_FRAME, waitForLoad);
        }

        private function waitForLoad(e:Event):void {
            if (oldskool._loadok){
                removeChild(_loadMessage);
                _loadMessage = null;
                fx.visible = true;
                removeEventListener(Event.ENTER_FRAME, waitForLoad);
                addEventListener(Event.ENTER_FRAME, onEnterFrame);    
            } 
        }
        
        private function onEnterFrame(e:Event):void {
            _t += .01 * Math.random();
            var px:Number = _halfWidth * (1 + Math.cos(4*_t));
            var py:Number = _halfHeight * (1 + Math.sin(4*_t));
            if (eff != oldskool._effect) {
                eff = oldskool._effect;
                if (oldskool._count>60){
                    fx.intensity+=oldskool._count*.1;
                    var dec:Number=Math.random()*50;
                    px*=dec;
                    py*=dec;
                }
            }
            fx.intensity = fx.intensity>12?fx.intensity-=8:12;
            fx.srcX = px;
            fx.srcY = py;
            oldskool.frameHandler();
        }

        private function onResize(e:Event):void {
            var w:int = stage.stageWidth;
            var h:int = stage.stageHeight;
            _halfWidth = w >> 1;
            _halfHeight = h >> 1;
            fx.setViewportSize(w,h);
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
    public var intensity:Number = 11;
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
    public var scale:Number = 2.2;
    /**
    * Smooth scaling of the effect's final output bitmap.
    */
    public var smoothing:Boolean = false;
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
    protected var _halve:ColorTransform = new ColorTransform(.5, .5, .5);
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

    public function EffectContainer(width:uint, height:uint, emission:DisplayObject, occlusion:DisplayObject = null) {
        if(!emission) throw(new Error("emission DisplayObject must not be null."));
        addChild(_emission = emission);
        if(occlusion) addChild(_occlusion = occlusion);
        setViewportSize(width, height);
        _lightBmp.blendMode = BlendMode.ADD;
        addChild(_lightBmp);
        srcX = width /2;
        srcY = height /2;
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
        _bufferHeight = Math.max(1, Math.sqrt(_bufferSize / aspect));
        _bufferWidth  = Math.max(1, _bufferHeight * aspect);
        dispose();
        _baseBmd           = new BitmapData(_bufferWidth, _bufferHeight, false, 0);
        _bufferBmd         = new BitmapData(_bufferWidth, _bufferHeight, false, 0);
        _occlusionLoResBmd = new BitmapData(_bufferWidth, _bufferHeight, true, 0);
        _occlusionLoResBmp = new Bitmap(_occlusionLoResBmd);
    }

    public function render(e:Event = null):void {
        var savedQuality:String = stage.quality;
        if(rasterQuality) stage.quality = rasterQuality;
        var mul:Number = colorIntegrity ? intensity : intensity/(1<<passes);
        _ct.redMultiplier = _ct.greenMultiplier = _ct.blueMultiplier = mul;
        _drawLoResEmission();
        if(_occlusion) _eraseLoResOcclusion();
        if(rasterQuality) stage.quality = savedQuality;
        var s:Number = 1 + (scale-1) / (1<<passes);
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

    protected function _drawLoResEmission():void {
        _copyMatrix(_emission.transform.matrix, _mtx);
        _mtx.scale(_bufferWidth / _viewportWidth, _bufferHeight / _viewportHeight);
        _baseBmd.lock();
        _baseBmd.fillRect(_baseBmd.rect, 0);
        _baseBmd.draw(_emission, _mtx, colorIntegrity ? null : _ct);
        _baseBmd.unlock();
    }

    protected function _eraseLoResOcclusion():void {
        _occlusionLoResBmd.lock();
        _occlusionLoResBmd.fillRect(_occlusionLoResBmd.rect, 0);
        _copyMatrix(_occlusion.transform.matrix, _mtx);
        _mtx.scale(_bufferWidth / _viewportWidth, _bufferHeight / _viewportHeight);
        _occlusionLoResBmd.draw(_occlusion, _mtx);
        _occlusionLoResBmd.unlock();
        _baseBmd.lock();
        _baseBmd.draw(_occlusionLoResBmp, null, null, BlendMode.ERASE);
        _baseBmd.unlock();
    }

    public function startRendering():void {
        addEventListener(Event.ENTER_FRAME, render);
    }

    public function stopRendering():void {
        removeEventListener(Event.ENTER_FRAME, render);
    }

    protected function _applyEffect(src:BitmapData, buffer:BitmapData, mtx:Matrix, passes:uint):BitmapData {
        var tmp:BitmapData;
        while(passes--) {
            if(colorIntegrity) src.colorTransform(src.rect, _halve);
            buffer.lock();
            buffer.copyPixels(src, src.rect, src.rect.topLeft);
            buffer.draw(src, mtx, null, BlendMode.ADD, null, true);
            buffer.unlock();
            mtx.concat(mtx);
            tmp = src; src = buffer; buffer = tmp;
        }
        src.lock();
        if(colorIntegrity) src.colorTransform(src.rect, _ct);
        if(blur) src.applyFilter(src, src.rect, src.rect.topLeft, _blurFilter);
        src.unlock();
        return src;
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
    public var _colors:Array;
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
        var size:Number = 2 * Math.sqrt(_viewportWidth*_viewportWidth + _viewportHeight*_viewportHeight);//
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
            _gradientLoResBmd.lock();
            _gradientLoResBmd.copyPixels(_baseBmd, _baseBmd.rect, _baseBmd.rect.topLeft);
            _gradientLoResBmd.unlock();
            _gradientLoResDirty = false;
        } else {
            _baseBmd.lock();
            _baseBmd.copyPixels(_gradientLoResBmd, _baseBmd.rect, _baseBmd.rect.topLeft);
            _baseBmd.unlock();
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
import flash.geom.Rectangle;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.media.SoundMixer;
import flash.media.SoundTransform;
import flash.net.URLRequest;
import flash.system.Security;
import flash.system.LoaderContext;
import flash.utils.ByteArray;

final class OldSkool extends Sprite {
    private static const _rect:Rectangle = new Rectangle(0,0,512,512);
    private const _xres:uint = 512;
    private const _yres:uint = 512;
    private var _loader:Loader;
    private var _input:BitmapData;
    private var _output:BitmapData;
    private var _blurMap:BitmapData;    
    private var _lookUpTable:Array = [];
    private var _lookUpTableH:Vector.<uint>;
    private var _inputVector:Array = [];
    private var _time:uint = 0;
    private var _maxEffects:int = 29;
    private var _outputVector:Vector.<uint> = new Vector.<uint>();
    private var _channel:SoundChannel = new SoundChannel;
    private var _mySound:Sound = new Sound();
    private var _echo:uint = 0;
    private var _spd:int = 5;
    private var _current:uint = 0;
    private var _pt:Point = new Point(0,0);
    private var _blur:BlurFilter = new BlurFilter(2,2,1);
    public var _effect:int = 0;
    public var _count:uint = 0;
    public var _loadok:uint = 0;
        
    final public function OldSkool() {
        if (stage) prepareAsset();
            else addEventListener(Event.ADDED_TO_STAGE, prepareAsset);
        }

        private function prepareAsset(event:Event = null):void{
            removeEventListener(Event.ADDED_TO_STAGE, prepareAsset);
            var gfx:Gfx = new Gfx;
            var data1:Vector.<String>=Vector.<String>(gfx._data.split(''));
            var data2:Vector.<String>=new Vector.<String>;
            var bytes:ByteArray = new ByteArray();
            var d1l:uint = data1.length;
            var j:int = -1;
            for (var i:uint=0;i<d1l;i+=2){
                data2[(data2.length)>>0] = '0x'+data1[i>>0]+data1[(i+1)>>0];
                bytes[(++j)>>0] = data2[j>>0];
            }
            _loader = new Loader();
            _loader.contentLoaderInfo.addEventListener(Event.COMPLETE,assetLoaded);
            _loader.loadBytes(bytes);
        }
        private function assetLoaded(event:Event):void { 
            var t:BitmapData = new BitmapData(_loader.content.width,_loader.content.height,true,0x00FFFFFF);
            t.draw(_loader.content);
            var spa:uint = 101;
            var tmp:BitmapData = new BitmapData(_xres,_yres,true,0x00FFFFFF);
            for (var i:uint=0;i<12;++i) {
                var r:Rectangle = new Rectangle(i*spa,0,spa,spa);
                tmp.copyPixels(t,r,new Point(tmp.width>>1 - spa>>1,tmp.height>>1 - spa>>1),null,null,true);
                _inputVector[i] = tmp.getVector(_rect);
            }
            t.dispose();
            t = null;
            tmp.dispose();
            tmp = null;
            _loader = null;
            init();
        }
        
        private function init():void {
            _blurMap = new BitmapData(_xres, _yres, true, 0x00ffffff);
            addChild(new Bitmap(_blurMap)) as Bitmap;
            _output = new BitmapData(_xres, _yres, true, 0x00FFFFFF);
            var bmp:Bitmap = new Bitmap(_output);
            bmp.width = bmp.height = stage.stageHeight;
            addChild(bmp);
            for (var i:uint=0;i<_maxEffects;++i){
                _effect = i;
                createLUT();
            }
            _effect=0;
            _lookUpTableH = _lookUpTable[_effect>>0];
            loadSound();
        }

        private function loadSound():void {
            _mySound.addEventListener(Event.COMPLETE, playSound);
            Security.loadPolicyFile("http://www.ventoline.com/crossdomain.xml");
            _mySound.load(new URLRequest("http://www.ventoline.com/music2.mp3"));
        }

        private function playSound(e:Event):void {
            _channel = new SoundChannel();
            _channel = _mySound.play(0,999);
            _loadok = 1;
        }
        
        private function changeEffect():void {
            _spd = Math.random() * 20;
            if (++_effect == _maxEffects) _effect = 0;
            _lookUpTableH = _lookUpTable[_effect];
        }
        
        public function frameHandler():void{
            renderDeformation();
            computeDaSound();
            _time += _spd + _echo;
            if (_echo>0){_echo--};
        }

        private function computeDaSound():void {
            var bytes:ByteArray = new ByteArray();
            SoundMixer.computeSpectrum(bytes, false, 0);
            bytes.position = 0;
            var rf:Number;
            _count = 0;
            for (var q:uint = 0; q<256; ++q) {
                rf = bytes.readFloat();
                var t:Number = Math.abs(rf);
                if (t >= .25) {
                    _count++;
                }
                if (_count > 10 && _count < 160) {_echo=_count/3;}
            }
            if (_count >= 160 && _count<256) {changeEffect();}
            _blurMap.lock();
            _blurMap.applyFilter(_output, _rect, _pt, _blur);
            _blurMap.unlock();
        }
         
        private function renderDeformation():void {
            var j:uint,i:uint,o:uint,u:uint,v:uint;
            _current %= 12;
            for(j=0; j < _yres; ++j) {
                for (i=0; i < _xres; ++i) {            
                    o = ((j<<9) + i)>>0;
                    u = _lookUpTableH[(o<<1)>>0]+_time;
                    v = _lookUpTableH[((o<<1)+1)>>0]+_time;
                    _outputVector[o>>0] = (_inputVector[_current>>0][(((v & 511) <<9) + (u & 511))>>0]>>0);
                }
            }
            _output.lock();
            _output.setVector(_rect, _outputVector);
            _output.unlock();
            _current++;
        }                 
        
        private function createLUT():void {
            var l:Vector.<uint> = new Vector.<uint>();
            var k:uint = 0;
            for (var j:int = 0; j < _yres; ++j) {
                for (var i:int = 0; i < _xres; ++i) {
                    var xx:Number = -1.0 + 2.0 * i / _xres;
                    var yy:Number = -1.0 + 2.0 * j / _yres;
                    var d:Number = Math.sqrt(xx * xx + yy * yy);
                    var a:Number = Math.atan2(yy, xx);
                    var r:Number = 1;
                    var u:Number;
                    var v:Number;
                    switch(_effect) {
                        case 0 :
                            u = Math.cos( a ) / d;
                            v = Math.sin( a ) / d ;
                            break;
                        case 1 :
                           u = .2 / Math.abs(yy);
                            v = .2 * xx / Math.abs(yy);
                            break;
                        case 2 :
                            u = .6 / Math.abs(yy);
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
                        case 12 :
                            u = Math.sqrt(d * Math.PI) * xx;
                            v = Math.sqrt(r * Math.PI) * yy;
                            break;
                        case 13 :
                            u = xx * (Math.cos(d) + r * Math.sin(d));
                            v = yy * (Math.sin(d) + r * Math.cos(d));
                            break;
                        case 14 :
                            u = r * (Math.cos(xx) + r * Math.sin(a));
                            v = r * (Math.sin(yy) + r * Math.cos(a));
                            break;
                        case 15 :
                            u = Math.pow((Math.pow(xx,2) + Math.pow(yy,2) - 2 * a * xx),2);
                            v = d * (Math.pow(xx,2) + Math.pow(yy,2));
                            break;
                        case 16 :
                            u = Math.sin(r) * Math.pow(yy,2) + d * yy;
                            v = Math.cos(r) * Math.pow(xx,2) + d * xx;
                            break;
                        case 17 :
                            u = Math.cos( a ) / d;
                            v = Math.sin( a ) / d * xx;
                            break;
                        case 18 :
                            u = Math.cos( a ) / d - yy;
                            v = Math.sin( a ) / d * xx;
                            break;
                        case 19 :
                            u = Math.cos( a ) / d - yy;
                            v = Math.sin( a ) / d - xx;
                            break;
                        case 20 :
                            u = Math.cos( a ) / d * Math.cos(a)*.2;
                            v = Math.sin( a ) / d * Math.sin(a)*.2;
                            break;
                        case 21 :
                            u = Math.cos( a ) / d * Math.tan(a)*.2;
                            v = Math.sin( a ) / d * Math.cos(a)*.2;
                            break;
                        case 22 :
                            u = .1 / yy;
                            v = .1 * xx / Math.abs(yy);
                            break;
                        case 23 :
                            u = Math.PI * .1 / Math.abs(yy) + Math.pow(d * Math.PI,2);
                            v = .1 * xx / Math.abs(yy);
                            break;
                        case 24 :
                            u = .1 / (Math.abs(yy) + Math.pow(d * Math.PI,2));
                            v = .1 * xx / Math.abs(yy);
                            break;
                        case 25 :
                            u = Math.cos( a ) / d;
                            v = 10 * yy / Math.pow(Math.abs(d) * Math.PI, xx * yy * d);
                            break;
                        case 26 :
                            u = 10 * a / Math.PI;
                            v = .1 * yy / (Math.abs(d) * Math.PI,xx * yy * d);
                            break;
                        case 27 :
                            u = 50 * Math.pow(d, Math.PI);
                            v = 50 * Math.pow(d, Math.PI);
                            break;
                        case 28 :
                            u = 500 * Math.pow(d, Math.PI);
                            v = 50 * Math.pow(d, Math.PI);
                            break;
                        case 29 :
                            u = 500 * Math.pow(d, Math.PI);
                            v = 50 * Math.pow(r, Math.PI);
                            break;
                        case 30 :
                            u = 500 * Math.pow(d, Math.PI);
                            v = Math.sin( r ) * a;
                            break;
                        default :
                            u = xx / (yy);
                            v = 1 / (yy);
                    }
                    l[(k++)>>0] = (512.0 * u)>>0 & 511;
                    l[(k++)>>0] = (512.0 * v)>>0 & 511;
                }
                _lookUpTable[_effect] = l;
            }
        }
}


final class Gfx {
    public const _data:String = "89504e470d0a1a0a0000000d49484452000004bc000000650803000000707f0afc0000001974455874536f66747761726500"+
"41646f626520496d616765526561647971c9653c000000b4504c54450002000306010a0c081a1c191214110c0f0b1e201e22"+
"24210f110e17191714151330322f474946373936292b282627253f403e2b2d2a2729262d2f2c5c5e5b4d4f4c6566643d3e3c"+
"50514f3234313536345354523a3c39151715555754585a57696b6845464460625f4244411c1e1c4a4c492325226d6f6c7274"+
"71414240393a387b7c797678758d8f8c7f817e9c9e9b939592a6a8a5848683888a87b9bbb8afb1aecccecbc2c4c1d6d8d5df"+
"e1def0f2efffffffaaa946fd0000003c74524e53ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff"+
"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00bb88eba70000a6174944415478dab49d0777dbb8"+
"b2800980bd779154a3ba6cd9967b927dffff7fbd2980ec244e36b9c9e69cbd9bbd7134e27cc0340c86d6fffdc62f615942ce"+
"2321f137fff71ffd82cf2e94845fffa510bb8727212176ecfd57422c8b85441bf19faa0b84eccaff9ac97c11fec74c44be91"+
"cc444e66ff95904033519dff5f33e937ff3513d965ff35936c6a331391eefe2b21a560267e9cfdde9358bff873db3c0e24ee"+
"464bf6200b7f674ffae0ef3ec5dc91160a91a91024a498d8a0b6bfcc43a010670f0250c8c4c567fa0f84c8344475819078ce"+
"8a13f2ef0af1cb5e3013b152cc44f489fb778548c14c44ac984910abff8809886026e520fe1b2642353e33890acde42f0b91"+
"ee66e330933e6226d63e29feae903e709849343013b9a9fcff8689854f8142c295fc6f9858fe6acf4cd446fc1e935f315eb8"+
"ae84f01733d4970a723b40287decb089f94b618a1364931c5c227cb4bfb27d14922c94c41df9d784449b998dac6193c442a1"+
"10af56165a6521bdea2f6d7b52170a89530b8504ad0dcf1448912565e088bf2944248a98d8cb8c98ece3eddf549725ed60ef"+
"096222e29c98946befef32090b5732132ba98949d87acc44cc4bf5979924a34be0d72e31b1c264f0ecbfcac4ead71e318967"+
"c4444daabfba4fa465ab55c54ca28e98b875ff779954793c93cca41c8989a823cdc457e15f325c864979288949336126b29a"+
"a54afe0de3153a16eebdf9dedb361841585645ff6baf94dae29f8030e78f17b016727d8890b7559208114356874244d02759"+
"f9378488793e8dbc39eacc231909e611b6f292c4958ef8f327b91aac5de4a0ba40484122fc9c1e66bbccc3bfa4aee0c224a8"+
"24c958d1bf64bcfffb4c8a4e1193202149b9cd4c203ceecbfd5f1122bd894b4cc48e2465053171d3a4b06d5ffa7f2a447956"+
"04cfc04c868c9716fdefbc69d4df52976f98cccb09692a52f4afc9b0fdeb4cb26ec1c057f41851a69908b7f84b4c2c359dee"+
"89496ed3769f1093edb6ea5d15da7fcc6416e5f12692ccc49d11f7587242b7f47e515dff62bcd29915279e93953e7ede0e4d"+
"afb32247b9a1fcce75a54a7bebcf1ca47008010a111bf488d6d6734048b46533b99b7a244cfc15215ecccb37f5a52365cc22"+
"26a9eb9202ff8210a1d6235b461f322de91464ed9ddc4175fd05219854e5bd2a8989955265adc180d2a2758642a41b257fc6"+
"042cb961627924c86f9089cbdec5992c221bd23029ff0a937966f37edf0313b162252549f6d798587edcd8da232213c50e65"+
"a2fe12938082add062267d864caeb6f8c191279889b0cba10cffd63e71afe84b4f9189c3c652461d7860693bcedf1152b247"+
"dc26c864c6da4b37d5df6322f33116daf702139f5d5754885f65f253e365cb2dadda7613d267cd8e7d94bab99b56d138d093"+
"d94387f1258434fff32a8e92853599154949df57ec207689a2c873d3fe1065f0d95e620b7e18fb7fcfb8253d892848489438"+
"e960c5a5ebb99b850542bc015dcc5f142213f025321d1669ea7ad3eb0a9e88dc0a08f142b78c12f77fb62c0e0991791d6782"+
"562c3c41ead65e5a59f586dd71318d43f8b3f07f8f59aaa18b453e89535e5be9004c8a169854871e99ccafddbfcc24502130"+
"99ad81c9d0229370e6fc5d26f059182e0e75074c36313049635b33910025f1823f14d26fd8cccbe23403268b0a983453cdbd"+
"eb3cd8a1a1b4ffe7f8d1c5e067df679ac91a98a4c4649c21133914f22fa8cb7a63e2c70a98f4233029c60898c899fabb4cac"+
"60a590c96e0d4ca22530c97297f5051ed8f6a2adfd3f1a2f61290c7c3df0b532ca2118ae9c943e1913f90cf6bf670f7850b0"+
"a732d5ff7878e34914228a26df5458aa9d440d5a659493da9693e64b7e983f125246dd349fcc1a7625a25c8e3e3a4af491f0"+
"ff38d3a5c786332d5c570dbdfa9f16d83b75c1afb09e56106a41526a91658ca3018504514216c1b765f8874284b7d92313b4"+
"53d680da899089ac22ff0fd5a50409d9e7fdd5b58d4c2a4a4eb140b17581493225a3f667422a6462e5f5d467260dd5b927cc"+
"dd72e29637a9c83c7beb56952dff9c899ce6c0444ce03ff081c42a2126b24cbac111220cfc3f6562d9ae2a8089832936ee71"+
"394326623f400cfe47eaf2998937b896a27d520d585b495066814c628a26fe4c88ade87b3783de279b83d23214ec42677660"+
"670642a43fcf3cf9179888e51839ccddc3aad46c434cc47658e4ca97ca0de7ff83f19242a03d17d79cb957c74ee8074191b8"+
"59c4669d71d285cf2402f1fbb6f82b21f3d91a2b10821360def4f35e25948209957bae97f5e1ef6bacf0ec5462181f45f9c4"+
"13e9465976a28d708f9b45597310e2a751112578a4e2dac16f3b615f45f52a9fe42d8307215166bdfd4223399fc43d66127f"+
"495d9655b458f910ca7ad397351b8bbfc844c8a85d2aed4c226d249d64af99847d18a86deafcbe9048c91285cc3c37c92389"+
"4c789909666265c444b855345b01733f0bd46f339997d7eb186cd47145061e84909442920c51d818424e7afc221775c93f64"+
"922e2a92e5e323403086ab211a93bfb94fc416f6357e2c6cfa149f053f75a898099832291ddbfb1f8428db08f15d2b900530"+
"119856ede159d0d284952026761a5d755e68abcafd7d268e72771077957521f43e09d0a6b801b3f7e0c1e6491f4573f10b4c"+
"ac1faa2bc8bdb2ec6baad63a7166c9648e5e0a040017e41d49cb9d708d6de32935cf9cdfb5f7d272d07d3857b4e19db88a50"+
"49b28208058c7d08be1e81b813954555e6e5d868947aea370f05edf74244fab8440fef44985153d57e1f92211e29ba90f4bf"+
"78e2f17b4292aa00bb27ec9d9b25f975d5a0e152296fc882f95b5e554d38af33427e575d62df4549b2391458e1422622c223"+
"269b0e515c0c58225b33015c81e34857fe2993b244732c803d44d9b6d2553677626f0b51143bd7b6e795a7b6bfb984bf12a2"+
"4e75a00d300810a9b1f8b371b0dfabeb376b3949e6e27ef0377658cc26b385712628a0e040d25251f2874cfca11ef2abe634"+
"f31c6662911583f505db33440750a90b93080fe8d51f33c942da9560815d88ee41a48f0f0a42ecac12fd2275b7ee2cddaa3f"+
"11628f64770578441480fa22fd45e3f556bea94bfc669252ca3065219894f41bfc4c895eb77a63624757f9af31f9d878d951"+
"d2d585a78a755a2533d18c541c7033b16d9b55bdda8149f38891b3988922f5b6abad1daa044cb1fc1d6d817185f833ad033c"+
"02501d16392a1714368d9793d53853983908a74cd68a0f55e859600b85bf2724a3ee0bb2f4204494905759f6d5249ee6ebdd"+
"0c8f1b65594a4967816f427e6781c1f2fc4ac898f714bd17db49bddab4ab1d3a1774925a881c6c58c4bf292498c9b8c3487a"+
"1ab84532eb4e01ef4470c49b55bb8ad790ed91f395cd5058855776a5eb7a13b9b57f8f4918055e3a3994ca119a490956326d"+
"e2ba41269cc57bc948699d519708ff8889e546886198c4232492b3c84511a9fd1d93df789228fc5a487d2df654c8f1268755"+
"3eae62c81e7dcc50df84c0d6f94d26ee64c873745ab1f4b7d5f5f491a39f506c970b60b26ac1c850f948ae8a0ca044cb4a79"+
"595efd56c70c3cfc364fa364774ad2ad238889853d84e53a5e2c56e3441177a19231926fea9252cdff8809d7ef763930992e"+
"67056a4f15caf986c9efc4aae53742161e0911bd3719636072b5c14ab17acfe4a79bf143e3354b7c329092ebffc1d2ab28d8"+
"8a4ed736eac9f38723da49d7ca942e7a52a3890285fdb2bdb7edac3b5ccda2e488e95ad23df57462e637f500f1043828a75b"+
"7a42615624375f09b17edd07db682031c15986782e1370f95495d1549f39ba71537a54816421420cf07324e497a928167251"+
"170a090b4f94f5d28768742ea2be63354977ccada250fb65eaa5322f7fa36ff5ba125f0959846504099b559d263e7eb66b0f"+
"8708d553965913be5397e3fffae980adfae9785d7965eb6ef71530495835cd7a5042da62eb34b567cdb19cf32d935ff7c1c4"+
"4448df1bf72a40634c4ce6e9309d8594a1aa5d93b9de1b9377e07f595de1f74c844c4b592e12c7f66159019315fbc4a0c52a"+
"9888d6bd10e5e0fe46ea9878e21b21dba8002b9c8e8983fb44cd7bca1861c7564b757912482a02f1cb4cc274365da7ca0ea6"+
"be13ba55f3342be9ac6ed30da984dde13af11a8cc07eeffc219342865e72ea8bd20d3deec4800c6e9ae359f956045db3577b"+
"f9474cec0ff689086d512e6a5b86960f4c9a2baeaafb4b5a79fd3a11e916fcd0c7423e325e60ef24161e44c3d15b4df6dc05"+
"432f5df02a20d052325f7814bb4a3e4693031dabc2dffc4585459ba1bcfe4a88843ccbf3572bf8fa4a409e0249e2b266257e"+
"2be457bd23649e5e7b15af564f9b28ead3cd3d980eac77ae6aef528e72973926616e161dfbb4506a5847227523297e5d8856"+
"57473729ecb5c3dfb96dc14d5ac21760623c70d0cadabbcebb2781ade2baee2f9e08a61f31b182b28d25e460581d145b994f"+
"3d577ec4e4174b13b3ab547d23c4cfac6cbe5a6da9f5194b477251fb7fc644cafe18af72d8279e9795935b60022997582d29"+
"d0d671d215fe7eee4547aaae266d957a41f63be0595d72e9ce959a6f5bfece628dbfc1eb0fe0cebdab1ca3df7d60efcc93e0"+
"d154e9fd6afae0591f31b1cbb6e1433b88198049e379f6474c7ed17a5d4d94ff8d10e996968a5736ed13ba1d34adc33f6412"+
"6c6e5693a81c3d1b52a8e829b7ac720e4c626a91c2fc47a87a458990aa8e119558d71968cafd6d26d21ea3324db3e21870c9"+
"be862f8d07c178f4e46d7201f151e6aa4e0a9d524a7b56b81fa60fd607b5548b4f64aca424d08b8a57d426a6863edbb22998"+
"cb67245aec375c3da04886dacb7ec17c292cd85c84c0af86ff652dd63e1ef273012414b3dca666af550b396c21e2e91e1e83"+
"0dcf2f9c6b04d9243ea08ade09118eebad6105ccf11a820389be10ddc275715fba337d920a0fad62ca9b7e41c81c2b662ada"+
"c477639ff47d7fb744b67bd56c2097a22e6289e663d1f139c44508ab4b04de2f6c152f7863029fe787eb6b87e06e287a80df"+
"fa2027541bcdc49d585f33b17ec17cb958a1fd88498769fb9cbfbe3d17b38943c963dcd29fc79d3797e29799a8fe2aa75dfe"+
"5e0824bcebdac15c484a708d73211a608200de98405cb0cb70e9fd2293a6cae3f8b48ed2ccf38e5d8501843bdde003a01460"+
"2282c58294f80d132121ecfb85239a0b93eb42dacaf50e2b15e2e76d36dccc0d4ce061543cb33e028f71cdafe4a5f6c74c76"+
"b5f2b5a597f65cce6632c4e4316e31232a563156627e9909b8d6a8f94e880f4cf0321584ac021e4c88ddc2b55c60cd4f2254"+
"2a4337ddd1fd885f6222640d48ae0e9d1b8476d8aebc14beacb7a446db1074e5c0b3cac5c2f9405dc287f4e8df8d17455909"+
"84a06a73bfb2f2591a3f556909a0923b0c2c74b882d728d100879eb71f13d72bac6a8d6564c925917f4d7e4b9b84609f0235"+
"599637aee7b9db203d50072c374262927d70756b21bbcec491aa1c36feaf08914957ca3721d8bec01b3068257d80a41d0eb6"+
"78197e2d84fb6fa5cafefde2086623d5dda20fa4ffb51075c28e67ae1be0253159bbbe1ddab6dfcd49ac1602ffccfd7f1782"+
"4c7c318fbafb389ff5e9e4ce735d2f0426a1454c1c07b5c64cc03e6f0f78645b654b748cbfc824d5e0595dc20992c7342dc1"+
"bb46378e654222b0f6963aeec53b7589d95cb945742d7ea55c24f35d203e6622b81199e1cb8f9978b6eb39bfc0c40e2677b0"+
"abbe15a28ec4442f3188f6968aaf82efecf7e0f1cacaaf32f1d37c71bf49aa3d0424c15c6d5d3bb973494d104ad06d1afb40"+
"818a951d279655ecf78dad85fc42b9a8506f4cf0624eb6b90d309df287932d84cd171b7d629292de485df0ff6e3caf28523a"+
"f8fc5775f9ab8dfc219390ac17c197ce874c52e56de52f3099a7f1e9daf95ec8b8bd2c2e8117ac967341bfbede8cf0a75be7"+
"df8c97c09f53d3ab6615d57c3cb3ead95e5de5885c4867e2e0bfe063aff90fb28157c6c44dabacf2e94bfcfc49b62824a4b0"+
"7e3ddd887c168d8dede02a6a3a9b9f23a23b9ac28e63b6645a4848ddeafb2c53f6bf0999e7891662ad68a9d8ed9a9751bdd4"+
"c74e916ecae8489f999b6fc49b10ac19b8ea5fa808996caefae42244ab0bccc862a1ef4c4792b7e52e761cc70e8318bbca8a"+
"ac48b41058e9f2df84c04767ed6e97a8c6fd8e095dc89ff93e6dfbaf99082f2eab824a15ffcac4354c44785cc79b49b4afb1"+
"148dab68e74bc304efb83aab5c58df3211559485febf829f15ef9908df3db6fc596bc3a4d7feb14126a1ab8699f53593ec5f"+
"9938f1aaf7fa6f980869070c1e166faf2f9b774d18ce03e5366b30f5a572a33726cebf3311c94d937b32fe9e09de3493c347"+
"4cc0d54dabcaf3dddf62e2a48f6d9c475ed8256c48362b49f6d6c72909b802f289f51d13793d78f25f8578bdf78e092426d5"+
"69e4cf5ad78c440e9ac97401ae7e1bf8d5f035139906ff2244d8d32b577dcd04beb7ad94667299f700e06d7bee7aaa5b5b45"+
"baf583eac74cac6f0d646aa9d57d82f65b9bc636a48a90756c2c2ae0c81c148251d1a6b55cfc507fc7cf38a17b10d33d5e8d"+
"123f3f7448e926937bd534b77382d16a9bdeeef4a3503b1c2cd56841e1b0485a79116289d292dbeae79d2c854b42e863da6c"+
"b6d9ccaa936eb19d46929b2e4b92ed8b942f0909770467556c9d5c0b013efe4f17b10c47f06e2484d525d42d3c4101b6b5ee"+
"2dde20a5b690f9542713f48852b549a52409b17f5ef30426a2689ea877ef8d89c480fa089fe5f8b0767bc72713094cb668fe"+
"df984036594e95f837262e33b1fba6c94ff2021ebfe9f89e09a410225906b873b26a29de3311b697fe0b93f08dc94db25ae5"+
"d1f6c0850fc3043e060ffd605f3313e114c7caaaf6f6053cf8eaf0e7eaf246d77ac744d8e97d6345e9d6960b304e0e7a60c3"+
"64d2883726322c0fc3deb77e91893d696e7ceb3d13540031b1255e9d2a6c4e8036ed16b7c97b26d28d3a2c5fff9cc99c98ec"+
"b2559317a378cfc43f68264e2938a49851a575ef65dd574ca4f2bc9f0b29fc0b93f069156f06d7d742ac69cf01a92cc962c2"+
"33c764cb82e8a6aa4a484cdf98a8f9cfd555b4fefb7d22bde4bc1315d61ba638b502777aa993e064f7b64f40a3d1215220fe"+
"4326d637fd37fba8494a32ac7b5e3dea7e6355e827e28d7e145b57a466e86282ccea6ff80f2a3abbdfceb759f0d30e5fc7f2"+
"e0bb26a76eb0b510d8205204e094ddc546c7c13a37b5a67cfb49386d5a45a52db4101f55fab3a4ae92781f520dd8dd7a7c4a"+
"250ba1c3a5fdb8d6d99c909410d9d37acb97ada6e8c7c2728d535f480858eb9f241076dff92484d4e5549bd5ac38f18ab596"+
"6b5854be1497838149b705f3284908ab4bccd36a860720ffa2aef46a97b9ef98c8f2bc194ab451f16a4e21b78311373a2764"+
"e2bba5158d2c99d5e5ba99e7ff3b13b97b5c4152f2c644e229b3ea3658bdd14c50da74c3bf0f8f11987a69bd31f18b9f2510"+
"bdd04c9ca8399ca888464c308a19f1708052792a170839ad95344cc02746ebdc179666f2b37b4ff3e44a5e9834ee24be8ad4"+
"41ea723d3171f4a38002f385b03c309f1726caf1226aa5f937264393dbea1d133b79d844745a02b902694bff134a60028bce"+
"4a8bb57cdb27629f964afe3b93a07eec1deb8d891362dba0bddbe056beec13481e72ed7f4f7d9481a62e4c84aa7ec664d04c"+
"84bbea5a0e10789ff87b62c2fe8af260094c426198e09de6ba17bfc4440dc38549b6ece33871fd9566d2ae0184edf0540c64"+
"b25a52fbda1b135715919b3113f963e3252def5808bedd6dad524b56ababe44e9f9aae9e6c6b7ed98aa1e59f26da9aadd308"+
"b9a9825d27241ec34f9aae25f62645d347a585d0ee3aaf7a3abbcc9ee0af071699feb998db721d093eacc1960fe9454d43c7"+
"2b1415c91f9bfb5850af63bc5f4dafed988540c8e847d8fbecf1bd69d098e3f3d9d6d60af7a52b4808b52e0655b49524048c"+
"d90f992476aa2fc30bf578cab17d5e627f9d70d3ac1fe51ccc93e42f0a7b04e33e21b6e97074f8448d264aa9ae74e804f7c7"+
"ea8af092866122d4249ea5477d616ef5e4603f2fa510d2b6adf03461a325c75e16a1756122e4b697d64f99d89be6e0bf3111"+
"d5c3aa20439cde6234247861e323ae13d856829988b018e27791aa1dfe5048c24cbaebe9ce132bc3c451bd80bcd63b648a82"+
"087350576f85b2b2f08dc975d6a7b661f2c33321379286898c6e8fdc798c4c646679c528d55c04926c8a63f9de116371676f"+
"f5a31682ea92d9024cf84f99881cf7b96102db64652ca4f0568f92da7b98093cc969a6bdfd4d1291a530fbc4df173f052f0a"+
"afc997f28d893d79d8f04db6e836a37c91ea51a8b736b1b642ef13e9f5fd6c786312fcd8cb67cca46ea6906c192687b0ec71"+
"0c87772835133ad3b4c21aeb3d004b33115e1cf52e4745a0ae1fe628fbd2301190d5b5dca4804cecc2724b6012c23e2126d2"+
"b2bd03d6c082b230b65ed18c91686a5bdf31f9ca78d933fc0ba2a1bf3476cd06db0a0e78065414b698d6d95b1c21bce94ef8"+
"199e5efb53ba3b300c7c531ffbfe4511fc505f96d5275d2a59c8328007ba5af53764aefc225b3481c21e65ec547081090699"+
"619a3abeb6c3761381996321a165ff983cde941c1ee846f992fbb7d543c7e9c2fe34bddca9a143e85171406312263c9b1641"+
"b5b049c80f9f24a21b0da0ae70b398f167a0badc845cf7789002ed159e685bca5e757b9a8d61f96dd467783ed8b3baa45bfa"+
"e18fcf6bd455270c13715a37d45e834cec2885a07bedb1bfa207f0ba9d980baae84e61657b4344dd28cc4446e14f98cce238"+
"148609588c38df1f435e3bdea28175b0e5714e5bf8fe0b6c84137b6198a8f5903a1a3cacc39f32b17767ba18b2d42db60f0d"+
"ad6591de74c27f8becc5f4404e3e2c26873726328b68b0c94fd495692622ed9afd3ad04c549160f02d8ec44481e1020fa9fc"+
"d574cfe30becc380bbf5c2242c5df913215e9e5f98c8db11c35566e246600da6ada7773366c0de6e2754463dcba02ebb184a"+
"d55f98f883f31326f1749017265690c77d7808f9ac524db1fab945cf15c05ab65bcc19bc541926a21c07f8569ac98f5b6590"+
"89c896f773ebc2445ebfc49c87a4c74670a5859a64c4829c9b70abebb5304c609b5413f173267cf3477476be98d84bc3643f"+
"502b97b81971609cc2e35f58bb72b5cc943ef14a52c7ba30895cb029df0879ff1f651e62c5d24d70314d1f74397b5da919e9"+
"a03f4e95d9f32ad88df48df655e8ad74c47a1c7001b834714806fe8f1279ef2e15240403f92c6fd08caf2b0c2bf19ce7b175"+
"b019805670df4cb72537992d0e7a83e610bdf4654a4284f8a110118961c1b1b458e3116c12f723d5feb24acafa14e88364cf"+
"0a0e53891547fc8f654501a0e48a749a143eb608fc20be2b4008fea5f562a74808f1bc672be657aa5ed2756919e289e41a82"+
"25e1e1b53a54975f41e0cc42405d629bfcf03e529f48c3c4cf17f7ba6ab78eca1975a52487a96b3c8a1bee46ea014c0bc94c"+
"84886e287a6226ce8f1a98e6d6700a2dc3a4bd6e62f4e2c8643f80629cc7b5e30a5b0678621e35538fe759a4d3b565983869"+
"af3c66f2238f024c7a3f6e66d78689a5362bafa56a7f9182864ea1de2a9e50e3540a626c656d5f39966122921cacf58f9964"+
"c44454374bd8f786897b6ef974b90a6b9aa93717e895657bc0fa3f3a3450975043643b1726721ffd50c8ac304c84d7758f3a"+
"1d5927fd75404cc6297c47977a3b3d7f77dcd38dc352e87d62cf6e08193109e63fca1ee66285669b995887a6a3f34060222a"+
"cc23edc7daf1206001a306cfb59b969c4c54ddf4b24f545f38ae6632ff3193fd749626977d52ec66f69aaafdd11e628793ad"+
"99b8c26da73248f9e6ee61e02540365c6ef2f9cf9878bc4ff2a70656956622a233970addc2afd791a58008550dc611ebffd4"+
"09bf12b24c32290d1308c7b2af85bc335ed56015083977e504d89bb25d7da6ae8f10f2dbf87e83f53fcb73f3a72b41375be1"+
"53ef381fb79c89f492bda01e7c8837c20f0d8b2d27f4c134f942a4cfbabb2ea9dd9c7663efe4a73a2804ec943ca7243ca343"+
"cf78d263df2808a11a7bde3874a9efe3d3668844aa6451083d5ea39dab5d8ccd1ea02fef1a7594acc6d69519440f5ebddee0"+
"295a18c1c3e0e8d32df86816026985f43248c63e4e8161d183ba4475bfa444969eca8dafafa848dcc38a750ee32a17185607"+
"f561669303c82287935808a00f3c680a1fdbe97f50bb1d52c364db75ae3035f4c3992ca40b6eb3b9dd9438c93a53f9ed44f0"+
"7530919ef4e19393dbd5306721c2161fef14db8e3b5f33114efecce99095acab097a5c3b92f9dd3228202714937c6c415b29"+
"89dfc509ad615217e4b034c5f7274cfaa60b2cc344451d9e82031351614544269b7154d20326e5621d535f373e0ca84ba6c9"+
"565c98f8a92b7fc4242326ceeafe8a2c1daa4bf4bb74464562bc746f8fc8c483a834588fb3a064cb29639e8a96c66b716112"+
"243f98473cdb6a26d9b09c48b34fec9b7be2599610363e6d2a4829ac545dddce045d3c046370a38f239d2b17d698d04c64f0"+
"b1badc38374c2cb77bd17f3769936bc9017bfe34052610b10013f8da6099f9e07c082cc3c449f38137e3c75e1eab7ef5445e"+
"98a4ab06bb6080894cf04bdb7d3e1e9849315d53f75786a736a02ebbef7dcb30c9b685fd43261e3171178f956598d89b5825"+
"945325e8c3da319e805f74dca06d676a4fcaf204ef9370b89a5e980877f8eac2f99bf152139e4c61d5d3254ebaa179866089"+
"232a0c44d8df39f8c9635b3fd6eddde0635c86872b965a66d7e44a8219265b4344ad4610307f742864a5714042f0fd07439d"+
"b4bad33d7b260b8811b5c893e56dbdbe5b1f62879a199cc106219869435e1ef0c9b94c522ac4581fb519409ae6df62a353c7"+
"8d488f377c2fd6392634eb5026c282b8e870b77c6c1735281defe55b5eef2df58cb2b8d1a72cb0a0f7099e857c70eaaf505d"+
"fbe56cc942961e0086afeb80babc09cd5712ce626c1febfa6931e028a6884e0756b71c0e5841d3e3bd63c94d9ab6fa4888db"+
"6b2687165b9198899cc454ac11d75bb4f686c969b051f334b548d5514262505d321b0894a0bb7b1fa86bd848c3c4de2dbcb5"+
"66923c93aef705a612497d0b22d6c78d83f7e6ad00b25764122660930d93159d0bfd90897beb5986893cdf700aef1c577410"+
"8431bf375ddedc2c1fd7d8a84cb10dd815b5e4c87b36cb0d13cbc6e6c68fd485f7a02762b2f4768689cc3b6c110275555804"+
"7222cba9dbf669a999486acc90cda33e6551f5351ddf1193ad0a3f12e215cc443c8dd4cf434ce6f12c442612ebc04ee5244f"+
"c8e4701ce658b189303853ed8c4b45a82ebbafe69966f251eb87b549846622d2e5c65f7abac3eaa5e2e11b60877b647238ac"+
"4f3387ae54e335745097f0c0ba6a26c29e56bef51326c3937f61b27d19d90e3b3753de30f0dd8b6679371213c7a27349d9bb"+
"cc44564931bbec1337f33ede27384a7a6277b1d31926aad938b44fc47541f7c22c67bd6626d855c25d527677234d0b00cd3a"+
"67269eebbc1362bd3b77805d8da1e033e78b3bf8a0720adf2b1925df67424f1909994b0c03e962849f483985e5eb4ee0f333"+
"eea2522d0daec28cfe833211c48214a32efd610d366377cdf7e49309964ca90d1a8d4521fd6b8137f3f9a2433a2c0af65e49"+
"d2eb162dcb2994faf8aeae12e592ae4fa19245553fe63abd399d1d8adb510a3c9c723cc5690675c2f94f5333f0a71de8c88b"+
"1e28fdf80622c8967107410a5b3cab6997112736479a2941e7c803581847620252d159169ea10c094f03c94095d5e0b31088"+
"fd3fcae92a66325f3c28c3444e9a39310970f4204a1195901362e2e027ab5e20135124f00ccc44a4141e2093f0a39bac9666"+
"a29a85b23413b72baf914982c6f01adb916538101387ec4a9f4ee939ec595144a66d4e55fe0fee4f2b30b98401d52557cb83"+
"ee3bb7ef6e517fd461055f0232b70a72b6823d0c7ce5db954e8a37077d139c0079c2fa0193e51294a6992c4e53be51989ca6"+
"188f38d7f8c52d317370f5e21d61f0c734e76bc6437b415d01de61d04c3eccb34b6202cbea962ddeee5ad8cd95242619b50b"+
"cda8bbc099119370cf83ad9109c733ccc44f6a73b5f90326785a464ceaa8c6d2363181947d0e42c0bd634499e02019e9a610"+
"b9c20a219b9b6c8989f026aa344c6499c91f31f177c3b561b25dc4b56e48f31ee990aed0b3af06c781d018231f9f3ed4bbbd"+
"d6fb647a985b86894413f03113ff389d5b86497bcb233345f24437cc15eef28298802cac4b49dc8d72dacc7cb34fca6b6519"+
"26e1bb98e862bcb09b2a73ad74ddeb2a7f51ab052d20b1bcc17b55022ffebb5c6e0bb0798e1e2e5f73f7463909f3addefa2a"+
"0a2dc7ffa883582d4808b92dd24051638b36bed265b99013742fa5a2894b420ff9218462f9a8c31579d3f1a363b014a049fe"+
"be074fec27494942607960ab65c1cd76651780108b2600e34c0c8cf22a1e8983738bc42a76275c33ceb7ce802769149139e1"+
"f683e64bbc0f33bd512c04e393a77b5d7b4acf74ea8147c1196b2b842fb30f28a50021c29ad33826549790d14029bd83937d"+
"bff3c0213181adaef41dcf62ddb30f068d50663401fe7c266861c9c9a5c072c3fd2572e8a561322b41a71f33f162cd449e5b"+
"d7d24cfc06ade272e1d09b8fb0df077b08231e86c55da9ad3e86b6823beeed4575092f0a3f6492c65ea699c8bcce2c662266"+
"b1042622439784893b60c75d82f9a29ce125d4b8d223e472d79d60099a99283ceefc808918b1d2c04cc4e4f1ce0cd7b9279b"+
"89df531f5ea2b6a89636286292a1268989a5922c314cbebf2764139360b99186c918371c54d4f7d4a08c9b13c33cad2d7c89"+
"1420df712bd5c4138649dcc3f32093efa3a274a699a8e7a96398b80b1c31b05c0494d6636c94d0212a0ddba2435a79bcd166"+
"253d69270feaf28b8c34fb9dba869d6f98cc178d2f9889dc0dc8c41af6c6ab83650bf991700e9e5835d77a6a51beafa82394"+
"98c067890f99d8a7461826e1f4e6a077f2ee09dbb829424cc8cf93b6687227982d60227a8a06689fa449d06b26d2b5be355e"+
"d7363ce0444d63a97723e84dffc6da9c11bd475537b31a709762d612df0dfacb5c6903034e4dec4b07877f7d7bcb31c321eb"+
"133c5f5f3e70e9df39daee32e37bcce7cce4ea937752c2018434ce35b7fbcb46cdc8c9f45c95c4ebdbdf5009838567f19cb1"+
"da5be05c56e7882ba4c1906ebd28a93273a525247a7a2738b3b841ef49e77268abc3d99e8588b915aa6fd187b62de393af2d"+
"a408173b75e415bcba76d6b01de9c0464b1124850e614f1d572c6652365acd23759fa2babead4831936a0d4982d928afb171"+
"7a843e424ba6fbdd490a25a2bb277d2c1cee8efa627b2f9d4ac98f98140333b18af6d6d74cc264c143300e0f814ee6494b89"+
"96e2a502988439df77945d9107966132dfc80f98b8b5af99acaf5b5c86c844e04c146492d08cc3191347672f66dc46814c7c"+
"32f5a82e91cd42c30412ed0f98d88bb5344c8a75e43313679a811049c30c847e0e4c4b3931bb1e89849c4164d4e84659ca9f"+
"88c9b715a90199e4f1726ebc9658bd46baabb23e21135ce3f8c9d883400137d510a6b77a64d97eb7364c848a7c12f26de747"+
"943213192f75f2044956a347fbdf9df1a1d23d6b099fc3a9786a1830f172fde18b09b5c5f3c5712f171f304921d16026e3a2"+
"5696de2711a20775c51831061113770afd51612291c93677988990e0e50d130939ddf74cca696398c0f3040e3371a7213209"+
"5774e6cad4c30c0b14a4d39ac2a510d03313085aa9090dd5e55c9818e345cd1a072a414de93583d1fa66a33b092ab9185d3b"+
"d611f1db8da389132c62e9f1e45351755cf7c398dff22bbab7f08d212e50c84a88d9da5de8339afa566f62598f23986e3a0a"+
"3726926a905ebc405753a218515d63501cb010085602f59d10812b8f408b7bdd53bfd85819cfbb93372f589fc3d92b2425a7"+
"31657422c59359803e0ae12e166ed3a53b13df08b14a7feab12199cec515de5c5ea0baec254e8b598c2d2e063a019a682998"+
"b2048b76a30f99f34eab52466eef0b6aaaf8f6fa0332114f74519598c8ddb46526fe4221137aeb8aaaf46627f3b891c8a42f"+
"74d2c0ad9da42ee11699f53d933d33f1178d9c6a26e3593ba4a05e0313d9980546b790693668824c4442a5345097ec61ab68"+
"2699177e177a51df230d25b05f5a9dd26d44ce51b47c3a239395d471366aabc2af92ddd3b807d10f423391fd64a699e0a0bf"+
"6f9978533d296a1a844bfcbbc4a45ca0ef5a1ce88024d1191749c116a260610ae9ee55aef32648ef526ad5f99e09bed8ca3f"+
"53a19ad4a5d693e546f70e496442aa4f69209996227310123b3967fe2239eaa1d4681052cfa3c2d737090a33c9da486826e2"+
"f1ac0ffa8be91298f82bbd70317710e4be26293291d8de444cecc95e18265526bf031fe2e104a92b7dd62e71b19153decdce"+
"fd2d86b968eeb1799cd61791ef6f636e9df32ccd249871d900f7890abe63326c846152b498352313919335599c46a14355db"+
"4829b060b7d483d144940c9a89b3a23c8b2e95395f1b2fc74a211c39d362daa5384f27968a3ae79d257c29393bc102132231"+
"132fa9a72278a26f1350b3acec6c781a0c04f9340d47507c43a5a286b8c6ae6107ef38f2f4eecebac56019cad94d1717d81a"+
"536aec48c5cf6ff9c643b0f25108e54391cb4284f0b7df786049cbbba17575ab7da23ad5fa1e88bb98dc747332c4f660a216"+
"d8baf93ad9691fb7a93a9da37a756a86b47ce3b7a4954f6d8bcbfabbb825e0a8ae82c6b40a793a77381981ba2e301e4267d3"+
"a739c4504ac749fe9d36daa02eb05f825f19eb7c7b55cb593c0ac3a46c0b8b99601c034c1ecf385298b49fd3dd1052e81a99"+
"94949483ba9c0906aac44438f88ea16f98a47405a5497142043311939b27568007d10a3059a283184c7f32660efee67cc5af"+
"a8835dcc4c8289ab34132b08be7903aa9347cc440ceda1d04c1e0fda680c2b1032f73077f0d08f6cc8f702f8f5d54a37926d"+
"b68649446e812e81bbdf32c16c9999742d67c0a02e4a0a91c9d31330913b1ad569c8e75b6452e96512dc4e846112f4f68f98"+
"b835dffd03754188100a663234d87d31bbc5fb6eb4e9e9c88146c146076422ae4b8e536df72ab0cc3e5114627c9dccf3f5b9"+
"698c469799388bf549df1d8f0532c17e22ebca387a549b1f3f709107abe0c4449433c73011aeff0df879523013399d2e751a"+
"a8ce476d61e308995043c4106a2672824c3a3d41bdbab63513b1599b571c58d9b74cdaded24cea3bf655a02eb9647367dfde"+
"0193101394ccd352ac38442613dd1494ddebef16a4a22ca46622bf325e96f46437e31164d1ceaa5a0c1a9b252cc4356e1021"+
"ebc3cd32355d89d42eebedd6353749f831ec253a949d43825a708d340b3cf14d5d82df9578a2f02edad163d77e4317e4c275"+
"084282f5a73a75c4cab1b44f88a31dc40e57813ecd72731d12a8313277557016fa5771bdebd16565316b55a4af49850f4fcc"+
"645b4b197437e76b605fe023f6d8819bdfad734738ba43401ef53d32ab70ddc13737eabf6eed75b145886f481e1ff4b498a6"+
"8e29b9c7cbda2064d95ce199d0351725a5d73dac684e06c55ea0ae80e7b6d3e000975e8ff6bdbae6b56b6b26b221c388eaaa"+
"9674635a8e6b6012520f2b6f786432728dc803eb424c440aa98166927ac1b742243211f714de91bafcfa4a101391a218191c"+
"5f96c0848c3fe1ee326062eb9721a995af99888a67a4d15c6aef6b2149c84c1c08ef0c93e2e5a82b653b64727ac011c97467"+
"03f7a4ec4664a2740ceedf2df4ba2bf614141193af1bc7ad7e2d3413fbf6d65cef6eeb81776f5320134cc1ad7dcaa727d25b"+
"3ce4c8a4e2bc274f0a7dca8665e3c22d3f64524d1da999f018436422e2155d62b70f0b60e2aea8a907bfc93532b9e3347e88"+
"2c66226760cc9889ec4be75b210299f82ff4d9a4aeb2cd2c6672856264f07846261df5ded3057310926f75fc54cd243311fe"+
"8c2ff223133cddfa8a89434c84d746966622e2f35abfc26b4026770ff87a02fa540a94d63530b18ca9771fcd594a11515044"+
"4cbe4eb3c5a6b13493e2fea87fbcb9a1267b342a0a991cc939a2899ce1ed80f61e9988dce37d329950a709a92bec439a1b6d"+
"cc303f906f796a510a5e21f671ca2703f230f15a9b2ead0f9d54f9f8748e234fb5ca2df2dbd322722c3df45fc641aa67a50d"+
"3dcfc016d8c822bfba91925938736ef2e2f38c6c08aad638f6f530c1e11b7867433a75918fc7f61e8404cba2c81737f7d85f"+
"20745024c61b73c32ebea2c9753c27e5bd4b2914ce12170b09fb84846058dc96284408d5d2b8c0fe713caee343af02b559e6"+
"8bf5f24447c4216fc8b4a9f4234ca4707a2538e77eef1c7d7fc48951a82e7bbdd4edb356f87ca2c046a6352c6f75f57c5ac7"+
"51be0b941b3d2dd68b48979e6965a3bae4046f87e8b7002c10d857adaac0a458da86c9e3c8f13ca86b3295c4a4b94626e75b"+
"60e2d6c8e43c22133da846c592998830d723d4f175f7f838e27d0321a84b2ef8b001d5558e7b8b995435cdf9b05b17988cc4"+
"a4f580c9d32332b1f54eb18fad61b28c431e34048fe3be1712d9ccc4857da29988d5322426325ad2509af8884cee4a60b2d8"+
"00939aee888a8c93ebb4bbeaf58563696d07b61e42faefd5a5704822a9ab1867c6ff78af6b66b2598110b57a0621d1220126"+
"f90999e4bc80237a110ba80b5fc56598b81d2f31e72b269b586826e179dceab6bbcd622688c9da43262f2760524c91c9430b"+
"4ca48efba3446826e5c4374ca4677fcdc4052642ad4f966622e2da612668225159ee1a841c6f1e890908599c0fc8c4d39508"+
"efb030b71ec75c6a267890f74ec82089c97202518366e2af270eef935d4e4cea9a988010d50ec0a4e50aea8c4d715aeb1127"+
"a02e091e45ef13ff9d10bf683413b9ab3dc3247fdd913b91cb0a99742fc8a4cd8049d722130ee8c4c6d5fb04bdaf66228b0d"+
"5fb674de192f69cd6af8d905e7679ff43d790823ef6dd496ef1e946dfb7ebdda4c97f5cb72ba4b12ea4510a660351e6d530d"+
"bbd16fadc4ebb45fb5f3fb5684f355f8c345eb7a63c96164148c0a84d8763e0d7d5f4d9e40c8fa7cd8259ec39f6ff3dc586f"+
"b11bf4969989128f03a927c17eef81136a0d13877160217420eaa01021e6a30b42ecb0757d556d1eea7abd6c6f134f8a2d53"+
"775133ded41601bdf7905a2a445a72caf5bea8eac4949581bab23115ad9e5cdb36280496162acbb6d30508993e3dad415d4f"+
"781fc8d213b3bd95f0a636578ba43dd3c97d0a5ee2ab37984870b6d2d24c86575307749fef2431e9d7381dcc1f0760d21293"+
"86b4e3ec74ae35aecd116ddc0ac32454f6b74cfcba5a6826de86efac83baa2b54f4c163310a2ba1b64f2b006263667f1daac"+
"78eba50ef0ed9983be8c9928df7a7f8d8aaa3c4f234d234775499cca494cd2d64626ea100293d5030859de9d9049cf273403"+
"5d620075715084ea127e4f45215057f87e0252cf4cc46a6d1b26e5d83393618d48ec3c4726e71b60d23ce181a5d0232293c8"+
"6226322f2dc364822f9dfa86091dae93bae4f4d9bc2a247b6dc974f9cd0e99848708981ccfc884ae6f59ae3e82aaeaa56632"+
"9ff2901150977003e73d1309eacaead030a9f83c1fd4d537310ab1c3314326ed1a99bc2c8189e21f9965da78d58e61b29d61"+
"a9809864ef539492cf281fa8d24bea72713b129355e72093b2052155734626f72d30b156f6a52284ea92796199d6233792d9"+
"77fbc4e3f3c285b0214cd14cc46a913193264624e12245260f2330599e9089af67bc801866a256a1304c76a0cf0b138b2f9a"+
"ca27fc4294949687fa12a33f3d26a82d759c6d950a82d1c77de351c54117a2586bd97a6ddee8d827137a4b38b55346ef862c"+
"821207d9e5a2d3fddbb7a3ae4566b7670f84042abbdbab20f42709cd5dd9d3eae3ba08bd403d5b281171fcd1e3d0b1c42121"+
"3862cc7a1b5c406fe7f29e39b61d16f045695476764aec430542d4366f55081bb3a6dbc6fc18da0617338142b03ae8b21014"+
"db71e1ebad49d9cefd811b08af5b7c81fc8287aa952804c2ed630442946a0b102226f8122a8b135f5b674c65bb54ba0477b5"+
"d1decb13fb50bc6fc791227c929a8988d7ab85b98879bc2326de5d8a4cbc168763f81dfd5d2e2ee8694bd9a1758c4389e980"+
"05d5c543d72f5618bebd0de99e6692bf4c758c9b81db2226c9d14526531799d010482bd7afb1cf9889dcf096017589a21086"+
"c9db4e898889c8f50133a82b64d702eaf2c0d02393e50e84c800634a11f0cba0b559b9da5bccc4c56a023391fdcafa864998"+
"734b60172c112633195a9f9964371e32718f0a994cf1f527daef66ba1363325de872cf3024868993ca6f989427a199d8edd5"+
"b566e2b48b1331198e2e32493a64e2e6347281379dc69c3d2e4de1255f72df1abd6adb7bc704b6ef0019bb6622a67a2943b4"+
"066e8b98743532b15b9cbb23a6ef16b0a04187a0ae90fd24a84bf890d23113dbfe9689acf50133a82b1a03cd2407430f4cdc"+
"438f4c0a9aea5690990a57fac8df6626224177d9f3b4bc24e17df276c411cc68335ad382dec7474ce4b411cc04b62132298f"+
"b819654d59f7949d86cee79a8966e26fdcc130517b7161428f1388ddd2cc094bc6401ef4bb1a47bfbceb54b05d1e68a6e66c"+
"6de35d53be4c77c53f738da94f0f4b588f64f337c299615333fda71bbcf92dd04d8ed53e1e4626a6afa52901df9e5188571e"+
"9638b853ad5d5417a7d69a8d95972804e3c89cde6645075783a72de65b51953f336d6b7da1f490d57aa64e79f710abad97a5"+
"d52378aac0564b548260ffe6e932fad55aab4be6996d0e0693425f0dbe74756ab1bb964ecb515dc23da04b40758d5d9681ba"+
"86d3360075f1bde32cd17d315ce5795ce8252cb2c72d9feec0cea751d46fea925dac99c825ec066622ba8e8404eecd94984c"+
"6364a2a7b8eab7333798d382bad4ced14ca48bef9f2626a27c77c211d03c61c3c43ebc6ccddbc16e9f8849fa941393838d4c"+
"e280d36bfe99ce6626821c3031b1bc68ae57d95b4ac7a5b0b8db1926b343a9b7e3ed4b142093e1a94026d18a9ac1d96c99e6"+
"986ec74c2011b67dcdc48e3dfd1b2384ed2a78f9472a1591ba726ab8037579602591c96e44264e4d3312f49d18ddf89d9cf3"+
"cb1bd7ee74cb08683e93ef679106413c6126c21d2b4b33f1db8899648fd7c4049c2430f126ef16b0240f0aea8af499003089"+
"2a619854f2fd3e1135a67dcca438dd2a532a39d166f486db089978236e46c1cc537658101533133b0ecc3e9191e79be058be"+
"a5a6f880eb484f0694c7a599f25f9e5f5c62129f3264b2abe816006ba7619b684f8d59a966d230515df80d135d44b60e4f5b"+
"c344f2207c50577f2a8949db2862c211d1db14242cf03d147a9fc8468ffd0075cdbdcb7c588bae09ccf8ae46318198db0792"+
"94da55239876ef749a4dee274992f4d5210fb066c429afab1b29a6bebdc3cc16ac178abfc6ce9dc1c3b72e92d44b7f279df7"+
"262484fa5016573a3975c60185a451739e247d91793721382e916a97a5ad705b7327a0555e4912c20d46bac5c99cd0b25d2d"+
"d67631d1c03fe9af29e4e1f90e840cc9fa1184b8c1d0a05715dc03a8ff6577f766b8aac8e9cc825ef562a7ba3ca1ab903bd3"+
"b07fab7b856bb1a7411ea8ae87db028424c9b10621b69c1251bfb32e54405d76a20f1ec475c4710caa4b50cf8651978a5983"+
"c5c4c7fe0a660261a460268bc70499448f0532b1390648388f093b414c84e2560350979843fac04cc4db1c78fc4af75bc344"+
"8dc34c33f18e8a99b48fd7c82402e305ea62e36bb1b2acf9ba63267252598689ea4c086e98f05b9ae29dd04cacf5ab7e41b9"+
"b09fce2762721a89493710138e4e1c5ec2767d3616358c3bcfcc05f0f46748335e5ad71def0fbae9ad96abb5d44c3e1d5262"+
"72bb41264e4bc64be7bd6e4c317113ecf40d77315b71390ad525d93f6a7579baf85a4cca83676926fe186926372d31491e3d"+
"6492f254007e9393954e2cde27fd4c182625deb1a23f0e02f18e89ba97864932ce135d67b95afbcce411c480bae205316118"+
"52279945d730131fac9766228a8d6e12b8ec93926d5761997df2f8ece87de2dd3e1193d97d874c54bb4526766cbddbf4f6e1"+
"de5489d2ab8d61b22dc2af98d87a9147b79d6162b7396f46eff1f39498e4f73d325164bc2c1d7351ad00d49535a69e9a2fb9"+
"6c8f2f73b5bd405b2f325ed7d77c56e0af1bee4d6e07bc3a1e42f06f7bedc3eb7115c7ab3cbfafb618e215fa3dddfcaff4ae"+
"e65aaab35342700823a24c472be0802fbb115c1a09a9315e0517d10e3c0d6c45424edd79c477ca4493e31cb253e1c5fa0620"+
"b7a81dcdf533b05ea969cb1c123d87d3f428fbe86f4bb0bf7eadcbc9e7448fb2bd3aa420a459ed1e6a10926d3b0a872d1d30"+
"a638de32a9fbd01cc98bec4697884b296c1e6da185a43c745b4c6b3d5541b435da2e2cbeda93d7171012c7cdc3150809fd96"+
"4edc8db2861e85e08c71eebf0175498ce3040b18e4a543cac2379490ba0e23b73681ba204096cce4e5734d4c9adb1299045c"+
"119e37baab786426c2c56e2c620261fdbcd44b217c6322ba563381d8b1b03493e0b86726cb970531592c436432ab74dd9999"+
"dc1e4c5d785299d8556e7453b665422fbcdcb659ed846152dde8be6621d79d474c162f0d3271c78c8e5175b979e559c4a48c"+
"8d43e91f5dc3c4725df19e091f77cdc759ad7f76bce3037c50d7f2f98198d4e71932095a4a0675b46a358a9938fa8571f024"+
"6ae21826784bc930110b5b33793a703008ea72c64430934faf1d31698f085e46ac914a2fc065a799607aa5f7893748cd44cc"+
"2fe095c3ef6a4126796b1b26c9e83393c343434c8e3931611fc7752821af1f4c500fb19761223ae392ed774c767561692672"+
"ba3e6826f39b9e998ce71899602841c575fee385434c0673ec6f59f19d367b25ce0179cf2463267deb1926371cde82bac2d3"+
"99999c1eaf91493aa56430d317581792988011d083c37249efa32626c2eef5250efc076b83f4b7e48b19ca069e174f30a51f"+
"78d5e3974fe771396ddadbca5360edf524b246f10dad5bd30f6fef025be7da62e8846e653057811d3fdb6df4e40db9c6a232"+
"08c198674a42baf3e72f0710b249da350a11aad1eaf251486c0fb34b58ffa41d89ac6431a78736b50fbc6cb16e6d3d72c5b2"+
"c7647be4bea0e2ae44219fceb72f8b065f98d046e8b72c735772a95008f8166dec817dc2d300b00bd0661066702ef655c9e9"+
"4eea8ab8c8bfccf8ecd7779fa628645c3e9e5709a82b3cf81c0feb9162b7a37e8123f979529704ff28f9c6bd5297669c6da3"+
"af33849ff4d00e757421966026d1c32b33b93b1213a587ffd229b19ff06505b2f4e0193413275f6926e2c2c49e44666a9047"+
"b91c31f10f91c34cbebca290cdec6e434c06de880e986264123426ca129d39b091d5bce2cb5da6728b4c4e54375c73d353a0"+
"3493dda898c9cb3d82afb29322261d274ae1d4662666083c248b1b659858ae0ade9878c4246c4b330647b4af7cf159fac3ed"+
"8c999c4f1b64e2b1f132b716d2a79a35442d57cc444d7cc3c47b6302d11333e94dc9431dcb3617cc24797e6126e705311938"+
"9de2a0d84f8ef726fdcb23cb307127896e6590172661a30c9315552d515d223d06bc4f1efe79262693db8a98e8641c7d3d32"+
"f1a6c6c987cbda3089f699f89689e0bb4ca82eb15808cdc419e38099bcde1093fe447990515635a1cd6819b1f0248979bd35"+
"9524de3151c4246a7dc3c4797c713593e9292226f5f39a98cc3a62a233086b73d44cd803a0ba4465ae08c3fa0d9909182f1f"+
"cd1035bc35f7a67563787accc8a16cd3f8a53d3d7ffe743b9e8f03b879c7d1ae35dd3865536f02df9ccb5ac162e199236a2a"+
"4ae0203e4dc50f82a9e4168459bce603b1e1608b4deba39064b5fcfc8a42bacd53bcc517c4863a58d9ac51087e39d79c9d35"+
"ba6ee0420e5dd828443742db81b4ec33fddc6c82b66b4642f0714f090a999e9efff90c42ae86e26e4fb3e2321acbed948ff7"+
"2bb62f7dce6fa3f4c0c3608ce912547c0d80ee8dab703cf195dc41b033e3b286775c92107028e391847cfef4e5098494dbed"+
"d1215f0d3652a0ba6e8c63f4c1cf4baedcc8c475954ee802bd53fca9cf4cecf1608a31c9c3c9b198c9fa61c94c5e16c4c4d5"+
"c62b2e9949b63375e128de19260515258889ad99942b4b33a9751d0ad425db8d6426e3e74fc4243ef7c4a4d23978bd6226f6"+
"d4845ecd5a9b4b5789b090ef98f88114e5bd6f98d058586222a393cb4c3efdf34a4c86bb80986cf87c370563c3230be3bd61"+
"625f0517261e965bb9dc59e0a0c4ab39bef78b99589bf64a33d93e75cce4f5cb919844351baf69404cd6b7c62d66d8a1ce0b"+
"57cd1cc3c4b735137a5a54573176c6614f5e6ba1993c3e11f8dbd3734c4caef58dcfa5cd4c7213fec8556f4a76d6843b2770"+
"9ebdaf994c2ac14c2677fac405d4b53d7a9ac9d32b81ef16f72931d9e9d2e0d8131391ae8c987ab42f4c20cb66265233b136"+
"7c3515d425a9338af7c9a29e3393d77f3e1193dd21a4d21a9d920a277a1899893de58a013c494659b6cba31fe8c20099c888"+
"9854184a3013d9ae12cda4bf4d98c9e7cf233169e28b43412617ef8b96de3029226198040e3101e31574dc472b5675609a76"+
"ec97b3cd0ea5bfbf5db7c7c787d7cfff9cdb3872ed7074605daab47b693bbc132c22735150ea46107a070cde90c069948243"+
"55e93573ee44b3824f6607afc6fc1852249137f79f50c8ebf3fda72908013bd0a2907c797ce919a17edbb55c1522e25e629c"+
"6722d390def6c7425cc839f8fd4c4e2bfd316721b6906d4742eaf6fe0b0ab96dbbfb8c4a06de1a85acbbd9a55d09e7088110"+
"8af04bf3361b59600e4dcb8bdeaf9d4cd1643bf497d4b1102804d475753b4321c747b09120248ea2a34f6f5c4a4e5720a470"+
"e4c2a4a5ee6ebed2cde672a60b95a1e5d82c84ba36405d4e3bf3cd378b5eee3493d9cba126265ffeb92726592d8949fbb066"+
"263b137a3977eb4bd235ef7dcd8467aaca0c54ca4c8acfbadddd5a1d5a08da8949f77266260f9f62625274cce4e9ac2f8347"+
"bc41415d92cfd3505d22281d62e2682676bd324c529aaf444cd4296226e3cb2766d23eb9c464d63093ce1ccd512f37330973"+
"f0ba9a4974b9454939647e482cc36436fa9666d21e2366f2facf2b3189d792982cea9c98a84beb7572ed18266aa2038a5084"+
"9a493a1013b11f95612216e78366d23d2c99c93f5f6e89093684a1ba1e1f99895cf8c6c9df5e12e121c3f09e98f0641cd9c7"+
"baa9dd6a5ecd7d96d5e9aee7883b5fbede3193e7076612f7cce4e18e998003334ce87c5633d92bf91593b4b9d64c9c8ea32a"+
"54d7f5516926af0fcce4716426d388998cb939fba4be55525789893033b193cb2d4a854cba536098c835b87b66a21e1bcde4"+
"cb1766d25e1113ff903393c1786c4851a46602b15762980424c4c26ba0d8de5459d760e877893643f16e841fb055b67c59b7"+
"879bd3e9e6f6f3edfdfdedddf1e6f5d0b66ddd4d4ebaa22da7fa92751c553acbc6f7b616019586f5b453812d5a1e8d23983e"+
"18bf25dacf331232acd6afb728e4e6eefc05858cede1750421d7ae3335b909cd5f002158bd46e48a27e1d16d35f68dc213f9"+
"b5c78599dd46c777221e553c062864d11e5f1f50c8edfdc3974710d2b6c74f2d08c1c39d4a8bf1bb9084d0445c6fcbc713b6"+
"a3e49b100803b9568feab271cf80105097fbd4a01050d7a71714727f7b2665b5ede12577b92d7b757921c7e360364dbaa4da"+
"9d8d57bcd901471931914bf0a39a8977cc626652dedd2f98c9cb2766f2f4dc1293f8ce0c0bd3e1b013272b93e264c286ed4e"+
"4c780d0b3c9325758587bbc430797cf534939bd71333797e65268fcf2d31999b2bfba2f10c137fa52e4c14b5161b75c9c5d6"+
"30595e5ef938ba90403393bb2fb7cce4d3eb1d31797aae8989d0ef09b404c4449a8950b9af34131b6facbd3119b9851bd515"+
"1d03c364f6d43393bb2ff7cce4e57924268fe71931113b73ee2da707131e412ccabb118d31efc6ca232674935e3359b5be66"+
"129d8f9ac9eb99993c3c3093dabcfe23d2ef2d71e2589fdaa1ba3cb035c4846b84024ffd485dfdb8364ce4c38bd24ccecf47"+
"66f2f999993c9c9949614cb04d8923a92b23034cea1234b1fda22e7b293593e6ce18e2781c4e996672ffe58e997c7961260f"+
"f7cc245c8ab798c830a97a6198602bec1b1379c7df0ad4055185304cd6879499dc7eb96326af6766f27077cdef7c5f1a4b1f"+
"d6cbcb215ad3e817ad62273f1b2f1cae0aa1195da5f7476a6c9e2e85d8dca404e566d91e4f77a7e3c37937898a32ab9e4aaa"+
"a85b135d8ab03c4a5a54530891f49c08a1a52dec405c82228108658c4d6a6b35eabc5c1eee48489ac4f79f6e5048bbbcbb45"+
"217b0f0b20947115b141d8b924842ac47b1642974ee9cd3954eccce0ab485de97f6ecd336feecf1e0959b6b75f9e50c86eb2"+
"bc4321db7930ea01f0eaad7d613dbd1cd16e3af3e276a12e4284353f700d12d405769e0082bafc762c50c8f1f4f4e5098544"+
"457c978110ec2ad3fb509a1be9aa1b23f36089c2c922346f4b3b60b29972b79b0ac3c43e0c9666b27a5832939bd73b66b2b9"+
"718989589839dd39bf1612d4e5c4ca301141219809192fa715ccc469735b3311d9a9d64c9ae733816febf3c84caea9630217"+
"6361c68143ecc64c84daf81726897ac704e7853193f4b371a862f5fc643393f1e595c0efae4e6b6652b6fc162cebe27f45be"+
"6b0c13f72a374c60095f988868dd1826ded1334cd4639c3293f397133319eb3d31092ebdd866dfabfaa42e4c0ada33a42ebe"+
"026e1393055e13d04cfa63a8996cdbfb86993c7e6e99c9bade1213672dbf72f2a82e8fdf9d434c32d77ab74fe8bb80ba4476"+
"501726bb76a799d460df89c9faa561268b85cfcd68a6c265f557c230c14b1d9a89dcf8972bba56095b4933d97dbe142e9bcf"+
"add44c5e5f98497ebf6126ab86990873e06b395d6f9888bebf364c204e7d63d2acf405c2d18ff5bb0b415dc363c14cee9e3f"+
"d1668caaa79c9944666a4a62d0abe3f1f2a6eb9c6f3ca2baecd042e355d0cb8facf140c0733cd69ca0d6447f6ad4b63d1394"+
"d3cdf1f51427a91b3aa169a9712fdb3d4e21d0a2337279b5a74bf5141355e5a5975f14b4e2804c0f9978aecf4e21d9262169"+
"b2787d442107d8280714025950ab6138a65dd8da2e127310efe42ad5274faec26b91d8b526ac14af884cf9d5c1e7dac438f6"+
"f9858400944fcf28641127634bb93c56eaf5434c3df32adaa7b72b9c135e12d8db2615b518f8f8e69c656afacf160b3d640d"+
"d47573aba19c1e3e1f5148ea6ed6bcdbad2e359fce657350171ecff29e76054e26a5063a4147819ac923034775c99606baa0"+
"babca753cc4c1e3faf994961ea8e1313d4fa7832464c84a20b43ac2e9579c25c761249c44cc4023c9a66621f7ba1991c3f1d"+
"3493978e9928938266170d5d5f55868937918609be6bc43049d0e3d2cf3be35d67364af170ab991cbe9c99c9ec69c34c2e89"+
"b26fd08bd9f9725e23f498761cb08d454e8bde7a25c3b56d98b447d389d2df9d0fae66f2facc4cbc36672672ed9b5d5bea3e"+
"03d733bd49f024e8d4994980675b29be89cc120fbc1d515ddecdde3089ce0bcde4fc69c94c1addff24cc1504abc4bbdbcc84"+
"0b1fa42e91528225c87ac949c64c82436a1926d1d1d64caeef1f466602a13c334962e30e868b93cf0acd04473c1926d59e2e"+
"a0f9c86417f36684ecefb8bc3099dede69268f5f1e99497c5f3093d2102f1bb3ebbbb3b96100abf3ca324cd0c95b28c49355"+
"77e9d37c3c9a28ba7f7a8e351308866933a619b6d68bf72184a30714179d3731194aeaca616e98c0b645e345af0290e785ce"+
"e40a99dd70fdc23ddc34e7e56aba1e8fc7c3dd6b7dd597ca96e14a3337876d28d28b571cc1d8abb9502c4dd0b01cbe1c664f"+
"e8550013d73db82484aad8079b844cd2e4e9a5452163bd78e84a3a45116be3041be3e683c73bdb684e2d7561d20970bc0035"+
"f939d614170c99e7fea05ae317a6b5474256d39b2f4f28a4bb4a4e1d090104e6d353dd6e10afdce6f29e91c125bfe50434aa"+
"9985b8f66c65e95beff27cef5ff6e3e70712b21e6f5e1f5008a8ab5968e3a5cbb7181007240472ff2dbfa585d4e5a6c2a1f6"+
"152aa6a7c444993e0f7892662d0d93f1bcd14ccecf1d33290c73f7d2c13d6c9461524ea46598f08933ade1f9c04cbc2b6a88"+
"227589ba139ac9e4e14933195f26cc646eacca9b9bf7ceeb0b936a971826587dd44cdad4622662399586897f4c5ccde4fef5"+
"86994c6e7b6672f15b964edf415dc3cef85f95f454d521265b2dc40d179961627fba314a10f1e727cde4eecb1333c9c64133"+
"599820c2c32dc64c127e045497a8d47b262531b9be2f0d13ffa09ba4dcc3e9f6943093e3a77bcda4bb3277f92697ed9ecd35"+
"13bc85649848ba212c68aa979b3193623db10c1375931a26ddf3b866268ff70333e93bf14d2c6125f79d6122f364304c702a"+
"1d39144750772daa2b38547a33e25b4b02cd64f1fc726426d35b8f995c1696c921e671dc5dfa25d48667bba1bad0c9331317"+
"7c0f3311e9e7eec2e4f0e9a4999c3fdf309374a1d3ac4b986ae5334b33e10e525697dd3b1633518e00e3e559b68ba733da00"+
"0787e2a0f78cb09bd7d7dd55b35c43367afb12cf2aecbe0b63b35d2ffbdebe7b4acd77f3f26066a64f6701bdef1cf4152914"+
"0209ac6e243a04080547e58390db9bc5cb8184d4d3e5c30c856006649656cacfedcfa6b3852961c253aef46e96a82e7aa19b"+
"2de9cc2b84f4617bcc040941a372a348487cd59cb1dc514fe35974372121f0e097d2205a15100251e45efb5f079e042baa82"+
"f270874612da968d037cc346f7889b2173d82e302521cbf5e9f3098580ba20a6e18de25dac4ab2b1510805f868dd9d195fd5"+
"7539d9a703211799c8f5556398ec8e73c364f1cf43ac993cdf6a269559b8ef1ccaedc1301149e51b2619bdff92985c3bcce4"+
"c8a3cb495d39c5dca4aee3cb5233b9b98f98896d8c97b5e3fa3ea86bdac9cbbb3c8fbaef04bc891d6a260145b4a82e7cd7a1"+
"6132ada56632fd74df3293fc3663266fb18a87cfc54c4c6711a84be25baa984948573880095e47d04c9ad38d61e21c778d66"+
"72ff3a321375283493d5ec127364be66c2275bcc4446b66682f528854c549b1926c7a3563ace92f8e7563339be8e9a49979b"+
"93f70bfafe766998d8abc0314ca8d51e2ff5fddfff4d043199df73c482eae2ba0431399d6f3b66b23c1f2b66525d2e61d773"+
"cd6471482eeff5f3f45d1364a21ccda4a4db05a02e89f3e13413fb3808cda47dbdd14cea3bc54cc20bfa7c626926be71f2ce"+
"cc0912c99bd138796082efb26226f6a13b1826e529d54cdae787969954a79099885a5d3a3d1ccd443b7952975095d04c6c09"+
"c6cbc6f1be5eeb4ff5fd80fe536ba0c8f47c7b7e5a4f17cbe5f2e17112650a6248736f0a58f06209278be6b26720c23f6ccd"+
"6b04f1add5acaf951e3efea0676e54a3af132121fdf4f0f9738b42165ddcde178a0f67172628f5f11d192004d4535dce8167"+
"6ec48b0d4bb5f69c1a94ad9e27774fe1b37316425d9ed72ce4fc347eba232193287aaa1cb6f54363be797e4542f04be53ca8"+
"75869b247249081e72604687b32c6964a34f50121682cbe494921050d7edf31285642aa837ba7c131a9722b2fb3191a6a373"+
"cf42681e07b9484907cd12d59537c230894db1089e64777fa399b49fd69a4974c9e0d9a1a0bac6b7e4d7d1376c505dbe2734"+
"932b9ed56e3fcf2e4cdc9bbd6ec4498fff7c5a3393ddd34dc64c7c5331a02c8299c8d8b830392b2773cb305121319157a166"+
"92a1bb6726e8e40d93bb4fad6612df2966f2160dcb856798d8bc53485d76e21b2694d1c19f3e3986497f981b26223ed89ac9"+
"f2f97ec14ce0193593e89230e5b74bc304936ccd448443a999f8cc44d48565988c9f4d9d41f8c7c34133b97b6e3493a9f18a"+
"be7edb5738593e9a0e5e1c75b9ba30c17135ec5026fc4e85e2599b9c6ab4637ed13baaebe9f54133e91ea69a497ac11c2786"+
"c97c6a5f984c74c90bb12b9f99ac2433b177b5bc3059d4c2307978e0cd38e9c776ce4c9c4b34ac968e6152b2932775edf17d"+
"0bc4043bc5918947338f505d10730bc3448eb1d44cdad7a366321c7dcda4338560511f169a8918aeff9fb7f3e08e23c71535"+
"53e55cd539e76eb5b26c8f77afffffff7a0423aa25793c5ecff3bbe7bc9d2488f88a20088000754caa568387a413f9a17a24"+
"0e5a6a268a93c5eb837d2ac0769b68f1f0fa7a3f18cebfadb3364c62868c1774560fdae3aa8869bdb02a64fb9db9641fa487"+
"a7ff274081210eb4fb62df7c8f47139d1b90bf44dabcbe2a21f9ddf8e15e09917f7b3e732e4dad84a8c469e53c6d7605d372"+
"503fa45550784e550ee1941f75aa683c0a085cb89490c3e2e1afff7b03218bac9dbd854c1b2f17be09ee5e7785d99c629858"+
"771ec6921d8c42e0f600f30928d103d8018a12a27c9eb916f2fafaf4f54d09091331ba1a284cdf82415d0fce5cca9dc20b17"+
"6abb5af3a6de885cf92e7053de778f23cb843fed0f86c9f9dbde3071c68b5c7362983097a695366067fef34340f9d230996a"+
"2693b3cd888ccf0f39b14cf26f6f8649fd32374c8251e236646499f049402c93833a7f95ba9866122d8866b2dacc8865129f"+
"17c430b9ffef7fef0d93f945df50a4cd193bfffa65659994bad5aa52d721a3860983f615845e379609bf34c432e1f7a565f2"+
"f8d7c83009e7dc3009f58122d5b57becdce19b5d03c7a4b68fa20d13a8bd364c42e99c18a5b2e2e964984c5e1e1786c9dce5"+
"d457ad65127937959dedb817c9448f2356f1025057bcc91d932f6fa165b23c3fde1b26f3e7c230a99c5fd7ae846552d8f70e"+
"454433157956ea124231c94ac3e4a267d882bae03cb14cdefeefbb6152de0f63cd84ed0ef69a757fb14cf4431173ed9587bc"+
"6642037dc80f27c43081c215cba43ec796c9b7af73c3e43a32377932d6117ba9ae874737189a6d23669948d7d8fcdd25bcda"+
"91fa5a402871a527245fb25a5b59a998b72e09abc5e8e5f5e5e5ebbe84b77a8c3ae345c5c3305f1f55b797746eb3698b8ad7"+
"7a379f542dacfa9061cc93b49ef1a65d997f8fecfe73355d1199987cc99490cb64f1b64a4c306aa82b405992dd7f9b54c606"+
"ebd7650c7a7f50f054992ed7e04a99b313d13ff3e9cd6c32b992d343a884c449d83cbf2a2145192ed4ab07f59fee981292af"+
"27f7ae768134778c9906239417da11909b4e59ca890a8e81ba54cd1d51eaa2d943a28448757dfbcf3725241162e7d2bcf34c"+
"0991eae2aee047baa917eb5fb24a4dcf901262aac21eabce31a937c231395e12cbe4eb7361984c9de7d55e0acbc4666ec025"+
"ca4cedc749f9f68a090c6ab9424f9ad832a16f7fd98dc296f7a3d630c95f8ac406a30e86c9f4f9f16899e8c4a666d2487758"+
"3381cc03516d80349357d7ce69940e47cc32197f7b334ca2dd20364cc6476a98ec9eb83b1561a28e655296fa7f04aa1c07e6"+
"ff18264cf7ccd54cd6d02b4c33f9ebff9e0d93e892da42e1516a99cc72879e0d07b6488e356af02dbc6957ddaa72f55395ba"+
"e0326799c4e7a3304c9eff736f98042b7729cd079961428f2e8fbd989abed0a02e79c8ab9b11bc74944c8639b54ce2d75761"+
"99948f7565988c1e4f86496482a12ca9bf9d2d9378c21d93e09a3826ba044c5a60c5447cb7753bf528d29dbc5485dfe0f56c"+
"98b4d0fe41dfe7c0026b264f97c02a8b1f8563124cf9c930510a4eb60bc324bc548ec9f221b34c36fffdcf8b6102792d7344"+
"ada861124f5c288a8693bcf26960a699000bf0b4558fd950656921623bd6539fe960170b68f7d0d583afff7d84de7a1517d1"+
"4318081e6577c3c1eb536bd641c72a2a4905f4b6d649e693eec2129b5a785271789d1bda89bea347d32741feb24f93500981"+
"ba923725240882d55a0b596f171b17eaa2db4e0b51284a7ad27e6ba0bc89398c5e55cf10bed8658f2f4fe672ca44727dd92b"+
"217225f72f2d08618168beec9510b9926ce8bfe06d51472e85accb33a0d4400527f53c7279825ff4a708ea0ace775ac8216a"+
"36af3b2524cfbaa74209912b797bd642d4d818fb93c571646bad4f8c56811a02a339e6cae956ea0a2fa56392dccf02c364f4"+
"9faf96493d8a0d93cdd79d65c274ca49a98b8db96312ebea26f8871567a3965826e1fd686399645fb28361f2edbf1bc324bd"+
"cc2c93958bac9264923a26ac48886112ab4f784e1413da7ed938268f2fb66d8e48065f3acbe479531926f9fdd43271cff2c0"+
"4d0d1d9340d784487541ed25c91ac3643536e505a0aef6e16099742ff703c364ff161a26c5f38365225c34958a816b25740a"+
"625d8763988c56c432d9831ccd8416f2dc324ceefffb6a982c475b6698bc7d1b5a26c6f50275d1837eff0deaa2c941f7d554"+
"4c22f90b182634dfe48ec9fac22d93ff7cdf1926e5e56098e40f774e5790d3364c289f31cb84ab3af9a16132bcf8063ddfde"+
"986512beed5ac3e4f2ed68996cd69961b2b4653fb0f46b6a99505e0bc32456e3d053c3643032278354179da87b9052d7fe79"+
"6d998c36a961727c1d1826b473db91a6ee658a64121e349358c25715bc2eb7a39d894e15eb45f795fc81293f8451f536e816"+
"c3c16eb3b9bbff723fde0d26791189c2a51048a2260584aab5b1bad02df58d3154dd355b1da682023c93402a2ea916020fa2"+
"9f2225240ca3fc75a784d475fdfa4d0b0127cc7fc187a1d042545ba7460b896920ef87d0ba414d08d9aefd27bff9af6a9f03"+
"0eb118dc474a885cc9eb5725643cde6dbe8e9410353dc31bc9f11797075e36aa7639d62d392514338664f2c52e5faea48647"+
"8c54a92b7a1b444ac860f7f09f2f4a885cc9e83e71390dfbaa46ae2434454ba02e1151352e2350d3bb069609db29394a5df2"+
"638e2d93c5cbd83279febe314c96eba9bb946ad74ba98b7208771a26bacf8b62321ec3cfd64c408e63b2dba596c9e6796298"+
"6cbe7fb14c52fc052fa86542f934b44c54cdedd6cc311ccd8eee79cce3d7a965c29fe6a161b2fafe68993c7d9b1826b4f39f"+
"185ddfbb8bf072a18e655017a72c3c52c364f75c3a26d7cd915a26d7974568983cfe75b14cbe0c5ca6746ffda4701f16e637"+
"0575f1443389d5838adc32092fad63129cf7d43219bcb586c9e6fbf3d830a9464e57ec587a26199c7d9a0953ef68d58c0776"+
"a73a286826e1434b2c13fe5408c3a47cbc0c0d93a7bfce96c9d41fbec130f44c9a2ab14c54a541a199449b34b74ca2d797cc"+
"3299c973cb30d9fc75b64c5e9f73cb64387572c4c81505107ee586094d28abb6765ccfdb8b3d0cbaf3fc3e229689d49565f2"+
"f5dbc630593d2f2c937875704c3af3780fd4057d8a629d336707ed6da9af374dcdeb723e9a0474058f4ea073e33229bfcc84"+
"ea0acc82d37dc474a28ef0818fd3d70bcaa6b55e1d2f5cef8954555e460735cf68a685a892eec20891bfc368152821cb54d4"+
"d00f470a9176783b30492142679e0acd4777ee8b8b741d108c3397b7c0034470a0406fc3b51095425969216076eef3a51222"+
"8f92dd510b8136688dffd9aea479ba750653ae8443890c2c75c958952b2170e5fbcbd9377e0fcfa75527e058645fa64a08f4"+
"b87d689510f94f0e3b775964131d070675e9616b44a98b1e5273761d4838d95a2685894c80ba960f53c7e4f8c42d93fd2636"+
"4ce8d83d6b949787d033c94a6a991c968ec95c39b55a5d0594e21826e17dc70c93e566c50c13312a1c93b98b12917475ac1d"+
"9399796629e00525ad1acd643c608ec9f432754c666f6d6a98f087ca3289464e5762edca46a77377b8b086b58961228dd7ac"+
"b04c76dfdc5e3a3c7f8fa861b29cdf8796c962232c93da7f57a179ab07ea12faf99e52178b9863729dde192607b36394ba8a"+
"8ba08609bf0c52c324de6c9961c2d6ee43a12df4ff364ce2454a2c93448dd13b0093cd8e5a266c000e9861b23da79649f594"+
"592615345030bf8cdf8ea41b2e1c93c0146b4875c1215f468a091b14c432618355e8980c36a965b280ef4a33b973890179a0"+
"b8b2d1e9d9ffef46744cbfd3843ac23c324c96f75f9ced8ebebf0acb84dfaf12cb64770c0c13acabb15137a8ab5d30c7240d"+
"15787975a49c4e17616322986b570e7cdc1cef5bdd983b08e2c513b728f8d007d2d6918f3dcfb36d6643ce5d691ebf052c06"+
"8f24059b7ca73a834a37529ec84395799542e42173920e9e1222af3ef31db328662b7f617054a40d7045d050ea175a4f250d"+
"2414b8623574bed542b4d7cdb410f953a74fa11202c2465787627e756b684d37bf835c49b235ed09e44a6825b43b245570d7"+
"80105572b91ab8abd3e4db7d67a9e40f8912027d1b27ee9715fe8822d39c6a21fab19e1602fa2855a102934c8ea165727e70"+
"26f5b8b99c03cb441e7ab165520c9caeaab5fba548b18d1c93f8ca1d93a5ea72024c76bafd15a84be821d64a5d74b8092c93"+
"e4b2b04ce8baf0d1baa38f48dc9f99fffbb59e95a89fd59407c5446c42c7243edf11cb840d76b165525d5c782bcd3de3fc4a"+
"1c93cc8e6a962b895ba699044cf5ec0075d1f23c734cd8c3e3c6321197496c99d45e57aecc00225d8d67a25e316a263455a5"+
"a934a09ccd9965f2789f3a260fcf39b54c22e872cb4cbd87d755be275e4e7b704c4e5366992cf59c1bc841dd0f1d93e92571"+
"4ce24b4d2d934c3d3fd1d51447bf1d577ee3378f73cfe468e699692695ea4bdb64b0d53513da3d70c784df17cc32c95d2c8a"+
"4cfd76b4070aa82bdd469e09446d1513a1fb1a292693f9c9bd262b9f368e49f9d458266ce7753559f86d0f0f810d13368e3c"+
"93906b2672431ee631b583dbbeb74ecdd5b7af253558d87ca43a2de96740fecb1a22494f0f7e77a6bbd678de4a5dd22fe284"+
"aeee8d55921fc1c5fcf3683438cdf53558fd191d6dda81647e17b295f18ed2f19e8fa72e389dc460eb095c5863414be85244"+
"f34a1ddbb3b97e33adaebfa34104367d608440618e77b78eb9fbb5e355a88524aaf7961e05ae1e239ca81a9c28bfe12d9c5b"+
"a0ae7ac766f603492f851622ff049bb9f980298d36fec2b042aeca9c6b210afa946a21608d639504a6ac9d98b12d843e7df3"+
"e7e9ec3f2f9165b2bc8c1d9385df90e9c063281f0789b7ccab8365c254d1965457b01b3826b9ade4912b993e148e892a2db0"+
"ee966b374a42fbfa4caea4741b88b63c54d15950d732a09562725463950c1379c1269609bf9f3926d926f6457cfe502cd57f"+
"a4d515eb8b905657c80d13b9c7b866c27663e2981497a56312dd378e49ee7761882a7cb223734cd8f8e09944cc3059d49649"+
"fcfce82dc3ea3f17c724bb3f5826cc1b2f92214392bfe58e092b6cb9c492a8f0bbf4d5c96935b44cd28ded791041b95d422d"+
"93fd26b04c526fbc486dd30e7225dbadabca68c32eb14ca4d18b1493b92a1ed6ea324fdcb4ba1697a565c256fed25e0ed8cd"+
"0d45ab4bbf9fd44c581b2821ea57344cc20d774c20306199b0fc2c2c936097b99f7d8702cff2f663995018226399c4335518"+
"0731af5aeede5697070d5e5014eb7eb4596b2cd0e6873ae714192f1bf4a2c938df4e7c12adcd4b67eb450c36b292ee53662c"+
"c67e32709142367bfa6ba581c3e4a88dbf4e37485b8a0a0891e697db9e6130aa1c6676062afb2068452023d1bc9916ac90b1"+
"9aeccc4c23b912fe30b562283f87de39f5f550745f1b21c066bf34424075a1aeeb88756e45aa4b6ce412f7c6fdd86e022d04"+
"ee87f79d91020320bc4e867ee3b3f5bd6b54232f0fbcb28f9e784275ff77b0749a09bf6cfc4570fc903b26f2faee982cd69e"+
"f83c734c86bbdaaf2d333169601204506c5d91d9b6b44c460f9967f2fcd7cce9aa73d939a9cfad8faaac2a6299a8421ccb44"+
"5e1f0c13e974478ac9d864bd415de9f94a1c93f1257572c63b7458b98f998855e89934aa4fba56173b2d758c59c453cd8466"+
"106a374c82cd965826ac3e0bcb041a69fb33d67d0624d9ac5da31a1a15cc31819277c504662e6826f568e298b0d1bc704c8e"+
"fa8cd78c5dfd3939d89b835cc9fae20d33adcdae0e20f14015133aa95ac364fbe5ec430de3bf5e2bab2ab65ad9239e885188"+
"cea7c03189f3d03349e0b6a598c81bca413159eb81a04a5dc579e99894a38943c2d0f7138ebca197f746c784a919659a094d"+
"f4a43e08669e0c93156c5dcd8436978367b239da6d2ff792f79932ef0d4b9eb963c28a8a5a26aa39a87ac241e098d3e308da"+
"7398bb6718d2bab362b4cbe0da077935971ef5c68b448a0a8bb67985aa1569758a33a1dbceaa67ad524849f6333b6b889ebf"+
"fa5f966c5fefb510188d89c8563ef041aa79ac85a88b897eca5e9dd4458b2921ea3f56b33aa36fc6a3912b395c3a6a4b7146"+
"2fcf918542aab3f748a65e5b247b986b214a75d2d855a67386b89ae90271a99a4d0dd97ecdb41015c15b1821722585d990ea"+
"e7f90d49c776d3c8959c1fbc7c52da6b3e4de85255895072090c133a5933c7446e48ea982cceb16332f6c6cb0c59d5ea3a0c"+
"856712eaa03048563de34849578963f2f2ead5cdce6f1bc7648fd6303ca2e0a3bcc5582689f62694baa0c1806542b862b27f"+
"618ec9d6beca972b397f7d136ea70cd11a56dea3970750ee98c435774c68d8e93e7e013f68266237238e49a1de246875a5bb"+
"893d4e88de4db7de308bf247bf4ec216db93632294cda314d2bf4a5d629351c7a479081d13a8bba6ee1998375ef1fa441c93"+
"ebd89d0555998596094d54eabf142b3b1b84245fdffcaf143d0d4696091b79a3128f2a6fe8d721714c4cb77ccd44ba2c9a89"+
"1024012674f7e098a41b5b322157f2f69f756c91c41b7f8870e4e12d77f5d632a1e07a3926adee0049e228d64c4a75f7d0ea"+
"623bfdec58a9ab79681d13bef1db3e72de308bd6cf5bffedc92b976312a81ea45001af66101f6a08db49dde726021783cb4a"+
"59b9de4ccaa0bbf8cd868d9718442c1c0feff403532349059f2278d5aa4a7d18e4ab09e7f29a71305d5e07cf28d8301a1a21"+
"30fdf39cfa558c965ee6c34e0b511f2dd479eb0897bc11874bd3ed37ee083c4c18ae6d317abe5aa37d17bc7d3b6b21001619"+
"c67660df6a86e3dd8bcf3693b4e6a5bdd0276da09f0446894a371f261bd39b1dd4559f8d332857727e750f302116e5bfbe4e"+
"5d83b5bac4b0f5bbb330173d50973c7fd5345b4510d4753847c432a199ea3dabd5255668b3d7fe7fc31dc53161fb8e38262c"+
"4b2c9380c3627823eda961c21f2ebe80f2f470724ce8ca7ba62c47b9bfeb25f74c543711c384b52235e72f8b8049b0bb3a26"+
"a37b7f9ba2a7e7b78d6542d7c8300e5d895a38be7f2cfde29a19734cc2d23cd36c7409c0e16c1a1780ba98cdcf83ba9ebeaf"+
"62e7290d90373aa98963524e90f53655ce2a112402c56439b14ce02da863b2569d5eb4ba4e171f1a60036fbce8e44a1d133e"+
"4c3d9304e2399a09bc74924cb633c7e46ee3df5e4194d83151afb6ad07ec134ed260aec68e89d09da1b5bad2961a2660c4a4"+
"baa241e5987cb9f73b8d1e5f468e093f47281264ff370bf7cff7a1ff28eac83369cc38d520a38a4964da9b2a7595d6350175"+
"bd7e2d5cb9d8c1878649a263c34a5d51ee0f31a9504b543249d47366f983f4077e17926aa3266eaafc319d5eec962a069be7"+
"e732b0478a335ed047ffe9699e97b62c5d3baa2c53ed25ba9830fd5813f20b925fae85801f753e8d5d923aba545ac868bd08"+
"8723bfd9f5f368086266fbf50bb236f0a8550b51a9081db3272c800a332276e99d9d29b4fe6befd7ce2f5323447e8b35322a"+
"21cc04072193bc147bff654b17cff35ac672e3072acd45d5c7727f6fbe6eb99278e303b2b47a7dd92821ea991196338ab410"+
"30bd85fbcd581655da3f0475d15879ac5cdfb0e577385c51c7840dec6b3ab99287ef0fa165228d17734c8ac7ddc432b1078a"+
"5217e55041aa98c06aa003566399d0e18039263a9d62989497bd3f01f673ea986c5eb79e09df0ac784261d374c58024c9a39"+
"754c9ebe475ec3e38df04c7663bf1ff613ea989c56fe5e24bf31db7f98b0044a930335604f31b1bd0594bab28bdf0f347fbd"+
"8c2c1348b2f9f54c62c72436af3794bacae2e09848f84a9507c3041c2fc724bc34c43179f96bee9878e305e1d6fbdc316177"+
"19f14c4a6e9940534d08d70bcb446c0aea98e8748a61b27d42b6636086c74b75e58f2f998f53cca01f8e65720a978609c4b9"+
"1b789c6a99c4afafa9ff71d2e83b26d5d92b315837c431a987febb26d5f6ea981ca0863050a51f8a097f9d39267c8d8e5876"+
"feb2734caa8d97130f3a6699d06ae8efcdd9c23c41017509a1335c8752f76a9f0813296c46ad4dd25a37eded454a1a8ea137"+
"77dc3c9481e061596c87f3c9fdc6bb19740676725998005bc4cc542fb8d0cbaba2aa61515308e7720f2a21ba5791b102a2cc"+
"775fbfcdb5908005e57da1851c1751501c19b20f7554b89ac2abd9286adb777476a46c621de2c74bebfd9b73aa854830932f"+
"6fad162257523cae8c10f9e9945e5b6439b44fc4e801e2db66a310f58c76f3647fa16634401b85b497480b0175ed364b2d44"+
"ae64fded5e0bd12780ad5b912b0954e74caad495aa42b96669989cb483a7d5155dfc814bbbe7f3c032119351ea98ec5e8e81"+
"bf54a803c530819ed986490c4e377d4a2d137eee3c1361da2528753dfce771e8980c37a163c2e719fa16174de29804fa0924"+
"182f60c22625b14cc46633724c74019b61b27b1d449649b27eaa3d93bc4047d0c835213d50660e948e2826d1c639dacdf96d"+
"8e4ea1f9803926d9d336764cee5f778e09bdda834baa8b862a23a8d4a5a72eb14cd762b1f9d6880175c9cf37f072568f73c7"+
"e470ae03c7e4fe25734c68ab0e14c364294f43cd2486d78d245087a252d7180e6cc384ceec3706ea7afe6be398f04dce1d93"+
"6ced6f2e30ab75e99824fa4a014ce42fdc0979dd60ce9fdf7a26ca97b04cde5e6bc724badf158e099fa32ffe747145d7070a"+
"c53ef022a1d14cf67397ab68de9ebd8f4892cd943a26c3b7ca31a99f1f578e493c3c7926ccdcb10faac59a995897323db97a"+
"63a3d8c92067d10549823320e04d7d1cae0783fb2ff7f068735f54d277ebe631d2569ed2766a28059d1e8c22fd3b01deea60"+
"aa37ad748a55bb7410a27e34f25a82cdaed342aed7e2f2f5de0881036e858244e966ee1f28a8223fa61a894b23d9400f03ae"+
"8d70bab9f241ee86d1bb1e00019fbe3ccfb510b992ddebce0881ffc6f55a932b11996d420a810ea184c05373f977db5de5b2"+
"22d1d7970085f046811622d5b57afd36d242e44aa6e7314515fc9d1102dbb3824b2457bf69c2e1f8bd6386890bc4487505bd"+
"8d32dd2c3d93d7af23c784a114b07ad3ea98505e858609d4fbb05837190375e9c09666427b5e4b797f6d2c93f1cbd7816342"+
"eb2d92536e6a7f0b8812cd84a98cd002dc42c3a4d82c13c7e4606f59a02ee91d0d1d93a7d7dc31a159eef366b3682c1c1368"+
"1de599d0e39e3b26e3bf7cf506d1fdc00d93d1f7c78163327c083d93d08c0f52ea62d3845826a100267ba29954df6c3dab5c"+
"49b8f169183d13cb32d97c7f2c1c9310a580d50dc53329136e98c470398df6ad61128cc6c431714eb7be856e22c764f4f565"+
"e2988879857e9dbbf9cc31895491816332c9a965020faa3c93ad4d31c9951ccecf2bc764f0fa76754c58eed3836d618b7a41"+
"5d8c536022aff2a0ae60173a2674f47d8ea2cb67ee993c7edf38268bcbce5df2ecc31dcd8472d56a9a33d34c06fec996515d"+
"14707971253277a3f3066dc8e86ce271e0cc9797d6a554c8618ba8b07abf70ae375de8f2bb588788e3fd4c271cee68aeef52"+
"ec0eea299a0bba14a4a3a9110229fa8d4f1210811e3a258bb9db9e5c500ecf01f5a422a27fb614a252709bd4085196bec0d7"+
"e7bdcd3a4bf5ad66e89f6c0b53345854543dac5042dcd30aa26687527878d9d8347675bfd9b91096ead4edc29fab39b3e960"+
"48377a3924bb635a885a9d74f6f58f876c10d47053cd2478bcb81f7c7779f1765e6e5563d694ba863be198d01a79a9f24069"+
"0a7f1d9aea9a6579eaaa80c4746a98889169ff0deaa2a87e4d9e6da3d433a977c27f580d4a2f27f9e8e49930385062f3a886"+
"0e8ec4326130bade31596c909f506d0e9e49b95ba2259888886692e9ff56a94ba4b10d774f69bce3d432a1c3cdd033395dfc"+
"96a6d2c7f44c788ebebe0052e48e4924ffc23049ac03aed4d5beccbd797879c19faffdc654427b33668e89582157801657ee"+
"98505ea78689ca06ceb865929989f24a5d874b761bfd314cc46eeb9204841daffeebe3039f20e462c9111372df38261504b6"+
"2c13ddeac5c5d9541d80299b18e6e89f1436be0dea120b5345ad46ddb0d83c7492ea6ad7cc3149cef59d6362fbd319bbb113"+
"8e091d4fd0d777ca05714c58c62d131aaa6fef07cc4cea54da62b4f0d1e5efcfe8f42df057164e700cc2754c56e17b54ea95"+
"b4ea6b5655bb3f7e48373cd6c7ec75b8b1c682afe7e1042d82442b7470a4830e01dfda88483c9dc54b039c2470fd951e881e"+
"352d192e741ff3ebc26c1425042279d3333efb7c519c7bd4eb9ed43023446f76aa85d8317e4a48dca98ad3ebc271d042748c"+
"738abeb215067e870305fcc88d105d89637a3da847ad4608242247b96732fc0b79446c87bfb22dca984a6f582039175476cd"+
"0b6e99082924e386c962e300cb954c513b28628f1a93995de31fed825172256967d72dd505074aa067b2cb95cce78e49ab23"+
"c05a5d3d6f824c47c8b78e8ef84cd4c7bc56973950341355676bd555c24f334ce451453c937a23f0e71ba16f6c8d8dcaac66"+
"9e495cc58961c20260c234133accc78e097bf8b6f6bf6985e2db72334cd1128663fc8ddde7febe12e93606e0eca572256366"+
"98d42f0e305fafd6289325cf787c10aff6d8a8382f55ae241c879e89ba635b267437b64ce850c74bb5ba7a172eb61ee26f6c"+
"8277aaf6520d13d532d93011a16792a91bbf61b290c6d831897778676c516135c9f0654ee427ea985079a0582681509d54a1"+
"8b090c4c2877a2beba0df030dc0db9339383deef8d10b1a3a322a68bccfb6109576fb269acfb890445a8848083f7ec5fc535"+
"97af6b4c75832dcc7a8abf6d4d450a8108e7d4b8532a409482ad87bec601a3fb957618e54aeca7441bb912d633927c83ed22"+
"3e52543a420b51da92f7f6c49cfba740af04d455a8888a56d71206ac29216042b3f301df23f6c8a8cc26c8990de6bb31f735"+
"755bf3bbc6240ea490a96642875bea98b0d560e699f43c499a23e345c2adfb15c4749c8ffd0b6a2e544d0ea84b6e94a06686"+
"097b79f30776f7f215bba2eb09d24e37401e51605e50697525e63ea7d4152f9590403199d49689dd285a5dbcb7847a800310"+
"c713f654a4161d1336e58e092ba963325d159e4901af9e2c13b6c646b2c2672f9ba05f8144eb7cc17d68aa30e0639a02934c"+
"3311bb883826e179d639267431c2166690a125206f584cf381cf35273ce4860918af587e8b9ac9e1758034f0f5d987e8a5d4"+
"169fbd796f7529714ca83d5012ae5b8fba7d22f29965c26d69a552d71d76530254e645d8185dfa881856d431d1078a6112b4"+
"9ec958775450ead25712cb243ae35363883fdf0a1556c36bb7c23389b3d6318176fc440fb65da88d426b376377c058369847"+
"bad9f7e0483f315e746c66daf2620cf52e9d75aab874f6124a8599084be41583eac9cfeb2f7728c6fffc648428c43b7444c6"+
"abde8735498c106554d4f1cb75bdb56e014ed500e8616adca17a3f71e65cae64f4d85b020e0dd02df68882635eb8038b8856"+
"70a32e110b35a6179a67d3373d7b0dd44567dae21a75e53b64a1e2758d7e74ebe376945fcff85f8c0a1d6e11307d540a0935"+
"13d8288e89dcebc43369cf787bf78c97f586b5ba92bdb537c0240c941035629cc83dad99f00dfa4cd9e0cbc8338977a87884"+
"343bfc61d577d43361333d38482b4339929a497c6496c9dcd720cb957c7989b0fdc5a76fd2f3884e9306313935d43159068a"+
"09f4758af55057a52ef75857a96b391a13b4841176ea8e7b74cdcadfb03b3035ad7aa5ba62681a76d04ca0e2c531a9213261"+
"99d0093ee3939ef1cacc2476a52e96b92f5bae2456ed34a18814663dcc2d93f1204715a2f7bb8167d23be375f8ca498598af"+
"63c217823826f152382651412d9307ef96b26cf3ed81f99fb61ccd70f47425703cade69e091c289609bc04b44c22fd1041a9"+
"2b321657a98b5d37f8439ae30392e7a88a970fded07d99eeafe691a6aa1a96c6eba446563542d50518b733d521ce763558c8"+
"af3019159f1aaf6e28f7745cd62ae9474f57d39b39d1055e4ca54ea0e7bf4a69c1a64a46adf76de5952b3542d45fe10f3898"+
"8f7b3bb23042148822314280ec418522c1aec447cacd3df6f8adc6b6fdfb1723447dc01be41ed1851b322c57d2dddfe32d95"+
"ddd90e168c4ad79bc2a474b9392ee683912b61ae0e0ad4953f600e6270457f159a008b5657943b2786865cb76250cd57607c"+
"50a499944a1f465d85eebfa2d5254ff925365ef85464501de398b0a2a48e091c289a89dc284c3dfa05755d078167c2370be6"+
"99f011bafd9016d5f801fbd033a1273543c4540857a963122e2c13baf986ddd287af1bcf84cde7587173bf6d685c3f0e380a"+
"4e14999d98cee4e5410ba1febe2e5702e152cf64f456a2254cfbf6d7d6e882bac2058a188551693bbc9018e65c72c5a43bd6"+
"c43131cdc30c9378d073e1b1f12211b4f0714c4cf318c324d49d90d481c28686091b2cd01d50ba30d431e99ff1761e98655f"+
"08cf84cdc0301a266a808c1242f9342286097b7cc1b7aa97c78167126ed01122ad36aa0613ebb7dc33a15577724ca05ad130"+
"99ae1bc764ebe6e8c8958c1e2fe8e8ee455748bab295e5a0aeece81d656aba272b75a5aa877d0bbe04992ed6eac7357328cb"+
"ca4ce2912ec783f562ff80e9f78c170907d3a6be2b4d0da018ab8b5c95ea2eba02feb61af6c0666a2a86343953b908254407"+
"9fe089b21202998a758fc3dc9ff96c597cb9ef6274b7698d108092a8bc3f4425a0aa789a98db0faee2a8378d11a2bcf0de07"+
"3c353122b6942b6966477cc0ec8debc4e08d931e2c20d595cec7e60734f36ee38f06ba5cfff538e6fe9e3640471759aee0a3"+
"5c1a7505b5bd3bc04a62a85766b0c0400de0504c66833be298b095f1ae94baea0dca3cde182fb92343cf8496aa0fb05157c0"+
"9510353d2850f722a92eb6aa896342a76a448a65d26227955443ff29b1e5f065507a26a2493d930866ba407c45dee44b6299"+
"ccefd79e8964cf3d13b6c61f703031d108a5ae59ef7217cf33c704768a02cf49b39f5926abb98f544b7bfdf4fdbc704c6881"+
"6fbef22a2f8863424f7b57dd5da52c54397958a01aa6a999d426c1a4d4156dec3e0375adbee0e069cff322c92a5b7a26c142"+
"57f32a75d124f54ce2cc30e1e0205a266c0d7c2d93fe194f737471607cf3967b26b4cda867022dc30c136875a899f0cd7cee"+
"9848f6d1d23369e778a7b73663aad495e3fc290dd7c609932b8963c7647f9a5a263bd46c4cfe5ecfcf03cf2458ef315f45db"+
"32610bff6a0d98c4c430e1eadaf883a86b97190f49f8aaa428c845e50de7f1fba680474bfa5f3819e3054f1e79377fde34fe"+
"836453691ad396d9ccbccecfa981ec4a48cdf4f33810a2439ca515b21a4c8e6f132b44f9c35b6a842cf2bacb734c2ccca7c6"+
"bf952e246c6d3d2a6e5128212a1b370f572e4309f48d1058c91d0a624bc5aeb91152ca9fb44409a8b4e59dae2711ba6b8912"+
"12d2684fed7d903fbef49c91cbd80a912be13b64d8e87230c98c10f5a1981da9d4050142dde7430f18574cd84b461c133ef2"+
"2fefe50de7dbebdc3371c64babebf232293d93244b8967a2dc5462c6f71926897ae2679848f6016272fed22026d131229ec9"+
"78d0e1c3262b4ac704ba431a2660efb4ba96a38e7b26d5b9219e09c7f115c2867bea99d00cddbed3b26ca963c29965326e1c"+
"93eadb05ffacd520f24cd818e51ce44f1e4d3bcf24dd878889884cd31d79ca3b75853691052b19fb20975cc9e8fbd3c43371"+
"9e9752d7e2f169ef99e860946512844bbf4f2ac3a4d08d05b4ba2c7badaec1cb79e999e8527fcb64bf1ea0a015591655eb98"+
"406ad6a80b102b75c9733cf64ce44528404c16f87a4a2278c4ea98c45bf4ee21cd8caf07ea62c23261c3d431a9bf63c724da"+
"ccb86722d6e88e45d964127a26b4b1ff0cd4452140a89970a686cec2ab40e8776f9be16cf3a817e8a0c74d56e4abf5305f64"+
"5578a8efc787306a66e3fd311f77d51c9f8af2ee204efe79abbab6e8f9b98ca9bafb7db26b8d10c879d5887e10aebe3e5a21"+
"9cf36ab3991a21d0ffa3cd111536b3d355694ad5ec6f33e7325742c0d3dfcda816a22f3f632b44ae64f0fc9a1b21b092c1f3"+
"c808d1795bd7c84bae44f70fd17d6d4303457aaf332d44dd1c5e26017ad9bd4b8d1058c9f0716885c895ac5e9ea6dc851468"+
"a47ac730ad2e2addc7d40c1650337a81493a9a7b2677bd2f29d9e4916712ed3627c4a4c6a722dc1d9867d2a9b20fcd447753"+
"65fb9976bab5ba20f5ee9944f7df3688c9e2296f3c137657f46e2c361d054c8463524c0d13da49e5782663137cd2eaba7c7d"+
"5a7826d3a72f13c4c45fb1612571a47bd5a838851122cf13ee981c2ee73c40afaf213467998c2f6f1962727edd759e09bbea"+
"3a54ad2ec64d436333a35731c9e65bc764bec11b529ab22af44c8afb9c7b26b3c1b177f65e63cf8465ec1d937c35268e099d"+
"6ed0dd29983d3fae3d937070c91093b0c6ecc5da1e097225714a2c9371659940c4cc3111ee050ea86bfdf2758098e48fa3bd"+
"67c2c68ebd5c098b4ed431892c93127a97edcdacd9cddc33a105b0774c268fbbc833c91f5f72c484eb98ad51571a52c324d6"+
"c64b10e95006abf2ceaab77ac2b5b0f2e852b63de051b6a8f7fbcbb7735d8f674db8d48376ee18de54f33bf71458042935a3"+
"4761b2806a742b46d6a3af5619d53fd93ba69bce0a917f8e8f5f6a23442d62ec1b41f02631afa954a4536847555ac8489969"+
"217fa593da1a204407b970843edd3c2c8c1058c9f1feca70a0766152108d3ada6d38151a9f6921e400b941a1d7bddc155688"+
"529535374a5d83d7b315225722b6d87984a7934688fa6ec2443f5ad5c62b06759d8689536ef3fa057b8bd5bc249ec9f0e579"+
"8298f0090ae6c338c5a967922026ad61f2c5ee415849b5c13102365c09c464f43a9a7926747687decd36ed34b6be3001e365"+
"9854a56142f5cb48a32e36c74906da3d4d32cfe4ba394788896d1aa5d5c5aa25b14c04334c22085c6a26d29b582226277bb7"+
"53ea9abd3d4f10936a5d62fbd3c0086bcb441e283afc61078c4b75d1bb99708bbe7343d94dc436404c46dfeef79e092d7274"+
"cd27b1fcfb8ec932d4ef661593936612b981ae72256c38c0ff71389a52cfe4f8e5e58898a4397a35cbb345e9ee273069c932"+
"99868689d02f238dba2214020142972962327c1b2e190adc981cb256575a32cb0446766a26f074d63081820ecf841e5d6a19"+
"56727c7ed87b267c8b6b25a4aaa013a865c238d3e059608d1769616e7b6aa9d0fc7984a2d6e9005792d06a5e51bcd751cd0a"+
"4d8b79e54d3db48d0a88d697fc79ad22ec3a21b1f17c3cbae25d36b5dd3d74615c2f0b48e2bd9d219bca2b280d5b67ead5dc"+
"49adaff0a0fc3ab99285b6225208589f1a173d4a4ddabef6aa60185d6594f308e65709516243a685d020b61b852a2748abab"+
"9446520b71a73c4e5c575688da54474c85154dd284be7e54d55b06aabe00368a54d7b4268e89d83cad2294a51de19483747a"+
"02c444e43843931edd4549318106457aa318266c73f64c563b5c6f4502f75c5aa9eb306cb0aa9c37acd4c51aee8fdf646999"+
"44cc30494d35b05657bac3810ed24e2ae299d0c5b0a7aab17a4d6898d0d01ebf541e8f8609536b50ea5213521c137dcaa3fc"+
"e29c2126e9106f5779422e53cf64a9bac5d14045b9410869691e3a26343bafe79e49b0c6096d1aee3a5f3c2acde2115d1ca8"+
"7ff901cf8c53014288021f12c5849fe79ec9086741a1c359453c135ae3b23ec2ee661431493a461c135544aa56d251c3a433"+
"1b43a9eb5655c339434c96135cba4442d598d93261f00a4133891323447a2ad432e1d03dcc31897be50b44a9ca31a1d910df"+
"7ce92c639e098d2a0d9e18e325c504e149ea27b557a1f990e71387052c3dde91c7deb9de1edd33c3b46be3d29a7a78659cc0"+
"96522bf9f1239142d40d7d8b86947ec554688d63a950d419f43e605d9e2085a8317e7077a02623965821d52150f64f6e586b"+
"45845c4930c7016de94cf7f6cd72d2fb8093825b21cad4a72615aa268f2a2a7498e90889b46377ca7f10465dd1a8f7a3ca5e"+
"6e8376c3defaea51e62f915cdf85a8fe841593a8ee8863128ddad433a1db5e6883e53d3bcff6be4fac5c09b7916cc5443778"+
"d142846222d6992f473b3cbf62fb940eeadee65ef5f7fae2403c131aa959125a5d10c3d3423a66980cdce507d4556e70c08c"+
"66a8b5165c7527bd0f3893beb1672222669930cb84696f13d425749ac430a1f9bab7b9273d550539ce07133119b6e862afef"+
"426a1aac61d2c2c6324ca040457826c96edcdb913d3b4fa2fae08f93aecc5cd361b992788998048a4933e49e49f1ed0967c0"+
"8b1d36317431c1eba385690ea8d515a8b4af66422b668548d74d337972c16db9927632e81d19f3636fd70c719040da2469ed"+
"1c13084619268c19214ce8a7df525d34d3dfab51178adfea1460d9b328f3defacae10231e90e8649fa431b2fb96d42357831"+
"d6ad8f1328404fb693c63c40ed259ca4f1eafde5c10cf4a6bc6ba1a9b4a6c212fd509e12ab2fe8030c8f412b234499a787b5"+
"15a24b7de2dee6ee9dbe34ab0323440968532344a21156c82124fadd40f43c4615a0fd2a2f92ac7b9fd90d9578bf9fb6be78"+
"e2a417049fb0d928011deb060172256c6eeca05297f71d5d2d414f737b8ee2bb599efb0a9b842d857ee214db6f58de8442e2"+
"98a8249963c2263d6b7c63bce8e28e2126acd39fbe521713816772504c0ef3c0334977ab1c3139ec663dcdcd7bc64beca127"+
"93654293963926a1db28556c988c9fbd294ff22f8f55cf0dedc5e96837c1fe1f3d6dbbce3361cdc9d82e93de8092c8716499"+
"44d60e2a7505abbe619fe47d3bef730110a91ef84f413249d92d13dd2153ab2b56b5ed8ec969d4f58cd7b167bc12d3b3c2a8"+
"2b29cd354833619e090726745c53cfa4d8655bcf84dead7b0757d1b7f38dbc382026ed815a262c751652fe30c5840ede5294"+
"11fdf680779c58f5cef8f8d8db356c310b3d139a5426640f4eb151972843c364e9caf395ba9a794b7a05383d8b12ee51a117"+
"e5c791ff4b96a8574ec04418e305cfc0f58319a6febb56ffeb623187de6f3796fed678a5ea459828677aba92686113065a5d"+
"69a40bd6141428e26730628ad95f4e7a78cc08d1dfd5a4bf0587bd23a5ca2b2b441d8b87d8ec9300aec15a088c1b5621163e"+
"1a20a767f6fc6485e844506f47c6b86b1015d966852ec241a7af2ad045c9082171c14a6d43f6854fb8c9956c07bbde87345d"+
"1f7a54ee6c3f23a5aeb4b3490750975842a37442cd6e843e193a2bafd4458f5a37465da25758f0ce786590f2774cd84935be"+
"d24c28e7b74c4a88d95a2627e9df2326d504473fc9723eed6dfdf16c8998c4511c5826825921ac324cc62b547ec8d62f3bc4"+
"84d6ab9e575ae237b354ec1f50be910a53d20bed0d2c1371a596c9cabb5a7225ebfbfe169c6ff15fd2b1bd082875c5a5f388"+
"e44ae095d30d93f8123b267ca7cd935617cb4611f9dc78896d4711934095445826a1f04c8462026daa2c13e9e10588093bae"+
"82be939af4dc9805179e090d23bb19690cef528d10ae9904f319b2148787f31c3149d68bfe4786a3db34196c3ac4849b4871"+
"4099db27bc2586c9f0c11b3eb158dda3963e606f7b1714c2dd3b66a52e5eb83ba35c89b2c09609d1be0459983971b382d2eb"+
"caf6d63be5937134ec597a52e53de315ef0b5e169d9debc54ab9fad4fc07614aa831c33f7ec048a4ee004f6454a721d80aa0"+
"1d2d04a29462d5ffae0a7cf7a5e9f67e982023c36db70f7865ec84c01405f84acab99815be7c65575921da4dedfa546a9726"+
"932be15de10fe3348d1375d6c2af6b850453463bd341ef059d12ac7b79cd0fec839ca83d7d9515498dba5866a2324a5d416a"+
"9f5259ff8e9a126b5057bc1a53c4a4d8dc7c573d075fdaf930454c38543b1826b40d7a42a4bad47865cb6436e0c43391b7b9"+
"de77b59c60b34ff9e0522026ac2deda854123327a4d54ca83c233c937895078809ddf62237e4b475dd3d60256d7df2e1a374"+
"c95574c5bc72325fd7951a26ecfe0d27def36f4f63c444f45eb2ca652bf7d732a107fb8c4e75d792def00d93783b754c1a7b"+
"a82b75d58351df881ccb1ea2ba608889ea11e89874f486c9ec1811c72456fbc23109fab73936ed3ba9cd799d212669195a26"+
"72cf3b219166b25c71cf8436a313434c0efd339eed7d577cb9926c5ce360f7410ffdee3149336298f0971ddabaf1f9798798"+
"c83b65d87787743b22a32e669ee21b26d21b36af9c8cf12229295ab3a1c36dd82b7bab86cfcf3567de6f41c68b4a43d85d2e"+
"05c7efc0a3c0e63963f3a2c6784530ca69a87fb48ef6453bc39755fb499e4d47bdef8acd7488088454b36bd3e415c586c29c"+
"91d0996ae98440eb2568845640eb7f3beb8dee57c20a515517bd3b3661777b668540a395f06abb0830a807804eadb1795163"+
"8e1469eccca0bde903eed523d693d20a51e677d5fb9ed3e3951b21fa63d1ad404dee59ed48ff799194ee53c764ba435b8155"+
"9b6f0f53c4041b2f58c9fe69dd2026f14930c724096e999827864a5d34b7cf0d94ba66f34dd80b74981bb65157b7cd71ad77"+
"306eed3ed12f6af49fa566c240eb8e09571734c7841df1c34fb83a40c376c7844d5dc93cac44c0eebc6122fd2bd3706bb2f6"+
"232ee0e06a2ac46439ef5f7ee4cd3e454cd226219e8958eaf9809e49706596493ec75931d63dbeae32c424ca4b54e3c7a49d"+
"df23261078764ce02db36722372389cd882ca52e3e9852c4647b19b25e799d6dbaa1d555f79e04d3c48ef8802ed58113926a"+
"26211c1996095da8d1728ec9ed195fe701414c78e682dd72254ccd6e0375c54e5d30fa4cab2b1a5cb79e49bc3a0ac4e4f68c"+
"1779112026b4d57913ad2e96069e895e0e21722f985f951d1f7b771231184cc7c3633dabb89a70520e4a33aabd998e175db5"+
"bfc39f1d8d6afbb9c7d0c9cba90b84109299f241362e208a873a572c9bddb7a7ad15025f6eb18eac90081e33150d6a8fc863"+
"bd345500cdbc10d5b5a8a36a521d08e90569a51058c9eeadb6426025c97c545821bae4ceb66051756a4b3de2922021300840"+
"a98bd64731f68e9aba8f1a217225cb7cc0ad1058c9f6e95244a8a74cd4312344fdd2eac72075c563e6988c5e7a59926c5434"+
"8849701cc69849b1ea5be72e73efaa285c4b7a4c68bef64c027caba2cbeced75572326c9fc2e464c58344bd13ee1a169ab47"+
"750da1fda3eeae9d981f886752d90344ab6bf276ae309366736c1013da4c1962127cc0a44b0d13312f9967a2efa39e49b9bb"+
"6398c9e0cbaa434c026878e798c4dafe2075250bc7447c79c211a2603e09319376d050c4648a0ad9d53abac8315115e33d26"+
"6c557b266def3dde327f7e1b6226d375c4309302a79a93a815f63ca1de19b64c4afdca49ab8bb9834babebfc32e4888938ee"+
"32cc4464b60738a84bb5e07fc724364c9a498c98e8fba86372c84711454c8afb873d62424378a96e99e897cc465dc42406e4"+
"866566d5c9c3a5c5ef1c560bf8b1c9695ad479de96e7f3a6adf6f52c930e29782c4d8d4f5f319b3177fc425e1ee94bd23be5"+
"f65c386c9b7dffaa50ed0a6e84b45555e59797b515a2fde3a90b4f40db606ec6584b2d207da5ead9f1cc140b1cb6b0927455"+
"f70ec1d5e3c00aa9e44aeacda54b916b194f55960a84e874801242032f44a866aa6a80b534925a888e3c96d63101756ddf9e"+
"075608ac24ccf16b4de81a248c107009f48454ac2ef96f1b26b4b8ac10137a5d738298cc1f1f27156222eaa6179e70d5d072"+
"2522b861428b2c734cea9bab423ee70962b27a94e70b62924cddcc33588950078a52d70109118ac9769512c7844ef1c14559"+
"fbf0506326abb7758898d0485de72c1379a0bc630205794a5d7c7f209e8973e98cba06cf4f47cc64868a1dd475aea29e0918"+
"e33e9364412d9360be423555fa23434c36e7f3163161e55d2f1c7a3afaf384c637e0e5bd823b26f9a09784975ecc34404cb6"+
"97975d8d98d0cc1b6eb9127648ed6871ca919058f715cfa967d20b074adde64ff30231d95eeec7984930d5f370b4bae4659e"+
"be63a21a6640976ed508d9318976f655955257fdf4bc6b119376824a8cd5cd577826b4d5ede590f1fa4116d0914c5b8730af"+
"caad471a0e9c295774ba41e79b11aa3151fe85b188521106ae7a34e6e840510fcda3823913347d3cf77cb646d7605053e6c5"+
"a6f343ffbb9a312b84eae680a62a4edc0801b73b7391df881ed6593f9836e74e883abbb669df51699911a24cbd0ab7b0de4a"+
"42f58473ca989a614f8dbae48eec5dde593de7bef11d2486fac64bdccd52179a64ee91935b0954d06975d1bb638098d0fddc"+
"bf4c80e15fc3498a99040bf42c49444918ba06092415374ce82cf44c8eafbdbc6c30344d438cba9261cd7a5ef9d5d60a6b26"+
"09b34ce2774ca2a7c43361fdea24924ec6143349f2aca72a2852f44c98f65afaeae28649a474639908549aa3b6e9aa609809"+
"1f9f7ad6ba5ab49e49fc8e09857a5eadaee5aaa488c9618dde92cb9534838c2126729b206b2da2d0a41b55452f0f6e98b086"+
"39266cf3823f5f5a9ae12d565dd35544f135b22d62e299c0537cc3247ecf6471669e09efb57181dbdc816026d3fc669b4080"+
"d9311107f342040b118689eec261d445bb412f904ac7723f2226b4a87b2184785a469e09171ebc4dd325aa8d841a5856ce13"+
"f99b6d6d05477b6c7b5bbfda56b4f739cc6cdc7219c18b36d55d5ad5c1da97678ebcf4f966540b815f6abdc97d05875ce3aa"+
"b7f56979d7cbd549fcc20a21fa3dab12c2687c2304626baef845ae6432eaa518e862b2ec53c87b7f4ddb8c47bedd41bb54f5"+
"cf3d2807f54897669149f26a75d1c5bcff83eb636f87d20cc538e152b6b7a72f1cb6f2ff485f5da7cc326110bbf74c58de2b"+
"81935e4d7f8732e7fe2a75d1a5325eba3639a2b74cb2903826e5eeb8454cc4a4f77e82c4dbbef90d666a829e65228d976512"+
"bc63920cc79ec9f032ef3ba1bd5766909c9bf6ffba3b2c3d93204335e9ce7819268b63809824f35e21973c99fb5671b96f7b"+
"b7b97a6f35ab98b05b266564991cb621414caa7e76919eb6bd6d4350d20c56c2f46ab4ba4eb74c4218276698b0e3708698d0"+
"6c7db34df6fdbf8ef4d441a32eb9dba961c2d83b26d3f1d43319bd4d6fcef8e4669b24fd6dd20588899abaf00993c2362bd6"+
"eaba0905d37a78bb4d7a6506a1cf12c995a4689f58ad319da2906c68a60ac169bb9fa945df2aabdaf7ce2a7975d035b6fca4"+
"2b6cc12362b1a9ebfdd1fb23dd36d04f19d9e25066845887a8af9cba2f98774b2b44d1a984713d6f852494ed0f65e4b3f2cf"+
"935ebc613cec1f21659f4a50cf5d945aae64a9fc54d217c274edccc235b10675f1bc579946d85ddeff6b74c38695305b1b03"+
"ea62beb8c09d5b9565c272658d2c1331d9f78dd5beffd7b42b028298c075ce3061fc1d13952cd7eaa2d3494a1193e5a497d5"+
"24f1be6fbc58d631c4841dcc5c84beedd24c923be6992c1fde169809efd7608053dadffac3fdd23349f5b8f70f99d0d58621"+
"26d3752fea4ca2bce95b4574c38695e86261cb64f98e09e796c94967f98cbae4bda1ef4e9c6ecef8e5cc54db697531f5c458"+
"338997e4565daac3b656573c2c2862f27e9bdcf5b60904d229621273f139936c4a1d139a3d8d6688c9ed36a1e5b82fb89964"+
"7e1cb1444f3f60427521db79e21b5dec17f3bed77d7bc6cb6de205cb95f032629e491a7b21ce78b54c19779eb9d64e34b9de"+
"35f13b65dd1a2f519ca4b2dac866a9784a4d94f5bdf1227ca285a85aac6deb847ca4aceac67885f3bb084da0a8d4927c09a1"+
"17220f999a1b211a7763857ce810550bd45e59aea4cc5ced9d5c49aa5673b312987b08637946bee4515e751e2fbc9f5cee1b"+
"2f698e532704dee844ba864c0b10ec5608aba861c26dde5dab2bb9b129b7c64b5d1d1013c8ff1a262c7ec7a4ac1d13aadc16"+
"cf44da949ea0e0eec678cd8e1962624ec08f992435f34cd249c1319330efdb98b82e70a397b65cf83bb3d09d703e61222f25"+
"a8d485ef9e2771afd27d5bf6058d338a99c4514c1c93e0406f85c8bf65984c8f6e0cb65c497abb4d4efbbef112d78a212650"+
"6f679904c13b26ba099b52573a513e8d654217c3e5cd3689fa56725fb48889c8e2cf99941023b41d86a6139e2026efb70936"+
"5e72250b7f14cb95a887ccef98248a09dbdf6528d1faf4586026b7673cad6c159456170b23e699a48917e22c65a4474fcbef"+
"d13f65a42cbce6e74dfff676ba51569ae7dd09e5d078244c053fbd5117f8aa7bdd9205c6c945dadf0521771967ef94158dd1"+
"633e1196b33cf21a606299a8d9d2b7ea5254f895133fb3ae3e0656c8873625d2af5c941058495ac556880a127d2484a9b90f"+
"cb22cc4254923ca8ad10531913f405cd122744674e981122fff6e1bd10337a5a5e0b7ddf5458c9e06dd8b7217775dff32a87"+
"b3123161616299b0e09dbae2825b26b436ed438dbaa21b9b12d4b8798908bb7c8b9aa6b1656826a1b00f98b4f03b5a267cde"+
"50c484deda94c0e6a68cba5875629e89345e9f8097ea6ac68167224d597d454cded994a0801e8a9e093cd2734cfcbb33ffe7"+
"440c93811f51235752dfbff5eea3f47477bab192e30831a1298f2d93f8bdba0e656299f07d451093f8ee769be0fd2857b258"+
"cfd0fb69bdf33f63729d52c7845e8f8220261f6c139b5ed4ea4a2b5752f4374c681d31cf243ee62d66f27e9bc007e999488b"+
"c23c13ffee0c19af1fa13474baf01237fba7c1fa7e58779170cf8b9df182c2111e35c57cd1ab3b31a3aca121d28f777f6893"+
"6af3cda7a21aba42119a74e3e3c32664f8c9b7325e4648130a5becaeefbeaad8471d82ef854026e86084a8adbf675608ac64"+
"99df282b1c474e88ba6545c20a81eb29ff448854573a4b8d1075e60d674e08ac24d8f76a92e5a5797de784a8233b645a0878"+
"44e203218961926cf003365a6d06356612d4b51f3a2b57d2e56bfc789e0459f21326ac0b2c13bef7b3e86125a32f478199b0"+
"f19811cc24f4434e2140b48cb5f7f391ba5233e841a92bdc9f08629266abbe4d61d76b809930fd20d730615c7ccea4bc52cf"+
"844e87096672736f90cecf76d86026909d734c12f681905833a1d96e8cdb566e47f518314167bc565731182ef1d7cd756f4d"+
"1861fd81ba44c52c93ce37dd8795e46ff7196662ce78cf4464fe8c574cd8e74c227d9d53eaa2b549ce187585c3fc669b5c23"+
"8a99c4d5123349824f995048073a26e9b1a098497f9b40eb87491121262a646b990402dd4c090aae1135b28a8e174d1750ec"+
"3eb0f4d42d78d134a790f3ebaee09c8755952dbb88c7724b36f83416496227d4c41f18af2865a1e9f0b9ee57ee2fd7a3ab13"+
"922c97c975b46dad10aacda23d8d81bb345ec147b61eac3d9999e2f456ae846dfd250b5622f12f9c1058497e993b216aaf47"+
"a915023f22fe4c883ca52138aa84e8c08ca9f136eaba6e069513022bb95b77d8a6d0f49418ff39a031fb408865925cc3d633"+
"51f114cc249acfa30433e11d6e152b96a19d50f32193965926d34bef2d0dcd4679879944f37557212694b782782674a9a706"+
"7da82e5a779ec9092563e44aa6a3c741879964bbcd1833a107f5e8db3051afb33e635241e8df32a18529a335eaeae6973dc7"+
"4c8af584f792752117960984bc3e60a2babe489f6ecc1013e53e60268b5d91602641d6e1934c443a031c7ce40ccb03a5a196"+
"49fed4b3ebf170d5612649b1ab23cc843515434cc078051f395ea02e662c2ca8abe7becb95dc3d3ded1bc424da9f2753cc24"+
"50e3392d93b8fa7433b2a8888867920ced4555abab3e8f4acc84e7a3458c998830f64c1264eb91ad4ccd7bdac5943169be5c"+
"82c93c53975677c9a3537bbce45514eaf2356d851a77ec0bb874c1752e201faa4b9e5b9512a21e3f3c8c835e8269c1ac90aa"+
"6ddbea6eb448193a6358ab3d60a16f2a420587e9474218e15d6814d474876d3ff82bf27d62859ce44ad22abf39f6c3251336"+
"3e1a73fa9910421b9d3d36ea0aef5a5c4f16448341678528752559ef4d977df4ad3ae1241f0a119a495a24c433a1ad7df566"+
"d4351d8da627cc246ddce42750973c158966127c240406dd9a69b4934186db4b37f2668f9974eb752530139d35b14c68aaa6"+
"b07fac2eda72cf6436ec67b29a491b6026bcae7ba12ab86153c764f93326636d7fb5bae8621b63df371e6fee4e9809eba6bd"+
"7a1dff18e553268162421b28f9724c02b34dacba2ab94d5acc84969def4e2c57a29e9d2926f14742e405dc3009e7fb2ec0db"+
"443abf98c97673c73113d6eafa2ba32e799dfb099329734c8a9b40aac86bd163d20d4bda0be9461c318157489f329977c433"+
"e17725ae2763e17a55f6989814a03fe367dc31414f017bc6eb878a11a6b4c8988ae5e95482d8f693d8f2eadb8f79b1ca182f"+
"bde1a5f18299bc9face4c70fc8adabf9e9b4b9e3a5cf5790f456102fa21bc9301ad96b2bec573ff7e3388d1ed20e9fe3e27e"+
"dba7b22f7a1122924c6f56d4d9ced670318de9674220b5d51821b092e8261ad88b3aebda7df42fc895a4dc344c82c4d6a742"+
"a4ba04f402774c68d96b9709755d8bbe2051daba7d5d200abd897ec2046cb79e695f770162c2ba635f109b5d83bea0534a10"+
"9364f913263c248ec9fcbefff2afb95911ed8a7ec025e942cfa4ff72e3465dc23c3651ea62e37ead076dc7fddc1c2db1f162"+
"d249d51506a0ae40fc8c49ab3c3ccb24de5ed9c71122b74dacf1d2ea8a61faf44f9844c43009af29434cdeedc7c3cd366127"+
"350fc132613a80fbc94ae4d9639924e711ef3f25ef0b22c9ec9da0c43109d2e0274caa6dea9984f54d2ae3ee67db44ae243c"+
"59f789b83622ef8c97a21244856902134de13f12377e0b8dae3754a2128e02616e401089a49f33516e3709c0ef2eebc00ad1"+
"c6ab9fd922b7c64b0a4aec354b7a4461fc1321d05a3730bfa7180e9d1025687f2328c5c64bae24b42f5be15eca969f0a81bb"+
"036a9336cdfb856a44dc1a2fd1b970a15257a04f5f1567fb5c885457679f9f2975b1a65fdb218dd78da0b85565b896095bc6"+
"c14f99a486091b438b10c784663782d8b4e81bafb8e1c2334913fa1321304d35b03183e11433615d7e63bc9a59dc0b4d35d6"+
"c680ba84f809135671cf643cca6ff2b0e31b735c4ddd7c7b5809d543db74d1f84f99d838a35697d8ffed366918414ce225fb"+
"39136a9884aabcd131b9dd26efce7879710e10133597eaf3cd583926415d9c309377db64d93be3e53da270dd1f02e8c5fe93"+
"95245dec99cc2fcdcd36997db24d8cba58c2886592fcf8cc78e9ff20774f1be3328ba23ceb2b2b2cc29bbfd1a4294f99fbe5"+
"8ce44f378afa4d0e09ad74e60a84c0efb5dc6637c6ab6fe95952b80c2b748f11ec274248c495106dd95b6a85282a77378250"+
"8893c14a02ddb540b51c2549f0b91042a29311a2eec19761841f3688f1f4c6a6344a10b3ea0ae0f4d51559ec2742a054cd0d"+
"20932ba916fd5a67121437c62ba8428698b0d2fc8e9f09490c1376d5dfa35117cdf67d412ceb1b2f16ed4be699e884d0a7df"+
"3014956b75c9834b10c48476fbe4c621f2c64bad449857baaa35ef81fd8409eb8467124c760566c2dac58df18a74cac1aa4b"+
"3aecd430a13f67c27dfda35cc9eca6a88446efb6491b6326c2e4ea3eb72b5433b1816ea3aee5b6bb315eb70e51561f1013dd"+
"b9e25326caa22a75b1b1740d1193747fb34d529c09902b090ea6d78e6212d29f301119f54ca2759e6126a2bedd269d1664d5"+
"a51e6e6826fdc42cb9f525a4a9af2b9f04168b87553f0918ce7a811b268a7e09836e40f6291388e3e8fc5166435e545459c9"+
"a3bcf9ec36277f6ac245606326d0acf1a3baa89b28b412029dcd959baa85c04ad2baa3b7969e5921cab8e846efa6d9c3cf84"+
"102e373bb3a53bd1953b21da78653736450ab242740161609b3dfc4c88dc4d59e34b7768ba7ae8f5f920ace89d5d941db6d7"+
"0431e1a650e673214c3369b7be95925c4938de8afe56ef6601c14c123b584ba92b48e94f8584d430a1551d13c4847675fa91"+
"43e499e810113336ffa74cca03714cd862c63013d616372e5ed808cc441a2f669e96fc0d93a0e18849351a74bc97042cfa8f"+
"db58b72f056272323ee8cf85005b57fea8d4359ddc7cbddc3b444a5dcbca35f38248d832f8a910685ba6d5c5160dc34cd2bb"+
"eec333de315133072d9354fc6c250c8e22cb24bc728a9988f18d958ce5b5113381871b1f32b9319730775c4c59eacd9134c0"+
"3cea9a88ab4c33d09e1e546a96b2204dc27029c2d64722633d74f27353afabbd947deb70f34c968c2fabd60ad16eaa5c8315"+
"02d9079a9810510c2b097e62ead525255042e44a8285bd63b30456924d663d6b4cd345965821fa5f134608517dfe3fff2389"+
"332dc4bff2d4426025c23f31d4ea6a87354a6aca0535fa9d31f9b9101ad3aaa29e09eb6a9e60266ca65f403a75f1c68fad97"+
"2b097e9509dde23702ecb03ad71166c2e4edadc744172d5826cbe4e74204334c82681113c4a4ca2707da63d22e0e2966a242"+
"4486494a7faaae40c56ab4ba98aa64f24c5859fbb1e5b092e43ac9969849a4277ffc3d1396a5c43349eb866126f28cd7ae93"+
"555752fab03bac24516ff4c8df08216a8e219e28dc6d56598f49226d0a6662b68961024f807fce841a2669e19c07b592f160"+
"11f49888a28c3113b8613b26c9cf99240d714c42535768d595d478402024baf2bb08336155f23113f2cec58b6370a4d3d07c"+
"5d69d1aaec46caa3b6646d15ed77752409476192c46a5842e21ca298a9ecc6df305142c0e22eaa106d95a42e032b240c0f87"+
"f03ac82b2bc424999811a273703f17a21ac9a9cc1b7efc2f57520e868d13022bc98e45bf9a89f3d8e4207e76fc6a2aba8230"+
"55d9a1d9d20981952c46abc60981958826c47df2e2d0bc2fa67fabae03784496096b16826026d95a0ac24c5868f3334a5d62"+
"497f8d09ad328e98d06c211866d20e57d3083351c6cb326111fd4526cbde7336b903ee06458b99b4fb63156326f141fc2a13"+
"1a72c7c43788d1ea6ae69bbac24c44d4e1e01a4b5b7d8bfc05260d279e8918b70c3369b7bb3ac44cdc36d1ea82c7d8bfc684"+
"4df91231498a8a6226e162b08d3113b54d1c93e06f99c486095f8d7b21ad709e573d26b3893c7a71f63f499865c2d8df30d1"+
"a5934a5d6ea6825197dc265d8f09ef07d798f18ede9f27e48388a7b68c426f807456a17a5d0901726a94e0f134da21d23946"+
"1247f4efc0ab60a4fcb0a6a915a21f7f99cee4b68350721b3590548c10982afeb74284b69184e5792f8d92cee495d20a8195"+
"046dd8bb75d9fecc507afdb72b3930f3f5863c9a2efb7e76d13127441f21e8d1a4fc7f4b359af557d415ebf8a056172bafc8"+
"c0804752cce21e13e607a9290f8f935f64c2e555c13371393fab2ed64cfb017b06857e968988ff5608334c92e194f7678e09"+
"8299c80fb69f6d3c181bc37e92db704238b54cc222bbc9f92d128a99507e4285f254d574fe2213aeb3715a5df224663d26d0"+
"d70e3331afe31d131eff22135a869889dd264e5dfc769ba4d0dcd132f9491cbd075e0d33ab3013b9f1598f495c86fde44765"+
"96fc2bfb24b0e79608b33dbfd9260deb3161683fc24a84fae83f5017f928bc3635014b1e0a0a4f176fde47f38f941518cb13"+
"057f779e9890671c97dc0a7997f3d3f9fec34d0cd4543040ce54b0bf17a2da3aaa8ea54e880e3c56efc2dbd83e0701b40a03"+
"21f4178430418c2fc866839b7773d3fe5fdb562ec4a88b72f542fe57d445c38a3926acead711905e9db07d608a9854f45799"+
"e8178e565dfd9c9f0aeddc0a2ac3d832a14bfacb4ce2728999e0f8bc09455501b60571a2df62b39f860751c771c324384efa"+
"cf4d4f593fb84613f7125ba90b0a537f9549c43d93b4e87f541f6e13e299c078875f6322da163379b74d7c4d9f5d51b50c1c"+
"93f49799406f4ccc24cd4eb729ec10b732964b10b68061f9f74204b14cf8aaf7269f88597bf35155078a98b8e2ab1f7f6fbc"+
"c0ef0e6c697ec0bbe16d76a3496eff068f991d1df23797df7e9d41678584098378e08df16a39aef9a4e6f451169afdb210e8"+
"f7098d04b4909be4a22d15e60eb68a1324a6b3d0af0961e6c9a83c422a2744071e6fa984d0599551ab2e35d4f417851c9863"+
"12ee873729b3a6bc111445c23311e29799305b9da4d445db5b47eb8404c14ab8b6314a5df13f61a29c5bc784d981b5fea33a"+
"050431a14bed30fdaabaa861c2aa6c8999b0a8eba72094438498c09cce5f152212ea98b4ab31fbf93649a3d481879ec6bfbc"+
"12318e1193f4769ba4689ba822b836b2e0e9e7d51e1fa84b8fa9744cde6f9313a79809943eff0e93601ac698493cadde6f13"+
"c404a6c97f2ce443c1317c29e60706d7457848d144fba44d28521515917db5a3b415fcf8f1cb3b25732b60cb4337bcc9cd89"+
"ca182b489ac0ff410583d616fb7521707b37e5815208ac4474d1ed5607df510bd1494046e92f38f53d2150d4089f9111a293"+
"8b37a7b1fcae0475213cd5d1f69785a431b14c68386e0f98092b5bdcc39ec1ce219e49f20fd4b5ac986712eeb7fca658a965"+
"0433d1956aff9c496adf1a6875491b736bbc5414da318124e0ef3091d74d461013482ede082a13ea993078f2f2cb4238734c"+
"58d671cc44fedc253e7a19ab5a5b17a298fcfa4a689850cfa49bf75a32b86de2989824a06212fc137571ebcf6b75ddd6a4aa"+
"331e33d167fc3f67c2546da46712dfba78ec14c68849507e9630fdd86ac22b0f2a742aac913f9ac62997b7f4349610c2d901"+
"ba1e42d9230de0d75f9a660d4a5be2c78f5fa7721046883219853c24ad10d0129f56c20ab14940fd05d37f2244fe6454ec2c"+
"57520e178913022b494e0d0b50cfe130fa0d217225acb4cfeeb5bac271163821b01264f7a5ba581afc1321823926899a2fe7"+
"9988ae097a4c744748c34404ff60256abe45e0db7f86698f499b25316602150c9a09fb47eaa28702b5a388f97858c69889a8"+
"66210df09b17fe7b4c96f6faa9d5b5ccea90612669d4063d26f49f0849a965424b38a81093b0d05d74adba741332cb24f927"+
"ea8aa17b8efd2d83ac159889dc26518099a833feb7989425f251e276383ef498f0aca19889a8d86f3111ad751eb4baa2bb69"+
"dc63c29b10a5055407868f8590cf23ab90a29776abaad0c0f72016d558da14e653b5d06856859fc93f387d5de18f1662c227"+
"cc09813fe1b4576006a5d38c927f60e99db77ae031f5c63d68226685c4b092204a7b31af4340ffb910c0326dfa1d0b6659ea"+
"8450d70dc144ebe55ffd53755926a24a0966c28b198f311368f0ff9b4c60328f6542b90a9b7b2669d3895efa3c8dc4ef3161"+
"518c98d0431953cc84f15e5e565eee28f92d26bc57944ac11cc79809b53645ab2b4e7e4708242da20adf4702d1ca6d8299e8"+
"31159a098dff991098cc639998f6049e4958440c33618784fe16132a428a980460423013714a71cc8b45c96f32697b215b1a"+
"4f1bd16362b78956174d3ecd037d5e7babd0d258c70bf17bf850f4af12fca090d07f746699ed986a216a2f57e1cd1dfb8005"+
"c9bb901e5141fea910a91e28228a297339bfdbf0b615a4fdee84fd8e1098dfdc2494e11165ef04c55608dc1ad96f09912be1"+
"d3dbdbdc8da018fa89fc269338764ca46dbac90cf09e207917e2e43799a84a76cb84f2d3cdb571e9db3da9b8734a7f8f090d"+
"c31831a149f4a120c3841de8ef3229fb410f13cec6f7536ec1d37f0c5e55f21826a7e83debde439432fecd7dc254f8cfaaeb"+
"27dbc43061bfc98449b38e987c26c8a8eb6610c62f192f65be74a13bc77d048838f4dee9d3b4348f69fe31779542a5f6254e"+
"5adedeb1b94f648147bf5cd2df14a21f698310e56847877736851a216af04dfa7b42205b115821daa61c6e3303d6a307bfec"+
"3785a8a45f497bfd36c2432f8e0e9531ff0313e69884e8e1bcdd810433510f377e4f5d21434cd2f0c6a6243a9e64d4c522f6"+
"bb4c046788c97b4160531c93f4f79904252788091561ef71260b9203fd1f9850cb84760da31f6d13ab2ed5f3fb37c11f1093"+
"7727226c13c404521bbfb71268f888987cb01f8567c27ec284fcdd45989a2b082166845b7c88cd8c355d6ba21ee891dfd396"+
"13a2ae0e4dea842841f24a6285103d14fdb78524fafd8bf6449b32a0f84fda722744de1cd2df5f09b70d0d94ba82907b21b0"+
"92838eaffcefea326977ab2ea64e75cf84c14dfe4f30d18569880957a90dc7043ee03fc2240c39c3485814c59e09e5f16faf"+
"8445eeaa0e2b4954edab6702cf74fe0c132e086202cfe4689f09237f82093430ed31d15eb66342f9f27f1022a86322b78960"+
"fd6d9250cf44ba69bfbd92386288490c081013f991a58ec9cfdf39fcadc1a761ea7b91c015143297cc1d32f22cfb5d87089f"+
"2a6a501a7342e0cfb25ca2930cee19ff8b10e62a066972600c0d3895df990d2092df70e9fb2e5e4c50e823aadc8053e6e22b"+
"94fcefea121143792c23c833618794fc1126a6c782632205e1cc068b823f01dedc147a4c7ca1ecef3aa90e3c6788893ca87a"+
"4cf415e54f30f1bd2c54e4393d708a99c421fb334c4c8f05a7ae34e43d8fef379dd4774ce042dd63b274afa9e9ef3aa9ce46"+
"2e1113795005143131e33f7f8109f9fbc530380429725351f9a0745422f6bf2171013676138e88dd1545bd2059fe1121c429"+
"0745f1383342fef795982a0beaee3e3d7798d33f2284ea767c14dd7d70a90f4938fd334ce8f2a66301b7cd82d42253f1a798"+
"a0788aabb2fd634c12ea99d83cacbf710bf287984431414cf036010151fa879898d713efb6895617e3ec4f31f9689bfc3126"+
"c233b9dd26d41424ffbd10f24b76d21a637d9b8ba91da6099d7fffe70fd82505135784aad20c223231af7f9e39f969b283a4"+
"49ec84a84b5744ffbc10dbfed3be4422e659fd1f12020d9b3c137b6dd4eafa031fb04b0a1e04414c58c8d9bfc204da4ef599"+
"24e45f6102f3121113b837fc3121daaf36ea0aa2183181c6a97f6825d4750752ea52dbe45f61122429414c5862d7f78799c8"+
"13926126c161f98b4c7e355da02d95f25b4261ee1484901f7ff40f44d7b410580a6cfd7f41887e96431c147dcaff7121f09b"+
"0be90f1b21203049ff0521eaaa7b08d9bfc6842226901eff7798c07436cf848a84917f850985db9c67c278f02f318923f1af"+
"314911139a44ec5f11a26ba010139efe4b4c8230404c88e0bf6a1dc93fdcf7d42454fff42a6e84d8bbd0bf25c4c68ae1ff13"+
"ffda4aec45f8df5697bb45fedb4cd482fe2d21d433a1fc5f1362039cffb6bad82120ff5f98a407f6ef0b5111fa7f6d33f294"+
"fe1693ff27c000e0613049c92db2d40000000049454e44ae426082";
}
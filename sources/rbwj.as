package  {
    import flash.display.Sprite;
    import flash.display.MovieClip;
    import flash.events.Event;
    import flash.display.Shape;
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.geom.Matrix3D;
    import flash.geom.PerspectiveProjection;
    import flash.geom.Point;
    import flash.geom.Vector3D;
    import flash.utils.*;
    import flash.geom.Utils3D;
    import flash.display.TriangleCulling;
    import flash.display.Loader;
    import flash.net.URLRequest;
    import flash.system.LoaderContext;
    
    import flash.filters.BlurFilter;
    import flash.filters.GlowFilter;
    import flash.events.MouseEvent;
    import flash.events.KeyboardEvent;
    import net.hires.debug.Stats;
    import com.bit101.components.HSlider;
    import flash.display.Shader;
    import flash.filters.ShaderFilter;
    import flash.utils.ByteArray;
    import flash.geom.Matrix;
    import com.bit101.components.HUISlider;
    
    public class tunnelV02 extends Sprite
    {
        // terrain
        private var W              :int        = 40;//15;
        private var H              :int        = 50;//30;
        private var SW             :Number     = 800;
        private var SH             :Number     = 960;
        private var GW             :Number     = SW/W;
        private var GH             :Number     = SH/H;
        private var MW             :Number     = 80;
        private var MH             :Number     = 120;
        private var TW             :Number     = (MW)/W-1;
        private var TH             :Number     = (MH)/H-1;
        private var TERRIAN_MAP    :BitmapData = new BitmapData(MW, MH, false);
        private var MAP            :BitmapData;
        
        // 3D
        private var viewport       :Shape                 = new Shape();
        private var world          :Matrix3D              = new Matrix3D();
        private var projected      :Vector.<Number>       = new Vector.<Number>;
        private var projection     :PerspectiveProjection = new PerspectiveProjection();
        private var TRANS          :Matrix3D              = new Matrix3D();
        private var VERTS          :Vector.<Number>       = new Vector.<Number>;
        private var INDICES        :Vector.<int>          = new Vector.<int>;
        private var UVTS           :Vector.<Number>       = new Vector.<Number>;
        
        private var offset         :Point  = new Point();
        private var loader         :Loader;
        private var GRAPHIC_URL    :String = "http://assets.wonderfl.net/images/related_images/f/fd/fd61/fd61859a0846c3b23cba2abd8b6ff3d3e1b21b68m";//"ballt.jpg"; //cloud map
        
        
        // interaction
        private var dragging       :Boolean  = false;
        private var drag_mode      :Boolean  = false;
        private var old_mouse      :Point    = new Point();
        private var new_mouse      :Point    = new Point();
        private var trans          :Matrix3D = new Matrix3D();
        private var zoomer         :Number   = 750;
        private var zoomVelocity   :Number   = 0;
        private var zoomIn         :Boolean  = false;
        private var zoomOut        :Boolean  = false;
        
        // settings
        private var baseX   :Number = 15;
        private var baseY   :Number = 30;
        private var Octaves :Number = 8;
        private var speed   :Number = 0.5;
        
        private var baseXHSlider   :HUISlider;
        private var baseYHSlider   :HUISlider;
        private var octavesHSlider :HUISlider;
        private var speedHSlider   :HUISlider;
        
        // sunshine :)
        private var matrix    :Matrix3D = new Matrix3D();
        private var SCALE     :Number       = 4; // scale bitmap, less quality for light, but save processing
        private var pbjLoader :Loader;
        private var shine     :ShaderFilter;
        private var innerMap  :BitmapData   = new BitmapData(stage.stageWidth/SCALE, stage.stageHeight/SCALE, true, 0x0);
        private var light     :Vector3D     = new Vector3D(0,0.1,0);
        private var bitmapM   :Matrix       = new Matrix();
        
        private var fx:VolumetricPointLight;
        private var _t:Number = 0;
        private var _halfWidth:uint;
        private var _halfHeight:uint;

        
        public function tunnelV02()
        {
            loader = new Loader();
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, init);
            loader.load(new URLRequest(GRAPHIC_URL), new LoaderContext(true));
        }
        
        private function init(e:Event):void
        {
            // constructor code
            var mouse:MovieClip = new MovieClip();
            mouse.scaleX = SCALE;
            mouse.scaleY = SCALE;
            //mouse.addChild(new Bitmap(innerMap));
            
            //mouse.x = (stage.stageWidth-innerMap.width)/2;
            //mouse.y = (stage.stageHeight-innerMap.height)/2;
            viewport.x = stage.stageWidth / 2;
            viewport.y = stage.stageHeight / 2;

            //addChild(viewport);
            //viewport.filters = [shine];  // too lag
            buildPath();
            
            MAP = Bitmap(loader.content).bitmapData;
            bitmapM.translate(stage.stageWidth/2, stage.stageHeight/2);
            bitmapM.scale(1/SCALE, 1/SCALE);
            matrix.appendRotation(30, Vector3D.X_AXIS);
            trans.appendRotation(120, Vector3D.X_AXIS);
            trans.appendRotation(25, Vector3D.Y_AXIS);
            
            var panel:Sprite = new Sprite();
            addChild(mouse);
            addChild(panel);
            addChild(new Stats());
            baseXHSlider = new HUISlider(panel, 80, 20, "baseX", updateBaseX);
            baseXHSlider.value = baseX;
            baseYHSlider = new HUISlider(panel, 80, 35, "baseY", updateBaseY);
            baseYHSlider.value = baseY;
            octavesHSlider = new HUISlider(panel, 80, 50, "Octaves", updateOctaves);
            octavesHSlider.value = (Octaves-1) * 10;
            speedHSlider = new HUISlider(panel, 80, 65, "speed", updateSpeed);
            speedHSlider.value = speed * 10;
            
            mouse.addEventListener(MouseEvent.MOUSE_DOWN, onmouseDown);
            stage.addEventListener(MouseEvent.MOUSE_UP, onmouseUp);
            stage.addEventListener(MouseEvent.MOUSE_MOVE, onmouseMove);
            stage.addEventListener(KeyboardEvent.KEY_DOWN, onkeyDown);
            stage.addEventListener(KeyboardEvent.KEY_UP, onkeyUp);
            stage.addEventListener(Event.ENTER_FRAME, processing);
            loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, init);
            var w:int = stage.stageWidth;
            var h:int = stage.stageHeight;
            _halfWidth = w >> 1;
            _halfHeight = h >> 1;
            //var tempSprite:Sprite = new Sprite();
            //tempSprite.addChild(innerMap);
            fx = new VolumetricPointLight(465, 465, new Bitmap(innerMap),[0xEFBFAA,0xFBECDF,0xffffff, 0xffffff, 0xffffff],[1,0.95,0.6,0.3,0.0]);//, 0x46497c]);//[0x6a4b00,0x000f13,0x0, 0x130013, 0x0]
            mouse.addChild(fx);
            fx.startRendering();
        }
        
        private function updateBaseX(...arg):void
        {
            baseX = baseXHSlider.value;
        }
        
        private function updateBaseY(...arg):void
        {
            baseY = baseYHSlider.value;
        }
        
        private function updateOctaves(...arg):void
        {
            Octaves = 1+(octavesHSlider.value/10)/10*9;
        }
        
        private function updateSpeed(...arg):void
        {
            speed = (speedHSlider.value/10);
        }
        
        private function buildPath():void
        {
            
            var w:int = 0;
            var h:int = 0;
            var xA    :Number = 0;
            var xB    :Number = 0;
            var yA    :Number = 0;
            var yB    :Number = 0;
            var zA    :Number = 0;
            var zB    :Number = 0;
            var index:int = 0;
            var i0:int = 0;
            var i1:int = 0;
            var i2:int = 0;
            var i3:int = 0;
            for(h = 0; h < H; h++)
            {
                for(w = 0; w < W; w++)
                {
                    xA = -SW/2 + w*GW;
                    xB = -SW/2 + (w+1)*GW;
                    zA = -SH/2 + h*GH;
                    zB = -SH/2 + (h+1)*GH;
                    
                    VERTS.push(
                        xA, yA, zB//, //0        //0
                        //xB, yA, zB, //1        //1
                        //xA, yB, zA, //2        //2
                        //xB, yB, zA  //3        //3
                    );
                    
//                    index = (W*h + w) * 4;
//                    i0 = index;
//                    i1 = index +  1;
//                    i2 = index +  2;
//                    i3 = index +  3;
                    if(w+1 < W && h+1 < H)
                    {
                        index = (W*h + w);
                        i0 = (W*h + w);
                        i1 = (W*h + (w+1));
                        i2 = (W*(h+1) + w);
                        i3 = (W*(h+1) + (w+1));
                        
                        INDICES.push( 
                            i0,  i1,  i2, // 3
                            i1,  i3,  i2  // 6
                        );
                    }

                    UVTS.push(
                        ((w)  *TW+1)/MW, ((h)*TH)/MH, 0//,
                        //((w+1)*TW+1)/MW, ((h+1)*TH)/MH, 0, 
                        //((w)  *TW+1)/MW, ((h)  *TH)/MH, 0,
                        //((w+1)*TW+1)/MW, ((h)  *TH)/MH, 0
                    ); // redundant
                }
            }
        }
        
        private function processing(e:Event):void
        {
            
            _t += .01 * Math.random();
            var px:Number = _halfWidth * (1 + Math.cos(4 * _t));
            var py:Number = _halfHeight * (1 + Math.sin(5 * _t));
            //fx.srcX = px;
            //fx.srcY = py;
            if(zoomIn) zoomVelocity+=1;
            if(zoomOut) zoomVelocity-=1;
            zoomVelocity *= 0.98;
            zoomer += zoomVelocity;
            
            TERRIAN_MAP.perlinNoise(baseX,baseY,Octaves,100, false, true, 8, true, [offset, offset]);
            
            var w:int = 0;
            var h:int = 0;
            var q:int = 0;
            var k:int = 0;
            var r:Number = 0;
            var index:int = 0;
            var i0:int = 0;
            var i1:int = 0;
            var i2:int = 0;
            var i3:int = 0;
            
            var VX:Number = 0;
            var VY:Number = 0;
            var VZ:Number = 0;
            var VLEN:Number = 0;
            
            var ViX:Number = 0;
            var ViY:Number = 0;
            var ViZ:Number = 0;
            
            for(h = 0; h < H; h++)
            {
                for(w = 0; w < W; w++)
                {
                    r = TERRIAN_MAP.getPixel((w*TW), (h)*TH) & 0xFF;
                    index = (W*h + w)*3;
                    ViX = VERTS[index];
                    ViY = -130 + 200 * (r/0xFF);
                    ViZ = VERTS[index+2];
                    VERTS[index+1] = ViY;
                    VX = ViX;
                    VY = ViY/Math.abs(ViY) * (ViY * ViY);
                    VZ = ViZ;
                    VLEN = Math.sqrt(VX*VX+VY*VY+VZ*VZ);
                    UVTS[index] = 0.5+VX/VLEN*0.5;
                    UVTS[index+1] = 0.5+VY/VLEN*0.5;
                }
            }
            
            offset.y-=speed;

            world.identity();
            world.append(trans);
            var nv:Vector3D = world.transformVector(light);
            world.appendTranslation(0, 0, zoomer);
            world.append(projection.toMatrix3D());
            
            fx.srcX = nv.x*850+innerMap.width/2;
            fx.srcY = nv.y*850+innerMap.height/2;
            
            var _UVTS:Vector.<Number> = new Vector.<Number>;
            matrix.transformVectors(UVTS,_UVTS);
            
            Utils3D.projectVectors(world, VERTS, projected, _UVTS);
            
            viewport.graphics.clear();
            
            viewport.graphics.beginBitmapFill(MAP, null, false, false);
            viewport.graphics.drawTriangles(projected, INDICES, _UVTS, TriangleCulling.NONE);  //NEGATIVE
            //viewport.graphics.drawTriangles(projected, INDICES, _UVTS, TriangleCulling.NEGATIVE);  //NEGATIVE
            viewport.graphics.endFill();
            
            innerMap.fillRect(innerMap.rect, 0x0);
            innerMap.draw(viewport, bitmapM);
            //innerMap.applyFilter (innerMap, innerMap.rect, innerMap.rect.topLeft, shine);
            //innerMap.threshold(innerMap, innerMap.rect, new Point, ">=", 0xFDF6D3, 0x0, 0xFFFFFF, true);//0xFDE6B3//
        }
        
        private function onmouseDown(e:MouseEvent):void
        {
            old_mouse.x = mouseX;
            old_mouse.y = mouseY;
            dragging = true;
        }
        
        private function onmouseMove(e:MouseEvent):void
        {
            if(dragging)
            {
                
                new_mouse.x = mouseX
                new_mouse.y = mouseY;
                
                var difference:Point = new_mouse.subtract(old_mouse);
                var vector:Vector3D = new Vector3D(difference.x, difference.y, 0);
 
                var rotationAxis:Vector3D = vector.crossProduct(new Vector3D(0,0,1));
                rotationAxis.normalize();
 
                var distance:Number = Point.distance(new_mouse, old_mouse);
                var rotationMatrix:Matrix3D = new Matrix3D();
                rotationMatrix.appendRotation(distance, rotationAxis);
                
                trans.append(rotationMatrix);
 
                old_mouse.x = new_mouse.x;
                old_mouse.y = new_mouse.y;
            }
        }
        
        private function onmouseUp(e:MouseEvent):void
        {
            dragging = false;
        }
        
        private function onkeyDown(e:KeyboardEvent):void
        {
            switch(e.keyCode)
            {
                case 107:
                    zoomIn = true;
                    break;
                case 189:
                    zoomOut = true;
                    break;
            }
            
        }
        
        private function onkeyUp(e:KeyboardEvent):void
        {
            switch(e.keyCode)
            {
                case 107:
                    zoomIn = false;
                    break;
                case 189:
                    zoomOut = false;
                    break;
            }
            
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
    private var cT:ColorTransform =  new ColorTransform(1,1,1,0.96);
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
        //emission.alpha = 0.3;
           if(occlusion) addChild(_occlusion = occlusion);
        //_occlusion = occlusion;
        setViewportSize(width, height);
        _lightBmp.blendMode = BlendMode.ADD;
        addChild(_lightBmp);
    //    addChild(Bitmap(_baseBmd));
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
        //_drawLoResEmission();
        //if(_occlusion) _eraseLoResOcclusion();
        
        _copyMatrix(_emission.transform.matrix, _mtx);
        _mtx.scale(_bufferWidth / _viewportWidth, _bufferHeight / _viewportHeight);
        _baseBmd.fillRect(_baseBmd.rect, 0x0);
        _baseBmd.draw(_occlusion, _mtx);
        _baseBmd.threshold(_baseBmd, _baseBmd.rect, new Point, "<", 0xFDF6D3, 0x0, 0xFFFFFF, true);
        _baseBmd.colorTransform(_baseBmd.rect, _ct);
        
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
        _baseBmd.fillRect(_baseBmd.rect, 0x0);
        _baseBmd.draw(_emission, _mtx, colorIntegrity ? null : _ct);
    }

    /**
    * Draws a scaled-down occlusion on _occlusionLoResBmd and erases it from _baseBmd.
    */
    protected function _eraseLoResOcclusion():void {
        _occlusionLoResBmd.fillRect(_occlusionLoResBmd.rect, 0x0);
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
            if(!alphas) _alphas = _colors.map(function(..._):Number { return 1 }); else _alphas = alphas;
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
        _gradientLoResBmd = new BitmapData(_bufferWidth, _bufferHeight, false, 0x0);
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

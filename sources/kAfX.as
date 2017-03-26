// forked from k3lab's Grid
package {
	import flash.display.*;
	import flash.events.*;

	[SWF(width="465", height="465", backgroundColor="0", frameRate="30")]
	public class PointLightDemo extends Sprite {
		private var fx:VolumetricPointLight;
		private var grid:Grid = new Grid;
		private var sun:SunIcon = new SunIcon;

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
			fx = new VolumetricPointLight(800, 600, grid, [0xc08040, 0x4080c0, 0], [1, 1, 1], [0, 20, 30]);
			// You can also specify a single color instead of gradient params, for example:
			//   fx = new VolumetricPointLight(800, 600, grid, 0xc08040);
			// is equivalent to:
			//   fx = new VolumetricPointLight(800, 600, grid, [0xc08040, 0], [1, 1], [0, 255]);

			addChild(fx);
			// Render on every frame.
			fx.startRendering();

			onResize(null);
			stage.addEventListener(Event.RESIZE, onResize);

			// Sun icon used to control light source position
			addChild(sun);
			sun.buttonMode = true;
			sun.addEventListener(MouseEvent.MOUSE_DOWN, function(e:Event):void { sun.startDrag(); });
			sun.addEventListener(MouseEvent.MOUSE_UP, function(e:Event):void { sun.stopDrag(); });
			addEventListener(Event.ENTER_FRAME, function(..._):void { fx.srcX = sun.x; fx.srcY = sun.y; });
		}

		private function onResize(e:Event):void {
			var w:Number = stage.stageWidth;
			var h:Number = stage.stageHeight;
			fx.setViewportSize(w, h);
			sun.x = fx.srcX = w/2;
			sun.y = fx.srcY = h/2;
			grid.x = w/2-232;
			grid.y = h/2-232;
		}
	}
}

import flash.display.*;
import flash.filters.*;

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
			if(!ratios)	_ratios = colorOrGradient.map(function(item:*, i:int, arr:Array):int { return 0x100*i/(colorOrGradient.length+i-1) });
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

/**
* Copyright k3lab ( http://wonderfl.net/user/k3lab )
* MIT License ( http://www.opensource.org/licenses/mit-license.php )
* Downloaded from: http://wonderfl.net/c/ptmi
*/

import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Matrix;
import flash.geom.Point;
class Grid extends Sprite
{
    private var test:Sprite
    private var lines:Sprite;
    private  var _pont:Point
    private  var Arrays:Array;
    private  var SQ:Array;

    private var diff:Number
    private var radian:Number
    private var diffPoint:Point
    private var Reaction:uint = 175;
    private var spring:Number = 0.3
    private var friction:Number = 0.68;
    public function Grid():void {
		if (stage) init();
		else addEventListener(Event.ADDED_TO_STAGE, init);
	}
	private function init(e:Event = null):void {
		removeEventListener(Event.ADDED_TO_STAGE, init);
		// entry point
		Arrays = []
		SQ=[]
		for (var i:int = 0; i < 6; i++ ) {
			for (var j:int = 0; j < 6; j++ ) {
				var _point:Points = new Points(95 * i, 95 * j);
				Arrays.push(_point)
				var test:Sprite = addChild(new Sprite()) as Sprite;
				test.graphics.beginFill(0x101010);
				test.graphics.drawCircle(0, 0, 20);
				test.graphics.endFill();
				SQ.push(test)
			}
		}
		lines = addChild(new Sprite()) as Sprite;
		addEventListener(Event.ENTER_FRAME, enter);
	}
	private function enter(e:Event):void {
		var mousePoint:Point = new Point(mouseX, mouseY);
		var i:int;
		for each (var _point:Points in Arrays) {
			_point.update(mousePoint,  Reaction, spring, friction);
			SQ[i].x = _point.x;
			SQ[i].y = _point.y
			i++;
		}
		lines.graphics.clear();
		lines.graphics.lineStyle (20, 0x101010, 1);
		for (var n:int = 0; n < 36; n++ ) {
			lines.graphics.beginFill(0x000000,Math.min(1,distance/350))
			lines.graphics.moveTo(SQ[n].x, SQ[n].y);
			var distance:Number = Point.distance(mousePoint, new Point(SQ[n].x+47, SQ[n].y+47));
			if (n < 30) {
				lines.graphics.lineTo( SQ[(n + 6)].x, SQ[n + 6].y);
				if(n%6){
					lines.graphics.lineTo( SQ[(n + 5 )].x, SQ[n + 5].y);
					lines.graphics.lineTo( SQ[(n - 1 )].x, SQ[n - 1].y);
				}
				if(n==2||n==1){
					lines.graphics.lineTo( SQ[(n-1)].x, SQ[n - 1].y);
					lines.graphics.lineTo(SQ[n].x, SQ[n].y);
				}
			}
		}
		lines.graphics.endFill()
	}

}


import flash.geom.Point;
class Points {
    private var localX:Number;
    private var localY:Number;
    private var vx:Number = 0;
    private var vy:Number = 0;
    private var _x:Number;
    private var _y:Number;
    public function Points(x:Number, y:Number) {
        _x = localX = x;
        _y = localY = y;
    }
    public function update(mousePoint:Point, Reaction:uint, spring:Number, friction:Number):void {
        var dx:Number;
		var dy:Number;
        var distance:Number = Point.distance(mousePoint, new Point(localX, localY));
        if (distance < Reaction) {
            var diff:Number     = distance * -1 * (Reaction - distance) / Reaction;
            var radian:Number   = Math.atan2(mousePoint.y - localY, mousePoint.x - localX);
            var diffPoint:Point = Point.polar(diff, radian);
            dx = localX + diffPoint.x;
            dy = localY + diffPoint.y;
        } else{
            dx = localX;
            dy = localY;
        }
        vx += (dx - _x) * spring;
        vy += (dy - _y) * spring;
        vx *= friction;
        vy *= friction;
        _x += vx;
        _y += vy;
    }
    public function get x():Number { return _x; }
    public function get y():Number { return _y; }
}

package  
{
	import com.flashdynamix.utils.SWFProfiler;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.ColorMatrixFilter;
	
	/**
	 * 元ネタ http://abduzeedo.com/super-cool-abstract-vectors-illustrator-and-photoshop
	 * 解説 http://ferv.jp/blog/2009/11/03/colormatrixfilter/
	 * 
	 * @langversion ActionScript 3.0
	 * @playerversion Flash 10.0
	 * 
	 * @author dsk
	 * @since 2009/11/01
	 */
	[SWF(backgroundColor = '0x000000', width = '465', height = '465', frameRate = '30')]
	public class Flowers extends Sprite 
	{
		
		//--------------------------------------
		// CLASS CONSTANTS
		//--------------------------------------
		
		
		//--------------------------------------
		// PRIVATE VARIABLES
		//--------------------------------------
		
		private var _bitmap:Bitmap;
		private var _background:Bitmap;
		private var _rotation:Number;
		
		
		//--------------------------------------
		// GETTER/SETTERS
		//--------------------------------------
		
		
		//--------------------------------------
		// CONSTRUCTOR
		//--------------------------------------
		
		public function Flowers() 
		{
			SWFProfiler.init(this);
			
			_rotation = 0;
			
			var i:int, flower:Flower;
			for (i = 4; i >= 0; i --) {
				flower = new Flower(20 * i + 80);
				flower.x = stage.stageWidth / 2;
				flower.y = stage.stageHeight / 2;
				flower.blendMode = BlendMode.SCREEN;
				addChild(flower);
			}
			
			_bitmap = new Bitmap(BitmapDataUtil.capture(this));
			_background = new Bitmap(new BitmapData(stage.stageWidth, stage.stageHeight, false, 0));
			while (numChildren > 0) removeChildAt(0);
			
			addChild(_background);
			addChild(_bitmap);
			
			addEventListener(Event.ENTER_FRAME, _onEnterFrame);
		}
		
		
		//--------------------------------------
		// PUBLIC METHODS
		//--------------------------------------
		
		
		//--------------------------------------
		// PRIVATE METHODS
		//--------------------------------------
		
		private function _onEnterFrame(e:Event):void 
		{
			_rotation += Math.PI / 180;
			
			var cos0:Number = (Math.cos(_rotation) + 1) / 2;
			var cos1:Number = (Math.cos(_rotation + Math.PI * 2 / 3) + 1) / 2;
			var cos2:Number = (Math.cos(_rotation + Math.PI * 4 / 3) + 1) / 2;
			
			_bitmap.filters = [new ColorMatrixFilter([
				cos0, cos1, cos2, 0, 0,
				cos2, cos0, cos1, 0, 0,
				cos1, cos2, cos0, 0, 0,
				0, 0, 0, 1, 0
			])];
		}
		
		
	}
	
	
}



	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.GraphicsPath;
	import flash.display.GraphicsPathCommand;
	import flash.display.GraphicsSolidFill;
	import flash.display.IGraphicsData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	internal class Flower extends Sprite 
	{
		private const PETALS_LENGTH:int = 24;
		
		private var _petals:Vector.<Petal>;
		
		public function Flower(radius:Number) 
		{
			_petals = new Vector.<Petal>();
			var i:int, rotation:Number, hsv:HSV, petal:Petal;
			for (i = 0; i < PETALS_LENGTH; i ++) {
				rotation = 360 * i / PETALS_LENGTH;
				
				hsv = new HSV();
				hsv.hue = rotation;
				hsv.saturation = 1;
				hsv.value = 1;
				
				petal = new Petal(radius, hsv.color);
				petal.alpha = 0.1;
				petal.rotation = rotation;
				_petals[i] = petal;
				
				addChild(petal);
			}
		}
	}
	
	internal class Petal extends Shape 
	{
		public function Petal(radius:Number, color:uint) 
		{
			var anchorX:Number = (1 - Math.SQRT1_2) * radius;
			var anchorY:Number = Math.SQRT1_2 * radius;
			var handleY:Number = Math.sin(Math.PI / 8) * radius;
			
			graphics.drawGraphicsData(Vector.<IGraphicsData>([
				new GraphicsSolidFill(color, 1),
				new GraphicsPath(
					Vector.<int>([
						GraphicsPathCommand.MOVE_TO,
						GraphicsPathCommand.CURVE_TO,
						GraphicsPathCommand.CURVE_TO,
						GraphicsPathCommand.CURVE_TO,
						GraphicsPathCommand.CURVE_TO
					]),
					Vector.<Number>([
						0, 0,
						-anchorX, -anchorY + handleY, -anchorX, -anchorY,
						-anchorX, -anchorY - handleY, 0, -anchorY * 2,
						anchorX, -anchorY - handleY, anchorX, -anchorY,
						anchorX, -anchorY + handleY, 0, 0
					])
				)
			]));
		}
	}
	
	internal class BitmapDataUtil 
	{
		public static function capture(source:DisplayObject, fillColor:uint = 0x00000000, extra:int = 0):BitmapData 
		{
			var temp:BitmapData = new BitmapData(source.width + extra * 2, source.height + extra * 2, true, 0x00000000);
			var extraMatrix:Matrix = new Matrix();
			extraMatrix.translate(extra, extra);
			temp.draw(source, extraMatrix);
			
			var colored:Rectangle = temp.getColorBoundsRect(0xFF000000, 0x00000000, false);
			var bitmapData:BitmapData = new BitmapData(colored.width, colored.height, true, fillColor);
			var matrix:Matrix = new Matrix();
			matrix.translate(-colored.x, -colored.y);
			bitmapData.draw(temp, matrix);
			
			temp.dispose();
			
			return bitmapData;
		}
	}
	
	internal class HSV 
	{
		
		//--------------------------------------
		// CLASS CONSTANTS
		//--------------------------------------
		
		
		//--------------------------------------
		// PRIVATE VARIABLES
		//--------------------------------------
		
		private var _color:uint;
		private var _hue:Number;
		private var _saturation:Number;
		private var _value:Number;
		
		//--------------------------------------
		// GETTER/SETTERS
		//--------------------------------------
		
		public function get color():uint { return _color; }
		public function set color(value:uint):void 
		{
			_color = value;
			_updateHSV();
		}
		
		public function get hue():Number { return _hue; }
		public function set hue(value:Number):void 
		{
			_hue = value;
			_updateColor();
		}
		
		public function get saturation():Number { return _saturation; }
		public function set saturation(value:Number):void 
		{
			_saturation = value;
			_updateColor();
		}
		
		public function get value():Number { return _value; }
		public function set value(value:Number):void 
		{
			_value = value;
			_updateColor();
		}
		
		
		//--------------------------------------
		// CONSTRUCTOR
		//--------------------------------------
		
		public function HSV(color:uint = 0x000000) 
		{
			_color = color;
			_updateHSV();
		}
		
		public function clone():HSV 
		{
			return new HSV(_color);
		}
		
		
		//--------------------------------------
		// PUBLIC METHODS
		//--------------------------------------
		
		public function toString():String 
		{
			return '[HSV' + 
				   ' color=' + toHexString() + 
				   ' hue=' + _hue.toString() + 
				   ' saturation=' + _saturation.toString() + 
				   ' value=' + _value.toString() + ']';
		}
		
		public function toHexString(length:int = 6):String 
		{
			var hex:String = _color.toString(16);
			while (hex.length < length) hex = '0' + hex;
			return '0x' + hex;
		}
		
		
		//--------------------------------------
		// PRIVATE METHODS
		//--------------------------------------
		
		private function _updateHSV():void
		{
			var rgb:RGB = new RGB(_color);
			var ratioR:Number = rgb.red / 0xFF;
			var ratioG:Number = rgb.green / 0xFF;
			var ratioB:Number = rgb.blue / 0xFF;
			
			var h:Number, s:Number, v:Number;
			var max:Number = Math.max(ratioR, ratioG, ratioB);
			var min:Number = Math.min(ratioR, ratioG, ratioB);
			var difference:Number = max - min;
			if (max == ratioR) {
				h = 60 * (ratioG - ratioB) / difference;
			} else if (max == ratioG) {
				h = 60 * ((ratioB - ratioR) / difference + 2);
			} else {
				h = 60 * ((ratioR - ratioG) / difference + 4);
			}
			if (h < 0) {
				h += 360;
			}
			s = difference / max;
			v = max;
			
			_hue = h;
			_saturation = s;
			_value = v;
		}
		
		private function _updateColor():void
		{
			var h:Number = _hue;
			var s:Number = _saturation;
			var v:Number = _value;
			
			var ratioR:Number, ratioG:Number, ratioB:Number;
			h %= 360;
			h += (h < 0)? 360: 0;
			if (h < 0 || h > 360) trace(h);
			if (s == 0) {
				ratioR = ratioG = ratioB = v;
			} else {
				var hi:Number = Math.floor(h / 60) % 6;
				var f:Number = h / 60 - hi;
				var p:Number = v * (1 - s);
				var q:Number = v * (1 - f * s);
				var t:Number = v * (1 - (1 - f) * s);
				switch (hi) {
					case 0: ratioR = v; ratioG = t; ratioB = p; break;
					case 1: ratioR = q; ratioG = v; ratioB = p; break;
					case 2: ratioR = p; ratioG = v; ratioB = t; break;
					case 3: ratioR = p; ratioG = q; ratioB = v; break;
					case 4: ratioR = t; ratioG = p; ratioB = v; break;
					case 5: ratioR = v; ratioG = p; ratioB = q; break;
				}
			}
			
			_color = Math.round(0xFF * ratioR) << 16 | Math.round(0xFF * ratioG) << 8 | Math.round(0xFF * ratioB);
		}
		
		
	}
	
	internal class RGB 
	{
		
		//--------------------------------------
		// CLASS CONSTANTS
		//--------------------------------------
		
		
		//--------------------------------------
		// PRIVATE VARIABLES
		//--------------------------------------
		
		private var _color:uint;
		private var _red:uint;
		private var _green:uint;
		private var _blue:uint;
		
		
		//--------------------------------------
		// GETTER/SETTERS
		//--------------------------------------
		
		public function get color():uint { return _color; }
		public function set color(value:uint):void 
		{
			_color = value;
			_updateRGB();
		}
		
		public function get red():uint { return _red; }
		public function set red(value:uint):void 
		{
			_red = value;
			_updateColor();
		}
		
		public function get green():uint { return _green; }
		public function set green(value:uint):void 
		{
			_green = value;
			_updateColor();
		}
		
		public function get blue():uint { return _blue; }
		public function set blue(value:uint):void 
		{
			_blue = value;
			_updateColor();
		}
		
		
		//--------------------------------------
		// CONSTRUCTOR
		//--------------------------------------
		
		public function RGB(color:uint = 0x000000) 
		{
			_color = color;
			_updateRGB();
		}
		
		public function clone():RGB 
		{
			return new RGB(_color);
		}
		
		
		//--------------------------------------
		// PUBLIC METHODS
		//--------------------------------------
		
		public function toString():String 
		{
			return '[RGB' + 
				   ' color=' + toHexString() + 
				   ' red=' + _red.toString() + 
				   ' green=' + _green.toString() + 
				   ' blue=' + _blue.toString() + ']';
		}
		
		public function toHexString(length:int = 6):String 
		{
			var hex:String = _color.toString(16);
			while (hex.length < length) hex = '0' + hex;
			return '0x' + hex;
		}
		
		
		//--------------------------------------
		// PRIVATE METHODS
		//--------------------------------------
		
		private function _updateRGB():void
		{
			_red = (_color & 0xFF0000) >> 16;
			_green = (_color & 0xFF00) >> 8;
			_blue = _color & 0xFF;
		}
		
		private function _updateColor():void
		{
			_color = _red << 16 | _green << 8 | _blue;
		}
		
		
	}










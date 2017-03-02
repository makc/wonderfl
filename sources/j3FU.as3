////////////////////////////////////////////////////////////////////////////////
// [AS3.0] MenuDockクラスに挑戦！ (2)
// http://www.project-nya.jp/modules/weblog/details.php?blog_id=1143
//
// 参考資料 : http://www.egashira.jp/as/dock1.html
////////////////////////////////////////////////////////////////////////////////

package {

	import flash.display.Sprite;

	[SWF(backgroundColor="#FFFFFF", width="465", height="465", frameRate="30")]

	public class Main extends Sprite {
		private var iconList:Array;
		private var menuDock:MenuDock;

		public function Main() {
			//Wonderfl.capture_delay(1);
			init();
		}

		private function init():void {
			var background:Background = new Background(465, 465);
			addChild(background);
			iconList = new Array();
			var icon1:Icon = new Icon(112);
			icon1.init([0x3366CC, 0x333366], "Ps", 64, 14);
			icon1.y = - 16;
			icon1.scaleX = icon1.scaleY = 0.25;
			var icon2:Icon = new Icon(112);
			icon2.init([0xFFCC00, 0xFF6600], "Ai", 64, 14);
			icon2.y = - 16;
			icon2.scaleX = icon2.scaleY = 0.25;
			var icon3:Icon = new Icon(112);
			icon3.init([0xCC0000, 0x660000], "Fl", 64, 14);
			icon3.y = - 16;
			icon3.scaleX = icon3.scaleY = 0.25;
			var icon4:Icon = new Icon(112);
			icon4.init([0x999999, 0x333333], "Fx", 64, 14);
			icon4.y = - 16;
			icon4.scaleX = icon4.scaleY = 0.25;
			var icon5:Icon = new Icon(112);
			icon5.init([0xFFCC00, 0x996600], "Fw", 64, 14);
			icon5.y = - 16;
			icon5.scaleX = icon5.scaleY = 0.25;
			var icon6:Icon = new Icon(112);
			icon6.init([0x99CC33, 0x666633], "Dw", 64, 14);
			icon6.y = - 16;
			icon6.scaleX = icon6.scaleY = 0.25;
			iconList.push({icon: icon1, label: "Photoshop"});
			iconList.push({icon: icon2, label: "Illustrator"});
			iconList.push({icon: icon3, label: "Flash"});
			iconList.push({icon: icon4, label: "Flex"});
			iconList.push({icon: icon5, label: "Fireworks"});
			iconList.push({icon: icon6, label: "Dreamweaver"});
			menuDock = new MenuDock(iconList);
			addChild(menuDock);
			menuDock.x = 232;
			menuDock.y = 465;
		}

	}

}


//////////////////////////////////////////////////
// MenuDockクラス
//////////////////////////////////////////////////

import flash.display.Sprite;
import flash.display.Shape;
import flash.events.Event;
import flash.events.MouseEvent;

class MenuDock extends Sprite {
	private var base:Shape;
	private var iconList:Array;
	private var max:uint;
	private var bWidth:uint;
	private static var iWidth:uint = 32;
	private var limit:uint;
	private var icons:Array;
	private static var scale:uint = 4;
	private static var dockBase:uint = 32;
	private static var dockTarget:uint = dockBase*scale;
	private var dockTop:uint = dockBase;
	private var limitTarget:Number = dockTarget/(scale - 1)*Math.PI/2;
	private static var offset:uint = 5;
	private static var deceleration:Number = 0.5;
	private var active:Boolean = false;

	public function MenuDock(list:Array) {
		iconList = list;
		max = iconList.length;
		limit = iWidth*max*0.5 + offset;
		icons = new Array();
		if (stage) init();
		else addEventListener(Event.ADDED_TO_STAGE, init, false, 0, true);
	}

	private function init(evt:Event = null):void {
		removeEventListener(Event.ADDED_TO_STAGE, init);
		drawBase();
		drawIcons();
		active = true;
		addEventListener(Event.ENTER_FRAME, motion, false, 0, true);
		stage.addEventListener(Event.MOUSE_LEAVE, leave, false, 0, true);
		stage.addEventListener(MouseEvent.MOUSE_OVER, over, false, 0, true);
	}
	private function motion(evt:Event):void {
		if (active) {
			if (Math.abs(mouseX) <= limit && mouseY <= 0 && mouseY >= -dockTop) {
				moveTarget();
			} else {
				moveBase();
			}
		} else {
			moveBase();
		}
		resizeBase();
	}
	private function leave(evt:Event):void {
		active = false;
	}
	private function over(evt:MouseEvent):void {
		active = true;
	}
	private function moveTarget():void {
		dockTop = dockTarget;
		for (var n:uint = 0; n < max; n++) {
		var icon:MenuDockIcon = icons[n];
		var basePos:int = iWidth*(n - (max - 1)*0.5);
		var distance:int = mouseX - basePos;
		var radian:Number = distance*(scale - 1)/dockTarget;
		if (Math.abs(distance) < limitTarget) {
			var targetScale:Number = 1 + (scale - 1)*Math.cos(radian);
			var targetPos:Number = basePos - dockTarget*Math.sin(radian);
			icon.scale += (targetScale - icon.scale)*deceleration;
			icon.x += (targetPos - icon.x)*deceleration;
		} else {
			icon.scale += (1 - icon.scale)*deceleration;
			if (distance < -limitTarget) {
				icon.x += (basePos + dockTop + 10 - icon.x)*deceleration;
			} else {
				icon.x += (basePos - dockTop - 10 - icon.x)*deceleration;
			}
		}
		}
	}
	private function moveBase():void {
		dockTop = dockBase;
		for (var n:uint = 0; n < max; n++) {
			var icon:MenuDockIcon = icons[n];
			var basePos:int = iWidth*(n - (max - 1)*0.5);
			icon.scale += (1 - icon.scale)*deceleration;
			icon.x += (basePos - icon.x)*deceleration;
		}
	}
	private function resizeBase():void {
		var first:Number = icons[0].x - icons[0].base.width*0.5;
		var last:Number = icons[max-1].x + icons[max-1].base.width*0.5;
		base.width = last - first + offset*2;
		base.x = first + base.width*0.5 - offset;
	}
	private function drawBase():void {
		base = new Shape();
		addChild(base);
		var bWidth:uint = iWidth*max;
		base.graphics.beginFill(0xFFFFFF, 0.5);
		base.graphics.drawRect(-bWidth*0.5, 0, bWidth, -iWidth);
		base.graphics.endFill();
	}
	private function drawIcons():void {
		for (var n:uint = 0; n < max; n++) {
			var icon:MenuDockIcon = new MenuDockIcon(n, iWidth, iconList[n].icon);
			addChild(icon);
			icon.x = iWidth*(n - (max - 1)*0.5);
			icon.y = -1;
			icon.text = iconList[n].label;
			icons.push(icon);
		}
	}

}


//////////////////////////////////////////////////
// MenuDockIconクラス
//////////////////////////////////////////////////

import flash.display.Sprite;
import flash.display.DisplayObject;
import flash.events.MouseEvent;

class MenuDockIcon extends Sprite {
	public var id:uint;
	public var base:Sprite;
	private var _width:uint;
	private var _scale:Number = 1;
	private var icon:DisplayObject;
	private var label:MenuDockLabel;

	public function MenuDockIcon(n:uint, w:uint, i:DisplayObject) {
		id = n;
		_width = w;
		icon = i;
		draw();
	}

	private function draw():void {
		base = new Sprite();
		addChild(base);
		base.graphics.beginFill(0xFFFFFF, 0);
		base.graphics.drawRect(-_width*0.5, -_width, _width, _width);
		base.graphics.endFill();
		base.addChild(icon);
		label = new MenuDockLabel();
		label.y = - base.height;
		buttonMode = true;
		mouseChildren = false;
		addEventListener(MouseEvent.MOUSE_OVER, rollOver, false, 0, true);
		addEventListener(MouseEvent.MOUSE_OUT, rollOut, false, 0, true);
	}
	private function rollOver(evt:MouseEvent):void {
		addChild(label);
	}
	private function rollOut(evt:MouseEvent):void {
		if (contains(label)) removeChild(label);
	}
	public function get scale():Number {
		return _scale;
	}
	public function set scale(param:Number):void {
		_scale = param;
		base.scaleX = base.scaleY = _scale;
		label.y = - base.height;
	}
	public function set text(param:String):void {
		label.text = param;
	}

}


//////////////////////////////////////////////////
// MenuDockLabelクラス
//////////////////////////////////////////////////

import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFieldType;
import flash.text.TextFieldAutoSize;
import flash.text.AntiAliasType;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flash.filters.DropShadowFilter;

class MenuDockLabel extends Sprite {
	private var txt:TextField;
	private static var fontType:String = "_ゴシック";
	private static var _height:uint = 22;
	private static var yOffset:uint = 6;
	private static var bColor:uint = 0xFFFFFF;
	private static var sColor:uint = 0x000000;

	public function MenuDockLabel() {
		draw();
	}

	private function draw():void {
		txt = new TextField();
		addChild(txt);
		txt.height = _height - 1;
		txt.y = - _height + yOffset;
		txt.autoSize = TextFieldAutoSize.CENTER;
		txt.type = TextFieldType.DYNAMIC;
		txt.selectable = false;
		//txt.embedFonts = true;
		//txt.antiAliasType = AntiAliasType.ADVANCED;
		//txt.antiAliasType = AntiAliasType.NORMAL;
		var tf:TextFormat = new TextFormat();
		tf.font = fontType;
		tf.size = 12;
		tf.align = TextFormatAlign.CENTER;
		txt.defaultTextFormat = tf;
		txt.textColor = bColor;
		var shade:DropShadowFilter = new DropShadowFilter(1, 90, sColor, 1, 2, 2, 2, 3, false, false, false);
		txt.filters = [shade];
	}
	public function set text(param:String):void {
		txt.text = param;
		txt.x = - uint(txt.width*0.5);
	}

}


//////////////////////////////////////////////////
// Iconクラス
//////////////////////////////////////////////////

import flash.display.Sprite;
import flash.display.Shape;
import flash.geom.Matrix;
import flash.display.GradientType;
import flash.display.SpreadMethod;
import flash.display.InterpolationMethod;
import flash.filters.DropShadowFilter;
import flash.text.TextField;
import flash.text.TextFieldType;
import flash.text.AntiAliasType;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

class Icon extends Sprite {
	private var size:uint;
	private var colors:Array;
	private var txt:TextField;
	private static var fontType:String = "_ゴシック";
	private var fontSize:uint;
	private var yOffset:int;

	public function Icon(s:uint) {
		size = s;
	}

	public function init(list:Array, t:String, s:uint, y:int = 0):void {
		colors = list;
		fontSize = s;
		yOffset = y;
		draw();
		txt.text = t;
	}
	private function draw():void {
		var base:Shape = new Shape();
		addChild(base);
		var alphas:Array = [1, 1];
		var ratios:Array = [0, 255];
		var matrix:Matrix = new Matrix();
		var offset:Number = size*0.1;
		matrix.createGradientBox(size*2, size*2, 0, -size*1.5+offset, -size*1.5+offset);
		base.graphics.beginGradientFill(GradientType.RADIAL, colors, alphas, ratios, matrix, SpreadMethod.PAD, InterpolationMethod.RGB, 0);
		base.graphics.drawRect(-size*0.5, -size*0.5, size, size);
		base.graphics.endFill();
		var shade:DropShadowFilter = new DropShadowFilter(4, 90, 0x000000, 0.3, 8, 8, 2, 3, false, false);
		base.filters = [shade];
		txt = new TextField();
		addChild(txt);
		txt.x = -size*0.5;
		txt.y = -size*0.5 + yOffset;
		txt.width = size;
		txt.height = size;
		txt.type = TextFieldType.DYNAMIC;
		txt.selectable = false;
		//txt.embedFonts = true;
		//txt.antiAliasType = AntiAliasType.ADVANCED;
		//txt.antiAliasType = AntiAliasType.NORMAL;
		var tf:TextFormat = new TextFormat();
		tf.font = fontType;
		tf.size = fontSize;
		tf.align = TextFormatAlign.CENTER;
		txt.defaultTextFormat = tf;
		txt.textColor = 0xFFFFFF;
		var shadow:DropShadowFilter = new DropShadowFilter(0, 90, 0x000000, 0.5, 2, 2, 2, 3, false, false);
		txt.filters = [shadow];
	}

}


//////////////////////////////////////////////////
// Backgroundクラス
//////////////////////////////////////////////////

import flash.display.Shape;
import flash.geom.Matrix;
import flash.display.GradientType;

class Background extends Shape {
	private static var _width:uint;
	private static var _height:uint;
	private static var color1:uint = 0x77B2EE;
	private static var color2:uint = 0x3F68AB;

	public function Background(w:uint, h:uint) {
		_width = w;
		_height = h;
		draw();
	}

	private function draw():void {
		var colors:Array = [color1, color2];
		var alphas:Array = [1, 1];
		var ratios:Array = [0, 255];
		var matrix:Matrix = new Matrix();
		matrix.createGradientBox(_width, _height, 0.5*Math.PI, 0, 0);
		graphics.beginGradientFill(GradientType.LINEAR, colors, alphas, ratios, matrix);
		graphics.drawRect(0, 0, _width, _height);
		graphics.endFill();
	}

}

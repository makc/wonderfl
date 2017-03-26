////////////////////////////////////////////////////////////////////////////////
// [AS3.0] LightCircleクラスだ！ (2)
// http://www.project-nya.jp/modules/weblog/details.php?blog_id=1153
////////////////////////////////////////////////////////////////////////////////

package {

	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.geom.Rectangle;
	import flash.events.MouseEvent;

	[SWF(backgroundColor="#000000", width="465", height="465", frameRate="30")]

	public class Main extends Sprite {
		private var light:LightCircle;

		public function Main() {
			init();
		}

		private function init():void {
			graphics.beginFill(0x000000);
			graphics.drawRect(0, 0, 465, 465);
			graphics.endFill();
			var rect:Rectangle = new Rectangle(0, 0, 465, 465);
			light = new LightCircle(rect, 8);
			addChild(light);
			light.start();
		}

	}

}



import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Rectangle;
import flash.display.BlendMode;
import flash.filters.ColorMatrixFilter;
import frocessing.color.ColorHSV;

class LightCircle extends Sprite {
	private var rect:Rectangle;
	private var circles:uint;
	private var circleList:Array;
	private var colorMatrix:ColorMatrixFilter;
	private var matrix:Array;
	private var color:ColorHSV;

	public function LightCircle(r:Rectangle, n:uint) {
		rect = r;
		circles = n;
		init();
	}

	private function init():void {
		circleList = new Array();
		color = new ColorHSV(216, 0.6, 1);
		for (var n:uint = 0; n < circles; n++) {
			var circle:Circle = new Circle(100);
			circle.color = color.value;
			circle.blendMode = BlendMode.ADD;
			circleList.push(circle);
		}
		colorMatrix = new ColorMatrixFilter();
		matrix = new Array();
		matrix = [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 128, 0, 0, 0, 1, 0];
		colorMatrix.matrix = matrix;
		filters = [colorMatrix];
		create();
	}
	private function create():void {
		for (var n:uint = 0; n < circles; n++) {
			var circle:Circle = circleList[n];
			circle.x = Math.random()*rect.width;
			circle.y = Math.random()*rect.height;
			circle.vx = Math.random()*8 - 4;
			circle.vy = Math.random()*8 - 4;
			addChild(circle);
		}
	}
	public function start():void {
		addEventListener(Event.ENTER_FRAME, move, false, 0, true);
	}
	public function stop():void {
		removeEventListener(Event.ENTER_FRAME, move);
	}
	private function move(evt:Event):void {
		for (var n:uint = 0; n < circles; n++) {
			var circle:Circle = circleList[n];
			if (circle.x < rect.left || circle.x > rect.right) circle.vx = - circle.vx;
			if (circle.y < rect.top || circle.y > rect.bottom) circle.vy = - circle.vy;
			circle.x += circle.vx;
			circle.y += circle.vy;
		}
	}


}



import flash.display.Shape;
import flash.filters.BlurFilter;

class Circle extends Shape {
	private var radius:uint = 100;
	private var rgb:uint = 0xFFFFFF;
	private var blur:BlurFilter
	public var vx:Number = 0;
	public var vy:Number = 0;

	public function Circle(r:uint) {
		radius = r;
		blur = new BlurFilter(radius*0.5, radius*0.5, 3);
		draw();
	}

	private function draw():void {
		graphics.clear();
		graphics.beginFill(rgb);
		graphics.drawCircle(0, 0, radius);
		graphics.endFill();
		var blur:BlurFilter = new BlurFilter(50, 50, 3);
		filters = [blur];
	}
	public function set color(c:uint):void {
		rgb = c;
		draw();
	}

}

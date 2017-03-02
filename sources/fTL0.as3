package {
	import flash.display.Sprite;
	import flash.display.Graphics;
	public class DragRotationSample extends Sprite {
		public function DragRotationSample() {
			var card:DragRotater = new DragRotater();
			var myGraphics:Graphics = card.graphics;
			addChild(card);
			card.x = stage.stageWidth / 2;
			card.y = stage.stageHeight / 2;
			myGraphics.beginFill(0x0000FF);
			myGraphics.drawRect(-50, -25, 100, 50);
			myGraphics.endFill();
		}
	}
}
import flash.display.Sprite;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.events.MouseEvent;
import flash.events.Event;
internal class DragRotater extends Sprite {
	private const DECELERATION:Number = 0.8;
	private const RATIO:Number = 0.02 * Math.PI / 180;
	private var myMatrix:Matrix;
	private var lastMouse:Point;
	private var velocity:Point;
	private var angularVelocity:Number = 0;
	public function DragRotater() {
		buttonMode = true;
		addEventListener(MouseEvent.MOUSE_DOWN, xMouseDown);
	}
	private function xMouseDown(eventObject:MouseEvent):void {
		removeEventListener(Event.ENTER_FRAME, xThrow);
		addEventListener(Event.ENTER_FRAME, xDrag);
		stage.addEventListener(MouseEvent.MOUSE_UP, xMouseUp);
		lastMouse = new Point(parent.mouseX, parent.mouseY);
	}
	private function xMouseUp(eventObject:MouseEvent):void {
		removeEventListener(Event.ENTER_FRAME, xDrag);
		stage.removeEventListener(MouseEvent.MOUSE_UP, xMouseUp);
		addEventListener(Event.ENTER_FRAME, xThrow);
	}
	private function xDrag(eventObject:Event):void {
		var position:Point = new Point(x,y);
		var currentMouse:Point = new Point(parent.mouseX, parent.mouseY);
		var radius:Point = lastMouse.subtract(position);
		var force:Point = currentMouse.subtract(lastMouse);
		var moment:Number = crossProduct2D(radius,force);
		angularVelocity +=  moment * RATIO;
		myMatrix = transform.matrix;
		myMatrix.translate(-lastMouse.x, -lastMouse.y);
		myMatrix.rotate(angularVelocity);
		myMatrix.translate(currentMouse.x, currentMouse.y);
		transform.matrix = myMatrix;
		lastMouse = currentMouse.clone();
		velocity = force;
		angularVelocity *= DECELERATION;
	}
	private function xThrow(eventObject:Event):void {
		myMatrix = transform.matrix;
		myMatrix.translate(-x, -y);
		myMatrix.rotate(angularVelocity);
		myMatrix.translate(x + velocity.x, y + velocity.y);
		transform.matrix = myMatrix;
		velocity.normalize(velocity.length * DECELERATION);
		angularVelocity *=  DECELERATION;
		if (Math.abs(angularVelocity) < 0.1 && velocity.length < 0.1) {
			removeEventListener(Event.ENTER_FRAME, xThrow);
		}
	}
	private function crossProduct2D(point0:Point, point1:Point):Number {
		return point0.x * point1.y - point0.y * point1.x;
	}
}
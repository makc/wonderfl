// same shit except dragging corners zooms,
// like in MSSurface
package {
	import flash.display.Sprite;
	import flash.display.Graphics;
	public class DragRotationSample extends Sprite {
		public function DragRotationSample() {
			var card:DragRotater = new DragRotater();
			addChild(card);
			card.x = stage.stageWidth / 2;
			card.y = stage.stageHeight / 2;
			var image:DragZoomer = new DragZoomer();
			card.addChild (image);
			var myGraphics:Graphics = image.graphics;
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
import flash.geom.Rectangle;
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
		var radius:Point = currentMouse.subtract(position);
		var force:Point = currentMouse.subtract(lastMouse);
		var moment:Number = crossProduct2D(radius,force);
		angularVelocity +=  moment * RATIO;
		myMatrix = transform.matrix;
		myMatrix.translate(-lastMouse.x, -lastMouse.y);
		myMatrix.rotate(angularVelocity);
		myMatrix.translate(currentMouse.x, currentMouse.y);
		transform.matrix = myMatrix;
		lastMouse = new Point(currentMouse.x,currentMouse.y);
		velocity = new Point(force.x,force.y);
		angularVelocity *=  DECELERATION;
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
internal class DragZoomer extends Sprite {
	private var lastMouse:Point;
	public function DragZoomer() {
		buttonMode = true;
		addEventListener(MouseEvent.MOUSE_DOWN, xMouseDown);
	}
	private function xMouseDown(eventObject:MouseEvent):void {
		var rect:Rectangle = getBounds (this);
		rect.inflate ( -0.1 * rect.width, -0.1 * rect.height);
		if (!rect.contains (mouseX, mouseY)) {
			// intercept events
			eventObject.stopPropagation ();

			addEventListener(Event.ENTER_FRAME, xDrag);
			stage.addEventListener(MouseEvent.MOUSE_UP, xMouseUp);
			lastMouse = new Point(parent.mouseX, parent.mouseY);
		}
	}
	private function xMouseUp(eventObject:MouseEvent):void {
		removeEventListener(Event.ENTER_FRAME, xDrag);
		stage.removeEventListener(MouseEvent.MOUSE_UP, xMouseUp);
	}
	private function xDrag(eventObject:Event):void {
		var currentMouse:Point = new Point(parent.mouseX, parent.mouseY);
		// find matrix that does lastMouse -> currentMouse
		var m1:Matrix = transform.matrix;
		var m2:Matrix = new Matrix; m2.rotate (
			Math.atan2 (currentMouse.y, currentMouse.x) - Math.atan2 (lastMouse.y, lastMouse.x));
		var scale:Number = currentMouse.length / lastMouse.length;
		m2.scale (scale, scale);
		m1.concat (m2);
		transform.matrix = m1;
		lastMouse = currentMouse;
	}
}
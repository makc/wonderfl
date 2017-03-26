package {
	import flash.display.*;
	public class Main extends Sprite {
			
		public function Main() {
			for (var i:Number = 5; i-- > 0;) {
				addChild(new MotionTail);
			}
		}
		public function remove(child:DisplayObject):void {
			removeChild(child);
		}
		
	}
	
}

import flash.display.*;
import flash.geom.Point;
import flash.events.*;
class Babble extends Sprite {
	
	private var cvx:Number;
	private var cvy:Number;
	private var vx:Number;
	private var vy:Number;
	private var d:Number;
	private var p:Point;
	
	public function Babble(depth:Number) {
		d = depth;
		p = new Point();
		addEventListener(Event.ADDED_TO_STAGE, initialize);
		addEventListener(Event.REMOVED_FROM_STAGE, uninitialize);
	}
	
	private function initialize(event:Event):void {
		var initv:Number = 8;
		vx = Math.random() * initv - initv / 2;
		vy = Math.random() * initv - initv / 2;
		var radius:uint = Math.random() * 20 + 10;
		radius /= d;
		/*var radius:uint = 10;*/
		if (Math.random() * 2 > 1.2)
			graphics.beginFill(0xffffff);
		else
			graphics.beginFill(0x000000);
		graphics.drawCircle(-radius / 2, -radius / 2, radius);
		graphics.drawCircle(-radius / 2, -radius / 2, radius / 2);
		graphics.endFill();
		addEventListener(Event.ENTER_FRAME, transitionVector);
		addEventListener(Event.ENTER_FRAME, motion);
	}
	private function transitionVector(event:Event):void {
		vx += Math.random() * 2 > 1? (Math.random() * 20) / 50: -(Math.random() * 20) / 50;
		vy += Math.random() * 2 > 1? (Math.random() * 20) / 50: -(Math.random() * 20) / 50;
		vx /= 1.09;
		vy /= 1.09;
		
	}
	private function motion(event:Event):void {
		x += vx / d;
		y += vy / d;
		
		scaleX /= 1.1;
		scaleY /= 1.1;
		scaleX -= 0.005;
		scaleY -= 0.005;
		
		if (width < 1) destroy();
	}
	public function destroy():void {
		removeEventListener(Event.ADDED_TO_STAGE, initialize);
		removeEventListener(Event.REMOVED_FROM_STAGE, uninitialize);
		removeEventListener(Event.ENTER_FRAME, transitionVector);
		removeEventListener(Event.ENTER_FRAME, motion);
		var p:Main = parent as Main;
		p.remove(this);
	}
	private function uninitialize(event:Event):void {
		
	}
}
class MotionTail extends Sprite {
	private var vx:Number;
	private var vy:Number;
	private var vs:Number;
	private var bx:Number;
	private var by:Number;
	public function MotionTail() {
		addEventListener(Event.ADDED_TO_STAGE, initialize);
		addEventListener(Event.REMOVED_FROM_STAGE, uninitialize);
		addEventListener(Event.ENTER_FRAME, crusing);
		addEventListener(Event.ENTER_FRAME, addBabble);
	}
	private function initialize(event:Event):void {
		vs = Math.random() * 50 + 100;
		vx = 0;
		vy = 0;
		x = Math.random() * stage.stageWidth;
		y = Math.random() * stage.stageHeight;
		bx = Math.random() * stage.stageWidth;
		by = Math.random() * stage.stageHeight;
		graphics.beginFill(0x000000);
		graphics.drawCircle(0, 0, 2);
		graphics.endFill();
	}
	private function uninitialize(event:Event):void {
		removeEventListener(Event.ADDED_TO_STAGE, initialize);
		removeEventListener(Event.REMOVED_FROM_STAGE, uninitialize);
		removeEventListener(Event.ENTER_FRAME, crusing);
		removeEventListener(Event.ENTER_FRAME, addBabble);
	}
	private function crusing(event:Event):void {
		var bs:Number = 5;
		bx += Math.random() * 2 > 1? (Math.random() * bs): -(Math.random() * bs);
		by += Math.random() * 2 > 1? (Math.random() * bs): -(Math.random() * bs);
		if (bx > stage.stageWidth) bx = stage.stageWidth / 2;  
		if (by > stage.stageWidth) by = stage.stageWidth / 2;  
		vx += (bx - x) / vs;
		vy += (by - y) / vs;
		vx /= 1.005;
		vy /= 1.005;
		x += vx / 1;
		y += vy / 1;
	}
	private function addBabble(event:Event):void {
		for (var i:uint = 3; i-- > 0;) {
			var babble:Babble = new Babble(1);
			babble.x = x;
			babble.y = y;
			parent.addChild(babble);
		}
	}
}
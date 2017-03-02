package {
    import flash.display.Sprite;
	import flash.events.MouseEvent;
	import caurina.transitions.Tweener;
	
    public class FlashTest extends Sprite {
		private var _color:uint = 0x4444ff;
		
        public function FlashTest() {
			stage.frameRate = 60;
			
			redraw();
			
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onDown);
        }
		
		private function onDown(e:MouseEvent):void {
			crack();
			redraw();
		}
		
		private function crack():void {
			var size:uint = 46;
			var num:uint = uint(465 / size) + ((465 % size > 0) ? 1 : 0);
			
			for (var y:uint = 0; y < num; ++y) {
				for (var x:uint = 0; x < num; ++x) {
					var b:Block = new Block(_color, size);
					b.x = x * size;
					b.y = y * size;
					this.addChildAt(b, 0);
				}
			}
		}
		
		private function redraw():void {
			var r:uint = Math.random() * 256;
			var g:uint = Math.random() * 256;
			var b:uint = Math.random() * 256;
			_color = (r << 16) + (g << 8) + (b << 0);

			this.graphics.beginFill(_color);
			this.graphics.drawRect(0, 0, 465, 465);
			this.graphics.endFill();
		}
    }
}

import flash.display.Sprite;
import flash.events.Event;

class Block extends Sprite
{
	private var _speedX:Number;
	private var _speedY:Number;
	private var _speedZ:Number;
	
	public function Block(color:uint, size:Number) {
		var rad:Number = Math.random() * Math.PI; // 0 - 180
		var length:Number = 0.5;
		
		_speedX = Math.cos(rad) * length;
		_speedY = -(Math.random() * 3.0 + 2.0);
		_speedZ = -Math.sin(rad) * length;
		
		this.graphics.lineStyle(1, 0x000000, 0.5);
		this.graphics.beginFill(color);
		this.graphics.drawRect(0, 0, size, size);
		this.graphics.endFill();
	
		this.addEventListener(Event.ENTER_FRAME, update);
	}

	private function update(e:Event):void {
		var brake:Number = 0.99;
		_speedX *= brake;
		_speedY += 0.2;
		_speedZ *= brake;
		
		this.rotationZ += _speedX * 2;
		this.x += _speedX;
		this.y += _speedY;
		this.z += _speedZ;
		//this.alpha *= 0.96;
		
		if (this.y > 500) {
			this.removeEventListener(Event.ENTER_FRAME, update);
			parent.removeChild(this);
		}
	}
}

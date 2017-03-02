package {
	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;
	
	[SWF(width = "465", height = "465", frameRate = "60")]
	public class AnimatedIllusions extends Sprite {
		private var shape:Shape = new Shape();
		private var g:Graphics = shape.graphics;
		
		private var param:Number;
		
		public function AnimatedIllusions():void {
			addChild(shape);
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		private function enterFrameHandler(event:Event):void {
			param = Math.sin(getTimer() / 200);
			
			g.clear();
			drawMullerLyerIllusion();
			drawZollnerIllusion();
		}
		
		private function drawMullerLyerIllusion():void {
			const XL:Number = 465 / 2 - 80;
			const XR:Number = 465 / 2 + 80;
			const H:Number = 40;
			
			g.lineStyle(4, 0x000000);
			var offset:Number = param * 40;
			for (var i:int = 0; i < 2; i++) {
				var y:Number = 80 + i * 100;
				
				g.drawPath(Vector.<int>([1, 2, 1, 2, 2, 1, 2, 2]), 
					Vector.<Number>([
						XL, y,  XR, y,  
						XL + offset, y - H,  XL, y,  XL + offset, y + H, 
						XR - offset, y - H,  XR, y,  XR - offset, y + H
					]));
				offset = -offset;
			}
		}
		
		private function drawZollnerIllusion():void {
			const XL:Number = 40;
			const XR:Number = 425;
			const SPACING:Number = 30;
			const H:Number = 15;
			
			g.lineStyle(4, 0x000000, 1, false, LineScaleMode.NORMAL, CapsStyle.SQUARE);
			var offset:Number = param * 40;
			for (var i:int = 0; i < 4; i++) {
				var y:Number = 290 + i * 40;
				
				g.moveTo(XL, y);
				g.lineTo(XR, y);
				for (var x:Number = XL + 12; x < XR; x += SPACING) {
					g.moveTo(x + offset, y - H);
					g.lineTo(x - offset, y + H);
				}
				offset = -offset;
			}
		}
	}
}

package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import caurina.transitions.Tweener;
	import flash.text.TextField;
	
	public class Main extends Sprite 
	{
		private var size:uint = 5;
		private var time:uint = 2;
		private var transition:String = "";
		public function Main():void 
		{
			//transition = "easeInOutBack";
			//transition = "easeInOutSine";
			//transition = "easeInElastic";
			//transition = "easeInBack";
			//transition = "easeInOutCirc";
			//transition = "easeInOutElastic";
			//transition = "easeInBounce";
			//transition = "easeOutCirc";
			transition = "easeInCubic";
			//transition = "easeOutCubic";
			//transition = "easeOutInElastic";
			//transition = "easeOutInBack";
			stage.addEventListener(MouseEvent.MOUSE_MOVE, mousemoveHandler);
		}
		
		private function mousemoveHandler(e:MouseEvent):void {
			createSprite();
		}
		
		private function createSprite():void {
			var spr:Sprite = new Sprite();
			spr.graphics.beginFill(getColor());
			spr.graphics.drawCircle(0, 0, getSize());
			spr.graphics.endFill();
			spr.x = stage.mouseX;
			spr.y = stage.mouseY;
			var tgtx:Number = Math.random() * stage.stageWidth + stage.stageWidth * getPlusMinus();
			var tgty:Number = Math.random() * stage.stageHeight + stage.stageHeight * getPlusMinus();
			stage.addChild(spr);
			Tweener.addTween(spr, { x:tgtx, y:tgty, alpha:0, time:time, transition:transition, onComplete:function():void {stage.removeChild(this)}} );
		}
		
		private function getColor():uint {
			var r:int = Math.random() * 255;
			var g:int = Math.random() * 255;
			var b:int = Math.random() * 255;
			return r << 16 | g << 8 | b;
		}
		
		private function getSize():uint {
			return Math.random() * size + 0.5;
		}
		
		private function getPlusMinus():int {
			return Math.random() < 0.5 ? -1 : 1;
		}
	}
	
}
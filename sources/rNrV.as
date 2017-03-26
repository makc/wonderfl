package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import caurina.transitions.Tweener;
	import flash.text.TextField;
	
	public class Main extends Sprite 
	{
		private var size:uint = 30;
		private var sprites:Array;
		private var txt:TextField;
		public function Main():void 
		{
			sprites = new Array();
			txt = new TextField();
			addChild(txt);
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, mousemoveHandler);
			stage.addEventListener(Event.ENTER_FRAME, enterframeHandler);
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
			var tgtx:Number = Math.random() * stage.stageWidth;
			var tgty:Number = Math.random() * stage.stageHeight;
			Tweener.addTween(spr, { x:tgtx, y:tgty, alpha:0, time:1, transition:"linear" } );
			sprites.push(spr);
			addChild(spr);
		}
		
		private function enterframeHandler(e:Event):void {
			txt.text = String(sprites.length);
			for (var i:int = sprites.length - 1; i >= 0; i--) {
				var spr:Sprite = sprites[i];
				//trace(spr.x);
				if (spr.x >= stage.stageWidth - 100) {
					sprites.splice(i, 1);
					removeChild(spr);
				}
			}
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
	}
	
}

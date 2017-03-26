package {

	import flash.display.*;
	import flash.events.*;


	

       public class MouseToy extends MovieClip {
		private var circles:Array;


               public function MouseToy(){
                  // init
			circles = [];
			for (var i:int = 0; i<30; i++){
				var c:Sprite = makeCircle();
				c.x = stage.stageWidth / 2;
				c.y = stage.stageHeight / 2;
				c.scaleX = 1 + i/2;
				c.scaleY = 0.5 + i/4;
				addChild(c);
				circles.push(c);
			}
			addEventListener(Event.ENTER_FRAME, onLoop);
			
			
			
			

               }
               // private methods

		private function onLoop(evt:Event):void {
			circles[0].y += (mouseY - circles[0].y) / 4;
			for (var i:int = 1; i<circles.length; i++){
				var pre:Sprite = circles[i - 1];
				circles[i].y += (pre.y - circles[i].y) / 4;
			}
		}
		private function makeCircle():Sprite{
			var s:Sprite = new Sprite();
			with(s.graphics){
				lineStyle(0,0x000000);
				drawCircle(0,0,10);
			}
			return s;
		}
		

       }

}
package {

	import flash.display.*;
	import flash.events.*;


	[SWF(width = 500, height=500)]

       public class FunctionUse extends MovieClip {
		private var canvas:BitmapData;
		private var walkerNum:int;
		private var walkers:Vector.<Function>;


               public function FunctionUse(){
                  // init
			
			canvas = new BitmapData(800,800,false, 0x000000);
			addChild(new Bitmap(canvas,"auto",true));
			scaleX = scaleY = 500 / 800
			 
			
			walkerNum = 50;
			walkers = new Vector.<Function>(walkerNum, true);
			
			makeWalkers();
			runWalkers();

               }
               // private methods

		private function makeWalkers():void{
			for (var i:int = 0; i<walkerNum; i++){
				walkers[i] = makeWalker();
			}
		}
		private function runWalkers():void{
			addEventListener(Event.ENTER_FRAME, onRun);
		}
		private function onRun(evt:Event):void{
			for (var i:int = 0; i<walkerNum; i++){
				walkers[i]();
			}
		}
		private function makeWalker(xp:Number=400, yp:Number=400):Function{
			var x:Number = xp, y:Number = yp;
			var rad:Number = Math.random() * 4;
			var theta:Number = Math.random() * Math.PI * 2;
			var speed:Number = 0.01 * Math.random() * 2
			if (int(Math.random() * 2) == 1){
				speed *= -1;
			}
			return function():void{
				x += rad * Math.cos(theta);
				y += rad * Math.sin(theta);
				theta += speed
				if (int(Math.random() * 100) == 1){
					theta = Math.random() * Math.PI * 2;
				}
				if (x > 800 || x < 0 || y > 800 || y < 0){
					x = xp, y = yp;
				}
			    canvas.setPixel(x, y, 0xFFFFFF);

			}
		}
		

       }

}
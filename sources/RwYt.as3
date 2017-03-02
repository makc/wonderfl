// click to load custom image ;)
// inspired by http://onecm.com/projects/mycelium/
package {

	import flash.display.*;
	import flash.events.*;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;


	[SWF(width=465, height=465)]

       public class FunctionUse extends MovieClip {
		private var canvas:BitmapData;
		private var walkerNum:int;
		private var walkers:Vector.<Function>;

		private var loader:Loader;
		private var file:FileReference;

               public function FunctionUse(){
                  // init
				  loader = new Loader;
				  loader.contentLoaderInfo.addEventListener (Event.COMPLETE, init);
				  loader.load (new URLRequest ("http://a1.twimg.com/profile_images/423176540/head.jpg"),
					new LoaderContext (true));
			   }

		public function init (e:Event):void {
			if (canvas == null) {
			canvas = new BitmapData(465,465,false, 0x000000);
			addChild(new Bitmap(canvas,"auto",true));
			 
			
			walkerNum = 50000;
			walkers = new Vector.<Function>(walkerNum, true);
			runWalkers();
			} else {
				canvas.fillRect (canvas.rect, 0);
			}	
			makeWalkers();

               }
               // private methods

		private function makeWalkers():void{
			var bd:BitmapData = loader.content["bitmapData"];
			for (var i:int = 0; i < walkerNum; i++) {
				var ix:int = 465 * Math.random ();
				var iy:int = 465 * Math.random ();
				walkers[i] = makeWalker(ix, iy,
					(bd.getPixel (
						ix * bd.width / 465.0,
						iy * bd.height / 465.0)
					& 0xFF00) >> 10);
			}
		}
		private function runWalkers():void{
			addEventListener(Event.ENTER_FRAME, onRun);
			file = new FileReference;
			file.addEventListener (Event.SELECT, onFileSelected);
			file.addEventListener (Event.COMPLETE, onFileLoaded);
			stage.addEventListener (MouseEvent.CLICK, loadUserImage);
		}

		private function loadUserImage (e:MouseEvent):void { file.browse (); }
		private function onFileSelected (e:Event):void { file.load (); }
		private function onFileLoaded (e:Event):void { loader.loadBytes (file.data); }
		private function onImageReady (e:Event):void {
		}
		private function onRun(evt:Event):void {
			canvas.lock ();
			for (var i:int = 0; i<walkerNum; i++){
				walkers[i]();
			}
			canvas.unlock ();
		}
		private function makeWalker(xp:Number=200, yp:Number=200, dieAt:int=64):Function{
			var age:int = dieAt;
			var x:Number = xp, y:Number = yp;
			var rad:Number = Math.random();
			var theta:Number = Math.random() * Math.PI * 2;
			var speed:Number = 0.01 * Math.random() * 2;
			if (int(Math.random() * 2) == 1){
				speed *= -1;
			}
			return function():void{
				if (age --< 1) return;
				x += rad * Math.cos(theta);
				y += rad * Math.sin(theta);
				theta += speed
				if (int(Math.random() * 100) == 1){
					theta = Math.random() * Math.PI * 2;
				}
				if (!(x > 465 || x < 0 || y > 465 || y < 0)){
					canvas.setPixel(x, y, Math.max (0x40404*age, canvas.getPixel (x, y)));
				}
			    

			}
		}
		

       }

}
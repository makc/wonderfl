package {
	import flash.display.*;
	import flash.events.Event;
	import flash.geom.*;
	import flash.filters.*;
	import flash.text.*;
	
	[SWF(backgroundColor=0x000000)]
	public class StringParticle extends Sprite{
		private static const WIDTH:Number = 400;
		private static const HEIGHT:Number = 400;
		
		public function StringParticle()
		{
			stage.scaleMode = "noScale";
			stage.align = "TL";

			var bmd:BitmapData = createBitmapData();
			var particles:Array = initParticles(bmd);

			var canvas:BitmapData = new BitmapData(WIDTH, HEIGHT, false, 0x000000);
			addChild(new Bitmap(canvas));
			
			var ptZero:Point = new Point();
			var filter1:BlurFilter = new BlurFilter();
			var filter2:ColorMatrixFilter = new ColorMatrixFilter([.9, 0, 0, 0, 0, 
				0, .9, 0, 0, 0, 
				0, 0, .9, 0, 0,
				0, 0, 0, 1, 0]);
			addEventListener("enterFrame", function(event:Event):void{
				canvas.lock();
				//canvas.fillRect(canvas.rect, 0x000000);
				canvas.applyFilter(canvas, canvas.rect, ptZero, filter1);
				canvas.applyFilter(canvas, canvas.rect, ptZero, filter2);
				for each (var p:Particle in particles){
					p.x = Math.abs(p.x - p._x) < 1 ? p._x : p.x + (p._x - p.x) * .2;
					p.y = Math.abs(p.y - p._y) < 1 ? p._y : p.y + (p._y - p.y) * .2;

					if (p.x == p._x && p.y == p._y && Math.random() < .5){
						p.x = WIDTH * Math.random();
						p.y = HEIGHT * Math.random();
					}
					
					canvas.setPixel(p.x, p.y, p.c);
				}
				canvas.unlock();
			});
			stage.addEventListener("click", function(event:Event):void{
				for each (var p:Particle in particles){
					p.x = Math.random() * WIDTH;
					p.y = Math.random() * HEIGHT;
				}    			
			});
		}

		private static function createBitmapData():BitmapData{
			var fmt:TextFormat = new TextFormat();
			fmt.size = 60;

			var tf:TextField = new TextField();
			tf.defaultTextFormat = fmt;
			tf.autoSize = "left";
			tf.textColor = 0xffffff;
			tf.text = "HELLO\nWORLD";

			var bmd:BitmapData = new BitmapData(WIDTH, HEIGHT, false, 0x000000);
			var mtx:Matrix = new Matrix();
			mtx.translate((WIDTH - tf.width) / 2, (HEIGHT - tf.height) / 2);
			bmd.draw(tf, mtx);

			return bmd;
		}

		private static function initParticles(bmd:BitmapData):Array{
			var particles:Array = [];
			for (var yy:int = 0; yy < bmd.height; yy++){
				for (var xx:int = 0; xx < bmd.width; xx++){
					var c:uint = bmd.getPixel(xx, yy);
					if (c != 0){
						var p:Particle = new Particle();
						p._x = xx; p._y = yy; p.c = c;
						var theta:Number = Math.random() * 2 * Math.PI;
						p.x = xx + 30 * Math.cos(theta);
						p.y = yy + 30 * Math.sin(theta);
						particles.push(p);
					}
				}
			}
			return particles;
		}
	}
}

class Particle{
	public var x:Number;
	public var y:Number;
	public var _x:Number;
	public var _y:Number;
	public var c:int;
	
	public function Particle(){
		x = 0;
		y = 0;
		c = 0;
	}
}

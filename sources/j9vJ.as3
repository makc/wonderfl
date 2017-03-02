// forked from miyaoka's Milk
package 
{
	import flash.display.*;
	import flash.events.*;
	import flash.filters.*;
	import flash.geom.*;
	import net.hires.debug.Stats;
	import flash.filters.BevelFilter;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	
	[SWF(width = "465", height = "465", backgroundColor = 0xFFFFFF, frameRate = "60")]
	
	public class Mochi
	extends Sprite
	{
		private var bmd:BitmapData;
		private var ballsContainer:Sprite;
		private var alphaArray:Array = new Array(0x100);
		private var imgURL:String = "http://farm4.static.flickr.com/3517/3749335774_a203d89e60_t.jpg";
		public function Mochi() 
		{
			//bg
			graphics.beginFill(0x0);
			graphics.drawRect(0, 0, SW, SH);
			
            var req:URLRequest = new URLRequest(imgURL);
            var loader:Loader = new Loader();
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadCompleteHandler);  
            loader.load(req, new LoaderContext(true));
		}
		private function loadCompleteHandler(e:Event):void 
		{
			e.target.removeEventListener(Event.COMPLETE, loadCompleteHandler);
			var bmp:Bitmap = e.target.loader.content as Bitmap;
			
			//bmd
			bmd = new BitmapData(SW, SH, true, 0x00ffffff);
			
			//threshold for metaball
			makeThreshold(0x70, 0x88);
			
			//balls
			ballsContainer = new Sprite();
			var num:uint = 30;
			while (num--) 
			{
				var ball:Ball = new Ball(bmp.bitmapData);
				ballsContainer.addChild(ball);
			}
			ballsContainer.filters =
			[
				new BevelFilter(2, 60, 0xFFFFFF, 1, 0x0, 1, 2, 2)
			];	
			

			//add
//			addChild(ballsContainer);			
			addChild(new Bitmap(bmd));
			addChild(new Stats());
			
			//evt
			addEventListener(Event.ENTER_FRAME, function ():void 
			{
				bmd.lock();
				bmd.fillRect(bmd.rect , 0x00ffffff);
				
/*				var num:int = ballsContainer.numChildren;
				while (num--) 
				{
					var b:Ball = ballsContainer.getChildAt(num) as Ball;
					var bmd2:BitmapData = b.bitmap;					
					bmd.copyPixels(bmd2, bmd2.rect, new Point(b.x - bmd2.width/2, b.y - bmd2.height/2), null, null, true); 
				}
*/				
				bmd.draw(ballsContainer);
				bmd.paletteMap(bmd, bmd.rect, new Point(), null, null, null, alphaArray);		
				bmd.unlock();
			});
			
			stage.addEventListener(MouseEvent.MOUSE_DOWN, function ():void 
			{
				var num:int = ballsContainer.numChildren;
				var pt:Point = new Point(mouseX, mouseY);
				while (num--) 
				{
					Ball(ballsContainer.getChildAt(num)).move(pt);
				}
			});
		}
		private function makeThreshold(min:uint, max:uint):void 
		{
			alphaArray = [];
			var step:Number = 0xFF / (max - min);
			var i:int;
			//under threshold
			for(i = 0; i < min; i++) {
				alphaArray[i] = 0;
			}
			for(i = min; i < max; i++) {
				alphaArray[i] = uint(((i - min) * step)  << 24);
			}			
			//over threshold
			for(i = max; i < 0x100; i++) {
				alphaArray[i] = 0xff000000;
			}
		}
		
	}	
}

var SW:Number = 465;
var SH:Number = 465;

import flash.display.*;
import flash.events.*;
import flash.geom.*;
import flash.display.BlendMode;
class Ball
extends Sprite
{
	private var vct:Point;
	private var bmd:BitmapData;
	private var radius:Number;
	public function get bitmap():BitmapData 
	{
		return bmd.clone();
	}
	public function Ball(img:BitmapData):void 
	{
		
		//draw
		var g:Graphics = graphics;
		radius = 20 + Math.random() * Math.random() * 100;
		var mtx:Matrix = new Matrix();
		mtx.createGradientBox(radius * 2, radius * 2, 0, -radius, -radius);
		g.beginGradientFill(
			GradientType.RADIAL, 
			[0xffffff, 0xffffff],
			[1, 0],
			[0x66, 0xff],
			mtx
		);
		g.drawCircle(0, 0, radius);
		
		
		bmd = new BitmapData(width, height, true, 0xFFFFFFFF);
		
		mtx = new Matrix;
		mtx.scale(width / img.width / 2, height / img.height / 2);
		mtx.translate(width / 4, height / 5);
		bmd.draw(img, mtx, null, null, null, true);
		
		
		blendMode = BlendMode.LAYER;
		mtx = new Matrix();
		mtx.translate(width / 2, height / 2)
		
		var alphaBmd:BitmapData = new BitmapData(width, height, true, 0x00ffffff);
		alphaBmd.draw(this, mtx);
		g.clear();

		bmd.copyChannel(alphaBmd, alphaBmd.rect, new Point(), BitmapDataChannel.ALPHA, BitmapDataChannel.ALPHA);
		alphaBmd.dispose();
		


		
		
		var bmp:Bitmap = new Bitmap(bmd);
		bmp.x = -bmp.width / 2;
		bmp.y = -bmp.height / 2;	
		addChild(bmp);
		
		//evt
		addEventListener(Event.ENTER_FRAME, function ():void 
		{
			vct.y += 0.2;
			var pos:Point = new Point(x, y).add(vct);
			x = pos.x;
			y = pos.y;
			checkWall();
		});

		move(new Point(SW/2, SH/2));

	}
	public function move(pt:Point):void 
	{
		x = pt.x;
		y = pt.y;
		vct = new Point((Math.random() - 0.5) * (Math.random() - 0.5) * radius * 0.5, (Math.random() - 0.5) * (Math.random() - 0.5) * radius * 0.8 - 5);
	}
	private function checkWall():void 
	{
		if (x < 0)
		{
			x = 0;
			vct.x *= -0.8;
		}
		else if (x > SW)
		{
			x = SW;
			vct.x *= -0.8;			
		}
		
		//if (y < 0)
		//{
			//y = 0;
			//vct.y *= -0.8;
		//}
		else if (y > SH)
		{
			y = SH;
			vct.y *= -0.8;			
		}
	}
}
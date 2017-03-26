package 
{
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import net.hires.debug.Stats;
	import flash.filters.BevelFilter;
	
	[SWF(width = "465", height = "465", backgroundColor = 0xFFFFFF, frameRate = "60")]
	
	public class Milk
	extends Sprite
	{
		private var bmd:BitmapData;
		private var ballsContainer:Sprite;
		private var alphaArray:Array = new Array(0x100);
		public function Milk() 
		{
			//bg
			graphics.beginFill(0x0);
			graphics.drawRect(0, 0, SW, SH);
			
			//bmd
			bmd = new BitmapData(SW, SH, true);
			
			//threshold for metaball
			makeThreshold(0x80, 0x88);
			
			//balls
			ballsContainer = new Sprite();
			var num:uint = 30;
			while (num--) 
			{
				var ball:Ball = new Ball();
				ballsContainer.addChild(ball);
			}
			ballsContainer.filters =
			[
				new BevelFilter(2)
			];	
			
			//add
//			addChild(ballsContainer);			
			addChild(new Bitmap(bmd));
			addChild(new Stats());
			
			//evt
			addEventListener(Event.ENTER_FRAME, function ():void 
			{
				bmd.lock();
				bmd.fillRect(bmd.rect , 0);
				bmd.draw(ballsContainer);
				bmd.paletteMap(bmd, bmd.rect, new Point(), null, null, null, alphaArray);		
				bmd.unlock();
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
class Ball
extends Shape
{
	private var vct:Point;
	public function Ball():void 
	{
		vct = new Point((Math.random() - 0.5) * 15, (Math.random() - 0.5) * 15);
		
		//draw
		var g:Graphics = graphics;
		var radius:Number = 5 + Math.random() * Math.random() * 200;
		var mtx:Matrix = new Matrix();
		mtx.createGradientBox(radius * 2, radius * 2, 0, -radius, -radius);
		g.beginGradientFill(
			GradientType.RADIAL, 
			[0xffffff, 0xffffff],
			[1, 0],
			[0x33, 0xff],
			mtx
		);
		g.drawCircle(0, 0, radius);
		
		//evt
		addEventListener(Event.ENTER_FRAME, function ():void 
		{
			var pos:Point = new Point(x, y).add(vct);
			x = pos.x;
			y = pos.y;
			checkWall();
		});
	}
	private function checkWall():void 
	{
		if (x < 0)
		{
			x = 0;
			vct.x *= -1;
		}
		else if (x > SW)
		{
			x = SW;
			vct.x *= -1;			
		}
		
		if (y < 0)
		{
			y = 0;
			vct.y *= -1;
		}
		else if (y > SH)
		{
			y = SH;
			vct.y *= -1;			
		}
	}
}
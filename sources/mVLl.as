/**
 * eskaflow
 * v0.1 - 6th March 2009
 * @author Richard Davey / Photon Storm
 */

package 
{
	import flash.display.Sprite;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.filters.BlurFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	[SWF (width = 600, height = 400, backgroundColor = 0x0, frameRate = 36)] 
	
	public class Main extends Sprite 
	{
		private var radMask:Sprite;
		private var grid:Sprite;
		private var fx:Bitmap;
		private var kaboom:Array;
		
		public function Main():void 
		{
			init();
		}
		
		private function init():void
		{
			makeGrid();
			
			kaboom = [];
			
			//	Shove some stuff into the array
			for (var ex:int = -180; ex < 180; ex += 1)
			{
				//	a 256 = special code for no alpha fade
				kaboom.push( { s: 0xffFF0080, a: 256, x: 300, y: 200, vx: Math.cos(ex * 0.017453) * Math.random() * 6, vy: Math.sin(ex * 0.017453) * Math.random() * 6 } );
				kaboom.push( { s: 0xffFF8000, a: 256, x: 300, y: 200, vx: Math.cos(ex * 0.017453) * Math.random() * 3, vy: Math.sin(ex * 0.017453) * Math.random() * 3 } );
				kaboom.push( { s: 0xffFFFF00, a: 256, x: 300, y: 200, vx: Math.cos(ex * 0.017453) * Math.random() * 1, vy: Math.sin(ex * 0.017453) * Math.random() * 1 } );
			}

			addChild(radMask);
			addChild(grid);
			addChild(fx);
			
			addEventListener(Event.ENTER_FRAME, mainLoop);
		}
		
		private function mainLoop(event:Event):void
		{
			fx.bitmapData.lock();
			
			//fx.bitmapData.fillRect(new Rectangle(0, 0, 600, 400), 0);

			//	Explosion Bits
			
			var kgb:int;
			
			for (var k:int; k < kaboom.length; k++)
			{
				//	If outside the screen, kill it
				if (kaboom[k].x < 0 || kaboom[k].x > 600 || kaboom[k].y < 0 || kaboom[k].y > 400 || kaboom[k].a <= 4)
				{
					kaboom.splice(k, 1);
				}
				else
				{
					kaboom[k].x += kaboom[k].vx;
					kaboom[k].y += kaboom[k].vy;
					
					if (kaboom[k].a < 256)
					{
						kaboom[k].a -= 3;
					}
					
					//	Make an ARGB colour from our value (so we can fade the debris out)
					kgb = 0 + (kaboom[k].a << 24) + kaboom[k].s;
					
					if (kaboom[k].t)
					{
						//	Thrusters
						kaboom[k].a -= 4;	//	Double speed reduce
						fx.bitmapData.fillRect(new Rectangle(kaboom[k].x, kaboom[k].y, 6, 4), kgb);
					}
					else
					{
						fx.bitmapData.fillRect(new Rectangle(kaboom[k].x, kaboom[k].y, 2, 2), kgb);
					}
				}
			}
			
			fx.bitmapData.unlock();
			
			fx.bitmapData.applyFilter(fx.bitmapData, new Rectangle(0, 0, 600, 400), new Point, new BlurFilter(2,2));
				
		}
		
		private function makeGrid():void
		{
			radMask = new Sprite;
			radMask.cacheAsBitmap = true;
			radMask.graphics.beginGradientFill("radial", [0, 0], [1, 0.4], [0, 255], new Matrix(0.3662109375, 0, 0, 0.244140625, 300, 200));
			radMask.graphics.drawRect(0, 0, 600, 400);
			
			grid = new Sprite;
			grid.cacheAsBitmap = true;
			grid.mask = radMask;
			
			for (var gy:int = 0; gy <= 600; gy += 20)
			{
				if (gy % 60 == 0)
				{
					grid.graphics.lineStyle(1, 0x0000FF);
					
				}
				else
				{
					grid.graphics.lineStyle(1, 0x0000A0);
				}
				
				grid.graphics.moveTo(0, gy);
				grid.graphics.lineTo(600, gy);
				grid.graphics.moveTo(gy, 0);
				grid.graphics.lineTo(gy, 400);
			}
			
			fx = new Bitmap(new BitmapData(600, 400, true, 0x0));
		}
		
	}
	
}
/*
 * 参考サイト
 * http://www5d.biglobe.ne.jp/~stssk/maze/make.html
 */
package
{
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import frocessing.math.*;
	import jp.progression.commands.lists.*;
	import jp.progression.commands.*;
	import com.bit101.components.*;
	
	public class Main extends Sprite
	{
		private var panel:Panel
		private var bd:BitmapData;
		private var destbd:BitmapData;
		private var bitmap:Bitmap;
		private var list:SerialList = new SerialList();
		private var wait:Number = 10 / 1000.0;
		
		public function Main()
		{
			Wonderfl.capture_delay(10);
			
			panel = new Panel(this);
			panel.width = panel.height = 465;
			
			stage.frameRate = 120;
			bd = new BitmapData(51, 51, false, Status.FIELD);
			
			destbd = bd.clone();
			
			bitmap = new Bitmap(destbd);
			bitmap.scaleX = bitmap.scaleY = 6;
			bitmap.x = (465 - bitmap.width) / 2;
			panel.content.addChild(bitmap);
			
			var button1:PushButton = new PushButton(panel.content, 82, 310, "boutaoshi", dig2);
			var button2:PushButton = new PushButton(panel.content, 182, 310, "anahori", dig1);
			var button3:PushButton = new PushButton(panel.content, 282, 310, "kabenobashi", dig3);
			var slider:HUISlider = new HUISlider(panel.content, 82, 350, "SPEED", sliderHandler);
			slider.minimum = 1;
			slider.value = 10;
		}
		
		private function sliderHandler(event:Event):void
		{
			var slider:HUISlider = event.currentTarget as HUISlider;
			wait = slider.value / 1000.0;
		}
		
		private function dig2(event:Event = null):void
		{
			list.clearCommand(true);
			list = new SerialList();
			bd = new BitmapData(51, 51, false, Status.FIELD);
			
			destbd = bd.clone();
			bitmap.bitmapData = destbd;
			
			for (var y:int = 0; y < bd.height; y++)
			{
				for (var x:int = 0; x < bd.width; x++)
				{
					if (y == 0 || x == 0 || y == bd.height - 1 || x == bd.width - 1 || y % 2 == 0 && x % 2 == 0)
					{
						bd.setPixel(x, y, Status.WALL);
						list.addCommand(new Func(function(x:int, y:int):void { destbd.setPixel(x, y, Status.WALL); }, [x, y]));
						list.addCommand(new Wait(wait));
					}
				}
			}

			for (y = 2; y < bd.height - 1; y += 2)
			{
				var dx:int = 2;
				var dy:int = y;
				
				switch (int(Math.random() * 4))
				{
					case 0: dx++; break;
					case 1: dx--; break;
					case 2: dy++; break;
					case 3: dy--; break;
				}
				
				if (bd.getPixel(dx, dy) != Status.WALL)
				{
					bd.setPixel(dx, dy, Status.WALL);
					list.addCommand(new Func(function(x:int, y:int):void { destbd.setPixel(x, y, Status.WALL); }, [dx, dy]));
					list.addCommand(new Wait(wait));
				}
				else y -= 2;
			}
			
			for (x = 4; x < bd.width - 1; x += 2)
			{
				for (y = 2; y < bd.height - 1; y += 2)
				{
					dx = x;
					dy = y;
					
					switch (int(Math.random() * 3))
					{
						case 0: dy++; break;
						case 1: dy--; break;
						case 2: dx++; break;
					}
					
					if (bd.getPixel(dx, dy) != Status.WALL)
					{
						bd.setPixel(dx, dy, Status.WALL);
						list.addCommand(new Func(function(x:int, y:int):void { destbd.setPixel(x, y, Status.WALL); }, [dx, dy]));
						list.addCommand(new Wait(wait));
					}
					else y -= 2;
				}
			}
			
			list.execute();
		}
		
		private function dig1(event:Event = null):void
		{
			list.clearCommand(true);
			list = new SerialList();
			bd = new BitmapData(51, 51, false, Status.FIELD);
			bd.fillRect(new Rectangle(1, 1, bd.width - 2, bd.height - 2), Status.WALL);
			
			destbd = bd.clone();
			bitmap.bitmapData = destbd;
			
			var px:int = int(Math.random() * (bd.width - 3) / 2) * 2 + 2;
			var py:int = int(Math.random() * (bd.width - 3) / 2) * 2 + 2;
			
			bd.setPixel(px, py, Status.FIELD);
			list.addCommand(new Func(function():void { destbd.setPixel(px, py, Status.FIELD); } ));

			_dig1(px, py);
			list.execute();
		}
		
		private function _dig1(px:int, py:int):void
		{
			const DIR:Array = 
			[
				[ 1,  0],
				[-1,  0],
				[ 0,  1],
				[ 0, -1]
			];
			
			var random:Array = Random.shakedIntegers(4);
			
			for (var i:int = 0; i < random.length; i++)
			{	
				if (bd.getPixel(px + DIR[random[i]][0] * 2, py + DIR[random[i]][1] * 2) == Status.WALL)
				{
					bd.setPixel(px + DIR[random[i]][0], py + DIR[random[i]][1], Status.FIELD);
					bd.setPixel(px + DIR[random[i]][0] * 2, py + DIR[random[i]][1] * 2, Status.FIELD);
					
					var ii:int = i;
					list.addCommand(new Func(function(px:int, py:int, i:int):void {destbd.setPixel(px + DIR[random[i]][0], py + DIR[random[i]][1], Status.FIELD);}, [px, py, i]));
					list.addCommand(new Wait(wait));
					list.addCommand(new Func(function(px:int, py:int, i:int):void {destbd.setPixel(px + DIR[random[i]][0] * 2, py + DIR[random[i]][1] * 2, Status.FIELD);}, [px, py, i]));
					list.addCommand(new Wait(wait));
					
					_dig1(px + DIR[random[i]][0] * 2, py + DIR[random[i]][1] * 2);
				}
			}
		}
		
		private function dig3(event:Event = null):void
		{
			list.clearCommand(true);
			list = new SerialList();
			bd = new BitmapData(51, 51, false, Status.WALL);
			bd.fillRect(new Rectangle(1, 1, bd.width - 2, bd.height - 2), Status.FIELD);
			
			destbd = bd.clone();
			bitmap.bitmapData = destbd;
			
			var wall:Array = new Array();
			for (var x:int = 2; x < bd.width; x += 2)
			{
				wall.push(new Point(x, 0));
				wall.push(new Point(x, bd.height - 1));
			}
			for (var y:int = 2; y < bd.height; y += 2)
			{
				wall.push(new Point(0, y));
				wall.push(new Point(bd.width - 1, y));
			}
			
			wall = Random.shake(wall);
			var point:Point = wall.pop();
			
			_dig3(point.x, point.y, wall);
			list.execute();
		}
		
		private function _dig3(px:int, py:int, wall:Array):void
		{
			const DIR:Array = 
			[
				[ 1,  0],
				[-1,  0],
				[ 0,  1],
				[ 0, -1]
			];
			
			var random:Array = Random.shakedIntegers(4);
			
			for (var i:int = 0; i < random.length; i++)
			{	
				if (bd.getPixel(px + DIR[random[i]][0] * 2, py + DIR[random[i]][1] * 2) == Status.FIELD)
				{
					bd.setPixel(px + DIR[random[i]][0], py + DIR[random[i]][1], Status.WALL);
					bd.setPixel(px + DIR[random[i]][0] * 2, py + DIR[random[i]][1] * 2, Status.WALL);
					
					var ii:int = i;
					list.addCommand(new Func(function(px:int, py:int, i:int):void {destbd.setPixel(px + DIR[random[i]][0], py + DIR[random[i]][1], Status.WALL);}, [px, py, i]));
					list.addCommand(new Wait(wait));
					list.addCommand(new Func(function(px:int, py:int, i:int):void {destbd.setPixel(px + DIR[random[i]][0] * 2, py + DIR[random[i]][1] * 2, Status.WALL);}, [px, py, i]));
					list.addCommand(new Wait(wait));
					
					_dig3(px + DIR[random[i]][0] * 2, py + DIR[random[i]][1] * 2, wall);
				}
			}
			
			if (wall.length != 0)
			{
				var point:Point = wall.pop();
				_dig3(point.x, point.y, wall);
			}
		}
	}
}

class Status
{
	public static const FIELD:int = 0xF3F3F3;
	public static const WALL:int = 0x393939;
}
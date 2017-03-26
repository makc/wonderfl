//棒倒し法、カベ重複有り版（複数ルート）
//とりあえず3D版 http://www.flickr.com/photos/miyaoka/3295692425/
package  
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	[SWF(width="465", height="465", backgroundColor= 0x000000, frameRate="60")]
	public class Maze 
	extends Sprite
	{		
		public function Maze() :void
		{
			stage.addEventListener(MouseEvent.CLICK, mouseClickHandler);
			mouseClickHandler(null);
		}
		private function mouseClickHandler(e:MouseEvent):void 
		{
			while (numChildren) removeChildAt(0);
			var num:uint = Math.floor(Math.random() * 50 + 5);
			var maze:MazeContainer = new MazeContainer(num, num);
			maze.scaleX = maze.scaleY  = stage.stageWidth / (num * 2 +1);
			maze.width = maze.height -= 30;
			maze.x = (stage.stageWidth - maze.width) / 2
			maze.y = (stage.stageHeight - maze.height) / 2
			addChild(maze);
		}
	}	
}
import flash.display.Sprite
import flash.geom.Matrix;
import flash.display.BitmapData;
import flash.display.Bitmap;
class MazeContainer
extends Bitmap
{
	public function MazeContainer(col:uint = 1, row:uint = 1) :void
	{
		bitmapData = new BitmapData(col * 2+1, row * 2+1, false, 0xFFFFFFFF);
		var c:uint;
		var r:uint;
		for (c = 1; c < col; c++)
		{
			for (r = 0; r < row; r++)
			{
				bitmapData.draw(new Block(), new Matrix(1, 0, 0, 1, c * 2+1, r * 2+1));
			}
		}
        //col:0
		for (r = 0; r < row; r++)
		{
			bitmapData.draw(new Block(true), new Matrix(1, 0, 0, 1, 1, r * 2+1));
		}
	}
}

class Block
extends Sprite
{
	public static const XY:Array = [
		[0, -1],
		[1, 0],
		[0, 1],
		[-1, 0]
	];
	public function Block(isFarLeft:Boolean = false) :void
	{
		graphics.beginFill(0);
		graphics.drawRect(0,0,1,1);
		var pt:Array = XY[Math.floor(Math.random() * (isFarLeft ? 4 : 3))];
		graphics.drawRect(pt[0], pt[1], 1, 1);
	}
}
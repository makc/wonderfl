//棒倒し法、カベ重複無し版（単一ルート）
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
			stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			mouseDownHandler(null);
		}
		private function mouseDownHandler(e:MouseEvent):void 
		{
			while (numChildren) removeChildAt(0);
			var num:uint = Math.floor(Math.random() * 60 + 2);
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
		bitmapData = new BitmapData(col * 2 + 1, row * 2 + 1, false, 0xFFFFFFFF);
		bitmapData.lock();
		var c:uint;
		var r:uint;
		var block:Block;
		var lastBlockIsBotton:Boolean = false;
        //col:0
		for (r = 0; r < row; r++)
		{
			block = new Block(!lastBlockIsBotton, true);
			bitmapData.draw(block, new Matrix(1, 0, 0, 1, 1, r * 2 + 1));
			lastBlockIsBotton = block.isBottom;
		}
		for (c = 1; c < col; c++)
		{
			for (r = 0; r < row; r++)
			{
				if (r == 0) lastBlockIsBotton = false;
				block = new Block(!lastBlockIsBotton, false);
				bitmapData.draw(block, new Matrix(1, 0, 0, 1, c * 2+1, r * 2+1));
				lastBlockIsBotton = block.isBottom;
			}
		}
		bitmapData.unlock();
	}
}

class Block
extends Sprite
{
	public var isBottom:Boolean;
	public static const XY:Array = [
		[0, -1], //top
		[1, 0], //right
		[0, 1], //bottom
		[-1, 0] //left
	];
	public function Block(hasTop:Boolean = true, hasLeft:Boolean = false) :void
	{
		graphics.beginFill(0x000000);
		graphics.drawRect(0, 0, 1, 1);
		var rot:uint = Math.floor(Math.random() * (2 + (hasLeft ? 1 : 0) + (hasTop? 1 : 0))) + (hasTop? 0 : 1);
		if (rot == 2) isBottom = true;
//		graphics.beginFill(0x999999);
		graphics.drawRect(XY[rot][0], XY[rot][1], 1, 1);
	}
}
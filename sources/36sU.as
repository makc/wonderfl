package  
{
	import flash.display.Sprite;
	[SWF(width="465", height="465", backgroundColor= 0xffffff, frameRate="60")]
	public class Maze 
	extends Sprite
	{
		
		public function Maze() :void
		{
			var maze:MazeContainer = new MazeContainer(50, 50);
			maze.scaleX = maze.scaleY = maze.x = maze.y = 5;
			addChild(maze);
		}
	}	
}
import flash.display.Sprite
class MazeContainer
extends Sprite
{
	public function MazeContainer(col:uint = 1, row:uint = 1) :void
	{
		var c:uint;
		var r:uint;
		var block:Block;
		for (c = 1; c < col; c++)
		{
			for (r = 0; r < row; r++)
			{
				block = new Block();
				block.x = c * 2;
				block.y = r * 2;
				addChild(block);
			}
		}
                //col:0
		for (r = 0; r < row; r++)
		{
			block = new Block(true);
			block.y = r * 2;
			addChild(block);
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
		graphics.drawRect(0, 0, 1, 1);
		var pt:Array = XY[Math.floor(Math.random() * (isFarLeft ? 4 : 3))];
		graphics.drawRect(pt[0], pt[1], 1, 1);
	}
}
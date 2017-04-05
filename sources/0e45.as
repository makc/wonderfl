
// write as3 code here..

/**
	rsakane
	迷路自動生成
	http://d.hatena.ne.jp/rsakane/20080612/p1
*/
package
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	
	public class Maze extends Sprite
	{
		private var maze:Array;
		private var SIZE:int = 21;
		
		public function Maze()
		{
			stage.addEventListener(MouseEvent.MOUSE_DOWN,
									function (event:MouseEvent):void
									{
										initialize();
										boutaoshi();
										draw();
									}
			);
			
			var tf:TextField = new TextField();
			setTextField(tf, 0, 220, stage.stageWidth, 50, false, TextFieldType.DYNAMIC);
			addChild(tf);
			tf.htmlText = '<font size="15">画面をクリックすると迷路を再生成できます</font>';
			
			initialize();
			boutaoshi();
			draw();
		}
		
		private function boutaoshi():void
		{
			for (var y:int = 2; y < SIZE - 1; y += 2)
			{
				var dx:int = 2;
				var dy:int = y;
				
				switch (Math.floor(Math.random() * 4))
				{
					case 0:
						dx++;
						break;
					case 1:
						dx--;
						break;
					case 2:
						dy++;
						break;
					case 3:
						dy--;
						break;
				}
				
				if (!maze[dx][dy])
				{
					maze[dx][dy] = true;
				}
				else
				{
					y -= 2;
				}
			}
			
			for (var x:int = 4; x < SIZE - 1; x += 2)
			{
				for (y = 2; y < SIZE - 1; y += 2)
				{
					dx = x;
					dy = y;
					
					switch (Math.floor(Math.random() * 3))
					{
						case 0:
							dy++;
							break;
						case 1:
							dy--;
							break;
						case 2:
							dx++;
							break;
					}
					
					if (!maze[dx][dy])
					{
						maze[dx][dy] = true;
					}
					else
					{
						y -= 2;
					}
				}
			}
		}
		
		private function draw():void
		{
			graphics.clear();
			graphics.beginFill(0x880000);
			for (var i:int = 0; i < SIZE; i++)
			{
				for (var j:int = 0; j < SIZE; j++)
				{
					if (maze[i][j])
					{
						graphics.drawRect(i * 10, j * 10, 10, 10);
					}
				}
			}
		}
		
		private function initialize():void
		{
			maze = new Array(SIZE);
			for (var i:int = 0; i < SIZE; i++)
			{
				maze[i] = new Array(SIZE);
			}
			
			for (i = 0; i < SIZE; i++)
			{
				for (var j:int = 0; j < SIZE; j++)
				{
					if (i == 0 || j == 0 || i == SIZE - 1 || j == SIZE - 1 || i % 2 == 0 && j % 2 == 0)
					{
						maze[i][j] = true;
					}
					else
					{
						maze[i][j] = false;
					}
				}
			}
		}
		
		public function setTextField(tf:TextField, x:int, y:int, width:int, height:int, border:Boolean, type:String, text:String = "")
		{
			tf.x = x;
			tf.y = y;
			tf.width = width;
			tf.height = height;
			tf.border = border;
			tf.type = type;
			tf.htmlText = text;
		}

	}
}

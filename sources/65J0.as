/**
    トレモー法で迷路探索
*/


package {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	


	public class SearchMazeMain extends Sprite
	{
		
		private var maze:Maze;
		private var searchMaze:TremauxSearch;
		private var bitmap:Bitmap;
		

		private const WIDTH:Number = 41;
		private const HEIGHT:Number = 41;
		private const SCALE:Number = 10;
		
		private var cursor:Sprite;
		
		public function SearchMazeMain()
		{
	
		
			stage.frameRate = 10;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			var progressArray:Array = [];
			maze = new DigMaze(WIDTH,HEIGHT,progressArray);
		

			searchMaze = new TremauxSearch(maze, new Point(1,1), new Point(1, HEIGHT-2), new Array());
		
		
			var bitmapData:BitmapData = new BitmapData(WIDTH*SCALE, HEIGHT*SCALE);
			bitmap = new Bitmap(bitmapData);
			addChild(bitmap);
				
			cursor = new Sprite();
			addChild(cursor);
			var g:Graphics = cursor.graphics;
			g.beginFill(0x5500ff00ff);
			g.drawRect(0,0,SCALE,SCALE);
			g.endFill();
		
			//地図を描画
			drawMaze();
		
		
			this.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		

		private var cnt:int = 0;
		private function enterFrameHandler(event:Event):void
		{
			var l:int = 5;
			for(var i:int = 0; i<l; i++)
			{
				drawSearch();
			}
			if(cnt == maze.buildProgressArray.length)
			{
				this.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
			}
		}
		
		private function drawSearch():void
		{
			if(cnt == searchMaze.buildProgressArray.length)
			{
				return;
			}
			
			var point:MazePoint = searchMaze.buildProgressArray[cnt];
			var color:Number;
			if(point.value == 2)
			{
				//一回通った
				color = 0x550000ff;
			}
			else
			{
				//2回通った。
				color = 0xff0000ff;
			}
			var scale:Number = 3;
			
			var bitmapData:BitmapData = bitmap.bitmapData;
			
			rect.x = point.x * SCALE;
			rect.y = point.y * SCALE;
			rect.width = SCALE;
			rect.height = SCALE;
			
			
			bitmapData.fillRect(rect, color);

			cursor.x = point.x * SCALE;
			cursor.y = point.y * SCALE;

			
			cnt++;
		
		}
		
		
		private var rect:Rectangle = new Rectangle(0,0,0,0);
		
		private function drawMaze():void
		{
			var bitmapData:BitmapData = bitmap.bitmapData;

			maze.data.forEach(function(p:uint, i:int, arr:Array):void{
			
				var x:int = i%maze.width;
				var y:int = int(i/maze.height);
			
				
			
				var color:Number;
				if(p == 0)
				{
					color = 0xffffffff;
				}
				else
				{
					color = 0xff000000;
				}
				var scale:Number = 3;
				
				
				rect.x = x*SCALE;
				rect.y = y*SCALE;
				rect.width = SCALE;
				rect.height = SCALE;
				
				
				bitmapData.fillRect(rect, color);
			});
                           if(!searchMaze)
                            return;
			
			//ゴールを描画
			rect.x = searchMaze.goalPoint.x * SCALE;
			rect.y = searchMaze.goalPoint.y * SCALE;
			rect.width = SCALE;
			rect.height = SCALE;
			bitmapData.fillRect(rect, 0xffff0000);

		}
	}
}

    class Maze 
    { 
         
        public var width:uint; 
        public var height:uint; 
        public var data:Array; 
        public var buildProgressArray:Array; 
         

        public function Maze(width:uint, height:uint, buildProgressArray:Array = null) 
        { 
            this.width = width; 
            this.height = height; 
            this.buildProgressArray = buildProgressArray; 
            initialize(); 
        } 
         
        protected function initialize():void 
        { 
            data = []; 
        } 
         
         
        protected function setData(x:uint, y:uint, value:uint):void 
        {     
            //value : 1(壁)　, 0(道) 
            data[x + width*y] = value; 

            if(buildProgressArray) 
            { 
                buildProgressArray.push(new MazePoint(x, y, value)); 
            } 
        } 

        public function getData(x:uint, y:uint):uint 
        { 
            return data[x + width*y]; 
        } 

    } 



    import flash.geom.Point; 
     
    class DigMaze extends Maze 
    { 
         
         

        public function DigMaze(width:uint, height:uint, buildProgressArray:Array = null,density:Number = 1) 
        { 
            super(width, height, buildProgressArray); 
             
        } 
         
        override protected function initialize():void 
        { 
            super.initialize(); 
             
            setDefWall(); 
            setWall(); 
             

        } 
         
        private var startPointArray:Array = []; 
         
        private function setDefWall():void 
        { 
            //まずすべてを壁でうめる 
            for(var y:int = 0; y< height; y++) 
            { 
                for(var x:int = 0; x< width; x++) 
                { 
                    setData(x,y,1); 
                     
                    //起点になれる座標配列を作る。 
                    if(y==0 || y == height-1 || x==0 || x == width-1) 
                    { 
                        continue; 
                    } 
                    if(x%2 == 1 && y%2 == 1) 
                    { 
                        startPointArray.push(new MazePoint(x,y,1)); 
                    } 
                     
                 
                }     
            } 
             
            //↓シャッフル・・をさせる。 
            //startPointArray. 
             
        } 
         
         
        private function setWall():void 
        { 
             
            startPointArray.forEach(function(p:MazePoint,i:int, arr:Array):void 
            { 

                if(p.value != 0) 
                { 
                    var loop:Boolean = true; 
                     
                    var x:uint = p.x; 
                    var y:uint = p.y; 
                     
                    while(loop) 
                    { 
                        var dir:String = checkRandomDicrectionCreate2Panel(x,y); 
                     

                        if(dir != "") 
                        { 
                            //塗りつぶし処理をする。と。 
                            //setData(x,y,0); 
                            switch(dir) 
                            { 
                                case TOP: 
                                    setData(x,y-1,0); 
                                    setData(x,y-2,0); 
                                    y -= 2; 
                                    break; 
                                case RIGHT: 
                                    setData(x+1,y,0); 
                                    setData(x+2,y,0); 
                                    x+=2; 
                                     
                                    break; 
                                case BOTTOM: 
                                    setData(x,y+1,0); 
                                    setData(x,y+2,0); 
                                    y +=2; 
                                    break; 
                                case LEFT: 
                                    setData(x-1,y,0); 
                                    setData(x-2,y,0); 
                                    x -=2; 
                                    break; 
                            } 
                        } 
                        else 
                        { 
                            loop = false; 
                        } 
                    } 
                } 
             
            }); 
        } 
         
        private static const TOP:String = "top"; 
        private static const RIGHT:String = "right"; 
        private static const BOTTOM:String = "bottom"; 
        private static const LEFT:String = "left"; 
         
        private function checkRandomDicrectionCreate2Panel(x:uint, y:uint):String 
        { 
            //生成できる方向をかえす 
            var enabledArray:Array = []; 
            if(getData(x-1,y) == 1 && getData(x-2,y) == 1 && x!=2) 
            { 
                //左は動ける。 
                enabledArray.push(LEFT); 
            } 
            if(getData(x,y-1) == 1 && getData(x,y-2) == 1 && y!=2) 
            { 
                //上に動ける。 
                enabledArray.push(TOP); 
            } 
            if(getData(x+1,y) == 1 && getData(x+2,y) == 1 && x!=width-2) 
            { 
                //右に動ける。 
                enabledArray.push(RIGHT); 
            } 
            if(getData(x,y+1) == 1 && getData(x,y+2) == 1 && y!=height-2) 
            { 
                //下に動ける。 
                enabledArray.push(BOTTOM); 
            } 

            if(enabledArray.length > 0) 
            { 
                return enabledArray[int(enabledArray.length*Math.random())]; 
            } 
            return ""; 
        } 
         

    } 




     class Direction
	{
		public static const TOP:String = "top";
		public static const RIGHT:String = "right";
		public static const BOTTOM:String = "bottom";
		public static const LEFT:String = "left";

	}






     
    import flash.geom.Point; 
    class MazePoint extends Point 
    { 
        public var value:int; 
        public function MazePoint(x:Number,y:Number,value:int) 
        { 
            super(x,y); 
            this.value = value; 
        } 
         
    } 



    //サーチャー
	class TremauxSearcher
	{
		
		private static const DIRECTIONS:Array = [Direction.TOP, Direction.RIGHT, Direction.BOTTOM, Direction.LEFT];

		public var direction:int;
		private var maze:Maze;
			
		
		public function TremauxSearcher(direction:uint, maze:Maze)
		{
			this.direction = direction;
			this.maze = maze;
			x = 1;
			y = 1;
		}
		
		//セッタ
		private var _x:uint;
		public function set x(value:uint):void
		{
			_oldX = _x;
			_x = value;
		}
		
		public function get x():uint
		{
			return _x;
		}
		
		private var _oldX:uint;
		public function get oldX():uint
		{
			return _oldX;
		}
		
		private var _y:uint;
		public function set y(value:uint):void
		{
			_oldY = _y;
			_y = value;
		}
		
		private var _oldY:uint;
		public function get oldY():uint
		{
			return _oldY;
		}
		
		public function get y():uint
		{
			return _y;
		}
		

		
		
		
		
		public function forword():void
		{
			//前方が道か調べる。
			
			if(isForwordWall(x,y))
			{
				//前が壁の場合。
				//右を向く
				turnRight();
				if(isForwordWall(x,y))
				{
					//左を向く
					turnLeft();
					turnLeft();
					if(isForwordWall(x,y))
					{
						//後を向く
						turnLeft();	
					}
				}
			}
			//一歩進む。
			move(1);

			

		}
		

		
		public function trunBack():void
		{
			turnRight();
			turnRight();
		}
		
		public function turnRight():void
		{
			direction++;
			if(direction == 4)
			{
				direction = 0
			}
		}
		
		public function turnLeft():void
		{
			direction--;
			if(direction == -1)
			{
				direction = 3;
			}		
		}
		
		private function move(value:int):void
		{
			switch(direction)
			{
				case 0:
					//上向き
					x = x;
					y -= value;
					break;
				case 1:
					//右向き
					x += value;
					y=y;
					break;
				case 2:
					//下向き
					x = x;
					y += value;
					break;
				case 3:
					//左向き
					x -= value;
					y = y;
					break;
			}
		}
		
		
		private function isForwordWall(posX:uint, posY:uint):Boolean
		{
			//正面が壁か否か
			switch(direction)
			{
				case 0:
					//上向き
					posY -= 1;
					break;
				case 1:
					//右向き
					posX += 1;
					break;
				case 2:
					//下向き
					posY += 1;
					break;
				case 3:
					//左向き
					posX -= 1;
					break;
			}
			//自分の前が壁か調べる。
			
			
			return (maze.data[posX + maze.width*posY] == 1);

		}
		
	}



//サーチ

	class TremauxSearch
	{
		
		//検索結果をまるごと格納。
		public var data:Array;
		
		private var searchData:Array;
		
		private var maze:Maze;
		public var startPoint:Point;
		public var goalPoint:Point;
		
		private var searcher:TremauxSearcher;
		
		//捜索過程を格納
		public var buildProgressArray:Array;
		
		
		

		public function TremauxSearch(maze:Maze, startPoint:Point, goalPoint:Point, buildProgressArray:Array = null)
		{
			this.maze = maze;
			this.startPoint = startPoint;
			this.goalPoint = goalPoint;
			this.buildProgressArray = buildProgressArray;
			
			
			
			this.initialize();
		}
		
		protected function initialize():void
		{
			searcher = new TremauxSearcher(0, maze);
			searcher.x = 1;
			searcher.y = 1;
			
			searchData = [].concat(maze.data);
			
			move();
		}
		

		protected function move():void
		{
			
			var loop:Boolean = true;
			var cnt:int = 0;
			var cntMax:int = 50000;	//たどり着けない疑いあり・・・のため。。
			//while(loop)
			while(cnt++ < cntMax )
			{
				if(!loop)
				{
					cnt = cntMax;
					return;
				}
				
				//移動する
				searcher.forword();
				setMark(searcher.x, searcher.y);
				

				if(isGoal(searcher.x, searcher.y))
				{
					//ゴール。
					loop = false;
					//trace("ゴール");
				}
				else if(this.isDive(searcher.x, searcher.y))
				{
					//分岐点に来た。
					var mark:uint = getData(searcher.x, searcher.y);
					if(mark == 2)
					{
						//初めて来た分岐点
						//道を一本選んで進む。
						loop = selectRoadAndTurn();
					}
					else if(mark == 3 && getData(searcher.oldX, searcher.oldY)==3)
					{
						//行き止まりで戻ってきた場合
						loop = selectRoadAndTurn();
					}
					else
					{
						//来たことのある分岐点の場合は引き返す。
						searcher.trunBack();
					}
					
				}
				else if(this.isDeadEnd(searcher.x, searcher.y))
				{
					//行き止まりの場合は引き返す。
					searcher.trunBack();
					setMark(searcher.x, searcher.y);
				}
				

			}
			
			
		}
		
		private function isGoal(x:uint, y:uint):Boolean
		{
			return (goalPoint.x == x && goalPoint.y == y);
		}
		
		private function isDeadEnd(x:uint, y:uint):Boolean
		{
			//行き止まり
			var top:uint = getData(x,y-1);
			var right:uint = getData(x+1,y);
			var bottom:uint = getData(x,y+1);
			var left:uint = getData(x-1,y);
			var deadEndCnt:uint=0;
			if(top == 1)deadEndCnt++;
			if(right == 1)deadEndCnt++;
			if(bottom == 1)deadEndCnt++;
			if(left == 1)deadEndCnt++;
			return (deadEndCnt >= 3)
		}
		
		private function isDive(x:uint, y:uint):Boolean
		{
			//分岐点か否か

			
			var top:uint = getData(x,y-1);
			var right:uint = getData(x+1,y);
			var bottom:uint = getData(x,y+1);
			var left:uint = getData(x-1,y);
			var diveCnt:uint=0;
			if(top != 1)diveCnt++;
			if(right != 1)diveCnt++;
			if(bottom != 1)diveCnt++;
			if(left != 1)diveCnt++;
			return (diveCnt >= 3)
		}
		
		private function selectRoadAndTurn():Boolean
		{
			//道を選んで、方向を合わせておく。
			var x:uint = searcher.x;
			var y:uint = searcher.y;

			var top:uint = getData(x,y-1);
			var right:uint = getData(x+1,y);
			var bottom:uint = getData(x,y+1);
			var left:uint = getData(x-1,y);
			

			//通ったことのない道を優先させる。
			if(top == 0 && !isOldPos(x,y-1))
			{
				//上に進める
				searcher.direction = 0;
				return true;
			}
			
			if(right == 0 && !isOldPos(x+1,y))
			{
				//右に進める
				searcher.direction = 1;
				return true;
			}
			
			if(bottom == 0 && !isOldPos(x,y+1))
			{
				//下に進める
				searcher.direction = 2;
				return true;
			}
			
			if(left == 0 && !isOldPos(x-1,y))
			{
				//左に進める
				searcher.direction = 3;
				return true;
			}
			
			if(top == 2 && !isOldPos(x,y-1))
			{
				//上に進める
				searcher.direction = 0;
				return true;
			}
			
			if(right == 2 && !isOldPos(x+1,y))
			{
				//右に進める
				searcher.direction = 1;
				return true;
			}
			
			if(bottom == 2 && !isOldPos(x,y+1))
			{
				//下に進める
				searcher.direction = 2;
				return true;
			}
			
			if(left == 2 && !isOldPos(x-1,y))
			{
				//左に進める
				searcher.direction = 3;
				return true;
			}			
			
			return false;

		}
		
		private function isOldPos(x:uint, y:uint):Boolean
		{
			return(searcher.oldX == x && searcher.oldY == y);
		}
		
		public function getData(x:uint, y:uint):uint
		{
			return searchData[x + maze.width*y];
		}
				
		protected function setMark(x:uint, y:uint):void
		{
			var d:uint = searchData[x + maze.width*y];
			var value:uint;
			if(d == 0)
			{
				value = 2;
				searchData[x + maze.width*y] = value;
			}
			else if(d == 2)
			{
				value = 3;
				searchData[x + maze.width*y] = value;
			}
			
			if(buildProgressArray)
			{
				buildProgressArray.push(new MazePoint(x,y,value));
			}
			
		}


	}


	

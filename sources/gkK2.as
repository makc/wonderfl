//	shift + click  Flg
//	click Open
package
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.Timer;

	public class Minesweeper extends Sprite
	{
		private const num:int = 16;
		private const bomb:int = 40;
		private var _cellCount:uint=num*num;
		
		private var _cellList:Array = [];
		private var _numList:Array = [];
		private var _mineList:Array = [];
		private var _time:Timer;
		private var _timeCount:uint;
		private var _timeTf:TextField;
		private var _bombCount:uint=0;
		private var _bombTf:TextField;
		
		public function Minesweeper()
		{
			if(stage)init();
			else addEventListener(Event.ADDED_TO_STAGE,init);
		}
		
		private function init(e:Event=null):void
		{
			removeEventListener(Event.ADDED_TO_STAGE,init);
			var i:int,q:int,n:int,m:int;
			for(i=0; i<num; i++)
			{
				var list:Array = [];
				for(q=0; q<num; q++)
				{
					var cell:Cell = addChild(new Cell())as Cell;
					cell._i = i;
					cell._q = q;
					cell.addEventListener("OUT",gameOver);
					cell.addEventListener("OPEN",open);
					cell.addEventListener("OPEN_COUNT",openCount);
					cell.addEventListener("FLG",MineCount);
					list.push(cell);
					cell.x = q*28;
					cell.y = i*28;
				}
				_cellList.push(list);
			}
			i=0;
			while(i<bomb)
			{
				n = Math.random()*num;
				q = Math.random()*num;
				if(!_cellList[n][q].bomb)
				{
					_cellList[n][q].bomb = true;
					_mineList.push(_cellList[n][q]);
					i++;
				}
			}
			
			for(i=0; i<num; i++)
			{
				for(q=0; q<num; q++)
				{
					var count:uint=0;
					for(n=-1; n<2; n++)
					{
						for(m=-1; m<2; m++)
						{
							if((i+n>=0 && q+m>=0) && (i+n<num && q+m<num))
							{
								if(n==0 && m==0)count = count;
								else if(_cellList[i+n][q+m].bomb)count++;
							}
						}
					}
					_cellList[i][q]._num = count;
				}
			}
			
			_timeTf = addChild(new TextField())as TextField;
			_timeTf.text = "TIME: 0";
			_timeTf.autoSize = TextFieldAutoSize.LEFT;
			_timeTf.x=5;
			_timeTf.y = 452;
			
			_bombTf = addChild(new TextField())as TextField;
			_bombTf.text = "MINE: 0/" + bomb.toString();;
			_bombTf.autoSize = TextFieldAutoSize.LEFT;
			_bombTf.x=100;
			_bombTf.y = 452;
			
			_time = new Timer(1000);
			_time.addEventListener(TimerEvent.TIMER,timeCount);
			_time.start();
			
			function timeCount(e:TimerEvent):void
			{
				_timeCount++;
				_timeTf.text = "TIME: "+_timeCount.toString();
			}
		}
		
		private function open(e:Event):void
		{
			var i:int,q:int,n:int,m:int;
			i = e.currentTarget._i;
			q = e.currentTarget._q;
			for(n=-1; n<2; n++)
			{
				for(m=-1; m<2; m++)
				{
					if((i+n>=0 && q+m>=0) && (i+n<num && q+m<num))
					{
						if(n!=0 || m!=0)
						{
							var cell:Cell = _cellList[i+n][q+m];
							if(cell.flg && !cell.bomb) cell.click();
						}
					}
				}
			}
			_cellCount--;
			if(_cellCount==bomb) End("CLEAR!! "+_timeTf.text);
		}
		
		private function openCount(e:Event):void
		{
			_cellCount--;
			if(_cellCount==bomb) End("CLEAR!! "+_timeTf.text);
		}
		
		private function MineCount(e:Event):void
		{
			if(e.target._sFlg) _bombCount++;
			else _bombCount--;
			
			_bombTf.text = "MINE: " + _bombCount.toString() + "/" + bomb.toString();
			if(_bombCount==bomb)  clearJ();
			else if(_cellCount==bomb) End("CLEAR!! "+_timeTf.text);
		}
		
		private function clearJ():void
		{
			var clearFlg:Boolean=true;
			var i:uint=0;
			for(i=0; i<bomb; i++)
			{
				if(!_mineList[i]._sFlg)clearFlg=false;
			}
			if(clearFlg)End("CLEAR!! "+_timeTf.text);
		}
		
		private function gameOver(e:Event):void
		{
			var i:uint,q:uint;
			for(i=0; i<num; i++)
			{
				for(q=0; q<num; q++)
				{
					_cellList[i][q].click(null,true);
				}
			}
			End("GAME OVER");
		}
		
		private function End(str:String):void
		{
			var caver:Sprite = addChild(new Sprite())as Sprite;
			caver.graphics.beginFill(0xffffff,0.3);
			caver.graphics.drawRect(0,0,465,465);
			caver.graphics.endFill();
			_time.stop();
			var tf:TextField = addChild(new TextField())as TextField;
			tf.autoSize = TextFieldAutoSize.LEFT;
			tf.defaultTextFormat = new TextFormat("_ゴシック",20,0,true);
			tf.text = str
			tf.selectable = false;
			tf.x = stage.stageWidth*0.5 - tf.width*0.5;
			tf.y = stage.stageHeight*0.5 - tf.height*0.5;
		}
	}
}
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.text.TextFieldAutoSize;

class Cell extends Sprite
{
	private var _tf:TextField;
	public var _num:uint=0;
	public var bomb:Boolean = false;
	public var flg:Boolean = true;
	public var _sFlg:Boolean = false;
	public var _i:uint;
	public var _q:uint;
	
	public function Cell()
	{
		draw();
		addEventListener(MouseEvent.CLICK,click);
		this.buttonMode = true;
	}
	
	private function draw(color:uint=0xcccccc):void
	{
		this.graphics.clear();
		this.graphics.beginFill(color);
		this.graphics.lineStyle(1,0xaaaaaa);
		this.graphics.drawRect(0,0,28,28);
		this.graphics.endFill();
	}
	
	public function click(e:MouseEvent = null , end:Boolean=false):void
	{
		removeEventListener(MouseEvent.CLICK,click);
		flg = false;
		if(e && e.shiftKey)
		{
			if(_sFlg) draw();
			else draw(0x0000ff);
			_sFlg = !_sFlg;
			dispatchEvent(new Event("FLG"));
			flg = true;
			addEventListener(MouseEvent.CLICK,click);
		}
		else if(bomb)
		{
			draw(0xff0000);
			if(!end)dispatchEvent(new Event("OUT"));
		}
		else
		{
			this.buttonMode = false;
			draw(0xdddddd);
			if(_num!=0)
			{
				_tf = addChild(new TextField())as TextField;
				_tf.selectable = false;
				_tf.text = _num.toString();
				_tf.autoSize = TextFieldAutoSize.LEFT;
				_tf.x = 14 - _tf.width*0.5;
				_tf.y = 14 - _tf.height*0.5;
				if(!end)dispatchEvent(new Event("OPEN_COUNT"));
			}
			else
			{
				if(!end)dispatchEvent(new Event("OPEN"));
			}
		}
	}
}
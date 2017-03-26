package 
{
	import com.actionsnippet.qbox.QuickBox2D;
	import flash.display.Graphics;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	/**
	 * マウスドラッグで物体を作成。
	 * @author paq89
	 */
	[SWF(backgroundColor="0xFFFFFF", width=465, height=465, frameRate=60)]
	public class Main extends Sprite 
	{
		private var _qbox:QuickBox2D;
		private var _points:/*int*/Array
		private var _isMouseDown:Boolean;
		private var _dx:Number;
		private var _dy:Number;
		private var _line:Shape;
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			_points = [];
			_isMouseDown = false;
			_line = new Shape();
			_line.graphics.lineStyle(1, 0);
			
			_qbox = new QuickBox2D(addChild(new MovieClip) as MovieClip);
			_qbox.createStageWalls();
			_qbox.start();
			
			addChild(_line);
			
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		}
		
		private function onMouseDown(e:MouseEvent):void 
		{
			_isMouseDown = true;
			_dx = mouseX;
			_dy = mouseY;
			
			_line.graphics.moveTo(mouseX, mouseY);
		}
		
		private function onMouseUp(e:MouseEvent):void 
		{
			if (_points.length > 1)
			{
				var avgX:Number = 0;
				var avgY:Number = 0;
				
				var len:uint = _points.length;
				for (var i:uint = 0; i < len; i += 2)
				{
					avgX += _points[i];
					avgY += _points[i + 1];
				}
				
				avgX /= _points.length / 2;
				avgY /= _points.length / 2;
				
				for (i = 0; i < len; i += 2)
				{
					var yp:int = i + 1;
					_points[i] -= avgX;
					_points[yp] -= avgY;
					_points[i] = Number(_points[i].toFixed(2));
					_points[yp] = Number(_points[yp].toFixed(2));
				}
				
				try
				{
					_qbox.addPoly( { x:avgX, y:avgY, points:_points } );
				}
				catch (e:*)
				{
					//
				}
			}
			_points = [];
			_isMouseDown = false;
			_line.graphics.clear();
			_line.graphics.lineStyle(1, 0);
		}
		
		
		private function onMouseMove(e:MouseEvent):void 
		{
			if (Math.abs(_dx - mouseX) > 5 && Math.abs(_dy - mouseY) > 5 && _isMouseDown)
			{
				_points.push(mouseX / 30.0, mouseY / 30.0);
				_dx = mouseX;
				_dy = mouseY;
				
				_line.graphics.lineTo(mouseX, mouseY);
			}
		}
		
	}
	
}
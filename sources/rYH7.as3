package 
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.GlowFilter;
	import net.hires.debug.Stats;
	/**
	 * AdvancED Actionscript 3 
	 * Advanced Collision Detectionより
	 * 
	 * grid- based collision detection
	 * 
	 * @author Motoki Matsumoto
	 */
	public class GridBaseCollisionDetection extends Sprite
	{
		private var _numBallFixed:uint = 100;
		private var _numBall:uint = 100;
		private var _background:Sprite;
		private var _circles:Vector.<Circle>;
		private var _dt:Number;
		private var _grid:Grid;
		private var _gridSize:Number = 30;
		private var _screen:Sprite;
		
		public function GridBaseCollisionDetection() 
		{
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		}
		
		private function addedToStageHandler(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			init();
		}
		private function init():void {
			addChild(_background = new Sprite());
			drawGrid(50);
			_dt = 1 / stage.frameRate;
			
			addChild(_screen = new Sprite());

			makeCircles();
			
			_grid = new Grid(stage.stageWidth, stage.stageHeight, _gridSize);
			
			addChild(new Stats());
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		private function makeCircles():void
		{
			var w:Number = stage.stageWidth;
			var h:Number = stage.stageHeight;
			var c:Circle;
			var i:int;
			
			_circles = new Vector.<Circle>();
			for (i = 0; i < _numBallFixed; i++) {
				c = new Circle(6);
				_circles.push(c);
				c.displayObj = new Ball(c.r, 0x00ff55);
				c.x = c.displayObj.x = w * Math.random();
				c.y = c.displayObj.y = h * Math.random();
				c.fixed = true;
				addChild(c.displayObj);
			}
			for (i = 0; i < _numBall; i++) {
				c = new Circle(2);
				_circles.push(c);
				c.displayObj = new Ball(c.r, 0xff5500);
				c.x = c.displayObj.x = w * Math.random();
				c.y = c.displayObj.y = h * Math.random();
				addChild(c.displayObj);
			}

		}
		
		private function enterFrameHandler(e:Event):void 
		{
			var len:int = _circles.length;
			var c:Circle;
			for (var i:int = 0; i < len; i++) {
				c = _circles[i] as Circle;
				c.step(_dt);
				c.accelerate(0, 0.09);
				c.displayObj.x = c.x;
				c.displayObj.y = c.y;
				if (c.y > stage.stageHeight) {
					c.y = 0;
					c.vx = 0;
					c.vy = 0;
				}
			}
			var vecCol:Vector.<Collision>;
			var col:Collision;
			
			/*-----------------------------------
			 *  collisionCheckAを使うと、総当たりで衝突判定
			 *  collisionCheckBを使うと、グリッドを使った衝突判定を行います。
			 *  比較したい場合は書き換えてください。
			 -----------------------------------*/
			
			//vecCol = collisionCheckA();
			vecCol = collisionCheckB();
			
			showCollisions(vecCol);
		}
		
		private function showCollisions(collisions:Vector.<Collision>):void
		{
			var len:int = collisions.length;
			var col:Collision;
			var i:int;
			_screen.graphics.clear();
			for (i = 0; i < len; i++) {
				col = collisions[i];
				_screen.graphics.beginFill(0x0000ff);
				_screen.graphics.drawCircle(col.c1.x, col.c1.y, col.c1.r+2);
				_screen.graphics.endFill();

				_screen.graphics.beginFill(0x0000ff);
				_screen.graphics.drawCircle(col.c2.x, col.c2.y, col.c2.r+2);
				_screen.graphics.endFill();
			}
		}
		/*
		 * グリッドベースの衝突チェック
		 */
		private function collisionCheckB():Vector.<Collision>
		{
			return _grid.check(_circles);
		}
		
		/*
		 * 総当たり衝突チェック
		 */
		private function collisionCheckA():Vector.<Collision>
		{
			var i:int = 0, j:int = 0;
			var len:int = _circles.length;
			var c1:Circle, c2:Circle;
			var collisions:Vector.<Collision> = new Vector.<Collision>();
			for (i = 0; i < len; i++) {
				c1 = _circles[i];
				for (j = i+1; j < len; j++) {
					c2 = _circles[j];
					
					if (c1.hitTest(c2)) {
						collisions.push(new Collision(c1, c2));
					}
				}
			}
			return collisions;
		}
		
		private function drawGrid(span:Number):void {
			var g:Graphics = _background.graphics;
			if (span < 0) {
				return ;
			}
			
			g.clear();
			g.lineStyle(1, 0xccccff);
			var w:Number = stage.stageWidth;
			var h:Number = stage.stageHeight;
			var n:Number;
			n = 0;
			while (n < h) {
				g.moveTo(0, n);
				g.lineTo(w, n);
				n += span;
			}
			
			n = 0;
			while (n < w) {
				g.moveTo(n, 0);
				g.lineTo(n, h);
				n += span;
			}
		}
		
	}

}
import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.Sprite;
class Ball extends Sprite {
	private var _r:Number;
	private var _color:uint;
	public function Ball(r:Number = 10, color:uint = 0xcccccc):void {
		_r = r;
		_color = color;
		_draw();
	}
	
	private function _draw():void
	{
		var g:Graphics = this.graphics;
		g.clear();
		g.beginFill(_color);
		g.drawCircle(0, 0, _r);
		g.endFill();
	}
	
	public function get r():Number { return _r; }
	public function set r(value:Number):void 
	{
		_r = value;
		_draw();
	}
	
	public function get color():uint { return _color; }
	public function set color(value:uint):void 
	{
		_color = value;
		_draw();
	}
}
class Collision {
	public var c1:Circle;
	public var c2:Circle;
	public function Collision(c1:Circle, c2:Circle) {
		this.c1 = c1;
		this.c2 = c2;
	}
}

class Circle {
	public var x:Number = 0;
	public var y:Number = 0;
	public var vx:Number = 0;
	public var vy:Number = 0;
	public var r:Number;
	public var friction:Number = 1;
	private var _fixed:Boolean;
	public var displayObj:DisplayObject;
	
	public function Circle(r:Number) {
		this.r = r;
	}
	public function hitTest(b:Circle):Boolean {
		if (b == this) return false;
		
		var dx:Number = x - b.x;
		var dy:Number = y - b.y;
		var d:Number = Math.sqrt(dx * dx + dy * dy);
		if ((b.r + r ) >  d) {
			return true;
		}
		return false;
	}
	public function accelerate(ax:Number, ay:Number):void {
		if (_fixed) return;
		vx += ax;
		vy += ay;
	}
	public function step(t:Number):void {
		if (_fixed) return;
		x += vx * t;
		y += vy * t;
		vx *= friction;
		vy *= friction;
	}
	
	public function get fixed():Boolean { return _fixed; }
	public function set fixed(value:Boolean):void 
	{
		_fixed = value;
		if (_fixed) {
			vx = 0;
			vy = 0;
		}
	}
}

class Grid {
	private var _grid:Vector.<Vector.<Circle>>;
	private var _size:Number;
	private var _gridLen:int;
	private var _cols:int;
	private var _rows:int;
	private var _collisions:Vector.<Collision>;
	public function Grid(width:Number, height:Number, size:Number) {
		_size = size;
		
		_cols = Math.ceil(width / size);
		_rows = Math.ceil(height / size);
		_gridLen = _cols * _rows;
	}
	
	public function check(circles:Vector.<Circle>):Vector.<Collision> {
		_grid = new Vector.<Vector.<Circle>>(_gridLen);
		
		_assign(circles);
		return _check();
	}
	private function _assign(circles:Vector.<Circle>):void {
		var c:Circle;
		var len:int = circles.length;
		var col:int, row:int;
		var vec:Vector.<Circle>;
		
		for (var i:int = 0; i < len; i++) {
			c = circles[i];
			col = Math.floor(c.x / _size);
			row = Math.floor(c.y / _size);
			if ( col >= _cols || row >= _rows) {
				//範囲外
			}else {
				vec = _grid[_cols * row + col];
				if (vec == null) {
					vec = _grid[_cols * row + col] = new Vector.<Circle>();
				}
				vec.push(c);
			}
		}
	}
	private function _check():Vector.<Collision> {
		var i:int, j:int;
		_collisions = new Vector.<Collision>();
		for (i = 0; i < _rows; i++) {
			for (j = 0; j < _cols; j++) {
				_checkSingleCell(j, i);
				_checkTwoCell(j, i, j+1, i);
				_checkTwoCell(j, i, j-1, i+1);
				_checkTwoCell(j, i, j,   i+1);
				_checkTwoCell(j, i, j+1, i+1);
			}
		}
		return _collisions;
	}
	
	private function _checkSingleCell(col:int, row:int):void {
		var c:Vector.<Circle> = _grid[_cols * row + col];
		if (c == null) return;
		var len:int = c.length;
		var i:int, j:int;
		var c1:Circle, c2:Circle;
		
		for (i = 0; i < len; i++) {
			c1 = c[i];
			for (j = i + 1; j < len; j++) {
				c2 = c[j];
				if (c1.hitTest(c2)) {
					_collisions.push(new Collision(c1, c2));
				}
			}
		}
	}
	
	private function _checkTwoCell(col1:int, row1:int, col2:int, row2:int):void{
		if (col2 < 0 || col2 >= _rows || row2 >= _cols) return;
		var vec1:Vector.<Circle> = _grid[_cols * row1 + col1];
		var vec2:Vector.<Circle> = _grid[_cols * row2 + col2];
		
		if (vec1 == null || vec2 == null) return;
		
		var len1:int = vec1.length;
		var len2:int = vec2.length;
		var c1:Circle, c2:Circle;
		
		var i:int, j:int;
		for (i = 0; i < len1; i++) {
			c1 = vec1[i];
			for (j = 0; j < len2; j++) {
				c2 = vec2[j];
				if (c1.hitTest(c2)) {
					_collisions.push(new Collision(c1,c2));
				}
			}
		}
		
	}
	
	public function get size():Number { return _size; }
	public function set size(value:Number):void 
	{
		_size = value;
	}
}

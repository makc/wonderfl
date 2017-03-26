/**
 * 本格的な布のシミュレーションではありません。
 *
 * ドラッグでマウスに一番近いポイントを移動させる。
 * ctrlキー押しながらドラッグで固定。
 * ダブルクリックで固定を解除。
 *
 * <問題点>
 * 左右対称になってない。右によってる。なんでだろう。
 */
package {
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;

    [SWF(backgroundColor="0xFFFFFF", width="465", height="465", frameRate="60")]
	public class Cloth extends Sprite {
		
		public static const STAGE_WIDTH:uint = 465;
		public static const STAGE_HEIGHT:uint = 465;
		
		public function Cloth() {
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private var _lineColor:uint = 0x000000;
		private var _cols:uint = 16;//横の数
        private var _rows:uint = 16;//縦の数
		private var _diffX:uint = 10;
        private var _diffY:uint = 10;
		private var _isCtrlPress:Boolean = false;
		private var _isMouseDown:Boolean = false;
		private var _draggedPoint:Point;
		private var _isFirst:Boolean = false;
		private var _numJoints:uint;
		private var _joints:Vector.<Joint> = new Vector.<Joint>();
		private var _points:Vector.<Point> = new Vector.<Point>();
		private var _pointsXs:Vector.<Vector.<Point>> = new Vector.<Vector.<Point>>(_rows, true);
		private var _pointsYs:Vector.<Vector.<Point>> = new Vector.<Vector.<Point>>(_cols, true);
		
		private function init(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			stage.scaleMode = StageScaleMode.NO_SCALE;
			//stage.quality = StageQuality.MEDIUM;
			
			stage.doubleClickEnabled = true;
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDwonHandler);
			stage.addEventListener(MouseEvent.DOUBLE_CLICK, doubleClickHandler);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDonwHandler);
			stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
			
			putPoint();
			joint();
			
			//上端2つを固定します。
			//左端
			var point1:Point = _pointsXs[0][0];
			point1.x = 100;
			point1.y = 10;
			point1.isPinned = true;
			
			//右端
			var point2:Point = _pointsXs[0][_rows - 1];
			point2.x = STAGE_WIDTH - 100;
			point2.y = 10;
			point2.isPinned = true;
			
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		/**
		 * ポイントを配置します。
		 */
		private function putPoint():void {
			//縦方向に並べたポイントを入れる配列を先に用意する
			for (var i:uint = 0; i < _cols; i++) { 
				var pointsY:Vector.<Point> = new Vector.<Point>(_rows, true);
				_pointsYs[i] = pointsY;
			}
			
			var clothWidth:Number = (_cols - 1) * _diffX;
			var clothHeight:Number = (_rows - 1) * _diffY;
			var startX:Number = (STAGE_WIDTH - clothWidth) / 2;
			var startY:Number = (STAGE_HEIGHT - clothHeight) / 2;
			
			//ポイントを格子状に配置
			for (i = 0; i < _rows; i++) {
				var pointsX:Vector.<Point> = new Vector.<Point>(_cols, true);
				_pointsXs[i] = pointsX;
				for (var j:uint = 0; j < _cols; j++) {
					var point:Point = new Point();
					_points.push(point);
					point.name = String(i) + "-" + String(j);//デバッグ用
					point.x = startX + _diffX * j;
					point.y = startY + _diffY * i;
					
					//横に並ぶポイントを入れる
					pointsX[j] = point;
					
					//縦方向に並ぶポイントを入れる
					pointsY = _pointsYs[j];
					pointsY[i] = point;
				}
			}
			_points.fixed = true;
		}
		
		private function joint():void {
			
			//00------01-------02
			//|        |       |
			//|        |       |
			//|        |       |
			//10------11-------12
			//|        |       |
			//|        |       |
			//|        |       |
			//20------21-------22
			
			for (var i:uint = 0; i < _rows; i++) {
				var up:Boolean = (i - 1) >= 0;//上の行があるか。
				var down:Boolean = (i + 1) < _rows;//下の行があるか。
				if (up)
					var pointsX0:Vector.<Point> = _pointsXs[i - 1];//一つ上の段
					
				var pointsX1:Vector.<Point> = _pointsXs[i];
				
				if (down)
					var pointsX2:Vector.<Point> = _pointsXs[i + 1];//一つ下の段
				
				for (var j:uint = 0; j < _cols; j++) {
					var left:Boolean = (j - 1) >= 0;//左の列があるか。
					var right:Boolean = (j + 1) < _cols;//右の列があるか。
					
					var point11:Point = pointsX1[j];//中央のポイント
					
					if (up) {
						var point01:Point = pointsX0[j];//上
						//trace(point01.name);
						_joints.push(new Joint(point11, point01));
					}
					
					if (left) { 
						var point10:Point = pointsX1[j -1];//左
						//trace(point10.name);
						_joints.push(new Joint(point11, point10));
						
						if (up) {
							var point00:Point = pointsX0[j - 1]; //左上
							//trace(point00.name);
							_joints.push(new Joint(point11, point00));
						}
						
						if (down) {
							var point20:Point = pointsX2[j -1];//左下
							//trace(point20.name);
							_joints.push(new Joint(point11, point20));
						}
					}
					
					if (right) { 
						var point12:Point = pointsX1[j + 1];//右
						//trace(point12.name);
						_joints.push(new Joint(point11, point12));
						
						if (up) {
							var point02:Point = pointsX0[j + 1];//右上
							//trace(point02.name);
							_joints.push(new Joint(point11, point02));
						}
						
						if (down) {
							var point22:Point = pointsX2[j + 1];//右下
							//trace(point22.name);
							_joints.push(new Joint(point11, point22));
						}
					}
					
					if (down) {
						var point21:Point = pointsX2[j];//下
						//trace(point21.name);
						_joints.push(new Joint(point11, point21));
					}
				}
			}
			_numJoints = _joints.length;
			_joints.fixed = true;
		}
		
		/**
		 * 一番カーソルに近いポイントを捜す。
		 */
		private function searchPoint():Point {
			var lastMinDist:Number = Infinity;
			var target:Point;
			for each(var point:Point in _points) {
				var dx:Number = point.x - mouseX;
				var dy:Number = point.y - mouseY;
				var dist:Number = Math.sqrt(dx * dx + dy * dy);
				if (dist < lastMinDist) {
					lastMinDist = dist;
					target = point;
				}
			}
			return target;
		}
		
		/**
		 * ポイント同士を繋ぐ線を書く
		 */
		private function drawLine():void {
			graphics.clear();
			graphics.lineStyle(1, _lineColor);
			//横のラインを引く
			for each(var pointsX:Vector.<Point> in _pointsXs){
				//横列のポイントが入った配列にアクセス。
				var firstPoint:Point = pointsX[0];
				graphics.moveTo(firstPoint.x, firstPoint.y);
				for (var i:uint = 1; i < _cols; i++) {
					var point:Point = pointsX[i];
					graphics.lineTo(point.x, point.y);
				}
			}
			
			for each(var pointsY:Vector.<Point> in _pointsYs) {
				firstPoint = pointsY[0];
				graphics.moveTo(firstPoint.x, firstPoint.y);
				for (i = 1; i < _rows; i++) {
					point = pointsY[i];
					graphics.lineTo(point.x, point.y);
				}
			}
		}
		
		private function enterFrameHandler(e:Event):void {
			if (_isMouseDown) {
				_draggedPoint.x = mouseX;
				_draggedPoint.y = mouseY;
			}
			
			for each(var joint:Joint in _joints) {
				joint.update();
			}
			
			drawLine();
		}
		
		private function keyDonwHandler(e:KeyboardEvent = null):void{
			if(e.ctrlKey) _isCtrlPress = true;
		}
		
		private function keyUpHandler(e:KeyboardEvent = null):void{
			_isCtrlPress = false;
		}
		
		private function doubleClickHandler(e:MouseEvent = null):void{
			searchPoint().isPinned = false;
		}
		
		private function mouseDwonHandler(e:MouseEvent):void {
			_isMouseDown = true;
			_draggedPoint = searchPoint();
			_draggedPoint.isDragging = true;
		}
		
		private function mouseUpHandler(e:MouseEvent):void	{
			_isMouseDown = false;
			if (_isCtrlPress)
				_draggedPoint.isPinned = true;
			_draggedPoint.isDragging = false;
			_draggedPoint = undefined;
		}
	}
}

class Joint {
	
	public static var SPRING:Number = 0.03;
	public static var FRICTION:Number = 0.97;
	public static var GRAVITY:Number = 0.005;
	
	public function Joint(point:Point, target:Point) { 
		var initDx:Number = target.x - point.x;
		var initDy:Number = target.y - point.y;
		var length:Number = Math.sqrt(initDx * initDx + initDy * initDy);
		var angle:Number = Math.atan2(initDy, initDx);
		
		var tx:Number = length * Math.cos(angle);
		var ty:Number = length * Math.sin(angle);
		
		//バネ運動させる関数
		update = function():void {
			if (point.isDragging || point.isPinned)
				return;
			
			var dx:Number = target.x - tx - point.x;
			var dy:Number = target.y - ty - point.y;
			point.vx += dx * Joint.SPRING;
			point.vy += dy * Joint.SPRING;
			point.vy += GRAVITY;
			point.x += (point.vx *= FRICTION);
			point.y += (point.vy *= FRICTION);
		}
	}
	
	public var update:Function;
}

class Point {
	public var name:String;
	public var x:Number;
	public var y:Number;
	public var vx:Number = 0;
	public var vy:Number = 0;
	public var isPinned:Boolean = false;
	public var isDragging:Boolean = false;
}
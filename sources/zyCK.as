package
{
	import __AS3__.vec.Vector;
	
	import caurina.transitions.Tweener;
	
	import flash.display.GraphicsPathCommand;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	
        [SWF(backgroundColor="#000000",frameRate="60")]
	public class LineConnection extends Sprite
	{
		private var prevPoint:Point;
		private var prevCore:LineCore;
		private var core:LineCore;
		private var point:Point;
		private var gc:GraphicsController;
		private var numLines:int = 5;
		private var lineGCs:Vector.<GraphicsController>;
		private var lineShapes:Vector.<Shape>;
		private var numSegment:int = 3;
		
		public function LineConnection()
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(event:Event=null):void{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			lineGCs = new Vector.<GraphicsController>();
			lineShapes = new Vector.<Shape>();
			
			point = new Point( Math.random()*stage.stageWidth, Math.random()*stage.stageHeight);
			moveNext();
			
			var timer:Timer = new Timer(1500);
			timer.addEventListener(TimerEvent.TIMER, timerHandler);
			timer.start();
		}
		
		private function timerHandler(event:TimerEvent):void{
			moveNext();
		}
		
		private function moveNext():void{
			prevPoint = point.clone();
			if( core ){
				core.addEventListener(Event.COMPLETE,function(event:Event):void{
					event.target.removeEventListener( event.type, arguments.callee);
					removeChild(LineCore(event.target));
				});
				core.disappear();
			}
			core = new LineCore(Math.random()*50 + 20);
			do{
			    point = new Point( Math.random()*stage.stageWidth*2, Math.random()*stage.stageHeight*2);
			} while ( Point.distance( prevPoint, point ) < 300 )
			core.x = point.x;
			core.y = point.y;
			
			generateLines();
			addChild(core);
		}
		
		private function generateLines():void{
			var radius:Number = Point.distance(prevPoint, point)/numSegment*1.5;
			
			for each( var shape:Shape in lineShapes ) removeChild(shape);
			lineGCs.splice(0,numLines);
			lineShapes.splice(0,numLines);
			
			for(var i:int=0;i<numLines;i++){
				var s:Shape = new Shape();
				var gc:GraphicsController = new GraphicsController(s.graphics);
				var commands:Vector.<int> = new Vector.<int>();
				var data:Vector.<Number> = new Vector.<Number>();
				lineGCs.push(gc);
				lineShapes.push(s);
				gc.thickness = Math.random()*5;
				gc.color = 0xBB0000;
				commands.push(GraphicsPathCommand.WIDE_MOVE_TO);
				data.push(0, 0, prevPoint.x, prevPoint.y);
				
				var prevCtrl:Point = prevPoint.add(new Point(Math.random()*radius,Math.random()*radius));
				for(var j:int=0;j<numSegment;j++){
					var basePoint:Point = Point.interpolate(prevPoint, point, 1 - (j+1)/numSegment);
					var ctrl:Point = basePoint.add(new Point(Math.random()*radius - radius/2,Math.random()*radius - radius/2));
					var pos:Point;
					if( j == numSegment-1) pos = point;
					else pos = Point.interpolate(prevCtrl, ctrl, .5);
					data.push( prevCtrl.x, prevCtrl.y, pos.x, pos.y);
					commands.push(GraphicsPathCommand.CURVE_TO);
					prevCtrl = ctrl.clone();
				}
				addChild(s);
				gc.drawLine(commands,data,0);
				Tweener.addTween(gc, { f:1, time:1.5, transition :"easeOutQuint"});
				Tweener.addTween(gc, { f0:1, time:1.5, transition:"easeInQuint"});
			}
			Tweener.addTween(this,{x:stage.stageWidth/2 - point.x, y:stage.stageHeight/2 - point.y, time:1.5});
		}
	}
}


    	import __AS3__.vec.Vector;
	
	import caurina.transitions.Tweener;
	import caurina.transitions.properties.DisplayShortcuts;
	
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	
	class LineCore extends Sprite {
		private var num:int;
		private var color:uint;
		private var radius:Number;
		private var weight:Number;
		private var gcAry:Vector.<GraphicsController>;
		
		public function LineCore(radius:Number=20, weight:Number=10, num:int=5, color:uint=0x555555){
			this.radius = radius;
			this.weight = weight;
			this.num = num;
			this.color = color;
			makePies();
			addAppearMotion();
			
			graphics.beginFill(0xFF0000);
			graphics.drawCircle(0,0,5);
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		private function makePies():void{
			gcAry = new Vector.<GraphicsController>;
			
			for(var i:int=0;i<num;i++){
				var s:Shape = new Shape();
				var gc:GraphicsController = new GraphicsController(s.graphics);
				gcAry.push(gc);
				gc.color = color;
				gc.drawPie( 0, 0, 0);
				s.rotation = i * 360 / num;
				addChild(s);
			}
		}
		
		private function addAppearMotion():void{
			for(var i:int=0;i<gcAry.length;i++){
				var gc:GraphicsController = gcAry[i];
				Tweener.addTween(gc, { degree:360/num - 5, radius:radius, time:.5, delay:i*.2 });
				Tweener.addTween(gc, { innerRadius:radius-weight, time:1, delay:i*.2, transition:"easeOutQuint" });
			}
			Tweener.addTween(this, {rotation:120, time:1.8 });
		}
		
		public function disappear():void{
			for(var i:int=0;i<gcAry.length;i++){
				var gc:GraphicsController = gcAry[i];
				if( i == 0 ){
					Tweener.addTween(gc, { degree:360, radius:radius*1.2, innerRadius:0, time:1});
					
				} else {
					Tweener.addTween(gc, { innerRadius:radius, time:.5, delay:i*.1 });
				}
			}
			DisplayShortcuts.init();
			Tweener.addTween(this, {rotation:359, time:1, transition:"linear" });
			Tweener.addTween(this, { _scale:0, time:.5, delay:.5, transition:"easeInQuint", onComplete:dispatch });
			
			function dispatch():void{
				dispatchEvent( new Event( Event.COMPLETE ));
			}
		}
		
		private function enterFrameHandler(event:Event):void{
			
		}
	}


	import __AS3__.vec.Vector;
	
	import flash.display.Graphics;
	import flash.display.GraphicsPathCommand;
	import flash.geom.Point;
	
	class GraphicsController {
		private var g:Graphics;
		public var speed:Number;
		public var thickness:Number = 1;
		public var color:Number = 0x3388DD;
		
		private var _degree:Number;
		private var _innerRadius:Number;
		private var _radius:Number;
		
		private var commands:Vector.<int>;
		private var data:Vector.<Number>;
		private var _f:Number;
		private var _f0:Number;
		
		public function GraphicsController(graphics:Graphics){
			this.g = graphics;
		}
		
		/**
		 * 弧をdrawPathで描画するためのデータを返します
		 */
		public function objectArc(radius:Number, degree:Number, opposite:Boolean=false):Object{
			//最終的に返す値。
			var commands:Vector.<int> = new Vector.<int>();
			var data:Vector.<Number> = new Vector.<Number>();
			
			if( Math.abs(degree) > 360 ) degree %= 360;
			
			var div:int = Math.ceil(degree/30);
			var radians:Number = degree * Math.PI / 180;
			var segment:Number = radians / div;
			var _from:Number;
			var _to:Number;
			for(var i:int;i<div;i++){
				//曲線の分割
				if( opposite ){
					_from = ( i == 0 ) ? radians : segment * ( div - i );
					_to = ( div - i - 1 ) * segment;
				} else {
					_from = segment * i;
					_to = (i == div-1) ? radians : segment * (i+1);
				}
				
				//初回ループ時に、最初の点に移動
				if( i == 0 ){
					var startPos:Point = new Point();
					startPos.x = Math.cos(_from) * radius;
					startPos.y = Math.sin(_from) * radius; 
					commands.push(2);
					data.push(startPos.x, startPos.y);
				}
				
				//終着点
				var endPos:Point = new Point();
				endPos.x = Math.cos(_to) * radius;
				endPos.y = Math.sin(_to) * radius;
				
				//コントロールポイント
				var controlPos:Point = new Point();
				var basePos:Point = opposite ? endPos : startPos;
				var rotate:Number = opposite ? _to : _from;
				controlPos.y = radius * Math.tan(Math.abs(_to - _from)/2);
				controlPos.x = basePos.x - Math.sin(rotate) * controlPos.y; 
				controlPos.y = basePos.y + Math.cos(rotate) * controlPos.y;
				
				//Vectorに格納
				commands.push(3);
				data.push(controlPos.x, controlPos.y, endPos.x, endPos.y);
				
				//次のループのために始点を移動
				startPos.x = endPos.x;
				startPos.y = endPos.y;
			}
			return { commands:commands, data:data };
		}
		
		/**
		 * 扇を描きます
		 */
		public function drawPie(degree:Number, radius:Number, innerRadius:Number = 0):void{
			this._degree = degree;
			this._radius = radius;
			this._innerRadius = innerRadius;
			
			if(degree > 0){
				g.clear();
				g.beginFill(color);
				var arc:Object = objectArc(radius,degree);
				if( innerRadius == 0 ){
					arc.commands.push(2);
					arc.data.push(0,0);
					g.drawPath(arc.commands, arc.data);
				} else {
					var oppositeArc:Object = objectArc(innerRadius,degree,true);
					g.moveTo(radius, 0);
					g.drawPath(arc.commands, arc.data);
					
					oppositeArc.commands.push(2);
					oppositeArc.data.push(radius, 0);
					g.drawPath(oppositeArc.commands, oppositeArc.data);
				}
			}
		}
			
		/**
		 * パスのトリミングをします
		 */
		public function drawLine(commands:Vector.<int>, data:Vector.<Number>,f:Number = 0.5,f0:Number = 0):void{
			this.commands = commands.concat();
			this.data = data.concat();
			this._f = f;
			this._f0 = f0;
			g.clear();
			g.lineStyle(thickness, color);
			
			var startPos:Point = new Point(data[2],data[3]);
			var endPos:Point = new Point();
			var trimPos:Point = new Point();
			var controlPoint:Point = new Point();
			var eachLength:Vector.<Number> = new Vector.<Number>();
			var com:Vector.<int> = commands.concat();
			var dat:Vector.<Number> = data.concat();
			
			if (f < f0){
				var a:Number = f;
				var b:Number = f0;
				f0 = a;
				f = b;
			}
			//全ての曲線の長さの合計をとっておく（それぞれの長さも）
			//長さの算出は今のところ直線距離（改良予定）
			var totalLength:Number = 0;
			var i:int;
			for(i=1;i<commands.length;i++){
				controlPoint = new Point(dat[i*4], dat[i*4+1]);
				endPos = new Point( dat[i*4+2], dat[i*4+3]);
				eachLength.push(Point.distance(startPos,controlPoint) + Point.distance(endPos,controlPoint));
				totalLength += eachLength[i-1];
				startPos = endPos.clone();
			}
			
			var length:Number = 0;
			var trimCtrl:Point;
			var _f:Number;
			var deleted:int = 0;
			if(f0 != 0){
				for(i=0;i<commands.length-1;i++){
					if( length + eachLength[i] >= f0*totalLength){
						deleted = i;
						_f = 1 - (f0*totalLength - length) / eachLength[i];
												
						startPos = new Point(dat[i*4+2], dat[i*4+3]);
						
						//コントロールポイント
						controlPoint = new Point(dat[(i+1)*4], dat[(i+1)*4+1]);
						endPos = new Point(dat[(i+1)*4+2],dat[(i+1)*4+3]);
						
						//分割
						trimCtrl = Point.interpolate(controlPoint,endPos,_f);
						trimPos = Point.interpolate(Point.interpolate(startPos,controlPoint,_f),trimCtrl,_f);
						
						com.splice(0, i+2);
						dat.splice(0, (i+2)*4);
						com.unshift(GraphicsPathCommand.CURVE_TO);
						com.unshift(GraphicsPathCommand.WIDE_MOVE_TO);
						dat.unshift(trimCtrl.x, trimCtrl.y, endPos.x, endPos.y);
						dat.unshift(0, 0, trimPos.x, trimPos.y)
						break;
					} else {
						length += eachLength[i];
					}
				}	
			}
			
			length = 0;
			if( _f != 1 ){
				for(i=0;i<commands.length;i++){
					if (length + eachLength[i] >= f*totalLength){
						//その線分内での割合を算出
						_f = (f*totalLength - length) / eachLength[i];
						
						i -= deleted;
						startPos = new Point(dat[i*4+2], dat[i*4+3]);
						
						i++;
						//コントロールポイント
						controlPoint = new Point(dat[i*4], dat[i*4+1]);
						endPos = new Point(dat[i*4+2], dat[i*4+3]);
						
						//分割
						trimCtrl = Point.interpolate(controlPoint, startPos, _f);
						trimPos = Point.interpolate(Point.interpolate(endPos,controlPoint,_f),trimCtrl,_f);
						
						com.splice(i, com.length-i);
						com.push(3);
						dat.splice(i*4,dat.length-i*4);
						dat.push(trimCtrl.x,trimCtrl.y,trimPos.x,trimPos.y);
						break;
					} else{
						length += eachLength[i];
					}
				}
			}
			
			g.drawPath( com, dat);
		}
		
		/**
		 * getters and setters
		 */
		public function set degree(value:Number):void{
			_degree = value;
			//drawPie(degree,radius,innerRadius);
		}
		public function set radius(value:Number):void{
			_radius = value;
			//drawPie(degree,radius,innerRadius);
		}
		public function set innerRadius(value:Number):void{
			_innerRadius = value;
			drawPie(degree,radius,innerRadius);
		}
		public function get degree():Number{ return _degree };
		public function get radius():Number{ return _radius };
		public function get innerRadius():Number{ return _innerRadius };
		
		public function set f(value:Number):void{
			_f = value;
			drawLine(commands,data,_f,_f0);
		}
		public function set f0(value:Number):void{
			_f0 = value;
			drawLine(commands,data,_f,_f0);
		}
		public function get f():Number{ return _f};
		public function get f0():Number{ return _f0 };
	}

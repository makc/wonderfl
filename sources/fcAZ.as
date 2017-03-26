// forked from miyaoka's Slicer implements GlowLine
// 小さい面積のは対象にしないようにしたりBetweenAS3いれたりして高速化
/*
 * GlowLine from
 * http://wonderfl.kayac.com/code/704630050881c4429dca8c7f27296b6e2fa3fa4f
 * 
 * マウス押しっぱなしで切りまくるようにした
 */
// forked from a24's Line slicer（割れるよ）
// forked from a24's Line slicer
// 切った後、割れるようにした
package  
{
	import flash.display.Sprite;
        import flash.display.DisplayObject;
	import flash.geom.Point;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.text.TextFieldAutoSize;
	import flash.events.Event;
	import net.hires.debug.Stats;
	
	[ SWF( width = "465" , height = "465" , backgroundColor = "0x000000" , frameRate = "60" ) ]

	public class Slicer2 extends Sprite
	{
		private	var _container:Sprite = new Sprite();
		private var isPress:Boolean;
		private var counterTfd:TextField = new TextField;
		
		public function Slicer2() 
		{
			graphics.beginFill(0);
			graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			
//			Wonderfl.capture_delay( 5 );
			
			var _pointArray:Array = [
				new Point( 0 , 0 ),
				new Point( 265 , 0 ),
				new Point( 265 , 265 ),
				new Point( 0 , 265 )
			];
			
			addChild( _container );
			
			//text
			var tft:TextFormat = new TextFormat();
			tft.align = TextFormatAlign.RIGHT;
			tft.bold = true;
			tft.font = "Verdana";
			tft.color = 0xFFFFFF;
			tft.letterSpacing = 5;
			tft.size = 48;
			
			counterTfd.defaultTextFormat = tft;
			counterTfd.autoSize = TextFieldAutoSize.RIGHT;
			counterTfd.mouseEnabled = false;
			counterTfd.x = stage.stageWidth -20;
			counterTfd.y = stage.stageHeight - 60;
			addChild(counterTfd);
			
			//stats
			addChild(new Stats());
			
			
			//evts
			stage.addEventListener( MouseEvent.MOUSE_DOWN, function ():void 
			{
				isPress = true;
				while (_container.numChildren) _container.removeChildAt(0);
				
				var _sliceObj:LineSliceObject = new LineSliceObject( stage , _pointArray ,
				(Math.random() * 0x99 + 0x66) << 16 | 
				(Math.random() * 0x99 + 0x66) << 8 | 
				(Math.random() * 0x99 + 0x66)
				);
				_sliceObj.x = _sliceObj.y = 100;
				_container.addChild( _sliceObj );
			});
			stage.addEventListener( MouseEvent.MOUSE_UP, function ():void 
			{
				isPress = false;
			});
			addEventListener(Event.ENTER_FRAME, function ():void 
			{
				if (!isPress) return;

				var t1:Number = Math.random() * Math.PI * 2;
				var t2:Number = t1 + Math.random() * (Math.PI * 2 / 3) + Math.PI * 1 / 3;
				
				var Pt1:Point = Point.polar(300, t1).add(new Point(stage.stageWidth/2, stage.stageHeight / 2)); 
				var Pt2:Point = Point.polar(300, t2).add(new Point(stage.stageWidth/2, stage.stageHeight / 2)); 
				
				var gl:GlowLine = new GlowLine(Pt1, Pt2);
				gl.addEventListener("completeLine", function ():void 
				{
                                        var lsos:Array = [];
					for (var i:int = 0; i < _container.numChildren; i++)
					{
                                            var child:DisplayObject = _container.getChildAt(i);
                                            if(child is LineSliceObject && LineSliceObject(child)._area >= 30){
                                                lsos.push(child);
                                            }
                                        }
                                        
                                        for each(var lso:LineSliceObject in lsos){
                                            lso.slice(Pt1, Pt2);
					}
					
					removeChild(gl);
					counterTfd.text = _container.numChildren.toString();
					gl = null;
				});
				
				addChild(gl);
				
				

			});
		}
	}
}



import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.display.Shape
import flash.events.Event;
import flash.display.Stage;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.events.MouseEvent;

import flash.filters.DropShadowFilter
import flash.filters.GlowFilter;
import flash.display.Graphics;

import org.libspark.betweenas3.BetweenAS3;
import org.libspark.betweenas3.easing.*;
class GlowLine
extends Shape
{
//	private var linearr:Array = [];
	private var dotarr:Array = [];
	public var startPt:Point;
	public var endPt:Point;
	public var t:Number = 0;
	public function GlowLine(startPt:Point, endPt:Point) {
		this.startPt = startPt;
		this.endPt = endPt;
	
		//filters
		filters = [
			new GlowFilter(0xffffff, 1, 16, 8, 1, 3, true, false),
			new GlowFilter(0xffff00, 1, 8, 8, 1, 3, false, false),
			new DropShadowFilter(0, 90, 0xcc3300, 1, 64, 64, 5, 3, false, false, false)
		];
		
		//evts
		addEventListener(Event.ENTER_FRAME, addPtHandler);
		addEventListener(Event.ENTER_FRAME, drawLineHandler);
		
		//twn
		BetweenAS3.tween(this, {t: 1.0},
                        null,
			Math.random() * 0.2 + 0.1,
                        Cubic.easeIn
		).play();
	}
	private function addPtHandler(e:Event):void 
	{
		dotarr.push({
    		    x : startPt.x + (endPt.x - startPt.x) * t,
		    y : startPt.y + (endPt.y - startPt.y) * t
                });

		if(t == 1) removeEventListener(Event.ENTER_FRAME, addPtHandler);		
	}
	private function drawLineHandler(e:Event):void {
		if (t == 1 ) {
			dotarr.splice(0, 1);
			
			if (dotarr.length < 5)
			{
			removeEventListener(Event.ENTER_FRAME, drawLineHandler);
			dispatchEvent(new Event("completeLine"));
			return;
			}
		}
		var _g:Graphics = graphics;

		_g.clear();
		_g.lineStyle(0, 0xff0000, 100, true, "none", "round", "round", 1);				
//		var _prevPoint:Point = null;
		var _dotLength:int = dotarr.length;
		for (var i:int = 1; i < _dotLength; ++i) {		
			var _prevObj:Object = dotarr[i - 1];									
			var _currentObj:Object = dotarr[i];

			_g.lineStyle(i / 1.5 * 2  , 0xffffff, 1, true, "none", "round", "round", 1);				
//			var _point:Point = new Point(_prevObj.x + (_currentObj.x - _prevObj.x) / 2, _prevObj.y + (_currentObj.y - _prevObj.y) / 2);				
			//if (_prevPoint) {
				//_g.moveTo(_prevPoint.x,_prevPoint.y);
				//_g.curveTo(_prevObj.x,_prevObj.y,_point.x,_point.y);
			//} else {
				_g.moveTo(_prevObj.x,_prevObj.y);
				_g.lineTo(_currentObj.x,_currentObj.y);
//				_g.lineTo(_point.x,_point.y);
			//}
//			_prevPoint = _point;
		}
		if (_currentObj) {
			_g.lineTo(_currentObj.x, _currentObj.y);
		}
		
	}	
}
class LineSliceObject extends Sprite
{
	private var _stage:Stage;
	private var _pointArray:Array;
	private var _color:uint;
	private var _point1:Point;
	private var _point2:Point;
	private var _length:int;
        public var _area:Number;
	
	public function LineSliceObject( _stage:Stage , _pointArray:Array , _color:uint ) 
	{
		this._stage = _stage;
		this._pointArray = _pointArray;
		this._color = _color;
//                this._area = areaFast(_pointArray);
		drawRectFromPoint( this , _pointArray , _color );
                this._area = areaFast(this);
	}

	
	/*
	 * ------------------------------------------------------------
	 * Graphic描画
	 * ------------------------------------------------------------
	*/
	private function drawRectFromPoint( _target:* , _pointArray:Array , _color:uint ):void
	{
		_target.graphics.beginFill( _color , 1.0 );
		_target.graphics.moveTo( _pointArray[ 0 ].x , _pointArray[ 0 ].y );
		_length = _pointArray.length;
		for ( var i:int = 1; i < _length; i ++ )
		{
			var _point:Point = _pointArray[ i ];
			_target.graphics.lineTo( _point.x , _point.y );
		}
		_target.graphics.endFill();
	}

        private static function areaFast(_target:DisplayObject) : Number
        {
            var r:Rectangle = _target.getRect(_target);
            return _target.width * _target.height;
        }
	
	/*
	 * ------------------------------------------------------------
	 * スライス
	 * ------------------------------------------------------------
	*/
	public function slice( _point1:Point , _point2:Point ):void
	{
		var _pt1:Point = globalToLocal( _point1 );
		var _pt2:Point = globalToLocal( _point2 );
		var _newPointArray:Array = [[], []];
		var _numCross:int = 0;
		
		for ( var i:int = 0; i < _length ; i ++ ) 
		{
			var _pt3:Point = _pointArray[ i ];
			var _pt4:Point = ( _pointArray[ i + 1 ] ) ? _pointArray[ i + 1 ] : _pointArray[ 0 ];
			var _crossPt:Point = crossPoint( _pt1 , _pt2 , _pt3 , _pt4 );
			
			_newPointArray[ 0 ].push( _pt3 );
			if ( _crossPt )
			{
				_newPointArray[ 0 ].push( _crossPt );
				_newPointArray[ 1 ].push( _crossPt );
				_newPointArray.reverse();
				_numCross ++;
			}
		}
		if ( _numCross == 2 )
		{
			var _newObj1:LineSliceObject = new LineSliceObject( _stage , _newPointArray[ 0 ] , _color );
			var _newObj2:LineSliceObject = new LineSliceObject( _stage , _newPointArray[ 1 ] , Math.random() * 0xFFFF00 );
			_newObj1.x = _newObj2.x = this.x;
			_newObj1.y = _newObj2.y = this.y;
			parent.addChild( _newObj1 );
			parent.addChild( _newObj2 );
			parent.removeChild( this );

			var _vector:Point = _pt2.subtract( _pt1 );
			var _force:int = 6 * Math.random() * 20;
                        var _d:Number = Math.sqrt(_vector.x * _vector.x + _vector.y * _vector.y);
                        var _fx:Number = (_vector.x >= 0 ? _vector.x : -_vector.x) / _d;
                        var _fy:Number = (_vector.y >= 0 ? _vector.y : -_vector.y) / _d;
			var _fx1:Number = ( _newPointArray[0][0].x < _newPointArray[1][0].x ) ? -_fx : _fx;
			var _fx2:Number = ( _newPointArray[1][0].x < _newPointArray[0][0].x ) ? -_fx : _fx;
			var _fy1:Number = ( _newPointArray[0][0].y < _newPointArray[1][0].y ) ? -_fy : _fy;
			var _fy2:Number = ( _newPointArray[1][0].y < _newPointArray[0][0].y ) ? -_fy : _fy;
			
			BetweenAS3.tween( _newObj1 , { x : _newObj1.x + _fx1 * _force , y : _newObj1.y + _fy1 * _force} , null, Math.random()*4+2, Expo.easeOut ).play();
			BetweenAS3.tween( _newObj2 , { x : _newObj2.x + _fx2 * _force , y : _newObj2.y + _fy2 * _force} , null, Math.random()*4+2, Expo.easeOut ).play();
		}
//		else _stage.addEventListener( MouseEvent.MOUSE_DOWN , mouseDownHandler );
	}
	
	/*
	 * ------------------------------------------------------------
	 * 交点を割り出す
	 * ------------------------------------------------------------
	*/
	private function crossPoint( _pt1:Point , _pt2:Point , _pt3:Point , _pt4:Point ):Point
	{	
		var _vector1:Point = _pt2.subtract( _pt1 );
		var _vector2:Point = _pt4.subtract( _pt3 );
		
                var c21:Number = cross(_vector2, _vector1);
		if ( c21 == 0.0) return null;
		
		var _s:Number = cross( _vector2 , _pt3.subtract( _pt1) ) / c21;

		if ( isCross( _s ))
		{
            		var _t:Number = cross( _vector1, _pt1.subtract( _pt3 ) ) / cross( _vector1, _vector2 );
                        if(isCross(_t)){
    			    _vector1.x *= _s;
			    _vector1.y *= _s;
			    return _pt1.add( _vector1 );
                        }
		}
		return null;
	}
		
	private function cross( _vector1:Point , _vector2:Point ):Number
	{
		return ( _vector1.x * _vector2.y - _vector1.y * _vector2.x );
	}
	
	public static function isCross( _n:Number ):Boolean
	{
		return ( ( 0 <= _n ) && ( _n <= 1) );
	}
}

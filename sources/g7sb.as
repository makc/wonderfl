package  
{
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	[ SWF( width = "465" , height = "465" , backgroundColor = "0x000000" , frameRate = "60" ) ]

	public class Main extends Sprite
	{
		private var _point:Point;
		private var _sliceObj:LineSliceObject;
		private var _line:Sprite = new Sprite();
		
		public function Main() 
		{
			Wonderfl.capture_delay( 5 );
    
			var _tf:TextField = new TextField();
			_tf.x = _tf.y = 6;
			_tf.autoSize = "left";
			_tf.textColor = 0xFFFFFF;
			_tf.text = "Please drag the Stage.";
			addChild( _tf );
			
			var _pointArray:Array = [
				new Point( 0 , 0 ),
				new Point( 265 , 0 ),
				new Point( 265 , 265 ),
				new Point( 0 , 265 )
			];
			
			var _container:Sprite = new Sprite();
			_sliceObj = new LineSliceObject( stage , _pointArray , 0x3399FF );
			_sliceObj.x = _sliceObj.y = 100;
			_container.addChild( _sliceObj );
			addChild( _container );
			addChild( _line );
			
			stage.addEventListener( MouseEvent.MOUSE_DOWN , mouseDownHandler );
		}
		
		private function mouseDownHandler( e:MouseEvent ):void 
		{
			_point = new Point( stage.mouseX , stage.mouseY );
			
			stage.removeEventListener( MouseEvent.MOUSE_DOWN , mouseDownHandler );
			stage.addEventListener( MouseEvent.MOUSE_UP , mouseUpHandler );
			stage.addEventListener( MouseEvent.MOUSE_MOVE , mouseMoveHandler );
		}
		private function mouseUpHandler( e:MouseEvent ):void 
		{
			_line.graphics.clear();
			
			stage.addEventListener( MouseEvent.MOUSE_DOWN , mouseDownHandler );
			stage.removeEventListener( MouseEvent.MOUSE_UP , mouseUpHandler );
			stage.removeEventListener( MouseEvent.MOUSE_MOVE , mouseMoveHandler );
		}
		
		private function mouseMoveHandler( e:MouseEvent ):void 
		{
			_line.graphics.clear();
			_line.graphics.lineStyle( 2.0 , 0x00FF00 , 1.0);
			_line.graphics.moveTo( _point.x , _point.y );
			_line.graphics.lineTo( mouseX , mouseY );
			_line.graphics.endFill();
		}
	}
}



import flash.display.Sprite;
import flash.display.Stage;
import flash.geom.Point;
import flash.events.MouseEvent;

class LineSliceObject extends Sprite
{
	private var _stage:Stage;
	private var _pointArray:Array;
	private var _color:uint;
	private var _point1:Point;
	private var _point2:Point;
	private var _length:int;
	
	public function LineSliceObject( _stage:Stage , _pointArray:Array , _color:uint ) 
	{
		this._stage = _stage;
		this._pointArray = _pointArray;
		this._color = _color;
		drawRectFromPoint( this , _pointArray , _color );
		
		_stage.addEventListener( MouseEvent.MOUSE_DOWN , mouseDownHandler );
	}
	
	/*
	 * ------------------------------------------------------------
	 * マウスイベントハンドラ
	 * ------------------------------------------------------------
	*/
	private function mouseDownHandler( e:MouseEvent ):void 
	{
		_point1 = new Point( _stage.mouseX , _stage.mouseY );
		
		_stage.removeEventListener( MouseEvent.MOUSE_DOWN , mouseDownHandler );
		_stage.addEventListener( MouseEvent.MOUSE_UP , mouseUpHandler );
	}
	private function mouseUpHandler( e:MouseEvent ):void 
	{
		_point2 = new Point( _stage.mouseX , _stage.mouseY );
		slice( _point1 , _point2 );
		
		_stage.removeEventListener( MouseEvent.MOUSE_UP , mouseUpHandler );
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
	
	/*
	 * ------------------------------------------------------------
	 * スライス
	 * ------------------------------------------------------------
	*/
	public function slice( _point1:Point , _point2:Point ):void
	{
		var _pt1:Point = globalToLocal( _point1 );
		var _pt2:Point = globalToLocal( _point2 );
		var _newPointArray:Array = [ new Array() , new Array() ];
		var _numCloss:int = 0;
		
		for ( var i:int = 0; i < _length ; i ++ ) 
		{
			var _pt3:Point = _pointArray[ i ];
			var _pt4:Point = ( _pointArray[ i + 1 ] ) ? _pointArray[ i + 1 ] : _pointArray[ 0 ];
			var _clossPt:Point = crossPoint( _pt1 , _pt2 , _pt3 , _pt4 );
			
			_newPointArray[ 0 ].push( _pt3 );
			if ( _clossPt )
			{
				_newPointArray[ 0 ].push( _clossPt );
				_newPointArray[ 1 ].push( _clossPt );
				_newPointArray.reverse();
				_numCloss ++;
			}
		}
		if ( _numCloss == 2 )
		{
			var _newObj1:LineSliceObject = new LineSliceObject( _stage , _newPointArray[ 0 ] , _color );
			var _newObj2:LineSliceObject = new LineSliceObject( _stage , _newPointArray[ 1 ] , Math.random() * 0xFFFF00 );
			_newObj1.x = _newObj2.x = this.x;
			_newObj1.y = _newObj2.y = this.y;
			parent.addChild( _newObj1 );
			parent.addChild( _newObj2 );
			parent.removeChild( this );
		}
		else _stage.addEventListener( MouseEvent.MOUSE_DOWN , mouseDownHandler );
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
		
		if ( cross( _vector1, _vector2 ) == 0.0) return null;
		
		var _s:Number = cross( _vector2 , _pt3.subtract( _pt1) ) / cross( _vector2 , _vector1 );
		var _t:Number = cross( _vector1, _pt1.subtract( _pt3 ) ) / cross( _vector1, _vector2 );

		if ( isCross( _s ) && isCross( _t ) )
		{
			_vector1.x *= _s;
			_vector1.y *= _s;
			return _pt1.add( _vector1 );
		}
		else return null;
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

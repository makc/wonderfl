package 
{
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.media.Camera;
	import flash.media.Video;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	
	/**
	 * ...
	 * @author 9re
	 */
	[SWF(backgroundColor = "#111111", frameRate = "37")]
	public class ProjectionMatrixTest extends MovieClip
	{
		//private const IMAGE_URL:String = "http://assets.wonderfl.net/images/related_images/e/ec/eca1/eca1057c7a177fd5dfa8c625e669b494bb4e85ab";
		private var _pmFilter:ProjectionMatrixFilter;
		
		private var _cvt0:ConvexTetragon;
		private var _cvt1:ConvexTetragon;
		private var _ctDomain:ConvexTetragon;
		private var _ctRegion:ConvexTetragon;
		private var _pm:ProjectionMatrix;
		private var _pointer:Vertex;
		private var _image:Sprite;
		private var _video:Video;
		
		public function ProjectionMatrixTest() 
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			_pm = new ProjectionMatrix;
			_pmFilter = new ProjectionMatrixFilter;
			
			addChild(_image = new Sprite);
			
            var camera:Camera = Camera.getCamera();
            if (camera != null) {
                _video = new Video(465, 465);
                _video.attachCamera(camera);
                _video.alpha = 0.9;
                _image.addChild(_video);
            }
			
			Vertex.COLOR = 0x333333;
			_cvt0 = new ConvexTetragon;
			_cvt0.fillAlpha = 0;
			_cvt0.addPoint(new Point(30, 40));
			_cvt0.addPoint(new Point(320, 60));
			_cvt0.addPoint(new Point(200, 240));
			_cvt0.addPoint(new Point(30, 160));
			_cvt0.draw();
			_cvt0.addEventListener(ConvexTetragon.VERTEX_MOVED, calculateProjectionMatirx);
			
			
			
			_cvt1 = new ConvexTetragon;
			_cvt1.addPoint(new Point(0, 0));
			_cvt1.addPoint(new Point(465, 0));
			_cvt1.addPoint(new Point(465, 465));
			_cvt1.addPoint(new Point(0, 465));
				
			
			_ctDomain = _cvt0;
			_ctRegion = _cvt1;
			
			addChild(_cvt0);
			
			calculateProjectionMatirx(null);
		}
		
		private function calculateProjectionMatirx(e:Event):void
		{
			var p:Point;
			
			setProjectionDomain(_ctDomain);
			setProjectionRegion(_ctRegion);
			
			_pm.calculateProjectionMatrix();
			_pm.setUpProjectionMatrixFilter(_pmFilter);
			_image.filters = [_pmFilter];
		}
		
		private function setProjectionDomain($domain:ConvexTetragon):void {
			var p:Point;
			
			p = $domain.getPointAt(0);
			_pm.setDomainA(p.x, p.y);
			p = $domain.getPointAt(1);
			_pm.setDomainB(p.x, p.y);
			p = $domain.getPointAt(2);
			_pm.setDomainC(p.x, p.y);
			p = $domain.getPointAt(3);
			_pm.setDomainD(p.x, p.y);			
		}
		
		private function setProjectionRegion($region:ConvexTetragon):void {
			var p:Point;
			
			p = $region.getPointAt(0);
			_pm.setRegionA(p.x, p.y);
			p = $region.getPointAt(1);
			_pm.setRegionB(p.x, p.y);
			p = $region.getPointAt(2);
			_pm.setRegionC(p.x, p.y);
			p = $region.getPointAt(3);
			_pm.setRegionD(p.x, p.y);
		}
	}
	
}

import flash.display.Shader;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.filters.ShaderFilter;
import flash.geom.Point;
import mx.utils.Base64Decoder;

import gs.easing.*;
import gs.TweenLite;

class ProjectionMatrixFilter extends ShaderFilter {
	public function ProjectionMatrixFilter() {
		var decoder:Base64Decoder = new Base64Decoder;
		decoder.decode(<projectionMatrixFilterKernel>
DI1vpQEAAACkFgBQcm9qZWN0aW9uTWF0cml4RmlsdGVyoAxuYW1lc3BhY2UAcXJlAKAMdmVuZG9y
AHFyZQCgCHZlcnNpb24AAQCgDGRlc2NyaXB0aW9uAEV4ZWN1dGUgUHJvamVjdGlvbiBNYXRyaXgg
RmlsdGVyIG9uIEltYWdlAKEBAgAADF9PdXRDb29yZACjAARzcmMAoQIEAQAPcmVzdWx0AKEBAQAA
AmEwAKIBZGVmYXVsdFZhbHVlAAAAAAChAQEAAAFiMACiAWRlZmF1bHRWYWx1ZQAAAAAAoQEBAgAI
YzAAogFkZWZhdWx0VmFsdWUAP4AAAKEBAQIABGExAKIBZGVmYXVsdFZhbHVlAD+AAAChAQECAAJi
MQCiAWRlZmF1bHRWYWx1ZQAAAAAAoQEBAgABYzEAogFkZWZhdWx0VmFsdWUAAAAAAKEBAQMACGEy
AKIBZGVmYXVsdFZhbHVlAAAAAAChAQEDAARiMgCiAWRlZmF1bHRWYWx1ZQA/gAAAoQEBAwACYzIA
ogFkZWZhdWx0VmFsdWUAAAAAAB0EAMEAABAAHQMAEAAAgAADAwAQBAAAAB0EACAAAMAAAwQAIAQA
QAAdBAAQAwDAAAEEABAEAIAAHQMAEAQAwAABAwAQAgAAADIEACAAAAAAKQMAEAQAgAAdAYCAAIAA
ADQAAAABgAAAHQMAEAIAQAADAwAQBAAAAB0EACACAIAAAwQAIAQAQAAdBAAQAwDAAAEEABAEAIAA
HQMAEAQAwAABAwAQAgDAAB0EACAAAIAAAwQAIAQAAAAdBAAQAADAAAMEABAEAEAAHQUAgAQAgAAB
BQCABADAAB0EACAFAAAAAQQAIAIAAAAEBAAQBACAAAMEABADAMAAHQUAgAQAwAAdAwAQAwAAAAMD
ABAEAAAAHQQAIAMAQAADBAAgBABAAB0EABADAMAAAQQAEAQAgAAdAwAQBADAAAEDABADAIAAHQQA
IAAAgAADBAAgBAAAAB0EABAAAMAAAwQAEAQAQAAdBQAgBACAAAEFACAEAMAAHQQAIAUAgAABBAAg
AgAAAAQEABAEAIAAAwQAEAMAwAAdBQBABADAADAGAPEFABAAHQEA8wYAGwA1AAAAAAAAADIBAIAA
AAAAMgEAQAAAAAAyAQAgAAAAADIBABAAAAAANgAAAAAAAAA=</projectionMatrixFilterKernel>);
		super(new Shader(decoder.drain().readObject()));
	}
	
	public function set a0(value:Number):void { shader.data.a0.value[0] = value; }
	public function set b0(value:Number):void { shader.data.b0.value[0] = value; }
	public function set c0(value:Number):void { shader.data.c0.value[0] = value; }
	public function set a1(value:Number):void { shader.data.a1.value[0] = value; }
	public function set b1(value:Number):void { shader.data.b1.value[0] = value; }
	public function set c1(value:Number):void { shader.data.c1.value[0] = value; }
	public function set a2(value:Number):void { shader.data.a2.value[0] = value; }
	public function set b2(value:Number):void { shader.data.b2.value[0] = value; }
	public function set c2(value:Number):void { shader.data.c2.value[0] = value; }
	public function get a0():Number { return shader.data.a0.value[0]; }
	public function get b0():Number { return shader.data.b0.value[0]; }
	public function get c0():Number { return shader.data.c0.value[0]; }
	public function get a1():Number { return shader.data.a1.value[0]; }
	public function get b1():Number { return shader.data.b1.value[0]; }
	public function get c1():Number { return shader.data.c1.value[0]; }
	public function get a2():Number { return shader.data.a2.value[0]; }
	public function get b2():Number { return shader.data.b2.value[0]; }
	public function get c2():Number { return shader.data.c2.value[0]; }
}


class MMatrix 
{
	private var _column:int;
	private var _row:int;
	private var _arr:Array;
		
	public function MMatrix($row:int, $column:int) 
	{
		_row = $row;
		_column = $column;
		_arr = [];
	}
		
	public function get column():int {
		return _column;
	}
		
	public function get row():int {
		return _row;
	}
		
	public function getElementAt($row:int, $column:int):Number {
		return _arr[$row * _column + $column];
	}
		
	public function setElementAt($row:int, $column:int, $value:Number):void {
		_arr[$row * _column + $column] = $value;
	}	
}

class MMatrixUtil
{		
	public static function makeMatrixFromArray($array:Array, $row:int, $column:int):MMatrix {
		var mat:MMatrix = new MMatrix($row, $column);
		var i:int, j:int;
			
			
		for (i = 0; i < $row; ++i) {
			for (j = 0; j < $column; ++j) {
				mat.setElementAt(i, j, $array[i * $column + j]);
			}
		}
		return mat;
	}
}

class HomogeneousLinearEQSystem 
{
	private var _dimension:int;
	private var _mat:MMatrix;
	private var _colInfo:Array;
		
	public function HomogeneousLinearEQSystem($array:Array):void {
		var n:int = Math.floor(Math.sqrt($array.length));
		_dimension = n;
		
		_mat = MMatrixUtil.makeMatrixFromArray($array, n, n + 1);
	}
		
	public function solve():void {
		var i:int, j:int, k:int, ii:int, ik:int;
		var t:Number, u:Number, v:Number;
		var weight:Array;
		var colInfo:Array = [];
		var rowInfo:Array = [];
			
		weight = [];
			
		for (k = 0; k <= _dimension; ++k)
			colInfo[k] = k;
			
		for (k = 0; k < _dimension; ++k) {
			rowInfo[k] = k;
				
			u = 0;
			for (j = 0; j <= _dimension; ++j) {
				t = _mat.getElementAt(k, j);
				t = (t < 0) ? -t : t;
				u = (u < t) ? t : u;
			}
			
			weight[k] = 1 / u; // suppose u != 0
		}
			
		for (k = 0; k < _dimension; ++k) {
			u = Number.NEGATIVE_INFINITY;
				
			for (i = k; i < _dimension; ++i) {
				ii = rowInfo[i];
				t = _mat.getElementAt(ii, k) * weight[ii];
				t = (t < 0) ? -t : t;
				if (t > u) {
					u = t;
					j = i;
				}
			}
			ik = rowInfo[j];
			if (j != k) {
				rowInfo[j] = rowInfo[k];
				rowInfo[k] = ik;
			}
			u = _mat.getElementAt(ik, k);
				
			if (u == 0) {
				//trace("u =", u);
				u = -1;
				for (j = k + 1; j <= _dimension; ++j) {
					t = _mat.getElementAt(ik, j);
					t = (t < 0) ? - t : t;
					if (u < t) {
						u = t;
						i = j;
					}
				}
					
				if (u == 0) {
						//trace("solved!");
					//trace(rowInfo);
					_mat = exchangeRows(_mat, rowInfo);
					_colInfo = colInfo;
					return;
				}
				//trace("exchange columns:", k, i);
				//trace("(ik, i) =", _mat.getElementAt(ik, i));
				// exchange columns					
				j = colInfo[k];
				colInfo[k] = colInfo[i];
				colInfo[i] = j;
				//
				for (j = 0; j < _dimension; ++j) {
					t = _mat.getElementAt(j, k);
					_mat.setElementAt(j, k, _mat.getElementAt(j, i));
					_mat.setElementAt(j, i, t);
				}
					
				u = _mat.getElementAt(ik, k);
				//trace("after: (ik, k) =", u);
			}
				
			ik = rowInfo[k];
			for (j = k; j <= _dimension; ++j) {
				t = _mat.getElementAt(ik, j) / u;
				_mat.setElementAt(ik, j, t);
			}
				
			for (i = 0; i < _dimension; ++i) {
				if (i != k) {
					ii = rowInfo[i];
					u = _mat.getElementAt(ii, k);
					for (j = k; j <= _dimension; ++j) {
						t = _mat.getElementAt(ii, j) - _mat.getElementAt(ik, j) * u;
						_mat.setElementAt(ii, j, t);
					}
				}
			}
			
			//trace(k, exchangeRows(_mat, rowInfo));
				
		}
			
		//trace("solved!");
		_mat = exchangeRows(_mat, rowInfo);
		_colInfo = colInfo;
	}
		
	public function get matrix():MMatrix {
		return _mat;
	}
		
	public function get columnInfo():Array {
		return _colInfo;
	}
		
	private function exchangeRows($matrix:MMatrix, $rowInfo:Array):MMatrix {
		var copy:MMatrix = new MMatrix(_dimension, _dimension + 1);
		var i:int, j:int, ii:int;
			
		for (i = 0; i < _dimension; ++i) {
			ii = $rowInfo[i];
				
			for (j = 0; j < _dimension + 1; ++j) {
				copy.setElementAt(i, j, $matrix.getElementAt(ii, j));
			}
		}
		return copy;
	}	
}


class ProjectionMatrix 
{
	private var _dx0:Number;
	private var _dy0:Number;
	private var _dx1:Number;
	private var _dy1:Number;
	private var _dx2:Number;
	private var _dy2:Number;
	private var _dx3:Number;
	private var _dy3:Number;
		
	private var _rx0:Number;
	private var _ry0:Number;
	private var _rx1:Number;
	private var _ry1:Number;
	private var _rx2:Number;
	private var _ry2:Number;
	private var _rx3:Number;
	private var _ry3:Number;
		
	private var _coefficients:Array;
		
	private var _a0:Number;
	private var _b0:Number;
	private var _c0:Number;
		
	private var _a1:Number;
	private var _b1:Number;
	private var _c1:Number;
		
	private var _a2:Number;
	private var _b2:Number;
	private var _c2:Number;
		
	public function ProjectionMatrix() {
		
	}
		
	public function setDomainA($x:Number, $y:Number):void {
		_dx0 = $x;
		_dy0 = $y;
	}
		
	public function setDomainB($x:Number, $y:Number):void {
		_dx1 = $x;
		_dy1 = $y;
	}
		
	public function setDomainC($x:Number, $y:Number):void {
		_dx2 = $x;
		_dy2 = $y;
	}
		
	public function setDomainD($x:Number, $y:Number):void {
		_dx3 = $x;
		_dy3 = $y;
	}
		
	public function setRegionA($x:Number, $y:Number):void {
		_rx0 = $x;
		_ry0 = $y;
	}
		
	public function setRegionB($x:Number, $y:Number):void {
		_rx1 = $x;
		_ry1 = $y;
	}

	public function setRegionC($x:Number, $y:Number):void {
		_rx2 = $x;
		_ry2 = $y;
	}
		
	public function setRegionD($x:Number, $y:Number):void {
		_rx3 = $x;
		_ry3 = $y;
	}
		
	public function calculateProjectionMatrix():void {
		var hleqs:Array = [
			_dx0 * _rx0, _dy0 * _rx0, _rx0, -_dx0, -_dy0, -1, 0, 0, 0,
			_dx1 * _rx1, _dy1 * _rx1, _rx1, -_dx1, -_dy1, -1, 0, 0, 0,
			_dx2 * _rx2, _dy2 * _rx2, _rx2, -_dx2, -_dy2, -1, 0, 0, 0,
			_dx3 * _rx3, _dy3 * _rx3, _rx3, -_dx3, -_dy3, -1, 0, 0, 0,
			_dx0 * _ry0, _dy0 * _ry0, _ry0, 0, 0, 0, -_dx0, -_dy0, -1,
			_dx1 * _ry1, _dy1 * _ry1, _ry1, 0, 0, 0, -_dx1, -_dy1, -1,
			_dx2 * _ry2, _dy2 * _ry2, _ry2, 0, 0, 0, -_dx2, -_dy2, -1,
			_dx3 * _ry3, _dy3 * _ry3, _ry3, 0, 0, 0, -_dx3, -_dy3, -1,
		];
			
		var solver:HomogeneousLinearEQSystem = new HomogeneousLinearEQSystem(hleqs);
			
		_coefficients = [];
		solver.solve();
		var conInfo:Array = solver.columnInfo;
		var solution:MMatrix = solver.matrix;
		var ii:int;
		for (var i:int = 0; i < solution.row; ++i) {
			ii = conInfo[i];
			_coefficients[ii] = - solution.getElementAt(i, solution.column - 1);
		}
		_coefficients[conInfo[solution.column - 1]] = 1;
			
		_a0 = _coefficients[0];
		_b0 = _coefficients[1];
		_c0 = _coefficients[2];
		_a1 = _coefficients[3];
		_b1 = _coefficients[4];
		_c1 = _coefficients[5];
		_a2 = _coefficients[6];
		_b2 = _coefficients[7];
		_c2 = _coefficients[8];
	}
	
	public function setUpProjectionMatrixFilter($filter:ProjectionMatrixFilter):void {
		$filter.a0 = _a0; $filter.b0 = _b0; $filter.c0 = _c0;
		$filter.a1 = _a1; $filter.b1 = _b1; $filter.c1 = _c1;
		$filter.a2 = _a2; $filter.b2 = _b2; $filter.c2 = _c2;
	}
		
	public function convert($point:Point):Point {
		var x:Number = $point.x;
		var y:Number = $point.y;
			
		return new Point(
			(_a1 * x + _b1 * y + _c1) / (_a0 * x + _b0 * y + _c0),
			(_a2 * x + _b2 * y + _c2) / (_a0 * x + _b0 * y + _c0)
		);
	}
}

class Vertex extends Sprite
{
	public static var RADIUS:Number = 5;
	public static var COLOR:uint = 0xff0000;
		
	public function Vertex($point:Point) 
	{
		x = $point.x;
		y = $point.y;
			
		graphics.beginFill(COLOR);
		graphics.drawCircle(0, 0, RADIUS);
		graphics.endFill();
	}
		
	public function get coordinate():Point {
		return new Point(x, y);
	}
		
	public function set coordinate(value:Point):void {
		x = value.x;
		y = value.y;
	}
}

class Convex extends Sprite
{
	private var _n:int;
	protected var _displayObjects:Array;
		
	public function Convex() 
	{
		_displayObjects = [];
	}
		
	public function removeAllPoints():void {
		while (_displayObjects.length > 0) {
			removeChild(_displayObjects.pop());
		}
	}
		
	public function getPointAt($index:int):Point {
		var v:Vertex = _displayObjects[$index] as Vertex;
			
		return v.coordinate;
	}
		
	public function addPoint($point:Point):void {
		_n = _displayObjects.push(addChild(new Vertex($point)));
	}
		
	public function get convexity():Boolean {
		if (_n < 4)
			return true;
			
			// _points.length > 3
		var i:int, j:int;
		var sgn:int;
		var first:Point;
		var second:Point;
		var third:Point;
		var cross:Number;
		var v:Vertex;
		for (i = 0; i < _n; ++i) {
			v = _displayObjects[i] as Vertex;
			first = v.coordinate;
			sgn = 2;
			for (j = 1; j < _n - 1; ++j) {
				v = _displayObjects[(i + j) % _n];
				second = v.coordinate;
				v = _displayObjects[(i + j + 1) % _n];
				third = v.coordinate;
					
				second = second.subtract(first);
				third = third.subtract(first);
				cross = second.x * third.y - second.y * third.x;
					
				if (cross == 0)
					return false;
					
				if (sgn == 2)
					sgn = sign(cross);
				else if (sgn != sign(cross))
					return false;
			}
		}
			
		return true;
	}
		
	private function sign(t:Number):int {
		return (t < 0) ? -1 : 1;
	}		
}


class ConvexTetragon extends Convex
{
	public static const VERTEX_MOVED:String = "vertex moved";
	public var color:uint = 0xffffff;
	public var fillAlpha:Number = 1.0;
	private var _prevX:Number;
	private var _prevY:Number;
	private var _v:Vertex;
		
	public function ConvexTetragon() 
	{
		//mouseEnabled = false;
		addEventListener(Event.ADDED_TO_STAGE, stageHandler, false, 0, true);
	}
		
	private function stageHandler(e:Event):void 
	{
		stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);			
	}
		
	override public function addPoint($point:Point):void 
	{
		super.addPoint($point);
			
		var v:Vertex = _displayObjects[_displayObjects.length - 1];
			
		v.buttonMode = true;
		v.tabEnabled = false;
		v.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
	}
		
	private function mouseDownHandler(e:MouseEvent):void 
	{
		_v = e.target as Vertex;
		_prevX = _v.x;
		_prevY = _v.y;
			
		stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			
		_v.startDrag();
	}
		
	private function mouseUpHandler(e:MouseEvent):void 
	{
		if (_v == null)
			return;
				
		_v.stopDrag();
			
		stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			
		if (!convexity) {
			TweenLite.to(_v, 0.4, { x: _prevX, y:_prevY, ease:Cubic.easeOut, onComplete:removeEnterFrameHandler } );
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		} else {
			dispatchEvent(new Event(VERTEX_MOVED));
			draw();
		}
		draw();
		
		_v = null;
	}
		
	private function removeEnterFrameHandler():void
	{
		removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
	}
		
	private function enterFrameHandler(e:Event):void 
	{
		draw();
	}
		
	public function draw():void
	{
		var v:Vertex;
		v = _displayObjects[0] as Vertex;
		graphics.clear();
		graphics.beginFill(color, fillAlpha);
		graphics.moveTo(v.x, v.y);
			
		for (var i:int = 1; i <= 4; ++i) {
			v = _displayObjects[i & 3];
			graphics.lineTo(v.x, v.y);
		}
		
		graphics.endFill();
	}
		
	private function mouseMoveHandler(e:MouseEvent):void 
	{
		e.updateAfterEvent();
		draw();
	}
	
}







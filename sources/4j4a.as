/**
 * 3Dとかクリッピングとかの勉強
 * クリッピングは矩形範囲外を切り取っているだけです
 * Utils3D.projectVectors()に3D座標変換とUVTの計算をまかせていたら
 * クリッピングで分割されたポリゴンの新しいUVT座標の求め方がわからなくなって挫折・・・
 * カメラもZソートもないし同じ座標の頂点を共有できてなかったり色々中途半端です
 */
package  {
	
	import com.bit101.components.*;
	import flash.display.*;
	import flash.events.*;
	import flash.filters.*;
	import flash.geom.*;
	import net.hires.debug.Stats;
	
	public class Moja3D extends Sprite {
		
		public var scene:Scene3D;
		public var plane:Plane;
		public var cube:Cube;
		public var ring:Object3D;
		public var clippingRect:Rectangle = new Rectangle(50, 50, 365, 365);
		
		public function Moja3D() {
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void {
			stage.frameRate = 60;
			scene = new Scene3D();
			scene.setViewSize(clippingRect.width, clippingRect.height);
			scene.display.x = clippingRect.x;
			scene.display.y = clippingRect.y;
			
			drawBackground();
			createPolygons();
			
			addChild(scene.display);
			addChild(new Stats());
			Style.LABEL_TEXT = Style.BACKGROUND = 0;
			new CheckBox(this, 390, 20, "CLIPPING", function(e:MouseEvent):void {
				scene.renderer.isClipping = e.currentTarget.selected;
			}).selected = true;
			new CheckBox(this, 390, 5, "WIREFRAME", function(e:MouseEvent):void {
				scene.renderer.isWireframe = e.currentTarget.selected;
			}).selected = true;
			addEventListener(Event.ENTER_FRAME, onTickRender);
		}
		
		private function createPolygons():void {
			plane = new Plane(200, 100, 0xcccccc, 1, true);
			plane.transform.x = -50;
			plane.transform.z = 200;
			plane.canvas.filters = [new DropShadowFilter(4, 45, 0, 1, 10, 10, 1, 1)];
			
			cube = new Cube(100, 100, 50, { front:0x444444, right:0x93A929, back:0xFFE318, left:0xBA1221, top:0xE98312, bottom:0x0061AA }, 0.8);
			cube.transform.x = 50;
			cube.transform.y = 50;
			cube.transform.z = 180;
			
			ring = new Object3D();
			ring.transform.z = 200;
			ring.transform.rotationX = 35;
			for (var i:int = 0; i < 360; i += 30) {
				var c:Cube = new Cube(20, 10, 10, { front:0x444444, right:0x93A929, back:0xFFE318, left:0xBA1221, top:0xE98312, bottom:0x0061AA }, 1);
				c.transform.x = Math.cos(Math.PI / 180 * i) * 100;
				c.transform.z = Math.sin(Math.PI / 180 * i) * 100;
				c.transform.rotationY = -i;
				ring.addChild(c);
			}
			
			scene.root.addChild(ring);
			scene.root.addChild(plane);
			scene.root.addChild(cube);
		}
		
		private function drawBackground():void{
			graphics.beginFill(0xDDDDDD);
			graphics.drawRect(0, 0, 465, 465);
			graphics.beginFill(0x808080);
			graphics.drawRect(clippingRect.x, clippingRect.y, clippingRect.width, clippingRect.height);
			graphics.endFill();
		}
		
		private function onTickRender(e:Event):void {
			plane.transform.rotationX += 0.2;
			plane.transform.rotationY += 0.6;
			plane.transform.rotationZ += 1;
			cube.transform.rotationX += 0.7;
			cube.transform.rotationY += 1.2;
			ring.matrix.prependRotation(1, Vector3D.Y_AXIS);
			scene.render();
		}
		
	}
	
}

import flash.display.*;
import flash.geom.*;

class Scene3D {
	
	public var display:Sprite = new Sprite();
	public var root:Object3D = new Object3D();
	public var renderer:Renderer = new Renderer();
	
	public function Scene3D() {
		display.addChild(root.canvas);
	}
	
	public function setViewSize(width:Number, height:Number):void {
		root.canvas.x = width / 2;
		root.canvas.y = height / 2;
		renderer.setViewSize.apply(null, arguments);
	}
	
	public function render():void {
		root.draw(renderer);
	}
	
}

class Renderer {
	
	public var isWireframe:Boolean = true;
	public var isClipping:Boolean = true;
	
	private var _clippng:Clipping = new Clipping();
	private var _projection:PerspectiveProjection = new PerspectiveProjection();
	
	private var _screenVtx:Vector.<Number> = new Vector.<Number>();
	private var _clippedVtx:Vector.<Number> = new Vector.<Number>();
	private var _uvts:Vector.<Number> = new Vector.<Number>();
	private var _indices:Vector.<int> = new Vector.<int>();
	private var _threeIndices:Vector.<int> = Vector.<int>([0, 1, 2]);
	private var _matrix:Matrix3D = new Matrix3D();
	
	public function Renderer() {
		_projection.fieldOfView = 75;
	}
	
	public function setViewSize(width:Number, height:Number):void {
		_clippng.setRect( -width / 2, -height / 2, width, height);
		_projection.projectionCenter = new Point(width / 2, height / 2);
	}
	
	public function render(obj:Polygon):void {
		var g:Graphics = obj.canvas.graphics;
		g.clear();
		isWireframe? g.lineStyle(0) : g.lineStyle();
		_matrix.identity();
		_matrix.append(obj.worldMatrix);
		_matrix.append(_projection.toMatrix3D());
		for each (var face:Face in obj.faces) {
			g.beginFill(face.color, face.alpha);
			Utils3D.projectVectors(_matrix, face.verts, _screenVtx, _uvts);
			if (isClipping) _clippng.clip(_screenVtx, _clippedVtx, _indices);
			if (!isClipping || _clippedVtx.length) g.drawTriangles(isClipping? _clippedVtx : _screenVtx, isClipping? _indices : _threeIndices, null, face.twoSides? TriangleCulling.NONE : TriangleCulling.POSITIVE);
		}
		g.endFill();
	}
}

class Object3D {
	
	private var _parent:Object3D = null;
	private var _canvas:Sprite = new Sprite();
	private var _transform:Sprite = new Sprite();
	private var _children:Vector.<Object3D> = new Vector.<Object3D>();
	private var _worldMatrix:Matrix3D = new Matrix3D();
	
	public function get parent():Object3D { return _parent; }
	public function get canvas():Sprite { return _canvas; }
	public function get children():Vector.<Object3D> { return _children; }
	public function get transform():Sprite { return _transform; }
	public function get matrix():Matrix3D { return transform.transform.matrix3D; }
	public function get worldMatrix():Matrix3D { return _worldMatrix; }
	
	public function Object3D() {
		transform.rotationX = 0;
	}
	
	public function removeChild(obj:Object3D):Object3D {
		if (obj.canvas.parent == canvas) {
			canvas.removeChild(obj.canvas);
			children.splice(children.indexOf(obj), 1);
			obj._parent = null;
			return obj;
		} else return null;
	}
	
	public function addChild(obj:Object3D):Object3D {
		if(obj.parent) obj.parent.removeChild(obj);
		children.push(obj);
		canvas.addChild(obj.canvas);
		obj._parent = this;
		return obj;
	}
	
	public function draw(renderer:Renderer, parentMatrix:Matrix3D = null):void {
		_worldMatrix.identity();
		_worldMatrix.append(matrix);
		if(parentMatrix) _worldMatrix.append(parentMatrix);
		if (this is Polygon) renderer.render(this as Polygon);
		for each (var obj:Object3D in children) obj.draw(renderer, _worldMatrix);
	}
	
}

class Polygon extends Object3D {
	
	public var faces:Vector.<Face> = new Vector.<Face>();
	
	public function Polygon() {
		super();
	}
	
}

class Plane extends Polygon {
	
	public function Plane(width:Number = 100, height:Number = 100, color:uint = 0x808080, alpha:Number = 1, twoSides:Boolean = false) {
		super();
		var face1:Face = new Face();
		face1.vertices[0] = new Vector3D( -width/2, -height/2, 0);
		face1.vertices[1] = new Vector3D( -width/2, height/2, 0);
		face1.vertices[2] = new Vector3D( width / 2, height / 2, 0);
		face1.updateVertices();
		var face2:Face = new Face();
		face2.vertices[0] = new Vector3D( -width/2, -height/2, 0);
		face2.vertices[1] = new Vector3D( width/2, height/2, 0);
		face2.vertices[2] = new Vector3D( width/2, -height/2, 0);
		face2.updateVertices();
		face1.color = face2.color = color;
		face1.alpha = face2.alpha = alpha;
		face1.twoSides = face2.twoSides = twoSides;
		faces.push(face1);
		faces.push(face2);
	}
	
}

class Cube extends Polygon {
	
	public function Cube(width:Number = 100, height:Number = 100, depth:Number = 100, color:* = 0x808080, alpha:Number = 1, twoSides:Boolean = false) {
		super();
		var i:int, rgbs:Array = [];
		if (color is uint) for (i = 0; i < 6; i++) rgbs[i] = color;
		else if (color is Object) for (i = 0; i < 6; i++) {
			var rgb:Number = color[["back", "bottom", "right", "top", "left", "front"][i]];
			rgbs[i] = (isNaN(rgb))? 0x808080 : rgb;
		}
		var list:Array = [[ -1, -1, 1], [1, -1, 1], [1, 1, 1], [ -1, 1, 1], [ -1, -1, -1], [1, -1, -1], [1, 1, -1], [ -1, 1, -1]];
		var ids:Array = [[0, 1, 2], [0, 2, 3], [3, 2, 6], [3, 6, 7], [2, 1, 5], [2, 5, 6], [1, 0, 4], [1, 4, 5], [0, 3, 7], [0, 7, 4], [7, 6, 5], [5, 4, 7]];
		var vectors:Array = [];
		for each (var item:Array in list)
			vectors.push(new Vector3D(width / 2 * item[0], height / 2 * item[1], depth / 2 * item[2]));
		for (i = 0; i < ids.length; i++) {
			var face:Face = new Face();
			face.vertices[0] = vectors[ids[i][0]];
			face.vertices[1] = vectors[ids[i][1]];
			face.vertices[2] = vectors[ids[i][2]];
			face.updateVertices();
			face.color = rgbs[i / 2 | 0];
			face.alpha = alpha;
			face.twoSides = twoSides;
			faces.push(face);
		}
	}
	
}

class Face {
	
	public var color:uint = 0x808080;
	public var alpha:Number = 1;
	public var twoSides:Boolean = false;
	public var vertices:Vector.<Vector3D> = new Vector.<Vector3D>();
	private var _verts:Vector.<Number>;
	
	public function get verts():Vector.<Number> { return _verts; }
	
	public function Face() {
	}
	
	public function updateVertices():void {
		_verts = Vector.<Number>([vertices[0].x, vertices[0].y, vertices[0].z, vertices[1].x, vertices[1].y, vertices[1].z, vertices[2].x, vertices[2].y, vertices[2].z]);
	}
	
}

class Clipping {
	
	private var _rect:Rectangle = new Rectangle();
	private var _center:Point = new Point();
	private var _corners:Array;
	private var _containsList:Vector.<Boolean> = new Vector.<Boolean>();
	private var _segments:Vector.<Array> = new Vector.<Array>();
	private var _displayBox:Vector.<Number> = new Vector.<Number>();
	
	public function Clipping() {
	}
	
	public function setRect(x:Number, y:Number, width:Number, height:Number):void {
		_rect.x = x;
		_rect.y = y;
		_rect.width = width;
		_rect.height = height;
		_center.x = x + width / 2;
		_center.y = y + height / 2;
		_corners = [[_rect.left, _rect.top], [_rect.right, _rect.top], [_rect.right, _rect.bottom], [_rect.left, _rect.bottom]];
		_segments.length = _displayBox.length = 0;
		_segments.push([_rect.left, _rect.top, _rect.bottom]);
		_segments.push([_rect.top, _rect.left, _rect.right]);
		_segments.push([_rect.right, _rect.top, _rect.bottom]);
		_segments.push([_rect.bottom, _rect.left, _rect.right]);
		_displayBox.push(_rect.left, _rect.top, _rect.right, _rect.top, _rect.right, _rect.bottom, _rect.left, _rect.bottom);
	}
	
	public function clip(vtx:Vector.<Number>, outVtx:Vector.<Number>, outIndices:Vector.<int>):void {
		var i:int, last:Array, first:Array, ax:Number, ay:Number, bx:Number, by:Number, points:Array = [];
		for (i = 0; i < 3; i++) _containsList[i] = containsXY(vtx[i * 2], vtx[i * 2 + 1]);
		if (_containsList[0] && _containsList[1] && _containsList[2]) {
			for (i = 0; i < vtx.length; i++) outVtx[i] = vtx[i];
			outVtx.length = vtx.length;
			for (i = 0; i < 3; i++) outIndices[i] = i;
			outIndices.length = 3;
			return;
		}
		
		var reverse:Boolean = cross(vtx[2] - vtx[0], vtx[3] - vtx[1], vtx[4] - vtx[0], vtx[5] - vtx[1]) < 0;
		for (i = 0; i < 3; i++) {
			ax = vtx[(i * 2)];
			ay = vtx[(i * 2 + 1)];
			bx = vtx[(i * 2 + 2) % 6];
			by = vtx[(i * 2 + 3) % 6];
			if (containsXY(ax, ay)) points.push([ax, ay]);
			var crossList:Array = checkCross(ax, ay, bx, by);
			if (last && crossList.length) addCorner(points, last[last.length - 1][3], crossList[0][3], reverse);
			points = points.concat(crossList);
			if (crossList.length) last = (containsXY(bx, by))? null : crossList;
			if (!first && crossList.length) first = crossList;
		}
		if (last && first) addCorner(points, last[last.length - 1][3], first[0][3], reverse);
		
		if (!points.length) {
			var isFill:Boolean = true;
			for (i = 0; i < 3; i++) {
				var t:int = reverse? 1 : -1;
				if (cross(vtx[(i * 2 + 2) % 6] - vtx[i * 2], vtx[(i * 2 + 3) % 6] - vtx[i * 2 + 1], _center.x - vtx[i * 2], _center.y - vtx[i * 2 + 1]) * t > 0) {
					isFill = false;
					break;
				}
			}
			if (isFill) {
				for (i = 0; i < _displayBox.length; i++) outVtx[i] = _displayBox[i];
				outVtx.length = _displayBox.length;
			} else outVtx.length = 0;
		} else {
			outVtx.length = 0;
			for (i = 0; i < points.length; i++) outVtx.push(points[i][0], points[i][1]);
		}
		
		outIndices.length = 0;
		for (i = 0; i < outVtx.length - 2; i++) outIndices.push(0, i + 1, i + 2);
	}
	
	private function cross(ax:Number, ay:Number, bx:Number, by:Number):Number {
		return ax * by - ay * bx;
	}
	
	private function addCorner(points:Array, min:int, max:int, reverse:Boolean):void {
		while (min != max) {
			points.push(_corners[(reverse)? (min + 3) % 4 : min]);
			min = (min + (reverse? -1 : 1) + 4) % 4;
		}
	}
	
	private function checkCross(x1:Number, y1:Number, x2:Number, y2:Number):Array {
		var crossPoints:Array = [];
		var last:Array;
		for (var i:int = 0; i < 4; i++) {
			var h:Number = _segments[i][0], v1:Number = _segments[i][1], v2:Number = _segments[i][2];
			var isVertical:Boolean = (i % 2) == 0;
			if (isVertical) {
				if ((x1 < h && x2 < h) || (x1 > h && x2 > h)) continue;
				if ((y1 < v1 && y2 < v1) || (y1 > v2 && y2 > v2)) continue;
				if (x2 == x1) continue;
			} else {
				if ((y1 < h && y2 < h) || (y1 > h && y2 > h)) continue;
				if ((x1 < v1 && x2 < v1) || (x1 > v2 && x2 > v2)) continue;
				if (y2 == y1) continue;
			}
			var t:Number = (isVertical)? (h - x1) / (x2 - x1) : (h - y1) / (y2 - y1);
			var xy:Number = (isVertical)? y1 + (y2 - y1) * t : x1 + (x2 - x1) * t;
			if (xy < v1 || xy > v2) continue;
			var point:Array = (isVertical)? [h, xy, t, i] : [xy, h, t, i];
			if (!(last && last[0] == point[0] && last[1] == point[1])) crossPoints.push(point);
			last = point;
		}
		
		if (crossPoints.length >= 2 && crossPoints[0][2] > crossPoints[1][2]) crossPoints.reverse();
		return crossPoints;
	}
	
	private function containsXY(x:Number, y:Number):Boolean {
		return !(x < _rect.left || x > _rect.right || y < _rect.top || y > _rect.bottom);
	}
	
}
package {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	[SWF(width = "465", height = "465", frameRate = "60", backgroundColor = "#000000")]
	/**
	 * Wonderwall のパチモン
	 * @author YOSHIDA, Akio (Aquioux)
	 */
	public class Main extends Sprite {
		private const DISTANCE_OF_REACTION:int = 125;	// マウスに反応する距離
		private const SPRING:Number   = 0.01;			// バネ係数
		private const FRICTION:Number = 0.9;			// 摩擦係数

		private const NUM_OF_ROW:int = 3;	// 横方向の数
		private const NUM_OF_COL:int = 3;	// 縦方向の数
		private const IMAGE_WIDTH:int  = 100;
		private const IMAGE_HEIGHT:int = 100;
		
		private var imageUrls:Vector.<String> = Vector.<String>([
			"http://assets.wonderfl.net/images/related_images/5/59/59ce/59ce4dc0471ca9405ef2d0ed2dc1cea5e70c91c1",
			"http://assets.wonderfl.net/images/related_images/7/71/716a/716a033cf4afbec77f72d124e1903b1ff05cbbda",
			"http://assets.wonderfl.net/images/related_images/8/87/871a/871a53382ac812425d86de3888971e86fb3b956b",
			"http://assets.wonderfl.net/images/related_images/7/74/74f2/74f2c57ef48e0d2b88be0bb3999ad15c110bcaf2",
			"http://assets.wonderfl.net/images/related_images/c/c5/c5ef/c5efc60973f19249b625ca1b0672b2b359d63eee",
			"http://assets.wonderfl.net/images/related_images/b/b4/b43b/b43bf737d1fe33d1c083c8e9e04f97467751df96",
			"http://assets.wonderfl.net/images/related_images/3/3d/3dcd/3dcd1527c2f968c5b4e39471303b690d28e28687",
			"http://assets.wonderfl.net/images/related_images/7/76/765f/765f0fef8e179cb6d384b85e972879be8e003f69",
			"http://assets.wonderfl.net/images/related_images/e/ee/ee94/ee94f456247434eee366c2c6a6362b8a7db03f8e"
		]);
		private var images:Vector.<BitmapData> = new Vector.<BitmapData>(9, true);
		private var cnt:uint = 0;
		private const NUM_OF_IMAGE:uint = NUM_OF_ROW * NUM_OF_COL;
		

		public function Main() {
			imageLoad();
		}
		
		private function imageLoad():void {
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler);
			var url:String = imageUrls[cnt];
			loader.load(new URLRequest(url), new LoaderContext(true));
		}
		private function completeHandler(event:Event):void {
			var loader:Loader = event.target.loader;
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, completeHandler);
			images[cnt] = Bitmap(loader.content).bitmapData;
			cnt++;
			cnt >= NUM_OF_IMAGE ? next() : imageLoad();
		}
			
		private function next():void {
			// Coordinate 初期化
			Coordinate.spring   = SPRING;
			Coordinate.friction = FRICTION;
			Coordinate.distanceOfReaction = DISTANCE_OF_REACTION;
		
			// データ生成
			var dataFactory:DataFactory = new DataFactory();
			dataFactory.numOfCol = NUM_OF_COL;
			dataFactory.numOfRow = NUM_OF_ROW;
			dataFactory.cellWidth  = IMAGE_WIDTH;
			dataFactory.cellHeight = IMAGE_HEIGHT;
			dataFactory.stageWidth  = stage.stageWidth;
			dataFactory.stageHeight = stage.stageHeight;
			dataFactory.start();
			
			// Model 生成
			var model:Model = new Model();
			model.coordinates = dataFactory.coordinates;

			// View 生成
			var viewLayer:Sprite = new Sprite();
			addChild(viewLayer);
			var n:uint = NUM_OF_ROW * NUM_OF_COL;
			for (var i:int = 0; i < n; i++) {
				var view:View = new View(model);
				view.bitmapData = images[i];
				view.setBounds(i, dataFactory.bounds);
				view.setup();
				viewLayer.addChild(view);
			}

			// Controller 生成
			var controller:Controller = new Controller(model);
		}
	}
}


	import flash.geom.Point;
	/**
	 * データ生成クラス
	 * @author YOSHIDA, Akio (Aquioux)
	 */
	class DataFactory {
		// 外部へ出力するデータ
		public function get coordinates():Vector.<Coordinate> { return _coordinates; }
		private var _coordinates:Vector.<Coordinate>;	// すべての頂点（for Model）
		
		public function get bounds():Vector.<int> { return _bounds; }
		private var _bounds:Vector.<int>;				// セルの四隅の頂点の組み合わせ（for View）

		
		// 外部から入力するデータ
		public function set numOfRow(value:int):void { _numOfRow = value; }
		private var _numOfRow:uint;		// 横方向のセル数
		public function set numOfCol(value:int):void { _numOfCol = value; }
		private var _numOfCol:uint;		// 縦方向のセル数
		public function set cellWidth(value:Number):void { _cellWidth = value; }
		private var _cellWidth:Number;	// セル幅
		public function set cellHeight(value:Number):void { _cellHeight = value; }
		private var _cellHeight:Number;	// セル高
		
		public function set stageWidth(value:Number):void { _stageWidth = value; }
		private var _stageWidth:Number;		// ステージ幅
		public function set stageHeight(value:Number):void { _stageHeight = value; }
		private var _stageHeight:Number;	// ステージ高
		
		
		// 内部だけで使用するデータ
		private var offsetX:Number;	// X座標オフセット値
		private var offsetY:Number;	// Y座標オフセット値
		

		public function DataFactory() {}
		
		// 出力データ作成開始
		// このメソッドは入力データをすべて設定してから実行すること
		public function start():void {
			var totalWidth:int  = _numOfRow * _cellWidth;
			var totalHeight:int = _numOfCol * _cellHeight;
			var offsetX:Number = (_stageWidth - totalWidth) / 2;
			var offsetY:Number = (_stageHeight - totalHeight) / 2;
			
			// 全頂点
			// 左上端からZ順に各頂点を Coordinete クラスで設定し、その Coordinate インスタンスを Vector に格納
			_coordinates = new Vector.<Coordinate>();
			for (var i:int = 0; i < _numOfCol + 1; i++) {
				for (var j:int = 0; j < _numOfRow + 1; j++) {
					var posX:Number = j * _cellWidth  + offsetX + Math.random() * 30 - 15;
					var posY:Number = i * _cellHeight + offsetY + Math.random() * 30 - 15;
					var coordinate:Coordinate = new Coordinate(posX, posY);
					_coordinates.push(coordinate);
				}
			}
			_coordinates.fixed = true;
			
			// セルの四隅の頂点の組み合わせ
			// 各セルの四隅（左上から時計回り）が全頂点のうちそれぞれ何番目になるのかを、Vector に格納（dtawTriangle の indices と似ている）
			_bounds = new Vector.<int>();
			var cnt:uint = 0;
			for (i = 0; i < _numOfCol; i++) {
				for (j = 0; j < _numOfRow; j++) {
					var leftTop:uint     =  i      * (_numOfRow + 1) + j;
					var rightTop:uint    =  i      * (_numOfRow + 1) + j + 1;
					var leftBottom:uint  = (i + 1) * (_numOfRow + 1) + j;
					var rightBottom:uint = (i + 1) * (_numOfRow + 1) + j + 1;
					_bounds[cnt++] = leftTop;
					_bounds[cnt++] = rightTop;
					_bounds[cnt++] = rightBottom;
					_bounds[cnt++] = leftBottom;
				}
			}
			_bounds.fixed = true;
		}
	}


	import flash.geom.Point;
	/**
	 * 頂点生成クラス
	 * @author YOSHIDA, Akio (Aquioux)
	 */
	class Coordinate {
		// 外部から入力するデータ
		// 静的変数
		// バネ係数
		static public function set spring(value:Number):void { _spring = value; }
		static private var _spring:Number = 0.01;
		// 抵抗
		static public function set friction(value:Number):void { _friction = value; }
		static private var _friction:Number = 0.9;
		// 反応距離
		static public function set distanceOfReaction(value:Number):void { _distanceOfReaction = value; }
		static private var _distanceOfReaction:Number = 100;

		// 外部へ出力するデータ
		// 現在座標
		public function get x():Number { return _x; }
		private var _x:Number;
		public function get y():Number { return _y; }
		private var _y:Number;

		
		// 内部だけで使用するデータ
		// 既定座標
		private var localX:Number;
		private var localY:Number;
		// 速度
		private var vx:Number = 0.0;
		private var vy:Number = 0.0;
	

		public function Coordinate(valueX:Number, valueY:Number) {
			_x = localX = valueX;
			_y = localY = valueY;
		}
	
		public function update(mousePoint:Point):void {
			// マウスの位置と自分との距離を求める
			var distance:Number = Point.distance(mousePoint, new Point(localX, localY));
		
			// 到達値
			var dx:Number;
			var dy:Number;
			// 到達値の計算
			if (distance < _distanceOfReaction) {
				var diff:Number     = -distance * (_distanceOfReaction - distance) / _distanceOfReaction;
				var radian:Number   = Math.atan2(mousePoint.y - localY, mousePoint.x - localX);
				var diffPoint:Point = Point.polar(diff*2, radian);
				dx = localX + diffPoint.x;
				dy = localY + diffPoint.y;
			} else{	// 位置を元に戻す
				dx = localX;
				dy = localY;
			}
		
			vx += (dx - _x) * _spring;
			vy += (dy - _y) * _spring;
			vx *= _friction;
			vy *= _friction;
			_x += vx;
			_y += vy;
		}
	}


	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	/**
	 * Model クラス
	 * @author YOSHIDA, Akio (Aquioux)
	 */
	class Model extends EventDispatcher {
		// 外部へ出力するデータ
		// 全頂点のXY座標値
		public function get vertices():Vector.<Number> { return _vertices; }
		private var _vertices:Vector.<Number>;

		// 外部から入力するデータ
		// 全頂点データ
		public function set coordinates(value:Vector.<Coordinate>):void {
			_coordinates = value;
			_vertices = new Vector.<Number>(_coordinates.length * 2, true);
		}
		private var _coordinates:Vector.<Coordinate>;
		
		
		public function Model() {}

		public function update(mousePoint:Point):void {
			var n:uint = _coordinates.length;
			for (var i:int = 0; i < n; i++) {
				var c:Coordinate = _coordinates[i];
				c.update(mousePoint);
				_vertices[i * 2]     = c.x;
				_vertices[i * 2 + 1] = c.y;
			}
			dispatchEvent(new Event(Event.CHANGE));
		}
	}


	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.GraphicsBitmapFill;
	import flash.display.GraphicsEndFill;
	import flash.display.GraphicsTrianglePath;
	import flash.display.IGraphicsData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	/**
	 * ...
	 * @author YOSHIDA, Akio (Aquioux)
	 */
	class View extends Sprite {
		// 外部から入力するデータ
		// 四隅の頂点の、全頂点中の順番
		public function setBounds(idx:uint, value:Vector.<int>):void {
			idx *= 4;
			_bounds = value.slice(idx, idx + 4);
		}
		private var _bounds:Vector.<int>;
		
		// スキンとなる BitmapData
		public function set bitmapData(value:BitmapData):void { _bitmapData = value; }
		private var _bitmapData:BitmapData;

		private var model:Model;

		
		// 内部だけで使用するデータ
		// for drawTriangles
		private var graphicsData:Vector.<IGraphicsData>;
		private var path:GraphicsTrianglePath;
		private var vertices:Vector.<Number>;
		private var indices:Vector.<int>;
		private var uvtData:Vector.<Number>;
		
		static private var topIndex:uint = 0;
		
		private var isVisited:Boolean = false;
		private const visitedColor:ColorTransform = new ColorTransform(0, 0, 0, 1, Math.floor(Math.random()*0xFF), Math.floor(Math.random()*0xFF), Math.floor(Math.random()*0xFF), 0);
		private const noVisitedColor:ColorTransform = new ColorTransform(1, 1, 1, 1, 0, 0, 0, 0);

		
		public function View(model:Model) {
			// 対 Model
			this.model = model;
			model.addEventListener(Event.CHANGE, update);
			addEventListener(MouseEvent.ROLL_OVER, overHandler);
			addEventListener(MouseEvent.ROLL_OUT, outHandler);
			addEventListener(MouseEvent.CLICK, clickHandler);
		}
		
		private function overHandler(event:MouseEvent):void {
			if (topIndex == 0)
				topIndex = parent.numChildren - 1;
			parent.setChildIndex(this, topIndex);
			
			if (isVisited)
				transform.colorTransform = noVisitedColor;
		}
		private function outHandler(event:MouseEvent):void {
			if (isVisited)
				transform.colorTransform = visitedColor;
		}
		
		
		private function clickHandler(event:MouseEvent):void {
			isVisited = true;
			transform.colorTransform = visitedColor;
		}
		
		
		public function setup():void {
			// drawTriangles で使う Vector　の設定
			vertices = new Vector.<Number>(8, true);
			indices = Vector.<int>([
				0, 1, 3,
				1, 2, 3
			]);
			indices.fixed = true;
			uvtData = Vector.<Number>([
				0, 0, 1.0,
				1, 0, 1.0,
				1, 1, 1.0,
				0, 1, 1.0
			]);
			uvtData.fixed = true;
			
			// graphicsData の設定
			graphicsData = new Vector.<IGraphicsData>();
			graphicsData.push(new GraphicsBitmapFill(_bitmapData));
			graphicsData.push(path = new GraphicsTrianglePath(vertices, indices, uvtData));
			graphicsData.push(new GraphicsEndFill());
		}
		
		private function update(event:Event):void {
			var allVertices:Vector.<Number> = model.vertices;
			for (var i:int = 0; i < 4; i++) {
				var idx:int = _bounds[i];
				vertices[i * 2]     = allVertices[idx * 2];
				vertices[i * 2 + 1] = allVertices[idx * 2 + 1];
			}
			path.vertices = vertices;

			// set Ts in uvtData: code by Zeh Fernando
			// http://zehfernando.com/2010/the-best-drawplane-distortimage-method-ever/
			p1.x = vertices [0]; p1.y = vertices [1];
			p2.x = vertices [2]; p2.y = vertices [3];
			p3.x = vertices [6]; p3.y = vertices [7];
			p4.x = vertices [4]; p4.y = vertices [5];
			var pc:Point = getIntersection(p1, p4, p2, p3);
			if (pc != null) {
				// Lenghts of first diagonal
				var ll1:Number = Point.distance(p1, pc);
				var ll2:Number = Point.distance(pc, p4);
				// Lengths of second diagonal
				var lr1:Number = Point.distance(p2, pc);
				var lr2:Number = Point.distance(pc, p3);
				// Ratio between diagonals
				var f:Number = (ll1 + ll2) / (lr1 + lr2);
				// Magic
				uvtData [2] = (1 / ll2) * f;
				uvtData [5] = (1 / lr2);
				uvtData [8] = (1 / ll1) * f;
				uvtData [11] = (1 / lr1);
				path.uvtData = uvtData;
			}

			draw();
		}

		private function draw():void {
			graphics.clear();
			graphics.drawGraphicsData(graphicsData);
		}

		private var p1:Point = new Point,
			p2:Point = new Point, p3:Point = new Point, p4:Point = new Point;

		private function getIntersection(p1:Point, p2:Point, p3:Point, p4:Point):Point {
			// Returns a point containing the intersection between two lines
			// http://keith-hair.net/blog/2008/08/04/find-intersection-point-of-two-lines-in-as3/
			// http://www.gamedev.pastebin.com/f49a054c1

			var a1:Number = p2.y - p1.y;
			var b1:Number = p1.x - p2.x;
			var a2:Number = p4.y - p3.y;
			var b2:Number = p3.x - p4.x;

			var denom:Number = a1 * b2 - a2 * b1;
			if (denom == 0) return null;

			var c1:Number = p2.x * p1.y - p1.x * p2.y;
			var c2:Number = p4.x * p3.y - p3.x * p4.y;

			var p:Point = new Point((b1 * c2 - b2 * c1)/denom, (a2 * c1 - a1 * c2)/denom);

			if (Point.distance(p, p2) > Point.distance(p1, p2)) return null;
			if (Point.distance(p, p1) > Point.distance(p1, p2)) return null;
			if (Point.distance(p, p4) > Point.distance(p3, p4)) return null;
			if (Point.distance(p, p3) > Point.distance(p3, p4)) return null;

			return p;
		}
	}


	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	/**
	 * Controller
	 * マウス座標を Model に渡すだけ
	 * マウス座標を取得するので Sprite を継承する
	 * @author YOSHIDA, Akio (Aquioux)
	 */
	class Controller extends Sprite {
		private var model:Model;
		
		public function Controller(model:Model) {
			this.model = model;
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		private function enterFrameHandler(event:Event):void {
			var mousePoint:Point = new Point(mouseX, mouseY);
			model.update(mousePoint);
		}
	}

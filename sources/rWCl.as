/**
 * http://wonderfl.net/c/vZPT
 * adobe checkmate 1 で投稿した上記 URL 作品は本来、こういうものにしたかったのでした。
 * 詳細は http://aquioux.blog48.fc2.com/blog-entry-624.html から続く一連の解説をご覧ください。
 */
package {
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	[SWF(width = "465", height = "465", frameRate = "60", backgroundColor = "#FFFFFF")]
	

	public class Main extends Sprite {
		private var loader:Loader;

		// セグメント数関連
		private const SEGMENT_W:uint = 2;
		private const SEGMENT_H:uint = 3;

		// 各マネージャ
		private var anchorManager:AnchorManager;
		private var jointManager:JointManager;
		private var imageManager:ImageManager;
		
		// 表示・非表示フラグ
		private var anchorVisible:Boolean = false;
		

		public function Main() {
                        Wonderfl.capture_delay(15);
    
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler);
			loader.load(
				new URLRequest('http://assets.wonderfl.net/images/related_images/2/26/2613/2613f9ff013a6375ab59a0fdec5c37de867d8814'),
				new LoaderContext(true)
			);

		}
		
		private function completeHandler(event:Event):void {
			var bitmapData:BitmapData = new BitmapData(loader.width, loader.height);
			bitmapData.draw(loader);
			next(bitmapData);
		}
		
		private function next(bitmapData:BitmapData):void {
			// イメージのサイズ
			var imageWidth:Number  = bitmapData.width;
			var imageHeight:Number = bitmapData.height;
			
			// セグメント化クラス
			var segmentation:Segmentation = new Segmentation(SEGMENT_W, SEGMENT_H, imageWidth, imageHeight);
			
			// アンカーマネージャ処理
			initAnchor();
			anchorManager = new AnchorManager();
			var offsetX:Number = (stage.stageWidth  - imageWidth) / 2;
			var offsetY:Number = -250;// (stage.stageHeight - imageHeight) / 2;
			anchorManager.buildAnchors(segmentation, offsetX, offsetY);
			anchorManager.visible = false;
			
			// ジョイントマネージャ処理
			initJoint();
			jointManager = new JointManager(anchorManager.anchors);
			jointManager.buildJoints(SEGMENT_W, SEGMENT_H);
			jointManager.visible = false;

			// イメージマネージャ処理
			imageManager = new ImageManager(anchorManager.anchors);
			imageManager.buildImage(bitmapData, segmentation);
			
			// 各マネージャを addChild
			addChild(imageManager);
			addChild(anchorManager);
			addChild(jointManager);
			
			// イベントハンドラ
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}

		// キーボードイベント
		private function keyDownHandler(event:KeyboardEvent):void {
			if (event.charCode == 97) {		// "a" キーでアンカー表示
				anchorManager.visible = !anchorManager.visible;
			}
			if (event.charCode == 106) {	// "j" キーでジョイント表示
				jointManager.visible = !jointManager.visible;
			}
		}
		
		// フレームイベント
		private function enterFrameHandler(event:Event):void {
			anchorManager.update();
			jointManager.update();
			imageManager.update();
		}
		
		// アンカーの初期化
		private function initAnchor():void {
			Anchor.gravity       =  0.98;
			Anchor.friction      =  0.96;
			Anchor.floorFriction =  0.8;
			Anchor.bounce        = -0.1;

			Anchor.top    = -250;
			Anchor.bottom = stage.stageHeight;
			Anchor.left   = 0;
			Anchor.right  = stage.stageWidth;
		}

		// ジョイントの初期化
		private function initJoint():void {
			Joint.stiffness = 0.17;
		}
		
	}
	
}


	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	class AnchorManager extends Sprite {
		
		// アンカー格納 Vector
		private var _anchors:Vector.<Anchor>;
		public function get anchors():Vector.<Anchor> { return _anchors; }
		
		// アンカー表示・非表示フラグ
		private var _anchorVisible:Boolean;
		override public function get visible():Boolean { return _anchorVisible; }
		override public function set visible(value:Boolean):void {
			_anchorVisible = value;
			alpha = (_anchorVisible) ? 1.0 : 0.0;
		}
		
		
		public function AnchorManager() {
			addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		}
		
		// アンカーの生成
		public function buildAnchors(segmentation:Segmentation, offsetX:Number = 0.0, offsetY:Number = 0.0):void {
			var positions:Vector.<Number> = segmentation.verticies;
			var n:uint = positions.length / 2;
			_anchors = new Vector.<Anchor>(n);
			for (var i:uint = 0; i < n; i++) {
				var anchor:Anchor = new Anchor();
				anchor.x = positions[i * 2]     + offsetX;
				anchor.y = positions[i * 2 + 1] + offsetY;
				addChild(anchor);
				_anchors[i] = anchor;
			}
		}
		
		// アップデート
		public function update():void {
			for each (var anchor:Anchor in _anchors) {
				anchor.update();
			}
		}
		
		
		// マウスハンドラ
		private function mouseDownHandler(event:MouseEvent):void {
			var anchor:Anchor = Anchor(event.target);
			anchor.isMouseDown = true;
		}
		private function mouseUpHandler(event:MouseEvent):void {
			if (event.target != null) {
				var anchor:Anchor = Anchor(event.target);
				anchor.isMouseDown = false;
			}
		}
		
	}


	import flash.display.Sprite;
	import flash.events.MouseEvent;

	class Anchor extends Sprite {
		// 物理的数値
		static public var gravity:Number       =  0.98;	// 重力
		static public var friction:Number      =  0.99;	// 空気抵抗（数値が小さいほど抵抗が強くなる）
		static public var floorFriction:Number =  0.9;	// 床面抵抗（数値が小さいほど滑りにくい）
		static public var bounce:Number        = -0.9;	// 跳ね返り（絶対値が小さいほど跳ねにくい）

		// 壁面値
		static public var left:Number;
		static public var right:Number;
		static public var top:Number;
		static public var bottom:Number;

		// 計算用変数
		// 速度
		private var vx:Number = 0;
		private var vy:Number = 0;
		// 前フレームの座標値
		private var prevX:Number = 0;
		private var prevY:Number = 0;
		// 剛性反映用の値
		private var sx:Number = 0;
		private var sy:Number = 0;

		// ドラッグフラグ
		private var _isMouseDown:Boolean = false;
		public function set isMouseDown(value:Boolean):void {
			_isMouseDown = value;
			(_isMouseDown) ? startDrag() : stopDrag();
		}
		
		
		public function Anchor(radius:Number = 20.0, color:uint = 0x000000):void {
			graphics.clear();
			graphics.beginFill(color, 0.5);
			graphics.drawCircle(0, 0, radius);
			graphics.endFill();

			buttonMode = true;
		}

		// アクセル
		public function accelalete(valX:Number, valY:Number):void {
			vx = valX;
			vy = valY;
		}
		// ジョイントの剛性値を反映
		public function setStiffness(valX:Number, valY:Number):void {
			sx += valX;
			sy += valY;
		}

		public function update():void {
			if (_isMouseDown) {	// ドラッグしている場合
				// 壁処理
				if (x < left) { x = left; }		// 左側面
				if (x > right) { x = right; }	// 右側面
				if (y < top) { y = top; }		// 天井
				if (y > bottom) { y = bottom; }	// 床
				// 計算
				var tmpX:Number = x;
				var tmpY:Number = y;
				vx = x - prevX;
				vy = y - prevY;
				prevX = tmpX;
				prevY = tmpY;
			} else {			// ドラッグしていない場合
				// 壁処理
				if (x < left) {
					x = left;
					vx *= floorFriction;
					vx *= bounce;
				} else if (x > right) {
					x = right;
					vx *= floorFriction;
					vx *= bounce;
				}
				if (y < top) {
					y = top;
					vy *= floorFriction;
					vy *= bounce;
				} else if (y > bottom) {
					y = bottom;
					vy *= floorFriction;
					vy *= bounce;
				}
				// 計算
				vx += sx;
				vy += sy;
				vx *= friction;
				vy *= friction;
				vy += gravity;
				x += vx;
				y += vy;
			}

			// 剛性値の初期化
			sx = 0;
			sy = 0;
		}
		
	}


	import flash.display.GraphicsPath;
	import flash.display.GraphicsPathCommand;
	import flash.display.GraphicsSolidFill;
	import flash.display.GraphicsStroke;
	import flash.display.IGraphicsData;
	import flash.display.Shape;
	
	class JointManager extends Shape {
		
		// 各格納 Vector
		private var joints:Vector.<Joint>;
		private var pair:Vector.<int>;
		private var anchors:Vector.<Anchor>;
		
		// 描画用データ
		private var graphicsData:Vector.<IGraphicsData>;
		private var path:GraphicsPath;

		// ジョイント表示・非表示フラグ
		private var _jointVisible:Boolean;
		override public function get visible():Boolean { return _jointVisible; }
		override public function set visible(value:Boolean):void {
			_jointVisible = value;
			if (!_jointVisible) {
				graphics.clear();
			}
		}
		
		
		public function JointManager(anchors:Vector.<Anchor>) {
			this.anchors = anchors;
		}

		// ジョイントの生成
		public function buildJoints(segW:uint, segH:uint):void {
			createPair(segW, segH);		// 頂点の組み合わせの生成
			createGraphicsData();		// 表示用データの生成
			
			// ジョイントの生成
			var n:uint = pair.length / 2;
			joints = new Vector.<Joint>(n);
			for (var i:uint = 0; i < n; i++) {
				var a:uint = pair[i * 2];
				var b:uint = pair[i * 2 + 1];
				var joint:Joint = new Joint(anchors[a], anchors[b]);
				joints[i] = joint;
			}
		}
		
		// アップデート
		public function update():void {
			for each (var joint:Joint in joints) {
				joint.update();
			}
			
			if (_jointVisible) {
				// data の更新
				path.data = getData();
				// 描画
				graphics.clear();
				graphics.drawGraphicsData(graphicsData);
			}
		}
		

		// 頂点の組み合わせの生成
		private function createPair(segW:uint, segH:uint):void {
			pair = new Vector.<int>();

			// 横
			for (var i:uint = 0; i < segH + 1; i++) {
				for (var j:uint = 0; j < segW; j++) {
					var a:uint = i * (segW + 1) + j;
					var b:uint = i * (segW + 1) + j + 1;
					pair.push(a, b);
				}
			}
			
			// 縦
			for (i = 0; i < segH; i++) {
				for (j = 0; j < segW+1; j++) {
					a =  i      * (segW + 1) + j;
					b = (i + 1) * (segW + 1) + j;
					pair.push(a, b);
				}
			}
			
			// 斜め（左上から右下）
			for (i = 0; i < segH; i++) {
				for (j = 0; j < segW; j++) {
					a =  i      * (segW + 1) + j;
					b = (i + 1) * (segW + 1) + j + 1;
					pair.push(a, b);
				}
			}
			// 斜め（右上から左下）
			for (i = 0; i < segH; i++) {
				for (j = 0; j < segW; j++) {
					a =  i      * (segW + 1) + j + 1;
					b = (i + 1) * (segW + 1) + j;
					pair.push(a, b);
				}
			}
			
			if (segW % 2 == 0) {
				// 横斜め（左上から右下）
				for (i = 0; i < segH; i++) {
					for (j = 0; j < segW - 1; j += 2) {
						a =  i      * (segW + 1) + j;
						b = (i + 1) * (segW + 1) + j + 2;
						pair.push(a, b);
					}
				}
				// 横斜め（右上から左下）
				for (i = 0; i < segH; i++) {
					for (j = 0; j < segW; j+=2) {
						a =  i      * (segW + 1) + j + 2;
						b = (i + 1) * (segW + 1) + j;
						pair.push(a, b);
					}
				}
			}
			
			if (segH % 2 == 0) {
				// 縦斜め（左上から右下）
				for (i = 0; i < segH; i += 2) {
					for (j = 0; j < segW; j++) {
						a =  i      * (segW + 1) + j;
						b = (i + 2) * (segW + 1) + j + 1;
						pair.push(a, b);
					}
				}
				// 縦斜め（右上から左下）
				for (i = 0; i < segH; i+=2) {
					for (j = 0; j < segW; j++) {
						a =  i      * (segW + 1) + j + 1;
						b = (i + 2) * (segW + 1) + j;
						pair.push(a, b);
					}
				}
			}
			
			// 全体の対角線
			var numOfVertex:uint = (segW+1) * (segH+1);
			if (segW != segH) {
				pair.push(0, numOfVertex - 1);
				pair.push(segW, numOfVertex - 1 - segW);
			}
		}
		
		// GraphicsData の生成
		private function createGraphicsData():void{
			// 線
			var stroke:GraphicsStroke = new GraphicsStroke(0);
			stroke.fill = new GraphicsSolidFill(0xFFFFFF, 0.5);
			
			graphicsData = new Vector.<IGraphicsData>(2);
			graphicsData.push(stroke);
			graphicsData.push(path = new GraphicsPath(getCommands(), getData()));
		}

		// graphicsPath の commands の生成
		private function getCommands():Vector.<int> {
			var n:uint = pair.length / 2;
			var commands:Vector.<int> = new Vector.<int>(n*2);
			for (var i:uint = 0; i < n; i++) {
				commands[i * 2]     = GraphicsPathCommand.MOVE_TO;
				commands[i * 2 + 1] = GraphicsPathCommand.LINE_TO;
			}
			return commands;
		}
		// graphicsPath の data の生成（updata のたびに呼ばれる）
		private function getData():Vector.<Number> {
			var n:uint = pair.length;
			var data:Vector.<Number> = new Vector.<Number>(n * 2);
			for (var i:uint = 0; i < n; i++) {
				var anchor:Anchor = anchors[pair[i]];
				data[i * 2]     = anchor.x;
				data[i * 2 + 1] = anchor.y;
			}
			return data;
		}
		
	}


	class Joint {
		// 物理的数値
		static public var stiffness:Number = 0.17;		// 剛性値
	
		// 両端のアンカー
		private var a:Anchor;	// 片端のアンカー
		private var b:Anchor;	// もう片端のアンカー

		// アンカー間の値
		private var defaultDistance:Number = 0;	// アンカー間の距離（既定値）
		private var distanceXY:Number;			// アンカー間の距離（実際の値）
		private var distanceX:Number;	// distanceXY を求めるための X座標値
		private var distanceY:Number;	// distanceXY を求めるための Y座標値

		public function Joint(a:Anchor, b:Anchor):void {
			this.a = a;
			this.b = b;
			getAnchorRelationData();
			defaultDistance = distanceXY;
		}

		// ジョイントの剛性計算をおこない、対象アンカーに反映させる
		public function update():void {
			getAnchorRelationData();
			var s:Number  = stiffness * (distanceXY - defaultDistance);
			var sx:Number = s * distanceX / distanceXY;
			var sy:Number = s * distanceY / distanceXY;
			a.setStiffness(-sx, -sy);
			b.setStiffness( sx,  sy);
		}
	
		// アンカー間の値を更新
		private function getAnchorRelationData():void {
			var x:Number = a.x - b.x;
			var y:Number = a.y - b.y;
			distanceXY = Math.sqrt(x * x + y * y);
			distanceX = x;
			distanceY = y;
		}
		
	}


	import flash.display.BitmapData;
	import flash.display.GraphicsBitmapFill;
	import flash.display.GraphicsEndFill;
	import flash.display.GraphicsTrianglePath;
	import flash.display.IGraphicsData;
	import flash.display.Shape;
	
	class ImageManager extends Shape {
		
		// アンカー格納 Vector
		private var anchors:Vector.<Anchor>;
		
		// 描画用データ
		private var graphicsData:Vector.<IGraphicsData>;
		private var trianglePath:GraphicsTrianglePath;

		
		public function ImageManager(anchors:Vector.<Anchor>) {
			this.anchors = anchors;
		}

		// イメージ表示用データの生成
		public function buildImage(bitmapData:BitmapData, segmentation:Segmentation):void {
			createGraphicsData(bitmapData, segmentation);	// 表示用データの生成
		}
		
		// アップデート
		public function update():void {
			// drawTriangle のデータ更新
			trianglePath.vertices = getVerticies();
			// 描画
			graphics.clear();
			graphics.drawGraphicsData(graphicsData);
		}
		
		// GraphicsData の生成
		private function createGraphicsData(bitmapData:BitmapData, segmentation:Segmentation):void {
			graphicsData = new Vector.<IGraphicsData>(3);
			graphicsData.push(new GraphicsBitmapFill(bitmapData));
			graphicsData.push(trianglePath = new GraphicsTrianglePath(segmentation.verticies, segmentation.indicies, segmentation.uvData));
			graphicsData.push(new GraphicsEndFill());
		}

		// graphicsPath の verticies の生成（updata のたびに呼ばれる）
		// アンカー座標の更新
		private function getVerticies():Vector.<Number> {
			var n:uint = anchors.length;
			var verticies:Vector.<Number> = new Vector.<Number>(n * 2);
			for (var i:uint = 0; i < n; i++) {
				var anchor:Anchor = anchors[i]; 
				verticies[i * 2]     = anchor.x;
				verticies[i * 2 + 1] = anchor.y;
			}
			return verticies;
		}
		
	}


	class Segmentation {
		
		// verticies
		private var _verticies:Vector.<Number>;
		public function get verticies():Vector.<Number> { return _verticies; }
		// indicies
		private var _indicies:Vector.<int>;
		public function get indicies():Vector.<int> { return _indicies; }
		// uvDatas
		private var _uvData:Vector.<Number>;
		public function get uvData():Vector.<Number> { return _uvData; }
		

		// コンストラクタ
		public function Segmentation(segW:uint, segH:uint, width:Number = 1, height:Number = 1) {
			createVerticies(segW, segH, width, height);
			createIndicies(segW, segH);
			createUvData(segW, segH);
		}
		
		// verticies の生成
		private function createVerticies(segW:uint, segH:uint, w:Number, h:Number):void {
			_verticies = new Vector.<Number>((segW + 1) * (segH + 1) * 2);
			var cnt:uint = 0;
			for (var i:uint = 0; i < segH + 1; i++) {
				for (var j:uint = 0; j < segW + 1; j++) {
					verticies[cnt++] = j / segW * w;
					verticies[cnt++] = i / segH * h;
				}
			}
		}
		// indicies の生成
		private function createIndicies(segW:uint, segH:uint):void {
			_indicies = new Vector.<int>(segW * segH * 6);
			var cnt:uint = 0;
			for (var i:uint = 0; i < segH; i++) {
				for (var j:uint = 0; j < segW; j++) {
					var leftTop:uint  = i * (segW + 1) + j;
					var rightTop:uint = i * (segW + 1) + j + 1;
					var leftBottom:uint  = (i + 1) * (segW + 1) + j;
					var rightBottom:uint = (i + 1) * (segW + 1) + j + 1;
					indicies[cnt]     = leftTop;
					indicies[cnt + 1] = rightTop;
					indicies[cnt + 2] = leftBottom;
					indicies[cnt + 3] = rightTop;
					indicies[cnt + 4] = rightBottom;
					indicies[cnt + 5] = leftBottom;
					cnt += 6;
				}
			}
		}
		// uvDatas の生成
		private function createUvData(segW:uint, segH:uint):void {
			_uvData = new Vector.<Number>((segW + 1) * (segH + 1) * 2);
			var cnt:uint = 0;
			for (var i:uint = 0; i < segH + 1; i++) {
				for (var j:uint = 0; j < segW + 1; j++) {
					uvData[cnt++] = j / segW;
					uvData[cnt++] = i / segH;
				}
			}
		}
		
	}

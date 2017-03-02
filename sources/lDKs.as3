/**
画面を適当にクリックすると3クリック以降、ポイントと線がひかれます。
線は交差すること無くひかれていきます

参照：
ドロネー図
http://ja.wikipedia.org/wiki/ドロネー図
ドロネー図の作図方法
http://homepage3.nifty.com/endou/tips/04/tips33.htm
外接円
http://wonderfl.net/code/ad8b6c5010abdb44d3e34d3a7cd06a200b35175d
.fla2「YuruYurer」（195P）
http://www.amazon.co.jp/dp/4862670717
*/
package {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.MouseEvent;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
    import flash.system.Security;
    import flash.display.StageAlign;
	[SWF(width = 465, height = 465, backgroundColor = 0x0, frameRate = 60)]

	public class Delaunay extends Sprite {

		//----------------------------------------
		//VARIABLES
		
		//点群
		private var _points : Array;
		//三角形の集まり
		private var _triangles : Array;
		//キャンバス
		private var _canvas : Sprite;
		//background
        private var _background:BitmapData;

		/*
		 * コンストラクタ
		 */
		public function Delaunay() {
			//Security.allowDomain("*");
            //Security.allowDomain("planet-ape.net");
            //Security.allowDomain("wonderfl.net");
            //Security.allowDomain("swf.wonderfl.net");
			//初期化
			addEventListener(Event.ADDED_TO_STAGE, _initialize);
		}

		/*
		 * 初期化
		 */
		private function _initialize(event : Event) : void {
			removeEventListener(Event.ADDED_TO_STAGE, _initialize);
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			var stageWidth : Number = stage.stageWidth;
			var stageHeight : Number = stage.stageHeight;
			//背景カラー
            _background = new BitmapData(stageWidth , stageHeight, false, 0x0);
            addChild(new Bitmap(_background));

			//ドロー用
			_canvas = addChild(new Sprite()) as Sprite;

			_points = new Array();
			_triangles = new Array();
			
			//ステージの大きさの三角形2つを用意
			_points.push(new Node(0, 0, 0));
			_points.push(new Node(1, stageWidth, 0));
			_points.push(new Node(2, stageWidth, stageHeight));
			_points.push(new Node(3, 0, stageHeight));
			_triangles.push(new Triangle(_points[0], _points[1], _points[2]));
			_triangles.push(new Triangle(_points[0], _points[2], _points[3]));

			addEventListener(Event.ENTER_FRAME, _updateHandler);
			stage.addEventListener(MouseEvent.MOUSE_UP, _stageMouseUpHandler);
		}

		/*
		 * アップデート
		 */
		private function _updateHandler(event : Event) : void {
			_interaction();
			_draw();
		}

		/*
		 * インタラクション
		 */
		private function _interaction() : void {
			//一時保持の三角形群
			var localTriangles : Array = new Array();
			//辺
			var edges : Array;
			//多角形
			var polygon : Array;
			//ポイント群ループ
			for (var k : int = 4;k < _points.length;k++) {
				var node : Node = _points[k];
				localTriangles = new Array();
				edges = new Array();
			
				for (var i : String in _triangles) {
					//点が外接円
					var tri : Triangle = _triangles[i];
					if(inOuterCircle(node.point.x, node.point.y, tri)) {
						edges.push(new Edge(tri.node0, tri.node1));
						edges.push(new Edge(tri.node1, tri.node2));
						edges.push(new Edge(tri.node2, tri.node0));
					} else {
						localTriangles.push(tri);						
					}				
				}
				//edgesからpolygonを作る（重複辺の削除
				polygon = new Array();
				for (i in edges) {
					var edge0 : Edge = edges[i];
					//重複チェック
					var flg : Boolean = false;
					for (var j : String in polygon) {
						var edge1 : Edge = polygon[j];
						if(judgeEdges(edge0, edge1)) {
							flg = true;
							polygon.splice(j, 1);
							break;						
						}
					}
					//データが存在しない場合は追加
					if(!flg) polygon.push(edges[i]);
				}
				//polygonから三角形を作って挿入
				for (i in polygon) {
					var tri1 : Triangle = new Triangle(polygon[i].node0, polygon[i].node1, node);
					localTriangles.push(tri1);
				}
			}
			if(localTriangles.length > 1) _triangles = localTriangles;
		}

		/*
		 * 同じ辺かどうかの判定
		 */
		private function judgeEdges(edge : Edge, edge0 : Edge) : Boolean {			
			if(edge.node0.id == edge0.node0.id && edge.node1.id == edge0.node1.id) {
				return true;				
			}
			if(edge.node1.id == edge0.node0.id && edge.node0.id == edge0.node1.id) {
				return true;
			}
			return false;
		}

		/*
		 * 描画
		 */
		private function _draw() : void {
			var g : Graphics = _canvas.graphics;
			var offset : Number = 0;
			g.clear();
			g.lineStyle(1, 0xffffff);
			
			//三角形群のループ
			for (var i : int = 0;i < _triangles.length;i++) {
				var tri : Triangle = _triangles[i];
				//四隅のポイントを含む三角形は描画しない
				if(!(tri.node0.id == 0 || tri.node1.id == 0 || tri.node2.id == 0 ||
					tri.node0.id == 1 || tri.node1.id == 1 || tri.node2.id == 1 ||
					tri.node0.id == 2 || tri.node1.id == 2 || tri.node2.id == 2 ||
					tri.node0.id == 3 || tri.node1.id == 3 || tri.node2.id == 3)
				){
				g.moveTo(tri.node0.point.x + offset, tri.node0.point.y + offset);
				g.lineTo(tri.node1.point.x + offset, tri.node1.point.y + offset);
				g.lineTo(tri.node2.point.x + offset, tri.node2.point.y + offset);
				g.lineTo(tri.node0.point.x + offset, tri.node0.point.y + offset);
				g.beginFill(0xFF0000);
				g.drawCircle(tri.node0.point.x + offset, tri.node0.point.y + offset, 3);
				g.drawCircle(tri.node1.point.x + offset, tri.node1.point.y + offset, 3);
				g.drawCircle(tri.node2.point.x + offset, tri.node2.point.y + offset, 3);
				g.endFill();					
				}
			}
		}

		/*
		 * 外接円の内か外か
		 */
		static function inOuterCircle(x : Number,y : Number,tri : Triangle) : Boolean {
			var node0 : Node = tri.node0;
			var node1 : Node = tri.node1;
			var node2 : Node = tri.node2;
			
			var d : Number = (node0.point.x * node0.point.x + node0.point.y * node0.point.y - x * x - y * y) * ((node1.point.x - x) * (node2.point.y - y) - (node2.point.x - x) * (node1.point.y - y)) + (node1.point.x * node1.point.x + node1.point.y * node1.point.y - x * x - y * y) * ((node2.point.x - x) * (node0.point.y - y) - (node2.point.y - y) * (node0.point.x - x)) + (node2.point.x * node2.point.x + node2.point.y * node2.point.y - x * x - y * y) * ((node0.point.x - x) * (node1.point.y - y) - (node0.point.y - y) * (node1.point.x - x));
			return ( (node1.point.x - node0.point.x) * (node2.point.y - node0.point.y) - (node1.point.y - node0.point.y) * (node2.point.x - node0.point.x) > 0 ) ? d > 0 : d <= 0;
		}

		/*
		 * マウスクリック時
		 */
		private function _stageMouseUpHandler(event : MouseEvent) : void {
			_points.push(new Node(_points.length, mouseX, mouseY));
		}
	}
}
class Triangle {
	private var _node0 : Node;
	private var _node1 : Node;
	private var _node2 : Node;
	
	public function Triangle(node0:Node,node1:Node,node2:Node):void {
		_node0 = node0;
		_node1 = node1;
		_node2 = node2;
	}
	
	public function get node0() : Node {
		return _node0;
	}
	
	public function get node1() : Node {
		return _node1;
	}
	
	public function get node2() : Node {
		return _node2;
	}
}
import flash.geom.Point;
class Node {
	private var _id : int;
	private var _point : Point;

	public function Node(id:int,x:Number,y:Number) {
		_id = id;
		_point = new Point(x,y);
	}
	
	public function get id() : int {
		return _id;
	}
	
	public function get point() : Point {
		return _point;
	}
}
class Edge {
	private var _node0 : Node;
	private var _node1 : Node;
	
	public function Edge(node0:Node,node1:Node):void {
		_node0 = node0;
		_node1 = node1;
	}
	
	public function get node0() : Node {
		return _node0;
	}
	
	public function get node1() : Node {
		return _node1;
	}
}

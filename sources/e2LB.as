/* ------------------------------------------------------------------
 * 最短経路を進むパーティクル（のはず）
 * 
 * [inspired by]
 * Desktop Tower Defense
 * http://www.handdrawngames.com/DesktopTD/
 * Dijkstra Visualization
 * http://wonderfl.net/c/fVQE
 * and 神の書とwonderflのパーティクル作品群
 * ------------------------------------------------------------------
 * [操作方法]
 * マウスのみ。
 * クリックすると壁を設置・除去できます。
 * ------------------------------------------------------------------
 * [簡単な説明]
 * main : 全体の初期化と更新処理
 * Node : マス目の情報
 * Wall : 壁の情報
 * Particle : パーティクルの情報
 * Start : パーティクルを出現させる場所です
 * Goal : パーティクルの目的地（ここで経路探索処理してます）
 * Parameter : ここのXMLをいじるといろいろ変えられます
 * ------------------------------------------------------------------
 * 
 * とりあえず投稿。内容、コメント等は後で充実させていきます。
 * 
 */
package {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	[SWF(frameRate=30)]
	public class main extends Sprite {		
		public static const MAP_SIZE:int = 33;
		public static const NODE_SIZE:int = 15;
		
		// ノード、パーティクル、スタート、ゴールのコレクション
		public static var nodes:Array;
		public static var particles:Array;
		private var _starts:Array;
		private var _goals:Array;
		
		// パーティクル、壁、カーソルの表示オブジェクト関係
		private var _particleCanvas:BitmapData;
		private var _canvasRect:Rectangle;
		private var _colorTransform:ColorTransform;
		private var _wallLayer:Sprite;
		private var _cursor:Shape;
		
		public function main() {
			// ノード、パーティクル、壁、ゴール、スタートの順で初期化
			initializeNodes();
			initializeParticles();
			initializeWalls();
			initializeStreams();	
			
			addEventListener(Event.ENTER_FRAME, update);
			
			initializeCursor();
			
		}
		
		// ノードの初期化
		private function initializeNodes():void {
			main.nodes = [];
			for (var row:int = 0; row < main.MAP_SIZE; row++) {
				main.nodes[row] = [];
				for (var col:int = 0; col < main.MAP_SIZE; col++) {
					main.nodes[row][col] = new Node(col, row);
				}
			}
		}
		
		// パーティクルの初期化
		private function initializeParticles():void {
			Particle.createImages();
			
			var numParticles:int = Parameter.numParticles;
			particles = new Array(numParticles);
			for (var i:int = 0; i < numParticles; i++){
				particles[i]= new Particle();
			}
			
			var particleLayer:Bitmap = new Bitmap();
			_particleCanvas = new BitmapData(465, 465, false, 0x000000);
			particleLayer.bitmapData = _particleCanvas;
			addChild(particleLayer);
			
			_canvasRect = new Rectangle(0, 0, 465, 465);
			_colorTransform = new ColorTransform(0.9, 0.9, 0.9);
		}
		
		// 壁の初期化
		private function initializeWalls():void {
			_wallLayer = new Sprite();
			var walls:Array = Parameter.getWalls();
			var len:int = int(walls.length);
			for (var i:int = 0; i < len; i++) {
				_wallLayer.addChild(walls[i]);
			}
			addChild(_wallLayer);
		}
		
		// スタートノード、ゴールノードの初期化
		private function initializeStreams():void {
			_goals = Parameter.getGoals();
			_starts = Parameter.getStarts(_goals);
			Start.setSpawnInterval();
			
			// パーティクルの出現をばらつかせるためにシャッフルする
			shuffle(_starts);
		}
		
		// 配列をシャッフルする
		private function shuffle(arr:Array):void {
			var i:int = arr.length;
			while (i) {
				var j:int = Math.floor(i * Math.random());
				var tmp:* = arr[--i];
				arr[i] = arr[j];
				arr[j] = tmp;
			}
		}
		
		// カーソルの初期化
		private function initializeCursor():void {
			_cursor = new Shape();
			_cursor.graphics.lineStyle(1, 0xffff00);
			_cursor.graphics.drawRect(0, 0, main.NODE_SIZE * 2 - 0.5, main.NODE_SIZE * 2 - 0.5);
			addChild(_cursor);
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, moveCursor);
			stage.addEventListener(MouseEvent.CLICK, clickMap);
		}
		
		// カーソルの移動
		private function moveCursor(e:MouseEvent):void {
			_cursor.x = e.stageX - (e.stageX % main.NODE_SIZE);
			_cursor.y = e.stageY - (e.stageY % main.NODE_SIZE);
		}
		
		// マップクリック時の挙動
		private function clickMap(e:MouseEvent):void {
			var wall:Wall;
			
			// クリックした場所が除去できる壁なら除去する
			if (e.target is Wall) {
				wall = e.target as Wall;
				if (wall.removable) {
					wall.remove();
					reSearchGoals();
				}
			// クリックした場所に壁が設置できるなら設置する
			}else {
				var tile:Point = Node.tileFormPos(new Point(e.stageX, e.stageY));
				if (buildableWall(tile.x, tile.y)) {
					wall = new Wall(tile.x, tile.y);
					_wallLayer.addChild(wall);
					reSearchGoals();
				}
			}
		}
		
		// 全てのゴールノードを更新（経路の最探索）をする
		private function reSearchGoals():void {
			var len:int = _goals.length;
			for (var i:int = 0; i < len; i++) {
				_goals[i].search();
			}
		}
		
		// 指定した位置に壁が設置できるか
		private function buildableWall(tilex:int, tiley:int):Boolean {
			return (main.nodes[tiley][tilex].passable &&
			main.nodes[tiley][tilex + 1].passable &&
			main.nodes[tiley + 1][tilex].passable &&
			main.nodes[tiley + 1][tilex + 1].passable);
		}
		
		// 毎フレームの更新処理
		private function update(e:Event):void {
			spawnParticles();	
			updateParticles();
		}
		
		// スタートノードからパーティクルを出現させる
		private function spawnParticles():void {
			var numStarts:int = _starts.length;
			for (var i:int = 0; i < numStarts; i++) {
				_starts[i].update();
			}
		}
		
		// パーティクルの更新を行う
		private function updateParticles():void {
			_particleCanvas.lock();
			for (var i:int = 0; i < Parameter.numParticles; i++) {
				// パーティクルが画面内に存在していたら更新
				if(main.particles[i].exists){
					main.particles[i].update();
					main.particles[i].draw(_particleCanvas);
				}
			}
			_particleCanvas.colorTransform(_canvasRect, _colorTransform);
			_particleCanvas.unlock();
		}
	}
}

import flash.display.Shape;
import flash.geom.Point;

class Node {
	private var _tilex:int;
	private var _tiley:int;
	private var _centerx:Number;
	private var _centery:Number;
	private var _passable:Boolean;
	
	public function get tileX():int { return _tilex; }
	public function get tileY():int { return _tiley; }
	public function get centerX():Number { return _centerx; }
	public function get centerY():Number { return _centery; }
	public function get passable():Boolean { return _passable; }
	public function set passable(arg:Boolean):void { _passable = arg; }
	
	public function Node(tilex:int, tiley:int) {
		_tilex = tilex;
		_tiley = tiley;
		var pos:Point = Node.posFromTile(new Point(_tilex, _tiley));
		_centerx = pos.x + (main.NODE_SIZE / 2);
		_centery = pos.y + (main.NODE_SIZE / 2);
		_passable = true;
	}
	
	// タイル縦横値からXY座標値を求める
	public static function posFromTile(tile:Point):Point {
		var pos:Point = new Point();
		
		pos.x = (tile.x * main.NODE_SIZE) - main.NODE_SIZE;
		if (pos.x < -main.NODE_SIZE) {
			pos.x = -main.NODE_SIZE;
		}else if (pos.x > (main.NODE_SIZE * (main.MAP_SIZE - 1))) {
			pos.x = (main.NODE_SIZE * (main.MAP_SIZE - 1));
		}
		
		pos.y = (tile.y * main.NODE_SIZE) - main.NODE_SIZE;
		if (pos.y < -main.NODE_SIZE) {
			pos.y = -main.NODE_SIZE;
		}else if (pos.y > (main.NODE_SIZE * (main.MAP_SIZE - 1))) {
			pos.y = (main.NODE_SIZE * (main.MAP_SIZE - 1));
		}
		
		return pos;
	}
	
	// XY座標値からタイル縦横値を求める
	public static function tileFormPos(pos:Point):Point {
		var tile:Point = new Point();
		
		tile.x = Math.floor(pos.x / main.NODE_SIZE) + 1;
		if (tile.x < 0) {
			tile.x = 0;
		}else if (tile.x > main.MAP_SIZE - 1) {
			tile.x = main.MAP_SIZE - 1;
		}
		
		tile.y = Math.floor(pos.y / main.NODE_SIZE) + 1;
		if (tile.y < 0) {
			tile.y = 0;
		}else if (tile.y > main.MAP_SIZE - 1) {
			tile.y = main.MAP_SIZE - 1;
		}
		
		return tile;
	}
}

import flash.display.Sprite;
import flash.geom.Point;

class Wall extends Sprite {
	private var _tilex:int;
	private var _tiley:int;
	private var _removable:Boolean;
	
	public function get removable():Boolean { return _removable; }
	
	public function Wall(tilex:int, tiley:int, removable:Boolean = true) {
		_tilex = tilex;
		_tiley = tiley;
		var pos:Point = Node.posFromTile(new Point(_tilex, _tiley));
		this.x = pos.x;
		this.y = pos.y;
		_removable = removable;
		
		setNodePassablity(false);
		draw();
	}
	
	// 壁を設置した部分のノードの通行可能性を変更する
	private function setNodePassablity(passable:Boolean):void {
		main.nodes[_tiley][_tilex].passable = passable;
		main.nodes[_tiley][_tilex + 1].passable = passable;
		main.nodes[_tiley + 1][_tilex].passable = passable;
		main.nodes[_tiley + 1][_tilex + 1].passable = passable;
	}
	
	// 壁の画像を描画する
	private function draw():void {
		var rectSize:Number = main.NODE_SIZE * 2;
		
		if (_removable) {
			rectSize -= 0.5;
			graphics.lineStyle(1, 0x222222);
		}
		
		graphics.beginFill(0x111111);
		graphics.drawRect(0, 0, rectSize, rectSize);
		graphics.endFill();
	}
	
	// 壁を取り除く際に呼ぶ関数
	public function remove():void {
		setNodePassablity(true);
		parent.removeChild(this);
	}
}


import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.display.Shape;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;

class Particle {
	private static const IMAGE_COLORS:Array =
	[0x0000ff, 0x3333ff, 0x6666ff, 0x9999ff, 0xccccff, 0xffffff,
	 0x0033ff, 0x0066ff, 0x0099ff, 0x00ccff, 0x00ffff,
	 0x33ffff, 0x66ffff, 0x99ffff, 0xccffff];
	private static var IMAGE_RADIUS:int;
	
	private var _posx:Number;
	private var _posy:Number;
	private var _vx:Number;
	private var _vy:Number;
	
	private var _speed:Number;
	private var _exists:Boolean;
	private var _start:Start;
	
	private static var _images:Array;
	private var _imageIndex:int;
	private static var _sourceRect:Rectangle;
	
	public function get exists():Boolean { return _exists; }
	
	public function Particle() {
		_posx = _posy = _vx = _vy = 0;
		_speed = ((Parameter.particleMaxSpeed - 1) * Math.random()) + 1;
		_exists = false;
		_start = null;
		_imageIndex = 0;
	}
	
	// スタートノードから出現させる
	public function spawn(start:Start):void {
		_posx = start.node.centerX;
		_posy = start.node.centerY;
		_exists = true;
		_start = start;
		_imageIndex = Math.floor(Particle.IMAGE_COLORS.length * Math.random());
	}
	
	public function update():void {
		_posx += _vx;
		_posy += _vy;
		
		var tile:Point = Node.tileFormPos( new Point(_posx, _posy));
		// ゴールに着いたか、移動不可能（かべのなかにいる）なら消滅する
		if (arrivedGoal(tile.x, tile.y) || !isMovable(tile.x, tile.y)) {
			_exists = false;
			return;
		}
		
		var nextNode:Node = _start.destination.getNext(tile.x, tile.y);
		// ゴールノードへの経路が存在しないなら止まる
		if (nextNode == main.nodes[tile.y][tile.x]) {
			_vx = 0;
			_vy = 0;
		}else {
			var radians:Number = Math.atan2(nextNode.centerY - _posy, nextNode.centerX - _posx);
			_vx = _speed * Math.cos(radians);
			_vy = _speed * Math.sin(radians);
		}
	}
	
	// ゴールノードへ到着しているかどうか
	private function arrivedGoal(tilex:int, tiley:int):Boolean {
		var goalNode:Node = _start.destination.node;
		
		return (tilex == goalNode.tileX) && (tiley == goalNode.tileY);
	}
	
	// パーティクルが移動できるかどうか
	private function isMovable(tilex:int, tiley:int):Boolean {
		return main.nodes[tiley][tilex].passable;
	}
	
	public function draw(canvas:BitmapData):void {
		var destPoint:Point = new Point(_posx - Particle.IMAGE_RADIUS, _posy - Particle.IMAGE_RADIUS);
		canvas.copyPixels(_images[_imageIndex], _sourceRect, destPoint);
	}
	
	// パーティクルの画像を予め作成しておく関数
	public static function createImages():void {
		Particle.IMAGE_RADIUS = Parameter.particleRadius;
		_images = [];
		_sourceRect = new Rectangle(0, 0, Particle.IMAGE_RADIUS * 2, Particle.IMAGE_RADIUS * 2);
		for (var i:int = 0; i < Particle.IMAGE_COLORS.length; i++) {
			var bitmapData:BitmapData = new BitmapData(Particle.IMAGE_RADIUS * 2, Particle.IMAGE_RADIUS * 2, true, 0x00ffffff);
			var shape:Shape = new Shape();
			shape.graphics.beginFill(Particle.IMAGE_COLORS[i]);
			shape.graphics.drawCircle(Particle.IMAGE_RADIUS, Particle.IMAGE_RADIUS, Particle.IMAGE_RADIUS);
			shape.graphics.endFill();
			bitmapData.draw(shape);
			_images.push(bitmapData);
		}
	}
}


class Start {
	private static var SPAWN_INTERVAL:int;
	
	private var _node:Node;
	private var _destination:Goal;
	private var _spawnCount:int;
	
	public function get node():Node { return _node; }
	public function get destination():Goal { return _destination; }
	
	public function Start(node:Node, dest:Goal) {
		_node = node;
		_destination = dest;
		_spawnCount = 0;
	}
	
	public function update():void {
		// ゴールノードへの経路が存在しない場合は何もしない
		if (_destination.getCost(node.tileX, node.tileY) == int.MAX_VALUE) { return; }
		
		// 一定の間隔でパーティクルの出現を試みる
		if (++_spawnCount >= Start.SPAWN_INTERVAL) {
			// 画面上に存在しないパーティクルがあればそれをここから出現させる
			var len:int = main.particles.length;
			for (var i:int = 0; i < len; i++) {
				if (!main.particles[i].exists) {
					main.particles[i].spawn(this);
					_spawnCount = 0;
					break;
				}
			}
		}
	}
	
	public static function setSpawnInterval():void {
		Start.SPAWN_INTERVAL = Parameter.spawnInterval;
	}
}


class Goal {
	private static const DX:Array = [ -1, 0, 1, -1, 1, -1, 0, 1];
	private static const DY:Array = [ -1, -1, -1, 0, 0, 1, 1, 1];
	private static const DCOST:Array = [Math.SQRT2, 1, Math.SQRT2, 1, 1, Math.SQRT2, 1, Math.SQRT2];
	
	private var _ID:int;
	private var _node:Node;
	
	private var _openNodes:Array;	// 保留ノードリスト
	private var _closedNodes:Array;	// 確定ノードリスト
	private var _nodeCost:Array;	// 各ノードの移動コスト
	private var _nodeNext:Array;	// 各ノードの次の経路となるノード
	
	public function get ID():int { return _ID; }
	public function get node():Node { return _node; }
	public function getCost(tilex:int, tiley:int):int { return _nodeCost[tiley][tilex]; }
	public function getNext(tilex:int, tiley:int):Node { return _nodeNext[tiley][tilex]; }
	
	public function Goal(ID:int, node:Node) {
		_ID = ID;
		_node = node;
		
		_openNodes = [];
		_closedNodes = [];
		_nodeCost = [];
		_nodeNext = [];
		for (var row:int = 0; row < main.MAP_SIZE; row++) {
			_closedNodes[row] = [];
			_nodeCost[row] = [];
			_nodeNext[row] = [];
		}
		
		search();
	}
	
	private function initialize():void {
		for (var row:int = 0; row < main.MAP_SIZE; row++) {
			for (var col:int = 0; col < main.MAP_SIZE; col++) {
				_closedNodes[row][col] = false;
				_nodeCost[row][col] = int.MAX_VALUE;
				_nodeNext[row][col] = main.nodes[row][col];
			}
		}
		
		// Goalのノードを経路探索のスタートノードとする
		_nodeCost[_node.tileY][_node.tileX] = 0;
		_openNodes.push(main.nodes[_node.tileY][_node.tileX]);
	}
	
	// ダイクストラ法による経路探索
	public function search():void {
		initialize();
		
		while (_openNodes.length > 0) {
			var subject:Node = _openNodes.pop() as Node;
			_closedNodes[subject.tileY][subject.tileX] = true;
			
			// 周囲8方向のノードを訪問する
			for (var i:int = 0; i < 8; i++) {
				// 画面外の存在しないノードを指すなら次の周囲ノードへ進む
				if (!isValid(subject.tileX + Goal.DX[i]) || !isValid(subject.tileY + Goal.DY[i])) { continue; }
				
				// 壁が設置されているノード、確定ノード、直進することができないノードなら次の周囲ノードへ進む
				var test:Node = main.nodes[subject.tileY + Goal.DY[i]][subject.tileX + Goal.DX[i]];
				if (isWall(test) || isClosedNode(test) || !canGoStraightTo(subject, test)) { continue; }
				
				// 既存の移動コストより小さかったら更新する
				if (_nodeCost[test.tileY][test.tileX] > _nodeCost[subject.tileY][subject.tileX] + Goal.DCOST[i]) {
					_nodeCost[test.tileY][test.tileX] = _nodeCost[subject.tileY][subject.tileX] + Goal.DCOST[i];
					// 次の経路ノードをsubjectノードに設定する
					_nodeNext[test.tileY][test.tileX] = subject;
					// 保留ノードリストに追加する
					insertToOpenNodes(test);
				}
			}
		}
	}
	
	// indexの値が有効な値かどうか
	private function isValid(index:int):Boolean {
		return ((index >= 0) && (index < main.MAP_SIZE));
	}
	
	private function isClosedNode(node:Node):Boolean {
		return _closedNodes[node.tileY][node.tileX];
	}
	
	// 壁が設置されたノードかどうか
	private function isWall(node:Node):Boolean {
		return !node.passable;
	}
	
	// subjectノードからtestノードへ直進できるかどうか
	private function canGoStraightTo(subject:Node, test:Node):Boolean {
		return (main.nodes[subject.tileY][test.tileX].passable && main.nodes[test.tileY][subject.tileX].passable);
	}
	
	// nodeを保留ノードリストの適切な場所に挿入する
	private function insertToOpenNodes(node:Node):void {
		var insertIndex:int;
		var len:int = _openNodes.length;
		var nodeCost:int = _nodeCost[node.tileY][node.tileX];
		
		for (insertIndex = 0; insertIndex < len; insertIndex++) {
			var openNode:Node = _openNodes[insertIndex];
			if (nodeCost > _nodeCost[openNode.tileY][openNode.tileX]) { break; }
		}
		_openNodes.splice(insertIndex, 0, node);
	}
}


import flash.geom.Point;

class Parameter {
	private static const data:XML =
	<root>
		<particles num="1000" radius="2" maxspeed="8" />
		<walls>
			<wall x="0" y="0" rem="f"/><wall x="2" y="0" rem="f"/>
			<wall x="4" y="0" rem="f"/><wall x="6" y="0" rem="f"/>
			<wall x="8" y="0" rem="f"/><wall x="10" y="0" rem="f"/>
			<wall x="21" y="0" rem="f"/><wall x="23" y="0" rem="f"/>
			<wall x="25" y="0" rem="f"/><wall x="27" y="0" rem="f"/>
			<wall x="29" y="0" rem="f"/><wall x="31" y="0" rem="f"/>
			
			<wall x="0" y="31" rem="f"/><wall x="2" y="31" rem="f"/>
			<wall x="4" y="31" rem="f"/><wall x="6" y="31" rem="f"/>
			<wall x="8" y="31" rem="f"/><wall x="10" y="31" rem="f"/>
			<wall x="21" y="31" rem="f"/><wall x="23" y="31" rem="f"/>
			<wall x="25" y="31" rem="f"/><wall x="27" y="31" rem="f"/>
			<wall x="29" y="31" rem="f"/><wall x="31" y="31" rem="f"/>
			
			<wall x="0" y="2" rem="f"/><wall x="0" y="4" rem="f"/>
			<wall x="0" y="6" rem="f"/><wall x="0" y="8" rem="f"/>
			<wall x="0" y="10" rem="f"/><wall x="0" y="21" rem="f"/>
			<wall x="0" y="23" rem="f"/><wall x="0" y="25" rem="f"/>
			<wall x="0" y="27" rem="f"/><wall x="0" y="29" rem="f"/>
			
			<wall x="31" y="2" rem="f"/><wall x="31" y="4" rem="f"/>
			<wall x="31" y="6" rem="f"/><wall x="31" y="8" rem="f"/>
			<wall x="31" y="10" rem="f"/><wall x="31" y="21" rem="f"/>
			<wall x="31" y="23" rem="f"/><wall x="31" y="25" rem="f"/>
			<wall x="31" y="27" rem="f"/><wall x="31" y="29" rem="f"/>
		</walls>
		<starts interval="10">
			<start dest="0" x="12" y="0"/>
			<start dest="0" x="13" y="0"/>
			<start dest="1" x="14" y="0"/>
			<start dest="1" x="15" y="0"/>
			<start dest="2" x="16" y="0"/>
			<start dest="3" x="17" y="0"/>
			<start dest="3" x="18" y="0"/>
			<start dest="4" x="19" y="0"/>
			<start dest="4" x="20" y="0"/>
			
			<start dest="5" x="0" y="12"/>
			<start dest="5" x="0" y="13"/>
			<start dest="6" x="0" y="14"/>
			<start dest="6" x="0" y="15"/>
			<start dest="7" x="0" y="16"/>
			<start dest="8" x="0" y="17"/>
			<start dest="8" x="0" y="18"/>
			<start dest="9" x="0" y="19"/>
			<start dest="9" x="0" y="20"/>
		</starts>
		<goals>
			<goal id="0" x="14" y="32"/>
			<goal id="1" x="15" y="32"/>
			<goal id="2" x="16" y="32"/>
			<goal id="3" x="17" y="32"/>
			<goal id="4" x="18" y="32"/>
			
			<goal id="5" x="32" y="14"/>
			<goal id="6" x="32" y="15"/>
			<goal id="7" x="32" y="16"/>
			<goal id="8" x="32" y="17"/>
			<goal id="9" x="32" y="18"/>
		</goals>
	</root>;
	
	public static function get numParticles():int {
		return int(Parameter.data.particles.@num);
	}
	
	public static function get particleRadius():int {
		return int(Parameter.data.particles.@radius);
	}
	
	public static function get particleMaxSpeed():Number {
		return Number(Parameter.data.particles.@maxspeed);
	}
	
	public static function get spawnInterval():int {
		return int(Parameter.data.starts.@interval);
	}
	
	public static function getWalls():Array {
		var walls:Array = [];
		for each(var w:XML in Parameter.data.walls.*) {
			var removable:Boolean = ((w.@rem == "t") ? true : false);
			var wall:Wall = new Wall(int(w.@x), int(w.@y), removable);
			walls.push(wall);
		}
		return walls;
	}
	
	public static function getStarts(goals:Array):Array {
		var starts:Array = [];
		var len:int = goals.length;
		
		for each(var s:XML in Parameter.data.starts.*) {
			var destID:int = int(s.@dest);
			var i:int;
			for (i = 0; i < len; i++) {
				if (destID == goals[i].ID) { break; }
			}
			if (i >= len) { i = 0; }
			
			var node:Node = main.nodes[int(s.@y)][int(s.@x)];
			var dest:Goal = goals[i];
			var start:Start = new Start(node, dest);
			starts.push(start);
		}
		return starts;
	}
	
	public static function getGoals():Array {
		var goals:Array = [];
		for each(var g:XML in Parameter.data.goals.*) {
			var node:Node = main.nodes[int(g.@y)][int(g.@x)];
			var goal:Goal = new Goal(int(g.@id), node);
			goals.push(goal);
		}
		return goals;
	}
}
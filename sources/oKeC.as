// forked from osamX's ワンダフルクエスト
// forked from nengafl's nengafl
/*
 * [遊び方]
 * はじめに、マップをクリックして...
 * ↑ , w :	上に移動
 * ↓ , s :	下に移動
 * ← , a :	左に移動
 * → , d :	右に移動
 * 
 * マップは毎回ランダムに生成されます。
 * 一階層しか探索できません。
 * やり直したいときはリロードしてください。
 * 
 * マップチップ素材
 * http://www.tekepon.net/fsm/
 * 
 * ダンジョン生成参考
 * http://racanhack.sourceforge.jp/rhdoc/index.html
 */
package 
{
    import flash.display.*;
	import flash.events.*;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import frocessing.math.Random;

	[SWF(width="465", height="465", frameRate="30", backgroundColor="0x000000")]
	public class Main extends Sprite 
	{
		private const SIZE:Number = 465;//ステージの大きさ
		private const SCALE:Number = 4.0; //勇者やフィールドの拡大率
		private const SPEED:Number = 6;	//勇者が歩くスピード FLDSIZEの約数にしてください
		private const MAPSIZE:uint = 50;//マップの横・縦のマスの個数
		private const FLDSIZE:uint = 72;//フィールド（マップ上の1マス）の横・縦のドット数
		
		private const SCALE2:int = 8;
		private var circle:Sprite;
		private var bd:BitmapData;
		private var image:BitmapData;
		private var dark:Bitmap;
		private var bitmap:Bitmap;
		
		private var yuusha:Yuusha;		//勇者
		private var yuushaPos:Point;	//勇者のマップ上の座標
		private var map:Sprite;			//マップ本体　これを動かして勇者が移動しているように見せる
		private var bMapData:Array = [];//フィールドが障害物か否かを記憶
		private var frameCount:Number = 0;	//onEnterFrameで使用
		private var keyFlags:Array = [false, false, false, false]; //下上左右のキーが押されているか
		private var walkDirection:int = 4;	//歩いていく方向 （0～3：下上左右  4:止）
		private var loaded:int = 0;		//読み込み完了した画像の個数
		private var isInit:Boolean = false;	//初期化されているか　onEnterFrameで使用
		private var prgSpr:Sprite;		//ロード画面表示用
		
		/**-----------------------------------------------------
		 * マップの1マス（フィールド）のリストです。
		 * ここをいじると好きな画像をマップ上に貼ることができます。
		 * 画像のサイズは、基本的に16*16ピクセルです。
		 * 形式はjpeg,gif,pngのどれかにしてください。
		 * Twitterのアイコン画像取得は、こちらのAPIを使わせてもらってます。
		 * http://usericons.relucks.org/
		 * ----------------------------------------------------- */
		private const fieldList:Array = [
			new Field(32 * 5, 32 * 6, true),
			new Field(0, 32 * 6, false),
			new Field(0, 32 * 6, false),
		];
		
		/**-----------------------------------------------------
		 * マップのデータ（ここが木で、あそこが芝生で．．．ってやつ）が入ってます。
		 * ここをいじると、マップが変わります。上のfieldListのコメント参照。
		 * ----------------------------------------------------- */
		private var mapData:Array;
		
		/**-----------------------------------------------------
		 * コンストラクタ。　ここが最初に処理されます。
		 * ----------------------------------------------------- */
		public function Main():void 
		{	
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.INIT, initHandler);
			loader.load(new URLRequest("http://assets.wonderfl.net/images/related_images/a/af/affb/affbae7b9d9ae1f2a19c182ef6584acecbfb833a"), new LoaderContext(true));
		}
		
		private function initHandler(event:Event):void
		{
			var loader:Loader = event.currentTarget.loader;
			image = new BitmapData(loader.width, loader.height, false);
			image.draw(loader);
			
			mapData = Map.init(MAPSIZE, MAPSIZE);
			
			prgSpr = new Sprite();//ロード画面
			addChild(prgSpr);
			
			createMap();			//マップを作る
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);//イベントリスナーの登録
			
			yuusha = new Yuusha();	//勇者を作る
			yuusha.scaleX = yuusha.scaleY = SCALE;	//勇者を拡大表示
			yuusha.x = yuusha.y = (SIZE-FLDSIZE)/2; //中央に配置
			
			var points:Array = new Array();
			for (var y:int = 0; y < MAPSIZE; y++)
			{
				for (var x:int = 0; x < MAPSIZE; x++)
				{
					if (mapData[y][x] != Status.WALL) points.push(new Point(x, y)); 
				}
			}
			points = Random.shake(points);
			yuushaPos = new Point(points[0].x * FLDSIZE, points[0].y * FLDSIZE);//勇者初期位置
			moveMap(yuushaPos);		//マップ移動
		}
		
		/**-----------------------------------------------------
		 * 毎フレームの処理。
		 * ----------------------------------------------------- */
		private function onEnterFrame(event:Event):void {
			
			//画像読み込み完了後　1回だけ処理
			if (!isInit) {
				removeChild(prgSpr);//ロード画面非表示
				prgSpr = null;
				stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);	//イベントリスナーの登録
				stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);		//イベントリスナーの登録
				addChild(map);		//マップ表示
				addChild(yuusha);	//勇者表示
				isInit = true;
				
				var matrix:Matrix = new Matrix();
				matrix.createGradientBox(140, 140, 0, -70, -70);
				
				circle = new Sprite();
				circle.graphics.beginGradientFill("radial", [0xFFFFFF, 0x0], [0.0, 0.5], [0, 255], matrix);
				circle.graphics.drawCircle(0, 0, 70);
				circle.graphics.endFill();
				
				matrix = new Matrix();
				matrix.translate(232, 232);
				
				bd = new BitmapData(465, 465, true, 0x0);
				dark = new Bitmap(bd);
				dark.alpha = 0.0;
				bd.draw(circle, matrix);
				bd.threshold(bd, bd.rect, new Point(), "==", 0x0, 0x7F000000, 0xFFFFFF);
				addChild(dark);
				
				bd = new BitmapData(MAPSIZE, MAPSIZE, true, 0x0);
				bitmap = new Bitmap(bd);
				bitmap.scaleX = bitmap.scaleY = SCALE2;
				bitmap.x = (465 - bitmap.width) / 2;
				bitmap.y = (465 - bitmap.height) / 2;
				addChild(bitmap);
				
				circle = new Sprite();
				circle.graphics.beginFill(0xFFFFFF);
				circle.graphics.drawCircle(4, 4, 4);
				circle.graphics.endFill();
				addChild(circle);
			}
			
			if (bitmap)
			{
				circle.x = bitmap.x + yuushaPos.x / 9;
				circle.y = bitmap.y + yuushaPos.y / 9;
			}
			
			var px:int = (circle.x - bitmap.x) / SCALE2;
			var py:int = (circle.y - bitmap.y) / SCALE2;
			
			if (mapData[py][px] == Status.ROOM)
			{
				dark.alpha = 0.0;
				if (bd.getPixel(px, py) == 0x0)
				{
					fill(py, px);
				}
			}
			else
			{
				dark.alpha = 1.0;
				bd.setPixel32(px, py, 0x44FFFFFF);
			}
			
			//15フレーム毎に処理する
			if (frameCount++ > 10) {
				frameCount = 0;
				yuusha.walk();
			}
			
			//マップ（勇者）をどの方向に動かすか判定
			if (yuushaPos.x % FLDSIZE == 0 && yuushaPos.y % FLDSIZE == 0) {
				var mapPosX:int = int(yuushaPos.x / FLDSIZE), mapPosY:int = int(yuushaPos.y / FLDSIZE);
				walkDirection = 4; 		//止まる
				switch(true) {
					case keyFlags[0]:	//下
						if(yuushaPos.y < (MAPSIZE-1)*FLDSIZE && !bMapData[mapPosY+1][mapPosX]) walkDirection=0;
						yuusha.changeDirection(0);
						break;
					case keyFlags[1]:	//上
						if(yuushaPos.y > 0 && !bMapData[mapPosY-1][mapPosX]) walkDirection=1;
						yuusha.changeDirection(1);
						break;
					case keyFlags[2]:	//左
						if(yuushaPos.x > 0 && !bMapData[mapPosY][mapPosX-1]) walkDirection=2;
						yuusha.changeDirection(2);
						break;
					case keyFlags[3]:	//右
						if(yuushaPos.x < (MAPSIZE-1)*FLDSIZE && !bMapData[mapPosY][mapPosX+1]) walkDirection=3;
						yuusha.changeDirection(3);
						break;
				}
			}
			
			//次のマスまで自動的に勇者を歩かせる
			switch(walkDirection) {
				case 0:
					yuushaPos.y += SPEED;
					break;
				case 1:
					yuushaPos.y -= SPEED;
					break;
				case 2:
					yuushaPos.x -= SPEED;
					break;
				case 3:
					yuushaPos.x += SPEED;
					break;
			}
			if (walkDirection < 4) moveMap(yuushaPos);
		}
		
		/**-----------------------------------------------------
		 * キーボードのキーが押された時の処理。
		 * ----------------------------------------------------- */
		private function onKeyDown(event:KeyboardEvent):void {
			switch(event.keyCode) {
				case 40: case 83:	//↓ s
					keyFlags[0] = true;
			}
			switch(event.keyCode) {
				case 38: case 87:	//↑ w
					keyFlags[1] = true;
			}
			switch(event.keyCode) {
				case 37: case 65:	//← a
					keyFlags[2] = true;
			}
			switch(event.keyCode) {
				case 39: case 68:	//→ d
					keyFlags[3] = true;
			}
		}
		
		/**-----------------------------------------------------
		 * キーボードのキーが離された時の処理。
		 * ----------------------------------------------------- */
		private function onKeyUp(event:KeyboardEvent):void {
			switch(event.keyCode) {
				case 40: case 83:	//↓ s
					keyFlags[0] = false;
			}
			switch(event.keyCode) {
				case 38: case 87:	//↑ w
					keyFlags[1] = false;
			}
			switch(event.keyCode) {
				case 37: case 65:	//← a
					keyFlags[2] = false;
			}
			switch(event.keyCode) {
				case 39: case 68:	//→ d
					keyFlags[3] = false;
			}
		}
		
		/**-----------------------------------------------------
		 * マップを作ります。
		 * ----------------------------------------------------- */
		private function createMap():void {
			map = new Sprite();
			for (var k:uint = 0; k < MAPSIZE; k++) bMapData[k] = []; //bMapDataを2次元配列にする
			
			var bd:BitmapData = new BitmapData(MAPSIZE * FLDSIZE, MAPSIZE * FLDSIZE);
			var bitmap:Bitmap = new Bitmap(bd);
			
			for (var j:uint = 0; j < MAPSIZE; j++) {
				for (var i:uint = 0; i < MAPSIZE; i++) {
					var field:Field = fieldList[mapData[j][i]];
					
					if (field.isObstacle) bd.copyPixels(image, new Rectangle(field.x, field.y, 32, 32), new Point(32 * i, 32 * j));
					else bd.copyPixels(image, new Rectangle(field.x, (Math.random() < 0.1) ? field.y + 32 : field.y, 32, 32), new Point(32 * i, 32 * j));
					bMapData[j][i] = field.isObstacle;
				}
			}
			bitmap.scaleX = bitmap.scaleY = FLDSIZE / 32;
			map.addChild(bitmap);
		}
		
		/**-----------------------------------------------------
		 * マップの座標計算。
		 * ----------------------------------------------------- */
		private function moveMap(pos:Point):void {
			map.x = (SIZE-FLDSIZE)/2 - yuushaPos.x;
			map.y = (SIZE-FLDSIZE)/2 - yuushaPos.y;
		}
		
		/**-----------------------------------------------------
		 * ロード画面を描く。
		 * ----------------------------------------------------- */
		private function drawPrg():void {
			var side:Number = SIZE / MAPSIZE,
				yy:int = int(loaded / MAPSIZE),
				xx:int = loaded - yy * MAPSIZE,
				max:int = MAPSIZE;
			prgSpr.graphics.clear();
			prgSpr.graphics.beginFill(0xFFFFFF);
			prgSpr.graphics.drawRect(0, 0, SIZE, yy * side);
			if(yy%2)prgSpr.graphics.drawRect((MAPSIZE-xx)*side, yy*side, SIZE, side);
			else	prgSpr.graphics.drawRect(0, yy*side, xx*side, side);
			prgSpr.graphics.endFill();
		}
		
		private function fill(py:int, px:int):void
		{
			bd.setPixel32(px, py, 0x44FFFFFF);
			
			if (mapData[py][px] == Status.CORRIDOR) return;
			
			if (0 <= px - 1 && mapData[py][px - 1] != Status.WALL && bd.getPixel(px - 1, py) == 0x0 && mapData[py][px - 1] != Status.WALL) fill(py, px - 1);
			if (px + 1 < MAPSIZE && mapData[py][px + 1] != Status.WALL && bd.getPixel(px + 1, py) == 0x0 && mapData[py][px + 1] != Status.WALL) fill(py, px + 1);
			if (0 <= py - 1 && mapData[py - 1][px] != Status.WALL && bd.getPixel(px, py - 1) == 0x0 && mapData[py - 1][px] != Status.WALL) fill(py - 1, px);
			if (py + 1 < MAPSIZE && mapData[py + 1][px] != Status.WALL && bd.getPixel(px, py + 1) == 0x0 && mapData[py + 1][px] != Status.WALL) fill(py + 1, px);
		}
	}
}

import flash.display.Sprite;
import flash.display.Loader;
import flash.net.URLRequest;
import flash.system.LoaderContext;

class Status
{
	public static const WALL:int = 0;
	public static const ROOM:int = 1;
	public static const CORRIDOR:int = 2;
}

/**-----------------------------------------------------
 * 勇者クラスです。勇者を作ったり、足踏させたり、向きを変えたりします。
 * ----------------------------------------------------- */
class Yuusha  extends Sprite {
	public var direction:int = 0;		//向き　（0:前　1：後　2：左　3：右）
	private var walkFlag:Boolean = true;//足踏み用
	private var yuushaImages:Array = [];//勇者の画像集
	
	/**-----------------------------------------------------
	 * コンストラクタ。
	 * ----------------------------------------------------- */
	public function Yuusha():void {
		for (var i:uint = 0; i < 8; i++) {
			var loader:Loader = new Loader();
			loader.load(new URLRequest(ImageURL[i]), new LoaderContext(true));
			yuushaImages.push(loader);
			if(i) yuushaImages[i].visible = false;
			addChild(yuushaImages[i]);
		}
	}
	
	/**-----------------------------------------------------
	 * 勇者の画像のURLリスト
	 * ----------------------------------------------------- */
	private const ImageURL:Array = [
		"http://flash-scope.com/wonderfl/WonderflQuest/yuusha/yuushaF1.png",	//前向き1
		"http://flash-scope.com/wonderfl/WonderflQuest/yuusha/yuushaF2.png",	//前向き2
		"http://flash-scope.com/wonderfl/WonderflQuest/yuusha/yuushaB1.png",	//後ろ向き1
		"http://flash-scope.com/wonderfl/WonderflQuest/yuusha/yuushaB2.png",	//後ろ向き2
		"http://flash-scope.com/wonderfl/WonderflQuest/yuusha/yuushaL1.png",	//左向き1
		"http://flash-scope.com/wonderfl/WonderflQuest/yuusha/yuushaL2.png",	//左向き2
		"http://flash-scope.com/wonderfl/WonderflQuest/yuusha/yuushaR1.png",	//右向き1
		"http://flash-scope.com/wonderfl/WonderflQuest/yuusha/yuushaR2.png"		//右向き2
	];
	
	/**-----------------------------------------------------
	 * 足踏みさせます。
	 * ----------------------------------------------------- */
	public function walk():void {
		walkFlag = !walkFlag;
		for (var i:uint = 0; i < 8; i++) {
			if (i == 2*direction+int(walkFlag)) yuushaImages[i].visible = true;
			else yuushaImages[i].visible = false;
		}
	}
	
	/**-----------------------------------------------------
	 * 向きを変更します。
	 * numは勇者の向きを表します。（0～3）
	 * ----------------------------------------------------- */
	public function changeDirection(num:int):void {
		direction = num;
		for (var i:uint = 0; i < 8; i++) {
			if (i == 2*direction+int(walkFlag)) yuushaImages[i].visible = true;
			else yuushaImages[i].visible = false;
		}
	}
}

/**-----------------------------------------------------
 * Fieldクラスです。画像のURLと、そのフィールドが障害物か否かを保存します。
 * ----------------------------------------------------- */
class Field {
	public var x:int;
	public var y:int;
	public var isObstacle:Boolean;	//障害物か否か （true:障害物　　false:障害物じゃない（歩ける））
	
	public function Field(x:int, y:int, b:Boolean = false):void {
		this.x = x;
		this.y = y;
		isObstacle = b;
	}
}

class Map
{
	private static var WIDTH:int;
	private static var HEIGHT:int;
	private static const MARGIN:int = 8;
	
	private static var dungeon:Array;
	
	public static function init(width:int, height:int):Array
	{
		WIDTH = width;
		HEIGHT = height;
		
		dungeon = new Array(HEIGHT).map(function(...a):* { return new Array(WIDTH).map(function(...a):* { return Status.WALL; } ) } );
		
		var partitions:Array = split(new Rect(0, 0, WIDTH - 1, HEIGHT - 1));
		var rooms:Array = partitions.map(makeRoom);
		makeCorridor(partitions, rooms);
		rooms.map(fill);
		
		return dungeon;
	}
	
	// Math.floor(value / 2)
	private static function half(value:int):int
	{
		return value >> 1;
	}
	
	// 領域の中から適当に部屋を作る
	private static function makeRoom(src:Rect, ...a):Rect
	{
		var dest:Rect = new Rect();
		dest.left 	= src.left 	 + randomRange(2, half(src.right  - src.left) - 0); // -1
		dest.top 	= src.top 	 + randomRange(2, half(src.bottom - src.top)  - 0);
		dest.right  = src.right  - randomRange(2, half(src.right  - src.left) - 0);
		dest.bottom = src.bottom - randomRange(2, half(src.bottom - src.top)  - 0);
		
		return dest;
	}
	
	// min以上、max未満のランダム値を生成
	private static function randomRange(min:int, max:int):int
	{
		if (min > max) throw new Error("min = " + min + " : max = " + max);
		else if (min == max) return min;
		else
		{
			var value:int = Math.floor(Math.random() * (max - min)) + min;
			return value;
		}
	}
	
	// 塗る。部屋、通路用
	private static function fill(rect:Rect, i:int = -1, array:Array = null):void
	{
		var minY:int = Math.min(rect.top, rect.bottom);
		var maxY:int = Math.max(rect.top, rect.bottom);
		
		var minX:int = Math.min(rect.left, rect.right);
		var maxX:int = Math.max(rect.left, rect.right);
		
		for (var y:int = minY; y <= maxY; y++)
		{
			for (var x:int = minX; x <= maxX; x++)
			{
				if (i != -1) dungeon[y][x] = Status.ROOM;
				else dungeon[y][x] = Status.CORRIDOR;
			}
		}
	}
	
	// 多次元配列を一次元配列に
	private static function flatten(array:Array):Array
	{
		var src:Array = array.slice(); 	// 渡された配列のコピー
		var dest:Array = new Array();	// フラットにした返却用配列
	 
		while (true)
		{
			var element:* = src.shift(); // 配列から一つだけ値を取り出す
	 
			if (element == undefined) break; //　もう配列には要素が無いので終了 
			else if (element is Array) src = src.concat(element); // 要素が配列なら、要素 + srcという形に変換する
			else dest.push(element); // 要素が配列以外なら返却用配列に追加
		}
	 
		return dest;
	}
	
	// 通路作成
	private static function makeCorridor(partitions:Array, rooms:Array):void
	{
		var list:Array = new Array();
		
		// 各部屋のペア
		for (var i:int = 0; i < partitions.length - 1; i++)
		{
			list.push([i, i + 1]);
		}
		
		// 一本道にならないように
		for (i = 0; i < partitions.length; i++)
		{
			for (var j:int = i + 1; j < partitions.length; j++)
			{
				if (randomRange(0, 4) == 0)
				{
					if (partitions[i].left == partitions[j].right ||
						partitions[i].right == partitions[j].left ||
						partitions[i].top == partitions[j].bottom ||
						partitions[i].bottom == partitions[j].top)
					{
						list.push([i, j]);
					}
				}
			}
		}
		
		list.forEach
		(
			function(i:Array, ...a):void
			{
				connect(partitions[i[0]], partitions[i[1]], rooms[i[0]], rooms[i[1]]);
			}
		);
	}
	
	// 部屋と部屋を繋げる
	private static function connect(p0:Rect, p1:Rect, r0:Rect, r1:Rect):void
	{
		var a:int;
		var b:int;
		
		// 枠Aの下側と枠Bの上側が同じ位置だったら横に分割した事になる
		if (p0.bottom == p1.top)
		{
			// 部屋のどこから通路を出すかを決める
			a = randomRange(r0.left, r0.right);
			b = randomRange(r1.left, r1.right);
			
			fill(new Rect(a, half(p0.top + p0.bottom), a, p0.bottom));
			fill(new Rect(b, half(p1.top + p1.bottom), b, p1.top));
			fill(new Rect(a, p0.bottom, b, p0.bottom));
		}
		// 縦に分割している場合の処理
		else
		{
			// 部屋のどこから通路を出すかを決める
			a = randomRange(r0.top, r0.bottom);
			b = randomRange(r1.top, r1.bottom);
			
			fill(new Rect(half(p0.left + p0.right), a, p0.right, a));
			fill(new Rect(half(p1.left + p1.right), b, p1.left, b));
			fill(new Rect(p0.right, a, p0.right, b));
		}
	}
	
	//　領域分割
	private static function split(rect:Rect, ...a):Array
	{
		if ((rect.right  - rect.left < MARGIN * 2) ||
			(rect.bottom - rect.top < MARGIN * 2))
		{
			return [rect];
		}
		else
		{
			var rectA:Rect;
			var rectB:Rect;
			
			// 1/2の確率で横か縦に分割
			if (randomRange(0, 2) == 0)
			{
				// 横に分割
				
				var height:int = randomRange(rect.top + MARGIN, rect.bottom - MARGIN);
				
				rectA = new Rect(rect.left, rect.top, rect.right, height);
				rectB = new Rect(rect.left, height, rect.right, rect.bottom);
			}
			else
			{
				// 縦に分割
				
				var width:int = randomRange(rect.left + MARGIN, rect.right - MARGIN);
				
				rectA = new Rect(rect.left, rect.top, width, rect.bottom);
				rectB = new Rect(width, rect.top, rect.right, rect.bottom);
			}
			
			return flatten([rectA, rectB].map(split));
		}
	}
}

// 標準で付いてるRectangleだとコンストラクタで右下のPointが指定できないから使いづらい
class Rect
{
	public var left:int;
	public var right:int;
	public var top:int;
	public var bottom:int;
	
	public function Rect(left:int = 0, top:int = 0, right:int = 0, bottom:int = 0):void
	{
		this.left = left;
		this.top = top;
		this.right = right;
		this.bottom = bottom;
	}
}
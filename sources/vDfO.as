////////////////////////////////////////////////////////////////////////////////
// リバーシ for AS3.0 (1)
// http://www.project-nya.jp/modules/weblog/details.php?blog_id=1039
// Enterキー・上下左右キーで操作してください。
//
// special thanks to QURAGE
// http://qurage.net/labo/fl1/data/reversi.html
////////////////////////////////////////////////////////////////////////////////

package {

	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.geom.Matrix;
	import flash.display.GradientType;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.AntiAliasType;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.filters.DropShadowFilter;

	[SWF(backgroundColor="#FFFFFF", width="465", height="465", frameRate="30")]

	public class Main extends Sprite {
		private static var color1:uint = 0x3F68AB;
		private static var color2:uint = 0x77B2EE;
		private static var tColor:uint = 0xFFFFFF;
		private static var sColor:uint = 0x00000;
		private static var fontType:String = "_ゴシック";

		public function Main() {
			//Wonderfl.capture_delay(10);
			init();
		}

		private function init():void {
			draw(465, 465);
			var game:Game = new Game();
			addChild(game);
			game.x = 42;
			game.y = 12;
		}
		private function draw(w:uint, h:uint):void {
			var colors:Array = [color1, color2];
			var alphas:Array = [1, 1];
			var ratios:Array = [0, 255];
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(w, h, 1.25*Math.PI, 0, 0);
			graphics.beginGradientFill(GradientType.LINEAR, colors, alphas, ratios, matrix);
			graphics.drawRect(0, 0, w, h);
			graphics.endFill();
			var tf:TextFormat = new TextFormat();
			tf.font = fontType;
			tf.size = 32;
			tf.align = TextFormatAlign.LEFT;
			var title:TextField = new TextField();
			addChild(title);
			title.x = 20;
			title.y = 3;
			title.width = 120;
			title.height = 40;
			title.type = TextFieldType.DYNAMIC;
			title.selectable = false;
			//title.embedFonts = true;
			//title.antiAliasType = AntiAliasType.ADVANCED;
			title.defaultTextFormat = tf;
			title.textColor = tColor;
			title.text = "Reversi";
			var shade:DropShadowFilter = new DropShadowFilter(1, 90, sColor, 0.4, 4, 4, 2, 2, false, false);
			title.filters = [shade];
		}

	}

}


//////////////////////////////////////////////////
//	リバーシ全体を管理するクラス
//////////////////////////////////////////////////

import flash.display.Sprite;

class Game extends Sprite {
	private static var pieces:uint = 8;
	private var board:Board;
	private var score:Score;
	private var help:Help;
	public static const INIT:String = "init";
	public static const PLAY:String = "play";
	public static const PUT:String = "put";
	public static const FINISH:String = "finish";
	public static const NO_POINT:String = "noPoint";
	public static const READY:String = "ready";
	public static const RESET:String = "reset";
	public static const NO_HELP:String = "";
	public static const MOVE:String = "move";
	public static const SELECT:String = "select";
	public static const PUT_COMPLETE:String = "putComplete";
	public static const TURN_COMPLETE:String = "turnComplete";

	public function Game() {
		init();
	}

	private function init():void {
		board = new Board();
		score = new Score();
		help = new Help();
		addChild(board);
		board.x = 22;
		board.y = 88;
		addChild(score);
		addChild(help);
		help.x = 194;
		help.y = 245;
		board.init(score, help);
	}

}


//////////////////////////////////////////////////
//	盤面を管理するクラス
//////////////////////////////////////////////////

import flash.display.Sprite;
import flash.display.Shape;
import flash.events.Event;
import flash.utils.Timer;
import flash.events.TimerEvent;
import flash.net.navigateToURL;
import flash.net.URLRequest;
import flash.events.MouseEvent;
import flash.utils.escapeMultiByte;

class Board extends Sprite {
	private var mode:String;
	private var player:uint = 0;
	private var map:Map;
	private var score:Score;
	private var help:Help;
	private var manager:Manager;
	private var cursor:Cursor;
	private static var pieces:uint = 8;
	private static var bColor:uint = 0x336600;
	private var pointList:Array;
	private var pieceList:Array;
	private static var pid:uint = 0;
	private var completed:uint = 0;
	private static var initTime:uint = 500;
	private static var startTime:uint = 1000;
	private static var cpuTime:uint = 500;
	private static var finishTime:uint = 1000;
	private static var resetTime:uint = 500;
	private var cpu:Object;
	private var turns:uint;
	private var passed1:Boolean = false;
	private var passed2:Boolean = false;
	//サウンド
	private var seready:SoundEffect;
	private var seput:SoundEffect;
	private var seturn:SoundEffect;
	private var sefanfare:SoundEffect;
	private var seclaps:SoundEffect;
	private var sefailure:SoundEffect;
	private var source1:String = "http://www.project-nya.jp/images/flash/reversi/ready.mp3";
	private var source2:String = "http://www.project-nya.jp/images/flash/reversi/put.mp3";
	private var source3:String = "http://www.project-nya.jp/images/flash/reversi/turn.mp3";
	private var source4:String = "http://www.project-nya.jp/images/flash/reversi/fanfare.mp3";
	private var source5:String = "http://www.project-nya.jp/images/flash/reversi/claps.mp3";
	private var source6:String = "http://www.project-nya.jp/images/flash/reversi/failure.mp3";
	//twitter
	private var twitterBtn:Btn;
	private static var twitterPath:String = "http://twitter.com/home/?status=";
	private var msgs:Array = new Array();
	private var result:String;
	private static var tag:String = " http://wonderfl.net/c/vDfO"


	public function Board() {
		draw();
		seready = new SoundEffect();
		seput = new SoundEffect();
		seturn = new SoundEffect();
		sefanfare = new SoundEffect();
		seclaps = new SoundEffect();
		sefailure = new SoundEffect();
	}

	public function init(s:Score, h:Help):void {
		score = s;
		help = h;
		seready.load(source1, "ready");
		seput.load(source2, "put");
		seturn.load(source3, "turn");
		sefanfare.load(source4, "fanfare");
		seclaps.load(source5, "claps");
		sefailure.load(source6, "failure");
		reset(null);
	}
	//カーソル位置にコマを配置する(キー設定)
	private function initialize():void {
		manager = new Manager(this);
		addChild(manager);
		manager.addEventListener(Game.READY, readySelect, false, 0, true);
		manager.addEventListener(Game.MOVE, moveCursor, false, 0, true);
		manager.addEventListener(Game.SELECT, selectCursor, false, 0, true);
		manager.addEventListener(Game.RESET, resetSelect, false, 0, true);
		manager.enable = false;
		cpu = new Object();
	}
	private function reset(evt:TimerEvent):void {
		if (evt) evt.target.removeEventListener(TimerEvent.TIMER_COMPLETE, reset);
		initialize();
		map = new Map();
		score.init();
		mode = Game.INIT;
		score.showMessage(mode);
		help.show("ready?");
		score.resetTime();
		seready.play("ready", 1);
		manager.help = Game.READY;
		if (pieceList) clearPieces();
		pieceList = new Array();
	}
	private function readySelect(evt:Event):void {
		manager.help = Game.NO_HELP;
		var timer:Timer = new Timer(initTime, 1);
		timer.addEventListener(TimerEvent.TIMER_COMPLETE, start, false, 0, true);
		timer.start();
		help.hide();
	}
	private function start(evt:TimerEvent):void {
		evt.target.removeEventListener(TimerEvent.TIMER_COMPLETE, start);
		score.startTime();
		putPiece(1, 3, 3);
		putPiece(2, 3, 4);
		putPiece(1, 4, 4);
		putPiece(2, 4, 3);
	}
	//盤面にコマを配置する
	private function put(px:uint, py:uint):void {
		if (map.getPoint(px, py)) {
			if (map.getHint(px, py)) {
				switch (player) {
				case 1 :
					putPiece(player, px, py);
					break;
				case 2 :
					cpuPiece(player, px, py);
					var timer:Timer = new Timer(cpuTime, 1);
					timer.addEventListener(TimerEvent.TIMER_COMPLETE, cpuPut, false, 0, true);
					timer.start();
					break;
				}
			} else {
				score.showMessage(Game.NO_POINT);
			}
		} else {
			score.showMessage(Game.NO_POINT);
		}
	}
	//盤面にコマを配置する(配置可能なマスに)
	private function putPiece(p:uint, px:uint, py:uint):void {
		//trace("[#"+player+"] ("+px+", "+py+")");
		var point:Point = pointList[px+py*pieces];
		var xPos:uint = point.x;
		var yPos:uint = point.y;
		var id:uint = px+py*pieces;
		var piece:Piece = new Piece();
		addChild(piece);
		piece.id = id;
		piece.px = px;
		piece.py = py;
		piece.x = xPos;
		piece.y = yPos;
		pieceList[id] = piece;
		piece.addEventListener(Game.PUT_COMPLETE, putComplete, false, 0, true);
		piece.addEventListener(Game.TURN_COMPLETE, turnComplete, false, 0, true);
		piece.put(p);
		score.put(p);
		map.put(p, px, py);
		seput.play("put", 1);
		hideHint();
		pid ++;
		manager.enable = false;
	}
	private function cpuPiece(p:uint, px:uint, py:uint):void {
		cpu = {p: p, px: px, py: py};
	}
	private function cpuPut(evt:TimerEvent):void {
		evt.target.removeEventListener(TimerEvent.TIMER_COMPLETE, cpuPut);
		putPiece(cpu.p, cpu.px, cpu.py);
	}
	private function clearPieces():void {
		for (var px:uint = 0; px < pieces; px++) {
			for (var py:uint = 0; py < pieces; py++) {
				var piece:Piece = pieceList[px+py*pieces];
				if (piece) removeChild(piece);
				piece = null;
			}
		}
		pid = 0;
	}
	//コマ配置後の処理
	private function putComplete(evt:Event):void {
		switch (mode) {
			case Game.INIT :
				completed ++;
				if (completed == 4) {
					completed = 0;
					mode = Game.PLAY;
					score.showMessage(mode);
					player = 2;
					var timer:Timer = new Timer(startTime, 1);
					timer.addEventListener(TimerEvent.TIMER_COMPLETE, prepare, false, 0, true);
					timer.start();
				}
				break;
			case Game.PLAY :
				turn(evt.target.px, evt.target.py);
				break;
		}
	}
	//反転するコマ情報を取得する
	private function turn(px:uint, py:uint):void {
		var list:Array = map.getTurnList(player, px, py);
		turns = list.length;
		if (turns > 0) {
			turnPieces(player, list);
			seturn.play("turn", 1);
		}
	}
	//コマを反転する
	private function turnPieces(p:uint, list:Array):void {
		for (var n:uint = 0; n < list.length; n++) {
			var tx:uint = list[n].x;
			var ty:uint = list[n].y;
			var piece:Piece = pieceList[tx+ty*pieces];
			piece.turn();
			score.turn(p);
			map.put(p, tx, ty);
		}
	}
	//コマ反転後の処理
	private function turnComplete(evt:Event):void {
		completed ++;
		if (completed == turns) {
			completed = 0;
			if (pid < pieces*pieces) {
				prepare(null);
			} else {
				finish();
			}
		}
	}
	//攻守交代
	private function prepare(evt:TimerEvent):void {
		if (evt) evt.target.removeEventListener(TimerEvent.TIMER_COMPLETE, prepare);
		player = player%2 + 1;
		switch (player) {
			case 1 :
				score.showMessage(Game.PUT, player, passed2);
				map.getBestPrio(player);
				if (showHint()) {
					if (!cursor) {
						cursor = new Cursor();
						addChild(cursor);
						setCursor(4, 4);
						manager.setCursor(4, 4);
					}
					manager.enable = true;
					passed1 = false;
				} else {
					passed1 = true;
				}
				break;
			case 2 :
				score.showMessage(Game.PUT, player, passed1);
				var best:Object = map.getBestPrio(player);
				if (!isNaN(best.x) && !isNaN(best.y)) {
					manager.autoCursor(best.x, best.y);
					passed2 = false;
				} else {
					passed2 = true;
				}
				break;
		}
		if (passed1 && passed2) {
			finish();
		} else if ((player == 1 && passed1) || (player == 2 && passed2)) {
			prepare(null);
		}
	}
	private function moveCursor(evt:Event):void {
		setCursor(evt.target.cx, evt.target.cy);
	}
	private function selectCursor(evt:Event):void {
		put(evt.target.cx, evt.target.cy);
	}
	//盤面にカーソルを配置する
	private function setCursor(cx:uint, cy:uint):void {
		var point:Point = pointList[cx+cy*pieces];
		var xPos:uint = point.x;
		var yPos:uint = point.y;
		cursor.x = xPos;
		cursor.y = yPos;
	}
	//ヒントを表示する
	private function showHint():Boolean {
		var hint:uint = 0;
		for (var px:uint = 0; px < pieces; px++) {
			for (var py:uint = 0; py < pieces; py++) {
				var point:Point = pointList[px+py*pieces];
				if (map.getHint(px, py)) {
					hint ++;
					point.hint();
				} else {
					point.init();
				}
			}
		}
		if (hint > 0) {
			return true;
		} else {
			return false;
		}
	}
	//ヒントを非表示にする
	private function hideHint():void {
		for (var px:uint = 0; px < pieces; px++) {
			for (var py:uint = 0; py < pieces; py++) {
				var point:Point = pointList[px+py*pieces];
				point.init();
			}
		}
	}
	//ゲーム終了の処理
	private function finish():void {
		mode = Game.FINISH;
		score.showMessage(mode);
		var timer:Timer = new Timer(finishTime, 1);
		timer.addEventListener(TimerEvent.TIMER_COMPLETE, showHelp, false, 0, true);
		timer.start();
		score.stopTime();
		player = 0;
		passed1 = false;
		passed2 = false;
	}
	private function showHelp(evt:TimerEvent):void {
		evt.target.removeEventListener(TimerEvent.TIMER_COMPLETE, showHelp);
		var scr:Array = score.getScore();
		var p1:uint = scr[0];
		var p2:uint = scr[1];
		//twitter
		result = String(p1) + ":" + String(p2);
		if (p1 > p2) {
			help.show("You win!");
			sefanfare.play("fanfare", 1);
			msgs = ["コンピュータに ", " で勝ったよ！"];
		} else if (p1 == p2) {
			help.show("draw");
			seclaps.play("claps", 1);
			msgs = ["コンピュータと ", " の引き分けでした。"];
		} else {
			help.show("You lose");
			sefailure.play("failure", 1);
			msgs = ["コンピュータに ", " で負けました..."];
		}
		removeChild(cursor);
		cursor = null;
		manager.help = Game.RESET;
	}
	private function resetSelect(evt:Event):void {
		manager.help = Game.NO_HELP;
		var timer:Timer = new Timer(resetTime, 1);
		timer.addEventListener(TimerEvent.TIMER_COMPLETE, reset, false, 0, true);
		timer.start();
		help.hide();
	}
	private function draw():void {
		graphics.beginFill(bColor);
		graphics.drawRect(-2, -2, 340, 340);
		graphics.endFill();
		pointList = new Array();
		for (var px:uint = 0; px < pieces; px++) {
			for (var py:uint = 0; py < pieces; py++) {
				var point:Point = new Point();
				addChild(point);
				var id:uint = px+py*pieces;
				point.id = id;
				pointList[id] = point;
				point.x = 21 + 42*px;
				point.y = 21 + 42*py;
				point.init();
			}
		}
		for (var cx:uint = 0; cx < 2; cx++) {
			for (var cy:uint = 0; cy < 2; cy++) {
				var corner:Shape = new Shape();
				addChild(corner);
				corner.graphics.beginFill(bColor);
				corner.graphics.drawCircle(0, 0, 4);
				corner.graphics.endFill();
				corner.x = 84 + 168*cx;
				corner.y = 84 + 168*cy;
			}
		}
		//twitter
		twitterBtn = new Btn();
		addChild(twitterBtn);
		twitterBtn.x = 365;
		twitterBtn.y = 350;
		twitterBtn.init({label: "twitter"});
		twitterBtn.addEventListener(MouseEvent.CLICK, twitter, false, 0, true);
	}
	//twitter対応
	private function twitter(evt:MouseEvent):void {
		var msg:String = "";
		switch (mode) {
			case Game.INIT :
				msg = "ゲームを開始します。";
				break;
			case Game.PLAY :
				msg = "ゲーム中です。";
				break;
			case Game.FINISH :
				msg = msgs[0] + result + msgs[1];
				break;
		}
		navigateToURL(new URLRequest(twitterPath + escapeMultiByte(msg + tag)), "_blank");			
	}

}


//////////////////////////////////////////////////
//	盤面上のコマの位置を管理するクラス
//////////////////////////////////////////////////

class Map {
	private static var pieces:uint = 8;
	//空マップ
	private var aMap:Array;
	//盤面上のコマ配置マップ
	private var bMap:Array;
	//優先度マップ
	private var pMap:Array;
	//走査マップ
	private var cMap:Array;
	//ヒント表示マップ
	private var hMap:Array;

	public function Map() {
		init();
	}

	private function init():void {
		aMap = new Array();
		aMap.push([0, 0, 0, 0, 0, 0, 0, 0]);
		aMap.push([0, 0, 0, 0, 0, 0, 0, 0]);
		aMap.push([0, 0, 0, 0, 0, 0, 0, 0]);
		aMap.push([0, 0, 0, 0, 0, 0, 0, 0]);
		aMap.push([0, 0, 0, 0, 0, 0, 0, 0]);
		aMap.push([0, 0, 0, 0, 0, 0, 0, 0]);
		aMap.push([0, 0, 0, 0, 0, 0, 0, 0]);
		aMap.push([0, 0, 0, 0, 0, 0, 0, 0]);
		bMap = copyMap(aMap);
		cMap = copyMap(aMap);
		pMap = new Array();
		pMap.push([7, 0, 5, 6, 6, 5, 0, 7]);
		pMap.push([0, 0, 2, 3, 3, 2, 0, 0]);
		pMap.push([5, 2, 5, 4, 4, 5, 2, 5]);
		pMap.push([6, 3, 4, 4 ,4, 4, 3, 6]);
		pMap.push([6, 3, 4, 4 ,4, 4, 3, 6]);
		pMap.push([5, 2, 5, 4, 4, 5, 2, 5]);
		pMap.push([0, 0, 2, 3, 3, 2, 0, 0]);
		pMap.push([7, 0, 5, 6, 6, 5, 0, 7]);
	}
	private function copyMap(list:Array):Array {
		var map:Array = new Array();
		for (var n:uint = 0; n < list.length; n++) {
			map[n] = list[n].concat();
		}
		return map;
	}
	//コマの配置をマップに設定する
	public function put(p:uint, x:uint, y:uint):void {
		bMap[y][x] = p;
		cMap[y][x] = p;
		for (var cx:int = x-1; cx <= x+1; cx++) {
			for (var cy:int = y-1; cy <= y+1; cy++) {
				if (cx >= 0 && cx < pieces && cy >= 0 && cy < pieces) {
					var player:Object = bMap[cy][cx];
					player = (player == 0) ? "*" : player;
					cMap[cy][cx] = player;
				}
			}
		}
	}
	//配置可能なマスかどうかを判定する
	public function getPoint(x:uint, y:uint):Boolean {
		if (bMap[y][x] == 0) {
			return true;
		} else {
			return false;
		}
	}
	//走査対象のコマかどうかを判定する
	private function getCheck(x:uint, y:uint):Boolean {
		var check:Object = cMap[y][x];
		if (check == "*") {
			return true;
		} else {
			return false;
		}
	}
	//ヒント表示するコマかどうかを判定する
	public function getHint(x:uint, y:uint):Boolean {
		var hint:Object = hMap[y][x];
		if (hint == "*") {
			return true;
		} else {
			return false;
		}
	}
	//優先順位の高いマスを取得する({x: 0, y: 0}で返す)
	public function getBestPrio(p:uint):Object {
		var px:Number = undefined;
		var py:Number = undefined;
		var best:uint = 0;
		hMap = copyMap(aMap);
		for (var x:uint = 0; x < pieces; x++) {
			for (var y:uint = 0; y < pieces; y++) {
				if (getCheck(x, y)) {
					var prio:uint = pMap[y][x];
					var turns:uint = getTurns(p, x, y);
					if (turns > 0) {
						hMap[y][x] = "*";
						prio += turns;
						/*
						if (best < prio) {
							px = x;
							py = y;
							best = prio;
						} else if (best == prio) {
							if (Math.random() > 0.5) {
								px = x;
								py = y;
								best = prio;
							}
						}
						*/
						if (best <= prio) {
							px = x;
							py = y;
							best = prio;
						}
					}
				}
			}
		}
		return {x: px, y: py};
	}
	//指定したマスの8方向に対して反転できるコマ数を取得する
	public function getTurns(p:uint, x:uint, y:uint):uint {
		var turns:uint = 0;
		for (var dx:int = -1; dx <= 1; dx++) {
			for (var dy:int = -1; dy <= 1; dy++) {
			if (dx == 0 && dy == 0) continue;
				var px:int = x + dx;
				var py:int = y + dy;
				while (px >= 0 && px < pieces && py >= 0 && py < pieces) {
					var player:uint = bMap[py][px];
					if (player == 0) break;
					if (player == p) {
						if (dx != 0) {
							turns += dx*(px - x) - 1;
						} else {
							turns += dy*(py - y) - 1;
						}
						break;
					}
					px += dx;
					py += dy;
				}
			}
		}
		return turns;
	}
	//反転するコマ情報を取得する
	public function getTurnList(p:uint, x:uint, y:uint):Array {
		var list:Array = new Array();
		for (var dx:int = -1; dx <= 1; dx++) {
			for (var dy:int = -1; dy <= 1; dy++) {
				if (dx == 0 && dy == 0) continue;
				var px:int = x + dx;
				var py:int = y + dy;
				var checking:Boolean = true;
				while (px >= 0 && px < pieces && py >= 0 && py < pieces) {
					var player:uint = bMap[py][px];
					if (player == 0) break;
					if (player == p) {
						if (checking) {
							px = x + dx;
							py = y + dy;
							checking = false;
							continue;
						} else {
							break;
						}
					}
					if (!checking && player != p) {
						list.push({x: px, y: py});
					}
					px += dx;
					py += dy;
				}
			}
		}
		return list;
	}

}


//////////////////////////////////////////////////
//	コマの動きを管理するクラス
//////////////////////////////////////////////////

import flash.display.Sprite;
import flash.display.Shape;
import flash.events.Event;
import flash.utils.Timer;
import flash.events.TimerEvent;

class Piece extends Sprite {
	public var id:uint;
	public var px:uint;
	public var py:uint;
	private var piece1:PieceShape;
	private var piece2:PieceShape;
	private var scale:Number = 1;
	private var light:Shape;
	private var _brightness:Number = 0;

	public function Piece() {
		draw();
	}

	public function put(p:uint):void {
		id = p;
		var piece:PieceShape = this["piece"+id];
		addChild(piece);
		piece.scaleX = piece.scaleY = scale = 1.6;
		addEventListener(Event.ENTER_FRAME, putPiece, false, 0, true);
	}
	private function putPiece(evt:Event):void {
		var piece:PieceShape = this["piece"+id];
		scale -= 0.1;
		piece.scaleX = piece.scaleY = scale;
		if (scale <= 1) {
			piece.scaleX = piece.scaleY = scale = 1;
			removeEventListener(Event.ENTER_FRAME, putPiece);
			dispatchEvent(new Event(Game.PUT_COMPLETE))
		}
	}
	public function turn():void {
		var old:PieceShape = this["piece"+id];
		removeChild(old);
		id = id%2 + 1;
		var piece:PieceShape = this["piece"+id];
		addChild(piece);
		addChild(light);
		var timer:Timer = new Timer(50, 6);
		timer.addEventListener(TimerEvent.TIMER, turnPiece, false, 0, true);
		timer.addEventListener(TimerEvent.TIMER_COMPLETE, motion, false, 0, true);
		timer.start();
	}
	private function turnPiece(evt:TimerEvent):void {
		if (evt.target.currentCount == 4) {
			evt.target.removeEventListener(TimerEvent.TIMER, turnPiece);
			removeChild(light);
		}
	}
	private function motion(evt:TimerEvent):void {
		evt.target.removeEventListener(TimerEvent.TIMER_COMPLETE, motion);
		brightness = 100;
		addEventListener(Event.ENTER_FRAME, bright, false, 0, true);
	}
	private function bright(evt:Event):void {
		brightness -= 20;
		if (brightness <= 0) {
			brightness = 0;
			removeEventListener(Event.ENTER_FRAME, bright);
			dispatchEvent(new Event(Game.TURN_COMPLETE))
		}
	}
	private function draw():void {
		graphics.beginFill(0x000000);
		graphics.drawCircle(0, 0, 20);
		graphics.endFill();
		piece1 = new PieceShape(1);
		piece2 = new PieceShape(2);
		light = new Shape();
		light.graphics.beginFill(0xFFFFFF);
		light.graphics.drawCircle(0, 0, 20);
		light.graphics.drawCircle(0, 0, 15);
		light.graphics.endFill();
	}
	private function get brightness():Number {
		return _brightness;
	}
	private function set brightness(param:Number):void {
		_brightness = param;
		ColorManager.brightOffset(this, _brightness);
	}

}


//////////////////////////////////////////////////
//	コマを描画するクラス
//////////////////////////////////////////////////

import flash.display.Shape;
import flash.geom.Matrix;
import flash.display.GradientType;
import flash.display.SpreadMethod;
import flash.display.InterpolationMethod;

class PieceShape extends Shape {
	private var type:uint = 1;
	private static var cList:Array = [[0x888888, 0x000000], [0xFFFFFF, 0xBBBBBB]];
	private static var bList:Array = [0x444444, 0xDDDDDD];

	public function PieceShape(t:uint) {
		type = t;
		draw();
	}

	private function draw():void {
		var colors:Array = cList[type-1];
		var alphas:Array = [1, 1];
		var ratios:Array = [0, 255];
		var matrix:Matrix = new Matrix();
		matrix.createGradientBox(36, 36, 0.25*Math.PI, -18, -18);
		graphics.beginGradientFill(GradientType.LINEAR, colors, alphas, ratios, matrix, SpreadMethod.PAD, InterpolationMethod.RGB, 0);
		graphics.drawCircle(0, 0, 18);
		graphics.endFill();
		var bColor:uint = bList[type-1];
		graphics.beginFill(bColor);
		graphics.drawCircle(0, 0, 15);
		graphics.endFill();
	}

}


//////////////////////////////////////////////////
//	マスを着色するクラス
//////////////////////////////////////////////////

import flash.display.Shape;
import flash.geom.ColorTransform;

class Point extends Shape {
	public var id:uint;
	private static var bColor:uint = 0x66CC00;
	private static var cColor:uint = 0x66CCFF;
	private static var bColorTrans:ColorTransform;
	private static var cColorTrans:ColorTransform;

	public function Point() {
		draw();
	}

	public function init():void {
		transform.colorTransform = bColorTrans;
	}
	public function hint():void {
		transform.colorTransform = cColorTrans;
	}
	private function draw():void {
		graphics.beginFill(0xFFFFFF);
		graphics.drawRect(-20, -20, 40, 40);
		graphics.endFill();
		bColorTrans = new ColorTransform(0, 0, 0, 1, 0, 0, 0, 0);
		bColorTrans.color = bColor;
		cColorTrans = new ColorTransform(0, 0, 0, 1, 0, 0, 0, 0);
		cColorTrans.color = cColor;
	}

}


//////////////////////////////////////////////////
//	得点を管理するクラス
//////////////////////////////////////////////////

import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFieldType;
import flash.text.AntiAliasType;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flash.filters.DropShadowFilter;

class Score extends Sprite {
	private var pieces1:uint = 0;
	private var pieces2:uint = 0;
	private var score1:TextField;
	private var score2:TextField;
	private var message:TextField;
	private var player:Array;
	private var msgs:Object;
	private var time:Time;
	private var txt:TextField;
	private static var bColor:uint = 0xFFFF00;
	private static var sColor:uint = 0x000000;
	private static var b1Color:uint = 0x66CC00;
	private static var b2Color:uint = 0xFFFFFF;
	private static var fontType:String = "_ゴシック";
	//private static var initMsg:String = "ゲームを初期化しています。";
	private static var initMsg:String = "Enterキー・上下左右キーで操作してください。";
	private static var playMsg:String = "ゲームを開始します。";
	private static var putMsg:String = "の番です。";
	private static var passMsg:String = "はパス。";
	private static var finishMsg:String = "ゲームは終了しました。";
	private static var noPointMsg:String = "そのマスにはコマを置けません。";

	public function Score() {
		draw();
		initialize();
	}

	private function initialize():void {
		msgs = new Object();
		msgs[Game.INIT] = initMsg;
		msgs[Game.PLAY] = playMsg;
		msgs[Game.PUT] = putMsg;
		msgs[Game.FINISH] = finishMsg;
		msgs[Game.NO_POINT] = noPointMsg;
		player = new Array();
		player[1] = "あなた";
		player[2] = "コンピュータ";
		time = new Time(txt);
	}
	public function init():void {
		pieces1 = 0;
		pieces2 = 0;
		showScore();
	}
	public function put(p:uint):void {
		this["pieces"+p] ++;
		showScore();
	}
	public function turn(p:uint):void {
		this["pieces"+p] ++;
		var r:uint = p%2 + 1;
		this["pieces"+r] --;
		showScore();
	}
	private function showScore():void {
		score1.text = String(pieces1);
		score2.text = String(pieces2);
	}
	public function showMessage(mode:String, p:uint = 0, passed:Boolean = false):void {
		switch (mode) {
			case Game.PUT :
				if (!passed) {
					message.text = player[p] + msgs[mode];
				} else {
					var r:uint = p%2 + 1;
					message.text = player[r] + passMsg + player[p] + msgs[mode];
				}
				break;
			default :
				message.text = msgs[mode];
				break;
		}
	}
	public function getScore():Array {
		return [pieces1, pieces2];
	}
	public function startTime():void {
		time.start();
	}
	public function stopTime():void {
		time.stop();
	}
	public function resetTime():void {
		time.reset();
	}
	private function draw():void {
		graphics.beginFill(bColor);
		graphics.drawRect(20, 56, 340, 24);
		graphics.endFill();
		graphics.beginFill(b1Color);
		graphics.drawRoundRect(256, 0, 104, 44, 12);
		graphics.endFill();
		graphics.beginFill(b2Color);
		graphics.drawRoundRect(258, 2, 100, 40, 8);
		graphics.endFill();
		var piece1:PieceShape = new PieceShape(1);
		addChild(piece1);
		piece1.x = 288;
		piece1.y = 29;
		piece1.width = piece1.height = 24;
		var piece2:PieceShape = new PieceShape(2);
		addChild(piece2);
		piece2.x = 328;
		piece2.y = 29;
		piece2.width = piece2.height = 24;
		var shade:DropShadowFilter = new DropShadowFilter(1, 90, sColor, 0.3, 2, 2, 2, 2, false, false);
		filters = [shade];
		drawText();
	}
	private function drawText():void {
		var tf:TextFormat = new TextFormat();
		tf.font = "_ゴシック";
		tf.size = 12;
		tf.align = TextFormatAlign.LEFT;
		message = new TextField();
		addChild(message);
		message.x = 30;
		message.y = 59;
		message.width = 404;
		message.height = 21;
		message.type = TextFieldType.DYNAMIC;
		message.selectable = false;
		message.antiAliasType = AntiAliasType.ADVANCED;
		message.defaultTextFormat = tf;
		message.textColor = 0x000000;
		var shade:DropShadowFilter = new DropShadowFilter(1, 90, sColor, 0.4, 2, 2, 2, 2, false, false);
		var tfn:TextFormat = new TextFormat();
		tfn.font = fontType;
		tfn.size = 12;
		tfn.align = TextFormatAlign.CENTER;
		var name1:TextField = new TextField();
		addChild(name1);
		name1.x = 273;
		name1.y = 1;
		name1.width = 30;
		name1.height = 19;
		name1.type = TextFieldType.DYNAMIC;
		name1.selectable = false;
		//name1.embedFonts = true;
		//name1.antiAliasType = AntiAliasType.ADVANCED;
		name1.defaultTextFormat = tfn;
		name1.textColor = 0x000000;
		name1.text = "You";
		name1.filters = [shade];
		var name2:TextField = new TextField();
		addChild(name2);
		name2.x = 313;
		name2.y = 1;
		name2.width = 30;
		name2.height = 19;
		name2.type = TextFieldType.DYNAMIC;
		name2.selectable = false;
		//name2.embedFonts = true;
		//name2.antiAliasType = AntiAliasType.ADVANCED;
		name2.defaultTextFormat = tfn;
		name2.textColor = 0x000000;
		name2.text = "CPU";
		name2.filters = [shade];
		var tfc:TextFormat = new TextFormat();
		tfc.font = fontType;
		tfc.size = 14;
		tfc.align = TextFormatAlign.CENTER;
		score1 = new TextField();
		addChild(score1);
		score1.x = 273;
		score1.y = 19;
		score1.width = 30;
		score1.height = 23;
		score1.type = TextFieldType.DYNAMIC;
		score1.selectable = false;
		//score1.embedFonts = true;
		//score1.antiAliasType = AntiAliasType.ADVANCED;
		score1.defaultTextFormat = tfc;
		score1.textColor = 0xFFFFFF;
		score1.text = String(0);
		score2 = new TextField();
		addChild(score2);
		score2.x = 313;
		score2.y = 19;
		score2.width = 30;
		score2.height = 23;
		score2.type = TextFieldType.DYNAMIC;
		score2.selectable = false;
		//score2.embedFonts = true;
		//score2.antiAliasType = AntiAliasType.ADVANCED;
		score2.defaultTextFormat = tfc;
		score2.textColor = 0x000000;
		score2.text = String(0);
		var tft:TextFormat = new TextFormat();
		tft.font = fontType;
		tft.size = 16;
		tft.align = TextFormatAlign.LEFT;
		var timer:TextField = new TextField();
		addChild(timer);
		timer.x = 140;
		timer.y = 18;
		timer.width = 40;
		timer.height = 21;
		timer.type = TextFieldType.DYNAMIC;
		timer.selectable = false;
		//timer.embedFonts = true;
		//timer.antiAliasType = AntiAliasType.ADVANCED;
		timer.defaultTextFormat = tft;
		timer.textColor = 0xFFFFFF;
		timer.text = "Time";
		txt = new TextField();
		addChild(txt);
		txt.x = 185;
		txt.y = 18;
		txt.width = 55;
		txt.height = 21;
		txt.type = TextFieldType.DYNAMIC;
		txt.selectable = false;
		//txt.embedFonts = true;
		//txt.antiAliasType = AntiAliasType.ADVANCED;
		txt.defaultTextFormat = tft;
		txt.textColor = 0xFFFFFF;
		txt.text = "00:00";
	}

}


//////////////////////////////////////////////////
//	タイマーを管理するクラス
//////////////////////////////////////////////////

import flash.display.Sprite;
import flash.text.TextField;
import flash.utils.getTimer;
import flash.utils.Timer;
import flash.events.TimerEvent;

class Time extends Sprite {
	private var target:TextField;
	private var startTime:uint;
	private var timer:Timer;
	private var countTime:uint = 30;

	public function Time(tg:TextField) {
		target = tg;
	}

	public function start():void {
		startTime = getTimer();
		timer = new Timer(countTime);
		timer.addEventListener(TimerEvent.TIMER, count, false, 0, true);
		timer.start();
	}
	private function count(evt:TimerEvent):void {
		var sec:uint = Math.floor((getTimer() - startTime)/1000);
		var min:String  = String(Math.floor(sec/60));
		min = (uint(min) < 10) ? "0" + min : min;
		var msec:String = String(sec%60);
		msec = (uint(msec) < 10) ? "0" + msec : msec;
		target.text = min + ":" + msec;
	}
	public function stop():void {
		timer.removeEventListener(TimerEvent.TIMER, count);
	}
	public function reset():void {
		target.text = "00:00";
	}

}


//////////////////////////////////////////////////
//	カーソル操作を管理するクラス
//////////////////////////////////////////////////

import flash.display.Sprite;
import flash.events.Event;
import flash.ui.Keyboard;
import flash.events.KeyboardEvent;
import flash.utils.Timer;
import flash.events.TimerEvent;

class Manager extends Sprite {
	private var board:Board;
	private static var pieces:uint = 8;
	public var cx:int;
	public var cy:int;
	private var tx:uint;
	private var ty:uint;
	private var cpu:Object;
	private static var autoTime:uint = 200;
	private var helpMode:String = "";
	private var keyMode:Boolean = false;

	public function Manager(b:Board) {
		board = b;
		if (stage) init();
		else addEventListener(Event.ADDED_TO_STAGE, init, false, 0, true);
	}

	private function init(evt:Event = null):void {
		removeEventListener(Event.ADDED_TO_STAGE, init);
		cpu = new Object();
		stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown, false, 0, true);
	}
	//カーソル位置を設定する
	public function setCursor(x:uint, y:uint):void {
		cx = x;
		cy = y;
	}
	//キー操作の処理
	private function keyDown(evt:KeyboardEvent):void {
		if (helpMode) {
			if (evt.keyCode == Keyboard.ENTER) {
				dispatchEvent(new Event(helpMode));
			}
		}
		if (keyMode) {
			switch (evt.keyCode) {
				case Keyboard.ENTER :
					dispatchEvent(new Event(Game.SELECT));
					break;
				case Keyboard.LEFT :
					cx --;
					break;
				case Keyboard.UP :
					cy --;
					break;
				case Keyboard.RIGHT :
					cx ++;
					break;
				case Keyboard.DOWN :
					cy ++;
					break;
			}
			if (cx > pieces - 1) cx = 0;
			if (cx < 0) cx = pieces - 1;
			if (cy > pieces - 1) cy = 0;
			if (cy < 0) cy = pieces - 1;
			dispatchEvent(new Event(Game.MOVE));
		}
	}
	//カーソル位置を移動する
	public function autoCursor(px:uint, py:uint):void {
		tx = px;
		ty = py;
		var timer:Timer = new Timer(autoTime);
		timer.addEventListener(TimerEvent.TIMER, moveCursor, false, 0, true);
		timer.start();
	}
	private function moveCursor(evt:TimerEvent):void {
		var mx:int = uint(tx > cx) - uint(tx < cx);
		var my:int = uint(ty > cy) - uint(ty < cy);
		if (mx != 0 || my != 0) {
			cx += mx;
			cy += my;
			dispatchEvent(new Event(Game.MOVE));
			if (cx == tx && cy == ty) {
				evt.target.removeEventListener(TimerEvent.TIMER, moveCursor);
				dispatchEvent(new Event(Game.SELECT));
			}
		}
	}
	public function set enable(param:Boolean):void {
		keyMode = param;
	}
	public function set help(param:String):void {
		helpMode = param;
	}

}


//////////////////////////////////////////////////
//	カーソルを描画するクラス
//////////////////////////////////////////////////

import flash.display.Sprite;
import flash.display.Shape;
import flash.utils.Timer;
import flash.events.TimerEvent;

class Cursor extends Sprite {
	private var id:uint = 0;
	private var cursor0:Shape;
	private var cursor1:Shape;
	private static var bColor:uint = 0x66CC00;
	private static var cColor:uint = 0x66CCFF;

	public function Cursor() {
		draw();
		init();
	}

	private function init():void {
		var cursor:Shape = this["cursor"+id];
		addChild(cursor);
		var timer:Timer = new Timer(250);
		timer.addEventListener(TimerEvent.TIMER, change, false, 0, true);
		timer.start();
	}
	private function change(evt:TimerEvent):void {
		var old:Shape = this["cursor"+id];
		removeChild(old);
		id = (id+1)%2;
		var cursor:Shape = this["cursor"+id];
		addChild(cursor);
	}
	private function draw():void {
		cursor0 = new Shape();
		cursor0.graphics.beginFill(0xFFFFFF);
		cursor0.graphics.moveTo(-21, -21);
		cursor0.graphics.lineTo(-21, -6);
		cursor0.graphics.lineTo(-18, -6);
		cursor0.graphics.lineTo(-18, -18);
		cursor0.graphics.lineTo(-6, -18);
		cursor0.graphics.lineTo(-6, -21);
		cursor0.graphics.lineTo(-21, -21);
		cursor0.graphics.moveTo(21, -21);
		cursor0.graphics.lineTo(21, -6);
		cursor0.graphics.lineTo(18, -6);
		cursor0.graphics.lineTo(18, -18);
		cursor0.graphics.lineTo(6, -18);
		cursor0.graphics.lineTo(6, -21);
		cursor0.graphics.lineTo(21, -21);
		cursor0.graphics.moveTo(-21, 21);
		cursor0.graphics.lineTo(-21, 6);
		cursor0.graphics.lineTo(-18, 6);
		cursor0.graphics.lineTo(-18, 18);
		cursor0.graphics.lineTo(-6, 18);
		cursor0.graphics.lineTo(-6, 21);
		cursor0.graphics.lineTo(-21, 21);
		cursor0.graphics.moveTo(21, 21);
		cursor0.graphics.lineTo(21, 6);
		cursor0.graphics.lineTo(18, 6);
		cursor0.graphics.lineTo(18, 18);
		cursor0.graphics.lineTo(6, 18);
		cursor0.graphics.lineTo(6, 21);
		cursor0.graphics.lineTo(21, 21);
		cursor0.graphics.endFill();
		cursor1 = new Shape();
		cursor1.graphics.beginFill(0xFFFFFF);
		cursor1.graphics.moveTo(-22, -22);
		cursor1.graphics.lineTo(-22, -7);
		cursor1.graphics.lineTo(-19, -7);
		cursor1.graphics.lineTo(-19, -19);
		cursor1.graphics.lineTo(-7, -19);
		cursor1.graphics.lineTo(-7, -22);
		cursor1.graphics.lineTo(-22, -22);
		cursor1.graphics.moveTo(22, -22);
		cursor1.graphics.lineTo(22, -7);
		cursor1.graphics.lineTo(19, -7);
		cursor1.graphics.lineTo(19, -19);
		cursor1.graphics.lineTo(7, -19);
		cursor1.graphics.lineTo(7, -22);
		cursor1.graphics.lineTo(22, -22);
		cursor1.graphics.moveTo(-22, 22);
		cursor1.graphics.lineTo(-22, 7);
		cursor1.graphics.lineTo(-19, 7);
		cursor1.graphics.lineTo(-19, 19);
		cursor1.graphics.lineTo(-7, 19);
		cursor1.graphics.lineTo(-7, 22);
		cursor1.graphics.lineTo(-22, 22);
		cursor1.graphics.moveTo(22, 22);
		cursor1.graphics.lineTo(22, 7);
		cursor1.graphics.lineTo(19, 7);
		cursor1.graphics.lineTo(19, 19);
		cursor1.graphics.lineTo(7, 19);
		cursor1.graphics.lineTo(7, 22);
		cursor1.graphics.lineTo(22, 22);
		cursor1.graphics.endFill();
	}

}


//////////////////////////////////////////////////
//	ヘルプ表示を管理するクラス
//////////////////////////////////////////////////

import flash.display.Sprite;
import flash.events.Event;
import flash.text.TextField;
import flash.text.TextFieldType;
import flash.text.AntiAliasType;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flash.filters.GlowFilter;

class Help extends Sprite {
	private var amplitude:Number = 0;
	private var scale:Number = 1;
	private static var targetScale:Number = 2;
	private static var deceleration:Number = 0.5;
	private static var friction:Number = 0.6;
	private var txt:TextField;
	private static var tColor:uint = 0x000000;
	private static var gColor:uint = 0xFFFFFF;
	private static var fontType:String = "_ゴシック";

	public function Help() {
		draw();
		hide();
	}

	public function hide():void {
		visible = false;
	}
	public function show(help:String):void {
		txt.text = help;
		visible = true;
		amplitude = 0;
		scale = 1;
		addEventListener(Event.ENTER_FRAME, elastic, false, 0, true);
	}
	private function elastic(evt:Event):void {
		amplitude += targetScale - scale;
		scale += amplitude*friction;
		amplitude *= deceleration;
		scaleX = scaleY = scale;
		if (Math.abs(targetScale - scale) < 0.005 && Math.abs(amplitude) < 0.001) {
			scaleX = scaleY = targetScale;
			removeEventListener(Event.ENTER_FRAME, elastic);
		}
	}
	private function draw():void {
		var tf:TextFormat = new TextFormat();
		tf.font = fontType;
		tf.size = 32;
		tf.align = TextFormatAlign.CENTER;
		txt = new TextField();
		addChild(txt);
		txt.x = -75;
		txt.y = -19;
		txt.width = 150;
		txt.height = 39;
		txt.type = TextFieldType.DYNAMIC;
		txt.selectable = false;
		//txt.embedFonts = true;
		//txt.antiAliasType = AntiAliasType.ADVANCED;
		txt.defaultTextFormat = tf;
		txt.textColor = tColor;
		var glow:GlowFilter = new GlowFilter(gColor, 1, 10, 10, 10, 1, false, false);
		txt.filters = [glow];
	}

}


//////////////////////////////////////////////////
// ColorManagerクラス
//////////////////////////////////////////////////

import flash.display.DisplayObject;
import flash.geom.ColorTransform;
import flash.filters.ColorMatrixFilter;

class ColorManager {
	private static var rs:Number = 0.3086;
	private static var gs:Number = 0.6094;
	private static var bs:Number = 0.0820;

	public function ColorManager() {
	}

	public static function brightOffset(target:DisplayObject, param:Number):void {
		target.transform.colorTransform = getBrightOffset(param);
	}
	private static function getBrightOffset(param:Number):ColorTransform {
		var percent:Number = 1;
		var offset:Number = param*2.55;
		var colorTrans:ColorTransform = new ColorTransform(0, 0, 0, 1, 0, 0, 0, 0);
		colorTrans.redMultiplier = percent;
		colorTrans.greenMultiplier = percent;
		colorTrans.blueMultiplier = percent;
		colorTrans.redOffset = offset;
		colorTrans.greenOffset = offset;
		colorTrans.blueOffset = offset;
		colorTrans.alphaMultiplier = 1;
		colorTrans.alphaOffset = 0;
		return colorTrans;
	}
	public static function saturation(target:DisplayObject, param:Number):void {
		target.filters = [getSaturation(param)];
	}
	private static function getSaturation(param:Number):ColorMatrixFilter {
		var colorMatrix:ColorMatrixFilter = new ColorMatrixFilter();
		var p:Number = param*0.01;
		var r:Number = (1 - p)*rs;
		var g:Number = (1 - p)*gs;
		var b:Number = (1 - p)*bs;
		var matrix:Array = [r + p, g, b, 0, 0, r, g + p, b, 0, 0, r, g, b + p, 0, 0, 0, 0, 0, 1, 0];
		colorMatrix.matrix = matrix;
		return colorMatrix;
	}

}


//////////////////////////////////////////////////
// SoundEffectクラス
//////////////////////////////////////////////////

import flash.events.EventDispatcher;
import flash.events.Event;
import flash.events.ProgressEvent;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.media.SoundTransform;
import flash.events.ProgressEvent;
import flash.net.URLRequest;

class SoundEffect extends EventDispatcher {
	private static var soundList:Object;
	private var sound:Sound;
	private var channel:SoundChannel;
	private static var initialized:Boolean = false;
	private var volume:Number;
	private var looping:Boolean = false;

	public function SoundEffect() {
		if (!initialized) initialize();
	}

	private static function initialize():void {
		initialized = true;
		soundList = new Object();
	}
	public function init(Snd:Class, id:String):void {
		var snd:Sound = new Snd();
		soundList[id] = snd;
	}
	public function load(file:String, id:String):void {
		var snd:Sound = new Sound();
		snd.load(new URLRequest(file));
		snd.addEventListener(ProgressEvent.PROGRESS, progress, false, 0, true);
		snd.addEventListener(Event.COMPLETE, loaded, false, 0, true);
		soundList[id] = snd;
	}
	public function play(id:String, vol:Number, loop:Boolean = false):void {
		if (channel != null) channel.stop();
		sound = soundList[id];
		volume = vol;
		looping = loop;
		channel = sound.play();
		var transform:SoundTransform = channel.soundTransform;
		transform.volume = volume;
		channel.soundTransform = transform;
		if (looping) {
			channel.addEventListener(Event.SOUND_COMPLETE, complete, false, 0, true);
		}
	}
	public function stop():void {
		if (channel != null) {
			channel.stop();
			channel.removeEventListener(Event.SOUND_COMPLETE, complete);
		}
	}
	private function progress(evt:ProgressEvent):void {
		dispatchEvent(evt);
	}
	private function loaded(evt:Event):void {
		dispatchEvent(evt);
	}
	private function complete(evt:Event):void {
		channel.removeEventListener(Event.SOUND_COMPLETE, complete);
		if (looping) {
			channel = sound.play(0);
			channel.addEventListener(Event.SOUND_COMPLETE, complete, false, 0, true);
			var transform:SoundTransform = channel.soundTransform;
			transform.volume = volume;
			channel.soundTransform = transform;
		}
	}

}


//////////////////////////////////////////////////
// Btnクラス
//////////////////////////////////////////////////

import flash.display.Sprite;
import flash.display.Shape;
import flash.text.TextField;
import flash.text.TextFieldType;
import flash.text.AntiAliasType;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flash.filters.GlowFilter;
import flash.events.MouseEvent;

class Btn extends Sprite {
	public var id:uint;
	private var shade:Shape;
	private var bottom:Shape;
	private var light:Shape;
	private var base:Shape;
	private var txt:TextField;
	private var label:String = "";
	private static var fontType:String = "_ゴシック";
	private var _width:uint = 60;
	private static var _height:uint = 20;
	private static var corner:uint = 5;
	private var type:uint = 1;
	private static var bColor:uint = 0xFFFFFF;
	private static var sColor:uint = 0x000000;
	private static var upColor:uint = 0x666666;
	private static var overColor:uint = 0x333333;
	private static var offColor:uint = 0x999999;
	private static var gColor:uint = 0x0099FF;
	private var blueGlow:GlowFilter;
	private var shadeGlow:GlowFilter;
	private var _clicked:Boolean = false;
	private var _enabled:Boolean = true;

	public function Btn() {
	}

	public function init(option:Object):void {
		if (option.id != undefined) id = option.id;
		if (option.label != undefined) label = option.label;
		if (option.width != undefined) _width = option.width;
		if (option.type != undefined) type = option.type;
		draw();
	}
	private function draw():void {
		switch (type) {
		case 1 :
			bColor = 0xFFFFFF;
			sColor = 0x000000;
			upColor = 0x666666;
			overColor = 0x333333;
			offColor = 0x999999;
			break;
		case 2 :
			bColor = 0x000000;
			sColor = 0xFFFFFF;
			upColor = 0x666666;
			overColor = 0x999999;
			offColor = 0x333333;
			break;
		}
		blueGlow = new GlowFilter(gColor, 0.6, 5, 5, 2, 3, false, true);
		shadeGlow = new GlowFilter(sColor, 0.3, 4, 4, 2, 3, false, true);
		shade = new Shape();
		bottom = new Shape();
		light = new Shape();
		base = new Shape();
		txt = new TextField();
		addChild(shade);
		addChild(bottom);
		addChild(light);
		addChild(base);
		addChild(txt);
		createBase(shade, _width, _height, corner, sColor);
		shade.filters = [shadeGlow];
		createBase(bottom, _width, _height, corner, sColor, 0.3);
		createBase(light, _width, _height, corner, gColor);
		light.filters = [blueGlow];
		createBase(base, _width, _height, corner, bColor);
		txt.x = -_width*0.5;
		txt.y = -_height*0.5;
		txt.width = _width;
		txt.height = _height - 1;
		txt.type = TextFieldType.DYNAMIC;
		txt.selectable = false;
		//txt.embedFonts = true;
		//txt.antiAliasType = AntiAliasType.ADVANCED;
		var tf:TextFormat = new TextFormat();
		tf.font = fontType;
		tf.size = 12;
		tf.align = TextFormatAlign.CENTER;
		txt.defaultTextFormat = tf;
		txt.text = label;
		enabled = true;
		mouseChildren = false;
	}
	private function rollOver(evt:MouseEvent):void {
		_over();
	}
	private function rollOut(evt:MouseEvent):void {
		_up();
	}
	private function press(evt:MouseEvent):void {
		_down();
	}
	private function release(evt:MouseEvent):void {
		_up();
	}
	private function click(evt:MouseEvent):void {
	}
	private function _up():void {
		txt.y = -_height*0.5;
		txt.textColor = upColor;
		base.y = -1;
		light.visible = false;
		light.y = -1;
	}
	private function _over():void {
		txt.y = -_height*0.5;
		txt.textColor = overColor;
		base.y = -1;
		light.visible = true;
		light.y = -1;
	}
	private function _down():void {
		txt.y = -_height*0.5 + 1;
		txt.textColor = overColor;
		base.y = 0;
		light.visible = true;
		light.y = 0;
	}
	private function _off():void {
		txt.y = -_height*0.5 + 1;
		txt.textColor = offColor;
		base.y = 0;
		light.visible = false;
		light.y = 0;
	}
	public function get clicked():Boolean {
		return _clicked;
	}
	public function set clicked(param:Boolean):void {
		_clicked = param;
		enabled = !_clicked;
		if (_clicked) {
			_down();
		} else {
			_up();
		}
	}
	public function get enabled():Boolean {
		return _enabled;
	}
	public function set enabled(param:Boolean):void {
		_enabled = param;
		buttonMode = _enabled;
		mouseEnabled = _enabled;
		useHandCursor = _enabled;
		if (_enabled) {
			_up();
			addEventListener(MouseEvent.MOUSE_OVER, rollOver, false, 0, true);
			addEventListener(MouseEvent.MOUSE_OUT, rollOut, false, 0, true);
			addEventListener(MouseEvent.MOUSE_DOWN, press, false, 0, true);
			addEventListener(MouseEvent.MOUSE_UP, release, false, 0, true);
			addEventListener(MouseEvent.CLICK, click, false, 0, true);
		} else {
			_off();
			removeEventListener(MouseEvent.MOUSE_OVER, rollOver);
			removeEventListener(MouseEvent.MOUSE_OUT, rollOut);
			removeEventListener(MouseEvent.MOUSE_DOWN, press);
			removeEventListener(MouseEvent.MOUSE_UP, release);
			removeEventListener(MouseEvent.CLICK, click);
		}
	}
	private function createBase(target:Shape, w:uint, h:uint, c:uint, color:uint, alpha:Number = 1):void {
		target.graphics.beginFill(color, alpha);
		target.graphics.drawRoundRect(-w*0.5, -h*0.5, w, h, c*2);
		target.graphics.endFill();
	}

}

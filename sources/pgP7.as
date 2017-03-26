// Jump game
//  Jump a hole.
//  <Operation>
//   Mouse: Move.
//   Click: Jump.
package {
	import flash.display.Sprite;
	[SWF(width="465", height="465", backgroundColor="0", frameRate="30")]
	public class Main extends Sprite {
		public function Main() { main = this; initializeFirst(); }
	}
}
// Initialize a game state.
const TITLE:String = "JUMP GAME";
var scrollCount:Number, scrollVel:Number, holeCount:int;
function initialize():void {
	player.initialize();
	scrollVel = 1;
	scrollCount = holeCount = 0;
	locate(0, 0);
	for (var i:int = 0; i < WIDTH; i++) print("O");
	for (i = 0; i < HEIGHT; i++) {
		locate(WIDTH - 1, i);
		print("O");
	}
	locate(0, HEIGHT - 1);
	for (i = 0; i < WIDTH; i++) print("O");
}
// Update a game frame.
function update():void {
	scrollCount += scrollVel;
	for (; scrollCount >= 1; scrollCount--) {
		scrollFloor();
		if (player.isOnFloor) {
			score++;
			locate(2, 2);
			print(String(score));
		}
		locate(0, 0);
		if (holeCount > 0) {
			print(" ");
			holeCount--;
			if (holeCount <= 0) holeCount = -(randi(20) + randi(20) + randi(20) + 2);
		} else {
			print("O");
			holeCount++;
			if (holeCount >= 0) holeCount = randi(5) + randi(5) + randi(5) + 2;
		}
	}
	player.update();
	scrollVel += 0.001;
}
function scrollFloor():void {
	for (var i:int = 0; i < WIDTH - 1; i++) vram[i][HEIGHT - 1] = vram[i + 1][HEIGHT - 1];
	for (i = HEIGHT - 2; i >= 0; i--) vram[WIDTH - 1][i + 1] = vram[WIDTH - 1][i];
	for (i = WIDTH - 2; i >= 0; i--) vram[i + 1][0] = vram[i][0];
}
// Player.
var player:Player = new Player;
class Player {
	public var pos:Vector3D = new Vector3D, ppos:Vector3D = new Vector3D, isOnFloor:Boolean, isFalling:Boolean;
	public function initialize():void {
		pos.x = ppos.x = WIDTH / 2; pos.y = ppos.y = HEIGHT / 2;
		isOnFloor = false; isFalling = true;
	}
	public function update():void {
		var vy:Number = pos.y - ppos.y;
		ppos.x = pos.x; ppos.y = pos.y;
		pos.x += (mouseX - pos.x) * 0.2;
		if (pos.x < 0) pos.x = 0;
		else if (pos.x > WIDTH - 2) pos.x = WIDTH - 2;
		if (isOnFloor) {
			if (screen(pos.x, pos.y + 1) != "O") {
				startGameOver();
				return;
			}
			if (isMousePressed) {
				pos.y -= 1.5;
				isOnFloor = isFalling = false;
			}
		} else {
			if (isMousePressed) {
				if (isFalling) pos.y += 0.2;
			} else {
				isFalling = true;
				pos.y += 0.2;
			}
			pos.y += vy + 0.1;
			if (pos.y >= HEIGHT - 2) {
				pos.y = HEIGHT - 2;
				isOnFloor = true;
			}
		}
		locate(ppos.x, ppos.y);
		print(" ");
		locate(pos.x, pos.y);
		print("A");
	}
}
import flash.display.*;
import flash.filters.*;
import flash.geom.*;
import flash.events.*;
import flash.text.*;
// Handle game state (Title/In game/Game over).
const GAME_OVER_DURATION:int = 150;
var gameOverTicks:int, score:int;
function startTitle():void {
	cls();
	locate((WIDTH - TITLE.length - 4) / 2, 10);
	print("--" + TITLE + "--");
	locate(13, 18);
	print("CLICK TO START");
	gameOverTicks = 0;
}
function startGame():void {
	cls();
	initialize();
	score = 0;
	gameOverTicks = -1;
}
function startGameOver():void {
	locate(15, 10);
	print("GAME OVER");
	locate(14, 18);
	print("SCORE: " + score);
	gameOverTicks = GAME_OVER_DURATION;
}
function get isInGame():Boolean {
	if (gameOverTicks < 0) return true;
	if (gameOverTicks > 0) {
		gameOverTicks--;
		if (gameOverTicks == 0) startTitle();
	}
	if (gameOverTicks < GAME_OVER_DURATION - 30 && isMousePressed) startGame();
	return false;
}
// Initialize a bitmapdata and events.
const SCREEN_WIDTH:int = 465, SCREEN_HEIGHT:int = 465;
var main:Main, bd:BitmapData, isMousePressed:Boolean;
function initializeFirst():void {
	bd = new BitmapData(SCREEN_WIDTH, SCREEN_HEIGHT, false);
	bd.fillRect(bd.rect, 0);
	main.addChild(new Bitmap(bd));
	main.stage.addEventListener(MouseEvent.MOUSE_DOWN, function (e:Event):void { isMousePressed = true; });
	main.stage.addEventListener(MouseEvent.MOUSE_UP, function (e:Event):void { isMousePressed = false; });
	startTitle();
	main.addEventListener(Event.ENTER_FRAME, updateFrame);
}
// Update the frame.
function updateFrame(event:Event):void {
	if (isInGame) update();
	cg.draw();
}
// Character graphics plane.
var vram:Vector.<Vector.<int>> = new Vector.<Vector.<int>>(WIDTH);
var cg:Cg = new Cg;
const WIDTH:int = 40, HEIGHT:int = 25;
class Cg {
	public static const PIXEL_WIDTH:int = SCREEN_WIDTH / WIDTH, PIXEL_HEIGHT:int = PIXEL_WIDTH * 1.4;
	public static const SCREEN_PIXEL_WIDTH:int = PIXEL_WIDTH * WIDTH + PIXEL_WIDTH * 0.5;
	public static const SCREEN_PIXEL_HEIGHT:int = PIXEL_HEIGHT * HEIGHT;
	public static const SCREEN_PIXEL_X:int = (SCREEN_WIDTH - SCREEN_PIXEL_WIDTH + PIXEL_WIDTH * 0.5) / 2;
	public static const SCREEN_PIXEL_Y:int = (SCREEN_HEIGHT - SCREEN_PIXEL_HEIGHT) / 2;
	public static const strings:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()_+-=[]\\{}|;':\",./<>?";
	private var screenRect:Rectangle = new Rectangle(SCREEN_PIXEL_X, SCREEN_PIXEL_Y, SCREEN_PIXEL_WIDTH, SCREEN_PIXEL_HEIGHT);
	private var bds:Vector.<BitmapData> = new Vector.<BitmapData>;
	private var rect:Rectangle = new Rectangle(0, 0, PIXEL_WIDTH * 1.4, PIXEL_HEIGHT * 1.4);
	private var cx:int, cy:int;
	public function Cg() {
		for (var i:int = 0; i < strings.length; i++) {
			var bd:BitmapData = createCharacterBitmapData(strings.charAt(i));
			bds.push(bd);
		}
		for (i = 0; i < WIDTH; i++) vram[i] = new Vector.<int>(HEIGHT);
		cls();
	}
	public function cls():void {
		for (var y:int = 0; y < HEIGHT; y++)
			for (var x:int = 0; x < WIDTH; x++)
				vram[x][y] = -1;
	}
	public function locate(x:int, y:int):void {
		cx = x; cy = y;
	}
	public function print(s:String):void {
		for (var i:int = 0; i < s.length; i++, cx++) vram[cx][cy] = strings.indexOf(s.charAt(i));
	}
	public function screen(x:int, y:int):String {
		return strings.charAt(vram[x][y]);
	}
	public function draw():void {
		bd.lock();
		bd.fillRect(screenRect, 0x225522);
		var p:Point = new Point;
		for (var y:int = 0; y < HEIGHT; y++) {
			p.y = y * PIXEL_HEIGHT + SCREEN_PIXEL_Y - 4;
			p.x = SCREEN_PIXEL_X;
			for (var x:int = 0; x < WIDTH; x++, p.x += PIXEL_WIDTH) {
				var c:int = vram[x][y];
				if (c >= 0) bd.copyPixels(bds[c], rect, p);
			}
		}
		bd.unlock();
	}
}
function cls():void { cg.cls(); }
function locate(x:int, y:int):void { cg.locate(x, y); }
function print(s:String):void { cg.print(s); }
function screen(x:int, y:int):String { return cg.screen(x, y); }
function get mouseX():Number {
	return Number(main.stage.mouseX - Cg.SCREEN_PIXEL_X) / Cg.PIXEL_WIDTH;
}
function get mouseY():Number {
	return Number(main.stage.mouseY - Cg.SCREEN_PIXEL_Y) / Cg.PIXEL_HEIGHT;
}
// Create a character bitmap data.
function createCharacterBitmapData(c:String):BitmapData {
	var bd:BitmapData = new BitmapData(Cg.PIXEL_WIDTH * 1.4, Cg.PIXEL_HEIGHT * 1.4, true, 0);
	var colors:Array = [ 0xff0000, 0x00ff00, 0x0000ff ];
	var s:Sprite = new Sprite;
	for (var i:int = 0; i < 3; i++) {
		var t:TextField = createTextField(0, 0, bd.rect.width, bd.rect.height, colors[i]);
		t.text = c;
		var tm:TextLineMetrics = t.getLineMetrics(0);
		var ofs:Number = Number(Cg.PIXEL_WIDTH - tm.width) / 2;
		var tbd:BitmapData = new BitmapData(Cg.PIXEL_WIDTH * 1.4, Cg.PIXEL_HEIGHT * 1.4, true, 0);
		tbd.draw(t);
		var b:Bitmap = new Bitmap(tbd);
		b.blendMode = BlendMode.ADD;
		b.alpha = 0.9;
		s.addChild(b);
		b.x = i * 1.5 + ofs;
	}
	bd.draw(s);
	return bd;
}
// Utility functions.
var sin:Function = Math.sin, cos:Function = Math.cos, atan2:Function = Math.atan2; 
var sqrt:Function = Math.sqrt, abs:Function = Math.abs, PI:Number = Math.PI;
function createTextField(x:int, y:int, width:int, height:int, color:int):TextField {
	var fm:TextFormat = new TextFormat, fi:TextField = new TextField;
	fm.size = 15; fm.color = color; fm.leftMargin = 0;
	fi.defaultTextFormat = fm; fi.x = x; fi.y = y; fi.width = width; fi.height = height; fi.selectable = false;
	return fi;
}
function randi(n:int):int {
	return Math.random() * n;
}

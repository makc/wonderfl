// Ski game
//  Go through the gates.
//  <Operation>
//   Mouse: Move player.
package {
	import flash.display.Sprite;
	[SWF(width="465", height="465", backgroundColor="0", frameRate="30")]
	public class Main extends Sprite {
		public function Main() { main = this; initialize(); }
	}
}
import flash.display.*;
import flash.filters.*;
import flash.geom.*;
import flash.events.*;
import flash.text.*;
const SCREEN_WIDTH:int = 465, SCREEN_HEIGHT:int = 465;
var main:Main, screen:BitmapData, isMouseClicked:Boolean;
// Initialize.
function initialize():void {
	screen = new BitmapData(SCREEN_WIDTH, SCREEN_HEIGHT, false);
	main.addChild(new Bitmap(screen));
	screen.fillRect(screen.rect, 0);
	startTitle();
	main.stage.addEventListener(MouseEvent.CLICK, function (e:Event):void { isMouseClicked = true; });
	main.addEventListener(Event.ENTER_FRAME, update);
}
// Update the frame.
var scrollCount:Number, nextGateCount:int;
function update(event:Event):void {
	if (gameOverTicks < 0) {
		scrollCount += player.scrollVel;
		for (; scrollCount >= 1; scrollCount--, nextGateCount--) {
			player.checkHit();
			if (gameOverTicks >= 0) return;
			cg.scrollUp();
			score++;
			if (nextGateCount <= 0) {
				gates.push(new Gate);
				nextGateCount += randi(Cg.HEIGHT) + randi(Cg.HEIGHT) + randi(Cg.HEIGHT) + Cg.HEIGHT / 2;
			}
			cg.clearLine(Cg.HEIGHT - 1);
			for (var i:int = 0; i < gates.length; i++) if (!gates[i].update()) { gates.splice(i, 1); i--; }
		}
		player.update();
	} else {
		if (gameOverTicks > 0) {
			gameOverTicks--;
			if (gameOverTicks == 0) startTitle();
		}
		if (isMouseClicked) startGame();
	}
	screen.lock();
	screen.fillRect(cg.screenRect, 0x225522);
	cg.draw();
	screen.unlock();
}
// Player.
var player:Player = new Player;
class Player {
	public var pos:Vector3D = new Vector3D, vel:Vector3D = new Vector3D;
	public var scrollVel:Number;
	private var eqc:int, rbc:int, lbc:int;
	public function initialize():void {
		pos.x = Cg.WIDTH / 2; pos.y = Cg.HEIGHT * 0.25;
		vel.x = vel.y = 0;
		scrollVel = 1;
		eqc = Cg.strings.indexOf("=");
		rbc = Cg.strings.indexOf("[");
		lbc = Cg.strings.indexOf("]");
	}
	public function update():void {
		var mx:int = main.stage.mouseX - pos.x * Cg.PIXEL_WIDTH - Cg.SCREEN_PIXEL_X;
		var my:int = main.stage.mouseY - pos.y * Cg.PIXEL_HEIGHT - Cg.SCREEN_PIXEL_Y;
		var ma:Number = atan2(mx, my);
		var ms:Number = sqrt(mx * mx + my * my) * 0.02;
		vel.x = sin(ma) * ms; vel.y = cos(ma) * ms;
		var vx:Number = abs(vel.x), vy:Number = abs(vel.y);
		var vn:int = (vx > vy ? vx : vy) + 1;
		vx = vel.x / vn; vy = vel.y / vn;
		for (; vn >= 0; vn--) {
			pos.x += vx; pos.y += vy;
			if (pos.x < 0) pos.x = 0;
			else if (pos.x >= Cg.WIDTH) pos.x = Cg.WIDTH - 1;
			if (pos.y < 0) pos.y = 0;
			else if (pos.y >= Cg.HEIGHT - 1) pos.y = Cg.HEIGHT - 2;
			checkHit();
			if (gameOverTicks >= 0) return;
		}
		cg.locate(pos.x, pos.y);
		cg.print("V");
		scrollVel += 0.001;
	}
	public function checkHit():void {
		var c:int = cg.chars[int(pos.x)][int(pos.y)];
		if (c == eqc || c == rbc || c == lbc) startGameOver();
	}
}
// Gates.
var gates:Vector.<Gate>;
class Gate {
	private const START_Y:int = Cg.HEIGHT * 3;
	public var pos:Vector3D = new Vector3D;
	public var width:int;
	public function Gate() {
		width = 5;
		pos.x = randi(Cg.WIDTH - width * 2) + width;
		pos.y = START_Y;
	}
	public function update():Boolean {
		pos.y--;
		if (pos.y <= 0) {
			cg.locate(0, Cg.HEIGHT - 2);
			for (var i:int = 0; i < pos.x - width - 1; i++) cg.print("=");
			cg.print("[");
			cg.locate(pos.x + width, Cg.HEIGHT - 2);
			cg.print("]");
			for (i = pos.x + width + 1; i < Cg.WIDTH; i++) cg.print("=");
			return false;
		}
		var w:int = width * (1.0 - pos.y / START_Y);
		cg.locate(pos.x - w, Cg.HEIGHT - 1);
		cg.print("[");
		cg.locate(pos.x + w, Cg.HEIGHT - 1);
		cg.print("]");
		return true;
	}
}
// Handle game state (Title/In game/Game over).
var gameOverTicks:int, score:int;
function startTitle():void {
	cg.clear();
	cg.locate(13, 10);
	cg.print("--SKI GAME--");
	cg.locate(12, 18);
	cg.print("CLICK TO START");
	gameOverTicks = 0;
}
function startGame():void {
	cg.clear();
	player.initialize();
	gates = new Vector.<Gate>;
	scrollCount = nextGateCount = 0;
	score = 0;
	gameOverTicks = -1;
}
function startGameOver():void {
	cg.locate(15, 10);
	cg.print("GAME OVER");
	cg.locate(14, 18);
	cg.print("SCORE: " + score);
	isMouseClicked = false;
	gameOverTicks = 150;
}
// Character graphics plane.
var cg:Cg = new Cg;
class Cg {
	public static const WIDTH:int = 40, HEIGHT:int = 25;
	public static const PIXEL_WIDTH:int = SCREEN_WIDTH / WIDTH, PIXEL_HEIGHT:int = PIXEL_WIDTH * 1.4;
	public static const SCREEN_PIXEL_WIDTH:int = PIXEL_WIDTH * WIDTH + PIXEL_WIDTH * 0.5;
	public static const SCREEN_PIXEL_HEIGHT:int = PIXEL_HEIGHT * HEIGHT;
	public static const SCREEN_PIXEL_X:int = (SCREEN_WIDTH - SCREEN_PIXEL_WIDTH + PIXEL_WIDTH * 0.5) / 2;
	public static const SCREEN_PIXEL_Y:int = (SCREEN_HEIGHT - SCREEN_PIXEL_HEIGHT) / 2;
	public static const strings:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()_+-=[]\\{}|;':\",./<>?";
	public var screenRect:Rectangle = new Rectangle(SCREEN_PIXEL_X, SCREEN_PIXEL_Y, SCREEN_PIXEL_WIDTH, SCREEN_PIXEL_HEIGHT);
	public var chars:Vector.<Vector.<int>> = new Vector.<Vector.<int>>(WIDTH);
	private var bds:Vector.<BitmapData> = new Vector.<BitmapData>;
	private var rect:Rectangle;
	private var cx:int, cy:int;
	public function Cg() {
		for (var i:int = 0; i < strings.length; i++) {
			var bd:BitmapData = createCharacterBitmapData(strings.charAt(i));
			bds.push(bd);
		}
		rect = new Rectangle(0, 0, PIXEL_WIDTH * 1.4, PIXEL_HEIGHT * 1.4);
		for (i = 0; i < WIDTH; i++) chars[i] = new Vector.<int>(HEIGHT);
		clear();
	}
	public function clear():void {
		for (var y:int = 0; y < HEIGHT; y++)
			for (var x:int = 0; x < WIDTH; x++)
				chars[x][y] = -1;
	}
	public function scrollUp():void {
		for (var y:int = 0; y < HEIGHT - 2; y++)
			for (var x:int = 0; x < WIDTH; x++)
				chars[x][y] = chars[x][y + 1];
		for (x = 0; x < WIDTH; x++) chars[x][HEIGHT - 2] = -1;
	}
	public function clearLine(y:int):void {
		for (var x:int = 0; x < WIDTH; x++) chars[x][y] = -1;
	}
	public function locate(x:int, y:int):void {
		cx = x; cy = y;
	}
	public function print(s:String):void {
		for (var i:int = 0; i < s.length; i++, cx++) chars[cx][cy] = strings.indexOf(s.charAt(i));
	}
	public function draw():void {
		var p:Point = new Point;
		for (var y:int = 0; y < HEIGHT; y++) {
			p.y = y * PIXEL_HEIGHT + SCREEN_PIXEL_Y - 4;
			p.x = SCREEN_PIXEL_X;
			for (var x:int = 0; x < WIDTH; x++, p.x += PIXEL_WIDTH) {
				var c:int = chars[x][y];
				if (c >= 0) screen.copyPixels(bds[c], rect, p);
			}
		}
	}
}
// Create a character bitmap data.
function createCharacterBitmapData(c:String):BitmapData {
	var bd:BitmapData = new BitmapData(Cg.PIXEL_WIDTH * 1.4, Cg.PIXEL_HEIGHT * 1.4, true, 0);
	var colors:Array = [ 0xff0000, 0x00ff00, 0x0000ff ];
	var s:Sprite = new Sprite;
	for (var i:int = 0; i < 3; i++) {
		var tbd:BitmapData = new BitmapData(Cg.PIXEL_WIDTH * 1.4, Cg.PIXEL_HEIGHT * 1.4, true, 0);
		var t:TextField = createTextField(0, 0, bd.rect.width, bd.rect.height, colors[i]);
		t.text = c;
		var tm:TextLineMetrics = t.getLineMetrics(0);
		var ofs:Number = Number(Cg.PIXEL_WIDTH - tm.width) / 2;
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
var sin:Function = Math.sin, cos:Function = Math.cos, atan2:Function = Math.atan2, sqrt:Function = Math.sqrt;
var abs:Function = Math.abs, PI:Number = Math.PI;
function createTextField(x:int, y:int, width:int, height:int, color:int):TextField {
	var fm:TextFormat = new TextFormat, fi:TextField = new TextField;
	fm.size = 15; fm.color = color; fm.leftMargin = 0;
	fi.defaultTextFormat = fm; fi.x = x; fi.y = y; fi.width = width; fi.height = height;  fi.selectable = false;
	return fi;
}
function randi(n:int):int {
	return Math.random() * n;
}
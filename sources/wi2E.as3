// DANCE ON RADAR
//  Avoid and destory incoming missiles.
//  <Operation>
//   Mouse: Change direction and speed.
//   Drag:  Lock missiles and move sideways.
package {
	import flash.display.Sprite;
	[SWF(width="465", height="465", backgroundColor="0", frameRate="30")]
	public class Main extends Sprite {
		public function Main() { main = this; initializeFirst(); }
	}
}
// Initializers.
var initializePhase:int = 0;
function initialize():void {
	switch (initializePhase) {
		case 0: initializeBlurs(); cg = new Cg; initializeSounds(); break;
		case 1: player = new Player; break;
		case 2: field = new Field; break;
		case 3: Missile.initalize(); break;
		case 4: LockMissile.initalize(); break;
		case 5: Explosion.initalize(); break;
		case 6: Line.initialize(0); break;
		case 7: Line.initialize(1); break;
		case 8: Line.initialize(2); break;
		case 9: Line.initialize(3); break;
		default: startTitle(); initializePhase = -1; return;
	}
	initializePhase++;
	cg.print("CREATING DATA..." + int(Number(initializePhase / 10) * 100) + "%", 100, 200);
}
function initializeTitle():void {
	field.initialize();
}
function initializeGame():void {
	stopBgm();
	field.initialize();
	player.initialize();
	missiles = new Vector.<Missile>;
	lockMissiles = new Vector.<LockMissile>;
	explosions = new Vector.<Explosion>;
	lines = new Vector.<Line>;
	missileAppearsTicks = 0; missileAppearsDuration = 50;
	gameSpeed = 1.0;
	playBgm();
}
function initalizeGameOver():void {
	fadeOutBgm();
}
// Update a game frame.
var missileAppearsTicks:int, missileAppearsDuration:Number;
var gameSpeed:Number;
function update():void {
	field.draw();
	for (var i:int = 0; i < lines.length; i++) if (!lines[i].update()) { lines.splice(i, 1); i--; }
	for (i = 0; i < lockMissiles.length; i++) if (!lockMissiles[i].update()) { lockMissiles.splice(i, 1); i--; }
	for (i = 0; i < explosions.length; i++) if (!explosions[i].update()) { explosions.splice(i, 1); i--; }
	player.update();
	missileAppearsTicks--;
	if (isInGame && missileAppearsTicks <= 0) {
		missiles.push(new Missile);
		missileAppearsTicks = missileAppearsDuration;
	}
	missileAppearsDuration -= 0.01; if (missileAppearsDuration < 10) missileAppearsDuration = 50;
	gameSpeed += 0.0003;
	for (i = 0; i < missiles.length; i++) if (!missiles[i].update()) { missiles.splice(i, 1); i--; }
	cg.print(String(score), 10, 10);
}
function updateTitle():void {
	field.draw();
	field.pos.x -= 5; field.pos.y -= 1;
	cg.print("DANCE ON RADAR", 50, 80);
	cg.print("CLICK TO START", 50, 120);
	cg.print(String(score), 10, 10);
}
function updateGameOver():void {
	update();
	cg.print("GAME OVER", 50, 80);
}
// Player
var player:Player;
class Player {
	private const MAX_SPEED:Number = 32;
	public var pos:Vector3D = new Vector3D;
	public var angle:Number;
	private var shape:VectorShape, shieldShape:VectorShape;
	private var velAngle:Number, speed:Number;
	private var prevMousePos:Vector3D = new Vector3D, vel:Vector3D = new Vector3D;
	private var wasMousePressed:Boolean;
	private var shield:Number;
	private var ticks:int;
	public function Player() {
		shape = new VectorShape(function (g:Graphics):void {
			g.lineStyle(5, 0x00ff00, 0.5);
			g.moveTo(0, -16);
			g.lineTo(-12, 16);
			g.lineTo(0, 10);
			g.lineTo(12, 16);
			g.lineTo(0, -16);
		}, 32, 32, true, true);
		shieldShape = new VectorShape(function (g:Graphics):void {
			g.beginFill(0x00ff00, 0.1);
			g.moveTo(-8, -16); g.lineTo(8, -16); g.lineTo(8, 16); g.lineTo(-8, 16);
			g.endFill();
		}, 16, 32, false, false);
	}
	public function initialize():void {
		pos.x = pos.y = 0;
		angle = velAngle = PI; speed = 1;
		vel.x = vel.y = 0;
		prevMousePos.x = main.stage.mouseX; prevMousePos.y = main.stage.mouseY;
		wasMousePressed = false;
		ticks = 0;
		shield = 10;
	}
	public function update():void {
		if (isInGame) {
			var mx:Number = main.stage.mouseX, my:Number = main.stage.mouseY;
			var ox:Number = mx - pos.x - SCREEN_WIDTH / 2, oy:Number = my - pos.y - SCREEN_HEIGHT / 2;
			if (isMousePressed) {
				vel.x += ((mx - prevMousePos.x) * MAX_SPEED * 0.2 - vel.x) * 0.1;
				vel.y += ((my - prevMousePos.y) * MAX_SPEED * 0.2 - vel.y) * 0.1;
				wasMousePressed = true;
			} else {
				if (wasMousePressed) {
					fireLockMissiles();
					wasMousePressed = false;
				}
				angle += normalizeAnglePm(atan2(ox, oy) - angle) * 0.2 * gameSpeed;
				var s:Number = 1.0 - distance(ox, oy) / (SCREEN_WIDTH / 2) 
				if (s < 0.1) s = 0.1;
				var oa:Number = normalizeAnglePm(angle - velAngle);
				velAngle += oa * (MAX_SPEED - speed) / MAX_SPEED * 0.1;
				speed += ((1.0 - s) * MAX_SPEED - speed) * 0.05;
				var sr:Number = 0.1;
				if (s > field.scale) sr = 0.01;
				field.scale += (s - field.scale) * sr;
			}
			if (ticks % 5 == 0) lines.push(new Line(-field.pos.x, -field.pos.y, velAngle, 0));
			ticks++;
		} else {
			speed *= 0.9;
		}
		pos.x += (sin(angle + PI) * speed * 3 - pos.x) * 0.1;
		pos.y += (cos(angle + PI) * speed * 3 - pos.y) * 0.1;
		field.pos.x -= sin(velAngle) * speed * gameSpeed + vel.x;
		field.pos.y -= cos(velAngle) * speed * gameSpeed + vel.y;
		vel.x *= 0.95; vel.y *= 0.95;
		shape.draw(pos.x + SCREEN_WIDTH / 2, pos.y + SCREEN_HEIGHT / 2, angle, field.scale);
		if (isMousePressed) {
			var lx:Number = -field.pos.x, ly:Number = -field.pos.y;
			for (var i:int = 0; i < Missile.LOCK_DISTANCE / (Line.SIZE * 2.5); i++) {
				lx += sin(angle) * Line.SIZE * 2.5; ly += cos(angle) * Line.SIZE * 2.5;
				lines.push(new Line(lx, ly, angle, 2, 1));
			}
		}
		prevMousePos.x = mx; prevMousePos.y = my;
		if (isInGame) {
			shield += 0.02 * gameSpeed; if (shield > 10) shield = 10;
		}
		for (i = 0; i < shield; i++) shieldShape.draw(20 + i * 20, 440, 0, 1);
	}
	public function hit():void {
		playSe(2);
		shield -= 6;
		if (shield <= 0 && isInGame) startGameOver();
	}
}
// Missiles.
var missiles:Vector.<Missile> = new Vector.<Missile>;
class Missile {
	public static const LOCK_DISTANCE:Number = 2560, HIT_DISTANCE:Number = 64;
	private static var shape:VectorShape, lockShape:VectorShape;
	private const RANGE:Number = SCREEN_WIDTH * 7.0;
	public var pos:Vector3D = new Vector3D;
	public var isRemoved:Boolean;
	public var isLocked:Boolean, isFired:Boolean;
	private var angle:Number, speed:Number, angleSpeed:Number;
	private var ticks:int;
	public static function initalize():void {
		shape = new VectorShape(function (g:Graphics):void {
			g.lineStyle(5, 0xffff00, 0.5);
			g.moveTo(0, -16); g.lineTo(-4, 12); g.lineTo(0, 16); g.lineTo(4, 12); g.lineTo(0, -16);
		}, 32, 32, true, true);
		lockShape = new VectorShape(function (g:Graphics):void {
			g.lineStyle(7, 0xff8888, 0.5);
			g.moveTo(-24, -32); g.lineTo(32, -32);
			g.moveTo(32, -24); g.lineTo(0, 32);
			g.moveTo(-4, 32); g.lineTo(-32, -24);
		}, 64, 64, false, true);
	}
	public function Missile():void {
		var a:Number = randn(PI * 2);
		pos.x = -field.pos.x + sin(a) * RANGE;
		pos.y = -field.pos.y + cos(a) * RANGE;
		angle = normalizeAngle(a + PI);
		speed = 24 + randn(10) + randn(10);
		angleSpeed = 0.01 + randn(0.015) + randn(0.015);
	}
	public function update():Boolean {
		if (isRemoved) return false;
		if (ticks % 5 == 0) lines.push(new Line(pos.x, pos.y, angle, 1));
		ticks++;
		pos.x += sin(angle) * speed * gameSpeed;
		pos.y += cos(angle) * speed * gameSpeed;
		var ox:Number = pos.x + field.pos.x, oy:Number = pos.y + field.pos.y;
		var d:Number = distance(ox, oy);
		if (d > RANGE * 5 || d < HIT_DISTANCE) {
			if (d < HIT_DISTANCE) {
				player.hit();
				explosions.push(new Explosion(pos, -1));
			}
			removeLockMissile(this);
			return false;
		}
		var pa:Number = atan2(ox, oy);
		var oa:Number = normalizeAnglePm(pa + PI - angle);
		if (oa > angleSpeed) oa = angleSpeed;
		else if (oa < -angleSpeed) oa = -angleSpeed;
		angle += oa * gameSpeed;
		var sx:Number = ox * field.scale + player.pos.x + SCREEN_WIDTH / 2;
		var sy:Number = oy * field.scale + player.pos.y + SCREEN_HEIGHT / 2;
 		shape.draw(sx, sy, angle, field.scale);
		if (isLocked) {
			lockShape.draw(sx, sy, 0, field.scale);
		} else if (isMousePressed) {
			if (abs(normalizeAnglePm(pa - player.angle)) < 0.1 && d < LOCK_DISTANCE) {
				isLocked = true;
				playSe(0);
			}
		}
		return true;
	}
}
// Player's missiles locking on enemies' missiles.
var lockMissiles:Vector.<LockMissile>;
var enemyScores:Vector.<int> = new Vector.<int>(8);
var nextScoreIndex:int = 0;
class LockMissile {
	private static var shape:VectorShape;
	private static const SPEED:Number = 64, HIT_DISTANCE:Number = 64;
	public var target:Missile;
	private var pos:Vector3D = new Vector3D, speed:Number, angle:Number, angleSpeed:Number;
	private var scoreIndex:int;
	private var ticks:int;
	public static function initalize():void {
		shape = new VectorShape(function (g:Graphics):void {
			g.lineStyle(5, 0x00bbff, 0.5);
			g.moveTo(0, -16);
			g.lineTo(-4, 12);
			g.lineTo(0, 16);
			g.lineTo(4, 12);
			g.lineTo(0, -16);
		}, 32, 32, true, true);
	}
	public function LockMissile(target:Missile):void {
		this.target = target;
		pos.x = -field.pos.x;
		pos.y = -field.pos.y;
		var ox:Number = pos.x - target.pos.x, oy:Number = pos.y - target.pos.y;
		angle = player.angle + normalizeAnglePm(atan2(ox, oy) + PI - player.angle) / 2;
		speed = angleSpeed = 0;
		scoreIndex = nextScoreIndex;
	}
	public function update():Boolean {
		if (ticks % 5 == 0) lines.push(new Line(pos.x, pos.y, angle, 3));
		ticks++;
		speed += (SPEED - speed) * 0.05;
		pos.x += sin(angle) * speed * gameSpeed;
		pos.y += cos(angle) * speed * gameSpeed;
		var ox:Number = pos.x - target.pos.x, oy:Number = pos.y - target.pos.y;
		var d:Number = distance(ox, oy);
		if (d < HIT_DISTANCE) {
			if (isInGame) {
				score += enemyScores[scoreIndex];
				explosions.push(new Explosion(target.pos, enemyScores[scoreIndex]));
				if (enemyScores[scoreIndex] < 6400) enemyScores[scoreIndex] *= 2;
			}
			target.isRemoved = true;
			return false;
		}
		var pa:Number = atan2(ox, oy);
		var oa:Number = normalizeAnglePm(pa + PI - angle);
		if (oa > angleSpeed) oa = angleSpeed;
		else if (oa < -angleSpeed) oa = -angleSpeed;
		angle += oa * gameSpeed;
		ox = pos.x + field.pos.x; oy = pos.y + field.pos.y;
		var sx:Number = ox * field.scale + player.pos.x + SCREEN_WIDTH / 2;
		var sy:Number = oy * field.scale + player.pos.y + SCREEN_HEIGHT / 2;
 		shape.draw(sx, sy, angle, field.scale);
		angleSpeed += 0.002;
		return true;
	}
}
function fireLockMissiles():void {
	var isFiring:Boolean;
	for each (var m:Missile in missiles) {
		if (m.isLocked && !m.isFired) {
			isFiring = true; break;
		}
	}
	if (!isFiring) return;
	playSe(1);
	enemyScores[nextScoreIndex] = 100;
	for each (m in missiles) {
		if (m.isLocked && !m.isFired) {
			lockMissiles.push(new LockMissile(m));
			m.isFired = true;
		}
	}
	nextScoreIndex++; if (nextScoreIndex >= enemyScores.length) nextScoreIndex = 0;
}
function removeLockMissile(m:Missile):void {
	for (var i:int = 0; i < lockMissiles.length; i++) if (lockMissiles[i].target == m) { lockMissiles.splice(i, 1); return; }
}
// Explosion marks.
var explosions:Vector.<Explosion>;
class Explosion {
	private static var shape:VectorShape;
	private var pos:Vector3D = new Vector3D;
	private var score:int, ticks:int;
	public static function initalize():void {
		shape = new VectorShape(function (g:Graphics):void {
			g.lineStyle(7, 0xff0000, 0.5);
			g.moveTo(-32, -32); g.lineTo(32, 32);
			g.moveTo(32, -32); g.lineTo(-32, 32);
		}, 64, 64, false, true);
	}
	public function Explosion(p:Vector3D, score:int):void {
		pos.x = p.x; pos.y = p.y;
		this.score = score;
		ticks = 60;
	}
	public function update():Boolean {
		var ox:Number = pos.x + field.pos.x, oy:Number = pos.y + field.pos.y;
		var sx:Number = ox * field.scale + player.pos.x;
		var sy:Number = oy * field.scale + player.pos.y;
		var ax:Number = abs(sx);
		if (ax > SCREEN_WIDTH * 0.45) {
			sy *= SCREEN_WIDTH * 0.45 / ax;
			if (sx > SCREEN_WIDTH * 0.45) sx = SCREEN_WIDTH * 0.45;
			else sx = -SCREEN_WIDTH * 0.45;
		}
		var ay:Number = abs(sy);
		if (ay > SCREEN_HEIGHT * 0.45) {
			sx *= SCREEN_HEIGHT * 0.45 / ay;
			if (sy > SCREEN_HEIGHT * 0.45) sx = SCREEN_HEIGHT * 0.45;
			else sy = -SCREEN_HEIGHT * 0.45;
		}
		sx += SCREEN_WIDTH / 2; sy += SCREEN_HEIGHT / 2;
		shape.draw(sx, sy, 0, field.scale);
		if (score > 0) cg.print(String(score), sx, sy);
		ticks--;
		return (ticks > 0);
	}
}
// Trail lines.
var lines:Vector.<Line>;
class Line {
	public static const SIZE:Number = 32;
	private static var shapes:Vector.<VectorShape>;
	private var pos:Vector3D = new Vector3D, angle:Number, ticks:int;
	private var colorIndex:int;
	public static function initialize(i:int):void {
		var colors:Array = [ 0x00ff00, 0xffff00, 0xff0000, 0x00bbff ];
		if (shapes == null) shapes = new Vector.<VectorShape>(colors.length);
		shapes[i] = new VectorShape(function (g:Graphics):void {
			g.lineStyle(5, colors[i], 0.5);
			g.moveTo(0, -SIZE);
			g.lineTo(0, SIZE);
		}, SIZE * 2, SIZE * 2, true, true);
	}
	public function Line(x:Number, y:Number, angle:Number, colorIndex:int, ticks:int = 60) {
		pos.x = x; pos.y = y;
		this.angle = angle; this.colorIndex = colorIndex;
		this.ticks = ticks;
	}
	public function update():Boolean {
		var ox:Number = pos.x + field.pos.x, oy:Number = pos.y + field.pos.y;
		shapes[colorIndex].draw(ox * field.scale + player.pos.x + SCREEN_WIDTH / 2, oy * field.scale + player.pos.y + SCREEN_HEIGHT / 2, angle, field.scale);
		ticks--;
		return (ticks > 0);
	}
}
// Scrolling game field.
var field:Field;
class Field {
	private const GRID_SIZE:Number = 400;
	public var pos:Vector3D = new Vector3D, scale:Number;
	private var wShape:VectorShape, hShape:VectorShape;
	public function Field() {
		wShape = new VectorShape(function (g:Graphics):void {
			g.lineStyle(3, 0x008800, 0.25);
			g.moveTo(-SCREEN_WIDTH / 2, 0); g.lineTo( SCREEN_WIDTH / 2, 0);
		}, SCREEN_WIDTH, 3, false, false);
		hShape = new VectorShape(function (g:Graphics):void {
			g.lineStyle(3, 0x008800, 0.25);
			g.moveTo(0, -SCREEN_HEIGHT / 2); g.lineTo(0,  SCREEN_HEIGHT / 2);
		}, 3, SCREEN_HEIGHT, false, false);
	}
	public function initialize():void {
		pos.x = pos.y = 0;
		scale = 0.1;
	}
	public function draw():void {
		var s:Number = GRID_SIZE * scale;
		var x:Number = ((pos.x % GRID_SIZE) * scale + player.pos.x + SCREEN_WIDTH / 2) % s - s;
		for (; x < SCREEN_WIDTH + s; x += s) hShape.draw(x, SCREEN_HEIGHT / 2);
		var y:Number = ((pos.y % GRID_SIZE) * scale + player.pos.y + SCREEN_HEIGHT / 2) % s - s;
		for (; y < SCREEN_HEIGHT + s; y += s) wShape.draw(SCREEN_WIDTH / 2, y);
	}
}
const POLICY_FILE:String = "http://abagames.sakura.ne.jp/crossdomain.xml";
const SOUNDS_URL:String = "http://abagames.sakura.ne.jp/sounds/dance_on_radar/";
const BGM_FILE:String = "missiles_on_radar.mp3";
var seFiles:Array = ["lock.mp3", "missile.mp3", "explosion.mp3"];
import flash.display.*;
import flash.filters.*;
import flash.geom.*;
import flash.events.*;
import flash.text.*;
import flash.media.*;
import flash.net.*;
import flash.system.Security;
// Initialize a bitmapdata and events.
const SCREEN_WIDTH:int = 465;
const SCREEN_HEIGHT:int = 465;
var main:Main, bd:BitmapData, isMousePressed:Boolean;
function initializeFirst():void {
	bd = new BitmapData(SCREEN_WIDTH, SCREEN_HEIGHT, false);
	bd.fillRect(bd.rect, 0);
	main.addChild(new Bitmap(bd));
	main.stage.addEventListener(MouseEvent.MOUSE_DOWN, function (e:Event):void { isMousePressed = true; });
	main.stage.addEventListener(MouseEvent.MOUSE_UP, function (e:Event):void { isMousePressed = false; });
	main.addEventListener(Event.ENTER_FRAME, updateFrame);
}
// Update the frame.
function updateFrame(event:Event):void {
	bd.fillRect(bd.rect, 0);
	if (initializePhase >= 0) {
		initialize();
		return;
	}
	if (!isSoundsReady) return;
	bd.lock();
	if (isInGame) update();
	else if (isTitle) updateTitle();
	else updateGameOver();
	bd.unlock();
	updateSound();
	if (gameOverTicks > 0) {
		gameOverTicks--;
		if (gameOverTicks == 0) startTitle();
	}
	if (!isInGame && gameOverTicks < GAME_OVER_DURATION - 30 && isMousePressed) startGame();
}
// Handle game state (Title/In game/Game over).
const GAME_OVER_DURATION:int = 180;
var gameOverTicks:int, score:int;
function startTitle():void {
	initializeTitle();
	gameOverTicks = 0;
}
function startGame():void {
	initializeGame();
	score = 0;
	gameOverTicks = -1;
}
function startGameOver():void {
	initalizeGameOver();
	gameOverTicks = GAME_OVER_DURATION;
}
function get isInGame():Boolean {
	return (gameOverTicks < 0);
}
function get isTitle():Boolean {
	return (gameOverTicks == 0);
}
// Vector shape.
class VectorShape {
	private const ROTATION_COUNT:int = 32, SCALE_COUNT:int = 16;
	private var isRotative:Boolean;
	private var bds:Vector.<BitmapData> = new Vector.<BitmapData>;
	private var rect:Rectangle;
	private var scaleIndexOffset:int = 1;
	private var point:Point = new Point;
	public function VectorShape(df:Function, w:Number, h:Number, isRotative:Boolean, isScalable:Boolean) {
		var bdsCount:int = 1;
		if (isRotative) {
			bdsCount *= ROTATION_COUNT;
			scaleIndexOffset = ROTATION_COUNT;
		}
		if (isScalable) bdsCount *= SCALE_COUNT;
		var angle:Number = 0, scale:Number = 1;
		for (var i:int = 0; i < bdsCount; i++) {
			bds.push(createBitmapData(df, w, h, angle, scale));
			if (isRotative) {
				angle += 360.0 / ROTATION_COUNT;
				if (angle >= 360 - 1) angle = 0;
			}
			if (isScalable && angle == 0) {
				scale -= 1.0 / SCALE_COUNT;
			}
		}
		rect = bds[0].rect;
	}
	public function draw(x:int, y:int, angle:Number = 0.0, scale:Number = 1.0):void {
		var i:int = normalizeAngle(angle) / (PI * 2 / ROTATION_COUNT) + int((1.0 - scale) / (1.0 / SCALE_COUNT)) * scaleIndexOffset;
		if (i >= bds.length) return;
		point.x = x - rect.width / 2; point.y = y - rect.height / 2;
		bd.copyPixels(bds[i], rect, point);
	}
}
// Create a vector bitmap data.
const BLUR_SIZE:int = 48, BLUR_SIZE_SKIP:int = 4;
var blurs:Vector.<BlurFilter>;
function initializeBlurs():void {
	blurs = new Vector.<BlurFilter>(BLUR_SIZE / BLUR_SIZE_SKIP);
	for (var i:int = BLUR_SIZE_SKIP; i < BLUR_SIZE; i += BLUR_SIZE_SKIP) {
		var blur:BlurFilter = new BlurFilter;
		blur.blurX = blur.blurY = i;
		blurs[i / BLUR_SIZE_SKIP] = blur;
	}
}
function createBitmapData(df:Function, w:Number, h:Number, angle:Number, scale:Number):BitmapData {
	var bd:BitmapData = new BitmapData(w + BLUR_SIZE * 2, h + BLUR_SIZE * 2, true, 0);
	var bs:Sprite = new Sprite;
	var s:Shape = new Shape;
	bs.addChild(s);
	s.x = w / 2 + BLUR_SIZE; s.y = h / 2 + BLUR_SIZE;
	var g:Graphics = s.graphics;
	df(g);
	bd.lock();
	for (var i:int = 0; i < BLUR_SIZE / BLUR_SIZE_SKIP; i++) {
		s.rotation = 180 - angle;
		s.scaleX = s.scaleY = scale;
		if (i > 0) bs.filters = [blurs[i]];
		bd.draw(bs);
	}
	bd.unlock();
	return bd;
}
// Character graphics plane.
var cg:Cg;
class Cg {
	public static const PIXEL_WIDTH:int = 9, PIXEL_HEIGHT:int = int(PIXEL_WIDTH * 1.4);
	public static const strings:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()_+-=[]\\{}|;':\",./<>?";
	private var bds:Vector.<BitmapData> = new Vector.<BitmapData>;
	private var rect:Rectangle = new Rectangle(0, 0, PIXEL_WIDTH * 1.4 + BLUR_SIZE * 2, PIXEL_HEIGHT * 1.4 + BLUR_SIZE * 2);
	public function Cg() {
		for (var i:int = 0; i < strings.length; i++) {
			var bd:BitmapData = createCharacterBitmapData(strings.charAt(i));
			bds.push(bd);
		}
	}
	public function print(s:String, x:Number, y:Number):void {
		var p:Point = new Point;
		p.x = x - BLUR_SIZE; p.y = y - BLUR_SIZE;
		for (var i:int = 0; i < s.length; i++, p.x += PIXEL_WIDTH) {
			var c:int = strings.indexOf(s.charAt(i));
			if (c >= 0) bd.copyPixels(bds[c], rect, p);
		}
	}
}
// Create a character bitmap data.
function createCharacterBitmapData(c:String):BitmapData {
	var bd:BitmapData = new BitmapData(Cg.PIXEL_WIDTH * 1.4 + BLUR_SIZE * 2, Cg.PIXEL_HEIGHT * 1.4 + BLUR_SIZE * 2, true, 0);
	var bs:Sprite = new Sprite;
	var t:TextField = createTextField(0, 0, Cg.PIXEL_WIDTH + 1, bd.rect.width, bd.rect.height, 0x00ff00);
	t.text = c;
	var tm:TextLineMetrics = t.getLineMetrics(0);
	var ofs:Number = Number(Cg.PIXEL_WIDTH - tm.width) / 2;
	var tbd:BitmapData = new BitmapData(Cg.PIXEL_WIDTH * 1.4, Cg.PIXEL_HEIGHT * 1.4, true, 0);
	tbd.draw(t);
	var b:Bitmap = new Bitmap(tbd);
	b.blendMode = BlendMode.ADD;
	bs.addChild(b);
	b.x = ofs + BLUR_SIZE; b.y = BLUR_SIZE;
	bd.lock();
	for (var i:int = 0; i < BLUR_SIZE / BLUR_SIZE_SKIP; i++) {
		if (i > 0) bs.filters = [blurs[i]];
		bd.draw(bs);
	}
	bd.unlock();
	return bd;
}
// BGM an SEs.
var bgm:Sound, isSoundsReady:Boolean, bgmChannel:SoundChannel, bgmTransform:SoundTransform;
var ses:Vector.<Sound> = new Vector.<Sound>;
var isBgmFadingOut:Boolean;
function initializeSounds():void {
	Security.loadPolicyFile(POLICY_FILE);
	for each (var sef:String in seFiles) {
		var se:Sound = new Sound;
		se.load(new URLRequest(SOUNDS_URL + sef));
		ses.push(se);
	}
	bgm = new Sound();
	bgmTransform = new SoundTransform;
	bgm.addEventListener(Event.COMPLETE, function(e:Event):void { isSoundsReady = true; } );
	bgm.load(new URLRequest(SOUNDS_URL + BGM_FILE));
}
function playBgm():void {
	bgmTransform.volume = 1.0; isBgmFadingOut = false;
	bgmChannel = bgm.play(0, int.MAX_VALUE, bgmTransform);
}
function fadeOutBgm():void {
	if (bgmChannel == null) return;
	isBgmFadingOut = true;
}
function stopBgm():void {
	if (bgmChannel == null) return;
	bgmChannel.stop();
	bgmChannel = null;
}
function playSe(index:int):void {
	ses[index].play();
}
function updateSound():void {
	if (bgmChannel == null || !isBgmFadingOut) return;
	bgmTransform.volume -= 0.015;
	bgmChannel.soundTransform = bgmTransform;
	if (bgmTransform.volume <= 0.05) stopBgm();
}
// Utility functions.
var sin:Function = Math.sin, cos:Function = Math.cos, atan2:Function = Math.atan2; 
var sqrt:Function = Math.sqrt, abs:Function = Math.abs, PI:Number = Math.PI;
function createTextField(x:int, y:int, size:int, width:int, height:int, color:int):TextField {
	var fm:TextFormat = new TextFormat, fi:TextField = new TextField;
	fm.size = size; fm.color = color; fm.leftMargin = 0;
	fi.defaultTextFormat = fm; fi.x = x; fi.y = y; fi.width = width; fi.height = height; fi.selectable = false;
	return fi;
}
function randi(n:int):int {
	return Math.random() * n;
}
function randn(n:int):Number {
	return Math.random() * n;
}
function normalizeAngle(a:Number):Number {
	if (a >= PI * 2) return a % (PI * 2);
	else if (a < 0) return PI * 2 + a % (PI * 2);
	return a;
}
function normalizeAnglePm(a:Number):Number {
	a = normalizeAngle(a);
	if (a > PI) return a - PI * 2;
	return a;
}
function distance(x:Number, y:Number):Number {
	return sqrt(x * x + y * y);
}
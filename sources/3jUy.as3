// SslbParser
//  Sslb (Shmup Specific Language:Bullet) parser.
//  <Operation>
//   Mouse: Move your ship.
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
import org.si.sion.*;
import org.si.sion.utils.*;
const SCREEN_WIDTH:int = 465, SCREEN_HEIGHT:int = 465;
var sslbRoot:String = (<![CDATA[
nway 1..12 30__90
 nwayslide $1 $2 0
nwayslide 1..12 10__90 0.2__0.5
 fire -$2 -$3
 repeat $1
  fire $2*2/$1 $3*2/($1-1)
nwayturn 1..12 30__90*-1|1 1..6
 fire -$2
 repeat $1
  wait $3
  fire $2*2/$1
nwayturncenter 1..12 30__120*-1|1 1..6
 fire
 repeat $1
  wait $3
  fire $2/$1
nwayturntoandfrom 1..12 30__120*-1|1 1..6
 fire -$2
 repeat $1
  wait $3
  fire $2*2/$1
 repeat $1
  wait $3
  fire -$2*2/$1
wedge 1..6 30__120 0.2__0.5*-1|1
 fire -$2 -$3
 repeat $1
  fire $2/$1 $3*2/$1
 repeat $1
  fire $2/$1 -$3*2/$1
round 3..32
 repeat $1
  fire 360/$1
roundturn 3..32 1..4 -1|1
 fire
 repeat $1
  wait $2
  fire 360/$1*$3
]]>).toString();
var sslbBranch:String = (<![CDATA[
bar 2..6 3..8
 speed 0
 whip $1 $2
whip 2..6 3..8 0.2__0.6
 fire 0 -$3
 repeat $1
  wait $2
  fire 0 $3*2/$1
shotside 3..12
 fire 90
  vanish
 repeat inf
  wait $1
  fire 180
  fire 180
shotaim 3..12
 repeat inf
  wait $1
  fireaim 0
shotslow 3..12
 wait $1
 fire 0 -0.5
 repeat inf
  wait $1
  fire
changespeed 0.4__0.8*-1|1 5..30
 speed 1+$1 $2
curve 2__10*-1|1 20..60
 angvel $1 $2
]]>).toString();
var main:Main, stage:Stage, screen:BitmapData;
var point:Point = new Point;
var commands:Array = new Array;
var rootCommands:Vector.<Command> = new Vector.<Command>;
var branchCommands:Vector.<Command> = new Vector.<Command>;
var sslbTextField:TextField;
var driver:SiONDriver = new SiONDriver();
var percusVoices:Array = new SiONPresetVoice()["valsound.percus"];
var drum1:SiONData, drum2:SiONData, drum3:SiONData;
// Initialize.
function initialize():void {
	stage = main.stage;
	var sslbXmls:Vector.<XML>;
	sslbXmls = parseIndentedText(sslbRoot);
	for each (var sslb:XML in sslbXmls) {
		var c:Command = new Command(sslb);
		commands[c.name] = c;
		rootCommands.push(c);
		branchCommands.push(c);
	}
	sslbXmls = parseIndentedText(sslbBranch);
	for each (sslb in sslbXmls) {
		c = new Command(sslb);
		commands[c.name] = c;
		branchCommands.push(c);
	}
	Bullet.initialize();
	drum1 = createDrum(14); drum2 = createDrum(27); drum3 = createDrum(0);
	screen = new BitmapData(SCREEN_WIDTH, SCREEN_HEIGHT, false);
	sslbTextField = createTextField(0, 0, SCREEN_WIDTH / 2, SCREEN_HEIGHT, 0xffffff);
	main.addChild(new Bitmap(screen));
	main.addChild(sslbTextField);
	main.addEventListener(Event.ENTER_FRAME, update);
}
// Update the frame.
const MAX_SSLB_COUNT:int = 2;
var ticks:int = 0;
var rootCommand:Command;
var addCommandFlags:Vector.<Boolean> = new Vector.<Boolean>(MAX_SSLB_COUNT), childCommands:Vector.<Command>;
function update(event:Event):void {
	var t:int = ticks % 60;
	if (t == 0) {
		rootCommand = rootCommands[randi(rootCommands.length)];
		childCommands  = new Vector.<Command>;
		for (var i:int = 0; i < MAX_SSLB_COUNT; i++) addCommandFlags[i] = (randi(2) == 0);
		sslbTextField.text = rootCommand.toString();
		driver.play(drum1);
	} else if (t % 7 == 0) {
		var at:int = t / 7 - 1;
		if (at < MAX_SSLB_COUNT && addCommandFlags[at]) {
			var c:Command = branchCommands[randi(branchCommands.length)].getRandomFixedClone();
			childCommands.push(c);
			sslbTextField.appendText(c.toString());
			driver.play(drum3);
		}
	} else if (t % 60 == 30) {
		var p:Vector3D = new Vector3D(SCREEN_WIDTH / 2, SCREEN_HEIGHT * 0.2);
		var a:Number;
		if (randi(2) == 0) a = getPlayerAngle(p);
		else a = randn(PI) - PI / 2;
		addBullet(p, a, 5, true, rootCommand, null, childCommands);
		driver.play(drum2);
	}
	ticks++;
	for (i = 0; i < bullets.length; i++) if (!bullets[i].update()) { bullets.splice(i, 1); i--; }
	if (bullets.length >= MAX_BULLET_COUNT) bullets.splice(MAX_BULLET_COUNT, bullets.length - MAX_BULLET_COUNT);
	screen.lock();
	screen.fillRect(screen.rect, 0);
	for each (var b:Bullet in bullets) b.drawBlur();
	player.update();
	for each (b in bullets) b.draw();
	screen.unlock();
}
// Player.
var player:Player = new Player;
class Player {
	private const HIT_RANGE:Number = 5;
	public var pos:Vector3D = new Vector3D;
	private var bd:BitmapData, bdRect:Rectangle;
	private var invincibleTicks:int = 60;
	public function Player() {
		pos.x = SCREEN_WIDTH / 2; pos.y = SCREEN_HEIGHT * 0.75;
		bd = createCircleBitmapData(12, 0x88, 0xff, 0xcc, 0.8, 3, 7);
		bdRect = bd.rect;
	}
	public function update():void {
		pos.x += (stage.mouseX - pos.x) * 0.2;
		pos.y += (stage.mouseY - pos.y) * 0.2;
		point.x = pos.x - bdRect.width / 2; point.y = pos.y - bdRect.height / 2;
		if (invincibleTicks >= 0) {
			invincibleTicks--;
			if (invincibleTicks % 15 < 7) return;
		}
		screen.copyPixels(bd, bdRect, point);
	}
	public function checkHit(p:Vector3D):void {
		if (invincibleTicks < 0 && Vector3D.distance(pos, p) < HIT_RANGE) {
			invincibleTicks = 60;
			for (var i:int = 0; i < 64; i++) {
				bullets.push(new Bullet(pos, randn(PI * 2), randn(10) + 10, false, null, null, null, true));
			}
		}
	}
}
function getPlayerAngle(p:Vector3D):Number {
	return atan2(player.pos.x - p.x, player.pos.y - p.y);
}
// Bullets.
const MAX_BULLET_COUNT:int = 256, MAX_TICKS:int = 30 * 5;
var bullets:Vector.<Bullet> = new Vector.<Bullet>;
class Bullet {
	private static var bd:BitmapData, bdRect:Rectangle;
	private static var fragmentBd:BitmapData, fragmentBdRect:Rectangle;
	private static var blurBds:Vector.<BitmapData> = new Vector.<BitmapData>;
	private static var blurRects:Vector.<Rectangle> = new Vector.<Rectangle>;
	private static const BLUR_SIZE_COUNT:int = 7, BLUR_COLOR_COUNT:int = 8;
	public var pos:Vector3D;
	public var angle:Number, speed:Number;
	public var runState:RunState;
	public var isRemoving:Boolean;
	public var childCommands:Vector.<Command>;
	private var isRoot:Boolean, ticks:int;
	private var isFragment:Boolean;
	public static function initialize():void {
		bd = createCircleBitmapData(10, 0xaa, 0x77, 0xdd, 0.75, 1, 8);
		bdRect = bd.rect;
		fragmentBd = createCircleBitmapData(8, 0xdd, 0xcc, 0x66, 0.5, 8, 4);
		fragmentBdRect = fragmentBd.rect;
		bdRect = bd.rect;
		for (var i:int = 0; i < BLUR_SIZE_COUNT; i++) {
			var radius:Number = (BLUR_SIZE_COUNT - i) * 2, a:Number = 0.5 - i * 0.05;
			for (var j:int = 0; j < BLUR_COLOR_COUNT; j++) {
				var r:int = 0xff - j * 0x11;
				var b:int = 0x88;
				var bbd:BitmapData = createCircleBitmapData(radius, r, 0, b, a, 5);
				blurBds.push(bbd);
				blurRects.push(bbd.rect);
			}
		}
	}
	public function Bullet(p:Vector3D, angle:Number, speed:Number, isRoot:Boolean,
			command:Command, vars:Vector.<Number>, ccs:Vector.<Command>, isFragment:Boolean = false) {
		pos = new Vector3D(p.x, p.y);
		this.angle = angle; this.speed = speed;
		this.isRoot = isRoot;
		this.isFragment = isFragment;
		if (command == null && ccs != null && ccs.length > 0) {
			command = ccs[0];
			childCommands = new Vector.<Command>;
			for (var i:int = 1; i < ccs.length; i++) childCommands.push(ccs[i]);
			vars = null;
			isRoot = true;
		} else {
			childCommands = ccs;
		}
		if (command != null) runState = new RunState(this, command, vars);
	}
	public function update():Boolean {
		if (runState != null) {
			if (!runState.isEnded) runState.update();
			else if (isRoot) return false;
			if (isRemoving) return false;
		}
		if (!isRoot) {
			pos.x += sin(angle) * speed; pos.y += cos(angle) * speed;
			player.checkHit(pos);
		}
		ticks++;
		return (pos.x >= 0 && pos.x <= SCREEN_WIDTH && pos.y >= 0 && pos.y <= SCREEN_HEIGHT && ticks < MAX_TICKS);
	}
	public function draw():void {
		if (isRoot) return;
		if (!isFragment)  {
			point.x = pos.x - bdRect.width / 2; point.y = pos.y - bdRect.height / 2;
			screen.copyPixels(bd, bdRect, point);
		} else {
			point.x = pos.x - fragmentBdRect.width / 2; point.y = pos.y - fragmentBdRect.height / 2;
			screen.copyPixels(fragmentBd, fragmentBdRect, point);
		}
	}
	public function drawBlur():void {
		if (isRoot || isFragment) return;
		var px:Number = pos.x, py:Number = pos.y;
		var vx:Number = sin(angle) * speed * 2;
		var vy:Number = cos(angle) * speed * 2;
		var t:int = ticks;
		for (var i:int = 0; i < BLUR_SIZE_COUNT; i++) {
			if (t-- <= 0) break;
			var c:int  = t % (BLUR_COLOR_COUNT * 2);
			if (c >= BLUR_COLOR_COUNT) c = BLUR_COLOR_COUNT * 2 - c - 1;
			var bi:int = c + i * BLUR_COLOR_COUNT;
			point.x = px - blurRects[bi].width / 2;
			point.y = py - blurRects[bi].height / 2;
			screen.copyPixels(blurBds[bi], blurRects[bi], point);
			px -= vx; py -= vy;
		}
	}
}
function addBullet(p:Vector3D, angle:Number, speed:Number, isRoot:Boolean,
		command:Command, vars:Vector.<Number>, ccs:Vector.<Command>):void {
	bullets.push(new Bullet(p, angle, speed, isRoot, command, vars, ccs));
}
// Sslb run state.
class RunState {
	public var bullet:Bullet;
	public var fireAngle:Number, fireSpeed:Number, fireBaseSpeed:Number;
	public var speedVel:Number, speedVelTicks:int;
	public var angVel:Number, angVelTicks:int;
	public var waitTicks:int;
	private var states:Vector.<ScopeState> = new Vector.<ScopeState>;
	private var current:ScopeState;
	public function RunState(bullet:Bullet, root:Command, vars:Vector.<Number>) {
		this.bullet = bullet;
		fireAngle = bullet.angle; fireSpeed = fireBaseSpeed = bullet.speed;
		current = new ScopeState(root, vars, 1, this);
	}
	public function update():void {
		if (speedVelTicks > 0) {
			bullet.speed += speedVel;
			speedVelTicks--;
		}
		if (angVelTicks > 0) {
			bullet.angle += angVel;
			angVelTicks--;
		}
		if (waitTicks > 0) {
			waitTicks--;
			return;
		}
		if (current != null) current.update();
	}
	public function pushCurrent(newState:ScopeState):void {
		states.push(current);
		current = newState;
		update();
	}
	public function popCurrent():void {
		if (states.length <= 0)	{
			current = null;
			return;
		}
		current = states.pop();
		update();
	}
	public function get isEnded():Boolean {
		return current == null && speedVelTicks <= 0 && angVelTicks <= 0;
	}
}
class ScopeState {
	private var runState:RunState, bullet:Bullet;
	private var command:Command;
	private var vars:Vector.<Number> = new Vector.<Number>;
	private var programCount:int, repeatCount:int;
	public function ScopeState(command:Command, vs:Vector.<Number>, repeatCount:int, runState:RunState) {
		this.runState = runState; bullet = runState.bullet; 
		this.command = command;
		this.repeatCount = repeatCount;
		var vc:int = 0;
		if (vs != null) {
			for each (var v:Number in vs) {
				vars.push(v);
				vc++;
			}
		}
		for (var i:int = vc; i < command.args.length; i++) vars.push(command.args[i].calc(vars));
	}
	public function update():void {
		if (programCount >= command.children.length) {
			repeatCount--;
			if (repeatCount <= 0) {
				runState.popCurrent();
				return;
			} else {
				programCount = 0;
			}
		}
		var c:Command = command.children[programCount];
		programCount++;
		var cn:String = c.name;
		if (cn == "fire" || cn == "fireaim") {
			if (bullet.pos.y < SCREEN_HEIGHT / 2) {
				var al:int = c.args.length;
				if (al > 0) {
					if (cn == "fire") runState.fireAngle += c.args[0].calc(vars) * PI / 180;
					else runState.fireAngle =
						getPlayerAngle(bullet.pos) + c.args[0].calc(vars) * PI / 180;
				}
				if (al > 1) runState.fireSpeed += runState.fireBaseSpeed * c.args[1].calc(vars);
				var command:Command;
				if (c.children.length > 0) command = c;
				addBullet(bullet.pos, runState.fireAngle, runState.fireSpeed,
					false, command, vars, bullet.childCommands);
			}
		} else if (cn == "repeat") {
			runState.pushCurrent(new ScopeState(c, vars, c.args[0].calc(vars), runState));
			return;
		} else if (cn == "wait") {
			runState.waitTicks = c.args[0].calc(vars);
			if (runState.waitTicks > 0) return;
		} else if (cn == "vanish") {
			if (c.args.length <= 0 || c.args[0].calc(vars) <= 0) bullet.isRemoving = true;
		} else if (cn == "angvel") {
			runState.angVel = c.args[0].calc(vars) * PI / 180;
			if (c.args.length > 1) runState.angVelTicks = c.args[1].calc(vars);
			else runState.angVelTicks = 9999999;
		} else if (cn == "speed") {
			var ts:Number = c.args[0].calc(vars);
			var t:int = 1;
			if (c.args.length > 1) t = c.args[1].calc(vars);
			runState.speedVel = bullet.speed * (ts - 1) / t;
			runState.speedVelTicks = t;
		} else {
			var vs:Vector.<Number> = new Vector.<Number>;
			for each (var arg:Expression in c.args) vs.push(arg.calc(vars));
			runState.pushCurrent(new ScopeState(commands[cn], vs, 1, runState));
			return;
		}
		update();
	}
}
// Sslb command.
class Command {
	public var name:String;
	public var args:Vector.<Expression> = new Vector.<Expression>;
	public var children:Vector.<Command> = new Vector.<Command>;
	public var value:XML;
	public function Command(v:XML) {
		value = v;
		name = v.name();
		for each (var a:String in v._arg) args.push(new Expression(a));
		if (v._line.length() >= 1)
			for each (var l:XML in v._line[0].children()) children.push(new Command(l));
	}
	public function getRandomFixedClone():Command {
		var c:Command = new Command(value);
		c.fixRandom();
		return c;
	}
	public function fixRandom():void {
		for each (var a:Expression in args) a.fixRandom();
		for each (var c:Command in children) c.fixRandom();
	}
	public function toString(indent:int = 0):String {
		var s:String = "";
		for (var i:int = 0; i < indent; i++) s += " ";
		s += name + " ";
		for each (var a:Expression in args) s += a.str + " ";
		s += "\n";
		for each (var c:Command in children) s += c.toString(indent + 1);
		return s;
	}
}
// Expression.
class Expression {
	private static const PLUS:int = -1, MINUS:int = -2, MULTIPLE:int = -3, DIVISION:int = -4, MODULO:int = -5;
	private static const INT_RAND:int = -6, NUMBER_RAND:int = -7, OR_RAND:int = -8, VARIABLE:int = -9;
	public var str:String;
	private var operator:Vector.<int> = new Vector.<int>;
	private var value:Vector.<Number> = new Vector.<Number>;
	public function Expression(s:String) {
		str = s;
		removeWhiteSpace();
		parseToRPN(0, str.length);
	}
	public function calc(vars:Vector.<Number>):Number {
		var stack:Vector.<Number> = new Vector.<Number>;
		for each (var op:int in operator) {
			if (op >= 0) {
				stack.push(value[op]);
			} else if (op <= VARIABLE) {
				stack.push(vars[VARIABLE - op]);
			} else {
				switch(op) {
				case PLUS: case MINUS: case MULTIPLE: case DIVISION: case MODULO:
				case INT_RAND: case NUMBER_RAND: case OR_RAND:
					var n1:Number = stack.pop();
					var n2:Number = stack.pop();
					stack.push(calcOperator(op, n2, n1));
					break;
				default:
					throw new Error("illegal operator: " + op);
				}
			}
		}
		return stack.pop();
	}
	public function fixRandom():void {
		for (var i:int = 0; i < operator.length; i++) {
			var op:int = operator[i];
			if (op == INT_RAND || op == NUMBER_RAND || op == OR_RAND) {
				var i1:int = operator[i - 1];
				var i2:int = operator[i - 2];
				if (i1 >= 0 && i2 >= 0) {
					var n1:Number = value[i1];
					var n2:Number = value[i2];
					var ni:int = value.push(calcOperator(op, n1, n2)) - 1;
					i -= 2;
					operator[i] = ni;
					operator.splice(i + 1, 2);
				}
			}
		}
	}
	private function removeWhiteSpace():void {
		var cs:String = new String;
		var skip:Boolean = false;
		var depth:int = 0;
		for (var i:int = 0; i < str.length; i++) {
			switch (str.charAt(i)) {
			case ' ':
			case '\n':
			case '\r':
				skip = true;
				break;
			case ')':
				depth--;
				if ( depth < 0 ) throw new Error("bracket not match");
				break;
			case '(':
				depth++;
				break;
			}
			if (skip)
				skip = false;
			else
				cs += str.charAt(i);
		}
		if (depth != 0) throw new Error("bracket not match");
		str = cs;
	}
	private function parseToRPN(stIdx:int, edIdx:int):void {
		var op0:int = -1, op1:int = -1, op2:int = -1;
		for (var i:int = edIdx - 1; i >= stIdx; i--) {
			var c:String = str.charAt(i);
			if (c == ')') {
				var bc:int = 1;
				do {
					i--;
					if (str.charAt(i) == ')') bc++;
					else if (str.charAt(i) == '(') bc--;
				} while (bc > 0);
			} else if (op0 < 0 && (c == '.' || c == '_' || c == '|')) {
				if (c == '.' || c == '_') {
					var c2:String = str.charAt(i - 1);
					if ((c == '.' && c2 != '.')	|| (c == '_' && c2 != '_')) continue;
					i--;
				}
				op0 = i;
			} else if (op1 < 0 && (c == '*' || c == '/' || c == '%')) {
				op1 = i;
			} else if (op2 < 0 && (c == '+' || c == '-')) {
				op2 = i;
			}
		}
		if (op0 < 0 && op1 < 0 && op2 < 0 && str.charAt(stIdx) == '(' && str.charAt(edIdx - 1) == ')') {
			parseToRPN(stIdx + 1, edIdx - 1);
			return;
		}
		if (op2 == stIdx) {
			if (op0 < 0 && op1 < 0) {
				switch (str.charAt(op2)) {
				case '-':
					parseToRPN(stIdx + 1, edIdx);
					pushNumber(-1);
					pushOperator(MULTIPLE);
					break;
				case '+':
					parseToRPN(stIdx + 1, edIdx);
					break;
				default:
					throw new Error("unknown unary operator: " + str.charAt(op2));
				}
				return;
			} else {
				op2 = -1;
			}
		}
		if (op2 >= 0) {
			c = str.charAt(op2 - 1);
			if (c == '+' || c == '-' || c == '*' || c == '/' || c == '%' || c == '.' || c == '_' || c == '|')
				op2 = -1;
		}
		if (op2 < 0) {
			if (op1 < 0) {
				if (op0 < 0) {
					parseFloatValue(stIdx, edIdx - stIdx);
				} else {
					parseToRPN(stIdx, op0);
					var ni:int = 1;
					c = str.charAt(op0);
					if (c == '.' || c =='_') ni = 2;
					parseToRPN(op0 + ni, edIdx);
					switch(c) {
					case '.': operator.push(INT_RAND); break;
					case '_': operator.push(NUMBER_RAND); break;
					case '|': operator.push(OR_RAND); break;
					default: throw new Error("unknown operator: " + str.charAt(op0));
					}
				}
			} else {
				parseToRPN(stIdx, op1);
				c = str.charAt(op1);
				parseToRPN(op1 + 1, edIdx);
				switch(c) {
				case '*': pushOperator(MULTIPLE); break;
				case '/': pushOperator(DIVISION); break;
				case '%': pushOperator(MODULO); break;
				default: throw new Error("unknown operator: " + str.charAt(op1));
				}
			}
		} else {
			parseToRPN(stIdx, op2);
			parseToRPN(op2 + 1, edIdx);
			switch(str.charAt(op2)) {
			case '+': pushOperator(PLUS); break;
			case '-': pushOperator(MINUS); break;
			default: throw new Error("unknown operator: " + str.charAt(op2));
			}
		}
	}
	private function parseFloatValue(stIdx:int, lgt:int):void {
		if (str.charAt(stIdx) == '$') {
			var label:String = str.substr(stIdx + 1, lgt - 1);
			var nidx:Number = parseInt(label);
			if (isNaN(nidx)) throw new Error("illegal variable: $" + label);
			var idx:int = nidx;
			idx--;
			pushVariable(VARIABLE - idx);
		} else {
			var s:String = str.substr(stIdx, lgt);
			if (s == "inf") {
				pushNumber(9999999);
			} else {
				var v:Number = Number(s);
				if (isNaN(v)) throw new Error ("illegal number: " + str.substr(stIdx, lgt));
				pushNumber(v);
			}
		}
	}
	private function pushOperator(op:int):void {
		var idx:int = operator.length;
		if (operator[idx - 2] >= 0 && operator[idx - 1] >= 0) {
			var i1:int = operator.pop();
			var i2:int = operator.pop();
			var n1:Number = value[i1];
			var n2:Number = value[i2];
			if (i1 > i2) {
				value.splice(i1, 1);
				value.splice(i2, 1);
			} else {
				value.splice(i2, 1);
				value.splice(i1, 1);
			}
			var ni:int = value.push(calcOperator(op, n2, n1)) - 1;
			operator.push(ni);
		} else {
			operator.push(op);
		}
	}
	private function pushVariable(vi:int):void {
		operator.push(vi);
	}
	private function pushNumber(n:Number):void {
		var ni:int = value.push(n) - 1;
		operator.push(ni);
	}
	private function calcOperator(op:int, n1:Number, n2:Number):Number {
		switch (op) {
		case PLUS:			return n1 + n2;
		case MINUS:			return n1 - n2;
		case MULTIPLE:		return n1 * n2;
		case DIVISION:		return n1 / n2;
		case MODULO:		return n1 % n2;
		case INT_RAND:		return randi(n2 - n1) + n1;
		case NUMBER_RAND:	return randn(n2 - n1) + n1;
		case OR_RAND:		return (randi(2) == 0 ? n1 : n2);
		default:			throw new Error("illegal operator: " + op);
		}
	}
}
// Indented text parser.
function parseIndentedText(s:String):Vector.<XML> {
	var indentSpaceCounts:Vector.<int> = new Vector.<int>;
	var indentSpaceCount:int = 0;
	var parentXmls:Vector.<XML> = new Vector.<XML>;
	indentSpaceCounts.push(indentSpaceCount);
	var lines:Array = s.split("\r\n").join("\n").split("\n");
	var texts:Vector.<XML> = new Vector.<XML>;
	var parent:XML, current:XML;
	for each (var line:String in lines) {
		var l:String = trimStart(line);
		if (l.length <= 0) continue;
		var strs:Array = l.split(" ");
		var isc:int = line.length  - l.length;
		if (isc > indentSpaceCount) {
			indentSpaceCounts.push(indentSpaceCount);
			indentSpaceCount = isc;
			parentXmls.push(parent);
			var lineXml:XML = new XML("<_line />");
			current.appendChild(lineXml);
			parent = lineXml;
		} else if (isc < indentSpaceCount) {
			while (isc < indentSpaceCount) {
				indentSpaceCount = indentSpaceCounts.pop();
				parent = parentXmls.pop();
			}
		}
		if (parentXmls.length == 0 && parent != null) {
			texts.push(parent);
			parent = null;
		}
		current = new XML("<" + strs[0] + " />");
		for (var i:int = 1; i < strs.length; i++) {
			current.appendChild(new XML("<_arg>" + strs[i] + "</_arg>"));
		}
		if (parent != null) parent.appendChild(current);
		else                parent = current;
	}
	if (parentXmls.length > 0) texts.push(parentXmls[0]);
	return texts;
}
// Create a circle bitmap data.
function createCircleBitmapData(radius:int, r:int, g:int, b:int, a:Number, blurSize:int, shineCount:int = 1):BitmapData {
	var s:Shape, gr:Graphics, bd:BitmapData;
	var blur:BlurFilter = new BlurFilter;
	blur.blurX = blur.blurY = blurSize;
	s = new Shape;
	gr = s.graphics;
	var p:Number = radius + blurSize, rd:int = radius;
	for (var i:int = 0; i < shineCount; i++) {
		gr.beginFill(r * 0x10000 + g * 0x100 + b, a);
		gr.drawCircle(p, p, rd);
		gr.endFill();
		p += 0.5; rd -= 1;
		r += 0x10; if (r > 0xff) r = 0xff;
		g += 0x10; if (g > 0xff) g = 0xff;
		b += 0x10; if (b > 0xff) b = 0xff;
	}
	s.filters = [blur];
	var sz:int = (radius + blurSize) * 2;
	bd = new BitmapData(sz, sz, true, 0);
	bd.draw(s);
	return bd;
}
// Utility functions.
var sin:Function = Math.sin, cos:Function = Math.cos, atan2:Function = Math.atan2;
var abs:Function = Math.abs, PI:Number = Math.PI;
function createTextField(x:int, y:int, width:int, height:int, color:int):TextField {
	var fm:TextFormat = new TextFormat, fi:TextField = new TextField;
	fm.font = "_typewriter"; fm.bold = true; fm.size = 12; fm.color = color;
	fi.defaultTextFormat = fm; fi.x = x; fi.y = y; fi.width = width; fi.height = height;  fi.selectable = false;
	return fi;
}
function createDrum(voiceNum:int):SiONData {
	var drum:SiONData = driver.compile("#EFFECT0{ws95lf4000}; %6@0o2v1c16");
	drum.setVoice(0, percusVoices[voiceNum]);
	return drum;
}
function randi(n:int):int {
	return Math.random() * n;
}
function randn(n:Number):Number {
	return Math.random() * n;
}
function trimStart(s:String):String {
        if (s.charAt(0) == ' ') s = trimStart(s.substring(1));
        return s;
}
// LeftRedRightBlue.as
//  Take red balls to left, blue balls to right.
//  <Operation>
//   Move the hole: Mouse
package {
    import flash.display.Sprite;
    [SWF(width="465", height="465", backgroundColor="0", frameRate="30")]
    public class LeftRedRightBlue extends Sprite { public function LeftRedRightBlue() { main = this; initialize(); } }
}
import flash.display.*;
import flash.geom.*;
import flash.text.*;
import flash.events.*;
const SCREEN_WIDTH:int = 465, SCREEN_HEIGHT:int = 465;
var main:Sprite, screen:BitmapData = new BitmapData(SCREEN_WIDTH, SCREEN_HEIGHT, false, 0);
var scoreField:TextField = new TextField, messageField:TextField = new TextField;
// Initialize UIs.
function initialize():void {
    main.addChild(new Bitmap(screen));
    main.stage.addEventListener(MouseEvent.CLICK, function(e:Event):void { startGame(); } );
    scoreField   = createTextField(SCREEN_WIDTH - 120, 0, 120, 24, 0xff6666);
    messageField = createTextField(SCREEN_WIDTH - 360, SCREEN_HEIGHT * 0.9, 360, 20, 0xff6666);
    main.addChild(scoreField); main.addChild(messageField);
    startGame(); isInGame = false; main.addEventListener(Event.ENTER_FRAME, update);
}
// Update the game frame.
const WALL_WIDTH:Number = 14, HOLE_WIDTH:Number = 25;
const HOLE_X:Number = SCREEN_WIDTH / 2 - WALL_WIDTH / 2;
const HOLE_Y_U:Number = SCREEN_HEIGHT * 0.25, HOLE_Y_L:Number = SCREEN_HEIGHT * 0.75;
var holeY:Number, areBallsSeparated:Boolean, level:int = 1, gameLevel:int;
function update(event:Event):void {
    level = main.stage.mouseX * 8.9 / SCREEN_WIDTH + 1;
    messageField.text = "Click to start level " + String(level);
    screen.fillRect(screen.rect, 0);
    fillRect(0, HOLE_Y_U - WALL_WIDTH, SCREEN_WIDTH / 2, SCREEN_HEIGHT * 0.5 + WALL_WIDTH * 2, RED);
    fillRect(SCREEN_WIDTH / 2, HOLE_Y_U - WALL_WIDTH, SCREEN_WIDTH / 2, SCREEN_HEIGHT * 0.5 + WALL_WIDTH * 2, BLUE);
    fillRect(WALL_WIDTH - BALL_WIDTH, HOLE_Y_U - BALL_WIDTH,
             SCREEN_WIDTH - WALL_WIDTH * 2 + BALL_WIDTH * 2, SCREEN_HEIGHT * 0.5 + BALL_WIDTH * 2, 0);
    areBallsSeparated = true;
    for each (var b:Ball in balls) b.update();
    if (areBallsSeparated) isInGame = false;
    if (!isInGame) return;
    holeY = main.stage.mouseY;
    if (holeY < HOLE_Y_U + HOLE_WIDTH) holeY = HOLE_Y_U + HOLE_WIDTH;
    if (holeY > HOLE_Y_L - HOLE_WIDTH) holeY = HOLE_Y_L - HOLE_WIDTH;
    fillRect(HOLE_X + BALL_WIDTH, HOLE_Y_U - BALL_WIDTH,
             WALL_WIDTH - BALL_WIDTH * 2, holeY - HOLE_WIDTH - HOLE_Y_U - BALL_WIDTH);
    fillRect(HOLE_X + BALL_WIDTH, holeY + HOLE_WIDTH + BALL_WIDTH * 2,
             WALL_WIDTH - BALL_WIDTH * 2, HOLE_Y_L - holeY - HOLE_WIDTH - BALL_WIDTH);
    scoreField.text = String(--score) + "\nLevel " + String(gameLevel); if (score <= 0) isInGame = false;
}
// Balls.
const RED:int = 0xff4444, BLUE:int = 0x4444ff, BALL_WIDTH:Number = 4;
var balls:Vector.<Ball>;
class Ball {
    public var pos:Vector3D = new Vector3D, vel:Vector3D = new Vector3D;
    public var boundedTicks:int, color:int;
    public function update():void {
        pos.incrementBy(vel); boundedTicks--;
        if ((pos.x < WALL_WIDTH                && vel.x < 0) ||
            (pos.x > SCREEN_WIDTH - WALL_WIDTH && vel.x > 0)) vel.x = -vel.x;
        if (pos.y < HOLE_Y_U && vel.y < 0) { pos.y = HOLE_Y_U; vel.y = -vel.y; }
        if (pos.y > HOLE_Y_L && vel.y > 0) { pos.y = HOLE_Y_L; vel.y = -vel.y; }
        if (pos.x > HOLE_X && pos.x < HOLE_X + WALL_WIDTH && isInGame && boundedTicks < 0 &&
            (pos.y < holeY - HOLE_WIDTH || pos.y > holeY + HOLE_WIDTH)) {
            vel.x = -vel.x; boundedTicks = 10;
        }
        fillRect(pos.x - BALL_WIDTH, pos.y - BALL_WIDTH, BALL_WIDTH * 2 + 1, BALL_WIDTH * 2 + 1, color);
        if ((color == BLUE && pos.x < SCREEN_WIDTH / 2) ||
            (color == RED  && pos.x > SCREEN_WIDTH / 2)) areBallsSeparated = false;
    }
}
function addBall(x:Number, y:Number, color:int):void {
    var b:Ball = new Ball; b.pos.x = x; b.pos.y = y; b.color = color;
    var a:Number = rand() * PI / 4 + int(rand() * 4) * PI / 2 + PI / 8;
    var s:Number = 4 + rand() * 2;
    b.vel.x = sin(a) * s; b.vel.y = cos(a) * s;
    balls.push(b);
}
function setBalls():void {
    for (var i:int = 0; i < gameLevel; i++) {
        addBall(WALL_WIDTH + rand() * (HOLE_X - WALL_WIDTH),          HOLE_Y_U + rand() * (HOLE_Y_L - HOLE_Y_U), BLUE);
        addBall(HOLE_X + WALL_WIDTH + rand() * (HOLE_X - WALL_WIDTH), HOLE_Y_U + rand() * (HOLE_Y_L - HOLE_Y_U), RED);
    }
}
// Handle the game lifecycle.
var isInGame:Boolean, score:int;
function startGame():void {
    isInGame = true; messageField.text = ""; score = 500 * level; gameLevel = level;
    balls = null; balls = new Vector.<Ball>; setBalls();
}
// Utility functions and variables.
var rand:Function = Math.random, abs:Function = Math.abs;
var sin:Function = Math.sin, cos:Function = Math.cos, PI:Number = Math.PI;
var rect:Rectangle = new Rectangle;
function fillRect(x:Number, y:Number, w:Number, h:Number, c:int = 0xffffff):void {
    rect.x = x; rect.y = y; rect.width = w; rect.height = h; screen.fillRect(rect, c);
}
function createTextField(x:int, y:int, width:int, size:int, color:int):TextField {
    var fm:TextFormat = new TextFormat, fi:TextField = new TextField;
    fm.font = "_typewriter"; fm.bold = true; fm.size = size; fm.color = color; fm.align = TextFormatAlign.RIGHT;
    fi.defaultTextFormat = fm; fi.x = x; fi.y = y; fi.width = width; fi.selectable = false;
    return fi;
}
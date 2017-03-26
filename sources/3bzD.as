// WallAll.as
//  Control a red box and avoid walls.
//  <Operation>
//   Movement: Mouse
package {
    import flash.display.Sprite;
    [SWF(width="465", height="465", backgroundColor="0x000000", frameRate="30")]
    public class WallAll extends Sprite { public function WallAll() { main = this; initialize(); } }
}
import flash.display.*;
import flash.geom.*;
import flash.text.*;
import flash.events.*;
const SCREEN_WIDTH:int = 465, SCREEN_HEIGHT:int = 465, GAME_OVER_DURATION:int = 150, BLOCK_GAME_START_DURATION:int = 30;
var main:Sprite, screen:BitmapData = new BitmapData(SCREEN_WIDTH, SCREEN_HEIGHT, false, 0);
var scoreField:TextField = new TextField, messageField:TextField = new TextField;
var gameOverTicks:int, score:int, wallTicks:int, isMouseClicked:Boolean;
// Initialize UIs.
function initialize():void {
    main.addChild(new Bitmap(screen));
    main.stage.addEventListener(MouseEvent.CLICK, function(e:Event):void { isMouseClicked = true; } );
    scoreField   = createTextField(SCREEN_WIDTH - 100, 0, 100, 24, 0xff6666, TextFormatAlign.RIGHT);
    messageField = createTextField(SCREEN_WIDTH - 256, 0, 256, 36, 0xff6666);
    main.addChild(scoreField); main.addChild(messageField);
    startTitle(); main.addEventListener(Event.ENTER_FRAME, update);
}
// Update the game frame.
function update(event:Event):void {
    screen.lock(); screen.fillRect(screen.rect, 0);
    wallTicks--; if (wallTicks <= 0) addWall();
    for (var i:int = 0; i < walls.length; i++) if (!walls[i].update()) { walls.splice(i, 1);  i--; }
    if      (gameOverTicks < 0)                  Player.update();
    else if (gameOverTicks < GAME_OVER_DURATION) Player.draw();
    screen.unlock();
    if (gameOverTicks >= 0) {
        gameOverTicks++; if (gameOverTicks == GAME_OVER_DURATION) startTitle();
        if (isMouseClicked && gameOverTicks > BLOCK_GAME_START_DURATION) startGame();
    }
}
// Walls.
const WALL_HEIGHT:Number = 10.0;
var walls:Vector.<Wall>;
class Wall {
    public var rect:Rectangle = new Rectangle;
    public function update():Boolean {
        if (gameOverTicks < 0 || gameOverTicks >= GAME_OVER_DURATION) rect.y += 5 + score / 100;
        screen.fillRect(rect, 0xffffff);
        return (rect.y < SCREEN_HEIGHT + WALL_HEIGHT);
    }
}
function addWall():void {
    var w:Wall = new Wall;
    w.rect.width = (rand() * 0.5 + 0.1) * SCREEN_WIDTH; w.rect.height = WALL_HEIGHT;
    w.rect.x = rand() * SCREEN_WIDTH - w.rect.width / 2; w.rect.y = -WALL_HEIGHT;
    walls.push(w); wallTicks = (5 + rand() * 15) * 1000 / (1000 + score);
}
// Player.
class Player {
    public static var pos:Vector3D = new Vector3D, prevPos:Vector3D = new Vector3D;
    public static function update():void {
        prevPos.x = pos.x; prevPos.y = pos.y;
        pos.x = main.stage.mouseX; pos.y = main.stage.mouseY;
        draw();
        var cx:Number = pos.x, cy:Number = pos.y, ox:Number = prevPos.x - pos.x, oy:Number = prevPos.y - pos.y;
        ox /= 9; oy /= 9;
        for (var i:int = 0; i < 10; i++, cx += ox, cy += oy)
            for each (var w:Wall in walls) if (w.rect.contains(cx, cy)) {
                startGameOver(); pos.x = cx; pos.y = cy; return;
            }
        score++; scoreField.text = String(score);
    }
    public static function draw():void {
        rect.x = pos.x - 5; rect.y = pos.y - 5; rect.width = rect.height = 11;
        screen.fillRect(rect, 0xff4444);
    }
}
// Handle the game lifecycle.
function startTitle():void {
    clearActors(); gameOverTicks = GAME_OVER_DURATION; isMouseClicked = false;
    messageField.y = SCREEN_HEIGHT / 3; messageField.text = "WallAll";
}
function startGame():void {
    clearActors(); gameOverTicks = -1; messageField.text = ""; score = 0; scoreField.text = "0";
    wallTicks = 0; Player.pos.x = main.stage.mouseX; Player.pos.y = main.stage.mouseY;
}
function startGameOver():void {
    gameOverTicks = 0; isMouseClicked = false;
    messageField.y = SCREEN_HEIGHT / 2; messageField.text = "GAME OVER";
}
function clearActors():void {
    walls = null; walls = new Vector.<Wall>;
}
// Utility functions and variables.
var rect:Rectangle = new Rectangle, rand:Function = Math.random;
function createTextField(x:int, y:int, width:int, size:int, color:int, align:String = TextFormatAlign.LEFT):TextField {
    var fm:TextFormat = new TextFormat, fi:TextField = new TextField;
    fm.font = "_typewriter"; fm.bold = true; fm.size = size; fm.color = color; fm.align = align;
    fi.defaultTextFormat = fm; fi.x = x; fi.y = y; fi.width = width; fi.selectable = false;
    return fi;
}

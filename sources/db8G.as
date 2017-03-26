// LaserShield.as
//  Control the red box and avoid lasers with the shield.
//  <Operation>
//   Movement: Mouse
//   Shield  : Click
package {
    import flash.display.Sprite;
    [SWF(width="465", height="465", backgroundColor="0x000000", frameRate="30")]
    public class LaserShield extends Sprite { public function LaserShield() { main = this; initialize(); } }
}
import flash.display.*;
import flash.geom.*;
import flash.text.*;
import flash.events.*;
const SCREEN_WIDTH:int = 465, SCREEN_HEIGHT:int = 465, GAME_OVER_DURATION:int = 50;
var main:Sprite, screen:BitmapData = new BitmapData(SCREEN_WIDTH, SCREEN_HEIGHT, false, 0);
var scoreField:TextField = new TextField, messageField:TextField = new TextField;
var isInGame:Boolean, score:int, ticks:int, laserTicks:int, isMousePressed:Boolean;
// Initialize UIs.
function initialize():void {
    main.addChild(new Bitmap(screen));
    main.stage.addEventListener(MouseEvent.MOUSE_DOWN, function(e:Event):void { isMousePressed = true; } );
    main.stage.addEventListener(MouseEvent.MOUSE_UP  , function(e:Event):void { isMousePressed = false; } );
    scoreField   = createTextField(SCREEN_WIDTH - 100, 0, 100, 24, 0xff6666, TextFormatAlign.RIGHT);
    messageField = createTextField(SCREEN_WIDTH - 256, SCREEN_HEIGHT / 2, 256, 36, 0xff6666);
    main.addChild(scoreField); main.addChild(messageField);
    startGameOver(); ticks = GAME_OVER_DURATION; main.addEventListener(Event.ENTER_FRAME, update);
}
// Update the game frame.
function update(event:Event):void {
    screen.fillRect(screen.rect, 0);
    if (isInGame) Player.update();
    else if (isMousePressed && ticks > GAME_OVER_DURATION) startGame();
    if (!isInGame && ticks == GAME_OVER_DURATION) {
        messageField.text = "LaserShield"; lasers = null; lasers = new Vector.<Laser>;
    }
    ticks++; laserTicks--; if (laserTicks <= 0) addLaser();
    for (var i:int = 0; i < lasers.length; i++) if (!lasers[i].update()) { lasers.splice(i, 1);  i--; }
}
// Lasers.
var lasers:Vector.<Laser>;
class Laser {
    public var pos:Vector3D = new Vector3D, length:int, vel:Number = 3.0 + rand() * 3.0;
    public var angle:Number = rand() * PI * 2, angleVel:Number = rand() * 0.2 - 0.1;
    public function update():Boolean {
        p.x = pos.x; p.y = pos.y;
        for (var i:int = 0; i < length; i++) {
            if (isInGame && isMousePressed && Player.shieldEnergy > 0 &&
                Vector3D.distance(p, Player.pos) <= Player.SHIELD_RADIUS) {
                scoreField.text = String(score++); length = i; break;
            } else if (isInGame && (!isMousePressed || Player.shieldEnergy <= 0) &&
                       Vector3D.distance(p, Player.pos) <= 20.0) startGameOver();
            rect.x = p.x - 4; rect.y = p.y - 4; rect.width = rect.height = 9;
            screen.fillRect(rect, 0x0000ff);
            rect.x = p.x - 2; rect.y = p.y - 2; rect.width = rect.height = 5; 
            screen.fillRect(rect, 0x0088ff);
            p.x += sin(angle) * 7.0; p.y += cos(angle) * 7.0;
            if (p.x < 0 || p.x >= SCREEN_WIDTH || p.y < 0 || p.y >= SCREEN_HEIGHT * 3) { length = i; break; }
        }
        angle += angleVel; pos.y += vel; length++;
        if (pos.y < SCREEN_HEIGHT) length++;
        else length -= 3;
        return (length >= 0);
    }
}
function addLaser():void {
    var l:Laser = new Laser; l.pos.x = rand() * SCREEN_WIDTH;
    lasers.push(l); laserTicks = (25 + rand() * 50) * 2000 / (2000 + ticks);
}
// Player.
class Player {
    public static const SHIELD_RADIUS:Number = 48.0;
    public static var pos:Vector3D = new Vector3D, shieldEnergy:Number;
    public static function update():void {
        pos.x = main.stage.mouseX; pos.y = main.stage.mouseY;
        rect.x = pos.x - 9; rect.y = pos.y - 9; rect.width = rect.height = 19;
        screen.fillRect(rect, 0xff4444);
        if (isMousePressed && shieldEnergy > 0) {
            var a:Number = ticks * 0.05; rect.width = rect.height = 7;
            for (var i:int = 0; i < 32; i++) {
                rect.x = pos.x + sin(a) * SHIELD_RADIUS - 3; rect.y = pos.y + cos(a) * SHIELD_RADIUS - 3;
                screen.fillRect(rect, int(shieldEnergy * 2 + 50) * 0x10000 + 0xff); a += PI / 16;
            }
            shieldEnergy -= (1.0 + ticks / 1000); if (shieldEnergy < 0) shieldEnergy = 0;
        }
        if (!isMousePressed) {
            shieldEnergy += 5.0; if (shieldEnergy > 100.0) shieldEnergy = 100.0;
        }
        rect.x = pos.x; rect.y = pos.y + 15; rect.width = shieldEnergy; rect.height = 10;
        screen.fillRect(rect, int(shieldEnergy * 2 + 50) * 0x10000 + 0x88ff);
    }
}
// Handle the game lifecycle.
function startGame():void {
    isInGame = true; lasers = null; lasers = new Vector.<Laser>; messageField.text = "";
    scoreField.text = String(score = 0); ticks = 0; Player.shieldEnergy = 100.0;
}
function startGameOver():void {
    isInGame = false; messageField.text = "GAME OVER"; isMousePressed = false; ticks = 0;
}
// Utility functions and variables.
var rect:Rectangle = new Rectangle, p:Vector3D = new Vector3D;
var rand:Function = Math.random, sin:Function = Math.sin, cos:Function = Math.cos, PI:Number = Math.PI;
function createTextField(x:int, y:int, width:int, size:int, color:int, align:String = TextFormatAlign.LEFT):TextField {
    var fm:TextFormat = new TextFormat, fi:TextField = new TextField;
    fm.font = "_typewriter"; fm.bold = true; fm.size = size; fm.color = color; fm.align = align;
    fi.defaultTextFormat = fm; fi.x = x; fi.y = y; fi.width = width; fi.selectable = false;
    return fi;
}

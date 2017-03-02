// AmidaDaMida.as
//  Lead robots to a green lamp.
//  <Operation>
//   Mouse: Move a bar.
package {
    import flash.display.Sprite;
    [SWF(width="465", height="465", backgroundColor="0", frameRate="30")]
    public class AmidaDaMida extends Sprite {
        public function AmidaDaMida() { main = this; initialize(); }
    }
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
    initializeLamps();
    startGame(); startGameOver();
    main.addEventListener(Event.ENTER_FRAME, update);
}
// Update the game frame.
const LINE_INTERVAL:Number = 60, LINE_START_X:Number = 50, LINE_START_Y:Number = 50;
const LINE_COUNT:int = 7;
var mouseBar:Bar = new Bar, existsMouseBar:Boolean;
function update(event:Event):void {
    screen.fillRect(screen.rect, 0);
    var i:int;
    for (i = 0; i < LINE_COUNT; i++)
        fillRect(LINE_START_X + LINE_INTERVAL * i - 2, LINE_START_Y, 5, SCREEN_HEIGHT - LINE_START_Y * 2);
    for each (var l:Lamp in lamps) l.draw();
    for each (var b:Bar in bars) b.draw();
    for (i = 0; i < robots.length; i++) if (!robots[i].update()) { robots.splice(i, 1); i--; }
    if (robots.length <= 0) startGameOver();
    existsMouseBar = false;
    if (!isInGame) return;
    var mx:int = main.stage.mouseX, my:int = main.stage.mouseY;
    var ml:int = (mx - LINE_START_X) / LINE_INTERVAL;
    if (mx >= LINE_START_X && ml >= 0 && ml < LINE_COUNT - 1 &&
        my > LINE_START_Y + NEAR_BAR_WIDTH && my < SCREEN_HEIGHT - LINE_START_Y - NEAR_BAR_WIDTH) {
        if (!haveNearBar(ml, my)) {
            existsMouseBar = true;
            mouseBar.lineX = ml; mouseBar.y = my;
            mouseBar.draw();
        }
    }
}
// Robots.
var robots:Vector.<Robot>;
class Robot {
    public var pos:Vector3D = new Vector3D, lineX:int, velX:int, velY:int, speed:Number;
    public function update():Boolean {
        if (velX == 0) {
            var py:Number = pos.y;
            pos.y += velY * speed;
            var cb:Bar = checkBars(lineX, py, velY, abs(pos.y - py));
            if (cb != null) {
                if (cb.lineX == lineX) velX =  1;
                else                   velX = -1;
                lineX += velX;
                pos.y = cb.y;
            }
        } else {
            pos.x += velX * speed;
            var tx:Number = LINE_START_X + LINE_INTERVAL * lineX;
            if ((pos.x - tx) * velX >= 0) { velX = 0; pos.x = tx; }
        }
        fillRect(pos.x - 7, pos.y - 7, 15, 15, 0x44ee66);
        if (pos.y <= LINE_START_Y || pos.y >= SCREEN_HEIGHT - LINE_START_Y) {
            var li:int = lineX + int((velY + 1) / 2) * LINE_COUNT;
            velY *= -1; pos.y += velY * speed;
            if (!isInGame) return true;
            if (!lamps[li].isGreen) return false;
            lamps[li].isGreen = false;
            var areAllLampsRed:Boolean = true;
            for each (var l:Lamp in lamps) if (l.isGreen) { areAllLampsRed = false; break; }
            if (areAllLampsRed) {
                setLamps(); rank++;
                for each (var r:Robot in robots) r.speed *= 1.5;
            }
            scoreField.text = String(score += robots.length);
            var ar:Robot = addRobot(lineX, pos.y, velY);
            if (ar.speed == speed) ar.speed += 0.5;
        }
        return true;
    }
}
function addRobot(lx:int, y:int, vy:int = 0):Robot {
    var r:Robot = new Robot;
    r.lineX = lx; r.pos.x = LINE_START_X + LINE_INTERVAL * r.lineX; r.pos.y = y;
    r.velX = 0;
    if (vy == 0) r.velY = int(rand() * 2) * 2 - 1;
    else         r.velY = vy;
    r.speed = (((robots.length + 3) % 4) + 2) * (1 + rank * 0.5);
    robots.push(r);
    return r;
}
// Bars.
const BAR_DISAPPEAR_COUNT:int = 12;
var bars:Vector.<Bar>;
class Bar {
    public var lineX:int, y:Number, count:int = BAR_DISAPPEAR_COUNT;
    public function draw():void {
        var c:int = count * 155 / BAR_DISAPPEAR_COUNT + 100;
        if (count <= 1) c -= 50;
        c = c * 0x10000 + 0x100 * c + c;
        fillRect(LINE_START_X + LINE_INTERVAL * lineX, y - 2, LINE_INTERVAL, 5, c);
    }
    public function getDistance(lx:int, by:Number, velY:int):int {
        if (lineX != lx || (by - y) * velY >= 0) return 99999;
        return abs(by - y);
    }
}
function addBar(c:int):void {
    var lx:int, y:Number;
    do {
        lx = rand() * (LINE_COUNT - 1);
        y = rand() * (SCREEN_HEIGHT - LINE_START_Y * 4) + LINE_START_Y * 2;
    } while (haveNearBar(lx, y));
    var b:Bar = new Bar;
    b.lineX = lx; b.y = y; b.count = c;
    bars.push(b);
}
function checkBars(lineX:int, y:Number, velY:int, range:Number):Bar {
    var lBar:Bar = getNearestBar(lineX - 1, y, velY);
    var rBar:Bar = getNearestBar(lineX    , y, velY);
    var lr:Number = 99999, rr:Number= 99999;
    if (lBar != null) lr = abs(lBar.y - y);
    if (rBar != null) rr = abs(rBar.y - y);
    if (lr <= range || rr <= range) {
        if (lr < rr) {
            if (lBar == mouseBar) addMouseBar();
            return lBar;
        } else {
            if (rBar == mouseBar) addMouseBar();
            return rBar;
        }
    }
    return null;
}
function addMouseBar():void {
    for (var i:int = 0; i < bars.length; i++) {
        bars[i].count--;
        if (bars[i].count <= 0) {
            bars.splice(i, 1); i--;
        }
    }
    bars.push(mouseBar);
    mouseBar = new Bar;
}
const NEAR_BAR_WIDTH:Number = 7;
function haveNearBar(lineX:int, y:Number):Boolean {
    var b1:Bar = getNearestBar(lineX - 1, y - NEAR_BAR_WIDTH, 1);
    var b2:Bar = getNearestBar(lineX    , y - NEAR_BAR_WIDTH, 1);
    var b3:Bar = getNearestBar(lineX + 1, y - NEAR_BAR_WIDTH, 1);
    var r1:Number = 99999, r2:Number = 99999, r3:Number = 99999;
    if (b1 != null) r1 = abs(b1.y - y);
    if (b2 != null) r2 = abs(b2.y - y);
    if (b3 != null) r3 = abs(b3.y - y);
    return (r1 < NEAR_BAR_WIDTH * 2 || r2 < NEAR_BAR_WIDTH * 2 || r3 < NEAR_BAR_WIDTH * 2);
}
function getNearestBar(lineX:int, y:Number, velY:int):Bar {
    var bar:Bar;
    var md:Number = 99999, d:Number;
    for each (var b:Bar in bars) {
        d = b.getDistance(lineX, y, velY);
        if (d < md) { md = d; bar = b; }
    }
    if (existsMouseBar) {
        d = mouseBar.getDistance(lineX, y, velY);
        if (d < md) bar = mouseBar;
    }
    return bar;
}
// Lamps.
var lamps:Vector.<Lamp> = new Vector.<Lamp>;
class Lamp {
    public var lineX:int, isOnTop:Boolean, isGreen:Boolean;
    public function draw():void {
        var x:Number = LINE_START_X + LINE_INTERVAL * lineX, y:Number, c:int;
        if (isOnTop) y = LINE_START_Y;
        else         y = SCREEN_HEIGHT - LINE_START_Y;
        if (isGreen) c = 0x22ff22;
        else         c = 0xff2222;
        fillRect(x - 5, y - 5, 11, 11, c);
    }
}
function initializeLamps():void {
    for (var i:int = 0; i < LINE_COUNT * 2; i++) {
        var l:Lamp = new Lamp;
        l.lineX = i % LINE_COUNT; l.isOnTop = (i < LINE_COUNT);
        lamps.push(l);
    }
}
function setLamps():void {
    for each (var l:Lamp in lamps) l.isGreen = true;
}
// Handle the game lifecycle.
var isInGame:Boolean, score:int, rank:int, robotAddCount:int;
function startGame():void {
    if (isInGame) return;
    isInGame = true;
    messageField.text = ""; scoreField.text = String(score = 0);
    rank = 0; robotAddCount = 0;
    robots = null; robots = new Vector.<Robot>;
    bars = null; bars = new Vector.<Bar>;
    for (var i:int = 0; i < BAR_DISAPPEAR_COUNT; i++) addBar(i + 1);
    addRobot(rand() * LINE_COUNT, SCREEN_HEIGHT / 2);
    setLamps();
}
function startGameOver():void {
    isInGame = false;
    messageField.text = "AmidaDaMida\nClick to start";
    setLamps();
}
// Utility functions and variables.
var rand:Function = Math.random, abs:Function = Math.abs, rect:Rectangle = new Rectangle;
function fillRect(x:Number, y:Number, w:Number, h:Number, c:int = 0xffffff):void {
    rect.x = x; rect.y = y; rect.width = w; rect.height = h; screen.fillRect(rect, c);
}
function createTextField(x:int, y:int, width:int, size:int, color:int):TextField {
    var fm:TextFormat = new TextFormat, fi:TextField = new TextField;
    fm.font = "_typewriter"; fm.bold = true; fm.size = size; fm.color = color; fm.align = TextFormatAlign.RIGHT;
    fi.defaultTextFormat = fm; fi.x = x; fi.y = y; fi.width = width; fi.selectable = false;
    return fi;
}

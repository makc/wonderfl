// forked from ABA's DefeatMe
// DefeatMe.as
//  Defeat black ships.
//  (To restart from stage 1, reload the page.)
//  <Operation>
//   Movement     : Arrow or [WASD] keys.
//   Fire / Start : [Z], [X], [.] or [/] key.
package {
    import flash.display.Sprite;
    [SWF(width="465", height="465", backgroundColor="0xdddddd", frameRate="30")]
    public class DefeatMe extends Sprite {
        public function DefeatMe() { main = this; initialize(); }
    }
}
import flash.display.*;
import flash.geom.*;
import flash.text.*;
import flash.events.*;
const SCREEN_WIDTH:int = 465, SCREEN_HEIGHT:int = 465;
var main:Sprite, g:Graphics;
var messageField:TextField = new TextField;
var keys:Vector.<Boolean> = new Vector.<Boolean>(256);
// Initialize UIs.
function initialize():void {
    g = main.graphics;
    main.stage.addEventListener(KeyboardEvent.KEY_DOWN, function(e:KeyboardEvent):void { keys[e.keyCode] = true; } );
    main.stage.addEventListener(KeyboardEvent.KEY_UP,   function(e:KeyboardEvent):void { keys[e.keyCode] = false; } );
    messageField = createTextField(SCREEN_WIDTH - 360, SCREEN_HEIGHT - 20, 360, 20, 0);
    main.addChild(messageField);
    goToNextStage(); ships[1].exists = false;
    startGameOver(); gameOverTicks = 1;
    main.addEventListener(Event.ENTER_FRAME, update);
}
// Update the game frame.
function update(event:Event):void {
    g.clear();
    var isStageOver:Boolean = true;
    g.lineStyle(5, 0, 0.8);
    for each (var s:Ship in ships) {
        s.update();
        if (!s.isPlayer && s.exists) isStageOver = false;
    }
    for (var i:int = 0; i < shots.length; i++) if (!shots[i].update()) { shots.splice(i, 1); i--; }
    if (isInGame) {
        if (isStageOver) goToNextStage();
    } else {
        if (gameOverTicks > 0) {
            gameOverTicks--; messageField.y = SCREEN_HEIGHT - 20 + gameOverTicks;
        } else if (isFirePressed()) {
            isInGame = true; resetStage();
        }
    }
}
var firePressedFlag:Boolean;
function isFirePressed():Boolean {
    if (isFireDown()) {
        if (!firePressedFlag) {
            firePressedFlag = true;
            return true;
        }
    } else {
        firePressedFlag = false;
    }
    return false;
}
function isFireDown():Boolean {
    return (keys[0x5a] || keys[0xbf] || keys[0x58] || keys[0xbe]);
}
// Ships.
var ships:Vector.<Ship> = new Vector.<Ship>;
class Ship {
    public var pos:Vector3D, vel:Vector3D = new Vector3D;
    public var isPlayer:Boolean;
    public var posRecord:Vector.<Vector3D>;
    public var fireRecord:Vector.<Boolean>;
    public var recordIndex:int = 0;
    public var exists:Boolean = true;
    public var speed:Number = 5, shotSpeed:Number = 10;
    public var fireWay:int = 1, fireWayAngle:Number = PI / 5;
    public var fireSource:Ship;
    public var hasWinder:Boolean, hasRapid:Boolean, fireTicks:int = 99999, hasBurstShot:Boolean;
    public var isBurstPhase:Boolean;
    public var shotColor:int;
    public function update():void {
        if (!exists) return;
        var px:Number, py:Number;
        if (pos != null) { px = pos.x; py = pos.y; }
        else             { px = SCREEN_WIDTH * 0.5; py = SCREEN_HEIGHT * 0.25; }
        var way:int = 1;
        if (isPlayer) {
            updatePlayer(); way = -1;
        } else {
            pos = posRecord[recordIndex];
            if (fireRecord[recordIndex]) {
                if (hasBurstShot && isBurstPhase) {
                    burstShots(this); isBurstPhase = false;
                } else {
                    addShot(pos, shotSpeed, fireWay, fireWayAngle, hasWinder, fireSource, fireTicks, false, shotColor);
                    isBurstPhase = true;
                }
            }
            recordIndex++;
            if (recordIndex >= fireRecord.length) {
                removeWinder(this);
                recordIndex = 0;
            }
        }
        g.moveTo(pos.x, pos.y + 10 * way);
        g.lineTo(pos.x - 7, pos.y - 4 * way);
        g.lineTo(pos.x + 7, pos.y - 4 * way);
        g.lineTo(pos.x, pos.y + 10 * way);
        vel.x = pos.x - px; vel.y = pos.y - py;
        return;
    }
    public function updatePlayer():void {
        var vx:Number = 0, vy:Number = 0;
        if (keys[0x25] || keys[0x41]) vx = -1;
        if (keys[0x26] || keys[0x57]) vy = -1;
        if (keys[0x27] || keys[0x44]) vx =  1;
        if (keys[0x28] || keys[0x53]) vy =  1;
        var isFiring:Boolean = isFirePressed();
        if (hasRapid) isFiring = isFireDown();
        if (isFiring) {
            if (hasBurstShot && isBurstPhase) {
                burstShots(this); isBurstPhase = false;
            } else {
                addShot(pos, shotSpeed, fireWay, fireWayAngle, hasWinder, fireSource, fireTicks, true, shotColor);
                isBurstPhase = true;
            }
        }
        if (vx != 0 && vy != 0) { vx *= 0.7; vy *= 0.7; }
        pos.x += vx * speed; pos.y += vy * speed;
        if (pos.x < 10) pos.x = 10;
        else if (pos.x > SCREEN_WIDTH - 10) pos.x = SCREEN_WIDTH - 10;
        if (pos.y < 10) pos.y = 10;
        else if (pos.y > SCREEN_HEIGHT - 10) pos.y = SCREEN_HEIGHT - 10;
        var p:Vector3D = new Vector3D(pos.x, -(pos.y - SCREEN_HEIGHT * 0.5) + SCREEN_HEIGHT * 0.5);
        posRecord.push(p); fireRecord.push(isFiring);
    }
    public function checkHit(p:Vector3D):Boolean {
        if (!exists) return false;
        var isHit:Boolean = (Vector3D.distance(p, pos) < 15);
        if (isHit) {
            removeWinder(this);
            exists = false;
            if (isPlayer) startGameOver();
        }
        return isHit;
    }
}
function goToNextStage():void {
    var s:Ship;
    if (ships.length > 0) {
        ships[ships.length - 1].isPlayer = false;
    } else {
        s = new Ship;
        var p:Vector3D = new Vector3D(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.25);
        s.posRecord = new Vector.<Vector3D>;
        s.fireRecord = new Vector.<Boolean>;
        s.posRecord.push(p); s.fireRecord.push(false);
        ships.push(s);
    }
    stage++;
    var sn:int = ships.length;
    if (sn > phase) {
        phase++;
        s = ships[ships.length - 1];
        ships = null; ships = new Vector.<Ship>;
        ships.push(s);
    }
    s = new Ship;
    s.pos = new Vector3D;
    var r:int = 0, g:int = 0, b:int = 0;
    if (stage % 3 == 0) s.shotSpeed += 3;
    if (stage % 5 == 0) s.shotSpeed += 2;
    if (stage % 3 == 2) s.fireWay += 2;
    if (stage % 4 == 0) s.fireWay++;
    if (stage % 5 == 4) s.fireWay++;
    if (stage % 2 == 0) s.fireWayAngle *= 0.7;
    if (stage % 4 == 2) s.fireWayAngle *= 0.8;
    if (stage % 4 == 3) s.speed *= 1.4;
    if (stage % 5 == 3) { s.hasRapid = true; g += 0x44; }
    if (stage % 6 == 0) { s.hasWinder = true; b += 0x44; }
    if (stage % 6 == 5) { s.fireTicks = 11; s.shotSpeed *= 1.5; s.fireWay += 2; r += 0x44; }
    if (stage % 10 == 7) { s.hasBurstShot = true; r += 0x44; g += 0x22; }
    s.fireSource = s;
    s.isPlayer = true;
    s.shotColor = r * 0x10000 + g * 0x100 + b;
    ships.push(s);
    resetStage();
}
function resetStage():void {
    var sn:int = ships.length - 1;
    var s:Ship;
    for each (s in ships) { s.recordIndex = 0; s.exists = true; }
    shots = null; shots = new Vector.<Shot>;
    s = ships[ships.length - 1];
    s.pos.x = SCREEN_WIDTH * 0.5; s.pos.y = SCREEN_WIDTH * 0.75;
    s.posRecord = null; s.posRecord = new Vector.<Vector3D>;
    s.fireRecord = null; s.fireRecord = new Vector.<Boolean>;
    s.isBurstPhase = false;
    for (var x:int = 0; x <= SCREEN_WIDTH; x += 15) {
        addShot(new Vector3D(x, 30), 5.0 / (sn + 1), 1, 0, false, null, 99999, false, 0);
    }
    messageField.y = 0;
    messageField.text = "Stage " + phase + "-" + sn;
}
// Shots.
var shots:Vector.<Shot>;
class Shot {
    public var pos:Vector3D = new Vector3D, vel:Vector3D = new Vector3D;
    public var isPlayers:Boolean;
    public var source:Ship;
    public var sinV:Number, cosV:Number;
    public var ticks:int;
    public var isWinder:Boolean;
    public var color:int;
    public function update():Boolean {
        pos.incrementBy(vel);
        if (isWinder) pos.incrementBy(source.vel);
        g.lineStyle(5, color, 0.8);
        g.moveTo(pos.x - sinV * 10, pos.y - cosV * 10);
        g.lineTo(pos.x + sinV * 10, pos.y + cosV * 10);
        if (isPlayers) {
            for each (var s:Ship in ships) if (!s.isPlayer) if (s.checkHit(pos)) return false;
        } else {
            ships[ships.length - 1].checkHit(pos);
        }
        ticks--;
        return (pos.x >= 0 && pos.x < SCREEN_WIDTH && pos.y >= 0 && pos.y < SCREEN_HEIGHT && ticks > 0);
    }
}
function addShot(p:Vector3D, shotSpeed:Number, fireWay:int, fireWayAngle:Number, isWinder:Boolean,
                 source:Ship, ticks:int, isPlayer:Boolean, color:int):void {
    var s:Shot, a:Number = 0, ai:Number;
    if (fireWay > 1) {
        a = -fireWayAngle;
        ai = fireWayAngle * 2 / (fireWay - 1);
    }
    for (var i:int = 0; i < fireWay; i++) {
        s = new Shot;
        s.pos.x = p.x; s.pos.y = p.y;
        var sa:Number = a;
        if (isPlayer) sa = PI - a;
        s.sinV = sin(sa); s.cosV = cos(sa);
        s.vel.x = shotSpeed * s.sinV; s.vel.y = shotSpeed * s.cosV;
        s.isWinder = isWinder;
        s.source = source;
        s.ticks = ticks;
        s.isPlayers = isPlayer;
        s.color = color;
        shots.push(s);
        a += ai;
    }
}
function removeWinder(src:Ship):void {
    for each (var s:Shot in shots) if (s.source == src) s.isWinder = false;
}
function burstShots(src:Ship):void {
    for (var i:int = 0; i < shots.length; i++) {
        var ps:Shot = shots[i];
        if (ps.source != src) continue;
        for (var j:int = 0; j < 8; j++) {
            var s:Shot = new Shot;
            s.pos.x = ps.pos.x; s.pos.y = ps.pos.y;
            var sa:Number = j * PI / 4;
            s.vel.x = sin(sa) * 10; s.vel.y = cos(sa) * 10;
            s.sinV = sin(sa); s.cosV = cos(sa);
            s.ticks = 5;
            s.isPlayers = ps.isPlayers;
            shots.push(s);
        }
        shots.splice(i, 1); i--;
    }
}
// Handle the game lifecycle.
var isInGame:Boolean, gameOverTicks:int, stage:int = 0, phase:int = 1;
function startGameOver():void {
    isInGame = false; gameOverTicks = 20;
    messageField.text = "GAME OVER";
}
// Utility functions and variables.
var sin:Function = Math.sin, cos:Function = Math.cos, PI:Number = Math.PI;
function createTextField(x:int, y:int, width:int, size:int, color:int):TextField {
    var fm:TextFormat = new TextFormat, fi:TextField = new TextField;
    fm.font = "_typewriter"; fm.bold = true; fm.size = size; fm.color = color; fm.align = TextFormatAlign.RIGHT;
    fi.defaultTextFormat = fm; fi.x = x; fi.y = y; fi.width = width; fi.selectable = false;
    return fi;
}

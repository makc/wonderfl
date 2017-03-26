// forked from ABA's forked from: CircleCycle
// CircleCycle.as
//  Destroy circles and avoid incoming bullets.
//  My ship extends every 200 points.
//  <Operation>
//   Movement   : Mouse
//   Zoom & Slow: Click
package {
    import flash.display.Sprite;
    [SWF(width="465", height="465", backgroundColor="0x000000", frameRate="30")]
    public class CircleCycle extends Sprite { public function CircleCycle() { main = this; initialize(); } }
}

import flash.display.*;
import flash.geom.*;
import flash.text.*;
import flash.events.*;

const SCREEN_WIDTH:int = 465, SCREEN_HEIGHT:int = 465;
const BACKGROUND_BRIGHTNESS:int = 200;
const BACKGROUND_COLOR:int = BACKGROUND_BRIGHTNESS * 0x10000 + BACKGROUND_BRIGHTNESS * 0x100 + BACKGROUND_BRIGHTNESS;
var main:Sprite, screen:BitmapData = new BitmapData(SCREEN_WIDTH, SCREEN_HEIGHT, false, 0);
var scoreField:TextField = new TextField, messageField:TextField = new TextField;
var score:int, extendScore:int, rank:Number = 0.0, stage:int = 0, targetCircleCount:int;
var ticks:int, isMousePressed:Boolean;

// Initialize UIs.
function initialize():void {
    main.addChild(new Bitmap(screen));
    main.stage.addEventListener(MouseEvent.MOUSE_DOWN, function(e:Event):void { isMousePressed = true; } );
    main.stage.addEventListener(MouseEvent.MOUSE_UP  , function(e:Event):void { isMousePressed = false; } );
    Field.initialize();
    initializeBlurs();
    scoreField = createTextField(SCREEN_WIDTH - 100, 0, 100, 24, 0xff6666, TextFormatAlign.RIGHT);
    messageField = createTextField(SCREEN_WIDTH - 256, 0, 256, 36, 0xff6666);
    main.addChild(scoreField); main.addChild(messageField);
    startTitle();
    main.addEventListener(Event.ENTER_FRAME, update);
}

// Update the game frame.
function update(event:Event):void {
    screen.lock();
    screen.fillRect(screen.rect, BACKGROUND_COLOR);
    updateBlurs();
    var i:int, spl:int = sparks.length, shl:int = shots.length, bnl:int = bonuses.length;
    for (i = 0; i < spl; i++) if (!sparks[i].update())  { sparks.splice(i, 1);  i--; spl--; }
    for (i = 0; i < shl; i++) if (!shots[i].update())   { shots.splice(i, 1);   i--; shl--; }
    for (i = 0; i < bnl; i++) if (!bonuses[i].update()) { bonuses.splice(i, 1); i--; bnl--; }
    if (targetCircleCount <= 0) addNextTarget();
    if (ticks % 50 == 0)
        addBackgroundCircles((rand() - 0.5) * Field.size.x * 1.5,
                             20.0 / (1.0 + rank), 5.0 + rand() * 2.0 + rand() * 2.0);
    ticks++;
    targetCircleCount = 0;
    for each (var c:Circle in circles) c.update();
    var cl:int = circles.length;
    for (i = 0; i < cl; i++) if (!circles[i].exists) { circles.splice(i, 1); i--; cl--; }
    if (gameOverTicks < 0) Player.update();
    var bl:int = bullets.length;
    for (i = 0; i < bl; i++) if (!bullets[i].update()) { bullets.splice(i, 1); i--; bl--; }
    Field.drawSideBoard();
    Player.drawLeft();
    screen.unlock();
    if (gameOverTicks >= 0) {
        gameOverTicks++; Player.zoom += (1.0 - Player.zoom) * 0.2;
        if (gameOverTicks == GAME_OVER_DURATION) startTitle();
        if (isMousePressed && gameOverTicks > BLOCK_GAME_START_DURATION) startGame();
    }
}

function addNextTarget():void {
    if (rand() < 0.5) addTargetCircles(0, 1, 40.0 / (1 + rank), MIDS);
    else if (rand() < 0.5)
        addTargetCircles((rand() - 0.5) * Field.size.x * 0.7, 1, 20.0 / (1.0 + rank), MID_2);
    else
        addTargetCircles((rand() - 0.5) * Field.size.x, 2, 10.0 / (1.0 + rank), BIG);
    rank += 1.0; stage++; if (stage % 10 == 0) rank -= 5.0;
}

// Game actor base class.
class Actor {
    public var pos:Vector3D = new Vector3D;
}

class VelocityActor extends Actor {
    public var vel:Vector3D = new Vector3D;
    public var ticks:int, disappearTicks:int = 300;

    public function update():Boolean {
        pos.incrementBy(vel);
        ticks++;
        if (!Field.contains(pos) || ticks > disappearTicks) return false;
        return true;
    }
}

// Player.
class Player {
    private static const COLLISION_SIZE:Number = 5.0;
    public static var pos:Vector3D = new Vector3D, prevPos:Vector3D = new Vector3D;
    public static var fireTicks:int, invincibleTicks:int, left:int;
    public static var zoom:Number = 1.0;

    public static function start():void {
        pos.x = 0; pos.y = Field.size.y * 0.5; invincibleTicks = 0; left = 0; zoom = 1.0;
    }

    public static function update():void {
        prevPos.x = pos.x; prevPos.y = pos.y;
        var tx:Number = (main.stage.mouseX - SCREEN_WIDTH / 2) * 1.5;
        var ty:Number = main.stage.mouseY - SCREEN_HEIGHT / 2;
        pos.x += (tx - pos.x) * 0.3; pos.y += (ty - pos.y) * 0.3;
        if (pos.x < -SCREEN_WIDTH  / 2) pos.x = -SCREEN_WIDTH / 2;
        if (pos.x >  SCREEN_WIDTH  / 2) pos.x =  SCREEN_WIDTH / 2;
        Field.offsetX = pos.x * 0.33;
        if (isMousePressed) zoom += (2.0 - zoom) * 0.1;
        else zoom += (1.0 - zoom) * 0.2;
        if (score >= extendScore) {
            if (left < 2) left++;
            extendScore += 200;
        }
        if (invincibleTicks <= 0 || (invincibleTicks % 6) > 3) {
            drawCircle(pos, 15, 7, 0x008800, 0.5);
            addBlur(pos.x, pos.y, 20, 20, 100, 200, 100);
        }
        invincibleTicks--;
        if (invincibleTicks > 0) return;
        if (fireTicks <= 0 && shots.length <= 14) {
            fireTicks = 2;
            var s:Shot;
            for (var i:int = 0; i < 7; i++) {
                s = new Shot;
                s.pos.x = pos.x; s.pos.y = pos.y;
                var a:Number = (i - 3) * 0.1;
                s.vel.x = sin(a) * 24.0; s.vel.y = -cos(a) * 24.0;
                shots.push(s);
            }
        }
        fireTicks--;
        p.x = (pos.x + prevPos.x) / 2; p.y = (pos.y + prevPos.y) / 2;
        for each (var b:Bullet in bullets) {
            if (Vector3D.distance(pos, b.pos)     <= COLLISION_SIZE ||
                Vector3D.distance(prevPos, b.pos) <= COLLISION_SIZE ||
                Vector3D.distance(p, b.pos)       <= COLLISION_SIZE) {
                addSparks(100, Player.pos.x, Player.pos.y, 30.0, 15.0, 200, 100, 100);
                left--; if (left < 0) { startGameOver(); return; }
                invincibleTicks = 30;
                bullets = null; bullets = new Vector.<Bullet>;
                return;
            }
        }
    }

    public static function drawLeft():void {
        p.x = 15; p.y = 20;
        for (var i:int = 0; i < left; i++) {
            drawCircleWithoutOffset(p, 15, 7, 0x008800, 0.5);
            p.x += 30;
        }
    }
}


// Player's shots.
var shots:Vector.<Shot>;

class Shot extends VelocityActor
{
    override public function update():Boolean {
        for each (var c:Circle in circles) if (checkHit(c)) return false;
        addBlur(pos.x, pos.y, 20, 15, 50, 150, 100);
        return super.update();
    }

    private function checkHit(c:Circle):Boolean {
        for each (var cc:Circle in c.children) if (cc.exists && checkHit(cc)) return true;
        if (c.exists && c.hasCollision && Vector3D.distance(pos, c.pos) < c.spec.visualRadius + 20.0) {
            addSparks(1, pos.x, pos.y, 20.0, 5.0, 50, 150, 100);
            c.damage(); return true;
        }
        return false;
    }
}

// Circles.
var circles:Vector.<Circle>;

class Circle extends Actor {
    public var children:Vector.<Circle> = null;
    public var isTop:Boolean, exists:Boolean = true;
    public var spec:CircleSpec;
    public var bulletSpeedRatio:Number = 1.0;
    public var rollAngle:Number = 0, fireAngle:Number = 0, fireSpeed:Number, angleInterval:Number;
    public var baseAngle:Number = 0, lastFireAngle:Number = 0;
    public var ticks:int, shield:int;
    public var hasCollision:Boolean, isTarget:Boolean, isDamaged:Boolean;
    public var speed:Number, targetY:Number = Field.size.y * 2;
    public var xReverse:Number = 1.0;
    public var circleWidth:Number = 5.0, color:int;

    public function start():void {
        color = (int)(spec.r / 2) * 0x10000 + int(spec.g / 2) * 0x100 + int(spec.b / 2);
        shield = spec.shield;
    }

    public function update():void {
        var vr:Number = spec.visualRadius;
        if (spec.fireInterval > 0) vr *= ((ticks % spec.fireInterval) / spec.fireInterval * 0.5 + 1.0);
        drawCircle(pos, vr, circleWidth, color);
        var i:int;
        if (isDamaged) {
            isDamaged = false;
            var da:Number = ticks * 0.1, sr:Number = spec.visualRadius, bc:int = sr * 0.5;
            for (i = 0; i < bc; i++) {
                addBlur(pos.x + sr * sin(da), pos.y + sr * cos(da),
                        9 + rand() * 7, 9 + rand() * 7, rand() * 128 + 64, rand() * 128 + 127, 64);
                da += PI * 2 / bc;
            }
        }
        if (spec.isAimingBaseAngle) lastFireAngle = atan2(Player.pos.x - pos.x, Player.pos.y - pos.y);
        else lastFireAngle = baseAngle * xReverse;
        lastFireAngle += rollAngle + fireAngle;
        if (spec.fireInterval > 0 && ticks % spec.fireInterval == 0 && pos.y < 0 &&
            pos.x - Field.offsetX > -Field.size.x + Field.SIDE_BOARD_WIDTH &&
            pos.x - Field.offsetX <  Field.size.x - Field.SIDE_BOARD_WIDTH &&
            (!spec.isAimingBaseAngle || Vector3D.distance(pos, Player.pos) > 120)) {
            var srv:Number = spec.bulletSpeedWhipVel * 2 / spec.bulletCount;
            var fd:int = 0;
            var pc:Circle = null; if (spec.hasFireParent) pc = this;
            for (i = 0; i < spec.bulletCount; i++) {
                fire(lastFireAngle, 1.0 - spec.bulletSpeedWhipVel + srv * i, fd, pc);
                fd += spec.fireWhipDelay;
            }
        }
        ticks++;
        if (isTop) {
            if (pos.y < targetY) pos.y += speed;
            else pos.y += speed * 0.3;
            if (isTarget && pos.y > 0) pos.y += speed * 0.5;
            if (pos.y > Field.size.y + spec.radius) remove();
        }
        if (isTarget) targetCircleCount++;
        if (children == null) return;
        rollAngle = spec.rollAngle.getValue(ticks);
        fireAngle = spec.fireAngle.getValue(ticks);
        fireSpeed = spec.fireSpeed.getValue(ticks);
        angleInterval = spec.angleInterval.getValue(ticks);
        if (spec.isAimingRollAngle) rollAngle += atan2(Player.pos.x - pos.x, Player.pos.y - pos.y) * xReverse;
        var a:Number = rollAngle - angleInterval * (children.length - 1) / 2 - angleInterval;
        for each (var c:Circle in children) {
            a += angleInterval;
            if (!c.exists) continue;
            c.pos.x = pos.x + sin(a) * spec.radius * xReverse;
            c.pos.y = pos.y + cos(a) * spec.radius;
            c.baseAngle = a + fireAngle;
            c.update();
        }
    }

    private function fire(a:Number, sr:Number, delay:int, parentCircle:Circle):void {
        var b:Bullet = new Bullet;
        b.pos.x = pos.x; b.pos.y = pos.y;
        var bs:Number = spec.bulletSpeed * bulletSpeedRatio * sr;
        b.baseVel.x = sin(a) * bs; b.baseVel.y = cos(a) * bs; b.speed = bs;
        b.delayTicks = delay; b.parentCircle = parentCircle;
        b.size = spec.bulletSize;
        b.br = spec.r; b.bg = spec.g; b.bb = spec.b;
        b.color = int(b.br / 4) * 0x10000 + int(b.bg / 4) * 0x100 + int(b.bb / 4);
        bullets.push(b);
    }

    public function damage():void {
        isDamaged = true;
        shield--;
        if (shield <= 0) remove(true);
    }

    public function remove(isDestroyed:Boolean = false):void {
        for each (var c:Circle in children) if (c.exists) c.remove();
        children = null;
        exists = false;
        if (!isDestroyed) return;
        var sa:Number = ticks * 0.1, sr:Number = spec.visualRadius, sc:int = sr * 0.5, i:int;
        for (i = 0; i < sc; i++) {
            addSparks(1, pos.x + sr * sin(sa), pos.y + sr * cos(sa), 10.0, 10.0, spec.r, spec.g, spec.b);
            sa += PI * 2 / sc;
        }
        addBonuses(sr * sr * 2 / (abs(pos.y - Player.pos.y) + 30.0), pos.x, pos.y, 10.0);
    }

    public function setXReverse():void {
        xReverse = -1.0;
        for each (var c:Circle in children) c.setXReverse();
    }
}

class CircleSpec {
    public static const FIX:int = 0, WEDGE:int = 1;
    public var radius:Number, visualRadius:Number;
    public var isRound:Boolean;
    public var rollAngle:Waveform = new Waveform;
    public var isAimingRollAngle:Boolean, isAimingBaseAngle:Boolean;
    public var fireAngle:Waveform = new Waveform, fireSpeed:Waveform = new Waveform;
    public var fireInterval:int = -1;
    public var angleInterval:Waveform = new Waveform;
    public var bulletSpeed:Number = 7.0, bulletSize:Number = 15.0;
    public var bulletSpeedFanType:int, bulletSpeedFanVel:Number = 0;
    public var fireDelayType:int, fireDelayVel:Number = 0;
    public var bulletCount:int = 1;
    public var bulletSpeedWhipVel:Number = 0, fireWhipDelay:int = 0, hasFireParent:Boolean;
    public var r:int, g:int, b:int;
    public var childrenCount:int;
    public var shield:int;

    public function set(childrenCount:int, radius:Number, childRadius:Number):void {
        this.childrenCount = childrenCount;
        this.radius = radius; visualRadius = radius + childRadius;
        shield = radius;
        rollAngle.width = (0.5 + rand() * 0.5) * ((int)(rand() * 2) * 2 - 1);
        isRound = (rand() < 0.25);
        if (isRound) {
            rollAngle.type = Waveform.MONOTONE;
            rollAngle.interval = 60 + rand() * 60;
            if (rand() < 0.4) fireAngle.type = Waveform.MONOTONE;
            fireAngle.width = (2.0 + rand() * 2.0) * ((int)(rand() * 2) * 2 - 1);
            fireAngle.interval = 90 + rand() * 90;
            if (rand() < 0.3) fireAngle.center = rand() * PI * 2;
            angleInterval.center = PI * 2 / childrenCount;
        } else {
            isAimingRollAngle = true;
            if (rand() < 0.3) rollAngle.type = Waveform.SIN;
            rollAngle.interval = 120 + rand() * 90;
            if (rand() < 0.3) angleInterval.type = Waveform.SIN;
            angleInterval.center = ((2.0 + rand() * 2.0) / childrenCount) * ((int)(rand() * 2) * 2 - 1);
            angleInterval.width = angleInterval.center * (0.3 + rand() * 0.3);
            angleInterval.interval = 60 + rand() * 60;
        }
        if (rand() < 0.5) bulletSpeedFanType = WEDGE;
        if (rand() < 0.5) bulletSpeedFanVel = (0.3 + rand() * 0.2) * ((int)(rand() * 2) * 2 - 1);
        if (rand() < 0.5) fireDelayType = WEDGE;
        if (rand() < 0.5) fireDelayVel = (8.0 + rand() * 6.0) * ((int)(rand() * 2) * 2 - 1);
    }
}

class Waveform {
    public static const FIX:int = 0, MONOTONE:int = 1, SIN:int = 2;
    public var type:int = FIX, center:Number = 0, width:Number = 0, interval:int = 1;

    public function getValue(ticks:int):Number {
        switch (type) {
            case FIX:      return center;
            case MONOTONE: return center + width * ticks * 2 / interval;
            case SIN:      return center + width * sin(PI * 2 * ticks / interval);
        }
        return 0;
    }
}

const BIG:int = 0, MID_2:int = 1, MIDS:int = 2;
function addTargetCircles(x:Number, depth:int, fireIntervalRatio:Number, type:int):void {
    var bulletSpeed:Number = 5.0 + rand() * 2.0 + rand() * 2.0;
    var radius:Number = (20 + rand() * 20) * depth;
    var c:Circle = new Circle;
    if (type == MIDS) x = (rand() - 0.5) * Field.size.x;
    var rw:Number = 0;
    if (type == MID_2) rw = (rand() * 0.1 + 0.1) * Field.size.x;
    var cy:Number = -Field.size.y * (1.0 + rand() * 2.0) - radius;
    c.pos.x = x - rw; c.pos.y = cy;
    c.isTop = true; c.hasCollision = true; c.isTarget = true;
    var spd:Number, ty:Number;
    if (type != MIDS) {
        spd = 5.0 + rand() * 2.0; ty = -Field.size.y * (0.5 + rand() * 0.2);
    } else {
        spd = 3.5 + rand(); ty = Field.size.y * 2;
    }
    c.speed = spd; c.targetY = ty;
    var r:int, g:int, b:int;
    r = 127 + rand() * 128; g = 127 + rand() * 128; b = 127 + rand() * 128;
    var sps:Vector.<CircleSpec> = new Vector.<CircleSpec>;
    var turretCount:int = createCircleSpecs(sps, radius, depth, r, g, b);
    var sp:CircleSpec;
    for each (sp in sps) if (sp.isRound) turretCount *= 0.75;
    sp = sps[0];
    sp.fireInterval = turretCount * fireIntervalRatio + 1;
    sp.bulletSpeed = bulletSpeed; sp.bulletSize = 12.0 + depth * 2;
    addCircleChildren(c, sps.length - 1, sps, 1.0, 0);
    circles.push(c);
    if (type == MID_2) {
        c = new Circle;
        c.pos.x = x + rw; c.pos.y = cy;
        c.isTop = true; c.hasCollision = true; c.isTarget = true;
        c.speed = spd; c.targetY = ty;
        addCircleChildren(c, sps.length - 1, sps, 1.0, 0);
        c.setXReverse();
        circles.push(c);
    } else if (type == MIDS) {
        for (var i:int = 0; i < 3; i++) {
            c = new Circle;
            c.pos.x = (rand() - 0.5) * Field.size.x;
            c.pos.y = -Field.size.y * (1.0 + rand()) - radius;
            c.isTop = true; c.hasCollision = true; c.isTarget = true;
            c.speed = spd;
            addCircleChildren(c, sps.length - 1, sps, 1.0, 0);
            if (rand() < 0.5) c.setXReverse();
            circles.push(c);
        }
    }
}

function addBackgroundCircles(x:Number, fireIntervalRatio:Number, bulletSpeed:Number):void {
    var radius:Number = (60 + rand() * 60);
    var c:Circle = new Circle;
    c.pos.x = x; c.pos.y = -Field.size.y - radius;
    c.isTop = true; c.speed = 3.0;
    c.circleWidth = 3.0;
    var csp:CircleSpec = new CircleSpec;
    csp.radius = 0; csp.visualRadius = 15.0; csp.childrenCount = 0;
    csp.shield = 3;
    csp.isAimingBaseAngle = true;
    csp.bulletSpeed = bulletSpeed;
    csp.r = csp.g = csp.b = 200;
    var sp:CircleSpec = new CircleSpec;
    sp.r = sp.g = sp.b = 300;
    if (rand() < 0.5) {
        sp.radius = sp.visualRadius = radius;
        c.spec = sp; c.start();
        circles.push(c); return;
    }
    sp.childrenCount = 3 + rand() * 7;
    csp.fireInterval = sp.childrenCount * fireIntervalRatio + 1;
    sp.radius = radius; sp.visualRadius = radius - csp.visualRadius;
    sp.rollAngle.width = (0.5 + rand() * 0.5) * ((int)(rand() * 2) * 2 - 1);
    sp.rollAngle.type = Waveform.MONOTONE;
    sp.rollAngle.interval = 60 + rand() * 60;
    sp.angleInterval.center = ((2.0 + rand() * 2.0) / sp.childrenCount);
    if (rand() < 0.5) sp.fireDelayVel = (8.0 + rand() * 6.0) * ((int)(rand() * 2) * 2 - 1);
    c.children = new Vector.<Circle>;
    var cct:int = 0;
    for (var i:int = 0; i < sp.childrenCount; i++) {
        var cc:Circle = new Circle;
        cc.hasCollision = true;
        cc.spec = csp; cc.start();
        cc.ticks = cct; cct += sp.fireDelayVel;
        c.children.push(cc);
    }
    c.spec = sp; c.start();
    circles.push(c);
}

function createCircleSpecs(sps:Vector.<CircleSpec>, radius:Number, depth:int, r:int, g:int, b:int):int {
    var sp:CircleSpec = new CircleSpec;
    sp.r = r; sp.g = g; sp.b = b;
    var turretCount:int;
    if (depth == 0) {
        sp.radius = 0; sp.visualRadius = radius; sp.childrenCount = 0;
        if (rand() < 0.6) {
            sp.bulletCount = 2 + rand() * 5;
            sp.bulletSpeedWhipVel = 0.2 + rand() * 0.2;
            if (rand() < 0.7) sp.fireWhipDelay = 2 + rand() * 4;
            if (rand() < 0.7) sp.hasFireParent = true;
            turretCount = sp.bulletCount * 0.75;
        }
        else turretCount = 1;
    } else {
        sp.childrenCount = 1 + rand() * 7;
        var cr:Number = radius * (0.33 + rand() * 0.1);
        sp.set(sp.childrenCount, radius, cr);
        turretCount = createCircleSpecs(sps, cr, depth - 1, r, g, b) * sp.childrenCount;
    }
    sps.push(sp);
    return turretCount;
}

function addCircleChildren(c:Circle, index:int, sps:Vector.<CircleSpec>,
                           bulletSpeedRatio:Number, fireDelay:Number):void {
    var sp:CircleSpec = sps[index];
    var bsv:Number = -sp.bulletSpeedFanVel * 2 / sp.childrenCount;
    var fdv:Number = -sp.fireDelayVel * 2 / sp.childrenCount;
    if (sp.bulletSpeedFanType == CircleSpec.WEDGE) bsv *= 2;
    if (sp.fireDelayType == CircleSpec.WEDGE) fdv *= 2;
    if (sp.childrenCount > 0) c.children = new Vector.<Circle>;
    for (var i:int = 0; i < sp.childrenCount; i++) {
        var cc:Circle = new Circle;
        var bsr:Number;
        if (sp.bulletSpeedFanType == CircleSpec.FIX ||
            i < sp.childrenCount / 2) bsr = 1.0 + sp.bulletSpeedFanVel + bsv * i;
        else bsr = 1.0 + sp.bulletSpeedFanVel + bsv * (sp.childrenCount - 1 - i);
        var fd:Number;
        if (sp.fireDelayType == CircleSpec.FIX || i < sp.childrenCount / 2) fd = sp.fireDelayVel + fdv * i;
        else fd = sp.fireDelayVel + fdv * (sp.childrenCount - 1 - i);
        addCircleChildren(cc, index - 1, sps, bsr * bulletSpeedRatio, fireDelay + fd);
        c.children.push(cc);
    }
    c.bulletSpeedRatio = bulletSpeedRatio;
    c.ticks = fireDelay;
    c.spec = sp; c.start();
}

// Circles' bullets.
var bullets:Vector.<Bullet>;

class Bullet extends VelocityActor {
    public var baseVel:Vector3D = new Vector3D, speed:Number;
    public var parentCircle:Circle, delayTicks:int = 0;
    public var color:int, br:int, bg:int, bb:int, size:int;

    override public function update():Boolean {
        if (delayTicks > 0) {
            delayTicks--;
            if (delayTicks <= 0 && parentCircle != null) {
                pos.x = parentCircle.pos.x; pos.y = parentCircle.pos.y;
                baseVel.x = sin(parentCircle.lastFireAngle) * speed;
                baseVel.y = cos(parentCircle.lastFireAngle) * speed;
                parentCircle = null;
            }
            return true;
        }
        var sz:Number = 1.5 + Math.sin(ticks * 0.2) * 0.4;
        var a:Number = 0.8 + Math.sin(ticks * 0.45) * 0.2;
        drawBox(pos.x, pos.y, size, size, color, sz, br * a, bg * a, bb * a);
        if (ticks <= 15) {
            vel.x = baseVel.x * (ticks + 15) / 30.0; vel.y = baseVel.y * (ticks + 15) / 30.0;
        } else {
            vel.x = baseVel.x; vel.y = baseVel.y;
        }
        if (isMousePressed) vel.scaleBy(0.5);
        return super.update();
    }
}

// Sparks.
var sparks:Vector.<Spark>;

class Spark extends VelocityActor {
    public var size:Number;
    public var r:int, g:int, b:int;

    override public function update():Boolean {
        vel.scaleBy(0.99);
        size *= 0.95;
        r += (BACKGROUND_BRIGHTNESS - r) * 0.1;
        g += (BACKGROUND_BRIGHTNESS - g) * 0.1;
        b += (BACKGROUND_BRIGHTNESS - b) * 0.1;
        var cr:Number = rand() + 0.5;
        var br:int = r * cr, bg:int = g * cr, bb:int = b * cr;
        if (br > 255) br = 255;
        if (bg > 255) bg = 255;
        if (bb > 255) bb = 255;
        drawBox(pos.x, pos.y, size, size, r * 0x10000 + g * 0x100 + b, 1.5, br, bg, bb);
        return super.update();
    }
}

function addSparks(count:int, x:Number, y:Number, speed:Number, size:Number, r:int, g:int, b:int):void {
    for (var i:int = 0; i < count; i++) {
        var s:Spark = new Spark;
        s.pos.x = x; s.pos.y = y;
        var a:Number = rand() * PI * 2, sp:Number = speed * (0.5 + rand());
        s.vel.x = Math.sin(a) * sp; s.vel.y = Math.cos(a) * sp;
        s.size = size;
        s.r = r; s.g = g; s.b = b;
        s.disappearTicks = 15 + 15 * rand();
        sparks.push(s);
    }
}

// Bonus items.
var bonuses:Vector.<Bonus>;

class Bonus extends VelocityActor {
    public var isInhaled:Boolean;

    override public function update():Boolean {
        var a:Number = ticks * 0.1;
        for (var i:int = 0; i < 4; i++) {
            drawBox(pos.x + sin(a) * 10 - 5, pos.y + cos(a) * 10 - 5, 8, 8, 0x6688aa, 1.0, 150, 200, 150);
            a += PI / 2;
        }
        if (isInhaled && gameOverTicks < 0) {
            vel.x += (Player.pos.x - pos.x) * 0.05; vel.y += (Player.pos.y - pos.y) * 0.05;
        }
        else vel.y += 0.5;
        vel.scaleBy(0.9);
        var d:Number = Vector3D.distance(pos, Player.pos);
        if (isInhaled && d < 40.0 && gameOverTicks < 0) {
            scoreField.text = String(score++); return false;
        }
        else if (d < 120.0 && vel.length < 5.0) isInhaled = true;
        return super.update();
    }
}

function addBonuses(count:int, x:Number, y:Number, speed:Number):void {
    for (var i:int = 0; i < count; i++) {
        var b:Bonus = new Bonus;
        b.pos.x = x; b.pos.y = y;
        var a:Number = rand() * PI * 2, sp:Number = speed * (0.5 + rand());
        b.vel.x = Math.sin(a) * sp; b.vel.y = Math.cos(a) * sp;
        bonuses.push(b);
    }
}

// Game field.
class Field {
    public static const SIDE_BOARD_WIDTH:Number = SCREEN_WIDTH / 6;
    public static var size:Vector3D = new Vector3D;
    public static var offsetX:Number = 0;

    public static function initialize():void {
        size.x = SCREEN_WIDTH * 1.1 / 2; size.y = SCREEN_HEIGHT * 1.1 / 2;
    }

    public static function drawSideBoard():void {
        rect.width = SIDE_BOARD_WIDTH; rect.height = SCREEN_HEIGHT; rect.y = 0;
        rect.x = 0;                         screen.fillRect(rect, BACKGROUND_COLOR);
        rect.x = SCREEN_WIDTH - rect.width; screen.fillRect(rect, BACKGROUND_COLOR);
    }

    public static function contains(p:Vector3D):Boolean {
        return (p.x >= -size.x && p.x <= size.x && p.y >= -size.y && p.y <= size.y);
    }
}

// Blur effect.
const BLUR_MAX_COUNT:int = 512, BLUR_HISTORY_COUNT:int = 6;
var blurs:Vector.<Vector.<Blur>> = new Vector.<Vector.<Blur>>(BLUR_HISTORY_COUNT, true);
var blurCounts:Vector.<int> = new Vector.<int>(BLUR_HISTORY_COUNT, true);
var blurIndex:int;

class Blur {
    public var pos:Vector3D = new Vector3D;
    public var width:Number, height:Number;
    public var r:int, g:int, b:int;

    public function update():void {
        if (Player.zoom < 1.1) {
            rect.x = pos.x - width / 2 + SCREEN_WIDTH / 2 - Field.offsetX; 
            rect.y = pos.y - height / 2 + SCREEN_HEIGHT / 2; 
            rect.width = width; rect.height = height;
        } else {
            rect.width = width * Player.zoom; rect.height = height * Player.zoom;
            rect.x = (pos.x - Player.pos.x) * Player.zoom + Player.pos.x - rect.width / 2 +
                SCREEN_WIDTH / 2 - Field.offsetX; 
            rect.y = (pos.y - Player.pos.y) * Player.zoom + Player.pos.y - rect.height / 2 + SCREEN_HEIGHT / 2;
        }
        screen.fillRect(rect, r * 0x10000 + g * 0x100 + b);
        width *= 1.2; height *= 1.2;
        r += (BACKGROUND_BRIGHTNESS - r) * 0.2;
        g += (BACKGROUND_BRIGHTNESS - g) * 0.2;
        b += (BACKGROUND_BRIGHTNESS - b) * 0.2;
    }
}

function drawBox(x:Number, y:Number, w:int, h:int, color:int, blurSizeRatio:Number, br:int, bg:int, bb:int):void {
    if (Player.zoom < 1.1) {
        rect.x = x - w / 2 + SCREEN_WIDTH / 2 - Field.offsetX;
        rect.y = y - h / 2 + SCREEN_HEIGHT / 2;
        rect.width = w; rect.height = h;
    } else {
        var sx:Number = (x - Player.pos.x) * Player.zoom + Player.pos.x;
        var sy:Number = (y - Player.pos.y) * Player.zoom + Player.pos.y;
        rect.x = sx - w / 2 + SCREEN_WIDTH / 2 - Field.offsetX;
        rect.y = sy - h / 2 + SCREEN_HEIGHT / 2;
        rect.width = w * Player.zoom; rect.height = h * Player.zoom;
    }
    screen.fillRect(rect, color);
    if (blurSizeRatio > 0) addBlur(x, y, w * blurSizeRatio, h * blurSizeRatio, br, bg, bb);
}

function addBlur(x:Number, y:Number, w:Number, h:Number, r:int, g:int, b:int):void {
    if (blurCounts[blurIndex] >= BLUR_MAX_COUNT) return;
    var bl:Blur = blurs[blurIndex][blurCounts[blurIndex]];
    bl.pos.x = x; bl.pos.y = y;
    bl.width = w; bl.height = h;
    bl.r = r; bl.g = g; bl.b = b;
    blurCounts[blurIndex]++;
}

function updateBlurs():void {
    var bi:int = blurIndex + 1;
    for (var i:int = 0; i < BLUR_HISTORY_COUNT; i++) {
        if (bi >= BLUR_HISTORY_COUNT) bi = 0;
        for (var j:int = 0; j < blurCounts[bi]; j++) blurs[bi][j].update();
        bi++;
    }
    blurIndex++;
    if (blurIndex >= BLUR_HISTORY_COUNT) blurIndex = 0;
    blurCounts[blurIndex] = 0;
}

function initializeBlurs():void {
    for (var i:int = 0; i < BLUR_HISTORY_COUNT; i++) {
        var bs:Vector.<Blur> = new Vector.<Blur>(BLUR_MAX_COUNT, true);
        for (var j:int = 0; j < BLUR_MAX_COUNT; j++) bs[j] = new Blur;
        blurs[i] = bs; blurCounts[i] = 0;
    }
    blurIndex = 0;
}

// Handle the game lifecycle.
const GAME_OVER_DURATION:int = 150, BLOCK_GAME_START_DURATION:int = 30;
var gameOverTicks:int;

function startTitle():void {
    clearActors();
    gameOverTicks = GAME_OVER_DURATION;
    messageField.y = SCREEN_HEIGHT / 3 * 2; messageField.text = "CircleCycle";
}

function startGame():void {
    gameOverTicks = -1;
    clearActors(); Player.start();
    messageField.text = ""; scoreField.text = String(score = 0);
    extendScore = 200; rank = 0.0; stage = 0;
}

function startGameOver():void {
    gameOverTicks = 0; isMousePressed = false;
    messageField.y = SCREEN_HEIGHT / 2; messageField.text = "GAME OVER";
}

function clearActors():void {
    shots = null; bullets = null; sparks = null; bonuses = null; circles = null;
    shots = new Vector.<Shot>; bullets = new Vector.<Bullet>; sparks = new Vector.<Spark>; bonuses = new Vector.<Bonus>;
    circles = new Vector.<Circle>; targetCircleCount = 0;
}

// Utility classes, functions and variables.
var p:Vector3D = new Vector3D, offset:Vector3D = new Vector3D;
var rect:Rectangle = new Rectangle;
var rand:Function = Math.random, abs:Function = Math.abs;
var sin:Function = Math.sin, cos:Function = Math.cos, atan2:Function = Math.atan2;
var PI:Number = Math.PI;

function createTextField(x:int, y:int, width:int, size:int, color:int,
                         align:String = TextFormatAlign.LEFT):TextField {
    var fm:TextFormat = new TextFormat;
    fm.font = "_typewriter"; fm.bold = true;
    fm.size = size; fm.color = color; fm.align = align;
    var fi:TextField = new TextField;
    fi.defaultTextFormat = fm;
    fi.x = x; fi.y = y; fi.width = width; fi.selectable = false;
    return fi;
}

function drawCircle(pos:Vector3D, radius:Number, width:Number, color:int, xRatio:Number = 1.0):void {
    if (Player.zoom < 1.1) {
        p.x = pos.x + SCREEN_WIDTH / 2 - Field.offsetX;
        p.y = pos.y + SCREEN_HEIGHT / 2;
    } else {
        p.x = (pos.x - Player.pos.x) * Player.zoom + Player.pos.x + SCREEN_WIDTH / 2 - Field.offsetX;
        p.y = (pos.y - Player.pos.y) * Player.zoom + Player.pos.y + SCREEN_HEIGHT / 2;
    }
    drawCircleWithoutOffset(p, radius * Player.zoom, width, color, xRatio);
}

function drawCircleWithoutOffset(p:Vector3D, radius:Number, width:Number, color:int, xRatio:Number = 1.0):void {
    var c:int = radius * 1.5;
    var a:Number = 0, oa:Number = PI * 2 / c;
    rect.width = rect.height = width;
    for (var i:int = 0; i < c; i++) {
        rect.x = p.x + sin(a) * radius * xRatio - width / 2;
        rect.y = p.y + cos(a) * radius - width / 2;
        screen.fillRect(rect, color);
        a += oa;
    }
}

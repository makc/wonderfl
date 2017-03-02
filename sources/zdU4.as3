// forked from ABA's CircleCycle
// CircleCycle.as
//  Destroy circles and avoid incoming bullets.
//  <Control>
//   Movement: Arrow or [WASD] keys.
//   Fire:    [Z] or [/] key.
//   Slow:    [X] or [.] key.
package
{
    import flash.display.Sprite;

    [SWF(width="465", height="465", backgroundColor="0x000000", frameRate="30")]
    public class CircleCycle extends Sprite
    {
        public function CircleCycle()
        {
            main = this;
            initialize();
        }
    }
}

import flash.display.Sprite;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.Rectangle;
import flash.geom.Vector3D;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flash.events.Event;
import flash.events.KeyboardEvent;

const SCREEN_WIDTH:int = 465, SCREEN_HEIGHT:int = 465;
const BACKGROUND_BRIGHTNESS:int = 200;
const BACKGROUND_COLOR:int = BACKGROUND_BRIGHTNESS * 0x10000 + BACKGROUND_BRIGHTNESS * 0x100 + BACKGROUND_BRIGHTNESS;
const GAME_OVER_DURATION:int = 150, BLOCK_GAME_START_DURATION:int = 30;
var main:Sprite;
var screen:BitmapData = new BitmapData(SCREEN_WIDTH, SCREEN_HEIGHT, false, 0);
var scoreField:TextField = new TextField, timeField:TextField = new TextField, messageField:TextField = new TextField;
var gameOverTicks:int, score:int, stage:int, targetCircleCount:int, ticks:int, time:int;

function initialize():void
{
    main.addChild(new Bitmap(screen));
    main.stage.addEventListener(KeyboardEvent.KEY_DOWN, Key.onKeyDown);
    main.stage.addEventListener(KeyboardEvent.KEY_UP,   Key.onKeyUp);
    Field.initialize();
    initializeBlurs();
    scoreField = createTextField(SCREEN_WIDTH - 100, 0, 100, 24, 0xff6666, TextFormatAlign.RIGHT);
    timeField = createTextField(SCREEN_WIDTH / 2 - 120, SCREEN_HEIGHT - 40, 200, 40, 0xff6666, TextFormatAlign.RIGHT);
    messageField = createTextField(SCREEN_WIDTH - 256, 0, 256, 36, 0xff6666);
    main.addChild(scoreField); main.addChild(timeField); main.addChild(messageField);
    startTitle();
    main.addEventListener(Event.ENTER_FRAME, update);
}

function update(event:Event):void
{
    screen.lock();
    screen.fillRect(screen.rect, BACKGROUND_COLOR);
    updateBlurs();
    var i:int;
    for (i = 0; i < sparks.length; i++)  if (!sparks[i].update())  { sparks.splice(i, 1);  i--; }
    for (i = 0; i < shots.length; i++)   if (!shots[i].update())   { shots.splice(i, 1);   i--; }
    for (i = 0; i < bonuses.length; i++) if (!bonuses[i].update()) { bonuses.splice(i, 1); i--; }
    if (targetCircleCount <= 0) goToNextStage();
    if (ticks % 50 == 0) addBackgroundCircles((rand() - 0.5) * Field.size.x * 1.5,
                                              200.0 / (20.0 + stage), 5.0 + rand() * 2.0 + rand() * 2.0);
    ticks++;
    targetCircleCount = 0;
    for each (var c:Circle in circles) c.update();
    for (i = 0; i < circles.length; i++) if (!circles[i].exists)   { circles.splice(i, 1); i--; }
    if (gameOverTicks < 0) Player.update();
    for (i = 0; i < bullets.length; i++) if (!bullets[i].update()) { bullets.splice(i, 1); i--; }
    Field.drawSideBoard();
    screen.unlock();
    if (gameOverTicks < 0)
    {
        time -= 33;
        if (Key.button2) time -= 33;
        if (time <= 0)
        {
            time = 0; startGameClear();
        }
        var msStr:String = String(time % 1000);
        while (msStr.length < 3) msStr = "0" + msStr;
        timeField.text = String(int(time / 1000)) + "\"" + msStr;
    }
    else
    {
        gameOverTicks++;
        if (gameOverTicks == GAME_OVER_DURATION) startTitle();
        if (Key.button1 && gameOverTicks > BLOCK_GAME_START_DURATION) startGame();
    }
}

function goToNextStage():void
{
    if (rand() < 0.5) addTargetCircles((rand() - 0.5) * Field.size.x, 2,
                                       200.0 / (20.0 + stage), 5.0 + rand() * 2.0 + rand() * 2.0, false);
    else              addTargetCircles((rand() - 0.5) * Field.size.x * 0.7, 1,
                                       400.0 / (20.0 + stage), 5.0 + rand() * 2.0 + rand() * 2.0, true);
    stage += 15;
}

function startTitle():void
{
    clearActors();
    gameOverTicks = GAME_OVER_DURATION;
    messageField.y = SCREEN_HEIGHT / 3 * 2; messageField.text = "CircleCycle";
}

function startGame():void
{
    clearActors();
    Player.start();
    gameOverTicks = -1;
    messageField.text = "";
    score = 0; scoreField.text = "0"; stage = 0; time = 60000;
}

function startGameOver():void
{
    gameOverTicks = 0;
    messageField.y = SCREEN_HEIGHT / 2; messageField.text = "GAME OVER";
}

function startGameClear():void
{
    gameOverTicks = 0;
    messageField.y = SCREEN_HEIGHT / 2; messageField.text = "COMPLETE!";
}

function clearActors():void
{
    shots = null; bullets = null; sparks = null; bonuses = null; circles = null;
    shots = new Vector.<Shot>; bullets = new Vector.<Bullet>; sparks = new Vector.<Spark>; bonuses = new Vector.<Bonus>;
    circles = new Vector.<Circle>; targetCircleCount = 0;
}

// Game actor base class.
class Actor
{
    public var pos:Vector3D = new Vector3D;
}

class VelocityActor extends Actor
{
    public var vel:Vector3D = new Vector3D;
    public var ticks:int, disappearTicks:int = 300;

    public function update():Boolean
    {
        pos.incrementBy(vel);
        ticks++;
        if (!Field.contains(pos) || ticks > disappearTicks) return false;
        return true;
    }
}

// Player.
class Player
{
    private static const COLLISION_SIZE:Number = 5.0;
    private static const SPEED:Number = 9.0;
    public static var pos:Vector3D = new Vector3D;
    private static var fireTicks:int;

    public static function start():void
    {
        pos.x = 0; pos.y = Field.size.y * 0.5;
    }

    public static function update():void
    {
        offset.x = offset.y = 0;
        if (Key.left)  offset.x = -1;
        if (Key.right) offset.x = 1;
        if (Key.up)    offset.y = -1;
        if (Key.down)  offset.y = 1;
        if (offset.x != 0 && offset.y != 0) offset.scaleBy(0.7);
        if (Key.button2) offset.scaleBy(0.5);
        offset.scaleBy(SPEED); pos.incrementBy(offset);
        if (pos.x < -SCREEN_WIDTH  / 2) pos.x = -SCREEN_WIDTH / 2;
        if (pos.x >  SCREEN_WIDTH  / 2) pos.x =  SCREEN_WIDTH / 2;
        if (pos.y < -SCREEN_HEIGHT / 2) pos.y = -SCREEN_HEIGHT / 2;
        if (pos.y >  SCREEN_HEIGHT / 2) pos.y =  SCREEN_HEIGHT / 2;
        Field.offsetX = pos.x * 0.33;
        drawCircle(pos, 15, 7, 0x008800, 0.5);
        addBlur(pos.x, pos.y, 20, 20, 100, 200, 100);
        if (fireTicks <= 0 && shots.length <= 14 && Key.button1)
        {
            fireTicks = 2;
            var s:Shot;
            for (var i:int = 0; i < 7; i++)
            {
                s = new Shot;
                s.pos.x = pos.x; s.pos.y = pos.y;
                var a:Number = (i - 3) * 0.1;
                s.vel.x = sin(a) * 24.0; s.vel.y = -cos(a) * 24.0;
                shots.push(s);
            }
        }
        fireTicks--;
        for each (var b:Bullet in bullets)
        {
            if (Vector3D.distance(pos, b.pos) <= COLLISION_SIZE)
            {
                addSparks(100, Player.pos.x, Player.pos.y, 30.0, 15.0, 200, 100, 100);
                startGameOver(); break;
            }
        }
    }
}


// Player's shots.
var shots:Vector.<Shot>;

class Shot extends VelocityActor
{
    override public function update():Boolean
    {
        for each (var c:Circle in circles) if (checkHit(c)) return false;
        addBlur(pos.x, pos.y, 20, 15, 50, 150, 100);
        return super.update();
    }

    private function checkHit(c:Circle):Boolean
    {
        for each (var cc:Circle in c.children) if (cc.exists && checkHit(cc)) return true;
        if (c.exists && c.hasCollision && Vector3D.distance(pos, c.pos) < c.spec.visualRadius + 20.0)
        {
            addSparks(1, pos.x, pos.y, 20.0, 5.0, 50, 150, 100);
            c.damage(); return true;
        }
        return false;
    }
}

// Circles' bullets.
var bullets:Vector.<Bullet>;

class Bullet extends VelocityActor
{
    public var baseVel:Vector3D = new Vector3D;
    public var color:int, br:int, bg:int, bb:int, size:int;

    override public function update():Boolean
    {
        var sz:Number = 1.5 + Math.sin(ticks * 0.2) * 0.4;
        var a:Number = 0.8 + Math.sin(ticks * 0.45) * 0.2;
        drawBox(pos.x, pos.y, size, size, color, sz, br * a, bg * a, bb * a);
        if (ticks <= 15)
        {
            vel.x = baseVel.x * (ticks + 15) / 30.0; vel.y = baseVel.y * (ticks + 15) / 30.0;
        }
        else
        {
            vel.x = baseVel.x; vel.y = baseVel.y;
        }
        if (Key.button2) vel.scaleBy(0.5);
        return super.update();
    }
}

// Circles.
var circles:Vector.<Circle>;

class Circle extends Actor
{
    public var children:Vector.<Circle> = null;
    public var isTop:Boolean, exists:Boolean = true;
    public var spec:CircleSpec;
    public var bulletSpeedRatio:Number = 1.0;
    public var rollAngle:Number = 0, fireAngle:Number = 0, fireSpeed:Number, angleInterval:Number;
    public var baseAngle:Number = 0;
    public var ticks:int, shield:int;
    public var hasCollision:Boolean, isTarget:Boolean, isDamaged:Boolean;
    public var xReverse:Number = 1.0;
    public var circleWidth:Number = 5.0;
    public var color:int;

    public function start():void
    {
        color = (int)(spec.r / 2) * 0x10000 + int(spec.g / 2) * 0x100 + int(spec.b / 2);
        shield = spec.shield;
    }

    public function update():void
    {
        var vr:Number = spec.visualRadius;
        if (spec.fireInterval > 0) vr *= ((ticks % spec.fireInterval) / spec.fireInterval * 0.5 + 1.0);
        drawCircle(pos, vr, circleWidth, color);
        var i:int;
        if (isDamaged)
        {
            isDamaged = false;
            var da:Number = ticks * 0.1, sr:Number = spec.visualRadius, bc:int = sr * 0.5;
            for (i = 0; i < bc; i++)
            {
                addBlur(pos.x + sr * sin(da), pos.y + sr * cos(da),
                        9 + rand() * 7, 9 + rand() * 7, rand() * 128 + 64, rand() * 128 + 127, 64);
                da += PI * 2 / bc;
            }
        }
        if (spec.fireInterval > 0 && ticks % spec.fireInterval == 0 && pos.y < 0 &&
            pos.x - Field.offsetX > -Field.size.x + Field.SIDE_BOARD_WIDTH &&
            pos.x - Field.offsetX <  Field.size.x - Field.SIDE_BOARD_WIDTH &&
            (!spec.isAimingBaseAngle || Vector3D.distance(pos, Player.pos) > 120))
         {
            var ba:Number;
            if (spec.isAimingBaseAngle) ba = atan2(Player.pos.x - pos.x, Player.pos.y - pos.y);
            else ba = baseAngle * xReverse;
            ba += rollAngle + fireAngle;
            var srv:Number = -spec.bulletSpeedWhipVel * 2 / spec.bulletCount;
            for (i = 0; i < spec.bulletCount; i++) fire(ba, 1.0 + spec.bulletSpeedWhipVel + srv * i);
        }
        ticks++;
        if (isTop && isTarget && pos.y < -Field.size.y * 0.5) pos.y += 7.0;
        if (isTop && !isTarget)
        {
            pos.y += 3.0;
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
        for each (var c:Circle in children)
        {
            a += angleInterval;
            if (!c.exists) continue;
            c.pos.x = pos.x + sin(a) * spec.radius * xReverse;
            c.pos.y = pos.y + cos(a) * spec.radius;
            c.baseAngle = a + fireAngle;
            c.update();
        }
    }

    private function fire(a:Number, sr:Number):void
    {
        var b:Bullet = new Bullet;
        b.pos.x = pos.x; b.pos.y = pos.y;
        var bs:Number = spec.bulletSpeed * bulletSpeedRatio * sr;
        b.baseVel.x = sin(a) * bs; b.baseVel.y = cos(a) * bs;
        b.size = spec.bulletSize;
        b.br = spec.r; b.bg = spec.g; b.bb = spec.b;
        b.color = int(b.br / 4) * 0x10000 + int(b.bg / 4) * 0x100 + int(b.bb / 4);
        bullets.push(b);
    }

    public function damage():void
    {
        isDamaged = true;
        shield--;
        if (shield <= 0) remove(true);
    }

    public function remove(isDestroyed:Boolean = false):void
    {
        for each (var c:Circle in children) if (c.exists) c.remove();
        children = null;
        exists = false;
        if (!isDestroyed) return;
        var sa:Number = ticks * 0.1, sr:Number = spec.visualRadius, sc:int = sr * 0.5, i:int;
        for (i = 0; i < sc; i++)
        {
            addSparks(1, pos.x + sr * sin(sa), pos.y + sr * cos(sa), 10.0, 10.0, spec.r, spec.g, spec.b);
            sa += PI * 2 / sc;
        }
        addBonuses(sr * sr * 2 / (abs(pos.y - Player.pos.y) + 30.0), pos.x, pos.y, 10.0);
    }

    public function setXReverse():void
    {
        xReverse = -1.0;
        for each (var c:Circle in children) c.setXReverse();
    }
}

class CircleSpec
{
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
    public var bulletCount:int = 1, bulletSpeedWhipVel:Number = 0;
    public var r:int, g:int, b:int;
    public var childrenCount:int;
    public var shield:int;

    public function set(childrenCount:int, radius:Number, childRadius:Number):void
    {
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
        }
        else
        {
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

class Waveform
{
    public static const FIX:int = 0, MONOTONE:int = 1, SIN:int = 2;
    public var type:int = FIX, center:Number = 0, width:Number = 0, interval:int = 1;

    public function getValue(ticks:int):Number
    {
        switch (type)
        {
            case FIX:      return center;
            case MONOTONE: return center + width * ticks * 2 / interval;
            case SIN:      return center + width * sin(PI * 2 * ticks / interval);
        }
        return 0;
    }
}

function addTargetCircles(x:Number, depth:int, fireIntervalRatio:Number, bulletSpeed:Number, hasReversed:Boolean):void
{
    var radius:Number = (20 + rand() * 20) * depth;
    var c:Circle = new Circle;
    var rw:Number = 0;
    if (hasReversed) rw = (rand() * 0.1 + 0.1) * Field.size.x;
    var cy:Number = -Field.size.y * (1.0 + rand() * 2.0) - radius;
    c.pos.x = x - rw; c.pos.y = cy;
    c.isTop = true; c.hasCollision = true; c.isTarget = true;
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
    if (hasReversed)
    {
        c = new Circle;
        c.pos.x = x + rw; c.pos.y = cy;
        c.isTop = true; c.hasCollision = true; c.isTarget = true;
        addCircleChildren(c, sps.length - 1, sps, 1.0, 0);
        c.setXReverse();
        circles.push(c);
    }
}

function addBackgroundCircles(x:Number, fireIntervalRatio:Number, bulletSpeed:Number):void
{
    var radius:Number = (60 + rand() * 60);
    var c:Circle = new Circle;
    c.pos.x = x; c.pos.y = -Field.size.y - radius;
    c.isTop = true;
    c.circleWidth = 3.0;
    var csp:CircleSpec = new CircleSpec;
    csp.radius = 0; csp.visualRadius = 15.0; csp.childrenCount = 0;
    csp.shield = 3;
    csp.isAimingBaseAngle = true;
    csp.bulletSpeed = bulletSpeed;
    csp.r = csp.g = csp.b = 200;
    var sp:CircleSpec = new CircleSpec;
    sp.childrenCount = 3 + rand() * 7;
    csp.fireInterval = sp.childrenCount * fireIntervalRatio + 1;
    sp.radius = radius; sp.visualRadius = radius - csp.visualRadius;
    sp.rollAngle.width = (0.5 + rand() * 0.5) * ((int)(rand() * 2) * 2 - 1);
    sp.rollAngle.type = Waveform.MONOTONE;
    sp.rollAngle.interval = 60 + rand() * 60;
    sp.angleInterval.center = ((2.0 + rand() * 2.0) / sp.childrenCount);
    if (rand() < 0.5) sp.fireDelayVel = (8.0 + rand() * 6.0) * ((int)(rand() * 2) * 2 - 1);
    sp.r = sp.g = sp.b = 300;
    c.children = new Vector.<Circle>;
    var cct:int = 0;
    for (var i:int = 0; i < sp.childrenCount; i++)
    {
        var cc:Circle = new Circle;
        cc.hasCollision = true;
        cc.spec = csp; cc.start();
        cc.ticks = cct; cct += sp.fireDelayVel;
        c.children.push(cc);
    }
    c.spec = sp; c.start();
    circles.push(c);
}

function createCircleSpecs(sps:Vector.<CircleSpec>, radius:Number, depth:int, r:int, g:int, b:int):int
{
    var sp:CircleSpec = new CircleSpec;
    sp.r = r; sp.g = g; sp.b = b;
    var turretCount:int;
    if (depth == 0)
    {
        sp.radius = 0; sp.visualRadius = radius; sp.childrenCount = 0;
        if (rand() < 0.3)
        {
            sp.bulletCount = 2 + rand() * 5;
            sp.bulletSpeedWhipVel = 0.2 + rand() * 0.2;
            turretCount = sp.bulletCount * 0.75;
        }
        else turretCount = 1;
    }
    else
    {
        sp.childrenCount = 1 + rand() * 7;
        var cr:Number = radius * (0.33 + rand() * 0.1);
        sp.set(sp.childrenCount, radius, cr);
        turretCount = createCircleSpecs(sps, cr, depth - 1, r, g, b) * sp.childrenCount;
    }
    sps.push(sp);
    return turretCount;
}

function addCircleChildren(c:Circle, index:int, sps:Vector.<CircleSpec>,
                           bulletSpeedRatio:Number, fireDelay:Number):void
{
    var sp:CircleSpec = sps[index];
    var bsv:Number = -sp.bulletSpeedFanVel * 2 / sp.childrenCount;
    var fdv:Number = -sp.fireDelayVel * 2 / sp.childrenCount;
    if (sp.bulletSpeedFanType == CircleSpec.WEDGE) bsv *= 2;
    if (sp.fireDelayType == CircleSpec.WEDGE) fdv *= 2;
    if (sp.childrenCount > 0) c.children = new Vector.<Circle>;
    for (var i:int = 0; i < sp.childrenCount; i++)
    {
        var cc:Circle = new Circle;
        var bsr:Number;
        if (sp.bulletSpeedFanType == CircleSpec.FIX || i < sp.childrenCount / 2) bsr = 1.0 + sp.bulletSpeedFanVel + bsv * i;
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

// Sparks.
var sparks:Vector.<Spark>;

class Spark extends VelocityActor
{
    public var size:Number;
    public var r:int, g:int, b:int;

    override public function update():Boolean
    {
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

function addSparks(count:int, x:Number, y:Number, speed:Number, size:Number, r:int, g:int, b:int):void
{
    for (var i:int = 0; i < count; i++)
    {
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

class Bonus extends VelocityActor
{
    public var isInhaled:Boolean;

    override public function update():Boolean
    {
        var a:Number = ticks * 0.1;
        for (var i:int = 0; i < 4; i++)
        {
            drawBox(pos.x + sin(a) * 10 - 5, pos.y + cos(a) * 10 - 5, 8, 8, 0x6688aa, 1.0, 150, 200, 150);
            a += PI / 2;
        }
        if (isInhaled && gameOverTicks < 0)
        {
            vel.x += (Player.pos.x - pos.x) * 0.05; vel.y += (Player.pos.y - pos.y) * 0.05;
        }
        else vel.y += 0.5;
        vel.scaleBy(0.9);
        var d:Number = Vector3D.distance(pos, Player.pos);
        if (isInhaled && d < 40.0 && gameOverTicks < 0)
        {
            score++; scoreField.text = String(score); return false;
        }
        else if (d < 120.0 && vel.length < 5.0) isInhaled = true;
        return super.update();
    }
}

function addBonuses(count:int, x:Number, y:Number, speed:Number):void
{
    for (var i:int = 0; i < count; i++)
    {
        var b:Bonus = new Bonus;
        b.pos.x = x; b.pos.y = y;
        var a:Number = rand() * PI * 2, sp:Number = speed * (0.5 + rand());
        b.vel.x = Math.sin(a) * sp; b.vel.y = Math.cos(a) * sp;
        bonuses.push(b);
    }
}

// Game field.
class Field
{
    public static const SIDE_BOARD_WIDTH:Number = SCREEN_WIDTH / 6;
    public static var size:Vector3D = new Vector3D;
    public static var offsetX:Number = 0;

    public static function initialize():void
    {
        size.x = SCREEN_WIDTH * 1.1 / 2; size.y = SCREEN_HEIGHT * 1.1 / 2;
    }

    public static function drawSideBoard():void
    {
        rect.width = SIDE_BOARD_WIDTH; rect.height = SCREEN_HEIGHT; rect.y = 0;
        rect.x = 0;                         screen.fillRect(rect, BACKGROUND_COLOR);
        rect.x = SCREEN_WIDTH - rect.width; screen.fillRect(rect, BACKGROUND_COLOR);
    }

    public static function contains(p:Vector3D):Boolean
    {
        return (p.x >= -size.x && p.x <= size.x && p.y >= -size.y && p.y <= size.y);
    }
}

// Blur effect.
const BLUR_MAX_COUNT:int = 512, BLUR_HISTORY_COUNT:int = 6;
var blurs:Vector.<Vector.<Blur>> = new Vector.<Vector.<Blur>>(BLUR_HISTORY_COUNT, true);
var blurCounts:Vector.<int> = new Vector.<int>(BLUR_HISTORY_COUNT, true);
var blurIndex:int;

class Blur
{
    public var pos:Vector3D = new Vector3D;
    public var width:Number, height:Number;
    public var r:int, g:int, b:int;

    public function update():void
    {
        rect.x = pos.x - width  / 2 - Field.offsetX; rect.width = width;
        rect.y = pos.y - height / 2; rect.height = height;
        screen.fillRect(rect, r * 0x10000 + g * 0x100 + b);
        width *= 1.2; height *= 1.2;
        r += (BACKGROUND_BRIGHTNESS - r) * 0.2;
        g += (BACKGROUND_BRIGHTNESS - g) * 0.2;
        b += (BACKGROUND_BRIGHTNESS - b) * 0.2;
    }
}

function drawBox(x:Number, y:Number, w:int, h:int, color:int,
                 blurSizeRatio:Number, br:int, bg:int, bb:int):void
{
    rect.x = x - w / 2 + SCREEN_WIDTH / 2 - Field.offsetX;
    rect.y = y - h / 2 + SCREEN_HEIGHT / 2;
    rect.width = w; rect.height = h;
    screen.fillRect(rect, color);
    if (blurSizeRatio > 0) addBlur(x, y, w * blurSizeRatio, h * blurSizeRatio, br, bg, bb);
}

function addBlur(x:Number, y:Number, w:Number, h:Number, r:int, g:int, b:int):void
{
    if (blurCounts[blurIndex] >= BLUR_MAX_COUNT) return;
    var bl:Blur = blurs[blurIndex][blurCounts[blurIndex]];
    bl.pos.x = x + SCREEN_WIDTH / 2; bl.pos.y = y + SCREEN_HEIGHT / 2;
    bl.width = w; bl.height = h;
    bl.r = r; bl.g = g; bl.b = b;
    blurCounts[blurIndex]++;
}

function updateBlurs():void
{
    var bi:int = blurIndex + 1;
    for (var i:int = 0; i < BLUR_HISTORY_COUNT; i++)
    {
        if (bi >= BLUR_HISTORY_COUNT) bi = 0;
        for (var j:int = 0; j < blurCounts[bi]; j++) blurs[bi][j].update();
        bi++;
    }
    blurIndex++;
    if (blurIndex >= BLUR_HISTORY_COUNT) blurIndex = 0;
    blurCounts[blurIndex] = 0;
}

function initializeBlurs():void
{
    for (var i:int = 0; i < BLUR_HISTORY_COUNT; i++)
    {
        var bs:Vector.<Blur> = new Vector.<Blur>(BLUR_MAX_COUNT, true);
        for (var j:int = 0; j < BLUR_MAX_COUNT; j++) bs[j] = new Blur;
        blurs[i] = bs; blurCounts[i] = 0;
    }
    blurIndex = 0;
}

// Utility classes, functions and variables.
var pos:Vector3D = new Vector3D, offset:Vector3D = new Vector3D;
var rect:Rectangle = new Rectangle;
var rand:Function = Math.random, abs:Function = Math.abs;
var sin:Function = Math.sin, cos:Function = Math.cos, atan2:Function = Math.atan2;
var PI:Number = Math.PI;

class Key
{
    public static var left:Boolean, up:Boolean, right:Boolean, down:Boolean;
    public static var button1:Boolean, button2:Boolean;

    public static function onKeyDown(event:KeyboardEvent):void
    {
        switch (event.keyCode)
        {
            case 0x25:case 0x41: left =    true; break;
            case 0x26:case 0x57: up =      true; break;
            case 0x27:case 0x44: right =   true; break;
            case 0x28:case 0x53: down =    true; break;
            case 0x5a:case 0xbf: button1 = true; break;
            case 0x58:case 0xbe: button2 = true; break;
        }
    }

    public static function onKeyUp(event:KeyboardEvent):void
    {
        switch (event.keyCode)
        {
            case 0x25:case 0x41: left =    false; break;
            case 0x26:case 0x57: up =      false; break;
            case 0x27:case 0x44: right =   false; break;
            case 0x28:case 0x53: down =    false; break;
            case 0x5a:case 0xbf: button1 = false; break;
            case 0x58:case 0xbe: button2 = false; break;
        }
    }
}

function createTextField(x:int, y:int, width:int, size:int, color:int,
                         align:String = TextFormatAlign.LEFT):TextField
{
    var fm:TextFormat = new TextFormat;
    fm.font = "_typewriter"; fm.bold = true;
    fm.size = size; fm.color = color; fm.align = align;
    var fi:TextField = new TextField;
    fi.defaultTextFormat = fm;
    fi.x = x; fi.y = y; fi.width = width; fi.selectable = false;
    return fi;
}

function drawCircle(p:Vector3D, radius:Number, width:Number, color:int, xRatio:Number = 1.0):void
{
    pos.x = p.x + SCREEN_WIDTH / 2 - Field.offsetX;
    pos.y = p.y + SCREEN_HEIGHT / 2;
    var c:int = radius * 1.5;
    var a:Number = 0, oa:Number = PI * 2 / c;
    rect.width = rect.height = width;
    for (var i:int = 0; i < c; i++)
    {
        rect.x = pos.x + sin(a) * radius * xRatio - width / 2;
        rect.y = pos.y + cos(a) * radius - width / 2;
        screen.fillRect(rect, color);
        a += oa;
    }
}

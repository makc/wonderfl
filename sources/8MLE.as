// CircleCycle.as
//  Destroy circles and avoid incoming bullets.
//  <Control>
//   Movement: Arrow or [WASD] keys.
//   Fire:    [Z], [X], [.] or [/] key.
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
import flash.display.Graphics;
import flash.geom.Rectangle;
import flash.geom.Vector3D;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flash.events.Event;
import flash.events.KeyboardEvent;

const SCREEN_WIDTH:int = 465, SCREEN_HEIGHT:int = 465;
const TITLE:int = 0, GAME:int = 1, GAME_OVER:int = 2;
const GAME_OVER_DURATION:int = 150, BLOCK_GAME_START_DURATION:int = 30;
const BACKGROUND_BRIGHTNESS:int = 200;
const BACKGROUND_COLOR:int = BACKGROUND_BRIGHTNESS * 0x10000 + BACKGROUND_BRIGHTNESS * 0x100 + BACKGROUND_BRIGHTNESS;
var main:Sprite;
var screen:BitmapData = new BitmapData(SCREEN_WIDTH, SCREEN_HEIGHT, false, 0);
var scoreField:TextField = new TextField;
var timeField:TextField = new TextField;
var messageField:TextField = new TextField;
var score:int, time:int, stage:int, gameOverTicks:int;
var rect:Rectangle = new Rectangle;
var pos:Vector3D = new Vector3D, offset:Vector3D = new Vector3D;
var rand:Function = Math.random, abs:Function = Math.abs;
var sin:Function = Math.sin, cos:Function = Math.cos, atan2:Function = Math.atan2;
var PI:Number = Math.PI;

function initialize():void
{
    main.addChild(new Bitmap(screen));
    main.stage.addEventListener(KeyboardEvent.KEY_DOWN, Key.onKeyDown);
    main.stage.addEventListener(KeyboardEvent.KEY_UP,   Key.onKeyUp);
    Field.initialize();
    initializeBlurs();
    player.initialize();
    scoreField = createTextField(SCREEN_WIDTH - 100, 0, 100, 24, 0xff6666, TextFormatAlign.RIGHT);
    timeField = createTextField(SCREEN_WIDTH / 2 - 100, SCREEN_HEIGHT - 48, 200, 48, 0xff6666, TextFormatAlign.RIGHT);
    messageField = createTextField(SCREEN_WIDTH - 256, 0, 256, 36, 0xff6666);
    main.addChild(scoreField); main.addChild(timeField); main.addChild(messageField);
    start(TITLE);
    main.addEventListener(Event.ENTER_FRAME, update);
}

function update(event:Event):void
{
    if (circles.length <= 0) goToNextStage();
    screen.lock();
    screen.fillRect(screen.rect, BACKGROUND_COLOR);
    updateBlurs();
    var i:int;
    for (i = 0; i < sparks.length; i++)  if (!sparks[i].update())  { sparks.splice(i, 1); i--; }
    for (i = 0; i < shots.length; i++)   if (!shots[i].update())   { shots.splice(i, 1);  i--; }
    for each (var c:Circle in circles) c.update();
    for (i = 0; i < circles.length; i++) if (!circles[i].exists)   { circles.splice(i, 1); i--; }
    if (gameOverTicks < 0) player.update();
    for (i = 0; i < bullets.length; i++) if (!bullets[i].update()) { bullets.splice(i, 1); i--; }
    Field.drawSideBoard();
    screen.unlock();
    if (gameOverTicks < 0)
    {
        var msStr:String = String(time % 1000);
        while (msStr.length < 3) msStr = "0" + msStr;
        timeField.text = String(int(time / 1000)) + "\"" + msStr;
        if (time <= 0) start(GAME_OVER);
        time -= 33;
    }
    else
    {
        gameOverTicks++;
        if (gameOverTicks == GAME_OVER_DURATION) start(TITLE);
        if (Key.button1 && gameOverTicks > BLOCK_GAME_START_DURATION) start(GAME);
    }
}

function goToNextStage():void
{
    if (gameOverTicks < 0 && stage > 0) score += time;
    scoreField.text = String(score);
    stage++;
    time = 5000;
    addCircles((rand() - 0.5) * Field.size.x, 2, 50.0 / (20.0 + stage), 5.0 + rand() * 2.0 + rand() * 2.0);
}

function start(mode:int):void
{
    switch (mode)
    {
        case TITLE:
        {
            clearActors();
            player.hide();
            gameOverTicks = GAME_OVER_DURATION;
            messageField.y = SCREEN_HEIGHT / 3 * 2; messageField.text = "CircleCycle";
            break;
        }
        case GAME:
        {
            clearActors();
            player.start();
            gameOverTicks = -1;
            messageField.text = "";
            score = 0; stage = 0;
            break;
        }
        case GAME_OVER:
        {
            player.hide();
            gameOverTicks = 0;
            messageField.y = SCREEN_HEIGHT / 2; messageField.text = "GAME OVER";
            timeField.text = "";
            break;
        }
    }
}

function clearActors():void
{
    shots = null; bullets = null; sparks = null;
    shots = new Vector.<Shot>; bullets = new Vector.<Bullet>; sparks = new Vector.<Spark>;
    for each (var c:Circle in circles) c.remove();
    circles = null; circles = new Vector.<Circle>;
}

// Game actor base class.
class Actor
{
    public var pos:Vector3D = new Vector3D;
}

class VelocityActor extends Actor
{
    public var vel:Vector3D = new Vector3D;
    public var ticks:int;

    public function update():Boolean
    {
        pos.incrementBy(vel);
        ticks++;
        if (!Field.contains(pos) || ticks > 300) return false;
        return true;
    }
}

// Player.
var player:Player = new Player;

class Player extends Actor
{
    private const INVINCIBLE_DURATION:int = 90;
    private const COLLISION_SIZE:Number = 5.0;
    private const SPEED:Number = 9.0;
    private var vel:Vector3D = new Vector3D;
    private var fireTicks:int;
    private var sprite:Sprite = new Sprite;

    public function initialize():void
    {
        var g:Graphics = sprite.graphics;
        g.lineStyle(5, 0x008800);
        g.moveTo(0, -10); g.lineTo(-10,10); g.lineTo(10, 10); g.lineTo(0, -10);
        main.addChild(sprite);
    }

    public function start():void
    {
        pos.x = 0; pos.y = Field.size.y * 0.5;
        vel.y = -5.0;
    }

    public function hide():void
    {
        sprite.x = sprite.y = 99999;
    }

    public function update():void
    {
        offset.x = offset.y = 0;
        if (Key.left)  offset.x = -1;
        if (Key.right) offset.x = 1;
        if (Key.up)    offset.y = -1;
        if (Key.down)  offset.y = 1;
        if (offset.x != 0 && offset.y != 0) offset.scaleBy(0.7);
        offset.scaleBy(SPEED); pos.incrementBy(offset);
        pos.incrementBy(vel); vel.scaleBy(0.9);
        if (pos.x < -SCREEN_WIDTH  / 2) pos.x = -SCREEN_WIDTH / 2;
        if (pos.x >  SCREEN_WIDTH  / 2) pos.x =  SCREEN_WIDTH / 2;
        if (pos.y < -SCREEN_HEIGHT / 2) pos.y = -SCREEN_HEIGHT / 2;
        if (pos.y >  SCREEN_HEIGHT / 2) pos.y =  SCREEN_HEIGHT / 2;
        Field.offsetX = pos.x * 0.33;
        sprite.x = pos.x + SCREEN_WIDTH / 2 - Field.offsetX;
        sprite.y = pos.y + SCREEN_WIDTH / 2;
        var bc:int = time * 150 / 5000;
        addBlur(pos.x, pos.y - 7, 7, 7, 250 - bc, 50 + bc, 100);
        addBlur(pos.x, pos.y + 3, 15, 15, 250 - bc, 50 + bc, 100);
        drawBox(pos.x + time * 0.02 / 2, pos.y + 15, time * 0.02, 10,
                (150 - bc) * 0x10000 + bc * 0x100, 0, 0, 0, 0);
        var i:int;
        if (fireTicks <= 0 && shots.length <= 7 && abs(vel.y) < 1.0 && Key.button1)
        {
            fireTicks = 2;
            var s:Shot;
            for (i = 0; i < 7; i++)
            {
                s = new Shot;
                s.pos.x = pos.x; s.pos.y = pos.y;
                var d:Number = (i - 3) * 0.1;
                s.vel.x = sin(d) * 24.0; s.vel.y = -cos(d) * 24.0;
                shots.push(s);
            }
        }
        fireTicks--;
        i = 0;
        for each (var b:Bullet in bullets)
        {
            if (Vector3D.distance(pos, b.pos) <= COLLISION_SIZE)
            {
                if (vel.y < 1.0)
                {
                    vel.y += 20.0;
                    addSparks(50, pos.x, pos.y, 30.0, 15.0, 200, 200, 100);
                    time /= 2;
                }
                else
                {
                    bullets.splice(i, 1); i--;
                }
            }
            i++;
        }
    }
}


// Player's shots.
var shots:Vector.<Shot> = new Vector.<Shot>;

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
        if (c.exists && c.hasCollision && Vector3D.distance(pos, c.pos) < c.spec.spriteRadius + 20.0)
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
        return super.update();
    }
}

// Circles.
var circles:Vector.<Circle> = new Vector.<Circle>;

class Circle extends Actor
{
    public var children:Vector.<Circle> = new Vector.<Circle>;
    public var isTop:Boolean, exists:Boolean = true;
    public var spec:CircleSpec;
    public var bulletSpeedRatio:Number = 1.0;
    public var rollAngle:Number, fireAngle:Number, fireSpeed:Number, angleInterval:Number;
    public var baseAngle:Number;
    public var ticks:int, shield:int;
    public var hasCollision:Boolean;
    public var isDamaged:Boolean;
    public var sprite:Sprite = new Sprite;

    public function start():void
    {
        var g:Graphics = sprite.graphics;
        g.clear();
        g.lineStyle(5, (int)(spec.r / 2) * 0x10000 + int(spec.g / 2) * 0x100 + int(spec.b / 2));
        g.drawCircle(0, 0, spec.spriteRadius);
        main.addChild(sprite);
        baseAngle = rollAngle = fireAngle = 0;
        shield = spec.shield;
    }

    public function update():void
    {
        sprite.x = pos.x + SCREEN_WIDTH / 2 - Field.offsetX;
        sprite.y = pos.y + SCREEN_HEIGHT / 2;
        var i:int;
        if (isDamaged)
        {
            isDamaged = false;
            var da:Number = ticks * 0.1, sr:Number = spec.spriteRadius, bc:int = sr * 0.5;
            for (i = 0; i < bc; i++)
            {
                addBlur(pos.x + sr * sin(da), pos.y + sr * cos(da),
                        9 + rand() * 7, 9 + rand() * 7, rand() * 128 + 127, rand() * 128, 0);
                da += PI * 2 / bc;
            }
        }
        if (spec.fireInterval > 0 && ticks % spec.fireInterval == 0 && pos.y < 0)
        {
            if (spec.isAimingBaseAngle) baseAngle = atan2(player.pos.x - pos.x, player.pos.y - pos.y);
            var ba:Number = baseAngle + rollAngle + fireAngle;
            var srv:Number = -spec.bulletSpeedWhipVel * 2/ spec.bulletCount;
            for (i = 0; i < spec.bulletCount; i++) fire(ba, 1.0 + spec.bulletSpeedWhipVel + srv * i);
        }
        ticks++;
        if (spec.childrenCount <= 0) return;
        rollAngle = spec.rollAngle.getValue(ticks);
        fireAngle = spec.fireAngle.getValue(ticks);
        fireSpeed = spec.fireSpeed.getValue(ticks);
        angleInterval = spec.angleInterval.getValue(ticks);
        if (spec.isAimingRollAngle) rollAngle += atan2(player.pos.x - pos.x, player.pos.y - pos.y);
        var a:Number = rollAngle - angleInterval * (children.length - 1) / 2 - angleInterval;
        for each (var c:Circle in children)
        {
            a += angleInterval;
            if (!c.exists) continue;
            c.pos.x = pos.x + sin(a) * spec.radius;
            c.pos.y = pos.y + cos(a) * spec.radius;
            c.baseAngle = a + fireAngle;
            c.update();
        }
        if (isTop && pos.y < -Field.size.y * 0.5) pos.y += 7.0;
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
        main.removeChild(sprite);
        for each (var c:Circle in children) if (c.exists) c.remove();
        exists = false;
        if (!isDestroyed) return;
        var ba:Number = ticks * 0.1, sr:Number = spec.spriteRadius, bc:int = sr * 0.5;
        for (var i:int = 0; i < bc; i++)
        {
            addSparks(1, pos.x + sr * sin(ba), pos.y + sr * cos(ba), 10.0, 10.0, spec.r, spec.g, spec.b);
            ba += PI * 2 / bc;
        }
    }
}

class CircleSpec
{
    public static const FIX:int = 0, WEDGE:int = 1;
    public var radius:Number, spriteRadius:Number;
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
        this.radius = radius; spriteRadius = radius + childRadius;
        shield = radius * 0.7;
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

function addCircles(x:Number, depth:int, fireIntervalRatio:Number, bulletSpeed:Number):void
{
    var radius:Number = (20 + rand() * 20) * depth;
    var c:Circle = new Circle;
    c.pos.x = x; c.pos.y = -Field.size.y - radius;
    c.isTop = true; c.hasCollision = true;
    var r:int, g:int, b:int;
    r = 127 + rand() * 128; g = 127 + rand() * 128; b = 127 + rand() * 128;
    var sps:Vector.<CircleSpec> = new Vector.<CircleSpec>;
    var turretCount:int = createCircleSpecs(sps, radius, depth, r, g, b);
    var sp:CircleSpec;
    for each (sp in sps) if (sp.isRound) turretCount *= 0.75;
    sp = sps[0];
    sp.fireInterval = turretCount * fireIntervalRatio + 1;
    sp.bulletSpeed = bulletSpeed; sp.bulletSize = 10.0 + depth * 3;
    addCircleChildren(c, sps.length - 1, sps, 1.0, 0);
    circles.push(c);
}

function createCircleSpecs(sps:Vector.<CircleSpec>, radius:Number, depth:int, r:int, g:int, b:int):int
{
    var sp:CircleSpec = new CircleSpec;
    sp.r = r; sp.g = g; sp.b = b;
    var turretCount:int;
    if (depth == 0)
    {
        sp.radius = 0; sp.spriteRadius = radius; sp.childrenCount = 0;
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

function addSparks(count:int, x:Number, y:Number, speed:Number, size:Number, r:int, g:int ,b:int):void
{
    for (var i:int = 0; i < count; i++)
    {
        var s:Spark = new Spark;
        s.pos.x = x; s.pos.y = y;
        var a:Number = rand() * PI * 2, sp:Number = speed * (0.5 + rand());
        s.vel.x = Math.sin(a) * sp; s.vel.y = Math.cos(a) * sp;
        s.size = size;
        s.r = r; s.g = g; s.b = b;
        s.ticks = 15 + 15 * rand();
        sparks.push(s);
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

// Utility classes and functions.
class Key
{
    public static var left:Boolean, up:Boolean, right:Boolean, down:Boolean;
    public static var button1:Boolean;

    public static function onKeyDown(event:KeyboardEvent):void
    {
        switch (event.keyCode)
        {
            case 0x25:case 0x41: left =    true; break;
            case 0x26:case 0x57: up =      true; break;
            case 0x27:case 0x44: right =   true; break;
            case 0x28:case 0x53: down =    true; break;
            case 0x5a:case 0xbf:
            case 0x58:case 0xbe: button1 = true; break;
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
            case 0x5a:case 0xbf:
            case 0x58:case 0xbe: button1 = false; break;
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

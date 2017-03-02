// BallBlast.as
//  - Blast while balls.
//  - When the red ball is blasted or the ball reaches the celling,
//    the game is over.
//  <Control>
//   Mouse: Move the red ring.
//   Click: Blast balls in the red ring.
package
{
    import flash.display.Sprite;
    import flash.events.Event;

    [SWF(width="465", height="465", backgroundColor="0x000000", frameRate="30")]
    public class BallBlast extends Sprite
    {
        public function BallBlast()
        {
            main = this;
            initialize();
            addEventListener(Event.ENTER_FRAME, update);
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
import flash.events.MouseEvent;

const SCREEN_WIDTH:int = 465;
const SCREEN_HEIGHT:int = 465;
var main:Sprite;
var buffer:BitmapData = new BitmapData(SCREEN_WIDTH, SCREEN_HEIGHT, false, 0);
var isMouseClicked:Boolean;
var mousePos:Vector3D = new Vector3D;
var rect:Rectangle = new Rectangle;
var offset:Vector3D = new Vector3D;
var ticks:int;
var scoreField:TextField = new TextField;
var score:int;
const GAME_OVER_DURATION:int = 150;
const NO_START_DURATION:int = 30;
var gameOverTicks:int;
var lastBall:Ball;
var messageField:TextField = new TextField;

function initialize():void
{
    main.addChild(new Bitmap(buffer));
    main.stage.addEventListener(MouseEvent.CLICK, function(e:Event):void { isMouseClicked = true; } );
    Field.initialize();
    initializeBlurs();
    scoreField = createTextField(SCREEN_WIDTH - 100, 0, 100, 24, 0xff6666, TextFormatAlign.RIGHT);
    main.addChild(scoreField);
    messageField = createTextField(SCREEN_WIDTH - 256, 0, 256, 36, 0xff6666);
    main.addChild(messageField);
    startTitle();
}

function update(event:Event):void
{
    mousePos.x = main.stage.mouseX - SCREEN_WIDTH / 2;
    mousePos.y = main.stage.mouseY - SCREEN_HEIGHT / 2;
    if (isMouseClicked)
    {
        isMouseClicked = false;
        if (gameOverTicks < 0) blastBalls(mousePos);
        else if (gameOverTicks > NO_START_DURATION) startGame();
    }
    buffer.lock();
    buffer.fillRect(buffer.rect, 0);
    updateBlurs();
    updateSparks();
    var b:Ball;
    for each (b in balls) b.update();
    for each (b in balls) if (!b.isRed) b.draw();
    for each (b in balls) if (b.isRed)  b.draw();
    if (gameOverTicks < 0) drawBlastCircle();
    buffer.unlock();
    if (gameOverTicks < 0 || gameOverTicks > GAME_OVER_DURATION)
    {
        if (ticks % 5 == 0)    balls.push(new Ball(false));
        if (ticks % 256 == 50) balls.push(new Ball(true));
    }
    ticks++;
    if (gameOverTicks >= 0)
    {
        if (gameOverTicks == GAME_OVER_DURATION) startTitle();
        gameOverTicks++;
        if (lastBall != null) lastBall.draw();
    }
}

function drawBlastCircle():void
{
    offset.x = 0; offset.y = BALL_BLAST_RADIUS;
    rotation(offset, ticks * 0.05);
    for (var i:int = 0; i < 16; i++)
    {
        drawBox(mousePos.x + offset.x, mousePos.y + offset.y, 7, 0xee0000,
                13, 200, 100, 100);
        rotation(offset, Math.PI * 2 / 16);
    }
}

function startTitle():void
{
    ticks = 0;
    lastBall = null;
    gameOverTicks = GAME_OVER_DURATION;
    messageField.y = SCREEN_HEIGHT / 3;
    messageField.text = "BallBlast";
}

function startGame():void
{
    blastAllBalls();
    lastBall = null;
    score = 0;
    scoreField.text = String(score);
    ticks = 0;
    gameOverTicks = -1;
    messageField.text = "";
}

function startGameOver():void
{
    blastAllBalls();
    if (gameOverTicks >= 0) return;
    gameOverTicks = 0;
    messageField.y = SCREEN_HEIGHT / 2;
    messageField.text = "GAME OVER";
}

// Balls.
const BALL_BLAST_RADIUS:Number = 64.0;
var balls:Vector.<Ball> = new Vector.<Ball>;

class Ball
{
    private const GRAVITY_FORCE:Number = 0.5;
    private const MAX_VELOCITY_CHANGE:Number = 0.5;
    public var pos:Vector3D = new Vector3D;
    public var vel:Vector3D = new Vector3D;
    public var radius:Number;
    public var angle:Number, angleVel:Number;
    public var isInAppearance:Boolean;
    public var isRed:Boolean;

    public function Ball(isRed:Boolean):void
    {
        if (!isRed)
        {
            radius = 20.0 + Math.random() * 20.0;
            pos.x = (Math.random() * 2 - 1) * (Field.size.x - radius * 1.1);
            pos.y = Field.size.y + radius * 1.1;
            isInAppearance = true;
        }
        else
        {
            radius = 20.0;
            pos.x = 0; pos.y = -Field.size.y * 0.8;
            isInAppearance = false;
        }
        vel.x = vel.y = 0;
        angle = Math.random() * Math.PI * 2;
        angleVel = (Math.random() * 2 - 1) * 0.1;
        this.isRed = isRed;
    }

    public function update():void
    {
        if (isInAppearance)
        {
            vel.y -= GRAVITY_FORCE * 2;
            if (pos.y < Field.size.y - radius) isInAppearance = false;
        }
        else
        {
            if (pos.y > Field.size.y - radius) hit(pos.y - (Field.size.y - radius), 0);
            vel.y += GRAVITY_FORCE;
        }
        vel.scaleBy(0.95);
        pos.incrementBy(vel);
        if (pos.y < -Field.size.y + radius)
        {
            if (gameOverTicks < 0) lastBall = this;
            startGameOver();
            return;
        }
        if (pos.x > Field.size.x - radius) hit(pos.x - (Field.size.x - radius), Math.PI / 2);
        if (pos.x < -Field.size.x + radius) hit((-Field.size.y + radius) - pos.x, Math.PI / 2 * 3);
        for each (var b:Ball in balls)
        {
            if (b == this) continue;
            var d:Number = radius + b.radius - Vector3D.distance(pos, b.pos);
            if (d > 0) hit(d, Math.atan2(b.pos.x - pos.x, b.pos.y - pos.y));
        }
        angle += angleVel; angleVel *= 0.95;
    }

    public function draw():void
    {
        offset.x = 0; offset.y = radius / 2;
        rotation(offset, angle);
        var color:int , r:int ,g:int, b:int;
        if (!isRed)
        {
            color = 0xeeeeee; r = 200; g = 200; b = 200;
        }
        else
        {
            color = 0xff0000; r = 250; g = 200; b = 200;
        }
        for (var i:int = 0; i < 3; i++)
        {
            drawBox(pos.x + offset.x, pos.y + offset.y, radius, color, radius, r, g, b);
            rotation(offset, Math.PI * 2 / 3);
        }
    }

    private function hit(d:Number, a:Number):void
    {
        if (isInAppearance) return;
        var sv:Number = Math.sin(a) * d, cv:Number = Math.cos(a) * d;
        pos.x -= sv / 2; pos.y -= cv / 2;
        angleVel += (-sv * 0.1 - angleVel) * 0.1;
        sv *= 0.1 * vel.x; cv *= 0.1 * vel.y;
        if (sv > MAX_VELOCITY_CHANGE) sv = MAX_VELOCITY_CHANGE;
        if (sv < -MAX_VELOCITY_CHANGE) sv = -MAX_VELOCITY_CHANGE;
        if (cv > MAX_VELOCITY_CHANGE) cv = MAX_VELOCITY_CHANGE;
        if (cv < -MAX_VELOCITY_CHANGE) cv = -MAX_VELOCITY_CHANGE;
        vel.x -= sv; vel.y -= cv;
    }
}

function blastBalls(p:Vector3D):void
{
    var bc:int = 0;
    var b:Ball;
    for each (b in balls)
    {
        if (Vector3D.distance(b.pos, p) < BALL_BLAST_RADIUS + b.radius)
        {
            if (b.isRed)
            {
                lastBall = b;
                startGameOver();
                return;
            }
            bc++;
        }
    }
    score += bc;
    scoreField.text = String(score);
    for (var i:int = 0; i < balls.length; i++)
    {
        b = balls[i];
        if (Vector3D.distance(b.pos, p) < BALL_BLAST_RADIUS + b.radius)
        {
            addSparks(10, b.pos, 20.0, 20.0, 250, 250, 250);
            balls.splice(i, 1); i--;
        }
    }
}

function blastAllBalls():void
{
    for each (var b:Ball in balls) addSparks(5, b.pos, 20.0, 20.0, 250, 0, 0);
    balls = new Vector.<Ball>;
}

// Sparks.
var sparks:Vector.<Spark> = new Vector.<Spark>;

class Spark
{
    public var pos:Vector3D = new Vector3D;
    public var vel:Vector3D = new Vector3D;
    public var size:Number;
    public var r:int, g:int, b:int;
    public var ticks:int;

    public function update():Boolean
    {
        pos.incrementBy(vel);
        vel.y += 0.5;
        vel.scaleBy(0.99);
        size *= 0.95;
        r *= 0.98; g *= 0.98; b *= 0.98;
        if (pos.x < -Field.size.x && vel.x < 0 ||
            pos.x >  Field.size.x && vel.x > 0) vel.x *= -1;
        if (pos.y < -Field.size.y && vel.y < 0 ||
            pos.y >  Field.size.y && vel.y > 0) vel.y *= -1;
        var cr:Number = Math.random();
        drawBox(pos.x, pos.y, size, r * 0x10000 + g * 0x100 + b, size, r * cr, g * cr, b * cr);
        ticks--;
        return (ticks >= 0);
    }
}

function addSparks(count:int, p:Vector3D, speed:Number, size:Number, r:int, g:int ,b:int):void
{
    for (var i:int = 0; i < count; i++)
    {
        var s:Spark = new Spark;
        s.pos.x = p.x; s.pos.y = p.y;
        var a:Number = Math.random() * Math.PI * 2;
        var sp:Number = speed * (0.5 + Math.random());
        s.vel.x = Math.sin(a) * sp; s.vel.y = Math.cos(a) * sp;
        s.size = size;
        s.r = r; s.g = g; s.b = b;
        s.ticks = 15 + 15 * Math.random();
        sparks.push(s);
    }
}

function updateSparks():void
{
    for (var i:int = 0; i < sparks.length; i++)
    {
        if (!sparks[i].update())
        {
            sparks.splice(i, 1); i--;
        }
    }
}

// Game field.
class Field
{
    public static var size:Vector3D = new Vector3D;

    public static function initialize():void
    {
        size.x = SCREEN_WIDTH * 0.9 / 2; size.y = SCREEN_HEIGHT * 0.9 / 2;
    }

    public static function contains(p:Vector3D):Boolean
    {
        return (p.x >= -size.x && p.x <= size.x && p.y >= -size.y && p.y <= size.y);
    }
}

// Blur effect.
const BLUR_MAX_COUNT:int = 512;
const BLUR_HISTORY_COUNT:int = 6;
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
        rect.x = pos.x - width / 2;
        rect.y = pos.y - height / 2;
        rect.width = width; rect.height = height;
        buffer.fillRect(rect, r * 0x10000 + g * 0x100 + b);
        width *= 1.2; height *= 1.2;
        var a:int = (r + g + b) / 3;
        r += (a - r) * 0.25;
        g += (a - g) * 0.25;
        b += (a - b) * 0.25;
        r *= 0.65; g *= 0.65; b *= 0.65;
    }
}

function drawBox(x:Number, y:Number, size:int, color:int,
                 bsize:int, br:int, bg:int, bb:int):void
{
    rect.x = x - size / 2 + SCREEN_WIDTH / 2;
    rect.y = y - size / 2 + SCREEN_HEIGHT / 2;
    rect.width = rect.height = size;
    buffer.fillRect(rect, color);
    addBlur(x, y, bsize, bsize, br, bg, bb);
}

function addBlur(x:Number, y:Number, w:Number, h:Number,
                 r:int, g:int, b:int):void
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
        for (var j:int = 0; j < BLUR_MAX_COUNT; j++)
        {
            bs[j] = new Blur;
        }
        blurs[i] = bs;
        blurCounts[i] = 0;
    }
    blurIndex = 0;
}

// Utility functions.
function rotation(v:Vector3D, a:Number):void
{
    var sv:Number = Math.sin(a);
    var cv:Number = Math.cos(a);
    var rx:Number = cv * v.x - sv * v.y;
    v.y = sv * v.x + cv * v.y;
    v.x = rx;
}

function normalizeAngle(v:Number):Number
{
    if (v > Math.PI)       return v - Math.PI * 2;
    else if (v < -Math.PI) return v + Math.PI * 2;
    else                   return v;
}

function createTextField(x:int, y:int, width:int, size:int, color:int,
                         align:String = TextFormatAlign.LEFT):TextField
{
    var fm:TextFormat = new TextFormat;
    fm.font = "_typewriter"; fm.bold = true;
    fm.size = size; fm.color = color;
    fm.align = align;
    var fi:TextField = new TextField;
    fi.defaultTextFormat = fm;
    fi.x = x; fi.y = y; fi.width = width;
    fi.selectable = false;
    return fi;
}

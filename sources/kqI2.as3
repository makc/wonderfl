package {
    import flash.display.Sprite;
    [SWF(width="465", height="465", backgroundColor="0", frameRate="30")]
    public class Main extends Sprite {
        public const WIDTH:int = 465, HEIGHT:int = 465;
        public function Main() { main = this; initializeFirst(); }
    }
}
class Actor {
    public static function update(s:*):void {
        for (var i:int = 0; i < s.length; i++) if (!updateActor(s[i])) s.splice(i--, 1);
    }
    public static function updateActor(a:*):Boolean {
        var f:Boolean = a.update();
        a.move();
        return f;
    }
    public var pos:Vec = new Vec, vel:Vec = new Vec;
    public function move():void {
        pos.incrementBy(vel);
    }
}
//----------------------------------------------------------------
const TITLE:String = "commandmissile";
const DEBUG:Boolean = false;
function initialize():void {
    missiles = new Vector.<Missile>;
    explosions = new Vector.<Explosion>;
    enemyMissileAppTicks = playerMissileAppTicks = 0;
    youMissileAppTicks = 1;
    targetMissile = null;
}
var colors:Array = [Color.red, Color.green, Color.blue,
Color.yellow, Color.magenta, Color.cyan, Color.white];
var colorsIndex:int;
var enemyMissileAppTicks:int, playerMissileAppTicks:int, youMissileAppTicks:int;
var targetMissile:Missile;
function update():void {
    if (++colorsIndex >= colors.length) colorsIndex = 0;
    if (--enemyMissileAppTicks <= 0) {
        var m:Missile = new Missile;
        m.setEnemy();
        missiles.push(m);
        enemyMissileAppTicks = 30 / (1 + ticks * 0.001);
    }
    if (--playerMissileAppTicks <= 0) {
        if (rand.i(3) == 0 || (targetMissile && targetMissile.isDestroyed)) {
            targetMissile = null;
        }
        if (!targetMissile) {
            for each (m in missiles) {
                if (m.isPlayers || m.isYou || m.pos.y < screen.size.y * 0.2) continue;
                if (rand.i(3) == 0) targetMissile = m;
            }
        }
        if (targetMissile) {
            m = new Missile;
            m.setPlayer(targetMissile.pos.x + targetMissile.vel.x * rand.i(30, 10),
            targetMissile.pos.y + targetMissile.vel.y * rand.i(30, 10));
            missiles.push(m);
        }
        var it:Number = 5 / (1 + ticks * 0.001);
        playerMissileAppTicks = rand.n(it * 3, it);
    }
    if (isInGame && --youMissileAppTicks == 0) {
        m = new Missile;
        m.setYou();
        missiles.push(m);
    }
    Actor.update(missiles);
    Actor.update(explosions);
    screen.fillRect(screen.center.x, screen.size.y * 0.975, screen.size.x, screen.size.y * 0.05, Color.yellow.i);
}
var missiles:Vector.<Missile>;
class Missile extends Actor {
    public var isPlayers:Boolean, isYou:Boolean;
    public var isDestroyed:Boolean;
    private var startPos:Vec = new Vec;
    private var target:Vec = new Vec;
    private var ticks:int;
    private var pVel:Vec = new Vec;
    private var message:Message;
    private var nearScore:int, nearScoreTicks:int;
    public function setEnemy():void {
        pos.x = rand.sx(); pos.y = 0;
        startPos.xy = pos;
        vel.x = rand.sx() - pos.x; vel.y = screen.size.y;
        vel.scaleBy(1 / rand.i(100, 200));
    }
    public function setPlayer(tx:Number, ty:Number):void {
        pos.x = (rand.i(3) * 0.4 + 0.1) * screen.size.x;
        pos.y = screen.size.y * 0.94;
        startPos.xy = pos;
        target.x = vel.x = tx;
        target.y = vel.y = ty;
        ticks = vel.distance(pos) / 20;
        vel.decrementBy(pos);
        vel.scaleBy(1 / ticks);
        ticks++;
        isPlayers = true;
    }
    public function setYou():void {
        pos.x = rand.sx(); pos.y = 0;
        startPos.xy = pos;
        vel.x = rand.sx() - pos.x; vel.y = screen.size.y;
        vel.scaleBy(1 / 300);
        isYou = true;
        message = Message.addOnce("YOU", pos);
    }
    public function update():Boolean {
        var lc:uint;
        if (isYou) {
            lc = Color.green.i;
            pVel.x += (mouse.pos.x - pos.x) * 0.005;
            pVel.y += (mouse.pos.y - pos.y) * 0.002;
            pVel.scaleBy(0.8);
            pos.incrementBy(pVel);
            if (message) {
                message.pos.x = pos.x; message.pos.y = pos.y + 20;
            }
        } else if (isPlayers) {
            lc = Color.blue.i;
            if (--ticks <= 0) {
                explosions.push(new Explosion(target));
                return false;
            }
            screen.draw(function(g:Graphics):void {
                g.lineStyle(1, colors[colorsIndex].i);
                g.moveTo(-5, -5); g.lineTo(5, 5);
                g.moveTo(5, -5); g.lineTo(-5, 5);
            }, target);
        } else {
            lc = Color.red.i;
        }
        if (!isPlayers) {
            for each (var e:Explosion in explosions) {
                var d:Number = e.pos.distance(pos) - e.radius;
                if (d <= 0) {
                    explosions.push(new Explosion(pos));
                    if (isYou) endGame();
                    isDestroyed = true;
                    return false;
                }
                if (isYou) {
                    d = 30 - d;
                    if (d > 0) {
                        nearScore += d;
                        nearScoreTicks = 0;
                    }
                    if (nearScore > 0) {
                        screen.drawText(String(nearScore), pos.x, pos.y - 20);
                        if (++nearScoreTicks >= 30) {
                            score += nearScore;
                            Message.add(String(nearScore), pos, 0, -100, 30);
                            nearScore = 0;
                        }
                    }
                }
            }
            if (pos.y >= screen.size.y * 0.95) {
                explosions.push(new Explosion(pos));
                if (isYou) {
                    youMissileAppTicks = 30;
                    var ads:int = 1000;
                    if (nearScore > 0) ads += nearScore;
                    score += ads;
                    Message.add(String(ads), pos, 0, -100, 30);
                }
                isDestroyed = true;
                return false;
            }
        }
        screen.draw(function(g:Graphics):void {
            g.lineStyle(1, lc);
            g.moveTo(startPos.x, startPos.y);
            g.lineTo(pos.x, pos.y);
        });
        screen.draw(function(g:Graphics):void {
            g.beginFill(colors[colorsIndex].i);
            g.drawCircle(pos.x, pos.y, 2);
        });
        return true;
    }
}
var explosions:Vector.<Explosion>;
class Explosion extends Actor {
    public var radius:Number = 0;
    private var ticks:int;
    function Explosion(p:Vec) {
        pos.xy = p;
    }
    public function update():Boolean {
        if (ticks < 30) radius = ticks;
        else radius = 60 - ticks;
        screen.draw(function(g:Graphics):void {
            g.beginFill(Color.white.getScatterd(32).i);
            g.drawCircle(pos.x, pos.y, radius);
        });
        return ++ticks < 60;
    }
}
//----------------------------------------------------------------
import flash.display.*;
import flash.geom.*;
import flash.filters.*;
import flash.events.*;
import flash.text.*;
import flash.utils.getTimer;
var screen:Screen;
var mouse:Mouse;
var main:Main, bd:BitmapData;
var blurBd:BitmapData, blurFilter:BlurFilter;
var baseSprite:Sprite;
function initializeFirst():void {
    screen = new Screen;
    bd = new BitmapData(screen.size.x, screen.size.y, true, 0);
    blurBd = new BitmapData(screen.size.x, screen.size.y, true, 0);
    blurFilter = new BlurFilter(7, 7, 2);
    baseSprite = new Sprite;
    baseSprite.addChild(new Bitmap(blurBd));
    main.addChild(new Bitmap(new BitmapData(screen.size.x, screen.size.y, false, 0)));
    main.addChild(baseSprite);
    mouse = new Mouse(main.stage);
    initialize();
    if (DEBUG) beginGame();
    else setScoreRecordViewer();
    main.addEventListener(Event.ENTER_FRAME, updateFrame);
}
var zeroPoint:Point = new Point;
function updateFrame(event:Event):void {
    bd.lock();
    bd.fillRect(bd.rect, 0);
    updateGame();
    Actor.update(Message.s);
    bd.unlock();
    blurBd.lock();
    blurBd.fillRect(bd.rect, 0);
    blurBd.copyPixels(bd, bd.rect, zeroPoint, null, null, true);
    blurBd.applyFilter(blurBd, blurBd.rect, zeroPoint, blurFilter);
    blurBd.copyPixels(bd, bd.rect, zeroPoint, null, null, true);
    blurBd.unlock();
}
var score:int, ticks:int;
var isInGame:Boolean;
var wasClicked:Boolean, wasReleased:Boolean;
function beginGame():void {
    isInGame = true;
    score = 0;
    closeScoreForms();
    initialize();
}
function endGame():void {
    isInGame = false;
    wasClicked = wasReleased = false;
    ticks = 0;
    recordScore(score);
    setScoreRecordViewer();
}
function updateGame():void {
    update();
    screen.drawText(String(score), screen.size.x - 40, 20);
    if (!isInGame) {
        screen.drawText(TITLE, screen.size.x * 0.7, screen.center.y - 20);
        screen.drawText("click to start", screen.size.x * 0.7, screen.center.y + 20);
        if (mouse.isPressing) {
            if (wasReleased) wasClicked = true;
        } else {
            if (wasClicked) beginGame();
            wasReleased = true;
        }
        return;
    }
    ticks++;
}
class Vec extends Vector3D {
    public function Vec(x:Number = 0, y:Number = 0) {
        super(x, y);
    }
    public function clear():void {
        x = y = 0;
    }
    public function distance(p:Vector3D):Number {
        return getLength(p.x - x, p.y - y);
    }
    public function angle(p:Vector3D):Number {
        return atan2(p.x - x, p.y - y);
    }
    public function addAngle(a:Number, s:Number):void {
        x += sin(a) * s; y += cos(a) * s;
    }
    public function rotate(a:Number):void {
        var px:Number = x;
        x = x * cos(a) - y * sin(a);
        y = px * sin(a) + y * cos(a);
    }    
    public function set xy(v:Vector3D):void {
        x = v.x; y = v.y;
    }
}
class Color {
    public var r:int, g:int, b:int;
    public function Color(r:int = 0, g:int = 0, b:int = 0) {
        this.r = r * 22;
        this.g = g * 22;
        this.b = b * 22;
    }
    public function get i():uint {
        return r * 0x10000 + g * 0x100 + b;
    }
    private static var scatterdColor:Color = new Color;
    public function getScatterd(w:int = 64):Color {
        scatterdColor.r = r + rand.i(w * 2, -w);
        scatterdColor.g = g + rand.i(w * 2, -w);
        scatterdColor.b = b + rand.i(w * 2, -w);
        scatterdColor.normalize();
        return scatterdColor;
    }
    public function normalize():void {
        r = clamp(r, 0, 255);
        g = clamp(g, 0, 255);
        b = clamp(b, 0, 255);
    }
    public function set rgb(v:Color):void {
        r = v.r; g = v.g; b = v.b;
    }
    private static const WHITENESS:int = 2;
    public static var black:Color = new Color(WHITENESS, WHITENESS, WHITENESS);
    public static var red:Color = new Color(10, WHITENESS, WHITENESS);
    public static var green:Color = new Color(WHITENESS, 10, WHITENESS);
    public static var blue:Color = new Color(WHITENESS, WHITENESS, 10);
    public static var yellow:Color = new Color(10, 10, WHITENESS);
    public static var magenta:Color = new Color(10, WHITENESS, 10);
    public static var cyan:Color = new Color(WHITENESS, 10, 10);
    public static var white:Color = new Color(10, 10, 10);
}
class Message extends Actor {
    public static var s:Vector.<Message> = new Vector.<Message>;
    public static var shownMessages:Vector.<String> = new Vector.<String>;
    public static function addOnce(text:String, p:Vec, vx:Number = 0, vy:Number = 0,
    ticks:int = 90):Message {
        if (shownMessages.indexOf(text) >= 0) return null;
        shownMessages.push(text);
        return add(text, p, vx, vy, ticks);
    }
    public static function add(text:String, p:Vec, vx:Number = 0, vy:Number = 0,
    ticks:int = 90, color:uint = 0xffffff):Message {
        var m:Message = new Message;
        m.text = text;
        m.pos.xy = p;
        m.vel.x = vx; m.vel.y = vy / ticks;
        m.ticks = ticks;
        m.color = color;
        s.push(m);
        return m;
    }
    public var text:String, ticks:int, color:uint;
    public function update():Boolean {
        screen.drawText(text, pos.x, pos.y, color);
        return --ticks > 0;
    }
}
class Screen {
    public var size:Vec = new Vec(main.WIDTH, main.HEIGHT);
    public var center:Vec = new Vec(size.x / 2, size.y / 2);
    private var textField:TextField = new TextField;
    private var textFormat:TextFormat;
    public function Screen() {
        textFormat = new TextFormat("_typewriter");
        textFormat.size = 11; textFormat.bold = true;
        textFormat.align = TextFormatAlign.CENTER;
        textField.width = 200; textField.height = 20;
    }
    private var matrix:Matrix = new Matrix;
    public function drawText(text:String, x:int, y:int, color:uint = 0xffffff):void {
        textFormat.color = color;
        textField.defaultTextFormat = textFormat;
        textField.text = text;
        matrix.identity(); matrix.translate(x - 100, y - 20);
        bd.draw(textField, matrix);
    }
    private var rectForFill:Rectangle = new Rectangle;
    public function fillRect
    (x:Number, y:Number, width:Number, height:Number, color:uint):void {
        rectForFill.x = x - width / 2; rectForFill.y = y - height / 2;
        rectForFill.width = width; rectForFill.height = height;
        bd.fillRect(rectForFill, 0xff000000 + color);
    }
    private var shape:Shape = new Shape;
    public function draw(gf:Function, p:Vector3D = null):void {
        shape.graphics.clear();
        gf(shape.graphics);
        if (p) {
            matrix.identity(); matrix.translate(p.x, p.y);
            bd.draw(shape, matrix);
        } else {
            bd.draw(shape);
        }
    }
    public function isIn(p:Vector3D, spacing:Number = 0):Boolean {
        return (p.x >= -spacing && p.x <= size.x + spacing && 
            p.y >= -spacing && p.y <= size.y + spacing);
    }
}
class Mouse {
    public var pos:Vec = new Vec;
    public var isPressing:Boolean;
    public function Mouse(stage:Stage) {
        baseSprite.addEventListener(MouseEvent.MOUSE_MOVE, onMoved);
        baseSprite.addEventListener(MouseEvent.MOUSE_DOWN, onPressed);
        baseSprite.addEventListener(MouseEvent.MOUSE_UP, onReleased);
        baseSprite.addEventListener(Event.MOUSE_LEAVE, onReleased);
    }
    private function onMoved(e:MouseEvent):void {
        pos.x = e.stageX; pos.y = e.stageY;
    }
    private function onPressed(e:MouseEvent):void {
        isPressing = true;
        onMoved(e);
    }
    private function onReleased(e:Event):void {
        isPressing = false;
    }
}
var rand:Rand = new Rand(int.MIN_VALUE);
class Rand {
    public function n(v:Number = 1, s:Number = 0):Number { return get() * v + s; }
    public function i(v:int, s:int = 0):int { return n(v, s); }
    public function sx(v:Number = 1, s:Number = 0):Number { return n(v, s) * screen.size.x; }
    public function sy(v:Number = 1, s:Number = 0):Number { return n(v, s) * screen.size.y; }
    public function pm():int { return i(2) * 2 - 1; }
    private var xorShiftX:int, xorShiftY:int, xorShiftZ:int, xorShiftW:int;
    function Rand(v:int = int.MIN_VALUE):void {
        var sv:int;
        if (v == int.MIN_VALUE) sv = getTimer();
        else sv = v;
        xorShiftX = sv = 1812433253 * (sv ^ (sv >> 30));
        xorShiftY = sv = 1812433253 * (sv ^ (sv >> 30)) + 1;
        xorShiftZ = sv = 1812433253 * (sv ^ (sv >> 30)) + 2;
        xorShiftW = sv = 1812433253 * (sv ^ (sv >> 30)) + 3;
    }
    public function get():Number {
        var t:int = xorShiftX ^ (xorShiftX << 11);
        xorShiftX = xorShiftY; xorShiftY = xorShiftZ; xorShiftZ = xorShiftW;
        xorShiftW = (xorShiftW ^ (xorShiftW >> 19)) ^ (t ^ (t >> 8));
        return Number(xorShiftW) / int.MAX_VALUE;
    }    
}
function getLength(x:Number, y:Number):Number {
    return sqrt(x * x + y * y);
}
function clamp(v:Number, min:Number, max:Number):Number {
    if (v > max) return max;
    else if (v < min) return min;
    return v;
}
var sin:Function = Math.sin, cos:Function = Math.cos, atan2:Function = Math.atan2; 
var sqrt:Function = Math.sqrt, abs:Function = Math.abs;
var PI:Number = Math.PI, PI2:Number = PI * 2;
/*
function setScoreRecordViewer():void { }
function recordScore(s:int):void { }
function closeScoreForms():void { }
/*/
import net.wonderfl.score.basic.BasicScoreForm;
import net.wonderfl.score.basic.BasicScoreRecordViewer;
var scoreRecordViewer:BasicScoreRecordViewer;
var scoreForm:BasicScoreForm;
function setScoreRecordViewer():void {
    scoreRecordViewer = new BasicScoreRecordViewer(main, 5, 220, "SCORE RANKING", 50);
}
function recordScore(s:int):void {
    scoreForm = new BasicScoreForm(main, 5, 5, s);
    scoreForm.onCloseClick = function():void {
        closeScoreForms();
        setScoreRecordViewer();
    }
}
function closeScoreForms():void {
    if (scoreRecordViewer) {
        main.removeChild(scoreRecordViewer);
        scoreRecordViewer = null;
    }
    if (scoreForm) {
        main.removeChild(scoreForm);
        scoreForm = null;
    }
}
//*/
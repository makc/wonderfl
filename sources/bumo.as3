package {
    import flash.display.Sprite;
    [SWF(width="465", height="465", backgroundClr="0", frameRate="30")]
    public class Main extends Sprite {
        public const WIDTH:int = 465, HEIGHT:int = 465;
        public function Main() { main = this; initializeFirst(); }
    }
}
class MObj {
    public var pos:Vct = new Vct, vel:Vct = new Vct;
    public function move():void { pos.incrementBy(vel); }
}
//----------------------------------------------------------------
const TITLE:String = "downward";
const DEBUG:Boolean = false;
var ballAddTicks:int;
function initialize():void {
    floor = new Floor;
    balls = new Vector.<Ball>;
    man = new Man;
    ballAddTicks = 0;
}
function update():void {
    if (--ballAddTicks <= 0) {
        balls.push(new Ball);
        ballAddTicks = 30 / (1 + sqrt(ticks * 0.01));
    }
    floor.update();
    updateActors(balls);
    man.update();
}
var floor:Floor;
class Floor {
    public const THICKNESS:Number = 10;
    public var fshp:Shp = new Shp().fill(Clr.yellow).rect(scr.size.x * 2, scr.size.y * 0.45);
    public var fpos:Vct = new Vct(scr.center.x, scr.size.y);
    public var shp:Shp = new Shp().fill(Clr.green).rect(scr.size.x * 2, THICKNESS);
    public var pos:Vct = new Vct(scr.center.x, scr.size.y * 0.77);
    public var angle:Number = 0;
    public function update():void {
        angle = (mouse.pos.x - scr.center.x) * 0.004;
        if (angle > 0.4) angle = 0.4;
        else if (angle < -0.4) angle = -0.4;
        shp.agl(angle).p(pos).draw();
        drawAngled(fshp, fpos);
    }
}
var balls:Vector.<Ball>;
class Ball extends MObj {
    public var shp:Shp = new Shp().fill(Clr.red).circle(10);
    public var hshp:Shp = new Shp().fill(Clr.yellow).circle(10);
    public var isHitFloor:Boolean;
    public var scale:Number = rnd.n(2, 1);
    function Ball() {
        if (rnd.i(10) == 0) scale *= 2;
        pos.x = rnd.sx(2, -0.5); pos.y = -64;
    }
    public function update():Boolean {
        vel.addAngle(floor.angle, 0.3);
        move();
        var r:Number = 10 * scale;
        var fy:Number = floor.pos.y - r - floor.THICKNESS / 2;
        if (isHitFloor) {
            scale -= 0.01;
            drawAngled(hshp, pos, scale);
            if (!man.isEnd && pos.distance(man.pos) <= r) {
                var s:int = 10 * scale;
                Msg.add(String(s), pos, 0, -100, 30);
                score += s;
                return false;
            }
        } else {
            drawAngled(shp, pos, scale);
            if (!man.isEnd && pos.distance(man.pos) <= r / 2) {
                man.isEnd = true;
                endGame();
            }
        }
        if (pos.y > fy) {
            pos.y = fy;
            vel.y *= -0.2;
            if (!man.isEnd) isHitFloor = true;
            if (!scr.isIn(spos, r * 2)) return false;
        }
        return scale > 0.5;
    }
}
var man:Man;
class Man extends MObj {
    public var shp:Shp = new Shp().fill(Clr.cyan).m(0, -20).l(10, 20).l(-10, 20);
    public var isEnd:Boolean, sy:Number = 1;
    function Man() {
        pos.x = scr.center.x; pos.y = floor.pos.y - 20;
        if (!isInGame) { isEnd = true; sy = 0; }
    }
    public function update():void {
        if (isEnd) {
            if (sy <= 0) return;
            sy -= 0.1;
            pos.y = floor.pos.y - 20 * sy;
            drawAngled(shp, pos, 1, sy);
            return;
        }
        vel.x += sin(floor.angle) * 10;
        vel.x *= 0.5;
        move();
        drawAngled(shp, pos);
        if ((spos.x < 0 && vel.x < 0) || (spos.x > scr.size.x && vel.x > 0)) {
            vel.x *= -1;
            pos.x += vel.x;
        }
    }
}
var spos:Vct = new Vct;
function drawAngled(shp:Shp, p:Vct, sx:Number = 1, sy:Number = int.MIN_VALUE):void {
    spos.xy = p;
    spos.decrementBy(floor.pos);
    spos.rotate(floor.angle);
    spos.incrementBy(floor.pos);
    shp.scl(sx, sy).agl(floor.angle).p(spos).draw();
}
//----------------------------------------------------------------
import flash.display.*;
import flash.geom.*;
import flash.filters.*;
import flash.events.*;
import flash.text.*;
import flash.utils.getTimer;
var scr:Scr;
var mouse:Mouse;
var main:Main, bd:BitmapData;
var blurBd:BitmapData, blurFilter:BlurFilter;
var baseSprite:Sprite;
function initializeFirst():void {
    scr = new Scr;
    bd = new BitmapData(scr.size.x, scr.size.y, true, 0);
    blurBd = new BitmapData(scr.size.x, scr.size.y, true, 0);
    blurFilter = new BlurFilter(7, 7, 2);
    baseSprite = new Sprite;
    baseSprite.addChild(new Bitmap(blurBd));
    main.addChild(new Bitmap(new BitmapData(scr.size.x, scr.size.y, false, 0)));
    main.addChild(baseSprite);
    mouse = new Mouse;
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
    updateActors(Msg.s);
    bd.unlock();
    blurBd.lock();
    blurBd.fillRect(blurBd.rect, 0);
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
    scr.drawText(String(score), scr.size.x - 40, 20);
    if (!isInGame) {
        scr.drawText(TITLE, scr.size.x * 0.7, scr.center.y - 20);
        scr.drawText("click to start", scr.size.x * 0.7, scr.center.y + 20);
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
function updateActors(s:*):void {
    for (var i:int = 0; i < s.length; i++) if (!s[i].update()) s.splice(i--, 1);
}
class Vct extends Vector3D {
    public function Vct(x:Number = 0, y:Number = 0) {
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
class Clr {
    public var r:int, g:int, b:int;
    public function Clr(r:int = 0, g:int = 0, b:int = 0) {
        this.r = r * 22;
        this.g = g * 22;
        this.b = b * 22;
    }
    public function get i():uint {
        return r * 0x10000 + g * 0x100 + b;
    }
    private static var scatterdClr:Clr = new Clr;
    public function getScatterd(w:int = 64):Clr {
        scatterdClr.r = r + rnd.i(w * 2, -w);
        scatterdClr.g = g + rnd.i(w * 2, -w);
        scatterdClr.b = b + rnd.i(w * 2, -w);
        scatterdClr.normalize();
        return scatterdClr;
    }
    public function normalize():void {
        r = clamp(r, 0, 255);
        g = clamp(g, 0, 255);
        b = clamp(b, 0, 255);
    }
    public function set rgb(v:Clr):void {
        r = v.r; g = v.g; b = v.b;
    }
    private static const WHITENESS:int = 2;
    public static var black:Clr = new Clr(WHITENESS, WHITENESS, WHITENESS);
    public static var red:Clr = new Clr(10, WHITENESS, WHITENESS);
    public static var green:Clr = new Clr(WHITENESS, 10, WHITENESS);
    public static var blue:Clr = new Clr(WHITENESS, WHITENESS, 10);
    public static var yellow:Clr = new Clr(10, 10, WHITENESS);
    public static var magenta:Clr = new Clr(10, WHITENESS, 10);
    public static var cyan:Clr = new Clr(WHITENESS, 10, 10);
    public static var white:Clr = new Clr(10, 10, 10);
}
class Msg {
    public static var s:Vector.<Msg> = new Vector.<Msg>;
    public static var shownMessages:Vector.<String> = new Vector.<String>;
    public static function addOnce(text:String, p:Vct, vx:Number = 0, vy:Number = 0,
    ticks:int = 90, Clr:uint = 0xffffff):Msg {
        if (shownMessages.indexOf(text) >= 0) return null;
        shownMessages.push(text);
        return add(text, p, vx, vy, ticks, Clr);
    }
    public static function add(text:String, p:Vct, vx:Number = 0, vy:Number = 0,
    ticks:int = 90, color:uint = 0xffffff):Msg {
        var m:Msg = new Msg;
        m.text = text;
        m.pos.xy = p;
        m.vel.x = vx; m.vel.y = vy / ticks;
        m.ticks = ticks;
        m.color = color;
        s.push(m);
        return m;
    }
    public var pos:Vct = new Vct, vel:Vct = new Vct;
    public var text:String, ticks:int, color:uint;
    public function update():Boolean {
        pos.incrementBy(vel);
        scr.drawText(text, pos.x, pos.y, color);
        return --ticks > 0;
    }
}
class Scr {
    public var size:Vct = new Vct(main.WIDTH, main.HEIGHT);
    public var center:Vct = new Vct(size.x / 2, size.y / 2);
    private var textField:TextField = new TextField;
    private var textFormat:TextFormat;
    public function Scr() {
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
    public function isIn(p:Vector3D, spacing:Number = 0):Boolean {
        return (p.x >= -spacing && p.x <= size.x + spacing && 
            p.y >= -spacing && p.y <= size.y + spacing);
    }
}
class Shp extends Shape {
    public function fill(c:Clr):Shp {
        graphics.beginFill(c.i);
        return this;
    }
    public function rect(w:Number, h:Number, x:Number = 0, y:Number = 0):Shp {
        graphics.drawRect(x - w / 2, y - h / 2, w, h);
        return this;
    }
    public function circle(r:Number, x:Number = 0, y:Number = 0):Shp {
        graphics.drawCircle(x, y, r);
        return this;
    }
    public function m(x:Number, y:Number):Shp {
        graphics.moveTo(x, y);
        return this;
    }
    public function l(x:Number, y:Number):Shp {
        graphics.lineTo(x, y);
        return this;
    }
    public var matrix:Matrix = new Matrix;
    public function scl(x:Number, y:Number = int.MIN_VALUE):Shp {
        if (y == int.MIN_VALUE) y = x;
        matrix.scale(x, y);
        return this;
    }
    public function agl(v:Number):Shp {
        matrix.rotate(v);
        return this;
    }
    public function p(p:Vct): Shp {
        matrix.translate(p.x, p.y);
        return this;
    }
    public function draw():void {
        bd.draw(this, matrix);
        matrix.identity();
    }
}
class Mouse {
    public var pos:Vct = new Vct;
    public var isPressing:Boolean;
    public function Mouse() {
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
var rnd:Rnd = new Rnd(int.MIN_VALUE);
class Rnd {
    public function n(v:Number = 1, s:Number = 0):Number { return get() * v + s; }
    public function i(v:int, s:int = 0):int { return n(v, s); }
    public function sx(v:Number = 1, s:Number = 0):Number { return n(v, s) * scr.size.x; }
    public function sy(v:Number = 1, s:Number = 0):Number { return n(v, s) * scr.size.y; }
    public function pm():int { return i(2) * 2 - 1; }
    private var x:int, y:int, z:int, w:int;
    function Rnd(v:int = int.MIN_VALUE):void {
        var sv:int;
        if (v == int.MIN_VALUE) sv = getTimer();
        else sv = v;
        x = sv = 1812433253 * (sv ^ (sv >> 30));
        y = sv = 1812433253 * (sv ^ (sv >> 30)) + 1;
        z = sv = 1812433253 * (sv ^ (sv >> 30)) + 2;
        w = sv = 1812433253 * (sv ^ (sv >> 30)) + 3;
    }
    public function get():Number {
        var t:int = x ^ (x << 11);
        x = y; y = z; z = w;
        w = (w ^ (w >> 19)) ^ (t ^ (t >> 8));
        return Number(w) / int.MAX_VALUE;
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
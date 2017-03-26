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
    public var shp:Shp;
    public function move():void { pos.incrementBy(vel); }
}
//----------------------------------------------------------------
const TITLE:String = "exvert";
const DEBUG:Boolean = false;
function initialize():void {
    field = new Field;
    block = new Block;
}
function update():void {
    if (!block.update()) block = new Block;
    field.update();
}
var field:Field;
class Field {
    public const SIZE:int = 24;
    public var dot:Vector.<Vector.<int>>;
    public var wshp:Shp, bshp:Shp, dshp:Shp;
    public var cshp:Shp;
    public var dsize:int;
    public var mx:int, my:int, ms:int;
    public var multiplier:int = 1;
    public var isRemoving:Boolean;
    public var hasDot:Boolean;
    public var msg:Msg;
    function Field() {
        dot = new Vector.<Vector.<int>>(SIZE);
        for (var i:int = 0; i < SIZE; i++) {
            dot[i] = new Vector.<int>(SIZE);
        }
        dsize = scr.size.x / SIZE;
        wshp = new Shp().fill(Clr.white).rect(dsize - 2);
        bshp = new Shp().fill(Clr.white).rect(dsize - 2).fill(Clr.black).rect(dsize - 4);
        dshp = new Shp().fill(Clr.green).rect(dsize - 2);
        cshp = new Shp;
    }
    private var dp:Vct = new Vct;
    public function update():void {
        if (isInGame) {
            setCursor();
            if (ms > 0) msg = Msg.addOnce("Click to invert colors", mouse.pos);
            if (msg) msg.pos = mouse.pos;
            if (mouse.isPressing) {
                if (wasReleased) {
                    if (ms > 0) xor();
                    wasReleased = false;
                }
            } else {
                wasReleased = true;
            }
        } else {
            ms = 0;
        }
        dp.y = 1 + dsize / 2;
        isRemoving = hasDot = false;
        var sc:int, sx:int, sy:int;
        for (var y:int = 0; y < SIZE; y++, dp.y += dsize) {
            dp.x = 1 + dsize / 2;
            for (var x:int = 0; x < SIZE; x++, dp.x += dsize) {
                var d:int = dot[x][y];
                if (d != 0) hasDot = true;
                if (d == 1) wshp.p(dp).draw();
                else if (d == -1) bshp.p(dp).draw();
                else if (d >= 2) {
                    isRemoving = true;
                    dshp.p(dp).draw();
                    if (multiplier <= 0) dot[x][y] += 3;
                    else dot[x][y]++;
                    if (dot[x][y] > 20) {
                        dot[x][y] = 0;
                        sx += x; sy += y; sc++;
                    }
                }
            }
        }
        if (sc > 0 && multiplier > 0) {
            score += sc * sc * multiplier;
            dp.x = (sx / sc + 0.5) * dsize; dp.y = (sy / sc + 0.5) * dsize;
            Msg.add(sc * sc + " x " + multiplier, dp, 0, -100, 60);
            multiplier++;
        }
        if (!isRemoving) multiplier = 1;
        if (ms > 0) {
            cshp.clear().line(Clr.green, 3).rect(ms * dsize);
            dp.x = (mx + ms / 2) * dsize;
            dp.y = (my + ms / 2) * dsize;
            cshp.p(dp).draw();
        }
        clearLines();
    }
    private function setCursor():void {
        mx = mouse.pos.x / dsize;
        my = mouse.pos.y / dsize;
        if (mx < 0 || mx >= SIZE || my < 0 || my >= SIZE) { ms = 0; return; }
        if (dot[mx][my] == 0 || dot[mx][my] >= 2) { ms = 0; return; }
        ms = 1;
        var ef:Boolean = true;
        while (ef) {
            mx--; my--; ms += 2;
            if (mx < 0 || my < 0 || mx + ms - 1 >= SIZE || my + ms - 1 >= SIZE) break;
            for (var x:int = mx; x < mx + ms; x++)
                for (var y:int = my; y < my + ms; y++)
                    if (dot[x][y] == 0 || dot[mx][my] >= 2) { ef = false;  break; }
        }
        mx++; my++; ms -= 2;
    }
    private function xor():void {
        for (var x:int = mx; x < mx + ms; x++)
            for (var y:int = my; y < my + ms; y++)
                if (dot[x][y] <= 1) dot[x][y] *= -1;
    }
    public function clearLines():void {
        for (var x:int = 0; x < SIZE; x++) {
            for (var y:int = 0; y < SIZE; y++) {
                if (dot[x][y] == 0 || dot[x][y] == 2) continue;
                checkVertLine(x, y);
                checkHorzLine(x, y);
            }
        }
    }
    private function checkVertLine(cx:int, cy:int):void {
        var cd:int = dot[cx][cy] * -1;
        var y:int = cy, from:int, to:int;
        while (y >= 0) {
            if (dot[cx][y] == cd || dot[cx][y] >= 2) return;
            if (dot[cx][y] == 0) break;
            y--;
        }
        from = y + 1;
        y = cy;
        while (y < SIZE) {
            if (dot[cx][y] == cd || dot[cx][y] >= 2) return;
            if (dot[cx][y] == 0) break;
            y++;
        }
        to = y - 1;
        for (y = from; y <= to; y++) dot[cx][y] = 2;
    }
    private function checkHorzLine(cx:int, cy:int):void {
        var cd:int = dot[cx][cy] * -1;
        var x:int = cx, from:int, to:int;
        while (x >= 0) {
            if (dot[x][cy] == cd || dot[x][cy] >= 2) return;
            if (dot[x][cy] == 0) break;
            x--;
        }
        from = x + 1;
        x = cx;
        while (x < SIZE) {
            if (dot[x][cy] == cd || dot[x][cy] >= 2) return;
            if (dot[x][cy] == 0) break;
            x++;
        }
        to = x - 1;
        for (x = from; x <= to; x++) dot[x][cy] = 2;
    }
}
var block:Block;
class Block {
    public const DURATION:int = 3000;
    public var dot:Vector.<Vector.<int>>;
    public var dx:int, dy:int;
    public var width:int, height:int;
    public var appTicks:int = DURATION;
    public var shp:Shp = new Shp;
    function Block() {
        width = rnd.i(field.SIZE * 0.4, field.SIZE * 0.3);
        height = rnd.i(field.SIZE * 0.4, field.SIZE * 0.3);
        dx = rnd.i(field.SIZE - width);
        dy = rnd.i(field.SIZE - height);
        dot = new Vector.<Vector.<int>>(width);
        var bd:int = rnd.pm();
        for (var x:int = 0; x < width; x++) {
            dot[x] = new Vector.<int>(height);
            for (var y:int = 0; y < height; y++) dot[x][y] = bd;
        }
        for (var i:int = 0; i < 32; i++) {
            xor();
            if (!hasLine()) break;
        }
    }
    private function xor():void {
        var cx:int = rnd.i(width - 2, 1), cy:int = rnd.i(height - 2, 1), s:int = 1;
        for (;;) {
            if (cx <= 0 || cy <= 0 || cx + s - 1 >= width - 1 || cy + s - 1 >= height - 1) break;
            cx--; cy--; s += 2;
        }
        for (var x:int = cx; x < cx + s; x++)
            for (var y:int = cy; y < cy + s; y++)
                dot[x][y] *= -1;
    }
    private function hasLine():Boolean {
        var hl:Boolean;
        for (var x:int = 0; x < width; x++) {
            hl = true;
            var id:int = -dot[x][0];
            for (var y:int = 1; y < height; y++) {
                if (dot[x][y] == id) { hl = false; break; }
            }
            if (hl) return true;
        }
        for (y = 0; y < height; y++) {
            hl = true;
            id = -dot[0][y];
            for (x = 1; x < width; x++) {
                if (dot[x][y] == id) { hl = false; break; }
            }
            if (hl) return true;
        }
        return false;
    }
    private var sp:Vct = new Vct;
    public function update():Boolean {
        if (!isInGame) return true;
        if (!field.isRemoving) {
            if (field.hasDot) appTicks -= sqrt(1 + ticks * 0.002);
            else appTicks -= DURATION / 10;
            if (appTicks <= 0) {
                set();
                field.clearLines();
                return false;
            }
        }
        sp.x = (dx + width / 2) * field.dsize;
        sp.y = (dy + height / 2) * field.dsize;
        shp.clear().fill(Clr.red).rect(width * field.dsize, height * field.dsize);
        shp.p(sp).draw();
        var dr:Number = 1 - appTicks / DURATION;
        shp.clear().fill(Clr.black).rect(width * field.dsize * dr, height * field.dsize * dr);
        shp.p(sp).draw();
        return true;
    }
    private function set():void {
        field.multiplier = 0;
        for (var x:int = 0; x < width; x++) {
            for (var y:int = 0; y < height; y++) {
                if (isInGame && field.dot[dx + x][dy + y] != 0) endGame();
                field.dot[dx + x][dy + y] = dot[x][y];
            }
        }
    }
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
var titleTicks:int;
function beginGame():void {
    isInGame = true;
    score = 0;
    closeScoreForms();
    rnd = new Rnd;
    initialize();
}
function endGame():void {
    isInGame = false;
    wasClicked = wasReleased = false;
    ticks = 0;
    recordScore(score);
    setScoreRecordViewer();
    titleTicks = 30;
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
            if (--titleTicks <= 0) wasReleased = true;
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
    public function get way():Number {
        return atan2(x, y);
    }
    public function get speed():Number {
        return getLength(x, y);
    }
}
class Clr {
    private const BRIGHTNESS:int = 20;
    public var r:int, g:int, b:int;
    public function Clr(r:int = 0, g:int = 0, b:int = 0) {
        this.r = r * BRIGHTNESS;
        this.g = g * BRIGHTNESS;
        this.b = b * BRIGHTNESS;
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
    public static var black:Clr = new Clr(0, 0, 0);
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
    public function clear():Shp {
        graphics.clear();
        return this;
    }
    public function fill(c:Clr):Shp {
        graphics.beginFill(c.i);
        return this;
    }
    public function line(c:Clr, t:int = 1):Shp {
        graphics.lineStyle(t, c.i);
        return this;
    }
    public function rect(w:Number, h:Number = 0, x:Number = 0, y:Number = 0):Shp {
        if (h == 0) h = w;
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
var rnd:Rnd = new Rnd;
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
function normalizeAngle(v:Number):Number {
    var r:Number = v % PI2;
    if (r < -PI) r += PI2;
    else if (r > PI) r -= PI2;
    return r;
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
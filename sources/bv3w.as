package {
    import flash.display.Sprite;
    [SWF(width="465", height="465", backgroundClr="0", frameRate="30")]
    public class Main extends Sprite {
        public function Main() { main = this; initializeFirst(); }
    }
}
import flash.display.*;
import flash.geom.*;
import flash.filters.*;
import flash.events.*;
import flash.text.*;
import flash.utils.getTimer;
const SCR_WIDTH:int = 465, SCR_HEIGHT:int = 465;
var main:Main, bd:BitmapData;
var blurBd:BitmapData, blurFilter:BlurFilter;
var baseSprite:Sprite;
function initializeFirst():void {
    bd = new BitmapData(scr.size.x, scr.size.y, true, 0);
    blurBd = new BitmapData(scr.size.x, scr.size.y, true, 0);
    blurFilter = new BlurFilter(7, 7, 2);
    baseSprite = new Sprite;
    baseSprite.addChild(new Bitmap(blurBd));
    main.addChild(new Bitmap(new BitmapData(scr.size.x, scr.size.y, false, 0)));
    main.addChild(baseSprite);
    mse = new Mse;
    key = new Key;
    initialize();
    if (DEBUG) beginGame();
    else setScoreRecordViewer();
    main.addEventListener(Event.ACTIVATE, onActivated);
    main.addEventListener(Event.DEACTIVATE, onDectivated);
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
var sin:Function = Math.sin, cos:Function = Math.cos, atan2:Function = Math.atan2; 
var sqrt:Function = Math.sqrt, abs:Function = Math.abs;
var PI:Number = Math.PI, PI2:Number = PI * 2;
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
var scr:Scr = new Scr;
class Scr {
    public var size:Vct = new Vct(SCR_WIDTH, SCR_HEIGHT);
    public var center:Vct = new Vct(size.x / 2, size.y / 2);
    private var textField:TextField = new TextField;
    private var textFormat:TextFormat;
    public function Scr() {
        textFormat = new TextFormat("_typewriter");
        textFormat.size = 11; textFormat.bold = true;
        textFormat.align = TextFormatAlign.CENTER;
        textField.width = 256; textField.height = 20;
    }
    private var matrix:Matrix = new Matrix;
    public function drawText(text:String, x:int, y:int, color:uint = 0xffffff):void {
        textFormat.color = color;
        textField.defaultTextFormat = textFormat;
        textField.text = text;
        matrix.identity(); matrix.translate(x - 128, y - 10);
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
    public function a(v:Number):Shp {
        matrix.rotate(v);
        return this;
    }
    public function p(p:Vct):Shp {
        matrix.translate(p.x, p.y);
        return this;
    }
    public function draw():void {
        bd.draw(this, matrix);
        matrix.identity();
    }
}
class Clr {
    public var r:int, g:int, b:int;
    public var brightness:Number = 1;
    public function Clr(r:int = 0, g:int = 0, b:int = 0) {
        this.r = r * BASE_BRIGHTNESS;
        this.g = g * BASE_BRIGHTNESS;
        this.b = b * BASE_BRIGHTNESS;
    }
    public function get i():uint {
        return uint(r * brightness) * 0x10000 + uint(g * brightness) * 0x100 + b * brightness;
    }
    public function set rgb(c:Clr):void {
        r = c.r; g = c.g; b = c.b;
    }
    private static const BASE_BRIGHTNESS:int = 20;
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
    ticks:int = 90, color:uint = 0xffffff):Msg {
        if (shownMessages.indexOf(text) >= 0) return null;
        shownMessages.push(text);
        return add(text, p, vx, vy, ticks, color);
    }
    public static function add(text:String, p:Vct, vx:Number = 0, vy:Number = 0,
    ticks:int = 90, color:uint = 0xffffff):Msg {
        var m:Msg = new Msg;
        m.text = text;
        m.pos.xy = p;
        m.vel.x = vx / ticks;
        m.vel.y = vy / ticks;
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
var mse:Mse;
class Mse {
    public var pos:Vct = new Vct;
    public var isPressing:Boolean;
    public function Mse() {
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
var key:Key;
class Key {
    public var s:Vector.<Boolean> = new Vector.<Boolean>(256);
    public function Key() {
        main.stage.addEventListener(KeyboardEvent.KEY_DOWN, onPressed);
        main.stage.addEventListener(KeyboardEvent.KEY_UP, onReleased);
    }
    private function onPressed(e:KeyboardEvent):void {
        s[e.keyCode] = true;
    }
    private function onReleased(e:KeyboardEvent):void {
        s[e.keyCode] = false;
    }
    public function get isWPressed():Boolean {
        return s[0x26] || s[0x57];
    }
    public function get isAPressed():Boolean {
        return s[0x25] || s[0x41];
    }
    public function get isSPressed():Boolean {
        return s[0x28] || s[0x53];
    }
    public function get isDPressed():Boolean {
        return s[0x27] || s[0x44];
    }
    private var sVct:Vct = new Vct;
    public function get stick():Vct {
        sVct.clear();
        if (isWPressed) sVct.y -= 1;
        if (isAPressed) sVct.x -= 1;
        if (isSPressed) sVct.y += 1;
        if (isDPressed) sVct.x += 1;
        if (sVct.x != 0 && sVct.y != 0) sVct.scaleBy(0.7);
        return sVct;
    }
    public function get isButtonPressed():Boolean {
        return isButton1Pressed || isButton2Pressed;
    }
    public function get isButton1Pressed():Boolean {
        return s[0x5a] || s[0xbe] || s[0x20];
    }
    public function get isButton2Pressed():Boolean {
        return s[0x58] || s[0xbf];
    }    
}
var score:int, ticks:int;
var isInGame:Boolean;
var isPaused:Boolean;
var wasClicked:Boolean, wasReleased:Boolean;
var titleTicks:int;
function beginGame():void {
    isInGame = true;
    score = 0;
    closeScoreForms();
    rnd = new Rnd;
    initialize();
}
function endGame():Boolean {
    if (!isInGame) return false;
    isInGame = false;
    wasClicked = wasReleased = false;
    ticks = 0;
    recordScore(score);
    setScoreRecordViewer();
    titleTicks = 30;
    return true;
}
function updateGame():void {
    if (!isPaused) update();
    scr.drawText(String(score), scr.size.x - 40, 10);
    if (!isInGame) {
        scr.drawText(TITLE, scr.size.x * 0.7, scr.center.y - 20);
        scr.drawText("click to start", scr.size.x * 0.7, scr.center.y + 20);
        if (mse.isPressing) {
            if (wasReleased) wasClicked = true;
        } else {
            if (wasClicked) beginGame();
            if (--titleTicks <= 0) wasReleased = true;
        }
        return;
    }
    if (isPaused) {
        scr.drawText("paused", scr.center.x, scr.center.y - 20);
        scr.drawText("click to resume", scr.center.x, scr.center.y + 20);
    }
    ticks++;
}
function onActivated(e:Event):void {
    isPaused = false;
}
function onDectivated(e:Event):void {
    if (isInGame) isPaused = true;
}
function updateActors(s:*):void {
    for (var i:int = 0; i < s.length; i++) if (!s[i].update()) s.splice(i--, 1);
}
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
//----------------------------------------------------------------
import flash.ui.Mouse;
const TITLE:String = "undermine"
const DEBUG:Boolean = false;
function initialize():void {
    blocks = new Vector.<Block>;
    player = new Player;
    nextBlockAppDist = 0;
    scroll(scr.size.y * 0.4);
    if (isInGame) {
        player.pos.x = scr.size.x * 0.3;
        player.pos.y = scr.center.y;
        Mouse.hide();
    }
}
function update():void {
    if (ticks == 1) Msg.addOnce("[WASD] to move", new Vct(100, 100));
    if (ticks == 60) Msg.addOnce("Click to fire", new Vct(100, 150));
    updateActors(blocks);
    player.update();
    scroll(sqrt(ticks * 0.0002) + 0.5);
}
var nextBlockAppDist:Number;
function scroll(d:Number):void {
    for each (var b:Block in blocks) b.pos.x -= d;
    player.pos.x -= d;
    nextBlockAppDist -= d;
    if (nextBlockAppDist <= 0) {
        for (var i:int = 0; i < 3; i++) {
            addBlocks(scr.size.x * 1.5 + nextBlockAppDist, scr.size.y * (0.5 - i),
            scr.size.x / 2, scr.size.y / 2);
        }
        removeBlocks(scr.size.y);
        nextBlockAppDist += scr.size.y;
    }
}
var blocks:Vector.<Block>;
class Block {
    public var pos:Vct = new Vct;
    public var size:Vct = new Vct;
    public var vy:Number = 0;
    public var shp:Shp;
    public var sc:Number;
    public var isDestroyed:Boolean;
    public function initialize():void {
        shp = new Shp().line(Clr.yellow, 2).rect(size.x * 2 - 3, size.y * 2 - 3);
        sc = (size.x + size.y) * 0.01 + 1;
    }
    public function update():Boolean {
        if (isDestroyed) return false;
        if (pos.y + size.y < scr.size.y) {
            pos.y += vy;
            var my:Number = getMinY(pos.x, pos.y + size.y, size.x, scr.size.y);
            if (pos.y + size.y >= my) {
                pos.y = my - size.y;
                vy = 0;
            } else {
                vy += sqrt(ticks * 0.0002) + 0.5;
                vy *= 0.9;
                if (pos.y > 0 && vy > 3) sc *= (1 + 0.01 * vy);
                if (sc > 1000) sc = 1000;
            }
        }
        shp.p(pos).draw();
        scr.drawText(String(int(sc)), pos.x, pos.y);
        if (pos.x + size.x < 0) {
            if (isInGame && pos.y > 0) {
                var s:int = sc;
                var sp:Vct = new Vct(0, pos.y);
                Msg.add("+" + s, sp, 90 + sqrt(sc * 5), 0);
                score += s;
            }
            return false;
        }
        return true;
    }
    public function checkHit(p:Vct, r:Number, isShot:Boolean):Boolean {
        if (pos.y + size.y < 0) return false;
        if (abs(p.x - pos.x) < size.x + r && abs(p.y - pos.y) < size.y + r) {
            if (isShot) isDestroyed = true;
            return true;
        }
        return false;
    }
}
function getMinY(x:Number, y:Number, sx:Number, bottomY:Number):Number {
    var my:Number = bottomY;
    for each (var b:Block in blocks) {
        var uy:Number = b.pos.y - b.size.y;
        if (uy + 10 < y) continue;
        if (abs(b.pos.x - x) > b.size.x + sx - 1) continue;
        if (uy < my) my = uy;
    }
    return my;
}
function addBlocks(x:Number, y:Number, sx:Number, sy:Number):void {
    if (sx + sy < 100 || sx < 30 || sy < 30) {
        var b:Block = new Block;
        b.pos.x = x; b.pos.y = y;
        b.size.x = sx; b.size.y = sy;
        b.initialize();
        blocks.push(b);
        return;
    }
    if (rnd.i(2) == 0) {
        var dy:Number = sy * rnd.n(0.4, 0.3);
        addBlocks(x, y - sy + dy, sx, dy);
        addBlocks(x, y + dy, sx, sy - dy);
    } else {
        var dx:Number = sx * rnd.n(0.4, 0.3);
        addBlocks(x - sx + dx, y, dx, sy);
        addBlocks(x + dx, y, sx - dx, sy);
    }
}
function removeBlocks(bottomY:Number):void {
    var bc:int = blocks.length;
    for (var i:int = 0; i < bc * 2; i++) {
        if (blocks.length <= 0) return;
        var rbi:int = rnd.i(blocks.length);
        var rb:Block = blocks[rbi];
        if (rb.pos.x < scr.size.x) continue;
        var rby:Number = rb.pos.y;
        rb.pos.y = 99999;
        for each (var b:Block in blocks) {
            if (b == rb) continue;
            var my:Number = getMinY(b.pos.x, b.pos.y + b.size.y, b.size.x, bottomY);
            if (b.pos.y + b.size.y < my - 2) {
                rb.pos.y = rby;
                break;
            }
        }
        if (rb.pos.y >= 99990) blocks.splice(rbi, 1);
    }
}
function checkBlocksHit(p:Vct, r:Number, isShot:Boolean = false):Boolean {
    for each (var b:Block in blocks) {
        if (b.checkHit(p, r, isShot)) return true;
    }
    return false;
}
var player:Player;
class Player {
    public const SIZE:Number = 10;
    public const SPEED:Number = 9;
    public var pos:Vct = new Vct;
    public var shp:Shp = new Shp().fill(Clr.green).circle(SIZE);
    public var sight:Sight = new Sight;
    public var shot:Shot;
    public var shotVel:Vct = new Vct(0, 1);
    private var np:Vct = new Vct;
    private var wasPressing:Boolean;
    public function update():void {
        if (!isInGame) {
            shp.p(pos).draw();
            return;
        }
        var v:Vct = new Vct;
        v = key.stick;
        v.scaleBy(SPEED);
        np.xy = pos;
        np.x += v.x;
        if (checkBlocksHit(np, SIZE) || !scr.isIn(np, -SIZE)) v.x = 0;
        np.xy = pos;
        np.y += v.y;
        if (checkBlocksHit(np, SIZE) || !scr.isIn(np, -SIZE)) v.y = 0;
        np.xy = pos;
        np.incrementBy(v);
        if (!checkBlocksHit(np, SIZE) || !scr.isIn(np, -SIZE)) pos.incrementBy(v);
        if (pos.x < SIZE) pos.x = SIZE;
        if (checkBlocksHit(np, SIZE)) {
            shp = new Shp().fill(Clr.red).circle(SIZE);
            Mouse.show();
            endGame();
        }
        shp.p(pos).draw();
        var ss:Number = (pos.x - scr.size.x * 0.6) * 0.1;
        if (ss > 0) scroll(ss);
        sight.update();
        if (shot) {
            if (!shot.update()) shot = null;
        } else {
            if (!wasPressing && mse.isPressing) {
                shot = new Shot;
                shot.pos.xy = pos;
                v.xy = sight.pos;
                v.decrementBy(pos);
                if (v.lengthSquared > 1) {
                    v.normalize();
                    shotVel.xy = v;
                }
                shot.vel.xy = shotVel;
                shot.vel.scaleBy(10);
                wasPressing = true;
            }
        }
        if (!mse.isPressing) wasPressing = false;
    }
}
class Sight {
    public const SIZE:Number = 10;
    public var pos:Vct = new Vct;
    public var shotVel:Vct = new Vct(0, 1);
    public var shp:Shp = new Shp().line(Clr.cyan, 2).m(0, -SIZE).l(0, SIZE).m( -SIZE, 0).l(SIZE, 0);
    public function update():void {
        pos.xy = mse.pos;
        shp.p(pos).draw();
    }
}
class Shot {
    public const SIZE:Number = 7;
    public var pos:Vct = new Vct;
    public var vel:Vct = new Vct;
    public var shp:Shp = new Shp().fill(Clr.cyan).circle(SIZE);
    public function update():Boolean {
        pos.incrementBy(vel);
        shp.p(pos).draw();
        if (checkBlocksHit(pos, SIZE, true)) return false;
        return scr.isIn(pos, SIZE);
    }
}
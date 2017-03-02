package {
    import flash.display.Sprite;
    [SWF(width="465", height="465", backgroundClr="0", frameRate="30")]
    public class Main extends Sprite {
        public function Main() {
            main = this;
            initializeFirst();
        }
    }
}
import flash.display.*;
import flash.geom.*;
import flash.filters.*;
import flash.events.*;
import flash.text.*;
import flash.utils.getTimer;
import flash.net.SharedObject;
import org.si.sion.*;
const SCR_WIDTH:int = 465, SCR_HEIGHT:int = 465;
var main:Main, bd:BitmapData;
var baseSprite:Sprite;
var bgColor:uint = 0;
function initializeFirst():void {
    Shp.initialize();
    scr = new Scr;
    bd = new BitmapData(scr.pixelSize.x, scr.pixelSize.y, true, bgColor);
    baseSprite = new Sprite;
    baseSprite.addChild(new Bitmap(bd));
    main.addChild(new Bitmap(new BitmapData(scr.pixelSize.x, scr.pixelSize.y, false, bgColor)));
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
function updateFrame(event:Event):void {
    bd.lock();
    bd.fillRect(bd.rect, bgColor);
    updateGame();
    bd.unlock();
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
        x += sin(a) * s;
        y += cos(a) * s;
    }
    public function rotate(a:Number):void {
        var px:Number = x;
        x = x * cos(a) - y * sin(a);
        y = px * sin(a) + y * cos(a);
    }
    public function set xy(v:Vector3D):void {
        x = v.x;
        y = v.y;
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
var scr:Scr;
class Scr {
    public const LETTER_COUNT:int = 36;
    public var pixelSize:Vct = new Vct(SCR_WIDTH, SCR_HEIGHT);
    public var size:Vct = new Vct(int(SCR_WIDTH / Shp.DOT_SIZE), int(SCR_HEIGHT / Shp.DOT_SIZE));
    public var center:Vct = new Vct(size.x / 2, size.y / 2);
    public var letterSprs:Vector.<Spr> = new Vector.<Spr>(LETTER_COUNT);
    private var letterPatterns:Array = [
    0x4644aaa4, 0x6f2496e4, 0xf5646949, 0x167871f4, 0x2489f697, 0xe9669696, 0x79f99668, 
    0x91967979, 0x1f799976, 0x1171ff17, 0xf99ed196, 0xee444e99, 0x53592544, 0xf9f11119,
    0x9ddb9999, 0x79769996, 0x7ed99611, 0x861e9979, 0x994444e7, 0x46699699, 0x6996fd99,
    0xf4469999, 0xf248];
    function Scr() {
        var lp:uint, d:int = 32;
        var lpIndex:int;
        var lStr:String;
        var lStrs:Array;
        for (var i:int = 0; i < LETTER_COUNT; i++) {
            lStrs = new Array;
            for (var j:int = 0; j < 5; j++) {
                lStr = "";
                for (var k:int = 0; k < 4; k++) {
                    if (++d >= 32) {
                        lp = letterPatterns[lpIndex++];
                        d = 0;
                    }
                    if (lp & 1 > 0) lStr += "1";
                    else lStr += " ";
                    lp >>= 1;
                }
                lStrs.push(lStr);
            }
            letterSprs[i] = new Spr([[Clr.white.i], lStrs, 0]);
            letterSprs[i].isStatic = true;
        }
    }
    public function isIn(p:Vector3D, spacing:Number = 0):Boolean {
        return (p.x >= -spacing && p.x <= size.x + spacing && 
            p.y >= -spacing && p.y <= size.y + spacing);
    }
    private var tPos:Vct = new Vct;
    public function drawText(text:String, x:Number, y:Number):void {
        tPos.x = x - text.length * 5 / 2;
        tPos.y = y;
        for (var i:int = 0; i < text.length; i++) {
            var c:int = text.charCodeAt(i);
            var li:int = -1;
            if (c >= 48 && c < 58) {
                li = c - 48;
            } else if (c >= 65 && c <= 90) {
                li = c - 65 + 10;
            } else if (c >= 97 && c <= 122) {
                li = c - 97 + 10;
            }
            if (li >= 0) letterSprs[li].draw(tPos);
            tPos.x += 5;
        }
    }
}
class Shp {
    public static const DOT_SIZE:int = 5;
    public static const BLUR_COUNT:int = 4;
    public static const BLUR_SIZE:int = 40;
    private static var filters:Vector.<BlurFilter> = new Vector.<BlurFilter>(BLUR_COUNT);
    public var bds:Vector.<BitmapData> = new Vector.<BitmapData>(BLUR_COUNT);
    public var rect:Rectangle = new Rectangle;
    public var size:Vct;
    public static function initialize():void {
        for (var i:int = 1; i < BLUR_COUNT; i++) {
            var w:int = BLUR_SIZE * i / (BLUR_COUNT - 1);
            filters[i] = new BlurFilter(w, w);
        }
    }
    function Shp(pattern:Ptn, colors:Array) {
        var xc:int = pattern.size.x;
        var yc:int = pattern.size.y;
        size = new Vct(xc, yc);
        var sp:Sprite = new Sprite;
        var s:Shape = new Shape;
        sp.addChild(s);
        var g:Graphics = s.graphics;
        for (var y:int = 0; y < yc; y++) {
            for (var x:int = 0; x < xc; x++) {
                var ci:int = pattern.getDot(x, y);
                if (ci <= 0) continue;
                g.beginFill(colors[ci - 1]);
                g.drawRect((x + 0.1) * DOT_SIZE + BLUR_SIZE, (y + 0.1) * DOT_SIZE + BLUR_SIZE,
                    DOT_SIZE * 0.8, DOT_SIZE * 0.8);
                g.endFill();
            }
        }
        rect = new Rectangle(0, 0,
            size.x * DOT_SIZE + BLUR_SIZE * 2, size.y * DOT_SIZE + BLUR_SIZE * 2);
        for (var i:int = 0; i < BLUR_COUNT; i++) {
            bds[i] = new BitmapData(rect.width, rect.height, true, 0);
            if (i > 0) sp.filters = [filters[i]];
            bds[i].draw(sp);
        }
    }
}
class Spr {
    public static const XINV:int = -1, YINV:int = -2;
    private static var sprs:Vector.<Spr> = new Vector.<Spr>;
    public var shps:Vector.<Shp>;
    public var pposs:Vector.<Vct>;
    public var anims:Vector.<int>;
    public var pposIndex:int;
    public var currentAnim:int;
    public var type:int;
    public var isStatic:Boolean;
    private var pos:Vct = new Vct;
    private var point:Point = new Point;
    function Spr(patterns:Array) {
        var t:int = getType(patterns);
        for each (var s:Spr in sprs) {
            if (s.type == t) {
                shps = s.shps;
                return;
            }
        }
        type = t;
        shps = new Vector.<Shp>;
        var colors:Array = patterns[0];
        for (var i:int = 1; i < patterns.length; i += 2) {
            var pattern:Ptn;
            if (patterns[i] is Ptn) pattern = patterns[i];
            else pattern = new Ptn(patterns[i]);
            var rev:int = patterns[i + 1];
            shps.push(new Shp(pattern, colors));
            if (rev == XINV) {
                shps.push(new Shp(pattern.clone().invertX(), colors));
            } else if (rev == YINV) {
                shps.push(new Shp(pattern.clone().invertY(), colors));
            } else if (rev > 1) {
                for (var j:int = 1; j < rev; j++) {
                    shps.push(new Shp(pattern.clone().rotate(PI2 * j / rev), colors));
                }
            }
        }
        sprs.push(this);
    }
    private function getType(patterns:Array):int {
        var t:int;
        for each (var c:uint in patterns[0]) t += c;
        var pattern:Ptn;
        if (patterns[1] is Ptn) pattern = patterns[1];
        else pattern = new Ptn(patterns[1]);
        t += pattern.getType() * 3;
        t += patterns[2] * 7;
        t += patterns.length * 17;
        return t;
    }
    public function draw(dp:Vct, anim:int = 0):void {
        currentAnim = anim;
        pos.x = (int(dp.x) - int(size.x / 2)) * Shp.DOT_SIZE;
        pos.y = (int(dp.y) - int(size.y / 2)) * Shp.DOT_SIZE;
        if (isStatic) {
            point.x = pos.x - Shp.BLUR_SIZE;
            point.y = pos.y - Shp.BLUR_SIZE;
            for (i = 0; i < Shp.BLUR_COUNT; i++) {
                var s:Shp = shps[currentAnim];
                bd.copyPixels(s.bds[i], s.rect, point, null, null, true);
            }
            return;
        }
        if (!pposs) {
            pposs = new Vector.<Vct>(Shp.BLUR_COUNT);
            anims = new Vector.<int>(Shp.BLUR_COUNT);
            for (var i:int = 0; i < Shp.BLUR_COUNT; i++) {
                pposs[i] = new Vct(pos.x, pos.y);
                anims[i] = anim;
            }
        }
        pposs[pposIndex].xy = pos;
        anims[pposIndex] = anim;
        var pi:int = pposIndex;
        for (i = 0; i < Shp.BLUR_COUNT; i++) {
            point.x = pposs[pi].x - Shp.BLUR_SIZE;
            point.y = pposs[pi].y - Shp.BLUR_SIZE;
            s = shps[anims[pi]];
            bd.copyPixels(s.bds[i], s.rect, point, null, null, true);
            if (--pi < 0) pi += Shp.BLUR_COUNT;
        }
        if (++pposIndex >= Shp.BLUR_COUNT) pposIndex = 0;
    }
    public function get size():Vct {
        return shps[currentAnim].size;
    }
}
class Ptn {
    public var dots:Vector.<int>;
    public var size:Vct = new Vct;
    function Ptn(pattern:Array = null):void {
        if (!pattern) return;
        setSize(pattern[0].length, pattern.length);
        for (var y:int = 0; y < size.y; y++) {
            var p:String = pattern[y];
            for (var x:int = 0; x < size.x; x++) {
                if (x >= p.length) break;
                var ci:int = p.charCodeAt(x) - 48;
                if (ci > 0) setDot(ci, x, y);
            }
        }
    }
    public function clone():Ptn {
        var p:Ptn = new Ptn;
        p.setSize(size.x, size.y);
        for (var i:int = 0; i < dots.length; i++) p.dots[i] = dots[i];
        return p;
    }
    public function setSize(w:int, h:int = -1):void {
        if (h < 0) h = w;
        dots = new Vector.<int>(w * h);
        size.x = w;
        size.y = h;
    }
    public function setDot(n:int, x:int, y:int):void {
        if (x < 0 || x >= size.x || y < 0 || y >= size.y) return;
        dots[x + y * size.x] = n;
    }
    public function getDot(x:int, y:int):int {
        if (x < 0 || x >= size.x || y < 0 || y >= size.y) return 0;
        return dots[x + y * size.x];
    }
    public function getType():int {
        var t:int;
        var dl:int = clamp(dots.length, 0, 32);
        for (var i:int = 0; i < dl; i++) t += dots[i] * (i + 1) * (i + 1);
        return t;
    }
    public function rotate(angle:Number):Ptn {
        var tp:Ptn = clone();
        var o:Vct = new Vct;
        var cx:Number = size.x / 2;
        var cy:Number = size.y / 2;
        for (var y:int = 0; y < size.y; y++) {
            for (var x:int = 0; x < size.x; x++) {
                o.x = x - cx;
                o.y = y - cy;
                o.rotate(angle);
                setDot(tp.getDot(o.x + cx, o.y + cy), x, y);
            }
        }
        return this;
    }
    public function invertX():Ptn {
        var tp:Ptn = clone();
        for (var y:int = 0; y < size.y; y++) {
            for (var x:int = 0; x < size.x; x++) {
                setDot(tp.getDot(size.x - x - 1, y), x, y);
            }
        }
        return this;
    }
    public function invertY():Ptn {
        var tp:Ptn = clone();
        for (var y:int = 0; y < size.y; y++) {
            for (var x:int = 0; x < size.x; x++) {
                setDot(tp.getDot(x, size.y - y - 1), x, y);
            }
        }
        return this;
    }
    public function drawCircle(r:Number, v:int = 1):void {
        var d:int = 3 - r * 2;
        var y:int = r;
        for (var x:int = 0; x <= y; x++) {
            setCircleDots(x, y, v);
            setCircleDots(y, x, v);
            if (d < 0) {
                d += 6 + x * 4;
            } else {
                d += 10 + x * 4 - y * 4;
                y--;
            }
        }
    }
    private function setCircleDots(x:int, y:int, v:int):void {
        var cx:int = size.x / 2, cy:int = size.y / 2;
        setDot(v, x + cx, y + cy);
        setDot(v, -x + cx, y + cy);
        setDot(v, x + cx, -y + cy);
        setDot(v, -x + cx, -y + cy);
    }
}
class Clr {
    private static const BASE_BRIGHTNESS:int = 24;
    private static const WHITENESS:int = 0;
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
    public static var black:Clr = new Clr(0, 0, 0);
    public static var red:Clr = new Clr(10, WHITENESS, WHITENESS);
    public static var green:Clr = new Clr(WHITENESS, 10, WHITENESS);
    public static var blue:Clr = new Clr(WHITENESS, WHITENESS, 10);
    public static var yellow:Clr = new Clr(10, 10, WHITENESS);
    public static var magenta:Clr = new Clr(10, WHITENESS, 10);
    public static var cyan:Clr = new Clr(WHITENESS, 10, 10);
    public static var white:Clr = new Clr(10, 10, 10);
    public static var bronze:Clr = new Clr(10, 5, 5);
    public static var silver:Clr = new Clr(7, 7, 9);
    public static var gold:Clr = new Clr(10, 10, 5);
}
class Msg {
    public static var s:Vector.<Msg> = new Vector.<Msg>;
    public static var shownMessages:Vector.<String> = new Vector.<String>;
    public static function addOnce(text:String, p:Vct,
    vx:Number = 0, vy:Number = 0, ticks:int = 90):Msg {
        if (shownMessages.indexOf(text) >= 0) return null;
        shownMessages.push(text);
        return add(text, p, vx, vy, ticks);
    }
    public static function add(text:String, p:Vct,
    vx:Number = 0, vy:Number = 0, ticks:int = 30):Msg {
        var m:Msg = new Msg;
        m.text = text;
        m.pos.xy = p;
        m.vel.x = vx / ticks;
        m.vel.y = vy / ticks;
        m.ticks = ticks;
        s.push(m);
        return m;
    }
    public var pos:Vct = new Vct, vel:Vct = new Vct;
    public var text:String, ticks:int;
    public function update():Boolean {
        pos.incrementBy(vel);
        scr.drawText(text, pos.x, pos.y);
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
        pos.x = e.stageX / Shp.DOT_SIZE;
        pos.y = e.stageY / Shp.DOT_SIZE;
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
class Snd {
    public static var driver:SiONDriver = new SiONDriver;
    public static var isStarting:Boolean;
    public static var s:Vector.<Snd> = new Vector.<Snd>;
    public var data:SiONData;
    public var isPlaying:Boolean;
    function Snd(mml:String, voice:int = 10, l:int = 64) {
        isStarting = false;
        data = driver.compile("%1@"+ voice + "l" + l + mml);
        driver.volume = 0;
        driver.play();
        s.push(this);
    }
    public function play():void {
        if (!isInGame) return;
        isPlaying = true;
    }
    public function update():void {
        if (!isPlaying) return;
        if (!isStarting) {
            driver.volume = 0.9;
            isStarting = true;
        }
        driver.sequenceOn(data, null, 0, 0, 0);
        isPlaying = false;
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
    ticks = 0;
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
    titleTicks = 5;
    return true;
}
function updateGame():void {
    updateActors(Ptc.s);
    if (!isPaused) update();
    for each (var s:Snd in Snd.s) s.update();
    scr.drawText(String(score), scr.size.x - 12, 2);
    ticks++;
    if (!isInGame) {
        scr.drawText(TITLE, scr.size.x * 0.8, scr.center.y - 10);
        scr.drawText("click", scr.size.x * 0.8, scr.center.y + 4);
        scr.drawText("to", scr.size.x * 0.8, scr.center.y + 9);
        scr.drawText("start", scr.size.x * 0.8, scr.center.y + 14);
        if (mse.isPressing) {
            if (wasReleased) wasClicked = true;
        } else {
            if (wasClicked) beginGame();
            if (--titleTicks <= 0) wasReleased = true;
        }
    }
    if (isPaused) {
        scr.drawText("paused", scr.center.x, scr.center.y - 4);
        scr.drawText("click to resume", scr.center.x, scr.center.y + 4);
    }
    updateActors(Msg.s);
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
const TITLE:String = "timebomb"
const DEBUG:Boolean = false;
var bombAppTicks:Number;
var combo:int;
var startSe:Snd = new Snd("o6d-a-o7d-o6a-e-g-o7co6g-ce-d-o5g-d-o6c", 1);
var explodeSe:Snd = new Snd("o4ef+g+a+bo5ccc+dddd", 9);
var explodeEs:Snd = new Snd("o5ddddc+cco4ba_g_f_e", 9);
var tickSe:Snd = new Snd("o6a-e-c", 1);
var comboSe:Snd = new Snd("o7gaddeo8co7gao8ccco7a", 1);
var deadSe:Snd = new Snd("o7a-g-co6co5d-co4a-g-g-o5ccccc", 10);
function initialize():void {
    Explosion.initialize();
    Circle.initialize();
    Bomb.s = new Vector.<Bomb>;
    Explosion.s = new Vector.<Explosion>;
    circle = new Circle;
    bombAppTicks = 0;
    combo = 0;
    startSe.play();
}
function update():void {
    if (--bombAppTicks <= 0) {
        var b:Bomb = new Bomb;
        if (rnd.i(2) == 0) {
            b.pos.x = int(rnd.sx(0.8, 0.1));
            b.pos.y = -Bomb.RADIUS + rnd.i(2) * (scr.size.y + Bomb.RADIUS * 2);
        } else {
            b.pos.x = -Bomb.RADIUS + rnd.i(2) * (scr.size.x + Bomb.RADIUS * 2);
            b.pos.y = int(rnd.sy(0.8, 0.1));
        }
        b.vel.x = rnd.sx(0.6, 0.2);
        b.vel.y = rnd.sx(0.6, 0.2);
        b.vel.decrementBy(b.pos);
        b.vel.normalize();
        b.vel.scaleBy(rnd.n(1, 0.5));
        b.ticks = ticks % 30 + rnd.i(6, 3) * 30;
        Bomb.s.push(b);
        var t:Number = 10 / (sqrt(ticks * 0.001) + 1);
        bombAppTicks += rnd.n(t, t);
    }
    updateActors(Explosion.s);
    circle.update();
    updateActors(Bomb.s);
    if (ticks % 30 == 0) tickSe.play();
}
class Bomb {
    public static const RADIUS:Number = 3;
    public static var s:Vector.<Bomb>;
    public var pos:Vct = new Vct;
    public var vel:Vct = new Vct;
    public var ticks:Number;
    public var spr:Spr;
    public var isDestroyed:Boolean;
    public var wasDestroyed:Boolean;
    public var timeStep:Number = 1;
    function Bomb() {
        var p:Ptn = new Ptn;
        p.setSize(RADIUS * 2 + 1);
        p.drawCircle(RADIUS);
        spr = new Spr([[Clr.magenta.i], p, 0]);
    }
    private var v:Vct = new Vct;
    private var pp1:Vct = new Vct, pp2:Vct = new Vct;
    public function update():Boolean {
        if (isDestroyed) {
            wasDestroyed = true;
            return false;
        }
        if (pos.distance(circle.pos) < RADIUS + circle.radius) {
            timeStep -= 0.1;
            circle.radius -= 0.1;
        } else {
            timeStep += 0.1;
            if (timeStep > 1) timeStep = 1;
        }
        v.xy = vel;
        v.scaleBy(timeStep);
        pos.incrementBy(v);
        spr.draw(pos);
        scr.drawText(String(int(ticks / 30)), pos.x + 4, pos.y);
        var pt:int = ticks;
        ticks -= timeStep;
        if (ticks < 30 || pos.distance(circle.pos) < RADIUS) bomb(1);
        if (int(ticks) != pt) {
            pp1.xy = pos;
            pp1.y -= RADIUS;
            pp2.xy = pp1;
            pp2.addAngle(rnd.n(0.5, PI - 0.25), rnd.n(5, 5));
            if (timeStep > 0) Ptc.add(pp1, pp2, Clr.magenta, timeStep, 10);
            else Ptc.add(pp2, pp1, Clr.magenta, -timeStep, 10);
        }
        return scr.isIn(pos, RADIUS + 1);
    }
    public function bomb(sc:int):void {
        if (isDestroyed) return;
        var e:Explosion = new Explosion;
        e.pos.xy = pos;
        e.vel.xy = vel;
        e.sc = sc + 1;
        e.timeStep = timeStep;
        e.bomb = this;
        Explosion.s.push(e);
        isDestroyed = true;
    }
}
class Explosion {
    public static var s:Vector.<Explosion>;
    public static var ptns:Array = new Array;
    public static var radiuses:Vector.<int> = new Vector.<int>;
    public static var indicies:Vector.<int> = new Vector.<int>;
    public static var startTicks:int;
    public static function initialize():void {
        if (ptns.length > 0) return;
        var i:int = 0, pi:int = 0;
        ptns.push([Clr.red.i]);
        for (var r:int = 1; r <= 10; r++) {
            var p:Ptn = new Ptn;
            p.setSize(r * 2 + 1);
            p.drawCircle(r);
            ptns.push(p);
            ptns.push(0);
            indicies[i] = pi;
            radiuses[i++] = r;
            pi++;
        }
        r -= 2; pi -= 2;
        while (r > 0) {
            indicies[i] = pi;
            radiuses[i++] = r;
            r--; pi--;
        }
        startTicks = i - 1;
    }
    public var pos:Vct = new Vct;
    public var vel:Vct = new Vct;
    public var ticks:Number = startTicks;
    public var spr:Spr = new Spr(ptns);
    public var sc:int;
    public var timeStep:Number;
    public var bomb:Bomb;
    public var isFirst:Boolean = true;
    private var pp:Vct = new Vct;
    public function update():Boolean {
        if (isFirst) {
            for (var i:int = 10; i < 20; i++) {
                for (var j:int = 0; j < 3; j++) {
                    pp.xy = pos;
                    pp.addAngle(rnd.n(PI2), rnd.n(20, 20));
                    Ptc.add(pos, pp, Clr.red, timeStep, i);
                }
            }
            isFirst = false;
            explodeSe.play();
        }
        pos.incrementBy(vel);
        vel.scaleBy(0.9);
        var t:int = ticks;
        spr.draw(pos, indicies[t]);
        var r:Number = radiuses[t];
        for each (var b:Bomb in Bomb.s) {
            if (b.pos.distance(pos) < r + Bomb.RADIUS) b.bomb(sc);
        }
        var cd:Number = pos.distance(circle.pos);
        if (cd < r) circle.dead();
        if (cd < r + circle.radius) {
            timeStep -= 0.1;
            circle.radius -= 0.1;
        } else {
            timeStep += 0.1;
            if (timeStep > 1) timeStep = 1;
        }
        var pt:int = ticks;
        ticks -= timeStep;
        if (int(ticks) != pt && timeStep < 0 && ticks >= 10 && ticks <= 20) {
            for (j = 0; j < 3; j++) {
                pp.xy = pos;
                pp.addAngle(rnd.n(PI2), rnd.n(20, 20));
                Ptc.add(pp, pos, Clr.red, -timeStep, ticks);
            }
        }
        if (ticks > startTicks) {
            if (bomb.wasDestroyed) Bomb.s.push(bomb);
            bomb.ticks = 30;
            bomb.timeStep = timeStep;
            bomb.isDestroyed = bomb.wasDestroyed = false;
            explodeEs.play();
            return false;
        } else if (ticks < 0) {
            combo++;
            if (Explosion.s.length <= 1) {
                circle.addScore(combo);
                combo = 0;
            }
            return false;
        }
        return true;
    }
}
var circle:Circle;
class Circle {
    public static const MAX_RADIUS:Number = 20;
    public static var ptns:Array = new Array;
    public static function initialize():void {
        if (ptns.length > 0) return;
        var i:int = 0, pi:int = 0;
        ptns.push([Clr.cyan.i]);
        for (var r:int = 0; r <= MAX_RADIUS; r++) {
            var p:Ptn = new Ptn;
            p.setSize(r * 2 + 1);
            p.drawCircle(r);
            ptns.push(p);
            ptns.push(0);
        }
    }
    public var pos:Vct = new Vct;
    public var spr:Spr = new Spr(ptns);
    public var manSpr:Spr = new Spr([
    [Clr.green.i],[
    "  11  ",
    "  11",
    "   1",
    " 1111",
    "   1 1",
    " 111",
    "    1",
    ],Spr.XINV,[
    " 11   ",
    " 11",
    "   1",
    " 11111",
    "1  1 ",
    "  1 11",
    "  1",
    ], Spr.XINV]);
    public var radius:Number = MAX_RADIUS;
    public var msg:Msg;
    public var addedScore:int;
    public var mvDist:Number = 0;
    public var manAnim:int, manWay:int;
    public var deadTicks:int = -1;
    private var pp:Vct = new Vct;
    public function update():void {
        if (deadTicks < 0 && !isInGame) {
            radius = 0;
            return;
        }
        if (msg && msg.ticks == 15) {
            msg.text = String(addedScore);
            msg = null;
        }
        pp.xy = pos;
        if (isInGame) pos.xy = mse.pos;
        mvDist += pos.distance(pp);
        if (mvDist > 10) {
            manAnim = (manAnim + 1) % 2;
            if (pp.x < pos.x) manWay = 1;
            else manWay = 0;
            mvDist -= 10;
        }
        if (deadTicks < 10) manSpr.draw(pos, manAnim * 2 + manWay);
        if (deadTicks > 0) {
            if (--deadTicks <= 0) {
                addDeatPtcs();
                deadTicks = 30;
            }
        }
        radius += 0.5;
        radius = clamp(radius, 1, MAX_RADIUS);
        spr.draw(pos, int(radius));
    }
    private var sp:Vct = new Vct;
    public function addScore(combo:int):void {
        if (!isInGame || combo <= 1) return;
        var oy:Number = 30;
        if (circle.pos.y > scr.center.y) oy *= -1;
        sp.xy = circle.pos;
        sp.y += oy / 3;
        sp.x = clamp(sp.x, 20, scr.size.x - 20);
        msg = Msg.add("COMBO " + String(combo), sp, 0, oy);
        addedScore = (combo / 2) * (combo / 2);
        score += addedScore;
        comboSe.play();
    }
    public function dead():void {
        if (!isInGame) return;
        addDeatPtcs();
        deadSe.play();
        deadTicks = 30;
        endGame();
    }
    private var dp:Vct = new Vct;
    private function addDeatPtcs():void {
        for (var i:int = 0; i < 50; i++) {
            dp.xy = pos;
            dp.addAngle(rnd.n(PI2), rnd.n(30, 30));
            Ptc.add(pos, dp, Clr.green, 1, rnd.i(30, 30));
        }
    }
}
class Ptc {
    public static var s:Vector.<Ptc> = new Vector.<Ptc>;
    public var pos:Vct = new Vct;
    public var vel:Vct = new Vct;
    public var spr:Spr;
    public var ticks:int;
    public var startTicks:int;
    public var timeStep:Number = 1;
    function Ptc(clr:Clr) {
        spr = new Spr([[clr.i], ["1"], 0]);
    }
    private var v:Vct = new Vct;
    public function update():Boolean {
        v.xy = vel;
        v.scaleBy(timeStep);
        pos.incrementBy(v);
        spr.draw(pos);
        if (pos.distance(circle.pos) < circle.radius) {
            timeStep -= 0.1;
        } else {
            timeStep += 0.1;
            if (timeStep > 1) timeStep = 1;
        }
        ticks -= timeStep;
        return ticks < startTicks && ticks > 0;
    }
    public static function add(p:Vct, tp:Vct, clr:Clr, timeStep:Number, ticks:Number):void {
        var pt:Ptc = new Ptc(clr);
        pt.pos.xy = p;
        pt.vel.xy = tp;
        pt.vel.decrementBy(pt.pos);
        pt.vel.scaleBy(1 / ticks);
        pt.timeStep = timeStep;
        pt.ticks = pt.startTicks = ticks;
        s.push(pt);
    }
}
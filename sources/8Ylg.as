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
import adobe.utils.CustomActions;
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
            var s:Shp = shps[anims[pi]];
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
    public function setSize(w:int, h:int):void {
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
    vx:Number = 0, vy:Number = 0, ticks:int = 90):Msg {
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
class Ptc {
    public static var s:Vector.<Ptc> = new Vector.<Ptc>;
    public var pos:Vct = new Vct;
    public var vel:Vct = new Vct;
    public var spr:Spr;
    public var ticks:int;
    function Ptc(clr:Clr) {
        spr = new Spr([[clr.i], ["1"], 0]);
    }
    public function update():Boolean {
        pos.incrementBy(vel);
        vel.scaleBy(0.98);
        spr.draw(pos);
        return --ticks > 0;
    }
    public static function add(p:Vct, clr:Clr, count:Number, speed:Number,
    ticks:Number = 30, angle:Number = 0, angleWidth:Number = Math.PI):void {
        for (var i:int = 0; i < count; i++) {
            var pt:Ptc = new Ptc(clr);
            pt.pos.xy = p;
            pt.vel.addAngle(angle + rnd.n(angleWidth) * rnd.pm(),
            speed * rnd.n(1, 0.5));
            pt.ticks = ticks * rnd.n(1, 0.5);
            s.push(pt);
        }
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
    public static var isPlaying:Boolean;
    public var data:SiONData;
    function Snd(mml:String, voice:int = 10, l:int = 64) {
        isPlaying = false;
        data = driver.compile("%1@"+ voice + "l" + l + mml);
        driver.volume = 0;
        driver.play();
    }
    public function play():void {
        if (!isInGame) return;
        if (!isPlaying) {
            driver.volume = 0.9;
            isPlaying = true;
        }
        driver.sequenceOn(data, null, 0, 0, 0);
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
const TITLE:String = "ufast"
const DEBUG:Boolean = false;
const STAGE_PANEL_SIZE:int = 5;
const STAGE_COUNT:int = 25;
var sharedObject:SharedObject;
var sharedObjectData:Object;
var stage:int = -1;
var stageScore:int;
var stageTicks:int;
var stageClearTicks:int;
var stageStates:Vector.<int>;
var isStageSelecting:Boolean;
var onOffButton:OnOffButton;
var isIndicatorOn:Boolean = true;
var appSe:Snd = new Snd("o4d+dd+o5edd+f+g+o6cco4d+o5dd+f+o4dd+f+ago5a+a");
var fireSe:Snd = new Snd("o5g+ed+", 9);
var enemyGetSe:Snd = new Snd("o5cddo4a+a+o5c+eed+co4a+o5g+o4g+o5f");
var playerDstSe:Snd = new Snd("o4f+f+go5fo4a+aao5do4a+o5co4bbb", 9);
var tickSe:Snd = new Snd("o5c+d+");
function initialize():void {
    if (!sharedObject) {
        sharedObject = SharedObject.getLocal("abagames_" + TITLE);
        sharedObjectData = sharedObject.data;
    }
    getState();
    if (isInGame) startStageSelect();
    else startStage();
}
function startStageSelect():void {
    isStageSelecting = true;
    StageBox.s = new Vector.<StageBox>;
    for (var i:int = 0; i < STAGE_COUNT; i++) {
        StageBox.s.push(new StageBox(i));
    }
    onOffButton = new OnOffButton;
    onOffButton.isOn = isIndicatorOn;
}
function startStage():void {
    if (stage >= STAGE_COUNT) {
        endGame();
        return;
    }
    saveState();
    isStageSelecting = false;
    rnd = new Rnd(stage + 20);
    Enemy.s = new Vector.<Enemy>;
    Bullet.s = new Vector.<Bullet>;
    player = new Player;
    var rank:Number = clamp(stage + 1, 1, 999);
    var ic:int = rnd.i(sqrt(rank), 1);
    for (var i:int = 0; i < ic; i++) Enemy.s.push(new Enemy(rank / ic));
    stageTicks = stageClearTicks = 0;
    for (i = 0; i < HISTORY_LENGTH - 1; i++) {
        updateActors(Enemy.s);
        updateActors(Bullet.s);
    }
    if (isInGame) {
        Msg.add("STAGE " + (stage + 1), scr.center, 0, 0, 30);
        Msg.addOnce("GET YELLOW ENEMY", new Vct(50, 10), 0, 0, 60);
    }
    stageTicks = 0;
    stageScore = 0;
    stageClearTicks = -1;
    appSe.play();
}
function update():void {
    if (isStageSelecting) updateStageSelect();
    else updateStage();
}
function updateStageSelect():void {
    updateActors(StageBox.s);
    scr.drawText("SELECT STAGE", 48, 45);
    scr.drawText("INDICATOR", 38, 10);
    onOffButton.update();
}
var isFiring:Boolean;
function updateStage():void {
    isFiring = false;
    updateActors(Bullet.s);
    updateActors(Enemy.s);
    if (isFiring) fireSe.play();
    if (isIndicatorOn) for each (var b:Bullet in Bullet.s) b.drawWarn();
    for each (var e:Enemy in Enemy.s) e.draw();
    if (isInGame) player.update();
    for each (b in Bullet.s) b.draw();
    stageTicks++;
    if (stageClearTicks < 0 && Enemy.s.length <= 0) stageClear();
    if (stageClearTicks > 0 && --stageClearTicks <= 0) {
        stage++;
        startStage();
    }
    if (stageClearTicks < 0 && stageTicks % 15 == 0) tickSe.play();
}
function stageClear():void {
    stageClearTicks = 30;
    var ss:int = clamp(stageTicks / (10 * 30), 0, 2);
    Msg.add("STAGE CLEAR", scr.center, 0, 0, 30);
    stageStates[stage] = stageScore;
    openStage(stage + 1);
    saveState();
}
function openStage(s:int):void {
    if (s >= STAGE_COUNT) return;
    if (stageStates[s] == 0) stageStates[s] = -1;
}
function getState():void {
    if (sharedObjectData.stageStates) {
        stageStates = sharedObjectData.stageStates;
        isIndicatorOn = sharedObjectData.isIndicatorOn;
    } else {
        stageStates = new Vector.<int>(STAGE_COUNT);
        stageStates[0] = -1;
        isIndicatorOn = true;
    }
}
function saveState():void {
    sharedObjectData.stageStates = stageStates;
    sharedObjectData.isIndicatorOn = isIndicatorOn;
}
class Button {
    public var pos:Vct = new Vct;
    public var size:Vct;
    public var spr:Spr;
    public var isPressed:Boolean;
    function Button(color:uint, w:int, h:int) {
        size = new Vct(w, h);
        var sprpt:Array = new Array;
        var co:Clr = new Clr, cs:Clr = new Clr;
        co.rgb = Clr.cyan;
        co.brightness = 0.7;
        cs.rgb = Clr.magenta;
        cs.brightness = 0.7;
        sprpt.push([color, co.i, cs.i]);
        for (var i:int = 0; i < 3; i++) {
            var pattern:Array = new Array;
            var ss:String = " ";
            if (i > 0) ss = String(i + 1);
            for (var y:int = 0; y < size.y; y++) {
                var ps:String = "";
                for (var x:int = 0; x < size.x; x++) {
                    if (y == 0 || y == size.y - 1 || x == 0 || x == size.x - 1) ps += "1";
                    else ps += ss
                }
                pattern.push(ps);
            }
            sprpt.push(pattern);
            sprpt.push(0);
        }
        spr = new Spr(sprpt);
    }
    public function draw(text:String):void {
        var anim:int = 0;
        if (abs(mse.pos.x - pos.x) < size.x / 2 && abs(mse.pos.y - pos.y) < size.y / 2) {
            if (mse.isPressing) {
                isPressed = true;
                anim = 2;
            } else {
                anim = 1;
            }
        } else {
            isPressed = false;
        }
        spr.draw(pos, anim);
        scr.drawText(text, pos.x + 3, pos.y);
    }
}
class StageBox extends Button {
    public static var s:Vector.<StageBox>;
    public var number:int;
    public var state:int;
    public var stageStateColors:Array = [Clr.blue, Clr.white, Clr.yellow, Clr.red];
    function StageBox(stg:int) {
        if (stage == stg) state = 3;
        else if (stageStates[stg] == 0) state = 0;
        else if (stageStates[stg] == -1) state = 1;
        else state = 2;
        super(stageStateColors[state].i, 11, 7);
        this.number = stg;
        pos.x = (stg % STAGE_PANEL_SIZE) * (size.x + 1) + 21;
        pos.y = int(stg / STAGE_PANEL_SIZE) * (size.y + 1) + 55;
    }
    public function update():Boolean {
        super.draw(String(number + 1));
        if (!mse.isPressing && isPressed) {
            if (state > 0) {
                stage = number;
                startStage();
            } else {
                Msg.add("LOCKED", new Vct(63, 36), 0, 0, 1);
            }
        }
        return true;
    }
}
class OnOffButton extends Button {
    public var isOn:Boolean;
    function OnOffButton() {
        super(Clr.white.i, 16, 7);
        pos.x = 68; pos.y = 10;
    }
    public function update():void {
        var str:String = "OFF";
        if (isOn) str = "ON";
        super.draw(str);
        if (!mse.isPressing && isPressed) {
            isPressed = false;
            isOn = !isOn;
            isIndicatorOn = isOn;
        }
    }
}
const HISTORY_LENGTH:int = 30;
class Enemy {
    public static var s:Vector.<Enemy>;
    public var pos:Vct = new Vct;
    public var center:Vct = new Vct;
    public var mvAngle:Vct = new Vct;
    public var mvAngleVel:Vct = new Vct;
    public var mvSize:Vct = new Vct;
    public var posHist:Vector.<Vct> = new Vector.<Vct>(HISTORY_LENGTH);
    public var posHistIndex:int;
    public var turrets:Vector.<Turret> = new Vector.<Turret>;
    public var spr:Spr = new Spr([
    [Clr.yellow.i, Clr.red.i],
    [" 1 1 ", "11 11", "  2  ", "11 11", " 1 1 "],
    0]);
    function Enemy(rank:Number) {
        center.x = rnd.sx(0.3, 0.3);
        center.y = rnd.sy(0.1, 0.15);
        mvAngle.x = rnd.n(PI2);
        mvAngle.y = rnd.n(PI2);
        mvAngleVel.x = rnd.n(0.05, 0.05) * rnd.pm();
        mvAngleVel.y = rnd.n(0.05, 0.05) * rnd.pm();
        mvSize.x = rnd.sx(0.25, 0.1);
        mvSize.y = rnd.sx(0.05, 0.05);
        calcPos();
        for (var i:int = 0; i < HISTORY_LENGTH; i++) posHist[i] = new Vct(pos.x, pos.y);
        var tc:int = rnd.i(sqrt(rank), 1);
        var sb:Number = sqrt(rank / tc);
        while (tc > 0) {
            var t:Turret = new Turret(rnd.n(1, 1) * sb * 3);
            if (tc >= 2) {
                t.ofs.x = rnd.sx(0.05, 0.05) * rnd.pm();
                t.ofs.y = rnd.sy(0.1) * rnd.pm();
                turrets.push(t);
                var mt:Turret = new Turret;
                mt.mirror(t);
                turrets.push(mt);
                tc -= 2;
            } else {
                turrets.push(t);
                tc--;
            }
        }
    }
    private function calcPos():void {
        pos.x = sin(mvAngle.x) * mvSize.x + center.x;
        pos.y = sin(mvAngle.y) * mvSize.y + center.y;
    }
    public function update():Boolean {
        mvAngle.incrementBy(mvAngleVel);
        calcPos();
        for each (var t:Turret in turrets) t.update(this);
        posHist[posHistIndex].xy = pos;
        if (++posHistIndex >= HISTORY_LENGTH) posHistIndex = 0;
        var cp:Vct = posHist[posHistIndex];
        if (isInGame && cp.distance(player.pos) < 5) {
            Ptc.add(cp, Clr.yellow, 30, 2);
            for (var i:int = 0; i < Bullet.s.length; i++) {
                if (Bullet.s[i].parentEnemy == this) Bullet.s.splice(i--, 1);
            }
            var asc:int = (100 / sqrt(stageTicks * 0.1 + 1) + 1 ) * (stage + 1);
            score += asc;
            stageScore += asc;
            Msg.add(String(asc), cp, 0, -20, 30);
            enemyGetSe.play();
            return false;
        }
        return true;
    }
    public function draw():void {
        spr.draw(posHist[posHistIndex]);
    }
}
class Turret {
    public static const ANGLE_CONT:int = 0, ANGLE_REV:int = 1, ANGLE_RESET:int = 2;
    public var ofs:Vct = new Vct;
    public var interval:Number;
    public var duration:Number;
    public var restDuration:Number;
    public var startAngle:Number;
    public var angleVel:Number;
    public var startSpeed:Number;
    public var speedVel:Number = 0;
    public var angleType:int;
    public var angle:Number, speed:Number;
    public var ticks:int, fireTicks:Number;
    function Turret(speed:Number = -1) {
        if (speed == -1) return;
        interval = rnd.n(2);
        var count:int = rnd.i(6, 3);
        duration = interval * count;
        var rd:Number = rnd.n(5, 10) - count;
        restDuration = clamp(rd * 3 - duration, 30, 90);
        angle = rnd.n(0.5) * rnd.pm();
        angleVel = rnd.n(0.5, 2.5) * rnd.pm() / count;
        startAngle = angle - angleVel * count / 2
        if (rnd.i(2) == 0) speedVel = speed * rnd.n(0.4, 0.4) * rnd.pm() / count;
        startSpeed = speed - speedVel * count / 2;
        angleType = rnd.i(4);
        if (angleType == 1) angleType = 3;
        ticks = rnd.i(restDuration) + duration;
        angle = startAngle;
    }
    public function mirror(t:Turret):void {
        ofs.x = -t.ofs.x;
        ofs.y = t.ofs.y;
        interval = t.interval;
        duration = t.duration;
        restDuration = t.restDuration;
        startAngle = -t.startAngle;
        angleVel = -t.angleVel;
        startSpeed = t.startSpeed;
        speedVel = t.speedVel;
        angleType = t.angleType;
        ticks = t.ticks;
        angle = startAngle;
    }
    private var bp:Vct = new Vct;
    public function update(e:Enemy):void {
        if (--ticks <= 0) {
            ticks = duration + restDuration;
            if ((angleType & ANGLE_REV) > 0) {
                startAngle *= -1;
                angleVel *= -1;
            }
            if ((angleType & ANGLE_RESET) > 0) angle = startAngle;
            speed = startSpeed;
            fireTicks = 0;
        }
        if (fireTicks <= duration) {
            bp.xy = e.pos;
            bp.incrementBy(ofs);
            var nft:Number = fireTicks + 1;
            while (fireTicks <= duration && fireTicks <= nft) {
                Bullet.s.push(new Bullet(bp, angle, speed, e));
                angle += angleVel;
                speed += speedVel;
                fireTicks += interval;
            }
        }
    }
}
class Bullet {
    public static var s:Vector.<Bullet>;
    public var pos:Vct = new Vct;
    public var vel:Vct = new Vct;
    public var angle:Number, speed:Number;
    public var posHist:Vector.<Vct> = new Vector.<Vct>(HISTORY_LENGTH);
    public var posHistIndex:int;
    public var spr:Spr = new Spr([
    [Clr.magenta.i, Clr.red.i],
    ["111", "121", "111"],
    0]);
    public var ticks:int;
    public var parentEnemy:Enemy;
    function Bullet(p:Vct, angle:Number, speed:Number, enemy:Enemy):void {
        pos.xy = p;
        this.angle = angle;
        this.speed = speed;
        parentEnemy = enemy;
        vel.addAngle(angle, speed);
        for (var i:int = 0; i < HISTORY_LENGTH; i++) posHist[i] = new Vct(pos.x, pos.y);
    }
    private var cp:Vct = new Vct;
    public function update():Boolean {
        pos.incrementBy(vel);
        posHist[posHistIndex].xy = pos;
        if (++posHistIndex >= HISTORY_LENGTH) posHistIndex = 0;
        if (++ticks < HISTORY_LENGTH) return true;
        cp.xy = posHist[posHistIndex];
        if (ticks == HISTORY_LENGTH) {
            Ptc.add(cp, Clr.magenta, 10, speed * 0.2, 15, angle, 0.2);
            isFiring = true;
        }
        Ptc.add(cp, Clr.magenta, 1, speed * 0.3, 10, angle + PI, 0);
        for (var i:int = 0; i < 5; i++) {
            if (cp.distance(player.pos) < 2) {
                player.destroy();
                return false;
            }
            cp.addAngle(angle, -speed / 6);
        }
        return scr.isIn(cp, 2);
    }
    public function draw():void {
        if (ticks < HISTORY_LENGTH) return;
        spr.draw(posHist[posHistIndex]);
    }
    private var pph:Vct = new Vct, dp:Vct = new Vct, dof:Vct = new Vct;
    public function drawWarn():void {
        var ci:int = 250 - HISTORY_LENGTH * 6;
        var hi:int = posHistIndex;
        for (var i:int = 0; i < HISTORY_LENGTH - 1; i++) {
            if (--hi < 0) hi = HISTORY_LENGTH - 1;
            var ph:Vct = posHist[hi];
            if (i > 0) {
                var d:int = pph.distance(ph) / 2;
                dp.xy = ph;
                dof.xy = pph;
                dof.decrementBy(ph);
                dof.scaleBy(1 / d);
                for (var j:int = 0; j < d; j++) {
                    drawDot(dp, 0xff000000 + ci * 0x10000);
                    dp.incrementBy(dof);
                }
            }
            ci += 6;
            pph.xy = ph;
        }
    }
    private var rect:Rectangle = new Rectangle(0, 0, Shp.DOT_SIZE * 0.8, Shp.DOT_SIZE * 0.8);
    private function drawDot(p:Vct, c:uint):void {
        rect.x = (p.x + 0.1) * Shp.DOT_SIZE;
        rect.y = (p.y + 0.1) * Shp.DOT_SIZE;
        bd.fillRect(rect, c);
    }
}
var player:Player;
class Player {
    public const SPEED:Number = 2;
    public var pos:Vct = new Vct;
    public var spr:Spr = new Spr([
    [Clr.green.i, Clr.cyan.i],
    [" 1 ", " 1 ", "121", "121"]
    ,0]);
    function Player() {
        pos.x = scr.center.x;
        pos.y = scr.size.y * 0.95;
    }
    private var o:Vct = new Vct;
    public function update():void {
        o.xy = mse.pos;
        o.decrementBy(pos);
        var sp:Number = SPEED;
        if (stageTicks < 60) sp = SPEED * stageTicks / 60;
        if (o.length <= sp) {
            pos.xy = mse.pos;
        } else {
            o.normalize();
            o.scaleBy(sp);
            pos.incrementBy(o);
        }
        spr.draw(pos);
    }
    public function destroy():void {
        if (!isInGame) return;
        Ptc.add(pos, Clr.green, 100, 3);
        playerDstSe.play();
        sharedObject.flush();
        endGame();
    }
}
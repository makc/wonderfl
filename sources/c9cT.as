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
            letterSprs[i] = new Spr([[Clr.white.i], lStrs]);
        }
    }
    public function isIn(p:Vector3D, spacing:Number = 0):Boolean {
        return (p.x >= -spacing && p.x <= pixelSize.x + spacing && 
            p.y >= -spacing && p.y <= pixelSize.y + spacing);
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
    private static var shps:Vector.<Shp> = new Vector.<Shp>;
    public var bds:Vector.<BitmapData> = new Vector.<BitmapData>(BLUR_COUNT);
    public var rect:Rectangle = new Rectangle;
    public var size:Vct;
    public var type:int;
    public static function initialize():void {
        for (var i:int = 1; i < BLUR_COUNT; i++) {
            var w:int = BLUR_SIZE * i / (BLUR_COUNT - 1);
            filters[i] = new BlurFilter(w, w);
        }
    }
    public static function n(pattern:Array, colors:Array,
    isXRev:Boolean = false, isYRev:Boolean = false, isXYSwap:Boolean = false):Shp {
        var t:int = getType(pattern, colors, isXRev, isYRev, isXYSwap);
        for each (var s:Shp in shps) {
            if (s.type == t) return s;
        }
        s = new Shp(pattern, colors, isXRev, isYRev, isXYSwap);
        s.type = t;
        return s;
    }
    private static function getType(pattern:Array, colors:Array,
    isXRev:Boolean, isYRev:Boolean, isXYSwap:Boolean):int {
        var t:int;
        for each (var c:uint in colors) t += c;
        t += pattern.length;
        var s:String = String(pattern[0]);
        for (var i:int = 0; i < s.length; i++) t += s.charCodeAt(i) * (i + 1);
        if (isXRev) t += i + 1;
        if (isYRev) t += i + 2;
        if (isXYSwap) t += i + 3;
        return t;
    }
    function Shp(pattern:Array, colors:Array,
    isXRev:Boolean, isYRev:Boolean, isXYSwap:Boolean) {
        var xc:int = String(pattern[0]).length;
        var yc:int = pattern.length;
        size = new Vct(xc, yc);
        var sp:Sprite = new Sprite;
        var s:Shape = new Shape;
        sp.addChild(s);
        var g:Graphics = s.graphics;
        for (var y:int = 0; y < yc; y++) {
            var p:String = pattern[y];
            for (var x:int = 0; x < xc; x++) {
                if (x >= p.length) break;
                var ci:int = p.charCodeAt(x) - 49;
                if (ci < 0) continue;
                g.beginFill(colors[ci]);
                var dx:int = x;
                if (isXRev) dx = xc - x - 1;
                var dy:int = y;
                if (isYRev) dy = yc - y - 1;
                if (isXYSwap) {
                    var t:int = dx; dx = dy; dy = t;
                }
                g.drawRect((dx + 0.1) * DOT_SIZE + BLUR_SIZE, (dy + 0.1) * DOT_SIZE + BLUR_SIZE,
                    DOT_SIZE * 0.8, DOT_SIZE * 0.8);
                g.endFill();
            }
        }
        if (isXYSwap) {
            t = size.x; size.x = size.y; size.y = t;
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
    public static const XREV:int = 1, YREV:int = 2, XYSWAP:int = 3;
    public var shps:Vector.<Shp> = new Vector.<Shp>;
    public var pposs:Vector.<Vct>;
    public var anims:Vector.<int>;
    public var pposIndex:int;
    public var currentAnim:int;
    private var pos:Vct = new Vct;
    private var point:Point = new Point;
    function Spr(patterns:Array) {
        var colors:Array = patterns[0];
        for (var i:int = 1; i < patterns.length; i += 2) {
            var pattern:Array = patterns[i];
            var rev:int = patterns[i + 1];
            var isXRev:Boolean = (rev & XREV) > 0;
            var isYRev:Boolean = (rev & YREV) > 0;
            var shp:Shp;
            shp = Shp.n(pattern, colors);
            shps.push(shp);
            if (rev == XREV) {
                shp = Shp.n(pattern, colors, true);
                shps.push(shp);
            } else if (rev == YREV) {
                shp = Shp.n(pattern, colors, false, true);
                shps.push(shp);
            } else if (rev == XYSWAP) {
                shp = Shp.n(pattern, colors, false, false, true);
                shps.push(shp);
                shp = Shp.n(pattern, colors, true);
                shps.push(shp);
                shp = Shp.n(pattern, colors, true, false, true);
                shps.push(shp);
            }
        }
    }
    public function draw(dp:Vct, anim:int = 0):void {
        currentAnim = anim;
        pos.x = int(dp.x) * Shp.DOT_SIZE;
        pos.y = int(dp.y) * Shp.DOT_SIZE;
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
    public static function add(p:Vct, clr:Clr, force:Number, speed:Number,
    ticks:Number = 30, angle:Number = 0, angleWidth:Number = Math.PI):void {
        for (var i:int = 0; i < force; i++) {
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
class Snd {
    public static var driver:SiONDriver = new SiONDriver;
    public static var isPlaying:Boolean;
    public var data:SiONData;
    function Snd(mml:String, l:int = 32, voice:String = "%1@10") {
        isPlaying = false;
        data = driver.compile(voice + "l" + l + mml);
        driver.volume = 0;
        driver.play();
    }
    public function play():void {
        if (!isPlaying) {
            driver.volume = 0.7;
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
    titleTicks = 30;
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
const TITLE:String = "vault"
const DEBUG:Boolean = false;
var walkSes:Vector.<Snd> = new Vector.<Snd>(2);
var jumpSe:Snd, landSe:Snd;
var scrollSe:Snd;
var nextFloorAddDist:Number;
var scrollDist:Number;
var scrollXDist:Number;
var rank:Number;
function initialize():void {
    player = new Player;
    floors = new Vector.<Floor>;
    walkSes[0] = new Snd(">d");
    walkSes[1] = new Snd(">a");
    jumpSe = new Snd("agedc");
    landSe = new Snd("eg", 64);
    scrollSe = new Snd("<e", 64);
    scrollDist = 0;
    scrollXDist = 0;
    nextFloorAddDist = 0;
    if (!isInGame) rank = 3;
    else rank = 0;
    addFloor(scr.size.y);
    floors[4].pos.x = scr.center.x - floors[4].pwidth / 2;
    floors[5].pos.x = floors[4].pos.x + scr.size.x;
}
function update():void {
    updateActors(floors);
    if (isInGame) {
        player.update();
        rank = sqrt(ticks * 0.005);
    }
    scrollY(0.1 + rank * 0.1);
}
function scrollY(d:Number):void {
    player.pos.y += d;
    for each (var f:Floor in floors) f.pos.y += d;
    for each (var p:Ptc in Ptc.s) p.pos.y += d;
    addFloor(d);
    scrollDist += d;
    if (scrollDist > 5) {
        scrollDist -= 5;
        if (isInGame) {
            scrollSe.play();
            score += 5;
        }
    }
}
function addFloor(d:Number):void {
    nextFloorAddDist -= d;
    while (nextFloorAddDist <= 0) {
        var f:Floor = new Floor;
        f.setRandom(-nextFloorAddDist);
        floors.push(f);
        var mf:Floor = new Floor;
        mf.setMirror(f);
        floors.push(mf);
        nextFloorAddDist += rnd.i(25, 7);
    }
}
function scrollX(d:Number):void {
    player.pos.x += d;
    for each (var f:Floor in floors) f.pos.x += d;
    for each (var p:Ptc in Ptc.s) p.pos.x += d;
    scrollXDist += d;
}
var player:Player;
class Player {
    public var spr:Spr = new Spr([
    [Clr.green.i],[
    "  11  ",
    "  11",
    "   1",
    " 1111",
    "   1 1",
    " 111",
    "    1",
    ],Spr.XREV,[
    " 11   ",
    " 11",
    "   1",
    " 11111",
    "1  1 ",
    "  1 11",
    "  1",
    ],Spr.XREV,[
    "  11   ",
    "  11",
    "1  1  1",
    " 11111",
    "   1 ",
    "111 1 1",
    "     1",
    ],Spr.XREV,[
    "  11   ",
    "  11",
    " 1 1 1",
    "  111",
    "   1 ",
    "  1 1",
    "  1 1",
    ],Spr.XREV]);
    public var pos:Vct = new Vct;
    public var bpos:Vct = new Vct, footPos:Vct = new Vct;
    public var vel:Vct = new Vct;
    public var animTicks:Number = 0;
    public var anim:int, baseAnim:int;
    public var floorOn:Floor;
    public var isJumpReady:Boolean;
    function Player() {
        pos.x = scr.center.x;
        pos.y = scr.size.y * 0.1;
    }
    public function update():void {
        if (ticks == 0) Msg.addOnce("arrow move", new Vct(40, 10), 0, 0, 120);
        if (ticks == 30) Msg.addOnce("z jump", new Vct(40, 20), 0, 0, 90);
        if (floorOn) {
            pos.y = floorOn.pos.y - spr.size.y;
            vel.x += floorOn.arrowVel.x * 0.25 + floorOn.beltVel.x * 0.25;
            vel.y = 0;
            var sx:Number = key.stick.x;
            if (sx != 0) {
                vel.x += sx * 0.3;
                var pwanim:int = int(animTicks) % 2;
                animTicks += abs(sx * 0.3);
                if (sx > 0) baseAnim = 1;
                else baseAnim = 0;
                var wanim:int = int(animTicks) % 2;
                anim = baseAnim + wanim * 2;
                if (wanim != pwanim) {
                    walkSes[wanim].play();
                    floorOn.addScore();
                }
            }
            vel.x *= 0.8;
            if (isJumpReady && key.isButtonPressed) {
                anim = baseAnim + 4;
                vel.y = -3;
                jumpSe.play();
                Ptc.add(footPos, Clr.green, 15, vel.length, 30, vel.way + PI, 0.2);
                floorOn = null;
            } else {
                if (!floorOn.checkHit(bpos, spr.size)) floorOn = null;
            }
        }
        if (!key.isButtonPressed) isJumpReady = true;
        if (!floorOn) {
            if (key.isButtonPressed) vel.y += 0.1;
            else vel.y += 0.2;
            vel.x += key.stick.x * 0.05;
            vel.x *= 0.98;
            if (vel.y > 0 && anim < 6) anim = baseAnim + 6;
            animTicks = int(animTicks) - 0.01;
            Ptc.add(footPos, Clr.green, 1, 0.1, 10, vel.way + PI, 0.1);
            if (vel.y > 0) {
                var f:Floor = checkHitFloors(pos, spr.size);
                if (f && f.pos.y + 5 >= pos.y + spr.size.y) {
                    floorOn = f;
                    f.land();
                    isJumpReady = false;
                    Ptc.add(footPos, Clr.green, 5, 0.5, 30, PI, PI / 2);
                    landSe.play();
                }
            }
        }
        pos.incrementBy(vel);
        bpos.x = pos.x;
        footPos.x = pos.x + spr.size.x / 2;
        bpos.y = footPos.y = pos.y + spr.size.y;
        if (pos.y < scr.size.y * 0.4) scrollY((scr.size.y * 0.4 - pos.y) * 0.1);
        if (pos.x < scr.size.x * 0.4) scrollX((scr.size.x * 0.4 - pos.x) * 0.1);
        if (pos.x > scr.size.x * 0.6) scrollX((scr.size.x * 0.6 - pos.x) * 0.1);
        spr.draw(pos, anim);
        if (pos.y > scr.size.y) endGame();
    }
}
var floors:Vector.<Floor>;
class Floor {
    public var spr:Spr = new Spr([
    [Clr.cyan.i],[
    "1111111",
    "1     1",
    "1     1",
    "1     1",
    "1     1",
    "1     1",
    "1111111",
    ], 0]);
    public var arrowSpr:Spr = new Spr([
    [Clr.yellow.i],[
    "  1  ",
    "   1 ",
    "11111",
    "   1 ",
    "  1  ",
    ], Spr.XYSWAP]);
    public var beltSpr:Spr = new Spr([
    [Clr.magenta.i],[
    " 11 ",
    "1  1",
    "1  1",
    " 11 ",
    ], 0]);
    public var pos:Vct = new Vct;
    public var width:int, pwidth:int;
    public var mirrorFloor:Floor;
    public var arrow:int = -1, isArrowStart:Boolean;
    public var arrowVel:Vct = new Vct;
    public var beltVel:Vct = new Vct;
    public var beltTicks:Number = 0;
    private static var arrowWays:Array = [1, 0, 0, 1, -1, 0, 0, -1];
    public function setRandom(y:Number):void {
        width = rnd.i(4, 2);
        pwidth = width * spr.size.x;
        pos.x = int(rnd.sx()) + (scrollXDist % 1);
        pos.y = -spr.size.y + y;
        if (rnd.n() < rank * 0.1) {
            arrow = rnd.i(4);
            if (arrow == 3) arrow = 1;
        }
        if (rnd.n() < rank * 0.1) beltVel.x = rnd.n(rank * 0.2, 0.5) * rnd.pm();
    }
    public function setMirror(f:Floor):void {
        width = f.width;
        pwidth = f.pwidth;
        pos.xy = f.pos;
        pos.x += scr.size.x;
        arrow = f.arrow;
        beltVel.xy = f.beltVel;
        mirrorFloor = f;
        f.mirrorFloor = this;
    }
    private var bp:Vct = new Vct;
    public function update():Boolean {
        if (isArrowStart) pos.incrementBy(arrowVel);
        if (pos.x < -pwidth) pos.x += scr.size.x * 2;
        else if (pos.x > scr.size.x + pwidth) pos.x -= scr.size.x * 2;
        if (beltVel.x != 0) {
            var d:Number = beltTicks;
            for (var i:int = 0; i < width * 2 + 2; i++) {
                calcEdgePos(d);
                bp.x = epos.x - 2;
                bp.y = epos.y - 2;
                beltSpr.draw(bp);
                if (beltVel.x > 0) d++;
                else d--;
            }
            beltTicks += beltVel.x * 0.1;
        }
        bp.xy = pos;
        for (i = 0; i < width; i++) {
            spr.draw(bp);
            if (arrow >= 0) {
                bp.x++; bp.y++;
                arrowSpr.draw(bp, arrow);
                bp.x--; bp.y--;
            }
            bp.x += spr.size.x;
        }
        return pos.y <= scr.size.y + spr.size.y * 2;
    }
    private var epos:Vct = new Vct;
    private function calcEdgePos(d:Number):void {
        d %= width * 2 + 2;
        if (d < 0) d = width * 2 + 2 + d;
        if (d < width) {
            epos.x = pos.x + d * spr.size.x;
            epos.y = pos.y;
        } else if (d < width + 1) {
            d -= width;
            epos.x = pos.x + pwidth;
            epos.y = pos.y + d * spr.size.y;
        } else if (d < width * 2 + 1) {
            d -= width + 1;
            epos.x = pos.x + pwidth - d * spr.size.x;
            epos.y = pos.y + spr.size.y;
        } else {
            d -= width * 2 + 1;
            epos.x = pos.x;
            epos.y = pos.y + (1 - d) * spr.size.y;
        }
    }
    public function land():void {
        if (arrow >= 0) {
            isArrowStart = mirrorFloor.isArrowStart = true;
            arrowVel.x = arrowWays[arrow * 2];
            arrowVel.y = arrowWays[arrow * 2 + 1];
            mirrorFloor.arrowVel.xy = arrowVel;
        }
    }
    public function addScore():void {
        score++;
        if (arrow >= 0) score++;
        if (arrow == 1) score += 2;
        if (beltVel.x != 0) score++;
    }
    public function checkHit(p:Vct, size:Vct):Boolean {
        return (p.x + size.x - 1 >= pos.x && p.x <= pos.x + width * spr.size.x - 1 &&
        p.y + size.y - 1 >= pos.y && p.y <= pos.y + spr.size.y - 1);
    }
}
function checkHitFloors(p:Vct, size:Vct):Floor {
    var rf:Floor;
    for each (var f:Floor in floors) {
        if (f.checkHit(p, size)) {
            if (!rf || rf.pos.y < f.pos.y) rf = f
        }
    }
    return rf;
}
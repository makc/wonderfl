package {
    import flash.display.Sprite;
    [SWF(width="465", height="465", backgroundColor="0", frameRate="60")]
    public class Main extends Sprite {
        public function Main() { initializeFirst(this); }
    }
}
import flash.display.*;
import flash.geom.*;
import flash.filters.*;
import flash.events.*;
import flash.text.*;
import flash.utils.getTimer;
import org.si.sion.*;
var main:Main;
var bd:BitmapData;
var blurBd:BitmapData;
var baseSprite:Sprite = new Sprite;
var backgroundColor:uint = 0;
function initializeFirst(main:Main):void {
    this.main = main;
    screen = new Screen;
    bd = new BitmapData(screen.size.x, screen.size.y, true, 0);
    blurBd = new BitmapData(screen.size.x, screen.size.y, false, 0);
    baseSprite.addChild(new Bitmap(blurBd));
    main.addChild(baseSprite);
    mouse = new Mouse;
    key = new Key;
    letter = new Letter;
    initialize();
    if (DEBUG) beginGame();
    else setScoreRecordViewer();
    main.addEventListener(Event.ACTIVATE, onActivated);
    main.addEventListener(Event.DEACTIVATE, onDectivated);
    main.addEventListener(Event.ENTER_FRAME, updateFrame);
}
var fadeFilter:ColorMatrixFilter = new ColorMatrixFilter([
    1, 0, 0, 0, 0,  0, 1, 0, 0, 0,  0, 0, 1, 0, 0,  0, 0, 0, 0.8, 0]);
var blurFilter10:BlurFilter = new BlurFilter(10, 10);
var blurFilter20:BlurFilter = new BlurFilter(20, 20);
var zeroPoint:Point = new Point;
function updateFrame(event:Event):void {
    bd.lock();
    bd.fillRect(bd.rect, backgroundColor);
    updateGame();
    bd.unlock();
    blurBd.lock();
    blurBd.applyFilter(blurBd, blurBd.rect, zeroPoint, fadeFilter);
    blurBd.copyPixels(bd, bd.rect, zeroPoint, null, null, true);
    blurBd.applyFilter(blurBd, blurBd.rect, zeroPoint, blurFilter20);
    blurBd.copyPixels(bd, bd.rect, zeroPoint, null, null, true);
    blurBd.applyFilter(blurBd, blurBd.rect, zeroPoint, blurFilter10);
    blurBd.copyPixels(bd, bd.rect, zeroPoint, null, null, true);
    blurBd.unlock();    
}
// ---- Math utils. ----
var sin:Function = Math.sin, cos:Function = Math.cos, atan2:Function = Math.atan2; 
var sqrt:Function = Math.sqrt, abs:Function = Math.abs;
var PI:Number = Math.PI, PI2:Number = PI * 2;
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
function aimAngle(angle:Number, targetAngle:Number, angleVel:Number):Number {
    var oa:Number = normalizeAngle(targetAngle - angle);
    var r:Number;
    if (oa > angleVel) r = angle + angleVel;
    else if (oa < -angleVel) r = angle - angleVel;
    else r = targetAngle;
    return normalizeAngle(r);
}
class Xy extends Vector3D {
    public function Xy(x:Number = 0, y:Number = 0) {
        super(x, y);
    }
    public function distance(pos:Xy):Number {
        return getLength(pos.x - x, pos.y - y);
    }
    public function angle(pos:Xy):Number {
        return atan2(pos.x - x, pos.y - y);
    }
    public function addAngle(angle:Number, speed:Number):void {
        x += sin(angle) * speed;
        y += cos(angle) * speed;
    }
    public function rotate(angle:Number):void {
        var px:Number = x;
        x = -x * cos(angle) + y * sin(angle);
        y = px * sin(angle) + y * cos(angle);
    }
    public function set xy(v:Xy):void {
        x = v.x; y = v.y;
    }
    public function set s(v:Number):void {
        x = y = v;
    }
    public function get way():Number {
        return atan2(x, y);
    }
}
var random:Random = new Random;
class Random {
    private var x:int, y:int, z:int, w:int;
    function Random(v:int = int.MIN_VALUE):void {
        var sv:int;
        if (v == int.MIN_VALUE) sv = getTimer();
        else sv = v;
        x = sv = 1812433253 * (sv ^ (sv >> 30));
        y = sv = 1812433253 * (sv ^ (sv >> 30)) + 1;
        z = sv = 1812433253 * (sv ^ (sv >> 30)) + 2;
        w = sv = 1812433253 * (sv ^ (sv >> 30)) + 3;
    }
    public function n(v:Number = 1, s:Number = 0):Number {
        return value * v + s;
    }
    public function i(v:int, s:int = 0):int {
        return n(v, s);
    }
    public function sx(v:Number = 1, s:Number = 0):Number {
        return n(v, s) * screen.size.x;
    }
    public function sy(v:Number = 1, s:Number = 0):Number {
        return n(v, s) * screen.size.y;
    }
    public function pm():int {
        return i(2) * 2 - 1;
    }
    public function pmn(v:Number = 1):Number {
        return random.n(v) * pm();
    }
    private function get value():Number {
        var t:int = x ^ (x << 11);
        x = y; y = z; z = w;
        w = (w ^ (w >> 19)) ^ (t ^ (t >> 8));
        return Number(w) / int.MAX_VALUE;
    }    
}
class Actor {
    public var pos:Xy = new Xy;
    public var vel:Xy = new Xy;
    public var size:Xy = new Xy;
    public var angle:Number = 0, speed:Number = 0;
    public static function updateAll(s:*):void {
        for (var i:int = 0; i < s.length; i++) if (!s[i].update()) s.splice(i--, 1);
    }
    public static function checkHit(ca:*, s:*, callHit:Boolean = false):Boolean {
        var hf:Boolean = false;
        for each (var a:* in s) {
            if (ca == a) continue;
            if (abs(ca.pos.x - a.pos.x) < (ca.size.x + a.size.x) / 2 &&
            abs(ca.pos.y - a.pos.y) < (ca.size.y + a.size.y) / 2) {
                if (callHit) a.hit(ca);
                hf = true;
            }
        }
        return hf;
    }
    public static const HIT_X:int = 1;
    public static const HIT_Y:int = 2;
    private static var pPos:Xy = new Xy;
    public static function checkHitVel(ca:*, s:*):int {
        var r:int;
        pPos.xy = ca.pos;
        ca.pos.x += ca.vel.x;
        if (checkHit(ca, s)) r |= HIT_X;
        ca.pos.x = pPos.x;
        ca.pos.y += ca.vel.y;
        if (checkHit(ca, s)) r |= HIT_Y;
        ca.pos.y = pPos.y;
        return r;
    }
}
// ---- UI utils. ----
var mouse:Mouse;
class Mouse {
    public var pos:Xy = new Xy;
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
    private var stickXy:Xy = new Xy;
    public function get stick():Xy {
        stickXy.s = 0;
        if (isWPressed) stickXy.y -= 1;
        if (isAPressed) stickXy.x -= 1;
        if (isSPressed) stickXy.y += 1;
        if (isDPressed) stickXy.x += 1;
        if (stickXy.x != 0 && stickXy.y != 0) stickXy.scaleBy(0.7);
        return stickXy;
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
var screen:Screen;
class Screen {
    public var size:Xy;
    public var center:Xy;
    function Screen() {
        size = new Xy(main.stage.stageWidth, main.stage.stageHeight);
        center = new Xy(size.x / 2, size.y / 2);
    }
    public function isIn(p:Xy, spacing:Number = 0):Boolean {
        return (p.x >= -spacing && p.x <= size.x + spacing && 
            p.y >= -spacing && p.y <= size.y + spacing);
    }
}
// ---- Graphics and sound utils. ----
var fRect:Rectangle = new Rectangle;
function fillRect(x:int, y:int, width:int, height:int, color:uint):void {
    fRect.x = x - int(width / 2);
    fRect.y = y - int(height / 2);
    fRect.width = width;
    fRect.height = height;
    bd.fillRect(fRect, color);
}
class Color {
    private static const LEVEL:int = 5;
    private static const LEVEL_VALUE:int = 50;
    private static const MAX_VALUE:int = LEVEL * LEVEL_VALUE;
    public static var transparent:Color = new Color(-1);
    public static var black:Color = new Color(0, 0, 0);
    public static var red:Color = new Color(MAX_VALUE, 0, 0);
    public static var green:Color = new Color(0, MAX_VALUE, 0);
    public static var blue:Color = new Color(0, 0, MAX_VALUE);
    public static var yellow:Color = new Color(MAX_VALUE, MAX_VALUE, 0);
    public static var magenta:Color = new Color(MAX_VALUE, 0, MAX_VALUE);
    public static var cyan:Color = new Color(0, MAX_VALUE, MAX_VALUE);
    public static var white:Color = new Color(MAX_VALUE, MAX_VALUE, MAX_VALUE);
    public var r:int, g:int, b:int;
    public function Color(r:int = 0, g:int = 0, b:int = 0) {
        this.r = r; this.g = g; this.b = b;
    }
    public function get i():uint {
        return 0xff000000 + r * 0x10000 + g * 0x100 + b;
    }
    public function set rgb(c:Color):void {
        r = c.r; g = c.g; b = c.b;
    }
    private static var blinkColor:Color = new Color;
    public function get blink():Color {
        changeValueColor(
            blinkColor, random.i(128, -64), random.i(128, -64), random.i(128, -64));
        return blinkColor;
    }
    public function get br():Color {
        return changeValue(LEVEL_VALUE, LEVEL_VALUE, LEVEL_VALUE);
    }
    public function get dr():Color {
        return changeValue(-LEVEL_VALUE, -LEVEL_VALUE, -LEVEL_VALUE);
    }
    public function get rz():Color {
        return changeValue(LEVEL_VALUE, -LEVEL_VALUE, -LEVEL_VALUE);
    }
    public function get gz():Color {
        return changeValue(-LEVEL_VALUE, LEVEL_VALUE, -LEVEL_VALUE);
    }
    public function get bz():Color {
        return changeValue(-LEVEL_VALUE, -LEVEL_VALUE, LEVEL_VALUE);
    }
    private function changeValue(rv:int, gv:int, bv:int):Color {
        var changedColor:Color = new Color;
        changeValueColor(changedColor, rv, gv, bv);
        return changedColor;
    }
    private function changeValueColor(color:Color, rv:int, gv:int, bv:int):void {
        color.rgb = this;
        color.r += rv; color.g += gv; color.b += bv;
        color.normalize();
    }
    private function normalize():void {
        r = clamp(r, 0, MAX_VALUE);
        g = clamp(g, 0, MAX_VALUE);
        b = clamp(b, 0, MAX_VALUE);
    }
}
class DotShape {
    private static var rPos:Xy = new Xy;
    private static var rect:Rectangle = new Rectangle;
    private var dots:Vector.<OffsetColor> = new Vector.<OffsetColor>;
    private var color:Color = Color.transparent;
    private var colorSpot:Color = Color.transparent;
    private var spotThreshold:Number = 0.3;
    private var xAngleVel:Number = 0;
    private var yAngleVel:Number = 0;
    private var xyAngleVel:Number = 0;
    private var offset:Xy = new Xy;
    public function c(c:Color, cs:Color = null):DotShape {
        color = c;
        if (cs) colorSpot = cs;
        return this;
    }
    public function st(v:Number):DotShape {
        spotThreshold = v;
        return this;
    }
    public function sa(x:Number = 0, y:Number = 0, xy:Number = 0):DotShape {
        xAngleVel = x;
        yAngleVel = y;
        xyAngleVel = xy;
        return this;
    }
    public function o(x:Number = 0, y:Number = 0):DotShape {
        offset.x = x; offset.y = y;
        return this;
    }
    public function fr(width:int, height:int, isDrawingEdge:Boolean = false):DotShape {
        var ox:int = -width / 2, oy:int = -height / 2;
        for (var y:int = 0; y < height; y++) {
            for (var x:int = 0; x < width; x++) {
                if (!isDrawingEdge ||
                    x == 0 || x == width - 1 || y == 0 || y == height - 1) fd(x + ox, y + oy);
            }
        }
        return this;
    }
    public function fc(radius:Number, isDrawingEdge:Boolean = false):DotShape {
        var d:int = 3 - radius * 2;
        var y:int = radius;
        for (var x:int = 0; x <= y; x++) {
            if (isDrawingEdge) {
                setCircleDotsEdge(x, y);
                setCircleDotsEdge(y, x);
            } else {
                setCircleDots(x, y);
                setCircleDots(y, x);
            }
            if (d < 0) {
                d += 6 + x * 4;
            } else {
                d += 10 + x * 4 - y * 4;
                y--;
            }
        }
        return this;
    }
    public function fd(x:Number, y:Number):DotShape {
        var ca:Number =
            Math.cos(x * xAngleVel) * Math.cos(y * yAngleVel) * Math.cos((x + y) * xyAngleVel);
        var c:Color;
        if (Math.abs(ca) < spotThreshold) c = colorSpot;
        else c = color;
        if (c.r < 0) return this;
        var d:OffsetColor = new OffsetColor;
        d.offset.x = x + offset.x;
        d.offset.y = y + offset.y;
        d.color = c.i;
        dots.push(d);
        return this;
    }
    private function setCircleDots(x:int, y:int):void {
        setXLine(-x, x, y);
        setXLine(-x, x, -y);
    }
    private function setXLine(xb:int, xe:int, y:int):void {
        for (var x:int = xb; x <= xe; x++) fd(x, y);
    }
    private function setCircleDotsEdge(x:int, y:int):void {
        fd(-x, y); fd(x, y);
        fd(-x, -y); fd(x, -y);
    }
    public function draw(pos:Xy, angle:Number = 0, scale:Number = 3, rectScale:int = -1):void {
        if (rectScale > 0) rect.width = rect.height = rectScale;
        else rect.width = rect.height = scale;
        var o:int = scale / 2;
        for each (var d:OffsetColor in dots) {
            rPos.xy = d.offset;
            rPos.scaleBy(scale);
            if (angle != 0) rPos.rotate(angle);
            rect.x = int(pos.x + rPos.x) - o;
            rect.y = int(pos.y + rPos.y) - o;
            bd.fillRect(rect, d.color);
        }
    }
}
class OffsetColor {
    public var offset:Xy = new Xy;
    public var color:uint;
}
var letter:Letter;
class Letter {
    private var shapes:Vector.<DotShape> = new Vector.<DotShape>;
    private var charToIndex:Vector.<int> = new Vector.<int>;
    function Letter() {
        const COUNT:int = 53;
        var patterns:Array = [
        0x4644AAA4, 0x6F2496E4, 0xF5646949, 0x167871F4, 0x2489F697, 0xE9669696, 0x79F99668,
        0x91967979, 0x1F799976, 0x1171FF17, 0xF99ED196, 0xEE444E99, 0x53592544, 0xF9F11119,
        0x9DDB9999, 0x79769996, 0x7ED99611, 0x861E9979, 0x994444E7, 0x46699699, 0x6996FD99,
        0xF4469999, 0x2226F248, 0x44644466, 0xF0044E, 0x12448, 0x640444F0, 0x4049,
        0x44040404, 0x4444, 0x5E40000A, 0x424F4244, 0x2F244E54, 0x4];
        var d:int, lp:int, pIndex:int;
        for (var i:int = 0; i < COUNT; i++) {
            var shape:DotShape = new DotShape;
            shape.c(Color.white);
            for (var j:int = 0; j < 5; j++) {
                for (var k:int = 0; k < 4; k++) {
                    if (--d <= 0) {
                        lp = patterns[pIndex++];
                        d = 32;
                    }
                    if (lp & 1 > 0) shape.fd(k, j);
                    lp >>= 1;
                }
            }
            shapes.push(shape);
        }
        var charCodes:Array = [
        91, 93, 43, 45, 47, 95, 33, 63, 46, 58, 124, 39, 34, 117, 114, 100, 108];
        for (var c:int = 0; c < 128; c++) {
            var li:int = -1;
            if (c >= 48 && c < 58) {
                li = c - 48;
            } else if (c >= 65 && c <= 90) {
                li = c - 65 + 10;
            } else {
                var lic:int = 36;
                for each (var cc:int in charCodes) {
                    if (cc == c) {
                        li = lic;
                        break;
                    }
                    lic++;
                }
            }
            charToIndex.push(li);
        }
    }
    private var tPos:Xy = new Xy;
    public function draw(text:String, x:Number, y:Number, isFromRight:Boolean = false):void {
        tPos.x = x;
        if (isFromRight) tPos.x -= text.length * 10;
        else tPos.x -= text.length * 10 / 2;
        tPos.y = y;
        for (var i:int = 0; i < text.length; i++) {
            var c:int = text.charCodeAt(i);
            var li:int = charToIndex[c];
            if (li >= 0) shapes[li].draw(tPos, 0, 2);
            tPos.x += 10;
        }
    }
}
class Message extends Actor {
    public static var s:Vector.<Message> = new Vector.<Message>;
    private static var shownMessages:Vector.<String> = new Vector.<String>;
    public static function addOnce(
    text:String, pos:Xy, vx:Number = 0, vy:Number = 0, ticks:int = 240):Message {
        if (shownMessages.indexOf(text) >= 0) return null;
        shownMessages.push(text);
        return add(text, pos, vx, vy, ticks);
    }
    public static function add(
    text:String, pos:Xy, vx:Number = 0, vy:Number = 0, ticks:int = 60):Message {
        var m:Message = new Message;
        m.text = text;
        m.pos.xy = pos;
        m.vel.x = vx / ticks; m.vel.y = vy / ticks;
        m.ticks = ticks;
        s.push(m);
        return m;
    }
    public var text:String, ticks:int;
    public function update():Boolean {
        pos.incrementBy(vel);
        letter.draw(text, pos.x, pos.y);
        return --ticks > 0;
    }
}
class Particle extends Actor {
    public static var s:Vector.<Particle> = new Vector.<Particle>;
    public static function add(
    pos:Xy, color:Color, size:Number, count:Number, speed:Number, ticks:Number = 60,
    angle:Number = 0, angleWidth:Number = Math.PI * 2):void {
        for (var i:int = 0; i < count; i++) {
            var pt:Particle = new Particle;
            pt.color = color;
            pt.targetSize = size;
            pt.pos.xy = pos;
            pt.vel.addAngle(
                angle + random.n(angleWidth / 2) * random.pm(), speed * random.n(1, 0.5));
            pt.ticks = ticks * random.n(1, 0.5);
            s.push(pt);
        }
    }
    private var ticks:int;
    private var color:Color;
    private var scale:Number = 1;
    private var targetSize:Number;
    private var isExpand:Boolean = true;
    public function update():Boolean {
        pos.incrementBy(vel);
        vel.scaleBy(0.98);
        if (isExpand) {
            scale *= 1.5;
            if (scale > targetSize) isExpand = false;
        } else {
            scale *= 0.95;
        }
        fillRect(pos.x, pos.y, scale, scale, color.blink.i);
        return --ticks > 0;
    }
}
class Se {
    public static const MAJOR:int = 0;
    public static const MINOR:int = 1;
    public static const NOISE:int = 2;
    public static const NOISE_SCALE:int = 3;
    private static var tones:Array = [
        ["c", "c+", "d", "d+", "e", "f", "f+", "g", "g+", "a", "a+", "b"],
        ["c", "d", "e", "g", "a"],
        ["c", "d-", "e-", "g-", "a-"]];
    public static var s:Vector.<Se> = new Vector.<Se>;
    private static var driver:SiONDriver = new SiONDriver;
    private static var isStarting:Boolean;
    private var data:SiONData;
    private var isPlaying:Boolean;
    private var mml:String;
    private var type:int;
    private var tone:Number = 0;
    public function t(v:int):Se {
        type = v;
        if (!mml) mml = "";
        else mml += ";";
        var voices:Array = [1, 1, 9, 10];
        mml += "%1@" + voices[v] + "l64";
        return this;
    }
    public function m(step:Number, time:int, start:Number = -1):Se {
        if (start >= 0) tone = start;
        for (var i:int = 0; i < time; i++) {
            tone = clamp(tone, 0, 1);
            switch (type) {
                case MAJOR:
                case MINOR:
                    var ti:int = tone * 40;
                    var o:int = ti / 5 + 2;
                    mml += "o" + o + tones[type + 1][ti % 5];
                    break;
                case NOISE:
                case NOISE_SCALE:
                    ti = tone * 15;
                    if (ti < 4) mml += "o5" + tones[0][3 - ti];
                    else mml += "o4" + tones[0][15 - ti];
                    break;
            }
            tone += step / time;
        }
        return this;
    }
    public function r(v:int = 1):Se {
        for (var i:int = 0; i < v; i++) mml += "r";
        return this;
    }
    public function v(v:int = 16):Se {
        mml += "v" + v;
        return this;
    }
    public function c():Se {
        isStarting = false;
        data = driver.compile(mml);
        driver.volume = 0;
        driver.play();
        s.push(this);
        return this;
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
// ---- Game state controller. ----
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
    random = new Random;
    Particle.s = new Vector.<Particle>;
    initialize();
}
function endGame():Boolean {
    if (!isInGame) return false;
    isInGame = false;
    wasClicked = wasReleased = false;
    ticks = 0;
    recordScore(score);
    setScoreRecordViewer();
    titleTicks = 10;
    return true;
}
function updateGame():void {
    Actor.updateAll(Particle.s);
    if (!isPaused) update();
    for each (var s:Se in Se.s) s.update();
    letter.draw(String(score), screen.size.x, 2, true);
    ticks++;
    if (!isInGame) {
        letter.draw(TITLE, screen.size.x * 0.8, screen.center.y - 20);
        letter.draw("CLICK", screen.size.x * 0.8, screen.center.y + 8);
        letter.draw("TO", screen.size.x * 0.8, screen.center.y + 20);
        letter.draw("START", screen.size.x * 0.8, screen.center.y + 32);
        if (mouse.isPressing) {
            if (wasReleased) wasClicked = true;
        } else {
            if (wasClicked) beginGame();
            if (--titleTicks <= 0) wasReleased = true;
        }
    }
    if (isPaused) {
        letter.draw("PAUSED", screen.center.x, screen.center.y - 8);
        letter.draw("CLICK TO RESUME", screen.center.x, screen.center.y + 8);
    }
    Actor.updateAll(Message.s);
}
function onActivated(e:Event):void {
    isPaused = false;
}
function onDectivated(e:Event):void {
    if (isInGame) isPaused = true;
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
function recordScore(score:int):void {
    scoreForm = new BasicScoreForm(main, 5, 5, score);
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
// ---- Game main logic. ----
const TITLE:String = "NO BULLET NO DEATH"
const DEBUG:Boolean = false;
var stage:int;
var stageTicks:int;
var stageSec:int;
var enemyAppTicks:int, enemyAppCount:int;
var countSes:Vector.<Se>;
var starAddTicks:int;
function initialize():void {
    if (!countSes) {
        countSes = new Vector.<Se>;
        for (var i:int = 0; i < 10 ; i++) {
            var cse:Se = new Se().t(Se.MAJOR);
            if (i < 3) cse.m(0, 1, 0.8).r(1).m(0, 1, 0.8).c();
            else cse.m(0, 1, 0.5).r(1).m(0, 1, 0.5).c();
            countSes.push(cse);
        }
    }
    Star.initialize();
    player = new Player;
    Enemy.s = new Vector.<Enemy>;
    Bonus.s = new Vector.<Bonus>;
    Star.s = new Vector.<Star>;
    stage = -1;
    stageTicks = 999;
    if (isInGame) gotoNextStage();
}
function gotoNextStage():void {
    for each (var e:Enemy in Enemy.s) e.hit(null, true);
    stage++;
    enemyAppTicks = 0;
    enemyAppCount = 0;
    stageTicks = 0;
    stageSec = 10;
    Enemy.setType(stage);
}
function update():void {
    var sc:int;
    if (stageTicks < 60) {
        if (stageTicks == 1) Message.add("STAGE " + (stage + 1), screen.center);
        if (stageTicks == 59) {
            Message.addOnce("[u][d][r][l]: MOVE", new Xy(100, 100));
            Message.addOnce("[Z]: SHOT", new Xy(100, 120));
        }
        sc = 10000;
    } else if (stageTicks < 660) {
        if (--enemyAppTicks <= 0) Enemy.add();
        sc = 10000 - (stageTicks - 60) * 16;
        var s:int = sc / 1000;
        if (s < stageSec) {
            stageSec = s;
            countSes[s].play();
        }
    } else if (stageTicks < 780) {
        sc = 0;
        if (stage < 6) gotoNextStage();
        else if (stageTicks == 660) Message.add("GAME OVER", screen.center, 0, 0, 120);
    } else {
        endGame();
    }
    Actor.updateAll(Star.s);
    if (--starAddTicks <= 0) {
        Star.s.push(new Star);
        starAddTicks = 5;
    }
    if (isInGame) {
        var mss:String = ("000" + sc % 1000);
        mss = mss.substr(mss.length - 3, 3);
        letter.draw(int(sc / 1000) + "\'" + mss, 70, 2, true);
        player.update();
    }
    stageTicks++;
    Actor.updateAll(Bonus.s);
    Actor.updateAll(Enemy.s);
}
var player:Player;
class Player extends Actor {
    private static var shape:DotShape = new DotShape().
    c(Color.green, Color.green.dr).sa(1, 2, 3).fr(3, 12, true).
    c(Color.green).o(5, 4).fr(7, 5, true).c(Color.green.dr.dr).o( -5, 4).fr(7, 5, true);
    private static var shotSe:Se = new Se().t(Se.NOISE).m( -0.2, 2, 0.3).m(0.2, 3, 0.5).c();
    private var shots:Vector.<Shot> = new Vector.<Shot>;
    private var fireTicks:int;
    private var isFirePressed:Boolean;
    function Player() {
        pos.x = screen.center.x;
        pos.y = screen.size.y * 0.7;
        size.s = 42;
    }
    public function update():void {
        vel.xy = key.stick;
        vel.scaleBy(4);
        pos.incrementBy(vel);
        pos.x = clamp(pos.x, 0, screen.size.x);
        pos.y = clamp(pos.y, 0, screen.size.y);
        shape.draw(pos);
        Actor.checkHit(this, Bonus.s, true);
        Actor.checkHit(this, Enemy.s, true);
        fireTicks--;
        if (key.isButtonPressed) {
            if (!isFirePressed && fireTicks <= 0) {
                shotSe.play();
                shots.push(new Shot(pos));
                fireTicks = 3;
                isFirePressed = true;
            }
        } else {
            isFirePressed = false;
        }
        Actor.updateAll(shots);
    }
}
class Shot extends Actor {
    private static var shape:DotShape = new DotShape().
    c(Color.green.rz).o( -7).fr(2, 10).o(7).fr(2, 10);
    function Shot(p:Xy) {
        pos.xy = p;
        vel.y = -13;
        size.s = 42;
    }
    public function update():Boolean {
        pos.incrementBy(vel);
        shape.draw(pos);
        if (Actor.checkHit(this, Enemy.s, true)) return false;
        return screen.isIn(pos, 10);
    }
}
class Enemy extends Actor {
    public static var s:Vector.<Enemy>;
    private static var destroySe:Se = new Se().t(Se.NOISE).m(-0.1, 2, 0.2).m(0.3, 10, 0.5).c();
    private static var destroyBonusSe:Se =
    new Se().t(Se.NOISE).m( -0.1, 2, 0.2).m(0.3, 10, 0.5).c().
    t(Se.NOISE_SCALE).m( -0.3, 10, 0.5).c();
    private static var eRandom:Random;
    private static var type:int;
    private static var edgeShape:DotShape;
    private static var shape:DotShape = new DotShape().
    c(Color.magenta, Color.red).sa(1, 1, 1).fc(4);
    public var isExist:Boolean = true;
    public var angleAim:Number = -9999;
    public var aimVel:Number = 0;
    public var phase:int;
    public var fireTicks:int, fireCount:int;
    public var xTicks:int;
    public var xCenter:Number;
    private var type:int;
    private var isInScreen:Boolean;
    private var message:Message;
    public static function setType(t:int):void {
        type = t;
        edgeShape = new DotShape().
        c(Color.red, Color.magenta).sa(0, 0, 1).fc(5, true).sa(1, 1, 0);
        switch (type) {
            case 0:
                eRandom = new Random(0);
                edgeShape.o(0, 5).fr(3, 6, true);
                break;
            case 1:
                edgeShape.o(5, 0).fr(6, 3, true).o(-5, 0).fr(6, 3, true);
                break;
            case 2:
                edgeShape.o(0, 5).fc(3, true);
                break;
            case 3:
                edgeShape.o(0, 5).fr(6, 6, true);
                break;
            case 4:
                edgeShape.o(0, 5).fc(4, true);
                break;
            case 5:
                edgeShape.o(-5, 0).fr(8, 2, true);
                break;
            case 6:
                edgeShape.o(-2, -5).fc(5, true);
                edgeShape.o(2, -5).fc(5, true);
                break;
        }
    }
    public static function add():void {
        switch (type) {
            case 0:
                var xc:Number = eRandom.sx(0.4, 0.3);
                for (i = 0; i < 5; i++) {
                    e = new Enemy(type);
                    e.xCenter = xc;
                    e.xTicks = i * 7;
                    e.pos.y = -15 - i * 7;
                    s.push(e);
                    e.fireTicks = i;
                }
                enemyAppTicks = 300;
                break;
            case 1:
                for (var i:int = 0; i < 3; i++) {
                    var e:Enemy = new Enemy(type);
                    e.pos.y += i * 20;
                    s.push(e);
                }
                enemyAppTicks = 200;
                break;
            case 2:
                e = new Enemy(type);
                if (eRandom.pm() < 0) {
                    e.pos.x = -15;
                    e.angle = e.angleAim = PI / 2;
                } else {
                    e.pos.x = screen.size.x + 15;
                    e.angle = e.angleAim = -PI / 2;
                }
                s.push(e);
                enemyAppTicks = 50;
                break;
            case 3:
                e = new Enemy(type);
                if (enemyAppCount % 2 == 0) {
                    e.pos.x = eRandom.sx(0.3, 0.1);
                    e.angleAim = PI;
                } else {
                    e.pos.x = eRandom.sx(0.3, 0.6);
                    e.angleAim = -PI;
                }
                s.push(e);
                enemyAppTicks = 100;
                break;
            case 4:
            case 5:
                s.push(new Enemy(type));
                enemyAppTicks = 50;
                break;
            case 6:
                s.push(new Enemy(type));
                enemyAppTicks = 60;
                break;
        }
        enemyAppCount++;
    }
    function Enemy(type:int) {
        this.type = type;
        pos.x = eRandom.sx(1);
        pos.y = -15;
        size.s = 30;
        switch (type) {
            case 1:
                pos.y = screen.size.y + 15;
                angle = angleAim = PI;
                speed = 1;
                break;
            case 2:
                pos.y = eRandom.sy(0.3, 0.1);
                speed = 3;
                break;
            case 3:
                aimVel = 0.01;
                speed = 1.5;
                break;
            case 4:
                aimVel = 0.01;
                speed = 4;
                break;
            case 5:
                pos.x = eRandom.sx(0.2, 0.2);
                vel.addAngle(-PI * 0.4, 4);
                break;
            case 6:
                pos.x = eRandom.sx(0.4, 0.3);
                angle = angleAim = 0;
                aimVel = 0.01;
                speed = 3;
                break;
        }
        message = Message.addOnce("SHOOT ME!", pos, 0, 0, 120);
    }
    public function update():Boolean {
        if (speed != 0) {
            pos.addAngle(angle, speed);
            var aa:Number = angleAim;
            if (aa < -999) aa = pos.angle(player.pos);
            angle = aimAngle(angle, aa, aimVel);
        }
        switch (type) {
            case 0:
                pos.x = xCenter + sin(--xTicks * 0.03) * screen.size.x * 0.3;
                pos.y += 1;
                break;
            case 1:
                if (phase == 0) {
                    if (pos.y < screen.center.y) phase = 1;
                } else {
                    speed += 0.1;
                }
                break;
            case 4:
                if (phase == 0) {
                    if (pos.y > screen.center.y) {
                        phase = 1;
                        angleAim = PI + random.pmn(0.5);
                        aimVel = 0.05;
                    }
                    speed *= 0.995;
                } else {
                    if (abs(angle) < PI / 2) speed *= 0.9;
                    else speed += 0.1;
                }
                break;
            case 5:
                vel.x += (player.pos.x - pos.x) * 0.001;
                vel.y += (player.pos.y - pos.y) * 0.001;
                pos.incrementBy(vel);
                angle = vel.way;
                break;
            case 6:
                if (phase == 0) {
                    speed *= 0.9;
                    if (fireCount >= 120) {
                        phase = 1;
                        angleAim = random.n(PI2);
                    }
                } else {
                    speed += 0.1;
                }
                break;
        }
        edgeShape.draw(pos, angle);
        shape.draw(pos, angle, abs(sin(fireTicks * 0.2)) * 3);
        if (message) {
            message.pos.x = pos.x;
            message.pos.y = pos.y - 20;
        }
        if (--fireTicks <= 0) {
            switch (type) {
                case 0:
                    fire(0);
                    fireTicks = 7;
                    break;
                case 1:
                    fire(PI / 2);
                    fire(PI / 2 * 3);
                    fireTicks = 5;
                    break;
                case 2:
                    var ft:int = fireCount % 7;
                    aa = pos.angle(player.pos);
                    fire(aa + 0.3, 2 + ft);
                    fire(aa - 0.3, 2 + ft);
                    if (ft < 6) fireTicks = 2;
                    else fireTicks = 17;
                    break;
                case 3:
                    aa = pos.angle(player.pos);
                    var ao:Number = 0;
                    fire(aa, 2);
                    for (var i:int = 0; i < 1; i++) {
                        ao += 0.1;
                        fire(aa + ao, 2); fire(aa - ao, 2);
                    }
                    ao += 0.4;
                    for (i = 0; i < 3; i++) {
                        ao += 0.1;
                        fire(aa + ao, 2); fire(aa - ao, 2);
                    }
                    if (pos.y < screen.size.y * 0.25) fireTicks = 13;
                    else fireTicks = 999;
                    break;
                case 4:
                    fire(pos.angle(player.pos));
                    fireTicks = 7 + cos(pos.y / screen.center.y * PI / 2) * 33;
                    break;
                case 5:
                    fire(angle + PI / 2);
                    fireTicks = 3;
                    break;
                case 6:
                    if (phase == 1) break;
                    if (fireCount < 30) aa = fireCount * 0.03;
                    else if (fireCount < 90) aa = 30 * 0.03 - (fireCount - 30) * 0.03;
                    else aa = -30 * 0.03 + (fireCount - 90) * 0.03;
                    aa -= PI / 10;
                    for (i = -2; i <= 2; i++) {
                        fire(aa, 10);
                        aa += PI / 20;
                    }
                    fireTicks = 3;
                    break;
            }
        }
        if (isInScreen) {
            if (!screen.isIn(pos, 15)) isExist = false;
        } else {
            isInScreen = screen.isIn(pos, 15);
        }
        return isExist;
    }
    private function fire(a:Number, s:Number = 4):void {
        Bonus.s.push(new Bonus(pos, a, s));
        Particle.add(pos, Color.yellow.rz, 10, 3, 7, 15, a, 0.5);
        fireCount++;
    }
    public function hit(a:*, isEndStage:Boolean = false):void {
        isExist = false;
        Particle.add(pos, Color.red.gz.gz, 15, 40, 7);
        if (a is Player) {
            destroySe.play();
            return;
        }
        if (isEndStage) return;
        Particle.add(pos, Color.red.gz, 25, 50, 10);
        var ba:Number = pos.angle(player.pos);
        for (var i:int = 0; i < 20; i++) {
            Bonus.s.push(new Bonus(pos, ba + random.pmn(0.2), 4 * (1 + random.pmn(0.7))));
        }
        destroyBonusSe.play();
    }
}
class Bonus extends Actor {
    public static var s:Vector.<Bonus>;
    private static var shape:DotShape = new DotShape().
    c(Color.yellow.gz, Color.yellow).sa(1, 1, 1).
    o(0, 3).fc(2, true).o(2, -2).fc(2, true).o(-2, -2).fc(2, true);
    private static var getSe:Se = new Se().
    t(Se.MAJOR).v(8).m(-0.3, 2, 0.5).m(0, 3, 0.7).c();
    private var message:Message;
    function Bonus(p:Xy, a:Number, s:Number) {
        pos.xy = p;
        vel.addAngle(a, s);
        size.s = 30;
        message = Message.addOnce("GET ME!", pos, 0, 0, 120);
    }
    public function update():Boolean {
        pos.incrementBy(vel);
        shape.draw(pos, angle += 0.1);
        if (message) {
            message.pos.x = pos.x;
            message.pos.y = pos.y + 20;
        }
        return screen.isIn(pos, 10);
    }
    public function hit(a:Player):void {
        Particle.add(pos, Color.yellow.gz, 15, 5, vel.length, 30, vel.way, 1);
        pos.x = 999;
        score++;
        if (ticks % 5 == 0) getSe.play();
    }
}
class Star extends Actor {
    public static var s:Vector.<Star>;
    private static var shapes:Vector.<DotShape>;
    public static function initialize():void {
        if (shapes) return;
        shapes = new Vector.<DotShape>;
        for (var i:int = 0; i < 10; i++) {
            var c:Color = new Color(random.i(128, 128), random.i(128, 128), random.i(128, 128));
            shapes.push(new DotShape().c(c).fd(0, 0));
        }
    }
    private var shape:DotShape;
    function Star() {
        pos.x = random.sx();
        vel.y = random.n(3, 1);
        shape = shapes[random.i(shapes.length)];
    }
    public function update():Boolean {
        pos.y += vel.y;
        shape.draw(pos);
        return screen.isIn(pos);
    }
}
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
var baseSprite:Sprite;
var backgroundColor:uint = 0;
function initializeFirst(main:Main):void {
    this.main = main;
    screen = new Screen;
    bd = new BitmapData(screen.size.x, screen.size.y, true, 0);
    blurBd = new BitmapData(screen.size.x, screen.size.y, false, 0);
    baseSprite = new Sprite;
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
class Xy extends Vector3D {
    public function Xy(x:Number = 0, y:Number = 0) {
        super(x, y);
    }
    public function clear():void {
        x = y = 0;
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
        stickXy.clear();
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
    public var dots:Vector.<Dot> = new Vector.<Dot>;
    private var color:Color = Color.transparent;
    private var colorSpot:Color = Color.transparent;
    private var spotThreshold:Number = 0.3;
    private var xAngleVel:Number = 0;
    private var yAngleVel:Number = 0;
    private var xyAngleVel:Number = 0;
    private var offset:Xy = new Xy;
    public function c(v:Color):DotShape {
        color = v;
        return this;
    }
    public function cs(v:Color):DotShape {
        colorSpot = v;
        return this;
    }
    public function st(v:Number):DotShape {
        spotThreshold = v;
        return this;
    }
    public function xa(v:Number):DotShape {
        xAngleVel = v;
        return this;
    }
    public function ya(v:Number):DotShape {
        yAngleVel = v;
        return this;
    }
    public function xya(v:Number):DotShape {
        xyAngleVel = v;
        return this;
    }
    public function o(x:Number = 0, y:Number = 0):DotShape {
        offset.x = x; offset.y = y;
        return this;
    }
    public function fr(width:int, height:int):DotShape {
        var ox:int = -width / 2, oy:int = -height / 2;
        for (var y:int = 0; y < height; y++) {
            for (var x:int = 0; x < width; x++) {
                fd(x + ox, y + oy);
            }
        }
        return this;
    }
    public function fc(radius:Number):DotShape {
        var d:int = 3 - radius * 2;
        var y:int = radius;
        for (var x:int = 0; x <= y; x++) {
            setCircleDots(x, y);
            setCircleDots(y, x);
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
        var ca:Number = cos(x * xAngleVel) * cos(y * yAngleVel) * cos((x + y) * xyAngleVel);
        var c:Color;
        if (abs(ca) < spotThreshold) c = colorSpot;
        else c = color;
        if (c.r < 0) return this;
        var d:Dot = new Dot;
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
    public function draw(pos:Xy, scale:int = 2, angle:Number = 0):void {
        rect.width = rect.height = scale;
        var o:int = scale / 2;
        for each (var d:Dot in dots) {
            rPos.xy = d.offset;
            rPos.scaleBy(scale);
            if (angle != 0) rPos.rotate(angle);
            rect.x = int(pos.x + rPos.x) - o;
            rect.y = int(pos.y + rPos.y) - o;
            bd.fillRect(rect, d.color);
        }
    }
}
class Dot {
    public var offset:Xy = new Xy;
    public var color:uint;
    public var bd:BitmapData;
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
            if (li >= 0) shapes[li].draw(tPos);
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
    pos:Xy, color:Color, size:Number, count:Number, speed:Number, ticks:Number = 30,
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
    private var tone:Number;
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
            if (tone < 0) tone = 0;
            var ti:int = tone;
            switch (type) {
                case MAJOR:
                    var o:int = ti / 5;
                    mml += "o" + o + tones[1][ti % 5];
                    break;
                case MINOR:
                    o = ti / 5;
                    mml += "o" + o + tones[2][ti % 5];
                    break;
                case NOISE:
                case NOISE_SCALE:
                    if (tone > 15) tone = 15;
                    if (ti < 4) mml += "o5" + tones[0][3 - ti];
                    else mml += "o4" + tones[0][15 - ti];
                    break;
            }
            tone += step;
        }
        return this;
    }
    public function r(v:int = 1):Se {
        for (var i:int = 0; i < v; i++) mml += "r";
        return this;
    }
    public function e():void {
        isStarting = false;
        data = driver.compile(mml);
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
const TITLE:String = "TANK FIRES BLOCK"
const DEBUG:Boolean = false;
var enemyAppTicks:int;
var largeEnemyAppTicks:int;
var isFirstEnemy:Boolean;
function initialize():void {
    Tank.s = new Vector.<Tank>;
    Tank.s.push(tank = new Tank);
    Shot.s = new Vector.<Shot>;
    Block.s = new Vector.<Block>;
    Enemy.s = new Vector.<Enemy>;
    Bullet.s = new Vector.<Bullet>;
    enemyAppTicks = 0;
    largeEnemyAppTicks = 1000;
    isFirstEnemy = true;
}
function update():void {
    if (--enemyAppTicks <= 0) {
        Enemy.s.push(new Enemy);
        enemyAppTicks = 150;
    }
    if (--largeEnemyAppTicks <= 0) {
        Enemy.s.push(new Enemy(true));
        largeEnemyAppTicks = 1000;
    }
    Actor.updateAll(Shot.s);
    Actor.updateAll(Block.s);
    Actor.updateAll(Enemy.s);
    Actor.updateAll(Bullet.s);
    if (isInGame) {
        tank.update();
        if (ticks == 0) Message.addOnce("[u][r][d][l]: MOVE", new Xy(150, 100));
        if (ticks == 120) Message.addOnce("[X]: FIRE A BLOCK", new Xy(150, 130));
        if (ticks == 240) Message.addOnce("[Z]: FIRE A CANNON", new Xy(150, 160));
    }
}
var tank:Tank;
class Tank extends Actor {
    public static var s:Vector.<Tank>;
    private static var shape:DotShape;
    private static var trackShapeLs:Vector.<DotShape> = new Vector.<DotShape>(3);
    private static var trackShapeRs:Vector.<DotShape> = new Vector.<DotShape>(3);
    private static var moveSe:Se = new Se, fireSe:Se = new Se, 
        blockSe:Se = new Se, destSe:Se = new Se;
    private static const ANGLE_VEL:Number = 0.1;
    private var angle:Number = PI;
    private var trackLTicks:Number = 0, trackRTicks:Number = 0, nextSeTicks:Number = 1;
    private var fireTicks:int;
    function Tank() {
        if (!shape) setShapeSe();
        pos.x = screen.center.x;
        pos.y = screen.size.y * 0.7;
        size = new Xy(33, 33);
    }
    private var sPos:Xy = new Xy, pPos:Xy = new Xy, mPos:Xy = new Xy;
    public function update():void {
        var st:Xy = key.stick;
        if (st.lengthSquared > 0) {
            var sa:Number = st.way;
            var oa:Number = normalizeAngle(sa - angle);
            if (oa > ANGLE_VEL) {
                angle += ANGLE_VEL;
                trackLTicks += 0.1;
                nextSeTicks -= 0.3;
            } else if (oa < -ANGLE_VEL) {
                angle -= ANGLE_VEL;
                trackRTicks += 0.1;
                nextSeTicks -= 0.3;
            } else {
                angle = sa;
                trackLTicks += 0.2;
                trackRTicks += 0.2;
                nextSeTicks -= 0.1;
            }
            if (nextSeTicks <= 0) {
                moveSe.play();
                nextSeTicks = 1;
            }
            angle = normalizeAngle(angle);
            var sp:Number = st.length * 2;
            vel.clear();
            vel.addAngle(angle, sp);
            var hitb:int = Actor.checkHitVel(this, Block.s);
            if ((hitb & Actor.HIT_X) > 0) vel.x = 0;
            if ((hitb & Actor.HIT_Y) > 0) vel.y = 0;
            pos.incrementBy(vel);
            pPos.xy = pos;
            pPos.addAngle(angle + PI * 0.7, 13);
            Particle.add(pPos, Color.yellow.dr.dr.br, 3, 1, sp * 0.3, 15, angle + PI, 0.1);
            pPos.xy = pos;
            pPos.addAngle(angle - PI * 0.7, 13);
            Particle.add(pPos, Color.yellow.dr.dr.br, 3, 1, sp * 0.3, 15, angle + PI, 0.1);
        }
        pos.x = clamp(pos.x, 0, screen.size.x);
        pos.y = clamp(pos.y, 0, screen.size.y);
        sPos.x = pos.x + 7;
        sPos.y = pos.y + 7;
        shape.draw(pos, 2, angle);
        trackShapeLs[int(trackLTicks) % 3].draw(pos, 2, angle);
        trackShapeRs[int(trackRTicks) % 3].draw(pos, 2, angle);
        sPos.xy = pos;
        for (;; ) {
            sPos.addAngle(angle, 30);
            if (!screen.isIn(sPos)) break;
            fillRect(sPos.x, sPos.y, 4, 4, Color.red.br.i);
        }
        if (--fireTicks <= 0 && key.isButtonPressed) {
            mPos.xy = pos;
            mPos.addAngle(angle, 25);
            if (key.isButton1Pressed) {
                var s:Shot = new Shot;
                s.pos.xy = mPos;
                s.angle = angle;
                Shot.s.push(s);
                Particle.add(mPos, Color.red.gz, 20, 10, 3, 30, angle, 1);
                fireSe.play();
            } else {
                var b:Block = new Block;
                b.pos.xy = mPos;
                b.vel.addAngle(angle, 5);
                Block.s.push(b);
                Particle.add(mPos, Color.white.rz, 20, 10, 1, 30, angle, 1);
                blockSe.play();
            }
            fireTicks = 30;
        }
    }
    public function hit(a:*):void {
        if (!isInGame) return;
        Particle.add(pos, Color.green.rz.rz, 20, 50, 5);
        destSe.play();
        endGame();
    }
    private function setShapeSe():void {
        shape = new DotShape;
        shape.c(Color.white.dr.dr).o(6).fr(2, 13).o(-5).fr(2, 13);
        shape.c(Color.green.dr).cs(Color.green.dr.rz).xa(1).ya(2).o(0, 0).fr(9, 11);
        shape.c(Color.yellow.dr).cs(Color.yellow.dr.bz).xya(0.1).fc(3).o(0, 7).fr(3, 7);
        for (var i:int = 0; i < 3; i++) {
            var s:DotShape = new DotShape;
            s.cs(Color.white.dr).ya(1).st(0.5).o(6, i - 1).fr(2, 13);
            trackShapeLs[i] = s;
            s = new DotShape;
            s.cs(Color.white.dr).ya(1).st(0.5).o(-5, i - 1).fr(2, 13);
            trackShapeRs[i] = s;
        }
        moveSe.t(Se.MINOR).m(1, 4, 10).e();
        fireSe.t(Se.NOISE).m(0.3, 4, 7).m(-1, 8).e();
        blockSe.t(Se.MINOR).m(5, 3, 15).r().m(-10, 2).e();
        destSe.t(Se.NOISE_SCALE).m(2, 5, 0).m(-1, 10).t(Se.NOISE).m(-1, 15, 15).e();
    }
}
class Shot extends Actor {
    public static var s:Vector.<Shot>;
    private static var shape:DotShape;
    public var angle:Number, speed:Number = 9;
    public var nextScore:int = 1;
    function Shot() {
        if (!shape) drawShape();
    }
    public function update():Boolean {
        pos.addAngle(angle, speed);
        size.x = size.y = 0;
        Actor.checkHit(this, Block.s, true);
        size.x = size.y = 20;
        Actor.checkHit(this, Enemy.s, true);
        Actor.checkHit(this, Bullet.s, true);
        shape.draw(pos, 3, angle);
        Particle.add(pos, Color.yellow.rz, 5, 1, -1, 10, angle, 0.5);
        return screen.isIn(pos, 15);
    }
    private function drawShape():void {
        shape = new DotShape;
        shape.c(Color.green.dr.dr).cs(Color.yellow.gz).xya(1).st(0.5).fr(3, 10);
    }
}
class Block extends Actor {
    public static var s:Vector.<Block>;
    private static var destSe:Se = new Se;
    private static var shape:DotShape;
    private var isDestroyed:Boolean;
    private var ticks:int;
    private var damage:Number = 0;
    function Block() {
        if (!shape) setShapeSe();
        size = new Xy(11 * 3, 11 * 3);
    }
    public function update():Boolean {
        if (isDestroyed) return false;
        if (vel.lengthSquared >= 0.5) {
            pos.incrementBy(vel);
            vel.scaleBy(0.9);
            var hitb:int = Actor.checkHitVel(this, s) | Actor.checkHitVel(this, Enemy.s);
            if (++ticks > 4) hitb |= Actor.checkHitVel(this, Tank.s);
            if ((hitb & Actor.HIT_X) > 0) vel.x *= -1;
            if ((hitb & Actor.HIT_Y) > 0) vel.y *= -1;
            if (hitb > 0) damage += 0.2;
            if (damage >= 1) hit(this);
            damage *= 0.9;
        }
        shape.draw(pos, 3);
        return true;
    }
    public function hit(a:*):void {
        if (isDestroyed) return;
        isDestroyed = true;
        Particle.add(pos, Color.white.rz, 10, 30, 1);
        destSe.play();
    }
    private function setShapeSe():void {
        shape = new DotShape;
        shape.c(Color.red.bz).cs(Color.white.bz).xya(0.6).ya(PI / 2).fr(11, 11);
        destSe.t(Se.NOISE).m(-1, 10, 10).e();
    }
}
class Enemy extends Actor {
    private static var destSe:Se = new Se, destLargeSe:Se = new Se;
    private static var fireSe:Se = new Se, fireLargeSe:Se = new Se;
    private static const ANGLE_VEL:Number = 0.03;
    public static var s:Vector.<Enemy>;
    private static var shape:DotShape;
    private static var largeShape:DotShape;
    private var angle:Number, speed:Number;
    private var isDestroyed:Boolean;
    private var isLarge:Boolean;
    private var ticks:int;
    private var tPos:Xy = new Xy;
    function Enemy(isLarge:Boolean = false) {
        if (!shape) setShapeSe();
        if (isFirstEnemy) {
            pos.x = screen.center.x;
            pos.y = -20;
            isFirstEnemy = false;
        } else {
            var ta:Number = screen.center.angle(tank.pos);
            ta += random.n(1) * random.pm() + PI;
            pos.xy = screen.center;
            pos.addAngle(ta, screen.size.x * 0.75);
        }
        tPos.x = random.sx(0.6, 0.2);
        tPos.y = random.sy(0.6, 0.2);
        angle = pos.angle(tPos);
        this.isLarge = isLarge;
        if (isLarge) {
            size.x = size.y = 45;
            speed = 0.5;
        } else {
            size.x = size.y = 27;
            speed = 1;
        }
    }
    private var pPos:Xy = new Xy;
    public function update():Boolean {
        if (isDestroyed) return false;
        var ph:int = int(++ticks / 60) % 2;
        vel.clear();
        if (ph == 0 && screen.isIn(pos)) {
            var ta:Number = pos.angle(tank.pos);
            var oa:Number = normalizeAngle(angle - ta);
            if (oa < -ANGLE_VEL) angle += ANGLE_VEL;
            else if (oa > ANGLE_VEL) angle -= ANGLE_VEL;
            else angle = ta;
        } else {
            vel.addAngle(angle, speed);
        }
        if (ticks % 77 == 0) {
            var b:Bullet = new Bullet(isLarge);
            b.pos.xy = pos;
            b.pos.addAngle(angle, 15);
            b.angle = angle;
            Bullet.s.push(b);
            Particle.add(b.pos, Color.magenta, 10, 5, 3, 20, angle, 1);
            if (isLarge) fireLargeSe.play();
            fireSe.play();
        }
        var hitb:int = Actor.checkHitVel(this, Block.s) | Actor.checkHitVel(this, Enemy.s);
        if ((hitb & Actor.HIT_X) > 0) vel.x = 0;
        if ((hitb & Actor.HIT_Y) > 0) vel.y = 0;
        pos.incrementBy(vel);
        if (isLarge) largeShape.draw(pos, 3, angle);
        else shape.draw(pos, 3, angle);
        return screen.isIn(pos, 200);
    }
    public function hit(a:*):void {
        if (isDestroyed) return;
        isDestroyed = true;
        var s:Shot = Shot(a);
        var ads:int = 10;
        if (isLarge) ads = 100;
        ads *= s.nextScore;
        Message.add(String(ads), pos, 0, -20);
        score += ads;
        s.nextScore += 1;
        if (isLarge) {
            Particle.add(pos, Color.red.bz, 20, 40, 3);
            destLargeSe.play();
        } else {
            Particle.add(pos, Color.red, 10, 30, 2);
            destSe.play();
        }
    }
    private function setShapeSe():void {
        shape = new DotShape;
        shape.c(Color.white.dr).o(-4).fr(2, 11);
        shape.c(Color.white.dr).o(5).fr(2, 11);
        shape.c(Color.magenta).o().cs(Color.red.br.br).ya(1.3).xya(0.7).fr(9, 9);
        shape.c(Color.red.br).o(-2, 5).ya(0.3).xya(1.7).fr(2, 5);
        shape.c(Color.red.br).o(2, 5).ya(0.3).xya(1.7).fr(2, 5);
        largeShape = new DotShape;
        largeShape.c(Color.white.dr.dr).o(-7).fr(3, 15);
        largeShape.c(Color.white.dr.dr).o(8).fr(3, 15);
        largeShape.c(Color.blue.rz).o().cs(Color.magenta.bz).ya(2).xya(3).fr(15, 11);
        largeShape.c(Color.magenta.br).xa(1).fc(6);
        largeShape.o(0, 10).fr(4, 10);
        destSe.t(Se.NOISE).m(0.3, 7, 5).m(-0.5, 3).e();
        destLargeSe.t(Se.NOISE).m(1, 10, 5).r(2).m( -0.2, 15, 3).t(Se.MINOR).m( -1, 20, 20).e();
        fireSe.t(Se.MINOR).m(3, 5, 10).m(-4, 5, 20).e();
        fireLargeSe.t(Se.MINOR).m(5, 7, 15).r().m(-3, 7, 25).e();
    }
}
class Bullet extends Actor {
    public static var s:Vector.<Bullet>;
    private static var shape:DotShape;
    private static var largeShape:DotShape;
    public var angle:Number, speed:Number;
    private var ticks:int;
    private var isDestroyed:Boolean;
    private var isLarge:Boolean;
    function Bullet(isLarge:Boolean) {
        if (!shape) drawShape();
        speed = 3 + sqrt(ticks * 0.01);
        this.isLarge = isLarge;
    }
    private static var oPos:Xy = new Xy, pPos:Xy = new Xy;
    public function update():Boolean {
        if (isDestroyed) return false;
        pos.addAngle(angle, speed);
        var hf:Boolean;
        if (isLarge) {
            size.x = size.y = 0;
            Actor.checkHit(this, Block.s, true);
        } else {
            size.x = size.y = 20;
            hf ||= Actor.checkHit(this, Block.s);
            if (++ticks > 9) hf ||= Actor.checkHit(this, Enemy.s);
        }
        size.x = size.y = 10;
        if (isInGame) hf ||= Actor.checkHit(this, Tank.s, true);
        if (hf) {
            Particle.add(pos, Color.magenta.bz, 5, 10, 3, 5, angle + PI, 1);
            return false;
        }
        if (isLarge) {
            largeShape.draw(pos, 3, angle);
            Particle.add(pos, Color.magenta.rz, 10, 2, -1, 10, angle, 0.2);
        } else {
            shape.draw(pos, 3, angle);
            for (var i:int = -1; i <= 1; i += 2) {
                oPos.clear();
                oPos.x = 6 * i;
                oPos.rotate(angle);
                pPos.xy = pos;
                pPos.incrementBy(oPos);
                Particle.add(pPos, Color.red, 4, 1, -1, 5, angle, 0.3);
            }
        }
        return screen.isIn(pos, 15);
    }
    public function hit(a:*):void {
        if (isDestroyed) return;
        isDestroyed = true;
        Particle.add(pos, Color.red, 5, 10, 3, 5);
    }
    private function drawShape():void {
        shape = new DotShape;
        shape.c(Color.red.dr.dr).cs(Color.yellow.rz).xya(1).st(0.5).o(2).fr(2, 5);
        shape.o(-2).fr(2, 5);
        largeShape = new DotShape;
        largeShape.c(Color.magenta.dr.dr).cs(Color.red.bz).xya(1).st(0.5).fr(3, 10);
    }
}
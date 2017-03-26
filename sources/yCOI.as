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
var PI:Number = Math.PI, PI2:Number = PI * 2, HPI:Number = PI / 2;
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
    public function set v(v:Number):void {
        x = y = v;
    }
    public function get way():Number {
        return atan2(x, y);
    }
}
var random:Random = new Random;
class Random {
    private var x:int, y:int, z:int, w:int;
    function Random(v:int = int.MIN_VALUE) {
        setSeed(v);
    }
    public function setSeed(v:int = int.MIN_VALUE):void {
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
    public var angle:Number = 0, speed:Number = 0;
    public var size:Xy = new Xy;
    public var radius:Number = -1;
    public static function updateAll(s:*):void {
        for (var i:int = 0; i < s.length; i++) if (!s[i].update()) s.splice(i--, 1);
    }
    public static function checkHitCircle(ca:*, s:*, callHit:Boolean = false):Boolean {
        return checkHit(ca, s, callHit, function(ca:*, a:*):Boolean {
            return (ca.pos.distance(a.pos) <= ca.radius + a.radius);
        });
    }
    public static function checkHitRect(ca:*, s:*, callHit:Boolean = false):Boolean {
        return checkHit(ca, s, callHit, function(ca:*, a:*):Boolean {
            return (abs(ca.pos.x - a.pos.x) <= (ca.size.x + a.size.x) / 2 &&
                abs(ca.pos.y - a.pos.y) <= (ca.size.y + a.size.y) / 2);
        });
    }
    public static function checkHit(ca:*, s:*, callHit:Boolean, hitTest:Function):Boolean {
        var hf:Boolean = false;
        for each (var a:* in s) {
            if (ca == a) continue;
            if (hitTest(ca, a)) {
                if (callHit) a.hit(ca);
                hf = true;
            }
        }
        return hf;
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
        stickXy.v = 0;
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
        return changeValue(LEVEL_VALUE, -LEVEL_VALUE / 2, -LEVEL_VALUE / 2);
    }
    public function get gz():Color {
        return changeValue(-LEVEL_VALUE / 2, LEVEL_VALUE, -LEVEL_VALUE / 2);
    }
    public function get bz():Color {
        return changeValue(-LEVEL_VALUE / 2, -LEVEL_VALUE / 2, LEVEL_VALUE);
    }
    public function blend(c:Color, ratio:Number):Color {
        return changeValue((c.r - r) * ratio, (c.g - g) * ratio, (c.b - b) * ratio);
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
    public static const BASE_SCALE:Number = 3;
    private static var rPos:Xy = new Xy;
    private static var rect:Rectangle = new Rectangle;
    private var dots:Vector.<OffsetColor> = new Vector.<OffsetColor>;
    private var color:Color = Color.transparent;
    private var colorSpot:Color = Color.transparent;
    private var colorBottom:Color;
    private var colorBottomSpot:Color;
    private var spotThreshold:Number = 0.3;
    private var xAngleVel:Number = 0;
    private var yAngleVel:Number = 0;
    private var xyAngleVel:Number = 0;
    private var offset:Xy = new Xy;
    public function c(c:Color, cs:Color = null, cb:Color = null, cbs:Color = null):DotShape {
        if (c) color = c;
        if (cs) colorSpot = cs;
        colorBottom = cb;
        colorBottomSpot = cbs;
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
                x == 0 || x == width - 1 || y == 0 || y == height - 1) {
                    fd(x + ox, y + oy, y / height);
                }
            }
        }
        return this;
    }
    public function fc(radius:Number, isDrawingEdge:Boolean = false):DotShape {
        var d:int = 3 - radius * 2;
        var y:int = radius;
        for (var x:int = 0; x <= y; x++) {
            if (isDrawingEdge) {
                setCircleDotsEdge(x, y, radius);
                setCircleDotsEdge(y, x, radius);
            } else {
                setCircleDots(x, y, radius);
                setCircleDots(y, x, radius);
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
    public function fd(x:Number, y:Number, ry:Number = 0):DotShape {
        var ca:Number =
            Math.cos(x * xAngleVel) * Math.cos(y * yAngleVel) * Math.cos((x + y) * xyAngleVel);
        var c:Color;
        if (Math.abs(ca) < spotThreshold) {
            if (colorBottomSpot) c = colorSpot.blend(colorBottomSpot, ry);
            else c = colorSpot;
        } else {
            if (colorBottom) c = color.blend(colorBottom, ry);
            else c = color;
        }
        if (c.r < 0) return this;
        var d:OffsetColor = new OffsetColor;
        d.offset.x = x + offset.x;
        d.offset.y = y + offset.y;
        d.color = c.i;
        dots.push(d);
        return this;
    }
    private function setCircleDots(x:int, y:int, r:int):void {
        setXLine(-x, x, y, r);
        setXLine(-x, x, -y, r);
    }
    private function setXLine(xb:int, xe:int, y:int, r:int):void {
        var ry:Number = (y + r) / (r * 2);
        for (var x:int = xb; x <= xe; x++) fd(x, y, ry);
    }
    private function setCircleDotsEdge(x:int, y:int, r:int):void {
        var ry:Number = (y + r) / (r * 2);
        fd(-x, y, ry); fd(x, y, ry);
        ry = (-y + r) / (r * 2);
        fd(-x, -y, ry); fd(x, -y, ry);
    }
    public function draw(
    pos:Xy, angle:Number = 0,
    scaleX:Number = BASE_SCALE, scaleY:Number = 0, rectScale:int = -1,
    color:Color = null):void {
        var sx:Number = scaleX, sy:Number;
        if (scaleY == 0) sy = scaleX;
        else sy = scaleY;
        if (rectScale > 0) {
            rect.width = rect.height = rectScale;
        } else {
            rect.width = abs(sx);
            rect.height = abs(sy);
        }
        var ox:int = scaleX / 2, oy:int = scaleY / 2;
        for each (var d:OffsetColor in dots) {
            rPos.x = d.offset.x * sx;
            rPos.y = d.offset.y * sy;
            if (angle != 0) rPos.rotate(angle);
            rect.x = int(pos.x + rPos.x) - ox;
            rect.y = int(pos.y + rPos.y) - oy;
            if (color) bd.fillRect(rect, color.i);
            else bd.fillRect(rect, d.color);
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
        const COUNT:int = 56;
        var patterns:Array = [
        0x4644AAA4, 0x6F2496E4, 0xF5646949, 0x167871F4, 0x2489F697, 0xE9669696, 0x79F99668,
        0x91967979, 0x1F799976, 0x1171FF17, 0xF99ED196, 0xEE444E99, 0x53592544, 0xF9F11119,
        0x9DDB9999, 0x79769996, 0x7ED99611, 0x861E9979, 0x994444E7, 0x46699699, 0x6996FD99,
        0xF4469999, 0x2226F248, 0x48644466, 0x24842842, 0xE440F0F0, 0x800F0044, 0x1244,
        0x9640444F, 0x40000404, 0x44404040, 0xA0000444, 0x45E40000, 0x4424F424, 0x42F244E5];
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
        91, 93, 60, 62, 61, 43, 45, 47, 95, 33, 63, 46, 58, 124, 39, 34, 117, 114, 100, 108];
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
    public function draw(
    text:String, x:Number, y:Number, isFromRight:Boolean = false, scale:Number = 2):void {
        var lw:int = scale * 5;
        tPos.x = x;
        if (isFromRight) tPos.x -= text.length * lw;
        else tPos.x -= text.length * lw / 2;
        tPos.y = y;
        for (var i:int = 0; i < text.length; i++) {
            var c:int = text.charCodeAt(i);
            var li:int = charToIndex[c];
            if (li >= 0) shapes[li].draw(tPos, 0, scale);
            tPos.x += lw;
        }
    }
}
class Message extends Actor {
    public static var s:Vector.<Message> = new Vector.<Message>;
    private static var shownMessages:Vector.<String> = new Vector.<String>;
    public static function addOnce(
    text:String, x:Number, y:Number, vx:Number = 0, vy:Number = 0, ticks:int = 240):Message {
        if (shownMessages.indexOf(text) >= 0) return null;
        shownMessages.push(text);
        return add(text, x, y, vx, vy, ticks);
    }
    public static function add(
    text:String, x:Number, y:Number, vx:Number = 0, vy:Number = 0, ticks:int = 60):Message {
        var m:Message = new Message;
        m.text = text;
        m.pos.x = x; m.pos.y = y;
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
    private static var toneRandom:Random = new Random;
    private var data:SiONData;
    private var isPlaying:Boolean;
    private var mml:String;
    private var type:int;
    private var tone:Number = 0;
    private var lastPlayTicks:int;
    public function t(v:int, l:int = 64):Se {
        type = v;
        if (!mml) mml = "";
        else mml += ";";
        var voices:Array = [1, 1, 9, 10];
        mml += "%1@" + voices[v] + "l" + l;
        return this;
    }
    public function m(step:Number, time:int, start:Number = -1,
    randomWidth:Number = 0, randomSeed:int = 0):Se {
        toneRandom.setSeed(randomSeed);
        if (start >= 0) tone = start;
        for (var i:int = 0; i < time; i++) {
            tone = clamp(tone, 0, 1);
            var tv:Number = clamp(tone + toneRandom.n(randomWidth) * toneRandom.pm(), 0, 1);
            switch (type) {
                case MAJOR:
                case MINOR:
                    var ti:int = tv * 39;
                    var o:int = ti / 5 + 2;
                    mml += "o" + o + tones[type + 1][ti % 5];
                    break;
                case NOISE:
                case NOISE_SCALE:
                    ti = tv * 14;
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
        if (!isInGame || lastPlayTicks > 0) return;
        isPlaying = true;
    }
    public function update():void {
        lastPlayTicks--;
        if (!isPlaying) return;
        if (!isStarting) {
            driver.volume = 0.9;
            isStarting = true;
        }
        driver.sequenceOn(data, null, 0, 0, 0);
        isPlaying = false;
        lastPlayTicks = 5;
    }
}
// ---- Game state controller. ----
var score:int, ticks:int;
var isInGame:Boolean;
var isPaused:Boolean;
var wasClicked:Boolean, wasReleased:Boolean;
var titleTicks:int;
var highScores:Array;
var currentRanking:int = -1;
var isRankUp:Boolean;
var currentRankString:String;
function beginGame():void {
    getHighScores();
    isInGame = true;
    score = 0;
    currentRanking = -1;
    ticks = 0;
    closeScoreForms();
    random.setSeed();
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
    if (!isPaused) update();
    for each (var s:Se in Se.s) s.update();
    drawScore();
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
var rankPostpositions:Array = ["ST", "ND", "RD", "TH"];
function drawScore():void {
    letter.draw(String(score), screen.size.x, 2, true, 3);
    if (currentRanking < 0) {
        if (highScores) currentRanking = highScores.length;
        else return;
    }
    isRankUp = false;
    while (currentRanking > 0 && score > highScores[currentRanking - 1].score) {
        currentRanking--;
        isRankUp = true;
    }
    if (currentRanking < highScores.length) {
        var cr:Object = highScores[currentRanking];
        currentRankString = cr.rank + rankPostpositions[clamp(cr.rank - 1, 0, 3)];
        letter.draw(currentRankString, screen.size.x, 20, true, 2);
    }
    if (currentRanking > 0) {
        var nr:Object = highScores[currentRanking - 1];
        letter.draw("NEXT " + nr.rank + rankPostpositions[clamp(nr.rank - 1, 0, 3)] +
            " " + nr.name + " " + nr.score, screen.size.x, 32, true, 1);
    }
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
function getHighScores():void { }
/*/
import net.wonderfl.score.basic.BasicScoreForm;
import net.wonderfl.score.basic.BasicScoreRecordViewer;
import net.wonderfl.score.manager.ScoreManager;
const HIGHSCORE_COUNT:int = 50;
var scoreRecordViewer:BasicScoreRecordViewer;
var scoreForm:BasicScoreForm;
var scoreManager:ScoreManager;
function setScoreRecordViewer():void {
    scoreRecordViewer =
        new BasicScoreRecordViewer(main, 5, 220, "SCORE RANKING", HIGHSCORE_COUNT);
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
function getHighScores():void {
    if (!scoreManager) {
        scoreManager = new ScoreManager(main);
        scoreManager.addEventListener(Event.COMPLETE, onScoreGot);
    }
    highScores = null;
    scoreManager.getScore(HIGHSCORE_COUNT);
}
function onScoreGot():void {
    highScores = scoreManager.score;
    for (var i:int = 0; i < highScores.length; i++) {
        var s:Object = highScores[i];
        s.name = s.name.toUpperCase();
    }
}
//*/
// ---- Game main logic. ----
const TITLE:String = "I'M FRONTLINE";
const DEBUG:Boolean = false;
var rTankAddTicks:int, gTankAddTicks:int;
var startSe:Se = new Se().t(Se.MAJOR, 16).m(0.6, 6, -0.4, 0.2, 0).c();
function initialize():void {
    initBack();
    player = new Player;
    Tank.s = new Vector.<Tank>;
    Shot.s = new Vector.<Shot>;
    rTankAddTicks = gTankAddTicks = 0;
    if (isInGame) startSe.play();
}
function update():void {
    if (isInGame && ticks == 0) Message.addOnce("[u][d][l][r]: MOVE", 100, 50);
    if (--rTankAddTicks <= 0) {
        Tank.s.push(new Tank(true));
        rTankAddTicks = 120 + (player.pos.x - screen.center.x) * 0.4;
    }
    if (--gTankAddTicks <= 0) {
        Tank.s.push(new Tank(false));
        gTankAddTicks = 120 - (player.pos.x - screen.center.x) * 0.4;
    }
    drawBack();
    Tank.drawShadows();
    Shot.drawShadows();
    if (isInGame) player.drawShadow();
    Actor.updateAll(Particle.s);
    Tank.redCount = Tank.greenCount = 0;
    Actor.updateAll(Tank.s);
    Tank.redScore = Tank.redCount;
    Tank.greenScore = Tank.greenCount;
    Actor.updateAll(Shot.s);
    if (isInGame) player.update();
}
var backGroundShape:DotShape;
var bgsPos:Xy;
var skyShape:DotShape;
var skyPos:Xy;
function initBack():void {
    if (backGroundShape) return;
    backGroundShape = new DotShape().
    c(Color.red.dr.dr.dr, Color.red.dr.dr.dr, Color.red.gz.gz.dr, Color.yellow.rz.rz.rz.dr.dr).
    sa(1, 1, 1).st(0.1).fr(15, 13);
    bgsPos = new Xy(screen.center.x, screen.size.y - 14 * 31 / 2);
    skyShape = new DotShape().
    c(Color.blue.br.br, Color.white.dr.dr, Color.blue.br, Color.white.dr.dr.dr).
    sa(0.8, 0, 0.3).st(0.5).fr(15, 2);
    skyPos = new Xy(screen.center.x, 31);
}
function drawBack():void {
    skyShape.draw(skyPos, 0, 31);
    backGroundShape.draw(bgsPos, 0, 31);
}
class Tank extends Actor {
    public static var s:Vector.<Tank>;
    public static var redCount:int, greenCount:int;
    public static var redScore:int, greenScore:int;
    private static var rShape:DotShape = new DotShape().
    c(Color.white.dr.dr).o(0, 2).fr(5, 1).
    c(Color.black, null, Color.black.br.br).sa().fr(7, 3, true).
    c(Color.red.br, Color.red.br.br, Color.red.dr, Color.red).sa(3, 2, 1).o(0, -1).fr(3, 4).
    c(Color.red.bz, Color.red.bz.bz).o(3, -2).fr(3, 1);
    private static var gShape:DotShape = new DotShape().
    c(Color.white.dr.dr).o(0, 2).fr(5, 1).
    c(Color.black, null, Color.black.br.br).sa().fr(7, 3, true).
    c(Color.green, Color.green.br, Color.green.dr.dr, Color.green.dr).
    sa(3, 2, 1).o(0, -1).fr(3, 4).
    c(Color.green.bz, Color.green.bz.bz).o(-3, -2).fr(3, 1);
    private static var shotSe:Se = new Se().t(Se.NOISE).m(0.5, 4, -0.5, 0.1).c();
    private static var dstSe:Se = new Se().
    t(Se.NOISE).m(0.7, 7, -0.5, 0.4).t(Se.MAJOR).m(0.7, 7, -0.5, 0.4, 1).c();
    private static var tPos:Xy = new Xy;
    private var fireTicks:int = 100;
    public var isRed:Boolean;
    private var isDestroyed:Boolean;
    function Tank(isRed:Boolean) {
        this.isRed = isRed;
        if (isRed) {
            pos.x = -20;
            pos.y = random.sy(0.8, 0.2);
            tPos.x = screen.size.x;
            tPos.y = random.sy(0.6, 0.3);
        } else {
            pos.x = screen.size.x + 20;
            pos.y = random.sy(0.8, 0.2);
            tPos.x = 0;
            tPos.y = random.sy(0.6, 0.3);
        }
        angle = pos.angle(tPos);
        vel.addAngle(angle, random.n(0.1 + sqrt(ticks * 0.001) * 0.1, 0.1));
        size.v = 20;
    }
    public function update():Boolean {
        if (isDestroyed) return false;
        pos.incrementBy(vel);
        if (isRed) {
            rShape.draw(pos, 0, 4);
            letter.draw(String(redScore), pos.x, pos.y - 20);
            redCount++;
            if (isInGame && pos.x > screen.size.x) {
                Particle.add(pos, Color.yellow, 50, 100, 10, 60, angle + PI, 1);
                player.destroy();
            }
        } else {
            gShape.draw(pos, 0, 4);
            letter.draw(String(greenScore), pos.x, pos.y - 20);
            greenCount++;
            if (isInGame && pos.x < 0) {
                Particle.add(pos, Color.yellow, 50, 100, 10, 60, angle + PI, 1);
                player.destroy();
            }
        }
        if (--fireTicks < 0) {
            Shot.s.push(new Shot(pos, isRed));
            fireTicks = 120;
            shotSe.play();
        }
        return screen.isIn(pos, 20);
    }
    private static var sPos:Xy = new Xy;
    public function drawShadow():void {
        sPos.x = pos.x;
        sPos.y = pos.y + 20;
        if (isRed) rShape.draw(sPos, 0, 4, -2, -1, Color.black);
        else gShape.draw(sPos, 0, 4, -2, -1, Color.black);
    }
    public static function drawShadows():void {
        for each (var t:Tank in s) t.drawShadow();
    }
    public function hit(s:Shot):void {
        if (isDestroyed) return;
        if (s.isRed == isRed) return;
        isDestroyed = true;
        var c:Color;
        if (isRed) c = Color.red.gz.gz;
        else c = Color.green.rz.rz;
        Particle.add(pos, c, 30, 30, 3);
        if (!isInGame) return;
        dstSe.play();
        var ads:int;
        if (isRed) ads = redScore;
        else ads = greenScore;
        Message.add("+ " + ads, pos.x, pos.y, 0, -50);
        score += ads;
    }
}
var player:Player;
class Player extends Actor {
    private static var bodyShape:DotShape = new DotShape().
    c(Color.yellow, Color.yellow.gz, Color.yellow.dr.dr, Color.yellow.gz.dr).fr(1, 4);
    private static var hllShape:DotShape = new DotShape().
    c(Color.yellow, Color.yellow.gz, Color.yellow.dr.dr, Color.yellow.gz.dr).
    o(0, 2).fr(1, 2).o(1, 2).fr(2, 1);
    private static var hlrShape:DotShape = new DotShape().
    c(Color.yellow, Color.yellow.gz, Color.yellow.dr.dr, Color.yellow.gz.dr).
    o(0, 2).fr(1, 2).o( -1, 2).fr(2, 1);
    private static var dstSe:Se = new Se().
    t(Se.NOISE_SCALE).m(-0.8, 20, 0.8, 0.3, 10).t(Se.MINOR).m( -0.6, 20, 0.6, 0.3, 12).c();
    private var moveTicks:int;
    function Player() {
        pos.x = screen.center.x;
        pos.y = screen.size.y * 0.6;
        size.x = 4; size.y = 6;
    }
    private static var sPos:Xy = new Xy;
    private var isToLeft:Boolean;
    public function update():void {
        pos.x = clamp(pos.x + key.stick.x * 3, 0, screen.size.x);
        pos.y = clamp(pos.y + key.stick.y * 3, screen.size.y * 0.15, screen.size.y);
        moveTicks += key.stick.length * 10;
        if (key.stick.x > 0) isToLeft = false;
        if (key.stick.x < 0) isToLeft = true;
        sPos.x = pos.x;
        var handShape:DotShape, legShape:DotShape;
        var lo:Number;
        if (isToLeft) {
            handShape = hllShape; legShape = hlrShape;
            lo = -PI / 4;
        } else {
            handShape = hlrShape; legShape = hllShape;
            lo = 0;
        }
        sPos.y = pos.y + 7;
        legShape.draw(sPos, sin(moveTicks * 0.03) + lo, 4);
        sPos.y = pos.y - 3;
        handShape.draw(sPos, sin(moveTicks * 0.03 + PI) * 0.5, 4);
        sPos.y = pos.y - 2;
        bodyShape.draw(sPos, 0, 4);
        sPos.y = pos.y - 3;
        handShape.draw(sPos, sin(moveTicks * 0.03) * 0.5, 4);
        sPos.y = pos.y + 7;
        legShape.draw(sPos, sin(moveTicks * 0.03 + PI) + lo, 4);
        if (Actor.checkHitRect(this, Shot.s) || Actor.checkHitRect(this, Tank.s)) {
            destroy();
        }
    }
    public function destroy():void {
        if (!isInGame) return;
        Particle.add(pos, Color.yellow, 50, 50, 5);
        dstSe.play();
        endGame();
    }
    public function drawShadow():void {
        sPos.x = pos.x;
        var handShape:DotShape, legShape:DotShape;
        var lo:Number;
        if (isToLeft) {
            handShape = hllShape; legShape = hlrShape;
            lo = -PI / 4;
        } else {
            handShape = hlrShape; legShape = hllShape;
            lo = 0;
        }
        sPos.y = pos.y + 25;
        legShape.draw(sPos, sin(moveTicks * 0.03) + lo, 4, -2, -1, Color.black);
        sPos.y = pos.y + 30;
        handShape.draw(sPos, sin(moveTicks * 0.03 + PI) * 0.5, 4, -2, -1, Color.black);
        sPos.y = pos.y + 27;
        bodyShape.draw(sPos, 0, 4, -2, -1, Color.black);
        sPos.y = pos.y + 30;
        handShape.draw(sPos, sin(moveTicks * 0.03) * 0.5, 4, -2, -1, Color.black);
        sPos.y = pos.y + 25;
        legShape.draw(sPos, sin(moveTicks * 0.03 + PI) + lo, 4, -2, -1, Color.black);
    }
}
class Shot extends Actor {
    public static var s:Vector.<Shot>;
    private static var rShape:DotShape = new DotShape().
    c(Color.red.dr, Color.red.bz.bz, Color.red, Color.red.bz).sa(1, 2).fr(3, 7);
    private static var gShape:DotShape = new DotShape().
    c(Color.green.dr, Color.green.bz.bz, Color.green, Color.green.bz).sa(1, 2).fr(3, 7);
    public var isRed:Boolean;
    public var isDestroyed:Boolean;
    function Shot(p:Xy, isRed:Boolean) {
        this.isRed = isRed;
        if (isRed) pos.x = p.x + 20;
        else pos.x = p.x - 20;
        pos.y = p.y - 7;
        angle = pos.angle(player.pos);
        if (isRed) {
            if (abs(angle - HPI) > HPI / 3 * 2) isDestroyed = true;
        } else {
            if (abs(angle + HPI) > HPI / 3 * 2) isDestroyed = true;
        }
        if (isDestroyed) return;
        vel.addAngle(angle, 2);
        size.x = 21; size.y = 9;
        var c:Color;
        if (isRed) c = Color.red.gz;
        else c = Color.green.rz;
        Particle.add(p, c, 10, 10, 3, 60, angle, 0.3);
    }
    public function update():Boolean {
        if (isDestroyed) return false;
        pos.incrementBy(vel);
        if (isRed) rShape.draw(pos, angle);
        else gShape.draw(pos, angle);
        if (Actor.checkHitRect(this, Tank.s, true)) {
            Particle.add(pos, Color.yellow, 7, 7, 2);
            return false;
        }
        return (screen.isIn(pos, 21) && pos.y > screen.size.y * 0.1);
    }
    private static var sPos:Xy = new Xy;
    public function drawShadow():void {
        sPos.x = pos.x;
        sPos.y = pos.y + 15;
        rShape.draw(sPos, angle, 3, -2, -1, Color.black);
    }
    public static function drawShadows():void {
        for each (var st:Shot in s) st.drawShadow();
    }
}
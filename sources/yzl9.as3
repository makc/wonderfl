package {
    import flash.display.Sprite;
    [SWF(width="465", height="465", backgroundClr="0xffffff", frameRate="30")]
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
    bd = new BitmapData(scr.size.x, scr.size.y, true, 0xffffff);
    blurBd = new BitmapData(scr.size.x, scr.size.y, true, 0xffffff);
    blurFilter = new BlurFilter(7, 7, 2);
    baseSprite = new Sprite;
    baseSprite.addChild(new Bitmap(blurBd));
    main.addChild(new Bitmap(new BitmapData(scr.size.x, scr.size.y, false, 0xffffff)));
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
var bgColor:uint = 0xffffffff;
function updateFrame(event:Event):void {
    bd.lock();
    bd.fillRect(bd.rect, bgColor);
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
    public function drawText(text:String, x:int, y:int, color:uint = 0):void {
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
    ticks:int = 90, color:uint = 0):Msg {
        if (shownMessages.indexOf(text) >= 0) return null;
        shownMessages.push(text);
        return add(text, p, vx, vy, ticks, color);
    }
    public static function add(text:String, p:Vct, vx:Number = 0, vy:Number = 0,
    ticks:int = 90, color:uint = 0):Msg {
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
const TITLE:String = "p3j2"
const DEBUG:Boolean = false;
var pillarAddDist:Number;
var scrollSpeed:Number;
var scrollX:Number, targetScrollX:Number;
var scrollXChangeTicks:int;
function initialize():void {
    pillars = new Vector.<Pillar>;
    pillarAddDist = 0;
    scrollSpeed = 0.1;
    scrollX = targetScrollX = 0;
    scrollXChangeTicks = 0;
    for (var i:int = 0; i < 30; i++) {
        var p:Pillar = new Pillar;
        p.pos.x /= 2;
        pillars.push(p);
        scroll();
    }
    player = new Player;
}
function update():void {
    if (isInGame) player.update();
    if (ticks == 1) Msg.addOnce("[<-][->] or [A][D] : Move", new Vct(100, 50), 0, 0, 150);
    if (ticks == 10) Msg.addOnce("[Z] or [/]: Jump", new Vct(100, 80), 0, 0, 141);
    scrollSpeed = 0.01 * (1 + sqrt(ticks * 0.01));
    pillarAddDist -= scrollSpeed;
    if (pillarAddDist <= 0) {
        pillars.push(new Pillar);
        pillarAddDist += rnd.n(0.1, 0.1);
    }
    updateActors(pillars);
    if (--scrollXChangeTicks <= 0) {
        scrollXChangeTicks = rnd.i(60, 60);
        targetScrollX = rnd.n(sqrt(ticks * 0.01)) * rnd.pm();
    }
    scrollX += (targetScrollX - scrollX) * 0.05;
    scroll();
}
var pillars:Vector.<Pillar>;
class Pillar {
    public var pos:Vct = new Vct;
    public var sPos:Vct = new Vct;
    public var size:Vct = new Vct;
    public var sSize:Vct = new Vct;
    public var shp:Shp = new Shp;
    function Pillar() {
        pos.x = rnd.n(1000, -500);
        pos.y = 50;
        pos.z = 3;
        size.x = rnd.n(20, 20);
        size.y = rnd.n(40, 20);
    }
    public function update():Boolean {
        sPos.x = pos.x / pos.z;
        sPos.y = pos.y / pos.z;
        sPos.incrementBy(scr.center);
        sSize.x = size.x / pos.z;
        sSize.y = size.y / pos.z;
        shp.clear().fill(Clr.black).rect(sSize.x, sSize.y, sPos.x, sPos.y - sSize.y / 2).draw();
        if (pos.z < 0.1) {
            sSize.x = -999;
            return false;
        }
        return true;
    }
}
function scroll():void {
    for each (var p:Pillar in pillars) {
        p.pos.x += scrollX;
        p.pos.z -= scrollSpeed;
    }
}
function checkHitPillars(pos:Vct, s:Number):Pillar {
    for each (var p:Pillar in pillars) {
        if (abs(pos.x - p.sPos.x) < p.sSize.x  / 2 + s &&
            abs(pos.y - (p.sPos.y - p.sSize.y / 2)) < p.sSize.y / 2 + s) {
                return p;
        }
    }
    return null;
}
var player:Player;
class Player {
    public const SIZE:Number = 10;
    public var pos:Vct = new Vct(scr.center.x, 0);
    public var vel:Vct = new Vct;
    public var shp:Shp = new Shp().fill(Clr.black).circle(SIZE);
    public var pillar:Pillar;
    public var ox:Number;
    public function update():void {
        if (!pillar) {
            pos.incrementBy(vel);
            pos.x = clamp(pos.x, SIZE, scr.size.x - SIZE);
            if (key.isButtonPressed) vel.y += 1;
            else vel.y += 2;
            pos.x += key.stick.x * 5;
            if (vel.y > 0) {
                pillar = checkHitPillars(pos, SIZE);
                if (pillar) ox = pos.x - pillar.sPos.x;
            }
        }
        if (pillar) {
            score += 10 / (1 + pillar.pos.z);
            pos.x = pillar.sPos.x + ox;
            pos.y = pillar.sPos.y - pillar.sSize.y - SIZE;
            ox += key.stick.x * 5;
            if (abs(ox) > pillar.sSize.x / 2 + SIZE) pillar = null;
            if (key.isButtonPressed || pos.x < SIZE || pos.x > scr.size.x - SIZE) {
                vel.y = -20;
                pillar = null;
            }
        }
        shp.p(pos).draw();
        if (pos.y > scr.size.y + SIZE) endGame();
    }
}
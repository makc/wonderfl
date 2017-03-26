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
var bgColor:uint = 0xff222288;
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
const TITLE:String = "bacrush"
const DEBUG:Boolean = false;
var boardAppTicks:Number;
var boardAppPatternChangeTicks:Number;
var boardAppPattern:Vector.<Number>;
function initialize():void {
    boards = new Vector.<Board>;
    shots = new Vector.<Shot>;
    ship = new Ship;
    if (!isInGame) ship.pos.y = 99999;
    boardAppTicks = 0;
    boardAppPatternChangeTicks = 120;
    boardAppPattern = new Vector.<Number>;
    boardAppPattern.push(0);
}
function update():void {
    if (--boardAppPatternChangeTicks <= 0) {
        var apn:int = clamp(rnd.i(sqrt(ticks * 0.005), 1), 1, 3);
        boardAppPattern = new Vector.<Number>;
        for (var i:int = 0; i < apn; i++) {
            boardAppPattern.push(rnd.i(4) * PI / 2);
        }
        boardAppPatternChangeTicks += rnd.n(120, 120);
    }
    if (--boardAppTicks <= 0) {
        var ba:Number = boardAppPattern[rnd.i(boardAppPattern.length)];
        boards.push(new Board(ba));
        boardAppTicks += 30 / (3 + sqrt(ticks * 0.01));
    }
    updateActors(boards);
    updateActors(shots);
    ship.update();
    if (ticks == 1) Msg.addOnce("[WASD] or Arrow Keys: Move", new Vct(100, 100), 0, 0, 150); 
    if (ticks == 51) Msg.addOnce("[Z] or [/]: Fire", new Vct(100, 150), 0, 0, 100); 
}
class Act {
    public var pos:Vct = new Vct, vel:Vct = new Vct;
    public var shp:Shp = new Shp;
    public function move():void {
        pos.incrementBy(vel);
    }
    public function draw():void {
        shp.p(pos).draw();
    }
    public function md(size:Number):Boolean {
        move();
        draw();
        return scr.isIn(pos, size);
    }
}
var boards:Vector.<Board>;
class Board extends Act {
    public static const WIDTH:Number = 80;
    public var sVel:Vct = new Vct;
    public var height:Number, heightTicks:int;
    public var clr:Clr;
    public var angle:Number;
    public function Board(a:Number) {
        pos.x = rnd.sx(1, -0.5);
        pos.y = -scr.center.y - WIDTH / 2;
        pos.rotate(a);
        pos.incrementBy(scr.center);
        vel.y = rnd.n(3 + sqrt(ticks * 0.01), 3);
        vel.rotate(a);
        angle = a;
        clr = new Clr(8, 8, 8);
    }
    public function update():Boolean {
        heightTicks++;
        height = abs(WIDTH * cos(heightTicks * 0.1));
        clr.brightness = abs(cos(heightTicks * 0.1)) * 0.5 + 0.5;
        shp.clear().fill(clr).rect(WIDTH, height);
        pos.incrementBy(sVel);
        sVel.scaleBy(0.8);
        shp.a(angle);
        return md(WIDTH);
    }
}
function checkHitBoards(p:Vct, v:Vct, w:Number):Boolean {
    var isHit:Boolean = false;
    for each (var b:Board in boards) {
        if (abs(b.pos.x - p.x) < (Board.WIDTH + w) / 2 &&
            abs(b.pos.y - p.y) < (b.height + w) / 2) {
            b.sVel.incrementBy(v);
            isHit = true;
            score++;
        }
    }
    return isHit;
}
var shots:Vector.<Shot>;
class Shot extends Act {
    public static const WIDTH:Number = 30;
    public var angle:Number;
    public function Shot(v:Vct) {
        shp.fill(Clr.magenta).rect(8, 8, WIDTH / 2 - 4, 0).
            fill(Clr.cyan).rect(8, 8, -WIDTH / 2 + 4, 0);
        pos.xy = ship.pos;
        vel.xy = v;
        pos.incrementBy(v);
        angle = vel.way;
    }
    public function update():Boolean {
        if (checkHitBoards(pos, vel, WIDTH)) return false;
        shp.a(-angle);
        return md(WIDTH);
    }
}
var ship:Ship;
class Ship extends Act {
    public static const SIZE:Number = 30;
    public var fireTicks:int;
    public function Ship() {
        pos.x = scr.center.x;
        pos.y = scr.size.y * 0.7;
        setShape(Clr.white);
    }
    private function setShape(c:Clr):void {
        var s:Number = SIZE / 2;
        shp.fill(c).m(0, -s).l(s / 3, -s / 2).l(s / 3, s / 2).
        l( -s / 3, s / 2).l( -s / 3, -s / 2).
        rect(s / 3, s / 3 * 4, s / 3 * 2, s / 3).
        rect(s / 3, s / 3 * 4, -s / 3 * 2, s / 3);
    }
    private var sv1:Vct = new Vct(0, -10);
    private var sv2:Vct = new Vct(-7, 7);
    private var sv3:Vct = new Vct(7, 7);
    public function update():Boolean {
        if (!isInGame) {
            draw();
            return true;
        }
        vel = key.stick;
        vel.scaleBy(7);
        if (--fireTicks <= 0 && key.isButtonPressed) {
            shots.push(new Shot(sv1));
            shots.push(new Shot(sv2));
            shots.push(new Shot(sv3));
            fireTicks = 3;
        }
        move();
        if (pos.x < 0) pos.x = 0;
        if (pos.x > scr.size.x) pos.x = scr.size.x;
        if (pos.y < 0) pos.y = 0;
        if (pos.y > scr.size.y) pos.y = scr.size.y;
        if (checkHitBoards(pos, vel, 0)) {
            setShape(Clr.red);
            endGame();
        }
        draw();
        return true;
    }
}
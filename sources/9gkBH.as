package {
    import flash.display.Sprite;
    [SWF(width="465", height="465", backgroundClr="0", frameRate="30")]
    public class Main extends Sprite {
        public function Main() { main = this; initializeFirst(); }
    }
}
import adobe.utils.CustomActions;
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
    mouse = new Mouse;
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
    public function get speed():Number {
        return getLength(x, y);
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
    public function p(p:Vct): Shp {
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
var mouse:Mouse;
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
        if (mouse.isPressing) {
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
const TITLE:String = "propagate"
const DEBUG:Boolean = false;
var glassAppDist:Number;
var waveAppDist:Number;
var scrollSpeed:Number;
function initialize():void {
    player = new Player;
    glasses = new Vector.<Glass>;
    waves = new Vector.<Wave>;
    for (var y:Number = scr.center.y; y >= 0; y -= rnd.n(20, 20)) {
        glasses.push(new Glass(y));
    }
    glassAppDist = waveAppDist = 10;
}
function update():void {
    scrollSpeed = sqrt(ticks * 0.0005) + 1;
    glassAppDist -= scrollSpeed;
    while (glassAppDist <= 0) {
        glasses.push(new Glass);
        glassAppDist += rnd.n(20, 20);
    }
    waveAppDist -= scrollSpeed;
    while (waveAppDist <= 0) {
        waves.push(new Wave);
        waveAppDist += rnd.n(60, 30);
    }
    player.update();
    updateActors(glasses);
    updateActors(waves);
}
var player:Player;
class Player {
    public const RADIUS:Number = 10;
    public var pos:Vct = new Vct(scr.center.x, scr.size.y * 0.7);
    public var shp:Shp = new Shp().fill(Clr.green).circle(RADIUS);
    private const SPEED:Number = 10;
    private var o:Vct = new Vct;
    public function Player() {
        if (!isInGame) pos.y = scr.size.y * 2;
    }
    public function update():void {
        if (!isInGame) {
            pos.y += scrollSpeed;
            shp.p(pos).draw();
            return;
        }
        o.xy = mouse.pos;
        o.decrementBy(pos);
        if (o.length > SPEED) {
            o.normalize();
            o.scaleBy(SPEED);
        }
        pos.incrementBy(o);
        shp.p(pos).draw();
    }
    public function destroy():void {
        if (!endGame()) return;
        shp = new Shp().fill(Clr.red).circle(RADIUS);
    }
}
var glasses:Vector.<Glass>;
class Glass {
    public var points:Vector.<Vct> = new Vector.<Vct>;
    public var shp:Shp;
    public var pos:Vct = new Vct;
    public var size:Number;
    public function Glass(y:Number = 0) {
        shp = new Shp().line(Clr.red);
        size = rnd.n(30, 10);
        pos.x = rnd.sx();
        pos.y = y - size;
        for (var i:int = 0; ; i++) {
            var a:Number = PI2 / 3 * i + PI;
            var p:Vct = new Vct(sin(a) * size, cos(a) * size);
            if (i == 0) shp.m(p.x, p.y);
            else shp.l(p.x, p.y);
            if (i >= 3) break;
            points.push(p);
        }
    }
    public function update():Boolean {
        shp.p(pos).draw();
        pos.y += scrollSpeed;
        if (contains(player.pos)) player.destroy();
        return pos.y < scr.size.y + size;
    }
    private var p1:Vct = new Vct;
    private var p2:Vct = new Vct;
    public function contains(p:Vct):Boolean {
        var ni:int = 0;
        for (var i:int = 0; i < points.length; i++) {
            if (++ni >= points.length) ni = 0;
            p1.xy = points[i];
            p2.xy = points[ni];
            p1.incrementBy(pos);
            p2.incrementBy(pos);
            if ((p1.y - p2.y) * p.x - (p1.x - p2.x) * p.y >
            (p1.y - p2.y) * p1.x - (p1.x - p2.x) * p1.y) return false;
        }
        return true;
    }
}
var waves:Vector.<Wave>;
class Wave {
    public var pos:Vct = new Vct;
    public var points:Vector.<Vct> = new Vector.<Vct>;
    public var vels:Vector.<Vct> = new Vector.<Vct>;
    public var shp:Shp;
    public var clr:Clr = new Clr;
    public var speed:Number;
    public var beginTicks:int = 30;
    public var endTicks:int = 60;
    private const COUNT:int = 64;
    public function Wave() {
        pos.x = rnd.sx();
        pos.y = rnd.sy(0.5);
        for (var i:int = 0; i < COUNT; i++) {
            var a:Number = PI2 / COUNT * i;
            points.push(new Vct);
            vels.push(new Vct(sin(a), cos(a)));
        }
        clr.rgb = Clr.magenta;
        var s:Number = sqrt(ticks * 0.001) + 2;
        speed = rnd.n(s, 2);
    }
    public function update():Boolean {
        var isIn:Boolean;
        if (beginTicks > 0) {
            var r:Number = speed * 5 * beginTicks / 30;
            for (var i:int = 0; i < COUNT; i++) {
                points[i].x = pos.x + vels[i].x * r;
                points[i].y = pos.y + vels[i].y * r;
            }
            if (--beginTicks <= 0) clr.rgb = Clr.red;
            pos.y += scrollSpeed;
            isIn = true;
            if (isInGame) {
                var sc:int = 200 / (player.pos.distance(pos) + 10);
                if (sc > 0) {
                    score += sc;
                    Msg.add("+" + sc, pos, 0, 0, 1);
                }
            }
        } else {
            speed *= 0.99;
            for (i = 0; i < points.length; i++) {
                var sp:Number = speed;
                for each (var g:Glass in glasses) {
                    if (g.contains(points[i])) {
                        sp = 0.5;
                        break;
                    }
                }
                points[i].x += vels[i].x * sp;
                points[i].y += vels[i].y * sp + scrollSpeed;
                if (points[i].distance(player.pos) < player.RADIUS) player.destroy();
                isIn ||= scr.isIn(points[i]);
            }
            clr.brightness = Number(endTicks + 60) / 90;
            endTicks--;
        }
        shp = new Shp().clear().line(clr, 2);
        var lp:Vct = points[points.length - 1];
        shp.m(lp.x, lp.y);
        for (i = 0; i < points.length; i++) {
            lp = points[i];
            shp.l(lp.x, lp.y);
        }
        shp.draw();
        return endTicks > 0 && isIn;
    }
}
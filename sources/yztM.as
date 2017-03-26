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
var bgColor:uint = 0;
function initializeFirst():void {
    bd = new BitmapData(scr.size.x, scr.size.y, true, bgColor);
    blurBd = new BitmapData(scr.size.x, scr.size.y, true, bgColor);
    blurFilter = new BlurFilter(7, 7, 2);
    baseSprite = new Sprite;
    baseSprite.addChild(new Bitmap(blurBd));
    main.addChild(new Bitmap(new BitmapData(scr.size.x, scr.size.y, false, bgColor)));
    main.addChild(baseSprite);
    mse = new Mse;
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
    bd.fillRect(bd.rect, bgColor);
    updateGame();
    updateActors(Msg.s);
    bd.unlock();
    blurBd.lock();
    blurBd.fillRect(blurBd.rect, bgColor);
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
const TITLE:String = "formula"
const DEBUG:Boolean = false;
function initialize():void {
    setBg();
    initializeFormulaStr();
    graphTop = new Graph;
    graphTop.isTop = true;
    graphTop.initialize();
    graphBottom = new Graph;
    graphBottom.initialize();
    player = new Player;
    addFormulas();
}
function update():void {
    if (ticks == 1) Msg.addOnce("Hold mouse button to go up", new Vct(100, 150));
    drawBg();
    graphTop.update();
    graphBottom.update();
    drawFormulaStr();
    player.uptate();
    if (isInGame) updateActors(formulas);
}
var bgShp:Shp;
function setBg():void {
    var c:Clr = new Clr;
    c.rgb = Clr.white;
    c.brightness = 0.5;
    bgShp = new Shp().line(c).
        m(0, scr.center.y).l(scr.size.x, scr.center.y).
        m(scr.center.x, 0).l(scr.center.x, scr.size.y);
}
function drawBg():void {
    bgShp.draw();
    scr.drawText("0", scr.center.x + 10, scr.center.y + 10, 0x888888);
    scr.drawText("-PI", 10, scr.center.y + 10, 0x888888);
    scr.drawText("PI", scr.size.x - 10, scr.center.y + 10, 0x888888);
}
var graphTop:Graph;
var graphBottom:Graph;
class Graph {
    public const POINT_COUNT:int = 16;
    public const POINT_INTERVAL:Number = scr.size.x / POINT_COUNT;
    public var formulas:Vector.<int> = new Vector.<int>;
    public var vs:Vector.<Number> = new Vector.<Number>(POINT_COUNT + 1);
    public var pvs:Vector.<Number> = new Vector.<Number>(POINT_COUNT + 1);
    public var ys:Vector.<Number> = new Vector.<Number>(POINT_COUNT + 1);
    public var shp:Shp = new Shp;
    public var isTop:Boolean;
    public var y:Number, ty:Number;
    public var cr:Number = 0;
    public var str:String;
    public function initialize():void {
        if (isTop) ty = scr.size.y * 0.2;
        else ty = scr.size.y * 0.8;
        y = ty;
        formulas.push(1);
        calcPoints();
        setPoints();
    }
    public function calcPoints():void {
        var a:Number = -PI;
        for (var i:int = 0; i <= POINT_COUNT; i++, a += PI2 / POINT_COUNT) {
            var v:Number = 1, pv:Number;
            for each (var f:int in formulas) {
                pv = v;
                switch (f) {
                    case 0: v *= sin(a); break;
                    case 1: v *= cos(a); break;
                    case 2: v ^= 2; break;
                    case 3: v += 1; break;
                    case 4: v -= 1; break;
                    case 5: v *= 2; break;
                    case 6: v /= 2; break;
                }
            }
            vs[i] = v;
            pvs[i] = pv;
        }
        str = "";
        for each (f in formulas) str += formulaStrings[f];
        str = str.substr(1, str.length - 1);
        score = str.length;
    }
    public function setPoints():void {
        var x:Number = 0;
        shp.clear().fill(Clr.white);
        if (isTop) shp.m(scr.size.x, 0).l(0, 0);
        else shp.m(scr.size.x, scr.size.y).l(0, scr.size.y);
        for (var i:int = 0; i <= POINT_COUNT; i++, x += scr.size.x / POINT_COUNT) {
            var v:Number = 1;
            v = vs[i] * (1 - cr) + pvs[i] * cr;
            ys[i] = y - v * scr.center.y * 0.1;
            shp.l(x, ys[i]);
        }
    }
    public function update():void {
        if (isInGame) {
            if (cr > 0) {
                cr -= 0.05;
                y += (ty - y) * 0.1;
            } else {
                var cs:Number = 0.5 * (1 + sqrt(ticks * 0.001));
                if (isTop) y += cs;
                else y -= cs;
            }
        }
        setPoints();
        shp.draw();
    }
    public function getY(x:Number):Number {
        var xr:int = x * POINT_COUNT / scr.size.x;
        if (xr <= 0) return ys[0];
        if (xr >= POINT_COUNT) return ys[POINT_COUNT];
        var pr:Number = x / (scr.size.x / POINT_COUNT) % 1;
        return ys[xr] * (1 - pr) + ys[xr + 1] * pr;
    }
}
var textField:TextField;
var textFormat:TextFormat;
var matrix:Matrix = new Matrix;
function initializeFormulaStr():void {
    textFormat = new TextFormat("_typewriter");
    textFormat.size = 11; textFormat.bold = true;
    textFormat.color = 0;
    textField = new TextField;
    textField.defaultTextFormat = textFormat;
    textField.width = 460; textField.height = 460;
    textField.wordWrap = true;
    textField.multiline = true;
    matrix.identity();
    matrix.translate(0, 10);
}
function drawFormulaStr():void {
    textField.text = graphTop.str;
    bd.draw(textField, matrix);
}
var player:Player;
class Player extends Act {
    public const SIZE:Number = 12;
    function Player() {
        shp.fill(Clr.green).circle(SIZE);
        pos.x = 0;
        if (!isInGame) pos.x = -100;
        pos.y = scr.center.y * 0.8;
    }
    public function uptate():void {
        if (!isInGame) {
            draw()
            return;
        }
        vel.x = 3 * (1 + sqrt(ticks * 0.001));
        if (mse.isPressing) vel.y--;
        else vel.y++;
        vel.y *= 0.95;
        move();
        if (pos.x >= scr.size.x) pos.x -= scr.size.x;
        if (pos.y < graphTop.getY(pos.x) - SIZE * 2 ||
        pos.y > graphBottom.getY(pos.x) + SIZE * 2) {
            endGame();
            shp.clear().fill(Clr.red).circle(SIZE);
        }
        draw();
    }
}
var formulas:Vector.<Formula>;
var formulaStrings:Array = ["*sin", "*cos", "^2", "+1", "-1", "*2", "/2"];
class Formula {
    public var pos:Vct = new Vct;
    public var type:int;
    function Formula(oy:Number, et:int = -1) {
        pos.x = player.pos.x - rnd.n(300, 50);
        if (pos.x < 0) pos.x += scr.size.x;
        pos.x = clamp(pos.x, scr.size.x * 0.1, scr.size.x * 0.9);
        pos.y = (graphTop.getY(pos.x) + graphBottom.getY(pos.x)) / 2 + oy;
        for (var i:int = 0; i < 10; i++) {
            type = rnd.i(7);
            if (type != et) break;
        }
    }
    public function update():Boolean {
        if (pos.distance(player.pos) < 20) {
            graphTop.formulas.push(type);
            graphBottom.formulas.push(type);
            graphTop.cr = graphBottom.cr = 0;
            graphTop.calcPoints();
            graphTop.setPoints();
            graphBottom.calcPoints();
            graphBottom.setPoints();
            addFormulas();
            graphTop.cr = graphBottom.cr = 1;
            return false;
        }
        scr.drawText(formulaStrings[type], pos.x, pos.y);
        return true;
    }
}
function addFormulas():void {
    formulas = new Vector.<Formula>;
    var tf:Formula = new Formula(-rnd.n(20, 20));
    formulas.push(tf);
    var bf:Formula = new Formula(rnd.n(20, 20), tf.type);
    formulas.push(bf);
}
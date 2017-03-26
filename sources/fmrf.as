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
import flash.system.*;
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
    key = new Key;
    initialize();
    if (DEBUG) beginGame();
    else setScoreRecordViewer();
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
        matrix.identity(); matrix.translate(x - 100, y - 20);
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
    private const BRIGHTNESS:int = 20;
    public var r:int, g:int, b:int;
    public function Clr(r:int = 0, g:int = 0, b:int = 0) {
        this.r = r * BRIGHTNESS;
        this.g = g * BRIGHTNESS;
        this.b = b * BRIGHTNESS;
    }
    public function get i():uint {
        return r * 0x10000 + g * 0x100 + b;
    }
    private static var scatterdClr:Clr = new Clr;
    public function getScatterd(w:int = 64):Clr {
        scatterdClr.r = r + rnd.i(w * 2, -w);
        scatterdClr.g = g + rnd.i(w * 2, -w);
        scatterdClr.b = b + rnd.i(w * 2, -w);
        scatterdClr.normalize();
        return scatterdClr;
    }
    public function normalize():void {
        r = clamp(r, 0, 255);
        g = clamp(g, 0, 255);
        b = clamp(b, 0, 255);
    }
    public function set rgb(v:Clr):void {
        r = v.r; g = v.g; b = v.b;
    }
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
    ticks:int = 90, Clr:uint = 0xffffff):Msg {
        if (shownMessages.indexOf(text) >= 0) return null;
        shownMessages.push(text);
        return add(text, p, vx, vy, ticks, Clr);
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
var wasClicked:Boolean, wasReleased:Boolean;
var titleTicks:int;
function beginGame():void {
    /*if (Capabilities.hasIME) {
        try {
            if (IME.enabled && IME.conversionMode != IMEConversionMode.ALPHANUMERIC_HALF) {
                Msg.addOnce("You should disable the IME", new Vct(100, 400));
            }
            //IME.enabled = false;
        } catch (e:Error) {}
    }*/
    isInGame = true;
    score = 0;
    closeScoreForms();
    rnd = new Rnd;
    initialize();
}
function endGame():void {
    isInGame = false;
    wasClicked = wasReleased = false;
    ticks = 0;
    recordScore(score);
    setScoreRecordViewer();
    titleTicks = 30;
}
function updateGame():void {
    update();
    scr.drawText(String(score), scr.size.x - 40, 20);
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
    ticks++;
}
function updateActors(s:*):void {
    for (var i:int = 0; i < s.length; i++) if (!s[i].update()) s.splice(i--, 1);
}
/*
function setScoreRecordViewer():void { }
function recordScore(s:int):void { }
function closeScoreForms():void { }
//*/
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
const TITLE:String = "dimcom"
const DEBUG:Boolean = false;
var field:Shp;
var enemyAppTicks:int;
function initialize():void {
    field = new Shp().fill(Clr.blue).rect(scr.size.x, 3);
    player = new Player;
    explosions = new Vector.<Explosion>;
    enemies = new Vector.<Enemy>;
    enemyAppTicks = 0;
}
function update():void {
    field.p(scr.center).draw();
    if (isInGame) {
        player.update();
        if (ticks == 1) Msg.addOnce("Left/Right key to move", new Vct(100, 100));
        else if (ticks == 60) Msg.addOnce("[Z] key to fire", new Vct(100, 120));
    }
    if (--enemyAppTicks <= 0) {
        var e:Enemy = new Enemy();
        e.vel = rnd.n(sqrt(ticks * 0.001) + 1, 1);
        enemies.push(e);
        enemyAppTicks = rnd.i(20, 10);
    }
    updateActors(explosions);
    updateActors(enemies);
}
var enemies:Vector.<Enemy>;
class Enemy {
    public static const WIDTH:Number = 10;
    public var pos:Vct = new Vct(scr.size.x, scr.center.y);
    public var vel:Number;
    public var shp:Shp = new Shp().fill(Clr.red).rect(WIDTH, 3);
    public var isDestoryed:Boolean;
    public function update():Boolean {
        if (isDestoryed) return false;
        pos.x -= vel;
        shp.p(pos).draw();
        player.checkHit(pos.x, WIDTH);
        return true;
    }
    public function checkHit(x:Number, w:Number, m:int):void {
        if (isDestoryed) return;
        if (abs(pos.x - x) < (w + WIDTH) / 2) {
            if (isInGame) {
                Msg.add(String(m), pos, 0, -30, 30);
                score += m;
            }
            var e:Explosion = new Explosion;
            e.pos.x = pos.x;
            e.multiplier = m + 1;
            explosions.push(e);
            isDestoryed = true;
        }
    }
}
var player:Player;
class Player {
    public static const WIDTH:Number = 10;
    public var pos:Vct = new Vct(scr.size.x * 0.2, scr.center.y);
    public var shp:Shp = new Shp().fill(Clr.green).rect(WIDTH, 3);
    public var shot:Shot;
    public var isFirePressed:Boolean;
    public function update():void {
        pos.x += key.stick.x * 2;
        shp.p(pos).draw();
        if (shot) {
            if (key.isButtonPressed && !isFirePressed) {
                var e:Explosion = new Explosion;
                e.pos.x = shot.pos.x;
                explosions.push(e);
                isFirePressed = true;
                shot = null;
            } else {
                if (!shot.update()) shot = null;
            }
        } else {
            if (key.isButtonPressed && !isFirePressed) {
                shot = new Shot;
                shot.pos.x = pos.x;
                isFirePressed = true;
                Msg.addOnce("Push [Z] key again to explode", new Vct(100, 140));
            }
        }
        if (!key.isButtonPressed) isFirePressed = false;
    }
    public function checkHit(x:Number, w:Number):void {
        if (!isInGame) return;
        if (abs(pos.x - x) < (w + WIDTH) / 2) {
            var e:Explosion = new Explosion;
            e.pos.x = pos.x;
            explosions.push(e);
            endGame();
        }
    }
}
class Shot {
    public static const WIDTH:Number = 7;
    public var pos:Vct = new Vct(0, scr.center.y);
    public var shp:Shp = new Shp().fill(Clr.cyan).rect(WIDTH, 3);
    public function update():Boolean {
        pos.x += 3;
        shp.p(pos).draw();
        return scr.isIn(pos);
    }
}
var explosions:Vector.<Explosion>
class Explosion {
    public static const BASE_WIDTH:Number = 10;
    public var pos:Vct = new Vct(0, scr.center.y);
    public var shp:Shp = new Shp().fill(Clr.yellow).rect(BASE_WIDTH, 3);
    public var width:Number = 1;
    public var isSpreading:Boolean = true;
    public var multiplier:int = 1;
    public function update():Boolean {
        if (isSpreading) {
            width += 3;
            if (width > 30) isSpreading = false;
        } else {
            width -= 3;
            if (width < 1) return false;
        }
        shp.scl(width / BASE_WIDTH, 1).p(pos).draw();
        player.checkHit(pos.x, width);
        for each (var e:Enemy in enemies) e.checkHit(pos.x, width, multiplier);
        return true;
    }
}
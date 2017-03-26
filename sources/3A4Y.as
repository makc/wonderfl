package {
    import flash.display.Sprite;
    [SWF(width="465", height="465", backgroundColor="0", frameRate="30")]
    public class Main extends Sprite {
        public const WIDTH:int = 465, HEIGHT:int = 465;
        public function Main() { main = this; initializeFirst(); }
    }
}
class Actor {
    public static function update(s:*):void {
        for (var i:int = 0; i < s.length; i++) if (!updateActor(s[i])) s.splice(i--, 1);
    }
    public static function updateActor(a:*):Boolean {
        var f:Boolean = a.update();
        a.moveAndDraw();
        return f;
    }
    public var pos:Vec = new Vec, vel:Vec = new Vec;
    public var shape:Paper, isVAngleShape:Boolean = false;
    public function moveAndDraw():void {
        pos.incrementBy(vel);
        if (shape) {
            if (isChangingShape) shape.create();
            if (isVAngleShape) shape.angle = vangle;
            shape.draw(pos);
        }
    }
    public function get vangle():Number { return atan2(vel.x, vel.y); }
    public function get vspeed():Number { return vel.length; }
}
//----------------------------------------------------------------
const TITLE:String = "carpieces";
const DEBUG:Boolean = false;
function initialize():void {
    cars = new Vector.<Car>;
    addCar(0.5, 0.7, 25);
    addCar(0.25, 0.8, 15);
    addCar(0.75, 0.8, 15);
    trees = new Vector.<Tree>;
    treeAppDist = 0;
}
function addCar(x:Number, y:Number, s:Number):void {
    var c:Car = new Car;
    c.pos.x = screen.size.x * x; c.pos.y = screen.size.y * y;
    c.size = s;
    cars.push(c);
}
var treeAppDist:int;
var scrollSpeed:Number;
function update():void {
    scrollSpeed = 3 + ticks * 0.003;
    treeAppDist -= scrollSpeed;
    if (--treeAppDist <= 0) {
        trees.push(new Tree);
        treeAppDist = rand.n(30, 90);
    }
    Actor.update(trees);
    if (isInGame) {
        Actor.update(cars);
        if (cars.length <= 0) endGame();
    }
}
var cars:Vector.<Car>;
class Car extends Actor {
    public var angle:Number = 0, size:Number;
    function Car() {
        shape = new Paper(30).
        transform(0, 0, 0.3, 0.8).color(Color.blue).tri().
        transform(-0.7, 0.7, 0.2, 0.3).color(Color.black).box().
        transform(0.7, 0.7, 0.2, 0.3).color(Color.black).box().
        transform(-0.8, -0.7, 0.3, 0.4).color(Color.black).box().
        transform(0.8, -0.7, 0.3, 0.4).color(Color.black).box().create();
    }
    private var mv:Vec = new Vec;
    public function update():Boolean {
        if (shape.isCrashed) {
            pos.y += scrollSpeed;
            return pos.y < screen.size.y + size;
        }
        var d:Number = mouse.pos.distance(pos) - size;
        if (d < 5) d = 5;
        var mr:Number = 1 / d;
        mv.xy = mouse.pos; mv.decrementBy(pos);
        mv.scaleBy(mr * 0.5);
        vel.incrementBy(mv);
        for each (var c:Car in cars) {
            if (c != this && !c.shape.isCrashed && c.pos.distance(pos) < c.size + size) {
                vel.addAngle(c.pos.angle(pos), 100 / size);
            }
        }
        if ((pos.x < 0 && vel.x < 0) || (pos.x > screen.size.x && vel.x > 0)) vel.x *= -1;
        if ((pos.y < 0 && vel.y < 0) || (pos.y > screen.size.y && vel.y > 0)) vel.y *= -1;
        vel.scaleBy(0.9);
        angle += (vel.x * 0.1 - angle) * 0.1;
        shape.angle = angle + PI;
        size += 0.03;
        shape.scale = size / (shape.size.x / 2);
        if (ticks % 30 == 0) {
            var s:int = size;
            Message.add(String(s), pos, 0, -100, 20);
            score += s;
        }
        for each (var t:Tree in trees) {
            if (!t.shape.isCrashed && t.pos.distance(pos) < (t.size + size) / 2) {
                if (t.size * 0.7 > size) {
                    shape.crash();
                    vel.clear();
                    break;
                } else {
                    t.shape.crash();
                    c = new Car;
                    c.pos.xy = pos; c.size = size / 2;
                    c.vel.addAngle(rand.n(PI * 2), 10);
                    vel.x -= c.vel.x; vel.y -= c.vel.y;
                    cars.push(c);
                    size /= 2;
                    break;
                }
            }
        }
        return true;
    }
}
var trees:Vector.<Tree>;
class Tree extends Actor {
    public var size:Number;
    function Tree() {
        shape = new Paper(30).
        transform(0, 0, 0.5, 0.5).color(Color.magenta).box().
        transform(0, -0.5, 1, 0.4, PI).color(Color.green).tri().
        transform(0, -1, 1, 0.4, PI).color(Color.green).tri().create();
        size = rand.i(20, 10);
        if (rand.i(7) == 0) size *= 2;
        if (rand.i(7) == 0) size *= 2;
        shape.scale = size / (shape.size.x / 2);
        pos.x = rand.sx(); pos.y = -size;
    }
    public function update():Boolean {
        pos.y += scrollSpeed;
        return pos.y < screen.size.y + size;
    }
}
//----------------------------------------------------------------
import flash.display.*;
import flash.geom.*;
import flash.filters.*;
import flash.events.*;
import flash.text.*;
import flash.utils.getTimer;
var screen:Screen;
var mouse:Mouse;
var main:Main, bd:BitmapData;
var baseSprite:Sprite;
function initializeFirst():void {
    screen = new Screen;
    bd = new BitmapData(screen.size.x, screen.size.y, false);
    baseSprite = new Sprite;
    baseSprite.addChild(new Bitmap(bd));
    main.addChild(baseSprite);
    mouse = new Mouse(main.stage);
    initialize();
    if (DEBUG) beginGame();
    else setScoreRecordViewer();
    main.addEventListener(Event.ENTER_FRAME, updateFrame);
}
var zeroPoint:Point = new Point;
var backColor:Color = new Color;
var isChangingShape:Boolean, isChangingTicks:int;
function updateFrame(event:Event):void {
    if (--isChangingTicks <= 0) {
        backColor.rgb = Color.back.getScatterd(8);
        isChangingShape = true;
        isChangingTicks = 30;
    } else {
        isChangingShape = false;
    }
    bd.lock();
    bd.fillRect(bd.rect, backColor.i);
    updateGame();
    Actor.update(Message.s);
    bd.unlock();
}
var score:int, ticks:int;
var isInGame:Boolean;
var wasClicked:Boolean, wasReleased:Boolean;
function beginGame():void {
    isInGame = true;
    score = 0;
    closeScoreForms();
    initialize();
}
function endGame():void {
    isInGame = false;
    wasClicked = wasReleased = false;
    ticks = 0;
    recordScore(score);
    setScoreRecordViewer();
}
function updateGame():void {
    update();
    screen.drawText(String(score), screen.size.x - 40, 20);
    if (!isInGame) {
        screen.drawText(TITLE, screen.size.x * 0.7, screen.center.y - 20);
        screen.drawText("click to start", screen.size.x * 0.7, screen.center.y + 20);
        if (mouse.isPressing) {
            if (wasReleased) wasClicked = true;
        } else {
            if (wasClicked) beginGame();
            wasReleased = true;
        }
        return;
    }
    ticks++;
}
class Vec extends Vector3D {
    public function Vec(x:Number = 0, y:Number = 0) {
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
}
class Color {
    public var r:int, g:int, b:int;
    public function Color(r:int = 0, g:int = 0, b:int = 0) {
        this.r = r * 22;
        this.g = g * 22;
        this.b = b * 22;
    }
    public function get i():uint {
        return r * 0x10000 + g * 0x100 + b;
    }
    private static var scatterdColor:Color = new Color;
    public function getScatterd(w:int = 16):Color {
        var sc:int = rand.i(w * 2, -w)
        scatterdColor.r = r + sc;
        scatterdColor.g = g + sc;
        scatterdColor.b = b + sc;
        scatterdColor.normalize();
        return scatterdColor;
    }
    private static var whitenedColor:Color = new Color;
    public function getWhitened(w:int = 80):Color {
        whitenedColor.r = r + w;
        whitenedColor.g = g + w;
        whitenedColor.b = b + w;
        whitenedColor.normalize();
        return whitenedColor;
    }
    public function normalize():void {
        r = clamp(r, 0, 255);
        g = clamp(g, 0, 255);
        b = clamp(b, 0, 255);
    }
    public function set rgb(v:Color):void {
        r = v.r; g = v.g; b = v.b;
    }
    private static const WHITENESS:int = 5;
    public static var black:Color = new Color(WHITENESS, WHITENESS, WHITENESS);
    public static var red:Color = new Color(10, WHITENESS, WHITENESS);
    public static var green:Color = new Color(WHITENESS, 10, WHITENESS);
    public static var blue:Color = new Color(WHITENESS, WHITENESS, 10);
    public static var yellow:Color = new Color(10, 10, WHITENESS);
    public static var magenta:Color = new Color(10, WHITENESS, 10);
    public static var cyan:Color = new Color(WHITENESS, 10, 10);
    public static var white:Color = new Color(10, 10, 10);
    public static var back:Color = new Color(10, 10, 8);
}
class Paper {
    private static var filter:DropShadowFilter = new DropShadowFilter(5, 45, 0, 0.5, 10, 10);
    private static var weakFilter:DropShadowFilter = new DropShadowFilter(3, 45, 0, 0.3, 5, 5);
    public var shape:Shape, g:Graphics;
    public var colors:Vector.<Color> = new Vector.<Color>;
    public var points:Vector.<Vector.<Vec>> = new Vector.<Vector.<Vec>>;
    public var size:Vec = new Vec;
    public var angle:Number = 0, scale:Number = 1;
    public var lineWidth:int = 2;
    public var isCrashed:Boolean;
    public function Paper(width:Number = 0, height:Number = 0) {
        if (height <= 0) height = width;
        size.x = width; size.y = height;
        shape = new Shape;
        shape.filters = [filter];
        g = shape.graphics;
    }
    private var currentPoints:Vector.<Vec>;
    public function color(c:Color):Paper {
        colors.push(c);
        currentPoints = new Vector.<Vec>;
        points.push(currentPoints);
        return this;
    }
    private var transPos:Vec = new Vec, transSize:Vec = new Vec(1, 1);
    private var transAngle:Number = 0;
    public function transform(x:Number, y:Number, w:Number, h:Number, a:Number = 0):Paper {
        transPos.x = x; transPos.y = y;
        transSize.x = w; transSize.y = h;
        transAngle = a;
        return this;
    }
    public function tri():Paper {
        addPoint(0, 1); addPoint(1, -1); addPoint(-1, -1);
        return this;
    }
    public function box():Paper {
        addPoint(-1, 1); addPoint(1, 1); addPoint(1, -1); addPoint(-1, -1);
        return this;
    }
    public function cross():Paper {
        addPoint(-0.8, -1); addPoint(1, 0.8); addPoint(0.8, 1); addPoint(1, -0.8);
        color(colors[colors.length - 1]);
        addPoint(0.8, -1); addPoint(-1, 0.8); addPoint(-0.8, 1); addPoint(1, -0.8);
        return this;
    }
    public function circle():Paper {
        for (var i:int = 0, a:Number = 0; i < 8 ; i++, a += PI / 4 ) {
            addPoint(sin(a), cos(a));
        }
        return this;
    }
    private function addPoint(rx:Number, ry:Number):void {
        var p:Vec = new Vec(rx, ry);
        p.rotate(transAngle);
        p.x *= transSize.x;
        p.y *= transSize.y;
        p.incrementBy(transPos);
        p.x *= size.x / 2;
        p.y *= size.y / 2;
        if (currentPoints.length > 0) {
            var pp:Vec = new Vec;
            pp.xy = currentPoints[currentPoints.length - 1];
            var c:int = p.distance(pp) / 20;
            if (c > 0) {
                var v:Vec = new Vec(p.x - pp.x, p.y - pp.y);
                v.scaleBy(1 / (c + 1));
                for (var i:int = 0; i < c; i++) {
                    pp.incrementBy(v);
                    currentPoints.push(new Vec(pp.x, pp.y));
                }
            }
        }
        currentPoints.push(p);
    }
    public function create():Paper {
        g.clear();
        if (isCrashed) g.lineStyle(lineWidth, 0xbbbbbb);
        else g.lineStyle(lineWidth, 0xffffff);
        var dp:Number = 3;
        if (isCrashed) dp *= 2;
        for (var i:int = 0; i < colors.length; i++) {
            if (isCrashed) g.beginFill(colors[i].getScatterd().getWhitened().i);
            else g.beginFill(colors[i].getScatterd().i);
            var ps:Vector.<Vec> = points[i];
            var sx:Number = ps[0].x + rand.n(dp, -dp / 2);
            var sy:Number = ps[0].y + rand.n(dp, -dp / 2);
            g.moveTo(sx, sy);
            for (var j:int = 1; j < ps.length; j++) {
                g.lineTo(ps[j].x + rand.n(dp, -dp / 2), ps[j].y + rand.n(dp, -dp / 2));
            }
            g.lineTo(sx, sy);
            g.endFill();
        }
        return this;
    }
    public function crash():void {
        isCrashed = true;
        angle += rand.n(0.5, 0.5) * rand.pm();
        shape.filters = [weakFilter];
        create();
    }
    private var matrix:Matrix = new Matrix;
    public function draw(pos:Vec):void {
        matrix.identity();
        matrix.rotate(angle);
        matrix.scale(scale, scale);
        matrix.translate(pos.x, pos.y);
        bd.draw(shape, matrix);
    }
}
class Message extends Actor {
    public static var s:Vector.<Message> = new Vector.<Message>;
    public static var shownMessages:Vector.<String> = new Vector.<String>;
    public static function addOnce(text:String, p:Vec, vx:Number = 0, vy:Number = 0,
    ticks:int = 90):Message {
        if (shownMessages.indexOf(text) >= 0) return null;
        shownMessages.push(text);
        return add(text, p, vx, vy, ticks);
    }
    public static function add(text:String, p:Vec, vx:Number = 0, vy:Number = 0,
    ticks:int = 90):Message {
        var m:Message = new Message;
        m.text = text;
        m.pos.xy = p;
        m.vel.x = vx; m.vel.y = vy / ticks;
        m.ticks = ticks;
        s.push(m);
        return m;
    }
    public var text:String, ticks:int;
    public function update():Boolean {
        screen.drawText(text, pos.x, pos.y);
        return --ticks > 0;
    }
}
class Screen {
    public var size:Vec = new Vec(main.WIDTH, main.HEIGHT);
    public var center:Vec = new Vec(size.x / 2, size.y / 2);
    private var textField:TextField = new TextField;
    private var matrix:Matrix = new Matrix;
    public function Screen() {
        var fm:TextFormat = new TextFormat("_typewriter");
        fm.size = 11; fm.color = 0; fm.bold = true;
        fm.align = TextFormatAlign.CENTER;
        textField.defaultTextFormat = fm;
        textField.width = 200; textField.height = 20;
    }
    public function drawText(text:String, x:int, y:int):void {
        textField.text = text;
        matrix.identity(); matrix.translate(x - 100, y - 20);
        bd.draw(textField, matrix);
    }
    public function isIn(p:Vector3D, spacing:Number = 0):Boolean {
        return (p.x >= -spacing && p.x <= size.x + spacing && 
            p.y >= -spacing && p.y <= size.y + spacing);
    }
    private var rectForFill:Rectangle = new Rectangle;
    public function fillRect
    (x:Number, y:Number, width:Number, height:Number, color:uint):void {
        rectForFill.x = x - width / 2; rectForFill.y = y - height / 2;
        rectForFill.width = width; rectForFill.height = height;
        bd.fillRect(rectForFill, color);
    }        
}
class Mouse {
    public var pos:Vec = new Vec;
    public var isPressing:Boolean;
    public function Mouse(stage:Stage) {
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
var rand:Rand = new Rand(int.MIN_VALUE);
class Rand {
    public function n(v:Number = 1, s:Number = 0):Number { return get() * v + s; }
    public function i(v:int, s:int = 0):int { return n(v, s); }
    public function sx(v:Number = 1, s:Number = 0):Number { return n(v, s) * screen.size.x; }
    public function sy(v:Number = 1, s:Number = 0):Number { return n(v, s) * screen.size.y; }
    public function pm():int { return i(2) * 2 - 1; }
    private var xorShiftX:int, xorShiftY:int, xorShiftZ:int, xorShiftW:int;
    function Rand(v:int = int.MIN_VALUE):void {
        var sv:int;
        if (v == int.MIN_VALUE) sv = getTimer();
        else sv = v;
        xorShiftX = sv = 1812433253 * (sv ^ (sv >> 30));
        xorShiftY = sv = 1812433253 * (sv ^ (sv >> 30)) + 1;
        xorShiftZ = sv = 1812433253 * (sv ^ (sv >> 30)) + 2;
        xorShiftW = sv = 1812433253 * (sv ^ (sv >> 30)) + 3;
    }
    public function get():Number {
        var t:int = xorShiftX ^ (xorShiftX << 11);
        xorShiftX = xorShiftY; xorShiftY = xorShiftZ; xorShiftZ = xorShiftW;
        xorShiftW = (xorShiftW ^ (xorShiftW >> 19)) ^ (t ^ (t >> 8));
        return Number(xorShiftW) / int.MAX_VALUE;
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
var sin:Function = Math.sin, cos:Function = Math.cos, atan2:Function = Math.atan2; 
var sqrt:Function = Math.sqrt, abs:Function = Math.abs;
var PI:Number = Math.PI, PI2:Number = PI * 2;
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
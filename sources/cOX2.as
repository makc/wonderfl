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
        a.moveAndDraw();
        return a.update();
    }
    public var pos:Vec = new Vec, vel:Vec = new Vec;
    public var shape:Polyline, isAngleChanging:Boolean = false;
    public function trail(intensity:Number = 3):void {
        Particle.add(pos, shape.color, intensity, 0.2 * intensity, atan2(vel.x, vel.y) + PI);
    }
    public function explode(intensity:Number = 20):void {
        Particle.add(pos, shape.color, intensity);
    }
    private function moveAndDraw():void {
        pos.incrementBy(vel);
        if (shape) {
            if (isAngleChanging) shape.angle = angle;
            shape.draw(pos);
        }
    }
    public function get angle():Number { return atan2(vel.x, vel.y); }
    public function get speed():Number { return vel.length; }
}
//----------------------------------------------------------------
var score:int, ticks:int;
function initialize():void {
    boxed = new Boxed;
    Item.initialize();
}
function start():void {
    score = 0;
    ball = new Ball;
    initialize();
}
function update():void {
    boxed.update();
    Item.update();
    if (ball) {
        Actor.updateActor(ball);
    } else {
        sc.drawText("boxed", sc.center.x, sc.center.y - 10);
        sc.drawText("click to start", sc.center.x, sc.center.y + 10);
        ticks = 0;
        if (mouse.isClicked) start();
    }
    sc.drawText(String(score), 20, 20);
    ticks++;
}
var ball:Ball;
class Ball extends Actor {
    function Ball() {
        shape = new Polyline(5, 15).tri().clr(Color.cyan);
        isAngleChanging = true;
        pos.xy = sc.center;
        vel.addAngle(0.5, 5);
    }
    public function update():Boolean {
        boxed.checkHit(pos, vel);
        trail(5);
        return true;
    }
}
var boxed:Boxed;
class Boxed {
    public var walls:Vector.<Wall> = new Vector.<Wall>(4);
    public var size:Vec = new Vec(150, 150);
    public var pos:Vec = new Vec, vel:Vec = new Vec, velTicks:int = 0;
    private var message:Message;
    function Boxed() {
        for (var i:int = 0; i < 4; i++) walls[i] = new Wall;
        setOffsets();
        if (ball) message = Message.addOnce("mouse: move a box", sc.center);
    }
    private function setOffsets():void {
        walls[0].setOffset(-Wall.SIZE / 2 + size.x / 2, -Wall.SIZE / 2 - size.y / 2);
        walls[1].setOffset(Wall.SIZE / 2 + size.x / 2, -Wall.SIZE / 2 + size.y / 2);
        walls[2].setOffset(Wall.SIZE / 2 - size.x / 2, Wall.SIZE / 2 + size.y / 2);
        walls[3].setOffset(-Wall.SIZE / 2 - size.x / 2, Wall.SIZE / 2 - size.y / 2);
    }
    public function update():void {
        if (--velTicks <= 0) {
            vel.clear();
            velTicks = rand.i(60, 30);
            if (rand.i(2) == 0) {
                vel.x = rand.pm();
                var sx:Number = size.x + vel.x * velTicks;
                if (sx > 300 || sx < 50) velTicks = vel.x = 0;
            } else {
                vel.y = rand.pm();
                var sy:Number = size.y + vel.y * velTicks;
                if (sy > 300 || sy < 50) velTicks = vel.x = 0;
            }
        } else {
            size.incrementBy(vel);
            setOffsets();
        }
        pos.xy = mouse.pos;
        if (message) message.pos.xy = pos;
        for each (var w:Wall in walls) w.setPos(pos);
        Actor.update(walls);
    }
    public function checkHit(p:Vec, v:Vec):void {
        var x1:Number = pos.x - size.x / 2, x2:Number = pos.x + size.x / 2;
        var y1:Number = pos.y - size.y / 2, y2:Number = pos.y + size.y / 2;
        if ((p.x < x1 && v.x < 0) || (p.x > x2 && v.x > 0)) v.x = -v.x;
        if ((p.y < y1 && v.y < 0) || (p.y > y2 && v.y > 0)) v.y = -v.y;
        p.x = clamp(p.x, x1, x2);
        p.y = clamp(p.y, y1, y2);
    }
}
class Wall extends Actor {
    public static const SIZE:Number = 400;
    private var offset:Vec = new Vec;
    function Wall() {
        shape = new Polyline(SIZE).box().clr(Color.green);
    }
    public function setOffset(x:Number, y:Number):void {
        offset.x = x; offset.y = y;
    }
    public function setPos(p:Vec):void {
        pos.x = p.x + offset.x;
        pos.y = p.y + offset.y;
    }
    public function update():Boolean { return true; }
}
class Item extends Actor {
    public static var s:Vector.<Item>;
    public static var scroll:Vec;
    public static var angle:Number, speed:Number;
    public static var vangle:Number, vspeed:Number;
    public static var appTicks:int, velTicks:int;
    public static function initialize():void {
        s = new Vector.<Item>;
        scroll = new Vec;
        angle = rand.n(PI2); speed = 3;
        vangle = vspeed = 0;
        scroll.addAngle(angle, speed);
        appTicks = velTicks = 0;
    }
    public static function update():void {
        if (--appTicks <= 0) {
            var i:Item = new Item;
            i.pos.xy = sc.center;
            i.pos.addAngle(angle + rand.n(PI / 2, PI / 4 * 3), sc.size.x);
            s.push(i);
            var t:int = 20 / sqrt(ticks * 0.003 + 1);
            appTicks = rand.i(t, t);
        }
        if (--velTicks <= 0) {
            velTicks = rand.n(90, 30);
            vangle = rand.n(0.04, -0.02);
            vspeed = rand.n(0.2, -0.1);
            var ns:Number = speed + vspeed * velTicks;
            if (ns < 1 || ns > 20) vangle = vspeed = velTicks = 0;
        }
        angle += vangle; speed + vspeed;
        scroll.clear();
        scroll.addAngle(angle, speed);
        Actor.update(s);
    }
    public var isBonus:Boolean;
    public var message:Message, isInFirst:Boolean;
    function Item() {
        if (rand.i(2) == 0) {
            shape = new Polyline(20).box().clr(Color.yellow);
            shape.angle = PI / 4;
            isBonus = true;
        } else {
            shape = new Polyline(15).cross().clr(Color.red);
        }
    }
    public function update():Boolean {
        vel.xy = scroll;
        trail();
        if (ball) {
            if (isBonus) {
                if (pos.distance(ball.pos) < 30) {
                    var a:Number = ball.pos.angle(pos) - ball.angle;
                    a = ball.angle + PI + a * 2;
                    var s:Number = ball.speed;
                    ball.vel.clear(); ball.vel.addAngle(a, s);
                    explode();
                    score++;
                    return false;
                }
            } else {
                if (pos.distance(ball.pos) < 15) {
                    ball.explode(50);
                    ball = null;
                }
            }
            if (!isInFirst && sc.isIn(pos, -50)) {
                isInFirst = true;
                if (isBonus) message = Message.addOnce("get a bonus", pos);
                else message = Message.addOnce("avoid a spike", pos);
            }
            if (message) message.pos.xy = pos;
        }
        return sc.isIn(pos, sc.size.x);
    }
}
//----------------------------------------------------------------
import flash.display.*;
import flash.geom.*;
import flash.filters.*;
import flash.events.*;
import flash.text.*;
var main:Main, bd:BitmapData, blurBd:BitmapData;
var backBd:BitmapData;
var blurFilter:BlurFilter;
var sc:Screen;
var mouse:Mouse;
function initializeFirst():void {
    sc = new Screen;
    bd = new BitmapData(sc.size.x, sc.size.y);
    blurBd = new BitmapData(sc.size.x, sc.size.y);
    backBd = new BitmapData(sc.size.x, sc.size.y, false);
    backBd.fillRect(backBd.rect, 0xff000000);
    main.addChild(new Bitmap(backBd));
    blurFilter = new BlurFilter(5, 5);
    main.addChild(new Bitmap(blurBd));
    mouse = new Mouse(main.stage);
    initialize();
    main.addEventListener(Event.ENTER_FRAME, updateFrame);
}
// Update a frame.
var zeroPoint:Point = new Point;
function updateFrame(event:Event):void {
    bd.lock();
    bd.fillRect(bd.rect, 0);
    update();
    Actor.update(Particle.s);
    Actor.update(Message.s);
    bd.unlock();
    blurBd.lock();
    blurBd.copyPixels(bd, bd.rect, zeroPoint);
    blurBd.applyFilter(blurBd, blurBd.rect, zeroPoint, blurFilter);
    blurBd.copyPixels(bd, bd.rect, zeroPoint, null, null, true);
    blurBd.unlock();
}
class Vec extends Vector3D {
    public function Vec(x:Number = 0, y:Number = 0) {
        super(x, y);
    }
    public function clear():void {
        x = y = 0;
    }
    public function distance(p:Vector3D):Number {
        return getLength(x - p.x, y - p.y);
    }
    public function angle(p:Vector3D):Number {
        return atan2(x - p.x, y - p.y);
    }
    public function addAngle(a:Number, s:Number):void {
        x += sin(a) * s; y += cos(a) * s;
    }
    public function set xy(v:Vector3D):void {
        x = v.x; y = v.y;
    }
}
class Color {
    private static var scatterdColor:Color = new Color;
    public var r:int, g:int, b:int;
    public function Color(r:int = 0, g:int = 0, b:int = 0) {
        this.r = r * 20;
        this.g = g * 20;
        this.b = b * 20;
    }
    public function get i():uint {
        return 0xff000000 + r * 0x10000 + g * 0x100 + b;
    }
    public function getScatterd(w:int = 64):Color {
        scatterdColor.r = r + rand.i(w * 2, -w);
        scatterdColor.g = g + rand.i(w * 2, -w);
        scatterdColor.b = b + rand.i(w * 2, -w);
        scatterdColor.normalize();
        return scatterdColor;
    }
    public function normalize():void {
        r = clamp(r, 0, 255);
        g = clamp(g, 0, 255);
        b = clamp(b, 0, 255);
    }
    private static const WHITENESS:int = 1;
    public static var red:Color = new Color(10, WHITENESS, WHITENESS);
    public static var green:Color = new Color(WHITENESS, 10, WHITENESS);
    public static var blue:Color = new Color(WHITENESS, WHITENESS, 10);
    public static var yellow:Color = new Color(10, 10, WHITENESS);
    public static var magenta:Color = new Color(10, WHITENESS, 10);
    public static var cyan:Color = new Color(WHITENESS, 10, 10);
    public static var white:Color = new Color(10, 10, 10);
}
class Polyline {
    public static const LINE_WIDTH:Number = 1;
    public var color:Color;
    public var pointAngles:Vector.<Number> = new Vector.<Number>;
    public var pointDists:Vector.<Number> = new Vector.<Number>;
    public var angle:Number = 0, scale:Number = 1;
    public var size:Vec = new Vec;
    public function Polyline(width:Number, height:Number = 0) {
        if (height <= 0) height = width;
        size.x = width; size.y = height;
    }
    public function clr(c:Color):Polyline {
        color = c;
        return this;
    }
    public function tri():Polyline {
        addPoint(0, 1); addPoint(1, -1, true); addPoint(-1, -1, true); addPoint(0, 1);
        return this;
    }
    public function box():Polyline {
        addPoint(-1, 1); addPoint(1, 1, true);
        addPoint(1, -1, true); addPoint(-1, -1, true); addPoint(-1, 1);
        return this;
    }
    public function cross():Polyline {
        addPoint(-1, -1); addPoint(1, 1);
        addPoint(1, -1); addPoint(-1, 1);
        return this;
    }
    private function addPoint(rx:Number, ry:Number, isMid:Boolean = false):void {
        var x:Number = rx * size.x / 2, y:Number = ry * size. y / 2;
        var a:Number = atan2(x, y), d:Number = sqrt(x * x + y * y);
        pointAngles.push(a); pointDists.push(d);
        if (isMid) { pointAngles.push(a); pointDists.push(d); }
    }
    private static var p1:Vec = new Vec, p2:Vec = new Vec;
    private static var clw:Color = new Color;
    public function draw(pos:Vec):void {
        var size:Number = LINE_WIDTH * scale;
        if (size < 1) size = 1;
        drawLines(pos, color.i, size * 2);
        clw.r = color.r * 4; clw.g = color.g * 4; clw.b = color.b * 4;
        clw.normalize();
        drawLines(pos, clw.i, size);
    }
    public function drawLines(pos:Vec, cl:uint, size:int):void {
        for (var i:int = pointAngles.length - 2; i >= 0; i -= 2) {
            p1.xy = pos;
            p1.addAngle(angle + pointAngles[i], pointDists[i] * scale);
            p2.xy = pos;
            p2.addAngle(angle + pointAngles[i + 1], pointDists[i + 1] * scale);
            drawLine(p1, p2, cl, size);
        }
    }
    public static var v:Vec = new Vec, rect:Rectangle = new Rectangle;
    public static function drawLine(p1:Vec, p2:Vec, cl:uint, size:int):void {
        v.x = p2.x - p1.x; v.y = p2.y - p1.y;
        var c:int = Math.max(abs(v.x), abs(v.y));
        v.scaleBy(1 / c);
        rect.width = rect.height = size;
        var lx:Number = p1.x - size / 2, ly:Number = p1.y - size / 2;
        v.scaleBy(size);
        c /= size;
        var vx:Number = v.x, vy:Number = v.y;
        for (var i:int = c; i >= 0; i--) {
            rect.x = lx; rect.y = ly;
            bd.fillRect(rect, cl);
            lx += vx; ly += vy;
        }
    }
}
class Particle extends Actor {
    public static var s:Vector.<Particle> = new Vector.<Particle>;
    public static function add(pos:Vector3D, color:Color, intensity:Number,
    arc:Number = Math.PI * 2, angle:Number = 0):void {
        var n:int = intensity * arc;
        for (var i:int = 0; i < n; i++) {
            var p:Particle = new Particle;
            p.pos.xy = pos;
            p.vel.addAngle(angle + rand.n(arc, -arc / 2), intensity * rand.n(1));
            p.size = intensity * rand.n(0.2, 0.2) + 1;
            var sc:Color = color.getScatterd();
            p.icolor = sc.i;
            s.push(p);
        }
    }
    public var size:Number, attenuation:Number = 0.96;
    public var icolor:uint;
    private static var rect:Rectangle = new Rectangle;
    public function update():Boolean {
        size *= attenuation;
        rect.x = pos.x - size / 2; rect.y = pos.y - size / 2;
        rect.width = rect.height = clamp(size, 1, 2);
        bd.fillRect(rect, icolor);
        return sc.isIn(pos) && size >= 1.0;
    }
}
class Message extends Actor {
    public static var s:Vector.<Message> = new Vector.<Message>;
    public static var shownMessages:Vector.<String> = new Vector.<String>;
    public static function addOnce(s:String, p:Vec, vx:Number = 0, vy:Number = 0,
    ticks:int = 90):Message {
        if (shownMessages.indexOf(s) >= 0) return null;
        shownMessages.push(s);
        return add(s, p, vx, vy, ticks);
    }
    public static function add(text:String, p:Vec, vx:Number = 0, vy:Number = 0,
    ticks:int = 90):Message {
        var m:Message = new Message;
        m.text = text;
        m.pos.xy = p;
        m.vel.x = vx; m.vel.y = vy;
        m.ticks = ticks;
        s.push(m);
        return m;
    }
    public var text:String, ticks:int;
    public function update():Boolean {
        sc.drawText(text, pos.x, pos.y);
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
        fm.size = 11; fm.color = 0xffffffff; fm.align = TextFormatAlign.CENTER;
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
}
class Mouse {
    public var pos:Vec = new Vec;
    public var isPressed:Boolean, _isClicked:Boolean;
    public function Mouse(stage:Stage) {
        stage.addEventListener(MouseEvent.MOUSE_MOVE, onMoved);
        stage.addEventListener(MouseEvent.MOUSE_DOWN, onPressed);
        stage.addEventListener(MouseEvent.MOUSE_UP, onReleased);
        stage.addEventListener(Event.MOUSE_LEAVE, onReleased);
    }
    private function onMoved(e:MouseEvent):void {
        pos.x = e.stageX; pos.y = e.stageY;
    }
    private function onPressed(e:MouseEvent):void {
        isPressed = _isClicked = true; onMoved(e);
    }
    private function onReleased(e:Event):void {
        isPressed = false;
    }
    public function get isClicked():Boolean {
        if (!_isClicked) return false;
        _isClicked = false;
        return true;
    }
}
var rand:Rand = new Rand;
class Rand {
    public function n(v:Number = 1, s:Number = 0):Number { return Math.random() * v + s; }
    public function i(v:int, s:int = 0):int { return n(v, s); }
    public function sx(v:Number, s:Number = 0):Number { return n(v, s) * sc.size.x; }
    public function sy(v:Number, s:Number = 0):Number { return n(v, s) * sc.size.y; }
    public function pm():int { return i(2) * 2 - 1; }
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
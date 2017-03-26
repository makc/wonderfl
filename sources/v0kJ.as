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
    public var shape:Polyline, isVAngleShape:Boolean = false;
    public function trail(intensity:Number = 3):void {
        Particle.add(pos, shape.color, 64, intensity, 0.2 * intensity, vangle + PI);
    }
    public function explode(intensity:Number = 20):void {
        Particle.add(pos, shape.color, 128, intensity);
    }
    private function moveAndDraw():void {
        pos.incrementBy(vel);
        if (shape) {
            if (isVAngleShape) shape.angle = vangle;
            shape.draw(pos);
        }
    }
    public function get vangle():Number { return atan2(vel.x, vel.y); }
    public function get vspeed():Number { return vel.length; }
}
//----------------------------------------------------------------
var score:int, ticks:int;
function initialize():void {
    ship = new Ship;
    Shot.s = new Vector.<Shot>;
    Enemy.initialize();
}
function start():void {
    initialize();
    ship.isDestroyed = false;
    score = 0;
}
function update():void {
    drawGrid();
    if (ship.isDestroyed) {
        sc.drawText("rgrid", sc.center.x, sc.center.y - 20);
        sc.drawText("click to start", sc.center.x, sc.center.y + 20);
        ticks = 0;
        if (mouse.isClicked) start();
    } else {
        ship.update();
    }
    Actor.update(Shot.s);
    Enemy.update();
    sc.drawText(String(score), sc.size.y - 40, 20);
    ticks++;
}
var ship:Ship;
class Ship extends Actor {
    public var angle:Number = 0;
    public var gpos:Vec = new Vec, gvel:Vec = new Vec;
    public var enemy:Number = 100;
    public var isDestroyed:Boolean = true;
    function Ship() {
        shape = new Polyline(10).tri().clr(Color.green);
        shape.angle = PI;
        pos.x = sc.center.x; pos.y = sc.size.y * 0.8;
        vel.addAngle(PI, 1);
    }
    public var fireTicks:int;
    private var acc:Vec = new Vec, sv:Vec = new Vec;
    private var rect:Rectangle = new Rectangle(10, 10, 100, 20);
    public function update():void {
        if (ticks == 1) Message.addOnce("click to fire", pos);
        var ry:Number = (pos.y - mouse.pos.y) / pos.y;
        acc.clear();
        acc.addAngle(angle, ry * 0.5);
        if (ry < 0) ry = 0;
        angle -= (mouse.pos.x - sc.center.x) * 0.0002 * ry;
        var vx:Number = (mouse.pos.x - sc.center.x) * -0.002 * (1 - ry);
        acc.addAngle(angle + PI / 2, vx);
        gvel.incrementBy(acc);
        gvel.scaleBy(0.98);
        gpos.incrementBy(gvel);
        shape.draw(pos);
        if (enemy > 0 && --fireTicks <= 0 && mouse.isPressed && ticks > 10) {
            Shot.s.push(new Shot(gpos, angle));
            fireTicks = 5;
            enemy -= 5;
        }
        enemy += 0.25;
        if (enemy > 100) enemy = 100;
        rect.width = enemy;
        bd.fillRect(rect, 0xff00ffff);
        trail(ry * 10);
        sv.xy = gvel;
        sv.rotate(angle);
        pos.x = sc.center.x - sv.x * 5;
        pos.y = sc.size.y * 0.8 - sv.y * 5;
        score += sv.y;
    }
    private var sp:Vec = new Vec;
    public function getScreenPos(p:Vec):Vec {
        sp.xy = p;
        sp.decrementBy(gpos);
        sp.rotate(angle + PI);
        sp.incrementBy(pos);
        return sp;
    }
}
const GRID_SIZE:Number = 100;
var gp1:Vec = new Vec, gp2:Vec = new Vec;
var gsp1:Vec = new Vec, gsp2:Vec = new Vec;
function drawGrid():void {
    var sx:Number = int((ship.gpos.x - sc.size.x) / GRID_SIZE) * GRID_SIZE;
    var sy:Number = int((ship.gpos.y - sc.size.y) / GRID_SIZE) * GRID_SIZE;
    gp1.y = sy; gp2.y = sy + sc.size.y * 2;
    for (var x:Number = sx; x <= sx + sc.size.x * 2; x += GRID_SIZE) {
        gp1.x = gp2.x = x;
        gsp1.xy = ship.getScreenPos(gp1);
        gsp2.xy = ship.getScreenPos(gp2);
        Polyline.drawLine(gsp1, gsp2, 0x8800ff00, 1);
    }
    gp1.x = sx; gp2.x = sx + sc.size.x * 2;
    for (var y:Number = sy; y <= sy + sc.size.y * 2; y += GRID_SIZE) {
        gp1.y = gp2.y = y;
        gsp1.xy = ship.getScreenPos(gp1);
        gsp2.xy = ship.getScreenPos(gp2);
        Polyline.drawLine(gsp1, gsp2, 0x8800ff00, 1);
    }
}
class Shot extends Actor {
    static public var s:Vector.<Shot>;
    public var gpos:Vec = new Vec;
    public var angle:Number;
    function Shot(p:Vec, a:Number) {
        shape = new Polyline(5, 10).tri().clr(Color.cyan);
        gpos.xy = p; angle = a;
        vel.addAngle(PI, 0.1);
    }
    public function update():Boolean {
        gpos.addAngle(angle, 10);
        gpos.x += ship.vel.x / 2;
        gpos.y += ship.vel.y / 2;
        pos.xy = ship.getScreenPos(gpos);
        shape.angle = angle + PI - ship.angle;
        trail();
        var hf:Boolean;
        for each (var e:Enemy in Enemy.s) {
            if (!e.isDestroyed && e.pos.distance(pos) < 25) {
                e.explode();
                e.isDestroyed = true;
                hf = true;
                score += 10000;
            }
        }
        if (hf) return false;
        return sc.isIn(pos, 10);
    }
}
class Enemy extends Actor {
    public static var s:Vector.<Enemy>;
    public static var appTicks:int;
    public static function initialize():void {
        s = new Vector.<Enemy>;
        appTicks = 0;
    }
    public static function update():void {
        if (--appTicks <= 0) {
            s.push(new Enemy);
            appTicks = 20 / (sqrt(ticks * 0.005) + 1);
        }
        Actor.update(Enemy.s);
    }
    public var gpos:Vec = new Vec, gvel:Vec = new Vec;
    public var angle:Number, speed:Number;
    public var isIn:Boolean;
    public var accel:Number = rand.n(0.2, 0.05), brk:Number = rand.n(0.1, 0.9);
    public var angleVel:Number = rand.n(0.04, 0.01);
    public var isDestroyed:Boolean;
    function Enemy() {
        shape = new Polyline(20).tri().clr(Color.red);
        gpos.xy = ship.gpos;
        angle = rand.n(PI2);
        speed = 5;
        gpos.addAngle(angle, -sc.size.y);
        angle += rand.n(PI / 2, -PI / 4);
    }
    public function update():Boolean {
        if (isDestroyed) return false;
        gvel.addAngle(angle, accel);
        gpos.incrementBy(gvel);
        gvel.scaleBy(brk);
        gpos.x += ship.vel.x * 0.9;
        gpos.y += ship.vel.y * 0.9;
        var ta:Number = gpos.angle(ship.gpos);
        var oa:Number = ta - angle;
        if (oa >= PI2) oa %= PI2;
        else if (oa < 0) oa = PI2 - abs(oa) % PI2;
        if (oa < angleVel || oa > PI2 - angleVel) angle = ta;
        else if (oa < PI) angle += angleVel;
        else angle -= angleVel;
        pos.xy = ship.getScreenPos(gpos);
        shape.angle = angle + PI - ship.angle;
        if (!sc.isIn(pos, sc.size.x)) return false;
        if (sc.isIn(pos, 20)) isIn = true;
        else if (isIn) return false;
        vel.addAngle(shape.angle, 0.1);
        trail(5);
        vel.clear();
        if (pos.distance(ship.pos) < 15) {
            if (!ship.isDestroyed) {
                ship.explode(50);
                ship.isDestroyed = true;
            }
            return false;
        }
        return true;
    }
}
//----------------------------------------------------------------
import flash.display.*;
import flash.geom.*;
import flash.filters.*;
import flash.events.*;
import flash.text.*;
var main:Main, bd:BitmapData, blurBd:BitmapData;
var blurFilter:BlurFilter;
var sc:Screen;
var mouse:Mouse;
function initializeFirst():void {
    sc = new Screen;
    bd = new BitmapData(sc.size.x, sc.size.y);
    blurBd = new BitmapData(sc.size.x, sc.size.y);
    blurFilter = new BlurFilter(5, 5);
    main.addChild(new Bitmap(new BitmapData(sc.size.x, sc.size.y, false, 0)));
    main.addChild(new Bitmap(blurBd));
    mouse = new Mouse(main.stage);
    initialize();
    main.addEventListener(Event.ENTER_FRAME, updateFrame);
}
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
    mouse.isClicked = false;
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
    public function circle():Polyline {
        for (var i:int = 0, a:Number = 0; i < 9 ; i++, a += PI / 4 ) {
            addPoint(sin(a), cos(a), (i > 0 && i < 8));
        }
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
        var lx:Number = p1.x - size / 2, ly:Number = p1.y - size / 2;
        var vx:Number = v.x, vy:Number = v.y;
        if (size >= 2) {
            v.scaleBy(size);
            c /= size;
            rect.width = rect.height = size;
            for (var i:int = c; i >= 0; i--) {
                rect.x = lx; rect.y = ly;
                bd.fillRect(rect, cl);
                lx += vx; ly += vy;
            }
        } else {
            for (i = c; i >= 0; i--) {
                bd.setPixel32(lx, ly, cl);
                lx += vx; ly += vy;
            }
        }
    }
}
class Particle extends Actor {
    public static var s:Vector.<Particle> = new Vector.<Particle>;
    public static function add(pos:Vector3D, color:Color, scatter:int,
    intensity:Number, arc:Number = Math.PI * 2, angle:Number = 0):void {
        var n:int = intensity * arc;
        for (var i:int = 0; i < n; i++) {
            var p:Particle = new Particle;
            p.pos.xy = pos;
            p.vel.addAngle(angle + rand.n(arc, -arc / 2), intensity * rand.n(1));
            p.size = intensity * rand.n(0.2, 0.2) + 1;
            var sc:Color = color.getScatterd(scatter);
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
    public var isPressed:Boolean, isClicked:Boolean;
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
        isPressed = isClicked = true; onMoved(e);
    }
    private function onReleased(e:Event):void {
        isPressed = false;
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
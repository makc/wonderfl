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
    Wall.initialize();
    mouse.isClicked = false;
}
function start():void {
    player = new Player;
    initialize();
    score = 0;
}
function update():void {
    Actor.update(Wall.s);
    if (player) {
        Actor.updateActor(player);
    } else {
        sc.drawText("ocwalls", sc.center.x, sc.center.y - 20);
        sc.drawText("click to start", sc.center.x, sc.center.y + 20);
        if (mouse.isClicked) start();
        ticks = 0;
    }
    sc.drawText(String(score), 40, 20);
    ticks++;
}
class Wall extends Actor {
    public static const HEIGHT:Number = 30;
    public static var s:Vector.<Wall>;
    public static var scrDist:Number;
    public static function initialize():void {
        s = new Vector.<Wall>;
        for (var y:int = 0; y < sc.size.y; y += HEIGHT) {
            addWall(y);
        }
        scrDist = 0;
    }
    private static function addWall(y:Number):void {
        var w1:Wall = new Wall(sc.size.x * -1.5 + HEIGHT, y);
        s.push(w1);
        var w2:Wall = new Wall(sc.size.x * -0.5 + HEIGHT + rand.sx(0.4), y);
        s.push(w2);
        var w3:Wall = new Wall(sc.size.x * 1.5 - HEIGHT - rand.sx(0.4), y);
        s.push(w3);
        var w4:Wall = new Wall(sc.size.x * 2.5 - HEIGHT, y);
        s.push(w4);
        w2.leftWall = w1; w2.rightWall = w3;
        w3.leftWall = w2; w3.rightWall = w4;
        if (rand.i(4) == 0) w2.toRight();
        else w2.toLeft();
        if (rand.i(4) == 0) w3.toLeft();
        else w3.toRight();
    }
    public static function scroll(v:Number):void {
        for each (var w:Wall in Wall.s) w.pos.y += v;
        scrDist += v;
        if (scrDist < HEIGHT) return;
        scrDist -= HEIGHT;
        addWall(scrDist);
    }
    public var rightWall:Wall, leftWall:Wall;
    public var isFixed:Boolean;
    public var vsp:Number = 0, asp:Number = 0, accx:Number = 0;
    function Wall(x:Number, y:Number) {
        pos.x = x; pos.y = y;
        if (x > -sc.size.x && x < sc.size.x * 2) {
            shape = new Polyline(sc.size.x, HEIGHT - 4).box().clr(Color.cyan);
            if (rand.i(5) == 0) {
                asp = rand.n(2, 1) * rand.n(2, 1) * rand.n(2, 1) * 0.01 * sqrt(ticks * 0.002 + 1);
            } else {
                vsp = rand.n(2, 1) * rand.n(2, 1) * rand.n(2, 1) * 0.1 * sqrt(ticks * 0.002 + 1); 
            }
        } else {
            isFixed = true;
        }
    }
    private var ep:Vec = new Vec, bp:Vec = new Vec;
    public function update():Boolean {
        if (isFixed) return pos.y < sc.size.y + HEIGHT;
        vel.x += accx;
        if (vel.x > 0) {
            if (pos.x > rightWall.pos.x - shape.size.x) {
                toLeft();
                if (rightWall.shape) {
                    rightWall.toRight();
                    ep.x = pos.x + shape.size.x / 2; ep.y = pos.y;
                    Particle.add(ep, shape.color, 128, 10);
                }
            }
        } else {
            if (pos.x < leftWall.pos.x + shape.size.x) {
                toRight();
                if (leftWall.shape) {
                    leftWall.toLeft();
                    ep.x = pos.x - shape.size.x / 2; ep.y = pos.y;
                    Particle.add(ep, shape.color, 128, 10);
                }
            }
        }
        return pos.y < sc.size.y + HEIGHT;
    }
    public function toRight():void {
        vel.x = vsp; accx = asp;
    }
    public function toLeft():void {
        vel.x = -vsp; accx = -asp;
    }
    public function checkHit(p:Vec):Boolean {
        if (!shape) return false;
        return (abs(p.x - pos.x) <= (shape.size.x + player.shape.size.x) / 2 &&
        abs(p.y - pos.y) <= (shape.size.y + player.shape.size.y) / 2);
    }
}
var player:Player;
class Player extends Actor {
    public const SPEED:Number = 8;
    public var hitCount:int = 0;
    function Player() {
        shape = new Polyline(Wall.HEIGHT).tri().clr(Color.green);
        shape.angle = PI;
        pos.xy = sc.center;
    }
    public function update():void {
        var a:Number = pos.angle(mouse.pos);
        var d:Number = pos.distance(mouse.pos);
        if (d > SPEED) d = SPEED;
        pos.addAngle(a, d);
        var isHitRight:Boolean, isHitLeft:Boolean;
        for each (var w:Wall in Wall.s) {
            if (w.checkHit(pos)) {
                if (abs(pos.y - w.pos.y) < w.shape.size.y / 2) {
                    if (pos.x > w.pos.x) {
                        pos.x = w.pos.x + (w.shape.size.x + shape.size.x) / 2;
                        isHitLeft = true;
                    }
                    else {
                        pos.x = w.pos.x - (w.shape.size.x + shape.size.x) / 2;
                        isHitRight = true;
                    }
                } else {
                    if (pos.y < w.pos.y) {
                        pos.y = w.pos.y - (w.shape.size.y + shape.size.y) / 2;
                    } else {
                        pos.y = w.pos.y + (w.shape.size.y + shape.size.y) / 2;
                    }
                }
            }
        }
        if (pos.y < sc.size.y * 0.5) {
            scroll((sc.size.y * 0.5 - pos.y) * 0.1);
        }
        if (isHitLeft && isHitRight) {
            if (++hitCount > 3) {
                explode(100);
                player = null;
                return;
            }
        } else {
            hitCount = 0;
        }
    }
}
function scroll(v:Number):void {
    player.pos.y += v;
    Wall.scroll(v);
    score += v;
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
            vx *= size; vy *= size;
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
            p.vel.addAngle(angle + rand.n(arc, -arc / 2), sqrt(intensity) * rand.n(3));
            p.size = sqrt(intensity) * rand.n(0.5, 0.2) + 1;
            var sc:Color = color.getScatterd(scatter);
            p.icolor = sc.i;
            s.push(p);
        }
    }
    public var size:Number;
    public var icolor:uint;
    private static var rect:Rectangle = new Rectangle;
    public function update():Boolean {
        vel.scaleBy(0.98);
        size -= 0.1;
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
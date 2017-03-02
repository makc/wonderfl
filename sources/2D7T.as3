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
    public function trail(intensity:Number = 5):void {
        Particle.add(pos, shape.lineColor, 64, intensity, 0.2 * intensity, vangle + PI);
    }
    public function explode(intensity:Number = 20):void {
        Particle.add(pos, shape.lineColor, 128, intensity);
    }
    public function moveAndDraw():void {
        pos.incrementBy(vel);
        if (shape) {
            if (isVAngleShape) shape.angle = vangle;
            shape.draw(pos);
        }
    }
    public function get vangle():Number { return atan2(vel.x, vel.y); }
    public function get vspeed():Number { return vel.length; }
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
//----------------------------------------------------------------
const TITLE:String = "boxinbox";
const DEBUG:Boolean = false;
function initialize():void {
    box = new Box(90, 12, 0);
}
function update():void {
    if (!box) {
        endGame();
        initialize();
        return;
    }
    box.center.xy = screen.center;
    box.size = screen.size.x;
    Actor.updateActor(box);
    if (isInGame) score += 100 / 30;
}
class ScalingActor extends Actor {
    public static var rcenter:Vec = new Vec, scenter:Vec = new Vec;
    public static var rsize:Number, ssize:Number;
    private static var spos:Vec = new Vec, mpos:Vec = new Vec;
    public static function convertMousePos(p:Vec):Vec {
        mpos.xy = p;
        mpos.decrementBy(scenter);
        mpos.scaleBy(rsize / ssize);
        mpos.incrementBy(rcenter);
        return mpos;
    }
    public static function convertPos(p:Vec):Vec {
        spos.xy = p;
        spos.decrementBy(rcenter);
        spos.scaleBy(ssize / rsize);
        spos.incrementBy(scenter);
        return spos;
    }
    public static function get scale():Number {
        return ssize / rsize;
    }
    public function drawScaled():void {
        shape.scale = scale;
        shape.draw(convertPos(pos));
    }
    public override function moveAndDraw():void {
        pos.incrementBy(vel);
        if (shape) {
            if (isVAngleShape) shape.angle = vangle;
            drawScaled();
        }
    }
}
var box:Box;
class Box extends ScalingActor {
    public var walls:Vector.<Wall> = new Vector.<Wall>;
    public var goal:Goal;
    public var player:Player;
    public var innerBox:Box, outerBox:Box;
    public var center:Vec = new Vec, size:Number;
    public var dir:int;
    function Box(idx:int, count:int, d:int) {
        dir = d;
        shape = new Polyline(screen.size.x).box().color(Color.cyan);
        pos.xy = screen.center;
        var rand:Rand = new Rand(idx);
        addWall(-screen.size.x * 0.1, -screen.size.y * 0.1, screen.size.x * 1.1, 0, false);
        addWall(-screen.size.x * 0.1, screen.size.y, screen.size.x * 1.1, screen.size.y * 1.1, false);
        addWall(-screen.size.x * 0.1, -screen.size.y * 0.1, 0, screen.size.y * 1.1, false);
        addWall(screen.size.x, -screen.size.y * 0.1, screen.size.x * 1.1, screen.size.y * 1.1, false);
        var y:Number = screen.size.y * 0.1;
        while (y < screen.size.y * 0.8) {
            y += rand.sy(0.05, 0.05);
            for (var i:int = 0; i < 10; i++) {
                var x1:Number = rand.sx(), x2:Number = rand.sx();
                switch (rand.i(5)) {
                    case 0: x1 = 0; break;
                    case 1: x2 = screen.size.x; break;
                }
                if (abs(x1 - x2) > screen.size.x * 0.1 && abs(x1 - x2) < screen.size.x * 0.7) break;
            }
            if (i == 10) {
                x1 = screen.size.x * 0.3; x2 = screen.size.x * 0.7;
            }
            if (x1 > x2) {
                var tx:Number = x1; x1 = x2; x2 = tx;
            }
            var h:Number = rand.sy(0.02, 0.02);
            addWall(x1, y, x2, y + h);
            y += h;
        }
        goal = new Goal(dir);
        switch (dir) {
            case 0:
                goal.pos.y = screen.size.y - goal.shape.size.y / 2;
                goal.pos.x = rand.n(screen.size.x - goal.shape.size.x);
                break;
            case 1:
                goal.pos.x = screen.size.x - goal.shape.size.x / 2;
                goal.pos.y = rand.n(screen.size.y - goal.shape.size.y);
                break;
            case 2:
                goal.pos.y = goal.shape.size.y / 2;
                goal.pos.x = rand.n(screen.size.x - goal.shape.size.x);
                break;
            case 3:
                goal.pos.x = goal.shape.size.x / 2;
                goal.pos.y = rand.n(screen.size.y - goal.shape.size.y);
                break;
        }
        player = new Player(dir);
        player.box = this;
        if (count > 0) {
            innerBox = new Box(idx + 1, count - 1, (d + 1) % 4);
            innerBox.outerBox = this;
        }
    }
    private function addWall(x1:Number, y1:Number, x2:Number, y2:Number, hasShape:Boolean = true):void {
        var w:Wall;
        switch (dir) {
            case 0:
                w = new Wall(x2 - x1, y2 - y1, hasShape);
                w.pos.x = (x1 + x2) / 2; w.pos.y = (y1 + y2) / 2;
                break;
            case 1:
                w = new Wall(y2 - y1, x2 - x1, hasShape);
                w.pos.x = (y1 + y2) / 2; w.pos.y = (x1 + x2) / 2;
                break;
            case 2:
                w = new Wall(x2 - x1, y2 - y1, hasShape);
                w.pos.x = screen.size.x - (x1 + x2) / 2;
                w.pos.y = screen.size.y - (y1 + y2) / 2;
                break;
            case 3:
                w = new Wall(y2 - y1, x2 - x1, hasShape);
                w.pos.x = screen.size.x - (y1 + y2) / 2;
                w.pos.y = screen.size.y - (x1 + x2) / 2;
                break;
        }
        walls.push(w);
    }
    public function checkHit(p:Player):void {
        for each (var w:Wall in walls) w.checkHit(p);
    }
    public function update():Boolean {
        if (goal.pos.distance(player.pos) < 25) {
            if (outerBox) outerBox.innerBox = innerBox;
            else box = innerBox;
            if (innerBox) innerBox.outerBox = outerBox;
        }
        setScreen();
        Actor.update(walls);
        Actor.updateActor(goal);
        if (abs(mouse.pos.x - center.x) < size / 2 &&
            abs(mouse.pos.y - center.y) < size / 2) {
            player.mpos = ScalingActor.convertMousePos(mouse.pos);            
        } else {
            player.mpos = null;
        }
        if (isInGame) Actor.updateActor(player);
        if (!innerBox) return true;
        innerBox.center.xy = ScalingActor.convertPos(player.pos);
        innerBox.size = Player.SIZE * ScalingActor.scale;
        Actor.updateActor(innerBox);
        ScalingActor.scenter.xy = center;
        setScreen();
        return true;
    }
    private var rp:Vec = new Vec;
    private function setScreen():void {
        ScalingActor.scenter.xy = center;
        ScalingActor.ssize = size;
        Polyline.topLeft.x = center.x - size / 2;
        Polyline.topLeft.y = center.y - size / 2;
        Polyline.bottomRight.x = center.x + size / 2;
        Polyline.bottomRight.y = center.y + size / 2;
        rp.xy = player.pos;
        rp.incrementBy(goal.pos);
        rp.scaleBy(0.5);
        var rw:Number = player.pos.distance(goal.pos) * 1.25;
        ScalingActor.rcenter.xy = rp;
        ScalingActor.rsize = rw;
    }
}
class Wall extends ScalingActor {
    public var size:Vec = new Vec;
    function Wall(width:Number, height:Number, hasShape:Boolean = true) {
        if (hasShape) shape = new Polyline(width, height).box().color(Color.cyan);
        size.x = width; size.y = height;
    }
    public function update():Boolean {
        return true;
    }
    public function checkHit(p:Player):void {
        if (abs(pos.x - p.pos.x) >= (size.x + Player.SIZE) / 2 ||
            abs(pos.y - p.pos.y) > (size.y + Player.SIZE) / 2) return;
        if (p.ppos.x <= pos.x - (size.x + Player.SIZE) / 2) {
            p.pos.x = pos.x - (size.x + Player.SIZE) / 2;
            if (p.vel.x > 0) p.vel.x = 0;
        } else if (p.ppos.x >= pos.x + (size.x + Player.SIZE) / 2) {
            p.pos.x = pos.x + (size.x + Player.SIZE) / 2;
            if (p.vel.x < 0) p.vel.x = 0;
        }
        if (p.ppos.y <= pos.y - (size.y + Player.SIZE) / 2) {
            p.pos.y = pos.y - (size.y + Player.SIZE) / 2;
            if (p.vel.y > 0) p.vel.y = 0;
        } else if (p.ppos.y >= pos.y + (size.y + Player.SIZE) / 2) {
            p.pos.y = pos.y + (size.y + Player.SIZE) / 2;
            if (p.vel.y < 0) p.vel.y = 0;
        }
    }
}
class Goal extends ScalingActor {
    function Goal(dir:int) {
        switch (dir) {
            case 0:
            case 2:
                shape = new Polyline(20, 5).box().color(Color.yellow);
                break;
            case 1:
            case 3:
                shape = new Polyline(5, 20).box().color(Color.yellow);
                break;
        }
    }
    public function update():Boolean {
        return true;
    }
}
var player:Player;
class Player extends ScalingActor {
    public static const SIZE:Number = 20;
    public var ppos:Vec = new Vec;
    public var mpos:Vec;
    public var box:Box;
    public var dir:int;
    function Player(dir:int) {
        this.dir = dir;
        shape = new Polyline(SIZE).box().color(Color.green);
        shape.angle = PI;
        switch (dir) {
            case 0:
                pos.x = screen.center.x; pos.y = SIZE;
                break;
            case 1:
                pos.x = SIZE; pos.y = screen.center.y;
                break;
            case 2:
                pos.x = screen.center.x; pos.y = screen.size.y - SIZE;
                break;
            case 3:
                pos.x = screen.size.x - SIZE; pos.y = screen.center.y;
                break;
        }
    }
    private const SPEED:Number = 5, GRAVITY:Number = 0.3;
    private var wasPressed:Boolean;
    public function update():Boolean {
        box.checkHit(this);
        switch (dir) {
            case 0:
            case 2:
                vel.x = 0;
                if (mpos) {
                    var ox:Number = mpos.x - pos.x;
                    if (abs(ox) < SPEED) vel.x = ox;
                    else if (ox < 0) vel.x = -SPEED;
                    else vel.x = SPEED;
                }
                break;
            case 1:
            case 3:
                vel.y = 0;
                if (mpos) {
                    var oy:Number = mpos.y - pos.y;
                    if (abs(oy) < SPEED) vel.y = oy;
                    else if (oy < 0) vel.y = -SPEED;
                    else vel.y = SPEED;
                }
                break;
        }
        switch (dir) {
            case 0: vel.y += GRAVITY; break;
            case 1: vel.x += GRAVITY; break;
            case 2: vel.y -= GRAVITY; break;
            case 3: vel.x -= GRAVITY; break;
        }
        ppos.xy = pos;
        return true;
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
var main:Main, bd:BitmapData, blurBd:BitmapData;
var blurFilter:BlurFilter;
var baseSprite:Sprite;
function initializeFirst():void {
    screen = new Screen;
    bd = new BitmapData(screen.size.x, screen.size.y);
    blurBd = new BitmapData(screen.size.x, screen.size.y);
    blurFilter = new BlurFilter(10, 10);
    main.addChild(new Bitmap(new BitmapData(screen.size.x, screen.size.y, false, 0)));
    baseSprite = new Sprite;
    baseSprite.addChild(new Bitmap(blurBd)); 
    main.addChild(baseSprite);
    mouse = new Mouse(main.stage);
    initialize();
    if (DEBUG) beginGame();
    else setScoreRecordViewer();
    main.addEventListener(Event.ENTER_FRAME, updateFrame);
}
var zeroPoint:Point = new Point;
function updateFrame(event:Event):void {
    blurBd.lock();
    blurBd.fillRect(bd.rect, 0);
    bd.lock();
    bd.fillRect(bd.rect, 0);
    updateGame();
    Actor.update(Particle.s);
    Actor.update(Message.s);
    bd.unlock();
    blurBd.applyFilter(blurBd, blurBd.rect, zeroPoint, blurFilter);
    blurBd.copyPixels(bd, bd.rect, zeroPoint, null, null, true);
    blurBd.unlock();
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
    screen.drawText(String(score), screen.size.x - 40, 20);
    update();
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
    public var lineColor:Color;
    public var pointAngles:Vector.<Number> = new Vector.<Number>;
    public var pointDists:Vector.<Number> = new Vector.<Number>;
    public var angle:Number = 0, scale:Number = 1;
    public var size:Vec = new Vec;
    public function Polyline(width:Number = 0, height:Number = 0) {
        if (height <= 0) height = width;
        size.x = width; size.y = height;
    }
    public function color(c:Color):Polyline {
        lineColor = c;
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
    public function draw(pos:Vec):void {
        drawLines(pos, lineColor.i, true);
        drawLines(pos, lineColor.i);
    }
    private static var p1:Vec = new Vec, p2:Vec = new Vec;
    public function drawLines(pos:Vec, cl:uint, isBlur:Boolean = false):void {
        for (var i:int = pointAngles.length - 2; i >= 0; i -= 2) {
            p1.xy = pos;
            p1.addAngle(angle + pointAngles[i], pointDists[i] * scale);
            p2.xy = pos;
            p2.addAngle(angle + pointAngles[i + 1], pointDists[i + 1] * scale);
            drawLine(p1, p2, cl, isBlur);
        }
    }
    public static var v:Vec = new Vec, rect:Rectangle = new Rectangle;
    public static var topLeft:Vec = new Vec, bottomRight:Vec = new Vec;
    public static function drawLine(p1:Vec, p2:Vec, cl:uint, isBlur:Boolean):void {
        v.x = p2.x - p1.x; v.y = p2.y - p1.y;
        var c:int = Math.max(abs(v.x), abs(v.y));
        v.scaleBy(1 / c);
        var lx:Number = p1.x, ly:Number = p1.y;
        var vx:Number = v.x, vy:Number = v.y;
        if (isBlur) {
            lx -= 1; ly -= 1;
            var size:int = 3;
            vx *= size; vy *= size;
            c /= size;
            rect.width = rect.height = size;
            for (var i:int = c; i >= 0; i--) {
                if (lx >= topLeft.x && lx <= bottomRight.x &&
                ly >= topLeft.y && ly <= bottomRight.y) {
                    rect.x = lx; rect.y = ly;
                    blurBd.fillRect(rect, cl);
                }
                lx += vx; ly += vy;
            }        
        } else {
            for (i = c; i >= 0; i--) {
                if (lx >= topLeft.x && lx <= bottomRight.x &&
                ly >= topLeft.y && ly <= bottomRight.y) {
                    bd.setPixel32(lx, ly, cl);
                }
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
        return screen.isIn(pos) && size >= 1.0;
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
var rand:Rand = new Rand;
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
    scoreRecordViewer = new BasicScoreRecordViewer(main, 5, 220, "SCORE RANKING", 50, false);
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
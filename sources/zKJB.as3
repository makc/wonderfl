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
const TITLE:String = "pwing";
const DEBUG:Boolean = false;
function initialize():void {
    Wing.s = new Vector.<Wing>;
    Ball.s = new Vector.<Ball>;
    nextWingDist = 0;
    nextBallDist = 99999;
    scroll(sc.size.y);
    Gate.initialize();
    scrollGate(sc.size.x);
}
function update():void {
    Actor.update(Wing.s);
    Actor.update(Ball.s);
    if (Ball.s.length <= 0) nextBallDist = 0;
    scroll(2 - cos(ticks * 0.005));
    if (isInGame) {
        Actor.update(Gate.s);
        scrollGate(sin(ticks * 0.003) * 2);
    }
}
class Wing extends Actor {
    public static var s:Vector.<Wing>;
    public var length:Number;
    function Wing(y:Number) {
        for (var i:int = 0; i < 16; i++) {
            length = rand.n(80, 50);
            pos.x = rand.sx();
            pos.y = sc.size.y + length / 2 + y;
            var hf:Boolean = false;
            for each (var w:Wing in s) {
                if (w.pos.distance(pos) < (w.length + length) / 3) {
                    hf = true; break;
                }
            }
            if (!hf) break;
        }
        shape = new Polyline(10, length).box().clr(Color.green);
    }
    public function update():Boolean {
        shape.angle = (mouse.pos.x - sc.center.x) * 0.01;
        if (shape.angle > PI * 0.4) shape.angle = PI * 0.4;
        else if (shape.angle < -PI * 0.4) shape.angle = -PI * 0.4;
        if (pos.y < length / 2 + 20) {
            explode(10);
            return false;
        }
        return true;
    }
    private var ofs:Vec = new Vec;
    public function checkHit(b:Ball):void {
        ofs.xy = b.pos;
        ofs.decrementBy(pos);
        ofs.rotate(shape.angle);
        if (abs(ofs.x) > shape.size.x / 2 || abs(ofs.y) > shape.size.y / 2) return;
        b.vel.rotate(shape.angle);
        b.vel.x *= -0.8;
        b.vel.rotate(-shape.angle);
    }
}
class Ball extends Actor {
    public static var s:Vector.<Ball>;
    function Ball() {
        for (var i:int = 0; i < 16; i++) {
            pos.x = rand.sx(0.8, 0.1);
            var hf:Boolean = false;
            for each (var w:Wing in Wing.s) {
                if (w.pos.y < sc.size.y * 0.3) continue;
                if (abs(w.pos.x - pos.x) < w.length / 4) {
                    hf = true;
                    break;
                }
            }
            if (hf) break;
        }
        pos.y = -10;
        shape = new Polyline(10).circle().clr(Color.cyan);
    }
    public var isInGate:Boolean;
    public function update():Boolean {
        vel.y += 0.3;
        if (isInGate) {
            return pos.y < sc.size.y;
        }
        vel.scaleBy(0.96);
        for each (var w:Wing in Wing.s) w.checkHit(this);
        if (pos.x < 0) pos.x += sc.size.x;
        else if (pos.x > sc.size.x) pos.x -= sc.size.x;
        if (isInGame && pos.y > sc.size.y - 30) {
            for each (var g:Gate in Gate.s) {
                if (pos.x >= g.pos.x - g.width && pos.x <= g.pos.x) {
                    if (g.score < 0) {
                        explode(50);
                        endGame();
                        return false;
                    }
                    Message.add(String(g.score), pos, 0, -100, 30);
                    score += g.score;
                    break;
                }
            }
            isInGate = true;
            vel.x = 0;
        }
        trail();
        return pos.y < sc.size.y;
    }
}
var nextWingDist:Number, nextBallDist:Number;
function scroll(d:Number):void {
    for each (var w:Wing in Wing.s) w.pos.y -= d;
    for each (var b:Ball in Ball.s) b.pos.y -= d;
    nextWingDist -= d;
    while (nextWingDist <= 0) {
        Wing.s.push(new Wing(nextWingDist));
        nextWingDist += 25;
    }
    nextBallDist--;
    while (nextBallDist <= 0) {
        Ball.s.push(new Ball);
        nextBallDist += 150 / sqrt(ticks * 0.004 + 1);
    }
}
class Gate extends Actor {
    public static var s:Vector.<Gate>;
    public static var nextCrossCount:int, nextHighCount:int;
    public static function initialize():void {
        s = new Vector.<Gate>;
        nextCrossCount = rand.i(5, 5);
        nextHighCount = rand.i(3, 3);
    }
    public var width:Number;
    public var cshape:Polyline;
    public var score:int;
    public var message:Message;
    function Gate(x:Number) {
        width = rand.sx(0.1, 0.15);
        shape = new Polyline(5, 30).tri().clr(Color.yellow);
        shape.angle = PI;
        pos.x = x;
        pos.y = sc.size.y - 15;
        if (--nextCrossCount <= 0) {
            score = -1;
            cshape = new Polyline(10).cross().clr(Color.red);
            width = sc.size.x * 0.1;
            nextCrossCount = rand.i(5, 5);
        } else {
            score = int(1 + rand.n(2) * rand.n(2) * rand.n(2) * rand.n(2)) * 10;
            if (--nextHighCount <= 0) {
                score *= rand.i(3, 3);
                score += 100;
                width = sc.size.x * 0.15;
                nextHighCount = rand.i(3, 3);
            }
        }
    }
    private var sp:Vec = new Vec;
    public function update():Boolean {
        sp.xy = pos;
        sp.x -= width / 2;
        if (score < 0) {
            if (!message) {
                if (pos.x > sc.size.x * 0.2 && pos.x < sc.size.x * 0.8) {
                    message = Message.addOnce("avoid this area", new Vec(0, pos.y - 20));
                }
            } else {
                message.pos.x = sp.x;
            }
            cshape.draw(sp);
        } else {
            sc.drawText(String(score), sp.x, sp.y);
        }
        return sc.isIn(pos, width);
    }
}
function scrollGate(v:Number):void {
    for each (var g:Gate in Gate.s) g.pos.x += v;
    var lx:Number = sc.size.x;
    for each (g in Gate.s) if (lx > g.pos.x - g.width) lx = g.pos.x - g.width;
    while (lx >= 0) {
        g = new Gate(lx);
        Gate.s.push(g);
        lx -= g.width;
    }
    var rx:Number = 0;
    for each (g in Gate.s) if (rx < g.pos.x) rx = g.pos.x;
    while (rx <= sc.size.x) {
        g = new Gate(rx);
        g.pos.x += g.width;
        Gate.s.push(g);
        rx += g.width;
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
var baseSprite:Sprite;
function initializeFirst():void {
    sc = new Screen;
    bd = new BitmapData(sc.size.x, sc.size.y);
    blurBd = new BitmapData(sc.size.x, sc.size.y);
    blurFilter = new BlurFilter(5, 5);
    main.addChild(new Bitmap(new BitmapData(sc.size.x, sc.size.y, false, 0)));
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
    bd.lock();
    bd.fillRect(bd.rect, 0);
    updateGame();
    Actor.update(Particle.s);
    Actor.update(Message.s);
    bd.unlock();
    blurBd.lock();
    blurBd.copyPixels(bd, bd.rect, zeroPoint);
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
    sc.drawText(String(score), sc.size.x - 40, 20);
    update();
    if (!isInGame) {
        sc.drawText(TITLE, sc.size.x * 0.7, sc.center.y - 20);
        sc.drawText("click to start", sc.size.x * 0.7, sc.center.y + 20);
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
    public function n(v:Number = 1, s:Number = 0):Number { return Math.random() * v + s; }
    public function i(v:int, s:int = 0):int { return n(v, s); }
    public function sx(v:Number = 1, s:Number = 0):Number { return n(v, s) * sc.size.x; }
    public function sy(v:Number = 1, s:Number = 0):Number { return n(v, s) * sc.size.y; }
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
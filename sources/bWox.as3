package {
    import flash.display.Sprite;
    [SWF(width="465", height="465", backgroundColor="0", frameRate="30")]
    public class Main extends Sprite {
        public function Main() { main = this; initializeFirst(); }
    }
}
// Game actor base class.
class Actor {
    public static var shapes:Vector.<PrimitiveShape>;
    public var shape:PrimitiveShape, sprite:PrimitiveSprite, pos:Vec = new Vec;
    public function Actor(type:int = -1, width:int = -1, height:int = -1) {
        initializeActor(this, type, width, height);
    }
}
/*----------------------------------------------------------------*/
const DEBUG = false;
const TITLE = "CONNECTED NODES";
var rank, nextNodesDist;
function initialize() {
    nodes = new Vector.<Node>;
    lines = new Vector.<LLine>;
    nextNodesDist = 0;
    addNodes(); scroll(SCREEN_HEIGHT * 0.5);
    var lmy = -SCREEN_HEIGHT, ml;
    for each (var l in lines) {
        if (l.pos.y < SCREEN_HEIGHT && l.pos.y > lmy) {
            lmy = l.pos.y; ml = l;
        }
    }
    if (ml) ml.setMessage();
}
function update() {
    // For Android.
    //fillRect(SCREEN_WIDTH / 2, 1, SCREEN_WIDTH, 2, 0xffffff);
    //fillRect(SCREEN_WIDTH / 2, SCREEN_HEIGHT - 1, SCREEN_WIDTH, 2, 0xffffff);
    //rank = 1 + sawtoothWave(Number(score) / 1000) * 4;
    rank = 1 + sawtoothWave(Number(score) / 1000) * 2;
    if (isMouseClicked && mouse.y >= 0) for each (var l in lines) l.checkClicked();
    updateActors(nodes);
    updateActors(lines);
    var my = 0;
    for each (var n in nodes) if (n.isConnected && n.pos.y > my) my = n.pos.y;
    if (my < SCREEN_CENTER) scroll((SCREEN_CENTER - my) * 0.05);
    scroll(0.5 * rank);
}
var nodes;
class Node extends Actor {
    static const SIZE = 15;
    var fromLines = new Vector.<LLine>, toLines = new Vector.<LLine>;
    var vel = new Vec, isChecked, isConnected = true;
    function Node() {
        super(PrimitiveShape.CIRCLE, SIZE);
        var nf;
        for (var i = 0; i < 10; i++) {
            pos.x = rands(0.1, 0.8); pos.y = -rands(0.5, 1);
            nf = false;
            for each (var n in nodes) if (n.pos.distance(pos) < 64) nf = true;
            if (!nf) break;
        }
        if (nf) pos.y = SCREEN_HEIGHT * 99;
    }
    function update() {
        if (pos.y > SCREEN_HEIGHT * 2) return false;
        vel.y += 0.1 * rank; vel.scaleBy(0.95);
        if (pos.y < 0) vel.x = vel.y = 0;
        pos.incrementBy(vel);
        if (pos.y > SCREEN_HEIGHT) {
            if (isConnected) { addParticlesRound(250, pos.x, pos.y, 25, 15); startGameOver(); }
            else removeConnected(1);
            return false;
        }
        return true;
    }
    function connect() {
        if (pos.y > 0) return;
        for each (var to in nodes) {
            if (toLines.length >= 2) break;
            if (to == this || to.pos.distance(pos) > 128 || to.pos.y > pos.y - 16) continue;
            var ef = false;
            for each (var l in lines) if (l.equals(this, to)) { ef = true; break; }
            if (!ef) lines.push(new LLine(this, to));
        }
    }
    function addConnection() {
        if (pos.y > 0) return;
        while (toLines.length <= 0) {
            var mn, md = 99999;
            for each (var to in nodes) {
                if (to == this || to.pos.y > pos.y - 16) continue;
                var ef = false;
                for each (var l in lines) if (l.equals(this, to)) { ef = true; break; }
                if (!ef) {
                    var d = to.pos.distance(pos);
                    if (d < md) { md = d; mn = to; }
                }
            }
            if (mn) lines.push(new LLine(this, mn));
            else break;
        }
    }
    function checkConnection() {
        if (pos.y < 0) return true;
        if (isChecked) return false;
        for (var i = 0; i < fromLines.length; i++) if (fromLines[i].pos.y > SCREEN_HEIGHT) fromLines.splice(i--, 1);
        for (i = 0; i < toLines.length; i++) if (toLines[i].pos.y > SCREEN_HEIGHT) toLines.splice(i--, 1);
        isChecked = true;
        for each (var l in fromLines) if (l.from.checkConnection()) return true;
        for each (l in toLines) if (l.to.checkConnection()) return true;
        return false;
    }
    function setNotConnected() {
        if (!isConnected) return;
        isConnected = false; sprite.alpha = 0.5;
        for each (var l in fromLines) l.from.setNotConnected();
        for each (l in toLines) l.to.setNotConnected();
    }
    function removeConnected(s) {
        if (pos.y > SCREEN_HEIGHT * 2) return s;
        addParticlesRound(50, pos.x, pos.y, 5, 5);
        addNumberBoard(s, pos.x, pos.y - 20); score += s++;
        pos.y = SCREEN_HEIGHT * 99;
        for each (var l in fromLines) { l.remove();  s = l.from.removeConnected(s); }
        for each (l in toLines) { l.remove();  s = l.to.removeConnected(s); }
        return s;
    }
}
var lines
class LLine extends Actor {
    var from, to, length, angle, baseLength, o = new Vec, isConnected = true, message;
    function LLine(from, to) {
        length = baseLength = from.pos.distance(to.pos);
        super(PrimitiveShape.BAR, 16, int(length - Node.SIZE));
        this.from = from; this.to = to;
        pos.x = (from.pos.x + to.pos.x) / 2; pos.y = (from.pos.y + to.pos.y) / 2;
        sprite.angle = angle = from.pos.angle(to.pos);
        from.toLines.push(this); to.fromLines.push(this);
    }
    function update() {
        if (pos.y > SCREEN_HEIGHT) return false;
        if (isConnected && !from.isConnected && !to.isConnected) {
            isConnected = false; sprite.alpha = 0.5;
        }
        length = from.pos.distance(to.pos);
        angle = from.pos.angle(to.pos);
        var v = (length - baseLength) * 0.05;
        from.vel.addAngle(angle, -v);
        to.vel.addAngle(angle, v);
        pos.x = (from.pos.x + to.pos.x) / 2;
        pos.y = (from.pos.y + to.pos.y) / 2;
        sprite.scale = (length - Node.SIZE) / int(baseLength - Node.SIZE);
        sprite.angle = angle;
        if (message) {
            message.pos.x = pos.x; message.pos.y = pos.y;
        }
        return pos.y < SCREEN_HEIGHT;
    }
    function setMessage() {
        message = addMessage(CLICK_STR + " TO CUT A LINE", pos.x, pos.y, 90, PI / 4 * 3);
    }
    function equals(f, t) {
        return (from == f && to == t);
    }
    function checkClicked() {
        o.x = mouse.x - pos.x; o.y = mouse.y - pos.y;
        o.rotate(angle);
        if (o.y >= -length / 2 && o.y <= length / 2 && o.x >= -24 && o.x <= 24) {
            remove();
            for each (var n in nodes) n.isChecked = false;
            if (!from.checkConnection()) from.setNotConnected();
            for each (var n in nodes) n.isChecked = false;
            if (!to.checkConnection()) to.setNotConnected();
        }
    }
    function remove() {
        if (pos.y > SCREEN_HEIGHT * 2) return;
        addParticlesAngle(10, pos.x, pos.y, angle, length * 0.1);
        addParticlesAngle(10, pos.x, pos.y, angle + PI, length * 0.1);
        pos.y = SCREEN_HEIGHT * 99;
    }
}
function scroll(d) {
    for each (var n in nodes) n.pos.y += d;
    for each (var l in lines) l.pos.y += d;
    nextNodesDist -= d;
    if (nextNodesDist <= 0) {
        addNodes();
        nextNodesDist += SCREEN_HEIGHT;
    }
}
function addNodes() {
    for (var i = 0; i < 16; i++) nodes.push(new Node);
    updateActors(nodes);
    for each (var n in nodes) n.connect();
    for each (n in nodes) n.addConnection();
}
/*----------------------------------------------------------------*/
import flash.display.*;
import flash.filters.*;
import flash.geom.*;
import flash.events.*;
import flash.text.*;
import flash.utils.*;
import flash.desktop.*;
const SCREEN_WIDTH:int = 465, SCREEN_HEIGHT:int = 465;
const SCREEN_CENTER:int = SCREEN_WIDTH / 2;
const DEFAULT_FONT_NAME:String = "_typewriter";
var main:Main, bd:BitmapData;
var ticks:int;
var playButton:PlayButton;
// Initialize a screen, a font and events.
function initializeFirst():void {
    bd = new BitmapData(SCREEN_WIDTH, SCREEN_HEIGHT, false);
    bd.fillRect(bd.rect, 0);
    main.addChild(new Bitmap(bd));
    main.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMoved);
    main.stage.addEventListener(MouseEvent.MOUSE_DOWN, onMousePressed);
    main.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseReleased);
    main.stage.addEventListener(Event.MOUSE_LEAVE, onMouseReleased);
    setDeactivateEvent();
    loadFont();
}
function onFontLoaded():void {
    initializeBlurs();
    cg = new Cg;
    startTitle();
    if (DEBUG) startGame();
    main.addEventListener(Event.ENTER_FRAME, updateFrame);
}
// Update a frame.
function updateFrame(event:Event):void {
    updateInput();
    bd.lock();
    bd.fillRect(bd.rect, 0);
    updateParticles(); updateNumberBoards(); updateMessages();
    if (!isInGame) scoreHistory.draw(SCREEN_WIDTH, 30);
    if (isInGame) { drawScore();  update(); }
    else if (isTitle) updateTitle();
    else { update(); drawGameOver(); }
    bd.unlock();
    ticks++;
    if (isGameOver) {
        gameOverTicks--;
        if (gameOverTicks <= 0 || (gameOverTicks < GAME_OVER_DURATION - 30 && isMousePressed)) startTitle();
    }
}
// Handle a game state (Title/In game/Game over).
const GAME_OVER_DURATION:int = 120;
const START_REPLAY_TICKS:int = 60;
var titleTicks:int, gameOverTicks:int
var score:int, scoreHistory:ScoreHistory = new ScoreHistory;
function startTitle():void {
    removeAllSprites();
    playButton = new PlayButton;
    titleTicks = gameOverTicks = 0;
}
function startGame():void {
    gameOverTicks = -1;
    playButton.hide();
    startRecordInput();
    initializeGame();
}
function initializeGame():void {
    removeAllSprites();
    score = ticks = 0;
    initialize();
}
function startGameOver():void {
    if (!isInGame) return;
    gameOverTicks = GAME_OVER_DURATION;
    stopRecordInput();
    scoreHistory.add(score);
}
function removeAllSprites():void {
    while (main.numChildren > 1) main.removeChildAt(1);
    for each (var m:Message in messages) m.arrow = null;
}
function get isTitle():Boolean { return (gameOverTicks == 0); }
function get isInGame():Boolean { return (gameOverTicks < 0); }
function get isGameOver():Boolean { return (gameOverTicks > 0); }
function updateTitle():void {
    if (inputHistory && titleTicks >= START_REPLAY_TICKS) {
        if (titleTicks == START_REPLAY_TICKS) {
            startReplayInput();
            initializeGame();
        } else {
            if (isReplayInputEnd || isCurrentMousePressed) {
                stopReplayInput();
                startTitle();
            } else {
                drawScore(); update();
            }
        }
    } else {
        playButton.update();
        if (playButton.isPressAndReleased) startGame();
    }
    if (!inputHistory || titleTicks < START_REPLAY_TICKS) drawTitle(TITLE);
    if (inputHistory && titleTicks >= START_REPLAY_TICKS) drawGameOver();
    titleTicks++;
}
function drawScore():void {
    cg.printFromRight(String(score), SCREEN_WIDTH, 0);
}
function drawTitle(title:String):void {
    cg.print(title, 100, 100);
}
function drawGameOver():void {
    cg.print("GAME OVER", 180, 200);
}
/*--------------------------------*/
// Play button on a title.
class PlayButton {
    public const WIDTH:int = 120, HEIGHT:int = 40, ALLOWANCE:int = 32;
    public var button:PrimitiveSprite, plate:PrimitiveSprite;
    public var isPressAndReleased:Boolean, isPressed:Boolean, wasMousePressed:Boolean;
    public function PlayButton() {
        button = new PrimitiveSprite;
        cg.printToSprite(button, "PLAY", 0, 0);
        var bs:PrimitiveShape = new PrimitiveShape(PrimitiveShape.BOX, WIDTH, HEIGHT);
        bs.drawToSprite(button);
        plate = new PrimitiveSprite(new PrimitiveShape(PrimitiveShape.BOX, WIDTH + 8, HEIGHT + 4));
        releaseButton();
        button.x = SCREEN_CENTER; button.y = 300;
        plate.x = button.x; plate.y = button.y;
        wasMousePressed = isMousePressed;
        isPressed = isPressAndReleased = false;
    }
    public function update():void {
        if (isMousePressed) {
            if (mouse.x >= button.x - WIDTH / 2 - ALLOWANCE && mouse.x <= button.x + WIDTH / 2 + ALLOWANCE &&
                mouse.y >= button.y - HEIGHT / 2 - ALLOWANCE && mouse.y <= button.y + HEIGHT / 2 + ALLOWANCE) {
                    if (!wasMousePressed) pressButton();
            } else {
                if (isPressed) releaseButton();
            }
        } else {
            if (isPressed) {
                releaseButton();
                isPressAndReleased = true;
            }
        }
        if (isMousePressed) wasMousePressed = true;
        else wasMousePressed = false;
    }
    public function pressButton():void {
        isPressed = true;
        button.x += 1; button.y += 1;
        plate.alpha = 0.8;
    }
    public function releaseButton():void {
        isPressed = false;
        button.x -= 1; button.y -= 1;
        plate.alpha = 0.5;
    }
    public function hide():void {
        if (!button) return;
        main.removeChild(button); main.removeChild(plate);
        button = plate = null;
    }
}
// Particles.
var particles:Vector.<Particle> = new Vector.<Particle>;
class Particle {
    public static var gravity:Number = 0;
    public static var rect:Rectangle = new Rectangle;
    public static var drawIndex:int, color:int;
    public var pos:Vector3D = new Vector3D, vel:Vector3D = new Vector3D;
    public var size:Number, attenuation:Number;
    public function Particle(x:Number, y:Number, vx:Number, vy:Number, size:int, attenuation:Number) {
        pos.x = x; pos.y = y; vel.x = vx; vel.y = vy;
        this.size = size + 0.9;
        this.attenuation = attenuation;
    }
    public function update():Boolean {
        pos.x += vel.x; pos.y += vel.y;
        vel.y += gravity;
        size *= attenuation;
        return isInScreen(pos) && size >= 1.0;
    }
    public static function setDrawIndex(i:int):void {
        drawIndex = i;
        var bright:int = 0xff - i * 0x55;
        color = bright * 0x10000 + bright * 0x100 + bright;
    }
    public function draw():void {
        var sz:Number = size * (1.0 + drawIndex * 0.5);
        rect.x = pos.x - sz / 2; rect.y = pos.y - sz / 2;
        rect.width = rect.height = sz;
        bd.fillRect(rect, color);
    }
}
function updateParticles():void {
    var i:int;
    for (i = 0; i < particles.length; i++) if (!particles[i].update()) particles.splice(i--, 1);
    for (i = 2; i >= 0; i--) {
        Particle.setDrawIndex(i);
        for each (var p:Particle in particles) p.draw();
    }
}
function addParticle(x:Number, y:Number, vx:Number, vy:Number, size:int = 4, attenuation:Number = 0.95):void {
    particles.push(new Particle(x, y, vx, vy, size, attenuation));
}
function addParticleAngle(x:Number, y:Number, a:Number, s:Number, size:int = 4, attenuation:Number = 0.95, spreading:Number = 0.5):void {
    addParticle(x, y, sin(a) * s, cos(a) * s, size, attenuation);
}
function addParticles(n:int, x:Number, y:Number, vx:Number, vy:Number, size:int = 4, attenuation:Number = 0.95, spreading:Number = 0.5):void {
    var bv:Number = (abs(vx) + abs(vy)) * spreading;
    for (var i:int = 0; i < n; i++) {
        var a:Number = randn(PI * 2), v:Number = randn() * bv;
        particles.push(new Particle(x, y, vx + sin(a) * v, vy + cos(a) * v, size * (0.5 + randn()), attenuation));
    }
}
function addParticlesAngle(n:int, x:Number, y:Number, a:Number, s:Number, size:int = 4, attenuation:Number = 0.95, spreading:Number = 0.5):void {
    addParticles(n, x, y, sin(a) * s, cos(a) * s, size, attenuation, spreading);
}
function addParticlesRound(n:int, x:Number, y:Number, mv:Number, size:int = 4, attenuation:Number = 0.95):void {
    for (var i:int = 0; i < n; i++) {
        var a:Number = randn(PI * 2);
        var v:Number = mv * randn();
        particles.push(new Particle(x, y, sin(a) * v, cos(a) * v, size * (0.5 + randn()), attenuation));
    }
}
// Number boards.
var numberBoards:Vector.<NumberBoard> = new Vector.<NumberBoard>;
class NumberBoard {
    public var pos:Vector3D = new Vector3D, vel:Vector3D = new Vector3D;
    public var ticks:int, score:int, text:String;
    public function NumberBoard(score:int, x:Number, y:Number, ox:Number, oy:Number, ticks:int) {
        this.score = score; this.ticks = ticks; 
        pos.x = x; pos.y = y; vel.x = ox / ticks; vel.y = oy / ticks;
        text = String(score);
    }
    public function update():Boolean {
        pos.x += vel.x; pos.y += vel.y;
        cg.printFromCenter(text, pos.x, pos.y);
        return --ticks > 0;
    }
}
function updateNumberBoards():void {
    for (var i:int = 0; i < numberBoards.length; i++) if (!numberBoards[i].update()) numberBoards.splice(i--, 1); i--;
}
function addNumberBoard(s:int, x:Number, y:Number, ox:Number = 0, oy:Number = -40, ticks:int = 30):void {
    numberBoards.push(new NumberBoard(s, x, y, ox, oy, ticks));
}
// Tutorial messages.
var messages:Vector.<Message> = new Vector.<Message>;
var shownMessages:Vector.<String> = new Vector.<String>;
class Message {
    public var pos:Vector3D = new Vector3D, ticks:int, text:String;
    public var arrow:PrimitiveSprite, arrowAngle:Number;
    public function Message(s:String, x:Number, y:Number, ticks:int, arrowAngle:Number) {
        if (arrowAngle > -9999) {
            arrow = new PrimitiveSprite(new PrimitiveShape(PrimitiveShape.ARROW, 20));
            arrow.angle = this.arrowAngle = arrowAngle;
        }
        text = s; this.ticks = ticks;
        pos.x = x; pos.y = y;
    }
    public function update():Boolean {
        if (arrow) {
            arrow.x = pos.x - sin(arrowAngle) * 24; arrow.y = pos.y - cos(arrowAngle) * 24;
            cg.printFromCenter(text, pos.x - sin(arrowAngle) * 56, pos.y - cos(arrowAngle) * 56 - Cg.PIXEL_HEIGHT / 2);
        } else {
            cg.printFromCenter(text, pos.x, pos.y);
        }
        if (--ticks <= 0) {
            if (arrow) arrow.remove();
            return false;
        }
        return true;
    }
}
function updateMessages():void {
    for (var i:int = 0; i < messages.length; i++) if (!messages[i].update()) messages.splice(i--, 1);
}
function addMessage(s:String, x:Number, y:Number, ticks:int = 90, arrowAngle:Number = -99999):Message {
    if (!isInGame) return null;
    if (shownMessages.indexOf(s) >= 0) return null;
    shownMessages.push(s);
    var m:Message = new Message(s, x, y, ticks, arrowAngle);
    messages.push(m);
    return m;
}
// Primitive shapes.
class PrimitiveShape {
    public static const CIRCLE:int = 0, FILLBOX:int = 1,
        BOX:int = 2, TRIANGLE:int = 3, CROSS:int = 4, BAR:int = 5,
        HUMAN:int = 6, CAR:int = 7, SPRING:int = 8, ARROW:int = 9;
    public static const POINTS:Array = [
        [-10, -10, 10, -10, 10, 10, -10, 10, -10, -10],
        [0, 10, -10, -10, 10, -10, 0, 10],
        [-10, -10, 10, 10, 99, 10, -10, -10, 10],
        [0, -10, 0, 10],
        [0, -10, 0, 0, -10, 10, 99, 0, 0, 10, 10, 99, -10, -3, 10, -3],
        [-7, 10, 7, 10, 99, 0, -10, 0, 10, 99, -10, -10, 10, -10],
        [0, 10, 10, 8, -10, 4, 10, 0, -10, -4, 10, -8, 0, -10],
        [-5, -10, 5, -10, 5, -5, 10, -5, 0, 10, -10, -5, -5, -5, -5, -10],
    ];
    public var sbd:BitmapData, type:int, width:int, height:int;
    public var rect:Rectangle, point:Point = new Point;
    public function PrimitiveShape(type:int, width:int, height:int = -1) {
        this.type = type; this.width = width;
        if (height < 0) height = width;
        this.height = height;
        if (type == 0) {
            sbd = createBlurredBitmapData(function (g:Graphics):void {
                g.lineStyle(2, 0xffffff);
                g.drawEllipse(-width / 2, -height / 2, width, height);
            }, width, height);
        } else if (type == 1) {
            sbd = createBlurredBitmapData(function (g:Graphics):void {
                g.beginFill(0xffffff);
                g.drawRect(-width / 2, -height / 2, width, height);
                g.endFill();
            }, width, height);
        } else {
            var ps:Array = POINTS[type - BOX];
            sbd = createBlurredBitmapData(function (g:Graphics):void {
                g.lineStyle(2, 0xffffff);
                var isMoveTo:Boolean = true, x:int, y:int;
                for (var i:int = 0; i < ps.length; i += 2) {
                    if (ps[i] == 99) { isMoveTo = true; i++; }
                    x = ps[i] * width / 20; y = ps[i + 1] * height / 20;
                    if (isMoveTo) { g.moveTo(x, y); isMoveTo = false; }
                    else g.lineTo(x, y);
                }
            }, width, height);
        }
        rect = new Rectangle(0, 0, width + BLUR_SZ * 2, height + BLUR_SZ * 2);
    }
    public function drawToSprite(s:Sprite, x:Number = 0, y:Number = 0):void {
        var b:Bitmap = new Bitmap(sbd);
        b.x = x - width / 2 - BLUR_SZ;
        b.y = y - height / 2 - BLUR_SZ;
        s.addChild(b);
    }
    public function draw(x:Number, y:Number):void {
        point.x = x - BLUR_SZ - width / 2;
        point.y = y - BLUR_SZ - height / 2;
        bd.copyPixels(sbd, rect, point);
    }
}
class PrimitiveSprite extends Sprite {
    public var isAdded:Boolean;
    public function PrimitiveSprite(shape:PrimitiveShape = null) {
        super();
        x = y = -999;
        if (shape) shape.drawToSprite(this);
        add();
    }
    public function add():void {
        if (isAdded) return;
        main.addChild(this);
        isAdded = true;
    }
    public function remove():void {
        if (!isAdded) return;
        main.removeChild(this);
        isAdded = false;
    }
    public function changeShape(shape:PrimitiveShape):void {
        removeChildAt(0);
        shape.drawToSprite(this);
    }
    public function set pos(p:Vector3D):void {
        x = p.x; y = p.y;
    }
    public function set angle(a:Number):void {
        rotation = -a * 180 / PI;
    }
    public function set scale(v:Number):void {
        scaleX = scaleY = v;
    }
}
// Create a blurred bitmap data.
const BLUR_SZ:int = 40, BLUR_SZ_SKIP:int = 8;
var blurs:Vector.<BlurFilter>;
function initializeBlurs():void {
    blurs = new Vector.<BlurFilter>(BLUR_SZ / BLUR_SZ_SKIP);
    for (var i:int = BLUR_SZ_SKIP; i < BLUR_SZ; i += BLUR_SZ_SKIP) {
        var blur:BlurFilter = new BlurFilter;
        blur.blurX = blur.blurY = i;
        blurs[i / BLUR_SZ_SKIP] = blur;
    }
}
function createBlurredBitmapData(df:Function, w:Number, h:Number):BitmapData {
    var bd:BitmapData = new BitmapData(w + BLUR_SZ * 2, h + BLUR_SZ * 2, true, 0);
    var bs:Sprite = new Sprite;
    var s:Shape = new Shape;
    bs.addChild(s);
    s.x = w / 2 + BLUR_SZ; s.y = h / 2 + BLUR_SZ;
    var g:Graphics = s.graphics;
    df(g);
    bd.lock();
    for (var i:int = 0; i < BLUR_SZ / BLUR_SZ_SKIP; i++) {
        if (i > 0) bs.filters = [blurs[i]];
        bd.draw(bs);
    }
    bd.unlock();
    return bd;
}
// Character graphics plane.
var cg:Cg;
class Cg {
    public static const PIXEL_WIDTH:int = 14, PIXEL_HEIGHT:int = int(PIXEL_WIDTH * 1.4);
    public const SPACING:Number = PIXEL_WIDTH * 0.8;
    public static const FONT_SIZE:int = 15;
    public static const STRINGS:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()_+-=[]\\{}|;':\",./?";
    private var bds:Vector.<BitmapData> = new Vector.<BitmapData>;
    private var rect:Rectangle = new Rectangle(0, 0, PIXEL_WIDTH * 1.4 + BLUR_SZ * 2, PIXEL_HEIGHT * 1.4 + BLUR_SZ * 2);
    public function Cg() {
        for (var i:int = 0; i < STRINGS.length; i++) {
            var bd:BitmapData;
            bd = createCharacterBitmapData(STRINGS.charAt(i));
            bds.push(bd);
        }
    }
    public function printToBitmapData(pbd:BitmapData, s:String, x:Number, y:Number, fromRight:Boolean = false, fromCenter:Boolean = false):void {
        var p:Point = new Point, cbd:BitmapData, px:Number;
        px = x - BLUR_SZ; p.y = y - BLUR_SZ;
        if (fromRight) px -= (s.length + 1) * SPACING;
        else if (fromCenter) px -= (s.length + 1) / 2 * SPACING;
        for (var i:int = 0; i < s.length; i++, px += SPACING) {
            var c:int = STRINGS.indexOf(s.charAt(i));
            if (c >= 0) {
                cbd = bds[c];
                p.x = px; pbd.copyPixels(cbd, rect, p);
            }
        }
    }
    public function print(s:String, x:Number, y:Number, fromRight:Boolean = false, fromCenter:Boolean = false):void {
        printToBitmapData(bd, s, x, y, fromRight, fromCenter);
    }
    public function printFromRight(s:String, x:Number, y:Number):void {
        print(s, x, y, true);
    }
    public function printFromCenter(s:String, x:Number, y:Number):void {
        print(s, x, y, false, true);
    }
    public function printToSprite(sp:Sprite, s:String, x:int, y:int):void {
        var width:Number = (s.length - 1) * SPACING + PIXEL_WIDTH * 1.4;
        var height:Number = PIXEL_WIDTH * 1.4;
        var sbd:BitmapData = new BitmapData(width + BLUR_SZ * 2, height + BLUR_SZ * 2, false, 0);
        printToBitmapData(sbd, s, BLUR_SZ, BLUR_SZ);
        var b:Bitmap = new Bitmap(sbd);
        b.x = x - width / 2 - BLUR_SZ;
        b.y = y - height / 2 - BLUR_SZ;
        sp.addChild(b);
    }
}
const CHARACTER_COLOR:int = 0xffffff;
function createCharacterBitmapData(c:String):BitmapData {
    var bd:BitmapData = new BitmapData(Cg.PIXEL_WIDTH * 1.4 + BLUR_SZ * 2, Cg.PIXEL_HEIGHT * 1.4 + BLUR_SZ * 2, true, 0);
    var bs:Sprite = new Sprite, g:Graphics;
    var t:TextField = createTextField(0, 0, Cg.FONT_SIZE, bd.rect.width, bd.rect.height, CHARACTER_COLOR);
    t.text = c;
    var tm:TextLineMetrics = t.getLineMetrics(0);
    var ofs:Number = Number(Cg.PIXEL_WIDTH * 1.4 - tm.width) / 2;
    var tbd:BitmapData = new BitmapData(Cg.PIXEL_WIDTH * 1.4, Cg.PIXEL_HEIGHT * 1.4, true, 0);
    tbd.draw(t);
    var b:Bitmap = new Bitmap(tbd);
    b.blendMode = BlendMode.ADD;
    bs.addChild(b);
    b.x = ofs + BLUR_SZ; b.y = BLUR_SZ;
    bd.lock();
    for (var i:int = 0; i < BLUR_SZ / BLUR_SZ_SKIP; i++) {
        if (i > 0) bs.filters = [blurs[i]];
        bd.draw(bs);
    }
    bd.unlock();
    return bd;
}
function createTextField(x:int, y:int, size:int, width:int, height:int, color:int, hasSpacing:Boolean = true):TextField {
    var fm:TextFormat = new TextFormat(FONT_NAME), fi:TextField = new TextField;
    fm.size = size; fm.color = color; fm.leftMargin = 0; fm.bold = false;
    if (hasSpacing) fm.letterSpacing = 3;
    fi.defaultTextFormat = fm;
    if (FONT_NAME != DEFAULT_FONT_NAME) fi.embedFonts = true;
    fi.x = x; fi.y = y; fi.width = width; fi.height = height; fi.selectable = false;
    return fi;
}
// Score history.
class ScoreHistory {
    public var scores:Vector.<int> = new Vector.<int>(10);
    public var endIndex:int;
    public function add(s:int):void {
        for (var i:int = scores.length - 1; i > 0; i--) scores[i] = scores[i - 1];
        scores[0] = s;
        if (endIndex < scores.length) endIndex++;
    }
    public function draw(x:int, sy:int):void {
        var y:Number = sy;
        for (var i:int = 0; i < endIndex; i++) {
            cg.printFromRight(String(scores[i]), x, y);
            y += Cg.FONT_SIZE * 1.2;
        }
    }
}
// Vector3D with utility functions.
class Vec extends Vector3D {
    public function Vec(x:Number = 0, y:Number = 0) {
        super(x, y);
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
    public function rotate(a:Number):void {
        var px:Number = x;
        x = x * cos(a) - y * sin(a);
        y = px * sin(a) + y * cos(a);
    }
}
/*--------------------------------*/
// Math utility functions.
var sin:Function = Math.sin, cos:Function = Math.cos, atan2:Function = Math.atan2; 
var sqrt:Function = Math.sqrt, abs:Function = Math.abs;
var PI:Number = Math.PI;
var xorShiftX:int, xorShiftY:int, xorShiftZ:int, xorShiftW:int;
function setRandomSeed(v:int):void {
    var sv:int = v;
    xorShiftX = sv = 1812433253 * (sv ^ (sv >> 30));
    xorShiftY = sv = 1812433253 * (sv ^ (sv >> 30)) + 1;
    xorShiftZ = sv = 1812433253 * (sv ^ (sv >> 30)) + 2;
    xorShiftW = sv = 1812433253 * (sv ^ (sv >> 30)) + 3;
}
function random():Number {
    var t:int = xorShiftX ^ (xorShiftX << 11);
    xorShiftX = xorShiftY; xorShiftY = xorShiftZ; xorShiftZ = xorShiftW;
    xorShiftW = (xorShiftW ^ (xorShiftW >> 19)) ^ (t ^ (t >> 8));
    return Number(xorShiftW) / int.MAX_VALUE;
}
function randi(n:int):int { return random() * n; }
function randn(n:Number = 1):Number { return random() * n; }
function rands(s:Number, w:Number):Number { return (s + randn(w)) * SCREEN_WIDTH; }
function normalizeAngle(a:Number):Number {
    if (a >= PI * 2) return a % (PI * 2);
    else if (a < 0) return PI * 2 + a % (PI * 2);
    return a;
}
function normalizeAnglePm(a:Number):Number {
    a = normalizeAngle(a);
    if (a > PI) return a - PI * 2;
    return a;
}
function getLength(x:Number, y:Number):Number {
    return sqrt(x * x + y * y);
}
function sawtoothWave(x:Number, increment:Number = 0.2):Number {
    return (x % 1) + int(x) * increment;
}
// Screen utility functions.
function isInScreen(p:Vector3D, spacing:Number = 0):Boolean {
    return (p.x >= -spacing && p.x <= SCREEN_WIDTH + spacing && p.y >= -spacing && p.y <= SCREEN_HEIGHT + spacing);
}
function setInScreen(p:Vector3D, spacing:Number = 0):void {
    if (p.x < -spacing) p.x = -spacing;
    else if (p.x > SCREEN_WIDTH + spacing) p.x = SCREEN_WIDTH + spacing;
    if (p.y < -spacing) p.y = -spacing;
    else if (p.y > SCREEN_HEIGHT + spacing) p.y = SCREEN_HEIGHT + spacing;
}
var rectForFill:Rectangle = new Rectangle;
function fillRect(x:Number, y:Number, width:Number, height:Number, color:int):void {
    rectForFill.x = x - width / 2; rectForFill.y = y - height / 2;
    rectForFill.width = width; rectForFill.height = height;
    bd.fillRect(rectForFill, color);
}
// Actor functions.
function initializeActor(a:Actor, type:int, width:int, height:int):void {
    if (Actor.shapes == null) Actor.shapes = new Vector.<PrimitiveShape>;
    if (type < 0) return;
    if (height < 0) height = width;
    for each (var s:PrimitiveShape in Actor.shapes) {
        if (s.type == type && s.width == width && s.height == height) { a.shape = s; break; }
    }
    if (!a.shape) { a.shape = new PrimitiveShape(type, width, height); Actor.shapes.push(a.shape); }
    a.sprite = new PrimitiveSprite(a.shape);
}
function updateActors(actors:Vector.<*>):void {
    for (var i:int = 0; i < actors.length; i++) {
        if (actors[i].update()) {
            if (actors[i].sprite) actors[i].sprite.pos = actors[i].pos;
        } else {
            if (actors[i].sprite) actors[i].sprite.remove();
            actors.splice(i--, 1);
        }
    }
}
// Operation utility functions.
var mouse:Vec = new Vec, isMousePressed:Boolean;
var wasMousePressed:Boolean, isMouseClicked:Boolean;
var prevMouse:Vec = new Vec, mouseVel:Vec = new Vec;
var currentMouse:Vec = new Vec, isCurrentMousePressed:Boolean;
var inputHistory:Vector.<Input>, inputHistoryIndex:int, randomSeed:int;
var isInputRecording:Boolean, isInputReplaying:Boolean;
var mouseSprite:PrimitiveSprite;
class Input {
    public var x:Number, y:Number, isMousePressed:Boolean;
    public function Input(x:Number, y:Number, isMousePressed:Boolean) {
        this.x = x; this.y = y; this.isMousePressed = isMousePressed;
    }
}
function onMousePressed(e:MouseEvent):void { isCurrentMousePressed = true; onMouseMoved(e); }
function onMouseReleased(e:Event):void { isCurrentMousePressed = false; }
function onMouseMoved(e:MouseEvent):void {
    if (e.buttonDown) { currentMouse.x = e.stageX; currentMouse.y = e.stageY; }
}
function updateInput():void {
    if (isInputRecording) recordInput();
    else if (isInputReplaying) replayInput();
    else getCurrentInput();
}
function getCurrentInput():void {
    mouse.x = currentMouse.x; mouse.y = currentMouse.y;
    isMousePressed = isCurrentMousePressed;
    updateMouseClicked(); updateMouseVelocity();
}
function updateMouseClicked():void {
    isMouseClicked = false;
    if (isMousePressed) {
        if (!wasMousePressed) isMouseClicked = wasMousePressed = true;
    } else {
        wasMousePressed = false;
    }
}
function updateMouseVelocity():void {
    mouseVel.x = mouseVel.y = 0;
    if (isMousePressed) {
        if (prevMouse.x > -9999) {
            mouseVel.x = mouse.x - prevMouse.x;
            mouseVel.y = mouse.y - prevMouse.y;
        }
        prevMouse.x = mouse.x; prevMouse.y = mouse.y;
    } else {
        prevMouse.x = -99999;
    }
}
function resetInput():void {
    mouse.x = mouse.y = currentMouse.x = currentMouse.y = SCREEN_CENTER; 
    isMousePressed = isCurrentMousePressed = false;
    wasMousePressed = isMouseClicked = false;
    prevMouse.x = -99999; prevMouse.y = 0;
    mouseVel.x = mouseVel.y = 0;
}
function startRecordInput():void {
    inputHistory = new Vector.<Input>;
    isInputRecording = true;
    setRandomSeed(randomSeed = getTimer());
    resetInput();
}
function recordInput():void {
    getCurrentInput();
    inputHistory.push(new Input(mouse.x, mouse.y, isMousePressed));
}
function stopRecordInput():void {
    inputHistory.push(new Input(-99, -99, false));
    isInputRecording = false;
}
function startReplayInput():void {
    inputHistoryIndex = 0;
    isInputReplaying = true;
    setRandomSeed(randomSeed);
    resetInput();
}
function replayInput():void {
    if (!mouseSprite) mouseSprite = new PrimitiveSprite(new PrimitiveShape(PrimitiveShape.CIRCLE, 15, 15));
    if (!isReplayInputEnd) {
        var i:Input = inputHistory[inputHistoryIndex];
        mouse.x = i.x; mouse.y = i.y; isMousePressed = i.isMousePressed;
        inputHistoryIndex++;
    }
    if (isMousePressed) {
        mouseSprite.visible = true;
        mouseSprite.x = mouse.x; mouseSprite.y = mouse.y;
    } else {
        mouseSprite.visible = false;
    }
    updateMouseClicked(); updateMouseVelocity();
}
function stopReplayInput():void {
    mouseSprite.remove(); mouseSprite = null;
    isInputReplaying = false;
    resetInput();
}
function get isReplayInputEnd():Boolean {
    return (inputHistoryIndex >= inputHistory.length);
}
// Platform dependent part.
// For PC.
const CLICK_STR:String = "CLICK";
// For Android.
//const CLICK_STR:String = "TAP";
// For PC/Android.
//const FONT_NAME:String = "_typewriter";
// For wonderfl.
import net.wonderfl.utils.FontLoader;
const FONT_NAME:String = "Bebas";
function loadFont():void {
    if (FONT_NAME == DEFAULT_FONT_NAME) { onFontLoaded(); return; }
    // For wonderfl.
    var loader:FontLoader = new FontLoader();
    loader.addEventListener(Event.COMPLETE, onFontLoaded);
    loader.load(FONT_NAME);
}
function setDeactivateEvent():void {
    // For Android.
    //main.stage.addEventListener(Event.DEACTIVATE, function (e:Event):void { NativeApplication.nativeApplication.exit(); } );
}
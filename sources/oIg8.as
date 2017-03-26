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
const TITLE = "LASER GRAZE";
const KEYS = ["<>^v"];
const OPERATIONS = ["MOVE"];
var rank, nextLaserTicks, isFirstLaser = true;
function initialize() {
    ship = new Ship;
    lasers = new Vector.<Laser>;
    nextLaserTicks = 0;
}
function update() {
    rank = 1 + sawtoothWave(Number(score) / 10000) * 2;
    ship.update();
    updateActors(lasers);
    if (--nextLaserTicks <= 0) {
        var x = rands(-0.5, 2), y = rands(-0.5, 0.3);
        var tx = rands(0, 1), ty = rands(0, 1);
        var a = atan2(tx - x, ty - y);
        lasers.push(new Laser(x, y, a, randn(5 * rank) + 5, randn(200) + 100));
        nextLaserTicks = 10 / rank;
    }
}
var ship;
class Ship extends Actor {
    static const SIZE = 24;
    var isDestroyed;
    function Ship() {
        super(PrimitiveShape.CIRCLE, SIZE);
        pos.x = pos.y = SCREEN_CENTER;
    }
    function update() {
        if (isDestroyed) return;
        pos.incrementBy(stick(7));
        keepInScreen(pos, -SIZE / 2);
        sprite.pos = pos;
    }
    function destroy() {
        if (isDestroyed) return;
        sprite.remove();
        addParticlesRound(300, pos, 10, 10); isDestroyed = true;
        startGameOver();
    }
}
var lasers;
class Laser extends Actor {
    var angle, speed, width:int, height:int, o = new Vec;
    function Laser(x, y, a, s, h) {
        angle = a; speed = s; width = 10; height = h;
        super(PrimitiveShape.FILLCIRCLE, width, height);
        pos.x = x; pos.y = y; sprite.angle = angle;
    }
    function update() {
        pos.addAngle(angle, speed);
        if (!ship.isDestroyed) checkHit();
        if (isFirstLaser && isInScreen(pos)) {
            addMessage("GRAZE A LASER TO EARN SCORE", 200, 50); 
            isFirstLaser = false;
        }
        return pos.y < SCREEN_HEIGHT + height / 2;
    }
    function checkHit() {
        o.x = ship.pos.x - pos.x; o.y = ship.pos.y - pos.y;
        o.rotate(angle);
        if (abs(o.y) < height / 2) {
            var d = abs(o.x);
            if (d < width / 2) {
                ship.destroy();
            } else if (d < width / 2 + Ship.SIZE) {
                var a = PI / 2;
                if (o.x < 0) a = -a;
                a += angle;
                var n:int = speed * (width / 2 + Ship.SIZE) / d;
                addParticlesAngle(n / 3, ship.pos, a, speed);
                score += n;
            }
        }
    }
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
    main.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPressed);
    main.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyReleased);
    setDeactivateEvent();
    loadFont();
}
function onFontLoaded():void {
    initializeBlurs();
    cg = new Cg;
    virtualPad = new VirtualPad;
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
        if (gameOverTicks <= 0 || (gameOverTicks < GAME_OVER_DURATION - 30 && (isMousePressed || isButtonPressed))) startTitle();
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
const BASE_SPRITE_COUNT:int = 1 + VirtualPad.SPRITE_COUNT;
function removeAllSprites():void {
    while (main.numChildren > BASE_SPRITE_COUNT) main.removeChildAt(1);
    for each (var m:Message in messages) m.arrow = null;
}
function get isTitle():Boolean { return (gameOverTicks == 0); }
function get isInGame():Boolean { return (gameOverTicks < 0); }
function get isGameOver():Boolean { return (gameOverTicks > 0); }
function updateTitle():void {
    if (hasInputHistory && titleTicks >= START_REPLAY_TICKS) {
        if (titleTicks == START_REPLAY_TICKS) {
            startReplayInput();
            initializeGame();
        } else {
            swapCurrentKeys();
            var bpf:Boolean = isButtonPressed;
            swapCurrentKeys();
            if (isReplayInputEnd || isCurrentMousePressed || bpf) {
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
    if (!hasInputHistory || titleTicks < START_REPLAY_TICKS) drawTitle(TITLE, KEYS, OPERATIONS);
    if (hasInputHistory && titleTicks >= START_REPLAY_TICKS) drawGameOver();
    titleTicks++;
}
function drawScore():void {
    cg.printFromRight(String(score), SCREEN_WIDTH, 0);
}
function drawTitle(title:String, buttonStrs:Array, operationStrs:Array):void {
    cg.print(title, 100, 100);
    var y:int = 200;
    for (var i:int = 0; i < buttonStrs.length; i++, y += 30) {
        cg.printKeys(buttonStrs[i], 120, y);
        cg.print(operationStrs[i], 240, y);
    }
    y += 10;
}
function drawGameOver():void {
    cg.print("GAME OVER", 180, 200);
}
/*--------------------------------*/
// Play button on a title.
class PlayButton {
    public const WIDTH:int = 120, HEIGHT:int = 40, ALLOWANCE:int = 32;
    public var button:PrimitiveSprite, plate:PrimitiveSprite;
    public var isPressAndReleased:Boolean, isPressed:Boolean, wasPressed:Boolean;
    public function PlayButton() {
        button = new PrimitiveSprite;
        cg.printToSprite(button, "PLAY", 0, 0);
        var bs:PrimitiveShape = new PrimitiveShape(PrimitiveShape.BOX, WIDTH, HEIGHT);
        bs.drawToSprite(button);
        plate = new PrimitiveSprite(new PrimitiveShape(PrimitiveShape.BOX, WIDTH + 8, HEIGHT + 4));
        releaseButton();
        button.x = SCREEN_CENTER; button.y = 360;
        plate.x = button.x; plate.y = button.y;
        wasPressed = isMousePressed || isButtonPressed;
        isPressed = isPressAndReleased = false;
    }
    public function update():void {
        if (isMousePressed || isButtonPressed) {
            if ((mouse.x >= button.x - WIDTH / 2 - ALLOWANCE && mouse.x <= button.x + WIDTH / 2 + ALLOWANCE &&
                mouse.y >= button.y - HEIGHT / 2 - ALLOWANCE && mouse.y <= button.y + HEIGHT / 2 + ALLOWANCE) ||
                isButtonPressed) {
                    if (!wasPressed) pressButton();
            } else {
                if (isPressed) releaseButton();
            }
        } else {
            if (isPressed) {
                releaseButton();
                isPressAndReleased = true;
            }
        }
        if (isMousePressed || isButtonPressed) wasPressed = true;
        else wasPressed = false;
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
    public function Particle(p:Vector3D, vx:Number, vy:Number, size:int, attenuation:Number) {
        pos.x = p.x; pos.y = p.y; vel.x = vx; vel.y = vy;
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
function addParticles(n:int, p:Vector3D, vx:Number, vy:Number, size:int = 4, attenuation:Number = 0.95, spreading:Number = 0.5):void {
    var bv:Number = (abs(vx) + abs(vy)) * spreading;
    for (var i:int = 0; i < n; i++) {
        var a:Number = randn(PI * 2), v:Number = randn() * bv;
        particles.push(new Particle(p, vx + sin(a) * v, vy + cos(a) * v, size * (0.5 + randn()), attenuation));
    }
}
function addParticlesAngle(n:int, p:Vector3D, a:Number, s:Number, size:int = 4, attenuation:Number = 0.95, spreading:Number = 0.5):void {
    addParticles(n, p, sin(a) * s, cos(a) * s, size, attenuation, spreading);
}
function addParticlesRound(n:int, p:Vector3D, mv:Number, size:int = 4, attenuation:Number = 0.95):void {
    for (var i:int = 0; i < n; i++) {
        var a:Number = randn(PI * 2);
        var v:Number = mv * randn();
        particles.push(new Particle(p, sin(a) * v, cos(a) * v, size * (0.5 + randn()), attenuation));
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
    public static const CIRCLE:int = 0, FILLCIRCLE:int = 1, FILLBOX:int = 2,
        BOX:int = 3, TRIANGLE:int = 4, CROSS:int = 5, BAR:int = 6,
        HUMAN:int = 7, CAR:int = 8, SPRING:int = 9, ARROW:int = 10;
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
        if (type == CIRCLE) {
            sbd = createBlurredBitmapData(function (g:Graphics):void {
                g.lineStyle(2, 0xffffff);
                g.drawEllipse(-width / 2, -height / 2, width, height);
            }, width, height);
        } else if (type == FILLCIRCLE) {
            sbd = createBlurredBitmapData(function (g:Graphics):void {
                g.beginFill(0xffffff);
                g.drawEllipse( -width / 2, -height / 2, width, height);
                g.endFill();
            }, width, height);
        } else if (type == FILLBOX) {
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
        main.addChildAt(this, 1);
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
    public static const FONT_SIZE:int = 15;
    public static const STRINGS:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()_+-=[]\\{}|;':\",./?<>^v";
    private var bds:Vector.<BitmapData> = new Vector.<BitmapData>;
    private var keyBds:Vector.<BitmapData> = new Vector.<BitmapData>;
    private var rect:Rectangle = new Rectangle(0, 0, PIXEL_WIDTH * 1.4 + BLUR_SZ * 2, PIXEL_HEIGHT * 1.4 + BLUR_SZ * 2);
    public function Cg() {
        for (var i:int = 0; i < STRINGS.length; i++) {
            var bd:BitmapData;
            bd = createCharacterBitmapData(STRINGS.charAt(i));
            bds.push(bd);
            bd = createCharacterBitmapData(STRINGS.charAt(i), true);
            keyBds.push(bd);
        }
    }
    public function printToBitmapData(pbd:BitmapData, s:String, x:Number, y:Number, fromRight:Boolean = false, fromCenter:Boolean = false, isKey:Boolean = false):void {
        var p:Point = new Point, cbd:BitmapData, px:Number;
        px = x - BLUR_SZ; p.y = y - BLUR_SZ;
        var spacing:Number = PIXEL_WIDTH * 0.8;
        if (isKey) spacing *= 2;
        if (fromRight) px -= (s.length + 1) * spacing;
        else if (fromCenter) px -= (s.length + 1) / 2 * spacing;
        for (var i:int = 0; i < s.length; i++, px += spacing) {
            var c:int = STRINGS.indexOf(s.charAt(i));
            if (c >= 0) {
                if (isKey) cbd = keyBds[c];
                else cbd = bds[c];
                p.x = px; pbd.copyPixels(cbd, rect, p, null, null, true);
            }
        }
    }
    public function print(s:String, x:Number, y:Number, fromRight:Boolean = false, fromCenter:Boolean = false, isKey:Boolean = false):void {
        printToBitmapData(bd, s, x, y, fromRight, fromCenter, isKey);
    }
    public function printKeys(s:String, x:Number, y:Number):void {
        print(s, x, y, false, false, true);
    }
    public function printFromRight(s:String, x:Number, y:Number):void {
        print(s, x, y, true);
    }
    public function printFromCenter(s:String, x:Number, y:Number):void {
        print(s, x, y, false, true);
    }
    public function printToSprite(sp:Sprite, s:String, x:int, y:int, isKey:Boolean = false):void {
        var width:Number = (s.length - 1) * PIXEL_WIDTH * 0.8 + PIXEL_WIDTH * 1.4;
        var height:Number = PIXEL_WIDTH * 1.4;
        var sbd:BitmapData = new BitmapData(width + BLUR_SZ * 2, height + BLUR_SZ * 2, true, 0);
        printToBitmapData(sbd, s, BLUR_SZ, BLUR_SZ, false, false, isKey);
        var b:Bitmap = new Bitmap(sbd);
        b.x = x - width / 2 - BLUR_SZ;
        b.y = y - height / 2 - BLUR_SZ;
        sp.addChild(b);
    }
}
const CHARACTER_COLOR:int = 0xffffff;
function createCharacterBitmapData(c:String, isKey:Boolean = false):BitmapData {
    var bd:BitmapData = new BitmapData(Cg.PIXEL_WIDTH * 1.4 + BLUR_SZ * 2, Cg.PIXEL_HEIGHT * 1.4 + BLUR_SZ * 2, true, 0);
    var bs:Sprite = new Sprite, g:Graphics;
    if (isKey && (c == '<' || c == '>' || c == "^" || c == "v")) {
        var s:Shape = new Shape;
        g = s.graphics;
        g.lineStyle(2, 0xffffff);
        g.moveTo(0, -Cg.PIXEL_WIDTH * 0.3);
        g.lineTo(0, Cg.PIXEL_WIDTH * 0.3);
        g.lineTo(-Cg.PIXEL_WIDTH * 0.2, Cg.PIXEL_WIDTH * 0.1);
        g.moveTo(0, Cg.PIXEL_WIDTH * 0.3);
        g.lineTo(Cg.PIXEL_WIDTH * 0.2, Cg.PIXEL_WIDTH * 0.1);
        s.blendMode = BlendMode.ADD;
        bs.addChild(s);
        s.x = Cg.PIXEL_WIDTH * 0.7 + BLUR_SZ;
        s.y = Cg.PIXEL_HEIGHT * 0.7 + BLUR_SZ;
        switch (c) {
            case "<": s.rotation = 90; break;
            case "^": s.rotation = 180; break;
            case ">": s.rotation = 270; break;
        }
    } else {
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
    }
    if (isKey) {
        g = bs.graphics;
        g.lineStyle(2, 0xffffff);
        g.moveTo(BLUR_SZ, BLUR_SZ);
        g.lineTo(BLUR_SZ + Cg.PIXEL_WIDTH * 1.4, BLUR_SZ);
        g.lineTo(BLUR_SZ + Cg.PIXEL_WIDTH * 1.4, BLUR_SZ + Cg.PIXEL_HEIGHT * 1.4);
        g.lineTo(BLUR_SZ, BLUR_SZ + Cg.PIXEL_HEIGHT * 1.4);
        g.lineTo(BLUR_SZ, BLUR_SZ);
    }
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
    public function set xy(v:Vector3D):void {
        x = v.x; y = v.y;
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
function keepInScreen(p:Vector3D, spacing:Number = 0):void {
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
var keys:Vector.<Boolean> = new Vector.<Boolean>(256);
var currentKeys:Vector.<Boolean> = new Vector.<Boolean>(256);
var stickVec:Vec = new Vec, stickMVec:Vec = new Vec;
var isWPressed:Boolean, isAPressed:Boolean, isSPressed:Boolean, isDPressed:Boolean;
var virtualPad:VirtualPad;
var mouseHistory:Vector.<Mouse>, mouseHistoryIndex:int;
var keyHistory:Vector.<Key>, keyHistoryIndex:int;
var randomSeed:int;
var isInputRecording:Boolean, isInputReplaying:Boolean;
var mouseSprite:PrimitiveSprite;
class Mouse {
    public var x:Number, y:Number, isPressed:Boolean;
    public function Mouse(x:Number, y:Number, isPressed:Boolean) {
        this.x = x; this.y = y; this.isPressed = isPressed;
    }
}
class Key {
    public var inputTicks:int;
    public var code:int, isPressed:Boolean;
    public function Key(code:int, isPressed:Boolean) {
        this.code = code; this.isPressed = isPressed;
        inputTicks = ticks;
    }
}
class VirtualPad {
    public static const SPRITE_COUNT:int = 12;
    public var centerSprite:PrimitiveSprite;
    public var wSprite:PrimitiveSprite, aSprite:PrimitiveSprite, sSprite:PrimitiveSprite, dSprite:PrimitiveSprite;
    public var lineSprites:Vector.<PrimitiveSprite> = new Vector.<PrimitiveSprite>(4);
    public var panelSprite:PrimitiveSprite;
    public var pos:Vec = new Vec;
    public function VirtualPad() {
        panelSprite = new PrimitiveSprite(new PrimitiveShape(PrimitiveShape.BOX, SCREEN_WIDTH + 1, 1));
        panelSprite.x = SCREEN_CENTER; panelSprite.y = SCREEN_HEIGHT;
        centerSprite = new PrimitiveSprite(new PrimitiveShape(PrimitiveShape.CIRCLE, 10));
        wSprite = new PrimitiveSprite; cg.printToSprite(wSprite, "^", 0, 0, true);
        aSprite = new PrimitiveSprite; cg.printToSprite(aSprite, "<", 0, 0, true);
        sSprite = new PrimitiveSprite; cg.printToSprite(sSprite, "v", 0, 0, true);
        dSprite = new PrimitiveSprite; cg.printToSprite(dSprite, ">", 0, 0, true);
        setCenterPos(SCREEN_CENTER, SCREEN_HEIGHT * 1.12);
        for (var i:int = 0; i < 4; i++) {
            lineSprites[i] = new PrimitiveSprite(new PrimitiveShape(PrimitiveShape.BAR, SCREEN_HEIGHT * 0.1));
            var a:Number;
            switch (i) {
                case 0: a = -PI / 3 * 2; break;
                case 1: a = -PI / 3; break;
                case 2: a =  PI / 3; break;
                case 3: a =  PI / 3 * 2; break;
            }
            lineSprites[i].angle = a;
            lineSprites[i].x = pos.x + sin(a) * SCREEN_HEIGHT * 0.07;
            lineSprites[i].y = pos.y + cos(a) * SCREEN_HEIGHT * 0.07;
        }
        addCoverSprites(-SCREEN_HEIGHT); addCoverSprites(SCREEN_HEIGHT);
    }
    public function update():void {
        if (isMousePressed) {
            var a:Number = mouse.angle(pos);
            isWPressed = (a <= -PI / 3 * 2 || a >= PI / 3 * 2);
            isAPressed = (a < -PI / 3 && a > -PI / 3 * 2);
            isSPressed = (a <= PI / 3 && a >= -PI / 3);
            isDPressed = (a < PI / 3 * 2 && a > PI / 3);
        }
    }
    public function setCenterPos(x:Number, y:Number):void {
        pos.x = x; pos.y = y;
        centerSprite.pos = pos;
        wSprite.x = pos.x; wSprite.y = pos.y - SCREEN_HEIGHT * 0.07 - 4;
        aSprite.x = pos.x - SCREEN_HEIGHT * 0.1; aSprite.y = pos.y - 4;
        sSprite.x = pos.x; sSprite.y = pos.y + SCREEN_HEIGHT * 0.07 - 4;
        dSprite.x = pos.x + SCREEN_HEIGHT * 0.1; dSprite.y = pos.y - 4;
    }
    public function addCoverSprites(y:int):void {
        var s:Sprite = new Sprite;
        var g:Graphics = s.graphics;
        g.beginFill(0);
        g.drawRect(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        g.endFill();
        s.x = 0; s.y = y;
        main.addChildAt(s, 1);
    }
}
function onMousePressed(e:MouseEvent):void { isCurrentMousePressed = true; onMouseMoved(e); }
function onMouseReleased(e:Event):void { isCurrentMousePressed = false; }
function onMouseMoved(e:MouseEvent):void {
    if (e.buttonDown) { currentMouse.x = e.stageX; currentMouse.y = e.stageY; }
}
function onKeyPressed(e:KeyboardEvent):void { currentKeys[e.keyCode] = true; }
function onKeyReleased(e:KeyboardEvent):void { currentKeys[e.keyCode] = false; }
function updateInput():void {
    if (isInputRecording) recordInput();
    else if (isInputReplaying) replayInput();
    else getCurrentInput();
}
function getCurrentInput():void {
    mouse.x = currentMouse.x; mouse.y = currentMouse.y;
    isMousePressed = isCurrentMousePressed;
    updateMouseClicked(); updateMouseVelocity();
    for (var i:int = 0; i < 256; i++) keys[i] = currentKeys[i];
    updateStick();
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
function updateStick():void {
    isWPressed = isAPressed = isSPressed = isDPressed = false;
    if (virtualPad) virtualPad.update();
    isWPressed ||= (keys[0x26] || keys[0x57]);
    isAPressed ||= (keys[0x25] || keys[0x41]);
    isSPressed ||= (keys[0x28] || keys[0x53]);
    isDPressed ||= (keys[0x27] || keys[0x44]);
    stickVec.x = stickVec.y = 0;
    if (isWPressed) stickVec.y -= 1;
    if (isAPressed) stickVec.x -= 1;
    if (isSPressed) stickVec.y += 1;
    if (isDPressed) stickVec.x += 1;
    if (stickVec.x != 0 && stickVec.y != 0) { stickVec.x *= 0.7; stickVec.y *= 0.7; }
}
function stick(m:Number = 1):Vec {
    stickMVec.x = stickVec.x * m; stickMVec.y = stickVec.y * m;
    return stickMVec;
}
function get isButtonPressed():Boolean {
    return keys[0x5a] || keys[0xbe] || keys[0x20] || keys[0x58] || keys[0xbf];
}
function swapCurrentKeys():void {
    for (var i:int = 0; i < 256; i++) {
        var ck:Boolean = currentKeys[i]; currentKeys[i] = keys[i]; keys[i] = ck;
    }
}
function resetInput():void {
    mouse.x = mouse.y = currentMouse.x = currentMouse.y = SCREEN_CENTER; 
    isMousePressed = isCurrentMousePressed = false;
    wasMousePressed = isMouseClicked = false;
    prevMouse.x = -99999; prevMouse.y = 0;
    mouseVel.x = mouseVel.y = 0;
    for (var i:int = 0; i < 256; i++) keys[i] = currentKeys[i] = 0;
}
function startRecordInput():void {
    mouseHistory = new Vector.<Mouse>; keyHistory = new Vector.<Key>;
    isInputRecording = true;
    setRandomSeed(randomSeed = getTimer());
    resetInput();
}
function recordInput():void {
    for (var i:int = 0; i < 256; i++) {
        if (keys[i] != currentKeys[i]) keyHistory.push(new Key(i, currentKeys[i]));
    }
    getCurrentInput();
    mouseHistory.push(new Mouse(mouse.x, mouse.y, isMousePressed));
}
function stopRecordInput():void {
    isInputRecording = false;
}
function startReplayInput():void {
    mouseHistoryIndex = keyHistoryIndex = 0;
    isInputReplaying = true;
    setRandomSeed(randomSeed);
    resetInput();
}
function replayInput():void {
    if (!mouseSprite) mouseSprite = new PrimitiveSprite(new PrimitiveShape(PrimitiveShape.CIRCLE, 15, 15));
    if (!isReplayInputEnd) {
        var m:Mouse = mouseHistory[mouseHistoryIndex];
        mouse.x = m.x; mouse.y = m.y; isMousePressed = m.isPressed;
        mouseHistoryIndex++;
        while (keyHistoryIndex < keyHistory.length) {
            var k:Key = keyHistory[keyHistoryIndex];
            if (k.inputTicks > ticks) break;
            keys[k.code] = k.isPressed;
            keyHistoryIndex++;
        }
    } else {
        resetInput();
    }
    if (isMousePressed) {
        mouseSprite.visible = true;
        mouseSprite.x = mouse.x; mouseSprite.y = mouse.y;
    } else {
        mouseSprite.visible = false;
    }
    updateMouseClicked(); updateMouseVelocity();
    updateStick();
}
function stopReplayInput():void {
    mouseSprite.remove(); mouseSprite = null;
    isInputReplaying = false;
    resetInput();
}
function get isReplayInputEnd():Boolean {
    return (mouseHistoryIndex >= mouseHistory.length);
}
function get hasInputHistory():Boolean {
    return (mouseHistory != null);
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
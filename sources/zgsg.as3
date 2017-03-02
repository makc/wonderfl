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
const TITLE = "SPIKE TUBES";
var rank, nextSpikeTicks, nextShrinkScore;
function initialize() {
    ship = new Ship;
    shot = null;
    tubes = new Vector.<Tube>(5);
    for (var i = 0; i < tubes.length; i++) tubes[i] = new Tube(SCREEN_WIDTH / (tubes.length + 1) * (1 + i));
    spikes = new Vector.<Spike>;
    nextSpikeTicks = 0;
    nextShrinkScore = 10000;
    addMessage(CLICK_STR + "/DRAG TO MOVE", 150, 400);
}
function update() {
    rank = 1 + sawtoothWave(Number(score) / 10000) * 2;
    if (score >= nextShrinkScore) {
        nextShrinkScore += 10000;
        for each (var t in tubes) t.isShrinking = true;
    }
    ship.update();
    if (isMousePressed || ship.isMoving) {
        if (shot) shot.update();
        updateActors(tubes);
        updateActors(spikes);
        if (--nextSpikeTicks <= 0) {
            spikes.push(new Spike);
            nextSpikeTicks += 9 / rank;
        }
    }
}
var ship;
class Ship extends Actor {
    const SIZE = 20, SPEED = 7;
    var target = new Vec, targetSprite, isMoving, isDestroyed;
    var pm = new Vec, vm = new Vec(99999), isPressed;
    function Ship() {
        super(PrimitiveShape.TRIANGLE, SIZE);
        pos.x = target.x = SCREEN_CENTER; pos.y = target.y = SCREEN_HEIGHT * 0.7;
        sprite.angle = PI;
        targetSprite = new PrimitiveSprite(new PrimitiveShape(PrimitiveShape.CIRCLE, 15, 15));
        targetSprite.alpha = 0.7;
    }
    function update() {
        if (isDestroyed) return;
        if (isMousePressed) {
            if (!isPressed) {
                vm.x = vm.y = 0; isPressed = true;
                target.x = pos.x; target.y = pos.y;
            }
            target.x += mouseVel.x; target.y += mouseVel.y;
            vm.x += mouseVel.x; vm.y += mouseVel.y;
            setMoving();
            pm.x = mouse.x; pm.y = mouse.y;
        } else {
            if (vm.length < 16) {
                target.x = pm.x; target.y = pm.y;
                setMoving();
            }
            isPressed = false;
        }
        if (isMoving) {
            if (target.distance(pos) <= SPEED) {
                pos.x = target.x; pos.y = target.y; isMoving = false;
                targetSprite.visible = false;
            } else {
                var a = target.angle(pos);
                pos.addAngle(a, SPEED);
            }
        }
        if (!shot) shot = new Shot(pos);
        for each (var s in spikes) {
            if (s.pos.distance(pos) < 10) {
                destroy();
                return;
            }
        }
        sprite.pos = pos;
    }
    function setMoving() {
        isMoving = true;
        setInScreen(target, SIZE / 2);
        targetSprite.x = target.x; targetSprite.y = target.y;
        targetSprite.visible = true;
    }
    function destroy() {
        if (isDestroyed) return;
        addParticlesRound(200, pos.x, pos.y, 15, 10);
        startGameOver();
        isDestroyed = true;
        targetSprite.visible = false;
        sprite.remove();
    }
}
var shot;
class Shot extends Actor {
    static const SIZE = 64;
    function Shot(p) {
        super(PrimitiveShape.BAR, SIZE);
        sprite.angle = PI / 2;
        pos.x = p.x; pos.y = p.y;
    }
    function update() {
        pos.y -= 10;
        for each (var t in tubes) {
            if (abs(pos.x - t.pos.x) < (SIZE + Tube.WIDTH) / 2 && pos.y < t.length) {
                t.damage(); sprite.remove(); shot = null; return;
            }
        }
        sprite.pos = pos;
        if (pos.y <= 0) { sprite.remove(); shot = null; }
    }
}
var tubes;
class Tube extends Actor {
    static const WIDTH = 16, HEIGHT = 128, START_HEIGHT = 32;
    var length, isShrinking;
    function Tube(x) {
        super(PrimitiveShape.BOX, WIDTH, HEIGHT);
        pos.x = x;
        length = START_HEIGHT;
        sprite.scaleY = length / HEIGHT; pos.y = length / 2;
        sprite.pos = pos;
    }
    function update() {
        if (isShrinking) {
            length -= 2;
            if (length < START_HEIGHT) {
                length = START_HEIGHT; isShrinking = false;
            }
        } else {
            length += 0.5 * rank;
        }
        if (length >= SCREEN_HEIGHT) {
            if (!ship.isDestroyed) {
                addParticlesRound(200, pos.x, SCREEN_HEIGHT, 15, 8);
                ship.destroy();
            }
        }
        sprite.scaleY = length / HEIGHT; pos.y = length / 2;
        sprite.pos = pos;
        return true;
    }
    function damage() {
        addParticlesAngle(20, pos.x, pos.y, PI, 10, 5);
        addNumberBoard(length, pos.x, length);
        score += length;
        length -= 64 * rank;
        if (length < START_HEIGHT) length = START_HEIGHT;
    }
}
var spikes;
class Spike extends Actor {
    const SIZE = 15;
    var tube, isInTube = true, speed, vel = new Vec, angle = 0;
    function Spike() {
        super(PrimitiveShape.TRIANGLE, SIZE * 0.7, SIZE);
        tube = tubes[randi(tubes.length)];
        pos.x = tube.pos.x; pos.y = SIZE / 2;
        speed = 2 + randn(1 + rank) + randn(1 + rank);
    }
    function update() {
        if (isInTube) {
            pos.y += speed; 
            if (pos.y >= tube.length) {
                isInTube = false;
                var a = ship.pos.angle(pos);
                vel.addAngle(a, speed);
                sprite.angle = a;
                addParticlesAngle(10, pos.x, pos.y, 0, speed, 4, 0.9, 0.9);
            }
        } else {
            pos.incrementBy(vel);
            if (!isInScreen(pos, SIZE)) return false;
        }
        sprite.pos = pos;
        return true;
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
const SCREEN_WIDTH:int = 465;
const SCREEN_HEIGHT:int = 465;
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
    for each (var m:Message in messages) m.hasArrow = false;
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
class Message extends Actor {
    public var vel:Vector3D = new Vector3D;
    public var ticks:int, text:String, hasArrow:Boolean;
    public function Message(s:String, x:Number, y:Number, vx:Number, vy:Number, ticks:int, hasArrow:Boolean) {
        var type:int = -1;
        if (hasArrow) type = PrimitiveShape.ARROW;
        super(type, 20);
        if (hasArrow) {
            sprite.angle = PI / 4;
            this.hasArrow = true;
            x -= 48; y -= 48;
        }
        text = s; this.ticks = ticks;
        pos.x = x; pos.y = y; vel.x = vx; vel.y = vy;
    }
    public function update():Boolean {
        pos.x += vel.x; pos.y += vel.y;
        cg.printFromCenter(text, pos.x, pos.y);
        if (hasArrow) { sprite.x = pos.x + 32; sprite.y = pos.y + 32; }
        return --ticks > 0;
    }
}
function updateMessages():void {
    for (var i:int = 0; i < messages.length; i++) if (!messages[i].update()) {
        if (messages[i].hasArrow) messages[i].sprite.remove();
        messages.splice(i--, 1);
    }
}
function addMessage(s:String, x:Number, y:Number, ox:Number = 0, oy:Number = 0, ticks:int = 90, hasArrow:Boolean = false):void {
    if (!isInGame) return;
    if (shownMessages.indexOf(s) >= 0) return;
    shownMessages.push(s);
    messages.push(new Message(s, x, y, ox, oy, ticks, hasArrow));
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
    public function PrimitiveShape(type:int, width:int, height:int) {
        this.type = type; this.width = width; this.height = height;
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
    public function drawToSprite(s:Sprite):void {
        var b:Bitmap = new Bitmap(sbd);
        b.x = -width / 2 - BLUR_SZ;
        b.y = -height / 2 - BLUR_SZ;
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
    for (var i:int = 0; i < actors.length; i++) if (!actors[i].update()) {
        if (actors[i].sprite) actors[i].sprite.remove();
        actors.splice(i--, 1);
    }
}
// Operation utility functions.
var mouse:Vec = new Vec, isMousePressed:Boolean;
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
function updateInput():void {
    if (isInputRecording) recordInput();
    else if (isInputReplaying) replayInput();
    else getCurrentInput();
}
function getCurrentInput():void {
    mouse.x = currentMouse.x; mouse.y = currentMouse.y;
    isMousePressed = isCurrentMousePressed;
    updateMouseVelocity();
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
    updateMouseVelocity();
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
function setDeactivateEvent() {
    // For Android.
    //main.stage.addEventListener(Event.DEACTIVATE, function (e:Event):void { NativeApplication.nativeApplication.exit(); } );
}
function onMouseMoved(e:MouseEvent):void {
    // For PC.
    currentMouse.x = e.stageX; currentMouse.y = e.stageY;
    // For Android.
    /*if (e.buttonDown) {
        currentMouse.x = e.stageX; currentMouse.y = e.stageY;
    }*/
}
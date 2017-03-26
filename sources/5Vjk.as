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
    public var shape:PrimitiveShape;
    public var sprite:PrimitiveSprite;
    public var pos:Vec = new Vec;
    public function Actor(type:int, size:int) {
        if (shapes == null) shapes = new Vector.<PrimitiveShape>;
        for each (var s:PrimitiveShape in shapes) {
            if (s.type == type && s.width == size) { shape = s; break; }
        }
        if (!shape) { shape = new PrimitiveShape(type, size, size); shapes.push(shape); }
        sprite = new PrimitiveSprite(shape);
    }
}
/*----------------------------------------------------------------*/
const TITLE = "SQUARE RAILS";
const KEYS = ["<>^v"];
const OPERATIONS = ["MOVE"];
var rank;
function initialize() {
    player = new Player;
    route = new Route;
}
function update() {
    rank = 1 + sawtoothWave(Number(score) / 10000) * 3;
    player.update();
    route.update();
}
var player;
class Player extends Actor {
    const SIZE = 24;
    var ofs = 0, dir:int = 0, isDestroyed = false;
    function Player() {
        super(PrimitiveShape.CIRCLE, SIZE);
        sprite.x = sprite.y = SCREEN_CENTER;
    }
    function update() {
        if (isDestroyed) return;
        ofs += 0.05 * rank;
        if (ofs >= 1.0) {
            ofs -= 1.0;
            switch (dir) {
                case 0: route.scrollVP(); break;
                case 1: route.scrollHM(); break;
                case 2: route.scrollVM(); break;
                case 3: route.scrollHP(); break;
            }
            switch (dir) {
                case 0: route.removeV(Route.COUNT / 2, Route.COUNT / 2 - 1); break;
                case 1:    route.removeH(Route.COUNT / 2, Route.COUNT / 2); break;
                case 2: route.removeV(Route.COUNT / 2, Route.COUNT / 2); break;
                case 3: route.removeH(Route.COUNT / 2 - 1, Route.COUNT / 2); break;
            }
            if (isSPressed && route.vRoutes[Route.COUNT / 2 + Route.COUNT * Route.COUNT / 2]) dir = 0;
            if (isAPressed && route.hRoutes[Route.COUNT / 2 - 1 + Route.COUNT * Route.COUNT / 2]) dir = 1;
            if (isWPressed && route.vRoutes[Route.COUNT / 2 + Route.COUNT * (Route.COUNT / 2 - 1)]) dir = 2;
            if (isDPressed && route.hRoutes[Route.COUNT / 2 + Route.COUNT * Route.COUNT / 2]) dir = 3;
            for (var i = 0; i < 4; i++) {
                var pd = dir;
                switch (dir) {
                    case 0: if (!route.vRoutes[Route.COUNT / 2 + Route.COUNT * Route.COUNT / 2]) dir++; break;
                    case 1: if (!route.hRoutes[Route.COUNT / 2 - 1 + Route.COUNT * Route.COUNT / 2]) dir++; break;
                    case 2: if (!route.vRoutes[Route.COUNT / 2 + Route.COUNT * (Route.COUNT / 2 - 1)]) dir++; break;
                    case 3:    if (!route.hRoutes[Route.COUNT / 2 + Route.COUNT * Route.COUNT / 2]) dir = 0; break;
                }
                if (pd == dir) break;
            }
            if (i == 4) {
                addParticlesRound(256, SCREEN_CENTER, SCREEN_CENTER, 10, 10);
                startGameOver();
                sprite.remove();
                isDestroyed = true;
            }
        }
        switch (dir) {
            case 0: pos.x = 0; pos.y = Route.SIZE * ofs; break;
            case 1: pos.x = -Route.SIZE * ofs; pos.y = 0; break;
            case 2: pos.x = 0; pos.y = -Route.SIZE * ofs; break;
            case 3: pos.x = Route.SIZE * ofs; pos.y = 0; break;
        }
    }
}
var route;
class Route {
    static const COUNT = 6 * 2, SIZE = SCREEN_WIDTH / (COUNT / 2);
    var hRoutes, vRoutes;
    var hShape, vShape;
    function Route() {
        hShape = new PrimitiveShape(PrimitiveShape.BOX, SIZE * 0.9, SIZE * 0.05);
        vShape = new PrimitiveShape(PrimitiveShape.BOX, SIZE * 0.05, SIZE * 0.9);
        hRoutes = new Vector.<Boolean>(COUNT * COUNT);
        vRoutes = new Vector.<Boolean>(COUNT * COUNT);
        for (var x = 0; x < COUNT; x++) for (var y = 0; y < COUNT; y++) {
            if (abs(x - COUNT / 2) + abs(y - COUNT / 2) < 3) {
                hRoutes[x + y * COUNT] = vRoutes[x + y * COUNT] = true;
            } else {
                hRoutes[x + y * COUNT] = (randi(3) > 0);
                vRoutes[x + y * COUNT] = (randi(3) > 0);
            }
        }
    }
    function update() {
        for (var x = 0; x < COUNT; x++) for (var y = 0; y < COUNT; y++) {
            if (hRoutes[x + y * COUNT]) {
                hShape.draw((x - COUNT / 4 + 0.5) * SIZE - player.pos.x, (y - COUNT / 4) * SIZE - player.pos.y);
            }
            if (vRoutes[x + y * COUNT]) {
                vShape.draw((x - COUNT / 4) * SIZE - player.pos.x, (y - COUNT / 4 + 0.5) * SIZE - player.pos.y);
            }
        }
    }
    function scrollHP() {
        for (var x = 0; x < COUNT - 1; x++) for (var y = 0; y < COUNT; y++) {
            hRoutes[x + y * COUNT] = hRoutes[x + 1 + y * COUNT];
            vRoutes[x + y * COUNT] = vRoutes[x + 1 + y * COUNT];
        }
        addNewRoutesV(COUNT - 1);
    }
    function scrollHM() {
        for (var x = COUNT - 2; x >= 0; x--) for (var y = 0; y < COUNT; y++) {
            hRoutes[x + 1 + y * COUNT] = hRoutes[x + y * COUNT];
            vRoutes[x + 1 + y * COUNT] = vRoutes[x + y * COUNT];
        }
        addNewRoutesV(0);
    }
    function addNewRoutesV(x) {
        for (var y = 0; y < COUNT; y++) {
            hRoutes[x + y * COUNT] = (randi(3) > 0);
            vRoutes[x + y * COUNT] = (randi(3) > 0);
        }
    }
    function scrollVP() {
        for (var x = 0; x < COUNT; x++) for (var y = 0; y < COUNT - 1; y++) {
            hRoutes[x + y * COUNT] = hRoutes[x + (y + 1) * COUNT];
            vRoutes[x + y * COUNT] = vRoutes[x + (y + 1) * COUNT];
        }
        addNewRoutesH(COUNT - 1);
    }
    function scrollVM() {
        for (var x = 0; x < COUNT; x++) for (var y = COUNT - 2; y >= 0; y--) {
            hRoutes[x + (y + 1) * COUNT] = hRoutes[x + y * COUNT];
            vRoutes[x + (y + 1) * COUNT] = vRoutes[x + y * COUNT];
        }
        addNewRoutesH(0);
    }
    function addNewRoutesH(y) {
        for (var x = 0; x < COUNT; x++) {
            hRoutes[x + y * COUNT] = (randi(3) > 0);
            vRoutes[x + y * COUNT] = (randi(3) > 0);
        }
    }
    function removeH(x, y) {
        hRoutes[x + y * COUNT] = false;
        addScore(x, y - 1); addScore(x, y);
        addParticles(30, (x - COUNT / 4 + 0.5) * SIZE, (y - COUNT / 4) * SIZE, 5, 0, 2, 0.97, 0.3);
        addParticles(30, (x - COUNT / 4 + 0.5) * SIZE, (y - COUNT / 4) * SIZE, -5, 0, 2, 0.97, 0.3);
    }
    function removeV(x, y) {
        vRoutes[x + y * COUNT] = false;
        addScore(x - 1, y); addScore(x, y);
        addParticles(30, (x - COUNT / 4) * SIZE, (y - COUNT / 4 + 0.5) * SIZE, 0, 5, 2, 0.97, 0.3);
        addParticles(30, (x - COUNT / 4) * SIZE, (y - COUNT / 4 + 0.5) * SIZE, 0, -5, 2, 0.97, 0.3);
    }
    function addScore(x, y) {
        var rc:int = 0, sc = 0;
        if (hRoutes[x + y * COUNT]) rc++;
        if (hRoutes[x + (y + 1) * COUNT]) rc++;
        if (vRoutes[x + y * COUNT]) rc++;
        if (vRoutes[x + 1 + y * COUNT]) rc++;
        switch (rc) {
            case 0: sc = 160; break;
            case 1: sc = 90; break;
            case 2: sc = 40; break;
            case 3: sc = 10; break;
        }
        addNumberBoard(sc, (x - COUNT / 4 + 0.5) * SIZE, (y - COUNT / 4 + 0.5) * SIZE);
        score += sc;
    }
}
/*----------------------------------------------------------------*/
import flash.display.*;
import flash.filters.*;
import flash.geom.*;
import flash.events.*;
import flash.text.*;
import flash.utils.*;
const SCREEN_WIDTH:int = 465;
const SCREEN_HEIGHT:int = 465;
const SCREEN_CENTER:int = 465 / 2;
var main:Main, bd:BitmapData;
// Initialize a bitmap, a font and events.
function initializeFirst():void {
    bd = new BitmapData(SCREEN_WIDTH, SCREEN_HEIGHT, false);
    bd.fillRect(bd.rect, 0);
    main.addChild(new Bitmap(bd));
    main.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPressed);
    main.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyReleased);
    setRandomSeed(getTimer());
    loadFont();
}
function onFontLoaded():void {
    initializeBlurs();
    cg = new Cg;
    startTitle();
    main.addEventListener(Event.ENTER_FRAME, updateFrame);
}
// Update a frame.
const GAME_OVER_DURATION:int = 120;
const START_REPLAY_TICKS:int = 60;
var ticks:int;
var isStartButtonPressed:Boolean;
function updateFrame(event:Event):void {
    updateKeys();
    bd.lock();
    bd.fillRect(bd.rect, 0);
    updateParticles();
    updateNumberBoards();
    if (!isInGame) scoreHistory.draw(SCREEN_WIDTH, 30);
    if (isInGame) { drawScore();  update(); }
    else if (isTitle) updateTitle();
    else { drawGameOver(); update(); }
    bd.unlock();
    ticks++;
    if (gameOverTicks > 0) {
        gameOverTicks--;
        if (gameOverTicks == 0) startTitle();
    }
    if (!isInGame) {
        swapCurrentKeys();
        if (gameOverTicks < GAME_OVER_DURATION - 30 && isButtonPressed) {
            isStartButtonPressed = true;
        } else {
            if (isStartButtonPressed) startGame();
            isStartButtonPressed = false;
        }
        swapCurrentKeys();
    } else {
        if (isEscPressed) startGameOver();
    }
}
function updateTitle():void {
    if (keyHistory && titleTicks >= START_REPLAY_TICKS) {
        if (titleTicks == START_REPLAY_TICKS) {
            startReplayKeys();
            initializeGame();
        }
        if (isReplayKeysEnd) {
            stopReplayKeys();
            startTitle();
        } else {
            drawScore(); update();
        }
    }
    if (!keyHistory || titleTicks < START_REPLAY_TICKS) drawTitle(TITLE, KEYS, OPERATIONS, "Z");
    if (keyHistory && titleTicks >= START_REPLAY_TICKS) drawGameOver();
    titleTicks++;
}
function drawScore():void {
    cg.printFromRight(String(score), SCREEN_WIDTH, 0);
}
function drawGameOver():void {
    cg.print("GAME OVER", 180, 200);
}
// Handle a game state (Title/In game/Game over).
var titleTicks:int, gameOverTicks:int
var score:int, scoreHistory:ScoreHistory = new ScoreHistory;
function startTitle():void {
    removeAllSprites();
    titleTicks = gameOverTicks = 0;
}
function startGame():void {
    startRecordKeys();
    initializeGame();
    gameOverTicks = -1;
}
function initializeGame():void {
    removeAllSprites();
    score = ticks = 0;
    initialize();
}
function startGameOver():void {
    if (!isInGame) return;
    stopRecordKeys();
    scoreHistory.add(score);
    gameOverTicks = GAME_OVER_DURATION;
}
function get isTitle():Boolean { return (gameOverTicks == 0); }
function get isInGame():Boolean { return (gameOverTicks < 0); }
function get isGameOver():Boolean { return (gameOverTicks > 0); }
function updateActors(actors:Vector.<*>):void {
    for (var i:int = 0; i < actors.length; i++) if (!actors[i].update()) {
        actors[i].sprite.remove();
        actors.splice(i--, 1);
    }
}
/*--------------------------------*/
// Particles.
var particles:Vector.<Particle> = new Vector.<Particle>;
class Particle {
    public static var gravity:Number = 0;
    public static var rect:Rectangle = new Rectangle;
    public static var drawIndex:int, color:int;
    public var pos:Vector3D = new Vector3D;
    public var vel:Vector3D = new Vector3D;
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
    for (i = 0; i < particles.length; i++) if (!particles[i].update()) { particles.splice(i, 1); i--; }
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
        var a:Number = randn(PI * 2), v:Number = randn(1) * bv;
        particles.push(new Particle(x, y, vx + sin(a) * v, vy + cos(a) * v, size * (0.5 + randn()), attenuation));
    }
}
function addParticlesAngle(n:int, x:Number, y:Number, a:Number, s:Number, size:int = 4, attenuation:Number = 0.95, spreading:Number = 0.5):void {
    addParticles(n, x, y, sin(a) * s, cos(a) * s, size, attenuation, spreading);
}
function addParticlesRound(n:int, x:Number, y:Number, mv:Number, size:int = 4, attenuation:Number = 0.95):void {
    for (var i:int = 0; i < n; i++) {
        var a:Number = randn(PI * 2);
        var v:Number = mv * randn(1);
        particles.push(new Particle(x, y, sin(a) * v, cos(a) * v, size * (0.5 + randn()), attenuation));
    }
}
// Number boards.
var numberBoards:Vector.<NumberBoard> = new Vector.<NumberBoard>;
class NumberBoard {
    public var pos:Vector3D = new Vector3D;
    public var vel:Vector3D = new Vector3D;
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
    for (var i:int = 0; i < numberBoards.length; i++) if (!numberBoards[i].update()) { numberBoards.splice(i, 1); i--; }
}
function addNumberBoard(s:int, x:Number, y:Number, ox:Number = 0, oy:Number = -40, ticks:int = 30):void {
    numberBoards.push(new NumberBoard(s, x, y, ox, oy, ticks));
}
// Primitive shapes.
class PrimitiveShape {
    public static const CIRCLE:int = 0, BOX:int = 1, TRIANGLE:int = 2,
        CROSS:int = 3, BAR:int = 4, HUMAN:int = 5, CAR:int = 6, SPRING:int = 7,
        COUNT:int = 8;
    public static const POINTS:Array = [
        [-10, -10, 10, -10, 10, 10, -10, 10, -10, -10],
        [0, 10, -10, -10, 10, -10, 0, 10],
        [-10, -10, 10, 10, 99, 10, -10, -10, 10],
        [0, -10, 0, 10],
        [0, -10, 0, 0, -10, 10, 99, 0, 0, 10, 10, 99, -10, -3, 10, -3],
        [-7, 10, 7, 10, 99, 0, -10, 0, 10, 99, -10, -10, 10, -10],
        [0, 10, 10, 8, -10, 4, 10, 0, -10, -4, 10, -8, 0, -10],
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
        } else {
            var ps:Array = POINTS[type - 1];
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
        rect = new Rectangle(0, 0, width + BLUR_SIZE * 2, height + BLUR_SIZE * 2);
    }
    public function drawToSprite(s:Sprite):void {
        var b:Bitmap = new Bitmap(sbd);
        b.x = -width / 2 - BLUR_SIZE;
        b.y = -height / 2 - BLUR_SIZE;
        s.addChild(b);
    }
    public function draw(x:Number, y:Number):void {
        point.x = x - BLUR_SIZE - width / 2;
        point.y = y - BLUR_SIZE - height / 2;
        bd.copyPixels(sbd, rect, point);
    }
}
class PrimitiveSprite extends Sprite {
    public var isAdded:Boolean;
    public function PrimitiveSprite(shape:PrimitiveShape) {
        super();
        x = y = -999;
        shape.drawToSprite(this);
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
const BLUR_SIZE:int = 40, BLUR_SIZE_SKIP:int = 8;
var blurs:Vector.<BlurFilter>;
function initializeBlurs():void {
    blurs = new Vector.<BlurFilter>(BLUR_SIZE / BLUR_SIZE_SKIP);
    for (var i:int = BLUR_SIZE_SKIP; i < BLUR_SIZE; i += BLUR_SIZE_SKIP) {
        var blur:BlurFilter = new BlurFilter;
        blur.blurX = blur.blurY = i;
        blurs[i / BLUR_SIZE_SKIP] = blur;
    }
}
function createBlurredBitmapData(df:Function, w:Number, h:Number):BitmapData {
    var bd:BitmapData = new BitmapData(w + BLUR_SIZE * 2, h + BLUR_SIZE * 2, true, 0);
    var bs:Sprite = new Sprite;
    var s:Shape = new Shape;
    bs.addChild(s);
    s.x = w / 2 + BLUR_SIZE; s.y = h / 2 + BLUR_SIZE;
    var g:Graphics = s.graphics;
    df(g);
    bd.lock();
    for (var i:int = 0; i < BLUR_SIZE / BLUR_SIZE_SKIP; i++) {
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
    private var rect:Rectangle = new Rectangle(0, 0, PIXEL_WIDTH * 1.4 + BLUR_SIZE * 2, PIXEL_HEIGHT * 1.4 + BLUR_SIZE * 2);
    public function Cg() {
        for (var i:int = 0; i < STRINGS.length; i++) {
            var bd:BitmapData;
            bd = createCharacterBitmapData(STRINGS.charAt(i));
            bds.push(bd);
            bd = createCharacterBitmapData(STRINGS.charAt(i), true);
            keyBds.push(bd);
        }
    }
    public function print(s:String, x:Number, y:Number, isKey:Boolean = false, fromRight:Boolean = false, fromCenter:Boolean = false):void {
        var p:Point = new Point, cbd:BitmapData, px:Number;
        px = x - BLUR_SIZE; p.y = y - BLUR_SIZE;
        var spacing:Number = PIXEL_WIDTH * 0.8;
        if (isKey) spacing *= 2;
        if (fromRight) px -= (s.length + 1) * spacing;
        else if (fromCenter) px -= (s.length + 1) / 2 * spacing;
        for (var i:int = 0; i < s.length; i++, px += spacing) {
            var c:int = STRINGS.indexOf(s.charAt(i));
            if (c >= 0) {
                if (isKey) cbd = keyBds[c];
                else cbd = bds[c];
                p.x = px; bd.copyPixels(cbd, rect, p);
            }
        }
    }
    public function printKeys(s:String, x:Number, y:Number):void {
        print(s, x, y, true);
    }
    public function printFromRight(s:String, x:Number, y:Number):void {
        print(s, x, y, false, true);
    }
    public function printFromCenter(s:String, x:Number, y:Number):void {
        print(s, x, y, false, false, true);
    }
}
const CHARACTER_COLOR:int = 0xffffff;
function createCharacterBitmapData(c:String, isKey:Boolean = false):BitmapData {
    var bd:BitmapData = new BitmapData(Cg.PIXEL_WIDTH * 1.4 + BLUR_SIZE * 2, Cg.PIXEL_HEIGHT * 1.4 + BLUR_SIZE * 2, true, 0);
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
        s.x = Cg.PIXEL_WIDTH * 0.7 + BLUR_SIZE;
        s.y = Cg.PIXEL_HEIGHT * 0.7 + BLUR_SIZE;
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
        b.x = ofs + BLUR_SIZE; b.y = BLUR_SIZE;
    }
    if (isKey) {
        g = bs.graphics;
        g.lineStyle(2, 0xffffff);
        g.moveTo(BLUR_SIZE, BLUR_SIZE);
        g.lineTo(BLUR_SIZE + Cg.PIXEL_WIDTH * 1.4, BLUR_SIZE);
        g.lineTo(BLUR_SIZE + Cg.PIXEL_WIDTH * 1.4, BLUR_SIZE + Cg.PIXEL_HEIGHT * 1.4);
        g.lineTo(BLUR_SIZE, BLUR_SIZE + Cg.PIXEL_HEIGHT * 1.4);
        g.lineTo(BLUR_SIZE, BLUR_SIZE);
    }
    bd.lock();
    for (var i:int = 0; i < BLUR_SIZE / BLUR_SIZE_SKIP; i++) {
        if (i > 0) bs.filters = [blurs[i]];
        bd.draw(bs);
    }
    bd.unlock();
    return bd;
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
    xorShiftX = xorShiftY;
    xorShiftY = xorShiftZ;
    xorShiftZ = xorShiftW;
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
function aim(a:Number, targetAngle:Number, maxRotation:Number):Number {
    var oa:Number = normalizeAnglePm(targetAngle - a);
    if (oa > maxRotation) oa = maxRotation;
    else if (oa < -maxRotation) oa = -maxRotation;
    return a + oa;
}
function getLength(x:Number, y:Number):Number {
    return sqrt(x * x + y * y);
}
function sawtoothWave(x:Number, increment:Number = 0.2):Number {
    return (x % 1) + int(x) * increment;
}
// Operation utility functions.
var currentKeys:Vector.<Boolean> = new Vector.<Boolean>(256);
var keys:Vector.<Boolean> = new Vector.<Boolean>(256);
var wasdWay:Vec = new Vec, ijklWay:Vec = new Vec;
var keyHistory:Vector.<Key>, keyHistoryIndex:int, randomSeed:int;
var isKeyRecording:Boolean, isKeyReplaying:Boolean;
class Key {
    public var code:int, isPressed:Boolean, keyTicks:int;
    public function Key(code:int, isPressed:Boolean) {
        this.code = code;
        this.isPressed = isPressed;
        keyTicks = ticks;
    }
}
function onKeyPressed(e:KeyboardEvent):void { currentKeys[e.keyCode] = true; }
function onKeyReleased(e:KeyboardEvent):void { currentKeys[e.keyCode] = false; }
function updateKeys():void {
    if (isKeyRecording) recordKeys();
    else if (isKeyReplaying) replayKeys();
    else getCurrentKeys();
}
function getCurrentKeys():void {
    for (var i:int = 0; i < 256; i++) keys[i] = currentKeys[i];
}
function swapCurrentKeys():void {
    for (var i:int = 0; i < 256; i++) {
        var ck:Boolean = currentKeys[i];
        currentKeys[i] = keys[i];
        keys[i] = ck;
    }
}
function resetKeys():void {
    for (var i:int = 0; i < 256; i++) keys[i] = currentKeys[i] = 0;
}
function startRecordKeys():void {
    keyHistory = new Vector.<Key>;
    isKeyRecording = true;
    setRandomSeed(randomSeed = getTimer());
    resetKeys();
}
function recordKeys():void {
    for (var i:int = 0; i < 256; i++) if (keys[i] != currentKeys[i]) {
        var ck:Boolean = currentKeys[i];
        keyHistory.push(new Key(i, ck));
        keys[i] = ck;
    }
}
function stopRecordKeys():void {
    keyHistory.push(new Key(0, false));
    isKeyRecording = false;
}
function startReplayKeys():void {
    keyHistoryIndex = 0;
    isKeyReplaying = true;
    setRandomSeed(randomSeed);
    resetKeys();
}
function replayKeys():void {
    while (keyHistoryIndex < keyHistory.length) {
        var k:Key = keyHistory[keyHistoryIndex];
        if (k.keyTicks > ticks) break;
        keys[k.code] = k.isPressed;
        keyHistoryIndex++;
    }
}
function stopReplayKeys():void {
    isKeyReplaying = false;
    resetKeys();
}
function get isReplayKeysEnd():Boolean {
    return (keyHistoryIndex >= keyHistory.length);
}
function getWasdWay(m:Number = 1):Vec {
    wasdWay.x = wasdWay.y = 0;
    if (isWPressed) wasdWay.y -= 1;
    if (isAPressed) wasdWay.x -= 1;
    if (isSPressed) wasdWay.y += 1;
    if (isDPressed) wasdWay.x += 1;
    if (wasdWay.x != 0 && wasdWay.y != 0) {
        wasdWay.x *= 0.7; wasdWay.y *= 0.7;
    }
    wasdWay.x *= m; wasdWay.y *= m;
    return wasdWay;
}
function get isWPressed():Boolean { return keys[0x26] || keys[0x57]; }
function get isAPressed():Boolean { return keys[0x25] || keys[0x41]; }
function get isSPressed():Boolean { return keys[0x28] || keys[0x53]; }
function get isDPressed():Boolean { return keys[0x27] || keys[0x44]; }
function getIjklWay(m:Number = 1):Vec {
    ijklWay.x = ijklWay.y = 0;
    if (isIPressed) ijklWay.y -= 1;
    if (isJPressed) ijklWay.x -= 1;
    if (isKPressed) ijklWay.y += 1;
    if (isLPressed) ijklWay.x += 1;
    if (ijklWay.x != 0 && ijklWay.y != 0) {
        ijklWay.x *= 0.7; ijklWay.y *= 0.7;
    }
    ijklWay.x *= m; ijklWay.y *= m;
    return ijklWay;
}
function get isIPressed():Boolean { return keys[0x49]; }
function get isJPressed():Boolean { return keys[0x4a]; }
function get isKPressed():Boolean { return keys[0x4b]; }
function get isLPressed():Boolean { return keys[0x4c]; }
function get isButtonPressed():Boolean {
    return isButton1Pressed || isButton2Pressed;
}
function get isButton1Pressed():Boolean {
    return keys[0x5a] || keys[0xbe] || keys[0x20];
}
function get isButton2Pressed():Boolean {
    return keys[0x58] || keys[0xbf];
}
function get isEscPressed():Boolean {
    return keys[0x1b];
}
// Screen utility functions.
function isInScreen(p:Vector3D):Boolean {
    return (p.x >= 0 && p.x <= SCREEN_WIDTH && p.y >= 0 && p.y <= SCREEN_HEIGHT);
}
function setInScreen(p:Vector3D):void {
    if (p.x < 0) p.x = 0;
    else if (p.x > SCREEN_WIDTH) p.x = SCREEN_WIDTH;
    if (p.y < 0) p.y = 0;
    else if (p.y > SCREEN_HEIGHT) p.y = SCREEN_HEIGHT;
}
function removeAllSprites():void {
    while (main.numChildren > 1) main.removeChildAt(1);
}
function drawTitle(title:String, buttonStrs:Array, operationStrs:Array, startButton:String):void {
    cg.print(title, 100, 100);
    var y:int = 200;
    for (var i:int = 0; i < buttonStrs.length; i++, y += 30) {
        cg.printKeys(buttonStrs[i], 120, y);
        cg.print(operationStrs[i], 240, y);
    }
    y += 10;
    cg.printKeys(startButton, 120, y);
    cg.print("START", 240, y);
}
var rectForFill:Rectangle = new Rectangle;
function fillRect(x:Number, y:Number, width:Number, height:Number, color:int):void {
    rectForFill.x = x - width / 2; rectForFill.y = y - height / 2;
    rectForFill.width = width; rectForFill.height = height;
    bd.fillRect(rectForFill, color);
}
// Text utility functions.
import net.wonderfl.utils.FontLoader;
const DEFAULT_FONT_NAME:String = "_typewriter";
const FONT_NAME:String = "Bebas";
function loadFont():void {
    if (FONT_NAME == DEFAULT_FONT_NAME) { onFontLoaded(); return; }
    var loader:FontLoader = new FontLoader();
    loader.addEventListener(Event.COMPLETE, onFontLoaded);
    loader.load(FONT_NAME);
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
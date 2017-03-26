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
const TITLE = "PUMP CIRCLE";
function initialize() {
    startStage();
    addMessage(CLICK_STR + " A SAFE AREA", 200, 50);
}
function startStage() {
    removeAllSprites();
    circles = new Vector.<Circle>;
    for (var i = 0; i < 10 + randi(20); i++) circles.push(new Circle);
    for (i = 0; i < 100; i++) for each (var c in circles) c.grow();
    for (i = 0; i < circles.length; i++) {
        var c = circles[i];
        if (c.size < Dot.SIZE) { c.sprite.remove(); circles.splice(i--, 1); }
        c.size = Dot.SIZE;
    }
    for (i = 0; i < 10; i++) {
        var ci = randi(circles.length);
        c = circles[ci];
        if (isInScreen(c.pos, -SCREEN_WIDTH * 0.2)) { c.sprite.remove; circles.splice(ci, 1); break; }
    }
    dot = null;
    updateActors(circles);
    isSettingDot = true; isPumping = isPumpingDot = false;
}
var isSettingDot, isPumping, isPumpingDot;
function update() {
    if (isSettingDot) {
        if (isMouseClicked && isInScreen(mouse)) {
            dot = new Dot(mouse);
            isSettingDot = false; isPumping = true;
        }
    } else if (isPumping) {
        updateActors(circles);
        isPumping = false;
        for each (var c in circles) if (c.isPumping) { isPumping = true; break; }
        if (!isPumping) isPumpingDot = true;
    } else if (dot && isPumpingDot) {
        isPumpingDot = dot.pump();
    } else if (dot) {
        for each (var c in circles) c.destroy();
        circles = new Vector.<Circle>;
        startGameOver();
    }
}
var circles;
class Circle extends Actor {
    const BASE_SIZE = 64;
    var size, isPumping = true;
    function Circle() {
        super(PrimitiveShape.CIRCLE, BASE_SIZE);
        pos.x = rands(0.1, 0.8); pos.y = rands(0.1, 0.8);
        size = Dot.SIZE;
    }
    function update() {
        if (!isPumping) return true;
        size += 2;
        if (dot && pos.distance(dot.pos) < (size + dot.size) / 2) {
            dot.destroy(); dot = null; startGameOver();
        }
        for each (var c in circles) {
            if (c != this && pos.distance(c.pos) < (size + c.size) / 2) {
                isPumping = c.isPumping = false;
            }
        }
        sprite.scale = size / BASE_SIZE;
        return true;
    }
    function checkHit() {
        for each (var c in circles) {
            if (c != this && pos.distance(c.pos) < (size + c.size) / 2) return c;
        }
        return null;
    }
    function grow() {
        size += 3;
        var c = checkHit();
        if (c) {
            size -= 5;
            var a = pos.angle(c.pos);
            pos.addAngle(a, 3); c.pos.addAngle(a, -3);
        }
        return true;
    }
    function destroy() {
        addParticlesRound(50, pos, size / 3);
        sprite.remove();
    }
}
var dot;
class Dot extends Actor {
    static const SIZE = 20;
    var size = SIZE;
    function Dot(p) {
        super(PrimitiveShape.FILLCIRCLE, SIZE);
        pos.xy = p; sprite.pos = pos;
    }
    function pump() {
        for each (var c in circles) {
            if (pos.distance(c.pos) < (size + c.size) / 2) {
                addNumberBoard(score, pos.x, pos.y - size * 0.7);
                return false;
            }
        }
        size += 2; score++;
        sprite.scale = size / SIZE;
        return true;
    }
    function destroy() {
        addParticlesRound(100, pos, size / 3, 8);
        sprite.remove();
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
// Initialize a screen, a font and events.
const SCREEN_WIDTH:int = 465, SCREEN_HEIGHT:int = 465, SCREEN_CENTER:int = SCREEN_WIDTH / 2;
const DEFAULT_FONT_NAME:String = "_typewriter";
var main:Main, bd:BitmapData;
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
    addCoverSprites(-SCREEN_HEIGHT); addCoverSprites(SCREEN_HEIGHT);
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
    if (isInGame) { update(); drawScore(); }
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
var ticks:int, gameOverTicks:int
var score:int, scoreHistory:ScoreHistory = new ScoreHistory;
function startTitle():void {
    removeAllSprites();
    playButton = new PlayButton;
    gameOverTicks = 0;
}
function startGame():void {
    gameOverTicks = -1;
    playButton.hide();
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
    scoreHistory.add(score);
}
const BACKGROUND_BITMAP_COUNT:int = 1, COVER_SPRITE_COUNT:int = 2;
const BASE_SPRITE_COUNT:int = BACKGROUND_BITMAP_COUNT + COVER_SPRITE_COUNT;
function removeAllSprites():void {
    while (main.numChildren > BASE_SPRITE_COUNT) main.removeChildAt(1);
    for each (var m:Message in messages) m.arrow = null;
}
function get isTitle():Boolean { return (gameOverTicks == 0); }
function get isInGame():Boolean { return (gameOverTicks < 0); }
function get isGameOver():Boolean { return (gameOverTicks > 0); }
function updateTitle():void {
    playButton.update();
    if (playButton.isPressAndReleased) startGame();
    drawTitle(TITLE);
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
function addCoverSprites(y:int):void {
    var s:Sprite = new Sprite, g:Graphics = s.graphics;
    g.beginFill(0); g.drawRect(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT); g.endFill();
    s.x = 0; s.y = y;
    main.addChild(s);
}
/*--------------------------------*/
// Play button on a title.
var playButton:PlayButton;
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
        button.x = SCREEN_CENTER; button.y = 320;
        plate.x = button.x; plate.y = button.y;
        wasPressed = isMousePressed;
        isPressed = isPressAndReleased = false;
    }
    public function update():void {
        if (isMousePressed) {
            if (mouse.x >= button.x - WIDTH / 2 - ALLOWANCE && mouse.x <= button.x + WIDTH / 2 + ALLOWANCE &&
                mouse.y >= button.y - HEIGHT / 2 - ALLOWANCE && mouse.y <= button.y + HEIGHT / 2 + ALLOWANCE) {
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
        if (isMousePressed) wasPressed = true;
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
function scrollParticles(vx:Number, vy:Number):void {
    for each (var p:Particle in particles) {
        p.pos.x += vx; p.pos.y += vy;
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
    public var pos:Vec = new Vec, ticks:int, text:String;
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
    var bs:Sprite = new Sprite, s:Shape = new Shape;
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
        var spacing:Number = PIXEL_WIDTH * 0.8;
        if (fromRight) px -= (s.length + 1) * spacing;
        else if (fromCenter) px -= (s.length + 1) / 2 * spacing;
        for (var i:int = 0; i < s.length; i++, px += spacing) {
            var c:int = STRINGS.indexOf(s.charAt(i));
            if (c >= 0) {
                cbd = bds[c];
                p.x = px; pbd.copyPixels(cbd, rect, p, null, null, true);
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
        var width:Number = (s.length - 1) * PIXEL_WIDTH * 0.8 + PIXEL_WIDTH * 1.4;
        var height:Number = PIXEL_WIDTH * 1.4;
        var sbd:BitmapData = new BitmapData(width + BLUR_SZ * 2, height + BLUR_SZ * 2, true, 0);
        printToBitmapData(sbd, s, BLUR_SZ, BLUR_SZ, false, false);
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
        for (var i:int = 0, y:Number = sy; i < endIndex; i++, y += Cg.FONT_SIZE * 1.2) {
            cg.printFromRight(String(scores[i]), x, y);
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
function randi(n:int):int { return Math.random() * n; }
function randn(n:Number = 1):Number { return Math.random() * n; }
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
var mouse:Vec = new Vec, isMousePressed:Boolean, isMouseClicked:Boolean, isMouseReleased:Boolean;
var mouseVel:Vec = new Vec, mouseDragDist:Vec = new Vec;
var wasMousePressed:Boolean, prevMouse:Vec = new Vec;
var currentMouse:Vec = new Vec, isCurrentMousePressed:Boolean;
function onMousePressed(e:MouseEvent):void { isCurrentMousePressed = true; onMouseMoved(e); }
function onMouseReleased(e:Event):void { isCurrentMousePressed = false; }
function onMouseMoved(e:MouseEvent):void {
    if (e.buttonDown) { currentMouse.x = e.stageX; currentMouse.y = e.stageY; }
}
function updateInput():void {
    mouse.x = currentMouse.x; mouse.y = currentMouse.y;
    isMousePressed = isCurrentMousePressed;
    updateMouseState();
}
function updateMouseState():void {
    isMouseClicked = isMouseReleased = false;
    mouseVel.x = mouseVel.y = 0;
    if (isMousePressed) {
        if (!wasMousePressed) {
            isMouseClicked = wasMousePressed = true;
            mouseDragDist.x = mouseDragDist.y = 0;
        } else {
            mouseVel.x = mouse.x - prevMouse.x; mouseVel.y = mouse.y - prevMouse.y;
            mouseDragDist.incrementBy(mouseVel);
        }
        prevMouse.x = mouse.x; prevMouse.y = mouse.y;
    } else {
        if (wasMousePressed) { isMouseReleased = true; wasMousePressed = false; }
    }
}
function resetInput():void {
    mouse.x = mouse.y = currentMouse.x = currentMouse.y = SCREEN_CENTER; 
    isMousePressed = isCurrentMousePressed = false;
    wasMousePressed = isMouseClicked = false;
    prevMouse.x = prevMouse.y = 0;
    mouseVel.x = mouseVel.y = 0; mouseDragDist.x = mouseDragDist.y = 0;
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
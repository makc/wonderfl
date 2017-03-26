package {
    import flash.display.Sprite;
    [SWF(width="465", height="465", backgroundColor="0", frameRate="30")]
        public class Main extends Sprite {
        public function Main() { main = this; initializeFirst(); }
    }
}
// Initializers.
var score:int, ticks:int, enemyAppearTicks:int;
function initialize():void {
    startTitle();
}
function initializeTitle():void {
    removeAllSprites();
}
function initializeGame():void {
    removeAllSprites();
    player = new Player;
    enemies = new Vector.<Enemy>;
    shots = new Vector.<Shot>;
    score = ticks = enemyAppearTicks = 0;
}
function initalizeGameOver():void {
}
// Update a game frame.
function update():void {
    cg.printFromRight(String(score), SCREEN_WIDTH, 0);
}
function updateGame():void {
    player.update();
    for (var i:int = 0; i < enemies.length; i++) if (!enemies[i].update()) { enemies.splice(i, 1); i--; }
    for (i = 0; i < shots.length; i++) if (!shots[i].update()) { shots.splice(i, 1); i--; }
    if (--enemyAppearTicks <= 0) {
        enemies.push(new Enemy);
        enemyAppearTicks = 67 - ticks * 0.05;
        if (enemyAppearTicks < 10) enemyAppearTicks = 10;
    }
    checkEnemyCollisions();
}
function updateTitle():void {
    drawTitle("FRIENDLY FIRE", new Array("<>^v"), new Array("MOVE"), "Z");
}
function updateGameOver():void {
    for (var i:int = 0; i < enemies.length; i++) if (!enemies[i].update()) { enemies.splice(i, 1); i--; }
    for (i = 0; i < shots.length; i++) if (!shots[i].update()) { shots.splice(i, 1); i--; }
    checkEnemyCollisions();
    cg.print("GAME OVER", 180, 200);
}
function get isStartButtonPressed():Boolean {
    return isButtonPressed;
}
// Player.
var player:Player; 
class Player {
    public static const SPEED:Number = 6;
    public static var shape:PrimitiveShape;
    public var pos:Vector3D = new Vector3D;
    public var sprite:Sprite = new Sprite;
    public function Player() {
        if (shape == null) shape = new PrimitiveShape(PrimitiveShape.HUMAN, 16, 16);
        shape.drawToSprite(sprite);
        main.addChild(sprite);
        pos.x = SCREEN_WIDTH / 2; pos.y = SCREEN_HEIGHT / 2;
    }
    public function update():void {
        var kv:Vector3D = getWasdWay();
        pos.x += kv.x * SPEED; pos.y += kv.y * SPEED;
        if (pos.x < 0) pos.x = 0;
        else if (pos.x > SCREEN_WIDTH) pos.x = SCREEN_WIDTH;
        if (pos.y < 0) pos.y = 0;
        else if (pos.y > SCREEN_HEIGHT) pos.y = SCREEN_HEIGHT;
        sprite.x = pos.x; sprite.y = pos.y;
    }
    public function checkHit(p:Vector3D):Boolean {
        if (!isInGame) return false;
        if (distance(pos, p) < 10) {
            addParticlesRound(20, pos.x, pos.y, 20, 8);
            main.removeChild(sprite);
            startGameOver();
            return true;
        }
        return false;
    }
}
// Enemies.
var enemies:Vector.<Enemy>;
class Enemy {
    public static const SIZE:Number = 24;
    public static var arrowShape:PrimitiveShape, circleShape:PrimitiveShape;
    public var pos:Vector3D = new Vector3D;
    public var vel:Vector3D = new Vector3D;
    public var angle:Number, angleVel:Number, speed:Number;
    public var isArrow:Boolean = true;
    public var sprite:Sprite = new Sprite;
    public var fireTicks:int, fireInterval:int;
    public function Enemy() {
        if (!arrowShape) arrowShape = new PrimitiveShape(PrimitiveShape.TRIANGLE, SIZE, SIZE);
        if (!circleShape) circleShape = new PrimitiveShape(PrimitiveShape.CIRCLE, SIZE, SIZE);
        arrowShape.drawToSprite(sprite);
        main.addChild(sprite);
        do {
            pos.x = (0.2 + randn(0.6)) * SCREEN_WIDTH;
            pos.y = (0.2 + randn(0.6)) * SCREEN_HEIGHT;
        } while (distance(pos, player.pos) < SCREEN_WIDTH / 3);
        angle = randn(PI * 2); 
        switch (randi(6)) {
        case 0: case 1: case 2: case 3:
            angleVel = 0.05 + randn(0.1);
            speed = 1 + randn(2); fireInterval = 15 + randi(30);
            break;
        case 4:
            angleVel = 0.05 + randn(0.05);
            speed = 0; fireInterval = 5 + randi(5);
            break;
        case 5:
            angleVel = 0.02 + randn(0.02);
            speed = 5 + randn(2); fireInterval = 4 + randi(2);
            break;
        }
        angleVel *= 1.0 + 0.001 * ticks;
        fireTicks = fireInterval;
    }
    public function update():Boolean {
        if (isArrow) {
            pos.x += sin(angle) * speed;
            pos.y += cos(angle) * speed;
            var av:Number = angleVel;
            if (!isInScreen(pos)) av *= 10;
            var oa:Number = normalizeAnglePm(atan2(player.pos.x - pos.x, player.pos.y - pos.y) - angle);
            if (oa > av) oa = av;
            else if (oa < -av) oa = -av;
            angle += oa;
        }
        pos.x += vel.x; pos.y += vel.y;
        vel.x *= 0.9; vel.y *= 0.9;
        if (!isArrow && !isInScreen(pos)) {
            addParticlesRound(20, pos.x, pos.y, 8, 5);
            main.removeChild(sprite);
            return false;
        }
        sprite.x = pos.x; sprite.y = pos.y;
        if (!isArrow) return true;
        sprite.rotation = -angle * 180 / PI;
        if (--fireTicks <= 0) {
            fireTicks = fireInterval;
            shots.push(new Shot(pos.x, pos.y, angle, 10));
        }
        return true;
    }
    public function checkHit(s:Shot):Boolean {
        var p:Vector3D = s.pos;
        var d:Number = distance(pos, p);
        if (d > SIZE) return false;
        if (isArrow) {
            sprite.removeChildAt(0);
            circleShape.drawToSprite(sprite);
            isArrow = false;
            addParticlesRound(25, pos.x, pos.y, 10, 7);
            addNumberBoard(10, pos.x, pos.y, -10, -50);
            score += 10;
            return true;
        } else {
            var a:Number = atan2(pos.x - p.x, pos.y - p.y);
            vel.x += sin(a) * (SIZE / d) * 2; vel.y += cos(a) * (SIZE / d) * 2;
            vel.x += s.vel.x * 0.5; vel.y += s.vel.y * 0.5;
            addNumberBoard(1, pos.x, pos.y, -10, -30, 15);
            score += 1;
            return true;
        }
    }
    public function checkCollision(p:Vector3D):void {
        var d:Number = distance(pos, p);
        if (d >= SIZE) return;
        d += SIZE / 4;
        var a:Number = atan2(pos.x - p.x, pos.y - p.y);
        vel.x += sin(a) * (SIZE / d) * 2; vel.y += cos(a) * (SIZE / d) * 2;
    }
}
function checkEnemyCollisions():void {
    for (var i:int = 0; i < enemies.length; i++) {
        for (var j:int = i + 1; j < enemies.length; j++) {
            enemies[i].checkCollision(enemies[j].pos);
            enemies[i].checkCollision(player.pos);
        }
    }
}
// Enemie's shots.
var shots:Vector.<Shot>;
class Shot {
    public static var shape:PrimitiveShape;
    public var pos:Vector3D = new Vector3D;
    public var vel:Vector3D = new Vector3D;
    public var sprite:Sprite = new Sprite;
    public function Shot(x:Number, y:Number, angle:Number, speed:Number) {
        if (!shape) shape = new PrimitiveShape(PrimitiveShape.BAR, 16, 16);
        shape.drawToSprite(sprite);
        pos.x = x + sin(angle) * Enemy.SIZE;
        pos.y = y + cos(angle) * Enemy.SIZE;
        vel.x = sin(angle) * speed; vel.y = cos(angle) * speed;
        sprite.rotation = -angle * 180 / PI;
        main.addChild(sprite);
    }
    public function update():Boolean {
        pos.x += vel.x; pos.y += vel.y;
        sprite.x = pos.x; sprite.y = pos.y;
        if (player.checkHit(pos)) return true;
        var rf:Boolean;
        for each (var e:Enemy in enemies) rf ||= e.checkHit(this);
        if (rf || !isInScreen(pos)) {
            addParticles(3, pos.x, pos.y, -vel.x, -vel.y, 5, 0.9, 0.2);
            main.removeChild(sprite);
            return false;
        }
        return true;
    }
}
// Game lifecycle handlers.
import flash.display.*;
import flash.filters.*;
import flash.geom.*;
import flash.events.*;
import flash.text.*;
import flash.media.*;
import flash.net.*;
const SCREEN_WIDTH:int = 465;
const SCREEN_HEIGHT:int = 465;
var main:Main, bd:BitmapData;
var isMousePressed:Boolean, isMouseClicked:Boolean;
var keys:Vector.<Boolean> = new Vector.<Boolean>(256);
var isStartButtonReleased:Boolean;
// Initialize a bitmap, a font and events.
function initializeFirst():void {
    bd = new BitmapData(SCREEN_WIDTH, SCREEN_HEIGHT, false);
    bd.fillRect(bd.rect, 0);
    main.addChild(new Bitmap(bd));
    main.stage.addEventListener(MouseEvent.MOUSE_DOWN, function(e:Event):void { isMousePressed = true; });
    main.stage.addEventListener(MouseEvent.MOUSE_UP, function(e:Event):void { isMousePressed = false; });
    main.stage.addEventListener(MouseEvent.CLICK, function(e:Event):void { isMouseClicked = true; });
    main.stage.addEventListener(KeyboardEvent.KEY_DOWN, function(e:KeyboardEvent):void { keys[e.keyCode] = true; } );
    main.stage.addEventListener(KeyboardEvent.KEY_UP, function(e:KeyboardEvent):void { keys[e.keyCode] = false; } );
    loadFont();
}
function onFontLoaded():void {
    initializeBlurs();
    cg = new Cg;
    initialize();
    main.addEventListener(Event.ENTER_FRAME, updateFrame);
}
// Update a frame.
function updateFrame(event:Event):void {
    bd.fillRect(bd.rect, 0);
    bd.lock();
    updateParticles();
    updateNumberBoards();
    update();
    if (isInGame) updateGame();
    else if (isTitle) updateTitle();
    else updateGameOver();
    bd.unlock();
    if (isInGame && isEscPressed) startGameOver();
    if (gameOverTicks > 0) {
        gameOverTicks--;
        if (gameOverTicks == 0) startTitle();
    }
    if (isStartButtonPressed) {
        if (isStartButtonReleased) {
            isStartButtonReleased = false;
            if (!isInGame && gameOverTicks < GAME_OVER_DURATION - 30) startGame();
        }
    } else {
        isStartButtonReleased = true;
    }
}
// Handle a game state (Title/In game/Game over).
const GAME_OVER_DURATION:int = 180;
var gameOverTicks:int;
function startTitle():void {
    initializeTitle();
    gameOverTicks = 0;
}
function startGame():void {
    initializeGame();
    gameOverTicks = -1;
}
function startGameOver():void {
    initalizeGameOver();
    gameOverTicks = GAME_OVER_DURATION;
}
function get isInGame():Boolean {
    return (gameOverTicks < 0);
}
function get isTitle():Boolean {
    return (gameOverTicks == 0);
}
function isInScreen(p:Vector3D):Boolean {
    return (p.x >= 0 && p.x < SCREEN_WIDTH && p.y >= 0 && p.y < SCREEN_HEIGHT);
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
function removeAllSprites():void {
    while (main.numChildren > 1) main.removeChildAt(1);
}
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
function addParticles(n:int, x:Number, y:Number, vx:Number, vy:Number, size:int = 4, attenuation:Number = 0.95, spreading:Number = 0.5):void {
    var v:Number = (abs(vx) + abs(vy)) * spreading;
    for (var i:int = 0; i < n; i++) {
        particles.push(new Particle(x, y, vx + v * (-1 + randn(2)), vy + v * (-1 + randn(2)), size, attenuation));
    }
}
function addParticlesRound(n:int, x:Number, y:Number, mv:Number, size:int = 4, attenuation:Number = 0.95):void {
    for (var i:int = 0; i < n; i++) {
        var a:Number = randn(PI * 2);
        var v:Number = mv * randn(1);
        particles.push(new Particle(x, y, sin(a) * v, cos(a) * v, size, attenuation));
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
function addNumberBoard(s:int, x:Number, y:Number, tx:Number, ty:Number, ticks:int = 30):void {
    numberBoards.push(new NumberBoard(s, x, y, tx, ty, ticks));
}
// Primitive shapes.
class PrimitiveShape {
    public static const CIRCLE:int = 0, BOX:int = 1, TRIANGLE:int = 2,
        CROSS:int = 3, BAR:int = 4, HUMAN:int = 5, CAR:int = 6,
        COUNT:int = 7;
    public static const POINTS:Array = [
        [-10, -10, 10, -10, 10, 10, -10, 10, -10, -10],
        [0, 10, -10, -10, 10, -10, 0, 10],
        [-10, -10, 10, 10, 99, 10, -10, -10, 10],
        [0, -10, 0, 10],
        [0, -10, 0, 0, -10, 10, 99, 0, 0, 10, 10, 99, -10, -3, 10, -3],
        [-7, 10, 7, 10, 99, 0, -10, 0, 10, 99, -10, -10, 10, -10],
    ];
    public var bd:BitmapData, width:int, height:int;
    public function PrimitiveShape(type:int, width:int, height:int) {
        this.width = width; this.height = height;
        if (type == 0) {
            bd = createBlurredBitmapData(function (g:Graphics):void {
                    g.lineStyle(2, 0xffffff);
                    g.drawEllipse(-width / 2, -height / 2, width, height);
            }, width, height);
        } else {
            var ps:Array = POINTS[type - 1];
            bd = createBlurredBitmapData(function (g:Graphics):void {
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
    }
    public function drawToSprite(s:Sprite):void {
        var b:Bitmap = new Bitmap(bd);
        b.x = -width / 2 - BLUR_SIZE;
        b.y = -height / 2 - BLUR_SIZE;
        s.addChild(b);
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
// Math utility functions.
var sin:Function = Math.sin, cos:Function = Math.cos, atan2:Function = Math.atan2; 
var sqrt:Function = Math.sqrt, abs:Function = Math.abs;
var PI:Number = Math.PI;
function randi(n:int):int {
    return Math.random() * n;
}
function randn(n:Number):Number {
    return Math.random() * n;
}
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
function length(x:Number, y:Number):Number {
    return sqrt(x * x + y * y);
}
 function distance(p1:Vector3D, p2:Vector3D):Number {
    return length(p1.x - p2.x, p1.y - p2.y);
}
function sign(v:Number):int {
    return (v > 0) ? 1 : ((v < 0) ? -1 : 0);
}
// Operation utility functions.
var wasdWay:Vector3D = new Vector3D, ijklWay:Vector3D = new Vector3D;
function getWasdWay():Vector3D {
    wasdWay.x = wasdWay.y = 0;
    if (keys[0x26] || keys[0x57]) wasdWay.y = -1;
    if (keys[0x25] || keys[0x41]) wasdWay.x = -1;
    if (keys[0x28] || keys[0x53]) wasdWay.y =  1;
    if (keys[0x27] || keys[0x44]) wasdWay.x =  1;
    if (wasdWay.x != 0 && wasdWay.y != 0) {
        wasdWay.x *= 0.7; wasdWay.y *= 0.7;
    }
    return wasdWay;
}
function getIjklWay():Vector3D {
    ijklWay.x = ijklWay.y = 0;
    if (keys[0x49]) ijklWay.y = -1;
    if (keys[0x4a]) ijklWay.x = -1;
    if (keys[0x4b]) ijklWay.y =  1;
    if (keys[0x4c]) ijklWay.x =  1;
    if (ijklWay.x != 0 && ijklWay.y != 0) {
        ijklWay.x *= 0.7; ijklWay.y *= 0.7;
    }
    return ijklWay;
}
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
// Text utility functions.
import net.wonderfl.utils.FontLoader;
const DEFAULT_FONT_NAME:String = "_typewriter";
const FONT_NAME:String = "Bebas";
function loadFont():void {
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
function drawStringToSprite(sp:Sprite, s:String, x:int, y:int, size:int, color:int, hasSpacing:Boolean = true):void {
    var t:TextField = createTextField(x, y, size, size * s.length, size * 1.5, color, hasSpacing);
    t.text = s;
    sp.addChild(t);
}
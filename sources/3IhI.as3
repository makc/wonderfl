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
    public function Actor(type:int = -1, width:int = -1, height:int = -1) {
        if (shapes == null) shapes = new Vector.<PrimitiveShape>;
        if (type < 0) return;
        if (height < 0) height = width;
        for each (var s:PrimitiveShape in shapes) {
            if (s.type == type && s.width == width && s.height == height) { shape = s; break; }
        }
        if (!shape) { shape = new PrimitiveShape(type, width, height); shapes.push(shape); }
        sprite = new PrimitiveSprite(shape);
    }
}
/*----------------------------------------------------------------*/
const DEBUG = false;
const TITLE = "GROWN RACKETS";
var rank, nextBallSourceDist, nextTargetDist, wasMousePressed;
function initialize() {
    balls = new Vector.<Ball>;
    ballSources = new Vector.<BallSource>;
    targets = new Vector.<Target>;
    rackets = new Vector.<Racket>;
    grownRacket = null;
    nextBallSourceDist = nextTargetDist = 0;
    wasMousePressed = false;
    addMessage("DRAG TO CREATE A RACKET", 200, 100);
}
function update() {
    rank = 1 + sawtoothWave(Number(score) / 1000) * 3;
    updateActors(ballSources);
    updateActors(balls);
    updateActors(targets);
    if (grownRacket && grownRacket.isDestroyed) grownRacket = null;
    if (isMousePressed) {
        if (!wasMousePressed) {
            var df;
            for each (var r in rackets) {
                if (r.checkHit(mouse)) { r.isDestroyed = true; df = true; }
            }
            if (!df) grownRacket = new Racket(mouse);
            wasMousePressed = true;
        }
        if (grownRacket) grownRacket.grow(mouse);
    } else {
        if (grownRacket) setGrownRacket();
        wasMousePressed = false;
    }
    updateActors(rackets);
    scroll(0.5 * rank);
}
function setGrownRacket() {
    if (grownRacket.width < 32) grownRacket.isDestroyed = true;
    addMessage(CLICK_STR + "TO REMOVE A RACKET", grownRacket.pos.x, grownRacket.pos.y, -rank * 0.5, 0, 120, true);
    rackets.push(grownRacket);
    grownRacket.sprite.alpha = 1;
    grownRacket = null;
}
var rackets, grownRacket:Racket;
class Racket extends Actor {
    const BASE_WIDTH = 64, HEIGHT = 16;
    var width = 0, angle = 0, o = new Vec;
    var isDestroyed;
    function Racket(p) {
        super(PrimitiveShape.CIRCLE, BASE_WIDTH, HEIGHT);
        pos.x = p.x; pos.y = p.y;
        sprite.pos = pos; sprite.scaleX = 0; sprite.alpha = 0.6;
    }
    function grow(p) {
        angle = p.angle(pos) + PI / 2;
        sprite.angle = angle;
        width = p.distance(pos) * 2;
        sprite.scaleX = width / BASE_WIDTH;
    }
    function checkHit(p) {
        o.x = p.x - pos.x; o.y = p.y - pos.y;
        o.rotate(angle);
        return o.x >= -width / 2 && o.x <= width / 2 && o.y >= -HEIGHT / 2 && o.y <= HEIGHT / 2;
    }
    function getAngle(p) {
        o.x = p.x - pos.x; o.y = p.y - pos.y;
        o.rotate(angle);
        var ox = o.x / (width / 2);
        var a = Math.tan(-ox / 2) / 2 + angle;
        return a;
    }
    function update() {
        if (isDestroyed) {
            addParticlesAngle(30, pos.x, pos.y, angle + PI / 2, 10, 5, 0.9, 0.3);
            addParticlesAngle(30, pos.x, pos.y, angle + PI / 2 * 3, 10, 5, 0.9, 0.3);
            return false;
        }
        sprite.pos = pos;
        return (pos.x > -width / 2);
    }
}
var balls;
class Ball extends Actor {
    static const SIZE = 12;
    var vel = new Vec, ppos = new Vec, isDestroyed;
    function Ball(p, v) {
        super(PrimitiveShape.CIRCLE, SIZE);
        pos.x = p.x; pos.y = p.y - SIZE;
        vel.x = v.x + randn() - 0.5; vel.y = v.y;
    }
    function update() {
        if (isDestroyed) return false;
        ppos.x = pos.x, ppos.y = pos.y;
        var pa = atan2(vel.x, vel.y);
        pos.incrementBy(vel);
        var angle = atan2(vel.x, vel.y), speed = vel.length;
        for each (var r in rackets) {
            if (r.checkHit(pos)) {
                if (vel.length < 3) return false;
                var ra = r.getAngle(ppos);
                addParticlesAngle(5, pos.x, pos.y, ra, speed / 2, 3);
                angle += normalizeAnglePm(ra - angle) * 2 + PI;
            }
        }
        angle = normalizeAnglePm(angle);
        if (angle != pa) {
            pos.x = ppos.x; pos.y = ppos.y;
            pos.addAngle(angle, speed);
        }
        vel.x = sin(angle) * speed; vel.y = cos(angle) * speed;
        vel.y += 0.5; vel.scaleBy(0.95);
        sprite.pos = pos;
        return (pos.y < SCREEN_HEIGHT + SIZE / 2);
    }
    function destroy() {
        score++;
        addParticlesRound(10, pos.x, pos.y, 4);
        isDestroyed = true;
    }
}
var ballSources;
class BallSource extends Actor {
    const SIZE = 24;
    var interval, ticks = 0, vel = new Vec;
    function BallSource(x) {
        super(PrimitiveShape.CIRCLE, SIZE);
        pos.x = SCREEN_WIDTH - SIZE / 2 - x; pos.y = SIZE / 2;
        interval = 5 + randi(5);
        vel.x = randn(4) - 2; vel.y = randn(4);
    }
    function update() {
        sprite.pos = pos;
        if (!isGameOver && --ticks <= 0) {
            balls.push(new Ball(pos, vel));
            ticks = interval;
        }
        return (pos.x > -SIZE / 2);
    }
}
var targets;
class Target extends Actor {
    const SIZE = 48;
    var size, sc;
    function Target(x) {
        super(PrimitiveShape.CIRCLE, SIZE);
        size = SIZE * (1 + randn());
        pos.x = SCREEN_WIDTH + size / 2 - x;
        pos.y = SCREEN_HEIGHT - SIZE / 2 - rands(0, 0.5);
        sc = size * 4;
        addMessage("DESTROY A TARGET", pos.x, pos.y, -0.5, 0, 200, true);
    }
    function update() {
        sprite.pos = pos; sprite.scale = size / SIZE;
        for each (var b in balls) {
            if (b.pos.distance(pos) <= (size + Ball.SIZE) / 2) {
                b.destroy();
                size -= 4;
                if (size < SIZE / 2) {
                    addNumberBoard(sc, pos.x, pos.y - 40);
                    score += sc;
                    addParticlesRound(100, pos.x, pos.y, 10, 6);
                    return false;
                }
            }
        }
        if (sc > 10) sc--;
        if (pos.x < -size / 2) {
            addParticlesRound(250, 0, pos.y, 20, 10);
            startGameOver();
            return false;
        }
        return true;
    }
}
function scroll(x) {
    for each (var b in balls) b.pos.x -= x;
    for each (var bs in ballSources) bs.pos.x -= x;
    for each (var t in targets) t.pos.x -= x;
    for each (var r in rackets) r.pos.x -= x;
    nextBallSourceDist -= x;
    while (nextBallSourceDist <= 0) {
        ballSources.push(new BallSource(-nextBallSourceDist));
        nextBallSourceDist += rands(0.4, 0.2);
    }
    nextTargetDist -= x;
    if (targets.length <= 0) nextTargetDist = 0;
    while (nextTargetDist <= 0) {
        targets.push(new Target(-nextTargetDist));
        nextTargetDist += rands(0.2, 0.4);
    }
}
/*----------------------------------------------------------------*/
// Update a frame.
const SCREEN_WIDTH:int = 465;
const SCREEN_HEIGHT:int = 465;
const SCREEN_CENTER:int = 465 / 2;
const GAME_OVER_DURATION:int = 120;
const START_REPLAY_TICKS:int = 60;
var ticks:int;
function updateFrame(event:Event):void {
    updateInput();
    bd.lock();
    bd.fillRect(bd.rect, 0);
    updateParticles();
    updateNumberBoards();
    updateMessages();
    if (!isInGame) scoreHistory.draw(SCREEN_WIDTH, 30);
    if (isInGame) { drawScore();  update(); }
    else if (isTitle) updateTitle();
    else { update(); drawGameOver(); }
    bd.unlock();
    ticks++;
    if (isGameOver) {
        gameOverTicks--;
        if (gameOverTicks <= 0 || (gameOverTicks < GAME_OVER_DURATION - 30 && isMousePressed)) startTitle();
    } else if (isTitle) {
        if (playButton.isPressAndReleased) startGame();
    }
}
function updateTitle():void {
    if (inputHistory && titleTicks >= START_REPLAY_TICKS) {
        if (titleTicks == START_REPLAY_TICKS) {
            startReplayInput();
            initializeGame();
        }
        if (isReplayInputEnd || isCurrentMousePressed) {
            stopReplayInput();
            startTitle();
        } else {
            drawScore(); update();
        }
    } else {
        playButton.update();
    }
    if (!inputHistory || titleTicks < START_REPLAY_TICKS) drawTitle(TITLE);
    if (inputHistory && titleTicks >= START_REPLAY_TICKS) drawGameOver();
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
function get isTitle():Boolean { return (gameOverTicks == 0); }
function get isInGame():Boolean { return (gameOverTicks < 0); }
function get isGameOver():Boolean { return (gameOverTicks > 0); }
function updateActors(actors:Vector.<*>):void {
    for (var i:int = 0; i < actors.length; i++) if (!actors[i].update()) {
        if (actors[i].sprite) actors[i].sprite.remove();
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
        HUMAN:int = 6, CAR:int = 7, SPRING:int = 8, ARROW:int = 9,
        COUNT:int = 10;
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
// Play button on a title.
class PlayButton {
    public const WIDTH:int = 120, HEIGHT:int = 40;
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
            if (mouse.x >= button.x - WIDTH / 2 && mouse.x <= button.x + WIDTH / 2 &&
                mouse.y >= button.y - HEIGHT / 2 && mouse.y <= button.y + HEIGHT / 2) {
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
var mouse:Vec = new Vec, isMousePressed:Boolean, isCurrentMousePressed:Boolean;
var inputHistory:Vector.<Input>, inputHistoryIndex:int, randomSeed:int;
var isInputRecording:Boolean, isInputReplaying:Boolean;
var mouseSprite:PrimitiveSprite;
class Input {
    public var x:int, y:int, isMousePressed:Boolean, inputTicks:int;
    public function Input(x:int, y:int, isMousePressed:Boolean) {
        this.x = x; this.y = y; this.isMousePressed = isMousePressed;
        inputTicks = ticks;
    }
}
function onMousePressed(e:Event):void { isCurrentMousePressed = true; }
function onMouseReleased(e:Event):void { isCurrentMousePressed = false; }
function updateInput():void {
    if (isInputRecording) recordInput();
    else if (isInputReplaying) replayInput();
    else getCurrentInput();
}
function getCurrentInput():void {
    mouse.x = main.stage.mouseX; mouse.y = main.stage.mouseY;
    isMousePressed = isCurrentMousePressed;
}
function resetInput():void {
    mouse.x = mouse.y = SCREEN_CENTER; isMousePressed = false;
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
    while (inputHistoryIndex < inputHistory.length) {
        var i:Input = inputHistory[inputHistoryIndex];
        if (i.inputTicks > ticks) break;
        mouse.x = i.x; mouse.y = i.y; isMousePressed = i.isMousePressed;
        if (isMousePressed) {
            mouseSprite.visible = true;
            mouseSprite.x = i.x; mouseSprite.y = i.y;
        } else {
        mouseSprite.visible = false;
        }
        inputHistoryIndex++;
    }
}
function stopReplayInput():void {
    mouseSprite.remove();
    isInputReplaying = false;
    resetInput();
}
function get isReplayInputEnd():Boolean {
    return (inputHistoryIndex >= inputHistory.length);
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
    for each (var m:Message in messages) m.hasArrow = false;
}
function drawTitle(title:String):void {
    cg.print(title, 100, 100);
}
var rectForFill:Rectangle = new Rectangle;
function fillRect(x:Number, y:Number, width:Number, height:Number, color:int):void {
    rectForFill.x = x - width / 2; rectForFill.y = y - height / 2;
    rectForFill.width = width; rectForFill.height = height;
    bd.fillRect(rectForFill, color);
}
// Text utility functions.
function createTextField(x:int, y:int, size:int, width:int, height:int, color:int, hasSpacing:Boolean = true):TextField {
    var fm:TextFormat = new TextFormat(FONT_NAME), fi:TextField = new TextField;
    fm.size = size; fm.color = color; fm.leftMargin = 0; fm.bold = false;
    if (hasSpacing) fm.letterSpacing = 3;
    fi.defaultTextFormat = fm;
    if (FONT_NAME != DEFAULT_FONT_NAME) fi.embedFonts = true;
    fi.x = x; fi.y = y; fi.width = width; fi.height = height; fi.selectable = false;
    return fi;
}
import flash.display.*;
import flash.filters.*;
import flash.geom.*;
import flash.events.*;
import flash.text.*;
import flash.utils.*;
//import flash.desktop.*;
const CLICK_STR:String = "CLICK ";
//const CLICK_STR:String = "TAP ";
import net.wonderfl.utils.FontLoader;
const DEFAULT_FONT_NAME:String = "_typewriter";
//const FONT_NAME:String = "_typewriter";
const FONT_NAME:String = "Bebas";
var main:Main, bd:BitmapData;
var playButton:PlayButton;
// Initialize a bitmap, a font and events.
function initializeFirst():void {
    bd = new BitmapData(SCREEN_WIDTH, SCREEN_HEIGHT, false);
    bd.fillRect(bd.rect, 0);
    main.addChild(new Bitmap(bd));
    main.stage.addEventListener(MouseEvent.MOUSE_DOWN, onMousePressed);
    main.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseReleased);
    main.stage.addEventListener(Event.MOUSE_LEAVE, onMouseReleased);
    //main.stage.addEventListener(Event.DEACTIVATE, function (e:Event):void { NativeApplication.nativeApplication.exit(); } );
    setRandomSeed(getTimer());
    loadFont();
}
function loadFont():void {
    if (FONT_NAME == DEFAULT_FONT_NAME) { onFontLoaded(); return; }
    var loader:FontLoader = new FontLoader();
    loader.addEventListener(Event.COMPLETE, onFontLoaded);
    loader.load(FONT_NAME);
}
function onFontLoaded():void {
    initializeBlurs();
    cg = new Cg;
    startTitle();
    if (DEBUG) startGame();
    main.addEventListener(Event.ENTER_FRAME, updateFrame);
}
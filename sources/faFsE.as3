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
const TITLE = "CHARGE SEVEN", KEYS = ["<>^v"], OPERATIONS = ["MOVE"];
const RANK_CYCLE_SCORE = 100, RANK_CYCLE_INCREMENT = 1, RANK_NEXT_CYCLE_INCREMENT = 0.2;
var checkBossTicks, randSeed, bossRandSeed, rank, bossPatterns = new Vector.<BossPattern>(3);
const SHARED_OBJECT_NAME = "abagames_charge_seven";
var stage:int = 1, isStageCleared;
function resetSharedObject() {
    sharedData.stage = 1;
    boss = null;
}
function initialize() {
    if (sharedData.stage) stage = sharedData.stage;
    if (!boss) startStage();
    else retryStage();
    for (var i = 0; i < 3; i++) bossPatterns[i] = new BossPattern;
}
function startStage() {
    removeAllSprites();
    sharedData.stage = stage;
    addMessage("STAGE " + stage, SCREEN_CENTER, SCREEN_CENTER, 60, -99999, true);
    rank = sawtoothWave(Number(stage) / 10, 0.25) * 0.15;
    randSeed = stage * 69069;
    checkBossTicks = 30;
    ship = null;
}
function retryStage() {
    addMessage("STAGE " + stage, SCREEN_CENTER, SCREEN_CENTER, 30, -99999, true);
    initializeStage();
}
function initializeStage() {
    checkBossTicks = -1;
    setRandomSeed(bossRandSeed);
    boss = new Boss(rank);
    bullets = new Vector.<Bullet>;
    ship = new Ship;
    isStageCleared = false;
    if (!IS_USING_KEYS) addMessage("DRAG TO MOVE", 150, 400);
}
class BossPattern {
    var botCount, randSeed;
}
function update() {
    if (checkBossTicks < 0) {
        boss.update();
        if (checkBossTicks >= 0) return;
        boss.draw();
        updateActors(bullets);
        drawAllBullets();
        ship.update();
    } else {
        updateCheckBoss();
    }
}
function updateCheckBoss() {
    if (checkBossTicks > 0) {
        if (checkBossTicks == 30) {
            if (boss) { boss.remove(); boss = null; }
        }
        if (checkBossTicks % 10 == 0) {
            if (boss) { boss.remove(); bossPatterns[checkBossTicks / 10].botCount = bots.length; }
            bossPatterns[checkBossTicks / 10 - 1].randSeed = randSeed;
            setRandomSeed(randSeed++);
            boss = new Boss(rank);
            bullets = new Vector.<Bullet>;
            bots = new Vector.<Bot>;
            for (var i = 0; i < 70; i++) bots.push(new Bot);
            for (var i = 0; i < 30; i++) bots.push(new Bot(true));
        }
        checkBoss();
        if (bots.length <= 0) checkBossTicks = int(checkBossTicks / 10) * 10;
        else checkBossTicks--;
    } else {
        boss.remove(); bossPatterns[0].botCount = bots.length;
        bossPatterns = bossPatterns.sort(function(v1, v2) { return v1.botCount - v2.botCount; } );
        var pi = 1;
        if (bossPatterns[pi].botCount <= 1) {
            pi = 2;
            if (bossPatterns[pi].botCount <= 1) { rank /= 2; if (rank > 1) rank = 1; }
        }
        bossRandSeed = bossPatterns[pi].randSeed;
        initializeStage();
    }    
}
function drawAllBullets() {
    drawBullets(3, 0.5, 0x777777);
    drawBullets(2, 0.8, 0x999999);
    drawBullets(1, 1.3, 0xbbbbbb);
    drawBullets(0, 1, 0xffffff);
}
function checkBoss() {
    for (var i = 0; i < 25; i++) {
        boss.update();
        updateActors(bullets);
        updateActors(bots);
    }
    boss.draw();
    drawBullets(0, 1, 0x888888);
    drawBots();
}
var bullets;
class Bullet extends Actor {
    const MIN_SPEED = 3, MAX_SPEED = 15;
    var angle, speed, size;
    var barrages, barrageDelays, barrageIndex, barrage = null, nextFireTicks;
    var fireCount, fireTicks, fireAngle, fireAngleVel, fireSpeed, fireSpeedVel;
    var isAngleReverse;
    var dpos = new Vec;
    function Bullet(p, a, s, size, barrages = null, barrageDelays = null, isAngleReverse = false, barrageIndex = 0) {
        pos.xy = p; angle = a; speed = s; this.size = size;
        this.barrages = barrages; this.barrageDelays = barrageDelays;
        this.barrageIndex = barrageIndex;
        this.isAngleReverse = isAngleReverse;
        if (barrageIndex < barrages.length) {
            barrage = barrages[barrageIndex]; nextFireTicks = barrageDelays[barrageIndex];
            fire();
        }
    }
    function update() {
        if (barrageIndex > 0) pos.addAngle(angle, speed);
        if (barrage && --nextFireTicks <= 0) {
            if (!updateBarrage()) return false;
        }
        return isInScreen(pos, size / 2);
    }
    function draw(dist, sz, color) {
        if (barrageIndex <= 0) return;
        dpos.xy = pos;
        dpos.addAngle(angle, -speed * dist);
        var s = size * sz;
        fillRect(dpos.x, dpos.y, s, s, color);
    }
    function fire() {
        var aw = barrage.angleWidth, av = barrage.angleVel;
        if (isAngleReverse) { aw = -aw; av = -av; }
        fireCount = barrage.count; fireTicks = 0;
        fireAngle = angle - aw / 2;
        fireAngleVel = av;
        fireSpeed = speed * (1 - barrage.speedWidth / 2);
        if (fireCount > 1) fireSpeedVel = speed * barrage.speedWidth / (fireCount - 1);
    }
    function updateBarrage() {
        while (fireTicks <= 0 && fireCount > 0) {
            var fs = fireSpeed;
            if (fs < MIN_SPEED) fs = MIN_SPEED;
            else if (fs > MAX_SPEED) fs = MAX_SPEED;
            bullets.push(new Bullet(pos, fireAngle, fs, size, barrages, barrageDelays,  isAngleReverse, barrageIndex + 1));
            fireAngle += fireAngleVel; fireSpeed += fireSpeedVel;
            fireCount--; fireTicks = barrage.delay;
        }
        fireTicks--;
        return fireCount > 0;
    }
}
function drawBullets(dist, sz, color) {
    for each (var b in bullets) b.draw(dist, sz, color);
}
class Barrage {
    var count, angleWidth, angleVel = 0, speedWidth = 0, speedVel = 0, delay = 0;
    var isRound;
    function Barrage() {
        count = 1 + randi(10);
        switch (randi(4)) {
            case 0: angleWidth = 0; break;
            case 1: angleWidth = PI * 2 * randpm(); isRound = true;  break;
            case 2: angleWidth = PI * (0.1 + randn(0.1)) * randpm(); break;
            case 3: angleWidth = PI * (0.3 + randn(0.4)) * randpm(); break;
        }
        if (randi(2) == 0) speedWidth = (0.5 + randn(0.5)) * randpm();
        if (randi(2) == 0) delay = 1 + randi(2);
        if (angleWidth == 0 && speedWidth == 0 && delay == 0) {
            angleWidth = PI * 0.25 * randpm();  speedWidth = 0.25 * randpm(); delay = 1;
        }
        setAngleVel();
    }
    function setAngleVel() {
        if (count > 1) {
            if (isRound) angleVel = angleWidth / count;
            else angleVel = angleWidth / (count - 1);
        } else {
            angleWidth = speedWidth = delay = 0;
        }
    }
    function get rank() {
        return 1 + count * 3 / (abs(angleWidth) + PI * 2);
    }
    function adjustRank(v) {
        var pc = count;
        count *= v;
        if (count < 1) count = 1;
        setAngleVel();
        return count / pc;
    }
}
function randpm() { return randi(2) * 2 - 1; }
class Turret {
    var barrages = new Vector.<Barrage>, barrageDelays = new Vector.<int>;
    var interval, isAiming = true, angleVel = 0, waveAngleWidth = 0, waveInterval;
    var fireTicks = 0, waveTicks = 0, aimAngle = 0, baseAngle = 0, angle = 0, speed, size;
    var isAngleReverse = false, hasMirrored;
    function Turret(targetRank, a = 0, hasMirrored = false) {
        baseAngle = a;
        speed = 4 + randi(3);
        size = 10 + randi(4);
        interval = 2 + randi(32);
        createBarrage(targetRank * interval);
        if (randi(2) == 0) isAiming = false;
        switch (randi(3)) {
            case 1: angleVel = PI * (0.025 + randn(0.05)) * randpm(); break;
            case 2: waveAngleWidth = PI * (0.3 + randn(0.6)) * randpm();
                    waveInterval = 15 + randi(30);
                    break;
        }
        this.hasMirrored = hasMirrored;
    }
    function createBarrage(targetRank) {
        var br = 1, bc = 1 + randn(3);
        for (var i = 0; i < bc; i++) {
            var b = new Barrage;
            barrages.push(b);
            br *= b.rank;
            var bd = 0;
            if (i > 0) bd = randi(32 / bc);
            barrageDelays.push(bd);
        }
        var ar = targetRank / br;
        var ai = randi(bc);
        for (i = 0; i < bc; i++) {
            ar /= barrages[ai].adjustRank(ar);
            ai++; if (ai >= bc) ai = 0;
        }
    }
    function update(p, mp = null) {
        if (--fireTicks <= 0) {
            if (isAiming) {
                if (ship) {
                    aimAngle = ship.pos.angle(p);
                } else if (bots.length > 0) {
                    var pp:Vec = bots[0].pos;
                    aimAngle = pp.angle(p);
                }
            }
            bullets.push(new Bullet(p, baseAngle + angle + aimAngle, speed, size, barrages, barrageDelays, isAngleReverse));
            if (hasMirrored) {
                if (isAiming) {
                    if (ship) {
                        aimAngle = ship.pos.angle(mp);
                    } else if (bots.length > 0) {
                        aimAngle = pp.angle(mp);
                    }
                }
                bullets.push(new Bullet(mp, -baseAngle - angle + aimAngle, speed, size, barrages, barrageDelays, !isAngleReverse));
            }
            isAngleReverse = !isAngleReverse;
            fireTicks = interval;
        }
        if (angleVel != 0) angle += angleVel;
        if (waveAngleWidth != 0) {
            var wr = waveTicks++ % (waveInterval * 2) / waveInterval;
            if (wr <= 1) angle = waveAngleWidth * (wr - 0.5);
            else angle = waveAngleWidth * (1.5 - wr);
        }
    }
}
var boss;
class Boss extends Actor {
    var cy, width, height, wFreq, hFreq;
    var centerTurret, sideTurret, sideTurretOfs = new Vec;
    var ticks, sideTurretPos = new Vec, sideTurretMirrorPos = new Vec;
    var sprites = new Vector.<PrimitiveSprite>, spriteOffsets = new Vector.<Vec>;
    var collisionLU = new Vec(0, -SCREEN_HEIGHT * 0.05);
    var collisionRL = new Vec(0, SCREEN_HEIGHT * 0.05);
    var isDestroyed, destroyedTicks = 40;
    function Boss(rank) {
        super(PrimitiveShape.CIRCLE, 15);
        cy = rands(0.2, 0.1);
        width = rands(0.1, 0.1); height = rands(0.05, 0.05);
        wFreq = 0.01 + randn(0.04); hFreq = 0.01 + randn(0.04);
        switch (randi(3)) {
            case 0: centerTurret = new Turret(rank); break;
            case 1: sideTurret = new Turret(rank / 2, randn(0.2) - 0.1, true); break;
            case 2:
                centerTurret = new Turret(rank / 3);
                sideTurret = new Turret(rank / 3, randn(0.6) - 0.3, true); break;
        }
        sideTurretOfs.x = rands(0.1, 0.2); sideTurretOfs.y = rands( -0.1, 0.2);
        setCollision(sideTurretOfs.x, sideTurretOfs.y);
        var w = 0.1 + randn(0.2);
        addTriangle(0, 0, sideTurretOfs.x, sideTurretOfs.y, w);
        addTriangle(0, 0, -sideTurretOfs.x, sideTurretOfs.y, w);
        for (var i = 0; i < randi(3); i++) {
            var x = rands(0.05, 0.25), y = rands(-0.1, 0.3), w = 0.1 + randn(0.3);
            addTriangle(0, 0, x, y, w); addTriangle(0, 0, -x, y, w);
            setCollision(x, y);
        }
        if (checkBossTicks >= 0) {
            sprite.alpha = 0.5;
            for each (var s in sprites) s.alpha = 0.5;
        }
        ticks = randn(300);
    }
    function setCollision(x, y) {
        if (x > collisionRL.x) {
            collisionRL.x = x; collisionLU.x = -x;
        }
        if (y > collisionRL.y) collisionRL.y = y;
        if (y < collisionLU.y) collisionLU.y = y;
    }
    function addTriangle(x1, y1, x2, y2, w) {
        var l = getLength(x1 - x2, y1 - y2);
        var s = new PrimitiveSprite(new PrimitiveShape(PrimitiveShape.TRIANGLE, l * w, l * 0.8));
        s.angle = atan2(x1 - x2, y1 - y2);
        sprites.push(s); spriteOffsets.push(new Vec((x1 + x2) / 2, s.y = (y1 + y2) / 2));
    }
    function update() {
        if (isDestroyed) {
            if (isMouseClicked || isButtonPressed) destroyedTicks = 0;
            if (--destroyedTicks <= 0) { stage++; startStage(); }
            return;
        }
        var vx = pos.x, vy = pos.y;
        pos.x = SCREEN_CENTER + sin(ticks * wFreq) * width;
        pos.y = cy + cos(ticks * hFreq) * height;
        vx -= pos.x; vy -= pos.y;
        ticks++;
        if (centerTurret) centerTurret.update(pos);
        if (sideTurret) {
            sideTurretPos.x = pos.x + sideTurretOfs.x;
            sideTurretMirrorPos.x = pos.x - sideTurretOfs.x;
            sideTurretPos.y = sideTurretMirrorPos.y = pos.y + sideTurretOfs.y;
            sideTurret.update(sideTurretPos, sideTurretMirrorPos);
        }
    }
    function draw() {
        sprite.pos = pos;
        for (var i = 0; i < sprites.length; i++ ) {
            var s = sprites[i], o = spriteOffsets[i];
            s.x = pos.x + o.x; s.y = pos.y + o.y;
        }
    }
    function remove() {
        sprite.remove();
        for each (var s in sprites) s.remove();
    }
    function isHit(p, s) {
        if (isDestroyed) return false;
        if (p.x > pos.x + collisionLU.x - s && p.x < pos.x + collisionRL.x + s &&
            p.y > pos.y + collisionLU.y - s && p.y < pos.y + collisionRL.y + s) {
            addParticlesRound(200, pos, 15, 15);
            remove();
            isDestroyed = true;
            return true;
        }
        return false;
    }
}
var bots;
class Bot extends Actor {
    const SIZE = 1, SPEED = 7;
    var vel = new Vec, ticks = 0;
    function Bot(isStopped = false) {
        if (isStopped) {
            pos.x = rands(0, 1); pos.y = rands(0.5, 0.5);
            ticks = 99999;
        } else {
            pos.x = SCREEN_CENTER; pos.y = SCREEN_HEIGHT * 0.8;
        }
    }
    function update() {
        if (--ticks <= 0) {
            if (vel.x == 0 && vel.y == 0) {
                var a = randn(PI * 2);
                vel.x = sin(a) * SPEED; vel.y = cos(a) * SPEED;
            } else {
                vel.x = vel.y = 0;
            }
            ticks = 15 + randi(15);
        }
        pos.incrementBy(vel);
        if (pos.x < 0 || pos.x > SCREEN_WIDTH) vel.x *= -1;
        if (pos.y < SCREEN_HEIGHT / 2 || pos.y > SCREEN_HEIGHT) vel.y *= -1;
        var x = pos.x, y = pos.y;
        for each (var b in bullets) {
            var d = (SIZE + b.size) / 2;
            if (b.pos.y > y - d && b.pos.y < y + d && b.pos.x > x - d && b.pos.x < x + d) return false;
        }
        return true;
    }
    function draw() {
        fillRect(pos.x, pos.y, SIZE + 4, SIZE + 4, 0x888888);
        fillRect(pos.x, pos.y, SIZE, SIZE, 0x111111);
    }
}
function drawBots() {
    for each (var b in bots) b.draw();
}
var ship;
class Ship extends Actor {
    const SIZE = 20, SPEED = 7;
    var target = new Vec, targetSprite, isMoving, isDestroyed;
    var shot;
    function Ship() {
        super(PrimitiveShape.TRIANGLE, SIZE);
        pos.x = target.x = SCREEN_CENTER; pos.y = target.y = SCREEN_HEIGHT * 0.8;
        sprite.angle = PI;
        targetSprite = new PrimitiveSprite(new PrimitiveShape(PrimitiveShape.CIRCLE, 15));
        targetSprite.alpha = 0.7;
        shot = new Shot;
    }
    function update() {
        if (!isDestroyed || shot.isReleased) {
            shot.update();
            if (shot.isFiring) destroy(true);
        }
        if (isDestroyed) return;
        if (isMouseClicked) {
            target.x = pos.x; target.y = pos.y;
        }
        if (isMousePressed) {
            target.x += mouseVel.x; target.y += mouseVel.y;
            setMoving();
        }
        var st = stick();
        if (st.length > 0) {
            st.scaleBy(SPEED);
            pos.incrementBy(st);
            keepInScreen(pos, -SIZE / 2);
        } else if (isMoving) {
            if (target.distance(pos) <= SPEED) {
                pos.xy = target;
                targetSprite.visible = isMoving = false;
            } else {
                pos.addAngle(target.angle(pos), SPEED);
            }
        }
        sprite.pos = pos;
        for each (var b in bullets) {
            if (pos.distance(b.pos) < b.size / 2) destroy();
        }
    }
    function setMoving() {
        isMoving = true;
        keepInScreen(target, -SIZE / 2);
        targetSprite.pos = target;
        targetSprite.visible = true;
    }
    function destroy(isSelfDefeat = false) {
        if (isDestroyed) return;
        if (isSelfDefeat) {
            addParticlesAngle(100, pos, 0, 15, 10);
        } else {
            addParticlesRound(200, pos, 15, 10);
            shot.sprite.remove();
            startGameOver();
        }
        isDestroyed = true;
        targetSprite.visible = false;
        sprite.remove();
    }
}
var shot;
class Shot extends Actor {
    const BASE_SIZE = 20, FIRE_TICKS = 30 * 7;
    var ticks = FIRE_TICKS, isFiring, size;
    function Shot() {
        super(PrimitiveShape.BOX, BASE_SIZE);
    }
    function update() {
        if (ticks > 0) {
            size = sin(ticks * 0.7) * 2 + (FIRE_TICKS - ticks) * 0.12;
            if (size < 0) size = 0;
            sprite.scale = size / BASE_SIZE;
            sprite.x = pos.x = ship.pos.x; sprite.y = pos.y = ship.pos.y - BASE_SIZE / 2;
            cg.print(String(int(ticks / 30) + 1), ship.pos.x, ship.pos.y + BASE_SIZE / 2);
        } else {
            addParticlesAngle(10, pos, 20, 5);
            if (ticks == 0) isFiring = true;
            else isFiring = false;
            pos.y -= 20;
            sprite.pos = pos;
            if (boss.isHit(pos, size / 2)) {
                addMessage("CLEAR", SCREEN_CENTER, SCREEN_HEIGHT * 0.7, 30, -99999, true);
                isStageCleared = true;
            }
            if (pos.y < -BASE_SIZE && !isStageCleared) startGameOver();
        }
        sprite.angle = ticks * 0.5;
        ticks--;
    }
    function get isReleased() {
        return ticks <= 0;
    }
}
/*----------------------------------------------------------------*/
import flash.display.*;
import flash.filters.*;
import flash.geom.*;
import flash.events.*;
import flash.text.*;
import flash.utils.*;
import flash.net.*;
import flash.desktop.*;
// Initialize a screen, a font and events.
const SCREEN_WIDTH:int = 465, SCREEN_HEIGHT:int = 465, SCREEN_CENTER:int = SCREEN_WIDTH / 2;
const DEFAULT_FONT_NAME:String = "_typewriter";
var main:Main, bd:BitmapData;
var sharedObject:SharedObject, sharedData:Object;
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
    addCoverSprites(-SCREEN_HEIGHT); addCoverSprites(SCREEN_HEIGHT);
    if (SHARED_OBJECT_NAME) {
        sharedObject = SharedObject.getLocal(SHARED_OBJECT_NAME);
        sharedData = sharedObject.data;
    }
    startTitle();
    if (DEBUG) startGame();
    main.addEventListener(Event.ENTER_FRAME, updateFrame);
}
// Update a frame.
function updateFrame(event:Event):void {
    updateInput();
    bd.lock();
    bd.fillRect(bd.rect, 0);
    if (isInGame) update();
    else if (isTitle) updateTitle();
    else { update(); drawGameOver(); }
    updateParticles(); updateNumberBoards(); updateMessages();
    bd.unlock();
    ticks++;
    if (isGameOver) {
        gameOverTicks--;
        if (gameOverTicks <= 0 || (isMouseClicked || isButtonPressed)) startTitle();
    }
}
// Handle a game state (Title/In game/Game over).
const GAME_OVER_DURATION:int = 120;
var ticks:int, gameOverTicks:int
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
    ticks = 0;
    initialize();
}
function startGameOver():void {
    if (!isInGame) return;
    gameOverTicks = GAME_OVER_DURATION;
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
    drawTitle(TITLE, KEYS, OPERATIONS);
}
function drawTitle(title:String, buttonStrs:Array, operationStrs:Array):void {
    cg.print(title, 100, 100);
    if (!IS_USING_KEYS || !buttonStrs) return;
    for (var i:int = 0, y:int = 200; i < buttonStrs.length; i++, y += 30) {
        cg.printKeys(buttonStrs[i], 120, y); cg.print(operationStrs[i], 240, y);
    }
    y += 10;
    cg.printKeys("Z", 120, y);
    cg.print("START", 240, y)
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
    public const RESET_TICKS:int = 5 * 30;
    public var button:PrimitiveSprite, plate:PrimitiveSprite;
    public var isPressAndReleased:Boolean, isPressed:Boolean, wasPressed:Boolean;
    public var pressedTicks:int;
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
                    if (!wasPressed) { pressButton(); pressedTicks = 0; }
                    if (++pressedTicks > RESET_TICKS) {
                        resetSharedObject(); 
                        releaseButton();
                        isPressAndReleased = true;
                    }
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
function addMessage(s:String, x:Number, y:Number, ticks:int = 90,  arrowAngle:Number = -99999, isShowingAlways:Boolean = false):Message {
    if (!isInGame) return null;
    if (!isShowingAlways) {
        if (shownMessages.indexOf(s) >= 0) return null;
        shownMessages.push(s);
    }
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
var mouse:Vec = new Vec, isMousePressed:Boolean, isMouseClicked:Boolean, isMouseReleased:Boolean;
var mouseVel:Vec = new Vec, mouseDragDist:Vec = new Vec;
var keys:Vector.<Boolean> = new Vector.<Boolean>(256);
var isWPressed:Boolean, isAPressed:Boolean, isSPressed:Boolean, isDPressed:Boolean;
var wasMousePressed:Boolean, prevMouse:Vec = new Vec;
var currentMouse:Vec = new Vec, isCurrentMousePressed:Boolean;
var currentKeys:Vector.<Boolean> = new Vector.<Boolean>(256);
var stickVec:Vec = new Vec, stickMVec:Vec = new Vec;
function onMousePressed(e:MouseEvent):void { isCurrentMousePressed = true; onMouseMoved(e); }
function onMouseReleased(e:Event):void { isCurrentMousePressed = false; }
function onMouseMoved(e:MouseEvent):void {
    if (e.buttonDown) { currentMouse.x = e.stageX; currentMouse.y = e.stageY; }
}
function onKeyPressed(e:KeyboardEvent):void { currentKeys[e.keyCode] = true; }
function onKeyReleased(e:KeyboardEvent):void { currentKeys[e.keyCode] = false; }
function updateInput():void {
    getCurrentInput();
}
function getCurrentInput():void {
    mouse.x = currentMouse.x; mouse.y = currentMouse.y;
    isMousePressed = isCurrentMousePressed;
    updateMouseState();
    for (var i:int = 0; i < 256; i++) keys[i] = currentKeys[i];
    updateStick();
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
function updateStick():void {
    isWPressed = (keys[0x26] || keys[0x57]);
    isAPressed = (keys[0x25] || keys[0x41]);
    isSPressed = (keys[0x28] || keys[0x53]);
    isDPressed = (keys[0x27] || keys[0x44]);
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
// Platform dependent part.
// For PC.
const CLICK_STR:String = "CLICK";
const IS_USING_KEYS:Boolean = true;
// For Android.
//const CLICK_STR:String = "TAP";
//const IS_USING_KEYS:Boolean = false;
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
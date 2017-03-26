// forked from ABA's forked from: forked from: AAShip
// forked from ABA's forked from: AAShip
// forked from ABA's AAShip
// AAShip.as
//  Ascii art ship.
//  [Control]
//   Movement: Arrow or [WASD] keys.
//   Fire:    [Z], [X], [.] or [/] key.
package
{
    import flash.display.Sprite;
    import flash.display.BitmapData;
    import flash.display.Bitmap;
    import flash.geom.Rectangle;
    import flash.text.TextField;
    import flash.events.Event;
    import flash.events.KeyboardEvent;

    [SWF(width="465", height="465", backgroundColor="0x000000", frameRate="30")]
    public class AAShip extends Sprite
    {
        public static const SCREEN_WIDTH:int = 465;
        public static const SCREEN_HEIGHT:int = 465;
        private const BLUR_MAX_COUNT:int = 512;
        private const BLUR_HISTORY_COUNT:int = 6;
        private const SHIP_SPEED:Number = 8;
        private const SHOT_MAX_COUNT:int = 12;
        private const SHOT_SPEED:Number = 20;
        private const SHIP_COLLISION_SIZE:Number = 5;
        private const SHIP_INVINCIBLE_TICKS:int = 90;
        private const ENEMY_MAX_COUNT:int = 16;
        private const BULLET_MAX_COUNT:int = 128;
        private const SPARK_MAX_COUNT:int = 64;
        private const ZAKO1_APPEARANCE_INTERVAL:Number = 30;
        private const MID1_APPEARANCE_INTERVAL:Number = 180;
        public static var gameSpeed:Number;
        private var buffer:BitmapData = new BitmapData(SCREEN_WIDTH, SCREEN_HEIGHT, false, 0);
        private var rect:Rectangle = new Rectangle;
        private var offset:Vector2 = new Vector2;
        private var blurs:Vector.<Vector.<Blur>> = new Vector.<Vector.<Blur>>(BLUR_HISTORY_COUNT, true);
        private var blurCounts:Vector.<int> = new Vector.<int>(BLUR_HISTORY_COUNT, true);
        private var blurIndex:int;
        private var shipChar:AAChar;
        private var shipSprite:Sprite = new Sprite;
        private var shipPos:Vector2 = new Vector2;
        private var shipAngle:Number;
        private var shipInvincibleTicks:int;
        private var shipFireCount:int;
        private var shipFireTicks:Number;
        private var shotChar:AAChar;
        private var shots:Vector.<Shot> = new Vector.<Shot>(SHOT_MAX_COUNT, true);
        private var enemies:Vector.<Enemy> = new Vector.<Enemy>(ENEMY_MAX_COUNT, true);
        private var zako1:Zako1, mid1:Mid1;
        private var bulletChar:AAChar;
        private var bullets:Vector.<Bullet> = new Vector.<Bullet>(BULLET_MAX_COUNT, true);
        private var sparkChar:AAChar;
        private var sparks:Vector.<Spark> = new Vector.<Spark>(SPARK_MAX_COUNT, true);
        private var bulletIntervalRank:Number;
        private var bulletSpeedRank:Number;
        private var enemyIntervalRank:Number;
        private var enemySpeedRank:Number;
        private var rankTicks:int;

        public function AAShip()
        {
            stage.scaleMode = "noScale";
            addChild(new Bitmap(buffer));
            stage.addEventListener(KeyboardEvent.KEY_DOWN, Key.onKeyDown);
            stage.addEventListener(KeyboardEvent.KEY_UP, Key.onKeyUp);
            AAChar.initialize();
            Field.initialize();
            var i:int;
            for (i = 0; i < BLUR_HISTORY_COUNT; i++)
            {
                var bs:Vector.<Blur> = new Vector.<Blur>(BLUR_MAX_COUNT, true);
                for (var j:int = 0; j < BLUR_MAX_COUNT; j++)
                {
                    bs[j] = new Blur;
                }
                blurs[i] = bs;
                blurCounts[i] = 0;
            }
            blurIndex = 0;
            shipChar = new AAChar([" A ", "I#I"], [" R ", "CBC"], 2, 2);
            shipChar.drawToSprite(shipSprite);
            shipInvincibleTicks = -SHIP_INVINCIBLE_TICKS;
            shotChar = new AAChar(["!"], ["Y"]);
            for (i = 0; i < SHOT_MAX_COUNT; i++)
            {
                shots[i] = new Shot;
                shotChar.drawToSprite(shots[i].sprite);
            }
            zako1 = new Zako1; mid1 = new Mid1;
            for (i = 0; i < ENEMY_MAX_COUNT; i++)
            {
                enemies[i] = new Enemy;
            }
            bulletChar = new AAChar(["#"], ["P"], 1, 1);
            for (i = 0; i < BULLET_MAX_COUNT; i++)
            {
                bullets[i] = new Bullet;
                bulletChar.drawToSprite(bullets[i].sprite);
            }
            sparkChar = new AAChar(["*"], ["Y"]);
            for (i = 0; i < SPARK_MAX_COUNT; i++)
            {
                sparks[i] = new Spark;
                sparkChar.drawToSprite(sparks[i].sprite);
            }
            bulletIntervalRank = bulletSpeedRank = enemyIntervalRank = enemySpeedRank = 1.0 / 0.5;
            gameSpeed = 1.0;
            addEventListener(Event.ENTER_FRAME, onEnterFrame);
        }

        private function initializeShip():void
        {
            shipPos.x = 0;
            shipPos.y = Field.size.y / 2;
            shipAngle = 0.0;
            shipFireCount = 0;
            shipFireTicks = 0;
            bulletIntervalRank *= 0.5; bulletSpeedRank *= 0.5;
            enemyIntervalRank *= 0.5; enemySpeedRank *= 0.5;
            if (bulletIntervalRank < 0.5) bulletIntervalRank = 0.5;
            if (bulletSpeedRank < 0.5) bulletSpeedRank = 0.5;
            if (enemyIntervalRank < 0.5) enemyIntervalRank = 0.5;
            if (enemySpeedRank < 0.5) enemySpeedRank = 0.5;
            rankTicks = 0;
            zako1.appearanceTicks = 0;
            mid1.appearanceTicks = MID1_APPEARANCE_INTERVAL;
            shipChar.setSpriteMatrix(shipSprite, shipPos, shipAngle);
            addChild(shipSprite);
        }

        private function onEnterFrame(event:Event):void
        {
            buffer.fillRect(buffer.rect, 0);
            var i:int;
            blurCounts[blurIndex] = 0;
            updateSparks();
            updateShots();
            if (shipInvincibleTicks > -SHIP_INVINCIBLE_TICKS) updateShip();
            else if (shipInvincibleTicks == -SHIP_INVINCIBLE_TICKS) initializeShip();
            else Field.offsetX *= 0.95;
            shipInvincibleTicks++;
            updateEnemies();
            updateBullets();
            rankTicks++;
            bulletIntervalRank += 0.02;
            if (rankTicks % (10 * 30) == 0) bulletIntervalRank *= 0.5;
            bulletSpeedRank += 0.005;
            if (rankTicks % (15 * 30) == 0) bulletSpeedRank *= 0.5;
            enemyIntervalRank += 0.005;
            if (rankTicks % (21 * 30) == 0) enemyIntervalRank *= 0.5;
            enemySpeedRank += 0.002;
            if (rankTicks % (27 * 30) == 0) enemySpeedRank *= 0.5;
            buffer.lock();
            Field.draw(buffer);
            var bi:int = blurIndex + 1;
            for (i = 0; i < BLUR_HISTORY_COUNT; i++)
            {
                if (bi >= BLUR_HISTORY_COUNT) bi = 0;
                for (var j:int = 0; j < blurCounts[bi]; j++)
                {
                    updateBlur(blurs[bi][j]);
                }
                bi++;
            }
            Field.drawSideBoard(buffer);
            buffer.unlock();
            blurIndex++;
            if (blurIndex >= BLUR_HISTORY_COUNT) blurIndex = 0;
        }

        private function updateShip():void
        {
            var px:Number = shipPos.x;
            var vx:Number = 0, vy:Number = 0;
            if (Key.left) vx = -1;
            if (Key.right) vx = 1;
            if (Key.up) vy = -1;
            if (Key.down) vy = 1;
            if (vx != 0 && vy != 0)
            {
                vx *= 0.7; vy *= 0.7;
            }
            shipPos.x += vx * SHIP_SPEED * gameSpeed;
            shipPos.y += vy * SHIP_SPEED * gameSpeed;
            if (shipPos.x < -SCREEN_WIDTH / 2) shipPos.x = -SCREEN_WIDTH / 2;
            if (shipPos.x > SCREEN_WIDTH / 2) shipPos.x = SCREEN_WIDTH / 2;
            if (shipPos.y < -SCREEN_HEIGHT / 2) shipPos.y = -SCREEN_HEIGHT / 2;
            if (shipPos.y > SCREEN_HEIGHT / 2) shipPos.y = SCREEN_HEIGHT / 2;
            shipAngle += (shipPos.x - px) * 0.01;
            shipAngle *= 0.8;
            Field.offsetX = shipPos.x * 0.33;
            shipChar.setSpriteMatrix(shipSprite, shipPos, shipAngle);
            if (shipInvincibleTicks >= 0 || (-shipInvincibleTicks % 15 > 7))
            {
                addBlursOfAAChar(shipChar, shipPos, shipAngle);
            }
            var s:Shot;
            if (Key.button1 && shipFireTicks <= 0)
            {
                shipFireTicks += 1.0;
                offset.x = 15;
                offset.y = 0;
                offset.rotation(shipAngle);
                s = getActorInstance(Vector.<Actor>(shots));
                var i:int = shipFireCount % 2;
                if (s != null)
                {
                    s.pos.x = shipPos.x + offset.x * (i * 2 - 1);
                    s.pos.y = shipPos.y + offset.y * (i * 2 - 1);
                    s.angle = shipAngle;
                    s.ticks = 0;
                    addBlur(s.pos.x, s.pos.y, 10, 10, 255, 255, 0);
                    shotChar.setSpriteMatrix(s.sprite, s.pos, s.angle);
                    addChild(s.sprite);
                    shipFireCount++;
                }
            }
            shipFireTicks -= gameSpeed;
            if (shipInvincibleTicks >= 0)
            {
                for each (var e:Enemy in enemies)
                {
                    if (!e.exists) continue;
                    if (Math.abs(shipPos.x - e.pos.x) <= e.spec.size.x - 12 &&
                        Math.abs(shipPos.y - e.pos.y) <= e.spec.size.y - 12)
                    {
                        shipDestroyed();
                        e.exists = false;
                        removeChild(e.sprite);
                        return;
                    }
                }
                for each (var b:Bullet in bullets)
                {
                    if (!b.exists) continue;
                    if (shipPos.getRoughDistance(b.pos) <= SHIP_COLLISION_SIZE)
                    {
                        shipDestroyed();
                        b.exists = false;
                        removeChild(b.sprite);
                        return;
                    }
                }
            }
        }

        private function updateShots():void
        {
            var s:Shot;
            for each (s in shots)
            {
                if (!s.exists) continue;
                s.pos.x += Math.sin(s.angle) * SHOT_SPEED * gameSpeed;
                s.pos.y -= Math.cos(s.angle) * SHOT_SPEED * gameSpeed;
                if (s.pos.y < -SCREEN_HEIGHT / 2)
                {
                    s.exists = false;
                    removeChild(s.sprite);
                    continue;
                }
                s.ticks += gameSpeed;
                shotChar.setSpriteMatrix(s.sprite, s.pos, s.angle);
                addBlursOfAAChar(shotChar, s.pos, s.angle, 1.0, 1.0, 150, 100, 0);
                for each (var e:Enemy in enemies)
                {
                    if (!e.exists) continue;
                    if (Math.abs(s.pos.x - e.pos.x) <= e.spec.size.x &&
                        Math.abs(s.pos.y - e.pos.y) <= e.spec.size.y)
                    {
                        addSpark(s.pos, s.angle + Math.PI, 0.2, SHOT_SPEED, 1.0, 2);
                        e.shield--;
                        e.isHit = true;
                        s.exists = false;
                        removeChild(s.sprite);
                        break;
                    }
                }
            }
        }

        private function updateEnemies():void
        {
            var e:Enemy;
            var es:EnemySpec = null;
            zako1.appearanceTicks -= gameSpeed;
            if (zako1.appearanceTicks <= 0)
            {
                es = zako1;
                var ei:int = ZAKO1_APPEARANCE_INTERVAL / enemyIntervalRank;
                ei *= (0.75 + Math.random() * 0.5);
                if (ei < 5) ei = 5;
                zako1.appearanceTicks += ei;
            }
            mid1.appearanceTicks -= gameSpeed;
            if (mid1.appearanceTicks <= 0)
            {
                es = mid1;
                mid1.appearanceTicks += MID1_APPEARANCE_INTERVAL * (0.5 + Math.random());
            }
            if (es != null)
            {
                e = getActorInstance(Vector.<Actor>(enemies));
                if (e != null)
                {
                    e.spec = es;
                    e.speedRatio = enemySpeedRank;
                    var fsr:Number = bulletSpeedRank;
                    if (fsr < 1.0) fsr = 1.0;
                    e.fireSpeedRatio = fsr;
                    var fir:Number = bulletIntervalRank;
                    if (fir > 25.0) fir = 25.0;
                    e.fireIntervalRatio = fir;
                    e.ticks = 0;
                    e.fireTicks = 0.0; e.fireSeqTicks = 0.0; e.fireCount = 0;
                    e.shield = e.spec.shield;
                    e.isHit = false;
                    e.spec.initialize(e, shipPos);
                    e.spec.aaChar.drawToSprite(e.sprite);
                    addChild(e.sprite);
                }
            }
            for each (e in enemies)
            {
                if (!e.exists) continue;
                if (!Field.contains(e.pos) || e.shield <= 0)
                {
                    e.exists = false;
                    removeChild(e.sprite);
                    if (e.shield <= 0) addSpark(e.pos, 0, Math.PI, 4.0, 1.5, 8);
                    continue;
                }
                e.spec.update(e, shipPos, this);
                e.ticks += gameSpeed;
                e.fireTicks -= gameSpeed;
                e.spec.aaChar.setSpriteMatrix(e.sprite, e.pos, e.angle, e.spec.scale.x, e.spec.scale.y);
                if (e.isHit)
                {
                    e.isHit = false;
                    addBlursOfAAChar(e.spec.aaChar, e.pos, e.angle, e.spec.scale.x * 1.5, e.spec.scale.y * 1.5, 255, 255, 0);
                }
                else
                {
                    addBlursOfAAChar(e.spec.aaChar, e.pos, e.angle, e.spec.scale.x, e.spec.scale.y);
                }
            }
        }

        public function fireBullet(p:Vector2, angle:Number, speed:Number, size:Number):void
        {
            if (p.getRoughDistance(shipPos) <= 200 ||
                p.x - Field.offsetX <= -Field.size.x + Field.SIDE_BOARD_WIDTH ||
                p.x - Field.offsetX >= Field.size.x - Field.SIDE_BOARD_WIDTH) return;
            var b:Bullet = getActorInstance(Vector.<Actor>(bullets));
            if (b == null) return;
            b.pos.x = p.x; b.pos.y = p.y;
            b.vel.x = Math.sin(angle) * speed;
            b.vel.y = -Math.cos(angle) * speed;
            b.speed = speed;
            b.size = size;
            addBlur(b.pos.x + b.vel.x * 2, b.pos.y + b.vel.y * 2, 20, 20, 255, 200, 100);
            b.ticks = 0;
            addChild(b.sprite);
        }

        private function updateBullets():void
        {
            var totalSpeed:Number = 0;
            for each (var b:Bullet in bullets)
            {
                if (!b.exists) continue;
                b.pos.addMultiplied(b.vel, gameSpeed);
                if (!Field.contains(b.pos))
                {
                    b.exists = false;
                    removeChild(b.sprite);
                    continue;
                }
                var a:Number = b.ticks * 0.1;
                bulletChar.setSpriteMatrix(b.sprite, b.pos, a, b.size, b.size);
                var sz:Number = b.size * (1.1 + Math.sin(b.ticks * 0.2) * 0.2);
                var cl:int = 128 + 64 + Math.sin(b.ticks * 0.3) * 64;
                addBlursOfAAChar(bulletChar, b.pos, a, sz, sz, cl, 100, 255);
                b.ticks += gameSpeed;
                totalSpeed += b.speed + 5.0;
            }
            if (totalSpeed > 500.0)
            {
                gameSpeed = 1.0 - (totalSpeed - 500.0) / 250.0;
                if (gameSpeed < 0.7) gameSpeed = 0.7;
            }
            else
            {
                gameSpeed = 1.0;
            }
        }

        private function updateSparks():void
        {
            for each (var s:Spark in sparks)
            {
                if (!s.exists) continue;
                s.pos.addMultiplied(s.vel, gameSpeed);
                s.vel.mul(1 - 0.05 * gameSpeed);
                s.size *= (1 - 0.05 * gameSpeed);
                if (!Field.contains(s.pos) || s.ticks <= 0)
                {
                    s.exists = false;
                    removeChild(s.sprite);
                    continue;
                }
                var a:Number = s.ticks * 0.2;
                sparkChar.setSpriteMatrix(s.sprite, s.pos, a, s.size, s.size);
                addBlursOfAAChar(sparkChar, s.pos, a, s.size, s.size,
                                 250, Math.random() * 128 + 128, 0);
                s.ticks -= gameSpeed;
            }
        }

        private function shipDestroyed():void
        {
            addSpark(shipPos, 0, Math.PI, 10.0, 6.0, 20);
            addSpark(shipPos, Math.PI / 2, 0, 30.0, 5.0, 10);
            addSpark(shipPos, -Math.PI / 2, 0, 30.0, 5.0, 10);
            shipInvincibleTicks = -SHIP_INVINCIBLE_TICKS * 1.5;
            removeChild(shipSprite);
        }

        private function addSpark(p:Vector2, angle:Number, ao:Number, speed:Number, size:Number, count:Number):void
        {
            for (var i:int = 0; i < count; i++)
            {
                var s:Spark = getActorInstance(Vector.<Actor>(sparks));
                if (s == null) return;
                s.pos.x = p.x; s.pos.y = p.y;
                var a:Number = angle + ao * (Math.random() * 2 - 1);
                var sp:Number = speed * (0.5 + Math.random());
                s.vel.x = Math.sin(a) * sp;
                s.vel.y = -Math.cos(a) * sp;
                s.size = size;
                s.ticks = 15 + 15 * Math.random();
                sparkChar.setSpriteMatrix(s.sprite, s.pos, a, s.size, s.size);
                addChild(s.sprite);
            }
        }

        private function addBlursOfAAChar(ac:AAChar, p:Vector2, angle:Number, sx:Number = 1, sy:Number = 1,
                                          cr:int = -1, cg:int = -1, cb:int = -1):void
        {
            var br:int, bg:int, bb:int;
            if (cr >= 0)
            {
                br = cr; bg = cg; bb = cb;
            }
            for each (var b:Blur in ac.blurs)
            {
                offset.x = b.pos.x * sx; offset.y = b.pos.y * sy;
                offset.rotation(angle);
                if (cr < 0)
                {
                    br = b.r; bg = b.g; bb = b.b;
                }
                addBlur(p.x + offset.x, p.y + offset.y, b.width * sx, b.height * sy, br, bg, bb);
            }
        }

        private function addBlur(x:Number, y:Number, w:Number, h:Number, r:int, g:int, b:int):void
        {
            if (blurCounts[blurIndex] >= BLUR_MAX_COUNT) return;
            var bl:Blur = blurs[blurIndex][blurCounts[blurIndex]];
            bl.pos.x = x + SCREEN_WIDTH / 2; bl.pos.y = y + SCREEN_HEIGHT / 2;
            bl.width = w; bl.height = h;
            bl.r = r; bl.g = g; bl.b = b;
            blurCounts[blurIndex]++;
        }

        private function updateBlur(b:Blur):void
        {
            rect.x = b.pos.x - b.width / 2 - Field.offsetX;
            rect.y = b.pos.y - b.height / 2;
            rect.width = b.width;
            rect.height = b.height;
            buffer.fillRect(rect, b.r * 0x10000 + b.g * 0x100 + b.b);
            b.width *= 1.2; b.height *= 1.2;
            var a:int = (b.r + b.g + b.b) / 3;
            b.r += (a - b.r) * 0.25;
            b.g += (a - b.g) * 0.25;
            b.b += (a - b.b) * 0.25;
            b.r *= 0.65; b.g *= 0.65; b.b *= 0.65;
        }

        private function getActorInstance(actors:Vector.<Actor>):*
        {
            var al:int = actors.length
            for (var i:int = 0; i < al; i++)
            {
                if (!actors[i].exists)
                {
                    actors[i].exists = true;
                    return actors[i];
                }
            }
            return null;
        }
    }
}

import flash.display.BitmapData;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.geom.Rectangle;
import flash.geom.Matrix;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.events.KeyboardEvent;

class Actor
{
    public var exists:Boolean = false;
    public var pos:Vector2 = new Vector2;
    public var sprite:Sprite = new Sprite;
    public var ticks:Number;
}

class Shot extends Actor
{
    public var angle:Number;
}

class Enemy extends Actor
{
    public var angle:Number;
    public var speed:Number;
    public var speedRatio:Number;
    public var fireSpeedRatio:Number;
    public var fireIntervalRatio:Number;
    public var fireTicks:Number;
    public var fireSeqTicks:Number;
    public var fireCount:int;
    public var shield:int;
    public var isHit:Boolean;
    public var spec:EnemySpec;
}

class EnemySpec
{
    public var size:Vector2 = new Vector2;
    public var scale:Vector2 = new Vector2;
    public var shield:int;
    public var aaChar:AAChar;
    public var appearanceTicks:Number;

    public function initialize(e:Enemy, shipPos:Vector2):void { }
    public function update(e:Enemy, shipPos:Vector2, main:AAShip):void {}
}

class Zako1 extends EnemySpec
{
    private const SPEED:Number = 6;
    private const ANGLE_VELOCITY:Number = 0.05;
    private const FIRE_INTERVAL:Number = 60;
    private const BULLET_SPEED:Number = 5;

    public function Zako1()
    {
        size.x = size.y = 32;
        scale.x = scale.y = 1.0;
        shield = 1;
        aaChar = new AAChar(["<O>", " v "], ["WGW", " C "], 2, 2);
    }

    override public function initialize(e:Enemy, shipPos:Vector2):void
    {
        e.pos.x = Field.size.x * (Math.random() * 2 - 1);
        e.pos.y = -Field.size.y;
        e.angle = Math.PI;
        e.speed = SPEED * e.speedRatio;
    }

    override public function update(e:Enemy, shipPos:Vector2, main:AAShip):void
    {
        e.pos.x += Math.sin(e.angle) * e.speed * AAShip.gameSpeed;
        e.pos.y -= Math.cos(e.angle) * e.speed * AAShip.gameSpeed;
        var pa:Number = Math.atan2(-e.pos.x + shipPos.x, e.pos.y - shipPos.y);
        var ao:Number = pa - e.angle;
        ao = Util.normalizeAngle(ao);
        if (ao > ANGLE_VELOCITY) e.angle += ANGLE_VELOCITY;
        else if (ao < -ANGLE_VELOCITY) e.angle -= ANGLE_VELOCITY;
        else e.angle = pa;
        e.angle = Util.normalizeAngle(e.angle);
        if (e.fireTicks <= 0)
        {
            e.fireTicks += FIRE_INTERVAL / e.fireIntervalRatio;
            main.fireBullet(e.pos, pa, BULLET_SPEED * e.fireSpeedRatio, 1.0);
        }
    }
}

class Mid1 extends EnemySpec
{
    private const WAVE_INTERVAL:int = 120;
    private const SPEED:Number = 1;
    private const FIRE_INTERVAL:Number = 150;
    private const BULLET_SPEED:Number = 5;

    public function Mid1()
    {
        size.x = 64; size.y = 48;
        scale.x = scale.y = 1.2;
        shield = 16;
        aaChar = new AAChar([".__.", "\\##/"], ["RYYR", "WCCW"], 2, 2);
    }

    override public function initialize(e:Enemy, shipPos:Vector2):void
    {
        e.pos.x = Field.size.x * 0.6 * (Math.random() * 2 - 1);
        e.ticks = Math.random() * WAVE_INTERVAL;
        e.pos.y = -Field.size.y;
        e.angle = 0;
        e.speed = SPEED * (Math.random() + 1.0);
        e.fireSpeedRatio = Math.sqrt(e.fireSpeedRatio);
        e.fireIntervalRatio = Math.sqrt(e.fireIntervalRatio);
    }

    override public function update(e:Enemy, shipPos:Vector2, main:AAShip):void
    {
        var xa:Number = e.ticks * Math.PI * 2.0 / WAVE_INTERVAL;
        e.pos.x += Math.sin(xa) * 1.0 * AAShip.gameSpeed;
        e.angle = -Math.sin(xa) * 0.2;
        e.pos.y += e.speed * AAShip.gameSpeed;
        if (e.pos.y < 0)
        {
            if (e.fireTicks <= 0)
            {
                e.fireTicks += FIRE_INTERVAL / e.fireIntervalRatio;
                e.fireSeqTicks = 0;
                e.fireCount = 4;
            }
            if (e.fireCount > 0)
            {
                e.fireSeqTicks -= AAShip.gameSpeed;
                if (e.fireSeqTicks <= 0)
                {
                    e.fireSeqTicks = 3;
                    e.fireCount--;
                    var pa:Number = Math.atan2(-e.pos.x + shipPos.x, e.pos.y - shipPos.y);
                    for (var i:int = 0; i < 3; i++)
                    {
                        main.fireBullet(e.pos, pa - (i - 1) * 0.5,
                                        BULLET_SPEED * e.fireSpeedRatio * (1.0 + (3 - e.fireCount) * 0.25), 1.25);
                    }
                }
            }
        }
        else
        {
            e.speed += (SPEED * 4 - e.speed) * 0.1;
        }
    }
}

class Bullet extends Actor
{
    public var vel:Vector2 = new Vector2;
    public var speed:Number;
    public var size:Number;
}

class Spark extends Actor
{
    public var vel:Vector2 = new Vector2;
    public var size:Number;
}

class Blur
{
    public var pos:Vector2 = new Vector2;
    public var width:Number, height:Number;
    public var r:int, g:int, b:int;
}

class Field
{
    public static const SIDE_BOARD_WIDTH:Number = AAShip.SCREEN_WIDTH / 6;
    private static const STAR_COUNT:int = 256;
    public static var size:Vector2;
    public static var offsetX:Number;
    private static var stars:Vector.<Star>;
    private static var rect:Rectangle = new Rectangle;

    public static function initialize():void
    {
        size = new Vector2;
        size.x = AAShip.SCREEN_WIDTH * 1.1 / 2; size.y = AAShip.SCREEN_HEIGHT * 1.1 / 2;
        stars = new Vector.<Star>(STAR_COUNT, true);
        for (var i:int = 0; i < STAR_COUNT; i++)
        {
            var s:Star = new Star;
            var z:Number = 1.0 + Math.random() * 10;
            var sz:int = (5 + Math.random() * 5) / z;
            if (sz < 1) sz = 1;
            s.pos.x = (Math.random() * 2 - 1) * size.x - sz;
            s.pos.y = (Math.random() * 2 - 1) * size.y - sz;
            s.size = sz;
            s.velRatio = 1.0 / z;
            s.color = (int)(Math.random() * 127 + 128) * 0x100 +
            (int)(Math.random() * 127 + 128);
            stars[i] = s;
        }
    }

    public static function draw(buffer:BitmapData):void
    {
        for each (var s:Star in stars)
        {
            rect.x = s.pos.x - offsetX * s.velRatio + AAShip.SCREEN_WIDTH / 2;
            rect.y = s.pos.y + AAShip.SCREEN_HEIGHT / 2;
            rect.width = rect.height = s.size;
            buffer.fillRect(rect, s.color);
            s.pos.y += 3.0 * s.velRatio;
            if (s.pos.y > size.y) s.pos.y -= size.y * 2;
        }
    }

    public static function drawSideBoard(buffer:BitmapData):void
    {
        rect.width = SIDE_BOARD_WIDTH;
        rect.height = AAShip.SCREEN_HEIGHT;
        rect.x = rect.y = 0;
        buffer.fillRect(rect, 0);
        rect.x = AAShip.SCREEN_WIDTH - rect.width;
        buffer.fillRect(rect, 0);
    }

    public static function contains(p:Vector2):Boolean
    {
        return (p.x >= -size.x && p.x <= size.x && p.y >= -size.y && p.y <= size.y);
    }
}

class Star
{
    public var pos:Vector2 = new Vector2;
    public var size:Number;
    public var color:int;
    public var velRatio:Number;
}

class AAChar
{
    private static const COLOR_PATTERNS:Array =
    [["R", 250, 100, 100], ["G", 100, 250, 100], ["B", 100, 100, 250],
     ["Y", 250, 250, 100], ["P", 250, 100, 250], ["C", 100, 250, 250],
     ["W", 250, 250, 250]];
    private const CHAR_SIZE:int = 24;
    private const CHAR_OFFSET_X:int = 14;
    private const CHAR_OFFSET_Y:int = 17;
    private const CHAR_HEIGHT:int = 24;
    private static var colorCount:int;
    private static var textFormats:Vector.<TextFormat> = new Vector.<TextFormat>;
    public var textFields:Vector.<TextField> = new Vector.<TextField>;
    public var blurs:Vector.<Blur> = new Vector.<Blur>;
    public var width:int, height:int;
    private var bitmapData:BitmapData;

    public static function initialize():void
    {
        colorCount = 0;
        for each (var cp:Array in COLOR_PATTERNS)
        {
            var tf:TextFormat = new TextFormat;
            tf.font = "_typewriter";
            tf.bold = true;
            tf.size = 24;
            tf.leading = -10;
            tf.color = (int)(cp[1] * 0.75) * 0x10000 + (int)(cp[2] * 0.75) * 0x100 + (int)(cp[3] * 0.75);
            textFormats.push(tf);
            colorCount++;
        }
    }

    public function AAChar(chars:Array, colors:Array, divX:int = 1, divY:int = 1)
    {
        var i:int;
        var tfts:Vector.<String> = new Vector.<String>(colorCount, true);
        var tffs:Vector.<Boolean> = new Vector.<Boolean>(colorCount, true);
        for (i = 0; i < colorCount; i++)
        {
            tfts[i] = "";
            tffs[i] = false;
        }
        var cx:int, cy:int = 0;
        var bd:BitmapData;
        var tf:TextField;
        var b:Blur;
        for (i = 0; i < chars.length; i++)
        {
            var str:String = chars[i];
            var colorStr:String = colors[i];
            cx = 0;
            var j:int;
            for (j = 0; j < str.length; j++)
            {
                var c:String = str.charAt(j);
                var color:String = colorStr.charAt(j);
                var ci:int;
                for (var k:int = 0; k < colorCount; k++)
                {
                    if (color == COLOR_PATTERNS[k][0])
                    {
                        tfts[k] += c;
                        tffs[k] = true;
                        ci = k;
                    }
                    else
                    {
                        tfts[k] += " ";
                    }
                }
                bd = new BitmapData(CHAR_SIZE, CHAR_SIZE, false, 0);
                tf = new TextField;
                tf.defaultTextFormat = textFormats[ci];
                tf.text = c;
                bd.draw(tf);
                for (var dx:int = 0; dx < divX; dx++)
                {
                    for (var dy:int = 0; dy < divY; dy++)
                    {
                        var minX:int = CHAR_SIZE, maxX:int = -1;
                        var minY:int = CHAR_SIZE, maxY:int = -1;
                        for (var x:int = dx * CHAR_SIZE / divX; x < (dx + 1) * CHAR_SIZE / divX; x++)
                        {
                            for (var y:int = dy * CHAR_SIZE / divY; y < (dy + 1) * CHAR_SIZE / divY; y++)
                            {
                                if (bd.getPixel(x, y) > 0)
                                {
                                    if (minX > x) minX = x;
                                    if (maxX < x) maxX = x;
                                    if (minY > y) minY = y;
                                    if (maxY < y) maxY = y;
                                }
                            }
                        }
                        if (maxX >= 0)
                        {
                            b = new Blur;
                            b.width = maxX - minX + 1;
                            b.height = maxY - minY + 1;
                            b.pos.x = minX + cx * CHAR_OFFSET_X + b.width / 2;
                            b.pos.y = minY + cy * CHAR_OFFSET_Y + b.height / 2;
                            b.r = COLOR_PATTERNS[ci][1] + (255 - COLOR_PATTERNS[ci][1]) * 0.5;
                            b.g = COLOR_PATTERNS[ci][2] + (255 - COLOR_PATTERNS[ci][2]) * 0.5;
                            b.b = COLOR_PATTERNS[ci][3] + (255 - COLOR_PATTERNS[ci][3]) * 0.5;
                            blurs.push(b);
                        }
                    }
                }
                cx++;
            }
            for (j = 0; j < colorCount; j++)
            {
                tfts[j] += "\n";
            }
            cy++;
        }
        width = cx * CHAR_OFFSET_X;
        height = cy * CHAR_HEIGHT;
        for (i = 0; i < colorCount; i++)
        {
            if (!tffs[i]) continue;
            tf = new TextField;
            tf.defaultTextFormat = textFormats[i];
            tf.multiline = true;
            tf.text = tfts[i];
            textFields.push(tf);
        }
        for each (b in blurs)
        {
            b.pos.x -= width / 2;
            b.pos.y -= height / 2;
        }
        bitmapData = new BitmapData(width, height, true, 0);
        for each (tf in textFields)
        {
            bitmapData.draw(tf);
        }
    }

    public function drawToSprite(s:Sprite):void
    {
        while (s.numChildren > 0)
        {
            s.removeChildAt(0);
        }
        s.addChild(new Bitmap(bitmapData));
    }

    public function setSpriteMatrix(s:Sprite, p:Vector2, angle:Number, sx:Number = 1, sy:Number = 1):void
    {
        var m:Matrix = new Matrix;
        m.translate(-width / 2, -height / 2);
        m.scale(sx, sy);
        m.rotate(angle);
        m.translate(p.x + AAShip.SCREEN_WIDTH / 2 - Field.offsetX, p.y + AAShip.SCREEN_HEIGHT / 2);
        s.transform.matrix = m;
    }
}


// Utility classes.

class Vector2
{
    public var x:Number = 0;
    public var y:Number = 0;

    public function add(v:Vector2):void
    {
        x += v.x;
        y += v.y;
    }

    public function addMultiplied(v:Vector2, mv:Number):void
    {
        x += v.x * mv;
        y += v.y * mv;
    }

    public function sub(v:Vector2):void
    {
        x -= v.x;
        y -= v.y;
    }

    public function mul(v:Number):void
    {
        x *= v;
        y *= v;
    }

    public function div(v:Number):void
    {
        x /= v;
        y /= v;
    }

    public function normalize():void
    {
        div(length);
    }

    public function get length():Number
    {
        return Math.sqrt(x * x + y * y);
    }

    public function getRoughDistance(p:Vector2):Number
    {
        return Math.abs(x - p.x) + Math.abs(y - p.y);
    }

    public function rotation(v:Number):void
    {
        var sv:Number = Math.sin(v);
        var cv:Number = Math.cos(v);
        var rx:Number = cv * x - sv * y;
        y = sv * x + cv * y;
        x = rx;
    }
}

class Key
{
    public static var left:Boolean, up:Boolean, right:Boolean, down:Boolean;
    public static var button1:Boolean;

    public static function onKeyUp(event:KeyboardEvent):void
    {
        switch (event.keyCode)
        {
            case 0x25:
            case 0x41:
            {
                left = false;
                break;
            }
            case 0x26:
            case 0x57:
            {
                up = false;
                break;
            }
            case 0x27:
            case 0x44:
            {
                right = false;
                break;
            }
            case 0x28:
            case 0x53:
            {
                down = false;
                break;
            }
            case 0x5a:
            case 0xbf:
            case 0x58:
            case 0xbe:
            {
                button1 = false;
                break;
            }
        }
    }

    public static function onKeyDown(event:KeyboardEvent):void
    {
        switch (event.keyCode)
        {
            case 0x25:
            case 0x41:
            {
                left = true;
                break;
            }
            case 0x26:
            case 0x57:
            {
                up = true;
                break;
            }
            case 0x27:
            case 0x44:
            {
                right = true;
                break;
            }
            case 0x28:
            case 0x53:
            {
                down = true;
                break;
            }
            case 0x5a:
            case 0xbf:
            case 0x58:
            case 0xbe:
            {
                button1 = true;
                break;
            }
        }
    }
}

class Util
{
    public static function normalizeAngle(v:Number):Number
    {
        if (v > Math.PI) return v - Math.PI * 2;
        else if (v < -Math.PI) return v + Math.PI * 2;
        else return v;
    }
}

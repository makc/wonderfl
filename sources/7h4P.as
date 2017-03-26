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
        private const SHIP_SPEED:Number = 7;
        private const SHOT_MAX_COUNT:int = 4;
        private const SHOT_SPEED:Number = 20;
        private const SHIP_COLLISION_SIZE:Number = 8;
        private const SHIP_INVINCIBLE_TICKS:int = 90;
        private const ENEMY_SPEED:Number = 6;
        private const ENEMY_ANGLE_VELOCITY:Number = 0.05;
        private const ENEMY_MAX_COUNT:int = 16;
        private const ENEMY_COLLISION_SIZE:Number = 36;
        private const ENEMY_FIRE_INTERVAL:Number = 60;
        private const ENEMY_APPEARANCE_INTERVAL:Number = 90;
        private const BULLET_SPEED:Number = 5;
        private const BULLET_MAX_COUNT:int = 128;
        private const SPARK_MAX_COUNT:int = 64;
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
        private var fireCount:int;
        private var shotChar:AAChar;
        private var shots:Vector.<Shot> = new Vector.<Shot>(SHOT_MAX_COUNT, true);
        private var enemyChar:AAChar;
        private var enemies:Vector.<Enemy> = new Vector.<Enemy>(ENEMY_MAX_COUNT, true);
        private var bulletChar:AAChar;
        private var bullets:Vector.<Bullet> = new Vector.<Bullet>(BULLET_MAX_COUNT, true);
        private var sparkChar:AAChar;
        private var sparks:Vector.<Spark> = new Vector.<Spark>(SPARK_MAX_COUNT, true);
        private var stageTicks:int;
        private var intervalRank:Number;
        private var speedRank:Number;
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
            shotChar = new AAChar(["!"], ["Y"], 1, 2);
            for (i = 0; i < SHOT_MAX_COUNT; i++)
            {
                shots[i] = new Shot;
                shotChar.drawToSprite(shots[i].sprite);
            }
            enemyChar = new AAChar(["<O>", " v "], ["WGW", " C "], 2, 2);
            for (i = 0; i < ENEMY_MAX_COUNT; i++)
            {
                enemies[i] = new Enemy;
                enemyChar.drawToSprite(enemies[i].sprite);
            }
            bulletChar = new AAChar(["&"], ["R"]);
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
            stageTicks = 0;
            intervalRank = speedRank = enemyIntervalRank = enemySpeedRank = 2;
            addEventListener(Event.ENTER_FRAME, onEnterFrame);
        }

        private function initializeShip():void
        {
            shipPos.x = 0;
            shipPos.y = Field.size.y / 2;
            shipAngle = 0.0;
            fireCount = 0;
            intervalRank *= 0.5; speedRank *= 0.5;
            enemyIntervalRank *= 0.5; enemySpeedRank *= 0.5;
            if (intervalRank < 0.5) intervalRank = 0.5;
            if (speedRank < 0.5) speedRank = 0.5;
            if (enemyIntervalRank < 0.5) enemyIntervalRank = 0.5;
            if (enemySpeedRank < 0.5) enemySpeedRank = 0.5;
            rankTicks = 0;
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
            else Field.offset.x *= 0.95;
            shipInvincibleTicks++;
            updateEnemies();
            updateBullets();
            stageTicks++;
            rankTicks++;
            intervalRank += 0.02;
            if (rankTicks % (10 * 30) == 0) intervalRank *= 0.5;
            speedRank += 0.005;
            if (rankTicks % (15 * 30) == 0) speedRank *= 0.5;
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
            if (Key.left) shipPos.x -= SHIP_SPEED;
            if (Key.right) shipPos.x += SHIP_SPEED;
            if (Key.up) shipPos.y -= SHIP_SPEED;
            if (Key.down) shipPos.y += SHIP_SPEED;
            if (shipPos.x < -SCREEN_WIDTH / 2) shipPos.x = -SCREEN_WIDTH / 2;
            if (shipPos.x > SCREEN_WIDTH / 2) shipPos.x = SCREEN_WIDTH / 2;
            if (shipPos.y < -SCREEN_HEIGHT / 2) shipPos.y = -SCREEN_HEIGHT / 2;
            if (shipPos.y > SCREEN_HEIGHT / 2) shipPos.y = SCREEN_HEIGHT / 2;
            shipAngle += (shipPos.x - px) * 0.005;
            shipAngle *= 0.8;
            Field.offset.x = shipPos.x * 0.33;
            Field.offset.y -= 3;
            shipChar.setSpriteMatrix(shipSprite, shipPos, shipAngle);
            if (shipInvincibleTicks >= 0 || (-shipInvincibleTicks % 15 > 7))
            {
                addBlursOfAAChar(shipChar, shipPos, shipAngle);
            }
            var s:Shot;
            if (Key.button1)
            {
                offset.x = 15;
                offset.y = 0;
                offset.rotation(shipAngle);
                s = getActorInstance(Vector.<Actor>(shots));
                var i:int = -fireCount % 2;
                if (s != null)
                {
                    s.pos.x = shipPos.x + offset.x * (i * 2 - 1);
                    s.pos.y = shipPos.y + offset.y * (i * 2 - 1);
                    s.angle = shipAngle;
                    shotChar.setSpriteMatrix(s.sprite, s.pos, s.angle);
                    addChild(s.sprite);
                }
            }
            fireCount--;
            if (shipInvincibleTicks >= 0)
            {
                for each (var e:Enemy in enemies)
                {
                    if (!e.exists) continue;
                    if (shipPos.getRoughDistance(e.pos) <= ENEMY_COLLISION_SIZE)
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
                s.pos.x += Math.sin(s.angle) * SHOT_SPEED;
                s.pos.y -= Math.cos(s.angle) * SHOT_SPEED;
                if (s.pos.y < -SCREEN_HEIGHT / 2)
                {
                    s.exists = false;
                    removeChild(s.sprite);
                    continue;
                }
                shotChar.setSpriteMatrix(s.sprite, s.pos, s.angle);
                addBlursOfAAChar(shotChar, s.pos, s.angle);
                for each (var e:Enemy in enemies)
                {
                    if (!e.exists) continue;
                    if (s.pos.getRoughDistance(e.pos) <= ENEMY_COLLISION_SIZE)
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
            var ei:int = ENEMY_APPEARANCE_INTERVAL / enemyIntervalRank;
            if (ei < 5) ei = 5;
            if (stageTicks % ei == 0)
            {
                e = getActorInstance(Vector.<Actor>(enemies));
                if (e != null)
                {
                    e.pos.x = Field.size.x * (Math.random() * 2 - 1);
                    e.pos.y = -Field.size.y;
                    e.angle = Math.PI;
                    e.speed = ENEMY_SPEED * enemySpeedRank;
                    e.ticks = 0;
                    e.shield = 1;
                    e.isHit = false;
                    addChild(e.sprite);
                }
            }
            for each (e in enemies)
            {
                if (!e.exists) continue;
                e.pos.x += Math.sin(e.angle) * e.speed;
                e.pos.y -= Math.cos(e.angle) * e.speed;
                if (!Field.contains(e.pos) || e.shield <= 0)
                {
                    e.exists = false;
                    removeChild(e.sprite);
                    if (e.shield <= 0) addSpark(e.pos, 0, Math.PI, 4.0, 1.5, 8);
                    continue;
                }
                var pa:Number = Math.atan2(-e.pos.x + shipPos.x, e.pos.y - shipPos.y);
                var ao:Number = pa - e.angle;
                ao = normalizeAngle(ao);
                if (ao > ENEMY_ANGLE_VELOCITY) e.angle += ENEMY_ANGLE_VELOCITY;
                else if (ao < -ENEMY_ANGLE_VELOCITY) e.angle -= ENEMY_ANGLE_VELOCITY;
                else e.angle = pa;
                e.angle = normalizeAngle(e.angle);
                e.ticks++;
                var fitv:int = (int)(ENEMY_FIRE_INTERVAL / intervalRank);
                if (fitv < 2) fitv = 2;
                if (e.ticks % fitv == 0 && e.pos.getRoughDistance(shipPos) > 200 &&
                    e.pos.x - Field.offset.x > -Field.size.x + Field.SIDE_BOARD_WIDTH &&
                    e.pos.x - Field.offset.x < Field.size.x - Field.SIDE_BOARD_WIDTH)
                {
                    var b:Bullet = getActorInstance(Vector.<Actor>(bullets));
                    if (b != null)
                    {
                        b.pos.x = e.pos.x; b.pos.y = e.pos.y;
                        var bs:Number = BULLET_SPEED * speedRank;
                        if (bs < BULLET_SPEED) bs = BULLET_SPEED;
                        b.vel.x = Math.sin(e.angle) * bs;
                        b.vel.y = -Math.cos(e.angle) * bs;
                        b.ticks = 0;
                        addChild(b.sprite);
                    }
                }
                enemyChar.setSpriteMatrix(e.sprite, e.pos, e.angle);
                if (e.isHit)
                {
                    e.isHit = false;
                    addBlursOfAAChar(enemyChar, e.pos, e.angle, 1.5, 1.5, 255, 255, 0);
                }
                else
                {
                    addBlursOfAAChar(enemyChar, e.pos, e.angle);
                }
            }
        }

        private function updateBullets():void
        {
            for each (var b:Bullet in bullets)
            {
                if (!b.exists) continue;
                b.pos.add(b.vel);
                if (!Field.contains(b.pos))
                {
                    b.exists = false;
                    removeChild(b.sprite);
                    continue;
                }
                var a:Number = b.ticks * 0.1;
                bulletChar.setSpriteMatrix(b.sprite, b.pos, a);
                addBlursOfAAChar(bulletChar, b.pos, a);
                b.ticks++;
            }
        }

        private function updateSparks():void
        {
            for each (var sp:Spark in sparks)
            {
                if (!sp.exists) continue;
                sp.pos.add(sp.vel);
                sp.vel.mul(0.95);
                sp.size *= 0.95;
                if (!Field.contains(sp.pos) || sp.ticks <= 0)
                {
                    sp.exists = false;
                    removeChild(sp.sprite);
                    continue;
                }
                var a:Number = sp.ticks * 0.2;
                sparkChar.setSpriteMatrix(sp.sprite, sp.pos, a, sp.size, sp.size);
                addBlursOfAAChar(sparkChar, sp.pos, a, sp.size, sp.size);
                sp.ticks--;
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
            var x:int = p.x + SCREEN_WIDTH / 2;
            var y:int = p.y + SCREEN_HEIGHT / 2;
            for each (var b:Blur in ac.blurs)
            {
                offset.x = b.pos.x * sx; offset.y = b.pos.y * sy;
                offset.rotation(angle);
                var bl:Blur = blurs[blurIndex][blurCounts[blurIndex]];
                bl.pos.x = x + offset.x;
                bl.pos.y = y + offset.y;
                bl.width = b.width * sx;
                bl.height = b.height * sy;
                if (cr >= 0)
                {
                    bl.r = cr; bl.g = cg; bl.b = cb;
                }
                else
                {
                    bl.r = b.r; bl.g = b.g; bl.b = b.b;
                }
                blurCounts[blurIndex]++;
            }
        }

        private function updateBlur(b:Blur):void
        {
            rect.x = b.pos.x - b.width / 2 - Field.offset.x;
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

        private function normalizeAngle(v:Number):Number
        {
            if (v > Math.PI) return v - Math.PI * 2;
            else if (v < -Math.PI) return v + Math.PI * 2;
            else return v;
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
}

class Shot extends Actor
{
    public var pos:Vector2 = new Vector2;
    public var angle:Number;
    public var sprite:Sprite = new Sprite;
}

class Enemy extends Actor
{
    public var pos:Vector2 = new Vector2;
    public var angle:Number;
    public var speed:Number;
    public var sprite:Sprite = new Sprite;
    public var ticks:int;
    public var shield:int;
    public var isHit:Boolean;
}

class Bullet extends Actor
{
    public var pos:Vector2 = new Vector2;
    public var vel:Vector2 = new Vector2;
    public var sprite:Sprite = new Sprite;
    public var ticks:int;
}

class Spark extends Actor
{
    public var pos:Vector2 = new Vector2;
    public var vel:Vector2 = new Vector2;
    public var sprite:Sprite = new Sprite;
    public var ticks:int;
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
    private static const GRID_SPACING:int = 32;
    public static var size:Vector2;
    public static var offset:Vector2;
    private static var rect:Rectangle = new Rectangle;

    public static function initialize():void
    {
        size = new Vector2;
        size.x = AAShip.SCREEN_WIDTH * 1.1 / 2; size.y = AAShip.SCREEN_HEIGHT * 1.1 / 2;
        offset = new Vector2;
    }

    public static function draw(buffer:BitmapData):void
    {
        var v:int;
        rect.width = 1; rect.height = AAShip.SCREEN_HEIGHT;
        for (v = -offset.x % GRID_SPACING; v < AAShip.SCREEN_WIDTH; v += GRID_SPACING)
        {
            rect.x = v; rect.y = 0;
            buffer.fillRect(rect, 0x225522);
        }
        rect.width = AAShip.SCREEN_WIDTH; rect.height = 1;
        for (v = -offset.y % GRID_SPACING; v < AAShip.SCREEN_HEIGHT; v += GRID_SPACING)
        {
            rect.x = 0; rect.y = v;
            buffer.fillRect(rect, 0x225522);
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
    }

    public function drawToSprite(s:Sprite):void
    {
        var bd:BitmapData = new BitmapData(width, height, true, 0);
        for each (var tf:TextField in textFields)
        {
            bd.draw(tf);
        }
        s.addChild(new Bitmap(bd));
    }

    public function setSpriteMatrix(s:Sprite, p:Vector2, angle:Number, sx:Number = 1, sy:Number = 1):void
    {
        var m:Matrix = new Matrix;
        m.translate(-width / 2, -height / 2);
        m.scale(sx, sy);
        m.rotate(angle);
        m.translate(p.x + AAShip.SCREEN_WIDTH / 2 - Field.offset.x, p.y + AAShip.SCREEN_HEIGHT / 2);
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

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
        private const BLUR_MAX_COUNT:int = 256;
        private const BLUR_HISTORY_COUNT:int = 6;
        private const SHIP_SPEED:Number = 7;
        private const SHOT_MAX_COUNT:int = 32;
        private const SHOT_SPEED:int = 18;
        private var buffer:BitmapData = new BitmapData(SCREEN_WIDTH, SCREEN_HEIGHT, false, 0);
        private var rect:Rectangle = new Rectangle;
        private var blurs:Vector.<Vector.<Blur>> = new Vector.<Vector.<Blur>>(BLUR_HISTORY_COUNT, true);
        private var blurCounts:Vector.<int> = new Vector.<int>(BLUR_HISTORY_COUNT, true);
        private var blurIndex:int;
        private var shipChar:AAChar;
        private var shipSprite:Sprite = new Sprite;
        private var shipPos:Vector2 = new Vector2;
        private var shipAngle:Number;
        private var fireCount:int;
        private var shotChar:AAChar;
        private var shots:Vector.<Shot> = new Vector.<Shot>(SHOT_MAX_COUNT, true);
        private var offset:Vector2 = new Vector2;

        public function AAShip()
        {
            stage.scaleMode = "noScale";
            addChild(new Bitmap(buffer));
            stage.addEventListener(KeyboardEvent.KEY_DOWN, Key.onKeyDown);
            stage.addEventListener(KeyboardEvent.KEY_UP, Key.onKeyUp);
            AAChar.initialize();
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
            shipChar = new AAChar([" A ", "I#I"], [" R ", "CBC"]);
            shipChar.drawToSprite(shipSprite);
            addChild(shipSprite);
            shipPos.x = 0;
            shipPos.y = SCREEN_HEIGHT / 4;
            shipAngle = 0.0;
            fireCount = 0;
            shotChar = new AAChar(["!"], ["Y"]);
            for (i = 0; i < SHOT_MAX_COUNT; i++)
            {
                shots[i] = new Shot;
                shotChar.drawToSprite(shots[i].sprite);
            }
            addEventListener(Event.ENTER_FRAME, onEnterFrame);
        }

        private function onEnterFrame(event:Event):void
        {
            buffer.fillRect(buffer.rect, 0);
            var i:int;
            blurCounts[blurIndex] = 0;
            var px:Number = shipPos.x;
            if (Key.left) shipPos.x -= SHIP_SPEED;
            if (Key.right) shipPos.x += SHIP_SPEED;
            if (Key.up) shipPos.y -= SHIP_SPEED;
            if (Key.down) shipPos.y += SHIP_SPEED;
            if (shipPos.x < -SCREEN_WIDTH / 2) shipPos.x = -SCREEN_WIDTH / 2;
            if (shipPos.x > SCREEN_WIDTH / 2) shipPos.x = SCREEN_WIDTH / 2;
            if (shipPos.y < -SCREEN_HEIGHT / 2) shipPos.y = -SCREEN_HEIGHT / 2;
            if (shipPos.y > SCREEN_HEIGHT / 2) shipPos.y = SCREEN_HEIGHT / 2;
            shipAngle += (shipPos.x - px) * 0.02;
            shipAngle *= 0.8;
            shipChar.setSpriteMatrix(shipSprite, shipPos, shipAngle);
            addBlursOfAAChar(shipChar, shipPos, shipAngle);
            var s:Shot;
            if (fireCount <= 0 && Key.button1)
            {
                fireCount = 2;
                offset.x = 15;
                offset.y = 0;
                offset.rotation(shipAngle);
                for (i = 0; i < 2; i++)
                {
                    s = getActorInstance(Vector.<Actor>(shots));
                    s.pos.x = shipPos.x + offset.x * (i * 2 - 1);
                    s.pos.y = shipPos.y + offset.y * (i * 2 - 1);
                    s.angle = shipAngle;
                    addChild(s.sprite);
                }
            }
            fireCount--;
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
            }
            buffer.lock();
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
            buffer.unlock();
            blurIndex++;
            if (blurIndex >= BLUR_HISTORY_COUNT) blurIndex = 0;
        }

        private function addBlursOfAAChar(ac:AAChar, p:Vector2, angle:Number):void
        {
            var x:int = p.x + SCREEN_WIDTH / 2;
            var y:int = p.y + SCREEN_HEIGHT / 2;
            for each (var b:Blur in ac.blurs)
            {
                offset.x = b.pos.x; offset.y = b.pos.y;
                offset.rotation(angle);
                var bl:Blur = blurs[blurIndex][blurCounts[blurIndex]];
                bl.pos.x = x + offset.x;
                bl.pos.y = y + offset.y;
                bl.width = b.width;
                bl.height = b.height;
                bl.r = b.r; bl.g = b.g; bl.b = b.b;
                blurCounts[blurIndex]++;
            }
        }

        private function updateBlur(b:Blur):void
        {
            rect.x = b.pos.x - b.width / 2;
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

class Blur
{
    public var pos:Vector2 = new Vector2;
    public var width:Number, height:Number;
    public var r:int, g:int, b:int;
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

    public function AAChar(chars:Array, colors:Array)
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
                var minX:int = CHAR_SIZE, maxX:int = -1;
                var minY:int = CHAR_SIZE, maxY:int = -1;
                for (var x:int = 0; x < CHAR_SIZE; x++)
                {
                    for (var y:int = 0; y < CHAR_SIZE; y++)
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

    public function setSpriteMatrix(s:Sprite, p:Vector2, angle:Number):void
    {
        var m:Matrix = new Matrix;
        m.translate(-width / 2, -height / 2);
        m.rotate(angle);
        m.translate(p.x + AAShip.SCREEN_WIDTH / 2, p.y + AAShip.SCREEN_HEIGHT / 2);
        s.transform.matrix = m;
    }
}


// Utility classes.

class Vector2
{
    public var x:Number;
    public var y:Number;

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


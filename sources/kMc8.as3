// ReflectLaser.as
//  Laser and mirrors.
//  [Control]
//   Movement: [WASD] keys.
//   Laser:    Hold [IJKL] or arrow keys.
package
{
    import flash.display.Sprite;
    import flash.display.BitmapData;
    import flash.display.Bitmap;
    import flash.geom.Rectangle;
    import flash.events.Event;
    import flash.events.KeyboardEvent;

    [SWF(width="465", height="465", backgroundColor="0x000000", frameRate="30")]
    public class ReflectLaser extends Sprite
    {
        public static const SCREEN_WIDTH:int = 465;
        public static const SCREEN_HEIGHT:int = 465;
        private const LASER_MAX_COUNT:int = 4;
        private const MIRROR_MAX_COUNT:int = 4;
        private const BLUR_MAX_COUNT:int = 512;
        private const BLUR_HISTORY_COUNT:int = 6;
        private var player:Player = new Player;
        private var lasers:Vector.<Laser> = new Vector.<Laser>(LASER_MAX_COUNT, true);
        private var mirrors:Vector.<Mirror> = new Vector.<Mirror>(MIRROR_MAX_COUNT, true);
        private var blurs:Vector.<Vector.<Blur>> = new Vector.<Vector.<Blur>>(BLUR_HISTORY_COUNT, true);
        private var blurCounts:Vector.<int> = new Vector.<int>(BLUR_HISTORY_COUNT, true);
        private var blurIndex:int;
        private var buffer:BitmapData = new BitmapData(SCREEN_WIDTH, SCREEN_HEIGHT, false, 0);
        private var rect:Rectangle = new Rectangle;
        private var pos:Vector2 = new Vector2;
        private var offset:Vector2 = new Vector2;
        private var ticks:int;

        public function ReflectLaser()
        {
            var i:int;
            Field.initialize();
            for (i = 0; i < LASER_MAX_COUNT; i++) lasers[i] = new Laser;
            for (i = 0; i < MIRROR_MAX_COUNT; i++) mirrors[i] = new Mirror;
            initializeBlurs();
            ticks = 120;
            stage.scaleMode = "noScale";
            addChild(new Bitmap(buffer));
            stage.addEventListener(KeyboardEvent.KEY_DOWN, Key.onKeyDown);
            stage.addEventListener(KeyboardEvent.KEY_UP, Key.onKeyUp);
            addEventListener(Event.ENTER_FRAME, onEnterFrame);
        }

        private function onEnterFrame(event:Event):void
        {
            buffer.fillRect(buffer.rect, 0);
            buffer.lock();
            updateBlurs();
            drawMirrors();
            player.update(this);
            for each (var l:Laser in lasers) l.update(this);
            buffer.unlock();
            ticks++;
            if (ticks % 150 == 0) setMirrors();
        }

        private function drawMirrors():void
        {
            for each (var m:Mirror in mirrors)
            {
                if (!m.exists) continue;
                offset.x = m.pos2.x - m.pos1.x;
                offset.y = m.pos2.y - m.pos1.y;
                var c:int = offset.length / 10;
                offset.div(c);
                pos.x = m.pos1.x; pos.y = m.pos1.y;
                for (var i:int = 0; i <= c; i++)
                {
                    drawBox(pos.x, pos.y, 7, 0x22ee22, 9, 100, 200, 100);
                    pos.add(offset);
                }
            }
        }

        public function drawBox(x:Number, y:Number, size:int, color:int,
                                 bsize:int, br:int, bg:int, bb:int):void
        {
            rect.x = x - size / 2 + SCREEN_WIDTH / 2;
            rect.y = y - size / 2 + SCREEN_HEIGHT / 2;
            rect.width = rect.height = size;
            buffer.fillRect(rect, color);
            addBlur(x, y, bsize, bsize, br, bg, bb);
        }

        public function checkHitMirrors(p:Vector2):Mirror
        {
            for each (var m:Mirror in mirrors)
            {
                if (!m.exists) continue;
                if (p.checkHit(m.pos1, m.pos2, 30.0)) return m;
            }
            return null;
        }

        private function setMirrors():void
        {
            for (var i:int = 0; i < MIRROR_MAX_COUNT; i++)
            {
                var x:Number = (Math.random() * 2 - 1) * Field.size.x * 0.8;
                var y:Number = (Math.random() * 2 - 1) * Field.size.y * 0.8;
                var l:Number = 40 + Math.random() * 20;
                var m:Mirror = mirrors[i];
                m.exists = true;
                m.angle = Math.random() * Math.PI;
                var sv:Number = Math.sin(m.angle), cv:Number = Math.cos(m.angle);
                m.pos1.x = x - sv * l; m.pos1.y = y - cv * l;
                m.pos2.x = x + sv * l; m.pos2.y = y + cv * l;
            }
        }

        private function updateBlurs():void
        {
            var bi:int = blurIndex + 1;
            for (var i:int = 0; i < BLUR_HISTORY_COUNT; i++)
            {
                if (bi >= BLUR_HISTORY_COUNT) bi = 0;
                for (var j:int = 0; j < blurCounts[bi]; j++)
                {
                    updateBlur(blurs[bi][j]);
                }
                bi++;
            }
            blurIndex++;
            if (blurIndex >= BLUR_HISTORY_COUNT) blurIndex = 0;
            blurCounts[blurIndex] = 0;
        }

        private function addBlur(x:Number, y:Number, w:Number, h:Number,
                                 r:int, g:int, b:int):void
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
            rect.x = b.pos.x - b.width / 2;
            rect.y = b.pos.y - b.height / 2;
            rect.width = b.width;
            rect.height = b.height;
            buffer.fillRect(rect, b.r * 0x10000 + b.g * 0x100 + b.b);
            b.width *= 1.2; b.height *= 1.2;
            var a:int = (b.r + b.g + b.b) / 3;
            b.r += (a - b.r) * 0.2;
            b.g += (a - b.g) * 0.2;
            b.b += (a - b.b) * 0.2;
            b.r *= 0.7; b.g *= 0.7; b.b *= 0.7;
        }

        private function initializeBlurs():void
        {
            for (var i:int = 0; i < BLUR_HISTORY_COUNT; i++)
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
        }

        public function getLaserInstance():Laser
        {
            return getActorInstance(Vector.<Actor>(lasers));
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

import flash.events.KeyboardEvent;

interface IPosition
{
    function get position():Vector2;
}

class Player implements IPosition
{
    private const SCREEN_WIDTH:int = ReflectLaser.SCREEN_WIDTH;
    private const SCREEN_HEIGHT:int = ReflectLaser.SCREEN_HEIGHT;
    private const SPEED:Number = 7.0;
    private const LASER_SPEED:Number = 12.0;
    public var pos:Vector2 = new Vector2;
    public var isFirePressed:Boolean;
    public var laser:Laser = null;
    private var offset:Vector2 = new Vector2;
    private var ticks:int = 0;

    public function update(main:ReflectLaser):void
    {
        var vx:Number = 0, vy:Number = 0;
        if (Key.left)  vx = -1;
        if (Key.right) vx = 1;
        if (Key.up)    vy = -1;
        if (Key.down)  vy = 1;
        if (vx != 0 && vy != 0)
        {
            vx *= 0.7; vy *= 0.7;
        }
        pos.x += vx * SPEED; pos.y += vy * SPEED;
        if (pos.x < -SCREEN_WIDTH  / 2) pos.x = -SCREEN_WIDTH / 2;
        if (pos.x >  SCREEN_WIDTH  / 2) pos.x =  SCREEN_WIDTH / 2;
        if (pos.y < -SCREEN_HEIGHT / 2) pos.y = -SCREEN_HEIGHT / 2;
        if (pos.y >  SCREEN_HEIGHT / 2) pos.y =  SCREEN_HEIGHT / 2;
        var fx:Number = 0, fy:Number = 0;
        if (Key.left2)  fx = -1;
        if (Key.right2) fx = 1;
        if (Key.up2)    fy = -1;
        if (Key.down2)  fy = 1;
        if (fx != 0 || fy != 0)
        {
            var fa:Number = Math.atan2(fx, fy);
            if (isFirePressed && laser != null)
            {
                laser.angle += Util.normalizeAngle(fa - laser.angle) * 0.1;
                laser.angle = Util.normalizeAngle(laser.angle);
            }
            else
            {
                isFirePressed = true;
                laser = main.getLaserInstance();
                if (laser != null) laser.initialize(this, fa, LASER_SPEED);
            }
        }
        else
        {
            if (isFirePressed)
            {
                isFirePressed = false;
                if (laser != null)
                {
                    laser.source = null;
                    laser = null;
                }
            }
        }
        offset.x = 0; offset.y = 7.0 + Math.sin(ticks * 0.25) * 2.0;
        offset.rotation(ticks * 0.15);
        for (var i:int = 0; i < 3; i++)
        {
            main.drawBox(pos.x + offset.x, pos.y + offset.y, 11, 0xee6666, 15, 255, 200, 200);
            offset.rotation(Math.PI * 2 / 3);
        }
        ticks++;
    }

    public function get position():Vector2
    {
        return pos;
    }
}

class Actor
{
    public var exists:Boolean = false;
}

class Laser extends Actor
{
    private const SPEED:Number = 5.0;
    private const SPACING:Number = 10.0;
    public var source:IPosition;
    public var sourcePos:Vector2 = new Vector2;
    public var angle:Number;
    public var speed:Number;
    public var startDist:Number, endDist:Number;
    public var ticks:int;
    private var pos:Vector2 = new Vector2;
    private var offset:Vector2 = new Vector2;

    public function initialize(s:IPosition, a:Number, sp:Number):void
    {
        exists = true;
        source = s;
        angle = a;
        speed = sp;
        startDist = endDist = 0;
        ticks = 0;
    }

    public function update(main:ReflectLaser):void
    {
        if (!exists) return;
        if (source != null)
        {
            sourcePos.x = source.position.x; sourcePos.y = source.position.y;
        }
        else
        {
            endDist += speed;
        }
        startDist += speed;
        pos.x = sourcePos.x; pos.y = sourcePos.y;
        var a:Number = angle;
        offset.x = Math.sin(a); offset.y = Math.cos(a);
        offset.mul(SPACING);
        var d:Number = 0;
        var df:Boolean = false;
        var i:Number = -startDist * 0.05;
        for (;;)
        {
            var m:Mirror = main.checkHitMirrors(pos);
            if (m != null)
            {
                a -= Util.normalizeAngle(a - m.angle) * 2;
                a = Util.normalizeAngle(a);
                offset.x = Math.sin(a); offset.y = Math.cos(a);
                offset.mul(SPACING);
            }
            if (d > endDist)
            {
                main.drawBox(pos.x, pos.y, 5, 0x8888ee, 20,
                             50, 50, 180 + Math.sin(i) * 70);
                i += 0.3;
                df = true;
            }
            if (d >= startDist || !Field.contains(pos)) break;
            pos.add(offset);
            d += SPACING;
        }
        if (!df) exists = false;
    }
}

class Mirror extends Actor
{
    public var pos1:Vector2 = new Vector2;
    public var pos2:Vector2 = new Vector2;
    public var angle:Number;
}

class Field
{
    public static var size:Vector2;

    public static function initialize():void
    {
        size = new Vector2;
        size.x = ReflectLaser.SCREEN_WIDTH * 1.1 / 2; size.y = ReflectLaser.SCREEN_HEIGHT * 1.1 / 2;
    }

    public static function contains(p:Vector2):Boolean
    {
        return (p.x >= -size.x && p.x <= size.x && p.y >= -size.y && p.y <= size.y);
    }
}

class Blur
{
    public var pos:Vector2 = new Vector2;
    public var width:Number, height:Number;
    public var r:int, g:int, b:int;
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

    public function addMultiplied(v:Vector2, m:Number):void
    {
        x += v.x * m;
        y += v.y * m;
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

    public function getRoughDistance(p:Vector2):Number
    {
        var ox:Number = Math.abs(p.x - x);
        var oy:Number = Math.abs(p.y - y);
        if (ox > oy) return ox + oy / 2;
        else         return oy + ox / 2;
    }

    public function rotation(v:Number):void
    {
        var sv:Number = Math.sin(v);
        var cv:Number = Math.cos(v);
        var rx:Number = cv * x - sv * y;
        y = sv * x + cv * y;
        x = rx;
    }

    public function checkHit(p:Vector2, pp:Vector2, dist:Number):Boolean
    {
      var bmvx:Number, bmvy:Number;
      bmvx = pp.x; bmvy = pp.y;
      bmvx -= p.x; bmvy -= p.y;
      var inaa:Number = bmvx * bmvx + bmvy * bmvy;
      if (inaa > 0.00001)
      {
        var sofsx:Number, sofsy:Number,inab:Number, hd:Number;
        sofsx = x - p.x; sofsy = y - p.y;
        inab = bmvx * sofsx + bmvy * sofsy;
        if (inab >= 0 && inab <= inaa)
        {
          hd = sofsx * sofsx + sofsy * sofsy - inab * inab / inaa;
          if (hd >= 0 && hd <= dist) return true;
        }
      }
      return false;
    }

    public function get length():Number
    {
        return Math.sqrt(x * x + y * y);
    }
}

class Key
{
    public static var left:Boolean, up:Boolean, right:Boolean, down:Boolean;
    public static var left2:Boolean, up2:Boolean, right2:Boolean, down2:Boolean;

    public static function onKeyDown(event:KeyboardEvent):void
    {
        switch (event.keyCode)
        {
            case 0x41:
            {
                left = true;
                break;
            }
            case 0x57:
            {
                up = true;
                break;
            }
            case 0x44:
            {
                right = true;
                break;
            }
            case 0x53:
            {
                down = true;
                break;
            }
            case 0x25:
            case 0x4a:
            {
                left2 = true;
                break;
            }
            case 0x26:
            case 0x49:
            {
                up2 = true;
                break;
            }
            case 0x27:
            case 0x4c:
            {
                right2 = true;
                break;
            }
            case 0x28:
            case 0x4b:
            {
                down2 = true;
                break;
            }
        }
    }

    public static function onKeyUp(event:KeyboardEvent):void
    {
        switch (event.keyCode)
        {
            case 0x41:
            {
                left = false;
                break;
            }
            case 0x57:
            {
                up = false;
                break;
            }
            case 0x44:
            {
                right = false;
                break;
            }
            case 0x53:
            {
                down = false;
                break;
            }
            case 0x25:
            case 0x4a:
            {
                left2 = false;
                break;
            }
            case 0x26:
            case 0x49:
            {
                up2 = false;
                break;
            }
            case 0x27:
            case 0x4c:
            {
                right2 = false;
                break;
            }
            case 0x28:
            case 0x4b:
            {
                down2 = false;
                break;
            }
        }
    }
}

class Util
{
    public static function normalizeAngle(v:Number):Number
    {
        if (v > Math.PI)       return v - Math.PI * 2;
        else if (v < -Math.PI) return v + Math.PI * 2;
        else                   return v;
    }
}

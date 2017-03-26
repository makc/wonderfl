// Boid.as
//  Flying birds using the Boid algorithm.
package
{
  import flash.display.Sprite;
  import flash.display.BitmapData;
  import flash.display.Bitmap;
  import flash.geom.Rectangle;
  import flash.events.Event;

  [SWF(width="465", height="465", backgroundColor="0x000000", frameRate="30")]
  public class Boid extends Sprite
  {
    private const SCREEN_WIDTH:int = 465;
    private const SCREEN_HEIGHT:int = 465;
    private const FIELD_SIZE_RATIO:Number = 1.25;
    private const BIRDS_COUNT:int = 64;
    private const SEPARATION_SPEED:Number = 0.1;
    private const SEPARATION_RADIUS:Number = 30;
    private const ALIGNMENT_RATIO:Number = 0.025;
    private const COHESION_RADIUS:Number = 90;
    private const COHESION_RATIO:Number = 0.0005;
    private const FORWARD_VELOCITY:Number = 0.3;
    private const SLOWDOWN_RATIO:Number = 0.9;
    private const CLOUDS_COUNT:int = 32;
    private var buffer:BitmapData= new BitmapData(SCREEN_WIDTH, SCREEN_HEIGHT, false, 0);
    private var birds:Array = new Array;
    private var clouds:Array = new Array;
    private var rect:Rectangle = new Rectangle;
    private var offset:Vector2 = new Vector2;
    private var centerOffset:Vector2 = new Vector2;
    private var fieldOffset:Vector2 = new Vector2;
    private var fieldSize:Vector2 = new Vector2;
    private var screenPos:Vector2 = new Vector2;

    public function Boid()
    {
      addChild(new Bitmap(buffer));
      fieldSize.x = SCREEN_WIDTH * FIELD_SIZE_RATIO;
      fieldSize.y = SCREEN_HEIGHT * FIELD_SIZE_RATIO;
      var i:int;
      for (i = 0; i < BIRDS_COUNT; i++)
      {
        var b:Bird = new Bird;
        b.pos.x = Math.random() * fieldSize.x;
        b.pos.y = Math.random() * fieldSize.y;
        b.vel.x = b.vel.y = 0;
        b.deg = Math.random() * Math.PI * 2;
        birds.push(b);
      }
      for (i = 0; i < CLOUDS_COUNT; i++)
      {
        var c:Cloud = new Cloud;
        c.pos.x = Math.random() * fieldSize.x;
        c.pos.y = Math.random() * fieldSize.y;
        var a:int = 0x4a + Math.random() * 0x12;
        c.color = a * 0x10000 + a * 0x100 + (a + 0x22);
        c.size = 24 + Math.random() * 36;
        clouds.push(c);
      }
      fieldOffset.x = fieldOffset.y = 0;
      addEventListener(Event.ENTER_FRAME, onEnterFrame);
    }

    private function onEnterFrame(e:Event):void
    {
      buffer.fillRect(buffer.rect, 0x444466);
      setFieldOffset(birds[0].pos);
      for each (var c:Cloud in clouds)
        drawCloud(c);
      for each (var b:Bird in birds)
        updateBirdByBoid(b);
    }

    private function drawCloud(c:Cloud):void
    {
      screenPos.x = c.pos.x - fieldOffset.x;
      screenPos.y = c.pos.y - fieldOffset.y;
      normalizePosInField(screenPos);
      rect.x = screenPos.x - c.size + SCREEN_WIDTH / 2;
      rect.y = screenPos.y - c.size + SCREEN_HEIGHT / 2;
      rect.width = rect.height = c.size * 2;
      buffer.fillRect(rect, c.color);
    }

    private function updateBirdByBoid(b:Bird):void
    {
      var nb:Bird = getNearestBird(b);
      if (nb != null)
      {
        offset.x = nb.pos.x - b.pos.x;
        offset.y = nb.pos.y - b.pos.y;
        normalizePosInField(offset);
        var dist:Number = offset.length;
        offset.normalize();
        if (dist > SEPARATION_RADIUS)
          offset.mul(dist / SEPARATION_RADIUS * SEPARATION_SPEED * 0.33);
        else
          offset.mul(-dist/ SEPARATION_RADIUS * SEPARATION_SPEED);
        b.vel.add(offset);
        b.vel.x += (nb.vel.x - b.vel.x) * ALIGNMENT_RATIO;
        b.vel.y += (nb.vel.y - b.vel.y) * ALIGNMENT_RATIO;
      }
      var op:Vector2 = getCenterOffsetInBirds(b, COHESION_RADIUS);
      offset.x = op.x;
      offset.y = op.y;
      offset.mul(COHESION_RATIO);
      b.vel.x += offset.x;
      b.vel.y += offset.y;
      b.deg += normalizeDeg(Math.atan2(b.vel.x, b.vel.y) - b.deg) * 0.1;
      b.deg = normalizeDeg(b.deg);
      b.vel.x += Math.sin(b.deg) * FORWARD_VELOCITY;
      b.vel.y += Math.cos(b.deg) * FORWARD_VELOCITY;
      b.vel.mul(SLOWDOWN_RATIO);
      b.pos.add(b.vel);
      normalizePosInField(b.pos);
      drawBird(b);
    }

    private function drawBird(b:Bird):void
    {
      screenPos.x = b.pos.x - fieldOffset.x;
      screenPos.y = b.pos.y - fieldOffset.y;
      normalizePosInField(screenPos);
      rect.x = screenPos.x - 3 + SCREEN_WIDTH / 2;
      rect.y = screenPos.y - 3 + SCREEN_HEIGHT / 2;
      rect.width = rect.height = 7;
      buffer.fillRect(rect, 0xaaaaaa);
      rect.width = rect.height = 5;
      rect.x = screenPos.x - 2 + SCREEN_WIDTH / 2 + Math.sin(b.deg + Math.PI / 2) * 6;
      rect.y = screenPos.y - 2 + SCREEN_HEIGHT / 2 + Math.cos(b.deg + Math.PI / 2) * 6;
      var c:int;
      c = (Math.sin(b.deg + Math.PI * 1.8) * 0.6 + 1.4) / 2 * 0xdd;
      buffer.fillRect(rect, c * 0x10000 + c * 0x100 + c);
      rect.x = screenPos.x - 2 + SCREEN_WIDTH / 2 + Math.sin(b.deg - Math.PI / 2) * 6;
      rect.y = screenPos.y - 2 + SCREEN_HEIGHT / 2 + Math.cos(b.deg - Math.PI / 2) * 6;
      c = (Math.sin(b.deg + Math.PI * 2.8) * 0.6 + 1.4) / 2 * 0xdd;
      buffer.fillRect(rect, c * 0x10000 + c * 0x100 + c);
    }

    private function getNearestBird(tb:Bird):Bird
    {
      var nd:Number = 99999, d:Number;
      var nb:Bird = null;
      for each (var b:Bird in birds)
      {
        if (b == tb)
          continue;
        offset.x = b.pos.x - tb.pos.x;
        offset.y = b.pos.y - tb.pos.y;
        normalizePosInField(offset);
        d = offset.length;
        if (d < nd) {
          nd = d;
          nb = b;
        }
      }
      return nb;
    }

    private function getCenterOffsetInBirds(tb:Bird, r:Number):Vector2
    {
      centerOffset.x = centerOffset.y = 0;
      var bc:int = 0;
      for each (var b:Bird in birds)
      {
        offset.x = b.pos.x - tb.pos.x;
        offset.y = b.pos.y - tb.pos.y;
        normalizePosInField(offset);
        if (offset.length < r)
        {
          centerOffset.add(offset);
          bc++;
        }
      }
      centerOffset.div(bc);
      return centerOffset;
    }

    private function setFieldOffset(p:Vector2):void
    {
      fieldOffset.x = p.x;
      fieldOffset.y = p.y;
      normalizePosInField(fieldOffset);
    }

    private function normalizePosInField(p:Vector2):void {
      if (p.x < -fieldSize.x / 2)
        p.x += fieldSize.x;
      else if (p.x >= fieldSize.x / 2)
        p.x -= fieldSize.x;
      if (p.y < -fieldSize.y / 2)
        p.y += fieldSize.y;
      else if (p.y >= fieldSize.y / 2)
        p.y -= fieldSize.y;
    }

    private function normalizeDeg(d:Number):Number {
      if (d > Math.PI)
        return d - Math.PI * 2;
      else if (d < -Math.PI)
        return d + Math.PI * 2;
      else
        return d;
    }
  }
}

class Bird
{
  public var pos:Vector2 = new Vector2;
  public var vel:Vector2 = new Vector2;
  public var deg:Number;
}

class Cloud
{
  public var pos:Vector2 = new Vector2;
  public var color:int;
  public var size:int;
}

class Vector2
{
  public var x:Number;
  public var y:Number;

  public function add(v:Vector2):void
  {
    x += v.x;
    y += v.y;
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
}


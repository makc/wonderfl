// UpDownRoad.as
//  Display a 3d updown road with 3d particles.
package
{
  import flash.display.Sprite;
  import flash.display.BitmapData;
  import flash.display.Bitmap;
  import flash.geom.Rectangle;
  import flash.events.Event;

  [SWF(width="465", height="465", backgroundColor="0x000000", frameRate="30")]
  public class UpDownRoad extends Sprite
  {
    private const SCREEN_WIDTH:int = 465;
    private const SCREEN_HEIGHT:int = 465;
    private const DRAWN_PARTICLES_MAX_COUNT:int = 2000;
    private const PROJECTION_RATIO:Number = 128;
    private const LOD_DISTANCE:Number = 200;
    private const MAX_DEPTH:Number = 500;
    private const ROAD_SPACING:Number = 5;
    private const ROAD_WIDTH:Number = 64;
    private const ROAD_HEIGHT:Number = 6;
    private const SIGHT_HEIGHT:Number = 30;
    private const BACKGROUND_BOX_SIZE:int = 16;
    private const BACKGROUND_R:int = 0x88;
    private const BACKGROUND_G:int = 0xcc;
    private const BACKGROUND_B:int = 0xff;
    private var buffer:BitmapData = new BitmapData(SCREEN_WIDTH, SCREEN_HEIGHT, false, 0);
    private var rect:Rectangle = new Rectangle;
    private var roads:Vector.<Road> = new Vector.<Road>;
    private var particles:Vector.<Particle> = new Vector.<Particle>;
    private var drawnParticles:Vector.<DrawnParticle> = new Vector.<DrawnParticle>;
    private var dpIndex:int;
    private var viewpoint:Vector3 = new Vector3;
    private var yaw:Number, pitch:Number, roll:Number;
    private var offset:Vector3 = new Vector3;
    private var carPosIndex:Number;
    private var roadIndex:int;

    public function UpDownRoad()
    {
      addChild(new Bitmap(buffer));
      yaw = pitch = roll = 0;
      createRoad();
      for (var i:int = 0; i < DRAWN_PARTICLES_MAX_COUNT; i++)
        drawnParticles.push(new DrawnParticle);
      carPosIndex = roads.length - 10;
      addEventListener(Event.ENTER_FRAME, onEnterFrame);
    }

    private function onEnterFrame(evt:Event):void
    {
      buffer.fillRect(buffer.rect, 0x99ffdd);
      carPosIndex += 1.7;
      if (carPosIndex >= roads.length)
        carPosIndex -= roads.length;
      var cpi:int = carPosIndex;
      var ncpi:int = carPosIndex + 1;
      if (ncpi >= roads.length)
        ncpi -= roads.length;
      var co:Number = carPosIndex - cpi;
      var rp:Vector3 = roads[cpi].pos;
      var nrp:Vector3 = roads[ncpi].pos;
      viewpoint.x += (rp.x * (1 - co) + nrp.x * co - viewpoint.x) * 0.2;
      viewpoint.y += (rp.y * (1 - co) + nrp.y * co - viewpoint.y - SIGHT_HEIGHT) * 0.2;
      viewpoint.z += (rp.z * (1 - co) + nrp.z * co - viewpoint.z) * 0.2;
      var oa:Number = roads[ncpi].angle - roads[cpi].angle;
      oa = normalizeAngle(oa);
      oa = roads[cpi].angle + oa * co - yaw;
      oa = normalizeAngle(oa);
      yaw += oa * 0.1;
      yaw = normalizeAngle(yaw);
      pitch += ((roads[cpi].upDown * (1 - co) + roads[ncpi].upDown * co) * 0.5 - pitch) * 0.2;
      roll += (-oa * 0.7 - roll) * 0.1;
      drawBackground();
      dpIndex = 0;
      for each (var p:Particle in particles)
        drawParticle(p);
      drawnParticles.sort(sortOnZ);
      function sortOnZ(v1:DrawnParticle, v2:DrawnParticle):Number
      {
        if (v1.pos.z < v2.pos.z)
          return 1;
        else if (v1.pos.z > v2.pos.z)
          return -1;
        else
          return 0;
      }
      for (var i:int = 0; i < dpIndex; i++)
      {
        var dp:DrawnParticle = drawnParticles[i];
        rect.x = dp.pos.x - dp.width;
        rect.y = dp.pos.y - dp.height;
        rect.width = dp.width * 2;
        rect.height = dp.height * 2;
        buffer.fillRect(rect, dp.color);
      }
    }

    private function drawParticle(p:Particle):void
    {
      offset.x = p.pos.x - viewpoint.x;
      offset.y = p.pos.y - viewpoint.y;
      offset.z = p.pos.z - viewpoint.z;
      offset.rotationYaw(yaw);
      offset.rotationPitch(pitch);
      offset.rotationRoll(roll);
      if (offset.z < -10 || offset.z > MAX_DEPTH)
        return;
      if (p.detail != null && offset.length < LOD_DISTANCE)
      {
        for each (var pp:Particle in p.detail)
          drawParticle(pp);
        return;
      }
      if (offset.z < 1 || p.width <= 0)
        return;
      var ar:Number = 1.0 - offset.z / MAX_DEPTH;
      if (ar < 0)
        return;
      var dp:DrawnParticle = drawnParticles[dpIndex];
      var zr:Number = 1.0 / offset.z * PROJECTION_RATIO;
      dp.pos.x = offset.x * zr + SCREEN_WIDTH / 2;
      dp.pos.y = offset.y * zr + SCREEN_HEIGHT / 2;
      dp.pos.z = offset.z;
      dp.width = p.width * zr;
      dp.height = p.height * zr;
      dp.color = createColor(p.r, p.g, p.b, 250 * ar);
      dpIndex++;
    }

    private function createColor(r:int, g:int, b:int, a:int):int
    {
      return int((r * a + BACKGROUND_R * (256 - a)) / 256) * 0x10000 +
             int((g * a + BACKGROUND_G * (256 - a)) / 256) * 0x100 +
             int((b * a + BACKGROUND_B * (256 - a)) / 256);
    }

    private function drawBackground():void
    {
      offset.x = 0;
      offset.y = 0;
      offset.z = 99999;
      offset.rotationPitch(pitch);
      var zr:Number = 1.0 / offset.z * PROJECTION_RATIO;
      var bc:int = SCREEN_WIDTH / BACKGROUND_BOX_SIZE + 1;
      var bx:Number, by:Number;
      var vby:Number = BACKGROUND_BOX_SIZE * Math.sin(roll);
      var bh:Number, bby:Number;
      for (var j:int = 0; j < 3; j++)
      {
        switch (j)
        {
          case 0:
          {
            bh = 8;
            bby = 0;
            break;
          }
          case 1:
          {
            bh = 16;
            bby = 16;
            break;
          }
          case 2:
          {
            bh = SCREEN_HEIGHT / 3;
            bby = 48;
            break;
          }
        }
        bx = SCREEN_WIDTH / 2 - BACKGROUND_BOX_SIZE * bc / 2;
        by = offset.y * zr + SCREEN_HEIGHT / 2 - vby * bc / 2 + bby + bh;
        rect.width = BACKGROUND_BOX_SIZE;
        rect.height = bh * 2;
        for (var i:int = 0; i < bc; i++)
        {
          rect.x = bx - BACKGROUND_BOX_SIZE / 2;
          rect.y = by - bh;
          buffer.fillRect(rect, createColor(0x88 - j * 0x33, 0x88 - j * 0x33, 0xff, 255));
          bx += BACKGROUND_BOX_SIZE;
          by += vby;
        }
      }
    }

    private var roadPattern:Array = [20, 0, 0.2, 1, 16, 0, -3, 0, 16, 0, 3, 0, 80, 0.05, 0.05, 1, 90, 0, 0, 0, 80, -0.05, -1.0, 1, 20, 0, 1.75, 1];

    private function createRoad():void
    {
      var r:Road = new Road;
      var a:Number = 0;
      var ud:Number = roadPattern[2];
      r.angle = a;
      r.upDown = ud;
      var c:int;
      var ta:Number, tud:Number;
      var polePattern:int;
      var i:int;
      roadIndex = 0;
      for (i = 0; i < roadPattern.length; i += 4)
      {
        c = roadPattern[i];
        ta = roadPattern[i + 1];
        tud = roadPattern[i + 2];
        polePattern = roadPattern[i + 3];
        for (var j:int = 0; j < c; j++)
        {
          a += (ta - a) * 0.2;
          ud += (tud - ud) * 0.1;
          r.angle += a;
          r.angle = normalizeAngle(r.angle);
          r.upDown = ud;
          addRoadAndPole(r, polePattern);
          r = getNextRoad(r);
        }
      }
      c = Math.sqrt(r.pos.x * r.pos.x + r.pos.z * r.pos.z) / ROAD_SPACING;
      var vrp:Vector3 = new Vector3;
      vrp.x = -r.pos.x / c;
      vrp.y = -r.pos.y / c;
      vrp.z = -r.pos.z / c;
      var va:Number = -r.angle / c;
      var vud:Number = -r.upDown / c;
      for (i = 0; i < c; i++)
      {
        addRoadAndPole(r, polePattern);
        var nr:Road = new Road;
        nr.pos.x = r.pos.x + vrp.x;
        nr.pos.y = r.pos.y + vrp.y;
        nr.pos.z = r.pos.z + vrp.z;
        nr.angle = r.angle + va;
        nr.upDown = r.upDown + vud;
        r = nr;
      }
    }

    private function addRoadAndPole(r:Road, polePattern:int):void
    {
      addRoadParticles(r);
      roads.push(r);
      if (polePattern > 0 && roadIndex % 7 == 0)
      {
        addPoleParticles(r);
      }
      roadIndex++;
    }

    private function getNextRoad(r:Road):Road
    {
      var nr:Road = new Road;
      nr.pos.x = r.pos.x + Math.sin(r.angle) * ROAD_SPACING;
      nr.pos.z = r.pos.z + Math.cos(r.angle) * ROAD_SPACING;
      nr.pos.y = r.pos.y + Math.sin(r.upDown) * ROAD_SPACING;
      nr.angle = r.angle;
      nr.upDown = r.upDown;
      return nr;
    }

    private function addRoadParticles(r:Road):void
    {
      for (var j:int = 0; j < 3; j++)
      {
        var p:Particle = new Particle;
        var ox:Number = Math.cos(r.angle) * ROAD_WIDTH / 3 * 2;
        var oz:Number = -Math.sin(r.angle) * ROAD_WIDTH / 3 * 2;
        p.pos.x = r.pos.x + ox * (j - 1);
        p.pos.y = r.pos.y;
        p.pos.z = r.pos.z + oz * (j - 1);
        p.width = ROAD_WIDTH / 3 * 1.05;
        p.height = ROAD_HEIGHT;
        p.detail = new Vector.<Particle>;
        var pc:int = p.width / p.height + 2;
        ox = Math.cos(r.angle) * p.width / pc * 2;
        oz = -Math.sin(r.angle) * p.width / pc * 2;
        var c:int = 0;
        var i:int;
        var pp:Particle;
        for (i = 0; i < pc; i++)
        {
          pp = new Particle;
          pp.pos.x = p.pos.x + ox * (i - pc / 2);
          pp.pos.y = p.pos.y;
          pp.pos.z = p.pos.z + oz * (i - pc / 2);
          pp.width = pp.height = p.height;
          pp.r = pp.g = pp.b = 190 + Math.random() * 30;
          c += pp.r;
          pp.detail = null;
          p.detail.push(pp);
        }
        p.r = p.g = p.b = c / pc;
        particles.push(p);
        if (roadIndex % 3 == 0 && j != 1)
        {
          pp = new Particle;
          pp.pos.x = p.pos.x + ox * pc / 2 * 1.2 * (j - 1);
          pp.pos.y = p.pos.y - p.height * 0.5;
          pp.pos.z = p.pos.z + oz * pc / 2 * 1.2 * (j - 1);
          pp.width = p.height;
          pp.height = p.height * 0.6;
          pp.r = pp.g = pp.b = 32;
          pp.detail = null;
          particles.push(pp);
        }
      }
    }

    private function addPoleParticles(r:Road):void
    {
      for (var i:int = 0; i < 2; i++)
      {
        var p:Particle = new Particle;
        p.width = 4;
        p.height = 36;
        p.pos.x = r.pos.x - Math.cos(r.angle) * ROAD_WIDTH * (i * 2 - 1) * 1.1;
        p.pos.y = r.pos.y - p.height / 2;
        p.pos.z = r.pos.z + Math.sin(r.angle) * ROAD_WIDTH * (i * 2 - 1) * 1.1;
        p.r = 250; p.g = 60; p.b = 60;
        p.detail = new Vector.<Particle>;
        for (var j:int = 0; j < 8; j++)
        {
          var pp:Particle = new Particle;
          pp.pos.x = p.pos.x;
          pp.pos.y = p.pos.y - j * p.height / 8;
          pp.pos.z = p.pos.z;
          pp.width = p.width;
          pp.height = p.height / 8;
          pp.r = p.r;
          pp.g = p.g;
          pp.b = p.b;
          pp.detail = null;
          p.detail.push(pp);
        }
        particles.push(p);
      }
    }

    private function normalizeAngle(v:Number):Number {
      if (v > Math.PI)
        return v - Math.PI * 2;
      else if (v < -Math.PI)
        return v + Math.PI * 2;
      else
        return v;
    }
  }
}

class Road
{
  public var pos:Vector3 = new Vector3;
  public var angle:Number, upDown:Number;
}

class Particle
{
  public var pos:Vector3 = new Vector3;
  public var width:Number;
  public var height:Number;
  public var r:int, g:int, b:int;
  public var detail:Vector.<Particle>;
}

class DrawnParticle
{
  public var pos:Vector3 = new Vector3;
  public var width:Number;
  public var height:Number;
  public var color:int;
}

class Vector3
{
  public var x:Number = 0;
  public var y:Number = 0;
  public var z:Number = 0;

  public function rotationYaw(v:Number):void
  {
    var sv:Number = Math.sin(v);
    var cv:Number = Math.cos(v);
    var rx:Number = cv * x - sv * z;
    z = sv * x + cv * z;
    x = rx;
  }

  public function rotationPitch(v:Number):void
  {
    var sv:Number = Math.sin(v);
    var cv:Number = Math.cos(v);
    var ry:Number = cv * y - sv * z;
    z = sv * y + cv * z;
    y = ry;
  }

  public function rotationRoll(v:Number):void
  {
    var sv:Number = Math.sin(v);
    var cv:Number = Math.cos(v);
    var rx:Number = cv * x - sv * y;
    y = sv * x + cv * y;
    x = rx;
  }

  public function get length():Number
  {
    return Math.sqrt(x * x + y * y + z * z);
  }
}


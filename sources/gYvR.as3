// forked from ABA's Ground
// Ground.as
//  Display a 3d ground surface and pillars.
package
{
  import flash.display.Sprite;
  import flash.display.BitmapData;
  import flash.display.Bitmap;
  import flash.geom.Rectangle;
  import flash.events.Event;

  [SWF(width="465", height="465", backgroundColor="0x000000", frameRate="30")]
  public class Ground extends Sprite
  {
    private const SCREEN_WIDTH:int = 465;
    private const SCREEN_HEIGHT:int = 465;
    private const COUNT:int = 512;
    private const NEAR_PLANE_DIST:Number = 0.6;
    private const PROJECTION_RATIO:Number = 250;
    private const LOD_RATIO:Number = 1.05;
    private const LOD_START_COUNT:Number = 16;
    private const PILLARS_COUNT:int = 32;
    private var buffer:BitmapData;
    private var rect:Rectangle;
    private var degs:Array;
    private var index:int;
    private var offset:Number;
    private var gys:Array;
    private var gzs:Array;
    private var gcs:Array;
    private var gas:Array;
    private var gIndices:Array;
    private var gCount:int;
    private var sightY:Number;
    private var pillars:Array;
    private var pillarRect:Rectangle;

    public function Ground()
    {
      buffer = new BitmapData(SCREEN_WIDTH, SCREEN_HEIGHT, false, 0);
      var screen:Bitmap = new Bitmap(buffer);
      addChild(screen);
      rect = new Rectangle;
      pillarRect = new Rectangle;
      gys = new Array;
      gzs = new Array;
      gcs = new Array;
      gas = new Array;
      gIndices = new Array;
      var di:Number = 0;
      var did:Number = 1.0;
      gCount = 0;
      while (di < COUNT)
      {
        gys.push(0.0);
        gzs.push(0.0);
        gcs.push(int(0));
        gas.push(int(0));
        gIndices.push(int(0));
        if (di > LOD_START_COUNT)
          did *= LOD_RATIO;
        di += did;
        gCount++;
      }
      var i:int;
      degs = new Array;
      for (i = 0; i < COUNT; i++)
      {
        var d:Number;
        if (i < COUNT / 4)
          d = -0.001;
        else if (i < COUNT / 2)
          d = 0.002;
        else if (i < COUNT / 4 * 3)
          d = -0.003;
        else
          d = 0.004;
        degs.push(d);
      }
      pillars = new Array;
      for (i = 0; i < PILLARS_COUNT; i++)
      {
        var p:Pillar = new Pillar;
        p.x = (Math.random() * 0.9 + 0.1) * 200;
        if (Math.random() < 0.5)
          p.x *= -1;
        p.z = Math.random() * COUNT;
        p.width = 2;
        p.height = 10 + Math.random() * 15;
        pillars.push(p);
      }
      index = 0;
      offset = 0;
      sightY = 0;
      addEventListener(Event.ENTER_FRAME, onEnterFrame);
    }

    private function onEnterFrame(evt:Event):void
    {
      buffer.fillRect(buffer.rect, 0);
      goForward(2.1);
      var idx:int = index;
      var d:Number = degs[idx];
      var dv:Number = -offset * d;
      var y:Number = 5 - offset * d;
      var z:Number = 1.0 - offset;
      var di:Number = 0;
      var did:Number = 1.0;
      var i:int;
      var gi:int = 0;
      var r:Number;
      for (i = 0; i < COUNT; i++)
      {
        var py:Number = y;
        var pz:Number = z;
        dv += degs[idx] - sightY * 0.00002;
        y += dv;
        z += 1.0;
        if (i > di)
        {
          r = Number(i) - di;
          gys[gi] = py * r + y * (1 - r);
          gzs[gi] = pz * r + z * (1 - r);
          var a:int = 255 - int(i * 255 / COUNT);
          gas[gi] = a;
          if (idx % 16 < 8)
            gcs[gi] = createColor(0x66, 0x88, 0x66, a);
          else
            gcs[gi] = createColor(0x77, 0x77, 0x77, a);
          gIndices[gi] = idx;
          gi++;
          if (di > LOD_START_COUNT)
            did *= LOD_RATIO;
          di += did;
        }
        idx++;
        if (idx >= COUNT)
          idx = 0;
      }
      rect.x = 0;
      rect.width = SCREEN_WIDTH;
      var sx:Number;
      var sy:Number;
      var psy:Number = 99999;
      for (i = gCount - 1; i >= 0; i--)
      {
        y = gys[i];
        z = gzs[i];
        sy = y * NEAR_PLANE_DIST / z * PROJECTION_RATIO + SCREEN_HEIGHT / 2;
        if (sy > psy)
        {
          rect.y = psy;
          rect.height = sy - psy;
          buffer.fillRect(rect, gcs[i]);
        }
        if (i < gCount - 1)
        {
          for (var j:int = 0; j < PILLARS_COUNT; j++)
          {
            var p:Pillar = pillars[j];
            if (gIndices[i] > gIndices[i + 1])
            {
              drawPillar(p, gIndices[i], gIndices[i + 1] + COUNT, i);
              drawPillar(p, gIndices[i] - COUNT, gIndices[i + 1], i);
            }
            else
            {
              drawPillar(p, gIndices[i], gIndices[i + 1], i);
            }
          }
        }
        psy = sy;
      }
    }

    private function drawPillar(p:Pillar, si:int, ei:int, i:int):void
    {
      if (p.z >= si && p.z < ei)
      {
        var r:Number = Number(ei - p.z) / (ei - si);
        var y:Number = gys[i] * r + gys[i + 1] * (1 - r);
        var z:Number = gzs[i] * r + gzs[i + 1] * (1 - r);
        var sx:Number = p.x * NEAR_PLANE_DIST / z * PROJECTION_RATIO + SCREEN_WIDTH / 2;
        var sy:Number = y * NEAR_PLANE_DIST / z * PROJECTION_RATIO + SCREEN_HEIGHT / 2;
        var sh:Number = NEAR_PLANE_DIST / z * PROJECTION_RATIO;
        for (var j:int = 0; j < 5; j++)
        {
          pillarRect.x = sx - sh * p.width * 2 / 5 * j;
          pillarRect.y = sy - sh * p.height;
          pillarRect.width = sh * p.width * 2 / 5;
          pillarRect.height = sh * p.height * 2;
          buffer.fillRect(pillarRect, createColor(0x55 + 0x11 * j, 0x55 + 0x11 * j, 0xbb, gas[i]));
        }
      }
    }

    private function createColor(r:int, g:int, b:int, a:int):int
    {
      return int(r * a / 256) * 0x10000 + int(g * a / 256) * 0x100 + int(b * a / 256);
    }

    private function goForward(v:Number):void
    {
      offset += v;
      while (offset >= 1.0)
      {
        offset -= 1.0;
        index++;
        if (index >= COUNT)
          index -= COUNT;
      }
    }
  }
}

class Pillar
{
  public var x:Number;
  public var z:Number;
  public var width:Number;
  public var height:Number;
}


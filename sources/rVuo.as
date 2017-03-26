/*
 * Ground.as
 */
package
{
  import flash.display.Sprite;
  import flash.display.BitmapData;
  import flash.display.Bitmap;
  import flash.geom.Rectangle;
  import flash.events.Event;

  [SWF(width="465", height="465", backgroundColor="0x000000", frameRate="30")]

  /**
   * Draw a 3d ground surface.
   */
  public class Ground extends Sprite
  {
    private static const SCREEN_WIDTH:int = 465;
    private static const SCREEN_HEIGHT:int = 465;
    private static const COUNT:int = 512;
    private static const NEAR_PLANE_DIST:Number = 0.6;
    private static const PROJECTION_RATIO:Number = 250;
    private static const LOD_RATIO:Number = 1.05;
    private static const LOD_START_COUNT:Number = 16;
    private var buffer:BitmapData;
    private var rect:Rectangle;
    private var degs:Array;
    private var index:int;
    private var offset:Number;
    private var gys:Array;
    private var gzs:Array;
    private var gcs:Array;
    private var gCount:int;
    private var sightY:Number;

    public function Ground()
    {
      buffer = new BitmapData(SCREEN_WIDTH, SCREEN_HEIGHT, false, 0);
      var screen:Bitmap = new Bitmap(buffer);
      addChild(screen);
      rect = new Rectangle;
      degs = new Array;
      gys = new Array;
      gzs = new Array;
      gcs = new Array;
      for (var i:int = 0; i < COUNT; i++)
      {
        degs.push(0);
      }
      var di:Number = 0;
      var did:Number = 1.0;
      gCount = 0;
      while (di < COUNT)
      {
        gys.push(0.0);
        gzs.push(0.0);
        gcs.push(int(0));
        if (di > LOD_START_COUNT)
          did *= LOD_RATIO;
        di += did;
        gCount++;
      }
      start();
      addEventListener(Event.ENTER_FRAME, onEnterFrame);
    }

    private function onEnterFrame(evt:Event):void
    {
      buffer.fillRect(buffer.rect, 0);
      update();
    }

    private function start():void
    {
      for (var i:int = 0; i < COUNT; i++)
      {
        if (i < COUNT / 4)
          degs[i] = -0.001;
        else if (i < COUNT / 2)
          degs[i] = 0.002;
        else if (i < COUNT / 4 * 3)
          degs[i] = -0.003;
        else
          degs[i] = 0.004;
      }
      index = 0;
      offset = 0;
      sightY = 0;
    }

    private function update():void
    {
      goForward(1.7);
      var idx:int = index;
      var d:Number = degs[idx];
      var dv:Number = -offset * d;
      var y:Number = 5 - offset * d;
      var z:Number = 1.0 - offset;
      var sx:Number;
      var sy:Number;
      var ss:Number;
      var di:Number = 0;
      var did:Number = 1.0;
      var i:int;
      var gi:int = 0;
      for (i = 0; i < COUNT; i++)
      {
        var py:Number = y;
        var pz:Number = z;
        dv += degs[idx] - sightY * 0.00002;
        y += dv;
        z += 1.0;
        if (i > di)
        {
          var r:Number = Number(i) - di;
          gys[gi] = py * r + y * (1 - r);
          gzs[gi] = pz * r + z * (1 - r);
          var a:int = 255 - int(i * 255 / COUNT);
          if (idx % 16 < 8)
            gcs[gi] = createColor(0x66, 0x88, 0x66, a);
          else
            gcs[gi] = createColor(0x77, 0x77, 0x77, a);
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
      var psy:Number = 99999;
      for (i = gCount - 1; i >= 0; i--)
      {
        y = gys[i];
        z = gzs[i];
        sy = y * NEAR_PLANE_DIST / z * PROJECTION_RATIO + SCREEN_HEIGHT / 2;
        ss = 1.0 * NEAR_PLANE_DIST / z * PROJECTION_RATIO;
        if (sy > psy)
        {
          rect.y = psy;
          rect.height = sy - psy;
          buffer.fillRect(rect, gcs[i]);
        }
        psy = sy;
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

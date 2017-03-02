// forked from shaktool's Peak beta 1
// forked from shaktool's Peak
// borrowed some code from psyark's BumpyPlanet:
// http://wonderfl.kayac.com/code/d79cd85845773958620f42cb3e6cb363c2020c73

package {
  import flash.display.*;
  import flash.events.*;
  import flash.filters.*;
  import flash.geom.*;
  import flash.text.*;
  import flash.utils.*;
  
  [SWF(width=465, height=465, frameRate=24, backgroundColor=0x000000)]
  public class Peak extends Sprite {
    private var heightMap:BitmapData = new BitmapData(200,200,false,0);
    private var temp:BitmapData = new BitmapData(200,200,true,0);
    private var pos: Bitmap = new Bitmap(heightMap);

    public var Tbl:Array = new Array;
    public function Peak() {
        stage.addEventListener(Event.ENTER_FRAME , generate); 
            
        Tbl[0] = new Point;
        Tbl[0].x = 1.0;
        Tbl[0].y = 1.0;

        pos.scaleX = 2.0;
        pos.scaleY = 2.0;
        addChild(pos);
    }
    public function generate(event: Event): void {
      Tbl[0].x += 2.0;
      Tbl[0].y += 1.5;
      heightMap.perlinNoise(50,50,2,0,true,true, 4, false, Tbl);
      
      // solarize:
      var palette: Array = new Array(256);
      var threshold: int = 100;
      var val:int;
      for (var i:int = 0; i < 128; i++) {
        if (i < threshold) val = 0; else val = (i - threshold) * 255 / (127 - threshold);
        val = (val << 16) | (val << 8) | (val << 0);
      	palette[i] = val;
      	palette[255 - i] = val;
      }
      heightMap.paletteMap(heightMap, new Rectangle(0,0,heightMap.width,heightMap.height), new Point(0,0), null, null, palette, null);
      
    }
  }
}


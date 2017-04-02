// forked from shaktool's Peak
// borrowed some code from psyark's BumpyPlanet:
// http://wonderfl.net/c/uLoH

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
    
    public function Peak() {
      stage.addEventListener(MouseEvent.CLICK, generate);
      generate(null)
    }
    public function generate(event: MouseEvent): void {
      stage.align = StageAlign.BOTTOM;
      stage.scaleMode = StageScaleMode.NO_SCALE;
      
      var i: int;
      var j: int;
      var val: int;
      
      heightMap.perlinNoise(50,50,10,Math.random()*int.MAX_VALUE,true,true, 4, false);
      
      var pos: Bitmap = new Bitmap(heightMap);
      addChild(pos);
      pos = new Bitmap(heightMap);
      pos.x = pos.width;
      addChild(pos);
      pos = new Bitmap(heightMap);
      pos.y = pos.height
      addChild(pos);
      pos = new Bitmap(heightMap);
      pos.x = pos.width;
      pos.y = pos.height
      addChild(pos);
      
      
      // solarize:
      var palette: Array = new Array(256);
      var threshold: int = 100;
      for (i = 0; i < 128; i++) {
        if (i < threshold) val = 0; else val = (i - threshold) * 255 / (127 - threshold);
        val = (val << 16) | (val << 8) | (val << 0);
      	palette[i] = val;
      	palette[255 - i] = val;
      }
      heightMap.paletteMap(heightMap, new Rectangle(0,0,heightMap.width,heightMap.height), new Point(0,0), null, null, palette, null);
      
      
      // flood fill:
      var blackPalette: Array = new Array(256);
      for (i = 0; i < 256; i++) {
        blackPalette[i] = 0;
      }
      
      for (i = 0; i < 256; i++) {
        if (i == 0) palette[i] = 0; else palette[i] = 0xff;
      }
      temp.paletteMap(heightMap, new Rectangle(0,0,temp.width,temp.height), new Point(0,0), blackPalette, blackPalette, palette, null);
      
      var color1: int = 0;
      var color2: int = 0;
      i = j = 0
      do {
      	i++;
      	if (i == heightMap.width) {
      	  i = 0;
      	  j++;
      	}
      	color1 = heightMap.getPixel(i,j);
      } while (color1 < (253 << 16))
      temp.floodFill(i,j,0xffffffff);
      
      for (i=0; i < heightMap.width; i++) {
        color1 = temp.getPixel(i,0);
        color2 = temp.getPixel(i,temp.height-1);
      	if (color1 == 0xff && color2 == 0xffffff) {
          temp.floodFill(i,0,0xffffffff);
      	} else if (color1 == 0xffffff && color2 == 0xff) {
          temp.floodFill(i,temp.height-1,0xffffffff);
      	}
      }
      for (i=0; i < heightMap.height; i++) {
        color1 = temp.getPixel(0,i);
        color2 = temp.getPixel(temp.width-1,i);
      	if (color1 == 0xff && color2 == 0xffffff) {
          temp.floodFill(0,i,0xffffffff);
      	} else if (color1 == 0xffffff && color2 == 0xff) {
          temp.floodFill(temp.width-1,i,0xffffffff);
      	}
      }
      
      
      palette[255] = 0x00000000;
      palette[0] = 0xff0000ff;
      
      temp.paletteMap(temp, new Rectangle(0,0,temp.width,temp.height), new Point(0,0), blackPalette, palette, blackPalette, blackPalette);
      
      heightMap.copyPixels(temp, new Rectangle(0,0,temp.width,temp.height), new Point(0,0));
    }
  }
}


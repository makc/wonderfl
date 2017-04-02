// forked from shaktool's Metroid Prime Intro Surface
// forked from shaktool's Shaded Mountains
// forked from shaktool's White Mountains
// forked from shaktool's Red Mountains
// forked from mash's Bottle Glass Mountains

// also borrowed some code from psyark's BumpyPlanet:
// http://wonderfl.net/c/uLoH

package {
  import flash.display.*;
  import flash.events.*;
  import flash.filters.*;
  import flash.geom.*;
  import flash.text.*;
  import flash.utils.*;
  
  [SWF(width=300, height=300, frameRate=24, backgroundColor=0x000000)]
  public class Mountains extends Sprite {
    private var heightMap:BitmapData = new BitmapData(300,300,false,0);
    private var extrudedMap:BitmapData = new BitmapData(300,300,false,0);
    private var texture:BitmapData = new BitmapData(300,300,false,0xffffff);
    private var rotatedScape:BitmapData = new BitmapData(300,300,false,0);
    private var shadedTexture:BitmapData = new BitmapData(300,300,true,0);
    private var rotatedTexture:BitmapData = new BitmapData(300,300,true,0);
    private var temp:BitmapData = new BitmapData(300,300,true,0);
    private var displaceFilter:DisplacementMapFilter = new DisplacementMapFilter(extrudedMap,new Point(), 16, 4, 0, 64,"color",0x0,1);
    private var a:Number = 0;
    private var screenBuffer: BitmapData = new BitmapData(300,300,false,0);
    private var normalMap:BitmapData;
    
    public function Mountains() {
      stage.align = StageAlign.BOTTOM;
      stage.scaleMode = StageScaleMode.NO_SCALE;
      stage.frameRate = 60;
      
      var fade :Shape = new Shape();
      heightMap.perlinNoise(200,200,6,Math.random()*int.MAX_VALUE,false,false, 7, true);
      var matrix: Matrix = new Matrix();
      matrix.createGradientBox(250,250,0,25,25);
      fade.graphics.beginGradientFill("radial",[0xFFFFFF,0],[1,1],[127,255],matrix); 
      fade.graphics.drawRect(0,0,300,300);
      texture.draw(fade,null,null,"multiply");
      heightMap.draw(fade,null,null,"multiply");
      normalMap = new NormalMap(heightMap, 0x80, 25)
      addEventListener(Event.ENTER_FRAME, onEnterFrame);
      
      addChild(new Bitmap(screenBuffer));
      var light:Vector3D = new Vector3D();
      light.x = -Math.cos(a-1.5) / Math.SQRT2;
      light.y = Math.sin(a-1.5) / Math.SQRT2;
      light.z = Math.sqrt(1 - light.x * light.x - light.y * light.y);
      var lighting:ColorMatrixFilter = new ColorMatrixFilter([
          2 * light.x, 2 * light.y, 2 * light.z, 0, (light.x + light.y + light.z) * -0xFF,
          2 * light.x, 2 * light.y, 2 * light.z, 0, (light.x + light.y + light.z) * -0xFF,
          2 * light.x, 2 * light.y, 2 * light.z, 0, (light.x + light.y + light.z) * -0xFF,
          0,           0,           0,           1, 0
      ]);
      shadedTexture.applyFilter(normalMap, normalMap.rect, normalMap.rect.topLeft, lighting);
      shadedTexture.draw(texture, null, null, BlendMode.MULTIPLY);
    }
    
    private function onEnterFrame(event: Event): void {
      rotatedScape.draw(heightMap,new Matrix(Math.cos(a-=(mouseX-150)/4000), 0.7*Math.sin(a), -Math.sin(a), 0.7*Math.cos(a), 150*(1-Math.cos(a)+Math.sin(a)), 105*(1-Math.sin(a)-Math.cos(a))),null,null,null,true);
      
      rotatedTexture.draw(shadedTexture,new Matrix(Math.cos(a), 0.7*Math.sin(a), -Math.sin(a), 0.7*Math.cos(a), 150*(1-Math.cos(a)+Math.sin(a)), 105*(1-Math.sin(a)-Math.cos(a))),null,null,null,true);   
      //extrudedMap.fillRect(extrudedMap.rect,0);
      
      var width2: int = extrudedMap.width;
      var height2: int = extrudedMap.height;
      extrudedMap.lock();
      for (var y: int = 0; y < height2; y++) {
        for (var x: int = 0; x < height2; x++) {
          var value: uint = rotatedScape.getPixel(x,y) & 0xff;
          if (value == 0) continue;
          var newY: int = y + 32 - ((value)>>2);
          extrudedMap.setPixel(x, newY, value);
          extrudedMap.setPixel(x, newY + 1, value - 3);
          extrudedMap.setPixel(x, newY + 2, value - 6);
          //extrudedMap.setPixel(x, newY + 3, value - 9);
          //extrudedMap.setPixel(x, newY + 4, value - 12);
        }
      }
      extrudedMap.unlock();
      
      //screenBuffer.fillRect(screenBuffer.rect,0);
      //extrudedMap.applyFilter(extrudedMap,extrudedMap.rect,new Point(), new BlurFilter(4,4)); 
      screenBuffer.applyFilter(rotatedTexture, rotatedTexture.rect, new Point(), displaceFilter);
      //screenBuffer.draw(extrudedMap, new Matrix(1,0,0,1,0,0), null, "normal");
    }
  }
}

import flash.display.BitmapData;
import flash.geom.ColorTransform;
import flash.geom.Vector3D;
import flash.geom.Matrix3D;
class NormalMap extends BitmapData {
    public function NormalMap(heightMap:BitmapData, seaHeight:uint, multiplier:Number) {
        super(heightMap.width, heightMap.height, false);
        var vec:Vector3D = new Vector3D();
        for (var y:int=0; y<heightMap.height; y++) {
            for (var x:int=0; x<heightMap.width; x++) {
                var height:uint = heightMap.getPixel(x, y) & 0xFF;
                vec.x = (height - (heightMap.getPixel((x + 1) % heightMap.width, y) & 0xFF)) / 0xFF * multiplier;
                vec.y = (height - (heightMap.getPixel(x, (y + 1) % heightMap.height) & 0xFF)) / 0xFF * multiplier;
                vec.z = 0;
                if (vec.lengthSquared > 1) {
                    vec.normalize();
                }
                vec.z = Math.sqrt(1 - vec.lengthSquared);
                setPixel(x, y,
                    (vec.x * 0x7F + 0x80) << 16 |
                    (vec.y * 0x7F + 0x80) << 8 |
                    (vec.z * 0x7F + 0x80)
                );
            }
        }
    }
}

// forked from shaktool's White Mountains
// forked from shaktool's Red Mountains
// forked from mash's Bottle Glass Mountains

// also borrowed some code from psyark's BumpyPlanet:
// http://wonderfl.kayac.com/code/d79cd85845773958620f42cb3e6cb363c2020c73

package {
  import flash.display.*;
  import flash.events.*;
  import flash.filters.*;
  import flash.geom.*;
  import flash.text.*;
  import flash.utils.*;    
  
  [SWF(width=300, height=300, frameRate=24, backgroundColor=0x000000)]
  public class Mountains extends Sprite {
    
    /**
     * 25-Line ActionScript Contest Entry
     * 
     * Project: Bottle Glass Mountains
     * Author: Daniil Tutubalin, Tomsk, Russia
     * Email: tutubalin@gmail.com
     * Date: 11/28/2008
     * 
     * Permission is hereby granted, free of charge, to any person obtaining a copy
     * of this software and associated documentation files (the "Software"), to deal
     * in the Software without restriction, including without limitation the rights
     * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
     * copies of the Software, and to permit persons to whom the Software is
     * furnished to do so, subject to the following conditions:
     * 
     * The above copyright notice and this permission notice shall be included in
     * all copies or substantial portions of the Software.
     * 
     * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
     * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
     * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
     * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
     * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
     * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
     * THE SOFTWARE.
     */
    
    private var heightMap:BitmapData = new BitmapData(300,300,false,0);
    private var extrudedmap:BitmapData = new BitmapData(300,300,false,0);
    private var texture:BitmapData = new BitmapData(300,300,false,0);
    private var rotatedScape:BitmapData = new BitmapData(300,300,false,0);
    private var shadedTexture:BitmapData = new BitmapData(300,300,true,0);
    private var rotatedTexture:BitmapData = new BitmapData(300,300,true,0);
    private var temp:BitmapData = new BitmapData(300,300,true,0);
    private var displaceFilter:DisplacementMapFilter = new DisplacementMapFilter(extrudedmap,new Point(), 16, 2, 0, 63,"color",0x0,1);
    private var a:Number = 0;
    private var screenBuffer: BitmapData = new BitmapData(300,300,false,0);
    private var normalMap:BitmapData;
    
    public function Mountains() {
      stage.align = StageAlign.BOTTOM;
      stage.scaleMode = StageScaleMode.NO_SCALE;
      
      var fade :Shape = new Shape();
      heightMap.perlinNoise(90,90,5,Math.random()*int.MAX_VALUE,false,false, 7, true);
      texture.perlinNoise(15,15,5,Math.random()*int.MAX_VALUE,false,false,7,true);
      texture.colorTransform(texture.rect, new ColorTransform(0.25,0.25,0.25,1,0,0,0,0));
      texture.draw(heightMap,null,new ColorTransform(1,1,1,1,0,0,0,0),"add");
      var matrix: Matrix = new Matrix();
      matrix.createGradientBox(250,250,0,25,25);
      fade.graphics.beginGradientFill("radial",[0xFFFFFF,0],[1,1],[127,255],matrix); 
      fade.graphics.drawRect(0,0,300,300);
      texture.draw(fade,new Matrix(1.1,0,0,1.1,-30,-30),null,"multiply");
      heightMap.draw(fade,null,null,"multiply");
      normalMap = new NormalMap(heightMap, 0x80, 25)
      addEventListener(Event.ENTER_FRAME, onEnterFrame);
      
      addChild(new Bitmap(screenBuffer));
    }
    
    private function onEnterFrame(event: Event): void {
            var light:Vector3D = new Vector3D();
            light.x = -Math.cos(a+0.5) / Math.SQRT2;
            light.y = Math.sin(a+0.5) / Math.SQRT2;
            light.z = Math.sqrt(1 - light.x * light.x - light.y * light.y);
            var lighting:ColorMatrixFilter = new ColorMatrixFilter([
                2 * light.x, 2 * light.y, 2 * light.z, 0, (light.x + light.y + light.z) * -0xFF,
                2 * light.x, 2 * light.y, 2 * light.z, 0, (light.x + light.y + light.z) * -0xFF,
                2 * light.x, 2 * light.y, 2 * light.z, 0, (light.x + light.y + light.z) * -0xFF,
                0,           0,           0,           1, 0
            ]);
            shadedTexture.applyFilter(normalMap, normalMap.rect, normalMap.rect.topLeft, lighting);
            shadedTexture.draw(texture, null, null, BlendMode.MULTIPLY);
            
      rotatedScape.draw(heightMap,new Matrix(Math.cos(a-=(mouseX-150)/2000), 0.7*Math.sin(a), -Math.sin(a), 0.7*Math.cos(a), 150*(1-Math.cos(a)+Math.sin(a)), 105*(1-Math.sin(a)-Math.cos(a))),null,null,null,true);
      
      rotatedTexture.draw(shadedTexture,new Matrix(Math.cos(a), 0.7*Math.sin(a), -Math.sin(a), 0.7*Math.cos(a), 150*(1-Math.cos(a)+Math.sin(a)), 105*(1-Math.sin(a)-Math.cos(a))),null,null,null,true);   
      extrudedmap.fillRect(extrudedmap.rect,0)
      for (var i: int=127; i>=0; i-=16) {
        temp.threshold(rotatedScape,rotatedScape.rect,new Point(), "<=", (128-i)<<8, 0, 0x0000ff00, true);
        temp.colorTransform(temp.rect, new ColorTransform(0.5,0.5,0.5,1,(128-i)>>1,(128-i)>>1,(128-i)>>1,0));
        extrudedmap.draw(temp, new Matrix(1,0,0,1,0,i>>2), null, "normal");
      }
      extrudedmap.applyFilter(extrudedmap,extrudedmap.rect,new Point(), new BlurFilter(3,3)); 
      screenBuffer.applyFilter(rotatedTexture, rotatedTexture.rect, new Point(), displaceFilter);
      //screenBuffer.draw(extrudedmap, new Matrix(1,0,0,1,0,i), null, "normal");
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

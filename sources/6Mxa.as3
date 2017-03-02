// forked from shaktool's Red Mountains
// forked from mash's Bottle Glass Mountains
// package, import, class definition added by mash
// others are from 
// http://www.25lines.com/finalists/0812/064.txt
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
    
    private var landscape:BitmapData = new BitmapData(300,300,false,0);
    private var map:BitmapData = new BitmapData(300,300,false,0);
    private var texture:BitmapData = new BitmapData(300,300,false,0);
    private var rotatedScape:BitmapData = new BitmapData(300,300,false,0);
    private var rotatedTexture:BitmapData = new BitmapData(300,300,true,0);
    private var temp:BitmapData = new BitmapData(300,300,true,0);
    private var displaceFilter:DisplacementMapFilter = new DisplacementMapFilter(map,new Point(), 16, 2, 0, 63,"color",0x0,1);
    private var a:Number = 0;
    private var screenBuffer: BitmapData = new BitmapData(300,300,false,0);
    
    public function Mountains() {
      stage.align = StageAlign.BOTTOM;
      stage.scaleMode = StageScaleMode.NO_SCALE;
      
      var fade :Shape = new Shape();
      landscape.perlinNoise(75,75,3,Math.random()*int.MAX_VALUE,false,false, 7, true);
      //texture.noise(0);
      //texture.applyFilter(texture,texture.rect,new Point(), new BlurFilter(2,2)); 
      texture.perlinNoise(15,15,5,Math.random()*int.MAX_VALUE,false,false,7,true);
      texture.colorTransform(texture.rect, new ColorTransform(0.25,0.25,0.25,1,0,0,0,0));
      texture.draw(landscape,null,new ColorTransform(1,1,1,1,0,0,0,0),"add");
      var matrix: Matrix = new Matrix();
      matrix.createGradientBox(250,250,0,25,25);
      fade.graphics.beginGradientFill("radial",[0xFFFFFF,0],[1,1],[127,255],matrix); 
      fade.graphics.drawRect(0,0,300,300);
      texture.draw(fade,new Matrix(1.1,0,0,1.1,-30,-30),null,"multiply");
      landscape.draw(fade,null,null,"multiply");
      addEventListener(Event.ENTER_FRAME, onEnterFrame);
      
      addChild(new Bitmap(screenBuffer));
    }
    
    private function onEnterFrame(event: Event): void {
      rotatedScape.draw(landscape,new Matrix(Math.cos(a-=(mouseX-150)/2000), 0.7*Math.sin(a), -Math.sin(a), 0.7*Math.cos(a), 150*(1-Math.cos(a)+Math.sin(a)), 105*(1-Math.sin(a)-Math.cos(a))),null,null,null,true);
      rotatedTexture.draw(texture,new Matrix(Math.cos(a), 0.7*Math.sin(a), -Math.sin(a), 0.7*Math.cos(a), 150*(1-Math.cos(a)+Math.sin(a)), 105*(1-Math.sin(a)-Math.cos(a))),null,null,null,true);   
      map.fillRect(map.rect,0)
      for (var i: int=127; i>=0; i-=16) {
        temp.threshold(rotatedScape,rotatedScape.rect,new Point(), "<=", (128-i)<<8, 0, 0x0000ff00, true);
        temp.colorTransform(temp.rect, new ColorTransform(0.5,0.5,0.5,1,(128-i)>>1,(128-i)>>1,(128-i)>>1,0));
        map.draw(temp, new Matrix(1,0,0,1,0,i>>2), null, "normal");
      }
      map.applyFilter(map,map.rect,new Point(), new BlurFilter(3,3)); 
      screenBuffer.applyFilter(rotatedTexture, rotatedTexture.rect, new Point(), displaceFilter);
      //screenBuffer.draw(map, new Matrix(1,0,0,1,0,i), null, "normal");
    }
  }
}


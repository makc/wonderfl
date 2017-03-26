// package, import, class definition added by mash
// others are from 
// http://www.25lines.com/finalists/0812/064.txt
package {
import flash.display.*;  
import flash.events.*;  
import flash.text.*;  
import flash.utils.*;
import flash.filters.*;
import flash.geom.*;    
public class project64 extends Sprite {
var fade :Shape;
public function project64() {

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

// 3 free lines! Alter the parameters of the following lines or remove them.
// Do not substitute other code for the three lines in this section
[SWF(width=600, height=600, frameRate=24, backgroundColor=0x000000)]
stage.align = StageAlign.TOP_LEFT;
stage.scaleMode = StageScaleMode.NO_SCALE;

var landscape:BitmapData = new BitmapData(600,600,false,0);
var map:BitmapData = new BitmapData(600,600,false,0);
var texture:BitmapData = new BitmapData(600,600,false,0);
addChild(new Bitmap(new BitmapData(600,600,false,0)));
landscape.perlinNoise(100,100,1,Math.random()*int.MAX_VALUE,false,false, 7, true);
texture.perlinNoise(100,100,3,Math.random()*int.MAX_VALUE,false,false,2,false);
texture.draw(landscape,null,new ColorTransform(0,1,0,1,0,0,0,0),"screen");
(this.fade = new Shape()).graphics.beginGradientFill("radial",[0xFFFFFF,0],[1,1],[192,255],new Matrix(0.29296875, 0, 0, 0.29296875, 300, 300));
this.fade.graphics.drawRect(0,0,600,600);
texture.draw(this.fade,new Matrix(1.1,0,0,1.1,-30,-30),null,"multiply");
landscape.draw(this.fade,null,null,"multiply");
var rotatedScape:BitmapData = new BitmapData(600,600,false,0);
var rotatedTexture = new BitmapData(600,600,true,0);
var temp:BitmapData = new BitmapData(600,600,true,0);
var displaceFilter:DisplacementMapFilter = new DisplacementMapFilter(map,new Point(), 16, 2, 0, 256,"color",0x0,1);
var a:Number = 0;
addEventListener(Event.ENTER_FRAME, function() {
	rotatedScape.draw(landscape,new Matrix(Math.cos(a-=(mouseX-300)/2000), 0.7*Math.sin(a), -Math.sin(a), 0.7*Math.cos(a), 300*(1-Math.cos(a)+Math.sin(a)), 210*(1-Math.sin(a)-Math.cos(a))),null,null,null,true);
	rotatedTexture.draw(texture,new Matrix(Math.cos(a), 0.7*Math.sin(a), -Math.sin(a), 0.7*Math.cos(a), 300*(1-Math.cos(a)+Math.sin(a)), 210*(1-Math.sin(a)-Math.cos(a))),null,null,null,true);		
	map.fillRect(map.rect,0)
	for (var i=127; i>=0; i-=16) {
		temp.threshold(rotatedScape,rotatedScape.rect,new Point(), "<=", (128-i)<<8, 0, 0x0000ff00, true);
		map.draw(temp, new Matrix(1,0,0,1,0,i), null, "normal");
	}										  
	map.applyFilter(map,map.rect,new Point(), new BlurFilter(3,3));											  
	getChildAt(0)["bitmapData"].applyFilter(rotatedTexture, rotatedTexture.rect, new Point(), displaceFilter);
});
}
}
}


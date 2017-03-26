/**
 * http://prototyprally.com/a-steroids4k/
 * @author Martin Jonasson (grapefrukt@grapefrukt.com)
 */

/* 
Licensed under the MIT License

Copyright (c) 2009 Martin Jonasson

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

http://prototyprally.com/a-steroids4k/

*/

package  {

	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.getTimer;
	
	/**
	 * a-steroids4k a game by grapefrukt (grapefrukt@grapefrukt.com)
	 * http://prototyprally.com/a-steroids4k/
	 */
	
	[ SWF( backgroundColor = '#2c2c2c', width = '500', height = '500' ) ]

	public class M extends Sprite {
		
		private var dc		:Sprite;
		private var ship	:S;
		public  var txt		:TextField;
		private var points	:int;
		public  var r		:Boolean = false;
		public  var st		:int = -3000;
		private var c		:Vector.<D>;
		
		public function M():void {
			dc = new Sprite;
			c = new Vector.<D>;
			addChild(dc);
			
			ship = new S;
			ship.die();
			addChild(ship);
			
			txt = new TextField();
			txt.textColor = 0xdddddd;
			txt.selectable = false;
			txt.defaultTextFormat = new TextFormat("_sans", 10);
			txt.text = "a-steroids4k\nby grapefrukt\nclick to start";
			addChild(txt);
			
			stage.addEventListener("mouseDown", hm);
			stage.addEventListener("mouseUp", hm);
			addEventListener("enterFrame", ef);
			
			stage.quality = "medium";
			
		}
		
		private function hm(e:*):void {
			if(!r && getTimer() - st > 3000){
				for each(var d:D in c) d.alive = false;
				for (var i:uint = 0; i < 16; i++) {
					da();
				}
				ship.die();
				r = true;
				st = getTimer();
			}
			
			ship.laser = 0;
			if(e.buttonDown && ship.alive && r) ship.laser = 50;
			ship.laser ? ship.lgfx.filters = [new GlowFilter(0xffffff, .6, 12, 12)] : ship.lgfx.filters = [];
		}
		
		private function ef(e:*):void {
			
			var d:D;
			var d2:D;
			var subresult:Vector.<D>;
			var grav:Point = new Point;
			var grav_l:Number;
			
			txt.x += (ship.x - txt.x + 15) * 0.1;
			txt.y += (ship.y - txt.y - 15) * 0.1;
			
			for each (d in c) {
				d.u();
				if (!d.alive) dcr(d);
				
				if (r && ship.alive && d.c == 0x5cec33) {
					grav.x = ship.x - d.x;
					grav.y = ship.y - d.y;
					grav_l = grav.length;
					if (grav_l < 100) {
						grav.normalize(1 - grav_l / 100);
						d.vx += grav.x * 0.1;
						d.vy += grav.y * 0.1;
					}
					if (grav_l < 10) {
						d.alive = false;
						txt.alpha = 1;
						txt.text = ++points + " / 300";
						txt.textColor = d.c;	// using the color from the destructable to save a literal specification
						if (points > 300) { // this ends the game
							r = false; 
							points = 0;
							txt.textColor = 0xdddddd;
							txt.text = "done!\n" + ((getTimer() - st) / 1000).toFixed(1) + "s";
							st = getTimer();
						}
					}
				}
				
				if (d.touched) {
					subresult = d.s();
					
					if (subresult == null) {
						d.blit();
						d.touched = false;
					} else {
						for each(d2 in subresult) {
							d2.touched = false;
							dca(d2);
						}
						dcr(d);
					}
				}
				
			}
			
			if (r) {
				if(txt.alpha) txt.alpha -= 0.01;
				ship.u();
			}
			
			if (ship.alive) {
				
				var target:D;
				var coords:Point;
				
				var p:Point = new Point(mouseX - ship.x, mouseY - ship.y);
				if(ship.laser) ship.laser = p.length * 3 + 1;
				p.normalize(1);
				
				ship.vx += p.x * .05;
				ship.vy += p.y * .05;
				
				if (ship.laser && r) {

					ship.vx -= p.x * .15;
					ship.vy -= p.y * .15;
					
					var steps:uint = 0;
					while (steps++ < ship.laser *.5) {
						target = dcght(ship.x + p.x * steps, ship.y + p.y * steps);
						if (target && target.valid) {
							coords = target.ghc(ship.x + p.x * steps, ship.y + p.y * steps);
							if (target.gp(coords.x, coords.y)) break;
						}
					}
					
					if (target && coords) {
						ship.laser = steps * 2;
						if(Math.random() < .5) da(1, ship.x + p.x * steps, ship.y + p.y * steps);
						target.sp(coords.x, coords.y, false);
					}
				}
				
				target = dcght(ship.x, ship.y);
				if (target && r) {
					coords = target.ghc(ship.x, ship.y);
					if (coords && target.valid) ship.die();
				}
			} else {
				ship.x = mouseX - 5;
				ship.y = mouseY - 5;
			}
		}
		
		private function da(size:Number = 0, x:Number = 0, y:Number = 0):void {
			var d:D = new D(size || 3 + 40 * Math.random(), size || 3 + 40 * Math.random());
			d.x = x || 500 * Math.random();
			d.y = y || 500 * Math.random();
			dca(d);
		}
			
		public function dca(d:D):void { // destructable collection, add
			c.push(d);
			dc.addChild(d);
		}
		
		public function dcr(d:D):void { // destructable collection, remove
			dc.removeChild(d);
			var i:int = 0;
			for each (var di:D in c) {
				if (di == d) {
					c.splice(i, 1);
					break;
				}
				i++;
			}
		}
		
		public function dcght(x:uint, y:uint):D { // destructable collection, get hit target
			var result:Array = dc.getObjectsUnderPoint(new Point(x, y));
			return result[0];
		}
			
	}
	
}

import flash.display.Sprite;
class GO extends Sprite { // GameObject
		
	public var vx:Number = 0;
	public var vy:Number = 0;
	public var vr:Number = 0;
	
	public var alive:Boolean = true;
	public var age:int = 150;
	
	public var bm:uint = 50;
		
	public function u():void {
		x 			+= vx;
		y 			+= vy;
		rotation 	+= vr;

		if (width < 8 && height < 8) {
			age--;
			vx *= 0.99;
			vy *= 0.99;
		}
		if (age < 0) alive = false;
		
		if (x > 500 + bm) {	
			x = -bm;
		} else if (x < -bm) {			
			x = 500 + bm;
		}
		
		if (y > 500 + bm) {
			y = -bm;
		} else if (y < -bm) {			
			y = 500 + bm;
		}
	}
}

import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Point;
import flash.utils.getTimer;
class S extends GO {

	public  var laser	:Number = 0;
	private var deathp	:uint 	= 0; // death time penalty
	public  var lgfx	:Sprite;
	
	public function S() {
		bm = 0;
		
		graphics.beginFill(0xff0000); //NORMAL_COLOR
		graphics.drawRect( -2, -2, 4, 4);
		
		lgfx = new Sprite;
		lgfx.graphics.beginFill(0x79daff); // DRILL_COLOR
		lgfx.graphics.drawRect( 0, -2.5, 100, 5);
		lgfx.blendMode = "add";
		lgfx.scaleX = 0;
		addChild(lgfx);
	}
	
	public function die():void {
		alive	= false;
		deathp 	= 100; // 3s penalty at 30fps
		alpha 	= .5;
	}
	
	override public function u():void {
		
		super.u();
		
		vx *= 0.99;
		vy *= 0.99;
		
		rotation = Math.atan2(vy, vx) * 57; // approximation of 180 / Math.PI, saves 16 bytes a piece
		
		lgfx.rotation = Math.atan2(mouseY, mouseX) * 57; // approximation of 180 / Math.PI, saves 16 bytes
		lgfx.scaleX = laser / 200;
		lgfx.scaleY = Math.sin(getTimer()/50)*0.5 + .75;

		age = 100;
		
		if (deathp && M(parent).r) {
			M(parent).txt.alpha = 1;
			M(parent).txt.textColor = 0xff0000;
			M(parent).txt.text = "spawn in " + deathp;
			alpha = Math.sin(deathp--);
		}
		
		if (deathp == 1) {
			alive = true;
			deathp = 0;
			alpha = 1;
			M(parent).txt.text = "";
		}
		
	}
	
}

import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.filters.GlowFilter;

class D extends GO {

	public var bmp		:BitmapData;
	public var com		:Point;			// centerOfMass
	public var touched	:Boolean 	= true;
	public var c		:uint 		= 0xeeeeee;

	public static const PX	:uint = 3;			// pixel size
	public static const AC	:uint = 0xff0000;	// active color
	public static const IC	:uint = 0x000000;	// inactive color
	public static const RC	:uint = 0xffff00;	// replace color

	public function D(w:int, h:int) {
		bmp = new BitmapData(w, h, false, AC);
		com = new Point;
		
		filters = [new GlowFilter(0, 1, 2, 2)];
		
		if (w * h == 1 && Math.random() < .5) c = 0x5cec33;
		
		age += Math.random() * 50;
		
		vx = Math.random() - .5;
		vy = Math.random() - .5;
		vr = Math.random() - .5;
	}

	public function sp(x:uint, y:uint, value:Boolean):void {	// set pixel
		if (x >= 0 && x < bmp.width && y >= 0 && y < bmp.height) {
			bmp.setPixel(x, y, value ? AC : IC);
			touched = true;
		}
	}

	public function gp(x:uint, y:uint):uint {	// get pixel
		var result:uint;
		if (x >= 0 && x < bmp.width && y >= 0 && y < bmp.height) result = bmp.getPixel(x, y);
		return result;
	}

	public function blit():void {
		graphics.clear();			
		for (var iy:uint = 0; iy < bmp.height; iy++) {
			var ix:uint = 0;
			var w:uint = 0;
			
			while(ix < bmp.width){
				while (bmp.getPixel(ix + w, iy) && ix + w < bmp.width) w++;
				if (w == 0) {
					ix++;
				} else {					
					graphics.beginFill(c);
					graphics.drawRect(ix * PX - com.x, iy * PX - com.y, w * PX, PX * 1.1);
					graphics.endFill();
					ix += w;
					w = 0;
				}
			}
		}
	}

	public function cpb(bmpd:BitmapData):BitmapData {	// copy bitmap
		var pixelcount	:uint = bmp.width * bmp.height;
		var ix			:uint = 0;
		var iy			:uint = 0;
		
		for (var i:uint = 0; i < pixelcount; i++) {
			ix = i % bmp.width;
			iy = i / bmp.width;
			bmp.setPixel(ix, iy, bmpd.getPixel(ix, iy) == RC ? AC : IC); // this is horrible, but it saves 6 bytes!
		}
		
		um();
		blit();
		
		return bmp;
	}

	/**
	 * Gets the hit coordinates for a given point, the coords sent in 
	 * should be in the stage's coordinate space
	 * @param	x
	 * @param	y
	 * @return	the coordinates of the hit voxel
	 */
	public function ghc(x:uint, y:uint):Point {
		var hitpos:Point = globalToLocal(new Point(x, y));
		hitpos.x = (hitpos.x + com.x) / PX;
		hitpos.y = (hitpos.y + com.y) / PX;
		return hitpos;
	}

	public function s():Vector.<D> { // s
		var ix:uint = 0;
		var iy:uint = 0;
		var rect:Rectangle;
		var rect2:Rectangle;
		
		var parts:Vector.<D> = new Vector.<D>;
		
		if (alive) {
			for (iy = 0; iy < bmp.height; iy++) {
				for (ix = 0; ix < bmp.width; ix++) {
					if (bmp.getPixel(ix, iy) == AC) {
						//trace("found set pixel at:", ix, iy);
						//trace("image is:", bmp.width, bmp.height);
						bmp.floodFill(ix, iy, RC);
						rect = bmp.getColorBoundsRect(0xffffff, RC, true);
						
						// checks if the currently colored segment is the only one in this destructable
						rect2 = bmp.getColorBoundsRect(0xffffff, AC,  true);
						
						// if it is, we skip the entire sting
						if (rect2.width == 0 && rect2.height == 0 && parts.length == 0) {
							// color the bitmap back to keep it until next time
							bmp.floodFill(ix, iy, AC);
							
							// only had one segment, escape the loop
							return null;
							
						} else {
							var nd:D = _s(rect, ix, iy);
							if (nd) parts.push(nd);
							ix = rect2.x;
							iy = rect2.y;
						}
					}
				}
			}
		}
		
		return parts;
	}

	private function _s(rect:Rectangle, firstX:uint, firstY:uint):D {
		//trace("sting region at", rect);
		
		if (!(rect.width + rect.height)) return null;
		
		var nd:D = new D(rect.width, rect.height);
		var pos:Point = localToGlobal(new Point(rect.x * PX - com.x, rect.y * PX - com.y));
		
		nd.x 		= pos.x;
		nd.y 		= pos.y;
		nd.rotation = rotation;
		nd.vx	= vx * (.9 + Math.random() * .2);
		nd.vy	= vy * (.9 + Math.random() * .2);
		nd.vr	= vr * (.9 + Math.random() * .2);
		
		var bmpData:BitmapData = new BitmapData(rect.width, rect.height);
		bmpData.copyPixels(bmp, rect, new Point);		
		nd.cpb(bmpData);
		bmp.floodFill(firstX, firstY, IC);
		
		return nd;
	}

	private function um():void {	// update mass
		
		var points:uint = 0;
		
		var pixelcount	:uint = bmp.width * bmp.height;
		var ix			:uint = 0;
		var iy			:uint = 0;
		
		for (var i:uint = 0; i < pixelcount; i++) {
			ix = i % bmp.width;
			iy = i / bmp.width;
			if (bmp.getPixel(ix, iy) == AC) {
				com.x += ix;
				com.y += iy;
				points++;
			}
		}
		
		com.x = com.x / points * PX + PX / 2;
		com.y = com.y / points * PX + PX / 2;
		
		x = localToGlobal(com).x;
		y = localToGlobal(com).y;
	}
	
	public function get valid():Boolean {
		return bmp.width > 1 && bmp.height > 1;
	}

}

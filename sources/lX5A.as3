/*
=======================================
Retro Avatars for Flash
=======================================
-Type avatar name to generate image.
-press ENTER key to save current image as PNG.
 
// Retro Avatars
// -------------
 
// By Richard Phipps
// (Open source, but a credit if used would be nice!)
 
http://retroremakes.com/forum/index.php/topic,657.0.html
より移植してみました
 
[Sample]
http://www.indiegames.com/blog/2009/06/freeware_app_pick_retro_avatar.html
http://www.flickr.com/photos/miyaoka/3592194889/

*/
package 
{
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.text.TextFieldType;
	import flash.text.TextFieldAutoSize;
	import flash.ui.Keyboard;
	import flash.events.KeyboardEvent;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.utils.ByteArray;

	import com.adobe.images.PNGEncoder;
	import flash.net.FileReference;
	import flash.geom.Matrix;
	
	import flash.system.Capabilities;
	import flash.system.IME;

	[SWF(width="465", height="465", backgroundColor= 0x0, frameRate="60")]
	public class RetroAvatars
	extends Sprite 
	{
		private	var tfd:TextField = new TextField();
		private var maxNameLength:uint = 9;
		private var bmd:AvatarBMD = new AvatarBMD(12, 12, false);
		private var bmd32:BitmapData = new BitmapData(bmd.width, bmd.height, true, 0x0);
		private var bmp:Bitmap = new Bitmap(bmd32);
		
		private static const EYES_COL:int = 0;
		private static const NOSE_COL:int = 0;
		private static const MOUSE_COL:int = 0;
		
		private var isFirst:Boolean = true;

		public function RetroAvatars():void 
		{
			//bg
			graphics.beginFill(0);
			graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			
			//ime off
			if (Capabilities.hasIME)
			{
				try
				{
					IME.enabled = false;
				}
				catch (e:Error) {}
			}
			
			//bmp
			bmp.scaleX = bmp.scaleY = 24;
			bmp.x = (stage.stageWidth - bmp.width) / 2;
			bmp.y = 40;
			addChild(bmp);			
			
			
			//text
			var tft:TextFormat = new TextFormat();
			tft.align = TextFormatAlign.CENTER;
			tft.bold = true;
			tft.font = "Verdana";
			tft.letterSpacing = 5;
			tft.size = 48;
			
			tfd.defaultTextFormat = tft;
			tfd.autoSize = TextFieldAutoSize.CENTER;
			
			tfd.x = 465/2;
			tfd.y = 380;
			tfd.text = "ENTER NAME";
			tfd.textColor = 0xDDDDDD;
			isFirst = true;
			addChild(tfd);
			
			//event
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
		}
		private function keyDownHandler(e:KeyboardEvent):void 
		{
			var cc:uint = e.charCode;
			
			// lower case keys, so make upper case.
			if (97 <= cc && cc <= 122) cc -= 32;
			
			if (isFirst) tfd.text = ""; isFirst = false;
			if (
				tfd.length < maxNameLength && 
				(
				cc == 32 // Space
				|| (cc >= 65 && cc <= 90) //letters
				|| (cc >= 48 && cc <= 57) //numbers 
				)
			)
			{
				tfd.text = tfd.text.concat(String.fromCharCode(cc));
			}
			else if ( cc == 8 && tfd.length > 0) //Backspace
			{
				tfd.text = tfd.text.substr(0, tfd.length -1);
			}
			else if (cc == 13 && 0 < tfd.text.length) // ENTER key
			{
				//save PNG to local
				var mtx:Matrix = new Matrix();
				var sc:Number = 8;
				mtx.scale(sc, sc);
				var tempBmd:BitmapData = new BitmapData(bmd32.width * sc, bmd32.height * sc, true,0);
				tempBmd.draw(bmd32, mtx);
				var ba:ByteArray = PNGEncoder.encode(tempBmd);
				var fr:FileReference = new FileReference;
				fr.save(ba, tfd.text + ".png");
			}
			
			
			var nameLen:int = tfd.text.length;
			if (nameLen == 0) 
			{
				bmd32.fillRect(bmd32.rect, 0);
				return;
			}
			
			// ------------
			// make code from text and set to srand
			Crand.srand(0);
			var code:int = 0;
			for (var g:int = 0; g < 32; g++)
			{
				code += tfd.text.charCodeAt(g % nameLen) * Crand.rand() % 1024;
			}
			Crand.srand(code); // Seed random generator with code.
			
			//make avatar color.  Random (but not too dark) colour.
			var col:int =
			Crand.rand() % 192 + 64
			| Crand.rand() % 192 + 64 << 8
			| Crand.rand() % 192 + 64 << 16;
			
			tfd.textColor = col;
			

			// ------------
			// build avatar img
			bmd.build();
			bmd.removeNoise(0);
			bmd.mirror();			
			bmd.enhanceFace();
			
			
			//copy to 32bit bmd and set color
			bmd32.threshold(bmd, bmd.rect, bmd.rect.topLeft, ">=", 0xff << 24 | AvatarBMD.SOLID_COL, 0xFF <<24  | col);
			bmd32.threshold(bmd, bmd.rect, bmd.rect.topLeft, "==", 0xff << 24 | AvatarBMD.EYES_COL, EYES_COL);
			bmd32.threshold(bmd, bmd.rect, bmd.rect.topLeft, "==", 0xff << 24 | AvatarBMD.NOSE_COL, NOSE_COL);
			bmd32.threshold(bmd, bmd.rect, bmd.rect.topLeft, "==", 0xff << 24 | AvatarBMD.MOUSE_COL, MOUSE_COL);
			bmd32.threshold(bmd, bmd.rect, bmd.rect.topLeft, "==", 0xff << 24 | AvatarBMD.BLANK_COL, 0);


		}
	}	
}
import flash.display.BitmapData
import flash.geom.Matrix;
import flash.geom.Rectangle;
class AvatarBMD
extends BitmapData
{
	public static const EYES_COL:int = 1;
	public static const NOSE_COL:int = 2;
	public static const MOUSE_COL:int = 3;
	public static const SOLID_COL:int = 0xFF;
	public static const BLANK_COL:int = 0x0;
	public function AvatarBMD(width:int, height:int, transparent:Boolean = true, fillColor:uint = 0xFFFFFFFF):void 
	{
		//bmd24
		super(width, height, false, fillColor);
	}
	public function build():void 
	{
		var c:int = 158;
		for (var y:int = 0; y < height; y++)
		{
			for (var x:int = 0; x < width; x++)
			{
				setPixel(x, y, (Crand.rand() % 356 > c) ? BLANK_COL : SOLID_COL);
			}
		}
	}
	public function enhanceFace():void 
	{
		var eyes:Boolean;
		var nose:Boolean;
		var mouth:Boolean;
		var x:int;
		var y:int;
		var hx:int = width / 2 - 1; // Half width of sprite variable.

		// Detect eyes one pixel away from horizontal centre (look from just below the top edge to the middle of the vertical height).
		for (y = 1; y < height / 2; y++)
		{
			if (getPixel(hx - 1, y) == BLANK_COL) // 0 - Empty, Pixel?
			{
				floodFill(hx - 1, y, EYES_COL); // Mark area with reserved colour 1 (normal colours are 0 - empty & 255 - solid).
				if (checkForFilledEdge() == 0) break; // If this eye area doesn't touch the edges of the image, then stop searching.
				floodFill(hx - 1, y, BLANK_COL); 	// It reaches the edge, so refill as 0 - empty and keep looking.
			}
			if (getPixel(hx - 2, y) == BLANK_COL) // Any potential eye areas one pixel further away?
			{
				floodFill(hx - 2, y, EYES_COL); 
				if (checkForFilledEdge() == 0) break;
				floodFill(hx - 2, y, BLANK_COL); 					
			}
		}


		// Ok, we didn't find anything!
		if ( y == height / 2) 
		{
			// Try to make eyes from any centre pixels (converting them to one pixel further away. i.e. xx -> x  x
			for ( y = 1; y < height; y++)
			{
				if (getPixel(hx - 1, y) == SOLID_COL && getPixel(hx, y) == BLANK_COL)
				{
					setPixel(hx - 1, y, BLANK_COL);
					setPixel(hx, y, SOLID_COL);
					setPixel(hx - 1, y + 1, BLANK_COL); // Make the eye 2 pixels (at least) high.  
					
					floodFill(hx - 1, y, EYES_COL); 
					if (checkForFilledEdge() == 0) break;
					floodFill(hx - 1, y, BLANK_COL); 					
				}
			}
		}
		
		var ny:int = y + 1;
		if (y < height) eyes = true; // Ok, we did find eyes
		
		// Still NO eyes.
		if (!eyes)
		{
			// Ok, create fake eyes!
			y = 1 + Crand.rand() % (height / 2);
			
			setPixel(hx - 1, y, EYES_COL);
			outlineArea(1); // Outline to protect area.
			
			eyes = true;
			ny = y + 1;
		}
		
		// Remove any joined up eyes (i.e xx instead of x  x)
		for (y = 1; y < height; y++)
		{
			if (getPixel(hx, y) == EYES_COL)
			{
				setPixel(hx, y, SOLID_COL);
				setPixel(hx - 1, y, EYES_COL);
			}
			else
			{
				if (getPixel(hx - 2, y) == EYES_COL) setPixel(hx, y, SOLID_COL);
				if (getPixel(hx - 1, y) == EYES_COL) setPixel(hx, y, SOLID_COL);
			}
		}
		mirror(); // Miror all eye work.
		
		if (eyes) outlineArea(EYES_COL); // Protect eyes with solid outline.
		
		trace(ny);

		
		// -------
		// Detect nose
		for (y = ny; y < height; y++)
		{
			if (getPixel(hx, y) == BLANK_COL)
			{
				floodFill(hx, y, NOSE_COL); // Fill with area colour 2.
				if ( checkForFilledEdge() == 0) break;
				floodFill(hx, y, BLANK_COL);
			}
		}
		if ( y < 10) nose = true;
		
		// No nose?
		if (!nose)
		{
			// Ok, we won't find a mouth either, but we need to make a nose/mouth one out of any open sections (regardless of touching the edge)
			for (y = ny; y < height - 1; y++)
			{
				if (getPixel(hx, y) == BLANK_COL)
				{
					setPixel(hx, y, NOSE_COL)
					nose = true;
					break;
				}
			}
			
			// Try to find a nose/mouth one pixel away which we can join up. i.e. x  x -> xxxx
			if (!nose)
			{
				for (y = ny; y < height - 1; y++)
				{
					if (getPixel(hx - 1, y) == BLANK_COL)
					{
						setPixel(hx -1, y, NOSE_COL)
						setPixel(hx, y, NOSE_COL)
						nose = true;
						break;
					}
				}
			
				// Ok, NOTHING, just create fake mouth/nose!
				if (!nose)
				{
					y = ny + 1 + Crand.rand() % (height / 3);
					if (y > height - 2) y = height - 2;

					setPixel(hx, y, NOSE_COL)
					nose = true;
					ny = y + 1;
				}
			}
		}
		else
		{
			ny = y + 1;
			
			// --------
			// Detect mouth	
			for (y = ny; y < height; y++)
			{
				if (getPixel(hx, y) == BLANK_COL)
				{
					floodFill(hx, y, MOUSE_COL);
					if (checkForFilledEdge() == 0) break;
					floodFill(hx, y, BLANK_COL);
				}
			}
			if (y < height) mouth = true;
			
			if (!mouth) // Still no mouse, so look one pixel further away and then if found, join up.
			{
				for (y = ny; y < height - 1; y++)
				{
					if (getPixel(hx - 1, y) == BLANK_COL)
					{
						setPixel(hx, y, BLANK_COL);
						floodFill(hx, y, MOUSE_COL);
						if (checkForFilledEdge() == 0) break;
						floodFill(hx, y, BLANK_COL);
					}
				}
			}
			if (y < height) mouth = true;
		}
		// Outline mouth / nose to protect and stop surrounding gfx 'bleeding' in.
		if (mouth) outlineArea(MOUSE_COL);
		if (nose) outlineArea(NOSE_COL);
		
		if (eyes) trimArea(EYES_COL, 3, 3); // Trim eyes to no more than 3 x 3
		if (nose && mouth) trimArea(NOSE_COL, 3, 3); // Trim nose to no more than 3 x 3. Mouth can be bigger..;
		
		mirror(); // Mirror to fix changes symmetrically.
		
		// Now search for any fill in any holes that doesn't leak to the edge of the sprite (passing over eyes, mouth and nose areas).
		const tmpCol:int = 4;
		for (y = 1; y < height -1; y++)
		{
			for (x = 1; x < hx - 1; x++)
			{
				if (getPixel(x, y) == BLANK_COL)
				{
					floodFill(x, y, tmpCol)
					floodFill(x, y, checkForFilledEdge() == 0 ? SOLID_COL : BLANK_COL);
				}
			}
		}

		mirror(); // Mirror finally (neccessary?)
	}
	public function mirror():void 
	{
		var mtx:Matrix = new Matrix();
		mtx.scale(-1, 1);
		mtx.translate(width, 0);
		draw(this, mtx , null, null, new Rectangle(width/2, 0, width, height));
	}
	public function checkForFilledEdge():int
	{
		var c:int;
		for (var y:int = 0; y < height; y++)
		{
			c = getPixel(0, y);
			if (c != BLANK_COL && c != SOLID_COL) return 1;
			c = getPixel(width-1, y);
			if (c != BLANK_COL && c != SOLID_COL) return 1;
		}
		for (var x:int = 0; x < width; x++)
		{
			c = getPixel(x, 0);
			if (c != BLANK_COL && c != SOLID_COL) return 2;
			c = getPixel(x, height -1);
			if (c != BLANK_COL && c != SOLID_COL) return 2;			
		}
		return 0;
	}
	public function outlineArea(col:int):void 
	{
		for (var y:int = 0; y < height; y++)
		{
			for (var x:int = 0; x < width; x++)
			{
				var c:int = getPixel(x, y);
				if (c == col) 
				{
				// diagonals are only outlined if blank (and not another reserved area).
				if (getPixel(x - 1, y - 1) == BLANK_COL) setPixel(x - 1, y - 1, SOLID_COL);
				if (getPixel(x , y - 1) != col) setPixel(x, y - 1, SOLID_COL);
				if (getPixel(x + 1, y - 1) == BLANK_COL) setPixel(x +1, y - 1, SOLID_COL);
				if (getPixel(x - 1, y) != col) setPixel(x - 1, y, SOLID_COL);
				if (getPixel(x + 1, y) != col) setPixel(x + 1, y, SOLID_COL);
				if (getPixel(x - 1, y + 1) == BLANK_COL) setPixel(x - 1, y + 1, SOLID_COL);
				if (getPixel(x, y + 1) != col) setPixel(x, y + 1, SOLID_COL);
				if (getPixel(x + 1, y + 1) == BLANK_COL) setPixel(x + 1, y + 1, SOLID_COL);
				}
			}
		}
	}
	public function trimArea(col:int, x2:int, y2:int ):void 
	{
		var rx:int;
		var nx:int = -1;
		var ny:int = -1;
		for (var y:int = 0; y < height; y++)
		{
			for (var x:int = 0; x < width / 2; x++)
			{
				if (col == 1) rx = x;
				if (col > 1) rx = ((width / 2) - 1) - x;
				
				var c:int = getPixel(rx, y);
				
				if (c == col)
				{
					if (nx == -1) nx = x;
					if (ny == -1) ny = y;
					
					if (x >= nx + x2) setPixel(rx, y, SOLID_COL);
					if (y >= ny + y2) setPixel(rx, y, SOLID_COL);
				}
			}
		}
	}
	public function removeNoise(type:int):void 
	{
		var noise:int = 4;
		var c:uint;
		for (var i:int = 0; i < noise; i++)
		{
			//Remove isolated pixels
			for (var y:int = 0; y < height; y++)
			{
				for (var x:int = 0; x < width; x++)
				{
					c = getPixel(x, y);
					if (c != BLANK_COL) continue;
					
					c = getPixel(x - 1, y - 1)
					+ getPixel(x, y - 1)
					+ getPixel(x + 1, y - 1)
					+ getPixel(x - 1, y)
					+ getPixel(x + 1, y)
					+ getPixel(x - 1, y + 1)
					+ getPixel(x, y + 1)
					+ getPixel(x + 1, y + 1);
					
					if (type == 0 && c >= 8 * SOLID_COL)
					{
						setPixel(x, y, SOLID_COL);
					}
					if (type == 1 && c >= 7 * SOLID_COL)
					{
						setPixel(x, y, SOLID_COL);							
					}
					
					// Join up 'one pixel' horizontal and vertical gaps, (adds a little order to the image).
					if (getPixel(x, y + 1) == SOLID_COL
					&& getPixel(x, y -1 ) == SOLID_COL
					&& getPixel(x-1, y ) != SOLID_COL
					&& getPixel(x + 1, y ) != SOLID_COL
					&& Crand.rand() % 5 > 2)
					{
						setPixel(x, y, SOLID_COL);
					}
					if (getPixel(x-1, y ) == SOLID_COL
					&& getPixel(x + 1, y ) == SOLID_COL
					&& getPixel(x, y + 1) != SOLID_COL
					&& getPixel(x, y -1 ) != SOLID_COL
					&& Crand.rand() % 5 > 2)
					{
						setPixel(x, y, SOLID_COL);
					}
				}
			}
			
			// Remove isolated pixels
			for (y = 0; y < height; y++)
			{
				for (x = 0; x < width; x++)
				{
					c = getPixel(x, y);
					if (c == 255)
					{
						// Add up surrounding pixels.
						c = getPixel(x, y - 1) 
						+ getPixel(x - 1, y) 
						+ getPixel(x - 1, y - 1)
						+ getPixel(x + 1, y - 1)
						+ getPixel(x + 1, y)
						+ getPixel(x, y + 1)
						+ getPixel(x - 1, y + 1)
						+ getPixel(x + 1, y + 1);
						
						// No lit pixels around this one.
						if (c <= 0) setPixel(x, y, BLANK_COL);
					}
				}
			}
		}
	}
}

/*
C rand()

http://www001.upp.so-net.ne.jp/isaku/rand.html
*/

class Crand
{
	//Visual C++ version
	private static var x:int = 1;
	public static function rand():int
	{
		x = x * 214013 + 2531011;
		return (x>>16) & 32767;
	}
	public static function srand(s:int):void
	{
		x = s;
	}
}

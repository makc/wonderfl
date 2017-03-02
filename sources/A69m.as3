package {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.media.SoundChannel;
	import flash.media.SoundMixer;
	import flash.utils.ByteArray;

	/**
	 * Some randomly branching green shit...
	 */
	[SWF(backgroundColor=0)]
	public class Branching extends Sprite {
		public var mp3:ClientMP3Loader;
		public var bmp:BitmapData;
		public var song:SoundChannel;
		public var P:Vector.<Particle>;
		public var ct:ColorTransform;
		public function Branching () {
			mp3 = new ClientMP3Loader;
			mp3.addEventListener (Event.COMPLETE, loaded);

			addChild (new Bitmap (bmp = new BitmapData (465, 465, false, 0)));
			ct = new ColorTransform (0.99, 0.999, 0.98);

			P = new Vector.<Particle> (32, true);
			for (var i:int = 0; i < 32; i++) P [i] = new Particle;
			P[0].x = 232; P[0].y = 232; P[0].a = Math.random () * 6.28;

			stage.addEventListener (MouseEvent.CLICK, click);
			stage.addEventListener (Event.ENTER_FRAME, loop);
		}
		public function click (e:MouseEvent):void {
			mp3.load ();
		}
		public function loaded (e:Event):void {
			if (song) song.stop ();
			song = mp3.sound.play (0, int.MAX_VALUE);
		}
		public var ba:ByteArray = new ByteArray;
		public function loop (e:Event):void {
			SoundMixer.computeSpectrum (ba, true);
			for (var i:int = 0; i < 64; i++) {
				if (i < 32) P [i].v = 0;

				for (var j:int = 0; j < 8; j++) {
					P [i % 32].v += ba.readFloat ();
				}

				if (i > 31) P [i % 32].n.f (P [i % 32].v);
			}

			var branches:Array = [];
			for (i = 0; i < 32; i++) {
				var p:Particle = P [i];
				if (/*(i == 0) ||*/ (p.ttl > 0)) {
					var L:Number = 7 * p.n.lastValue ();
					if (L > 1) {
						var px:Number = p.x + L * Math.cos (p.a);
						var py:Number = p.y + L * Math.sin (p.a);
						efla (bmp, p.x, p.y, px, py, 0xFFFFFF);
						p.x = (465 + px) % 465;
						p.y = (465 + py) % 465;
						p.a += p.da * p.n.lastValue ();
					} else {
						bmp.setPixel (p.x, p.y, 0xFFFFFF);
						p.da = 0.2 * (Math.random () - Math.random ());
					}
				} else if (p.n.lastValue () > 0.6) {
					branches.push (p);
				}
			}

			i = 0;
			while (branches.length > 0) {
				p = branches.shift ();
				do { i = (i + 1) % 32; } while ((i != 0) && (P [i].ttl < 1));
				p.x = P [i].x; p.y = P [i].y;
				p.a = P [i].a + p.n.lastValue () * ((Math.random () > 0.5) ? 0.4 : -0.4);
				p.ttl = 20 * p.n.lastValue ();
			}

			for (i = 0; i < 32; i++) {
				if (P [i].ttl > 0) {
					P [i].ttl--;
					if (P [i].ttl == 0) {
						P [i].da = 0.2 * (Math.random () - Math.random ());
						if (i == 0) {
							P [i].ttl = 20 * p.n.lastValue ();
						}
					}
				}
			}

			bmp.colorTransform (bmp.rect, ct);
		}
		/**
		 *	"Extremely Fast Line Algorithm"
		 *	@author 	Po-Han Lin (original version: http://www.edepot.com/algorithm.html)
		 *	@author 	Simo Santavirta (AS3 port: http://www.simppa.fi/blog/?p=521)
		 *	@author 	Jackson Dunstan (minor formatting: http://jacksondunstan.com/articles/506)
		 * 	@author 	skyboy (optimization for 10.1+)
		 *	@param  BitmapData: bmd	Bitmap to draw on
		 *	@param 	int: x			X component of the start point
		 *	@param 	int: y			Y component of the start point
		 *	@param 	int: x2			X component of the end point
		 *	@param 	int: y2			Y component of the end point
		 *	@param 	uint: color		Color of the line
		 *  @see https://github.com/skyboy/AS3-Utilities/blob/master/skyboy/utils/efla.as
		 */
		public function efla(bmd:BitmapData, x:int, y:int, x2:int, y2:int, color:uint):void {
			var shortLen:int = y2 - y;
			var longLen:int = x2 - x;
			if (!longLen) if (!shortLen) return;
			var i:int, id:int, inc:int;
			var multDiff:Number;

			bmd.lock();

			// TODO: check for this above, swap x/y/len and optimize loops to ++ and -- (operators twice as fast, still only 2 loops)
			if ((shortLen ^ (shortLen >> 31)) - (shortLen >> 31) > (longLen ^ (longLen >> 31)) - (longLen >> 31)) {
				if (shortLen < 0) {
					inc = -1;
					id = -shortLen % 4;
				} else {
					inc = 1;
					id = shortLen % 4;
				}
				multDiff = !shortLen ? longLen : longLen / shortLen;

				if (id) {
					bmd.setPixel32(x, y, color);
					i += inc;
					if (--id) {
						bmd.setPixel32(x + i * multDiff, y + i, color);
						i += inc;
						if (--id) {
							bmd.setPixel32(x + i * multDiff, y + i, color);
							i += inc;
						}
					}
				}
				while (i != shortLen) {
					bmd.setPixel32(x + i * multDiff, y + i, color);
					i += inc;
					bmd.setPixel32(x + i * multDiff, y + i, color);
					i += inc;
					bmd.setPixel32(x + i * multDiff, y + i, color);
					i += inc;
					bmd.setPixel32(x + i * multDiff, y + i, color);
					i += inc;
				}
			} else {
				if (longLen < 0) {
					inc = -1;
					id = -longLen % 4;
				} else {
					inc = 1;
					id = longLen % 4;
				}
				multDiff = !longLen ? shortLen : shortLen / longLen;

				if (id) {
					bmd.setPixel32(x, y, color);
					i += inc;
					if (--id) {
						bmd.setPixel32(x + i, y + i * multDiff, color);
						i += inc;
						if (--id) {
							bmd.setPixel32(x + i, y + i * multDiff, color);
							i += inc;
						}
					}
				}
				while (i != longLen) {
					bmd.setPixel32(x + i, y + i * multDiff, color);
					i += inc;
					bmd.setPixel32(x + i, y + i * multDiff, color);
					i += inc;
					bmd.setPixel32(x + i, y + i * multDiff, color);
					i += inc;
					bmd.setPixel32(x + i, y + i * multDiff, color);
					i += inc;
				}
			}

			bmd.unlock();
		}
	}
}

class Particle {
	public var x:Number;
	public var y:Number;
	public var a:Number, da:Number = 0;
	public var n:Normalizer = new Normalizer;
	public var v:Number;
	public var ttl:int = 1;
}

/**
 * 2nd draft of Normalizer class.
 */
class Normalizer {
	/** Damping. */
	public var d:Number = 0.9;
	/** Maximum minimum. */
	public var e:Number = 0.1;

	private var avg:Number = 0.5;
	private var val:Number = 0;

	public function average ():Number { return avg; }
	public function lastValue ():Number { return val; }

	public function f (x:Number):Number {
		avg = d * avg + (1 - d) * x;

		// f(x)=1-exp(ax); f(avg)=0.5; a=?
		var a:Number = - Math.LN2 / Math.max (avg, e);

		val = 1 - Math.exp (a * x);
		return val;
	}
}

	import com.codeazur.as3swf.SWF;
	import com.codeazur.as3swf.SWFData;
	import com.codeazur.as3swf.data.SWFScene;
	import com.codeazur.as3swf.data.SWFSymbol;
	import com.codeazur.as3swf.data.consts.SoundCompression;
	import com.codeazur.as3swf.data.consts.SoundRate;
	import com.codeazur.as3swf.data.consts.SoundSize;
	import com.codeazur.as3swf.data.consts.SoundType;
	import com.codeazur.as3swf.tags.TagDefineSceneAndFrameLabelData;
	import com.codeazur.as3swf.tags.TagDefineSound;
	import com.codeazur.as3swf.tags.TagDoABC;
	import com.codeazur.as3swf.tags.TagEnd;
	import com.codeazur.as3swf.tags.TagFileAttributes;
	import com.codeazur.as3swf.tags.TagSetBackgroundColor;
	import com.codeazur.as3swf.tags.TagShowFrame;
	import com.codeazur.as3swf.tags.TagSymbolClass;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.media.Sound;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	/**
	 * This loads MP3 from HDD.
	 * 
	 * @see http://wiki.github.com/claus/as3swf/play-mp3-directly-from-bytearray
	 * @see http://github.com/claus/as3swf/raw/master/bin/as3swf.swc
	 */
	class ClientMP3Loader extends EventDispatcher {

		/**
		 * Use this object after Event.COMPLETE.
		 */
		public var sound:Sound;

		/**
		 * Call this to load MP3 from HDD.
		 */
		public function load ():void {
			file = new FileReference;
			file.addEventListener (Event.CANCEL, onUserCancelled);
			file.addEventListener (Event.SELECT, onFileSelected);
			file.addEventListener (Event.COMPLETE, onFileLoaded);
			file.browse ([ new FileFilter ("MP3 files", "*.mp3") ]);
		}

		private var file:FileReference;
		private function onUserCancelled (e:Event):void { dispatchEvent (new Event (Event.CANCEL)); }
		private function onFileSelected (e:Event):void { file.load (); }
		private function onFileLoaded (e:Event):void {
			// Wrap the MP3 with a SWF
			var swf:ByteArray = createSWFFromMP3 (file.data);
			// Load the SWF with Loader::loadBytes()
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.INIT, initHandler);
			loader.loadBytes(swf);
		}

		private function initHandler(e:Event):void {
			// Get the sound class definition
			var SoundClass:Class = LoaderInfo(e.currentTarget).applicationDomain.getDefinition("MP3Wrapper_soundClass") as Class;
			// Instantiate the sound class
			sound = new SoundClass() as Sound;
			// Report Event.COMPLETE
			dispatchEvent (new Event (Event.COMPLETE));
		}

		private function createSWFFromMP3(mp3:ByteArray):ByteArray
		{
			// Create an empty SWF
			// Defaults to v10, 550x400px, 50fps, one frame (works fine for us)
			var swf:SWF = new SWF();
			
			// Add FileAttributes tag
			// Defaults: as3 true, all other flags false (works fine for us)
			swf.tags.push(new TagFileAttributes());

			// Add SetBackgroundColor tag
			// Default: white background (works fine for us)
			swf.tags.push(new TagSetBackgroundColor());
			
			// Add DefineSceneAndFrameLabelData tag 
			// (with the only entry being "Scene 1" at offset 0)
			var defineSceneAndFrameLabelData:TagDefineSceneAndFrameLabelData = new TagDefineSceneAndFrameLabelData();
			defineSceneAndFrameLabelData.scenes.push(new SWFScene(0, "Scene 1"));
			swf.tags.push(defineSceneAndFrameLabelData);

			// Add DefineSound tag
			// The ID is 1, all other parameters are automatically
			// determined from the mp3 itself.
			swf.tags.push(TagDefineSound.createWithMP3(1, mp3));
			
			// Add DoABC tag
			// Contains the AS3 byte code for the document class and the 
			// class definition for the embedded sound
			swf.tags.push(TagDoABC.create(abc));
			
			// Add SymbolClass tag
			// Specifies the document class and binds the sound class
			// definition to the embedded sound
			var symbolClass:TagSymbolClass = new TagSymbolClass();
			symbolClass.symbols.push(SWFSymbol.create(1, "MP3Wrapper_soundClass"));
			symbolClass.symbols.push(SWFSymbol.create(0, "MP3Wrapper"));
			swf.tags.push(symbolClass);
			
			// Add ShowFrame tag
			swf.tags.push(new TagShowFrame());

			// Add End tag
			swf.tags.push(new TagEnd());
			
			// Publish the SWF
			var swfData:SWFData = new SWFData();
			swf.publish(swfData);
			
			return swfData;
		}
		
		private static var abcData:Array = [
			0x10, 0x00, 0x2e, 0x00, 0x00, 0x00, 0x00, 0x19, 0x07, 0x6d, 0x78, 0x2e, 0x63, 0x6f, 0x72, 0x65, 
			0x0a, 0x49, 0x46, 0x6c, 0x65, 0x78, 0x41, 0x73, 0x73, 0x65, 0x74, 0x0a, 0x53, 0x6f, 0x75, 0x6e, 
			0x64, 0x41, 0x73, 0x73, 0x65, 0x74, 0x0b, 0x66, 0x6c, 0x61, 0x73, 0x68, 0x2e, 0x6d, 0x65, 0x64, 
			0x69, 0x61, 0x05, 0x53, 0x6f, 0x75, 0x6e, 0x64, 0x12, 0x6d, 0x78, 0x2e, 0x63, 0x6f, 0x72, 0x65, 
			0x3a, 0x53, 0x6f, 0x75, 0x6e, 0x64, 0x41, 0x73, 0x73, 0x65, 0x74, 0x00, 0x15, 0x4d, 0x50, 0x33, 
			0x57, 0x72, 0x61, 0x70, 0x70, 0x65, 0x72, 0x5f, 0x73, 0x6f, 0x75, 0x6e, 0x64, 0x43, 0x6c, 0x61, 
			0x73, 0x73, 0x0a, 0x4d, 0x50, 0x33, 0x57, 0x72, 0x61, 0x70, 0x70, 0x65, 0x72, 0x0d, 0x66, 0x6c, 
			0x61, 0x73, 0x68, 0x2e, 0x64, 0x69, 0x73, 0x70, 0x6c, 0x61, 0x79, 0x06, 0x53, 0x70, 0x72, 0x69, 
			0x74, 0x65, 0x0a, 0x73, 0x6f, 0x75, 0x6e, 0x64, 0x43, 0x6c, 0x61, 0x73, 0x73, 0x05, 0x43, 0x6c, 
			0x61, 0x73, 0x73, 0x2a, 0x68, 0x74, 0x74, 0x70, 0x3a, 0x2f, 0x2f, 0x77, 0x77, 0x77, 0x2e, 0x61, 
			0x64, 0x6f, 0x62, 0x65, 0x2e, 0x63, 0x6f, 0x6d, 0x2f, 0x32, 0x30, 0x30, 0x36, 0x2f, 0x66, 0x6c, 
			0x65, 0x78, 0x2f, 0x6d, 0x78, 0x2f, 0x69, 0x6e, 0x74, 0x65, 0x72, 0x6e, 0x61, 0x6c, 0x07, 0x56, 
			0x45, 0x52, 0x53, 0x49, 0x4f, 0x4e, 0x06, 0x53, 0x74, 0x72, 0x69, 0x6e, 0x67, 0x07, 0x33, 0x2e, 
			0x30, 0x2e, 0x30, 0x2e, 0x30, 0x0b, 0x6d, 0x78, 0x5f, 0x69, 0x6e, 0x74, 0x65, 0x72, 0x6e, 0x61, 
			0x6c, 0x06, 0x4f, 0x62, 0x6a, 0x65, 0x63, 0x74, 0x0c, 0x66, 0x6c, 0x61, 0x73, 0x68, 0x2e, 0x65, 
			0x76, 0x65, 0x6e, 0x74, 0x73, 0x0f, 0x45, 0x76, 0x65, 0x6e, 0x74, 0x44, 0x69, 0x73, 0x70, 0x61, 
			0x74, 0x63, 0x68, 0x65, 0x72, 0x0d, 0x44, 0x69, 0x73, 0x70, 0x6c, 0x61, 0x79, 0x4f, 0x62, 0x6a, 
			0x65, 0x63, 0x74, 0x11, 0x49, 0x6e, 0x74, 0x65, 0x72, 0x61, 0x63, 0x74, 0x69, 0x76, 0x65, 0x4f, 
			0x62, 0x6a, 0x65, 0x63, 0x74, 0x16, 0x44, 0x69, 0x73, 0x70, 0x6c, 0x61, 0x79, 0x4f, 0x62, 0x6a, 
			0x65, 0x63, 0x74, 0x43, 0x6f, 0x6e, 0x74, 0x61, 0x69, 0x6e, 0x65, 0x72, 0x0a, 0x16, 0x01, 0x16, 
			0x04, 0x18, 0x06, 0x16, 0x07, 0x18, 0x08, 0x16, 0x0a, 0x18, 0x09, 0x08, 0x0e, 0x16, 0x14, 0x03, 
			0x01, 0x01, 0x01, 0x04, 0x14, 0x07, 0x01, 0x02, 0x07, 0x01, 0x03, 0x07, 0x02, 0x05, 0x09, 0x02, 
			0x01, 0x07, 0x04, 0x08, 0x07, 0x04, 0x09, 0x07, 0x06, 0x0b, 0x07, 0x04, 0x0c, 0x07, 0x04, 0x0d, 
			0x07, 0x08, 0x0f, 0x07, 0x04, 0x10, 0x07, 0x01, 0x12, 0x09, 0x03, 0x01, 0x07, 0x04, 0x13, 0x07, 
			0x09, 0x15, 0x09, 0x08, 0x02, 0x07, 0x06, 0x16, 0x07, 0x06, 0x17, 0x07, 0x06, 0x18, 0x0d, 0x00, 
			0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
			0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
			0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
			0x00, 0x00, 0x00, 0x00, 0x04, 0x01, 0x00, 0x05, 0x00, 0x02, 0x00, 0x02, 0x03, 0x09, 0x03, 0x01, 
			0x04, 0x05, 0x00, 0x05, 0x02, 0x09, 0x05, 0x00, 0x08, 0x00, 0x06, 0x07, 0x09, 0x07, 0x00, 0x0b, 
			0x01, 0x08, 0x00, 0x00, 0x09, 0x00, 0x01, 0x00, 0x04, 0x01, 0x0a, 0x06, 0x01, 0x0b, 0x11, 0x01, 
			0x07, 0x00, 0x0a, 0x00, 0x05, 0x00, 0x01, 0x0c, 0x06, 0x00, 0x00, 0x08, 0x08, 0x03, 0x01, 0x01, 
			0x04, 0x00, 0x00, 0x06, 0x01, 0x02, 0x04, 0x00, 0x01, 0x09, 0x01, 0x05, 0x04, 0x00, 0x02, 0x0c, 
			0x01, 0x06, 0x04, 0x01, 0x03, 0x0c, 0x00, 0x01, 0x01, 0x01, 0x02, 0x03, 0xd0, 0x30, 0x47, 0x00, 
			0x00, 0x01, 0x00, 0x01, 0x03, 0x03, 0x01, 0x47, 0x00, 0x00, 0x03, 0x02, 0x01, 0x01, 0x02, 0x0a, 
			0xd0, 0x30, 0x5d, 0x04, 0x20, 0x58, 0x00, 0x68, 0x01, 0x47, 0x00, 0x00, 0x04, 0x02, 0x01, 0x05, 
			0x06, 0x09, 0xd0, 0x30, 0x5e, 0x0a, 0x2c, 0x11, 0x68, 0x0a, 0x47, 0x00, 0x00, 0x05, 0x01, 0x01, 
			0x06, 0x07, 0x06, 0xd0, 0x30, 0xd0, 0x49, 0x00, 0x47, 0x00, 0x00, 0x06, 0x02, 0x01, 0x01, 0x05, 
			0x17, 0xd0, 0x30, 0x5d, 0x0d, 0x60, 0x0e, 0x30, 0x60, 0x0f, 0x30, 0x60, 0x03, 0x30, 0x60, 0x03, 
			0x58, 0x01, 0x1d, 0x1d, 0x1d, 0x68, 0x02, 0x47, 0x00, 0x00, 0x07, 0x01, 0x01, 0x06, 0x07, 0x03, 
			0xd0, 0x30, 0x47, 0x00, 0x00, 0x08, 0x01, 0x01, 0x07, 0x08, 0x06, 0xd0, 0x30, 0xd0, 0x49, 0x00, 
			0x47, 0x00, 0x00, 0x09, 0x02, 0x01, 0x01, 0x06, 0x1b, 0xd0, 0x30, 0x5d, 0x10, 0x60, 0x0e, 0x30, 
			0x60, 0x0f, 0x30, 0x60, 0x03, 0x30, 0x60, 0x02, 0x30, 0x60, 0x02, 0x58, 0x02, 0x1d, 0x1d, 0x1d, 
			0x1d, 0x68, 0x05, 0x47, 0x00, 0x00, 0x0a, 0x01, 0x01, 0x08, 0x09, 0x03, 0xd0, 0x30, 0x47, 0x00, 
			0x00, 0x0b, 0x02, 0x01, 0x09, 0x0a, 0x0b, 0xd0, 0x30, 0xd0, 0x60, 0x05, 0x68, 0x08, 0xd0, 0x49, 
			0x00, 0x47, 0x00, 0x00, 0x0c, 0x02, 0x01, 0x01, 0x08, 0x23, 0xd0, 0x30, 0x65, 0x00, 0x60, 0x0e, 
			0x30, 0x60, 0x0f, 0x30, 0x60, 0x11, 0x30, 0x60, 0x12, 0x30, 0x60, 0x13, 0x30, 0x60, 0x07, 0x30, 
			0x60, 0x07, 0x58, 0x03, 0x1d, 0x1d, 0x1d, 0x1d, 0x1d, 0x1d, 0x68, 0x06, 0x47, 0x00, 0x00
		];

		private static function abcDataToByteArray():ByteArray {
			var ba:ByteArray = new ByteArray();
			for (var i:uint = 0; i < abcData.length; i++) {
				ba.writeByte(abcData[i]);
			}
			return ba;
		}
		
		private static var abc:ByteArray = abcDataToByteArray();
	}
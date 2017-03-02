// forked from makc3d's ff: 3D水面 / Water 3D + MP3
// forked from saharan's 3D水面 / Water 3D
package {
	import flash.media.SoundChannel;
    import flash.system.LoaderContext;
    import flash.display.*;
    import flash.events.*;
    import flash.net.*;
    [SWF(frameRate = "30", width="465", height="465")]

    /**
     * Water 3D
     * 
     * Click&Load some dubstep mp3 :)
     * 
     * @author saharan
     */
    public class Water3D extends Sprite {
        private const NUM_DETAILS:int = 48;
        private const INV_NUM_DETAILS:Number = 1 / NUM_DETAILS;
        private const MESH_SIZE:Number = 100;
        private var bmd:BitmapData;
        private var loader:Loader;
        private var vertices:Vector.<Vertex>;
        private var transformedVertices:Vector.<Number>;
        private var indices:Vector.<int>;
        private var uvt:Vector.<Number>;
        private var width2:Number;
        private var height2:Number;
        private var heights:Vector.<Vector.<Number>>;
        private var velocity:Vector.<Vector.<Number>>;
        private var mp3loader:ClientMP3Loader;
		private var song:SoundChannel;

        public function Water3D():void {
            if (stage) init();
            else addEventListener(Event.ADDED_TO_STAGE, init);
        }

        private function init(e:Event = null):void {
            removeEventListener(Event.ADDED_TO_STAGE, init);
            stage.quality = StageQuality.LOW;
            width2 = 465 / 2;
            height2 = 465 / 2;
            loader = new Loader();
            loader.load(new URLRequest("http://assets.wonderfl.net/images/related_images/b/b2/b217/b2177f87d979a28b9bcbb6e0b89370e77ce22337"), new LoaderContext(true));
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE,
                function(e:Event = null):void {
                    bmd = Bitmap(loader.content).bitmapData;
                    addEventListener(Event.ENTER_FRAME, frame);
                });
			mp3loader = new ClientMP3Loader;
			mp3loader.addEventListener(Event.COMPLETE,
                function(e:Event = null):void {
                    if (song) song.stop ();
					song = mp3loader.sound.play (0, int.MAX_VALUE);
                });
            stage.addEventListener(MouseEvent.CLICK,
                function(e:Event = null):void {
                    mp3loader.load ();
                });
            vertices = new Vector.<Vertex>(NUM_DETAILS * NUM_DETAILS, true);
            transformedVertices = new Vector.<Number>(NUM_DETAILS * NUM_DETAILS * 2, true);
            indices = new Vector.<int>();
            uvt = new Vector.<Number>(NUM_DETAILS * NUM_DETAILS * 2, true);
            var i:int;
            var j:int;
            for (i = 2; i < NUM_DETAILS - 2; i++) {
                for (j = 2; j < NUM_DETAILS - 2; j++) {
                    vertices[i * NUM_DETAILS + j] = new Vertex(
                        (j - (NUM_DETAILS - 1) * 0.5) / NUM_DETAILS * MESH_SIZE, 0,
                        (i - (NUM_DETAILS - 1) * 0.5) / NUM_DETAILS * MESH_SIZE);
                    if (i != 2 && j != 2) {
                        indices.push(getIndex(i - 1, j - 1), getIndex(i, j - 1), getIndex(i, j));
                        indices.push(getIndex(i - 1, j - 1), getIndex(i, j), getIndex(i - 1, j));
                    }
                }
            }
            heights = new Vector.<Vector.<Number>>(NUM_DETAILS, true);
            velocity = new Vector.<Vector.<Number>>(NUM_DETAILS, true);
            for (i = 0; i < NUM_DETAILS; i++) {
                heights[i] = new Vector.<Number>(NUM_DETAILS, true);
                velocity[i] = new Vector.<Number>(NUM_DETAILS, true);
                for (j = 0; j < NUM_DETAILS; j++) {
                    heights[i][j] = 0;
                    velocity[i][j] = 0;
                }
            }
        }

        private function frame(e:Event = null):void {
            drag();
            move();
            setMesh();
            transformVertices();
            draw();
        }

        private function setMesh():void {
            for (var i:int = 2; i < NUM_DETAILS - 2; i++) {
                for (var j:int = 2; j < NUM_DETAILS - 2; j++) {
                    const index:int = getIndex(i, j);
                    vertices[index].y = heights[i][j] * 0.15;
                    
                    // ---Sphere map---
                    
                    var nx:Number;
                    var ny:Number;
                    // nz is 1
                    nx = (heights[i][j] - heights[i - 1][j]) * 0.15;
                    ny = (heights[i][j] - heights[i][j - 1]) * 0.15;
                    var len:Number = 1 / Math.sqrt(nx * nx + ny * ny + 1);
                    nx *= len;
                    ny *= len;
                    uvt[index * 2] = nx * 0.5 + 0.5 + ((i - NUM_DETAILS * 0.5) * INV_NUM_DETAILS * 0.25);
                    uvt[index * 2 + 1] = ny * 0.5 + 0.5 + ((NUM_DETAILS * 0.5 - j) * INV_NUM_DETAILS * 0.25);
                }
            }
        }

        public function move():void {
            
            //---Water simulation---
            
            var i:int;
            var j:int;
            var mx:Number = mouseX / 465 * NUM_DETAILS;
            var my:Number = (1 - mouseY / 465) * NUM_DETAILS;
            for (i = 1; i < NUM_DETAILS - 1; i++) {
                for (j = 1; j < NUM_DETAILS - 1; j++) {
                    heights[i][j] += velocity[i][j];
                }
            }
            for (i = 1; i < NUM_DETAILS - 1; i++) {
                for (j = 1; j < NUM_DETAILS - 1; j++) {
                    velocity[i][j] = (velocity[i][j] +
                        (heights[i - 1][j] + heights[i][j - 1] + heights[i + 1][j] +
                        heights[i][j + 1] - heights[i][j] * 4) * 0.5) * 0.9;
                }
            }
        }

		public var arg:Number = 0;
        public function drag():void {
            var i:int;
            var j:int;
			if (song) {
				// computeSpectrum is useless...
				var s3:Number = Math.sin (3 * arg);
				var s4:Number = Math.sin (4 * arg);

				var i0:int = 2 + (NUM_DETAILS * 0.5 - 2) * (1 + s3);
				var j0:int = 2 + (NUM_DETAILS * 0.5 - 2) * (1 + s4);

				for (i = i0 - 2; i < i0 + 2; i++)
				for (j = j0 - 2; j < j0 + 2; j++) {
					var v:Number = (song.leftPeak + song.rightPeak) * 0.5;
					var d2:Number = (j - j0) * (j - j0) + (i - i0) * (i - i0);
					velocity [i] [j] -= 6 * Math.pow (v, 3) / (1 + d2);
				}
			}
			arg += 0.03; if (arg > 6.28) arg -= 6.28;
        }

        private function draw():void {
            graphics.clear();
            graphics.beginFill(0x282828);
            graphics.drawRect(0, 0, 465, 465);
            graphics.endFill();
            graphics.beginBitmapFill(bmd);
            graphics.drawTriangles(transformedVertices, indices, uvt, TriangleCulling.POSITIVE);
            graphics.endFill();
        }

        private function getIndex(x:int, y:int):int {
            return y * NUM_DETAILS + x;
        }

        private function transformVertices():void {
            var angle:Number = 70 * Math.PI / 180;
            var sin:Number = Math.sin(angle);
            var cos:Number = Math.cos(angle);
            for (var i:int = 0; i < vertices.length; i++) {
                var v:Vertex = vertices[i];
                if(v != null) {
                    var x:Number = v.x;
                    var y:Number = cos * v.y - sin * v.z;
                    var z:Number = sin * v.y + cos * v.z;
                    z = 1 / (z + 60);
                    x *= z;
                    y *= z;
                    x = x * 232.5 + 232.5;
                    y = y * 232.5 + 182.5;
                    transformedVertices[i * 2] = x;
                    transformedVertices[i * 2 + 1] = y;
                }
            }
        }
    }
}

class Vertex {
    public var x:Number;
    public var y:Number;
    public var z:Number;

    public function Vertex(x:Number, y:Number,z:Number) {
        this.x = x;
        this.y = y;
        this.z = z;
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
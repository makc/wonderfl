// hold mouse over controls to zoom
package {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shader;
	import flash.display.ShaderJob;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.events.ShaderEvent;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	[SWF(width=465,height=465)]
	public class Zoomer extends Sprite {
		private var map:Map;
		private var out:BitmapData, tmp:BitmapData, tmpRect:Rectangle;
		private var zoomer:Shader, job:ShaderJob;
		private var fwdButt:DoubleArrowButton;
		private var bwdButt:DoubleArrowButton;
		private var scrlBar:HScrollBar;
		private var cZoom:Number = 0, cCompression:Number = 1;
		private var tZoom:Number = 0, tCompression:Number = 1;
		private var maxZoom:Number, drawMatrix:Matrix = new Matrix;
		private function onProgress (e:ProgressEvent):void {
			graphics.clear ();
			graphics.lineStyle (2);
			graphics.drawRect (80, 220, 304, 34);
			graphics.lineStyle ();
			graphics.beginFill (0);
			graphics.drawRect (82, 222, 300 * e.bytesLoaded / e.bytesTotal, 30);
			graphics.endFill ();
		}
		private function onComplete (e:Event):void {
			graphics.clear ();
			map.removeEventListener (ProgressEvent.PROGRESS, onProgress);
			map.removeEventListener (Event.COMPLETE, onComplete);
			maxZoom =
				map.bitmaps [0].height * (map.bitmaps.length - 1) +
				map.bitmaps [map.bitmaps.length - 1].height -
				map.scale * 4;
			out = new BitmapData (465, 465, false, 0);
			var bmp:Bitmap = new Bitmap (out);
			addChild (bmp);
			addChild (fwdButt = new DoubleArrowButton).y = 465 - 40; fwdButt.x = 465 - 50;
			addChild (bwdButt = new DoubleArrowButton (false)).y = 465 - 40; bwdButt.x = 10;
			addChild (scrlBar = new HScrollBar (465 - 120)).y = 465 - 40; scrlBar.x = 60;
			tmp = new BitmapData (map.bitmaps [0].width, 8 * map.scale, false, 0);
			tmpRect = tmp.rect;
			zoomer.data.map.input = tmp;
			zoomer.data.map_width.value = [ tmp.width ];
			zoomer.data.map_height.value = [ tmp.height ];
			zoomer.data.map_scale.value = [ map.scale ];
			zoomer.data.zoom.value = [ Math.SQRT1_2 ];
			onEnterFrame (null);
		}
		private function onJobComplete (e:ShaderEvent):void {
			job.removeEventListener (ShaderEvent.COMPLETE, onJobComplete);
			addEventListener (Event.ENTER_FRAME, onEnterFrame);
		}
		private function onEnterFrame (e:Event):void {
			removeEventListener (Event.ENTER_FRAME, onEnterFrame);

			if (fwdButt.mouseIsOver) {
				tZoom = cZoom + map.scale; scrlBar.tgtValue = tZoom / maxZoom;
			} else if (bwdButt.mouseIsOver) {
				tZoom = cZoom - map.scale; scrlBar.tgtValue = tZoom / maxZoom;
			} else {
				tZoom = maxZoom * scrlBar.tgtValue;
			}

			tZoom = Math.max (0, Math.min (maxZoom, tZoom));

			var delta:Number = (0.9 - 1) * cZoom + 0.1 * tZoom;
			var delta_abs:Number = (delta > 0) ? delta : -delta;
			if (delta_abs > 0.1 * map.scale / cCompression) {
				delta = delta * 0.1 * map.scale / (delta_abs * cCompression);
			}
			cZoom += delta;

			scrlBar.curValue = cZoom / maxZoom;
			scrlBar.update ();

			tCompression = 1 / Math.max (1, delta_abs / map.scale);
			cCompression = 0.9 * cCompression + 0.1 * tCompression;

			var i:int = map.bitmaps.length - 1, j:int = cZoom;
			while ((j >= map.bitmaps [i].height) && (i > 0)) {
				j -= map.bitmaps [i].height; i -= 1;
			}

			drawMatrix.d = -cCompression;
			drawMatrix.ty = int (cCompression * (map.bitmaps [i].height - j));
			tmp.fillRect (tmpRect, 0);
			tmp.draw (map.bitmaps [i], drawMatrix);
			while (i > 0) {
				i -= 1;
				drawMatrix.ty += int (cCompression * map.bitmaps [i].height);
				tmp.draw (map.bitmaps [i], drawMatrix);
			}

			job = new ShaderJob (zoomer, out);
			job.addEventListener (ShaderEvent.COMPLETE, onJobComplete);
			job.start ();
		}
		public function Zoomer () {
			var sdata:Array = [-23295,0,164,1536,23151,28525,25970,-24564,28257,28005,29552,24931,25856,25976,28773,29289,28005,28276,24940,160,3190,25966,25711,29184,28001,27491,160,2166,25970,29545,28526,2,160,3172,25971,25458,26992,29801,28526,108,28519,24946,26996,26733,8297,28001,26469,8314,28527,28005,29184,-24319,512,12,24399,30068,17263,28530,25600,-23808,1133,24944,161,516,256,3940,29556,161,257,0,621,24944,24424,25961,26472,29696,-24063,28009,28246,24940,30053,65,8192,162,365,24952,22113,27765,25856,17948,16384,-24063,25701,26209,30060,29782,24940,30053,68,31232,161,257,0,365,24944,24439,26980,29800,162,365,26990,22113,27765,25856,16672,0,-24063,28001,30806,24940,30053,70,7232,162,356,25958,24949,27764,22113,27765,25856,17530,0,-24319,258,8,25715,29791,26721,27750,24435,26980,25856,-24063,28009,28246,24940,30053,65,8192,162,365,24952,22113,27765,25856,17530,0,-24063,25701,26209,30060,29782,24940,30053,67,26752,162,3172,25971,25458,26992,29801,28526,115,29045,24946,25888,26989,24935,25971,8294,28530,8302,28535,161,257,512,1133,24944,24435,25441,27749,162,365,26990,22113,27765,25856,16672,0,-24063,28001,30806,24940,30053,68,31232,162,356,25958,24949,27764,22113,27765,25856,17224,0,-24052,25701,29539,29289,28788,26991,28160,30568,25970,25888,31343,28525,8300,25974,25964,8292,28533,25196,25971,16128,-24319,258,2,31343,28525,162,365,26990,22113,27765,25856,0,0,-24063,28001,30806,24940,30053,63,-32768,162,356,25958,24949,27764,22113,27765,25856,16256,0,1027,193,512,0,771,193,0,4096,12803,32,16256,0,12803,16,16256,0,7428,193,768,4096,516,193,768,-20480,7427,193,1024,4096,12802,16,16128,0,7428,128,768,16384,1540,128,768,0,12804,64,16585,4059,1028,32,1024,16384,772,32,1024,0,7428,128,512,-16384,260,128,1024,-32768,12802,16,16256,0,7428,64,0,-16384,516,64,512,-16384,7426,16,1024,0,770,16,1024,16384,7427,32,512,-16384,12802,16,0,0,514,16,512,16384,9220,129,768,4096,7428,64,1024,0,772,64,512,-32768,5380,128,1024,16384,7428,64,512,-16384,772,64,1024,0,7426,16,1024,16384,12804,128,0,0,12804,32,16256,0,7428,16,0,-32768,516,16,1024,-32768,7428,32,512,-16384,2564,32,1024,0,7429,128,1024,-32768,2309,128,1024,-16384,7427,16,1024,-32768,12548,241,768,-20480,7425,243,1024,6912];
			var ba:ByteArray = new ByteArray; ba.endian = "bigEndian"; for (var i:int = 0; i < sdata.length; i++) ba.writeShort (sdata [i]);
			zoomer = new Shader (ba);
			map = new Map;
			map.addEventListener (ProgressEvent.PROGRESS, onProgress);
			map.addEventListener (Event.COMPLETE, onComplete);
			map.loadBitmaps ([
				"http://assets.wonderfl.net/images/related_images/b/b0/b0c7/b0c746dc922a6ab292dab1098d475abfbdabddd9",//"zoom_multipaulinator/out00a.jpg",
				"http://assets.wonderfl.net/images/related_images/6/64/643b/643b4410e0f7422e0cc8256b2c882bf30b758feb",//"zoom_multipaulinator/out00b.jpg",
				"http://assets.wonderfl.net/images/related_images/2/24/2493/24939ed0c0bb9e3615f82d6613f74fe861bd5c00",//"zoom_multipaulinator/out01a.jpg",
				"http://assets.wonderfl.net/images/related_images/6/69/6962/69627f2f85f9a149d8037b0858aced624ff09945",//"zoom_multipaulinator/out01b.jpg",
				"http://assets.wonderfl.net/images/related_images/5/54/5438/5438cc54c5365a542b368ae890636137605b73f8",//"zoom_multipaulinator/out02a.jpg",
				"http://assets.wonderfl.net/images/related_images/e/e0/e0d1/e0d14ad7d11dc43daf8fbbf6afc1c04313114ae1",//"zoom_multipaulinator/out02b.jpg",
				"http://assets.wonderfl.net/images/related_images/a/af/afbd/afbd5b91a51d8796e4fcc519af721b9656a733f8",//"zoom_multipaulinator/out03a.jpg",
				"http://assets.wonderfl.net/images/related_images/c/c0/c0d0/c0d0e7f12ee581c9e5991f78f870e338114cedd4",//"zoom_multipaulinator/out03b.jpg",
				"http://assets.wonderfl.net/images/related_images/d/da/da87/da87a0b89a23ec8770c525e57a4198a96f5b40c2",//"zoom_multipaulinator/out04a.jpg",
				"http://assets.wonderfl.net/images/related_images/0/09/0955/0955836ad2e981640127c60c481672b17c689e3c",//"zoom_multipaulinator/out04b.jpg",
				"http://assets.wonderfl.net/images/related_images/d/dc/dcc9/dcc951e12a1d57a46924ed80c7ef6fb52de78d5d",//"zoom_multipaulinator/out05a.jpg",
				"http://assets.wonderfl.net/images/related_images/2/2c/2ca3/2ca38a9ff97f8742a19eaa13162c7b952403aa95",//"zoom_multipaulinator/out05b.jpg",
				"http://assets.wonderfl.net/images/related_images/b/b1/b190/b190292b57c45ce46aa003ff6b3c031d3b9edc55",//"zoom_multipaulinator/out06a.jpg",
				"http://assets.wonderfl.net/images/related_images/b/b6/b60d/b60d596f5828f823bc462420c178402f12f02112",//"zoom_multipaulinator/out06b.jpg",
				"http://assets.wonderfl.net/images/related_images/f/f0/f098/f0985f7e2261a7b001f5e5d0e7f5ace963bf146f",//"zoom_multipaulinator/out07a.jpg",
				"http://assets.wonderfl.net/images/related_images/d/dd/dd3a/dd3aff10235d7f2af6bb74f4a16ce5dc4d995539",//"zoom_multipaulinator/out07b.jpg",
				"http://assets.wonderfl.net/images/related_images/1/14/14e5/14e50c5b25cbbda671ace1b555d6d22b9e5e55c4"//"zoom_multipaulinator/out08.jpg"
			], 60);
		}
	}
}

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Loader;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.ProgressEvent;
import flash.net.URLRequest;
import flash.system.LoaderContext;

class Map extends EventDispatcher {
	public var files:Array;
	public var scale:Number;

	private var loader:Loader;
	private var context:LoaderContext;
	private var currentFileIndex:int;
	public function loadBitmaps (files:Array, scale:Number):void {
		this.files = files; this.scale = scale;

		bitmaps = new Vector.<BitmapData> (files.length, true);

		context = new LoaderContext (true);

		loader = new Loader;
		loader.contentLoaderInfo.addEventListener (ProgressEvent.PROGRESS, onProgress);
		loader.contentLoaderInfo.addEventListener (Event.COMPLETE, onComplete);
		loader.load (new URLRequest (files [currentFileIndex = 0]), context);
	}
	private function onProgress (e:ProgressEvent):void {
		var total:uint = 100;
		var loaded:uint = Math.min (100,
			100 * (currentFileIndex + e.bytesLoaded / e.bytesTotal) / files.length
		);
		dispatchEvent (new ProgressEvent (ProgressEvent.PROGRESS, false, false, loaded, total));
	}
	private function onComplete (e:Event):void {
		bitmaps [currentFileIndex] = Bitmap (loader.content).bitmapData;
		loader.unload ();
		currentFileIndex += 1;
		if (currentFileIndex < files.length) {
			loader.load (new URLRequest (files [currentFileIndex]), context);
		} else {
			dispatchEvent (new Event (Event.COMPLETE));
		}
	}

	public var bitmaps:Vector.<BitmapData>;
}

import flash.display.Sprite;
import flash.events.MouseEvent;

class DoubleArrowButton extends flash.display.Sprite {
	public var mouseIsOver:Boolean;

	private var fwd:Boolean;
	public function DoubleArrowButton (forward:Boolean = true) {
		fwd = forward;
		addEventListener (Event.ADDED_TO_STAGE, onStage);
		addEventListener (MouseEvent.MOUSE_MOVE, onMouseMove);
	}
	private function onStage (e:Event):void {
		removeEventListener (Event.ADDED_TO_STAGE, onStage);
		stage.addEventListener (MouseEvent.MOUSE_MOVE, onMouseMove); onMouseMove (null);
	}
	private function onMouseMove (e:MouseEvent):void {
		mouseIsOver = (e != null) && (e.currentTarget == this);
		draw ();
		if (mouseIsOver) e.stopPropagation ();
	}

	protected function draw ():void {
		graphics.clear ();
		graphics.beginFill (0, 0.5);
		graphics.drawRoundRect (0, 0, 40, 30, 20);

		graphics.beginFill (mouseIsOver ? 0xFFFFFF : 0x333333);

		var a:Number = fwd ? 0 : 40;
		var b:Number = fwd ? 1 : -1;

		graphics.moveTo (a + b * 10, 10);
		graphics.lineTo (a + b * 10, 20);
		graphics.lineTo (a + b * 20, 15);
		graphics.lineTo (a + b * 20, 20);
		graphics.lineTo (a + b * 30, 15);
		graphics.lineTo (a + b * 20, 10);
		graphics.lineTo (a + b * 20, 15);
		graphics.lineTo (a + b * 10, 10);
	}
}

class HScrollBar extends DoubleArrowButton {
	public var tgtValue:Number = 0;
	public var curValue:Number = 0;

	private var w:uint;
	public function HScrollBar (width:uint) {
		w = width;
		addEventListener (MouseEvent.MOUSE_OUT, onMouseOut);
	}

	private function onMouseOut (e:MouseEvent):void {
		tgtValue = 0.01 * tgtValue + 0.99 * curValue;
	}

	override protected function draw ():void {
		if (mouseIsOver) {
			tgtValue = Math.min (1, Math.max (0, (mouseX - 20) / (w - 40)));
		}

		graphics.clear ();
		graphics.beginFill (0, 0.5);
		graphics.drawRoundRect (0, 0, w, 30, 20);

		var a:Number = (w - 40) * curValue;

		graphics.lineStyle (0, mouseIsOver ? 0xFFFFFF : 0x333333);
		graphics.beginFill (mouseIsOver ? 0xFFFFFF : 0x333333);
		graphics.drawRect (20, (30 - 8) / 2, a, 8);
		graphics.endFill ();
		graphics.drawRect (20 + a, (30 - 8) / 2, (w - 40) - a, 8);
	}

	public function update ():void { draw (); }
}
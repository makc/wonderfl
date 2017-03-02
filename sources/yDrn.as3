// Realtime Mandelbrot zoomer to 10^-6
// move your mouse right/left to zoom in/out
//
// Too bad I can't upload map in better quality...
// Oh well... coming up - Blue Marble :)
package {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Shader;
	import flash.display.ShaderJob;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.events.ShaderEvent;
	import flash.geom.ColorTransform;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	[SWF(width=465,height=465)]
	public class Zoomer extends Sprite {
		private var out:BitmapData, mX:Number = 0;
		private var zoomer:Shader, job:ShaderJob;
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
			var info:LoaderInfo = LoaderInfo (e.target);
			info.removeEventListener (ProgressEvent.PROGRESS, onProgress);
			info.removeEventListener (Event.COMPLETE, onComplete);
			out = new BitmapData (465, 465, false, 0);
			var bmp:Bitmap = new Bitmap (out);
			bmp.transform.colorTransform = new ColorTransform (1.0, 1.2, 1.5);
			addChild (bmp);
			var map:BitmapData = info.content ["bitmapData"];
			zoomer.data.map.input = map;
			zoomer.data.half_side_map.value = [ map.width * 0.5 ];
			onEnterFrame (null);
		}
		private function onJobComplete (e:ShaderEvent):void {
			job.removeEventListener (ShaderEvent.COMPLETE, onJobComplete);
			addEventListener (Event.ENTER_FRAME, onEnterFrame);
		}
		private function onEnterFrame (e:Event):void {
			removeEventListener (Event.ENTER_FRAME, onEnterFrame);
			mX *= 0.95; mX += 0.05 * mouseX;
			var zoom:Number = Math.pow (10, -6 * Math.max (0, Math.min (1, mX / 465)));
			//trace ("starting shader job for zoom = " + zoom);
			zoomer.data.zoom.value = [ zoom ];
			job = new ShaderJob (zoomer, out);
			job.addEventListener (ShaderEvent.COMPLETE, onJobComplete);
			job.start ();
		}
		public function Zoomer () {
			var sdata:Array = [-23295,0,164,1536,23151,28525,25970,-24564,28257,28005,29552,24931,25856,25976,28773,29289,28005,28276,24940,160,3190,25966,25711,29184,28001,27491,160,2166,25970,29545,28526,1,160,3172,25971,25458,26992,29801,28526,114,25953,27693,29801,28005,8297,28001,26469,8314,28527,28005,29184,-24319,512,12,24399,30068,17263,28530,25600,-23808,1133,24944,161,516,256,3940,29556,161,257,0,616,24940,26207,29545,25701,24435,29283,162,365,26990,22113,27765,25856,17096,0,-24063,28001,30806,24940,30053,68,31232,162,356,25958,24949,27764,22113,27765,25856,17256,-32768,-24319,256,1,26721,27750,24435,26980,25951,28001,28672,-24063,28009,28246,24940,30053,66,-14336,162,365,24952,22113,27765,25856,17786,0,-24063,25701,26209,30060,29782,24940,30053,68,-1536,161,257,512,2153,28278,24432,28535,25970,162,365,26990,22113,27765,25856,15820,-13107,-24063,28001,30806,24940,30053,63,-32768,162,356,25958,24949,27764,22113,27765,25856,16000,0,-24319,258,4,31343,28525,162,365,26990,22113,27765,25856,0,0,-24063,28001,30806,24940,30053,63,-32768,162,356,25958,24949,27764,22113,27765,25856,16256,0,1026,49,0,-24576,770,49,0,4096,12803,128,16256,0,12803,64,16256,0,7427,49,512,-20480,515,49,768,4096,7426,49,768,-20480,9219,129,512,-20480,7427,64,768,0,7427,128,768,16384,771,128,512,16384,7427,32,768,0,1795,32,512,0,1027,128,768,16384,771,128,768,-32768,7427,32,768,0,7428,193,512,-20480,772,193,768,-24576,12804,32,16256,0,12804,16,16256,0,7429,193,1024,4096,261,193,1024,-20480,7428,193,1280,4096,772,193,0,-4096,12549,241,1024,4096,7425,243,1280,6912];
			var ba:ByteArray = new ByteArray; ba.endian = "bigEndian"; for (var i:int = 0; i < sdata.length; i++) ba.writeShort (sdata [i]);
			zoomer = new Shader (ba);
			var loader:Loader = new Loader;
			loader.contentLoaderInfo.addEventListener (ProgressEvent.PROGRESS, onProgress);
			loader.contentLoaderInfo.addEventListener (Event.COMPLETE, onComplete);
			loader.load (new URLRequest ("http://assets.wonderfl.net/images/related_images/a/a5/a5ad/a5ad882324c251174d3261c7cf6795cdcac54523"),
				new LoaderContext (true));
		}
	}
}
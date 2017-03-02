// Realtime zoomer to makc house, better version
// move your mouse right/left to zoom in/out
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
			addChild (bmp);
			var map:BitmapData = info.content ["bitmapData"];
			zoomer.data.map.input = map;
			zoomer.data.map_width.value = [ map.width ];
			zoomer.data.map_height.value = [ map.height ];
			zoomer.data.map_scale.value = [ 80 ];
			onEnterFrame (null);
		}
		private function onJobComplete (e:ShaderEvent):void {
			job.removeEventListener (ShaderEvent.COMPLETE, onJobComplete);
			addEventListener (Event.ENTER_FRAME, onEnterFrame);
		}
		private function onEnterFrame (e:Event):void {
			removeEventListener (Event.ENTER_FRAME, onEnterFrame);
			mX *= 0.95; mX += 0.05 * mouseX;
			var zoom:Number = Math.pow (10, -5 * Math.max (0, Math.min (1, mX / 465)));
			zoom = Math.min (zoom, Math.SQRT1_2);
			//trace ("starting shader job for zoom = " + zoom);
			zoomer.data.zoom.value = [ zoom ];
			job = new ShaderJob (zoomer, out);
			job.addEventListener (ShaderEvent.COMPLETE, onJobComplete);
			job.start ();
		}
		public function Zoomer () {
			var sdata:Array = [-23295,0,164,1536,23151,28525,25970,-24564,28257,28005,29552,24931,25856,25976,28773,29289,28005,28276,24940,160,3190,25966,25711,29184,28001,27491,160,2166,25970,29545,28526,2,160,3172,25971,25458,26992,29801,28526,108,28519,24946,26996,26733,8297,28001,26469,8314,28527,28005,29184,-24319,512,12,24399,30068,17263,28530,25600,-23808,1133,24944,161,516,256,3940,29556,161,257,0,621,24944,24424,25961,26472,29696,-24063,28009,28246,24940,30053,65,8192,162,365,24952,22113,27765,25856,17948,16384,-24063,25701,26209,30060,29782,24940,30053,68,31232,161,257,0,365,24944,24439,26980,29800,162,365,26990,22113,27765,25856,16672,0,-24063,28001,30806,24940,30053,70,7232,162,356,25958,24949,27764,22113,27765,25856,17530,0,-24319,258,8,25715,29791,26721,27750,24435,26980,25856,-24063,28009,28246,24940,30053,65,8192,162,365,24952,22113,27765,25856,17530,0,-24063,25701,26209,30060,29782,24940,30053,67,26752,162,3172,25971,25458,26992,29801,28526,115,29045,24946,25888,26989,24935,25971,8294,28530,8302,28535,161,257,512,1133,24944,24435,25441,27749,162,365,26990,22113,27765,25856,16672,0,-24063,28001,30806,24940,30053,68,31232,162,356,25958,24949,27764,22113,27765,25856,17224,0,-24052,25701,29539,29289,28788,26991,28160,30568,25970,25888,31343,28525,8300,25974,25964,8292,28533,25196,25971,16128,-24319,258,2,31343,28525,162,365,26990,22113,27765,25856,0,0,-24063,28001,30806,24940,30053,63,-32768,162,356,25958,24949,27764,22113,27765,25856,16256,0,1027,193,512,0,771,193,0,4096,12803,32,16256,0,12803,16,16256,0,7428,193,768,4096,516,193,768,-20480,7427,193,1024,4096,12802,16,16128,0,7428,128,768,16384,1540,128,768,0,12804,64,16585,4059,1028,32,1024,16384,772,32,1024,0,7428,128,512,-16384,260,128,1024,-32768,12802,16,16256,0,7428,64,0,-16384,516,64,512,-16384,7426,16,1024,0,770,16,1024,16384,7427,32,512,-16384,12802,16,0,0,514,16,512,16384,9220,129,768,4096,7428,64,1024,0,772,64,512,-32768,5380,128,1024,16384,7428,64,512,-16384,772,64,1024,0,7426,16,1024,16384,12804,128,0,0,12804,32,16256,0,7428,16,0,-32768,516,16,1024,-32768,7428,32,512,-16384,2564,32,1024,0,7429,128,1024,-32768,2309,128,1024,-16384,7427,16,1024,-32768,12548,241,768,-20480,7425,243,1024,6912];
			var ba:ByteArray = new ByteArray; ba.endian = "bigEndian"; for (var i:int = 0; i < sdata.length; i++) ba.writeShort (sdata [i]);
			zoomer = new Shader (ba);
			var loader:Loader = new Loader;
			loader.contentLoaderInfo.addEventListener (ProgressEvent.PROGRESS, onProgress);
			loader.contentLoaderInfo.addEventListener (Event.COMPLETE, onComplete);
			loader.load (new URLRequest ("http://assets.wonderfl.net/images/related_images/9/98/9891/9891f67d95169f117a587e42eb02951290dca948"),
				new LoaderContext (true));
		}
	}
}
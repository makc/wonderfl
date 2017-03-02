package {
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.ActivityEvent;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.media.Camera;
	import flash.media.Video;
	import flash.text.TextField;
	/**
	 * Using camera activity level to reduce jitter in CV apps.
	 * @see http://deepanjandas.wordpress.com/2010/07/08/augmented-reality-using-flartoolkit-restrict-unnecessary-model-jumping/
	 */
	public class WebCamTest extends Sprite {
		public var camera:Camera;
		public var video:Video;
		public var bitmap:BitmapData;
		public var text:TextField;
		public function WebCamTest () {
			camera = Camera.getCamera ();
			camera.addEventListener (ActivityEvent.ACTIVITY,
				function (e:ActivityEvent):void {
					/* indicates that we want camera.activityLevel */
				} );
			video = new Video (160, 120);
			video.attachCamera (camera);
			addChild (video);
			bitmap = new BitmapData (160, 120);
			graphics.beginBitmapFill (bitmap, new Matrix (1, 0, 0, 1, 180));
			graphics.drawRect (180, 0, 160, 120);
			text = new TextField; text.y = 140;
			addChild (text);
			addEventListener (Event.ENTER_FRAME, loop);
		}
		public function loop(e:Event):void {
			text.text = camera.activityLevel.toString ();
			if (camera.activityLevel > 16 /* 0 to 100 */) {
				bitmap.draw (video);
			}
		}
	}
}
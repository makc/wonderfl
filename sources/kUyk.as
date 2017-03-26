/* -------------------------------------------------------------------
 * やっぱり怖いですよね。
 * 
 * [inspired by]
 * 某Pad
 * http://wonderfl.net/code/63331dcac2f468ad4da986160bc91d39945e6211
 * -------------------------------------------------------------------
 */

package {
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class Main extends Sprite {
		// 真ん中が透過な画像なら多分何でもいけます
		private static var IMAGE_URL:String =
		"http://assets.wonderfl.net/images/related_images/a/a2/a235/a23539b3cebd3c86ed745a2ae2afae32bfa32bfc";
		private static var IMAGE_NUM:int = 10;				// 入れ子にする画像数
		private static var IMAGE_OFFSET_X:Number = 90;		// X座標位置の補正値
		private static var IMAGE_OFFSET_Y:Number = 330;		// Y座標位置の補正値
		private static var SCALE_DEFAULT:Number = 1.5;		// 初期拡大率
		private static var SCALE_MULTIPLIER:Number = 0.45;	// 拡大率の係数
		private static var SCALE_LIMIT:Number = 6;			// 拡大率の限界値
		private static var SCALE_INCREASE:Number = 1.01;	// 拡大率の増加量
		
		private var _jobs:ExternalImageLoader;
		private var _sprites:Array;
		
		public function Main() {
			_jobs = new ExternalImageLoader();
			_jobs.addEventListener(Event.COMPLETE, initialize);
			_jobs.load(IMAGE_URL);
		}
		
		private function initialize(e:Event):void {
			_jobs.removeEventListener(Event.COMPLETE, initialize);
			
			_sprites = [];
			for (var i:int = 0; i < IMAGE_NUM; ++i) {
				var bitmap:Bitmap = new Bitmap(_jobs.image);
				bitmap.x = -(IMAGE_OFFSET_X);
				bitmap.y = -(IMAGE_OFFSET_Y);
				
				var sprite:Sprite = new Sprite();
				sprite.x = IMAGE_OFFSET_X;
				sprite.y = IMAGE_OFFSET_Y;
				sprite.scaleX = (sprite.scaleY = SCALE_DEFAULT * Math.pow(SCALE_MULTIPLIER, i));
				sprite.addChild(bitmap);
				
				_sprites.push(sprite);
				addChildAt(sprite, 0);
			}
			
			addEventListener(Event.ENTER_FRAME, update);
		}
		
		private function update(e:Event):void {
			for (var i:int = 0; i < IMAGE_NUM; ++i) {
				var sprite:Sprite = _sprites[i];
				sprite.scaleX = (sprite.scaleY *= SCALE_INCREASE);
			}
			
			// 最大の拡大率の画像が、限界値を超えていたら（完全に画面外に出ていたら）
			// 拡大率を最小にして、最奥へ再配置する
			var largest:Sprite = _sprites[0];
			var smallest:Sprite = _sprites[IMAGE_NUM - 1];
			if (largest.scaleY > SCALE_LIMIT) {
				largest.scaleX = (largest.scaleY = smallest.scaleY * SCALE_MULTIPLIER);
				_sprites.push(_sprites.shift());
				addChildAt(largest, 0);
			}
		}
	}
}
//package {
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	
	//public 
	class ExternalImageLoader extends EventDispatcher {
		public var image:BitmapData;
		
		private var _tmpA:Loader;
		private var _tmpB:Loader;
		
		public function ExternalImageLoader() {
			image = null;
		}
		
		public function load(url:String):void {
			_tmpA = new Loader();
			_tmpA.contentLoaderInfo.addEventListener(Event.INIT, tmpALoaded);
			_tmpA.load(new URLRequest(url), new LoaderContext(true));
		}
		
		private function tmpALoaded(e:Event):void {
			e.target.removeEventListener(Event.INIT, tmpALoaded);
			image = new BitmapData(int(_tmpA.width), int(_tmpA.height), true, 0x00ffffff);
			_tmpB = new Loader();
			_tmpB.contentLoaderInfo.addEventListener(Event.INIT, tmpBLoaded);
			_tmpB.loadBytes(_tmpA.contentLoaderInfo.bytes);
		}
		
		private function tmpBLoaded(e:Event):void {
			e.target.removeEventListener(Event.INIT, tmpBLoaded);
			image.draw(_tmpB);
			_tmpA = _tmpB = null;
			dispatchEvent(new Event(Event.COMPLETE));
		}
	}
//}
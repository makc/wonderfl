package {
	import flash.display.Sprite;
	[SWF(width = "465", height = "465", frameRate = "60", backgroundColor = "#000000")]
	/**
	 * 何でもスーラ -Seurat anything-
	 * 点描派風ピクセラレート
	 * ネタ元：Beyond Interaction -メディアアートのための openFrameworks プログラミング入門 P169
	 * http://www.amazon.co.jp/gp/product/4861006708?ie=UTF8&tag=laxcomplex-22&linkCode=as2&camp=247&creative=1211&creativeASIN=4861006708
	 * @author Aquioux(Yoshida, Akio)
	 */
	public class Main extends Sprite {
		
		public function Main():void {
			// model
			var model:Model = new Model();
			
			// _view
			var view:View = new View(model);
			addChild(view);
			
			// controller
			var controller:Controller = new Controller(model);
			addChild(controller);
			
			// 参照のセット
			controller.view = view;
		}
	}
}


	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Matrix;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	/**
	 * Model
	 * @author YOSHIDA, Akio (Aquioux)
	 */
	class Model extends EventDispatcher {
		// ---------- パブリックプロパティ ----------
		//
		// 表示する縦 or 横の長い方の最大値
		static public const MAX_SIZE:uint = 400;
		
		// View へ渡すデータ
		public function get data():BitmapData { return _data; }
		private var _data:BitmapData;
		
		// ---------- ローカルプロパティ ----------
		//
		private var fileRef_:FileReference;
		private var loader_:Loader;
		

		// ---------- パブリックメソッド ----------
		//
		/**
		 * コンストラクタ
		 */
		public function Model() {
			fileRef_ = new FileReference();
			loader_  = new Loader();
		}
		
		/**
		 * 画像ロード step 1 ファイル選択
		 * Controller 向けに開かれたメソッド
		 */
		public function loadHandler():void {
			fileRef_.addEventListener(Event.SELECT, load2Handler);
			fileRef_.browse();
		}

		
		// ---------- ローカルメソッド ----------
		//
		// 画像ロード step 2 ファイル読込
		private function load2Handler(e:Event):void {
			fileRef_.removeEventListener(Event.SELECT, arguments.callee);
			fileRef_.addEventListener(Event.COMPLETE, load3Handler);
			fileRef_.load();
		}
		// 画像ロード step 3 ファイル読込完了
		private function load3Handler(e:Event):void {
			fileRef_.removeEventListener(Event.COMPLETE, arguments.callee);
			loader_.loadBytes(fileRef_.data);
			loader_.contentLoaderInfo.addEventListener(Event.COMPLETE, load4Handler);
		}
		// 画像ロード step 4 ファイル読込後の処理
		private function load4Handler(e:Event):void {
			loader_.contentLoaderInfo.removeEventListener(Event.COMPLETE, arguments.callee);
			update(Bitmap(loader_.content).bitmapData);
		}
		// _data のアップデート
		private function update(bmd:BitmapData):void {
			// 読み込んだ画像ファイルの BitmapData の処理
			var w:uint = bmd.width;
			var h:uint = bmd.height;
			var scale:Number = Math.min(MAX_SIZE / w, MAX_SIZE / h);
			if (scale > 1) scale = 1;
			if (_data) _data.dispose();
			_data = new BitmapData(w * scale, h * scale);
			_data.draw(bmd, new Matrix(scale, 0, 0, scale));

			// CHANGE イベント発行
			dispatchEvent(new Event(Event.CHANGE));
		}
	}


	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.BlurFilter;
	import flash.geom.Matrix;
	import frocessing.color.ColorRGB;
	/**
	 * View
	 * @author YOSHIDA, Akio (Aquioux)
	 */
	class View extends Sprite {
		// ---------- パブリックプロパティ ----------
		//
		// Model の参照
		public function set model(value:Model):void { _model = value; }
		private var _model:Model;
		
		// Controller の参照
		public function set controller(value:Controller):void { _controller = value; }
		private var _controller:Controller;
		
		
		// ---------- ローカルプロパティ ----------
		//
		private var bm_:Bitmap;
		private var bmd_:BitmapData;
		

		// ---------- パブリックメソッド ----------
		//
		/**
		 * コンストラクタ
		 * @param	model	Model
		 */
		public function View(model:Model) {
			_model = model;
			_model.addEventListener(Event.CHANGE, changeHandler);
			
			bm_  = new Bitmap();
			bm_.filters = [new BlurFilter(2, 2, BitmapFilterQuality.HIGH)];
			addChild(bm_);
		}
		

		// ---------- ローカルメソッド ----------
		//
		// Model から Event.CHANGE が発行されたときの処理（ロード時の処理）
		private function changeHandler(e:Event):void {
			// 読み込まれたデータ
			var bmd:BitmapData = _model.data;
			// BitmapData のサイズ
			var w:uint = bmd.width;
			var h:uint = bmd.height;
			// 表示オフセット
			var sw:uint = stage.stageWidth;
			var sh:uint = stage.stageHeight;
			var offsetX:Number = (sw - w) / 2;
			var offsetY:Number = (sh - h) / 2;
			// ColorRGB インスタンス
			var rgb:ColorRGB = new ColorRGB();
			
			if (!bmd_) bmd_ = new BitmapData(sw, sh, true, 0xFF000000);
			// キャンバスリセット
			bmd_.fillRect(bmd_.rect, 0xFF000000);
			
			// BitmapData 解析、Dot 生成
			var colors:Vector.<uint> = bmd.getVector(bmd.rect);
			var radius:uint = 4;
			var interval:uint = radius * 2;
			var dot:Dot = new Dot(radius);
			var matrix:Matrix = new Matrix();
			for (var j:int = 0; j < h; j += interval) {
				for (var i:int = 0; i < w; i += interval) {
					var idx:uint = w * j + i;
					rgb.value32 = colors[idx];
					dot.draw(rgb);
					matrix.tx = i + offsetX;
					matrix.ty = j + offsetY;
					bmd_.draw(dot, matrix);
				}
			}
			bm_.bitmapData = bmd_;
		}
	}


	import com.bit101.components.PushButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	/**
	 * Controller
	 * @author YOSHIDA, Akio (Aquioux)
	 */
	class Controller extends Sprite {
		// ---------- パブリックプロパティ ----------
		//
		// Model の参照
		public function set model(value:Model):void { _model = value; }
		private var _model:Model;

		// View の参照
		public function set view(value:View):void { _view = value; }
		private var _view:View;
		

		// ---------- ローカルプロパティ ----------
		//
		private var loadButton_:PushButton;		// ロードボタン


		// ---------- パブリックメソッド ----------
		//
		/**
		 * コンストラクタ
		 * @param	model	Model
		 */
		public function Controller(model:Model) {
			_model = model;
			
			// ロードのボタン
			loadButton_ = new PushButton(this, 0, 0, "LOAD", loadHandler);
			loadButton_.width = 50;
		}
		

		// ---------- ローカルメソッド ----------
		//
		// ロードボタンのイベントハンドラ
		private function loadHandler(e:MouseEvent):void {
			_model.loadHandler();
		}
	}


	import flash.display.BlendMode;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import frocessing.color.ColorRGB;
	/**
	 * ...
	 * @author YOSHIDA, Akio (Aquioux)
	 */
	class Dot extends Sprite {
		
		private var radius_:uint;
		private var circles_:Array;
		
		public function Dot(radius:uint) {
			radius_ = radius;
			
			circles_ = [];
			for (var i:int = 0; i < 3; i++) {
				var circle:Shape = new Shape();
				circle.blendMode = BlendMode.ADD;
				addChild(circle);
				circles_.push(circle);
			}
		}
		
		public function draw(rgb:ColorRGB):void {
			var v:Vector.<uint> = new Vector.<uint>(3, true);
			v[0] = rgb.r;
			v[1] = rgb.g;
			v[2] = rgb.b;
		
			for (var i:int = 0; i < 3; i++) {
				var circle:Shape = circles_[i];
				var g:Graphics = circle.graphics;
				g.clear();
				g.beginFill(0xFF << 8 * (2 - i));
				g.drawCircle(Math.random() - 0.5, Math.random() - 0.5, radius_ * v[i] / 255);
				g.endFill();
			}
		}
	}

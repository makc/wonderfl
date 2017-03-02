package {
	import flash.display.Sprite;
	import flash.events.Event;
	/**
	 * 画像フラクタル分割を WebCam に適用
	 * @author YOSHIDA, Akio (Aquioux)
	 */
	[SWF(width = "465", height = "465", frameRate = "60", backgroundColor = "#000000")]
	
	public class Main extends Sprite {
		
		public function Main() {
			Wonderfl.capture_delay(15);

			// Model を生成
			try {
				var model:Model = new Model(stage);
			} catch (err:Error) {
				trace(err.message);
			}
			model.setEffector(new Effector(stage.stageWidth, stage.stageHeight));

			// View を生成
			var view:View = new View(model);
			addChild(view);
			
			// ユーザインタラクションはないので Controller は存在しない。
			
			// 開始
			model.start();
		}
	}
}


	import flash.display.BitmapData;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.media.Camera;
	import flash.media.Video;
	/**
	 * Web Camera の映像にエフェクトをかける（MVC の Model）
	 * エフェクトロジックは effector クラスとして外部で定義する
	 * @author YOSHIDA, Akio (Aquioux)
	 */
	class Model extends EventDispatcher {
		// --------------------------------------------------
		// View へ渡すデータ（プロパティ）
		// --------------------------------------------------
		/**
		 * 加工済みのカメラ画像
		 */
		private var _data:BitmapData;
		public function get data():BitmapData { return _data; }
		
		
		// --------------------------------------------------
		// データアクセサー（外部からデータを取得する）
		// --------------------------------------------------
		/**
		 * カメラエフェクタ
		 * @param	effector	カメラエフェクター
		 */
		private var effector:AbstractEffector;	// カメラエフェクタ
		public function setEffector(effector:AbstractEffector):void {
			this.effector = effector;
		}
		
		
		// --------------------------------------------------
		// 外部との通信をおこなうメソッド
		// --------------------------------------------------
		/**
		 * 対 View 用メソッド
		 * このメソッドの終了時にイベントを発行するので、View との通信手段となる
		 * @private
		 */
		private function update():void {
			_data = effector.applyEffect(video);
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		
		// --------------------------------------------------
		// その他のメソッド
		// --------------------------------------------------
		/**
		 * コンストラクタ
		 * コンストラクタの引数はステージとする。各種データはアクセサーによって取り込むものとする
		 * @param	stage	ステージ
		 */
		private var stage:Stage;
		// カメラが表示するサイズ
		private var cameraWidth:uint;
		private var cameraHeight:uint;
		// カメラ
		private var camera:Camera;
		private var video:Video;
		public function Model(stage:Stage) {
			this.stage = stage;
			cameraWidth  = stage.stageWidth;
			cameraHeight = stage.stageHeight;
			
			// カメラ
			camera = Camera.getCamera();
			if (camera != null) {
				// camera のセットアップ
				camera.setMode(cameraWidth, cameraHeight, stage.frameRate);
				// video のセットアップ
				video = new Video(cameraWidth, cameraHeight);
				video.attachCamera(camera);
			} else {
				throw new Error("カメラがありません。");
			}
		}
		
		/**
		 * 処理開始
		 * Event.ENTER_FRAME を使う場合、このメソッドを設定する。
		 * Controller から通知されるイベントだけで処理する場合、このメソッドは不要。
		 */
		public function start():void {
			stage.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		/**
		 * イベントハンドラ
		 * @private
		 */
		private function enterFrameHandler(event:Event):void {
			update();
		}
	}


	import flash.display.Bitmap;
	import flash.events.Event;
	/**
	 * Web Camera のスクリーン（MVC の View）
	 * @author YOSHIDA, Akio (Aquioux)
	 */
	class View extends Bitmap {
		/**
		 * コンストラクタ
		 * @param	model	Model
		 */
		private var model:Model;
		public function View(model:Model) {
			this.model = model;
			this.model.addEventListener(Event.CHANGE, changeHandler);
		}
		
		/**
		 * Model との通信手段
		 * @param	event	発生したイベント
		 */
		private function changeHandler(event:Event):void {
			// Model からデータを受け取り、視覚化
			this.bitmapData = model.data;
		}
	}


	import flash.display.BitmapData;
	import flash.display.IBitmapDrawable;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	/**
	 * ウェブカメラエフェクト用抽象クラス
	 * @author YOSHIDA, Akio
	 */
	class AbstractEffector {
		
		protected var _raw:BitmapData;	// ウェブカメラの生映像の bitmapData

		// BitmapData 操作時に使う各種変数
		protected const ZERO_POINT:Point = new Point(0, 0);
		protected var _rect:Rectangle;
		
		
		public function AbstractEffector(width:Number, height:Number) {
			_raw  = new BitmapData(width, height);
			_rect = new Rectangle(0, 0, width, height);
		}
		
		// 効果適用
		public function applyEffect(data:IBitmapDrawable):BitmapData {
			_raw.draw(data);
			return effect(_raw);
		}
		
		// 効果処理
		// サブクラスで定義
		protected function effect(raw:BitmapData):BitmapData {
			return null;
		}
	}


	import flash.display.BitmapData;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	/**
	 * Web Camera Effector
	 * フラクタル分割
	 * @author YOSHIDA, Akio (Aquioux)
	 */
	class Effector extends AbstractEffector {

		private const THRESHOLD:Number = 25;		// 閾値
		private const LIMIT_OF_MINIMUN:uint = 8;	// 分割サイズ最小値
		
		private var _colorBitmapData:BitmapData;	// 読込画像の BitmapData
		private var _grayBitmapData:BitmapData;		// グレイスケール化した BitmapData
		private var _canvasBitmapData:BitmapData;
		private var _histVector:Vector.<Vector.<Number>>;	// BitmapData.histogram() の返り値として共用する
		private var _numOfPixel:uint;				// Rectangle 内のピクセル数として共用する
		
		
		public function Effector(width:Number, height:Number) {
			super(width, height);
			_colorBitmapData  = new BitmapData(width, height);
			_grayBitmapData   = new BitmapData(width, height);
			_canvasBitmapData = new BitmapData(width, height);
		}
		
		override protected function effect(value:BitmapData):BitmapData {
			_colorBitmapData  = value;
			_grayBitmapData   = _colorBitmapData.clone();
			_canvasBitmapData = _colorBitmapData.clone();
			grayscale(_grayBitmapData);

			// 再帰処理の開始
			_rect = new Rectangle(0, 0, _colorBitmapData.width, _colorBitmapData.height);
			_canvasBitmapData.fillRect(_rect, 0xFF000000);	// 表示用 BitmapData の初期化
			divideCheck(_rect);
			
			return _canvasBitmapData;
		}
		
		
		// 再帰処理
		private function divideCheck(rect:Rectangle):void {
			// Rectangle を共用変数に格納（以下、getStandardDeviation, getAverageColor では _rect を使用する）
			_rect = rect;
			// 現在のチェック対象矩形の縦または横の長さが指定より小さい場合、再帰を停止させる
			var isDivide:Boolean = (_rect.width <= LIMIT_OF_MINIMUN || _rect.height <= LIMIT_OF_MINIMUN) ? false : true;
			// 再帰判定
			if (isDivide) {
				var deviation:Number = getStandardDeviation();
				if (deviation > THRESHOLD) {
					// 標準偏差が指定より大きい場合、4分木再帰を続行
					var halfWidth:Number  = _rect.width / 2;
					var halfHeight:Number = _rect.height / 2;
					var left:Number = _rect.x;
					var top:Number  = _rect.y;
					var center:Number = left + halfWidth;
					var middle:Number = top  + halfHeight;
					// 4分木再帰
					divideCheck(new Rectangle(left,   top,    halfWidth, halfHeight));
					divideCheck(new Rectangle(center, top,    halfWidth, halfHeight));
					divideCheck(new Rectangle(left,   middle, halfWidth, halfHeight));
					divideCheck(new Rectangle(center, middle, halfWidth, halfHeight));
				} else {
					// 標準偏差が指定より小さい場合、再帰を停止し、描画をおこなう
					draw();
				}
			} else {
				draw();
			}
		}
		

		// 対象 BitmapData の指定矩形範囲の標準偏差を求める（グレイスケール bitmapData を使用）
		private function getStandardDeviation():Number {
			_numOfPixel = _rect.width * _rect.height;		// 走査範囲のピクセル数
			_histVector = _grayBitmapData.histogram(_rect);	// 走査範囲のヒストグラム
			var vector:Vector.<Number> = _histVector[0];	// グレイスケールなので一つだけで処理
			var sum:Number = 0;								// 累積用変数
			
			// 輝度の平均を求める
			for (var i:int = 0; i < 256; i++) {
				sum += vector[i] * i;
			}
			var average:Number = sum / _numOfPixel;
			
			// 平均との差の二乗を累積
			var diff:Number;
			sum = 0;
			for (i = 0; i < 256; i++) {
				diff =  i - average;
				sum += diff * diff * vector[i];
			}
			return Math.sqrt(sum / _numOfPixel);
		}
		
		// キャンバスに描画
		private function draw():void {
			var rect:Rectangle = new Rectangle(_rect.x + 0.5, _rect.y + 0.5, _rect.width - 1, _rect.height - 1);
			_canvasBitmapData.fillRect(rect, getAverageColor());
		}
		
		// 対象 BitmapData の指定矩形範囲の平均色を求める（カラー bitmapData を使用）
		private function getAverageColor():uint {
			_numOfPixel = _rect.width * _rect.height;		// 走査範囲のピクセル数
			_histVector = _colorBitmapData.histogram(_rect);// 走査範囲のヒストグラム
			var sumVector:Vector.<Number> = new Vector.<Number>(3, true);	// 累積用変数格納 Vector
			
			// r, g, b それぞれの平均値を求める
			for (var i:int = 0; i < 256; i++) {
				for (var j:int = 0; j < 3; j++) {
					sumVector[j] += _histVector[j][i] * i;
				}
			}
			var r:uint = sumVector[0] / _numOfPixel;
			var g:uint = sumVector[1] / _numOfPixel;
			var b:uint = sumVector[2] / _numOfPixel;
			
			// Math.min(value, 0xFF)
			// http://www.be-interactive.org/index.php?itemid=519
			r = (r | (((r & 0xFFFFFF00) + 0x7FFFFFFF) >> 31)) & 0xFF;
			g = (g | (((g & 0xFFFFFF00) + 0x7FFFFFFF) >> 31)) & 0xFF;
			b = (b | (((b & 0xFFFFFF00) + 0x7FFFFFFF) >> 31)) & 0xFF;
			
			return 0xFF << 24 | r << 16 | g << 8 | b;
		}
		
		
		// グレイスケール
		// Foundation ActionScript 3.0 Image Effects(P106)
		// http://www.amazon.co.jp/gp/product/1430218711?ie=UTF8&tag=laxcomplex-22
		// （NTSC 系加重平均）
		private function grayscale(bitmapData:BitmapData):void {
			var matrix:Array = [
				0.3, 0.59, 0.11, 0, 0,
				0.3, 0.59, 0.11, 0, 0,
				0.3, 0.59, 0.11, 0, 0,
				0,   0,    0,    1, 0
			];
			bitmapData.applyFilter(bitmapData, bitmapData.rect, new Point(), new ColorMatrixFilter(matrix));
		}
	}

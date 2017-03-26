package {
	import flash.display.Sprite;
	[SWF(width = "465", height = "465", frameRate = "60", backgroundColor = "#FFFFFF")]
	/**
	 * 二つのアルゴリズムによる平面分割の比較
	 * fladdict:http://fladdict.net/blog/2009/05/computer-painting.html
	 * Quasimondo:http://www.flickr.com/photos/quasimondo/4251382278/in/set-72057594062596732/
	 * 解説：http://aquioux.blog48.fc2.com/blog-entry-705.html
	 * @author Aquioux(Yoshida, Akio)
	 */
	public class Main extends Sprite {
		
		public function Main():void {
			Wonderfl.capture_delay(15);

			// model
			var model:Model = new Model();
			
			// _view
			var view:View = new View(model);
			addChild(view);
			
			// controller
			var controller:Controller = new Controller(model);
			addChild(controller);
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
	import flash.geom.Rectangle;
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
		static public const MAX_SIZE:uint = 420;

		// 完了した処理の種別
		static public const LOAD:String   = "load";
		static public const EFFECT:String = "effected";
		
		// エフェクトの種別
		static public const EFFECT1:String = "by fladdict logic";
		static public const EFFECT2:String = "by Quasimondo logic";
		
		// 外部へ通知する完了した処理の種別
		public function get state():String { return _state; }
		private var _state:String;

		// View へ渡すデータ
		public function get data():BitmapData { return _data; }
		private var _data:BitmapData;
		

		// ---------- ローカルプロパティ ----------
		//
		// ファイルロード関連
		private var fileRef_:FileReference;
		private var loader_:Loader;
		
		// BitmapData
		private var colorBmd_:BitmapData;	// フルカラー BitmapData（buffer）
		private var grayBmd_:BitmapData		// グレイスケール BitmapData
		private var rect_:Rectangle;		// 上記の 3 BitmapData （_data も含む）共用の Rectangle
		
		// effector
		private var smooth_:Smooth;
		private var grayscale_:GrayScale;
		private var binarize_:Binarize;
		private var edge_:Edge2;
		private var divider_:SubDivider3;
		
		private var size_:uint = 5;		// 分割最小値
		

		// ---------- パブリックメソッド ----------
		//
		/**
		 * コンストラクタ
		 */
		public function Model() {
			// ファイルロード関連
			fileRef_ = new FileReference();
			loader_  = new Loader();
			
			// エフェクタ
			smooth_ = new Smooth();
			grayscale_ = new GrayScale();
			binarize_ = new Binarize();
			binarize_.auto = true;
			edge_ = new Edge2();
			divider_ = new SubDivider3();
		}
		
		/**
		 * Controller 向けに開かれたメソッド
		 * 画像ロード step 1 ファイル選択
		 */
		public function loadHandler():void {
			fileRef_.addEventListener(Event.SELECT, load2Handler);
			fileRef_.browse();
		}
		/**
		 * Controller 向けに開かれたメソッド
		 * 画像にエフェクト適用
		 */
		public function effectHandler(state:String):void {
			_data.fillRect(rect_, 0xFF000000);
			
			if (state == EFFECT1) {
				grayBmd_ = colorBmd_.clone();
				grayscale_.applyEffect(grayBmd_);
			}
			if (state == EFFECT2) {
				binarize_.applyEffect(grayBmd_);
				edge_.applyEffect(grayBmd_);
			}
			divider_.applyEffect(rect_, colorBmd_, grayBmd_, _data, 15, size_);

			// CHANGE イベント発行
			_state = EFFECT;
			dispatchEvent(new Event(Event.CHANGE));
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
			_state = LOAD;
			update(Bitmap(loader_.content).bitmapData);
		}
		// _data のアップデート
		private function update(bmd:BitmapData):void {
			// 読み込んだ画像ファイルの BitmapData の処理
			var w:uint = bmd.width;
			var h:uint = bmd.height;
			var scale:Number = Math.min(MAX_SIZE / w, MAX_SIZE / h);
			//if (scale > 1) scale = 1;
			if (_data) initBmds();
			_data = new BitmapData(w * scale, h * scale);
			_data.draw(bmd, new Matrix(scale, 0, 0, scale));
			rect_ = _data.rect;
			
			colorBmd_ = _data.clone();
			smooth_.applyEffect(colorBmd_);
			grayBmd_ = colorBmd_.clone();
			grayscale_.applyEffect(grayBmd_);
			
			// CHANGE イベント発行
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		private function initBmds():void {
			_data.dispose();
			colorBmd_.dispose();
			grayBmd_.dispose();
			_data      = null;
			colorBmd_  = null;
			grayBmd_   = null;
		}
	}


	import com.bit101.components.Label;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
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
		private var bm_:Bitmap;			// メイン表示 Bitmap
		private var bmd_:BitmapData;	// メイン表示 Bitmap 用の BitmapData
		

		// ---------- パブリックメソッド ----------
		//
		/**
		 * コンストラクタ
		 * @param	model	Model
		 */
		public function View(model:Model) {
			_model = model;
			_model.addEventListener(Event.CHANGE, changeHandler);
			
			bm_ = new Bitmap();
			addChild(bm_);
		}
		

		// ---------- ローカルメソッド ----------
		//
		// Model から Event.CHANGE が発行されたときの処理（ロード時の処理）
		private function changeHandler(e:Event):void {
			if (_model.state == Model.LOAD) {
				bmd_ = _model.data;
				bm_.bitmapData = bmd_;
				bm_.smoothing = true;
				bm_.x = uint((stage.stageWidth  - bm_.width)  / 2);
				bm_.y = uint((stage.stageHeight - bm_.height) / 2);
			}
		}
	}


	import com.bit101.components.PushButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
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
		private var effectButton1_:PushButton;	// 効果適用ボタン1
		private var effectButton2_:PushButton;	// 効果適用ボタン2
		
		private var prevSelected_:PushButton;	// 前に選んだボタン
		
		private const SELECTED:ColorTransform = new ColorTransform(1, 1, 1, 1, 255, 0, 0, 0);
		private const DEFAULT:ColorTransform  = new ColorTransform(1, 1, 1, 1, 0, 0, 0, 0);


		// ---------- パブリックメソッド ----------
		//
		/**
		 * コンストラクタ
		 * @param	model	Model
		 */
		public function Controller(model:Model) {
			_model = model;
			_model.addEventListener(Event.CHANGE, changeHandler);
			
			// ボタンの幅
			var buttonWidth:uint = 50;
			// ロードのボタン
			loadButton_ = new PushButton(this, 0, 0, "LOAD", loadHandler);
			loadButton_.width = buttonWidth;
			// 効果適用ボタン
			effectButton1_ = new PushButton(this, loadButton_.x+loadButton_.width, 0, Model.EFFECT1, effectHandler);
			effectButton1_.width = buttonWidth * 2;
			effectButton2_ = new PushButton(this, effectButton1_.x + effectButton1_.width, 0, Model.EFFECT2, effectHandler);
			effectButton2_.width = buttonWidth * 2;
			buttonEbled(effectButton1_, false);
			buttonEbled(effectButton2_, false);
		}
		

		// ---------- ローカルメソッド ----------
		//
		// ロードボタンのイベントハンドラ
		private function loadHandler(e:MouseEvent):void {
			if (prevSelected_) prevSelected_.transform.colorTransform = DEFAULT;
			_model.loadHandler();
		}
		
		private function effectHandler(e:MouseEvent):void {
			// 今、選んだボタン
			var target:PushButton = PushButton(e.target);
			target.transform.colorTransform = SELECTED;
			buttonEbled(target, false);
			// 直前に選んだボタン
			if (prevSelected_) {
				prevSelected_.transform.colorTransform = DEFAULT;
				buttonEbled(prevSelected_, true);
			}
			
			prevSelected_ = target;
			_model.effectHandler(target.label);
		}

		// Model から Event.CHANGE が発行されたときの処理
		private function changeHandler(e:Event):void {
			if (_model.state == Model.LOAD) {
				// 画像ロード完了時
				buttonEbled(effectButton1_, true);
				buttonEbled(effectButton2_, true);
			}
		}
		
		// ボタンの使用可否切り替え
		private function buttonEbled(button:PushButton, flg:Boolean):void {
			button.mouseEnabled = flg;
			button.alpha = flg ? 1.0 : 0.5;
		}
	}


	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.geom.Rectangle;
	/**
	 * 画面分割
	 * @author YOSHIDA, Akio (Aquioux)
	 */
	class SubDivider3 {
		// ---------- ローカルプロパティ ----------
		//
		// 共用 Rectangle
		private var nextRect_:Rectangle = new Rectangle();	// 4分木再帰処理に使用
		private var drawRect_:Rectangle = new Rectangle();	// 描画に使用
		
		// ヒストグラムから濃度の合計値を求める関数
		private const GET_BRIGHTNESS:Function = EffectorUtils.getSumOfBrightness3;
		

		// ---------- パブリックメソッド ----------
		//
		/*
		 * コンストラクタ
		 */
		public function SubDivider3() {
		}
		
		/*
		 * 効果適用
		 * @param	rect	現在の対象 Rectangle
		 * @param	color	効果対象 BitmapData（カラー）
		 * @param	gray	効果対象 BitmapData（モノクロ）
		 * @param	canvas	描画 BitmapData
		 * @param	threshold	分割閾値
		 * @param	minSize	分割サイズ最小値
		 */
		public function applyEffect(rect:Rectangle, color:BitmapData, gray:BitmapData, canvas:BitmapData, threshold:uint, minSize:uint):void {
			// 現在のチェック対象矩形の縦または横の長さが指定より小さい場合、再帰を停止
			var isDivide:Boolean = rect.width > minSize && rect.height > minSize;
			
			// 走査範囲のピクセル数
			var numOfPixel:uint = rect.width * rect.height;
			
			// 再帰判定
			if (isDivide) {
				// 走査範囲のヒストグラム（グレイスケール）
				var histGray:Vector.<Vector.<Number>> = gray.histogram(rect);
				// 濃度の標準偏差
				var deviation:Number = getStandardDeviation(histGray[0], numOfPixel);
				if (deviation > threshold) {
					// 標準偏差が指定より大きい場合、4分木再帰を続行
					// Rectangle の x、y、width、height が　uint になるようにする
					// （numOfPixel と齟齬が出ないようにするため）
					var nextWidth1:uint  = rect.width / 2 >> 0;
					var nextHeight1:uint = rect.height / 2 >> 0;
					var nextWidth2:uint  = rect.width  - nextWidth1;
					var nextHeight2:uint = rect.height - nextHeight1;
					var left:Number = rect.x;
					var top:Number  = rect.y;
					var center:Number = left + nextWidth1;
					var middle:Number = top  + nextHeight1;
					var xs:Vector.<uint> = Vector.<uint>([left, center, left, center]);
					var ys:Vector.<uint> = Vector.<uint>([top, top, middle, middle]);
					var ws:Vector.<uint> = Vector.<uint>([nextWidth1, nextWidth2, nextWidth1, nextWidth2]);
					var hs:Vector.<uint> = Vector.<uint>([nextHeight1, nextHeight1, nextHeight2, nextHeight2]);
					// 4分木再帰
					for (var i:int = 0; i < 4; i++) {
						nextRect_.x = xs[i];
						nextRect_.y = ys[i];
						nextRect_.width  = ws[i];
						nextRect_.height = hs[i];
						applyEffect(nextRect_, color, gray, canvas, threshold, minSize);
					}
				} else {
					// 標準偏差が指定より小さい場合、再帰を停止し、描画をおこなう
					isDivide = false;
				}
			}
			
			// 描画
			if (!isDivide) {
				var histColor:Vector.<Vector.<Number>> = color.histogram(rect);	// 走査範囲のヒストグラム（カラー）
				draw(rect, histColor, numOfPixel, canvas);
			}
		}
		

		// ---------- ローカルメソッド ----------
		//
		// 対象 BitmapData の指定矩形範囲の標準偏差を求める
		private function getStandardDeviation(hist:Vector.<Number>, numOfPixel:uint):Number {
			var sum:Number = 0;		// 累積用変数
			
			// 輝度の平均を求める
			for (var i:int = 0; i < 256; i++) {
				sum += hist[i] * i;
			}
			var average:Number = sum / numOfPixel;	// 平均値
			
			// 平均との差の二乗を累積
			var diff:Number;
			sum = 0;
			for (i = 0; i < 256; i++) {
				diff =  i - average;
				sum += diff * diff * hist[i];
			}
			
			return Math.sqrt(sum / numOfPixel);
		}
		
		// キャンバスに描画
		private function draw(rect:Rectangle, hist:Vector.<Vector.<Number>>, numOfPixel:uint, canvas:BitmapData):void {
			var sum:Vector.<uint> = GET_BRIGHTNESS(hist);
			var r:uint = sum[0] / numOfPixel;
			var g:uint = sum[1] / numOfPixel;
			var b:uint = sum[2] / numOfPixel;
			var c:uint = 0xFF << 24 | r << 16 | g << 8 | b;

			drawRect_.x = rect.x + 1;
			drawRect_.y = rect.y + 1;
			drawRect_.width  = rect.width  - 1;
			drawRect_.height = rect.height - 1;
			canvas.fillRect(drawRect_, c);
		}
	}


	import flash.display.BitmapData;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Point;
	/**
	 * ColorMatrixFilter による BitmapData のグレイスケール化（NTSC 系加重平均による）
	 * 参考：Foundation ActionScript 3.0 Image Effects(P106)
	 * 		http://www.amazon.co.jp/gp/product/1430218711?ie=UTF8&tag=laxcomplex-22
	 * @author YOSHIDA, Akio (Aquioux)
	 */
	class GrayScale implements IEffector {
		// ---------- ローカルプロパティ ----------
		//
		private const MATRIX:Array = [
			0.3, 0.59, 0.11, 0, 0,
			0.3, 0.59, 0.11, 0, 0,
			0.3, 0.59, 0.11, 0, 0,
			0,   0,    0,    1, 0
		];
		private const FILTER:ColorMatrixFilter = new ColorMatrixFilter(MATRIX);
		
		private const ZERO_POINT:Point = EffectorUtils.ZERO_POINT;

		
		// ---------- パブリックメソッド ----------
		//
		/*
		 * 効果適用
		 * @param	value	効果対象 BitmapData
		 */
		public function applyEffect(value:BitmapData):BitmapData {
			value.applyFilter(value, value.rect, ZERO_POINT, FILTER);
			return value;
		}
	}


	import flash.display.BitmapData;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.BlurFilter;
	import flash.geom.Point;
	/**
	 * BlurFilter による平滑化
	 * @author YOSHIDA, Akio (Aquioux)
	 */
	class Smooth implements IEffector {
		// ---------- パブリックプロパティ ----------
		//
		/*
		 * ぼかしの強さ
		 * @param	value	数値
		 */
		public function set strength(value:Number):void {
			filter_.blurX = filter_.blurY = value;
		}
		/*
		 * ぼかしの質
		 * @param	value	数値
		 */
		public function set quality(value:int):void {
			filter_.quality = value;
		}


		// ---------- ローカルプロパティ ----------
		//
		private var filter_:BlurFilter;		// ブラーフィルタ
		private const ZERO_POINT:Point = EffectorUtils.ZERO_POINT;


		// ---------- パブリックメソッド ----------
		//
		/*
		 * コンストラクタ
		 */
		public function Smooth() {
			filter_ = new BlurFilter(2, 2, BitmapFilterQuality.MEDIUM);
		}
		
		/*
		 * 効果適用
		 * @param	value	効果対象 BitmapData
		 */
		public function applyEffect(value:BitmapData):BitmapData {
			value.applyFilter(value, value.rect, ZERO_POINT, filter_);
			return value;
		}
	}


	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	/**
	 * 二値化
	 * 閾値より大きな値のピクセルは白、それ以外は黒に置き換える
	 * @author YOSHIDA, Akio (Aquioux)
	 */
	class Binarize implements IEffector {
		// ---------- パブリックプロパティ ----------
		//
		// 閾値
		public function get threshold():int { return _threshold; }
		public function set threshold(value:int):void {
			if (value < 0)   value = 0;
			if (value > 255) value = 255;
			_threshold = value;
		}
		private var _threshold:int = 127;	// 閾値：0 ～ 255
		
		public function get auto():Boolean { return _auto; }
		public function set auto(value:Boolean):void { _auto = value; }
		private var _auto:Boolean = false;


		// ---------- ローカルプロパティ ----------
		//
		private const ZERO_POINT:Point = EffectorUtils.ZERO_POINT;

		
		// ---------- パブリックメソッド ----------
		//
		/*
		 * 効果適用
		 * @param	value	効果対象 BitmapData
		 */
		public function applyEffect(value:BitmapData):BitmapData {
			var bufferBmd:BitmapData = new BitmapData(value.width, value.height);
			var rect:Rectangle = bufferBmd.rect;
			bufferBmd = value.clone();

			if (_auto) {
				var hist:Vector.<Vector.<Number>> = value.histogram();
				var numOfPixel:uint = rect.width * rect.height;
				_threshold = calcThresholdRough(hist[2], numOfPixel);
			}
			
			value.fillRect(rect, 0xFF000000);
			value.threshold(bufferBmd, rect, ZERO_POINT, ">", _threshold, 0xFFFFFFFF, 0x000000FF, false);
			return value;
		}

		
		// ---------- ローカルメソッド ----------
		//
		// 閾値の判別分析
		private function calcThresholdRough(hist:Vector.<Number>, numOfPixel:uint):uint {
			var total:uint;
			for (var i:int = 0; i < 256; i++) {
				total += hist[i] * i;
			}
			return total / numOfPixel >> 0;
		}
		
		// 閾値の判別分析
		private function calcThresholdStrict(hist:Vector.<Number>, numOfPixel:uint):uint {
			var maxSeparability:Number  = 0;	// 最大分離値を待避させる変数
			var maxDegree:uint = 0;				// そのときの階調を待避させる変数
			for (var i:int = 1; i < 255; i++) {
				// 1～254 を閾値としたときの分離度を計算し、最大値を待避する
				var Separability:Number = calcSeparability(i, hist, numOfPixel);
				if (Separability > maxSeparability) {
					maxSeparability = Separability;
					maxDegree       = i;
				}
			}
			return maxDegree;
		}
		// 分離度の計算
		private function calcSeparability(threshold:uint, hist:Vector.<Number>, numOfPixel:uint):Number {
			var i:uint;								// ループカウンター
			var num1:uint = 0, num2:uint = 0;		// 各領域の画素数
			var con1:Number = 0, con2:Number = 0;	// 各領域の濃度（濃度平均値）
			var con:Number = 0;						// 濃度中間値
			var dis1:Number, dis2:Number;			// 分散計算用
			var within:Number = 0;					// クラス内分散値
			var between:Number = 0;					// クラス間分散値
			
			// 二つの領域の画素数と濃度を計算
			for (i = 0; i < threshold; i++) {
				num1 += hist[i];
				con1 += i * hist[i];
			}
			for (i = threshold; i < 256; i++) {
				num2 += hist[i];
				con2 += i * hist[i];
			}
			con = (con1 + con2) / numOfPixel;	// 濃度中間値
			con1 /= num1;	// 領域1の濃度平均値
			con2 /= num2;	// 領域2の濃度平均値

			if (num1 == 0 || num2 == 0) return 0;
			
			// 分散を計算
			// クラス内分散
			for (i = 0; i < threshold; i++) {
				dis1 = i - con1;
				within += dis1 * dis1 * hist[i];
			}
			for (i = threshold; i < 256; i++) {
				dis2 = i - con2;
				within += dis2 * dis2 * hist[i];
			}
			within /= numOfPixel;
			// クラス間分散
			for (i = 0; i < threshold; i++) {
				dis1 = con - con1;
				between += dis1 * dis1 * hist[i];
			}
			for (i = threshold; i < 256; i++) {
				dis2 = con - con2;
				between += dis2 * dis2 * hist[i];
			}
			between /= numOfPixel;
			
			return between / within;
		}
	}


	import flash.display.BitmapData;
	import flash.filters.ConvolutionFilter;
	import flash.geom.Point;
	/**
	 * ConvolutionFilter によるエッジ検出　2次微分
	 * 「OpenGL+GLSLによる画像処理プログラミング」 工学社　酒井幸市　P104　「5.1 差分フィルタ」
	 * 「C言語で学ぶ実践画像処理」 オーム社 井上誠喜・他 P47 「4.7 ラプラシアンとゼロ交差により輪郭線を求める」
	 * http://msdn.microsoft.com/ja-jp/academic/cc998604.aspx
	 * @author YOSHIDA, Akio (Aquioux)
	 */
	class Edge2 {
		// ---------- ローカルプロパティ ----------
		//
		private const MATRIX:Array = [
			-1, -1, -1,
			-1,  8, -1,
			-1, -1, -1
		];
		private const FILTER:ConvolutionFilter = new ConvolutionFilter(3, 3, MATRIX);

		private const ZERO_POINT:Point = EffectorUtils.ZERO_POINT;

		
		// ---------- パブリックメソッド ----------
		//
		/*
		 * 効果適用
		 * @param	value	効果対象 BitmapData
		 */
		public function applyEffect(value:BitmapData):BitmapData {
			value.applyFilter(value, value.rect, ZERO_POINT, FILTER);
			return value;
		}
	}


	import flash.display.BitmapData;
	/**
	 * BitmapDataEffector 用 interface
	 * @author YOSHIDA, Akio (Aquioux)
	 */
	interface IEffector {
		function applyEffect(value:BitmapData):BitmapData;
	}


	import flash.geom.Point;
	/**
	 * bitmapDataEffector パッケージ内のクラスで共通に使う定数など
	 * @author YOSHIDA, Akio (Aquioux)
	 */
	class EffectorUtils {
		// ---------- パブリックプロパティ ----------
		//
		// BitmapData が備える各種メソッドの destPoint 用
		static public const ZERO_POINT:Point = new Point(0, 0);

		
		// ---------- パブリックメソッド ----------
		//
		// 一つのチャンネルにおける濃度の平均値を求める（引数のヒストグラムで調整する）
		static public function getAverageOfBrightness1(hist:Vector.<Number>):uint {
			var sum:uint = 0;
			var numOfPixel:uint = 0;
			for (var i:int = 0; i < 256; i++) {
				sum        += i * hist[i];
				numOfPixel += hist[i];
			}
			return sum / numOfPixel >> 0;
		}
		// RGB チャンネルにおける濃度の各平均値を求める
		static public function getAverageOfBrightness3(hist:Vector.<Vector.<Number>>):Vector.<uint> {
			var rSum:uint = 0;
			var gSum:uint = 0;
			var bSum:uint = 0;
			var numOfPixel:uint = 0;
			for (var i:int = 0; i < 256; i++) {
				rSum += i * hist[0][i];
				gSum += i * hist[1][i];
				bSum += i * hist[2][i];
				numOfPixel += hist[0];
			}
			return Vector.<uint>([rSum / numOfPixel >> 0, gSum / numOfPixel >> 0, bSum / numOfPixel >> 0]);
		}
		
		// 一つのチャンネルにおける濃度の平均値を求める（引数のヒストグラムで調整する）
		static public function getSumOfBrightness1(hist:Vector.<Number>):uint {
			var sum:uint = 0;
			for (var i:int = 0; i < 256; i++) {
				sum += i * hist[i];
			}
			return sum;
		}
		// RGB チャンネルにおける濃度の各平均値を求める
		static public function getSumOfBrightness3(hist:Vector.<Vector.<Number>>):Vector.<uint> {
			var rSum:uint = 0;
			var gSum:uint = 0;
			var bSum:uint = 0;
			for (var i:int = 0; i < 256; i++) {
				rSum += i * hist[0][i];
				gSum += i * hist[1][i];
				bSum += i * hist[2][i];
			}
			return Vector.<uint>([rSum, gSum, bSum]);
		}
	}

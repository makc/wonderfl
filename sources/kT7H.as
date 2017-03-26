package {
	import flash.display.Sprite;
	import flash.events.Event;
	import net.hires.debug.Stats;
	/**
	 * Saqoosha 先生による煌めきエフェクトの俺用テンプレート
	 * @author YOSHIDA, Akio (Aquioux)
	 */
	[SWF(width = "465", height = "465", frameRate = "30", backgroundColor = "#000000")]
	
	public class Main extends Sprite {
		public function Main() {
			// Model を生成
			var model:Model = new Model(10000);
			model.setup(stage);

			// View を生成
			var view:View = new View(model);
			addChild(view);
			
			addChild(new Stats());
		}
	}
}


	/**
	 * Model
	 */
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	class Model extends EventDispatcher {
		// 外部へ渡すデータ
		// X座標、Y座標、色の順番の1次元 Vector
		public function get data():Vector.<Number> { return _data; }
		private var _data:Vector.<Number>;
		// 上記 Vector の1次元にする要素数
		public const NUM_OF_BLOCK:uint = 3;
		
		// 外部から受けるデータ
		// 引数として受ける
		private var numOfParticle:uint;
		
		// 内部で使用するデータ
		private var particles:Array;
		
		// ENTER_FRAME のタイミングで呼び出される
		internal function update(event:Event):void {
			var n:uint = numOfParticle;
			var nob:uint = NUM_OF_BLOCK;
			var range2:Number = 6;
			var range1:Number = range2 / 2;
			for (var i:int = 0; i < n; i++) {
				var p:Particle2D = particles[i];
				p.x += Math.random() * range2 - range1;
				p.y += Math.random() * range2 - range1;
				_data[i * nob]     = p.x;
				_data[i * nob + 1] = p.y;
				_data[i * nob + 2] = p.color;
			}
			
			// リスナー（View）へ通知
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		
		public function Model(numOfParticle:uint) {
			// 外部から受けるデータを引数として受ける
			this.numOfParticle = numOfParticle;
			// 外部に渡すデータの初期化
			_data = new Vector.<Number>(this.numOfParticle * NUM_OF_BLOCK, true);
		}
		
		public function setup(stage:Stage):void {
			var x:Number = stage.stageWidth / 2;
			var y:Number = stage.stageHeight / 2;
			particles = [];
			for (var i:int = 0; i < this.numOfParticle; i++) {
				particles[i] = new Particle2D(x, y, Math.random() * 0xFFFFFF >> 0);
			}
			
			stage.addEventListener(Event.ENTER_FRAME, update);
		}
	}


	/**
	 * View
	 */
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	class View extends Sprite {
		private const SCALE:Number = 15;
		private const COLOR_TRANSFORM:ColorTransform = new ColorTransform(0.95, 0.95, 0.95, 0.95);
		
		private function changeHandler(event:Event):void {
			// Model からデータを受ける
			var data:Vector.<Number> = model.data;

			// 描画
			canvas.lock();
			canvas.fillRect(canvas.rect, 0x000000);
			var n:uint = data.length / numOfBlock;
			for (var i:int = 0; i < n; i++) {
				var posX:Number  = data[i * numOfBlock];
				var posY:Number  = data[i * numOfBlock + 1];
				var color:Number = data[i * numOfBlock + 2];
				canvas.setPixel(posX, posY, color);
			}
			canvas.colorTransform(canvas.rect, COLOR_TRANSFORM);
			canvas.unlock();
			twincles.draw(canvas, twinklesMatrix);
		}

		private var model:Model;
		public function View(model:Model) {
			this.model = model;
			this.model.addEventListener(Event.CHANGE, changeHandler);
			addEventListener(Event.ADDED_TO_STAGE, setup);
		}
		private var numOfBlock:uint;        // イテレート要素数
		private var canvas:BitmapData;		// 一般キャンバス
		private var twincles:BitmapData;	// 煌きキャンバス
		private var twinklesMatrix:Matrix;	// 煌きキャンバス用 Matrix
		private function setup(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, setup);
			
			numOfBlock = model.NUM_OF_BLOCK;
			
			// 一般キャンバスの生成
			canvas = new BitmapData(stage.stageWidth, stage.stageHeight, false);
			var canvasBitmap:Bitmap = new Bitmap(canvas);
			canvasBitmap.smoothing = true;
			addChild(canvasBitmap);

			// 煌きキャンバスの生成
			twincles = new BitmapData(stage.stageWidth / SCALE >> 0, stage.stageHeight / SCALE >> 0, false);
			twinklesMatrix = new Matrix(1 / SCALE, 0, 0, 1 / SCALE);
			var twinklesBitmap:Bitmap = new Bitmap(twincles);
			twinklesBitmap.scaleX = twinklesBitmap.scaleY = SCALE;
			twinklesBitmap.smoothing = true;
			//twinklesBitmap.blendMode = BlendMode.LIGHTEN;
			twinklesBitmap.blendMode = BlendMode.ADD;
			addChild(twinklesBitmap);
		}
	}


	/**
	 * 2次元用パーティクル
	 */
	class Particle2D {
		// X座標
		public var x:Number;
		// Y座標
		public var y:Number;
		// 色
		public var color:uint;
		
		public function Particle2D(x:Number = 0, y:Number = 0, color:uint = 0) {
			this.x = x;
			this.y = y;
			this.color = color;
		}
	}

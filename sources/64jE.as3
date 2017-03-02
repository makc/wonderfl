package {
    
	/*
	 若干立体感のある、雲っぽい映像を作るよ。
	 はっきり言って重いので、実用性がちょっと無いよ！！
	 その代わり、リアルタイムで色合いとか変えられるから、時間に合わせて夕焼けになったりできるかも。
	 
	 仕組み的にはPhotoShopでの常套手段をFlashで再現したもの。
	 数値を変えるとかなりリアルなのも作れるけど、これ以上立体感を出すには他の工夫が必要。
	 台形変形とか、影の位置をずらしたりとかできれば・・・。
	 
	 雲模様の生成が遅いのはなんとかならないかな～
	 １オクターブずつ用意して、横にずれた分だけを新しく生成するとかさ。
	 ちょっと考えてみたけど頭痛くなったからやらなかったよ。
	 */
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.display.BlendMode;
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.filters.DisplacementMapFilter;
	import flash.filters.DisplacementMapFilterMode;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import net.hires.debug.Stats;

	public class CloudEffect1 extends Sprite
	{
		public static const STAGE_W:uint = 465;
		public static const STAGE_H:uint = 465;
		
		public static const _H_RATE:Number = 2;	// 上下の圧縮割合
		
		// 雲模様関係
		private var _perlinNoiseBitmapData:BitmapData;
		private var _seed:int = Math.random()*int.MAX_VALUE;
		private var _perlinNoiseSize:Number = 0.25;	// 雲模様を画面全体に描画するのは重くて無理なので、サイズを減らす。
		private var _perlinNoiseSizeW:int = STAGE_W*_perlinNoiseSize;
		private var _perlinNoiseSizeH:int = STAGE_H*_perlinNoiseSize*_H_RATE;
		private var _cloudSize:int = _perlinNoiseSize * 240;
		private var _speedList:Point
		private var _octaves:int = 5;	// 雲模様オクターブ数。レイヤー数みたいなもの。多いほど細かいけど、死ぬほど重くなる。
		private var _offsetList:Array = [];	// 雲のズレ。オクターブの数だけPointが必要。
		private var _offsetSpeedList:Array = [0.5, 0.4, 0.3, 0.2, 0.15];	// 雲をずらす量。
		
		// 立体化関係
		private var _displacementBitmapData:BitmapData;
		private var _displacementMapFilter:DisplacementMapFilter;
		
		// 色変換関係
		private var _palletBitmapData:BitmapData;
		private var _pallet:Array = [];
		private var _nullPallet:Array = [];
		
		// 引き伸ばした画像データ
		private var _scaleChangeBitmapData:BitmapData;
		private var _scaleChangeMatrix:Matrix;
		
		// ちょっとしたカバー
		private var _cover:Sprite;
		
		// その他
		private var _rect:Rectangle = new Rectangle(0, 0, STAGE_W, STAGE_H);
		private var _point:Point = new Point(0, 0);
		private var _rectSmall:Rectangle = new Rectangle(0, 0, _perlinNoiseSizeW, _perlinNoiseSizeH);
		
		public function CloudEffect1()
		{
			addEventListener(Event.ADDED_TO_STAGE, init);	// flexBuilderとの互換性。
		}
		private function init(e:Event):void {	// ここから開始
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// SWF設定
			stage.frameRate = 30;
			stage.quality = StageQuality.HIGH;
			
			// 雲模様データを用意する
			_perlinNoiseBitmapData = new BitmapData(_perlinNoiseSizeW, _perlinNoiseSizeH, false);
			for (var i:int = 0; i < _octaves; i++) _offsetList.push(new Point());
			
			// 立体化データを用意する
			_displacementBitmapData = new BitmapData(STAGE_W, STAGE_H, false);
			_displacementMapFilter = new DisplacementMapFilter(null, _point, 0, BitmapDataChannel.RED, 0,
									 100, DisplacementMapFilterMode.CLAMP);
			
			// 色変換データを用意する
			_palletBitmapData = new BitmapData(STAGE_W, STAGE_H, false);
			createGradation();
			
			// サイズ
			_scaleChangeBitmapData = new BitmapData(STAGE_W, STAGE_H, false);
			_scaleChangeMatrix = new Matrix();
			_scaleChangeMatrix.scale(1/_perlinNoiseSize, 1/_perlinNoiseSize/_H_RATE);
			
			// 白っぽいカバー
			_cover = new Sprite();
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(STAGE_W, STAGE_H, Math.PI/2);
			_cover.graphics.beginGradientFill(GradientType.LINEAR, [0x666666, 0xaaaaaa], [1, 1], [128, 255], matrix);
			_cover.graphics.drawRect(0, 0, STAGE_W, STAGE_H);
			_cover.blendMode = BlendMode.OVERLAY;
			
			// 表示
			addChild(new Bitmap(_scaleChangeBitmapData));
			addChild(_cover);
			
			// Stats
			addChild(new Stats());
			
			addEventListener(Event.ENTER_FRAME, frame);
		}
		private function createGradation():void{	// グラデーションを作るよ
			var tmpShape:Shape = new Shape();
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(255, 0);
			var colorList:Array = [0xa7a7c4, 0xf3f8ff, 0xffffff, 0x418fdf];
			//var colorList:Array = [0x824229, 0xfb8f1b, 0xffc768, 0xa0afac];	// 夕焼けカラーパターン
			var alphaList:Array = [1,        1,        1,        1];
			var ratioList:Array = [0,        80,       100,      200];
			tmpShape.graphics.beginGradientFill(GradientType.LINEAR, colorList, alphaList, ratioList, matrix);
			tmpShape.graphics.drawRect(0, 0, 255, 1);
			var tmpBitmap:BitmapData = new BitmapData(255, 1, false);
			tmpBitmap.draw(tmpShape);
			for (var i:int=0; i<256; i++){
				_pallet.push(tmpBitmap.getPixel(i, 0));
				_nullPallet.push(0x000000);
			}
		}
		
		private function frame(event:Event):void{	
			for (var i:int = 0; i < _octaves; i++){	// 雲模様のオフセットを決める
				Point(_offsetList[i]).x += Number(_offsetSpeedList[i]);
			}
			// 雲模様を作成
			_perlinNoiseBitmapData.perlinNoise(_cloudSize, _cloudSize, _octaves, _seed, false, true, 0, true, _offsetList);
			// 立体感を出す
			_displacementMapFilter.mapBitmap = _perlinNoiseBitmapData;
			_displacementBitmapData.applyFilter(_perlinNoiseBitmapData, _rectSmall, _point, _displacementMapFilter);
			_displacementBitmapData.draw(_perlinNoiseBitmapData, null, null, BlendMode.HARDLIGHT);
			// パレットマップで変換
			_palletBitmapData.paletteMap(_displacementBitmapData, _rectSmall, _point, _pallet, _nullPallet, _nullPallet);
			// 引き伸ばす
			_scaleChangeBitmapData.draw(_palletBitmapData, _scaleChangeMatrix, null, null, null, true);
			
		}
		
	}
}
// forked from paq's fork of tail_y's CloudEffect
package
{
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
        /*
         びかーっとさせてみた。
         重いよ！！
        */
	
	import flash.display.*;
	import flash.events.*;
	import flash.filters.*;
	import flash.geom.*;

	[SWF (width="465", height="465")]
	public class SmolderEffect extends Sprite
	{
		public static const STAGE_W:uint = 465;
		public static const STAGE_H:uint = 465;
		
		public static const _H_RATE:Number = 4;	// 上下の圧縮割合
		
		// 雲模様関係
		private var _perlinNoiseBitmapData:BitmapData;
		private var _seed:int = Math.random()*int.MAX_VALUE;
		private var _perlinNoiseSize:Number = 0.20;	// 雲模様を画面全体に描画するのは重くて無理なので、サイズを減らす。
		private var _perlinNoiseSizeW:int = STAGE_W*_perlinNoiseSize;
		private var _perlinNoiseSizeH:int = STAGE_H*_perlinNoiseSize*_H_RATE;
		private var _cloudSize:int = _perlinNoiseSize * 100;
		private var _octaves:int = 4;	// 雲模様オクターブ数。レイヤー数みたいなもの。多いほど細かいけど、死ぬほど重くなる。
		private var _offsetList:Array = [];	// 雲のズレ。オクターブの数だけPointが必要。
		private var _offsetSpeedListX:Array = [0.4, 0.3, 0.2, -0.05];	// 雲をずらす量。
		private var _offsetSpeedListY:Array = [0.2, 0.1, -0.05, -0.1];
		
		// 立体化関係
		private var _displacementBitmapData:BitmapData;
		private var _displacementMapFilter:DisplacementMapFilter;
		private var _offsetMatrix:Matrix;
		
		// 射光関係
		private var _brightLength:uint = 8;
		private var _brightMatrices:Vector.<Matrix>;
		private var _colorTransform1:ColorTransform = new ColorTransform(1.3, 1.3, 1.3, 1, 0, 0, 0, 0);
		private var _colorTransform2:ColorTransform = new ColorTransform(0.5, 0.5, 0.5, 1, 100, 100, 100, 0);
		private var _colorTransform3:ColorTransform = new ColorTransform(0.25, 0.25, 0.25, 1, 0, 0, 0, 0);
		private var _colorTransform4:ColorTransform = new ColorTransform(0.25, 0.25, 0.25, 1, -10, -10, -10, 0);
		
		// 色変換関係
		private var _paletteBitmapData:BitmapData;
		private var _palette:Array = [];
		private var _nullPalette:Array = [];
		
		// 引き伸ばした画像データ
		private var _scaleChangeBitmap:Bitmap;
		
		// ちょっとしたカバー
		private var _cover:Shape;
		
		// その他
		private var _point:Point = new Point(0, 0);
		private var _rectSmall:Rectangle = new Rectangle(0, 0, _perlinNoiseSizeW, _perlinNoiseSizeH);

		private var _shadow:Sprite;
		
		function SmolderEffect()
		{
			//Wonderfl.disable_capture();
			addEventListener(Event.ADDED_TO_STAGE, init);	// flexBuilderとの互換性。
		}
		
		// ここから開始
		private function init(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			var i:int;
						
			// 雲模様データを用意する
			_perlinNoiseBitmapData = new BitmapData(_perlinNoiseSizeW, _perlinNoiseSizeH, false);
			for (i = 0; i < _octaves; i++) {
				_offsetList.push(new Point());
			}
			
			// 立体化データを用意する
			_displacementBitmapData = new BitmapData(_perlinNoiseSizeW, _perlinNoiseSizeH, false);
			_displacementMapFilter = new DisplacementMapFilter(_perlinNoiseBitmapData, _point, 0, BitmapDataChannel.RED, 0,
									 -120, DisplacementMapFilterMode.CLAMP);
			_offsetMatrix = new Matrix();
			//_offsetMatrix.scale(1, 0.95);
			
			// 射光データを用意する
			_brightMatrices = new Vector.<Matrix>(_brightLength, false);
			for (i = 0; i < _brightLength; i++) _brightMatrices[i] = new Matrix();
			
			// 色変換データを用意する
			createGradation();
			
			// サイズ
			_scaleChangeBitmap = new Bitmap(_displacementBitmapData);
			_scaleChangeBitmap.scaleX = 1/_perlinNoiseSize;
			_scaleChangeBitmap.scaleY = 1/_perlinNoiseSize/_H_RATE;
			_scaleChangeBitmap.smoothing = true;
			
			// 白っぽいカバー
			_cover = new Shape();
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(_perlinNoiseSizeW, _perlinNoiseSizeH, Math.PI/2);
			_cover.graphics.beginGradientFill(GradientType.LINEAR, [0x808080, 0x202020], [1, 1], [128, 255], matrix);
			_cover.graphics.drawRect(0, 0, _perlinNoiseSizeW, _perlinNoiseSizeH);
			
			// 表示
			addChild(_scaleChangeBitmap);

			_shadow = new Sprite;
			var tmpm:Matrix = new Matrix; tmpm.createGradientBox (STAGE_W, STAGE_H, 0, -0.5 * STAGE_W, -0.5 * STAGE_H);
			_shadow.graphics.beginGradientFill (GradientType.RADIAL, [0xFFFFFF, 0], [1, 0.5], [0, 255], tmpm);
			_shadow.graphics.drawRect ( -STAGE_W, -STAGE_H, STAGE_W * 2, STAGE_H * 2);
			_shadow.blendMode = BlendMode.OVERLAY; addChild (_shadow); _shadow.startDrag (true);
			
			addEventListener(Event.ENTER_FRAME, frame);
		}
		
		// グラデーションを作るよ
		private function createGradation():void
		{
			var tmpShape:Shape = new Shape();
			var tmpBitmap:BitmapData = new BitmapData(256, 1, false);
			var matrix:Matrix = new Matrix();
			var colorList:Array = [0x100010, 0x301020, 0x602030, 0xD08040, 0xFFF080, 0xFFFFF0];
			var alphaList:Array = [1,        1,        1,        1,        1,        1];
			var ratioList:Array = [0,       20,       80,      160,      220,      255];
			
			matrix.createGradientBox(255, 0);
			tmpShape.graphics.beginGradientFill(GradientType.LINEAR, colorList, alphaList, ratioList, matrix);
			tmpShape.graphics.drawRect(0, 0, 256, 1);
			tmpBitmap.draw(tmpShape);
			
			for (var i:int=0; i<256; i++)
			{
				_palette.push(tmpBitmap.getPixel(i, 0));
				_nullPalette.push(0x000000);
			}
		}
		
		private function frame(event:Event):void
		{	
			var i:int;
			updateMatrices ();
			
			// 雲模様のオフセットを決める
			for (i = 0; i < _octaves; i++)
			{
				_offsetList[i].x += _offsetSpeedListX[i];
				_offsetList[i].y += _offsetSpeedListY[i];
			}
			
			// 雲模様を作成
			_perlinNoiseBitmapData.perlinNoise(_cloudSize, _cloudSize, _octaves, _seed, false, true, 0, true, _offsetList);
			
			_displacementBitmapData.lock();
			
			// 立体感を出す
			_displacementBitmapData.applyFilter(_perlinNoiseBitmapData, _rectSmall, _point, _displacementMapFilter);
			_displacementBitmapData.draw(_perlinNoiseBitmapData, null, _colorTransform1, BlendMode.HARDLIGHT);
			_displacementBitmapData.draw(_perlinNoiseBitmapData, _offsetMatrix, _colorTransform2, BlendMode.SUBTRACT);
			_displacementBitmapData.scroll(0, 20);
			_displacementBitmapData.fillRect(new Rectangle(0, 0, _displacementBitmapData.width, 20), 0x000000)
			_displacementBitmapData.draw(_perlinNoiseBitmapData, null, _colorTransform3, BlendMode.ADD);
			
			// 光らせる
			for (i = 0; i < _brightLength; i++) {
				_displacementBitmapData.draw(_displacementBitmapData, _brightMatrices[i], _colorTransform4, BlendMode.ADD, null, true);
			}
			
			// パレットマップで変換
			_displacementBitmapData.paletteMap(_displacementBitmapData, _rectSmall, _point, _palette, _nullPalette, _nullPalette);
			
			_displacementBitmapData.draw(_cover, null, null, BlendMode.OVERLAY);
			_displacementBitmapData.unlock();
		}

		private function updateMatrices ():void {
			// watch mouse
			for (var i:int = 0; i < _brightLength; i++)
			{
				var _x:Number = _perlinNoiseSizeW * mouseX / stage.stageWidth;
				var _y:Number = _perlinNoiseSizeH * mouseY / stage.stageHeight;
				_brightMatrices[i].identity ();
				_brightMatrices[i].translate(-_x, -_y);
				_brightMatrices[i].scale(1+ 0.03 * i, 1 + 0.03 * i);
				_brightMatrices[i].translate(+_x, +_y);
			}
		}
	}

}








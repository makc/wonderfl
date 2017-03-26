package {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	public class Marimo extends Sprite {
		// 空飛ぶマリモ的な物を作る。
		// 実際の構造は、マリモというか、やわらかいウニ。
		// 球形の表面からパーティクルを飛ばして、それを線で繋ぐ。
		// 問題点：線のつなぎ目が汚い　毛の長さが重力によって伸びてしまう　ちょっと重い
		// できそうなこと:ビットマップにピクセルで描いて縮小するようにすれば、軽くなるかも。パーティクルを制御すれば、地面と毛が接する表現になるかも
		
		public static const STAGE_W:uint = 465;
		public static const STAGE_H:uint = 465;
		
		public static const SPHERE_R:Number = 40;		// マリモの体の（毛以外の部分の）半径。
	
		public static const PARTICLE_NUM_RATE:uint = 60;	// 球体の半円を分割する数。
		public static const PARTICLE_STEP:uint = 5;	// 線の描画回数。大きいほど長くなる。
		public static const PARTICLE_V:uint = 10;	// 線の勢い。大きいほど長く、粗くなる。
		public static const GRAVITY:Number = 1.2;	// 重力。毛の長さ補正をしていないので、重力が強すぎると毛が伸びる	
		public static const RANDOM_RATE:Number = 0.4;	// バラつき具合		
		public static const COLOR_RANDOM_RATE:Number = 0.3;	// 色のバラつき具合		
		
		public static const GROUND_Y:Number = 400;	// 地面位置	
		public static const SHADOW_W:Number = 150;	// 影サイズ
		public static const GROUND_H:Number = 30;	// 影サイズ
		
		private var _marimoX:Number = STAGE_W/2;	// マリモの位置
		private var _marimoY:Number = STAGE_H/2;
		private var _display:BitmapData;
		private var _display2:Sprite;
		
		public static const COLOR_TIP_TOP:Number     = 0x77cc44;		// 毛先上部
		public static const COLOR_TIP_BOTTOM:Number  = 0x339900;		// 毛先下部
		public static const COLOR_BACE_TOP:Number    = 0x337711;		// 本体上部
		public static const COLOR_BACE_BOTTOM:Number = 0x000000;		// 本体下部
		
		public function Marimo() {
			// 準備
			_display = new BitmapData(STAGE_W, STAGE_H, false, 0xffffff);
			addChild(new Bitmap(_display)); // （できればこっちに描画して軽量化したい）
			_display2 = new Sprite();
			//addChild(_display2);
			
			// 描画
			var g:Graphics = _display2.graphics;
			
			// 本体
			g.beginFill(COLOR_BACE_BOTTOM);
			g.drawCircle(_marimoX, _marimoY, SPHERE_R);
			g.endFill();
			// 毛
			for (var xri:uint = 0; xri < PARTICLE_NUM_RATE; xri++){	// zを先に計算して、奥から手前へ描画
				var xAngle:Number = Math.PI*xri / PARTICLE_NUM_RATE;	// マリモ中心点から、マリモ表面へのx方向に対する角度
				var z:Number = Math.cos(xAngle) * SPHERE_R;				// パーティクルを飛ばす原点Z
				var r:Number = Math.sin(xAngle) * SPHERE_R;				// その時の、断面の半径
				
				// z方向に向いた面の円周上にある点の数。円周の比（=半径の比）で割り出すが、整数に丸めるので、正確ではない。
				// （右側でそろっちゃうのが気持ち悪い。ランダムでz回転させてもいいかも。）
				var particleRateZ:int = PARTICLE_NUM_RATE * 2 * r / SPHERE_R;
				
				for (var zri:uint = 0; zri < particleRateZ; zri++){	// z方向面に対して、時計回りに描画
					var zAngle:Number = Math.PI*zri*2 / particleRateZ;	// マリモ中心点から、マリモ表面へのz方向に対する角度
					var x:Number = Math.cos(zAngle) * r;	// パーティクルを飛ばす原点X
					var y:Number = Math.sin(zAngle) * r;	// パーティクルを飛ばす原点Y
					var vx:Number = PARTICLE_V * x / SPHERE_R;	// パーティクルの速度X
					var vy:Number = PARTICLE_V * y / SPHERE_R;	// パーティクルの速度Y
					// 方向をランダムでバラす。（本来は、円形方向へランダムにしなきゃいけないのだけど、面倒なのでこれで）
					vx += (PARTICLE_V * RANDOM_RATE) * (0.5 - Math.random());
					vy += (PARTICLE_V * RANDOM_RATE) * (0.5 - Math.random());
					
					// 色を決める。上下の位置と、根本までの割合で色を決定する。ランダムもちょっと入れておく。
					var yColorRate:Number = ((SPHERE_R + y)/ 2 / SPHERE_R) + COLOR_RANDOM_RATE * (0.5 - Math.random());
					var color0:Number = mixColor(COLOR_BACE_TOP, COLOR_BACE_BOTTOM, yColorRate);
					var color1:Number = mixColor(COLOR_TIP_TOP, COLOR_TIP_BOTTOM, yColorRate);
					
					// 毛
					drawFur(_marimoX + x, _marimoY + y, vx, vy, color0, color1);
				}
				
			}
			// 影
			var gradientMatrix:Matrix = new Matrix();
			gradientMatrix.createGradientBox(SHADOW_W, GROUND_H, 0, _marimoX - SHADOW_W/2, GROUND_Y-GROUND_H/2);
			g.beginGradientFill(GradientType.RADIAL, [0x000000, 0x000000], [0.3, 0.0], [60, 255], gradientMatrix);	// グラデーションわけわからん・・・
			g.drawRect(0, 0, STAGE_W, STAGE_H);
			g.endFill();

                        // user:uwiのアドバイスに従い、bitmapにして固定化(表示中にブラウザが重くなるのを防ぐ効果）
                        _display.draw(_display2);
		}
		
		// 毛を描く
		private function drawFur(x:Number, y:Number, vx:Number, vy:Number, color0:Number, color1:Number):void{
			var lastX:Number;
			var lastY:Number;
			for (var i:uint=0; i<PARTICLE_STEP; i++){
				lastX = x;
				lastY = y;
				vy += GRAVITY;
				x += vx;
				y += vy;
				drawLine(lastX, lastY, x, y, mixColor(color0, color1, i/PARTICLE_STEP), 1 - i/PARTICLE_STEP);
			}
		}
		
		// 線を引く（ピクセルを打つ方法と、どっちが軽いかな）
		private function drawLine(x0:Number, y0:Number, x1:Number, y1:Number, color:uint, alpha:Number):void{
			var g:Graphics = _display2.graphics;
			g.lineStyle(1, color, alpha);
			g.moveTo(x0, y0);
			g.lineTo(x1, y1);
		}
		
		// ２つの色を指定した割合で混ぜた色を返す（rate=0ならcolor0）。（ここもかなり軽量化できるはず。グラデーションをキャッシュとして使うとか）
		private function mixColor(color0:uint, color1:uint, rate:Number):uint{
			if (rate <= 0) return color0;
			if (rate >= 1) return color1;
			var r:uint = (color0>>16) * (1-rate) 
							+ (color1>>16) * rate;
			var g:uint = ((color0 & 0x00ff00 ) >>8) * (1-rate) 
							+ ((color1 & 0x00ff00 ) >>8) * rate;
			var b:uint = (color0 & 0xff) * (1-rate) 
							+ (color1 & 0xff) * rate;
 			return (r << 16) | (g << 8) | (b);
		}
		
	}
}
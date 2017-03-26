// forked from ahchang's RainyDay
// forked from Saqoosha's forked from: Snow
// forked from Saqoosha's Snow
/*
* blog@http://tirirenge.undo.jp/?p=1821
*/
package {
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.PixelSnapping;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.BlurFilter;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;
	
	import net.hires.debug.Stats;
	
	import frocessing.color.ColorHSV;

	[SWF(width=465, height=465, backgroundColor=0x0, frameRate=120)]

	public class RainyDay extends Sprite {
		
		private static const GRAVITY:Number = 20;
		private static const DRAG:Number = 0.7;
		
		private static const ZERO_POINT:Point = new Point(0, 0);
		
		private var _canvas:BitmapData;
		private var _glow:BitmapData;
		private var _glowMtx:Matrix;
		private var _forceMap:BitmapData;
//		private var _snow:Array;
		private var _snow:Dictionary;
		private var _color:ColorMatrixFilter = new ColorMatrixFilter([
			1, 0, 0, 0, -5,
			0, 1, 0, 0, -5,
			0, 0, 1, 0, -5,
			0, 0, 0, 1, 0
		]);
		private var _hsv:ColorHSV = new ColorHSV();
		private var _blur:BlurFilter = new BlurFilter(1.5, 1.5, 1);
		
		public function RainyDay() {
			this._canvas = new BitmapData(465, 465, false, 0x0); // カンバスをつくる。ここに 1 pixel ずつ描いていくよ
			this.addChild(new Bitmap(this._canvas)) as  Bitmap;  // stage に配置
			
			/*this._glow = new BitmapData(465 / 4, 465 / 4, false, 0x0); // キラキラを描く用のん。カンバスの 4 分の 1 のサイズ
			var bm:Bitmap = this.addChild(new Bitmap(this._glow, PixelSnapping.NEVER, true)) as Bitmap; // smoothing を true にして配置
			//bm.scaleX = bm.scaleY = 4; // 4 倍にする。
			bm.blendMode = BlendMode.ADD; // 加算モードで合成
			this._glowMtx = new Matrix(0.25, 0, 0, 0.25);*/
			
			// 雪を積もらせるかたちを BitmapData に描く。
			var tf:TextField = new TextField();
			tf.defaultTextFormat = new TextFormat('Verdana', 64, 0xffffff, true); 
			tf.autoSize = TextFieldAutoSize.LEFT;
			tf.text = 'Rainyday';
			tf.x = (465 - tf.width) / 2;
			tf.y = (465 - tf.height) / 2;
			this._forceMap = new BitmapData(465, 465, false, 0x0);
			this._forceMap.draw(tf, tf.transform.matrix);
			this._forceMap.applyFilter(this._forceMap, this._forceMap.rect, new Point(0, 0), new BlurFilter(8, 8));
			
//			this._snow = []; // 雪パーティクルはここにいれておくよ。
			this._snow = new Dictionary();
			
			this.addChild(new Stats());

			this.addEventListener(Event.ENTER_FRAME, this.update); // 毎フレーム update を呼ぶよ
		}
		
		// 雪を 1 粒発生させる関数
		public function emitParticle(ex:Number, ey:Number, s:Number = 1, c:int = 0x00bfff, vx:Number = 0, vy:Number = 0):void {
			var p:SnowParticle = new SnowParticle(); // 作って
			// パラメータ設定して
			p.x = ex;
			p.y = ey;
			p.vx = vx;
			p.vy = vy;
			p.s = s;
			p.c = c;
//			this._snow.push(p); // 保存
			this._snow[p] = true;
		}
		
		// 雪を動かすよーー
		public function update(e:Event):void {
			this._canvas.lock(); // いっぱい setPixel するときは必ず lock しよう
			this._canvas.applyFilter(this._canvas, this._canvas.rect, ZERO_POINT, this._color);
			this._canvas.applyFilter(this._canvas, this._canvas.rect, ZERO_POINT, this._blur);
//			this._canvas.fillRect(this._canvas.rect, 0x0); // カンバスをクリア
//			var n:int = this._snow.length;
			var d:Number;
			var gravity:Number = GRAVITY / 100; // あらかじめ計算しとく
//			while (n--) {
			for (var key:* in this._snow) {
				var p:SnowParticle = SnowParticle(key);
//				var p:SnowParticle = this._snow[n];
//				p.vx += 0.02;
				p.vy += gravity * p.s; // まず重力を加える
				p.vx *= 0.99; // 空気抵抗
				p.vy *= 0.99; // y 方向にも
				d = 1 - (this._forceMap.getPixel(p.x, p.y) / 0xffffff) * DRAG; // forceMap にもとづいて抵抗値を計算。黒→速い、白→遅い。
				p.vx *= d; // forceMap から得た抵抗値を適用
				p.vy *= d; // y 方向にも
				var px:int = p.x;
				var py:int = p.y;
				p.x += p.vx; // 動かす
				p.y += p.vy;
//				this._canvas.setPixel(p.x, p.y, p.c); // 雪 1 粒描く
				_drawLine(p.x, p.y, px, py, p.c, 1);
				if (p.y > this.stage.stageHeight) { // もし画面外にでちゃったら
//					this._snow.splice(n, 1); // とりのぞく
					delete this._snow[p];
				}
			}
			this._canvas.unlock(); // lock したやつは必ず unlock
			//this._glow.draw(this._canvas, this._glowMtx); // キラキラを描く
			
			// 雪を発生させますよ
//			var n = 10;
//			while (n--) {
			for (var i:int = 0; i < 8; i++) {
				_hsv.h = Math.random() * 20 + 180;
				this.emitParticle(Math.random() * this.stage.stageWidth, -20, Math.random() + 0.5, _hsv.value);
			}
		}

		private function _drawLine(x0:int, y0:int, x1:int, y1:int, color:int, alpha:Number):void {
			var steep:Boolean = Math.abs(y1 - y0) > Math.abs(x1 - x0);
			var tmp:int;
			if (steep) {
				tmp = x0;
				x0 = y0;
				y0 = tmp;
				tmp = x1;
				x1 = y1;
				y1 = tmp;
			}
			if (x0 > x1) {
				tmp = x0;
				x0 = x1;
				x1 = tmp;
				tmp = y0;
				y0 = y1;
				y1 = tmp;
			}
			var deltax:int = x1 - x0;
			var deltay:int = Math.abs(y1 - y0);
			var error:int = deltax / 2;
			var ystep:int;
			var y:int = y0;
			if (y0 < y1) {
				ystep = 1;
			} else {
				ystep = -1;
			}
			for (var x:int = x0; x <= x1; x++) {
				if (steep) {
					this._canvas.setPixel32(y, x, color | ((alpha * 0xff) << 24));
				} else {
					this._canvas.setPixel32(x, y, color | ((alpha * 0xff) << 24));
				}
				error = error - deltay;
				if (error < 0) {
					y = y + ystep;
					error = error + deltax;
				}
			}
		}
	}
}


class SnowParticle {
	
	public var x:Number;
	public var y:Number;
	public var vx:Number;
	public var vy:Number;
	public var s:Number;
	public var c:int;
	
	public function SnowParticle() {
		this.x = 0;
		this.y = 0;
		this.vx = 0;
		this.vy = 0;
		this.s = 1;
		this.c = 0xffffff;
	}
}
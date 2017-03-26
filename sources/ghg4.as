//はじめてのフォースマップ
package 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
 	import flash.geom.ColorTransform;
	
  [SWF(backgroundColor="0x0", frameRate="90")]
	public class  MyFirstForceMap extends Sprite
	{
		private const WH:uint = 465;

		//Force map
		private const fm: BitmapData = new BitmapData(WH, WH);
		/**
		 * ピクセルのRGB値から粒子にはたらく力を決めよう。
		 * Rはx方向、Gはy方向に、それぞれ作用する力を
		 * Bはその場所における動きにくさ、のようなものを。
		 * (早く動くほど受ける力が大きくなる)
		 */
		private const VERO:Number = 1.0/50.0; //加速度に掛ける正の値
		private const RESI:Number = 1.0/800.0; //抵抗の大きさ0~255に掛ける正の値
                private const BIAS:int = -64;//加速度の補正値
                
		private var ps:Vector.<Point>;//位置ベクトル
		private var vs:Vector.<Point>;//速度ベクトル
		private const N:uint = 4000;//粒子の数
		
		private const dat:BitmapData = new BitmapData(WH, WH, true, 0x0);
		private const bmp:Bitmap = new Bitmap(dat);
		public function MyFirstForceMap() {
			var rnd: uint = 100000 * Math.random();
			fm.perlinNoise(400, 400, 3, rnd, true, false, 7);
			
			ps = new Vector.<Point>();
			while (ps.length != N) {
				ps.push(new Point(WH*Math.random(), WH*Math.random()));
			}
			vs = new Vector.<Point>();
			while (vs.length != N) {
				vs.push(new Point());
			}
			addChild(bmp);
			addEventListener(Event.ENTER_FRAME, function(e:Event):void {
				dat.lock();
				dat.draw(stage,null,new ColorTransform(1,1,1,1,-1,-3,-7,0));//残像

                                var i:int;
				var c:uint;
				var fr:int;
				var fg:int;
				var fb:Number;
				var resist:Number;
				for (i = 0; i < N; i++) {
					c = fm.getPixel(ps[i].x, ps[i].y);
					fr = (c >>> 16) & 0xff;
					fr += BIAS;
					fg = (c >>> 8) & 0xff;
					fg += BIAS;
					fb = 1 - (c & 0xff) * RESI;
					vs[i].x = fb * (vs[i].x + VERO*fr);
					vs[i].y = fb * (vs[i].y + VERO*fg);
					ps[i].x += vs[i].x;
					ps[i].y += vs[i].y;
					ps[i].x = ps[i].x > WH? ps[i].x - WH: ps[i].x < 0? ps[i].x + WH: ps[i].x;
					ps[i].y = ps[i].y > WH? ps[i].y - WH: ps[i].y < 0? ps[i].y + WH: ps[i].y;
					dat.setPixel32(ps[i].x, ps[i].y, 0xffffffff);
				}
				dat.unlock();
			});
			stage.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
				rnd = 100000 * Math.random();
				fm.perlinNoise(200, 200, 3, rnd, true, true, 7);
			});
		}

	}
	
}
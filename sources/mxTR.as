// forked from knd's My first force map
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
	import flash.filters.BlurFilter;
	
  [SWF(backgroundColor="0x0", frameRate="60")]
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
		private const VERO:Number = 1.0/100.0; //加速度に掛ける正の値
		private const RESI:Number = 1.0/800.0; //抵抗の大きさ0~255に掛ける正の値
                private const BIAS:int = -64;//加速度の補正値
                
		private var ps:Vector.<Point>;//位置ベクトル
		private var vs:Vector.<Point>;//速度ベクトル
		private const N:uint = 100000;//粒子の数
		
		private const dat:BitmapData = new BitmapData(WH, WH, true, 0xff000000);
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
                        var i:int;
			var c:int;
			var fr:Number;
			var fg:Number;
			var fb:Number;
			var resist:Number;
                        var p:Point;
                        var v:Point;
                        
                        const p0:Point = new Point;
                        const blur:BlurFilter = new BlurFilter;
			addEventListener(Event.ENTER_FRAME, function(e:Event):void {
				dat.lock();
				dat.colorTransform(dat.rect, new ColorTransform(1, 1, 1, 1, -4, -3, -2, 0));
				dat.applyFilter(dat, dat.rect, p0, blur);
				for (i = 0; i < N; i++) {
                                        p = ps[i];
                                        v = vs[i];
					c = fm.getPixel(p.x, p.y);
					fr = VERO * Number(((c >> 16) & 0xff) + BIAS);
					fg = VERO * Number(((c >> 8) & 0xff) + BIAS);
					fb = 1.0 - Number(c & 0xff) * RESI;
					v.x = fb * (v.x + fr);
					v.y = fb * (v.y + fg);
					p.x += v.x;
					p.y += v.y;
					if (p.x > WH) p.x -= WH;
                                        else if( p.x < 0) p.x += WH;
					if (p.y > WH) p.y -= WH; 
                                        else if( p.y < 0) p.y += WH;
					dat.setPixel32(p.x, p.y, 0xffffffff);
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


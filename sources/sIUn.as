// forked from knd's forked from: forked from: forked from: forked from: My first force map
// forked from knd's forked from: forked from: forked from: My first force map
// forked from knd's forked from: forked from: My first force map
// forked from knd's forked from: My first force map
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
 	import flash.geom.Matrix;
	import flash.filters.BlurFilter;
        import flash.text.*;
	
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
		private const VERO:Number = 1.0/150.0; //加速度に掛ける正の値
		private const RESI:Number = 1.0/275.0; //抵抗の大きさ0~255に掛ける正の値
                private const BIAS:int = -128;//加速度の補正値
                
		private var ps:Vector.<Point>;//位置ベクトル
		private var vs:Vector.<Point>;//速度ベクトル
		private const N:uint = 20000;//粒子の数
		
		private const dat:BitmapData = new BitmapData(WH, WH, true, 0xff000000);
		private const bmp:Bitmap = new Bitmap(dat);
                
                private var vh:Boolean;
                private var ct: ColorTransform = new ColorTransform(1, 1, 1, 1, -7, -3, -2, 0);
                private function updateFM():void{
                        var txt : TextField = new TextField;
                        txt.autoSize = TextFieldAutoSize.LEFT;
                        var tf: TextFormat = new TextFormat;
                        tf.color = 0x8080f0;
                        tf.bold = true;
                        tf.size = 60;
                        var mat :Matrix;
			var rnd: uint = 100000 * Math.random();
                        if(vh){
			fm.perlinNoise(WH>>2, WH>>2, 7, rnd, true, true, 7);
                        
                       ct = new ColorTransform(1, 1, 1, 1, -8, -6, -2, 0);
                        txt.text = "あ\nお";
                        txt.setTextFormat(tf);
                        mat = new Matrix(3,0,0,3, WH>>3, 0);
                        fm.draw(txt, mat);
                        }
                        else{
                        fm.perlinNoise(WH>>2, WH>>2, 7, rnd, true, true, 7);
                        
                         ct = new ColorTransform(1, 1, 1, 1, -2, -6, -8, 0);
                        txt.text = "あか";
                        txt.setTextFormat(tf);
                        mat = new Matrix(3,0,0,3,0, WH>>3);
                        fm.draw(txt, mat);
}                            
                    vh = !vh
                }
		public function MyFirstForceMap() {
			updateFM();
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
                        const blur:BlurFilter = new BlurFilter(4,4);
                        
			addEventListener(Event.ENTER_FRAME, function(e:Event):void {
				dat.lock();
				dat.colorTransform(dat.rect, ct);
				for (i = 0; i < N; i++) {
                                        p = ps[i];
                                        v = vs[i];
                                        
					c = fm.getPixel(p.x, p.y);
					fr = VERO * Number(int((c >>> 16) & 0xff) + BIAS);
					fg = VERO * Number(int((c >>> 8) & 0xff) + BIAS);
					fb = Number(~c & 0xff) * RESI;
					
					v.x = fb * (v.x + fr);
					v.y = fb * (v.y + fg);
					p.x += v.x;
					p.y += v.y;
					if (p.x > WH){ p.x -= WH; }
                                        else if( p.x < 0){ p.x += WH;}
					else if (p.y > WH)  p.y -= WH; 
                                        else if( p.y < 0)  p.y += WH;
                                        if(dat.getPixel32(p.x,p.y)== 0xffffffff){
                                            p.x = WH*Math.random() ;
                                            p.y = WH*Math.random() ;
                                            v.x = 0;
                                            v.y = 0;
                                        } else 
					    dat.setPixel32(p.x, p.y, 0xffffffff);
				}
				dat.applyFilter(dat, dat.rect, p0, blur);
				dat.unlock();
			});
			stage.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
				updateFM();
			});
		}

	}
	
}


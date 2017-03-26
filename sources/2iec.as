//
// メンガーとか最近流行ってるらしいので。
// もろ劣化パクリでごめんなさい。
// 速度でないので工夫できる方法模索中
//
// [ref : 参考にした素晴らしいコードとサイト]
// http://www.p01.org/releases/512b_jspongy/
// http://www.pouet.net/prod.php?which=52993
// http://www.fractalforums.com/3d-fractal-generation/revenge-of-the-half-eaten-menger-sponge/
//
package {
	import flash.display.Sprite;
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;

	[SWF(width=465,height=465,backgroundColor=0xFFFFFF,frameRate=60)]
	
	public class Main extends Sprite 	{
		
		//本当は解像度小さくしてバイリニア拡大したいけどわからない
		private const WIDTH:int = 465;
		private const HEIGHT:int = 465;
		private var canvas:BitmapData;
		
		//時間
		private var time:Number = 0;
		
		//速くなる？わからない
		private var x1:Number;
		private var y1:Number;
		private var dx:Number;
		private var dy:Number;
		
		//sincos
		private var sn:Number;
		private var cn:Number; 
		
		//いろ
		private var col:Number;
		public function Main():void {
			canvas = new BitmapData(WIDTH, HEIGHT, false, 0x0);
			addChild(new Bitmap(canvas)) as Bitmap;
			addEventListener(Event.ENTER_FRAME, update);
		}

		private function update(e:Event):void {
			var x:int;
			var y:int;
			
			//速度でないのでなくなく
			var scale:int = 8;
			
			//適当に係数
			sn = Math.sin(time * 0.1);
			cn = Math.cos(time * 0.1);
			time += 0.01666667;
			dx = 2.0 / WIDTH;
			dy = 2.0 / HEIGHT;

			//ラスタライザ遅いのでなんとかしないと
			canvas.lock();
			y1 = -1.0;
			for(y = 0 ; y < HEIGHT; y += scale) {
				x1 = -1.0;
				for(x = 0 ; x < WIDTH; x += scale) {
					shader(x1, y1);
					var col:int = (col) * 255;
					//遅すぎるので封印
//					canvas.setPixel(x, y, col << 8);
					canvas.fillRect(
					　　new Rectangle(x, y, scale, scale), col << 8);
					x1 += dx * scale;
			 	}	
			 	y1 += dy * scale;
			}
			canvas.unlock();
		}
		
		//とりあえず実験
		private function shader(u:Number, v:Number):void
		{
			var a:Number = time;
			var d:Number = 1;
			var n:Number = a * 0.1;
			var Z:Number = 3; //2 is gasket
			var IZ:Number = 1.0/Z;
			
			//float3(0.5 + cos(a * 0.37) * v, a * v + sin(a * v - 0.01));
			var acc:Number  = 0.1;
			var ex:Number = 0.5 + Math.sin(a * 0.5) * acc;
			var ey:Number = 0.5 + Math.cos(a * 0.47) * acc;
			var ez:Number = -a * 0.3 + Math.sin(a * 0.3 - 0.01);
			
			//Start position
			var sx:Number = ex;
			var sy:Number = ey;
			var sz:Number = ez;
			
			var rx:Number;
			var ry:Number;
			var rz:Number;
			
			//direction ray
			rx = 1;//u;
			ry = u;//v;
			rz = v;//1;

			//temp position
			var tx:Number = ex;
			var ty:Number = ey;
			var tz:Number = ez;
			
			//光線回転
			var gx:Number = cn * rx + sn * rz;
			var gy:Number = ry;
			var gz:Number = cn * rz - sn * rx;
			rx = gx;	ry = gz;	rz = gy;
			gx = cn * rx + sn * rz;
			gy = ry;
			gz = cn * rz - sn * rx;
			rx = gx; ry = gz; rz = gy;
			var irx:Number = 1.0/rx;
			var iry:Number = 1.0/ry;
			var irz:Number = 1.0/rz;
			
			//oraora.近傍を反復計算
			var i:int = 0;
			for(i = 100; i-- && d > 0.0125;) {
				d *= IZ;
				
				//fraction;
				tx = (tx - Math.floor(tx)) * Z;
				ty = (ty - Math.floor(ty)) * Z;
				tz = (tz - Math.floor(tz)) * Z;
				
				//interger
				var j:int = 
					Math.floor(tx) * Math.floor(tx) + 
					Math.floor(ty) * Math.floor(ty) + 
					Math.floor(tz) * Math.floor(tz);
				j %= 4;
				if(j >= 2) {
					//下手に整数キャストすると重くなるな
					tx = ((int)(rx > 0) - (tx - Math.floor(tx))) * irx;
					ty = ((int)(ry > 0) - (ty - Math.floor(ty))) * iry;
					tz = ((int)(rz > 0) - (tz - Math.floor(tz))) * irz;
					n = Math.min(Math.min(tx, ty), tz);
					ex += rx * (n * d + 0.001);
					ey += ry * (n * d + 0.001);
					ez += rz * (n * d + 0.001);
					tx = ex;
					ty = ey;
					tz = ez;
					
					//もっかい
					d = 1;
				}
			}
			
			//初期位置つかってfogしておわり。指数でなくても見てくれは良いはず
			ex -= sx;
			ey -= sy;
			ez -= sz;
			col = 1 - Math.exp( -Math.sqrt(ex*ex + ey*ey + ez*ez));
		}
	}
}

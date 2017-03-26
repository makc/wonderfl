// BitmapData に描画した TextField から座標をとって
// FP10 の 3D 機能で変換して描画してみた
//-----------------------------------------------------
// 見所
// - PerspectiveProjection を初めて使ってみた
// - あとはいつも通り transformVectors やら projectVectors で。
package {
	import flash.display.*;
	import flash.events.Event;
	import flash.geom.*;
	import flash.text.*;
	
	[SWF(backgroundColor=0x000000)]
	public class StringParticle3 extends Sprite{
		private static const WIDTH:Number = 475;
		private static const HEIGHT:Number = 475;
		private var points:Vector.<Number> = new Vector.<Number>();
		private var colors:Vector.<uint> = new Vector.<uint>();
		
		public function StringParticle3()
		{
			stage.scaleMode = "noScale";
			stage.align = "TL";

			// BitmapData にテキストを描画して座標を points に格納する
			var bmd:BitmapData = createBitmapData("HELLO WORLD");
			initParticles(bmd);

			// キャンバスを準備
			var canvas:BitmapData = new BitmapData(WIDTH, HEIGHT, false, 0x000000);
			addChild(new Bitmap(canvas));

			// FP10 用 座標変換の準備
			var xys:Vector.<Number> = new Vector.<Number>();
			var uvts:Vector.<Number> = new Vector.<Number>();
			var points2:Vector.<Number> = new Vector.<Number>();
			var mtx3d:Matrix3D = new Matrix3D();

			// 透視投影用の変換行列作成
			var proj:PerspectiveProjection = new PerspectiveProjection();
			proj.fieldOfView = 90;
			var projMat:Matrix3D = proj.toMatrix3D();

			var counter:int = 0;
			addEventListener("enterFrame", function(event:Event):void{
				// 角度を設定して変換する (points → points2)
				mtx3d.identity();
				mtx3d.appendRotation(counter, Vector3D.Y_AXIS);
				mtx3d.appendRotation(15, Vector3D.X_AXIS);
				mtx3d.appendTranslation(0, 0, WIDTH / 2);
				mtx3d.transformVectors(points, points2);

				// 透視投影する
				Utils3D.projectVectors(projMat, points2, xys, uvts);

				// BitmapData に描画する
				canvas.lock();
				canvas.fillRect(canvas.rect, 0x000000);
				for (var i:int = 0; i < xys.length / 2; i++){
					canvas.setPixel32(xys[i * 2] + WIDTH / 2, xys[i * 2 + 1] + HEIGHT / 2, colors[i]);
				}
				canvas.unlock();

				counter++;
			});
		}

		private static function createBitmapData(letters:String):BitmapData{
			var fmt:TextFormat = new TextFormat();
			fmt.size = 50;

			var tf:TextField = new TextField();
			tf.defaultTextFormat = fmt;
			tf.autoSize = "left";
			tf.textColor = 0xffffff;
			tf.text = letters;

			var bmd:BitmapData = new BitmapData(tf.textWidth, tf.textHeight, false, 0x000000);
			var mtx:Matrix = new Matrix();
			bmd.draw(tf, mtx);

			return bmd;
		}

		private function initParticles(bmd:BitmapData):void{
			for (var yy:int = 0; yy < bmd.height; yy++){
				for (var xx:int = 0; xx < bmd.width; xx++){
					var c:uint = bmd.getPixel(xx, yy);
					if (c != 0){
						points.push(xx - bmd.width / 2, yy - bmd.height / 2, 0);
						colors.push(c);
					}
				}
			}
		}
	}
}
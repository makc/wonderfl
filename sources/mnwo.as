// キラキラ3D Typography
//-----------------------------------------------------
// 次の２つの組み合わせ＋αです
//  - HelloWorld3D 
//    http://wonderfl.net/code/50225c9944de6206a3813f515fce2c51fd56ab23
//  - キラキラPixel3D！ in Native Flash 10 3D API 
//    http://wonderfl.net/code/8283df8a03a8f3c290bc88a056b44b3c6084b123
package {
    import flash.display.*;
    import flash.events.Event;
    import flash.geom.*;
    import flash.text.*;
    import flash.utils.setInterval;
    
    [SWF(backgroundColor=0x000000)]
    public class HelloSpace extends Sprite{
        private static const SIZE:Number = 475;
        private static const R:Number = 300;
        private static const HR:Number = R / 2;
        private var particles:Vector.<Number> = new Vector.<Number>();
        private var letterPoints:Vector.<Number> = new Vector.<Number>();
        private var colors:Vector.<uint> = new Vector.<uint>();

        // 光らせるための BitmapData
        private var canvasGlow:BitmapData;

        // 1/4 で描画するための Matrix
        private var mtx:Matrix = new Matrix(0.25, 0, 0, 0.25);

        public function HelloSpace()
        {
            stage.scaleMode = "noScale";
            stage.align = "TL";

            // BitmapData にテキストを描画して座標を points に格納する
            var bmd:BitmapData = createBitmapData("HELLO UNIVERSE");
            initParticles(bmd);

            // キャンバスを準備
            var canvas:BitmapData = new BitmapData(SIZE, SIZE, false, 0x000000);
            addChild(new Bitmap(canvas));

            // FP10 用 座標変換の準備
            var uvts:Vector.<Number> = new Vector.<Number>();
            var particles2:Vector.<Number> = new Vector.<Number>();
            var mtx3d:Matrix3D = new Matrix3D();

            // 透視投影用の変換行列作成
            var proj:PerspectiveProjection = new PerspectiveProjection();
            proj.fieldOfView = 90;
            var projMat:Matrix3D = proj.toMatrix3D();

            // 光らせるための BitmapData を初期化する
            canvasGlow = new BitmapData(SIZE / 4, SIZE / 4, false, 0x000000);
            var bmp:Bitmap = new Bitmap(canvasGlow, PixelSnapping.NEVER, true);
            bmp.scaleX = bmp.scaleY = 4;
            bmp.smoothing = true;
            bmp.blendMode = BlendMode.ADD;
            addChild(bmp);

            // ループ用の変数を用意
            var counter:int = 0;
            var moveCounter:int = 0;
            var xysRandom:Vector.<Number> = new Vector.<Number>();
            var xys:Vector.<Number> = new Vector.<Number>(letterPoints.length);
            var f:Boolean = false;

            // ループ処理
            addEventListener("enterFrame", function(event:Event):void{
                // 角度を設定して座標変換する (particles → particles2)
                mtx3d.identity();
                mtx3d.appendRotation(counter, Vector3D.Y_AXIS);
                mtx3d.appendRotation(15, Vector3D.X_AXIS);
                mtx3d.appendTranslation(0, 0, SIZE / 2);
                mtx3d.transformVectors(particles, particles2);

                // 透視投影して回転後の座標を計算する
                Utils3D.projectVectors(projMat, particles2, xysRandom, uvts);

                // moveCounter 以下ならパーティクルを文字列の配置に近づける
                // そうでない場合はあらかじめ定義したランダム位置の配置に近づける
                for (var i:int = 0; i < xysRandom.length; i++){
                    if (i < moveCounter * 2){
                        xys[i] += (letterPoints[i] - xys[i]) * .13;
                    } else {
                        xys[i] += (xysRandom[i] - xys[i]) * .12;
                    }
                }

                // 文字列表示中はmoveCounter を加算する
                moveCounter = (f ? moveCounter + 100 : 0);

                // BitmapData に描画する
                canvas.lock();
                canvas.fillRect(canvas.rect, 0x000000);
                for (var i:int = 0; i < xys.length / 2; i++){
                    canvas.setPixel32(xys[i * 2] + SIZE / 2, xys[i * 2 + 1] + SIZE / 2, colors[i]);
                }
                canvas.unlock();

                // 光らせるためのキャンバスにコピーする
                canvasGlow.fillRect(canvasGlow.rect, 0x000000);
                canvasGlow.draw(canvas, mtx);

                counter++;
            });

            // 定期的に f を反転させる
            setInterval(function():void{ f = !f; }, 4000);
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
                        letterPoints.push(xx - 220, yy - 20);
                        particles.push(R * Math.random() - HR, R * Math.random() - HR, R * Math.random() - HR);
                        colors.push(c);
                    }
                }
            }
        }
    }
}

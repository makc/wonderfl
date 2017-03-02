// forked from gbone's メンガーのスポンジ(Menger Sponge)
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
    import flash.display.*;
    import flash.events.*;
    import flash.filters.BlurFilter;
    import flash.filters.ColorMatrixFilter;
    import flash.geom.*;
    import flash.text.TextField;
    import flash.utils.getTimer;

    [SWF(width=465,height=465,backgroundColor=0xFFFFFF,frameRate=30)]
    
    public class Main extends Sprite     {
        
        //本当は解像度小さくしてバイリニア拡大したいけどわからない
        private var WIDTH:int = 465;
        private var HEIGHT:int = 465;
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
        private var _tf:TextField = new TextField;
        public function Main():void {
            //stage.align = StageAlign.TOP_LEFT;
            //stage.scaleMode = StageScaleMode.NO_SCALE;
            
            
            //本当は解像度小さくしてバイリニア拡大したいけどわからない
            var scale:Number = 2.0;
            WIDTH /= scale;
            HEIGHT /= scale;
            canvas = new BitmapData(WIDTH, HEIGHT, false, 0x0);
            var bm:Bitmap = new Bitmap(canvas, PixelSnapping.AUTO, true);
            // こういうことですか？
            bm.scaleX = bm.scaleY = scale;
            addChild(bm) as Bitmap;
            
            _canvasData = new Vector.<uint>(WIDTH * HEIGHT, true);
            
            addEventListener(Event.ENTER_FRAME, update);
            //_tf.x = 465;
            //addChild(_tf);
        }
        
        private var _prevTime:int = 0;
        private var rect:Rectangle;
        private var _canvasData:Vector.<uint>;

        private function update(e:Event):void {
            var x:int;
            var y:int;
            //var t:int = getTimer();
            //速度でないのでなくなく
            var scale:int = 1;
            //適当に係数
            sn = Math.sin(time * 0.1);
            cn = Math.cos(time * 0.1);
            // 処理落ちした分スキップ fps=20設定
            time += 0.01666667 * (getTimer() - _prevTime) / (1000 / 33);
            dx = 2.0 / WIDTH * scale;
            dy = 2.0 / HEIGHT * scale;
            _prevTime = getTimer();

            var acc:Number = 0.1;
            var ex:Number = 0.5 + Math.sin(time * 0.5) * acc;
            var ey:Number = 0.5 + Math.cos(time * 0.47) * acc;
            var ez:Number = -time * 0.3 + Math.sin(time * 0.3 - 0.01);
            rect = new Rectangle;
            //ラスタライザ遅いのでなんとかしないと
            // avmは
            // ・ 関数呼び出し
            // ・ 型変換
            // が異常に重いので、これらを避けるだけで、10倍くらい高速になります
            canvas.lock();
            y1 = -1.0;
            var pos:int = 0;
            for(y = 0 ; y < HEIGHT; ++y) {
                x1 = -1.0;
                for(x = 0 ; x < WIDTH; ++x) {
                    var col:int = shader(x1, y1, ex, ey, ez);
                    _canvasData[pos++] = col << 8;
                    x1 += dx;
                 }    
                 y1 += dy;
            }
            canvas.setVector(canvas.rect, _canvasData);
            canvas.unlock();
            
            //_tf.text = ('loop costs : ' + (getTimer() - t) + ' ms');
        }
        
        
        //とりあえず実験
        private function shader(u:Number, v:Number, ex:Number, ey:Number, ez:Number):int
        {
            var a:Number = time;
            var d:Number = 1;
            var n:Number = a * 0.1;
            var Z:Number = 3; //2 is gasket
            var IZ:Number = 1.0/Z;
            
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
            rx = gx;    ry = gz;    rz = gy;
            gx = cn * rx + sn * rz;
            gy = ry;
            gz = cn * rz - sn * rx;
            rx = gx; ry = gz; rz = gy;
            var irx:Number = 1.0/rx;
            var iry:Number = 1.0/ry;
            var irz:Number = 1.0/rz;
            var ix:int;
            var iy:int;
            var iz:int;
            var fx:int;
            var fy:int;
            var fz:int;
            
            //oraora.近傍を反復計算
            var i:int = 0;
            // 再起計算の脱出定数ですが、実際に見てみるとほとんどが10回以下の反復で計算を終了していました
            // それ以上は無限ループに陥るパターンなので、10回で計算を打ち切ってみたら、
            // 無限ループのところで演算回数が跳ね上がる問題を解決しました。
            for(i = 10; i-- && d > 0.0125;) {
                d *= IZ;
                
                ix = tx >> 0;
                iy = ty >> 0;
                iz = tz >> 0;
                //fraction;
                tx = (tx - ix) * Z;
                ty = (ty - iy) * Z;
                tz = (tz - iz);
                tz = (tz < 0) ? (1 + tz) : tz;
                tz *= Z;
                // 関数呼び出し(Math.floor)のオーバーヘッドをなくします
                ix = tx >> 0;
                iy = ty >> 0;
                iz = tz >> 0;
                
                //interger
                var j:int = 
                    ix * ix + 
                    iy * iy + 
                    iz * iz;
                j &= 3;
                if (j >= 2) {
                    fx = (rx > 0) ? 1 : 0;
                    fy = (ry > 0) ? 1 : 0;
                    fz = (rz > 0) ? 1 : 0;
                    //下手に整数キャストすると重くなるな -> 型のキャストは遅いですね。
                    tx = (fx - (tx - ix)) * irx;
                    ty = (fy - (ty - iy)) * iry;
                    tz = (fz - (tz - iz)) * irz;
                    //n = Math.min(Math.min(tx, ty), tz);
                    n = tx;
                    n = (ty < n) ? ty : n;
                    n = (tz < n) ? tz : n;
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
            
            return ((1 - Math.exp( -Math.sqrt(ex*ex + ey*ey + ez*ez))) * 0xff) >> 0;
        }
    }
}

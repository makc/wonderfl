// forked from Aquioux's マルチブロ集合
// forked from Aquioux's マンデルブロ集合
package {
    import com.bit101.components.*;
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.events.Event;
    [SWF(width = "465", height = "465", frameRate = "30", backgroundColor = "#000000")]
    /**
     * マルチブロ集合の描画
     * @author Aquioux(Yoshida, Akio)
     * @see    http://aquioux.net/blog/?p=1244
     * @see    http://aquioux.net/blog/?p=1247
     * initial state "z ^ 2.5 + c"
     */
    [SWF(backgroundColor='#FFFFFF')]
    public class Main extends Sprite {
        private const W:int = stage.stageWidth;
        private const H:int = stage.stageHeight;

        private var colors_:Vector.<uint>;
        
        private var bmd_:BitmapData;
        private var hslider:HSlider;
        

        public function Main():void {
            colors_ = new Vector.<uint>();
            var degree:int = 45;
            var step:Number = 270 / degree;
            for (var i:int = 0; i < degree; i++) colors_[i] = CycleRGB.getColor(i * step + 180);
            colors_.reverse();
            colors_.fixed = true;
            
            Mandelbrot.divergenceColors = colors_;

            bmd_ = new BitmapData(W, H, false, 0x0);
            addChild(new Bitmap(bmd_));
            
            hslider = new HSlider (this, 20, 20, button2Handler);
            hslider.width = 465 - 40;
            hslider.minimum = 1;
            hslider.maximum = 10;
            hslider.tick = 0.01;
            hslider.value = 2.5;
            
            button2Handler(null);
        }
        
        private function draw():void {
            bmd_.setVector(bmd_.rect, Mandelbrot.update(W, H));
        }
        
        private function button2Handler(e:Event):void {
            Mandelbrot.expo = hslider.value;
            Mandelbrot.offsetX = 0.5;
            draw();
        }
    }
}


//package {
    /**
     * マンデルブロ集合描画クラス
     * @author Aquioux(Yoshida, Akio)
     */
    /*public*/ class Mandelbrot {
        /**
         * マンデルブロ集合に該当する部分の色
         */
        public static function set mandelbrotColor(value:uint):void { _mandelbrotColor = value; }
        private static var _mandelbrotColor:uint = 0x000000;
        /**
         * 発散部分の色階調
         */
        public static function set divergenceColors(value:Vector.<uint>):void { _divergenceColors = value; }
        private static var _divergenceColors:Vector.<uint>;
        
        /**
         * 表示位置オフセットX座標値
         */
        public static function set offsetX(value:Number):void { _offsetX = value; }
        private static var _offsetX:Number = 0.0;
        /**
         * 表示位置オフセットY座標値
         */
        public static function set offsetY(value:Number):void { _offsetY = value; }
        private static var _offsetY:Number = 0.0;

        /**
         * ズーム値
         */
        public static function set zoom(value:Number):void { _zoom = value; }
        private static var _zoom:Number = 1.0;
        
        /**
         * 漸化式の z の冪乗数
         */
        static public function set expo(value:Number):void { _expo = value; }
        private static var _expo:Number = 2;
        
        /**
         * 複素数平面を走査
         * @param    width    複素数平面の幅
         * @param    height    複素数平面の高
         * @return    複素数平面の各点ごとの発散濃度を格納した Vector
         */
        public static function update(width:int, height:int):Vector.<uint> {
            // 発散時の色が外部から指定されていなければ設定する
            if (!_divergenceColors) {
                _divergenceColors = new Vector.<uint>(256, true);
                for (var i:int = 0; i < 256; i++) _divergenceColors[i] = i << 16 | i << 8 | i;
            }
            
            // 複素数平面走査のインクリメントステップを計算する
            var target:int = (width < height) ? width : height;
            var step:Number = 4 / (_zoom * target);
            // 複素数平面の走査開始座標を計算する
            var startRl:Number = -width  * step / 2 + _offsetX - 0.5;
            var startIm:Number = -height * step / 2 - _offsetY;
            
            // 返り値となる Vector
            var data:Vector.<uint> = new Vector.<uint>(width * height, true);

            var idx:int = 0;
            var degree:int = _divergenceColors.length;
            
            // 複素数平面の走査
            var im:Number = startIm;
            // Y軸方向ループ変数の初期化
            var y:int = height;
            while (y--) {
                // 複素数実数部の初期化
                var rl:Number = startRl;
                // X軸方向ループ変数の初期化
                var x:int = width;
                while (x--) {
                    // マンデルブロ集合に該当する色で color を初期化しておく
                    var color:uint = _mandelbrotColor;
                    // 発散のチェック
                    var result:int = checkDivergence(rl, im, degree);
                    // 発散したときは、マンデルブロ集合でない色に color を置き換える
                    if (result >= 0) color = _divergenceColors[result];
                    data[idx++] = color;
                    // 複素数の実数部のインクリメント
                    rl += step;
                }
                // 複素数の虚数部のインクリメント
                im += step;
            }
            return data;
        }

        /**
         * 漸化式 z_n1 = z_n^2 + c を最大 degree 回ループして発散するか否か調べる
         * @param    rl    複素数 c の実数部
         * @param    im    複素数 c の虚数部
         * @param    degree    発散チェックの最大ループ回数
         * @return    発散濃度評価値
         * @private
         */
        private static function checkDivergence(cRl:Number, cIm:Number, degree:int):int {
            // z_n
            var zRl:Number = 0.0;    // 実数部
            var zIm:Number = 0.0;    // 虚数部
            // z_n の各要素の二乗
            var zRlSqr:Number;        // 実数部
            var zImSqr:Number;        // 虚数部
            
            var r:Number;    // 複素数の冪乗を簡単に計算するための局座標（距離）
            var t:Number;    // 複素数の冪乗を簡単に計算するための局座標（偏角）
            var r2:Number;    // 冪乗計算結果（距離）
            var t2:Number;    // 冪乗計算結果（偏角）

            var i:int = degree;
            var j:int;
            while (i--) {
                // 発散の評価
                zRlSqr = zRl * zRl;
                zImSqr = zIm * zIm;
                if (zRlSqr + zImSqr > 4) break;
                // 発散していなかった場合、再評価へ向けて z_n の値を更新する
                // 複素数を局座標化
                r = Math.sqrt(zRlSqr + zImSqr);
                t = Math.atan2(zIm, zRl);
                // オイラーの公式による冪乗計算
                r2 = Math.pow (r, _expo);            // 距離
                t2 = t * _expo;    // 偏角
                zRl = Math.cos(t2) * r2 + cRl;
                zIm = Math.sin(t2) * r2 + cIm;
            }
            return i;
        }
    }
//}


//package {
    /**
     * コサインカーブによる色循環
     * @author Aquioux(Yoshida, Akio)
     */
    /*public*/ class CycleRGB {
        private static const DEGREE90:Number  = Math.PI / 2;    // 90度（弧度法形式）
        private static const DEGREE180:Number = Math.PI;        // 180度（弧度法形式）
        
        public static function getColor(angle:Number):uint {
            var radian:Number = angle * Math.PI / 180;
            var valR:uint = (Math.cos(radian)             + 1) * 0xFF >> 1;
            var valG:uint = (Math.cos(radian + DEGREE90)  + 1) * 0xFF >> 1;
            var valB:uint = (Math.cos(radian + DEGREE180) + 1) * 0xFF >> 1;
            return valR << 16 | valG << 8 | valB;
        }
    }
//}

package {
    import com.bit101.components.PushButton;
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.events.Event;
    import frocessing.color.ColorHSV;
    [SWF(width = "465", height = "465", frameRate = "30", backgroundColor = "#000000")]
    /**
     * マンデルブロ集合の描画
     * @author Aquioux(Yoshida, Akio)
     * @see http://aquioux.net/blog/?p=1216
     * @see http://aquioux.net/blog/?p=1205
     * @see http://aquioux.net/blog/?p=1189
     * @see http://aquioux.net/blog/?p=1176
     * @see http://aquioux.net/blog/?p=1165
     * initial state "colorfl" & "*1"
     */
    public class Main1 extends Sprite {
        private const W:int = stage.stageWidth;
        private const H:int = stage.stageHeight;

        private var colors0_:Vector.<uint>;
        private var colors1_:Vector.<uint>;
        private var colors2_:Vector.<uint>;
        
        private var bmd_:BitmapData;
        
        public function Main1():void {
            colors0_ = new Vector.<uint>();
            for (var i:int = 0; i < 50; i++) colors0_[i] = 0xFFFFFF;
            colors0_.fixed = true;

            colors1_ = new Vector.<uint>();
            var degree:int = 0x33;
            var step:Number = 0xFF / degree;
            for (i = 0; i < degree; i++) {
                var c:uint = step * i;
                colors1_[i] = 0xFF << 16 | c << 8 | c;
            }
            colors1_.fixed = true;
            
            colors2_ = new Vector.<uint>();
            degree = 45;
            step = 270 / degree;
            for (i = 0; i < degree; i++) colors2_[i] = CycleRGB.getColor(i * step + 180);
            colors2_.reverse();
            colors2_.fixed = true;

            bmd_ = new BitmapData(W, H, false, 0x0);
            addChild(new Bitmap(bmd_));
            
            var buttonWidth:int = 50;
            var button0:PushButton = new PushButton(this, 0, H - 40, "B/W", button0Handler);
            var button1:PushButton = new PushButton(this, buttonWidth, H - 40, "monotone", button1Handler);
            var button2:PushButton = new PushButton(this, buttonWidth * 2, H - 40, "colorful", button2Handler);
            var button3:PushButton = new PushButton(this, 0, H - 20, "* 1", button3Handler);
            var button4:PushButton = new PushButton(this, buttonWidth, H - 20, "* 2", button4Handler);
            var button5:PushButton = new PushButton(this, buttonWidth * 2, H - 20, "* 10", button5Handler);
            button0.width = buttonWidth;
            button1.width = buttonWidth;
            button2.width = buttonWidth;
            button3.width = buttonWidth;
            button4.width = buttonWidth;
            button5.width = buttonWidth;
            
            button2Handler(null);
        }
        
        private function draw():void {
            bmd_.setVector(bmd_.rect, Mandelbrot.update(W, H));
        }
        
        private function button0Handler(e:Event):void {
            Mandelbrot.divergenceColors = colors0_;
            draw();
        }
        private function button1Handler(e:Event):void {
            Mandelbrot.divergenceColors = colors1_;
            draw();
        }
        private function button2Handler(e:Event):void {
            Mandelbrot.divergenceColors = colors2_;
            draw();
        }
        private function button3Handler(e:Event):void {
            Mandelbrot.zoom = 1.0;
            Mandelbrot.offsetX = 0.0;
            Mandelbrot.offsetY = 0.0;
            draw();
        }
        private function button4Handler(e:Event):void {
            Mandelbrot.zoom = 2.0;
            Mandelbrot.offsetX = 0.0;
            Mandelbrot.offsetY = 0.0;
            draw();
        }
        private function button5Handler(e:Event):void {
            Mandelbrot.zoom = 10.0;
            Mandelbrot.offsetX = -0.75;
            Mandelbrot.offsetY = -0.25;
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
            // z_n+1
            var zRlNxt:Number;        // 実数部
            var zImNxt:Number;        // 虚数部
            
            var i:int = degree;
            while (i--) {
                // 発散の評価
                zRlSqr = zRl * zRl;
                zImSqr = zIm * zIm;
                if (zRlSqr + zImSqr > 4) break;
                // 発散していなかった場合、再評価へ向けて z_n の値を更新する
                zRlNxt = zRlSqr - zImSqr + cRl;
                zImNxt = 2 * zRl * zIm + cIm;
                zRl = zRlNxt;
                zIm = zImNxt;
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

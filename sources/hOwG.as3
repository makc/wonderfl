package {
    import com.bit101.components.HUISlider;
    import com.bit101.components.Label;
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.geom.Rectangle;
    import flash.ui.Keyboard;
    [SWF(width="465", height="465", frameRate="60", backgroundColor="0x000000")]
    /**
     * Gray-Scott モデルの反応拡散方程式
     * @author YOSHIDA, Akio
     * @see http://aquioux.net/blog/?p=3724
     * 
     * 【モデル】
     * 2U + V -> 3U
     * U -> P
     *   V : 原材料となる化学物質
     *   U : 中間生成物かつ自己触媒物質
     *   P : 最終生成物（式には出てこない）
     *   反応を全体としてみると、V -> P という一方向反応で、
     *   原材料 V は外部から常に供給されることで永続的な反応が可能となる（開放系）。
     *
     * 【方程式】
     * ut = duΔu + u^2v - (F+k)u
     * vt = dvΔv - u^2v + F(1-v)
     *   du : U の拡散率
     *   dv : V の拡散率
     *     du と dv の比率を変化させると、描画パターンの大きさが変化する
     *   F  : 原材料 V の外部からの供給率＆中間生成物 U の外部への流出率
     *   k  : 中間生成物 U の最終生成物 P への転換率（U の除去率）
     *     F, k を変えると、描画パターン形状が変化する
     */
    public class Main extends Sprite {
        // ビューアサイズ
        private const IMAGE_WIDTH:int  = 300;
        private const IMAGE_HEIGHT:int = 300;
        // ビューアのピクセル数
        private const NUM_OF_PIXELS:int = IMAGE_WIDTH * IMAGE_HEIGHT;

        // ビューアサイズからそれぞれ -1（ビューア.getVector で得られたリストを計算するときのため）
        private const IMAGE_WIDTH_FOR_LIST:int  = IMAGE_WIDTH  - 1;
        private const IMAGE_HEIGHT_FOR_LIST:int = IMAGE_HEIGHT - 1;

        // 反応速度（値を大きくすると速くなる）
        private const SPEED:int = 7;

        // 反応パラメータ
        private var f_:Number;
        private var k_:Number;
        // 拡散パラメータ
        private var dv_:Number;
        private var du_:Number;

        // 濃度リスト
        private var vList_:Vector.<Number>;    // 原材料
        private var uList_:Vector.<Number>;    // 中間生成物

        // ビューア
        private var viewer_:Sprite;
        private var viewBmd_:BitmapData = new BitmapData(IMAGE_WIDTH, IMAGE_HEIGHT, false, 0xffffff);
        private var viewList_:Vector.<uint>;
        private const RECT:Rectangle = new Rectangle(0, 0, IMAGE_WIDTH, IMAGE_HEIGHT);
        
        // パターン名ラベル
        private var patternLabel_:Label;

        // マウスダウン判定
        private var isMouseDown_:Boolean;

        // パラメータ変更用スライダー
        private var fSlider_:HUISlider;        // 反応パラメータ f 用
        private var kSlider_:HUISlider;        // 反応パラメータ k 用
        private var dvSlider_:HUISlider;    // 拡散パラメータ Dv 用
        private var duSlider_:HUISlider;    // 拡散パラメータ Du 用


        // コンストラクタ
        public function Main() {
            setup();
            addEventListener(Event.ENTER_FRAME, update);
            viewer_.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
            viewer_.addEventListener(MouseEvent.MOUSE_UP,   mouseUpHandler);
            viewer_.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
            stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
        }


        // セットアップ
        private function setup():void {
            // ステージサイズ
            var stageWidth:int = stage.stageWidth;

            // スライダー生成
            var shiftX:int = 5;
            fSlider_  = new HUISlider(this, shiftX,  0, "F ", fSliderHandler);
            kSlider_  = new HUISlider(this, shiftX, 20, "K ", kSliderHandler);
            dvSlider_ = new HUISlider(this, shiftX, 40, "Dv", dvSliderHandler);
            duSlider_ = new HUISlider(this, shiftX, 60, "Du", duSliderHandler);
            fSlider_.width  = stageWidth - shiftX * 2;
            kSlider_.width  = stageWidth - shiftX * 2;
            dvSlider_.width = stageWidth - shiftX * 2;
            duSlider_.width = stageWidth - shiftX * 2;
            var precision:int = 5;
            var tick:Number = 1 / Math.pow(10, precision);
            fSlider_.labelPrecision  = precision;
            kSlider_.labelPrecision  = precision;
            dvSlider_.labelPrecision = precision;
            duSlider_.labelPrecision = precision;
            fSlider_.tick  = tick;
            kSlider_.tick  = tick;
            dvSlider_.tick = tick;
            duSlider_.tick = tick;
        
            // ビューア生成
            viewer_ = new Sprite();
            addChild(viewer_);
            viewer_.addChild(new Bitmap(viewBmd_));
            viewer_.x = (stageWidth - IMAGE_WIDTH) / 2;
            viewer_.y = 90;
            
            // パターン名ラベル生成
            patternLabel_ = new Label(this, viewer_.x, 390, "");
            // Usage 生成
            var usage:Label = new Label(this, 170, 390, "[USAGE]\nSPACE Key : init, concentration of reactant\nRIGHT Key : next pattern\nLEFT Key : prev pattern\nMouse DRAG : change, concentration of reactant on Mouse cursor");
            
            // パラメータ
            Parameters.setup();
            // 反応拡散パラメータ値をスライダーとパラメータに設定
            setRange(Parameters.range);
            changeParameters(Parameters.current());

            // 各リスト生成
            viewList_ = new Vector.<uint>(NUM_OF_PIXELS, true);
            vList_    = new Vector.<Number>(NUM_OF_PIXELS, true);
            uList_    = new Vector.<Number>(NUM_OF_PIXELS, true);

            // 濃度初期化
            init();
        }

        // アップデート
        private function update(event:Event):void {
            var c:int = SPEED;
            while (--c) calc();
            draw();
        }

        // マウスイベントハンドラ
        private function mouseDownHandler(event:MouseEvent):void {
            isMouseDown_ = true;
        }
        private function mouseUpHandler(event:MouseEvent):void {
            isMouseDown_ = false;
        }
        private function mouseMoveHandler(event:MouseEvent):void {
            interference(event.localX >> 0, event.localY >> 0, isMouseDown_);
        }

        // キーボードイベントハンドラ
        private function keyDownHandler(event:KeyboardEvent):void {
            switch (event.keyCode) {
                case Keyboard.SPACE:
                    init();
                    break;
                case Keyboard.LEFT:
                    changeParameters(Parameters.prev());
                    break;
                case Keyboard.RIGHT:
                    changeParameters(Parameters.next());
                    break;
            }
        }

        // スライダーハンドラ
        private function fSliderHandler(event:Event):void {
            f_ = fSlider_.value;
        }
        private function kSliderHandler(event:Event):void {
            k_ = kSlider_.value;
        }
        private function dvSliderHandler(event:Event):void {
            dv_ = dvSlider_.value;
        }
        private function duSliderHandler(event:Event):void {
            du_ = duSlider_.value;
        }


        // パラメータ変更時の処理
        private function changeParameters(data:Array):void {
            patternLabel_.text = data[0];    // パターン名表示
            setParameters(data[1]);            // 変更したパラメータのセット
        }

        // スライダーの最小値と最大値を設定
        private function setRange(ranges:Vector.<Number>):void {
            fSlider_.minimum  = ranges[0];
            fSlider_.maximum  = ranges[1];
            kSlider_.minimum  = ranges[2];
            kSlider_.maximum  = ranges[3];
            dvSlider_.minimum = ranges[4];
            dvSlider_.maximum = ranges[5];
            duSlider_.minimum = ranges[6];
            duSlider_.maximum = ranges[7];
        }
        // パラメータのプリセット値のセット
        private function setParameters(parameters:Vector.<Number>):void {
            fSlider_.value  = parameters[0];
            kSlider_.value  = parameters[1];
            dvSlider_.value = parameters[2];
            duSlider_.value = parameters[3];
            fSliderHandler(null);
            kSliderHandler(null);
            dvSliderHandler(null);
            duSliderHandler(null);
        }


        // 原材料および中間生成物の濃度を初期化
        private function init():void {
            var len:int = NUM_OF_PIXELS;
            for (var i:int = 0; i < len; i++) {
                // 最初の原材料濃度はすべて 1.0 にする
                vList_[i] = 1.0;
                uList_[i] = Math.random() < 0.001 ? 0.5 + Math.random() * 0.5 : 0.0;
                // 中間生成物濃度が 0.0 のときは何も表示されず、そうでない場合は黒い点となる
                // 原材料濃度を視覚化するということは、原材料濃度が 1.0 に近づくほど白くなり、0.0 に近づくほど黒くなる
                // 中間生成物が存在するということは、原材料が消費されるということなので、0.0 に近づくことになり、そのため黒くなる
            }
        }

        // 原材料と中間生成物の濃度への干渉
        private function interference(posX:int, posY:int, flg:Boolean):void {
            // 当該ピクセルと近傍4ピクセルのリスト上の位置を計算
            var current:int = posY * IMAGE_WIDTH + posX;
            var west:int    = posX == 0 ? current : current - 1;                                // 左
            var east:int    = posX == IMAGE_WIDTH_FOR_LIST  ? current : current + 1;            // 右
            var north:int   = posY == 0 ? current : current - IMAGE_WIDTH;                        // 上
            var south:int   = posY == IMAGE_HEIGHT_FOR_LIST ? current : current + IMAGE_WIDTH;    // 下
            // 当該ピクセルと近傍4ピクセルにのみ init() と同じ処理
            if (flg) {
                var vVal:Number = 1.0;
                vList_[current] = vVal;
                vList_[west]    = vVal;
                vList_[east]    = vVal;
                vList_[north]   = vVal;
                vList_[south]   = vVal;
                var uVal:Number = 0.5 + Math.random() * 0.5;
                uList_[current] = uVal;
                uList_[west]    = uVal;
                uList_[east]    = uVal;
                uList_[north]   = uVal;
                uList_[south]   = uVal;
            }
        }

        // 原材料および中間生成物の濃度の更新（反応拡散計算）
        public function calc():void {
            var len:int = NUM_OF_PIXELS;
            for (var i:int = 0; i < len; i++) {
                // カレントピクセルの座標
                var posX:int  = i % IMAGE_WIDTH;
                var posY:int  = i / IMAGE_WIDTH >> 0;
                // 近傍4ピクセルのリスト上の位置を計算
                var west:int  = posX == 0 ? i : i - 1;                                    // 左
                var east:int  = posX == IMAGE_WIDTH_FOR_LIST  ? i : i + 1;                // 右
                var north:int = posY == 0 ? i : i - IMAGE_WIDTH;                        // 上
                var south:int = posY == IMAGE_HEIGHT_FOR_LIST ? i : i + IMAGE_WIDTH;    // 下

                // カレントの濃度値
                var currentV:Number = vList_[i];
                var currentU:Number = uList_[i];

                // 拡散項の計算
                var diffusionV:Number = dv_ * (vList_[west] + vList_[east] + vList_[north] + vList_[south] - 4 * currentV);
                var diffusionU:Number = du_ * (uList_[west] + uList_[east] + uList_[north] + uList_[south] - 4 * currentU);

                // 反応項の計算(1)
                var reaction1:Number = currentV * currentU * currentU;    // 2U + V -> 3U
                // 反応項の計算(2)
                var reaction2V:Number = f_ * (1 - currentV);    // 原材料 V の外部からの供給
                var reaction2U:Number = (f_ + k_) * currentU;    // U -> P （U の除去）

                // 反応拡散の計算
                currentV += (diffusionV - reaction1 + reaction2V);    // reaction1 は除去、reaction2V は供給：原材料
                currentU += (diffusionU + reaction1 - reaction2U);    // reaction1 は供給、reaction2U は除去：中間生成物
                if (currentV < 0.0) currentV = 0.0;
                if (currentV > 1.0) currentV = 1.0;
                if (currentU < 0.0) currentU = 0.0;
                if (currentU > 1.0) currentU = 1.0;
                vList_[i] = currentV;
                uList_[i] = currentU;
            }
        }

        // 原材料の濃度を視覚化（反応拡散の描画）
        private function draw():void {
            // 原材料の濃度を色に変換し、リストに格納
            var len:int = NUM_OF_PIXELS;
            for (var i:int = 0; i < len; i++) {
                var gray:int = vList_[i] * 255 >> 0;
                viewList_[i] = gray << 16 | gray << 8 | gray;
            }
            // BitmapData に反映
            viewBmd_.lock();
            viewBmd_.setVector(RECT, viewList_);
            viewBmd_.unlock();
        }
    }
}



//package {
    /**
     * Gray-Scott モデルの反応拡散方程式のパラメータ・データ
     * @author YOSHIDA, Akio
     */
    /*public*/ class Parameters {
        // 各パラメータの最小値と最大値
        static private var range_:Vector.<Number>;
        // 各パラメータのプリセット値
        static private var preset_:Vector.<Array>;
        // プリセット値リストのカレントインデックス
        static private var idx_:int = 0;


        /**
         * セットアップ
         */
        static public function setup():void {
            // 各パラメータの最小値と最大値
            range_ = Vector.<Number>([
                0.01000, 0.07000,    // F  の最小値, 最大値,
                0.01000, 0.07000,    // k  の最小値, 最大値,
                0.01000, 0.15000,    // Dv の最小値, 最大値,
                0.01000, 0.15000    // Du の最小値, 最大値
            ]);

            // 各パラメータのプリセット値（F, k, Dv, Du の順）
            preset_ = new Vector.<Array>();
            preset_.push(["Pattern 1",  Vector.<Number>([0.02500,    0.05424,    0.1,    0.05])]);
            preset_.push(["Pattern 2",  Vector.<Number>([0.02500,    0.05650,    0.1,    0.05])]);
            preset_.push(["Pattern 3",  Vector.<Number>([0.03000,    0.05500,    0.1,    0.05])]);
            preset_.push(["Pattern 4",  Vector.<Number>([0.06200,    0.06200,    0.1,    0.05])]);
            preset_.push(["Pattern 5",  Vector.<Number>([0.01200,    0.05000,    0.1,    0.05])]);
            preset_.push(["Pattern 6",  Vector.<Number>([0.03500,    0.06010,    0.1,    0.05])]);
            preset_.push(["Pattern 7",  Vector.<Number>([0.03600,    0.06300,    0.1,    0.05])]);
            preset_.push(["like BZ",    Vector.<Number>([0.02000,    0.04800,    0.1,    0.15])]);
            
            // プリセット値リストのカレントインデックス
            idx_ = 0;
        }
        
        /**
         * 範囲を返す
         */
        static public function get range():Vector.<Number> {
            return range_;
        }

        /**
         * 現在のプリセット値を返す
         */
        static public function current():Array {
            return preset_[idx_];
        }
        /**
         * 前のプリセット値を返す
         */
        static public function prev():Array {
            idx_--;
            if (idx_ < 0) idx_ = preset_.length - 1;
            return current();
        }
        /**
         * 次のプリセット値を返す
         */
        static public function next():Array {
            idx_++;
            idx_ %= preset_.length;
            return current();
        }
    }
//}

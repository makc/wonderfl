package {
    /**
     * perlin waves(mouse move reaction)
     * @author YOSHIDA, Akio (Aquioux)
     * @see http://wonderfl.net/c/7D0s (perlin waves)
     * @see http://wonderfl.net/c/jvIs (perlinNoise, mouse move reaction)
     */
    //import aquioux.display.colorUtil.CycleRGB;
    import flash.display.Graphics;
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.filters.BitmapFilterQuality;
    import flash.filters.BlurFilter;
    import flash.geom.ColorTransform;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    [SWF(width = "465", height = "465", frameRate = "30", backgroundColor = "#000000")]

    public class Main extends Sprite {

        // ステージサイズ関係
        private const SW:int = stage.stageWidth;
        private const SH:int = stage.stageHeight;
        private const CX:Number = SW / 2;
        private const CY:Number = SH / 2;
        

        // perlinNoise 関係
        private var perlinBmd_:BitmapData;
        private var perlinBm_:Bitmap;
        
        private const PERLIN_WIDTH:int  = 31;
        private const PERLIN_HEIGHT:int = 31;
        
        //private var offsets_:Array = [new Point(), new Point(), new Point(), new Point()];
        private var offsets_:Array = [new Point(), new Point()];
        private const OCTAVES:uint = offsets_.length;
        
        private var isDisp:Boolean = false;
        

        // 線描画関係
        private var lineCanvas_:Shape;

        private const INTERVAL_WIDTH:Number  = SW / (PERLIN_WIDTH - 1);
        private const INTERVAL_HEIGHT:Number = 0xFF / SH;
        private const INTERVAL_COLOR:Number  = 360 / PERLIN_HEIGHT;
        
        private var g_:Graphics;
        private var colors_:Vector.<uint>;
        

        // 表示関係
        private var viewBmd_:BitmapData;

        private const RECT:Rectangle = new Rectangle(0, 0, SW, SH);
        private const ZERO_POINT:Point = new Point();
        private const BLUR:BlurFilter = new BlurFilter(16, 16, BitmapFilterQuality.HIGH);
        private const COLOR_TRANS:ColorTransform = new ColorTransform(1, 1, 1, 0.25);


        // コンストラクタ
        public function Main() {
            setup();
            addEventListener(Event.ENTER_FRAME, update);
            stage.addEventListener(MouseEvent.CLICK, clickHandler);
        }

        // セットアップ
        private function setup():void {
            // perlinNoise 用 BitmapData 生成
            perlinBmd_ = new BitmapData(PERLIN_WIDTH, PERLIN_HEIGHT, false, 0x000000);
            perlinBm_  = new Bitmap(perlinBmd_);
            addChild(perlinBm_);
            
            clickHandler(null);
            
            // 表示用 BitmapData 生成
            viewBmd_ = new BitmapData(SW, SH, true, 0xFF000000);
            addChild(new Bitmap(viewBmd_));
            
            // 線描画カンバス生成
            lineCanvas_ = new Shape();
            g_ = lineCanvas_.graphics;
            
            // 線色設定
            colors_ = new Vector.<uint>();
            var angle:Number = 0;
            for (var i:int = 0; i < PERLIN_HEIGHT; i++) {
                colors_.push(CycleRGB.getColor(angle));
                angle += INTERVAL_COLOR;
            }
            colors_.fixed = true;
        }

        // アップデート
        private function update(e:Event):void {
            updatePerlinNoise();
            updateLines();
            updateView();
        }
        // perlinNoise の更新
        private function updatePerlinNoise():void {
            // offsets_ の更新
            var offsetX:Number = (mouseX / CX - 1) * 0.5;
            var offsetY:Number = (mouseY / CY - 1) * 0.5;
            offsets_[0].x += offsetX;
            offsets_[0].y += offsetY;
            offsets_[1].x -= offsetX;
            offsets_[1].y -= offsetY;
            //offsets_[2].x += offsetX;
            //offsets_[2].y -= offsetY;
            //offsets_[3].x -= offsetX;
            //offsets_[3].y += offsetY;
            // perlinNoise の更新
            perlinBmd_.perlinNoise(PERLIN_WIDTH, PERLIN_HEIGHT, OCTAVES, 0xFF, true, true, 1, true, offsets_);
        }
        // 線の更新
        private function updateLines():void {
            g_.clear();
            for (var h:int = 0; h < PERLIN_HEIGHT; h++) {
                g_.moveTo(-20, h);
                g_.lineStyle(0, colors_[h], 1);
                for (var w:int = 0; w < PERLIN_WIDTH; w++) {
                    var value:Number = (perlinBmd_.getPixel(w, h) & 0xFF) / INTERVAL_HEIGHT;
                    g_.lineTo(w * INTERVAL_WIDTH, value);
                }
            }
        }
        // 表示の更新
        private function updateView():void {
            viewBmd_.lock();
            viewBmd_.fillRect(RECT, 0xFF000000);
            viewBmd_.draw(lineCanvas_);
            viewBmd_.applyFilter(viewBmd_, RECT, ZERO_POINT, BLUR);
            viewBmd_.draw(lineCanvas_,null,COLOR_TRANS);
            viewBmd_.unlock();
        }
        
        private function clickHandler(e:MouseEvent):void {
            perlinBm_.visible = isDisp;
            isDisp = !isDisp;
        }
    }
}


//package aquioux.display.colorUtil {
    /**
     * コサインカーブで色相環的な RGB を計算
     * @author Aquioux(YOSHIDA, Akio)
     */
    /*public*/ class CycleRGB {
        /**
         * 32bit カラーのためのアルファ値
         */
        static public function get alpha():uint { return _alpha; }
        static public function set alpha(value:uint):void {
            _alpha = (value > 0xFF) ? 0xFF : value;
        }
        private static var _alpha:uint = 0xFF;
    
        private static const PI:Number = Math.PI;        // 円周率
        private static const DEGREE90:Number  = PI / 2;    // 90度（弧度法形式）
        private static const DEGREE180:Number = PI;        // 180度（弧度法形式）
        
        /**
         * 角度に応じた RGB を得る
         * @param    angle    HSV のように角度（度数法）を指定
         * @return    色（0xNNNNNN）
         */
        public static function getColor(angle:Number):uint {
            var radian:Number = angle * PI / 180;
            var valR:uint = (Math.cos(radian)             + 1) * 0xFF >> 1;
            var valG:uint = (Math.cos(radian + DEGREE90)  + 1) * 0xFF >> 1;
            var valB:uint = (Math.cos(radian + DEGREE180) + 1) * 0xFF >> 1;
            return valR << 16 | valG << 8 | valB;
        }
        
        /**
         * 角度に応じた RGB を得る（32bit カラー）
         * @param    angle    HSV のように角度（度数法）を指定
         * @return    色（0xNNNNNNNN）
         */
        public static function getColor32(angle:Number):uint {
            return _alpha << 24 | getColor(angle);
        }
        
    }

//}

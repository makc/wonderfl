package {
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Graphics;
    import flash.display.Loader;
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.net.URLRequest;
    import flash.system.LoaderContext;
    import frocessing.color.ColorRGB;
    [SWF(width = "465", height = "465", frameRate = "30", backgroundColor = "#FFFFFF")]
    
    /**
     * Code P_4_3_1_01
     * @author Aquioux(Yoshida, Akio)
     * 
     * Porting AS from Processing
     * "Generative Gestaltung" Page 302 (http://www.amazon.co.jp/gp/product/3874397599?ie=UTF8&tag=laxcomplex-22)
     * @see http://www.generative-gestaltung.de/P_4_3_1_01
     *
     * "Generative Gestaltung" のサンプルコード P.4.3.1.01(Page 302)を ActionScript 3.0 に移植したものです。
     * オレオレアレンジを施しています。
     * 
     * Picture 「写真素材　足成」　http://www.ashinari.com/
     */
    public class Main extends Sprite {
        // イメージのサイズ
        private var imgW_:uint;
        private var imgH_:uint;
        
        // スケール
        private const INTERVAL_X:Number = 4.0;
        private const INTERVAL_Y:Number = 4.0;
        
        // マウス位置計算用
        private const SH:uint   = stage.stageHeight;
        private const CX:Number = stage.stageWidth / 2;
        
        // マウス座標に連動する変数
        private var mX_:Number;
        private var mY_:Number;
        
        private var rgb_:ColorRGB;
        
        // 色格納 Vector
        private var bmdVector_:Vector.<uint>;
        private var grayVector_:Vector.<uint>;
        
        // キャンバス
        private var canvas_:Shape;

        // 移動距離
        private const DIST_RATIO:uint  = 20;
        // 線の太さ
        private const THICK_RATIO:uint = 0x44;
        
        // 表示開始オフセット
        private var offsetX_:Number;
        private var offsetY_:Number;


        public function Main() {
            var url:String = "http://assets.wonderfl.net/images/related_images/0/0d/0d28/0d2809088a12918d35bb22df299af02f4ecbe586";
            var loader:Loader = new Loader();
            loader.load(new URLRequest(url), new LoaderContext(true));
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler);
        }

        private function completeHandler(event:Event):void {
            init(Bitmap(event.target.loader.content));
            addEventListener(Event.ENTER_FRAME, update);
        }
        
        private function init(bm:Bitmap):void{
            rgb_ = new ColorRGB();
            
            var bmd:BitmapData = bm.bitmapData;
            imgW_ = bmd.width;
            imgH_ = bmd.height;
            offsetX_ = (stage.stageWidth  - imgW_ * INTERVAL_X) / 2;
            offsetY_ = (stage.stageHeight - imgH_ * INTERVAL_Y) / 2;
            
            bmdVector_ = bmd.getVector(bmd.rect);
            bmdVector_.fixed = true;

            var len:uint = bmdVector_.length;
            grayVector_ = new Vector.<uint>();
            for (var i:int = 0; i < len; i++) {
                rgb_.value32 = bmdVector_[i];
                bmdVector_[i] = rgb_.value;
                grayVector_.push(Math.round(rgb_.r * 0.222 + rgb_.g * 0.707 + rgb_.b * 0.071));
            }
            grayVector_.fixed = true;
            

            addChild(bm);

            canvas_ = new Shape();
            addChild(canvas_);
        }
        
        private function update(e:Event):void {
            mX_ = (mouseX - CX) / CX;
            mY_ = mouseY / SH;
            
            var g:Graphics = canvas_.graphics;
            g.clear();
            
            var len:uint = bmdVector_.length;
            for (var i:int = 0; i < len; i++) {
                var c1:uint    = bmdVector_[i];
                var gray1:uint = grayVector_[i];
                    
                var i2:uint = i + 1;
                var amari:uint = i2 % imgW_;
                if (amari == 0) i2 -= 1;
                var c2:uint    = bmdVector_[i2];
                var gray2:uint = grayVector_[i2];

                var thickness:Number = (0xFF - gray1) / THICK_RATIO * mY_;

                var d:Number = DIST_RATIO * mX_;
                var d1:Number = d * c1 / 0xFFFFFF;
                var d2:Number = d * c2 / 0xFFFFFF;
                
                var posX:Number = INTERVAL_X * (i % imgW_);
                var posY:Number = INTERVAL_Y * ((i / imgW_) >> 0);
                
                g.lineStyle(thickness, c2);
                g.moveTo(posX - d1 + offsetX_, posY + d1 + offsetY_);
                g.lineTo(posX + INTERVAL_X - d2 + offsetX_, posY + d2 + offsetY_);
            }
        }
    }
}
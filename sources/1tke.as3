/**
 * みんな大好き、ストレンジアトラクタ。　クリックでリスタート。
 * 
 * パラメータが時間と共に変わるバージョンですよ
 * http://wonderfl.net/code/90734a988f6be3310a692f419ea0c8e981660e4e
 * 
 * @author alumican.net
 */
package {
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.display.Sprite;
    import flash.filters.BlurFilter;
    import flash.geom.ColorTransform;
    import flash.geom.Point;
    import com.flashdynamix.utils.SWFProfiler;
    
    public class FlashTest extends Sprite {
        private const ZEROS:Point = new Point(0, 0);
        
        //パーティクル数
        private const N:uint = 10000;
        
        //パラメータ群
        private var _a:Number;
        private var _b:Number;
        private var _c:Number;
        private var _d:Number;
        
        //linked listの先頭インスタンス
        private var _head:Particle;
        
        //描画用
        private var _canvas:BitmapData;
        private var _w:uint;
        private var _h:uint;
        
        //エフェクト用
        private var _blur:BlurFilter = new BlurFilter(2, 2, 1);
        private var _trans:ColorTransform = new ColorTransform(0.999, 0.999, 0.999);
        
        //--------------------------------------------------
        //コンストラクタ
        public function FlashTest() {
            Wonderfl.disable_capture();
                        
            _w = stage.stageWidth;
            _h = stage.stageHeight;
            
            //パーティクル生成
            var o:Particle = _head = new Particle();
            for (var i:uint = 0; i < N; ++i) {
                o = o.next = new Particle();
            }
            
            //描画用BitmapData生成
            _canvas = new BitmapData(_w, _h, false, 0x000000);
            addChild(new Bitmap(_canvas));
            
            //イベントリスナ登録
            addEventListener(Event.ENTER_FRAME, _update);
            stage.addEventListener(MouseEvent.CLICK, _reset);
            
            //パラメータ群の初期化
            _reset();
            
            //プロファイラの表示
            SWFProfiler.init(this);
        }
        
        //--------------------------------------------------
        //パラメータ群の再設定
        private function _reset(e:MouseEvent = null):void {
            _canvas.fillRect(_canvas.rect, 0x000000);
            
            //パラメータの再設定と調整
            _a = (Math.random() - 0.5) * 3;
            _b = (Math.random() - 0.5) * 3;
            _c = (Math.random() - 0.5) * 6;
            _d = (Math.random() - 0.5) * 6;
            if (Math.abs(_a) < 0.8) _a += 0.8 * _a / Math.abs(_a);
            if (Math.abs(_b) < 0.8) _b += 0.8 * _b / Math.abs(_b);
            if (Math.abs(_c) < 1.0) _c += 1.0 * _c / Math.abs(_c);
            if (Math.abs(_d) < 1.0) _d += 1.0 * _d / Math.abs(_d);
            
            //パーティクルを分散させる
            var p:Particle = _head;
            do {
                p.x0 = (Math.random() - 0.5) * 2;
                p.y0 = (Math.random() - 0.5) * 2;
            }
            while (p = p.next);
        }
        
        //--------------------------------------------------
        //毎フレーム更新
        private function _update(e:Event):void {
            _canvas.lock();
            
            //パーティクル
            var p:Particle = _head;
            do {
                //座標の更新
                p.x1 = Math.sin(_a * p.y0) + _c * Math.cos(_a * p.x0);
                p.y1 = Math.sin(_b * p.x0) + _d * Math.cos(_b * p.y0);
                p.x0 = p.x1;
                p.y0 = p.y1;
                
                //描画
                _canvas.setPixel(_w / 2 + p.x1 * 70, _h / 2 + p.y1 * 70, 0xffffff);
            }
            while (p = p.next);
            
            //エフェクト
            _canvas.applyFilter(_canvas, _canvas.rect, ZEROS, _blur);
            _canvas.colorTransform(_canvas.rect, _trans);
            
            _canvas.unlock();
        }
    }
}

//--------------------------------------------------
//パーティクルクラス
internal class Particle {
    public var x1:Number;
    public var y1:Number;
    public var x0:Number;
    public var y0:Number;
    public var next:Particle;
}

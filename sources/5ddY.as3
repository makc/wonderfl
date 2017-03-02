package {
    
    //----------------------------------
    // Music by "SHW"(http://shw.in/)
    //----------------------------------
    
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.filters.BitmapFilter;
    import flash.filters.BlurFilter;
    import flash.geom.ColorTransform;
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.media.Sound;
    import flash.media.SoundChannel;
    import flash.media.SoundMixer;
    import flash.net.URLRequest;
    import flash.system.Security;
    import flash.utils.ByteArray;
    import flash.media.SoundLoaderContext;
    
    [SWF(width=465, height=465, backgroundColor=0x000000, frameRate=60)]
    public class SoundTest extends Sprite {
        private static const POLICY_FILE:String = "http://hycro.crz.jp/crossdomain.xml";
        private static const SOUND_FILE:String = "http://hycro.crz.jp/wonderfl/sound/u-chi-u.mp3";
        
        private var _sound:Sound = new Sound();
        private var _channel:SoundChannel;
        
        private var _leftBars:Vector.<Bar>;
        private var _rightBars:Vector.<Bar>;
        
        private var _canvas:Bitmap;
        private var _colorTransform:ColorTransform = new ColorTransform(.9, .9, .9);
        private var _filter:BitmapFilter = new BlurFilter(8, 4);
        
        {
            Wonderfl.capture_delay( 33 );
        }
        
        /**
         * コンストラクタ
         */
        public function SoundTest() {
            // 左右のバーを作成
            _leftBars = new Vector.<Bar>();
            _rightBars = new Vector.<Bar>();
            var bar:Bar;
            for (var i:uint=0; i<64; i++) {
                // 左
                bar = new Bar(0xffffff, false);
                bar.y = i * (Bar.LENGTH + Bar.MARGIN) + Bar.LENGTH + 10; // 回転後にずれるため Bar.LENGTH だけ足す
                bar.x = (Bar.LENGTH + Bar.MARGIN) * Bar.NUM_RECT;
                _leftBars.unshift(bar);
                
                // 右
                bar = new Bar(0xffffff, false);
                bar.y = i * (Bar.LENGTH + Bar.MARGIN) + 10;
                bar.x = Math.floor(stage.stageWidth / 2) + 1;
                _rightBars.unshift(bar);
            }
            
            // 描画用Bitmapの作成
            _canvas = new Bitmap(new BitmapData(stage.stageWidth, stage.stageHeight, true, 0xff000000));
            addChild(_canvas);
            
            // ポリシーファイルのロード
            //// たまにセキュリティ例外が出るのでSoundLoaderContextを使ってみる
            // やっぱり例外が出る。あとで勉強しよう。
            Security.loadPolicyFile(POLICY_FILE);
            
            // サウンドのロード
            _sound.addEventListener(Event.COMPLETE, onLoadComplete);
            _sound.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
            _sound.load(new URLRequest(SOUND_FILE), new SoundLoaderContext(10000, true));
        }
        
        /**
         * サウンドのロード完了。
         * サウンドを再生し、メインループを開始します。
         * 
         * @private
         */
        private function onLoadComplete(evt:Event):void {
            this.addEventListener(Event.ENTER_FRAME, loop);
            _channel = _sound.play(0, int.MAX_VALUE);
        }
        
        
        /**
         * メインループ
         * 
         * @private
         */
        private function loop(evt:Event):void {
            var data:ByteArray = new ByteArray();
            var matrix:Matrix;
            var rect:Rectangle = new Rectangle(0, 0, _canvas.width, _canvas.height);
            var dp:Point = new Point(0, 0);
            
            _canvas.bitmapData.lock();
            
            // スペクトラムの取得
            SoundMixer.computeSpectrum(data, true);
            
            // 色調整
            var d:Number = Math.max(_channel.rightPeak, _channel.leftPeak) * .02;
            _colorTransform.redMultiplier += (.5 - Math.random()) * d;
            _colorTransform.blueMultiplier += (.5 - Math.random()) * d;
            _colorTransform.greenMultiplier += (.5 - Math.random()) * d;
            _colorTransform.redMultiplier = Math.min(Math.max(_colorTransform.redMultiplier, .8), 1);
            _colorTransform.blueMultiplier = Math.min(Math.max(_colorTransform.blueMultiplier, .8), 1);
            _colorTransform.greenMultiplier = Math.min(Math.max(_colorTransform.greenMultiplier, .8), 1);
            _canvas.bitmapData.colorTransform(rect, _colorTransform);
            
            // ぼかしフィルター
            _canvas.bitmapData.applyFilter(_canvas.bitmapData, rect, dp, _filter);
            
            // 左チャンネルの描画
            for (var i:uint=0; i<64; i++) {
                _leftBars[i].setLevel(Math.sqrt((data.readFloat() + data.readFloat() + data.readFloat() + data.readFloat()) / 4));
                matrix = new Matrix();
                matrix.rotate(Math.PI)
                matrix.translate(_leftBars[i].x, _leftBars[i].y);
                _canvas.bitmapData.draw(_leftBars[i], matrix);
            }
                
            // 右チャンネルの描画
            for (i=0; i<64; i++) {
                _rightBars[i].setLevel(Math.sqrt((data.readFloat() + data.readFloat() + data.readFloat() + data.readFloat()) / 4));
                matrix = new Matrix();
                matrix.translate(_rightBars[i].x, _rightBars[i].y);
                _canvas.bitmapData.draw(_rightBars[i], matrix);
            }
            
            _canvas.bitmapData.unlock();
        }
        
        /**
         * ロード失敗
         * 
         * @private
         */
        private function onLoadError(evt:IOErrorEvent):void {
            trace("ロードに失敗しました");
        }
    }
}

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;

class Bar extends Sprite {
    // 四角の数
    public static const NUM_RECT:uint = 33;
    // 四角の大きさ
    public static const LENGTH:uint = 5;
    // マージン
    public static const MARGIN:uint = 2;
    // 最大時の長さ
    public static const MAX_LENGTH:uint = (LENGTH + MARGIN) * NUM_RECT - MARGIN;
    
    // Bar を構成する四角形
    private var _rects:Vector.<Bitmap>;
    
    /**
     * コンストラクタ
     */
    public function Bar(color:uint=0xffffff, gradient:Boolean=false) {
        var r:uint = (color & 0x00ff0000) >> 16;
        var g:uint = (color & 0x0000ff00) >> 8;
        var b:uint = (color & 0x000000ff);
        
        _rects = new Vector.<Bitmap>;
        for (var i:uint = 0; i < NUM_RECT; i++) {
            var grad:Number = Math.min(Math.sqrt((i+1)/NUM_RECT+.4), 1)
            var c:uint = (r*grad << 16) | (g*grad << 8) | b*grad;
            var bmp:Bitmap = new Bitmap(new BitmapData(LENGTH, LENGTH, false, gradient ? c : color));
            
            bmp.x = i * (LENGTH + MARGIN);
            _rects[i] = bmp;
            addChild(bmp);
            bmp.visible = false;
        }
    }
    
    /**
     * レベルを設定
     * 
     * @param level 0〜1の範囲の実数値
     */
    public function setLevel(level:Number):void {
        level = Math.min(NUM_RECT, Math.floor(NUM_RECT * level));
        
        for (var i:uint = 0; i<NUM_RECT; i++) {
            _rects[i].visible = i<level;
        }
    }
}

/* It's Show Time ! 
 * Make a music & Let's Scratch ramens !
 * 
 * ・具をトッピングしたり、どんぶりをスクラッチしたり、レバーをいじったりして遊びながら、
 * 　おいしいラーメン （音楽） を作ってください。
 * 
 * ・「Shiftキー + 既に置いてある具材をドラッグ」 で置き直せます。
 * 
 * ・トッピングした音は自動でビートに吸着するので、
 * 　適当に置いてもそれなりに聴けると思います。
 * 
 * 一部に propan_mode さん(http://propanmode.net/)が配布されている効果音と、
 * 音声読み上げソフト SofTalk (http://cncc.hp.infoseek.co.jp/)を使わせていただいています、多謝。
 * 
 * コードの汚さはおいしさに反比例しています。
 * さあレッツラ ラーメン！
 * 
 * @author alumican.net<Yukiya Okuda>
 * @link http://alumican.net/
 * 
 *****************************************
 * 
 * Draw a Tasty Ramen !
 * 
 * You can edit and modify every piece of this code.
 * Load more pictures of GU (ingredients of ramen)
 * from flickr or draw one by yourself.
 * Make it look tasty.
 * 
 */
package
{
    import flash.display.*;
    import org.libspark.thread.*;
    import com.flashdynamix.utils.SWFProfiler;
    
    public class FlashTest extends Sprite
    {
        public function FlashTest():void
        {
            //キャプチャ制御
            Wonderfl.disable_capture();
        //    Wonderfl.capture_delay(30);
            
            //ステージ初期化
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align     = StageAlign.TOP_LEFT;
            stage.frameRate = 60;
            
            //スレッドの開始
            Thread.initialize(new EnterFrameThreadExecutor());
            new MainThread(this).start();
            
            //プロファイラの表示
            SWFProfiler.init(this);
        }
    }
}

import flash.display.*;
import flash.errors.*;
import flash.events.*;
import flash.geom.*;
import flash.media.*;
import flash.net.*;
import flash.system.*;
import flash.text.*;
import flash.ui.*;
import flash.utils.*;
import org.libspark.betweenas3.*;
import org.libspark.betweenas3.easing.*;
import org.libspark.betweenas3.tweens.*;
import org.libspark.thread.*;
import org.libspark.thread.errors.*;
import org.libspark.thread.threads.display.*;
import org.libspark.thread.threads.media.*;
import org.libspark.thread.threads.net.*;
import org.libspark.thread.utils.*;





//------------------------------------------------------------------------------------------------------------------------------------------------------
/**                                                                                                                                           MainThread
 * メインスレッド
 */
internal class MainThread extends Thread
{
    //----------------------------------------
    //CONSTANTS
    //----------------------------------------
    
    
    
    
    
    //----------------------------------------
    //VARIABLES
    //----------------------------------------
    
    /**
     * stageの参照
     */
    public var stage:Stage;
    
    /**
     * ベースSprite
     */
    private var _base:Sprite;
    
    /**
     * リソース管理クラス
     */
    private var _resource:Resource;
    
    /**
     * コンポーザークラス
     */
    private var _composer:Composer;
    
    
    
    
    
    //----------------------------------------
    //METHODS
    //----------------------------------------
    
    public function MainThread(base:Sprite):void
    {
        this.stage = base.stage;
        _base      = base;
        
        //デバッガの初期化
        Debugger.initialize(_base);
    }
    
    /**
     * スレッドの実行関数
     */
    override protected function run():void 
    {
        Debugger.log("", "now loading...");
        
        //外部リソースを読み込む
        _resource = new Resource();
        _resource.start();
        _resource.join();
        
        next(_loadResourceComplete);
    }
    
    /**
     * 外部リソースの読み込み完了ハンドラ
     */
    private function _loadResourceComplete():void
    {
        Debugger.log("", "initializing...");
        
        _composer = new Composer(_base, _resource);
        _composer.start();
        _composer.join();
        
        next(null);
    }
}





//------------------------------------------------------------------------------------------------------------------------------------------------------
/**                                                                                                                                             Composer
 * コンポーザー
 */
internal class Composer extends Thread
{
    //----------------------------------------
    //CONSTANTS
    //----------------------------------------
    
    /**
     * ステージサイズ
     */
    private const W:uint = 465;
    private const H:uint = 465;
    
    
    
    
    
    //----------------------------------------
    //VARIABLES
    //----------------------------------------
    
    /**
     * stageの参照
     */
    public var stage:Stage;
    
    /**
     * ベースSprite
     */
    public function get base():Sprite { return _base; }
    private var _base:Sprite;
    
    /**
     * リソース管理クラス
     */
    private var _resource:Resource;
    
    /**
     * ターンテーブル
     */
    private var _tables:Array;
    
    /**
     * ターンテーブルの数
     */
     private var _tableCount:uint;
    
    /**
     * ピッチコントローラ
     */
     private var _pitchController:PitchController;
     
     /**
      * 音符アタッチャー
      */
     private var _noteAttacher:NoteAttacher;
     
     /**
      * カーソル
      */
     private var _cursor:Cursor;
    
    
    
    
    
    //----------------------------------------
    //METHODS
    //----------------------------------------
    
    public function Composer(base:Sprite, resource:Resource):void
    {
        this.stage = base.stage;
        _base      = base;
        _resource  = resource;
    }
    
    /**
     * スレッドの実行関数
     */
    override protected function run():void 
    {
        Debugger.log("", "run");
        
        _setupTables();
        _setupPitchController();
        _setupNoteAttacher();
        _setupCursor();
        
        //再生開始
        play();
    }
    
    /**
     * ターンテーブルを配置する
     */
    private function _setupTables():void
    {
        _tableCount = 2;
        _tables     = new Array(_tableCount);
        var table:Turntable;
        for (var i:uint = 0; i < _tableCount; ++i)
        {
            table = new Turntable(_resource, this, i);
            table.x = W / 4 * (i * 2 + 1);
            table.y = H / 2 - 30;
            _base.addChild(table);
            
            //配列に格納する
            _tables[i] = table;
        }
    }
    
    /**
     * ピッチコントローラの配置
     */
    private function _setupPitchController():void
    {
        _pitchController = new PitchController(_resource, this);
        _pitchController.x = 30;
        _pitchController.y = 40;
        _base.addChild(_pitchController);
    }
    
    /**
     * アタッチャーの配置
     */
    private function _setupNoteAttacher():void
    {
        _noteAttacher = new NoteAttacher(_resource, this);
        _base.addChild(_noteAttacher);
        
        _noteAttacher.x = (W - _noteAttacher.width) / 2;
        _noteAttacher.y = H - 70;
    }
    
    /**
     *マウストレーラーの配置
     */
    private function _setupCursor():void
    {
        _cursor = new Cursor(_resource, this);
        _base.addChild(_cursor);
    }
    
    /**
     * 再生開始
     */
    public function play():void
    {
        Debugger.log("");
        
        var table:Turntable;
        for (var i:uint = 0; i < _tableCount; ++i)
        {
            table = _tables[i];
            table.play();
        }
    }
    
    /**
     * ピッチコントローラからの再生ピッチの変更通知
     */
    public function notifyPitchControllerUpdate(pitch:Number):void
    {
        var table:Turntable;
        for (var i:uint = 0; i < _tableCount; ++i)
        {
            table = _tables[i];
            table.defaultPitch = pitch;
        }
    }
    
    /**
     * 音を合成する(xy座標)
     */
    public function synthSoundOnXY(bytes:Array, x:Number, y:Number, object:DisplayObject, mode:String):Array
    {
        var gp:Point = _noteAttacher.localToGlobal( new Point(x, y) );
        var table:Turntable, p:Point;
        var result:Array = new Array();
        for (var i:uint = 0; i < _tableCount; ++i)
        {
            table = _tables[i];
            p = table.getPolarFromXY( table.globalToLocal( gp.clone() ) );
            
            if (p.x <= 1)
            {
                (mode == "add") ? table.addFilling(object, p.x, p.y) : table.removeFilling(object);
                result.push(
                    {
                        discID   : i,
                        position : table.synthSoundUsingAngle(bytes[i], p.y, mode),
                        distance : p.x,
                        angle    : p.y
                    }
                );
            }
        }
        return result;
    }
    
    /**
     * 音を合成する(バイト番号)
     */
    public function synthSoundOnPosition(bytes:Array, discID:uint, position:uint, mode:String):void
    {
        Turntable(_tables[discID]).synthSoundUsingPosition(bytes[discID], position, mode);
    }
}





//------------------------------------------------------------------------------------------------------------------------------------------------------
/**                                                                                                                                            Turntable
 * ターンテーブル
 */
internal class Turntable extends Sprite
{
    //----------------------------------------
    //CONSTANTS
    
    /**
     * ピッチ可変再生のためのバッファ長
     */
    private const SOUND_BUFFER_LENGHT:uint = 2048; 
    
    /**
     * サンプリングレート(KHz)
     */
    private const SOUND_SAMPLING_RATE:Number = 44.1;
    
    /**
     * π
     */
    private const PI:Number  = Math.PI;
    private const PI2:Number = Math.PI * 2;
    
    
    
    
    
    //----------------------------------------
    //VARIABLES
    
    /**
     * リソース管理クラス
     */
    private var _resource:Resource;
    
    /**
     * コンポーザー
     */
    private var _composer:Composer;
    
    /**
     * ディスクID
     */
    private var _discID:uint;
    
    
    
    
    
    /**
     * メイントラック
     */
    private var _track:Sound;
    
    /**
     * 再生ピッチ
     */
    public function get pitch():Number { return _pitch; }
    public function set pitch(value:Number):void { _pitch = value; }
    private var _pitch:Number;
    
    /**
     * デフォルトの再生ピッチ
     */
    public function get defaultPitch():Number { return _defaultPitch; }
    public function set defaultPitch(value:Number):void { _defaultPitch = value; }
    private var _defaultPitch:Number;
    
    /**
     * メイントラックのByteデータ
     */
    private var _trackBytes:ByteArray;
    
    /**
     * メイントラックのByteデータ（合成前）
     */
    private var _trackBytesOriginal:ByteArray;
    
    //メイントラックの再生位置
    private var _trackPosition:Number;
    
    //メイントラックの総バイト数
    private var _trackBytesTotal:Number;
    
    //動的生成Sound
    private var _dynamicSound:Sound;
    
    //動的生成SoundChannel
    private var _dynamicSoundChannel:SoundChannel;
    
    /**
     * 再生中の場合はtrue
     */
    public function get isPlaying():Boolean { return _dynamicSoundChannel != null; }
    
    
    
    
    
    /**
     * disc用Sprite
     */
    private var _disc:Sprite;
    
    /**
     * どんぶり用Sprite
     */
    private var _bowl:Bitmap;
    
    /**
     * 具材用Sprite
     */
    private var _filling:Sprite;
    
    /**
     * ボタン領域
     */
    private var _area:Sprite;
    
    /**
     * スクラッチ中ならばtrue
     */
    public function get isScratching():Boolean { return _isScratching; }
    private var _isScratching:Boolean;
    
    /**
     * スクラッチ速度
     */
    public function get scratchVelocity():Number { return _scratchVelocity; }
    private var _scratchVelocity:Number;
    
    //スクラッチの角度
    private var _newScratchAngle:Number;
    private var _oldScratchAngle:Number;
    
    
    
    
    
    //----------------------------------------
    //METHODS
    
    /**
     * コンストラクタ
     */
    public function Turntable(resource:Resource, composer:Composer, discID:uint):void
    {
        _resource = resource;
        _composer = composer;
        _discID   = discID;
        
        addEventListener(Event.ADDED_TO_STAGE, _initialize);
        addEventListener(Event.REMOVED_FROM_STAGE, _finalize);
    }
    
    /**
     * 初期化関数
     */
    private function _initialize(e:Event):void 
    {

        _initializeImages();
        _initializeSounds();
    }
    
    /**
     * 画像の初期化
     */
    private function _initializeImages():void
    {
        //----------------------------------------
        //ディスク
        _disc = new Sprite();
        addChild(_disc);
        
        //----------------------------------------
        //どんぶり画像
        _bowl = _resource.bowlBmps(0);
        _bowl.x = -_bowl.width  / 2;
        _bowl.y = -_bowl.height / 2;
        _bowl.smoothing  = true;
        _disc.addChild(_bowl);
        
        //----------------------------------------
        //ボタン領域
        _area = new Sprite();
        var g:Graphics = _area.graphics;
        g.beginFill(0x0, 0);
        g.drawCircle(0, 0, _bowl.width / 2);
        g.endFill();
        _area.addEventListener(MouseEvent.MOUSE_DOWN, _mouseDownHandler);
        _area.buttonMode = true;
        _disc.addChild(_area);
        
        //----------------------------------------
        //具材
        _filling = new Sprite();
        _disc.addChild(_filling);
        
        _filling.mouseEnabled  = false;
        _filling.mouseChildren = false;
        stage.addEventListener(KeyboardEvent.KEY_DOWN, _keyDownHandler);
        stage.addEventListener(KeyboardEvent.KEY_UP  , _keyUpHandler);
    }
    
    /**
     * 音の初期化
     */
    private function _initializeSounds():void 
    {
        //----------------------------------------
        //ベーストラック
        _track = _resource.trackSounds(_discID);
        _trackBytes = new ByteArray();
        
        //Soundオブジェクトから生データ(ByteArray)を抽出する
        _track.extract(_trackBytes, _track.length * SOUND_SAMPLING_RATE * 8, 0);
        
        //Sound再生ヘッダを先頭へ移動する
        _trackPosition = 0;
        
        //Soundのバイト数を取得する
        _trackBytesTotal = _trackBytes.length;
        
        //3倍にする(読み取り領域がはみ出たときのため)
        var single:ByteArray = new ByteArray();
        single.writeBytes(_trackBytes, 0, _trackBytes.length);
        _trackBytes.writeBytes(single);
        _trackBytes.writeBytes(single);
        
        //復元用に保存する
        _trackBytesOriginal = new ByteArray();
        _trackBytes.position = 0;
        _trackBytes.readBytes(_trackBytesOriginal, 0, _trackBytes.length);
        
        //動的音生成のSoundを生成する
        _dynamicSound = new Sound();
        _dynamicSound.addEventListener(SampleDataEvent.SAMPLE_DATA, _onSoundSampleDataHandler);
        
        //デフォルトの再生ピッチ
        _defaultPitch = 1.0;
        
        //再生ピッチ
        _pitch = 1.0;
        
        //スクラッチ状況の初期化
        _isScratching    = false;
        _newScratchAngle = Math.atan2(mouseY, mouseX);
        _oldScratchAngle = _newScratchAngle;
        _scratchVelocity = 0;
    }
    
    /**
     * 終了関数
     */
    private function _finalize(e:Event):void
    {
        _finalizeImages();
        _finalizeSounds();
    }
    
    /**
     * 画像の終了処理
     */
    private function _finalizeImages():void
    {
    }
    
    /**
     * 音の終了処理
     */
    private function _finalizeSounds():void
    {
    }
    
    /**
     * 再生を開始する
     */
    public function play():void
    {
        if (isPlaying) return;
        
        //ピッチ計測開始
        addEventListener(Event.ENTER_FRAME, _updatePitch);
        
        //再生開始
        _dynamicSoundChannel = _dynamicSound.play();
    }
    
    /**
     * 再生を停止する
     */
    public function stop():void
    {
        if (!isPlaying) return;
        
        //ピッチ計測停止
        removeEventListener(Event.ENTER_FRAME, _updatePitch);
        
        //再生停止
        _dynamicSoundChannel.stop();
        _dynamicSoundChannel = null;
    }
    
    /**
     * 再生ピッチ調整
     */
    private function _updatePitch(e:Event):void 
    {
        _oldScratchAngle = _newScratchAngle;
        _newScratchAngle = Math.atan2(mouseY, mouseX);
        
        var targetPitch:Number;
        if (_isScratching)
        {
            var targetVelocity:Number = _newScratchAngle - _oldScratchAngle;
            if (targetVelocity < 0 ) targetVelocity += PI2;
            if (targetVelocity > PI) targetVelocity -= PI2;
            targetVelocity *= 50;
            
            _scratchVelocity += (targetVelocity - _scratchVelocity) * 0.5;
            targetPitch       = _scratchVelocity;
        }
        else
        {
            _scratchVelocity += (0 - _scratchVelocity) * 0.1;
            targetPitch       = _defaultPitch + _scratchVelocity;
        }
        
        _pitch += (targetPitch - _pitch) * 0.1;
    }
    
    /**
     * マウスダウンハンドラ
     */
    private function _mouseDownHandler(e:MouseEvent):void
    {
        _isScratching = true;
        stage.addEventListener(MouseEvent.MOUSE_UP, _mouseUpHandler);
    }
    
    /**
     * マウスアップハンドラ
     */
    private function _mouseUpHandler(e:MouseEvent):void
    {
        _isScratching = false;
        stage.removeEventListener(MouseEvent.MOUSE_UP, _mouseUpHandler);
    }
    
    /**
     * サウンドのサンプルデータハンドラ
     */
    private function _onSoundSampleDataHandler(e:SampleDataEvent):void 
    {
        //ピッチを0.5の倍数に調整する
        var normPitch:Number = Math.round(_pitch * 2) / 2;
        
        for (var i:uint = 0; i < SOUND_BUFFER_LENGHT; ++i) 
        {
            //ByteArrayの読み取りヘッダを移動する
            _trackPosition += normPitch * 8;
            
            //ループ処理
            if      (_trackPosition > _trackBytesTotal - 8) _trackPosition -= _trackBytesTotal;
            else if (_trackPosition <  7                  ) _trackPosition += _trackBytesTotal;
            
            //読み込みヘッダの移動(1トラック分オフセット)
            _trackBytes.position = _trackBytesTotal + _trackPosition;
            
            //ByteArrayの読み込みと書き込み
            e.data.writeFloat( _trackBytes.readFloat() / 2 );
            e.data.writeFloat( _trackBytes.readFloat() / 2 );
        }
        
        //ディスクの回転
        _disc.rotation = 360 * _trackPosition / _trackBytesTotal;
    }
    
    
    
    
    
    /**
     * トラックをSound合成前の状態に復元する
     */
    public function resetTrack():void
    {
        //トラックの復元
        _trackBytesOriginal.readBytes(_trackBytes, 0, _trackBytesOriginal.length);
        _trackBytesOriginal.position = 0;
    }
    
    
    
    
    
    /**
     * Soundを合成する
     */
    public function synthSoundUsingPosition(bytes:ByteArray, position:uint, mode:String):uint
    {
        var len:uint  = bytes.length;
        var last:uint = position + _trackBytesTotal + len;
        var dst:Number;
        
        //ブレンドモード
        var op:Number = (mode == "add") ?  1 :
                        (mode == "sub") ? -1 : 0;
        
        bytes.position = 0;
        
        for (var i:uint = position + _trackBytesTotal; i < last; i += 4) 
        {
            //合成(あとでちゃんと調べる)
            _trackBytes.position = i;
            dst = _trackBytes.readFloat() + op * bytes.readFloat() * 2;
            
            //中心の波形に書き込む
            _trackBytes.position = i;
            _trackBytes.writeFloat(dst);
            
            //前の波形に書き込む
            _trackBytes.position = i - _trackBytesTotal;
            _trackBytes.writeFloat(dst);
            
            //後ろの波形に書き込む
            if (i + len < _trackBytesTotal * 2)
            {
                _trackBytes.position = i + _trackBytesTotal;
                _trackBytes.writeFloat(dst);
            }
        }
        
        bytes.position = 0;
        
        return position;
    }
    
    /**
     * 任意のdisc角度にSoundを合成する
     */
    public function synthSoundUsingAngle(bytes:ByteArray, angle:Number, mode:String):uint
    {
        //なんか音が遅れるんですけど
        var adjust:Number = (_discID == 0) ? -0.10 : -0.05;
        
        //真上で鳴らす
        var ratio:Number = 0.75 - angle / PI2 + adjust;
        ratio %= 1;
        if (ratio < 0) ratio += 1;
        
        //var position:Number = _trackBytesTotal * ratio;
        //position = Math.round(position / 8) * 8;
        
        //ビートに乗せる
        var position:Number = _trackBytesTotal * ratio;
        var unit:int = 2 * SOUND_SAMPLING_RATE * 1000;
        position = Math.round(position / unit) * unit;
        
        synthSoundUsingPosition(bytes, position, mode);
        
        return position;
    }
    
    /**
     * disc中心を基準点とするxy座標から、discの回転を考慮した極座標を取得する
     * x : 角度[0, 2pi]
     * y : 中心からの距離[0, +inf]（1で円周上）
     */
    public function getPolarFromXY(p:Point):Point
    {
        var x:Number = p.x;
        var y:Number = p.y;
        
        var dist:Number  = Math.sqrt(x * x + y * y) / (_area.width / 2);
        var angle:Number = Math.atan2(y, x) - PI2 * _trackPosition / _trackBytesTotal;
        
        if (angle < 0  ) angle += PI2;
        if (angle > PI2) angle -= PI2;
        
        return new Point(dist, angle);
    }
    
    /**
     * 具材のDisplayObjectを追加する
     */
    public function addFilling(object:DisplayObject, dist:Number = 0, angle:Number = 0):DisplayObject
    {
        dist *= _area.width / 2;
        object.x = dist * Math.cos(angle);
        object.y = dist * Math.sin(angle);
        object.rotation -= _disc.rotation;
        
        return _filling.addChild(object);
    }
    
    /**
     * 具材のDisplayObjectを削除する
     */
    public function removeFilling(object:DisplayObject):DisplayObject
    {
        var angle:Number = _disc.rotation + Math.atan2(object.y, object.x) * 180 / PI;
        object.rotation += angle;
        
        return (_filling.contains(object)) ? _filling.removeChild(object) : null;
    }
    
    /**
     * 全ての具材のDisplayObjectを削除する
     */
    public function removeAllFilling():Array
    {
        var removed:Array = new Array();
        for (var i:uint = _filling.numChildren - 1; i >= 0; --i)
        {
            removed.push( _filling.removeChildAt(i) );
        }
        return removed;
    }
    
    /**
     * キープレスハンドラ
     */
    private function _keyDownHandler(e:KeyboardEvent):void 
    {
        if (e.keyCode == 16)
        {
            _filling.mouseEnabled  = true;
            _filling.mouseChildren = true;
        }
    }
    
    /**
     * キーアップハンドラ
     */
    private function _keyUpHandler(e:KeyboardEvent):void 
    {
        if (e.keyCode == 16)
        {
            _filling.mouseEnabled  = false;
            _filling.mouseChildren = false;
        }
    }
}





//------------------------------------------------------------------------------------------------------------------------------------------------------
/**                                                                                                                                         NoteAttacher
 * 音の合成UI
 */
internal class NoteAttacher extends Sprite
{
    //----------------------------------------
    //CONSTANTS
    
    /**
     * サンプリングレート(KHz)
     */
    private const SOUND_SAMPLING_RATE:Number = 44.1;
    
    
    
    
    
    //----------------------------------------
    //VARIABLES
    
    /**
     * リソース管理クラス
     */
    private var _resource:Resource;
    
    /**
     * コンポーザー
     */
    private var _composer:Composer;
    
    /**
     * 合成音のドラッグ元DisplayObject配列
     */
    private var _noteObjects:Array;
    
    /**
     * 合成音数
     */
    private var _noteCount:uint;
    
    /**
     * ドラッグ中のDisplayObject
     */
    private var _draggingObject:MovieClip;
    
    /**
     * 合成音のバイト列
     */
    private var _noteBytes:Array;
    
    /**
     * 具材名再生用SoundChannel
     */
    private var _fillingSoundChannel:SoundChannel;
    
    
    
    
    
    //----------------------------------------
    //METHODS
    
    /**
     * コンストラクタ
     */
    public function NoteAttacher(resource:Resource, composer:Composer):void
    {
        _resource = resource;
        _composer = composer;
        
        addEventListener(Event.ADDED_TO_STAGE, _initialize);
        addEventListener(Event.REMOVED_FROM_STAGE, _finalize);
    }
    
    /**
     * 初期化関数
     */
    private function _initialize(e:Event):void 
    {
        //コピー元を生成する
        _noteCount   = _resource.noteCount;
        _noteObjects = new Array(_noteCount);
        _noteBytes   = new Array(_noteCount);
        
        var p:Number = 0;
        for (var i:uint = 0; i < _noteCount; ++i)
        {
            //----------------------------------------
            //ドラッグ用のDisplayObject
            
            var bmp:Bitmap = _resource.fillingBmps(i);
            bmp.x = -bmp.width  / 2;
            bmp.y = -bmp.height / 2;
            bmp.smoothing = true;
            
            p += (i == 0) ? bmp.width / 2 : bmp.width / 2 + 10;
            
            var object:MovieClip = new MovieClip();
            object.addChild(bmp);
            object.initX = object.x = p;
            object.initY = object.y = 0;
            object.id = i;
            object.addEventListener(MouseEvent.MOUSE_DOWN, _mouseDownHandler);
            object.buttonMode = true;
            addChild(object);
            
            p += bmp.width / 2;
            
            _noteObjects[i] = object;
            
            //----------------------------------------
            //Soundオブジェクトから生データ(ByteArray)を抽出する
            _noteBytes[i] = new Array(2);
            for (var j:uint = 0; j < 2; ++j)
            {
                var note:Sound   = _resource.noteSounds(j, i);
                var ba:ByteArray = new ByteArray();
                note.extract(ba, note.length * SOUND_SAMPLING_RATE * 8);
                _noteBytes[i][j] = ba;
            }
        }
    }
    
    /**
     * 終了関数
     */
    private function _finalize(e:Event):void
    {
    }
    
    /**
     * コピー元DisplayObjectのマウスダウンハンドラ
     */
    private function _mouseDownHandler(e:MouseEvent):void
    {
        var o:MovieClip = _draggingObject = MovieClip(e.currentTarget);
        o.startDrag(false, null);
        o.x = mouseX;
        o.y = mouseY;
        
        //具材名を再生する
        if (_fillingSoundChannel != null) _fillingSoundChannel.stop();
        _fillingSoundChannel = _resource.fillingSounds(o.id).play();
        
        stage.addEventListener(MouseEvent.MOUSE_UP, _mouseUpHandler);
    }
    
    /**
     * コピー元DisplayObjectのマウスアップハンドラ
     */
    private function _mouseUpHandler(e:MouseEvent):void
    {
        var o:MovieClip = _draggingObject;
        var id:uint = o.id;
        
        //ドラッグ停止
        o.stopDrag();
        
        //具材の生成
        var bmp:Bitmap = _resource.fillingBmps(id);
        bmp.x = -bmp.width  / 2;
        bmp.y = -bmp.height / 2;
        var filling:MovieClip = new MovieClip();
        filling.id     = id;
        filling.addEventListener(MouseEvent.MOUSE_DOWN, _fillingMouseDownHandler);
        filling.addChild(bmp);
        
        //合成
        var result:Array = _composer.synthSoundOnXY(_noteBytes[id], o.x, o.y, filling, "add");
        if (result.length > 0)
        {
            filling.discID   = result[0].discID;
            filling.position = result[0].position;
            //_resource.noteSounds(id).play();
            
            //元の座標に戻す
            o.x = o.initX;
            o.y = o.initY;
            o.scaleX = o.scaleY = 0;
            BetweenAS3.tween(o, { scaleX:1, scaleY:1 }, null, 0.5, Bounce.easeOut).play();
        }
        else
        {
            //元の座標に戻す
            BetweenAS3.tween(o, { x:o.initX, y:o.initY, scaleX:1, scaleY:1 }, null, 0.5, Quart.easeOut).play();
        }
        
        stage.removeEventListener(MouseEvent.MOUSE_UP, _mouseUpHandler);
        
        _draggingObject = null;
    }
    
    /**
     * 配置済み具材のマウスダウンハンドラ
     */
    private function _fillingMouseDownHandler(e:MouseEvent):void 
    {
        var o:MovieClip = _draggingObject = MovieClip(e.currentTarget);
        var id:uint = o.id;
        
        //音を取る
        _composer.synthSoundOnPosition(_noteBytes[id], o.discID, o.position, "sub");
        
        //ドラッグ開始
        addChild(o);
        o.startDrag(false, null);
        o.x = mouseX;
        o.y = mouseY;
        
        //具材名を再生する
        if (_fillingSoundChannel != null) _fillingSoundChannel.stop();
        _fillingSoundChannel = _resource.fillingSounds(o.id).play();
        
        stage.addEventListener(MouseEvent.MOUSE_UP, _fillingMouseUpHandler);
    }
    
    /**
     * 配置済み具材のマウスアップハンドラ
     */
    private function _fillingMouseUpHandler(e:MouseEvent):void 
    {
        var o:MovieClip = _draggingObject;
        var id:uint = o.id;
        
        //ドラッグ終了
        o.stopDrag();
        
        //音の合成
        var result:Array = _composer.synthSoundOnXY(_noteBytes[id], o.x, o.y, o, "add");
        if (result.length > 0)
        {
            //再着地成功
            o.discID   = result[0].discID;
            o.position = result[0].position;
            o.distance = result[0].distance;
            o.angle    = result[0].angle;
        }
        else
        {
            //再着地失敗
            BetweenAS3.serial(
                BetweenAS3.tween(o, { scaleX:0, scaleY:0 }, null, 0.5, Quart.easeOut),
                BetweenAS3.func(function():void { removeChild(o); } )
            ).play();
            
            o.removeEventListener(MouseEvent.MOUSE_DOWN, _fillingMouseDownHandler);
        }
        stage.removeEventListener(MouseEvent.MOUSE_UP, _fillingMouseUpHandler);
        
        _draggingObject = null;
    }
}





//------------------------------------------------------------------------------------------------------------------------------------------------------
/**                                                                                                                                      PitchController
 * ピッチコントローラ
 */
internal class PitchController extends Sprite
{
    //----------------------------------------
    //CONSTANTS
    
    
    
    
    
    //----------------------------------------
    //VARIABLES
    
    /**
     * リソース管理クラス
     */
    private var _resource:Resource;
    
    /**
     * コンポーザー
     */
    private var _composer:Composer;
    
    /**
     * スライダーオブジェクト
     */
    private var _slider:Sprite;
    
    /**
     * ベースオブジェクト
     */
     private var _base:Sprite;
     
    /**
     * スライダーが示す再生ピッチ
     */
     private var _pitch:Number;
    
    /**
     * スライダーのデフォルト座標
     */
     private var _defaultSliderPosition:Number;
    
    
    
    
    //----------------------------------------
    //METHODS
    
    /**
     * コンストラクタ
     */
    public function PitchController(resource:Resource, composer:Composer):void
    {
        _resource = resource;
        _composer = composer;
        
        addEventListener(Event.ADDED_TO_STAGE, _initialize);
        addEventListener(Event.REMOVED_FROM_STAGE, _finalize);
    }
    
    /**
     * 初期化関数
     */
    private function _initialize(e:Event):void 
    {
        //----------------------------------------
        //ベースの生成
        _base = new Sprite();
        var g:Graphics = _base.graphics;
        g.beginFill(0xeeeeee);
        g.drawRoundRect(0, 0, 400, 3, 3);
        g.endFill();
        addChild(_base);
        
        _defaultSliderPosition = _base.x + _base.width / 2;
        
        //----------------------------------------
        //スライダーの生成
        _slider = new Sprite();
        var bmp:Bitmap = _resource.fillingBmps(5);
        bmp.x = -bmp.width  / 2;
        bmp.y = -bmp.height / 2;
        bmp.smoothing = true;
        _slider.addChild(bmp);
        _slider.x =  _defaultSliderPosition;
        _slider.addEventListener(MouseEvent.MOUSE_DOWN, _sliderMouseDownHandler);
        _slider.buttonMode = true;
        _slider.doubleClickEnabled = true;
        addChild(_slider);
        
        _calcPitch();
        
        addEventListener(Event.ENTER_FRAME, _updateRotation);
    }
    
    /**
     * 終了関数
     */
    private function _finalize(e:Event):void
    {
        removeEventListener(Event.ENTER_FRAME, _updateRotation);
    }
    
    /**
     * スライダーの座標から計算されたピッチを通知する
     */
    private function _calcPitch():void
    {
        //再生ピッチ計算(真ん中が1)
        _pitch = (_slider.x / (_base.x + _base.width)) * 10 - 4;
        if (_pitch < 0.5) _pitch -= 1.0;
     }
    
    /**
     * スライダーのマウスダウンハンドラ
     */
     private function _sliderMouseDownHandler(e:MouseEvent):void
     {
        //ドラッグ開始
        _slider.startDrag(false, new Rectangle(_base.x, _base.height / 2, _base.width, 0));
        
        stage.addEventListener(MouseEvent.MOUSE_MOVE, _sliderMouseMoveHandler);
        stage.addEventListener(MouseEvent.MOUSE_UP, _sliderMouseUpHandler);
        
        removeEventListener(Event.ENTER_FRAME, _updateAutoBackHandler);
     }
     
    /**
     * スライダーのマウスアップハンドラ
     */
     private function _sliderMouseUpHandler(e:MouseEvent):void
     {
        //ドラッグ停止
        _slider.stopDrag();
        
        stage.removeEventListener(MouseEvent.MOUSE_MOVE, _sliderMouseMoveHandler);
        stage.removeEventListener(MouseEvent.MOUSE_UP, _sliderMouseUpHandler);
        
        addEventListener(Event.ENTER_FRAME, _updateAutoBackHandler);
    }
     
    /**
     * スライダーのドラッグハンドラ
     */
     private function _sliderMouseMoveHandler(e:MouseEvent):void
     {
        _calcPitch();
        _composer.notifyPitchControllerUpdate(_pitch);
     }
     
     /**
      * マウスを話したときに自動で戻る
      */
     private function _updateAutoBackHandler(e:Event):void
     {
        var d:Number = _defaultSliderPosition - _slider.x;
        var a:Number = (d > 0) ? d : -d;
        
        if (a < 1.0)
        {
            _slider.x = _defaultSliderPosition;
            removeEventListener(Event.ENTER_FRAME, _updateAutoBackHandler);
        }
        else
        {
            _slider.x += d * 0.1;
        }
        
        _calcPitch();
        _composer.notifyPitchControllerUpdate(_pitch);
     }
     
     /**
      * ぐるぐる回しとく
      */
     private function _updateRotation(e:Event):void
     {
        _slider.rotation += _pitch * 5;
     }
}





//------------------------------------------------------------------------------------------------------------------------------------------------------
/**                                                                                                                                               Cursor
 * カーソル
 */
internal class Cursor extends Sprite
{
    //----------------------------------------
    //CONSTANTS
    
    
    
    
    
    //----------------------------------------
    //VARIABLES
    
    /**
     * リソース管理クラス
     */
    private var _resource:Resource;
    
    /**
     * コンポーザー
     */
    private var _composer:Composer;
    
    /**
     * マウストレーラー
     */
    private var _cursor:Sprite;
    
    /**
     * 通常時カーソル
     */
    private var _upBmp:Bitmap;
    
    /**
     * マウスダウン時カーソル
     */
     private var _downBmp:Bitmap;
    
    
    
    //----------------------------------------
    //METHODS
    
    /**
     * コンストラクタ
     */
    public function Cursor(resource:Resource, composer:Composer):void
    {
        _resource = resource;
        _composer = composer;
        
        addEventListener(Event.ADDED_TO_STAGE, _initialize);
        addEventListener(Event.REMOVED_FROM_STAGE, _finalize);
    }
    
    /**
     * 初期化関数
     */
    private function _initialize(e:Event):void 
    {
        //カーソル画像の取得
        _upBmp = _resource.cursorBmps(0);
        _upBmp.smoothing = true;
        
        _downBmp = _resource.cursorBmps(1);
        _downBmp.smoothing = true;
        _downBmp.visible = false;
        
        //マウストレーラーの生成
        _cursor = new Sprite();
        _cursor.mouseEnabled  = false;
        _cursor.mouseChildren = false;
        _cursor.addChild(_upBmp);
        _cursor.addChild(_downBmp);
        addChild(_cursor);
        
        Mouse.hide();
        var context:ContextMenu = new ContextMenu();
        context.addEventListener(ContextMenuEvent.MENU_SELECT, _contectMenuSelectHandler);
        _composer.base.contextMenu = context;
        
        stage.addEventListener(MouseEvent.MOUSE_DOWN, _mouseDownHandler);
        stage.addEventListener(MouseEvent.MOUSE_UP  , _mouseUpHandler);
        stage.addEventListener(MouseEvent.MOUSE_MOVE, _mouseMoveHandler);
    }
    
    /**
     * 終了関数
     */
    private function _finalize(e:Event):void
    {
        _cursor.removeChild(_upBmp);
        _cursor.removeChild(_downBmp);
        
        stage.removeEventListener(MouseEvent.MOUSE_DOWN, _mouseDownHandler);
        stage.removeEventListener(MouseEvent.MOUSE_UP  , _mouseUpHandler);
        stage.removeEventListener(MouseEvent.MOUSE_MOVE, _mouseMoveHandler);
        
        _upBmp   = null;
        _downBmp = null;
        _cursor  = null;
    }
    
    /**
     * マウスダウンハンドラ
     */
    private function _mouseDownHandler(e:MouseEvent):void
    {
        _upBmp.visible   = false;
        _downBmp.visible = true;
    }
    
    /**
     * マウスアップハンドラ
     */
    private function _mouseUpHandler(e:MouseEvent):void
    {
        _upBmp.visible   = true;
        _downBmp.visible = false;
    }
    
    /**
     * マウス移動ハンドラ
     */
    private function _mouseMoveHandler(e:MouseEvent):void
    {
        _cursor.x = mouseX;
        _cursor.y = mouseY;
    }
    
    /**
     * 右クリックメニュー表示時にマウスカーソルを隠す
     * @param    e
     */
    private function _contectMenuSelectHandler(e:ContextMenuEvent):void 
    {
        Mouse.hide();
    }
}





//------------------------------------------------------------------------------------------------------------------------------------------------------
/**                                                                                                                                             Resource
 * リソース管理クラス
 */
internal class Resource extends Thread
{
    //----------------------------------------
    //CONSTANTS
    
    private const BASE_URL:String = "http://lab.alumican.net/wonderfl/ramen_beats_box/";
//    private const BASE_URL:String = "assets/";
    
    /**
     * 画像URL配列
     */
    private const IMAGE_URLS:Array = [
        BASE_URL + "imgs/ramen.png", /* ラーメン */
        
        BASE_URL + "imgs/cursor_up.png",   /* 箸(開) */
        BASE_URL + "imgs/cursor_down.png", /* 箸(閉) */
        
        BASE_URL + "imgs/kakuni.png",   /* 角煮 */
        BASE_URL + "imgs/chashu.png",   /* チャーシュー */
        BASE_URL + "imgs/menma.png",    /* メンマ   */
        BASE_URL + "imgs/nitamago.png", /* 煮卵     */
        BASE_URL + "imgs/mame.png",     /* 豆 */
        BASE_URL + "imgs/naruto.png"    /* ナルト   */
    ];
    
    /**
     * 音URL配列
     */
    private const SOUND_URLS:Array = [
        BASE_URL + "sounds/bit235_etc02.mp3",  /* ギタートラック */
        BASE_URL + "sounds/bit243_bass01.mp3", /* ベーストラック */
    //    BASE_URL + "sounds/bit243_drum02.mp3", /* ドラムトラック */
        
        //disc1
        BASE_URL + "sounds/note_0.mp3",
        BASE_URL + "sounds/note_1.mp3",
        BASE_URL + "sounds/note_2.mp3",
        BASE_URL + "sounds/note_3.mp3",
        BASE_URL + "sounds/note_4.mp3",
        BASE_URL + "sounds/note_5.mp3",
        
        //disc2
        BASE_URL + "sounds/kick_004.mp3",
        BASE_URL + "sounds/kick_009.mp3",
        BASE_URL + "sounds/snare_010.mp3",
        BASE_URL + "sounds/snare_019.mp3",
        BASE_URL + "sounds/voice_hey_omachi.mp3",
        BASE_URL + "sounds/voice_wow_oisii.mp3",
        
        //filling name
        BASE_URL + "sounds/voice_kakuni.mp3",
        BASE_URL + "sounds/voice_chashu.mp3",
        BASE_URL + "sounds/voice_menma.mp3",
        BASE_URL + "sounds/voice_nitamago.mp3",
        BASE_URL + "sounds/voice_mame.mp3",
        BASE_URL + "sounds/voice_naruto.mp3"
    ];
    
    /**
     * ラーメンドンブリの数
     */
    public const bowlCount:uint = 1;
    
    /**
     * カーソル用Bitmapの数
     */
    public const cursorCount:uint = 2;
    
    /**
     * ラーメン具材の数
     */
    public const fillingCount:uint = IMAGE_URLS.length - bowlCount - 2;
    
    /**
     * ベーストラックの数
     */
    public const trackCount:uint = 2;
    
    /**
     * サウンドエフェクトの数
     */
    public const noteCount:uint = fillingCount;
    
    /**
     * サウンドエフェクトのサブセット数
     */
    public const noteSubsetCount:uint = 2;
    
    
    
    
    
    //----------------------------------------
    //VARIABLES
    
    /**
     * 読み込んだ画像データ配列
     */
    public function bmps(index:uint):Bitmap { return new Bitmap(Bitmap(_bmps[index]).bitmapData.clone(), "auto", true); }
    private var _bmps:Array;
    
    /**
     * 読み込んだ音データ配列
     */
    public function sounds(index:uint):Sound { return _sounds[index]; }
    private var _sounds:Array;
    
    /**
     * ラーメンドンブリのBitmap
     */
    public function bowlBmps(index:uint):Bitmap { return bmps(index); }
    
    /**
     * カーソル用のBitmap
     */
    public function cursorBmps(index:uint):Bitmap { return bmps(index + bowlCount); }
    
    /**
     * ラーメン具材のBitmap
     */
    public function fillingBmps(index:uint):Bitmap { return bmps(index + bowlCount + cursorCount); }
    
    /**
     * ベーストラックのSound
     */
    public function trackSounds(index:uint):Sound { return sounds(index); }
    
    /**
     * 合成用のSound
     */
    public function noteSounds(subset:uint, index:uint):Sound { return sounds(index + trackCount + subset * noteCount); }
    
    /**
     * 具材名のSound
     */
    public function fillingSounds(index:uint):Sound { return sounds(index + trackCount + noteSubsetCount * noteCount); }
    
    
    
    
    
    //----------------------------------------
    //METHODS
    
    /**
     * コンストラクタ
     */
    public function Resource():void
    {
    }
    
    /**
     * スレッドの実行関数
     */
    override protected function run():void 
    {
        //素材の読み込み開始
        _loadImages();
    }
    
    /**
     * 画像の読み込みを開始する
     */
    private function _loadImages():void
    {
        Debugger.log("", "loading images...");
        _loadDatas(IMAGE_URLS, "img", _onImagesLoadComplete);
    }
    
    /**
     * 音の読み込みを開始する
     */
    private function _loadSounds():void
    {
        Debugger.log("", "loading sounds...");
        _loadDatas(SOUND_URLS, "sound", _onSoundsLoadComplete);
    }
    
    /**
     * 画像の読み込み完了ハンドラ
     */
    private function _onImagesLoadComplete(container:Array, type:String):void 
    {
        //読み込んだ画像配列
        _bmps = container;
        
        //音の読み込みを開始する
        _loadSounds();
    }
    
    /**
     * 音の読み込み完了ハンドラ
     */
    private function _onSoundsLoadComplete(container:Array, type:String):void 
    {
        //読み込んだ音配列
        _sounds = container;
    }
    
    /**
     * URL配列で与えられたデータを読み込む汎用メソッド
     */
    private function _loadDatas(urls:Array, type:String, onComplete:Function = null, onError:Function = null):void
    {
        //読み込んだデータを格納する配列
        var container:Array = new Array();
        
        //読み込み開始
        var loaders:ParallelExecutor = new ParallelExecutor();
        for (var i:uint = 0; i < urls.length; ++i) 
        {
            var thread:Thread = (type == "text" ) ? new URLLoaderThread( new URLRequest(urls[i]) )   :
                                (type == "sound") ? new SoundLoaderThread( new URLRequest(urls[i]) ) :
                                                    new LoaderThread( new URLRequest(urls[i]), new LoaderContext(true) ) ;
            loaders.addThread(thread);
        }
        loaders.start();
        loaders.join();
        
        //読み込み完了ハンドラ
        function onLoadComplete():void
        {
            //読み込んだデータを配列に格納する
            for (var i:uint = 0; i < urls.length; ++i) 
            {
                var data:* = (type == "text" ) ? URLLoaderThread( loaders.getThreadAt(i) ).loader.data :
                             (type == "sound") ? SoundLoaderThread( loaders.getThreadAt(i) ).sound     :
                                                 LoaderThread( loaders.getThreadAt(i) ).loader.content ;
                container.push(data);
            }
            //コールバック関数の呼び出し
            if (onComplete != null) onComplete(container, type);
        }
        
        //読み込みエラーハンドラ
        function onLoadError(e:Error, t:Thread):void
        {
            var url:String = (type == "text" ) ? URLLoaderThread(t).request.url   :
                             (type == "sound") ? SoundLoaderThread(t).request.url :
                                                 LoaderThread(t).request.url      ;
            trace("error : _loadDatas, url = " + url + ", type = " + type);
            //コールバック関数の呼び出し
            (onError != null) ? onError() : next(null);
        }
        
        //ハンドラの登録
        next(onLoadComplete);
        error(IOError, onLoadComplete);
        error(SecurityError, onLoadError);
    }
    
    /**
     * ディープコピーを生成する
     */
    static public function clone(src:*):*
    {
        var ba:ByteArray = new ByteArray();
        ba.writeObject(src);
        ba.position = 0;
        return ba.readObject();
    }
}





//------------------------------------------------------------------------------------------------------------------------------------------------------
/**                                                                                                                                             Debugger
 * デバッグ用クラス
 */
internal class Debugger
{
    //----------------------------------------
    //CONSTANTS
    
    
    
    
    
    //----------------------------------------
    //VARIABLES
    
    /**
     * ログ出力用TextField
     */
    static private var _field:TextField;
    
    
    
    
    
    //----------------------------------------
    //METHODS
    
    /**
     * コンストラクタ
     */
    public function Debugger():void
    {
    }
    
    /**
     * 初期化関数
     */
    static public function initialize(base:Sprite):void
    {
        _field = base.addChild(new TextField()) as TextField;
        _field.width        = 465;
        _field.height       = 465;
        _field.selectable   = false;
        _field.mouseEnabled = false;
    }
    
    /**
     * ログ出力
     */
    static public function log(...args):void
    {
        var argn:uint = args.length;
        for (var i:uint = 0; i < argn; ++i)
        {
            if (args[i] == "")
            {
                _field.text = "";
                continue;
            }
            _field.appendText(String(args[i]) + "\n");
        }
    }
}

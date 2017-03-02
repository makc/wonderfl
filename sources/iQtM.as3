/**
 *============================================================
 *
 * Trance Metal Generator α ver
 * （トランスメタルジェネレーター アルファ版）
 * 
 * @author itoz ( http://www.romatica.com/ )
 * 
 * 上部サムネをタイムラインにドラッグドロップ
 * 下部再生ボタンで再生。
 * 手っ取り早く遊んでみたいなら[ set sample ]ボタンでサンプルをセットし再生。
 * 
 * - 環境にもよるけど、きれいにトラックが繋がらない場合がある。
 *   ※SiONを使うなどしてそのうち対策を考える
 * - ちらほらバグあり
 * - 音源（とくにギター）がしょぼいのでだれか録音機材使わせてくれる方いないかなー
 * 
 *
 * - 201.8.24  HTML版作ってみた。　js do it 　http://jsdo.it/itoz/n8OV
 *
 * - http://blog.romatica.com/2011/08/18/as3soundtrance-metal-generato/
 *============================================================
 */
package
{
    import caurina.transitions.Tweener;

    import flash.display.BitmapData;
    import flash.display.DisplayObjectContainer;
    import flash.display.Loader;
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.events.ProgressEvent;
    import flash.events.TimerEvent;
    import flash.geom.ColorTransform;
    import flash.media.Sound;
    import flash.media.SoundChannel;
    import flash.net.URLRequest;
    import flash.system.LoaderContext;
    import flash.system.Security;
    import flash.utils.Timer;

    [SWF(backgroundColor="#000000", frameRate="45", width="465", height="465")]
    public class TranceMetalGenerator_Alpha extends Sprite
    {
        private static const DOMAIN_PATH:String = "http://www.romatica.com/dev/wonderfl/TranceMetalGenerator/";
//        private static const DOMAIN_PATH:String = "";
        private static const PARTS_URL : String = DOMAIN_PATH+"wonderfl_assets.swf?v=1";
        // private static const PARTS_URL : String = "wonderfl_assets.swf";
        private var  _BG : MovieClip;
        private var _partsSWF : Loader;
        private var _loadBar : Sprite;
        private var _channels : Array;
        private var _source : Source;
        private var _previewManager : PreviewManager;
        private var _dropManager : DropManager;
        private var _playButton : MovieClip;
        private var _stopButton : MovieClip;
        private var _loopButton : MovieClip;
        private var _pp : Property;
        private var _timer : Timer;
        private var _barCount : int = 0;
        private var _mainSoundIdArray : Array;
        private var _currentLineArea : CurrenLineArea;
        private var _setSampleButton : MovieClip;
        private var _blackBG : Sprite;
        private var _loopToggle : Toggle;
        private var _loopFlag : Boolean;
        public function TranceMetalGenerator_Alpha()
        {
            Security.allowDomain("*");
            _pp = Property.getInstance();
            _source = Source.getInstance();
            addEventListener(Event.ADDED_TO_STAGE, _onAdded);
        }

        private function _onAdded(event : Event) : void
        {
            removeEventListener(Event.ADDED_TO_STAGE, _onAdded);
            _pp.FPS = stage.frameRate;
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;

            _blackBG = addChild(new Sprite()) as Sprite;
            _blackBG.graphics.beginFill(0x000000);
            _blackBG.graphics.drawRect(0, 0, 465, 465);
            _blackBG.graphics.endFill();

            _loadBar = addChild(new Sprite()) as Sprite;
            _loadBar.graphics.beginFill(0x45618f);
            _loadBar.graphics.drawRect(0, 0, 1, 2);
            _loadBar.graphics.endFill();
            _loadBar.y = 225;
            
            _partsSWF = new Loader();
            _partsSWF.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onLoadProgress);
            _partsSWF.contentLoaderInfo.addEventListener(Event.COMPLETE, loadCompleteHandler);
            _partsSWF.load(new URLRequest(PARTS_URL), new LoaderContext(true));
           
        }

        private function onLoadProgress(event : ProgressEvent) : void
        {
            _loadBar.width = stage.stageWidth * (event.bytesLoaded / event.bytesTotal);
        }

        private function loadCompleteHandler(event : Event) : void
        {
            removeChild( _loadBar);
            _source.partsLoader = _partsSWF;
            _channels = [];

            var BGClass : Class = _source.partsLoader.contentLoaderInfo.applicationDomain.getDefinition("MainBGImage") as Class;
            _BG = addChild(new BGClass())as MovieClip;
            _BG.x = 464 / 2;
           
            _dropManager = addChild(new DropManager()) as DropManager;
            _dropManager.x = 22;
            _dropManager.y = 278;
            _dropManager.dragArea();

            _previewManager = addChild(new PreviewManager()) as PreviewManager;
            _previewManager.x = 75;
            _previewManager.y = 103;
            _previewManager.setDragArea();
            _previewManager.addEventListener(DraggableEvent.DRAGGABLE_START, _dragStart, true);
            _previewManager.addEventListener(DraggableEvent.DRAGGABLE_COMPLETE,_dragComplete,true);

            var PlayClass : Class = _source.partsLoader.contentLoaderInfo.applicationDomain.getDefinition("PlayButtonBG") as Class;
            _playButton = new PlayClass();
            _playButton.buttonMode = true;
            _playButton.addEventListener(MouseEvent.CLICK, onPlayClick);
            _playButton.x = 465 / 2 - _playButton.width - 10;
            _playButton.y = 465 - _playButton.height - 20;
            addChild(_playButton);

            var StopClass : Class = _source.partsLoader.contentLoaderInfo.applicationDomain.getDefinition("StopButtonBG") as Class;
            _stopButton = new StopClass();
            _stopButton.buttonMode = true;
            _stopButton.addEventListener(MouseEvent.CLICK, onStopClick);
            _stopButton.x = 465 / 2 + 10;
            _stopButton.y = 465 - _stopButton.height - 20;
            addChild(_stopButton);

            var LoopClass : Class = _source.partsLoader.contentLoaderInfo.applicationDomain.getDefinition("LoopButton") as Class;
            _loopButton = new LoopClass();
            _loopButton.x = 20;
            _loopButton.y = 465 - _loopButton.height - 20;
            _loopToggle = new Toggle(_loopButton,true);
            _loopToggle.addEventListener(ToggleEvent.TOGGLE_OFF, onLoopOff);
            _loopToggle.addEventListener(ToggleEvent.TOGGLE_ON, onLoopOn);
            addChild(_loopButton);

            _currentLineArea = addChild(new CurrenLineArea()) as CurrenLineArea;
            _currentLineArea.x = 20;
            _currentLineArea.y = 255;

            var SetSampleButtonClass : Class = _source.partsLoader.contentLoaderInfo.applicationDomain.getDefinition("SetSampleButton") as Class;
            _setSampleButton = new SetSampleButtonClass() as MovieClip;
            _setSampleButton.x = 325;
            _setSampleButton.y = 236;
            _setSampleButton.buttonMode = true;
            _setSampleButton.addEventListener(MouseEvent.CLICK, onSetSample);
            addChild(_setSampleButton);
            
            onStopClick(null);
        }

        private function onLoopOff(e : ToggleEvent) : void { _loopFlag = false;}
        private function onLoopOn (e : ToggleEvent) : void { _loopFlag = true;}

        private function onSetSample(e : MouseEvent) : void
        {
            var preset : Array = [
                [
                     _previewManager.thumbArray[0][0]
                    ,_previewManager.thumbArray[0][0]
                    ,_previewManager.thumbArray[0][0]
                    ,_previewManager.thumbArray[0][1]
                ]
                ,[
                     _previewManager.thumbArray[2][0]
                    ,_previewManager.thumbArray[1][1]
                    ,_previewManager.thumbArray[1][2]
                    ,_previewManager.thumbArray[1][2]
                ]
                ,[
                     _previewManager.thumbArray[2][1]
                    ,_previewManager.thumbArray[2][1]
                    ,_previewManager.thumbArray[2][1]
                    ,_previewManager.thumbArray[2][2]
                ]
            ];
            var trgArray:Array=_dropManager.thumbs;
            for (var i : int = 0; i < trgArray.length; i++) {
                for (var j : int = 0; j < trgArray[i].length; j++) {
                    var thumb:DropThumb= trgArray[i][j] as DropThumb;
                    var previewThumb:PreviewThumb=preset[i][j];
                    if (previewThumb != null) {
                        var bmd : BitmapData = previewThumb.waveImage.copy();
                        var colTransBmd : BitmapData = new BitmapData(bmd.width, bmd.height, true, 0x00ffffff);
                        colTransBmd.draw(bmd, null, new ColorTransform(1, 1, 1, 0.7, 0, 50, 35, 0));
                        thumb.setSound(previewThumb.id, previewThumb.name, colTransBmd);
                    }
                }
            }
        }

        private function onStopClick(event : MouseEvent) : void
        {
            stopTimeLine();
            _setSampleButton.mouseChildren=true;
            _setSampleButton.mouseEnabled=true;
            _setSampleButton.alpha=1;
            _dropManager.mouseChildren = true;
            _previewManager.mouseChildren = true;
            _stopButton.mouseChildren = false;
            _stopButton.mouseEnabled = false;
            _playButton.mouseChildren = true;
            _playButton.mouseEnabled = true;
            _stopButton.alpha = 0.5;
            _playButton.alpha = 1;
            _loopToggle.setEvents();
            _currentLineArea.reset();
        }

        private function onPlayClick(event : MouseEvent) : void
        {
            _setSampleButton.mouseEnabled=false;
            _setSampleButton.mouseChildren=false;
            _setSampleButton.alpha=0.5;
            _dropManager.mouseChildren = false;
            _previewManager.mouseChildren = false;
            _previewManager.stopAllPreviewSound();
            _stopButton.mouseChildren = true;
            _stopButton.mouseEnabled = true;
            _playButton.mouseChildren = false;
            _playButton.mouseEnabled = false;
            _stopButton.alpha = 1;
            _playButton.alpha = 0.5;
            _loopToggle.removeEvents();
            playTimeLine();
        }

        private function playTimeLine() : void
        {
            _channels = [];
            stopTimeLine();
            getTimeLineData();
            _timer = new Timer(_pp.TRACK_TIME, 1);
            _timer.addEventListener(TimerEvent.TIMER_COMPLETE, timerCompleteHandler);
            startTimer();
        }

        private function getTimeLineData() : void
        {
           _mainSoundIdArray =  _dropManager.getSoundArray();
        }

        private function stopTimeLine() : void
        {
            if (_timer != null) {
                _timer.stop();
                _timer.reset();
                if (_timer.hasEventListener(TimerEvent.TIMER_COMPLETE)) {
                    _timer.removeEventListener(TimerEvent.TIMER_COMPLETE, timerCompleteHandler);
                }
                _timer = null;
            }
            for (var i : int = 0; i < _channels.length; i++) {
                _channels[i].stop();
            }
            _barCount = 0;
            _currentLineArea.reset();
        }

        private function startTimer() : void
        {
            if (_timer == null) return ;
            doSound();
        }

        private function doSound() : void
        {
            trace(_barCount + " / "+_mainSoundIdArray.length)
            // 最後に到達した
            if(_barCount ==_mainSoundIdArray.length ){
                 if(_loopFlag){
                    _barCount = 0;
                    _currentLineArea.reset();
                }else{
                    onStopClick(null);
                    return ;
                }
            }
            // 縦列トラック分のデータ
            var barArray : Array = _mainSoundIdArray[_barCount];
            for (var i : int = 0; i < barArray.length; i++) {
                var sndId : String = barArray[i] as String;
                if (sndId != null) {
                    var snd : Sound = _source.sounds[int(sndId.charAt(0))][int(sndId.charAt(1))] as Sound;
                    if (snd != null) {
                        // 再生
                        var channel : SoundChannel = snd.play(0);
                        _channels.push(channel);
                    }
                }
            }
            var timerCount:int =_timer.currentCount% _mainSoundIdArray.length;
            _currentLineArea.setPosition((_dropManager.width / 4) * timerCount, 0);
            _timer.start();
            _barCount += 1;
        }

        private function timerCompleteHandler(event : TimerEvent) : void
        {
            startTimer();
        }

        private function _dragStart(event : DraggableEvent) : void
        {
            var trgThumb : PreviewThumb = event.target as PreviewThumb;
            (trgThumb.parent as DisplayObjectContainer).addChild(trgThumb);
            _previewManager.stopAllPreviewSound();
            _previewManager.mouseChildren = false;
            _previewManager.mouseEnabled = false;
        }
        
        //ドロップされた
        private function _dragComplete(event : DraggableEvent) : void
        {
            var previewThumb:PreviewThumb= event.target as PreviewThumb;
            var dropThumb:DropThumb = _dropManager.overTarget as DropThumb;
            if(dropThumb==null){
                //ドロップエリアじゃないなら
                mouseChildren=false;
                Tweener.addTween(previewThumb,
                    {time:0.5
                        ,x:previewThumb.defX
                        ,y:previewThumb.defY
                        ,onComplete:function():void{mouseChildren=true;}});
            }else{
                //ドロップエリアなら
                previewThumb.x=previewThumb.defX;
                previewThumb.y=previewThumb.defY;
                //タイムライン上にセット
                var bmd : BitmapData = previewThumb.waveImage.copy();
                var colTransBmd : BitmapData = new BitmapData(bmd.width, bmd.height, true, 0x00ffffff);
                colTransBmd.draw(bmd, null, new ColorTransform(1, 1, 1, 0.7, 0, 50, 35, 0));
                dropThumb.setSound(previewThumb.id, previewThumb.name, colTransBmd);
            }
            _previewManager.mouseChildren = true;
            _previewManager.mouseEnabled = true;
        }
    }
}
import caurina.transitions.Tweener;

import jp.progression.commands.lists.SerialList;
import jp.progression.commands.media.DoSound;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Graphics;
import flash.display.LineScaleMode;
import flash.display.Loader;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.errors.IllegalOperationError;
import flash.events.DataEvent;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.ProgressEvent;
import flash.events.TimerEvent;
import flash.geom.Rectangle;
import flash.media.Sound;
import flash.text.AntiAliasType;
import flash.text.Font;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.ui.Mouse;
import flash.ui.MouseCursor;
import flash.utils.ByteArray;
import flash.utils.Timer;
class Property
{
    public static var instance : Property;
    public var  FPS : Number;
    public var INIT_XML : XML ;
    public var ROOT : String = "";
    public var SWF_URL : String;
    public var IMAGE_DIR : String = "";
    public var FLASH_VARS : Object;
    // public var TRACK_TIME : int = 5630;
    public var TRACK_TIME : int = 5615;
    public var TRACK_THUMB_WIDTH : int = 110;
    public var TRACK_THUBM_HEIGHT : int = 34;
    public var TRACK_DROP_MARGIN_WIDTH : int = 5;

    public static function getInstance() : Property
    {
        if ( instance == null ) instance = new Property(new SingletonEnforcer());
        return instance;
    }

    public function Property(pvt : SingletonEnforcer)
    {
        if (pvt == null) {
            throw new Error("Property is a singleton class, use getInstance() instead");
        }
    }
}
class Source
{
    public static var instance : Source;
    public var sounds : Array = [];
    public var soundsName : Array = [];
    private var _partsLoader : Loader;
    public var _fontClass : Class;
    public var mainFont :Font;

    public static function getInstance() : Source
    {
        if ( instance == null ) {
            instance = new Source(new SingletonEnforcer());
        }
        return instance;
    }

    public function Source(pvt : SingletonEnforcer)
    {
        if (pvt == null) {
            throw new Error("Source is a singleton class, use getInstance() instead");
        }
    }

    public function get partsLoader() : Loader
    {
        return _partsLoader;
    }

    public function set partsLoader(loader : Loader) : void
    {
        _partsLoader = loader;
        _fontClass = _partsLoader.contentLoaderInfo.applicationDomain.getDefinition("MyFont") as Class;
//        Font.registerFont(_fontClass);
        mainFont= new _fontClass();
        var SoundClass_Drum0 : Class = _partsLoader.contentLoaderInfo.applicationDomain.getDefinition("Drum_0") as Class;
        var SoundClass_Drum1 : Class = _partsLoader.contentLoaderInfo.applicationDomain.getDefinition("Drum_1") as Class;
        var SoundClass_Drum2 : Class = _partsLoader.contentLoaderInfo.applicationDomain.getDefinition("Drum_2") as Class;

        var SoundClass_Synce0 : Class = _partsLoader.contentLoaderInfo.applicationDomain.getDefinition("Synce_0") as Class;
        var SoundClass_Synce1 : Class = _partsLoader.contentLoaderInfo.applicationDomain.getDefinition("Synce_1") as Class;
        var SoundClass_Synce2 : Class = _partsLoader.contentLoaderInfo.applicationDomain.getDefinition("Synce_2") as Class;

        var SoundClass_Guitar0 : Class = _partsLoader.contentLoaderInfo.applicationDomain.getDefinition("Guitar_0") as Class;
        var SoundClass_Guitar1 : Class = _partsLoader.contentLoaderInfo.applicationDomain.getDefinition("Guitar_1") as Class;
        var SoundClass_Guitar2 : Class = _partsLoader.contentLoaderInfo.applicationDomain.getDefinition("Guitar_2") as Class;

        sounds = [[new SoundClass_Drum0(), new SoundClass_Drum1(), new SoundClass_Drum2()], [new SoundClass_Synce0(), new SoundClass_Synce1(), new SoundClass_Synce2()], [new SoundClass_Guitar0(), new SoundClass_Guitar1(), new SoundClass_Guitar2()]];
        soundsName = [["drum 1", "drum 2", "drum 3"], ["synce 1", "synce 2", "synce 3"], ["guitar 1", "guitar 2", "guitar 3"]];
    }
}
internal class SingletonEnforcer
{
}
class PreviewManager extends Sprite
{
    private var _soundSource : Source;
    private var _thumbs : Array;
    private var _pp : Property;
    private var _thumbArray : Array;

    public function PreviewManager()
    {
        _pp = Property.getInstance();
        _soundSource = Source.getInstance();
        _thumbs = [];
        _thumbArray =[];
        var soundTypeMax : int = _soundSource.sounds.length;
        for (var i : int = 0; i < soundTypeMax; i++) {
            var tracs : Array = _soundSource.sounds[i] as Array;
            var thumbJ:Array =[];
            for (var j : int = 0; j < tracs.length; j++) {
                var id : String = (i).toString() + (j).toString();
                var nameId : String = _soundSource.soundsName[i][j];
                var dragThumb : PreviewThumb = new PreviewThumb(tracs[j] as Sound, id, nameId);
                dragThumb.x = (_pp.TRACK_THUMB_WIDTH + 5) * j;
                dragThumb.y = (_pp.TRACK_THUBM_HEIGHT + 11) * i;
                dragThumb.defX = dragThumb.x;
                dragThumb.defY = dragThumb.y;
                addChild(dragThumb);
                _thumbs.push(dragThumb);
                thumbJ.push(dragThumb);
            }
            _thumbArray.push(thumbJ);
        }
        addEventListener(PreviewThumbEvent.PREVIEW_CLICK, onPreviewClick, true);
        addEventListener(PreviewThumbEvent.PLAY_COMPLETE, onTrackStop, true);
    }
    
    private function onTrackStop(e : PreviewThumbEvent) : void
    {
        stopAllPreviewSound();
    }

    private function onPreviewClick(event : PreviewThumbEvent) : void
    {
        for (var i : int = 0; i < _thumbs.length; i++) {
            var thumb : PreviewThumb = _thumbs[i];
            if ( thumb.id == event.data) {
                if (thumb.playState) {
                    thumb.stop();
                }
                else {
                    thumb.start();
                }
            }
            else {
                thumb.stop();
            }
        }
    }

    public function stopAllPreviewSound() : void
    {
        for (var i : int = 0; i < _thumbs.length; i++) {
            var thumb : PreviewThumb = _thumbs[i];
            thumb.stop();
        }
    }

    public function setDragArea() : void
    {
        for (var i : int = 0; i < _thumbs.length; i++) {
            var thumb : PreviewThumb = _thumbs[i] as PreviewThumb;
            thumb.setAreaRect(new Rectangle(-this.x, -this.y, 465 - _pp.TRACK_THUMB_WIDTH, 465 - _pp.TRACK_THUBM_HEIGHT));
        }
    }

    public function get thumbArray() : Array
    {
        return _thumbArray;
    }
}
class Draggable extends Sprite
{
    protected var _mc : MovieClip;
    private var _over : MovieClip;
    private var _offsetX : Number;
    private var _offsetY : Number;
    protected var _minX : int;
    protected var _maxX : int;
    protected var _minY : int;
    protected var _maxY : int;
    protected var _areaRect : Rectangle;

    public function Draggable(mc : MovieClip, areaRectangle : Rectangle)
    {
        if (mc.getChildByName("overArea_mc") == null) {
            
            
            throw new IllegalOperationError("overArea_mcを設置してください" + mc);
        }
        _mc = mc;
        _over = _mc.getChildByName("overArea_mc") as MovieClip;
        _over.addEventListener(MouseEvent.MOUSE_DOWN, _onDragStart);
        _over.addEventListener(MouseEvent.ROLL_OVER, _onRollOver);
        _over.addEventListener(MouseEvent.ROLL_OUT, _onRollOut);
        _areaRect = areaRectangle || new Rectangle(0, 0, 400, 300);
        addChild(_mc);
        addEventListener(Event.ADDED_TO_STAGE, _init);
    }

    protected function _init(event : Event) : void
    {
        removeEventListener(Event.ADDED_TO_STAGE, _init);
        setAreaRect(_areaRect);
    }

    public function setAreaRect(rect : Rectangle) : void
    {
        _minX = rect.left;
        _maxX = rect.right;
        _minY = rect.top;
        _maxY = rect.bottom;
    }

    private function _onRollOut(event : MouseEvent) : void
    {
        Mouse.cursor = MouseCursor.AUTO;
        dispatchEvent(new DraggableEvent(DraggableEvent.DRAGGABLE_OUT));
    }

    private function _onRollOver(event : MouseEvent) : void
    {
        Mouse.cursor = MouseCursor.HAND;
        dispatchEvent(new DraggableEvent(DraggableEvent.DRAGGABLE_OVER));
    }

    private function _onDragStart(event : MouseEvent) : void
    {
        stage.addEventListener(MouseEvent.MOUSE_MOVE, _onMouseMove);
        stage.addEventListener(MouseEvent.MOUSE_UP, _onDragEnd);
        _offsetX = this.parent.mouseX - this.x;
        _offsetY = this.parent.mouseY - this.y;
        dispatchEvent(new DraggableEvent(DraggableEvent.DRAGGABLE_START));
    }

    private function _onDragEnd(event : MouseEvent) : void
    {
        stage.removeEventListener(MouseEvent.MOUSE_MOVE, _onMouseMove);
        stage.removeEventListener(MouseEvent.MOUSE_UP, _onDragEnd);
        dispatchEvent(new DraggableEvent(DraggableEvent.DRAGGABLE_COMPLETE));
    }

    private function _onMouseMove(event : MouseEvent) : void
    {
        this.x = this.parent.mouseX - _offsetX;
        this.y = this.parent.mouseY - _offsetY;
        if (this.x < _minX ) {
            this.x = _minX;
        }
        if (this.x > _maxX) {
            this.x = _maxX;
        }
        if (this.y < _minY) {
            this.y = _minY;
        }
        if (this.y > _maxY) {
            this.y = _maxY;
        }
        dispatchEvent(new DraggableEvent(DraggableEvent.DRAGGABLE_PROGRESS));
    }
}

class PreviewThumb extends Draggable
{
    public var playState : Boolean = false;
    public var id : String = null;
    private var _sound : Sound;
    private var _bg : Sprite;
    private var _soundCommand : DoSound;
    private var _pp : Property;
    private var _tf : TextField;
    private var _source : Source;
    public var defX : Number;
    public var defY : Number;
    private var _waveImage : SoundWaveImage;

    public function PreviewThumb(snd : Sound, _id : String, _name : String)
    {
        _pp = Property.getInstance();
        _source = Source.getInstance();
        _sound = snd;
        id = _id;
        this.name = _name;
        var BGClass : Class = _source.partsLoader.contentLoaderInfo.applicationDomain.getDefinition("PreviewThumbBG") as Class;
        _bg = addChild(new BGClass())as MovieClip;
        super(_bg as  MovieClip, null);
        _soundCommand = new DoSound(_sound, 0, 0, true);
        _waveImage = new SoundWaveImage(_sound, _pp.TRACK_THUMB_WIDTH - 18, _pp.TRACK_THUBM_HEIGHT - 22, 0x313f63, true);
        _bg.addChild(_waveImage);
        _bg.setChildIndex(_waveImage, _bg.getChildIndex(_bg.getChildByName("overArea_mc")) - 1);
        // _swimg.addEventListener(SoundWaveImageEvent.SOUND_WAVE_IMAGE_COMPLETE, onComplete);
        // _swimg.addEventListener(ProgressEvent.PROGRESS, onProgress);
        _waveImage.renderStart();
        _waveImage.x = 18;
        _waveImage.y = 22 / 2 + 1;
        _tf = _bg.addChild(new TextField()) as TextField;
        _tf.defaultTextFormat = new TextFormat(_source.mainFont.fontName, 8, 0xffffff);
        _tf.antiAliasType = AntiAliasType.NORMAL;
        _tf.autoSize = TextFieldAutoSize.LEFT;
        _tf.text = _name;
        _tf.x = 15;
        _bg.setChildIndex(_tf, _bg.getChildIndex(_bg.getChildByName("overArea_mc")) - 1);
        var playBtn : MovieClip = ( _bg.getChildByName("btn")) as MovieClip;
        new SimpleButtonEvents(playBtn, new Rectangle(0, 0, 25, 25), onClick);
    }

    
    private function onClick(event : MouseEvent) : void
    {
        dispatchEvent(new PreviewThumbEvent(PreviewThumbEvent.PREVIEW_CLICK, false, false, id));
    }

    public function start() : void
    {
        stop();
        playState = true;
        this.alpha = 0.5;
        new SerialList({onComplete:function():void{playComplete();}}
        , 0, _soundCommand).execute();
    }

    private function playComplete():void
    {
        dispatchEvent(new PreviewThumbEvent(PreviewThumbEvent.PLAY_COMPLETE));
    }

    public function stop() : void
    {
        this.alpha = 1;
        playState = false;
        if (_soundCommand.state > 0) {
            _soundCommand.interrupt();
        }
    }

    public function get waveImage() : SoundWaveImage
    {
        return _waveImage;
    }
}
class DropThumb extends Draggable
{
    public var id : String = null;
    private var _bg : Sprite;
    public var _soundId : String;
    private var _tf : TextField;
    private var _pp : Property;
    private var _bgImage : MovieClip;
    private var _source : Source;
    public var defX : int;
    public var defY : int;
    private var _waveBitmap : Bitmap;
    private var _waveBMD : BitmapData;

    public function DropThumb(_id : String)
    {
        _pp = Property.getInstance();
        _source =Source.getInstance();
        id = _id;
        _bg = addChild(new Sprite()) as Sprite;
        _bg.graphics.beginFill(0x232424);
        // _bg.graphics.beginFill(0xb05403);
        _bg.graphics.drawRoundRect(0, 0, 100, _pp.TRACK_THUBM_HEIGHT, 3);
        _bg.graphics.endFill();
        _bg.alpha = 0;
        var BGClass : Class = _source.partsLoader.contentLoaderInfo.applicationDomain.getDefinition("DropThumbBG") as Class;
        _bgImage = addChild(new BGClass()) as MovieClip;

        super(_bgImage, null);

        _tf = _bgImage.addChild(new TextField()) as TextField;
        _tf.defaultTextFormat = new TextFormat(_source.mainFont.fontName, 8, 0xffffff);
        _tf.text = "";
        _tf.autoSize = TextFieldAutoSize.LEFT;
        _tf.x = 15;
        _tf.y = 3;

        _bgImage.setChildIndex(_tf, _bgImage.getChildIndex(_bgImage.getChildByName("overArea_mc")) );
        
        _waveBMD = new BitmapData(100 - 18, _pp.TRACK_THUBM_HEIGHT, true, 0x00ffffff);
        _waveBitmap = _bgImage.waveArea_mc.addChild(new Bitmap(_waveBMD)) as Bitmap;
        _waveBitmap.y = 22/2+1;
        resetSound();
        var deleteButton : MovieClip = _bgImage.btn;
        new SimpleButtonEvents(deleteButton, new Rectangle(0,0,20,20), onClick);
        addEventListener(MouseEvent.ROLL_OVER, onRollOver);
        addEventListener(MouseEvent.ROLL_OUT, onRollOut);
    }

    private function onClick(event : MouseEvent) : void
    {
        resetSound();
    }

    private function onRollOut(event : MouseEvent) : void
    {
        dispatchEvent(new DropThumbEvent(DropThumbEvent.DROP_OUT, false, false, id));
    }

    private function onRollOver(event : MouseEvent) : void
    {
        dispatchEvent(new DropThumbEvent(DropThumbEvent.DROP_OVER, false, false, id));
    }

    public function setSound(soundId : String, soundName : String,thumbBMD:BitmapData) : void
    {
        _bgImage.visible = true;
        _waveBMD.dispose();
        _waveBMD = new BitmapData(100 - 18, _pp.TRACK_THUBM_HEIGHT, true, 0x00ffffff);
        _waveBMD.draw(thumbBMD);
        _waveBitmap.bitmapData = _waveBMD;
        _soundId = soundId;
        _tf.text = soundName;
        this.name = soundName;
    }

    public function resetSound() : void
    {
        _bgImage.visible = false;
        _soundId = null;
        _tf.text = "";
    }

    public function get soundId() : String
    {
        return _soundId;
    }

    public function get waveBMD() : BitmapData
    {
        return _waveBMD;
    }
}
class DropManager extends Sprite
{
    private var _pp : Property;
    private var _thumbs : Array;
    public var overTarget : DropThumb;
    public static var trackNum : int = 4;

    public function DropManager()
    {
        _pp = Property.getInstance();
        _thumbs = [];
        for (var i : int = 0; i < 3; i++) {
            var barArray : Array = [];
            for (var j : int = 0; j < trackNum; j++) {
                var id : String = (i).toString() + (j).toString();
                var dropThumb : DropThumb = new DropThumb(id);
                dropThumb.x = j * (100 + _pp.TRACK_DROP_MARGIN_WIDTH);
                dropThumb.y = i * (_pp.TRACK_THUBM_HEIGHT + 9);
                dropThumb.defX = dropThumb.x;
                dropThumb.defY = dropThumb.y;
                barArray.push(dropThumb);
                addChild(dropThumb);
            }
            _thumbs.push(barArray);
        }
        addEventListener(DropThumbEvent.DROP_OVER, onDropOver, true);
        addEventListener(DropThumbEvent.DROP_OUT, onDropOut, true);
        addEventListener(DraggableEvent.DRAGGABLE_START, onDraggableStart,true);
        addEventListener(DraggableEvent.DRAGGABLE_COMPLETE, onDraggableComplete,true);
    }

    private function onDraggableStart(event : DraggableEvent) : void
    {
        overTarget = null;
        var  dragThumb : DropThumb = event.target as DropThumb;
        addChild(dragThumb);
        dragThumb.mouseChildren = false;
        dragThumb.mouseEnabled = false;
    }

    // 既に配置されたものをドロップ
    private function onDraggableComplete(event : DraggableEvent) : void
    {
        var  dragThumb : DropThumb = event.target as DropThumb;
        if (overTarget != null) {
            if (overTarget._soundId == null) {
                overTarget.setSound(dragThumb._soundId, dragThumb.name,dragThumb.waveBMD);
                dragThumb.resetSound();
                dragThumb.alpha=1;
            }
            dragThumb.x = dragThumb.defX;
            dragThumb.y = dragThumb.defY;
        }
        else {
            //戻す
            mouseChildren=false;
            Tweener.addTween(dragThumb,{time:0.5
                ,x:dragThumb.defX
                ,y:dragThumb.defY
                ,onComplete:function():void{mouseChildren=true;}});
            
        }
        dragThumb.mouseChildren = true;
        dragThumb.mouseEnabled = true;
    }

    private function onDropOut(event : DropThumbEvent) : void
    {
        if (overTarget != null) {
            // overTarget.alpha = 1;
            overTarget = null;
        }
    }

    private function onDropOver(event : DropThumbEvent) : void
    {
        overTarget = event.target as DropThumb;
        // overTarget.alpha=0.5;
    }

    public function getSoundArray() : Array
    {
        var soundIdArray : Array = [];
        for (var i : int = 0; i < _thumbs.length; i++) {
            var barArray : Array = _thumbs[i];
            for (var j : int = 0; j < barArray.length; j++) {
                if (soundIdArray[j] == null) soundIdArray[j] = [];
                var dropThumb : DropThumb = barArray[j] as DropThumb;
                (soundIdArray[j] as Array).push(dropThumb.soundId);
            }
        }
        return soundIdArray;
    }

    public function dragArea() : void
    {
        for (var i : int = 0; i < _thumbs.length; i++) {
            for (var j : int = 0; j < _thumbs[i].length; j++) {
                var tmb : DropThumb = _thumbs[i][j];
                    tmb.setAreaRect(new Rectangle(0,0
                        ,(trackNum-1) * (100 + _pp.TRACK_DROP_MARGIN_WIDTH)
                        ,2 * (_pp.TRACK_THUBM_HEIGHT + 9)));
            }
        }
    }

    public function get thumbs() : Array
    {
        return _thumbs;
    }
}
class SoundWaveImageEvent extends Event
{
    public static const SOUND_WAVE_IMAGE_START : String = "SOUND_WAVE_IMAGE_START";
    public static const SOUND_WAVE_IMAGE_PROGRESS : String = "SOUND_WAVE_IMAGE_PROGRESS";
    public static const SOUND_WAVE_IMAGE_COMPLETE : String = "SOUND_WAVE_IMAGE_COMPLETE";

    public function SoundWaveImageEvent(type : String, bubbles : Boolean = false, cancelable : Boolean = false)
    {
        super(type, bubbles, cancelable);
    }
}
class SoundWaveImage extends Sprite
{
    public var _bufferSize : int = 8192;
    public var _sampleRate : int = 44100;
    public var _milsPerSec : int = 1000;
    public var _padding : int = 0;
    protected var  _w : int ;
    protected var  _h : int ;
    protected var _sound : Sound;
    protected var _xpos : Number;
    protected var _lineLength : Number;
    protected var _position : int;
    protected var _detail : int;
    protected var _outsample : int;
    protected var _playing : Boolean;
    protected var _playprev : Boolean;
    protected var _renderer : Sprite;
    protected var _overlay : Sprite;
    protected var _init : Boolean;
    private var _sync : Boolean;
    private var _color : Number;

    public function SoundWaveImage(sound : Sound, w : int, h : Number, color : Number = 0x666666, sync : Boolean = true)
    {
        _sound = sound;
        _color = color;
        _w = w;
        _h = h;
        _sync = sync;
        _renderer = addChild(new Sprite()) as Sprite;
    }

    public function copy() : BitmapData
    {
        var bmd : BitmapData = new BitmapData(_renderer.width, _renderer.height, true, 0x00ffffff);
        bmd.draw(_renderer);
        return bmd;
    }

    public function renderStart() : void
    {
        if (_init) return ;
        _init = true;
        _detail = 10;
        _outsample = _sound.length / _milsPerSec * _sampleRate;
        _xpos = 0;
        _renderer.graphics.clear();
        _lineLength = _w / ( (_outsample - _position ) / _detail );
        _xpos = 0;
        _position = 0;
        _renderer.graphics.clear();
        _renderer.graphics.moveTo(_padding, _padding + _h * .5);
        _renderer.graphics.lineStyle(1, _color, 1, true, LineScaleMode.NONE);
        _lineLength = _w / ( (_outsample - _position ) / _detail );
        dispatchEvent(new SoundWaveImageEvent(SoundWaveImageEvent.SOUND_WAVE_IMAGE_START));

        if (_sync) {
            addEventListener(Event.ENTER_FRAME, renderProgress);
        }
        else {
            renderProgressNoSync();
        }
    }

    protected function renderProgress(even : Event) : void
    {
        var n : Number;
        var bytes : ByteArray = new ByteArray();
        var length : int = _position + _bufferSize < _outsample ? _bufferSize : _outsample - _position;
        _sound.extract(bytes, length, _position);
        bytes.position = 0;
        while ( bytes.position < bytes.length ) {
            n = bytes.readFloat() + bytes.readFloat();
            n *= .5;
            if ( _position % _detail == 0 ) {
                _renderer.graphics.lineTo(_padding + _xpos, ( _padding * 2 + _h * .5 ) + n * _h * .5);
                _xpos += _lineLength;
            }
            _position++;
        }

        dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false, _position, _outsample));

        if ( _position == _outsample ) {
            if (this.hasEventListener(Event.ENTER_FRAME)) removeEventListener(Event.ENTER_FRAME, renderProgress);
            renderComplete();
        }
    }

    private function renderProgressNoSync() : void
    {
        while (_position != _outsample ) {
            var n : Number;
            var bytes : ByteArray = new ByteArray();
            var length : int = _position + _bufferSize < _outsample ? _bufferSize : _outsample - _position;
            _sound.extract(bytes, length, _position);
            bytes.position = 0;
            while ( bytes.position < bytes.length ) {
                n = bytes.readFloat() + bytes.readFloat();
                n *= .5;
                if ( _position % _detail == 0 ) {
                    _renderer.graphics.lineTo(_padding + _xpos, ( _padding * 2 + _h * .5 ) + n * _h * .5);
                    _xpos += _lineLength;
                }
                _position++;
            }
        }
        renderComplete();
    }

    private function renderComplete() : void
    {
        dispatchEvent(new SoundWaveImageEvent(SoundWaveImageEvent.SOUND_WAVE_IMAGE_COMPLETE));
    }
}
class DropThumbEvent extends DataEvent
{
    public static const DROP_OVER : String = "DROP_OVER";
    public static const DROP_OUT : String = "DROP_OUT";

    public function DropThumbEvent(type : String, bubbles : Boolean = false, cancelable : Boolean = false, data : String = "")
    {
        super(type, bubbles, cancelable, data);
    }
}
class SimpleButtonEvents extends MovieClip
{
    public var _btn : MovieClip;
    private var _clickFunc : Function;
    private var _hit : Sprite;

    public function SimpleButtonEvents(btn : MovieClip, hitRect : Rectangle, clickFunc : Function)
    {
        try {
            _btn = btn;
            _clickFunc = clickFunc;
            mouseChildren = false;
            _hit = new Sprite();
            var g : Graphics = _hit.graphics;
            g.beginFill(0xcc0000);
            g.drawRect(hitRect.x, hitRect.y, hitRect.width, hitRect.height);
            g.endFill();
            _hit.visible = false;
            _hit.alpha = 0.5;
            _hit.name = "hit_area";
            _hit.mouseEnabled = false;
            _btn.addChild(_hit);
            _btn.hitArea = _hit;
            _btn.buttonMode = false;
            setON();
        } catch(err : Error) {
            trace("ERROR : SimpleButtonEvent >" + err.message);
        }
    }

    public function get hit() : Sprite
    {
        return _hit;
    }

    public function setON() : void
    {
        if (_btn != null) {
            if (_btn.buttonMode == false) {
                _btn.gotoAndPlay("up");
                _btn.buttonMode = true;
                _btn.addEventListener(MouseEvent.ROLL_OVER, onOver, false, 0, true);
                _btn.addEventListener(MouseEvent.ROLL_OUT, onOut, false, 0, true);
                _btn.addEventListener(MouseEvent.CLICK, _clickFunc, false, 0, true);
            }
        }
    }

    public function setOFF() : void
    {
        if (_btn != null) {
            if (_btn.buttonMode) {
                _btn.gotoAndPlay("disable");
                _btn.buttonMode = false;
                if (_btn.hasEventListener(MouseEvent.ROLL_OVER)) _btn.removeEventListener(MouseEvent.ROLL_OVER, onOver);
                if (_btn.hasEventListener(MouseEvent.ROLL_OUT)) _btn.removeEventListener(MouseEvent.ROLL_OUT, onOut);
                if (_btn.hasEventListener(MouseEvent.CLICK)) _btn.removeEventListener(MouseEvent.CLICK, _clickFunc);
            }
        }
    }

    private function onOver(e : MouseEvent) : void
    {
        _btn.gotoAndPlay("over");
    }

    private function onOut(e : MouseEvent) : void
    {
        _btn.gotoAndPlay("out");
    }

    public function remove() : void
    {
        setOFF();
        if (_btn != null) {
            if (_hit != null) {
                if (_btn.contains(_hit)) {
                    _btn.removeChild(_hit);
                }
                _hit = null;
            }
            _btn = null;
        }
    }
}
class PreviewThumbEvent extends DataEvent
{
    public static const PREVIEW_CLICK : String = "PREVIEW_CLICK";
    public static const PLAY_COMPLETE : String = "PLAY_COMPLETE";

    public function PreviewThumbEvent(type : String, bubbles : Boolean = false, cancelable : Boolean = false, data : String = "")
    {
        super(type, bubbles, cancelable, data);
    }
}
class CurrenLineArea extends Sprite
{
    private var _pp : Property;
    private var _line : MovieClip;
    private var _trackWidth : int;
    private var _trackTime : int;
    private var _lineTrackX : int;
    private var _timer : Timer;
    private var _source : Source;

    public function CurrenLineArea()
    {
        _pp = Property.getInstance();
        _source = Source.getInstance();
        var LineClass : Class = _source.partsLoader.contentLoaderInfo.applicationDomain.getDefinition("CurrentBar") as Class;
        _line = addChild(new LineClass()) as MovieClip;
        _trackWidth = 100 + _pp.TRACK_DROP_MARGIN_WIDTH-5;
        _trackTime = _pp.TRACK_TIME;
    }

    public function reset() : void
    {
        _line.x = 0;
        removeTimer() ;
    }

    private function removeTimer() : void
    {
        if (_timer != null) {
            if (_timer.hasEventListener(TimerEvent.TIMER)) {
                _timer.removeEventListener(TimerEvent.TIMER, onUpdate);
            }
            _timer.reset();
            _timer.stop();
            _timer = null;
        }
    }

    public function setPosition(xx : int, yy : int) : void
    {
        _lineTrackX = xx;
        _line.x = xx;
        _line.y = yy;
        startUpdate();
    }

    private function startUpdate() : void
    {
        removeTimer() ;
        // _timer = new Timer(1000 / _pp.FPS, 0);
        _timer = new Timer(1000 / stage.frameRate, 0);
        _timer.addEventListener(TimerEvent.TIMER, onUpdate);
        _timer.start();
    }

    private function onUpdate(event : TimerEvent) : void
    {
        _line.x = _lineTrackX + ((_trackWidth / (_trackTime / stage.frameRate)) * _timer.currentCount) / 2;
    }
}
class DraggableEvent extends Event
{
    public static const DRAGGABLE_OUT : String = "DRAGGABLE_OUT";
    public static const DRAGGABLE_OVER : String = "DRAGGABLE_OVER";
    public static const DRAGGABLE_PROGRESS : String = "DRAGGABLE_PROGRESS";
    public static const DRAGGABLE_COMPLETE : String = "DRAGGABLE_COMPLETE";
    public static const DRAGGABLE_START : String = "DRAGGABLE_START";

    public function DraggableEvent(type : String, bubbles : Boolean = false, cancelable : Boolean = false)
    {
         super(type, bubbles, cancelable);
    }
}
class ToggleEvent extends Event
{
    public static const TOGGLE_ON : String = "TOGGLE_ON";
    public static const TOGGLE_OFF : String = "TOGGLE_OFF";

    public function ToggleEvent(type : String, bubbles : Boolean = false, cancelable : Boolean = false)
    {
        super(type, bubbles, cancelable);
    }
}
class Toggle extends Sprite
{
    private var _btn : MovieClip;
    private var _status : Boolean;
    private var _viewMode : Boolean;

    public function Toggle(btn : MovieClip, toggle : Boolean = false, viewMode : Boolean = false)
    {
        _viewMode = viewMode;
        _btn = btn;
        _status = toggle;
        setStatus(_status);
        setEvents();
    }

    public function get btn() : MovieClip
    {
        return _btn;
    }

    public function setEvents() : void
    {
        var _ov : MovieClip = _btn.overArea_mc;
        _ov.buttonMode = true;
        _ov.mouseChildren = false;
        _ov.addEventListener(MouseEvent.CLICK, onClick, false, 0, true);
        _ov.addEventListener(MouseEvent.ROLL_OVER, onOver, false, 0, true);
        _ov.addEventListener(MouseEvent.ROLL_OUT, onOut, false, 0, true);
    }

    public function removeEvents() : void
    {
        if (btn != null) {
            var _ov : MovieClip = _btn.overArea_mc;
            if (_ov != null) {
                _ov.buttonMode = false;
                if (_ov.hasEventListener(MouseEvent.CLICK)) _ov.removeEventListener(MouseEvent.CLICK, onClick);
                if (_ov.hasEventListener(MouseEvent.ROLL_OVER)) _ov.removeEventListener(MouseEvent.ROLL_OVER, onOver);
                if (_ov.hasEventListener(MouseEvent.ROLL_OUT)) _ov.removeEventListener(MouseEvent.ROLL_OUT, onOut);
            }
        }
    }

    public function remove() : void
    {
        removeEvents();
        _btn = null;
    }

    public function onClick(e : MouseEvent) : void
    {
        _status = !_status;
        if (!_viewMode) setStatus(_status);
        _status = _status;
        if (_status) {
            dispatchEvent(new ToggleEvent(ToggleEvent.TOGGLE_OFF));
        }
        else {
            dispatchEvent(new ToggleEvent(ToggleEvent.TOGGLE_ON));
        }
    }

    public function setStatus(state : Boolean) : void
    {
        if (state) {
            _btn.gotoAndStop("off");
        }
        else {
            _btn.gotoAndStop("on");
        }
        _status = state;
    }

    private function onOver(e : MouseEvent) : void
    {
        if (_status) {
            _btn.gotoAndStop("off_over");
        }
        else {
            _btn.gotoAndStop("on_over");
        }
    }

    private function onOut(e : MouseEvent) : void
    {
        if (_status) {
            _btn.gotoAndStop("off");
        }
        else {
            _btn.gotoAndStop("on");
        }
    }

    public function get status() : Boolean
    {
        return _status;
    }
}

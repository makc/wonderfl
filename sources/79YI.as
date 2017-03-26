package
{
    import caurina.transitions.Tweener;

    import flash.display.MovieClip;
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.events.MouseEvent;
    import flash.text.Font;
    import flash.text.TextFormat;

    [SWF(frameRate = "60", backgroundColor = "#000000")]
    public class ShuffleTextWonderfl extends Sprite
    {

        //----------------------------------------------------------
        //
        //   Constructor 
        //
        //----------------------------------------------------------
        

        public function ShuffleTextWonderfl()
        {
            graphics.beginFill(0x0);
            graphics.drawRect(0, 0, 465, 465);

            var arr:Array = [
                "ActionScriptVersion",
                "AVM1Movie",
                "Bitmap",
                "BitmapData",
                "BitmapDataChannel",
                "BlendMode",
                "CapsStyle",
                "DisplayObject",
                "DisplayObjectContainer",
                "FrameLabel",
                "GradientType",
                "Graphics",
                "InteractiveObject",
                "InterpolationMethod",
                "JointStyle",
                "LineScaleMode",
                "Loader",
                "LoaderInfo",
                "MorphShape",
                "MovieClip",
                "PixelSnapping",
                "Scene",
                "Shape",
                "SimpleButton",
                "SpreadMethod",
                "Sprite",
                "Stage",
                "StageAlign",
                "StageDisplayState",
                "StageQuality",
                "StageScaleMode",
                "SWFVersion",
                "ActivityEvent",
                "AsyncErrorEvent",
                "ContextMenuEvent",
                "DataEvent",
                "ErrorEvent",
                "Event",
                "EventDispatcher",
                "EventPhase",
                "FocusEvent",
                "FullScreenEvent",
                "HTTPStatusEvent",
                "IMEEvent",
                "IOErrorEvent",
                "KeyboardEvent",
                "MouseEvent",
                "NetStatusEvent",
                "ProgressEvent",
                "SecurityErrorEvent",
                "StatusEvent",
                "SyncEvent",
                "TextEvent",
                "TimerEvent",
                "BevelFilter",
                "BitmapFilter",
                "BitmapFilterQuality",
                "BitmapFilterType",
                "BlurFilter",
                "ColorMatrixFilter",
                "ConvolutionFilter",
                "DisplacementMapFilter",
                "DropShadowFilter",
                "GlowFilter",
                "GradientBevelFilter",
                "GradientGlowFilter",
                ];

            var WIDTH:uint = 150;
            var HEIGHT:uint = 18;
            for (var i:int = 0; i < arr.length; i++)
            {
                var item:MovieClip = new MovieClip();
                item.buttonMode = true;
                item.tf = new ShuffleText(arr[i], new TextFormat("_sans", 12, 0xCCCCCC));
                item.tf.x = 2;
                item.zabuton = new Shape();
                item.zabuton.graphics.beginFill(0x111111, 1);
                item.zabuton.graphics.drawRect(0, 0, WIDTH, HEIGHT);

                item.bg = new Shape();
                item.bg.graphics.beginFill(0x333333)
                item.bg.graphics.drawRect(
                    0,
                    0,
                    WIDTH,
                    HEIGHT)
                item.bg.scaleX = 0;
                item.bg.alpha = 0;

                item.addChild(item.zabuton);
                item.addChild(item.bg);
                item.addChild(item.tf);

                item.addEventListener(MouseEvent.ROLL_OVER, function(event:MouseEvent):void {
                    var t:MovieClip = (event.currentTarget as MovieClip);
                    t.tf.start();
                    var tff:TextFormat = t.tf.defaultTextFormat;
                    tff.color = 0xCC1111;
                    t.tf.defaultTextFormat = tff;
                    Tweener.addTween(t.bg, {scaleX: 1, alpha: 1, time: 0.15});
                });

                item.addEventListener(MouseEvent.ROLL_OUT, function(event:MouseEvent):void {
                    var t:MovieClip = (event.currentTarget as MovieClip);
                    t.tf.start();
                    var tff:TextFormat = t.tf.defaultTextFormat;
                    tff.color = 0xCCCCCC;
                    t.tf.defaultTextFormat = tff;
                    Tweener.addTween(t.bg, {scaleX: 0, alpha: 0, time: 1.5, transition: "easeInExpo"});
                });

                item.x = 10 + (WIDTH + 1) * (i % 3);
                item.y = 10 + (HEIGHT + 1) * Math.floor(i / 3);
                addChild(item);
            }
        }
    }
}

import flash.display.Shape;
import flash.events.Event;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;

/**
 * Flash用シャッフルテキストクラス
 */
class ShuffleText extends TextField
{

    //----------------------------------------------------------
    //
    //   Constructor 
    //
    //----------------------------------------------------------

    /**
     * 新しいインスタンスを作成します。
     * @param text    文言
     * @param format    テキストフォーマット
     */
    public function ShuffleText(text:String = null, format:TextFormat = null)
    {
        this.selectable = false;
        this.mouseEnabled = false;
        this.multiline = false;
        this.autoSize = TextFieldAutoSize.LEFT;
        if (format)
            this.defaultTextFormat = format;
        this.text = text;
    }

    //----------------------------------------------------------
    //
    //   Property 
    //
    //----------------------------------------------------------

    /** エフェクトの実行時間 */
    public var duration:int = 500;
    /** 空白に用いる文字列 */
    public var emptyCharacter:String = "-";
    /** 再生中かどうかを示すブール値 */
    public var isRunning:Boolean = false;
    /** ランダムテキストに用いる文字列 */
    public var sourceRandomCharacter:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890";

    /** テキストを設定します。 */
    override public function set text(value:String):void
    {
        if (!value)
            return;

        this._orijinalStr = value;
        this._orijinalLength = value.length;
        super.text = value;
    }

    private var _orijinalLength:int = 0;
    private var _orijinalStr:String = "";
    private var _provider:Shape = new Shape();
    private var _randomIndex:Array = [];
    private var _timeCurrent:int = 0;
    private var _timeStart:int = 0;

    //----------------------------------------------------------
    //
    //   Function 
    //
    //----------------------------------------------------------

    /** 再生を開始します。 */
    public function start():void
    {
        this.stop();

        this._randomIndex = [];
        var str:String = "";
        for (var i:int = 0; i < this._orijinalLength; i++)
        {
            var rate:Number = i / this._orijinalLength;
            this._randomIndex[i] = Math.random() * (1 - rate) + rate;
            str += this.emptyCharacter;
        }

        this._timeStart = new Date().time;
        _provider.addEventListener(Event.ENTER_FRAME, tick);
        this.isRunning = true;

        super.text = str;
    }

    /** 停止します。 */
    public function stop():void
    {
        if (this.isRunning)
            _provider.removeEventListener(Event.ENTER_FRAME, tick);
        this.isRunning = false;
    }

    /**　プロパティーをリセットして、メモリを解放します。　*/
    public function dispose():void
    {
        duration = 0;
        emptyCharacter = null;
        isRunning = false;
        sourceRandomCharacter = null;
        _orijinalLength = 0;
        _orijinalStr = null;
        _provider = null;
        _randomIndex = null;
        _timeCurrent = 0;
        _timeStart = 0;
    }

    private function tick(e:Event):void
    {
        this._timeCurrent = new Date().time - this._timeStart;

        var percent:Number = this._timeCurrent / this.duration;
        var str:String = "";

        for (var i:int = 0; i < this._orijinalLength; i++)
        {
            if (percent >= this._randomIndex[i])
                str += this._orijinalStr.charAt(i);
            else if (percent < this._randomIndex[i] / 3)
                str += this.emptyCharacter;
            else
                str += this.sourceRandomCharacter.charAt(Math.floor(Math.random() * (this.sourceRandomCharacter.length)));
        }

        if (percent > 1)
        {
            str = this._orijinalStr;
            _provider.removeEventListener(Event.ENTER_FRAME, tick);
            this.isRunning = false;
        }
        super.text = str;
    }
}

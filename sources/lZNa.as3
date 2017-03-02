/**
 *============================================================
 * copyright(c). romatica.com
 * @author  itoz ( http://www.romatica.com/ )
 *============================================================
 *
 *　2進数を当てるゲーム。全10問
 *
 * TODO 開発時のランキングデータがのこっちゃった。どーやって消すの？（;´Д｀）
 * TODO　同じ答えが連続しないようにする
 * 
 *　bkzen さんのWhat the Hex からインスピレーションされて作りました。
 *　makc3d 　さんのスコアコードをそのまま使わさせていただきました。
 */
package
{
    import caurina.transitions.Tweener;

    import jp.progression.commands.Prop;
    import jp.progression.commands.Wait;
    import jp.progression.commands.lists.SerialList;
    import jp.progression.commands.tweens.DoTweener;

    import net.wonderfl.utils.WonderflAPI;

    import flash.display.Loader;
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Rectangle;
    import flash.net.URLRequest;
    import flash.system.ApplicationDomain;
    import flash.system.LoaderContext;
    import flash.system.Security;
    /**
     * 　WhatIsThisBit　2進数を当てるゲーム
     */
    public class WhatIsThisBit extends Sprite
    {
        private static const PARTS_URL : String = "http://www.romatica.com/dev/wonderfl/bit/whatsthisbit.swf";
        private var _partsSWF : Loader;
        private var _BG : MovieClip;
        private var _title : MovieClip;
        private var _startBtn : MovieClip;
        private var _sbeStart : SimpleButtonEvents;
        private var _container : Sprite;
        private var _limitBar : Sprite;
        private var _answers : MovieClip;
        private var _answermask : Sprite;
        private var _answerButtons : Array;
        private var _point : int=0;
        private var _a : int;
        private var _qArea : Sprite;
        private var _qnumArea : MovieClip;
        private var _qBoard : MovieClip;
        private var _qnum : int = 0;
        private var _scoreArea : MovieClip;
        private var _popUpPoint : MovieClip;
          
          
        public function WhatIsThisBit(){addEventListener(Event.ADDED_TO_STAGE, init);}
        
        private function init(e:Event):void
        {
            Security.allowDomain("*");
            removeEventListener(Event.ADDED_TO_STAGE, init);
            stage.scaleMode=StageScaleMode.NO_SCALE;
            stage.align=StageAlign.TOP_LEFT;
            loadStart();
        }

        /**
         * load start
         */
        private function loadStart() : void
        {
            var context : LoaderContext = new LoaderContext( true );
            context.applicationDomain = ApplicationDomain.currentDomain ;
            _partsSWF = new Loader();
            _partsSWF.contentLoaderInfo.addEventListener( Event.COMPLETE, setDO );
            _partsSWF.load( new URLRequest( PARTS_URL ), context );
        }

        private function setDO(e:Event) : void
        {
            //BG
            var BGClass:Class = _partsSWF.contentLoaderInfo.applicationDomain.getDefinition("BG") as Class;
            _BG = new BGClass() as MovieClip;
            addChild(_BG);
            
            //startBtn
            var StartBtn:Class = _partsSWF.contentLoaderInfo.applicationDomain.getDefinition("StartBtn") as Class;
            _startBtn = new StartBtn() as MovieClip;
           _sbeStart = new SimpleButtonEvents(_startBtn,new Rectangle (-61,-20,113,41),onClickStart);
           
            //container
            _container = addChild(new Sprite()) as Sprite;
                
            //Qarea
            _qArea = _container.addChild(new Sprite()) as Sprite;
            var _qmask:Sprite = _container.addChild(new Sprite()) as Sprite;
            _qmask.graphics.beginFill(0xcc0000);
            _qmask.graphics.drawRect(0,170,465,90);
            _qmask.graphics.endFill();
            _qArea.mask = _qmask;
            
            //title
            var TitleClass:Class =  _partsSWF.contentLoaderInfo.applicationDomain.getDefinition("Title") as Class;
            _title = new TitleClass() as MovieClip;
            _container.addChild(_title);
            
            //Question 
            var QBoardClass:Class =  _partsSWF.contentLoaderInfo.applicationDomain.getDefinition("QBoard") as Class;
            _qBoard = new QBoardClass() as MovieClip;
            _qArea.addChild(_qBoard);
            
            //QNumber
            var QnumAreaClass : Class = _partsSWF.contentLoaderInfo.applicationDomain.getDefinition( "QnumArea" ) as Class;
            _qnumArea = new QnumAreaClass() as MovieClip;
            _qArea.addChild(_qnumArea);
            
            //score
            var ScoreAreaClass : Class = _partsSWF.contentLoaderInfo.applicationDomain.getDefinition( "ScoreArea" ) as Class;
            _scoreArea = new ScoreAreaClass() as MovieClip;
            _scoreArea.x = 465/2-(_scoreArea.width/2);
            _scoreArea.y = 380;
            _container.addChild(_scoreArea);
            
            //popuppoint
            var PopUpPointClass : Class = _partsSWF.contentLoaderInfo.applicationDomain.getDefinition( "PopUpPoint" ) as Class;
            _popUpPoint = new PopUpPointClass() as MovieClip;
            _container.addChild(_popUpPoint);
            _popUpPoint.visible = false;
            
            setIntro();
        }

        private function setIntro() : void
        {
            addChild(_startBtn);
            _title.x = 465/2; 
            _title.y = 190;
            _startBtn.x = 465/2 ;
            _startBtn.y = 320;
        }

        private function onClickStart(e:MouseEvent) : void
        {
            new SerialList (null
                    ,[
                      new DoTweener(_startBtn,{alpha:0,time:0.5,scaleX:1.5,scaleY:1.5})
                     ,new DoTweener(_title,{y:80,time:0.5})
                     ]
                    ,new Prop(_startBtn,{visible:false})
                    ,function():void{
                                createAnswerButtons();    
                                setPoint(_point);
                                startQuestion();//問題開始
                    }
            ).execute();
        }
        private function setQuestion(q : String) : void{_qBoard.q_tf.text =q;}
        
        private function setPoint(p:int) : void{ _scoreArea.label.text = String(p);}

        private function startQuestion() : void
        {
            _qnum++;
            if(_qnum >10){
                stopGame();
                return;
            }
            var answers :Array= [];
            var qleng:int = 5;
            var rndArr:Array = ArrayPlus.rndNum(30);//29までのランダムな数配列
            //31までのランダムな数配列(5)を作成
            for (var i : int = 0; i < qleng; i++) {
                answers.push(rndArr[i]+2);
            }
            answers = ArrayPlus.rndSort(answers);
            setAnswers(answers);
            //答えを抽出設定
            _a = answers[int( Math.random() * 5 )];
            while (1 == _a || 0 == _a ) {
                _a = answers[int( Math.random() * qleng )];
            }
            setQuestion( _a.toString( 2 ) );
           _qnumArea.label.text= "Q."+_qnum+" READY";
            new SerialList(null
                ,[ new Prop(_qnumArea,{x:465/2,y:300})
                  ,new Prop(_qBoard,{x:465/2,y:300})
                  ,new Prop(_answers,{y:350})
                 ]
                ,new DoTweener(_qnumArea,{time:0.5,y:230})
                ,function():void{_qnumArea.label.text+= ".";}
                ,new Wait(0.5)
                ,function():void{_qnumArea.label.text+=".";}
                ,new Wait(0.5)
                ,function():void{_qnumArea.label.text+=".";}
                ,new Wait(0.5)
                ,[
                   new DoTweener(_qnumArea,{time:1,y:150})
                  ,new DoTweener(_qBoard,{time:1,y:230})
                  ,new DoTweener(_answers, {time:1,y:290})
                  ,function ():void{setTimer();}
                 ]
            ).execute();
        }
        /**
         * 終了
         */
        private function stopGame() : void
        {
            Tweener.addTween(_title,{time:1,y:190});
            Tweener.addTween(_limitBar,{time:1,alpha:0});
            var obj: Object = loaderInfo.parameters;
            var window: ScoreWindow = makeScoreWindow(new WonderflAPI(obj)
                                                         , _point
                                                         , null
                                                         , 1
                                                         , "What's this BIT? SCORE [%SCORE%] "
                                                         ,"SCORE"
                                                         ,""
                                                         ,99
                                                         ,1);
            addChild(window);
        }
      
        
        private function createAnswerButtons():void
        {
            _answers = _container.addChild(new MovieClip()) as MovieClip;
            _answerButtons = [];
            var ABtnClass:Class = _partsSWF.contentLoaderInfo.applicationDomain.getDefinition("Abtn") as Class;
            for (var i : int = 0; i < 5; i++) {
                var b:MovieClip = new ABtnClass() as MovieClip;
                _answers.addChild(b);
                b.x = b.width * i;
                var _sbeABtn:SimpleButtonEvents = new SimpleButtonEvents(b,new Rectangle(0,0,66,41),onClickAnswer);
                _answerButtons.push(b);
            }
            _answers.x = 465/2 - (_answers.width/2);
            //mask
            _answermask = _container.addChild(new Sprite()) as Sprite;
            _answermask.graphics.beginFill(0xcc0000);
            _answermask.graphics.drawRect(0,268,465,70);
            _answermask.graphics.endFill();
            _answers.mask = _answermask;
        }
        
        /**
         * ボタンに問題をセット
         */
        private function setAnswers(answers : Array) : void
        {
            for (var i : int = 0; i < answers.length; i++) {
                _answerButtons[i].label.text = answers[i];
            }
        }
        /**
         *  ボタンクリックした
         */
        private function onClickAnswer(e:MouseEvent) : void
        {
            var t:MovieClip = e.currentTarget as MovieClip;
            var selectedAnswer:int = int(t.label.text);
            if( _a == selectedAnswer){
                shakeRight();
                nextQuestion();
            }else{
                _limitBar.scaleX-=0.3;
                shakeWrong();
            }
        }

        private function shakeRight() : void
        {
            if(_qBoard.hasEventListener(Event.ENTER_FRAME)){
                _qBoard.removeEventListener(Event.ENTER_FRAME, onShake);
            }
            _qBoard.scaleX = _qBoard.scaleY = 1.3;
            Tweener.addTween(_qBoard,{time:1,scaleX:1,scaleY:1,transition:"easeOutElastic"});
        }
        
        private function shakeWrong():void{
            _qBoard.addEventListener(Event.ENTER_FRAME, onShake);
            _qBoard.leng = 5;
        }

        private function onShake(event : Event) : void
        {
            _qBoard.leng *=-1;
            _qBoard.x = (465/2)+_qBoard.leng;
            _qBoard.leng = _qBoard.leng*0.8;
            if(Math.abs((465/2)+_qBoard.y) <1.5){
                _qBoard.x = (465/2);
                _qBoard.removeEventListener(Event.ENTER_FRAME, onShake);
            }
        }

        private function setTimer() : void
        {
            if (_limitBar == null) createLimitBar();
            _limitBar.scaleX = 1;
            addEventListener( Event.ENTER_FRAME, onLimitBar );
        }

        private function createLimitBar() : void
        {
            _limitBar = addChild( new Sprite() ) as Sprite;
            _limitBar.graphics.beginFill( 0x0768ae );
            _limitBar.graphics.drawRect( 0, 0, 470, 2 );
            _limitBar.graphics.endFill();
            _limitBar.y = 268;
        }

        private function onLimitBar(event : Event) : void
        {
            if (_limitBar.scaleX > 0) {
                _limitBar.scaleX -= 0.002;
            } else {
                _limitBar.scaleX = 0 ;
                nextQuestion();
            }
        }

        /**
         * 次の問題
         */
        private function nextQuestion() : void
        {
            var point:int = int(_limitBar.scaleX*100);
            _point += point;
            popUpPoint(point);
            setPoint( _point);
            if(this.hasEventListener(Event.ENTER_FRAME)){
                    removeEventListener(Event.ENTER_FRAME, onLimitBar);
            }
            new SerialList (null
                            ,new DoTweener(_answers,{time:1,y:200})
                            ,new DoTweener(_qBoard,{time:0.5,y:140})
                            ,new Wait(0.5)
                            ,[
                              new DoTweener(_limitBar,{scaleX:1,time:0.5})
                              ,function():void{startQuestion();}
                            ]
            ).execute();
        }
        /**
         * ゲットポイントポップアップ
         */
        private function popUpPoint(n:int):void
        {
            new SerialList(null
                ,[
                   new Prop(_popUpPoint,{alpha:0,visible:true,x:305,y:_scoreArea.y+30})
                  ,function():void{_popUpPoint.label.text ="+"+ n;}
                 ]
                ,new DoTweener(_popUpPoint,{time:1,alpha:1,y:_scoreArea.y})
                ,new Wait(0.5)
                ,new DoTweener(_popUpPoint,{time:0.5,alpha:0,y:_scoreArea.y-20})
            ).execute();
        }
        /**
         * Wonderfl の Score API 用
         * ランキング表示から Tweet までをひとまとめにしたSWF素材
         * @param    api                : WonderflAPI
         * @param    score            : 取得スコア
         * @param    title            : (省略時: "GAME SCORE")ランキングのタイトル
         * @param    denominator        : (省略時: 1) 表示スコアに小数点が付く場合に使用する。
         *                                     スコアが 1234 のとき、 100 に指定すると 12.34
         * @param    tweet            : (省略時はTweet無し) Twitter 連携をする時に文字列を指定すると
         *                                    それでつぶやかれる。%SCORE% という文字列が中にあるとそこがスコアと置き換わる。
         * @param    scoreTitle        : (省略時: SCORE)　スコアが何を意味するのか。例) LAP TIME
         * @param    addScoreAfter    : 表示スコアの後ろにつける単位などに、
         *                                 例) [sec] と指定すると 12.34 [sec] のように表示される
         * @param    scoreLength        : (省略時: 99) スコア送信後に取得するランキング件数
         * @param    scoreDescend    : (省略時: 0) 降順昇順のフラグ
         *                                 (1: 点数が高い順、0: 点数が低い順)
         * @param    modal            : (省略時: true) モーダル処理を入れるかどうか。
         */
        public function makeScoreWindow(
            api: WonderflAPI, score: int, title: String, denominator: int = 1, 
            tweet: String = null, scoreTitle: String = "SCORE", addScoreAfter: String = "",
            scoreLength: uint = 99, scoreDescend: uint = 0, modal: Boolean = true
        ): ScoreWindow
        {
            _api = api, _score = score, _scoretitle = title, _denominator = denominator, _tweet = tweet, _scoreTitle = scoreTitle, _addScoreAfter = addScoreAfter, _scoreLength = scoreLength, _scoreDescend = scoreDescend;
            return new ScoreWindow(modal);
        }
        
    }
}
import net.wonderfl.data.APIScoreData;
import net.wonderfl.data.ScoreData;
import net.wonderfl.data.WonderflAPIData;
import net.wonderfl.utils.WonderflAPI;

import com.adobe.serialization.json.JSON;
import com.bit101.components.InputText;
import com.bit101.components.Label;
import com.bit101.components.PushButton;
import com.bit101.components.Style;
import com.bit101.components.VScrollBar;

import org.libspark.betweenas3.BetweenAS3;
import org.libspark.betweenas3.easing.Quad;
import org.libspark.betweenas3.tweens.IObjectTween;
import org.libspark.betweenas3.tweens.ITween;
import org.libspark.betweenas3.tweens.ITweenGroup;

import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.Loader;
import flash.display.MovieClip;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.MouseEvent;
import flash.filters.DropShadowFilter;
import flash.geom.Rectangle;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.net.navigateToURL;
import flash.utils.escapeMultiByte;
class ArrayPlus{
    public static function rndSort(arr : Array) : Array
    {
        var result : Array = arr.slice();
        var rndArr : Array = rndNum( arr.length );
        result = arraySort( result, rndArr );
        return result;
    }

    public static function arraySort(arr : Array, sortArr : Array) : Array
    {
        var result : Array = [];
        for (var i : int = 0; i < sortArr.length; i++) {
            var index : int = sortArr[i];
            result.push( arr[index] );
        }
        return result;
    }

    public static function rndNum(nn : int) : Array
    {
        var result : Array = [];
        var pushCnt : int = 0;
        while (pushCnt != nn) {
            var rr : int = Math.floor( Math.random() * nn );
            var arrCheck : int = result.indexOf( rr );
            if (arrCheck == -1) {
                result[pushCnt] = rr;
                pushCnt++;
            }
        }
        return result;
    }
}


 class SimpleButtonEvents extends MovieClip {

        public var _btn : MovieClip;
        private var _clickFunc : Function;
        private var hit : Sprite;

        public function SimpleButtonEvents(btn : MovieClip, hitRect : Rectangle, clickFunc : Function) {
            try {
                _btn = btn;
                _clickFunc = clickFunc;
                mouseChildren = false;
                //hitarea
                hit = new Sprite( );
                var g : Graphics= hit.graphics;
                g.beginFill( 0xcc0000 );
                g.drawRect( hitRect.x, hitRect.y, hitRect.width, hitRect.height );
                g.endFill( );
                hit.visible = false;
                hit.alpha = 0.5;
                hit.name = "hit_area";
                hit.mouseEnabled = false;
                _btn.addChild( hit );
                _btn.hitArea = hit;
                _btn.buttonMode=false;
                setON( );
            }catch(err : Error) {
                trace( "ERROR : SimpleButtonEvent >" + _btn );
            }
        }

    public function setON() : void
    {
        if (_btn.buttonMode == false) {
            _btn.gotoAndPlay( "stay" );
            _btn.alpha = 1;
            _btn.buttonMode = true;
            _btn.addEventListener( MouseEvent.ROLL_OVER, onOver );
            _btn.addEventListener( MouseEvent.ROLL_OUT, onOut );
            _btn.addEventListener( MouseEvent.CLICK, _clickFunc );
        }
    }

    public function setOFF() : void
    {
        if (_btn.buttonMode) {
            _btn.gotoAndPlay( "stay" );
            _btn.alpha = 0.5;
            _btn.buttonMode = false;
            _btn.removeEventListener( MouseEvent.ROLL_OVER, onOver );
            _btn.removeEventListener( MouseEvent.ROLL_OUT, onOut );
            _btn.removeEventListener( MouseEvent.CLICK, _clickFunc );
        }
    }


    private function onOver(e : MouseEvent) : void
    {
        _btn.gotoAndPlay( "over" );
    }

    private function onOut(e : MouseEvent) : void
    {
        _btn.gotoAndPlay( "out" );
    }

    public function remove() : void
    {
        setOFF();
        _btn.removeChild( hit );
        hit = null;
    }
}
    
    
 
var _api: WonderflAPI, _score: int, _scoretitle: String, _denominator: int, _tweet: String, _scoreTitle: String, _addScoreAfter: String, _scoreLength: uint, _scoreDescend: uint;

/**
 * 閉じられた時に出力されます。
 */
[Event(name="close", type="flash.events.Event")]
class ScoreWindow extends Sprite
{
    function ScoreWindow( modal: Boolean = true )
    {
        this.modal = modal;
        if (_tweet) _tweet = _tweet.replace(/%SCORE%/g, (_score / _denominator));
        if (stage) init();
        else addEventListener(Event.ADDED_TO_STAGE, init);
    }
    private var modal: Boolean;
    private var modalSp: Sprite;
    
    private function init(e: Event = null): void 
    {
        removeEventListener(Event.ADDED_TO_STAGE, init);
        var window: _ScoreWindow = new _ScoreWindow();
        window.closeHandler = onClose;
        window.x = stage.stageWidth  - window.width  >> 1;
        window.y = stage.stageHeight - window.height >> 1;
        if (modal) 
        {
            addChild(modalSp = new Sprite());
            var g: Graphics = modalSp.graphics;
            g.beginFill(0xCCCCCC, 0.5);
            g.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
        }
        addChild(window);
        stage.addEventListener(Event.RESIZE, onResize);
    }
    
    private function onResize(e:Event):void 
    {
        if (modal)
        {
            var g: Graphics = modalSp.graphics;
            g.clear();
            g.beginFill(0x333333, 0.3);
            g.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
        }
        var i: int;
        for (i = 0; i < numChildren; i++) 
        {
            var d: DisplayObject = getChildAt(i);
            d.x = stage.stageWidth  - d.width  >> 1;
            d.y = stage.stageHeight - d.height >> 1;
        }
    }
    
    private function onClose():void 
    {
        while (numChildren > 0) removeChildAt(0);
        stage.removeEventListener(Event.RESIZE, onResize);
        parent.removeChild(this);
        dispatchEvent(new Event(Event.CLOSE));
    }
}

class _ScoreWindow extends Sprite
{
    private var iconLoader: Loader, input: InputText, registBtn: PushButton, closeBtn: PushButton, tweetBtn: PushButton;
    private var tween: IObjectTween;
    public var closeHandler: Function;
    
    function _ScoreWindow()
    {
        alpha = 0;
        var bg: Shape = new Shape();
        var g: Graphics = bg.graphics;
        g.beginFill(0x777777);
        g.drawRoundRectComplex(0, 0,  280, 180, 5, 5, 5, 5);
        g.beginFill(0xFFFFFF);
        g.drawRoundRectComplex(1, 1,  278,  20, 5, 5, 0, 0);
        g.drawRoundRectComplex(1, 22, 278, 157, 0, 0, 5, 5);
        bg.filters = [new DropShadowFilter(2, 45, 0, 1, 16, 16)];
        addChild(bg);
        BackupStyle.styleSet();
        new Label(this, 5, 3, _scoretitle);
        iconLoader = new Loader();
        iconLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onCompLoadIcon);
        iconLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onIOErrorIcon);
        iconLoader.visible = false;
        iconLoader.x = 10, iconLoader.y = 60;
        addChild(iconLoader);
        new Label(this, 75,  65, _scoreTitle + " :");
        new Label(this, 75,  85, "PLAYER :");
        new Label(this, 150, 65, (_score / _denominator) + " " + _addScoreAfter);
        input = new InputText(this, 150, 85, _api.viewerDisplayName);
        iconLoader.load(new URLRequest(_api.viewerIconURL));
        if (_tweet) tweetBtn = new PushButton(this, 10, 150, "TWEET", onClickTweet);
        registBtn = new PushButton(this, _tweet ? 100 : 35, 150, "REGISTER", onClickRegist);
        closeBtn = new PushButton(this, _tweet ? 190 : 145, 150, "CANCEL", onClickCancel);
        if (tweetBtn) tweetBtn.width = registBtn.width = closeBtn.width = 80;
        else registBtn.width = closeBtn.width = 100;
        tween = BetweenAS3.to(this, { alpha: 1 }, 1);
        tween.play();
        BackupStyle.styleBack();
    }
    
    private function onIOErrorIcon(e:IOErrorEvent):void 
    {
        iconLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onCompLoadIcon);
        iconLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onIOErrorIcon);
    }
    
    private function onCompLoadIcon(e:Event):void 
    {
        iconLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onCompLoadIcon);
        iconLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onIOErrorIcon);
        iconLoader.scaleX = iconLoader.scaleY = 0.5;
        iconLoader.visible = true;
    }
    
    private function onClickCancel(e: Event):void 
    {
        if (tween.isPlaying) tween.stop();
        tween = BetweenAS3.to(this, { alpha: 0 } );
        tween.onComplete = close;
        tween.play();
        btnDisable();
    }
    
    private function btnDisable(): void
    {
        if (tweetBtn) tweetBtn.enabled = false;
        registBtn.enabled = closeBtn.enabled = false;
    }
    
    private function close(): void
    {
        while (numChildren > 0) removeChildAt(0);
        input = null;
        if (tweetBtn) tweetBtn.removeEventListener(MouseEvent.CLICK, onClickTweet);
        registBtn.addEventListener(MouseEvent.CLICK, onClickRegist);
        closeBtn.addEventListener(MouseEvent.CLICK, onClickCancel);
        tweetBtn = registBtn = closeBtn = null;
        var f: Function = closeHandler;
        closeHandler = null;
        iconLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onCompLoadIcon);
        iconLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onIOErrorIcon);
        iconLoader.unloadAndStop();
        iconLoader = null;
        if (f != null) f();
        if (parent) parent.removeChild(this);
    }
    
    private function onClickRegist(e: Event):void 
    {
        if (input.text == "") return;
        btnDisable();
        var window: RankingWindow = new RankingWindow(input.text);
        window.x = stage.stageWidth  - window.width  >> 1;
        window.y = stage.stageHeight - window.height >> 1;
        window.closeHandler = closeHandler;
        closeHandler = null;
        parent.addChild(window);
        tween.stop();
        tween = BetweenAS3.to(this, { alpha: 0 } );
        tween.onComplete = close;
        tween.play();
    }
    
    private function onClickTweet(e: Event):void 
    {
        navigateToURL(new URLRequest("http://twitter.com/share?" + 
            "text=" + escapeMultiByte(_tweet) + "&url=" + escapeMultiByte("http://wonderfl.net/c/" + _api.appID)
        ));
    }
}
class RankingWindow extends Sprite
{
    private var _name: String;
    private var loader: URLLoader;
    private var bg: Shape, closeBtn:PushButton, loadingLabel:Label;
    private var tween: ITween;
    private var scoreData: APIScoreData;
    private var list: ScoreList;
    private var tweetBtn:PushButton;
    public var closeHandler: Function;
    function RankingWindow(name: String)
    {
        _name = name, alpha = 0;
        
        BackupStyle.styleSet();
        bg = new Shape();
        var g: Graphics = bg.graphics;
        g.beginFill(0x777777);
        g.drawRoundRectComplex(0, 0,  260, 340, 5, 5, 5, 5);
        g.beginFill(0xFFFFFF);
        g.drawRoundRectComplex(1, 1,  258, 20,  5, 5, 0, 0);
        g.drawRoundRectComplex(1, 22, 258, 317, 0, 0, 5, 5);
        g.beginFill(0x777777);
        g.drawRect(6, 27, 248, 282);
        g.beginFill(0xFFFFFF);
        g.drawRect(7, 28, 246, 280);
        bg.filters = [new DropShadowFilter(2, 45, 0, 1, 16, 16, 1)];
        addChild(bg);
        new Label(this, 5, 3, _scoretitle + " RANKING");
        if (_tweet) tweetBtn = new PushButton(this, 25, 314, "TWEET", onClickTweet);
        closeBtn = new PushButton(this, _tweet ? 135 : 80, 314, "CLOSE", onClickClose);
        loadingLabel = new Label(this, 100, 160, "NOW LOADING...");
        BackupStyle.styleBack();
        
        tween = BetweenAS3.to(this, { alpha: 1 } );
        tween.onComplete = check;
        tween.play();
        addEventListener(Event.ENTER_FRAME, loadingLoop);
        loader = new URLLoader();
        loader.addEventListener(Event.COMPLETE, onCompSaveScore);
        var urlReq: URLRequest = _api.apiScorePost(_score, _name);
        urlReq.url = WonderflAPI.API_SCORE_SET.replace("%ID%", _api.appID);
        loader.load(urlReq);
    }
    
    private function onClickTweet(e: Event):void 
    {
        navigateToURL(new URLRequest("http://twitter.com/share?" + 
            "text=" + escapeMultiByte(_tweet) + "&url=" + escapeMultiByte("http://wonderfl.net/c/" + _api.appID)
        ));
    }
    
    private function onClickClose(e: Event):void 
    {
        removeEventListener(Event.ENTER_FRAME, loadingLoop);
        closeBtn.removeEventListener(MouseEvent.CLICK, onClickClose);
        try { loader.close(); }
        catch (err: Error) { }
        
        if (tween && tween.isPlaying) tween.stop();
        tween = BetweenAS3.to(this, { alpha: 0 } );
        tween.onComplete = close;
        tween.play();
    }
    
    private function close():void 
    {
        while (numChildren > 0) removeChildAt(0);
        var f: Function = closeHandler;
        closeHandler = null;
        list.clear();
        if (loader) 
        {
            loader.removeEventListener(Event.COMPLETE, onCompLoadScore);
            loader.removeEventListener(Event.COMPLETE, onCompSaveScore);
        }
        bg = null, closeBtn = null, loadingLabel = null, list = null;
        if (f != null) f();
    }
    
    private function check():void 
    {
        if (scoreData && alpha == 1) 
        {
            removeEventListener(Event.ENTER_FRAME, loadingLoop);
            removeChild(loadingLabel);
            addChild(list = new ScoreList(7, 28, 246, 280));
            list.add(scoreData.scores, _name, _score);
        }
    }
    
    private function loadingLoop(e:Event):void 
    {
        loadingLabel.visible = !loadingLabel.visible;
    }
    
    private function onCompSaveScore(e:Event):void 
    {
        loader.removeEventListener(Event.COMPLETE, onCompSaveScore);
        var res: WonderflAPIData = new WonderflAPIData(JSON.decode(loader.data));
        if (res.isOK)
        {
            loader = new URLLoader();
            loader.addEventListener(Event.COMPLETE, onCompLoadScore);
            loader.load(_api.apiScoreGet(_scoreLength, _scoreDescend));
        }
        else 
        {
            removeEventListener(Event.ENTER_FRAME, loadingLoop);
            loadingLabel.visible = true;
            loadingLabel.text = "Score Save Error : " + res.stat + " : " + res.message;
        }
    }
    
    private function onCompLoadScore(e:Event):void 
    {
        loader.removeEventListener(Event.COMPLETE, onCompLoadScore);
        scoreData = new APIScoreData(JSON.decode(loader.data));
        if (scoreData.isOK)
        {
            check();
        }
        else 
        {
            removeEventListener(Event.ENTER_FRAME, loadingLoop);
            loadingLabel.visible = true;
            loadingLabel.text = "Score Load Error" + scoreData.stat + " : " + scoreData.message;
            scoreData = null;
            if (tweetBtn) tweetBtn.removeEventListener(MouseEvent.CLICK, onClickTweet); 
            tweetBtn = null;
        }
    }
}
class ScoreList extends Sprite
{
    private var container: Sprite;
    private var containerMask: Shape;
    private var scrollBar: VScrollBar;
    private var scoreLength: int;
    private var myScoreLCIndex: int;
    private var listChildren: Vector.<ListChild>;
    private var myScoreLC: ListChild;
    private var scrollValue: int;
    private var isClear: Boolean;
    private var highLightEffect:Shape;
    private var targetY: int;
    private var tween:ITweenGroup;
    private var w: int, h: int;
    function ScoreList(x: int, y: int, w: int, h: int)
    {
        this.x = x, this.y = y, this.w = w - 10, this.h = h;
        addChild(container = new Sprite());
        addChild(containerMask = new Shape());
        container.mask = containerMask;
        var g: Graphics = containerMask.graphics;
        g.beginFill(0xFFFFFF), g.drawRect(0, 0, this.w, h);
        scrollBar = new VScrollBar(this, this.w, 0);
        scrollBar.height = h;
    }
    
    public function add(scores: Vector.<ScoreData>, name: String, score: int): void 
    {
        scoreLength = scores.length, myScoreLCIndex = -1;
        listChildren = new Vector.<ListChild>(scoreLength, true);
        for ( var i: int = 0; i < scoreLength; i++ )
        {
            var s: ScoreData = scores[i];
            if (s.name == name && s.score == score) myScoreLCIndex = i;
            var listChild: ListChild = listChildren[i] = new ListChild(w, 21, i + 1, s.name, String(s.score / _denominator) + " " + _addScoreAfter);
            listChild.y = 20 * (i - (myScoreLCIndex < 0 ? 0 : 1));
            if (myScoreLCIndex == i) myScoreLC = listChild;
            else container.addChild(listChild);
        }
        var setScrollBar: Function = function(): void
        {
            scrollBar.setThumbPercent(13 / (scoreLength - 1));
            var max: int = scoreLength - 1 - 13;
            if (max < 0) max = 0;
            var now: int = myScoreLCIndex - 13;
            if (now < 0) now = 0;
            scrollBar.setSliderParams(0, max, now);
            scrollValue = now;
            scrollBar.addEventListener(Event.CHANGE, onChangeScroll);
            tween = null;
            if (isClear) clear();
        };
        if (myScoreLC) 
        {
            highLightEffect = new Shape();
            var g: Graphics = highLightEffect.graphics;
            g.beginFill(0x80FFFF);
            g.drawRect(- w >> 1, - 10, w, 21);
            myScoreLC.scaleX = myScoreLC.scaleY = 1.5;
            myScoreLC.alpha = 0;
            myScoreLC.x = w  - myScoreLC.width  >> 1;
            highLightEffect.x = w >> 1;
            if (myScoreLCIndex > 13) 
            {
                // 画面をスクロール
                myScoreLC.y = (targetY = 13 * 20) + (20 - myScoreLC.height >> 1);
                container.y = (13 - myScoreLCIndex) * 20;
            }
            else 
            {
                myScoreLC.y = (targetY = myScoreLCIndex * 20) + (20 - myScoreLC.height >> 1);
            }
            highLightEffect.y = targetY + 10;
            addChild(myScoreLC);
            var arr: Array = [];
            if (myScoreLCIndex != scoreLength - 1)
            {
                for (i = myScoreLCIndex + 1; i < scoreLength; i++ )
                {
                    arr.push(BetweenAS3.to(listChildren[i], { y: listChildren[i].y + 20 }, 0.5, Quad.easeInOut));
                }
            }
            arr.push(BetweenAS3.to(myScoreLC, { x: 0, y: targetY, scaleX: 1, scaleY:1 }, 0.5, Quad.easeOut));
            tween = BetweenAS3.serial(
                BetweenAS3.to(myScoreLC, { alpha: 1 }, 0.5),
                BetweenAS3.parallelTweens(arr),
                BetweenAS3.addChild(highLightEffect, this),
                BetweenAS3.to(highLightEffect, { alpha: 0, scaleX: 1.3, scaleY: 1.3 }, 0.5, Quad.easeOut),
                BetweenAS3.parallel(
                    BetweenAS3.removeFromParent(highLightEffect), BetweenAS3.removeFromParent(myScoreLC)
                )
            );
            tween.onComplete = function(): void
            {
                tween.onComplete = null;
                tween = null;
                myScoreLC.y = myScoreLCIndex * 20;
                container.addChildAt(myScoreLC, myScoreLCIndex);
                setScrollBar();
            };
            tween.play();
        }
        else 
        {
            setScrollBar();
        }
    }
    
    public function clear():void 
    {
        if (tween)
        {
            isClear = true;
        }
        else 
        {
            while (numChildren > 0) removeChildAt(0);
            while (container.numChildren > 0) container.removeChildAt(0);
            for (var i: int = 0; i < scoreLength; i ++ ) listChildren[i].clear();
            container.mask = null;
            container = null;
            containerMask = null;
            scrollBar = null;
            myScoreLC = null;
            highLightEffect = null;
        }
    }
    
    private function onChangeScroll(e:Event):void 
    {
        if (scrollValue == scrollBar.value) return;
        scrollValue = scrollBar.value;
        container.y = - scrollValue * 20;
    }
}
class ListChild extends Sprite
{
    private var indexLabel: Label;
    private var label: Label;
    private var scoreLabel: Label;
    function ListChild(w: int, h: int, index: int, userName: String, score: String)
    {
        BackupStyle.styleSet();
        var g: Graphics = graphics;
        g.beginFill(0xCCCCCC);
        g.drawRect(0, 0, w, h);
        g.drawRect(1, 1, w - 2, h - 2);
        g.beginFill(0xFFFFFF);
        g.drawRect(1, 1, w - 2, h - 2);
        indexLabel = new Label(this, 5, 0, String(index));
        label = new Label(this, 25, 0, userName);
        scoreLabel = new Label(this, 0, 0, score);
        scoreLabel.draw();
        scoreLabel.x = w - scoreLabel.width - 5;
        BackupStyle.styleBack();
    }
    
    public function clear():void 
    {
        graphics.clear();
        while (numChildren > 0) removeChildAt(0);
        indexLabel = null;
        label = null;
        scoreLabel = null;
    }
}

class BackupStyle
{
    public static var BACKGROUND: uint = 0xCCCCCC;
    public static var BUTTON_FACE: uint = 0xFFFFFF;
    public static var INPUT_TEXT: uint = 0x333333;
    public static var LABEL_TEXT: uint = 0x666666;
    public static var DROPSHADOW: uint = 0x000000;
    public static var PANEL: uint = 0xF3F3F3;
    public static var PROGRESS_BAR: uint = 0xFFFFFF;
    
    public static var embedFonts: Boolean = true;
    public static var fontName: String = "PF Ronda Seven";
    public static var fontSize: Number = 8;
    
    private static var b: Object;
    
    public static function styleSet(): void
    {
        b = {
            BACKGROUND:        Style.BACKGROUND,    BUTTON_FACE:    Style.BUTTON_FACE, 
            INPUT_TEXT:        Style.INPUT_TEXT,    LABEL_TEXT:        Style.LABEL_TEXT, 
            DROPSHADOW:        Style.DROPSHADOW,    PANEL:            Style.PANEL, 
            PROGRESS_BAR:    Style.PROGRESS_BAR,    embedFonts:        Style.embedFonts, 
            fontName:        Style.fontName,        fontSize:        Style.fontSize
        };
        Style.BACKGROUND = BACKGROUND,         Style.BUTTON_FACE = BUTTON_FACE;
        Style.INPUT_TEXT = INPUT_TEXT,         Style.LABEL_TEXT = LABEL_TEXT;
        Style.DROPSHADOW = DROPSHADOW,         Style.PANEL = PANEL;
        Style.PROGRESS_BAR = PROGRESS_BAR,     Style.embedFonts = embedFonts;
        Style.fontName = fontName,             Style.fontSize = fontSize;
    }
    
    public static function styleBack(): void
    {
        Style.BACKGROUND = b["BACKGROUND"], Style.BUTTON_FACE = b["BUTTON_FACE"];
        Style.INPUT_TEXT = b["INPUT_TEXT"], Style.LABEL_TEXT = b["LABEL_TEXT"];
        Style.DROPSHADOW = b["DROPSHADOW"], Style.PANEL = b["PANEL"];
        Style.PROGRESS_BAR = b["PROGRESS_BAR"], Style.embedFonts = b["embedFonts"];
        Style.fontName = b["fontName"], Style.fontSize = b["fontSize"];
    }
}
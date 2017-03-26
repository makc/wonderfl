/*
 * デザイン「あ」 の 「あ」のうた http://www.nhk.or.jp/design-ah/ah-song/
 * がすごい好きだったので真似して作って見ました。
 * フルスクリーンで見ると綺麗かもしれません。
 * 
 * 「あ」のうたのインターフェースで「あ」のうた以外の曲を流すという邪道っぷりですが、お許し下さい。
 * 曲も真似して作ろうと思ったんですが、技量が足りませんでした...
 * 
 * 
 * 環境によってはマイクの反応が悪い場合があります。マイクに近づくか大きな声で発音してください。
 * ノートPCなどスピーカーとマイクが近い場合はマイクがスピーカーの音を拾ってしまうのでイヤホンでお聴きください。
 * 
 * 
 * mp3アップロードはmakc3dさんの
 * http://wonderfl.net/c/wzzu
 * にあるClientMP3Loaderをお借りしました。
 */

package  
{
    import caurina.transitions.*;
    import flash.display.*;
    import flash.events.*;
    import flash.geom.*;
    import flash.system.*;
    import flash.text.*;
    import flash.ui.*;
    import frocessing.color.ColorHSV;
    
    [SWF(width = 465, height = 465, backgroundColor = 0xffffff, frameRate = 30)]
    public class DesignAh extends Sprite 
    {
        private var lang:Namespace;
        private namespace ja;
        private namespace en;
        
        private var descriptionTxt:TextField;
        public static const FONT_NAME:String = "_sans";
        private const FONT_SIZE:int = 24;
        
        private var texts:Array/*String*/ = [];
        private const DESCRIPTION1:int = 0;
        private const READY:int = 1;
        private const CANCEL:int = 2;
        private const OK:int = 3;
        private const THANKS:int = 4;
        private const ENJOY:int = 5;
        private const NEXT:int = 6;
        private const SELECT_MUSIC:int = 7;
        private const WELCOME:int = 8;
        private const MIC:int = 9;
        private const SOUND:int = 10;
        private const THEME_LEFT:int = 11;
        private const THEME_RIGHT:int = 12;
        
        private var drawingPanel:DrawingPanel;
        private var centerDrawingPanel:Sprite;
        
        private var soundButton:NavigationButton;
        private var micButton:NavigationButton;
        private var nextButton:NavigationButton;
        
        private var cancelButton:NavigationButton;
        private var okButton:NavigationButton;
        
        private var maxLines:int;
        private var displayLines:int;
        
        private var defaultSound:AhSound;
        private var loadedDefaultSound:Boolean = false;
        
        private var sounds:Vector.<AhSoundBase>;
        private var loadCount:int = 0;
        private var maxSounds:int;
            
        private var panelClasses:Vector.<Class>;
        private var listPanel:ListPanel;
        private var panels:Vector.<DisplayPanel>;
        
        private var extendMode:Boolean;
        private var color:ColorHSV = new ColorHSV(0, 0.7);

        private var bg:Shape;
        
        public function DesignAh() {
            stage.align = StageAlign.TOP;
            stage.scaleMode = StageScaleMode.SHOW_ALL;
            
            bg = new Shape();
            bg.graphics.beginFill(0);
            bg.graphics.drawRect( -465, 0, 465 * 3, 465);
            bg.graphics.endFill();
            addChild(bg);    
            
            checkLanguage();
            lang::init();
            initDescriptionTxt();
            initDrawingPanel();
            initButton();
            initPanelClasses();
            initDefaultSound();
            extendKey();
            maskStage();
            
            sounds = new Vector.<AhSoundBase>();
            
            startWelcomMessage();

        }
        
        private function extendKey():void {
            stage.addEventListener(KeyboardEvent.KEY_DOWN, function(e:KeyboardEvent):void {
                if (e.keyCode == Keyboard.SHIFT)extendMode = true;
            });
            
            stage.addEventListener(KeyboardEvent.KEY_UP, function(e:KeyboardEvent):void {
                if (e.keyCode == Keyboard.SHIFT)extendMode = false;
            });
        }
        
        private function initDefaultSound():void {
            defaultSound = new AhSound("http://www.takasumi-nagai.com/soundfiles/sound001.mp3", "SOUND");
            defaultSound.addEventListener(Event.COMPLETE, onCompleteDefaultSound);
            defaultSound.addEventListener(IOErrorEvent.IO_ERROR, onDefaultSoundIOError);
        }
        
        private function onDefaultSoundIOError(e:IOErrorEvent):void { loadedDefaultSound = true;}
        private function onCompleteDefaultSound(e:Event):void { loadedDefaultSound = true;}
        
        private function checkLanguage():void {
            lang = Capabilities.language == "ja" ? ja : en;
        }
        
        ja function init():void {
            texts[DESCRIPTION1] = "画面に「あ」と書いてください。";
            texts[READY] = "これでいいですか？";
            texts[CANCEL] = "書きなおす";
            texts[OK] = "はい";
            texts[THANKS] = "ありがとうございました。\n\n\n\n\n\n\n\n\n\n";
            texts[ENJOY] = "それではどうぞお楽しみください。";
            texts[NEXT] = "次へ";
            texts[SELECT_MUSIC] = "再生したい音楽を選んでください。\n\n\n\n\n\n\n\n\n\n";
            texts[WELCOME] = "「あ」のうたへ ようこそ。\n\n\n\n\n\n\n\n\n\n";
            texts[MIC] = "マイク";
            texts[SOUND] = "サウンド";
            texts[THEME_LEFT] = "「";
            texts[THEME_RIGHT] = "」のテーマ";
            
            maxLines = 3;
            displayLines = 3;
        }
        
        en function init():void {
            texts[DESCRIPTION1] = "please write 'A' on the screen.";
            texts[READY] = "are you ready?";
            texts[CANCEL] = "try again";
            texts[OK] = "ok";
            texts[THANKS] = "thank you.\n\n\n\n\n\n\n\n\n\n";
            texts[ENJOY] = "let's enjoy.";
            texts[NEXT] = "next";
            texts[SELECT_MUSIC] = "please select the music to play.\n\n\n\n\n\n\n\n\n\n";
            texts[WELCOME] = "welcome to the song of 'Ah'.\n\n\n\n\n\n\n\n\n\n";
            texts[MIC] = "Microphone";
            texts[SOUND] = "Sound";
            texts[THEME_LEFT] = "Theme of '";
            texts[THEME_RIGHT] = "'";
            
            maxLines = 3;
            displayLines = 2;
        }
        
        private function initDescriptionTxt():void {
            descriptionTxt = new TextField();
            descriptionTxt.autoSize = TextFieldAutoSize.CENTER;
            descriptionTxt.selectable = false;
            
            descriptionTxt.defaultTextFormat = new TextFormat(FONT_NAME, FONT_SIZE, 0xffffff);
            descriptionTxt.text = " ";
            descriptionTxt.y = stage.stageHeight / 2 - descriptionTxt.height;
            descriptionTxt.x = stage.stageWidth / 2 - descriptionTxt.width / 2;
            addChild(descriptionTxt);
        }
        
        private function initDrawingPanel():void {
            drawingPanel = new DrawingPanel(stage, 3);
            drawingPanel.x = -drawingPanel.width / 2;
            drawingPanel.y = -drawingPanel.height / 2;
            
            centerDrawingPanel = new Sprite();
            centerDrawingPanel.addChild(drawingPanel);
            centerDrawingPanel.x = stage.stageWidth / 2;
            centerDrawingPanel.y = stage.stageHeight / 2;
        }
        
        private function initPanelClasses():void {
            panelClasses = new Vector.<Class>();
            panelClasses.push(Spring);
            panelClasses.push(FlyingCircle);
            panelClasses.push(Outline);
            panelClasses.push(Mosaic);
            
            maxSounds = panelClasses.length;
        }
        
        private function initButton():void {
            var offsetX:int = 10;
            var offsetY:int = 20;
            
            soundButton = new NavigationButton(texts[SOUND], FONT_SIZE, false);
            soundButton.x = stage.stageWidth / 2 - soundButton.width / 2;
            soundButton.y = stage.stageHeight / 2 - soundButton.height / 2 + offsetY;
            soundButton.addEventListener(MouseEvent.CLICK, onSoundSet);
            
            micButton = new NavigationButton(texts[MIC], FONT_SIZE, false);
            micButton.x = stage.stageWidth / 2 - micButton.width / 2;
            micButton.y = soundButton.y - micButton.height - 20 - offsetY;        
            micButton.addEventListener(MouseEvent.CLICK, onMicSet);
            
            nextButton = new NavigationButton(texts[NEXT], FONT_SIZE, false);
            nextButton.x = stage.stageWidth - nextButton.width - offsetX;
            nextButton.y = stage.stageHeight - nextButton.height - offsetY;
            nextButton.addEventListener(MouseEvent.CLICK, onNext);
            
            cancelButton = new NavigationButton(texts[CANCEL], FONT_SIZE, true);
            cancelButton.x = offsetX;
            cancelButton.y = stage.stageHeight - cancelButton.height - offsetY;
            cancelButton.addEventListener(MouseEvent.CLICK, onDrawCancel);
            
            okButton = new NavigationButton(texts[OK], FONT_SIZE, false);
            okButton.x = stage.stageWidth - okButton.width - offsetX;
            okButton.y = stage.stageHeight - okButton.height - offsetY;
            okButton.addEventListener(MouseEvent.CLICK, onDrawOK);
        }
        
        private function maskStage():void {
            var m:Shape = new Shape();
            m.graphics.beginFill(0x0, 0);
            m.graphics.drawRect(-stage.stageWidth, 0, stage.stageWidth*3, stage.stageHeight);
            m.graphics.endFill();
            addChild(m);
            mask = m;            
        }
        
        private function startWelcomMessage():void {            
            TypeWriterAnimation.startAnimation(descriptionTxt, texts[WELCOME], 100, function():void {
                TypeWriterAnimation.startAnimation(descriptionTxt, texts[SELECT_MUSIC], 100, nextAnimation);
            });
            
            function nextAnimation():void {
                Tweener.addTween(descriptionTxt, { y:30, time:1, transition:"easeOutCubic" } );    
                
                var toX:Number = soundButton.x;
                soundButton.x = stage.stageWidth * 2;
                Tweener.addTween(soundButton, {x:toX, time:0.5, transition:"easeOutCubic" } );                
                addChild(soundButton);
                
                toX = micButton.x;
                micButton.x = stage.stageWidth * 2;
                Tweener.addTween(micButton, {x:toX, time:0.5, delay:0.1, transition:"easeOutCubic" } );                
                addChild(micButton);
                
                toX = nextButton.x;
                nextButton.x = -stage.stageWidth * 2 - nextButton.width;
                Tweener.addTween(nextButton, {x:toX, time:0.5,delay:0.2, transition:"easeOutCubic" } );                    
                addChild(nextButton);
            }
        }
        
        private function onNext(e:MouseEvent):void {
            nextButton.removeEventListener(MouseEvent.CLICK, onNext);
            
            if (loadCount == 0) sounds.push(defaultSound);
            
            if (contains(soundButton)) removeChild(soundButton);
            if (contains(micButton)) removeChild(micButton);
            removeChild(nextButton);
            
            if (extendMode && sounds.length == 1) {
                sounds[0].addEventListener(AhSoundEvent.ACTIVE_COUNT, extendActiveCount);
            }
                        
            descriptionTxt.text = " ";
            descriptionTxt.y = stage.stageHeight / 2 - descriptionTxt.height;
            startDrawMessage();
        }
        
        private function onMicSet(e:MouseEvent):void {
            micButton.removeEventListener(MouseEvent.CLICK, onMicSet);
            removeChild(micButton);            
            var s:AhMicrophone = new AhMicrophone();
            s.addEventListener(Event.COMPLETE, onSoundComplete);
        }
        
        private function extendActiveCount(e:AhSoundEvent):void {
            if(listPanel && listPanel.running){
                for (var i:int = 0; i < panels.length; i++ ) {
                    var panel:DisplayPanel = panels[i];
                    color.h = Math.random() * 360;
                    panel.color = color.value;
                }
            }
            
        }
        
        private function onSoundSet(e:MouseEvent):void {
            var s:AhSoundLocal = new AhSoundLocal();
            s.addEventListener(Event.COMPLETE, onSoundComplete);
        }        
        
        private function onSoundComplete(e:Event):void {
            var sound:AhSoundBase = e.currentTarget as AhSoundBase;
            sounds.push(sound);
            loadCount++;
            if (loadCount == maxSounds) {
                removeChild(soundButton);
                if (contains(micButton)) removeChild(micButton);
            }
        }
        
        private function startDrawMessage():void {
            TypeWriterAnimation.startAnimation(descriptionTxt, texts[DESCRIPTION1], 100, nextAnimation);

            function nextAnimation():void {
                Tweener.addTween(descriptionTxt, { y:20, time:1, delay:1, transition:"easeOutCubic" } );
                
                centerDrawingPanel.alpha = 0;
                centerDrawingPanel.scaleX = centerDrawingPanel.scaleY = 0;
                addChild(centerDrawingPanel);
            
                Tweener.addTween(centerDrawingPanel, { alpha:1, scaleX:1, scaleY:1, time:1, delay:1, transition:"easeOutCubic", onComplete:function():void {
                    drawingPanel.start();
                    drawingPanel.addEventListener(ProgressEvent.PROGRESS, onDrawProgress);                        
                }} );
            }            
        }
        
        private function onDrawOK(e:MouseEvent):void {
            drawingPanel.stop();        
            removeDrawPanelButton();
            ready();
        }
        
        private function onDrawCancel(e:MouseEvent):void {
            drawingPanel.init();
            drawingPanel.start();
            removeDrawPanelButton();
            TypeWriterAnimation.startAnimation(descriptionTxt, texts[DESCRIPTION1], 100);        
        }
        
        private function addDrawPanelButton():void {            
            cancelButton.alpha = okButton.alpha = 0;
            addChild(cancelButton);
            addChild(okButton);
            
            Tweener.addTween(cancelButton, {alpha:1, time:1, transition:"easeOutCubic" } );
            Tweener.addTween(okButton, { alpha:1, time:1, transition:"easeOutCubic" } );
        }
                
        private function removeDrawPanelButton():void {
            cancelButton.alpha = okButton.alpha = 0;        
            removeChild(cancelButton);
            removeChild(okButton);            
            
        }
        
        private function onDrawProgress(e:ProgressEvent):void {
            if (drawingPanel.lineLength == displayLines) {
                addDrawPanelButton();
                
                TypeWriterAnimation.startAnimation(descriptionTxt, texts[READY], 100);
            }
        }

        
        private function ready():void {
            centerDrawingPanel.removeChild(drawingPanel);
            removeChild(descriptionTxt);
            
            descriptionTxt.y = stage.stageHeight / 2 - descriptionTxt.height;
            Tweener.addTween(descriptionTxt, { time:1, onComplete:function():void {
                TypeWriterAnimation.startAnimation(descriptionTxt, texts[THANKS], 100, function():void {
                    TypeWriterAnimation.startAnimation(descriptionTxt, texts[ENJOY], 100, function():void {
                        Tweener.addTween(descriptionTxt, { delay:1, time:2, alpha:0, onComplete:function():void { 
                            removeChild(descriptionTxt); 
                            startDrawingAnimation();
                        }} );                        
                    });
                });
                addChild(descriptionTxt);
            } } );

        }        
        
        private function startDrawingAnimation():void {
            panels = new Vector.<DisplayPanel>();
            listPanel = new ListPanel(stage, new Rectangle(0, 0, stage.stageWidth, stage.stageHeight));
            listPanel.x = stage.stageWidth * 2;
            
            var lines:Vector.<Line> = drawingPanel.lines;
            
            listPanel.addFirst(new ThemeOfAh(Line.cloneLines(lines), texts[THEME_LEFT], texts[THEME_RIGHT]));
            
            for (var j:int = 0; j < panelClasses.length; j++) {
                var PanelClass:Class = panelClasses[j];
                var panel:DisplayPanel = new PanelClass(stage, Line.cloneLines(lines), sounds[j % sounds.length]);
                panels.push(panel);
                listPanel.add(panel);
            }
            
            if (loadedDefaultSound) {
                start();
            }else {
                addEventListener(Event.ENTER_FRAME, function(e:Event):void {
                    if (loadedDefaultSound) {
                        e.currentTarget.removeEventListener(e.type, arguments.callee);
                        start();
                    }
                });
            }
            
            function start():void{
                addChild(listPanel);
                Tweener.addTween(listPanel, { x:0, time:2, transition:"easeOutQuint", onComplete:function():void {
                    for (var i:int = 0; i < sounds.length; i++) sounds[i].start();                    
                    listPanel.start();                    
                }} );
            }
        }
    }
}

import caurina.transitions.*;
import com.codeazur.as3swf.*;
import com.codeazur.as3swf.data.*;
import com.codeazur.as3swf.tags.*;
import flash.display.*;
import flash.events.*;
import flash.geom.*;
import flash.media.*;
import flash.net.*;
import flash.system.*;
import flash.text.*;
import flash.utils.*;

/*//////////////////////////////////////////////////
 * 
 * 文字を描く時のクラス
 * 
/*//////////////////////////////////////////////////

/**
 * 「あ」の文字を描く時のパネル
 */
class DrawingPanel extends Sprite {
    
    private const RECT_SIZE:int = 300;
    private const RECT_OFFSET:int = 3;
    private const SPACES:int = 20;
    
    private const COLOR:uint = 0xffffff;
    private const LINE_SIZE:int = 7;
    
    private var _drawCount:int;
    private var _lines:Vector.<Line>;
    private var _line:Line;
    
    private var _stage:Stage;
    private var _maxLines:int;
    
    private var _canvases:Vector.<Shape>;
    private var _canvas:Shape;
    
    private var _resultPanel:Spring;
    
    public function DrawingPanel(stage:Stage, maxLines:int) {
        this._stage = stage;
        this._maxLines = maxLines;

        drawBaseLine();        
        init();
    }
    
    public function init():void {
        if (_canvases) {
            for (var i:int = 0; i < _canvases.length; i++) {
                if(contains(_canvases[i]))
                    removeChild(_canvases[i]);
            }
        }
        _canvases = new Vector.<Shape>();
        
        if (_resultPanel) {
            removeChild(_resultPanel);
            _resultPanel.removeEventListener(Event.ENTER_FRAME, resultUpdate);
        }
        
        _lines = new Vector.<Line>();
        _drawCount = 0;

    }
    
    public function start():void {
        _stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);        
    }
    
    public function stop():void {
        _stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
    }
    
    public function get lineLength():int {
        return lines.length;
    }
    
    public function get lines():Vector.<Line> {
        return _lines;
    }
    
    
    private function onMouseDown(e:MouseEvent):void {
        var x:Number = mouseX;
        var y:Number = mouseY;        
        if(x >= RECT_OFFSET && x <= RECT_SIZE - RECT_OFFSET && y >= RECT_OFFSET && y <= RECT_SIZE - RECT_OFFSET){
            _stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
            _stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
            _line = new Line(new Rectangle(0, 0, RECT_SIZE, RECT_SIZE));
            
            _canvas = new Shape();
            addChild(_canvas);
            _canvas.graphics.lineStyle(LINE_SIZE, COLOR, 1, false, LineScaleMode.NORMAL, CapsStyle.SQUARE, JointStyle.BEVEL);        
            _canvas.graphics.moveTo(x, y);
        }
    }
    
    private function onMouseMove(e:MouseEvent):void {
        var x:Number = mouseX;
        var y:Number = mouseY;
        
        if (x < RECT_OFFSET) {
            x = RECT_OFFSET;
        }else if(x > RECT_SIZE - RECT_OFFSET){
            x = RECT_SIZE - RECT_OFFSET;
        }
        
        if (y < RECT_OFFSET) {
            y = RECT_OFFSET;
        }else if (y > RECT_SIZE - RECT_OFFSET) {
            y = RECT_SIZE - RECT_OFFSET;
        }
        
        _line.add(new Point(x, y));
        _canvas.graphics.lineTo(x, y);
    }
    
    private function onMouseUp(e:MouseEvent):void {
        _stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
        _stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
        
        var length:int = _line.length;
        
        if (length > 10 && length < 400) {
            _canvases.push(_canvas);
            _lines.push(_line);    
            
            dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false, lineLength, _maxLines));
            
            _drawCount++;
            if (_drawCount == _maxLines) {
                for (var i:int = 0; i < _canvases.length; i++) {
                    if(contains(_canvases[i]))
                        removeChild(_canvases[i]);
                }
            
                _resultPanel = new Spring(_stage, Line.cloneLines(_lines), null);
                _resultPanel.addEventListener(Event.ENTER_FRAME, resultUpdate);
                addChild(_resultPanel);
                
                stop();
                dispatchEvent(new Event(Event.COMPLETE, false, false));
            }            
        }else {
            removeChild(_canvas);
        }
    }
    
    private function resultUpdate(e:Event):void {
        _resultPanel.update();
    }
    
    private function drawBaseLine():void {
        graphics.lineStyle(1, COLOR);
        graphics.beginFill(COLOR, 0.01);
        graphics.drawRect(0, 0, RECT_SIZE, RECT_SIZE);

        graphics.moveTo(0, RECT_SIZE / 2);
        graphics.lineTo(RECT_SIZE, RECT_SIZE / 2);
        
        graphics.moveTo(RECT_SIZE / 2, 0);
        graphics.lineTo(RECT_SIZE / 2, RECT_SIZE);
        
        graphics.lineStyle(0, COLOR, 0.2);
        var dist:Number = RECT_SIZE / 20;
        var i:int;
        
        for (i = dist; i < RECT_SIZE; i += dist) {
            graphics.moveTo(i, 0);
            graphics.lineTo(i, RECT_SIZE);
        }
        
        for (i = dist; i < RECT_SIZE; i += dist) {
            graphics.moveTo(0, i);
            graphics.lineTo(RECT_SIZE, i);
        }            
        
        graphics.endFill();
    }
}

/**
 * 描いた線の情報を保持するクラス
 */
class Line {
    
    private var _points:Vector.<Point>;
    private var _region:Rectangle;
    private var _normalized:Boolean = false;
    
    public function Line(region:Rectangle) {
        _region = region;
        _points = new Vector.<Point>();
    }
    
    public function add(p:Point):void {_points.push(p);}
    
    public function get(index:int):Point {return _points[index];}
    
    public function get length():int {return _points.length;}
    
    public function get normalized():Boolean {return _normalized;}
    
    public function get region():Rectangle {return _region;}
    
    public function optimize(d:int = 3):void {
        
        var newPoints:Vector.<Point> = new Vector.<Point>();
        
        newPoints.push(_points[0]);
        for (var j:int = d; j < _points.length - 1; j += d) {
            newPoints.push(_points[j]);
        }
        newPoints.push(_points[_points.length - 1]);

        _points =  newPoints;
    }    
    
    public function normalize():void {
        if (normalized) return;
        
        _normalized = true;
        
        for (var i:int = 0; i < _points.length; i++) {
            var p:Point = _points[i];
            p.x /= region.width;
            p.y /= region.height;
        }
    }
    
    public function denormalize(region:Rectangle):void {
        if (!normalized) return;
        
        _normalized = false;
        
        _region = region;
        
        for (var i:int = 0; i < _points.length; i++) {
            var p:Point = _points[i];
            p.x *= region.width;
            p.y *= region.height;
        }    
    }
    
    public function clone():Line {
        var line:Line = new Line(new Rectangle(region.x, region.y, region.width, region.height));
        
        for (var i:int = 0; i < this.length; i++) {
            var p:Point = this.get(i);
            line.add(new Point(p.x, p.y));
        }
        
        return line;
    }        
    
    public static function cloneLines(lines:Vector.<Line>):Vector.<Line> {
        var nl:Vector.<Line> = new Vector.<Line>();
        for (var i:int = 0; i < lines.length; i++) {
            nl.push(lines[i].clone());
        }
        
        return nl;
    }    
}

/*//////////////////////////////////////////////////
 * 
 * 「あ」のパネルを並べてスライドさせるクラス
 * 
/*//////////////////////////////////////////////////


/**
 * パネルを並べて表示するクラス
 */
class ListPanel extends Sprite {
    
    private var _stage:Stage;
    private var _region:Rectangle;
    
    private var _wrapPanels:Vector.<WrapPanel>;
    
    private var _drag:Boolean = false;
    private var _prevMouseX:Number = 0;
    private var _prevEnterMouseX:Number = 0;
    private var _tweenObj:Object = new Object();
    private var _running:Boolean = false;
    
    private var _topPos:Number;
    
    private var _first:Boolean = true;
    
    private var _themePanel:DisplayPanel;
    
    public function ListPanel(stage:Stage, region:Rectangle) {
        _stage = stage;
        _region = region;
        
        _topPos = region.width;
        
        _wrapPanels = new Vector.<WrapPanel>();
        
        buttonMode = true;
        useHandCursor = true;
        
        graphics.beginFill(0, 0);
        graphics.drawRect( -_region.width, 0, _region.width * 3, _region.height);
        graphics.endFill();
    }
    
    public function add(panel:DisplayPanel):void {
        var wp:WrapPanel = new WrapPanel(panel, _region);
        wp.x = _topPos + _region.width * _wrapPanels.length;
        addChild(wp);
        _wrapPanels.push(wp);
    }
    
    public function addFirst(themePanel:DisplayPanel):void {
        _themePanel = themePanel;
        _themePanel.x = _region.width / 2 - _themePanel.width / 2;
        _themePanel.y = _region.height / 2 - _themePanel.height / 2;
        addChild(_themePanel);
    }
    
    public function start():void {
        if (_running) return ;
        
        _running = true;
        _stage.addEventListener(Event.ENTER_FRAME, onUpdate);
        _stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
        _stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
        _stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
        
        for (var i:int = 0; i < _wrapPanels.length; i++){
            _wrapPanels[i].displayPanel.start();
        }
    }

    public function stop():void {
        if (!_running) return ;
        
        _running = false;
        _stage.removeEventListener(Event.ENTER_FRAME, onUpdate);
        _stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
        _stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
        _stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);

        for (var i:int = 0; i < _wrapPanels.length; i++){
            _wrapPanels[i].displayPanel.stop();
        }        
    }
    
    private function onUpdate(e:Event):void {
        if (!_drag) move( -3);
        _prevEnterMouseX = mouseX;
    }
    
    private function onMouseDown(e:MouseEvent):void {
        _drag = true;
    }    
    
    private function onMouseUp(e:MouseEvent):void {
        _drag = false;
        
        _tweenObj.x = (mouseX - _prevEnterMouseX) ;
        Tweener.addTween(_tweenObj, { x:0, time:0.5, transition:"easeOutQuint", onUpdate:function():void {
            move(_tweenObj.x);
        }} );
    }
    
    private function onMouseMove(e:MouseEvent):void {
        if (_drag) move(mouseX - _prevMouseX);
        
        _prevMouseX = mouseX;    
    }    
    
    private function move(dx:Number):void {
        if (dx < 0 ) {
            //左
            if (_topPos < -_region.width * 2) {
                if (_first) {
                    _first = false;
                    removeChild(_themePanel);
                }
                
                var e1:WrapPanel = _wrapPanels.shift();
                _wrapPanels.push(e1);
                _topPos = _wrapPanels[0].x;
            }
        }else if(!_first){
            //右
            if (_topPos >= -_region.width) {
                _topPos = _wrapPanels[0].x - _region.width;
                var e2:WrapPanel = _wrapPanels.pop();
                _wrapPanels.unshift(e2);
            }
        }
        
        _topPos += dx;        
        
        if(_first) _themePanel.x += dx;
        
        for (var i:int = 0; i < _wrapPanels.length; i++) {
            var panel:WrapPanel = _wrapPanels[i];
            panel.x = _topPos + _region.width * i;
            
            if (panel.x >= -_region.width*2 && panel.x <= _region.width*2) {
                panel.displayPanel.start();
            }else {
                panel.displayPanel.stop();
            }
        }        
    }
    
    public function get running():Boolean {    return _running;}
}

class WrapPanel extends Sprite {
    
    private var _panel:DisplayPanel;
    private var _acp:ActiveCountPanel;
    private var _region:Rectangle;
    
    public function WrapPanel(panel:DisplayPanel, region:Rectangle) {
        _panel = panel;
        _region = region;
        
        graphics.beginFill(0x0, 0);
        graphics.drawRect(0, 0, _region.width, _region.height);
        graphics.endFill();

        panel.x = _region.width/2 - panel.width / 2;
        panel.y = _region.height/2 - panel.height / 2;
        addChild(panel);
        
        _acp = new ActiveCountPanel(panel.sound, panel.sound.voiceName);
        _acp.x = 10;
        _acp.y = _region.height - _acp.height - 10;
        addChild(_acp);
    }
    
    public function get displayPanel():DisplayPanel {return _panel;}
    public function get activeCountPanel():ActiveCountPanel {return _acp;}
}

/*//////////////////////////////////////////////////
 * 
 * 「あ」をアニメーションさせるクラス
 * 
/*//////////////////////////////////////////////////

/**
 * 「あ」をアニメーションさせるパネルのベース
 */
class DisplayPanel extends Sprite {

    public const RECT_SIZE:int = 300;

    protected var lines:Vector.<Line>;
    protected var container:Stage;
    
    private var _sound:AhSoundBase;
    private var _running:Boolean = false;
    private var _color:uint = 0xffffff;
    
    private var dummy:Shape;

    public function DisplayPanel (container:Stage, lines:Vector.<Line>, sound:AhSoundBase) {
        this.lines = lines;
        this.container = container;
        
        _sound = sound;

        dummy = new Shape();
        dummy.graphics.beginFill(0x0, 0);
        dummy.graphics.drawRect(0, 0, RECT_SIZE, RECT_SIZE);
        dummy.graphics.endFill();
        addChild(dummy);
    }
    
    public function start():void {
        if (_running) return ;
        
        _running = true;
        addEventListener(Event.ENTER_FRAME, onUpdate);
        sound.addEventListener(AhSoundEvent.ACTIVE, onActive);
        sound.addEventListener(AhSoundEvent.ACTIVE_COUNT, onActiveCount);
    }

    public function stop():void {
        if (!_running) return ;
        
        _running = false;
        removeEventListener(Event.ENTER_FRAME, onUpdate);
        sound.removeEventListener(AhSoundEvent.ACTIVE, onActive);
        sound.removeEventListener(AhSoundEvent.ACTIVE_COUNT, onActiveCount);
    }
    
    public function get running():Boolean {return _running;}
    public function get color():uint {return _color;}
    public function set color(value:uint):void {_color = value;}
    public function get sound():AhSoundBase {return _sound;}
    
    private function onUpdate(e:Event):void {update();}
    private function onActive(e:AhSoundEvent):void {active();}    
    private function onActiveCount(e:AhSoundEvent):void {activeCount();}
    
    public function update():void {}    
    public function active():void {}    
    public function activeCount():void {}    
}

/**
 * 最初に流れる 「あ」のテーマ の文字
 */
class ThemeOfAh extends DisplayPanel {
    
    private const FONT_SIZE:int = 50;
    private const AH_SIZE:int = 80;
    
    public function ThemeOfAh(lines:Vector.<Line>, leftText:String, rightText:String) {
        super(null, lines, null);
        
        var lt:TextField = new TextField();
        lt.autoSize = TextFieldAutoSize.LEFT;
        lt.selectable = false;
        lt.defaultTextFormat = new TextFormat(DesignAh.FONT_NAME, FONT_SIZE, 0xffffff);
        lt.text = leftText;
        lt.y = this.height / 2 - lt.height / 2;
        addChild(lt);
        
        var ah:Shape = new Shape();
        for (var i:int = 0; i < lines.length; i++) {
            var l:Line = lines[i];
            l.normalize();
            l.denormalize(new Rectangle(0, 0, AH_SIZE, AH_SIZE));
            
            ah.graphics.lineStyle(5, 0xffffff, 1, false, LineScaleMode.NORMAL, CapsStyle.SQUARE, JointStyle.BEVEL);
            ah.graphics.moveTo(l.get(0).x, l.get(0).y);
            for (var j:int = 0; j < l.length; j++) {
                ah.graphics.lineTo(l.get(j).x, l.get(j).y);
            }
        }
        ah.x = lt.x + lt.width;
        ah.y = this.height / 2 - ah.height / 2;
        addChild(ah);
        
        var rt:TextField = new TextField();
        rt.autoSize = TextFieldAutoSize.LEFT;
        rt.selectable = false;
        rt.defaultTextFormat = new TextFormat(DesignAh.FONT_NAME, FONT_SIZE, 0xffffff);
        rt.text = rightText;
        rt.x = ah.x + AH_SIZE;
        rt.y = this.height / 2 - rt.height / 2;
        addChild(rt);
        
        if (Capabilities.os.indexOf("Mac") != -1) {
            lt.y += 4;
            rt.y += 4;
        }
    }
}

/**
 * 円がランダムで飛んでいくアニメーションのパネル
 */
class FlyingCircle extends DisplayPanel {
    
    private const RANDOM_DIST:Number = 4;
    
    private var _circles:Vector.<Circle>;
    
    public function FlyingCircle(container:Stage, lines:Vector.<Line>, sound:AhSoundBase) {
        super(container, lines, sound);

        _circles = new Vector.<Circle>();
        
        for (var i:int = 0; i < lines.length; i++) {
            lines[i].optimize();
            for (var j:int = 0; j < lines[i].length; j++) {
                var p:Point = lines[i].get(j);
                var circle:Circle = new Circle(p.x, p.y, 3 + Math.random() * 8, Math.random() * 2 * Math.PI, this.graphics);
                _circles.push(circle);
            }
        }        
        
    }

    override public function update():void {
        graphics.clear();
        graphics.beginFill(color);
        
        var circle:Circle;
            
        for (var i:int = 0; i < _circles.length; i++) {
            circle = _circles[i];
            
            if (!Tweener.isTweening(circle)){                
                circle.angle += Math.random() * 2 - 1;
                circle.x += Math.random() * RANDOM_DIST * Math.sin(circle.angle);
                circle.y += Math.random() * RANDOM_DIST * Math.cos(circle.angle);
                circle.size -= (circle.size - circle.initSize) / 10;
            }
            
            circle.update();
        }
    }
    
    override public function activeCount():void {
        graphics.clear();
        graphics.beginFill(color);
        
        var circle:Circle;
        
        for (var j:int = 0; j < _circles.length; j++) {
            circle = _circles[j];
            
            Tweener.addTween(circle, 
            {     x:circle.initX, 
                y:circle.initY, 
                size:circle.size  + circle.initSize * 0.5, 
                time:0.3, 
                transition:"easeOutExpo"
            } );
            
            circle.update();
        }                
    }
}

/**
 * 円
 */
class Circle {
    
    public var initX:Number;
    public var initY:Number;
    public var initSize:Number;
    
    public var x:Number;
    public var y:Number;
    public var angle:Number;
    public var size:Number;
    
    private var canvas:Graphics;
    
    public function Circle(x:Number, y:Number, size:Number, angle:Number, canvas:Graphics) {
        this.initX = x;
        this.initY = y;
        this.initSize = size;
        
        this.x = x;
        this.y = y;
        this.size = size;
        this.angle = angle;
        this.canvas = canvas;
    }
    
    public function update():void {
        canvas.drawCircle(x, y, size);
    }
}


/**
 * 「あ」の輪郭がゆれるアニメーションのパネル
 */
class Outline extends DisplayPanel {
    
    private const D:Number = 13;
    
    public function Outline(container:Stage, lines:Vector.<Line>, sound:AhSoundBase) {
        super(container, lines, sound);
        
        var newLines:Vector.<Line> = new Vector.<Line>();
        
        for (var i:int = 0; i < lines.length; i++) {
            lines[i].optimize(4);
            
            var line:Line = new Line(lines[i].region);
            newLines.push(line);
            
            var j:int;
            var p1:Point;
            var p2:Point;
            var np:Point;
            
            for (j = 0; j < lines[i].length-1; j++) {
                p1 = lines[i].get(j);
                p2 = lines[i].get(j+1);
                
                np = calcPoint(p1, p2, Math.PI/2);                
                line.add(np);
            }
            for (j = lines[i].length - 1; j > 0; j--) {
                p1 = lines[i].get(j);
                p2 = lines[i].get(j-1);
                
                np = calcPoint(p1, p2, Math.PI/2);
                
                line.add(np);
            }
        }
        this.lines = newLines;
    }
    
    private function calcPoint(p1:Point, p2:Point, rotateAngle:Number = Math.PI/2):Point {
        var dx:Number = p1.x - p2.x;
        var dy:Number = p1.y - p2.y;
        var centerP:Point = new Point((p1.x + p2.x) / 2, (p1.y + p2.y) / 2);
        
        var angle:Number = Math.atan2(dy, dx);
        angle += rotateAngle;
        
        centerP.x += D * Math.cos(angle);
        centerP.y += D * Math.sin(angle);
        
        return centerP;
    }
    
    override public function update():void {
        graphics.clear();
        
        var level:Number = sound.activityLevel / 100 * 80 + 2;
        var lineW:Number = sound.activityLevel / 100 * 8;
        for (var i:int = 0; i < lines.length; i++) {
            graphics.lineStyle(lineW, color);

            var first:Point = new Point(lines[i].get(0).x + Math.random() * level - level / 2, lines[i].get(0).y + Math.random() * level - level / 2);
            graphics.moveTo(first.x, first.y);

            for (var j:int = 1; j < lines[i].length; j++) {
                graphics.lineTo(lines[i].get(j).x + Math.random() * level - level / 2, lines[i].get(j).y + Math.random() * level - level / 2);
            }
            
            graphics.lineTo(first.x, first.y);
        }
    }
}

/**
 * バネの動きをするアニメーション
 */
class Spring extends DisplayPanel {
    
    private const D:Number = 13;
        
    private var springs:Vector.<SpringBall>;
    private var mouseDown:Boolean = false;
    private var turn:Boolean = false;
    
    public function Spring(container:Stage, lines:Vector.<Line>, sound:AhSoundBase) {
        super(container, lines, sound);
        
        var drawLines:Vector.<Line> = new Vector.<Line>();
        var springLines:Vector.<Line> = new Vector.<Line>();
        drawLines = new Vector.<Line>();
        
        var i:int;
        var j:int;
        
        for (i = 0; i < lines.length; i++) {
            lines[i].optimize();
            
            var springLine:Line = new Line(lines[i].region);
            springLines.push(springLine);
            var drawLine:Line = new Line(lines[i].region);
            drawLines.push(drawLine);
            
            var p1:Point;
            var p2:Point;
            var np:Point;
            var length:int = lines[i].length - 1;
            
            for (j = 0; j < length; j++) {
                p1 = lines[i].get(j);
                p2 = lines[i].get(j+1);
                
                np = calcPoint(p1, p2, Math.PI / 2);                
                springLine.add(np);
                drawLine.add(np);
                
                np = calcPoint(p1, p2, -Math.PI / 2);
                drawLine.add(np);
            }
            
            length = drawLine.length - 1;
            for (j = length; j >= 0; j -= 2) {
                np = drawLine.get(j);
                springLine.add(np);
            }
        }
        
        springs = new Vector.<SpringBall>();
        var s:SpringBall;
        for (i = 0; i < drawLines.length; i++) {
            var l:Line = drawLines[i];
            
            for (j = 0; j < l.length; j++) {
                s = new SpringBall(l.get(j));
                springs.push(s);                
            }        
        }
        
        this.lines = drawLines;    
        
        addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
        addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
        update();
    }

    private function calcPoint(p1:Point, p2:Point, rotateAngle:Number = Math.PI/2):Point {
        var dx:Number = p1.x - p2.x;
        var dy:Number = p1.y - p2.y;
        var centerP:Point = new Point((p1.x + p2.x) / 2, (p1.y + p2.y) / 2);
        
        var angle:Number = Math.atan2(dy, dx);
        angle += rotateAngle;
        
        centerP.x += D * Math.cos(angle);
        centerP.y += D * Math.sin(angle);
        
        return centerP;
    }
    
    override public function update():void {
        if (mouseDown) addSpring(mouseX, mouseY, turn);

        for (var i:int = 0; i < springs.length; i++) {
            var s:SpringBall = springs[i];
            s.x += Math.random() * 2 - 1;
            s.y += Math.random() * 2 - 1;
            
            s.startingX = s.initX;
            s.startingY = s.initY;
        
            s.update();
        }        
        
        updateDraw();    
    }
    
    override public function activeCount():void {
        addSpring(Math.random() * RECT_SIZE, Math.random() * RECT_SIZE, turn);
        
        updateDraw();
    }
    
    private function addSpring(x:Number, y:Number, attract:Boolean):void {
        var c:int = attract ? 1 : -1;
        
        for (var i:int = 0; i < springs.length; i++) {
            var s:SpringBall = springs[i];
            
            var dx:Number = x - s.x;
            var dy:Number = y - s.y;
            var d:Number = Math.sqrt(dx * dx + dy * dy);
            
            var f:Number = 30 / d;
            f = f > 10 ? 10 : f;
            
            s.startingX = s.x + c * dx * f;
            s.startingY = s.y + c * dy * f;
            if(f > 1 ){
                s.vx *= 1.5;
                s.vy *= 1.5;    
            }
            s.update();
        }                
    }
    
    private function onMouseDown(e:MouseEvent):void {
        mouseDown = true;    
        turn = !turn;
    }
    
    private function onMouseUp(e:MouseEvent):void {
        mouseDown = false;
    }
    
    private function updateDraw():void {
        graphics.clear();
        
        for (var i:int = 0; i < lines.length; i++) {
            var l:Line = lines[i];

            for (var j:int = 0; j < lines[i].length; j+=2) {
                if (j + 3 <= lines[i].length) {
                    graphics.beginFill(color);
                    moveTo(l.get(j));
                    lineTo(l.get(j + 1));
                    lineTo(l.get(j + 3));
                    lineTo(l.get(j + 2));
                }
            }
        }
        graphics.endFill();
    }
    
    private function moveTo(p:Point):void {
        graphics.moveTo(p.x, p.y);
    }
    
    private function lineTo(p:Point):void {
        graphics.lineTo(p.x, p.y);
    }
}

class SpringBall {
    
    private static const SPRING:Number = 0.3;
    private static const FRICTION:Number = 0.8;
    
    private var _ball:Point;
    private var _handles:Vector.<Point>;

    public var initX:Number;
    public var initY:Number;
    
    public var startingX:Number;
    public var startingY:Number;
    
    public var vx:Number = 0;
    public var vy:Number = 0;
    
    public var x:Number;
    public var y:Number;
        
    public function SpringBall(ball:Point) {
        _ball = ball;
        initX = _ball.x;
        initY = _ball.y;
        
        startingX = initX;
        startingY = initY;
        
        x = ball.x;
        y = ball.y;
    }
    
    public function get ball():Point {
        return _ball;
    }
    
    public function update():void {
        var dx:Number = startingX - x;
        var dy:Number = startingY - y;            
            
        vx += dx * SPRING;
        vy += dy * SPRING;
        
        vx *= FRICTION;
        vy *= FRICTION;
        
        _ball.x += vx;
        _ball.y += vy;
        
        x = _ball.x;
        y = _ball.y;
    }
}

/**
 * モザイクのような「あ」
 */
class Mosaic extends DisplayPanel {
    
    private var mosaics:Vector.<Vector.<MosaicCircle> >;
    private var increment:int = 1;
    private var index:int = 0;
    
    public function Mosaic(container:Stage, lines:Vector.<Line>, sound:AhSoundBase) {
        super(container, lines, sound);
        
        for (var i:int = 0; i < lines.length; i++) {
            var l:Line = lines[i];
        graphics.lineStyle(20, 0xffffff, 1, false, LineScaleMode.NORMAL, CapsStyle.SQUARE, JointStyle.BEVEL);
            graphics.moveTo(l.get(0).x, l.get(0).y);
            for (var j:int = 1; j < lines[i].length; j++) {
                graphics.lineTo(l.get(j).x, l.get(j).y);
            }
        }
        
        mosaics = new Vector.<Vector.<MosaicCircle> >();
        
        for (i = 1; i <= 64; i += i) mosaics.push(createMosaic(this, i));        
        
        graphics.clear();
    }
    
    private function createMosaic(canvas:DisplayObject, partitions:int):Vector.<MosaicCircle> {
        var points:Vector.<MosaicCircle> = new Vector.<MosaicCircle>();
        var bmd:BitmapData = new BitmapData(canvas.width, canvas.height, false, 0x00);
        bmd.draw(canvas);
        
        for (var i:int = 0; i < partitions; i++) {
            var ws:int = i * canvas.width / partitions;
            var we:int = (i + 1) * canvas.width / partitions;
            
            for (var j:int = 0; j < partitions; j++) {
                var hs:int = j * canvas.height / partitions;
                var he:int = (j + 1) * canvas.height / partitions;
                
                var count:int = 0;
                for (var width:int = ws; width < we; width++) {
                    for (var height:int = hs; height < he; height++) {
                        var color:uint = bmd.getPixel(width, height);
                        if(color >= 0xffffff) count++;
                    }
                }
                
                var total:int = (we - ws) * (he - hs);
                
                if (count / total >= 0.05) {
                    var c:MosaicCircle = new MosaicCircle((ws + we) / 2, (hs + he) / 2, (we-ws) / 2 - 1);
                    points.push(c);
                }
                
            }
        }
        
        return points;
    }
    
    public override function activeCount():void {
        graphics.clear();
        graphics.beginFill(color);

        index += increment;
        
        for (var i:int = 0; i < mosaics[index].length; i++) {
            var c:MosaicCircle = mosaics[index][i];
            graphics.drawCircle(c.x, c.y, c.radius);
        }
        
        if (index == 0 || index == mosaics.length-1) {
            increment *= -1;
        }
    }
}

class MosaicCircle {
    
    private var _x:Number;
    private var _y:Number;
    private var _radius:Number;
    
    public function MosaicCircle(x:Number, y:Number, radius:Number) {
        _x = x;
        _y = y;
        _radius = radius;
    }
    
    public function get radius():Number {return _radius;}
    public function get y():Number {return _y;}
    public function get x():Number {return _x;}
}


/*//////////////////////////////////////////////////
 * 
 * サウンドに反応した回数をカウントするクラス
 * 
/*//////////////////////////////////////////////////

/**
 * 反応した回数をカウントするパネル
 */
class ActiveCountPanel extends Sprite {
    
    private var _sound:AhSoundBase;
    
    private var _count:int = -1;
    
    private var _circles:Array /*CountCircle*/ = [];
    private var _txt:TextField;
    private var _text:String;
    
    private var _indicator:Indicator;

    private var _delay:int = 100;
    private var _delayCnt:int = 0;
    
    private var _isMic:Boolean;
    private var _initY:Number;
    
    public function ActiveCountPanel(sound:AhSoundBase, text:String = "VOICE") {
        _sound = sound;
        _text = text;
        _sound.addEventListener(AhSoundEvent.ACTIVE_COUNT, onCount);
        
        for (var i:int = 0; i < 5; i++) {
            var circle:CountCircle = new CountCircle();
            circle.x = i * (CountCircle.SIZE * 3) + CountCircle.SIZE;
            circle.y = CountCircle.SIZE / 2;
            addChild(circle);
            
            _circles[i] = circle;
        }
        
        _txt = new TextField();
        _txt.selectable = false;
        _txt.autoSize = TextFieldAutoSize.LEFT;
        _txt.defaultTextFormat = new TextFormat(DesignAh.FONT_NAME, 16, 0xffffff, true);
        _txt.mouseEnabled = false;
        _txt.x = -1;
        _txt.y = CountCircle.SIZE + 5;
        addChild(_txt);
        setText(_count);
        
        _indicator = new Indicator();
        _indicator.y = _txt.y + _txt.height + 3;
        addChild(_indicator);
        
        _isMic = sound is AhMicrophone ? true : false;
    }
    
    override public function get y():Number {
        return super.y;
    }
    
    private var first:Boolean = true;
    override public function set y(value:Number):void {
        if(first){
            _initY = value;
            first = false;
        }
        super.y = value;
    }
    
    private function setText(count:int):void {
        _txt.text = "SONG OF DESIGN AH ! \n" + _text + " : " + (count + 1) + " HITS";
    }
    
    private function onCount(e:AhSoundEvent):void {
        _count++;
        activeCircles();
        setText(_count);

        _delayCnt = getTimer();
        _indicator.active();
        
        if (_isMic) {
            Tweener.addTween(this, { y: this.y - 10, time:0.2, transition:"easeOutCubic", onComplete:function():void {
                Tweener.addTween(this, { y:_initY, time:0.4, transition:"easeOutBounce" } );
            }} );
        }
    }
    
    private function activeCircles():void {
        var l:int = _count % 6;
        if (l != _circles.length) {
            _circles[l].active();
        }else {
            for (var i:int = 0; i < _circles.length; i++ ) _circles[i].deactive();
        }            
    }
}

/**
 * ActiveCountPanelの丸
 */
class CountCircle extends Shape {
    public static const SIZE:Number = 8;
    private const ACTIVE_COLOR:uint = 0xffffff;
    private const DEACTIVE_COLOR:uint = 0x555555;
    
    public function CountCircle() {
        deactive();
    }
    
    public function active():void {
        drawCircle(ACTIVE_COLOR);
    }
    
    public function deactive():void {
        drawCircle(DEACTIVE_COLOR);
    }
    
    private function drawCircle(color:uint):void {
        graphics.clear();
        graphics.beginFill(color);
        graphics.drawCircle(0, 0, SIZE);
        graphics.endFill();
    }
}

/**
 * ActiveCountPanelの下のゲージ
 */
class Indicator extends Sprite {
    
    public static const WIDTH:Number = 5;
    public static const HEIGHT:Number = 30;
    public static const NUM:int = 10;
    
    private var _bar:Shape;
    private var _maskBar:Shape;
    private var _maskBar2:Shape;
    
    public function Indicator() {
        _bar = createBar();
        
        _maskBar = createMaskBar();
        _maskBar2 = createMaskBar();
        
        addChild(_maskBar);
        _bar.mask = _maskBar;
        
        addChild(_maskBar2);
        addChild(_bar);
    }
    
    private function createBar():Shape {
        var bar:Shape = new Shape();
        bar.graphics.beginFill(0xffffff);
        bar.graphics.drawRect(0, 0, WIDTH * NUM * 2 - WIDTH, HEIGHT);
        bar.graphics.endFill();
        bar.scaleX = 0;
        return bar;
    }
    
    private function createMaskBar():Shape {
        var maskBar:Shape = new Shape();
        maskBar.graphics.beginFill(0x555555);
        for (var i:int = 0; i < NUM; i++) {
            maskBar.graphics.drawRect(i * WIDTH * 2, 0, WIDTH, HEIGHT);
        }
        maskBar.graphics.endFill();
        return maskBar;
    }
    
    public function active():void {
        Tweener.removeTweens(_bar);
        Tweener.addTween(_bar, {scaleX:1, time:0.1,    onComplete:function():void {
                Tweener.addTween(_bar, {scaleX:0, time:0.3, transition:"easeOutCubic"} );
        }} );
    }
}

/*//////////////////////////////////////////////////
 * 
 * 文字のアニメーションクラス
 * 
/*//////////////////////////////////////////////////

/**
 * カタカタ文字を打っているようなアニメーション
 */
[Event(name = "complete", type = "flash.events.Event")]
class TypeWriterAnimation extends EventDispatcher{
    
    private static var taDic:Dictionary = new Dictionary();
    
    private var _textField:TextField;
    private var _texts:Array/*String*/;
    private var _interval:Number;
    
    private var _timer:Timer;
    
    public function TypeWriterAnimation(textField:TextField, text:String, interval:Number) {
        this._textField = textField;
        this._textField.text = "";
        
        this._texts = text.split("");
        this._interval = interval;
        
        _timer = new Timer(interval, text.length);
        _timer.addEventListener(TimerEvent.TIMER, onTick);
        _timer.addEventListener(TimerEvent.TIMER_COMPLETE, onComplete);
    }    
    
    private function onComplete(e:TimerEvent):void {
        dispatchEvent(new Event(Event.COMPLETE, false, false));
    }
    
    private function onTick(e:TimerEvent):void {
        _textField.appendText(_texts[_timer.currentCount-1]);
    }
    
    public function start():void {_timer.start();}
    
    public function stop():void {_timer.stop();}
    
    public function get running():Boolean {return _timer.running;}
    
    public static function startAnimation(textField:TextField, text:String, interval:Number, onComplete:Function = null):TypeWriterAnimation {
        if (taDic[textField]) {
            taDic[textField].stop();
        }
        
        var ta:TypeWriterAnimation = new TypeWriterAnimation(textField, text, interval);
        taDic[textField] = ta;
        ta.addEventListener(Event.COMPLETE, function(e:Event):void {
            delete taDic[textField];
            if (onComplete != null)     onComplete();
        } );
        ta.start();
        
        return ta;
    }
}

/*//////////////////////////////////////////////////
 * 
 * ボタン関係のクラス
 * 
/*//////////////////////////////////////////////////

/**
 * ボタンのベースクラス
 */
class Button extends Sprite {
    
    private var _upState:Sprite;
    private var _overState:Sprite;
    private var _downState:Sprite;
    private var _hitTestState:Sprite;
    
    public function Button() {
        buttonMode = true;
        useHandCursor = true;
        
        addEventListener(MouseEvent.MOUSE_OVER, onOver);
        addEventListener(MouseEvent.MOUSE_OUT, onOut);
        addEventListener(MouseEvent.MOUSE_UP, onUp);
        addEventListener(MouseEvent.MOUSE_DOWN, onDown);
        addEventListener(Event.ADDED, onAdded);
    }

    private function onAdded(e:Event):void {add(_upState);}
    private function onOver(e:MouseEvent):void {add(_overState);}
    private function onUp(e:MouseEvent):void {add(_upState);}
    private function onOut(e:MouseEvent):void {add(_upState);}
    private function onDown(e:MouseEvent):void {add(_downState);}
    
    private function add(state:DisplayObject):void {
        if(state) addChild(state);
        if(_hitTestState) addChild(_hitTestState);
    }    
    
    protected function get upState():Sprite {return _upState;}    
    protected function set upState(value:Sprite):void {
        add(value);        
        _upState = value;
    }
    
    protected function get overState():Sprite {return _overState;}
    protected function set overState(value:Sprite):void {
        add(value);        
        _overState = value;
    }
    
    protected function get downState():Sprite {return _downState;}
    protected function set downState(value:Sprite):void {
        add(value);                
        _downState = value;
    }
    
    protected function get hitTestState():Sprite {return _hitTestState;}
    protected function set hitTestState(value:Sprite):void {
        add(value);                
        _hitTestState = value;
        _hitTestState.alpha = 0;        
    }
}

/**
 * ナビゲーションボタン
 */
class NavigationButton extends Button {
    
    private var _text:String;
    private var _size:int;
    private var _left:Boolean;
    
    private const BUTTON_OFFSET:int = 3;
    
    private const UP_COLOR:uint = 0x888888;
    private const OVER_COLOR:uint = 0xffffff;
    
    public function NavigationButton(text:String, size:int, left:Boolean = true) {
        this._text = text;
        this._size = size;
        this._left = left;
        
        upState = createState(UP_COLOR);
        overState = createState(OVER_COLOR);
        downState = overState;
        hitTestState = createHitState();
    }
    
    private function createState(color:uint):Sprite {
        var state:Sprite = new Sprite();

        var txt:TextField = new TextField();
        txt.autoSize = TextFieldAutoSize.LEFT;
        txt.selectable = false;
        txt.defaultTextFormat = new TextFormat(DesignAh.FONT_NAME, _size, color);
        txt.text = _text;
        txt.y = -2;
        
        if (Capabilities.os.indexOf("Mac") != -1) txt.y += 4;
        
        state.addChild(txt);
        
        var mark:ButtonMark = new ButtonMark(color);
        mark.y = txt.height / 2;
        state.addChild(mark);
        
        if (_left) {
            mark.x = mark.width / 2;
            txt.x = mark.width + BUTTON_OFFSET;
        }else {
            mark.scaleX = -1;
            mark.x = txt.width + BUTTON_OFFSET + mark.width/2;
        }
        
        return state;
    }
    
    private function createHitState():Sprite {
        var state:Sprite = createState(UP_COLOR);
        var rect:Rectangle = state.getBounds(this);
        
        var hitState:Sprite = new Sprite();
        hitState.graphics.beginFill(0);
        hitState.graphics.drawRect(0, 0, rect.width, rect.height);
        hitState.graphics.endFill();
        
        return hitState;
    }
}

/**
 * ボタンの丸
 */
class ButtonMark extends Shape {
    
    public function ButtonMark(color:uint) {
        graphics.beginFill(color);
        graphics.drawCircle(0, 0, 18);
        graphics.endFill();
        
        graphics.lineStyle(3.5, 0, 1, false, LineScaleMode.NORMAL, CapsStyle.SQUARE);
        graphics.moveTo(2, -7);
        graphics.lineTo( -5, 0);
        graphics.lineTo(2, 7);
        graphics.endFill();
    }
}

/**
 * サウンドを追加するときのボタン
 */
class AddSoundButton extends Button {
    
    public function AddSoundButton(label:String, size:int) {
        upState = createState(label, 0xffffff, size, 0xffffff, 0x0);
        overState = upState;
        downState = createState(label, 0x0, size, 0x0, 0xffffff);
        hitTestState = createState(label, 0xffffff, size, 0xffffff, 0x0);
    }
    
    private function createState(label:String, textColor:uint, textSize:int, lineColor:uint, bgColor:uint):Sprite {
        var s:Sprite = new Sprite();
        var _tf:TextField = new TextField();
        _tf.selectable = false;
        _tf.autoSize = TextFieldAutoSize.LEFT;
        _tf.mouseEnabled = false;
        _tf.defaultTextFormat = new TextFormat(DesignAh.FONT_NAME, textSize, textColor);
        _tf.text = label;
        _tf.x = 4;
        _tf.y = 2;
        s.addChild(_tf);
        s.graphics.beginFill(bgColor);
        s.graphics.lineStyle(4, lineColor, 1, false, LineScaleMode.NORMAL, CapsStyle.SQUARE);
        s.graphics.drawRect(0, 0, _tf.width+8, _tf.height+4);
        s.graphics.endFill();
        
        return s;
    }
}


/*//////////////////////////////////////////////////
 * 
 * サウンド関係のクラス
 * 
/*//////////////////////////////////////////////////

/**
 * サウンド用のイベント
 */
class AhSoundEvent extends Event {
    
    public static const ACTIVE:String = "active";
    public static const ACTIVE_COUNT:String = "activeCount";
    
    public function AhSoundEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false) {
        super(type, bubbles, cancelable);
    }
}

/**
 * サウンドのベースクラス
 */
[Event(name = "active", type = "AhSoundEvent")] 
[Event(name = "activeCount", type = "AhSoundEvent")] 
[Event(name = "complete", type = "flash.events.Event")] 
class AhSoundBase extends EventDispatcher {
    
    private var _activityThreshold:Number = 25;
    
    protected var _running:Boolean = false;
    protected var _activityLevel:Number = 0;
    private var _prevActivityLevel:Number = 0;
    
    private var _delayCnt:Number = 0;
    private var _delay:Number = 100;
    
    private var _voiceName:String;
    
    public function AhSoundBase(voiceName:String = "") {
        _voiceName = voiceName;
    }
    
    protected function sampleData():void {
        _prevActivityLevel = _activityLevel;
        setActivityLevel();

        if (activityLevel > activityThreshold) {
            dispatchEvent(new AhSoundEvent(AhSoundEvent.ACTIVE));
            
            if (_activityLevel - _prevActivityLevel > _activityThreshold) {        
                dispatchEvent(new AhSoundEvent(AhSoundEvent.ACTIVE_COUNT));
            }
        }
    }    
    
    public function start():void {}
    public function stop():void { }
    
    public function get activityLevel():Number { return _activityLevel; }
    
    protected function setActivityLevel():void {}
    
    public function get activityThreshold():Number {return _activityThreshold;}
    
    public function set activityThreshold(value:Number):void {
        if (value < 0) value = 0;
        else if (value > 100) value = 100;
        
        _activityThreshold = value;
    }
    
    public function get running():Boolean {    return _running;}
    public function get voiceName():String { return _voiceName; }
    public function set voiceName(value:String):void { _voiceName = value; }
    
}

/**
 * サウンド
 */
[Event(name = "ioError", type = "flash.events.IOErrorEvent")]
[Event(name = "progress", type = "flash.events.ProgressEvent")]
class AhSound extends AhSoundBase {
    protected var _sound:Sound;
    private var _channel:SoundChannel;
    
    private var _dummy:Sprite;
    
    public function AhSound(url:String, voiceName:String) {
        super(voiceName);
        
        if(url){
            _sound = new Sound(new URLRequest(url));
            _sound.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
            _sound.addEventListener(ProgressEvent.PROGRESS, onProgress);
            _sound.addEventListener(Event.COMPLETE, onComplete);
        }
        
        _dummy = new Sprite();
    }    
    
    private function onProgress(e:ProgressEvent):void { dispatchEvent(e);}
    private function onIOError(e:IOErrorEvent):void {dispatchEvent(e);}
    private function onComplete(e:Event):void {dispatchEvent(e);}
    
    private function onUpdate(e:Event):void {
        sampleData();
        
    }
        
    override public function start():void {
        if (_running) return;
        
        _running = true;
        
        _channel = _sound.play((_channel ? _channel.position : 0));
        _channel.addEventListener(Event.SOUND_COMPLETE, onSoundComplete);
        _sound.addEventListener(SampleDataEvent.SAMPLE_DATA, sampleData);        
        _dummy.addEventListener(Event.ENTER_FRAME, onUpdate);
    }

    override public function stop():void {
        if (!_running) return;
        
        _running = false;
        
        _channel.stop();
        _channel.removeEventListener(Event.SOUND_COMPLETE, onSoundComplete);
        _sound.removeEventListener(SampleDataEvent.SAMPLE_DATA, sampleData);        
        _dummy.removeEventListener(Event.ENTER_FRAME, onUpdate);
    }
    
    override protected function setActivityLevel():void {
        _activityLevel = _channel ? Math.max(_channel.rightPeak, _channel.leftPeak) * 100 : 0;
    }
    
    
    private function onSoundComplete(e:Event):void {
        stop();
        _channel = null;
        start();
    }
        
}

/**
 * ローカルサウンド
 */
[Event(name = "cancel", type = "flash.events.Event")]
class AhSoundLocal extends AhSound {
    private var _mp3:ClientMP3Loader;
    
    public function AhSoundLocal() {
        super(null, "");
        
        _mp3 = new ClientMP3Loader();
        _mp3.addEventListener(Event.COMPLETE, onComplete);
        _mp3.addEventListener(Event.CANCEL, onCancel);
        _mp3.load();
    }
    
    private function onCancel(e:Event):void {
        dispatchEvent(e);
    }
    
    private function onComplete(e:Event):void {
        _sound = _mp3.sound;
        voiceName = _mp3.file.name.replace(".mp3", "");
        dispatchEvent(e);
    }
}


/**
 * マイク
 */
class AhMicrophone extends AhSoundBase{    
    private var _microphone:Microphone;
    
    public function AhMicrophone() {
        super("YOUR VOICE");        

        _microphone = Microphone.getMicrophone();
        _microphone.addEventListener(StatusEvent.STATUS, micStatus);
        _microphone.setSilenceLevel(0);        
        start();
        stop();
    
    }
    
    private function micStatus(e:StatusEvent):void {
        switch(e.code){
            case "Microphone.Muted" : dispatchEvent(new Event(Event.CANCEL));  break;
            case "Microphone.Unmuted" : dispatchEvent(new Event(Event.COMPLETE)); break;
        }
    }
    
    public function get microphone():Microphone {
        return _microphone;
    }
    
    public function get muted():Boolean {
        return _microphone.muted;
    }
    
    override public function start():void {
        if (_running) return;
        
        _running = true;
        _microphone.addEventListener(SampleDataEvent.SAMPLE_DATA, onSampleData);        
    }
    
    private function onSampleData(e:SampleDataEvent):void {
        sampleData();
    }
    
    override public function stop():void {
        if (!_running) return;
        
        _running = false;
        _microphone.removeEventListener(SampleDataEvent.SAMPLE_DATA, onSampleData);
    }
    
    override protected function setActivityLevel():void {
        _activityLevel = _microphone.activityLevel;        
    }    
}


/**
 * This loads MP3 from HDD.
 * 
 * @see http://wiki.github.com/claus/as3swf/play-mp3-directly-from-bytearray
 * @see http://github.com/claus/as3swf/raw/master/bin/as3swf.swc
 */
class ClientMP3Loader extends EventDispatcher {

    /**
     * Use this object after Event.COMPLETE.
     */
    public var sound:Sound;

    /**
     * Call this to load MP3 from HDD.
     */
    public function load ():void {
        file = new FileReference;
        file.addEventListener (Event.CANCEL, onUserCancelled);
        file.addEventListener (Event.SELECT, onFileSelected);
        file.addEventListener (Event.COMPLETE, onFileLoaded);
        file.browse ([ new FileFilter ("MP3 files", "*.mp3") ]);
    }

    public var file:FileReference;
    private function onUserCancelled (e:Event):void { dispatchEvent (new Event (Event.CANCEL)); }
    private function onFileSelected (e:Event):void { file.load (); }
    private function onFileLoaded (e:Event):void {
        // Wrap the MP3 with a SWF
        var swf:ByteArray = createSWFFromMP3 (file.data);
        // Load the SWF with Loader::loadBytes()
        var loader:Loader = new Loader();
        loader.contentLoaderInfo.addEventListener(Event.INIT, initHandler);
        loader.loadBytes(swf);
    }

    private function initHandler(e:Event):void {
        // Get the sound class definition
        var SoundClass:Class = LoaderInfo(e.currentTarget).applicationDomain.getDefinition("MP3Wrapper_soundClass") as Class;
        // Instantiate the sound class
        sound = new SoundClass() as Sound;
        // Report Event.COMPLETE
        dispatchEvent (new Event (Event.COMPLETE));
    }

    private function createSWFFromMP3(mp3:ByteArray):ByteArray
    {
        // Create an empty SWF
        // Defaults to v10, 550x400px, 50fps, one frame (works fine for us)
        var swf:SWF = new SWF();
        
        // Add FileAttributes tag
        // Defaults: as3 true, all other flags false (works fine for us)
        swf.tags.push(new TagFileAttributes());

        // Add SetBackgroundColor tag
        // Default: white background (works fine for us)
        swf.tags.push(new TagSetBackgroundColor());
        
        // Add DefineSceneAndFrameLabelData tag 
        // (with the only entry being "Scene 1" at offset 0)
        var defineSceneAndFrameLabelData:TagDefineSceneAndFrameLabelData = new TagDefineSceneAndFrameLabelData();
        defineSceneAndFrameLabelData.scenes.push(new SWFScene(0, "Scene 1"));
        swf.tags.push(defineSceneAndFrameLabelData);

        // Add DefineSound tag
        // The ID is 1, all other parameters are automatically
        // determined from the mp3 itself.
        swf.tags.push(TagDefineSound.createWithMP3(1, mp3));
        
        // Add DoABC tag
        // Contains the AS3 byte code for the document class and the 
        // class definition for the embedded sound
        swf.tags.push(TagDoABC.create(abc));
        
        // Add SymbolClass tag
        // Specifies the document class and binds the sound class
        // definition to the embedded sound
        var symbolClass:TagSymbolClass = new TagSymbolClass();
        symbolClass.symbols.push(SWFSymbol.create(1, "MP3Wrapper_soundClass"));
        symbolClass.symbols.push(SWFSymbol.create(0, "MP3Wrapper"));
        swf.tags.push(symbolClass);
        
        // Add ShowFrame tag
        swf.tags.push(new TagShowFrame());

        // Add End tag
        swf.tags.push(new TagEnd());
        
        // Publish the SWF
        var swfData:SWFData = new SWFData();
        swf.publish(swfData);
        
        return swfData;
    }
    
    private static var abcData:Array = [
        0x10, 0x00, 0x2e, 0x00, 0x00, 0x00, 0x00, 0x19, 0x07, 0x6d, 0x78, 0x2e, 0x63, 0x6f, 0x72, 0x65, 
        0x0a, 0x49, 0x46, 0x6c, 0x65, 0x78, 0x41, 0x73, 0x73, 0x65, 0x74, 0x0a, 0x53, 0x6f, 0x75, 0x6e, 
        0x64, 0x41, 0x73, 0x73, 0x65, 0x74, 0x0b, 0x66, 0x6c, 0x61, 0x73, 0x68, 0x2e, 0x6d, 0x65, 0x64, 
        0x69, 0x61, 0x05, 0x53, 0x6f, 0x75, 0x6e, 0x64, 0x12, 0x6d, 0x78, 0x2e, 0x63, 0x6f, 0x72, 0x65, 
        0x3a, 0x53, 0x6f, 0x75, 0x6e, 0x64, 0x41, 0x73, 0x73, 0x65, 0x74, 0x00, 0x15, 0x4d, 0x50, 0x33, 
        0x57, 0x72, 0x61, 0x70, 0x70, 0x65, 0x72, 0x5f, 0x73, 0x6f, 0x75, 0x6e, 0x64, 0x43, 0x6c, 0x61, 
        0x73, 0x73, 0x0a, 0x4d, 0x50, 0x33, 0x57, 0x72, 0x61, 0x70, 0x70, 0x65, 0x72, 0x0d, 0x66, 0x6c, 
        0x61, 0x73, 0x68, 0x2e, 0x64, 0x69, 0x73, 0x70, 0x6c, 0x61, 0x79, 0x06, 0x53, 0x70, 0x72, 0x69, 
        0x74, 0x65, 0x0a, 0x73, 0x6f, 0x75, 0x6e, 0x64, 0x43, 0x6c, 0x61, 0x73, 0x73, 0x05, 0x43, 0x6c, 
        0x61, 0x73, 0x73, 0x2a, 0x68, 0x74, 0x74, 0x70, 0x3a, 0x2f, 0x2f, 0x77, 0x77, 0x77, 0x2e, 0x61, 
        0x64, 0x6f, 0x62, 0x65, 0x2e, 0x63, 0x6f, 0x6d, 0x2f, 0x32, 0x30, 0x30, 0x36, 0x2f, 0x66, 0x6c, 
        0x65, 0x78, 0x2f, 0x6d, 0x78, 0x2f, 0x69, 0x6e, 0x74, 0x65, 0x72, 0x6e, 0x61, 0x6c, 0x07, 0x56, 
        0x45, 0x52, 0x53, 0x49, 0x4f, 0x4e, 0x06, 0x53, 0x74, 0x72, 0x69, 0x6e, 0x67, 0x07, 0x33, 0x2e, 
        0x30, 0x2e, 0x30, 0x2e, 0x30, 0x0b, 0x6d, 0x78, 0x5f, 0x69, 0x6e, 0x74, 0x65, 0x72, 0x6e, 0x61, 
        0x6c, 0x06, 0x4f, 0x62, 0x6a, 0x65, 0x63, 0x74, 0x0c, 0x66, 0x6c, 0x61, 0x73, 0x68, 0x2e, 0x65, 
        0x76, 0x65, 0x6e, 0x74, 0x73, 0x0f, 0x45, 0x76, 0x65, 0x6e, 0x74, 0x44, 0x69, 0x73, 0x70, 0x61, 
        0x74, 0x63, 0x68, 0x65, 0x72, 0x0d, 0x44, 0x69, 0x73, 0x70, 0x6c, 0x61, 0x79, 0x4f, 0x62, 0x6a, 
        0x65, 0x63, 0x74, 0x11, 0x49, 0x6e, 0x74, 0x65, 0x72, 0x61, 0x63, 0x74, 0x69, 0x76, 0x65, 0x4f, 
        0x62, 0x6a, 0x65, 0x63, 0x74, 0x16, 0x44, 0x69, 0x73, 0x70, 0x6c, 0x61, 0x79, 0x4f, 0x62, 0x6a, 
        0x65, 0x63, 0x74, 0x43, 0x6f, 0x6e, 0x74, 0x61, 0x69, 0x6e, 0x65, 0x72, 0x0a, 0x16, 0x01, 0x16, 
        0x04, 0x18, 0x06, 0x16, 0x07, 0x18, 0x08, 0x16, 0x0a, 0x18, 0x09, 0x08, 0x0e, 0x16, 0x14, 0x03, 
        0x01, 0x01, 0x01, 0x04, 0x14, 0x07, 0x01, 0x02, 0x07, 0x01, 0x03, 0x07, 0x02, 0x05, 0x09, 0x02, 
        0x01, 0x07, 0x04, 0x08, 0x07, 0x04, 0x09, 0x07, 0x06, 0x0b, 0x07, 0x04, 0x0c, 0x07, 0x04, 0x0d, 
        0x07, 0x08, 0x0f, 0x07, 0x04, 0x10, 0x07, 0x01, 0x12, 0x09, 0x03, 0x01, 0x07, 0x04, 0x13, 0x07, 
        0x09, 0x15, 0x09, 0x08, 0x02, 0x07, 0x06, 0x16, 0x07, 0x06, 0x17, 0x07, 0x06, 0x18, 0x0d, 0x00, 
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
        0x00, 0x00, 0x00, 0x00, 0x04, 0x01, 0x00, 0x05, 0x00, 0x02, 0x00, 0x02, 0x03, 0x09, 0x03, 0x01, 
        0x04, 0x05, 0x00, 0x05, 0x02, 0x09, 0x05, 0x00, 0x08, 0x00, 0x06, 0x07, 0x09, 0x07, 0x00, 0x0b, 
        0x01, 0x08, 0x00, 0x00, 0x09, 0x00, 0x01, 0x00, 0x04, 0x01, 0x0a, 0x06, 0x01, 0x0b, 0x11, 0x01, 
        0x07, 0x00, 0x0a, 0x00, 0x05, 0x00, 0x01, 0x0c, 0x06, 0x00, 0x00, 0x08, 0x08, 0x03, 0x01, 0x01, 
        0x04, 0x00, 0x00, 0x06, 0x01, 0x02, 0x04, 0x00, 0x01, 0x09, 0x01, 0x05, 0x04, 0x00, 0x02, 0x0c, 
        0x01, 0x06, 0x04, 0x01, 0x03, 0x0c, 0x00, 0x01, 0x01, 0x01, 0x02, 0x03, 0xd0, 0x30, 0x47, 0x00, 
        0x00, 0x01, 0x00, 0x01, 0x03, 0x03, 0x01, 0x47, 0x00, 0x00, 0x03, 0x02, 0x01, 0x01, 0x02, 0x0a, 
        0xd0, 0x30, 0x5d, 0x04, 0x20, 0x58, 0x00, 0x68, 0x01, 0x47, 0x00, 0x00, 0x04, 0x02, 0x01, 0x05, 
        0x06, 0x09, 0xd0, 0x30, 0x5e, 0x0a, 0x2c, 0x11, 0x68, 0x0a, 0x47, 0x00, 0x00, 0x05, 0x01, 0x01, 
        0x06, 0x07, 0x06, 0xd0, 0x30, 0xd0, 0x49, 0x00, 0x47, 0x00, 0x00, 0x06, 0x02, 0x01, 0x01, 0x05, 
        0x17, 0xd0, 0x30, 0x5d, 0x0d, 0x60, 0x0e, 0x30, 0x60, 0x0f, 0x30, 0x60, 0x03, 0x30, 0x60, 0x03, 
        0x58, 0x01, 0x1d, 0x1d, 0x1d, 0x68, 0x02, 0x47, 0x00, 0x00, 0x07, 0x01, 0x01, 0x06, 0x07, 0x03, 
        0xd0, 0x30, 0x47, 0x00, 0x00, 0x08, 0x01, 0x01, 0x07, 0x08, 0x06, 0xd0, 0x30, 0xd0, 0x49, 0x00, 
        0x47, 0x00, 0x00, 0x09, 0x02, 0x01, 0x01, 0x06, 0x1b, 0xd0, 0x30, 0x5d, 0x10, 0x60, 0x0e, 0x30, 
        0x60, 0x0f, 0x30, 0x60, 0x03, 0x30, 0x60, 0x02, 0x30, 0x60, 0x02, 0x58, 0x02, 0x1d, 0x1d, 0x1d, 
        0x1d, 0x68, 0x05, 0x47, 0x00, 0x00, 0x0a, 0x01, 0x01, 0x08, 0x09, 0x03, 0xd0, 0x30, 0x47, 0x00, 
        0x00, 0x0b, 0x02, 0x01, 0x09, 0x0a, 0x0b, 0xd0, 0x30, 0xd0, 0x60, 0x05, 0x68, 0x08, 0xd0, 0x49, 
        0x00, 0x47, 0x00, 0x00, 0x0c, 0x02, 0x01, 0x01, 0x08, 0x23, 0xd0, 0x30, 0x65, 0x00, 0x60, 0x0e, 
        0x30, 0x60, 0x0f, 0x30, 0x60, 0x11, 0x30, 0x60, 0x12, 0x30, 0x60, 0x13, 0x30, 0x60, 0x07, 0x30, 
        0x60, 0x07, 0x58, 0x03, 0x1d, 0x1d, 0x1d, 0x1d, 0x1d, 0x1d, 0x68, 0x06, 0x47, 0x00, 0x00
    ];

    private static function abcDataToByteArray():ByteArray {
        var ba:ByteArray = new ByteArray();
        for (var i:uint = 0; i < abcData.length; i++) {
            ba.writeByte(abcData[i]);
        }
        return ba;
    }
    
    private static var abc:ByteArray = abcDataToByteArray();
}
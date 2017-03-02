package  {
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.filters.BlurFilter;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import jp.progression.commands.lists.SerialList;
    import jp.progression.commands.tweens.*;
    import jp.progression.commands.Func;
    import caurina.transitions.properties.FilterShortcuts;
    import com.bit101.components.*;
    
    public class Main extends Sprite{
        private const CHR_W:int = 25;
        
        private var _chrList:Array = [];
        
        private var _bar:ProgressBar;
        private var _label:Label;
        private var _tx:InputText;
        private var _bt1:PushButton;
        private var _bt2:PushButton;
        private var _bt3:PushButton;
        private var _bt4:PushButton;
        private var _bt5:PushButton;
        private var _bt6:PushButton;
        private var _bt7:PushButton;
        private var _bt8:PushButton;
        
        private var _targetStr:String;
        
        private var _font:FontEmbed;

        public function Main() {
            graphics.beginFill(0);
            graphics.drawRect(0, 0, 465, 465);
            graphics.endFill();
            _label = new Label(this, 180, 200, "Now Loading");
            _bar = new ProgressBar(this, 180, 220);
            _bar.maximum = 100;
            _bar.addEventListener(Event.ENTER_FRAME, loading);
            //
            _font = new FontEmbed("http://www.digifie.jp/assets/KozGoH.swf", "KozGoH");
            _font.addEventListener(FontEmbed.FONT_LOADED, onFontLoaded);
            //
            FilterShortcuts.init();
        }
        
        private function loading(event:Event):void {
            _bar.value = _font.progress;
            if(_bar.value >= 100){
                _bar.removeEventListener(Event.ENTER_FRAME, loading);
                removeChild(_bar)
                removeChild(_label)
            }
        }
        
        private function onFontLoaded(e:Event):void{
            _font.removeEventListener(FontEmbed.FONT_LOADED, onFontLoaded);
            //
            _bt1 = new PushButton(this, 25, stage.stageHeight - 70, "1", startEffect);
            _bt2 = new PushButton(this, 25 + 105, stage.stageHeight - 70, "2", startEffect);
            _bt3 = new PushButton(this, 25 + 105 * 2, stage.stageHeight - 70, "3", startEffect);
            _bt4 = new PushButton(this, 25 + 105 * 3, stage.stageHeight - 70, "4", startEffect);
            _bt5 = new PushButton(this, 25, stage.stageHeight - 45, "5", startEffect);
            _bt6 = new PushButton(this, 25 + 105, stage.stageHeight - 45, "6", startEffect);
            _bt7 = new PushButton(this, 25 + 105 * 2, stage.stageHeight - 45, "7", startEffect);
            _bt8 = new PushButton(this, 25 + 105 * 3, stage.stageHeight - 45, "8", startEffect);
            //
            Style.embedFonts = false
            _tx = new InputText(this, 25, stage.stageHeight - 100, "２月１８日金曜日は第二回極道焼肉ですよー");
            _tx.maxChars = 21;
            _tx.width = 180;
            _tx.scaleX = _tx.scaleY = 1.5;
        }
        
        private function startEffect(e:MouseEvent):void{
            if(_chrList.length > 1){
                for(var i:int=0; i<_chrList.length; i++){
                    var list:SerialList = new SerialList();
                    list.addCommand(
                                    new DoTweener(_chrList[i], {alpha:0, time:.3, delay:i * .1 + 1, transition:"easeOut"}),
                                    new Func(removed, [i])
                                    )
                    list.execute();
                }
            }else{
                textEffect(e.target.label)
            }
            // Removed
            function removed(n:int):void{
                removeChild(_chrList[n])
                if(n == _chrList.length-1){
                    _chrList = [];
                    textEffect(e.target.label);
                }
            }
        }
        
        private function textEffect(effectType:String):void{
            if(_tx.text.length > 1){
                _targetStr = _tx.text;
            }
            //
            switch(effectType){
                case "1":
                    for(var i:int=0; i<_targetStr.length; i++){
                        var testText:TextPanel = new TextPanel(_targetStr.substr(i,1), CHR_W, _font);
                        testText.x = (CHR_W * .84) * i + 10;
                        testText.y = -50;
                        testText.rotationX = 120;
                        testText.rotationZ = 270;
                        testText.filters = [new BlurFilter(0, 16, 1)];
                        addChild(testText);
                        _chrList.push(testText);
                        //
                        var com:DoTweener = new DoTweener(testText, {
                                                          y:150, 
                                                          rotationX:0,
                                                          rotationZ:0,
                                                          _Blur_blurX:0, 
                                                          _Blur_blurY:0, 
                                                          time:1, 
                                                          delay:i * .1 + 1, 
                                                          transition:"easeOutBounce"
                                                          });
                        com.execute();
                    }
                    break;
                case "2":
                    for(i=0; i<_targetStr.length; i++){
                        testText = new TextPanel(_targetStr.substr(i,1), CHR_W, _font);
                        testText.scaleX = testText.scaleY = 20;
                        testText.x = -100;
                        testText.alpha = 0;
                        testText.filters = [new BlurFilter(32, 4, 2)];
                        addChild(testText);
                        _chrList.push(testText);
                        //
                        com = new DoTweener(testText, {
                                            x:(CHR_W * .84) * i + 10, 
                                            y:150,
                                            rotationX:-30,
                                            scaleX:1,
                                            scaleY:1.5,
                                            alpha:1, 
                                            _Blur_blurX:0, 
                                            _Blur_blurY:0, 
                                            time:1, 
                                            delay:i * .05 + 1, 
                                            transition:"easeInOutBack"
                                            });
                        com.execute();
                    }
                    break;
                case "3":
                    for(i=0; i<_targetStr.length; i++){
                        testText = new TextPanel(_targetStr.substr(i,1), CHR_W, _font);
                        testText.scaleX = testText.scaleY = 10;
                        testText.x = -100;
                        testText.rotationY = 180;
                        testText.alpha = 0;
                        testText.filters = [new BlurFilter(128, 0, 1)];
                        addChild(testText);
                        _chrList.push(testText);
                        //
                        com = new DoTweener(testText, {
                                            x:(CHR_W * .84) * i + 10,
                                            y:150,
                                            rotationY:0,
                                            scaleX:1,
                                            scaleY:1,
                                            alpha:1, 
                                            _Blur_blurX:0, 
                                            _Blur_blurY:0, 
                                            time:1, 
                                            delay:(_targetStr.length - i) * .1 + 1, 
                                            transition:"easeInOut"
                                            });
                        com.execute();
                    }
                    break;
                case "4":
                    for(i=0; i<_targetStr.length; i++){
                        testText = new TextPanel(_targetStr.substr(i,1), CHR_W, _font);
                        testText.x = CHR_W * _targetStr.length * .5;
                        testText.y = 150;
                        testText.alpha = 0;
                        testText.filters = [new BlurFilter(64, 0, 1)]
                        addChild(testText);
                        _chrList.push(testText);
                        //
                        var list:SerialList = new SerialList()
                        list.addCommand(
                                        new DoTweener(testText, {
                                            x:(CHR_W * .84) * i + 10, 
                                            y:100,
                                            alpha:1, 
                                            scaleX:4,
                                            scaleY:4,
                                            time:1, 
                                            delay:i * .15 + 1, 
                                            transition:"easeInOutElastic"
                                            }),
                                        new DoTweener(testText, {
                                            y:150,
                                            scaleX:1,
                                            scaleY:1,
                                            _Blur_blurX:0, 
                                            _Blur_blurY:0,
                                            time:.3, 
                                            transition:"easeInOut"
                                            })
                                        )
                        list.execute();
                    }
                    break;
                case "5":
                    for(i=0; i<_targetStr.length; i++){
                        testText = new TextPanel(_targetStr.substr(i,1), CHR_W, _font);
                        testText.x = Math.random() * CHR_W * _targetStr.length;
                        testText.y = Math.random() * 465;
                        testText.alpha = 0;
                        testText.filters = [new BlurFilter(32, 32, 1)];
                        addChild(testText);
                        _chrList.push(testText);
                        //
                        com = new DoTweener(testText, {
                                            x:(CHR_W * .84) * i + 10, 
                                            y:150, 
                                            alpha:1, 
                                            _Blur_blurX:0, 
                                            _Blur_blurY:0, 
                                            time:1, 
                                            delay:i * .05 + 1, 
                                            transition:"easeOutElastic"
                                            });
                        com.execute();
                    }
                    break;
                case "6":
                    for(i=0; i<_targetStr.length; i++){
                        testText = new TextPanel(_targetStr.substr(i,1), CHR_W, _font);
                        testText.x = (CHR_W * .84) * i + 10;
                        if(i%2 == 0){
                            testText.y = 465;
                        }else{
                            testText.y = 0;
                        }
                        testText.alpha = 0;
                        testText.filters = [new BlurFilter(32, 32, 1)];
                        addChild(testText);
                        _chrList.push(testText);
                        //
                        com = new DoTweener(testText, {
                                            x:(CHR_W * .84) * i + 10, 
                                            y:150, 
                                            alpha:1, 
                                            _Blur_blurX:0, 
                                            _Blur_blurY:0, 
                                            time:1, 
                                            delay:i * .1 + 1, 
                                            transition:"easeInOutBack"
                                            });
                        com.execute();
                    }
                    break;
                case "7":
                    for(i=0; i<_targetStr.length; i++){
                        testText = new TextPanel(_targetStr.substr(i,1), CHR_W, _font);
                        testText.x = CHR_W * _targetStr.length * .5;
                        if(i%2 == 0){
                            testText.y = 465;
                        }else{
                            testText.y = -(testText.height * 10 * .5);
                        }
                        testText.scaleX = testText.scaleY = 30;
                        testText.rotationX = Math.random() * 180|0;
                        testText.rotationY = Math.random() * 180|0;
                        testText.rotationZ = Math.random() * 180|0;
                        testText.alpha = 0;
                        testText.filters = [new BlurFilter(32, 32, 1)];
                        addChild(testText);
                        _chrList.push(testText);
                        //
                        com = new DoTweener(testText, {
                                            scaleX:1, 
                                            scaleY:1, 
                                            x:(CHR_W * .84) * i + 10, 
                                            y:150,
                                            rotationX:0,
                                            rotationY:0,
                                            rotationZ:0,
                                            alpha:1, 
                                            _Blur_blurX:0, 
                                            _Blur_blurY:0, 
                                            time:2, 
                                            delay:(_targetStr.length-i) * .1 +1, 
                                            transition:"easeInOutElastic"
                                            });
                        com.execute();
                    }
                    break;
                case "8":
                    for(i=0; i<_targetStr.length; i++){
                        testText = new TextPanel(_targetStr.substr(i,1), CHR_W, _font);
                        if(i%2 == 0){
                            testText.x = CHR_W * _targetStr.length;
                        }else{
                            testText.x = 0;
                        }
                        testText.y = 150 - testText.height * 10 * .5;
                        testText.scaleX = testText.scaleY = 20;
                        testText.alpha = 0;
                        testText.filters = [new BlurFilter(64, 64, 1)]
                        addChild(testText);
                        _chrList.push(testText);
                        //
                        com = new DoTweener(testText, {
                                            scaleX:1, 
                                            scaleY:1, 
                                            x:(CHR_W * .84) * i + 10, 
                                            y:150, 
                                            rotation:0, 
                                            alpha:1, 
                                            _Blur_blurX:0, 
                                            _Blur_blurY:0, 
                                            time:1, 
                                            delay:i * .15 + 1, 
                                            transition:"easeInOut"
                                            });
                        com.execute();
                    }
                    break;
            }

        }
        
        //
    }
    
}


import flash.display.Sprite;
import flash.display.BitmapData;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.display.Bitmap;
import flash.events.MouseEvent;
import flash.events.Event;

class TextPanel extends Sprite{
    
    public var tf:TextField = new TextField();
    public var tfmt:TextFormat = new TextFormat();
    
    public function TextPanel(chr:String, w:int, font:FontEmbed){
        
        var bmd:BitmapData = new BitmapData(w, 50, true, 0xFFFFFF);
        tf.defaultTextFormat = tfmt;
        font.embetedFont(tf, "Kozuka Gothic Pro H", w * .9, 0xEEEEEE, tfmt);
        //
        tf.text = chr;
        bmd.draw(tf);
        var bm:Bitmap = new Bitmap(bmd);
        bm.smoothing = true;
        addChild(bm);
        //
        this.addEventListener(MouseEvent.MOUSE_DOWN, onDrag);
        this.addEventListener(MouseEvent.MOUSE_UP, offDrag);
    }
    
    private function onDrag(e:MouseEvent):void{
        this.startDrag();
    }
    private function offDrag(e:MouseEvent):void{
        this.stopDrag();
    }
}


import flash.events.Event;
import flash.events.ProgressEvent;
import flash.events.EventDispatcher;
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.net.URLRequest;
import flash.net.URLLoader;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.Font;
import flash.system.LoaderContext;
import flash.system.ApplicationDomain;
import flash.system.SecurityDomain;
import flash.system.Security;

class FontEmbed extends EventDispatcher {

    private var _fontClassName:String
    private var _loader:Loader = new Loader()
    public var progress:int
    
    public static const FONT_LOADED:String = "font_loaded";
    
    public function FontEmbed(fontPath:String, fontClassName:String) {
        Security.loadPolicyFile("http://www.digifie.jp/crossdomain.xml");
        Security.allowDomain("www.digifie.jp");
        swfLoad(fontPath);
        _fontClassName = fontClassName;
    }
    
    //Load FontSwf
    private function swfLoad(fontPath:String):void{
        var context:LoaderContext = new LoaderContext(); 
        context.checkPolicyFile = true;
        context.securityDomain = SecurityDomain.currentDomain; //クロスドメイン時は有効に
        context.applicationDomain = ApplicationDomain.currentDomain;
        var req:URLRequest = new URLRequest(fontPath);
        _loader.contentLoaderInfo.addEventListener(Event.COMPLETE, swfLoadComplete);
        _loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS,onProgressListener);
        _loader.load(req, context);
    }
    
    //Progress
    private function onProgressListener(e:ProgressEvent):void {
        progress = e.bytesLoaded/e.bytesTotal*100;
    }
    
    //Load Complete
    private function swfLoadComplete(e:Event):void {
        _loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,swfLoadComplete);
        _loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS,onProgressListener);
        //
        var fontClass:Class = _loader.contentLoaderInfo.applicationDomain.getDefinition(_fontClassName) as Class; 
        //trace(fontClass)
        try{
            Font.registerFont(fontClass);
        }catch(e:Error){
            //trace(e)
        }
        dispatchEvent(new Event(FontEmbed.FONT_LOADED));
    }
    
    //Embeted Font
    public function embetedFont(txt:TextField, fontname:String, size:Number, color:int, fmt:TextFormat):void {
        var tfmt:TextFormat = fmt
        tfmt.font = fontname;
        tfmt.size = size;
        tfmt.color = color;
        txt.embedFonts = true;
        txt.defaultTextFormat = tfmt;
    }
}
package 
{
    import flash.display.Sprite;
    import flash.events.Event;
    import net.hires.debug.Stats;
    /**
     * ...
     * @author jaiko
     */
    [SWF(width = "465", height = "465", backgroundColor = "0x2F2F2F")]
    public class Main2 extends Sprite 
    {
        
        public function Main2():void 
        {
            if (stage) init();
            else addEventListener(Event.ADDED_TO_STAGE, init);
        }
        
        private function init(e:Event = null):void 
        {
            removeEventListener(Event.ADDED_TO_STAGE, init);
            // entry point
            var viewManager:ViewManager = ViewManager.getInstance();
            addChild(viewManager);
        }
    }
}
import flash.display.Loader;
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageQuality;
import flash.display.StageScaleMode;
import flash.events.Event;
/**
 * ...
 * @author jaiko
 */
class ViewManager extends Sprite
{
    private var loadFlag:Boolean = true;
    private var modelManager:ModelManager;
    private var windowList:Vector.<Window>;
    private static var _widthNumber:uint;
    private static var _heightNumber:uint;
    //
    private static var _instance:ViewManager;
    private var windowManager:WindowManager;
    private var controllBar:ControllBar;
    private var loading:RollingLoading;
    private var imageStart:uint;
    private var imageCount:uint;
    public function ViewManager(singletonBlock:SingletonBlock) 
    {
        if (stage) init();
        else addEventListener(Event.ADDED_TO_STAGE, init);
    }
    public static function getInstance():ViewManager
    {
        if (_instance == null )
        {
            _instance = new ViewManager(new SingletonBlock());
        }
        return _instance;
    }
    
    private function init(e:Event = null):void 
    {
        stage.scaleMode = StageScaleMode.NO_SCALE;
        stage.align = StageAlign.TOP_LEFT;
        stage.addEventListener(Event.RESIZE, resizeListener);
        windowManager = new WindowManager();
        addChild(windowManager);
        controllBar = ControllBar.getInstance();
        addChild(controllBar);
        modelManager = ModelManager.getInstance();
        modelManager.addEventListener(ModelEvent.IMAGE_COMPLETE, xmlCompleteListener);
        //
        loading = new RollingLoading();
        addChild(loading);
        loading.stop();
        addEventListener(WindowEvent.ADD_WINDOW, addWindowListener);
        //
        loadFlag = true;
        start();
        ControllBar.setMassage("init");
    }
    
    private function addWindowListener(event:WindowEvent):void 
    {
        modelManager.setList(_widthNumber * 1,"add");
    }
    
    private function imageCompleteListener(event:WindowEvent):void 
    {
        imageCount++;
        ControllBar.setMassage(String("loading image " + imageCount + "/" + (imageStart-1)));
        if (imageCount == imageStart)
        {
            ControllBar.setMassage("");
            loading.addEventListener(Event.ENTER_FRAME, loadingRemoveAlphaListener);
            windowManager.alpha = 0;
            removeEventListener(WindowEvent.IMAGE_COMPLETE, imageCompleteListener);
        }
    }

    private function resizeListener(event:Event):void 
    {
        controllBar.resize();
        restart();
    }
    private function restart():void
    {
        //
        windowManager.removeEventListener(Event.ENTER_FRAME, windowsAlphaListener);
        windowManager.removeAllWindow();
        windowManager.stopEnterFrame();
        
        modelManager.stop();
        start();
    }

    private function start():void
    {
        ControllBar.setMassage("loading xml");
        loading.x = stage.stageWidth * 0.5;
        loading.y = stage.stageHeight * 0.5;
        loading.start();
        loading.alpha = 1;
        //
        _widthNumber = Math.ceil(stage.stageWidth / 243);
        _heightNumber = Math.ceil(stage.stageHeight / 203);
        //
        imageStart = Math.floor(0.8 * (_widthNumber * _heightNumber));
        if (imageStart == 0)
        {
            imageStart = 1;
        }
        imageCount = 0;
        addEventListener(WindowEvent.IMAGE_COMPLETE, imageCompleteListener);
        //
        modelManager.setList(_widthNumber * _heightNumber,"init");
    }
    
    private function xmlCompleteListener(event:ModelEvent):void 
    {
        if (event.loadType == "add")
        {
            windowManager.addWindows();
        }else {
            ControllBar.setMassage("loading image");
            windowManager.setWindows();
            windowManager.alpha = 0;
        }
    }
    
    private function loadingRemoveAlphaListener(event:Event):void 
    {
        loading.alpha += (0 - loading.alpha) * 0.1;
        if (loading.alpha < 0.02) {
            loading.alpha = 0;
            loading.removeEventListener(Event.ENTER_FRAME, loadingRemoveAlphaListener);
            loading.stop();
            windowManager.startEnterFrame();
            windowManager.addEventListener(Event.ENTER_FRAME, windowsAlphaListener);
        }
    }
    
    private function windowsAlphaListener(event:Event):void 
    {
        windowManager.alpha += (1 - windowManager.alpha) * 0.1;
        if (windowManager.alpha > 0.95) {
            windowManager.alpha = 1;
            windowManager.removeEventListener(Event.ENTER_FRAME, windowsAlphaListener);
        }
    }
    static public function get widthNumber():uint 
    {
        return _widthNumber;
    }
    
    static public function get heightNumber():uint 
    {
        return _heightNumber;
    }
}

import flash.display.Sprite;
import flash.events.Event;

/**
 * ...
 * @author jaiko
 */
class WindowManager extends Sprite 
{
    private const MARGIN:Number = 4;
    private var modelManager:ModelManager;
    private var windowList:Vector.<Window>;
    private var addFlag:Boolean = true;
    public function WindowManager() 
    {
        windowList = new Vector.<Window>();
        modelManager = ModelManager.getInstance();
        //addEventListener(Event.ENTER_FRAME, upMoveListener);
    }
    
    private function upMoveListener(event:Event):void 
    {
        var i:uint;
        var n:uint;
        var window:Window;
        //
        n = windowList.length;
        for (i = 0; i < n; i++)
        {
            window = windowList[i];
            window.positionY += -1;
            window.y = window.positionY;
        }
        //
        checkPosition();
        if (window) {
            if (window.y < stage.stageHeight)
            {
                if (addFlag) {
                    addFlag = false;
                    var windowEvent:WindowEvent = new WindowEvent(WindowEvent.ADD_WINDOW, true);
                    dispatchEvent(windowEvent);
                }
            }
        }
    }
    public function startEnterFrame():void
    {
        addEventListener(Event.ENTER_FRAME, upMoveListener);
    }
    public function stopEnterFrame():void
    {
        removeEventListener(Event.ENTER_FRAME, upMoveListener);
    }
    private function checkPosition():void 
    {
        var i:uint;
        var n:uint;
        var window:Window;
        //
        n = windowList.length;
        for (i = 0; i < n; i++)
        {
            window = windowList[i];
            if (window.y < -220)
            {
                removeChild(window);
                windowList.splice(i, 1);
                window.stop();
                checkPosition();
                break;
            }
        }
    }
    public function removeAllWindow():void
    {
        var window:Window;
        var i:uint;
        var n:uint;
        //
        n = windowList.length;
        for (i = 0; i < n; i++)
        {
            window = windowList[i];
            window.stop();
            removeChild(window);
        }
        //
        windowList = new Vector.<Window>();
    }
    
    public function setWindows():void
    {
        var window:Window;
        var i:uint;
        var n:uint;
        var xmlList:Array = modelManager.xmlList;
        var _widthNumber:uint = ViewManager.widthNumber;
        var _heightNumber:uint = ViewManager.heightNumber;
        var startX:Number = (stage.stageWidth - ((Window.WIDTH+MARGIN) * _widthNumber)) * 0.5;
        var startY:Number = (stage.stageHeight - ((Window.HEIGHT+MARGIN) * _heightNumber)) * 0.5;
        windowList = new Vector.<Window>();
        n = xmlList.length;
        for (i = 0; i < n; i++)
        {
            var obj:Object = xmlList[i];
            window = new Window();
            addChild(window);
            window.init(obj);
            window.x = startX + ((Window.WIDTH+MARGIN) * (i % _widthNumber));
            window.y = startY + (Window.HEIGHT+MARGIN) * Math.floor(i / _widthNumber);
            window.positionY  = window.y;
            windowList[i] = window;
        }
        addFlag = true;
    }
    public function addWindows():void
    {
        var window:Window;
        var lastWindow:Window;
        
        var startX:Number;
        var startY:Number;
        var i:uint;
        var n:uint;
        var xmlList:Array = modelManager.xmlList;
        var _widthNumber:uint = ViewManager.widthNumber;
        var _heightNumber:uint = ViewManager.heightNumber;
        n = xmlList.length;
        if (windowList.length == 0)
        {
            setWindows();
        }else {
            lastWindow = windowList[windowList.length - 1];
            startX = (stage.stageWidth - ((Window.WIDTH+MARGIN) * _widthNumber)) * 0.5;
            startY = lastWindow.y + (Window.HEIGHT+MARGIN);
            for (i = 0; i < n; i++)
            {
                var obj:Object = xmlList[i];
                window = new Window();
                addChild(window);
                window.init(obj);
                window.x = startX + (Window.WIDTH+MARGIN) * (i % _widthNumber);
                window.y = startY + (Window.HEIGHT+MARGIN) * Math.floor(i / _widthNumber);
                window.positionY  = window.y;
                windowList.push(window);
            }
            
        }
        addFlag = true;
    }
}
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Graphics;
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.display.PixelSnapping;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.MouseEvent;
import flash.filters.BlurFilter;
import flash.net.navigateToURL;
import flash.net.URLRequest;
import flash.text.TextField;
import flash.text.TextFormat;

/**
 * ...
 * @author jaiko
 */
class Window extends Sprite 
{
    private var _alpha:Number;
    public static const WIDTH:Number = 244;
    public static const HEIGHT:Number = 2+18+180+18+2;
    private var _positionY:Number;
    private var loader:Loader;
    private var pageURL:URLRequest;
    private var body:Sprite;
    private var loading:RollingLoading;
    public function Window() 
    {
        
    }
    public function init(obj:Object):void
    {
        var g:Graphics;
        var backGround:Sprite = new Sprite();
        addChild(backGround);
        g = backGround.graphics;
        g.beginFill(0xCCCCCC);
        g.drawRect(0, 0, WIDTH, HEIGHT);
        //
        body = new Sprite();
        addChild(body);
        g = body.graphics;
        g.beginFill(0x191919);
        g.drawRect(2, 20, 240, 180);
        //
        var xml:XML = obj.xml;
        //
        var infoBar:InfoBar;
        //header
        infoBar = new InfoBar();
        addChild(infoBar);
        infoBar.x = 2;
        infoBar.y = 2;
        infoBar.init(xml);
        //
        infoBar = new InfoBar();
        addChild(infoBar);
        infoBar.x = 2;
        infoBar.y = 200;
        infoBar.init(xml, "bottom");
        loader = new Loader();
        var info:LoaderInfo = loader.contentLoaderInfo;
        info.addEventListener(Event.COMPLETE, loadCompleteListener);
        info.addEventListener(IOErrorEvent.IO_ERROR,ioErrorListener)
        var url:URLRequest = new URLRequest(xml.preview_url);
        loader.load(url);
        obj.loader = loader;
        
        loading = new RollingLoading();
        body.addChild(loading);
        loading.x = WIDTH * 0.5;
        loading.y = HEIGHT * 0.5;
        
        pageURL = new URLRequest(xml.url);
        this.addEventListener(MouseEvent.CLICK, clickListener);
    }
    
    private function clickListener(event:MouseEvent):void 
    {
        navigateToURL(pageURL, "_blank");
    }
    
    private function ioErrorListener(event:IOErrorEvent):void 
    {
        //trace("error image");
    }
    public function stop():void
    {
        try {
            loading.stop();
            body.removeChild(loading);
            loader.close();
        }catch (e:Error) {
            //trace(e)
        }
        
    }
    private function loadCompleteListener(event:Event):void 
    {
        var g:Graphics;
        var ratio:Number;
        var info:LoaderInfo = LoaderInfo(event.currentTarget);
        var loader:Loader = Loader(info.loader);
        var aspect:Number = loader.width / loader.height;
        var sp:Sprite = new Sprite();
        body.addChild(sp);
        if (aspect >= 240 / 180) {
            ratio = 240 / loader.width;
            //
            loader.width = 240;
            loader.height = loader.height * ratio;
            sp.x = 2+0;
            sp.y = 20 + (180 - loader.height) * 0.5;
        }else {
            ratio = 180 / loader.height;
            loader.height = 180;
            loader.width = loader.width * ratio;
            sp.x = 2 + (240 - loader.width) * 0.5;
            sp.y = 20;
        }
        sp.addChild(loader);
        _alpha = 0;
        sp.alpha = 0;
        sp.addEventListener(Event.ENTER_FRAME, visibleLoaderListener);
        loading.addEventListener(Event.ENTER_FRAME, loadingRemoveListener);
        var windowEvent:WindowEvent = new WindowEvent(WindowEvent.IMAGE_COMPLETE, true);
        dispatchEvent(windowEvent);
    }
    private function loadingRemoveListener(event:Event):void
    {
        loading.alpha += (0 - loading.alpha) * 0.1;
        if (loading.alpha < 0.02)
        {
            loading.alpha = 0;
            loading.stop();
            loading.removeEventListener(Event.ENTER_FRAME, loadingRemoveListener);
        }
    }
    private function visibleLoaderListener(event:Event):void 
    {
        var sp:Sprite = Sprite(event.currentTarget);
        _alpha += (1 - _alpha) * 0.1;
        sp.alpha = _alpha;
        if (_alpha > 0.97) {
            sp.alpha = 1;
            sp.removeEventListener(Event.ENTER_FRAME, visibleLoaderListener);
        }
    }
    
    public function get positionY():Number 
    {
        return _positionY;
    }
    
    public function set positionY(value:Number):void 
    {
        _positionY = value;
    }

}
import flash.events.Event;

/**
 * ...
 * @author jaiko
 */
class WindowEvent extends Event 
{
    public static const IMAGE_COMPLETE:String = "image_complete";
    public static const ADD_WINDOW:String = "add_window";
    public function WindowEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
    { 
        super(type, bubbles, cancelable);
        
    } 
    
    public override function clone():Event 
    { 
        return new WindowEvent(type, bubbles, cancelable);
    } 
    
    public override function toString():String 
    { 
        return formatToString("WindowEvent", "type", "bubbles", "cancelable", "eventPhase"); 
    }
    
}

import flash.display.Graphics;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.net.navigateToURL;
import flash.net.URLRequest;
import flash.text.TextField;
import flash.text.TextFormat;
/**
 * ...
 * @author jaiko
 */
class ControllBar extends Sprite 
{
    private var fullScreen:FullScreen;
    private var footer:Sprite;
    private var header:Sprite;
    private var clock:Clock;
    private static var _instance:ControllBar;
    private static var massage_tf:TextField;
    public function ControllBar(block:SingletonBlock) 
    {
        if (stage) init();
        else addEventListener(Event.ADDED_TO_STAGE, init);
    }
    public static function setMassage(massage:String):void
    {
        massage_tf.text = massage
    }
    public static function getInstance():ControllBar
    {
        if (_instance == null)
        {
            _instance = new ControllBar(new SingletonBlock());
        }
        return _instance;
    }
    public function resize():void
    {
        fullScreen.resize();
        setButtons();
    }
    private function init(event:Event = null):void
    {
        removeEventListener(Event.ADDED_TO_STAGE, init);
        //
        var format:TextFormat = new TextFormat();
        format.size = 10;
        format.bold = true;
        format.color =  0xFFFFFF;
        
        header = new Sprite();
        addChild(header);
        clock = new Clock();
        header.addChild(clock);
        massage_tf = new TextField();
        massage_tf.defaultTextFormat = format;
        massage_tf.selectable = false;
        massage_tf.x = 2;
        massage_tf.y = 2;
        massage_tf.width = 250;
        massage_tf.height = 18;
        header.addChild(massage_tf);
        footer = new Sprite();
        addChild(footer);
        var g:Graphics;
        var linkButton:Sprite = new Sprite();
        footer.addChild(linkButton);
        linkButton.x = 2;
        linkButton.y = 2;
        var tf:TextField = new TextField();
        tf.defaultTextFormat = format;
        tf.text = "Webcams provided by webcams.travel";
        tf.selectable = false
        tf.width = tf.textWidth +5;
        tf.height = tf.textHeight +5;
        g = linkButton.graphics;
        g.beginFill(0x000000, 0);
        g.drawRect(0, 0, tf.width, tf.height);
        linkButton.addChild(tf);
        linkButton.buttonMode = true;
        linkButton.mouseChildren = false;
        linkButton.addEventListener(MouseEvent.CLICK, linkButtonClickListener);
        fullScreen = new FullScreen();
        footer.addChild(fullScreen);
        setButtons();
    }
    
    private function linkButtonClickListener(event:MouseEvent):void 
    {
        var url:URLRequest = new URLRequest("http://www.webcams.travel/");
        navigateToURL(url);
    }

    private function setButtons():void
    {
        var g:Graphics;
        g = header.graphics;
        g.clear();
        g.beginFill(0x000000, 0.5);
        g.drawRect(0, 0, stage.stageWidth, 20);
        clock.x = stage.stageWidth - clock.width;
        footer.x = 0;
        footer.y = stage.stageHeight - 20;
        g = footer.graphics;
        g.clear();
        g.beginFill(0x000000, 0.5);
        g.drawRect(0, 0, stage.stageWidth, 20);
        //
        fullScreen.x = stage.stageWidth - fullScreen.width -2;
        fullScreen.y = 2;
    }
}
import flash.display.Sprite;
import flash.events.Event;
import flash.text.TextField;
import flash.text.TextFormat;

/**
 * ...
 * @author jaiko
 */
class Clock extends Sprite 
{
    private var tf:TextField;
    
    public function Clock() 
    {
        if (stage) init();
        else addEventListener(Event.ADDED_TO_STAGE, init);
    }
    private function init(event:Event = null):void
    {
        removeEventListener(Event.ADDED_TO_STAGE, init);
        //
        var format:TextFormat;
        var date:Date;
        var year:Number;
        var month:Number;
        var day:Number;
        var hours:Number;
        var minuites:Number;
        var seconds:Number
        //
        date = new Date();
        date.fullYear;
        date.month;
        date.date;
        date.hours;
        date.minutes;
        date.seconds;
        tf = new TextField();
        tf.y = 2;
        tf.x = 0;
        tf.selectable = false;
        addChild(tf);
        format = new TextFormat();
        format.size = 10;
        format.color = 0xDDDDDD;
        format.font = "_typewriter";
        format.bold = true;
        tf.defaultTextFormat = format;
        tf.text = setClock();
        tf.width = tf.textWidth + 10;
        tf.height = tf.textHeight +4;
        
        addEventListener(Event.ENTER_FRAME, enterFrameListener);
    }
    
    private function enterFrameListener(event:Event):void 
    {
        tf.text = setClock();
    }
    
    private static function setTimeString(time:Number):Array
    {
        var date:Date = new Date(time);
        var y:String = String(date.fullYear);
        var m:String = zeroPlus(date.month+1);
        var d:String = zeroPlus(date.date);
        var hours:String = zeroPlus(date.hours);
        var minutes:String = zeroPlus(date.minutes);
        var seconds:String = zeroPlus(date.seconds);
        //
        var _ar:Array = [y, m, d, hours, minutes, seconds];
        return _ar;
    }
    private function setClock():String
    {
        var string:String;
        var list:Array;
        var colom:String;
        var date:Date = new Date();
        var ms:Number = date.milliseconds;
        if (ms < 500)
        {
            colom = ":"
        }else {
            colom =" "
        }
        
        list = setTimeString(date.getTime());
        string = list[0] +"-" + list[1]  + "-" + list[2] +"T" + list[3] +colom + list[4] + colom +list[5]
        return string;
    }
    public static function setTime(time:Number):String
    {
        var string:String;
        var list:Array;
        list = setTimeString(time);
        //
        string = list[0] +"-" + list[1]  + "-" + list[2] +"T" + list[3] +":" + list[4] + ":" +list[5]
        //
        return string;
    }
    private static function zeroPlus(value:Number):String
    {
        var string:String;
        string = String(value + 100);
        string = string.substr(string.length - 2, 2);
        return string;
    }
}
import flash.display.Graphics;
import flash.display.Sprite;
import flash.display.StageDisplayState;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.text.TextFormat;

/**
 * ...
 * @author jaiko
 */
class FullScreen extends Sprite 
{
    private var tf:TextField;
    
    public function FullScreen() 
    {
        if (stage) init();
        else addEventListener(Event.ADDED_TO_STAGE, init);
    }
    public function resize():void
    {
        setButton();
    }
    

    private function init(e:Event = null):void 
    {
        removeEventListener(Event.ADDED_TO_STAGE, init);
        // entry point
        start()
    }
    private function start():void
    {
        tf = new TextField();
        var format:TextFormat = new TextFormat();
        format.size = 10;
        format.bold = true;
        tf.defaultTextFormat = format;
        tf.textColor = 0xFFFFFF;
        addChild(tf);
        tf.selectable = false;
        tf.x = 22;
        tf.mouseEnabled = false;
        setButton();
        buttonMode = true;
        addEventListener(MouseEvent.CLICK, clickListener);
    }
    
    private function clickListener(event:MouseEvent):void 
    {
        if (stage.displayState == StageDisplayState.FULL_SCREEN)
        {
            stage.displayState = StageDisplayState.NORMAL;
        }else {
            stage.displayState = StageDisplayState.FULL_SCREEN
        }
    }
    private function setButton():void 
    {
        var g:Graphics;
        g = this.graphics;
        g.clear();
        if (stage.displayState == StageDisplayState.FULL_SCREEN)
        {
        
            g.beginFill(0x666666);
            g.lineStyle(1, 0xCCCCCC);
            g.drawRoundRect(0, 2, 21, 14, 3,3);
            g.endFill();
            g.lineStyle();
            g.beginFill(0x999999);
            g.drawRoundRect(1, 3, 12, 9, 2, 2);
            
            tf.text = "Normal";
            tf.width = tf.textWidth+4;
            tf.height = tf.textHeight + 4;
        }else {
            g.beginFill(0x666666);
            g.lineStyle(1, 0x999999);
            g.drawRoundRect(0, 2, 21, 14, 3,3);
            g.lineStyle();
            g.beginFill(0xCCCCCC);
            g.drawRoundRect(1, 3, 12, 9, 2, 2);
            tf.text = "Full Screen";
            tf.width = tf.textWidth+4;
            tf.height = tf.textHeight + 4;
        }
    }
}
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.net.navigateToURL;
import flash.net.URLRequest;
import flash.text.TextField;
import flash.text.TextFormat;

/**
 * ...
 * @author jaiko
 */
class InfoBar extends Sprite 
{
    private var url:URLRequest;
    
    public function InfoBar() 
    {
        
    }
    
    public function init(xml:XML , type:String = null ):void
    {
        var string:String
        var format:TextFormat;
        var g:Graphics;
        //
        g = this.graphics;
        g.beginFill(0x666666);
        g.drawRect(0, 0, 240, 18);
        //
        var tfBox:Sprite = new Sprite();
        var tf:TextField = new TextField();
        tf.width = 240;
        tf.height = 18;
        tf.selectable = false;
        format = new TextFormat();
        format.size = 9;
        format.color = 0xDDDDDD;
        format.bold = true;
        tf.defaultTextFormat = format;
        if (type == "bottom"){
            string =  "photo by " + String(xml.user);
            tf.height = 17;
            url = new URLRequest(String(xml.user_url));
            this.buttonMode = true;
            addEventListener(MouseEvent.CLICK, clickListener);
        }else {
            var localDate:Date = new Date();
            var difference:Number = localDate.getTime() - (xml.last_update * 1000);
            var UTCDate:Date = new Date(localDate.getUTCFullYear(), localDate.getUTCMonth(),
            localDate.getUTCDate(),localDate.getUTCHours(),localDate.getUTCMinutes(),localDate.getUTCSeconds(),localDate.getUTCMilliseconds());
            var AwayDate:Date = new Date();
            AwayDate.setTime(UTCDate.getTime() + (xml.timezone_offset * 60 * 60 * 1000) - difference);
            var contry:String = CountryCode.getCountryName(xml.country);
            var time:String = Clock.setTime(AwayDate.getTime());
            string = contry + " / " + xml.city +"/" +time; 
        }
        
        tf.text = string;
        //
        var bmd:BitmapData = new BitmapData(tf.width, tf.height, true, 0xFFFFFF);
        bmd.draw(tf);
        var sp:Sprite = new Sprite();
        addChild(sp);
        
        var bm:Bitmap = new Bitmap(bmd, "auto", true);
        sp.addChild(bm);
    }
    
    private function clickListener(event:MouseEvent):void 
    {
        navigateToURL(url, "_blank");
    }
}


import flash.display.Graphics;
import flash.display.Sprite;
import flash.events.Event;
import flash.utils.setInterval;
import flash.utils.setTimeout;

/**
 * ...
 * @author jaiko
 */
class RollingLoading extends Sprite 
{
    private const TIME:Number = 1;
    private const RADIUS:Number = 7;
    private const WIDTH:Number =  7;
    private const HEIGHT:Number = 3;
    private const MEMBERS:Number = 12;
    private var barList:Array;
    private var id:uint;
    private var counter:uint;
    private var pre_blink:Number;
    public function RollingLoading() 
    {
        if (stage) init();
        else addEventListener(Event.ADDED_TO_STAGE, init);
    }

    private function init(e:Event = null):void 
    {
        removeEventListener(Event.ADDED_TO_STAGE, init);
        // entry point
        var i:uint;
        var n:uint;
        var bar:Sprite;
        var g:Graphics;
        var theta:Number;
        var time:Number;
        var id:uint;
        //
        barList = [];
        n = MEMBERS;
        for (i = 0; i < n; i++)
        {
            bar = new Sprite();
            g = bar.graphics;
            g.beginFill(0xAAAAAA);
            g.drawRect( 0, -0.5*HEIGHT, WIDTH, HEIGHT);
            addChild(bar);
            theta = 2 * Math.PI * (i / MEMBERS);
            
            bar.x = RADIUS * Math.cos(theta);
            bar.y = RADIUS * Math.sin(theta);
            bar.rotation = theta * 180 / Math.PI;
            bar.alpha = 0;
            
            
            barList[i] = bar;
        }
        pre_blink = 0;
        counter = 0;
        addEventListener(Event.ENTER_FRAME, enterFrameListener);
    }
    public function stop():void
    {
        removeEventListener(Event.ENTER_FRAME, enterFrameListener);
    }
    public function start():void
    {
        removeEventListener(Event.ENTER_FRAME, enterFrameListener);
        addEventListener(Event.ENTER_FRAME, enterFrameListener);
    }
    private function enterFrameListener(event:Event):void 
    {
        var i:uint;
        var n:uint;
        var bar:Sprite;
        var blink:Number = MEMBERS * (counter / (stage.frameRate * TIME)) ;
        n = barList.length;
        for (i = 0; i < n; i++)
        {
            bar = barList[i];
            if ((i==0&&counter==0) ||(blink >= i && pre_blink < i))
            {
                bar.alpha = 0.8;
            }else {
                bar.alpha += (0 - bar.alpha)*0.08;
            }
        }
        counter++;
        
        if (blink >= MEMBERS)
        {
            counter = 0;
            blink = 0;
        }
        pre_blink = blink;
    }
    private function startBlink(bar:Sprite):void
    {
        bar.alpha = 1;
        setTimeout(startBlink, TIME,bar);
    }
    private function closeCluser(bar:Sprite):void
    {
        bar.alpha = 0;
    }
}

import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.net.URLRequestMethod;
import flash.net.URLVariables;

/**
 * ...
 * @author jaiko
 */
class ModelManager extends EventDispatcher 
{
    private var _type:String;
    private static var _instance:ModelManager;
    private var _xmlList:Array;
    private var imageLoadMax:uint;
    private var partCount:uint;
    private var loader:URLLoader;
    public function ModelManager(singletonBlock:SingletonBlock) 
    {
        
    }
    public function stop():void
    {
        try {
            loader.close();
        }catch (e:Error) {
            trace("model error");
        }
    }
    public static function getInstance():ModelManager
    {
        if (!_instance)
        {
            _instance = new ModelManager(new SingletonBlock());
        }
        return _instance;
    }
    public function setList(value:uint ,type:String = null):void
    {
        _type = type;
        imageLoadMax = value;
        _xmlList = [];
        //
        loadImageURL();
    }

    private function loadImageURL():void
    {
        var partCount:uint = imageLoadMax - _xmlList.length;
        if (partCount >= 10) {
            partCount = 10;
        }
        var urlVariables:URLVariables = new URLVariables();
        urlVariables.value = partCount;
        var url:URLRequest = new URLRequest("http://mztm.heteml.jp/kawamura/act/getXML.php");
        url.method = URLRequestMethod.POST;
        url.data = urlVariables;
        loader = new URLLoader();
        loader.addEventListener(Event.COMPLETE, xmlCompleteLisetener);
        loader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorEventListener);
        loader.load(url);
    }
    
    private function ioErrorEventListener(event:IOErrorEvent):void 
    {
        ControllBar.setMassage("xml error");
    }
    
    private function xmlCompleteLisetener(event:Event):void 
    {            
        var i:uint;
        var n:uint;
        var data:XML;
        var obj:Object;
        var _xml:XML = XML(loader.data);
        n = _xml.webcams.webcam.length();
        for (i = 0; i < n; i++)
        {
            obj = new Object();
            data = _xml.webcams.webcam[i];
            obj.xml = data;
            _xmlList.push(obj);
        }
        //
        if (imageLoadMax == _xmlList.length) {
            var modelEvent:ModelEvent = new ModelEvent(ModelEvent.IMAGE_COMPLETE);
            modelEvent.loadType = _type;
            dispatchEvent(modelEvent);
        }else {
            loadImageURL();
        }
    }
    
    public function get xmlList():Array 
    {
        return _xmlList;
    }
}


/**
 * ...
 * @author jaiko
 */
class CountryCode 
{
    private static const CODE_LIST:Array = [
["AF","AFGHANISTAN"],
["AX","ÅLAND ISLANDS"],
["AL","ALBANIA"],
["DZ","ALGERIA"],
["AS","AMERICAN SAMOA"],
["AD","ANDORRA"],
["AO","ANGOLA"],
["AI","ANGUILLA"],
["AQ","ANTARCTICA"],
["AG","ANTIGUA AND BARBUDA"],
["AR","ARGENTINA"],
["AM","ARMENIA"],
["AW","ARUBA"],
["AU","AUSTRALIA"],
["AT","AUSTRIA"],
["AZ","AZERBAIJAN"],
["BS","BAHAMAS"],
["BH","BAHRAIN"],
["BD","BANGLADESH"],
["BB","BARBADOS"],
["BY","BELARUS"],
["BE","BELGIUM"],
["BZ","BELIZE"],
["BJ","BENIN"],
["BM","BERMUDA"],
["BT","BHUTAN"],
["BO","BOLIVIA"," PLURINATIONAL STATE OF"],
["BQ","BONAIRE"," SINT EUSTATIUS AND SABA"],
["BA","BOSNIA AND HERZEGOVINA"],
["BW","BOTSWANA"],
["BV","BOUVET ISLAND"],
["BR","BRAZIL"],
["IO","BRITISH INDIAN OCEAN TERRITORY"],
["BN","BRUNEI DARUSSALAM"],
["BG","BULGARIA"],
["BF","BURKINA FASO"],
["BI","BURUNDI"],
["KH","CAMBODIA"],
["CM","CAMEROON"],
["CA","CANADA"],
["CV","CAPE VERDE"],
["KY","CAYMAN ISLANDS"],
["CF","CENTRAL AFRICAN REPUBLIC"],
["TD","CHAD"],
["CL","CHILE"],
["CN","CHINA"],
["CX","CHRISTMAS ISLAND"],
["CC","COCOS (KEELING) ISLANDS"],
["CO","COLOMBIA"],
["KM","COMOROS"],
["CG","CONGO"],
["CD","CONGO"," THE DEMOCRATIC REPUBLIC OF THE"],
["CK","COOK ISLANDS"],
["CR","COSTA RICA"],
["CI","CÔTE D'IVOIRE"],
["HR","CROATIA"],
["CU","CUBA"],
["CW","CURAÇAO"],
["CY","CYPRUS"],
["CZ","CZECH REPUBLIC"],
["DK","DENMARK"],
["DJ","DJIBOUTI"],
["DM","DOMINICA"],
["DO","DOMINICAN REPUBLIC"],
["EC","ECUADOR"],
["EG","EGYPT"],
["SV","EL SALVADOR"],
["GQ","EQUATORIAL GUINEA"],
["ER","ERITREA"],
["EE","ESTONIA"],
["ET","ETHIOPIA"],
["FK","FALKLAND ISLANDS (MALVINAS)"],
["FO","FAROE ISLANDS"],
["FJ","FIJI"],
["FI","FINLAND"],
["FR","FRANCE"],
["GF","FRENCH GUIANA"],
["PF","FRENCH POLYNESIA"],
["TF","FRENCH SOUTHERN TERRITORIES"],
["GA","GABON"],
["GM","GAMBIA"],
["GE","GEORGIA"],
["DE","GERMANY"],
["GH","GHANA"],
["GI","GIBRALTAR"],
["GR","GREECE"],
["GL","GREENLAND"],
["GD","GRENADA"],
["GP","GUADELOUPE"],
["GU","GUAM"],
["GT","GUATEMALA"],
["GG","GUERNSEY"],
["GN","GUINEA"],
["GW","GUINEA-BISSAU"],
["GY","GUYANA"],
["HT","HAITI"],
["HM","HEARD ISLAND AND MCDONALD ISLANDS"],
["VA","HOLY SEE (VATICAN CITY STATE)"],
["HN","HONDURAS"],
["HK","HONG KONG"],
["HU","HUNGARY"],
["IS","ICELAND"],
["IN","INDIA"],
["ID","INDONESIA"],
["IR","IRAN"," ISLAMIC REPUBLIC OF"],
["IQ","IRAQ"],
["IE","IRELAND"],
["IM","ISLE OF MAN"],
["IL","ISRAEL"],
["IT","ITALY"],
["JM","JAMAICA"],
["JP","JAPAN"],
["JE","JERSEY"],
["JO","JORDAN"],
["KZ","KAZAKHSTAN"],
["KE","KENYA"],
["KI","KIRIBATI"],
["KP","KOREA"," DEMOCRATIC PEOPLE'S REPUBLIC OF"],
["KR","KOREA"," REPUBLIC OF"],
["KW","KUWAIT"],
["KG","KYRGYZSTAN"],
["LA","LAO PEOPLE'S DEMOCRATIC REPUBLIC"],
["LV","LATVIA"],
["LB","LEBANON"],
["LS","LESOTHO"],
["LR","LIBERIA"],
["LY","LIBYA"],
["LI","LIECHTENSTEIN"],
["LT","LITHUANIA"],
["LU","LUXEMBOURG"],
["MO","MACAO"],
["MK","MACEDONIA"," THE FORMER YUGOSLAV REPUBLIC OF"],
["MG","MADAGASCAR"],
["MW","MALAWI"],
["MY","MALAYSIA"],
["MV","MALDIVES"],
["ML","MALI"],
["MT","MALTA"],
["MH","MARSHALL ISLANDS"],
["MQ","MARTINIQUE"],
["MR","MAURITANIA"],
["MU","MAURITIUS"],
["YT","MAYOTTE"],
["MX","MEXICO"],
["FM","MICRONESIA"," FEDERATED STATES OF"],
["MD","MOLDOVA"," REPUBLIC OF"],
["MC","MONACO"],
["MN","MONGOLIA"],
["ME","MONTENEGRO"],
["MS","MONTSERRAT"],
["MA","MOROCCO"],
["MZ","MOZAMBIQUE"],
["MM","MYANMAR"],
["NA","NAMIBIA"],
["NR","NAURU"],
["NP","NEPAL"],
["NL","NETHERLANDS"],
["NC","NEW CALEDONIA"],
["NZ","NEW ZEALAND"],
["NI","NICARAGUA"],
["NE","NIGER"],
["NG","NIGERIA"],
["NU","NIUE"],
["NF","NORFOLK ISLAND"],
["MP","NORTHERN MARIANA ISLANDS"],
["NO","NORWAY"],
["OM","OMAN"],
["PK","PAKISTAN"],
["PW","PALAU"],
["PS","PALESTINIAN TERRITORY"," OCCUPIED"],
["PA","PANAMA"],
["PG","PAPUA NEW GUINEA"],
["PY","PARAGUAY"],
["PE","PERU"],
["PH","PHILIPPINES"],
["PN","PITCAIRN"],
["PL","POLAND"],
["PT","PORTUGAL"],
["PR","PUERTO RICO"],
["QA","QATAR"],
["RE","RÉUNION"],
["RO","ROMANIA"],
["RU","RUSSIAN FEDERATION"],
["RW","RWANDA"],
["BL","SAINT BARTHÉLEMY"],
["SH","SAINT HELENA"," ASCENSION AND TRISTAN DA CUNHA"],
["KN","SAINT KITTS AND NEVIS"],
["LC","SAINT LUCIA"],
["MF","SAINT MARTIN (FRENCH PART)"],
["PM","SAINT PIERRE AND MIQUELON"],
["VC","SAINT VINCENT AND THE GRENADINES"],
["WS","SAMOA"],
["SM","SAN MARINO"],
["ST","SAO TOME AND PRINCIPE"],
["SA","SAUDI ARABIA"],
["SN","SENEGAL"],
["RS","SERBIA"],
["SC","SEYCHELLES"],
["SL","SIERRA LEONE"],
["SG","SINGAPORE"],
["SX","SINT MAARTEN (DUTCH PART)"],
["SK","SLOVAKIA"],
["SI","SLOVENIA"],
["SB","SOLOMON ISLANDS"],
["SO","SOMALIA"],
["ZA","SOUTH AFRICA"],
["GS","SOUTH GEORGIA AND THE SOUTH SANDWICH ISLANDS"],
["SS","SOUTH SUDAN"],
["ES","SPAIN"],
["LK","SRI LANKA"],
["SD","SUDAN"],
["SR","SURINAME"],
["SJ","SVALBARD AND JAN MAYEN"],
["SZ","SWAZILAND"],
["SE","SWEDEN"],
["CH","SWITZERLAND"],
["SY","SYRIAN ARAB REPUBLIC"],
["TW","TAIWAN"," PROVINCE OF CHINA"],
["TJ","TAJIKISTAN"],
["TZ","TANZANIA"," UNITED REPUBLIC OF"],
["TH","THAILAND"],
["TL","TIMOR-LESTE"],
["TG","TOGO"],
["TK","TOKELAU"],
["TO","TONGA"],
["TT","TRINIDAD AND TOBAGO"],
["TN","TUNISIA"],
["TR","TURKEY"],
["TM","TURKMENISTAN"],
["TC","TURKS AND CAICOS ISLANDS"],
["TV","TUVALU"],
["UG","UGANDA"],
["UA","UKRAINE"],
["AE","UNITED ARAB EMIRATES"],
["GB","UNITED KINGDOM"],
["US","UNITED STATES"],
["UM","UNITED STATES MINOR OUTLYING ISLANDS"],
["UY","URUGUAY"],
["UZ","UZBEKISTAN"],
["VU","VANUATU"],
["VE","VENEZUELA"," BOLIVARIAN REPUBLIC OF"],
["VN","VIET NAM"],
["VG","VIRGIN ISLANDS"," BRITISH"],
["VI","VIRGIN ISLANDS"," U.S."],
["WF","WALLIS AND FUTUNA"],
["EH","WESTERN SAHARA"],
["YE","YEMEN"],
["ZM", "ZAMBIA"]
];
    public function CountryCode() 
    {
        
    }
    public static function getCountryName(code:String):String
    {
        var name:String ;
        var i:uint;
        var n:uint;
        //
        n = CODE_LIST.length;
        for (i = 0; i < n; i++) {
            if (code == CODE_LIST[i][0])
            {
                return CODE_LIST[i][1];
                break;
            }
        }
        return name;
    }
}

import flash.events.Event;

/**
 * ...
 * @author jaiko
 */
class ModelEvent extends Event 
{
    public var loadType:String;
    public static const IMAGE_COMPLETE:String = "image_complete";
    public function ModelEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
    { 
        super(type, bubbles, cancelable);
        
    } 
    
    public override function clone():Event 
    { 
        return new ModelEvent(type, bubbles, cancelable);
    } 
    
    public override function toString():String 
    { 
        return formatToString("ModelEvent", "type", "bubbles", "cancelable", "eventPhase"); 
    }
}

class SingletonBlock {
    
}


////////////////////////////////////////////////////////////////////////////////
// [AS3.0] MP3Player (2)
// http://www.project-nya.jp/modules/weblog/details.php?blog_id=1042
////////////////////////////////////////////////////////////////////////////////

package {

    import flash.display.Sprite;
    import flash.events.Event;

    [SWF(backgroundColor="#EEEEEE", width="465", height="465", frameRate="30")]

    public class Main extends Sprite {
        private static var basePath:String = "http://www.project-nya.jp/images/flash/";
        private static var filePath:String  = "mp3Player.xml";
        private var player:MP3Player;
        private var loader:TextLoader;

        public function Main() {
            //Wonderfl.capture_delay(1);
            init();
        }

        private function init():void {
            graphics.beginFill(0xEEEEEE);
            graphics.drawRect(0, 0, 465, 465);
            graphics.endFill();
            player = new MP3Player(200, 240);
            addChild(player);
            player.x = 232;
            player.y = 112;
            loader = new TextLoader();
            loader.addEventListener(TextLoader.COMPLETE, complete, false, 0, true);
            loader.load(basePath + filePath);
        }
        private function complete(evt:Event):void {
            var src:String = evt.target.data;
            player.dataProvider = parse(src);
        }
        private function parse(src:String):Array {
            var xml:XML = new XML(src);
            var list:Array = new Array();
            for (var n:uint = 0; n < xml.sound.length(); n++) {
                var sound:XML = xml.sound[n];
                var path:String = "http://www.project-nya.jp" + sound.path;
                var title:String = sound.title;
                list.push({label: title, path: path});
            }
            return list;
        }

    }

}


//////////////////////////////////////////////////
//    MP3Playerクラス
//////////////////////////////////////////////////

import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.media.Sound;
import flash.net.URLRequest;
import flash.events.ProgressEvent;
import flash.events.IOErrorEvent;
import flash.events.HTTPStatusEvent;
import flash.events.SecurityErrorEvent;
import flash.media.SoundChannel;
import flash.media.SoundTransform;
import flash.filters.DropShadowFilter;

class MP3Player extends Sprite {
    private var _width:uint;
    private var _height:uint;
    private var soundList:Array;
    private static var bColor:uint = 0xFFFFFF;
    private static var sColor:uint = 0x000000;
    private var playBtn:MP3Btn;
    private var pauseBtn:MP3Btn;
    private var loadBtn:MP3Btn;
    private var loopBtn:MP3Btn;
    private var prog:MP3ProgressBar;
    private var monitor:MP3Monitor;
    private var volume:MP3Volume;
    private var menu:MP3Menu;
    private var sound:Sound;
    private var channel:SoundChannel;
    private var soundID:uint;
    private var looping:Boolean = false;

    public function MP3Player(w:uint, h:uint) {
        _width = w;
        _height = h;
        draw();
        if (stage) init();
        else addEventListener(Event.ADDED_TO_STAGE, init, false, 0, true);
    }

    private function init(evt:Event = null):void {
        removeEventListener(Event.ADDED_TO_STAGE, init);
        playBtn = new MP3Btn(PlayIcon);
        addChild(playBtn);
        playBtn.y = 180;
        playBtn.init({width: 60});
        playBtn.visible = true;
        playBtn.enabled = false;
        pauseBtn = new MP3Btn(PauseIcon);
        pauseBtn.y = 180;
        addChild(pauseBtn);
        pauseBtn.init({width: 60});
        pauseBtn.visible = false;
        pauseBtn.clicked = false;
        loadBtn = new MP3Btn(LoadIcon);
        addChild(loadBtn);
        loadBtn.x = -60;
        loadBtn.y = 180;
        loadBtn.init({width: 20, color: 0xFFCC00});
        loadBtn.mouseEnabled = false;
        loopBtn = new MP3Btn(LoopIcon);
        addChild(loopBtn);
        loopBtn.x = 60;
        loopBtn.y = 180;
        loopBtn.init({width: 20, color: 0x00FF00});
        loopBtn.addEventListener(MouseEvent.CLICK, loop, false, 0, true);
        loadBtn.clicked = false;
        prog = new MP3ProgressBar();
        addChild(prog);
        prog.addEventListener(MP3ProgressBar.COMPLETE, complete, false, 0, true);
        prog.enabled = false;
        monitor = new MP3Monitor();
        addChild(monitor);
        monitor.y = 40;
        volume = new MP3Volume();
        addChild(volume);
        volume.x = -50;
        volume.y = 180;
        volume.init({label: "", width: 100, grid: 5, init: 50});
        volume.addEventListener(CompoEvent.CHANGE, change, false, 0, true);
        menu = new MP3Menu();
        addChild(menu);
        menu.x = -74;
        menu.y = 15;
        menu.init({label: "MP3Player", width: 149});
        menu.addEventListener(CompoEvent.SELECT, select, false, 0, true);
        menu.enabled = false;
    }
    public function set dataProvider(list:Array):void {
        soundList = list;
        menu.dataProvider = soundList;
        load(0);
    }
    private function select(evt:CompoEvent):void {
        load(evt.value);
    }
    private function load(id:uint):void {
        if (channel) pause();
        soundID = id;
        prog.init();
        removeEventListener(Event.ENTER_FRAME, status);
        prog.enabled = true;
        sound = new Sound();
        sound.addEventListener(IOErrorEvent.IO_ERROR, ioerror, false, 0, true);
        sound.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpstatus, false, 0, true);
        sound.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityerror, false, 0, true);
        sound.addEventListener(ProgressEvent.PROGRESS, progress, false, 0, true);
        var file:String = soundList[soundID].path;
        try {
            sound.load(new URLRequest(file));
        } catch (err:Error) {
            trace(err.message);
        }
        playBtn.visible = true;
        playBtn.enabled = false;
        pauseBtn.visible = false;
        pauseBtn.clicked = false;
        loadBtn.clicked = false;
        prog.enabled = false;
        monitor.clear();
        menu.enabled = false;
    }
    private function ioerror(evt:IOErrorEvent):void {
        trace(evt.text);
    }
    private function httpstatus(evt:HTTPStatusEvent):void {
        trace(evt.status);
    }
    private function securityerror(evt:SecurityErrorEvent):void {
        trace(evt.text);
    }
    private function progress(evt:ProgressEvent):void {
        prog.progress(evt.bytesLoaded, evt.bytesTotal);
    }
    private function complete(evt:Event):void {
        sound.removeEventListener(IOErrorEvent.IO_ERROR, ioerror);
        sound.removeEventListener(HTTPStatusEvent.HTTP_STATUS, httpstatus);
        sound.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityerror);
        sound.removeEventListener(ProgressEvent.PROGRESS, progress);
        prog.total = sound.length;
        prog.position = 0;
        manage(false);
        loadBtn.clicked = true;
        prog.enabled = true;
        menu.enabled = true;
        menu.initialize(soundID);
    }
    private function play(evt:MouseEvent = null):void {
        channel = sound.play(prog.position);
        channel.addEventListener(Event.SOUND_COMPLETE, soundComplete, false, 0, true);
        setVolume(volume.value/100);
        addEventListener(Event.ENTER_FRAME, status, false, 0, true);
        prog.enabled = false;
        manage(true);
    }
    private function pause(evt:MouseEvent = null):void {
        removeEventListener(Event.ENTER_FRAME, status);
        prog.enabled = true;
        channel.stop();
        prog.position = channel.position;
        monitor.clear();
        manage(false);
    }
    private function status(evt:Event):void {
        prog.position = channel.position;
        monitor.update();
    }
    private function loop(evt:MouseEvent):void {
        looping = !looping;
        loopBtn.clicked = looping;
    }
    private function soundComplete(evt:Event):void {
        channel.removeEventListener(Event.SOUND_COMPLETE, soundComplete);
        if (looping) {
            channel = sound.play(0);
            channel.addEventListener(Event.SOUND_COMPLETE, soundComplete, false, 0, true);
            setVolume(volume.value/100);
        } else {
            pause();
        }
        prog.position = 0;
    }
    private function change(evt:CompoEvent):void {
        setVolume(evt.value/100);
    }
    private function setVolume(vol:Number):void {
        var transform:SoundTransform = channel.soundTransform;
        transform.volume = vol;
        channel.soundTransform = transform;
    }
    private function manage(playing:Boolean):void {
        if (playing) {
            playBtn.removeEventListener(MouseEvent.CLICK, play);
            playBtn.visible = false;
            playBtn.enabled = false;
            pauseBtn.addEventListener(MouseEvent.CLICK, pause, false, 0, true);
            pauseBtn.visible = true;
            pauseBtn.clicked = true;
        } else {
            playBtn.addEventListener(MouseEvent.CLICK, play, false, 0, true);
            playBtn.visible = true;
            playBtn.enabled = true;
            pauseBtn.removeEventListener(MouseEvent.CLICK, pause);
            pauseBtn.visible = false;
            pauseBtn.clicked = false;
        }
    }
    private function draw():void {
        graphics.beginFill(bColor);
        graphics.drawRoundRect(-_width*0.5, 0, _width, _height, 20);
        graphics.endFill();
        var shade:DropShadowFilter = new DropShadowFilter(1, 90, sColor, 0.4, 4, 4, 2, 3, false, false);
        filters = [shade];
    }

}


//////////////////////////////////////////////////
//    MP3ProgressBarクラス
//////////////////////////////////////////////////

import flash.display.Sprite;
import flash.display.Shape;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.text.TextFieldType;
import flash.text.AntiAliasType;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flash.geom.Rectangle;
import flash.filters.DropShadowFilter;
import flash.filters.GlowFilter;

class MP3ProgressBar extends Sprite {
    private var bar:Sprite;
    private var stripe:Shape;
    private var prog:Shape;
    private var status:Shape;
    private var inner:Shape;
    private var thumb:Sprite;
    private var light:Shape;
    private var shade:Shape;
    private var base:Shape;
    private var txt:TextField;
    private static var fontType:String = "_ゴシック";
    private static var _width:uint = 160;
    private static var _height:uint = 145;
    private static var bHeight:uint = 8;
    private static var tHeight:uint = 17;
    private static var bColor:uint = 0xFFFFFF;
    private static var sColor:uint = 0x000000;
    private static var tColor:uint = 0x999999;
    private static var s1Color:uint = 0xFFFFFF;
    private static var s2Color:uint = 0xABCDFB;
    private static var cColor:uint = 0x71A8F1;
    private static var e1Color:uint = 0xFFFF00;
    private static var e2Color:uint = 0x333333;
    private static var bgColor:uint = 0x0099FF;
    private static var mColor:uint = 0xCCCCCC;
    private var barShade:DropShadowFilter;
    private var thumbShade:DropShadowFilter;
    private var blueGlow:GlowFilter;
    private var _total:Number;
    private var totalTime:String;
    private var _percent:Number = 0;
    private var targetPercent:Number;
    private var _position:Number = 0;
    private static var interval:uint = 500;
    private static var deceleration:Number = 0.4;
    public var value:Number;
    private var _enabled:Boolean = true;
    public static const COMPLETE:String = "complete";

    public function MP3ProgressBar() {
        draw();
        percent = 0;
    }

    private function draw():void {
        graphics.beginFill(mColor);
        graphics.drawRoundRect(-90, 8, 180, 124, 10);
        graphics.endFill();
        graphics.beginFill(bColor);
        graphics.drawRoundRect(-89, 9, 178, 122, 8);
        graphics.endFill();
        createChildren();
    }
    private function createChildren():void {
        barShade = new DropShadowFilter(0, 90, sColor, 0.3, 4, 4, 1.5, 2, true, false);
        thumbShade = new DropShadowFilter(1, 90, sColor, 0.5, 4, 4, 2, 3, false, false);
        blueGlow = new GlowFilter(bgColor, 0.6, 5, 5, 2, 3, false, true);
        bar = new Sprite();
        inner = new Shape();
        stripe = new Shape();
        prog = new Shape();
        status = new Shape();
        thumb = new Sprite();
        shade = new Shape();
        light = new Shape();
        base = new Shape();
        txt = new TextField();
        addChild(bar);
        bar.addChild(inner);
        bar.addChild(stripe);
        bar.addChild(prog);
        bar.addChild(status);
        addChild(thumb);
        thumb.addChild(shade);
        thumb.addChild(light);
        thumb.addChild(base);
        addChild(txt);
        bar.x = -_width*0.5;
        bar.y = _height;
        bar.filters = [barShade];
        createBase(inner, 0, 0, _width, bHeight, bColor);
        createStripe(stripe, _width, bHeight, [s1Color, s2Color]);
        createBase(prog, 0, 0, _width, bHeight, sColor);
        createBase(status, 0, 0, _width, bHeight, cColor, 0.6);
        stripe.mask = prog;
        thumb.x = -_width*0.5;
        status.scaleX = 0;
        thumb.y = _height + bHeight*0.5;
        createThumb(shade, 8, 22, 12, bColor);
        shade.filters = [thumbShade];
        createThumb(light, 8, 22, 12, bgColor);
        light.filters = [blueGlow];
        createThumb(base, 8, 22, 12, bColor);
        var tf:TextFormat = new TextFormat();
        tf.font = fontType;
        tf.size = 10;
        tf.align = TextFormatAlign.CENTER;
        txt.x = -_width*0.5;
        txt.y = 115;
        txt.width = _width;
        txt.height = tHeight;
        txt.type = TextFieldType.DYNAMIC;
        txt.selectable = false;
        //txt.embedFonts = true;
        //txt.antiAliasType = AntiAliasType.ADVANCED;
        txt.defaultTextFormat = tf;
        txt.text = "00:00 / 00:00";
        thumb.mouseChildren = false;
    }
    public function init():void {
        createStripe(stripe, _width, bHeight, [s1Color, s2Color]);
        percent = 0;
        thumb.x = -_width*0.5;
        status.scaleX = 0;
        _position = 0;
        txt.text = "00:00 / 00:00";
    }
    public function error(e:String):void {
        createStripe(stripe, _width, bHeight, [e1Color, e2Color]);
        prog.scaleX = 1;
    }
    public function progress(l:Number, t:Number):void {
        targetPercent = Math.round(l/t*100);
        addEventListener(Event.ENTER_FRAME, progressTo, false, 0, true);
    }
    private function progressTo(evt:Event):void {
        percent += (targetPercent - percent)*deceleration;
        if (Math.abs(targetPercent - percent) < 0.5) {
            percent = targetPercent;
            removeEventListener(Event.ENTER_FRAME, progressTo);
        }
        if (percent >= 100) {
            dispatchEvent(new Event(MP3ProgressBar.COMPLETE));
        }
    }
    public function get percent():Number {
        return _percent;
    }
    public function set percent(param:Number):void {
        _percent = param;
        manage(_percent);
    }
    private function manage(p:Number):void {
        prog.scaleX = p/100;
    }
    public function set total(param:Number):void {
        _total = param;
        totalTime = displayTime(_total);
    }
    public function get position():Number {
        return _position;
    }
    public function set position(p:Number):void {
        _position = p;
        var per:Number = _position/_total;
        thumb.x = -_width*0.5 + Math.round(_width*per);
        status.scaleX = per;
        txt.text = displayTime(_position) + " / " + totalTime;
    }
    private function displayTime(time:Number):String {
        var seconds:uint = Math.round(time/1000);
        var second:uint = seconds%60;
        var minute:uint = Math.floor(seconds/60);
        var minuteTime:String;
        var secondTime:String;
        if (minute < 1) {
            minuteTime = "00";
        } else if (minute < 10) {
            minuteTime = "0" + minute;
        } else {
            minuteTime = String(minute);
        }
        if (second < 1) {
            secondTime = "00";
        } else if (second < 10) {
            secondTime = "0" + second;
        } else {
            secondTime = String(second);
        }
        var tTime:String = minuteTime + ":" + secondTime;
        return tTime;
    }
    private function rollOver(evt:MouseEvent):void {
        _over();
    }
    private function rollOut(evt:MouseEvent):void {
        _up();
    }
    private function press(evt:MouseEvent):void {
        _down();
        var rect:Rectangle = new Rectangle(-_width*0.5, _height + bHeight*0.5, _width, 0);
        thumb.startDrag(false, rect);
        thumb.addEventListener(MouseEvent.MOUSE_UP, release, false, 0, true);
        stage.addEventListener(MouseEvent.MOUSE_UP, release, false, 0, true);
        stage.addEventListener(Event.MOUSE_LEAVE, leave, false, 0, true);
        thumb.addEventListener(Event.ENTER_FRAME, change, false, 0, true);
    }
    private function release(evt:MouseEvent):void {
        _up();
        thumb.stopDrag();
        checkValue();
        thumb.removeEventListener(MouseEvent.MOUSE_UP, release);
        stage.removeEventListener(MouseEvent.MOUSE_UP, release);
        stage.removeEventListener(Event.MOUSE_LEAVE, leave);
        thumb.removeEventListener(Event.ENTER_FRAME, change);
    }
    private function leave(evt:Event):void {
        _up();
        thumb.stopDrag();
        checkValue();
        thumb.removeEventListener(MouseEvent.MOUSE_UP, release);
        stage.removeEventListener(MouseEvent.MOUSE_UP, release);
        stage.removeEventListener(Event.MOUSE_LEAVE, leave);
        thumb.removeEventListener(Event.ENTER_FRAME, change);
    }
    private function _up():void {
        light.visible = false;
    }
    private function _over():void {
        light.visible = true;
    }
    private function _down():void {
        light.visible = true;
    }
    private function _off():void {
        light.visible = false;
    }
    private function change(evt:Event):void {
        _down();
        checkValue();
    }
    private function checkValue():void {
        var value:Number = (thumb.x + _width*0.5)*_total/_width;
        position = value;
    }
    public function get enabled():Boolean {
        return _enabled;
    }
    public function set enabled(param:Boolean):void {
        _enabled = param;
        if (!_enabled) _off();
        thumb.buttonMode = _enabled;
        thumb.mouseEnabled = _enabled;
        thumb.useHandCursor = _enabled;
        if (_enabled) {
            thumb.addEventListener(MouseEvent.MOUSE_OVER, rollOver, false, 0, true);
            thumb.addEventListener(MouseEvent.MOUSE_OUT, rollOut, false, 0, true);
            thumb.addEventListener(MouseEvent.MOUSE_DOWN, press, false, 0, true);
            thumb.addEventListener(MouseEvent.MOUSE_UP, release, false, 0, true);
        } else {
            thumb.removeEventListener(MouseEvent.MOUSE_OVER, rollOver);
            thumb.removeEventListener(MouseEvent.MOUSE_OUT, rollOut);
            thumb.removeEventListener(MouseEvent.MOUSE_DOWN, press);
            thumb.removeEventListener(MouseEvent.MOUSE_UP, release);
        }
    }
    private function createThumb(target:Shape, w:uint, h:uint, y:uint, color:uint, alpha:Number = 1):void {
        target.graphics.beginFill(color, alpha);
        target.graphics.drawRoundRect(-w*0.5, -y, w, h, w);
        target.graphics.endFill();
    }
    private function createBase(target:Shape, x:int, y:int, w:uint, h:uint, color:uint, alpha:Number = 1):void {
        target.graphics.beginFill(color, alpha);
        target.graphics.drawRect(x, y, w, h);
        target.graphics.endFill();
    }
    private function createStripe(target:Shape, w:uint, h:uint, colors:Array):void {
        target.graphics.clear();
        for (var n:uint = 0; n <= Math.ceil(w/h); n++) {
            target.graphics.beginFill(colors[n%2]);
            target.graphics.moveTo(h*(n-1), 0);
            target.graphics.lineTo(h*n, h);
            target.graphics.lineTo(h*(n+1), h);
            target.graphics.lineTo(h*n, 0);
            target.graphics.lineTo(h*(n-1), 0);
            target.graphics.endFill();
        }
    }

}


//////////////////////////////////////////////////
//    MP3Monitorクラス
//////////////////////////////////////////////////

import flash.display.Sprite;
import flash.display.Shape;
import flash.media.SoundMixer;
import flash.utils.ByteArray;
import flash.filters.DropShadowFilter;
import frocessing.color.ColorHSV;

class MP3Monitor extends Sprite {
    private var spectrum:Shape;
    private var byteArray:ByteArray;
    private static var channels:uint = 256;
    private static var bColor:uint = 0xFFFFFF;
    private static var cColor:uint = 0xF6F6F6;
    private static var sColor:uint = 0x000000;
    //private static var pColor:uint = 0x00A8FF;
    private var color:ColorHSV;
    private static var _width:uint = 160;
    private static var _height:uint = 70;
    private static var pHeight:uint = 48;

    public function MP3Monitor() {
        byteArray = new ByteArray();
        color = new ColorHSV(0, 0.8);
        draw();
    }

    public function update():void {
        try {
            SoundMixer.computeSpectrum(byteArray, true, 8);
        } catch (err:Error) {
            trace(err.message);
        }
        spectrum.graphics.clear();
        //spectrum.graphics.beginFill(pColor);
        var p:Number = 0;
        for (var n:uint = 0; n < channels; n++) {
            color.h = 180 + 40*n/channels;
            spectrum.graphics.beginFill(color.value);
            p = Math.round(byteArray.readFloat()*pHeight);
            spectrum.graphics.drawRect(n, -p, 1, p);
        }
        spectrum.graphics.endFill()
    }
    public function clear():void {
        spectrum.graphics.clear();
    }
    private function draw():void {
        graphics.beginFill(cColor);
        graphics.drawRect(-_width*0.5, 0, _width, _height);
        graphics.endFill();
        spectrum = new Shape();
        addChild(spectrum);
        spectrum.x = -_width*0.5;
        spectrum.y = _height;
        spectrum.scaleX = _width/channels;
        var frame:Shape = new Shape();
        addChild(frame);
        frame.graphics.beginFill(bColor);
        frame.graphics.drawRect(-_width*0.5, 0, _width, _height);
        frame.graphics.endFill();
        var shade:DropShadowFilter = new DropShadowFilter(0, 90, sColor, 0.3, 4, 4, 1.5, 2, true, true);
        frame.filters = [shade];
    }

}


//////////////////////////////////////////////////
// MP3Volumeクラス
//////////////////////////////////////////////////

import flash.display.Sprite;
import flash.display.Shape;
import flash.text.TextField;
import flash.text.TextFieldType;
import flash.text.AntiAliasType;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flash.filters.DropShadowFilter;
import flash.filters.GlowFilter;
import flash.geom.Rectangle;
import flash.geom.Matrix;
import flash.display.GradientType;
import flash.display.SpreadMethod;
import flash.display.InterpolationMethod;
import flash.events.Event;
import flash.events.MouseEvent;

class MP3Volume extends Sprite {
    private var hole:Shape;
    private var line:Sprite;
    private var thumb:Sprite;
    private var light:Shape;
    private var shade:Shape;
    private var base:Shape;
    private var txt:TextField;
    private static var fontType:String = "_ゴシック";
    private var _width:uint = 100;
    private static var tHeight:uint = 20;
    private static var bHeight:uint = 30;
    private var grid:uint = 5;
    private var off:SoundIcon;
    private var on:SoundIcon;
    private static var bColor:uint = 0xFFFFFF;
    private static var tColor:uint = 0x666666;
    private static var gColor:uint = 0x999999;
    private static var mColor:uint = 0x333333;
    private static var bgColor:uint = 0x0099FF;
    private static var sColor:uint = 0x000000;
    private static var offColor:uint = 0x999999;
    private var min:Number = 0;
    private var max:Number = 100;
    private var initValue:Number = 0;
    private var blueGlow:GlowFilter;
    private var shadeDrop:DropShadowFilter;
    public var value:Number;
    private var _enabled:Boolean = true;

    public function MP3Volume() {
    }

    public function init(option:Object):void {
        if (option.width != undefined) _width = option.width;
        if (option.min != undefined) min = option.min;
        if (option.max != undefined) max = option.max;
        if (option.grid != undefined) grid = option.grid;
        if (option.init != undefined) initValue = option.init;
        draw();
    }
    private function draw():void {
        shadeDrop = new DropShadowFilter(1, 90, sColor, 0.5, 4, 4, 2, 3, false, false);
        blueGlow = new GlowFilter(bgColor, 0.6, 5, 5, 2, 3, false, true);
        hole = new Shape();
        line = new Sprite();
        txt = new TextField();
        thumb = new Sprite();
        shade = new Shape();
        light = new Shape();
        base = new Shape();
        off = new SoundIcon(false);
        on = new SoundIcon(true);
        addChild(hole);
        addChild(line);
        addChild(txt);
        addChild(thumb);
        thumb.addChild(shade);
        thumb.addChild(light);
        thumb.addChild(base);
        addChild(off);
        addChild(on);
        hole.y = bHeight;
        createGradientHole(hole, _width, 3);
        line.y = bHeight;
        createGrid(line);
        txt.x = 25;
        txt.y = 40;
        txt.width = 50;
        txt.height = tHeight-1;
        txt.selectable = false;
        //txt.embedFonts = true;
        //txt.antiAliasType = AntiAliasType.ADVANCED;
        var tfc:TextFormat = new TextFormat();
        tfc.font = fontType;
        tfc.size = 12;
        tfc.align = TextFormatAlign.CENTER;
        txt.defaultTextFormat = tfc;
        reset();
        thumb.y = bHeight;
        createThumb(shade, 8, 20, 12, sColor);
        shade.filters = [shadeDrop];
        createThumb(light, 8, 20, 12, bgColor);
        light.filters = [blueGlow];
        createThumb(base, 8, 20, 12, bColor);
        off.x = -15;
        off.y = 30;
        on.x = 120;
        on.y = 30;
        _up();
        enabled = true;
        thumb.mouseChildren = false;
    }
    private function rollOver(evt:MouseEvent):void {
        _over();
    }
    private function rollOut(evt:MouseEvent):void {
        _up();
    }
    private function press(evt:MouseEvent):void {
        _down();
        var rect:Rectangle = new Rectangle(0, bHeight, _width, 0);
        thumb.startDrag(false, rect);
        thumb.addEventListener(MouseEvent.MOUSE_UP, release, false, 0, true);
        stage.addEventListener(MouseEvent.MOUSE_UP, release, false, 0, true);
        thumb.addEventListener(Event.ENTER_FRAME, change, false, 0, true);
    }
    private function release(evt:MouseEvent):void {
        _up();
        thumb.stopDrag();
        checkValue();
        dispatchEvent(new CompoEvent(CompoEvent.SELECT, value));
        thumb.removeEventListener(MouseEvent.MOUSE_UP, release);
        stage.removeEventListener(MouseEvent.MOUSE_UP, release);
        thumb.removeEventListener(Event.ENTER_FRAME, change);
    }
    private function _up():void {
        light.visible = false;
    }
    private function _over():void {
        light.visible = true;
    }
    private function _down():void {
        light.visible = true;
    }
    private function _off():void {
        light.visible = false;
        txt.textColor = offColor;
    }
    private function change(evt:Event):void {
        _down();
        checkValue();
        dispatchEvent(new CompoEvent(CompoEvent.CHANGE, value));
    }
    private function checkValue():void {
        value = min + Math.round(thumb.x/_width*(max-min));
        txt.text = String(value);
    }
    public function get enabled():Boolean {
        return _enabled;
    }
    public function set enabled(param:Boolean):void {
        _enabled = param;
        if (!_enabled) _off();
        thumb.buttonMode = _enabled;
        thumb.mouseEnabled = _enabled;
        thumb.useHandCursor = _enabled;
        if (_enabled) {
            thumb.addEventListener(MouseEvent.MOUSE_OVER, rollOver, false, 0, true);
            thumb.addEventListener(MouseEvent.MOUSE_OUT, rollOut, false, 0, true);
            thumb.addEventListener(MouseEvent.MOUSE_DOWN, press, false, 0, true);
            thumb.addEventListener(MouseEvent.MOUSE_UP, release, false, 0, true);
        } else {
            thumb.removeEventListener(MouseEvent.MOUSE_OVER, rollOver);
            thumb.removeEventListener(MouseEvent.MOUSE_OUT, rollOut);
            thumb.removeEventListener(MouseEvent.MOUSE_DOWN, press);
            thumb.removeEventListener(MouseEvent.MOUSE_UP, release);
        }
    }
    public function reset():void {
        thumb.x = _width*(initValue-min)/(max-min);
        value = initValue;
        txt.text = String(value);
    }
    private function createGrid(target:Sprite):void {
        for (var n:uint = 0; n <= grid; n++) {
            var w:uint = Math.floor(_width/grid);
            if (n == 0 || n == grid*0.5 || n == grid) {
                createGridLine(target, w*n, mColor);
                var _txt:TextField = new TextField();
                target.addChild(_txt);
                _txt.x = w*n - 20;
                _txt.y = 13;
                _txt.width = 40;
                _txt.height = 14;
                _txt.selectable = false;
                //_txt.embedFonts = true;
                //_txt.antiAliasType = AntiAliasType.ADVANCED;
                _txt.textColor = mColor;
                var tfc:TextFormat = new TextFormat();
                tfc.font = fontType;
                tfc.size = 9;
                tfc.align = TextFormatAlign.CENTER;
                _txt.defaultTextFormat = tfc;
                if (n == 0) _txt.text = String(min);
                if (n == grid*0.5) _txt.text = String(min+(max-min)*0.5);
                if (n == grid) _txt.text = String(max);
            } else {
                createGridLine(target, w*n, gColor);
            }
        }
    }
    private function createThumb(target:Shape, w:uint, h:uint, y:uint, color:uint, alpha:Number = 1):void {
        target.graphics.beginFill(color, alpha);
        target.graphics.drawRoundRect(-w*0.5, -y, w, h, w);
        target.graphics.endFill();
    }
    private function createGradientHole(target:Shape, w:uint, c:Number):void {
        var colors:Array = [0x000000, 0x000000];
        var alphas:Array = [0.4, 0];
        var ratios:Array = [0, 255];
        var matrix:Matrix = new Matrix();
        matrix.createGradientBox(w+c*2, c*2, 0.5*Math.PI, -c, -c);
        target.graphics.beginGradientFill(GradientType.LINEAR, colors, alphas, ratios, matrix, SpreadMethod.PAD, InterpolationMethod.RGB, 0);
        target.graphics.drawRoundRect(-c, -c, w+c*2, c*2, c*2);
        target.graphics.endFill();
    }
    private function createGridLine(target:Sprite, x:uint, color:uint):void {
        target.graphics.lineStyle(0, color);
        target.graphics.moveTo(x, 8);
        target.graphics.lineTo(x, 12);
    }

}


//////////////////////////////////////////////////
// MP3Menuクラス
//////////////////////////////////////////////////

import flash.display.Sprite;
import flash.display.Shape;
import flash.text.TextField;
import flash.text.TextFieldType;
import flash.text.AntiAliasType;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flash.events.MouseEvent;
import flash.geom.ColorTransform;

class MP3Menu extends Sprite {
    public var id:uint;
    private var tab:Sprite;
    private var base:Shape;
    private var txt:TextField;
    private var label:String = "";
    private static var fontType:String = "_ゴシック";
    private var _width:uint = 60;
    private static var _height:uint = 20;
    private static var tHeight:uint = 20;
    private static var bColor:uint = 0xFFFFFF;
    private static var cColor:uint = 0x3165B5;
    private static var upColor:uint = 0x000000;
    private static var overColor:uint = 0xFFFFFF;
    private static var offColor:uint = 0x999999;
    private static var bColorTrans:ColorTransform;
    private static var cColorTrans:ColorTransform;
    private var child:MP3MenuChild;
    private var dataList:Array;
    private var _enabled:Boolean = true;
    private var _selected:Boolean = false;

    public function MP3Menu() {
    }

    public function init(option:Object):void {
        if (option.id != undefined) id = option.id;
        if (option.label != undefined) label = option.label;
        if (option.width != undefined) _width = option.width;
        draw();
    }
    private function draw():void {
        bColorTrans = new ColorTransform();
        bColorTrans.color = bColor;
        cColorTrans = new ColorTransform();
        cColorTrans.color = cColor;
        tab = new Sprite();
        base = new Shape();
        txt = new TextField();
        addChild(tab);
        tab.addChild(base);
        tab.addChild(txt);
        createBox(base, _width, _height);
        txt.y = 1;
        txt.width = _width;
        txt.height = _height - 1;
        txt.type = TextFieldType.DYNAMIC;
        txt.selectable = false;
        //txt.embedFonts = true;
        //txt.antiAliasType = AntiAliasType.ADVANCED;
        var tf:TextFormat = new TextFormat();
        tf.font = fontType;
        tf.size = 12;
        tf.align = TextFormatAlign.CENTER;
        txt.defaultTextFormat = tf;
        txt.text = label;
        _up();
        enabled = true;
        tab.mouseChildren = false;
    }
    private function rollOver(evt:MouseEvent):void {
        _over();
    }
    private function rollOut(evt:MouseEvent):void {
        up();
    }
    private function press(evt:MouseEvent):void {
        _over();
    }
    private function release(evt:MouseEvent):void {
        _over();
    }
    private function click(evt:MouseEvent):void {
        _over();
        child.opencloseMenu();
    }
    private function up():void {
        if (_selected) {
            _over();
        } else {
            _up();
        }
    }
    private function _up():void {
        txt.textColor = upColor;
        base.transform.colorTransform = bColorTrans;
    }
    private function _over():void {
        txt.textColor = overColor;
        base.transform.colorTransform = cColorTrans;
    }
    private function _off():void {
        txt.textColor = offColor;
        base.transform.colorTransform = bColorTrans;
    }
    public function set dataProvider(list:Array):void {
        dataList = list;
        if (dataList.length > 0) addChildren();
    }
    private function addChildren():void {
        child = new MP3MenuChild(dataList, this);
        addChild(child);
        child.y = tHeight;
        child.visible = false;
        child.addEventListener(MouseEvent.CLICK, select, false, 0, true);
    }
    private function mouseDown(evt:MouseEvent):void {
        if (!hitTestPoint(stage.mouseX, stage.mouseY, true)) {
            child.closeMenu();
        }
    }
    public function initialize(param:uint):void {
        var selectedID:uint = param;
        txt.text = dataList[selectedID].label;
        child.selectItem(selectedID);
    }
    private function select(evt:MouseEvent):void {
        var selectedID:uint = evt.target.id;
        txt.text = dataList[selectedID].label;
        var e:CompoEvent = new CompoEvent(CompoEvent.SELECT, selectedID);
        dispatchEvent(e);
    }
    public function get selected():Boolean {
        return _selected;
    }
    public function set selected(param:Boolean):void {
        _selected = param;
        if (_enabled) up();
    }
    public function get enabled():Boolean {
        return _enabled;
    }
    public function set enabled(param:Boolean):void {
        _enabled = param;
        tab.buttonMode = _enabled;
        tab.mouseEnabled = _enabled;
        tab.useHandCursor = _enabled;
        if (_enabled) {
            _up();
            tab.addEventListener(MouseEvent.MOUSE_OVER, rollOver, false, 0, true);
            tab.addEventListener(MouseEvent.MOUSE_OUT, rollOut, false, 0, true);
            tab.addEventListener(MouseEvent.MOUSE_DOWN, press, false, 0, true);
            tab.addEventListener(MouseEvent.MOUSE_UP, release, false, 0, true);
            tab.addEventListener(MouseEvent.CLICK, click, false, 0, true);
            stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown, false, 0, true);
        } else {
        _off();
            tab.removeEventListener(MouseEvent.MOUSE_OVER, rollOver);
            tab.removeEventListener(MouseEvent.MOUSE_OUT, rollOut);
            tab.removeEventListener(MouseEvent.MOUSE_DOWN, press);
            tab.removeEventListener(MouseEvent.MOUSE_UP, release);
            tab.removeEventListener(MouseEvent.CLICK, click);
            stage.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
        }
    }
    private function createBox(target:Shape, w:uint, h:uint):void {
        target.graphics.clear();
        target.graphics.beginFill(bColor);
        target.graphics.drawRect(0, 0, w, h);
        target.graphics.endFill();
    }

}

import flash.display.Sprite;
import flash.display.Shape;
import flash.events.MouseEvent;
import flash.filters.DropShadowFilter;

class MP3MenuChild extends Sprite {
    private var _width:uint = 100;
    private var _height:uint;
    private static var tHeight:uint = 20;
    private static var bColor:uint = 0xFFFFFF;
    private static var sColor:uint = 0x000000;
    private var dataList:Array;
    private var max:uint;
    private var itemList:Array;
    private var maxWidth:uint = 0;
    private var back:Shape;
    private var shade:DropShadowFilter;
    private var menu:MP3Menu;
    private var opened:Boolean = false;
    private var selectedID:uint;

    public function MP3MenuChild(list:Array, m:MP3Menu) {
        dataList = list;
        max = dataList.length;
        _height = tHeight*max;
        menu = m;
        init();
    }

    private function init():void {
        back = new Shape();
        addChild(back);
        shade = new DropShadowFilter(1, 90, sColor, 0.5, 4, 4, 2, 3, false, false);
        back.filters = [shade];
        itemList = new Array();
        for (var n:uint = 0; n < max; n++) {
            var item:MP3MenuItem = new MP3MenuItem({id: n, label: dataList[n].label});
            addChild(item);
            item.y = tHeight*n;
            itemList.push(item);
            item.addEventListener(MouseEvent.CLICK, select, false, 0, true);
            resizeWidth(item);
        }
    }
    private function select(evt:MouseEvent):void {
        closeMenu();
        selectedID = MP3MenuItem(evt.currentTarget).id;
        checkItem();
    }
    public function selectItem(id:uint):void {
        selectedID = id;
        checkItem();
    }
    public function opencloseMenu():void {
        if (!opened) {
            openMenu();
        } else {
            closeMenu();
        }
    }
    private function openMenu():void {
        opened = true;
        visible = true;
        menu.selected = true;
    }
    public function closeMenu():void {
        opened = false;
        visible = false;
        menu.selected = false;
    }
    private function checkItem():void {
        for (var n:uint = 0; n < itemList.length; n++) {
            var item:MP3MenuItem = itemList[n];
            if (n == selectedID) {
                item.selected = true;
            } else {
                item.selected = false;
            }
        }
    }
    private function resizeWidth(item:MP3MenuItem):void {
        if (item._width > maxWidth) maxWidth = item._width;
        if (itemList.length >= max) resize();
    }
    private function resize():void {
        _width = maxWidth + 20;
        createBox(back, _width, _height);
        for (var n:uint = 0; n < max; n++) {
            var item:MP3MenuItem = itemList[n];
            item._width = maxWidth + 20;
            item.txt.width = item._width - 40;
            createBox(item.base, item._width, item._height);
        }
    }
    private function createBox(target:Shape, w:uint, h:uint):void {
        target.graphics.clear();
        target.graphics.beginFill(bColor);
        target.graphics.drawRect(0, 0, w, h);
        target.graphics.endFill();
    }

}

import flash.display.Sprite;
import flash.display.Shape;
import flash.text.TextField;
import flash.text.TextFieldType;
import flash.text.AntiAliasType;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flash.events.MouseEvent;
import flash.geom.ColorTransform;

class MP3MenuItem extends Sprite {
    public var id:uint;
    private var item:Sprite;
    public var base:Shape;
    public var txt:TextField;
    private var check:TextField;
    public var _width:uint = 100;
    public var _height:uint = 20;
    private var label:String = "";
    private static var fontType:String = "_ゴシック";
    private var mark:String = String.fromCharCode(10003);
    private static var checkType:String = "ゴシック";
    private static var bColor:uint = 0xFFFFFF;
    private static var cColor:uint = 0x3165B5;
    private static var upColor:uint = 0x000000;
    private static var overColor:uint = 0xFFFFFF;
    private static var bColorTrans:ColorTransform;
    private static var cColorTrans:ColorTransform;
    private var _selected:Boolean = false;

    public function MP3MenuItem(option:Object) {
        if (option.id != undefined) id = option.id;
        if (option.label) label = option.label;
        init();
    }

    private function init():void {
        bColorTrans = new ColorTransform();
        bColorTrans.color = bColor;
        cColorTrans = new ColorTransform();
        cColorTrans.color = cColor;
        item = new Sprite();
        base = new Shape();
        txt = new TextField();
        check = new TextField();
        addChild(item);
        item.addChild(base);
        item.addChild(txt);
        item.addChild(check);
        txt.x = 20;
        txt.y = 1;
        txt.width = _width;
        txt.height = _height - 1;
        txt.type = TextFieldType.DYNAMIC;
        txt.selectable = false;
        //txt.embedFonts = true;
        //txt.antiAliasType = AntiAliasType.ADVANCED;
        var tf:TextFormat = new TextFormat();
        tf.font = fontType;
        tf.size = 12;
        tf.align = TextFormatAlign.CENTER;
        txt.defaultTextFormat = tf;
        txt.text = label;
        _width = txt.textWidth + 35;
        check.x = 3;
        check.y = -1;
        check.width = 14;
        check.height = 22;
        check.type = TextFieldType.DYNAMIC;
        check.selectable = false;
        //check.embedFonts = true;
        //check.antiAliasType = AntiAliasType.ADVANCED;
        var tfc:TextFormat = new TextFormat();
        tfc.font = checkType;
        tfc.size = 12;
        tfc.align = TextFormatAlign.CENTER;
        check.defaultTextFormat = tfc;
        check.text = mark;
        check.visible = false;
        buttonMode = true;
        mouseEnabled = true;
        useHandCursor = true;
        _up();
        mouseChildren = false;
        addEventListener(MouseEvent.MOUSE_OVER, rollOver, false, 0, true);
        addEventListener(MouseEvent.MOUSE_OUT, rollOut, false, 0, true);
        addEventListener(MouseEvent.MOUSE_DOWN, press, false, 0, true);
        addEventListener(MouseEvent.MOUSE_UP, release, false, 0, true);
        addEventListener(MouseEvent.CLICK, click, false, 0, true);
    }
    private function rollOver(evt:MouseEvent):void {
        _over();
    }
    private function rollOut(evt:MouseEvent):void {
        _up();
    }
    private function press(evt:MouseEvent):void {
        _over();
    }
    private function release(evt:MouseEvent):void {
        _up();
    }
    private function click(evt:MouseEvent):void {
        _up();
    }
    private function _up():void {
        txt.textColor = upColor;
        check.textColor = upColor;
        base.transform.colorTransform = bColorTrans;
    }
    private function _over():void {
        txt.textColor = overColor;
        check.textColor = overColor;
        base.transform.colorTransform = cColorTrans;
    }
    public function get selected():Boolean {
        return _selected;
    }
    public function set selected(param:Boolean):void {
        _selected = param;
        check.visible = _selected;
    }

}


//////////////////////////////////////////////////
// MP3Btnクラス
//////////////////////////////////////////////////

import flash.display.Sprite;
import flash.display.Shape;
import flash.filters.GlowFilter;
import flash.events.MouseEvent;
import flash.geom.ColorTransform;

class MP3Btn extends Sprite {
    public var id:uint;
    private var shade:Shape;
    private var bottom:Shape;
    private var light:Shape;
    private var base:Shape;
    private var icon:Shape;
    private var _width:uint = 60;
    private static var _height:uint = 20;
    private static var corner:uint = 5;
    private var type:uint = 1;
    private static var bColor:uint = 0xFFFFFF;
    private static var sColor:uint = 0x000000;
    private static var upColor:uint = 0x666666;
    private static var overColor:uint = 0x333333;
    private static var offColor:uint = 0x999999;
    private static var upColorTrans:ColorTransform;
    private static var overColorTrans:ColorTransform;
    private static var offColorTrans:ColorTransform;
    private var cColor:uint = 0x0099FF;
    private var colorGlow:GlowFilter;
    private var shadeGlow:GlowFilter;
    private var _clicked:Boolean = false;
    private var _enabled:Boolean = true;

    public function MP3Btn(Icon:Class) {
        icon = new Icon();
    }

    public function init(option:Object):void {
        if (option.id != undefined) id = option.id;
        if (option.width != undefined) _width = option.width;
        if (option.type != undefined) type = option.type;
        if (option.color != undefined) cColor = option.color;
        draw();
    }
    private function draw():void {
        switch (type) {
        case 1 :
            bColor = 0xFFFFFF;
            sColor = 0x000000;
            upColor = 0x666666;
            overColor = 0x333333;
            offColor = 0x999999;
            break;
        case 2 :
            bColor = 0x000000;
            sColor = 0xFFFFFF;
            upColor = 0x666666;
            overColor = 0x999999;
            offColor = 0x333333;
            break;
        }
        colorGlow = new GlowFilter(cColor, 0.6, 5, 5, 2, 3, false, true);
        shadeGlow = new GlowFilter(sColor, 0.3, 4, 4, 2, 3, false, true);
        upColorTrans = new ColorTransform();
        upColorTrans.color = upColor;
        overColorTrans = new ColorTransform();
        overColorTrans.color = overColor;
        offColorTrans = new ColorTransform();
        offColorTrans.color = offColor;
        shade = new Shape();
        bottom = new Shape();
        light = new Shape();
        base = new Shape();
        addChild(shade);
        addChild(bottom);
        addChild(light);
        addChild(base);
        addChild(icon);
        createBase(shade, _width, _height, corner, sColor);
        shade.filters = [shadeGlow];
        createBase(bottom, _width, _height, corner, sColor, 0.3);
        createBase(light, _width, _height, corner, cColor);
        light.filters = [colorGlow];
        createBase(base, _width, _height, corner, bColor);
        icon.y = -1;
        enabled = true;
        mouseChildren = false;
    }
    private function rollOver(evt:MouseEvent):void {
        _over();
    }
    private function rollOut(evt:MouseEvent):void {
        _up();
    }
    private function press(evt:MouseEvent):void {
        _down();
    }
    private function release(evt:MouseEvent):void {
        _up();
    }
    private function click(evt:MouseEvent):void {
    }
    private function _up():void {
        icon.y = -1;
        icon.transform.colorTransform = upColorTrans;
        base.y = -1;
        light.visible = false;
        light.y = -1;
    }
    private function _over():void {
        icon.y = -1;
        icon.transform.colorTransform = overColorTrans;
        base.y = -1;
        light.visible = true;
        light.y = -1;
    }
    private function _down():void {
        icon.y = 0;
        icon.transform.colorTransform = overColorTrans;
        base.y = 0;
        light.visible = true;
        light.y = 0;
    }
    private function _off():void {
        icon.y = 0;
        icon.transform.colorTransform = offColorTrans;
        base.y = 0;
        light.visible = false;
        light.y = 0;
    }
    public function get clicked():Boolean {
        return _clicked;
    }
    public function set clicked(param:Boolean):void {
        _clicked = param;
        if (_clicked) {
            _down();
            removeEventListener(MouseEvent.MOUSE_OVER, rollOver);
            removeEventListener(MouseEvent.MOUSE_OUT, rollOut);
            removeEventListener(MouseEvent.MOUSE_DOWN, press);
            removeEventListener(MouseEvent.MOUSE_UP, release);
        } else {
            _up();
            addEventListener(MouseEvent.MOUSE_OVER, rollOver, false, 0, true);
            addEventListener(MouseEvent.MOUSE_OUT, rollOut, false, 0, true);
            addEventListener(MouseEvent.MOUSE_DOWN, press, false, 0, true);
            addEventListener(MouseEvent.MOUSE_UP, release, false, 0, true);
        }
    }
    public function get enabled():Boolean {
        return _enabled;
    }
    public function set enabled(param:Boolean):void {
        _enabled = param;
        buttonMode = _enabled;
        mouseEnabled = _enabled;
        useHandCursor = _enabled;
        if (_enabled) {
            _up();
            addEventListener(MouseEvent.MOUSE_OVER, rollOver, false, 0, true);
            addEventListener(MouseEvent.MOUSE_OUT, rollOut, false, 0, true);
            addEventListener(MouseEvent.MOUSE_DOWN, press, false, 0, true);
            addEventListener(MouseEvent.MOUSE_UP, release, false, 0, true);
            addEventListener(MouseEvent.CLICK, click, false, 0, true);
        } else {
            _off();
            removeEventListener(MouseEvent.MOUSE_OVER, rollOver);
            removeEventListener(MouseEvent.MOUSE_OUT, rollOut);
            removeEventListener(MouseEvent.MOUSE_DOWN, press);
            removeEventListener(MouseEvent.MOUSE_UP, release);
            removeEventListener(MouseEvent.CLICK, click);
        }
    }
    private function createBase(target:Shape, w:uint, h:uint, c:uint, color:uint, alpha:Number = 1):void {
        target.graphics.beginFill(color, alpha);
        target.graphics.drawRoundRect(-w*0.5, -h*0.5, w, h, c*2);
        target.graphics.endFill();
    }

}


//////////////////////////////////////////////////
// Iconクラス
//////////////////////////////////////////////////

import flash.display.Shape;
//import sketchbook.graphics.GraphicsHelper;

class PlayIcon extends Shape {
    private static var bColor:uint = 0x000000;

    public function PlayIcon() {
        draw();
    }

    private function draw():void {
        graphics.beginFill(bColor);
        graphics.moveTo(-4, -6);
        graphics.lineTo(-4, 6);
        graphics.lineTo(8, 0);
        graphics.endFill();
    }

}

class PauseIcon extends Shape {
    private static var bColor:uint = 0x000000;

    public function PauseIcon() {
        draw();
    }

    private function draw():void {
        graphics.beginFill(bColor);
        graphics.drawRect(-5, -5, 4, 10);
        graphics.endFill();
        graphics.beginFill(bColor);
        graphics.drawRect(3, -5, 4, 10);
        graphics.endFill();
    }

}

class LoadIcon extends Shape {
    private static var bColor:uint = 0x000000;
    //private var helper:GraphicsHelper;
    private var ring:Ring;

    public function LoadIcon() {
        draw();
    }

    private function draw():void {
        graphics.beginFill(bColor);
        graphics.drawRect(-1, -7, 2, 7);
        graphics.endFill();
        /*
        helper = new GraphicsHelper(graphics);
        helper.beginFill(bColor);
        helper.drawRing(0, 0, 6, 4, 300, -60);
        helper.endFill();
        */
        ring = new Ring(graphics);
        ring.draw(bColor, 0, 0, 6, 4, 300, -60);
    }

}

class LoopIcon extends Shape {
    private static var bColor:uint = 0x000000;
    //private var helper:GraphicsHelper;
    private var ring:Ring;

    public function LoopIcon() {
        draw();
    }

    private function draw():void {
        graphics.beginFill(bColor);
        graphics.moveTo(-2, -7);
        graphics.lineTo(-2, -1);
        graphics.lineTo(1, -4);
        graphics.endFill();
        graphics.beginFill(bColor);
        graphics.moveTo(2, 7);
        graphics.lineTo(2, 1);
        graphics.lineTo(-1, 4);
        graphics.endFill();
        /*
        helper = new GraphicsHelper(graphics);
        helper.beginFill(bColor);
        helper.drawRing(-2, 0, 5, 3, 180, 90);
        helper.endFill();
        helper.beginFill(bColor);
        helper.drawRing(2, 0, 5, 3, 180, -90);
        helper.endFill();
        */
        ring = new Ring(graphics);
        ring.draw(bColor, -2, 0, 5, 3, 180, 90);
        ring.draw(bColor, 2, 0, 5, 3, 180, -90);
    }

}

class SoundIcon extends Shape {
    private var type:Boolean;
    private static var bColor:uint = 0x000000;
    //private var helper:GraphicsHelper;
    private var ring:Ring;

    public function SoundIcon(t:Boolean) {
        type = t;
        draw();
    }

    private function draw():void {
        graphics.beginFill(bColor);
        graphics.moveTo(-9, -3);
        graphics.lineTo(-6, -3);
        graphics.lineTo(-2, -6);
        graphics.lineTo(-2, 6);
        graphics.lineTo(-6, 3);
        graphics.lineTo(-9, 3);
        graphics.endFill();
        if (type) drawLine();
    }
    private function drawLine():void {
        /*
        helper = new GraphicsHelper(graphics);
        helper.beginFill(bColor);
        helper.drawRing(-8, 0, 10, 9, 50, -25);
        helper.endFill();
        helper.beginFill(bColor);
        helper.drawRing(-8, 0, 12.5, 11.5, 50, -25);
        helper.endFill();
        helper.beginFill(bColor);
        helper.drawRing(-8, 0, 15, 14, 50, -25);
        helper.endFill();
        */
        ring = new Ring(graphics);
        ring.draw(bColor, -8, 0, 10, 9, 50, -25);
        ring.draw(bColor, -8, 0, 12.5, 11.5, 50, -25);
        ring.draw(bColor, -8, 0, 15, 14, 50, -25);
    }

}

import flash.display.Graphics;
import flash.geom.Point;

class Ring {
    private var target:Graphics;

    public function Ring(g:Graphics) {
        target = g;
    }

    public function draw(color:uint, x:Number, y:Number, outerRadius:Number, innerRadius:Number, degree:Number=360, fromDegree:Number=0, split:Number=36):void {
        var points:Array = getRingPoints(x, y, outerRadius, innerRadius, degree, fromDegree, split);
        target.beginFill(color);
        drawLines(points, true);
        target.endFill();
    }
    private function drawLines(points:Array, close:Boolean=false):void {
        var max:Number = points.length;
        target.moveTo(points[0].x, points[0].y);
        for (var n:uint = 1; n < max; n++) {
            target.lineTo(points[n].x, points[n].y);
        }
        if (close) target.lineTo(points[0].x, points[0].y);
    }
    private function getRingPoints(x:Number, y:Number, outerRadius:Number, innerRadius:Number, degree:Number=360, fromDegree:Number=0, split:Number=36):Array {
        var fromRad:Number = fromDegree * Math.PI/180;
        var dr:Number = (degree* Math.PI/180)/split;
        var pt:Point;
        var max:int = split +1;
        var rad:Number;
        var points:Array = new Array();
        for (var n:uint = 0; n < max; n++) {
            pt = new Point();
            rad = fromRad + dr*n;
            pt.x = Math.cos(rad)*outerRadius + x;
            pt.y = Math.sin(rad)*outerRadius + y;
            points.push(pt);
        }
        var points2:Array = new Array();
        for (n = 0; n < max; n++) {
            pt = new Point();
            rad = fromRad + dr*n;
            pt.x = Math.cos(rad)*innerRadius + x;
            pt.y = Math.sin(rad)*innerRadius + y;
            points2.push(pt);
        }
        points2.reverse();
        points = points.concat(points2);
        return points;
    }

}


//////////////////////////////////////////////////
// CompoEventクラス
//////////////////////////////////////////////////

import flash.events.Event;

class CompoEvent extends Event {
    public static const SELECT:String = "select";
    public static const CHANGE:String = "change";
    public var value:*;

    public function CompoEvent(type:String, value:*) {
        super(type);
        this.value = value;
    }

    public override function clone():Event {
        return new CompoEvent(type, value);
    }

}


//////////////////////////////////////////////////
//    TextLoaderクラス
//////////////////////////////////////////////////

import flash.events.EventDispatcher;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.HTTPStatusEvent;
import flash.events.SecurityErrorEvent;

class TextLoader extends EventDispatcher {
    private var loader:URLLoader;
    private var _data:*;
    public static const TEXT:String = URLLoaderDataFormat.TEXT;
    public static const BINARY:String = URLLoaderDataFormat.BINARY;
    public static const COMPLETE:String = Event.COMPLETE;

    public function TextLoader() {
        loader = new URLLoader();
    }

    public function load(file:String, format:String = TextLoader.TEXT):void {
        loader.dataFormat = format;
        loader.addEventListener(IOErrorEvent.IO_ERROR, ioerror, false, 0, true);
        loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpstatus, false, 0, true);
        loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityerror, false, 0, true);
        loader.addEventListener(Event.COMPLETE, complete, false, 0, true);
        try {
            loader.load(new URLRequest(file));
        } catch (err:Error) {
            trace(err.message);
        }
    }
    private function ioerror(evt:IOErrorEvent):void {
        trace(evt.text);
    }
    private function httpstatus(evt:HTTPStatusEvent):void {
        trace(evt.status);
    }
    private function securityerror(evt:SecurityErrorEvent):void {
        trace(evt.text);
    }
    private function complete(evt:Event):void {
        loader.removeEventListener(IOErrorEvent.IO_ERROR, ioerror);
        loader.removeEventListener(HTTPStatusEvent.HTTP_STATUS, httpstatus);
        loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityerror);
        loader.removeEventListener(Event.COMPLETE, complete);
        _data = evt.target.data;
        dispatchEvent(new Event(TextLoader.COMPLETE));
    }
    public function get data():* {
        return _data;
    }

}

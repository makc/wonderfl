// forked from Quasimondo's Math Music Incubator
// forked from Quasimondo's forked from: Math Music
// forked from Saqoosha's Math Music
package {
    import flash.desktop.ClipboardFormats;
    import flash.desktop.Clipboard;
    import com.bit101.components.Component;
    import com.bit101.components.PushButton;
    import com.bit101.components.HSlider;
    import com.bit101.components.VBox;
    import com.bit101.components.TextArea;
    import flash.media.Sound;
    import flash.media.SoundChannel;
    import flash.display.*;
    import flash.events.*;
    import flash.utils.*;
    import flash.net.*;
    import flash.system.*;

    [SWF(backgroundColor="0x000000", frameRate="30", width="475", height="475")]
    public class MathMusicIncubator extends Sprite {
        private var _sound:Sound;
        private var _channel:SoundChannel;
        private var _t:Number = -1;
        private var _type:int = -1;
        private var _image:BitmapData;
        private var _px:int = 0;
        private var _py:int = 0;
        private var _control:Component;
        private var _formula:TextArea, _output:TextArea;
        public static var audioGen:Function = function(t:Number):Number { return 0; }
        
        public function MathMusicIncubator() {
            //loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onUncaughtError);
            _image = new BitmapData(256, 256, false, 0x0);
            var b:Bitmap = addChild(new Bitmap(_image)) as Bitmap;
            b.width = b.height = 475;
            var vbox:VBox = new VBox(this, 5, 5);
            _formula = new TextArea( vbox );
            _formula.textField.addEventListener(Event.CHANGE, _onChange);
            var _copy_btn:PushButton = new PushButton( vbox, 3,3,"Copy to Clipboard",_copyToClipboard );
            _output = new TextArea( vbox );
            _control = vbox;
            _control.scaleX = _control.scaleY = 2;
            var vb2:VBox = new VBox(this, 415, 5);
            function handler(i:int):Function { return function(e:*):void { _formula.text = presets[i]; _onChange(null) }; }
            for(var i:int=0; i<presets.length; i++) (new PushButton(vb2, 0, 0, String(i), handler(i))).setSize(50, 20);
            _sound = new Sound();
            _sound.addEventListener(SampleDataEvent.SAMPLE_DATA, _onSampleData);
            stage.addEventListener(MouseEvent.MOUSE_MOVE, function(e:*):void { _control.visible = vb2.visible = true; });
            stage.addEventListener(Event.MOUSE_LEAVE, function(e:*):void { _control.visible = vb2.visible = false; });
            loadLas3rSwf(initCompiler);
        }
        
        private function _copyToClipboard( event:Event ):void {
            Clipboard.generalClipboard.setData( ClipboardFormats.TEXT_FORMAT, _formula.text);
        }

        private function _play():void {
            _t = 0;
            _px = 0;
            _py = 0;
            _image.fillRect(_image.rect, 0x0);
            if (_channel) _channel.stop();
            _channel = _sound.play();
        }
        
        private function _onSampleData(e:SampleDataEvent):void {
            var i:int, t:Number, tt:int, val:Number;
            _image.lock();
            for (i = 0; i < 8192; i++, _t++) {
                t = (_t / 44100);
                try { val = audioGen(t); } catch(e:*) { _output.text = String(e); if (_channel) _channel.stop(); break; };
                tt = val * 0x7f + 0x80;
                e.data.writeFloat(val);
                e.data.writeFloat(val);
                _image.setPixel(_px, _py, tt << 16 | tt << 8 | tt);
                if (++_px == _image.width) {
                    _px = 0;
                    if (++_py == _image.height) {
                        _py = 0;
                    }
                }
            }
            _image.unlock();
        }

        private function _onChange(e:Event):void {
            if (_channel) _channel.stop();
            repl.rt.evalStr(_formula.text,
                function(fn:*):void { audioGen = fn; _output.text = ""; _play(); },
                null,
                function(v:*):void { _output.text = String(v); });
            _t = 0;
        }

        private function loadLas3rSwf(completeHandler:Function):void {
            Security.loadPolicyFile("http://zozuar.org/wonderfl/crossdomain.xml");
            var loader:Loader;
            var req:URLRequest = new URLRequest("http://zozuar.org/wonderfl/las3r.swf");
            var ctx:LoaderContext = new LoaderContext(true, ApplicationDomain.currentDomain, SecurityDomain.currentDomain);
            loader = new Loader();
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler);
            loader.load(req, ctx);
        }

        private var repl:*;
        private function initCompiler(e:* = null):void {
            _output.text = "ready.";
            var replClass:Class = getDefinitionByName("com.las3r.repl.Repl") as Class;
            repl = new replClass(265, 265, stage);
            repl.visible = false;
            repl.rt.evalStr(prelude, ready);
        }

        private function ready(_:*):void {
            _formula.text = presets[0];
            _onChange(null);
            _play();
        }

        // from http://wonderfl.net/c/hOvH
        private function onUncaughtError(event:UncaughtErrorEvent):void {
            var message:String;
            if (event.error is Error)
                message = Error(event.error).getStackTrace();
            else if (event.error is ErrorEvent)
                message = ErrorEvent(event.error).text;
            else
                message = event.error.toString();
            _output.text = message;
            event.preventDefault(); // ココ重要！
        }

        private var prelude:String = 
        "(def << bit-shl)" +
        "(def >> bit-sar)" +
        "(def >>> bit-shr)" +
        "(def abs (. Math abs))" +
        "(def ceil (. Math ceil))" +
        "(def cos (. Math cos))" +
        "(def exp (. Math exp))" +
        "(def floor (. Math floor))" +
        "(def log (. Math log))" +
        "(def pow (. Math pow))" +
        "(def random (. Math random))" +
        "(def round (. Math round))" +
        "(def sin (. Math sin))" +
        "(def sqrt (. Math sqrt))" +
        "(def tan (. Math tan))";

        private var presets:Array = [
            "(fn [t] (sin (* 6.28 440 t)))",
            "(fn [t] (* t (sin (* 6.28 440 (* t t)))))",
            "(fn [t]\n  (let [n (* 6.28 440 t)]\n    (pow n (sin n))))",
        ]
    }
}

package {

    import com.bit101.components.Component;
    import com.bit101.components.PushButton;
    import com.bit101.components.VBox;

    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.events.SampleDataEvent;
    import flash.media.Sound;
    import flash.media.SoundChannel;


    /**
     * This is just AS3 ported version of following video
     * "Experimental music from very short C programs"
     * http://www.youtube.com/watch?v=GtQdIYUtAHg
     * and Kyle's visualization.
     * http://www.flickr.com/photos/kylemcdonald/6187863454/in/photostream/
     */
    [SWF(backgroundColor="0x000000", frameRate="30", width="465", height="465")]
    public class MathMusic extends Sprite {
        
        
        private static const FORMULAS:Array = [
            't * ((t >> 12 | t >> 8) & 63 & t >> 4)',
            '(t * (t >> 5 | t >> 8)) >> (t >> 16)',
            't * ((t >> 9 | t >> 13) & 25 & t >> 6)',
            't * (t >> 11 & t >> 9 & 123 & t >> 3)',
            '(t * (t >> 8 * (t >> 15 | t >> 8) & (20 | (t >> 19) * 5 >> t | t >> 3)))',
            '((-t & 4095) * (255 & t * (t & t >> 13)) >> 13) + (127 & t * (234 & t >> 8 & t >> 3) >> ( 3 & t >> 14))',
            't * (t >> ((t >> 9 | t >> 8)) & 63 & t >> 4)',
        ];


        private var _sound:Sound;
        private var _channel:SoundChannel;
        private var _t:Number = -1;
        private var _type:int = -1;
        private var _image:BitmapData;
        private var _px:int = 0;
        private var _py:int = 0;
        private var _control:Component;
        private var _buttons:Vector.<PushButton> = new Vector.<PushButton>();


        public function MathMusic() {
            _image = new BitmapData(256, 256, false, 0x0);
            var b:Bitmap = addChild(new Bitmap(_image)) as Bitmap;
            b.width = b.height = 465;
            
            var vbox:VBox = new VBox(this, 5, 5);
            for each (var f:String in FORMULAS) {
                var btn:PushButton = new PushButton(vbox, 0, 0, f.replace(/ +/g, '').toUpperCase(), _onClick);
                btn.toggle = true;
                btn.width = 227;
                _buttons.push(btn);
            }
            _control = vbox;
            _control.scaleX = _control.scaleY = 2;
            
            _sound = new Sound();
            _sound.addEventListener(SampleDataEvent.SAMPLE_DATA, _onSampleData);
            
            stage.addEventListener(MouseEvent.MOUSE_MOVE, function(e:*):void { _control.visible = true; });
            stage.addEventListener(Event.MOUSE_LEAVE, function(e:*):void { _control.visible = false; });
        }
        
        
        private function _play():void {
            for (var i:int = 0, n:int = _buttons.length; i < n; i++) {
                _buttons[i].selected = i == _type;
            }
            _t = 0;
            _px = 0;
            _py = 0;
            _image.fillRect(_image.rect, 0x0);
            if (_channel) _channel.stop();
            _channel = _sound.play();
        }


        private function _onClick(e:Event):void {
            var type:int = _buttons.indexOf(e.target);
            if (_type != type) {
                _type = type;
                _play();
            }
        }


        private var ot:int = -1;
        
        private function _onSampleData(e:SampleDataEvent):void {
            var i:int, t:int, tt:int, val:Number;
            _image.lock();
            for (i = 0; i < 8192; i++, _t++) {
                t = _t * 8 / 44.1;
                switch (_type) {
                    case 0: tt = t * ((t >> 12 | t >> 8) & 63 & t >> 4); break;
                    case 1: tt = (t * (t >> 5 | t >> 8)) >> (t >> 16); break;
                    case 2: tt = t * ((t >> 9 | t >> 13) & 25 & t >> 6); break;
                    case 3: tt = t * (t >> 11 & t >> 9 & 123 & t >> 3); break;
                    case 4: tt = (t * (t >> 8 * (t >> 15 | t >> 8) & (20 | (t >> 19) * 5 >> t | t >> 3))); break;
                    case 5: tt = ((-t & 4095) * (255 & t * (t & t >> 13)) >> 13) + (127 & t * (234 & t >> 8 & t >> 3) >> ( 3 & t >> 14)); break;
                    case 6: tt = t * (t >> ((t >> 9 | t >> 8)) & 63 & t >> 4); break;
                }
                tt &= 0xff;
                val = tt / 0xff;
                e.data.writeFloat(val);
                e.data.writeFloat(val);
                if (t != ot) {
                    _image.setPixel(_px, _py, tt << 16 | tt << 8 | tt);
                    if (++_px == _image.width) {
                        _px = 0;
                        if (++_py == _image.height) {
                            _py = 0;
                        }
                    }
                }
                ot = t;
            }
            _image.unlock();
        }
    }
}

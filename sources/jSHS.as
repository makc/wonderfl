// forked from Saqoosha's Math Music
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
     *
     @quasimondo: exchanged sound pattern forumulas for my own
     */
    [SWF(backgroundColor="0x000000", frameRate="30", width="475", height="475")]
    public class MathMusic extends Sprite {
        
        
        private static const FORMULAS:Array = [
            'Poor Vocoder',
            'Patiencie',
            'Dribble',
            'Who-is-Calling?',
            'Cowboy',
            'QX3710',
            'Paradroid',
            'Chacatronic',
            'Digger'
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
            b.width = b.height = 475;
            
            var vbox:VBox = new VBox(this, 5, 5);
            for each (var f:String in FORMULAS) {
                var btn:PushButton = new PushButton(vbox, 0, 0, f.replace(/ +/g, '').toUpperCase(), _onClick);
                btn.toggle = true;
                btn.width = 232;
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
                t = (_t * 8 / 44.1);
                switch (_type) {
                    case 0: tt = t*(((t>>15|t>>8)&(0xfff- (t&0xfff)) )& ((t%0x1934) >> (( t^(t>>3))&3)) & t >> 4); break;
                    case 1: tt = (((t>>9)>>((t*(t>>9))&0xf))>>((((t-t)>>(t&0xf))&16638)&0xf)); break;
                    case 2: tt= t*((t%((t>>7)&0xff))<<2 & ((t&0xff00)>>5) );break;
                    case 3: tt = (t|((97|(t+((t&t)&(t>>((t&(712&(t|(313+(195<<((t-(1113%(t+t)))&0xf))))))&0xf)))))>>(838&0xf)));break;
                    case 4: tt = (((t%(t>>7))%1082)&(566&(1422+((1647&(t>>9))*(t%1800)))));break;
                    case 5: tt = (15682-(37321&((31593&17772)+((t-(t>>8))&(((t>>6)&t)&t)))));break;
                   case 6: tt = (8351&(((2496*(t>>8))%11112)*(t+((6647>>(6505&0xf))>>((9255<<(2389&0xf))&0xf)))));break;
                   case 7: tt =  (13240+(40409%(((t>>4)+t)&16227))); break;
                   case 8: tt = (7736|(t+(t-(7083<<((((t>>11)%(975|14242))*(t%(2423>>((t<<(28126&0xf))&0xf))))&0xf)))));break;
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

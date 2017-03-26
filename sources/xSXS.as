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
    

    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.events.SampleDataEvent;
    import flash.media.Sound;
    import flash.media.SoundChannel;


    /**
     * This is inspired by
      "Experimental music from very short C programs"
     * http://www.youtube.com/watch?v=GtQdIYUtAHg
     * and Kyle's visualization.
     * http://www.flickr.com/photos/kylemcdonald/6187863454/in/photostream/
     *
     * Author: Mario Klingemann / @Quasimondo
     * Based on Saqoosha's Math Music Code
     
     * This version creates the entire formula randomly. Thus most of it will sound very ugly ;-)
     * 
     * TODOs: 
     ** - optimize formula
     * - add more commands
     * - improve UI
     */
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
        private var _slider1:HSlider;
        private var _slider2:HSlider;
        private var _slider3:HSlider;
        private var _formula:TextArea;
       
        private var masterSeed:uint = 0xffffffff * Math.random();
    
        public function MathMusicIncubator() {
            _image = new BitmapData(256, 256, false, 0x0);
            var b:Bitmap = addChild(new Bitmap(_image)) as Bitmap;
            b.width = b.height = 475;
            
            var vbox:VBox = new VBox(this, 5, 5);
            
            var _seed_btn:PushButton = new PushButton( vbox, 3,3,"Randomize Formula",_randomize );
            _slider1 = new HSlider(vbox,3,3,updateFormula);
            _slider1.width = 220;
            _slider1.minimum = 1;
            _slider1.maximum = 4095;
            _slider1.value = 255;
            
            _slider2 = new HSlider(vbox,3,3,updateFormula);
            _slider2.width = 220;
            _slider2.minimum = 1;
            _slider2.maximum = 15;
            _slider2.value = 255;
            
            _slider3 = new HSlider(vbox,3,3,updateFormula);
            _slider3.width = 220;
            _slider3.minimum = 4;
            _slider3.maximum = 64;
            _slider3.value = 8;
            
            _formula = new TextArea( vbox );
             var _copy_btn:PushButton = new PushButton( vbox, 3,3,"Copy to Clipboard",_copyToClipboard );
            
            
            _control = vbox;
            _control.scaleX = _control.scaleY = 2;
            
            _sound = new Sound();
            _sound.addEventListener(SampleDataEvent.SAMPLE_DATA, _onSampleData);
            
            stage.addEventListener(MouseEvent.MOUSE_MOVE, function(e:*):void { _control.visible = true; });
            stage.addEventListener(Event.MOUSE_LEAVE, function(e:*):void { _control.visible = false; });
            
            _randomize(null);
            _play();
        }
        
         private function _randomize( event:Event ):void {
             masterSeed = 0xffffffff * Math.random();
             _formula.text = getFormula();
            _play();
          }
         
          private function _copyToClipboard( event:Event ):void {
             Clipboard.generalClipboard.setData( ClipboardFormats.TEXT_FORMAT, _formula.text);
             
         }
         
          private function updateFormula( event:Event ):void {
               _formula.text = getFormula();
               _play();
     }    

        private function _play():void {
            
            _t = 0;
            _px = 0;
            _py = 0;
            _image.fillRect(_image.rect, 0x0);
            if (_channel) _channel.stop();
            _channel = _sound.play();
        }


        

        private var ot:int = -1;
        private var stack:Vector.<int> = new Vector.<int>(64,true);
      private var seed: uint;
        private var m_seed0:uint;
        private var m_seed1:uint;
        private var m_seed2:uint;  
        
       
        
        private function setSeed( seed:uint ):void
        {
            this.seed = seed;
            
            m_seed0 = (69069*seed) & 0xffffffff;
            if (m_seed0<2) {
                m_seed0+=2;
            }
    
            m_seed1 = (69069*m_seed0) & 0xffffffff;;
            if (m_seed1<8) {
                m_seed1+=8;
            }
    
            m_seed2 = ( 69069 *m_seed1) & 0xffffffff;;
            if (m_seed2<16) {
                m_seed2+=16;
            }
            
        }
        
        public function getNextInt(): uint
        {
            m_seed0 = ((( m_seed0 & 4294967294) << 12 )& 0xffffffff)^((((m_seed0<<13)&0xffffffff)^m_seed0) >>> 19 );
               m_seed1 = ((( m_seed1 & 4294967288) << 4) & 0xffffffff)^((((m_seed1<<2)&0xffffffff)^m_seed1)>>>25)
            m_seed2=  ((( m_seed2 & 4294967280) << 17) & 0xffffffff)^((((m_seed2<<3)&0xffffffff)^m_seed2)>>>11)
            return m_seed0 ^ m_seed1 ^ m_seed2;
        }
        
        public function rnd( min: int = 0, max: int = 1 ): int
        {
            return min + Number(getNextInt() / uint( 0xffffffff)) * ( max - min );
        }
        
        private function _onSampleData(e:SampleDataEvent):void {
            var i:int, t:int, tt:int, val:Number;
            
            _image.lock();
            for (i = 0; i < 8192; i++, _t++) {
                t = (_t * 8 / 44.1);
                
                setSeed(masterSeed);
                var steps:int = _slider3.value;
                var v1:int, v2:int;
                var stackpointer:int = 0;
                 for ( var k:int = 0; k < steps; k++ )
                 {
                   var command:int = rnd(0,24);
                    if ( stackpointer < 2 )
                    {
                      stack[stackpointer++] = ((command & 1) == 0) ? t : rnd(0,_slider1.value);
                } else {
                
                switch( command )
                {
                   case 0:
                     v1 = stack[--stackpointer];
                     v2 = stack[--stackpointer];
                     stack[stackpointer++] = v1 * v2;
                   break;
                   case 1:
                     v1 = stack[--stackpointer];
                     v2 = stack[--stackpointer];
                     stack[stackpointer++] = v1 + v2;
                   break;
                   case 2:
                    v1 = stack[--stackpointer];
                     v2 = stack[--stackpointer];
                     stack[stackpointer++] = v1 - v2;
                   break;
                   case 3:
                     v1 = stack[--stackpointer];
                     v2 = stack[--stackpointer];
                     stack[stackpointer++] = v1 % v2;
                   break;
                   case 4:
                   case 12:
                   case 13:
                   case 21:
                     v1 = stack[--stackpointer];
                     v2 = stack[--stackpointer];
                     stack[stackpointer++] = v1 | v2;
                   break;
                   case 5:
                   case 20:
                     v1 = stack[--stackpointer];
                     v2 = stack[--stackpointer];
                     stack[stackpointer++] = v1 & v2;
                   break;
                   case 6:
                     v1 = stack[--stackpointer];
                     v2 = stack[--stackpointer];
                     stack[stackpointer++] = v1 ^ v2;
                   break;
                   case 7:
                     v1 = stack[--stackpointer];
                     v2 = stack[--stackpointer] & 0xf;
                     stack[stackpointer++] = v1 << v2;
                   break;
                   case 8:
                   case 14:
                   case 15:
                    case 16:
                     v1 = stack[--stackpointer];
                     v2 = stack[--stackpointer] & 0xf;
                     stack[stackpointer++] = v1 >> v2;
                   break;
                   case 9:
                   case 17:
                   case 18:
                     stack[stackpointer++] = t;
                     break;
                   case 10:
                     stack[stackpointer++] = rnd(0,_slider1.value);
                     break;
                    case 11:
                    case 19:
                     stack[stackpointer++] = t >> rnd(0,_slider2.value);
                     break;
                      case 22:
                     stack[stackpointer++] =stack[stackpointer-2];
                     break;
                      case 23:
                      v1 =  stack[stackpointer-1];
                     stack[stackpointer-1] =stack[stackpointer-2];
                     stack[stackpointer-2] = v1;
                     break;
                }
                }
               }
  
                tt = stack[0] & 0xff;
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
   
    
    private function getFormula():String
    {
        var actionStack:Array = [];    
        setSeed(masterSeed);
                var steps:int = _slider3.value;
                var v1:String, v2:String;
                var stackpointer:int = 0;
                 for ( var k:int = 0; k < steps; k++ )
                 {
                   var command:int = rnd(0,24);
                    if ( stackpointer < 2 )
                    {
                      actionStack[stackpointer++] = ((command & 1) == 0) ? "t" : rnd(0,_slider1.value);
                } else {
                
                switch( command )
                {
                   case 0:
                     v1 = actionStack[--stackpointer];
                     v2 = actionStack[--stackpointer];
                     actionStack[stackpointer++] = "("+v1+"*"+v2+")";
                   break;
                   case 1:
                     v1 = actionStack[--stackpointer];
                     v2 = actionStack[--stackpointer];
                     actionStack[stackpointer++] = "("+v1+"+"+v2+")";
                   break;
                   case 2:
                    v1 = actionStack[--stackpointer];
                     v2 = actionStack[--stackpointer];
                     actionStack[stackpointer++] = "("+v1+"-"+v2+")";
                   break;
                   case 3:
                     v1 = actionStack[--stackpointer];
                     v2 = actionStack[--stackpointer];
                     actionStack[stackpointer++] = "("+v1+"%"+v2+")";
                   break;
                   case 4:
                   case 12:
                   case 13:
                   case 21:
                     v1 = actionStack[--stackpointer];
                     v2 = actionStack[--stackpointer];
                     actionStack[stackpointer++] = "("+v1+"|"+v2+")";
                   break;
                   case 5:
                   case 20:
                     v1 = actionStack[--stackpointer];
                     v2 = actionStack[--stackpointer];
                     actionStack[stackpointer++] = "("+v1+"&"+v2+")";
                   break;
                   case 6:
                     v1 = actionStack[--stackpointer];
                     v2 = actionStack[--stackpointer];
                     actionStack[stackpointer++] ="("+v1+"^"+v2+")";
                   break;
                   case 7:
                     v1 = actionStack[--stackpointer];
                     v2 = actionStack[--stackpointer] ;
                     actionStack[stackpointer++] = "("+v1+"<<("+v2+"&0xf))";
                   break;
                   
                   case 8:
                   case 14:
                   case 15:
                    case 16:
                     v1 = actionStack[--stackpointer];
                     v2 = actionStack[--stackpointer];
                     actionStack[stackpointer++] = "("+v1+">>("+v2+"&0xf))";
                   break;
                   
                   case 9:
                   case 17:
                   case 18:
                     actionStack[stackpointer++] = "t";
                     break;
                   
                   case 10:
                     actionStack[stackpointer++] = rnd(0,_slider1.value);
                     break;
                    
                    case 11:
                    case 19:
                     actionStack[stackpointer++] = "(t>>"+rnd(0,_slider2.value)+")";
                     break;
                    
                     case 22:
                     actionStack[stackpointer++] = actionStack[stackpointer-2];
                     break;
                     
                     case 23:
                      v1 =  actionStack[stackpointer-1];
                     actionStack[stackpointer-1] = actionStack[stackpointer-2];
                     actionStack[stackpointer-2] = v1;
                     break;
                }
               }
              }
              return actionStack[0];
             }
            }   
}

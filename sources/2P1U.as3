// SiON TENORION
package {
    import flash.display.Sprite;
    import flash.events.*;
    import flash.text.TextField;
	import net.user1.reactor.IClient;
	import net.user1.reactor.Reactor;
	import net.user1.reactor.ReactorEvent;
	import net.user1.reactor.Room;
	import net.user1.reactor.RoomEvent;
    import org.si.sion.*;
    import org.si.sion.events.*;
    import org.si.sion.sequencer.SiMMLTrack;
    import org.si.sion.utils.SiONPresetVoice;
    
    
    [SWF(width="465", height="465", backgroundColor="#ffffff", frameRate=30)]
    public class Tenorion extends Sprite {
        // driver
        public var driver:SiONDriver = new SiONDriver();
        
        // preset voice
        public var presetVoice:SiONPresetVoice = new SiONPresetVoice();
        
        // voices, notes and tracks
        public var tracks:Vector.<SiMMLTrack> = new Vector.<SiMMLTrack>(16);
        public var voices:Vector.<int> = Vector.<int>([ 0, 1, 2, 3,  4, 4, 4, 4,  4, 4, 4, 4,  4, 4, 4, 4]);
        public var notes:Vector.<int>  = Vector.<int>([36,48,60,72, 43,48,55,60, 65,67,70,72, 77,79,82,84]);
        
        // beat counter
        public var beatCounter:int;
        
        // control pad
        public var matrixPad:MatrixPad;
        
		// union
		private var c:Reactor = new Reactor();
		private var r:Room;
		
        // constructor
        function Tenorion() {
            Wonderfl.capture_delay( 10 );
            
            driver.setVoice(0, presetVoice["valsound.percus1"]);  // bass drum
            driver.setVoice(1, presetVoice["valsound.percus28"]); // snare drum
            driver.setVoice(2, presetVoice["valsound.percus17"]); // close hihat
            driver.setVoice(3, presetVoice["valsound.percus23"]); // open hihat
            driver.setVoice(4, presetVoice["valsound.bass18"]);
            
            // listen click
            driver.setTimerInterruption(1, _onTimerInterruption);
            driver.setBeatCallbackInterval(1);
            driver.addEventListener(SiONTrackEvent.BEAT, _onBeat);
            driver.addEventListener(SiONEvent.STREAM_START, _onStreamStart);
            
            // control pad
            matrixPad = new MatrixPad(stage);
            matrixPad.x = 72;
            matrixPad.y = 72;
			matrixPad.addEventListener( DataEvent.CHANGE, onChange );
			
			// connect to union server
			connect();
		}
		
		// invoked when change event occurs by MatrixPad
		protected function onChange(e:DataEvent):void {
			if ( c.isReady() ) {
				if ( r.clientIsInRoom() ) {
					r.sendMessage( "I_CLICKED_SOMEWHERE", true, null, e.track, e.beat, e.bit );
				}
			}
		}
		
		// connect to union server
		protected function connect():void{
			c.addEventListener(ReactorEvent.READY, onReady);
			c.connect("tryunion.com", 9100);
		}
		
		// invoked when the connection is ready
		private function onReady(e:ReactorEvent):void {
			c.getMessageManager().addMessageListener("GIVE_ME_LOG", sendLog);
			c.getMessageManager().addMessageListener("THIS_IS_LOG", happyToReceiveLog);
			r = c.getRoomManager().createRoom("tenorion_share");
			r.addMessageListener("I_CLICKED_SOMEWHERE", someoneClicked );
			r.addEventListener(RoomEvent.SYNCHRONIZE, onSynchronize);
			r.join();
		}
		
		// invoked when received map from someone
		protected function happyToReceiveLog(from:IClient, data:String):void {
			
			matrixPad.setSequences(Vector.<int>(data.split(",")));
			start();
		}
		
		// send map to new comer
		protected function sendLog(from:IClient):void {
			var data:Array = [];
			for each( var value:int in matrixPad.sequences ) {
				data.push( value );
			}
			from.sendMessage("THIS_IS_LOG", data.join(","));
		}
		
		// invoked when joined the room
		protected function onSynchronize(e:RoomEvent):void {
			if ( r.getClients().length == 1 ) {
				start();
			} else {
				var topClient:IClient = r.getClients()[0];
				topClient.sendMessage("GIVE_ME_LOG");
			}
			
		}
		
		// invoked when received click action by someone other
		protected function someoneClicked(from:IClient, track:int, beat:int, bit:int):void {
			matrixPad.clickAction(track, beat, bit);
			var ttf:TempTF = new TempTF("id: " + from.getClientID());
			this.addChild( ttf );
			ttf.x = matrixPad.x + beat * 20 + 10;
			ttf.y = matrixPad.y + (15 - track) * 20 + 5;
		}
		
		// start playing when the map is ready
		private function start():void{
            addChild(matrixPad);
            // start streaming
            driver.play();
        }
        
        
        // _onStreamStart (SiONEvent.STREAM_START) is called back first of all after SiONDriver.play().
        private function _onStreamStart(e:SiONEvent) : void
        {
            // create new controlable tracks and set voice
            for (var i:int=0; i<16; i++) {
                tracks[i] = driver.sequencer.newControlableTrack();
                tracks[i].setChannelModuleType(6, 0, voices[i]);
                tracks[i].velocity = 64;
            }
            beatCounter = 0;
        }
        
        
        // _onBeat (SiONTrackEvent.BEAT) is called back in each beat at the sound timing.
        private function _onBeat(e:SiONTrackEvent) : void 
        {
            matrixPad.beat(e.eventTriggerID & 15);
        }
        
        
        // _onTimerInterruption (SiONDriver.setTimerInterruption) is called back in each beat at the buffering timing.
        private function _onTimerInterruption() : void
        {
            var beatIndex:int = beatCounter & 15;
            for (var i:int=0; i<16; i++) {
                if (matrixPad.sequences[i] & (1<<beatIndex)) tracks[i].keyOn(notes[i]);
            }
            beatCounter++;
        }
    }
}



import flash.display.*;
import flash.events.*;
import flash.geom.*;
import flash.text.engine.FontDescription;

class MatrixPad extends Bitmap {
    public var sequences:Vector.<int> = new Vector.<int>(16);
    private var canvas:Shape = new Shape();
    private var buffer:BitmapData = new BitmapData(320, 320, true, 0);
    private var padOn:BitmapData  = _pad(0x303050, 0x6060a0);
    private var padOff:BitmapData = _pad(0x303050, 0x202040);
    private var pt:Point = new Point();
    private var colt:ColorTransform = new ColorTransform(1,1,1,0.1)
    
    function MatrixPad(stage:Stage) {
        super(new BitmapData(320, 320, false, 0));
        var i:int;
        for (i=0; i<256; i++) {
            pt.x = (i&15)*20;
            pt.y = (i&240)*1.25;
            buffer.copyPixels(padOff, padOff.rect, pt);
            bitmapData.copyPixels(padOff, padOff.rect, pt);
        }
        for (i=0; i<16; i++) sequences[i] = 0;
        addEventListener("enterFrame", _onEnterFrame);
        stage.addEventListener("click",  _onClick);
    }
    
	// set sequence and make the map of on/off
	public function setSequences(data:Vector.<int>):void {
		sequences = data;
		for ( var track:int = 0; track < 16; track++ ) {
			for ( var beat:int = 0; beat < 16; beat++ ) {
				pt.x = beat*20;
				pt.y = (15-track)*20;
				if (sequences[track] & (1<<beat)) buffer.copyPixels(padOn, padOn.rect, pt);
				else buffer.copyPixels(padOff, padOff.rect, pt);
			}
		}
	}
	
    private function _pad(border:int, face:int) : BitmapData {
        var pix:BitmapData = new BitmapData(20, 20, false, 0);
        canvas.graphics.clear();
        canvas.graphics.lineStyle(1, border);
        canvas.graphics.beginFill(face);
        canvas.graphics.drawRect(1, 1, 17, 17);
        canvas.graphics.endFill();
        pix.draw(canvas);
        return pix;
    }
    
    private function _onEnterFrame(e:Event) : void {
        bitmapData.draw(buffer, null, colt);
    }
	
	// reflect someone's click action
	public function clickAction(track:int, beat:int, bit:int):void {
		if ( bit ) sequences[track] |= bit;
		else sequences[track] &= 0xFFFF ^ (1 << beat);
		pt.x = beat*20;
		pt.y = (15-track)*20;
		if (sequences[track] & (1<<beat)) buffer.copyPixels(padOn, padOn.rect, pt);
		else buffer.copyPixels(padOff, padOff.rect, pt);
	}
    
    private function _onClick(e:Event) : void {
        if (mouseX>=0 && mouseX<320 && mouseY>=0 && mouseY<320) {
            var track:int = 15-int(mouseY*0.05), beat:int = int(mouseX*0.05);
            sequences[track] ^= 1 << beat;
			dispatchEvent( new DataEvent( DataEvent.CHANGE, track, beat, sequences[track] & (1 << beat) ) );
        }
    }
    
    public function beat(beat16th:int) : void {
        for (pt.x=beat16th*20, pt.y=0; pt.y<320; pt.y+=20) bitmapData.copyPixels(padOn, padOn.rect, pt);
    }
}
import flash.text.TextField;

class TempTF extends Sprite {
	public var tf:TextField = new TextField();
	public function TempTF(str:String) {
		tf.text = str;
		tf.textColor = 0xFF8888FF;
		this.mouseEnabled = this.mouseChildren = false;
		this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		this.alpha = 3;
		this.addChild( tf );
	}
	private function onEnterFrame(e:Event):void {
		this.alpha *= 0.95;
		if ( this.alpha < 0.1 ) {
			this.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			if ( this.parent != null ) {
				this.parent.removeChild( this );
			}
		}
	}
}

class DataEvent extends Event {
	public var track:int;
	public var beat:int;
	public var bit:int;
	public static const CHANGE:String = "change";
	public function DataEvent(type:String, track:int, beat:int, bit:int, bubbles:Boolean = false, cancelable:Boolean = false ) {
		this.track = track;
		this.beat = beat;
		this.bit = bit;
		super(type, bubbles, cancelable);
	}
	public override function toString():String {
		return super.toString() + "[track:" + track + ", beat:" + beat +", bit:" + bit + "]";
	}
}

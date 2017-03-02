package {
    //drag mouse: draw waveform
    //press key: reset waveform

    import flash.display.Sprite;  
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.media.Sound;
    import flash.events.SampleDataEvent;
    import flash.events.Event;
    import flash.media.SoundMixer;
    import flash.utils.ByteArray;
    import flash.display.Graphics;
    import flash.events.MouseEvent;
    import flash.events.KeyboardEvent;
	
    [SWF(width="256", height="240", backgroundColor="0x000000", frameRate="30")]
    public class SounDraw extends Sprite {
	private static const PLOT_HEIGHT:int = 120;
	private static const CHANNEL_LENGTH:int = 256;
		
	private var on:Boolean = false;
	private var snd:Sound;
	private var table:Array;
		
        public function SounDraw() {
	    init();
        }
		
	private function init():void {
            stage.align = StageAlign.TOP_LEFT;
            stage.scaleMode = StageScaleMode.NO_SCALE;
	    snd = new Sound();
	    snd.addEventListener(SampleDataEvent.SAMPLE_DATA, drawSound);
			
	    table = new Array(256);
	    for(var i:uint = 0; i<table.length; i++) {
	        table[i] = 0;
	    }
			
	    addEventListener(Event.ENTER_FRAME, onEnterFrame);
	    snd.play();
			
            stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
	    stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
	    stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
	}
		
	private function onMouseDown(e:MouseEvent):void {
	    on = true;
	}
		
	private function onMouseUp(e:MouseEvent):void {
	    on = false;
        }
		
	private function onEnterFrame(e:Event):void {
	    if(on) {
		table[mouseX] = (PLOT_HEIGHT-mouseY)/PLOT_HEIGHT;
	    }
	}

	private function onKeyUp(e:KeyboardEvent):void {
	    for(var i:uint = 0; i<table.length; i++) {
		table[i] = 0;
	    }
	}
		
	private function drawSound(e:SampleDataEvent):void {
	    for(var c:uint = 0 ; c < 2048; c++) {
		e.data.writeFloat(table[c%255]);
		e.data.writeFloat(table[c%255]);
	    }
	    visualize();
	}
	
        private function visualize():void {
            var bytes:ByteArray = new ByteArray();
	    SoundMixer.computeSpectrum(bytes, false, 0);
	    var g:Graphics = this.graphics;
	    g.clear();
	    g.lineStyle(0, 0xFFFFFF);
	    g.moveTo(0, PLOT_HEIGHT);
			
            var n:Number = 0;
            
            for (var i:int = 0; i < CHANNEL_LENGTH/2; i++) {
                n = (bytes.readFloat() * PLOT_HEIGHT);
                g.lineTo(i*2, PLOT_HEIGHT - n);
            }
			
            g.lineTo(CHANNEL_LENGTH, PLOT_HEIGHT);
	}
    }
}

// forked from miyaoka's DSG_study2
// forked from miyaoka's DSG_study
package 
{
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
    import com.bit101.components.*;

	[SWF(width = "465", height = "465", backgroundColor = 0xffffff, frameRate = "60")]	
	public class DSG_study3 extends Sprite 
	{
		public function DSG_study3() 
		{
			//bg
            var mtr:Matrix = new Matrix();
            mtr.createGradientBox(stage.stageWidth*2, stage.stageHeight*2, 0, -stage.stageWidth/2, -stage.stageHeight/2);
            graphics.beginGradientFill(
                GradientType.RADIAL, 
                [0x999999, 0xffffff], 
                [1, 1],
                [30, 255],
                mtr
            );
			graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			
			//dsg
			var d:DSG_Shape = new DSG_Shape();
			d.x = stage.stageWidth - 16;
			d.y = stage.stageHeight/2;
			addChild(d);
			
			//freq
			var t:Label = new Label();
			var s:Slider = new Slider(Slider.VERTICAL, this, stage.stageWidth-16, 16, function ():void 
			{
				t.y = mouseY - 10;
				t.x = s.x - t.width;
				d.note = s.value;
				t.text = d.freq.toFixed(0) + "Hz (" + s.value.toFixed(0) + ")";
			});
			s.width = 16;
			s.height = stage.stageHeight - 16*2;
			s.setSliderParams(0, 127, 69);
			s.backClick = true;
			
			var l:Label = new Label(this, 320, 0, "Frequency(MIDI note number)");
			addChild(l);
			addChild(s);
			addChild(t);

			//sampling rate
			var t2:Label = new Label();
			var s2:Slider = new Slider(Slider.HORIZONTAL, this, 0, stage.stageHeight-16, function ():void 
			{
				t2.text = (s2.value / 1000).toFixed(1) + "KHz";
				t2.x = mouseX;
				t2.y = s2.y - t.height;
				d.samplingRate = s2.value;
			});
			s2.height = 16
			s2.width = stage.stageWidth - 16;
			s2.setSliderParams(1000, 88200, 44100);
			s2.backClick = true;
			
			var l2:Label = new Label(this, 0, 420, "SamplingRate");
			addChild(l2);
			addChild(s2);
			addChild(t2);
			
			//waves
			var rb1:RadioButton = new RadioButton(this,0,0, "Sine",true,function ():void 
			{
				d.wave = new SinWave
			});
			addChild(rb1);
			var rb2:RadioButton = new RadioButton(this,0,rb1.y+rb1.height, "Square",false,function ():void 
			{
				d.wave = new SquareWave
			});
			addChild(rb2);
			var rb3:RadioButton = new RadioButton(this,0,rb2.y+rb2.height, "Saw",false,function ():void 
			{
				d.wave = new SawWave
			});
			addChild(rb3);
			var rb4:RadioButton = new RadioButton(this,0,rb3.y+rb3.height, "Triangle",false,function ():void 
			{
				d.wave = new TriangleWave
			});
			addChild(rb4);
			var rb5:RadioButton = new RadioButton(this,0,rb4.y+rb4.height, "Noise",false,function ():void 
			{
				d.wave = new NoiseWave
			});
			addChild(rb5);
			
			//amp
			var k:Knob = new Knob(this, 100, 0, "amp", function ():void 
			{
				d.amp = k.value;
			});
			k.labelPrecision = 2;
			k.minimum = 0;
			k.maximum = 1;
			k.value = 0.25;
		}
	}
}
import flash.display.*;
import flash.events.*;
import flash.geom.*;
import caurina.transitions.Tweener;
import flash.media.Sound;
import flash.utils.getTimer;
class DSG_Shape
extends Sprite
{
	private static const BUFFER_LENGTH:uint = 2048;
	private static const PI2:Number = Math.PI * 2;
	private var drawHeight:Number = 100;
	private var drawWidth:Number = BUFFER_LENGTH;
	private var snd:Sound;
	public var amp:Number = 0.25;
	private var sp:Shape = new Shape;
	private var bmp:Bitmap;
	
	private var phase:Number = 0;
	private var phaseStep:Number;
	
	public function DSG_Shape():void 
	{
		note = 69;
		addEventListener(Event.ADDED_TO_STAGE, init);
	}
	private var _note:Number;
	public function set note(num:Number):void 
	{
		_note = Math.max(0, Math.min(127, num));
		freq =  440 * Math.pow(2, (_note - 69) / 12);		
	}
	public function get note():Number
	{
		return _note;
	}
	private var _freq:Number;
	public function set freq(num:Number):void 
	{
		_freq = num;
		phaseStep = _freq * PI2 / samplingRate;
	}
	public function get freq():Number
	{
		return _freq;
	}
	private var _samplingRate:Number = 44100;
	public function set samplingRate(num:Number):void 
	{
		_samplingRate = num;
		freq = freq;
	}
	public function get samplingRate():Number
	{
		return _samplingRate;
	}
	private var _wave:IWave = new SinWave
	public function set wave(w:IWave):void 
	{
		_wave = w;
	}
	public function get wave():IWave
	{
		return _wave;
	}
	
	
	private function init(e:Event):void 
	{
		removeEventListener(Event.ADDED_TO_STAGE, init);

		var bmd:BitmapData = new BitmapData(stage.stageWidth, drawHeight*2+10, false, 0);
		bmp = new Bitmap(bmd);
		bmp.x = -bmd.width;
		bmp.y = -bmd.height / 2;
		addChild(bmp);
		
		snd = new Sound();
		snd.addEventListener(SampleDataEvent.SAMPLE_DATA, sampleDataHandler);
		snd.play();
	}
    private function sampleDataHandler(e:SampleDataEvent):void {
		var g:Graphics = sp.graphics;
		g.clear();
		g.lineStyle(2, 0x0);

		g.moveTo(0, Math.sin(phase) * amp * drawHeight);
		
		var w:Number = drawWidth / BUFFER_LENGTH;
		for (var i:int = 0; i < BUFFER_LENGTH; i++)
		{
			var sample:Number = wave.value(phase += phaseStep) * amp;
			e.data.writeFloat(sample);
			e.data.writeFloat(sample);
			//
			g.lineTo(i*w, -sample * drawHeight);
		}
		var bmd1:BitmapData = bmp.bitmapData;
		var bmd2:BitmapData = new BitmapData(bmd1.width, bmd1.height, true, 0);
		bmd2.draw(bmd1, new Matrix(1, 0, 0, 1, -drawWidth));
		bmd2.draw(sp, new Matrix(1, 0, 0, 1, bmd2.width - drawWidth, bmd2.height / 2));
		bmp.bitmapData = bmd2;
		bmd1.dispose();
	}
}
interface IWave
{
	function value(t:Number):Number;
}
class SinWave
implements IWave
{
	public function value(t:Number):Number
	{
		return Math.sin(t);
	}
}
class SquareWave
implements IWave
{
	public function value(t:Number):Number
	{
		return Math.sin(t) > 0 ? 1 : -1;
	}
}
class SawWave
implements IWave
{
	public function value(t:Number):Number
	{
		var t2:Number = t / Math.PI / 2;
		return (t2 - Math.round(t2))*2
	}
}
class TriangleWave
implements IWave
{
	public function value(t:Number):Number
	{
		var t2:Number = (t / Math.PI / 2) % 1;
		return (Math.abs(t2 - Math.round(t2)) * 2 - 0.5)*2;
	}
}
class NoiseWave
implements IWave
{
	public function value(t:Number):Number
	{
		return Math.random()*2-1;
	}
}
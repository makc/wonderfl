// write as3 code here..
package
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	[SWF(backgroundColor="#000000")]
	
	public class DSG extends Sprite
	{
		public function DSG()
		{
			super();
			
			init();
		}
		
		private var timer:Timer;
		private var noteNumbers:Array = [60, 62, 64, 65, 67, 69, 71, 72];
		
		private function init():void
		{
			ring();
			
			timer = new Timer(1000);
			timer.addEventListener(TimerEvent.TIMER, timerHandler);
			timer.start();
		}
		
		private function ring():void
		{
			if (noteNumbers.length == 0)
				return;
			
			var noteNumber:int = noteNumbers[int(Math.random() * noteNumbers.length)];	

			var attack:Number = Math.random() * 5;
                        var decay:Number = Math.random() * 5;
                        var release:Number = 10 - attack - decay;

			new Tone(noteNumber, 2, 8, attack, decay, 5, release).start();
			new Particle(noteNumber, 2, 8, attack, decay, 5, release, this).start();
		}
		
		private function timerHandler(event:TimerEvent):void
		{
			ring();
		}
		
	}
}

import flash.display.Sprite;
import flash.events.Event;
import flash.events.TimerEvent;
import flash.utils.Timer;

class Particle extends Sprite
{
	public static const UNIT:int = 10;
	
	public static const TIMER_RATE:int = 20;
	
	public function Particle(noteNumber:uint, length:Number, volume:Number, attack:Number, decay:Number, sustain:Number, release:Number, parent:Sprite)
	{	
		this.noteNumber = noteNumber;
		this.length = length;
		this.volume = volume;
		this.attack = attack;
		this.decay = decay;
		this.sustain = sustain;
		this.release = release;
		
		amplify = volume > sustain ? volume : sustain;
		
		parent.addChildAt(this, 0);
		
		check();
		initializeVelocity();
	}
	
	private var timer:Timer;
	
	private var radius:Number = 0;
	private var alphaValue:Number = 1;
	private var amplify:Number = 0;
	
	private var state:int = 1; // 1: Attack, 2: Decay, 3: Release
	
	private var noteNumber:uint;
	private var length:Number;
	private var volume:Number;
	private var attack:Number;
	private var decay:Number;
	private var sustain:Number;
	private var release:Number;
	
	private var v1:Number;
	private var v2:Number;
	private var v3:Number;
	
	private function check():void
	{
		if (attack + decay + release != UNIT)
		{
			 attack = 0;
			 decay = 5;
			 release = 5;
		}
			
		if (volume > UNIT)
			volume = UNIT;
		
		if (volume < 0)
			volume = 0;
			
		if (sustain > UNIT)
			sustain = UNIT;
			
		if (sustain < 0)
			sustain = 0;
	}
	
	private function initializeVelocity():void
	{			
		v1 = volume / (TIMER_RATE * length * attack / UNIT);
		v2 = (volume - sustain) / (TIMER_RATE * length * decay / UNIT);
		v3 = sustain / (TIMER_RATE * length * release / UNIT);
		
		alphaValue = volume > sustain ? volume : sustain;
	}
	
	private function init():void
	{
		timer = new Timer(1000 / TIMER_RATE);
		timer.addEventListener(TimerEvent.TIMER, timerHandler);
		timer.start();
	}
	
	private function update():void
	{
		drawGraphics();
		updateParams();
	}
	
	private function drawGraphics():void
	{
		graphics.clear();
		
		graphics.beginFill(0xFFFFFF, alphaValue / 10);
		graphics.drawCircle(0, 0, radius * 0.8 * amplify);
		graphics.endFill();
	}
	
	private function updateParams():void
	{
		if (state == 1)
		{
			radius += v1;

			if (radius >= volume)
			{
				radius = volume;
				state = 2;
			}
		}
		else if (state == 2)
		{
			if (volume < sustain)
			{
				radius -= v2;
				
				if (radius >= sustain)
				{
					radius = sustain;
					state = 3;
				}
			}
			else
			{
				alphaValue -= v2;
				
				if (alphaValue <= sustain)
				{
					alphaValue = sustain;
					state = 3;
				}
			}	
		}
		else if (state == 3)
		{
			alphaValue -= v3;
			
			if (alphaValue <= 0)
			{
				alphaValue = 0;
				
				stop();
			}
		}
	}
	
	public function start():void
	{
		if (!parent)
			throw new Error("parent must be specified.");
		
		if (x == 0 && y == 0)
		{
			x = Math.random() * stage.stageWidth;
			y = Math.random() * stage.stageHeight;
		}
		
		timer = new Timer(1000 / TIMER_RATE);
		timer.addEventListener(TimerEvent.TIMER, timerHandler);
		timer.start();
	}
	
	public function stop():void
	{
		timer.removeEventListener(TimerEvent.TIMER, timerHandler);
		
		parent.removeChild(this);
		
		dispatchEvent(new Event(Event.COMPLETE));
	}
	
	private function timerHandler(event:TimerEvent):void
	{
		update();
	}
	
}

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.SampleDataEvent;
import flash.media.Sound;
import flash.utils.ByteArray;

class Tone extends EventDispatcher
{
	public static const SAMPLING_RATE:Number = 44100;
	public static const BUFFER_SIZE:int = 8192;
		
	public static const UNIT:int = 10;
	
	public function Tone(noteNumber:uint, length:Number, volume:Number, attack:Number, decay:Number, sustain:Number, release:Number)
	{	
		this.frequency = noteNumber2frequency(noteNumber);
		this.length = length;
		this.volume = volume;
		this.attack = attack;
		this.decay = decay;
		this.sustain = sustain;
		this.release = release;
		
		check();
		initializeVelocity();
	}
	
	private var sound:Sound;
	
	private var phase:Number = 0;
	private var amplify:Number = 0;
	
	private var state:int = 1; // 1: Attack, 2: Decay, 3: Release
	
	private var frequency:Number;
	private var length:Number;
	private var volume:Number;
	private var attack:Number;
	private var decay:Number;
	private var sustain:Number;
	private var release:Number;
	
	private var v1:Number;
	private var v2:Number;
	private var v3:Number;
		
	private function check():void
	{
		if (attack + decay + release != UNIT)
		{
			 attack = 0;
			 decay = 5;
			 release = 5;
		}
			
		if (volume > UNIT)
			volume = UNIT;
		
		if (volume < 0)
			volume = 0;
			
		if (sustain > UNIT)
			sustain = UNIT;
			
		if (sustain < 0)
			sustain = 0;
	}
	
	private function initializeVelocity():void
	{			
		v1 = volume / (SAMPLING_RATE * length * attack / UNIT);
		v2 = (volume - sustain) / (SAMPLING_RATE * length * decay / UNIT);
		v3 = sustain / (SAMPLING_RATE * length * release / UNIT);
	}
	
	private function updateAmplify():void
	{
		if (state == 1)
		{
			amplify += v1;

			if (amplify >= volume)
			{
				amplify = volume;
				state = 2;
			}
		}
		else if (state == 2)
		{
			amplify -= v2;
			
			if (volume < sustain)
			{
				if (amplify >= sustain)
				{
					amplify = sustain;
					state = 3;
				}
			}
			else
			{
				if (amplify <= sustain)
				{
					amplify = sustain;
					state = 3;
				}
			}	
		}
		else if (state == 3)
		{
			amplify -= v3;
			
			if (amplify <= 0)
			{
				amplify = 0;
				
				stop();
			}
		}
	}
	
	public function start():void
	{					
		sound = new Sound();
		sound.addEventListener(SampleDataEvent.SAMPLE_DATA, soundSampleDataHandler);
		sound.play();
	}
	
	public function stop():void
	{
		sound.removeEventListener(SampleDataEvent.SAMPLE_DATA, soundSampleDataHandler);
		dispatchEvent(new Event(Event.COMPLETE));
	}
	
	private function soundSampleDataHandler(event:SampleDataEvent):void
	{	
		var bytes:ByteArray = new ByteArray();
		
		for (var i:int = 0; i < BUFFER_SIZE; ++i)
		{
			phase += frequency / SAMPLING_RATE;  
			
			var phaseAngle:Number = phase * Math.PI * 2;
			var sample:Number = Math.sin(phaseAngle) * amplify / UNIT;
			
			sample *= 0.2;
			
			bytes.writeFloat(sample);
			bytes.writeFloat(sample);
			
			updateAmplify();
		}
		
		event.data.writeBytes(bytes);
	}
	
}

function noteNumber2frequency(value:uint):Number
{
	if (value > 127)
		value = 127;
	
	return 440 * Math.pow(2, (value - 69) / 12);
}
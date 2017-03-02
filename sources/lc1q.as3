package
{
/*
　cat voice keyboard

 作っては見たけれど、動的にサンプリング音源をFFT変換するには、
 かなり無理があり、実用的ではないかも。
 なので、あらかじめ必要な音を全部生成しキーボードに割り付けてみましたが
 それはそれで、最初にかなり時間がかかるので、やはり全音サンプリングデータを
 取り込んだ方が、早い気がしますね。
 
 なお、PhaseVocoder&FFTは、海外サイト
 http://iq12.com/blog/2009/08/25/real-time-pitch-shifting/ 
 より、拝借
 情報を頂いた、alumican_netさんに多謝
*/

	
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.media.Sound;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.net.*;
	import flash.text.*;
	import net.hires.debug.Stats;
 
	[SWF(width = 465, height = 465, frameRate = 60, backgroundColor=0x727B80)]

	public class catKeyboard extends Sprite {
		//private var loadData:String = "http://marubayashi.net/archive/sample/cat/guitar.mp3";
		private var loadData:String = "http://marubayashi.net/archive/sample/cat/cat.mp3";
		private var source:Sound = new Sound();
		private var white:Sprite;
		private var black:Sprite;
		private var comment:TextField;
		private var progressVar:Sprite
		
		public function catKeyboard() {
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.quality = StageQuality.HIGH;

			
			var back:Sprite=new Sprite()
			back.graphics.beginFill(0x727B80,1)
			back.graphics.drawRect(0,0,465,465)
			addChild(back)
			addChild(new Stats())

			//簡易loadingBar
			progressVar = new Sprite()
			addChild(progressVar)
			progressVar.y=465/2+80

			//Bar
			for (var i:uint=0;i<24;i++) {
				catWalk(i,0.2)
			}

			comment=new TextField()
			comment.autoSize=TextFieldAutoSize.CENTER
			comment.selectable=false;
			comment.mouseEnabled=false;
			var format:TextFormat=new TextFormat();
			format.color=0x000000
			format.size=12;
			format.font='_ゴシック';
			format.align='center';
			comment.defaultTextFormat=format
			comment.x=465/2
			comment.y=465/2
			addChild(comment)
			comment.text="音源生成中\nマシンスペックにもよりますが、かなり時間がかかります。";

			source.addEventListener(Event.COMPLETE, loadComplete);
			source.load(new URLRequest(loadData));
		}


		private function loadComplete(event:Event):void {

			//鍵盤の作成
			var keyArray:Array=[];
			white=new Sprite()
			black=new Sprite()
			white.scaleX=white.scaleY=0.65;
			black.scaleX=black.scaleY=0.65;
			white.x=4;
			black.x=4;
			white.y=150;
			black.y=150;

			var counter:uint=0;
			var oldCounter:uint=99;
			addEventListener(Event.ENTER_FRAME, onRenderTick);

			function setKey():void {
				oldCounter=counter
				keyArray[counter]=new Keyboard(counter,source)

				if (keyArray[counter].color) {
					black.addChild(keyArray[counter])
				} else {
					white.addChild(keyArray[counter])
				}
				keyArray[counter].addEventListener(Keyboard.MAKE_SOUND_END, nextKey);
				keyArray[counter].makeSound()
			}

			function nextKey():void {
				keyArray[counter].removeEventListener(Keyboard.MAKE_SOUND_END, nextKey);
				counter++;
				if (counter>=24) {
					addChild(white)
					addChild(black)
					removeEventListener(Event.ENTER_FRAME, onRenderTick);
					removeChild(comment)
				}
			}

			function onRenderTick(e:Event):void {
				if (counter!=oldCounter) {
					catWalk(counter,1,0xFFFFFF)
					setKey()
				}
			}

		}


		private function catWalk(id:uint,alpha:Number=1,color:uint=0x333333):void {
			var mark:Shape = new Shape()
			mark.scaleX=0.5
			mark.scaleY=0.5
			mark.graphics.beginFill(color,alpha)
			mark.graphics.moveTo(-10,-4)
			mark.graphics.curveTo(-10,-15,-4,-10)
			mark.graphics.lineTo(-1,-6)
			mark.graphics.lineTo(5,-4)
			mark.graphics.curveTo(9,0,5,4)
			mark.graphics.lineTo(-1,6)
			mark.graphics.lineTo(-4,10)
			mark.graphics.curveTo(-10,15,-10,4)
			mark.graphics.endFill()
			mark.graphics.beginFill(color,alpha)
			mark.graphics.drawEllipse(3-5,-10-4,10,8)
			mark.graphics.drawEllipse(12-5,-4.5-4,10,8)
			mark.graphics.drawEllipse(12-5, 4.5-4,10,8)
			mark.graphics.drawEllipse(3-5, 10-4,10,8)
			mark.graphics.endFill()
			progressVar.addChild(mark)
			mark.x=id*19+10
			mark.y=id%2*10
		}


	}
}



import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.media.Sound;


class Keyboard extends Sprite {
	public static const MAKE_SOUND_END:String = 'make_sound_end';

	private var id:uint=0
	private var source:Sound;
	private var sound:SoundPitchShift;
	public var color:uint=0

	public function Keyboard(_id:uint,_source:Sound) {
		source=_source
		id=_id
		var i:uint
		var n:Array=new Array(	0, 35, 50, 85,100,150,185,200,235,250,285,300,350,385,400,435,450,500,535,550,585,600,635,650)
		var m:Array=new Array(	0,	1,	0,	1,	0,	0,	1,	0,	1,	0,	1,	0,	0,	1,	0,	1,	0,	0,	1,	0,	1,	0,	1,	0)
		var result:Sprite = new Sprite();

		graphics.lineStyle(1,0x000000,1,true)
		if (m[id]) {
			graphics.beginFill(0x000000,1)
			graphics.drawRect(0,0,30,100)
			x=n[id]
		} else {
			graphics.beginFill(0xFFFFFF,1)
			graphics.drawRect(0,0,50,200)
			x=n[id]
		}
		color=m[id]
		addEventListener(MouseEvent.MOUSE_DOWN,onDown)

	}

	private function onDown(e:MouseEvent):void {
		trace('onDown')
		sound.play();
	}


	public function makeSound():void {
		//周波数（1=基準ラ、0.5=位置オクターブ下がる、2=１オクターブ上がる）
		var k:Array=new Array(-12,-11,-10,-9, -8, -7, -6, -5, -4, -3, -2,  -1,	0,	1,	2,	3,	4,	5,	6,	7,	8,	9, 10, 11)
		var key:Number=k[id]
		sound = new SoundPitchShift(source);

		sound.stereo=false//true
		sound.fftFrameSize = 2048/2
		sound.osamp=3

		if (key) {
			sound.pitch=1*Math.pow(2,key/12)
		} else if (key < 0) {
			sound.pitch=1/Math.pow(2,Math.abs(key)/12)
		} else if (!key) {
			sound.pitch=1.01
		}
		trace(sound.pitch)


		sound.makeSound();
		this.dispatchEvent(new Event(MAKE_SOUND_END));
	}

}






import flash.events.Event;
import flash.events.SampleDataEvent;
import flash.media.Sound;
import flash.net.URLRequest;
import flash.utils.ByteArray;
import flash.utils.getTimer;

class SoundPitchShift extends Sprite{
	public var mp3: Sound;
	private var _sound: Sound;
	
	private var _target: ByteArray;
	private var _soundBuffer: ByteArray;
	
	private var _leftChannel:Vector.<Number> = new Vector.<Number>(8192/2);
	private var _rightChannel:Vector.<Number> = new Vector.<Number>(8192/2);
	
	private var _leftPitchShifter:PitchShifter;
	private var _rightPitchShifter:PitchShifter;
	
	public var pitch: Number = 1.0;

	public function SoundPitchShift(source:Sound)
	{
		_target = new ByteArray();
		mp3 = source;
	}

	public function makeSound():void {
		//変調したsoundを作成・保存
		_soundBuffer=onSampleDataAll()
	}
	

	public function play(start:Number=0,loop:uint=0):void {
		//_constructShifters();
		trace('音Start')
		var _target:ByteArray=_soundBuffer
		var _position:Number=0;
		_sound = new Sound();
		_sound.addEventListener( SampleDataEvent.SAMPLE_DATA, onSampleDataRequest);
		_sound.play(start,loop);

		function onSampleDataRequest(e:SampleDataEvent):void {
			var data: ByteArray = e.data;

			_target.position=_position

			var read:int=8192/2
			if (0>_target.length/8-(_target.position/8+read)) {
				read=_target.length/8-(_target.position/8)
			}
			_position+=read*8

			for( var i:int = 0; i < read; ++i )
			{
				data.writeFloat(_target.readFloat()*0.5);
				data.writeFloat(_target.readFloat()*0.5);
			}

		}


	}


	private var _fftFrameSize:int = 1024;
	public function get fftFrameSize():int	{ return _fftFrameSize }
	public function set fftFrameSize(v:int):void
	{
		if (v != _fftFrameSize)
		{
			_fftFrameSize = v;
			_constructShifters();
		}
	}
	
	private var _osamp:int = 4;
	public function get osamp():int	{ return _osamp }
	public function set osamp(v:int):void
	{
		if (v != _osamp)
		{
			_osamp = v;
			_constructShifters();
		}
	}
	
	private var _sampleRate:int = 44100;
	public function get sampleRate():int	{ return _sampleRate }
	public function set sampleRate(v:int):void
	{
		if (v != _sampleRate)
		{
			_sampleRate = v;
			_constructShifters();
		}
	}
	
	private var _stereo:Boolean = false;
	public function get stereo():Boolean	{ return _stereo }
	public function set stereo(v:Boolean):void
	{
		if (_stereo = v)
			_rightPitchShifter = new PitchShifter( _fftFrameSize, _osamp, _sampleRate );
	}
	
	public var settings:String;

	private function _constructShifters():void
	{
		settings = (_stereo?"stereo-":"mono-") + _fftFrameSize + "-" + _osamp + "-" + _sampleRate;
		_cpuFIFO = new Vector.<Number>;
		
		_leftPitchShifter = new PitchShifter( _fftFrameSize, _osamp, _sampleRate );
		if ( _stereo )
			_rightPitchShifter = new PitchShifter( _fftFrameSize, _osamp, _sampleRate );
	}

	
	public var doPitch:Boolean;
	public var doStereo:Boolean;
	
	private var _maxCPUPerSetting:Object = { }
	private var _cpuFIFO:Vector.<Number>;
	private var _cpu:Number = 0.0;

	
	public function get cpu():Number { return _cpu }
	


	public function onSampleDataAll():ByteArray {

		var s:int = getTimer();
		
		//-- SHORTCUT
		var data: ByteArray = new ByteArray();
		
		//-- REUSE INSTEAD OF RECREATION
		_target.position = 0;
		var read: int = mp3.extract( _target, mp3.length / 1000 * 44100,0);
		_target.position = 0;
		trace(read,mp3.length)
		var currentMax:Number = _maxCPUPerSetting[settings];
		if (isNaN(currentMax)) currentMax = 0.0;
		
		doPitch = currentMax < 1.5;
		doStereo = currentMax < 1.0;

		for( var i:int = 0; i < read; ++i )
		{
			if (doStereo)
			{
				_leftChannel[i] = _target.readFloat()*0.5;
				_rightChannel[i] = _target.readFloat()*0.5;
			}
			else
			{
				//-- AVG LEFT AND RIGHT CHANNELS
				_leftChannel[i] = .5 * ( _target.readFloat() + _target.readFloat() ) * 0.5;
			}
		}
		
		if ( doPitch ) {
			_leftPitchShifter.pitchShift( pitch, read, _leftChannel );
			
			if (_stereo && doStereo) {
				_rightPitchShifter.pitchShift( pitch, read, _rightChannel );
			}
		}
		
		for( i = 0 ; i < read ; ++i )
		{
			data.writeFloat( _leftChannel[i] );
			data.writeFloat( _stereo && doStereo ? _rightChannel[i] : _leftChannel[i] );
		}

		_cpu = 0.0;
		_cpuFIFO.unshift( (getTimer() - s) * _sampleRate * 1.220703125E-7 );
		var l:int = _cpuFIFO.length;
		if(l>6) _cpuFIFO.splice( --l, 1 );
		for ( i = 0 ; i < l ; ++i )
			_cpu += _cpuFIFO[i];
		_cpu /= Number(l);
		
		if ( currentMax < _cpu )
			_maxCPUPerSetting[settings] = _cpu;

		return data;

	}
	
}


/****************************************************************************
*
* NAME: PitchShifter.as
* VERSION: 1.0
* HOME URL: http://iq12.com/
* KNOWN BUGS: none
*
* SYNOPSIS: Routine for doing pitch shifting while maintaining
* duration using the Short Time Fourier Transform.
*
* DESCRIPTION: The routine takes a pitchShift factor value which is between 0.5
* (one octave down) and 2. (one octave up). A value of exactly 1 does not change
* the pitch. numSampsToProcess tells the routine how many samples in indata[0...
* numSampsToProcess-1] should be pitch shifted and moved to outdata[0 ...
* numSampsToProcess-1]. The two buffers can be identical (ie. it can process the
* data in-place). fftFrameSize defines the FFT frame size used for the
* processing. Typical values are 1024, 2048 and 4096. It may be any value <=
* MAX_FRAME_LENGTH but it MUST be a power of 2. osamp is the STFT
* oversampling factor which also determines the overlap between adjacent STFT
* frames. It should at least be 4 for moderate scaling ratios. A value of 32 is
* recommended for best quality. sampleRate takes the sample rate for the signal 
* in unit Hz, ie. 44100 for 44.1 kHz audio. The data passed to the routine in 
* indata[] should be in the range [-1.0, 1.0), which is also the output range 
* for the data, make sure you scale the data accordingly (for 16bit signed integers
* you would have to divide (and multiply) by 32768). 
*
* COPYRIGHT 1999-2006 Stephan M. Bernsee <smb [AT] dspdimension [DOT] com>
*
* 						The Wide Open License (WOL)
*
* Permission to use, copy, modify, distribute and sell this software and its
* documentation for any purpose is hereby granted without fee, provided that
* the above copyright notice and this license appear in all source copies. 
* THIS SOFTWARE IS PROVIDED "AS IS" WITHOUT EXPRESS OR IMPLIED WARRANTY OF
* ANY KIND. See http://www.dspguru.com/wol.htm for more information.
*
*****************************************************************************/
 
/****************************************************************************
*
* This code was converted to AS3/FP10 by Arnaud Gatouillat <fu [AT] iq12 [DOT] com>
* from C# code by Michael Knight ( madmik3 at gmail dot com. )
* http://sites.google.com/site/mikescoderama/
* 
*****************************************************************************/

/****************************************************************************
*
* The functions `realft' and `four1' are based on those in Press, W.H., et al.,
* Numerical Recipes in C: the Art of Scientific Computing (Cambridge Univ. Press,
* 1989;  2nd ed., 1992).
* 
*****************************************************************************/

class PitchShifter
{
	private var gInFIFO		:Vector.<Number>;
	private var gOutFIFO	:Vector.<Number>;
	private var gFFTworksp	:Vector.<Number>;
	private var gLastPhase	:Vector.<Number>;
	private var gSumPhase	:Vector.<Number>;
	private var gOutputAccum:Vector.<Number>;
	private var gAnaFreq	:Vector.<Number>;
	private var gAnaMagn	:Vector.<Number>;
	private var gSynFreq	:Vector.<Number>;
	private var gSynMagn	:Vector.<Number>;

	private var freqPerBin:Number, expct:Number;
	private var gRover:int, inFifoLatency:int, stepSize:int, fftFrameSize2:int;
	
	private var fftFrameSize:int, osamp:int, sampleRate:Number;
	
	/* pre-computed values for speed */
	private var windowValues		:Vector.<Number>;
	private var windowValuesFactored:Vector.<Number>;
	private var invPI:Number, invFftFrameSizePI2:Number, osampPI2:Number, invOsampPI2FreqBin:Number;
	
	private var PI:Number		= Math.PI
	private var TWOPI:Number	= 2 * Math.PI

	public function PitchShifter(fftFrameSize:int, osamp:int, sampleRate:Number)
	{
		this.fftFrameSize	= fftFrameSize;
		this.osamp			= osamp;
		this.sampleRate		= sampleRate;
		
		gInFIFO			= new Vector.<Number>(fftFrameSize);
		gOutFIFO		= new Vector.<Number>(fftFrameSize, true);
		gFFTworksp		= new Vector.<Number>(2 * fftFrameSize + 2, true);
		gLastPhase		= new Vector.<Number>(fftFrameSize / 2 + 1, true);
		gSumPhase		= new Vector.<Number>(fftFrameSize / 2 + 1, true);
		gOutputAccum	= new Vector.<Number>(2 * fftFrameSize, true);
		gAnaFreq		= new Vector.<Number>(fftFrameSize, true);
		gAnaMagn		= new Vector.<Number>(fftFrameSize, true);
		gSynFreq		= new Vector.<Number>(fftFrameSize, true);
		gSynMagn		= new Vector.<Number>(fftFrameSize, true);
		
		/* set up some handy variables */
		fftFrameSize2= fftFrameSize / 2;
		stepSize = fftFrameSize / osamp;
		freqPerBin = sampleRate / Number(fftFrameSize);
		expct = 2.0 * PI * Number(stepSize) / Number(fftFrameSize);
		inFifoLatency = fftFrameSize - stepSize;
		
		invPI = 1 / PI;
		invFftFrameSizePI2 = PI * 2 / fftFrameSize;
		osampPI2 = osamp / ( 2 * PI );
		invOsampPI2FreqBin = 1 / ( freqPerBin * osampPI2);
		
		windowValues			= new Vector.<Number>(fftFrameSize);
		windowValuesFactored	= new Vector.<Number>(fftFrameSize);

		var invFftFrameSize2:Number = 2.0 / (fftFrameSize2 * osamp);
		for (var k:int = 0, t:Number = 0.0; k < fftFrameSize; ++k, t += invFftFrameSizePI2)
		{
			var window: Number = -.5 * Math.cos(t) + .5;
			windowValues[k] = window;
			windowValuesFactored[k] = window * invFftFrameSize2;
		}
	}

	public function pitchShift(pitchShift:Number, numSampsToProcess:int, indata:Vector.<Number>):void
	{
		var magn:Number, phase:Number, tmp:Number, window:Number, real:Number, imag:Number, t:Number;
		var i:int, k:int, qpd:int, index:int, n:int;

		var outdata:Vector.<Number> = indata;
		if (gRover == 0) gRover = inFifoLatency;
		
		/* main processing loop */
		for (i = 0; i < numSampsToProcess; ++i)
		{
			/* As long as we have not yet collected enough data just read in */
			gInFIFO[gRover] = indata[i];
			outdata[i] = gOutFIFO[gRover - inFifoLatency];
			++gRover;
			
			/* now we have enough data for processing */
			if (gRover >= fftFrameSize)
			{
				gRover = inFifoLatency;

				/* do windowing and re,im interleave */
				for (k = 0, n = 1; k < fftFrameSize; ++k, ++n)
				{
					gFFTworksp[n] = gInFIFO[k] * windowValues[k];
					gFFTworksp[++n] = 0.0;
				}
				/* ***************** ANALYSIS ******************* */
				/* do transform */
				realft(gFFTworksp, fftFrameSize, -1);
				/* this is the analysis step */
				for (k = 0; k <= fftFrameSize2; ++k)
				{
					/* de-interlace FFT buffer */
					real = gFFTworksp[n = 1 + (k << 1)];
					imag = gFFTworksp[n + 1];

					/* compute magnitude and phase */
					magn = 2.0 * Math.sqrt(real * real + imag * imag);
					phase = Math.atan2(imag, real);

					/* compute phase difference */
					tmp = phase - gLastPhase[k];
					gLastPhase[k] = phase;

					/* subtract expected phase difference */
					tmp -= k * expct;

					/* map delta phase into +/- Pi interval */
					qpd = int(tmp * invPI);
					if (qpd >= 0)	qpd += qpd & 1;
					else			qpd -= qpd & 1;
					tmp -= PI * Number(qpd);

					/* get deviation from bin frequency from the +/- Pi interval */
					tmp *= osampPI2;

					/* compute the k-th partials' true frequency */
					tmp = (k + tmp) * freqPerBin;

					/* store magnitude and true frequency in analysis arrays */
					gAnaMagn[k] = magn;
					gAnaFreq[k] = tmp;

				}
				/* ***************** PROCESSING ******************* */
				/* this does the actual pitch shifting */
				for (var zero:int = 0; zero < fftFrameSize; ++zero)
				{
					gSynMagn[zero] = 0.0;
					gSynFreq[zero] = 0.0;
				}

				for (k = 0, n = pitchShift > 1.0 ? int(fftFrameSize2 / pitchShift) : fftFrameSize2; k <= n; ++k)
				{
					index = int(k * pitchShift);
					gSynMagn[index] += gAnaMagn[k];
					gSynFreq[index] = gAnaFreq[k] * pitchShift;
				}
				/* ***************** SYNTHESIS ******************* */
				/* this is the synthesis step */
				for (k = 0; k <= fftFrameSize2; ++k)
				{
					/* get magnitude and true frequency from synthesis arrays */
					magn = gSynMagn[k];

					/* subtract bin mid frequency */
					/* get bin deviation from freq deviation */
					/* take osamp into account */
					/* add the overlap phase advance back in */
					/* accumulate delta phase to get bin phase */
					phase = (gSumPhase[k] += (gSynFreq[k] - Number(k) * freqPerBin) * invOsampPI2FreqBin + Number(k) * expct);

					/* get real and imag part and re-interleave */
					gFFTworksp[n = 1 + (k << 1)] = magn * Math.cos(phase);
					gFFTworksp[n + 1] = magn * Math.sin(phase);
				}
				
				/* zero negative frequencies */
				for (k = fftFrameSize + 3, n = 1 + (fftFrameSize << 1); k < n; ++k)
				{
					gFFTworksp[k] = 0.0;
				}
				/* do inverse transform */
				realft(gFFTworksp, fftFrameSize, 1);

				/* do windowing and add to output accumulator */
				for (k = 0, n = 1; k < fftFrameSize; ++k, ++n, ++n)
				{
					gOutputAccum[k] += windowValuesFactored[k] * gFFTworksp[n];
				}
				for (k = 0; k < stepSize; ++k)
				{
					gOutFIFO[k] = gOutputAccum[k];
				}

				//memmove(gOutputAccum, gOutputAccum + stepSize, fftFrameSize * sizeof(Number));
				/* shift accumulator */
				/* move input FIFO */
				for (k = 0, n = stepSize; k < inFifoLatency; ++k, ++n)
				{
					gOutputAccum[k] = gOutputAccum[n];
					gInFIFO[k] = gInFIFO[n];
				}
				for ( ;  k < fftFrameSize; ++k, ++n)
				{
					gOutputAccum[k] = gOutputAccum[n];
				}
			}
		}
	}

	private function realft( data:Vector.<Number>, n:int, isign:int ):void
	{
		var i:int, i1:int, i2:int, i3:int, i4:int, n2p3:int;
		var c1:Number = 0.5, c2:Number, h1r:Number, h1i:Number, h2r:Number, h2i:Number;
		var wr:Number, wi:Number, wpr:Number, wpi:Number, wtemp:Number, theta:Number;

		theta = PI/n;
		if (isign == 1)
		{
			c2 = -0.5;
			four1(data, n, 1);
		} 
		else
		{
			c2 = 0.5;
			theta = -theta;
		}
		wtemp = Math.sin(0.5 * theta);
		wpr = -2.0 * wtemp * wtemp;
		wpi = Math.sin(theta);
		wr = 1.0 + wpr;
		wi = wpi;
		n2p3 = 2 * n + 3;
		for (i = 2; i <= n / 2; ++i)
		{
			i4 = 1 + (i3 = n2p3 - (i2 = 1 + ( i1 = i + i - 1)));
			h1r =  c1 * (data[i1] + data[i3]);
			h1i =  c1 * (data[i2] - data[i4]);
			h2r = -c2 * (data[i2] + data[i4]);
			h2i =  c2 * (data[i1] - data[i3]);
			data[i1] =	h1r + wr * h2r - wi * h2i;
			data[i2] =	h1i + wr * h2i + wi * h2r;
			data[i3] =	h1r - wr * h2r + wi * h2i;
			data[i4] = -h1i + wr * h2i + wi * h2r;
			wr = (wtemp = wr) * wpr - wi * wpi + wr;
			wi = wi * wpr + wtemp * wpi + wi;
		}
		if (isign == 1)
		{
			data[1] = (h1r = data[1]) + data[2];
			data[2] = h1r - data[2];
		}
		else
		{
			data[1] = c1 * ((h1r = data[1]) + data[2]);
			data[2] = c1 * (h1r - data[2]);
			four1(data, n, -1);
			data=data;
		}
	}

	private function four1(data:Vector.<Number>, nn:int, isign:int):void
	{
		var n:int, mmax:int, m:int, j:int, istep:int, i:int;
		var wtemp:Number, wr:Number, wpr:Number, wpi:Number, wi:Number, theta:Number;
		var tempr:Number, tempi:Number;
		var j1:int, i1:int;
		n = nn << 1;
		j = 1;
		for (i = 1; i < n; i += 2)
		{
			if (j > i)
			{
				j1 = j + 1;
				i1 = i + 1;
				tempr = data[j];	data[j] = data[i];		data[i] = tempr;
				tempr = data[j1];	data[j1] = data[i1];	data[i1] = tempr;
			}
			m = n >> 1;
			while (m >= 2 && j > m)
			{
				j -= m;
				m >>= 1;
			}
			j += m;
		}
		mmax = 2;
		while (n > mmax)
		{
			istep = 2 * mmax;
			theta = TWOPI / (isign * mmax);
			wtemp = Math.sin(0.5 * theta);
			wpr = -2.0 * wtemp * wtemp;
			wpi = Math.sin(theta);
			wr = 1.0;
			wi = 0.0;
			for (m = 1; m < mmax; m += 2)
			{
				for (i = m; i <= n; i += istep)
				{
					i1 = i +1;
					j1 = 1+ (j = i + mmax);
					tempr = wr*data[j]	 - wi*data[j1];
					tempi = wr*data[j1]  + wi*data[j];
					data[j] 	= data[i] 	- tempr;
					data[j1]	= data[i1]	- tempi;
					data[i]  += tempr;
					data[i1] += tempi;
				}
				wr = (wtemp = wr) * wpr - wi * wpi + wr;
				wi = wi * wpr + wtemp * wpi + wi;
			}
			mmax = istep;
		}
	}

}


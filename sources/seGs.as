// forked from k__'s Pitch Shifter
package {
import flash.display.*;
import flash.events.*;
import flash.net.*;
import flash.text.*;
import flash.ui.*;
import flash.utils.ByteArray;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.utils.getTimer;

public class Main extends Sprite {
	var progTxt:TextField;
	var levelTxt:TextField;
	var level:int = 0;
	var sourceSound:Sound;
	var sound:Sound;
	var soundURL:String = "http://www.kynd.info/flash/sound/jazz.mp3";
	var channel:SoundChannel;
	var pitchRatio:Number;

	public function Main() {
		sound = new Sound();
		sourceSound = new Sound();
		sound.addEventListener(SampleDataEvent.SAMPLE_DATA,h_sampleData);
		sourceSound.addEventListener(ProgressEvent.PROGRESS,h_loadProgress);
		sourceSound.addEventListener(Event.COMPLETE,h_loadComplete);
		sourceSound.load(new URLRequest(soundURL));
		setUI();
	}

	private function setUI():void {
		addChild(progTxt = new TextField());
		var tf:TextFormat = new TextFormat();
		tf.size = 24;
		tf.font = "_sans";
		tf.color = 0xdddddd;
		progTxt.defaultTextFormat = tf;
		progTxt.x = 22;
		progTxt.y = 20;
		progTxt.width = 420;

		addChild(levelTxt = new TextField());
		tf.size = 60;
		tf.color = 0x333333;
		levelTxt.defaultTextFormat = tf;
		levelTxt.x = 20;
		levelTxt.y = 60;
		levelTxt.width = 420;
		updateLevelTxt();

		var msgTxt:TextField;
		addChild(msgTxt = new TextField());
		tf.size = 18;
		msgTxt.defaultTextFormat = tf;
		msgTxt.x = 22;
		msgTxt.y = 120;
		msgTxt.width = 420;
		msgTxt.text = "use up/down arrow keys to change the value";

		stage.addEventListener(KeyboardEvent.KEY_DOWN, h_keyDown)
	}

	private function h_keyDown(evt:KeyboardEvent):void {
		if (evt.keyCode == Keyboard.DOWN && level > -5) {
			level --;
		}
		if (evt.keyCode == Keyboard.UP && level < 10) {
			level ++;
		}
		updateLevelTxt();
	}

	private function updateLevelTxt():void {
		levelTxt.text = "Pitch: " + ((level > 0) ? "+" : "") + level;
	}

	/* load MP3 File */
	private function h_loadProgress(evt:ProgressEvent):void {
		var loaded:uint = evt.bytesLoaded;
		var total:uint = evt.bytesTotal;
		var msg:String = "Loading " + Math.floor(loaded / total * 100)+ "%";
		progTxt.text = msg;
	}

	private function h_loadComplete(evt:Event):void {
		var msg:String = "Load Complete";
		progTxt.text = msg;
		playSound();
	}

	/* sound playback */
	private function playSound():void {
		channel = sound.play();
		channel.addEventListener(Event.SOUND_COMPLETE, h_soundComplete);
	}

	private function h_soundComplete(evt:Event):void {
		playSound();
	}

	private function h_sampleData(evt:SampleDataEvent):void {
		var bytes:ByteArray = new ByteArray();
		var avail:Number;
		avail = sourceSound.extract(bytes, 8192);
		if (avail == 0) {
			sourceSound.extract(bytes, 8192, 0);
		}
		evt.data.writeBytes(processSound(bytes));
	}

	private var samples:Vector.<Number> = new Vector.<Number>();
	private function processSound(bytes:ByteArray):ByteArray {
		var returnBytes:ByteArray = new ByteArray();
		bytes.position = 0;
		var n:int = 0;
		while(bytes.bytesAvailable > 0) {
			// pitch shift is expensive, so we convert to mono
			samples[n] = 0.5 * (bytes.readFloat() + bytes.readFloat());
			n++;
		}

//		var t:int = getTimer();
		// oversampling below 5 gives shitty quality (original author recommends 32 :)
		// unfortunately good old flash is too slow, so we use oversampling = 3
		SMB.PitchShift(1 + 0.1 * level, n, 2048, 3, 44100, samples, samples);
//		trace("spent:",getTimer()-t,"ms");

		for (var i:int = 0; i < n; i++) {
			returnBytes.writeFloat(samples[i]);
			returnBytes.writeFloat(samples[i]);
		}
		return returnBytes;
	}

}
}

/****************************************************************************
 *
 * NAME: smbPitchShift.cpp
 * VERSION: 1.2
 * HOME URL: http://www.dspdimension.com
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
 * COPYRIGHT 1999-2009 Stephan M. Bernsee <smb [AT] dspdimension [DOT] com>
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

class SMB {

	public static const MAX_FRAME_LENGTH:int = 8192;

	private static var gInFIFO:Vector.<Number> = new Vector.<Number> (MAX_FRAME_LENGTH);
	private static var gOutFIFO:Vector.<Number> = new Vector.<Number> (MAX_FRAME_LENGTH);
	private static var gLastPhase:Vector.<Number> = new Vector.<Number> (MAX_FRAME_LENGTH/2+1);
	private static var gSumPhase:Vector.<Number> = new Vector.<Number> (MAX_FRAME_LENGTH/2+1);
	private static var gOutputAccum:Vector.<Number> = new Vector.<Number> (2*MAX_FRAME_LENGTH);
	private static var gAnaFreq:Vector.<Number> = new Vector.<Number> (MAX_FRAME_LENGTH);
	private static var gAnaMagn:Vector.<Number> = new Vector.<Number> (MAX_FRAME_LENGTH);
	private static var gSynFreq:Vector.<Number> = new Vector.<Number> (MAX_FRAME_LENGTH);
	private static var gSynMagn:Vector.<Number> = new Vector.<Number> (MAX_FRAME_LENGTH);

	private static function init():void {
		for each (var v:Vector.<Number> in new <Vector.<Number>> [
			gInFIFO, gOutFIFO, gLastPhase, gSumPhase, gOutputAccum, gAnaFreq, gAnaMagn
		]) for (var i:int = 0, n:int = v.length; i < n; i++) v[i] = 0;
	}

	{
		/* initialize our static arrays */
		init();
	}

	private static var gRover:int = 0;


	private static var gWindow:Vector.<Number> = new Vector.<Number>();

	/**
	 * Original at http://www.dspdimension.com/admin/pitch-shifting-using-the-ft/
	 *
	 * Funny properties of original code:
	 * - relies on broken inverse fft;
	 * - has significant lag after incoming signal;
	 * - output is louder and biased;
	 * - any oversampling values below 5 are basically crap.
	 */
	public static function PitchShift(pitchShift:Number, numSampsToProcess:int, fftFrameSize:int, osamp:int, sampleRate:Number, indata:Vector.<Number>, outdata:Vector.<Number>):void {

		// but first, let's cache window calsulations...
		if (fftFrameSize != gWindow.length) {
			gWindow.length = fftFrameSize;
			for (k = 0; k < fftFrameSize;k++) {
				gWindow[k] = -0.5*Math.cos(2.0*Math.PI*k/fftFrameSize)+0.5;
			}
		}

		// ...and prepare fft
		if (fft2 == null) {
			fft2 = new FFT2();
		}
		fft2.logN = Math.log(fftFrameSize)/Math.log(2) + 0.5;
		xre.length = fftFrameSize;
		xim.length = fftFrameSize;


		var magn:Number, phase:Number, tmp:Number, window:Number, real:Number, imag:Number, freqPerBin:Number, expct:Number;
		var i:int, k:int, qpd:int, index:int, inFifoLatency:int, stepSize:int, fftFrameSize2:int;

		/* set up some handy variables */
		fftFrameSize2 = fftFrameSize/2;
		stepSize = fftFrameSize/osamp;
		freqPerBin = sampleRate/Number(fftFrameSize);
		expct = 2.0*Math.PI*stepSize/fftFrameSize;
		inFifoLatency = fftFrameSize-stepSize;
		if (gRover == 0) gRover = inFifoLatency;

		/* main processing loop */
		for (i = 0; i < numSampsToProcess; i++) {

			/* As long as we have not yet collected enough data just read in */
			gInFIFO[gRover] = indata[i];
			outdata[i] = gOutFIFO[gRover-inFifoLatency];
			gRover++;

			/* now we have enough data for processing */
			if (gRover >= fftFrameSize) {
				gRover = inFifoLatency;

				/* do windowing and re,im */
				for (k = 0; k < fftFrameSize;k++) {
					window = gWindow[k];
					xre[k] = gInFIFO[k] * window;
					xim[k] = 0.0;
				}


				/* ***************** ANALYSIS ******************* */
				/* do transform */
				fft2.run(xre, xim, false);

				/* this is the analysis step */
				for (k = 0; k <= fftFrameSize2; k++) {

					/* de-interlace FFT buffer */
					real = xre[k];
					imag = xim[k];

					/* compute magnitude and phase */
					magn = 2.0*Math.sqrt(real*real + imag*imag);
					phase = Math.atan2(imag,real);

					/* compute phase difference */
					tmp = phase - gLastPhase[k];
					gLastPhase[k] = phase;

					/* subtract expected phase difference */
					tmp -= k*expct;

					/* map delta phase into +/- Pi interval */
					qpd = tmp/Math.PI;
					if (qpd >= 0) qpd += qpd&1; else qpd -= qpd&1;
					tmp -= Math.PI*qpd;

					/* get deviation from bin frequency from the +/- Pi interval */
					tmp = osamp*tmp/(2.0*Math.PI);

					/* compute the k-th partials' true frequency */
					tmp = k*freqPerBin + tmp*freqPerBin;

					/* store magnitude and true frequency in analysis arrays */
					gAnaMagn[k] = magn;
					gAnaFreq[k] = tmp;

				}

				/* ***************** PROCESSING ******************* */
				/* this does the actual pitch shifting */
				for (k = 0; k < fftFrameSize; k++) {
					gSynMagn[k] = 0;
					gSynFreq[k] = 0;
				}
				for (k = 0; k <= fftFrameSize2; k++) {
					index = k*pitchShift;
					if (index <= fftFrameSize2) {
						gSynMagn[index] += gAnaMagn[k];
						gSynFreq[index] = gAnaFreq[k] * pitchShift;
					}
				}

				/* ***************** SYNTHESIS ******************* */
				/* this is the synthesis step */
				for (k = 0; k <= fftFrameSize2; k++) {

					/* get magnitude and true frequency from synthesis arrays */
					magn = gSynMagn[k];
					tmp = gSynFreq[k];

					/* subtract bin mid frequency */
					tmp -= k*freqPerBin;

					/* get bin deviation from freq deviation */
					tmp /= freqPerBin;

					/* take osamp into account */
					tmp = 2.0*Math.PI*tmp/osamp;

					/* add the overlap phase advance back in */
					tmp += k*expct;

					/* accumulate delta phase to get bin phase */
					gSumPhase[k] += tmp;
					phase = gSumPhase[k];

					/* get real and imag part */
					xre[k] = magn*Math.cos(phase);
					xim[k] = magn*Math.sin(phase);
				}

				/* zero negative frequencies */
				for (k = fftFrameSize2 + 1; k < fftFrameSize; k++) {
					xre[k] = 0;
					xim[k] = 0;
				}

				/* do inverse transform */
				fft2.run(xre, xim, true);

				/* do windowing and add to output accumulator */
				for(k=0; k < fftFrameSize; k++) {
					window = gWindow[k];
					gOutputAccum[k] += 2.0*window*xre[k]/(fftFrameSize2*osamp);
				}
				for (k = 0; k < stepSize; k++) {
					gOutFIFO[k] = gOutputAccum[k];
				}

				/* shift accumulator */
				for (k = 0; k < fftFrameSize; k++) {
					gOutputAccum[k] = gOutputAccum[k + stepSize];
				}

				/* move input FIFO */
				for (k = 0; k < inFifoLatency; k++) {
					gInFIFO[k] = gInFIFO[k+stepSize];
				}
			}
		}
	}

	private static var xre:Vector.<Number> = new Vector.<Number>();
	private static var xim:Vector.<Number> = new Vector.<Number>();
	private static var fft2:FFT2;
}


/**
 * Performs an in-place complex FFT.
 *
 * Released under the MIT License
 *
 * Copyright (c) 2010 Gerald T. Beauregard
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to
 * deal in the Software without restriction, including without limitation the
 * rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
 * sell copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
 * IN THE SOFTWARE.
 */
class FFT2
{
	public static const FORWARD:Boolean = false;
	public static const INVERSE:Boolean = true;

	private var m_logN:uint = 0;            // log2 of FFT size

	public function get logN():uint { return m_logN }
	public function set logN(v:uint):void { if (m_logN != v) init(v); }

	private var m_N:uint = 0;               // FFT size
	private var m_invN:Number;              // Inverse of FFT length

	private var m_X:Vector.<FFTElement>;  // Vector of linked list elements

	/**
	 *
	 */
	public function FFT2()
	{
	}

	/**
	 * Initialize class to perform FFT of specified size.
	 *
	 * @param   logN    Log2 of FFT length. e.g. for 512 pt FFT, logN = 9.
	 */
	public function init(
			logN:uint ):void
	{
		m_logN = logN
		m_N = 1 << m_logN;
		m_invN = 1.0/m_N;

		// Allocate elements for linked list of complex numbers.
		m_X = new Vector.<FFTElement>(m_N);
		for ( var k:uint = 0; k < m_N; k++ )
			m_X[k] = new FFTElement;

		// Set up "next" pointers.
		for ( k = 0; k < m_N-1; k++ )
			m_X[k].next = m_X[k+1];

		// Specify target for bit reversal re-ordering.
		for ( k = 0; k < m_N; k++ )
			m_X[k].revTgt = BitReverse(k,logN);
	}

	/**
	 * Performs in-place complex FFT.
	 *
	 * @param   xRe     Real part of input/output
	 * @param   xIm     Imaginary part of input/output
	 * @param   inverse If true (INVERSE), do an inverse FFT
	 */
	public function run(
			xRe:Vector.<Number>,
			xIm:Vector.<Number>,
			inverse:Boolean = false ):void
	{
		var numFlies:uint = m_N >> 1; // Number of butterflies per sub-FFT
		var span:uint = m_N >> 1;     // Width of the butterfly
		var spacing:uint = m_N;         // Distance between start of sub-FFTs
		var wIndexStep:uint = 1;        // Increment for twiddle table index

		// Copy data into linked complex number objects
		// If it's an IFFT, we divide by N while we're at it
		var x:FFTElement = m_X[0];
		var k:uint = 0;
/*
	pitch shifter is expecting broken inverse fft, so...

		var scale:Number = inverse ? m_invN : 1.0;
*/
		while (x)
		{
			x.re = /*scale**/xRe[k];
			x.im = /*scale**/xIm[k];
			x = x.next;
			k++;
		}

		// For each stage of the FFT
		for ( var stage:uint = 0; stage < m_logN; ++stage )
		{
			// Compute a multiplier factor for the "twiddle factors".
			// The twiddle factors are complex unit vectors spaced at
			// regular angular intervals. The angle by which the twiddle
			// factor advances depends on the FFT stage. In many FFT
			// implementations the twiddle factors are cached, but because
			// vector lookup is relatively slow in ActionScript, it's just
			// as fast to compute them on the fly.
			var wAngleInc:Number = wIndexStep * 2.0*Math.PI/m_N;
			if ( inverse == false ) // Corrected 3 Aug 2011. Had this condition backwards before, so FFT was IFFT, and vice-versa!
				wAngleInc *= -1;
			var wMulRe:Number = Math.cos(wAngleInc);
			var wMulIm:Number = Math.sin(wAngleInc);

			for ( var start:uint = 0; start < m_N; start += spacing )
			{
				var xTop:FFTElement = m_X[start];
				var xBot:FFTElement = m_X[start+span];

				var wRe:Number = 1.0;
				var wIm:Number = 0.0;

				// For each butterfly in this stage
				for ( var flyCount:uint = 0; flyCount < numFlies; ++flyCount )
				{
					// Get the top & bottom values
					var xTopRe:Number = xTop.re;
					var xTopIm:Number = xTop.im;
					var xBotRe:Number = xBot.re;
					var xBotIm:Number = xBot.im;

					// Top branch of butterfly has addition
					xTop.re = xTopRe + xBotRe;
					xTop.im = xTopIm + xBotIm;

					// Bottom branch of butterly has subtraction,
					// followed by multiplication by twiddle factor
					xBotRe = xTopRe - xBotRe;
					xBotIm = xTopIm - xBotIm;
					xBot.re = xBotRe*wRe - xBotIm*wIm;
					xBot.im = xBotRe*wIm + xBotIm*wRe;

					// Advance butterfly to next top & bottom positions
					xTop = xTop.next;
					xBot = xBot.next;

					// Update the twiddle factor, via complex multiply
					// by unit vector with the appropriate angle
					// (wRe + j wIm) = (wRe + j wIm) x (wMulRe + j wMulIm)
					var tRe:Number = wRe;
					wRe = wRe*wMulRe - wIm*wMulIm;
					wIm = tRe*wMulIm + wIm*wMulRe;
				}
			}

			numFlies >>= 1;   // Divide by 2 by right shift
			span >>= 1;
			spacing >>= 1;
			wIndexStep <<= 1;     // Multiply by 2 by left shift
		}

		// The algorithm leaves the result in a scrambled order.
		// Unscramble while copying values from the complex
		// linked list elements back to the input/output vectors.
		x = m_X[0];
		while (x)
		{
			var target:uint = x.revTgt;
			xRe[target] = x.re;
			xIm[target] = x.im;
			x = x.next;
		}
	}

	/**
	 * Do bit reversal of specified number of places of an int
	 * For example, 1101 bit-reversed is 1011
	 *
	 * @param   x       Number to be bit-reverse.
	 * @param   numBits Number of bits in the number.
	 */
	private function BitReverse(
			x:uint,
			numBits:uint):uint
	{
		var y:uint = 0;
		for ( var i:uint = 0; i < numBits; i++)
		{
			y <<= 1;
			y |= x & 0x0001;
			x >>= 1;
		}
		return y;
	}
}

class FFTElement
{
	public var re:Number = 0.0;         // Real component
	public var im:Number = 0.0;         // Imaginary component
	public var next:FFTElement = null;  // Next element in linked list
	public var revTgt:uint;             // Target position post bit-reversal
}
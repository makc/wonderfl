package 
{
	import flash.display.*;
	import flash.events.*;
	import flash.filters.BlurFilter;
	import flash.geom.*;
	
	[SWF(width = "465", height = "465", backgroundColor = 0xffffff, frameRate = "60")]
	
	public class DSG_study extends Sprite 
	{
		public function DSG_study() 
		{			
			var bmd:BitmapData = new BitmapData(stage.stageWidth, stage.stageHeight, false, 0);
			addChild(new Bitmap(bmd));
			var bf:BlurFilter = new BlurFilter();
			addEventListener(Event.ENTER_FRAME, function ():void 
			{
				bmd.applyFilter(bmd, bmd.rect, bmd.rect.topLeft, bf);
			});
			stage.addEventListener(MouseEvent.MOUSE_DOWN, function ():void 
			{
				var d:DSG_Shape = new DSG_Shape();
				d.x = mouseX;
				d.y = mouseY;
				addChild(d);
				d.addEventListener(MouseEvent.MOUSE_UP, function():void 
				{
				bmd.draw(d, new Matrix(1,0,0,1, d.x,d.y))
				});
				
				d.addEventListener(Event.COMPLETE, function():void 
				{
					removeChild(d);
					d.removeEventListener(Event.COMPLETE, arguments.callee); 
					d = null;
				});				
			});			
		}
	}
}
import flash.display.*;
import flash.events.*;
import flash.geom.*;
import caurina.transitions.Tweener;
import flash.media.Sound;
class DSG_Shape
extends Shape
{
	private static const BUFFER_LENGTH:uint = 2048;
	private static const SAMPLING_RATE:Number = 44100;
	private static const PI2:Number = Math.PI * 2;
	private var radius:Number = 20;
	private var snd:Sound;
	private var phase:Number = 0;
	private var freq:Number;
	public var amp:Number = 0;
	public function DSG_Shape():void 
	{
		freq =  440 * Math.pow(2, Math.floor((Math.random()-0.5)*80) / 12);
		addEventListener(Event.ADDED_TO_STAGE, init);
	}
	private function init(e:Event):void 
	{
		removeEventListener(Event.ADDED_TO_STAGE, init);
		
		snd = new Sound();
		snd.addEventListener(SampleDataEvent.SAMPLE_DATA, sampleDataHandler);
		snd.play();

		addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		
		stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
	}
	private function enterFrameHandler(e:Event):void 
	{
		x += mouseX * 0.1;
		y += mouseY * 0.1;
		amp = (amp + 0.01) * 1.01;
	}
	private function mouseUpHandler(e:MouseEvent):void 
	{
		dispatchEvent(new Event(MouseEvent.MOUSE_UP));
		stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
		
			Tweener.addTween(this, {
				y : y + height*0.25,
				alpha: 0,
				time:5.0,
				amp: 0,
				onComplete: function ():void 
				{
					graphics.clear();
					snd.removeEventListener(SampleDataEvent.SAMPLE_DATA, sampleDataHandler);
					dispatchEvent(new Event(Event.COMPLETE));
				}
			});
	}
    private function sampleDataHandler(e:SampleDataEvent):void {
		
		var step:Number = freq / SAMPLING_RATE * PI2;
		var samples:Array = [];
		for (var i:int = 0; i < BUFFER_LENGTH; i++)
		{
			var sample:Number = Math.sin(phase += step) * amp;
			e.data.writeFloat(sample);
			e.data.writeFloat(sample);
			samples.push(sample);
		}
		
		var len:uint = 1024;
		var left:Number = -len / 2 * amp*2;
		var g:Graphics = graphics;
		g.clear();
		g.lineStyle(Math.max(2, 0.1*amp/freq*SAMPLING_RATE), 0xffffff);
		g.moveTo(left, 0)
		for ( i = 0; i < len; i++)
		{
			g.lineTo( left + i * amp * 2, samples[i] * 600 * Math.cos(Math.abs(i/len - 0.5)*Math.PI));
		}
	}
}
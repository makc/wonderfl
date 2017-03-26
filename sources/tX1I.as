package  
{
	import flash.display.*;
	import flash.media.*;
	import flash.events.*;
	import flash.events.SampleDataEvent;
	import flash.net.*;
	import flash.utils.ByteArray;
	
	public class ElasticSample extends Sprite
	{
		
		//private var loadData:String = "http://thecoolmuseum.cool.ne.jp/media/intro.mp3";
		//private var loadData:String = "http://thecoolmuseum.cool.ne.jp/media/intro2.mp3";
		private var loadData:String = "http://thecoolmuseum.cool.ne.jp/media/intro3.mp3";
		//private var loadData:String = "http://thecoolmuseum.cool.ne.jp/music/future.mp3";

		private var source:Sound = new Sound();
		private var sound:Sound = new Sound();
		
		private var sampleTable:ByteArray = new ByteArray();
		private var delayBuffer:ByteArray = new ByteArray();
		
		private var bufferLength:int = 2048;
		private var delayTime:int = 300;
			
		public function ElasticSample() 
		{
			source.addEventListener(Event.COMPLETE, loadComplete);
			source.load(new URLRequest(loadData));
		}

		private function player(event:SampleDataEvent):void {
			var speed:Number = (stage.mouseX - stage.stageWidth/2) / stage.stageWidth*4;
			var level:Number = (stage.mouseY - stage.stageHeight/2) / stage.stageHeight;
			var pos:Number = sampleTable.position / 8;
			var length:Number = sampleTable.length / 8;
			for (var i:int = 0; i < bufferLength; i++ ) {
				pos += speed;
				if (pos > length-1 && speed>0)
				{
					pos += 2;
					pos %= length;
				}
				if (pos <= 0 && speed<0)
				{
					pos %= length;
					pos += length - 1;
				}
				
				sampleTable.position = Math.round(pos) * 8;
				var left:Number = sampleTable.readFloat() + delayBuffer.readFloat() * level;
				var right:Number = sampleTable.readFloat() + delayBuffer.readFloat() * level;
				delayBuffer.position -= 8;
				delayBuffer.writeFloat(left);
				delayBuffer.writeFloat(right);
				if (delayBuffer.position >= delayBuffer.length - 8)
				{
					delayBuffer.position = 0;
				}
				event.data.writeFloat(left*0.25);
				event.data.writeFloat(right * 0.25);
			}
		}
		
		private function loadComplete(event:Event):void
		{
			graphics.lineStyle(1);
			graphics.moveTo(0, stage.stageHeight / 2);
			graphics.lineTo(stage.stageWidth, stage.stageHeight / 2);
			graphics.moveTo(stage.stageWidth/2, 0);
			graphics.lineTo(stage.stageWidth/2, stage.stageHeight);
			graphics.drawRect(stage.stageWidth/4,stage.stageHeight/4,stage.stageWidth/2,stage.stageHeight/2)
		
			for (var i:int = 0; i < delayTime / 1000 * 44100; i++ ){
				delayBuffer.writeFloat(0);
				delayBuffer.writeFloat(0);
			}
			delayBuffer.position = 0;
			
			sampleTable.position = 0;
			source.extract(sampleTable, source.length / 1000 * 44100, 0);
			sampleTable.position = 0;
				sound.addEventListener("sampleData", player);
			trace("play");
			sound.play();
		}
	}
	
}
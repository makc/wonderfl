package {
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.text.*;
	import flash.ui.*;
	import flash.utils.ByteArray;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.media.SoundMixer;
	
	public class Main extends Sprite {
		var progTxt:TextField;
		var levelTxt:TextField;
		var level:uint = 0;
		var fr:FileReference;
		var soundData:ByteArray;
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
			if (evt.keyCode == Keyboard.DOWN && level > 0) {
				level --;
			}
			if (evt.keyCode == Keyboard.UP && level < 24) {
				level ++;
			}
			pitchRatio = Math.pow(2, level / 12);
			updateLevelTxt();
		}
		
		private function updateLevelTxt():void {
			levelTxt.text = "Pitch: +" + level;
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
		
		private function processSound(bytes:ByteArray):ByteArray {
			var returnBytes:ByteArray = new ByteArray(); 
			bytes.position = 0;
			var cnt:Number = 0;
			var threshold:Number = 0;
			while(bytes.bytesAvailable > 0) { 
				returnBytes.writeFloat(bytes.readFloat()); 
				returnBytes.writeFloat(bytes.readFloat()); 
				cnt += 1 - 1 / pitchRatio;
				while (bytes.bytesAvailable > 0 && cnt >= threshold) { 
					bytes.position += 8;
					threshold += 1;
					cnt += 1 - 1 / pitchRatio;
				}
			}
			return returnBytes;
		}
		
	}
}
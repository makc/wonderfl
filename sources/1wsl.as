package
{
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	import flash.net.*;
	import flash.utils.ByteArray;
	import mx.utils.Base64Decoder;
	
	[SWF(width="465", height="465", frameRate="24")]
	public class test extends Sprite
	{
		private var button:Sprite = new Sprite();
		private var buttontext:TextField = new TextField();
		private var fileReference:FileReference;
		
		private var textfield:TextField = new TextField();
		
		private var midi:SMFSequence;
		
		function test()
		{
			textfield.width = 465
			textfield.height = 465-30;
			textfield.y = 30;
			textfield.wordWrap = true;
			addChild(textfield);
			
			var decoder:Base64Decoder = new Base64Decoder();
			decoder.decode(SMFBinary.data);
			
			var ba:ByteArray = decoder.toByteArray();
			ba.uncompress();
			
			midi = new SMFSequence(ba);
			textfield.text = midi.toString();
			
			button.x = 5;
			button.y = 5;
			button.mouseChildren = false;
			button.buttonMode = true;
			button.graphics.lineStyle(1, 0xBBBBBB);
			button.graphics.beginFill(0xEEEEEE);
			button.graphics.drawRoundRect(0, 0, 100, 20, 5, 5);
			button.graphics.endFill();
			addChild(button);
			
			buttontext = new TextField();
			buttontext.width = 100;
			buttontext.height = 20;
			buttontext.htmlText = "<p align='center'><font face='_sans'>開く</span></p>";
			button.addChild(buttontext);
			
			fileReference = new FileReference();
			fileReference.addEventListener(Event.SELECT, onSelect);
			fileReference.addEventListener(Event.COMPLETE, onComplete);
			button.addEventListener(MouseEvent.CLICK, onClick);
		}
		
		private function onClick(event:MouseEvent):void 
		{
			fileReference.browse([new FileFilter("MIDIシーケンス(mid)", "*.mid")]);
		}
		
		private function onSelect(event:Event):void
		{
			fileReference.load();
		}
		
		private function onComplete(event:Event):void
		{
			midi = new SMFSequence(fileReference.data);
			textfield.text = midi.toString();
		}
	}
}

	import flash.utils.ByteArray;
	
	class SMFSequence
	{
		public var format:int;
		public var numTracks:int;
		public var division:int;
		public var tempo:int = 0;
		public var title:String = "";
		public var artist:String = "";
		public var signature_n:int;
		public var signature_d:int;
		public var length:int;
		
		public var tracks:Vector.<SMFTrack> = new Vector.<SMFTrack>();
		
		function SMFSequence(bytes:ByteArray)
		{
			bytes.position = 0;
			
			while(bytes.bytesAvailable > 0)
			{
				var type:String = bytes.readMultiByte(4, "us-ascii");
				switch(type)
				{
				case "MThd":	//ヘッダ
					bytes.position += 4;	//ヘッダのデータ長は常に00 00 00 06なのでスルー
					format = bytes.readUnsignedShort();
					numTracks = bytes.readUnsignedShort();
					division = bytes.readUnsignedShort();
					break;
				case "MTrk":	//トラック
					var len:uint = bytes.readUnsignedInt();
					var temp:ByteArray = new ByteArray();
					bytes.readBytes(temp, 0, len);
					var track:SMFTrack = new SMFTrack(this, temp);
					tracks.push(track);
					length = Math.max(length, track.length);
					break;
				default:
					return;
				}
			}
		}
		
		public function toString():String
		{
			var text:String = "format : "+format+" | numTracks : "+numTracks+" | division : "+division+"\n";
			text += "タイトル : "+title+" | 著作権表示 : "+artist+"\n";
			text += "拍子 : "+signature_d+"分の"+signature_n+"拍子 | BPM : "+tempo+" | length : "+length+"\n";
			
			text += "\n";
			
			for(var i:int = 0; i < tracks.length; i++)
			{
				text += "トラック"+i+" : "+tracks[i].toString() + "\n";
			}
			
			return text;
		}
	}

	class SMFTrack
	{
		public var parent:SMFSequence;
		public var sequence:Vector.<SMFEvent> = new Vector.<SMFEvent>();
		public var length:int;
		
		function SMFTrack(parent:SMFSequence, bytes:ByteArray)
		{
			this.parent = parent;
			
			var event:SMFEvent;
			var temp:int;
			var len:int;
			
			var type:int;
			var channel:int;
			
			var time:int;
			/*
			var readVariableLength:Function = function(time:uint = 0):uint
			{
				var temp:uint = bytes.readUnsignedByte();
				if(temp & 0x80) {return readVariableLength(time + (temp & 0x7F));}
				else {return time + (temp & 0x7F);}
			}
			*/
			var readVariableLength:Function = function(time:uint = 0):uint
			{
				var temp:uint = bytes.readUnsignedByte();
				if(temp & 0x80) {return readVariableLength((time << 7) + (temp & 0x7F));}
				else {return (time << 7) + (temp & 0x7F);}
			}
			
			main : while(bytes.bytesAvailable > 0)
			{
				event = new SMFEvent();
				event.delta_time = readVariableLength();
				time += event.delta_time;
				event.time = time;
				
				temp = bytes.readUnsignedByte();
				
				if(temp == 0xFF)
				{
					event.type = bytes.readUnsignedByte();
					len = readVariableLength();
					
					switch(event.type)
					{
					case 0x02:	//作者
						event.artist = bytes.readMultiByte(len, "Shift-JIS");
						parent.artist = event.artist;
						break;
					case 0x03:	//タイトル
						event.title = bytes.readMultiByte(len, "Shift-JIS");
						parent.title = event.title;
						break;
					case 0x2F:	//トラック終了
						break main;
					case 0x51:	//テンポ
						event.tempo = bytes.readUnsignedByte()*0x10000 + bytes.readUnsignedShort();
						if(parent.tempo == 0) {
							parent.tempo = 60000000 / event.tempo;
						}
						break;
					case 0x58:	//拍子
						parent.signature_n = bytes.readUnsignedByte();
						parent.signature_d = Math.pow(2, bytes.readUnsignedByte());
						bytes.position += 2;
						break;
					default:
						bytes.position += len;
						break;
					}
				}
				else if(temp == 0xF0 || temp == 0xF7)	//Sysx
				{
					event.type = temp;
					len = readVariableLength();
					event.sysx = new ByteArray();
					bytes.readBytes(event.sysx, 0, len);
				}
				else {
					if(temp & 0x80) {
						type = temp & 0xF0;
						channel = temp & 0x0F;
					}
					else {
						bytes.position--;
					}
					
					event.type = type;
					event.channel = channel;
					
					switch(type)
					{
					case 0x80:	//ノートオフ
						event.note = bytes.readUnsignedByte();
						event.velocity = bytes.readUnsignedByte();
						break;
					case 0x90:	//ノートオン
						event.note = bytes.readUnsignedByte();
						event.velocity = bytes.readUnsignedByte();
						break;
					case 0xA0:	//ポリフォニックキープレッシャー
						event.note = bytes.readUnsignedByte();
						event.value = bytes.readUnsignedByte();
						break;
					case 0xB0:	//コントロールチェンジ
						event.cc = bytes.readUnsignedByte();
						event.value = bytes.readUnsignedByte();
						break;
					case 0xC0:	//パッチチェンジ
						event.value = bytes.readUnsignedByte();
						break;
					case 0xD0:	//チャンネルプレッシャー
						event.value = bytes.readUnsignedByte();
						break;
					case 0xE0:	//ピッチベンド
						event.lsb = bytes.readUnsignedByte();
						event.msb = bytes.readUnsignedByte();
						break;
					}
				}
				sequence.push(event);
			}
			length = time;
		}
		
		public function toString():String
		{
			var text:String = length + "\n";
			
			for(var i:int = 0; i < sequence.length; i++)
			{
				if(sequence[i].toString() == "") {continue;}
				text += sequence[i].toString();
			}
			
			return text;
		}
	}

	dynamic class SMFEvent
	{
		public var delta_time:uint;	//相対時間
		public var time:uint;	//絶対時間
		public var type:int;
		
		public function toString():String
		{
			var text:String = "";
			//text = type.toString(16);
			//*
			switch(type)
			{
			case 0x90:
				if(this.velocity == 0) {break;}
				
				switch(this.note % 12)
				{
				case  0: text += "ド"; break;
				case  1: text += "ド#"; break;
				case  2: text += "レ"; break;
				case  3: text += "ミb"; break;
				case  4: text += "ミ"; break;
				case  5: text += "ファ"; break;
				case  6: text += "ファ#"; break;
				case  7: text += "ソ"; break;
				case  8: text += "ソ#"; break;
				case  9: text += "ラ"; break;
				case 10: text += "シb"; break;
				case 11: text += "シ"; break;
				}
				//text += " "+this.velocity;
				break;
			case 0xB0:
				text += "CC#" + this.cc +" "+this.value + " ";
				break;
			case 0xC0:
				text += "楽器変更 " + this.value + " ";
				break;
			case 0xF0:
			case 0xF7:
				text += "Sysx : ";
				for(var i:int = 0; i < this.sysx.length; i++) {
					text += this.sysx[i].toString(16)+" ";
				}
				break;
			}
			/*/
			if(type == 0x90 && this.velocity != 0)
			{
				switch(this.note % 12)
				{
				case  0: text += "c"; break;
				case  1: text += "c+"; break;
				case  2: text += "d"; break;
				case  3: text += "d+"; break;
				case  4: text += "e"; break;
				case  5: text += "f"; break;
				case  6: text += "f+"; break;
				case  7: text += "g"; break;
				case  8: text += "g+"; break;
				case  9: text += "a"; break;
				case 10: text += "a+"; break;
				case 11: text += "b"; break;
				}
			}
			//*/
			return text;
		}
	}
	
	class SMFBinary
	{
		public static const data:String = "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"
		 + "H85DH2s";
	}

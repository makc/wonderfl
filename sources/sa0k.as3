<?xml version="1.0" encoding="utf-8"?>
<mx:Application xmlns:mx="http://www.adobe.com/2006/mxml" layout="absolute">
	<mx:Script>
		<![CDATA[
			import mx.controls.NumericStepper;
			import mx.controls.TextInput;
			import mx.utils.Base64Decoder;
			import mx.controls.SWFLoader;
			import mx.utils.Base64Encoder;
			
			[Bindable] private var _output:String = "";
			[Bindable] private var _varName:String = "s";
			[Bindable] private var _tabNum:int = 3;
			private var _resultList:Array = [];
			
			private function onSelect():void
			{
				var f:FileReference = new FileReference();
				f.addEventListener(Event.SELECT, _onSelect);
				f.browse();
				function _onSelect(e:Event):void
				{
					f.addEventListener(Event.COMPLETE, _onLoad);
					f.load();
				}
				var main:Sprite = this;
				function _onLoad(e:Event):void
				{
					var ba:ByteArray = f.data as ByteArray;
					var b64:Base64Encoder = new Base64Encoder;
					b64.encodeBytes(ba,0,ba.length);
					var org:String = b64.flush();
					
					_resultList = org.split("\n");
					outputString();
				}
			}
			
			private function outputString():void
			{
				var tabs:String = "";
				for(var i:int = 0; i < _tabNum; ++i) 
					tabs += "\t";
				var s:String = tabs + "var "+ _varName +":String = \"\";\n";
				for each(var line:String in _resultList)
					s += tabs + _varName +" += \""+ line +"\";\n";
				_output = s;
			}

			private function onVarChange(e:Event):void
			{
				_varName = TextInput(e.currentTarget).text;
				outputString();
			}

			private function onTabChange(e:Event):void
			{
				_tabNum = NumericStepper(e.currentTarget).value;
				outputString();
			}

		]]>
	</mx:Script>
	<mx:VBox width="100%" height="100%">
		<mx:Label text="This program converts from binary to base64." toolTip="このプログラムはバイナリーからbase64に変換します"/>
		<mx:HBox>
			<mx:Button
				label="select file"
				toolTip="ファイル選択"
				click="onSelect()"/>
				
			<mx:Label
				text="name of variable"
				toolTip="変数名"/>
				
			<mx:TextInput
				text="{_varName}" 
				change="onVarChange(event)"
				width="40"/>
				
			<mx:Label
				text="numbers of tab"
				toolTip="タブの数"/>
				
			<mx:NumericStepper
				value="{_tabNum}"
				change="onTabChange(event)"
				minimum="0"
				maximum="10"/>
				
		</mx:HBox>
		<mx:TextArea
			text="{_output}"
			width="100%" height="100%"/>		
	</mx:VBox>
			
</mx:Application>

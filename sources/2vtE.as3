package 
{
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.IOErrorEvent;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.utils.ByteArray;
	import flash.xml.XMLDocument;
 
	public class BinaryXMLTool extends Sprite 
	{
 
		// ** minimalist buttons **
		private var browseButton:TextField;
		private var saveButton:TextField;
 
		// ** minimalist editor **
		private var xmlText:TextField;
 
		// ** browse/load/save **
		private var xmlFile:FileReference;
 
		public function BinaryXMLTool():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
 
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
 
			// entry point
			stage.align			= StageAlign.LEFT;
			stage.scaleMode			= StageScaleMode.NO_SCALE;
			stage.showDefaultContextMenu	= false;
 
			// ** draw minimalist text editor **
			xmlText				= new TextField();
			xmlText.multiline		= true;
			xmlText.background		= true;
			xmlText.backgroundColor		= 0xEEEEEE;
			xmlText.type			= TextFieldType.INPUT;
			xmlText.width			= 400;
			xmlText.height			= 400;
			xmlText.border			= true;
			xmlText.x			= (stage.stageWidth - xmlText.width) * 0.5;
			addChild(xmlText);
 
			// ** draw minimalist browse button **
			browseButton			= new TextField();
			browseButton.autoSize		= TextFieldAutoSize.LEFT;
			browseButton.background		= true;
			browseButton.backgroundColor	= 0x000000;
			browseButton.defaultTextFormat	= new TextFormat("Tahoma", 14, 0xFFFFFF, true, null, null, null, null, null, 4, 4);
			browseButton.selectable		= false;
			browseButton.text		= "BROWSE";
			browseButton.x			= (stage.stageWidth - browseButton.width) * 0.5;
			browseButton.y			= 420;
			addChild(browseButton);
 
			// ** draw minimalist save button **
			saveButton			= new TextField();
			saveButton.autoSize		= TextFieldAutoSize.LEFT;
			saveButton.background		= true;
			saveButton.backgroundColor	= 0xAAAAAA;
			saveButton.defaultTextFormat	= browseButton.defaultTextFormat;
			saveButton.selectable		= false;
			saveButton.text			= "SAVE";
			saveButton.x			= (stage.stageWidth - saveButton.width) * 0.5;
			saveButton.y			= 460;
			addChild(saveButton);
 
			// ** button listeners **
			browseButton.addEventListener(MouseEvent.CLICK, on_buttonClick, false, 0, true);
			saveButton.addEventListener(MouseEvent.CLICK, on_buttonClick, false, 0, true);
		}
 
		/**
		* handle browse or save
		*/
		private function on_buttonClick(evt:MouseEvent):void
		{
			var btn:TextField = evt.target as TextField;
			if (btn)
			{
				if (btn.text == "BROWSE")
				{
					xmlFile = new FileReference();
					xmlFile.addEventListener(Event.SELECT, on_xmlSelect, false, 0, true);
					xmlFile.browse([new FileFilter("XML Documents","*.xml")]);
				}
				else if (btn.text == "SAVE")
				{
					if (xmlFile)
					{
						if (xmlText.text.length)
						{
							// ** saving as binary **
							var data:ByteArray = new ByteArray();
							data.writeUTFBytes(xmlText.text);
							data.compress();
							new FileReference().save(data, "bin" + xmlFile.name);
						}
					}
				}
			}
 
		}
 
		/**
		* handle browse, load XML file
		*/
		private function on_xmlSelect(evt:Event):void
		{
			xmlFile.removeEventListener(Event.SELECT, on_xmlSelect);
			xmlFile.addEventListener(Event.COMPLETE, on_xmlComplete, false, 0, true);
			xmlFile.load();
		}
 
		/**
		* handle load, check if it is binary, uncompress, display XML in editor
		*/
		private function on_xmlComplete(evt:Event):void
		{
			xmlFile.removeEventListener(Event.COMPLETE, on_xmlComplete);
 
			saveButton.backgroundColor = 0x000000;
 
			var data:* = FileReference(evt.target).data;
			if (data is ByteArray)
			{
				try
				{
					ByteArray(data).uncompress();
				}
				catch(e:Error)
				{
				}
 
			}
			data = XML(data);
			xmlText.text = data;
		}
	}	
}
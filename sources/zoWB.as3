<?xml version = "1.0" encoding = "utf-8"?>
<mx:Application xmlns:mx = "http://www.adobe.com/2006/mxml" layout = "absolute" applicationComplete = "init();">
	<mx:ComboBox id = "cbox"
		labelField = "fontName"
		height = "30"
		fontSize = "16"
		rowCount = "12"
		change = "change();" />
	<mx:Label id = "jp"
		y = "100"
		fontSize = "20"
		text = "あのイーハトーヴォのすきとおった風、夏でも底に冷たさを持つ青い空、ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz" />
	<mx:Label id = "en"
		y = "150"
		fontSize = "20"
		text = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz" />

	<mx:Script>
		<![CDATA[
			import mx.core.UIComponent;
			private var fonts:Array = Font.enumerateFonts(true);
			
			private function init():void
			{
				fonts.sortOn("fontName", Array.CASEINSENSITIVE);
				this.cbox.dataProvider = fonts;
			}
			
			private function change():void
			{
				jp.setStyle("fontFamily", cbox.selectedItem.fontName);
				en.setStyle("fontFamily", cbox.selectedItem.fontName);
			}
		]]>
	</mx:Script>

</mx:Application>



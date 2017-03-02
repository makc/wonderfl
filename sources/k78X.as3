package {

	import flash.display.*;
	import flash.text.*;

	public class Shuffle extends Sprite
	{
		private var textfield:TextField;
		
		function Shuffle()
		{
			var i:int, array:Array, text:String = "";
			
			text += "Array.sort(function():int{return int(Math.random()*3)-1});\nで、配列をシャッフルできる。\n\n";
			
			text += "◆シャッフルのテスト\n";
			array = new Array();
			for(i = 1; i <= 16; i++) {array.push(i);}
			text += "array = ["+array+"]\n\n";
			
			text += shuffle(array)+"\n";
			text += shuffle(array)+"\n";
			text += shuffle(array)+"\n";
			text += shuffle(array)+"\n";
			text += shuffle(array)+"\n";
			
			text += "\n◆分布のテスト\n";
			array = new Array();
			for(i = 1; i <= 3; i++) {array.push(i);}
			text += "array = ["+array+"]\n\n";
			
			var result:Object = {"1,2,3":0,"1,3,2":0,"2,1,3":0,"2,3,1":0,"3,1,2":0,"3,2,1":0};
			
			for(i = 0; i < 65536; i++) {result[shuffle(array)]++;}
			for(var str:String in result) {text += "["+str+"] = "+result[str]+"\n";}
			
			textfield = new TextField();
			textfield.x = textfield.y = 20;
			textfield.width = textfield.height = 400;
			textfield.text = text;
			addChild(textfield);
		}
		
		public function shuffle(array:Array):Array
		{
			return array.sort(function():int{return int(Math.random()*3)-1});
		}
	}
}

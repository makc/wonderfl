package {
	import flash.display.Sprite;
	import flash.utils.getTimer;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	[SWF(width = "240",height = "180")]
	public class Max_in_Array extends Sprite {
		private const MAX_NUMBER:uint = 50000;;
		private const nCount:uint = 100;
		private var source_array:Array = createArray(nCount);
		private var testArrays:Vector.<Array >  = new Vector.<Array > (MAX_NUMBER,true);
		private var my_txt:TextField = new TextField  ;
		private var label_txt:TextField = new TextField  ;
		private var my_fmt:TextFormat = new TextFormat  ;
		public function Max_in_Array() {
			// Creating a TextField for display
			createTextField();
			setArrays();
			// Starting Test
			use_Array_sort();
			use_Array_sort2();
			use_condition();
			use_Function_apply();
		}
		private function use_Array_sort():void {
			var started:int = getTimer();
			for (var i:uint = 0; i < MAX_NUMBER; i++) {
				var my_array:Array = testArrays[i].concat();
				my_array.sort(Array.NUMERIC);
				var nMax:int = my_array[my_array.length - 1];
			}
			xTrace("Array.sort()",getTimer() - started);
		}
		private function use_Array_sort2():void {
			var started:int = getTimer();
			for (var i:uint = 0; i < MAX_NUMBER; i++) {
				var my_array:Array = testArrays[i].concat();
				my_array.sort(Array.NUMERIC | Array.DESCENDING);
				var nMax:int = my_array[0];
			}
			xTrace("Array.sort() (decending)",getTimer() - started);
		}
		private function use_condition():void {
			var started:int = getTimer();
			for (var i:uint = 0; i < MAX_NUMBER; i++) {
				var my_array:Array = testArrays[i].concat();
				var nLength:uint = my_array.length;
				var nMax:int = my_array[0];
				for (var j:uint = 1; j < nLength; j++) {
					var n:int = my_array[j];
					if ((n > nMax)) {
						nMax = n;
					}
				}
			}
			xTrace("if condition",getTimer() - started);
		}
		private function use_Function_apply():void {
			var started:int = getTimer();
			for (var i:uint = 0; i < MAX_NUMBER; i++) {
				var my_array:Array = testArrays[i].concat();
				var nMax:int = Math.max.apply(null, my_array);
			}
			xTrace("Function.apply()",getTimer() - started);
		}
		private function setArrays():void {
			for (var i:uint = 0; i < MAX_NUMBER; i++) {
				var my_array:Array = source_array.concat();
				shuffleArray(my_array);
				testArrays[i] = my_array;
			}
		}
		private function createArray(n:uint):Array {
			var my_array:Array = [];
			for (var i:uint = 0; i < n; i++) {
				my_array[i] = i;
			}
			return my_array;
		}
		private function shuffleArray(my_array:Array):void {
			var i:uint = my_array.length;
			while (i) {
				var nRandom:int = Math.floor(Math.random() * i--);
				var temp:Object = my_array[i];
				my_array[i] = my_array[nRandom];
				my_array[nRandom] = temp;
			}
		}
		private function createTextField():void {
			addChild(my_txt);
			addChild(label_txt);
			my_fmt.align = TextFormatAlign.RIGHT;
			my_txt.x +=  50;
			my_txt.defaultTextFormat = my_fmt;
			my_txt.autoSize = TextFieldAutoSize.RIGHT;
			label_txt.autoSize = TextFieldAutoSize.LEFT;
		}
		private function xTrace(_str:String,n:int):void {
			my_txt.appendText((String(n) + "\n"));
			label_txt.appendText(((_str + ":") + "\n"));
		}
	}
}
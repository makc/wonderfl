// forked from chaiyuttochai's how i can make movie clipe illastrate as a dot pixel?
// forked from hacker_7i4tn9on's forked from: The same brightness looks different.
// forked from borealkiss's The same brightness looks different.
/*
左側が赤(赤255 = #FF0000)と黒(#000000)を使って
チェック柄に塗りつぶした四角形、
右側が明るさ半分の赤(赤128 = #800000)で塗りつぶした四角形。
チェック柄が見えなくなるぐらい十分離れた位置から見ると
どちらの四角形も同じ”半分の明るさの赤色”に見えるはずだが。
*/
/*
勉強も兼ねて、『ガンマ補正　式』でぐぐって出てきた↓のサイトを見てガンマ補正してみた。
同じ色に見えるだろうか？
http://www.tyre.gotdns.org/domino/web01/tecrep2.nsf/By+Category/7DA1082FA16C929849256B220033FD86?Open
*/
package {
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	[SWF(width=465, height=465, backgroundColor=0x0)]
	public class main extends Sprite{
		private static const STAGE_SIZE:int = 465;
		private static const RECT_SIZE:int = 100;
		
                private static const SCREEN_GAMMA:Number = 2.2;
                
		public function main(){
			this.addRects();
			this.addCaptions();
		}
		
		private function addRects():void{
			var rect1:Bitmap = new Bitmap(new CheckPattern(RECT_SIZE, RECT_SIZE, rgb(0xff, 0, 0), rgb(0, 0, 0)));
			rect1.x = STAGE_SIZE*0.25 - RECT_SIZE*0.5;
			rect1.y = 150;
			this.addChild(rect1);
			
			var rect2:Bitmap = new Bitmap(new CheckPattern(RECT_SIZE, RECT_SIZE, rgb(gamma(0x80, SCREEN_GAMMA), 0, 0), rgb(gamma(0x80, SCREEN_GAMMA), 0, 0)));
			rect2.x = STAGE_SIZE*0.75 - RECT_SIZE*0.5;
			rect2.y = 150;
			this.addChild(rect2);
		}
		
                private function rgb(r:int, g:int, b:int):uint {
                    return ((r & 255) << 16) | ((g & 255) << 8) | ((b & 255) << 0);
                }
                
                private function gamma(a:int, g:Number):int {
                    return 255 * Math.pow(a / 255, 1 / g);
                }
                
		private function addCaptions():void{
			var text1:TextField = new TextField();
			text1.width = STAGE_SIZE*0.5;
			text1.height = 100;
			text1.text = "Check-patterned rectangle \n (#FF0000 and #000000)";
			text1.x = 0;
			text1.y = 300;
			this.setFormat(text1);
			this.addChild(text1);
			
			var text2:TextField = new TextField();
			text2.width = STAGE_SIZE*0.5;
			text2.height = 100;
			text2.x = STAGE_SIZE*0.5;
			text2.y = 300;
			text2.text = "Half-tone rectangle \n (#800000)";
			text2.appendText("\n(Actual color: #" + rgb(gamma(0x80, SCREEN_GAMMA), 0, 0).toString(16) + ")");
			this.setFormat(text2);
			this.addChild(text2);
		}
		
		private function setFormat(textField:TextField):void{
			var textFormat:TextFormat = new TextFormat();
            textFormat.size = 16;
            textFormat.color = 0xFFFFFF;
            textFormat.align = TextFormatAlign.CENTER;
            textField.setTextFormat(textFormat);
		}
	}
}

import flash.display.BitmapData;

class CheckPattern extends BitmapData{
	protected var _width:int;
	protected var _height:uint;
	protected var _firstColor:uint;
	protected var _secondColor:uint;
		
	/**
	 * Constructor
	 */ 
	public function CheckPattern(width:int, height:int, firstColor:uint=0xFFFFFF, secondColor:uint=0x0){
		_width = width;
		_height = height;
		_firstColor = firstColor;
		_secondColor = secondColor;
		super(_width, _height, false, _firstColor);
		this.init();
	}
		
	protected function init():void{
		for (var i:int=0; i<_width; i++){
			for (var j:int=0; j<_height; j++){
				var iIsEven:Boolean = this.isEven(i);
				var jIsEven:Boolean = this.isEven(j);
				if ((iIsEven && jIsEven) || (!iIsEven && !jIsEven)){
					this.setPixel(i, j, _secondColor);
				}
			}
		}
	}
	
	protected function isEven(value:int):Boolean{
		return !Boolean(value % 2);
	}
}

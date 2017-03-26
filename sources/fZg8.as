package {
    import flash.display.Sprite;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.utils.ByteArray;
    public class FlashTest extends Sprite {
        public function FlashTest() {
			var t:TextField = new TextField;
			t.autoSize = "left";
			var f:TextFormat = t.defaultTextFormat;
			f.font = "_typewriter";
			t.defaultTextFormat = f;
			t.text = bin2txt (root.loaderInfo.bytes, 32);
			t.x = -5; addChild (t);
        }

		private function bin2txt (bytes:ByteArray, rows:int = 0):String {
			var s:String = "", s1:String = "";
			var c:String = ".☺☻♥♦♣♠●◘..♂♀.♫☼►◄↕‼¶§−↨↑↓.←∟↔▲▼";
			var L:int = Math.min ((rows > 0) ? rows : int.MAX_VALUE, Math.ceil (bytes.length / 16)) * 16;
			for (var i:int = 0; i < L; i++) {
				var b:int, h:String;
				if (i < bytes.length) {
					b = bytes [i];
					h = ((b < 16) ? "0" : "") + b.toString (16) + " ";
				} else {
					b = 32;
					h = "   ";
				}

				var q:String = ".";
				if (b < 32) {
					q = c.charAt (b);
				} else if (b < 127) {
					q = String.fromCharCode (b);
				}

				if (i == L - 1) {
					s += h; s1 += q;
				}

				if (i > 0) {
					if ((i % 16 == 0) || (i == L - 1)) {
						s += "| " + s1 + "\n"; s1 = "";
					} else if (i % 8 == 0) {
						s += " ";
					}
				}

				if (i != L - 1) {
					s += h; s1 += q;
				}
			}

			return s;
		}
    }
}
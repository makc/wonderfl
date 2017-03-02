package {
	import flash.text.TextField;
	import flash.display.Sprite;

	/**
	 * 
	 * ベクターのソートメソッドは、実装かマニュアルがおかしい。
	 * たぶん内部でNumberをintに通してしまうミスをやってる。
	 * adobeの人も間違うんだったら、いっそのことintにNumberを暗黙的に入れたらエラーってことにしたらいいのに
	 * 
	 * @author sipo
	 */
	public class VectorSortTest extends Sprite {
		
		private var _displayString:String;
		
		
		public function VectorSortTest() {
			_displayString = "※理想(リファレンスより)" + "\n" +
			"指定したメソッドはベクターのベース型（T）の 2 つの引数を受け取り、数値を返す必要があります。" + "\n" +
			"　　function compare(x:T, y:T):Number {}" + "\n" +
			"compareFunction 関数のロジックにより、2 つのエレメント x と y が指定された場合、この関数は次の 3 つの値のいずれかを返します。" + "\n" +
			"" + "\n" +
			"x が y の前に表示されるソート順の場合は負の数。" + "\n" +
			"x と y が等しい場合は 0。" + "\n" +
			"x が y の後に表示されるソート順の場合は正の数。" + "\n" +
			"--------" + "\n" +
			"※現実" + "\n";
			
			var vector:Vector.<Number> = Vector.<Number>([1.5, 2.1, 0.9, 0.5, 1.1, 0.1, 1.8]);
			
			_displayString += "[" + vector.join(", ") + "]" + "\n" + 
			"↓" + "\n";
			
			vector.sort(function (x:Number, y:Number):Number{
				return x - y;	// x < y ? -1 : 1にしたらうまくいく 
			});
			
			_displayString += "vector.sort(function (x:Number, y:Number):Number{" + "\n" + 
			"    return x - y;" + "\n" + 
			"});" + "\n" + 
			"↓" + "\n" + 
			"[" + vector.join(", ") + "]" + "\n" + 
			"何この中途半端なソート" + "\n";
			
			
			var tf:TextField = new TextField();
			addChild(tf);
			tf.width = 465;
			tf.height = 465;
			tf.text = _displayString;
			tf.wordWrap = true;
		}
	}
}

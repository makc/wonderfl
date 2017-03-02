package  {
	import com.actionscriptbible.Example;
	/**
	 * Array shuffle oneliner.
	 */
	public class ShuffleArray extends Example {
		public function ShuffleArray () {
			var a:Array = [];
			for (var i:int = 0; i < 100; i++) a [i] = i;
			a.sort (function (a:*, b:*):Number { return (Math.random () > 0.5) ? 1 : -1; });
			trace (a);
		}
	}
}
package {
    import com.actionscriptbible.Example;
    public class FlashTest extends Example {
        public function FlashTest() {
            // http://juick.com/valyard/1230690
            var a:Array = ["bla"];
            a[ uint.MAX_VALUE ] = "bla2";
            trace( a.length ); // 0
            a.push(1, 2, 3);
            trace( a.length ); // 0
            trace( a[0] ); // 3
            trace( a[ uint.MAX_VALUE ] ); // "bla2"
        }
    }
}
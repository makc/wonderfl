package {
           	/*
	     	if you execute the following code in Chrome,
           	
'マルチバイト http://twitter.com/ ascii http://google.com'.
	replace(
	    new RegExp("https?://[-_.!~*a-zA-Z0-9;/?:@&=+$,%#]+", "g"),
	    function ($url, index, $str) {
	    	    console.log($url, index);
           	return $url;
         }
     );
      
     		the outcome is like :
http://twitter.com/ 7
http://google.com 33
"マルチバイト http://twitter.com/ ascii http://google.com"

			this is right. because indeces should be given as indeces of utf-8 char.
			
			what flash player gives as match indeces for the regular expression
			is byte positions of utf-8 bytes.
			
			so if you try to match the string which contains multibyte chars in unicode,
			the wrong indeces are passed.
			
			in the above example, 'マルチバイト' consits of 6 3-byte unicode chars.
            the difference is 2 for each characters. so the flash player gives us
            the wrong indeces :
            
http://twitter.com/ 19 = 6 * (3 - 1) + 7
http://google.com 45 = 6 * (3 - 1) + 33

            to avoid this, you can use exec of RegExp instead.
            http://wonderfl.net/c/xaLG/
           	*/
    import flash.display.Sprite;
    import flash.text.TextField;
    import flash.utils.ByteArray;
    import flash.accessibility.Accessibility;
    public class FlashTest extends Sprite {
        public function FlashTest() {
           	var str:String = 'マルチバイト http://twitter.com/ ascii http://google.com';
           	var ba:ByteArray = new ByteArray;
           	ba.writeUTFBytes(str);
           	ba.position = 0;
           	var tf:TextField = new TextField;
           	var i:int = 0;
           	tf.appendText(str.replace(new RegExp("https?://[-_.!~*a-zA-Z0-9;/?:@&=+$,%#]+", "g"), function ($url:String, index:int, $str:String):String {
           		ba.position = i;
           		var before:String = ba.readUTFBytes(index - i);
           		tf.appendText(<>{$url} {index}, before match: {before}</> + "\n");
           		i = index + $url.length;
           		return $url;
           	}));
           	tf.width = tf.textWidth + 4;
           	addChild(tf);
           	
           	
           	function trace(...o):void {
           		tf.appendText(o + '\n');
           	}
        }
    }
}
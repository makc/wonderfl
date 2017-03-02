package {
    
    import flash.display.Sprite;
    import flash.text.TextField;
    
    [SWF (width = "465", height = "465", frameRate = "30", backgroundColor = "0xFFFFFF")]
    
    public class Main extends Sprite {
        
        public function Main() {
            var num1:String = new String(int(Math.random() * 9) + 1);
            var num2:String = new String(int(Math.random() * 9) + 1);
            for (var i:int = 0; i < 450; i++) {
                num1 += String(int(Math.random() * 10));
                num2 += String(int(Math.random() * 10));
            }
            var answer:String = multiply(num1, num2);
            
            var tf:TextField = new TextField();
            tf.wordWrap = true;
            tf.multiline = true;
            tf.width = 465;
            tf.height = 465;
            tf.appendText("num1 = " + num1 + "\n\n");
            tf.appendText("num2 = " + num2 + "\n\n");
            tf.appendText("num1 * num2 = " + answer);
            addChild(tf);
        }
        
        private function multiply(numStr1:String, numStr2:String):String {
            var len1:int = numStr1.length;
            var len2:int = numStr2.length;
            
            var numArr1:Array = numStr1.split("");
            numArr1.reverse();
            var numArr2:Array = numStr2.split("");
            numArr2.reverse();
            
            var ansArr:Array = [];
            var stock:int = 0;
            for (var i:int = 0; i < len2; i++) {
                for (var j:int = 0; j < len1; j++) {
                    var k:int = int(numArr1[j]) * int(numArr2[i]) + int(ansArr[i + j]) + stock;
                    stock = int(k * 0.1);
                    k %= 10;
                    ansArr[i + j] = k;
                }
                if (stock != 0){
                    ansArr[i + j] = stock;
                    stock = 0;
                }
            }
            ansArr.reverse();
            return ansArr.join("");
        }
        
    }
    
}
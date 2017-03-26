package {
    import flash.text.TextField;
    import flash.display.Sprite;
    public class FlashTest extends Sprite {
        private var traceField:TextField;
        public function FlashTest() {
            traceField = new TextField;
            traceField.width = traceField.height = 465;
            addChild(traceField);
            methodA();
        }
        
        private function methodA():void {
            traceNow('1', 2);
            methodB();
        }
        
        private function methodB():void {
            traceNow(new Date);
        }
        
        private function traceNow(...msg:Array):void {
            try {
                throw new Error;
            } catch (e:Error) {
                traceField.appendText((msg ? msg.join(' ') : '') + e.getStackTrace().split('\n')[2] + '\n');
            }
        }
        
    }
}
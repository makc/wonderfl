// forked from imo_'s oimo challenge lv.3
// forked from imo_'s oimo challenge lv.2
// forked from imo_'s oimo challenge lv.1
package {
    import flash.events.MouseEvent;
    import flash.text.TextFormat;
    import flash.events.Event;
    import flash.text.TextField;
    import flash.display.Sprite;
    public class FlashTest extends Sprite {
        private var target:int;
        private var buffer:int;
        private var xor:uint;
        private var tf:TextField;
        
        public function FlashTest() {
            tf = new TextField();
            tf.defaultTextFormat = new TextFormat("monospaced", 24);
            tf.selectable = false;
            tf.x = 32;
            tf.y = 32;
            tf.width = 400;
            tf.height = 400;
            addChild(tf);
            target = buffer = xor = 0;
            addEventListener(Event.ENTER_FRAME, frame);
            stage.addEventListener(MouseEvent.MOUSE_DOWN, function(e:Event = null):void {
                buffer = buffer ^ xor;
                buffer = (buffer + 1) % 10;
                xor = uint(Math.random() * 0xFFFFFFFF);
                buffer = buffer ^ xor;
            });
        }
        
        private function frame(e:Event = null):void {
            target = buffer ^ xor;
            checkValue();
            tf.text = "Change this to 100 -> " + target;
            checkValue();

        }
        
        private function checkValue():void {
            if (target != (buffer ^ xor)) {
                tf.text = "you're dead.";
                tf = null;
            }

        }


    }
}
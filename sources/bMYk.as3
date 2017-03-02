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
            target = buffer = 0;
            addEventListener(Event.ENTER_FRAME, frame);
            stage.addEventListener(MouseEvent.MOUSE_DOWN, function(e:Event = null):void { buffer = target = (target + 1) % 10; });
        }
        
        private function frame(e:Event = null):void {
            if (target != buffer) {
                tf.text = "you're dead.";
                tf = null;
            } else if (target == 100) {
                tf.text = "Congrats.";
            } else {
                tf.text = "Change this to 100 -> " + target;
            }
            buffer = target; 

        }

    }
}
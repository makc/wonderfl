package {
  import flash.display.Sprite;
  import flash.events.TouchEvent;
  import flash.ui.Multitouch;
  import flash.ui.MultitouchInputMode;
  public class ch23ex4 extends Sprite {
    public function ch23ex4() {
      try {
        var test:Class = Multitouch;
        if (Multitouch.supportsTouchEvents) {
          Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
          for (var i:int = 0; i < Multitouch.maxTouchPoints; i++) {
            var b:Ball = new Ball();
            b.x = Math.random() * stage.stageWidth;
            b.y = Math.random() * stage.stageHeight;
            addChild(b);
          }
          stage.addEventListener(TouchEvent.TOUCH_BEGIN, onTouchBegin);
          stage.addEventListener(TouchEvent.TOUCH_END, onTouchEnd);
        } else {
          trace("Sorry, your device doesn't support touch-level events");
        }
      } catch (error:ReferenceError) {
        trace("Sorry, but multitouch is not supported in this runtime.");
      }
    }
    protected function onTouchBegin(event:TouchEvent):void {
      var b:Ball = event.target as Ball;
      if (!b) return;
      b.startTouchDrag(event.touchPointID, false);
    }
    protected function onTouchEnd(event:TouchEvent):void {
      var b:Ball = event.target as Ball;
      if (!b) return;
      b.stopTouchDrag(event.touchPointID);
    }
  }
}
import flash.display.BlendMode;
import flash.display.Sprite;
class Ball extends Sprite {
  public var touchPointID:int;
  public function Ball() {
    graphics.beginFill(Math.random() * 0xf0f0f0);
    graphics.drawCircle(0, 0, 70);
    blendMode = BlendMode.MULTIPLY
  }
}
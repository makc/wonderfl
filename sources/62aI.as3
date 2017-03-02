package {
    import flash.display.Shape;
    import flash.events.*;
    
    import a24.tween.Tween24;
    import com.actionscriptbible.Example;
    public class FlashTest extends Example {
        
        private static function lightBounceEase(t:Number, b:Number, c:Number, d:Number):Number {
            if (t < 0.75) {
                return t / 0.75;
            } else {
                return (t * 4 - 3.5) * (t * 4 - 3.5) * 0.2 + 0.95;
                // var t2:Number = t * 4 - 3.5;
                // return t2 * t2 * 0.2 + 0.95;
            }
        }
        
        public function FlashTest() {
            loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, function (e:UncaughtErrorEvent):void { trace(e.error); });
            trace('test');

            var s:Shape = new Shape();
            s.graphics.beginFill(0x000000);
            s.graphics.drawCircle(0, 0, 16);
            addChild(s);
            var t:Tween24 = Tween24.parallel(
                Tween24.prop(s).xy(32, 32),
                Tween24.tween(s, 4).x(465 - 32),
                Tween24.tween(s, 4, lightBounceEase).y(465 - 32)
            );
            t.play();
            stage.addEventListener(MouseEvent.CLICK, function (e:MouseEvent):void {
                t.play();
            });
        }
        
    }
}
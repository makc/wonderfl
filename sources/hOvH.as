// forked from kacchan6's Wonderfl.log
package {
    import flash.utils.describeType;
    import flash.display.Sprite;
    import flash.events.UncaughtErrorEvent;
    import flash.events.ErrorEvent;
    public class FlashTest extends Sprite {
        
        /** コンストラクター */
        public function FlashTest() {
            
            // グローバルエラーのイベント登録
            loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onUncaughtError);

            // こんなことすると、エラーが起きるよ
            var hoge:Object;
            hoge.moja;

        }
        /** グローバルエラーハンドラー */
        private function onUncaughtError(event:UncaughtErrorEvent):void {
            var message:String;
            
            if (event.error is Error)
                message = Error(event.error).getStackTrace();
            
            else if (event.error is ErrorEvent)
                message = ErrorEvent(event.error).text;
            
            else
                message = event.error.toString();

            Wonderfl.log(message);
            
            event.preventDefault(); // ココ重要！
        }
    }
}

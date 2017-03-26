package {
    import flash.events.Event;
    import flash.text.TextField;
    import flash.display.Sprite;
    import flash.system.MessageChannel;
    import flash.system.Worker;
    import flash.system.WorkerDomain;
    public class FlashTest extends Sprite {
        private var worker:Worker;
        private var messageChannel:MessageChannel;
        public function FlashTest() {
            // write as3 code here..
            if (Worker.current.isPrimordial)
            {
                var txt:TextField = new TextField();
                txt.autoSize = "left";
                addChild(txt);
                worker = WorkerDomain.current.createWorker(loaderInfo.bytes);
                messageChannel = worker.createMessageChannel(Worker.current);
                worker.setSharedProperty("_test_channel", messageChannel);
                worker.start();
                txt.text = messageChannel.receive(true);
            }
            else 
            {
                messageChannel = Worker.current.getSharedProperty("_test_channel");
                messageChannel.send("hogemoja");
            }
        }
    }
}
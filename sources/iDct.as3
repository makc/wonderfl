package {
    
    import flash.text.TextField;
    import flash.display.Sprite;
    import flash.events.Event
    import flash.display.Stage3D
    import flash.display3D.Context3D
    import flash.display3D.Context3DRenderMode
    import flash.system.Capabilities
    
    public class FlashTest extends Sprite {
        
        private var tf:TextField = new TextField
        
        public function FlashTest() {
            // write as3 code here..
            stage ? init() : addEventListener("addedToStage", init)
        }
        
        private function init(e:Event=null):void {
            removeEventListener("addedToStage", arguments.callee)
            
            var s3d:Stage3D = stage.stage3Ds[0]
            s3d.addEventListener(Event.CONTEXT3D_CREATE, initStage3D)
            s3d.requestContext3D(Context3DRenderMode.AUTO)
            
            tf.text = "flash player version : " + Capabilities.version + "\n"
            tf.appendText("requesting context...\n")
            tf.autoSize = "left"
            addChild(tf)
        }
        
        private function initStage3D(e:Event):void {
            var context:Context3D = e.target.context3D as Context3D
            tf.appendText("come on!\n")
            tf.appendText(context.driverInfo + "")
        }

    }
    
}
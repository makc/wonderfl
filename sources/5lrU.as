package {
    import flash.media.Video;
    import flash.media.Camera;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextField;
    import flash.display.Sprite;
    public class FlashTest extends Sprite {
        public function FlashTest() {
            var tf:TextField = new TextField;
            tf.y = 360;
            tf.width = 465;
            
            
            var camera:Camera = Camera.getCamera();
            camera.setMode(480, 360, 30);
            var video:Video = new Video(480, 360);
            video.attachCamera(camera);
            addChild(video);
            
            XML.prettyPrinting = false;
            tf.text = <>
                width : {camera.width},
                height : {camera.height}
            </>.toString();
            addChild(tf);
        }
    }
}
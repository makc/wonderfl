package {
  import flash.display.*;
  import flash.events.MouseEvent;
  import flash.text.TextField;
  import com.codeazur.as3swf.SWF;
  
  public class as3swfTest extends Sprite {
      public function as3swfTest() {
        var tf :TextField = new TextField;
        tf.width = stage.stageWidth;
        tf.height = stage.stageHeight;
        addChild( tf );  
    
        var swf:SWF = new SWF(root.loaderInfo.bytes);
        tf.text = swf.toString();
      }

    
  }
}


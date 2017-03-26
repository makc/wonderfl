// forked from makc3d's JPEG XR Encoder
package {
  
  import flash.display.BitmapData;
  import com.bit101.components.Label;
  import flash.net.FileReference;
  import flash.display.Loader;
  import com.bit101.components.HSlider;
  import flash.utils.ByteArray;
  import flash.events.Event;
  import com.bit101.components.PushButton;
  import flash.display.Sprite;
  import flash.events.MouseEvent;
  import flash.display.Bitmap;
  import flash.display.PNGEncoderOptions;
  
  [SWF(width="465", height="465")]
  /**
   * Shit, shit, shit!
   * Now I need to decode some jxr files back to editable form.
   */
  public class JXRDecoder extends Sprite {
    private var bd : BitmapData  = new BitmapData(8, 8, false, 0) ;
    private var bdInfo : Label ;
    private var file : FileReference  = new FileReference() ;
    private var loader : Loader  = new Loader() ;
    private var tester : Loader  = new Loader() ;
    private var output : ByteArray  = new ByteArray() ;
    public function JXRDecoder(  ){
      stage.align = "TL"; stage.scaleMode = "noScale";
      
      file.addEventListener(Event.SELECT, onFileSelected);
      file.addEventListener(Event.COMPLETE, onFileLoaded);
      loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onImageReady);
      
      var loadButton : PushButton  = new PushButton(this, 10, 10, "Load JXR file", loadUserImage);
      
      new PushButton(this, loadButton.x + loadButton.width + 15, 10, "Save PNG file", savePNG);
            
      bdInfo = new Label(this, 10, 40, "8 x 8");
    }
    private function loadUserImage ( e : MouseEvent ) : void {
      file.browse();
    }
    private function onFileSelected ( e : Event ) : void {
      file.load();
    }
    private function onFileLoaded ( e : Event ) : void {
      loader.loadBytes(file.data);
    }
    private function onImageReady ( e : Event ) : void {
      bd.dispose();
      bd = (loader.content as Bitmap).bitmapData;
      
      compress();
    }
    private function compress ( ...fu ) : void {
      var options : PNGEncoderOptions  = new PNGEncoderOptions();
      
      output = bd.encode(bd.rect, options); output.position = 0;
      
      bdInfo.text = bd.width + " x " + bd.height;
      
      if (tester.parent == this) removeChild (tester);
      
      tester = new Loader ();
      addChild (tester).y = 60;
      tester.loadBytes (output);
    }
    private function savePNG ( ...fu ) : void {
      (new FileReference()).save(output, "result.png");
    }
  }
}




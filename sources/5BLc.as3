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
  import flash.display.JPEGXREncoderOptions;
  
  [SWF(width="465", height="465")]
  /**
   * Apparently Microsoft pulled their HD photo plugins for Photoshop and
   * all we have now is http://www.microsoft.com/en-us/download/details.aspx?id=5863
   * 
   * Which is why I made this crappy tool to encode JXR files in flash.
   */
  public class JXREncoder extends Sprite {
    private var bd : BitmapData  = new BitmapData(8, 8, false, 0) ;
    private var bdInfo : Label ;
    private var file : FileReference  = new FileReference() ;
    private var loader : Loader  = new Loader() ;
    private var tester : Loader  = new Loader() ;
    private var quantization : HSlider ;
    private var output : ByteArray  = new ByteArray() ;
    public function JXREncoder(  ){
      stage.align = "TL"; stage.scaleMode = "noScale";
      
      file.addEventListener(Event.SELECT, onFileSelected);
      file.addEventListener(Event.COMPLETE, onFileLoaded);
      loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onImageReady);
      
      var loadButton : PushButton  = new PushButton(this, 10, 10, "Load JPG, PNG or GIF file", loadUserImage);
      
      new PushButton(this, loadButton.x + loadButton.width + 15, 10, "Save JXR file", saveJXR);
      
      quantization = new HSlider(this, 10, 40, compress);
      quantization.minimum = 0;
      quantization.maximum = 100;
      quantization.tick = 1;
      quantization.value = 20;
      
      bdInfo = new Label(this, quantization.x + quantization.width + 15, 40, "8 x 8");
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
      // no idea what 2nd and 3rd options are, so leaving defaults for now...
      var options : JPEGXREncoderOptions  = new JPEGXREncoderOptions(quantization.value);
      
      output = bd.encode(bd.rect, options); output.position = 0;
      
      bdInfo.text = bd.width + " x " + bd.height + ", q-n " + quantization.value + " => " + output.length + " bytes";
      
      if (tester.parent == this) removeChild (tester);
      
      tester = new Loader ();
      addChild (tester).y = 60;
      tester.loadBytes (output);
    }
    private function saveJXR ( ...fu ) : void {
      (new FileReference()).save(output, "result.jxr");
    }
  }
}




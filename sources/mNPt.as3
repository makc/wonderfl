package {
  
  import flash.display.BitmapData;
  import flash.filters.BlurFilter;
  import flash.geom.ColorTransform;
  import flash.display.Loader;
  import flash.events.Event;
  import flash.net.URLRequest;
  import flash.display.Sprite;
  import flash.display.Bitmap;
  import flash.display.LoaderInfo;
  import flash.system.*;
  import flash.display.BlendMode;
  
  [SWF(width="465", height="465")]
  public class Main extends Sprite {
    private var maskBitmapData : BitmapData ;
    private var growBitmapData : BitmapData ;
    private var bf : BlurFilter ;
    private var ct : ColorTransform ;
    public function Main(  ){
      var loader : Loader  = new Loader();
      loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
      loader.load(new URLRequest("http://assets.wonderfl.net/images/related_images/e/eb/eb54/eb5417bcd8f14d7ed884f02e636975fb87615d2d"),new LoaderContext(true));
    }
    private function onComplete ( e : Event ) : void {
      maskBitmapData = ((e.target as LoaderInfo).content as Bitmap).bitmapData;
      growBitmapData = new BitmapData(465, 465, false, 0);
      growBitmapData.setPixel(450, 425, 0xFFFFFF);
      addChild(new Bitmap(growBitmapData));
      bf = new BlurFilter(4, 4, 1);
      ct = new ColorTransform(16, 16, 16);
      addEventListener(Event.ENTER_FRAME, onEnterFrame);
    }
    private function onEnterFrame ( e : Event ) : void {
      growBitmapData.applyFilter(growBitmapData, growBitmapData.rect, growBitmapData.rect.topLeft, bf);
      growBitmapData.colorTransform(growBitmapData.rect, ct);
      growBitmapData.draw(maskBitmapData, null, null, BlendMode.MULTIPLY);
    }
  }
}




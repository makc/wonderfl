package {
  import flash.display.Bitmap;
  import flash.display.BitmapData;
  import flash.display.Sprite;
  import flash.events.Event;
    
  public class Main extends Sprite {
    private const re:Number = -1.8;
    private const im:Number = -0.085
    private const zoom:Number = 8.5;
    private const iter:int = 256;
    private var data:Vector.<uint>;
    private var pos:uint;
    private var canvas:BitmapData;
    
    public function Main() {
      var w:int = stage.stageWidth;
      var h:int = stage.stageHeight;
      data = new Vector.<uint>(w*h, true);
      canvas = new BitmapData(w, h, false);
      addChild(new Bitmap(canvas));
      make(w, h);
    }
    private function make(widht:int, height:int):void {
      var xi:Number, yi:Number, xip:Number, yip:Number;
      var a:Number = re, b:Number = im;
      var n:int;      
      var step:Number = 1.0/zoom/width;
      pos = 0;
      for(var y:int = 0; y < height; y++) {
        for(var x:int = 0; x < width; x++) {
          xi = 0, yi = 0, xip = 0, yip = 0, n = 0;
          while(n++ < iter) {
            xi = xi > 0 ? xi : -xi;  yi = yi > 0 ? yi : -yi;
            xip = xi*xi - yi*yi + a;  yip = 2*xi*yi + b;
            xi = xip;  yi = yip;
            if(xi*xi + yi*yi > 4) break; 
          }
          data[pos++] = x << 18 | y << 9 | n;
          a += step;
        }
        a = re;
        b += step;
      }
      pos = 0;
      addEventListener(Event.ENTER_FRAME, function(e:Event):void {
        try {
          var step:int = stage.stageWidth << 2;
          canvas.lock();
          for(var i:int = 0; i < step; i++) {
            var d:uint = data[pos++];
            canvas.setPixel(d >> 18, d >> 9 & 0x1ff,
                            (d & 0x1ff) << 18 | (d & 0xf) << 8);
          }
          canvas.unlock();
        }catch(e:RangeError) {
          removeEventListener(Event.ENTER_FRAME, arguments.callee);
        }
      });
    } 
  }
}
// write as3 code here..
package{

  import flash.display.MovieClip;
  import flash.display.BitmapData;
  import flash.display.Bitmap;
  import flash.geom.Rectangle;
  import flash.geom.Point;
  import flash.filters.BlurFilter;
  import flash.geom.ColorTransform;
  import flash.events.Event;
  import flash.events.MouseEvent;
  import flash.text.TextField;
	
  [SWF(width="465", height="465", backgroundColor="0x000000", frameRate="30")]

  public class Main extends MovieClip{

  private var tf:TextField;
  private var a0:Number;
  private var a1:Number;
  private var a2:Number;
  private var a3:Number;
	
  private var tonedown:ColorTransform;
  private var filter:BlurFilter;
  private var rect:Rectangle;
  private var pt:Point;

  private var objNum:int = 10000;
  private var objAry:Array;		

  private var bmd:BitmapData;
  private var bmp:Bitmap;

    public function Main(){

      tf = new TextField();
      tf.textColor = 0xFFFFFF;
      tf.text = "Click -> reset!";
      objAry = new Array();

      tonedown = new ColorTransform(1, 0.999, 0.9, 0.99);
      filter = new BlurFilter(1.5, 1.5, 1);
      rect = new Rectangle(0, 0, 465, 465)
      pt = new Point(0, 0)

      bmd = new BitmapData(465, 465, true, 0xFF000000);
      bmp = new Bitmap(bmd);

      for(var i:int = 0; i<objNum; i++){
        var p:Particle = new Particle(bmd);
        objAry.push(p);
      }

      addChild(bmp);
      addChild(tf);
      stage.addEventListener(MouseEvent.MOUSE_DOWN, init);

      init();
    }
	
    private function init(e:MouseEvent = null):void{

      removeEventListener(Event.ENTER_FRAME, update);
      bmd.fillRect(rect, 0xFF000000);

      a0 = Math.random()*4;
      a1 = Math.random()*4;
      a2 = Math.random()*4;
      a3 = Math.random()*4-2;

      for(var i:int = 0; i<objNum; i++){
        objAry[i].init(a0, a1, a2, a3);
      }

      addEventListener(Event.ENTER_FRAME, update);			
    }

    private function update(e:Event = null):void{
      bmd.lock();

      bmd.applyFilter(bmd, rect, pt, filter);
      bmd.colorTransform(rect, tonedown);

      for(var i:int = 0; i<objNum; i++){
        objAry[i].update();
      }

      bmd.unlock();
    }
  }
}

import flash.display.BitmapData;

class Particle{
  private var x:Number, y:Number;
  private var nx:Number, ny:Number;
  private var A0:Number, A1:Number, A2:Number, A3:Number;
  private var drawScale:Number;
  private var bmd:BitmapData;
	
  public function Particle(_bmd:BitmapData){
    bmd = _bmd;
    drawScale = 0.25;
  }
	
  public function init(a0:Number, a1:Number, a2:Number, a3:Number):void{
    x = Math.random()*8-4;
    y = Math.random()*8-4;

    A0 = a0;
    A1 = a1;
    A2 = a2;
    A3 = a3;
  }
	
  public function update():void{
    nx = Math.sin( A0 * y ) + Math.cos( A1 * x );
    ny = Math.sin( A2 * x ) + Math.cos( A3 * y );
		
    x = nx;
    y = ny;
		
    bmd.setPixel32(
      x * 465 * drawScale + 465 / 2,
      y * 465 * drawScale + 465 / 2,
      0xCCFF9922
    );
  }



}
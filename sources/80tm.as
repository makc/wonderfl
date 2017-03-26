package 
{
  import flash.display.*;
  import flash.events.*;
  import flash.geom.*;
  import flash.net.*;
  import flash.system.LoaderContext;
  
  [SWF(backgroundColor="0x808080", frameRate="60", width="465", height="465")]
  
  /**
   * RGB色分解するデモ
   * マウスでステージをドラッグしてみてね
   */
  public class Main extends Sprite 
  {
    /**
     * スピードの値
     */
    static private const CAMERA_SPEED:Number = .1;
    
    /**
     * 画像のパス
     * FlickrのピクチャでもOK!
     */
    static private const IMAGE_URL:String = "http://clockmaker.jp/imgs/mooning-light_300x300.jpg"
    //static private const IMAGE_URL:String = "http://farm1.static.flickr.com/50/146026358_13c698d683_m.jpg"
    
    /**
     * コンストラクター
     */
    public function Main()
    {
      var perspectiveProjection:PerspectiveProjection = root.transform.perspectiveProjection;
      perspectiveProjection.focalLength = 10000;
      
      // LoaderContextを準備(クロスドメインを使用するため)
      var context:LoaderContext = new LoaderContext(true);
      
      // 外部画像読み込み
      loader = new Loader();
      loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadHandler);
      loader.load(new URLRequest(IMAGE_URL), context);
      
      // and bg
      var bgMatrix:Matrix = new Matrix();
      bgMatrix.rotate(90 * Math.PI / 180);
      graphics.beginGradientFill("linear", [0xFFFFFF, 0x001122], [100, 100], [0, 255], bgMatrix);
      graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
    }
    
    /**
     * 画像の読み込み完了時の処理
     */
    private function loadHandler(e:Event):void
    {
      // イベントを設定
      stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
      stage.addEventListener(MouseEvent.MOUSE_UP, mouseUp);
      addEventListener(Event.ENTER_FRAME, onEnterFrame);
      
      // RGBチャンネルに分解する
      var vec:Array = createRGBChannel(loader.content as Bitmap);
       
      // 3Dオブジェクトをいれるラッパーを作成
      main = Sprite(addChild(new Sprite()));
      wrap = Sprite(main.addChild(new Sprite()));
      wrap.x = stage.stageWidth / 2;
      wrap.y = stage.stageHeight / 2;
      
      //Add some reference objects
      for (var i:int = 0; i < vec.length; i++)
      {
        var obj:DisplayObject = wrap.addChild(new Bitmap(vec[i]));
        obj.x = - obj.width / 2;
        obj.y = - obj.height / 2;
        obj.z = - 50 * (i - vec.length / 2);
        
        if (i == 0) continue;
        obj.blendMode = BlendMode.SCREEN;
      }
    }
    
    /**
     * Seperate RGB Channel
     * @param  Bitmap
     * @return  RGB + Black Vector.<BitmapData>
     */
    private function createRGBChannel(bmp:Bitmap):Array
    {
      var w:uint = bmp.width;
      var h:uint = bmp.height;
      var bmd:BitmapData = bmp.bitmapData;
      var rect:Rectangle = new Rectangle(0, 0, w, h);
      var point:Point = new Point(0, 0);

      // BitmapData のインスタンスを作成
      var r:BitmapData = new BitmapData(w, h, true, 0xFF000000);
      var g:BitmapData = new BitmapData(w, h, true, 0xFF000000);
      var b:BitmapData = new BitmapData(w, h, true, 0xFF000000);

      // RGB それぞれの色チャンネルを取得
      r.copyChannel(bmd, rect, point, BitmapDataChannel.RED, BitmapDataChannel.RED);
      g.copyChannel(bmd, rect, point, BitmapDataChannel.GREEN, BitmapDataChannel.GREEN);
      b.copyChannel(bmd, rect, point, BitmapDataChannel.BLUE, BitmapDataChannel.BLUE);
      return [new BitmapData(bmp.width, bmp.height, true, 0xFF000000), r, g, b];
    }
    
    /**
     * Eneter Frameの処理
     */
    private function onEnterFrame(e:Event):void
    {
      if (move)
      {
        panAngle += ((mouseX - lastMouseX) / stage.stageWidth * 180 + lastPanAngle - panAngle) * CAMERA_SPEED;
        tiltAngle += ((mouseY - lastMouseY) / stage.stageHeight * 180 + lastTiltAngle - tiltAngle) * CAMERA_SPEED;
      }
      else
      {
        panAngle += (0 - panAngle) * CAMERA_SPEED;
        tiltAngle += (0 - tiltAngle) * CAMERA_SPEED;
      }
      wrap.rotationX = tiltAngle;
      wrap.rotationY = panAngle;
      
      // 以下 Zソート
      var arr:Array = []
      for (var i:int = 0; i < wrap.numChildren; i++)
      {
        var ele:DisplayObject = wrap.getChildAt(i);
        var mtx:Matrix3D = ele.transform.getRelativeMatrix3D(main);
        arr.push( { ele:ele, z:mtx.position.z } );
      }

      arr.sortOn("z", Array.NUMERIC | Array.DESCENDING);
      var baseZ:Number = wrap.z;
      for (i = 0; i < arr.length; i++)
      {
        ele = arr[i].ele;
        var z:Number = arr[i].z;
        wrap.setChildIndex(ele, i);
      }
    }
    
    /**
     * マウスを押したときの処理
     */
    private function mouseDown(event:MouseEvent):void
    {
      lastPanAngle = panAngle;
      lastTiltAngle = tiltAngle;
      lastMouseX = mouseX;
      lastMouseY = mouseY;
      move = true;
    }
    
    /**
     * マウスを話したときの処理
     */
    private function mouseUp(event:MouseEvent):void
    {
      move = false;
    }
    
    // ------------------------------------------
    // いろいろ変数
    // ------------------------------------------
    private var move:Boolean = false;
    private var lastMouseX:Number;
    private var lastMouseY:Number;
    private var lastPanAngle:Number;
    private var lastTiltAngle:Number;
    private var panAngle:Number = 0;
    private var tiltAngle:Number = 0;
    
    private var main:Sprite;
    private var wrap:Sprite;
    private var loader:Loader;
  }
  
}
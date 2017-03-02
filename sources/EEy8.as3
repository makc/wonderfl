/*

	Mandelbrot safari zoomer, images by Paul Derbyshire, see
	http://www.fractalforums.com/images-showcase-%28rate-my-fractal%29/mandelbrot-safari/
	
	Warning: this code will load ~100MB of images.
	
	Click and hold to zoom, move your mouse to change zoom direction. Go!

 */
package {
  
  import flash.display.Loader;
  import flash.net.URLRequest;
  import flash.geom.Point;
  import flash.display.Shape;
  import flash.events.Event;
  import flash.events.IOErrorEvent;
  import flash.display.StageAlign;
  import flash.display.StageScaleMode;
  import flash.display.StageQuality;
  import flash.events.MouseEvent;
  import flash.display.Sprite;
  import flash.geom.Rectangle;
  import flash.geom.Matrix;
  
  public class MandelbrotSafari extends Sprite {
    private var loaders : Vector.<Loader>  = new Vector.<Loader>() ;
    private var requests : Vector.<URLRequest>  = new Vector.<URLRequest>() ;
    private var scales : Vector.<Number>  = new <Number>[1, 0.10125, 0.07875, 0.11125, 0.10125, 0.10125, 0.18125, 0.07125, 0.3515625, 0.04125, 0.05125, 0.06375, 0.1, 0.0806640625, 0.1, 0.24875, 0.20125, 0.10375, 0.1001953125, 0.128515625, 0.10125, 0.10125, 0.10125, 0.08375, 0.10125, 0.05, 0.10125, 0.07125, 0.1625, 0.19296875, 0.24625, 0.02125, 0.02625, 0.03875, 0.08125, 0.0525, 0.09875, 0.10125, 0.02625, 0.077734375, 0.10125, 0.11125, 0.09375, 0.10125, 0.10125, 0.05125, 0.04125, 0.10125, 0.05, 0.26, 0.05625, 0.07, 0.050625, 0.098125, 0.038125, 0.124609375, 0.025, 0.081640625, 0.065625, 0.0625, 0.09482421875, 0.056875, 0.17625, 0.0669921875, 0.04013671875, 0.0796875, 0.081640625, 0.058125, 0.05, 0.05, 0.198125, 0.05, 0.05, 0.04, 0.034, 0.05, 0.05, 0.05, 0.1, 0.05, 0.04, 0.04, 0.1, 0.1, 0.05, 0.1, 0.05, 0.05, 0.066, 0.04, 0.05, 0.1, 0.1, 0.0425, 0.08, 0.07, 0.1625, 0.16, 0.06, 0.1, 0.1, 0.1, 0.1, 0.1, 0.05, 0.25, 0.1, 0.0625, 0.25, 0.16, 0.1, 0.0625, 0.05, 0.05, 0.1, 0.2140625, 0.16, 0.06, 0.1, 0.1, 0.05, 0.14375, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.125, 0.1, 0.1, 0.11, 0.071, 0.1, 0.1, 0.1, 0.1125, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.0625, 0.16, 0.1, 0.1, 0.2, 0.1, 0.2, 0.1, 0.1, 0.051, 0.1, 0.1, 0.12375, 0.1, 0.1, 0.1, 0.1, 0.11, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.08375, 0.14375, 0.08375, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.27, 0.065, 0.075, 0.266, 0.06, 0.06125, 0.073, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.10375, 0.09625, 0.1, 0.20875, 0.1, 0.1, 0.1, 0.131, 0.16, 0.20875, 0.3, 0.16, 0.1, 0.19, 0.1, 0.1, 0.1, 0.1, 0.1, 0.11625, 0.1, 0.1, 0.1, 0.1, 0.2075, 0.16, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.11625, 0.1, 0.08625, 0.1, 0.11625, 0.08625, 0.09875, 0.14125, 0.14875, 0.22125, 0.21125, 0.1, 0.1, 0.18375, 0.1, 0.1, 0.25, 0.34875, 0.1, 0.1, 0.0625, 0.1328125, 0.1, 0.1, 0.2375, 0.09375, 0.2078125, 0.125, 0.1, 0.19] ;
    private var sizes : Vector.<Point>  = new Vector.<Point>() ;
    private var progress : Shape  = new Shape() ;
    private var count : int  = -1 ;
    private var mouseDown : Boolean ;
    private var scale : Number  = 1 ;
    public function MandelbrotSafari(  ){
      const wtfNames : Array  = ["_zpscd44fa16", "_zps438c5370", "_zpsea1ed915", "_zpsadf6cfa4", "_zps6f810c1e", "_zps5818427f", "_zps6285bd82", "_zps087a4d91", "_zps9570e0d0", "_zps7ef2cd3b", "_zps93d684b5", "_zpsf8736881", "_zpsdca6ce1d", "_zps9e547a4a", "_zpsdec9be3e", "_zps735bead1"];
      
      for ( var i : int  = 1 ; i < scales.length ; i++ ) {
        // cumulative scales
        scales[i] *= scales[i - 1];
        
        // images
        var url : String  = "http://i1248.photobucket.com/albums/hh496/Paul_Derbyshire/Mandelbrot%20Safari/evdz1_" + (1000 + i).toString().substr(1);
        if ( (i == 94) || (i == 96) || (i == 108) || (i == 109) || (i == 112) || (i == 114) ) {
          url += "hq.png";
        } else if ( i == 185 ) {
          url += "hq-1.jpg";
        } else if ( (i == 214) || (i == 216) || (i == 217) ) {
          url += "hq.jpg";
        } else if ( (i == 8) || (i == 12) || (i == 18) || (i == 19) || (i == 29) || (i == 50) || (i == 55) || (i == 57) || (i == 60) || (i == 63) ) {
          url += "_lrg.jpg";
        }else{
          // fuck, this guy was creative with file naming
          if ( (i >= 148) && (i <= 163) ) {
            url += wtfNames[i - 148];
          }
          url += ".jpg";
        }
        
        requests.push(new URLRequest(url));
        
        var loader : Loader  = new Loader();
        loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
        loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onIoError);
        loaders.push(loader);
        
        // sizes are mostly 800x600
        var size : Point  = new Point(400, 300);
        if ( (i == 94) || (i == 96) || (i == 108) || (i == 109) || (i == 112) || (i == 114) || (i == 113) || (i == 115) || (i == 116) || (i == 158) || (i == 185) || (i == 214) || (i == 216) || (i == 217) || (i == 231) || ((i >= 259) && (i <= 262)) || ((i >= 264) && (i <= 268)) || (i == 97) || (i == 66) ) {
          // 1280x960
          size.x = 640;
          size.y = 480;
        } else if ( (i == 8) || (i == 12) || (i == 13) || (i == 18) || (i == 19) || (i == 29) || (i == 39) || (i == 50) || (i == 55) || (i == 57) || (i == 60) || ((i >= 63) && (i <= 65)) ) {
          // 1024x768
          size.x = 512;
          size.y = 384;
        }
        sizes.push(size);
      }
      
      stage.align = StageAlign.TOP_LEFT;
      stage.scaleMode = StageScaleMode.NO_SCALE;
      stage.quality = StageQuality.BEST;
      stage.addEventListener(Event.RESIZE, onResize);
      stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
      stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouse);
      stage.addEventListener(MouseEvent.MOUSE_UP, onMouse);
      
      onResize();
      onComplete();
    }
    private var resized:Boolean;
    private function onResize ( e : Event  = null ) : void {
      scrollRect = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight); resized = true;
    }
    private function onComplete ( e : Event  = null ) : void {
      count++;
      if ( count < requests.length ) {
        loaders[count].load(requests[count]);
      }
    }
    private function onMouse ( e : MouseEvent ) : void {
      mouseDown = (e.type == MouseEvent.MOUSE_DOWN);
    }
    private function onEnterFrame ( e : Event ) : void {
      
      var w2 : Number  = stage.stageWidth / 2;
      var h2 : Number  = stage.stageHeight / 2;
      
      if ( mouseDown ) {
        var zoomSpeed : Number  = 1 + (mouseX - w2) / 1e3;
        scale *= zoomSpeed;
        scale = Math.min(1 / scales[scales.length - 1], Math.max(1, scale));
      } else if ( count >= loaders.length ) {
          if ( !resized )
              // why waste cpu
              return;
          else
              resized = false;
      }
      
      while ( numChildren > 0 ) {
        removeChildAt(0);
      }
      
      if ( count > 0 ) {
        // find smallest loaded image that covers whole screen
        for ( var i : int  = count - 1 ; i > 0 ; i-- ) {
          var ss : Number  = scale * scales[i];
          if ( (ss * sizes[i].x > w2) && (ss * sizes[i].y > h2) ) {
            
            break ;
          }
        }
        
        // add at most 1 image with scale < 1
        for ( var j : int  = i ; j < count ; j++ ) {
          ss = scale * scales[j];
          var loader : Loader  = loaders[j];
          loader.transform.matrix = new Matrix(ss, 0, 0, ss, w2 - sizes[j].x * ss, h2 - sizes[j].y * ss);
          addChild(loader);
          if ( ss < 1 ) {
            
            break ;
          }
        }
      }
      
      // if not all images are loaded, show the preloader
      if ( count < loaders.length ) {
        var p : Number  = count / loaders.length;
        progress.graphics.clear();
        progress.graphics.beginFill(0x7FFF, 1);
        progress.graphics.drawRect(0, h2 * 1.5, p * w2 * 2, 5);
        progress.graphics.endFill();
        progress.graphics.beginFill(0x7FFF, 0.3);
        progress.graphics.drawRect(p * w2 * 2, h2 * 1.5, (1 - p) * w2 * 2, 5);
        progress.graphics.endFill();
        addChild(progress);
      }
    }
    private function onIoError ( e : IOErrorEvent ) : void {
      // debug: catch bad urls here
    }
  }
}





// forked from makc3d's Relativity simulation
package {
  
  import flash.display.BitmapData;
  import flash.geom.Point;
  import flash.events.Event;
  import flash.events.MouseEvent;
  import flash.utils.setTimeout;
  import flash.display.Sprite;
  
  [SWF (width="465", height="465")]
  public class Relativity extends Sprite {
    private var grid : BitmapData ;
    private var worldline : Vector.<DragableBall> ;
    private var tmp1 : Point = new Point () ;
    private var tmp2 : Point = new Point () ;
    private var tmp3 : Point = new Point () ;
    public function Relativity () {
      worldline = new Vector.<DragableBall> ();
      
      var i : int;
      for ( i = 0 ; i < 8 ; i++ ) {
        worldline[i] = new DragableBall (150, 80 * i - 50);
      }
      
      for ( i = 1 ; i < 7 ; i++ ) {
        addChild (worldline[i]);
      }
      
      grid = new BitmapData (465, 465, false);
      graphics.beginBitmapFill (grid);
      graphics.drawRect (0, 0, 465, 465);
      
      stage.addEventListener (Event.ENTER_FRAME, onEnterFrame);
      stage.addEventListener (MouseEvent.MOUSE_UP, onMouseUp);
      
      setTimeout (renderGrid, 10);
    }

    private function onEnterFrame ( e : Event ) : void {
      // update worldline constraints
      var i : int;
      for ( i = 1 ; i < 8 ; i++ ) {
        worldline[i].x1 = worldline[i - 1].x - 77;
        worldline[i].x2 = worldline[i - 1].x + 77;
      }
      for ( i = 6 ; i > 0 ; i-- ) {
        worldline[i].x1 = Math.max (worldline[i].x1, worldline[i + 1].x - 77);
        worldline[i].x2 = Math.min (worldline[i].x2, worldline[i + 1].x + 77);
      }
    }

    private function onMouseUp ( e : MouseEvent ) : void {
      setTimeout (renderGrid, 10);
    }

    private var deltas : Vector.<Point>, ray : LightRay = new LightRay;
    private function renderGrid () : void {
      deltas = new Vector.<Point> (7);
      for ( var i : int = 0 ; i < 7 ; i++ ) {
        deltas[i] = worldline[i + 1].coords.subtract (worldline[i].coords);
      }
      
      intersectionCache = {};
      
      grid.lock ();
      for ( var X : int = 0 ; X < 465 ; X++ ) {
        for ( var Y : int = 0 ; Y < 465 ; Y++ ) {
          
          ray.setTo (X, Y, true);
          var t1 : Number = intersectRay (ray);
          
          ray.setTo (X, Y, false);
          var t2 : Number = intersectRay (ray);
          
          if (t2 < t1) {
            var t3 : Number = t2; t2 = t1; t1 = t3;
          }
          
          // own time at X, Y is:
          var t : Number = 0.5 * (t2 + t1);
          // distance at t from X, Y is:
          var d : Number = 0.5 * (t2 - t1);
          
          if ( d < 2 ) {
            // world line
            grid.setPixel (X, Y, 0x7FFF);
          } else {
            // grid every 20 pixels
            grid.setPixel (X, Y, 0xFFFFFF * ( (int ((t + 1000) / 20) + int (d / 20)) % 2));
          }
        }
      }
      grid.unlock ();
      
    }

    private var intersectionCache : Object;
    private function intersectRay ( ray : LightRay ) : Number {
      if (intersectionCache [ray.id] == null) {
        var t0 : Number = 0;
        for ( var j : int = 0 ; j < 7 ; j++ ) {
          // segment dr, dt (our)
          var dj : Point = deltas[j];
          // Minkowski space: dr (our)^2 - dt (our)^2 = 0 - dt (own)^2
          var dt : Number = Math.sqrt (dj.y * dj.y - dj.x * dj.x);

          var from : Point = worldline[j].coords;
          var to : Point = worldline[j + 1].coords;
          ray.setPoint1 (tmp1);
          ray.setPoint2 (tmp2);
          var t : Number = (from.y - intersection (tmp1, tmp2, from, to).y) / (from.y - to.y);

          if ( ((j == 0) || (t >= 0)) && ((j == 6) || (t < 1)) ) {
            intersectionCache [ray.id] = t0 + dt * t; break;
          }
          t0 += dt;
        }
      }
      return intersectionCache [ray.id];
    }

    private function intersection ( p1 : Point, p2 : Point, p3 : Point, p4 : Point ) : Point {
      var x1:Number = p1.x, x2:Number = p2.x, x3:Number = p3.x, x4:Number = p4.x;
      var y1:Number = p1.y, y2:Number = p2.y, y3:Number = p3.y, y4:Number = p4.y;
      var z1:Number= (x1 -x2), z2:Number = (x3 - x4), z3:Number = (y1 - y2), z4:Number = (y3 - y4);
      var d:Number = z1 * z4 - z3 * z2;
      
      // If d is zero, there is no intersection
      if ( d != 0 ) {
        var pre : Number = (x1 * y2 - y1 * x2);
        var post : Number = (x3 * y4 - y3 * x4);
        var x : Number = (pre * z2 - z1 * post) / d;
        var y : Number = (pre * z4 - z3 * post) / d;
        tmp3.setTo (x, y);
      }

      return tmp3;
    }
  }
}


import flash.geom.Point;

class LightRay {
  private var x:int, dx:int;
  public function setPoint1 (p:Point):void {
    p.x = x; p.y = 0;
  }
  public function setPoint2 (p:Point):void {
    p.x = x + dx; p.y = 1;
  }
  public function setTo (x:int, y:int, left:Boolean):void {
    if (left) {
      this.x = x - y; dx = +1;
    } else {
      this.x = x + y; dx = -1;
    }
    // cache address
    id = this.x + (left ? 1000 : 2000);
  }
  public var id:int;
}

import flash.events.MouseEvent;
import flash.display.Sprite;
import flash.events.Event;


class DragableBall extends Sprite {
  private var y0 : Number ;
  public var x1 : Number ;
  public var x2 : Number ;
  public var coords : Point ;
  public function DragableBall ( x : Number = 0, y : Number = 0 ) {
    graphics.beginFill (0x7fff);
    graphics.drawCircle (0, 0, 6);
    graphics.drawCircle (0, 0, 7);
    graphics.drawCircle (0, 0, 8);
    buttonMode = true;
    useHandCursor = true;
    addEventListener (MouseEvent.MOUSE_DOWN, onMouseDown);
    this.x = x;
    this.y = y;
    coords = new Point (x, y);
    y0 = y;
  }
  private function onMouseDown ( e : MouseEvent ) : void {
    startDrag ();
    onEnterFrame (e);
    addEventListener (Event.ENTER_FRAME, onEnterFrame, false, int.MAX_VALUE);
    
    stage.removeEventListener (MouseEvent.MOUSE_UP, onMouseUp);
    stage.addEventListener (MouseEvent.MOUSE_UP, onMouseUp);
  }
  private function onMouseUp ( e : MouseEvent ) : void {
    stopDrag ();
    onEnterFrame (e);
    removeEventListener (Event.ENTER_FRAME, onEnterFrame);
  }
  private function onEnterFrame ( e : Event ) : void {
    x = Math.min (Math.max (x, x1), x2);
    y = y0;
    coords.setTo (x, y);
  }
}

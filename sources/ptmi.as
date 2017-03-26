package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;
	/**
	 *
	 * 
	 */
	[SWF(width = "465", height = "465", frameRate = "60",backgroundColor="0x000000")]
	public class Main extends Sprite 
	{
            private var test:Sprite
            private var lines:Sprite;
            private  var _pont:Point
            private  var Arrays:Array;
            private  var SQ:Array;

            private var diff:Number
            private var radian:Number
            private var diffPoint:Point 
            private var Reaction:uint = 175; 
              private var spring:Number = 0.3
              private var friction:Number = 0.68;
              public function Main():void {
		if (stage) init();
		else addEventListener(Event.ADDED_TO_STAGE, init);
	   }
	   private function init(e:Event = null):void {
		removeEventListener(Event.ADDED_TO_STAGE, init);
		// entry point
		Arrays = []
		SQ=[]
		for (var i:int = 0; i < 6; i++ ) {
			for (var j:int = 0; j < 6; j++ ) {
				var _point:Points = new Points(95 * i, 95 * j);
				Arrays.push(_point)
				var test:Sprite = addChild(new Sprite()) as Sprite;
				test.graphics.beginFill(0x013823);
				test.graphics.drawCircle(0, 0, 10);
				test.graphics.endFill();
				SQ.push(test)
			}
		}
		lines = addChild(new Sprite()) as Sprite;
		addEventListener(Event.ENTER_FRAME, enter);
	    }
	    private function enter(e:Event):void {
		var mousePoint:Point = new Point(mouseX, mouseY); 
		var i:int;
		for each (var _point:Points in Arrays) { 
			_point.update(mousePoint,  Reaction, spring, friction);
			SQ[i].x = _point.x;
			SQ[i].y = _point.y
			i++;
		}
		lines.graphics.clear();
		lines.graphics.lineStyle (2, 0x000000, 1);
		for (var n:int = 0; n < 36; n++ ) {
			lines.graphics.beginFill(0x013823,distance/150)
			lines.graphics.moveTo(SQ[n].x, SQ[n].y);
			var distance:Number = Point.distance(mousePoint, new Point(SQ[n].x+47, SQ[n].y+47));
			if (n < 30) {
				lines.graphics.lineTo( SQ[(n + 6)].x, SQ[n + 6].y);
				if(n%6){
					lines.graphics.lineTo( SQ[(n + 5 )].x, SQ[n + 5].y);
					lines.graphics.lineTo( SQ[(n - 1 )].x, SQ[n - 1].y);
				}
				if(n==2||n==1){
					lines.graphics.lineTo( SQ[(n-1)].x, SQ[n - 1].y);
					lines.graphics.lineTo(SQ[n].x, SQ[n].y);	
				}
			}	
		}	
		lines.graphics.endFill()
	    }

	}
	
}

import flash.geom.Point;
class Points { 
     private var localX:Number; 
    private var localY:Number; 
     private var vx:Number = 0; 
    private var vy:Number = 0; 
     private var _x:Number; 
    private var _y:Number; 
    public function Points(x:Number, y:Number) { 
        _x = localX = x; 
        _y = localY = y; 
    } 
    public function update(mousePoint:Point, Reaction:uint, spring:Number, friction:Number):void { 
        var dx:Number; 
       var dy:Number; 
        var distance:Number = Point.distance(mousePoint, new Point(localX, localY)); 
        if (distance < Reaction) { 
            var diff:Number     = distance * -1 * (Reaction - distance) / Reaction; 
            var radian:Number   = Math.atan2(mousePoint.y - localY, mousePoint.x - localX); 
            var diffPoint:Point = Point.polar(diff, radian); 
            dx = localX + diffPoint.x; 
            dy = localY + diffPoint.y; 
        } else{
              dx = localX; 
            dy = localY; 
        } 
        vx += (dx - _x) * spring; 
        vy += (dy - _y) * spring; 
        vx *= friction; 
        vy *= friction; 
        _x += vx; 
        _y += vy; 
    }
    public function get x():Number { return _x; } 
    public function get y():Number { return _y; } 
} 

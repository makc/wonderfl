//click to draw a heart shape
package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import caurina.transitions.Tweener;
	[SWF(width = "465", height = "465", backgroundColor = 0xffffff, frameRate = "60")]
	
	public class HeartDraw extends Sprite 
	{
		public function HeartDraw():void 
		{
			stage.addEventListener(MouseEvent.MOUSE_DOWN, function ():void 
			{
				var h:HeartSprite = new HeartSprite();
				h.x = mouseX;
				h.y = mouseY;
				h.scaleX *= (Math.random() * 0.5 + 0.75);
				h.scaleY *= (Math.random() * 0.5 + 0.75);
				h.rotation = (Math.random() - 0.5) * 60,
				addChild(h);
				Tweener.addTween(h, {
					x: h.x + (Math.random() -0.5) * 300,
					y: h.y + 200 + Math.random()*300,
					scaleX: h.scaleX * 0.2,
					scaleY: h.scaleY * 0.2,
					rotation: h.rotation * (Math.random() * 1.5 + 1.5),
					time: 2.0 + Math.random()*1.5,
					transition: "easeInBack",
					onComplete: function ():void 
					{
						removeChild(h);
					}
				});
			});
		}
	}
}
import flash.display.Graphics;
import flash.display.Sprite;
import flash.geom.Point;
import caurina.transitions.Tweener;

class HeartSprite
extends Sprite
{
	public var t:Number = 0;
	public static var trans:Array = [
		"easeInOutQuad",
		"linear",
		"easeInCubic",
		"easeOutCubic"
	];
	public function HeartSprite():void 
	{
		scaleY *= -1;
		if (Math.random() < 0.5) scaleX *= -1;

		var h:HeartSegment = new HeartSegment(Math.random()*50 + 10);
		var g:Graphics = graphics;
		var lastT:Number = 0;
		var step:Number = 1 / 50;
		
		g.lineStyle(Math.random() * 6, 
		(Math.random() * 0x66 + 0x99) << 16 |
		(Math.random() * 0x66 + 0x99) << 8 |
		(Math.random() * 0x66 + 0x99)
		);
		
		//set startPt to random
		t = (Math.random() < 0.5) ? 0 : 0.5;
		lastT = t;
		var pt:Point = h.getValue(t);
		g.moveTo( pt.x, pt.y);
		
		Tweener.addTween(this, {
			t:t+1,
			time: 0.5 + Math.random()*1.0,
			transition: trans[Math.floor(Math.random()*trans.length)],
			onUpdate: function ():void 
			{
				while ((lastT += step) < t)
				{
					var pt:Point = h.getValue(lastT);
					g.lineTo( pt.x, pt.y);
				}
				pt = h.getValue(t);
				g.lineTo( pt.x, pt.y);
				lastT = t;
			}
		});
	}
}

class HeartSegment
{
	private var len:Number;
	private var bss:Array = [];
	public function HeartSegment(len:Number = 30):void 
	{		
		this.len = len;
		
		//--nodes
		
		//bottom
		var n0:Point = new Point(0, 0);		
		//left top
		var n1:Point = Point.polar(len * 2 * (Math.random()* 0.5 +0.75), Math.PI * (7/12 + Math.random() * 1 / 6));
		//top
		var n2:Point = new Point((Math.random()-0.5)*len*0.25, len * Math.sqrt(3));
		//right top
		var n3:Point = Point.polar(len * 2 * (Math.random()* 0.5 +0.75), Math.PI *  (5/12 - Math.random() * 1 / 6));
		
		
		//--controls
		var c10:Number = 0.5 + Math.random() * 1 / 6;
		var c11:Number = 0.5 + Math.random() * 1 / 6;
		
		var c20:Number = 0.5 - Math.random() * 1 / 6;
		var c21:Number = 0.5 - Math.random() * 1 / 6;
		
		var c00:Number = 0.5 + Math.random() * 1 / 6;
		var c01:Number = c10 + 1;
		
		var c30:Number = c21 + 1;
		var c31:Number = 0.5 - Math.random() * 1 / 6;
		

		//bezierSegments
		bss =
		[
			new BezierSegment_(
				n0,
				n0.add(Point.polar(len, Math.PI * c00)),
				n1.add(Point.polar(len, Math.PI * c01)),
				n1
			),
			new BezierSegment_(
				n1,
				n1.add(Point.polar(len, Math.PI * c10)),
				n2.add(Point.polar(len, Math.PI * c11)),
				n2
			),
			new BezierSegment_(
				n2,
				n2.add(Point.polar(len, Math.PI * c20)),
				n3.add(Point.polar(len, Math.PI * c21)),
				n3
			),
			new BezierSegment_(
				n3,
				n3.add(Point.polar(len, Math.PI * c30)),
				n0.add(Point.polar(len, Math.PI * c31)),
				n0
			)
		];
	}
	public function getValue(t:Number):Point
	{
		t -= Math.floor(t);
		t *= bss.length;
		var i:int = Math.floor(t);
		return BezierSegment_(bss[i]).getValue(t-i);
	}
}

/**
 * A Bezier segment consists of four Point objects that define a single cubic Bezier curve.
 * The BezierSegment class also contains methods to find coordinate values along the curve.
 * @playerversion Flash 9.0.28.0
 * @langversion 3.0
 * @keyword BezierSegment, Copy Motion as ActionScript
 * @see ../../motionXSD.html Motion XML Elements  
 */
class BezierSegment_
{
    public var a:Point;
    public var b:Point;
    public var c:Point;
	public var d:Point;
	function BezierSegment_(a:Point, b:Point, c:Point, d:Point)
	{
		this.a = a;
		this.b = b;
		this.c = c;
		this.d = d;
	}
	public function getValue(t:Number):Point
	{
		var ax:Number = this.a.x;
		var x:Number = (t*t*(this.d.x-ax) + 3*(1-t)*(t*(this.c.x-ax) + (1-t)*(this.b.x-ax)))*t + ax;
		var ay:Number = this.a.y;
		var y:Number = (t*t*(this.d.y-ay) + 3*(1-t)*(t*(this.c.y-ay) + (1-t)*(this.b.y-ay)))*t + ay;
		return new Point(x, y);	
	}
}
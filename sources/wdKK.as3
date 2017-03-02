package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import caurina.transitions.Tweener;
	
	[SWF(width = "465", height = "465", backgroundColor = 0xFFFFFF, frameRate = "60")]
	
	public class Walker extends Sprite 
	{
		private var rad:Number;
		private var r:Number = 0;
		private const PI2:Number = Math.PI * 2;
		private var speed:Number = 0.05;
		private var rAdd:Number = Math.PI * speed;
		private var legs:Sprite = new Sprite();
		private var body:Sprite = new Sprite();

		public function Walker():void 
		{			
			//bg
			graphics.beginFill(0x999999);
			graphics.drawRect(0, 300, 465, 300);
			
			//body
			body.graphics.beginFill(0)//x666666);
			body.graphics.drawRoundRect(-40, 0, 80, 60, 60, 60);
			body.graphics.beginFill(0xFFFFFF);
			body.graphics.drawCircle( -20, 20, 4);
			body.graphics.drawCircle( 20, 20, 4);
			
			//legs
			var legNum:uint = 4;
			for (var i:uint = 0; i < legNum; i ++)
			{
				var leg:Leg = new Leg();
				leg.r = PI2 * (i *1.5) / legNum;
				leg.length = 100;
				leg.rMul = Math.random() + 0.2;
				legs.addChild(leg);
			}
			//add
			addChild(body);
			addChild(legs);
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
			//
			enterFrameHandler(null);

		}
		private function enterFrameHandler(e:Event):void 
		{
			var d:Number = (mouseX - legs.x) * 0.1;
			legs.x += d;
			body.x  = legs.x;

			r = (r + d * 0.02 ) % PI2;
			legs.graphics.clear();
			var heights:Array = new Array();
			for (var i:uint; i < legs.numChildren; i++) 
			{
				var leg:Leg = legs.getChildAt(i) as Leg;
				var pt:Point = Point.polar(leg.length/2, Math.abs(Math.sin(r + leg.r)) * (i %2 ==0 ? -1 : 1) *1.0 + Math.PI / 2);
				
				var lx:Number = (Math.ceil(i/2)) * 60 / legs.numChildren *  ((i % 2 == 0) ? 1 : -1)
				+ ((legs.numChildren % 2 == 0) ? 30/ legs.numChildren : 0);

				legs.graphics.moveTo(lx, 0);
				legs.graphics.lineStyle(16, 0);
				legs.graphics.lineTo(lx + pt.x, pt.y);
				legs.graphics.lineTo(lx, pt.y*2);
				heights.push(pt.y*2)
			}

			heights.sort(Array.NUMERIC | Array.DESCENDING);
			legs.y = 300 - heights[0];

			body.y = legs.y - body.height *0.75;
		}
		
	}
	
}
import flash.display.Sprite;
import flash.events.Event;
class Leg
extends Sprite
{
	public var r:Number;
	public var length:Number;
	public var rMul:Number;
	public function Leg():void 
	{
	}
}
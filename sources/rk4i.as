package 
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	
 [SWF(width=500, height=500, frameRate=30, backgroundColor=0x000000)]
	public class CircleBlends extends Sprite
	{
		private var list:Array = [];
                private var length:uint;
		
		public function CircleBlends()
		{
			for(var i:uint=0; i<300; i++)
			{
				var size:Number = Math.random()*5+5;
				var a:ball = new ball(size);
				addChild(a);
				list.push(a);
			}
                        length = list.length;
			addEventListener(Event.ENTER_FRAME,loop);
		}
		
		private function loop(e:Event):void
		{
			for(var i:uint=0; i<length; i++)
			{
				list[i].x += (Math.random()*4-2)
				list[i].y += (Math.random()*4-2)
			}
		}
	}
}

	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.filters.BlurFilter;
	import flash.utils.ByteArray;

class ball extends Sprite
{
	public function ball(size:Number)
	{
		var px:Number = Math.random()*500;
			var py:Number = Math.random()*500;
			
			var red:uint = Math.random()*150;
			var bytes:ByteArray = new ByteArray();
			bytes.writeByte(0);
			bytes.writeByte(red);
			bytes.writeByte(170);
			bytes.writeByte(187);
			bytes.position = 0;
			var color:uint = bytes.readUnsignedInt();
			
			var cCir:Shape = new Shape();
			var bCir:Shape = new Shape();
			var gCir:Shape = new Shape();
			
			circle(gCir,px,py,size+15,color,0.2,150);
			circle(bCir,px,py,size+3,color,0.7,20);
			circle(cCir,px,py,size,0x001000,1,5);
	}
	
	private function circle(target:Shape,x:Number,y:Number,r:Number,color:Number,a:Number,bl:Number):void
		{
			addChild(target);
			target.x = x;
			target.y = y;
			target.alpha = a;
			target.filters = [new BlurFilter(bl,bl)];
			
			with(target.graphics)
			{
				beginFill(color);
				drawCircle(0,0,r);
				endFill();
			}
		}
}
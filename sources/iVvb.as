/*
これ
http://www.masahicom.com/blog/index.cgi/information/20090312suurikyokusen-kagaku.htm

クリックで軌跡のフェード有無切り替え
*/
package  
{
	import flash.display.Sprite;
	import flash.display.BitmapData;
	import flash.display.Bitmap;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.display.GradientType;
	import flash.events.MouseEvent;

	[SWF(width = "465", height = "465", backgroundColor = 0x335544, frameRate = "60")]
	public class MathematicalGraphics 
	extends Sprite
	{
		
		public function MathematicalGraphics() 
		{
			var bg:Sprite = new Sprite();
			var mtr:Matrix = new Matrix();
			mtr.createGradientBox(stage.stageWidth, stage.stageHeight, Math.PI/2);
			bg.graphics.beginGradientFill(
				GradientType.RADIAL, 
				[0x55735b, 0x3a4e37], 
				[1,1],
				[0, 255],
				mtr
			);
			bg.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			//
			var bd:BitmapData = new BitmapData(465,400,true,0x00FFFFFF)
			var container:Container = new Container(bd);
			container.y = 400;
			//
			var bmp:Bitmap = new Bitmap(bd);
			//
			var timer:Timer = new Timer(100);
			timer.addEventListener(TimerEvent.TIMER, function ():void 
			{
				bd.colorTransform(bd.rect, new ColorTransform(1, 1, 1, 0.95));
			});
			timer.start();
			//
			stage.addEventListener(MouseEvent.MOUSE_DOWN,function ():void 
			{
				timer.running ? timer.stop() : timer.start();
			});
			addChild(bg);
			addChild(bmp);
			addChild(container);

		}
		
	}
	
}
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.events.Event;
import flash.geom.Matrix;
import flash.display.GradientType;
	
class Container
extends Sprite
{
	private var bd:BitmapData;
	public function Container(bd_:BitmapData):void 
	{
		bd = bd_;
		
		var bg:Sprite = new Sprite();
		var mtr:Matrix = new Matrix();
		mtr.createGradientBox(465, 100, Math.PI/2);
		bg.graphics.beginGradientFill(
			GradientType.LINEAR, 
			[0xdec392, 0x8a7356], 
			[1,1],
			[0, 255],
			mtr
		);
		bg.graphics.drawRect(0, 0, 465, 100);
		addChild(bg);
			

		add();
		add();
		add();
//		add();
//		add();
	}
	private function add():void 
	{
		var mover:Mover;
		var i:uint = Math.floor(Math.random() * 3);
		switch (i) 
		{
			case 0:
				mover = new Hammer();
				break;
			case 1:
				mover = new Roller();
				break;
			case 2:
				mover = new Cube();
				break;
			
		}
		
		mover.addEventListener(Event.ENTER_FRAME, update);
		addChild(mover);
	}

	public function update(e:Event):void 
	{
		var o:Mover = e.target as Mover;
		
		var pts:Array = o.pts.map(function (pt:Point, i:int, a:Array):Point
		{
			return o.localToGlobal(pt);
		});
		
		o.update();
		
		var sp:Sprite = new Sprite();
		var g:Graphics = sp.graphics;
		
		g.beginFill(0,0);
		g.lineStyle(1.5,0xFFFFFF, 0.5);
		
		
		var len:uint = pts.length;
		for (var i:uint = 0; i < len; i++)
		{
			var pt:Point = pts[i];
			g.moveTo(pt.x, pt.y);
			pt = o.localToGlobal(o.pts[i]);
			g.lineTo(pt.x, pt.y);
			
		}
		//g.moveTo(pt1.x, pt1.y);
		//pt1 = o.localToGlobal(o.pt1);
		//g.lineTo(pt1.x, pt1.y);
		//
		//g.moveTo(pt2.x, pt2.y);
		//pt2 = o.localToGlobal(o.pt2);
		//g.lineTo(pt2.x, pt2.y);
		
		bd.draw(sp);
		sp = null;
		var rect:Rectangle = o.getBounds(this);
		if (rect.x > 465)
		{
			o.removeEventListener(Event.ENTER_FRAME, update);
			removeChild(o);
			o = null;
			add();
		}		
	}
}

class Mover
extends Sprite
{
	protected var xx:Number;
	protected var yy:Number;
	protected var rr:Number;
	public var pts:Array = new Array;
	public static const GRAV:Number = 0.01;
	protected var ref:Number = -0.9
	public function update():void 
	{
		x += xx;
		y += yy;
		rotation += rr;
		
		var rect:Rectangle = getRect(parent);
		var h:Number = rect.y + rect.height
		if (0 < h)
		{
			y -= h;
			yy *= ref;
		}
		yy += GRAV;
	}
}
class CircleMover
extends Mover
{
	protected var r:Number;
	override public function update():void 
	{
		x += xx;
		y += yy;
		rotation += rr;
		
		var h:Number = y + r;
		if (0 < h)
		{
			y -= h;
			yy *= ref;
		}
		yy += GRAV;
	}
}
class Hammer
extends Mover
{
	public function Hammer():void 
	{
		//graphics
		var g:Graphics = graphics;
//		g.lineStyle(2);
		g.beginFill(0x997755);
		g.drawRect( -4, 0, 8, 60);
		g.endFill();
		g.beginFill(0);
		g.drawRect( -10, -4, 20, 8);
		g.endFill();
		
		//
		x = y = -height;
		y -= Math.random() * 100;
		rotation = Math.random() * 360;
		
		//
		pts.push(new Point(0, 0), new Point(0, 60));
		xx = Math.random() * 1.5 + 0.5;
		yy = -(Math.random() * 1 + 1.5);
		rr = xx * (Math.random()*1.0 + 0.5) * ( (Math.random() < 0.5) ? 1 : -1);
		
		//
		ref = -0.9;
	}
}
class Roller
extends CircleMover
{
	public function Roller():void 
	{
		//graphics
		var g:Graphics = graphics;
//		g.lineStyle(2);
		g.beginFill(0xdddddd);
		g.drawCircle( 0, 0, 20);
		g.drawCircle( 0, 0, 12);
		g.endFill();
		
		g.beginFill(0x990000);
		g.drawCircle( 0, 16, 2);
		
		x = y = -height;
		y -= Math.random() * 300;
		rotation = Math.random() * 360;

		
		//
		pts.push(new Point(0, 16));
		xx = Math.random() * 1 + 0.5;
		yy = -(Math.random() * 0.1 + 0.1);
		rr = xx * Math.PI;
		
		//
		r = 20;
		ref = -0.3;
	}
}
class Cube
extends Mover
{
	public function Cube():void 
	{
		//graphics
		var g:Graphics = graphics;
//		g.lineStyle(2);
		g.beginFill(0x448844);
		g.drawRect( -20, -20, 40, 40);
		g.endFill();
		
		x = y = -height;
		y -= Math.random() * 200;
		rotation = Math.random() * 360;
		
		//
		pts.push(new Point(-20, -20), new Point(20, 20));
		xx = Math.random() * 1.5 + 0.5;
		yy = -(Math.random() * 1.5 + 0.5);
		rr = xx * (Math.random()*2 + 0.2);
		
		//
		ref = -0.7;
	}
}



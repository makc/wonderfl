package 
{
	/*
	 * iPhoneカメラとかが歪むあれ
	 * http://labaq.com/archives/51250054.html
	 */ 
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import caurina.transitions.Tweener;
	import com.bit101.components.Slider;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.utils.Timer;
	import com.bit101.components.PushButton;
	import com.bit101.components.Label;
	import com.bit101.components.Style;
	import com.adobe.images.PNGEncoder;
	import flash.net.FileReference;	
	import flash.utils.ByteArray;
	
	[SWF(width = "465", height = "465", backgroundColor = 0xFFFFFF, frameRate = "60")]
	
	public class Scan extends Sprite 
	{
		private var screen:Sprite = new Sprite();
		private var scanBmp:Bitmap = new Bitmap();
		private var effect:Shape = new Shape();
		private var menu:Sprite = new Sprite();
		
		public function Scan() 
		{			
			addChild(screen);
			screen.alpha = 0.1;
			screen.x = stage.stageWidth / 2;
			screen.y = stage.stageHeight / 2;
			
			addChild(scanBmp);
			addChild(effect);
			addChild(menu);
			
			screen.addChild(new Rect(200, 200));
			
			var loader:Loader = new Loader();
			loader.load(new URLRequest("http://farm3.static.flickr.com/2608/3839475460_66c5e7637e_o.png"), new LoaderContext(true));
			
			
			//menus
			var propellerLbl:Label = new Label(menu, 10, 0, "Rotation freq. (cycle / sec)");
			
			var propellerFreq:SliderWithLabel = new SliderWithLabel(Slider.HORIZONTAL, menu, 20, 30);
			propellerFreq.width = 400;
			propellerFreq.height = 12;
			propellerFreq.backClick = true;
			propellerFreq.fractionDigits = 3;
			propellerFreq.setSliderParams( -4, 4, 0.025);
			
			var scannerLbl:Label = new Label(menu, 10, 400, "Scanner delay /row [ms]");
			
			var scanDelay:SliderWithLabel = new SliderWithLabel(Slider.HORIZONTAL, menu, 20, 430);
			scanDelay.width = 300;
			scanDelay.height = 12;
			scanDelay.backClick = true;
			scanDelay.fractionDigits = 3;
			scanDelay.setSliderParams( 0, 60000 / stage.stageHeight, 5000 / stage.stageHeight);
			
			var row:int = 0;
			var eg:Graphics = effect.graphics;
			var scanTimer:Timer = new Timer(1);
			var bmd:BitmapData = new BitmapData(stage.stageWidth, stage.stageHeight, true, 0x00000000);
			scanTimer.addEventListener(TimerEvent.TIMER, function ():void 
			{
				scanTimer.delay = scanDelay.value;
				//draw 1px row
				var mtx:Matrix = new Matrix()
				mtx.rotate( screen.rotation / 180 * Math.PI);
				mtx.translate(screen.x, screen.y);
				
				bmd.draw(screen, mtx, null, null, new Rectangle(0, row, bmd.width, 1));
				//draw scan effect
				eg.clear();
				eg.lineStyle(1, 0xff0000);
				eg.moveTo(0, row);
				eg.lineTo(bmd.width, row);
				if (++row > stage.stageHeight) 
				{
					scanTimer.reset();
				}
			});

			//cmd
			var scanBtn:PushButton = new PushButton(menu, 340, 375, "scan", function ():void 
			{
				row = 0;
				scanClear();
				scanTimer.start();				
			});
			scanBtn.width = 120;
			scanBtn.height = 30;
			new PushButton(menu, 350, 410, "clear", function ():void 
			{
				scanClear();
			});
			new PushButton(menu, 350, 430, "save img", function ():void 
			{
				//save PNG to local
				var ba:ByteArray = PNGEncoder.encode(bmd);
				var fr:FileReference = new FileReference;
				fr.save(ba, "scanner" + new Date().valueOf().toString() + ".png");
			});

			//shapes
			new PushButton(menu, 350, 60, "achamo", function ():void 
			{
				while (screen.numChildren) screen.removeChildAt(0); 
				screen.addChild(loader);
				loader.x = -loader.width / 2;
				loader.y = -loader.height / 2;
			});
			new PushButton(menu, 350, 80, "propeller", function ():void 
			{
				while (screen.numChildren) screen.removeChildAt(0); 
				screen.addChild(new Rose(150, 4,1 ));
			});
			new PushButton(menu, 350, 100, "random rose", function ():void 
			{
				while (screen.numChildren) screen.removeChildAt(0); 
				screen.addChild(new Rose(150, Math.random()*10 + 1,Math.random()*10+1));
			});
			new PushButton(menu, 350, 120, "random rect", function ():void 
			{
				while (screen.numChildren) screen.removeChildAt(0); 
				screen.addChild(new Rect(Math.random()*300+100, Math.random()*300+100));
			});
			
			function scanClear():void 
			{
				bmd = new BitmapData(stage.stageWidth, stage.stageHeight, true, 0x00000000);
				scanBmp.bitmapData = bmd;				
			}
			
			
			var timer:Timer = new Timer(1000/stage.frameRate);
			timer.addEventListener(TimerEvent.TIMER, function ():void 
			{
				screen.rotation += propellerFreq.value * timer.delay / 1000 * 360
			});
			timer.start();
		}
		
	}
	
}
import flash.display.*;
import flash.events.*;
import flash.geom.*;
import caurina.transitions.Tweener;
import com.bit101.components.Slider;
import com.bit101.components.Label;

class SliderWithLabel
extends Slider
{
	private var valueLabel:Label;
	private var _fractionDigits:uint = 0;
	public function set fractionDigits(f:uint):void
	{
		_fractionDigits = f;
		drawLabel();
	}
	public function get fractionDigits():uint
	{
		return _fractionDigits;
	}
	public function SliderWithLabel(orientation:String = Slider.HORIZONTAL, parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number =  0, defaultHandler:Function = null)
	{
		super(orientation, parent, xpos, ypos, defaultHandler);
	}
	override protected function init():void
	{
		super.init();
		
		valueLabel = new Label(this);
		drawLabel();
		positionHandle();
		if (_orientation == HORIZONTAL)
		{
			valueLabel.y = _handle.y - valueLabel.height;
		}
		else
		{
			drawHandle();
			valueLabel.x = _handle.x + _handle.width + 4;
		}
		
		addEventListener(Event.CHANGE, function ():void 
		{
			drawLabel()
		});
	}
	private function drawLabel():void 
	{
		valueLabel.text = value.toFixed(fractionDigits);
		if(_orientation == HORIZONTAL)
		{
			valueLabel.x = _handle.x;
		}
		else
		{
			valueLabel.y = _handle.y;
		}
	}
	override public function set value(v:Number):void
	{
		super.value = v;
		dispatchEvent(new Event(Event.CHANGE));
	}
}
class Rose extends Shape
{
	public function Rose(radius:Number,n:uint,d:uint)
	{
		var c:Number = n/d;
		var g:Graphics = graphics;
		g.lineStyle(2, 0xcccccc);
		g.beginFill(0x0);
			
		for(var i:uint=0; i<360*d; i+=2)
		{
			var rad:Number = i * Math.PI /180;
			var v:Number = Math.sin(c * rad);
			var r:Number = radius * v;
				
			var x:Number = r * Math.cos(rad);
			var y:Number = r * Math.sin(rad);
				
			g.lineTo(x,y);
		}
		g.endFill();
	}
}
class Rect extends Shape
{
	public function Rect(w:Number, h:Number)
	{
		var g:Graphics = graphics;
		g.lineStyle(2, 0xcccccc);
		g.beginFill(0x0);
		g.drawRect( -w/2, -h/2, w, h);
		g.endFill();
	}
}
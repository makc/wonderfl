package 
{
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.text.*;
	import flash.filters.*;

	import caurina.transitions.Tweener;
	
	[SWF(width = "465", height = "465", backgroundColor = 0xFFFFFF, frameRate = "60")]
	
	public class Kirari2 extends Sprite 
	{

		private var startPt:Point;
		private var lineLayer:Shape = new Shape();
		public function Kirari2():void 
		{
			//bg
			graphics.beginFill(0);
			graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			Wonderfl.capture_delay( 5 );

			
			//event
			stage.addEventListener(MouseEvent.MOUSE_DOWN, function ():void 
			{
				addChild(lineLayer);
				startPt = new Point(mouseX, mouseY);
				stage.addEventListener(MouseEvent.MOUSE_MOVE, drawLineHandler);
			});
			
			stage.addEventListener(MouseEvent.MOUSE_UP, function ():void 
			{
				stage.removeEventListener(MouseEvent.MOUSE_MOVE, drawLineHandler);
				removeChild(lineLayer)
				lineLayer.graphics.clear();
				
				var endPt:Point = new Point(mouseX, mouseY);
				var kt:KirariText = new KirariText("wonderfl.net");
				kt.x = startPt.x;
				kt.y = startPt.y;
				var pt:Point = endPt.subtract(startPt);
				kt.scaleX = kt.scaleY = Point.distance(startPt, endPt) / kt.width;
				kt.rotation = 90 - Math.atan2(pt.x, pt.y) * 180 / Math.PI;
				kt.addEventListener(KirariText.COMPLETE, function():void
				{
					Tweener.addTween(kt, {
						alpha: 0,
						time:1.0,
						delay:0.2,
						onComplete: function ():void 
						{
							removeChild(kt);
							kt = null;
						}
					});

				});
				
				addChild(kt);
				
			});
			
		}
		private function drawLineHandler(e:MouseEvent):void 
		{
			var g:Graphics = lineLayer.graphics;

			g.clear();
			g.lineStyle(0, 0xffffff, 0.5);
			g.moveTo(startPt.x, startPt.y);
			g.lineTo(mouseX, mouseY);
		}


	}
	
}
import flash.display.*;
import flash.events.*;
import flash.geom.*;
import flash.text.*;
import flash.filters.*;

import caurina.transitions.Tweener;
class KirariText
extends Sprite
{
	public var t:Number = 0;
	public var lastT:Number = 0;
	private var tft:TextFormat = new TextFormat();
	public static const COMPLETE:String = "complete";
	public function KirariText(text:String):void 
	{
		//text
//		tft.align = TextFormatAlign.CENTER;
//		tft.bold = true;
//		tft.font = "Times New Roman";
		tft.size = 96;
			
		var tfd:TextField = new TextField();
		tfd.defaultTextFormat = tft;
		tfd.textColor = 0xddce44;
		tfd.mouseEnabled = false;
		tfd.autoSize = TextFieldAutoSize.LEFT;
		
		
		
		var tx:Number = 0;
		for (var i:int = 0; i < text.length; i++)
		{
			tfd.text = text.charAt(i);
			var bmd:BitmapData = new BitmapData(tfd.width, tfd.height, true, 0x000000); 
			bmd.draw(tfd)
			var bmp:WordBmp = new WordBmp(bmd);
			bmp.smoothing = true;
			bmp.x = tx;
			bmp.scaleX = bmp.scaleY = Math.random() * 0.8 + 1.0;
			
			tx += bmp.width * (0.6 + Math.random() * 0.2); ;
			
			
			bmp.y = (Math.random() * 1.0 + 5) * 10
			bmp.alpha = 0.0;
			bmp.rotation = (Math.random() - 0.5) * 10;
			Tweener.addTween(bmp, {
				alpha: 1,
				y: -bmp.height* (2.0 + Math.random() * 0.2 ),
				time: (1 - i / text.length) * 0.3 + 0.3 + Math.random()*0.05,
				delay: i / text.length * 0.3,
				transition: "easeOutQuart",
				onComplete: jumpupCompleteHandler,
				onCompleteParams: [bmp]
			});
			addChild(bmp);
		}
		start();
	}
	private function jumpupCompleteHandler(bmp:WordBmp):void 
	{
		Tweener.addTween(bmp, {
			y: -bmp.height * (1.0 - Math.random() *0.1) ,
			time: 0.5 + Math.random() * 0.4,
			transition: "easeOutBounce"
		});
	}

	private function start():void 
	{

		t = 0;
		lastT = 0;
		Tweener.removeTweens(this);
		Tweener.addTween(this, {
			t: numChildren,
			delay:1.5,
			time: 1.0,
			transition: "easeOutCubic",
			onUpdate: function ():void 
			{
				for (var i:int= lastT; i < t; i++)
				{
					var bmp:WordBmp = WordBmp(getChildAt(i));
					
					bmp.t = 0;
					Tweener.addTween(bmp, {
						t:1.0,
						time:0.3 +Math.random()*0.5,
						transition:"easeOutSine",
						onUpdate: function ():void 
						{
							bmp.filters = [
								new BevelFilter(6, 180 * bmp.t, 0xffffff, 1.0, 0x6c5718, 0.9, 4,4,10)
							];
						},
						onComplete: function ():void 
						{
							bmp.t = 0;
							Tweener.addTween(bmp, {
								t:1.0,
								time:0.2,
								transition: "easeOutCubic",
								onUpdate:function ():void 
								{
									bmp.filters = [
										new BevelFilter(6 - bmp.t * 2, 180, 0xffffc6, 1.0, 0x6c5718, 0.9, 4, 4, 10 - bmp.t * 8 )
									]										
								}	
							});
						}
					});
				}
				lastT = Math.ceil(t);
			},
			onComplete :function ():void 
			{
				dispatchEvent(new Event(COMPLETE));
			}
		})
	}
}
class WordBmp
extends Bitmap
{
	public var t:Number;
	public function WordBmp(bitmapData:BitmapData = null, pixelSnapping:String = "auto", smoothing:Boolean = false):void
	{
		super(bitmapData, pixelSnapping, smoothing);
							filters = [
								new BevelFilter(4, 180 * 0, 0xffffc6, 1.0, 0x6c5718, 0.9, 4,4, 2)
							];
	}
}
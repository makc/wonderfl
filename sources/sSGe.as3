package {
	import flash.display.*;
	import flash.geom.*;
	import flash.events.*;
	
	public class FlashTest extends Sprite {
		private var bmp:BitmapData = new BitmapData(24, 24, false);
		private var offsets:Array = new Array(new Point(), new Point());
		private var g:Shape = new Shape();
		private var circle:Vector.<Shape> = new Vector.<Shape>(bmp.width * bmp.height);
		
		function FlashTest() {
			graphics.beginFill(0x000000);
			graphics.drawRect(0, 0, 465, 465);
			
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(bmp.width, bmp.height, Math.PI/2);
			g.graphics.beginGradientFill(GradientType.LINEAR, [0x000000, 0xFFFFFF], [1, 1], [0, 255], matrix);
			g.graphics.drawRect(0, 0, bmp.width, bmp.height);
			
			for(var i:int = 0; i < bmp.width * bmp.height; i++) {
				circle[i] = Shape(addChild(new Shape()));
				circle[i].x = (i % bmp.width) * 20;
				circle[i].y = Math.floor(i / bmp.width) * 20;
				circle[i].graphics.beginFill(0xFFFFFF);
				circle[i].graphics.drawCircle(0, 0, 1);
			}
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		public function onEnterFrame(e:Event):void {
			bmp.perlinNoise(10, 8, 3, 0, false, true, 0, true, offsets);
			bmp.draw(g, null, null, BlendMode.OVERLAY);
			bmp.colorTransform(bmp.rect, new ColorTransform(3, 3, 3, 1, -256, -256, -256, 0));
			
			for(var i:int = 0; i < circle.length; i++) {
				circle[i].scaleX = circle[i].scaleY = (bmp.getPixel(i % bmp.width, Math.floor(i / bmp.width)) & 0xFF) / 16;
			}
			
			offsets[0].offset(0.2, -0.1);
			offsets[1].offset(-0.3, 0.05);
		}
	}
}
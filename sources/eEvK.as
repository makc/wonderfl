package
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;

	// Non-alchemy plasma based on Dennis Ippel needlessly slow code at
	// http://www.rozengain.com/blog/2009/04/02/alchemy-experiment-incredibly-fast-plasma/

	[SWF(width=465,height=465,frameRate=60)]
	public class Plasma extends Sprite {

		protected var plasma:Array = [];
		protected var palette_r:Array = [];
		protected var palette_g:Array = [];
		protected var palette_b:Array = [];
		protected var bmd_0:BitmapData;
		protected var bmd_1:BitmapData;

		
		public function Plasma () {
			bmd_0 = new BitmapData( stage.stageWidth, stage.stageHeight );
			bmd_1 = bmd_0.clone (); addChild ( new Bitmap( bmd_1 ) );

			var x:int, y:int;
			for( x = 0; x < 256; x++ ) {
				palette_r [x] = 0x10000 * int(128.0 + 128 * Math.sin(3.1415 * x / 16.0));
				palette_g [x] =   0x100 * int(128.0 + 128 * Math.sin(3.1415 * x / 128.0));
				palette_b [x] =       1 * 0;
			}

			for( x = 0; x < stage.stageWidth; x++ )	{
				plasma[ x ] = new Array( stage.stageHeight );
				for( y = 0; y < stage.stageHeight; y++ ) {
					var color : int = (
					      128 + ( 128.0 * Math.sin( x / 16 ) )
					    + 128 + ( 128.0 * Math.sin( y / 8 ) )
					    + 128 + ( 128.0 * Math.sin( ( x + y ) / 16 ) )
					    + 128 + ( 128.0 * Math.sin( Math.sqrt( x * x + y * y ) / 8 ) )
					) / 4;
					plasma[ x ][ y ] = color;
				}
			}

			bmd_0.lock();
 			for( x = 0; x < stage.stageWidth; x++ )
				for ( y = 0; y < stage.stageHeight; y++ )
					bmd_0.setPixel( x, y, (( plasma[ x ][ y ] ) % 256) * 0x10101);
			bmd_0.unlock();

			addEventListener( Event.ENTER_FRAME, enterFrameHandler );
		}

		protected function enterFrameHandler( event : Event = null ):void {
			// now, let's do things right way
			var shift : int = 5;
			while (shift -- > 0) {
				palette_r.push (palette_r.shift ());
				palette_g.push (palette_g.shift ());
				palette_b.push (palette_b.shift ());
			}
			bmd_1.paletteMap (bmd_0, bmd_0.rect, bmd_0.rect.topLeft, palette_r, palette_g, palette_b);
		}

	}
	
}
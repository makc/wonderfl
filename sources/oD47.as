package  
{
	/**
	 * ...
	 * @author hoge
	 * 40フレごとに大炎。
	 * クリックで中炎。 
	 * ドラッグで小炎。 
	 */
	import flash.display.Sprite;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DisplacementMapFilter;
	import flash.geom.Point;
	import flash.geom.Matrix;
	import flash.display.GradientType;
	import flash.geom.Rectangle;
    import flash.geom.ColorTransform;
	[SWF( width=465,height=465)]
	public class FlameBreath extends Sprite
	{
		private const ZERO_POINT:Point = new Point(0, 0);
		public function FlameBreath() 
		{
			const SW:int = stage.stageWidth;
			const SH:int = stage.stageHeight;
			var cnt:int = 0;
			var buf:BitmapData = new BitmapData(SW, SH, true, 0xff000000);
			var bmp:Bitmap = new Bitmap( buf.clone() );
			var fl:DisplacementMapFilter = createNoiseDisplaceFilter(SW, SH);
			var ar:Array = new Array();
			var arNext:Array = new Array();
			var bx:int = stage.stageWidth / 2;
			var by:int = stage.stageHeight / 2;
			var sprFire:Sprite = createFireGradient();
			var press:Boolean = false;
			var hUp:int = 2;
			var tmp:BitmapData = new BitmapData( fl.mapBitmap.width, hUp);
			var ct:ColorTransform = new ColorTransform( 0.9, 0.75, 0.75 );
			addChild( bmp );
			var mat:Matrix = new Matrix();
			var fire:Function = function(x:Number, y:Number, tx:Number, ty:Number, cnt:Number,sz:Number = 0.1,dl:int = 0 ):void {
				var dx:Number = tx-bx;
				var dy:Number = ty-by;
				var len:Number = Math.sqrt( dx * dx + dy * dy);
				if ( len != 0 ) {
					dx = 30 * dx / len;
					dy = 30 * dy / len;
				}
				ar.push( [x + Math.random() * 5,y + Math.sin( cnt * Math.PI/4)*5,  sz,0.04 + Math.random() * 0.04,dx,dy,cnt,dl]);
			};
			stage.addEventListener( Event.ENTER_FRAME, function( e:Event ):void {
				cnt++;
				buf.colorTransform( buf.rect, ct);
				arNext = new Array();
				for each( var o:Array in ar ) {
					for ( var i:int = 0; i < 3; i++ ){
						if ( o[7] > 0 ) {
							o[7]--;
							continue;
						}
						mat.identity();
						mat.translate( -sprFire.width / 2, -sprFire.height / 2);
						mat.scale( o[2], o[2] );
						mat.translate( o[0], o[1]);
						buf.draw( sprFire, mat, null, "add" );
						o[0] += o[4];
						o[1] += o[5];
						o[2] += o[3];
						o[6]--;
						if ( o[6] < 0 ) {
							break;
						}
					}
					if ( o[6] > 0 ) {
						arNext.push( o );
					}
				}
				tmp.copyPixels( fl.mapBitmap, tmp.rect, ZERO_POINT);
				fl.mapBitmap.scroll(0, -hUp);
				fl.mapBitmap.copyPixels( tmp, tmp.rect, new Point(0, fl.mapBitmap.height-hUp));
				bmp.bitmapData.applyFilter(buf, buf.rect, ZERO_POINT, fl);
				ar = arNext;
				if ( !press && ( cnt % 40 ) == 0)  {
					var len:int = 20 + Math.random() * 4;
					fire( bx,by,SW/2,SH/2,len*0.5,  (Math.random()*1+1),  0 );
					fire( bx,by,SW/2,SH/2,len,      0.1,  6*1 );
					fire( bx,by,SW/2,SH/2,len,      0.1,  6*2 );
					fire( bx,by,SW/2,SH/2,len,      0.1,  6*3 );
					fire( bx,by,SW/2,SH/2,len,      0.05, 6*3+10 );
					fire( bx,by,SW/2,SH/2,len*0.25, 0.1,  6*3+20 );
				}
			});
			stage.addEventListener(MouseEvent.MOUSE_DOWN, function( e:MouseEvent):void {
				press = true;
				fire( bx, by, SW / 2, SH / 2, 10 + Math.random() * 4, 0.05);
				cnt = 0;
			});
			stage.addEventListener(MouseEvent.MOUSE_UP, function( e:MouseEvent):void {
				press = false;
			});
			stage.addEventListener(MouseEvent.MOUSE_MOVE, function( e:MouseEvent):void {
				bx = mouseX;
				by = mouseY;
				if(press){
					fire( bx,by,bx,by,1,0.25);
				}
			});
		}
		private function createFireGradient():Sprite {
			var sh:Sprite = new Sprite();
			var colors:Array = [0xffffff,0xffff00,0xff8000,0x802000,0x402000];
			var alphas:Array = [1, 1, 1, 1, 0];
			var ratios:Array = [30,70,90,100,255];
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(256, 256, 0, 0, 0);
			sh.graphics.beginGradientFill(GradientType.RADIAL,colors,alphas,ratios, matrix);
			sh.graphics.drawRect(0, 0, 256, 256);
			sh.graphics.endFill();
			return sh;
		}
		private function createNoiseDisplaceFilter(w:int,h:int):DisplacementMapFilter {
			var bbuf:BitmapData = new BitmapData( w, h );
			bbuf.perlinNoise( 80, 80, 5, Math.random() * 0xffff, true, true, 2 | 4);
			var fl:DisplacementMapFilter = new DisplacementMapFilter(bbuf, ZERO_POINT, 2, 4, 100, 100, "clamp");
			return fl;
		}
	}
}
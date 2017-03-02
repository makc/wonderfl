package  {
	import flash.display.BlendMode;
	import flash.display.Sprite;
	import flash.filters.BlurFilter;
	import flash.geom.ColorTransform;	
	/**
	 * ...
	 * @author milkmidi     , http://milkmidi.blogspot.com
	 * * 
	 */
	[SWF(width = "465", height = "465", frameRate = "41", backgroundColor = "#000000")]
	public class GlowingEffectMove extends Sprite{
		public static const SizeW:int = 465;
		public static const SizeH:int = 465;
		private var circles:int = 20;
		public function GlowingEffectMove() {
			for (var i:int = 0; i<circles; i++) {								
				var _mc:CircleMC = new CircleMC();
				addChild(_mc);
				_mc.x = Math.random() * SizeW;			
				_mc.y = Math.random() * SizeH;							
				var scale:Number = Math.random() * .4 + .8;				
				_mc.scaleX = scale;
				_mc.scaleY = scale;				
				var _color:ColorTransform = new ColorTransform();
				_color.color = getRandomHex();
				_mc.transform.colorTransform = _color;
				_mc.blendMode = BlendMode.ADD;
				var blur:BlurFilter = new BlurFilter(64, 64, 2);
				_mc.filters = [blur];
				_mc.speedX = Math.round(Math.random() - 1) + .1;
				_mc.speedY = Math.round(Math.random() - 1) + .1; 				
			}
		}
		public static function getRandomHex():uint{
			var cr:uint = Math.random() * 255;
			var cg:uint = Math.random() * 255;
			var cb:uint = Math.random() * 255;
			return cr << 16 ^ cg  << 8 ^ cb;
		}
		
	}

}
import flash.display.Sprite
import flash.events.Event;
class CircleMC extends Sprite {
	
	public var speedX:Number;
	public var speedY:Number;
	
	public function CircleMC() {
		graphics.beginFill(0xaabbcc);
		graphics.drawCircle( 0, 0, 64);
		graphics.endFill();
		addEventListener(Event.ENTER_FRAME , _enterFrameHandler);
	}
	
	private function _enterFrameHandler(e:Event):void {
		x += speedX;
		y += speedY;
		if (x<0) {
			speedX = -speedX;
		}else if (x>GlowingEffectMove.SizeW) {
			speedX = -speedX;
		}
		if (y<0) {
			speedY = -speedY;
		}else if (y>GlowingEffectMove.SizeH) {
			speedY = -speedY;
		}		
	}
}
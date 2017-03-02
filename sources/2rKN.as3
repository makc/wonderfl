/**
 * FP10.2.151.49で見るとBitmapData.draw()のBlendModeが効いてない？
 * MinimalComps0.9.6のComboBoxにバグがあるっぽいのでRadioButtonに変更
 */
package  {
	
	import com.bit101.components.*;
	import flash.display.*;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.system.Capabilities;
	import flash.utils.describeType;
	
	public class Player102 extends Sprite {
		
		private var _bmd1:BitmapData;
		private var _bmd2:BitmapData;
		private var _bmd3:BitmapData;
		private var _blend:String = BlendMode.OVERLAY;
		
		public function Player102() {
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			_bmd1 = new BitmapData(100, 100);
			_bmd2 = new BitmapData(100, 100, false, 0xFFF2D10A);
			_bmd3 = _bmd1.clone();
			_bmd1.perlinNoise(50, 50, 4, 1234, false, true);
			
			Style.fontSize = 8 * 2;
			new Label(this, 10, -35, "Version : " + Capabilities.version);
			y = 35;
			addChild(new Bitmap(_bmd1)).x = 15;
			addChild(new Bitmap(_bmd2)).x = 145;
			addChild(new Bitmap(_bmd3)).x = 275;
			new Label(this, 122, 30, "+");
			new Label(this, 255, 30, "=");
			new Label(this, 10, 115, "BitmapData.draw() / BlendMode");
			
			Style.fontSize = 8 * 1;
			var vbox:VBox = new VBox(this, 300,122);
			for each(var k:String in describeType(BlendMode)..constant.@name)
				new RadioButton(vbox, 0, 0, k, k == _blend.toUpperCase(), onSelectBlendMode);
			
			updateDraw();
		}
		
		private function onSelectBlendMode(e:Event):void {
			_blend = BlendMode[RadioButton(e.currentTarget).label];
			updateDraw();
		}
		
		private function updateDraw():void{
			_bmd3.copyPixels(_bmd1, _bmd1.rect, new Point());
			_bmd3.draw(_bmd2, null, null, _blend);
		}
		
	}
	
}
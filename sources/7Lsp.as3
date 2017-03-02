
package
{
	import flash.display.Sprite;
	import flash.events.Event;
    import com.bit101.components.HUISlider;

	public class Main extends Sprite
	{
		private var _numSheets:Number = 6;
		private var _startFold:Number = -45;

		private var _sheets:Array     = [];
		private var _slider:HUISlider;
		private var _container:Sprite = new Sprite();
		
		public function Main()
		{
			addChild (_container);

	    	_container.z         = 10;
			
			makeSheets();
			parentSheets();
			makeSlider();
			fold (_startFold);
		}
			
		private function fold(inAmount:Number):void
		{
			for (var i:Number = 0; i < _sheets.length; i++)
	 		{
	 			var sheet:Sheet  = _sheets[i];
	 			sheet.rotationY = (i%2 == 1 ? inAmount : -inAmount);
			}
		}



		private function makeSheets ():void
		{
			for (var i:Number = 0; i < _numSheets; i++)
			{
				var sheet:Sheet = new Sheet (i);
				sheet.x        = _container.width;
				_container.addChild (sheet);
				_sheets.push (sheet);
			}
		}

		private function parentSheets ():void
		{
			for (var i:Number = 1; i < _sheets.length; i++)
			{
				var sheet:Sheet = _sheets[i];
				var p:Sheet    = _sheets[i - 1];
				sheet.x        = p.width;
				p.addChild (sheet);
			}
			
			_container.x = stage.stageWidth / 2 - _container.width/2;	
			_container.y = stage.stageHeight / 2 - _container.height;	
		}

		private function makeSlider():void
		{
			var _slider:HUISlider = new HUISlider(this, 0, 0, "Fold");
			_slider.width         = 300;
			_slider.minimum       = -180;
			_slider.maximum       = 0;
			_slider.value		  = _startFold;
			_slider.x             = stage.stageWidth / 2- _slider.width/2 + 10;
			_slider.y             = _container.y + _container.height + 50;
			addChild (_slider);
			_slider.addEventListener (Event.CHANGE, handleSlider);
		}


		private function handleSlider (e:Event=null):void
		{
			var amount:Number = e.target.value;
			fold(amount);
		}


	}
}

// -----------------------------------------------------
//	Sheet
// -----------------------------------------------------

import flash.events.MouseEvent;
import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.geom.*;

	class Sheet extends Sprite
	{
		private var w:Number = 50;
		private var h:Number = 100;
		
		private var tf:TextField = new TextField();
		public var id:Number = 0 ;
		
		public function Sheet (inID:Number):void
		{
			id = inID;
			
			var s:Sprite = new Sprite();
			addChild(s);
		
			var matr:Matrix = new Matrix();
			    matr.createGradientBox( w, h, 45, w-20, 0 );
			
			with (s.graphics)
			{
				beginGradientFill ( "linear", [0xEEEEEE , Math.random()*0xFFFFFF], [1,1], [0,255], matr, "pad" );
				lineStyle (1,0xAAAAAA,1);
				drawRect (0,0, w,h);
				endFill();
			}
			
			tf.selectable         = false;
			tf.mouseEnabled       = false;
			tf.text               = String(id);
			tf.width              = tf.height = 30;
			tf.x                  = s.width/2 - tf.width/2;
			tf.y                  = s.height/2;

			this.addChild(tf);

			var format:TextFormat = new TextFormat();
			format.size           = 30;
			format.color          = 0x333333;
			format.align		  = "center"
			tf.setTextFormat(format);
			
			s.addEventListener (MouseEvent.MOUSE_OVER, handleMouseOver);
			s.addEventListener (MouseEvent.MOUSE_OUT, handleMouseOut);
		}
		
		private function handleMouseOver (m:MouseEvent=null):void
		{
			Sheet (m.currentTarget.parent).tf.textColor = 0xFF0000
		}

		private function handleMouseOut (m:MouseEvent=null):void
		{
			Sheet (m.currentTarget.parent).tf.textColor = 0x333333
		}

		
	}


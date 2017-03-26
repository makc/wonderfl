/*
左下に数値入力後、右下の●をクリックでファンネル生成
生成後は画面の上半分あたりクリックで射出
*/

package
{
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	[SWF(width="300", height="300", backgroundColor="0x000000", frameRate="30")]  
	
	public class Main extends MovieClip
	{
		private var _bt_mc:MovieClip = new MovieClip();
		private var _txt:TextField = new TextField();
		private var _bitNum:uint=0;
		
		
		public function Main():void
		{
			_txt.height=30;
			_txt.x = 30;
			_txt.y = 270;
			_txt.background=true;
			_txt.backgroundColor=0xFFFFFF;
			_txt.type = TextFieldType.INPUT;
			_txt.text = "6";
			_txt.restrict="0-9";
			addChild(_txt);

			_bt_mc.graphics.beginFill(0xFF00FF);
			_bt_mc.graphics.drawCircle(0,0,20);
			_bt_mc.graphics.endFill();
			_bt_mc.x = 260;
			_bt_mc.y = 280;
			_bt_mc.buttonMode=true;
			_bt_mc.addEventListener(MouseEvent.CLICK, init);
			addChild(_bt_mc);
		}
		
		
		private function init(me:MouseEvent):void
		{
			stage.addEventListener(MouseEvent.MOUSE_UP, startMv);
			for(var i:uint=1; i<=_bitNum; i++){	removeChild( getChildByName("bit_"+i) );	}
			
			_bitNum = uint(_txt.text);
			
			for(i=1; i<=_bitNum; i++){
				var bit:Bit=new Bit();
				bit.name="bit_"+i;
				bit.rotation = 360*(i-1)/_bitNum;
				bit.x = 150 + 30*Math.sin(bit.rotation * Math.PI/180);
				bit.y = 150 + -30*Math.cos(bit.rotation * Math.PI/180);
				addChild(bit);
			}
		}
		
		
		private function startMv(me:MouseEvent):void
		{
			if(mouseY<250){
				stage.removeEventListener(MouseEvent.MOUSE_UP, startMv);
				for(var i:uint=1; i<=_bitNum; i++){	Bit(getChildByName("bit_"+i)).init( i%3*0.2 );	}
			}
		}
		
	}
}


	import flash.display.*;
	import flash.events.*;
	import gs.*; 
	import gs.easing.*;
	
	
	class Bit extends MovieClip
	{
		private var _laser_mc:MovieClip = new MovieClip();
		
		public function Bit():void
		{
			addEventListener(Event.REMOVED_FROM_STAGE, remove);
			
			graphics.beginFill(0xF0F0F0);
			graphics.moveTo( 0, 0 );
			graphics.lineTo( -5, 24 );
			graphics.lineTo( 5, 24 );
			graphics.endFill();
			
			_laser_mc.graphics.lineStyle(2, 0xFFFFCC);
			_laser_mc.graphics.moveTo(0, 0);
			_laser_mc.graphics.lineTo(0, -600);
			_laser_mc.scaleY=0;
			addChild( _laser_mc );
		}
		
		
		function remove(e:Event):void
		{
			removeEventListener(Event.ENTER_FRAME, rot);
			removeEventListener(Event.REMOVED_FROM_STAGE, remove);
			TweenMax.killTweensOf(this);
			TweenMax.killTweensOf(_laser_mc);
		}
		
		
		public function init(delayTime:Number):void
		{
			var startX:int = 150+300*Math.sin(rotation * Math.PI/180);
			var startY:int = 150-300*Math.cos(rotation * Math.PI/180);
			
			TweenMax.to( this, 0.2+Math.random()*0.2, { delay:delayTime, x:startX, y:startY, ease:Cubic.easeIn, onComplete:startMv});
		}
		
		
		public function startMv():void
		{
			addEventListener(Event.ENTER_FRAME, rot);
			
			var scaleVal:Number = 0.3+Math.random()*0.7;
			var bezierData:Array = [
															{x:Math.random()*300, y:Math.random()*300},
															{x:Math.random()*300, y:Math.random()*300}
															];
			
			TweenMax.to( this, 0.4+Math.random()*0.4, { delay:0.3+Math.random()*0.2, bezier:bezierData, scaleX:scaleVal, scaleY:scaleVal,
											 ease:Cubic.easeInOut, onComplete:shot});
		}
		
		
		private function shot():void
		{
			removeEventListener(Event.ENTER_FRAME, rot);
			
			_laser_mc.scaleY=0;
			_laser_mc.alpha=1;
			_laser_mc.visible=true;
			
			TweenMax.to(_laser_mc, 0.5, {scaleY:1, ease:Cubic.easeOut} );
			TweenMax.to(_laser_mc, 0.3, {delay:0.2, autoAlpha:0, ease:Linear.easeNone, onComplete:startMv} );
			
		}

		
		private function rot(e:Event):void
		{
			rotation = 180*Math.atan2(MovieClip(parent).mouseY-y, MovieClip(parent).mouseX-x)/Math.PI+90;
		}
		
		
	}


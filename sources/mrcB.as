package {
    import flash.display.Sprite;
    import flash.events.*;
    import frocessing.color.*;

    [SWF(frameRate=60, backgroundColor=0)]
    public class Test extends Sprite {
        private const RA : Number = 120;
        private const RB : Number = 120;
        private const AX : Number = -100;
        private const AY : Number = 565;
        private const BX : Number = 565;
        private const BY : Number = -100;
        private const OMEGAA : Number = 0.16;
        private const OMEGAB : Number = 0.12345;
        private const N : uint = 40;
  
        public function Test() {
            addEventListener(Event.ENTER_FRAME, onEnterFrame);
        }
        
        private var _t : Number = -Math.random() * 99999999;
        
        private function onEnterFrame(e : Event) : void
        {
        		graphics.clear();
            graphics.beginFill(0);
            graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
            graphics.endFill();

        		var hsv : ColorHSV = new ColorHSV(0, 1, 1);
        		for(var i : uint = 0;i < N;i++){
        			var theta : Number = 2 * Math.PI * i / N;
        			hsv.h = 360 * i / N;
	        		graphics.lineStyle(10, hsv.value, 0.3);
	        		graphics.moveTo(AX + RA * Math.cos(theta + OMEGAA * _t), AY + RA * Math.sin(theta + OMEGAA * _t));
	        		graphics.lineTo(BX + RB * Math.cos(theta + OMEGAB * _t), BY + RB * Math.sin(theta + OMEGAB * _t));
        		}
        		_t++;
        }
    }
}
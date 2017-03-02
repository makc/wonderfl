// write as3 code here..
package {	
	import flash.display.*;
	import flash.events.Event;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
    import flash.geom.Point;	

	[SWF(width = "500", height = "500", frameRate = "41", backgroundColor = "#000000", pageTitle = "milkmidi.com")]
	public class MouseGrowEffect extends Sprite
	{	
		private var dep:Number = 0;
        private var linearr:Array = new Array();
        private var dotarr:Array = new Array();
        private var draw_mc:Sprite = new Sprite();
        public function MouseGrowEffect() {
			this.addEventListener(Event.ADDED_TO_STAGE, onAdd2Stage);

        }
		
		private function onAdd2Stage(e:Event):void {
			this.addChild(draw_mc);
			var glow0:GlowFilter = new GlowFilter(0xffffff, 1, 16, 8, 1, 3, true, false);
			var glow1:GlowFilter = new GlowFilter(0xffff00, 1, 8, 8, 1, 3, false, false);
			var dropShadow0:DropShadowFilter = new DropShadowFilter(0, 90, 0xcc3300, 1, 64, 64, 5, 3, false, false, false);
			draw_mc.filters = [glow0, glow1, dropShadow0];			
			this.addEventListener(Event.ENTER_FRAME, onEventEnterFrame);
			
		}
		private function onEventEnterFrame(e:Event):void {
			var _obj:Object = new Object();
			if (mouseX != 0 && mouseX != 0) {
				_obj.x = mouseX;
				_obj.y = mouseY;
				dotarr.push(_obj);
			}
			if (dotarr.length > 15) {
				dotarr.splice(0,1);
			}
			var _g:Graphics = draw_mc.graphics;

			_g.clear();
			_g.lineStyle(0, 0xff0000, 100, true, "none", "round", "round", 1);				
			var _prevPoint:Point = null;
			var _dotLength:int = dotarr.length;		
			if(_dotLength <= 0) return;
			for (var i:int = 1; i < _dotLength; ++i) {		
				var _prevObj:Object = dotarr[i - 1];									
				var _currentObj:Object = dotarr[i];

				_g.lineStyle(i / 1.5  , 0xffffff, 1, true, "none", "round", "round", 1);				
				var _point:Point = new Point(_prevObj.x + (_currentObj.x - _prevObj.x) / 2, _prevObj.y + (_currentObj.y - _prevObj.y) / 2);				
				if (_prevPoint) {
					_g.moveTo(_prevPoint.x,_prevPoint.y);
					_g.curveTo(_prevObj.x,_prevObj.y,_point.x,_point.y);
				} else {
					_g.moveTo(_prevObj.x,_prevObj.y);
					_g.lineTo(_point.x,_point.y);
				}
				_prevPoint = _point;
			}
			if (_currentObj) {
				_g.lineTo(_currentObj.x, _currentObj.y);
			}		
			
		}		
	}
}



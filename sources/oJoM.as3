// forked from milkmidi's code on 2008-12-25
package {    
    import flash.display.*;
    import flash.events.Event;
    import flash.filters.DropShadowFilter;
    import flash.filters.GlowFilter;
    import flash.geom.Point;    

    [SWF(width = "465", height = "465", frameRate = "30", backgroundColor = "#000000", pageTitle = "milkmidi.com")]
    public class MouseGrowEffect extends Sprite
    {    
        private const N:int = 10;
        private var dotarr:Vector.<Point> = new Vector.<Point>(N, true);
        private var canvas:Shape = new Shape();

        public function MouseGrowEffect() {
            for (var i:int = 0; i < N; i++) dotarr[i] = new Point(mouseX, mouseY);
            this.addChild(canvas);
            var glow0:GlowFilter = new GlowFilter(0xffffff, 1, 16, 16, 1, 1, true, false);
            var glow1:GlowFilter = new GlowFilter(0x00ffff, 1, 8, 8, 1, 1, false, false);
            var dropShadow0:DropShadowFilter = new DropShadowFilter(0, 90, 0x0033cc, 1, 64, 64, 5, 3, false, false, false);
            canvas.filters = [glow0, glow1, dropShadow0];            
            this.addEventListener(Event.ENTER_FRAME, onEventEnterFrame);
        }
        
        private function onEventEnterFrame(e:Event):void {
            dotarr[N - 1].x = mouseX;
            dotarr[N - 1].y = mouseY;
            var _g:Graphics = canvas.graphics;
            _g.clear();            
            var _prevPoint:Point = dotarr[0];
            for (var i:int = 1; i < N; ++i) {        
                var _prev:Point = dotarr[i - 1];                                    
                var _current:Point = dotarr[i];
                _g.lineStyle(i, 0xffffff, 1, true, "none", "round", "round");                
                var _point:Point = new Point(_prev.x + (_current.x - _prev.x) / 2, _prev.y + (_current.y - _prev.y) / 2);                
                _g.moveTo(_prevPoint.x,_prevPoint.y);
                _g.curveTo(_prev.x,_prev.y,_point.x,_point.y);
                _prevPoint = _point;
                _prev.x = _current.x;
                _prev.y = _current.y;
            }
        }        
    }
}

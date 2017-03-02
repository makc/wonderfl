// forked from makc3d's Clock
// 軽く1打目 EnterFrame 内 212文字
package  {
	import flash.display.Sprite;
	public class Clock extends Sprite {
		public function Clock () {
			addEventListener("enterFrame", function():void {
				with(graphics)with(Math)with(new Date)c=cos,v=moveTo,l=lineTo,x=y=232,rotation=-90,clear(),v(lineStyle(2),l(99*c(s=seconds*(t=PI/30)),99*sin(s))),v(l(75*c(m=minutes*t),75*sin(m)),0),l(50*c(h=hours*t*5),50*sin(h))
			});
		}
	}
}
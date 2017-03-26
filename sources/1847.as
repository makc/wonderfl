// forked from meat18's EnterFrame内 156文字 forked from: Clock
// forked from Nicolas's EnterFrame内 158文字 forked from: Clock
// forked from nitoyon's EnterFrame内 168文字 forked from: Clock
// forked from meat18's forked from: EnterFrame内 192文字 forked from: Clock
// forked from bkzen's EnterFrame内 212文字 forked from: Clock
// forked from makc3d's Clock 
// 軽く1打目 EnterFrame 内 212文字

package {
	import flash.display.Sprite;
	public class FlashTest extends Sprite {
		public function FlashTest() {
			addEventListener("enterFrame", function():void {
				with(graphics)with(new Date)with(Math)for(clear(),lineStyle(y=2);y<232;)moveTo(0,lineTo(sin(i=[,l=50*y,hours*5,minutes,seconds][x=y++]*PI/30)*l,-cos(i)*l))
			});
        }
    }
}
//with(graphics)with(new Date)with(Math)
//	for(clear(),lineStyle(y=2);y<232;)
//		moveTo(0,lineTo(
//		sin(i=[,l=50*y,hours*5,minutes,seconds][x=y++]*PI/30)*l,-cos(i)*l))

// forked from bkzen's EnterFrame内 212文字 forked from: Clock
// forked from makc3d's Clock
// 軽く1打目 EnterFrame 内 212文字

//アプローチを変えて、192文字。

package {
	import flash.display.Sprite;
	public class FlashTest extends Sprite {
		public function FlashTest() {
			addEventListener("enterFrame", function():void {
				with(graphics){clear(),lineStyle(2),x=y=232,k=0,d=new Date;for(;k<3;k++){with(Math)p=PI/30,moveTo(0,0),lineTo(cos(i=[d.hours,d.minutes,d.seconds][k]*[p*5,p,p][k]-PI/2)*(l=50*(k+2)),sin(i)*l)}}
			});
        }
    }
}
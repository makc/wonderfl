/*
 * 3次元を投影する奴を応用したらできた4次元超立方体
 * 処理は適当なので気にしないでくださいな
 * 参考：http://ja.wikipedia.org/wiki/正八胞体
 *
 * 4/4 Point使えばいいよ的なコメントをいただいたのでPointにしてみる
 */
package {
	import flash.display.*;
	import flash.events.Event;
	import flash.geom.Point;
	[SWF(width="320", height="320", backgroundColor="0xffffff", frameRate="60")]
	public class FlashTest extends Sprite {
		private var i:uint;
		private var obj0:Point,obj1:Point,obj2:Point,obj3:Point,
			obj4:Point,obj5:Point,obj6:Point,obj7:Point,
			obj8:Point,obj9:Point,obj10:Point,obj11:Point,
			obj12:Point,obj13:Point,obj14:Point,obj15:Point;
		private var vx:Number,vy:Number,vz:Number,vw:Number;
		private var sf:Number,r:Number;
		private var t:Number,u:Number;
		private var n:int=4;
		public function FlashTest() {
			obj0=new Point();obj1=new Point();obj2=new Point();obj3=new Point();
			obj4=new Point();obj5=new Point();obj6=new Point();obj7=new Point();
			obj8=new Point();obj9=new Point();obj10=new Point();obj11=new Point();
			obj12=new Point();obj13=new Point();obj14=new Point();obj15=new Point();
			vx=0;
			vy=0;
			vz=0;
			vw=0;
			sf=360;
			r=100;//半径
			t=0;
			u=45;
			addEventListener("enterFrame", loop);
		}
		private function loop(e:Event):void{
			graphics.clear();
			for(i=0;i<n;i++){
				vx=Math.cos((t+360*i/n)/180*Math.PI)*r;
				vy=Math.cos(u/180*Math.PI)*r;//-71;//Math.cos((t/3+360*i/n)/180*Math.PI)*r;
				vz=Math.sin((t+360*i/n)/180*Math.PI)*r;
				vw=Math.sin(u/180*Math.PI)*r;
				vx=vx*sf/(sf+vw);
				vy=vy*sf/(sf+vw);
				vz=vz*sf/(sf+vw);
				this["obj"+i].x=vx*sf/(sf+vz)+160;
				this["obj"+i].y=vy*sf/(sf+vz)+160;
			}
			for(i=n;i<n*2;i++){
				vx=Math.cos((t+360*(i-n)/n)/180*Math.PI)*r;
				vy=Math.cos((u+90)/180*Math.PI)*r;//71;//Math.cos((t/3+360*(i-n)/n)/180*Math.PI)*r;
				vz=Math.sin((t+360*(i-n)/n)/180*Math.PI)*r;
				vw=Math.sin((u+90)/180*Math.PI)*r;
				vx=vx*sf/(sf+vw);
				vy=vy*sf/(sf+vw);
				vz=vz*sf/(sf+vw);
				this["obj"+i].x=vx*sf/(sf+vz)+160;
				this["obj"+i].y=vy*sf/(sf+vz)+160;
			}
			for(i=n*2;i<n*3;i++){
				vx=Math.cos((t+360*(i-2*n)/n)/180*Math.PI)*r;
				vy=Math.cos((u+180)/180*Math.PI)*r;//71;//Math.cos((t/3+360*(i-2*n)/n)/180*Math.PI)*r;
				vz=Math.sin((t+360*(i-2*n)/n)/180*Math.PI)*r;
				vw=Math.sin((u+180)/180*Math.PI)*r;
				vx=vx*sf/(sf+vw);
				vy=vy*sf/(sf+vw);
				vz=vz*sf/(sf+vw);
				this["obj"+i].x=vx*sf/(sf+vz)+160;
				this["obj"+i].y=vy*sf/(sf+vz)+160;
			}
			for(i=n*3;i<n*4;i++){
				vx=Math.cos((t+360*(i-3*n)/n)/180*Math.PI)*r;
				vy=Math.cos((u+270)/180*Math.PI)*r;//-71;//Math.cos((t/3+360*(i-3*n)/n)/180*Math.PI)*r;
				vz=Math.sin((t+360*(i-3*n)/n)/180*Math.PI)*r;
				vw=Math.sin((u+270)/180*Math.PI)*r;
				vx=vx*sf/(sf+vw);
				vy=vy*sf/(sf+vw);
				vz=vz*sf/(sf+vw);
				this["obj"+i].x=vx*sf/(sf+vz)+160;
				this["obj"+i].y=vy*sf/(sf+vz)+160;
			}
			graphics.lineStyle(1,0x000000,100);
			graphics.moveTo(obj3.x,obj3.y);
			for(i=0;i<4;i++)graphics.lineTo(this["obj"+i].x,this["obj"+i].y);
			for(i=7;i>3;i--)graphics.lineTo(this["obj"+i].x,this["obj"+i].y);
			graphics.lineTo(obj7.x,obj7.y);
			for(i=0;i<3;i++){graphics.moveTo(this["obj"+i].x,this["obj"+i].y);
			graphics.lineTo(this["obj"+(i+4)].x,this["obj"+(i+4)].y);}
			graphics.moveTo(obj11.x,obj11.y);
			for(i=8;i<12;i++)graphics.lineTo(this["obj"+i].x,this["obj"+i].y);
			for(i=15;i>11;i--)graphics.lineTo(this["obj"+i].x,this["obj"+i].y);
			graphics.lineTo(obj15.x,obj15.y);
			for(i=8;i<11;i++){graphics.moveTo(this["obj"+i].x,this["obj"+i].y);
			graphics.lineTo(this["obj"+(i+4)].x,this["obj"+(i+4)].y);}

			for(i=0;i<4;i++){graphics.moveTo(this["obj"+i].x,this["obj"+i].y);
			graphics.lineTo(this["obj"+(i+12)].x,this["obj"+(i+12)].y);}
			for(i=4;i<8;i++){graphics.moveTo(this["obj"+i].x,this["obj"+i].y);
			graphics.lineTo(this["obj"+(i+4)].x,this["obj"+(i+4)].y);}

			t+=(mouseX-160)/80;
			u+=(mouseY-160)/80;
		}
	}
}
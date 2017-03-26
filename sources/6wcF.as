// forked from SeeDa's Hairs
/*
 * マウスを追うヘビ
 * drawPathやめました
 */
package {
	import flash.display.*;
	import flash.geom.*;
	import flash.events.*;
	[SWF(width="465",height="465",backgroundColor="0x33aa66",frameRate="60")]
	
	public class Main extends Sprite {
		private var snakes:Array = new Array();
		public function Main():void {
			for (var i:uint = 0; i < 1; i++) {
				var snake:Snake = new Snake();
				addChild(snake);
				snakes.push(snake);
			}
		}
	}
}

import flash.display.*;
import flash.events.*;
import flash.geom.*;
import flash.filters.*;
class Snake extends Sprite {
	
	private var nSpeed:Number;
	private var nColor:uint;
	private var points:Vector.<Number> = new Vector.<Number>();
	private var commands:Vector.<int> = new Vector.<int>();
	private var pointsNum:uint = 60;
	private var pointDist:Number = 4;
	private var vibration:Number = 0;
	private var headP:Point;
	private var dsFilter:DropShadowFilter = new DropShadowFilter(6,30,0x666666,0.5);
	
	public function Snake():void {
		nSpeed   = 5;
		nColor = 0xffffff;
		
		commands.push(1);
		points.push(mouseX,mouseY);
		headP = new Point(mouseX,mouseY);
		
		for (var i:uint = 1; i < pointsNum; i++) {
			points.push(mouseX, mouseY);
			commands.push(2);
		}
		addEventListener(Event.ENTER_FRAME, xMove);
		Wonderfl.capture_delay( 30 );
	}
	private function xMove(e:Event):void {
		// ターゲットまでの距離を求める
		var mX:Number = mouseX;
		var mY:Number = mouseY;
		var dist:Number = Point.distance(new Point(headP.x,headP.y), new Point(mX, mY));
		
		if(dist > 30) {
			// ターゲットへの角度を求める
			var radian:Number = Math.atan2(mY-headP.y, mX-headP.x);
			
			// 振動値を加える
			var vibR:Number = radian+Math.PI/2;
			var vibX:Number = (50 * Math.cos(vibR)) * Math.sin(vibration);
			var vibY:Number = (50 * Math.sin(vibR)) * Math.sin(vibration);
			// 移動
			points[0] = headP.x + Math.cos(radian)*nSpeed;
			points[1] = headP.y + Math.sin(radian)*nSpeed;
			headP = new Point(points[0],points[1]);
			vibration+=0.2;
			points[0] += vibX;
			points[1] += vibY;
			// 2番目以降の点を移動する
			for (var i:uint = 1; i < pointsNum; i++) {
				var tP:Point = new Point(points[i*2-2], points[i*2-1]);
				var cP:Point = new Point(points[i*2], points[i*2+1]);
				dist = Point.distance(tP,cP);
				if (dist > pointDist) {
					var dX:Number = tP.x - cP.x;
					var dY:Number = tP.y - cP.y;
					var rad:Number = Math.atan2(dX,dY);
					dist -= pointDist;
					points[i*2] += Math.sin(rad) * dist;
					points[i*2+1] += Math.cos(rad) * dist;
				}
			}
			// 再描画
			graphics.clear();
			graphics.lineStyle(8,nColor);
			graphics.moveTo(points[0],points[1]);
			for (i = 1; i < pointsNum; i++) {
				if (i > pointsNum-40) {
					graphics.lineStyle(8*(pointsNum-i)/(pointsNum-40)/2,nColor);
				}
				graphics.lineTo(points[i*2],points[i*2+1]);
				
			}
			// 目玉をつけてみよう
			var eyeR:Number = Math.atan2(points[3]-points[1],points[2]-points[0]) + Math.PI/2;
			var eyeX:Number = (4 * Math.cos(eyeR));
			var eyeY:Number = (4 * Math.sin(eyeR));
			var headX:Number = (points[0]+points[2])/2;
			var headY:Number = (points[3]+points[1])/2;
			graphics.lineStyle(0,0,0);
			graphics.beginFill(0xff6666);
			graphics.drawCircle(headX+eyeX, headY+eyeY, 2);
			graphics.drawCircle(headX-eyeX, headY-eyeY, 2);
			filters = [dsFilter];
		}
	}
}
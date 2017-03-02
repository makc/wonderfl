/*
 * 毛束がマウスを追います
 * 筆にすることができそうです
 * 曲線は使ってません
 */
package {
	import flash.display.*;
	import flash.geom.*;
	import flash.events.*;
	[SWF(width="465",height="465",frameRate="30")]
	public class Hairs extends Sprite {
		private var hairs:Array = new Array();
		public function Hairs():void {
			for (var i:uint = 0; i < 20; i++) {
				var hair:Hair = new Hair();
				addChild(hair);
				hairs.push(hair);
			}
                        Wonderfl.capture_delay( 30 ); 
		}
	}
}

import flash.display.*;
import flash.events.*;
import flash.geom.*;
class Hair extends Sprite {
	private var myTarget:Shape;
	private var nSpeed:Number;
	private var points:Vector.<Number> = new Vector.<Number>();
	private var commands:Vector.<int> = new Vector.<int>();
	private var pointsNum:uint = 40;
	private var pointDist:Number = 4;
	public function Hair():void {
		nSpeed   = Math.random()*10+10;
		commands.push(1);
		points.push(mouseX,mouseY);
		for (var i:uint = 1; i < pointsNum; i++) {
			points.push(mouseX, mouseY);
			commands.push(2);
		}
		addEventListener(Event.ENTER_FRAME, xMove);
	}
	private function xMove(e:Event):void {
		// ターゲットまでの距離を求める
		var dist:Number = Point.distance(new Point(points[0],points[1]), new Point(mouseX, mouseY));
		if(dist > nSpeed) {
			// ターゲットへの角度を求める
			var radian:Number = Math.atan2(mouseY-points[1], mouseX-points[0]);
			// 移動
			points[0] += Math.cos(radian)*nSpeed;
			points[1] += Math.sin(radian)*nSpeed;
		
		}
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
		graphics.lineStyle(1,0x000000,0.4);
		graphics.drawPath(commands,points);
	}
}
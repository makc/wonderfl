/*
 * 点と点を曲線で繋ぐ
 * Please drag red Circle and confirm the change.
 */
package {
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.geom.Point;
	[SWF(width=465, height=465, backgroundColor=0x000000, frameRate=30)]
	public class Take02 extends Sprite {
		private const PNUM:uint = 12;
		private const ANGLE:Number = 360/PNUM;
		private const RADIUS:uint = 150;
		private const SW:uint = stage.stageWidth;
		private const SH:uint = stage.stageHeight;
		private var points:Vector.<Sprite> = new Vector.<Sprite>();
		private var drawStage:Shape;
		public function Take02():void {
			drawStage = new Shape();
			addChild(drawStage);
			for (var i:uint = 0; i < PNUM; i++) {
				var cp:ControlPoint = new ControlPoint();
				var myP:Point = Point.polar(RADIUS,ANGLE*i/180*Math.PI);
				myP.offset(SW/2,SH/2);
				cp.x = myP.x;
				cp.y = myP.y;
				addChild(cp);
				points.push(cp);
			}
			drawLine();
		}
		public function drawLine():void {
			drawStage.graphics.clear();
			drawStage.graphics.lineStyle(5,0xffffff);
			drawStage.graphics.moveTo(points[1].x,points[1].y);
			for (var i:uint = 0; i < PNUM; i++) {
				var pA:uint = (i+PNUM)%PNUM;
				var pB:uint = (pA+1)%PNUM;
				var pC:uint = (pB+1)%PNUM;
				var pD:uint = (pC+1)%PNUM;
				var cp:Array = getCurvePoint(points[pA],points[pB],points[pC],points[pD]);
				drawStage.graphics.curveTo(cp[0].x,cp[0].y,cp[1].x,cp[1].y);
				drawStage.graphics.curveTo(cp[2].x,cp[2].y,points[pC].x,points[pC].y);
			}
		}
		// 与えられた４点からその中間２点(A0,B0)を曲線で繋ぐための位置（controlPointA,mp,controlPointB）を求める
		private function getCurvePoint(a:Sprite, b:Sprite, c:Sprite, d:Sprite):Array {
			// Point targetA,targetBの距離
			var beforeA:Point = new Point(a.x, a.y);
			var targetA:Point = new Point(b.x, b.y);
			var targetB:Point = new Point(c.x, c.y);
			var afterB :Point = new Point(d.x, d.y);
			var connectL:Number = Point.distance(targetA,targetB);
			//var connectR:Number = getRadian(targetB,targetA);
			// コントロールポイント（controlPoint）の要素
			var controlPointA:Object = new Object();
			controlPointA.r = getRadian(targetB, beforeA);
			controlPointA.p = Point.distance(targetA, beforeA);	// この線にかかる力（接続線の距離）
			var controlPointB:Object = new Object();
			controlPointB.r = getRadian(targetA, afterB);
			controlPointB.p = Point.distance(targetB, afterB);	// この線にかかる力（接続線の距離）
			// 力のかかる比率 
			var ratio:Number = controlPointA.p/(controlPointA.p+controlPointB.p);
			// コントロールポイント（controlPoint）の位置を求める
			if (targetA.equals(beforeA)) {
				controlPointA.x = beforeA.x;
				controlPointA.y = beforeA.y;
			} else {
				controlPointA.l = connectL/2*ratio;	//*Math.tan(getRadianDiff(connectR,controlPointA.r));
				controlPointA.x = targetA.x + controlPointA.l*Math.cos(controlPointA.r);
				controlPointA.y = targetA.y + controlPointA.l*Math.sin(controlPointA.r);
			}
			if (targetB.equals(afterB)) {
				controlPointB.x = afterB.x;
				controlPointB.y = afterB.y;
			} else {
				controlPointB.l = connectL/2*(1-ratio);	//*Math.tan(getRadianDiff(controlPointB.r,connectR));
				controlPointB.x = targetB.x + controlPointB.l*Math.cos(controlPointB.r);
				controlPointB.y = targetB.y + controlPointB.l*Math.sin(controlPointB.r);
			}
			// 中間点（centerPoint）
			var centerPoint:Point = new Point();
			centerPoint.x = controlPointA.x + (controlPointB.x-controlPointA.x)*ratio;
			centerPoint.y = controlPointA.y + (controlPointB.y-controlPointA.y)*ratio;
			// 中間点と２つのコントロールポイントとを返す
			return ([controlPointA,centerPoint,controlPointB]);	
		}
		private function getRadian(a:Point,b:Point):Number {
			var dx:Number = (a.x - b.x);
			var dy:Number = (a.y - b.y);
			var radian:Number = Math.atan2(dy,dx);
			return (radian);
		}
	}
}
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.events.Event;
class ControlPoint extends Sprite {
	private var dFlag:Boolean = false;
	public function ControlPoint():void {
		graphics.beginFill(0xff0000);
		graphics.drawCircle(0,0,10);
		graphics.endFill();
		addEventListener(MouseEvent.MOUSE_DOWN, beginDrag);
		addEventListener(MouseEvent.MOUSE_UP, finishDrag);
		addEventListener(MouseEvent.MOUSE_MOVE, movePoint);
		buttonMode = true;
	}
	private function movePoint(e:Event):void {
		if (dFlag) e.target.parent.drawLine();
	}
	private function beginDrag(e:MouseEvent):void {
		dFlag = true;
		this.startDrag();
	}
	private function finishDrag(e:MouseEvent):void {
		dFlag = false;
		this.stopDrag();
	}
}
/*
 * ２つの円を円弧で繋ぐ
 * リアルな水滴の表現に向けて目玉焼きみたいな
 * 例外処理は未実装
 */
package {
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.events.Event;
	[SWF(width=400, height=400, backgroundColor=0x333366)]
	public class Take05 extends Sprite {
		private const SW:Number = stage.stageWidth;
		private const SH:Number = stage.stageHeight;
		private var circleA:Circle;
		private var circleB:Circle;
		private var nA:Number = 0;
		private var nB:Number = 0;
		public function Take05():void {
			circleA = new Circle();
			circleA.x = SW/2-55;
			circleA.y = SH/2+55;
			circleA.radius = 120;
			circleB = new Circle();
			circleB.x = SW/2+90;
			circleB.y = SH/2-90;
			circleB.radius = 90;
			// circleA,Bの位置を常時移動する
			addEventListener(Event.ENTER_FRAME, moveCircleB);
		}
		private function moveCircleB(eventObject:Event):void {
			nA+=0.07;
			circleA.y = SH/2 + 60*Math.sin(nA);
			nB+=0.15;
			circleB.y = SH/2 + 100*Math.sin(nB);
			graphics.clear();
			// ２つの円を曲線で繋ぐ
			getConectCenter(circleA, circleB, (circleA.radius+circleB.radius)/3);
			// オマケ
			graphics.beginFill(0xffcc00);
			graphics.drawCircle(circleA.x, circleA.y, circleA.radius/2);
			graphics.endFill();
			graphics.beginFill(0xffcc00);
			graphics.drawCircle(circleB.x, circleB.y, circleB.radius/2);
			graphics.endFill();
			graphics.lineStyle(16, 0xffffff);
			var pA:Point = new Point(circleA.x, circleA.y);
			graphics.moveTo(pA.x-circleA.radius*0.3, pA.y);
			drawArc(pA, circleA.radius*0.3, Math.PI*1, Math.PI*1.4)
			var pB:Point = new Point(circleB.x, circleB.y);
			graphics.moveTo(pB.x-circleB.radius*0.25, pB.y);
			drawArc(pB, circleB.radius*0.25, Math.PI*1, Math.PI*1.4)
		}
		// ２つの円を繋ぐ接続円を描く
		private function getConectCenter(circleA:Circle, circleB:Circle, radiusC:Number):void {
			// ３辺の長さを求める
			var pointA:Point = new Point(circleA.x,circleA.y);
			var pointB:Point = new Point(circleB.x,circleB.y);
			var distAC:Number = circleA.radius+radiusC;
			var distBC:Number = circleB.radius+radiusC;
			var distAB:Number = Point.distance(pointA,pointB);
			if (distAB < distBC+distAC) {
				// ヘロンの公式で三角形の高さを求める
				var nABC:Number = (distAB+distAC+distBC)/2;
				var area:Number = Math.sqrt(nABC*(nABC-distAB)*(nABC-distAC)*(nABC-distBC));
				var nH:Number = area/distAB*2;
				// ∠CABを求める
				var radianCAB:Number = Math.asin(nH / distAC);
				// pointAとpointBの角度を求める
				var radianAB:Number = Math.atan2((pointB.y-pointA.y),(pointB.x-pointA.x));
				// 交点C座標を求める
				var pointC:Point = Point.polar(distAC, radianCAB+radianAB);
				pointC.offset(pointA.x, pointA.y);
				if (radianCAB != 0) {
					// もう１つの交点D座標を求める
					var pointD:Point = Point.polar(distAC, -radianCAB+radianAB);
					pointD.offset(pointA.x, pointA.y);
					// ２つの円を円弧で繋いだ線を描画
					graphics.beginFill(0xffffff);
					graphics.lineStyle(16,0xffff99);
					var vAC:Number = Math.atan2((pointC.y-pointA.y),(pointC.x-pointA.x));
					var vAD:Number = Math.atan2((pointD.y-pointA.y),(pointD.x-pointA.x));
					var vBC:Number = Math.atan2((pointC.y-pointB.y),(pointC.x-pointB.x));
					var vBD:Number = Math.atan2((pointD.y-pointB.y),(pointD.x-pointB.x));
					var pointBegin:Point = Point.polar(circleA.radius,vAC);
					pointBegin.offset(pointA.x, pointA.y);
					graphics.moveTo(pointBegin.x, pointBegin.y);
					drawArc(pointA,circleA.radius,vAC,vAD+Math.PI*2);
					drawArc(pointD,radiusC,vAD+Math.PI,vBD+Math.PI);
					drawArc(pointB,circleB.radius,vBD,vBC);
					drawArc(pointC,radiusC,vBC+Math.PI,vAC+Math.PI);
					graphics.endFill();
					// オマケ
					graphics.beginFill(0xff6666);
					graphics.drawCircle(pointC.x, pointC.y, radiusC/2);
					graphics.endFill();
					graphics.beginFill(0xff6666);
					graphics.drawCircle(pointD.x, pointD.y, radiusC/2);
					graphics.endFill();
					graphics.lineStyle(16,0xffffff);
					graphics.moveTo(pointC.x-radiusC*0.2,pointC.y);
					drawArc(pointC,radiusC*0.2,Math.PI,Math.PI*1.3);
					graphics.moveTo(pointD.x-radiusC*0.2,pointD.y);
					drawArc(pointD,radiusC*0.2,Math.PI,Math.PI*1.3);
				}
			}
		}
		private function drawArc(center:Point, radius:Number, begin:Number, end:Number):void {
			// 描画範囲を取得
			var diffRadian:Number=end-begin;
			// 描画開始点を取得
			var pBegin:Point=Point.polar(radius,begin);
			pBegin.offset(center.x, center.y);
			var pEnd:Point=Point.polar(radius,end);
			pEnd.offset(center.x, center.y);
			// 中間点の数を求める
			var nStep:uint=Math.ceil(Math.abs(diffRadian)/Math.PI*4)-1;
			// 分割する角度を求める
			var stepRadian:Number = diffRadian / (nStep+1);
			// 開始点を求める
			var nY:Number=radius*Math.tan(stepRadian/2);
			var nDist:Number=Math.sqrt(Math.pow(radius,2)+Math.pow(nY,2));
			var currentRadian:Number=begin;
			for (var i:uint = 0; i < nStep; i++) {
				// 到達点
				var targetRadian:Number=currentRadian+stepRadian;
				var pTarget:Point=Point.polar(radius,targetRadian);
				pTarget.offset(center.x, center.y);
				// コントロールポイント（pControl）を求める
				var pControl:Point=Point.polar(nDist,currentRadian+stepRadian/2);
				pControl.offset(center.x, center.y);
				graphics.curveTo(pControl.x, pControl.y, pTarget.x, pTarget.y);
				// 開始点を更新
				currentRadian=targetRadian;
			}
			// 最終到達点までを描く
			stepRadian=end-currentRadian;
			nY=radius*Math.tan(stepRadian/2);
			nDist=Math.sqrt(Math.pow(radius,2)+Math.pow(nY,2));
			pControl=Point.polar(nDist,currentRadian+stepRadian/2);
			pControl.offset(center.x, center.y);
			graphics.curveTo(pControl.x, pControl.y, pEnd.x, pEnd.y);
		}
	}
}
import flash.display.Sprite;
class Circle extends Sprite {
	public var radius:Number = 100;
	public var color:uint = 0;
	public var nX:Number = 0;
	public var nY:Number = 0;
	public function Circle() {
	}
}
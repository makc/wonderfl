/*
 * 円弧を描く
 * 円を描くには45度以下に分割
 */
package {
	import flash.display.Sprite;
	import flash.geom.Point;
	[SWF(width=350, height=350, backgroundColor=0xffffff)]
	public class Arc extends Sprite {
		private const SW:Number=stage.stageWidth;
		private const SH:Number=stage.stageHeight;
		public function Arc():void {
			graphics.lineStyle(6,0x00ff00);
			drawArc(new Point(SW/2-50,SH/2-46), 100, Math.PI*0, Math.PI*1.95);
			graphics.lineStyle(6,0x0000ff);
			drawArc(new Point(SW/2+50,SH/2+46), 100, Math.PI*1, Math.PI*2.95);
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
			graphics.moveTo(pBegin.x, pBegin.y);
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
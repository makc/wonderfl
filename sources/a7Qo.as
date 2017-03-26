// forked from tatsuhisa's forked from: ２つの円を円弧で繋ぐ
// forked from Kay's ２つの円を円弧で繋ぐ
//http://wonderfl.kayac.com/code/5656d1a3a53ba7896347ae9527cce71ab1f2742e
/*
 * ２つの円を円弧で繋ぐ
 * リアルな水滴の表現に向けて目玉焼きみたいな
 * 例外処理は未実装
 */
package {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.BlendMode;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.filters.BlurFilter;
	import flash.geom.Point;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	[SWF(width=400, height=400, backgroundColor=0x000000, frameRate=60)]
	
	public class Take05 extends Sprite {
		
		private const SW:Number = stage.stageWidth;
		private const SH:Number = stage.stageHeight;
		private var circleA:Circle;
		private var circleB:Circle;
		private var nA:Number = 0;
		private var nB:Number = 0;
		
		//ADD
		private var contents:Shape;
		private var blackBmd:BitmapData;
		private var bitmap:Bitmap;
		
		private var point:Point;
		private var blur:BlurFilter;
		
		private var metaColor:uint = 0xFFFFFF;
		private var connect:Boolean = false;
		
		public function Take05():void {
			contents = new Shape();
			//addChild( contents );
			
			blackBmd = new BitmapData( stage.stageWidth, stage.stageHeight, true, 0x000000 );
			
			var bmd:BitmapData = new BitmapData( stage.stageWidth, stage.stageHeight, true, 0x000000 );
			bitmap = new Bitmap( bmd, "auto", true );
			addChild( bitmap );
			
			point = new Point( 0, 0 );
			blur = new BlurFilter( 8, 8, 1);
			
			circleA = new Circle();
			circleA.x = SW/2;
			circleA.y = SH/2;
			circleA.radius = 60;
			
			circleB = new Circle();
			circleB.x = SW/2+90;
			circleB.y = SH/2-90;
			circleB.radius = 20;
			
			// circleA,Bの位置を常時移動する
			addEventListener(Event.ENTER_FRAME, moveCircleB);
		}
		
		
		private function moveCircleB(eventObject:Event):void {
			/*
			nA+=0.03;
			//circleA.y = SH/2 + 60*Math.sin(nA);
			nB+=0.07;
			//circleB.y = SH/2 + 100*Math.sin(nB);
			circleB.x = SW/2 + 180*Math.sin(nA);
			circleB.y = SH/2 + 150*Math.sin(nB);
			*/
			circleB.x = mouseX;
			circleB.y = mouseY;
			
			var pointA:Point = new Point(circleA.x,circleA.y);
			var pointB:Point = new Point(circleB.x,circleB.y);
			var distAB:Number = Point.distance(pointA, pointB);
			
			
			if ( distAB <= circleA.radius )
			{
				connect = true;
			}
			
			contents.graphics.clear();
			// ２つの円を曲線で繋ぐ
			getConectCenter( contents, circleA, circleB, distAB/2);
			
			var bmd:BitmapData = bitmap.bitmapData;
			bmd.lock();
			bmd.merge( blackBmd, bmd.rect, point, 32, 32, 32, 32 );
			//bmd.draw( blackBmd );
			bmd.applyFilter( bmd, bmd.rect, point, blur);
			bmd.draw( contents, null, null, BlendMode.ADD, null, true );
			bmd.unlock();
		}
		
		
		// ２つの円を繋ぐ接続円を描く
		private function getConectCenter( drawArea:Shape, circleA:Circle, circleB:Circle, radiusC:Number ):void {
			// ３辺の長さを求める
			var pointA:Point = new Point(circleA.x,circleA.y);
			var pointB:Point = new Point(circleB.x,circleB.y);
			var distAC:Number = circleA.radius+radiusC;
			var distBC:Number = circleB.radius+radiusC;
			var distAB:Number = Point.distance(pointA, pointB);
			
			if (distAB < distBC+distAC) {
				// ヘロンの公式で三角形の高さを求める
				var nABC:Number = (distAB+distAC+distBC)/2;
				var area:Number = Math.sqrt(nABC*(nABC-distAB)*(nABC-distAC)*(nABC-distBC));
				var nH:Number = area/distAB*2;
				// ∠CABを求める
				var radianCAB:Number = Math.asin(nH / distAC);
				
				// pointAとpointBの角度を求める
				var radianAB:Number = Math.atan2((pointB.y - pointA.y), (pointB.x - pointA.x));
				
				// 交点C座標を求める
				var pointC:Point = Point.polar(distAC, radianCAB+radianAB);
				pointC.offset(pointA.x, pointA.y);
				if ( radianCAB != 0 ) {
					// もう１つの交点D座標を求める
					var pointD:Point = Point.polar(distAC, -radianCAB+radianAB);
					pointD.offset(pointA.x, pointA.y);
					
					// ２つの円を円弧で繋いだ線を描画
					drawArea.graphics.beginFill(metaColor);
					//graphics.lineStyle(16,0xffff99);
					var vAC:Number = Math.atan2((pointC.y-pointA.y),(pointC.x-pointA.x));
					var vAD:Number = Math.atan2((pointD.y-pointA.y),(pointD.x-pointA.x));
					var vBC:Number = Math.atan2((pointC.y-pointB.y),(pointC.x-pointB.x));
					var vBD:Number = Math.atan2((pointD.y-pointB.y),(pointD.x-pointB.x));
					var pointBegin:Point = Point.polar(circleA.radius, vAC);
					pointBegin.offset(pointA.x, pointA.y);
					
                    if (connect)
					{
						if ( Point.distance( pointC, pointD )/2 > radiusC && distAB >= ( circleA.radius + circleB.radius ) )
						{
							drawArea.graphics.moveTo(pointBegin.x, pointBegin.y);
							drawArc( drawArea, pointA, circleA.radius, vAC, vAD);
							drawArc( drawArea, pointD, radiusC, vAD + Math.PI, vBD + Math.PI);
							drawArc( drawArea, pointB, circleB.radius, vBD, vBC);
							drawArc( drawArea, pointC, radiusC, vBC + Math.PI, vAC + Math.PI);
							drawArea.graphics.endFill();
						}
						else if( distAB < ( circleA.radius + circleB.radius ) )
						{
							drawArea.graphics.moveTo(pointBegin.x, pointBegin.y);
							drawArc( drawArea, pointA, circleA.radius, vAC, vAD);
							drawArc( drawArea, pointD, radiusC, vAD + Math.PI, vBD + Math.PI);
							drawArc( drawArea, pointB, circleB.radius, vBD, vBC);
							drawArc( drawArea, pointC, radiusC, vBC + Math.PI, vAC + Math.PI);
							drawArea.graphics.endFill();
						}
						else
						{
							connect = false;
						}
					}
					
					//確認用
					/*
					drawArea.graphics.beginFill( 0xFF0000, 0.5 );
					drawArea.graphics.drawCircle( pointC.x, pointC.y, radiusC );
					drawArea.graphics.endFill();
					drawArea.graphics.beginFill( 0xFF0000, 0.5 );
					drawArea.graphics.drawCircle( pointD.x, pointD.y, radiusC );
					drawArea.graphics.endFill();
					*/
				}
				
			}
			
			drawArea.graphics.beginFill(metaColor);
			drawArea.graphics.lineStyle(1, metaColor);
            drawArea.graphics.drawCircle( pointA.x, pointA.y, circleA.radius );
            drawArea.graphics.endFill();
            
            drawArea.graphics.beginFill(metaColor);
			drawArea.graphics.lineStyle(1, metaColor);
            drawArea.graphics.drawCircle( pointB.x, pointB.y, circleB.radius );
            drawArea.graphics.endFill();
            
		}
		
		
		private function drawArc(drawArea:Shape, center:Point, radius:Number, begin:Number, end:Number ):void {
			// 描画範囲を取得
			//trace( end, begin );
			if ( end > begin )
			{
				end -= Math.PI * 2;
			}
			var diffRadian:Number = end - begin;
			// 描画開始点を取得
			var pBegin:Point=Point.polar(radius,begin);
			pBegin.offset(center.x, center.y);
			var pEnd:Point=Point.polar(radius,end);
			pEnd.offset(center.x, center.y);
			
			//trace(diffRadian);
			
			// 中間点の数を求める
			var nStep:uint = Math.ceil( Math.abs(diffRadian) / Math.PI * 4) - 1;
			
			// 分割する角度を求める
			var stepRadian:Number = diffRadian / (nStep + 1);
			
			// 開始点を求める
			var nY:Number=radius*Math.tan(stepRadian/2);
			var nDist:Number = Math.sqrt(Math.pow(radius, 2) + Math.pow(nY, 2));
			var currentRadian:Number=begin;
			for (var i:uint = 0; i < nStep; i++) {
				// 到達点
				var targetRadian:Number=currentRadian+stepRadian;
				var pTarget:Point=Point.polar(radius,targetRadian);
				pTarget.offset(center.x, center.y);
				// コントロールポイント（pControl）を求める
				var pControl:Point=Point.polar(nDist,currentRadian+stepRadian/2);
				pControl.offset(center.x, center.y);
				drawArea.graphics.curveTo(pControl.x, pControl.y, pTarget.x, pTarget.y);
				// 開始点を更新
				currentRadian=targetRadian;
			}
			// 最終到達点までを描く
			stepRadian=end-currentRadian;
			nY=radius*Math.tan(stepRadian/2);
			nDist=Math.sqrt(Math.pow(radius,2)+Math.pow(nY,2));
			pControl=Point.polar(nDist,currentRadian+stepRadian/2);
			pControl.offset(center.x, center.y);
			drawArea.graphics.curveTo(pControl.x, pControl.y, pEnd.x, pEnd.y);
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

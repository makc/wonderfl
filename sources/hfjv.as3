/*
 * PerfumeのPV 'baby cruising Love'の中に出てくる光のエフェクトを再現してみました。
 * 1:13他　何回か出てきます
 * 
 * Youtube [PV] "Perfume" baby cruising Love 2nd Enc
 * http://www.youtube.com/watch?v=76yVixuKqGY
 * 
 * マウスドラッグで光を描きます
 * ハートの形とか可愛いかも
 * 
 * http://www.kuma-de.com/blog/1-programming/1-javascript/2009-09-07/1202
 */

package  
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.BitmapFilter;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.BlurFilter;
	import flash.filters.GlowFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.PerspectiveProjection;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Utils3D;
	import flash.geom.Vector3D;
	import flash.sampler.NewObjectSample;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
        [SWF(width = "480", height = "480", backgroundColor = 0x000000, frameRate = "30")]
	public class Main extends Sprite
	{
		public var penSp:Sprite;
		public var canvas:Bitmap;
		public var currentBmd:BitmapData;
		public var lastDrawPoint:Point;
		public var drawPoints:Vector.<DrawPoint>;
		public var proj:Matrix3D;
		public var vout:Vector.<Number> = new Vector.<Number>();
		public var uvts:Vector.<Number> = new Vector.<Number>();
		public var projverts:Vector.<Number> = new Vector.<Number>();
		public var moveCount:int = 0;
		
		public var hsw:Number;
		public var hsh:Number;
		
		public var logText:TextField;
		
		
		public function Main() 
		{
			stage.addEventListener(MouseEvent.MOUSE_DOWN, initHD);
		}
		
		private function initHD(e:MouseEvent):void 
		{
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, initHD);

			hsw = stage.stageWidth / 2;
			hsh = stage.stageHeight / 2;
			
			var perse:PerspectiveProjection = new PerspectiveProjection();
			perse.focalLength = 350;
			proj = perse.toMatrix3D();
			drawPoints = new Vector.<DrawPoint>();
			initCanvas();
			initLog();
			
			stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHD);
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHD);
			stage.addEventListener(Event.ENTER_FRAME, update);
		}
		
		private function initLog():void
		{
			logText = new TextField();
			addChild(logText);
			logText.x = 8;
			logText.y = 6;
			var tf:TextFormat = new TextFormat();
			tf.color = 0xffffff;
			tf.size = 10;
			tf.font = "_gothicMono";
			logText.selectable = false;
			logText.defaultTextFormat = tf;
		}
		
		private function initCanvas():void
		{
			var w:Number = stage.stageWidth;
			var h:Number = stage.stageHeight;
			currentBmd = new BitmapData(w, h, true, 0xff000000);
			canvas = new Bitmap(currentBmd);
			addChild(canvas);
			
			penSp = new Sprite();
			penSp.filters = [getGlowFilter(), getBlurFilter()];
		}
		
        private function getGlowFilter():GlowFilter {
            var color:Number = 0xFFF2D3;
            var alpha:Number = 0.85;
            var blurX:Number = 16;
            var blurY:Number = 16;
            var strength:Number = 3;
            var inner:Boolean = false;
            var knockout:Boolean = false;
            var quality:Number = BitmapFilterQuality.HIGH;

            return new GlowFilter(color,
                                  alpha,
                                  blurX,
                                  blurY,
                                  strength,
                                  quality,
                                  inner,
                                  knockout);
        }
		
        private function getBlurFilter():BlurFilter {
            var blurX:Number = 2;
            var blurY:Number = 2;
            return new BlurFilter(blurX, blurY, BitmapFilterQuality.HIGH);
        }

		
		private function update(e:Event):void 
		{
			updateDrawPoints();
			updateDraw();
			
			var r:Rectangle = currentBmd.rect;
			currentBmd.lock();
			currentBmd.fillRect(r, 0x000000);
			currentBmd.draw(penSp, new Matrix(), new ColorTransform(), null, r);
			currentBmd.unlock();
			logText.text = "POINTS:" + drawPoints.length.toString();
		}
		
		public function updateDraw():void
		{
			var g:Graphics = penSp.graphics;
			g.clear();
			var len:int = drawPoints.length;
			var drawPoint:DrawPoint;
			
			var verts:Vector.<Number> = new Vector.<Number>();
			var i:int;
			for (i = 0; i < len; i++) {
				drawPoint = drawPoints[i];
				verts.push(drawPoint.drawX, drawPoint.drawY);
			}
			if (verts.length > 8) {
				drawThickSprine(g, verts, 3);
			}
		}
		
		//参考　FrocessingではじめるActionScriptドローイング 第4回　スケッチしてみよう
		//http://gihyo.jp/design/feature/01/frocessing/0004?page=4
		private function drawThickSprine(g:Graphics, verts:Vector.<Number>, thick:Number):void
		{
			var verts0:Vector.<Number> = new Vector.<Number>();
			var verts1:Vector.<Number> = new Vector.<Number>();
			
			var i:int;
			var len:int = verts.length;
			var vx:Number, vy:Number;
			var pt:Point;
			var px0:Number = verts[0];
			var py0:Number = verts[1];
			var px1:Number, py1:Number;
			var drawPoint:DrawPoint;
			for (i = 2; i + 1 < len; i += 2) {
				px1 = verts[i];
				py1 = verts[i + 1];
				vx = px1 - px0;
				vy = py1 - py0;
				pt = new Point(vx, vy);
				pt.normalize(1);
				verts0.push(Math.floor(px0 + pt.y * thick));
				verts0.push(Math.floor(py0 - pt.x * thick));
				verts1.push(Math.floor(px0 - pt.y * thick));
				verts1.push(Math.floor(py0 + pt.x * thick));
				px0 = px1;
				py0 = py1;
			}
			
			var dVerts0:Vector.<Number> = new Vector.<Number>();
			var dVerts1:Vector.<Number> = new Vector.<Number>();
			
			//初期値
			dVerts0.push(0, 0, verts0[0], verts0[1], verts0[2], verts0[3], verts0[4], verts0[5]);
			dVerts1.push(verts1[4], verts1[5], verts1[2], verts1[3], verts1[0], verts1[1], 0, 0);
			
			//描画
			len -= 2;
			for (i = 6; i + 1 < len; i += 2) {
				dVerts0.shift();
				dVerts0.shift();
				dVerts0.push(verts0[i], verts0[i + 1]);
				dVerts1.unshift(verts1[i], verts1[i + 1]);
				dVerts1.pop();
				dVerts1.pop();
				drawPoint = drawPoints[Math.floor(i / 2)];
				g.beginFill(0xFFFEF1, drawPoint.timeFactor);
				g.moveTo(dVerts0[2], dVerts0[3]);
				splineTo(g, dVerts0, 3);
				g.lineTo(dVerts1[2], dVerts1[3]);
				splineTo(g, dVerts1, 3);
				g.lineTo(dVerts0[2], dVerts0[3]);
				g.endFill();
			}
		}
	
		//参考　Catmull-Rom スプライン曲線
		//http://l00oo.oo00l.com/blog/archives/264
		
		//verts: (x0, y0, x1, y1, x2, y2, x3, y3)
		private function splineTo(g:Graphics, verts:Vector.<Number>, numSegments:int):void
		{
			var i:int;
			var len:int = verts.length;
			var t:Number;
			for (i = 0; i < numSegments; i++) {
				t = (i + 1) / numSegments;
				g.lineTo(
					catmullRom(verts[0], verts[2], verts[4], verts[6], t),
					catmullRom(verts[1], verts[3], verts[5], verts[7], t)
				);
			}
		}
	
		private function catmullRom(p0:Number, p1:Number, p2:Number, p3:Number, t:Number):Number
		{
			var v0:Number = (p2 - p0) * 0.5;
			var v1:Number = (p3 - p1) * 0.5;
			return (2 * p1 - 2 * p2 + v0 + v1) * t * t * t + ( -3 * p1 + 3 * p2 - 2 * v0 - v1) * t * t + v0 * t + p1;
		}
		
		//時間がきたら消去
		public function updateDrawPoints():void
		{
			if (drawPoints.length < 1) {
				return;
			}
			var drawPoint:DrawPoint = drawPoints[0];
			
			while (drawPoint.nextPoint != null){
				drawPoint.aliveTime--;
				if (drawPoint.aliveTime < 1) {
					drawPoints.shift();
				}
				updateDrawPoint(drawPoint);
				drawPoint = drawPoint.nextPoint;
			}
			updateDrawPoint(drawPoint);
			drawPoint.aliveTime--;
			if (drawPoint.aliveTime < 1) {
				drawPoints.shift();
			}
		}
		
		//時間に応じてY軸回転
		private function updateDrawPoint(drawPoint:DrawPoint):void
		{
			var mat:Matrix3D = new Matrix3D();
			mat.appendRotation((1 - drawPoint.timeFactor) * 540, Vector3D.Y_AXIS);
			mat.appendTranslation(0, 0, 500);
			mat.transformVectors(Vector.<Number>([drawPoint.x, drawPoint.y, drawPoint.z]), vout);
			Utils3D.projectVectors(proj, vout, projverts, uvts);
			drawPoint.drawX = projverts[0] + hsw;
			drawPoint.drawY = projverts[1] + hsh;
		}
		
		private function mouseUpHD(e:MouseEvent):void 
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHD);
		}
		
		private function mouseDownHD(e:MouseEvent):void 
		{
			stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHD);
		}
		
		private function mouseMoveHD(e:MouseEvent = null):void 
		{
			//制御点をあまりとりすぎないように間引く
			moveCount++;
			if (moveCount % 3 != 0) {
				return;
			}
			moveCount = 0;
			
			//領域を超えたら描画しない
			if (stage.mouseX > stage.stageWidth || stage.mouseY > stage.stageHeight) {
				return;
			}
			
			var drawPoint:DrawPoint = new DrawPoint(stage.mouseX -hsw, stage.mouseY -hsh);
			if (drawPoints.length > 0) {
				drawPoints[drawPoints.length - 1].nextPoint = drawPoint;
			}
			drawPoints.push(drawPoint);
		}
	}
}

import flash.display.Sprite;

class DrawPoint 
{
	public var x:Number;
	public var y:Number;
	public var z:Number;
	public var aliveTime:int = 300;
	public var nextPoint:DrawPoint;
	public var drawX:Number;
	public var drawY:Number;
	public function get timeFactor():Number 
	{
		return aliveTime / 300;
	}
	
	public function DrawPoint(x:Number, y:Number) {
		this.x = x;
		this.y = y;
		this.z = 0;
	}
}

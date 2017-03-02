/**
 * Copyright matsu4512 ( http://wonderfl.net/user/matsu4512 )
 * MIT License ( http://www.opensource.org/licenses/mit-license.php )
 * Downloaded from: http://wonderfl.net/c/9nuR
 */

package {
	import flash.display.*;
	import flash.events.*;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	
	[SWF(width=465,height=465,backgroundColor=0x0)]
	
	public class ColorfulSpring extends Sprite {
		private var array:Array = [];
		private const N:int = 10, minDist:int = 5, springAmount:Number = 0.0075;
		private var canvas:Bitmap, bmpData:BitmapData, sp:Sprite;
		private var tr:ColorTransform = new ColorTransform(0.97,0.97,0.995,1);
		
		public function ColorfulSpring() {
			graphics.beginFill(0);
			graphics.drawRect(0,0,465,465);
			graphics.endFill();
			
			sp = new Sprite();
			for(var i:int = 0; i < N; i++){
				//var ball:Ball = new Ball(Math.random() * 10 - 5, Math.random() * 10 - 5, Math.random()*20+10, Math.random() * 0xFFFFFF);
				var ball:Ball = new Ball(
					Math.random()*2-1,
					Math.random()*2-1,
					i * 18 + 30,
					Math.random() * 0xFFFFFF
				);
				array.push(ball);
				ball.x = stage.stageWidth / 2 + (Math.random() * 10 - 5);
				ball.y = stage.stageHeight / 2 + (Math.random() * 10 - 5);
				ball.rotationX = Math.random() * 360;
				ball.rotationY = Math.random() * 360;
				sp.addChild(ball);
			}
			
			bmpData = new BitmapData(stage.stageWidth, stage.stageHeight, true, 0xFF000000);
			canvas = new Bitmap(bmpData);
			addChild(canvas);
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		private function onEnterFrame(e:Event):void {
			
			bmpData.colorTransform(bmpData.rect, tr);
			bmpData.draw(sp);
			
			var len:uint = N;
			while(len--) {
				var ball:Ball = array[len];
				ball.rotationX += ball.vx;
				ball.rotationY += ball.vy;
				ball.alpha += (ball.toAlpha-ball.alpha)/4;
				ball.toAlpha = 0;
				//if(ball.x < -20) ball.x = stage.stageWidth+20;
				//else if(ball.x > stage.stageWidth+20) ball.x = -20;
				//if(ball.y < -20) ball.y = stage.stageHeight+20;
				//else if(ball.y > stage.stageHeight+20) ball.y = -20;
			}
			
			sp.graphics.clear();
			for(var i:int = 0; i < N - 1; i++){
				var partA:Ball = array[i];
				for(var j:uint = i + 1; j < N; j++){
					var partB:Ball = array[j];
					spring(partA, partB);
				}
			}
		}
		
		private function spring(b1:Ball, b2:Ball):void{
			var dx:Number = b2.x - b1.x;
			var dy:Number = b2.y - b1.y;
			var dist:Number = Math.sqrt(dx * dx + dy * dy);
			if(dist < minDist){				
				sp.graphics.lineStyle(1);
				var m:Matrix = new Matrix;
				m.createGradientBox(Math.abs(dx), Math.abs(dy), Math.atan2(dy,dx), Math.min(b1.x, b2.x), Math.min(b1.y, b2.y));
				sp.graphics.lineGradientStyle(GradientType.LINEAR, [b1.color, b2.color], [b1.alpha, b2.alpha],	[0,255], m);
				sp.graphics.moveTo(b1.x, b1.y);
				sp.graphics.lineTo(b2.x, b2.y);
				b1.toAlpha += 0.1;
				b2.toAlpha += 0.1;
				var ax:Number = dx * springAmount;
				var ay:Number = dy * springAmount;
				b1.vx += ax / b1.r;
				b1.vy += ay / b1.r;
				b2.vx -= ax / b2.r;
				b2.vy -= ay / b2.r;
			}
		}
	}
}

import flash.display.*;
import flash.filters.*;

class Ball extends Sprite {
	public var vx:Number, vy:Number, r:Number, toAlpha:Number, color:uint;
	
	public function Ball(vx:Number, vy:Number, r:Number, color:uint) {
		this.vx = vx; this.vy = vy; this.r = r; this.color = color;
		toAlpha = 0;
		
		graphics.lineStyle(1,0xFFFFFF);
		graphics.drawCircle(0, 0, r);
		filters = [new GlowFilter(color, 1, 6, 6 ,2), new BlurFilter(4,4)];
		blendMode = BlendMode.ADD;
	}
}

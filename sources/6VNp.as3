// パターンマッチングによるカメラの移動方向推定
//
// 映像を縮小し、全体をすこしずつ移動して直前のフレームと
// 重ねあわせ、その差を比較することで移動方向を推定。
// SSDという手法があるらしいが、それに近いのかも。
// CPU負荷とのたたかいなので、scaleSmall、search_count、threshold
// の組み合わせでよいところを設定。
// search_countを多くすると、速い動きにも対応できるが、
// それだけCPUに負担
//
// [注意]固定カメラで顔を動かしたりしても反応しません。
// 運動カメラの動きをとらえます。

package {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.BlendMode;
	import flash.events.Event;
	import flash.filters.BlurFilter;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.ConvolutionFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.ColorTransform;
	import flash.media.Camera;
	import flash.media.Video;
	import net.hires.debug.*;
	
	[SWF(frameRate="30")]
    Wonderfl.capture_delay( 20 );
	
	public class DetectDirection extends Sprite {
		private var camera:Camera;
		private var video:Video;
		private var videoWidth:int = 465;
		private var videoHeight:int = 465;
		private var raw:BitmapData;
		private var rect:Rectangle;
		private var pt:Point = new Point(0,0);
		
		private var xp:int,yp:int;
		// Properties for Patch Search
		private var now:BitmapData;
		private var nowMedium:BitmapData;
		private var nowSmall:BitmapData;
		private var last:BitmapData;
		private var lastMedium:BitmapData;
		private var lastSmall:BitmapData;
		private var scaleSmall:Number = .12;
		private var scaleMedium:Number = .25;
		private var mSmall:Matrix = new Matrix();
		private var mMedium:Matrix = new Matrix();
		// 検索の順番
		// 7 8 1
		// 6 0 2
		// 5 4 3
		private var compareX:Array = [ 0, 1, 1, 1, 0, -1, -1, -1, 0];
		private var compareY:Array = [ 0, -1, 0, 1, 1, 1, 0, -1, -1];
		private var dNow:int = 0;
		private var dResult:Point = new Point(0,0);
		private var score:Number;
		private var scoreNow:Number;
		private var scoreLast:Number;
		private var count:int = 0;
		private var t:Number;
		private var ii:int;
		private var aVec:Vector.<uint>;
		private var bVec:Vector.<uint>;
		private var scoreIndiv:Number;
		private var scoreNowIndiv:uint;
		private var current:int;
		private var dif:int;

		//Sprite
		private var arrow:Sprite;
		
		public function DetectDirection() {
			camera=Camera.getCamera();
			if (camera==null) {
			} else {
				start();
			}
		}
		private function start():void {
			camera.setMode(640, 480,30);
			video = new Video(videoWidth, videoHeight);
			video.attachCamera(camera);
			
			raw = new BitmapData(videoWidth,videoHeight);
			rect = raw.rect;
			
			this.addChild(video);
			this.addChild(new Bitmap(raw));
			
			arrow = new Sprite();
			
            arrow.graphics.beginFill(0xff0000);
            arrow.graphics.moveTo(0,-2);
            arrow.graphics.lineTo(40,-2);
            arrow.graphics.lineTo(40,-10);
            arrow.graphics.lineTo(63,0);
            arrow.graphics.lineTo(40,10);
            arrow.graphics.lineTo(40,2);
            arrow.graphics.lineTo(0,2);
            arrow.graphics.lineTo(0,-2);
            arrow.graphics.endFill();
			
			arrow.x = videoWidth/2;
			arrow.y = videoHeight/2- arrow.height/2;
			
			this.addChild(arrow);
			this.addChild(new Stats);
			
			//
			mSmall.scale(scaleSmall,scaleSmall);
			mMedium.scale(scaleMedium,scaleMedium);
			
			now = new BitmapData(videoWidth,videoHeight,false);
			nowMedium = new BitmapData(videoWidth*scaleMedium, videoHeight*scaleMedium, false);
			nowSmall = new BitmapData(videoWidth*scaleSmall, videoHeight*scaleSmall, false);
			last = new BitmapData(videoWidth,videoHeight,false);
			lastMedium = new BitmapData(videoWidth*scaleMedium, videoHeight*scaleMedium, false);
			lastSmall = new BitmapData(videoWidth*scaleSmall, videoHeight*scaleSmall, false);
			
			this.addEventListener(Event.ENTER_FRAME,onEnterFrame);
		}
		private function onEnterFrame(e:Event):void {

			raw.lock();

			raw.draw(video);
			
			var detected:Object = detectDirection(raw);
			
			arrow.rotation = (Math.atan2(detected.point.x,detected.point.y)* -180 / Math.PI) +90;
			arrow.scaleX = detected.distance/25;
			arrow.scaleY = detected.distance/25;
			
		}
		
		private function detectDirection(bd:BitmapData):Object {
			
            now.copyPixels(bd,rect,pt);
			nowMedium.draw(bd,mMedium);
			nowSmall.draw(bd,mSmall);

			var p:Point = getDirection(new Point(0,0),nowSmall,lastSmall, 8, 0.1);
			//var p2:Point = getDirection(new Point(p.x*scaleMedium/scaleSmall,p.y*scaleMedium/scaleSmall),nowMedium,lastMedium, 2, 0.05);
			var d:Number = Point.distance(pt, p)*(1/scaleSmall);

			//trace(p,Point.distance(pt, p)*(1/scaleSmall),Math.atan2(p.x,p.y));

            
			last.copyPixels(bd,last.rect,pt);
			lastMedium.copyPixels(nowMedium,lastMedium.rect,pt);
			lastSmall.copyPixels(nowSmall,lastSmall.rect,pt);
			
			return {point:p,distance:d};
        }
		private function getDirection(centerP:Point,a:BitmapData,b:BitmapData,search_count:int, threshold):Point{
			dNow = 0;
			dResult = centerP;
			score = 50000000;
			scoreNow = 0;
			scoreLast = 0;
			count = 0;
			t = (a.width-1) * (a.height-1) *threshold;

			while(score > t){
				dNow = 0;
				
				for (ii = 0 ; ii < 9; ii++){
					
					scoreNow = getScore(a, b, compareX[ii] + dResult.x, compareY[ii] + dResult.y);
					
					if (scoreNow < score){
						//前回のものよりスコアが低いなら、そっちを優先
						dNow = ii;
						score = scoreNow;
					}
				};
				
				dResult = new Point(dResult.x + compareX[dNow],dResult.y+compareY[dNow]);
				
				count ++;
				if(count >= search_count){
					// search_countまでに条件が満たなかったら中断
					//trace("break");
					break;
				}
			}
			
			return dResult;
		}
		private function getScore(a:BitmapData,b:BitmapData,x:int,y:int):Number{
			//x,yずらした画像の差分をベクトルで計算し、合計スコアを返す
			
			aVec = a.getVector(a.rect);
			bVec = b.getVector(b.rect);
			scoreIndiv = 0;
			scoreNowIndiv = 0;
			current = 0;
			dif = x + y*a.width;
			
			for (yp = 1; yp < a.height-1 ; yp++){
				for (xp = 1; xp < a.width-1 ; xp++){
					current = yp*a.width + xp;
					if( 0 <= current+dif && current+dif < aVec.length){
						scoreNowIndiv = Math.abs(aVec[current] - bVec[current+dif]);
						if ((0x00000000 < scoreNowIndiv ) && (scoreNowIndiv < 0x00ffffff)){
							scoreIndiv += (scoreNowIndiv / 0xffffff);
						}
					}
				}
			}
			return  scoreIndiv;			
		}

	}
}
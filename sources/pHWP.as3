// おおまかに言うと、１つの特徴点検索 > 次のフレームから同じ特徴点を探す
// という流れを延々とくりかえしてます。
//
// 細かく言うと、
// 1. カメラのおおよその移動方向を取得
// 2. FAST10を使って特徴点を検索
// 3. そこからランダムの一点を抽出し、小さいパッチとして登録
// 4. 次のフレームで3に似ているパッチを探す(1の距離を使う)
// 5. しきい値以上なら、その点は発見されたことになる
//
// がしかし、大きい動きに対応できていない。
// パターンのある場所、マットな場所などでは評価できなくなる。
// らへんが課題
//
// [注意]前回と同様、固定カメラ向きではありません。
// 鼻の穴とか追跡してくれることありますが。

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
    //Wonderfl.capture_delay( 20 );
	
	public class TrackingFeatures extends Sprite {
		private var camera:Camera;
		private var video:Video;
		private var videoWidth:int = 465;
		private var videoHeight:int = int(465* 2/3);//232;
		private var raw:BitmapData;
		private var res:BitmapData;
		private var resLast:BitmapData;
		private var rect:Rectangle;
		private var pt:Point = new Point(0,0);
		private var overlaySprite:Sprite;
		
		// Properties for FAST
		private var outline:BitmapData;
		private var pixel:Vector.<int>;
		private var corners:Vector.<Point> = new Vector.<Point>();
		private var cornersLast:Vector.<Point> = new Vector.<Point>();
		private var num_corners:int = 0;
		private var ret_corners:Vector.<Point>;
		private var center:uint;
		private var p:uint;
		private var cb:uint;
		private var c_b:uint;
		private var xp:uint, yp:uint;
		private var blurFilter:BlurFilter = new BlurFilter(3,3);
		private const white_threshold:uint = 0xff444444;  //アウトライン判定用。
		private var b:uint = 0x222222;	// FAST判定用
		private var fast_color:uint = 0xff00ff00;
		
		// Properties for Coarse Patch Search
		private var coarseDirection:Object;
		private var now:BitmapData;
		private var nowMedium:BitmapData;
		private var nowSmall:BitmapData;
		private var last:BitmapData;
		private var lastMedium:BitmapData;
		private var lastSmall:BitmapData;
		private var scaleSmall:Number = .125;
		private var scaleMedium:Number = .25;
		private var mSmall:Matrix = new Matrix();
		private var mMedium:Matrix = new Matrix();
		// 検索の順番
		// 7 8 1
		// 6 0 2
		// 5 4 3
		private var compareX:Array = [ 0, 1, 1, 1, 0, -1, -1, -1, 0];
		private var compareY:Array = [ 0, -1, 0, 1, 1, 1, 0, -1, -1];
		//private var compareX2:Array = [ 0,  1, 1, 1, 0, -1, -1, -1,  0,  2,  2,  2,  2,  2,  1, 0, -1, -2, -2, -2, -2, -2, -1,  0,  1];
		//private var compareY2:Array = [ 0, -1, 0, 1, 1,  1,  0, -1, -1, -2, -1,  0,  1,  2,  2, 2,  2,  2,  1,  0, -1, -2, -2, -2, -2];
		//private var compareX3:Array = [ 0,  1, 1, 1, 0, -1, -1, -1,  0,  2,  2,  2,  2,  2,  1, 0, -1, -2, -2, -2, -2, -2, -1,  0,  1,  3,  3,  3, 3, 3, 3, 3, 2, 1, 0, -1, -2, -3, -3, -3, -3, -3, -3, -3, -2, -1,  0,  1,  2];
		//private var compareY3:Array = [ 0, -1, 0, 1, 1,  1,  0, -1, -1, -2, -1,  0,  1,  2,  2, 2,  2,  2,  1,  0, -1, -2, -2, -2, -2, -3, -2, -1, 0, 1, 2, 3, 3, 3, 3,  3,  3,  3,  2,  1,  0, -1, -2, -3, -3, -3, -3, -3, -3];
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
			
		private const grayFilter:ColorMatrixFilter = new ColorMatrixFilter([
			0.3, 0.59, 0.11, 0, 0,
			0.3, 0.59, 0.11, 0, 0,
			0.3, 0.59, 0.11, 0, 0,
			0, 0, 0, 0, 255
		]);
		private const gaussianFilter:ConvolutionFilter = new ConvolutionFilter(3,3,[
			1,2,1,
			2,4,2,
			1,2,1
		],16);

		private const outlineFilter:ConvolutionFilter = new ConvolutionFilter(3,3,[
		 	 0,  1,  0, 
			 1, -4,  1, 
			 0,  1,  0
		],0,0);
		private const nonmaxFilter:ConvolutionFilter = new ConvolutionFilter(3, 3, [
			 0, -1,  0, 
			-1,  4, -1, 
			 0, -1,  0
		],0,0);
		private const noiseReduction:ConvolutionFilter = new ConvolutionFilter(3, 3,[
                1,  2, 1,
                2,  8, 2,
                1,  2, 1
        ],32);
			
		public function TrackingFeatures() {
			camera=Camera.getCamera();
			if (camera==null) {
			} else {
				start();
			}
		}
		private function start():void {
			camera.setMode(videoWidth, videoHeight,30);
			video = new Video(videoWidth, videoHeight);
			video.attachCamera(camera);
			outline = new BitmapData(videoWidth,videoHeight);
			raw = new BitmapData(videoWidth,videoHeight);
			res = new BitmapData(videoWidth,videoHeight);
			resLast = new BitmapData(videoWidth,videoHeight);
			rect = outline.rect;
			
			make_offsets(videoWidth);
			
			this.addChild(video);
			this.addChild(new Bitmap(raw));
			//this.addChild(new Bitmap(res));
			//this.addChild(new Bitmap(outline));
			
			overlaySprite = new Sprite();
			
			addChild(overlaySprite);
			
			//this.getChildAt(2).y = 234;
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
			
			
			bmA = new Bitmap(patchABlur);//patchABlur
			bmB = new Bitmap(patchB);
			bmB_dot = new Bitmap(patchB_dot);
			bmA.scaleX = bmB.scaleX = bmB_dot.scaleX = 3;
			bmA.scaleY = bmB.scaleY = bmB_dot.scaleY = 3;
			bmA.x = 1;
			bmB.x = 1 + (psize+1) * 3;
			bmB_dot.x = 1+ (psize*2+2) * 3;
			bmA.y = bmB.y = bmB_dot.y = 340;
					
			addChild(bmA);
			addChild(bmB);
			addChild(bmB_dot);
						
						
			this.addEventListener(Event.ENTER_FRAME,onEnterFrame);
		}
		private function onEnterFrame(e:Event):void {

			outline.lock();
			raw.lock();
			res.lock();
			last.lock();
			res.fillRect(rect,0xff000000);
			raw.draw(video);
			//raw.applyFilter(raw, rect, pt, grayFilter);
			coarseDirection = detectCoarseDirection(raw);
			//trace(coarseDirection.point,coarseDirection.rotation,coarseDirection.distance);
			
			outline.copyPixels(raw,rect,pt);
			// グレー化
			//outline.applyFilter(outline, rect, pt, grayFilter);
			//outline.applyFilter(outline, rect, pt, gaussianFilter);
			outline.applyFilter(outline, rect, pt, outlineFilter);
			//outline.applyFilter(outline, rect, pt, nonmaxFilter);
			
			
			//now.copyPixels(raw,rect,pt);
			//fast10_detect_nonmax(outline.getVector(rect), raw.getVector(rect), videoWidth, videoHeight, videoWidth, b);
			
			corners = fast10_detect(outline.getVector(rect), raw.getVector(rect), videoWidth, videoHeight, videoWidth, b);
			drawPixels(res,corners);
			
			searchFeatures(last,raw,res,cornersLast,corners,coarseDirection.point);
			
			cornersLast = corners;
			//resLast.copyPixels(res,rect,pt);
			last.copyPixels(raw,rect,pt);
			
			outline.unlock();
			raw.unlock();
			res.unlock();
			//overlaySprite.graphics.clear();
			//overlaySprite.graphics.lineStyle(1, 0xff0000, 1);
		}
		
		private var r:Number = 0,dcp :Point,dcd:Number = 0,dcratio:Number = 1/scaleSmall;
		
		private function detectCoarseDirection(bd:BitmapData):Object {
			
			nowSmall.draw(bd,mSmall);

			dcp = getDirection(new Point(0,0),nowSmall,lastSmall, 8, 0.1);
			//var p2:Point = getDirection(new Point(p.x*scaleMedium/scaleSmall,p.y*scaleMedium/scaleSmall),nowMedium,lastMedium, 2, 0.05);
			if (dcp.x != 0 && dcp.y != 0){
				r = Number((Math.atan2(dcp.x,dcp.y)* -180 / Math.PI) -90);
			}
			dcd = Point.distance(pt, dcp)*dcratio;

			lastSmall.copyPixels(nowSmall,lastSmall.rect,pt);
			//trace(int(dcp.x*dcratio),int(dcp.y*dcratio));
			return {point:new Point(int(dcp.x*dcratio),int(dcp.y*dcratio)),rotation:r,distance:dcd};
			
        }
		private function getDirection(centerP:Point,a:BitmapData,b:BitmapData,search_count:int, threshold:Number):Point{
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
		
		//Properties for Patch Searching
		private var ball:Ball;
		private var pp:int;
		private var psize:int = 17;
		private var psize_half:int = 8;
		private var searchSize:int = 3;
		private var detectedPoints:Vector.<Array> = new Vector.<Array>();
		private var detectedPoint:Point;
		private var lastFeaturePoints:Vector.<Point> = new Vector.<Point>();
		private var targetPoint:Point;
		private var patchRectA:Rectangle = new Rectangle(0,0,psize,psize);
		private var patchRectB:Rectangle = new Rectangle(0,0,psize,psize);
		private var patchA:BitmapData = new BitmapData(psize,psize,false);
		private var patchB:BitmapData = new BitmapData(psize,psize,false);
		private var patchB_dot:BitmapData = new BitmapData(psize,psize,false);
		private var pdNow:int;
		private var pdResult:Point = new Point(0,0);
		private var pscore:Point = new Point();
		private var pscoreNow:Point = new Point();
		private var pth:Number = 0.01;
		private var psearch_count:int = 4;
		private var pcount:int = 0;
		private var p_threshold:Point = new Point(122, 126); //x:パッチの中心、y:パッチの周辺のしきい値 //psize*psize*pth;

		private var patchABlur:BitmapData = new BitmapData(psize,psize,false);
		private var px:int, py:int, pdNowX:int, pdNowY:int;
		
		private var gpWeightColor:uint = 0x090909;
		private var diff_threshold:uint = 0x030303;
		
		// testing
		private var bmA:Bitmap;
		private var bmB:Bitmap;
		private var bmB_dot:Bitmap;
		
		
		//おおよその移動方向coarseDirectionから対応する特徴点を検索
		private function searchFeatures(bdA:BitmapData,bdB:BitmapData,bdB_dot:BitmapData,cornersA:Vector.<Point>,cornersB:Vector.<Point>,coarseDirection:Point):void {
			
			// A ふるほう(last)
			// B あたらしいほう(now)

			pscore.x = pscore.y = pscoreNow.x = pscoreNow.y = 0, pcount = 0;
			
			if(cornersA.length > 0){
				
				if(detectedPoints.length > 0){
					//前回のフレームから特徴点を選ぶ
					lastFeaturePoints[0] = detectedPoints[0][2];
					patchRectA.x = lastFeaturePoints[0].x-psize_half;
					patchRectA.y = lastFeaturePoints[0].y-psize_half;
					patchRectA.width = psize;
					patchRectA.height = psize;
					patchA.draw(detectedPoints[0][0]);
					
				} else if(coarseDirection.x == 0 && coarseDirection.y == 0){
					
					lastFeaturePoints[0] = cornersA[Math.floor(Math.random()*(cornersA.length))];
					patchRectA.x = lastFeaturePoints[0].x-psize_half;
					patchRectA.y = lastFeaturePoints[0].y-psize_half;
					patchA.copyPixels(bdA,patchRectA,pt);
					
				}
				
				//patchABlur.lock();
				
				//今回のフレームから、おおまかな検索箇所を決定する
				pdResult.x = patchRectA.x - int(coarseDirection.x);
				pdResult.y = patchRectA.y - int(coarseDirection.y);
				
				//周辺画像を総当たりで最も近い画像を探す
				while(pscore.x < p_threshold.x && pscore.y < p_threshold.y){
					
					//回数を重ねるごとに、基準パッチにブラーをかけて再評価
					if(coarseDirection.x == 0 && coarseDirection.y == 0){
						blurFilter = new BlurFilter(pcount,pcount);
					} else {
						blurFilter = new BlurFilter(Math.abs(coarseDirection.x)/2*pcount,Math.abs(coarseDirection.y)/2*pcount);
					}
					patchABlur.applyFilter(patchA,patchA.rect,pt,blurFilter);
					
					if(pcount >= psearch_count){
						// psearch_countまでに条件が満たなかったら中断
						break;
					}
					pcount ++;
					
					pdNow = 0;
					pdNowX = 0;
					pdNowY = 0;
					
					//for (pp = 0 ; pp < compareX3.length; pp++){
					for (py = - searchSize*pcount ; py <= searchSize*pcount; py+= 1*pcount){
					for (px = - searchSize*pcount ; px <= searchSize*pcount; px+= 1*pcount){
						patchRectB.x = pdResult.x + px;
						patchRectB.y = pdResult.y + py;
						
						try{//範囲外を指定する可能性あり
							patchB.copyPixels(bdB,patchRectB,pt);
						} catch(e:Event) {
							trace("error");
						}

						pscoreNow = getPatchScore(patchABlur, patchB,diff_threshold,gpWeightColor);
					
						if (pscoreNow.x > pscore.x && pscoreNow.y > pscore.y){
							//前回のものよりスコアが高いなら、そっちを優先
							pdNowX = px;
							pdNowY = py;
							pscore.x  = pscoreNow.x;
							pscore.y  = pscoreNow.y;
						}
					}};
					//結果用ポイントにpscoreが最小値になった方向を足す。条件が満たなかったらそこから再スタート。条件が満ち足りていたら、そこが発見したパッチ。
					pdResult.x = pdResult.x + pdNowX;
					pdResult.y = pdResult.y + pdNowY;
				}
				
				//特徴点発見
				if(pscore.x >= p_threshold.x && pscore.y >= p_threshold.y ){
					
					
					//パッチを出力（テスト）
					patchB.copyPixels(bdB,new Rectangle(pdResult.x,pdResult.y,psize,psize),pt);
					patchB_dot.copyPixels(bdB_dot,new Rectangle(pdResult.x,pdResult.y,psize,psize),pt);
					
					//detectedPoint = new Point(pdResult.x+8,pdResult.y+8);
					detectedPoints[0] = [patchA,new Point(lastFeaturePoints[0].x,lastFeaturePoints[0].y),new Point(pdResult.x+psize_half,pdResult.y+psize_half)];

					//trace("found \t\t",pcount+"回目","\t\tscore : "+pscore,"\tおおよその方向 : "+coarseDirection,"\t\distance : "+lastFeaturePoints[0].subtract(detectedPoints[0][2]) );
					
					if(ball){
						ball.alpha = 1;
						ball.x = detectedPoints[0][2].x;
						ball.y = detectedPoints[0][2].y;
					} else {
						ball = new Ball(detectedPoints[0][2].x,detectedPoints[0][2].y);
						overlaySprite.addChild(ball);
					}
						
				} else {
					//trace("notfound \t",pcount+"回目","\t\tscore : "+pscore );
					detectedPoints  = new Vector.<Array>();
					if(ball){ ball.alpha = 0; }
				}
			}
			
        }
		private var gpyp:int, gpxp:int;
		private var paVec:Vector.<uint>;
		private var pbVec:Vector.<uint>;
		private var pscoreIndiv:Point = new Point();
		private var pscoreNowIndiv:Number;
		private var gpcurrent:int;
		private var gpWeight:Number;
		private var gpCenter:Number;
		private var gpCenterSize:int = 6;
		
		private function getPatchScore(a:BitmapData,b:BitmapData,t:uint,t2:uint):Point{
			//パッチ画像の差分をベクトルで計算し、合計スコアを返す
			paVec = a.getVector(a.rect);
			pbVec = b.getVector(b.rect);
			pscoreIndiv.x = pscoreIndiv.y = 0;
			pscoreNowIndiv = 0;
			gpcurrent = 0;
			gpCenter = a.height/2;
			
			for (gpyp = 0; gpyp < a.height ; gpyp++){
				for (gpxp = 0; gpxp < a.width ; gpxp++){
					
					gpcurrent = gpyp*a.width + gpxp;
					//中心から離れるとふえる重み (1:重い中心, 0:軽い周辺)
					gpWeight =  ( 1 + (-1 * ( ( Math.abs(gpyp - (a.height/2)) +  Math.abs(gpxp - (a.width/2)) ) / a.height)));
						
					pscoreNowIndiv = Math.abs(paVec[gpcurrent] - pbVec[gpcurrent]);
					pscoreNowIndiv = 1- (pscoreNowIndiv / 0xffffff );
					
					//中心から離れるとスコアを低くして加算 (中心に向かうほど厳密に判定する)
					//if (pscoreNowIndiv * gpWeight < t ){ //(t * (1+(gpWeight*gpWeight)))
					if (gpCenter-gpCenterSize < gpyp && gpyp < gpCenter+gpCenterSize && gpCenter-gpCenterSize < gpxp && gpxp < gpCenter+gpCenterSize){
						//パッチの中心スコア
						pscoreIndiv.x += (( pscoreNowIndiv ));
					
					} else {
						//パッチの周辺スコア
						pscoreIndiv.y += (( pscoreNowIndiv ));
					}
					//pscoreIndiv += (pscoreNowIndiv / 0xffffff);
				}
			}
			//trace(gpWeight);
			return  pscoreIndiv;
		}
		
		private function drawPixels(bitmapData:BitmapData,c:Vector.<Point>):void{
			c.forEach(drawAll);
			function drawAll(element:Point, index:int, arr:Vector.<Point>):void{
				bitmapData.setPixel(element.x,element.y,fast_color);
			}
		}


/*
Copyright (c) 2006, 2008 Edward Rosten
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:


	*Redistributions of source code must retain the above copyright
	 notice, this list of conditions and the following disclaimer.

	*Redistributions in binary form must reproduce the above copyright
	 notice, this list of conditions and the following disclaimer in the
	 documentation and/or other materials provided with the distribution.

	*Neither the name of the University of Cambridge nor the names of 
	 its contributors may be used to endorse or promote products derived 
	 from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR
CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/


		private function make_offsets(row_stride:int):void{
        	pixel = new Vector.<int>(16);
			pixel[0] = 0 + row_stride * 3;
			pixel[1] = 1 + row_stride * 3;
			pixel[2] = 2 + row_stride * 2;
			pixel[3] = 3 + row_stride * 1;
			pixel[4] = 3 + row_stride * 0;
			pixel[5] = 3 + row_stride * -1;
			pixel[6] = 2 + row_stride * -2;
			pixel[7] = 1 + row_stride * -3;
			pixel[8] = 0 + row_stride * -3;
			pixel[9] = -1 + row_stride * -3;
			pixel[10] = -2 + row_stride * -2;
			pixel[11] = -3 + row_stride * -1;
			pixel[12] = -3 + row_stride * 0;
			pixel[13] = -3 + row_stride * 1;
			pixel[14] = -2 + row_stride * 2;
			pixel[15] = -1 + row_stride * 3;
			//  return pix;
		}
	public function fast10_detect(outline:Vector.<uint>, raw:Vector.<uint>, xsize:int, ysize:int, stride:int, b:uint, ret_num_corners:int = undefined):Vector.<Point> {

	num_corners = 0;
	//var rsize:int = 512;
	ret_corners = new Vector.<Point>();

	for(yp=3; yp < ysize - 3; yp++){
		for(xp=3; xp < xsize - 3; xp++){
			//const byte* p = im + y*stride + x;
			center = yp*stride + xp;
			p = raw[center];
			cb = p + b;
			c_b = p - b;
	
	if(outline[center] > white_threshold)	{
        
		 if(raw[center + pixel[0]] > cb){
         if(raw[center + pixel[1]] > cb){
          if(raw[center + pixel[2]] > cb){
           if(raw[center + pixel[3]] > cb){
            if(raw[center + pixel[4]] > cb){
             if(raw[center + pixel[5]] > cb){
              if(raw[center + pixel[6]] > cb){
               if(raw[center + pixel[7]] > cb){
                if(raw[center + pixel[8]] > cb){
                 if(raw[center + pixel[9]] > cb){
                  
                 } else {
                  if(raw[center + pixel[15]] > cb){
                   
                  } else {
                   continue; }
                 }
                 
                } else {
                 if(raw[center + pixel[14]] > cb){
                  if(raw[center + pixel[15]] > cb){
                   
                  } else {
                   continue; }
                 } else {
                  continue; }
                }
                
               } else {
                if(raw[center + pixel[13]] > cb){
                 if(raw[center + pixel[14]] > cb){
                  if(raw[center + pixel[15]] > cb){
                   
                  } else {
                   continue; }
                 } else {
                  continue; }
                } else {
                 continue; }
               }
               
              } else if (raw[center + pixel[6]] < c_b){
               if(raw[center + pixel[12]] > cb){
                if(raw[center + pixel[13]] > cb){
                 if(raw[center + pixel[14]] > cb){
                  if(raw[center + pixel[15]] > cb){
                   
                  } else {
                   continue; }
                 } else {
                  continue; }
                } else {
                 continue; }
               } else if(raw[center + pixel[12]] < c_b){
                if(raw[center + pixel[7]] < c_b){
                 if(raw[center + pixel[8]] < c_b){
                  if(raw[center + pixel[9]] < c_b){
                   if(raw[center + pixel[10]] < c_b){
                    if(raw[center + pixel[11]] < c_b){
                     if(raw[center + pixel[13]] < c_b){
                      if(raw[center + pixel[14]] < c_b){
                       if(raw[center + pixel[15]] < c_b){
                        
                       } else {
                        continue; }
                      } else {
                       continue; }
                     } else {
                      continue; }
                    } else {
                     continue; }
                   } else {
                    continue; }
                  } else {
                   continue; }
                 } else {
                  continue; }
                } else {
                 continue; }
               } else {
                continue; }
              } else {
               if(raw[center + pixel[12]] > cb){
                if(raw[center + pixel[13]] > cb){
                 if(raw[center + pixel[14]] > cb){
                  if(raw[center + pixel[15]] > cb){
                   
                  } else {
                   continue; }
                 } else {
                  continue; }
                } else {
                 continue; }
               } else {
                continue; }
              }
              
             } else if(raw[center + pixel[5]] < c_b){
              if(raw[center + pixel[15]] > cb){
               if(raw[center + pixel[11]] > cb){
                if(raw[center + pixel[12]] > cb){
                 if(raw[center + pixel[13]] > cb){
                  if(raw[center + pixel[14]] > cb){
                   
                  } else {
                   continue; }
                 } else {
                  continue; }
                } else {
                 continue; }
               } else if(raw[center + pixel[11]] < c_b){
                if(raw[center + pixel[6]] < c_b){
                 if(raw[center + pixel[7]] < c_b){
                  if(raw[center + pixel[8]] < c_b){
                   if(raw[center + pixel[9]] < c_b){
                    if(raw[center + pixel[10]] < c_b){
                     if(raw[center + pixel[12]] < c_b){
                      if(raw[center + pixel[13]] < c_b){
                       if(raw[center + pixel[14]] < c_b){
                        
                       } else {
                        continue; }
                      } else {
                       continue; }
                     } else {
                      continue; }
                    } else {
                     continue; }
                   } else {
                    continue; }
                  } else {
                   continue; }
                 } else {
                  continue; }
                } else {
                 continue; }
               } else {
                continue; }
              } else {
               if(raw[center + pixel[6]] < c_b){
                if(raw[center + pixel[7]] < c_b){
                 if(raw[center + pixel[8]] < c_b){
                  if(raw[center + pixel[9]] < c_b){
                   if(raw[center + pixel[10]] < c_b){
                    if(raw[center + pixel[11]] < c_b){
                     if(raw[center + pixel[12]] < c_b){
                      if(raw[center + pixel[13]] < c_b){
                       if(raw[center + pixel[14]] < c_b){
                        
                       } else {
                        continue; }
                      } else {
                       continue; }
                     } else {
                      continue; }
                    } else {
                     continue; }
                   } else {
                    continue; }
                  } else {
                   continue; }
                 } else {
                  continue; }
                } else {
                 continue; }
               } else {
                continue; }
              }
              
             } else {
              if(raw[center + pixel[11]] > cb){
               if(raw[center + pixel[12]] > cb){
                if(raw[center + pixel[13]] > cb){
                 if(raw[center + pixel[14]] > cb){
                  if(raw[center + pixel[15]] > cb){
                   
                  } else {
                   continue; }
                 } else {
                  continue; }
                } else {
                 continue; }
               } else {
                continue; }
              } else if(raw[center + pixel[11]] < c_b){
               if(raw[center + pixel[6]] < c_b){
                if(raw[center + pixel[7]] < c_b){
                 if(raw[center + pixel[8]] < c_b){
                  if(raw[center + pixel[9]] < c_b){
                   if(raw[center + pixel[10]] < c_b){
                    if(raw[center + pixel[12]] < c_b){
                     if(raw[center + pixel[13]] < c_b){
                      if(raw[center + pixel[14]] < c_b){
                       if(raw[center + pixel[15]] < c_b){
                        
                       } else {
                        continue; }
                      } else {
                       continue; }
                     } else {
                      continue; }
                    } else {
                     continue; }
                   } else {
                    continue; }
                  } else {
                   continue; }
                 } else {
                  continue; }
                } else {
                 continue; }
               } else {
                continue; }
              } else {
               continue; }
             }
             
            } else if(raw[center + pixel[4]] < c_b){
             if(raw[center + pixel[14]] > cb){
              if(raw[center + pixel[10]] > cb){
               if(raw[center + pixel[11]] > cb){
                if(raw[center + pixel[12]] > cb){
                 if(raw[center + pixel[13]] > cb){
                  if(raw[center + pixel[15]] > cb){
                   
                  } else {
                   if(raw[center + pixel[5]] > cb){
                    if(raw[center + pixel[6]] > cb){
                     if(raw[center + pixel[7]] > cb){
                      if(raw[center + pixel[8]] > cb){
                       if(raw[center + pixel[9]] > cb){
                        
                       } else {
                        continue; }
                      } else {
                       continue; }
                     } else {
                      continue; }
                    } else {
                     continue; }
                   } else {
                    continue; }
                  }
                  
                 } else {
                  continue; }
                } else {
                 continue; }
               } else {
                continue; }
              } else if(raw[center + pixel[10]] < c_b){
               if(raw[center + pixel[5]] < c_b){
                if(raw[center + pixel[6]] < c_b){
                 if(raw[center + pixel[7]] < c_b){
                  if(raw[center + pixel[8]] < c_b){
                   if(raw[center + pixel[9]] < c_b){
                    if(raw[center + pixel[11]] < c_b){
                     if(raw[center + pixel[12]] < c_b){
                      if(raw[center + pixel[13]] < c_b){
                       
                      } else {
                       continue; }
                     } else {
                      continue; }
                    } else {
                     continue; }
                   } else {
                    continue; }
                  } else {
                   continue; }
                 } else {
                  continue; }
                } else {
                 continue; }
               } else {
                continue; }
              } else {
               continue; }
             } else if(raw[center + pixel[14]] < c_b){
              if(raw[center + pixel[6]] < c_b){
               if(raw[center + pixel[7]] < c_b){
                if(raw[center + pixel[8]] < c_b){
                 if(raw[center + pixel[9]] < c_b){
                  if(raw[center + pixel[10]] < c_b){
                   if(raw[center + pixel[11]] < c_b){
                    if(raw[center + pixel[12]] < c_b){
                     if(raw[center + pixel[13]] < c_b){
                      if(raw[center + pixel[5]] < c_b){
                       
                      } else {
                       if(raw[center + pixel[15]] < c_b){
                        
                       } else {
                        continue; }
                      }
                      
                     } else {
                      continue; }
                    } else {
                     continue; }
                   } else {
                    continue; }
                  } else {
                   continue; }
                 } else {
                  continue; }
                } else {
                 continue; }
               } else {
                continue; }
              } else {
               continue; }
             } else {
              if(raw[center + pixel[5]] < c_b){
               if(raw[center + pixel[6]] < c_b){
                if(raw[center + pixel[7]] < c_b){
                 if(raw[center + pixel[8]] < c_b){
                  if(raw[center + pixel[9]] < c_b){
                   if(raw[center + pixel[10]] < c_b){
                    if(raw[center + pixel[11]] < c_b){
                     if(raw[center + pixel[12]] < c_b){
                      if(raw[center + pixel[13]] < c_b){
                       
                      } else {
                       continue; }
                     } else {
                      continue; }
                    } else {
                     continue; }
                   } else {
                    continue; }
                  } else {
                   continue; }
                 } else {
                  continue; }
                } else {
                 continue; }
               } else {
                continue; }
              } else {
               continue; }
             }
             
            } else {
             if(raw[center + pixel[10]] > cb){
              if(raw[center + pixel[11]] > cb){
               if(raw[center + pixel[12]] > cb){
                if(raw[center + pixel[13]] > cb){
                 if(raw[center + pixel[14]] > cb){
                  if(raw[center + pixel[15]] > cb){
                   
                  } else {
                   if(raw[center + pixel[5]] > cb){
                    if(raw[center + pixel[6]] > cb){
                     if(raw[center + pixel[7]] > cb){
                      if(raw[center + pixel[8]] > cb){
                       if(raw[center + pixel[9]] > cb){
                        
                       } else {
                        continue; }
                      } else {
                       continue; }
                     } else {
                      continue; }
                    } else {
                     continue; }
                   } else {
                    continue; }
                  }
                  
                 } else {
                  continue; }
                } else {
                 continue; }
               } else {
                continue; }
              } else {
               continue; }
             } else if(raw[center + pixel[10]] < c_b){
              if(raw[center + pixel[6]] < c_b){
               if(raw[center + pixel[7]] < c_b){
                if(raw[center + pixel[8]] < c_b){
                 if(raw[center + pixel[9]] < c_b){
                  if(raw[center + pixel[11]] < c_b){
                   if(raw[center + pixel[12]] < c_b){
                    if(raw[center + pixel[13]] < c_b){
                     if(raw[center + pixel[14]] < c_b){
                      if(raw[center + pixel[5]] < c_b){
                       
                      } else {
                       if(raw[center + pixel[15]] < c_b){
                        
                       } else {
                        continue; }
                      }
                      
                     } else {
                      continue; }
                    } else {
                     continue; }
                   } else {
                    continue; }
                  } else {
                   continue; }
                 } else {
                  continue; }
                } else {
                 continue; }
               } else {
                continue; }
              } else {
               continue; }
             } else {
              continue; }
            }
            
           } else if(raw[center + pixel[3]] < c_b){
            if(raw[center + pixel[9]] > cb){
             if(raw[center + pixel[10]] > cb){
              if(raw[center + pixel[11]] > cb){
               if(raw[center + pixel[12]] > cb){
                if(raw[center + pixel[13]] > cb){
                 if(raw[center + pixel[14]] > cb){
                  if(raw[center + pixel[15]] > cb){
                   
                  } else {
                   if(raw[center + pixel[5]] > cb){
                    if(raw[center + pixel[6]] > cb){
                     if(raw[center + pixel[7]] > cb){
                      if(raw[center + pixel[8]] > cb){
                       
                      } else {
                       continue; }
                     } else {
                      continue; }
                    } else {
                     continue; }
                   } else {
                    continue; }
                  }
                  
                 } else {
                  if(raw[center + pixel[4]] > cb){
                   if(raw[center + pixel[5]] > cb){
                    if(raw[center + pixel[6]] > cb){
                     if(raw[center + pixel[7]] > cb){
                      if(raw[center + pixel[8]] > cb){
                       
                      } else {
                       continue; }
                     } else {
                      continue; }
                    } else {
                     continue; }
                   } else {
                    continue; }
                  } else {
                   continue; }
                 }
                 
                } else {
                 continue; }
               } else {
                continue; }
              } else {
               continue; }
             } else {
              continue; }
            } else if(raw[center + pixel[9]] < c_b){
             if(raw[center + pixel[6]] < c_b){
              if(raw[center + pixel[7]] < c_b){
               if(raw[center + pixel[8]] < c_b){
                if(raw[center + pixel[10]] < c_b){
                 if(raw[center + pixel[11]] < c_b){
                  if(raw[center + pixel[12]] < c_b){
                   if(raw[center + pixel[5]] < c_b){
                    if(raw[center + pixel[4]] < c_b){
                     
                    } else {
                     if(raw[center + pixel[13]] < c_b){
                      if(raw[center + pixel[14]] < c_b){
                       
                      } else {
                       continue; }
                     } else {
                      continue; }
                    }
                    
                   } else {
                    if(raw[center + pixel[13]] < c_b){
                     if(raw[center + pixel[14]] < c_b){
                      if(raw[center + pixel[15]] < c_b){
                       
                      } else {
                       continue; }
                     } else {
                      continue; }
                    } else {
                     continue; }
                   }
                   
                  } else {
                   continue; }
                 } else {
                  continue; }
                } else {
                 continue; }
               } else {
                continue; }
              } else {
               continue; }
             } else {
              continue; }
            } else {
             continue; }
           } else {
            if(raw[center + pixel[9]] > cb){
             if(raw[center + pixel[10]] > cb){
              if(raw[center + pixel[11]] > cb){
               if(raw[center + pixel[12]] > cb){
                if(raw[center + pixel[13]] > cb){
                 if(raw[center + pixel[14]] > cb){
                  if(raw[center + pixel[15]] > cb){
                   
                  } else {
                   if(raw[center + pixel[5]] > cb){
                    if(raw[center + pixel[6]] > cb){
                     if(raw[center + pixel[7]] > cb){
                      if(raw[center + pixel[8]] > cb){
                       
                      } else {
                       continue; }
                     } else {
                      continue; }
                    } else {
                     continue; }
                   } else {
                    continue; }
                  }
                  
                 } else {
                  if(raw[center + pixel[4]] > cb){
                   if(raw[center + pixel[5]] > cb){
                    if(raw[center + pixel[6]] > cb){
                     if(raw[center + pixel[7]] > cb){
                      if(raw[center + pixel[8]] > cb){
                       
                      } else {
                       continue; }
                     } else {
                      continue; }
                    } else {
                     continue; }
                   } else {
                    continue; }
                  } else {
                   continue; }
                 }
                 
                } else {
                 continue; }
               } else {
                continue; }
              } else {
               continue; }
             } else {
              continue; }
            } else if(raw[center + pixel[9]] < c_b){
             if(raw[center + pixel[6]] < c_b){
              if(raw[center + pixel[7]] < c_b){
               if(raw[center + pixel[8]] < c_b){
                if(raw[center + pixel[10]] < c_b){
                 if(raw[center + pixel[11]] < c_b){
                  if(raw[center + pixel[12]] < c_b){
                   if(raw[center + pixel[13]] < c_b){
                    if(raw[center + pixel[5]] < c_b){
                     if(raw[center + pixel[4]] < c_b){
                      
                     } else {
                      if(raw[center + pixel[14]] < c_b){
                       
                      } else {
                       continue; }
                     }
                     
                    } else {
                     if(raw[center + pixel[14]] < c_b){
                      if(raw[center + pixel[15]] < c_b){
                       
                      } else {
                       continue; }
                     } else {
                      continue; }
                    }
                    
                   } else {
                    continue; }
                  } else {
                   continue; }
                 } else {
                  continue; }
                } else {
                 continue; }
               } else {
                continue; }
              } else {
               continue; }
             } else {
              continue; }
            } else {
             continue; }
           }
           
          } else if(raw[center + pixel[2]] < c_b){
           if(raw[center + pixel[8]] > cb){
            if(raw[center + pixel[9]] > cb){
             if(raw[center + pixel[10]] > cb){
              if(raw[center + pixel[11]] > cb){
               if(raw[center + pixel[12]] > cb){
                if(raw[center + pixel[13]] > cb){
                 if(raw[center + pixel[14]] > cb){
                  if(raw[center + pixel[15]] > cb){
                   
                  } else {
                   if(raw[center + pixel[5]] > cb){
                    if(raw[center + pixel[6]] > cb){
                     if(raw[center + pixel[7]] > cb){
                      
                     } else {
                      continue; }
                    } else {
                     continue; }
                   } else {
                    continue; }
                  }
                  
                 } else {
                  if(raw[center + pixel[4]] > cb){
                   if(raw[center + pixel[5]] > cb){
                    if(raw[center + pixel[6]] > cb){
                     if(raw[center + pixel[7]] > cb){
                      
                     } else {
                      continue; }
                    } else {
                     continue; }
                   } else {
                    continue; }
                  } else {
                   continue; }
                 }
                 
                } else {
                 if(raw[center + pixel[3]] > cb){
                  if(raw[center + pixel[4]] > cb){
                   if(raw[center + pixel[5]] > cb){
                    if(raw[center + pixel[6]] > cb){
                     if(raw[center + pixel[7]] > cb){
                      
                     } else {
                      continue; }
                    } else {
                     continue; }
                   } else {
                    continue; }
                  } else {
                   continue; }
                 } else {
                  continue; }
                }
                
               } else {
                continue; }
              } else {
               continue; }
             } else {
              continue; }
            } else {
             continue; }
           } else if(raw[center + pixel[8]] < c_b){
            if(raw[center + pixel[6]] < c_b){
             if(raw[center + pixel[7]] < c_b){
              if(raw[center + pixel[9]] < c_b){
               if(raw[center + pixel[10]] < c_b){
                if(raw[center + pixel[11]] < c_b){
                 if(raw[center + pixel[5]] < c_b){
                  if(raw[center + pixel[4]] < c_b){
                   if(raw[center + pixel[3]] < c_b){
                    
                   } else {
                    if(raw[center + pixel[12]] < c_b){
                     if(raw[center + pixel[13]] < c_b){
                      
                     } else {
                      continue; }
                    } else {
                     continue; }
                   }
                   
                  } else {
                   if(raw[center + pixel[12]] < c_b){
                    if(raw[center + pixel[13]] < c_b){
                     if(raw[center + pixel[14]] < c_b){
                      
                     } else {
                      continue; }
                    } else {
                     continue; }
                   } else {
                    continue; }
                  }
                  
                 } else {
                  if(raw[center + pixel[12]] < c_b){
                   if(raw[center + pixel[13]] < c_b){
                    if(raw[center + pixel[14]] < c_b){
                     if(raw[center + pixel[15]] < c_b){
                      
                     } else {
                      continue; }
                    } else {
                     continue; }
                   } else {
                    continue; }
                  } else {
                   continue; }
                 }
                 
                } else {
                 continue; }
               } else {
                continue; }
              } else {
               continue; }
             } else {
              continue; }
            } else {
             continue; }
           } else {
            continue; }
          } else {
           if(raw[center + pixel[8]] > cb){
            if(raw[center + pixel[9]] > cb){
             if(raw[center + pixel[10]] > cb){
              if(raw[center + pixel[11]] > cb){
               if(raw[center + pixel[12]] > cb){
                if(raw[center + pixel[13]] > cb){
                 if(raw[center + pixel[14]] > cb){
                  if(raw[center + pixel[15]] > cb){
                   
                  } else {
                   if(raw[center + pixel[5]] > cb){
                    if(raw[center + pixel[6]] > cb){
                     if(raw[center + pixel[7]] > cb){
                      
                     } else {
                      continue; }
                    } else {
                     continue; }
                   } else {
                    continue; }
                  }
                  
                 } else {
                  if(raw[center + pixel[4]] > cb){
                   if(raw[center + pixel[5]] > cb){
                    if(raw[center + pixel[6]] > cb){
                     if(raw[center + pixel[7]] > cb){
                      
                     } else {
                      continue; }
                    } else {
                     continue; }
                   } else {
                    continue; }
                  } else {
                   continue; }
                 }
                 
                } else {
                 if(raw[center + pixel[3]] > cb){
                  if(raw[center + pixel[4]] > cb){
                   if(raw[center + pixel[5]] > cb){
                    if(raw[center + pixel[6]] > cb){
                     if(raw[center + pixel[7]] > cb){
                      
                     } else {
                      continue; }
                    } else {
                     continue; }
                   } else {
                    continue; }
                  } else {
                   continue; }
                 } else {
                  continue; }
                }
                
               } else {
                continue; }
              } else {
               continue; }
             } else {
              continue; }
            } else {
             continue; }
           } else if(raw[center + pixel[8]] < c_b){
            if(raw[center + pixel[6]] < c_b){
             if(raw[center + pixel[7]] < c_b){
              if(raw[center + pixel[9]] < c_b){
               if(raw[center + pixel[10]] < c_b){
                if(raw[center + pixel[11]] < c_b){
                 if(raw[center + pixel[12]] < c_b){
                  if(raw[center + pixel[5]] < c_b){
                   if(raw[center + pixel[4]] < c_b){
                    if(raw[center + pixel[3]] < c_b){
                     
                    } else {
                     if(raw[center + pixel[13]] < c_b){
                      
                     } else {
                      continue; }
                    }
                    
                   } else {
                    if(raw[center + pixel[13]] < c_b){
                     if(raw[center + pixel[14]] < c_b){
                      
                     } else {
                      continue; }
                    } else {
                     continue; }
                   }
                   
                  } else {
                   if(raw[center + pixel[13]] < c_b){
                    if(raw[center + pixel[14]] < c_b){
                     if(raw[center + pixel[15]] < c_b){
                      
                     } else {
                      continue; }
                    } else {
                     continue; }
                   } else {
                    continue; }
                  }
                  
                 } else {
                  continue; }
                } else {
                 continue; }
               } else {
                continue; }
              } else {
               continue; }
             } else {
              continue; }
            } else {
             continue; }
           } else {
            continue; }
          }
          
         } else if(raw[center + pixel[1]] < c_b){
          if(raw[center + pixel[7]] > cb){
           if(raw[center + pixel[8]] > cb){
            if(raw[center + pixel[9]] > cb){
             if(raw[center + pixel[10]] > cb){
              if(raw[center + pixel[11]] > cb){
               if(raw[center + pixel[12]] > cb){
                if(raw[center + pixel[13]] > cb){
                 if(raw[center + pixel[14]] > cb){
                  if(raw[center + pixel[15]] > cb){
                   
                  } else {
                   if(raw[center + pixel[5]] > cb){
                    if(raw[center + pixel[6]] > cb){
                     
                    } else {
                     continue; }
                   } else {
                    continue; }
                  }
                  
                 } else {
                  if(raw[center + pixel[4]] > cb){
                   if(raw[center + pixel[5]] > cb){
                    if(raw[center + pixel[6]] > cb){
                     
                    } else {
                     continue; }
                   } else {
                    continue; }
                  } else {
                   continue; }
                 }
                 
                } else {
                 if(raw[center + pixel[3]] > cb){
                  if(raw[center + pixel[4]] > cb){
                   if(raw[center + pixel[5]] > cb){
                    if(raw[center + pixel[6]] > cb){
                     
                    } else {
                     continue; }
                   } else {
                    continue; }
                  } else {
                   continue; }
                 } else {
                  continue; }
                }
                
               } else {
                if(raw[center + pixel[2]] > cb){
                 if(raw[center + pixel[3]] > cb){
                  if(raw[center + pixel[4]] > cb){
                   if(raw[center + pixel[5]] > cb){
                    if(raw[center + pixel[6]] > cb){
                     
                    } else {
                     continue; }
                   } else {
                    continue; }
                  } else {
                   continue; }
                 } else {
                  continue; }
                } else {
                 continue; }
               }
               
              } else {
               continue; }
             } else {
              continue; }
            } else {
             continue; }
           } else {
            continue; }
          } else if(raw[center + pixel[7]] < c_b){
           if(raw[center + pixel[6]] < c_b){
            if(raw[center + pixel[8]] < c_b){
             if(raw[center + pixel[9]] < c_b){
              if(raw[center + pixel[10]] < c_b){
               if(raw[center + pixel[5]] < c_b){
                if(raw[center + pixel[4]] < c_b){
                 if(raw[center + pixel[3]] < c_b){
                  if(raw[center + pixel[2]] < c_b){
                   
                  } else {
                   if(raw[center + pixel[11]] < c_b){
                    if(raw[center + pixel[12]] < c_b){
                     
                    } else {
                     continue; }
                   } else {
                    continue; }
                  }
                  
                 } else {
                  if(raw[center + pixel[11]] < c_b){
                   if(raw[center + pixel[12]] < c_b){
                    if(raw[center + pixel[13]] < c_b){
                     
                    } else {
                     continue; }
                   } else {
                    continue; }
                  } else {
                   continue; }
                 }
                 
                } else {
                 if(raw[center + pixel[11]] < c_b){
                  if(raw[center + pixel[12]] < c_b){
                   if(raw[center + pixel[13]] < c_b){
                    if(raw[center + pixel[14]] < c_b){
                     
                    } else {
                     continue; }
                   } else {
                    continue; }
                  } else {
                   continue; }
                 } else {
                  continue; }
                }
                
               } else {
                if(raw[center + pixel[11]] < c_b){
                 if(raw[center + pixel[12]] < c_b){
                  if(raw[center + pixel[13]] < c_b){
                   if(raw[center + pixel[14]] < c_b){
                    if(raw[center + pixel[15]] < c_b){
                     
                    } else {
                     continue; }
                   } else {
                    continue; }
                  } else {
                   continue; }
                 } else {
                  continue; }
                } else {
                 continue; }
               }
               
              } else {
               continue; }
             } else {
              continue; }
            } else {
             continue; }
           } else {
            continue; }
          } else {
           continue; }
         } else {
          if(raw[center + pixel[7]] > cb){
           if(raw[center + pixel[8]] > cb){
            if(raw[center + pixel[9]] > cb){
             if(raw[center + pixel[10]] > cb){
              if(raw[center + pixel[11]] > cb){
               if(raw[center + pixel[12]] > cb){
                if(raw[center + pixel[13]] > cb){
                 if(raw[center + pixel[14]] > cb){
                  if(raw[center + pixel[15]] > cb){
                   
                  } else {
                   if(raw[center + pixel[5]] > cb){
                    if(raw[center + pixel[6]] > cb){
                     
                    } else {
                     continue; }
                   } else {
                    continue; }
                  }
                  
                 } else {
                  if(raw[center + pixel[4]] > cb){
                   if(raw[center + pixel[5]] > cb){
                    if(raw[center + pixel[6]] > cb){
                     
                    } else {
                     continue; }
                   } else {
                    continue; }
                  } else {
                   continue; }
                 }
                 
                } else {
                 if(raw[center + pixel[3]] > cb){
                  if(raw[center + pixel[4]] > cb){
                   if(raw[center + pixel[5]] > cb){
                    if(raw[center + pixel[6]] > cb){
                     
                    } else {
                     continue; }
                   } else {
                    continue; }
                  } else {
                   continue; }
                 } else {
                  continue; }
                }
                
               } else {
                if(raw[center + pixel[2]] > cb){
                 if(raw[center + pixel[3]] > cb){
                  if(raw[center + pixel[4]] > cb){
                   if(raw[center + pixel[5]] > cb){
                    if(raw[center + pixel[6]] > cb){
                     
                    } else {
                     continue; }
                   } else {
                    continue; }
                  } else {
                   continue; }
                 } else {
                  continue; }
                } else {
                 continue; }
               }
               
              } else {
               continue; }
             } else {
              continue; }
            } else {
             continue; }
           } else {
            continue; }
          } else if(raw[center + pixel[7]] < c_b){
           if(raw[center + pixel[6]] < c_b){
            if(raw[center + pixel[8]] < c_b){
             if(raw[center + pixel[9]] < c_b){
              if(raw[center + pixel[10]] < c_b){
               if(raw[center + pixel[11]] < c_b){
                if(raw[center + pixel[5]] < c_b){
                 if(raw[center + pixel[4]] < c_b){
                  if(raw[center + pixel[3]] < c_b){
                   if(raw[center + pixel[2]] < c_b){
                    
                   } else {
                    if(raw[center + pixel[12]] < c_b){
                     
                    } else {
                     continue; }
                   }
                   
                  } else {
                   if(raw[center + pixel[12]] < c_b){
                    if(raw[center + pixel[13]] < c_b){
                     
                    } else {
                     continue; }
                   } else {
                    continue; }
                  }
                  
                 } else {
                  if(raw[center + pixel[12]] < c_b){
                   if(raw[center + pixel[13]] < c_b){
                    if(raw[center + pixel[14]] < c_b){
                     
                    } else {
                     continue; }
                   } else {
                    continue; }
                  } else {
                   continue; }
                 }
                 
                } else {
                 if(raw[center + pixel[12]] < c_b){
                  if(raw[center + pixel[13]] < c_b){
                   if(raw[center + pixel[14]] < c_b){
                    if(raw[center + pixel[15]] < c_b){
                     
                    } else {
                     continue; }
                   } else {
                    continue; }
                  } else {
                   continue; }
                 } else {
                  continue; }
                }
                
               } else {
                continue; }
              } else {
               continue; }
             } else {
              continue; }
            } else {
             continue; }
           } else {
            continue; }
          } else {
           continue; }
         }
         
        } else if(raw[center + pixel[0]] < c_b){
         if(raw[center + pixel[1]] > cb){
          if(raw[center + pixel[7]] > cb){
           if(raw[center + pixel[6]] > cb){
            if(raw[center + pixel[8]] > cb){
             if(raw[center + pixel[9]] > cb){
              if(raw[center + pixel[10]] > cb){
               if(raw[center + pixel[5]] > cb){
                if(raw[center + pixel[4]] > cb){
                 if(raw[center + pixel[3]] > cb){
                  if(raw[center + pixel[2]] > cb){
                   
                  } else {
                   if(raw[center + pixel[11]] > cb){
                    if(raw[center + pixel[12]] > cb){
                     
                    } else {
                     continue; }
                   } else {
                    continue; }
                  }
                  
                 } else {
                  if(raw[center + pixel[11]] > cb){
                   if(raw[center + pixel[12]] > cb){
                    if(raw[center + pixel[13]] > cb){
                     
                    } else {
                     continue; }
                   } else {
                    continue; }
                  } else {
                   continue; }
                 }
                 
                } else {
                 if(raw[center + pixel[11]] > cb){
                  if(raw[center + pixel[12]] > cb){
                   if(raw[center + pixel[13]] > cb){
                    if(raw[center + pixel[14]] > cb){
                     
                    } else {
                     continue; }
                   } else {
                    continue; }
                  } else {
                   continue; }
                 } else {
                  continue; }
                }
                
               } else {
                if(raw[center + pixel[11]] > cb){
                 if(raw[center + pixel[12]] > cb){
                  if(raw[center + pixel[13]] > cb){
                   if(raw[center + pixel[14]] > cb){
                    if(raw[center + pixel[15]] > cb){
                     
                    } else {
                     continue; }
                   } else {
                    continue; }
                  } else {
                   continue; }
                 } else {
                  continue; }
                } else {
                 continue; }
               }
               
              } else {
               continue; }
             } else {
              continue; }
            } else {
             continue; }
           } else {
            continue; }
          } else if(raw[center + pixel[7]] < c_b){
           if(raw[center + pixel[8]] < c_b){
            if(raw[center + pixel[9]] < c_b){
             if(raw[center + pixel[10]] < c_b){
              if(raw[center + pixel[11]] < c_b){
               if(raw[center + pixel[12]] < c_b){
                if(raw[center + pixel[13]] < c_b){
                 if(raw[center + pixel[14]] < c_b){
                  if(raw[center + pixel[15]] < c_b){
                   
                  } else {
                   if(raw[center + pixel[5]] < c_b){
                    if(raw[center + pixel[6]] < c_b){
                     
                    } else {
                     continue; }
                   } else {
                    continue; }
                  }
                  
                 } else {
                  if(raw[center + pixel[4]] < c_b){
                   if(raw[center + pixel[5]] < c_b){
                    if(raw[center + pixel[6]] < c_b){
                     
                    } else {
                     continue; }
                   } else {
                    continue; }
                  } else {
                   continue; }
                 }
                 
                } else {
                 if(raw[center + pixel[3]] < c_b){
                  if(raw[center + pixel[4]] < c_b){
                   if(raw[center + pixel[5]] < c_b){
                    if(raw[center + pixel[6]] < c_b){
                     
                    } else {
                     continue; }
                   } else {
                    continue; }
                  } else {
                   continue; }
                 } else {
                  continue; }
                }
                
               } else {
                if(raw[center + pixel[2]] < c_b){
                 if(raw[center + pixel[3]] < c_b){
                  if(raw[center + pixel[4]] < c_b){
                   if(raw[center + pixel[5]] < c_b){
                    if(raw[center + pixel[6]] < c_b){
                     
                    } else {
                     continue; }
                   } else {
                    continue; }
                  } else {
                   continue; }
                 } else {
                  continue; }
                } else {
                 continue; }
               }
               
              } else {
               continue; }
             } else {
              continue; }
            } else {
             continue; }
           } else {
            continue; }
          } else {
           continue; }
         } else if(raw[center + pixel[1]] < c_b){
          if(raw[center + pixel[2]] > cb){
           if(raw[center + pixel[8]] > cb){
            if(raw[center + pixel[6]] > cb){
             if(raw[center + pixel[7]] > cb){
              if(raw[center + pixel[9]] > cb){
               if(raw[center + pixel[10]] > cb){
                if(raw[center + pixel[11]] > cb){
                 if(raw[center + pixel[5]] > cb){
                  if(raw[center + pixel[4]] > cb){
                   if(raw[center + pixel[3]] > cb){
                    
                   } else {
                    if(raw[center + pixel[12]] > cb){
                     if(raw[center + pixel[13]] > cb){
                      
                     } else {
                      continue; }
                    } else {
                     continue; }
                   }
                   
                  } else {
                   if(raw[center + pixel[12]] > cb){
                    if(raw[center + pixel[13]] > cb){
                     if(raw[center + pixel[14]] > cb){
                      
                     } else {
                      continue; }
                    } else {
                     continue; }
                   } else {
                    continue; }
                  }
                  
                 } else {
                  if(raw[center + pixel[12]] > cb){
                   if(raw[center + pixel[13]] > cb){
                    if(raw[center + pixel[14]] > cb){
                     if(raw[center + pixel[15]] > cb){
                      
                     } else {
                      continue; }
                    } else {
                     continue; }
                   } else {
                    continue; }
                  } else {
                   continue; }
                 }
                 
                } else {
                 continue; }
               } else {
                continue; }
              } else {
               continue; }
             } else {
              continue; }
            } else {
             continue; }
           } else if(raw[center + pixel[8]] < c_b){
            if(raw[center + pixel[9]] < c_b){
             if(raw[center + pixel[10]] < c_b){
              if(raw[center + pixel[11]] < c_b){
               if(raw[center + pixel[12]] < c_b){
                if(raw[center + pixel[13]] < c_b){
                 if(raw[center + pixel[14]] < c_b){
                  if(raw[center + pixel[15]] < c_b){
                   
                  } else {
                   if(raw[center + pixel[5]] < c_b){
                    if(raw[center + pixel[6]] < c_b){
                     if(raw[center + pixel[7]] < c_b){
                      
                     } else {
                      continue; }
                    } else {
                     continue; }
                   } else {
                    continue; }
                  }
                  
                 } else {
                  if(raw[center + pixel[4]] < c_b){
                   if(raw[center + pixel[5]] < c_b){
                    if(raw[center + pixel[6]] < c_b){
                     if(raw[center + pixel[7]] < c_b){
                      
                     } else {
                      continue; }
                    } else {
                     continue; }
                   } else {
                    continue; }
                  } else {
                   continue; }
                 }
                 
                } else {
                 if(raw[center + pixel[3]] < c_b){
                  if(raw[center + pixel[4]] < c_b){
                   if(raw[center + pixel[5]] < c_b){
                    if(raw[center + pixel[6]] < c_b){
                     if(raw[center + pixel[7]] < c_b){
                      
                     } else {
                      continue; }
                    } else {
                     continue; }
                   } else {
                    continue; }
                  } else {
                   continue; }
                 } else {
                  continue; }
                }
                
               } else {
                continue; }
              } else {
               continue; }
             } else {
              continue; }
            } else {
             continue; }
           } else {
            continue; }
          } else if(raw[center + pixel[2]] < c_b){
           if(raw[center + pixel[3]] > cb){
            if(raw[center + pixel[9]] > cb){
             if(raw[center + pixel[6]] > cb){
              if(raw[center + pixel[7]] > cb){
               if(raw[center + pixel[8]] > cb){
                if(raw[center + pixel[10]] > cb){
                 if(raw[center + pixel[11]] > cb){
                  if(raw[center + pixel[12]] > cb){
                   if(raw[center + pixel[5]] > cb){
                    if(raw[center + pixel[4]] > cb){
                     
                    } else {
                     if(raw[center + pixel[13]] > cb){
                      if(raw[center + pixel[14]] > cb){
                       
                      } else {
                       continue; }
                     } else {
                      continue; }
                    }
                    
                   } else {
                    if(raw[center + pixel[13]] > cb){
                     if(raw[center + pixel[14]] > cb){
                      if(raw[center + pixel[15]] > cb){
                       
                      } else {
                       continue; }
                     } else {
                      continue; }
                    } else {
                     continue; }
                   }
                   
                  } else {
                   continue; }
                 } else {
                  continue; }
                } else {
                 continue; }
               } else {
                continue; }
              } else {
               continue; }
             } else {
              continue; }
            } else if(raw[center + pixel[9]] < c_b){
             if(raw[center + pixel[10]] < c_b){
              if(raw[center + pixel[11]] < c_b){
               if(raw[center + pixel[12]] < c_b){
                if(raw[center + pixel[13]] < c_b){
                 if(raw[center + pixel[14]] < c_b){
                  if(raw[center + pixel[15]] < c_b){
                   
                  } else {
                   if(raw[center + pixel[5]] < c_b){
                    if(raw[center + pixel[6]] < c_b){
                     if(raw[center + pixel[7]] < c_b){
                      if(raw[center + pixel[8]] < c_b){
                       
                      } else {
                       continue; }
                     } else {
                      continue; }
                    } else {
                     continue; }
                   } else {
                    continue; }
                  }
                  
                 } else {
                  if(raw[center + pixel[4]] < c_b){
                   if(raw[center + pixel[5]] < c_b){
                    if(raw[center + pixel[6]] < c_b){
                     if(raw[center + pixel[7]] < c_b){
                      if(raw[center + pixel[8]] < c_b){
                       
                      } else {
                       continue; }
                     } else {
                      continue; }
                    } else {
                     continue; }
                   } else {
                    continue; }
                  } else {
                   continue; }
                 }
                 
                } else {
                 continue; }
               } else {
                continue; }
              } else {
               continue; }
             } else {
              continue; }
            } else {
             continue; }
           } else if(raw[center + pixel[3]] < c_b){
            if(raw[center + pixel[4]] > cb){
             if(raw[center + pixel[14]] > cb){
              if(raw[center + pixel[6]] > cb){
               if(raw[center + pixel[7]] > cb){
                if(raw[center + pixel[8]] > cb){
                 if(raw[center + pixel[9]] > cb){
                  if(raw[center + pixel[10]] > cb){
                   if(raw[center + pixel[11]] > cb){
                    if(raw[center + pixel[12]] > cb){
                     if(raw[center + pixel[13]] > cb){
                      if(raw[center + pixel[5]] > cb){
                       
                      } else {
                       if(raw[center + pixel[15]] > cb){
                        
                       } else {
                        continue; }
                      }
                      
                     } else {
                      continue; }
                    } else {
                     continue; }
                   } else {
                    continue; }
                  } else {
                   continue; }
                 } else {
                  continue; }
                } else {
                 continue; }
               } else {
                continue; }
              } else {
               continue; }
             } else if(raw[center + pixel[14]] < c_b){
              if(raw[center + pixel[10]] > cb){
               if(raw[center + pixel[5]] > cb){
                if(raw[center + pixel[6]] > cb){
                 if(raw[center + pixel[7]] > cb){
                  if(raw[center + pixel[8]] > cb){
                   if(raw[center + pixel[9]] > cb){
                    if(raw[center + pixel[11]] > cb){
                     if(raw[center + pixel[12]] > cb){
                      if(raw[center + pixel[13]] > cb){
                       
                      } else {
                       continue; }
                     } else {
                      continue; }
                    } else {
                     continue; }
                   } else {
                    continue; }
                  } else {
                   continue; }
                 } else {
                  continue; }
                } else {
                 continue; }
               } else {
                continue; }
              } else if(raw[center + pixel[10]] < c_b){
               if(raw[center + pixel[11]] < c_b){
                if(raw[center + pixel[12]] < c_b){
                 if(raw[center + pixel[13]] < c_b){
                  if(raw[center + pixel[15]] < c_b){
                   
                  } else {
                   if(raw[center + pixel[5]] < c_b){
                    if(raw[center + pixel[6]] < c_b){
                     if(raw[center + pixel[7]] < c_b){
                      if(raw[center + pixel[8]] < c_b){
                       if(raw[center + pixel[9]] < c_b){
                        
                       } else {
                        continue; }
                      } else {
                       continue; }
                     } else {
                      continue; }
                    } else {
                     continue; }
                   } else {
                    continue; }
                  }
                  
                 } else {
                  continue; }
                } else {
                 continue; }
               } else {
                continue; }
              } else {
               continue; }
             } else {
              if(raw[center + pixel[5]] > cb){
               if(raw[center + pixel[6]] > cb){
                if(raw[center + pixel[7]] > cb){
                 if(raw[center + pixel[8]] > cb){
                  if(raw[center + pixel[9]] > cb){
                   if(raw[center + pixel[10]] > cb){
                    if(raw[center + pixel[11]] > cb){
                     if(raw[center + pixel[12]] > cb){
                      if(raw[center + pixel[13]] > cb){
                       
                      } else {
                       continue; }
                     } else {
                      continue; }
                    } else {
                     continue; }
                   } else {
                    continue; }
                  } else {
                   continue; }
                 } else {
                  continue; }
                } else {
                 continue; }
               } else {
                continue; }
              } else {
               continue; }
             }
             
            } else if(raw[center + pixel[4]] < c_b){
             if(raw[center + pixel[5]] > cb){
              if(raw[center + pixel[15]] < c_b){
               if(raw[center + pixel[11]] > cb){
                if(raw[center + pixel[6]] > cb){
                 if(raw[center + pixel[7]] > cb){
                  if(raw[center + pixel[8]] > cb){
                   if(raw[center + pixel[9]] > cb){
                    if(raw[center + pixel[10]] > cb){
                     if(raw[center + pixel[12]] > cb){
                      if(raw[center + pixel[13]] > cb){
                       if(raw[center + pixel[14]] > cb){
                        
                       } else {
                        continue; }
                      } else {
                       continue; }
                     } else {
                      continue; }
                    } else {
                     continue; }
                   } else {
                    continue; }
                  } else {
                   continue; }
                 } else {
                  continue; }
                } else {
                 continue; }
               } else if(raw[center + pixel[11]] < c_b){
                if(raw[center + pixel[12]] < c_b){
                 if(raw[center + pixel[13]] < c_b){
                  if(raw[center + pixel[14]] < c_b){
                   
                  } else {
                   continue; }
                 } else {
                  continue; }
                } else {
                 continue; }
               } else {
                continue; }
              } else {
               if(raw[center + pixel[6]] > cb){
                if(raw[center + pixel[7]] > cb){
                 if(raw[center + pixel[8]] > cb){
                  if(raw[center + pixel[9]] > cb){
                   if(raw[center + pixel[10]] > cb){
                    if(raw[center + pixel[11]] > cb){
                     if(raw[center + pixel[12]] > cb){
                      if(raw[center + pixel[13]] > cb){
                       if(raw[center + pixel[14]] > cb){
                        
                       } else {
                        continue; }
                      } else {
                       continue; }
                     } else {
                      continue; }
                    } else {
                     continue; }
                   } else {
                    continue; }
                  } else {
                   continue; }
                 } else {
                  continue; }
                } else {
                 continue; }
               } else {
                continue; }
              }
              
             } else if(raw[center + pixel[5]] < c_b){
              if(raw[center + pixel[6]] > cb){
               if(raw[center + pixel[12]] > cb){
                if(raw[center + pixel[7]] > cb){
                 if(raw[center + pixel[8]] > cb){
                  if(raw[center + pixel[9]] > cb){
                   if(raw[center + pixel[10]] > cb){
                    if(raw[center + pixel[11]] > cb){
                     if(raw[center + pixel[13]] > cb){
                      if(raw[center + pixel[14]] > cb){
                       if(raw[center + pixel[15]] > cb){
                        
                       } else {
                        continue; }
                      } else {
                       continue; }
                     } else {
                      continue; }
                    } else {
                     continue; }
                   } else {
                    continue; }
                  } else {
                   continue; }
                 } else {
                  continue; }
                } else {
                 continue; }
               } else if(raw[center + pixel[12]] < c_b){
                if(raw[center + pixel[13]] < c_b){
                 if(raw[center + pixel[14]] < c_b){
                  if(raw[center + pixel[15]] < c_b){
                   
                  } else {
                   continue; }
                 } else {
                  continue; }
                } else {
                 continue; }
               } else {
                continue; }
              } else if(raw[center + pixel[6]] < c_b){
               if(raw[center + pixel[7]] < c_b){
                if(raw[center + pixel[8]] < c_b){
                 if(raw[center + pixel[9]] < c_b){
                  
                 } else {
                  if(raw[center + pixel[15]] < c_b){
                   
                  } else {
                   continue; }
                 }
                 
                } else {
                 if(raw[center + pixel[14]] < c_b){
                  if(raw[center + pixel[15]] < c_b){
                   
                  } else {
                   continue; }
                 } else {
                  continue; }
                }
                
               } else {
                if(raw[center + pixel[13]] < c_b){
                 if(raw[center + pixel[14]] < c_b){
                  if(raw[center + pixel[15]] < c_b){
                   
                  } else {
                   continue; }
                 } else {
                  continue; }
                } else {
                 continue; }
               }
               
              } else {
               if(raw[center + pixel[12]] < c_b){
                if(raw[center + pixel[13]] < c_b){
                 if(raw[center + pixel[14]] < c_b){
                  if(raw[center + pixel[15]] < c_b){
                   
                  } else {
                   continue; }
                 } else {
                  continue; }
                } else {
                 continue; }
               } else {
                continue; }
              }
              
             } else {
              if(raw[center + pixel[11]] > cb){
               if(raw[center + pixel[6]] > cb){
                if(raw[center + pixel[7]] > cb){
                 if(raw[center + pixel[8]] > cb){
                  if(raw[center + pixel[9]] > cb){
                   if(raw[center + pixel[10]] > cb){
                    if(raw[center + pixel[12]] > cb){
                     if(raw[center + pixel[13]] > cb){
                      if(raw[center + pixel[14]] > cb){
                       if(raw[center + pixel[15]] > cb){
                        
                       } else {
                        continue; }
                      } else {
                       continue; }
                     } else {
                      continue; }
                    } else {
                     continue; }
                   } else {
                    continue; }
                  } else {
                   continue; }
                 } else {
                  continue; }
                } else {
                 continue; }
               } else {
                continue; }
              } else if(raw[center + pixel[11]] < c_b){
               if(raw[center + pixel[12]] < c_b){
                if(raw[center + pixel[13]] < c_b){
                 if(raw[center + pixel[14]] < c_b){
                  if(raw[center + pixel[15]] < c_b){
                   
                  } else {
                   continue; }
                 } else {
                  continue; }
                } else {
                 continue; }
               } else {
                continue; }
              } else {
               continue; }
             }
             
            } else {
             if(raw[center + pixel[10]] > cb){
              if(raw[center + pixel[6]] > cb){
               if(raw[center + pixel[7]] > cb){
                if(raw[center + pixel[8]] > cb){
                 if(raw[center + pixel[9]] > cb){
                  if(raw[center + pixel[11]] > cb){
                   if(raw[center + pixel[12]] > cb){
                    if(raw[center + pixel[13]] > cb){
                     if(raw[center + pixel[14]] > cb){
                      if(raw[center + pixel[5]] > cb){
                       
                      } else {
                       if(raw[center + pixel[15]] > cb){
                        
                       } else {
                        continue; }
                      }
                      
                     } else {
                      continue; }
                    } else {
                     continue; }
                   } else {
                    continue; }
                  } else {
                   continue; }
                 } else {
                  continue; }
                } else {
                 continue; }
               } else {
                continue; }
              } else {
               continue; }
             } else if(raw[center + pixel[10]] < c_b){
              if(raw[center + pixel[11]] < c_b){
               if(raw[center + pixel[12]] < c_b){
                if(raw[center + pixel[13]] < c_b){
                 if(raw[center + pixel[14]] < c_b){
                  if(raw[center + pixel[15]] < c_b){
                   
                  } else {
                   if(raw[center + pixel[5]] < c_b){
                    if(raw[center + pixel[6]] < c_b){
                     if(raw[center + pixel[7]] < c_b){
                      if(raw[center + pixel[8]] < c_b){
                       if(raw[center + pixel[9]] < c_b){
                        
                       } else {
                        continue; }
                      } else {
                       continue; }
                     } else {
                      continue; }
                    } else {
                     continue; }
                   } else {
                    continue; }
                  }
                  
                 } else {
                  continue; }
                } else {
                 continue; }
               } else {
                continue; }
              } else {
               continue; }
             } else {
              continue; }
            }
            
           } else {
            if(raw[center + pixel[9]] > cb){
             if(raw[center + pixel[6]] > cb){
              if(raw[center + pixel[7]] > cb){
               if(raw[center + pixel[8]] > cb){
                if(raw[center + pixel[10]] > cb){
                 if(raw[center + pixel[11]] > cb){
                  if(raw[center + pixel[12]] > cb){
                   if(raw[center + pixel[13]] > cb){
                    if(raw[center + pixel[5]] > cb){
                     if(raw[center + pixel[4]] > cb){
                      
                     } else {
                      if(raw[center + pixel[14]] > cb){
                       
                      } else {
                       continue; }
                     }
                     
                    } else {
                     if(raw[center + pixel[14]] > cb){
                      if(raw[center + pixel[15]] > cb){
                       
                      } else {
                       continue; }
                     } else {
                      continue; }
                    }
                    
                   } else {
                    continue; }
                  } else {
                   continue; }
                 } else {
                  continue; }
                } else {
                 continue; }
               } else {
                continue; }
              } else {
               continue; }
             } else {
              continue; }
            } else if(raw[center + pixel[9]] < c_b){
             if(raw[center + pixel[10]] < c_b){
              if(raw[center + pixel[11]] < c_b){
               if(raw[center + pixel[12]] < c_b){
                if(raw[center + pixel[13]] < c_b){
                 if(raw[center + pixel[14]] < c_b){
                  if(raw[center + pixel[15]] < c_b){
                   
                  } else {
                   if(raw[center + pixel[5]] < c_b){
                    if(raw[center + pixel[6]] < c_b){
                     if(raw[center + pixel[7]] < c_b){
                      if(raw[center + pixel[8]] < c_b){
                       
                      } else {
                       continue; }
                     } else {
                      continue; }
                    } else {
                     continue; }
                   } else {
                    continue; }
                  }
                  
                 } else {
                  if(raw[center + pixel[4]] < c_b){
                   if(raw[center + pixel[5]] < c_b){
                    if(raw[center + pixel[6]] < c_b){
                     if(raw[center + pixel[7]] < c_b){
                      if(raw[center + pixel[8]] < c_b){
                       
                      } else {
                       continue; }
                     } else {
                      continue; }
                    } else {
                     continue; }
                   } else {
                    continue; }
                  } else {
                   continue; }
                 }
                 
                } else {
                 continue; }
               } else {
                continue; }
              } else {
               continue; }
             } else {
              continue; }
            } else {
             continue; }
           }
           
          } else {
           if(raw[center + pixel[8]] > cb){
            if(raw[center + pixel[6]] > cb){
             if(raw[center + pixel[7]] > cb){
              if(raw[center + pixel[9]] > cb){
               if(raw[center + pixel[10]] > cb){
                if(raw[center + pixel[11]] > cb){
                 if(raw[center + pixel[12]] > cb){
                  if(raw[center + pixel[5]] > cb){
                   if(raw[center + pixel[4]] > cb){
                    if(raw[center + pixel[3]] > cb){
                     
                    } else {
                     if(raw[center + pixel[13]] > cb){
                      
                     } else {
                      continue; }
                    }
                    
                   } else {
                    if(raw[center + pixel[13]] > cb){
                     if(raw[center + pixel[14]] > cb){
                      
                     } else {
                      continue; }
                    } else {
                     continue; }
                   }
                   
                  } else {
                   if(raw[center + pixel[13]] > cb){
                    if(raw[center + pixel[14]] > cb){
                     if(raw[center + pixel[15]] > cb){
                      
                     } else {
                      continue; }
                    } else {
                     continue; }
                   } else {
                    continue; }
                  }
                  
                 } else {
                  continue; }
                } else {
                 continue; }
               } else {
                continue; }
              } else {
               continue; }
             } else {
              continue; }
            } else {
             continue; }
           } else if(raw[center + pixel[8]] < c_b){
            if(raw[center + pixel[9]] < c_b){
             if(raw[center + pixel[10]] < c_b){
              if(raw[center + pixel[11]] < c_b){
               if(raw[center + pixel[12]] < c_b){
                if(raw[center + pixel[13]] < c_b){
                 if(raw[center + pixel[14]] < c_b){
                  if(raw[center + pixel[15]] < c_b){
                   
                  } else {
                   if(raw[center + pixel[5]] < c_b){
                    if(raw[center + pixel[6]] < c_b){
                     if(raw[center + pixel[7]] < c_b){
                      
                     } else {
                      continue; }
                    } else {
                     continue; }
                   } else {
                    continue; }
                  }
                  
                 } else {
                  if(raw[center + pixel[4]] < c_b){
                   if(raw[center + pixel[5]] < c_b){
                    if(raw[center + pixel[6]] < c_b){
                     if(raw[center + pixel[7]] < c_b){
                      
                     } else {
                      continue; }
                    } else {
                     continue; }
                   } else {
                    continue; }
                  } else {
                   continue; }
				 }
				 
                } else {
                 if(raw[center + pixel[3]] < c_b){
                  if(raw[center + pixel[4]] < c_b){
                   if(raw[center + pixel[5]] < c_b){
                    if(raw[center + pixel[6]] < c_b){
                     if(raw[center + pixel[7]] < c_b){
                      
                     } else {
                      continue; }
                    } else {
                     continue; }
                   } else {
                    continue; }
                  } else {
                   continue; }
                 } else {
                  continue; }
                }
                
               } else {
                continue; }
              } else {
               continue; }
             } else {
              continue; }
            } else {
             continue; }
           } else {
            continue; }
          }
          
         } else {
          if(raw[center + pixel[7]] > cb){
           if(raw[center + pixel[6]] > cb){
            if(raw[center + pixel[8]] > cb){
             if(raw[center + pixel[9]] > cb){
              if(raw[center + pixel[10]] > cb){
               if(raw[center + pixel[11]] > cb){
                if(raw[center + pixel[5]] > cb){
                 if(raw[center + pixel[4]] > cb){
                  if(raw[center + pixel[3]] > cb){
                   if(raw[center + pixel[2]] > cb){
                    
                   } else {
                    if(raw[center + pixel[12]] > cb){
                     
                    } else {
                     continue; }
                   }
                   
                  } else {
                   if(raw[center + pixel[12]] > cb){
                    if(raw[center + pixel[13]] > cb){
                     
                    } else {
                     continue; }
                   } else {
                    continue; }
                  }
                  
                 } else {
                  if(raw[center + pixel[12]] > cb){
                   if(raw[center + pixel[13]] > cb){
                    if(raw[center + pixel[14]] > cb){
                     
                    } else {
                     continue; }
                   } else {
                    continue; }
                  } else {
                   continue; }
                 }
                 
                } else {
                 if(raw[center + pixel[12]] > cb){
                  if(raw[center + pixel[13]] > cb){
                   if(raw[center + pixel[14]] > cb){
                    if(raw[center + pixel[15]] > cb){
                     
                    } else {
                     continue; }
                   } else {
                    continue; }
                  } else {
                   continue; }
                 } else {
                  continue; }
                }
                
               } else {
                continue; }
              } else {
               continue; }
             } else {
              continue; }
            } else {
             continue; }
           } else {
            continue; }
          } else if(raw[center + pixel[7]] < c_b){
           if(raw[center + pixel[8]] < c_b){
            if(raw[center + pixel[9]] < c_b){
             if(raw[center + pixel[10]] < c_b){
              if(raw[center + pixel[11]] < c_b){
               if(raw[center + pixel[12]] < c_b){
                if(raw[center + pixel[13]] < c_b){
                 if(raw[center + pixel[14]] < c_b){
                  if(raw[center + pixel[15]] < c_b){
                   
                  } else {
                   if(raw[center + pixel[5]] < c_b){
                    if(raw[center + pixel[6]] < c_b){
                     
                    } else {
                     continue; }
                   } else {
                    continue; }
                  }
                  
                 } else {
                  if(raw[center + pixel[4]] < c_b){
                   if(raw[center + pixel[5]] < c_b){
                    if(raw[center + pixel[6]] < c_b){
                     
                    } else {
                     continue; }
                   } else {
                    continue; }
                  } else {
                   continue; }
                 }
                 
                } else {
                 if(raw[center + pixel[3]] < c_b){
                  if(raw[center + pixel[4]] < c_b){
                   if(raw[center + pixel[5]] < c_b){
                    if(raw[center + pixel[6]] < c_b){
                     
                    } else {
                     continue; }
                   } else {
                    continue; }
                  } else {
                   continue; }
                 } else {
                  continue; }
                }
                
               } else {
                if(raw[center + pixel[2]] < c_b){
                 if(raw[center + pixel[3]] < c_b){
                  if(raw[center + pixel[4]] < c_b){
                   if(raw[center + pixel[5]] < c_b){
                    if(raw[center + pixel[6]] < c_b){
                     
                    } else {
                     continue; }
                   } else {
                    continue; }
                  } else {
                   continue; }
                 } else {
                  continue; }
                } else {
                 continue; }
               }
               
              } else {
               continue; }
             } else {
              continue; }
            } else {
             continue; }
           } else {
            continue; }
          } else {
           continue; }
         }
         
        } else {
         if(raw[center + pixel[6]] > cb){
          if(raw[center + pixel[7]] > cb){
           if(raw[center + pixel[8]] > cb){
            if(raw[center + pixel[9]] > cb){
             if(raw[center + pixel[10]] > cb){
              if(raw[center + pixel[5]] > cb){
               if(raw[center + pixel[4]] > cb){
                if(raw[center + pixel[3]] > cb){
                 if(raw[center + pixel[2]] > cb){
                  if(raw[center + pixel[1]] > cb){
                   
                  } else {
                   if(raw[center + pixel[11]] > cb){
                    
                   } else {
                    continue; }
                  }
                  
                 } else {
                  if(raw[center + pixel[11]] > cb){
                   if(raw[center + pixel[12]] > cb){
                    
                   } else {
                    continue; }
                  } else {
                   continue; }
                 }
                 
                } else {
                 if(raw[center + pixel[11]] > cb){
                  if(raw[center + pixel[12]] > cb){
                   if(raw[center + pixel[13]] > cb){
                    
                   } else {
                    continue; }
                  } else {
                   continue; }
                 } else {
                  continue; }
                }
                
               } else {
                if(raw[center + pixel[11]] > cb){
                 if(raw[center + pixel[12]] > cb){
                  if(raw[center + pixel[13]] > cb){
                   if(raw[center + pixel[14]] > cb){
                    
                   } else {
                    continue; }
                  } else {
                   continue; }
                 } else {
                  continue; }
                } else {
                 continue; }
               }
               
              } else {
               if(raw[center + pixel[11]] > cb){
                if(raw[center + pixel[12]] > cb){
                 if(raw[center + pixel[13]] > cb){
                  if(raw[center + pixel[14]] > cb){
                   if(raw[center + pixel[15]] > cb){
                    
                   } else {
                    continue; }
                  } else {
                   continue; }
                 } else {
                  continue; }
                } else {
                 continue; }
               } else {
                continue; }
              }
              
             } else {
              continue; }
            } else {
             continue; }
           } else {
            continue; }
          } else {
           continue; }
         } else if(raw[center + pixel[6]] < c_b){
          if(raw[center + pixel[7]] < c_b){
           if(raw[center + pixel[8]] < c_b){
            if(raw[center + pixel[9]] < c_b){
             if(raw[center + pixel[10]] < c_b){
              if(raw[center + pixel[5]] < c_b){
               if(raw[center + pixel[4]] < c_b){
                if(raw[center + pixel[3]] < c_b){
                 if(raw[center + pixel[2]] < c_b){
                  if(raw[center + pixel[1]] < c_b){
                   
                  } else {
                   if(raw[center + pixel[11]] < c_b){
                    
                   } else {
                    continue; }
                  }
                  
                 } else {
                  if(raw[center + pixel[11]] < c_b){
                   if(raw[center + pixel[12]] < c_b){
                    
                   } else {
                    continue; }
                  } else {
                   continue; }
                 }
                 
                } else {
                 if(raw[center + pixel[11]] < c_b){
                  if(raw[center + pixel[12]] < c_b){
                   if(raw[center + pixel[13]] < c_b){
                    
                   } else {
                    continue; }
                  } else {
                   continue; }
                 } else {
                  continue; }
                }
                
               } else {
                if(raw[center + pixel[11]] < c_b){
                 if(raw[center + pixel[12]] < c_b){
                  if(raw[center + pixel[13]] < c_b){
                   if(raw[center + pixel[14]] < c_b){
                    
                   } else {
                    continue; }
                  } else {
                   continue; }
                 } else {
                  continue; }
                } else {
                 continue; }
               }
               
              } else {
               if(raw[center + pixel[11]] < c_b){
                if(raw[center + pixel[12]] < c_b){
                 if(raw[center + pixel[13]] < c_b){
                  if(raw[center + pixel[14]] < c_b){
                   if(raw[center + pixel[15]] < c_b){
                    
                   } else {
                    continue; }
                  } else {
                   continue; }
                 } else {
                  continue; }
                } else {
                 continue; }
               } else {
                continue; }
              }
              
             } else {
              continue; }
            } else {
             continue; }
           } else {
            continue; }
          } else {
           continue; }
         } else {
          continue; }
          
          ret_corners[num_corners] = new Point(xp,yp);
			num_corners++;
		
		}
		
				
		} // end if
		
		}}// end xy loops
		
		return ret_corners;
		
		}
	}
}

import flash.display.Sprite;

class Ball extends Sprite 
{
    public var abs_ct1: Number;

	function Ball(xp:int,yp:int){
		graphics.beginFill(0xff0000, .7);
		//graphics.lineStyle(2, 0xff0000, 1);
		graphics.drawCircle(0,0,10);
		graphics.endFill();
		x = xp;
		y = yp;
		
	}
	
}
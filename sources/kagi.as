/*
 * 一筆書きでいかに正円に近い円を書けるかを競います。
 * 得点には、正確さだけではなく、速さと、大きさも影響します。
 * より速く、より大きく、より正確に正円がかけると得点があがります。
 * 100点満点で、理論上は満点とるのは可能ですが、まず無理でしょう。。。
 * 
 * ･･･正円判定はかなりざっくりです。
 * 
 * ちなみにこれはiPhoneアプリネタを考えてたときに浮かんだのですが、
 * すでに似たようなものがあったので、断念したというお話でした。。
 * 
 * 勢いで書いたのでソース汚いです。。。
 *
 * 2010/06/15:追記
 * 理論上100点越えるケースがあったので、越えないようにしました。
 * 理論上はガンバレば100点だせる、はずｗ
 * */

package {
	import com.bit101.components.PushButton;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.escapeMultiByte;
	import flash.utils.getTimer;
	
	[SWF(backgroundColor="0x808080", frameRate="120", width="320", height="480")]
	/**
	 * ...
	 * @author 393
	 */
	public class RealCircle extends Sprite{
		private var _graphic:Graphics;
		private var _bmd:BitmapData;
		private var _bm:Bitmap;
		private var _realBmd:BitmapData;
		private var _realBm:Bitmap;
		private var _shape:Shape = new Shape();
		private var _sGraphic:Graphics;
		private var _centerPoint:Point;
		private var _pointArray:Array = [];
		private var _pointsLength:int;
		private var _realPointArray:Array = [];
		private var _realPointsLength:int;
		private var _radiusArray:Array = [];
		private var _pointDistance:Number = 100000;
		private var _pointDistanceAverage:int;
		
		//評価パラメータ
		private var _drawSpeed:Number = 0;
		private var _drawSize:int = 0;
		private var _drawAccuracy:int = 0;
		
		private var _generalTf:TextField = new TextField();
		private var _accuracyTf:TextField = new TextField();
		private var _speedTf:TextField = new TextField();
		private var _sizeTf:TextField = new TextField();
		private var _infoTf:TextField = new TextField();
		
		//定数
		private const SPEED_MAX:Number = 10;
		private const SPEED_MIN:Number = 1;
		private const SPEED_POINT:Number = 100;
		
		private const SIZE_MAX:Number = 155;
		private const SIZE_MIN:Number = 10;
		private const SIZE_POINT:Number = 300;
		
		private const ACCURACY_MAX:Number = 20;
		private const ACCURACY_MIN:Number = 0;
		private const ACCURACY_POINT:Number = 100;
		
		private const LINE_COLOR:int = 0xFFFF00;
		private const REAL_LINE_COLOR:int = 0xFF0000;
		
		private var _retryButton:PushButton;
		private var _postButton:PushButton;
		private var _totalScoreStr:String;
		private var _info:String  = "正円を書いてください。\n速く、大きく、そして正確に";
		
		private var _isNotCircle:Boolean;
		
		public function RealCircle() {
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		//初期化処理
		private function init(e:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			//ステージエリアの描画
			stage.addChild(new Bitmap(new BitmapData(stage.stageWidth, stage.stageHeight, false, 0)));
			//ステージエリアを一番下に置く
			stage.setChildIndex(stage.getChildAt(stage.numChildren-1),0)
			
			//評価用(円を転写)
			_bmd = new BitmapData(stage.stageWidth, stage.stageHeight,false,0x000000);
			_bm = new Bitmap(_bmd);
			//正円用(円を転写)
			_realBmd = new BitmapData(stage.stageWidth, stage.stageHeight,true,0x00000000);
			_realBm = new Bitmap(_realBmd);
			
			//正円を描画用
			_sGraphic = _shape.graphics;
			//円を描画用
			_graphic = this.graphics;
			stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			
			//リトライ用のボタン
			_retryButton = new PushButton(stage, 50, stage.stageHeight - 100, "retry", onMouseClick);
			_retryButton.visible = false;
			
			//Twitter投稿用のボタン
			_postButton = new PushButton(stage, 160, stage.stageHeight - 100, "post Twitter", postTwitter);
			_postButton.visible = false;
			
			//infoテキストを表示
			stage.addChild(setTf(_infoTf, _info, 10, 10, 24));
		}
		//マウスダウン時の処理
		private function mouseDownHandler(e:MouseEvent):void {
			_drawSpeed = getTimer();
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			_graphic.lineStyle(2, LINE_COLOR);
			_graphic.moveTo(mouseX, mouseY);
			addEventListener(Event.ENTER_FRAME, entarFrameHandler);
		}
		//円を描画
		private function entarFrameHandler(e:Event):void {
			_graphic.lineTo(mouseX, mouseY);
		}
		
		//マウスアップ処理
		private function mouseUpHandler(e:MouseEvent):void {
			//描画時間をセット
			_drawSpeed = (getTimer() - _drawSpeed) / 1000;
			//描画終了
			_graphic.endFill();
			removeEventListener(Event.ENTER_FRAME, entarFrameHandler);
			//イベントの破棄
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			//書いた円をbitmapDataに転写
			_bmd.draw(this);
			//graphicに書いた円はクリア
			_graphic.clear();
			//bitmapDataを表示
			addChild(_bm);
			//正円用のshapeを表示
			addChild(_shape);
			
			
			//書いた円の座標ポイントを取得
			setCircleMatrix();
			//理想の正円の中心点を取得
			checkCenterPoint();
			//正円の描画
			drawTrueCircle();
			//正確さを判定
			checkAcuracy();
			//結果を表示
			drawResult();
		}
		//書いた円の座標を配列に追加
		private function setCircleMatrix():void {
			var i:int;
			var j:int;
			for (i = 0; i < stage.stageHeight; i+=2) {
				for (j = 0; j < stage.stageWidth; j+=2) {
					if (_bmd.getPixel(j, i) == LINE_COLOR) {
						_pointArray.push(new Point(j, i));
					}
				}
			}
			_pointsLength = _pointArray.length;
		}
		//書いた円の中心座標を計算
		private function checkCenterPoint():void {
			if (_pointArray.length <= 0) return;
			var i:int;
			var maxX:int = 0;
			var minX:int = stage.stageWidth;
			
			//Y座標の最大値を取得
			var maxY:int = _pointArray[_pointsLength - 1].y;
			//Y座標の最小値を取得
			
			var minY:int = _pointArray[0].y;			
			for (i = 0; i < _pointsLength; i++) {
				//X座標の最大値を取得
				if (maxX < _pointArray[i].x) maxX = _pointArray[i].x;
				//X座標の最小値を取得
				if (minX > _pointArray[i].x) minX = _pointArray[i].x;
			}
			//正円の中心座標
			_centerPoint = new Point((maxX - minX) / 2 + minX, (maxY - minY) / 2 + minY);
		}
		//理想の正円を描画
		private function drawTrueCircle():void {
			var radiusSum:Number = 0;
			var i:int;
			for (i = 0; i < _pointsLength; i++) {
				//各ポイントの半径を取得
				_radiusArray.push(Point.distance(_pointArray[i], _centerPoint));
				radiusSum += _radiusArray[i];
			}
			//平均値を正円の半径とする
			var radiusAverage:Number = radiusSum / _pointsLength;
			_drawSize = radiusAverage;
			//円っぽくなってるか判定
			var halfLength:int = _pointsLength / 2;
			var checkDistanceX:Number;
			var checkDistanceY:Number;
			_isNotCircle = true;
			
			//十分にポイントが無かったら終了
			if (_pointsLength < 50) return;
			
			for (i = 0; i < 10; i++) {
				checkDistanceX = Math.abs(_pointArray[halfLength].x - _pointArray[halfLength + i].x);
				checkDistanceY = Math.abs(_pointArray[halfLength].y - _pointArray[halfLength + i].y);
				if (checkDistanceX > _drawSize * 0.8 && checkDistanceY < 10) {
					_isNotCircle = false;
					break;
				}
			}
			
			//グラフィックに正円を描画
			_sGraphic.lineStyle(2, REAL_LINE_COLOR);
			_sGraphic.drawCircle(_centerPoint.x, _centerPoint.y, _drawSize);
			_sGraphic.endFill();
			//ビットマップに転写
			if(!_isNotCircle) _realBmd.draw(_shape);
			addChild(_realBm);
			//グラフィックをクリア
			_sGraphic.clear();
			
			//正円の座標を取得
			var j:int;
			for (i = 0; i < stage.stageHeight; i+=2) {
				for (j = 0; j < stage.stageWidth; j+=2) {
					if (_realBmd.getPixel(j, i) == 0x00FF0000) {
						_realPointArray.push(new Point(j, i));
					}
				}
			}
			_realPointsLength = _realPointArray.length;
		}
		//円の正確さを判定
		private function checkAcuracy():void {
			var i:int;
			var j:int;
			var distanceMax:int;
			var distanceSum:int;
			for (i = 0; i < _pointsLength; i++) {
				var point:Point = _pointArray[i];
				var pointDistanceMin:int = 1000;
				for (j = 0; j < _realPointsLength; j++) {
					var pointDistance:int = Point.distance(point, _realPointArray[j]);
					if (pointDistanceMin > pointDistance) {
						pointDistanceMin = pointDistance;
					}
				}
				distanceSum += pointDistanceMin;
				if(distanceMax <  pointDistanceMin) distanceMax = pointDistanceMin;
			}
			_drawAccuracy = distanceMax;
		}
		//判定結果を表示
		private function drawResult():void {
			//infoを消す
			_infoTf.text = "";
			
			if (!_isNotCircle) {
				//速度
				var speedStr:String = "draw speed : " + _drawSpeed + " sec";
				//サイズ
				var sizeStr:String = "draw size : " + _drawSize + " px";
				//正確さ
				var accuracyStr:String = "draw accuracy : " + _drawAccuracy  +" px";
			}else {
				speedStr = "";
				sizeStr = "";
				accuracyStr = "";
			}
			addChild(setTf(_sizeTf, sizeStr, 0, 20));
			addChild(setTf(_speedTf, speedStr, 0, 0));
			addChild(setTf(_accuracyTf, accuracyStr, 0, 40));
			
			//総合評価(100点からの減点法)
			var totalPoint:Number = 100;
			//速度
			var speed:Number = _drawSpeed / (Math.pow(SPEED_MAX,2) / SPEED_POINT) - SPEED_MIN * SPEED_MIN;
			if (speed > 20) speed = 20;
			//大きさ
			var size:Number = (Math.pow(SIZE_MAX - _drawSize, 4)) / (Math.pow(SIZE_MAX,4) / SIZE_POINT);
			if (size > 40) size = 40;
			//正確さ
			var accuracy:Number = _drawAccuracy / (Math.pow(ACCURACY_MAX,2) / ACCURACY_POINT);
			if (accuracy > 40) accuracy = 40;
			//合計点
			if (!_isNotCircle) {
				var totalScore:Number = xRoundDown(totalPoint - speed - size - accuracy, 2);
				if (totalScore >= 100) totalScore = 100;
				_totalScoreStr = String(totalScore);
				var totalStf:String = "score : " + totalScore;
				_postButton.visible = true;
			}else {
				totalStf = "";
				_infoTf.text = "もうすこし円っぽく･･･";
			}
			_retryButton.visible = true;
			addChild(setTf(_generalTf , totalStf, 160, 20,24));
		}
		private function xRoundDown(nValue:Number, nDigits:int):Number {
		  var nMultiplier:Number = Math.pow(10, nDigits);
		  var nResult:Number = Math.ceil(nValue * nMultiplier) / nMultiplier;
		  return nResult;
		} 
		private function setTf(tf:TextField,str:String,posX:int = 0, posY:int = 0,size:int = 12):TextField {
			var tfm:TextFormat = new TextFormat();
			tfm.color = 0xFFFFFF;
			tfm.size = size;
			tfm.font = "_明朝";
			tf.defaultTextFormat = tfm;
			
			tf.text = str;
			tf.selectable = false;
			tf.mouseEnabled = false;
			tf.autoSize = "left";
			tf.x = posX;
			tf.y = posY;
			return tf;
		}
		
		
		//retryクリック時の処理
		private function onMouseClick(e:MouseEvent):void {
			_bmd.fillRect(_bmd.rect, 0x000000);
			_realBmd.fillRect(_realBmd.rect, 0x00000000);
			if(_bm.parent) removeChild(_bm);
			if(_realBm.parent) removeChild(_realBm);
			_accuracyTf.text = "";
			_generalTf.text = "";
			_sizeTf.text = "";
			_speedTf.text = "";
			removeChild(_accuracyTf);
			removeChild(_generalTf);
			removeChild(_speedTf);
			removeChild(_sizeTf);
			
			_pointArray = [];
			_pointsLength = 0;
			_realPointArray = [];
			_realPointsLength = 0;
			_radiusArray = [];
			
			_retryButton.visible = false;
			_postButton.visible = false;
			
			_infoTf.text = _info;
			stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
		}
		
		//Twitterへ結果をポスト
		private function postTwitter(e:MouseEvent):void {
			var comment:String = "あなたの描いた正円は" + _totalScoreStr + "点です [RealCircle] ";
			var post:String = comment + " " + "http://wonderfl.net/c/kagi" + " " + "#wonderfl";
			navigateToURL(new URLRequest("http://twitter.com/home?status=" + escapeMultiByte(post)), "_blank");
		}
		
	}

}

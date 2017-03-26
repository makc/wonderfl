package
{
	/*
	  ゆらゆら揺れる尻尾です。
	  
	  自由形状の軟体を画像から生成することができます。
	  外形は荒いですが、それっぽく見えると思います。
	  影をつけている処理が意外に重く、これを外せばもっとまともになるかも。
	  
	  今のところ用意している画像は４種類です。
	 */	
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.events.MouseEvent;
	
	import net.hires.debug.Stats;

	public class AnimalTail extends Sprite
	{
		private var _main:AnimalTailMain;
		private var _count:int = int(Math.random()*10);
		private var _nextButton:TextField;
		
		public function AnimalTail()
		{
			addEventListener(Event.ADDED_TO_STAGE, init);	// flexBuilderとの互換性。
			Wonderfl.capture_delay(10);
		}
		
		private function init(event:Event):void {	// ここから開始
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// SWF設定
			stage.frameRate = 20;
			stage.quality = StageQuality.LOW;
			
			createNew(null);
			
			_nextButton = new TextField();
			_nextButton.background = true;
			_nextButton.text = " next ";
			_nextButton.borderColor = 0xffffff;
			_nextButton.autoSize = TextFieldAutoSize.LEFT;
			_nextButton.selectable = false;
			_nextButton.addEventListener(MouseEvent.CLICK, createNew);
			_nextButton.x = 465 - _nextButton.width;
			addChild(_nextButton);
			//addChild(new Stats());
		}
		private function createNew(event:Event):void{
			if (_main != null){
				_main.end();
				removeChild(_main);
				_main = null;
			}
			_main = new AnimalTailMain();
			addChildAt(_main, 0);
			_main.init(_count++);
		}
	}
}
















	import flash.display.Sprite;
	import flash.display.BitmapData;
	import __AS3__.vec.Vector;
	import flash.display.Bitmap;
	import flash.display.Graphics;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import flash.display.TriangleCulling;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.filters.BlurFilter;
	import flash.geom.Matrix;
	import flash.display.GradientType;
	import flash.display.BitmapDataChannel;
	import flash.system.Security;
	import flash.net.URLLoader;
	import flash.display.DisplayObject;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.filters.BevelFilter;
	import flash.filters.BitmapFilterQuality;



class AnimalTailMain extends Sprite
{
	public static const STAGE_W:uint = 465;
	public static const STAGE_H:uint = 465;
	public static const GROUND_H:uint = 350;
	
	private var _loadUrl:String;
	private var _bevelColor:int;
	
	private var _sorceBitmapData:BitmapData;
	private var _puyoIllust:PuyoIllust;
	private var _planeShadow:PlaneShadow;
	
	private var _IMAGE_LIST:Array = [
						{url:"http://asset.sipo.jp/wonderfl/tail/tail1.png", shadow:0x996633},
						{url:"http://asset.sipo.jp/wonderfl/tail/tail2.png", shadow:0x000033},
						{url:"http://asset.sipo.jp/wonderfl/tail/tail3.png", shadow:0x000000},
						{url:"http://asset.sipo.jp/wonderfl/tail/tail4.png", shadow:0x000000},
						];
	
	public function init(count:int):void {	// ここから開始
		addEventListener(Event.ENTER_FRAME, frame);
		
		count %= _IMAGE_LIST.length;
		
		Security.loadPolicyFile("http://asset.sipo.jp/wonderfl/crossdomain.xml");
		_loadUrl = _IMAGE_LIST[count]["url"];
		_bevelColor = _IMAGE_LIST[count]["shadow"];
		
		var urlLoader:URLLoader = new URLLoader();
		urlLoader.addEventListener(Event.COMPLETE, urlLoadEnd);
		urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
		trace("loadStart");
		urlLoader.load(new URLRequest(_loadUrl));
	}
	// ByteArray(URLLoader(event.target).data)
	private function urlLoadEnd(event:Event):void{
		var loader:Loader = new Loader();
		loader.contentLoaderInfo.addEventListener(Event.COMPLETE, bynaryLoadEnd);
		loader.loadBytes(URLLoader(event.target).data);
	}
	private function bynaryLoadEnd(event:Event):void{
		var displayObject:DisplayObject = LoaderInfo(event.target).content;
		_sorceBitmapData = Bitmap(displayObject).bitmapData;
		trace("loadEnd");
		var topColor:int = 0xffffff;
		if (!_sorceBitmapData.transparent){	// 透過でない場合
			//var topColor:int = getSideTopColor(_sorceBitmapData);
			var w:int = _sorceBitmapData.width;
			var h:int = _sorceBitmapData.height;
			var transBitmapData:BitmapData = new BitmapData(w, h, true, 0x00000000);
			transBitmapData.threshold(_sorceBitmapData, new Rectangle(0, 0, w, h), new Point(),
										"==", topColor, 0x00000000, 0xFFFFFF, true);
			_sorceBitmapData = transBitmapData;
		}
		addChild(createBg(topColor));
		createPlaneShadow();
		createPuyoIllust();
	}
	private function createBg(color:uint):Bitmap{
		var bg:Bitmap = new Bitmap();
		bg.bitmapData = new BitmapData(STAGE_W, STAGE_H, false, color);
		var coverGradient:Sprite = new Sprite();
		var matrix:Matrix = new Matrix()
		matrix.createGradientBox(STAGE_W, STAGE_H, Math.PI / 2, 0, 0)
		coverGradient.graphics.beginGradientFill(GradientType.LINEAR, [0x000000, 0xffffff], [0.1, 0.1], [0, 230], matrix);
		coverGradient.graphics.drawRect(0, 0, STAGE_W, STAGE_H);
		bg.bitmapData.draw(coverGradient);
		return bg;
	}
	// 影を作る
	private function createPlaneShadow():void{
		_planeShadow = new PlaneShadow(STAGE_W, GROUND_H, 0.4, -0.2, 0.2, 24, 1);
		_planeShadow.y = 210;
		addChild(_planeShadow);
	}
	
	// プヨイラストを作る
	private function createPuyoIllust():void{
		_puyoIllust = new PuyoIllust();
		//_puyoIllust.setDebugDisplay(true);
		_puyoIllust.setPhisical(
					3,	//	derivation:int = 2
					0.5, 0.1,	//	verticalRate:Number = 0.3, rotateRate:Number = 0.2, 
					0.2, 0.03,	//	gravity:Number = 0.25, mousePower:Number = 0.1,
					0.90, 0.95,	//	friction:Number = 0.95, rFriction:Number = 0.92, 
					20, Math.PI/2	//	maxV:Number = 30, maxVR:Number = Math.PI):
					);
		addChild(_puyoIllust);
		_puyoIllust.first(_sorceBitmapData, STAGE_W, GROUND_H, 300, 12);
		_puyoIllust.filters = [new BevelFilter(5, 100, 0x000000, 0, _bevelColor, 1, 30, 30, 2, BitmapFilterQuality.MEDIUM)]
	}
	private function frame(event:Event):void{
		if (_puyoIllust != null) _puyoIllust.frame();
		if (_planeShadow != null) _planeShadow.frame(_puyoIllust.getDisplayBitmapData());
	}
	
	public function end():void{
		removeEventListener(Event.ENTER_FRAME, frame);
		_puyoIllust.end();
	}
}

class PuyoIllust extends Sprite
{
	private var _debugDisplay:Boolean;
	
	private var _sorceBitmap:BitmapData;
	private var _baseBitmap:BitmapData;
	private var _clear:BitmapData;
	private var _dragSprite:Vector.<Sprite> = new Vector.<Sprite>();
	
	private var _display:BitmapData;
	private var _displaySprite:Sprite;
	
	private var _point:Point = new Point();
	private var _rect:Rectangle;
	
	private var _baseSize:int;
	private var _stageWidth:int;
	private var _stageHeight:int;
	private var _blockSize:int;
	private var _blockNum:int;
	private var _dotNum:int;
	
	// 各種物理設定
	private var _derivation:int;	// 計算分割数
	private var _verticalRate:Number;	// 垂直方向ばね定数
	private var _rotateRate:Number;	// 回転方向ばね定数
	private var _gravity:Number;
	private var _mousePower:Number;
	private var _friction:Number;
	private var _rFriction:Number;
	private var _maxV:Number;
	private var _maxVR:Number;
	
	// 角度定数
	private static const _PI:Number = Math.PI;
	private static const _PI2:Number = 2 * _PI;
	private static const _R_90:Number	= _PI * 0.5;
	private static const _R_180:Number	= _PI * 1.0;
	private static const _R_270:Number	= _PI * -0.5;
	
	// ドットの個別データ。高速化のため、クラスにしない
	private var _dotX:Vector.<Number> = new Vector.<Number>();
	private var _dotY:Vector.<Number> = new Vector.<Number>();
	private var _dotR:Vector.<Number> = new Vector.<Number>();
	private var _dotVX:Vector.<Number> = new Vector.<Number>();
	private var _dotVY:Vector.<Number> = new Vector.<Number>();
	private var _dotVR:Vector.<Number> = new Vector.<Number>();
	private var _dotIs:Vector.<Boolean> = new Vector.<Boolean>();
	private var _dotLock:Vector.<Boolean> = new Vector.<Boolean>();
	private var _connectX:Vector.<Boolean> = new Vector.<Boolean>();
	private var _connectY:Vector.<Boolean> = new Vector.<Boolean>();
	private var _connectXX:Vector.<Boolean> = new Vector.<Boolean>();
	private var _connectYY:Vector.<Boolean> = new Vector.<Boolean>();
	
	// フリフリコンテンツ用
	private var _FURI_RATE:int = 50;
	private var _FURI_X:int = 10;
	private var _furiCount:int = 0;
	private var _furiIs:Boolean = true;
	private var _FURI_WAIT_MAX:int = 200;
	private var _furiWait:int = _FURI_WAIT_MAX;
	
	// ブロックのデータ
	private var _blockIs:Vector.<Boolean> = new Vector.<Boolean>();
	
	// 描画のデータ
	private var _vertices:Vector.<Number> = new Vector.<Number>();
	private var _indices:Vector.<int> = new Vector.<int>();
	private var _uvtData:Vector.<Number> = new Vector.<Number>();
	
	// 特定ポイント
	private var _dragTarget:int = -1;
	
	public function PuyoIllust():void{
		setDebugDisplay();
		setPhisical();
	}
	public function setDebugDisplay(debugDisplay:Boolean = false):void{
		_debugDisplay = debugDisplay;
	}
	public function setPhisical(derivation:int = 2,
								verticalRate:Number = 0.3, rotateRate:Number = 0.2, 
								gravity:Number = 0.25, mousePower:Number = 0.1,
								friction:Number = 0.95, rFriction:Number = 0.92, 
								maxV:Number = 30, maxVR:Number = Math.PI):void{
		_derivation = derivation;
		_verticalRate = verticalRate / derivation;
		_rotateRate = rotateRate / derivation;
		_gravity = gravity / derivation;
		_mousePower = mousePower / derivation;
		_friction = 1 - (1 - friction) / derivation;
		_rFriction = 1 - (1 - rFriction) / derivation;
		_maxV = maxV / derivation;
		_maxVR = maxVR / derivation;
	}
	public function first(baseBitmap:BitmapData,
						 stageWidth:int, stageHeight:int,
						 size:int, blockNum:int):void{
		
		var xi:int, yi:int;
		
		_baseSize = Math.max(baseBitmap.width, baseBitmap.height);
		_sorceBitmap = baseBitmap;
		_stageWidth = stageWidth;
		_stageHeight = stageHeight;
		_blockSize = int(size / blockNum);
		_blockNum = blockNum;
		_dotNum = _blockNum+1;
		_rect = new Rectangle(0, 0, _stageWidth, _stageHeight);
		
		// 正方形になおす
		var sorceWidth:int = _sorceBitmap.width;
		var sorceHeight:int = _sorceBitmap.height;
		_baseBitmap = new BitmapData(_baseSize, _baseSize, true, 0x00000000);
		_baseBitmap.copyPixels(_sorceBitmap, new Rectangle(0, 0, sorceWidth, sorceHeight), 
											new Point((_baseSize - sorceWidth)/2, (_baseSize - sorceHeight)/2));
		
		// bitmapの用意
		_clear = new BitmapData(_stageWidth, _stageHeight, true, 0x00000000)
		_display = new BitmapData(_stageWidth, _stageHeight, true, 0x00000000);
		var bitmap:Bitmap = new Bitmap(_display);
		addChild(bitmap);
		_displaySprite = new Sprite();
		
		
		
		// 初期位置（後で設定できるようにする？）
		var baseX:int = (_stageWidth - _blockSize*_blockNum) / 2;
		var baseY:int = 0;
		var index:int = 0;
		for (xi = 0; xi < _dotNum; xi++){
			for (yi = 0; yi < _dotNum; yi++){
				_dotX[index] = xi * _blockSize + baseX;
				_dotY[index] = yi * _blockSize + baseY;
				_dotR[index] = 0;
				_dotVX[index] = 0;
				_dotVY[index] = 0;
				_dotVR[index] = 0;
				_dotIs[index] = false;
				_dotLock[index] = false;
				_connectX[index] = false;
				_connectY[index] = false;
				_connectXX[index] = false;
				_connectYY[index] = false;
				_blockIs[index] = false;
				index++;
			}
		}
		
		// ブロックの状態を取得
		var baseBlockSize:Number = _baseSize / blockNum;
		var blockRectangle:Rectangle = new Rectangle(0, 0, baseBlockSize, baseBlockSize);
		var square:int = baseBlockSize*baseBlockSize;	// 面積
		for (xi = 0; xi < _blockNum; xi++){
			for (yi = 0; yi < _blockNum; yi++){
				blockRectangle.x = xi * baseBlockSize;
				blockRectangle.y = yi * baseBlockSize;
				var alphaHistogram:Vector.<Number> = _baseBitmap.histogram(blockRectangle)[3];
				if (alphaHistogram[0] != square){
					_dotIs[(xi + 0)*_dotNum + (yi + 0)] = true;
					_dotIs[(xi + 1)*_dotNum + (yi + 0)] = true;
					_dotIs[(xi + 0)*_dotNum + (yi + 1)] = true;
					_dotIs[(xi + 1)*_dotNum + (yi + 1)] = true;
					_blockIs[(xi + 0)*_dotNum + (yi + 0)] = true;
				}
			}
		}
		
		// ブロックの接続を設定
		index = 0;
		for (xi = 0; xi < _dotNum; xi++){
			for (yi = 0; yi < _dotNum; yi++){
				_connectX[index] = (xi < _dotNum - 1) && _dotIs[(xi + 1)*_dotNum + (yi + 0)];
				_connectY[index] = (yi < _dotNum - 1) && _dotIs[(xi + 0)*_dotNum + (yi + 1)];
				_connectXX[index] = (xi < _dotNum - 2) && _connectX[index] && _dotIs[(xi + 2)*_dotNum + (yi + 0)];
				_connectYY[index] = (yi < _dotNum - 2) && _connectY[index] && _dotIs[(xi + 0)*_dotNum + (yi + 2)];
				index++;
			}
		}
		// ドットのうち、ロックする物を選ぶ（ここをコメントアウトで、下に落ちる）
		for (xi = 0; xi < _dotNum; xi++){
			for (yi = 0; yi < 1; yi++){
				_dotLock[xi*_dotNum + yi] = true;
			}
		}
		// 描画ベクターを作る
		createTraiangleVector();
		// ドラッグ用のスプライトを用意する
		createDragSprite();
		
		draw();
	}
	// 描画用データを用意する
	private function createTraiangleVector():void{
		var index:int = 0;
		var xi:int, yi:int;
		for (xi = 0; xi < _blockNum; xi++){
			for (yi = 0; yi < _blockNum; yi++){
				if (_blockIs[xi*_dotNum + yi]){
					_indices.push(xi*_dotNum + yi,		(xi+1)*_dotNum + yi,		xi*_dotNum + (yi+1));
					_indices.push((xi+1)*_dotNum + yi,	(xi+1)*_dotNum + (yi+1),	xi*_dotNum + (yi+1));
				}
			}
		}
		for (xi = 0; xi < _dotNum; xi++){
			for (yi = 0; yi < _dotNum; yi++){
					_uvtData[index++] = xi / _blockNum;
					_uvtData[index++] = yi / _blockNum;
			}
		}
	}
	// ドラッグするためのSpriteを用意する
	private function createDragSprite():void{
		for (var xi:int = 0; xi < _dotNum; xi++){
			for (var yi:int = 0; yi < _dotNum; yi++){
				if (_dotIs[xi*_dotNum + yi]){
					var sprite:Sprite = createCircleSprite(_blockSize, _debugDisplay ? 0.1 : 0);	// ドラッグ用の円形Sprite
					sprite.buttonMode = true;
					sprite.useHandCursor = true;
					sprite.addEventListener(MouseEvent.MOUSE_DOWN, dotMouseDown(xi*_dotNum + yi));
					//sprite.alpha = (xi*_dotNum + yi == 30) ? 1 : 0;
					_dragSprite.push(sprite);
					addChild(sprite);
				}else{
					_dragSprite.push(null);
				}
			}
		}
	}
	private function createCircleSprite(size:Number, alpha:Number):Sprite{
		var sprite:Sprite = new Sprite();
		var g:Graphics = sprite.graphics;
		g.beginFill(0x999900, alpha);
		g.drawCircle(0, 0, size);
		g.endFill();
		g.lineStyle(0, 0xff0000, alpha);
		g.moveTo(0, 0);
		g.lineTo(size*1.3, 0);
		return sprite;
	}
	private function dotMouseDown(index:int):Function{
		return function (event:Event):void{
			_dragTarget = index;
			stage.addEventListener(MouseEvent.MOUSE_UP, dotMouseUp);
			_furiIs = false;
		};
	}
	private function dotMouseUp(event:Event):void{
		_furiIs = true;
		_furiWait = _FURI_WAIT_MAX;
		
		_dragTarget = -1;
		stage.removeEventListener(MouseEvent.MOUSE_UP, dotMouseUp);
	}
	
	public function frame():void{
		for (var i:int = 0; i < _derivation; i++){
			rotate();	// 回転の計算
			foce();
			mouse();
			move();
		}
		draw();
	}
	// 回転させる
	private function rotate():void{
		var l:int = _dotNum;
		var index:int = 0, target:int;
		var dotVX:Number, dotVY:Number, dotVR:Number;
		var xi:int, yi:int;
		
		// 全体動作
		for (xi = 0; xi < _dotNum; xi++){
			for (yi = 0; yi < _dotNum; yi++){
				if (_dotIs[index]){
					if (_connectX[index]){	// 右パーティクルに対する処理
						target = (xi+1) * _dotNum + (yi);
						calcConnectRForce(index, target, 0);
						calcConnectRForce(target, index, _R_180);
					}
					if (_connectY[index]){	// 下パーティクルに対する処理
						target = (xi) * _dotNum + (yi+1);
						calcConnectRForce(index, target, _R_90);
						calcConnectRForce(target, index, _R_270);
					}
					if (_connectXX[index]){	// 右パーティクルに対する処理
						target = (xi+2) * _dotNum + (yi);
						calcConnectRForce(index, target, 0);
						calcConnectRForce(target, index, _R_180);
					}
					if (_connectYY[index]){	// 下パーティクルに対する処理
						target = (xi) * _dotNum + (yi+2);
						calcConnectRForce(index, target, _R_90);
						calcConnectRForce(target, index, _R_270);
					}
					// 摩擦
					_dotVR[index] *= _rFriction;
				}
				index++;
			}
		}
	}
	// 接続されたパーツの回転方向を計算する
	private function calcConnectRForce(main:int, target:int, connectAngle:Number):void{
		var angle:Number = Math.atan2(_dotY[target] - _dotY[main], _dotX[target] - _dotX[main]);
		_dotVR[main] += ajustRadian(angle - (connectAngle + _dotR[main])) * _rotateRate;
	}
	
	// 力をかける
	private function foce():void{
		var l:int = _dotNum;
		var index:int = 0, target:int;
		var dotVX:Number, dotVY:Number, dotVR:Number;
		var xi:int, yi:int;
		
		// 全体動作
		for (xi = 0; xi < _dotNum; xi++){
			for (yi = 0; yi < _dotNum; yi++){
				// バネ接続
				if (_dotIs[index]){
				
					if (_connectX[index]){	// 右パーティクルに対する処理
						target = (xi+1) * _dotNum + (yi);
						calcConnectFoce(index, target, 0, _blockSize);
						calcConnectFoce(target, index, _R_180, _blockSize);
					}
					if (_connectY[index]){	// 下パーティクルに対する処理
						target = (xi) * _dotNum + (yi+1);
						calcConnectFoce(index, target, _R_90, _blockSize);
						calcConnectFoce(target, index, _R_270, _blockSize);
					}
					if (_connectXX[index]){	// 右右パーティクルに対する処理
						target = (xi+2) * _dotNum + (yi);
						calcConnectFoce(index, target, 0, _blockSize*2);
						calcConnectFoce(target, index, _R_180, _blockSize*2);
					}
					if (_connectYY[index]){	// 下下パーティクルに対する処理
						target = (xi) * _dotNum + (yi+2);
						calcConnectFoce(index, target, _R_90, _blockSize*2);
						calcConnectFoce(target, index, _R_270, _blockSize*2);
					}
					dotVX = _dotVX[index];
					dotVY = _dotVY[index];
					dotVR = _dotVR[index];
					// 重力
					dotVY += _gravity;
					// 摩擦
					dotVX *= _friction;
					dotVY *= _friction;
					dotVR *= _rFriction;
					// 最大最小ロック
					dotVX =	(_maxV < dotVX) ? _maxV :
							(dotVX < -_maxV) ? -_maxV : dotVX;
					dotVY =	(_maxV < dotVY) ? _maxV :
							(dotVY < -_maxV) ? -_maxV : dotVY;
					dotVR = (_maxVR < dotVR) ? _maxVR :
							(dotVR < -_maxVR) ? -_maxVR : dotVR;
					_dotVX[index] = dotVX;
					_dotVY[index] = dotVY;
					_dotVR[index] = dotVR;
				}
				index++;
			}
		}
	}
	// 接続された２パーツの力を計算する
	private function calcConnectFoce(main:int, target:int, connectAngle:Number, distance:Number):void{
		var toAngle:Number = ajustRadian(connectAngle + _dotR[main]);	// あるべき角度
		var toX:Number = _dotX[main] + Math.cos(toAngle) * distance;
		var toY:Number = _dotY[main] + Math.sin(toAngle) * distance;
		var ax:Number = (_dotX[target] - toX) * _verticalRate;
		var ay:Number = (_dotY[target] - toY) * _verticalRate;
		_dotVX[main] += ax;
		_dotVY[main] += ay;
		_dotVX[target] -= ax;
		_dotVY[target] -= ay;
	}
	// radian角度を、-π～πの範囲に修正する
	private function ajustRadian(radian:Number):Number{
		return radian - _PI2 * Math.floor( 0.5 + radian / _PI2);
	}
	
	// マウス
	private function mouse():void{
		if (_dragTarget == -1) return;
		_dotVX[_dragTarget] = (mouseX - _dotX[_dragTarget])*_mousePower;
		_dotVY[_dragTarget] = (mouseY - _dotY[_dragTarget])*_mousePower;
	}
	// 移動
	private function move():void{
		if (_furiIs && _furiWait-- < 0){
			_furiCount = (_furiCount + 1) % _FURI_RATE;
		}
		var baseX:int = (_stageWidth - _blockSize*_blockNum) / 2 + _FURI_X * Math.sin(_PI2 * _furiCount / _FURI_RATE);
		
		var l:int = _dotNum;
		var index:int = 0;
		var dotX:Number, dotY:Number, dotR:Number;
		var xi:int, yi:int;
		for (xi = 0; xi < _dotNum; xi++){
			for (yi = 0; yi < _dotNum; yi++){
				if (_dotIs[index]){
					// 一時変数
					dotX = _dotX[index];
					dotY = _dotY[index];
					dotR = _dotR[index];
					// 加速の反映
					dotX += _dotVX[index];
					dotY += _dotVY[index];
					dotR += _dotVR[index];
					// 壁処理
					dotX =	(dotX < 0) ? 0 : 
							(_stageWidth < dotX) ? _stageWidth : 
							dotX;
					dotY = (_stageHeight < dotY) ? _stageHeight : dotY;
					
					_dragSprite[index].x = dotX;
					_dragSprite[index].y = dotY;
					
					if (_dotLock[index]){
						dotX = xi * _blockSize + baseX
						dotY = 0;
					}
					_dotX[index] = dotX;
					_dotY[index] = dotY;
					_dotR[index] = dotR;
				}
				index++;
			}
		}
		if (_debugDisplay) {
			index = 0;
			for (xi = 0; xi < _dotNum; xi++){
				for (yi = 0; yi < _dotNum; yi++){
					if (_dotIs[index]){
						_dragSprite[index].rotation = _dotR[index] * 180 / Math.PI;
						index++;
					}
				}
			}
		}
	}
	private function draw():void{
		_display.lock();
		var graphics:Graphics = _displaySprite.graphics;
		graphics.clear();
		var l:int = _dotNum;
		var index:int = 0;
		for (var xi:int = 0; xi < l; xi++){
			for (var yi:int = 0; yi < l; yi++){
				_vertices[index*2] = _dotX[index];
				_vertices[index*2+1] = _dotY[index];
				
				index++;
			}
		}
		graphics.beginBitmapFill(_baseBitmap);
		graphics.drawTriangles(_vertices, _indices, _uvtData);
		graphics.endFill();
		_display.copyPixels(_clear, _rect, _point);
		_display.draw(_displaySprite);
		_display.unlock();
	}
	
	public function getDisplayBitmapData():BitmapData{
		return _display;
	}
	
	public function end():void{
		stage.removeEventListener(MouseEvent.MOUSE_UP, dotMouseUp);
	}
}


class PlaneShadow extends Bitmap
{
	private var _width:int;
	private var _height:int;
	private var _minAlpha:Number;
	private var _maxAlpha:Number;
	private var _blur:BlurFilter;
	private var _clear:BitmapData;
	private var _black:BitmapData;
	private var _gradient:BitmapData;
	private var _alphaMap:BitmapData;
	private var _point:Point = new Point();
	private var _rect:Rectangle;
	
	public function PlaneShadow(width:int, height:int, heightRate:Number, minAlpha:Number, maxAlpha:Number, blur:int, quality:int){
		super();
		_width = width;
		_height = height;
		scaleY = heightRate;
		_minAlpha = minAlpha;
		_maxAlpha = maxAlpha;
		_blur = new BlurFilter(blur, blur, quality);
		_clear = new BitmapData(width, height, true, 0x00000000);
		bitmapData = _clear.clone();
		_alphaMap = new BitmapData(width, height, true, 0xffff0000);
		_black = new BitmapData(width, height, true, 0xff000000);
		_gradient = _clear.clone();
		createGradient();
		_rect = new Rectangle(0, 0, width, height);
		filters = [_blur];
	}
	private function createGradient():void{
		var coverGradient:Sprite = new Sprite();
		var matrix:Matrix = new Matrix()
		matrix.createGradientBox(_width, _height, Math.PI / 2, 0, 0)
		coverGradient.graphics.beginGradientFill(GradientType.LINEAR, [0x000000, 0x000000], [1-_minAlpha, 1-_maxAlpha], [0, 230], matrix);
		coverGradient.graphics.drawRect(0, 0, _width, _height);
		_gradient.draw(coverGradient);
	}
	public function frame(targetBitmapdata:BitmapData):void{
		bitmapData.lock();
		_alphaMap.copyChannel(targetBitmapdata, _rect, _point, BitmapDataChannel.ALPHA, BitmapDataChannel.RED);
		_alphaMap.copyPixels(_gradient, _rect, _point, null, null, true);
		bitmapData.copyChannel(_alphaMap, _rect, _point, BitmapDataChannel.RED, BitmapDataChannel.ALPHA);
		bitmapData.unlock();
	}
}








package 
{
	/*
	PuyoDot
	プヨっとしたドット。 
	下のほうにあるパレットから拾ってきて表示するよ。
	ぐりぐりしたり、引っ張ったり、新しいドット絵を追加して遊んでね。
	(マップが意外と見ずらくなった。wonderflって等倍フォントじゃないんだね
	等倍のテキストエディタか何かで編集すると楽かも)
	
	本当はドットを編集する機能も入れたかったんだけど
	力尽きるどころの話じゃなかったから今回は諦めた。
	でもいつか作りたいね。
	 */
	 
	 
	 
	 /*
	
	ドット状、任意外形の弾性体を表現します。
	こういう、ぐにぐにしたものは、各頂点をテンションで繋ぐfladdict式が一番軽くて綺麗なのですが、
	そうすると自由な形にはしにくいという欠点があります。
	今回の手法では、小さな点が、バネで繋がっているモデルをしており、一部が欠けてもそれらしい動作をします。
	バネは回転方向への力も持ち、隣の点を、距離だけではなく正常な角度に保とうとします。
	欠点として、点の数が多くなるため圧倒的に重いことと
	力の伝わり方が遅いため、伸びやすい物体になってしまうことです。
	前者はリファクタリングしていく必要があります。
	後者は、今回解決のために点を２個先まで接続する手法をとりました。
	
	
	キング・カズマのドットバージョンを入れたかったんだけど
	16x32ドットは重くなりすぎて断念。
	軽量化して、そのくらいは動くようになりたい。
	*/
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class PuyoDot3 extends Sprite
	{
		public static const STAGE_W:uint = 465;
		public static const STAGE_H:uint = 465;
		
		private static const _WALL_LEFT:Number = 0;
		private static const _WALL_RIGHT:Number = 465;
		private static const _GROUND_LINE:Number = 350;
		
		private static const _DOT_CONNECT_MAX:int = 4;
		private static const _DERIVATION:int = 3;	// 計算の分割数。
		private static const _MAP_SIZE:Number = 200;
		
		private static const _PI:Number = Math.PI;
		private static const _PI2:Number = 2.0 * _PI;
		private static const _RADIAN90:Number	= _PI * 0.5;
		private static const _RADIAN180:Number	= _PI * 1.0;
		private static const _RADIAN270:Number	= _PI * -0.5;
		private static const _TO_DEGREE:Number	= 180 / _PI;
		
		private static const _GRAVITY:Number = 0.2 / _DERIVATION;
		private static const _ROTATION_RATE:Number = 0.05 / _DERIVATION;	// 自身バネ（根元）
		private static const _VERTICAL_RATE:Number = 0.2 / _DERIVATION;	// ターゲットバネ（さきっぽ）
		private static const _MOUSE_PULL_RATE:Number = 2.0 / _DERIVATION;
		
		private static const _FRICTION:Number = 0.1 / _DERIVATION;
		private static const _ROTATE_FRICTION:Number = 1 - 0.2 / _DERIVATION;
		private static const _MOUSE_ROTATE_FRICTION:Number = 1 - 0.8 / _DERIVATION;
		private static const _MOUSE_MOVE_FRICTION:Number = 1 - 0.5 / _DERIVATION;
		private static const _GROUND_FRICTION:Number = 1 - 0.2 / _DERIVATION;
		
		// パーティクル
		private var _dotMap:DotMap;
		private var _particleList:Array = [];	//:Array :Particle
		private var _particleDistance:int;
		private var _w:int;
		private var _h:int;
		
		// ドラッグ
		private var _dragIdX:int = -1;
		private var _dragIdY:int = -1;
		
		// レイヤー
		private var _bgLayer:Bitmap;
		private var _displayLayer:Bitmap;
		private var _debugLayer:Sprite;
		private var _debugDisplayList:Array = [];
		private var _dragLayer:Sprite;
		private var _dragList:Array = [];
		
		// ビットマップ
		private var _clearBitmap:BitmapData = new BitmapData(STAGE_W, STAGE_H, true, 0x00000000);
		private var _displayBitmap:BitmapData = new BitmapData(STAGE_W, STAGE_H);
		private var _bgBitmap:BitmapData = new BitmapData(STAGE_W, STAGE_H);
		private var _gradiationBitmap:BitmapData = new BitmapData(STAGE_W, STAGE_H);
		private var _reflectAlphaBitmap:BitmapData = new BitmapData(STAGE_W, STAGE_H, true, 0x00000000);
		
		private var _rect:Rectangle = new Rectangle(0, 0, STAGE_W, STAGE_H);
		private var _point:Point = new Point();
		private var _refrectPoint:Point = new Point(0, -2*_GROUND_LINE + STAGE_H);
		
		public function PuyoDot3()
		{
			addEventListener(Event.ADDED_TO_STAGE, init);	// flexBuilderとの互換性。
		}
		private function init(e:Event):void {	// ここから開始
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// SWF設定
			stage.frameRate = 30;
			stage.quality = StageQuality.LOW;
			var bg:Sprite = new Sprite();	// wonderflではキャプチャに背景色が反映されないので、背景色Spriteで覆う。
			bg.graphics.beginFill(0xffffff);
			bg.graphics.drawRect(0, 0, STAGE_W, STAGE_H);
			addChild(bg);
			
			var dotMapList:Array = [
									new MapMarioStand(),
									new MapMarioJump(),
									new MapSlime(),
									new MapPackmanMonster(),
									new MapSpelunker(),
									new Map1Up(),
									new MapSakuma(),
									]	// ここを一つだけにすれば、任意のドット絵が表示できる
			_dotMap = dotMapList[Math.floor(Math.random()*dotMapList.length)];	// ここで、パレットマップを決める
			
			
			addChild(_bgLayer = new Bitmap(_bgBitmap));
			addChild(_displayLayer = new Bitmap(_displayBitmap));
			addChild(_debugLayer = new Sprite());
			addChild(_dragLayer = new Sprite());
			_debugLayer.visible = false;
			_bgLayer.scaleY = -1;
			_bgLayer.y = STAGE_H;
			
			
			
			_w = _dotMap.w+1;
			_h = _dotMap.h+1;
			_particleDistance = _MAP_SIZE / _w;
			var tmpBaceX:Number = (STAGE_W - _MAP_SIZE) / 2;
			var tmpBaceY:Number = 20;
			var x:int, y:int;
			var particle:Particle;
			// 生成
			for (x = 0; x < _w; x++){
				_particleList[x] = [];
				_dragList[x] = [];
				for (y = 0; y < _h; y++){
					
					particle = new Particle();
					var tmpNearDotList:Array = [_dotMap.isDot(x, y), _dotMap.isDot(x-1, y), 
												_dotMap.isDot(x-1, y-1), _dotMap.isDot(x, y-1)];
					particle.connect[0] = (tmpNearDotList[0] || tmpNearDotList[3]) && x < _w-1;	// 右
					particle.connect[1] = (tmpNearDotList[1] || tmpNearDotList[0]) && y < _h-1;	// 下
					particle.connect[2] = (tmpNearDotList[2] || tmpNearDotList[1]) && 0 < x;	// 左
					particle.connect[3] = (tmpNearDotList[3] || tmpNearDotList[2]) && 0 < y;	// 上
					
					
					if (!particle.connect[0] && !particle.connect[1] && !particle.connect[2] && !particle.connect[3]){
						_particleList[x][y] = null;
						continue;
					}
					particle.color = _dotMap.getColor(x, y);
					particle.x = tmpBaceX + _particleDistance * x + Math.random()*3;
					particle.y = tmpBaceY + _particleDistance * y;
					_particleList[x][y] = particle;
					createDragSprite(x, y);
					
				}
			}
			for (x = 0; x < _w; x++){
				for (y = 0; y < _h; y++){
					particle = _particleList[x][y];
					if (particle == null) continue;
					particle.connect[4] = particle.connect[0] && Particle(_particleList[x+1][y]).connect[0];	// 右右
					particle.connect[5] = particle.connect[1] && Particle(_particleList[x][y+1]).connect[1];	// 下下
					particle.connect[6] = particle.connect[2] && Particle(_particleList[x-1][y]).connect[2];	// 左左
					particle.connect[7] = particle.connect[3] && Particle(_particleList[x][y-1]).connect[3];	// 上上
				}
			}
			
			// デバッグ表示
			debugInit();
			
			displayInit();
			
			// フレームの処理を登録
			addEventListener(Event.ENTER_FRAME, frame);
			// マウスドラッグ
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpEvent());
			
			//addChild(new Stats());
		}
		private function createDragSprite(x:int, y:int):void{	// ドラッグ判定を作る
			var sprite:Sprite = new Sprite();
			_dragLayer.addChild(sprite);
			_dragList[x][y] = sprite;
			var g:Graphics = sprite.graphics;
			g.beginFill(0x000000, 0);
			g.drawCircle(0, 0, _particleDistance*0.8);
			// マウスイベント
			sprite.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownEvent(x, y));
		}
		
		
		// フレーム挙動
		private function frame(event:Event):void{
			for (var i:int=0; i<_DERIVATION; i++){
				rotate();	// 回転の計算
				force();	// 力の計算
				move();	// 移動処理
			}
			draw();	// 描画処理
			debugDraw();
		}
		
		
		
		// ボーンの向きを決定する
		private function rotate():void{
			var x:int, y:int;
			for (x = 0; x < _w; x++){
				for (y = 0; y < _h; y++){
					var particle:Particle = _particleList[x][y];
					if (particle == null) continue;
					var subParticle:Particle;
					if (particle.connect[0]){	// 右パーティクルに対する処理
						subParticle = _particleList[x+1][y];
						calcConnectRForce(particle, subParticle, 0);
						calcConnectRForce(subParticle, particle, _RADIAN180);
					}
					if (particle.connect[1]){	// 下パーティクルに対する処理
						subParticle = _particleList[x][y+1];
						calcConnectRForce(particle, subParticle, _RADIAN90);
						calcConnectRForce(subParticle, particle, _RADIAN270);
					}
					if (particle.connect[4]){	// 右右パーティクルに対する処理
						subParticle = _particleList[x+2][y];
						calcConnectRForce(particle, subParticle, 0);
						calcConnectRForce(subParticle, particle, _RADIAN180);
					}
					if (particle.connect[5]){	// 下下パーティクルに対する処理
						subParticle = _particleList[x][y+2];
						calcConnectRForce(particle, subParticle, _RADIAN90);
						calcConnectRForce(subParticle, particle, _RADIAN270);
					}
					if (x == _dragIdX && y == _dragIdY) particle.vr *= _MOUSE_ROTATE_FRICTION;
					else particle.vr *= _ROTATE_FRICTION;	// 摩擦
					
					particle.radian += particle.vr;
				}
			}
		}
		// 接続されたパーツの回転方向を計算する
		private function calcConnectRForce(particle:Particle, targetParticle:Particle, connectAngle:Number):void{
			var angle:Number = Math.atan2(targetParticle.y - particle.y, targetParticle.x - particle.x);
			particle.vr += ajustRadian(angle - (connectAngle + particle.radian)) * _ROTATION_RATE;
		}
		
		
		
		private function force():void{
			var x:int, y:int;
			for (x = 0; x < _w; x++){
				for (y = 0; y < _h; y++){
					var particle:Particle = _particleList[x][y];
					if (particle == null) continue;
					var subParticle:Particle;
					if (particle.connect[0]){	// 右パーティクルに対する処理
						subParticle = _particleList[x+1][y];
						calcConnectFoce(particle, subParticle, 0, _particleDistance);
						calcConnectFoce(subParticle, particle, _RADIAN180, _particleDistance);
					}
					if (particle.connect[1]){	// 下パーティクルに対する処理
						subParticle = _particleList[x][y+1];
						calcConnectFoce(particle, subParticle, _RADIAN90, _particleDistance);
						calcConnectFoce(subParticle, particle, _RADIAN270, _particleDistance);
					}
					if (particle.connect[4]){	// 右右パーティクルに対する処理
						subParticle = _particleList[x+2][y];
						calcConnectFoce(particle, subParticle, 0, _particleDistance*2);
						calcConnectFoce(subParticle, particle, _RADIAN180, _particleDistance*2);
					}
					if (particle.connect[5]){	// 下下パーティクルに対する処理
						subParticle = _particleList[x][y+2];
						calcConnectFoce(particle, subParticle, _RADIAN90, _particleDistance*2);
						calcConnectFoce(subParticle, particle, _RADIAN270, _particleDistance*2);
					}
					particle.ay += _GRAVITY;
					if (_dragIdX == x && _dragIdY == y){	// マウスで引っ張る
						var point:Point = pullForce(particle.x, particle.y, mouseX, mouseY, _MOUSE_PULL_RATE);
						particle.ax += point.x;
						particle.ay += point.y;
						particle.vx *= _MOUSE_MOVE_FRICTION;
						particle.vy *= _MOUSE_MOVE_FRICTION;
					}
				}
			}
		}
		// 接続された２パーツの力を計算する
		private function calcConnectFoce(particle:Particle, targetParticle:Particle, connectAngle:Number, distance:Number):void{
			var toAngle:Number = ajustRadian(connectAngle + particle.radian);
			var toX:Number = particle.x + Math.cos(toAngle) * distance;
			var toY:Number = particle.y + Math.sin(toAngle) * distance;
			var ax:Number = (targetParticle.x - toX) * _VERTICAL_RATE;
			var ay:Number = (targetParticle.y - toY) * _VERTICAL_RATE;
			particle.ax += ax;
			particle.ay += ay;
			targetParticle.ax -= ax;
			targetParticle.ay -= ay;
		}
		// ポイントx1 y1を、ポイントx2 y2へ、係数rateだけ移動させる場合の、XYの力を返す
		private function pullForce(x1:Number, y1:Number, x2:Number, y2:Number, rate:Number):Point{
			var point:Point = new Point();
			var distance:Number = calcDistance(x1, y1, x2, y2);
			
			var angle:Number = Math.atan2(y2 - y1, x2 - x1);
			point.x = Math.cos(angle) * distance * rate;
			point.y = Math.sin(angle) * distance * rate;
			return point;
		}
		// ポイントx1 y1から、ポイントx2 y2までの距離
		private function calcDistance(x1:Number, y1:Number, x2:Number, y2:Number):Number{
			return Math.sqrt(Math.pow(x2-x1, 2) + Math.pow(y2-y1, 2));
		}
		// radian角度を、-π～πの範囲に修正する
		private function ajustRadian(radian:Number):Number{
			return radian - _PI2 * Math.floor( 0.5 + radian / _PI2);
		}
		
		private function move():void{
			var x:int, y:int;
			for (x = 0; x < _w; x++){
				for (y = 0; y < _h; y++){
					var particle:Particle = _particleList[x][y];
					if (particle == null) continue;
					
					// 空気抵抗 TODO:速度に対しての処理で良いはず。
					particle.ax += -_FRICTION * particle.vx;
					particle.ay += -_FRICTION * particle.vy;
					
					// 速度、位置への反映
					particle.vx += particle.ax;
					particle.vy += particle.ay;
					particle.x += particle.vx;
					particle.y += particle.vy;
					particle.ax = 0;
					particle.ay = 0;	// 力をクリア
					
					// 壁チェック
					if (0 < particle.vy && _GROUND_LINE < particle.y){
						particle.y = _GROUND_LINE;
						particle.vy *= -0.8;
						if (particle.vy < -50) particle.vy = -50;
						particle.vx *= _GROUND_FRICTION;
					}
					if (particle.vx < 0 && particle.x < _WALL_LEFT){
						particle.x = _WALL_LEFT;
						particle.vx = 0;
						particle.vy *= _GROUND_FRICTION;
					}else if (0 < particle.vx && _WALL_RIGHT < particle.x){
						particle.x = _WALL_RIGHT;
						particle.vx = 0;
						particle.vy *= _GROUND_FRICTION;
					}
					
					// ドラッグエリアを移動
					var sprite:Sprite = _dragList[x][y];
					sprite.x = particle.x;
					sprite.y = particle.y;
				}
			}
		}
		
		private var _drawShape:Shape = new Shape();
		
		private function displayInit():void{
			var g:Graphics = _drawShape.graphics;
			g.clear();
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(STAGE_W, STAGE_H, Math.PI / 2, 0, 0);
			g.beginGradientFill(GradientType.LINEAR, [0xf8f8f8, 0xe8e8e8], [1, 1], [0, 255], matrix);
			g.drawRect(0, 0, STAGE_W, STAGE_H);
			_gradiationBitmap.draw(_drawShape);
			
			g.clear();
			g.beginGradientFill(GradientType.LINEAR, [0x000000, 0x000000], [0, 0.3], [125, 230], matrix);
			g.drawRect(0, 0, STAGE_W, STAGE_H);
			_reflectAlphaBitmap.draw(_drawShape);
		}
		private function draw():void{
			var g:Graphics = _drawShape.graphics;
			var particle:Particle;
			g.clear();
			var x:int, y:int;
			for (y = 0; y < _h-1; y++){
				for (x = 0; x < _w-1; x++){
					if(!_dotMap.isDot(x, y)) continue;	// ドットが無いなら描画省略
					g.beginFill(_dotMap.getColor(x, y));
					particle = _particleList[x][y];
					g.moveTo(particle.x, particle.y);
					particle = _particleList[x+1][y];
					g.lineTo(particle.x, particle.y);
					particle = _particleList[x+1][y+1];
					g.lineTo(particle.x, particle.y);
					particle = _particleList[x][y+1];
					g.lineTo(particle.x, particle.y);
					g.endFill();
				}
			}
			
			_displayBitmap.copyPixels(_clearBitmap, _rect, _point);
			_displayBitmap.draw(_drawShape);
			
			
			_bgBitmap.copyPixels(_gradiationBitmap, _rect, _point);
			_bgBitmap.copyPixels(_displayBitmap, _rect, _refrectPoint, _reflectAlphaBitmap, _point, true);
		}
		
		
		// マウスイベント
		private function mouseDownEvent(x:int, y:int):Function{
			return function (event:Event):void{	startBornDrag(x, y);};
		}
		private function mouseUpEvent():Function{
			return function (event:Event):void{	endBornDrag();};
		}
		
		// ドラッグ
		private function startBornDrag(x:int, y:int):void{
			_dragIdX = x;
			_dragIdY = y;
		}
		private function endBornDrag():void{
			_dragIdX = -1;
			_dragIdY = -1;
		}
		
		private function debugInit():void{
			var x:int, y:int;
			for (x = 0; x < _w; x++){
				_debugDisplayList[x] = [];
				for (y = 0; y < _h; y++){
					var sprite:Sprite = new Sprite();
					var g:Graphics = sprite.graphics;
					var radius:Number = 5;
					g.lineStyle(0, 0xff0000, 1);
					g.beginFill(0xff0000, 0.3);
					g.drawCircle(0, 0, radius);
					g.endFill();
					g.moveTo(0, 0);
					g.lineTo(radius*2, 0);
					_debugDisplayList[x][y] = sprite;
					_debugLayer.addChild(sprite);
				}
			}
		}
		
		private function debugDraw():void{
			var x:int, y:int;
			for (x = 0; x < _w; x++){
				for (y = 0; y < _h; y++){
					var particle:Particle = _particleList[x][y];
					if (particle == null) continue;
					var sprite:Sprite = _debugDisplayList[x][y];
					sprite.x = particle.x;
					sprite.y = particle.y;
					sprite.rotation = particle.radian * _TO_DEGREE;
				}
			}
		}
	}
}

class Particle
{
	public var x:Number = 0;	// 位置
	public var y:Number = 0;
	public var vx:Number = 0;	// 速度
	public var vy:Number = 0;
	public var ax:Number = 0;	// 加速度=力	TOTO:最後まで意味無かったら消す
	public var ay:Number = 0;
	
	public var radian:Number = 0;	// 向き
	public var vr:Number = 0;	// 向き速度
	
	public var color:uint = 0x000000;	// パーティクルの色。右下の枠の色
	public var connect:Array = [true, true, true, true];	// パーティクルの接続状態を毎回チェックしなくていいように、保持しておく
}
class DotMap	// ドットのカラー情報元
{
	public var w:uint = 16;
	public var h:uint = 16;
	
	public var pallet:Array = [];	// カラーパレット。ゼロ番は透過色予定:uint
	public var strPallet:Array = [];	// :String
	public var strMap:String = "";
	public var map:Array = [];	// ピクセルマップ:int
	
	function DotMap(){
		init();
		readMap();
	}
	protected function init():void{
		w = 16;	// 16くらいが妥当。あんまり多すぎると自重で潰れるし、重い
		h = 16;
		pallet = [0x000000, 0xDC2900, 0xFFA53B, 0x8B7300];	// 一応何色でも可能
		strPallet = ["＿", "○", "□", "■"];
		
		strMap =
				"■■■■■■■■■■■■■■■■"+
				"■■■■■■■■■■■■■■■■"+
				"■■■■■■■■■■■■■■■■"+
				"■■■■■■■■■■■■■■■■"+
				"■■■■■■■■■■■■■■■■"+
				"■■■■■■■■■■■■■■■■"+
				"■■■■■■■■■■■■■■■■"+
				"■■■■■■■■■■■■■■■■"+
				"■■■■■■■■■■■■■■■■"+
				"■■■■■■■■■■■■■■■■"+
				"■■■■■■■■■■■■■■■■"+
				"■■■■■■■■■■■■■■■■"+
				"■■■■■■■■■■■■■■■■"+
				"■■■■■■■■■■■■■■■■"+
				"■■■■■■■■■■■■■■■■"+
				"■■■■■■■■■■■■■■■■";
				
	}
	private function readMap():void{
		for (var i:int; i<w*h; i++){
			map.push(strPallet.indexOf(strMap.substr(i, 1)));
		}
	}
	
	public function isDot(x:int, y:int):Boolean{
		if (x < 0 || y < 0 || w <= x || h <= y) return false;
		if (map[x + y*w] == 0) return false;
		return true;
	}
	public function getColor(x:int, y:int):uint{
		if (x < 0 || y < 0 || w <= x || h <= y) return 0;
		return pallet[map[x + y*w]];
	}
}
class TestMap extends DotMap
{
	override protected function init():void{
		w = 16;
		h = 16;
		pallet = [0x000000, 0xffffff, 0x000000];
		strPallet = ["＿", "○", "■"];
		strMap =
				"■○■○■○■○■○■○■○■○"+
				"○■○■○■○■○■○■○■○■"+
				"■○■○■○■○■○■○■○■○"+
				"○■○■○■○■○■○■○■○■"+
				"■○■○■○■○■○■○■○■○"+
				"○■○■○■○■○■○■○■○■"+
				"■○■○■○■○■○■○■○■○"+
				"○■○■○■○■○■○■○■○■"+
				"■○■○■○■○■○■○■○■○"+
				"○■○■○■○■○■○■○■○■"+
				"■○■○■○■○■○■○■○■○"+
				"○■○■○■○■○■○■○■○■"+
				"■○■○■○■○■○■○■○■○"+
				"○■○■○■○■○■○■○■○■"+
				"■○■○■○■○■○■○■○■○"+
				"○■○■○■○■○■○■○■○■"+
				"";
	}
}
class MapMarioStand extends DotMap
{
	override protected function init():void{
		w = 16;
		h = 16;
		pallet = [0x000000, 0xee2900, 0xFFA500, 0x875200];
		strPallet = ["＿", "○", "□", "■"];
		strMap =
				"＿＿＿＿＿＿○○○○○＿＿＿＿＿"+
				"＿＿＿＿＿○○○○○○○○○＿＿"+
				"＿＿＿＿＿■■■□□■□＿＿＿＿"+
				"＿＿＿＿■□■□□□■□□□＿＿"+
				"＿＿＿＿■□■■□□□■□□□＿"+
				"＿＿＿＿■■□□□□■■■■■＿"+
				"＿＿＿＿＿＿□□□□□□□＿＿＿"+
				"＿＿＿＿＿■■○■■■＿＿＿＿＿"+
				"＿＿＿＿■■■○■■○■■■＿＿"+
				"＿＿＿■■■■○■■○■■■■＿"+
				"＿＿＿□□■○□○○□○■□□＿"+
				"＿＿＿□□□○○○○○○□□□＿"+
				"＿＿＿□□○○○○○○○○□□＿"+
				"＿＿＿＿＿○○○＿＿○○○＿＿＿"+
				"＿＿＿＿■■■＿＿＿＿■■■＿＿"+
				"＿＿＿■■■■＿＿＿＿■■■■＿"+
				"";
	}
}
class MapMarioJump extends DotMap
{
	override protected function init():void{
		w = 16;
		h = 16;
		pallet = [0x000000, 0xee2900, 0xFFA500, 0x875200];
		strPallet = ["＿", "○", "□", "■"];
		strMap =
				"＿＿＿＿＿＿＿＿＿＿＿＿＿□□□"+
				"＿＿＿＿＿＿○○○○○＿＿□□□"+
				"＿＿＿＿＿○○○○○○○○○□□"+
				"＿＿＿＿＿■■■□□■□□■■■"+
				"＿＿＿＿■□■□□□■□□■■■"+
				"＿＿＿＿■□■■□□□■□□□■"+
				"＿＿＿＿■■□□□□■■■■■＿"+
				"＿＿＿＿＿＿□□□□□□□＿＿＿"+
				"＿＿■■■■■○■■■○■＿＿＿"+
				"＿■■■■■■■○■■■○＿＿■"+
				"□□■■■■■■○○○○○＿＿■"+
				"□□□＿○○■○○□○○□○■■"+
				"＿□＿■○○○○○○○○○○■■"+
				"＿＿■■■○○○○○○○○○■■"+
				"＿■■■○○○○○○○＿＿＿＿＿"+
				"＿■＿＿○○○○＿＿＿＿＿＿＿＿"+
				"";
	}
}
class MapSlime extends DotMap
{
	override protected function init():void{
		w = 16;
		h = 16;
		pallet = [0x000000, 0x3399FF, 0xffffff, 0xff3333];
		strPallet = ["＿", "○", "×", "■"];
		strMap =
				"＿＿＿＿＿＿＿＿○＿＿＿＿＿＿＿"+
				"＿＿＿＿＿＿＿＿○＿＿＿＿＿＿＿"+
				"＿＿＿＿＿＿＿＿○＿＿＿＿＿＿＿"+
				"＿＿＿＿＿＿＿＿○＿＿＿＿＿＿＿"+
				"＿＿＿＿＿＿＿○○○＿＿＿＿＿＿"+
				"＿＿＿＿＿＿○○○○○＿＿＿＿＿"+
				"＿＿＿＿○○○○○○○○○＿＿＿"+
				"＿＿＿××○○○○○○○○○＿＿"+
				"＿＿××○○○○○○○○○○○＿"+
				"＿○×○○○×○○○×○○○○○"+
				"＿○○○○×○×○×○×○○○○"+
				"＿○○○○×○×○×○×○○○○"+
				"＿○○○■○×○○○×○■○○○"+
				"＿○○○■■○○○○○■■○○○"+
				"＿＿○○○■■■■■■■○○○＿"+
				"＿＿＿＿○○○○○○○○○＿＿＿"+
				"";
	}
}
class MapPackmanMonster extends DotMap
{
	override protected function init():void{
		w = 16;
		h = 16;
		pallet = [0x000000, 0xffffff, 0xff0000, 0x0000ff];
		strPallet = ["＿", "×", "□", "■"];
		strMap =
				"＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿"+
				"＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿"+
				"＿＿＿＿＿＿□□□□＿＿＿＿＿＿"+
				"＿＿＿＿□□□□□□□□＿＿＿＿"+
				"＿＿＿□□□□□□□□□□＿＿＿"+
				"＿＿□××□□□□××□□□＿＿"+
				"＿＿××××□□××××□□＿＿"+
				"＿＿■■××□□■■××□□＿＿"+
				"＿□■■××□□■■××□□□＿"+
				"＿□□××□□□□××□□□□＿"+
				"＿□□□□□□□□□□□□□□＿"+
				"＿□□□□□□□□□□□□□□＿"+
				"＿□□□□□□□□□□□□□□＿"+
				"＿□□□□□□□□□□□□□□＿"+
				"＿□□□□＿□□□□＿□□□□＿"+
				"＿＿□□＿＿＿□□＿＿＿□□＿＿"+
				"";
	}
}
class MapSpelunker extends DotMap
{
	override protected function init():void{
		w = 16;
		h = 16;
		pallet = [0x000000, 0xFF8855, 0x0000ff, 0xff0000];
		strPallet = ["＿", "×", "□", "■"];
		strMap =
				"＿＿■■■■■＿＿＿＿＿＿＿＿＿"+
				"＿■■■■■■■＿＿＿＿＿＿■＿"+
				"■■■■■■■■■＿＿＿■＿＿＿"+
				"＿□□□□×□×＿＿＿＿＿＿＿＿"+
				"＿□□□×××××＿＿＿＿■＿■"+
				"＿＿□□□×××＿＿＿＿＿＿＿＿"+
				"＿＿■■■××＿□□□□□□■＿"+
				"＿■××□■■＿＿××□＿＿＿＿"+
				"＿××□■■■■■××□＿＿＿■"+
				"＿××□□■■■■＿□＿＿■＿＿"+
				"＿＿×□□□□□＿＿＿＿＿＿■＿"+
				"＿＿＿＿□□□□□＿＿＿＿＿＿＿"+
				"＿＿＿□□□＿□□□＿＿＿＿＿＿"+
				"＿＿■■□□□□□＿＿＿＿＿＿＿"+
				"＿＿■■■＿■■■＿＿＿＿＿＿＿"+
				"＿＿＿■■＿■■■■＿＿＿＿＿＿"+
				"";
	}
}
class Map1Up extends DotMap
{
	override protected function init():void{
		w = 16;
		h = 16;
		pallet = [0x000000, 0x00cc33, 0xffffff, 0x000000];
		strPallet = ["＿", "×", "□", "■"];
		strMap =
				"＿＿＿＿＿■■■■■■＿＿＿＿＿"+
				"＿＿＿■■□□××××■■＿＿＿"+
				"＿＿■□□□□××××□□■＿＿"+
				"＿■□□□□××××××□□■＿"+
				"＿■□□□××□□□□××□■＿"+
				"■×××××□□□□□□×××■"+
				"■×□□××□□□□□□×××■"+
				"■□□□□×□□□□□□××□■"+
				"■□□□□××□□□□××□□■"+
				"■×□□×××××××××□□■"+
				"■×××■■■■■■■■××□■"+
				"＿■■■□□■□□■□□■■■＿"+
				"＿＿■□□□■□□■□□□■＿＿"+
				"＿＿■□□□□□□□□□□■＿＿"+
				"＿＿＿■□□□□□□□□■＿＿＿"+
				"＿＿＿＿■■■■■■■■＿＿＿＿"+
				"";
	}
}
class MapSakuma extends DotMap
{
	override protected function init():void{
		w = 16;
		h = 16;
		pallet =	[0x000000,	0xD8A36F,	0xffffff,	0xB47856,	0xBE1920,	0x689A39,	0xF3ED71,	0x2F6392,	0x542D28];
		strPallet =	["＿",		"□",		"○",		"茶",		"赤",		"緑",		"黄",		"青",		"■"];
		strMap =
				"＿＿＿茶茶茶茶茶茶茶茶茶茶＿＿＿"+
				"＿＿茶茶茶□□□□□□茶茶茶＿＿"+
				"＿＿茶茶□□□□□□□□茶茶＿＿"+
				"□□茶□□□□□□□□□□茶□□"+
				"□□赤赤赤赤赤□□赤赤赤赤赤□□"+
				"□茶赤○○○赤□□赤○○○赤茶□"+
				"□茶赤○■○赤赤赤赤○■○赤茶□"+
				"□□赤○○○赤□□赤○○○赤□□"+
				"＿＿赤赤赤赤赤■■赤赤赤赤赤＿＿"+
				"＿＿＿茶□□□□□□□□茶＿＿＿"+
				"＿＿＿＿茶□□□□□□茶＿＿■■"+
				"＿＿＿＿＿緑緑緑黄緑緑＿＿■＿＿"+
				"＿＿＿＿□緑緑黄緑緑緑□＿■＿＿"+
				"＿＿＿□□＿緑緑緑緑＿□□＿■＿"+
				"＿＿＿＿＿＿青青青青■＿＿＿■＿"+
				"＿＿＿＿＿＿□＿＿□＿■■■＿＿"+
				"";
	}
}
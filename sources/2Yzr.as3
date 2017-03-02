/**
 * アリのエサ運びをシミュレーションしてみました
 * 土をクリックするとお菓子が置けて、左下のボタンでアリが増やせます（1000匹まで）
 * ※増やしすぎ注意（負荷的にも見た目的にも・・・）
 * 
 * アリは普段ランダムに動いていますが、
 * エサを見つけると地面にフェロモンを残しながら巣まで戻り、
 * そのフェロモンを発見した他のアリがそれを辿ってエサの在り処を見つけるという流れです。
 * フェロモン濃度だけで判断するとなかなかうまく辿れなかったので
 * 濃度と一緒に進む方向も記録するようにしています。
 * （濃度と向きはBitmapDataのピクセルに色情報としてまとめて記録してます）
 * フェロモンが蒸発して消えないかぎり複雑な道のりも辿れるんですが、
 * 複雑すぎると巣に帰るプログラムかけなくなりそうだったのでやめました。。。
 */
package {
	import com.bit101.components.Label;
	import com.bit101.components.PushButton;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	public class Ants extends Sprite {
		///画面サイズ
		public const DISPLAY:Rectangle = new Rectangle(0, 0, 465, 465);
		///最初からいるアリの数
		public const ANTSNUM:int = 50;
		///一度に追加するアリの数
		public const ADDNUM:int = 50;
		///アリの最大数
		public const ANTSMAX:int = 1000;
		public const MATERIAL_URL:String = "http://assets.wonderfl.net/images/related_images/4/40/40c1/40c16871d560d547ebb1fc1725db47922ef9f261";
		public var world:World;
		public var bg:Sprite;
		public var containerAnts:Sprite;
		public var containerFoods:Sprite;
		public var canvasBmp:Bitmap;
		public var pheromoneBmp:Bitmap;
		public var canvas:BitmapData;
		public var loader:ImageLoader;
		public var stats:Label;
		public var whiteColor:ColorTransform = new ColorTransform();
		///コンストラクタ
		public function Ants() {
			stage.frameRate = 30;
			stage.quality = StageQuality.MEDIUM;
			Wonderfl.capture_delay(5);
			whiteColor.color = 0xFFFFFF;
			
			world = new World();
			world.home.setPosition(110, 350);
			world.obstacles.push(new Obstacle(280, 225, 90));
			world.obstacles.push(new Obstacle(0, -150, 280));
			world.init(DISPLAY.width, DISPLAY.height);
			
			bg = new Sprite();
			bg.graphics.beginFill(0x444444, 1);
			bg.graphics.drawRect(0, 0, DISPLAY.width, DISPLAY.height);
			bg.graphics.endFill();
			
			addChild(bg);
			
			//外部画像読み込み開始
			loader = new ImageLoader();
			loader.load(MATERIAL_URL, onLoadImage, onErrorImage);
		}
		///画像読み込み失敗
		private function onErrorImage(str:String):void {
			var msg:Label = new Label(this, 5, 5, str);
			msg.textField.wordWrap = true;
			msg.textField.width = 440;
			msg.transform.colorTransform = whiteColor;
		}
		///画像読み込み完了
		private function onLoadImage():void {
			loader.ground.width = DISPLAY.width;
			loader.ground.height = DISPLAY.height;
			
			pheromoneBmp = new Bitmap(world.pheromone.map);
			pheromoneBmp.visible = false;
			pheromoneBmp.blendMode = BlendMode.LIGHTEN;
			
			//障害物領域をマウスクリックできなくさせる
			for each(var obs:Obstacle in world.obstacles) {
				var sp:Sprite = addChild(new Sprite()) as Sprite;
				sp.graphics.beginFill(0x444444, 0);
				sp.graphics.drawCircle(obs.center.x, obs.center.y, obs.radius);
				sp.graphics.endFill();
			}
			canvas = new BitmapData(DISPLAY.width, DISPLAY.height, true, 0x00FFFFFF);
			canvasBmp = new Bitmap(canvas);
			canvasBmp.filters = [new DropShadowFilter(3, 45, 0x222222, 0.8, 3, 3, 1, 1)];
			containerAnts = new Sprite();
			containerFoods = new Sprite();
			containerFoods.mouseChildren = false;
			containerFoods.mouseEnabled = false;
			
			//画面下のメニュー
			var menu:Sprite = new Sprite();
			var blackBox:Sprite = menu.addChild(new Sprite()) as Sprite;
			blackBox.graphics.beginFill(0x000000, 0.5);
			blackBox.graphics.drawRect(0, 0, DISPLAY.width, 25);
			blackBox.graphics.endFill();
			new SwitchButton(menu, DISPLAY.width - 160, 5, ["PHEROMONE: OFF", "PHEROMONE: ON"], onSwitchPheromon);
			new PushButton(menu, DISPLAY.width - 55, 5, "RESET", onClickClear).setSize(50, 16);
			new PushButton(menu, 5, 5, "+" + ADDNUM + " ANTS", onClickAdd).setSize(70, 16);
			stats = new Label(menu, 85, 3, "");
			stats.transform.colorTransform = whiteColor;
			menu.y = DISPLAY.height - menu.height;
			
			//画面に色々配置
			addChild(loader.ground);
			addChild(pheromoneBmp);
			addChild(world.home);
			addChild(canvasBmp);
			addChild(containerFoods);
			addChild(menu);
			new Label(this, 5, 3, "CLICK TO FEED").transform.colorTransform = whiteColor;
			
			//メイン処理開始
			init(ANTSNUM);
			bg.addEventListener(MouseEvent.MOUSE_DOWN, onClickStage);
			addEventListener(Event.ENTER_FRAME, onEnter);
		}
		///蟻の数を指定して初期化
		private function init(num:int):void {
			world.clear();
			var wait:Number = 10;
			for (var i:int = 0; i < num; i++) {
				wait += Math.max(0.05, 15 / (i * i / 100 + 1));
				containerAnts.addChild(world.addAnt(wait).body);
			}
			updateStats();
		}
		///情報更新
		private function updateStats():void {
			stats.text = "ANTS: " + world.ants.length;
		}
		///全てリセット
		private function onClickClear(e:MouseEvent):void{
			init(ANTSNUM);
		}
		///アリ追加
		private function onClickAdd(e:MouseEvent):void {
			var num:int = Math.min(ADDNUM, ANTSMAX - world.ants.length);
			for (var i:int = 0; i < num; i++)
				containerAnts.addChild(world.addAnt(i/2).body);
			updateStats();
		}
		///フェロモン切り替え
		private function onSwitchPheromon(mode:int):void{
			pheromoneBmp.visible = !!mode;
		}
		///土をクリック
		private function onClickStage(e:MouseEvent):void {
			var img:ImageData = loader.feeds[Math.random() * loader.feeds.length | 0];
			containerFoods.addChild(world.addFood(stage.mouseX, stage.mouseY, img).sprite);
		}
		//毎フレーム処理
		private function onEnter(e:Event):void {
			world.pheromone.map.lock();
			for each(var a:Ant in world.ants) a.action(world);
			world.pheromone.vaporize();
			world.pheromone.map.unlock();
			canvas.fillRect(DISPLAY, 0x00000000);
			canvas.draw(containerAnts);
		}
	}
}
import com.bit101.components.PushButton;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.display.DisplayObjectContainer;
import flash.display.Loader;
import flash.display.Sprite;
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.MouseEvent;
import flash.events.SecurityErrorEvent;
import flash.filters.DropShadowFilter;
import flash.geom.ColorTransform;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.net.URLRequest;
import flash.system.LoaderContext;
import flash.system.System;
//角度変換用
class Angle {
	static public const ALL_RADIAN:Number = Math.PI * 2;
	static public const TO_RADIAN:Number = Math.PI / 180;
	static public const TO_ROTATION:Number = 180 / Math.PI;
	//角度を合成する
	static public function between(a1:Number, a2:Number, per:Number):Number {
		var minus:Number = a1 - a2;
		var r180:Number = (minus % Angle.ALL_RADIAN + Angle.ALL_RADIAN) % Angle.ALL_RADIAN;
		if (r180 > Math.PI) r180 -= Angle.ALL_RADIAN;
		var a0:Number = r180 + a2;
		return a0 * (1 - per) + a2 * (per);
	}
}
/**
 * 全てのデータ
 */
class World {
	///ワールドサイズ
	public var area:Rectangle;
	///全てのアリ
	public var ants:Vector.<Ant> = new Vector.<Ant>();
	///全てのエサ
	public var foods:Vector.<Food> = new Vector.<Food>();
	///全ての障害物
	public var obstacles:Vector.<Obstacle> = new Vector.<Obstacle>();
	///アリ塚
	public var home:AntsHill = new AntsHill();
	///フェロモン
	public var pheromone:Pheromone;
	public function World() {
	}
	///サイズを指定して初期化
	public function init(width:Number, height:Number):void {
		area = new Rectangle(0, 0, width, height);
		pheromone = new Pheromone(width, height);
	}
	///エサを削って無くなったら削除
	public function cutFood(f:Food):void {
		if (f.cut()) {
			f.remove();
			foods.splice(foods.indexOf(f), 1);
		}
	}
	///エサを追加
	public function addFood(x:int, y:int, img:ImageData):Food {
		var f:Food = new Food(x, y, 50, 200, img);
		foods.push(f);
		return f;
	}
	///アリを追加
	public function addAnt(wait:int):Ant {
		var a:Ant = new Ant(home.position.x, home.position.y);
		a.thinkTime = wait;
		ants.push(a);
		return a;
	}
	///色々リセット
	public function clear():void {
		for each(var f:Food in foods) f.remove();
		for each(var a:Ant in ants) a.remove();
		ants.length = 0;
		foods.length = 0;
		pheromone.clear();
		System.gc();
	}
}
/**
 * エサの画像
 */
class ImageData {
	private var _colors:Array;
	public var bmd:BitmapData;
	public function ImageData(bmd:BitmapData) {
		var px:int, py:int, rgba:uint;
		this.bmd = bmd;
		//画像のピクセルカラーを調べる（透明領域は無視）
		_colors = new Array();
		for (px = 0; px < bmd.width; px += 8) {
			for (py = 0; py < bmd.width; py += 8) {
				rgba = bmd.getPixel32(px, py);
				if (rgba >>> 24 == 255) _colors.push(rgba & 0xFFFFFF);
			}
		}
	}
	///画像の色をランダムに取得
	public function getRandomColor():uint {
		return _colors[Math.random() * _colors.length | 0];
	}
}
/**
 * 画像をロードして分割
 */
class ImageLoader {
	///背景画像
	public var ground:Bitmap;
	///エサ画像リスト
	public var feeds:Vector.<ImageData>;
	///エサ画像の数
	private const FEED_NUM:int = 5;
	private var _loader:Loader;
	private var _completeFunc:Function;
	private var _errorFunc:Function;
	public function ImageLoader() {
		_loader = new Loader();
	}
	public function load(src:String, complete:Function, error:Function):void{
		_completeFunc = complete;
		_errorFunc = error;
		_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onErrorImage);
		_loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onErrorImage);
		_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadImage);
		_loader.load(new URLRequest(src), new LoaderContext(true));
	}
	private function removeEvent():void {
		_loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onErrorImage);
		_loader.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onErrorImage);
		_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoadImage);
	}
	private function onErrorImage(e:ErrorEvent):void {
		removeEvent();
		_errorFunc(e.text);
	}
	private function onLoadImage(e:Event):void {
		removeEvent();
		var bmp:BitmapData = Bitmap(_loader.content).bitmapData;
		feeds = new Vector.<ImageData>();
		for (var i:int = 0; i < FEED_NUM; i++) {
			var bmp2:BitmapData = new BitmapData(64, 64, true, 0x00FFFFFF);
			bmp2.copyPixels(bmp, new Rectangle(64 * i, 0, 64, 64), new Point(0, 0));
			feeds.push(new ImageData(bmp2));
		}
		ground = new Bitmap(new BitmapData(bmp.width, bmp.height-64, false));
		ground.bitmapData.copyPixels(bmp, new Rectangle(0, 64, ground.width, ground.height), new Point());
		ground.smoothing = true;
		_completeFunc();
	}
}
/**
 * 切り替えボタン
 */
class SwitchButton extends PushButton {
	private var _mode:int = 0;
	private var _labels:Array;
	private var _clickFunc:Function;
	public function SwitchButton(parent:DisplayObjectContainer, xpos:Number, ypos:Number, labels:Array = null, func:Function = null) {
		if(labels == null) labels = [""];
		_labels = labels;
		_clickFunc = func;
		super(parent, xpos, ypos, _labels[0], onClick);
		height = 16;
	}
	private function onClick(e:MouseEvent):void {
		_mode = ++_mode % _labels.length;
		label = _labels[_mode];
		if (_clickFunc != null) _clickFunc(_mode);
	}
}
/**
 * アリ塚
 */
class AntsHill extends Sprite {
	public var position:Point;
	public function AntsHill() {
		graphics.beginFill(0x000000, 0.3);
		graphics.drawCircle(0, 0, 9);
		graphics.beginFill(0x000000, 1);
		graphics.drawCircle(0, 0, 7);
		graphics.endFill();
		position = new Point();
	}
	///位置変更
	public function setPosition(x:Number, y:Number):void {
		this.x = position.x = x;
		this.y = position.y = y;
	}
}
//フェロモン
class Pheromone {
	public var map:BitmapData;
	private var _ct:ColorTransform;
	private var _timeCount:int = 0;
	public function Pheromone(width:Number, height:Number) {
		_ct = new ColorTransform(1, 0.99, 1, 1, 0, 0, 0, 0);
		map = new BitmapData(width, height, true, 0x00000000);
	}
	///指定座標のフェロモンから進む角度を調べる
	public function getGuidepost(x:int, y:int):Number {
		var isNone:Boolean = true, tx:Number = 0, ty:Number = 0, px:int, py:int;
		//周囲のフェロモン濃度を調べて濃い方向を調べる
		for (px = -2; px <= 2; px++) {
			for (py = -2; py <= 2; py++) {
				if (px != 0 || py != 0) {
					var per:Number = (map.getPixel32(x + px * 4, y + py * 4) >> 8 & 0xFF) / 255;
					tx += per * px;
					ty += per * py;
					if (per) isNone = false;
				}
			}
		}
		var angle:Number;
		if ((!tx && !ty) || isNone) {
			angle = NaN;
		} else {
			//足元のフェロモンから進む角度を調べる
			var angleRate:Number = (map.getPixel32(x, y) & 0xFF) / 255;
			var dx:Number, dy:Number;
			if (angleRate == 0) {
				//フェロモンが無ければ濃い方へ
				dx = tx;
				dy = ty;
			} else {
				//フェロモンがあれば先に進む（周囲濃度で若干角度補正）
				var radian:Number = angleRate * Angle.ALL_RADIAN + Math.PI;
				dx = Math.cos(radian) * 40 + tx;
				dy = Math.sin(radian) * 40 + ty;
			}
			angle = Math.atan2(dy, dx);
		}
		return angle;
	}
	//フェロモンをつける
	public function putPheromone(x:int, y:int, radianPer:Number):void {
		var rgb:uint = 0xF0 << 24 | 0xFF << 16 | 0xFF << 8 | uint(0xFF * radianPer);
		map.fillRect(new Rectangle(x-5, y-5, 11, 11), rgb);
	}
	//フェロモン拡散
	public function vaporize():void {
		if (!(++_timeCount % 2)) map.colorTransform(map.rect, _ct);
	}
	//フェロモンリセット
	public function clear():void {
		map.fillRect(map.rect, 0x00000000);
	}
}
/**
 * アリのエサ
 */
class Food {
	public var sprite:Sprite;
	///位置
	public var position:Point;
	///半径
	public var size:Number;
	///残りの量
	public var quantity:int;
	///画像データ
	public var image:ImageData;
	private var _max:int;
	private var _mask:BitmapData;
	private var _noise:BitmapData;
	public function Food(x:Number = 0, y:Number = 0, size:Number = 10, num:int = 10, img:ImageData = null) {
		position = new Point(x, y);
		this.size = size;
		quantity = num;
		_max = num;
		sprite = new Sprite();
		sprite.x = x;
		sprite.y = y;
		sprite.scaleX = sprite.scaleY = 0.7;
		sprite.filters = [new DropShadowFilter(5, 45, 0x111111, 0.7, 8, 8, 1, 1)];
		image = img;
		var foodBmp:Bitmap = sprite.addChild(new Bitmap(image.bmd)) as Bitmap;
		foodBmp.smoothing = true;
		//徐々に削られるエフェクト用
		_mask = new BitmapData(image.bmd.width, image.bmd.height, true);
		_mask.fillRect(_mask.rect, 0x00888888);
		_noise = new BitmapData(image.bmd.width, image.bmd.height, false);
		_noise.perlinNoise(20, 20, 3, int(Math.random() * 100), false, true, 1, true);
		var maskBmp:Bitmap = sprite.addChild(new Bitmap(_mask)) as Bitmap;
		maskBmp.blendMode = BlendMode.ERASE;
		foodBmp.x = maskBmp.x = -foodBmp.width / 2;
		foodBmp.y = maskBmp.y = -foodBmp.height / 2;
	}
	///削る
	public function cut():Boolean {
		quantity--;
		var per:Number = quantity / _max * 0.4 + 0.4;
		_mask.fillRect(_mask.rect, 0xFF888888);
		_mask.threshold(_noise, _noise.rect, new Point(), "<", per * 255, 0x00000000, 255, false);
		return !quantity;
	}
	///削除
	public function remove():void {
		_mask.dispose();
		_noise.dispose();
		if (sprite.parent) sprite.parent.removeChild(sprite);
	}
}
/**
 * 円形障害物
 */
class Obstacle {
	///中心点
	public var center:Point;
	///半径
	public var radius:Number;
	public function Obstacle(x:Number = 0, y:Number = 0, radius:Number = 50) {
		center = new Point(x, y);
		this.radius = radius;
	}
}
/**
 * アリ
 */
class Ant {
	///グラフィック
	public var body:Sprite;
	///位置
	public var position:Point;
	///停止時間
	public var thinkTime:int = 0;
	private var _locus:Vector.<Point>;	//数フレーム前までの位置リスト
	private var _radian:Number = 0;	//角度
	private var _speed:Number = 2;	//速度
	private var _status:int = 0;	//状況　0:エサ探し　1：巣に帰る
	private var _freeTime:int = 0;	//フェロモン無効時間
	private var _view:Number = 20;	//視界範囲
	private var _wanderCnt:int = 1;
	private var _food:Sprite;
	private var _randomRad:Number;
	private var _startReturn:Boolean = false;
	private var _searchCnt:int = -1;
	private var _targetFood:Food = null;
	public function Ant(x:Number = 0, y:Number = 0) {
		body = new Sprite();
		body.graphics.beginFill(0x000000, 1);
		body.graphics.drawRect(-4, -1, 4, 2);
		body.graphics.drawRect(1, -1, 1, 2);
		body.graphics.drawRect(3, -1, 2, 2);
		body.graphics.endFill();
		body.visible = false;
		_food = body.addChild(new Sprite()) as Sprite;
		_food.graphics.beginFill(0xFFFFFF, 1);
		_food.graphics.drawRect(-2, -2, 4, 4);
		_food.graphics.endFill();
		_food.x = 6;
		_food.visible = false;
		position = new Point(x, y);
		_locus = new Vector.<Point>();
		_radian = Math.random() * Angle.ALL_RADIAN;
		_randomRad = (Math.random() * 10 - 5) * Angle.TO_RADIAN;
	}
	///行動
	public function action(w:World):void {
		if (thinkTime) {
			if (--thinkTime == 0) {
				if (_status == 0) startSearch();
				if (_startReturn) {
					_startReturn = false;
					toFace(w.home.position);
				}
			}
			return;
		} else {
			randomThink(0.015, Math.random() * 10 + 15);
		}
		//エサ探しモード
		if (_status == 0) {
			_searchCnt = ++_searchCnt % 3;
			if (!_searchCnt) {
				var near:Number = Number.MAX_VALUE;
				_targetFood = null;
				for each(var f:Food in w.foods) {
					var distance:Number = position.subtract(f.position).length;
					//エサに接触したら持ち帰り始める
					if (distance <= f.size/2 + 1) {
						thinkTime = Math.random() * 50 + 30;
						getFood(f.image.getRandomColor());
						w.cutFood(f);
						return;
					}
					//エサを見つけた
					var d:Number = distance - f.size/2;
					if (d <= _view && d < near) {
						near = d;
						_targetFood = f;
					}
				}
			}
			//エサを見つけているか
			if (_targetFood) {
				toFace(_targetFood.position);
			} else {
				if (_freeTime > 0) _freeTime--;
				//フェロモンが近くにあるかチェック
				var rad:Number = (_freeTime > 0)? NaN : w.pheromone.getGuidepost(position.x, position.y);
				if (isNaN(rad)) {
					//なければうろつく
					wander();
				} else {
					//あればフォロモンの流れに向く
					_radian = Angle.between(rad, _radian, 0.5) + Angle.TO_RADIAN + _randomRad;
					checkStay();
				}
			}
		}
		
		//エサ持ち帰りモード
		if (_status == 1) {
			var per:Number = _radian / Angle.ALL_RADIAN;
			w.pheromone.putPheromone(position.x, position.y, per);
			goto(w.home.position);
			if (w.home.position.subtract(position).length < 5) backHome();
		}
		
		//進行方向に進む
		position.x += Math.cos(_radian) * _speed;
		position.y += Math.sin(_radian) * _speed;
		
		//障害物を避ける
		adjustPosition(w);
		
		//表示更新
		body.x = position.x;
		body.y = position.y;
		body.rotation = _radian * Angle.TO_ROTATION;
	}
	///ランダム回転
	private function wander():void {
		_wanderCnt = ++_wanderCnt % 4;
		if (!_wanderCnt) _radian += (Math.random() * 60 - 30) * Angle.TO_RADIAN;
	}
	///指定の座標を向く
	private function toFace(target:Point):void {
		_radian = Math.atan2(target.y - position.y, target.x - position.x);
	}
	///指定座標に向かいながらランダム回転
	private function goto(target:Point):void {
		_wanderCnt = ++_wanderCnt % 4;
		if (!_wanderCnt) {
			var minus:Point = target.subtract(position);
			var rad:Number = Math.atan2(minus.y, minus.x);
			var per:Number = minus.length / 100;
			if (per > 1) per = 1;
			_radian = Angle.between(rad, _radian, 0.75 * per) + (Math.random() * 30 - 15) * Angle.TO_RADIAN;
		}
	}
	///一定時間その場でうろついていたらフェロモン無効に
	private function checkStay():void {
		_locus.unshift(position.clone());
		_locus.length = 4;
		if (_locus[3] && _locus[0].subtract(_locus[3]).length <= _speed * 2) _freeTime = 60;
	}
	///障害物を避けるように位置と角度を調整
	private function adjustPosition(w:World):void {
		//円形障害物を避ける角度を調べる
		var adjustRad1:Number = NaN;
		var plus:Point = new Point(Math.cos(_radian) * _speed, Math.sin(_radian) * _speed);
		var nextPos:Point = position.add(plus);
		for each(var obs:Obstacle in w.obstacles) {
			var distance:Number = Point.distance(nextPos, obs.center);
			if (distance < obs.radius) {
				var radius:Point = nextPos.subtract(obs.center);
				if (radius.length < obs.radius) {
					radius.normalize(obs.radius);
					var fixPos:Point = obs.center.add(radius);
					adjustRad1 = Math.atan2(fixPos.y - position.y, fixPos.x - position.x);
				}
				break;
			}
		}
		if(!isNaN(adjustRad1)) _radian = Angle.between(adjustRad1, _radian, 0.85);
		
		//ワールドエリア内に収まる位置と角度を調べる
		var rect:Rectangle = w.area;
		var adjustRad2:Number = NaN;
		var padding:int = 5;
		if (position.x < rect.left + padding) {
			position.x = rect.left + padding;
			adjustRad2 = 0;
		}
		if (position.x > rect.right - padding) {
			position.x = rect.right - padding;
			adjustRad2 = Math.PI;
		}
		if (position.y > rect.bottom - padding) {
			position.y = rect.bottom - padding;
			adjustRad2 = Math.PI * 1.5;
		}
		if (position.y < rect.top + padding) {
			position.y = rect.top + padding;
			adjustRad2 = Math.PI * 0.5;
		}
		if (!isNaN(adjustRad2)) _radian = Angle.between(adjustRad2, _radian, 0.9);
	}
	///一定確率で立ち止まる
	private function randomThink(per:Number, time:int):void {
		if (Math.random() <= per) thinkTime = time;
	}
	///エサを探し始める
	private function startSearch():void {
		body.visible = true;
		_status = 0;
	}
	///巣に入れる
	private function backHome():void {
		_status = 0;
		_food.visible = false;
		body.visible = false;
		thinkTime = Math.random() * 100 + 100;
	}
	///エサを取得
	private function getFood(color:uint = 0xFFFFFF):void {
		_status = 1;
		_startReturn = true;
		_food.visible = true;
		var ct:ColorTransform = new ColorTransform();
		ct.color = color;
		_food.transform.colorTransform = ct;
	}
	///親から削除
	public function remove():void {
		_targetFood = null;
		if (body.parent != null) body.parent.removeChild(body);
	}
}
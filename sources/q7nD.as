/* -----------------------------------------------------
 * まだ全然出来てないんですが、とりあえずテストで投稿。
 * 今後更新を重ねてちゃんと完成まで持っていく予定です。
 * 
 * ４月から本気出す
 * 
 * -----------------------------------------------------
 */

package {
	import com.bit101.components.ProgressBar;
	import flash.display.*;
	import flash.events.Event;
	
	public class Main extends Sprite {
		public static var nodes:Array;
		public static var towers:Array;
		public static var enemies:Array;
		public static var bullets:Array;
		public static var goals:Array;
		
		private var _fieldMap:FieldMap;
		private var _frontend:Frontend;
		
		public function Main() {
			var preloader:Preloader = ImageFactory.preload(this);
			preloader.addEventListener(Event.COMPLETE, initialize);
		}
		
		private function initialize(e:Event):void {
			e.target.removeEventListener(Event.COMPLETE, initialize);
			
			graphics.beginFill(0x000000);
			graphics.drawRect(0, 0, 465, 465);
			graphics.endFill();
			
			initializeNodes();
			towers = [];
			enemies = [];
			bullets = [];
			goals = Parameter.getGoals();
			
			addChild(_fieldMap = new FieldMap( -9, 12));
			addChild(_frontend = new Frontend());
		}
		
		private function initializeNodes():void {
			nodes = [];
			for (var row:int = 0; row < Parameter.NODE_ROWS; row++) {
				nodes[row] = [];
				for (var col:int = 0; col < Parameter.NODE_COLS; col++) {
					nodes[row][col] = new Node(col, row, Parameter.MAP_DATA[row][col]);
				}
			}
		}
	}
}

//package {
	import flash.geom.Point;
	
	//public 
	class Parameter {
		public static const FRAMERATE:int = 30;						// fps
		public static const NODE_SIZE:Number = 16;					// ノードの大きさ
		public static const NODE_COLS:int = 24;						// ノードの行数（横に並ぶ数）
		public static const NODE_ROWS:int = 26;						// ノードの列数（縦に並ぶ数）
		public static const TOWER_SIZE:Number = NODE_SIZE * 2;		// タワーの大きさ
		public static const TOWER_IMAGE_SIZE:int = TOWER_SIZE + 8;	// タワーの画像の大きさ
		public static const TOWER_SELL_RATE:Number = 0.8;			// タワー売却値の率
		public static const SLOWING_TIME:Number = 4.0;				// スロー状態の持続時間
		public static const INITIAL_LIVES:int = 20;					// ライフの初期値
		public static const INITIAL_GOLD:int = 10000;					// ゴールドの初期値
		
		// マップを構成する各ノードの属性の情報
		public static const MAP_DATA:Array = [
			[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
			[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
			[1,1,0,0,0,0,0,0,0,1,1,1,1,1,1,0,0,0,0,0,0,0,1,1],
			[1,0,0,0,0,0,0,0,0,0,2,1,1,2,0,0,0,0,0,0,0,0,0,1],
			[1,0,0,0,0,0,0,0,0,0,2,2,2,2,0,0,0,0,0,0,0,0,0,1],
			[1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
			[1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
			[1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
			[1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
			[1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
			[1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
			[1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
			[1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
			[1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
			[1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
			[1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
			[1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
			[1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
			[1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
			[1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
			[1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
			[1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
			[1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
			[1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
			[1,1,2,2,2,2,2,1,1,1,1,1,1,1,1,1,1,2,2,2,2,2,1,1],
			[1,1,2,2,2,2,2,1,1,1,1,1,1,1,1,1,1,2,2,2,2,2,1,1]
		];
		
		// 読み込むべき外部画像のリスト
		public static const EXTERNAL_IMAGES:Object = {
			Fieldmap : "http://assets.wonderfl.net/images/related_images/5/5f/5ff7/5ff7c989b7a1068c50a7008713931f651804468c",
			Arrow : "http://assets.wonderfl.net/images/related_images/6/63/6343/63436a18a4aea50e9219db1a18fed0c3feddfd45",
			Gatling : "http://assets.wonderfl.net/images/related_images/4/40/4008/4008e51eb77440a7421dfc0363f55fc4784f069c",
			Bomb : "http://assets.wonderfl.net/images/related_images/b/b5/b5d2/b5d2a5c08373d1bd07375d9ad74bf502f9fcccc8",
			Misslie : "http://assets.wonderfl.net/images/related_images/6/69/6950/6950fb7ed305b34a23392d7b1371a13b49a7ccbc",
			Frost : "http://assets.wonderfl.net/images/related_images/6/69/6931/6931d44cd4bbf0feb60b4c2d24ffa6f29098479b",
			Vortex : "http://assets.wonderfl.net/images/related_images/d/df/df45/df45671017d8385c582396d44f98e8e2fd705ee2",
			Laser : "http://assets.wonderfl.net/images/related_images/9/92/9245/9245550bd2d49a69cec242205454199d1e4f6b87"
		};
		
		private static const data:XML =
		<root>
			<towers>
				<tower name="Arrow" ground="1" air="1" slow="0" splash="0">
					<stats rank="E" cost="10"   damage="30"   range="60"  firerate="1.5" />
					<stats rank="D" cost="20"   damage="60"   range="65"  firerate="1.5" />
					<stats rank="C" cost="40"   damage="90"   range="70"  firerate="1.5" />
					<stats rank="B" cost="80"   damage="120"  range="75"  firerate="1.5" />
					<stats rank="A" cost="280"  damage="150"  range="150" firerate="1.5" />
				</tower>
				<tower name="Gatling" ground="1" air="1" slow="0" splash="0">
					<stats rank="E" cost="20"   damage="15"   range="50"  firerate="3" />
					<stats rank="D" cost="40"   damage="30"   range="55"  firerate="4" />
					<stats rank="C" cost="80"   damage="45"   range="60"  firerate="5" />
					<stats rank="B" cost="160"  damage="60"   range="65"  firerate="6" />
					<stats rank="A" cost="400"  damage="90"   range="70"  firerate="8" />
				</tower>
				<tower name="Bomb" ground="1" air="0" slow="0" splash="1">
					<stats rank="E" cost="25"   damage="10"   range="90"  firerate="1" />
					<stats rank="D" cost="50"   damage="20"   range="95"  firerate="1" />
					<stats rank="C" cost="75"   damage="40"   range="100" firerate="1" />
					<stats rank="B" cost="100"  damage="80"   range="105" firerate="1" />
					<stats rank="A" cost="300"  damage="160"  range="120" firerate="1" />
				</tower>        
				<tower name="Misslie" ground="0" air="1" slow="0" splash="0">
					<stats rank="E" cost="30"   damage="25"   range="65" firerate="4" />
					<stats rank="D" cost="60"   damage="50"   range="65" firerate="4" />
					<stats rank="C" cost="120"  damage="100"  range="65" firerate="4" />
					<stats rank="B" cost="180"  damage="200"  range="65" firerate="4" />
					<stats rank="A" cost="240"  damage="300"  range="65" firerate="4" />
				</tower>        
				<tower name="Frost" ground="1" air="1" slow="1" splash="1">
					<stats rank="E" cost="50"   damage="10"   range="50" firerate="0.5" />
					<stats rank="D" cost="100"  damage="15"   range="50" firerate="0.7" />
					<stats rank="C" cost="150"  damage="20"   range="55" firerate="0.7" />
					<stats rank="B" cost="200"  damage="25"   range="55" firerate="0.9" />
					<stats rank="A" cost="150"  damage="30"   range="60" firerate="1.0" />
				</tower>        
				<tower name="Vortex" ground="1" air="0" slow="0" splash="1">
					<stats rank="E" cost="100"  damage="150"  range="40" firerate="0.3" />
					<stats rank="D" cost="200"  damage="300"  range="40" firerate="0.3" />
					<stats rank="C" cost="400"  damage="600"  range="40" firerate="0.3" />
					<stats rank="B" cost="600"  damage="1000" range="40" firerate="0.3" />
					<stats rank="A" cost="1000" damage="2000" range="40" firerate="0.3" />
				</tower>        
				<tower name="Laser" ground="1" air="1" slow="0" splash="1">
					<stats rank="E" cost="150"  damage="80"   range="80" firerate="0.3" />
					<stats rank="D" cost="300"  damage="160"  range="80" firerate="0.3" />
					<stats rank="C" cost="450"  damage="320"  range="80" firerate="0.4" />
					<stats rank="B" cost="900"  damage="640"  range="80" firerate="0.4" />
					<stats rank="A" cost="2000" damage="960"  range="80" firerate="0.5" />
				</tower>        
			</towers>
			<enemies>
				<enemy type="Normal" hpbase="2" hpgrow="7" bounty="1" speed="1.0" />
				<enemy type="Immune" hpbase="2" hpgrow="6" bounty="1" speed="1.0" />
				<enemy tyep="Flying" hpbase="2" hpgrow="5" bounty="2" speed="1.0" />
			</enemies>
			<levels>
				<level type="normal" time="20"><spawn num="10" /><spawn num="0" /><spawn num="10" /></level>
			</levels>
			<starts>
				<start x="35" y="400" width="75" height="12"/>
				<start x="275" y="400" width="75" height="12"/>
				<start x="160" y="400" width="64" height="12"/>
			</starts>
			<goals>
				<goal x="10" y="3" /><goal x="10" y="4" />
				<goal x="11" y="4" /><goal x="12" y="4" />
				<goal x="13" y="3" /><goal x="13" y="4" />
			</goals>
		</root>;
		
		// タワーの属性情報を返す
		public static function getTowerAttlibutes(towerName:String):Object {
			var tower:XMLList = Parameter.data.towers.*.(@name == towerName);
			if (tower.length() == 0) { return null; } // 指定した名前のタワーが存在しないならnullを返す
			
			return {
				ground : Boolean(int(tower.@ground)),
				air : Boolean(int(tower.@air)),
				slow : Boolean(int(tower.@slow)),
				splash : Boolean(int(tower.@splash))
			};
		}
		
		// タワーのステータス情報を返す
		public static function getTowerStats(towerName:String, rankNum:int):Object {
			var stats:XML = Parameter.data.towers.*.(@name == towerName).stats[rankNum];
			if (stats == null) { return null; }	// ステータス情報が無いならnullを返す
			
			return {
				rank : stats.@rank,
				cost : stats.@cost,
				damage : stats.@damage,
				range : stats.@range,
				firerate : stats.@firerate
			};
		}
		
		// ゴールの配列を返す
		public static function getGoals():Array {
			var goals:Array = [];
			for each(var g:XML in Parameter.data.goals.*) {
				goals.push(new Goal(new Point(int(g.@x), int(g.@y))));
			}
			return goals;
		}
	}
//}
//package {
	import flash.display.*;
	import flash.filters.*;
	import flash.geom.Matrix;
	import flash.text.*;
	
	//public 
	class ImageFactory {
		private static var _externalImages:Object;			// 外部画像の連想配列
		private static var _enemyImages:Object;				// 敵画像の連想配列
		private static var _towerBase:BitmapData = null;	// タワーの土台
		private static var _cancelMark:BitmapData = null;	// （タワー選択）キャンセルのマーク
		
		// プリローダーを作成、読み込みを開始する
		public static function preload(parentOfProgressBar:DisplayObjectContainer):Preloader {
			initializeEnemyImages();
			
			_externalImages = { };
			return new Preloader(parentOfProgressBar, _externalImages);
		}
		
		// 敵画像の連想配列を初期化する
		private static function initializeEnemyImages():void {
			_enemyImages = { };
			
			var enemyTypes:Array = ["Normal", "Immune", "Flying"];
			for (var i:int = 0; i < enemyTypes.length; i++) {
				_enemyImages[enemyTypes[i]] = ImageFactory.createEnemy(enemyTypes[i]);
			}
		}
		
		// 外部画像を取得する
		public static function getImage(name:String):BitmapData {
			return _externalImages[name];
		}
		
		// 敵画像を取得する
		public static function getEnemy(name:String):BitmapData {
			return _enemyImages[name];
		}
		
		// キャンセルのマークの画像を取得する
		public static function getCancelMark():BitmapData {
			if (_cancelMark == null) {
				_cancelMark = new BitmapData(Parameter.TOWER_IMAGE_SIZE, Parameter.TOWER_IMAGE_SIZE, true, 0x00ffffff);
				
				var shape:Shape = new Shape();
				var center:Number = Parameter.TOWER_IMAGE_SIZE / 2;
				var radius:Number = center - 8;
				shape.graphics.lineStyle(4, 0xff0000);
				shape.graphics.drawCircle(center, center, radius);
				shape.graphics.moveTo(center + (radius * Math.cos(9 * Math.PI / 8)), center + (radius * Math.sin(9 * Math.PI / 8)));
				shape.graphics.lineTo(center + (radius * Math.cos(Math.PI / 8)), center + (radius * Math.sin(Math.PI / 8)));
				_cancelMark.draw(shape);
			}
			
			return _cancelMark;
		}
		
		// タワーの土台の画像を取得する
		public static function getTowerBase():BitmapData {
			if (_towerBase == null) {
				_towerBase = new BitmapData(Parameter.TOWER_SIZE, Parameter.TOWER_SIZE);
				
				var shape:Shape = new Shape();
				shape.graphics.beginFill(0xc0c0c0);
				shape.graphics.drawRect(0, 0, Parameter.TOWER_SIZE, Parameter.TOWER_SIZE);
				shape.graphics.endFill();
				shape.filters = [new BevelFilter(1, 45, 0xffffff, 1, 0x606060, 1, Parameter.TOWER_SIZE / 4, Parameter.TOWER_SIZE / 4, 255)];
				
				_towerBase.draw(shape);
			}
			
			return _towerBase;
		}
		
		// 敵の画像を作成する
		private static function createEnemy(type:String):BitmapData {
			var bitmapData:BitmapData = new BitmapData(Parameter.NODE_SIZE, Parameter.NODE_SIZE, true, 0x00ffffff);
			
			var shape:Shape;
			switch(type) {
				case "Normal": shape = ImageFactory.createNormalEnemy(); break;
				case "Immune": shape = ImageFactory.createImmuneEnemy(); break;
				case "Flying": shape = ImageFactory.createFlyingEnemy(); break;
				default: shape = new Shape();
			}
			
			bitmapData.draw(shape);
			return bitmapData;
		}
		
		private static function createNormalEnemy():Shape {
			var shape:Shape = new Shape();
			
			shape.graphics.beginFill(0xff0000);
			shape.graphics.drawRect(4, 2, 4, 12);
			shape.graphics.drawRect(8, 6, 4, 4);
			shape.graphics.endFill();
			shape.filters = [new GlowFilter(0x880000, 1, 2, 2, 255)];
			
			return shape;
		}
		
		private static function createImmuneEnemy():Shape {
			var shape:Shape = new Shape();
			
			shape.graphics.beginFill(0xff0000);
			shape.graphics.drawCircle(8, 8, 6);
			shape.graphics.endFill();
			shape.filters = [new GlowFilter(0x880000, 1, 2, 2, 255)];
			
			return shape;
		}
		
		private static function createFlyingEnemy():Shape {
			var shape:Shape = new Shape();
			
			shape.graphics.lineStyle(1, 0x880000);
			shape.graphics.beginFill(0xff0000);
			shape.graphics.moveTo(2, 4);
			shape.graphics.lineTo(10, 4);
			shape.graphics.lineTo(14, 8);
			shape.graphics.lineTo(2, 4);
			shape.graphics.endFill();
			
			return shape;
		}
		
		// 普通のテキストを作成する
		public static function createSimpleText(posx:int, posy:int, width:int, height:int, text:String, fontSize:int, textColor:uint):TextField {
			return ImageFactory.createText(posx, posy, width, height, text, fontSize, textColor, TextFieldAutoSize.CENTER);
		}
		
		// 縁取り付きのテキストを作成する
		public static function createBorderedText(posx:int, posy:int, width:int, height:int, text:String, fontSize:int, textColor:uint, borderColor:uint):TextField {
			return ImageFactory.createText(posx, posy, width, height, text, fontSize, textColor, TextFieldAutoSize.CENTER, false, true, borderColor);
		}
		
		// スコア表示用のテキストを作成する
		public static function createScoreText(posx:int, posy:int, width:int, height:int, text:String, fontSize:int, textColor:uint):TextField {
			return ImageFactory.createText(posx, posy, width, height, text, fontSize, textColor, TextFieldAutoSize.RIGHT, true);
		}
		
		// タワーのステータス表示用テキストを作成する
		public static function createStatsText(posx:int, posy:int, width:int, height:int, text:String, fontSize:int, textColor:uint):TextField {
			return ImageFactory.createText(posx, posy, width, height, text, fontSize, textColor, TextFieldAutoSize.CENTER, true);
		}
		
		private static function createText(posx:int, posy:int, width:int, height:int, text:String, fontSize:int, textColor:uint, autoSize:String, bold:Boolean = false, border:Boolean = false, borderColor:uint = 0x000000):TextField {
			var textField:TextField = new TextField();
			
			var textFormat:TextFormat = new TextFormat("Arial", fontSize, null, bold);
			textField.defaultTextFormat = textFormat;
			
			textField.text = text;
			textField.x = posx;
			textField.y = posy + Math.ceil((height - (textField.textHeight + 4)) / 2);
			textField.width = Math.max(width, textField.textWidth);
			textField.height = textField.textHeight + 4;
			textField.textColor = textColor;
			if (border) { textField.filters = [new GlowFilter(borderColor, 1, 4, 4)]; }
			
			textField.autoSize = autoSize;
			textField.mouseEnabled = textField.selectable = false;
			
			return textField;
		}
		
		// ウインドウを作成する（FF6っぽいヤツ）
		public static function createWindow(posx:int, posy:int, width:int, height:int):Sprite {
			var sprite:Sprite = new Sprite();
			sprite.x = posx;
			sprite.y = posy;
			
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(width, height, Math.PI / 2);
			
			sprite.graphics.lineStyle(2);
			sprite.graphics.lineGradientStyle(GradientType.LINEAR, [0xf0f0f0, 0x808080], [1, 1], [0, 255], matrix);
			sprite.graphics.beginGradientFill(GradientType.LINEAR, [0x303090, 0x000030], [1, 1], [0, 255], matrix);
			sprite.graphics.drawRoundRect(1, 1, width - 2, height - 2, 10);
			sprite.graphics.endFill();
			
			return sprite;
		}
		
		// カーソルを描画する
		public static function drawCursor(g:Graphics):void {
			g.lineStyle(1, 0xffffff);
			g.drawRect(0.5, 0.5, Parameter.TOWER_SIZE - 1, Parameter.TOWER_SIZE - 1);
			g.endFill();
		}
		
		// 射程範囲の円を描画する
		public static function drawRangeCircle(g:Graphics, radius:int = 16, color:uint = 0xffffff):void {
			g.beginFill(color, 0.3);
			g.drawCircle(Parameter.TOWER_SIZE / 2, Parameter.TOWER_SIZE / 2, radius);
			g.endFill();
		}
	}
//}
//package {
	import com.bit101.components.ProgressBar;
	import flash.display.DisplayObjectContainer;
	import flash.events.*;
	
	//public
	class Preloader extends EventDispatcher {
		private var _imageNum:int;				// 読み込むべき外部画像の数
		private var _loadedNum:int;				// 読み込み完了した外部画像の数
		private var _loaders:Object;			// 外部画像ローダの連想配列
		private var _imagesReference:Object;	// 外部画像の連想配列の参照
		private var _progressBar:ProgressBar;	// プログレスバー
		
		public function Preloader(parentOfProgressBar:DisplayObjectContainer, images:Object) {
			_imageNum = 0;
			_loadedNum = 0;
			_loaders = { };
			_imagesReference = images;
			_progressBar = new ProgressBar(parentOfProgressBar, 182, 227);
			
			// 各外部画像の読み込みを開始する
			for (var imageName:* in Parameter.EXTERNAL_IMAGES) {
				_imageNum++;
				var loader:ExternalImageLoader = new ExternalImageLoader();
				_loaders[imageName] = loader;
				loader.addEventListener(Event.COMPLETE, imageLoaded);
				loader.load(Parameter.EXTERNAL_IMAGES[imageName]);
			}
			_progressBar.maximum = _imageNum;
		}
		
		// 一つの画像の読み込みが完了した際に呼ばれるメソッド
		private function imageLoaded(e:Event):void {
			e.target.removeEventListener(Event.COMPLETE, imageLoaded);
			
			_loadedNum++;
			_progressBar.value = _loadedNum;
			if (_loadedNum == _imageNum) { loadComplete(); }
		}
		
		// 全ての画像の読み込みが完了した際に呼ばれるメソッド
		private function loadComplete():void {
			for (var imageName:* in _loaders) {
				_imagesReference[imageName] = _loaders[imageName].content;
			}
			
			DisplayObjectContainer(_progressBar.parent).removeChild(_progressBar);
			dispatchEvent(new Event(Event.COMPLETE));
		}
	}
//}
//package {
	import flash.display.*;
	import flash.events.*;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	
	//public
	class ExternalImageLoader extends EventDispatcher {
		private var _content:BitmapData;
		private var _tmpA:Loader;
		private var _tmpB:Loader;
		
		public function get content():BitmapData { return _content; }
		
		public function ExternalImageLoader() {
			_content = null;
			_tmpA = new Loader();
			_tmpB = new Loader();
		}
		
		public function load(url:String):void {
			_tmpA.contentLoaderInfo.addEventListener(Event.INIT, tmpALoaded);
			_tmpA.load(new URLRequest(url), new LoaderContext(true));
		}
		
		private function tmpALoaded(e:Event):void {
			_tmpA.contentLoaderInfo.removeEventListener(Event.INIT, tmpALoaded);
			_content = new BitmapData(int(_tmpA.width), int(_tmpA.height), true, 0x00ffffff);
			_tmpB.contentLoaderInfo.addEventListener(Event.INIT, tmpBLoaded);
			_tmpB.loadBytes(_tmpA.contentLoaderInfo.bytes);
		}
		
		private function tmpBLoaded(e:Event):void {
			_tmpB.contentLoaderInfo.removeEventListener(Event.INIT, tmpBLoaded);
			_content.draw(_tmpB);
			_tmpA.unload();
			_tmpB.unload();
			dispatchEvent(new Event(Event.COMPLETE));
		}
	}
//}
//package {
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	//public
	class FieldMap extends Sprite {
		private var _groundEnemyLayer:Sprite;
		private var _towerLayer:Sprite;
		private var _airEnemyLayer:Sprite;
		private var _bulletLayer:Sprite;
		private var _cursor:Sprite;
		
		public function FieldMap(posx:int, posy:int) {
			x = posx;
			y = posy;
			
			addChild(new Bitmap(ImageFactory.getImage("Fieldmap")));
			addChild(_groundEnemyLayer = new Sprite());
			addChild(_towerLayer = new Sprite());
			addChild(_airEnemyLayer = new Sprite());
			addChild(_bulletLayer = new Sprite());
			addChild(_cursor = new Sprite());
			_bulletLayer.mouseEnabled = _cursor.mouseEnabled = false;
			_cursor.visible = false;
			
			addEventListener(MouseEvent.CLICK, clickFieldMap);
			addEventListener(MouseEvent.ROLL_OVER, showCursor);
			addEventListener(MouseEvent.ROLL_OUT, hideCursor);
			
			//test
			var e:Enemy = new Enemy(new Point(40, 390), { hp:1, bounty:1, speed:1 } );
			Main.enemies.push(e);
			_groundEnemyLayer.addChild(e);
			addEventListener(Event.ENTER_FRAME, test);
		}
		
		private function test(e:Event):void {
			for (var i:int = 0; i < Main.towers.length; i++) {
				Main.towers[i].update();
			}
			for (var j:int = 0; j < Main.enemies.length; j++) {
				Main.enemies[j].update();
			}
		}
		
		private function clickFieldMap(e:MouseEvent):void {
			var data:GameData = GameData.instance;
			
			var selectedTower:Tower = data.selectedTower;
			if (selectedTower != null && !selectedTower.active) {
				if (Node.buildable(_cursor.x, _cursor.y) && data.buyable(selectedTower.cost) && Goal.reSearch(Node.tileFromPosition(new Point(_cursor.x,_cursor.y)))) {
					var tower:Tower = new Tower(_cursor.x, _cursor.y, data.selectedTower.towerName, true);
					data.spendGold(selectedTower.cost);
					Main.towers.push(tower);
					_towerLayer.addChild(tower);
				}
			}
		}
		
		private function showCursor(e:MouseEvent):void {
			_cursor.visible = true;
			addEventListener(Event.ENTER_FRAME, updateCursor);
		}
		
		private function hideCursor(e:MouseEvent):void {
			removeEventListener(Event.ENTER_FRAME, updateCursor);
			_cursor.visible = false;
		}
		
		private function updateCursor(e:Event):void {
			var selectedTower:Tower = GameData.instance.selectedTower;
			
			if(!(selectedTower != null && selectedTower.active)){
				_cursor.x = mouseX - (mouseX % Parameter.NODE_SIZE);
				_cursor.y = mouseY - (mouseY % Parameter.NODE_SIZE);
			}else {
				_cursor.x = selectedTower.x;
				_cursor.y = selectedTower.y;
			}
			
			_cursor.graphics.clear();
			if (selectedTower != null) {
				ImageFactory.drawRangeCircle(_cursor.graphics, selectedTower.range, 0xffffff);
				ImageFactory.drawCursor(_cursor.graphics);
			}
		}
	}
//}
//package {
	import com.bit101.components.*;
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	
	//public 
	class Frontend extends Sprite {
		private var _level:TextField;
		private var _score:TextField;
		private var _lives:TextField;
		private var _gold:TextField;
		
		private var _towerStatsWindow:Sprite;
		private var _towerMenuWindow:Sprite;
		private var _name:TextField;
		private var _attlibuteGround:TextField;
		private var _attlibuteAir:TextField;
		private var _attlibuteSlow:TextField;
		private var _attlibuteSplash:TextField;
		private var _rank:TextField;
		private var _cost:TextField;
		private var _damage:TextField;
		private var _range:TextField;
		private var _fireRate:TextField;
		
		public function Frontend() {
			setupMainStatsWindow();
			setupTowerSelectWindow();
			setupTowerStatsWindow();
			setupLevelBarWindow();
			setupMenuWindow();
			
			GameData.instance.addEventListener(Event.CHANGE, update);
		}
		
		// メインステータスを表示するウインドウを配置する
		private function setupMainStatsWindow():void {
			var mainStatsWindow:Sprite = ImageFactory.createWindow(0, 0, 365, 25);
			
			mainStatsWindow.addChild(ImageFactory.createBorderedText(14, 0, 40, 25, "Level :", 12, 0xffffff, 0x808080));
			mainStatsWindow.addChild(_level = ImageFactory.createScoreText(54, 0, 25, 25, "0", 14, 0xffffff));
			
			mainStatsWindow.addChild(ImageFactory.createBorderedText(93, 0, 40, 25, "Score :", 12, 0xffffff, 0x808080));
			mainStatsWindow.addChild(_score = ImageFactory.createScoreText(133, 0, 50, 25, "0", 14, 0xffffff));
			
			mainStatsWindow.addChild(ImageFactory.createBorderedText(197, 0, 40, 25, "Lives :", 12, 0xffffff, 0xf00000));
			mainStatsWindow.addChild(_lives = ImageFactory.createScoreText(237, 0, 20, 25, Parameter.INITIAL_LIVES.toString(), 14, 0xff0000));
			
			mainStatsWindow.addChild(ImageFactory.createBorderedText(271, 0, 35, 25, "Gold :", 12, 0xffffff, 0xb0b000));
			mainStatsWindow.addChild(_gold = ImageFactory.createScoreText(306, 0, 45, 25, Parameter.INITIAL_GOLD.toString(), 14, 0xffff00));
			
			addChild(mainStatsWindow);
		}
		
		// タワーを選択するウインドウを配置する
		private function setupTowerSelectWindow():void {
			var towerSelectWindow:Sprite = ImageFactory.createWindow(365, 0, 100, 415);
			
			var towerNames:Array = ["Arrow", "Gatling", "Bomb", "Misslie", "Frost", "Vortex", "Laser", "Cancel"];
			for (var i:int = 0; i < 8; i++) {
				var tower:Tower = new Tower(((i < 4) ? 15 : 53), (7 + 38 * (i % 4)), towerNames[i], false);
				towerSelectWindow.addChild(tower);
				
				if (i < 7) { towerSelectWindow.addChild(ImageFactory.createSimpleText(((i < 4) ? 1 : 85), tower.y, 14, 32, String(i + 1), 10, 0xffffff)); }
			}
			
			addChild(towerSelectWindow);
		}
		
		// タワーのステータスを表示するウインドウを作成する
		private function setupTowerStatsWindow():void {
			_towerStatsWindow = ImageFactory.createWindow(370, 160, 90, 250);
			
			_towerStatsWindow.addChild(ImageFactory.createWindow(0, 0, 90, 20));
			_towerStatsWindow.addChild(_name = ImageFactory.createSimpleText(0, 0, 90, 20, "Tower", 12, 0xffffff));
			
			_towerStatsWindow.addChild(_attlibuteGround = ImageFactory.createSimpleText(5, 25, 40, 10, "Ground", 10, 0xffffff));
			_towerStatsWindow.addChild(_attlibuteAir = ImageFactory.createSimpleText(5, 35, 40, 10, "Air", 10, 0xffffff));
			_towerStatsWindow.addChild(_attlibuteSlow = ImageFactory.createSimpleText(45, 25, 40, 10, "Slow", 10, 0x606060));
			_towerStatsWindow.addChild(_attlibuteSplash = ImageFactory.createSimpleText(45, 35, 40, 10, "Splash", 10, 0x606060));
			
			_towerStatsWindow.addChild(ImageFactory.createBorderedText(0, 50, 90, 10, "Rank", 10, 0xffffff, 0x00b000));
			_towerStatsWindow.addChild(_rank = ImageFactory.createStatsText(0, 62, 90, 15, "E", 14, 0x00ff00));
			
			_towerStatsWindow.addChild(ImageFactory.createBorderedText(0, 80, 90, 10, "Cost", 10, 0xffffff, 0xb0b000));
			_towerStatsWindow.addChild(_cost = ImageFactory.createStatsText(0, 92, 90, 15, "0", 14, 0xffff00));
			
			_towerStatsWindow.addChild(ImageFactory.createBorderedText(0, 110, 90, 10, "Damage", 10, 0xffffff, 0xf00000));
			_towerStatsWindow.addChild(_damage = ImageFactory.createStatsText(0, 122, 90, 15, "0", 14, 0xff0000));
			
			_towerStatsWindow.addChild(ImageFactory.createBorderedText(0, 140, 90, 10, "Range", 10, 0xffffff, 0x00b0b0));
			_towerStatsWindow.addChild(_range = ImageFactory.createStatsText(0, 152, 90, 15, "0", 14, 0x00ffff));
			
			_towerStatsWindow.addChild(ImageFactory.createBorderedText(0, 170, 90, 10, "FireRate", 10, 0xffffff, 0xb000b0));
			_towerStatsWindow.addChild(_fireRate = ImageFactory.createStatsText(0, 182, 90, 15, "0", 14, 0xff00ff));
			
			_towerStatsWindow.addChild(_towerMenuWindow = ImageFactory.createWindow(0, 200, 90, 50));
			var upgradeButton:PushButton = new PushButton(_towerMenuWindow, 5, 5, "Upgrade", clickUpdateButton);
			var sellButton:PushButton = new PushButton(_towerMenuWindow, 5, 25, "Sell", clickSellButton);
			upgradeButton.width = sellButton.width = 80;
			
			addChild(_towerStatsWindow);
			_towerStatsWindow.visible = false;
		}
		
		private function clickUpdateButton(e:MouseEvent):void {
			GameData.instance.selectedTower.upgrade();
			GameData.instance.setSelectedTower(GameData.instance.selectedTower);
		}
		
		// 売却ボタンを押した時の処理
		private function clickSellButton(e:MouseEvent):void {
			GameData.instance.selectedTower.sell();
			GameData.instance.setSelectedTower(null);
		}
		
		// レベルバーを表示するウインドウを配置する
		private function setupLevelBarWindow():void {
			var levelBarWindow:Sprite = ImageFactory.createWindow( -10, 415, 475, 50);
			
			/*
			var backgroundBar:Shape = new Shape();
			backgroundBar.graphics.beginFill(0x000000);
			backgroundBar.graphics.drawRect(0, 10, 475, 30);
			backgroundBar.graphics.endFill();
			levelBarWindow.addChild(backgroundBar);
			
			var hand:Shape = new Shape();
			hand.graphics.lineStyle(1, 0xffff00);
			hand.graphics.moveTo(45, 2);
			hand.graphics.lineTo(45, 48);
			levelBarWindow.addChild(hand);
			*/
			
			addChild(levelBarWindow);
		}
		
		// メニューウインドウを配置する
		private function setupMenuWindow():void {
			var menuWindow:Sprite = ImageFactory.createWindow(365, 415, 100, 50);
			
			//var pauseButton:PushButton = new PushButton(menuWindow, 5, 4, "Pause", null);
			//var nextLevelButton:PushButton = new PushButton(menuWindow, 5, 26, "Next Level", null);
			//pauseButton.width = nextLevelButton.width = 90;
			
			addChild(menuWindow);
		}
		
		// ゲーム情報の更新を反映する
		public function update(e:Event):void {
			updateMainStatsWindow();
			updateTowerStatsWindow();
		}
		
		// メインステータス表示を更新する
		private function updateMainStatsWindow():void {
			var data:GameData = GameData.instance;
			_level.text = data.level.toString();
			_score.text = data.score.toString();
			_lives.text = data.lives.toString();
			_gold.text = data.gold.toString();
		}
		
		// タワーのステータス表示を更新する
		private function updateTowerStatsWindow():void {
			_towerStatsWindow.visible = (GameData.instance.selectedTower != null);
			if (_towerStatsWindow.visible) {
				var selectedTower:Tower = GameData.instance.selectedTower;
				
				_towerMenuWindow.visible = selectedTower.active;
				_name.text = selectedTower.towerName + " Tower";
				var onColor:uint = 0xffffff;
				var offColor:uint = 0x606060;
				_attlibuteGround.textColor = (selectedTower.ground ? onColor : offColor);
				_attlibuteAir.textColor = (selectedTower.air ? onColor : offColor);
				_attlibuteSlow.textColor = (selectedTower.slow ? onColor : offColor);
				_attlibuteSplash.textColor = (selectedTower.splash ? onColor : offColor);
				
				_rank.text = selectedTower.rank + ((selectedTower.active && selectedTower.hasNextRank()) ? (" → " + selectedTower.nextRank) : "");
				_cost.text = selectedTower.cost + ((selectedTower.active && selectedTower.hasNextRank()) ? (" + " + (selectedTower.nextCost - selectedTower.cost)) : "");
				_damage.text = selectedTower.damage + ((selectedTower.active && selectedTower.hasNextRank()) ? (" + " + (selectedTower.nextDamage - selectedTower.damage)) : "");
				_range.text = selectedTower.range + ((selectedTower.active && selectedTower.hasNextRank()) ? (" + " + (selectedTower.nextRange - selectedTower.range)) : "");
				_fireRate.text = selectedTower.fireRate.toFixed(1) + ((selectedTower.active && selectedTower.hasNextRank()) ? (" + " + (selectedTower.nextFireRate - selectedTower.fireRate).toFixed(1)) : "");
			}
		}
	}
//}
//package {
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	
	//public 
	class GameData extends EventDispatcher {
		private static var _instance:GameData;
		
		private var _selectedTower:Tower;
		
		private var _level:int;
		private var _score:int;
		private var _lives:int;
		private var _gold:int;
		
		public function get selectedTower():Tower { return _selectedTower; }
		public function get level():int { return _level; }
		public function get score():int { return _score; }
		public function get lives():int { return _lives; }
		public function get gold():int { return _gold; }
		
		public function GameData(enforcer:SingletonEnforcer) {
			initialize();
		}
		
		public function initialize():void {
			_level = 0;
			_score = 0;
			_lives = Parameter.INITIAL_LIVES;
			_gold = Parameter.INITIAL_GOLD;
			
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		// 選択中のタワーを設定する
		public function setSelectedTower(tower:Tower):void {
			_selectedTower = tower;
			
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function damageLives():void {
			_lives--;
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		// 購入できるかどうか
		public function buyable(price:int):Boolean {
			return price <= _gold;
		}
		
		// ゴールドを得る
		public function earnGold(amount:int):void {
			_gold += amount;
			
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		// ゴールドを消費する
		public function spendGold(amount:int):void {
			_gold -= amount;
			
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		public static function get instance():GameData {
			if (GameData._instance == null) {
				_instance = new GameData(new SingletonEnforcer());
			}
			
			return _instance;
		}
	}
//}
class SingletonEnforcer { }
//package {
	import flash.geom.Point;
	
	//public 
	class Node {
		private var _tile:Point;
		private var _center:Point;
		
		private var _passable:Boolean;	// 敵が通れるかどうか
		private var _buildable:Boolean;	// タワーが建てられるかどうか
		private var _enemyNum:int;		// このノード上にいる敵の数
		
		public function get tileX():int { return _tile.x; }
		public function get tileY():int { return _tile.y; }
		public function get centerX():Number { return _center.x; }
		public function get centerY():Number { return _center.y; }
		
		public function get passable():Boolean { return _passable; }
		public function set passable(value:Boolean):void { _passable = value; }
		
		public function get buildable():Boolean { return _buildable && (_enemyNum == 0); }
		public function set buildable(value:Boolean):void { _buildable = value; };
		
		public function get enemyNum():int { return _enemyNum; }
		public function set enemyNum(value:int):void { _enemyNum = value; }
		
		public function Node(tilex:int, tiley:int, type:int) {
			_tile = new Point(tilex, tiley);
			var pos:Point = Node.positionFromTile(_tile);
			_center = new Point(pos.x + (Parameter.NODE_SIZE / 2), pos.y +(Parameter.NODE_SIZE / 2));
			switch(type) {
				case 0: _passable = true; _buildable = true; break;
				case 1: _passable = false; _buildable = false; break;
				case 2: _passable = true; _buildable = false; break;
			}
			_enemyNum = 0;
		}
		
		// タイル縦横値から、XY座標値を求める
		public static function positionFromTile(tile:Point):Point {
			var pos:Point = new Point();
			
			pos.x = tile.x * Parameter.NODE_SIZE;
			pos.x = Math.max(0, Math.min(pos.x, (Parameter.NODE_COLS - 1) * Parameter.NODE_SIZE));
			pos.y = tile.y * Parameter.NODE_SIZE;
			pos.y = Math.max(0, Math.min(pos.y, (Parameter.NODE_ROWS - 1) * Parameter.NODE_SIZE));
			
			return pos;
		}
		
		// XY座標値から、タイル縦横値を求める
		public static function tileFromPosition(pos:Point):Point {
			var tile:Point = new Point();
			
			tile.x = int(pos.x / Parameter.NODE_SIZE);
			tile.x = Math.max(0, Math.min(tile.x, Parameter.NODE_COLS - 1));
			tile.y = int(pos.y / Parameter.NODE_SIZE);
			tile.y = Math.max(0, Math.min(tile.y, Parameter.NODE_ROWS - 1));
			
			return tile;
		}
		
		// タワーが設置できるかどうか
		public static function buildable(posx:int, posy:int):Boolean {
			var tile:Point = Node.tileFromPosition(new Point(posx, posy));
			
			return (Main.nodes[tile.y][tile.x].buildable &&
			Main.nodes[tile.y + 1][tile.x].buildable &&
			Main.nodes[tile.y][tile.x + 1].buildable &&
			Main.nodes[tile.y + 1][tile.x + 1].buildable);
		}
		
		public static function changeBulidablity(towerTile:Point, buildable:Boolean):void {
			Main.nodes[towerTile.y][towerTile.x].buildable = buildable;
			Main.nodes[towerTile.y + 1][towerTile.x].buildable = buildable;
			Main.nodes[towerTile.y][towerTile.x + 1].buildable = buildable;
			Main.nodes[towerTile.y + 1][towerTile.x + 1].buildable = buildable;
		}
		
		public static function changePassablity(towerTile:Point, passable:Boolean):void {
			Main.nodes[towerTile.y][towerTile.x].passable = passable;
			Main.nodes[towerTile.y + 1][towerTile.x].passable = passable;
			Main.nodes[towerTile.y][towerTile.x + 1].passable = passable;
			Main.nodes[towerTile.y + 1][towerTile.x + 1].passable = passable;
		}
	}
//}
//package {
	import flash.geom.Point;
	
	//public 
	class Goal {
		private static const DX:Array = [0, -1, 1, 0, -1, 1, -1, 1];
		private static const DY:Array = [ -1, 0, 0, 1, -1, -1, 1, 1];
		private static const DCOST:Array = [1, 1, 1, 1, Math.SQRT2, Math.SQRT2, Math.SQRT2, Math.SQRT2];
		
		private var _node:Node;
		private var _openNodes:Array;			// 保留ノードリスト
		private var _nodeCost:Array;			// 各ノードの移動コスト
		private var _nodeNext:Array;			// 各ノードの次の経路となるノード
		private var _previousNodeCost:Array;	// 以前のnodeCost
		private var _previousNodeNext:Array;	// 以前のnodeNext
		
		public function get node():Node { return _node; }
		public function getCost(tile:Point):Number { return _nodeCost[tile.y][tile.x]; }
		public function getNext(tile:Point):Node { return _nodeNext[tile.y][tile.x]; }
		
		public function Goal(tile:Point) {
			_node = Main.nodes[tile.y][tile.x];
			_openNodes = [];
			_nodeCost = _nodeNext = null;
			
			search();
		}
		
		// ダイクストラ法による経路探索
		public function search():void {
			initialize();
			
			while (_openNodes.length > 0) {
				var subject:Node = _openNodes.pop() as Node;
				
				// 周囲8方向のノードを訪問する
				for (var i:int = 0; i < 8; i++) {
					// 画面外の存在しないノードを指すなら次の周囲ノードへ進む
					if (!isValid(subject.tileX + Goal.DX[i], subject.tileY + Goal.DY[i])) { continue; }
					// 通れないノード、計算済み（確定）ノード、直進することができないノードなら次の周囲ノードへ進む
					var test:Node = Main.nodes[subject.tileY + Goal.DY[i]][subject.tileX + Goal.DX[i]];
					if (isImpassable(test) || isCalculatedNode(test) || !canGoStraightTo(subject, test)) { continue; }
					
					// 移動コストを計算する
					_nodeCost[test.tileY][test.tileX] = _nodeCost[subject.tileY][subject.tileX] + Goal.DCOST[i];
					// 次の経路ノードをsubjectノードに設定する
					_nodeNext[test.tileY][test.tileX] = subject;
					// 保留ノードリストに追加する
					insertToOpenNodes(test);
				}
			}
		}
		
		private function initialize():void {
			_previousNodeCost = _nodeCost;
			_previousNodeNext = _nodeNext;
			
			_nodeCost = [];
			_nodeNext = [];
			for (var row:int = 0; row < Parameter.NODE_ROWS; row++) {
				_nodeCost[row] = [];
				_nodeNext[row] = [];
				for (var col:int = 0; col < Parameter.NODE_COLS; col++) {
					_nodeCost[row][col] = Number.MAX_VALUE;
					_nodeNext[row][col] = Main.nodes[row][col];
				}
			}
			
			// Goalのノードを経路探索のスタートノードとする
			_nodeCost[_node.tileY][_node.tileX] = 0;
			_openNodes.push(_node);
		}
		
		// indexの値が有効な値かどうか
		private function isValid(col:int, row:int):Boolean {
			return ((col >= 0) && (col < Parameter.NODE_COLS) && (row >= 0) && (row < Parameter.NODE_ROWS));
		}
		
		// 既にコストを計算済みのノードかどうか
		private function isCalculatedNode(node:Node):Boolean {
			return _nodeCost[node.tileY][node.tileX] != Number.MAX_VALUE;
		}
		
		// 通れないノードかどうか
		private function isImpassable(node:Node):Boolean {
			return !node.passable;
		}
		
		// subjectノードからtestノードへ直進できるかどうか
		private function canGoStraightTo(subject:Node, test:Node):Boolean {
			return (Main.nodes[subject.tileY][test.tileX].passable && Main.nodes[test.tileY][subject.tileX].passable);
		}
		
		// nodeを保留ノードリストの適切な場所に挿入する
		private function insertToOpenNodes(node:Node):void {
			var insertIndex:int;
			var len:int = _openNodes.length;
			var nodeCost:Number = _nodeCost[node.tileY][node.tileX];
			
			for (insertIndex = 0; insertIndex < len; insertIndex++) {
				var openNode:Node = _openNodes[insertIndex];
				if (nodeCost > _nodeCost[openNode.tileY][openNode.tileX]) { break; }
			}
			_openNodes.splice(insertIndex, 0, node);
		}
		
		// 一つ前の状態を復元する
		public function revertToPrevious():void {
			_nodeCost = _previousNodeCost;
			_nodeNext = _previousNodeNext;
		}
		
		// 指定した位置から最も近いゴールを取得する
		public static function getNearestGoalFrom(tile:Point):Goal {
			var goals:Array = Main.goals;
			var nearest:Goal = goals[0];
			
			var len:int = goals.length;
			for (var i:int = 1; i < len; i++) {
				if (goals[i].getCost(tile) < nearest.getCost(tile)) {
					nearest = goals[i];
				}
			}
			
			return nearest;
		}
		
		// 最探索し、成功したかどうかを返す
		public static function reSearch(towerTile:Point):Boolean {
			Node.changePassablity(towerTile, false);
			
			var i:int;
			for (i = 0; i < Main.goals.length; i++) {
				Main.goals[i].search();
			}
			
			var hasPathAllEnemy:Boolean = true;
			for (i = 0; i < Main.enemies.length; i++) {
				Main.enemies[i].updateNearestGoal();
				
				if (!Main.enemies[i].hasPathToGoal()) {
					hasPathAllEnemy = false;
					break;
				}
			}
			
			Node.changePassablity(towerTile, true);
			if (hasPathAllEnemy) {
				return true;
			// ブロッキングしていたら全部元に戻す
			}else {
				for (i = 0; i < Main.goals.length; i++) {
					Main.goals[i].revertToPrevious();
				}
				
				for (i = 0; i < Main.enemies.length; i++) {
					Main.enemies[i].updateNearestGoal();
				}
				
				return false;
			}
		}
	}
//}
//package {
	import flash.display.*;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	//public 
	class Tower extends Sprite {
		private var _center:Point;
		
		private var _name:String;
		private var _rank:int;
		private var _attlibutes:Object;
		private var _currentStats:Object;
		private var _nextStats:Object;
		private var _active:Boolean;
		
		private var _target:Enemy;
		private var _reloadSpeed:Number;	// 毎フレームのカウントの上昇値
		private var _reloadCount:Number;	// この値が100を超えたら発射可能
		
		private var _image:Sprite;
		
		public function get towerName():String { return _name; }
		
		public function get ground():Boolean { return _attlibutes.ground; }
		public function get air():Boolean { return _attlibutes.air; }
		public function get slow():Boolean { return _attlibutes.slow; }
		public function get splash():Boolean { return _attlibutes.splash; }
		
		public function get rank():String { return _currentStats.rank; }
		public function get cost():int { return _currentStats.cost; }
		public function get damage():int { return _currentStats.damage; }
		public function get range():int { return _currentStats.range; }
		public function get fireRate():Number { return _currentStats.firerate; }
		
		public function get nextRank():String { return _nextStats.rank; }
		public function get nextCost():int { return _nextStats.cost; }
		public function get nextDamage():int { return _nextStats.damage; }
		public function get nextRange():int { return _nextStats.range; }
		public function get nextFireRate():Number { return _nextStats.firerate; }
		
		public function get active():Boolean { return _active; }
		
		public function Tower(posx:int, posy:int, name:String, active:Boolean) {
			x = posx;
			y = posy;
			
			_center = new Point(posx + Parameter.TOWER_SIZE / 2, posy + Parameter.TOWER_SIZE / 2);
			_name = name;
			_rank = 0;
			_attlibutes = Parameter.getTowerAttlibutes(_name);
			_currentStats = Parameter.getTowerStats(_name, _rank);
			_nextStats = Parameter.getTowerStats(_name, _rank + 1);
			_active = active;
			
			if (active) {
				_target = null;
				_reloadSpeed = _currentStats.firerate * 100 / Parameter.FRAMERATE; 
				_reloadCount = 0;
				
				var tile:Point = Node.tileFromPosition(new Point(x, y));
				Node.changePassablity(tile, false);
				Node.changeBulidablity(tile, false);
			}
			
			draw();
			
			buttonMode = true;
			addEventListener(MouseEvent.CLICK, selected);
		}
		
		// タワーの画像を描画する
		private function draw():void {
			addChild(new Bitmap(ImageFactory.getTowerBase()));
			
			_image = new Sprite();
			var bitmap:Bitmap = new Bitmap((_name != "Cancel") ? ImageFactory.getImage(_name) : ImageFactory.getCancelMark(), "auto", true);
			bitmap.x = bitmap.y = int( -Parameter.TOWER_IMAGE_SIZE / 2);
			_image.x  = _image.y = int(Parameter.TOWER_SIZE / 2);
			_image.addChild(bitmap);
			addChild(_image);
			
			if (active) { _image.rotation = int(350 * Math.random() - 175); }
		}
		
		public function update():void {
			// ターゲット無しかターゲットがやられていたら、新しいターゲットを探す
			if (_target == null || _target.hp <= 0) {
				for (var i:int = 0; i < Main.enemies.length; i++) {
					var diffX:Number = _center.x - Main.enemies[i].posX;
					var diffY:Number = _center.y - Main.enemies[i].posY;
					if (Math.sqrt(diffX * diffX + diffY * diffY) < _currentStats.range) {
						_target = Main.enemies[i];
						break;
					}
				}
			}
			
			// ターゲットがいるなら、
			// 射程内ならターゲットの方を向き、射程外ならターゲットからはずす
			if (_target != null) {
				diffX = _target.posX - _center.x;
				diffY = _target.posY - _center.y;
				if (Math.sqrt(diffX * diffX + diffY * diffY) < _currentStats.range) {
					var degree:Number = Math.atan2(diffY, diffX) * 180 / Math.PI;
					_image.rotation = degree;
				}else {
					_target = null;
				}
			}
			
			// 弾を発射できるなら発射する
			_reloadCount += _reloadSpeed;
		}
		
		// タワーアップグレード時の処理
		public function upgrade():void {
			if (hasNextRank() && GameData.instance.buyable(_nextStats.cost - _currentStats.cost)) {
				GameData.instance.spendGold(_nextStats.cost - _currentStats.cost);
				
				_rank++;
				_currentStats = _nextStats;
				_nextStats = Parameter.getTowerStats(_name, _rank + 1);
				
				_reloadSpeed = _currentStats.firerate * 100 / Parameter.FRAMERATE;
			}
		}
		
		// 次のランクがあるかどうか
		public function hasNextRank():Boolean {
			return _nextStats != null;
		}
		
		// タワー売却時の処理
		public function sell():void {
			parent.removeChild(this);
			var tile:Point = Node.tileFromPosition(new Point(x, y));
			Node.changePassablity(tile, true);
			Node.changeBulidablity(tile, true);
			Main.towers.splice(Main.towers.indexOf(this), 1);
			GameData.instance.earnGold(int(_currentStats.cost * Parameter.TOWER_SELL_RATE));
		}
		
		private function selected(e:MouseEvent):void {
			GameData.instance.setSelectedTower((_name != "Cancel") ? this : null);
		}
	}
//}
//package {
	import flash.display.*;
	import flash.geom.Point;
	
	//public 
	class Enemy extends Sprite {
		private var _position:Point;
		private var _velocity:Point;
		
		private var _hp:int;			// ヒットポイント
		private var _bounty:int;		// 倒して得る金
		private var _speed:Number;		// 速さ（スカラー）
		
		private var _immunity:Boolean;	// 免疫が有るか
		private var _slowing:int;		// スロー状態かどうか
		private var _isFlying:Boolean;	// 飛行しているか
		
		private var _currentNode:Node;	// 現在のノード
		private var _nearestGoal:Goal;	// 最短で到達できるゴールノード
		private var _nextNode:Node;		// 次に進むべきノード
		
		private var _image:Sprite;
		
		public function get posX():Number { return _position.x; }
		public function get posY():Number { return _position.y; }
		public function get hp():int { return _hp; }
		
		public function Enemy(pos:Point, stats:Object) {
			_position = pos;
			
			_hp = stats.hp;
			_bounty = stats.bounty;
			_speed = stats.speed;
			
			_immunity = false;
			_slowing = 0;
			_isFlying = false;
			
			initializeVelocity();
			
			var tile:Point = Node.tileFromPosition(_position);
			initializeCurrentNode(tile);
			initializeNearestGoal(tile);
			initializeNextNode(tile);
			
			draw();
		}
		
		private function initializeVelocity():void {
			if (_isFlying) {
				_velocity = new Point(0, -_speed);
			}else {
				_velocity = new Point();
			}
		}
		
		private function initializeCurrentNode(tile:Point):void {
			_currentNode = Main.nodes[tile.y][tile.x];
			if (!_isFlying) { _currentNode.enemyNum++; }
		}
		
		private function initializeNearestGoal(tile:Point):void {
			if (_isFlying) {
				_nearestGoal = Main.nodes[4][tile.x];
			}else {
				_nearestGoal = Goal.getNearestGoalFrom(tile);
			}
		}
		
		private function initializeNextNode(tile:Point):void {
			if (_isFlying) {
				_nextNode = _nearestGoal.node;
			}else {
				_nextNode = _nearestGoal.getNext(tile);
			}
		}
		
		private function draw():void {
			_image = new Sprite();
			var bitmap:Bitmap = new Bitmap(ImageFactory.getEnemy("Normal"));
			bitmap.x = bitmap.y = int( -Parameter.NODE_SIZE / 2);
			_image.rotation = -90;
			_image.addChild(bitmap);
			addChild(_image);
		}
		
		public function update():void {
			if (_hp <= 0) {
				GameData.instance.earnGold(_bounty);
				vanish();
				return;
			}
			
			var tile:Point = Node.tileFromPosition(_position);
			
			// ゴールに着いたら、ライフが減って敵消滅
			if (arrivedGoal(tile)) {
				GameData.instance.damageLives();
				vanish();
				return;
			}
			
			move(tile);
			veer(tile);
		}
		
		// 消滅する
		private function vanish():void {
			if (!_isFlying) { _currentNode.enemyNum--; }
			parent.removeChild(this);
			Main.enemies.splice(Main.enemies.indexOf(this), 1);
		}
		
		// 移動する
		private function move(tile:Point):void {
			var slowed:Boolean = (_slowing > 0);
			if (slowed) { _slowing--; }
			
			x = (_position.x += (slowed ? _velocity.x / 2 : _velocity.x));
			y = (_position.y += (slowed ? _velocity.y / 2 : _velocity.y));
		}
		
		// 進行方向の修正
		private function veer(tile:Point):void {
			if (!_isFlying) {
				//次に進むべきノードへ到着していたら、次に進むべきノードを更新する
				if (arrivedNextNode(tile)) {
					_currentNode.enemyNum--;
					_nextNode.enemyNum++;
					
					_currentNode = _nextNode;
					updateNextNode(tile); 
				}
				
				var radian:Number = Math.atan2(_nextNode.centerY - _position.y, _nextNode.centerX - _position.x);
				_velocity.x = (_velocity.x + _speed * Math.cos(radian)) * 0.5;
				_velocity.y = (_velocity.y + _speed * Math.sin(radian)) * 0.5;
				
				var degree:Number = radian * 180 / Math.PI;
				_image.rotation = degree;
			}
		}
		
		// 最短で到達できるゴールノードを更新する
		public function updateNearestGoal():void {
			var tile:Point = Node.tileFromPosition(_position);
			_nearestGoal = Goal.getNearestGoalFrom(tile);
			
			updateNextNode(tile);
		}
		
		// 次に進むべきノードを更新する
		private function updateNextNode(tile:Point):void {
			_nextNode = _nearestGoal.getNext(tile);
		}
		
		// ゴールへ向かう経路が存在しているかどうか
		public function hasPathToGoal():Boolean {
			return _currentNode != _nextNode;
		}
		
		// ゴールノードへ到着しているかどうか
		private function arrivedGoal(tile:Point):Boolean {
			return (tile.x == _nearestGoal.node.tileX) && (tile.y == _nearestGoal.node.tileY);
		}
		
		// 次に進むべきノードへ到着しているかどうか
		private function arrivedNextNode(tile:Point):Boolean {
			return  (tile.x == _nextNode.tileX) && (tile.y == _nextNode.tileY);
		}
		
		// ダメージを受ける
		public function damaged(amount:int, slow:Boolean):void {
			_hp -= amount;
			if (slow) { slowed(); }
		}
		
		// 移動が遅くなる（免疫が無ければ）
		private function slowed():void {
			if (!_immunity) { _slowing = Parameter.SLOWING_TIME; }
		}
	}
//}
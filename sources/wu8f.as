// forked from nengafl's nengafl
/**=====================================================
 * マップを変えたり、勇者の画像を差し替えたり、パーティーメンバーを追加したりして、
 * あなたのQuestを自由に作ってみてください。
 * なお、このコードで使用されているすべての画像は、著作権フリーとします。
 * 商用・非商用に関わらず、好きに使ってください。
 * 
 * [遊び方]
 * はじめに、マップをクリックして...
 * ↑ , w :	上に移動
 * ↓ , s :	下に移動
 * ← , a :	左に移動
 * → , d :	右に移動
 * 
 * [ヒント]
 * mapData（81～97行目）をいじると、マップを変えることができます。
 * ===================================================== */
package 
{
    import flash.display.*;
	import flash.events.*;
	import flash.geom.Point;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;

	[SWF(width="465", height="465", frameRate="30", backgroundColor="0x000000")]
	public class WonderflQuest extends Sprite 
	{
		private const SIZE:Number = 465;//ステージの大きさ
		private const SCALE:Number = 3; //勇者やフィールドの拡大率
		private const SPEED:Number = 6;	//勇者が歩くスピード FLDSIZEの約数にしてください
		private const MAPSIZE:uint = 16;//マップの横・縦のマスの個数
		private const FLDSIZE:uint = 48;//フィールド（マップ上の1マス）の横・縦のドット数
		
		private var yuusha:Yuusha;		//勇者
		private var yuushaPos:Point;	//勇者のマップ上の座標
		private var map:Sprite;			//マップ本体　これを動かして勇者が移動しているように見せる
		private var bMapData:Array = [];//フィールドが障害物か否かを記憶
		private var frameCount:Number = 0;	//onEnterFrameで使用
		private var keyFlags:Array = [false, false, false, false]; //下上左右のキーが押されているか
		private var walkDirection:int = 4;	//歩いていく方向 （0～3：下上左右  4:止）
		private var loaded:int = 0;		//読み込み完了した画像の個数
		private var isInit:Boolean = false;	//初期化されているか　onEnterFrameで使用
		private var prgSpr:Sprite;		//ロード画面表示用
		
		/**-----------------------------------------------------
		 * マップの1マス（フィールド）のリストです。
		 * ここをいじると好きな画像をマップ上に貼ることができます。
		 * 画像のサイズは、基本的に16*16ピクセルです。
		 * 形式はjpeg,gif,pngのどれかにしてください。
		 * Twitterのアイコン画像取得は、こちらのAPIを使わせてもらってます。
		 * http://usericons.relucks.org/
		 * ----------------------------------------------------- */
		private const fieldList:Array = [
			new Field("http://flash-scope.com/wonderfl/WonderflQuest/map/map0.png", false),	//[ 0]: 芝生
			new Field("http://flash-scope.com/wonderfl/WonderflQuest/map/map1.png", false),	//[ 1]: 砂
			new Field("http://flash-scope.com/wonderfl/WonderflQuest/map/map2.png", false),	//[ 2]: 石畳
			new Field("http://flash-scope.com/wonderfl/WonderflQuest/map/map3.png", false),	//[ 3]: フローリング
			new Field("http://flash-scope.com/wonderfl/WonderflQuest/map/map4.png", false),	//[ 4]: 橋（縦）
			new Field("http://flash-scope.com/wonderfl/WonderflQuest/map/map5.png", false),	//[ 5]: 橋（横）
			new Field("http://flash-scope.com/wonderfl/WonderflQuest/map/map6.png", true),	//[ 6]: 木（小）
			new Field("http://flash-scope.com/wonderfl/WonderflQuest/map/map7.png", true),	//[ 7]: 木（大）
			new Field("http://flash-scope.com/wonderfl/WonderflQuest/map/map8.png", true),	//[ 8]: サボテン
			new Field("http://flash-scope.com/wonderfl/WonderflQuest/map/map9.png", true),	//[ 9]: 水
			new Field("http://flash-scope.com/wonderfl/WonderflQuest/map/map10.png", true),	//[10]: 壁（石）
			new Field("http://flash-scope.com/wonderfl/WonderflQuest/map/map11.png", true),	//[11]: 壁（木）
			new Field("http://flash-scope.com/wonderfl/WonderflQuest/map/map12.png", true),	//[12]: 壁（武器屋）
			new Field("http://flash-scope.com/wonderfl/WonderflQuest/map/map13.png", true),	//[13]: 壁（防具屋）
			new Field("http://flash-scope.com/wonderfl/WonderflQuest/map/map14.png", true),	//[14]: 壁（宿屋）
			new Field("http://flash-scope.com/wonderfl/WonderflQuest/map/map15.png", true),	//[15]: 壺
			new Field("http://flash-scope.com/wonderfl/WonderflQuest/map/map16.png", true),	//[16]: タンス
			new Field("http://flash-scope.com/wonderfl/WonderflQuest/map/map17.png", true),	//[17]: 石像
			new Field("http://flash-scope.com/wonderfl/WonderflQuest/map/map18.png", true),	//[18]: 真っ暗
			new Field("http://usericons.relucks.org/twitter/osamX", false)					//[19]: Twitterアイコン
		];
		
		/**-----------------------------------------------------
		 * マップのデータ（ここが木で、あそこが芝生で．．．ってやつ）が入ってます。
		 * ここをいじると、マップが変わります。上のfieldListのコメント参照。
		 * ----------------------------------------------------- */
		private const mapData:Array = 
			[[ 0, 6, 9,18,10,10,10,10,10,18, 2,18,11,11,11,11],
			 [ 0, 0, 9,18,16,16, 2, 2, 2,18, 2,18, 3, 3,15,16],
			 [ 0, 0, 9,18, 2, 2, 2, 2, 2,18, 2,18, 3, 3, 3, 3],
			 [ 7, 0, 9,18, 2, 2, 2, 2, 2,18, 2,18, 3, 3, 3, 3],
			 [ 0, 0, 9,18,10,10,10,10, 2,13, 2,14, 3,11,11,11],
			 [ 0, 0, 9,18, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2],
			 [ 0, 0, 9,18, 2, 2, 2, 2, 2, 2, 2,12,10,10,10,10],
			 [ 0, 0, 9,18, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,16],
			 [ 0, 0, 9,18, 2, 2, 2, 2, 2, 2, 2,18, 2, 2, 2, 2],
			 [ 1, 0, 9,18,19,15, 2,17, 2, 2,17,18, 2, 2, 2, 2],
			 [ 1, 1, 9,10,10,10,10,10, 2, 2,10,10,10,10,10,10],
			 [ 1, 1, 9, 9, 9, 9, 9, 9, 4, 4, 9, 9, 9, 9, 9, 9],
			 [ 1, 1, 0, 0, 0, 9, 9, 0, 0, 0, 0, 6, 0, 0, 0, 7],
			 [ 1, 1, 1, 0, 0, 5, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0],
			 [ 8, 1, 1, 1, 9, 9, 9, 9, 0, 0, 1, 1, 0, 0, 6, 0],
			 [ 1, 1, 1, 9, 9, 9, 9, 9, 9, 9, 9, 9, 1, 1, 1, 0]];
		
		/**-----------------------------------------------------
		 * コンストラクタ。　ここが最初に処理されます。
		 * ----------------------------------------------------- */
		public function WonderflQuest():void 
		{	
			prgSpr = new Sprite();//ロード画面
			addChild(prgSpr);
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);//イベントリスナーの登録
			
			createMap();			//マップを作る
			
			yuusha = new Yuusha();	//勇者を作る
			yuusha.scaleX = yuusha.scaleY = SCALE;	//勇者を拡大表示
			yuusha.x = yuusha.y = (SIZE-FLDSIZE)/2; //中央に配置
			
			yuushaPos = new Point(8 * FLDSIZE, 8 * FLDSIZE);//勇者初期位置
			moveMap(yuushaPos);		//マップ移動
		}
		
		/**-----------------------------------------------------
		 * 毎フレームの処理。
		 * ----------------------------------------------------- */
		private function onEnterFrame(event:Event):void {
			if (loaded < MAPSIZE * MAPSIZE) { //フィールドの画像読み込み未完了なら
				drawPrg();
				return; //これ以下を処理しない
			}
			
			//画像読み込み完了後　1回だけ処理
			if (!isInit) {
				removeChild(prgSpr);//ロード画面非表示
				prgSpr = null;
				stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);	//イベントリスナーの登録
				stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);		//イベントリスナーの登録
				addChild(map);		//マップ表示
				addChild(yuusha);	//勇者表示
				isInit = true;
			}
			
			//15フレーム毎に処理する
			if (frameCount++ > 10) {
				frameCount = 0;
				yuusha.walk();
			}
			
			//マップ（勇者）をどの方向に動かすか判定
			if (yuushaPos.x % FLDSIZE == 0 && yuushaPos.y % FLDSIZE == 0) {
				var mapPosX:int = int(yuushaPos.x / FLDSIZE), mapPosY:int = int(yuushaPos.y / FLDSIZE);
				walkDirection = 4; 		//止まる
				switch(true) {
					case keyFlags[0]:	//下
						if(yuushaPos.y < (MAPSIZE-1)*FLDSIZE && !bMapData[mapPosY+1][mapPosX]) walkDirection=0;
						yuusha.changeDirection(0);
						break;
					case keyFlags[1]:	//上
						if(yuushaPos.y > 0 && !bMapData[mapPosY-1][mapPosX]) walkDirection=1;
						yuusha.changeDirection(1);
						break;
					case keyFlags[2]:	//左
						if(yuushaPos.x > 0 && !bMapData[mapPosY][mapPosX-1]) walkDirection=2;
						yuusha.changeDirection(2);
						break;
					case keyFlags[3]:	//右
						if(yuushaPos.x < (MAPSIZE-1)*FLDSIZE && !bMapData[mapPosY][mapPosX+1]) walkDirection=3;
						yuusha.changeDirection(3);
						break;
				}
			}
			
			//次のマスまで自動的に勇者を歩かせる
			switch(walkDirection) {
				case 0:
					yuushaPos.y += SPEED;
					break;
				case 1:
					yuushaPos.y -= SPEED;
					break;
				case 2:
					yuushaPos.x -= SPEED;
					break;
				case 3:
					yuushaPos.x += SPEED;
					break;
			}
			if (walkDirection < 4) moveMap(yuushaPos);
		}
		
		/**-----------------------------------------------------
		 * キーボードのキーが押された時の処理。
		 * ----------------------------------------------------- */
		private function onKeyDown(event:KeyboardEvent):void {
			switch(event.keyCode) {
				case 40: case 83:	//↓ s
					keyFlags[0] = true;
			}
			switch(event.keyCode) {
				case 38: case 87:	//↑ w
					keyFlags[1] = true;
			}
			switch(event.keyCode) {
				case 37: case 65:	//← a
					keyFlags[2] = true;
			}
			switch(event.keyCode) {
				case 39: case 68:	//→ d
					keyFlags[3] = true;
			}
		}
		
		/**-----------------------------------------------------
		 * キーボードのキーが離された時の処理。
		 * ----------------------------------------------------- */
		private function onKeyUp(event:KeyboardEvent):void {
			switch(event.keyCode) {
				case 40: case 83:	//↓ s
					keyFlags[0] = false;
			}
			switch(event.keyCode) {
				case 38: case 87:	//↑ w
					keyFlags[1] = false;
			}
			switch(event.keyCode) {
				case 37: case 65:	//← a
					keyFlags[2] = false;
			}
			switch(event.keyCode) {
				case 39: case 68:	//→ d
					keyFlags[3] = false;
			}
		}
		
		/**-----------------------------------------------------
		 * マップを作ります。
		 * この実装方法は良くないです。遅いし、何回も同じ画像をロードしてます。
		 * 画像が別ドメインにある時に、crossdomain.xmlがなくても大丈夫なようにしています。
		 * ----------------------------------------------------- */
		private function createMap():void {
			map = new Sprite();
			for (var k:uint = 0; k < MAPSIZE; k++) bMapData[k] = []; //bMapDataを2次元配列にする
			
			for (var j:uint = 0; j < MAPSIZE; j++) {
				for (var i:uint = 0; i < MAPSIZE; i++) {
					var loader:Loader = new Loader();
					var field:Field = fieldList[mapData[j][i]];
					loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void{loaded++;}); //ロード完了したらloadedをカウントアップ
					loader.load(new URLRequest(field.url), new LoaderContext(true));
					loader.x = FLDSIZE * i;
					loader.y = FLDSIZE * j;
					loader.scaleX = loader.scaleY = SCALE;
					if (mapData[j][i] == 19) loader.scaleX = loader.scaleY = FLDSIZE / 73; //Twitterのアイコンの時
					map.addChild(loader);
					bMapData[j][i] = field.isObstacle;
				}
			}
		}
		
		/**-----------------------------------------------------
		 * マップの座標計算。
		 * ----------------------------------------------------- */
		private function moveMap(pos:Point):void {
			map.x = (SIZE-FLDSIZE)/2 - yuushaPos.x;
			map.y = (SIZE-FLDSIZE)/2 - yuushaPos.y;
		}
		
		/**-----------------------------------------------------
		 * ロード画面を描く。
		 * ----------------------------------------------------- */
		private function drawPrg():void {
			var side:Number = SIZE / MAPSIZE,
				yy:int = int(loaded / MAPSIZE),
				xx:int = loaded - yy * MAPSIZE,
				max:int = MAPSIZE;
			prgSpr.graphics.clear();
			prgSpr.graphics.beginFill(0xFFFFFF);
			prgSpr.graphics.drawRect(0, 0, SIZE, yy * side);
			if(yy%2)prgSpr.graphics.drawRect((MAPSIZE-xx)*side, yy*side, SIZE, side);
			else	prgSpr.graphics.drawRect(0, yy*side, xx*side, side);
			prgSpr.graphics.endFill();
		}
		
	}
}

import flash.display.Sprite;
import flash.display.Loader;
import flash.net.URLRequest;
import flash.system.LoaderContext;

/**-----------------------------------------------------
 * 勇者クラスです。勇者を作ったり、足踏させたり、向きを変えたりします。
 * ----------------------------------------------------- */
class Yuusha  extends Sprite {
	public var direction:int = 0;		//向き　（0:前　1：後　2：左　3：右）
	private var walkFlag:Boolean = true;//足踏み用
	private var yuushaImages:Array = [];//勇者の画像集
	
	/**-----------------------------------------------------
	 * コンストラクタ。
	 * ----------------------------------------------------- */
	public function Yuusha():void {
		for (var i:uint = 0; i < 8; i++) {
			var loader:Loader = new Loader();
			loader.load(new URLRequest(ImageURL[i]), new LoaderContext(true));
			yuushaImages.push(loader);
			if(i) yuushaImages[i].visible = false;
			addChild(yuushaImages[i]);
		}
	}
	
	/**-----------------------------------------------------
	 * 勇者の画像のURLリスト
	 * ----------------------------------------------------- */
	private const ImageURL:Array = [
		"http://flash-scope.com/wonderfl/WonderflQuest/yuusha/yuushaF1.png",	//前向き1
		"http://flash-scope.com/wonderfl/WonderflQuest/yuusha/yuushaF2.png",	//前向き2
		"http://flash-scope.com/wonderfl/WonderflQuest/yuusha/yuushaB1.png",	//後ろ向き1
		"http://flash-scope.com/wonderfl/WonderflQuest/yuusha/yuushaB2.png",	//後ろ向き2
		"http://flash-scope.com/wonderfl/WonderflQuest/yuusha/yuushaL1.png",	//左向き1
		"http://flash-scope.com/wonderfl/WonderflQuest/yuusha/yuushaL2.png",	//左向き2
		"http://flash-scope.com/wonderfl/WonderflQuest/yuusha/yuushaR1.png",	//右向き1
		"http://flash-scope.com/wonderfl/WonderflQuest/yuusha/yuushaR2.png"		//右向き2
	];
	
	/**-----------------------------------------------------
	 * 足踏みさせます。
	 * ----------------------------------------------------- */
	public function walk():void {
		walkFlag = !walkFlag;
		for (var i:uint = 0; i < 8; i++) {
			if (i == 2*direction+int(walkFlag)) yuushaImages[i].visible = true;
			else yuushaImages[i].visible = false;
		}
	}
	
	/**-----------------------------------------------------
	 * 向きを変更します。
	 * numは勇者の向きを表します。（0～3）
	 * ----------------------------------------------------- */
	public function changeDirection(num:int):void {
		direction = num;
		for (var i:uint = 0; i < 8; i++) {
			if (i == 2*direction+int(walkFlag)) yuushaImages[i].visible = true;
			else yuushaImages[i].visible = false;
		}
	}
}

/**-----------------------------------------------------
 * Fieldクラスです。画像のURLと、そのフィールドが障害物か否かを保存します。
 * ----------------------------------------------------- */
class Field {
	public var url:String;			//画像のURL
	public var isObstacle:Boolean;	//障害物か否か （true:障害物　　false:障害物じゃない（歩ける））
	
	public function Field(s:String, b:Boolean = false):void {
		url = s;
		isObstacle = b;
	}
}
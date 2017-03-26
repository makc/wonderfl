/*
   リセットボタン追加
   ランキング表示機能追加
   Twitterに投稿されている点数からランキングを計算

   普通のブロック崩しです。
   最初からあるボールが落ちるとGameOverです。
   高得点目指して頑張ってください。
   結果はTwitterでつぶやけます。

   アイテム
   星: 星型のボールになります。
   ハート: 反射バーの大きさの変更
 */

package
{
	import __AS3__.vec.Vector;
	import com.adobe.serialization.json.JSON;
	import com.bit101.components.PushButton;
	import net.wonderfl.utils.SequentialLoader;
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.net.*;
	import flash.system.Security;
	import flash.text.*;
	import flash.utils.escapeMultiByte;
	
	import org.si.sion.*;

	[SWF(backgroundColor=0x00f0f, width=465, height=465, frameRate=60)]
	public class BreakBlock extends Sprite
	{
		
		//背景画像読み込み用	
		private var imageArray:Array=[];
		private var imageUrl:String="http://assets.wonderfl.net/images/related_images/1/16/162f/162fabe272eae4e0e084575ac63ac9545f4e2bd2";
		//private var imageUrl:String="pic3.jpg";
		//private var imageLoader:Loader;

		//Twitter用
		private var postUrl:String="http://twitter.com/home?status=";
		private var wonderflUrl:String="http://bit.ly/9xsPLp %23StardustBreakout";
		//状態　0:ゲーム中、1:Not Clear, 2:Clear
		public var status:int;

		public static const W:Number=388; // ゲームステージの幅
		public static const H:Number=465; // ゲームステージの高さ
		public static const ITEM_PROBABILITY:Number=0.3; //アイテムの出る確率
		public static const STAR_PROBABILITY:Number=0.7;
		public static const HEART_PROBABILITY:Number=0.3;
		public static const FAIL:String="fail"; //FAILイベント
		public static const CLEAR:String="clear"; //clearイベント
		public static const block_row:int=10; // ブロックの行数
		public static const block_column:int=10; // ブロックの列数
		public static const block_width:Number=38.9; // ブロックの幅
		public static const block_height:Number=15.5; //ブロックの高さ
		public static const bar_width:Number=62; //反射バーの幅
		public static const bar_height:Number=15.5; //反射バーの高さ
		public static const ball_size:Number=4; //ボールのサイズ
		private static const SPEED:Number=6; //メインの球のスピード
		private static const BLOCK_COLOR:uint=0x0000ff; //ブロックの色

		private var score:int=0; //スコア
		private var ball_bmp:Bitmap; // 表示用Bitmap
		private var block_bmp:Bitmap; //Blockを描くBitmap
		private var block_bmpData:BitmapData;
		private var ball_bmpData:BitmapData; // canvasの内容を記録するためのBitmapData
		private var counter:TextField; // カウントフィールド
		private var message:TextField; // メッセージフィールド
		private var scoreTxt:TextField; //スコアフィールド
		private var clickStart:TextField; //クリックスタート
		private var rankTxt:TextField;
		private var remainBall:int;
		private var block_count:int;
		public var ball_canvas:Sprite; // Ballなどを描画するSprite
		public var block_canvas:Sprite; //Blockを描くSprite
		public var BlockList:Vector.<Block>; // ブロック格納配列
		public var bar:Bar // ボード

		public var ballNum:int;
		public var soundDriver:SiONDriver;
		//BGM
		private var data:SiONData;
		private var bgm:SoundChannel;
		//効果音
		public var se:SiONData;


		//キラキラのためのもの
		private var glow_bmpData:BitmapData;
		private var glowMtx:Matrix;
		private var particle_bmpData:BitmapData;
		//キラキラパーティクルを格納する配列
		public var particleList:Vector.<Particle>;

		//ランキングの取得用
		//現在読み込んでいるページ数
		private var page:int=1;
		//１ページの要素数
		private var rpp:int=100;
		private var twitterLoader:URLLoader;
		private var rankUrl:String = "http://search.twitter.com/search.json?q=%23StardustBreakout";
		private var ary:Array=[];

		private var rank:int=0;
		private var userNum:int=0;

		private var resetBtn:PushButton;
		private var twitBtn:PushButton;
		public var expFlg:int=0;

		public function BreakBlock()
		{
			status=0;
			ballNum=0;
			soundDriver=new SiONDriver();

			//コンパイル
			data=soundDriver.compile("t80o7l8r10[g>b<f+>b<d>b<e>b<f+>b<e>b<d>b<e>b<g>b<f+>b<d>b<e>b<f+>b<e>b<d>b<e>b<g>b<f+>b<d>b<e>b<f+>b<e>b<d>b<e>b<g>b<f+>b<d>b<e>b<f+>b<e>b<d>b<e>b<g>b<f+>b<d>b<e>b<f+>b<e>b<d>b<e>b<g>b<f+>b<d>b<e>b<f+>b<e>b<d>b<e>b<g>b<f+>b<d>b<e>b<f+>b<e>b<d>b<e>b<g>b<f+>b<d>b<e>b<f+>b<e>b<d>b<e>b<g>b<f+>b<d>b<e>b<f+>b<e>b<d>b<e>b<g>b<f+>b<d>b<e>b<f+>b<e>b<d>b<e>b<g>b<f+>b<d>b<e>b<f+>b<e>b<d>b<e>b<g>b<f+>b<d>b<e>b<f+>b<e>b<d>b<e>b<g>b<f+>b<d>b<e>b<f+>b<e>b<d>b<e>b<g>b<f+>b<d>b<e>b<f+>b<e>b<d>b<e>b<g>b<f+>b<d>b<e>b<f+>b<e>b<d>b<e>b<g>b<f+>b<d>b<e>b<f+>b<e>b<d>b<e>b<g>b<f+>b<d>b<e>b<f+>b<e>b<d>b<e>b<g>b<f+>b<d>b<e>b<f+>b<e>b<d>b<e>b<g>b<f+>b<d>b<e>b<f+>b<e>b<d>b<e>b<g>b<f+>b<d>b<e>b<f+>b<e>b<d>b<e>b]10");
			se=soundDriver.compile("t300 l8 <<b<e");

			//背景絵を設定
		//	imageLoader=new Loader();
		//	imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaded);
		//	imageLoader.load(new URLRequest(imageUrl));
			SequentialLoader.loadImages([imageUrl], imageArray, onLoaded);
		}

		private function onLoaded():void
		{
				var loader:Loader=imageArray.pop();
				var backData:BitmapData = new BitmapData(W, H);
				backData.draw(loader);
				var back:Bitmap=new Bitmap(backData);
			//var back:Bitmap=event.target.content as Bitmap;
			back.width=W;
			back.height=H;
			addChild(back);
			// BitmapDataの作成
			ball_bmpData=new BitmapData(W, H, true, 0x0);
			// BitmapDataの内容からBitmapを生成
			ball_bmp=new Bitmap(ball_bmpData);
			// Bitmapを表示
			addChild(ball_bmp);
			ball_canvas=new Sprite;

			// BitmapDataの作成
			block_bmpData=new BitmapData(W, H, true, 0x0);
			// BitmapDataの内容からBitmapを生成
			block_bmp=new Bitmap(block_bmpData);
			// Bitmapを表示
			addChild(block_bmp);
			block_canvas=new Sprite;

			//キラキラの準備
			particle_bmpData=new BitmapData(W, H, true, 0xFF000000);
			addChild(new Bitmap(particle_bmpData));
			glow_bmpData=new BitmapData(W / 4, H / 4, false, 0x0);
			var bm:Bitmap=addChild(new Bitmap(glow_bmpData, PixelSnapping.NEVER, true)) as Bitmap;
			bm.scaleX=bm.scaleY=4;
			bm.blendMode=BlendMode.ADD;
			glowMtx=new Matrix(0.25, 0, 0, 0.25);

			particleList=new Vector.<Particle>();

			// バーの作成
			bar=new Bar(this, W / 2, H - 50, 0x0000FF, bar_width, bar_height);
			ball_canvas.addChild(bar);

			// カウントフィールドの作成
			counter=createField();
			counter.x=W;
			addChild(counter);

			// メッセージフィールド作成
			message=createField();

			rankTxt=createField();

			scoreTxt=createField();
			scoreTxt.x=W;
			scoreTxt.y=50;
			addChild(scoreTxt);

			clickStart=createField();
			
			addEventListener(FAIL, notClear);
			addEventListener(CLEAR, clear);
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			create();
		}

		private function create():void
		{
			// 要素の型がBlockのVectorを作成
			BlockList=new Vector.<Block>();

			// ブロック作成
			var color:uint=BLOCK_COLOR;
			var b:Block;
			var item:Item;
			var type:int; // アイテムタイプ
			var item_color:uint;
			var rand:Number; // 乱数格納
			for (var i:int=0; i < block_row; i++)
			{
				color+=0xf;
				for (var j:int=0; j < block_column; j++)
				{
					b=new Block(this, j * block_width, i * block_height, color, block_width, block_height);
					// ball_canvas上に表示(画面上に見えない)
					block_canvas.addChild(b);
					// 配列に追加
					BlockList.push(b);
				}
			}

			block_bmpData.draw(block_canvas);
			ball_bmpData.draw(ball_canvas);

			rankTxt.text="";
			scoreTxt.text="Score:\n0";
			clickStart.text="Click Start!!";
			clickStart.x=W / 2 - clickStart.width / 2;
			clickStart.y=H / 2 - clickStart.height / 2;
			addChild(clickStart);

			stage.addEventListener(MouseEvent.CLICK, start);
		}

		private function start(event:MouseEvent):void
		{
			if (event.target != stage)
				return;
			expFlg=0;
			status=0;
			var theta:Number=Math.random() * Math.PI;
			if (theta < Math.PI / 6)
				theta=Math.PI / 6;
			else if (theta > 5 * Math.PI / 6)
				theta=5 * Math.PI / 6;
			// ボールの作成
			var ball:Ball=new Ball(this, W / 2, H - 100, SPEED * Math.cos(theta), -SPEED * Math.sin(theta), 0.0, 0xFFFFFF, ball_size);
			ball_canvas.addChild(ball);

			stage.removeEventListener(MouseEvent.CLICK, start);
			removeChild(clickStart);

			//bgmを再生
			bgm=soundDriver.play(data);
			var st:SoundTransform=new SoundTransform();
			st.volume=0.2;
			bgm.soundTransform=st;
		}

		//スコアの加算
		public function addScore(value:int):void
		{
			if (status != 0)
				return;
			score+=value;
			scoreTxt.text="Score:\n" + score.toString();
		}

		// テキストフィールド作成関数
		private function createField():TextField
		{
			var tf:TextField=new TextField;
			// フォント、サイズ、色を決める
			tf.defaultTextFormat=new TextFormat("Swis721 BdRndBT", 20, 0xFFFFFF);
			tf.autoSize=TextFieldAutoSize.LEFT;
			return tf;
		}

		private function displayMessage(str:String):void
		{
			ball_bmpData.lock();
			ball_bmpData.fillRect(ball_bmpData.rect, 0x0);
			ball_bmpData.unlock();
			message.text=str;
			// ゲームステージの中央に合わせる
			message.x=W / 2 - message.width / 2;
			message.y=H / 2 - message.height / 2;
			addChild(message);
		}

		//クリア出来なかった
		private function notClear(event:Event):void
		{
			remainBall=block_count;
			if (status != 0)
				return;
			status=1;
			displayMessage("Game Over!!");

			createButton();
		}

		//クリア
		private function clear(event:Event):void
		{
			if (status != 0)
				return;
			status=2;
			ary=[];
			page=1;
			userNum=0;
			rank = 0;
			displayMessage("THANK YOU FOR PLAYING\nCONGRATULATION!!");
			twitterLoader = new URLLoader(new URLRequest(rankUrl + "&rpp="+rpp.toString()+"&page=" + page.toString()));
			twitterLoader.addEventListener(Event.COMPLETE, onLoadTwitter);
			twitterLoader.addEventListener(IOErrorEvent.IO_ERROR, error);
		}
		
		//検索結果の取得
		private function onLoadTwitter(event:Event):void{
			var str:String = event.target.data;
			var obj:Object = JSON.decode(str);
			if((obj.results as Array).length == rpp){
				page++;
				twitterLoader.load(new URLRequest(rankUrl + "&rpp="+rpp.toString()+"&page=" + page.toString()));
				ary = ary.concat(obj.results as Array);
				return;
			}
			
			ary = ary.concat(obj.results as Array);
			
			var exp1:RegExp = /(\[星屑ブロック崩し\]|\[星空ブロック崩し\])Clearおめでとう！ あなたのスコアは[0-9]+点です。/;
			var exp2:RegExp = /[0-9]+/;
			var exp3:RegExp = /RT|QT/;
			var resultMap:Object = {};
			for(var i:int = 0; i < ary.length; i++){
				var tmp:String = ary[i].text;
				var user:String = ary[i].from_user;
				if(exp3.exec(tmp) != null) continue;
				tmp = exp1.exec(tmp);
				tmp = exp2.exec(tmp);
				if(resultMap[user] == undefined){
					resultMap[user] = tmp;
				}
				else{
					if(int(tmp) > int(resultMap[user])){
						resultMap[user] = tmp;
					}
				}
			}
			for each(i in resultMap){
				if(i < score) rank++;
				userNum++;
			}
			rank = userNum-rank+1;
			userNum++;
			rankTxt.text = userNum.toString() + "人中" + rank.toString() + "位";
			rankTxt.x = W/2 - rankTxt.width/2;
			rankTxt.y = H/2 - rankTxt.height/2 + message.height;
			addChild(rankTxt);
			createButton();
		}

		private function error(event:IOErrorEvent):void
		{
			createButton();
		}

		private function createButton():void
		{
			twitBtn=new PushButton(this, W / 2, H / 2 + message.height + rankTxt.height, "Twitter", twitter);
			twitBtn.x-=twitBtn.width / 2;
			resetBtn=new PushButton(this, W / 2, twitBtn.y + twitBtn.height + 10, "Restart", reset);
			resetBtn.x-=resetBtn.width / 2;
		}



		private function reset(event:MouseEvent):void
		{
			score=0;
			ballNum=0;
			expFlg=1;
			removeChild(twitBtn);
			removeChild(resetBtn);
			removeChild(message);
			for (var i:int=0; i < BlockList.length; i++)
			{
				BlockList[i].explosion();
			}
			create();
		}

		//Twitterに投稿
		private function twitter(event:MouseEvent):void
		{
			var url:String
			if (status == 2)
			{
				url=postUrl + escapeMultiByte("[星屑ブロック崩し]Clearおめでとう！ あなたのスコアは") + score.toString() + escapeMultiByte("点です。");
				if (rankTxt.text != "")
					url+=escapeMultiByte(userNum.toString() + "人中" + rank.toString() + "位")
			}
			else if (status == 1 && block_count == 0)
			{
				url=postUrl + escapeMultiByte("[星屑ブロック崩し]ブロック全消しおめでとう！だけどGame Overだよ！！");
			}
			else if (status == 1)
			{
				url=postUrl + escapeMultiByte("[星屑ブロック崩し]Game Over あなたは残り") + remainBall.toString() + escapeMultiByte("個のブロックを残して力尽きました。");
			}
			url+=wonderflUrl;
			navigateToURL(new URLRequest(url));
		}

		private function onEnterFrame(event:Event):void
		{
			block_count=BlockList.length;
			counter.text="Block数:\n" + block_count;

			glow_bmpData.fillRect(glow_bmpData.rect, 0x0);
			particle_bmpData.fillRect(particle_bmpData.rect, 0x00000000);
			particle_bmpData.lock();

			//キラキラパーティクルを動かすよ
			var i:int=particleList.length;
			while (i--)
			{
				var p:Particle=particleList[i];
				particle_bmpData.setPixel32(p.x, p.y, p.color);
				p.update();
				if (p.y > H)
				{
					particleList.splice(i, 1);
				}
			}

			//描画
			particle_bmpData.unlock();
			glow_bmpData.draw(particle_bmpData, glowMtx);

			block_bmpData.fillRect(block_bmpData.rect, 0x0);
			block_bmpData.draw(block_canvas);

			ball_bmpData.draw(ball_canvas);
			ball_bmpData.colorTransform(ball_bmpData.rect, new ColorTransform(1.5, 1.0, 1.5, 0.85));
		}
	}
}

import __AS3__.vec.Vector;
import flash.display.Shape;
import flash.events.Event;
import flash.filters.GlowFilter;
import org.libspark.betweenas3.BetweenAS3;
import org.libspark.betweenas3.tweens.ITween;
import flash.filters.GlowFilter;
import flash.geom.Matrix;
import flash.display.Sprite;
import flash.geom.Point;

class Obj extends Shape
{
	protected var field:BreakBlock;
	protected var color:uint;

	public function Obj(field:BreakBlock)
	{
		this.field=field;
	}

	protected function enterFrame(event:Event):void
	{
		if (field.expFlg)
			explosion();
		update();
	}

	//画面上から消す
	public function deleteObj():void
	{
		removeEventListener(Event.ENTER_FRAME, enterFrame);
		parent.removeChild(this);
	}

	protected function update():void
	{
	}

	protected function draw():void
	{
	}

	public function explosion():void
	{
		var num:int=width * height / 10;
		//キラキラパーティクルの発生
		for (var i:int=0; i < num; i++)
		{
			var p:Particle=new Particle(x + width / 2, y + height / 2, Math.random() * 10 - 5, Math.random() * 10 - 5, color);
			field.particleList.push(p as Particle);
		}
		deleteObj();
	}
}

//通常のボールクラス
class Ball extends Obj
{
	//Blockの参照
	protected var blocks:Vector.<Block>;
	//Barの参照
	private var bar:Bar;
	protected var value:int; //基礎点
	protected var vx:Number; // x方向の移動量
	protected var vy:Number; // y方向の移動量
	protected var vz:Number;
	protected var va:Number; // alphaの変化量
	protected var r:Number; // 半径
	protected var heaven:int; //貫通モードフラグ
	protected var judgeLine1:Number; //ブロックとの判定が必要になる境界線
	protected var judgeLine2:Number; //バーとの判定が必要になる境界線

	public function Ball(field:BreakBlock, x:Number, y:Number, vx:Number, vy:Number, va:Number, c:uint, r:Number)
	{
		super(field);
		field.ballNum++;
		value=100;
		this.field=field;
		this.blocks=field.BlockList;
		this.bar=field.bar;
		this.heaven=0;
		this.color=c;
		this.x=x;
		this.y=y;
		this.vx=vx;
		this.vy=vy;
		this.va=va;
		this.vz=0;
		this.r=r;
		draw();
		filter();
		judgeLine1=BreakBlock.block_height * BreakBlock.block_row + height / 2;
		judgeLine2=field.bar.y - height / 2 - field.bar.height / 2;
		addEventListener(Event.ENTER_FRAME, enterFrame);
	}

	//描画
	override protected function draw():void
	{
		//(0,0)を中心に円を描画
		graphics.beginFill(color);
		graphics.drawCircle(0, 0, r);
		graphics.endFill();
	}

	protected function filter():void
	{
		if (heaven)
		{
			filters=[new GlowFilter(0xFF0000, 1, 16, 16, 4)];
		}
		else
		{
			filters=[new GlowFilter(0xFF0000, 1, 8, 8, 2)];
		}
	}

	override protected function update():void
	{
		if (field.status == 2)
		{
			vz=-10;
			field.addScore(2000);
		}
		if (heaven)
		{
			x+=vx * 1.5;
			y+=vy * 1.5;
			z+=vz * 1.5;
		}
		else
		{
			x+=vx;
			y+=vy;
			z+=vz;
		}

		if (y + vy < judgeLine1)
			checkBlockCollision();
		if (y + vy > judgeLine2)
			checkBarCollision();
		checkStageCollision();
		checkInField();
	}

	//画面外に出ていないかどうか
	protected function checkInField():void
	{
		if (y > BreakBlock.H)
		{
			removeEventListener(Event.ENTER_FRAME, enterFrame);
			parent.removeChild(this);
			//FAILイベントの発生
			field.dispatchEvent(new Event(BreakBlock.FAIL));
			field.ballNum--;
		}
	}

	//Block衝突判定
	protected function checkBlockCollision():void
	{
		var i:int=blocks.length;
		while (i--)
		{
			var block:Block=blocks[i];
			if (block.hitTestObject(this))
			{
				if (!heaven)
				{
					if ((y - r) <= (block.y + block.height) || block.y <= (y + r))
					{
						vy*=-1;
						y+=vy;
					}
					else if ((x + r) >= block.x || (block.x + block.width) >= (x - r))
					{
						vx*=-1;
						x+=vx;
					}
				}
				//ブロックにダメージ
				addScore();
				block.deleteBlock();
				blocks.splice(i, 1);
				if (blocks.length == 0)
				{
					field.dispatchEvent(new Event(BreakBlock.CLEAR));
				}
			}
		}
	}

	//Bar衝突判定
	protected function checkBarCollision():void
	{
		// バーとボールの当たり判定
		if (this.hitTestObject(bar))
		{
			if ((bar.y - bar.height / 2) <= (y + r))
			{
				vy*=-1;
				// バーにボールがめり込むのを防ぐ
				y-=bar.height / 2 + r;
				var radian:Number=Math.atan2(y - bar.y, x - bar.x);

				var point:Point=new Point(vx, vy);
				vx=Math.cos(radian) * point.length;
				vy=Math.sin(radian) * point.length;
			}
			if (radian < -Math.PI / 2 + 0.1 && radian > -Math.PI / 2 - 0.1)
			{
				heaven=1;
				filter();
			}
			else if (heaven)
			{
				heaven=0;
				filter();
			}
		}
	}

	protected function checkStageCollision():void
	{
		//ステージ全体とボールの当たり判定
		if (x < r || x > BreakBlock.W - r)
		{
			vx*=-1;
			// ステージにめり込むのを防ぐ
			x+=vx;
		}
		else if (y < r)
		{
			vy*=-1;
			// ステージにめり込むのを防ぐ
			y+=vy;
		}
	}

	protected function addScore():void
	{
		var score:int=value;
		score+=(field.ballNum - 1) * 50;
		if (heaven)
			score*=2;
		score*=1.0 / field.bar.scaleX;
		field.addScore(score);
	}
}

//星型のボールクラス
class StarBall extends Ball
{
	public var rv:Number;

	public function StarBall(field:BreakBlock, x:Number, y:Number, vx:Number, vy:Number, va:Number, c:uint, r:Number, rv:Number)
	{
		super(field, x, y, vx, vy, va, c, r);
		this.rv=rv;
		value=200;
	}

	override protected function draw():void
	{
		var r2:Number=r / 2;
		var angle:Number=-90;
		var addtion:Number=360 / 10;
		graphics.beginFill(0xffffff);
		graphics.moveTo(0, -r);
		for (var i:int=0; i < 10; i++)
		{
			angle+=addtion;
			var to_x:Number;
			var to_y:Number;
			var radian:Number=angle * Math.PI / 180;
			if (i % 2)
			{
				to_x=r * Math.cos(radian);
				to_y=r * Math.sin(radian);
			}
			else
			{
				to_x=r2 * Math.cos(radian);
				to_y=r2 * Math.sin(radian);
			}
			graphics.lineTo(to_x, to_y);
		}
		graphics.endFill();
	}

	override protected function filter():void
	{
		if (heaven)
		{
			filters=[new GlowFilter(0xFF0000, 1, 16, 16, 4)];
		}
		else
		{
			filters=[new GlowFilter(color, 1, 8, 8, 2)];
		}
	}

	//画面外に出ていないかどうか
	override protected function checkInField():void
	{
		if (y > BreakBlock.H)
		{
			removeEventListener(Event.ENTER_FRAME, enterFrame);
			parent.removeChild(this);
			field.ballNum--;
		}
	}

	override protected function update():void
	{
		rotation+=rv;
		super.update();
	}
}

//ブロッククラス
class Block extends Obj
{
	public function Block(field:BreakBlock, x:Number, y:Number, c:uint, w:Number, h:Number)
	{
		super(field);
		this.field=field;
		this.x=x;
		this.y=y;
		this.color=c;
		// (1,1)を始点に長方形を描く
		graphics.beginFill(color);
		graphics.drawRect(1, 1, w - 1, h - 1);
		graphics.endFill();
	}

	override public function explosion():void
	{
		var num:int=width * height / 10;
		//キラキラパーティクルの発生
		for (var i:int=0; i < num; i++)
		{
			var p:Particle=new Particle(x + width / 2, y + height / 2, Math.random() * 10 - 5, Math.random() * 10 - 5, x / BreakBlock.W * 0xffffff);
			field.particleList.push(p as Particle);
		}
		deleteObj();
	}

	override public function deleteObj():void
	{
		parent.removeChild(this);
	}

	public function deleteBlock():void
	{
		var tween:ITween=BetweenAS3.to(this, {alpha: 0}, 0.3);
		tween.onComplete=function(... onCompleteParams):void
		{
			parent.removeChild(onCompleteParams[0])
		};
		tween.onCompleteParams=[this];
		tween.play();

		//効果音
		field.soundDriver.sequenceOn(field.se);

		var num:int=width * height / 10;
		//キラキラパーティクルの発生
		for (var i:int=0; i < num; i++)
		{
			var p:Particle=new Particle(x + width / 2, y + height / 2, Math.random() * 10 - 5, Math.random() * 10 - 5, Math.random() * 0xffffff);
			field.particleList.push(p as Particle);
		}

		// アイテム作成
		if (Math.random() < BreakBlock.ITEM_PROBABILITY)
		{
			var item:Item;
			if (Math.random() < BreakBlock.STAR_PROBABILITY)
			{
				item=new StarItem(field, x + width / 2, y + height / 2, 0, 4, Math.random() * 0xffffff, 5.4 * Math.random() + 4);
				field.block_canvas.addChild(item as StarItem);
			}
			else
			{
				item=new HeartItem(field, x + width / 2, y + height / 2, 0, 4, Math.round(Math.random()) * 0xffffff, 15.5);
				field.block_canvas.addChild(item as HeartItem);
			}
		}
	}
}

//反射バークラス
class Bar extends Obj
{
	private var w:Number;
	private var h:Number;

	public function Bar(field:BreakBlock, x:Number, y:Number, c:uint, w:Number=50, h:Number=20)
	{
		super(field);
		this.field=field;
		this.x=x;
		this.y=y;
		this.w=w;
		this.h=h;
		draw();

		addEventListener(Event.ENTER_FRAME, enterFrame);
	}

	override protected function draw():void
	{
		// (0,0)を中心とする長方形を描く
		var matrix:Matrix=new Matrix();
		matrix.createGradientBox(w, h, 5);
		graphics.beginGradientFill("linear", [0x0000FF, 0x00FFFF], [1.0, 1.0], [0, 255], matrix);
		graphics.drawRect(-w / 2, -h / 2, w, h);
		graphics.endFill();
	}

	override public function explosion():void
	{
		BetweenAS3.to(this, {scaleX: 1}, 0.5).play();
	}

	override public function deleteObj():void
	{
	}

	override protected function update():void
	{
		x+=(field.mouseX - x) / 8;
		if (x + width / 2 > BreakBlock.W)
			x=BreakBlock.W - width / 2;
		else if (x - width / 2 < 0)
			x=width / 2;
	}
}

//アイテムクラス
class Item extends Obj
{
	protected var vx:Number;
	protected var vy:Number;
	protected var vz:Number;
	protected var size:Number;
	protected var judgeLine:Number;

	public function Item(field:BreakBlock, x:Number, y:Number, vx:Number, vy:Number, color:uint, r:Number)
	{
		super(field);
		this.x=x;
		this.y=y;
		this.vx=vx;
		this.vy=vy;
		this.vz=vx;
		this.color=color;
		this.size=r;
		this.field=field;
		draw();
		this.judgeLine=0;
		addEventListener(Event.ENTER_FRAME, enterFrame);
	}

	override protected function update():void
	{
		if (field.status == 2)
			vz=-10;

		x+=vx;
		y+=vy;
		z+=vz;

		checkInField();
		if (y > judgeLine)
			checkBarCollision();
	}

	//画面外に出ていないかどうか
	protected function checkInField():void
	{
		if (y > BreakBlock.H)
		{
			deleteObj();
		}
	}

	//バーとの接触判定
	protected function checkBarCollision():void
	{
		if (this.hitTestObject(field.bar))
		{
			deleteObj();
		}
	}
}

//星型のアイテムクラス
class StarItem extends Item
{
	public function StarItem(field:BreakBlock, x:Number, y:Number, vx:Number, vy:Number, color:uint, r:Number)
	{
		super(field, x, y, vx, vy, color, r);
	}

	override protected function draw():void
	{
		this.filters=[new GlowFilter(color, 1, 8, 8, 2)];
		var r2:Number=size / 2;
		var angle:Number=-90;
		var addtion:Number=360 / 10;
		graphics.beginFill(0xffffff);
		graphics.moveTo(0, -size);
		for (var i:int=0; i < 10; i++)
		{
			angle+=addtion;
			var to_x:Number;
			var to_y:Number;
			var radian:Number=angle * Math.PI / 180;
			if (i % 2)
			{
				to_x=size * Math.cos(radian);
				to_y=size * Math.sin(radian);
			}
			else
			{
				to_x=r2 * Math.cos(radian);
				to_y=r2 * Math.sin(radian);
			}
			graphics.lineTo(to_x, to_y);
		}
		graphics.endFill();
	}

	override protected function checkBarCollision():void
	{
		if (this.hitTestObject(field.bar))
		{
			deleteObj();
			createBall();
		}
	}

	//ボールの生成
	private function createBall():void
	{
		var newBall:StarBall=new StarBall(field, x, y - field.bar.height, Math.random() * 15 - 7.5, -Math.random() * 5 - 2, 0.0, color, size, Math.random() * 5 + 5);
		field.ball_canvas.addChild(newBall);
	}
}

//バーの大きさを変えるアイテム
class HeartItem extends Item
{
	public function HeartItem(field:BreakBlock, x:Number, y:Number, vx:Number, vy:Number, color:uint, r:Number)
	{
		super(field, x, y, vx, vy, color, r);
	}

	//バーとの衝突判定
	override protected function checkBarCollision():void
	{
		if (this.hitTestObject(field.bar))
		{
			var tween:ITween;
			var toScale:Number;
			vy=0;
			//バーの縮小拡大。色によって効果が違う
			if (color)
			{
				if (field.bar.scaleX < 1)
					toScale=1;
				else
				{
					toScale=field.bar.scaleX + 1;
					if (toScale > 3)
						toScale=3;
				}
				tween=BetweenAS3.to(field.bar, {scaleX: toScale}, 0.5);
			}
			else
			{
				toScale=field.bar.scaleX / 2;
				if (toScale < 0.25)
					toScale=0.25;
				tween=BetweenAS3.to(field.bar, {scaleX: toScale}, 0.5);
			}
			tween.play();
			removeEventListener(Event.ENTER_FRAME, enterFrame);
			tween=BetweenAS3.to(this, {alpha: 0, scaleX: 3, scaleY: 3}, 0.5);
			tween.onComplete=deleteObj;
			tween.play();
		}
	}

	override protected function draw():void
	{
		var a:Number=1;
		var b:Number=2;
		var c:Number=0.7;
		var d:Number=1;
		var df:Number=0.01;
		var fmin:Number=-Math.PI / 2;
		var fmax:Number=3 * Math.PI / 2;
		var xx:Vector.<Number>=new Vector.<Number>;
		var yy:Vector.<Number>=new Vector.<Number>;
		var value:Number;
		var max_v:Number=0;
		var min_v:Number=1000000;

		for (var f:Number=fmin; f <= fmax; f+=df)
		{
			var t:Number=b * Math.sqrt(f + Math.PI / 2) - b * Math.sqrt(3 * Math.PI / 2 - f) + (1 - b * Math.sqrt(2 / Math.PI)) * f + b * Math.sqrt(Math.PI / 2);
			var r:Number=a * (1 - Math.sin(t));
			xx.push(size * r * (1 + c * Math.sin(f)) * Math.cos(f));
			value=size * d * r * (1 + c * Math.sin(f)) * Math.sin(f);
			yy.push(value);
			if (value > max_v)
				max_v=value;
			if (value < min_v)
				min_v=value;
		}

		var center:Number=(max_v + min_v) / 2;
		var i:int=xx.length;
		graphics.beginFill(color);
		graphics.moveTo(xx[0], yy[0] - center);
		while (i--)
		{
			graphics.lineTo(xx[i], yy[i] - center);
		}
		graphics.endFill();

		this.rotation+=180;
		this.filters=[new GlowFilter(0xff69b4, 1, 16, 16, 2)];
	}
}

//キラキラの粒子クラス
class Particle
{
	public var x:Number;
	public var y:Number;
	public var vx:Number;
	public var vy:Number;
	public var color:uint;
	public var field:BreakBlock;

	public function Particle(x:Number, y:Number, vx:Number, vy:Number, color:uint)
	{
		this.x=x;
		this.y=y;
		this.vx=vx;
		this.vy=vy;
		this.color=color | 0xFF000000;
	}

	public function update():void
	{
		x+=vx;
		y+=vy;
		vy+=0.2;
	}
}

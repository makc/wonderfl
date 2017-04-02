package {

	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display.Sprite;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import flash.events.Event;
	import flash.events.MouseEvent;

	[SWF(width=465, height=465, backgroundColor=0x000000, frameRate=30)];

	
	/*
	 * パーティクル祭りの原点「Liquid10000」を解説してみる。
	 * [冒頭のコメントに追記あり]（Download後の閲覧推奨）
	 * 
	 * 前回のPerlinNoiseはこれの伏線だったのだよ！（偶然ですけど）
	 * 今回はPerlinNoiseの復習と、ビット演算子の勉強になります。
	 * 
	 * 前々回
	 * http://wonderfl.net/c/rp2U
	 * 前回
	 * http://wonderfl.net/c/sXHT
	 * 
	 * フォースマップっていう考え方らしいですが、
	 * PerlinNoiseの色を速度に変換するらしいです。
	 * てっきり難しい物理演算を使ってると思ってたよ・・・。
	 * 
	 * あと、前々回にやった花火の処理も加わってますので、
	 * 前々回・前回の内容を知ってると、にやけることができると思います。
	 * 
	 * これが分かると、あのsnowとかの作り方もわかるかな・・・？
	 * 次回はそれにするかもしれません。しないかもしれません。
	 * 
	 * パーティクル祭りに関してはclockmaker様のまとめが詳しいです。
	 * この記事を元に、自身で高速化を試してみるのもありだと思います。
	 * http://clockmaker.jp/blog/2009/04/particle/
	 * http://clockmaker.jp/blog/2009/04/particle_fes/
	 * 
	 * Fork元を製作された方へ。
	 * ・Forkを拒否されたい場合は、何かしらのアクションでお伝えください。
	 * 	削除いたします。（できれば生暖かく見守っていただけると嬉しいです）
	 * 
	 * 中級者・上級者の方へ。
	 * ・何かアドバイスや校正箇所があれば、ご指摘お願いします。
	 * 
	 * 初心者・初級者の方へ。
	 * ・一緒に勉強しましょう。何か質問があればどうぞ。
	 *  自分も初級者なので、答えられるか分かりませんが。（笑
	 * 
	 * [追記]
	 * 朝起きて見てみたらFavoriteの多さにびっくりして目が覚めました。
	 * あくまで解説のみで、自分の作品ではないということで恐縮ではありますが、
	 * こういう試みが支持されてるということは、自分の考えは間違ってなかったんだなと、
	 * 確信している次第です。
	 * 
	 * そしてこういう解説ができるのも、勉強したいと思わせられる素敵な作品たちが
	 * このwonderflに溢れているからだと思います。製作者の皆さんに多謝。
	 * 
	 * これからもマイペースでやっていきたいと思いますが、あまりに高度なものは
	 * 初級者の自分では解析不可能なので、こういう解説を中級者・上級者の方も
	 * してくださったら、もっとwonderflのすばらしさというのが共有できるんじゃないかと
	 * 思う次第です。
	 * 
	 * あ、あと、clockmakerさん、
	 * 「extends Progression 拡張機能コンテスト」ダブル受賞おめでとうございますー。
	 * 
	 */
	
	 /*
	  * おおまかな流れ
	  * 　１．パーティクルを10000個作る
	  * 　２．パーティクル情報を打ち込むためのBitmapを作る
	  * 　３．PerlinNoiseを作る
	  * 　４．パーティクル情報を打ち込むためのBitmapの色を落とす
	  * 　５．PerlinNoiseの情報を元にパーティクルの加速度・速度・位置を求める
	  * 　６．求められたパーティクルの情報に従って、Bitmapに色を打ち込む
	  * 　７．４・５・６の処理をパーティクル毎に処理する
	  * 　８．４・５・６・７の処理を毎フレーム行う
	  */
	public class Liquid10000 extends Sprite {

		private const nums:uint = 10000;
		private var bmpDat:BitmapData;
		private var vectorDat:BitmapData;
		private var randomSeed:uint = Math.floor( Math.random() * 0xFFFF );
		private var bmp:Bitmap;
		private var vectorList:Array;
		private var rect:Rectangle;
		private var cTra:ColorTransform;

		public function Liquid10000() {
			initialize();
		}
		private function initialize():void {

			//stage関連の設定
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;

			//Bitmapを作ってaddChild（描画される、メインのBitmap）
			bmpDat = new BitmapData( 465, 465, false, 0x000000 );
			bmp= new Bitmap( bmpDat );
			addChild( bmp );
			
			//PerlinNoiseを描く（addChildされてないのが肝）
			//PerlinNoiseについては、前回やりましたね。なので解説は省略。
			vectorDat= new BitmapData( 465, 465, false, 0x000000 );
			randomSeed = Math.floor( Math.random() * 0xFFFF );
			vectorDat.perlinNoise( 230, 230, 4, randomSeed, false, true, 1 | 2 | 0 | 0 );
			//どんなPerlinNoiseか見たい人は、下のaddChildのコメントアウトを消して、
			//EnterFrameのaddEventListenerをコメントアウトしてみてください。
			//引数からもわかりますが、赤と緑（RG）しか使われていませんね。
			//これは理由があります。記憶の片隅にとどめておいてください。
			//addChild(new Bitmap(vectorDat));
			
			//stageの大きさの矩形範囲を設定
			//colorTransformでの範囲設定に使われます。
			rect = new Rectangle( 0, 0, 465, 465 );
			
			//時間経過とともにパーティクルの残像を暗くして、軌跡を作るための色設定。
			//花火でもありました。重要なパラメータです。
			cTra= new ColorTransform( 0, .8, .8, .9 );

			//パーティクルを入れるための配列
			vectorList= new Array();

			//パーティクルを1万個作ってvectorListに押し込む
			for (var i:uint = 0; i < nums; i++) {
				//パーティクルの場所：X・YともにRandom
				var px:Number = Math.random()*465;
				var py:Number = Math.random() * 465;
				//X・Y軸の加速度
				var av:Point = new Point( 0, 0 );
				//X・Y軸の速度
				var vv:Point = new Point( 0, 0 );
				//最初に求めたpx,pyを代入
				var pv:Point = new Point( px, py );
				//一番下に定義されているパーティクルの情報を持つVectorDat型のオブジェクトを生成して
				//位置情報・速度・加速度情報を入れ込む
				var hoge:VectorDat = new VectorDat( av, vv, pv);
				//配列に押し込む
				vectorList.push( hoge );
			}
			//メインタイムラインのEnterFrameイベントをloop関数に関連付ける
			addEventListener( Event.ENTER_FRAME, loop );
			//stageがクリックされたらresetFunc関数が呼び出されるようにする。
			stage.addEventListener( MouseEvent.CLICK, resetFunc );
		}
		
		
		
		//毎フレーム呼び出される関数
		private function loop( e:Event ):void {
			//描画用のBitmapDataをcolorTransformで暗くする（重要）
			//これにより、過去の色が薄くなるのは、以前解説した花火の描画の時も一緒でしたね。
			//これがないとどうなるのかは、花火のとき同様、コメントアウトしてみてください。
			bmpDat.colorTransform( rect, cTra );
			
			//vectorListのコピーを作成
			var list:Array = vectorList;
			
			//listの長さをlenに代入しておく
			//なんかこうすると、for文の処理が早いらしい？
			var len:uint = list.length;
			
			//このクラスの根幹処理なので超重要！
			//for文でlistの最初のエレメントから走査
			for (var i:uint = 0; i < len; i++) {
				//listのi番目のエレメントをdotsに代入
				var dots:VectorDat = list[i];
				
				//PerlinNoiseが描かれているvectorDatの色を抜き出す。
				//dotsの場所(dots.pv.x, dots.pv.y)にあるピクセルの色を抜き出し(getPixel)ます。
				var col:Number = vectorDat.getPixel( dots.pv.x, dots.pv.y );
				
				//上で抜き出した色から、さらにRGそれぞれの色を抜き出します。
				//後の処理で、RはX軸の加速度に、GはY軸の加速度に変換されます。
				//Bがないのは、別にZ軸とかその他の処理がいらない(RとGだけで十分）からですね。
				//これで、何故PerilinNoiseがRGしか使われてないか理由が判明しました。
				
				//var r:uint = col >> 16;	これでもOK
				var r:uint = col >> 16 & 0xff;
				var g:uint = col >> 8 & 0xff;
				//var b:uint = col & 0xff;
				
				/* ビット演算がわかってる人はスルーで。読む人は、紙に書きながら一緒にやってみるとわかりやすいかもしれません。
				 * （というか自分も勉強しながら解説してるんで、偉そうなこといえない）
				 * 上の式は普段あまり見ないですが、ビット演算と呼ばれるものです。主に色を弄るときに使われたりします。多分。
				 * 例えば、
				 * 
				 * var color:Number = 0x99C6FF;
				 * trace(color.toString(2));
				 * 
				 * とやってみると、100110011100011011111111とでます。
				 * これは、0x99C6FFの2進数バージョンです。つまり、
				 * 		最初の8ビット(10011001)がRで0x99
				 *		真ん中の8ビット(11000110)がGで0xC6
				 *		最後の8ビット(11111111)がBで0xFF
				 * ということになります。
				 * で、これからどうやってそれぞれの色を抜き出すかというと、例えばRを例に説明すると
				 * >>16　とやることで、16ビット分右にシフトされます。すると、10011001（最初の8ビット）となります。
				 * これで最初の8bit、つまり赤色が取り出せたということになります。
				 * 右側にあふれた数値はどうなるかというと破棄されます。それだけではないらしいのですが、よく分かりません（ずれた分左側を符号で埋める埋めないとかなんとか）。
				 * 
				 * さて、Gは「col >> 8 & 0xff」となってますが、col >> 8はいいとして、&はなんでしょう。Rでも使われてますね。
				 * これは何かというと論理積というらしいです。左辺と右辺のビット単位で掛け算するってことですね。
				 * 言葉だけだと分からないので、まずはGを例としてやってみましょう。
				 * まず、col >> 8で8ビット右にシフトすると、1001100111000110(RGの色)となりますね。これに0xff(11111111)で論理積を求めるということは、
				 * 
				 *   1001100111000110
				 * &         11111111
				 * -------------------
				 *           11000110
				 * 
				 * ということになります。（式がずれていたら数値を右寄せで整列してください）
				 * 一番右を見てみると、0*1は0だから、答えは0ですね。右から2番目は1*1なので1です。
				 * これが論理積(AND)・・・らしいです。逆に論理和(OR)というのもありますが、これはどちらかが1なら1ってやつですね。
				 * if等の条件式のandとorを連想すると分かりやすいかと思います。
				 * 
				 * Rの部分（前の8ビット）は掛け算されることすらないので、0と考えてください。ということは、答えが1になるはずもないですね。
				 * 感覚としては、フィルターをかける感じと考えていただければいいと思います。とにかく、これでGが出ました。
				 * ということは、Bはどうすれば導き出せるでしょう？答えは書いてありますが、自分で考えてみましょうー。
				 */
				
				//赤色をX軸の加速度に変換
				//r-128は負の方向にも平等に移動させるため。
				//赤色が129以上だったら正の方向に、127以下だったら負の方向にそれだけ移動するということですね。
				//.0005は多分目算での速度調整用数値だと思います。
				dots.av.x += ( r - 128 ) * .0005;
				//緑はY軸ですね。
				dots.av.y += ( g - 128 ) * .0005;
				//あとはそれぞれの速度に加速度をプラスして、位置を調整します。
				dots.vv.x += dots.av.x;
				dots.vv.y += dots.av.y;
				dots.pv.x += dots.vv.x;
				dots.pv.y += dots.vv.y;
				
				var _posX:Number = dots.pv.x;
				var _posY:Number = dots.pv.y;
				
				//摩擦というか空気抵抗というか、速度が増え続けないように少し速度と加速度を落とす感じですね。
				dots.av.x *= .96;
				dots.av.y *= .96;
				dots.vv.x *= .92;
				dots.vv.y *= .92;
				
				//ステージ外に移動した場合の処理です。若干分かりづらいですが、3項演算子の入れ子になってます。
				/* 3項演算子はif文の簡略化されたやつという感じです。定義的には怪しいかもしれませんが。
				 * if文にすると・・・
				 * 
				 * if ( _posX > 465 ) {
				 * 	dots.pv.x = 0;	//465を超えたら0(反対側)に移動する
				 * } else {
				 * 		if ( _posX < 0 ) {
				 * 			dots.pv.x = 465	//0より小さくなったら465（反対側）に移動する
				 * 		else {
				 * 			0;	//これよく分からないですけど、処理しない(false)ってこと・・・？
				 * 		}
				 * }
				 */
				( _posX > 465 )?dots.pv.x = 0:
				( _posX < 0 )?dots.pv.x = 465:0;
				//Y軸も同様に。
				( _posY > 465 )?dots.pv.y = 0:
				( _posY < 0 )?dots.pv.y = 465:0;
				
				//1*1の四角形をdots.pv.x, dots.pv.yの位置に0xFFFFFFの色で描く
				bmpDat.fillRect( new Rectangle( dots.pv.x, dots.pv.y, 1, 1), 0xFFFFFF );
			}
		}

		
		//クリックで呼び出される関数。
		//これと同じ処理が上でもありましたね。なので、解説はしません。
		//・・・が。同じ処理っていうことは、記述的には無駄かもしれませんね。どうすればその無駄を省けるのか考えてみましょう。
		//ヒント（というか答え）：最初のinitialize関数のときにもこれを呼び出せばいいじゃん？でもe:MouseEventが邪魔だなぁ・・・。
		//				この引数がなくても関数が使えるようにできないかなぁ・・・。あ、デフォルトの値を入れておけばいいんじゃね？
		private function resetFunc(e:MouseEvent):void {
			randomSeed= Math.floor( Math.random() * 0xFFFF );
			vectorDat.perlinNoise( 230, 230, 4,randomSeed, false, true, 1|2|0|0 );
			vectorList= new Array();
			
			for (var i:uint = 0; i < nums; i++) {
				
				var px:Number = Math.random()*465;
				var py:Number = Math.random()*465;
				
				var av:Point = new Point( 0, 0 );
				var vv:Point = new Point( 0, 0 );
				var pv:Point = new Point( px, py );
				
				var hoge:VectorDat = new VectorDat( av, vv, pv);
				
				vectorList.push( hoge );
			}
		}
	}
}

//パーティクル用のクラスです。花火のときと似てる感じですね。これも説明は不要ですかね。
import flash.geom.Point;
class VectorDat {

	public var vv:Point;
	public var av:Point;
	public var pv:Point;

	function VectorDat( _av:Point, _vv:Point, _pv:Point ) {
		vv = _vv;
		av = _av;
		pv = _pv;
	}
}
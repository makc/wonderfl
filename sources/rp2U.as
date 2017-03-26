package
{

	/*
	 * [追記]皆さん好意的な意見ありがとうございます。
	 * 少し安心しました。バッシング来たらどうしようかと思ってたので（笑
	 * 
	 * ただ、自分の作ったコードがおおっぴらに解析されるっていうのは
	 * 恥ずかしかったり、あるいは気分のいいものでは無かったりする
	 * というのは自分でもなんとなく判るので、難しいところですね。
	 * 
	 * 最近のwonderflの作品はどれも素晴らしく、しかし高度すぎて、
	 * 初心者・初級者が研究・勉強しようと思っても難しい。
	 * わけのわからないメソッドが多かったり、高度な使い方をされてたり、
	 * 注釈があっても解説ではなかったり（ある意味当たり前ですが）、
	 * よくわからない数学・物理の計算式だったりと、敷居が高いな、と
	 * 感じていました。
	 * これが何か初心者向けへのアプローチのきっかけになればいいんですが・・・。
	 * 
	 * コメント：sqrtってそういう使い方ができるんですね。
	 * 目から鱗でした。ちょっと平方根なめてました。
	 * 仕組みがよくわからないので、高校数学から勉強しなおさないとだめですね。
	 * 
	 * また研究したいコードがあればやりたいと思います。
	 * 次はPerlinNoiseかなぁ・・・。
	 * 
	 * 
	 * すばらしい作品なので、勉強を兼ねてコードの注釈を付けてみました。
	 * とはいっても、自分のレベル的にまったく持って未知の領域なのでヘルプで調べながら。
	 *
	 * そんなわけで、コード自体はいじってません。
	 * 同じくこれで勉強をしようとしてる人の参考になれば・・・。
	 * 
	 * こういうForkはだめだろう、という意見があれば削除しますので教えてください。
	 * 
	 * 自分はまだレベルが低いので、考え方とか間違ってるかもしれません。
	 * むしろこちらがこれであってるか聞きたいので、questionタグ付けておきます。
	 * 
	 * 長ったらしいので、wonderfulの画面では表示し切れません。
	 * DOWNLOADしての閲覧をお勧め。
	 * 
	 * コンストラクタからの閲覧をお勧め。グローバル変数は見たいときに見るのが吉。
	 * （経験がないと、どんな変数か想像がつかないため）
	 */
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.PixelSnapping;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.filters.BlurFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	
	[SWF(width = "465", height = "465", backgroundColor = "0x000000", frameRate = "30")]
	
	public class HANABI extends Sprite
	{
		//ステージの幅、高さ
		private const WIDTH:Number = 465;
		private const HEIGH:Number = 465;
		
		//パーティクルを管理するための配列
		private var _particles:Array;
		
		//キャンバス（エフェクトをかける前の元データ）
		private var _canvas:BitmapData;
		
		//キャンバスの上に置くBitmapData（エフェクト用）
		private var _glow:BitmapData;
		
		//矩形情報
		private var _rect:Rectangle;
		
		//色情報（色を変化させたり、明度を低くしたり）。超重要。
		private var cTra:ColorTransform;
		
		//timerクラスのオブジェクト。
		private var timer:Timer;
		
		//花火の中心位置を一時的に保持するための変数。
		private var sx:Number;
		private var sy:Number;
		
		
		public function HANABI()
		{
			init();
		}
		
		private function init():void
		{
			_particles = [];
			
			//キャンバスBitmapを作成
			_canvas = new BitmapData(WIDTH, HEIGH, false, 0x0);
			addChild(new Bitmap(_canvas)) as Bitmap;
			
			//Glowエフェクト用Bitmapを作成
			//ピクセルの吸着なし、スムージングあり、ブレンドモードADD（白を上限として色が加算されていく。詳細はヘルプを参照。）
			//（4分の1の大きさで作成してscaleで戻してるのは、多分全体をぼやけさせるため？）
			_glow = new BitmapData(WIDTH/4, HEIGH/4, false, 0x0);
			var bm:Bitmap = addChild(new Bitmap(_glow, PixelSnapping.NEVER, true)) as Bitmap;
			bm.scaleX = bm.scaleY = 4;
			bm.blendMode = BlendMode.ADD;
			
			//ステージサイズの矩形範囲を設定。
			_rect = new Rectangle(0, 0, WIDTH, HEIGH);
			
			//色を全体的に落とす（RとGを0.8倍、Bを0.9倍。Alphaはそのまま）
			//RGBのどれもが1ではないのが肝
			cTra = new ColorTransform(.8, .8, .9, 1.0);
			
			
			//（この作品は2つのスレッド（？）によって別々の計算・レンダリングがされています。）
			//addEventListenerその1（描画関連）
			this.stage.addEventListener(Event.ENTER_FRAME, enterframeHandler);
			
			//addEventListenerその2（花火の情報生成・色の情報の変化関連）
			timer = new Timer(100);
			timer.addEventListener(TimerEvent.TIMER, resetFunc);
			timer.start();
		}
		
		
		
		
		////// スレッドその1
		
		
		private function resetFunc(e:TimerEvent):void
		{
			//Timerイベントにより100msごとに起こる
			//redMultiplierが0.9以上だったら0.8に戻して、0.9より小さかったら0.01ずつ加算する
			//つまり0.8から0.9くらいの間を行ったりきたり。花火の色が青と紫を行ったりきたりするのはこのため。
			(cTra.redMultiplier > 0.9)? cTra.redMultiplier = 0.8 : cTra.redMultiplier += 0.01;
			
			hanabi();
		}
		
		private function hanabi():void 
		{
			//上のresetFuncが起こるごとに呼び出される関数。
			//見えない花火を作る。
			//この花火の位置情報を元にupdate()関数で_canvasに花火を描く。
			
			//200回createParticleを呼び出す
			//（1個の花火に付き200個のパーティクルを作る）
			//HEIGH/3の理由は、花火が上部以外から出るのを避けるため
			var i:int = 200;
			sx = Math.random()*WIDTH;
			sy = Math.random()*HEIGH/3;
			while (i--) createParticle();
		}
		
		private function createParticle():void {
			//花火用パーティクルを生成
			//ひとつの場所から円状に拡散するように速度を設定する
			
			//上のhanabi関数でランダムに設定されたsx,syの場所にパーティクルを作成
			var p:Particle = new Particle();
			p.x = sx;
			p.y = sy;
			
			//半径と角度をランダムに決めて、それをx軸・y軸の速度にそれぞれ分解する
			//このradiusの求め方の意味があまりわからない・・・なんでMath.sqrtの必要があるのだろう。
			var radius:Number = Math.sqrt(Math.random())*10;
			var angle:Number = Math.random()*(Math.PI)*2;
			p.vx = Math.cos(angle) * radius;
			p.vy = Math.sin(angle) * radius;
			
			//配列に押し込む
			_particles.push(p);
		}
		
		
		
		
		////// スレッドその2
		
		
		private function enterframeHandler(e:Event):void
		{
			//拡張性を高めるため、enterframeHanlerの中に処理を書かないのかな？
			//各処理ごとに関数を細分化して、ここにまとめて書く方法がベターということかしら。
			update();
		}
		
		private function update():void {
			
			//この関数の全体的な流れ
			//１．既存の_canvasにBlurFilterをかけて、_canvasを上書き（軌跡をぼやけさせる）
			//２．_canvasの色を変える（青と紫を交互に出しつつ、過去に描画されたピクセルの色をどんどん落としていく）
			//３．花火の情報を動かして新しくピクセルを打つ
			//４．_glowに_canvasを描く（これでエフェクトがかった感じになる）
			//５．１に戻る。結果、_canvasに描かれていたピクセルがどんどんBlurFilterでぼけていく
			
			
			
			//いろんな処理を施すため、少しでも軽くするためにlockしておく。
			//以後、unlockがかかるまで見た目の描画は更新されない（裏では更新されてる）
			_canvas.lock();
			
			//_canvasにフィルターをかけたBitmapDataを_canvasに渡す。
			//花火の軌跡のぼやけ方に影響する。でもBlurXとYが1程度ではたいした違いはない。
			//但し、2以上にすると目に見えてぼやけ方が変わってしまう。Blurの量は方程式の係数と同意。
			//
			//第1引数でBitmapDataのソース
			//第2引数で範囲：全体(_rect)
			//第3引数で、第1引数に設定したBitmapDataの中心点(0,0)を_canvasのnew Point（初期値(0,0)）にあわせる
			//第4引数でかけたいフィルタを選択。この場合はBlurFilter。
			_canvas.applyFilter(_canvas, _rect, new Point(), new BlurFilter(1, 1));
			
			//_canvasの色を変える（超重要！）
			//ただ色を変えるだけでなく、古いピクセルの明度をどんどん落としていってる
			//これをコメントアウトすると大変なことに・・・。
			_canvas.colorTransform(_rect, cTra);
			
			//_particles.lengthの数だけ処理
			var i:int = _particles.length;
			while (i--) {
				var p:Particle = _particles[i];
				//落下加速度をプラス
				p.vy += 0.2;
				//速度に摩擦をかける
				p.vx *= 0.9;
				p.vy *= 0.9;
				//実際に移動する
				p.x += p.vx;
				p.y += p.vy;
				//_canvasのひとつのピクセルにパーティクルを描く
				_canvas.setPixel32(p.x, p.y, p.c);
				
				//パーティクルがステージ外に行ったりパーティクルの速度が.01を切ったら
				//_particles配列からそのパーティクルを除去する
				if ((p.x > stage.stageWidth || p.x < 0) || (p.y < 0 || p.y > stage.stageHeight) || Math.abs(p.vx) < .01 || Math.abs(p.vy) < .01)
				{
					this._particles.splice(i, 1);
				}
			}
			
			//処理が完了したのでunlockで更新。
			_canvas.unlock();
			
			//Glowエフェクト用Bitmapに描画。これを無くすと光ってるように見えない。試しに外してみると一目瞭然。
			//多分BlendMode.ADDが効いてる・・・のかな？NORMALにしたらやばかった。
			//
			//_glowはstageの1/4の大きさなので、_canvasを1/4の大きさにしたものをdrawしなければならない
			//ここでは1/4となってるが、addChildしてある「_glowを元としたBitmap」によって4倍されるので問題なし？
			//試しにMatrixをとってみると、ステージの4倍の大きさの_glowがお目見えします。
			//花火がめちゃくちゃ近いよ！やけどするよ！
			_glow.draw(_canvas, new Matrix(0.25, 0, 0, 0.25));
		}
	}
}


//パーティクルはあくまで位置・速度・色情報持つのみで、addChildされるわけではない。
//パーティクルを描画して動かすわけではないため、パーティクル自体はめちゃくちゃ軽い。
//これの中身の解説はさすがにいらないと思うので省略。
class Particle
{
	public var x:Number;
	public var y:Number;
	public var vx:Number;
	public var vy:Number;
	public var c:uint;
	
	public function Particle()
	{
		this.x = 0;
		this.y = 0;
		this.vx = 0;
		this.vy = 0;
		this.c = 0xFFFFFFFF;
	}
}


package {
    
	/*
	  ランダムパターンの種類を色々紹介するよ！ 
	  →キーで色々見れるよ。
	  
	  今回は仕組みが違うから出さなかったけど、このほかにも、ゲーム制作でよく使うものとして
	  前回出た結果と同じものの確率が減っていく、抽選ランダムというものもあるよ。
	 */
	
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.text.TextField;

	public class RandomPattern extends Sprite
	{
		public static const STAGE_W:uint = 465;
		public static const STAGE_H:uint = 465;
		
		public static const CHART_W:uint = 300;
		public static const CHART_H:uint = 300;
		
		private var _randomFunction:Function; 	// ランダム実験する関数を入れるよ
		private var _titleTf:TextField;
		private var _captionTf:TextField;
		private var _chart:RandomChart;
		
		private var _calc:Boolean = false;
		private var _patternNum:int = -1;
		
		public function RandomPattern()
		{
			addEventListener(Event.ADDED_TO_STAGE, init);	// flexBuilderとの互換性。
		}
				
		public function init(event:Event):void{
    
             // キャプチャを止めます
            Wonderfl.disable_capture();
             
			// SWF設定
			stage.frameRate = 24
			stage.quality = StageQuality.HIGH;
			var bg:Sprite = new Sprite();
			bg.graphics.beginFill(0xffffff);
			bg.graphics.drawRect(0, 0, STAGE_W, STAGE_H);
			addChild(bg);
			
			// ランダム用関数
			_randomFunction = null;
			
			// タイトル表示
			_titleTf = new TextField();
			_titleTf.width = STAGE_W;
			_titleTf.height = 20;
			_titleTf.text = "ランダムパターンのテストと紹介をするよ！";
			addChild(_titleTf);
			
			// 説明文表示
			_captionTf = new TextField();
			_captionTf.width = STAGE_W;
			_captionTf.height = 80;
			_captionTf.y = 25;
			_captionTf.text = "キーの左右で、ランダムの種類を切り替えるよ。\n下のグラフに、ランダムの分布結果が出るよ";
			addChild(_captionTf);
			
			// グラフを用意
			_chart = new RandomChart(CHART_W, CHART_H);
			_chart.x = 82;
			_chart.y = 100;
			addChild(_chart);
			
			// キーイベント
			stage.addEventListener(KeyboardEvent.KEY_DOWN, key);
			
			// フレームイベント
			stage.addEventListener(Event.ENTER_FRAME, frame);
		}
		private function key(event:KeyboardEvent):void{	// キーイベント
			// キーの左右で切り替え
			if (event.keyCode == 39) changeRandomList(1);
			if (event.keyCode == 37) changeRandomList(-1);
		}
		private function changeRandomList(lr:int):void{	// ランダムの関数を切り替えて、グラフをリセットするよ。
			if (_patternNum == -1) _patternNum = 0;
			else _patternNum = (_patternNum + lr + _patternList.length)%_patternList.length;
			var pattern:Object = _patternList[_patternNum];
			_titleTf.text = pattern.name;
			_captionTf.text = pattern.caption;
			_randomFunction = pattern.func;
			_chart.reset();	// リセット;
			_calc = true;	// 計算ループ開始
		}
		
		private function frame(event:Event):void{	// フレームイベント
			if (_calc) calcChart();
		}
		private function calcChart():void{	// ランダムを計算して、グラフに反映
			for (var i:int = 0; i < 500; i++){
				_chart.addValue(_randomFunction());
				if (_chart.isMax()){	// どこかが一番上まで行ったら
					_calc = false;	// 計算ループ終了
					break;
				}
			}
		}
		
		// =======================================================以下がランダム関数
		
		private var _patternList:Array = [
			{name:"普通のランダム",	func:normalRandom,	caption:"0～1の出現率が一定になる。\n上に行くにしたがってバラつきが出るのは全共通。"},
			{name:"平方ランダム１",	func:powerRandom,	caption:"ランダムを２乗したもの。\n0付近が露骨に多くなるのが特徴。"},
			{name:"平方ランダム２",	func:powerRandom2,	caption:"ランダムを２回出し、それをかけたもの。\n前のものより、0の露骨さが減り、なめらかになる。"},
			{name:"平方根ランダム",	func:sqrtRandom,	caption:"ランダムをルートで囲ったもの。\n0に近づくにつれ、綺麗に出現度が減る。\n使いやすい。"},
			{name:"２ランダムの和",	func:plusRandom2,	caption:"ランダムを２回出し、足したもの。\n中央付近が高い３角形になる。\nサイコロを２個振ると合計６付近が出やすいのはこのため。"},
			{name:"３ランダムの和",	func:plusRandom3,	caption:"ランダムを３回出し、足したもの。\n中央付近が高い、正規分布に似た形になる。\n自然物などをそれっぽく見せるのに有用。"},
			{name:"指定割合ランダム",	func:oddsRandom_0,
				caption:"ゲームによく使われる整数指定のランダム。\n指定した数の割合でランダムを出してくれる。\n今回の指定は[5, 10, 10, 20, 10, 8, 5, 0, 10, 20]\n戻り値が整数なのでグラフ上は飛び飛びになる。"},
			{name:"変形4平方ランダム balance=0.5 velvet=0.3",	func:transRandom4_0,
				caption:"ちょっと自由なランダム分布が作れるオリジナル関数。\nbalance=0.5 velvet=0.3を指定すると、中央の高い正規分布風に。"},
			{name:"変形4平方ランダム balance=0.3 velvet=0.2",	func:transRandom4_1,
				caption:"ちょっと自由なランダム分布が作れるオリジナル関数。\nbalance=0.3 velvet=0.6を指定すると、左側にずれたドーム型分布に。"},
			{name:"変形4平方ランダム balance=1.0 velvet=0.5",	func:transRandom4_2,
				caption:"ちょっと自由なランダム分布が作れるオリジナル関数。\nbalance=1.0 velvet=0.5を指定すると、1付近がなだらかに高い分布に。"},
		]
		
		// 普通のランダム。
		public function normalRandom():Number{
			return Math.random();
		}
		
		// 平方ランダム。
		public function powerRandom():Number{
			return Math.pow(Math.random(), 2);
		}
		
		// 平方ランダムその２。
		public function powerRandom2():Number{
			return Math.random()*Math.random();
		}
		
		// 平方根ランダム。
		public function sqrtRandom():Number{
			return Math.sqrt(Math.random());
		}
		
		// ２ランダムの和。
		public function plusRandom2():Number{
			return (Math.random()+Math.random())/2
		}
		
		// ３ランダムの和。
		public function plusRandom3():Number{
			return (Math.random()+Math.random()+Math.random())/3
		}
		
		// 指定割合ランダム
		public function oddsRandom_0():Number{
			var odds:Array = [5, 10, 10, 20, 10, 8, 5, 0, 10, 20];
			return oddsRandom(odds) / odds.length;	// グラフ描画の関係上、１以下の数にして返す。
		}
		/* 
		    指定割合ランダム
		    指定された配列の割合に沿って整数値を返す。
		*/
		public static function oddsRandom(arg:Array):int{
			if (arg.length == 0) return 0;
			var maxNum:Number = 0;
			var i:int;
			for (i = 0; i < arg.length; i++){
				if (isNaN(arg[i])) continue;
				maxNum += arg[i];
			}
			var mainRandom:Number = int(Math.random()*maxNum);
			for (i = 0; i < arg.length; i++){
				if (isNaN(arg[i])) continue;
				
				mainRandom -= arg[i];
				if (mainRandom < 0){
					return i;
				}
			}
			return -1;	// 数値なしError
		}
		
		// 変形4平方ランダム。balance=0.5 velvet=0.3
		public function transRandom4_0():Number{
			return transRandom4(0.5, 0.3);
		}
		// 変形4平方ランダム。balance=0.3 velvet=0.6
		public function transRandom4_1():Number{
			return transRandom4(0.3, 0.6);
		}
		// 変形4平方ランダム。balance=1.0 velvet=0.5
		public function transRandom4_2():Number{
			return transRandom4(1.0, 0.5);
		}
		/* 
		   変形4平方ランダム。
		   値に沿ってrandomの割合を変換して返す。
		   中心点に設定した部分が一番確率が高く、両脇の確率がほぼ０になる。
		   
		   balance - 中心点の位置。0～1で指定する。省略すれば0.5
		   velvet  - なだらかさ。0～1で指定する。
		   　　　　　0で尖った形（人←こんなん）、0.2で３角形、0.3で正規分布に近く、
		   　　　　　0.5～0.7でドーム型、0.9で台形になり、1は普通のランダムと同じ一様な分布となる
		   　　　　　省略すれば0.3
		 */
		public function transRandom4(balance:Number = 0.5, velvet:Number = 0.3):Number{
			var ans:Number;
			var sqrtFunctionY:Number;
			var reBalance:Number;
			var x:Number;
			x = Math.random();
			if (x < balance){
				sqrtFunctionY = sqrt4(x / balance) * balance;
			}else{
				reBalance = 1 - balance;
				sqrtFunctionY= -sqrt4((1 - x)/reBalance) * reBalance + 1;
			}
			ans = sqrtFunctionY*(1 - velvet) + x * velvet;
			return ans;
		}
		private function sqrt4(arg:Number):Number{
			return Math.sqrt(Math.sqrt(arg));
		}
	}
}
	import flash.display.Sprite;
	
class RandomChart extends Sprite{
	
	private var _w:int;
	private var _h:int;
	private var _rate:Number;
	private var _isMax:Boolean = false;
	
	private var _valueList:Array;
	private var _markerList:Array;
	
	function RandomChart(w:int, h:int, rate:Number = 1){
		_w = w;
		_h = h;
		_rate = rate;
		_markerList = [];
		for (var i:int = 0; i < _w; i++){
			var marker:Marker = new Marker();
			_markerList.push(marker);
			addChild(marker);
			marker.x = i;
		}
		graphics.lineStyle(0, 0xffaa22);
		graphics.moveTo(0, 0);
		graphics.lineTo(0, h);
		graphics.lineTo(w, h);
		
		reset();
	}
	
	public function reset():void{
		_isMax = false;
		_valueList = [];
		for (var i:int = 0; i < _w; i++){
			_valueList.push(0);
			moveMarkerY(i);
		}
	}
	
	public function addValue(value:Number):void{
		var num:int = int(value * _w);
		_valueList[num]+=_rate;
		moveMarkerY(num);
		if (_h <= _valueList[num]) _isMax = true;
	}
	private function moveMarkerY(num:int):void{
		var marker:Marker = _markerList[num];
		marker.y = _h - _valueList[num];
	}
	
	public function isMax():Boolean{
		return _isMax;
	}
}
class Marker extends Sprite{
	function Marker(){
		graphics.beginFill(0x88cc22, 0.4);
		graphics.drawRect(-3, -3, 6, 6);
		graphics.endFill();
	}
}

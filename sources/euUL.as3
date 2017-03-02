/*
Math.sin()を毎回計算するよりも、
あらかじめ変換テーブルを作っておいて、近似値を参照する方が、
精度はちょっと劣りつつも、早ささの面で使えるかもしれない。

ブラシュアップ。
index値の求め方を変更した_a1bを追加。
len/(Math.PI*2)を定数としてあらかじめ計算しておく。
(ran[i]%PI2)*LENdivPI2 & len2


もっとブラシュアップ
index値の求め方を変更した_a1cを追加。
ran[i]*LENdivPI2 & len2

「ran[i]*LENdivPI2」の値が、計算範囲内であることを前提のブラシュアップ
超えるようであれば、(ran[i]%PI2)をする。


クラス化してみた。


＝＝＝＝以下結果例＝＝＝＝
◆Math.sin()を計算するより、変換テーブルを作って参照した方が精度は劣るが早い。

Sin(0)〜Sin(2*Math.PI)を65536段階で、sinTable:Vector.<Number>に入れる。

変換テーブルの作成時間：60
_a0：183：普通にMath.sinで計算。
_a1c：28：sinTableを参照もっとブラシュアップ版
_a2c：113：sinTableの参照もっとブラシュアップ版を関数化
_a2d：116：sinTableの参照もっとブラシュアップ版をクラス化
_a99：92：対照用に0を返すだけの関数


試しに20個、Math.sinとsinTableで求めた値との比較をする。
0.000011295614069428694
0.000018468081231148327
-0.000048742107041879756
0.00006136495014702481
-0.000005346027467822978
0.00008947552124638491
-0.00003862500423407189
-0.000013733251637670918
-0.00005233214434591238
-0.000009970360831168534
-0.00005403697863781698
0.000026028611143202873
0.000004722851165483988
-0.0000010851409804057965
0.000041016223552126085
-0.00004906400100462838
0.00004841687776591108
-0.000015632646815588735
0.00006041626474262429
0.00006274562401942241
＝＝＝＝以上結果例＝＝＝＝


誤差1/10000以下の精度が出ているので、
多くの場合、これで足りるはず。

100万段階くらいの精度だと、
普通にMath.sinで計算するのとあまり変わらなくなってしまう。

ただし、同じ角度でMath.cosとMath.sinを求める場合は、
段階/4ずらせば良い（sin,cosカーブが一致する）だけなので、
Mathrix3Dなどの計算の際は計算コストを下げることができるのかも。


関数化はFlashPlayerのバージョンによって、遅い場合もあるので注意。


いずれにしても、大量に計算するのでなければ、
普通にMath.sinを使った方がいいのでそこは注意。



参考
Game Programming Gems 2
http://www.amazon.co.jp/gp/product/4939007332/
*/
package {
	import flash.display.Sprite;
	import flash.geom.Vector3D;
	import flash.text.TextField;
	public class Main extends Sprite {
		public var ran:Vector.<Number> = new Vector.<Number>(10000000,true);
		private const len:int=(0xFFFF+1);
		private const len2:int=len-1;
		private const PI2:Number=Math.PI*2;
		private const PI:Number=Math.PI;
		private const LENdivPI2:Number=len/(Math.PI*2);
		private var sinTable:Vector.<Number>=new Vector.<Number>(len,true);
		private var myMas:Mas = new Mas();
		public function Main():void {
			var _str:String = new String();
			_str+="◆Math.sin()を計算するより、変換テーブルを作って参照した方が精度は劣るが早い。\n\n";
			_str+="Sin(0)〜Sin(2*Math.PI)を"+len+"段階で、sinTable:Vector.<Number>に入れる。\n\n";

			var time:Number = (new Date()).getTime();
			for (var i:int=0; i<len; i++) {
				sinTable[i]=Math.sin(Math.PI*i/len << 1);
			}
			_str += "変換テーブルの作成時間："+((new Date()).getTime() - time)+"\n";

			for (var j:int=0; j<10000000; j++) {
				ran[j]=Math.random()*200-100;
			}

			benchMarkj(_a0);
			//benchMarkj(_a1);
			//benchMarkj(_a1b);
			benchMarkj(_a2c);
			benchMarkj(_a2d);
			benchMarkj(_a99);
			
			
			_str+="_a0："+benchMarkj(_a0)+"：普通にMath.sinで計算。\n";
			
			//_str+="_a1："+benchMarkj(_a1)+"：sinTableを参照\n";
			//_str+="_a1b："+benchMarkj(_a1b)+"：sinTableを参照ブラシュアップ版\n";
			_str+="_a1c："+benchMarkj(_a1c)+"：sinTableを参照もっとブラシュアップ版\n";
			_str+="_a2c："+benchMarkj(_a2c)+"：sinTableの参照もっとブラシュアップ版を関数化\n";
			_str+="_a2d："+benchMarkj(_a2d)+"：sinTableの参照もっとブラシュアップ版をクラス化\n";
			_str+="_a99："+benchMarkj(_a99)+"：対照用に0を返すだけの関数\n\n\n";

			_str+="試しに20個、Math.sinとsinTableで求めた値との比較をする。\n";
			
			var numSum:Number = 0;
			for (j=0; j<20; j++) {
				var k:int=Math.random()*len;
				_str += Math.sin(ran[k])-myMas.sin(ran[k])+"\n";
			}
			
			var text_field:TextField = new TextField();
			text_field.width=stage.stageWidth;
			text_field.height=stage.stageHeight;
			stage.addChild(text_field);
			text_field.text=_str;
		}

		//100万回関数を実行して、かかった時間をreturn 
		private function benchMarkj(_fn:Function):int {
			var time:Number = (new Date()).getTime();
			_fn(1000000);
			return (new Date()).getTime() - time;
		}

		private function _a0(n:uint):void {
			for (var i:int = 0; i < n; i++) {
				Math.sin(ran[i]);
			}
		}

		private function _a1(n:uint):void {
			for (var i:int = 0; i < n; i++) {
				sinTable[((ran[i]%PI2+PI2)%PI2)*len/PI2 >> 0];
			}
		}

		private function _a1b(n:uint):void {
			for (var i:int = 0; i < n; i++) {
				sinTable[(ran[i]%PI2)*LENdivPI2 & len2];
			}
		}
		
		private function _a1c(n:uint):void {
			for (var i:int = 0; i < n; i++) {
				sinTable[ran[i]*LENdivPI2 & len2];
			}
		}
		
		private function _a2c(n:uint):void {
			for (var i:int = 0; i < n; i++) {
				sin(ran[i]);
			}
		}
		private function _a2d(n:uint):void {
			for (var i:int = 0; i < n; i++) {
				myMas.sin(ran[i]);
			}
		}

		private function _a99(n:uint):void {
			for (var i:int = 0; i < n; i++) {
				zero();
			}
		}
		private function zero():Number {
			return 0;
		}

		private function sin(n:Number):Number {
			return sinTable[n*LENdivPI2 & len2];
		}
	}
}

class Mas{
	private const len:int=(0xFFFF+1);
	private var sinTable:Vector.<Number>=new Vector.<Number>(len,true);
	private const len2:int=len-1;
	private const LENdivPI2:Number=len/(Math.PI*2);
	function Mas(){
		for (var i:int=0; i<len; i++) {
			sinTable[i]=Math.sin(2*Math.PI*i/len);
		}
	}
	public function sin(n:Number):Number {
		return sinTable[n*LENdivPI2 & len2];
	}
}
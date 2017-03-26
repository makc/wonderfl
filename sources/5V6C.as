/*
Matrix3D.append();
と同じ機能の関数を作ってみる。
MAC 10,0,2,54,MAC 10,0,12,36,MAC 10,0,22,87で動作確認。


各要素をrandomで-100〜100の値を入れて、appendする。
小数点2桁目の誤差が出る場合がある。

極基本的な計算で間違い用が無いはずなので
内部的な値の管理が根本的に違うのかも。

ところどころ20倍しているところがあるけど、なんでこうなるかはよくわかんない。

【追記】
10,0,22,87で20倍のバグは無くなった模様。


http://help.adobe.com/ja_JP/AS3LCR/Flash_10.0/flash/geom/Matrix3D.html#append()

*/
package {
	import flash.display.Sprite;
	import flash.geom.Matrix3D;
	import flash.text.TextField;
	import flash.geom.Vector3D;
	import flash.system.Capabilities;
	public class Main extends Sprite {
		public function Main() {
			var txt:String="◆同機能関数Mtrx3D.append　"+Capabilities.version+"での実行結果\n\n";
			
			//確認用の値を用意
			var entity:Matrix3D=new Matrix3D(Util.random16());
			var parameter:Matrix3D=new Matrix3D(Util.random16());
			var entity1:Matrix3D=entity.clone();
			var entity2:Matrix3D=entity.clone();
			var parameter1:Matrix3D=parameter.clone();
			var parameter2:Matrix3D=parameter.clone();
			
			//実行
			entity1.append(parameter1);
			Mtrx3D.append(entity2,parameter2);
			
			//確認
			var entity1RawData:Vector.<Number>=entity1.rawData;
			txt+="↓Matrix3D.appendの結果\n"+entity1RawData+"\n";
			var entity2RawData:Vector.<Number>=entity2.rawData;
			txt+="\n↓同機能関数Mtrx3D.appendの結果\n"+entity2RawData+"\n\n";
			txt+=Util.hikaku(entity1RawData,entity2RawData);
			
			//テキストフィールドを作りtxtを流し込み。
			var tf:TextField = new TextField();
			tf.width=stage.stageWidth;
			tf.height=stage.stageHeight;
			tf.wordWrap=true;
			stage.addChild(tf);
			tf.text=txt;
		}
	}
}
import flash.display.Sprite;
class Mtrx3D extends Sprite {
	import flash.geom.Matrix3D;
	public static function append(_entity:Matrix3D,_parameter:Matrix3D):void {
		var e:Vector.<Number>=_entity.rawData;
		var p:Vector.<Number>=_parameter.rawData;
		var pe:Vector.<Number> = new Vector.<Number>();
		
		//バグ対応。10,0,22,87未満の場合バグを含むように。
		var bug:int = 1;
		if(Util.version() <1000022087){
			bug = 20;
		}
		
		pe[0] = p[0]*e[0]+p[4]*e[1]+p[8]*e[2]+p[12]*e[3]*bug;
		pe[1] = p[1]*e[0]+p[5]*e[1]+p[9]*e[2]+p[13]*e[3]*bug;
		pe[2] = p[2]*e[0]+p[6]*e[1]+p[10]*e[2]+p[14]*e[3]*bug;
		pe[3] = p[3]*e[0]+p[7]*e[1]+p[11]*e[2]+p[15]*e[3];

		pe[4] = p[0]*e[4]+p[4]*e[5]+p[8]*e[6]+p[12]*e[7]*bug;
		pe[5] = p[1]*e[4]+p[5]*e[5]+p[9]*e[6]+p[13]*e[7]*bug;
		pe[6] = p[2]*e[4]+p[6]*e[5]+p[10]*e[6]+p[14]*e[7]*bug;
		pe[7] = p[3]*e[4]+p[7]*e[5]+p[11]*e[6]+p[15]*e[7];

		pe[8] = p[0]*e[8]+p[4]*e[9]+p[8]*e[10]+p[12]*e[11]*bug;
		pe[9] = p[1]*e[8]+p[5]*e[9]+p[9]*e[10]+p[13]*e[11]*bug;
		pe[10] = p[2]*e[8]+p[6]*e[9]+p[10]*e[10]+p[14]*e[11]*bug;
		pe[11] = p[3]*e[8]+p[7]*e[9]+p[11]*e[10]+p[15]*e[11];

		pe[12] = p[0]*e[12]+p[4]*e[13]+p[8]*e[14]+p[12]*e[15];
		pe[13] = p[1]*e[12]+p[5]*e[13]+p[9]*e[14]+p[13]*e[15];
		pe[14] = p[2]*e[12]+p[6]*e[13]+p[10]*e[14]+p[14]*e[15];
		pe[15] = p[3]*e[12]*bug+p[7]*e[13]*bug+p[11]*e[14]*bug+p[15]*e[15];

		_entity.rawData=pe;
	}
}
class Util {
	import flash.system.Capabilities;	
	public static function version():uint{
		var ver_array:Array = Capabilities.version.substr(4).split(",");
		return int(ver_array[0])*100000000+int(ver_array[1])*1000000+int(ver_array[2])*1000+int(ver_array[3]);
	}
	
	public static function hikaku(v0:Vector.<Number>,v1:Vector.<Number>):String {
		var _str:String="↓二つのMatrixの要素毎の差\n";
		var _n:int=v0.length;
		for (var i:int=0; i<_n; i++) {
			_str += "["+i+"]:"+(v0[i]-v1[i])+"\n";
		}
		return _str;
	}

	public static function random16():Vector.<Number> {
		var _v:Vector.<Number>=new Vector.<Number>(16,true);
		for (var i:int=0; i<16; i++) {
			_v[i]=Math.random()*200-100;
		}
		return _v;
	}
}


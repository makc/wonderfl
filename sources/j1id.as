/*
Matrix3D.clone();
と同じ機能の関数を作ってみる。
MAC 10,0,2,54,MAC 10,0,12,36で動作確認。

処理としては
newして返すだけ。

元のentity行列とは同じだが影響を及ぼさない行列ができる。

各要素にrandomで値を入れて、cloneし、
行列の各要素を比較して確認とした。

Matrix3D.appendTranslation()
http://help.adobe.com/ja_JP/AS3LCR/Flash_10.0/flash/geom/Matrix3D.html#appendTranslation()
*/
package {
	import flash.display.Sprite;
	import flash.geom.Matrix3D;
	import flash.text.TextField;
	import flash.geom.Vector3D;
	import flash.system.Capabilities;
	public class FlashTest extends Sprite {
		public function FlashTest() {
			var tf:TextField = new TextField();
			tf.width=stage.stageWidth;
			tf.height=stage.stageHeight;
			tf.wordWrap=true;
			stage.addChild(tf);
			var txt:String="";
			//
			txt+="◆同機能関数Mtrx3D.clone\n";
			txt+=Capabilities.version+"での実行結果\n\n";
			
			var entity:Matrix3D=new Matrix3D(Util.random16());
			var parameter:Matrix3D=new Matrix3D(Util.random16());
			var entity1:Matrix3D=entity.clone();
			var entity2:Matrix3D=Mtrx3D.clone(entity);
			
			var entity1RawData:Vector.<Number>=entity1.rawData;
			txt+="↓Matrix3D.cloneの結果\n";
			txt+=entity1RawData;
			txt+="\n";

			var entity2RawData:Vector.<Number>=entity2.rawData;

			txt+="\n↓同機能関数Mtrx3D.cloneの結果\n";
			txt+=entity2RawData;
			txt+="\n\n";

			txt+=Util.hikaku(entity1RawData,entity2RawData);


			tf.text=txt;
		}
	}
}
import flash.display.Sprite;
class Mtrx3D extends Sprite {
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	public static function clone(entity:Matrix3D):Matrix3D {
		return new Matrix3D(Vector.<Number>(entity.rawData));
	}
}
class Util {
	public static function hikaku(v0:Vector.<Number>,v1:Vector.<Number>):String {
		var _str:String="↓二つのMatrix3Dの要素毎の差\n";
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
/*
Matrix3D.identity();
と同じ機能の関数を作ってみる。
MAC 10,0,2,54,MAC 10,0,12,36で動作確認。

処理としては
entity行列を単位行列にするだけ。


各要素にrandomで値を入れて、identityし、
行列の各要素を比較して確認とした。

Matrix3D.identity()
http://help.adobe.com/ja_JP/AS3LCR/Flash_10.0/flash/geom/Matrix3D.html#identity()
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
			txt+="◆同機能関数Mtrx3D.identity\n";
			txt+=Capabilities.version+"での実行結果\n\n";

			var entity:Matrix3D=new Matrix3D(Util.random16());
			var parameter:Matrix3D=new Matrix3D(Util.random16());
			var entity1:Matrix3D=entity.clone();
			var entity2:Matrix3D=entity.clone();



			entity1.identity();
			Mtrx3D.identity(entity2);



			var entity1RawData:Vector.<Number>=entity1.rawData;
			var entity2RawData:Vector.<Number>=entity2.rawData;
			txt+="↓Matrix3D.identityの結果\n"+entity1RawData+"\n";
			txt+="\n↓同機能関数Mtrx3D.identityの結果\n"+entity2RawData+"\n\n";
			txt+=Util.hikaku(entity1RawData,entity2RawData);

			tf.text=txt;
		}
	}
}
import flash.display.Sprite;
class Mtrx3D extends Sprite {
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	public static function identity(entity:Matrix3D):void {
		entity.rawData=Vector.<Number>([1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1]);
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
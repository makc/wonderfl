/*
Matrix3D.deltaTransformVector();
と同じ機能の関数を作ってみる。
MAC 10,0,2,54、MAC 10,0,12,36で動作確認。

処理としては
行列にx,y,zを乗算している。
↓こういう普通の乗算
http://www.fumiononaka.com/TechNotes/Flash/FN0811001.html

ただしパラメーターvector3Dのwの値は使わないことに注意。


Matrix3D.deltaTransformVector()
http://help.adobe.com/ja_JP/AS3LCR/Flash_10.0/flash/geom/Matrix3D.html#deltaTransformVector()
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
			txt+="◆同機能関数Mtrx3D.deltaTransformVector\n";
			txt+=Capabilities.version+"での実行結果\n\n";

			var entity:Matrix3D=new Matrix3D(Util.random16());
			var vec3d:Vector3D=new Vector3D(Math.random()*200-100,Math.random()*200-100,Math.random()*200-100,Math.random()*200-100);

			txt+="↓Matrix3D.deltaTransformVectorの結果\n";
			txt+=entity.deltaTransformVector(vec3d)+" , "+entity.deltaTransformVector(vec3d).w;
			txt+="\n";

			txt+="\n↓同機能関数Mtrx3D.deltaTransformVectorの結果\n";
			txt+=Mtrx3D.deltaTransformVector(entity,vec3d)+" , "+Mtrx3D.deltaTransformVector(entity,vec3d).w;
			txt+="\n\n";

			tf.text=txt;
		}
	}
}
import flash.display.Sprite;
class Mtrx3D extends Sprite {
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	public static function deltaTransformVector(entity:Matrix3D,v:Vector3D):Vector3D {
		var e:Vector.<Number>=Vector.<Number>(entity.rawData);
		return new Vector3D((e[0]*v.x+e[4]*v.y+e[8]*v.z),(e[1]*v.x+e[5]*v.y+e[9]*v.z),(e[2]*v.x+e[6]*v.y+e[10]*v.z),(e[3]*v.x+e[7]*v.y+e[11]*v.z));
		/*
		var _v:Vector3D = new Vector3D();
		_v.x = (e[0]*v.x+e[4]*v.y+e[8]*v.z);
		_v.y = (e[1]*v.x+e[5]*v.y+e[9]*v.z);
		_v.z = (e[2]*v.x+e[6]*v.y+e[10]*v.z);
		_v.w = (e[3]*v.x+e[7]*v.y+e[11]*v.z);
		return _v;
		*/
	}
}
class Util {
	import flash.geom.Vector3D;
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
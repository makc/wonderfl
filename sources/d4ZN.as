/*
Matrix3D.appendScale();
と同じ機能の関数を作ってみる。
MAC 10,0,2,54,MAC 10,0,12,36で動作確認。


処理としては
パラメーターで作った行列にentity行列をappendする。

パラメーターで作る行列は
scaleを変えるだけなので対角行列になるが、
これはめんどくさいだけなので、
行列は作らずに、対応する要素毎に乗算するのみ。


各要素をrandomで値を入れて、appendScaleし、
行列の各要素を比較して確認とした。

appendScale
http://help.adobe.com/ja_JP/AS3LCR/Flash_10.0/flash/geom/Matrix3D.html#appendScale()

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
			txt+="◆同機能関数Mtrx3D.appendScale\n";
			txt+=Capabilities.version+"での実行結果\n\n";

			var entity:Matrix3D=new Matrix3D(Util.random16());
			var parameter:Matrix3D=new Matrix3D(Util.random16());
			var entity1:Matrix3D=entity.clone();
			var entity2:Matrix3D=entity.clone();
			var xScale:Number=Math.random()*200-100;
			var yScale:Number=Math.random()*200-100;
			var zScale:Number=Math.random()*200-100;

			entity1.appendScale(xScale,yScale,zScale);
			var entity1RawData:Vector.<Number>=entity1.rawData;
			txt+="↓Matrix3D.appendScaleの結果\n";
			txt+=entity1RawData;
			txt+="\n";

			Mtrx3D.appendScale(entity2,xScale,yScale,zScale);
			var entity2RawData:Vector.<Number>=entity2.rawData;

			txt+="\n↓同機能関数Mtrx3D.appendScaleの結果\n";
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
	public static function appendScale(entity:Matrix3D,xScale:Number,yScale:Number,zScale:Number):void {
		var e:Vector.<Number>=Vector.<Number>(entity.rawData);
		e[0]*=xScale;
		e[1]*=yScale;
		e[2]*=zScale;
		e[4]*=xScale;
		e[5]*=yScale;
		e[6]*=zScale;
		e[8]*=xScale;
		e[9]*=yScale;
		e[10]*=zScale;
		e[12]*=xScale;
		e[13]*=yScale;
		e[14]*=zScale;
		entity.rawData=e;
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
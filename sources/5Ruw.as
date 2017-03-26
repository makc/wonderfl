/*

Matrix3D.appendRotation();
と同じ機能の関数を作ってみる。
MAC 10,0,2,54,MAC 10,0,12,36で動作確認。


各要素をrandomで値を入れて、appendRotationする。


appendRotationはAXIS_ANGLEで値を受け取るので、Matrix3Dに変換後appendする。
pivotPointのぶん、移動する。
AXIS_ANGLE to Matrix3Dは下記blogエントリーを参考にした。
http://blog.livedoor.jp/take_z_ultima/archives/51383303.html


小数点6桁目あたりから誤差が出る場合がある。
内部的な値の管理が根本的に違うのかも。

pivotPoint.x,y,zを1/20しているけど、なんでこうなるかはよくわかんない。

appendRotation
http://help.adobe.com/ja_JP/AS3LCR/Flash_10.0/flash/geom/Matrix3D.html#appendRotation()
AXIS_ANGLE
http://help.adobe.com/ja_JP/AS3LCR/Flash_10.0/flash/geom/Orientation3D.html#AXIS_ANGLE

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
			txt+="◆同機能関数Mtrx3D.appendRotation\n";
			txt+=Capabilities.version +"での実行結果\n\n";


			var entity:Matrix3D=new Matrix3D(Util.random16());
			var parameter:Matrix3D=new Matrix3D(Util.random16());
			var entity1:Matrix3D=entity.clone();
			var entity2:Matrix3D=entity.clone();
			var degrees:Number = Math.random()*360-180;
			var axis:Vector3D = new Vector3D(Math.random()-0.5,Math.random()-0.5,Math.random()-0.5);
			var pivotPoint:Vector3D = new Vector3D(Math.random()*200-100,Math.random()*200-100,Math.random()*200-100);
			axis.normalize();
			entity1.appendRotation(degrees,axis);
			var entity1RawData:Vector.<Number>=entity1.rawData;
			txt+="↓Matrix3D.appendRotationの結果\n";
			txt+=entity1RawData;
			txt+="\n";

			Mtrx3D.appendRotation(entity2,degrees,axis);
			var entity2RawData:Vector.<Number>=entity2.rawData;

			txt+="\n↓同機能関数Mtrx3D.appendRotationの結果\n";
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
	public static function appendRotation(entity:Matrix3D,degrees:Number,axis:Vector3D,pivotPoint:Vector3D=null):void {
		if(!pivotPoint){
			pivotPoint = new Vector3D(0,0,0);
		}
		axis.normalize();
		var w:Number = Math.cos(degrees/360*Math.PI);
		var x:Number = Math.sin(degrees/360*Math.PI)*axis.x;
		var y:Number = Math.sin(degrees/360*Math.PI)*axis.y;
		var z:Number = Math.sin(degrees/360*Math.PI)*axis.z;
		var p:Vector.<Number> = new Vector.<Number>(16,true);
		p[0] = (w*w+x*x-y*y-z*z);
		p[1] = 2*(y*x+w*z);
		p[2] = 2*(z*x-w*y);
		p[3] = 0;
		p[4] = 2*(y*x-w*z);
		p[5] = (w*w-x*x+y*y-z*z);
		p[6] = 2*(w*x+z*y);
		p[7] = 0;
		p[8] = 2*(z*x+w*y);
		p[9] = 2*(z*y-w*x);
		p[10] = (w*w-x*x-y*y+z*z);
		p[11] = 0;
		p[12] = 0;
		p[13] = 0;
		p[14] = 0;
		p[15] = (x*x+y*y+z*z+w*w);
		var e:Vector.<Number> = entity.rawData;
		var pe:Vector.<Number> = new Vector.<Number>(16,true);
		pe[0] = p[0]*e[0]+p[4]*e[1]+p[8]*e[2]+p[12]*e[3];
		pe[1] = p[1]*e[0]+p[5]*e[1]+p[9]*e[2]+p[13]*e[3];
		pe[2] = p[2]*e[0]+p[6]*e[1]+p[10]*e[2]+p[14]*e[3];
		pe[3] = p[3]*e[0]+p[7]*e[1]+p[11]*e[2]+p[15]*e[3];
		pe[4] = p[0]*e[4]+p[4]*e[5]+p[8]*e[6]+p[12]*e[7];
		pe[5] = p[1]*e[4]+p[5]*e[5]+p[9]*e[6]+p[13]*e[7];
		pe[6] = p[2]*e[4]+p[6]*e[5]+p[10]*e[6]+p[14]*e[7];
		pe[7] = p[3]*e[4]+p[7]*e[5]+p[11]*e[6]+p[15]*e[7];
		pe[8] = p[0]*e[8]+p[4]*e[9]+p[8]*e[10]+p[12]*e[11];
		pe[9] = p[1]*e[8]+p[5]*e[9]+p[9]*e[10]+p[13]*e[11];
		pe[10] = p[2]*e[8]+p[6]*e[9]+p[10]*e[10]+p[14]*e[11];
		pe[11] = p[3]*e[8]+p[7]*e[9]+p[11]*e[10]+p[15]*e[11];
		pe[12] = p[0]*e[12]+p[4]*e[13]+p[8]*e[14]+p[12]*e[15]+pivotPoint.x/20;
		pe[13] = p[1]*e[12]+p[5]*e[13]+p[9]*e[14]+p[13]*e[15]+pivotPoint.y/20;
		pe[14] = p[2]*e[12]+p[6]*e[13]+p[10]*e[14]+p[14]*e[15]+pivotPoint.z/20;
		pe[15] = p[3]*e[12]+p[7]*e[13]+p[11]*e[14]+p[15]*e[15];
		entity.rawData = pe;
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


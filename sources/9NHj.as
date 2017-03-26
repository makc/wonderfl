/*
【未完成】
Matrix3D.interpolate();
と同じ機能の関数を作ってみる。
MAC 10,0,2,54,MAC 10,0,12,36で動作確認。

処理としては
行列をクオータニオンにしてから、
球面線形補完(slerp)で、補完行列を作り返す。

【未完成】なのは、scaleが(1,1,1)の場合にしか上手く行かないから。
squadを使うのかな、、、


◆確認方法
平行移動と回転にrandomを入れてrecomposeしたものを、
interpolateし、行列の各要素を比較して確認とした。

参考
直接の参照先は「実例で学ぶゲーム3D数学」P172だけど、

↓これらも参考になると思う。勉強中
床井研究室 - ゲームグラフィックス特論
http://marina.sys.wakayama-u.ac.jp/~tokoi/?date=20040430
クォータニオン同士を球面線形補間する
http://hakuhin.hp.infoseek.co.jp/main/as/quaternion.html#QUAT_10
その10 クォータニオンを学んでみよう！
http://marupeke296.com/DXG_No10_Quaternion.html

Matrix3D.interpolate()
http://help.adobe.com/ja_JP/AS3LCR/Flash_10.0/flash/geom/Matrix3D.html#interpolate()
【未完成】
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
			txt+="◆同機能関数Mtrx3D.interpolate　"+Capabilities.version+"での実行結果\n\n";

			var parameter1:Matrix3D=new Matrix3D(Util.random9());
			var parameter2:Matrix3D=new Matrix3D(Util.random9());
			var parameter1a:Matrix3D=parameter1.clone();
			var parameter1b:Matrix3D=parameter1.clone();
			var parameter2a:Matrix3D=parameter2.clone();
			var parameter2b:Matrix3D=parameter2.clone();
			var percent:Number=Math.random();
			
			
			var entity1RawData:Vector.<Number>=Matrix3D.interpolate(parameter1a,parameter2a,percent).rawData;
			var entity2RawData:Vector.<Number>=Mtrx3D.interpolate(parameter1b,parameter2b,percent).rawData;
			
			
			txt+="↓Matrix3D.interpolateの結果\n"+entity1RawData+"\n";
			txt+="\n↓同機能関数Mtrx3D.interpolateの結果\n"+entity2RawData+"\n\n";
			txt+=Util.hikaku(entity1RawData,entity2RawData);
			
			tf.text=txt;
		}
	}
}
import flash.display.Sprite;
class Mtrx3D extends Sprite {
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	public static function interpolate(thisMat:Matrix3D,toMat:Matrix3D,percent:Number):Matrix3D{
		var v0:Vector3D = thisMat.decompose("quaternion")[1];
		var v1:Vector3D = toMat.decompose("quaternion")[1];
		var cosOmega:Number = v0.w*v1.w + v0.x*v1.x + v0.y*v1.y + v0.z*v1.z;
		if(cosOmega < 0){
			v1.x = -v1.x;
			v1.y = -v1.y;
			v1.z = -v1.z;
			v1.w = -v1.w;
			cosOmega = -cosOmega;
		}
		var k0:Number;
		var k1:Number;
		if(cosOmega > 0.9999){
			k0 = 1 - percent;
			k1 = percent;
		}else{
			var sinOmega:Number = Math.sqrt(1 - cosOmega*cosOmega);
			var omega:Number = Math.atan2(sinOmega,cosOmega);
			var oneOverSinOmega:Number = 1/sinOmega;
			k0 = Math.sin((1-percent)*omega)*oneOverSinOmega;
			k1 = Math.sin(percent*omega)*oneOverSinOmega;
		}
		var scale_x:Number = thisMat.decompose("quaternion")[2].x*(1-percent) + toMat.decompose("quaternion")[2].x*percent;
		var scale_y:Number = thisMat.decompose("quaternion")[2].y*(1-percent) + toMat.decompose("quaternion")[2].y*percent;
		var scale_z:Number = thisMat.decompose("quaternion")[2].z*(1-percent) + toMat.decompose("quaternion")[2].z*percent;
		
		var tx:Number = thisMat.decompose("quaternion")[0].x*(1-percent) + toMat.decompose("quaternion")[0].x*percent;
		var ty:Number = thisMat.decompose("quaternion")[0].y*(1-percent) + toMat.decompose("quaternion")[0].y*percent;
		var tz:Number = thisMat.decompose("quaternion")[0].z*(1-percent) + toMat.decompose("quaternion")[0].z*percent;
		
		//trace(thisMat.decompose("quaternion")[2].x,toMat.decompose("quaternion")[2].x,scale_x)
		
		var x:Number = v0.x*k0+v1.x*k1;
		var y:Number = v0.y*k0+v1.y*k1;
		var z:Number = v0.z*k0+v1.z*k1;
		var w:Number = v0.w*k0+v1.w*k1;
		var _q:Vector.<Number> = new Vector.<Number>(16,true);
		_q[0] = 1-2*y*y-2*z*z;
		_q[1] = 2*x*y+2*w*z;
		_q[2] = 2*x*z-2*w*y;
		_q[3] = 0;
		_q[4] = 2*x*y-2*w*z;
		_q[5] = 1-2*x*x-2*z*z;
		_q[6] = 2*y*z+2*w*x;
		_q[7] = 0;
		_q[8] = 2*x*z+2*w*y;
		_q[9] = 2*y*z-2*w*x;
		_q[10] = 1-2*x*x-2*y*y;
		_q[11] = 0;
		_q[12] = tx;
		_q[13] = ty;
		_q[14] = tz;
		_q[15] = 1;
		//trace(_q)
		
		var v:Vector3D = new Vector3D(v0.x*k0+v1.x*k1,v0.y*k0+v1.y*k1,v0.z*k0+v1.z*k1,v0.w*k0+v1.w*k1);
		
		//var txyz:Vector3D = new Vector3D(tx,ty,tz);
		//var m:Matrix3D=new Matrix3D();
		//m.recompose(Vector.<Vector3D>([txyz,v,new Vector3D(scale_x,scale_y,scale_z)]),"quaternion");
		//trace(m.rawData);
		return new Matrix3D(_q);
	}
}
class Util {
	import flash.geom.Matrix3D;
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
	public static function random9():Vector.<Number>{
		var _mt:Matrix3D = new Matrix3D();
		var v:Vector.<Vector3D>=new Vector.<Vector3D>;
		v[0]=new Vector3D(200*Math.random()-100,200*Math.random()-100,200*Math.random()-100);//平行移動、
		v[1]=new Vector3D(10*Math.random()-5,10*Math.random()-5,10*Math.random()-5);//回転
		//v[2]=new Vector3D(100*Math.random(),100*Math.random(),100*Math.random());//拡大 / 縮小
		v[2]=new Vector3D(1,1,1);//拡大 / 縮小
		_mt.recompose(v);
		return _mt.rawData;
	}
}
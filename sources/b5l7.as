// forked from umhr's Matrix3D.decompose()の動作確認。
/*
Matrix3D.decompose();
と同じ機能の関数を作ってみる。
MAC 10,0,2,54、MAC 10,0,12,36で動作確認。

処理としては
entity行列を元に、オイラー角、クオータニオン、軸角度方向の各書式で、
平行移動量、回転、スケールを返す。
要はmatrix3dToEulerAngleとmatrix3dToQuaternion(axisAngle)を作ればいい。

だいぶ本に助けられた。
オライリーの「実例で学ぶゲーム3D数学」
http://www.amazon.co.jp/gp/product/4873113776

各要素にrandomで値を入れて、各要素を比較して確認とした。

たまに、符号がMatrix3D.decomposeと異なることがあるけど、
逆方向を向いて後ろ歩きしているような符号、かも。
この点をまだ理解しきれてないので、完全にはできてない。
っていうか、MAC 10,0,12,36だと、誤差が結構おおきい、、汗。
やっぱバグの疑いが無くなってからやるべきだったか、、、。

◆追記
やっぱり、10,0,12,36でappendからprependにrotationの仕方がかわったからっぽい。
調整中


Matrix3D.decompose()
http://help.adobe.com/ja_JP/AS3LCR/Flash_10.0/flash/geom/Matrix3D.html#decompose()
*/
package {
	import flash.display.Sprite;
	import flash.geom.Matrix3D;
	import flash.text.TextField;
	import flash.geom.Vector3D;
	import flash.system.Capabilities;
	public class FlashTest extends Sprite {
		public function FlashTest() {
			var txt:String="◆同機能関数Mtrx3D.decompose　"+Capabilities.version+"での実行結果\n\n";
			
			//確認用の値を用意
			var entity:Matrix3D=new Matrix3D(Util.random9());
			
			//実行
			var Matrix3DEA:Vector.<Vector3D> = entity.decompose("eulerAngles");
			var Matrix3DQ:Vector.<Vector3D> = entity.decompose("quaternion");
			var Matrix3DAA:Vector.<Vector3D> = entity.decompose("axisAngle");
			var Mtrx3DEA:Vector.<Vector3D> = Mtrx3D.decompose(entity,"eulerAngles");
			var Mtrx3DQ:Vector.<Vector3D> = Mtrx3D.decompose(entity,"quaternion");
			var Mtrx3DAA:Vector.<Vector3D> = Mtrx3D.decompose(entity,"axisAngle");
			
			//確認
			txt+="↓Matrix3D.decomposeの結果\n";
			txt+="eulerAngles:"+Matrix3DEA+"\n";
			//txt+="quaternion"+Matrix3DQ+Matrix3DQ[1].w+"\n";
			//txt+="axisAngle"+Matrix3DAA+Matrix3DAA[1].w+"\n";
			txt+="\n";
			txt+="↓同機能関数Mtrx3D.decomposeの結果\n";
			txt+="eulerAngles"+Mtrx3DEA+"\n";
			//txt+="quaternion"+Mtrx3DQ+Mtrx3DQ[1].w+"\n";
			//txt+="axisAngle"+Mtrx3DAA+Mtrx3DAA[1].w+"\n";
			txt+="\n"+Util.hikaku2(Matrix3DEA,Mtrx3DEA,"eulerAngles");
			txt+="\n"+Util.hikaku2(Matrix3DQ,Mtrx3DQ,"quaternion");
			txt+="\n"+Util.hikaku2(Matrix3DAA,Mtrx3DAA,"axisAngle");
			//
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
	import flash.geom.Vector3D;
	import flash.system.Capabilities;
	public static function decompose(entity:Matrix3D,orientationStyle:String = "eulerAngles"):Vector.<Vector3D>{
		var e:Vector.<Number> = Vector.<Number>(entity.rawData);
		var vec:Vector.<Vector3D>;
		//バージョン判定
		var ver_array:Array = Capabilities.version.substr(4).split(",");
		var scale:Vector.<Number>=new Vector.<Number>(16,true);
		if(int(ver_array[2])*1000+int(ver_array[3]) > 2054){
			//prependScale的処理
			vec = matrix3dToEulerAnglePrepend(entity);
		}else{
			//appendScale的処理
			vec = matrix3dToEulerAngleAppend(entity);
		}

		
		if(orientationStyle != "eulerAngles"){
			vec = matrix3dToQuaternion(entity,vec[2],orientationStyle);
		}
		return vec;
	}
	
	//行列をクオータニオン（＋軸角度方向）に変換する関数
	//オライリーの「実例で学ぶゲーム3D数学」P187を参考にした。
	//ただし、本の行列とは行と列が異なるので、書き換えてる。
	private static function matrix3dToQuaternion(entity:Matrix3D,scale:Vector3D,orientationStyle:String):Vector.<Vector3D>{
		var e:Vector.<Number> = Vector.<Number>(entity.rawData);
		if(scale.x > 0){
			e[0]/=scale.x;
			e[4]/=scale.x;
			e[8]/=scale.x;
		}
		if(scale.y > 0){
			e[1]/=scale.y;
			e[5]/=scale.y;
			e[9]/=scale.y;
		}
		if(scale.z > 0){
			e[2]/=scale.z;
			e[6]/=scale.z;
			e[10]/=scale.z;
		}
		var w:Number;
		var x:Number;
		var y:Number;
		var z:Number;
		var _ar:Array = new Array(e[0]+e[5]+e[10],e[0]-e[5]-e[10],e[5]-e[0]-e[10],e[10]-e[0]-e[5]);
		var biggestIndex:int = _ar.sort(Array.NUMERIC|Array.RETURNINDEXEDARRAY|Array.DESCENDING)[0];
		var biggestVal:Number = Math.sqrt(_ar[biggestIndex]+1)*0.5;
		var mult:Number = 0.25/biggestVal;
		switch (biggestIndex) {
			case 0:
				w = biggestVal;
				x = (e[6]-e[9])*mult;
				y = (e[8]-e[2])*mult;
				z = (e[1]-e[4])*mult;
				break;
			case 1:
				x = biggestVal;
				w = (e[6]-e[9])*mult;
				y = (e[4]+e[1])*mult;
				z = (e[2]+e[8])*mult;
				break;
			case 2:
				y = biggestVal;
				w = (e[8]-e[2])*mult;
				x = (e[4]+e[1])*mult;
				z = (e[9]+e[6])*mult;
				break;
			case 3:
				z = biggestVal;
				w = (e[1]-e[4])*mult;
				x = (e[2]+e[8])*mult;
				y = (e[9]+e[6])*mult;
				break;
		}
		
		if(orientationStyle == "axisAngle"){
			if(Math.sin(Math.acos(w)) != 0){
				x = x/Math.sin(Math.acos(w));
				y = y/Math.sin(Math.acos(w));
				z = z/Math.sin(Math.acos(w));
				w = 2*Math.acos(w);
			}else{
				x = y = z= w = 0;
			}
		}
		return Vector.<Vector3D>([new Vector3D(e[12],e[13],e[14]),new Vector3D(x,y,z,w),scale]);
	}
	
	//行列をオイラー角にする関数
	//縮小拡大の値を得るためにかならず実行。
	private static function matrix3dToEulerAngle2(entity:Matrix3D):Vector.<Vector3D>{
		var e:Vector.<Number> = Vector.<Number>(entity.rawData);
		var _z:Number = Math.atan2(e[1],e[0]);
		var cz:Number = Math.cos(_z);
		var sz:Number = Math.sin(_z);
		
		var _y:Number = Math.atan2(-e[2],e[0]/cz);
		var cy:Number = Math.cos(_y);
		var sy:Number = Math.sin(_y);
		
		var _x:Number = Math.atan2((e[8]*cy/e[10]-sy*cz)/sz,1);
		var cx:Number = Math.cos(_x);
		var sx:Number = Math.sin(_x);
		
		var scale_x:Number = -e[2]/sy;
		var scale_y:Number = e[6]/(sx*cy);
		var scale_z:Number = e[10]/cx*cy;
		
		return Vector.<Vector3D>([new Vector3D(rounding(e[12]),rounding(e[13]),rounding(e[14])),new Vector3D(rounding(_x),rounding(_y),rounding(_z)),new Vector3D(rounding(scale_x),rounding(scale_y),rounding(scale_z))]);
		function rounding(n:Number):Number{
			var temp:Number = Math.round(n*1000000)/10000;
			if(temp%1 == 0){
				n = temp/100;
			}
			return n;
		}

	}
	private static function matrix3dToEulerAnglePrepend(entity:Matrix3D):Vector.<Vector3D>{
		var e:Vector.<Number> = Vector.<Number>(entity.rawData);
		
		var _z:Number = Math.atan2(e[1],e[0]);
		var sz:Number = Math.sin(_z);
		var cz:Number = Math.cos(_z);
		
		var _y:Number;
		if(Math.abs(cz) > 0.7){
			_y = Math.atan2(-e[2],e[0]/cz);
		}else{
			_y = Math.atan2(-e[2],e[1]/sz);
		}
		var sy:Number = Math.sin(_y);
		var cy:Number = Math.cos(_y);
		
		
		var _x:Number;
		if(Math.abs(cz) > 0.7){
			_x = Math.atan2((sy*sz-e[9]*cy/e[10]),cz);
		}else{
			_x = Math.atan2((e[8]*cy/e[10]-sy*cz)/sz,1);
		}

		var sx:Number = Math.sin(_x);
		var cx:Number = Math.cos(_x);
		
		var scale_x:Number = -e[2]/sy;
		var scale_y:Number = e[6]/(sx*cy);
		//e[6]/(sx*cy);
		//e[4]/(sx*sy*cz-cx*sz);
		//e[5]/(sx*sy*sz+cx*cz);
		var scale_z:Number = e[10]/(cx*cy);
		//e[10]/(cx*cy);
		//e[9]/(cx*sy*sz-sx*cz);
		//e[8]/(cx*sy*cz+sx*sz);
		
		
		return Vector.<Vector3D>([new Vector3D(rounding(e[12]),rounding(e[13]),rounding(e[14])),new Vector3D(rounding(_x),rounding(_y),rounding(_z)),new Vector3D(rounding(scale_x),rounding(scale_y),rounding(scale_z))]);
		
		//値を丸める関数。100万倍して、四捨五入をし10000で割った時に、1で割り切れれば、
		//さらに100で割った値を代入する。
		//これで0.999999...などを1にする。
		function rounding(n:Number):Number{
			var temp:Number = Math.round(n*1000000)/10000;
			if(temp%1 == 0){
				n = temp/100;
			}
			return n;
		}
	}
	private static function matrix3dToEulerAngleAppend(entity:Matrix3D):Vector.<Vector3D>{
		var e:Vector.<Number> = Vector.<Number>(entity.rawData);
		var cx:Number = Math.cos(Math.atan2(e[6],e[10]));
		var sx:Number = Math.sin(Math.atan2(e[6],e[10]));
		var _x:Number = Math.atan2(e[6],e[10]);
		var _y:Number;
		//Math.abs(sx) > Math.abs(cx)
		//これは0の除算が出来なので、
		//Math.abs(sx) > 0
		//の必要がある。
		//計算精度を上げるには大きい方が有利なので
		//45度以上、という意味で以下でもいい。
		//Math.abs(sx) > 1/Math.sqrt(2);
		//さらに1/Math.sqrt(2) = 0.707なので
		//Math.abs(sx) > 0.707;でもいい
		if(Math.abs(sx) > Math.abs(cx)){
			_y = Math.atan2(-e[2],e[6]/sx);
		}else{
			_y = Math.atan2(-e[2],e[10]/cx);
		}
		var cy:Number = Math.cos(_y);
		var sy:Number = Math.sin(_y);
		var _z:Number;
		if(Math.abs(sx) > 0.7){
			if(Math.abs(cy) > 0.001){
				if(Math.abs(e[0]/cy) > Math.abs((cx*sy*e[1]-cy*e[9])/sx)){
					_z = Math.atan2((e[8]-cx*sy*(e[0]/cy))/sx,e[0]/cy);
				}else{
					_z = Math.atan2(e[1]/cy,-(e[9]-cx*sy*(e[1]/cy))/sx);
				}
			}else{
				if(Math.abs(e[0]) > Math.abs((cx*sy*e[1]-cy*e[9])/sx)){
					_z = Math.atan2((cy*e[8]-cx*sy*e[0])/sx,e[0]);
				}else{
					_z = Math.atan2(e[1],(cx*sy*e[1]-cy*e[9])/sx);
				}
			}
		}else{
			if(Math.abs(cy) > 0.001){
				if(Math.abs(e[0]/cy) > Math.abs((e[5]*cy-e[1]*sx*sy)/cx)){
					_z = Math.atan2(-(e[4]-sx*sy*(e[0]/cy))/cx,e[0]/cy)
				}else{
					_z = Math.atan2(e[1]/cy,(e[5]-sx*sy*(e[1]/cy))/cx);
				}
			}else{
				if(Math.abs(e[0]) > Math.abs((e[5]-sx*sy*(e[1]/cy))/cx)){
					_z = Math.atan2((e[0]*sx*sy-e[4]*cy)/cx,e[0]);
				}else{
					_z = Math.atan2(e[1],(e[5]*cy-e[1]*sx*sy)/cx);
				}
			}
		}
		var cz:Number = Math.cos(_z);
		var sz:Number = Math.sin(_z);
		//var rotation:Vector3D = new Vector3D(Math.atan2(e[6],e[10]),_y,_z);
		var scale_z:Number;
		if(Math.abs(sy) > Math.abs(cy)){
			scale_z = -e[2]/sy;
		}else if(Math.abs(sx) > Math.abs(cx)){
			scale_z = e[6]/(sx*cy);
		}else{
			scale_z = e[10]/(cx*cy);
		}
		var scale_x:Number;
		var _ar:Array = new Array(Math.abs(cy*cz),Math.abs(sx*sy*cz-cx*sz),Math.abs(cx*sy*cz+sx*sz));
		var _big:int = _ar.sort(Array.NUMERIC|Array.RETURNINDEXEDARRAY|Array.DESCENDING)[0];
		if(_big == 0){
			scale_x = e[0]/(cy*cz);
		}else if(_big == 1){
			scale_x = e[4]/(sx*sy*cz-cx*sz);
		}else{
			scale_x = e[8]/(cx*sy*cz+sx*sz);
		}
		var scale_y:Number;
		_ar = new Array(Math.abs(cy*sz),Math.abs(sx*sy*sz+cx*cz),Math.abs(cx*sy*sz-sx*cz));
		_big = _ar.sort(Array.NUMERIC|Array.RETURNINDEXEDARRAY|Array.DESCENDING)[0];
		if(_big == 0){
			scale_y = e[1]/(cy*sz);
		}else if(_big == 1){
			scale_y = e[5]/(sx*sy*sz+cx*cz);	
		}else{
			scale_y = e[9]/(cx*sy*sz-sx*cz);
		}
		//var scale:Vector3D = new Vector3D(scale_x,scale_y,scale_z);
		return Vector.<Vector3D>([new Vector3D(rounding(e[12]),rounding(e[13]),rounding(e[14])),new Vector3D(rounding(_x),rounding(_y),rounding(_z)),new Vector3D(rounding(scale_x),rounding(scale_y),rounding(scale_z))]);
		
		//値を丸める関数。100万倍して、四捨五入をし10000で割った時に、1で割り切れれば、
		//さらに100で割った値を代入する。
		//これで0.999999...などを1にする。
		function rounding(n:Number):Number{
			var temp:Number = Math.round(n*1000000)/10000;
			if(temp%1 == 0){
				n = temp/100;
			}
			return n;
		}
	}
}
class Util {
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	public static function hikaku2(v0:Vector.<Vector3D>,v1:Vector.<Vector3D>,str:String):String {
		var _str:String="↓二つの"+str+"の要素毎の差\n";
		//_str += "平行移動："+(v0[0].x-v1[0].x)+","+(v0[0].y-v1[0].y)+","+(v0[0].z-v1[0].z);
		_str += "回転："+(v0[1].x-v1[1].x)+","+(v0[1].y-v1[1].y)+","+(v0[1].z-v1[1].z)+","+(v0[1].w-v1[1].w);
		_str += "、拡大 / 縮小："+(v0[2].x-v1[2].x)+","+(v0[2].y-v1[2].y)+","+(v0[2].z-v1[2].z)+","+(v0[2].w-v1[2].w);
		return _str;
	}

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
	public static function random9():Vector.<Number> {
		var _mt:Matrix3D = new Matrix3D();
		var v:Vector.<Vector3D>=new Vector.<Vector3D>  ;
		v[0]=new Vector3D(200*Math.random()-100,200*Math.random()-100,200*Math.random()-100);//平行移動、
		v[1]=new Vector3D(10*Math.random()-5,10*Math.random()-5,10*Math.random()-5);//回転
		v[2]=new Vector3D(100*Math.random(),100*Math.random(),100*Math.random());//拡大 / 縮小
		_mt.recompose(v);
		return _mt.rawData;
	}
}
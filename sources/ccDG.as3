// forked from umhr's 【未完成】Matrix3D.interpolate()

/* Comparison of interpolation techniques:

Green sprite uses Adobe's Matrix3D.interpolate function
Orange sprite uses umhr's Mtrx3D.interpolate function
Black sprite uses my interpolate function, which is umhr's interpolate with support for scaling

*/

package {
    import flash.display.Sprite;
    import flash.events.*;
    import flash.utils.*;
    import flash.text.*;
    import flash.geom.Matrix3D;

    public class Test extends Sprite {
        private var r:Sprite, adobe:Sprite, b:Sprite, umhr:Sprite, me:Sprite;

        public function Test() {
            var array:Array = [];

            for each( var color:uint in [0xFF0000,0x00FF00,0x0000FF,0xFF8800,0x000000] ) {
                var s:Sprite = new Sprite;
                s.graphics.beginFill( color );
                s.graphics.drawRect( 0, 0, 100, 100 );
                s.graphics.endFill();
                s.alpha = 0.5;
                addChild(s);
                array.push( s );
            }

            r = array[0]; // src (red)
            b = array[2]; //
            adobe = array[1]; // Adobe's interpolate (green)
            umhr = array[3]; // umhr's interpolate (orange)
            me = array[4]; // (black)
            
            r.x = 100;
            r.y = 30;
            r.rotationY = r.rotationY = r.rotationZ = 40;
            r.scaleY = 1.5;
            r.scaleX = r.scaleZ = 0.5;

            b.rotationX = -40;
            b.x = b.y = 333;

            addEventListener( Event.ENTER_FRAME, onEnter );
        }
        
        // use Matrix3D.interpolate to calculate a new matrix for g
        private function onEnter( e:Event ):void {
            var t:Number = Math.sin( getTimer()/1000 )/2+0.5;
            
            umhr.transform.matrix3D = Mtrx3D.interpolate( r.transform.matrix3D, b.transform.matrix3D, t );
            me.transform.matrix3D = Mtrx3D.myInterpolate( r.transform.matrix3D, b.transform.matrix3D, t );
            adobe.transform.matrix3D = Matrix3D.interpolate( r.transform.matrix3D, b.transform.matrix3D, t );
        }
    }
}

class Mtrx3D {
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

	public static function myInterpolate(thisMat:Matrix3D,toMat:Matrix3D,percent:Number):Matrix3D{
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
		_q[0] = (1-2*y*y-2*z*z)*scale_x;
		_q[1] = (2*x*y+2*w*z)*scale_x;
		_q[2] = (2*x*z-2*w*y)*scale_x;
		_q[3] = 0;
		_q[4] = 2*x*y-2*w*z*scale_y;
		_q[5] = (1-2*x*x-2*z*z)*scale_y;
		_q[6] = 2*y*z+2*w*x*scale_y;
		_q[7] = 0;
		_q[8] = 2*x*z+2*w*y*scale_z;
		_q[9] = 2*y*z-2*w*x*scale_z;
		_q[10] = (1-2*x*x-2*y*y)*scale_z;
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

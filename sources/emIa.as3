package  
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.IGraphicsData;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.geom.Vector3D;
	import flash.geom.Point;
	import net.hires.debug.Stats;
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author lizhi http://game-develop.net/
	 */
	[SWF(frameRate=60)]
	public class Test3D5 extends Sprite
	{
		private var obj3ds:Vector.<Obj3D>=new Vector.<Obj3D>;
		private var w:int = 400;
		private var h:int = 400;
		private var bmd:BitmapData = new BitmapData(w, h, false, 0);
		private var vs:Vector.<uint> = bmd.getVector(bmd.rect);
		private var zs:Vector.<Number> = new Vector.<Number>(w * h);
		private var gd:Vector.<IGraphicsData> = new Vector.<IGraphicsData>;
		private var light:Vector3D = new Vector3D(0, 0, -1);
		public function Test3D5() 
		{
			var image:Bitmap = new Bitmap(bmd);
			addChild(image);
			//image.x = 400;
			for (var i:int = 0; i < 5;i++ ) {
				var obj3d:Obj3D = createCube(100,0xffffff*Math.random());
				obj3d.rotation.x = Math.PI * Math.random();
				obj3d.rotation.y = Math.PI * Math.random();
				obj3d.rotation.z = Math.PI * Math.random();
				obj3d.position.z = 320;
				obj3d.position.x = (Math.random()-.5)*300;
				obj3d.position.y = (Math.random()-.5)*300;
				obj3ds.push(obj3d);
			}
			
			obj3d = createSphere(100, 10 , 15);
			obj3d.position.z = 220;
			obj3d.position.y = 50;
			//obj3ds.push(obj3d);
			
			stage.quality = StageQuality.LOW;
			addEventListener(Event.ENTER_FRAME, enterFrame);
			addChild(new Stats);
		}
		
		private function enterFrame(e:Event):void 
		{
			var tss:Array = [];
			for each(var obj3d:Obj3D in obj3ds){
				obj3d.rotation.x += .01;
				obj3d.rotation.y += .02;
				obj3d.rotation.z += .03;
				graphics.lineStyle(0);
				for (var i:int = obj3d.vs.length - 1; i >= 0; i-- ) {
					var v:Vector3D = obj3d.vs[i];
					var v2:Vector3D = obj3d.vs2[i];
					//var uv:Vector3D = obj3d.uvs[i];
					var y:Number = v.y * Math.cos(obj3d.rotation.x) - v.z * Math.sin(obj3d.rotation.x);
					var z:Number = v.z * Math.cos(obj3d.rotation.x) + v.y * Math.sin(obj3d.rotation.x);
					var x:Number = v.x * Math.cos(obj3d.rotation.y) - z * Math.sin(obj3d.rotation.y);
					z = z * Math.cos(obj3d.rotation.y) + v.x * Math.sin(obj3d.rotation.y);
					var x_:Number = x * Math.cos(obj3d.rotation.z) - y * Math.sin(obj3d.rotation.z);  
					y = y * Math.cos(obj3d.rotation.z) + x * Math.sin(obj3d.rotation.z);
					z += obj3d.position.z;
					var fz:Number = 100 / z;
					v2.x = (x_+obj3d.position.x) * fz+200;
					v2.y = (y+obj3d.position.y) * fz + 200;
					v2.z = z;
				}
				/*for each(var line:Point in obj3d.lines) {
					graphics.moveTo(obj3d.vs2[line.x].x,obj3d.vs2[line.x].y);
					graphics.lineTo(obj3d.vs2[line.y].x,obj3d.vs2[line.y].y);
				}*/
				//obj3d.sort();
				for (i = obj3d.ts.length - 1; i >= 0; i-- ) {
					var ts:Vector3D = obj3d.ts[i];
					var v1:Vector3D = obj3d.vs2[ts.x];
					var v22:Vector3D = obj3d.vs2[ts.y];
					var v3:Vector3D = obj3d.vs2[ts.z];
					if (!multiply(v1, v22, v3)) {
						var color:int = ts.w;
						v = obj3d.norms[i];
						y = v.y * Math.cos(obj3d.rotation.x) - v.z * Math.sin(obj3d.rotation.x);
						z = v.z * Math.cos(obj3d.rotation.x) + v.y * Math.sin(obj3d.rotation.x);
						x = v.x * Math.cos(obj3d.rotation.y) - z * Math.sin(obj3d.rotation.y);
						z = z * Math.cos(obj3d.rotation.y) + v.x * Math.sin(obj3d.rotation.y);
						x_ = x * Math.cos(obj3d.rotation.z) - y * Math.sin(obj3d.rotation.z);  
						y = y * Math.cos(obj3d.rotation.z) + x * Math.sin(obj3d.rotation.z);
						var norm:Vector3D = new Vector3D(x_, y, z);
						var li:Number = norm.dotProduct(light);
						if (li < 0) li = 0;
						var r:int = ((ts.w & 0xff0000)>>16) *li;
						var g:int = ((ts.w & 0xff00)>>8) *li;
						var b:int = (ts.w & 0xff)*li;
						tss.push([Vector.<Vector3D>([v1, v22, v3]),(r<<16)+(g<<8)+b] );
					}
				}
			}
			
			///tss.sort(sorttss);
			
			vs.length = 0;
			vs.length = w * h;
			for (i = w * h - 1; i >= 0;i-- ) {
				zs[i] = Number.POSITIVE_INFINITY;
			}
			for each(var its:Array in tss) {
				fill(its[0],its[1]);
			}
			bmd.setVector(bmd.rect, vs);
		}
		public static function multiply(v1:Vector3D,v2:Vector3D,v3:Vector3D):Boolean {
			return (v1.x - v3.x) * (v2.y - v3.y) > (v2.x - v3.x) * (v1.y - v3.y); 
		}
		
		private function sorttss(v1:Vector.<Vector3D>,v2:Vector.<Vector3D>):Number 
		{
			return v2[0].z + v2[1].z + v2[2].z - v1[0].z - v1[1].z - v1[2].z;
		}
		
		public function createCube(r:Number,color:uint):Obj3D {
			var obj3d:Obj3D = new Obj3D;
			obj3d.vs.push(
				new Vector3D(-1, -1, 1),//0
				new Vector3D(1, -1, 1),//1
				new Vector3D(-1, 1, 1),//2
				new Vector3D(1, 1, 1),//3
				new Vector3D(-1, -1, -1),//4
				new Vector3D(1, -1, -1),//5
				new Vector3D(-1, 1, -1),//6
				new Vector3D(1, 1, -1)//7
			);
			
			for each(var v:Vector3D in obj3d.vs) {
				v.scaleBy(r);
				obj3d.vs2.push(new Vector3D);
			}
			obj3d.lines.push(
				new Point(0,1),
				new Point(0,2),
				new Point(1,3),
				new Point(2,3),
				new Point(4,5),
				new Point(4,6),
				new Point(5,7),
				new Point(6,7),
				new Point(0,4),
				new Point(1,5),
				new Point(2,6),
				new Point(3,7)
			);
			var c0:uint = color;//0xffffff * Math.random();
			var c1:uint = color;//0xffffff * Math.random();
			var c2:uint = color;//0xffffff * Math.random();
			var c3:uint = color;//0xffffff * Math.random();
			var c4:uint = color;//0xffffff * Math.random();
			var c5:uint = color;//0xffffff * Math.random();
			obj3d.ts.push(
			new Vector3D(0,1,2,c0),
			new Vector3D(1,3,2,c0),
			new Vector3D(4,6,5,c1),
			new Vector3D(5,6,7,c1),
			new Vector3D(0,2,4,c2),
			new Vector3D(2,6,4,c2),
			new Vector3D(1,5,3,c3),
			new Vector3D(3,5,7,c3),
			new Vector3D(0,4,1,c4),
			new Vector3D(1,4,5,c4),
			new Vector3D(2,3,6,c5),
			new Vector3D(3,7,6,c5)
			);
			obj3d.norms.push(
			new Vector3D(0,0,1),
			new Vector3D(0,0,1),
			new Vector3D(0,0,-1),
			new Vector3D(0,0,-1),
			new Vector3D(-1,0,0),
			new Vector3D(-1,0,0),
			new Vector3D(1,0,0),
			new Vector3D(1,0,0),
			new Vector3D(0,-1,0),
			new Vector3D(0,-1,0),
			new Vector3D(0,1,0),
			new Vector3D(0,1,0)
			);
			return obj3d;
		}
		
		public function createSphere(r:Number, nv:int = 20, nh:int = 30):Obj3D {
			var obj3d:Obj3D = new Obj3D;
			obj3d.vs.push(new Vector3D(0, -r));
			obj3d.uvs.push(new Vector3D(.5,0));
			obj3d.vs2.push(new Vector3D);
			
			for (var i:int = 1; i <= nv;i++ ) {
				var az:Number = (i / (nv + 1) - .5) * Math.PI;
				var uvv:Number = i / (nv + 1);
				for (var j:int = 0; j < nh; j++ ) {
					obj3d.uvs.push(new Vector3D(j/nh,uvv));
					var v:Vector3D = new Vector3D(r);
					var x:Number = v.x * Math.cos(az);  
					v.y = v.x * Math.sin(az);
					var ay:Number = j / nh * 2 * Math.PI;
					v.x = x * Math.cos(ay);
					v.z = x * Math.sin(ay);
					obj3d.vs.push(v);
					obj3d.vs2.push(new Vector3D);
					var a:int = (i - 1) * nh + j+1;
					var b:int = j == (nh-1)?a - nh + 1:a + 1;
					var c:int = i == nv?nv * nh + 1:a + nh;
					var d:int = j == (nh - 1)?c - nh + 1:c + 1;
					var color:uint = 0xffffff * Math.random();
					obj3d.ts.push(new Vector3D(a, b, c,color), new Vector3D(b, c, d,color));
					if (i == nv) obj3d.ts.pop();
					obj3d.lines.push(new Point(a, b),new Point(a,c));
				}
			}
			obj3d.vs.push(new Vector3D(0, r));
			obj3d.vs2.push(new Vector3D);
			obj3d.uvs.push(new Vector3D(.5,1));
			for (j = 0; j < nh; j++ ) {
				obj3d.lines.push(new Point(0, j + 1));
				obj3d.ts.push(new Vector3D(0, j+1, j==(nh-1)?1:j+2,0xffffff*Math.random()));
			}
			
			return obj3d;
		}
		
		private function fill(v:Vector.<Vector3D>,color:uint):void {
			/*graphics.beginFill(color);
				graphics.moveTo(v[0].x, v[0].y);
				graphics.lineTo(v[1].x, v[1].y);
				graphics.lineTo(v[2].x, v[2].y);
				graphics.lineTo(v[0].x, v[0].y);
				graphics.endFill();
				return;*/
			v.sort(sort);
			var dx0:Number = (v[1].x - v[0].x) / (int(v[1].y) - int(v[0].y));
			var dx1:Number = (v[2].x - v[0].x) / (int(v[2].y) - int(v[0].y));
			var dz0:Number = (v[1].z - v[0].z) /(int(v[1].y) - int(v[0].y));
			var dz1:Number = (v[2].z - v[0].z)/(int(v[2].y) - int(v[0].y)) ;
			if (dx0 > dx1) {
				var temp:Number = dx0;
				dx0 = dx1;
				dx1 = temp;
				temp = dz0;
				dz0 = dz1;
				dz1 = temp;
			}
			var i:int = int(v[0].y) * w;
			var x0:Number = v[0].x;
			var x1:Number = v[0].x;
			var z0:Number = v[0].z;
			var z1:Number = v[0].z;
			for (var y:int = v[0].y, y1:int = v[1].y; y < y1; y++ ) {
				var dz:Number = (z1 - z0) / (x1 - x0);
				var z:Number = z0;
				for (var x:int = x0+i,len:int=x1+i; x < len; x++ ) { 
					if (zs[x] > z) {
						vs[x] = color;
						zs[x] = z;
					}
					z += dz;
				}
				x0 += dx0;
				x1 += dx1;
				i += w;
				z0 += dz0;
				z1 += dz1;
			}
			
			if (int(v[0].y)==int(v[1].y)) {
				dx0 = (v[2].x - v[0].x) / (int(v[2].y) - int(v[0].y));
				dx1 = (v[2].x - v[1].x) / (int(v[2].y) - int(v[1].y));
				dz0 = (v[2].z - v[0].z) / (int(v[2].y) - int(v[0].y));
				dz1 = (v[2].z - v[1].z) / (int(v[2].y) - int(v[1].y));
				if (dx0 < dx1) {
					temp = dx0;
					dx0 = dx1;
					dx1 = temp;
					x1 = v[0].x;
					x0 = v[1].x;
					temp = dz0;
					dz0 = dz1;
					dz1 = temp;
					z1 = v[0].z;
					z0 = v[1].z;
				}else {
					x0 = v[0].x;
					x1 = v[1].x;
					z0 = v[0].z;
					z1 = v[1].z;
				}
			}else {
				dx0 = (v[2].x - v[0].x) / (int(v[2].y) - int(v[0].y));
				dx1 = (v[2].x - v[1].x) / (int(v[2].y) - int(v[1].y));
				dz0 = (v[2].z - v[0].z) / (int(v[2].y) - int(v[0].y));
				dz1 = (v[2].z - v[1].z) / (int(v[2].y) - int(v[1].y));
				if (dx0 < dx1) {
					temp = dx0;
					dx0 = dx1;
					dx1 = temp;
					temp = dz0;
					dz0 = dz1;
					dz1 = temp;
				}
			}
			for (y1 = v[2].y; y < y1; y++ ) { 
				dz = (z1 - z0) / (x1 - x0);
				z = z0;
				for (x = x0+i,len=x1+i; x < len; x++ ) { 
					if (zs[x] > z) {
						vs[x] = color;
						zs[x] = z;
					}
					z += dz;
				}
				x0 += dx0;
				x1 += dx1;
				i += w;
				
				z0 += dz0;
				z1 += dz1;
			}
		}
		private function sort(p1:Vector3D, p2:Vector3D):Number { return p1.y - p2.y }
	}
}
import flash.geom.*;
class Obj3D {
	public var rotation:Vector3D = new Vector3D;//角度
	public var position:Vector3D = new Vector3D;//位置
	public var vs:Vector.<Vector3D> = new Vector.<Vector3D>;//顶点
	public var uvs:Vector.<Vector3D> = new Vector.<Vector3D>;//uv
	public var vs2:Vector.<Vector3D> = new Vector.<Vector3D>;//屏幕坐标顶点
	public var lines:Vector.<Point> = new Vector.<Point>;//直线
	public var clines:Vector.<Vector3D> = new Vector.<Vector3D>;//曲线
	public var ts:Vector.<Vector3D> = new Vector.<Vector3D>;//三角形
	public var norms:Vector.<Vector3D> = new Vector.<Vector3D>;//面垂线
}
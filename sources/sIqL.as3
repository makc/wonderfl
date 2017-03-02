/**
 * 視線とメッシュの交差判定のテスト（処理が重い版）
 * （追記）176行目のgetWorldTransform()の第二引数書き忘れてました。。
 */
package  {
	import flash.events.*;
	import flash.utils.*;
	import org.papervision3d.core.geom.*;
	import org.papervision3d.core.geom.renderables.*;
	import org.papervision3d.core.math.*;
	import org.papervision3d.materials.*;
	import org.papervision3d.materials.special.*;
	import org.papervision3d.materials.utils.*;
	import org.papervision3d.objects.*;
	import org.papervision3d.objects.primitives.*;
	import org.papervision3d.view.*;
	import org.papervision3d.view.stats.*;
	public class CollideRayToMesh extends BasicView {
		private var cube:Cube;
		private var point:Sphere;
		private var lines:Lines3D;
		private var line:Line3D;
		private var wire:WireframeMaterial;
		private var color:ColorMaterial;
		//コンストラクタ
		public function CollideRayToMesh() {
			stage.frameRate = 60;
			opaqueBackground = 0x000000;
			addChild(new StatsView(renderer));
			wire = new WireframeMaterial(0xFF8800);
			color = new ColorMaterial(0xFF8800, 0.7);
			lines = new Lines3D(new LineMaterial());
			lines.addNewLine(2, 0, 0, 0, 0, 450, 0);
			line = lines.lines[0] as Line3D;
			cube = new Cube(new MaterialsList( { all:wire } ), 200, 200, 200, 2, 2, 2);
			point = new Sphere(new ColorMaterial(0xFFFF00), 10, 8, 6);
			cube.position = new Number3D(0, 200, 0);
			var plane:Plane = new Plane(new WireframeMaterial(0x007700), 1000, 1000, 5, 5);
			plane.rotationX = 90;
			scene.addChild(cube);
			scene.addChild(point);
			scene.addChild(plane);
			scene.addChild(lines);
			camera.position = new Number3D(0, 700, -400);
			addEventListener(Event.ENTER_FRAME, onEnter);
		}
		/**
		 * 毎フレーム処理
		 */
		private function onEnter(e:Event):void {
			//キューブを回転・変形させる
			var tm:int = getTimer();
			cube.scaleY = (Math.cos(Math.PI/180 * tm / 30) + 1) *0.8;
			cube.rotationZ = tm/25;
			cube.rotationX = tm/25;
			cube.rotationY = tm/25;
			//視線用ライン
			line.v0.x = (mouseX - stage.stageWidth/2)*2; 
			line.v0.z = (-mouseY + stage.stageHeight/2)*2;
			var ray:Number3D = line.v0.toNumber3D()
			ray.minusEq(line.v1.toNumber3D());
			//交差判定
			var res:Array = collideRayToMeshList(line.v1.toNumber3D(), ray, [cube], false, true);
			for each(var face:Triangle3D in cube.geometry.faces) face.material = wire;
			if (res.length == 0) {
				//交差なし
				point.visible = false;
			} else {
				//交差あり
				res[0].triangle.material = color;
				point.visible = true;
				point.position = new Number3D(res[0].position.x, res[0].position.y, res[0].position.z);
			}
			renderer.renderScene(scene, camera, viewport);
		}
		/**
		 * 視線と複数メッシュの交差判定をする
		 * @param	pos	レイ放射地点
		 * @param	vec	レイの方向
		 * @param	meshes	メッシュオブジェクトの配列
		 * @param	isDoubleSided	裏向きのポリゴンも交差判定する
		 * @param	updateTransform	モデルが回転・変形していたらtrueにする
		 * @return
		 */
		private function collideRayToMeshList(pos:Number3D, vec:Number3D, meshes:Array, isDoubleSided:Boolean = false, updateTransform:Boolean = false):Array {
			var res:Array = new Array();
			for each(var mesh:TriangleMesh3D in meshes) {
				//モデルのワールド空間における変形情報
				var transform:Matrix3D = getWorldTransform(mesh, updateTransform);
				//メッシュモデル内の全三角ポリゴンをチェック
				for each(var face:Triangle3D in mesh.geometry.faces) {
					var ps:Array = new Array();
					for each(var v:Vertex3D in face.vertices) {
						var n:Number3D = v.toNumber3D();
						Matrix3D.multiplyVector4x4(transform, n);
						ps.push(n);
					}
					var hit:Object = collideRayToTriangle(pos, vec, ps[0], ps[1], ps[2], isDoubleSided);
					if (hit != null) {
						hit.triangle = face;
						res.push(hit);
					}
				}
			}
			res.sortOn("distance", Array.NUMERIC);
			return res;
		}
		/**
		* 視線と三角ポリゴンの交差判定をする(ポリゴンは頂点反時計周りで構成)
		* @param	pos	視線の開始地点
		* @param	vec	視線の方向ベクトル
		* @param	p0	三角ポリゴンの頂点1
		* @param	p1	三角ポリゴンの頂点2
		* @param	p2	三角ポリゴンの頂点3
		* @param	isDoubleSided	裏向きのポリゴンも交差判定する
		* @return
		*/
		private function collideRayToTriangle(pos:Object, vec:Object, p0:Object, p1:Object, p2:Object, isDoubleSided:Boolean = false):Object {
			//視線ベクトルの正規化
			var v:Object = { x:vec.x, y:vec.y, z:vec.z };
			normalize(v);
			//法線ベクトルを求める
			var n:Object = cross3D( { x:p1.x - p0.x, y:p1.y - p0.y, z:p1.z - p0.z }, { x:p2.x - p0.x, y:p2.y - p0.y, z:p2.z - p0.z } );
			normalize(n);
			var vn:Number = dot3D(v, n);
			//視線に対して面が表向きか
			var isRightSide:Boolean = (vn < 0);
			//1.視線が平面と平行なら交差なし
			//2.片面チェックON時に視線と法線が同じ向き（面が裏向き）なら交差なし
			if ((isRightSide? -vn : vn) < 0.0000001 || (!isRightSide && !isDoubleSided)) return null;
			var xpn:Number = dot3D( { x:pos.x - p0.x, y:pos.y - p0.y, z:pos.z - p0.z }, n);
			var distance:Number = -xpn / vn;
			//3.交点が視線の後ろなら交差なし
			if (distance < 0) return null;
			//平面との交点座標を求める
			var hit:Object = { x:v.x * distance + pos.x, y:v.y * distance + pos.y, z:v.z * distance + pos.z };
			//4.交点が三角形内にあるかチェック
			var cross0:Object = cross3D( { x:hit.x - p0.x, y:hit.y - p0.y, z:hit.z - p0.z }, { x:p1.x - p0.x, y:p1.y - p0.y, z:p1.z - p0.z } );
			if (dot3D(cross0, n) > 0.000000001) return null;
			var cross1:Object = cross3D( { x:hit.x - p1.x, y:hit.y - p1.y, z:hit.z - p1.z }, { x:p2.x - p1.x, y:p2.y - p1.y, z:p2.z - p1.z } );
			if (dot3D(cross1, n) > 0.000000001) return null;
			var cross2:Object = cross3D( { x:hit.x - p2.x, y:hit.y - p2.y, z:hit.z - p2.z }, { x:p0.x - p2.x, y:p0.y - p2.y, z:p0.z - p2.z } );
			if (dot3D(cross2, n) > 0.000000001) return null;
			//交差情報を返す{position:交差点、isRightSide:交差面が視線に対して表向きかどうか、distance:視点から交点までの距離}
			return { position:hit, isRightSide:vn < 0, distance:distance };
		}
		/**ベクトルの正規化*/
		private function normalize(v:Object):void {
			var mod:Number = Math.sqrt(v.x * v.x + v.y * v.y + v.z * v.z);
			if (mod != 0 && mod != 1) {
				mod = 1 / mod;
				v.x *= mod;
				v.y *= mod;
				v.z *= mod;
			}
		}
		/**2つの3Dベクトルの外積を返す*/
		private function cross3D(v1:Object, v2:Object):Object {
			return { x:v2.y * v1.z - v2.z * v1.y, y:v2.z * v1.x - v2.x * v1.z, z:v2.x * v1.y - v2.y * v1.x };
		}
		/**2つの3Dベクトルの内積を返す*/
		private function dot3D(vec1:Object, vec2:Object):Number {
			return vec1.x * vec2.x + vec1.y * vec2.y + vec1.z * vec2.z;
		}
		/**
		 * オブジェクトのワールド空間での変形情報を取得
		 * @param	obj	変形情報を取得するモデル
		 * @param	updateTransform	モデルが回転・変形していたらtrueにする
		 * @return
		 */
		private function getWorldTransform(obj:DisplayObject3D, updateTransform:Boolean = false):Matrix3D {
			if (updateTransform) obj.updateTransform();
			var res:Matrix3D = new Matrix3D();
			res.copy(obj.transform);
			var parent3D:DisplayObject3D = obj.parent as DisplayObject3D;
			if (parent3D != null) res.calculateMultiply(getWorldTransform(parent3D, updateTransform), res);
			return res;
		}
	}
}
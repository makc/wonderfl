package {
    import flash.display.*;
    import flash.events.Event;
    import flash.geom.*;
    import flash.utils.getTimer;
    
    [SWF(width=465,height=465,frameRate=60,backgroundColor=0x000000)]
    /**
     * トーラス
     * 3Dで何か作る用
     */
    public class Torus extends Sprite {
        // 投影された頂点
        private var projected:Vector.<Number> = new Vector.<Number>(0, false);
        // 投影
        private var projection:PerspectiveProjection = new PerspectiveProjection();
        // ワールド変換マトリックス
        private var world:Matrix3D = new Matrix3D();
        // ビューポート（3D描画対象）
        private var viewport:Shape = new Shape();
        // メッシュデータ
        private var mesh:GraphicsTrianglePath = createTorusMesh(200, 100, 32, 16);
        // テクスチャ
        private var texture:BitmapData = new BitmapData(512, 512, false);
        
        /**
         * コンストラクタ
         */
        public function Torus() {
            texture.perlinNoise(64, 64, 3, 0, true, true, 7, true);
            viewport.x = viewport.y = 465 / 2;
            addChild(viewport);
            projection.fieldOfView = 60;
            addEventListener(Event.ENTER_FRAME, enterFrame);
        }
        
        /**
         * フレームごとの処理
         */
        private function enterFrame(event:Event):void {
            world.identity();
            world.appendRotation(getTimer() * 0.027, Vector3D.X_AXIS);
            world.appendRotation(getTimer() * 0.061, Vector3D.Y_AXIS);
            world.appendTranslation(0, 0, 50);
            world.append(projection.toMatrix3D());
            // meshを投影してprojectedに頂点を格納。uvtDataも更新される
            Utils3D.projectVectors(world, mesh.vertices, projected, mesh.uvtData);
            // テクスチャを利用して描画
            viewport.graphics.clear();
            viewport.graphics.beginBitmapFill(texture, null, false, true);
            viewport.graphics.drawTriangles(projected, getSortedIndices(mesh), mesh.uvtData, mesh.culling);
        }
    }
}

import flash.display.GraphicsTrianglePath;
import flash.display.TriangleCulling;

/**
 * GraphicsTrianglePathを元に、Zソートされたインデックスを返す
 */
function getSortedIndices(mesh:GraphicsTrianglePath):Vector.<int> {
    var triangles:Array = [];
    for (var i:uint=0; i<mesh.indices.length; i+=3) {
        var i1:uint = mesh.indices[i+0], i2:uint = mesh.indices[i+1], i3:uint = mesh.indices[i+2];
        var z:Number = Math.min(mesh.uvtData[i1 * 3 + 2], mesh.uvtData[i2 * 3 + 2], mesh.uvtData[i3 * 3 + 2]);
        if (z > 0) { triangles.push({i1:i1, i2:i2, i3:i3, z:z}); }
    }
    triangles = triangles.sortOn("z", Array.NUMERIC);
    var sortedIndices:Vector.<int> = new Vector.<int>(0, false);
    for each (var triangle:Object in triangles) {
        sortedIndices.push(triangle.i1, triangle.i2, triangle.i3);
    }
    return sortedIndices;
}

/**
 * トーラスを作成
 */
function createTorusMesh(hRadius:Number, vRadius:Number, hDiv:uint, vDiv:uint):GraphicsTrianglePath {
    var mesh:GraphicsTrianglePath = new GraphicsTrianglePath(new Vector.<Number>(0, false), new Vector.<int>(0, false), new Vector.<Number>(0, false), TriangleCulling.POSITIVE);
    for (var i:uint=0; i<=hDiv; i++) {
        var s1:Number = Math.PI * 2 * i / hDiv;
        for (var j:uint=0; j<=vDiv; j++) {
            var s2:Number = Math.PI * 2 * j / vDiv;
            var r:Number = Math.cos(s2) * vRadius + hRadius;
            mesh.vertices.push(Math.cos(s1) * r, Math.sin(s1) * r, Math.sin(s2) * vRadius);
            mesh.uvtData.push(i / hDiv, j / vDiv, 1);
            if (j < vDiv && i < hDiv) {
                var a:uint =  i      * (vDiv + 1) + j;
                var b:uint = (i + 1) * (vDiv + 1) + j;
                mesh.indices.push(b, a + 1, a, a + 1, b, b + 1);
            }
        }
    }
    return mesh;
}

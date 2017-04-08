// forked from psyark's ShadedTorus
package {
    import flash.display.*;
    import flash.events.Event;
    import flash.geom.*;
    import flash.net.*;
    import flash.utils.getTimer;
    
    [SWF(width=465,height=465,frameRate=60,backgroundColor=0x000000)]
    /**
     * 陰影処理を付けてみた
     * createTorusNormalMap追加
     * createLightingFilter追加
     * enterFrame中で光の方向の計算、法線マップとの掛け合わせ、テクスチャとの掛け合わせを追加
     */
    public class ShadedTorus extends Sprite {
        // 投影された頂点
        private var projected:Vector.<Number> = new Vector.<Number>(0, false);
        // 投影
        private var projection:PerspectiveProjection = new PerspectiveProjection();
        // ワールド変換マトリックス
        private var world:Matrix3D = new Matrix3D();
        // ビューポート（3D描画対象）
        private var viewport:Shape = new Shape();
        // メッシュデータ
        private var mesh:GraphicsTrianglePath = createTorusMesh(200, 100, 32 * 2, 16 * 2);
        // テクスチャ
        private var texture:BitmapData = new BitmapData(512, 512, false);
        // 法線マップ
        private var normalMap:BitmapData = createTorusNormalMap(512, 512);
        // 一時計算用ビットマップ
        private var tmp1:BitmapData = new BitmapData(512, 512, false);
        private var tmp2:BitmapData = new BitmapData(512, 512, false);
        
        private var palette:Array;
        private var pattern:BitmapData;
        
        // 肌色をつけるかどうか
        private const skinColor:Boolean = true;
        // 黒タイツ具合
        private const paletteFactor:int = 8;
        // 布カバー率
        private const clothLength:Number = 0.85;
        // すべりどめ
        private const band:Boolean = true;
        // 模様を使うかどうか
        private const applyPattern:Boolean = true;
        // 背景に出す画像（空文字なら出さない）
        private const backgroundURL:String = "http://assets.wonderfl.net/images/related_images/7/7a/7a01/7a01da75c51397f39cc7cc75382226d9c6060938";
        
        /**
         * コンストラクタ
         */
        public function ShadedTorus() {
            texture.perlinNoise(64, 64, 3, 0, true, true, 7, true);
            if (skinColor) {
                texture.colorTransform(texture.rect, new ColorTransform(-0.2, -0.2, -0.2, 1, 0xFF, 0xB8, 0x97));
            }
            viewport.x = viewport.y = 465 / 2;
            addChild(viewport);
            projection.fieldOfView = 60;
            addEventListener(Event.ENTER_FRAME, enterFrame);
            
            palette = [];
            for (var i:int=0; i<0x100; i++) {
                palette[i] = gs(Math.pow(i / 0xFF, paletteFactor) * 0xFF);
            }
            function gs(v:int):int {
                return v << 16 | v << 8 | v;
            }
            
            var tile:BitmapData = new BitmapData(32, 32, false, 0xFFFFFF);
            var s:Sprite = new Sprite();
            s.graphics.lineStyle(3, 0x999999);
            s.graphics.moveTo(-16, -16);
            s.graphics.lineTo(48, 48);
            s.graphics.moveTo(48, -16);
            s.graphics.lineTo(-16, 48);
            tile.draw(s);
            s.graphics.clear();
            s.graphics.beginBitmapFill(tile);
            s.graphics.drawRect(0, 0, 512 * 2, 512);
            
            pattern = new BitmapData(512, 512, false, 0x000000);
            pattern.draw(s, new Matrix(0.5, 0, 0, 1));
            
            if (backgroundURL) {
                var loader:Loader = new Loader();
                addChildAt(loader, 0);
                loader.load(new URLRequest(backgroundURL));
            }
        }
        
        /**
         * フレームごとの処理
         */
        private function enterFrame(event:Event):void {
            var light:Vector3D = new Vector3D();
            light.x = viewport.mouseX / (465 / 2) / Math.SQRT2;
            light.y = viewport.mouseY / (465 / 2) / Math.SQRT2;
            light.z = -Math.sqrt(1 - light.x * light.x - light.y * light.y);
            world.identity();
            world.appendRotation(getTimer() * 0.027, Vector3D.X_AXIS);
            world.appendRotation(getTimer() * 0.061, Vector3D.Y_AXIS);
            world.invert();
            light = world.transformVector(new Vector3D(0, 0, -1));
            world.invert();
            world.appendTranslation(0, 0, 700);
            world.append(projection.toMatrix3D());
            // meshを投影してprojectedに頂点を格納。uvtDataも更新される
            Utils3D.projectVectors(world, mesh.vertices, projected, mesh.uvtData);
            // ライティング
            tmp1.applyFilter(normalMap, normalMap.rect, normalMap.rect.topLeft, createLightingFilter(light));
            
            var rect:Rectangle = new Rectangle(0, 0, 512 * clothLength, 512);
            tmp1.paletteMap(tmp1, rect, tmp1.rect.topLeft, palette, [], []);
            if (band) {
                tmp1.colorTransform(new Rectangle(0, 0, 8, 512), new ColorTransform(0.2, 0.2, 0.2));
                tmp1.colorTransform(new Rectangle(rect.width - 8, 0, 8, 512), new ColorTransform(0.2, 0.2, 0.2));
            }
            tmp2.copyPixels(texture, texture.rect, texture.rect.topLeft);
            tmp2.draw(tmp1, null, null, BlendMode.MULTIPLY);
            if (applyPattern) {
                tmp2.draw(pattern, null, null, BlendMode.MULTIPLY, rect);
            }
            // テクスチャを利用して描画
            viewport.graphics.clear();
            viewport.graphics.beginBitmapFill(tmp2, null, false, true);
            viewport.graphics.drawTriangles(projected, getSortedIndices(mesh), mesh.uvtData, mesh.culling);
        }
    }
}

import flash.display.*;
import flash.filters.ColorMatrixFilter;
import flash.geom.*;

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

/**
 * 法線マップの作成
 */
function createTorusNormalMap(w:uint, h:uint):BitmapData {
    var normalMap:BitmapData = new BitmapData(w, h, false, 0);
    var mtx:Matrix3D = new Matrix3D();
    for (var x:uint=0; x<w; x++) {
        for (var y:uint=0; y<h; y++) {
            mtx.identity();
            mtx.appendRotation(y / h * -360, Vector3D.Y_AXIS);
            mtx.appendRotation(x / w * +360, Vector3D.Z_AXIS);
            var normal:Vector3D = mtx.transformVector(Vector3D.X_AXIS);
            var color:uint = (normal.x / 2 + 0.5) * 0xFF << 16 | (normal.y / 2 + 0.5) * 0xFF << 8 | (normal.z / 2 + 0.5) * 0xFF;
            normalMap.setPixel(x, y, color);
        }
    }
    return normalMap;
}

/**
 * 光の方向ベクトルからライティング用フィルタを作成
 */
function createLightingFilter(light:Vector3D):ColorMatrixFilter {
    return new ColorMatrixFilter([
        2 * light.x, 2 * light.y, 2 * light.z, 0, (light.x + light.y + light.z) * -0xFF,
        2 * light.x, 2 * light.y, 2 * light.z, 0, (light.x + light.y + light.z) * -0xFF,
        2 * light.x, 2 * light.y, 2 * light.z, 0, (light.x + light.y + light.z) * -0xFF,
        0,           0,           0,           1, 0
    ]);
}

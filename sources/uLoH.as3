// 非平面モデルへのバンプマップ生成
// ついでに地形のランダム生成
// Shader使ってないので初期化が重いです
// favoriteありがとう！マウスで光を動かせるようにしてみたよ
package {
    import flash.display.*;
    import flash.events.Event;
    import flash.filters.ColorMatrixFilter;
    import flash.geom.*;
    import flash.utils.getTimer;
    
    [SWF(width=465,height=465,frameRate=60,backgroundColor=0x000000)]
    public class BumpyPlanet extends Sprite {
        private var vertices:Vector.<Number>  = new Vector.<Number>(0, false);
        private var projected:Vector.<Number> = new Vector.<Number>(0, false);
        private var indices:Vector.<int>      = new Vector.<int>(0, false);
        private var uvtData:Vector.<Number>   = new Vector.<Number>(0, false);
        private var projection:PerspectiveProjection = new PerspectiveProjection();
        private var heightMap:BitmapData = new HeightMap(512, 512);
        private var normalMap:BitmapData = new NormalMap(heightMap, 0x80, 25);
        private var texture:BitmapData = new Texture(heightMap, 0x80);
        private var tmp1:BitmapData = new BitmapData(512, 512, false, 0);
        private var tmp2:BitmapData = new BitmapData(512, 512, false, 0);
        private var world:Matrix3D = new Matrix3D();
        private var viewport:Shape = new Shape();
        
        public function BumpyPlanet() {
            addChild(new Bitmap(new Space(465, 465)));
            viewport.x = viewport.y = 465 / 2;
            addChild(viewport);
            projection.fieldOfView = 60;
            createGeometry();
            addEventListener(Event.ENTER_FRAME, enterFrame);
        }
        
        private function createGeometry():void {
            var radius:Number = 300;
            var xDiv:uint = 24;
            var yDiv:uint = 16;
            for (var y:uint=0; y<=yDiv; y++) {
                var yr:Number = y / yDiv;
                var cy:Number = Math.cos(yr * Math.PI);
                var sy:Number = Math.sin(yr * Math.PI);
                for (var x:uint=0; x<=xDiv; x++) {
                    var xr:Number = x / xDiv;
                    var cx:Number = Math.cos(xr * Math.PI * 2);
                    var sx:Number = Math.sin(xr * Math.PI * 2);
                    vertices.push(cx * sy * radius, cy * radius, sx * sy * radius);
                    uvtData.push(xr, yr, 0);
                    if (y < yDiv) {
                        var i1:uint = y       * (xDiv + 1) + x;
                        var i2:uint = y       * (xDiv + 1) + ((x + 1) % (xDiv + 1));
                        var i3:uint = (y + 1) * (xDiv + 1) + x;
                        var i4:uint = (y + 1) * (xDiv + 1) + ((x + 1) % (xDiv + 1));
                        indices.push(i1, i2, i3, i3, i2, i4);
                    }
                }
            }
        }
        
        private function enterFrame(event:Event):void {
            var light:Vector3D = new Vector3D();
            light.x = viewport.mouseX / (465 / 2) / Math.SQRT2;
            light.y = viewport.mouseY / (465 / 2) / Math.SQRT2;
            light.z = Math.sqrt(1 - light.x * light.x - light.y * light.y);
            world.identity();
            world.appendRotation(getTimer() * -0.03, Vector3D.Y_AXIS);
            light = world.transformVector(light);
            world.appendRotation(23.4, Vector3D.Z_AXIS);
            world.appendRotation(60, Vector3D.Y_AXIS);
            world.appendTranslation(0, 0, 750);
            world.append(projection.toMatrix3D());
            Utils3D.projectVectors(world, vertices, projected, uvtData);
            var lighting:ColorMatrixFilter = new ColorMatrixFilter([
                2 * light.x, 2 * light.y, 2 * light.z, 0, (light.x + light.y + light.z) * -0xFF,
                2 * light.x, 2 * light.y, 2 * light.z, 0, (light.x + light.y + light.z) * -0xFF,
                2 * light.x, 2 * light.y, 2 * light.z, 0, (light.x + light.y + light.z) * -0xFF,
                0,           0,           0,           1, 0
            ]);
            tmp1.applyFilter(normalMap, normalMap.rect, normalMap.rect.topLeft, lighting);
            tmp2.copyPixels(texture, texture.rect, texture.rect.topLeft);
            tmp2.draw(tmp1, null, null, BlendMode.MULTIPLY);
            viewport.graphics.clear();
            viewport.graphics.beginBitmapFill(tmp2, null, false, true);
            viewport.graphics.drawTriangles(projected, indices, uvtData, TriangleCulling.POSITIVE);
        }
    }
}

import flash.display.BitmapData;
import flash.geom.ColorTransform;
import flash.geom.Vector3D;
import flash.geom.Matrix3D;
class HeightMap extends BitmapData {
    public function HeightMap(width:uint, height:uint) {
        super(width, height, false, 0);
        perlinNoise(80, 120, 10, Math.random() * 100, true, true, 0, true);
        colorTransform(rect, new ColorTransform(1.5, 1.5, 1.5, 1, -0x40, -0x40, -0x40));
    }
}
class NormalMap extends BitmapData {
    public function NormalMap(heightMap:BitmapData, seaHeight:uint, multiplier:Number) {
        super(heightMap.width, heightMap.height, false);
        var vec:Vector3D = new Vector3D();
        var mtx:Matrix3D = new Matrix3D();
        for (var y:int=0; y<heightMap.height; y++) {
            for (var x:int=0; x<heightMap.width; x++) {
                var height:uint = heightMap.getPixel(x, y) & 0xFF;
                if (height >= seaHeight) {
                    vec.x = (height - (heightMap.getPixel((x + 1) % heightMap.width, y) & 0xFF)) / 0xFF * multiplier;
                    vec.y = (height - (heightMap.getPixel(x, (y + 1) % heightMap.height) & 0xFF)) / 0xFF * multiplier;
                } else {
                    vec.x = vec.y = 0;
                }
                vec.y *= -1;
                vec.z = 0;
                if (vec.lengthSquared > 1) {
                    vec.normalize();
                }
                vec.z = Math.sqrt(1 - vec.lengthSquared);
                mtx.identity();
                mtx.appendRotation(y / heightMap.height * 180 - 90, Vector3D.X_AXIS);
                mtx.appendRotation(x / heightMap.width * 360, Vector3D.Y_AXIS);
                vec = mtx.transformVector(vec);
                setPixel(x, y,
                    (vec.x * 0x7F + 0x80) << 16 |
                    (vec.y * 0x7F + 0x80) << 8 |
                    (vec.z * 0x7F + 0x80)
                );
            }
        }
    }
}
class Texture extends BitmapData {
    public function Texture(heightMap:BitmapData, seaHeight:uint) {
        super(heightMap.width, heightMap.height, false, 0x229900);
        var paletteR:Array = [];
        var paletteG:Array = [];
        var paletteB:Array = [];
        var r:Number;
        for (var i:uint=0; i<256; i++) {
            if (i >= seaHeight) {
                r = (i - seaHeight) / (256 - seaHeight);
                if (r > 0.7) {
                    paletteR[i] = (0x99 + 0x66 * (r - 0.7) / (1 - 0.7)) << 16;
                    paletteG[i] = (0x66 + 0x99 * (r - 0.7) / (1 - 0.7)) << 8;
                    paletteB[i] = (0x00 + 0xFF * (r - 0.7) / (1 - 0.7));
                } else if (r > 0.15) {
                    paletteR[i] = (0x00 + 0x99 * (r - 0.15) / (0.7 - 0.15)) << 16;
                    paletteG[i] = (0xCC - 0x66 * (r - 0.15) / (0.7 - 0.15)) << 8;
                    paletteB[i] = (0x00 + 0x00 * (r - 0.15) / (0.7 - 0.15));
                } else {
                    paletteR[i] = (0xCC - 0xCC * r / 0.15) << 16;
                    paletteG[i] = (0x99 + 0x33 * r / 0.15) << 8;
                    paletteB[i] = (0x33 - 0x33 * r / 0.15);
                }
            } else {
                r = i / seaHeight;
                paletteR[i] = 0;
                paletteG[i] = Math.pow(r, 5) * 0x66 << 8;
                paletteB[i] = (r * 0.5 + 0.5) * 0xFF;
            }
        }
        paletteMap(heightMap, rect, rect.topLeft, paletteR, paletteG, paletteB);
    }
}
class Space extends BitmapData {
    public function Space(width:uint, height:uint) {
        super(width, height, false);
        noise(Math.random() * 256, 0, 255, 7, true);
        var a:Number = 20.4;
        var b:Number = 0xFF * -20;
        colorTransform(rect, new ColorTransform(a, a, a, 1, b, b, b));
    }
}

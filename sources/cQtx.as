package  {
    import alternativa.engine3d.alternativa3d;
    import alternativa.engine3d.materials.TextureMaterial;
    import alternativa.engine3d.materials.VertexLightTextureMaterial;
    import alternativa.engine3d.materials.StandardMaterial;
    import alternativa.engine3d.objects.WireFrame;
    import alternativa.engine3d.objects.Mesh;
    import alternativa.engine3d.objects.Surface;
    import alternativa.engine3d.primitives.GeoSphere;
    import alternativa.engine3d.resources.BitmapTextureResource;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.events.Event;
    
    use namespace alternativa3d;
    
    public class main extends Sprite {
        private var scene:Template;
        private const RADIAN:Number = Math.PI / 180;
        
        public function main():void {
            scene = new Template();
            scene.addEventListener(Template.VIEW_CREATE, initialize);
            addChild(scene);
        }
        
        private function initialize(event:Event):void {
            //↓wonderflではサーフェースクラスがエラーになる模様
            var test:Surface = new Surface();
            
            scene.removeEventListener(Template.VIEW_CREATE, initialize);
            //マテリアル用のリソースの用意
            var bmd:BitmapData = new BitmapData(256, 256, true, 0xFF000000);
            bmd.perlinNoise(64, 64, 1, 1, true , true);
            var textureResource:BitmapTextureResource = new BitmapTextureResource(bmd);

            
            //Textureの作成
            var diffuseMap:BitmapData = new BitmapData(16, 16, false, 0x6666FF);
            var normalMap:BitmapData = new BitmapData(16, 16, false, 0x8080FF);

            //マテリアルの作成
            var bitmapResource:BitmapTextureResource = new BitmapTextureResource(diffuseMap);
            var normalResource:BitmapTextureResource = new BitmapTextureResource(normalMap);
            var material:StandardMaterial = new StandardMaterial(bitmapResource, normalResource);
            //var material:TextureMaterial = new TextureMaterial(bitmapResource);
            
            var meshA:Mesh = new Cylinder(50,30, 100, 12,6,0,0,false);
            meshA.geometry.calculateTangents(0);
            //MeshUtility.createTangent(meshA);
            
            meshA.setMaterialToAllSurfaces(material)
            scene.controlObject.addChild(meshA);
            
            var meshB:Mesh = new Cylinder(50,30, 100, 12,6,0,0,false);
            MeshUtility.smoothShading(meshB,true);
            meshB.geometry.calculateTangents(0);
            //MeshUtility.createTangent(meshB);
            
            meshB.setMaterialToAllSurfaces(material)
            scene.controlObject.addChild(meshB);
            /*
            var normalFrameA:WireFrame = WireFrame.createNormals(meshA, 0xFF0000, 1, 1, 10);
            var tangentFrameA:WireFrame = WireFrame.createTangents(meshA, 0x0000FF, 1, 1, 10);
            var binormalFrameA:WireFrame = WireFrame.createBinormals(meshA, 0x00FF00, 1, 1, 10);
            //var wireFrameA:WireFrame = WireFrame.createEdges(meshA, 0xFF0000);
            meshA.addChild(normalFrameA);
            meshA.addChild(tangentFrameA);
            meshA.addChild(binormalFrameA);
            var normalFrameB:WireFrame = WireFrame.createNormals(meshB, 0xFF0000, 1, 1, 10);
            var tangentFrameB:WireFrame = WireFrame.createTangents(meshB, 0x0000FF, 1, 1, 10);
            var binormalFrameB:WireFrame = WireFrame.createBinormals(meshB, 0x00FF00, 1, 1, 10);
            //var wireFrameB:WireFrame = WireFrame.createEdges(meshB, 0xFF0000);
            meshB.addChild(normalFrameB);
            meshB.addChild(tangentFrameB);
            meshB.addChild(binormalFrameB);
            */
            meshA.x =-80
            meshB.x = 80
            
            //3Dオブジェクト（球）の用意
            var earth:GeoSphere = new GeoSphere(100,10);
            //scene.controlObject.addChild(earth);
            
            //WireFrameの表示
            //var wire:WireFrame = WireFrame.createEdges(earth, 0x00FF00);
            //earth.addChild(wire);
            
            //3Dオブジェクトへマテリアルの適用
            earth.setMaterialToAllSurfaces(material);
            
            scene.initialize();
        }
    }
}    
    
import alternativa.engine3d.controllers.SimpleObjectController;
import alternativa.engine3d.core.Camera3D;
import alternativa.engine3d.core.Object3D;
import alternativa.engine3d.core.Resource;
import alternativa.engine3d.core.View;
import alternativa.engine3d.lights.AmbientLight;
import alternativa.engine3d.lights.DirectionalLight;
import flash.display.Sprite;
import flash.display.Stage3D;
import flash.display.StageAlign;
import flash.display.StageQuality;
import flash.display.StageScaleMode;
import flash.events.Event;

class Template extends Sprite {
    public static const VIEW_CREATE:String = 'view_create'
    
    private var stage3D:Stage3D
    private var camera:Camera3D
    public var scene:Object3D
    public var cameraController:SimpleObjectController;
    public var objectController:SimpleObjectController;
    public var controlObject:Object3D;
    
    protected var directionalLight:DirectionalLight;
    protected var ambientLight:AmbientLight;    
    
    public function Template() {
        addEventListener(Event.ADDED_TO_STAGE, init);
    }
    
    private function init(e:Event = null):void 
    {
        removeEventListener(Event.ADDED_TO_STAGE, init);
        
        stage.scaleMode = StageScaleMode.NO_SCALE;
        stage.align = StageAlign.TOP_LEFT;
        stage.quality = StageQuality.HIGH;            
        
        //Stage3Dを用意
        stage3D = stage.stage3Ds[0];
        //Context3Dの生成、呼び出し、初期化
        stage3D.addEventListener(Event.CONTEXT3D_CREATE, onContextCreate);
        stage3D.requestContext3D();
    }
    
    
    private function onContextCreate(e:Event):void {
        stage3D.removeEventListener(Event.CONTEXT3D_CREATE, onContextCreate);
        //View3D(表示エリア)の作成
        var view:View = new View(stage.stageWidth, stage.stageHeight);
        view.antiAlias = 4
        addChild(view);
        
        //Scene（コンテナ）の作成
        scene = new Object3D();

        //Camera（カメラ）の作成
        camera = new Camera3D(1, 100000);
        camera.view = view;
        scene.addChild(camera)
        camera.diagram
        addChild(camera.diagram)
        
        //Cameraをコントロールする場合は、CameraControlerの作成
        cameraController = new SimpleObjectController(stage, camera, 100);
        cameraController.mouseSensitivity = 0;
        cameraController.unbindAll();
        
        //Cameraの位置調整
        cameraController.setObjectPosXYZ(0, -300, 0);
        cameraController.lookAtXYZ(0, 0, 0);
        
        //Lightを追加
        ambientLight = new AmbientLight(0xFFFFFF);
        ambientLight.intensity = 0.5;
        scene.addChild(ambientLight);
        
        //Lightを追加
        directionalLight = new DirectionalLight(0xFFFFFF);
        //手前右上から中央へ向けた指向性light
        directionalLight.x = 0;
        directionalLight.y = -100;
        directionalLight.z = -100;
        directionalLight.lookAt(0, 0, 0);
        scene.addChild(directionalLight);
        //directionalLight.visible = false;
        
    
        //コントロールオブジェクトの作成
        controlObject = new Object3D()
        scene.addChild(controlObject);
        dispatchEvent(new Event(VIEW_CREATE));
    }
    
    
    public function initialize():void {
        for each (var resource:Resource in scene.getResources(true)) {
            trace(resource)
            resource.upload(stage3D.context3D);
        }
        
        //オブジェクト用のコントローラー（マウス操作）
        objectController = new SimpleObjectController(stage, controlObject, 100);
        objectController.mouseSensitivity = 0.2;
        
        //レンダリング
        camera.render(stage3D);
        
        addEventListener(Event.ENTER_FRAME, onRenderTick);
    }

    
    public function onRenderTick(e:Event):void {
        objectController.update()
        camera.render(stage3D);
    }
}


/**
 * Primitive
 */
import alternativa.engine3d.core.*;
import alternativa.engine3d.objects.*;
import alternativa.engine3d.resources.*;
class Primitive extends Mesh {
    protected var inSide:Surface;
    protected var outSide:Surface;        
    protected var indices:Vector.<uint> = new Vector.<uint>();
    protected var positions:Vector.<Number> = new Vector.<Number>();
    protected var texcoords:Vector.<Number> = new Vector.<Number>();        
    
    //表用と裏用のpositionsとtexcoordsとindicesとを追加
    protected var positionsInSide:Vector.<Number> = new Vector.<Number>();
    protected var positionsOutSide:Vector.<Number> = new Vector.<Number>();
    protected var texcoordsInSide:Vector.<Number> = new Vector.<Number>();
    protected var texcoordsOutSide:Vector.<Number> = new Vector.<Number>();
    protected var indicesInSide:Vector.<uint> = new Vector.<uint>();
    protected var indicesOutSide:Vector.<uint> = new Vector.<uint>();
    
    protected const RADIAN:Number = Math.PI / 180;    
    
    public function Primitive() {
        geometry = new Geometry();
        var pos:int = VertexAttributes.POSITION
        var tex:int = VertexAttributes.TEXCOORDS[0]
        geometry.addVertexStream([pos,pos,pos,tex,tex]);
    }
    
    protected function setGeometry():void {
        positions = positionsOutSide.concat(positionsInSide);
        texcoords = texcoordsOutSide.concat(texcoordsInSide);
        indices = indicesOutSide.concat();
        var indexStart:int = positionsOutSide.length / 3;
        var count:uint = indicesInSide.length;
        for (var i:uint = 0; i < count; i++) {
            indices.push(indicesInSide[i] + indexStart);
        }
        geometry.numVertices = positions.length / 3;
        geometry.setAttributeValues(VertexAttributes.POSITION, positions);
        geometry.setAttributeValues(VertexAttributes.TEXCOORDS[0], texcoords);
        geometry.indices = indices;
        if (indicesInSide.length) {
            inSide = this.addSurface(null, indicesOutSide.length, indicesInSide.length / 3);
        }
        if (indicesOutSide.length) {
            outSide = this.addSurface(null, 0, indicesOutSide.length / 3);
        }
        MeshUtility.createNormal(this);
    }
}



import alternativa.engine3d.core.*;
import alternativa.engine3d.materials.*;
import alternativa.engine3d.objects.*;
import alternativa.engine3d.primitives.*;
import alternativa.engine3d.resources.*;
import flash.geom.*;

class RoundMesh extends Primitive {
    
    public function RoundMesh(lineList:Vector.<Point>, radialSegments:uint = 3,lastSegments:uint = 0,star:Number = 0, twoSide:Boolean = false, reverse:Boolean = false) {
        super();
        
        var rInterval:Number = 360 /  radialSegments;
        var heightSegments:uint = lineList.length - 1;
        var height:Number = lineList[heightSegments].y - lineList[0].y;
        
        var radian:Number
        var segmentCount:int = (lastSegments > 0) ? lastSegments : radialSegments;
        for (var i:int = 0; i < segmentCount; i++) {
            for (var j:int = 0; j < heightSegments; j++) {
                var vertices:Vector.<Vector3D> = new Vector.<Vector3D>(4);
                var uvs:Vector.<Point> = new Vector.<Point>(4);
                
                //時計周りで四角を作成していく
                var tempRadiusA:Number = (i % 2 == 1 && star > 0) ? lineList[j].x * star : lineList[j].x
                var tempRadiusB:Number = (i % 2 == 1 && star > 0) ? lineList[j+1].x * star : lineList[j+1].x
                
                radian = (rInterval * i - 90) * RADIAN;
                vertices[0] = new Vector3D(Math.cos(radian) * tempRadiusA, Math.sin(radian) * tempRadiusA, lineList[j].y-(height/2));
                vertices[3] = new Vector3D(Math.cos(radian) * tempRadiusB, Math.sin(radian) * tempRadiusB, lineList[j+1].y-(height/2));
                
                radian = (rInterval * (i + 1) - 90) * RADIAN;
                vertices[1] = new Vector3D(Math.cos(radian) * tempRadiusA, Math.sin(radian) * tempRadiusA, lineList[j].y-(height/2));
                vertices[2] = new Vector3D(Math.cos(radian) * tempRadiusB, Math.sin(radian) * tempRadiusB, lineList[j+1].y-(height/2));

                uvs[0] = new Point(1 / radialSegments * -i, 1 / heightSegments * j);
                uvs[3] = new Point(1 / radialSegments * -i, 1 / heightSegments * (j+1));
                uvs[1] = new Point(1 / radialSegments * -(i+1), 1 / heightSegments * j);
                uvs[2] = new Point(1 / radialSegments * -(i+1), 1 / heightSegments * (j+1));
                
                //Cylinderに巻きつける場合、裏表が逆になるので注意（UVも逆）
                if (reverse == false || twoSide == true) {
                    MeshUtility.createSquare(vertices, uvs, indicesOutSide, positionsOutSide, texcoordsOutSide, true)
                }
                if (reverse == true || twoSide == true) {
                    MeshUtility.createSquare(vertices, uvs, indicesInSide, positionsInSide, texcoordsInSide, false)
                }
                
            }
        }
        setGeometry();
    }
}




import alternativa.engine3d.core.*;
import alternativa.engine3d.objects.*;
import alternativa.engine3d.resources.*;
import flash.geom.*;

class Cylinder extends Primitive {
    public function Cylinder(topRadius:Number = 0, bottomRadius:Number = 50, height:Number = 100, radialSegments:uint = 3, heightSegments:uint = 1, lastSegments:uint = 0,star:Number = 0, twoSide:Boolean = false, reverse:Boolean = false) {
        
        var rInterval:Number = 360 / radialSegments;
        var hInterval:Number = height / heightSegments;
        
        var radian:Number
        var segmentCount:int = (lastSegments > 0) ? lastSegments : radialSegments;
        for (var i:int = 0; i < segmentCount; i++) {
            for (var j:int = 0; j < heightSegments; j++) {
                var vertices:Vector.<Vector3D> = new Vector.<Vector3D>(4);
                var uvs:Vector.<Point> = new Vector.<Point>(4);
                var px:Number=0;
                var py:Number = 0;
                var tmpR:Number = 0;
                var starRatio:Number = 0;
                radian = (rInterval * i - 90) * RADIAN;
                starRatio = (i % 2 == 1 && star > 0) ? star : 1;
                px = Math.cos(radian)
                py = Math.sin(radian)
                tmpR = getRadius(topRadius, bottomRadius, height, hInterval * j, starRatio);
                vertices[0] = new Vector3D(px * tmpR, py * tmpR, hInterval * j - (height / 2));
                tmpR = getRadius(topRadius, bottomRadius, height, hInterval * (j + 1), starRatio);
                vertices[3] = new Vector3D(px * tmpR, py * tmpR, hInterval * (j + 1) - (height / 2));
                
                radian = (rInterval * (i + 1) - 90) * RADIAN;
                starRatio = (i % 2 == 0 && star > 0) ? star : 1;
                px = Math.cos(radian);
                py = Math.sin(radian);
                tmpR = getRadius(topRadius, bottomRadius, height, hInterval * j, starRatio);
                vertices[1] = new Vector3D(px * tmpR, py * tmpR, hInterval * j - (height / 2));
                tmpR = getRadius(topRadius, bottomRadius, height, hInterval * (j + 1), starRatio);
                vertices[2] = new Vector3D(px * tmpR, py * tmpR, hInterval * (j + 1) - (height / 2));
                
                var u:Number = 1 / radialSegments;
                var v:Number = 1 / heightSegments;
                uvs[0] = new Point(u * -i, v * j);
                uvs[3] = new Point(u * -i, v * (j + 1));
                uvs[1] = new Point(u * -(i + 1), v * j);
                uvs[2] = new Point(u * -(i + 1), v * (j + 1));
                
                
                //Cylinderに巻きつける場合、裏表が逆になるので注意（UVも逆）
                if (reverse == false || twoSide == true) {
                    MeshUtility.createSquare(vertices, uvs, indicesOutSide, positionsOutSide, texcoordsOutSide, true)
                }
                if (reverse == true || twoSide == true) {
                    MeshUtility.createSquare(vertices, uvs, indicesInSide, positionsInSide, texcoordsInSide, false)
                }
                
            }
        }
        setGeometry()

    }
    
    /**
     * 半径を高さの比率から割り出す
     * @return
     */
    private function getRadius(topRadius:Number, bottomRadius:Number, height:Number, length:Number, starRatio:Number):Number {
        var result:Number
        var difference:Number
        var ratio:Number
        
        if (topRadius > bottomRadius) {
            difference = topRadius - bottomRadius;
            ratio = (length) ? (height - length) / height : 1
            result = (bottomRadius + (difference * ratio));
        } else {
            difference = bottomRadius - topRadius;
            ratio = (length) ? length / height : 0
            result = (topRadius + (difference * ratio));
        }
        result *= starRatio
        return result;
    }

}








/**
 * 頂点に隣接する面法線を収集するクラス
 */
import flash.geom.Vector3D;
import flash.utils.Dictionary;

class ExtraVertex {
    public var vertex:Vector3D;
    public var normals:Dictionary;
    public var indices:Vector.<uint>;
    public function ExtraVertex(x:Number, y:Number, z:Number) {
        vertex = new Vector3D(x, y, z);
        normals = new Dictionary();
        indices = new Vector.<uint>();
    }
    
}



/**
 * MeshUtility
 */
import alternativa.engine3d.alternativa3d;
import alternativa.engine3d.core.*;
import alternativa.engine3d.objects.*;
import alternativa.engine3d.primitives.GeoSphere;
import alternativa.engine3d.resources.*;
import flash.geom.*;
import flash.utils.Dictionary;

use namespace alternativa3d;

class MeshUtility {
    
    public function MeshUtility() {
    
    }
    
    /**
     * 3つの頂点座標から、Faceを作成し、indices、positionsに各値を登録する
     */
    public static function createTriangle(vertices:Vector.<Vector3D>, uvs:Vector.<Point>,
                                          indices:Vector.<uint>, positions:Vector.<Number>, 
                                          texcoords:Vector.<Number>, reverse:Boolean = false):void {
        if (reverse == false) {
            //三角形用の頂点を登録
            positions.push(vertices[0].x, vertices[0].y, vertices[0].z,
                           vertices[2].x, vertices[2].y, vertices[2].z,
                           vertices[1].x, vertices[1].y, vertices[1].z);
            
            //三角形用のUVを登録
            texcoords.push(uvs[0].x, uvs[0].y,uvs[2].x, uvs[2].y,uvs[1].x, uvs[1].y);
            
        } else {
            //三角形用の頂点を登録
            positions.push(vertices[0].x, vertices[0].y, vertices[0].z,
                           vertices[1].x, vertices[1].y, vertices[1].z,
                           vertices[2].x, vertices[2].y, vertices[2].z);
            
            //三角形用のUVを登録
            texcoords.push(uvs[0].x, uvs[0].y,uvs[1].x, uvs[1].y,uvs[2].x, uvs[2].y);
            
        }
        //Face用indexを登録
        var startIndex:uint = indices.length
        indices.push(startIndex + 0, startIndex + 1, startIndex + 2);
    }
    
    /**
     * 4つの頂点座標から、四角形（2つのFace）を作成し、indices、positions、uvsに各値を登録する
     */
    public static function createSquare(vertices:Vector.<Vector3D>, uvs:Vector.<Point>,
                                        indices:Vector.<uint>, positions:Vector.<Number>, 
                                        texcoords:Vector.<Number>, reverse:Boolean = false):void {
        
        if (reverse == false) {
            positions.push(    vertices[0].x, vertices[0].y, vertices[0].z,
                            vertices[3].x, vertices[3].y, vertices[3].z,
                            vertices[1].x, vertices[1].y, vertices[1].z);
            positions.push(    vertices[1].x, vertices[1].y, vertices[1].z,
                            vertices[3].x, vertices[3].y, vertices[3].z,
                            vertices[2].x, vertices[2].y, vertices[2].z);    
            //三角形用のUVを登録
            texcoords.push(uvs[0].x, uvs[0].y,uvs[3].x, uvs[3].y,uvs[1].x, uvs[1].y);
            texcoords.push(uvs[1].x, uvs[1].y,uvs[3].x, uvs[3].y,uvs[2].x, uvs[2].y);
                            
        } else {
            positions.push(    vertices[0].x, vertices[0].y, vertices[0].z,
                            vertices[1].x, vertices[1].y, vertices[1].z,
                            vertices[3].x, vertices[3].y, vertices[3].z);
            positions.push(    vertices[1].x, vertices[1].y, vertices[1].z,
                            vertices[2].x, vertices[2].y, vertices[2].z,
                            vertices[3].x, vertices[3].y, vertices[3].z);    
            //三角形用のUVを登録
            texcoords.push(uvs[0].x, uvs[0].y,uvs[1].x, uvs[1].y,uvs[3].x, uvs[3].y);
            texcoords.push(uvs[1].x, uvs[1].y, uvs[2].x, uvs[2].y, uvs[3].x, uvs[3].y);
        }
        
        //Face用indexを登録
        var startIndex:uint = indices.length
        indices.push(startIndex + 0, startIndex + 1, startIndex + 2);
        indices.push(startIndex + 3, startIndex + 4, startIndex + 5);
    
    }
    
    /**
     * 指定Meshの法線を作成します
     * @param    mesh
     */
    public static function createNormal(mesh:Mesh):void {
        //法線の有無のチェック
        if (mesh.geometry.hasAttribute(VertexAttributes.NORMAL) == false) {
            var nml:int = VertexAttributes.NORMAL;    
            mesh.geometry.addVertexStream([nml,nml,nml]);
        }
        
        var indices:Vector.<uint> = mesh.geometry.indices;
        var positions:Vector.<Number> = mesh.geometry.getAttributeValues(VertexAttributes.POSITION);
        var vartices:Vector.<Vector3D> = new Vector.<Vector3D>(positions.length / 3);
        var vNormals:Vector.<Vector3D> = new Vector.<Vector3D>(positions.length / 3);
        
        var i:int;
        var count:uint = positions.length / 3;
        for (i = 0; i < count; i++) {
            vartices[i] = new Vector3D(positions[i * 3], positions[i * 3 + 1], positions[i * 3 + 2]);
        }
        
        //面法線を求め、頂点法線に代入する
        count = indices.length;
        for (i = 0; i < count; i += 3) {
            var normal:Vector3D = calcNormal(vartices[indices[i]], vartices[indices[i + 1]], vartices[indices[i + 2]]);
            vNormals[indices[i]] = normal;
            vNormals[indices[i + 1]] = normal;
            vNormals[indices[i + 2]] = normal;
        }
        
        var normals:Vector.<Number> = new Vector.<Number>();
        
        count = vNormals.length;
        for (i = 0; i < count; i++) {
            if (vNormals[i]) {
                normals.push(vNormals[i].x, vNormals[i].y, vNormals[i].z);
            }
        }
        
        mesh.geometry.setAttributeValues(VertexAttributes.NORMAL, normals);
    }
    
    /**
     * 面法線の計算
     * 三つの頂点座標からなる三角ポリゴンの法線を計算し返します
     */
    public static function calcNormal(a:Vector3D, b:Vector3D, c:Vector3D):Vector3D {
        var v1:Vector3D = b.subtract(a);
        var v2:Vector3D = c.subtract(a);
        var v3:Vector3D = v1.crossProduct(v2);
        //var v3:Vector3D = cross(v1,v2);
        v3.normalize();
        return (v3);
    }
    

    
    /**
     * 指定Meshの法線をSmoothShadingにします
     * @param    mesh
     */
    public static function smoothShading(mesh:Mesh,separateSurface:Boolean=false,threshold:Number=0.000001):void {
        
        var indices:Vector.<uint> = mesh.geometry.indices;
        var positions:Vector.<Number> = mesh.geometry.getAttributeValues(VertexAttributes.POSITION);
        var normals:Vector.<Number> = mesh.geometry.getAttributeValues(VertexAttributes.NORMAL);
        
        var vartices:Vector.<Vector3D> = new Vector.<Vector3D>(positions.length / 3);
        var vNormals:Vector.<Vector3D> = new Vector.<Vector3D>(normals.length / 3);
        
        var vertexDictionary:Dictionary = new Dictionary()
        var exVertex:ExtraVertex;
        
        //サーフェースごとに判断する

        for (var s:uint = 0; s < mesh.numSurfaces; s++ ) {
            var side:String = (separateSurface) ? s.toString() : '';
            for (var n:uint = 0; n < mesh.getSurface(s).numTriangles * 3; n++) {
                var i:uint = indices[n+mesh.getSurface(s).indexBegin];
                vartices[i] = new Vector3D(positions[i * 3], positions[i * 3 + 1], positions[i * 3 + 2]);
                //誤差を丸める
                vartices[i].x = int(vartices[i].x / threshold) * threshold;
                vartices[i].y = int(vartices[i].y / threshold) * threshold;
                vartices[i].z = int(vartices[i].z / threshold) * threshold;                
                vNormals[i] = new Vector3D(normals[i * 3], normals[i * 3 + 1], normals[i * 3 + 2]);
                //誤差を丸める
                vNormals[i].x = int(vNormals[i].x / threshold) * threshold;
                vNormals[i].y = int(vNormals[i].y / threshold) * threshold;
                vNormals[i].z = int(vNormals[i].z / threshold) * threshold;
                
                //同じ頂点を集める
                //ただし、表裏がある場合があるので法線の方向もチェックする
                if (vertexDictionary[vartices[i].toString()+'_'+side]) {
                    exVertex = vertexDictionary[vartices[i].toString()+'_'+side]
                    if (exVertex.normals[vNormals[i].toString()+'_'+side] == null) {
                        exVertex.normals[vNormals[i].toString()+'_'+side] = vNormals[i];
                    }
                    exVertex.indices.push(i);

                } else {
                    exVertex = new ExtraVertex(vNormals[i].x, vNormals[i].y, vNormals[i].z);
                    exVertex.normals[vNormals[i].toString()+'_'+side] = vNormals[i];
                    exVertex.indices.push(i)
                    vertexDictionary[vartices[i].toString()+'_'+side] = exVertex
                }
            }                
            
        }

        //Normalの平均化
        var count:uint = 0;
        for each (exVertex in vertexDictionary) {
            var normalX:Number = 0;
            var normalY:Number = 0;
            var normalZ:Number = 0;
            count = 0
            for each (var normal:Vector3D in exVertex.normals) {
                normalX += normal.x;
                normalY += normal.y;
                normalZ += normal.z;
                count++
            }
            normal = new Vector3D(normalX / count, normalY / count, normalZ / count);
            normal.normalize();
            count = exVertex.indices.length;
            for (i = 0; i < count; i++) {
                vNormals[exVertex.indices[i]] = normal;
            }
        }
        count = vNormals.length;
        normals = new Vector.<Number>();
        for (i = 0; i < count; i++) {
            normals.push(vNormals[i].x, vNormals[i].y, vNormals[i].z);
        }
        
        mesh.geometry.setAttributeValues(VertexAttributes.NORMAL, normals);
    }
    
    
    /**
     * 指定MeshのUVをVertexのxyから仮に作成する
     * @param    mesh
     */
    public static function createUv(mesh:Mesh):void {
        if (mesh.geometry.hasAttribute(VertexAttributes.TEXCOORDS[0]) == false) {
            var tex:int = VertexAttributes.TEXCOORDS[0];    
            mesh.geometry.addVertexStream([tex,tex]);
        }
        mesh.calculateBoundBox()
        var width:Number = mesh.boundBox.maxX - mesh.boundBox.minX
        var length:Number = mesh.boundBox.maxZ - mesh.boundBox.minZ
        
        var positions:Vector.<Number> = mesh.geometry.getAttributeValues(VertexAttributes.POSITION);
        var texcoords:Vector.<Number> = new Vector.<Number>;
        var i:int;
        for (i = 0; i < positions.length; i += 3) {
            texcoords.push((positions[i] - mesh.boundBox.minX) / width, (positions[i + 2] - mesh.boundBox.minZ) / length);
        }

        mesh.geometry.setAttributeValues(VertexAttributes.TEXCOORDS[0], texcoords);
    }
    
    
    
    /**
     * 指定MeshのTangentを作成する
     * @param    mesh
     */
    static public function createTangent(mesh:Mesh):void {
        //接線有無のチェック


        
        
        var positions:Vector.<Number> = mesh.geometry.getAttributeValues(VertexAttributes.POSITION);
        var texcoords:Vector.<Number> = mesh.geometry.getAttributeValues(VertexAttributes.TEXCOORDS[0]);
        var normals:Vector.<Number> = mesh.geometry.getAttributeValues(VertexAttributes.NORMAL);
        
        var indices:Vector.<uint> = mesh.geometry.indices;
        var vertices:Vector.<Vector3D> = new Vector.<Vector3D>;
        var uvs:Vector.<Point> = new Vector.<Point>;
        var vNormals:Vector.<Vector3D> = new Vector.<Vector3D>;
        
        var i:int;
        for (i = 0; i < positions.length; i += 3) {
            vertices.push(new Vector3D(positions[i], positions[i + 1], positions[i + 2]));
        }
        for (i = 0; i < texcoords.length; i += 2) {
            uvs.push(new Point(texcoords[i], texcoords[i + 1]));
        }
        for (i = 0; i < normals.length; i += 3) {
            vNormals.push(new Vector3D(normals[i], normals[i + 1], normals[i + 2]));
        }
        
        var tangents:Vector.<Number> = calcTangent(mesh.geometry.indices, vertices, uvs, vNormals);
        
        var geometry:Geometry = new Geometry();
        //if (mesh.geometry.hasAttribute(VertexAttributes.TANGENT4) == false) {
        var tan:int = VertexAttributes.TANGENT4;
        var pos:int = VertexAttributes.POSITION;
        var nor:int = VertexAttributes.NORMAL;
        var tex:int = VertexAttributes.TEXCOORDS[0];
        var attribute:Array = [
            pos, pos, pos,
            nor, nor, nor,
            tan, tan, tan, tan,
            tex, tex
        ]
        geometry.addVertexStream(attribute)
        //}                
        geometry.numVertices = mesh.geometry.numVertices
        geometry.indices = mesh.geometry.indices;
        geometry.setAttributeValues(VertexAttributes.POSITION, positions);
        geometry.setAttributeValues(VertexAttributes.NORMAL, normals);
        geometry.setAttributeValues(VertexAttributes.TANGENT4, tangents);
        geometry.setAttributeValues(VertexAttributes.TEXCOORDS[0], texcoords);

        mesh.geometry = geometry;
    }
    
    
    /**
     * 複数のMeshを結合し、１つのMeshにします
     * @param    meshs
     * @return
     */
    public static function bindMeshs(meshs:Vector.<Mesh>):Mesh {
        var count:uint = meshs.length;
        
        var indices:Vector.<uint> = new Vector.<uint>();
        var positions:Vector.<Number> = new Vector.<Number>();
        var texcoords:Vector.<Number> = new Vector.<Number>();
        
        var nextIndex:uint = 0;
        var nextPosition:uint = 0;
        var mesh:Mesh = meshs[i];
        var i:int
        var j:int
        for (i = 0; i < count; i++) {
            mesh = meshs[i];
            var tempPositions:Vector.<Number> = mesh.geometry.getAttributeValues(VertexAttributes.POSITION);
            mesh.matrix.transformVectors(tempPositions, tempPositions);
            positions = positions.concat(tempPositions);
            texcoords = texcoords.concat(mesh.geometry.getAttributeValues(VertexAttributes.TEXCOORDS[0]));
            
            var tempIndices:Vector.<uint> = mesh.geometry.indices;            
            var indexCount:uint = tempIndices.length
            for (j = 0; j < indexCount; j++) {
                tempIndices[j] += nextIndex;
            }
            indices = indices.concat(tempIndices);
            nextIndex += tempPositions.length/3
        }

        var geometry:Geometry = new Geometry();
        
        var attributes:Array = [];
        attributes[0] = VertexAttributes.POSITION;
        attributes[1] = VertexAttributes.POSITION;
        attributes[2] = VertexAttributes.POSITION;
        attributes[3] = VertexAttributes.TEXCOORDS[0];
        attributes[4] = VertexAttributes.TEXCOORDS[0];
        
        geometry.addVertexStream(attributes);
        
        geometry.numVertices = positions.length/3;
        
        geometry.setAttributeValues(VertexAttributes.POSITION, positions);
        geometry.setAttributeValues(VertexAttributes.TEXCOORDS[0], texcoords);
        
        geometry.indices = indices;            
        
        var result:Mesh = new Mesh()
        result.geometry = geometry;
        
        //サーフェースのコピー
        var indexBegin:uint = 0
        for (i = 0; i < count; i++) {
            mesh = meshs[i];
            for (j = 0; j < mesh.numSurfaces; j++) {
                var surface:Surface = mesh.getSurface(j);
                result.addSurface(surface.material, surface.indexBegin+indexBegin, surface.numTriangles)
            }
            indexBegin = surface.indexBegin+indexBegin + surface.numTriangles * 3;
        }
        
        //normal再計算
        createNormal(result);
        return result;
    }
    
    
    /**
     * Cylinder、Cone、Dome、RoundMesh等を合成した、MeshのSurfaceを合成します
     * UVのV値のみ更新されます
     * 
     * 頂点情報の高さ(Z座標)で判断します
     * 
     */
    public static function repairRoundSurface(mesh:Mesh):Mesh {
        var positions:Vector.<Number> = mesh.geometry.getAttributeValues(VertexAttributes.POSITION);
        var texcoords:Vector.<Number> = mesh.geometry.getAttributeValues(VertexAttributes.TEXCOORDS[0]);
        var count:int = positions.length / 3
        //全体の高さを割り出す
        var minY:Number=0
        var maxY:Number=0
        for (var i:int = 0; i < count; i++) {
            if (minY > positions[i * 3 + 2])
                minY = positions[i * 3 + 2];
            if (maxY < positions[i * 3 + 2])
                maxY = positions[i * 3 + 2];
        }
        
        var height:Number = maxY - minY;
        for (i = 0; i < count; i++) {
            texcoords[i * 2 + 1] = (positions[i * 3 + 2] - minY) / height;
        }
        mesh.geometry.setAttributeValues(VertexAttributes.TEXCOORDS[0], texcoords);
        var result:Mesh = new Mesh();
        result.geometry = mesh.geometry
        result.addSurface(null, 0, positions.length / 9);
        return result;
    }
    
    
    /**
     * サーフェースのコピー
     * @param    origin
     * @param    mesh
     */
    public static function copySurface(origin:Mesh, mesh:Mesh):void {
        for (var i:uint = 0; i < origin.numSurfaces; i++) {
            var surface:Surface = origin.getSurface(i);
            mesh.addSurface(surface.material, surface.indexBegin, surface.numTriangles)
        }
    }

    
    /**
     * TANGENT4を再計算
     * @param    indices
     * @param    vertex
     * @param    uvs
     * @param    normals
     * @return
     */
    static public function calcTangent(indices:Vector.<uint>, vertices:Vector.<Vector3D>, uvs:Vector.<Point>, normals:Vector.<Vector3D>):Vector.<Number> {
        var tangent:Vector.<Number> = new Vector.<Number>;
        var numTriangle:int = indices.length / 3;
        var numVertex:int = vertices.length;
        
        var tan1:Vector.<Vector3D> = new Vector.<Vector3D>;
        var tan2:Vector.<Vector3D> = new Vector.<Vector3D>;
        
        var i:int;
        for (i = 0; i < vertices.length; i++) {
            tan1.push(new Vector3D());
            tan2.push(new Vector3D());
        }
        
        var max:int = indices.length;
        for (i = 0; i < max; i += 3) {
            var i1:Number = indices[i];
            var i2:Number = indices[i + 1];
            var i3:Number = indices[i + 2];
            
            var v1:Vector3D = vertices[i1];
            var v2:Vector3D = vertices[i2];
            var v3:Vector3D = vertices[i3];
            
            var w1:Point = uvs[i1];
            var w2:Point = uvs[i2];
            var w3:Point = uvs[i3];
            
            var x1:Number = v2.x - v1.x;
            var x2:Number = v3.x - v1.x;
            var y1:Number = v2.y - v1.y;
            var y2:Number = v3.y - v1.y;
            var z1:Number = v2.z - v1.z;
            var z2:Number = v3.z - v1.z;
            
            var s1:Number = w2.x - w1.x;
            var s2:Number = w3.x - w1.x;
            var t1:Number = w2.y - w1.y;
            var t2:Number = w3.y - w1.y;
            
            var r:Number = 1 / (s1 * t2 - s2 * t1);
            var sdir:Vector3D = new Vector3D((t2 * x1 - t1 * x2) * r, (t2 * y1 - t1 * y2) * r, (t2 * z1 - t1 * z2) * r);
            var tdir:Vector3D = new Vector3D((s1 * x2 - s2 * x1) * r, (s1 * y2 - s2 * y1) * r, (s1 * z2 - s2 * z1) * r);
            
            tan1[i1].incrementBy(sdir);
            tan1[i2].incrementBy(sdir);
            tan1[i3].incrementBy(sdir);
            
            tan2[i1].incrementBy(tdir);
            tan2[i2].incrementBy(tdir);
            tan2[i3].incrementBy(tdir);
        }
        
        for (i = 0; i < numVertex; i++) {
            var n:Vector3D = normals[i];
            var t:Vector3D = tan1[i];
            var tgt:Vector3D = t.subtract(getScaled(n, dot(n, t)));
            tgt.normalize();
            var w:Number = dot(cross(n, t), tan2[i]) < 0 ? -1 : 1;
            tangent.push(tgt.x, tgt.y, tgt.z, w);
        }
        return tangent;
    }
    
    /**
     * 2つのベクトルの内積を返します。
     * (内積：2つのベクトルがどれだけ平行に近いかを示す数値)
     * ・ 1 に近いほど同じ向きで平行
     * ・ 0 に近いほど直角
     * ・-1 に近いほど逆向きで平行
     */
    static public function dot(a:Vector3D, b:Vector3D):Number {
        return (a.x * b.x) + (a.y * b.y) + (a.z * b.z);
    }
    
    /**
     * 2つのベクトルの外積を返します。
     * (外積：2つのベクトルで作られる面に垂直なベクトル(=法線)。)
     */
    static public function cross(a:Vector3D, b:Vector3D):Vector3D {
        return new Vector3D((a.y * b.z) - (a.z * b.y), (a.z * b.x) - (a.x * b.z), (a.x * b.y) - (a.y * b.x));
    }
    
    /**
     * スケーリングした新しいベクトルを取得
     * @param    v
     * @param    scale
     * @return
     */
    static public function getScaled(v:Vector3D, scale:Number):Vector3D {
        var sv:Vector3D = v.clone();
        sv.scaleBy(scale);
        return sv;
    }
    
    /**
     * Jointの位置を初期化
     * @param    joints
     */
    public static function JointBindPose(joints:Vector.<Joint>):void {
        var count:uint = joints.length;
        for (var i:uint = 0; i < count; i++) 
        {
            var joint:Joint = joints[i]
            var jointMatrix:Matrix3D = joint.concatenatedMatrix.clone();

            jointMatrix.transpose();
            var jointBindingTransform:Transform3D = new Transform3D();
            jointBindingTransform.initFromVector(jointMatrix.rawData);
            jointBindingTransform.invert();
            var matrixVector:Vector.<Number> = new Vector.<Number>();
            matrixVector.push(jointBindingTransform.a);
            matrixVector.push(jointBindingTransform.b);
            matrixVector.push(jointBindingTransform.c);
            matrixVector.push(jointBindingTransform.d);
            matrixVector.push(jointBindingTransform.e);
            matrixVector.push(jointBindingTransform.f);
            matrixVector.push(jointBindingTransform.g);
            matrixVector.push(jointBindingTransform.h);
            matrixVector.push(jointBindingTransform.i);
            matrixVector.push(jointBindingTransform.j);
            matrixVector.push(jointBindingTransform.k);
            matrixVector.push(jointBindingTransform.l);
            
            joint.setBindPoseMatrix(matrixVector);

        }
    }
    

}

    

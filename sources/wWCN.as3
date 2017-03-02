/**
 * 環境マップの練習。これを再現したかった→http://atnd.org/events/7558
 * 開封してないのに量が少ないのは、中に渦巻き状のかわいい動物を浮かべようと思っていたからです。
 * モデルの切れ目で環境マップがうまく繋がらなかった。
 */
package  {
    import flash.display.*;
    import flash.events.*;
    import flash.filters.*;
    import flash.geom.*;
    import org.papervision3d.*;
    import org.papervision3d.core.math.*;
    import org.papervision3d.materials.*;
    import org.papervision3d.materials.shaders.*;
    import org.papervision3d.objects.*;
    import org.papervision3d.objects.primitives.*;
    import org.papervision3d.view.*;
    import org.papervision3d.view.layer.*;
    import org.papervision3d.view.layer.util.*;
    public class Wine extends BasicView {
        private var _sd:SceneDragger;
        private var _cameraTarget:DisplayObject3D;
        private var _loader:ImageLoader;
        private var _wineClip:Water;
        private var _env:EnvMaterials;
        private var _layerIndex:int = 0;
        public function Wine() {
            stage.frameRate = 30;
            stage.quality = StageQuality.MEDIUM;
            super(465, 465, false, false, "Free");
            Papervision3D.PAPERLOGGER.unregisterLogger(Papervision3D.PAPERLOGGER.traceLogger);
            viewport.containerSprite.sortMode = ViewportLayerSortMode.INDEX_SORT;
            _env = new EnvMaterials();
            scene.addChild(_env.light);
            _wineClip = new Water();
            _loader = new ImageLoader();
            _loader.addImage("http://assets.wonderfl.net/images/related_images/9/99/99df/99df247118128bccbb814b0817df6b7ebddfc195", "label");
            _loader.addImage("http://assets.wonderfl.net/images/related_images/c/c9/c9f7/c9f7df890697cd70637af9706fe3a9165906623b", "refect1");
            _loader.addImage("http://assets.wonderfl.net/images/related_images/3/30/3050/3050d8828318b2aa11097bd88c0ffd2d17fb2856", "refect2");
            _loader.load(onLoaded);
            addChildAt(Painter.createColorRect(465, 465, Color.BG), 0);
        }
        private function onLoaded(...rest):void {
            createTable();
            createBottle();
            startRendering();
            _sd = new SceneDragger(stage, 105, 20);
            _sd.setAngleLimit(-15, 55);
            _sd.addEventListener(Event.CHANGE, onMoveCamera);
            _cameraTarget = new DisplayObject3D();
            _cameraTarget.y = 400;
            onMoveCamera(null);
        }
        private function createTable():void {
            var tableImg:BitmapData = new BitmapData(512, 512, false);
            tableImg.noise(1234, 150, 180, 7, true);
            tableImg.draw(Painter.createGradientRect(512, 512, false, [Color.BG, Color.BG], [0, 1], [0.5, 1]));
            var tableMap:BitmapMaterial = new BitmapMaterial(tableImg);
            var table:Plane = new Plane(tableMap, 1000, 1000, 5, 5);
            table.rotationX = 90;
            table.y = -3;
            addChildLayer(table);
        }
        private function createBottle():void {
            var segmentS:int = 12;
            var segmentW:int = 4;
            var radius:Number = 120;
            var topRadius:Number = 45;
            var baseHeight:Number = 550;
            var waveHeight:Number = 150;
            var topHeight:Number = 60;
            var capHeight:Number = 150;
            
            //画像
            var refrectImg1:BitmapData = _loader.image.refect1;
            var refrectImg2:BitmapData = _loader.image.refect2;
            var labelImg:BitmapData = _loader.image.label;
            var glassImg:BitmapData = new BitmapData(128, 128, true, 0xFF * 0.85 << 24 | Color.GLASS);
            var capImg:BitmapData = new BitmapData(128, 128, false, 0xFF << 24 | Color.CAP);
            var shadowImg:BitmapData = new BitmapData(128, 128, true, 0);
            shadowImg.draw(Painter.createGradientRect(128, 128, true, [0, 0, 0], [0.5, 0.2, 0], [0, 0.5, 1], 90));
            var noiseImg:BitmapData = new BitmapData(465, 465, false);
            noiseImg.noise(1234, 0, 150, 1, true);
            
            //環境マップテクスチャ
            var labelMap:ShadedMaterial = _env.createEnvMaterial(labelImg, refrectImg2);
            var glassMap:ShadedMaterial = _env.createEnvMaterial(glassImg, refrectImg1);
            var capMap1:ShadedMaterial = _env.createEnvMaterial(capImg, refrectImg2);
            var capMap2:ColorMaterial = new ColorMaterial(Color.CAP);
            var shadowMap:BitmapMaterial = new BitmapMaterial(shadowImg);
            
            //ボトル生成
            var bottle1:TubePlane = new TubePlane(glassMap, radius, baseHeight, segmentS, 2);
            var bottle2:WavyTube = new WavyTube(glassMap, radius, topRadius, waveHeight, segmentS, segmentW);
            bottle2.y = baseHeight;
            var bottle3:TubePlane = new TubePlane(glassMap, topRadius, topHeight, segmentS, 1);
            bottle3.y = baseHeight + waveHeight;
            
            //何故かフタ付きの円柱を作ると環境マップが汚くなるので側面とフタをわける
            var cap1:Cylinder = new Cylinder(capMap1, topRadius+2, capHeight, segmentS, 1, -1, false, false);
            var cap2:Cylinder = new Cylinder(capMap2, topRadius+2, 0.001, segmentS, 1, -1, true, false);
            cap2.y = baseHeight + waveHeight + topHeight + capHeight - 5;
            cap1.y = baseHeight + waveHeight + topHeight + capHeight/2 - 5;
            
            //ラベル
            var label1:TubePlane = new TubePlane(labelMap, radius, 250, segmentS / 2, 1, Math.PI *0.75);
            label1.y = 250;
            var label2:DisplayObject3D = label1.clone();
            label2.material = new ColorMaterial(Color.LABEL_R);
            label2.geometry.flipFaces();
            
            //反射影
            var shadow:TubePlane = new TubePlane(shadowMap, radius, baseHeight, segmentS, 1);
            shadow.y = -baseHeight + 15;
            
            //ワインの中身
            var wineMap:MovieMaterial = new MovieMaterial(_wineClip, true, true, false, _wineClip.size);
            wineMap.doubleSided = true;
            var wine:TubePlane = new TubePlane(wineMap, radius - 5, 450, 12, 1);
            wine.y = 3;
            
            
            addChildLayer(shadow).filters = [
                new BlurFilter(8, 8, 1),
                new DisplacementMapFilter(noiseImg, new Point(0, 0), 1, 1, 8, -10, DisplacementMapFilterMode.IGNORE)
            ];
            addChildLayer(label2);
            addChildLayer(wine);
            addChildLayer(bottle1);
            addChildLayer(bottle2);
            addChildLayer(bottle3);
            addChildLayer(label1);
            addChildLayer(cap1);
            addChildLayer(cap2);
        }
        private function addChildLayer(model:DisplayObject3D):ViewportLayer {
            scene.addChild(model);
            var layer:ViewportLayer = viewport.containerSprite.getChildLayer(model);
            layer.layerIndex = ++_layerIndex;
            return layer;
        }
        private function onMoveCamera(e:Event):void {
            var p:Number3D = _sd.getPosition(1000);
            p.plusEq(_cameraTarget.position);
            camera.position = p;
            camera.lookAt(_cameraTarget);
            _env.updateCamera(camera);
        }
    }
}
import flash.display.*;
import flash.events.*;
import flash.geom.*;
import flash.net.*;
import flash.system.*;
import org.papervision3d.core.geom.renderables.*;
import org.papervision3d.core.math.*;
import org.papervision3d.core.proto.*;
import org.papervision3d.lights.*;
import org.papervision3d.materials.*;
import org.papervision3d.materials.shaders.*;
import org.papervision3d.objects.primitives.*;
class Color {
    static public const WINE_T:uint = 0xEC3366;
    static public const WINE_B:uint = 0x700404;
    static public const GLASS:uint = 0x111A07;
    static public const CAP:uint = 0xA40606;
    static public const BG:uint = 0x000000;
    static public const LABEL_R:uint = 0xC0B38D;
}
/**
 * 環境マップ生成
 */
class EnvMaterials {
    //共通ライト
    public var light:PointLight3D;
    public function EnvMaterials() {
        light = new PointLight3D();
    }
    public function createEnvMaterial(texture:BitmapData, refrect:BitmapData, precise:Boolean = false):ShadedMaterial {
        var textureMap:BitmapMaterial = new BitmapMaterial(texture, precise);
        textureMap.smooth = true;
        var shader:EnvMapShader = new EnvMapShader(light, refrect, refrect, 0);
        var material:ShadedMaterial = new ShadedMaterial(textureMap, shader, ShaderCompositeModes.PER_LAYER);
        return material;
    }
    public function updateCamera(cam:CameraObject3D):void {
        light.copyPosition(cam);
    }
}
/**
 * 適当にうねる液体
 */
class Water extends Sprite {
    public var size:Rectangle = new Rectangle(0, 0, 256, 128);
    private var _mtx:Matrix;
    private var _heights:Array = [0, 60, 120, 195, 270, 315, 0];
    private var _speeds:Array = [5, 4, 3, 4, 3, 4, 5];
    public function Water() {
        _mtx = new Matrix();
        _mtx.createGradientBox(size.width, size.height/4, Math.PI / 2, 0, 0);
        draw();
        addEventListener(Event.ENTER_FRAME, onEnterFrame);
    }
    private function onEnterFrame(e:Event):void {
        draw();
    }
    private function draw():void {
        graphics.clear();
        graphics.beginGradientFill(GradientType.LINEAR, [Color.WINE_T, Color.WINE_B], [0.8, 0.8], [0, 255], _mtx);
        graphics.moveTo(size.width, size.height);
        graphics.lineTo(0, size.height);
        for (var i:int = 0; i < _heights.length; i++) {
            _heights[i] = (_heights[i] + _speeds[i]*2) % 360;
            var wh:Number = (Math.cos(Math.PI / 180 * _heights[i]) + 1) * 5;
            graphics.lineTo(size.width/(_heights.length-1)*i, wh);
        }
        graphics.endFill();
    }
}
/**
 * 筒
 */
class TubePlane extends Plane {
    public function TubePlane(material:MaterialObject3D = null, radius:Number = 100, height:Number = 100, segmentsW:int = 8, segmentsH:int = 6, radian:Number = Math.PI * 2, reverse:Boolean = false) {
        super(material, 100, height, segmentsW, segmentsH);
        var i:int = -1;
        for each(var v:Vertex3D in geometry.vertices) {
            i++;
            var ih:int = i / (segmentsH + 1);
            var iv:int = i % (segmentsH + 1);
            var rad:Number = radian / segmentsW * ih;
            v.x = Math.cos(rad) * radius;
            v.z = Math.sin(rad) * radius;
            v.y = iv * height / segmentsH;
        }
        for each(var f:Triangle3D in geometry.faces) f.createNormal();
        geometry.ready = true;
    }
}
/**
 * サインカーブの筒
 */
class WavyTube extends TubePlane {
    public function WavyTube(material:MaterialObject3D = null, radius:Number = 100, topRadius:Number = 50, height:Number = 100, segmentsW:int = 16, segmentsH:int = 8, topFace:Boolean = false, bottomFace:Boolean = false) {
        super(material, radius, height, segmentsW, segmentsH);//, -1, topFace, bottomFace
        var minY:Number = 0;
        var maxY:Number = height;
        var scale:Number = topRadius / radius;
        for each(var v:Vertex3D in geometry.vertices) {
            var rot:Number = Math.max(0, Math.min(1, (v.y - minY) / (maxY - minY))) * 180 - 90;
            var zoom:Number = (Math.sin(rot * Math.PI / 180) + 1) * 0.5 * (scale-1) + 1;
            v.x *= zoom;
            v.z *= zoom;
        }
    }
}
/**
 * 複数画像読み込み
 */
class ImageLoader {
    public var image:Object = new Object();
    private var _images:Array = new Array();
    private var _count:int;
    private var _completeFunc:Function;
    private var _errorFunc:Function;
    private var _activeLoader:Loader;
    public function ImageLoader() {
    }
    public function addImage(src:String, name:String):void {
        _images.push( { src:src, name:name } );
    }
    public function load(complete:Function, error:Function = null):void {
        _count = -1;
        _completeFunc = complete;
        _errorFunc = error;
        next();
    }
    private function next():void {
        if (++_count >= _images.length) {
            if (_completeFunc != null) _completeFunc();
            return;
        }
        _activeLoader = new Loader();
        _activeLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
        _activeLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
        _activeLoader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
        _activeLoader.load(new URLRequest(_images[_count].src), new LoaderContext(true));
    }
    private function onError(e:ErrorEvent):void {
        _activeLoader = null;
        removeEvent(e.currentTarget as LoaderInfo);
        if (_errorFunc != null) _errorFunc.apply(null, []);
    }
    private function onComplete(e:Event):void {
        _activeLoader = null;
        var info:LoaderInfo = e.currentTarget as LoaderInfo;
        removeEvent(info);
        if (info.content is Bitmap) {
            image[_images[_count].name] = Bitmap(info.content).bitmapData;
        } else {
            image[_images[_count].name] = info.content;
        }
        next();
    }
    private function removeEvent(target:LoaderInfo):void {
        target.removeEventListener(Event.COMPLETE, onComplete);
        target.removeEventListener(IOErrorEvent.IO_ERROR, onError);
        target.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
    }
}
class Painter {
    /**
     * 一色塗りスプライト生成
     */
    static public function createColorRect(width:Number, height:Number, color:uint = 0x000000, alpha:Number = 1):Sprite {
        var sp:Sprite = new Sprite();
        sp.graphics.beginFill(color, alpha);
        sp.graphics.drawRect(0, 0, width, height);
        sp.graphics.endFill();
        return sp;
    }
    /**
     * グラデーションスプライト生成
     */
    static public function createGradientRect(width:Number, height:Number, isLinear:Boolean, colors:Array, alphas:Array, ratios:Array = null, r:Number = 0):Sprite {
        var i:int, ratioList:Array = new Array();
        if (ratios == null) {
            for (i = 0; i < colors.length; i++) ratioList.push(int(255 * i / (colors.length - 1)));
        } else {
            for (i = 0; i < ratios.length; i++) ratioList[i] = Math.round(ratios[i] * 255);
        }
        var sp:Sprite = new Sprite();
        var mtx:Matrix = new Matrix();
        mtx.createGradientBox(width, height, Math.PI / 180 * r, 0, 0);
        var type:String = (isLinear)? "linear" : "radial";
        sp.graphics.beginGradientFill(type, colors, alphas, ratioList, mtx);
        sp.graphics.drawRect(0, 0, width, height);
        sp.graphics.endFill();
        return sp;
    }
}
/**
 * シーンをマウスでぐるぐる
 */
class SceneDragger extends EventDispatcher {
    private var _rotation:Number;
    private var _angle:Number;
    private var _rotationMinLimit:Number = NaN;
    private var _rotationMaxLimit:Number = NaN;
    private var _angleMinLimit:Number = NaN;
    private var _angleMaxLimit:Number = NaN;
    private var _sprite:DisplayObject;
    private var _saveRotation:Number;
    private var _saveAngle:Number;
    private var _saveMousePos:Point;
    public function SceneDragger(sprite:DisplayObject, rotation:Number = 0, angle:Number = 30) {
        _angle = angle;
        _rotation = rotation;
        _sprite = sprite;
        _sprite.addEventListener(MouseEvent.MOUSE_DOWN, onMsDown);
        _sprite.stage.addEventListener(MouseEvent.MOUSE_UP, onMsUp);
    }
    public function setAngleLimit(min:Number, max:Number):void {
        _angleMinLimit = min;
        _angleMaxLimit = max;
    }
    public function setRotationLimit(min:Number, max:Number):void {
        _rotationMinLimit = min;
        _rotationMaxLimit = max;
    }
    private function onMsDown(e:MouseEvent):void {
        _sprite.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMsMove);
        _saveRotation = _rotation;
        _saveAngle = _angle;
        _saveMousePos = new Point(_sprite.mouseX, _sprite.mouseY);
    }
    private function onMsMove(e:MouseEvent):void {
        var dragOffset:Point = new Point(_sprite.mouseX, _sprite.mouseY).subtract(_saveMousePos);
        _rotation = _saveRotation - dragOffset.x * 0.5;
        if (!isNaN(_rotationMinLimit) && _rotation < _rotationMinLimit) _rotation = _rotationMinLimit;
        if (!isNaN(_rotationMaxLimit) && _rotation > _rotationMaxLimit) _rotation = _rotationMaxLimit;
        _angle = Math.max(-89, Math.min(89, _saveAngle + dragOffset.y * 0.5));
        if (!isNaN(_angleMinLimit) && _angle < _angleMinLimit) _angle = _angleMinLimit;
        if (!isNaN(_angleMaxLimit) && _angle > _angleMaxLimit) _angle = _angleMaxLimit;
        dispatchEvent(new Event(Event.CHANGE));
    }
    private function onMsUp(...rest):void {
        _sprite.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMsMove);
        dispatchEvent(new Event(Event.CHANGE));
    }
    public function getPosition(distance:Number):Number3D {
        var per:Number = Math.cos(Math.PI / 180 * _angle);
        var px:Number = Math.cos(Math.PI / 180 * _rotation) * distance * per;
        var py:Number = Math.sin(Math.PI / 180 * _angle) * distance;
        var pz:Number = Math.sin(Math.PI / 180 * _rotation) * distance * per;
        return new Number3D(px, py, pz);
    }
}
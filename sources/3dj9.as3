/**
 * Fork元と同じシーンをAlternativa3D7.6用に修正。
 * BSPContainerは戦闘機モデルだけに使うようにしてみました。
 */
package {
    
    import alternativ7.engine3d.containers.BSPContainer;
    import alternativ7.engine3d.core.Object3D;
    import alternativ7.engine3d.core.Object3DContainer;
    import alternativ7.engine3d.loaders.events.LoaderErrorEvent;
    import alternativ7.engine3d.loaders.events.LoaderProgressEvent;
    import alternativ7.engine3d.loaders.MaterialLoader;
    import alternativ7.engine3d.loaders.ParserCollada;
    import alternativ7.engine3d.materials.FillMaterial;
    import alternativ7.engine3d.materials.TextureMaterial;
    import alternativ7.engine3d.objects.Mesh;
    import com.bit101.components.*;
    import flash.display.*;
    import flash.events.*;
    import flash.filters.GlowFilter;
    import flash.geom.ColorTransform;
    import flash.geom.Vector3D;
    import flash.net.URLLoader;
    import flash.net.URLRequest;
    import flash.system.LoaderContext;
    import flash.system.Security;
    import flash.utils.Dictionary;
    import org.libspark.betweenas3.BetweenAS3;
    import org.libspark.betweenas3.easing.Quad;
    import org.libspark.betweenas3.tweens.ITween;
    import org.libspark.betweenas3.tweens.ITweenGroup;
    
    public class Alternativa3DTest760 extends Sprite {
        
        private var _scene:Scene3D;
        private var _buttonContainer:Sprite = new Sprite();
        private var _dragger:SphericalDragger;
        private var _autocamPos:Vector3D = new Vector3D();
        private var _autocamGaze:Vector3D = new Vector3D();
        private var _cameraMode:int = 0;
        private var _meshList:Vector.<Mesh>;
        private var _refList:Vector.<Mesh>;
        
        private var _loadingTxt:Label;
        private var _wireMaterial:FillMaterial = new FillMaterial(0, 0, 0, 0xFFFFFF);
        private var _rawTextures:Dictionary = new Dictionary();
        private var _checkboxes:Vector.<CheckBox> = new Vector.<CheckBox>();
        
        private var _loader:URLLoader;
        private var _parser:ParserCollada;
        private var _mloader:MaterialLoader;
        private var _isInitError:Boolean = false;
        
        private const PATH_POLICY:String = "http://shelter.s377.xrea.com/crossdomain.xml";
        private const PATH_DIR:String = "http://shelter.s377.xrea.com/assets/wonderfl/alt3dtest/";
        private const PATH_DAE:String = "model7.6_wdfl.DAE";
        
        public function Alternativa3DTest760() {
            stage.frameRate = 60;
            stage.quality = StageQuality.LOW;
            stage.align = StageAlign.TOP_LEFT;
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.addEventListener(Event.RESIZE, onResize);
            
            _scene = new Scene3D(Scene3D.NOSORT, 465, 465);
            _scene.camera.fov = 75 * Math.PI / 180;
            
            //マウスドラッグで動かすカメラ用
            _dragger = new SphericalDragger(_scene.display, 45, 2, 350);
            _dragger.dragEnabled = _dragger.wheelEnabled = false;
            _dragger.angle.speed = _dragger.rotation.speed = 0.65;
            _dragger.angle.setLimit(-7, 90);
            _dragger.distance.setLimit(10, 420);
            
            //画面に配置するもの色々
            addChild(_scene.display);
            addChild(_buttonContainer);
            
            Style.LABEL_TEXT = 0xFFFFFF;
            Style.BACKGROUND = 0x444444;
            var vox:VBox = new VBox(_buttonContainer);
            vox.x = vox.y = 10;
            vox.filters = [new GlowFilter(0, 1, 2, 2, 100, 1)];
            var labels:Array = ["VOLUME LIGHT", "REFLECTION", "USER CAMERA", "WIREFRAME"];
            for (var i:int = 0; i < labels.length; i++)
                _checkboxes.push(new CheckBox(vox, 0, 0, labels[i], updateSettings));
            
            _loadingTxt = new Label(this, 10, 10, "LOADING ...");
            
            _buttonContainer.visible = false;
            _checkboxes[1].selected = true;
            
            onResize();
            startLoad();
        }
        
        private function updateSettings(e:MouseEvent = null):void {
            var m:Mesh;
            _scene.root.getChildByName("volumelight").visible = _checkboxes[0].selected;
            _scene.root.getChildByName("floor").blendMode = _checkboxes[1].selected? BlendMode.ADD : BlendMode.NORMAL;
            _cameraMode = int(_checkboxes[2].selected);
            _dragger.dragEnabled = _checkboxes[2].selected;
            for each(m in _refList)
                m.visible = _checkboxes[1].selected;
            for each(m in _meshList)
                m.setMaterialToAllFaces(_checkboxes[3].selected? _wireMaterial : _rawTextures[m]);
            _scene.render();
        }
        
        /**
         * 画面リサイズ時
         */
        private function onResize(e:Event = null):void {
            var sw:Number = stage.stageWidth, sh:Number = stage.stageHeight;
            _scene.setSize(sw, sh);
            _scene.render();
        }
        
        /**
         * Collada読み込み開始
         */
        private function startLoad():void {
            Security.loadPolicyFile(PATH_POLICY);
            _loader = new URLLoader();
            _loader.addEventListener(Event.COMPLETE, onLoadCollada);
            _loader.addEventListener(IOErrorEvent.IO_ERROR, onErrorAsset);
            _loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onErrorAsset);
            _loader.load(new URLRequest(PATH_DIR + PATH_DAE));
        }
        
        private function onErrorAsset(e:ErrorEvent):void {
            _loadingTxt.text = e.text;
            _loadingTxt.transform.colorTransform = new ColorTransform(0, 0, 0, 1, 0xFF, 0, 0);
            _isInitError = true;
        }
        
        /**
         * Colladaモデル読み込み完了時
         */
        private function onLoadCollada(e:Event):void {
            //Colladaデータをパース
            _parser = new ParserCollada();
            _parser.parse(new XML(_loader.data), PATH_DIR);
            
            //テクスチャ読み込み
            _mloader = new MaterialLoader();
            _mloader.addEventListener(LoaderErrorEvent.LOADER_ERROR, onErrorAsset);
            _mloader.addEventListener(LoaderProgressEvent.LOADER_PROGRESS, onProgressMaterial);
            _mloader.addEventListener(Event.COMPLETE, onCompleteMaterial);
            _mloader.load(_parser.textureMaterials, new LoaderContext(true));
        }
        
        private function onProgressMaterial(e:LoaderProgressEvent):void {
            if (_isInitError) return;
            var per:Number = e.totalProgress;
            _loadingTxt.text = "LOADING ... " + int(per * 100) + "%";
        }
        
        /**
         * テクスチャ読み込み完了時
         */
        private function onCompleteMaterial(e:Event):void {
            //マテリアルの読み込みに失敗していたら処理停止
            if (_isInitError) return;
            
            //全テクスチャのリピートをOFFにする
            for each(var tm:TextureMaterial in _parser.textureMaterials) tm.repeat = false;
            
            _parser.getObjectByName("volumelight").blendMode = BlendMode.OVERLAY;
            _parser.getObjectByName("floor").blendMode = BlendMode.ADD;
            
            var o:Object3D, name:String, m:Mesh;
            var cameras:Array = [[], []];
            for each(o in _parser.objects) {
                if (!(o is Mesh) && o.name && o.name.indexOf("Camera") == 0)
                    (o.name.indexOf(".Target") == -1)? cameras[0].push(o) : cameras[1].push(o);
            }
            //カメラリストを名前順にソート
            cameras[0].sortOn("name");
            cameras[1].sortOn("name");
            
            _refList = new Vector.<Mesh>();
            //ルートコンテナをObject3DContainerにしているのでaddChild()順にレンダリングされる
            var meshes:Array = ["wall_ref", "poles_ref", "box_ref", "light_ref", "objects_ref", "floor", "wall", "sunlight", "box", "truss", "truss2", "poles", "volumelight"];
            for each (name in meshes) {
                if ((o = _parser.getObjectByName(name))) {
                    _scene.root.addChild(o);
                    if (name.indexOf("_ref") != -1) _refList.push(o);
                }
            }
            var fighterContainer:BSPContainer = new BSPContainer();
            fighterContainer.addChild(_parser.getObjectByName("fighter"));
            _scene.root.addChild(fighterContainer);
            
            _meshList = getMeshList(_scene.root);
            for each(m in _meshList)
                _rawTextures[m] = m.faces[0].material;
            
            //自動カメラの動きをBetweenAS3で設定する
            var i:int, n:int, cf:Object3D, ct:Object3D, tw:ITween;
            var tweens:Array = [[], []];
            var targets:Array = [_autocamPos, _autocamGaze];
            var N:int = cameras[0].length;
            for (i = 0; i < N; i++) {
                for (n = 0; n < 2; n++) {
                    cf = cameras[n][i];
                    ct = cameras[n][(i + 1) % N];
                    tw = BetweenAS3.tween(targets[n], { x:ct.x, y:ct.y, z:ct.z }, { x:cf.x, y:cf.y, z:cf.z }, 2.5, Quad.easeInOut);
                    tweens[n].push(BetweenAS3.delay(tw, 0.5, 0));
                }
            }
            var itg:ITweenGroup = BetweenAS3.parallelTweens([BetweenAS3.serialTweens(tweens[0]), BetweenAS3.serialTweens(tweens[1])]);
            itg.stopOnComplete = false;
            itg.play();
            
            addChild(_scene.camera.diagram);
            _loadingTxt.visible = false;
            _buttonContainer.visible = true;
            updateSettings();
            onResize();
            addEventListener(Event.ENTER_FRAME, onEnterFrame);
            tw = BetweenAS3.tween({x:0}, {x:0}, {x:0}, 3);
            tw.onUpdate = function():void {
                var per:Number = tw.position / tw.duration;
                _scene.camera.view.transform.colorTransform = new ColorTransform(per, per, per, 1, 0, 0, 0, 0);
            }
            tw.onComplete = function():void {
                _scene.camera.view.transform.colorTransform = new ColorTransform();
            }
            tw.play();
        }
        
        /**
         * 内部のメッシュを全て取得
         */
        private function getMeshList(target:Object3D):Vector.<Mesh> {
            var i:int, m:Mesh, oc:Object3DContainer;
            var meshes:Vector.<Mesh> = new Vector.<Mesh>();
            if ((m = target as Mesh)) {
                meshes.push(m);
            } else if ((oc = target as Object3DContainer)) {
                for (i = 0; i < oc.numChildren; i++)
                    meshes = meshes.concat(getMeshList(oc.getChildAt(i)));
            }
            return meshes;
        }
        
        /**
         * 毎フレーム処理
         */
        private function onEnterFrame(e:Event = null):void {
            if (_cameraMode == 0) {
                //自動カメラモード
                _scene.controller.setObjectPos(_autocamPos);
                _scene.controller.lookAt(_autocamGaze);
            } else {
                //ドラッグカメラモード
                var v:Vector3D = _dragger.position;
                _scene.controller.setObjectPosXYZ(v.x, v.y, v.z + 80);
                _scene.controller.lookAtXYZ(0, 0, 80);
            }
            _scene.render();
        }
        
    }
    
}

import alternativ7.engine3d.containers.*;
import alternativ7.engine3d.controllers.SimpleObjectController;
import alternativ7.engine3d.core.*;
import flash.display.*;
import flash.events.*;
import flash.geom.*;

class Scene3D {
    public var display:Sprite = new Sprite();
    public var bg:Sprite = new Sprite();
    public var root:Object3DContainer;
    public var camera:Camera3D;
    public var controller:SimpleObjectController;
    private var _displayRect:Rectangle = new Rectangle();
    
    static public const DISTANCE:String = "distance";
    static public const BSP:String = "bsp";
    static public const KD:String = "kd";
    static public const CONFLICT:String = "conflict";
    static public const NOSORT:String = "nosort";
    
    public function Scene3D(container:String = CONFLICT, width:Number = 465, height:Number = 465, transparent:Boolean = false, bgColor:uint = 0x000000, bgAlpha:Number = 1) {
        switch(container) {
            case DISTANCE: root = new DistanceSortContainer(); break;
            case BSP: root = new BSPContainer(); break;
            case KD: root = new KDContainer(); break;
            case CONFLICT: root = new ConflictContainer(); break;
            case NOSORT: root = new Object3DContainer(); break;
            default: root = new ConflictContainer();
        }
        camera = new Camera3D();
        camera.view = new View(width, height);
        camera.fov = 60 * Math.PI / 180;
        root.addChild(camera);
        display.addChild(bg);
        display.addChild(camera.view);
        display.addEventListener(Event.ADDED_TO_STAGE, onAddedStage);
        controller = new SimpleObjectController(display, camera, 1);
        controller.unbindAll();
        
        setBgColor(transparent, bgColor, bgAlpha);
        setSize(width, height);
    }
    
    public function setSize(width:Number, height:Number):void {
        bg.width = camera.view.width = width;
        bg.height = camera.view.height = height;
    }
    
    public function setBgColor(transparent:Boolean = false, bgColor:uint = 0x000000, bgAlpha:Number = 1):void {
        bg.graphics.beginFill(bgColor, bgAlpha);
        bg.graphics.drawRect(0, 0, 100, 100);
        bg.graphics.endFill();
        bg.visible = !transparent;
    }
    
    private function onAddedStage(e:Event):void {
        display.removeEventListener(Event.ADDED_TO_STAGE, onAddedStage);
        render();
    }
    
    public function render():void {
        if (camera.view.stage) camera.render();
    }
    
}

/**
 * マウスでぐるぐる
 */
class SphericalDragger extends EventDispatcher {
    
    public var distance:Range = new Range();
    public var rotation:Range = new Range();
    public var angle:Range = new Range();
    public var dragEnabled:Boolean = true;
    public var wheelEnabled:Boolean = true;
    
    private var _eventObject:InteractiveObject;
    private var _clickPoint:Point;
    private var _position:Vector3D = new Vector3D();
    private const RADIAN:Number = Math.PI / 180;
    
    public var onMovePosition:Function;
    public function get position():Vector3D { return _position; }
    
    public function SphericalDragger(obj:InteractiveObject, rotation:Number = 0, angle:Number = 30, distance:Number = 1000) {
        this.distance.position = distance;
        this.distance.speed = 1.2;
        this.angle.position = angle;
        this.angle.min = -(this.angle.max = 89);
        this.rotation.position = rotation;
        _eventObject = obj;
        _eventObject.addEventListener(MouseEvent.MOUSE_DOWN, onMsDown);
        _eventObject.addEventListener(MouseEvent.MOUSE_WHEEL, onMsWheel);
        updatePosition();
    }
    
    public function notify():void {
        dispatchEvent(new Event(Event.CHANGE));
        if (onMovePosition != null) onMovePosition(_position);
    }
    
    private function onMsWheel(e:MouseEvent):void {
        if (!dragEnabled || !wheelEnabled) return;
        distance.position *= Math.pow(distance.speed, (e.delta < 0)? 1 : -1);
        distance.checkLimit();
        updatePosition();
    }
    
    private function onMsDown(e:MouseEvent):void {
        if (!dragEnabled) return;
        _eventObject.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMsMove);
        _eventObject.stage.addEventListener(MouseEvent.MOUSE_UP, onMsUp);
        rotation.prev = rotation.position;
        angle.prev = angle.position;
        _clickPoint = new Point(_eventObject.mouseX, _eventObject.mouseY);
    }
    
    private function onMsMove(e:MouseEvent):void {
        if (!dragEnabled) return;
        var dragOffset:Point = new Point(_eventObject.mouseX, _eventObject.mouseY).subtract(_clickPoint);
        rotation.position = rotation.prev - dragOffset.x * rotation.speed;
        rotation.checkLimit();
        angle.position = angle.prev + dragOffset.y * angle.speed;
        angle.checkLimit();
        updatePosition();
    }
    
    private function onMsUp(...rest):void {
        _eventObject.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMsMove);
        _eventObject.stage.removeEventListener(MouseEvent.MOUSE_UP, onMsUp);
        updatePosition();
    }
    
    private function updatePosition():void {
        var per:Number = Math.cos(RADIAN * angle.position);
        var px:Number = Math.cos(RADIAN * rotation.position) * distance.position * per;
        var py:Number = Math.sin(RADIAN * rotation.position) * distance.position * per;
        var pz:Number = Math.sin(RADIAN * angle.position) * distance.position;
        _position = new Vector3D(px, py, pz);
        notify();
    }
    
}

class Range {
    
    public var min:Number = NaN;
    public var max:Number = NaN;
    public var prev:Number = NaN;
    public var speed:Number = 1;
    public var position:Number = 0;
    
    public function Range() {
    }
    
    public function setLimit(min:Number, max:Number):void {
        this.min = min, this.max = max;
    }
    
    public function checkLimit():void {
        if (!isNaN(min) && position < min) position = min;
        else if (!isNaN(max) && position > max) position = max;
    }
    
}
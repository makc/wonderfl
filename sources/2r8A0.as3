package 
{
    //import alternativa.engine3d.spriteset.Sprite3DSet;
    //import alternativa.engine3d.spriteset.util.SpriteGeometryUtil;
    import alternativa.engine3d.alternativa3d;
    import alternativa.engine3d.core.Object3D;
    import alternativa.engine3d.core.Transform3D;
    import alternativa.engine3d.materials.FillMaterial;
    import alternativa.engine3d.materials.TextureMaterial;
    import alternativa.engine3d.primitives.Plane;
    import alternativa.engine3d.resources.BitmapTextureResource;
    import com.bit101.components.TextArea;
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.geom.Vector3D;
    import flash.ui.Keyboard;
    use namespace alternativa3d;
    /**
     * A high performance sprite batch renderer in Alternativa3D that you can use to help render old-school sprites, globally axis-locked sprites, z-locked sprites, etc. in batches,
     * You can use the class to create starfields (star streaks/hyperspace jump), dust, particle systems, etc. The Sprite3DSet Object3D class isn't prescriptive, since the rendering
     * engine is seperate from the particle/material system itself. Do whatever you wish in your own material/particle system, than pump the raw numeric data into the Sprite3DSet's sprite data arrays.
     * @author Glenn Ko
     */
    public class SpriteSetTest extends Sprite
    {
        
         private var _template:Template
        private const RADIAN:Number = Math.PI / 180;
         private const DEGREE:Number = 180 / Math.PI;
    
        //[Embed(source = "../../resources/images/test/leaf.png")]
         public static var LEAF:Class;
        
        static public const WORLD_SCALE:Number = 4;
                static private const SPEC_CAM_Z_OFF:Number = 23;
        
        private var ASSET_PATH:String;
        
        private var cardinal:CardinalVectors = new CardinalVectors();
        
        private var _pitchAmount:Number = 0;
        private var _turnAmount:Number = 0;
        private var _horizontalAmount:Number = 0;
        private var _verticalAmount:Number = 0;
        
        private var specCameraController:OrbitCameraController;

        
        public function SpriteSetTest() 
        {
           Wonderfl.disable_capture();
            
            var localMode:Boolean = (loaderInfo.url.indexOf("file://") >= 0);
           localMode = false;

            setup3DView();
        
            stage.addEventListener(Event.RESIZE, onStageResize);
            onStageResize();
            
            
        }
        
        private var _sw:Number;
        private var _sh:Number;
        private var _swPadd:Number;
        private var _shPadd:Number;
        private function onStageResize(e:Event=null):void 
        {
            var xPadd:Number = .2 * stage.stageWidth;
            var yPadd:Number = .2 * stage.stageHeight;
            scrollRegion.x = xPadd;
            scrollRegion.y = yPadd;
            scrollRegion.width = stage.stageWidth - xPadd;
            scrollRegion.height = stage.stageHeight - yPadd;
            _swPadd = 1/xPadd;
            _shPadd = 1/yPadd;
            
            _sw =stage.stageWidth;
            _sh = stage.stageHeight;
            
            scrollSpeed.x = intendedScrollSpeed.x / _sw * .5;
            scrollSpeed.y = intendedScrollSpeed.y / _sh * .5;
        }
        


        private function setupStuff():void {
            
                floor = new Plane(99999, 99999, 1, 1, false, false, null, new FillMaterial(0xDDDDDD));
                
                _template.scene.addChild(floor);
                
            specCameraController = new OrbitCameraController(_template.camera, _specFollowTarget, stage, stage, stage, false, true);
        specCameraController.minDistance = .1;
        specCameraController.setDistance(313, true);
        specCameraController.maxAngleLatidude = 45;
        specCameraController.minAngleLatitude = 2;
        specCameraController.maxPitch = 0;
        
            _template.controller = specCameraController;
            
            
            //_specFollowTarget.addChild(_floor);
            
            //_template.scene.removeChild(_template.rootControl);
            
            var leafData:BitmapData;
            if (LEAF != null) {
                throw new Error( BitmapEncoder.encodeBase64( new LEAF().bitmapData) );
                leafData = new LEAF().bitmapData;
            }
            else leafData = BitmapEncoder.decodeBase64( new Bmp_Leaf().str);
            var mat:TextureMaterial = new TextureMaterial(new BitmapTextureResource(leafData));
            mat.alphaThreshold = .99;
            
            var viewAligned:Boolean = true;
            var child:Object3D = _template.scene.addChild( spriteSetTest =  new Sprite3DSet(1000, viewAligned, mat, 32, 32, 120) );
            spriteSetTest.viewAlignedLockUp = true;
            spriteSetTest.randomisePositions(4);  // bitmask 4 (100), to ensure Z position is clamped to Zero floorn!
            // set normalized tree alignment to bottom ( last 2 parameters for originX,originY (right/up) respectively (0,-1) ) with custom geometry setting
            
            spriteSetTest.geometry = SpriteGeometryUtil.createNormalizedSpriteGeometry(spriteSetTest.getMaxSprites(), 0, SpriteGeometryUtil.guessRequirementsAccordingToMaterial(mat), 1, 0, -1);
            spriteSetAxis = spriteSetTest.setupAxisAlignment(0,0, 1);
            spriteSetTest.bakeSpriteData(true);  
            
            var spriteSetTest2:Sprite3DSet;
            _template.scene.addChild( spriteSetTest2 = new Sprite3DSet(3000, true, mat, 16 , 16, 120));
            spriteSetTest2.randomisePositions(0,0,1200,0,0,33);
            spriteSetTest2.bakeSpriteData();
            
            
            
            refreshCamPosition();
            
            _template.preUpdate = preUpdate;
            _template.preRender = preRender;
            
            stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
        
            _template.initialize();
        }
            
        
        private function preUpdate():void 
        {
            var mx:Number = mouseX;
            var my:Number = mouseY;
            if (autoScrollCamera && ( mx < scrollRegion.x || my < scrollRegion.y || mx > scrollRegion.width || my > scrollRegion.height) ) {
                mx -= _sw * .5;
                my -= _sh * .5;
                translateCamera( 
                mx / _sw * scrollSpeed.x
                ,my / _sh * scrollSpeed.y
                );
            }
            
            
            //specCameraController.setDistance( (specCameraController._angleLatitude-specCameraController.minAngleLatitude)/(specCameraController.maxAngleLatidude - specCameraController.minAngleLatitude) * 600 + 155, true);
        
        }
        
        private function preRender():void {
            
            //throw new Error("A");
        //    if (spriteSetTest) spriteSetTest.rotationX+=.01;
            //debugField.text = String( (specCameraController.maxAngleLatidude ) );
        }
        
    
                
        private var _scrnie:Bitmap;
        private function onKeyDown(e:KeyboardEvent):void 
        {
            var kc:uint = e.keyCode;
            switch(kc) {
                case Keyboard.F6:    
                      _template.takeScreenshot(screenieMethod);
                    
                    
                return;
                case Keyboard.F7:
                      _scrnie= _template.takeScreenshot(screenieMethod2);
                return;
                case Keyboard.O: 
                    
                    pitchAmount += .01 * Math.PI;
                    return
                    
            
                case Keyboard.P: 
                    pitchAmount -= .01 * Math.PI;
                    
                return;
                
                case Keyboard.K: 
                    turnAmount += .01 * Math.PI;
                    return;
                case Keyboard.L:
                    turnAmount -= .01 * Math.PI;
                    return;
                case Keyboard.UP:
                    verticalAmount--;
                    return;
                case Keyboard.W: // diff
                    translateCamera(0, -8);
                    //verticalAmount--;
                //    _template.rootControl.x--;
                    return;
                case Keyboard.DOWN:
                    verticalAmount++;
                    return;
                case Keyboard.S: // diff
                        translateCamera(0, 8);
                    //verticalAmount++;
                //    _template.rootControl.x++;
                    return;
                case Keyboard.LEFT:
                    horizontalAmount--;
                return;
                case Keyboard.A: // diff
                    //horizontalAmount--;
                    translateCamera(-8, 0);
                    return;
                case Keyboard.RIGHT:
                    horizontalAmount++;
                return;
            case Keyboard.D: // diff
                    translateCamera( 8, 0);
                    //horizontalAmount++;
                    return;
                case Keyboard.NUMPAD_ADD:
                    //_template.camera.z++;
                    specCameraController.setDistance(specCameraController.getDistance() + 1);
                    return;    
                case Keyboard.NUMPAD_SUBTRACT:
                    specCameraController.setDistance(specCameraController.getDistance() - 1);
                    return;    
                default:return;
            }
            
            
        }
        
        
        
        private function screenieMethod():Boolean 
        {
        //    Wonderfl.capture(); //
            return true;
        
        }
        
         private function screenieMethod2():Boolean 
        {

            stage.addEventListener(MouseEvent.CLICK, removeScreenie);
            return false;
        }
        
        private function removeScreenie(e:Event=null):void {
            if (_scrnie == null) return;
            stage.removeEventListener(MouseEvent.CLICK, removeScreenie);
            _scrnie.parent.removeChild(_scrnie);
            _scrnie = null;
        }

        
        private function setup3DView():void 
        {
            _template = new Template();
            _template.addEventListener(Template.VIEW_CREATE, initialize);
            addChild(_template);

            //camera.orthographic = true;
            _template.rootControl.z = 254;
            
        //    _template.rootControl.rotationX = Math.PI;
        //    _template.rootControl.rotationZ = DEFAULT_ROT_Z;
            
            //_template.rootControl.rotationY = -.45 * Math.PI;
            
            
        }
        
        private function initialize(event:Event):void {
            _template.removeEventListener(Template.VIEW_CREATE, initialize);
            
                _template.scene.addChild(_specFollowTarget);
        //        _specFollowTarget.addChild( new Box(10, 10, 10, 1, 1, 1, false, new FillMaterial(0xFF0000)));
                
            //マテリアル用のリソースの用意
            var bmd:BitmapData = new BitmapData(256, 256, true, 0xFF000000);
            bmd.perlinNoise(64, 64, 1, 1, true , true);
            var textureResource:BitmapTextureResource = new BitmapTextureResource(bmd);

            
            //Textureの作成
            var diffuseMap:BitmapData = new BitmapData(16, 16, false, 0xFF6666);
            var normalMap:BitmapData = new BitmapData(16, 16, false, 0x8080FF);

            //マテリアルの作成
            bitmapResource = new BitmapTextureResource(diffuseMap);
            normalResource = new BitmapTextureResource(normalMap);
            var materialA:TextureMaterial = new TextureMaterial(bitmapResource);
            var materialB:TextureMaterial = new TextureMaterial(normalResource);
            //var material:TextureMaterial = new TextureMaterial(bitmapResource);
        materialB.alpha = .6;
            materialB.alphaThreshold = .99;    
            
        
            bitmapResource.upload(_template.stage3D.context3D);
            normalResource.upload(_template.stage3D.context3D);
         
           setupStuff();
            

        }

        
        private function onEnterFrameRefresh(e:Event):void 
        {
            removeEventListener(Event.ENTER_FRAME, onEnterFrameRefresh);
                uiSpr.graphics.beginFill(0xFF0000, 0);
                uiSpr.graphics.drawRect(0, 0, uiSpr.width, uiSpr.height);
        }
        
        
        
        private function onVLayoutOver(e:MouseEvent):void 
        {
            
            //trackGridPos = false;
            
            autoScrollCamera = false;
        }
        
        private function onVayoutOUt(e:MouseEvent):void 
        {
        //    trackGridPos = true;
            autoScrollCamera = true;
            //checkGridPos();
        }
        
     
       
        
        
        //private var arcValueList:Array = [];  // for debuggign
        private var debugField:TextArea;

        private var normalResource:BitmapTextureResource;
        private var _floor:Plane;

        private var scrollRegion:Rectangle = new Rectangle();
        private var _specFollowTarget:Object3D = new Object3D();
        private var scrollSpeed:Point = new Point(234, 324);
        private var intendedScrollSpeed:Point = new Point(11222*2, 11222*2);
        private var autoScrollCamera:Boolean=true;
        private var uiSpr:Sprite;
    
        private var bitmapResource:BitmapTextureResource;
        private var spriteSetTest:Sprite3DSet;
        private var spriteSetAxis:Vector3D;
        private var floor:Plane;
        
        public function get pitchAmount():Number 
        {
            
            return _pitchAmount;
        }
        
        
        public function set pitchAmount(value:Number):void 
        {
            _pitchAmount = value;
            

        
                
                
        }
        
        public function get turnAmount():Number 
        {
            return _turnAmount;
        }
        
        public function set turnAmount(value:Number):void 
        {
            _turnAmount = value;

        
            
        }
        
        public function get horizontalAmount():Number 
        {
            return _horizontalAmount;
        }
        
        public function set horizontalAmount(value:Number):void 
        {
            _horizontalAmount = value;
            refreshCamPosition();
        }
        
        public function get verticalAmount():Number 
        {
            return _verticalAmount;
        }
        
        public function set verticalAmount(value:Number):void 
        {
            _verticalAmount = value;
            refreshCamPosition();
        }
        
        private function translateCamera(dispX:Number, dispY:Number):void {

            if (_template.camera.transformChanged) {
                _template.camera.composeTransforms();
            }
            var transform:Transform3D = _template.camera.transform;
    
            var dx:Number = transform.a * dispX + transform.b * dispY;
            var dy:Number =  transform.e * dispX + transform.f * dispY;

        //    var len:Number = 1 / Math.sqrt( dx * dx + dy * dy );
        //    dx *= len;
        //    dy *= len;
            
            _specFollowTarget._x += dx;
            _specFollowTarget._y +=dy;
            
            _horizontalAmount = _specFollowTarget._x * cardinal.east.x + _specFollowTarget._y * cardinal.east.y + _specFollowTarget._z * cardinal.east.z;
            _verticalAmount = _specFollowTarget._x * cardinal.south.x + _specFollowTarget._y * cardinal.south.y + _specFollowTarget._z * cardinal.south.z;
            
            _specFollowTarget.transformChanged = true;

        }
    
        
        private function refreshCamPosition():void 
        {

            _template.camera._x = cardinal.east.x * _horizontalAmount;
            _template.camera._y = cardinal.east.y * _horizontalAmount;
            _template.camera._z = cardinal.east.z * _horizontalAmount;
        
            _template.camera._x += cardinal.south.x * _verticalAmount;
            _template.camera._y += cardinal.south.y * _verticalAmount;
            _template.camera._z += cardinal.south.z * _verticalAmount;
            
            _specFollowTarget._x = _template.camera._x;
            _specFollowTarget._y = _template.camera._y;
            _specFollowTarget._z = _template.camera._z  + SPEC_CAM_Z_OFF;
            
            _template.camera.transformChanged = true;

            _specFollowTarget.transformChanged = true;
            
            
        }
        
        
    
        
        
        
    }
}
import alternativa.engine3d.controllers.SimpleObjectController;
import alternativa.engine3d.core.BoundBox;
import alternativa.engine3d.core.Resource;
import alternativa.engine3d.core.View;
import alternativa.engine3d.lights.AmbientLight;
import alternativa.engine3d.lights.DirectionalLight;
import flash.display.Bitmap;
import flash.display.InteractiveObject;
import flash.display.Sprite;
import flash.display.Stage3D;
import flash.display.StageAlign;
import flash.display.StageQuality;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.ui.Keyboard;
import flash.ui.Mouse;
import flash.ui.MouseCursor;


class CardinalVectors {
    public var east:Vector3D = new Vector3D(0, -1, 0);
    public var north:Vector3D = new Vector3D(1,0, 0);
    public var west:Vector3D = new Vector3D(0, 1, 0);
    public var south:Vector3D = new Vector3D(-1, 0, 0);
    
    public function transform(vec:Vector3D, obj:Object3D, distance:Number):void {
        obj.x += vec.x * distance;
        obj.y += vec.y * distance;
        obj.z += vec.z * distance;
    }
    
    public function set(vec:Vector3D, obj:Object3D, distance:Number):void {
        obj.x = vec.x * distance;
        obj.y = vec.y * distance;
        obj.z = vec.z * distance;
    }
    
    public function getDist(vec:Vector3D, boundBox:BoundBox, numGridSquares:uint=1, scaler:Number=2):Number {
        var val:Number =  (boundBox.maxX * vec.x +  boundBox.maxY * vec.y +   boundBox.maxZ * vec.z);
        val = val < 0 ? -val : val;
        val *= numGridSquares;
        val *= scaler;
        return val;
    }
    
}



class Template extends Sprite {
    public var rootControl:Object3D= new Object3D();
    public static const VIEW_CREATE:String = 'view_create'
    
    public var stage3D:Stage3D
    public var camera:Camera3D
    public var scene:Object3D

    public var controlObject:Object3D;
    public var controller:SimpleObjectController;
    
    protected var directionalLight:DirectionalLight;
    protected var ambientLight:AmbientLight;    
    
    //private var _previewCam:Camera3D:
    
    
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
        view.backgroundColor = 0xFFFFFF;
        view.antiAlias = 4
        addChild(view);
        
        //Scene（コンテナ）の作成
        scene = new Object3D();

        //Camera（カメラ）の作成
        camera = new Camera3D(1, 100000);
        camera.view = view;
        scene.addChild(camera)
        
        addChild(camera.diagram)
        
      
        
        //Lightを追加
        ambientLight = new AmbientLight(0xFFFFFF);
        ambientLight.intensity = 0.5;
        scene.addChild(ambientLight);
        
        //Lightを追加
        directionalLight = new DirectionalLight(0xFFFFFF);
        //手前右上から中央へ向けた指向性light
        directionalLight.x = 0;
        directionalLight.y = -100;
        directionalLight.z = 100;
        directionalLight.lookAt(0, 0, 0);
        scene.addChild(directionalLight);
        //directionalLight.visible = false;
        
    
        //コントロールオブジェクトの作成
        
    //    rootControl.rotationX = Math.PI * .5;
        scene.addChild(rootControl);
        controlObject = new Object3D()
        rootControl.addChild(controlObject);
        dispatchEvent(new Event(VIEW_CREATE));
        
        //customiseScene();
        
    }
    
    
    
    public function initialize():void {
        for each (var resource:Resource in scene.getResources(true)) {
     
            resource.upload(stage3D.context3D);
        }
        
        //オブジェクト用のコントローラー（マウス操作）
      //  objectController = new SimpleObjectController(stage, controlObject, 100);
      //  objectController.mouseSensitivity = 0.2;
        
        //レンダリング
        camera.render(stage3D);
        
        addEventListener(Event.ENTER_FRAME, onRenderTick);
    }
    
    public function takeScreenshot( method:Function=null) : Bitmap  //width:int, height:int,
     {
          var view:View = camera.view;
          /*
          var oldWidth:Number = view.width;
          var oldHeight:Number = view.height;  
          view.width = width;
          view.height = height; 
          */
          view.renderToBitmap = true;
          camera.render(stage3D);
         var canvas:BitmapData =  view.canvas.clone();
         // var bitmapData:BitmapData = view.canvas.clone();
          view.renderToBitmap = false;
        //  view.width = oldWidth;
        //  view.height = oldHeight;   
            var child:Bitmap = new Bitmap(canvas);
            stage.addChildAt( child,0 );
         // take screenshot here
             if (method!= null && method() ) {
                stage.removeChild(child);
             }
          return child;
     }

    
    public function onRenderTick(e:Event):void {

        if (preUpdate !=null) preUpdate();
        if (controller) controller.update();
        if (preRender != null) preRender();
        camera.render(stage3D);
        
    }
    
    public var preRender:Function 
    public var preUpdate:Function;

}


//package alternativa.engine3d.spriteset 
//{
    import alternativa.engine3d.core.Camera3D;
    import alternativa.engine3d.core.DrawUnit;
    import alternativa.engine3d.core.Light3D;
    import alternativa.engine3d.core.Object3D;
    import alternativa.engine3d.materials.compiler.Linker;
    import alternativa.engine3d.materials.compiler.Procedure;
    import alternativa.engine3d.materials.compiler.VariableType;
    import alternativa.engine3d.materials.Material;
    import alternativa.engine3d.materials.TextureMaterial;
    import alternativa.engine3d.alternativa3d;
    import alternativa.engine3d.objects.Mesh;

    import alternativa.engine3d.resources.Geometry;
//    import alternativa.engine3d.spriteset.util.SpriteGeometryUtil;
    import flash.display3D.Context3D;
    import flash.display3D.Context3DVertexBufferFormat;
    import flash.geom.Vector3D;
    import flash.utils.Dictionary;
    use namespace alternativa3d;
    
    /**
     * A 3d object to support batch rendering of sprites.
     * 
     * @author Glenn Ko
     */
    //public
    class Sprite3DSet extends Object3D
    {
        /**
         * Raw sprite data to upload to GPU if number of renderable sprites is lower than batch
         */
        public var spriteData:Vector.<Number>;
        /**
         * Raw sprite data to upload to GPU in batches if number of renderable sprite is higher than batch amount. (If you called bakeSpriteData(), this is automatically created)
         */
        public var staticBatches:Vector.<Vector.<Number>>;
        
        alternativa3d var uploadSpriteData:Vector.<Number>;
        private var toUploadSpriteData:Vector.<Number>;
        private var toUploadNumSprites:int;
        alternativa3d var maxSprites:int;
        alternativa3d var _numSprites:int;
        
        public var height:Number;
        public var width:Number;

    
        
        private var material:Material;
        private var surface:alternativa.engine3d.objects.Surface;
        public function setMaterial(mat:Material):void {
            this.material = mat;
            surface.material = mat;
        }
        
        private static var _transformProcedures:Dictionary = new Dictionary();
        public var geometry:Geometry;
        
        /**
         * Default maximum batch setting (number of uploadable sprites) per batch.
         */
        public static var MAX:int = 80;    
        
        private var NUM_REGISTERS_PER_SPR:int = 1;
        
        private var viewAligned:Boolean = false;
        /**
         * An alternative to "z-locking", if viewAligned is enabled, this flag can be used to lock axis along the local up (z) direction, but still keep the rightward-aligned orientation to camera view.
         */
        public var viewAlignedLockUp:Boolean = false;
    
        private static var UP:Vector3D = new Vector3D(0, 0, 1);
        
        alternativa3d var axis:Vector3D;

        /**
         *  Sets an arbituary normalized axis direction vector along a given direction for non-viewAligned option. The default setting is z-locked (0,0,1), but using
         * this option will allow alignemnt of sprites along a specific editable axis vector.
         * This method automatically disables viewAligned option. and updates the transform procedure to ensure arbituary axis alignment works.
         * @param    x
         * @param    y
         * @param    z
         * @return The axis reference which you can change at runtime
         */
        public function setupAxisAlignment(x:Number, y:Number, z:Number):Vector3D {
            viewAligned = false;
            axis =  new Vector3D(x, y, z);
            if (transformProcedure != null) validateTransformProcedure();
            return axis;
        }
    
          // TODO:
         // create specialised material that uses smallest possible vertex buffer data (2 tuple, quad-corner index and sprite index and spritesheet-animation support) that works with this class.
        
          
        /**
         * Constructor
         * @param    numSprites    The total number of sprites to render in this set
         * @param   viewAligned (Boolean) Whether to fully align sprites to camera screen orienation, or align to a locked axis (up - z) facing towards camera.
         * @param    material    Material to use for all sprites
         * @param    width        Default width (or scaling factor) of each sprite to use in world coordinate 
         * @param    height        Default height (or scaling factor) of each sprite to use in world coordinate
         * @param    maxSprites  (Optional) Default 0 will use static MAX setting. Defines the maximum uploadable batch amount of sprites that can upload at once to GPU for this instance.
         * @param    numRegistersPerSprite  (Optional) Default 1 will only use 1 constant register per sprite (which is the first register assumed to contain xyz position of each sprite). 
         *                                     Specify more registers if needed depending on material type.
         * @param    geometry   (Optional)   Specific custom geometry layout for the spriteset if needed, else, it'll try to create a normalized (1x1 sized geometry sprite batch geometry) to fit according to available material types in Alternativa3D. 
         */
        public function Sprite3DSet(numSprites:int, viewAligned:Boolean, material:TextureMaterial, width:Number, height:Number,maxSprites:int=0, numRegistersPerSprite:int=1, geometry:Geometry=null) 
        {
            super();
            
            this.geometry = geometry;
            this.viewAligned = viewAligned;
            
            NUM_REGISTERS_PER_SPR = numRegistersPerSprite;
            if (maxSprites <= 0) maxSprites = MAX;
            
            
            uploadSpriteData = new Vector.<Number>(((maxSprites*NUM_REGISTERS_PER_SPR) << 2),true);

            this.material = material;
            surface = new alternativa.engine3d.objects.Surface();
            surface.material = material;
            surface.object = this;
            surface.indexBegin = 0;
        
            this.width = width;
            this.height = height;
            
            this.maxSprites = maxSprites;
            
            
            _numSprites = numSprites;
            spriteData = new Vector.<Number>(((numSprites * NUM_REGISTERS_PER_SPR) << 2), true);
        }
        
        /*
        alternativa3d override function calculateVisibility(camera:Camera3D):void {
            
        }
        */
        
        alternativa3d override function setTransformConstants(drawUnit:DrawUnit, surface:alternativa.engine3d.objects.Surface, vertexShader:Linker, camera:Camera3D):void {
            drawUnit.setVertexBufferAt(vertexShader.getVariableIndex("joint"), geometry.getVertexBuffer(SpriteGeometryUtil.ATTRIBUTE), geometry._attributesOffsets[SpriteGeometryUtil.ATTRIBUTE], Context3DVertexBufferFormat.FLOAT_1);
            
            if (!viewAligned) {
                drawUnit.setVertexConstantsFromNumbers(vertexShader.getVariableIndex("cameraPos"), cameraToLocalTransform.d, cameraToLocalTransform.h, cameraToLocalTransform.l, 0);
                var axis:Vector3D = this.axis || UP;
                drawUnit.setVertexConstantsFromNumbers(vertexShader.getVariableIndex("up"), axis.x, axis.y, axis.z, 0);  
            }
            else {                
                if (!viewAlignedLockUp) drawUnit.setVertexConstantsFromNumbers(vertexShader.getVariableIndex("up"), -cameraToLocalTransform.b, -cameraToLocalTransform.f, -cameraToLocalTransform.j, 0)
                else  drawUnit.setVertexConstantsFromNumbers(vertexShader.getVariableIndex("up"), 0, 0, 1, 0);
                drawUnit.setVertexConstantsFromNumbers(vertexShader.getVariableIndex("right"), cameraToLocalTransform.a, cameraToLocalTransform.e, cameraToLocalTransform.i, 0);  
            }
            drawUnit.setVertexConstantsFromNumbers(vertexShader.getVariableIndex("spriteSet"), width*.5, height*.5, 0, 0);  
            drawUnit.setVertexConstantsFromVector(0, toUploadSpriteData, toUploadNumSprites*NUM_REGISTERS_PER_SPR ); 
        }
        
        override alternativa3d function collectDraws(camera:Camera3D, lights:Vector.<Light3D>, lightsLength:int, useShadow:Boolean):void {
        
            var spriteDataSize:int;
            var i:int;
            var numSprites:int = _numSprites;
        
            // setup defaults if required
            if (geometry == null) {
                geometry = SpriteGeometryUtil.createNormalizedSpriteGeometry(maxSprites, 0, SpriteGeometryUtil.guessRequirementsAccordingToMaterial(material), 1);
                geometry.upload( camera.context3D );
            }
            if (transformProcedure == null) validateTransformProcedure();
        

                if (_numSprites  <= maxSprites) {
                    toUploadSpriteData = spriteData;
                    toUploadNumSprites = _numSprites;
                    surface.numTriangles = (toUploadNumSprites << 1);
                     surface.material.collectDraws(camera, surface, geometry, lights, lightsLength, useShadow);
                }
                else if (staticBatches) {
                    spriteDataSize = NUM_REGISTERS_PER_SPR * 4;
                    for (i = 0; i < staticBatches.length; i++) {
                        toUploadSpriteData = staticBatches[i];
                        toUploadNumSprites = toUploadSpriteData.length / spriteDataSize;
                        surface.numTriangles = (toUploadNumSprites << 1);
                        surface.material.collectDraws(camera, surface, geometry, lights, lightsLength, useShadow);
                    }
                }
                else { 
                
                    spriteDataSize = (NUM_REGISTERS_PER_SPR << 2);
                    toUploadSpriteData = uploadSpriteData;
                    for (i = 0; i < _numSprites;  i += maxSprites) {
                        var limit:int = _numSprites - i;  // remaining sprites left to iterate
                        
                        if (limit > maxSprites) limit = maxSprites;
                        toUploadNumSprites = limit;
                        limit += i;
                    
                        var count:int = 0;
                        for (var u:int = i; u < limit; u++ ) {   // start sprite index to ending sprite index
                            var bu:int = u * spriteDataSize; 
                            var d:int = spriteDataSize;
                            while (--d > -1) toUploadSpriteData[count++] = spriteData[bu++];
                        }
                        surface.numTriangles = (toUploadNumSprites << 1);
                    
                        surface.material.collectDraws(camera, surface, geometry, lights, lightsLength, useShadow);
                    
                    }
                }
            
                // Mouse events
                //if (listening) camera.view.addSurfaceToMouseEvents(surface, geometry, transformProcedure);
                //    }
            
                // Debug
                /*
                if (camera.debug) {
                    var debug:int = camera.checkInDebug(this);
                    if ((debug & Debug.BOUNDS) && boundBox != null) Debug.drawBoundBox(camera, boundBox, localToCameraTransform);
                }
                */
        }
        

        /**
         * Sets up geometry according to settings found in this instance.
         * @param    context3D
         */
        public function setupDefaultGeometry(context3D:Context3D = null):void {    
            if (geometry != null) {
                geometry.dispose();
            }
            geometry = SpriteGeometryUtil.createNormalizedSpriteGeometry(maxSprites, 0, SpriteGeometryUtil.guessRequirementsAccordingToMaterial(material), 1);
            if (context3D) geometry.upload(context3D);
        }
        
        /**
         * Sets up transform procedure according to settings found in this instance.
         */
        public function validateTransformProcedure():void {
            transformProcedure = viewAligned ? getViewAlignedTransformProcedure(maxSprites) : axis!= null ? getAxisAlignedTransformProcedure(maxSprites) :  getTransformProcedure(maxSprites);
        }
        
    
        /**
         * Randomise positions of sprites of spriteData, assuming 1st register of each sprite refers to it's x,y,z position. Good for previewing spriteset.
         * @param   mask  (Optional) bitmask of x,y,z (1st,2nd and 3rd value) to set value to zero if mask hits.
         */
        public function randomisePositions(mask:int = 0, maskValue:Number = 0, range:Number = 1200, offsetX:Number = 0, offsetY:Number = 0, offsetZ:Number = 0 ):void {
            var multiplier:int = NUM_REGISTERS_PER_SPR * 4;
            var hRange:Number = range * .5;
            for (var i:int = 0; i < _numSprites; i++ ) {
                var baseI:int = i * multiplier;
                spriteData[baseI] = (mask & 1) ? maskValue :  -hRange + Math.random() * range  +offsetX;
                spriteData[baseI + 1] = (mask & 2) ? maskValue : -hRange + Math.random() * range+offsetY;
                spriteData[baseI + 2] = (mask & 4) ? maskValue : -hRange +  Math.random() * range +offsetZ;
            }
        }
        
        /**
         * Adjust number of sprites in spriteData. This would truncate sprites or add more to the list that can be editable.
         */
        public function set numSprites(value:int):void 
        {
            spriteData.fixed = false;
            spriteData.length  = ((value * NUM_REGISTERS_PER_SPR) << 2);
            spriteData.fixed = true;
            _numSprites = value;
                
        }
        
        /**
         * Will permanently render baked static sprite data information into a set of static batches, if total number of sprites to be drawn exceeds the batch size.
         * This can improve performance a bit for larger sets since you don't need to re-read data one-by-one from existing spriteData, if spriteData isn't changing,
         * or you might wish to use the static batches for your own direct manual editing.
         * @param     flushOldSpriteDataIfPossible (Boolean) Optional. Whether to null away spriteData reference if it exceeds batch size.
         * @return  The baked staticBatches reference for the current instance.
         */
        public function bakeSpriteData(flushOldSpriteDataIfPossible:Boolean = false):Vector.<Vector.<Number>> {
            
            // setup defaults if required
            if (geometry == null) geometry = SpriteGeometryUtil.createNormalizedSpriteGeometry(maxSprites, 0, SpriteGeometryUtil.guessRequirementsAccordingToMaterial(material), 1);
            if (transformProcedure == null) validateTransformProcedure();
            
            staticBatches = new Vector.<Vector.<Number>>();
            
            if (_numSprites <= maxSprites) {
                staticBatches.push(spriteData);
                return staticBatches;
            }
            
            var batch:Vector.<Number>;
            var i:int;

            var spriteDataSize:int = NUM_REGISTERS_PER_SPR * 4;
                    
                    for (i = 0; i < _numSprites;  i += maxSprites) {
                        var limit:int = _numSprites - i;  // remaining sprites left to iterate    
                        if (limit > maxSprites) limit = maxSprites;
                        limit += i;
            
                        var count:int = 0;
                        batch = new Vector.<Number>();
                        for (var u:int = i; u < limit; u++ ) {   // start sprite index to ending sprite index
                            var bu:int = u * spriteDataSize; 
                            var d:int = spriteDataSize;
                            while (--d > -1) batch[count++] = spriteData[bu++];
                        }
                        batch.fixed = true;
                        staticBatches.push(batch);
                    }
            
            staticBatches.fixed = true;
            
            if (flushOldSpriteDataIfPossible) spriteData = null;
            return staticBatches;
        }
        
        public function getMaxSprites():int 
        {
            return maxSprites;
        }
        
        
        
        alternativa3d override function fillResources(resources:Dictionary, hierarchy:Boolean = false, resourceType:Class = null):void {
            if (geometry != null && (resourceType == null || geometry is resourceType)) resources[geometry] = true;
            material.fillResources(resources, resourceType);
            
            super.fillResources(resources, hierarchy, resourceType);
        }
        
        
        private function getTransformProcedure(maxSprites:int):Procedure {
            var key:String = maxSprites + "_" + (maxSprites * NUM_REGISTERS_PER_SPR) + "_z";
            var res:Procedure = _transformProcedures[key];
            if (res != null) return res;
            res = _transformProcedures[key] = new Procedure(null, "Sprite3DSetTransformProcedure");
            res.compileFromArray([
                "mov t2, c[a0.x].xyz",  // origin position in local coordinate space
                
                "sub t0, c3.xyz, t2.xyz",
                "mov t0.z, c1.w",  // #if zAxis
                "nrm t0.xyz, t0",  // look  (no longer needed after cross products)
                
                "crs t1.xyz, c1.xyz, t0.xyz",  // right      // cross product vs perp dot product for z case
                        
                /* #if !zAxis  // (doesn't work to face camera, it seems only axis locking works)
                "crs t0.xyz, t0.xyz, t1.xyz",  // get (non-z) up vector based on  look cross with right
                "mul t0.xyz, t0.xyz, i0.yyy",   // multiple up vector by normalized xyz coodinates
                "mul t0.xyz, t0.xyz, c2.yyy",
                
                "add t2.xyz, t2.xyz, t0.xyz",
                */
                
                "mul t0.xyz, i0.xxx, t1.xyz",   // multiple right vector by normalized xyz coodinates
                "mul t0.xyz, t0.xyz, c2.xxx",   // scale according to spriteset setting (right vector)
                "add t2.xyz, t2.xyz, t0.xyz",
            
                
                ///*  // #if zAxis
                "mul t0.z, c2.y, i0.y",  // scale according to spriteset setting (fixed axis direction)
                "add t2.z, t2.z, t0.z",
                //*/
                
                "mov t2.w, i0.w",    
                "mov o0, t2",
                
                "#a0=joint",
                //"#c0=array",
                "#c1=up",  // up
                "#c2=spriteSet",
                "#c3=cameraPos"
            ]);
        
            res.assignConstantsArray(maxSprites*NUM_REGISTERS_PER_SPR);
        
            return res;
        }
        
        private function getAxisAlignedTransformProcedure(maxSprites:int):Procedure {
            var key:String = maxSprites + "_" + (maxSprites * NUM_REGISTERS_PER_SPR) + "_axis";
            var res:Procedure = _transformProcedures[key];
            if (res != null) return res;
            res = _transformProcedures[key] = new Procedure(null, "Sprite3DSetTransformProcedure");
            res.compileFromArray([
                "mov t2, c[a0.x].xyz",  // origin position in local coordinate space
                
                "sub t0, c3.xyz, t2.xyz",
                //"mov t0.z, c1.w",  // #if zAxis
                "nrm t0.xyz, t0",  // look  (no longer needed after cross products)
                
                "crs t1.xyz, c1.xyz, t0.xyz",  // right      // cross product vs perp dot product for z case
                        
                ///* #if !zAxis  // (doesn't work to face camera, it seems only axis locking works)
                "crs t0.xyz, t0.xyz, t1.xyz",  // get (non-z) up vector based on  look cross with right
                "mul t0.xyz, t0.xyz, i0.yyy",   // multiple up vector by normalized xyz coodinates
                "mul t0.xyz, t0.xyz, c2.yyy",
                
                "add t2.xyz, t2.xyz, t0.xyz",
                //*/
                
                "mul t0.xyz, i0.xxx, t1.xyz",   // multiple right vector by normalized xyz coodinates
                "mul t0.xyz, t0.xyz, c2.xxx",   // scale according to spriteset setting (right vector)
                "add t2.xyz, t2.xyz, t0.xyz",
                
                /*  // #if zAxis
                "mul t0.z, c2.y, i0.y",  // scale according to spriteset setting (fixed axis direction)
                "add t2.z, t2.z, t0.z",
                */
                
                "mov t2.w, i0.w",    
                "mov o0, t2",
                
                "#a0=joint",
                //"#c0=array",
                "#c1=up",  // up
                "#c2=spriteSet",
                "#c3=cameraPos"
            ]);
        
            res.assignConstantsArray(maxSprites*NUM_REGISTERS_PER_SPR);
        
            return res;
        }
        
        private function getViewAlignedTransformProcedure(maxSprites:int):Procedure {
            var key:String = maxSprites + "_" + (maxSprites * NUM_REGISTERS_PER_SPR) + "_view";
            var res:Procedure = _transformProcedures[key];
            if (res != null) return res;
            res = _transformProcedures[key] = new Procedure(null, "Sprite3DSetTransformProcedure");
            
            
            res.compileFromArray([
                "mov t2, c[a0.x].xyz",  // origin position in local coordinate space
                
                "mov t1, t2",  //dummy not needed later change
        
                "mul t0.xyz, c2.xyz, i0.xxx",
                "mul t0.xyz, t0.xyz, c3.xxx", // scale according to spriteset setting (right vector)
                "add t2.xyz, t2.xyz, t0.xyz",
                
                "mul t0.xyz, c1.xyz, i0.yyy",
                "mul t0.xyz, t0.xyz, c3.yyy",  // scale according to spriteset setting  (up vector)
                "add t2.xyz, t2.xyz, t0.xyz",
                
                "mov t2.w, i0.w",    
                "mov o0, t2",
                
                "#a0=joint",
                //"#c0=array",
                "#c1=up", 
                "#c2=right",
                "#c3=spriteSet"
            ]);
        
            res.assignConstantsArray(maxSprites*NUM_REGISTERS_PER_SPR);
        
            return res;
        }
        

    
    
           
    }

//}



//package alternativa.engine3d.spriteset.util 
//{
    import alternativa.engine3d.core.VertexAttributes;
    import alternativa.engine3d.resources.Geometry;
    import flash.utils.ByteArray;
    import flash.utils.Dictionary;
    import flash.utils.Endian;
    import alternativa.engine3d.alternativa3d;
    import flash.utils.getQualifiedClassName;
    use namespace alternativa3d;
    
    /**
     * Utility to help work with Sprite3DSet and your own custom sprite materials!
     * @author Glenn Ko
     */
    //public 
    class SpriteGeometryUtil 
    {
        
        public static const REQUIRE_UVs:uint = 1;
        public static const REQUIRE_NORMAL:uint = 2;
        public static const REQUIRE_TANGENT:uint = 4;
        
        public static const ATTRIBUTE:uint = 20;  // same attribute as used in MeshSet
        
        public static var MATERIAL_REQUIREMENTS:Dictionary = new Dictionary();
        
        public static function guessRequirementsAccordingToMaterial(material:*):int {
            if (MATERIAL_REQUIREMENTS && MATERIAL_REQUIREMENTS[material.constructor]) return MATERIAL_REQUIREMENTS[material.constructor];
            var classeName:String = getQualifiedClassName(material).split("::").pop();
            if (MATERIAL_REQUIREMENTS && MATERIAL_REQUIREMENTS[classeName]) return MATERIAL_REQUIREMENTS[classeName];
            
            switch (classeName) {
                case "Material":
                case "FillMaterial": 
                        return 0;  
                case "TextureMaterial": return ( REQUIRE_UVs );
                case "StandardMaterial": return ( REQUIRE_UVs ); return ( REQUIRE_UVs | REQUIRE_NORMAL | REQUIRE_TANGENT );
                default: return (  REQUIRE_UVs | REQUIRE_NORMAL | REQUIRE_TANGENT );
            }
        }
        
        public static function createNormalizedSpriteGeometry(numSprites:int, indexOffset:int, requirements:uint = 1, scale:Number=1, originX:Number=0, originY:Number=0 ):Geometry 
        {
            var geometry:Geometry = new Geometry();
            var attributes:Array = [];
            var i:int = 0;
            
            originX *= scale;
            originY *= scale;
            
            var indices:Vector.<uint> = new Vector.<uint>();
            var vertices:ByteArray = new ByteArray();
            vertices.endian = Endian.LITTLE_ENDIAN;
            
            var requireUV:Boolean = (requirements & REQUIRE_UVs)!=0;
            var requireNormal:Boolean = (requirements & REQUIRE_NORMAL)!=0;
            var requireTangent:Boolean = (requirements & REQUIRE_TANGENT)!=0;
            
            attributes[i++] = VertexAttributes.POSITION;
            attributes[i++] = VertexAttributes.POSITION;
            attributes[i++] = VertexAttributes.POSITION;
            if ( requireUV) {
                attributes[i++] = VertexAttributes.TEXCOORDS[0];
                attributes[i++] = VertexAttributes.TEXCOORDS[0];
            }
            if (requireNormal) {
                attributes[i++] = VertexAttributes.NORMAL;
                attributes[i++] = VertexAttributes.NORMAL;
                attributes[i++] = VertexAttributes.NORMAL;
            }
            if ( requireTangent) {
                attributes[i++] = VertexAttributes.TANGENT4;
                attributes[i++] = VertexAttributes.TANGENT4;
                attributes[i++] = VertexAttributes.TANGENT4;
                attributes[i++] = VertexAttributes.TANGENT4;
            }
            attributes[i++] = ATTRIBUTE;
            
        
            for (i = 0; i<numSprites;i++) {
                vertices.writeFloat(-1*scale - originX);
                vertices.writeFloat(-1*scale - originY);
                vertices.writeFloat(0);
                if ( requireUV) {
                    vertices.writeFloat(0);
                    vertices.writeFloat(0);
                }
                if ( requireNormal) {
                    vertices.writeFloat(0);
                    vertices.writeFloat(0);
                    vertices.writeFloat(1);
                }
                if ( requireTangent) {
                    vertices.writeFloat(1);
                    vertices.writeFloat(0);
                    vertices.writeFloat(0);
                    vertices.writeFloat(-1);
                }
                vertices.writeFloat(i+indexOffset);
                
                vertices.writeFloat(1*scale - originX);
                vertices.writeFloat(-1*scale - originY);
                vertices.writeFloat(0);
                if ( requireUV) {
                    vertices.writeFloat(1);
                    vertices.writeFloat(0);
                }
                if ( requireNormal) {
                    vertices.writeFloat(0);
                    vertices.writeFloat(0);
                    vertices.writeFloat(1);
                }
                if ( requireTangent) {
                    vertices.writeFloat(1);
                    vertices.writeFloat(0);
                    vertices.writeFloat(0);
                    vertices.writeFloat(-1);
                }
                vertices.writeFloat(i+indexOffset);
                
                vertices.writeFloat(1*scale - originX);
                vertices.writeFloat(1*scale - originY);
                vertices.writeFloat(0);
                if ( requireUV) {
                    vertices.writeFloat(1);
                    vertices.writeFloat(-1);
                }
                if ( requireNormal) {
                    vertices.writeFloat(0);
                    vertices.writeFloat(0);
                    vertices.writeFloat(1);
                }
                if ( requireTangent) {
                    vertices.writeFloat(1);
                    vertices.writeFloat(0);
                    vertices.writeFloat(0);
                    vertices.writeFloat(-1);
                }
                vertices.writeFloat(i+indexOffset);
                
                vertices.writeFloat(-1*scale - originX);
                vertices.writeFloat(1*scale - originY);
                vertices.writeFloat(0);    
                if ( requireUV) {
                    vertices.writeFloat(0);
                    vertices.writeFloat(-1);
                }
                if (requireNormal) {
                    vertices.writeFloat(0);
                    vertices.writeFloat(0);
                    vertices.writeFloat(1);
                }
                if ( requireTangent) {
                    vertices.writeFloat(1);
                    vertices.writeFloat(0);
                    vertices.writeFloat(0);
                    vertices.writeFloat(-1);
                }
                vertices.writeFloat(i+indexOffset);
                
                var baseI:int = i * 4;
                indices.push(baseI, baseI+1, baseI+3,  baseI+1, baseI+2, baseI+3);
            }
            
        
            geometry._indices = indices;
            
            geometry.addVertexStream(attributes);
            geometry._vertexStreams[0].data = vertices;
            geometry._numVertices = numSprites * 4;
            
            
            return geometry;
        }
        
    }

//}


    
    

//package alternativa.engine3d.controller {
    



    /**
     * GeoCameraController は 3D オブジェクトの周りに配置することのできるコントローラークラスです。
     * 緯度・経度で配置することができます。
     *
     * @author narutohyper
     * @author clockmaker
     *
     * @see http://wonderfl.net/c/fwPU
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     */
    
 //  public 
 class OrbitCameraController extends SimpleObjectController
    {

        //----------------------------------------------------------
        //
        //   Static Property 
        //
        //----------------------------------------------------------

        /** 中心と方向へ移動するアクションを示す定数です。 */
        public static const ACTION_FORWARD:String = "actionForward";

        /** 中心と反対方向へ移動するアクションを示す定数です。 */
        public static const ACTION_BACKWARD:String = "actionBackward";

        /** イージングの終了判断に用いるパラメーターです。0〜0.2で設定し、0に近いほどイージングが残されます。 */
        private static const ROUND_VALUE:Number = 0.1;
        
        
        private var _lockRotationZ:Boolean = false;
        private var _mouseWheelHandler:Function;
        

        //----------------------------------------------------------
        //
        //   Constructor 
        //
        //----------------------------------------------------------

        /**
         * 新しい GeoCameraController インスタンスを作成します。
         * @param targetObject    コントローラーで制御したいオブジェクトです。
         * @param mouseDownEventSource    マウスダウンイベントとひもづけるオブジェクトです。
         * @param mouseUpEventSource    マウスアップイベントとひもづけるオブジェクトです。推奨は stage です。
         * @param keyEventSource    キーダウン/キーマップイベントとひもづけるオブジェクトです。推奨は stage です。
         * @param useKeyControl    キーコントロールを使用するか指定します。
         * @param useMouseWheelControl    マウスホイールコントロールを使用するか指定します。
         */
        public function OrbitCameraController(
            targetObject:Camera3D,
            followTarget:Object3D,
            mouseDownEventSource:InteractiveObject,
            mouseUpEventSource:InteractiveObject,
            keyEventSource:InteractiveObject,
            useKeyControl:Boolean = true,
            useMouseWheelControl:Boolean = true, mouseWheelHandler:Function=null
            )
        {
            _target = targetObject;
            _followTarget = followTarget;

            super(mouseDownEventSource, targetObject, 0, 3, mouseSensitivity);
            super.mouseSensitivity = 0;
            super.unbindAll();
            super.accelerate(true);

            this._mouseDownEventSource = mouseDownEventSource;
            this._mouseUpEventSource = mouseUpEventSource;
            this._keyEventSource = keyEventSource;

            _mouseDownEventSource.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
            _mouseUpEventSource.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
    
            // マウスホイール操作
            _mouseWheelHandler = mouseWheelHandler;
            
            if (useMouseWheelControl)
            {
                _mouseDownEventSource.addEventListener(MouseEvent.MOUSE_WHEEL, (_mouseWheelHandler=mouseWheelHandler || this.mouseWheelHandler));
            }

            // キーボード操作
            if (useKeyControl)
            {
                _keyEventSource.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
                _keyEventSource.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
            }
        }
        
        public function reset():void {
            _angleLongitude = 0;
            _lastLongitude = 0;
            _angleLatitude = 0;
        //    _mouseMove = false;
            if (useHandCursor)
                Mouse.cursor = MouseCursor.AUTO;
            
        }

        //----------------------------------------------------------
        //
        //   Property 
        //
        //----------------------------------------------------------

        //--------------------------------------
        // easingSeparator 
        //--------------------------------------

        private var _easingSeparator:Number = 1.5;

        /**
         * イージング時の現在の位置から最後の位置までの分割係数
         * フレームレートと相談して使用
         * 1〜
         * 正の整数のみ。0 を指定しても 1 になります。
         * 1 でイージング無し。数値が高いほど、遅延しぬるぬるします
         */
        public function set easingSeparator(value:uint):void
        {
            if (value)
            {
                _easingSeparator = value;
            }
            else
            {
                _easingSeparator = 1;
            }
        }
        /** Camera から、中心までの最大距離です。デフォルト値は 2000 です。 */
        public var maxDistance:Number = 2000;

        /** Camera から、中心までの最小距離です。デフォルト値は 200 です。 */
        public var minDistance:Number = 200;

        //--------------------------------------
        // mouseSensitivityX 
        //--------------------------------------

        private var _mouseSensitivityX:Number = -1;

        /**
         * マウスの X 方向の感度
         */
        public function set mouseSensitivityX(value:Number):void
        {
            _mouseSensitivityX = value;
        }

        //--------------------------------------
        // mouseSensitivityY 
        //--------------------------------------

        private var _mouseSensitivityY:Number = 1;

        /**
         * マウスの Y 方向の感度
         */
        public function set mouseSensitivityY(value:Number):void
        {
            _mouseSensitivityY = value;
        }

        public var multiplyValue:Number = 10;

        //--------------------------------------
        // needsRendering 
        //--------------------------------------

        private var _needsRendering:Boolean;

        /**
         * レンダリングが必要かどうかを取得します。
         * この値は update() メソッドが呼び出されたタイミングで更新されます。
         *
         * @see GeoCameraController.update
         */
        public function get needsRendering():Boolean
        {
            return _needsRendering;
        }

        //--------------------------------------
        // pitchSpeed 
        //--------------------------------------

        private var _pitchSpeed:Number = 5;

        /**
         * 上下スピード
         * 初期値は5(px)
         */
        public function set pitchSpeed(value:Number):void
        {
            _pitchSpeed = value
        }

        public var useHandCursor:Boolean = true;

        //--------------------------------------
        // yawSpeed 
        //--------------------------------------

        private var _yawSpeed:Number = 5;

        /**
         * 回転スピード
         * 初期値は5(度)
         */
        public function set yawSpeed(value:Number):void
        {
            _yawSpeed = value * Math.PI / 180;
        }

        /**
         * Zoomスピード
         * 初期値は5(px)
         */
        public function set zoomSpeed(value:Number):void
        {
            _distanceSpeed = value;
        }
        
        public function get lockRotationZ():Boolean 
        {
            return _lockRotationZ;
        }
        
        public function set lockRotationZ(value:Boolean):void 
        {
            _lockRotationZ = value;
        }
        
        public function get followTarget():Object3D 
        {
            return _followTarget;
        }
        
        public function get angleLatitude():Number 
        {
            return _angleLatitude;
        }
        
        public function set angleLatitude(value:Number):void 
        {
            _angleLatitude = value;
            _lastLatitude = value;
        }
        
        public function get angleLongitude():Number 
        {
            return _angleLongitude;
        }
        
        public function set angleLongitude(value:Number):void 
        {
            _angleLongitude = value;
            _lastLongitude = value;
        }
        
        public function get minAngleLatitude():Number 
        {
            return _minAngleLatitude;
        }
        
        public function set minAngleLatitude(value:Number):void 
        {
            _minAngleLatitude = value;
        }
        
        public function get maxAngleLatidude():Number 
        {
            return _maxAngleLatidude;
        }
        
        public function set maxAngleLatidude(value:Number):void 
        {
            _maxAngleLatidude = value;
        }
        


        private var _minAngleLatitude:Number = -Number.MAX_VALUE;
        private var _maxAngleLatidude:Number = Number.MAX_VALUE;

        public var _angleLatitude:Number = 0;
        public var _angleLongitude:Number = 0;
        private var _distanceSpeed:Number = 5;
        private var _keyEventSource:InteractiveObject;
        private var _lastLatitude:Number = 0;
        private var _lastLength:Number = 700;
        private var _lastLongitude:Number = _angleLongitude;
        private var _lastLookAtX:Number = _lookAtX;
        private var _lastLookAtY:Number = _lookAtY;
        private var _lastLookAtZ:Number = _lookAtZ;
        private var _length:Number = 700;
        private var _lookAtX:Number = 0;
        private var _lookAtY:Number = 0;
        private var _lookAtZ:Number = 0;
        private var _mouseDownEventSource:InteractiveObject;
        private var _mouseMove:Boolean;
        private var _mouseUpEventSource:InteractiveObject;
        private var _mouseX:Number;
        private var _mouseY:Number;
        private var _oldLatitude:Number;
        private var _oldLongitude:Number;
        private var _pitchDown:Boolean;
        private var _pitchUp:Boolean;
        private var _taregetDistanceValue:Number = 0;
        public var _taregetPitchValue:Number = 0;
        private var _taregetYawValue:Number = 0;
        public var _target:Camera3D
        private var _yawLeft:Boolean;
        private var _yawRight:Boolean;
        private var _zoomIn:Boolean;
        private var _zoomOut:Boolean;
        public var _followTarget:Object3D;

        //----------------------------------------------------------
        //
        //   Function 
        //
        //----------------------------------------------------------

        /**
         * 自動的に適切なキーを割り当てます。
         */
        public function bindBasicKey():void
        {
            bindKey(Keyboard.LEFT, SimpleObjectController.ACTION_YAW_LEFT);
            bindKey(Keyboard.RIGHT, SimpleObjectController.ACTION_YAW_RIGHT);
            bindKey(Keyboard.DOWN, SimpleObjectController.ACTION_PITCH_DOWN);
            bindKey(Keyboard.UP, SimpleObjectController.ACTION_PITCH_UP);
            bindKey(Keyboard.PAGE_UP, OrbitCameraController.ACTION_BACKWARD);
            bindKey(Keyboard.PAGE_DOWN, OrbitCameraController.ACTION_FORWARD);
        }

        /** 上方向に移動します。 */
        public function pitchUp():void
        {
            _taregetPitchValue = _pitchSpeed * multiplyValue;
        }

        /** 下方向に移動します。 */
        public function pitchDown():void
        {
            _taregetPitchValue = _pitchSpeed * -multiplyValue;
        }

        /** 左方向に移動します。 */
        public function yawLeft():void
        {
            _taregetYawValue = _yawSpeed * multiplyValue;
        }

        /** 右方向に移動します。 */
        public function yawRight():void
        {
            _taregetYawValue = _yawSpeed * -multiplyValue;
        }

        /** 中心へ向かって近づきます。 */
        public function moveForeward():void
        {
            _taregetDistanceValue -= _distanceSpeed * multiplyValue;
        }

        /** 中心から遠くに離れます。 */
        public function moveBackward():void
        {
            _taregetDistanceValue += _distanceSpeed * multiplyValue;
        }

        /**
         *　@inheritDoc
         */
        override public function bindKey(keyCode:uint, action:String):void
        {
            switch (action)
            {
                case ACTION_FORWARD:
                    keyBindings[keyCode] = toggleForward;
                    break
                case ACTION_BACKWARD:
                    keyBindings[keyCode] = toggleBackward;
                    break
                case ACTION_YAW_LEFT:
                    keyBindings[keyCode] = toggleYawLeft;
                    break
                case ACTION_YAW_RIGHT:
                    keyBindings[keyCode] = toggleYawRight;
                    break
                case ACTION_PITCH_DOWN:
                    keyBindings[keyCode] = togglePitchDown;
                    break
                case ACTION_PITCH_UP:
                    keyBindings[keyCode] = togglePitchUp;
                    break
            }
            //super.bindKey(keyCode, action)
        }

        /**
         * 下方向に移動し続けるかを設定します。
         * @param value    true の場合は移動が有効になります。
         */
        public function togglePitchDown(value:Boolean):void
        {
            _pitchDown = value
        }

        /**
         * 上方向に移動し続けるかを設定します。
         * @param value    true の場合は移動が有効になります。
         */
        public function togglePitchUp(value:Boolean):void
        {
            _pitchUp = value
        }

        /**
         * 左方向に移動し続けるかを設定します。
         * @param value    true の場合は移動が有効になります。
         */
        public function toggleYawLeft(value:Boolean):void
        {
            _yawLeft = value;
        }

        /**
         * 右方向に移動し続けるかを設定します。
         * @param value    true の場合は移動が有効になります。
         */
        public function toggleYawRight(value:Boolean):void
        {
            _yawRight = value;
        }

        /**
         * 中心方向に移動し続けるかを設定します。
         * @param value    true の場合は移動が有効になります。
         */
        public function toggleForward(value:Boolean):void
        {
            _zoomIn = value;
        }

        /**
         * 中心と反対方向に移動し続けるかを設定します。
         * @param value    true の場合は移動が有効になります。
         */
        public function toggleBackward(value:Boolean):void
        {
            _zoomOut = value;
        }

        private var testLook:Vector3D = new Vector3D();
        /**
         * @inheritDoc
         */
        override public function update():void
        {
            const RADIAN:Number = Math.PI / 180;
            var oldAngleLatitude:Number = _angleLatitude;
            var oldAngleLongitude:Number = _angleLongitude;
            var oldLengh:Number = _lastLength;

            //CameraZoom制御
            if (_zoomIn)
            {
                _lastLength -= _distanceSpeed;
            }
            else if (_zoomOut)
            {
                _lastLength += _distanceSpeed;
            }

            // ズーム制御
            if (_taregetDistanceValue != 0)
            {
                _lastLength += _taregetDistanceValue;
                _taregetDistanceValue = 0;
            }

            if (_lastLength < minDistance)
            {
                _lastLength = minDistance;
            }
            else if (_lastLength > maxDistance)
            {
                _lastLength = maxDistance;
            }
            if (_lastLength - _length)
            {
                _length += (_lastLength - _length) / _easingSeparator;
            }

            if (Math.abs(_lastLength - _length) < ROUND_VALUE)
            {
                _length = _lastLength;
            }

            //Camera回転制御
            if (_mouseMove)
            {
                _lastLongitude = _oldLongitude + (_mouseDownEventSource.mouseX - _mouseX) * _mouseSensitivityX
            }
            else if (_yawLeft)
            {
                _lastLongitude += _yawSpeed;
            }
            else if (_yawRight)
            {
                _lastLongitude -= _yawSpeed;
            }

            if (_taregetYawValue)
            {
                _lastLongitude += _taregetYawValue;
                _taregetYawValue = 0;
            }

            if (_lastLongitude - _angleLongitude)
            {
                _angleLongitude += (_lastLongitude - _angleLongitude) / _easingSeparator;
            }

            if (Math.abs(_lastLatitude - _angleLatitude) < ROUND_VALUE)
            {
                _angleLatitude = _lastLatitude;
            }

            //CameraZ位置制御
            if (_mouseMove)
            {
                _lastLatitude = _oldLatitude + (_mouseDownEventSource.mouseY - _mouseY) * _mouseSensitivityY;
            }
            else if (_pitchDown)
            {
                _lastLatitude -= _pitchSpeed;
            }
            else if (_pitchUp)
            {
                _lastLatitude += _pitchSpeed;
            }

            if (_taregetPitchValue)
            {
                _lastLatitude += _taregetPitchValue;
                _taregetPitchValue = 0;
            }

            _lastLatitude = Math.max(-89.9, Math.min(_lastLatitude, 89.9));

            if (_lastLatitude - _angleLatitude)
            {
                _angleLatitude += (_lastLatitude - _angleLatitude) / _easingSeparator;
            }
            if (Math.abs(_lastLongitude - _angleLongitude) < ROUND_VALUE)
            {
                _angleLongitude = _lastLongitude;
            }
            
            
            if (_angleLatitude < _minAngleLatitude) _angleLatitude = _minAngleLatitude;
            if (_angleLatitude > _maxAngleLatidude) _angleLatitude = _maxAngleLatidude;
            

            var vec3d:Vector3D = this.translateGeoCoords(_angleLatitude, _angleLongitude, _length);
                testLook.x = _followTarget.x;
                testLook.y = _followTarget.y;
                testLook.z = _followTarget.z;
            //    testLook = _followTarget.localToGlobal(testLook);
    
            _target.x = testLook.x + vec3d.x;
            _target.y = testLook.y + vec3d.y;
            _target.z = testLook.z + vec3d.z;

            //lookAt制御
            if (_lastLookAtX - _lookAtX)
            {
                _lookAtX += (_lastLookAtX - _lookAtX) / _easingSeparator;
            }

            if (_lastLookAtY - _lookAtY)
            {
                _lookAtY += (_lastLookAtY - _lookAtY) / _easingSeparator;
            }

            if (_lastLookAtZ - _lookAtZ)
            {
                _lookAtZ += (_lastLookAtZ - _lookAtZ) / _easingSeparator;
            }
            
        

            //super.update()
            updateObjectTransform();
            
            
            
            lookAtXYZ(_lookAtX + testLook.x, _lookAtY + testLook.y, _lookAtZ + testLook.z);
            
    

            _needsRendering = oldAngleLatitude != _angleLatitude
                || oldAngleLongitude != _angleLongitude
                || oldLengh != _length;
        }

        /** @inheritDoc */
        override public function startMouseLook():void
        {
            // 封印
        }

        /** @inheritDoc */
        override public function stopMouseLook():void
        {
            // 封印
        }

        /**
         * Cameraの向く方向を指定します。
         * lookAtやlookAtXYZとの併用は不可。
         * @param x
         * @param y
         * @param z
         * @param immediate    trueで、イージングしないで変更
         */
        public function lookAtPosition(x:Number, y:Number, z:Number, immediate:Boolean = false):void
        {
            if (immediate)
            {
                _lookAtX = x
                _lookAtY = y
                _lookAtZ = z
            }
            _lastLookAtX = x
            _lastLookAtY = y
            _lastLookAtZ = z
        }

        /**
         * 経度を設定します。
         * @param value    0で、正面から中央方向(lookAtPosition)を見る
         * @param immediate    trueで、イージングしないで変更
         */
        public function setLongitude(value:Number, immediate:Boolean = false):void
        {
            if (immediate)
            {
                _angleLongitude = value;
            }
            _lastLongitude = value;
        }

        /**
         * 緯度を設定します。
         * @param value    0で、正面から中央方向(lookAtPosition)を見る
         * @param immediate    trueで、イージングしないで変更
         */
        public function setLatitude(value:Number, immediate:Boolean = false):void
        {
            if (immediate)
            {
                _angleLatitude = value;
            }
            _lastLatitude = value;

        }

        /**
         * Cameraから、targetObjectまでの距離を設定します。
         * @param value    Cameraから、targetObjectまでの距離
         * @param immediate trueで、イージングしないで変更
         */
        public function setDistance(value:Number, immediate:Boolean = false):void
        {
            if (immediate)
            {
                _length = value;
            }
            _lastLength = value;
        }
        
        public function getDistance():Number {
            return _length;
        }

        /**
         * オブジェクトを使用不可にしてメモリを解放します。
         */
        public function dispose():void
        {
            // イベントの解放
            if (_mouseDownEventSource)
                _mouseDownEventSource.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);

            // マウスホイール操作
            if (_mouseDownEventSource)
                _mouseDownEventSource.removeEventListener(MouseEvent.MOUSE_WHEEL, _mouseWheelHandler);

            // キーボード操作
            if (_keyEventSource)
            {
                _keyEventSource.removeEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
                _keyEventSource.removeEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
            }

            // プロパティーの解放
            _easingSeparator = 0;
            maxDistance = 0;
            minDistance = 0;
            _mouseSensitivityX = 0;
            _mouseSensitivityY = 0;
            multiplyValue = 0;
            _needsRendering = false;
            _pitchSpeed = 0;
            useHandCursor = false;
            _yawSpeed = 0;
            _angleLatitude = 0;
            _angleLongitude = 0;
            _distanceSpeed = 0;
            _keyEventSource = null;
            _lastLatitude = 0;
            _lastLength = 0;
            _lastLongitude = 0;
            _lastLookAtX = 0;
            _lastLookAtY = 0;
            _lastLookAtZ = 0;
            _length = 0;
            _lookAtX = 0;
            _lookAtY = 0;
            _lookAtZ = 0;
            _mouseDownEventSource = null;
            _mouseMove = false;
            _mouseUpEventSource = null;
            _mouseX = 0;
            _mouseY = 0;
            _oldLatitude = 0;
            _oldLongitude = 0;
            _pitchDown = false;
            _pitchUp = false;
            _taregetDistanceValue = 0;
            _taregetPitchValue = 0;
            _taregetYawValue = 0;
            _target = null;
            _yawLeft = false;
            _yawRight = false;
            _zoomIn = false;
            _zoomOut = false;
        }

        protected function mouseDownHandler(event:Event):void
        {
            _oldLongitude = _lastLongitude;
            _oldLatitude = _lastLatitude;
            _mouseX = _mouseDownEventSource.mouseX;
            _mouseY = _mouseDownEventSource.mouseY;
            _mouseMove = true;

            if (useHandCursor)
                Mouse.cursor = MouseCursor.HAND;

        
        }

        protected function mouseUpHandler(event:Event):void
        {
            if (!_mouseMove) return;
            
            if (useHandCursor)
                Mouse.cursor = MouseCursor.AUTO;

            _mouseMove = false;
            
        }
        
        

        private function keyDownHandler(event:KeyboardEvent):void
        {
            for (var key:String in keyBindings)
            {
                if (String(event.keyCode) == key)
                {
                    keyBindings[key](true)
                }
            }
        }

        private function keyUpHandler(event:KeyboardEvent = null):void
        {
            for (var key:String in keyBindings)
            {
                keyBindings[key](false)
            }
        }

        private function mouseWheelHandler(event:MouseEvent):void
        {

            _lastLength -= event.delta * 20;
            if (_lastLength < minDistance)
            {
                _lastLength = minDistance
            }
            else if (_lastLength > maxDistance)
            {
                _lastLength = maxDistance
            }
        }

        /**
         * 経度と緯度から位置を算出します。
         * @param latitude    緯度
         * @param longitude    経度
         * @param radius    半径
         * @return 位置情報
         */
        private function translateGeoCoords(latitude:Number, longitude:Number, radius:Number):Vector3D
        {
            const latitudeDegreeOffset:Number = 90;
            const longitudeDegreeOffset:Number = -90;

            latitude = Math.PI * latitude / 180;
            longitude = Math.PI * longitude / 180;

            latitude -= (latitudeDegreeOffset * (Math.PI / 180));
            longitude -= (longitudeDegreeOffset * (Math.PI / 180));

            var x:Number = radius * Math.sin(latitude) * Math.cos(longitude);
            var y:Number = radius * Math.cos(latitude);
            var z:Number = radius * Math.sin(latitude) * Math.sin(longitude);

            return new Vector3D(x, z, y);
        }
    }
//}

//package com.foxarc.images {   
  
    import flash.display.BitmapData;   
    import flash.geom.Rectangle;   
    import flash.utils.ByteArray;          
   // import com.foxarc.util.Base64;   
       
    class BitmapEncoder {   
           
        public static function encodeByteArray(data:BitmapData):ByteArray{   
            if(data == null){   
                throw new Error("data parameter can not be empty!");   
            }   
            var bytes:ByteArray = data.getPixels(data.rect);   
            bytes.writeShort(data.width);   
            bytes.writeShort(data.height);   
            bytes.writeBoolean(data.transparent);   
            bytes.compress();   
            return bytes;   
        }   
        public static function encodeBase64(data:BitmapData):String{   
            return Base64.encodeByteArray(encodeByteArray(data));   
        }   
           
        public static function decodeByteArray(bytes:ByteArray):BitmapData{   
            if(bytes == null){   
                throw new Error("bytes parameter can not be empty!");   
            }   
            bytes.uncompress();   
            if(bytes.length <  6){   
                throw new Error("bytes parameter is a invalid value");   
            }              
            bytes.position = bytes.length - 1;   
            var transparent:Boolean = bytes.readBoolean();   
            bytes.position = bytes.length - 3;   
            var height:int = bytes.readShort();   
            bytes.position = bytes.length - 5;   
            var width:int = bytes.readShort();   
            bytes.position = 0;   
            var datas:ByteArray = new ByteArray();             
            bytes.readBytes(datas,0,bytes.length - 5);   
            var bmp:BitmapData = new BitmapData(width,height,transparent,0);   
            bmp.setPixels(new Rectangle(0,0,width,height),datas);   
            return bmp;   
        }   
           
        public static function decodeBase64(data:String):BitmapData{               
            return decodeByteArray(Base64.decodeToByteArray(data));   
        }          
           
        public function BitmapEncoder() {   
            throw new Error("BitmapEncoder  is a static class!");   
        }   
           
    }   
       
//}   


  import flash.utils.ByteArray;
    
    class Base64 {
        
        private static const BASE64_CHARS:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";

        public static const version:String = "1.1.0";

        public static function encode(data:String):String {
            // Convert string to ByteArray
            var bytes:ByteArray = new ByteArray();
            bytes.writeUTFBytes(data);
            
            // Return encoded ByteArray
            return encodeByteArray(bytes);
        }
        
        public static function encodeByteArray(data:ByteArray):String {
            // Initialise output
            var output:String = "";
            
            // Create data and output buffers
            var dataBuffer:Array;
            var outputBuffer:Array = new Array(4);
            
            // Rewind ByteArray
            data.position = 0;
            
            // while there are still bytes to be processed
            while (data.bytesAvailable > 0) {
                // Create new data buffer and populate next 3 bytes from data
                dataBuffer = new Array();
                for (var i:uint = 0; i < 3 && data.bytesAvailable > 0; i++) {
                    dataBuffer[i] = data.readUnsignedByte();
                }
                
                // Convert to data buffer Base64 character positions and 
                // store in output buffer
                outputBuffer[0] = (dataBuffer[0] & 0xfc) >> 2;
                outputBuffer[1] = ((dataBuffer[0] & 0x03) << 4) | ((dataBuffer[1]) >> 4);
                outputBuffer[2] = ((dataBuffer[1] & 0x0f) << 2) | ((dataBuffer[2]) >> 6);
                outputBuffer[3] = dataBuffer[2] & 0x3f;
                
                // If data buffer was short (i.e not 3 characters) then set
                // end character indexes in data buffer to index of '=' symbol.
                // This is necessary because Base64 data is always a multiple of
                // 4 bytes and is basses with '=' symbols.
                for (var j:uint = dataBuffer.length; j < 3; j++) {
                    outputBuffer[j + 1] = 64;
                }
                
                // Loop through output buffer and add Base64 characters to 
                // encoded data string for each character.
                for (var k:uint = 0; k < outputBuffer.length; k++) {
                    output += BASE64_CHARS.charAt(outputBuffer[k]);
                }
            }
            
            // Return encoded data
            return output;
        }
        
        public static function decode(data:String):String {
            // Decode data to ByteArray
            var bytes:ByteArray = decodeToByteArray(data);
            
            // Convert to string and return
            return bytes.readUTFBytes(bytes.length);
        }
        
        public static function decodeToByteArray(data:String):ByteArray {
            // Initialise output ByteArray for decoded data
            var output:ByteArray = new ByteArray();
            
            // Create data and output buffers
            var dataBuffer:Array = new Array(4);
            var outputBuffer:Array = new Array(3);

            // While there are data bytes left to be processed
            for (var i:uint = 0; i < data.length; i += 4) {
                // Populate data buffer with position of Base64 characters for
                // next 4 bytes from encoded data
                for (var j:uint = 0; j < 4 && i + j < data.length; j++) {
                    dataBuffer[j] = BASE64_CHARS.indexOf(data.charAt(i + j));
                }
                  
                  // Decode data buffer back into bytes
                outputBuffer[0] = (dataBuffer[0] << 2) + ((dataBuffer[1] & 0x30) >> 4);
                outputBuffer[1] = ((dataBuffer[1] & 0x0f) << 4) + ((dataBuffer[2] & 0x3c) >> 2);        
                outputBuffer[2] = ((dataBuffer[2] & 0x03) << 6) + dataBuffer[3];
                
                // Add all non-padded bytes in output buffer to decoded data
                for (var k:uint = 0; k < outputBuffer.length; k++) {
                    if (dataBuffer[k+1] == 64) break;
                    output.writeByte(outputBuffer[k]);
                }
            }
            
            // Rewind decoded data ByteArray
            output.position = 0;
            
            // Return decoded data
            return output;
        }
        
        public function Base64() {
            throw new Error("Base64 class is static container only");
        }
        
    }
    
    
    
class Bmp_Leaf {
    public var str:String = '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';
}

package {
    import alternativ5.engine3d.materials.FillMaterial;

    import alternativ5.engine3d.primitives.Plane;
    import alternativ5.engine3d.primitives.Cone;
    import alternativ5.engine3d.core.Camera3D;
    import alternativ5.engine3d.core.Object3D;
    import alternativ5.engine3d.core.Mesh;
    import alternativ5.engine3d.core.Surface;
    import alternativ5.engine3d.events.MouseEvent3D
    import alternativ5.engine3d.loaders.*;
    import alternativ5.types.Point3D;
    import alternativ5.types.Texture;
    import alternativ5.utils.*

    import flash.system.LoaderContext;
    import flash.display.StageQuality;
    import flash.display.Sprite;
    import flash.display.BlendMode;
    import flash.events.MouseEvent;
    import flash.events.Event;
    import flash.events.ProgressEvent;
    import flash.events.IOErrorEvent;
    import flash.media.Sound;
    import flash.media.SoundChannel;
    import flash.media.SoundTransform;
    import flash.utils.describeType;
    import flash.net.URLRequest;
    
    [SWF(width = 465, height = 465, frameRate = 60,backgroundColor=0xFFE3C8)]
    /**
     * Alternativa3D を簡単に扱うためのベーシックテンプレート
     * @author Yasu (clockmaker)
     */
    public class Main extends Sprite {
        private var test:Number=1
        private var camera:Camera3D
        private var sound:SoundChannel;
        private var soundFactory:Sound = new Sound();
        public function Main():void {
        this.graphics.beginFill(0xFFE3C8);
        this.graphics.drawRect(0,0,465,465);
        
        var url:String = "http://marubayashi.net/archive/sample/secret/chime.mp3";

        var request:URLRequest = new URLRequest(url);
        soundFactory = new Sound();
        soundFactory.addEventListener(Event.COMPLETE, completeHandler);
        soundFactory.load(request);

    }

    private function completeHandler(event:Event):void {
            init()
    }
            
        private function init():void{
            stage.quality = StageQuality.HIGH;
            // テンプレートを作成します
            var template:BasicTemplate = new BasicTemplate();
            template.view.interactive = true;
            camera = template.camera
            camera.y = 5000;
            camera.z = 0;
            camera.zoom=0.15
            camera.orthographic=true
            //camera.fov = 45/180*Math.PI;
            addChild(template);


            var context:LoaderContext = new LoaderContext();
            var loader:LoaderOBJ = new LoaderOBJ();
            loader.addEventListener(Event.COMPLETE, loadCompleteHandler);
            loader.load("http://marubayashi.net/archive/sample/secret/oppai3.obj", context);

            var container:Object3D;
            var oppai:Mesh;
            var body:Mesh;
            var button:Surface;

            function loadCompleteHandler(e:Event):void {

                template.scene.root.addChild(loader.content);
                loader.content.scaleX = loader.content.scaleY = loader.content.scaleZ = 20;

                container = loader.content
                oppai=container.children.toArray()[0]
                //メソッド[Object3D.forEach()]ですべての子Object3Dにアクセスできます

                function test():void {
                    if (this is Mesh) {
                        MeshUtils.removeSingularFaces(Mesh(this));
                        MeshUtils.removeUselessVertices(Mesh(this));
                        MeshUtils.removeIsolatedVertices(Mesh(this));
                        MeshUtils.autoWeldVertices(Mesh(this), 0.01);
                        MeshUtils.autoWeldFaces(Mesh(this), 0.01, 0.001);
                    }
                    //oppai.rotationX=120/180*Math.PI
    
                    //oppai.y=100
                }
                
                button = oppai.surfaces['button'];
                button.addEventListener(MouseEvent3D.CLICK,onClick);
                
                function onClick(e:MouseEvent3D):void {
                    trace('ピンポーン')
                    if (sound) {
                        sound.stop();
                    }
                    sound = soundFactory.play();
                    var transform:SoundTransform = new SoundTransform(1);
                    sound..soundTransform = transform;
                }
                
                
            }


            // Event.ENTER_FRAME 時に実行されるレンダリングのイベントです。
            // レンダリング前に実行したい処理を記述します。
            var angle:Number=0
            template.onPreRender = function():void {
                if (oppai) {

                    var rateX:Number = (stage.stageHeight-(mouseY-2))*0.05+60;
                    var rateZ:Number = (mouseX-(stage.stageWidth-2))*0.1+20;
                    
                    oppai.rotationX += (MathUtils.toRadian(rateX)-oppai.rotationX)*0.1;
                    oppai.rotationZ += (MathUtils.toRadian(rateZ)-oppai.rotationZ)*0.1;
                    // カメラの座標を中央に向かせる
                    template.cameraContoller.lookAt(oppai.coords);
                }


            }
        }






            
        

    }
}



import alternativ5.engine3d.controllers.CameraController;
import alternativ5.engine3d.core.Camera3D;
import alternativ5.engine3d.core.Object3D;
import alternativ5.engine3d.core.Scene3D;
import alternativ5.engine3d.display.View;
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageQuality;
import flash.display.StageScaleMode;
import flash.events.Event;




/**
 * BasicTemplate for Alternativa3D
 * Alternativa3Dを扱いやすくするためのテンプレートです
 * @author Yasu
 */
class BasicTemplate extends Sprite{
    public var scene:Scene3D;
    public var view:View;
    public var camera:Camera3D;
    public var cameraContoller:CameraController;
    
    private var _viewWidth:int;
    private var _viewHeight:int;
    private var _scaleToStage:Boolean;

    public function BasicTemplate(viewWidth:int=640, viewHeight:int=480, scaleToStage:Boolean = true) {
        _viewWidth = viewWidth;
        _viewHeight = viewHeight;
        _scaleToStage = scaleToStage;
        
        // Creating scene
        scene = new Scene3D();
        scene.splitAnalysis = false; // not analysis for performance
        scene.root = new Object3D();
        
        // Adding camera
        camera = new Camera3D();
        camera.y = -1000;
        scene.root.addChild(camera);
        
        // camera contoller
        cameraContoller = new CameraController(this);
        cameraContoller.camera = camera;
        
        // set view
        view = new View();
        view.camera = camera;
        addChild(view);
        
        // stage
        if (stage) init();
        else addEventListener(Event.ADDED_TO_STAGE, init);
    }
    
    protected function atInit():void {}
    
    private var _onInit:Function = function():void { };
    public function get onInit():Function { return _onInit; }
    public function set onInit(value:Function):void {
        _onInit = value;
    }
    
    protected function atPreRender():void {}
    
    private var _onPreRender:Function = function():void{};
    public function get onPreRender():Function { return _onPreRender; }
    public function set onPreRender(value:Function):void {
        _onPreRender = value;
    }
    
    protected function atPostRender():void {
    }
    
    protected var _onPostRender:Function = function():void{};
    public function get onPostRender():Function { return _onPostRender; }
    public function set onPostRender(value:Function):void {
        _onPostRender = value;
    }
    
    public function startRendering():void {
        addEventListener(Event.ENTER_FRAME, onRenderTick);
    }
    public function stopRendering():void {
        removeEventListener(Event.ENTER_FRAME, onRenderTick);
    }
    
    public function singleRender():void {
        onRenderTick();
    }
    
    private function init(e:Event = null):void {
        stage.scaleMode = StageScaleMode.NO_SCALE;
        stage.align = StageAlign.TOP_LEFT;
        stage.quality = StageQuality.HIGH;

        stage.addEventListener(Event.RESIZE, onResize);
        onResize(null);
        
        startRendering();
        
        atInit();
        _onInit();
        
    }
    
    private function onRenderTick(e:Event = null):void {
        atPostRender();
        _onPostRender();
        scene.calculate();
        atPreRender();
        _onPreRender();
    }
    
    private function onResize(event:Event = null):void {
        if (_scaleToStage) {
            view.width = stage.stageWidth;
            view.height = stage.stageHeight;
        }else {
            view.width = _viewWidth;
            view.height = _viewHeight;
        }
    }
}



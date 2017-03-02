// forked from Glidias's Flocking test with 3D models
package
{
   import alternativa.engine3d.animation.AnimationClip;
    import alternativa.engine3d.animation.keys.Track;
    import alternativa.engine3d.core.Object3D;
    import alternativa.engine3d.loaders.ParserA3D;
    import alternativa.engine3d.materials.FillMaterial;
    import alternativa.engine3d.materials.StandardMaterial;
    import alternativa.engine3d.materials.TextureMaterial;
    import alternativa.engine3d.objects.Joint;
    import alternativa.engine3d.objects.Skin;
    import alternativa.engine3d.primitives.Plane;
    import alternativa.engine3d.resources.BitmapTextureResource;
    import com.greensock.events.LoaderEvent;
    import com.greensock.loading.BinaryDataLoader;
    import com.greensock.loading.ImageLoader;
    import com.greensock.loading.LoaderMax;
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Loader;
    import flash.events.IEventDispatcher;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.net.URLRequest;
    import flash.system.ApplicationDomain;
    import flash.system.LoaderContext;
    import flash.system.Security;
    import flash.system.SecurityDomain;
    import flash.text.TextField;
    import flash.ui.Keyboard;
    import flash.utils.ByteArray;
    import flash.utils.Dictionary;




    import flash.display.DisplayObject;    
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.geom.Vector3D;
    
    import alternativa.engine3d.alternativa3d;
    use namespace alternativa3d;

    /**
     * ...
     * @author Glenn Ko
     */
    [SWF(frameRate="60", backgroundColor="0xddddff")]
    public class TestFlocking3D extends MovieClip
    {
        public var engine:Engine;
        public var ticker:FrameTickProvider;
        
        public static const WORLD_SCALE:Number = 2;
        public static const TEST_FLOCKING:Boolean = true;
        public static const G_WORLD_SIZE_MULT:Number = 1;
                
        private  var WORLD_WIDTH:Number = 1200*WORLD_SCALE*G_WORLD_SIZE_MULT;
        private  var WORLD_HEIGHT:Number = 800 * WORLD_SCALE*G_WORLD_SIZE_MULT;
        
        
        
        private static const NUMBOIDS:int = 100   * 3 * G_WORLD_SIZE_MULT;
        static public const MIN_SPEED:Number = 24*WORLD_SCALE;
        static public const MAX_SPEED:Number = 66*WORLD_SCALE;
        static public const TURN_RATIO:Number = 0.9;
        static public const MIN_DIST:Number = 65*WORLD_SCALE;
        static public const SENSE_DIST:Number = 200*WORLD_SCALE;
        static public const DEFAULT_ROT_X:Number = Math.PI * .5; // for boid

        
        private var _skin:Skin;
        private var _animManager:AnimationManager;
        private var rootContainer:Object3D = new Object3D();
        public var myAssets:Assets;
        
        private var loadingField:TextField;
        
        
        public function TestFlocking3D() 
        {
            super();
             Wonderfl.disable_capture();
             

             
            
            ReflectUtil.registerComponents([Pos,Rot,Vel,Flocking,Object3D,IAnimatable]);
            
            
            myAssets = new Assets();
            if (myAssets.MECH_SKIN != null) {
                init();
            }
            else {
                
                
            //    myAssets.addEventListener(Event.COMPLETE, init);
            
                var domain:SecurityDomain = loaderInfo.url.indexOf("file://") >= 0 ? null : SecurityDomain.currentDomain;
                if (domain != null) {
                    Security.loadPolicyFile("http://glidias.github.io/crossdomain.xml");    
                
                }
                
                myAssets.addEventListener(Event.COMPLETE, loadQueueComplete);
                 myAssets.load("http://glidias.github.io/Asharena/assets/skins/mech/bundle.swf", "tests.flocking", new LoaderContext(true, null, domain));
             
                
                loadingField = new TextField();
                
                addChild(loadingField);
              //  loadingField.text = "LOADING...";
                /*
                 LoaderMax.defaultContext = new LoaderContext(true, null, domain);
                var loadQueue:LoaderMax = new LoaderMax();
                
                loadQueue.addEventListener(LoaderEvent.SECURITY_ERROR, onError);
                loadQueue.addEventListener(LoaderEvent.ERROR, onError);
                loadQueue.addEventListener(LoaderEvent.IO_ERROR, onError);
               loadQueue.addEventListener(LoaderEvent.COMPLETE, loadQueueComplete);
                loadQueue.append( new BinaryDataLoader("http://glidias.github.io/Asharena/assets/skins/gladiator/animations.ani", {  name:"anim" } ));
                loadQueue.append( skinbmpLoader=new ImageLoader("http://glidias.github.io/Asharena/assets/skins/gladiator/samnite/samnite_skin.png",{ name:"skinbmp" } ));
                loadQueue.append( new BinaryDataLoader("http://glidias.github.io/Asharena/assets/skins/gladiator/samnite/samnite_lowpolyanim.a3d", {  name:"skin" } ));
                loadQueue.load();
            //    */
                

            }
            
        }
        
        private function onError(e:LoaderEvent):void 
        {
            throw new Error(e + ", "+e.data);
        }
        
        
        
        private function loadTest():void {
            var loader:Loader = new Loader();
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete);
            loader.load( new URLRequest("http://glidias.github.io/Asharena/assets/skins/gladiator/samnite/samnite_skin.png"), LoaderMax.defaultContext);
            // new ImageLoader("http://glidias.github.io/Asharena/assets/skins/gladiator/samnite/samnite_skin.png", { name:"skinbmp", onComplete:function(e:Event):void { throw new Error("LOAD DOE:"+e.target.rawContent.content);  }  } ).load();
        
            
        }
        
        private function onLoadComplete(e:Event):void 
        {
            throw new Error(e.currentTarget.content);
        }
        
        private function loadQueueComplete(e:Event):void 
        {
            removeChild(loadingField);
            //loadTest();

            init();
    //        onReady3D( null, LoaderMax.getLoader("skin").content,  LoaderMax.getLoader("skinbmp").rawContent.bitmapData,  LoaderMax.getLoader("anim").content);
            
        }
        
        
        
        
        
        private function init(e:Event=null):void {
            
            engine = new Engine();
            
            if (TEST_FLOCKING) engine.addSystem( new FlockingSystem(), 0 );
            engine.addSystem( new AnimationSystem(), 1 );
            //engine.addSystem( new DisplayObjectRenderingSystem(this), 1);
            
            ticker = new FrameTickProvider(stage);
            ticker.add(tick);
            
            stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
            
            MechStance.RANGE = 1 / MAX_SPEED;
            addChild( _template3d = new Template());
            _template3d.settings.cameraSpeed *= 4;
            _template3d.settings.viewBackgroundColor = 0xBBBBBB;
            _template3d.settings.cameraSpeedMultiplier *= 2;
             _template3d.addEventListener(Template.VIEW_CREATE, onReady3D);
    
        
        }
        
    
        private var _template3d:Template;
        private function onReady3D(e:Event, skinData:ByteArray=null, skinBmpData:BitmapData=null, animData:ByteArray=null):void 
        {
                    
            if (e != null) (e.currentTarget as IEventDispatcher).removeEventListener(e.type, onReady3D);
            
            if (loadingField) {
                if (LoaderMax.getLoader("skin")) {
                    skinData = LoaderMax.getLoader("skin").content;
                    var skinBmpDataRawContent:* = skinbmpLoader.rawContent;
                    if (skinBmpDataRawContent == null) throw new Error("Failed to load skinbmp:"+LoaderMax.getLoader("skinbmp") + ", "+skinData + ", "+animData );
                    skinBmpData = skinBmpDataRawContent.bitmapData;
                    animData = LoaderMax.getLoader("anim").content
                }
            }
            
            engine.addSystem( new RenderingSystem(rootContainer), 2 );
            
            
            var child:Object3D = _template3d.scene.addChild( new Plane( 1e4, 1e4, 1, 1, false, false, null, new FillMaterial(0x445544, 1) ) );
            child.x += WORLD_WIDTH * .5;
            child.y += WORLD_HEIGHT * .5;
            child.z -= 72*.5;
            //rootContainer.rotationZ = Math.PI;
          
            var parser:ParserA3D = new ParserA3D();
            parser.parse(skinData || new myAssets.MECH_KAYRATH());
            var skin:Skin = findSkin(parser.objects);
            skin.divide(1000);
        //    skin.calculateBindingMatrices();
            //throw new Error(skin.surfaceJoints.length + "::: " + skin.surfaceJoints[0].length);
            skin.renderedJoints = skin.surfaceJoints[0];
            
        
            
        
            var standardMaterial:StandardMaterial = new StandardMaterial( new BitmapTextureResource(skinBmpData || (new myAssets.MECH_SKIN().bitmapData)), _template3d.normalResource);
            skin.geometry.calculateNormals();
            skin.geometry.calculateTangents(0);
            skin.rotationX = Math.PI * .5;
            skin.rotationZ = Math.PI*.5;
            
            standardMaterial.specularPower = 0;
            skin.boundBox = null;
            skin.setMaterialToAllSurfaces(standardMaterial);
            //_template3d.scene.addChild(skin); 
            _skin = skin;
            
            
            
            skinClonesCont = new SkinClonesContainer(skin, 0, SkinClone);
            rootContainer.addChild(skinClonesCont);
            
            _animManager = new AnimationManager();
            
            var animBytes:ByteArray =  animData || new myAssets.MECH_ANIMS();
            animBytes.uncompress();
            _animManager.readExternal(animBytes );
            
            postProcessAnimManager();
            
            _template3d.cameraController.setObjectPos(new Vector3D(WORLD_WIDTH * .5, WORLD_HEIGHT * .5, 100));
            //_template3d.camera.transformChanged = true;
            //_template3d.cameraController.update();
            //throw new Error(_animManager.animClips[0].name);
            
            _template3d.scene.addChild(rootContainer);
            _template3d.uploadResources(_template3d.scene.getResources(true));
            _template3d.uploadResources(skin.getResources());
            
            
            startGame();
            
        }
        
        private function postProcessAnimManager():void {
            /*
            var len:int = _animManager.animClips.length;
            for (var i:int = 0; i < len; i++) {
                removeAnimationTrack(_animManager, _animManager.animClips[i].name ,"Bip01");
            }
            */
            removeAnimationTrack(_animManager, "jog" ,"Bip01");
            //
        }
        private function removeAnimationTrack(animManager:AnimationManager, animName:String, boneName:String):void 
        {
            var anim:AnimationClip = animManager.getAnimationByName(animName);
            
            var len:int = anim.numTracks;
            for (var i:int = 0; i < len ; i++) {
                var t:Track = anim.getTrackAt(i);
                if (t.object === boneName) {
                    anim.removeTrack(t);
                    
                    return;
                }
            }
            
        }
        
        private function startGame():void 
        {
            createBoids();
            ticker.start();
        }
        private function findSkin(objects:Vector.<Object3D>):Skin {
            for each(var obj:Object3D in objects) {
                if (obj is Skin) return obj as Skin;
            }
            throw new Error("Could not find skin:");
            return null;
        }
        
        
        private var playing:Boolean = true;
        
        private function onKeyDown(e:KeyboardEvent):void 
        {
            var kc:uint = e.keyCode;
            if (kc === Keyboard.P) {
                playing = !playing;
                if (playing) ticker.start()
                else ticker.stop();
            }
            else if (kc === Keyboard.F6) {
                _template3d.takeScreenshot(screenieMethod);
            }
            else if (kc === Keyboard.F7) {
                _scrnie=_template3d.takeScreenshot(screenieMethod2);
            }
        }
        
          private function screenieMethod():Boolean 
        {
            Wonderfl.capture(); //
            return true;
        
        }
        
         private function screenieMethod2():Boolean 
        {
            stage.addEventListener(MouseEvent.CLICK, removeScreenie);
            return false;
        }
        private var _scrnie:Bitmap;
        private var skinClonesCont:SkinClonesContainer;
        private var skinbmpLoader:ImageLoader;
          private function removeScreenie(e:Event=null):void {
            if (_scrnie == null) return;
            stage.removeEventListener(MouseEvent.CLICK, removeScreenie);
            _scrnie.parent.removeChild(_scrnie);
            _scrnie = null;
        }
        
        
        private function tick(time:Number):void 
        {
            engine.update(time);
            
            _template3d.cameraController.update();
            _template3d.camera.render(_template3d.stage3D); // onRenderTick();
        }
        
        
        private function createBoids():void 
        {
            
             var tmp:Number = 2.0 * Math.PI / NUMBOIDS;
             
                var tmpw:int = WORLD_WIDTH / 2 , tmph:int = WORLD_HEIGHT / 2;
                var flockSettings:FlockSettings = Flocking.createFlockSettings(MIN_DIST,SENSE_DIST,0,0,tmpw*2, tmph*2, MIN_SPEED, MAX_SPEED, TURN_RATIO);
              
            for (var i:int = 0; i < NUMBOIDS; ++i) {
                 const ph:Number = i * tmp;
                var pos:Pos = new Pos(  tmpw + ((i % 4) * 0.2 + 0.3) * tmpw * Math.cos(ph), tmph + ((i % 4) * 0.2 + 0.3) * tmph * Math.sin(ph));
                
                
                var vel:Vel = new Vel( ((i%4)*(-4) + 16) * Math.cos(ph + Math.PI / 6 * (1+i%4) * (Math.random() - 0.5)),  ((i%4)*(-4) + 16) * Math.sin(ph + Math.PI / 6 * (1+i%4) * (Math.random() - 0.5)));
                
                var rot:Rot = new Rot(0, 0, Math.random() * 2 * Math.PI);
                

                
                var entity:Entity = new Entity().add(pos).add(rot).add(vel).add( new Flocking().setup(flockSettings )) ;
                
                //entity.add( new BoidGraphic(), DisplayObject);
                ///*
                var obj:Object3D;// = new Object3D();
                var skinClone:SkinClone  =  skinClonesCont.createClone();
                var skin:Object3D =skinClone.root ;// _skin.clone() as Skin;
                //obj.addChild(skin);
                obj = skin;
                
                skinClonesCont.addClone(skinClone);
                entity.add( new MechStance( _animManager.cloneFor(skin.childrenList), vel, skinClone.renderedJoints, !TEST_FLOCKING ), IAnimatable).add(obj, Object3D);
                //*/
                
                /*
                var obj:Object3D= new Object3D();
                var skin:Object3D =_skin.clone() as Skin;
                obj.addChild(skin);
                
                
            
                
                //obj = skin;
                rootContainer.addChild(obj);

                entity.add( new MechStance( _animManager.cloneFor(skin), vel, (skin as Skin).renderedJoints ), IAnimatable).add(obj, Object3D);
                */
                
                engine.addEntity(entity);
            }
        }
        
        
        
    
    }
        

}



    /**
     * ...
     * @author Glenn Ko
     */
    
    import alternativa.engine3d.alternativa3d;
    import alternativa.engine3d.primitives.GeoSphere;
    import alternativa.engine3d.controllers.SimpleObjectController;
    import alternativa.engine3d.core.Camera3D;
    import alternativa.engine3d.core.Object3D;
    import alternativa.engine3d.core.Resource;
    import alternativa.engine3d.core.View;
    import alternativa.engine3d.core.VertexAttributes;
    import alternativa.engine3d.core.Transform3D;
    import alternativa.engine3d.resources.BitmapTextureResource;
    import flash.display.Bitmap;
    import flash.display.BitmapData;

    import alternativa.engine3d.objects.Mesh;
    import alternativa.engine3d.objects.Surface;
    import alternativa.engine3d.objects.Joint;
    import alternativa.engine3d.lights.AmbientLight;
    import alternativa.engine3d.lights.DirectionalLight;
    import alternativa.engine3d.resources.Geometry;
    import flash.display.Sprite;
    import flash.display.Stage3D;
    import flash.display.StageAlign;
    import flash.display.StageQuality;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.utils.Dictionary;
    import flash.geom.Vector3D;
    import flash.utils.Dictionary;
    import flash.geom.*;


    class Template extends Sprite {
        public static const VIEW_CREATE:String = 'view_create'
        
        public var stage3D:Stage3D
        public var camera:Camera3D
        public var scene:Object3D
        public var cameraController:SimpleObjectController;
        public var objectController:SimpleObjectController;
        public var controlObject:Object3D;
        
        protected var directionalLight:DirectionalLight;
        protected var ambientLight:AmbientLight;   
        
        public var bitmapResource:BitmapTextureResource;
        public var normalResource:BitmapTextureResource;
        
        public var settings:TemplateSettings = new TemplateSettings();
        public var renderId:int = 0;
        
        public function Template() {
            
            
            addEventListener(Event.ADDED_TO_STAGE, init);
        }
        
        protected function init(e:Event = null):void 
        {
             var diffuseMap:BitmapData = new BitmapData(16, 16, false, 0xFF6666);
            var normalMap:BitmapData = new BitmapData(16, 16, false, 0x8080FF);

            bitmapResource = new BitmapTextureResource(diffuseMap);
            normalResource = new BitmapTextureResource(normalMap);
            
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
        
            public function takeScreenshot( method:Function=null) : Bitmap  //width:int, height:int,
     {
          var view:View = camera.view;

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
            addChild(camera.diagram);
            camera.view.backgroundColor  = settings.viewBackgroundColor;
            
            //Cameraをコントロールする場合は、CameraControlerの作成
            cameraController = new SimpleObjectController(stage, camera, settings.cameraSpeed, settings.cameraSpeedMultiplier, settings.cameraSensitivity);
            //cameraController.mouseSensitivity = 0;
            //cameraController.unbindAll();
        
            
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
            
            
            stage.addEventListener(Event.RESIZE, onStageResize);
            
            
        }
        
        private function onStageResize(e:Event):void 
        {
            camera.view.width = stage.stageWidth;
            camera.view.height = stage.stageHeight;
        }
        
        public function startRendering():void {
            uploadResources ( scene.getResources(true) );
            
            //オブジェクト用のコントローラー（マウス操作）
            objectController = new SimpleObjectController(stage, controlObject, 100);
            objectController.mouseSensitivity = 0.2;
         
            //レンダリング
            camera.render(stage3D);
            
            
            addEventListener(Event.ENTER_FRAME, onRenderTick);
        }
        
        public function uploadResources(vec:Vector.<Resource>):void {
             for each (var resource:Resource in vec) {
                //trace(resource)
                resource.upload(stage3D.context3D);
            }
        }
        
        


        
        public function onRenderTick(e:Event):void {
            cameraController.update()
            camera.render(stage3D);
        
        }
    }




class TemplateSettings {
    public var cameraSpeedMultiplier:Number = 3;
    public var cameraSpeed:Number = 100;
    public var cameraSensitivity:Number = 1;
    public var viewBackgroundColor:uint;
    public function TemplateSettings() {
        
    }
    
}



import flash.display.Loader;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import flash.system.LoaderContext;
import flash.utils.describeType;
import flash.utils.getDefinitionByName;

    /**
     * ...
     * @author Glenn Ko
     */
    class Assets extends Sprite
    {
        //[Embed(source = "../../../bin/skins/mech/animations.ani", mimeType = "application/octet-stream")]
        public var MECH_ANIMS:Class;
        
        //[Embed(source = "../../../bin/skins/mech/mech_kayrath.a3d", mimeType = "application/octet-stream")]
        public var MECH_KAYRATH:Class;
        
        //[Embed(source = "../../../bin/skins/mech/skin.jpg")]
        public var MECH_SKIN:Class;
        
        public function Assets() 
        {
            
        }
        
        private var _loader:ClassLoader; 
        private var packagePrefix:String;
        
        public function load(url:String, packagePath:String, context:LoaderContext):void {
            _loader = new ClassLoader();
            if (packagePath != "") {
                packagePrefix = packagePath+ "::";
            }
            else packagePrefix = null;
            _loader.addEventListener(ClassLoader.CLASS_LOADED, onLoadComplete);
            _loader.load(url, context);
        }
        
        private function onLoadComplete(e:Event):void {
            (e.currentTarget as IEventDispatcher).removeEventListener(e.type, onLoadComplete);
            
            var me:Object = Object(this);
            var variables : XMLList = describeType( me.constructor ).factory.variable;

            var classe:Class = _loader.getClass( packagePrefix + "Assets");
            var refer:Object = new classe();
            
              for each ( var atom:XML in variables )
                {        
                    var componentClass : Class = refer[atom.@name.toString()];            
                    me[atom.@name.toString()] = componentClass;
                    
                }

                dispatchEvent( new Event(Event.COMPLETE));
            }
        }
    



// written by @9re
// MIT License, see http://www.opensource.org/licenses/mit-license.php

    import flash.display.Loader;
    import flash.errors.IllegalOperationError;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IOErrorEvent;
    import flash.events.ProgressEvent;
    import flash.events.SecurityErrorEvent;
    import flash.net.URLRequest;
    import flash.system.ApplicationDomain;
    import flash.system.LoaderContext;

    class ClassLoader extends EventDispatcher {
        public static var CLASS_LOADED:String = "classLoaded";
        public static var LOAD_ERROR:String = "loadError";
        private var loader:Loader;
        private var swfLib:String;
        private var request:URLRequest;
        private var loadedClass:Class;
        
        public function ClassLoader() {
            loader = new Loader();
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler);
            loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
            loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
        }
        
        public function load(lib:String, context:LoaderContext):void {
            swfLib = lib;
            request = new URLRequest(swfLib);
            loader.load(request, context);
        }
            
        public function getClass(className:String):Class {
            try {
                var c:Class = loader.contentLoaderInfo.applicationDomain.getDefinition(className) as Class;
                return c;
            }
            catch(e:Error) {
                throw new IllegalOperationError(e + className + " definition not found in " + swfLib);
            }
            return null;
        }
        
        private function completeHandler(e:Event):void {
            dispatchEvent(new Event(ClassLoader.CLASS_LOADED));
        }
        
        private function ioErrorHandler(e:Event):void {
            dispatchEvent(new Event(ClassLoader.LOAD_ERROR));
        }
        
        private function securityErrorHandler(e:Event):void {
            dispatchEvent(new Event(ClassLoader.LOAD_ERROR));
        }

    }



    
    
    
    
    
    
//}//package {
    //import Engine;
    //import Node;
    //import NodeList;
    //import System;

    //}
//package {
    //import ash.signals.Signal2;

    import flash.utils.Dictionary;
    import flash.utils.getQualifiedClassName;

    
    /*public*/ class Entity
    {
        private static var nameCount : int = 0;
        
        
        private var _name : String;
        
        public var componentAdded : Signal2;
        
        public var componentRemoved : Signal2;
        
        public var nameChanged : Signal2;
        
        public var previous : Entity;
        public var next : Entity;
        public var components : Dictionary;

        
        public function Entity( name : String = "" )
        {
            componentAdded = new Signal2( Entity, Class );
            componentRemoved = new Signal2( Entity, Class );
            nameChanged = new Signal2( Entity, String );
            components = new Dictionary();
            if( name )
            {
                _name = name;
            }
            else
            {
                _name = "_entity" + (++nameCount);
            }
        }
        
        
        public function get name() : String
        {
            return _name;
        }
        public function set name( value : String ) : void
        {
            if( _name != value )
            {
                var previous : String = _name;
                _name = value;
                nameChanged.dispatch( this, previous );
            }
        }

        
        public function add( component : Object, componentClass : Class = null ) : Entity
        {
            if ( !componentClass )
            {
                componentClass = Class( component.constructor );
            }
            if ( components[ componentClass ] )
            {
                remove( componentClass );
            }
            components[ componentClass ] = component;
            componentAdded.dispatch( this, componentClass );
            return this;
        }

        
        public function remove( componentClass : Class ) : *
        {
            var component : * = components[ componentClass ];
            if ( component )
            {
                delete components[ componentClass ];
                componentRemoved.dispatch( this, componentClass );
                return component;
            }
            return null;
        }

        
        public function get( componentClass : Class ) : *
        {
            return components[ componentClass ];
        }
        
        
        public function getAll() : Array
        {
            var componentArray : Array = new Array();
            for each( var component : * in components )
            {
                componentArray.push( component );
            }
            return componentArray;
        }

        
        public function has( componentClass : Class ) : Boolean
        {
            return components[ componentClass ] != null;
        }
    }
//}
//package {
    
    /*public*/ class System
    {
        
        public var previous : System;
        
        public var next : System;
        
        public var priority : int = 0;
        
        
        public function addToEngine( engine : Engine ) : void
        {
            
        }
        
        
        public function removeFromEngine( engine : Engine ) : void
        {
            
        }
        
        
        public function update( time : Number ) : void
        {
            
        }
    }
//}
//package {
    
    /*public*/ class Node
    {
        
        public var entity : Entity;
        
        
        public var previous : *;
        
        
        public var next : *;
    }
//}



//}


    class ListenerNodePool
    {
        private var tail : ListenerNode;
        private var cacheTail : ListenerNode;
        
        public function get():ListenerNode
        {
            if( tail )
            {
                var node : ListenerNode = tail;
                tail = tail.previous;
                node.previous = null;
                return node;
            }
            else
            {
                return new ListenerNode();
            }
        }

        public function dispose( node : ListenerNode ):void
        {
            node.listener = null;
            node.once = false;
            node.next = null;
            node.previous = tail;
            tail = node;
        }
        
        public function cache( node : ListenerNode ) : void
        {
            node.listener = null;
            node.previous = cacheTail;
            cacheTail = node;
        }
        
        public function releaseCache() : void
        {
            while( cacheTail )
            {
                var node : ListenerNode = cacheTail;
                cacheTail = node.previous;
                node.next = null;
                node.previous = tail;
                tail = node;
            }
        }
    }





    class ListenerNode
    {
        public var previous : ListenerNode;
        public var next : ListenerNode;
        public var listener : Function;
        public var once : Boolean;
    }

    
    
    /*public*/ class ListIteratingSystem extends System
    {
        protected var nodeList : NodeList;
        protected var nodeClass : Class;
        protected var nodeUpdateFunction : Function;
        protected var nodeAddedFunction : Function;
        protected var nodeRemovedFunction : Function;
        
        public function ListIteratingSystem( nodeClass : Class, nodeUpdateFunction : Function, nodeAddedFunction : Function = null, nodeRemovedFunction : Function = null )
        {
            this.nodeClass = nodeClass;
            this.nodeUpdateFunction = nodeUpdateFunction;
            this.nodeAddedFunction = nodeAddedFunction;
            this.nodeRemovedFunction = nodeRemovedFunction;
        }
        
        override public function addToEngine( engine : Engine ) : void
        {
            nodeList = engine.getNodeList( nodeClass );
            if( nodeAddedFunction != null )
            {
                for( var node : Node = nodeList.head; node; node = node.next )
                {
                    nodeAddedFunction( node );
                }
                nodeList.nodeAdded.add( nodeAddedFunction );
            }
            if( nodeRemovedFunction != null )
            {
                nodeList.nodeRemoved.add( nodeRemovedFunction );
            }
        }
        
        override public function removeFromEngine( engine : Engine ) : void
        {
            if( nodeAddedFunction != null )
            {
                nodeList.nodeAdded.remove( nodeAddedFunction );
            }
            if( nodeRemovedFunction != null )
            {
                nodeList.nodeRemoved.remove( nodeRemovedFunction );
            }
            nodeList = null;
        }
        
        override public function update( time : Number ) : void
        {
            for( var node : Node = nodeList.head; node; node = node.next )
            {
                nodeUpdateFunction( node, time );
            }
        }
    }
//}
//package {
    //import ash.signals.Signal1;
    
    
    /*public*/ class NodeList
    {
        
        public var head : *;
        
        public var tail : *;
        
        
        public var nodeAdded : Signal1;
        
        public var nodeRemoved : Signal1;
        
        public function NodeList()
        {
            nodeAdded = new Signal1( Node );
            nodeRemoved = new Signal1( Node );
        }
        
        public function add( node : Node ) : void
        {
            if( ! head )
            {
                head = tail = node;
                node.next = node.previous = null;
            }
            else
            {
                tail.next = node;
                node.previous = tail;
                node.next = null;
                tail = node;
            }
            nodeAdded.dispatch( node );
        }
        
        public function remove( node : Node ) : void
        {
            if ( head == node)
            {
                head = head.next;
            }
            if ( tail == node)
            {
                tail = tail.previous;
            }
            
            if (node.previous)
            {
                node.previous.next = node.next;
            }
            
            if (node.next)
            {
                node.next.previous = node.previous;
            }
            nodeRemoved.dispatch( node );
            
        }
        
        public function removeAll() : void
        {
            while( head )
            {
                var node : Node = head;
                head = node.next;
                node.previous = null;
                node.next = null;
                nodeRemoved.dispatch( node );
            }
            tail = null;
        }
        
        
        public function get empty() : Boolean
        {
            return head == null;
        }
        
        
        public function swap( node1 : Node, node2 : Node ) : void
        {
            if( node1.previous == node2 )
            {
                node1.previous = node2.previous;
                node2.previous = node1;
                node2.next = node1.next;
                node1.next  = node2;
            }
            else if( node2.previous == node1 )
            {
                node2.previous = node1.previous;
                node1.previous = node2;
                node1.next = node2.next;
                node2.next  = node1;
            }
            else
            {
                var temp : Node = node1.previous;
                node1.previous = node2.previous;
                node2.previous = temp;
                temp = node1.next;
                node1.next = node2.next;
                node2.next = temp;
            }
            if( head == node1 )
            {
                head = node2;
            }
            else if( head == node2 )
            {
                head = node1;
            }
            if( tail == node1 )
            {
                tail = node2;
            }
            else if( tail == node2 )
            {
                tail = node1;
            }
            if( node1.previous )
            {                            
                node1.previous.next = node1;
            }
            if( node2.previous )
            {
                node2.previous.next = node2;
            }
            if( node1.next )
            {
                node1.next.previous = node1;
            }
            if( node2.next )
            {
                node2.next.previous = node2;
            }
        }
        
        
        public function insertionSort( sortFunction : Function ) : void
        {
            if( head == tail )
            {
                return;
            }
            var remains : Node = head.next;
            for( var node : Node = remains; node; node = remains )
            {
                remains = node.next;
                for( var other : Node = node.previous; other; other = other.previous )
                {
                    if( sortFunction( node, other ) >= 0 )
                    {
                        
                        if( node != other.next )
                        {
                            
                            if ( tail == node)
                            {
                                tail = node.previous;
                            }
                            node.previous.next = node.next;
                            if (node.next)
                            {
                                node.next.previous = node.previous;
                            }
                            
                            node.next = other.next;
                            node.previous = other;
                            node.next.previous = node;
                            other.next = node;
                        }
                        break; 
                    }
                }
                if( !other ) 
                {
                    
                    if ( tail == node)
                    {
                        tail = node.previous;
                    }
                    node.previous.next = node.next;
                    if (node.next)
                    {
                        node.next.previous = node.previous;
                    }
                    
                    node.next = head;
                    head.previous = node;
                    node.previous = null;
                    head = node;
                }
            }
        }
        
        
        public function mergeSort( sortFunction : Function ) : void
        {
            if( head == tail )
            {
                return;
            }
            var lists : Vector.<Node> = new Vector.<Node>;
            
            var start : Node = head;
            var end : Node;
            while( start )
            {
                end = start;
                while( end.next && sortFunction( end, end.next ) <= 0 )
                {
                    end = end.next;
                }
                var next : Node = end.next;
                start.previous = end.next = null;
                lists.push( start );
                start = next;
            }
            
            while( lists.length > 1 )
            {
                lists.push( merge( lists.shift(), lists.shift(), sortFunction ) );
            }
            
            tail = head = lists[0];
            while( tail.next )
            {
                tail = tail.next;    
            }
        }
        
        private function merge( head1 : Node, head2 : Node, sortFunction : Function ) : Node
        {
            var node : Node;
            var head : Node;
            if( sortFunction( head1, head2 ) <= 0 )
            {
                head = node = head1;
                head1 = head1.next;
            }
            else
            {
                head = node = head2;
                head2 = head2.next;
            }
            while( head1 && head2 )
            {
                if( sortFunction( head1, head2 ) <= 0 )
                {
                    node.next = head1;
                    head1.previous = node;
                    node = head1;
                    head1 = head1.next;
                }
                else
                {
                    node.next = head2;
                    head2.previous = node;
                    node = head2;
                    head2 = head2.next;
                }
            }
            if( head1 )
            {
                node.next = head1;
                head1.previous = node;
            }
            else
            {
                node.next = head2;
                head2.previous = node;
            }
            return head;
        }
    }
//}



//package {
    import flash.utils.Dictionary;

    
    /*public*/ class SignalBase
    {
        public var head : ListenerNode;
        public var tail : ListenerNode;
        
        private var nodes : Dictionary;
        private var listenerNodePool : ListenerNodePool;
        private var toAddHead : ListenerNode;
        private var toAddTail : ListenerNode;
        private var dispatching : Boolean;
        private var _numListeners : int = 0;

        public function SignalBase()
        {
            nodes = new Dictionary( true );
            listenerNodePool = new ListenerNodePool();
        }
        
        protected function startDispatch() : void
        {
            dispatching = true;
        }
        
        protected function endDispatch() : void
        {
            dispatching = false;
            if( toAddHead )
            {
                if( !head )
                {
                    head = toAddHead;
                    tail = toAddTail;
                }
                else
                {
                    tail.next = toAddHead;
                    toAddHead.previous = tail;
                    tail = toAddTail;
                }
                toAddHead = null;
                toAddTail = null;
            }
            listenerNodePool.releaseCache();
        }
        
        public function get numListeners() : int
        {
            return _numListeners;
        }

        public function add( listener : Function ) : void
        {
            if( nodes[ listener ] )
            {
                return;
            }
            var node : ListenerNode = listenerNodePool.get();
            node.listener = listener;
            nodes[ listener ] = node;
            addNode( node );
        }
        
        public function addOnce( listener : Function ) : void
        {
            if( nodes[ listener ] )
            {
                return;
            }
            var node : ListenerNode = listenerNodePool.get();
            node.listener = listener;
            node.once = true;
            nodes[ listener ] = node;
            addNode( node );
        }
        
        protected function addNode( node : ListenerNode ) : void
        {
            if( dispatching )
            {
                if( !toAddHead )
                {
                    toAddHead = toAddTail = node;
                }
                else
                {
                    toAddTail.next = node;
                    node.previous = toAddTail;
                    toAddTail = node;
                }
            }
            else
            {
                if ( !head )
                {
                    head = tail = node;
                }
                else
                {
                    tail.next = node;
                    node.previous = tail;
                    tail = node;
                }
            }
            _numListeners++;
        }

        public function remove( listener : Function ) : void
        {
            var node : ListenerNode = nodes[ listener ];
            if ( node )
            {
                if ( head == node)
                {
                    head = head.next;
                }
                if ( tail == node)
                {
                    tail = tail.previous;
                }
                if ( toAddHead == node)
                {
                    toAddHead = toAddHead.next;
                }
                if ( toAddTail == node)
                {
                    toAddTail = toAddTail.previous;
                }
                if (node.previous)
                {
                    node.previous.next = node.next;
                }
                if (node.next)
                {
                    node.next.previous = node.previous;
                }
                delete nodes[ listener ];
                if( dispatching )
                {
                    listenerNodePool.cache( node );
                }
                else
                {
                    listenerNodePool.dispose( node );
                }
                _numListeners--;
            }
        }
        
        public function removeAll() : void
        {
            while( head )
            {
                var node : ListenerNode = head;
                head = head.next;
                delete nodes[ node.listener ];
                listenerNodePool.dispose( node );
                node.previous = null;
                node.next = null;
            }
            tail = null;
            toAddHead = null;
            toAddTail = null;
            _numListeners = 0;
        }
    }
//}

//package {
    //import ash.signals.Signal0;
    import flash.utils.Dictionary;

    
    /*public*/ class Engine
    {
        private var entityNames : Dictionary;
        private var entityList : EntityList;
        private var systemList : SystemList;
        private var families : Dictionary;
        
        
        public var updating : Boolean;
        
        
        public var updateComplete : Signal0;
        
        
        public var familyClass : Class = ComponentMatchingFamily;
        
        public function Engine()
        {
            entityList = new EntityList();
            entityNames = new Dictionary();
            systemList = new SystemList();
            families = new Dictionary();
            updateComplete = new Signal0();
        }
        
        
        public function addEntity( entity : Entity ) : void
        {
            if( entityNames[ entity.name ] )
            {
                throw new Error( "The entity name " + entity.name + " is already in use by another entity." );
            }
            entityList.add( entity );
            entityNames[ entity.name ] = entity;
            entity.componentAdded.add( componentAdded );
            entity.componentRemoved.add( componentRemoved );
            entity.nameChanged.add( entityNameChanged );
            for each( var family : IFamily in families )
            {
                family.newEntity( entity );
            }
        }
        
        
        public function removeEntity( entity : Entity ) : void
        {
            entity.componentAdded.remove( componentAdded );
            entity.componentRemoved.remove( componentRemoved );
            entity.nameChanged.remove( entityNameChanged );
            for each( var family : IFamily in families )
            {
                family.removeEntity( entity );
            }
            delete entityNames[ entity.name ];
            entityList.remove( entity );
        }
        
        private function entityNameChanged( entity : Entity, oldName : String ) : void
        {
            if( entityNames[ oldName ] == entity )
            {
                delete entityNames[ oldName ];
                entityNames[ entity.name ] = entity;
            }
        }
        
        
        public function getEntityByName( name : String ) : Entity
        {
            return entityNames[ name ];
        }
        
        
        public function removeAllEntities() : void
        {
            while( entityList.head )
            {
                removeEntity( entityList.head );
            }
        }
        
        
        public function get entities() : Vector.<Entity>
        {
            var entities : Vector.<Entity> = new Vector.<Entity>();
            for( var entity : Entity = entityList.head; entity; entity = entity.next )
            {
                entities.push( entity );
            }
            return entities;
        }
        
        
        private function componentAdded( entity : Entity, componentClass : Class ) : void
        {
            for each( var family : IFamily in families )
            {
                family.componentAddedToEntity( entity, componentClass );
            }
        }
        
        
        private function componentRemoved( entity : Entity, componentClass : Class ) : void
        {
            for each( var family : IFamily in families )
            {
                family.componentRemovedFromEntity( entity, componentClass );
            }
        }
        
        
        public function getNodeList( nodeClass : Class ) : NodeList
        {
            if( families[nodeClass] )
            {
                return IFamily( families[nodeClass] ).nodeList;
            }
            var family : IFamily = new familyClass( nodeClass, this );
            families[nodeClass] = family;
            for( var entity : Entity = entityList.head; entity; entity = entity.next )
            {
                family.newEntity( entity );
            }
            return family.nodeList;
        }
        
        
        public function releaseNodeList( nodeClass : Class ) : void
        {
            if( families[nodeClass] )
            {
                families[nodeClass].cleanUp();
            }
            delete families[nodeClass];
        }
        
        
        public function addSystem( system : System, priority : int ) : void
        {
            system.priority = priority;
            system.addToEngine( this );
            systemList.add( system );
        }
        
        
        public function getSystem( type : Class ) : System
        {
            return systemList.get( type );
        }
        
        
        public function get systems() : Vector.<System>
        {
            var systems : Vector.<System> = new Vector.<System>();
            for( var system : System = systemList.head; system; system = system.next )
            {
                systems.push( system );
            }
            return systems;
        }
        
        
        public function removeSystem( system : System ) : void
        {
            systemList.remove( system );
            system.removeFromEngine( this );
        }
        
        
        public function removeAllSystems() : void
        {
            while( systemList.head )
            {
                removeSystem( systemList.head );
            }
        }

        
        public function update( time : Number ) : void
        {
            updating = true;
            for( var system : System = systemList.head; system; system = system.next )
            {
                system.update( time );
            }
            updating = false;
            updateComplete.dispatch();
        }
    }



//package {
    
    /*public*/ class Signal0 extends SignalBase
    {
        public function Signal0()
        {
        }

        public function dispatch() : void
        {
            startDispatch();
            var node : ListenerNode;
            for ( node = head; node; node = node.next )
            {
                node.listener();
                if( node.once )
                {
                    remove( node.listener );
                }
            }
            endDispatch();
        }
    }
//}


class ReflectUtil {
    
    private static var CACHE:Dictionary = new Dictionary();
    public static var HACHE_COMPONENTS:Dictionary = new Dictionary();
    
    public static function registerComponents(arrClasses:Array):void {
        var i:int = arrClasses.length;
        while (--i > -1) {
            HACHE_COMPONENTS[getQualifiedClassName(arrClasses[i])] = arrClasses[i]; 
        }
    }
    

    public static function getFields(nodeClass:Class, arrOfClasses:Array):Dictionary {
        if (CACHE[nodeClass]) return CACHE[nodeClass];
        var variables : XMLList = describeType( nodeClass ).factory.variable;

        var components:Dictionary = new Dictionary();
        var i:int = arrOfClasses.length;
        var hash:Object = { };
        while (--i > -1) {
            hash[ getQualifiedClassName(arrOfClasses[i]) ] = arrOfClasses[i];
        }
          for each ( var atom:XML in variables )
            {
                if ( atom.@name != "entity" && atom.@name != "previous" && atom.@name != "next" )
                {
                    var componentClass : Class = hash[ atom.@type.toString()] || HACHE_COMPONENTS[atom.@type.toString()];
                    if (componentClass == null) throw new Error("Could not find component class>" + atom.@type + ", for "+nodeClass);
                    components[componentClass] = atom.@name.toString();
                }
            }
                CACHE[nodeClass] = components;
                return components;
        }
        
    
    }
    



//package {
    import flash.utils.Dictionary;
    import flash.utils.describeType;
    import flash.utils.getDefinitionByName;

    
    /*public*/ class ComponentMatchingFamily implements IFamily
    {
        private var nodes : NodeList;
        private var entities : Dictionary;
        private var nodeClass : Class;
        private var components : Dictionary;
        private var nodePool : NodePool;
        private var engine : Engine;

        
        public function ComponentMatchingFamily( nodeClass : Class, engine : Engine )
        {
            this.nodeClass = nodeClass;
            this.engine = engine;
            init();
        }

        
        private function init() : void
        {
            nodes = new NodeList();
            entities = new Dictionary();
            components = new Dictionary();
            nodePool = new NodePool( nodeClass, components );
            
            nodePool.dispose( nodePool.get() ); 

            try {
            var dict:Dictionary = nodeClass["_getFields"]();
            }
            catch (e:Error) {
                 var variables : XMLList = describeType( nodeClass ).factory.variable;
                for each ( var atom:XML in variables )
                {
                    if ( atom.@name != "entity" && atom.@name != "previous" && atom.@name != "next" )
                    {
                        var componentClass : Class = ReflectUtil.HACHE_COMPONENTS[ atom.@type.toString()];
                        if (componentClass == null) throw new Error("Component class is undefined! "+atom.@type);
                        components[componentClass] = atom.@name.toString();
                    }
                }
                dict = new Dictionary();
            }
            for each(var key:* in dict) {
                components[key] = dict[key];
            }
            
        }
        
        
        public function get nodeList() : NodeList
        {
            return nodes;
        }

        
        public function newEntity( entity : Entity ) : void
        {
            addIfMatch( entity );
        }
        
        
        public function componentAddedToEntity( entity : Entity, componentClass : Class ) : void
        {
            addIfMatch( entity );
        }
        
        
        public function componentRemovedFromEntity( entity : Entity, componentClass : Class ) : void
        {
            if( components[componentClass] )
            {
                removeIfMatch( entity );
            }
        }
        
        
        public function removeEntity( entity : Entity ) : void
        {
            removeIfMatch( entity );
        }
        
        
        private function addIfMatch( entity : Entity ) : void
        {
            if( !entities[entity] )
            {
                var componentClass : *;
                for ( componentClass in components )
                {
                    if ( !entity.has( componentClass ) )
                    {
                        return;
                    }
                }
                var node : Node = nodePool.get();
                node.entity = entity;
                for ( componentClass in components )
                {
                    node[components[componentClass]] = entity.get( componentClass );
                }
                entities[entity] = node;
                nodes.add( node );
            }
        }
        
        
        private function removeIfMatch( entity : Entity ) : void
        {
            if( entities[entity] )
            {
                var node : Node = entities[entity];
                delete entities[entity];
                nodes.remove( node );
                if( engine.updating )
                {
                    nodePool.cache( node );
                    engine.updateComplete.add( releaseNodePoolCache );
                }
                else
                {
                    nodePool.dispose( node );
                }
            }
        }
        
        
        private function releaseNodePoolCache() : void
        {
            engine.updateComplete.remove( releaseNodePoolCache );
            nodePool.releaseCache();
        }
        
        
        public function cleanUp() : void
        {
            for( var node : Node = nodes.head; node; node = node.next )
            {
                delete entities[node.entity];
            }
            nodes.removeAll();
        }
    }
//}


//package {
    
    /*public*/ class Signal2 extends SignalBase
    {
        private var type1 : Class;
        private var type2 : Class;

        public function Signal2( type1 : Class, type2 : Class )
        {
            this.type1 = type1;
            this.type2 = type2;
        }

        public function dispatch( object1 : *, object2 : * ) : void
        {
            startDispatch();
            var node : ListenerNode;
            for ( node = head; node; node = node.next )
            {
                node.listener( object1, object2 );
                if( node.once )
                {
                    remove( node.listener );
                }
            }
            endDispatch();
        }
    }
//}

/*
 * Based on ideas used in Robert Penner's AS3-signals - https://github.com/robertpenner/as3-signals
 */


    
    class Signal3 extends SignalBase
    {
        private var type1 : Class;
        private var type2 : Class;
        private var type3 : Class;

        public function Signal3( type1 : Class, type2 : Class, type3 : Class )
        {
            this.type1 = type1;
            this.type2 = type2;
            this.type3 = type3;
        }

        public function dispatch( object1 : *, object2 : *, object3 : * ) : void
        {
            startDispatch();
            var node : ListenerNode;
            for ( node = head; node; node = node.next )
            {
                node.listener( object1, object2, object3 );
                if( node.once )
                {
                    remove( node.listener );
                }
            }
            endDispatch();
        }
    }
    
    


    class SignalAny extends SignalBase
    {
        protected var classes : Array;

        public function SignalAny( ...classes )
        {
            this.classes = classes;
        }

        public function dispatch( ...objects ) : void
        {
            startDispatch();
            var node : ListenerNode;
            for ( node = head; node; node = node.next )
            {
                node.listener.apply( null, objects );
                if( node.once )
                {
                    remove( node.listener );
                }
            }
            endDispatch();
        }
    }








//package {
    
    /*public*/ class Signal1 extends SignalBase
    {
        private var type : Class;

        public function Signal1( type : Class )
        {
            this.type = type;
        }

        public function dispatch( object : * ) : void
        {
            startDispatch();
            var node : ListenerNode;
            for ( node = head; node; node = node.next )
            {
                node.listener( object );
                if( node.once )
                {
                    remove( node.listener );
                }
            }
            endDispatch();
        }
    }
//}




interface IFamily {
        function get nodeList() : NodeList;
        function newEntity( entity : Entity ) : void;
        function removeEntity( entity : Entity ) : void;
        function componentAddedToEntity( entity : Entity, componentClass : Class ) : void;
        function componentRemovedFromEntity( entity : Entity, componentClass : Class ) : void;
        function cleanUp() : void;
}



     interface ITickProvider
    {
        function get playing() : Boolean;
        
        function add( listener : Function ) : void;
        function remove( listener : Function ) : void;
        
        function start() : void;
        function stop() : void;
    }



    class EntityList
    {
        public var head : Entity;
        public var tail : Entity;
        
        public function add( entity : Entity ) : void
        {
            if( ! head )
            {
                head = tail = entity;
                entity.next = entity.previous = null;
            }
            else
            {
                tail.next = entity;
                entity.previous = tail;
                entity.next = null;
                tail = entity;
            }
        }
        
        public function remove( entity : Entity ) : void
        {
            if ( head == entity)
            {
                head = head.next;
            }
            if ( tail == entity)
            {
                tail = tail.previous;
            }
            
            if (entity.previous)
            {
                entity.previous.next = entity.next;
            }
            
            if (entity.next)
            {
                entity.next.previous = entity.previous;
            }
            // N.B. Don't set node.next and node.previous to null because that will break the list iteration if node is the current node in the iteration.
        }
        
        public function removeAll() : void
        {
            while( head )
            {
                var entity : Entity = head;
                head = head.next;
                entity.previous = null;
                entity.next = null;
            }
            tail = null;
        }
    }



    class SystemList
    {
        public var head : System;
        public var tail : System;
        
        public function add( system : System ) : void
        {
            if( ! head )
            {
                head = tail = system;
                system.next = system.previous = null;
            }
            else
            {
                for( var node : System = tail; node; node = node.previous )
                {
                    if( node.priority <= system.priority )
                    {
                        break;
                    }
                }
                if( node == tail )
                {
                    tail.next = system;
                    system.previous = tail;
                    system.next = null;
                    tail = system;
                }
                else if( !node )
                {
                    system.next = head;
                    system.previous = null;
                    head.previous = system;
                    head = system;
                }
                else
                {
                    system.next = node.next;
                    system.previous = node;
                    node.next.previous = system;
                    node.next = system;
                }
            }
        }
        
        public function remove( system : System ) : void
        {
            if ( head == system)
            {
                head = head.next;
            }
            if ( tail == system)
            {
                tail = tail.previous;
            }
            
            if (system.previous)
            {
                system.previous.next = system.next;
            }
            
            if (system.next)
            {
                system.next.previous = system.previous;
            }
            // N.B. Don't set system.next and system.previous to null because that will break the list iteration if node is the current node in the iteration.
        }
        
        public function removeAll() : void
        {
            while( head )
            {
                var system : System = head;
                head = head.next;
                system.previous = null;
                system.next = null;
            }
            tail = null;
        }
        
        public function get( type : Class ) : System
        {
            for( var system : System = head; system; system = system.next )
            {
                if ( system is type )
                {
                    return system;
                }
            }
            return null;
        }
    }

//package 
//{
    import flash.utils.Dictionary;
    
    class NodePool
    {
        private var tail : Node;
        private var nodeClass : Class;
        private var cacheTail : Node;
        private var components : Dictionary;

        /**
         * Creates a pool for the given node class.
         */
        public function NodePool( nodeClass : Class, components : Dictionary )
        {
            this.nodeClass = nodeClass;
            this.components = components;
        }

        /**
         * Fetches a node from the pool.
         */
        internal function get() : Node
        {
            if ( tail )
            {
                var node : Node = tail;
                tail = tail.previous;
                node.previous = null;
                return node;
            }
            else
            {
                return new nodeClass();
            }
        }

        /**
         * Adds a node to the pool.
         */
        internal function dispose( node : Node ) : void
        {
            for each( var componentName : String in components )
            {
                node[ componentName ] = null;
            }
            node.entity = null;
            
            node.next = null;
            node.previous = tail;
            tail = node;
        }
        
        /**
         * Adds a node to the cache
         */
        internal function cache( node : Node ) : void
        {
            node.previous = cacheTail;
            cacheTail = node;
        }
        
        /**
         * Releases all nodes from the cache into the pool
         */
        internal function releaseCache() : void
        {
            while( cacheTail )
            {
                var node : Node = cacheTail;
                cacheTail = node.previous;
                dispose( node );
            }
        }
    }
//}

//package {
    //import ash.signals.Signal1;
    import flash.display.DisplayObject;
    import flash.events.Event;
    import flash.utils.getTimer;

    
    /*public*/ class FrameTickProvider extends Signal1 implements ITickProvider
    {
        private var displayObject : DisplayObject;
        private var previousTime : Number;
        private var maximumFrameTime : Number;
        private var isPlaying : Boolean = false;
        
        
        public var timeAdjustment : Number = 1;
        
        public function FrameTickProvider( displayObject : DisplayObject, maximumFrameTime : Number = Number.MAX_VALUE )
        {
            super( Number );
            this.displayObject = displayObject;
            this.maximumFrameTime = maximumFrameTime;
        }
        
        public function start() : void
        {
            previousTime = getTimer();
            displayObject.addEventListener( Event.ENTER_FRAME, dispatchTick );
            isPlaying = true;
        }
        
        public function stop() : void
        {
            isPlaying = false;
            displayObject.removeEventListener( Event.ENTER_FRAME, dispatchTick );
        }
        
        private function dispatchTick( event : Event ) : void
        {
            var temp : Number = previousTime;
            previousTime = getTimer();
            var frameTime : Number = ( previousTime - temp ) / 1000;
            if( frameTime > maximumFrameTime )
            {
                frameTime = maximumFrameTime;
            }
            dispatch( frameTime * timeAdjustment );
        }

        public function get playing() : Boolean
        {
            return isPlaying;
        }
    }
//}

//package ash.tick
//{
    import flash.display.DisplayObject;
    import flash.events.Event;


    //public
    class FixedTickProvider extends Signal1 implements ITickProvider
    {
        private var displayObject : DisplayObject;
        private var frameTime : Number;
        private var isPlaying : Boolean = false;
        
        public var timeAdjustment : Number = 1;
        
        public function FixedTickProvider( displayObject : DisplayObject, frameTime : Number )
        {
            super( Number );
            this.displayObject = displayObject;
            this.frameTime = frameTime;
        }
        
        public function start() : void
        {
            displayObject.addEventListener( Event.ENTER_FRAME, dispatchTick );
            isPlaying = true;
        }
        
        public function stop() : void
        {
            isPlaying = false;
            displayObject.removeEventListener( Event.ENTER_FRAME, dispatchTick );
        }
        
        private function dispatchTick( event : Event ) : void
        {
            dispatch( frameTime * timeAdjustment );
        }

        public function get playing() : Boolean
        {
            return isPlaying;
        }
    }
//}



// -- Ash framework ends here
    
    
    
    
    

     interface IAnimatable {
        function animate(time : Number) : void ;
    }

    class AnimationSystem extends ListIteratingSystem {
        public function AnimationSystem() : void { 
            super(AnimationNode,this.updateNode);
        }
        
        public function updateNode(node : AnimationNode,time : Number) : void {
            node.animatable.animate(time);
        }
        
    }

    
     class AnimationNode extends Node {
        public function AnimationNode() : void {
        }
        
        public var animatable : IAnimatable;

    }



     interface IRenderable {
        function render() : void ;
    }



     class RenderSystem extends System {
        public function RenderSystem() : void { 
            super();
        }
        
        public function onRemovedNode(node : RenderNode) : void {
        }
        
        public function onAddedNode(node : RenderNode) : void {
        }
        
        public override function addToEngine(engine : Engine) : void {
            this.nodeList = engine.getNodeList(RenderNode);
            this.nodeList.nodeAdded.add(this.onAddedNode);
            this.nodeList.nodeRemoved.add(this.onRemovedNode);
        }
        
        public var renderEngine : IRenderable;
        public var nodeList : NodeList;
    }

    
    import alternativa.engine3d.core.Object3D;
    
    class RenderNode extends Node {
        public function RenderNode() : void {
        }
        
        public var rot : Rot;
        public var pos : Pos;
        public var object : Object3D;
        
        
    }
    
    



    import alternativa.engine3d.core.Object3D;
    import alternativa.engine3d.alternativa3d;
    use namespace alternativa3d;
    
    /**
     * ...
     * @author Glenn Ko
     */
    class RenderingSystem extends RenderSystem
    {
        private var scene:Object3D;
    
        public function RenderingSystem(scene:Object3D, renderingSystem:IRenderable=null) 
        {
            this.scene = scene;
            this.renderEngine = renderingSystem;
        }
        
    
        override public function onAddedNode(node:RenderNode):void {
          if (node.object._parent == null)  scene.addChild( node.object );
        }
        
        override public function onRemovedNode(node:RenderNode):void {
           if (node.object._parent === scene) scene.removeChild( node.object);
        }
    
        override public function update(time:Number):void {
            for (var r:RenderNode = nodeList.head as RenderNode; r != null; r = r.next as RenderNode) {
                r.object._x = r.pos.x;
                r.object._y = r.pos.y;
                r.object._z = r.pos.z;
                r.object._rotationX = r.rot.x;
                r.object._rotationY = r.rot.y;
                r.object._rotationZ = r.rot.z;
                r.object.transformChanged = true;
            }
            if (renderEngine != null) renderEngine.render();
        }
        
    }

// --- Ash-compiled classes


import flash.display.Graphics;
import flash.display.Shape;
import flash.display.Sprite;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.events.Event;



class DisplayObjectRenderingSystem extends System {
    private var scene:DisplayObjectContainer;
    private var nodeList:NodeList;
    
    
    public function DisplayObjectRenderingSystem(scene:DisplayObjectContainer):void {
        this.scene = scene;
    }
     public function onAddedNode(node:DisplayNode):void {
            scene.addChild( node.object );
    }
    
    override public function addToEngine(engine:Engine ):void {
        super.addToEngine(engine);
        nodeList = engine.getNodeList(DisplayNode);
        nodeList.nodeAdded.add(onAddedNode);
        nodeList.nodeRemoved.add(onRemovedNode);
    }
    
        
         public function onRemovedNode(node:DisplayNode):void {
            scene.removeChild( node.object);
        }
    
        override public function update(time:Number):void {
            const RAD_TO_DEG:Number = 180 / Math.PI;
            for (var r:DisplayNode = nodeList.head as DisplayNode; r != null; r = r.next as DisplayNode) {
                r.object.x = r.pos.x;
                r.object.y = r.pos.y;
                r.object.rotation = r.rot.z * RAD_TO_DEG;
            }
            //if (renderEngine != null) renderEngine.render();
        }
    
}

class DisplayNode extends Node {
    public var object:DisplayObject;
    public var pos:Pos;
    public var rot:Rot;
    


    public function DisplayNode() {
        
    }
    
   
}

    class Vec3 {
        public function Vec3(x : Number = 0,y : Number = 0,z : Number = 0) : void {
            this.x = x;
            this.y = y;
            this.z = z;
        }
        public function toString() : String {
            return "Vec3(" + this.x + ", " + this.y + ", " + this.z + ")";
        }
        public function distanceTo(v : Vec3) : Number {
            var dx : Number = this.x - v.x;
            var dy : Number = this.y - v.y;
            var dz : Number = this.z - v.z;
            return Math.sqrt(dx * dx + dy * dy + dz * dz);
        }
        public function removeComponent(axis : Vec3) : void {
            var scalar : Number = this.dotProduct(axis);
            this.x = this.x - axis.x * scalar;
            this.y = this.y - axis.y * scalar;
            this.z = this.z - axis.z * scalar;
        }
        public function setLength(val : Number) : void {
            var k : Number = val / this.length();
            this.x *= k;
            this.y *= k;
            this.z *= k;
        }
        protected function normalizeWithSquared(squaredLength : Number) : void {
            this.scale(1 / Math.sqrt(squaredLength));
        }
        public function normalize() : void {
            this.scale(1 / this.length());
        }
        public function assignAddition(v1 : Vec3,v2 : Vec3) : void {
            this.x = v1.x + v2.x;
            this.y = v1.y + v2.y;
            this.z = v1.z + v2.z;
        }

        public function copyFrom(source : Vec3) : void {
            this.x = source.x;
            this.y = source.y;
            this.z = source.z;
        }
        public function saveTo(result : Vec3) : void {
            result.x = this.x;
            result.y = this.y;
            result.z = this.z;
        }
        public function set(param1 : Number,param2 : Number,param3 : Number) : void {
            this.x = param1;
            this.y = param2;
            this.z = param3;
        }
        public function reset() : void {
            this.x = this.y = this.z = 0;
        }
        public function transformTransposed3(m : Mat3) : void {
            this.x = m.a * this.x + m.e * this.y + m.i * this.z;
            this.y = m.b * this.x + m.f * this.y + m.j * this.z;
            this.z = m.c * this.x + m.g * this.y + m.k * this.z;
        }
        public function transform3(m : Mat3) : void {
            this.x = m.a * this.x + m.b * this.y + m.c * this.z;
            this.y = m.e * this.x + m.f * this.y + m.g * this.z;
            this.z = m.i * this.x + m.j * this.y + m.k * this.z;
        }
        public function reverse() : void {
            this.x = -this.x;
            this.y = -this.y;
            this.z = -this.z;
        }
        public function scale(k : Number) : void {
            this.x *= k;
            this.y *= k;
            this.z *= k;
        }
        public function diff(a : Vec3,b : Vec3) : void {
            this.x = a.x - b.x;
            this.y = a.y - b.y;
            this.z = a.z - b.z;
        }
        public function sum(a : Vec3,b : Vec3) : void {
            this.x = a.x + b.x;
            this.y = a.y + b.y;
            this.z = a.z + b.z;
        }
        public function subtract(v : Vec3) : void {
            this.x -= v.x;
            this.y -= v.y;
            this.z -= v.z;
        }
        public function addScaled(k : Number,v : Vec3) : void {
            this.x += k * v.x;
            this.y += k * v.y;
            this.z += k * v.z;
        }
        public function add(v : Vec3) : void {
            this.x += v.x;
            this.y += v.y;
            this.z += v.z;
        }
        public function crossProductSet(v : Vec3) : void {
            this.x = this.y * v.z - this.z * v.y;
            this.y = this.z * v.x - this.x * v.z;
            this.z = this.x * v.y - this.y * v.x;
        }
        public function isZeroVector() : Boolean {
            return this.lengthSqr() == 0;
        }
        public function clone() : Vec3 {
            return new Vec3(this.x,this.y,this.z);
        }
        public function crossProduct(v : Vec3) : Vec3 {
            return new Vec3(this.y * v.z - this.z * v.y,this.z * v.x - this.x * v.z,this.x * v.y - this.y * v.x);
        }
        public function dotProduct(v : Vec3) : Number {
            return this.x * v.x + this.y * v.y + this.z * v.z;
        }
        public function lengthSqr() : Number {
            return this.x * this.x + this.y * this.y + this.z * this.z;
        }
        public function length() : Number {
            return Math.sqrt(this.x * this.x + this.y * this.y + this.z * this.z);
        }
        public var z : Number;
        public var y : Number;
        public var x : Number;
        static public var ZERO : Vec3 = new Vec3(0,0,0);
        static public var X_AXIS : Vec3 = new Vec3(1,0,0);
        static public var Y_AXIS : Vec3 = new Vec3(0,1,0);
        static public var Z_AXIS : Vec3 = new Vec3(0,0,1);
        static public var RIGHT : Vec3 = new Vec3(1,0,0);
        static public var LEFT : Vec3 = new Vec3(-1,0,0);
        static public var FORWARD : Vec3 = new Vec3(0,1,0);
        static public var BACK : Vec3 = new Vec3(0,-1,0);
        static public var UP : Vec3 = new Vec3(0,0,1);
        static public var DOWN : Vec3 = new Vec3(0,0,-1);
        static public function copy(v : Vec3) : Vec3 {
            return new Vec3(v.x,v.y,v.z);
        }
        static public function createCross(v1 : Vec3,v2 : Vec3) : Vec3 {
            return new Vec3(v1.y * v2.z - v1.z * v2.y,v1.z * v2.x - v1.x * v2.z,v1.x * v2.y - v1.y * v2.x);
        }
        static public function createAdd(v1 : Vec3,v2 : Vec3) : Vec3 {
            return new Vec3(v1.x + v2.x,v1.y + v2.y,v1.z + v2.z);
        }
        static public function createSubtract(v1 : Vec3,v2 : Vec3) : Vec3 {
            return new Vec3(v1.x - v2.x,v1.y - v2.y,v1.z - v2.z);
        }
        static public function createScale(v : Vec3,scaleAmt : *) : Vec3 {
            return new Vec3(v.x * scaleAmt,v.y * scaleAmt,v.z * scaleAmt);
        }
        static public function createProjection(v : Vec3,axis : Vec3) : Vec3 {
            var scalar : Number = Vec3.dot(v,axis);
            return new Vec3(v.x - axis.x * scalar,v.y - axis.y * scalar,v.z - axis.z * scalar);
        }
        static public function dot(v1 : Vec3,v2 : Vec3) : Number {
            return v1.x * v2.x + v1.y * v2.y + v1.z * v2.z;
        }
        static public function lengthOf(v : Vec3) : Number {
            return Math.sqrt(Vec3.squareLengthOf(v));
        }
        static public function squareLengthOf(v : Vec3) : Number {
            return v.x * v.x + v.y * v.y + v.z * v.z;
        }
        static public function writeCross(v1 : Vec3,v2 : Vec3,output : Vec3) : void {
            output.x = v1.y * v2.z - v1.z * v2.y;
            output.y = v1.z * v2.x - v2.z * v1.x;
            output.z = v1.x * v2.y - v1.y * v2.x;
        }
        static public function writeProjection(v : Vec3,axis : Vec3,output : Vec3) : void {
            var scalar : Number = Vec3.dot(v,axis);
            output.x = v.x - axis.x * scalar;
            output.y = v.y - axis.y * scalar;
            output.z = v.z - axis.z * scalar;
        }
        static public function writeSubtract(output : Vec3,input : Vec3) : void {
            output.x -= input.x;
            output.y -= input.y;
            output.z -= input.z;
        }
        static public function writeAdd(output : Vec3,input : Vec3) : void {
            output.x += input.x;
            output.y += input.y;
            output.z += input.z;
        }
        static public function writeScale(output : Vec3,scaleAmt : Number) : void {
            output.x *= scaleAmt;
            output.y *= scaleAmt;
            output.z *= scaleAmt;
        }
    }

//package {


    /*public*/ class FlockingNode extends Node {
        public var vel : Vel;
        public var rot : Rot;
        public var pos : Pos;
        public var f : Flocking;
        

    }
//}
//package {
    import flash.geom.Vector3D;
    
    /*public*/ class Vec3Utils {
        static public function copy(v : Vec3) : Vec3 {
            return new Vec3(v.x,v.y,v.z);
        }
        static public function createCross(v1 : Vec3,v2 : Vec3) : Vec3 {
            return new Vec3(v1.y * v2.z - v1.z * v2.y,v1.z * v2.x - v1.x * v2.z,v1.x * v2.y - v1.y * v2.x);
        }
        static public function createAdd(v1 : Vec3,v2 : Vec3) : Vec3 {
            return new Vec3(v1.x + v2.x,v1.y + v2.y,v1.z + v2.z);
        }
        static public function createSubtract(v1 : Vec3,v2 : Vec3) : Vec3 {
            return new Vec3(v1.x - v2.x,v1.y - v2.y,v1.z - v2.z);
        }
        static public function createScale(v : Vec3,scaleAmt : Number) : Vec3 {
            return new Vec3(v.x * scaleAmt,v.y * scaleAmt,v.z * scaleAmt);
        }
        static public function createProjection(v : Vec3,axis : Vec3) : Vec3 {
            var scalar : Number = Vec3Utils.dot(v,axis);
            return new Vec3(v.x - axis.x * scalar,v.y - axis.y * scalar,v.z - axis.z * scalar);
        }
        static public function matchValues(output : Vec3,withValue : Vec3) : void {
            output.x = withValue.x;
            output.y = withValue.y;
            output.z = withValue.z;
        }
        static public function matchValuesVector3D(output : Vec3,withValue : flash.geom.Vector3D) : void {
            output.x = withValue.x;
            output.y = withValue.y;
            output.z = withValue.z;
        }
        static public function dot(v1 : Vec3,v2 : Vec3) : Number {
            return v1.x * v2.x + v1.y * v2.y + v1.z * v2.z;
        }
        static public function writeCross(v1 : Vec3,v2 : Vec3,output : Vec3) : void {
            output.x = v1.y * v2.z - v1.z * v2.y;
            output.y = v1.z * v2.x - v2.z * v1.x;
            output.z = v1.x * v2.y - v1.y * v2.x;
        }
        static public function writeProjection(v : Vec3,axis : Vec3,output : Vec3) : void {
            var scalar : Number = Vec3Utils.dot(v,axis);
            output.x = v.x - axis.x * scalar;
            output.y = v.y - axis.y * scalar;
            output.z = v.z - axis.z * scalar;
        }
        static public function normalize(v : Vec3) : void {
            var sc : Number = 1 / Math.sqrt(v.x * v.x + v.y * v.y + v.z * v.z);
            v.x *= sc;
            v.y *= sc;
            v.z *= sc;
        }
        static public function subtract(output : Vec3,input : Vec3) : void {
            output.x -= input.x;
            output.y -= input.y;
            output.z -= input.z;
        }
        static public function add(output : Vec3,input : Vec3) : void {
            output.x += input.x;
            output.y += input.y;
            output.z += input.z;
        }
        static public function scale(output : Vec3,scaleAmt : Number) : void {
            output.x *= scaleAmt;
            output.y *= scaleAmt;
            output.z *= scaleAmt;
        }
        static public function writeSubtract(output : Vec3,v1 : Vec3,v2 : Vec3) : void {
            output.x = v1.x - v2.x;
            output.y = v1.y - v2.y;
            output.z = v1.z - v2.z;
        }
        static public function getLength(v : Vec3) : Number {
            return Math.sqrt(v.x * v.x + v.y * v.y + v.z * v.z);
        }
    }
//}
//package {

    /*public*/ class Mat3 {
        public function Mat3(a : Number = 1,b : Number = 0,c : Number = 0,e : Number = 0,f : Number = 1,g : Number = 0,i : Number = 0,j : Number = 0,k : Number = 1) : void { 
            this.a = a;
            this.b = b;
            this.c = c;
            this.e = e;
            this.f = f;
            this.g = g;
            this.i = i;
            this.j = j;
            this.k = k;
        }
        public function toString() : String {
            return "[Mat3 (" + this.a + ", " + this.b + ", " + this.c + "), (" + this.e + ", " + this.f + ", " + this.g + "), (" + this.i + ", " + this.j + ", " + this.k + ")]";
        }
        public function setFromAxisAngle(axis : Vec3,angle : Number) : void {
            var c1 : Number = Math.cos(angle);
            var s : Number = Math.sin(angle);
            var t : Number = 1 - c1;
            var x : Number = axis.x;
            var y : Number = axis.y;
            var z : Number = axis.z;
            this.a = t * x * x + c1;
            this.b = t * x * y - z * s;
            this.c = t * x * z + y * s;
            this.e = t * x * y + z * s;
            this.f = t * y * y + c1;
            this.g = t * y * z - x * s;
            this.i = t * x * z - y * s;
            this.j = t * y * z + x * s;
            this.k = t * z * z + c1;
        }
        public function setRotation(rx : Number,ry : Number,rz : Number) : void {
            var cosX : Number = Math.cos(rx);
            var sinX : Number = Math.sin(rx);
            var cosY : Number = Math.cos(ry);
            var sinY : Number = Math.sin(ry);
            var cosZ : Number = Math.cos(rz);
            var sinZ : Number = Math.sin(rz);
            var cosZsinY : Number = cosZ * sinY;
            var sinZsinY : Number = sinZ * sinY;
            this.a = cosZ * cosY;
            this.b = cosZsinY * sinX - sinZ * cosX;
            this.c = cosZsinY * cosX + sinZ * sinX;
            this.e = sinZ * cosY;
            this.f = sinZsinY * sinX + cosZ * cosX;
            this.g = sinZsinY * cosX - cosZ * sinX;
            this.i = -sinY;
            this.j = cosY * sinX;
            this.k = cosY * cosX;
        }
        public function writeToEulerAngles(angles : Vec3) : void {
            if(-1 < this.i && this.i < 1) {
                angles.x = Math.atan2(this.j,this.k);
                angles.y = -Math.asin(this.i);
                angles.z = Math.atan2(this.e,this.a);
            }
            else {
                angles.x = 0;
                angles.y = ((this.i <= -1)?Math.PI:-Math.PI);
                angles.y *= 0.5;
                angles.z = Math.atan2(-this.b,this.f);
            }
        }
        public function copyFrom(m : Mat3) : void {
            this.a = m.a;
            this.b = m.b;
            this.c = m.c;
            this.e = m.e;
            this.f = m.f;
            this.g = m.g;
            this.i = m.i;
            this.j = m.j;
            this.k = m.k;
        }
        public function toSkewSymmetric(v : Vec3) : void {
            this.a = this.f = this.k = 0;
            this.b = -v.z;
            this.c = v.y;
            this.e = v.z;
            this.g = -v.x;
            this.i = -v.y;
            this.j = v.x;
        }
        public function transpose() : void {
            var tmp : Number = this.b;
            this.b = this.e;
            this.e = tmp;
            tmp = this.c;
            this.c = this.i;
            this.i = tmp;
            tmp = this.g;
            this.g = this.j;
            this.j = tmp;
        }
        public function subtract(m : Mat3) : void {
            this.a -= m.a;
            this.b -= m.b;
            this.c -= m.c;
            this.e -= m.e;
            this.f -= m.f;
            this.g -= m.g;
            this.i -= m.i;
            this.j -= m.j;
            this.k -= m.k;
        }
        public function add(m : Mat3) : void {
            this.a += m.a;
            this.b += m.b;
            this.c += m.c;
            this.e += m.e;
            this.f += m.f;
            this.g += m.g;
            this.i += m.i;
            this.j += m.j;
            this.k += m.k;
        }
        public function prependTransposed(m : Mat3) : void {
            this.a = this.a * m.a + this.b * m.b + this.c * m.c;
            this.b = this.a * m.e + this.b * m.f + this.c * m.g;
            this.c = this.a * m.i + this.b * m.j + this.c * m.k;
            this.e = this.e * m.a + this.f * m.b + this.g * m.c;
            this.f = this.e * m.e + this.f * m.f + this.g * m.g;
            this.g = this.e * m.i + this.f * m.j + this.g * m.k;
            this.i = this.i * m.a + this.j * m.b + this.k * m.c;
            this.j = this.i * m.e + this.j * m.f + this.k * m.g;
            this.k = this.i * m.i + this.j * m.j + this.k * m.k;
        }
        public function prepend(m : Mat3) : void {
            this.a = this.a * m.a + this.b * m.e + this.c * m.i;
            this.b = this.a * m.b + this.b * m.f + this.c * m.j;
            this.c = this.a * m.c + this.b * m.g + this.c * m.k;
            this.e = this.e * m.a + this.f * m.e + this.g * m.i;
            this.f = this.e * m.b + this.f * m.f + this.g * m.j;
            this.g = this.e * m.c + this.f * m.g + this.g * m.k;
            this.i = this.i * m.a + this.j * m.e + this.k * m.i;
            this.j = this.i * m.b + this.j * m.f + this.k * m.j;
            this.k = this.i * m.c + this.j * m.g + this.k * m.k;
        }
        public function append(m : Mat3) : void {
            this.a = m.a * this.a + m.b * this.e + m.c * this.i;
            this.b = m.a * this.b + m.b * this.f + m.c * this.j;
            this.c = m.a * this.c + m.b * this.g + m.c * this.k;
            this.e = m.e * this.a + m.f * this.e + m.g * this.i;
            this.f = m.e * this.b + m.f * this.f + m.g * this.j;
            this.g = m.e * this.c + m.f * this.g + m.g * this.k;
            this.i = m.i * this.a + m.j * this.e + m.k * this.i;
            this.j = m.i * this.b + m.j * this.f + m.k * this.j;
            this.k = m.i * this.c + m.j * this.g + m.k * this.k;
        }
        public function invert_with_determinant(det : Number) : void {
            this.a = (this.f * this.k - this.g * this.j) * det;
            this.b = (this.c * this.g - this.b * this.k) * det;
            this.c = (this.b * this.g - this.c * this.f) * det;
            this.e = (this.g * this.i - this.e * this.k) * det;
            this.f = (this.a * this.k - this.c * this.i) * det;
            this.g = (this.c * this.e - this.a * this.g) * det;
            this.i = (this.e * this.j - this.f * this.i) * det;
            this.j = (this.b * this.i - this.a * this.j) * det;
            this.k = (this.a * this.f - this.b * this.e) * det;
        }
        public function invert() : void {
            this.invert_with_determinant(this.determinant());
        }
        public function transformVec3To3D(vin : Vec3,vout : Vec3) : void {
            vout.x = this.a * vin.x + this.b * vin.y + this.c * vin.z;
            vout.y = this.e * vin.x + this.f * vin.y + this.g * vin.z;
            vout.z = this.i * vin.x + this.j * vin.y + this.k * vin.z;
        }
        public function transformVectorTransposed(vin : Vec3,vout : Vec3) : void {
            vout.x = this.a * vin.x + this.e * vin.y + this.i * vin.z;
            vout.y = this.b * vin.x + this.f * vin.y + this.j * vin.z;
            vout.z = this.c * vin.x + this.g * vin.y + this.k * vin.z;
        }
        public function transformVector(vin : Vec3,vout : Vec3) : void {
            vout.x = this.a * vin.x + this.b * vin.y + this.c * vin.z;
            vout.y = this.e * vin.x + this.f * vin.y + this.g * vin.z;
            vout.z = this.i * vin.x + this.j * vin.y + this.k * vin.z;
        }
        public function clone() : Mat3 {
            return new Mat3(this.a,this.b,this.c,this.e,this.f,this.g,this.i,this.j,this.k);
        }
        public function identity() : void {
            this.a = this.f = this.k = 1;
            this.b = this.c = this.e = this.g = this.i = this.j = 0;
        }
        public function determinant() : Number {
            return 1 / (-this.c * this.f * this.i + this.b * this.g * this.i + this.c * this.e * this.j - this.a * this.g * this.j - this.b * this.e * this.k + this.a * this.f * this.k);
        }
        public var k : Number;
        public var j : Number;
        public var i : Number;
        public var g : Number;
        public var f : Number;
        public var e : Number;
        public var c : Number;
        public var b : Number;
        public var a : Number;
        static public var IDENTITY : Mat3 = new Mat3();
        static public var ZERO : Mat3 = new Mat3(0,0,0,0,0,0,0,0,0);
    }
//}
//package {

    
    /*public*/ class FlockingSystem extends System {
        public function FlockingSystem() : void { 
            super();
            this.relP = new Vec3();
            this.relV = new Vec3();
            this.dist = new Vec3();
            this.hispos = new Vec3();
            this.mypos = new Vec3();
            this.hispos = new Vec3();
            this.collision = new Vec3();
        }
        protected function predictTime(cur : FlockingNode,other : FlockingNode) : Number {
            Vec3Utils.writeSubtract(this.relP,cur.pos,other.pos);
            Vec3Utils.writeSubtract(this.relV,other.vel,cur.vel);
            return this.relV.dotProduct(this.relP) / this.relV.lengthSqr();
        }
        protected function angleBetween(me : Vec3,v : Vec3) : Number {
            var result : Number = Math.atan2(me.y,me.x) - Math.atan2(v.y,v.x);
            if(result < -Math.PI) result += Math.PI * 2;
            if(result > Math.PI) result -= Math.PI * 2;
            return result;
        }
        protected function isAlmostZero(a : Vec3,min : Number = 0.15999) : Boolean {
            return a.lengthSqr() < min;
        }
        protected function getAngle(vec : Vec3) : Number {
            return Math.atan2(vec.y,vec.x);
        }
        protected function sign(arg : Number) : Number {
            return ((arg > 0)?1:((arg < 0)?-1:0));
        }
        public override function update(sec : Number) : void {
            var count : int;
            var count2 : int;
            var cur : FlockingNode = this.nodeList.head;
            var time : Number;
            var collisionLen : Number;
            var curF : Flocking;
            var curS : FlockSettings;
            while(cur != null) {
                count = 0;
                count2 = 0;
                curF = cur.f;
                curS = curF.settings;
                var minTime : Number = curF.minTime;
                var other : FlockingNode;
                curF.separation.reset();
                curF.alignment.reset();
                curF.cohesion.reset();
                curF._aold.copyFrom(curF._a);
                curF._a.reset();
                other = cur.previous;
                while(other != null) {
                    Vec3Utils.writeSubtract(this.dist,other.pos,cur.pos);
                    time = this.predictTime(cur,other);
                    if(this.dist.lengthSqr() < curS.mydistSquared) {
                        curF.angle = Math.abs(this.angleBetween(cur.vel,this.dist));
                        if(curF.angle < 2 / 3 * Math.PI) {
                            this.dist.scale(curS.mydist / this.dist.lengthSqr());
                            curF.separation.subtract(this.dist);
                            curF.alignment.add(other.vel);
                            ++count;
                            curF.angle = Math.abs(this.angleBetween(cur.vel,other.vel));
                            if(curF.angle < Math.PI / 2) {
                                curF.cohesion.add(other.pos);
                                ++count2;
                            }
                        }
                    }
                    if(!(time < 0. || time >= minTime)) {
                        this.mypos.copyFrom(cur.vel);
                        this.mypos.scale(time);
                        this.mypos.add(cur.pos);
                        this.hispos.copyFrom(other.vel);
                        this.hispos.scale(time);
                        this.hispos.add(other.pos);
                        Vec3Utils.writeSubtract(this.collision,this.mypos,this.hispos);
                        collisionLen = this.collision.lengthSqr();
                        if(!(collisionLen >= curS.mindistSquared)) {
                            minTime = time;
                            collisionLen = 1 / Math.sqrt(collisionLen);
                            this.collision.scale(collisionLen);
                            curF._a.copyFrom(this.collision);
                        }
                    }
                    other = other.previous;
                }
                other = cur.next;
                while(other != null) {
                    Vec3Utils.writeSubtract(this.dist,other.pos,cur.pos);
                    time = this.predictTime(cur,other);
                    if(this.dist.lengthSqr() < curS.mindistSquared) {
                        curF.angle = Math.abs(this.angleBetween(cur.vel,this.dist));
                        if(curF.angle < 2 / 3 * Math.PI) {
                            this.dist.scale(curS.mydist / this.dist.lengthSqr());
                            curF.separation.subtract(this.dist);
                            curF.alignment.add(other.vel);
                            ++count;
                            curF.angle = Math.abs(this.angleBetween(cur.vel,other.vel));
                            if(curF.angle < Math.PI / 2) {
                                curF.cohesion.add(other.pos);
                                ++count2;
                            }
                        }
                    }
                    if(!(time < 0. || time >= minTime)) {
                        this.mypos.copyFrom(cur.vel);
                        this.mypos.scale(time);
                        this.mypos.add(cur.pos);
                        this.hispos.copyFrom(other.vel);
                        this.hispos.scale(time);
                        this.hispos.add(other.pos);
                        Vec3Utils.writeSubtract(this.collision,this.mypos,this.hispos);
                        collisionLen = this.collision.lengthSqr();
                        if(!(collisionLen >= curS.mindistSquared)) {
                            minTime = time;
                            collisionLen = 1 / Math.sqrt(collisionLen);
                            this.collision.scale(collisionLen);
                            curF._a.copyFrom(this.collision);
                        }
                    }
                    other = other.next;
                }
                var _a : Vec3 = curF._a;
                if(this.isAlmostZero(_a)) {
                    curF.separation.scale(.5);
                    _a.add(curF.separation);
                    if(count > 0) {
                        curF.alignment.scale(1 / count);
                        curF.alignment.subtract(cur.vel);
                        curF.alignment.scale(1 / (curS.maxspeed * 2));
                        curF.alignment.scale(2);
                        _a.add(curF.alignment);
                    }
                    if(count2 > 0) {
                        curF.cohesion.scale(1 / count2);
                        curF.cohesion.subtract(cur.pos);
                        curF.cohesion.scale(1 / curS.mydist);
                        curF.cohesion.scale(8);
                        _a.add(curF.cohesion);
                    }
                }
                if(this.isAlmostZero(_a) && count == 0) {
                    curF.rangle += this.sign(Math.random() - 0.5) * Math.PI / 36;
                    _a.addScaled(0.44 / Vec3Utils.getLength(cur.vel),cur.vel);
                    _a.x += 0.45 * Math.sin(curF.rangle);
                    _a.y += 0.45 * Math.cos(curF.rangle);
                }
                else curF.rangle = this.getAngle(_a);
                if(cur.pos.x < curS.minx) _a.x += 0.4;
                else if(cur.pos.x > curS.maxx) _a.x -= 0.4;
                if(cur.pos.y < curS.miny) _a.y += 0.4;
                else if(cur.pos.y > curS.maxy) _a.y -= 0.4;
                if(curS.turnAccelRatio > 0) {
                    _a.subtract(curF._aold);
                    var t : Number = _a.length();
                    if(t > 0.0001) _a.scale(curS.turnAccelRatio);
                    if(t >= curS.turnAccelRatio) _a.scale(curS.turnAccelRatio / t);
                    _a.add(curF._aold);
                }
                cur = cur.next;
            }
            cur = this.nodeList.head;
            while(cur != null) {
                curF = cur.f;
                curS = curF.settings;
                Vec3Utils.add(cur.vel,curF._a);
                Vec3Utils.scale(cur.vel,1. / 12);
                cur.rot.z = this.getAngle(cur.vel);
                Vec3Utils.add(cur.pos,cur.vel);
                Vec3Utils.scale(cur.vel,12.);
                var v : Number = Vec3Utils.getLength(cur.vel);
                if(v > curS.maxspeed) Vec3Utils.scale(cur.vel,curS.maxspeed / v);
                else if(v < curS.minspeed) Vec3Utils.scale(cur.vel,curS.minspeed / v);
                else Vec3Utils.scale(cur.vel,0.99);
                cur = cur.next;
            }
        }
        public override function addToEngine(engine : Engine) : void {
            this.nodeList = engine.getNodeList(FlockingNode);
        }
        protected var collision : Vec3;
        protected var mypos : Vec3;
        protected var hispos : Vec3;
        protected var dist : Vec3;
        protected var relV : Vec3;
        protected var relP : Vec3;
        protected var nodeList : NodeList;
        static protected var myr : Number = 2 / 3 * Math.PI;
        static protected var scalerSpeed : Number = 1. / 12;
    }
//}
//package {

    
    /*public*/ class Pos extends Vec3 {
        public function Pos(x : Number = 0,y : Number = 0,z : Number = 0) : void { 
            super(x,y,z);
        }
    }
//}
//package {

    /*public*/ class Flocking {
        public function Flocking() : void {
        }
        public function setup(flockSettings : FlockSettings) : Flocking {
            this.settings = flockSettings;
            this.rangle = Math.random() * 2 * Math.PI;
            this.minTime = 10.0 / 3;
            this.separation = new Vec3();
            this.alignment = new Vec3();
            this.cohesion = new Vec3();
            this._a = new Vec3();
            this._aold = new Vec3();
            return this;
        }
        public var settings : FlockSettings;
        public var rangle : Number;
        public var minTime : Number;
        public var angle : Number;
        public var _aold : Vec3;
        public var _a : Vec3;
        public var cohesion : Vec3;
        public var alignment : Vec3;
        public var separation : Vec3;
        static public function createFlockSettings(minDist : Number,senseDistance : Number,minx : Number = 0,miny : Number = 0,maxx2 : Number = 400,maxy2 : Number = 400,minspeed : Number = 8,maxspeed : Number = 32,turnAccelRatio : Number = 0) : FlockSettings {
            var me : FlockSettings = new FlockSettings();
            me.minspeed = minspeed;
            me.maxspeed = maxspeed;
            me.turnAccelRatio = turnAccelRatio;
            me.mydist = senseDistance;
            me.mydistSquared = senseDistance * senseDistance;
            me.mindistSquared = minDist * minDist;
            me.maxx = maxx2 - senseDistance;
            me.maxy = maxy2 - senseDistance;
            me.minx = senseDistance;
            me.miny = senseDistance;
            return me;
        }
    }
//}
//package {

    
    /*public*/ class Rot extends Vec3 {
        public function Rot(x : Number = 0,y : Number = 0,z : Number = 0) : void { 
            super(x,y,z);
        }
    }
//}
//package {

    
    /*public*/ class Vel extends Vec3 {
        public function Vel(x : Number = 0,y : Number = 0,z : Number = 0) : void { 
            super(x,y,z);
        }
    }
//}
//package {
    /*public*/ class FlockSettings {
        public function FlockSettings() : void {
        }
        public var turnAccelRatio : Number;
        public var minspeed : Number;
        public var maxspeed : Number;
        public var mydist : Number;
        public var mydistSquared : Number;
        public var mindistSquared : Number;
        public var miny : Number;
        public var minx : Number;
        public var maxy : Number;
        public var maxx : Number;
    }
//}


    import alternativa.engine3d.animation.AnimationClip;
    import alternativa.engine3d.animation.AnimationController;
    import alternativa.engine3d.animation.AnimationCouple;
    import alternativa.engine3d.objects.Joint;
    import alternativa.engine3d.objects.Skin;
    import alternativa.engine3d.alternativa3d;
    use namespace alternativa3d;
    
    /**
     * ...
     * @author Glenn Ko
     */
    class MechStance implements IAnimatable 
    {
        private var animManager:AnimationManager;
        private var anim_walk:AnimationClip;
        private var vel:Vel;
        private var controller:AnimationController;
        private var couple:AnimationCouple;
        private var _turretJoint:Joint;
        
        public function MechStance(animManager:AnimationManager, vel:Vel, jointList:Vector.<Joint>, randAnim:Boolean=false) 
        {
            this.animManager = animManager;
            this.vel = vel;
            var index:int = randAnim ? Math.random() * animManager.animClips.length : animManager.getAnimationIndexByName("jog");
            
            if (index < 0) index = 0;
            anim_walk = animManager.animClips[index];
            controller = new AnimationController();
            anim_walk.time = Math.random()*anim_walk.length;
            
            couple = new AnimationCouple();
            controller.root = couple;
            couple.left = anim_walk;
            couple.right = new AnimationClip();
            _turretJoint = findJointByName(jointList, "Bip01 Spine3");
            
            
            
        }
        
        
        
        private function findJointByName(joints:Vector.<Joint>, str:String):Joint {
            
            var i:int = joints.length;
            while (--i > -1) {
                if (joints[i].name === str) return joints[i];
            }
            return null;
        }
        
        /* INTERFACE systems.animation.IAnimatable */
        public static var RANGE:Number = 1/44;
        public function animate(time:Number):void 
        {
            var d:Number = Math.sqrt(vel.x * vel.x + vel.y * vel.y + vel.z * vel.z);
            couple.balance = 1 -  d  * RANGE * 1;
            controller.update();
        
        //    anim_walk.update(time, 1);
            //_turretJoint._rotationY += .05;
            //_turretJoint.transformChanged = true;
        }
        
    }

    import alternativa.engine3d.animation.AnimationClip;
    import alternativa.engine3d.animation.AnimationNotify;
    import alternativa.engine3d.animation.AnimationSwitcher;
    import alternativa.engine3d.animation.events.NotifyEvent;
    import alternativa.engine3d.animation.keys.Keyframe;
    import alternativa.engine3d.animation.keys.NumberKey;
    import alternativa.engine3d.animation.keys.NumberTrack;
    import alternativa.engine3d.animation.keys.Track;
    import alternativa.engine3d.animation.keys.TransformKey;
    import alternativa.engine3d.animation.keys.TransformTrack;
    import alternativa.engine3d.core.Object3D;
    import flash.geom.Matrix3D;
    import flash.geom.Vector3D;
    import flash.utils.Dictionary;
    import flash.utils.IDataInput;
    import flash.utils.IDataOutput;
    import flash.utils.IExternalizable;

    
    import alternativa.engine3d.alternativa3d;
    use namespace alternativa3d;
    
    /**
     * A model blueprint / switcher for animation state 
     * @author Glidias
     */
    class AnimationManager implements IExternalizable
    {
        public var animClips:Vector.<AnimationClip>;
        private var animGroups:Vector.<Vector.<int>>;    
        private var switcher:AnimationSwitcher;
        private var _fixed:Boolean;
        
        public function AnimationManager(animClips:Vector.<AnimationClip>=null, animGroups:Vector.<Vector.<int>>=null, fixed:Boolean=true, animEndLoops:Dictionary=null) 
        {
            animEndLoops = animEndLoops || new Dictionary();
            if (animClips != null) init(animClips, animGroups, fixed);
        }
        
        private function init(animClips:Vector.<AnimationClip>, animGroups:Vector.<Vector.<int>>=null, fixed:Boolean=true):void {
            this.animClips = animClips;
            this.animGroups = animGroups;
        
            // initSwitcher
            var len:int = animClips.length;
            switcher = new AnimationSwitcher();
            for (var i:int = 0; i < len; i++) {
                switcher.addAnimation(animClips[i]);
            }
            
            _fixed = fixed;
        }
        
        
        /* INTERFACE flash.utils.IExternalizable */
        
        public function writeExternal(output:IDataOutput):void 
        {
            output.writeBoolean( _fixed);
            
            
            var i:int;
            var len:int = animClips.length;  
            output.writeByte(len);
            for (i = 0; i < len; i++) {
                writeAnimationClip( animClips[i] , output);
            }
        
        
            output.writeBoolean( animGroups != null);
            if (animGroups != null) writeAnimationGroups(output);

        }
        

        private function writeAnimationGroups(output:IDataOutput):void {
            var len:int = animGroups.length;
            output.writeByte(len);
            for (var i:int = 0; i < len; i++) {
                var anims:Vector.<int> = animGroups[i];
                if (anims == null) {
                    output.writeByte(0);
                    continue;
                }
                var uLen:int = anims.length;
                output.writeByte(uLen);
                for (var u:int=0; u < uLen; u++) {
                    output.writeByte(anims[u]);
                }
            }
        }
        private function readAnimationGroups(input:IDataInput, fixed:Boolean):Vector.<Vector.<int>> {
            var len:int = input.readByte();
            var animGroups:Vector.<Vector.<int>> = new Vector.<Vector.<int>>(len, fixed);
            for (var i:int = 0; i < len; i++) {
                var uLen:int = input.readByte();
                if (uLen <= 0) continue;
                var anims:Vector.<int> = new Vector.<int>(uLen, fixed);
                animGroups[i] = anims;
                for (var u:int=0; u < uLen; u++) {
                    anims[u] = input.readByte();
                }
            }
            return animGroups;
        }
        
        public function readExternal(input:IDataInput):void 
        {
            var fixed:Boolean = input.readBoolean();
            
            var len:int = input.readByte();
            animClips =  new Vector.<AnimationClip>(len);
            for (var i:int = 0; i < len; i++) {
                animClips[i] = readAnimationClip(input);
            }
        
            animGroups = input.readBoolean() ? readAnimationGroups(input, fixed) : null;
        
            init(animClips, animGroups, fixed );
        }
        
        
        // Parse from XML
        
        public static function fromAnimationAndXML(animation:AnimationClip, animXML:XML, animFPS:int=0, tableLookup:Vector.<String>=null):AnimationManager {
            var animManager:AnimationManager;    
            var animList:XMLList = animXML..a;
            if (animFPS == 0) animFPS = animXML.@fps != undefined ? Number(animXML.@fps) || 24 : 24;
            var useAnimLoop:Boolean = animXML.@loop == "true" || animXML.@loop == "false" ? animXML.@loop == "true" : animation.loop;
            var len:int;
            var i:int;

            var animations:Vector.<AnimationClip> = new Vector.<AnimationClip>();
            
            len = animList.length()
            for (i = 0; i < len; i++) {
                var xml:XML = animList[i];
                var sa:Array = xml.@f.split("-");
                var sa_1:Number = Number(sa[0]);
                var sa_2:Number = Number(sa[1]);
                var newAnim:AnimationClip = animation.slice( (sa_1 <= 1 ? 0 : sa_1) / animFPS, sa_2 / animFPS);
                var notifyList:XMLList = xml.n;
                var uLen:int = notifyList.length();
                for (var u:int = 0; u < uLen; u++) {
                    var uXML:XML = notifyList[u];
                    newAnim.addNotify((Number(uXML)-sa_1)/animFPS , uXML.@id);
                }
            //    var useFPS:Number = xml.@fps != undefined ? Number(xml.@fps) : animFPS;
                newAnim.speed = 1;// Math.round(newAnim.length * animFPS) / useFPS; 
                newAnim.name = xml.@id;
                
                newAnim.loop = xml.@loop == "true" || xml.@loop == "false" ? xml.@loop == "true" : useAnimLoop;
                
                //if (newAnim.loop && uLen > 0) new AnimEndLoop(newAnim);  // todo: determine context from which..
                
                newAnim.name = animList[i].@id;
                animations[i] = newAnim;    
            }
            
            animManager = new AnimationManager(animations, null, true);
            animManager.setupAnimGroups(animXML, tableLookup);
            return animManager;
        }
        
        public function cloneAnimation(toClone:AnimationClip):AnimationClip {
            var newAnim:AnimationClip = toClone.clone();
            newAnim.loop = toClone.loop;
            newAnim.speed = toClone.speed;
            newAnim.time = 0;
            return newAnim;
        }
        
        
        public function switchAnim(animation:AnimationClip, time:Number) : void {
            _currentAnim = animation;
            switcher.activate(animation, time);
        }
        
        public function switchAndRestartAnim(animation:AnimationClip, time:Number):void {
            _currentAnim = animation;
            animation.time = 0;
            switcher.activate(animation, time);
        }
        
        
        public function setupAnimGroups(xml:XML, tableLookup:Vector.<String>=null):void {
            var xmlList:XMLList = xml..a.(hasOwnProperty("@g"));
        
            var len:int = xmlList.length();
            if (len == 0) return;
            
            
            var dict:Dictionary = new Dictionary();
            var i:int;
    
            animGroups = tableLookup != null ? new Vector.<Vector.<int>>(tableLookup.length) : new Vector.<Vector.<int>>();
            var intList:Vector.<int>;
            for (i = 0; i < len; i++) {
                xml = xmlList[i];
                var prop:String = xml.@g != undefined ? xml.@g : null;
                if (prop == null) continue;
                intList = dict[prop];
                if (intList == null) {
                    intList = new Vector.<int>();
                    dict[prop] = intList;
                    if (tableLookup == null) animGroups.push(intList)
                    else animGroups[tableLookup.indexOf(prop)] = intList;
                }
                intList.push(getAnimationIndexByName(xml.@id));
            }
            
            len = animGroups.length;
            for (i = 0; i < len; i++ ) {
                intList = animGroups[i];
                if (intList == null) {
                    //animGroups[i] = intList = new <int>[0];
                }
                else intList.fixed = _fixed;
            }
            
            animGroups.fixed = _fixed;
        }
        

        private var _alreadySetup:Boolean = false;
        
        
        public function setupFor(target:Object):void {
            if (_alreadySetup) return;
            _alreadySetup = true;
            var len:int = animClips.length;

            for (var i:int = 0; i < len; i++) {
                var oldAnim:AnimationClip =  animClips[i];
                
                oldAnim.attach(target, true);
            }
        }
        
        public function cloneFor(target:Object):AnimationManager {
            var len:int = animClips.length;
            var newClips:Vector.<AnimationClip> = new Vector.<AnimationClip>(len);
            var dictEndLoops:Dictionary = new Dictionary();
            var newC:AnimationClip;
            for (var i:int = 0; i < len; i++) {
                var oldAnim:AnimationClip =  animClips[i];
                newClips[i] = newC = oldAnim.clone();
                //if (newC.loop != oldAnim.loop) throw new Error("LOOP MISMATCH!");
                newC.loop = oldAnim.loop;
                //if (newC.speed != oldAnim.speed) throw new Error("SPEED MISMATCH!");
                newC.speed = oldAnim.speed;
                var chkNotifiers:Vector.<AnimationNotify> = oldAnim.notifiers;
                var nLen:int = chkNotifiers.length;
                for (var n:int = 0; n < nLen; n++) {
                    var notifier:AnimationNotify = chkNotifiers[n];
        
                    newC.addNotify( notifier.time, notifier.name);
                }
                if (newC.loop && nLen > 0 ) dictEndLoops[newC.name] = new AnimEndLoop(newC);
                newC.time = 0;
                //newC.speed
                newC.attach(target, true);
            }
            return new AnimationManager(newClips, animGroups, _fixed, dictEndLoops);
        }
        
        
        
        
        public static var MANAGERS:Dictionary = new Dictionary();
    
        
        public var _currentAnim:AnimationClip;
        
        public static function getAnimManagerByKey(key:*):AnimationManager {
            return MANAGERS[key] || (new AnimationManager(new <AnimationClip>[],null,false));
        }
        public static function registerAnimManager(key:*, rootInstance:AnimationManager):void {
            MANAGERS[key] = rootInstance;
        }
        
        /**
         * Plays a certain random animation from a group category
         * @param    index    Category index
         * @param    time    The time to transition to animation
         * @return    True if animation is found, or False if no animation found
         */
        public function playGroup(index:int, time:Number):AnimationClip {
            if (animGroups == null) return null;
            var anim:AnimationClip = getAnimationFromGroup(index);
            if (anim == null) return null;
            _currentAnim = anim;
            switcher.activate(anim , time);
            return anim;
        }
        
        public function getAnimationFromGroup(index:int):AnimationClip {
            //if (animGroups == null) throw new Error("IS NULL!");
            var listAnims:Vector.<int> = animGroups[index];
            return listAnims!= null ? animClips[ listAnims[int(Math.random() * listAnims.length)] ] : null;
        }        
        
        public function getAnimationGroup(index:int):Vector.<int> {
            if (animGroups == null || (index >=animGroups.length)) return null;
            return animGroups[index];
        }
        
        public function getAnimationsByGroup(index:int):Vector.<AnimationClip> {
            var vec:Vector.<AnimationClip> = new Vector.<AnimationClip>();
            var animGroups:Vector.<int> =  getAnimationGroup(index);
            if (animGroups == null) return vec;
            var len:int = animGroups.length;
            for (var i:int = i; i < len; i++) {
                vec[i] = animClips[animGroups[i]];
            }
            vec.fixed = _fixed;
            return vec;
        }

        
        public function getAnimationByName(name:String):AnimationClip {
            var i:int = animClips.length; 
            while (--i > -1) {
                var animClip:AnimationClip = animClips[i];
                if (animClip.name === name) return animClip;
            }
            throw new Error("FAILED TO GET ANIMATION!"+name);
            return null;
        }
        
        public function getAnimationIndexByName(name:String):int {
            var i:int = animClips.length;
            while (--i > -1) {
                if (animClips[i].name === name) return i;
            }
            return -1;
        }
        
        public function getSwitcher():AnimationSwitcher 
        {
            return switcher;
        }
        
        public function get fixed():Boolean 
        {
            return _fixed;
        }
        
        public function get currentAnim():AnimationClip 
        {
            return _currentAnim;
        }
        
        
        
        // --Serialization helpers
        
        private function writeNotifiers(vec:Vector.<AnimationNotify>, output:IDataOutput):void {
            var len:int = vec.length;
            output.writeByte(len);
            for (var i:int = 0; i < len; i++) {
                var anim:AnimationNotify = vec[i];
                output.writeFloat(anim.time);
                output.writeObject(anim.name != null ? anim.name : "0");
            };
        }
        
        private function readNotifiers(input:IDataInput, clip:AnimationClip):void {
            var len:int = input.readByte();
            if (len == 0 ) return;
            for (var i:int = 0; i < len; i++) {
                var time:Number = input.readFloat();
                clip.addNotify(time, input.readObject() );
            };
            if (clip.loop) new AnimEndLoop(clip);
        }
        
        private function writeAnimationClip(anim:AnimationClip, output:IDataOutput):void {
                var uLen:int;
                
                output.writeObject(anim.name);
                output.writeBoolean(anim.loop);    
                //output.writeFloat(anim.length);  // speed
            
                
                uLen = anim.numTracks;
                output.writeShort(uLen);
                for (var u:int = 0; u < uLen; u++) {
                    var track:Track = anim.getTrackAt(u);  // is't the case, could be NUmberTrack or various other trakc types
                    output.writeBoolean( track is TransformTrack );
                    
                    if (track is TransformTrack) {
                        writeTransformTrack(track as TransformTrack, output);    
                    }
                    else if (track is NumberTrack) {
                        writeNumberTrack(track as NumberTrack, output);
                    }
                    else  {
                        throw new Error("Could not resolve track type!");
                    }
                }
                
                var notifiers:Vector.<AnimationNotify> = anim.notifiers;
                if (notifiers != null) {
                    writeNotifiers(notifiers, output);
                }
                else output.writeByte(0);
        }    
        
        
        private function readAnimationClip(input:IDataInput):AnimationClip {
            var anim:AnimationClip;
            anim =  new AnimationClip( input.readObject() );
            anim.loop = input.readBoolean();
            //anim.length = input.readFloat();  // speed
            
            
            var uLen:int = input.readShort();
            for (var u:int = 0; u < uLen; u++) {
                anim.addTrack( input.readBoolean() ? readTransformTrack(input) : readNumberTrack(input) );
            }    
            
            readNotifiers(input, anim);
            
            return anim;
        }
        
        private function writeNumberTrack(numberTrack:NumberTrack, output:IDataOutput):void 
        {
            output.writeObject( numberTrack.object );
            output.writeObject( numberTrack.property );
            var key:NumberKey;
            var count:int = 0;
            for (key = numberTrack.keyList; key != null; key = key.next) {
                count++;
            }
            output.writeShort(count);
        
            for ( key = numberTrack.keyList; key != null; key = key.next) {
                output.writeFloat(key._time);
                output.writeFloat(key._value);
            }
        }
        
        private function readNumberTrack(input:IDataInput):NumberTrack {
            var track:NumberTrack = new NumberTrack(input.readObject(), input.readObject() );
            var len:int = input.readShort();
            for (var i:int = 0; i < len; i++) {
                track.addKey(input.readFloat(), input.readFloat() );
            }
            return track;
        }
        
        private function writeTransformTrack(transformTrack:TransformTrack, output:IDataOutput):void 
        {
            
            output.writeObject(transformTrack.object);
            
            var keys:Vector.<Keyframe> = transformTrack.keys;
            if (keys == null) throw new Error("COuld not find keys!");
            var len:int = keys.length;
            output.writeShort(len);
            
            for (var i:int = 0; i < len; i++) {
                var tKey:TransformKey = keys[i] as TransformKey;
                if (tKey == null) throw new Error("COudl not find TransformKey:" + tKey);
                var matrix3D:Matrix3D = tKey.value as Matrix3D;
                if (matrix3D == null) throw new Error("Could not find matrix!");
                
                output.writeFloat( tKey._time);
                
                //writeMatrix3D( matrix3D, output); 
                writeComponentsFromMatrix3D(matrix3D, output);
                //writeKeyComponents(tKey, output);
            }
        }
        
        private function writeKeyComponents(transformKey:TransformKey, output:IDataOutput):void {
            output.writeFloat(transformKey.x);
            output.writeFloat(transformKey.y);
            output.writeFloat(transformKey.z);
            output.writeFloat(transformKey.rotation.x);
            output.writeFloat(transformKey.rotation.y);
            output.writeFloat(transformKey.rotation.z);
        }
        
        private function writeMatrix3D(matrix:Matrix3D, output:IDataOutput):void {
            var data:Vector.<Number> = matrix.rawData;
            output.writeFloat(data[0]);
            output.writeFloat(data[1]);
            output.writeFloat(data[2]);
            output.writeFloat(data[3]);
            output.writeFloat(data[4]);
            output.writeFloat(data[5]);
            output.writeFloat(data[6]);
            output.writeFloat(data[7]);
            output.writeFloat(data[8]);
            output.writeFloat(data[9]);
            output.writeFloat(data[10]);
            output.writeFloat(data[11]);
            output.writeFloat(data[12]);
            output.writeFloat(data[13]);
            output.writeFloat(data[14]);
            output.writeFloat(data[15]);
        }
        
        public function writeComponentsFromMatrix3D(matrix:Matrix3D, output:IDataOutput):void {
            // hmm.. may need to transpose.
            
            var vec:Vector.<Vector3D> = matrix.decompose();
            var v:Vector3D;
            v = vec[0];
            output.writeFloat(v.x);
            output.writeFloat(v.y);
            output.writeFloat(v.z);
            
            v = vec[1];
            output.writeFloat(v.x);
            output.writeFloat(v.y);
            output.writeFloat(v.z);
        }
        
        public function getAnimGroups():Vector.<Vector.<int>> 
        {
            return animGroups;
        }
        
        
        
        private function readMatrix3D(input:IDataInput):Matrix3D {
            var data:Vector.<Number> = new Vector.<Number>(16, true);
            data[0] = input.readFloat();
            data[1] = input.readFloat();
            data[2] = input.readFloat();
            data[3] = input.readFloat();
            data[4] = input.readFloat();
            data[5] = input.readFloat();
            data[6] = input.readFloat();
            data[7] = input.readFloat();
            data[8] = input.readFloat();
            data[9] = input.readFloat();
            data[10] = input.readFloat();
            data[11] = input.readFloat();
            data[12] = input.readFloat();
            data[13] = input.readFloat();
            data[14] = input.readFloat();
            data[15] = input.readFloat();
            return new Matrix3D(data);
        }
        
        private function readTransformTrack(input:IDataInput):TransformTrack {
            var track:TransformTrack = new TransformTrack(input.readObject());
            var len:int = input.readShort();
            for (var i:int = 0; i < len; i++) {
                //track.addKey(input.readFloat(), readMatrix3D(input)  );
                track.addKeyComponents(input.readFloat(), input.readFloat(), input.readFloat(), input.readFloat(), input.readFloat(), input.readFloat(), input.readFloat());
            }
            return track;
        }
        
        
    }


    import alternativa.engine3d.animation.AnimationClip;
    import alternativa.engine3d.animation.AnimationNotify;
    import alternativa.engine3d.animation.events.NotifyEvent;
    import flash.events.Event;
    /**
     * ...
     * @author Glidias
     */
    class AnimEndLoop 
    {
        private var anim:AnimationClip;
        private var notifier:AnimationNotify;
        
        public function AnimEndLoop(anim:AnimationClip) 
        {
            this.anim = anim;
            anim.loop = false;
            notifier = anim.addNotifyAtEnd();
            notifier.addEventListener(NotifyEvent.NOTIFY, resetAnimTime);
        }
        
        private function resetAnimTime(e:NotifyEvent):void {
            anim.time = 0;
        }
        
        public function destroy():void {
            notifier.removeEventListener(NotifyEvent.NOTIFY, resetAnimTime);
        }
        
        
        
    }

import alternativa.engine3d.alternativa3d;
    import alternativa.engine3d.core.Camera3D;
    import alternativa.engine3d.core.DrawUnit;
    import alternativa.engine3d.core.Light3D;
    import alternativa.engine3d.core.Object3D;
    import alternativa.engine3d.core.VertexAttributes;
    import alternativa.engine3d.materials.compiler.Linker;
    import alternativa.engine3d.materials.compiler.Procedure;
    import alternativa.engine3d.materials.compiler.VariableType;
    import flash.utils.ByteArray;
    import flash.utils.Dictionary;
    import flash.utils.Endian;
    use namespace alternativa3d;
    /**
     * ...
     * @author Glenn Ko
     */
     class SkinClonesContainer extends Skin
    {
        public static var CLONE_CLASS:Class = SkinClone;
        alternativa3d var cloneClass:Class;
        
        public static const JOINTS_PER_SURFACE:uint = 40;
        private var jointsPerSurface:uint;
        private var _minClonesPerBatch:int;
        private var _numJoints:int;

        alternativa3d var clones:Vector.<SkinClone> = new Vector.<SkinClone>();
        alternativa3d var visibleClones:Vector.<SkinClone>;
        alternativa3d var numClones:int = 0;
        
        
        
        private static var _transformProcedures:Dictionary = new Dictionary();
        private var _curCloneIndex:int;
        private var _curBatchCount:int;
        private var outputSurface:Surface;
        private var flags:int;
        private var _sample:Skin;
        private var protoNumTriangles:int; // Note this will be deciated to surfaceNumTriangles[] in the future
        public var objectRenderPriority:int = -1;
        
        public static const FLAG_GLOBAL_PROCEDURE:int = 1;
        
        // Cashing of procedures on number of influence
        //private static var _deltaTransformProcedures:Vector.<Procedure> = new Vector.<Procedure>(9);
        
        public function SkinClonesContainer(sample:Skin, jointsPerSurface:uint = 0, cloneClass:Class = null, flags:int=0) 
        {
            this.flags = flags;
            
            this.cloneClass = cloneClass || CLONE_CLASS;
            this.jointsPerSurface = jointsPerSurface != 0 ? jointsPerSurface : JOINTS_PER_SURFACE;
            
            super(sample.maxInfluences);
            this.clonePropertiesFrom(sample);
            sample.geometry = null;
            
            _sample = sample;
            
            _x = 0;
            _y = 0;
            _z = 0;
            _rotationX = 0;
            _rotationY = 0;
            _rotationZ = 0;
            _scaleX = 1;
            _scaleY = 1;
            _scaleZ = 1;

            
            if (numSurfaces > 1) throw new Error("Sorry, we don't support >1 material surface for SkinClones at the moment!!");
            
            _numJoints = surfaceJoints[0].length;
            
            outputSurface = new Surface();
            outputSurface.object = this;
            outputSurface.indexBegin = 0;
            outputSurface.material = _surfaces[0].material;
            
            duplicateGeometry();
            boundBox = null;
            
        
            
        }
        
        
        
        private function duplicateGeometry():void 
        {
            ///*
            var totalAllowedFloored:int =  jointsPerSurface / _numJoints;
            if (totalAllowedFloored <= 0) totalAllowedFloored = 1;
            _minClonesPerBatch = totalAllowedFloored;
            setupDuplicateGeometry(totalAllowedFloored);
            //*/
            
            /*
            var totalAllowedCeil:int =  Math.ceil( jointsPerSurface / _numJoints);
            _minClonesPerBatch = totalAllowedCeil;
            setupDuplicateGeometry(totalAllowedCeil);
            */
        }
        
    
        
        
        private function setupDuplicateGeometry(total:int):void {
            if (total <= 1) return;
            
            
            ///*
            var cap:int = total * _numJoints;
            
            if (cap > jointsPerSurface) {
                cap = jointsPerSurface;
            }
            //*/
            
            protoNumTriangles = geometry.numTriangles;
            
        
              // stick to 1 global transform procedure based off jointsPerSurface setting ? 
            transformProcedure = calculateTransformProcedure(maxInfluences, (flags & FLAG_GLOBAL_PROCEDURE ? jointsPerSurface : cap) );
        //    deltaTransformProcedure = calculateDeltaTransformProcedure(maxInfluences);
            
        //    /*
            var bytes:ByteArray;
            //throw new Error(geometry.getAttributeValues(VertexAttributes.POSITION))
            // get samples
        //    var protoJointIndices:Vector.<Number> = geometry.getAttributeValues(ATTRIBUTE);
            var protoNumVertices:int = geometry.numVertices;
            
            
            //_numVertices = protoNumVertices;
            var protoByteArrayStreams:Vector.<ByteArray> = new Vector.<ByteArray>();
            var len:int = geometry._vertexStreams.length;
    
            // copy all geometry bytearray data samples for all vertex streams
            for (var i:int = 0; i < len; i++) {
                protoByteArrayStreams[i] = bytes = new ByteArray();
                bytes.endian = Endian.LITTLE_ENDIAN;
                for (var u:int = 0; u < total; u++) {
                    bytes.writeBytes( geometry._vertexStreams[i].data );
                }
            }
            
            // TODO: Test shouldn't i start at 1 instead....because geometry is already filled?
            // paste geometry data for all the vertex streams
            for (i = 0; i < len; i++) {
                bytes = protoByteArrayStreams[i];
                var data:ByteArray = geometry._vertexStreams[i].data;
        
                for (u = 1; u < total; u++) {
                    data.position = data.length;
                    data.writeBytes(bytes, data.length);
                }
            }
            
            
            
            // set number of vertices to match new vertex data size
            geometry._numVertices = protoNumVertices * total;
            
            
            
            var indices:Vector.<uint> = geometry.indices;
            // duplicate indices with offsets
            len = indices.length;
            
            for (i = 1; i < total; i++) {
                var indexOffset:int = i * protoNumVertices;
                for (u = 0; u < len; u++) {
                    indices.push(indexOffset+ indices[u]);
                }
            }
            geometry.indices = indices;
    
            // paste joint attribute values with offsets
        //    /*
            //len = maxInfluences;
            for (var k:int = 0; k < maxInfluences; k += 2) {
                
                /*
                if (!geometry.hasAttribute(VertexAttributes.JOINTS[k>>1])) {
                //    throw new Error(k);
                    break;
                }
                */
                var jointIndices:Vector.<Number> = geometry.getAttributeValues(VertexAttributes.JOINTS[k>>1]);
                var stride:int = VertexAttributes.getAttributeStride(VertexAttributes.JOINTS[k>>1]);
            //throw new Error(jointIndices);
        
                ///*
                len = protoNumVertices * stride;
                var addDupMult:Number =  _numJoints * 3;
                var duplicateMultiplier:Number =addDupMult;
                var totalLen:int = jointIndices.length;
                for (i = len; i < totalLen; i += len) {
                    for (u = i; u < i+len; u+=stride) {
                        jointIndices[u] += duplicateMultiplier;
                        jointIndices[u+2] += duplicateMultiplier;
                    }
                    duplicateMultiplier+=  addDupMult;
                }
                //*/
                 geometry.setAttributeValues(VertexAttributes.JOINTS[k>>1], jointIndices);
                 
                // throw new Error( getJointIndices( jointIndices.slice( jointIndices.length / 4, jointIndices.length/4+jointIndices.length/4) ,  -10) );
            }
        //    */
        
                //throw new Error(  geometry.getAttributeValues(VertexAttributes.POSITION).slice(protoNumVertices * 3, protoNumVertices * 3 + protoNumVertices*3) );
        }
        
        private function getJointIndices(values:Vector.<Number>, offset:int=0):Vector.<int> {
            var stuff:Vector.<int>  = new Vector.<int>();
            var len:int = values.length;
            for (var i:int = 0; i < len; i += 4) {
                stuff.push( values[i] / 3 + offset);
            }
            
            return stuff;
        }
        
        public function createClone():SkinClone {
            var cloneItem:SkinClone = new cloneClass();
            cloneItem.root = new Joint();
            

            
            cloneItem.root._parent = this;
            cloneItem.index = -1;
            
            var skin:Skin = _sample.clone() as Skin;  // lazy method to grab new set of surfaceJoints, original cloned skin is wasted away    
            
    
            var skinJoint:Joint = new Joint();
             skinJoint.x = skin._x;
            skinJoint.y = skin._y;
           skinJoint.z = skin._z;
           
            skinJoint._scaleX = skin._scaleX;
            skinJoint._scaleY = skin._scaleY;
           skinJoint._scaleZ = skin._scaleZ;
           
           
            skinJoint._rotationX = skin._rotationX;
            skinJoint._rotationY = skin._rotationY;
           skinJoint._rotationZ = skin._rotationZ;
           skinJoint.transformChanged = true;
           
         //  throw new Error(skinJoint.rotationZ);
           
           cloneItem.root.addChild(skinJoint);
           
           
            var c:Object3D;
            for (c = skin.childrenList; c != null; c = c.next) {       
                skinJoint.addChild(c);
            }
            
            
            cloneItem.renderedJoints = skin.surfaceJoints[0];
            return cloneItem;
        }
        
        
    
        
        
        public function addClone(cloneItem:SkinClone):SkinClone {
            //if (cloneItem.index >= 0) throw new Error("Clone item seems to already belong to a container or wasn't freshly created/removed!!");  
            
            cloneItem.index = numClones;
            clones[numClones++] = cloneItem;
            return cloneItem;
        }
        
        /*
        public function addCloneWithCuller(cloneItem:SkinClone):void {
            (culler is IMeshSetClonesContainer) ? (culler as IMeshSetClonesContainer).addClone(cloneItem) : addClone(cloneItem);
        }
        
        public function removeCloneWithCuller(cloneItem:SkinClone):void {
            (culler is IMeshSetClonesContainer) ? (culler as IMeshSetClonesContainer).removeClone(cloneItem) : removeClone(cloneItem);
        }
        */
        
        public function removeClone(cloneItem:SkinClone):void {
        //    if (cloneItem.index < 0) throw new Error("Clone item seems to already be removed!");
            numClones--;
            //if (clones[cloneItem.index] !== cloneItem) throw new Error("Mismatch! " + clones[cloneItem.index].index + ", " + cloneItem.index);
            var tail:SkinClone = clones[numClones];
             clones[numClones] = null;
            if (tail!=cloneItem) {  // popback
                clones[cloneItem.index] =   tail;  
                tail.index = cloneItem.index;
            }
            cloneItem.index = -1;
        }
        

        /*  // rip from MeshSetClonesContainer,  to edit for SkinClonesContainer
        alternativa3d override function calculateVisibility(camera:Camera3D):void {
            super.alternativa3d::calculateVisibility(camera);
            numVisibleClones = culler != null ? culler.cull(numClones, clones, visibleClonesCollection, camera, this) : numClones;
            visibleClones = culler != null ? visibleClonesCollection : clones;
            var i:int = numVisibleClones;
            while (--i > -1) {
                var root:Object3D = visibleClones[i].root;
                if (root.transformChanged) root.composeTransforms();
                
                if (root._parent == null) root.localToGlobalTransform.copy(root.transform);
                else {
                    if (root._parent.transformChanged) root._parent.composeTransforms();
                    root.localToGlobalTransform.combine(root._parent.transform, root.transform);
                }
                
                calculateMeshesTransforms(root);
            }
        }
        */
        
        
        
        
        
        
        override alternativa3d function setTransformConstants(drawUnit:DrawUnit, surface:Surface, vertexShader:Linker, camera:Camera3D):void {
            var i:int, count:int;
            for (i = 0; i < maxInfluences; i += 2) {
                var attribute:int = VertexAttributes.JOINTS[i >> 1];
                drawUnit.setVertexBufferAt(vertexShader.getVariableIndex("joint" + i.toString()), geometry.getVertexBuffer(attribute), geometry._attributesOffsets[attribute], VertexAttributes.FORMATS[attribute]);
            }

            
            var limit:int = _curCloneIndex + _curBatchCount;
        
            count = 0;
        //    var triCount:int = 0;
            for (i = _curCloneIndex; i < limit; i++) {
                var joints:Vector.<Joint> = visibleClones[i].renderedJoints;
                var jointsLen:int = joints.length;
                var baseI:int = count * _numJoints * 3;
                for (var j:int = 0; j < jointsLen; j++) {
                    var joint:Joint = joints[j];            
                    drawUnit.setVertexConstantsFromTransform(baseI+j*3 , joint.jointTransform);
            
                }
                count++;
                //triCount += protoNumTriangles;
            }
            //        surface.numTriangles = triCount;
            
        }
    
        
        /**
         * @private
         */
        override alternativa3d function collectDraws(camera:Camera3D, lights:Vector.<Light3D>, lightsLength:int, useShadow:Boolean):void {
            if (geometry == null) return;

            
            //// Calculate joints matrices  //  this could already done in calculateVisibility?  .. later on when implementing ICuller support for clones
            /*
            for (var child:Object3D = childrenList; child != null; child = child.next) {
                if (child.transformChanged) child.composeTransforms();
                // Write transformToSkin matrix to localToGlobalTransform property
                child.localToGlobalTransform.copy(child.transform);
                if (child is Joint) {
                    Joint(child).calculateTransform();
                }
                calculateJointsTransforms(child);
            }
            */
            
            
            var totalClones:int = numClones; //numVisibleClones;
            visibleClones = clones;
        
            if (totalClones == 0) return;
            
            var minClonesPerBatch:int = _minClonesPerBatch;
        
        
            
            var i:int = totalClones;
            
            while (--i > -1) {  // later this can be transfered to calculateVisibility phase for pre-culling
                var root:Joint = clones[i].root;
                if (root.transformChanged) root.composeTransforms();
                root.localToGlobalTransform.copy(root.transform);
                root.calculateTransform();
                calculateJointsTransforms(root);
            }
            
            
            //  Now only support 1 surface because usually this is the common case for batching skins anyway
            //transformProcedure = surfaceTransformProcedures[0];  // already pre-calculated earlier as highest
            //deltaTransformProcedure = surfaceDeltaTransformProcedures[0];
        //    throw new Error(deltaTransformProcedure);
        
            var surface:Surface = _surfaces[0];
            
            //for (i = 0; i < _surfacesLength; i++) {
            //var surface:Surface = _surfaces[i];
            
        
                
                // Mouse events (i dun need this so i comment i taway)
                //if (listening) camera.view.addSurfaceToMouseEvents(surface, geometry, transformProcedure);
                
                
                for (var c:int = 0; c < totalClones; c += minClonesPerBatch) {
                    //count++;
                    
                
                    
                    _curCloneIndex = c;
                    
                    
                    _curBatchCount = totalClones - c;
    
                    _curBatchCount = _curBatchCount > minClonesPerBatch ? minClonesPerBatch : _curBatchCount;
                    //if (_curBatchCount == 0) throw new Error("AWTAW");
                    outputSurface.numTriangles = surface.numTriangles *_curBatchCount;  // surface.numTriangles * _curBatchCount - lastNumAddTriangles + addNumTriangles;
            
                    outputSurface.material.collectDraws(camera, outputSurface, geometry, lights, lightsLength, useShadow, objectRenderPriority);
                    //    traceStr += "\n"+  (surfaceMeshesLen * _curBatchCount-_offsetNumMeshes) + "," + addNumMeshes +  " , " + _offsetNumMeshes + ": "+ _curCloneIndex + ", "+_curBatchCount + " | "+outputSurface.indexBegin + " + "+outputSurface.numTriangles + ", "+surface.numTriangles + " >> " +addNumTriangles;
        
                    /*
                    lastNumAddTriangles = addNumTriangles;
                    spillOverMeshes = gotRemainder  ? surfaceMeshesLen - addNumMeshes : 0;
                    _offsetNumMeshes = addNumMeshes;
                    */
                    
                    // Uncomment this if you relying on mouse events!
                    //    if (listening) camera.view.addSurfaceToMouseEvents(outputSurface, geometry, transformProcedure);
                }
                
                
                
            //}
        }
        
        
        
        // duplicate from skin.as
        private function calculateTransformProcedure(maxInfluences:int, numJoints:int):Procedure {
            var res:Procedure = _transformProcedures[maxInfluences | (numJoints << 16)];
            if (res != null) return res;
            res = _transformProcedures[maxInfluences | (numJoints << 16)] = new Procedure(null, "SkinTransformProcedure");
            var array:Array = [];
            var j:int = 0;
            for (var i:int = 0; i < maxInfluences; i ++) {
                var joint:int = int(i/2);
                if (i%2 == 0) {
                    if (i == 0) {
                        array[j++] = "m34 t0.xyz, i0, c[a" + joint + ".x]";
                        array[j++] = "mul o0, t0.xyz, a" + joint + ".y";
                    } else {
                        array[j++] = "m34 t0.xyz, i0, c[a" + joint + ".x]";
                        array[j++] = "mul t0.xyz, t0.xyz, a" + joint + ".y";
                        array[j++] = "add o0, o0, t0.xyz";
                    }
                } else {
                    array[j++] = "m34 t0.xyz, i0, c[a" + joint + ".z]";
                    array[j++] = "mul t0.xyz, t0.xyz, a" + joint + ".w";
                    array[j++] = "add o0, o0, t0.xyz";
                }
            }
            array[j++] = "mov o0.w, i0.w";
            res.compileFromArray(array);
            res.assignConstantsArray(numJoints*3 );
            for (i = 0; i < maxInfluences; i += 2) {
                res.assignVariableName(VariableType.ATTRIBUTE, int(i/2), "joint" + i);
            }
            return res;
        }
        
        
        /*
        private function calculateDeltaTransformProcedure(maxInfluences:int):Procedure {
            var res:Procedure = _deltaTransformProcedures[maxInfluences];
            if (res != null) return res;
            res = new Procedure(null, "SkinDeltaTransformProcedure");
            _deltaTransformProcedures[maxInfluences] = res;
            var array:Array = [];
            var j:int = 0;
            for (var i:int = 0; i < maxInfluences; i ++) {
                var joint:int = int(i/2);
                if (i%2 == 0) {
                    if (i == 0) {
                        array[j++] = "m33 t0.xyz, i0, c[a" + joint + ".x]";
                        array[j++] = "mul o0, t0.xyz, a" + joint + ".y";
                    } else {
                        array[j++] = "m33 t0.xyz, i0, c[a" + joint + ".x]";
                        array[j++] = "mul t0.xyz, t0.xyz, a" + joint + ".y";
                        array[j++] = "add o0, o0, t0.xyz";
                    }
                } else {
                    array[j++] = "m33 t0.xyz, i0, c[a" + joint + ".z]";
                    array[j++] = "mul t0.xyz, t0.xyz, a" + joint + ".w";
                    array[j++] = "add o0, o0, t0.xyz";
                }
            }
            array[j++] = "mov o0.w, i0.w";
            array[j++] = "nrm o0.xyz, o0.xyz";
            res.compileFromArray(array);
            for (i = 0; i < maxInfluences; i += 2) {
                res.assignVariableName(VariableType.ATTRIBUTE, int(i/2), "joint" + i);
            }
            return res;
        }
        */

    
        
    }

    
    import alternativa.engine3d.alternativa3d;
    import alternativa.engine3d.core.Object3D;
    use namespace alternativa3d;
    /**
     * ...
     * @author Glenn Ko
     */
     class SkinClone 
    {
        public var root:Joint;
        public var renderedJoints:Vector.<Joint>;
        alternativa3d var index:int;
        
        public function SkinClone() 
        {
            
        }
        
    }
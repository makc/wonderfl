package {
    import away3d.materials.methods.OutlineMethod;
    import away3d.materials.methods.CelDiffuseMethod;
    import away3d.materials.methods.CelSpecularMethod;
    import away3d.lights.shadowmaps.NearDirectionalShadowMapper;
    import away3d.materials.lightpickers.StaticLightPicker;
    import away3d.materials.methods.FilteredShadowMapMethod;
    import away3d.materials.methods.NearShadowMapMethod;
    import away3d.materials.methods.FogMethod;
    import away3d.core.managers.Stage3DManager;
    import away3d.core.managers.Stage3DProxy;
    import away3d.filters.BloomFilter3D;
    import away3d.events.Stage3DEvent;
    import away3d.lights.DirectionalLight;
    import away3d.lights.PointLight;
    import away3d.cameras.Camera3D;
    import away3d.cameras.lenses.PerspectiveLens;
    import away3d.primitives.SphereGeometry;
    import away3d.primitives.CubeGeometry;
    import away3d.materials.ColorMaterial;
    import away3d.core.base.Geometry;
    import away3d.containers.Scene3D;
    import away3d.containers.View3D;
    import away3d.entities.Mesh;
    import away3d.filters.*
    import starling.core.Starling;
    import flash.events.Event;
    import flash.geom.Vector3D;
    import flash.display.Bitmap;
    import flash.display.Sprite;
    import flash.display.BitmapData;
    import flash.geom.ColorTransform;
    import flash.system.System;
    import com.greensock.TweenNano;
    import com.greensock.easing.Quad;
    
    public class Earth extends flash.display.Sprite {
        private var _view:View3D;
        private var _scene:Scene3D;
        private var _manager:Stage3DManager;
        private var _stage3DProxy:Stage3DProxy;
        // Objects
        private var _sphere:Mesh;
        private var _axe:Mesh;
        // Lights
        private var _sun:DirectionalLight;
        private var _moon:PointLight;
        private var _lightPicker:StaticLightPicker;
        // Methods
        private var _shadow:NearShadowMapMethod;
        private var _fog:FogMethod;
        // StarLing test
        private var _starling:Starling;
        // ColorTools
        private var startColor:ColorTransform = new ColorTransform();
        private var endColor:ColorTransform = new ColorTransform();
        private var runColor:ColorTransform = new ColorTransform();
        public var n:Number;
        // Other
        private var _capture : Bitmap;
        private var _center:Vector3D = new Vector3D();
        private var _i:int;
        private var _color:int;
        private var _colorBack:int;
        private var _sunOrbital:int;
        
    [SWF(backgroundColor="#000000", frameRate="60", width="465",height="465")]
    
    /**
    * away3d first
    * @author loth
    */
        public function Earth(){
            if(stage)init(null);
            else addEventListener(Event.ADDED_TO_STAGE, init);
        }
        
        private function init(e:Event):void{
            removeEventListener(Event.ADDED_TO_STAGE, init);
            stage.align = 'TL';
            stage.scaleMode = 'noScale';
            stage.quality = 'low';
            stage.frameRate = 60;
            System.pauseForGCIfCollectionImminent(1);
            // ★wonderfl capture
            if(Wonderfl)Wonderfl.disable_capture();
            //_capture = addChild(new Bitmap(new BitmapData(465, 465, false, 0x000000))) as Bitmap ;
            _manager = Stage3DManager.getInstance(stage);
            //_scene = new Scene3D();
            _stage3DProxy = _manager.getFreeStage3DProxy();
            _stage3DProxy.addEventListener(Stage3DEvent.CONTEXT3D_CREATED, onContextCreated);
        }
        
        private function onContextCreated(e:Stage3DEvent):void{
            _color= 0x45B046;//Math.random()*0xFFFFFF;
            _stage3DProxy.color = _color;
            _stage3DProxy.antiAlias = 4;
            _stage3DProxy.width = stage.stageWidth;
            _stage3DProxy.height = stage.stageHeight;
            _view = new View3D();
            //_view.scene = _scene;
            _scene = _view.scene;
            _view.stage3DProxy = _stage3DProxy;
            _view.shareContext = true;
            _view.camera.lens.far = 2500;
            _view.camera.z = -2000;
            var lens:PerspectiveLens = new PerspectiveLens( 90 );
            _view.camera.lens = lens;
            
            addChild(_view);
            
             //_starling = new Starling(SampleTexture, stage, _stage3DProxy.viewPort, _stage3DProxy.stage3D);
            //_starling.showStats = true;
            
            _sun = new DirectionalLight();
            _sun.castsShadows = true;
            _sun.shadowMapper = new NearDirectionalShadowMapper(.3);
            _scene.addChild(_sun);
            _sun.ambient=0.2;
            _sun.specular = 1;
            _sun.color= 0xffffFa;
            _sun.ambientColor= getNegative(_color);
            
            _moon = new PointLight();
            _moon.specular=2;
            _scene.addChild(_moon);
            
            
            _lightPicker = new StaticLightPicker([_sun, _moon]);
            
            _shadow = new NearShadowMapMethod(new FilteredShadowMapMethod(_sun));
            _shadow.epsilon = .0007;
            _fog = new FogMethod(200, 600, _color);
            
            createObject();
            
           }
       
       private function addEffect():void{
           var deep:DepthOfFieldFilter3D = new DepthOfFieldFilter3D(10, 10);
           deep.range = 600;
           deep.focusDistance = 300;
           //deep.focusTarget = _sphere;
            //var staturation:HueSaturationFilter3D = new HueSaturationFilter3D(0.2, 0.2, 0.2, 0.2);
           var bloom:BloomFilter3D = new BloomFilter3D( 10, 10, .5, 0.2, 3);
          // _view.filters3d = [deep]//, bloom];
       }

       private function createObject():void{
           var matGround:ColorMaterial = new ColorMaterial(0xAAAAAA);
           matGround.lightPicker = _lightPicker;
           matGround.shadowMethod = _shadow;
           matGround.addMethod(_fog);
           matGround.gloss=15;
           var matConstruct:ColorMaterial = new ColorMaterial(0x908888);
           matConstruct.lightPicker = _lightPicker;
           matConstruct.shadowMethod = _shadow;
           matConstruct.addMethod(_fog);
           matConstruct.gloss=30;
           
          // if (cartoon) {
              /* matGround.addMethod(new OutlineMethod(0x000000, 0.1, true));
                    matGround.diffuseMethod = new CelDiffuseMethod(3);
                    matGround.specularMethod = new CelSpecularMethod(.5);
                    CelSpecularMethod(matGround.specularMethod).smoothness = .3;
                    CelDiffuseMethod(matGround.diffuseMethod).smoothness = .2;*/
              
                    matConstruct.addMethod(new OutlineMethod(0xFFFFFF, 0.2, false));
                   //matConstruct.diffuseMethod = new CelDiffuseMethod(3);
                  // matConstruct.specularMethod = new CelSpecularMethod(.5);
                   // CelSpecularMethod(matConstruct.specularMethod).smoothness = .3;
                   // CelDiffuseMethod(matConstruct.diffuseMethod).smoothness = .2;
            //}
           
           
           _axe = new Mesh(new Geometry());
           _scene.addChild(_axe);
           _sphere = new Mesh(new SphereGeometry(300, 30, 20), matGround);
           _axe.addChild(_sphere);
           _axe.rotationZ=22.5;
            
            var boxRef:Mesh = new Mesh(new CubeGeometry(10, 10, 10), matConstruct);
            var box:Mesh;
            var height:int;
            for(_i=0; _i<200;_i++){
                height = 4+Math.random()*15;
                box = Mesh(boxRef.clone());
                box.scaleX=2+Math.random()*5;
                box.scaleY=2+Math.random()*5;
                box.rotationY = Math.random()*360;
                box.scaleZ=1//height;
                box.position = orbit(Math.random()*360, Math.random()*360, 280);
                box.lookAt(new Vector3D());
                TweenNano.to(box, 4, { scaleZ:height, delay:5+Math.random()*20, ease:Quad.easeOut});
                _sphere.addChild(box);
                }
            _stage3DProxy.addEventListener(Event.ENTER_FRAME, onEnterFrame);
            TweenNano.to(_view.camera, 2, { z:-600, ease:Quad.easeOut});
            
            swapColor(_color, 0x4F4540, 20);
            
            // error no effect if starling !?
            addEffect();
        }
        
        private final function orbit(H:Number, V:Number, D:Number):Vector3D {
            var p:Vector3D = new Vector3D();
            var phi:Number = radToDeg(H);
            var theta:Number = radToDeg(V);
            p.x = (D * Math.sin(phi) * Math.cos(theta));
            p.z = (D * Math.sin(phi) * Math.sin(theta));
            p.y = (D * Math.cos(phi));
            return p;
        }
        
        private static function radToDeg(d:Number):Number {
            return (d * (Math.PI / 180));
        }
        
        private function onEnterFrame(e:Event):void{
           // _proxy.clear();
            _sunOrbital++;
            _sun.position = orbit( _sunOrbital, 0, 1000);
            _moon.position = orbit( _sunOrbital+180, 0, 1000);
            _sun.lookAt(_center);
            _sphere.rotationY+=1;
            _view.render();
            //_starling.nextFrame();
            //　★ wonderfl capture
            if (_capture) _stage3DProxy.context3D.drawToBitmapData(_capture.bitmapData);
           // _proxy.present();
        }
       
        //-----------------------------------------------ColorTools
        public function swapColor(c1:int, c2:int, t:Number=1, d:Number=0 ):void {
            startColor.color = c1;
            endColor.color = c2;
            n = 0;
            TweenNano.to(this, t, {n:1, onUpdate:tweenTransforme, ease:Quad.easeOut});
        }
        private function tweenTransforme():void {
            runColor = interpolateColor(startColor, endColor, n);
            _stage3DProxy.color = runColor.color;
            _view.backgroundColor = runColor.color;
            _fog.fogColor = runColor.color;
            _sun.ambientColor= getNegative(runColor.color);
            _moon.color = runColor.color;
        }
        
        private function interpolateColor(s:ColorTransform, e:ColorTransform, t:Number):ColorTransform {
            var r:ColorTransform = new ColorTransform();
            r.redMultiplier = s.redMultiplier + (e.redMultiplier - s.redMultiplier) * t;
            r.greenMultiplier = s.greenMultiplier + (e.greenMultiplier - s.greenMultiplier) * t;
            r.blueMultiplier = s.blueMultiplier + (e.blueMultiplier - s.blueMultiplier) * t;
            r.alphaMultiplier = s.alphaMultiplier + (e.alphaMultiplier - s.alphaMultiplier) * t;
            r.redOffset = s.redOffset + (e.redOffset - s.redOffset) * t;
            r.greenOffset = s.greenOffset + (e.greenOffset - s.greenOffset) * t;
            r.blueOffset = s.blueOffset + (e.blueOffset - s.blueOffset) * t;
            r.alphaOffset = s.alphaOffset + (e.alphaOffset - s.alphaOffset) * t;
            return r;
        }
        
        private function getNegative(color:uint):uint {
            return (color & 0xFF000000) + /* keep alpha */
            ((0xff << 16 ) - (color & 0xff0000)) + /* red */
            ((0xff << 8 ) - (color & 0xff00)) + /* green */
            ((0xff) - (color & 0xff)); /* blue */
        }
    
    }
}


import flash.display.BitmapData;
import flash.geom.Rectangle;
import starling.display.Image;
import starling.display.Sprite;
import starling.textures.Texture;
import starling.text.TextField;
import starling.textures.RenderTexture;
internal class SampleTexture extends starling.display.Sprite{
    private var _container:Sprite;
    public function SampleTexture()
        {
            var checkerTx:RenderTexture = new RenderTexture(465,465);
            var infoText:TextField = new TextField(100, 50, "earth!");
        infoText.color = 0xFFFFFF;
        infoText.fontSize = 24;
        infoText.x = 20;
        infoText.y = 50;
        checkerTx.draw(infoText); 
        addChild(new Image(checkerTx));
        }
    }
package {
    import flash.display.*;
    import flash.events.*;
    import flash.filters.BlurFilter;
    import flash.geom.ColorTransform;
    import caurina.transitions.*;
    import caurina.transitions.properties.*;
    import org.papervision3d.cameras.Camera3D;
    import org.papervision3d.core.effects.BitmapLayerEffect;
    import org.papervision3d.core.geom.Pixels;
    import org.papervision3d.materials.special.ParticleMaterial;
    import org.papervision3d.materials.WireframeMaterial;
    import org.papervision3d.objects.DisplayObject3D;
    import org.papervision3d.objects.primitives.Sphere;
    import org.papervision3d.objects.special.ParticleField;
    import org.papervision3d.render.BasicRenderEngine;
    import org.papervision3d.scenes.Scene3D;
    import org.papervision3d.view.layer.BitmapEffectLayer;
    import org.papervision3d.view.Viewport3D;
    
    /* @author zawa */
    
    [SWF(width = "465", height = "465", backgroundColor = "0", fps = "30")] 
    
    public class Main extends Sprite {
        
        private var scene:Scene3D;
        private var camera:Camera3D;
        private var viewport:Viewport3D;
        private var render:BasicRenderEngine;
        private var rootNode:DisplayObject3D;
        private var bfm:BitmapEffectLayer;
        private var coltrans:ColorTransform;
        private var cameraBool:Boolean;
        private var cametaPos:Object;
        private var angle:Number;
        
        public function Main():void 
        {
            Wonderfl.capture_delay(55);
            
            var bitmap:Bitmap = new Bitmap(new BitmapData(465,465,false,0x000000));
            addChild(bitmap);
            
            createWorld();
            stage.addEventListener(MouseEvent.CLICK, changeView)
        }
        private function createWorld():void {
            scene = new Scene3D();
            viewport = new Viewport3D(0, 0, true, false);
            addChild(viewport);
            rootNode = new DisplayObject3D();
            scene.addChild(rootNode);
            camera = new Camera3D();
            camera.z = -camera.focus * camera.zoom;
            render = new BasicRenderEngine();
            
            var sphere:Sphere = new Sphere(new WireframeMaterial(0xFFFFFF, 100, 1), 100, 36, 24);
            var vmax:Number = sphere.geometry.vertices.length - 1;
            var mat:ParticleMaterial =  new ParticleMaterial(0xFFFFFF, 10, 1);
            var particles:ParticleField = new ParticleField(mat, vmax*2, 3, 2000, 2000, 2000);
            
            bfm = new BitmapEffectLayer(viewport, stage.stageWidth, stage.stageHeight, true, 0, "clear_pre",false,false );
            bfm.addEffect(new BitmapLayerEffect(new BlurFilter(10, 10, 3), false));
            bfm.drawCommand.blendMode = BlendMode.ADD
            viewport.containerSprite.addLayer(bfm);
            bfm.addDisplayObject3D(particles);
            
            coltrans = new ColorTransform(0,0,0,1,0,0,0,0);
            rootNode.addChild(particles)
            
            for (var i:Number = 0; i <= vmax; i++) {
                var gx:Number = sphere.geometry.vertices[i].x;
                var gy:Number = sphere.geometry.vertices[i].y;
                var gz:Number = sphere.geometry.vertices[i].z;
                Tweener.addTween(particles.geometry.vertices[i], { x:gx, y:gy, z:gz, delay:i*.1,time:5, transition:"easeInOutExpo" } );
            }
            
            angle = 0;
            cameraBool = true;
            cametaPos = { b: -camera.focus * camera.zoom, f:-camera.focus * camera.zoom + 150 };
            
            startRendering();
        }
        private function startRendering():void {
            addEventListener(Event.ENTER_FRAME, update);
        }
        //Rendering...
        private function update(e:Event):void{
            render.renderScene(scene, camera, viewport);
            rootNode.rotationY+=.5;
            rootNode.rotationX+=.3;
            rootNode.rotationZ+=.1;
            angle+=.01;
            var sin:Number = Math.sin(angle)
            var cos:Number = Math.cos(angle)
            if (sin < .1) sin = Math.abs(sin)+.1;
            if (cos < .1) cos = Math.abs(cos)+.1;
            
            coltrans.redMultiplier = sin/4;
            coltrans.greenMultiplier = cos/2;
            coltrans.blueMultiplier = sin;
            
            bfm.drawCommand.colorTransform = coltrans;
        }
        //MouseEvent...
        private function changeView(e:MouseEvent) :void {
            Tweener.removeTweens(camera);
            if (cameraBool) {
                cameraBool = false;
                Tweener.addTween(camera, { z:cametaPos.f, time:10, transition:"easeInOutQuard" } );
            }else {
                cameraBool = true;
                Tweener.addTween(camera, { z:cametaPos.b, time:10, transition:"easeInOutQuard" } );
            }
        }
    }
}
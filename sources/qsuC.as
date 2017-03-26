/**
 * Sphere made from planes.
 * @see http://forum.alternativaplatform.com/posts/list/2969.page#50884
 */
package {   
    import alternativ5.engine3d.controllers.WalkController;   
    import alternativ5.engine3d.core.Camera3D;   
    import alternativ5.engine3d.core.Object3D;   
    import alternativ5.engine3d.core.Scene3D;   
    import alternativ5.engine3d.display.View;   
  
    import alternativ5.engine3d.materials.FillMaterial;   
    import alternativ5.engine3d.primitives.Plane;   
    import alternativ5.types.Point3D;   
  
    import flash.display.Sprite;   
    import flash.events.Event;   
  
    [SWF (backgroundColor="0", width="465", height="465", frameRate="30")]   
    public class Main extends Sprite {   
  
        private var view:View;   
        private var scene:Scene3D;   
        private var camera:Camera3D;   
        private var controller:WalkController;   
  
        public function Main() {   
            scene = new Scene3D();   
            scene.root = new Object3D();   
            var cameraContainer:Object3D = new Object3D();   
            scene.root.addChild(cameraContainer);   
            camera = new Camera3D();   
            cameraContainer.addChild(camera);   
            camera.y = -200;   
            camera.rotationX = -Math.PI/2;   
            view = new View(camera, 465, 465);   
            addChild(view);   
            controller = new WalkController(stage, cameraContainer);   
  
            createGeometry();   
  
            stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);   
        }   
  
        private function createGeometry():void {   
            var planeWidth:Number = 10;   
            var planeHength:Number = 15;   
            var radius:Number = 100;   
            var numParallels:int = 10;   
            var alphaStep:Number = Math.PI/(numParallels + 1);   
            for (var pIndex:int = 0; pIndex < numParallels; pIndex++) {   
                var alpha:Number = alphaStep*(pIndex + 1);   
				var numMeridians:int = 10*Math.sin(alpha)/Math.sin(alphaStep);   
				var betaStep:Number = 2*Math.PI/numMeridians;   
                var z:Number = radius*Math.cos(alpha);   
                var xy:Number = radius*Math.sin(alpha);   
                for (var mIndex:int = 0; mIndex < numMeridians; mIndex++) {   
                    var beta:Number = betaStep*mIndex;   
                    var x:Number = -xy*Math.sin(beta);   
                    var y:Number = xy*Math.cos(beta);   
                    var plane:Plane = new Plane(planeWidth, planeHength);   
                    plane.setMaterialToSurface(new FillMaterial(0xFF0000, 1, "normal", 0, 0xFFFFFF), "front");   
                    plane.setMaterialToSurface(new FillMaterial(0x660000, 1, "normal", 0, 0xFFFFFF), "back");   
                    plane.coords = new Point3D(x, y, z);   
                    plane.rotationX = -alpha;   
                    plane.rotationZ = beta;   
                    scene.root.addChild(plane);   
                }   
            }   
        }   
  
        private function onEnterFrame(e:Event):void {   
            controller.processInput();   
            scene.calculate();   
        }   
    }   
} 
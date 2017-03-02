// forked from focus's Alternativa3D 7 667 boxes
package 
{
    import alternativ7.engine3d.containers.DistanceSortContainer;
    import alternativ7.engine3d.controllers.SimpleObjectController;
    import alternativ7.engine3d.core.Camera3D;
    import alternativ7.engine3d.core.MipMapping;
    import alternativ7.engine3d.core.Object3D;
    import alternativ7.engine3d.core.Object3DContainer;
    import alternativ7.engine3d.core.View;
    import alternativ7.engine3d.materials.FillMaterial;
    import alternativ7.engine3d.materials.TextureMaterial;
    import alternativ7.engine3d.primitives.Box;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageQuality;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    
    /**
     * ...
     * @author focus
     */
	[SWF(width=465,height=465,backgroundColor=0)]
    public class Main1 extends Sprite 
    {
        
        //engine variables
        private var rootContainer:Object3DContainer = new Object3DContainer();
        private var camera:Camera3D;
        
        private var cubes:Vector.<Box>;
        private var materials:Vector.<FillMaterial>;
        private var cube:Box;
        private var len:int;
        private var i:int;
        private var sortCont:DistanceSortContainer;
        private var controller:SimpleObjectController;
        
        public function Main1():void 
        {
            if (stage) init();
            else addEventListener(Event.ADDED_TO_STAGE, init);
        }
        
        private function init(e:Event = null):void 
        {
            removeEventListener(Event.ADDED_TO_STAGE, init);
            // entry point
            
            stage.align = StageAlign.TOP_LEFT;
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.quality = StageQuality.LOW;
            
            _init();
            //stage.addChild(new Stats());
        }
        
        private function _init():void
        {
            initEngine();
        }

        private function initEngine():void
        {
            
            camera = new Camera3D();
            camera.view = new View(stage.stageWidth, stage.stageHeight);
            addChild(camera.view);
            addChild(camera.diagram);
            
            camera.x = 0;
            camera.y = 0;
            camera.z = -600;
            
            //camera.rotationZ = - Math.PI/4;
            
            controller = new SimpleObjectController(stage, camera, 200);
            rootContainer.addChild(camera);
            
            i = 0;
            len = 625;
			cubes = new Vector.<Box> (len, true);
			materials = new Vector.<FillMaterial> (len, true);
            
            sortCont = new DistanceSortContainer();
            var bmp : BitmapData = new BitmapData(20, 20);
            bmp.perlinNoise(200, 200, 2, Math.random(), true, true);
            
            var box:Box = new Box(20, 20, 20);
            
            for (i = 0; i < len; i++)
            {
				var mat:FillMaterial = new FillMaterial;
                var cube:Box = box.clone () as Box;
				cube.setMaterialToAllFaces (mat);

                cube.x = 25 * (int (i / 25) - 12);
                cube.y = 25 * (int (i % 25) - 12);

                cubes [i] = cube; materials [i] = mat;
                sortCont.addChild(cube);
            }
            
            rootContainer.addChild(sortCont);
            stage.addEventListener(Event.ENTER_FRAME, onRender);
        }
        
        private function onRender(e:Event):void 
        {
            i = 0;
            len =cubes.length;
            
            for (i; i < len ; i++ )
            {
				var cube:Box = cubes [i];
				var dx:Number = cube.x * 0.55 - mouseX + stage.stageWidth / 2;
				var dy:Number = cube.y * 0.55 - mouseY + stage.stageHeight / 2;
				cube.z = -500 / (1 + 0.1 * Math.sqrt (dx * dx + dy * dy));
				cube.rotationX += 0.005 * cube.z;
				cube.rotationY += 0.005 * cube.z;
				materials [i].color = 0x30201 * int (-cube.z / 6) + 0x10203 * int ((500 - cube.z) / 24)
            }
            
            //controller.update();
            camera.render();
        }
    }
    
}
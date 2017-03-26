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
    public class Main extends Sprite 
    {
        
        //engine variables
        private var rootContainer:Object3DContainer = new Object3DContainer();
        private var camera:Camera3D;
        
        private var cubes:Array = [];
        private var cube:Box;
        private var len:int;
        private var i:int;
        private var sortCont:DistanceSortContainer;
        private var controller:SimpleObjectController;
        
        public function Main():void 
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
            camera.y = 100;
            camera.z = -600;
            
            //camera.rotationZ = - Math.PI/4;
            
            controller = new SimpleObjectController(stage, camera, 200);
            rootContainer.addChild(camera);
            
            i = 0;
            len = 667;
            
            var startX:Number = -stage.stageWidth/2;
            var startY:Number = -stage.stageHeight/2;
            
            var xx:Number = startX;
            var yy:Number = startY;
            
            var nPageColCount:uint = 14;
            var nPageRowCount:uint = 70;
            
            var nSpaceX:Number = 5;
            var nSpaceY:Number = 5;
            
            var nCurrPage:uint = 1;
            
            var nItemXIncrement:Number = 0;
            var nItemYIncrement:Number = 0;
            
            sortCont = new DistanceSortContainer();
            var bmp : BitmapData = new BitmapData(20, 20);
            bmp.perlinNoise(200, 200, 2, Math.random(), true, true);
            
            var box:Box = new Box(20, 20, 20);
            box.setMaterialToAllFaces(new FillMaterial());
            
            i = 0;
            for (i; i < len; i+=1 )
            {
                var cube:Object3D = box.clone();
                
                cube.x = Math.round(xx);
                cube.y = Math.round(yy);
                
                nItemXIncrement = 20 + nSpaceX;
                
                if (xx + nItemXIncrement < (nCurrPage*(nItemXIncrement*nPageColCount)) - 1)
                {
                    xx += nItemXIncrement;
                }
                else
                {
                    nItemYIncrement = 20 + nSpaceY;
                    if (yy + nItemYIncrement < nItemYIncrement*nPageRowCount)
                    {
                        yy += nItemYIncrement;
                    }
                    else
                    {
                        yy = startY;
                        nCurrPage += 1;
                    }
                    
                    xx = startX + (nCurrPage-1) * (nItemXIncrement * nPageColCount);
                }
                cubes[cubes.length] = cube;
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
                cubes[i].rotationY += 5;
            }
            
            //controller.update();
            camera.render();
        }
    }
    
}
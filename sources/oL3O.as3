package 
{
    //import frocessing.color.ColorHSV
    import alternativ7.engine3d.containers.DistanceSortContainer;
    import alternativ7.engine3d.controllers.SimpleObjectController;
    import alternativ7.engine3d.core.Camera3D;
    import alternativ7.engine3d.core.Object3DContainer;
    import alternativ7.engine3d.core.View;
    import alternativ7.engine3d.materials.FillMaterial;
    import alternativ7.engine3d.primitives.Box;
    import flash.display.BitmapData;
    import flash.geom.Point;
    import flash.display.Sprite;
    import flash.events.Event;
    
    public class Main extends Sprite 
    {   
        public function Main():void 
        {
            //stage.frameRate = 60
            opaqueBackground = 0x05
            var rootContainer:Object3DContainer = new Object3DContainer();           
            var camera:Camera3D = new Camera3D();
            camera.view = new View(stage.stageWidth, stage.stageHeight)
            camera.rotationX = 0.3
            camera.y = 200
            camera.z = -600;
            addChild(camera.view);
            addChild(camera.diagram);
            rootContainer.addChild(camera);
            var sortCont:DistanceSortContainer = new DistanceSortContainer()
            var cubes:Vector.<Box> = new Vector.<Box>
            var materials:Vector.<FillMaterial>= new Vector.<FillMaterial>
            var box:Box = new Box(20, 20, 20);
            for (var i:int=0; i<25; i++) {
                for (var j:int=0; j<25; j++) {
                    var mat:FillMaterial = new FillMaterial
                    var cube:Box = box.clone() as Box
                    cube.setMaterialToAllFaces(mat)
                    cube.x = 25 *(i-12)
                    cube.y = 25 *(j-12)
                    cubes.push(cube)
                    materials.push(mat)
                    sortCont.addChild(cube)
                }
            }
            rootContainer.addChild(sortCont);
            var noise:BitmapData = new BitmapData(25,25)
            var val:Number = 0
            addEventListener(Event.ENTER_FRAME, function (e:Event):void {
                noise.perlinNoise(20,20,2,100,false,true,7,true,[new Point(val,0)])
                val -= 0.2
                for (var i:int=0; i<25; i++) {
                    for (var j:int=0; j<25; j++) {
                        var idx:int = i*25+j
                        var cube:Box = cubes[idx]
                        /*
                        var rate:Number = (noise.getPixel(i,j)% 0x100)/0x100
                        cube.z = -250 * rate
                        cube.rotationX += 0.05 * rate
                        cube.rotationY += 0.05 * rate
                        var color : ColorHSV = new ColorHSV(180)
                        color.s = rate
                        materials[idx].color = color.value
                        */
                        var num:int = noise.getPixel(i,j)% 0x100
                        cube.z = -num
                        if (num > 0xaf) cube.z *= 1.2
                        if (num < 0x85) cube.z *= 0.7
                        cube.rotationX += 0.0003 * num
                        cube.rotationY += 0.0003 * num
                        materials[idx].color = 0x30201 * int (-cube.z / 6) + 0x10203 * int ((500 - cube.z) / 24)
                        
                    }
                }
                camera.render()
            })
        }
    }
}


package 
{
    import flash.display.*;
    import flash.events.*;
    import flash.geom.Matrix;
    import flash.net.URLRequest;
    import flash.system.LoaderContext;
    import org.libspark.betweenas3.BetweenAS3;
    import org.libspark.betweenas3.easing.*;
    import org.libspark.betweenas3.tweens.ITween;
    import org.papervision3d.lights.PointLight3D;
    import org.papervision3d.materials.BitmapMaterial;
    import org.papervision3d.materials.shadematerials.FlatShadeMaterial;
    import org.papervision3d.materials.utils.MaterialsList;
    import org.papervision3d.objects.primitives.Cube;
    import org.papervision3d.view.BasicView;
    
    /**
     * Cube Transition
     * @author Yasu
     */
    public class Main extends BasicView 
    {
        static public const SEPATATE:uint = 10;
        static public const IMAGE_URL_1:String = "http://farm4.static.flickr.com/3204/2662752901_15864d11c3.jpg";
        static public const IMAGE_URL_2:String = "http://farm4.static.flickr.com/3170/2662752833_c3fb0c76a4.jpg";
        
        private var loader1:Loader;
        private var loader2:Loader;
        private var cubes:Array;
        private var degree:Number = 0;
        private var light:PointLight3D = 
new PointLight3D();
                public function Main():void 
        {
            stage.quality = StageQuality.LOW;
            stage.frameRate = 60;
            viewport.opaqueBackground = 0x0;
            
            var context:LoaderContext = new LoaderContext(true);
            
            loader1 = new Loader();
            loader1.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void
            {
                loader2= new Loader();
                loader2.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void
                {
                    init();
                });
                loader2.load(new URLRequest(IMAGE_URL_2), context);
            });
            loader1.load(new URLRequest(IMAGE_URL_1), context);
        }
        
        private function init():void
        {
            var sliceList1:Array = sliceBmp(loader1.content as Bitmap, true);
            var sliceList2:Array = sliceBmp(loader2.content as Bitmap, true);
            var sliceList3:Array = sliceBmp(loader1.content as Bitmap, false);
            var sliceList4:Array = sliceBmp(loader2.content as Bitmap, false);
            
            cubes = [];
            
            for (var i:int = 0; i < SEPATATE; i++) 
            {
                var bmpData1:BitmapMaterial = new BitmapMaterial(sliceList1[i], true);
                var bmpData2:BitmapMaterial = new BitmapMaterial(sliceList2[i], true);
                var bmpData3:BitmapMaterial = new BitmapMaterial(sliceList3[i], true);
                var bmpData4:BitmapMaterial = new BitmapMaterial(sliceList4[i], true);
                
                /*
                bmpData1.smooth = true;
                bmpData2.smooth = true;
                bmpData3.smooth = true;
                bmpData4.smooth = true;
                */
                
                var cube:Cube = new Cube(new MaterialsList( {
                    bottom : bmpData1,
                    front  : bmpData2,
                    top    : bmpData3,
                    back   : bmpData4,
                    left   : new FlatShadeMaterial(light, 0xCCCCCC),
                    right  : new FlatShadeMaterial(light, 0xCCCCCC)
                }), loader1.content.width / SEPATATE, loader1.content.height, loader1.content.height);
                
                cube.x = loader1.content.width / SEPATATE * (i - SEPATATE / 2  + 0.5);
                
                cubes.push(scene.addChild(cube));
            }
            
            var tweens:Array = [];
            for (var j:int = 1; j < 5; j++) 
            {
                var localTweens:Array = [];
                for (i = 0; i < cubes.length; i++) 
                {
                    var tw:ITween = BetweenAS3.bezier(cubes[i], { rotationX : -90 * j, scale:1 }, null, {scale:0.7}, 1.3, Cubic.easeInOut);
                    tw = BetweenAS3.delay(tw, 0.075 * i);
                    localTweens.push(tw);
                }
                tweens.push(BetweenAS3.delay(BetweenAS3.parallelTweens(localTweens), 1));
            }
            var tween:ITween = BetweenAS3.serialTweens(tweens)
            tween.stopOnComplete = false;
            tween.play();
            
            startRendering();
            //addEventListener(Event.ENTER_FRAME, loop);
            
            camera.focus = 50;
            camera.zoom = 4;
            camera.z = -(camera.focus * camera.zoom + loader1.content.height / 2);
        }
        
        private function loop(e:Event):void 
        {
            //var distance:Number = -(camera.focus * camera.zoom + loader1.content.height / 2);
            var distance:Number = -600;
            degree += ((mouseX / stage.stageWidth * 120 - 60) - degree) * 0.15;
            
            camera.x = distance * Math.sin(degree * Math.PI / 180);
            camera.z = distance * Math.cos(degree * Math.PI / 180);
            camera.y += ((500 * mouseY / stage.stageHeight - 250) - camera.y) * 0.15;
            
            light.copyPosition(camera);
        }
        
        private function sliceBmp(bmp:Bitmap, opposite:Boolean):Array
        {
            var arr:Array = [];
            for (var i:int = 0; i < SEPATATE; i++) 
            {
                var matrix:Matrix = new Matrix();
                if (opposite)
                {
                    matrix.scale(1, -1);
                    matrix.translate(0, bmp.height);
                    matrix.scale(-1, 1);
                    matrix.translate(bmp.width, 0);
                    matrix.translate( - bmp.width / SEPATATE * (SEPATATE - i - 1), 0);
                }
                else
                {
                    matrix.translate( - bmp.width / SEPATATE * i, 0);
                }
                

                var bmpData:BitmapData = new BitmapData(bmp.width / SEPATATE, bmp.height);
                bmpData.draw(bmp, matrix);
                
                arr.push(bmpData);
            }
            return arr;
        }
    }
}

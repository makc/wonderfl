// forked from greentec's Lonely Planet 1
package  
{
    import away3d.cameras.Camera3D;
    import away3d.containers.Scene3D;
    import away3d.containers.View3D;
    import away3d.controllers.HoverController;
    import away3d.debug.AwayStats;
    import away3d.entities.Mesh;
    import away3d.lights.DirectionalLight;
    import away3d.materials.lightpickers.StaticLightPicker;
    import away3d.materials.TextureMaterial;
    import away3d.primitives.SphereGeometry;
    import away3d.primitives.CubeGeometry;
    import away3d.utils.Cast;
    import flash.geom.Matrix;
    import flash.geom.Point;
    
    import flash.display.*;
    import flash.events.*;
    import flash.geom.ColorTransform;
    /**
     * ...
     * @author ypc
     */
    [SWF(width = 465, height = 465)]
    public class SphereTexture extends Sprite
    {
        private var view:View3D;
        private var scene:Scene3D;
        private var camera:Camera3D;
        private var awayStats:AwayStats;
        
        private var cameraController:HoverController;
        
        private var light:DirectionalLight;
        private var lightPicker:StaticLightPicker;
        
        private var sphereMaterial:TextureMaterial;
        private var sphereBitmapData:BitmapData;
        private var _width:int = 256;
        private var _height:int = 256;
        private var noiseBitmapData:BitmapData;
        private var normalBitmapData:BitmapData;
        
        private var sphere:Mesh;
        private var sphereGeometry:SphereGeometry;
        //private var sphereGeometry:CubeGeometry;
        
        //navigation variables
        private var move:Boolean = false;
        private var lastPanAngle:Number;
        private var lastTiltAngle:Number;
        private var lastMouseX:Number;
        private var lastMouseY:Number;
        
        private var showSphereBitmap:Bitmap;
        private var showSphereBitmapData:BitmapData;
        private var showNormalBitmap:Bitmap;
        private var showNormalBitmapData:BitmapData;
        
        //private var source:BitmapData = new BitmapData(465, 465, false, 0x000000);       
        
        public function SphereTexture() 
        {
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
            
            Wonderfl.disable_capture();

            //addChild(new Bitmap(source));
            
            initEngine();
            initLight();
            initMaterial();
            initObject();
            initListener();
        }
        
        private function initEngine():void
        {
            view = new View3D();
            view.antiAlias = 4;
            
            scene = view.scene;
            camera = view.camera;
            camera.lens.far = 5000;
            
            cameraController = new HoverController(camera);
            cameraController.distance = 400;
            
            awayStats = new AwayStats(view);
            
        }
        
        private function initLight():void
        {
            light = new DirectionalLight( -0.5, -1, -1);
            light.color = 0xffffff;
            light.ambient = 1;
            scene.addChild(light);
            
            lightPicker = new StaticLightPicker([light]);
        }
        
        private function initMaterial():void
       {
            var i:int;
            var j:int;
            var x:Number;
            var y:Number;
            var num:Number;
            var color:int;
           
            sphereBitmapData = new BitmapData(_width, _height, false, 0);
            noiseBitmapData = new BitmapData(_width, _height, false, 0);
           noiseBitmapData.perlinNoise(_width / 4, _height / 4, 7, Math.random() * int.MAX_VALUE, true, true, 7, true);
            
            
            for (i = 0; i < _width; i += 1)
            {
               for (j = 0; j < _height; j += 1)
               {
                    x = i / _width * 1.0;
                    y = (noiseBitmapData.getPixel(i, j) & 0xff) / 255;
                    num = (1 + Math.sin((x + y / 2) * 50)) / 2;
                    
                    num = num < 0 ? 0 : num;
                    color = num * 255;
                    sphereBitmapData.setPixel(i, j, color << 16 | color << 8 | color);
                    //trace(color);
                }
           }
            
            //sphereBitmapData.draw(noiseBitmapData);
            
            
           
            sphereMaterial = new TextureMaterial();
            sphereMaterial.lightPicker = lightPicker;
            sphereMaterial.ambientColor = 0xffffff;
            sphereMaterial.ambient = .2;
            sphereMaterial.specular = .1;
           //sphereMaterial.normalMap = Cast.bitmapTexture(sphereBitmapData);
            
            normalBitmapData = new BitmapData(_width, _height, false, 0);
            var right:Number;
           var left:Number;
            var down:Number;
            var up:Number;
            var normalX:Number;
            var normalY:Number;
            var normalZ:Number;
            var normalSq:Number;
            var alpha:Number = 2;
           var red:uint;
            var green:uint;
            var blue:uint;
            
            for (i = 0; i < _width; i += 1)
            {
                for (j = 0; j < _height; j += 1)
                {
                    if (j < _width - 1)
                    {
                        right = (sphereBitmapData.getPixel(i, j + 1) & 0xff) / 255;
                    }
                    else
                    {
                        right = 0;
                    }
                    
                    if (j > 0)
                    {
                        left = (sphereBitmapData.getPixel(i, j - 1) & 0xff) / 255;
                    }
                    else
                    {
                        left = 0;
                    }
                    
                    if (i < _height - 1)
                    {
                        down = (sphereBitmapData.getPixel(i + 1, j) & 0xff) / 255;
                    }
                    else
                    {
                        down = 0;
                    }
                    
                    if (i > 0)
                    {
                        up = (sphereBitmapData.getPixel(i - 1, j) & 0xff) / 255;
                    }
                    else
                    {
                        up = 0;
                    }
                    
                    normalX = alpha * (right - left);
                    normalY = alpha * (down - up);
                    normalZ = 1;
                    
                    normalSq = Math.sqrt(normalX * normalX + normalY * normalY + 1);
                    normalX /= normalSq;
                    normalY /= normalSq;
                    normalZ /= normalSq;
                    
                    red = (1 + normalX) / 2 * 255;
                    green = (1 + normalY) / 2 * 255;
                    blue = (1 + normalZ) / 2 * 255;
                    
                    normalBitmapData.setPixel(i, j, red << 16 | green << 8 | blue);
                    
                }
            }
           
            //var bitmap:Bitmap = new Bitmap(normalBitmapData);
            //bitmap.x = stage.stageWidth - bitmap.width;
            //addChild(bitmap);
            
            sphereMaterial.normalMap = Cast.bitmapTexture(normalBitmapData);
            
            sphereBitmapData.colorTransform(sphereBitmapData.rect, new ColorTransform(Math.random(), Math.random(), Math.random(), 1, Math.random() * 255, Math.random() * 255, Math.random() * 255));
            
           sphereMaterial.texture = Cast.bitmapTexture(sphereBitmapData);
            
            showSphereBitmapData = new BitmapData(_width / 2, _height / 2, false, 0);
            showSphereBitmapData.draw(sphereBitmapData, new Matrix(0.5, 0, 0, 0.5, 0, 0));
            showSphereBitmap = new Bitmap(showSphereBitmapData);
            showSphereBitmap.x = 465 - _width;
            addChild(showSphereBitmap);
            
            showNormalBitmapData = new BitmapData(_width / 2, _height / 2, false, 0);
            showNormalBitmapData.draw(normalBitmapData, new Matrix(0.5, 0, 0, 0.5, 0, 0));
            showNormalBitmap = new Bitmap(showNormalBitmapData);
            showNormalBitmap.x = 465 - _width / 2;
           addChild(showNormalBitmap);
            
        }
        
        private function initObject():void
        {
            sphereGeometry = new SphereGeometry(200, 64, 64);
            //sphereGeometry = new CubeGeometry(200, 200, 200, 1, 1, 1, false);
            sphere = new Mesh(sphereGeometry, sphereMaterial);
            scene.addChild(sphere);
        }

      
        private function initListener():void
        {
            stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
            stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
            stage.addEventListener(Event.RESIZE, resizeHandler);
            addEventListener(Event.ENTER_FRAME, render);
            
            
            addChild(view);
            addChild(awayStats);
        }
        
        private function render(e:Event):void
        {
            if (move)
            {
                cameraController.panAngle = 0.3 * (stage.mouseX - lastMouseX) + lastPanAngle;
                cameraController.tiltAngle = 0.3 * (stage.mouseY - lastMouseY) + lastTiltAngle;
            }
            
            sphere.rotationY += 1;
            sphere.rotationZ -= 0.5;
            
            view.render();
            //view.renderer.queueSnapshot(source);
        }
        
        private function onMouseDown(e:MouseEvent):void
        {
            lastPanAngle = cameraController.panAngle;
            lastTiltAngle = cameraController.tiltAngle;
            lastMouseX = stage.mouseX;
            lastMouseY = stage.mouseY;
            move = true;
            
            
            var i:int;
            var j:int;
            var x:Number;
           var y:Number;
            var num:Number;
            var color:int;
            
            noiseBitmapData.fillRect(noiseBitmapData.rect, 0);
            var scale:int = Math.random() * 10 + 2;
            noiseBitmapData.perlinNoise(_width / scale, _height / scale, 7, Math.random() * int.MAX_VALUE, false, true, 7, true);
            
            for (i = 0; i < _width; i += 1)
            {
                for (j = 0; j < _height; j += 1)
                {
                    x = i / _width * 1.0;
                    y = (noiseBitmapData.getPixel(i, j) & 0xff) / 255;
                    num = (1 + Math.sin((x + y / 2) * 50)) / 2;
                    
                    num = num < 0 ? 0 : num;
                    color = num * 255;
                    sphereBitmapData.setPixel(i, j, color << 16 | color << 8 | color);
                    //trace(color);
                }
            }
            
            //sphereBitmapData.draw(noiseBitmapData);
            
            var right:Number;
            var left:Number;
            var down:Number;
            var up:Number;
            var normalX:Number;
            var normalY:Number;
            var normalZ:Number;
            var normalSq:Number;
            var alpha:Number = 2//Math.random() * 5 + 0.5;
            var red:uint;
            var green:uint;
            var blue:uint;
            
            for (i = 0; i < _width; i += 1)
            {
                for (j = 0; j < _height; j += 1)
                {
                    if (j < _width - 1)
                    {
                        right = (sphereBitmapData.getPixel(i, j + 1) & 0xff) / 255;
                    }
                    else
                    {
                        right = (sphereBitmapData.getPixel(i, 0) & 0xff) / 255;
                    }
                    
                    if (j > 0)
                    {
                        left = (sphereBitmapData.getPixel(i, j - 1) & 0xff) / 255;
                    }
                    else
                    {
                        left = (sphereBitmapData.getPixel(i, _width - 1) & 0xff) / 255;
                    }
                    
                    if (i < _height - 1)
                    {
                        down = (sphereBitmapData.getPixel(i + 1, j) & 0xff) / 255;
                    }
                    else
                    {
                        down = (sphereBitmapData.getPixel(0, j) & 0xff) / 255;
                   }
                    
                    if (i > 0)
                    {
                        up = (sphereBitmapData.getPixel(i - 1, j) & 0xff) / 255;
                    }
                    else
                    {
                        up = (sphereBitmapData.getPixel(_height - 1, j) & 0xff) / 255;
                    }
                    

                   normalX = alpha * (right - left);
                   normalY = alpha * (down - up);
                    normalZ = 1;
                   
                   normalSq = Math.sqrt(normalX * normalX + normalY * normalY + 1);
                   normalX /= normalSq;
                   normalY /= normalSq;
                   normalZ /= normalSq;
                   
                   red = (1 + normalX) / 2 * 255;
                   green = (1 + normalY) / 2 * 255;
                    blue = (1 + normalZ) / 2 * 255;
                    
                    normalBitmapData.setPixel(i, j, red << 16 | green << 8 | blue);
                    
                }
            }
            
            sphereMaterial.normalMap = Cast.bitmapTexture(normalBitmapData);
            
            //sphereMaterial.normalMap = Cast.bitmapTexture(sphereBitmapData);
            
            sphereBitmapData.colorTransform(sphereBitmapData.rect, new ColorTransform(Math.random(), Math.random(), Math.random(), 1, Math.random() * 255, Math.random() * 255, Math.random() * 255));
            
            
            sphereMaterial.texture = Cast.bitmapTexture(sphereBitmapData);
            
            showSphereBitmapData.draw(sphereBitmapData, new Matrix(0.5, 0, 0, 0.5, 0, 0));
            showNormalBitmapData.draw(normalBitmapData, new Matrix(0.5, 0, 0, 0.5, 0, 0));
            
        }
        
        private function onMouseUp(e:MouseEvent):void
        {
            move = false;
        }
        
        private function resizeHandler(e:Event):void
        {
            view.width = stage.stageWidth;
            view.height = stage.stageHeight;
        }
        
    }
}
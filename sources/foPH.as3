package 
{
    import com.bit101.components.PushButton;
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.filters.BlurFilter;
    import flash.geom.Matrix;
    import flash.geom.Point;
    
    /**
     * Inspired by:
     * http://www.catalinzima.com/2010/07/my-technique-for-the-shader-based-dynamic-2d-shadows/
     */
    public class Main extends Sprite 
    {
        
        private const PI                 :Number = Math.PI;
        private const TWO_PI             :Number = 2 * Math.PI;
        private const HALF_PI            :Number = 0.5 * Math.PI;
        private const QUARTER_PI         :Number = 0.25 * Math.PI;
        
        private const NUM_OBSTACLES      :int    = 10;
        private const OBSTACLE_SIZE      :Number = 50;
        private const OBSTACLE_SIZE_VAR  :Number = 15;
        private const LIGHT_RADIUS       :Number = 100;
        
        private const BLUR               :Number = 2;
        private const DIST_BLUR_FACTOR   :Number = 0.25;
        private const DIST_BLUR_THRESHOLD:Number = 27;
        
        private var resultBMP            :Bitmap;
        private var dataBMP              :Bitmap;
        private var obstacles            :Sprite;
        private var result               :BitmapData;
        private var resultBlurTemp       :BitmapData;
        private var obstacleMap          :BitmapData;
        private var distanceMap          :BitmapData;
        private var reducedDistanceMap   :BitmapData;
        
        public function Main() 
        {
            init();
            stage.addEventListener(MouseEvent.MOUSE_MOVE, mainLoop);
        }
        
        private function init():void 
        {
            
            result             = new BitmapData(150, 150, false, 0xFFFFFF);
            resultBlurTemp     = new BitmapData(150, 150, false, 0xFFFFFF);
            obstacleMap        = new BitmapData(150, 150, false, 0xFFFFFF);
            distanceMap        = new BitmapData(100, 100, false, 0xFFFFFF);
            reducedDistanceMap = new BitmapData(  1, 100, false, 0xFFFFFF);
            
            dataBMP = new Bitmap();
            addChild(dataBMP);
            
            resultBMP = new Bitmap(result);
            resultBMP.scaleX =  stage.stageWidth / result.width;
            resultBMP.scaleY =  stage.stageHeight / result.height;
            addChild(resultBMP);
            
            obstacles = new Sprite();
            //addChild(obstacles);
            
            new PushButton(this, 10, 10, "Regenerate Obstacles", regenerateObstacles);
            new PushButton(this, 10, 30, "Result",          showResult);
            new PushButton(this, 10, 50, "Obstacle Map",    showObstacleMap);
            new PushButton(this, 10, 70, "Distance Map",    showDistanceMap);
            new PushButton(this, 10, 90, "Reduced Distance Map",    showReducedDistanceMap);
            
            regenerateObstacles();
        }
        
        private function mainLoop(e:Event = null):void 
        {
            result.lock();
            distanceMap.lock();
            reducedDistanceMap.lock();
            
            //pre-processing
            updateDistanceMap();
            reduceDistanceMap();
            
            //rendering
            result.fillRect(result.rect, 0xFFFFFF);
            renderLight();
            blurLight();
            renderObstacles();
            
            result.unlock();
            distanceMap.unlock();
            reducedDistanceMap.unlock();
        }
        
        private function updateDistanceMap():void 
        {
            distanceMap.fillRect(distanceMap.rect, 0xFFFFFF);
            
            var mx:Number = stage.mouseX * obstacleMap.width / stage.stageWidth;
            var my:Number = stage.mouseY * obstacleMap.height / stage.stageHeight;
            
            for (var j:int = 0; j < distanceMap.height; ++j)
            {
                for (var i:int = 0; i < distanceMap.width; ++i)
                {
                    //polar to cartesian
                    var r:Number = LIGHT_RADIUS * (i / distanceMap.width);
                    var t:Number = TWO_PI * (j/ distanceMap.height);
                    var cx:Number = r * Math.cos(t) + mx;
                    var cy:Number = r * Math.sin(t) + my;
                    
                    if 
                    (
                        cx >= 0 && cx <= obstacleMap.width 
                        && cy >= 0 && cy <= obstacleMap.height
                    )
                    {
                        var dx:Number = cx - mx;
                        var dy:Number = cy - my;
                        var dist:Number = Math.sqrt(dx * dx + dy * dy);
                        
                        if (dist > LIGHT_RADIUS)
                        {
                            //out of light radius
                            distanceMap.setPixel(i, j, 0xFFFFFF);
                        }
                        else
                        {
                            //draw distance color
                            var channel:uint = 0xFF * (dist / LIGHT_RADIUS);
                            var color:uint = 0;
                            color |= channel << 16;
                            color |= channel << 8;
                            color |= channel;
                            distanceMap.setPixel
                            (
                                i, j, 
                                (obstacleMap.getPixel(cx, cy) < 0xFFFFFF)
                                ?(color):(0xFFFFFF)
                            );
                        }
                    }
                }
            }
        }
        
        private function reduceDistanceMap():void 
        {
            reducedDistanceMap.fillRect(reducedDistanceMap.rect, 0xFFFFFF);
            for (var t:int = 0; t < reducedDistanceMap.height; ++t)
            {
                for (var i:int = 0; i < distanceMap.width; ++i)
                {
                    var color:uint = distanceMap.getPixel(i, t);
                    if (color != 0xFFFFFF)
                    {
                        reducedDistanceMap.setPixel(0, t, color);
                        break;
                    }
                }
            }
        }
        
        private function renderLight():void 
        {
            var mx:Number = stage.mouseX * result.width / stage.stageWidth;
            var my:Number = stage.mouseY * result.height / stage.stageHeight;
            for (var j:int = 0; j < result.width; ++j)
            {
                for (var i:int = 0; i < result.height; ++i)
                {
                    var dx:Number = i - mx;
                    var dy:Number = j - my;
                    var dist:Number = Math.sqrt(dx * dx + dy * dy);
                    var obstacleDist:Number;
                    var color:uint;
                    var channel:uint;
                    var distFactor:Number = Math.atan2(dy, dx);
                    if (distFactor < 0) distFactor += TWO_PI;
                    distFactor /= TWO_PI;
                    
                    obstacleDist = 
                        LIGHT_RADIUS
                        * reducedDistanceMap.getPixel
                        (0, reducedDistanceMap.height * distFactor);
                        
                    obstacleDist /= 0xFFFFFF;
                    
                    if (dist < obstacleDist)
                    {
                        channel = 0xFF * (1 - dist / LIGHT_RADIUS);
                        color = 0;
                        color |= channel << 16;
                        color |= channel << 8;
                        color |= channel;
                    }
                    else
                    {
                        color = 0x000000;
                    }
                    
                    result.setPixel(i, j, color);
                }
            }
        }
        
        private function blurLight():void
        {
            var mx:Number = stage.mouseX * result.width / stage.stageWidth;
            var my:Number = stage.mouseY * result.height / stage.stageHeight;
            
            resultBlurTemp.copyPixels(result, result.rect, new Point(0, 0));
            
            //distance-based blur
            for (var j:int = 0; j < result.height; ++j)
            {
                for (var i:int = 0; i < result.width; ++i)
                {
                    var dx:Number = i - mx;
                    var dy:Number = j - my;
                    var d:Number = 
                        DIST_BLUR_FACTOR 
                        * (Math.sqrt(dx * dx + dy * dy) - DIST_BLUR_THRESHOLD);
                        
                    d = (d < 0)?(0):(d);
                    var channel:uint = 
                        (
                            4 * (result.getPixel(i, j) & 0xFF)
                            + 2 * (result.getPixel(i - d / 2, j - d / 2) & 0xFF)
                            + 2 * (result.getPixel(i + d / 2, j - d / 2) & 0xFF)
                            + 2 * (result.getPixel(i + d / 2, j + d / 2) & 0xFF)
                            + 2 * (result.getPixel(i - d / 2, j + d / 2) & 0xFF)
                            + (result.getPixel(i - d, j) & 0xFF)
                            + (result.getPixel(i, j - d) & 0xFF)
                            + (result.getPixel(i + d, j) & 0xFF)
                            + (result.getPixel(i, j + d) & 0xFF)
                        ) / 16;
                    var color:uint = 0;
                    color |= channel << 16;
                    color |= channel << 8;
                    color |= channel;
                    
                    resultBlurTemp.setPixel(i, j, color);
                }
            }
            
            var temp:BitmapData = result;
            result = resultBlurTemp;
            resultBlurTemp = temp;
            resultBMP.bitmapData = result;
            
            //global blur
            result.applyFilter
            (
                result, result.rect, new Point(0, 0), 
                new BlurFilter(BLUR, BLUR, 2)
            );
        }
        
        private function renderObstacles():void 
        {
            result.draw
            (
                obstacles, 
                new Matrix
                (
                    result.width / stage.stageWidth, 0, 
                    0, result.height / stage.stageHeight
                )
            );
        }
        
        private function regenerateObstacles(e:Event = null):void
        {
            while (obstacles.numChildren) obstacles.removeChildAt(0);
            
            for (var i:int = 0; i < NUM_OBSTACLES; ++i)
            {
                var shape:Shape = new Shape();
                var size:Number = 
                    OBSTACLE_SIZE 
                    + OBSTACLE_SIZE_VAR * (2 * (0.5 - Math.random()));
                
                shape.graphics.beginFill(0x808080, 1);
                shape.graphics.drawRect( -0.5 * size, -0.5 * size, size, size);
                shape.rotation = 360 * Math.random();
                shape.x = stage.stageWidth * Math.random();
                shape.y = stage.stageHeight * Math.random();
                obstacles.addChild(shape);
            }
            
            obstacleMap.lock();
            
            obstacleMap.fillRect(obstacleMap.rect, 0xFFFFFF);
            obstacleMap.draw
            (
                obstacles, 
                new Matrix
                (
                    obstacleMap.width / stage.stageWidth, 0, 
                    0, obstacleMap.height / stage.stageHeight
                )
            );
            obstacleMap.threshold
            (
                obstacleMap, obstacleMap.rect, new Point(0, 0), "<", 
                0xFF0000, 0x000000, 0xFF0000, true
            );
            
            obstacleMap.unlock();
            
            //update
            mainLoop();
        }
        
        private function showResult(e:Event = null):void
        {
            resultBMP.visible = true;
            obstacles.visible = true;
            dataBMP.visible = false;
        }
        
        private function showObstacleMap(e:Event = null):void
        {
            resultBMP.visible = false;
            obstacles.visible = false;
            dataBMP.visible = true;
            
            dataBMP.bitmapData = obstacleMap;
            dataBMP.scaleX = stage.stageWidth / obstacleMap.width;
            dataBMP.scaleY = stage.stageHeight / obstacleMap.height;
        }
        
        private function showDistanceMap(e:Event = null):void
        {
            resultBMP.visible = false;
            obstacles.visible = false;
            dataBMP.visible = true;
            
            dataBMP.bitmapData = distanceMap;
            dataBMP.scaleX = stage.stageWidth / distanceMap.width;
            dataBMP.scaleY = stage.stageHeight / distanceMap.height;
        }
        
        private function showReducedDistanceMap(e:Event = null):void
        {
            resultBMP.visible = false;
            obstacles.visible = false;
            dataBMP.visible = true;
            
            dataBMP.bitmapData = reducedDistanceMap;
            dataBMP.scaleX = stage.stageWidth / reducedDistanceMap.width;
            dataBMP.scaleY = stage.stageHeight / reducedDistanceMap.height;
        }
    }
}
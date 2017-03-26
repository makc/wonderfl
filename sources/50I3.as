package 
{
    // read more and download pbk file here:
    // http://3ddm.yoz.sk/
    // http://blog.yoz.sk/2010/05/pixel-bender-displacement-map-fakes-3d-effect
    
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Loader;
    import flash.display.Shader;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.filters.BitmapFilterQuality;
    import flash.filters.BlurFilter;
    import flash.filters.ShaderFilter;
    import flash.geom.Point;
    import flash.net.URLLoader;
    import flash.net.URLLoaderDataFormat;
    import flash.net.URLRequest;
    import flash.system.LoaderContext;
    import flash.utils.ByteArray;
    
    [SWF(width="465", height="465", frameRate="30", backgroundColor="#FFFFFF")]
    
    public class PBDisplacement extends Sprite
    {
        private var sourcePath:String = "http://blog.yoz.sk/examples/pixelBenderDisplacement/";
        private var index:int = -1;
        private var sources:Array = [
            {image:"car.jpg", map:"carMap.jpg"},
            {image:"china.jpg", map:"chinaMap.jpg"},
            {image:"landscape.jpg", map:"landscapeMap.jpg"},
            {image:"mountain.jpg", map:"mountainMap.jpg"}
        ]
        
        private var shaderLoader:URLLoader = new URLLoader();
        private var shaderURL:String = "http://blog.yoz.sk/examples/pixelBenderDisplacement/displacementMapFader.pbj";
        private var shader:Shader;
        private var filter:ShaderFilter;
        
        private var imageLoader:Loader = new Loader();
        private var imageLegend:Bitmap = new Bitmap();
        
        private var mapLoader:Loader = new Loader();
        private var mapLegend:Bitmap = new Bitmap();
        
        private var imageContainer:Sprite = new Sprite();
        private var shape:Sprite = new Sprite();
        
        public function PBDisplacement():void
        {
            imageContainer.x = stage.stageWidth / 2;
            imageContainer.y = stage.stageHeight / 2;
            addChild(imageContainer);
            
            shape.graphics.beginFill(0, 0);
            shape.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
            shape.graphics.endFill();
            addChild(shape);
            
            shaderLoader.dataFormat = URLLoaderDataFormat.BINARY;
            shaderLoader.load(new URLRequest(shaderURL));
            shaderLoader.addEventListener(Event.COMPLETE, shaderComplete);
            
            addEventListener(Event.ENTER_FRAME, enterFrame);
            addEventListener(MouseEvent.CLICK, changeSource);
            changeSource();
        }
        
        private function changeSource(... rest):void
        {
            index = index + 1 >= sources.length ? 0 : index + 1;
            var source:Object = sources[index];
            
            var type:String = Event.COMPLETE;
            var context:LoaderContext = new LoaderContext(true);
            
            if(imageLoader)
                imageLoader.unload();
            
            var imageRequest:URLRequest = new URLRequest(sourcePath + source.image);
            imageLoader.load(imageRequest, context);
            imageLoader.contentLoaderInfo.addEventListener(type, imageComplete);
            imageContainer.addChild(imageLoader);
            
            if(mapLoader)
                mapLoader.unload();
            
            var mapRequest:URLRequest = new URLRequest(sourcePath + source.map);
            mapLoader.load(mapRequest, context);
            mapLoader.contentLoaderInfo.addEventListener(type, mapComplete);
        }
        
        private function shaderComplete(event:Event):void
        {
            var loader:URLLoader = URLLoader(event.currentTarget);
            shader = new Shader(loader.data as ByteArray);
            filter = new ShaderFilter(shader);
            testComplete();
        }
        
        private function imageComplete(event:Event):void
        {
            imageLoader.x = -imageLoader.width / 2;
            imageLoader.y = -imageLoader.height / 2;
            testComplete();
            
            var image:Bitmap = Bitmap(imageLoader.content)
            imageLegend.bitmapData = image.bitmapData.clone();
            imageLegend.width = 100;
            imageLegend.height = imageLegend.bitmapData.height
                * imageLegend.width / imageLegend.bitmapData.width;
            addChild(imageLegend); 
        }
        
        private function mapComplete(event:Event):void
        {
            testComplete();
            
            var map:Bitmap = Bitmap(mapLoader.content)
            mapLegend.bitmapData = map.bitmapData.clone();
            mapLegend.width = 100;
            mapLegend.height = mapLegend.bitmapData.height 
                * mapLegend.width / mapLegend.bitmapData.width;
            mapLegend.x = stage.stageWidth - mapLegend.width;
            addChild(mapLegend); 
        }
        
        private function testComplete():void
        {
            if(!filter || !imageLoader.content || !mapLoader.content)
                return;
                
            var map:BitmapData = Bitmap(mapLoader.content).bitmapData;
            var image:BitmapData = Bitmap(imageLoader.content).bitmapData;
            var fader:BitmapData = new BitmapData(image.width, image.height, true, 0);
            fader.draw(image);
            fader.applyFilter(fader, fader.rect, new Point(), 
                new BlurFilter(5, 5, BitmapFilterQuality.HIGH));
            
            shader.data.map.input = map;
            shader.data.fader.input = fader;
            shader.data.fadeNear.value = [0];
            shader.data.fadeDistant.value = [1];
        }
        
        private function enterFrame(event:Event):void
        {
            if(!filter || !imageLoader.content || !mapLoader.content)
                return;
            
            var dx:Number = (stage.stageWidth / 2 - mouseX);
            var dy:Number = (stage.stageHeight / 2 - mouseY);
            
            imageContainer.rotationX -= (imageContainer.rotationX + dy / 15) / 10;
            imageContainer.rotationY -= (imageContainer.rotationY - dx / 15) / 10;
            
            shader.data.dx.value = [imageContainer.rotationY * 1.5];
            shader.data.dy.value = [-imageContainer.rotationX * 1.5];
            imageLoader.filters = [filter];
        }
    }
}
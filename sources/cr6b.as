// 2011-05-12 18:30:28
package
{
    import flash.system.LoaderContext;
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Loader;
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.net.URLRequest;
    import flash.utils.getTimer;
    
    [SWF(backgroundColor="#ffffff", frameRate="30")]
    
    public class Main extends Sprite
    {
        private var buffer:BitmapData;
        private var texture:BitmapData;
        private var frames:Array;
        private var numFrames:uint = 0;
        
        public function Main() 
        {
            if(stage) init();
            else this.addEventListener(Event.ADDED_TO_STAGE, onAdded);
        }
        private function onAdded(e:Event):void {
            this.removeEventListener(Event.ADDED_TO_STAGE, onAdded);
            init();
        }
        private function init():void
        {
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
            
            buffer = new BitmapData(403, 156, false, 0xffffff);
            var canvas:Bitmap = new Bitmap(buffer);
            canvas.x = stage.stageWidth - canvas.width >> 1;
            canvas.y = stage.stageHeight - canvas.height >> 1;
            this.addChild(canvas);
            
            var loader:Loader = new Loader();
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete);
            loader.load(new URLRequest("http://assets.wonderfl.net/images/related_images/9/9b/9be5/9be5c1bcf6cb49644f8e061e5cfdc6801eb5f22f"), new LoaderContext(true));
        }
        
        private function getFrames():Array
        {
            var list:Array = [];
            var d:Array = [[307, 48, 88, 89], [307, 48, 89, 89], [307, 48, 91, 89], [305, 49, 93, 89], [305, 50, 93, 88], [305, 50, 93, 88], [306, 52, 92, 86], [305, 53, 93, 84], [305, 54, 94, 83], [306, 54, 93, 83], [307, 54, 92, 83], [307, 54, 92, 83], [308, 54, 90, 83], [308, 54, 90, 83], [306, 53, 91, 84], [306, 53, 91, 84], [308, 53, 90, 84], [308, 53, 90, 84], [305, 53, 92, 84], [305, 52, 92, 85], [306, 52, 91, 85], [308, 51, 88, 87, 1], [308, 50, 88, 88], [308, 49, 88, 88], [307, 49, 89, 88], [307, 50, 89, 87], [308, 51, 89, 86], [307, 54, 90, 83], [307, 57, 90, 80], [306, 58, 92, 79], [306, 58, 92, 79], [305, 60, 92, 77], [302, 61, 95, 76], [302, 63, 95, 74], [302, 51, 96, 86], [302, 66, 98, 71], [304, 67, 96, 69], [301, 63, 96, 74], [301, 58, 93, 79], [291, 52, 94, 85], [288, 50, 71, 88], [285, 43, 76, 95], [285, 37, 70, 101], [281, 29, 55, 109], [278, 20, 58, 119], [278, 20, 55, 119, 1], [277, 12, 121, 127], [271, 2, 122, 138], [267, 1, 126, 139], [264, 0, 136, 140], [260, 0, 141, 140], [255, 0, 148, 140], [252, 0, 151, 140], [249, 2, 121, 138], [247, 3, 123, 137], [246, 3, 123, 137], [246, 2, 124, 137], [258, 2, 112, 137], [263, 2, 106, 137], [263, 2, 106, 137], [262, 2, 103, 137], [260, 2, 104, 136], [260, 2, 104, 137, 1], [268, 2, 98, 137], [267, 2, 99, 137], [266, 2, 97, 137], [266, 3, 96, 136], [264, 3, 99, 136], [263, 3, 100, 136], [261, 3, 100, 136], [259, 2, 138, 137], [254, 2, 126, 137], [247, 2, 101, 136], [240, 2, 108, 136], [238, 1, 110, 137], [230, 1, 118, 138], [220, 15, 128, 124], [211, 18, 137, 121], [205, 43, 102, 96], [202, 45, 104, 93], [200, 38, 97, 101], [198, 38, 104, 101, 1], [197, 39, 107, 100], [197, 39, 112, 100], [213, 39, 94, 110], [212, 40, 95, 111], [211, 41, 97, 111], [209, 42, 99, 112], [209, 43, 98, 112], [213, 43, 87, 112], [213, 42, 83, 113], [211, 40, 86, 109], [211, 38, 86, 103], [211, 37, 88, 112], [211, 20, 186, 131], [213, 27, 167, 122], [212, 44, 87, 105], [210, 44, 88, 98], [195, 44, 106, 98], [189, 44, 110, 98], [182, 46, 117, 99], [173, 44, 118, 96, 1], [161, 43, 130, 99], [154, 42, 137, 97], [153, 42, 137, 97], [153, 42, 137, 97], [152, 41, 137, 98], [151, 41, 137, 97], [149, 41, 145, 97], [148, 25, 144, 114], [148, 13, 144, 126], [141, 12, 153, 127], [115, 11, 173, 128], [108, 7, 180, 133], [108, 4, 180, 136], [108, 3, 176, 137, 1], [108, 1, 161, 139], [105, 1, 235, 138], [103, 1, 295, 148], [103, 0, 277, 149], [108, 0, 234, 137], [101, 0, 232, 137], [99, 0, 135, 139], [95, 0, 244, 139], [81, 0, 152, 139], [69, 0, 164, 139, 1], [66, 0, 169, 139], [65, 0, 170, 139], [63, 0, 168, 138], [61, 0, 159, 138], [35, 0, 304, 139], [19, 0, 189, 140], [18, 11, 138, 129], [18, 11, 137, 129], [18, 11, 137, 128], [18, 6, 135, 133], [7, 4, 146, 136], [6, 4, 147, 136], [3, 4, 150, 136, 1], [3, 5, 150, 135], [3, 8, 150, 132], [4, 6, 394, 145], [12, 6, 388, 145], [11, 8, 389, 144], [11, 8, 387, 144], [11, 8, 387, 143, 1], [10, 8, 113, 131], [11, 8, 111, 131], [10, 9, 112, 130], [12, 9, 116, 130], [12, 9, 111, 130], [12, 9, 111, 130], [12, 9, 110, 131], [12, 34, 113, 106], [13, 35, 110, 104]];
            var f:int, i:int, g:int, h:int;
            var a:Array;
            var len:int = d.length;
            for(f = 0; f < len; ++f) {
                a = d[f];
                list.push({left:a[0], top:a[1], width:a[2], height:a[3], offsetX:g, offsetY:h });
                if(a[3] > i) {i = a[3]};
                if(a[4]) {g = 0; h += i; i = 0;} else { g += a[2] };
            }
            return list;
        }
        
        private function onLoadComplete(event:Event):void
        {
            this.texture = event.currentTarget.content.bitmapData;
            this.frames = getFrames();
            this.numFrames = frames.length;
            this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
        }
        
        private var t0:int, t1:int;
        private var frame:Object, count:int = 0;
        private var rect:Rectangle = new Rectangle();
        private var pt:Point = new Point();
        private function onEnterFrame(event:Event):void
        {
            t1 = getTimer();
            if((t1 - t0) < 83) return; else t0 = t1;
            
            if(count < numFrames) {
                frame = frames[count];
                rect.x = frame.offsetX;
                rect.y = frame.offsetY;
                rect.width = frame.width;
                rect.height = frame.height;
                pt.x = frame.left;
                pt.y = frame.top;
                buffer.copyPixels(texture, rect, pt);
                count++;
            }
            else {
                buffer.fillRect(buffer.rect, 0xffffff);
                count = 0;
            }
        }
    }
}
package {
    import flash.net.URLRequest;
    import flash.events.Event;
    import flash.net.URLLoader;
    import flash.display.*;
    public class MediaRSSReader extends Sprite {
        private var _feed:String = "http://api.flickr.com/services/feeds/photos_public.gne?tags=kamakura&format=rss_200";
        private var media:Namespace = new Namespace("http://search.yahoo.com/mrss/");
        
        public function MediaRSSReader() {
            var ldr:URLLoader = new URLLoader;
            ldr.addEventListener(Event.COMPLETE, function _load(e:Event):void {
                ldr.removeEventListener(Event.COMPLETE, _load);
                onImageLoaded(XML(ldr.data)..media::thumbnail.@url.toXMLString().split('\n'));
            });
            ldr.load(new URLRequest(_feed));
        }
        
        private function onImageLoaded($images:Array):void {
            var container:Sprite = new Sprite;
            var ldr:Loader;
            for (var i:int = 0; i < $images.length; ++i) {
                ldr = new Loader;
                ldr.load(new URLRequest($images[i]));
                ldr.x = (i % 5) * 85;
                ldr.y = Math.floor(i / 5) * 85;
                container.addChild(ldr);
            }
            container.x = container.y = 15;
            addChild(container);
        }
    }
}

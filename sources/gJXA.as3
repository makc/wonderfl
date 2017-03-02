package {
    import flash.display.Loader;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.net.URLLoader;
    import flash.net.URLRequest;
    import flash.system.Security;
    import flash.text.TextField;
    public class FlashTest extends Sprite {
        
        // Wrap url in proxy parameter.
        private function proxy(url:String):String {
            return 'http://www.gmodules.com/ig/proxy?url=' + encodeURIComponent(url);
        }
        
        public function FlashTest() {
            // Only the top level movie starts off with stage populated.
            if (stage) {
                // The top level movie is likely included from wonderfl.net and therefore unproxied.
                // All we do in this case is load the proxied version.
                // Allow the proxy domain so wee can access stage on lines 45-46.
                Security.allowDomain('www.gmodules.com');
                var l:Loader = new Loader();
                l.load(new URLRequest(proxy(loaderInfo.url)));
                addChild(l);
                return;
            } else {
                // Allow Wonderfl to take a screen cap.
                Security.allowDomain('swf.wonderfl.net');
                addEventListener(Event.ADDED_TO_STAGE, init);
            }
        }
        
        private function init(e:Event):void {
            removeEventListener(Event.ADDED_TO_STAGE, init);
            
            // Now you write your own code.
            // Since the inner proxied movie is in the proxy's domain, we can request anything.
            var ul:URLLoader = new URLLoader(new URLRequest(proxy('http://www.example.com/')));
            ul.addEventListener(Event.COMPLETE, complete);
        }
        
        private function complete(e:Event):void {
            var tf:TextField = new TextField();
            // The two lines below would fail if we didn't allow access on line 21.
            tf.width = stage.stageWidth;
            tf.height = stage.stageHeight;
            tf.text = e.target.data;
            addChild(tf);
        }
        
    }
}

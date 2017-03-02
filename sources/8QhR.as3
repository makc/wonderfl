package {

    import flash.display.Sprite;
    import flash.events.Event;
    import flash.net.URLLoader;
    import flash.net.URLRequest;
    
    [SWF(backgroundColor="0xffffff", frameRate="60", width="465", height="465")]

    /**
     * @author Saqoosha
     */
    public class test51_airpen extends Sprite {



        private static const SCALE:Number = 0.02;


        private var _index:int;
        private var _points:Vector.<Number> = new Vector.<Number>();


        public function test51_airpen() {
            var loader:URLLoader = new URLLoader();
            loader.addEventListener(Event.COMPLETE, _onLoaded);
            loader.load(new URLRequest('https://saqoo.sh/a/labs/wonderfl/110224%20174249.svg'));
        }


        private function _onLoaded(event:Event):void {
            var data:XML = new XML(event.target.data);
            var svg:Namespace = data.namespace();
            for each (var path:XML in data..svg::path) {
                for each (var p:String in path.@d.match(/\d+/g)) {
                    _points.push(Number(p) * SCALE);
                }
            }
            graphics.clear();
            _index = 0;
            addEventListener(Event.ENTER_FRAME, _onEnterFrame);
        }


        private function _onEnterFrame(e:Event):void {
            var n:int = 5;
            while (n--) {
                _draw();
                if (_index == _points.length) {
                    removeEventListener(Event.ENTER_FRAME, _onEnterFrame);
                    break;
                }
            }
        }


        private function _draw():void {
            graphics.lineStyle(0, 0x0);
            graphics.moveTo(_points[_index++], _points[_index++]);
            graphics.lineTo(_points[_index++], _points[_index++]);
        }
    }
}

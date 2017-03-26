package {

    import com.bit101.components.CheckBox;
    import com.bit101.components.HUISlider;
    import com.bit101.components.PushButton;
    import com.bit101.components.VBox;

    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Loader;
    import flash.display.LoaderInfo;
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageQuality;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.net.URLRequest;
    import flash.system.LoaderContext;


    /**
     * @author Saqoosha
     */
    [SWF(backgroundColor="0xFFFFFF", frameRate="60", width="1024", height="768")]
    public class ElasticImage extends Sprite {
        
        
        private var _numSegments:int = 20;
        private var _segmentLength:Number = 10;
        
        private var _segmentsSlider:HUISlider;
        private var _dragSlider:HUISlider;
        private var _debugCheckBox:CheckBox;
        
        private var _dragging:Anchor = null;
        private var _anchors:Vector.<Anchor>;
        
        private var _image:BitmapData;
        private var _vertices:Vector.<Number>;
        private var _indices:Vector.<int>;
        private var _uvtData:Vector.<Number>;
        
        
        public function ElasticImage() {
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
            stage.quality = StageQuality.LOW;
            
            var loader:Loader = new Loader();
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, _onImageLoaded);
            loader.load(new URLRequest('http://saqoo.sh/a/tmp/Saqoosha256.png'), new LoaderContext(true));
        }


        private function _onImageLoaded(e:Event):void {
            _image = Bitmap(LoaderInfo(e.target).content).bitmapData;
            
            var vbox:VBox = new VBox(this, 10, 10);
            _segmentsSlider = new HUISlider(vbox, 0, 0, 'NUM SEGMENTS');
            _segmentsSlider.minimum = 3;
            _segmentsSlider.maximum = 20;
            _segmentsSlider.value = 8;
            _segmentsSlider.tick = 1;
            _segmentsSlider.labelPrecision = 0;
            _segmentsSlider.width = 300;
            new PushButton(vbox, 0, 0, 'REBUILD', _onClickRebuild);
            _dragSlider = new HUISlider(vbox, 0, 0, 'DRAG');
            _dragSlider.minimum = 0.1;
            _dragSlider.maximum = 0.9;
            _dragSlider.value = 0.5;
            _dragSlider.tick = 0.01;
            _dragSlider.labelPrecision = 2;
            _dragSlider.width = 300;
            _debugCheckBox = new CheckBox(vbox, 0, 0, 'DEBUG');
            _debugCheckBox.selected = false;
            
            _onClickRebuild();
            
            stage.addEventListener(MouseEvent.MOUSE_DOWN, _onMouseDown);
            addEventListener(Event.ENTER_FRAME, _draw);
        }


        private function _onClickRebuild(e:Event = null):void {
            _numSegments = _segmentsSlider.value;
            _segmentLength = 200 / (_numSegments - 1);
            _anchors = new Vector.<Anchor>();
            _vertices = new Vector.<Number>();
            _indices = new Vector.<int>();
            _uvtData = new Vector.<Number>();
            var n:int = _numSegments - 1;
            var x:int, y:int;
            for (y = 0; y < _numSegments; y++) {
                for (x = 0; x < _numSegments; x++) {
                    _anchors.push(new Anchor(x * _segmentLength, y * _segmentLength));
                    _vertices.push(0, 0);
                    if (x > 0 && y > 0) {
                        var index:int = x + y * _numSegments;
                        _indices.push(index - _numSegments - 1, index - _numSegments, index - 1);
                        _indices.push(index - _numSegments, index, index - 1);
                    }
                    _uvtData.push(x / n, y / n);
                }
            }
            _retargetAnchors(_anchors[0]);
        }
        
        
        private function _onMouseDown(e:MouseEvent):void {
            if (e.target != stage) return;
            stage.addEventListener(MouseEvent.MOUSE_MOVE, _onMouseMove);
            stage.addEventListener(MouseEvent.MOUSE_UP, _onMouseUp);
            
            var minDist:Number = Number.MAX_VALUE;
            for each (var a:Anchor in _anchors) {
                var dx:Number = mouseX - a.x;
                var dy:Number = mouseY - a.y;
                var d:Number = dx * dx + dy * dy;
                if (d < minDist) {
                    _dragging = a;
                    minDist = d;
                }
            }
            _retargetAnchors(_dragging);
            _dragging.x = mouseX;
            _dragging.y = mouseY;
        }


        private function _onMouseMove(e:MouseEvent):void {
            _dragging.x = mouseX;
            _dragging.y = mouseY;
        }


        private function _onMouseUp(e:MouseEvent):void {
            stage.removeEventListener(MouseEvent.MOUSE_MOVE, _onMouseMove);
            stage.removeEventListener(MouseEvent.MOUSE_UP, _onMouseUp);
            _dragging = null;
        }
        
        
        private function _retargetAnchors(origin:Anchor):void {
            origin.target = null;
            var x:int, y:int;
            for (y = 0; y < _numSegments; y++) {
                for (x = 0; x < _numSegments; x++) {
                    var index:int = y * _numSegments + x;
                    var a:Anchor = _anchors[index];
                    if (a == origin) continue;
                    var dx:int = a.x - origin.x;
                    var dy:int = a.y - origin.y;
                    if (Math.abs(dx) > Math.abs(dy)) {
                        if (dx > 0) {
                            a.target = _anchors[index - 1];
                            a.offsetX = _segmentLength;
                        } else {
                            a.target = _anchors[index + 1];
                            a.offsetX = -_segmentLength;
                        }
                        a.offsetY = 0;
                    } else {
                        if (dy > 0) {
                            a.target = _anchors[index - _numSegments];
                            a.offsetY = _segmentLength;
                        } else {
                            a.target = _anchors[index + _numSegments];
                            a.offsetY = -_segmentLength;
                        }
                        a.offsetX = 0;
                    }
                }
            }
        }
        
        
        private function _draw(e:Event = null):void {
            var a:Anchor;
            var index:int = 0;
            var drag:Number = _dragSlider.value;
            for (var i:int = 0, n:int = _anchors.length; i < n; i++) {
                a = _anchors[i];
                if (a.target) {
                    a.x += (a.target.x + a.offsetX - a.x) * drag;
                    a.y += (a.target.y + a.offsetY - a.y) * drag;
                }
                _vertices[index++] = a.x;
                _vertices[index++] = a.y;
            }
            
            graphics.clear();
            graphics.beginBitmapFill(_image);
            graphics.drawTriangles(_vertices, _indices, _uvtData);
            graphics.endFill();
            if (_debugCheckBox.selected) {
                for each (a in _anchors) {
                    if (a.target) {
                        graphics.lineStyle(0, 0x7c93ff);
                        graphics.moveTo(a.x, a.y);
                        graphics.lineTo(a.x + (a.target.x - a.x) * .5, a.y + (a.target.y - a.y) * .7);
                        graphics.lineStyle();
                    }
                    graphics.beginFill(0xff487b);
                    graphics.drawCircle(a.x, a.y, 3);
                    graphics.endFill();
                }
            }
        }
    }
}


class Anchor {
    
    
    public var x:Number;
    public var y:Number;
    public var target:Anchor = null;
    public var offsetX:Number = 0;
    public var offsetY:Number = 0;


    public function Anchor(x:Number = 0, y:Number = 0, target:Anchor = null) {
        this.y = y;
        this.x = x;
        this.target = target;
        if (target) {
            offsetX = x - target.x;
            offsetY = y - target.y;
        }
    }
}

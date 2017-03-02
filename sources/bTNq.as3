/* ------------------------------------------------------------------------------------------------
 * NESIcon
 * http://wonderfl.net/c/bTNq 
 * ファミコン風ドット絵アイコン投稿サイト「wonderfl」
 * http://wonderfl.net/c/xgnq
 * ------------------------------------------------------------------------------------------------
 */
package {
    import flash.display.BitmapData;
    import flash.display.DisplayObject;
    import flash.display.Loader;
    import flash.display.LoaderInfo;
    import flash.display.Sprite;
    import flash.events.Event;
    import mx.utils.Base64Decoder;
    
    [SWF(width="465",height="465")]
    public class Main extends Sprite {
        private var _data:XML =
// "CopyToCilpboard"で生成されたテキストを、<paste-here> ... </paste-here> の中にコピペして下さい。
<paste-here>

</paste-here>;
        
        private var _canvas:Canvas;
        private var _palette:Palette;
        
        public function Main() {
            graphics.beginFill(0x404040);
            graphics.drawRect(0, 0, 465, 465);
            graphics.endFill();
            
            //TextBuilder.deviceFonts = true;
            
            var preloader:Preloader = new Preloader(this);
            preloader.addImageLoadingRequest( {
                pen: "http://assets.wonderfl.net/images/related_images/2/20/20ee/20eeb12b70937edaaa5630a9776f6c3ed9e21b37",
                picker: "http://assets.wonderfl.net/images/related_images/8/8d/8db9/8db927b851af0fdb8d2192c53316d1c299383e04",
                fill: "http://assets.wonderfl.net/images/related_images/9/97/9754/9754d617bb538d09d3b6bc2c742b4ef4374289fd",
                replace: "http://assets.wonderfl.net/images/related_images/4/45/45d3/45d31cbde12753c6afd7dae882cdc4d682a60f35"
            }, Assets.addImage);
            preloader.addFontLoadingRequest(["IPAGP"]);
            preloader.addEventListener(Event.COMPLETE, initialize);
            preloader.load();
        }
        
        private function initialize(event:Event):void {
            Hotkey.initialize(stage);
            
            _canvas = new Canvas(48, 8);
            _canvas.x = _canvas.y = 2;
            addChild(_canvas);
            
            var sameSizeView:Sprite = _canvas.createSameSizeView();
            sameSizeView.x = 402; sameSizeView.y = 3;
            addChild(sameSizeView);
            
            _palette = new Palette();
            _palette.x = int((465 - _palette.width) / 2); _palette.y = 390;
            addChild(_palette);
            
            var dotter:Dotter = new Dotter(_canvas, _palette);
            
            var file:FileWindow = new FileWindow(dotter);
            file.x = 388; file.y = 55;
            addChild(file);
            var edit:EditWindow = new EditWindow(dotter);
            edit.x = 388; edit.y = 138;
            addChild(edit);
            var view:ViewWindow = new ViewWindow(_canvas.toggleGridLines, _palette.toggleUseCount);
            view.x = 388; view.y = 326;
            addChild(view);
            
            loadData();
        }
        
        private function loadData():void {
            var base64:Base64Decoder = new Base64Decoder();
            var data:String = _data.toString() || "iVBORw0KGgoAAAANSUhEUgAAADAAAAAwCAYAAABXAvmHAAAAQElEQVR42u3PMQ0AAAjAsPk3DRZ4SXpUQKvmOQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQGBmwVaj/d5qIRVjwAAAABJRU5ErkJggg==";
            base64.decode(data);
            var loader:Loader = new Loader();
            loader.contentLoaderInfo.addEventListener(Event.INIT, setDataToCanvas);
            loader.loadBytes(base64.toByteArray());
        }
        
        private function setDataToCanvas(event:Event):void {
            event.target.removeEventListener(Event.INIT, setDataToCanvas);
            
            var image:DisplayObject = LoaderInfo(event.target).content;
            var bmd:BitmapData = new BitmapData(_canvas.size, _canvas.size, false, 0x000000);
            bmd.draw(image);
            
            _canvas.lock();
            for (var row:int = 0; row < _canvas.size; row++) {
                for (var col:int = 0; col < _canvas.size; col++) {
                    _canvas.getPixelAt(col, row).color = _palette.getColorFrom(bmd.getPixel(col, row));
                }
            }
            _canvas.unlock();
        }
    }
}
/* ------------------------------------------------------------------------------------------------
 * Canvas
 * ------------------------------------------------------------------------------------------------
 */
//package {
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.CapsStyle;
    import flash.display.JointStyle;
    import flash.display.LineScaleMode;
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    
    //public 
    class Canvas extends Sprite {
        private var _pixels:Vector.<Vector.<Pixel>>;
        private var _bitmapData:BitmapData;
        private var _gridLines:Shape;
        private var _cursor:Shape;
        
        public function Canvas(size:int, scale:int) {
            var enlargedSize:int = size * scale;
            
            _pixels = new Vector.<Vector.<Pixel>>(size, true);
            for (var row:int = 0; row < size; row++) {
                _pixels[row] = new Vector.<Pixel>(size, true);
                for (var col:int = 0; col < size; col++) {
                    var pixel:Pixel = new Pixel(col, row, scale);
                    pixel.addEventListener(Event.CHANGE, updateBitmapData);
                    addChild(_pixels[row][col] = pixel);
                }
            }
            _bitmapData = new BitmapData(size, size, false, 0x000000);
            addChild(_gridLines = createGridLines(enlargedSize, scale));
            addChild(_cursor = createCursor(scale));
            _cursor.visible = false;
            
            addEventListener(MouseEvent.ROLL_OVER, showCursor);
            addEventListener(MouseEvent.ROLL_OUT, hideCursor);
        }
        
        private function updateBitmapData(event:Event):void {
            var pixel:Pixel = Pixel(event.target);
            _bitmapData.setPixel(pixel.col, pixel.row, pixel.color.value);
        }
        
        private function createGridLines(size:int, cellSize:int):Shape {
            var gridLines:Shape = new Shape();
            gridLines.graphics.lineStyle(0, 0x404040, 1, true, LineScaleMode.NONE, CapsStyle.NONE, JointStyle.BEVEL);
            for (var i:int = 0; i <= size; i += cellSize) {
                gridLines.graphics.moveTo(i, 0);
                gridLines.graphics.lineTo(i, size);
                gridLines.graphics.moveTo(0, i);
                gridLines.graphics.lineTo(size, i);
            }
            return gridLines;
        }
        
        private function createCursor(size:int):Shape {
            var cursor:Shape = new Shape();
            cursor.graphics.lineStyle(0, 0xFFE000, 1, true, LineScaleMode.NONE, CapsStyle.NONE, JointStyle.BEVEL);
            cursor.graphics.drawRect(0, 0, size, size);
            cursor.graphics.endFill();
            return cursor;
        }
        
        private function showCursor(event:MouseEvent):void {
            _cursor.visible = true;
            addEventListener(MouseEvent.MOUSE_OVER, moveCursor);
        }
        
        private function hideCursor(event:MouseEvent):void {
            removeEventListener(MouseEvent.MOUSE_OVER, moveCursor);
            _cursor.visible = false;
        }
        
        private function moveCursor(event:MouseEvent):void {
            var pixel:Pixel = event.target as Pixel;
            if (pixel) {
                _cursor.x = pixel.x;
                _cursor.y = pixel.y;
            }
        }
        
        public function toggleGridLines():Boolean {
            return _gridLines.visible = !_gridLines.visible;
        }
        
        public function createSameSizeView():Sprite {
            var sprite:Sprite = new Sprite();
            sprite.addChild(new Bitmap(_bitmapData));
            return sprite;
        }
        
        public function lock():void { _bitmapData.lock(); }
        public function unlock():void { _bitmapData.unlock(); }
        
        public function get size():int { return _pixels.length; }
        public function getPixelAt(col:int, row:int):Pixel {
            var lastIndex:int = _pixels.length - 1;
            col = (col < 0) ? 0 : (col > lastIndex) ? lastIndex : col;
            row = (row < 0) ? 0 : (row > lastIndex) ? lastIndex : row;
            return _pixels[row][col];
        }
        public function get bitmapData():BitmapData { return _bitmapData.clone(); }
    }
//}
/* ------------------------------------------------------------------------------------------------
 * Pixel
 * ------------------------------------------------------------------------------------------------
 */
//package {
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.geom.ColorTransform;
    import org.libspark.betweenas3.BetweenAS3;
    import org.libspark.betweenas3.tweens.ITween;
    
    //public 
    class Pixel extends Sprite {
        private var _col:int;
        private var _row:int;
        private var _size:int;
        private var _color:ColorElement;
        private var _highlightTween:ITween;
        
        private var _prev:Pixel;
        private var _next:Pixel;
        
        public function Pixel(col:int, row:int, size:int) {
            _col = col;
            _row = row;
            _size = size;
            _color = null;
            _highlightTween = BetweenAS3.tween(
                transform,
                { colorTransform: { redMultiplier:1, greenMultiplier:1, blueMultiplier:1, redOffset:128, greenOffset:128, blueOffset:128 } },
                { colorTransform: { redMultiplier:0, greenMultiplier:0, blueMultiplier:0 } }
            );
            _highlightTween.stopOnComplete = false;
            _prev = _next = null;
            
            x = col * size;
            y = row * size;
        }
        
        public function showHighlight():void {
            _highlightTween.play();
            if (_next) { _next.showHighlight(); }
        }
        
        public function hideHighlight():void {
            if(_highlightTween.isPlaying){
                _highlightTween.gotoAndStop(0);
                transform.colorTransform = new ColorTransform();
            }
            if (_next) { _next.hideHighlight(); }
        }
        
        public function get col():int { return _col; }
        public function get row():int { return _row; }
        public function get color():ColorElement { return _color; }
        public function get prev():Pixel { return _prev; }
        public function get next():Pixel { return _next; }
        
        public function set color(value:ColorElement):void {
            if (_color) {
                _color.removeFromPixelList(this);
                _color.useCount--;
                hideHighlight();
            }
            _color = value;
            _color.useCount++;
            _color.addToPixelList(this);
            
            graphics.clear();
            graphics.beginFill(_color.value);
            graphics.drawRect(0, 0, _size, _size);
            graphics.endFill();
            
            dispatchEvent(new Event(Event.CHANGE));
        }
        public function set prev(value:Pixel):void { _prev = value; }
        public function set next(value:Pixel):void { _next = value; }
    }
//}
/* ------------------------------------------------------------------------------------------------
 * Palette
 * ------------------------------------------------------------------------------------------------
 */
 //package {
    import flash.display.CapsStyle;
    import flash.display.JointStyle;
    import flash.display.LineScaleMode;
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.utils.Dictionary;
    
    //public 
    class Palette extends Sprite {
        private var _colors:Vector.<ColorElement>;
        private var _RGBToColorElem:Dictionary;
        private var _selectedColor:ColorElement;
        private var _cursor:Shape;
        
        public function Palette() {
            var elemWidth:int = 35;
            var elemHeight:int = 18;
            var h:Array = [0, 210, 240, 270, 300, 340, 0, 20, 40, 90, 120, 150, 180];
            var l:Array = [0.2, 0.4, 0.6, 0.8];
            var gray:Array = [0, 0.5, 0.75, 1];
            
            _colors = new Vector.<ColorElement>(52, true);
            _RGBToColorElem = new Dictionary();
            for (var i:int = 0; i < 52; i++) {
                var color:ColorElement = (i < 4) ? new ColorElement(elemWidth, elemHeight, 0, 0, gray[i])
                                                 : new ColorElement(elemWidth, elemHeight, h[int(i / 4)], 1, l[i % 4]);
                color.x = elemWidth * int(i / 4);
                color.y = elemHeight * (i % 4);
                
                addChild(_colors[i] = color);
                _RGBToColorElem[color.value] = color;
            }
            _selectedColor = _colors[0];
            addChild(_cursor = createCursor(elemWidth, elemHeight));
            
            addEventListener(MouseEvent.CLICK, selectColor);
        }
        
        private function createCursor(width:int, height:int):Shape {
            var cursor:Shape = new Shape();
            cursor.graphics.lineStyle(2, 0xFFE000, 1, true, LineScaleMode.NONE, CapsStyle.NONE, JointStyle.BEVEL);
            cursor.graphics.drawRect(0, 0, width, height);
            cursor.graphics.endFill();
            return cursor;
        }
        
        private function selectColor(event:MouseEvent):void {
            var color:ColorElement = event.target as ColorElement;
            if (color) { selectedColor = color; }
        }
        
        public function toggleUseCount():Boolean {
            var result:Boolean = _colors[0].toggleUseCount();
            for (var i:int = 1; i < _colors.length; i++) {
                _colors[i].toggleUseCount();
            }
            return result;
        }
        
        public function getColorFrom(rgb:uint):ColorElement {
            return _RGBToColorElem[rgb] || _colors[0];
        }
        
        public function get selectedColor():ColorElement { return _selectedColor; }
        public function set selectedColor(value:ColorElement):void {
            _selectedColor = value;
            _cursor.x = value.x;
            _cursor.y = value.y;
        }
    }
//}
/* ------------------------------------------------------------------------------------------------
 * ColorElement
 * ------------------------------------------------------------------------------------------------
 */
//package {
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.text.TextField;
    import frocessing.color.ColorHSL;
    
    //public 
    class ColorElement extends Sprite {
        private var _hsl:ColorHSL;
        private var _useCount:int;
        private var _useCountDisplay:TextField;
        private var _pixelHead:Pixel;
        
        public function ColorElement(width:int, height:int, h:Number, s:Number, l:Number) {
            _hsl = new ColorHSL(h, s, l);
            _useCount = 0;
            addChild(_useCountDisplay =
                (new TextBuilder()).align(TextBuilder.ALIGN_RIGHT).autoSize()
                .font("IPAGP", true, true).fontColor(0xFFFFFF).fontSize(10)
                .size(width, height).textBorder(true, 0x000000).build(String(_useCount))
            );
            _pixelHead = null;
            
            graphics.beginFill(0x404040);
            graphics.drawRect(0, 0, width, height);
            graphics.endFill();
            graphics.beginFill(_hsl.value);
            graphics.drawRect(0.5, 0.5, width - 1, height - 1);
            graphics.endFill();
            
            buttonMode = true;
            
            addEventListener(MouseEvent.ROLL_OVER, showPixelHighlight);
            addEventListener(MouseEvent.ROLL_OUT, hidePixelHighlight);
        }
        
        private function showPixelHighlight(event:MouseEvent):void {
            if (_useCountDisplay.visible && _pixelHead) { _pixelHead.showHighlight(); }
        }
        
        private function hidePixelHighlight(event:MouseEvent):void {
            if (_pixelHead) { _pixelHead.hideHighlight(); }
        }
        
        public function toggleUseCount():Boolean {
            _useCountDisplay.visible = !_useCountDisplay.visible;
            return _useCountDisplay.visible;
        }
        
        public function addToPixelList(pixel:Pixel):void {
            if (_pixelHead) {
                pixel.next = _pixelHead;
                _pixelHead.prev = pixel;
            }else {
                pixel.next = null;
            }
            _pixelHead = pixel;
            pixel.prev = null;
        }
        
        public function removeFromPixelList(pixel:Pixel):void {
            if (pixel == _pixelHead) { _pixelHead = pixel.next; }
            if (pixel.prev) { pixel.prev.next = pixel.next; }
            if (pixel.next) { pixel.next.prev = pixel.prev; }
            pixel.prev = pixel.next = null;
        }
        
        public function get value():uint { return _hsl.value; }
        public function get useCount():int { return _useCount; }
        public function set useCount(value:int):void {
            _useCount = value;
            _useCountDisplay.text = String(value);
        }
    }
//}
/* ------------------------------------------------------------------------------------------------
 * Dotter
 * ------------------------------------------------------------------------------------------------
 */
//package {
    import flash.display.BitmapData;
    import flash.events.EventDispatcher;
    import flash.events.MouseEvent;
    
    //public 
    class Dotter extends EventDispatcher {
        private var _canvas:Canvas;
        private var _palette:Palette;
        private var _canvasHistory:CanvasHistory;
        private var _selectedTool:Function;
        
        public function Dotter(canvas:Canvas, palette:Palette) {
            _canvas = canvas;
            _palette = palette;
            _canvasHistory = new CanvasHistory(canvas);
            _selectedTool = function(event:MouseEvent):void { };
        }
        
        public static const TOOL_PEN:String = "tool_pen";
        public static const TOOL_PICKER:String = "tool_picker";
        public static const TOOL_FILL:String = "tool_fill";
        public static const TOOL_REPLACE:String = "tool_replace";
        
        public function setTool(type:String):void {
            determineLine();
            _canvas.removeEventListener(MouseEvent.MOUSE_DOWN, _selectedTool);
            switch(type) {
                case TOOL_PEN: { _selectedTool = usePen; break; }
                case TOOL_PICKER: { _selectedTool = usePicker; break; }
                case TOOL_FILL: { _selectedTool = useFill; break; }
                case TOOL_REPLACE: { _selectedTool = useReplace; break; }
            }
            _canvas.addEventListener(MouseEvent.MOUSE_DOWN, _selectedTool);
        }
        
        private function usePen(event:MouseEvent):void {
            _canvasHistory.store();
            setPixel(event);
            _canvas.addEventListener(MouseEvent.MOUSE_OVER, setPixel);
            _canvas.stage.addEventListener(MouseEvent.MOUSE_UP, determineLine);
        }
        
        private function setPixel(event:MouseEvent):void {
            var pixel:Pixel = event.target as Pixel;
            if (pixel) { pixel.color = _palette.selectedColor; }
        }
        
        private function determineLine(event:MouseEvent = null):void {
            _canvas.removeEventListener(MouseEvent.MOUSE_OVER, setPixel);
            _canvas.stage.removeEventListener(MouseEvent.MOUSE_UP, determineLine);
        }
        
        private function usePicker(event:MouseEvent):void {
            var pixel:Pixel = event.target as Pixel;
            if (pixel) { _palette.selectedColor = pixel.color; }
        }
        
        private function useFill(event:MouseEvent):void {
            var pixel:Pixel = event.target as Pixel;
            if (!pixel) { return; }
            
            var sourceColor:ColorElement = _palette.selectedColor;
            var targetColor:ColorElement = pixel.color;
            if (sourceColor == targetColor) { return; }
            
            _canvasHistory.store();
            _canvas.lock();
            fillPixel(pixel, sourceColor, targetColor);
            _canvas.unlock();
        }
        
        private function fillPixel(pixel:Pixel, source:ColorElement, target:ColorElement):void {
            if (pixel.color != target) { return; }
            pixel.color = source;
            fillPixel(_canvas.getPixelAt(pixel.col - 1, pixel.row), source, target);
            fillPixel(_canvas.getPixelAt(pixel.col + 1, pixel.row), source, target);
            fillPixel(_canvas.getPixelAt(pixel.col, pixel.row - 1), source, target);
            fillPixel(_canvas.getPixelAt(pixel.col, pixel.row + 1), source, target);
        }
        
        private function useReplace(event:MouseEvent):void {
            var pixel:Pixel = event.target as Pixel;
            if (!pixel) { return; }
            
            var sourceColor:ColorElement = _palette.selectedColor;
            var targetColor:ColorElement = pixel.color;
            if (sourceColor == targetColor) { return; }
            
            _canvasHistory.store();
            _canvas.lock();
            for (var row:int = 0; row < _canvas.size; row++) {
                for (var col:int = 0; col < _canvas.size; col++) {
                    var target:Pixel = _canvas.getPixelAt(col, row);
                    if (target.color == targetColor) { target.color = sourceColor; }
                }
            }
            _canvas.unlock();
        }
        
        public static const DIRECTION_UP:String = "direction_up";
        public static const DIRECTION_LEFT:String = "direction_left";
        public static const DIRECTION_RIGHT:String = "direction_right";
        public static const DIRECTION_DOWN:String = "direction_down";
        
        public function scrollCanvas(direction:String):void {
            _canvasHistory.store();
            _canvas.lock();
            switch(direction) {
                case DIRECTION_UP: { scrollUpCanvas(); break; }
                case DIRECTION_LEFT: { scrollLeftCanvas(); break; }
                case DIRECTION_RIGHT: { scrollRightCanvas(); break; }
                case DIRECTION_DOWN: { scrollDownCanvas(); break; }
            }
            _canvas.unlock();
        }
        
        private function scrollUpCanvas():void {
            var canvasSize:int = _canvas.size;
            for (var col:int = 0; col < canvasSize; col++) {
                var temp:ColorElement = _canvas.getPixelAt(col, 0).color;
                for (var row:int = 1; row < canvasSize; row++) {
                    _canvas.getPixelAt(col, row - 1).color = _canvas.getPixelAt(col, row).color;
                }
                _canvas.getPixelAt(col, canvasSize - 1).color = temp;
            }
        }
        
        private function scrollLeftCanvas():void {
            var canvasSize:int = _canvas.size;
            for (var row:int = 0; row < canvasSize; row++) {
                var temp:ColorElement = _canvas.getPixelAt(0, row).color;
                for (var col:int = 1; col < canvasSize; col++) {
                    _canvas.getPixelAt(col - 1, row).color = _canvas.getPixelAt(col, row).color;
                }
                _canvas.getPixelAt(canvasSize - 1, row).color = temp;
            }
        }
        
        private function scrollRightCanvas():void {
            var canvasSize:int = _canvas.size;
            for (var row:int = 0; row < canvasSize; row++) {
                var temp:ColorElement = _canvas.getPixelAt(canvasSize - 1, row).color;
                for (var col:int = canvasSize - 2; col >= 0; col--) {
                    _canvas.getPixelAt(col + 1, row).color = _canvas.getPixelAt(col, row).color;
                }
                _canvas.getPixelAt(0, row).color = temp;
            }
        }
        
        private function scrollDownCanvas():void {
            var canvasSize:int = _canvas.size;
            for (var col:int = 0; col < canvasSize; col++) {
                var temp:ColorElement = _canvas.getPixelAt(col, canvasSize - 1).color;
                for (var row:int = canvasSize - 2; row >= 0; row--) {
                    _canvas.getPixelAt(col, row + 1).color = _canvas.getPixelAt(col, row).color;
                }
                _canvas.getPixelAt(col, 0).color = temp;
            }
        }
        
        public function drawImage(image:BitmapData):void {
            _canvasHistory.store();
            _canvas.lock();
            for (var row:int = 0; row < _canvas.size; row++) {
                for (var col:int = 0; col < _canvas.size; col++) {
                    _canvas.getPixelAt(col, row).color = _palette.getColorFrom(image.getPixel(col, row));
                }
            }
            _canvas.unlock();
        }
        
        public function get canvas():Canvas { return _canvas; }
        public function get canvasHistory():CanvasHistory { return _canvasHistory; }
    }
//}
/* ------------------------------------------------------------------------------------------------
 * CanvasHistory
 * ------------------------------------------------------------------------------------------------
 */
//package {
    import flash.events.Event;
    import flash.events.EventDispatcher;
    
    //public 
    class CanvasHistory extends EventDispatcher {
        private static const NUM_HISTORY:int = 20;
        
        private var _canvas:Canvas;
        private var _undoList:Vector.<Vector.<Vector.<ColorElement>>>;
        private var _redoList:Vector.<Vector.<Vector.<ColorElement>>>;
        
        public function CanvasHistory(canvas:Canvas) {
            _canvas = canvas;
            _undoList = new Vector.<Vector.<Vector.<ColorElement>>>();
            _redoList = new Vector.<Vector.<Vector.<ColorElement>>>();
        }
        
        private function getCanvasData():Vector.<Vector.<ColorElement>> {
            var canvasSize:int = _canvas.size;
            var data:Vector.<Vector.<ColorElement>> = new Vector.<Vector.<ColorElement>>(canvasSize, true);
            for (var row:int = 0; row < canvasSize; row++) {
                data[row] = new Vector.<ColorElement>(canvasSize, true);
                for (var col:int = 0; col < canvasSize; col++) {
                    data[row][col] = _canvas.getPixelAt(col, row).color;
                }
            }
            return data;
        }
        
        private function setCanvasData(data:Vector.<Vector.<ColorElement>>):void {
            var canvasSize:int = _canvas.size;
            _canvas.lock();
            for (var row:int = 0; row < canvasSize; row++) {
                for (var col:int = 0; col < canvasSize; col++) {
                    var pixel:Pixel = _canvas.getPixelAt(col, row);
                    if (pixel.color != data[row][col]) {
                        pixel.color = data[row][col];
                    }
                }
            }
            _canvas.unlock();
        }
        
        public function store():void {
            _undoList.push(getCanvasData());
            if (_undoList.length > NUM_HISTORY) { _undoList.shift(); }
            _redoList = new Vector.<Vector.<Vector.<ColorElement>>>();
            dispatchEvent(new Event(Event.CHANGE));
        }
        
        public function undo():void {
            if (_undoList.length == 0) { return; }
            _redoList.push(getCanvasData());
            setCanvasData(_undoList.pop());
            dispatchEvent(new Event(Event.CHANGE));
        }
        
        public function redo():void {
            if (_redoList.length == 0) { return; }
            _undoList.push(getCanvasData());
            setCanvasData(_redoList.pop());
            dispatchEvent(new Event(Event.CHANGE));
        }
        
        public function get undoable():Boolean { return _undoList.length > 0; }
        public function get redoable():Boolean { return _redoList.length > 0; }
    }
//}
/* ------------------------------------------------------------------------------------------------
 * FileWindow
 * ------------------------------------------------------------------------------------------------
 */
//package {
    import com.adobe.images.PNGEncoder;
    import com.bit101.components.Label;
    import com.bit101.components.Window;
    import flash.display.BitmapData;
    import flash.display.DisplayObject;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.net.FileReference;
    import flash.system.System;
    import mx.utils.Base64Encoder;
    
    //public 
    class FileWindow extends Window {
        private var _dotter:Dotter;
        private var _loader:LocalImageLoader;
        
        public function FileWindow(dotter:Dotter) {
            super(null, 0, 0, "File");
            width = 75;
            height = 80;
            draggable = false;
            
            _dotter = dotter;
            _loader = new LocalImageLoader();
            
            createButton(0, 0, 75, 20, "Load Image").addEventListener(MouseEvent.CLICK, loadImage);
            createButton(0, 20, 75, 20, "Save As PNG").addEventListener(MouseEvent.CLICK, saveCanvas);
            createButton(0, 40, 75, 20, "CopyToClipboard").addEventListener(MouseEvent.CLICK, copyCanvasDataToClipboard);
        }
        
        private function createButton(x:int, y:int, width:int, height:int, label:String = ""):Button {
            var button:Button = new Button(width, height);
            button.x = x;
            button.y = y;
            if (label != "") { button.setFace(new Label(null, 0, 0, label)); }
            content.addChild(button);
            return button;
        }
        
        private function loadImage(event:MouseEvent):void {
            _loader.addEventListener(Event.COMPLETE, setImageToCanvas);
            _loader.addEventListener(Event.CANCEL, cancelImageSelection);
            _loader.load();
        }
        
        private function setImageToCanvas(event:Event):void {
            _loader.removeEventListener(Event.COMPLETE, setImageToCanvas);
            _loader.removeEventListener(Event.CANCEL, cancelImageSelection);
            
            var image:DisplayObject = _loader.content;
            var canvasSize:int = _dotter.canvas.size;
            image.scaleX = image.scaleY = Math.min(1, canvasSize / image.width, canvasSize / image.height);
            var bmd:BitmapData = new BitmapData(canvasSize, canvasSize, false, 0x000000);
            bmd.draw(image, image.transform.matrix, null, null, null, true);
            
            _dotter.drawImage(NESImage.quantize(bmd, false));
        }
        
        private function cancelImageSelection(event:Event):void {
            _loader.removeEventListener(Event.COMPLETE, setImageToCanvas);
            _loader.removeEventListener(Event.CANCEL, cancelImageSelection);
        }
        
        private function saveCanvas(event:MouseEvent):void {
            (new FileReference()).save(PNGEncoder.encode(_dotter.canvas.bitmapData), "icon.png");
        }
        
        private function copyCanvasDataToClipboard(event:MouseEvent):void {
            var base64Encoder:Base64Encoder = new Base64Encoder();
            base64Encoder.encodeBytes(PNGEncoder.encode(_dotter.canvas.bitmapData));
            System.setClipboard(base64Encoder.toString());
        }
    }
//}
/* ------------------------------------------------------------------------------------------------
 * EditWindow
 * ------------------------------------------------------------------------------------------------
 */
//package {
    import com.bit101.components.Label;
    import com.bit101.components.Window;
    import flash.display.Bitmap;
    import flash.display.Shape;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    import flash.text.TextField;
    import flash.ui.Keyboard;
    
    //public 
    class EditWindow extends Window {
        private var _dotter:Dotter;
        
        private var _penButton:Button;
        private var _pickerButton:Button;
        private var _fillButton:Button;
        private var _replaceButton:Button;
        
        private var _undoButton:Button;
        private var _redoButton:Button;
        
        public function EditWindow(dotter:Dotter) {
            super(null, 0, 0, "Edit");
            width = 75;
            height = 185;
            draggable = false;
            
            _dotter = dotter;
            _dotter.canvasHistory.addEventListener(Event.CHANGE, updateButton);
            
            _penButton = createButton(4, 4, 32, 32, "A");
            _penButton.setFace(new Bitmap(Assets.getImage("pen")));
            _penButton.addEventListener(MouseEvent.CLICK, setPen);
            Hotkey.bind(Hotkey.A, setPen);
            _pickerButton = createButton(39, 4, 32, 32, "S");
            _pickerButton.setFace(new Bitmap(Assets.getImage("picker")));
            _pickerButton.addEventListener(MouseEvent.CLICK, setPicker);
            Hotkey.bind(Hotkey.S, setPicker);
            _fillButton = createButton(4, 39, 32, 32, "D");
            _fillButton.setFace(new Bitmap(Assets.getImage("fill")));
            _fillButton.addEventListener(MouseEvent.CLICK, setFill);
            Hotkey.bind(Hotkey.D, setFill);
            _replaceButton = createButton(39, 39, 32, 32, "F");
            _replaceButton.setFace(new Bitmap(Assets.getImage("replace")));
            _replaceButton.addEventListener(MouseEvent.CLICK, setReplace);
            Hotkey.bind(Hotkey.F, setReplace);
            
            var upButton:Button = createButton(26, 74, 24, 24, "↑");
            upButton.setFace(createTriangleImage(new Point(6, 0), new Point(0, 12), new Point(12, 12)));
            upButton.addEventListener(MouseEvent.CLICK, scrollUp);
            Hotkey.bind(Keyboard.UP, scrollUp);
            var leftButton:Button = createButton(2, 98, 24, 24, "←");
            leftButton.setFace(createTriangleImage(new Point(0, 6), new Point(12, 12), new Point(12, 0)));
            leftButton.addEventListener(MouseEvent.CLICK, scrollLeft);
            Hotkey.bind(Keyboard.LEFT, scrollLeft);
            var rightButton:Button = createButton(50, 98, 24, 24, "→");
            rightButton.setFace(createTriangleImage(new Point(0, 0), new Point(0, 12), new Point(12, 6)));
            rightButton.addEventListener(MouseEvent.CLICK, scrollRight);
            Hotkey.bind(Keyboard.RIGHT, scrollRight);
            var downButton:Button = createButton(26, 98, 24, 24, "↓");
            downButton.setFace(createTriangleImage(new Point(0, 0), new Point(6, 12), new Point(12, 0)));
            downButton.addEventListener(MouseEvent.CLICK, scrollDown);
            Hotkey.bind(Keyboard.DOWN, scrollDown);
            
            _undoButton = createButton(0, 125, 75, 20, "Z", "Undo");
            _undoButton.enabled = false;
            _undoButton.addEventListener(MouseEvent.CLICK, undo);
            Hotkey.bind(Hotkey.Z, undo);
            _redoButton = createButton(0, 145, 75, 20, "X", "Redo");
            _redoButton.enabled = false;
            _redoButton.addEventListener(MouseEvent.CLICK, redo);
            Hotkey.bind(Hotkey.X, redo);
            
            setPen();
        }
        
        private function updateButton(event:Event):void {
            _undoButton.enabled = _dotter.canvasHistory.undoable;
            _redoButton.enabled = _dotter.canvasHistory.redoable;
        }
        
        private function createButton(x:int, y:int, width:int, height:int, hotkey:String = "", label:String = ""):Button {
            var button:Button = new Button(width, height);
            button.x = x;
            button.y = y;
            if (hotkey != "") {
                var hotkeyText:TextField = (new TextBuilder()).autoSize(true, false)
                    .font("IPAGP", true, true).fontColor(0xFFFFFF).fontSize(10)
                    .textBorder(true, 0x000000).build(hotkey);
                hotkeyText.x = width - hotkeyText.width;
                hotkeyText.y = height - hotkeyText.height;
                button.addChild(hotkeyText);
            }
            if (label != "") { button.setFace(new Label(null, 0, 0, label)); }
            content.addChild(button);
            return button;
        }
        
        private function createTriangleImage(p1:Point, p2:Point, p3:Point):Shape {
            var image:Shape = new Shape();
            image.graphics.beginFill(0x808080);
            image.graphics.moveTo(p1.x, p1.y);
            image.graphics.lineTo(p2.x, p2.y);
            image.graphics.lineTo(p3.x, p3.y);
            image.graphics.lineTo(p1.x, p1.y);
            image.graphics.endFill();
            return image;
        }
        
        private function setPen(event:MouseEvent = null):void {
            _dotter.setTool(Dotter.TOOL_PEN);
            _penButton.selected = true;
            _pickerButton.selected = _fillButton.selected = _replaceButton.selected = false;
        }
        private function setPicker(event:MouseEvent = null):void {
            _dotter.setTool(Dotter.TOOL_PICKER);
            _pickerButton.selected = true;
            _penButton.selected = _fillButton.selected = _replaceButton.selected = false;
        }
        private function setFill(event:MouseEvent = null):void {
            _dotter.setTool(Dotter.TOOL_FILL);
            _fillButton.selected = true;
            _penButton.selected = _pickerButton.selected = _replaceButton.selected = false;
        }
        private function setReplace(event:MouseEvent = null):void {
            _dotter.setTool(Dotter.TOOL_REPLACE);
            _replaceButton.selected = true;
            _penButton.selected = _pickerButton.selected = _fillButton.selected = false;
        }
        
        private function scrollUp(event:MouseEvent = null):void { _dotter.scrollCanvas(Dotter.DIRECTION_UP); }
        private function scrollLeft(event:MouseEvent = null):void { _dotter.scrollCanvas(Dotter.DIRECTION_LEFT); }
        private function scrollRight(event:MouseEvent = null):void { _dotter.scrollCanvas(Dotter.DIRECTION_RIGHT); }
        private function scrollDown(event:MouseEvent = null):void { _dotter.scrollCanvas(Dotter.DIRECTION_DOWN); }
        
        private function undo(event:MouseEvent = null):void { _dotter.canvasHistory.undo(); }
        private function redo(event:MouseEvent = null):void { _dotter.canvasHistory.redo(); }
    }
//}
/* ------------------------------------------------------------------------------------------------
 * ViewWindow
 * ------------------------------------------------------------------------------------------------
 */
//package {
    import com.bit101.components.Window;
    import flash.display.CapsStyle;
    import flash.display.JointStyle;
    import flash.display.LineScaleMode;
    import flash.display.Shape;
    import flash.events.MouseEvent;
    import flash.text.TextField;
    
    //public 
    class ViewWindow extends Window {
        
        public function ViewWindow(toggleGridLinesFunc:Function, toggleUseCountFunc:Function) {
            super(null, 0, 0, "View");
            width = 75;
            height = 60;
            draggable = false;
            
            var toggleGridLinesButton:Button = new Button(32, 32);
            toggleGridLinesButton.x = 4;
            toggleGridLinesButton.y = 4;
            toggleGridLinesButton.setFace(createGridLinesImage(18));
            content.addChild(toggleGridLinesButton);
            toggleGridLinesButton.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void {
                toggleGridLinesButton.selected = toggleGridLinesFunc();
            });
            toggleGridLinesButton.selected = (toggleGridLinesFunc(), toggleGridLinesFunc());
            
            var toggleUseCountButton:Button = new Button(32, 32);
            toggleUseCountButton.x = 39;
            toggleUseCountButton.y = 4;
            toggleUseCountButton.setFace(createUseCountImage(9));
            content.addChild(toggleUseCountButton);
            toggleUseCountButton.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void {
                toggleUseCountButton.selected = toggleUseCountFunc();
            });
            toggleUseCountButton.selected = (toggleUseCountFunc(), toggleUseCountFunc());
        }
        
        private function createGridLinesImage(size:int):Shape {
            var image:Shape = new Shape();
            image.graphics.lineStyle(0, 0x808080, 1, true, LineScaleMode.NONE, CapsStyle.NONE, JointStyle.BEVEL);
            for (var i:Number = 0; i <= size; i += size / 3) {
                image.graphics.moveTo(i, 0);
                image.graphics.lineTo(i, size);
                image.graphics.moveTo(0, i);
                image.graphics.lineTo(size, i);
            }
            return image;
        }
        
        private function createUseCountImage(fontSize:int):TextField {
            return (new TextBuilder()).autoSize(true, false)
            .font("IPAGP", true, true).fontColor(0xFFFFFF).fontSize(fontSize)
            .textBorder(true, 0x000000).build("1234");
        }
    }
//}
/* ------------------------------------------------------------------------------------------------
 * NESImage
 * ------------------------------------------------------------------------------------------------
 */
//package {
    import flash.display.BitmapData;
    import flash.display.Loader;
    import frocessing.color.ColorHSL;
    
    //public 
    class NESImage {
        
        public static function quantize(source:BitmapData, usesErrorDiffusion:Boolean):BitmapData {
            var width:int = source.width;
            var height:int = source.height;
            var bmd:BitmapData = new BitmapData(width, height, false, 0x000000);
            bmd.lock();
            
            var x:int, y:int;
            var original:ColorHSL = new ColorHSL();
            var quantized:ColorHSL = new ColorHSL();
            if (usesErrorDiffusion) {
                var error:ColorError;
                var errorTable:Vector.<Vector.<ColorError>> = new Vector.<Vector.<ColorError>>(height + 1, true);
                for (y = height; y >= 0; y--) {
                    errorTable[y] = new Vector.<ColorError>(width + 2, true);
                    for (x = width + 1; x >= 0; x--) {
                        errorTable[y][x] = new ColorError();
                    }
                }
            }
            // 誤差拡散を行うかどうかで、各閾値を少し変える
            var thresholds:Vector.<Number> = new Vector.<Number>(6, true);
            thresholds[0] = (usesErrorDiffusion) ? 0.1 : 0.125;
            thresholds[1] = (usesErrorDiffusion) ? 0.9 : 0.875;
            thresholds[2] = (usesErrorDiffusion) ? 0.2 : 0.225;
            thresholds[3] = (usesErrorDiffusion) ? 0.625 : 0.6;
            thresholds[4] = (usesErrorDiffusion) ? 0.875 : 0.85;
            thresholds[5] = (usesErrorDiffusion) ? 0.25 : 0.3;
            
            for (y = 0; y < height; y++) {
                for (x = 0; x < width; x++) {
                    original.value = source.getPixel(x, y);
                    
                    // 誤差の補正を加える
                    if (usesErrorDiffusion) {
                        error = errorTable[y][x + 1];
                        original.hsl(original.h + error.h, original.s, original.l + error.l);
                    }
                    
                    var originalH:Number = original.h;
                    var originalS:Number = original.s;
                    var originalL:Number = original.l;
                    var quantizedH:Number;
                    var quantizedS:Number;
                    var quantizedL:Number;
                    
                    if (originalL < thresholds[0]) {
                        // 黒
                        quantizedH = quantizedS = quantizedL = 0;
                    }else if (originalL > thresholds[1]) {
                        // 白
                        quantizedH = quantizedS = 0;
                        quantizedL = 1;
                    }else if (originalS < thresholds[2]) {
                        // モノクロ
                        quantizedH = quantizedS = 0;
                        if (originalL > thresholds[3]) {
                            if (originalL > thresholds[4]) {
                                quantizedL = 1;
                            }else {
                                quantizedL = 0.75;
                            }
                        }else {
                            if (originalL > thresholds[5]) {
                                quantizedL = 0.5;
                            }else {
                                quantizedL = 0;
                            }
                        }
                    }else {
                        // カラー
                        quantizedS = 1;
                        if (originalH < 135) {
                            if (originalH < 65) {
                                if (originalH < 10) {
                                    quantizedH = 0;
                                }else if (originalH < 30) {
                                    quantizedH = 20;
                                }else {
                                    quantizedH = 40;
                                }
                            }else {
                                if (originalH < 105) {
                                    quantizedH = 90;
                                }else {
                                    quantizedH = 120;
                                }
                            }
                        }else if (originalH < 255) {
                            if (originalH < 195) {
                                if (originalH < 165) {
                                    quantizedH = 150;
                                }else {
                                    quantizedH = 180;
                                }
                            }else {
                                if (originalH < 225) {
                                    quantizedH = 210;
                                }else {
                                    quantizedH = 240;
                                }
                            }
                        }else {
                            if (originalH < 320) {
                                if (originalH < 285) {
                                    quantizedH = 270;
                                }else {
                                    quantizedH = 300;
                                }
                            }else {
                                if (originalH < 350) {
                                    quantizedH = 340;
                                }else {
                                    quantizedH = 0;
                                }
                            }
                        }
                        
                        if (originalL > 0.5) {
                            if (originalL > 0.7) {
                                quantizedL = 0.8;
                            }else {
                                quantizedL = 0.6;
                            }
                        }else {
                            if (originalL > 0.3) {
                                quantizedL = 0.4;
                            }else {
                                quantizedL = 0.2;
                            }
                        }
                    }
                    quantized.hsl(quantizedH, quantizedS, quantizedL);
                    bmd.setPixel(x, y, quantized.value);
                    
                    // 元の色と変換後の色の誤差を拡散させる
                    if (usesErrorDiffusion) {
                        var diffH1:Number = (quantizedS == 1) ? originalH - quantizedH : 0;
                        var diffH2:Number = (diffH1 < 0) ? 360 + diffH1 : 360 - diffH1;
                        var errorH:Number = ((Math.abs(diffH1) < Math.abs(diffH2)) ? diffH1 : diffH2) * 0.0625;
                        var errorL:Number = (originalL - quantizedL) * 0.0625;
                        errorTable[y][x + 2].add(errorH * 7, errorL * 7);
                        errorTable[y + 1][x].add(errorH * 3, errorL * 3);
                        errorTable[y + 1][x + 1].add(errorH * 5, errorL * 5);
                        errorTable[y + 1][x + 2].add(errorH, errorL);
                    }
                }
            }
            
            bmd.unlock();
            return bmd;
        }
    }
//}
//package {
    //public 
    class ColorError {
        public var h:Number;
        public var l:Number;
        
        public function ColorError() {
            this.h = this.l = 0;
        }
        
        public function add(h:Number, l:Number):void {
            this.h += h;
            this.l += l;
        }
    }
//}
/* ------------------------------------------------------------------------------------------------
 * Preloader
 * ------------------------------------------------------------------------------------------------
 */
//package {
    import com.bit101.components.Label;
    import com.bit101.components.ProgressBar;
    import com.bit101.components.Style;
    import flash.display.DisplayObjectContainer;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.utils.Dictionary;
    import net.wonderfl.utils.FontLoader;
    
    //public 
    class Preloader extends EventDispatcher {
        private var _numAssets:int;
        private var _numLoaded:int;
        /* ローディング状況表示関連 */
        private var _label:Label;
        private var _progressBar:ProgressBar;
        /* 画像読み込み関連 */
        private var _loadsImages:Boolean;
        private var _imageURLs:Object;
        private var _imageLoaders:Dictionary;
        private var _addToContainerFunc:Function;
        /* フォント読み込み関連 */
        private var _loadsFonts:Boolean;
        private var _fontNames:Array;
        private var _fontLoaders:Vector.<FontLoader>;
        
        public function Preloader(parent:DisplayObjectContainer):void {
            _numAssets = _numLoaded = 0;
            
            Style.BACKGROUND = 0xFFFFFF;
            Style.LABEL_TEXT = 0xFFFFFF;
            Style.PROGRESS_BAR = 0x00FF00;
            
            _label = new Label(parent, 182, 213, "Now Loading...");
            _progressBar = new ProgressBar(parent, 182, 231);
            _loadsImages = _loadsFonts = false;
        }
        
        /* 画像読み込み要求を行う */
        public function addImageLoadingRequest(URLs:Object, addToContainerFunc:Function):void {
            _loadsImages = true;
            _imageURLs = URLs;
            _imageLoaders = new Dictionary();
            _addToContainerFunc = addToContainerFunc;
            
            for (var name:String in _imageURLs) {
                _numAssets++;
                var loader:ExternalImageLoader = new ExternalImageLoader();
                loader.addEventListener(Event.COMPLETE, assetLoaded);
                _imageLoaders[name] = loader;
            }
        }
        
        /* フォント読み込み要求を行う */
        public function addFontLoadingRequest(names:Array):void {
            _loadsFonts = true;
            _fontNames = names;
            _fontLoaders = new Vector.<FontLoader>();
            
            for (var i:int = 0; i < _fontNames.length; i++) {
                _numAssets++;
                var loader:FontLoader = new FontLoader();
                loader.addEventListener(Event.COMPLETE, assetLoaded);
                _fontLoaders.push(loader);
            }
        }
        
        public function load():void {
            if (_numAssets == 0) { onEveryAssetLoaded(); return; }
            
            _progressBar.maximum = _numAssets;
            
            // 画像読み込みを開始する
            if (_loadsImages) {
                for (var name:String in _imageLoaders) {
                    _imageLoaders[name].load(_imageURLs[name]);
                }
            }
            // フォント読み込みを開始する
            if (_loadsFonts) {
                for (var i:int = 0; i < _fontLoaders.length; i++) {
                    _fontLoaders[i].load(_fontNames[i]);
                }
            }
        }
        
        private function assetLoaded(event:Event):void {
            event.target.removeEventListener(Event.COMPLETE, assetLoaded);
            
            _numLoaded++;
            _progressBar.value = _numLoaded;
            if (_numLoaded == _numAssets) { onEveryAssetLoaded(); }
        }
        
        private function onEveryAssetLoaded():void {
            if (_loadsImages) {
                for (var name:String in _imageLoaders) {
                    _addToContainerFunc(name, _imageLoaders[name].content);
                }
            }
            
            _label.parent.removeChild(_label);
            _progressBar.parent.removeChild(_progressBar);
            
            Style.BACKGROUND = 0xCCCCCC;
            Style.LABEL_TEXT = 0x666666;
            Style.PROGRESS_BAR = 0xFFFFFF;
            
            dispatchEvent(new Event(Event.COMPLETE));
        }
    }
//}
/* ------------------------------------------------------------------------------------------------
 * ExternalImageLoader
 * ------------------------------------------------------------------------------------------------
 */
//package {
    import flash.display.BitmapData;
    import flash.display.Loader;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.net.URLRequest;
    import flash.system.LoaderContext;
    
    //public 
    class ExternalImageLoader extends EventDispatcher {
        private var _content:BitmapData;
        private var _temp1:Loader;
        private var _temp2:Loader;
        
        public function ExternalImageLoader() {
            _content = null; _temp1 = new Loader(); _temp2 = new Loader();
        }
        
        public function load(url:String):void {
            _temp1.contentLoaderInfo.addEventListener(Event.INIT, temp1Loaded);
            _temp1.load(new URLRequest(url), new LoaderContext(true));
        }
        
        private function temp1Loaded(event:Event):void {
            event.target.removeEventListener(Event.INIT, temp1Loaded);
            _content = new BitmapData(int(_temp1.width), int(_temp1.height), true, 0x00ffffff);
            _temp2.contentLoaderInfo.addEventListener(Event.INIT, temp2Loaded);
            _temp2.loadBytes(_temp1.contentLoaderInfo.bytes);
        }
        
        private function temp2Loaded(event:Event):void {
            event.target.removeEventListener(Event.INIT, temp2Loaded);
            _content.draw(_temp2); _temp1.unload(); _temp2.unload();
            dispatchEvent(new Event(Event.COMPLETE));
        }
        
        public function get content():BitmapData { return _content; }
    }
//}
/* ------------------------------------------------------------------------------------------------
 * Assets
 * ------------------------------------------------------------------------------------------------
 */
//package {
    import flash.display.BitmapData;
    import flash.utils.Dictionary;
    
    //public 
    class Assets {
        private static var _images:Dictionary = new Dictionary();
        
        public static function getImage(name:String):BitmapData {
            return _images[name];
        }
        
        public static function addImage(name:String, image:BitmapData):void {
            _images[name] = image;
        }
    }
//}
/* ------------------------------------------------------------------------------------------------
 * LocalImageLoader
 * ------------------------------------------------------------------------------------------------
 */
//package {
    import flash.display.DisplayObject;
    import flash.display.Loader;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.net.FileFilter;
    import flash.net.FileReference;
    
    //public 
    class LocalImageLoader extends EventDispatcher {
        private var _loader:Loader;
        private var _file:FileReference;
        private var _fileFilter:Array;
        
        public function LocalImageLoader() {
            _loader = new Loader();
            _file = new FileReference();
            _fileFilter = [new FileFilter("Image (*.png;*.jpg;*.gif)", "*.png;*.jpg;*.gif")];
        }
        
        public function load():void {
            _file.addEventListener(Event.SELECT, onFileSelected);
            _file.addEventListener(Event.CANCEL, cancelFileSelection);
            _file.browse(_fileFilter);
        }
        
        private function onFileSelected(event:Event):void {
            _file.addEventListener(Event.COMPLETE, onFileLoaded);
            _file.load();
        }
        
        private function onFileLoaded(event:Event):void {
            removeFileListeners();
            _loader.unload();
            _loader.contentLoaderInfo.addEventListener(Event.INIT, onLoadCompleted);
            _loader.loadBytes(_file.data);
        }
        
        private function onLoadCompleted(event:Event):void {
            _loader.contentLoaderInfo.removeEventListener(Event.INIT, onLoadCompleted);
            dispatchEvent(new Event(Event.COMPLETE));
        }
        
        private function cancelFileSelection(event:Event):void {
            removeFileListeners();
            dispatchEvent(new Event(Event.CANCEL));
        }
        
        private function removeFileListeners():void {
            _file.removeEventListener(Event.SELECT, onFileSelected);
            _file.removeEventListener(Event.CANCEL, cancelFileSelection);
            _file.removeEventListener(Event.COMPLETE, onFileLoaded);
        }
        
        public function get content():DisplayObject { return _loader.content; }
    }
//}
/* ------------------------------------------------------------------------------------------------
 * Hotkey
 * ------------------------------------------------------------------------------------------------
 */
//package {
    import flash.display.Stage;
    import flash.events.KeyboardEvent;
    
    //public 
    class Hotkey {
        private static var _stage:Stage;
        private static var _keymap:Vector.<Function>;
        
        public static function initialize(stage:Stage):void {
            Hotkey._stage = stage;
            Hotkey._keymap = new Vector.<Function>(256, true);
            enable();
        }
        
        public static function enable():void { Hotkey._stage.addEventListener(KeyboardEvent.KEY_DOWN, Hotkey.keyDownHandler); }
        public static function disable():void { Hotkey._stage.removeEventListener(KeyboardEvent.KEY_DOWN, Hotkey.keyDownHandler); }
        
        private static function keyDownHandler(event:KeyboardEvent):void {
            var command:Function = Hotkey._keymap[event.keyCode];
            if (command != null) { command(); }
        }
        
        public static function bind(keyCode:uint, command:Function):void {
            Hotkey._keymap[keyCode] = command;
        }
        
        public static const A:uint = 65;
        public static const S:uint = 83;
        public static const D:uint = 68;
        public static const F:uint = 70;
        
        public static const Z:uint = 90;
        public static const X:uint = 88;
    }
//}
/* ------------------------------------------------------------------------------------------------
 * Button
 * ------------------------------------------------------------------------------------------------
 */
//package {
    import flash.display.DisplayObject;
    import flash.display.GradientType;
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.filters.DropShadowFilter;
    import flash.geom.ColorTransform;
    import flash.geom.Matrix;
    import flash.geom.Point;
    
    //public 
    class Button extends Sprite {
        private var _size:Point;
        private var _border:Shape;
        private var _background:Shape;
        private var _faceContainer:Sprite;
        private var _face:DisplayObject;
        private var _facePosition:Point;
        private var _hovered:Boolean;
        private var _pressed:Boolean;
        
        private var _selected:Boolean;
        private var _enabled:Boolean;
        
        public function Button(width:int, height:int) {
            _size = new Point(width, height);
            addChild(_border = new Shape());
            addChild(_background = new Shape());
            addChild(_faceContainer = new Sprite());
            _faceContainer.addChild(_face = new Shape());
            _facePosition = new Point(0, 0);
            _hovered = _pressed = false;
            
            var matrix:Matrix = new Matrix();
            matrix.createGradientBox(_size.x - 2, _size.y - 2, Math.PI / 2, 1, 1);
            _background.graphics.beginGradientFill(GradientType.LINEAR, [0xFFFFFF, 0xE0E0E0], [1, 1], [0, 255], matrix);
            _background.graphics.drawRect(1, 1, _size.x - 2, _size.y - 2);
            _background.graphics.endFill();
            
            selected = false;
            enabled = true;
            
            mouseChildren = false;
            addEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
            addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
        }
        
        private function rollOverHandler(event:MouseEvent):void {
            _hovered = true;
            draw();
            addEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
        }
        
        private function rollOutHandler(event:MouseEvent):void {
            removeEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
            _hovered = false;
            draw();
        }
        
        private function mouseDownHandler(event:MouseEvent):void {
            _pressed = true;
            draw();
            stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
        }
        
        private function mouseUpHandler(event:MouseEvent):void {
            stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
            _pressed = false;
            draw();
        }
        
        private static const DOWN:Array = [new DropShadowFilter(1, 45, 0x404040, 0.5, 1, 1, 1, 1, true)];
        private static const UP:Array = [];
        private static const HOVER:ColorTransform = new ColorTransform(0.5, 0.5, 0.5, 1, 128, 128, 128);
        private static const NORMAL:ColorTransform = new ColorTransform(1, 1, 1);
        private static const DISABLED:ColorTransform = new ColorTransform(0.7, 0.7, 0.7);
        
        private function draw():void {
            _border.graphics.clear();
            _border.graphics.beginFill((_selected) ? 0xFFFF00 : 0xC0C0C0);
            _border.graphics.drawRect(0, 0, _size.x, _size.y);
            _border.graphics.endFill();
            
            _background.filters = (_pressed) ? DOWN : UP;
            
            _face.x = _facePosition.x + int(_pressed);
            _face.y = _facePosition.y + int(_pressed);
            
            transform.colorTransform = (_enabled) ? ((_hovered) ? HOVER : NORMAL) : DISABLED;
        }
        
        public function setFace(face:DisplayObject):void {
            _faceContainer.removeChild(_face);
            _face = face;
            _face.x = _facePosition.x = (_size.x - _face.width) / 2;
            _face.y = _facePosition.y = (_size.y - _face.height) / 2;
            _faceContainer.addChild(_face);
        }
        
        public function get selected():Boolean { return _selected; }
        public function get enabled():Boolean { return _enabled; }
        
        public function set selected(value:Boolean):void {
            _selected = value;
            draw();
        }
        public function set enabled(value:Boolean):void {
            _enabled = buttonMode = mouseEnabled = value;
            draw();
        }
    }
//}
/* ------------------------------------------------------------------------------------------------
 * TextBuilder
 * ------------------------------------------------------------------------------------------------
 */
//package {
    import flash.filters.GlowFilter;
    import flash.text.AntiAliasType;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;
    
    //public 
    class TextBuilder {
        public static const ALIGN_LEFT:String = "left";
        public static const ALIGN_RIGHT:String = "right";
        public static const ALIGN_CENTER:String = "center";
        
        public static var deviceFonts:Boolean = false;
        
        private var _posX:Number;
        private var _posY:Number;
        
        private var _width:Number;
        private var _height:Number;
        
        private var _background:Boolean;
        private var _backgroundColor:uint;
        
        private var _border:Boolean;
        private var _borderColor:uint;
        
        private var _fontName:String;
        private var _embedFonts:Boolean;
        private var _advancedAntiAlias:Boolean;
        
        private var _fontSize:int;
        private var _fontColor:uint;
        private var _bold:Boolean;
        
        private var _textBorder:Boolean;
        private var _textBorderColor:uint;
        private var _textBorderBlur:Number;
        private var _textBorderStrength:Number;
        
        private var _align:String;
        private var _autoSizeEnabled:Boolean;
        private var _autoCorrectPositionY:Boolean;
        private var _wordWrap:Boolean;
        
        public function TextBuilder() {
            clear();
        }
        
        public function clear():TextBuilder {
            _posX = 0;
            _posY = 0;
            _width = 100;
            _height = 100;
            _background = false;
            _backgroundColor = 0xffffff;
            _border = false;
            _borderColor = 0x000000;
            _fontName = "Arial";
            _embedFonts = false;
            _advancedAntiAlias = false;
            _fontSize = 12;
            _fontColor = 0x000000;
            _bold = false;
            _textBorder = false;
            _textBorderColor = 0xffff00;
            _textBorderBlur = 4;
            _textBorderStrength = 2;
            _align = TextBuilder.ALIGN_LEFT;
            _autoSizeEnabled = false;
            _autoCorrectPositionY = false;
            _wordWrap = false;
            return this;
        }
        
        public function position(x:Number, y:Number, isRelative:Boolean = false):TextBuilder {
            if (isRelative) {
                _posX += x;
                _posY += y;
            }else{
                _posX = x;
                _posY = y;
            }
            return this;
        }
        
        public function size(width:Number, height:Number):TextBuilder {
            _width = width;
            _height = height;
            return this;
        }
        
        public function background(enabled:Boolean, color:uint = 0xffffff):TextBuilder {
            _background = enabled;
            _backgroundColor = color;
            return this;
        }
        
        public function border(enabled:Boolean, color:uint = 0x000000):TextBuilder {
            _border = enabled;
            _borderColor = color;
            return this;
        }
        
        public function font(name:String, embed:Boolean = false, advancedAntiAlias:Boolean = false):TextBuilder {
            if (deviceFonts) { return this; }
            
            _fontName = name;
            _embedFonts = embed;
            _advancedAntiAlias = advancedAntiAlias;
            return this;
        }
        
        public function fontSize(size:int):TextBuilder {
            _fontSize = size;
            return this;
        }
        
        public function fontColor(color:uint):TextBuilder {
            _fontColor = color;
            return this;
        }
        
        public function bold(enabled:Boolean = true):TextBuilder {
            _bold = enabled;
            return this;
        }
        
        public function textBorder(enabled:Boolean, color:uint = 0xffff00, blur:Number = 4, strength:Number = 2):TextBuilder {
            _textBorder = enabled;
            _textBorderColor = color;
            _textBorderBlur = blur;
            _textBorderStrength = strength;
            return this;
        }
        
        public function align(value:String = TextBuilder.ALIGN_LEFT):TextBuilder {
            _align = value;
            return this;
        }
        
        public function autoSize(enabled:Boolean = true, correctsY:Boolean = true):TextBuilder {
            _autoSizeEnabled = enabled;
            _autoCorrectPositionY = correctsY;
            return this;
        }
        
        public function wordWrap(enabled:Boolean = true):TextBuilder {
            _wordWrap = enabled;
            return this;
        }
        
        public function build(text:String):TextField {
            var textField:TextField = new TextField();
            
            textField.x = _posX;
            textField.y = _posY;
            textField.width = _width;
            textField.height = _height;
            
            var format:TextFormat = new TextFormat(_fontName, _fontSize, _fontColor, _bold);
            if (_autoSizeEnabled) {
                switch(_align) {
                    case TextBuilder.ALIGN_LEFT: { textField.autoSize = TextFieldAutoSize.LEFT; break; }
                    case TextBuilder.ALIGN_RIGHT: { textField.autoSize = TextFieldAutoSize.RIGHT; break; }
                    case TextBuilder.ALIGN_CENTER: { textField.autoSize = TextFieldAutoSize.CENTER; break; }
                }
            }else {
                switch(_align) {
                    case TextBuilder.ALIGN_LEFT: { format.align = TextFormatAlign.LEFT; break; }
                    case TextBuilder.ALIGN_RIGHT: { format.align = TextFormatAlign.RIGHT; break; }
                    case TextBuilder.ALIGN_CENTER: { format.align = TextFormatAlign.CENTER; break; }
                }
            }
            
            textField.embedFonts = _embedFonts;
            textField.antiAliasType = (_advancedAntiAlias ? AntiAliasType.ADVANCED : AntiAliasType.NORMAL);
            textField.defaultTextFormat = format;
            textField.text = text;
            
            if (textField.background = _background) { textField.backgroundColor = _backgroundColor; }
            if (textField.border = _border) { textField.borderColor = _borderColor; }
            if (_textBorder) { textField.filters = [new GlowFilter(_textBorderColor, 1, _textBorderBlur, _textBorderBlur, _textBorderStrength)]; }
            if (!(textField.wordWrap = _wordWrap) && _autoCorrectPositionY) { textField.y += Math.max(0, Math.ceil((_height - (textField.textHeight + 4)) / 2)); }
            textField.mouseEnabled = textField.selectable = false;
            
            return textField;
        }
        
        public function clone():TextBuilder {
            var clone:TextBuilder = new TextBuilder();
            clone._posX = _posX;
            clone._posY = _posY;
            clone._width = _width;
            clone._height = _height;
            clone._background = _background;
            clone._backgroundColor = _backgroundColor;
            clone._border = _border;
            clone._borderColor = _borderColor;
            clone._fontName = _fontName;
            clone._embedFonts = _embedFonts;
            clone._advancedAntiAlias = _advancedAntiAlias;
            clone._fontSize = _fontSize;
            clone._fontColor = _fontColor;
            clone._bold = _bold;
            clone._textBorder = _textBorder;
            clone._textBorderColor = _textBorderColor;
            clone._textBorderBlur = _textBorderBlur;
            clone._textBorderStrength = _textBorderStrength;
            clone._align = _align;
            clone._autoSizeEnabled = _autoSizeEnabled;
            clone._autoCorrectPositionY = _autoCorrectPositionY;
            clone._wordWrap = _wordWrap;
            return clone;
        }
    }
//}
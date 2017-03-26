/*
 * Copyright (c) 2009 psyark.jp
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
package {
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.events.ContextMenuEvent;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.system.Security;
    import flash.ui.ContextMenu;
    import flash.ui.ContextMenuItem;
    import flash.ui.Keyboard;
    
    [SWF(width=465,height=465,backgroundColor=0xFFFFFF,frameRate=60)]
    public class Wonderflized extends Sprite {
        private var tabView:TabView;
        
        private var liveClient:PsycodeLiveClient;
        
        public function Wonderflized() {
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
            
            tabView = new TabView();
            addChild(tabView);
            
            tabView.addItem(new AdvancedTextEditor(), "無題");
            tabView.addEventListener(Event.OPEN, function (event:Event):void {
                tabView.addItem(new AdvancedTextEditor(), "無題");
            });
            
            liveClient = new PsycodeLiveClient("_PsycodeLive", "test2");
            addChild(liveClient);
            
            Security.allowDomain("*");
            
            stage.addEventListener(Event.RESIZE, updateLayout);
            stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler, true);
            updateLayout();
            
            contextMenu = createContextMenu();
        }
        
        
        private function createContextMenu():ContextMenu {
            var compileItem:ContextMenuItem = new ContextMenuItem("コンパイル(&C)");
            compileItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, function (event:Event):void {
                compile();
            });
            var unloadItem:ContextMenuItem = new ContextMenuItem("アンロード(&U)");
            unloadItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, function (event:Event):void {
                liveClient.unload();
            });
            var menu:ContextMenu = new ContextMenu();
            menu.addEventListener(ContextMenuEvent.MENU_SELECT, function (event:ContextMenuEvent):void {
                unloadItem.enabled = liveClient.content != null;
            });
            menu.customItems.push(compileItem);
            menu.customItems.push(unloadItem);
            return menu;
        }
        
        public function compile():void {
            var targetFile:String;
            
            for (var i:int=0; i<tabView.count; i++) {
                var editor:TextEditor = tabView.getItemAt(i) as TextEditor;
                if (editor) {
                    var localName:String = CodeUtil.getDefinitionLocalName(editor.text);
                    if (localName) {
                        tabView.setTitle(editor, localName ? localName + ".as" : "無題");
                        
                        var symbolName:String = CodeUtil.getDefinitionName(editor.text);
                        var fileName:String = symbolName.replace(/\./g, "/") + ".as";
                        liveClient.save(fileName, editor.text);
                        targetFile ||= fileName;
                    }
                }
            }
            
            if (targetFile) {
                liveClient.compile(targetFile);
            }
        }
        
        
        private function keyDownHandler(event:KeyboardEvent):void {
            if (event.keyCode == Keyboard.F11) {
                compile();
            }
        }
        
        private function updateLayout(event:Event=null):void {
            tabView.width = stage.stageWidth;
            tabView.height = stage.stageHeight;
        }
    }
}


/*
 jp/psyark/psycode/core/codehint/CatalogEntry.as
*/

class CatalogEntry {
    public var identifier:String;
    public var name:String;
    
    public function CatalogEntry(identifier:String) {
        this.identifier = identifier;
        name = identifier.split(":").pop();
    }
}



/*
 jp/psyark/psycode/core/codehint/Catalog.as
*/

class Catalog {
    public static var catalog:Array;
    
    {
        init();
    }
    
    public static function init():void {
        catalog = [];
        var add:Function = function (id:String):void {
            catalog.push(new CatalogEntry(id));
        };
        add("AS3");
        add("ArgumentError");
        add("Array");
        add("Boolean");
        add("Class");
        add("Date");
        add("DefinitionError");
        add("Error");
        add("EvalError");
        add("Function");
        add("Infinity");
        add("Math");
        add("NaN");
        add("Namespace");
        add("Number");
        add("Object");
        add("QName");
        add("RangeError");
        add("ReferenceError");
        add("RegExp");
        add("SecurityError");
        add("String");
        add("SyntaxError");
        add("TypeError");
        add("URIError");
        add("UninitializedError");
        add("VerifyError");
        add("XML");
        add("XMLList");
        add("__AS3__.vec:Vector");
        add("__AS3__.vec:Vector$double");
        add("__AS3__.vec:Vector$int");
        add("__AS3__.vec:Vector$object");
        add("__AS3__.vec:Vector$uint");
        add("adobe.utils:CustomActions");
        add("adobe.utils:MMEndCommand");
        add("adobe.utils:MMExecute");
        add("adobe.utils:ProductManager");
        add("adobe.utils:XMLUI");
        add("authoring:authObject");
        add("decodeURI");
        add("decodeURIComponent");
        add("encodeURI");
        add("encodeURIComponent");
        add("escape");
        add("flash.accessibility:Accessibility");
        add("flash.accessibility:AccessibilityImplementation");
        add("flash.accessibility:AccessibilityProperties");
        add("flash.debugger:enterDebugger");
        add("flash.desktop:Clipboard");
        add("flash.desktop:ClipboardFormats");
        add("flash.desktop:ClipboardTransferMode");
        add("flash.display:AVM1Movie");
        add("flash.display:ActionScriptVersion");
        add("flash.display:Bitmap");
        add("flash.display:BitmapData");
        add("flash.display:BitmapDataChannel");
        add("flash.display:BlendMode");
        add("flash.display:CapsStyle");
        add("flash.display:ColorCorrection");
        add("flash.display:ColorCorrectionSupport");
        add("flash.display:DisplayObject");
        add("flash.display:DisplayObjectContainer");
        add("flash.display:FrameLabel");
        add("flash.display:GradientType");
        add("flash.display:Graphics");
        add("flash.display:GraphicsBitmapFill");
        add("flash.display:GraphicsEndFill");
        add("flash.display:GraphicsGradientFill");
        add("flash.display:GraphicsPath");
        add("flash.display:GraphicsPathCommand");
        add("flash.display:GraphicsPathWinding");
        add("flash.display:GraphicsShaderFill");
        add("flash.display:GraphicsSolidFill");
        add("flash.display:GraphicsStroke");
        add("flash.display:GraphicsTrianglePath");
        add("flash.display:IBitmapDrawable");
        add("flash.display:IGraphicsData");
        add("flash.display:IGraphicsFill");
        add("flash.display:IGraphicsPath");
        add("flash.display:IGraphicsStroke");
        add("flash.display:InteractiveObject");
        add("flash.display:InterpolationMethod");
        add("flash.display:JointStyle");
        add("flash.display:LineScaleMode");
        add("flash.display:Loader");
        add("flash.display:LoaderInfo");
        add("flash.display:MorphShape");
        add("flash.display:MovieClip");
        add("flash.display:PixelSnapping");
        add("flash.display:SWFVersion");
        add("flash.display:Scene");
        add("flash.display:Shader");
        add("flash.display:ShaderData");
        add("flash.display:ShaderInput");
        add("flash.display:ShaderJob");
        add("flash.display:ShaderParameter");
        add("flash.display:ShaderParameterType");
        add("flash.display:ShaderPrecision");
        add("flash.display:Shape");
        add("flash.display:SimpleButton");
        add("flash.display:SpreadMethod");
        add("flash.display:Sprite");
        add("flash.display:Stage");
        add("flash.display:StageAlign");
        add("flash.display:StageDisplayState");
        add("flash.display:StageQuality");
        add("flash.display:StageScaleMode");
        add("flash.display:TriangleCulling");
        add("flash.errors:EOFError");
        add("flash.errors:IOError");
        add("flash.errors:IllegalOperationError");
        add("flash.errors:InvalidSWFError");
        add("flash.errors:MemoryError");
        add("flash.errors:ScriptTimeoutError");
        add("flash.errors:StackOverflowError");
        add("flash.events:ActivityEvent");
        add("flash.events:AsyncErrorEvent");
        add("flash.events:ContextMenuEvent");
        add("flash.events:DataEvent");
        add("flash.events:ErrorEvent");
        add("flash.events:Event");
        add("flash.events:EventDispatcher");
        add("flash.events:EventPhase");
        add("flash.events:FocusEvent");
        add("flash.events:FullScreenEvent");
        add("flash.events:HTTPStatusEvent");
        add("flash.events:IEventDispatcher");
        add("flash.events:IMEEvent");
        add("flash.events:IOErrorEvent");
        add("flash.events:KeyboardEvent");
        add("flash.events:MouseEvent");
        add("flash.events:NetFilterEvent");
        add("flash.events:NetStatusEvent");
        add("flash.events:ProgressEvent");
        add("flash.events:SampleDataEvent");
        add("flash.events:SecurityErrorEvent");
        add("flash.events:ShaderEvent");
        add("flash.events:StatusEvent");
        add("flash.events:SyncEvent");
        add("flash.events:TextEvent");
        add("flash.events:TimerEvent");
        add("flash.events:WeakFunctionClosure");
        add("flash.events:WeakMethodClosure");
        add("flash.external:ExternalInterface");
        add("flash.filters:BevelFilter");
        add("flash.filters:BitmapFilter");
        add("flash.filters:BitmapFilterQuality");
        add("flash.filters:BitmapFilterType");
        add("flash.filters:BlurFilter");
        add("flash.filters:ColorMatrixFilter");
        add("flash.filters:ConvolutionFilter");
        add("flash.filters:DisplacementMapFilter");
        add("flash.filters:DisplacementMapFilterMode");
        add("flash.filters:DropShadowFilter");
        add("flash.filters:GlowFilter");
        add("flash.filters:GradientBevelFilter");
        add("flash.filters:GradientGlowFilter");
        add("flash.filters:ShaderFilter");
        add("flash.geom:ColorTransform");
        add("flash.geom:Matrix");
        add("flash.geom:Matrix3D");
        add("flash.geom:Orientation3D");
        add("flash.geom:PerspectiveProjection");
        add("flash.geom:Point");
        add("flash.geom:Rectangle");
        add("flash.geom:Transform");
        add("flash.geom:Utils3D");
        add("flash.geom:Vector3D");
        add("flash.media:Camera");
        add("flash.media:ID3Info");
        add("flash.media:Microphone");
        add("flash.media:Sound");
        add("flash.media:SoundChannel");
        add("flash.media:SoundCodec");
        add("flash.media:SoundLoaderContext");
        add("flash.media:SoundMixer");
        add("flash.media:SoundTransform");
        add("flash.media:Video");
        add("flash.net:DynamicPropertyOutput");
        add("flash.net:FileFilter");
        add("flash.net:FileReference");
        add("flash.net:FileReferenceList");
        add("flash.net:IDynamicPropertyOutput");
        add("flash.net:IDynamicPropertyWriter");
        add("flash.net:LocalConnection");
        add("flash.net:NetConnection");
        add("flash.net:NetStream");
        add("flash.net:NetStreamInfo");
        add("flash.net:NetStreamPlayOptions");
        add("flash.net:NetStreamPlayTransitions");
        add("flash.net:ObjectEncoding");
        add("flash.net:Responder");
        add("flash.net:SharedObject");
        add("flash.net:SharedObjectFlushStatus");
        add("flash.net:Socket");
        add("flash.net:URLLoader");
        add("flash.net:URLLoaderDataFormat");
        add("flash.net:URLRequest");
        add("flash.net:URLRequestHeader");
        add("flash.net:URLRequestMethod");
        add("flash.net:URLStream");
        add("flash.net:URLVariables");
        add("flash.net:XMLSocket");
        add("flash.net:getClassByAlias");
        add("flash.net:navigateToURL");
        add("flash.net:registerClassAlias");
        add("flash.net:sendToURL");
        add("flash.printing:PrintJob");
        add("flash.printing:PrintJobOptions");
        add("flash.printing:PrintJobOrientation");
        add("flash.profiler:profile");
        add("flash.profiler:showRedrawRegions");
        add("flash.sampler:DeleteObjectSample");
        add("flash.sampler:NewObjectSample");
        add("flash.sampler:Sample");
        add("flash.sampler:StackFrame");
        add("flash.sampler:_getInvocationCount");
        add("flash.sampler:clearSamples");
        add("flash.sampler:getGetterInvocationCount");
        add("flash.sampler:getInvocationCount");
        add("flash.sampler:getMemberNames");
        add("flash.sampler:getSampleCount");
        add("flash.sampler:getSamples");
        add("flash.sampler:getSetterInvocationCount");
        add("flash.sampler:getSize");
        add("flash.sampler:isGetterSetter");
        add("flash.sampler:pauseSampling");
        add("flash.sampler:startSampling");
        add("flash.sampler:stopSampling");
        add("flash.system:ApplicationDomain");
        add("flash.system:Capabilities");
        add("flash.system:FSCommand");
        add("flash.system:IME");
        add("flash.system:IMEConversionMode");
        add("flash.system:JPEGLoaderContext");
        add("flash.system:LoaderContext");
        add("flash.system:Security");
        add("flash.system:SecurityDomain");
        add("flash.system:SecurityPanel");
        add("flash.system:System");
        add("flash.system:fscommand");
        add("flash.text.engine:BreakOpportunity");
        add("flash.text.engine:CFFHinting");
        add("flash.text.engine:ContentElement");
        add("flash.text.engine:DigitCase");
        add("flash.text.engine:DigitWidth");
        add("flash.text.engine:EastAsianJustifier");
        add("flash.text.engine:ElementFormat");
        add("flash.text.engine:FontDescription");
        add("flash.text.engine:FontLookup");
        add("flash.text.engine:FontMetrics");
        add("flash.text.engine:FontPosture");
        add("flash.text.engine:FontWeight");
        add("flash.text.engine:GraphicElement");
        add("flash.text.engine:GroupElement");
        add("flash.text.engine:JustificationStyle");
        add("flash.text.engine:Kerning");
        add("flash.text.engine:LigatureLevel");
        add("flash.text.engine:LineJustification");
        add("flash.text.engine:RenderingMode");
        add("flash.text.engine:SpaceJustifier");
        add("flash.text.engine:TabAlignment");
        add("flash.text.engine:TabStop");
        add("flash.text.engine:TextBaseline");
        add("flash.text.engine:TextBlock");
        add("flash.text.engine:TextElement");
        add("flash.text.engine:TextJustifier");
        add("flash.text.engine:TextLine");
        add("flash.text.engine:TextLineCreationResult");
        add("flash.text.engine:TextLineMirrorRegion");
        add("flash.text.engine:TextLineValidity");
        add("flash.text.engine:TextRotation");
        add("flash.text.engine:TypographicCase");
        add("flash.text:AntiAliasType");
        add("flash.text:CSMSettings");
        add("flash.text:Font");
        add("flash.text:FontStyle");
        add("flash.text:FontType");
        add("flash.text:GridFitType");
        add("flash.text:StaticText");
        add("flash.text:StyleSheet");
        add("flash.text:TextColorType");
        add("flash.text:TextDisplayMode");
        add("flash.text:TextExtent");
        add("flash.text:TextField");
        add("flash.text:TextFieldAutoSize");
        add("flash.text:TextFieldType");
        add("flash.text:TextFormat");
        add("flash.text:TextFormatAlign");
        add("flash.text:TextFormatDisplay");
        add("flash.text:TextLineMetrics");
        add("flash.text:TextRenderer");
        add("flash.text:TextRun");
        add("flash.text:TextSnapshot");
        add("flash.trace:Trace");
        add("flash.ui:ContextMenu");
        add("flash.ui:ContextMenuBuiltInItems");
        add("flash.ui:ContextMenuClipboardItems");
        add("flash.ui:ContextMenuItem");
        add("flash.ui:KeyLocation");
        add("flash.ui:Keyboard");
        add("flash.ui:Mouse");
        add("flash.ui:MouseCursor");
        add("flash.utils:ByteArray");
        add("flash.utils:Dictionary");
        add("flash.utils:Endian");
        add("flash.utils:IDataInput");
        add("flash.utils:IDataOutput");
        add("flash.utils:IExternalizable");
        add("flash.utils:ObjectInput");
        add("flash.utils:ObjectOutput");
        add("flash.utils:Proxy");
        add("flash.utils:SetIntervalTimer");
        add("flash.utils:Timer");
        add("flash.utils:clearInterval");
        add("flash.utils:clearTimeout");
        add("flash.utils:describeType");
        add("flash.utils:escapeMultiByte");
        add("flash.utils:flash_proxy");
        add("flash.utils:getDefinitionByName");
        add("flash.utils:getQualifiedClassName");
        add("flash.utils:getQualifiedSuperclassName");
        add("flash.utils:getTimer");
        add("flash.utils:setInterval");
        add("flash.utils:setTimeout");
        add("flash.utils:unescapeMultiByte");
        add("flash.xml:XMLDocument");
        add("flash.xml:XMLNode");
        add("flash.xml:XMLNodeType");
        add("flash.xml:XMLParser");
        add("flash.xml:XMLTag");
        add("int");
        add("isFinite");
        add("isNaN");
        add("isXMLName");
        add("parseFloat");
        add("parseInt");
        add("trace");
        add("uint");
        add("undefined");
        add("unescape");

        catalog = catalog.sort(function (a:CatalogEntry, b:CatalogEntry):int {
            return a.name > b.name ? 1 : -1;
        });
    }
}



/*
 jp/psyark/psycode/utils/CodeUtil.as
*/

class CodeUtil {
    public static function getDefinitionLocalName(code:String):String {
        var match:Array = code.match(/\Wpublic\s+(?:class|interface|function|namespace)\s+([_a-zA-Z]\w*)/);
        return match && match[1] ? match[1] : "";
    }
    
    public static function getDefinitionName(code:String):String {
        var result:String = getDefinitionLocalName(code);
        if (result == "") {
            return "";
        }
        
        var match:Array = code.match(/package\s+([_a-zA-Z]\w*(?:\.[_a-zA-Z]\w*)*)/);
        if (match && match[1]) {
            result = match[1] + "." + result;
        }
        return result;
    }
}



/*
 jp/psyark/psycode/core/history/HistoryEntry.as
*/

class HistoryEntry {
    public var index:int;
    public var oldText:String;
    public var newText:String;
    
    public function HistoryEntry(index:int=0, oldText:String="", newText:String="") {
        this.index   = index;
        this.oldText = oldText;
        this.newText = newText;
    }
}



/*
 jp/psyark/utils/StringComparator.as
*/

/**
 * 文字列の左右一致を数える
 */
class StringComparator {
    /**
     * @private
     */
    internal static function test():void {
        var sc:StringComparator = new StringComparator();
        var test:Function = function (a:String, b:String, l:int, r:int):void {
            sc.compare(a, b);
            if (sc.commonPrefixLength != l || sc.commonSuffixLength != r) {
                throw new Error();
            }
        };
        test("Hello World", "Hello World", 11, 0);
        test("Hello World", "Hello! World", 5, 6);
        test("Hello World", "HelPIYOrld", 3, 3);
        test("a", "aB", 1, 0);
        test("aBC", "aBCD", 3, 0);
        test("Ba", "a", 0, 1);
        test("aBC", "DaBC", 0, 3);
        test("aXbXc", "aXc", 2, 1);
        test("aaaXccc", "aaaXbbbXccc", 4, 3);
    }
    
    /**
     * 左側の共通文字列長
     */
    public var commonPrefixLength:int;
    
    /**
     * 右側の共通文字列長
     */
    public var commonSuffixLength:int;
    
    /**
     * 2つの文字列を比較し、commonPrefixLengthとcommonSuffixLengthをセットする
     * 
     * @param str1 比較する文字列の一方
     * @param str2 比較する文字列の他方
     */
    public function compare(str1:String, str2:String):void {
        var minLength:int = Math.min(str1.length, str2.length);
        var step:int, l:int, r:int;
        
        step = Math.pow(2, Math.floor(Math.log(minLength) / Math.log(2)));
        for (l=0; l<minLength; ) {
            if (str1.substr(0, l + step) != str2.substr(0, l + step)) {
                if (step == 1) { break; }
                step >>= 1;
            } else {
                l += step;
            }
        }
        l = Math.min(l, minLength);
        
        minLength -= l;
        
        step = Math.pow(2, Math.floor(Math.log(minLength) / Math.log(2)));
        for (r=0; r<minLength; ) {
            if (str1.substr(-r - step) != str2.substr(-r - step)) {
                if (step == 1) { break; }
                step >>= 1;
            } else {
                r += step;
            }
        }
        r = Math.min(r, minLength);
        
        commonPrefixLength = l;
        commonSuffixLength = r;
    }
}



/*
 jp/psyark/utils/escapeText.as
*/

function escapeText(str:String):String {
    return EscapeTextInternal.escapeText(str);
}

class EscapeTextInternal {
    private static var table:Object;
    {
        table = {};
        table["\t"] = "\\t";
        table["\r"] = "\\r";
        table["\n"] = "\\n";
        table["\\"] = "\\\\";
    }
    
    public static function escapeText(str:String):String {
        return str.replace(/[\t\r\n\\]/g, replace);
    }
    
    private static function replace(match:String, index:int, source:String):String {
        return table[match];
    }
}



/*
 jp/psyark/psycode/core/psycode_internal.as
*/

namespace psycode_internal = "http://psyark.jp/ns/psycode";



/*
 jp/psyark/utils/convertNewlines.as
*/

function convertNewlines(str:String, newline:String="\n"):String {
    return str.replace(/\r\n|\r|\n/g, newline);
}



/*
 jp/psyark/psycode/core/linenumber/LineNumberView.as
*/

import flash.events.Event;
import flash.text.TextField;
import flash.text.TextFormat;

/**
 * 行番号表示
 */
class LineNumberView extends TextField {
    private var target:TextField;
    
    public function LineNumberView(target:TextField) {
        this.target = target;
        
        width = 30;
        background = true;
        backgroundColor = 0xF2F2F2;
        multiline = true;
        selectable = false;
        
        target.addEventListener(Event.CHANGE, updateView);
        target.addEventListener(Event.SCROLL, updateView);
    }
    
    public override function setTextFormat(format:TextFormat, beginIndex:int=-1, endIndex:int=-1):void {
        defaultTextFormat = format;
        super.setTextFormat(format);
        updateView(null);
    }
    
    private function updateView(event:Event):void {
        text = "000\n" + target.numLines;
        width = textWidth + 4;
        text = "";
        for (var i:int=target.scrollV; i<=target.bottomScrollV; i++) {
            appendText(i + "\n");
        }
        dispatchEvent(new Event(Event.RESIZE));
    }
}



/*
 jp/psyark/psycode/controls/UIControl.as
*/

import flash.display.Sprite;

class UIControl extends Sprite {
    private var _width:Number = 100;
    private var _height:Number = 100;
    
    
    /**
     * コントロールの幅と高さ設定します。
     */
    public function setSize(width:Number, height:Number):void {
        if (_width != width || _height != height) {
            _width = width;
            _height = height;
            updateSize();
        }
    }
    
    
    /**
     * コントロールの幅を取得または設定します。
     */
    public override function get width():Number {
        return _width;
    }
    
    /**
     * @private
     */
    public override function set width(value:Number):void {
        if (_width != value) {
            _width = value;
            updateSize();
        }
    }
    
    /**
     * コントロールの高さを取得または設定します。
     */
    public override function get height():Number {
        return _height;
    }
    
    /**
     * @private
     */
    public override function set height(value:Number):void {
        if (_height != value) {
            _height = value;
            updateSize();
        }
    }
    
    
    /**
     * コントロールのサイズを更新します。
     */
    protected function updateSize():void {
    }
}



/*
 jp/psyark/psycode/controls/ScrollBar.as
*/

import flash.display.GradientType;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Matrix;

[Event(name="change", type="flash.events.Event")]
class ScrollBar extends UIControl {
    public static const HORIZONTAL:String = "horizontal";
    public static const VERTICAL:String = "vertical";
    protected const BAR_THICKNESS:Number = 16;
    protected const MIN_HANDLE_LENGTH:Number = 14;
    
    
    protected var handle:ScrollBarHandle;
    protected var track:Sprite;
    protected var draggableSize:Number;
    private var handlePressX:Number;
    private var handlePressY:Number;
    private var dragging:Boolean = false;
    
    protected var trackColors:Array = [0xDDDDDD, 0xECECEC, 0xF5F5F5];
    protected var trackAlphas:Array = [1, 1, 1];
    protected var trackRatios:Array = [0x00, 0x2A, 0xFF];
    
    
    private var _direction:String;
    public function get direction():String {
        return _direction;
    }
    
    private var _value:Number = 0;
    public function get value():Number {
        return _value;
    }
    public function set value(v:Number):void {
        if (_value != v) {
            _value = v;
            updateHandle();
        }
    }
    
    private var _maxValue:Number = 1;
    public function get maxValue():Number {
        return _maxValue;
    }
    public function set maxValue(value:Number):void {
        if (_maxValue != value) {
            _maxValue = value;
            updateHandle();
        }
    }
    
    private var _minValue:Number = 0;
    public function get minValue():Number {
        return _minValue;
    }
    public function set minValue(value:Number):void {
        if (_minValue != value) {
            _minValue = value;
            updateHandle();
        }
    }
    
    private var _viewSize:Number = 0;
    public function get viewSize():Number {
        return _viewSize;
    }
    public function set viewSize(value:Number):void {
        if (_viewSize != value) {
            _viewSize = value;
            updateHandle();
        }
    }
    
    public override function get width():Number {
        return direction == VERTICAL ? BAR_THICKNESS : super.width;
    }
    
    public override function get height():Number {
        return direction == HORIZONTAL ? BAR_THICKNESS : super.height;
    }
    
    public function ScrollBar(direction:String="vertical") {
        if (direction == HORIZONTAL || direction == VERTICAL) {
            _direction = direction;
        } else {
            throw new ArgumentError("direction must be " + HORIZONTAL + " or " + VERTICAL + ".");
        }
        
        track = new Sprite();
        track.addEventListener(MouseEvent.MOUSE_DOWN, trackMouseDownHandler);
        addChild(track);
        
        handle = new ScrollBarHandle(direction);
        handle.addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDownHandler);
        addChild(handle);
        invalidateAll();
    }
    
    protected function invalidateAll():void {
        updateTrack();
        updateHandle();
    }
    
    
    /**
     * スクロールバーの表示を更新します。
     */
    protected function updateTrack():void {
        var mtx:Matrix = new Matrix();
        
        track.graphics.clear();
        if (direction == VERTICAL) {
            mtx.createGradientBox(BAR_THICKNESS, height);
            track.graphics.beginGradientFill(GradientType.LINEAR, trackColors, trackAlphas, trackRatios, mtx);
            track.graphics.drawRect(0, 0, BAR_THICKNESS, height);
        } else {
            mtx.createGradientBox(BAR_THICKNESS, height, Math.PI / 2);
            track.graphics.beginGradientFill(GradientType.LINEAR, trackColors, trackAlphas, trackRatios, mtx);
            track.graphics.drawRect(0, 0, width, BAR_THICKNESS);
        }
    }
    
    
    protected function updateHandle():void {
        if (maxValue > minValue) {
            var t:Number = Math.max(minValue, Math.min(maxValue, value));
            if (value != t) {
                value = t;
                dispatchEvent(new Event(Event.CHANGE));
            }
            
            handle.visible = true;
            if (direction == VERTICAL) {
                var handleHeight:Number = MIN_HANDLE_LENGTH + (height - MIN_HANDLE_LENGTH) * viewSize / (maxValue - minValue + viewSize);
                draggableSize = height - handleHeight;
                handle.setSize(BAR_THICKNESS - 1, handleHeight);
                handle.x = 1;
                if (dragging == false) {
                    handle.y = (value - minValue) / (maxValue - minValue) * draggableSize;
                }
            } else {
                var handleWidth:Number = MIN_HANDLE_LENGTH + (width - MIN_HANDLE_LENGTH) * viewSize / (maxValue - minValue + viewSize);
                draggableSize = width - handleWidth;
                handle.setSize(handleWidth, BAR_THICKNESS - 1);
                handle.y = 1;
                if (dragging == false) {
                    handle.x = (value - minValue) / (maxValue - minValue) * draggableSize;
                }
            }
        } else {
            handle.visible = false;
        }
    }
    
    protected function trackMouseDownHandler(event:MouseEvent):void {
        
    }
    
    protected function handleMouseDownHandler(event:MouseEvent):void {
        stage.addEventListener(MouseEvent.MOUSE_MOVE, stageMouseMoveHandler);
        stage.addEventListener(MouseEvent.MOUSE_UP, stageMouseUpHandler);
        handlePressX = mouseX - handle.x;
        handlePressY = mouseY - handle.y;
        dragging = true;
    }
    
    protected function stageMouseMoveHandler(event:MouseEvent):void {
        event.updateAfterEvent();
        var position:Number;
        if (direction == VERTICAL) {
            position = handle.y = Math.max(0, Math.min(draggableSize, mouseY - handlePressY));
        } else {
            position = handle.x = Math.max(0, Math.min(draggableSize, mouseX - handlePressX));
        }
        var newValue:Number = (position / draggableSize) * (maxValue - minValue) + minValue;
        if (_value != newValue) {
            _value = newValue;
            dispatchEvent(new Event(Event.CHANGE));
        }
    }
    
    protected function stageMouseUpHandler(event:MouseEvent):void {
        stage.removeEventListener(MouseEvent.MOUSE_MOVE, stageMouseMoveHandler);
        stage.removeEventListener(MouseEvent.MOUSE_UP, stageMouseUpHandler);
        dragging = false;
    }
    
    protected override function updateSize():void {
        invalidateAll();
    }
}



/*
 jp/psyark/psycode/controls/TextScrollBar.as
*/

import flash.events.Event;
import flash.text.TextField;

class TextScrollBar extends ScrollBar {
    private var target:TextField;
    
    public function TextScrollBar(target:TextField, direction:String="vertical") {
        this.target = target;
        super(direction);
        
        if (direction == VERTICAL) {
            minValue = 1;
            value = 1;
        }
        
        addEventListener(Event.CHANGE, changeHandler);
        target.addEventListener(Event.CHANGE, targetChangeHandler);
        target.addEventListener(Event.SCROLL, targetScrollHandler);
        
        targetChangeHandler(null);
        targetScrollHandler(null);
    }
    
    private function changeHandler(event:Event):void {
        if (direction == VERTICAL) {
            target.scrollV = Math.round(value);
        } else {
            target.scrollH = Math.round(value);
        }
    }
    
    private function targetChangeHandler(event:Event):void {
        correctTextFieldScrollPosition(target);
        if (direction == VERTICAL) {
            maxValue = target.maxScrollV;
            viewSize = target.bottomScrollV - target.scrollV;
        } else {
            maxValue = target.maxScrollH;
            viewSize = target.width;
        }
    }
    
    private function targetScrollHandler(event:Event):void {
        correctTextFieldScrollPosition(target);
        if (direction == VERTICAL) {
            value = target.scrollV;
        } else {
            value = target.scrollH;
        }
    }
    
    protected override function updateSize():void {
        super.updateSize();
        targetChangeHandler(null);
    }
    
    
    /**
     * 時折不正確な値を返すTextField#scrollVが、正しい値を返すようにする
     */
    protected static function correctTextFieldScrollPosition(target:TextField):void {
        // textWidthかtextHeightにアクセスすればOK
        target.textWidth;
        target.textHeight;
    }
}



/*
 jp/psyark/psycode/core/TextEditUI.as
*/

import flash.events.Event;
import flash.events.FocusEvent;
import flash.net.FileReference;
import flash.text.TextField;
import flash.text.TextFieldType;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

/**
 * @private
 * TextEditAreaクラスは、テキストフィールド・行番号・スクロールバーなど
 * テキスト編集UIの基本的な機能を提供し、それらの実装を隠蔽します。
 */
class TextEditUI extends UIControl {
    private var linumField:LineNumberView;
    private var scrollBarV:TextScrollBar;
    private var scrollBarH:TextScrollBar;
    protected var textField:TextField;
    
    private var TAB_STOP_RATIO:Number = 2.42;
    private var fileRef:FileReference;
    
    
    /**
     * TextEditUIクラスのインスタンスを初期化します。
     */
    public function TextEditUI() {
        var tabStops:Array = [];
        for (var i:int=1; i<20; i++) {
            tabStops.push(13 * TAB_STOP_RATIO * i);
        }
        var fmt:TextFormat = new TextFormat("_typewriter", 13, 0x000000);
        fmt.tabStops = tabStops;
        fmt.leading = 1;
        
        textField = new TextField();
        textField.background = true;
        textField.backgroundColor = 0xFFFFFF;
        textField.multiline = true;
        textField.type = TextFieldType.INPUT;
        textField.defaultTextFormat = fmt;
        textField.addEventListener(FocusEvent.KEY_FOCUS_CHANGE, function (event:FocusEvent):void {
            event.preventDefault();
        });
        
        fmt.align = TextFormatAlign.RIGHT;
        fmt.color = 0x666666;
        
        linumField = new LineNumberView(textField);
        linumField.setTextFormat(fmt);
        linumField.addEventListener(Event.RESIZE, linumResizeHandler);
        
        scrollBarV = new TextScrollBar(textField);
        scrollBarH = new TextScrollBar(textField, ScrollBar.HORIZONTAL);
        
        addChild(textField);
        addChild(linumField);
        addChild(scrollBarV);
        addChild(scrollBarH);
        
        updateSize();
        
        textField.addEventListener(Event.SCROLL, textFieldScrollHandler);
    }
    
    public function open():void {
        fileRef = new FileReference();
        fileRef.addEventListener(Event.SELECT, function (event:Event):void {
            fileRef.load();
        });
        fileRef.addEventListener(Event.COMPLETE, function (event:Event):void {
            text = convertNewlines(String(fileRef.data));
        });
        fileRef.browse();
    }
    
    public function save():void {
        var localName:String = CodeUtil.getDefinitionLocalName(text);
        localName ||= "untitled";
        fileRef = new FileReference();
        fileRef.save(text, localName + ".as");
    }
    
    public function setFontSize(fontSize:Number):void {
        var tabStops:Array = [];
        for (var i:int=1; i<20; i++) {
            tabStops.push(i * fontSize * 2.42);
        }
        
        var fmt:TextFormat = textField.defaultTextFormat;
        fmt.size = fontSize;
        fmt.tabStops = tabStops;
        textField.defaultTextFormat = fmt;
        
        fmt.align = TextFormatAlign.RIGHT;
        fmt.color = 0x666666;
        linumField.setTextFormat(fmt);
        
        fmt = new TextFormat();
        fmt.size = fontSize;
        fmt.tabStops = tabStops;
        textField.setTextFormat(fmt);
        
        dispatchChangeEvent();
    }
    
    
    private function textFieldScrollHandler(event:Event):void {
        dispatchEvent(event);
    }
    
    private function linumResizeHandler(event:Event):void {
        updateSize();
    }
    
    
    /**
     * テキストフィールドへのアクセスを提供します
     */
    public function get text():String {
        return textField.text;
    }
    public function set text(value:String):void {
        textField.text = value;
        dispatchChangeEvent();
    }
    public function get selectionBeginIndex():int {
        return textField.selectionBeginIndex;
    }
    public function get selectionEndIndex():int {
        return textField.selectionEndIndex;
    }
    protected function setSelection(beginIndex:int, endIndex:int):void {
        textField.setSelection(beginIndex, endIndex);
    }
    protected function replaceText(beginIndex:int, endIndex:int, newText:String):void {
        textField.replaceText(beginIndex, endIndex, convertNewlines(newText));
    }
    protected function replaceSelectedText(newText:String):void {
        textField.replaceSelectedText(newText);
    }
    psycode_internal function setTextFormat(format:TextFormat, beginIndex:int=-1, endIndex:int=-1):void {
        textField.setTextFormat(format, beginIndex, endIndex);
    }
    psycode_internal function resetFocus():void {
        if (stage.focus) {
            throw 1;
        }
        stage.focus = textField;
    }
    
    protected function dispatchChangeEvent():void {
        textField.dispatchEvent(new Event(Event.CHANGE, true));
    }
    
    
    
    
    /**
     * エディタのレイアウトを更新します。
     */
    protected override function updateSize():void {
        linumField.height = height;
        textField.x = linumField.width;
        textField.width = width - scrollBarV.width - linumField.width;
        textField.height = height - scrollBarH.height;
        scrollBarV.x = width - scrollBarV.width;
        scrollBarV.height = height - scrollBarH.height;
        scrollBarH.x = linumField.width;
        scrollBarH.y = height - scrollBarH.height;
        scrollBarH.width = width - scrollBarV.width - linumField.width;
        graphics.clear();
        graphics.beginFill(0xEEEEEE);
        graphics.drawRect(0, 0, width, height);
    }
}



/*
 jp/psyark/psycode/controls/List.as
*/

import flash.display.DisplayObject;
import flash.display.GradientType;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Matrix;

class List extends UIControl {
    private var _itemRenderer:Class = ListItemRenderer;
    private var _rowHeight:Number = 20;
    private var _dataProvider:Array;
    private var _selectedIndex:int = -1;
    private var _labelField:String = "label";
    
    private var selectionRect:Shape;
    private var rendererLayer:Sprite;
    private var scrollBar:ScrollBar;
    
    private var renderers:Array;
    private var scrollPosition:int = 0;
    
    
    /**
     * Listクラスのインスタンスを作成します。
     */
    public function List() {
        renderers = [];
        
        selectionRect = new Shape();
        rendererLayer = new Sprite();
        scrollBar = new ScrollBar();
        scrollBar.addEventListener(Event.CHANGE, scrollBarChangeHandler);
        
        addChild(selectionRect);
        addChild(rendererLayer);
        addChild(scrollBar);
        
        updateSize();
    }
    
    /**
     * リストのアイテムレンダラークラスを取得または設定します。
     */
    public function get itemRenderer():Class {
        return _itemRenderer;
    }
    
    /**
     * @private
     */
    public function set itemRenderer(value:Class):void {
        if (_itemRenderer != value) {
            _itemRenderer = value;
            updateRenderers();
        }
    }
    
    /**
     * リストの各行の高さを取得または設定します。
     */
    public function get rowHeight():Number {
        return _rowHeight;
    }
    
    /**
     * @private
     */
    public function set rowHeight(value:Number):void {
        if (_rowHeight != value) {
            _rowHeight = value;
            updateRenderers();
        }
    }
    
    /**
     * データプロバイダを取得または設定します。
     */
    public function get dataProvider():Array {
        return _dataProvider;
    }
    
    /**
     * @private
     */
    public function set dataProvider(value:Array):void {
        if (_dataProvider != value) {
            _dataProvider = value;
            updateData();
        }
    }
    
    /**
     * 選択されているアイテムのインデックスを取得または設定します。
     */
    public function get selectedIndex():int {
        return _selectedIndex;
    }
    
    /**
     * @private
     */
    public function set selectedIndex(value:int):void {
        if (_selectedIndex != value) {
            _selectedIndex = value;
            
            if (dataProvider) {
                if (value >= 0 && value < dataProvider.length) {
                    if (scrollPosition > value) {
                        scrollPosition = value;
                        scrollBar.value = scrollPosition;
                        updateData();
                    } else if (scrollPosition < value - renderers.length + 1) {
                        scrollPosition = value - renderers.length + 1;
                        scrollBar.value = scrollPosition;
                        updateData();
                    }
                }
            }
            updateData();
        }
    }
    
    /**
     * ラベルとして使うプロパティ名を取得または設定します。
     */
    public function get labelField():String {
        return _labelField;
    }
    
    /**
     * @private
     */
    public function set labelField(value:String):void {
        if (_labelField != value) {
            _labelField = value;
            updateData();
        }
    }
    
    /**
     * 
     */
    public function get selectedItem():Object {
        return _dataProvider ? _dataProvider[selectedIndex] : null
    }
    public function set selectedItem(value:Object):void {
        selectedIndex = _dataProvider ? _dataProvider.indexOf(value) : -1;
    }
    
    
    /**
     * アイテムレンダラーに与えるデータを更新します。
     */
    protected function updateData():void {
        scrollBar.maxValue = dataProvider ? Math.max(0, dataProvider.length - renderers.length) : 0;
        
        for (var i:int=0; i<renderers.length; i++) {
            var renderer:ListItemRenderer = renderers[(i + scrollPosition) % renderers.length];
            renderer.labelField = labelField;
            if (_dataProvider) {
                renderer.data = _dataProvider[i + scrollPosition];
            } else {
                renderer.data = null;
            }
            renderer.height = rowHeight;
            renderer.y = i * rowHeight;
        }
        
        if (_dataProvider && selectedIndex >= scrollPosition && selectedIndex < (scrollPosition + renderers.length)) {
            selectionRect.visible = true;
            selectionRect.y = (selectedIndex - scrollPosition) * rowHeight;
        } else {
            selectionRect.visible = false;
        }
    }
    
    /**
     * アイテムレンダラーを作成します。
     */
    protected function updateRenderers():void {
        var itemCount:int = Math.floor(height / rowHeight);
        
        while (renderers.length > itemCount) {
            rendererLayer.removeChild(renderers.pop() as DisplayObject);
        }
        while (renderers.length < itemCount) {
            var renderer:ListItemRenderer = new itemRenderer();
            renderer.addEventListener(MouseEvent.CLICK, rendererClickHandler, false, 0, true);
            renderers.push(renderer);
            rendererLayer.addChild(renderer);
        }
        
        var mtx:Matrix = new Matrix();
        mtx.createGradientBox(10, rowHeight, Math.PI / 2);
        
        selectionRect.graphics.clear();
        selectionRect.graphics.beginFill(0xCCCCCC);
        selectionRect.graphics.drawRoundRect(0, 0, width - scrollBar.width, rowHeight, 8);
        selectionRect.graphics.beginFill(0xEEEEEE);
        selectionRect.graphics.drawRoundRect(1, 1, width - scrollBar.width - 2, rowHeight - 2, 6);
        selectionRect.graphics.beginGradientFill(GradientType.LINEAR, [0xEEEEEE, 0xF8F8F8, 0xDDDDDD], [1, 1, 1], [0x00, 0x40, 0xFF], mtx);
        selectionRect.graphics.drawRoundRect(2, 2, width - scrollBar.width - 4, rowHeight - 4, 4);
        
        scrollBar.viewSize = renderers.length;
        updateData();
    }
    
    private function rendererClickHandler(event:Event):void {
        var renderer:ListItemRenderer = ListItemRenderer(event.currentTarget);
        if (renderer.data) {
            selectedItem = renderer.data;
            dispatchEvent(new Event(Event.CHANGE));
        }
    }
    
    protected override function updateSize():void {
        updateRenderers();
        for each (var renderer:ListItemRenderer in renderers) {
            renderer.width = width - scrollBar.width;
        }
        scrollBar.x = width - scrollBar.width;
        scrollBar.height = height;
        
        graphics.clear();
        graphics.beginFill(0xFFFFFF);
        graphics.drawRect(0, 0, width, height);
    }
    
    private function scrollBarChangeHandler(event:Event):void {
        scrollPosition = Math.round(scrollBar.value);
        updateData();
    }
}



/*
 jp/psyark/psycode/core/codehint/CodeHint.as
*/

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.filters.DropShadowFilter;
import flash.ui.Keyboard;
import flash.utils.ByteArray;

class CodeHint extends Sprite {
    private var _width:Number = 200;
    private var _height:Number = 280;
    
    private var background1:Sprite;
    private var background2:Sprite;
    private var list:List;
    private var target:TextEditUI;
    
    private const STAGE_KEY_LISTEN_PRIORITY:int = 100;
    
    private var activated:Boolean = false;
    
    private var catalog:Array;
    
    private const VAR_REGEX:RegExp = /\Wvar\s+([_a-zA-Z]\w*)\s*:\s*([_a-zA-Z]\w*)?$/;
    private const FUNCTION_REGEX:RegExp = /\Wfunction\s+([_a-zA-Z]\w*)?\s*\([^)]*\)\s*:\s*([_a-zA-Z]\w*)?$/;
    private const CLASS_REGEX:RegExp = /\Wclass\s+([_a-zA-Z]\w*)\s+extends\s+([_a-zA-Z]\w*)?$/;
    private var currentRegex:RegExp;
    
    public var selectedIdentifier:String;
    public var selectedName:String;
    public var captureLength:int;
    
    public function CodeHint(target:TextEditUI) {
        this.target = target;
        target.addEventListener(Event.SCROLL, function (event:Event):void {
            deactivate();
        });
        
        catalog = Catalog.catalog.slice();
        
        background1 = new Sprite();
        background2 = new Sprite();
        background2.filters = [new DropShadowFilter(1, 45, 0x000000, 1, 10, 10, 1.2, 2, false, true)];
        
        list = new List();
        list.labelField = "name";
        list.addEventListener(Event.CHANGE, function (event:Event):void {
            select(CatalogEntry(list.selectedItem));
            target.psycode_internal::resetFocus();
        });
        
        addChild(background1);
        addChild(background2);
        addChild(list);
        
        
        updateLayout();
        
        addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
        addEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler);
    }
    
    public function activate():Boolean {
        if (activated) {
            return false;
        }
        
        var prevText:String = target.text.substr(0, target.selectionBeginIndex);
        
        for each (var regex:RegExp in [VAR_REGEX, FUNCTION_REGEX, CLASS_REGEX]) {
            var match:Array = prevText.match(regex);
            if (match) {
                currentRegex = regex;
                show();
                updateContent(match[2], true);
                return activated;
            }
        }
        
        return false;
    }
    
    private function show():void {
        visible = true;
        activated = true;
        updateLayout();
    }
    
    private function select(entry:CatalogEntry):void {
        selectedName = entry.name;
        selectedIdentifier = entry.identifier;
        dispatchEvent(new Event(Event.SELECT));
        deactivate();
    }
    
    public function deactivate():void {
        visible = false;
        activated = false;
    }
    
    private function checkUpdate():void {
        var prevText:String = target.text.substr(0, target.selectionBeginIndex);
        var match:Array = prevText.match(currentRegex);
        if (match) {
            updateContent(match[2]);
        } else {
            deactivate();
        }
    }
    
    private function updateContent(filter:String="", selectOnlyItem:Boolean=false):void {
        filter ||= "";
        filter = filter.toUpperCase();
        captureLength = filter.length;
        list.dataProvider = catalog.filter(function (entry:CatalogEntry, index:int, source:Array):Boolean {
            return entry.name.toUpperCase().substr(0, filter.length) == filter;
        });
        list.selectedIndex = 0;
        if (list.dataProvider.length == 0) {
            deactivate();
        }
        if (selectOnlyItem && list.dataProvider.length == 1) {
            select(CatalogEntry(list.dataProvider[0]));
        }
    }
    
    private function updateLayout():void {
        var borderWidth:Number = 7;
        
        for each (var bg:Sprite in [background1, background2]) {
            bg.graphics.clear();
            bg.graphics.lineStyle(-1, 0x666666, 0.5);
            bg.graphics.beginFill(0xE8F8FF, 0.9);
            bg.graphics.drawRoundRect(0, 0, _width, _height, borderWidth * 2);
            bg.graphics.endFill();
            bg.graphics.drawRect(borderWidth - 1, borderWidth - 1, _width - borderWidth * 2 + 2, _height - borderWidth * 2 + 2);
        }
        
        list.x = borderWidth;
        list.y = borderWidth;
        list.width = _width - borderWidth * 2;
        list.height = _height - borderWidth * 2;
    }
    
    
    
    private function stageKeyDownHandler(event:KeyboardEvent):void {
        if (activated) {
            if (event.keyCode == Keyboard.ENTER) {
                stage.focus = null;
                select(CatalogEntry(list.selectedItem));
                callLater(target.psycode_internal::resetFocus);
                event.stopPropagation();
            } else if (event.keyCode == Keyboard.DOWN) {
                stage.focus = null;
                list.selectedIndex = Math.min(list.selectedIndex + 1, list.dataProvider.length - 1);
                callLater(target.psycode_internal::resetFocus);
                event.stopPropagation();
            } else if (event.keyCode == Keyboard.UP) {
                stage.focus = null;
                list.selectedIndex = Math.max(list.selectedIndex - 1, 0);
                callLater(target.psycode_internal::resetFocus);
                event.stopPropagation();
            } else {
                callLater(checkUpdate);
            }
        }
    }
    
    private function stageMouseDownHandler(event:MouseEvent):void {
        if (!contains(event.target as DisplayObject)) {
            deactivate();
        }
    }
    
    private function addedToStageHandler(event:Event):void {
        stage.addEventListener(KeyboardEvent.KEY_DOWN, stageKeyDownHandler, true, STAGE_KEY_LISTEN_PRIORITY);
        stage.addEventListener(MouseEvent.MOUSE_DOWN, stageMouseDownHandler, true, STAGE_KEY_LISTEN_PRIORITY);
    }
    
    private function removedFromStageHandler(event:Event):void {
        stage.removeEventListener(KeyboardEvent.KEY_DOWN, stageKeyDownHandler, true);
        stage.removeEventListener(MouseEvent.MOUSE_DOWN, stageMouseDownHandler, true);
    }
}



/*
 jp/psyark/utils/callLater.as
*/

function callLater(func:Function, args:Array=null, frame:int=1):void {
    Helper.callLater(func, args, frame);
}

import flash.display.MovieClip;
import flash.events.Event;

class Helper {
    private static var engine:MovieClip = new MovieClip();
    
    public static function callLater(func:Function, args:Array=null, frame:int=1):void {
        engine.addEventListener(Event.ENTER_FRAME, function(event:Event):void {
            if (--frame <= 0) {
                engine.removeEventListener(Event.ENTER_FRAME, arguments.callee);
                func.apply(null, args);
            }
        });
    }
}


/*
 jp/psyark/psycode/core/history/HistoryManager.as
*/

import __AS3__.vec.Vector;

class HistoryManager {
    private var currentIndex:int = 0;
    private var entries:Vector.<HistoryEntry>;
    
    public function HistoryManager() {
        entries = new Vector.<HistoryEntry>();
    }
    
    public function appendEntry(entry:HistoryEntry):void {
        entries.length = currentIndex;
        entries.push(entry);
        currentIndex = entries.length;
    }
    
    public function clear():void {
        currentIndex = 0;
        entries.length = 0;
    }
    
    public function get canForward():Boolean {
        return currentIndex < entries.length;
    }
    
    public function get canBack():Boolean {
        return currentIndex > 0;
    }
    
    public function forward():HistoryEntry {
        return entries[currentIndex++];
    }
    
    public function back():HistoryEntry {
        return entries[--currentIndex];
    }
}



/*
 jp/psyark/psycode/feedback/FeedbackManager.as
*/

import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.KeyboardEvent;
import flash.net.LocalConnection;
import flash.system.Security;
import flash.ui.Keyboard;

class FeedbackManager extends EventDispatcher {
    public static const instance:FeedbackManager = new FeedbackManager();
    private var _target:DisplayObject;
    private var recvConn:LocalConnection;
    private var sendConn:LocalConnection;
    
    public var targetX:Number;
    public var targetY:Number;
    
    public function FeedbackManager():void {
        sendConn = new LocalConnection();
        recvConn = new LocalConnection();
        Security.allowDomain("*");
        try {
            recvConn.connect("_feedbackManager");
            recvConn.allowDomain("*");
            recvConn.client = { change:changeHandler };
        } catch (e:*) {
        }
    }
    
    private function changeHandler(targetX:Number, targetY:Number):void {
        this.targetX = targetX;
        this.targetY = targetY;
        dispatchEvent(new Event(Event.CHANGE));
    }
    
    public function activate(target:DisplayObject):void {
        if (_target) {
            _target.removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
        }
        _target = target;
        if (_target) {
            _target.addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
        }
    }
    
    private function addedToStageHandler(event:Event):void {
        _target.stage.addEventListener(KeyboardEvent.KEY_DOWN, stageKeyDownHandler);
    }
    
    private function stageKeyDownHandler(event:KeyboardEvent):void {
        if (_target && _target.stage) {
            if (event.keyCode == Keyboard.RIGHT) {
                _target.x += event.shiftKey ? 10 : 1;
            } else if (event.keyCode == Keyboard.LEFT) {
                _target.x -= event.shiftKey ? 10 : 1;
            } else if (event.keyCode == Keyboard.DOWN) {
                _target.y += event.shiftKey ? 10 : 1;
            } else if (event.keyCode == Keyboard.UP) {
                _target.y -= event.shiftKey ? 10 : 1;
            } else {
                return;
            }
            sendConn.send("_feedbackManager", "change", _target.x, _target.y);
        }
    }
}



/*
 jp/psyark/psycode/core/coloring/SyntaxHighlighter.as
*/

import flash.text.TextFormat;

/**
 * シンタックスハイライトを行うクラスの基底クラスです。
 */
class SyntaxHighlighter {
    private var target:TextEditor;
    
    private var defaultFormat:TextFormat;
    private var numberFormat:TextFormat;
    private var stringFormat:TextFormat;
    private var asdocFormat:TextFormat;
    private var commentFormat:TextFormat;
    private var metadataFormat:TextFormat;
    private var regexFormat:TextFormat;
    
    private var formats:Object;
    
    public function SyntaxHighlighter(target:TextEditor) {
        this.target = target;
        
        defaultFormat = new TextFormat(null, null, 0x000000, false, false);
        numberFormat = new TextFormat(null, null, 0xCC6600, false);
        stringFormat = new TextFormat(null, null, 0x990000, true);
        asdocFormat = new TextFormat(null, null, 0x3f5fbf, false);
        commentFormat = new TextFormat(null, null, 0x009900, false);
        metadataFormat = new TextFormat(null, null, 0x0033ff, true);
        regexFormat = new TextFormat(null, null, 0x990000, true);
        
        var reservedFormat:TextFormat = new TextFormat(null, null, 0x0033ff, true);
        
        formats = {};
        var reserved:String =
            "as,break,case,catch,class,const,continue,default,delete,do,else,extends,false,finally," +
            "for,function,if,implements,import,in,instanceof,interface,internal,is,native,new,null," +
            "package,private,protected,public,return,super,switch,this,throw,to,true,try,typeof,use," +
            "var,void,while,with,each,get,set,namespace,include,dynamic,final,native,override,static," +
            "abstract,boolean,byte,cast,char,debugger,double,enum,export,float,goto,intrinsic,long," +
            "prototype,short,synchronized,throws,to,transient,type,virtual,volatile";
        for each (var r:String in reserved.split(",")) {
            formats[" " + r] = reservedFormat;
        }
        
        var classFormat:TextFormat = new TextFormat(null, null, 0x9900cc, true);
        
        formats[" var"]       = new TextFormat(null, null, 0x6699cc, true);
        formats[" package"]   = classFormat;
        formats[" class"]     = classFormat;
        formats[" interface"] = classFormat;
        formats[" trace"]     = new TextFormat(null, null, 0xcc6666, true);
        formats[" function"]  = new TextFormat(null, null, 0x339966, true);
    }
        
    /**
     * シンタックスハイライトを再描画
     */
    public function update(start:int, end:int):void {
        var text:String = getText();
        for (; start>0 && !isBreak(text.charAt(start - 1)); start--);
        for (; end<text.length && !isBreak(text.charAt(end)); end++);
        
        var index:int;
        if (start != end) {
            setFormat(start, end, defaultFormat);
            index = start;
            text.substring(start, end).replace(/([_A-Z]\w*)|(0x[A-F\d]+|\d+(?:\.\d+)?)|(.)/sgi,
                function (match:String, word:String, number:String, other:String, inaccurIdx:int, str:String):String {
                    if (!other) {
                        var s:int = Math.max(start, index);
                        var e:int = Math.min(end, index + match.length);
                        if (s < e) {
                            if (word) {
                                if (formats[" " + word] !== undefined) {
                                    setFormat(index, index + match.length, formats[" " + word]);
                                }
                            } else if (number) {
                                setFormat(index, index + match.length, numberFormat);
                            }
                        }
                    }
                    index += match.length;
                    return match;
                }
            );
            index = 0;
            text.replace(/(\/\*.*?\*\/|\/\/[^\r\n]*)|("[^"]*?(?:\\"[^"]*?)*"|'[^']*?(?:\\'[^']*?)*')|(\/[^\/\r\n]*?(?:\\\/[^\/\r\n]*?)*\/)|(.)/sg,
                function (match:String, comment:String, string:String, regex:String, other:String, inaccurIdx:int, str:String):String {
                    if (!other) {
                        var s:int = Math.max(start, index);
                        var e:int = Math.min(end, index + match.length);
                        if (s < e) {
                            if (comment) {
                                setFormat(index, index + match.length, comment.substr(0, 3) == "/**" ? asdocFormat : commentFormat);
                            } else if (string) {
                                setFormat(index, index + match.length, stringFormat);
                            } else if (regex) {
                                setFormat(index, index + match.length, regexFormat);
                            }
                        }
                    }
                    index += match.length;
                    return match;
                }
            );
        }
    }
    
    /**
     * 対象からテキストを取得
     */
    protected function getText():String {
        return target.text;
    }
    
    /**
     * 範囲にフォーマットを設定
     */
    protected function setFormat(start:int, end:int, format:TextFormat):void {
        try {
            target.psycode_internal::setTextFormat(format, start, end);
        } catch (e:RangeError) {
        }
    }
    
    /**
     * 文字が改行かどうかを判断
     */
    protected function isBreak(char:String):Boolean {
        return char == "\r" || char == "\n";
    }
}



/*
 jp/psyark/psycode/core/TextEditorBase.as
*/

import flash.events.Event;
import flash.events.TextEvent;
import flash.geom.Rectangle;


/**
 * @private
 * TextEditorBaseクラスはTextEditUIクラスを継承し、
 * キーイベントのキャンセルなどテキストエディタの実装に必要な機能を提供します。
 */
class TextEditorBase extends TextEditUI {
    private var codeHint:CodeHint;
    
    protected var preventFollowingTextInput:Boolean = false;
    protected var prevText:String = "";
    protected var prevSBI:int;
    protected var prevSEI:int;
    
    protected var ignoreChange:Boolean = false;
    protected var comparator:StringComparator;
    protected var historyManager:HistoryManager;
    protected var syntaxHighlighter:SyntaxHighlighter;
    
    /**
     * TextEditorBaseクラスのインスタンスを作成します。
     */
    public function TextEditorBase() {
        codeHint = new CodeHint(this);
        codeHint.visible = false;
        codeHint.addEventListener(Event.SELECT, codeHintSelectHandler);
        addChild(codeHint);
        
        addEventListener(Event.CHANGE, changeHandler);
        addEventListener(TextEvent.TEXT_INPUT, textInputHandler);
    }
    
    
    /**
     * 次のテキスト入力をキャンセルするように、現在の状態を保存します。
     */
    psycode_internal function preventNextTextInput():void {
        
    }
    
    
    /**
     * テキストが変更された
     */
    private function changeHandler(event:Event):void {
        //trace("change", "changed=" + (prevText != text), "ignore=" + ignoreChange, "prevent=" + preventFollowingTextInput);
        //trace("{" + escapeText(prevText) + "} => {" + escapeText(text) + "}");
        if (prevText != text) {
            if (preventFollowingTextInput) {
                comparator.compare(prevText, text);
                replaceText(
                    comparator.commonPrefixLength,
                    text.length - comparator.commonSuffixLength,
                    prevText.substring(comparator.commonPrefixLength, prevText.length - comparator.commonSuffixLength)
                );
                setSelection(prevSBI, prevSEI);
                preventFollowingTextInput = false;
            } else {
                comparator.compare(prevText, text);
                if (!ignoreChange) {
                    var entry:HistoryEntry = new HistoryEntry(comparator.commonPrefixLength);
                    entry.oldText = prevText.substring(comparator.commonPrefixLength, prevText.length - comparator.commonSuffixLength);
                    entry.newText = text.substring(comparator.commonPrefixLength, text.length - comparator.commonSuffixLength);
                    historyManager.appendEntry(entry);
                }
                callLater(syntaxHighlighter.update, [comparator.commonPrefixLength, text.length - comparator.commonSuffixLength]);
                prevText = text;
            }
        }
    }
    
    
    /**
     * テキストが入力された
     */
    private function textInputHandler(event:TextEvent):void {
        if (preventFollowingTextInput) {
            event.preventDefault();
        }
    }
    
    
    /**
     * 履歴追加の際、自分が無視できる変更イベントを送信
     */
    protected function dispatchIgnorableChangeEvent():void {
        ignoreChange = true;
        dispatchChangeEvent();
        ignoreChange = false; 
    }
    
    
    /**
     * コードヒントを起動します
     * 現在のカーソル前のテキストから続くコードを類推し、
     * 候補が無ければそのまま終了、
     * 候補がひとつなら直ちに補完を行い、
     * 候補が複数なら選択パネルを表示します。
     */
    public function activateCodeHint(a:Boolean=false):void {
        var rect:Rectangle = getCharBoundaries(textField.caretIndex);
        if (rect) {
            var scrollIndex:int = textField.getLineOffset(textField.scrollV - 1) + textField.scrollH;
            var rect2:Rectangle = getCharBoundaries(scrollIndex);
            if (rect2) {
                rect.x -= rect2.x;
                rect.y -= rect2.y;
            }
            codeHint.x = rect.x + textField.x;
            codeHint.y = rect.bottom + 2;
        }
        codeHint.activate();
        
        function getCharBoundaries(index:int):Rectangle {
            var char:String = text.charAt(index);
            replaceText(index, index + 1, "M");
            var bound:Rectangle = textField.getCharBoundaries(index);
            replaceText(index, index + 1, char);
            return bound;
        }
    }
    
    /**
     * コードヒントが選択された
     */
    private function codeHintSelectHandler(event:Event):void {
        preventFollowingTextInput = false;
        var newIndex:int = textField.caretIndex - codeHint.captureLength + codeHint.selectedName.length;
        replaceText(textField.caretIndex - codeHint.captureLength, textField.caretIndex, codeHint.selectedName);
        setSelection(newIndex, newIndex);
        dispatchChangeEvent();
        
        var identifier:String = codeHint.selectedIdentifier;
        if (identifier.indexOf(":") != -1) {
            autoImport(identifier.replace(/:/, "."));
        }
    }
    
    /**
     * インポート文の自動追加
     */
    private function autoImport(qname:String):void {
        var regex:String = "";
        regex += "(package\\s*(?:[_a-zA-Z]\\w*(?:\\.[_a-zA-Z]\\w*)*)?\\s*{)"; // package
        regex += "(\\s*(?:import\\s*(?:[_a-zA-Z]\\w*(?:\\.[_a-zA-Z]\\w*)*(?:\\.\\*)?[\\s;]+))*$)"; // import 
        regex += "(.*?public\\s+(?:class|interface|function|namespace))"; // def
        var match:Array = text.match(new RegExp(regex, "sm"));
        if (match) {
            var importTable:Object = {};
            match[2].replace(/import\s*([_a-zA-Z]\w*(?:\.[_a-zA-Z]\w*)*(?:\.\*)?)/g, function (match:String, cap1:String, index:int, source:String):void {
                importTable[cap1] = true;
            });
            importTable[qname] = true;
            var importList:Array = [];
            for (var i:String in importTable) {
                importList.push("\timport " + i + ";");
            }
            var importStr:String = importList.sort().join("\n");
            var newStr:String = "\n" + importStr + "\n" + match[3];
            var index:int = selectionBeginIndex;
            replaceText(
                match.index + match[1].length,
                match.index + match[1].length + match[2].length + match[3].length,
                newStr
            );
            
            if (index > match.index + match[1].length) {
                var newSel:int = index + newStr.length - match[2].length - match[3].length;
                setSelection(newSel, newSel);
            }
            dispatchChangeEvent();
        }
    }
}



/*
 jp/psyark/psycode/controls/ScrollBarHandle.as
*/

import flash.display.GradientType;
import flash.display.Graphics;
import flash.display.Shape;
import flash.display.SimpleButton;
import flash.geom.ColorTransform;
import flash.geom.Matrix;


class ScrollBarHandle extends SimpleButton {
    protected static var handleColors:Array = [0xF7F7F7, 0xECECEC, 0xD8D8D8, 0xCCCCCC, 0xEDEDED];
    protected static var handleAlphas:Array = [1, 1, 1, 1, 1];
    protected static var handleRatios:Array = [0x00, 0x66, 0x80, 0xDD, 0xFF];
    protected static var iconColors:Array = [0x000000, 0xFFFFFF];
    protected static var iconAlphas:Array = [1, 1];
    protected static var iconRatios:Array = [0x00, 0xFF];
    
    private var direction:String;
    private var upFace:Shape;
    private var overFace:Shape;
    
    public function ScrollBarHandle(direction:String="vertical") {
        this.direction = direction;
        cacheAsBitmap = true;
        useHandCursor = false;
        
        upFace = new Shape();
        overFace = new Shape();
        overFace.transform.colorTransform = new ColorTransform(0.95, 1.3, 1.5, 1, 0x00, -0x33, -0x44);
        
        upState = upFace;
        overState = overFace;
        downState = overFace;
        hitTestState = upFace;
    }
    
    public function setSize(w:Number, h:Number):void {
        drawFace(upFace.graphics, w, h);
        drawFace(overFace.graphics, w, h);
    }
    
    protected function drawFace(graphics:Graphics, w:Number, h:Number):void {
        var mtx:Matrix = new Matrix();
        mtx.createGradientBox(w, h, direction == ScrollBar.VERTICAL ? 0 : Math.PI / 2);
        
        graphics.clear();
        graphics.beginFill(0x999999);
        graphics.drawRoundRect(0, 0, w, h, 2);
        graphics.beginGradientFill(GradientType.LINEAR, handleColors, handleAlphas, handleRatios, mtx);
        graphics.drawRect(1, 1, w - 2, h - 2);
        
        graphics.lineStyle(-1, 0xEEEEEE);
        graphics.beginGradientFill(GradientType.LINEAR, iconColors, iconAlphas, iconRatios, mtx);
        for (var i:int=-1; i<2; i++) {
            if (direction == ScrollBar.VERTICAL) {
                graphics.drawRoundRect((w - 8) / 2, (h - 3) / 2 + i * 3, 8, 3, 2);
            } else {
                graphics.drawRoundRect((w - 3) / 2 + i * 3, (h - 8) / 2, 3, 8, 2);
            }
        }
    }
}



/*
 jp/psyark/psycode/controls/ListItemRenderer.as
*/

import flash.events.MouseEvent;
import flash.text.TextField;
import flash.text.TextFormat;

class ListItemRenderer extends UIControl {
    private var _data:Object;
    private var _labelField:String;
    private var label:TextField;
    
    public function ListItemRenderer() {
        label = new TextField();
        label.selectable = false;
        label.defaultTextFormat = new TextFormat("_typewriter", 13, 0x000000);
        label.backgroundColor = 0xE8F8FF;
        addChild(label);
        updateView();
        
        addEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
        addEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
    }
    
    public function get data():Object {
        return _data;
    }
    
    public function set data(value:Object):void {
        if (_data != value) {
            _data = value;
            updateView();
        }
    }
    
    /**
     * ラベルとして使うプロパティ名を取得または設定します。
     */
    public function get labelField():String {
        return _labelField;
    }
    
    /**
     * @private
     */
    public function set labelField(value:String):void {
        if (_labelField != value) {
            _labelField = value;
            updateView();
        }
    }
    
    protected function updateView():void {
        if (data) {
            try {
                label.text = data[labelField];
            } catch (e:*) {
                label.text = "";
            }
            label.visible = true;
        } else {
            label.visible = false;
        }
    }
    
    protected override function updateSize():void {
        label.width = width;
        label.height = height;
    }
    
    protected function rollOverHandler(event:MouseEvent):void {
        label.background = true;
    }
    
    protected function rollOutHandler(event:MouseEvent):void {
        label.background = false;
    }
}



/*
 jp/psyark/psycode/live/PsycodeLiveClient.as
*/

import flash.display.Loader;
import flash.events.Event;
import flash.events.StatusEvent;
import flash.net.LocalConnection;
import flash.net.URLRequest;

class PsycodeLiveClient extends Loader {
    private var serverConnName:String;
    private var projectName:String;
    private var sendConn:LocalConnection;
    private var recvConn:LocalConnection;
    private var recvConnName:String;
    
    private var queue:Array;
    private var running:Boolean = false;
    
    public var currentURL:String;
    
    public function PsycodeLiveClient(serverConnName:String="_PsycodeLive", projectName:String="default") {
        this.serverConnName = serverConnName;
        this.projectName = projectName;
        
        sendConn = new LocalConnection();
        recvConn = new LocalConnection();
        recvConnName = connectAnyName(recvConn);
        
        recvConn.client = {
            saveComplete:saveComplete,
            saveError:saveError,
            compileComplete:compileComplete,
            compileError:compileError
        };
        sendConn.addEventListener(StatusEvent.STATUS, function (event:StatusEvent):void {
            trace(event);
        });
        
        queue = [];
    }
    
    public function save(filePath:String, code:String):void {
        queue.push([ serverConnName, "save", projectName, filePath, code, recvConnName ]);
        run();
    }
    
    public function saveComplete(param:Object):void {
        running = false;
        run();
    }
    
    public function saveError(message:String, param:Object):void {
        running = false;
        queue = [];
    }
    
    public function compile(filePath:String):void {
        queue.push([ serverConnName, "compile", projectName, filePath, recvConnName ]);
        run();
    }
    
    public function compileComplete(url:String, param:Object):void {
        running = false;
        currentURL = url;
        dispatchEvent(new Event(Event.COMPLETE));
        load(new URLRequest(url));
        run();
    }
    
    public function compileError(message:String, param:Object):void {
        running = false;
        queue = [];
    }
    
    
    
    
    private function run():void {
        if (running == false && queue.length) {
            running = true;
            sendConn.send.apply(null, queue.shift());
        }
    }
    
    
    private function connectAnyName(connection:LocalConnection):String {
        for (var i:int=0; i<1000; i++) {
            try {
                var name:String = "conn_" + i;
                connection.connect(name);
                return name;
            } catch (error:ArgumentError) {
            }
        }
        return "";
    }
}



/*
 jp/psyark/psycode/controls/TabView.as
*/

import flash.display.DisplayObject;
import flash.display.GradientType;
import flash.display.Shape;
import flash.display.SimpleButton;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Matrix;
import flash.utils.Dictionary;

class TabView extends UIControl {
    private var contentItemTable:Dictionary;
    private var items:Array;
    private var addButton:SimpleButton;
    
    private var _currentItem:TabViewItem;
    private function get currentItem():TabViewItem {
        return _currentItem;
    }
    private function set currentItem(value:TabViewItem):void {
        if (_currentItem != value) {
            if (_currentItem) {
                removeChild(_currentItem.content);
            }
            _currentItem = value;
            if (_currentItem) {
                addChild(_currentItem.content);
                updateView();
            }
        }
    }
    
    public function get selectedIndex():int {
        return items.indexOf(currentItem);
    }
    
    public function TabView() {
        contentItemTable = new Dictionary();
        items = new Array();
        addButton = createAddButton();
        addButton.addEventListener(MouseEvent.CLICK, addButtonClickHandler);
        addChild(addButton);
    }
    
    private function createAddButton():SimpleButton {
        var u:Shape = new Shape();
        var o:Shape = new Shape();
        
        o.graphics.beginFill(0x666666);
        o.graphics.drawRoundRect(0, 0, 18, 18, 8);
        o.graphics.beginFill(0xFFFFFF);
        o.graphics.drawRoundRect(1, 1, 16, 16, 6);
        for each (var shape:Shape in [u, o]) {
            shape.graphics.beginFill(0x666666);
            shape.graphics.drawRect(7, 4, 4, 10);
            shape.graphics.beginFill(0x666666);
            shape.graphics.drawRect(4, 7, 10, 4);
            shape.graphics.beginFill(0xFFFFFF);
            shape.graphics.drawRect(8, 5, 2, 8);
            shape.graphics.beginFill(0xFFFFFF);
            shape.graphics.drawRect(5, 8, 8, 2);
        }
        
        var btn:SimpleButton = new SimpleButton();
        btn.upState = u;
        btn.overState = o;
        btn.downState = o;
        btn.hitTestState = o;
        return btn;
    }
    
    public function addItem(content:DisplayObject, title:String):void {
        var item:TabViewItem = new TabViewItem(content, title);
        item.addEventListener(Event.CLOSE, itemCloseHandler);
        item.addEventListener(MouseEvent.CLICK, itemClickHandler);
        items.push(item);
        addChild(item);
        contentItemTable[content] = item;
        currentItem = item;
        updateView();
    }
    
    public function setTitle(content:DisplayObject, title:String):void {
        TabViewItem(contentItemTable[content]).title = title;
        updateView();
    }
    
    public function removeItem(content:DisplayObject):void {
        var item:TabViewItem = contentItemTable[content];
        items.splice(items.indexOf(item), 1);
        removeChild(item);
        delete contentItemTable[content];
        if (currentItem == item) {
            currentItem = items[0];
        }
        updateView();
    }
    
    public function get count():int {
        return items.length;
    }
    
    public function getItemAt(index:int):DisplayObject {
        return TabViewItem(items[index]).content;
    }
    
    private function itemClickHandler(event:MouseEvent):void {
        currentItem = TabViewItem(event.currentTarget);
    }
    
    private function itemCloseHandler(event:Event):void {
        removeItem(TabViewItem(event.currentTarget).content);
    }
    
    private function addButtonClickHandler(event:MouseEvent):void {
        dispatchEvent(new Event(Event.OPEN));
    }
    
    private function updateView():void {
        graphics.clear();
        graphics.beginFill(0x999999);
        graphics.drawRoundRect(0, 0, width, height, 8);
        graphics.beginFill(0xEEEEEE);
        graphics.drawRoundRect(1, 1, width - 2, height - 2, 6);
        graphics.beginFill(0x999999);
        graphics.drawRect(0, 22, width, height - 22);
        graphics.beginFill(0xC1CFDD);
        graphics.drawRect(1, 23, width - 2, height - 24);
        graphics.beginFill(0xFFFFFF);
        graphics.drawRect(4, 26, width - 8, height - 30);
        
        var left:Number = 1;
        for each (var item:TabViewItem in items) {
            item.x = left;
            item.y = 1;
            left += item.width;
        }
        addButton.x = left + 3;
        addButton.y = 2;
        
        if (currentItem) {
            var mtx:Matrix = new Matrix();
            mtx.createGradientBox(10, 20, Math.PI / 2);
            graphics.beginGradientFill(GradientType.LINEAR, [0xD3DFEE, 0xC1CFDD], [1, 1], [0x00, 0xFF], mtx);
            graphics.drawRect(currentItem.x, currentItem.y, currentItem.width, currentItem.height);
            
            currentItem.content.x = 4;
            currentItem.content.y = 26;
            if (currentItem.content is UIControl) {
                UIControl(currentItem.content).setSize(width - 8, height - 30);
            }
        }
    }
    
    protected override function updateSize():void {
        super.updateSize();
        updateView();
    }
}

import flash.display.Sprite;
import flash.display.DisplayObject;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.display.Shape;
import flash.display.SimpleButton;
import flash.events.MouseEvent;
import flash.events.Event;    

class TabViewItem extends Sprite {
    private var label:TextField;
    private var closeButton:SimpleButton;
    public var content:DisplayObject;
    
    public function get title():String {
        return label.text;
    }
    public function set title(value:String):void {
        label.text = value;
        updateView();
    }
    
    public function TabViewItem(content:DisplayObject, title:String):void {
        var fmt:TextFormat = new TextFormat("_sans");
        fmt.leftMargin = 4;
        fmt.rightMargin = 4;
        
        label = new TextField();
        label.selectable = false;
        label.defaultTextFormat = fmt;
        addChild(label);
        
        closeButton = createCloseButton();
        closeButton.addEventListener(MouseEvent.CLICK, closeButtonClickHandler);
        addChild(closeButton);
        
        this.title = title;
        this.content = content;
    }
    
    private function updateView():void {
        label.width = Math.max(60, Math.min(140, label.textWidth + 30));
        label.height = label.textHeight + 4;
        label.y = (20 - label.height) / 2;
        graphics.clear();
        graphics.lineStyle(-1, 0x999999);
        graphics.moveTo(label.width, 0);
        graphics.lineTo(label.width, 22);
        
        closeButton.rotation = 45;
        closeButton.x = label.width - 11;
        closeButton.y = 11;
    }
        
    private function createCloseButton():SimpleButton {
        var u:Shape = new Shape();
        var o:Shape = new Shape();
        
        o.graphics.beginFill(0x666666);
        o.graphics.drawCircle(0, 0, 10);
        for each (var shape:Shape in [u, o]) {
            shape.graphics.beginFill(0x666666);
            shape.graphics.drawRect(-2, -6, 4, 12);
            shape.graphics.beginFill(0x666666);
            shape.graphics.drawRect(-6, -2, 12, 4);
            shape.graphics.beginFill(0xFFFFFF);
            shape.graphics.drawRect(-1, -5, 2, 10);
            shape.graphics.beginFill(0xFFFFFF);
            shape.graphics.drawRect(-5, -1, 10, 2);
        }
        
        var btn:SimpleButton = new SimpleButton();
        btn.upState = u;
        btn.overState = u;
        btn.downState = u;
        btn.hitTestState = o;
        return btn;
    }
    
    private function closeButtonClickHandler(event:MouseEvent):void {
        dispatchEvent(new Event(Event.CLOSE));
        event.stopPropagation();
    }
}


/*
 jp/psyark/psycode/TextEditor.as
*/

import flash.events.ContextMenuEvent;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.net.FileReference;
import flash.ui.ContextMenu;
import flash.ui.ContextMenuItem;
import flash.ui.Keyboard;
import flash.utils.clearTimeout;
import flash.utils.setTimeout;

/**
 * TextEditorクラス
 */
class TextEditor extends TextEditorBase {
    private var highlightAllTimer:int;
    
    /**
     * コンストラクタ
     */
    public function TextEditor() {
        comparator = new StringComparator();
        historyManager = new HistoryManager();
        syntaxHighlighter = new SyntaxHighlighter(this);
        
        contextMenu = createDebugMenu();
        
        addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
        addEventListener(Event.CHANGE, function (event:Event):void {
            clearTimeout(highlightAllTimer);
            highlightAllTimer = setTimeout(highlightAll, 1000);
        });
    }
    
    private function highlightAll():void {
        syntaxHighlighter.update(0, text.length);
    }
    
    
    private function createDebugMenu():ContextMenu {
        var menu:ContextMenu = new ContextMenu();
        menu.hideBuiltInItems();
        createMenuItem("ファイルを開く(&O)...", open);
        createMenuItem("ファイルを保存(&S)...", save);
        createMenuItem("元に戻す(&Z)", undo, function ():Boolean { return historyManager.canBack; }, true);
        createMenuItem("やり直し(&Y)", redo, function ():Boolean { return historyManager.canForward; });
        createMenuItem("文字サイズ : &64", function ():void { setFontSize(64); }, null, true);
        createMenuItem("文字サイズ : &48", function ():void { setFontSize(48); });
        createMenuItem("文字サイズ : &32", function ():void { setFontSize(32); });
        createMenuItem("文字サイズ : &24", function ():void { setFontSize(24); });
        createMenuItem("文字サイズ : &13", function ():void { setFontSize(13); });
        return menu;
        
        function createMenuItem(caption:String, func:Function, enabler:Function=null, separator:Boolean=false):void {
            var item:ContextMenuItem = new ContextMenuItem(caption, separator);
            item.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, function (event:ContextMenuEvent):void {
                func();
            });
            if (enabler != null) {
                menu.addEventListener(ContextMenuEvent.MENU_SELECT, function (event:ContextMenuEvent):void {
                    item.enabled = enabler();
                });
            }
            menu.customItems.push(item);
        }
    }
    
    
    /**
     * 履歴を消去
     */
    public function clearHistory():void {
        historyManager.clear();
        prevText = text;
    }
    
    
    /**
     * キー押下イベントハンドラ
     */
    private function keyDownHandler(event:KeyboardEvent):void {
        preventFollowingTextInput = false;
        
        // Ctrl+O : ファイルを開く
        if (event.charCode == "o".charCodeAt(0) && event.ctrlKey) {
            open();
            event.preventDefault();
            preventFollowingTextInput = true;
            prevSBI = selectionBeginIndex;
            prevSEI = selectionEndIndex;
            return;
        }
        
        // Ctrl+S : ファイルを保存
        if (event.charCode == "s".charCodeAt(0) && event.ctrlKey) {
            save();
            event.preventDefault();
            preventFollowingTextInput = true;
            prevSBI = selectionBeginIndex;
            prevSEI = selectionEndIndex;
            return;
        }
        
        // Ctrl+Space : コードヒントを表示
        if (event.keyCode == Keyboard.SPACE && event.ctrlKey) {
            activateCodeHint();
            event.preventDefault();
            preventFollowingTextInput = true;
            prevSBI = selectionBeginIndex;
            prevSEI = selectionEndIndex;
            return;
        }
        
        // Ctrl+Backspace : 文字グループを前方消去
        if (event.keyCode == Keyboard.BACKSPACE && event.ctrlKey) {
            deleteGroupBack();
            event.preventDefault();
            preventFollowingTextInput = true;
            prevSBI = selectionBeginIndex;
            prevSEI = selectionEndIndex;
            return;
        }
        
        // Tab : タブ挿入とインデント
        if (event.keyCode == Keyboard.TAB) {
            doTab(event);
            return;
        }
        
        // Enter : 自動インデント
        if (event.keyCode == Keyboard.ENTER) {
            doEnter(event);
            return;
        }
        
        // } : 自動アンインデント
        if (event.charCode == 125) {
            doRightbrace(event);
            return;
        }
        
        // Ctrl+Z : UNDO
        if (event.keyCode == 90 && event.ctrlKey) {
            undo();
            event.preventDefault();
            preventFollowingTextInput = true;
            prevSBI = selectionBeginIndex;
            prevSEI = selectionEndIndex;
            return;
        }
        
        // Ctrl+Y : REDO
        if (event.keyCode == 89 && event.ctrlKey) {
            redo();
            event.preventDefault();
            preventFollowingTextInput = true;
            prevSBI = selectionBeginIndex;
            prevSEI = selectionEndIndex;
            return;
        }
        
        // コードヒント起動
        if (event.charCode == 58 || event.charCode == 32) {
            callLater(activateCodeHint, [true]);
        }
    }
    
    
    /**
     * 同じ文字グループを前方消去
     */
    private function deleteGroupBack():void {
        if (selectionBeginIndex != selectionEndIndex) {
            // 範囲選択中なら、範囲を削除
            replaceSelectedText("");
            dispatchChangeEvent();
        } else if (selectionBeginIndex == 0) {
            // カーソル位置が先頭なら、何もしない
        } else {
            var len:int;
            var c:String = text.charAt(selectionBeginIndex - 1);
            if (c == "\r" || c == "\n") {
                // 改行の直後なら、それを消去
                len = 1;
            } else {
                // それ以外なら、同じ文字グループ（単語構成文字・空白・それ以外）を前方消去
                var match:Array = beforeSelection.match(/(?:\w+|[ \t]+|[^\w \t\r\n]+)$/i);
                len = match[0].length;
            }
            var newIndex:int = selectionBeginIndex - len;
            replaceText(selectionBeginIndex - len, selectionEndIndex, "");
            setSelection(newIndex, newIndex);
            dispatchChangeEvent();
        }
    }
    
    
    
    
    /**
     * Tab : タブ挿入とインデント
     */
    private function doTab(event:KeyboardEvent):void {
        if (selectionBeginIndex != selectionEndIndex) {
            var b:int, e:int, c:String;
            for (b=selectionBeginIndex; b>0; b--) {
                c = text.charAt(b - 1);
                if (c == "\r" || c == "\n") {
                    break;
                }
            }
            for (e=selectionEndIndex; e<text.length; e++) {
                c = text.charAt(e);
                if (c == "\r" || c == "\n") {
                    break;
                }
            }
            var replacement:String = text.substring(b, e);
            if (event.shiftKey) {
                replacement = replacement.replace(/^\t/mg, "");
            } else {
                replacement = replacement.replace(/^(.?)/mg, "\t$1");
            }
            replaceText(b, e, replacement);
            setSelection(b, b + replacement.length);
            dispatchChangeEvent();
            event.preventDefault();
            preventFollowingTextInput = true;
        } else {
            // 選択してなければタブ挿入
            replaceSelectedText("\t");
            setSelection(selectionEndIndex, selectionEndIndex);
            dispatchChangeEvent();
            event.preventDefault();
            preventFollowingTextInput = true;
        }
    }
    
    /**
     * Enter : 自動インデント
     */
    private function doEnter(event:KeyboardEvent):void {
        var before:String = beforeSelection;
        var match:Array = before.match(/(?:^|\n|\r)([ \t]*).*$/);
        var ins:String = "\n" + match[1];
        if (before.charAt(before.length - 1) == "{") {
            ins += "\t";
        }
        replaceSelectedText(ins);
        setSelection(selectionEndIndex, selectionEndIndex);
        dispatchChangeEvent();
        event.preventDefault();
        preventFollowingTextInput = true;
    }
    
    /**
     * } : 自動アンインデント
     */
    private function doRightbrace(event:KeyboardEvent):void {
        var match:Array = beforeSelection.match(/[\r\n]([ \t]*)$/);
        if (match) {
            var preCursorWhite:String = match[1];
            var nest:int = 1;
            for (var i:int=selectionBeginIndex-1; i>=0; i--) {
                var c:String = text.charAt(i);
                if (c == "{") {
                    nest--;
                    if (nest == 0) {
                        match = text.substr(0, i).match(/(?:^|[\r\n])([ \t]*)[^\r\n]*$/);
                        var replaceWhite:String = match ? match[1] : "";
                        replaceText(
                            selectionBeginIndex - preCursorWhite.length,
                            selectionEndIndex,
                            replaceWhite + "}"
                        );
                        dispatchChangeEvent();
                        event.preventDefault();
                        preventFollowingTextInput = true;
                        break;
                    }
                } else if (c == "}") {
                    nest++;
                }
            }
        }
    }
    
    /**
     * 元に戻す
     */
    public function undo():void {
        if (historyManager.canBack) {
            var entry:HistoryEntry = historyManager.back();
            replaceText(entry.index, entry.index + entry.newText.length, entry.oldText);
            setSelection(entry.index + entry.oldText.length, entry.index + entry.oldText.length);
            dispatchIgnorableChangeEvent();
        }
    }
    
    /**
     * やり直し
     */
    public function redo():void {
        if (historyManager.canForward) {
            var entry:HistoryEntry = historyManager.forward();
            replaceText(entry.index, entry.index + entry.oldText.length, entry.newText);
            setSelection(entry.index + entry.newText.length, entry.index + entry.newText.length);
            dispatchIgnorableChangeEvent();
        }
    }
    
    /**
     * 選択範囲の前の文字列
     */
    private function get beforeSelection():String {
        return text.substr(0, selectionBeginIndex);
    }
}



/*
 jp/psyark/psycode/AdvancedTextEditor.as
*/

import flash.events.Event;

class AdvancedTextEditor extends TextEditor {
    public function AdvancedTextEditor() {
        FeedbackManager.instance.addEventListener(Event.CHANGE, feedbackHandler);
    }
    
    private function feedbackHandler(event:Event):void {
        var t:String = text;
        var match:Array = t.match(/FeedbackManager\.instance\.activate\((.+)\)/);
        if (match) {
            var targetName:String = match[1];
            match = t.match(new RegExp("(" + targetName + "\\.x\\s*=\\s*)\\d+"));
            if (match) {
                replaceText(match.index + match[1].length, match.index + match[0].length, FeedbackManager.instance.targetX + "");
            }
            match = t.match(new RegExp("(" + targetName + "\\.y\\s*=\\s*)\\d+"));
            if (match) {
                replaceText(match.index + match[1].length, match.index + match[0].length, FeedbackManager.instance.targetY + "");
            }
            dispatchChangeEvent();
        }
    }
}

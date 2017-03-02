/**
 * Embedded PixelBender Generator.
 * pbjファイル(Pixel Bender Byte Code files)をコード内に埋め込むためのASクラスを生成するツールです.
 * パラメータがある場合はgetter/setterも適宜自動生成します.
 * 
 * getter/setterを生成するためにpbjのディスアセンブラを作った後に,
 * ShaderDataから必要な情報を取り出せることに気づき泣きました.
 * pbjのディスアセンブラはまた機会があれば晒します.
 * 
 * 2010.08.04 パラメータの最大・最小・デフォルト値のgetterを追加
 * 2010.08.04 getter/setterの命名規則を変更
 * 2010.07.20 inputが複数ある場合にはMainCodeにinputの設定コードを表示するように設定
 * 2010.07.13 Shaderのコンストラクタに初期化オブジェクトを渡せるように修正
 * 2010.07.13 ShaderJobでの使用, 複数入力イメージ対応のためにInputのgetter/setterを追加
 * 2010.07.12 パラメータのgetter/setter部分にデフォルト値が反映されていなかったのを修正
 * 
 * @author Yukiya Okuda<alumican.net>
 */
package
{
    import com.bit101.components.Label;
    import com.bit101.components.PushButton;
    import com.bit101.components.RadioButton;
    import com.bit101.components.TextArea;
    import flash.display.BlendMode;
    import flash.display.Shader;
    import flash.display.ShaderData;
    import flash.display.ShaderInput;
    import flash.display.ShaderParameter;
    import flash.display.ShaderParameterType;
    import flash.display.Sprite;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.events.FocusEvent;
    import flash.events.IOErrorEvent;
    import flash.events.SecurityErrorEvent;
    import flash.events.TimerEvent;
    import flash.filters.ShaderFilter;
    import flash.net.FileFilter;
    import flash.net.FileReference;
    import flash.text.TextField;
    import flash.utils.ByteArray;
    import flash.utils.Timer;
    
    public class Main extends Sprite
    {
        private var _file:FileReference;
        private var _shader:Shader;
        private var _bytes:ByteArray;
        private var _inputs:Array;
        private var _parameters:Array;
        private var _metadata:Object;
        
        public function Main():void
        {
            Wonderfl.disable_capture();
            stage.scaleMode = StageScaleMode.NO_SCALE;
            
            var template:XML = <data><code><![CDATA[package
{
    import flash.display.Shader;
    import flash.utils.ByteArray;
    
    /**
     * %CLASS%
     * %META_DESCRIPTION%
     * @author %META_VENDER%
     * @version %META_VERSION%
     * @namespace %META_NAMESPACE%
     */
    class %CLASS% extends Shader
    {
        //Parameters
        %BEGIN_PARAMS%/**
         * (Parameter) %PARAM_NAME% %PARAM_AS3_TYPE_ARY%
         * %PARAM_DESCRIPTION%
         * @type %PARAM_PBJ_TYPE%
         * @minValue %PARAM_MIN_ARY%
         * @maxValue %PARAM_MAX_ARY%
         * @defaultValue %PARAM_DEFAULT_ARY%
         */
        public function get %PARAM_NAME%():Array { return data.%PARAM_NAME%.value; }
        public function set %PARAM_NAME%(value:Array):void { data.%PARAM_NAME%.value = value; }
        public function get %PARAM_NAME%_min():Array { return %PARAM_MIN_ARY%; }
        public function get %PARAM_NAME%_max():Array { return %PARAM_MAX_ARY%; }
        public function get %PARAM_NAME%_default():Array { return %PARAM_DEFAULT_ARY%; }
        public function get %PARAM_NAME%_type():String { return "%PARAM_PBJ_TYPE%"; }
        
        %END_PARAMS%//Inputs
        %BEGIN_INPUTS%/**
         * (Input) %INPUT_NAME%
         * @channels %INPUT_CHANNELS%
         */
        public function get %INPUT_NAME%():Object { return data.%INPUT_NAME%.input; }
        public function set %INPUT_NAME%(input:Object):void { data.%INPUT_NAME%.input = input; }
        public function get %INPUT_NAME%_width():int { return data.%INPUT_NAME%.width; }
        public function set %INPUT_NAME%_width(width:int):void { data.%INPUT_NAME%.width = width; }
        public function get %INPUT_NAME%_height():int { return data.%INPUT_NAME%.height; }
        public function set %INPUT_NAME%_height(height:int):void { data.%INPUT_NAME%.height = height; }
        
        %END_INPUTS%//Constructor
        public function %CLASS%(init:Object = null):void
        {
            if (_byte == null)
            {
                _byte = new ByteArray();
                for (var i:uint = 0, l:uint = _data.length; i < l; ++i) _byte.writeByte(_data[i]);
            }
            super(_byte);
            for (var prop:String in init) this[prop] = init[prop];
        }
        
        //Data
        private static var _byte:ByteArray = null;
        private static var _data:Vector.<int> = Vector.<int>(%DATA%);
    }
}]]></code><usage><filter><![CDATA[var myShader:%CLASS% = new %CLASS%();
var myFilter:ShaderFilter = new ShaderFilter(myShader);
%BEGIN_USAGE_INPUTS%myShader.%INPUT_NAME% = %INPUT_NAME%;
%END_USAGE_INPUTS%
//if target is DisplayObject
target.filters = [myFilter];

//if target is BitmapData
target.applyFilter(target, target.rect, new Point(), myFilter);]]></filter><shader><![CDATA[var myShader:%CLASS% = new %CLASS%();
%BEGIN_USAGE_INPUTS%myShader.%INPUT_NAME% = %INPUT_NAME%;
%END_USAGE_INPUTS%
//target is DisplayObject
target.blendMode = BlendMode.SHADER;
target.blendShader = myShader;]]></shader></usage></data>;
            
            var title:Label = new Label(this, 6, 0, "Embedded PixelBender Generator");
            title.scaleX = title.scaleY = 2;
            title.alpha = 0.7;
            
            new Label(this, 8, 333, "Main Code");
            var usageField:TextArea = new TextArea(this, 10, 353);
            usageField.width = 443;
            usageField.height = 100;
            usageField.textField.addEventListener(FocusEvent.FOCUS_IN, _selectField);
            
            var usageTypeFilter:RadioButton = new RadioButton(this, 359, 338, "Filter", true, function(e:Event):void {
                if (_shader) usageField.text = _generateCode(template.usage.filter.text());
            } );
            
            var usageTypeShader:RadioButton = new RadioButton(this, 409, 338, "Shader", false, function(e:Event):void {
                if (_shader) usageField.text = _generateCode(template.usage.shader.text());
            } );
            
            new Label(this, 8, 75, "Shader Code");
            var codeField:TextArea = new TextArea(this, 10, 95);
            codeField.width = 443;
            codeField.height = 230;
            codeField.textField.addEventListener(FocusEvent.FOCUS_IN, _selectField);
            
            _file = new FileReference();
            _file.addEventListener(Event.CANCEL, trace);
            _file.addEventListener(IOErrorEvent.IO_ERROR, trace);
            _file.addEventListener(SecurityErrorEvent.SECURITY_ERROR, trace);
            _file.addEventListener(Event.SELECT, function(e:Event):void
            {
                _file.load();
            } );
            _file.addEventListener(Event.COMPLETE, function(e:Event):void
            {
                _shader = new Shader(_bytes = _file.data);
                _inputs = new Array();
                _parameters = new Array();
                _metadata = new Object();
                var data:ShaderData = _shader.data;
                for (var prop:String in data)
                { 
                    if (data[prop] is ShaderInput) _inputs[data[prop].index] = data[prop];
                    else if (data[prop] is ShaderParameter) _parameters[data[prop].index] = data[prop];
                    else _metadata[prop] = data[prop];
                }
                codeField.text = _generateCode(template.code.text());
                usageField.text = _generateCode(usageTypeFilter.selected ? template.usage.filter.text() : template.usage.shader.text());
                codeField.textField.scrollV = 1;
                usageField.textField.scrollV = 1;
                saveButton.alpha = 1;
            } );
            
            var loadButton:PushButton = new PushButton(this, 10, 45, "Load .pbj File", function(e:Event):void {
                _file.browse([new FileFilter("Pixel Bender Byte Code files (*.pbj)", "*.pbj")]);
            } );
            loadButton.width = 215;
            
            var saveButton:PushButton = new PushButton(this, 239, 45, "Save .as File", function(e:Event):void {
                if (_shader) (new FileReference()).save(codeField.text, _metadata["name"] + ".as");
            } );
            saveButton.blendMode = BlendMode.LAYER;
            saveButton.width = 215;
            saveButton.alpha = 0.3;
        }
        
        private function _selectField(e:FocusEvent):void
        {
            var tf:TextField = TextField(e.target);
            var timer:Timer = new Timer(10);
            timer.addEventListener(TimerEvent.TIMER, function(e:TimerEvent):void
            {
                e.target.removeEventListener(e.type, arguments.callee);
                var scroll:int = tf.scrollV;
                tf.setSelection(0,  tf.text.length);
                tf.scrollV = scroll;
            } );
            timer.start();
        }
        
        private function _generateCode(template:String, removeLF:Boolean = true):String
        {
            template = template.replace(/\r\n/g, "\n");
            template = template.replace(/\r/g, "\n");
            
            var byteList:Array = new Array();
            _bytes.position = 0;
            while (_bytes.bytesAvailable) byteList.push(_bytes.readByte());
            var byteString:String = "[" + byteList.join(", ") + "]";
            
            template = template.replace(/%CLASS%/g, _metadata["name"]);
            template = template.replace(/%DATA%/g, byteString);
            template = template.replace(/(.*?)%BEGIN_PARAMS%(.*?)%END_PARAMS%(.*?)/s, function(matched:String, capture0:String, capture1:String, capture2:String, index:int, string:String):String
            {
                var parameter:ShaderParameter;
                for (var index:int = 0; index < _parameters.length; ++index)
                {
                    parameter = _parameters[index];
                    var code:String = capture1;
                    
                    var type:String;
                    var length:int;
                    switch (parameter["type"])
                    {
                        case ShaderParameterType.FLOAT:
                            type = "Number";
                            length = 1;
                            break;
                        
                        case ShaderParameterType.FLOAT2:
                            type = "Number";
                            length = 2;
                            break;
                        
                        case ShaderParameterType.FLOAT3:
                            type = "Number";
                            length = 3;
                            break;
                        
                        case ShaderParameterType.FLOAT4:
                            type = "Number";
                            length = 4;
                            break;
                        
                        case ShaderParameterType.INT:
                            type = "int";
                            length = 1;
                            break;
                        
                        case ShaderParameterType.INT2:
                            type = "int";
                            length = 2;
                            break;
                        
                        case ShaderParameterType.INT3:
                            type = "int";
                            length = 3;
                            break;
                        
                        case ShaderParameterType.INT4:
                            type = "int";
                            length = 4;
                            break;
                        
                        case ShaderParameterType.BOOL:
                            type = "Boolean";
                            length = 1;
                            break;
                        
                        case ShaderParameterType.BOOL2:
                            type = "Boolean";
                            length = 2;
                            break;
                        
                        case ShaderParameterType.BOOL3:
                            type = "Boolean";
                            length = 3;
                            break;
                        
                        case ShaderParameterType.BOOL4:
                            type = "Boolean";
                            length = 4;
                            break;
                        
                        case ShaderParameterType.MATRIX2X2:
                            type = "Number";
                            length = 4;
                            break;
                        
                        case ShaderParameterType.MATRIX3X3:
                            type = "Number";
                            length = 9;
                            break;
                        
                        case ShaderParameterType.MATRIX4X4:
                            type = "Number";
                            length = 16;
                            break;
                    }
                    
                    var types:Array = new Array(length);
                    for (var i:int = 0; i < length; ++i) types[i] = type;
                    code = code.replace(/%PARAM_AS3_TYPE_ARY%/g, "[" + types.join(", ") + "]");
                    
                    code = code.replace(/%PARAM_AS3_TYPE%/g, type);
                    code = code.replace(/%PARAM_LENGTH%/g, length);
                    code = code.replace(/%PARAM_NAME%/g, parameter["name"]);
                    code = code.replace(/%PARAM_INDEX%/g, String(parameter["index"]));
                    code = code.replace(/%PARAM_PBJ_TYPE%/g, parameter["type"]);
                    code = code.replace(/%PARAM_DESCRIPTION%/g, parameter["description"] != null ? parameter["description"] : "%REMOVE_LINE%");
                    code = code.replace(/%PARAM_MIN_ARY%/g, parameter["minValue"] != null ? ("[" + parameter["minValue"].join(", ") + "]") : "%REMOVE_LINE%");
                    code = code.replace(/%PARAM_MAX_ARY%/g, parameter["maxValue"] != null ? ("[" + parameter["maxValue"].join(", ") + "]") : "%REMOVE_LINE%");
                    code = code.replace(/%PARAM_DEFAULT_ARY%/g, parameter["defaultValue"] != null ? ("[" + parameter["defaultValue"].join(", ") + "]") : "%REMOVE_LINE%");
                    
                    capture0 += code;
                }
                return capture0 + capture2;
            } );
            
            function replaceInput(template:String, capture0:String, capture1:String, capture2:String, usage:Boolean):String
            {
                if (usage && _inputs.length > 1) capture0 += "\n//set inputs\n";
                var input:ShaderInput;
                for (var index:int = usage ? 1 : 0; index < _inputs.length; ++index)
                {
                    input = _inputs[index];
                    var code:String = capture1;
                    
                    code = code.replace(/%INPUT_NAME%/g, input["name"]);
                    code = code.replace(/%INPUT_INDEX%/g, String(input["index"]));
                    code = code.replace(/%INPUT_CHANNELS%/g, String(input["channels"]));
                    
                    capture0 += code;
                }
                return capture0 + capture2;
            }
            
            template = template.replace(/(.*?)%BEGIN_INPUTS%(.*?)%END_INPUTS%(.*?)/s, function(matched:String, capture0:String, capture1:String, capture2:String, index:int, string:String):String
            {
                return replaceInput(template, capture0, capture1, capture2, false);
            } );
            template = template.replace(/(.*?)%BEGIN_USAGE_INPUTS%(.*?)%END_USAGE_INPUTS%(.*?)/s, function(matched:String, capture0:String, capture1:String, capture2:String, index:int, string:String):String
            {
                return replaceInput(template, capture0, capture1, capture2, true);
            } );
            
            template = template.replace(/%META_VENDER%/g, _metadata["vendor"] != null ? _metadata["vendor"] : "%REMOVE_LINE%");
            template = template.replace(/%META_VERSION%/g, _metadata["version"] != null ? _metadata["version"] : "%REMOVE_LINE%");
            template = template.replace(/%META_NAMESPACE%/g, _metadata["namespace"] != null ? _metadata["namespace"] : "%REMOVE_LINE%");
            template = template.replace(/%META_DESCRIPTION%/g, _metadata["description"] != null ? _metadata["description"] : "%REMOVE_LINE%");
            
            template = template.replace(/\n(.*?)%REMOVE_LINE%(.*?)\n/g, "\n");
            template = template.replace(/\n(.*?)%REMOVE_LINE%(.*?)\n/g, "\n");
            
            return template;
        }
    }
}
package {
    import flash.display.Sprite;
    import flash.text.TextField;
    public class FlashTest extends Sprite {
        public function FlashTest() {
            $(graphics)
                .beginFill(0xff0000)
                .drawCircle(80, 80, 60)
                .endFill();
            $(graphics)
                .lineStyle(3, 0x0000ff)
                .moveTo(200, 100)
                .lineTo(150, 150)
                .lineTo(200, 150)
                .lineTo(200, 100);
        }
    }
}


import flash.utils.Proxy;
import flash.utils.flash_proxy;
import flash.utils.getQualifiedClassName;
import flash.utils.getDefinitionByName;
import flash.utils.describeType;

function $(obj:*):$${
    return new $$(obj);
}

dynamic class $$ extends Proxy{
    private var _obj:Object;
    private var _cls:Class;
    private var _desc:XML;
    private var _voidMethods:Object;

    public function $$(obj:Object){
        _obj = obj;

        // get class
        var clsName:String = getQualifiedClassName(obj);
        _cls = getDefinitionByName(clsName) as Class;
        if (_cls == null) throw new Error("failed to get class");

        // describeType
        _voidMethods = {};
        _desc = describeType(obj);
        for each (var xml:XML in _desc.method.(@returnType == "void")){
            _voidMethods[xml.@name.toString()] = 1;
        }
    }
    
    flash_proxy override function callProperty(name:*, ... rest):*{
        if (_voidMethods[name]){
            _obj[name].apply(_obj, rest);
            return this;
        } else {
            return _obj[name].apply(_obj, rest);
        }
    }
}
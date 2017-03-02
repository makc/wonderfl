////////////////////////////////////////////////////////////////////////////////
// [AS3.0] MenuTreeコンポーネントに挑戦！ (1)
// http://www.project-nya.jp/modules/weblog/details.php?blog_id=997
////////////////////////////////////////////////////////////////////////////////

package {

    import flash.display.Sprite;
    import flash.display.Shape;
    import flash.geom.Rectangle;
    import flash.events.MouseEvent;

    [SWF(backgroundColor="#EEEEEE", width="465", height="465", frameRate="30")]

    public class Main extends Sprite {
        private var menu:MenuTree;
        private var itemList:Array;
        private var label:Label;

        public function Main() {
            Wonderfl.capture_delay(8);
            init();
        }

        private function init():void {
            graphics.beginFill(0xEEEEEE);
            graphics.drawRect(0, 0, 465, 465);
            graphics.endFill();
            itemList = new Array();
            itemList.push({label: "profile"});
            var childList2:Array = new Array();
            childList2.push({label: "NyAlbum"});
            childList2.push({label: "NyaPhoto"});
            childList2.push({label: "NyaClock"});
            itemList.push({label: "digital junk box", child: childList2});
            var childList3:Array = new Array();
            childList3.push({label: "Flash Studio"});
            itemList.push({label: "monkey club", child: childList3});
            itemList.push({label: "aquazone"});
            var childList4:Array = new Array();
            childList4.push({label: "works"});
            var childList41:Array = new Array();
            childList41.push({label: "AS1.0"});
            childList41.push({label: "AS2.0"});
            childList41.push({label: "AS3.0"});
            childList4.push({label: "ActionScript", child: childList41});
            itemList.push({label: "shockwave flash", child: childList4});
            itemList.push({label: "communication"});
            menu = new MenuTree();
            addChild(menu);
            menu.x = 20;
            menu.y = 20;
            menu.init({label: "home"});
            menu.dataProvider = itemList;
            menu.addEventListener(CompoEvent.SELECT, select, false, 0, true);
            label = new Label(40);
            addChild(label);
            label.x = 40;
            label.y = 300;
            label.textColor = 0x333333;
        }
        private function select(evt:CompoEvent):void {
            var list:Array = itemList.concat();
            for (var n:Number = 0; n < evt.value.length; n++) {
                var obj:Object = list[evt.value[n]];
                list = obj.child;
            }
            label.text = obj.label;
        }

    }

}


//////////////////////////////////////////////////
//    MenuTreeクラス
//////////////////////////////////////////////////

import flash.display.Sprite;
import flash.display.Shape;
import flash.text.TextField;
import flash.text.TextFieldType;
import flash.text.AntiAliasType;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flash.events.MouseEvent;
import flash.geom.ColorTransform;

class MenuTree extends Sprite {
    public var id:uint;
    private var tab:Sprite;
    private var base:Shape;
    private var txt:TextField;
    private var label:String = "";
    private static var fontType:String = "_ゴシック";
    private var _width:uint = 60;
    private static var _height:uint = 20;
    private static var tHeight:uint = 20;
    private static var bColor:uint = 0xFFFFFF;
    private static var cColor:uint = 0x3165B5;
    private static var upColor:uint = 0x000000;
    private static var overColor:uint = 0xFFFFFF;
    private static var offColor:uint = 0x999999;
    private static var bColorTrans:ColorTransform;
    private static var cColorTrans:ColorTransform;
    private var child:MenuTreeChild;
    private var dataList:Array;
    private var childList:Array;
    private var itemList:Array;
    private var selectedID:Array;
    private var _enabled:Boolean = true;
    private var _selected:Boolean = false;

    public function MenuTree() {
    }

    public function init(option:Object):void {
        if (option.id != undefined) id = option.id;
        if (option.label != undefined) label = option.label;
        if (option.width != undefined) _width = option.width;
        draw();
    }
    private function draw():void {
        bColorTrans = new ColorTransform();
        bColorTrans.color = bColor;
        cColorTrans = new ColorTransform();
        cColorTrans.color = cColor;
        tab = new Sprite();
        base = new Shape();
        txt = new TextField();
        addChild(tab);
        tab.addChild(base);
        tab.addChild(txt);
        createBox(base, _width, _height);
        txt.y = 1;
        txt.width = _width;
        txt.height = _height - 1;
        txt.type = TextFieldType.DYNAMIC;
        txt.selectable = false;
        //txt.embedFonts = true;
        //txt.antiAliasType = AntiAliasType.ADVANCED;
        var tf:TextFormat = new TextFormat();
        tf.font = fontType;
        tf.size = 12;
        tf.align = TextFormatAlign.CENTER;
        txt.defaultTextFormat = tf;
        txt.text = label;
        _up();
        enabled = true;
        tab.mouseChildren = false;
        childList = new Array();
        itemList = new Array();
    }
    private function rollOver(evt:MouseEvent):void {
        _over();
    }
    private function rollOut(evt:MouseEvent):void {
        up();
    }
    private function press(evt:MouseEvent):void {
        _over();
    }
    private function release(evt:MouseEvent):void {
        _over();
    }
    private function click(evt:MouseEvent):void {
        _over();
        child.opencloseMenu();
    }
    private function up():void {
        if (_selected) {
            _over();
        } else {
            _up();
        }
    }
    private function _up():void {
        txt.textColor = upColor;
        base.transform.colorTransform = bColorTrans;
    }
    private function _over():void {
        txt.textColor = overColor;
        base.transform.colorTransform = cColorTrans;
    }
    private function _off():void {
        txt.textColor = offColor;
        base.transform.colorTransform = bColorTrans;
    }
    public function set dataProvider(list:Array):void {
        dataList = list;
        if (dataList.length > 0) addChildren();
    }
    private function addChildren():void {
        child = new MenuTreeChild(dataList, this, []);
        addChild(child);
        child.x = 0;
        child.y = tHeight;
        child._visible = false;
        child.addEventListener(MouseEvent.CLICK, select, false, 0, true);
    }
    private function mouseDown(evt:MouseEvent):void {
        if (!hitTestPoint(stage.mouseX, stage.mouseY, true)) {
            child.closeMenu();
        }
    }
    public function initialize(param:Array):void {
        var selectedID:Array = param;
        selectItem(selectedID);
    }
    private function selectItem(id:Array):void {
        selectedID = id;
        checkItem();
    }
    private function select(evt:MouseEvent):void {
        selectedID = evt.target.parent.id;
        var e:CompoEvent = new CompoEvent(CompoEvent.SELECT, selectedID);
        dispatchEvent(e);
    }
    public function registerChild(child:MenuTreeChild):void {
        childList.push(child);
    }
    public function closeChild():void {
        for (var n:uint = 0; n < childList.length; n++) {
            var child:MenuTreeChild = childList[n];
            child.opened = false;
            child._visible = false;
        }
        closeItems();
    }
    private function closeItems():void {
        for (var n:uint = 0; n < itemList.length; n++) {
            var item:MenuTreeItem = itemList[n];
            item.opened = false;
        }
    }
    public function registerItem(item:MenuTreeItem):void {
        itemList.push(item);
    }
    public function checkItem():void {
        for (var n:uint = 0; n < itemList.length; n++) {
            var item:MenuTreeItem = itemList[n];
            if (selectedID) {
                if (item.id.toString() == selectedID.toString()) {
                    item.selected = true;
                } else {
                    item.selected = false;
                }
            }
        }
    }
    public function get selected():Boolean {
        return _selected;
    }
    public function set selected(param:Boolean):void {
        _selected = param;
        if (_enabled) up();
    }
    public function get enabled():Boolean {
        return _enabled;
    }
    public function set enabled(param:Boolean):void {
        _enabled = param;
        tab.buttonMode = _enabled;
        tab.mouseEnabled = _enabled;
        tab.useHandCursor = _enabled;
        if (_enabled) {
            _up();
            tab.addEventListener(MouseEvent.MOUSE_OVER, rollOver, false, 0, true);
            tab.addEventListener(MouseEvent.MOUSE_OUT, rollOut, false, 0, true);
            tab.addEventListener(MouseEvent.MOUSE_DOWN, press, false, 0, true);
            tab.addEventListener(MouseEvent.MOUSE_UP, release, false, 0, true);
            tab.addEventListener(MouseEvent.CLICK, click, false, 0, true);
            stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown, false, 0, true);
        } else {
            _off();
            tab.removeEventListener(MouseEvent.MOUSE_OVER, rollOver);
            tab.removeEventListener(MouseEvent.MOUSE_OUT, rollOut);
            tab.removeEventListener(MouseEvent.MOUSE_DOWN, press);
            tab.removeEventListener(MouseEvent.MOUSE_UP, release);
            tab.removeEventListener(MouseEvent.CLICK, click);
            stage.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
        }
    }
    private function createBox(target:Shape, w:uint, h:uint):void {
        target.graphics.clear();
        target.graphics.beginFill(bColor);
        target.graphics.drawRect(0, 0, w, h);
        target.graphics.endFill();
    }

}


import flash.display.Sprite;
import flash.display.Shape;
import flash.events.MouseEvent;
import flash.filters.DropShadowFilter;

class MenuTreeChild extends Sprite {
    public var id:Array;
    private var _width:uint = 100;
    private var _height:uint;
    private static var tHeight:uint = 20;
    private static var bColor:uint = 0xFFFFFF;
    private static var sColor:uint = 0x000000;
    private var dataList:Array;
    private var max:uint;
    private var itemList:Array;
    private var maxWidth:uint = 0;
    private var back:Shape;
    private var shade:DropShadowFilter;
    private var menu:MenuTree;
    public var opened:Boolean = false;
    private var __visible:Boolean = false;
    private var openedID:uint;

    public function MenuTreeChild(list:Array, m:MenuTree, i:Array) {
        dataList = list;
        max = dataList.length;
        _height = tHeight*max;
        menu = m;
        id = i;
        init();
    }

    private function init():void {
        back = new Shape();
        addChild(back);
        shade = new DropShadowFilter(1, 90, sColor, 0.5, 4, 4, 2, 3, false, false);
        back.filters = [shade];
        itemList = new Array();
        for (var n:uint = 0; n < max; n++) {
            var item:MenuTreeItem = new MenuTreeItem({cid: n, label: dataList[n].label, child: dataList[n].child}, menu, id);
            addChildAt(item, 1);
            item.y = tHeight*n;
            itemList.push(item);
            item.addEventListener(MouseEvent.MOUSE_OVER, opencloseItems, false, 0, true);
            item.addEventListener(MouseEvent.CLICK, select, false, 0, true);
            menu.registerItem(item);
            resizeWidth(item);
        }
        menu.registerChild(this);
    }
    private function showItems():void {
        addChildAt(back, 0);
        for (var n:uint = 0; n < max; n++) {
            var item:MenuTreeItem = itemList[n];
            addChildAt(item, 1);
        }
    }
    private function hideItems():void {
        if (contains(back)) removeChild(back);
        for (var n:uint = 0; n < max; n++) {
            var item:MenuTreeItem = itemList[n];
            if (contains(item)) removeChild(item);
        }
    }
    private function select(evt:MouseEvent):void {
        closeMenu();
    }
    public function opencloseMenu():void {
        if (!opened) {
            openMenu();
        } else {
            closeMenu();
        }
    }
    private function openMenu():void {
        opened = true;
        _visible = true;
        menu.selected = true;
        menu.checkItem();
    }
    public function closeMenu():void {
        opened = false;
        _visible = false;
        menu.selected = false;
        menu.closeChild();
    }
    private function opencloseItems(evt:MouseEvent):void {
        openedID = evt.currentTarget.cid;
        for (var n:uint = 0; n < itemList.length; n++) {
            var item:MenuTreeItem = itemList[n];
            if (n == openedID) {
                item.opened = true;
            } else {
                item.opened = false;
            }
        }
    }
    private function resizeWidth(item:MenuTreeItem):void {
        if (item._width > maxWidth) maxWidth = item._width;
        if (itemList.length >= max) resize();
    }
    private function resize():void {
        _width = maxWidth;
        createBox(back, _width, _height);
        for (var n:uint = 0; n < max; n++) {
            var item:MenuTreeItem = itemList[n];
            item._width = maxWidth;
            item.txt.width = item._width - 20;
            createBox(item.base, item._width, item._height);
            item.tree.x = item._width - 20;
            if (item.child) item.child.x = item._width;
        }
    }
    public function get _visible():Boolean {
        return __visible;
    }
    public function set _visible(param:Boolean):void {
        __visible = param;
        if (__visible) {
            showItems();
        } else {
            hideItems();
        }
    }
    private function createBox(target:Shape, w:uint, h:uint):void {
        target.graphics.clear();
        target.graphics.beginFill(bColor);
        target.graphics.drawRect(0, 0, w, h);
        target.graphics.endFill();
    }

}


import flash.display.Sprite;
import flash.display.Shape;
import flash.text.TextField;
import flash.text.TextFieldType;
import flash.text.AntiAliasType;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flash.events.MouseEvent;
import flash.geom.ColorTransform;

class MenuTreeItem extends Sprite {
    public var cid:uint;
    public var id:Array;
    private var item:Sprite;
    public var base:Shape;
    public var txt:TextField;
    private var check:TextField;
    public var tree:Shape;
    public var _width:uint = 100;
    public var _height:uint = 20;
    private var label:String = "";
    private static var fontType:String = "_ゴシック";
    private var mark:String = String.fromCharCode(10003);
    private static var checkType:String = "_ゴシック";
    private static var bColor:uint = 0xFFFFFF;
    private static var cColor:uint = 0x3165B5;
    private static var upColor:uint = 0x000000;
    private static var overColor:uint = 0xFFFFFF;
    private static var bColorTrans:ColorTransform;
    private static var cColorTrans:ColorTransform;
    private static var upColorTrans:ColorTransform;
    private static var overColorTrans:ColorTransform;
    private var menu:MenuTree;
    public var child:MenuTreeChild;
    private var dataList:Array;
    private var _selected:Boolean = false;
    private var _opened:Boolean = false;

    public function MenuTreeItem(option:Object, m:MenuTree, i:Array) {
        if (option.cid != undefined) cid = option.cid;
        if (option.label) label = option.label;
        if (option.child) dataList = option.child;
        menu = m;
        id = i.concat();
        id[id.length] = cid;
        init();
    }

    private function init():void {
        bColorTrans = new ColorTransform();
        bColorTrans.color = bColor;
        cColorTrans = new ColorTransform();
        cColorTrans.color = cColor;
        upColorTrans = new ColorTransform();
        upColorTrans.color = upColor;
        overColorTrans = new ColorTransform();
        overColorTrans.color = overColor;
        item = new Sprite();
        base = new Shape();
        txt = new TextField();
        check = new TextField();
        tree = new Shape();
        addChild(item);
        item.addChild(base);
        item.addChild(txt);
        item.addChild(check);
        item.addChild(tree);
        txt.x = 20;
        txt.y = 1;
        txt.width = _width;
        txt.height = _height - 1;
        txt.type = TextFieldType.DYNAMIC;
        txt.selectable = false;
        //txt.embedFonts = true;
        //txt.antiAliasType = AntiAliasType.ADVANCED;
        var tf:TextFormat = new TextFormat();
        tf.font = fontType;
        tf.size = 12;
        tf.align = TextFormatAlign.LEFT;
        txt.defaultTextFormat = tf;
        txt.text = label;
        if (dataList) {
            _width = txt.textWidth + 50;
        } else {
            _width = txt.textWidth + 35;
        }
        check.x = 3;
        check.y = -1;
        check.width = 12;
        check.height = 22;
        check.type = TextFieldType.DYNAMIC;
        check.selectable = false;
        //check.embedFonts = true;
        //check.antiAliasType = AntiAliasType.ADVANCED;
        var tfc:TextFormat = new TextFormat();
        tfc.font = checkType;
        tfc.size = 12;
        tfc.align = TextFormatAlign.LEFT;
        check.defaultTextFormat = tfc;
        check.text = mark;
        check.visible = _selected;
        createTriangle(tree);
        tree.x = _width - 20;
        if (dataList) {
            tree.visible = true;
        } else {
            tree.visible = false;
        }
        if (dataList) addChildren();
        buttonMode = true;
        mouseEnabled = true;
        useHandCursor = true;
        _up();
        item.mouseChildren = false;
        addEventListener(MouseEvent.MOUSE_OVER, rollOver, false, 0, true);
        addEventListener(MouseEvent.MOUSE_OUT, rollOut, false, 0, true);
        addEventListener(MouseEvent.MOUSE_DOWN, press, false, 0, true);
        addEventListener(MouseEvent.MOUSE_UP, release, false, 0, true);
        addEventListener(MouseEvent.CLICK, click, false, 0, true);
    }
    private function addChildren():void {
        child = new MenuTreeChild(dataList, menu, id);
        addChild(child);
        child._visible = false;
    }
    private function rollOver(evt:MouseEvent):void {
        _over();
    }
    private function rollOut(evt:MouseEvent):void {
        if (dataList) {
            up();
        } else {
            _up();
        }
    }
    private function press(evt:MouseEvent):void {
        _over();
    }
    private function release(evt:MouseEvent):void {
        _up();
    }
    private function click(evt:MouseEvent):void {
        _up();
    }
    private function up():void {
        if (_opened) {
            _over();
        } else {
            _up();
        }
    }
    private function _up():void {
        txt.textColor = upColor;
        check.textColor = upColor;
        base.transform.colorTransform = bColorTrans;
        tree.transform.colorTransform = upColorTrans;
    }
    private function _over():void {
        txt.textColor = overColor;
        check.textColor = overColor;
        base.transform.colorTransform = cColorTrans;
        tree.transform.colorTransform = overColorTrans;
    }
    public function get selected():Boolean {
        return _selected;
    }
    public function set selected(param:Boolean):void {
        _selected = param;
        check.visible = _selected;
    }
    public function get opened():Boolean {
        return _opened;
    }
    public function set opened(param:Boolean):void {
        _opened = param;
        if (child) child._visible = _opened;
        up();
    }
    private function createTriangle(target:Shape):void {
        target.graphics.clear();
        target.graphics.beginFill(bColor);
        target.graphics.moveTo(6, 5);
        target.graphics.lineTo(6, 15);
        target.graphics.lineTo(14, 10);
        target.graphics.lineTo(6, 5);
        target.graphics.endFill();
    }

}


//////////////////////////////////////////////////
//    CompoEventクラス
//////////////////////////////////////////////////

import flash.events.Event;

class CompoEvent extends Event {
    public static const SELECT:String = "select";
    public static const CHANGE:String = "change";
    public var value:*;

    public function CompoEvent(type:String, value:*) {
        super(type);
        this.value = value;
    }

    public override function clone():Event {
        return new CompoEvent(type, value);
    }

}


//////////////////////////////////////////////////
//    Labelクラス
//////////////////////////////////////////////////

import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFieldType;
import flash.text.TextFieldAutoSize;
import flash.text.AntiAliasType;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

class Label extends Sprite {
    private var txt:TextField;
    private var fontSize:uint;
    private static var fontType:String = "_ゴシック";
    private static var _height:uint = 20;

    public function Label(s:uint) {
        fontSize = s;
        draw();
    }

    private function draw():void {
        txt = new TextField();
        addChild(txt);
        txt.height = _height;
        txt.autoSize = TextFieldAutoSize.LEFT;
        txt.type = TextFieldType.DYNAMIC;
        txt.selectable = false;
        //txt.embedFonts = true;
        //txt.antiAliasType = AntiAliasType.ADVANCED;
        var tf:TextFormat = new TextFormat();
        tf.font = fontType;
        tf.size = fontSize;
        tf.align = TextFormatAlign.LEFT;
        txt.defaultTextFormat = tf;
    }
    public function set text(param:String):void {
        txt.text = param;
    }
    public function set textColor(param:uint):void {
        txt.textColor = param;
    }

}

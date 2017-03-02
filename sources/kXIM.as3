package {
    import flash.display.Sprite;
    public class ButtonContainer extends Sprite {
        public function ButtonContainer() {
            var button:Button = new Button;
            button.setText('Click me!');
            button.x = 9; button.y = 7;
            addChild(button);
            
            stage.scaleMode = "noScale";
            stage.align = "tl";
        }
    }
}

import flash.display.*;
import flash.events.MouseEvent;
import flash.text.TextFormat;
import flash.text.TextField;
import flash.events.Event;

class Button extends Sprite {
    protected var _label:TextField;
    protected var _tfmOver:TextFormat = new TextFormat('_serif', 14, 0);
    protected var _tfmOut:TextFormat = new TextFormat('_serif', 14, 0xffffff);
    protected var _overSkin:Shape;
    
    public function Button() {
        _label = new TextField;
        _label.defaultTextFormat = _tfmOut;
        _label.x = _label.y = 1;
        _overSkin = new Shape;
        
        addEventListener(Event.ADDED_TO_STAGE, function _init(e:Event):void {
            removeEventListener(Event.ADDED_TO_STAGE, _init);
            init();
        });
    }
    protected function init():void {
        buttonMode = true;
        tabEnabled = false;
        _label.mouseEnabled = false;
        addChild(_overSkin);
        addChild(_label);
        
        addEventListener(MouseEvent.MOUSE_OVER, mouseOver);
        addEventListener(MouseEvent.MOUSE_OUT, mouseOut);
        
        mouseOut(null);
    }
    protected function mouseOver(e:MouseEvent):void {
        _overSkin.visible = true;
        _label.setTextFormat(_tfmOver);
    }
    protected function mouseOut(e:MouseEvent):void {
        _overSkin.visible = false;
        _label.setTextFormat(_tfmOut);
    }
    public function setText(value:String):void {
        _label.text = value;
        _label.width = _label.textWidth + 4;
        _label.height = _label.textHeight + 4;
        
        draw(graphics, 0x888888, 0x999999);
        draw(_overSkin.graphics, 0xbbbbbb, 0xcccccc);
    }
    private function draw(g:Graphics, lineColor:uint, fillColor:uint):void {
        g.clear();
        g.lineStyle(2, lineColor);
        g.beginFill(fillColor);
        g.drawRect(0, 0, _label.width + 2, _label.height + 2);
        g.endFill();
    }
}
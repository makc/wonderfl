package {
    import flash.events.Event;
    import flash.display.Sprite;
    public class FlashTest extends Sprite {
        
        private var mouseSlider:LineSlider;
        private var scaleSlider:LineSlider;
        private var mouseBetweenSlider:LineSlider;
        private var valueINeed:LineSlider;
        
        public function FlashTest() {
            // write as3 code here..
            
            graphics.beginFill(0x0);
            graphics.drawRect(0,0,stage.stageWidth,stage.stageHeight);
            graphics.endFill();
            
            mouseSlider = new LineSlider(stage.stageWidth-40, 0, stage.stageWidth,"Mouse X", 0xFFFFFF);
            addChild(mouseSlider);
            mouseSlider.y = 50;
            mouseSlider.x = 20;
            
            scaleSlider = new LineSlider(200,0,1,"Mouse %",0xB0EB4E);
            addChild(scaleSlider);
            scaleSlider.x = 120;
            scaleSlider.y = 140;
            
            mouseBetweenSlider = new LineSlider(300, 60, 405, "Mouse Between 60 - 405",0xF07D57);
            addChild(mouseBetweenSlider);
            mouseBetweenSlider.x = 60;
            mouseBetweenSlider.y = 200;
            
            valueINeed = new LineSlider(stage.stageWidth-40, 0, 1, "Value I Need % (mouse between 60 - 405)", 0x67AAE0);
            addChild(valueINeed);
            valueINeed.x = 20;
            valueINeed.y = 260;
            
            addEventListener("enterFrame", loop);
        }
        private function loop(e:Event):void
        {
            mouseSlider.value = stage.mouseX;
            
            scaleSlider.value = mouseSlider.value/stage.stageWidth;
            
            mouseBetweenSlider.value = mouseSlider.value;
            
            var rangeCutOff:int = 60;
            
            var val:Number = stage.mouseX;
            var scale:Number = ((val - mouseBetweenSlider.min) / (mouseBetweenSlider.max - mouseBetweenSlider.min));
            
            
            //val = val > stage.stageWidth - rangeCutOff * 2 ? stage.stageWidth - rangeCutOff * 2 : val;
            //valueINeed.value = val / (stage.stageWidth - rangeCutOff);
            valueINeed.value = scale;
            
//        slider.value = _value  = x < min ? min : (x > max ? max : x);
//        slider.x = ((_value - min) / (max - min)) * w;
        }

    }
}
/////////////////////////////////
//        SLIDER
/////////////////////////////////
import flash.geom.Rectangle;
import flash.text.TextFormat;
import flash.text.TextField;
import flash.display.Sprite;

class LineSlider extends Sprite
{
    private var lblA:Text;
    private var lblB:Text;
    public var label:Text;
    private var slider:LineSliderValue;
    
    private var w:Number;
    public var min:Number;
    public var max:Number;
    
    public function LineSlider(width:Number, min:Number, max:Number, name:String="", color:uint = 0x0)
    {
        w = width;
        this.min = min;
        this.max = max;
        
        lblA = new Text(min.toFixed(1), color);
        addChild(lblA);
        lblB = new Text(max.toFixed(1), color);
        addChild(lblB);
        
        label = new Text(name, color);
        addChild(label);
        
        slider = new LineSliderValue(color);
        addChild(slider);
        value = 0;        
        
        graphics.lineStyle(4, color);
        graphics.moveTo(0, -6);
        graphics.lineTo(0,0);
        graphics.lineTo(width, 0);
        graphics.lineTo(width, -6);
        
        label.x = (width - label.width)/2;
        
        
        //lblA.x = -lblA.width/2;
        lblB.x = width - lblB.width;
    }
    
    private var _value:Number = 0;
    public function get value():Number{return _value;}
    public function set value(x:Number):void
    {    
        slider.value = _value  = x < min ? min : (x > max ? max : x);
        slider.x = ((_value - min) / (max - min)) * w;
    }
}

class LineSliderValue extends Sprite
{
    private var label:Text;
    private var color:uint = 0x0;
    
    public function LineSliderValue(color:uint = 0x0)
    {
        this.color = color;
        
        label = new Text("0", color);
        addChild(label);
        label.x = -label.width/2;
        label.y = -label.height - 12;
        
    }
    public function set value(val:Number):void
    {
        label.text = val.toFixed(1);
        label.x = -label.width/2;
        graphics.clear();
        graphics.lineStyle(3, color,1,true);
        graphics.beginFill(color, 0.1);
        //var mx:Number = Math.max(label.width, label.height);
        //graphics.drawCircle(label.x + label.width/2, label.y + label.height/2, mx/2 + 2);
        //graphics.drawRoundRect(label.x-3, label.y, label.width+6, label.height, label.height/2);
        var r:Rectangle = new Rectangle(label.x-3, label.y, label.width+6, label.height);
        graphics.moveTo(r.left,r.bottom);
        graphics.lineTo(r.left,r.top);
        graphics.lineTo(r.right,r.top);
        graphics.lineTo(r.right,r.bottom);
        graphics.lineTo(0,-4);
        graphics.lineTo(r.left,r.bottom);
        graphics.endFill();
    }
}
class Text extends TextField
{
    private var color:uint;
    public function Text(txt:String, color:uint = 0x0)
    {
        this.color = color;
        super();
        this.defaultTextFormat = new TextFormat("_sans", 14, color);    
        this.multiline = false;
        this.wordWrap = false;
        this.selectable = false;
        this.autoSize = "left";
        this.mouseEnabled = false;
        this.text = txt;
        
    }    
    public function set size(value:int):void {
        this.setTextFormat(new TextFormat("_sans", value, color));
    }
}
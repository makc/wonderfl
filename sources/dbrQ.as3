/*
please tune your own config and paste it into the comments
*/

package
{
    import com.bit101.components.ComboBox;
    import com.bit101.components.HUISlider;
    import com.bit101.components.PushButton;
    import com.bit101.components.TextArea;
    import com.bit101.components.VBox;
    
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    
    import net.hires.debug.Stats;
    
    [SWF(frameRate="30", backgroundColor="#FFFFFF")]
    public class Penice extends Sprite
    {
        private var speed:Point;
        private var position:Point;
        private var thickness:Number = 1;
        
        private var size:HUISlider;
        private var steps:HUISlider;
        private var speedSmoothness:HUISlider;
        private var speedDecel:HUISlider;
        private var minSize:HUISlider;
        private var maxSize:HUISlider;
        private var sot:HUISlider;
        private var thicknessSmoothness:HUISlider;
        
        private var bg:Sprite = new Sprite();
        private var drawing:Boolean = false;
        
        private var textArea:TextArea
        private var configCombo:ComboBox;
        
        private var configs:Array = [
            {label:"Yoz 1",  values:[   1,    5,   17, 1.15,    2,  3.0,   .5,   20]},
            {label:"Yoz 2",  values:[   1,   10,   80, 1.10,    1,  1.9,   .5,   20]},
            {label:"Yoz 3",  values:[   1,    3,   33, 1.15,  1.3,  1.6,   .5,   20]},
            {label:"Thy 1",  values:[   1,    5, 20.4, 1.15,  0.8,   10,  2.5,  7.6]},
            {label:"Brad 1", values:[2.37, 3.08, 27.5,  1.1,  2.8,  9.1,  0.5,37.58]}
        ];
        
        
        public function Penice()
        {
            super();
            stage.align = StageAlign.TOP_LEFT;
            stage.scaleMode = StageScaleMode.NO_SCALE;
            
            addChild(bg);
            bg.graphics.beginFill(0, 0);
            bg.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
            bg.graphics.endFill();
            
            addEventListener(Event.ENTER_FRAME, onEnterFrame);
            bg.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
            bg.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
            
            var box:VBox = new VBox(this);
            
            configCombo = new ComboBox(box, 0, 0, "label", configs);
            configCombo.addEventListener(Event.SELECT, onConfigSelect);
            
            size = new HUISlider(box, 0, 0, "size");
            size.minimum = 1;
            size.maximum = 5;
            
            steps = new HUISlider(box, 0, 0, "steps");
            steps.minimum = 1;
            steps.maximum = 10;
            
            speedSmoothness = new HUISlider(box, 0, 0, "speed smooth");
            speedSmoothness.minimum = 0.5;
            speedSmoothness.maximum = 80;
            speedSmoothness.tick = 0.1;
            
            speedDecel = new HUISlider(box, 0, 0, "speed decel");
            speedDecel.minimum = 1;
            speedDecel.maximum = 1.8;
            speedDecel.tick = 0.01;
            speedDecel.labelPrecision = 2;
            
            sot = new HUISlider(box, 0, 0, "speed over thickness");
            sot.minimum = 0.5;
            sot.maximum = 10;
            sot.tick = 0.1;
            
            thicknessSmoothness = new HUISlider(box, 0, 0, "thickness smooth");
            thicknessSmoothness.minimum = 0.5;
            thicknessSmoothness.maximum = 10;
            thicknessSmoothness.tick = 0.1;
            
            minSize = new HUISlider(box, 0, 0, "min size");
            minSize.minimum = 0.5;
            minSize.maximum = 100;
            minSize.tick = 0.5;
            
            maxSize = new HUISlider(box, 0, 0, "max size");
            maxSize.minimum = 1;
            maxSize.maximum = 100;
            
            new PushButton(box, 0, 0, "clear graphics", onClear);
            new PushButton(box, 0, 0, "current config", onGetConfig);
            
            textArea = new TextArea(box);
            
            config = configs[0].values;
        }
        
        private function set config(value:Array):void
        {
            var i:uint = 0;
            size.value = value[i++];
            steps.value = value[i++];
            speedSmoothness.value = value[i++];
            speedDecel.value = value[i++];
            sot.value = value[i++];
            thicknessSmoothness.value = value[i++];
            minSize.value = value[i++];
            maxSize.value = value[i++];
        }
        
        private function onClear(event:Event):void
        {
            graphics.clear();
            graphics.lineStyle(2);
        }
        
        private function onGetConfig(event:Event):void
        {
            textArea.text = 
                size.value + ", " +
                steps.value + ", " +
                speedSmoothness.value + ", " +
                speedDecel.value + ", " +
                sot.value + ", " +
                thicknessSmoothness.value + ", " +
                minSize.value + ", " +
                maxSize.value;
        }
        
        private function onConfigSelect(event:Event):void
        {
            config = configCombo.selectedItem.values;
        }
        
        private function onMouseDown(event:MouseEvent):void
        {
            drawing = true;
            speed = new Point(0, 0);
            position = new Point(mouseX, mouseY);
            thickness = 1;
            graphics.lineStyle(2);
            graphics.moveTo(position.x, position.y);
        }
        
        private function onMouseUp(event:MouseEvent):void
        {
            drawing = false;
        }
        
        private function onEnterFrame(event:Event):void
        {
            if(!drawing)
                return;
            
            for(var i:uint = 1; i <= steps.value; i++)
                draw(
                    position.x + i / steps.value * (mouseX - position.x), 
                    position.y + i / steps.value * (mouseY - position.y));
        }
        
        private function draw(x:Number, y:Number):void
        {
            speed.x += (x - position.x) / speedSmoothness.value;
            speed.y += (y - position.y) / speedSmoothness.value;
            
            speed.x /= speedDecel.value;
            speed.y /= speedDecel.value;
            
            position.x += speed.x;
            position.y += speed.y;
            
            var s:Number = Math.sqrt(speed.x * speed.x + speed.y * speed.y);
            thickness += (s / sot.value - thickness) / thicknessSmoothness.value;
            thickness = Math.min(Math.max(thickness, minSize.value), maxSize.value);
            
            graphics.lineStyle(thickness * size.value);
            graphics.lineTo(position.x, position.y);
        }
    }
}
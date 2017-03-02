// forked from matacat's forked from: flash on 2011-2-4
package
{
    import flash.display.AVM1Movie;
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.BlendMode;
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.filters.BlurFilter;
    
    import com.bit101.components.*;
    
    [SWF(frameRate=60)]
    public class FlashTest extends Sprite
    {
        private const D2R:Number = Math.PI / 180;
        
        private var centerX:int = stage.stageWidth / 2;
        //private var centerY:int = stage.stageWidth * 5 / 8;
        private var centerY:int = stage.stageWidth / 2;
        
        private var myCenterDot:MyArm = new MyArm(  0,   0, 0, 0xffffff);
        private var myArm1Dot:MyArm   = new MyArm( 75, 270, 2, 0xff0000);
        private var myArm2Dot:MyArm   = new MyArm(100, 270, 2.5, 0x00ff00);
        private var myArm3Dot:MyArm   = new MyArm(125, 270, 1, 0x0000ff);
        private var line:Shape        = new Shape();
        private var canvas:Sprite     = new Sprite();
        private var canvasBitmap:BitmapData = new BitmapData(stage.stageWidth, stage.stageHeight, false, 0x000000);
        private var lineWidth:Number  = 2;
        private var canvasIsBlurred:Boolean = false;
        
        private var myUIPanel:Panel;
        
        private var myArm1LengthSlider:HUISlider;
        private var myArm1OmegaSlider:HUISlider;
        
        private var myArm2LengthSlider:HUISlider;
        private var myArm2OmegaSlider:HUISlider;
        
        private var myArm3LengthSlider:HUISlider;
        private var myArm3OmegaSlider:HUISlider;
        
        private var myArmWidthSlider:HUISlider;
        private var myRandomizeColorsButton:PushButton;
        private var myBlurToggleButton:PushButton;
        private var myResetButton:PushButton;

        public function FlashTest()
        {
            myCenterDot.x = centerX;
            myCenterDot.y = centerY;
            
            addChild(canvas);
            
            //addChild(new Bitmap(canvas)).filters = [new BlurFilter(2, 2)];
            canvas.addChild(new Bitmap(canvasBitmap));
            addChild(myCenterDot);
            addChild(myArm1Dot);
            addChild(myArm2Dot);
            addChild(myArm3Dot);
            
            addEventListener(Event.ENTER_FRAME, onEnterFrame);
         
             initControls();
        }
        
        private function initControls():void
        {
            //myArm1LengthSlider = new HUISlider(this,0,0,Label,null);
            //this.addChild(myArm1LenghtSlider);
            
            myUIPanel = new Panel(this,0,stage.stageHeight-100);
            myUIPanel.color = 0x222222;
            myUIPanel.width = stage.stageWidth;
            myUIPanel.height = 100;
            myUIPanel.alpha = .75;
            
            
            myArm1LengthSlider = new HUISlider(myUIPanel,0,0,"1 L", updateArmProperties);
            myArm1LengthSlider.minimum = 1;
            myArm1LengthSlider.maximum = 200;
            myArm1LengthSlider.value = myArm1Dot.length;
            
            myArm1OmegaSlider = new HUISlider(myUIPanel,200,0,"1 O", updateArmProperties);
            myArm1OmegaSlider.minimum = 1;
            myArm1OmegaSlider.maximum = 10;
            myArm1OmegaSlider.value = myArm1Dot.omega;
            
            myArm2LengthSlider = new HUISlider(myUIPanel,0,20,"2 L", updateArmProperties);
            myArm2LengthSlider.minimum = 1;
            myArm2LengthSlider.maximum = 200;
            myArm2LengthSlider.value = myArm2Dot.length;
            
            myArm2OmegaSlider = new HUISlider(myUIPanel,200,20,"2 O", updateArmProperties);
            myArm2OmegaSlider.minimum = 1;
            myArm2OmegaSlider.maximum = 10;
            myArm2OmegaSlider.value = myArm1Dot.omega;
            
            myArm3LengthSlider = new HUISlider(myUIPanel,0,40,"3 L", updateArmProperties);
            myArm3LengthSlider.minimum = 1;
            myArm3LengthSlider.maximum = 200;
            myArm3LengthSlider.value = myArm3Dot.length;
            
            myArm3OmegaSlider = new HUISlider(myUIPanel,200,40,"3 O", updateArmProperties);
            myArm3OmegaSlider.minimum = 1;
            myArm3OmegaSlider.maximum = 10;
            myArm3OmegaSlider.value = myArm1Dot.omega;
            
            myArmWidthSlider = new HUISlider(myUIPanel,0,60,"Arm Width", updateArmProperties);
            myArmWidthSlider.minimum = 1;
            myArmWidthSlider.maximum = 32;
            myArmWidthSlider.value = lineWidth;
            
            myRandomizeColorsButton = new PushButton(myUIPanel,0,80,"Rand Colors", randomizeColors);
            myBlurToggleButton = new PushButton(myUIPanel,150,80,"Blur", toggleBlur);
            myResetButton = new PushButton(myUIPanel,300,80,"RESET", resetHandler);
             
            
        }
        
        private function resetHandler(e:Event):void
        {
            canvasBitmap.fillRect(canvasBitmap.rect,0xFF000000);
        }

        
        private function toggleBlur(e:Event):void
        {
            if(canvasIsBlurred == false)
            {
                canvas.filters = [new BlurFilter(2, 2)];
                canvasIsBlurred = true;
            }
            else {
                canvasIsBlurred = false;
                canvas.filters = [new BlurFilter(0, 0)];
            }

 
        }

        
        private function randomizeColors(e:Event):void
        {
            myArm1Dot.color = Math.random() * 0xFFFFFF;
            myArm2Dot.color = Math.random() * 0xFFFFFF;
            myArm3Dot.color = Math.random() * 0xFFFFFF;
        }

        
        private function updateArmProperties(e:Event):void
        {
            myArm1Dot.length = myArm1LengthSlider.value;
            myArm1Dot.omega = myArm1OmegaSlider.value;
            
            myArm2Dot.length = myArm2LengthSlider.value;
            myArm2Dot.omega = myArm2OmegaSlider.value;
            
            myArm3Dot.length = myArm3LengthSlider.value;
            myArm3Dot.omega = myArm3OmegaSlider.value;
            
            lineWidth = myArmWidthSlider.value;
        }


        
        private function onEnterFrame(e:Event):void
        {
            line.graphics.clear();
            line.graphics.moveTo(centerX, centerY);
            
            moveArm(myCenterDot, myArm1Dot);
            moveArm(myArm1Dot, myArm2Dot);
            moveArm(myArm2Dot, myArm3Dot);
            
            canvasBitmap.draw(line, null, null, BlendMode.ADD);
        }
        
        public function moveArm(from:MyArm, to:MyArm):void
        {
            var radian:Number = to.angle * D2R;
            
            to.x = from.x + to.length * Math.cos(radian);
            to.y = from.y + to.length * Math.sin(radian);
            
            line.graphics.lineStyle(lineWidth, to.color, 1/16);
            line.graphics.lineTo(to.x, to.y);
            
            to.angle += to.omega;
        }
    }
}

import flash.display.Shape;

class MyArm extends Shape
{
    public var length:Number;
    public var angle:Number;
    public var omega:Number;
    public var color:uint;
    
    public function MyArm(length:Number, angle:Number, omega:Number, color:uint)
    {
        this.length = length;
        this.angle  = angle;
        this.omega  = omega;
        this.color  = color;
        
        graphics.beginFill(color, 1);
        graphics.drawCircle(0, 0, 4);
    }
}
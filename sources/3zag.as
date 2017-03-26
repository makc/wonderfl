package
{
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.BlendMode;
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.filters.BlurFilter;
    
    [SWF(frameRate=60)]
    public class FlashTest extends Sprite
    {
        private const D2R:Number = Math.PI / 180;
        
        private var centerX:int = stage.stageWidth / 2;
        private var centerY:int = stage.stageWidth * 5 / 8;
        
        private var myCenterDot:MyArm = new MyArm(  0,   0, 0, 0xffffff);
        private var myArm1Dot:MyArm   = new MyArm( 75, 270, 1, 0xff0000);
        private var myArm2Dot:MyArm   = new MyArm(100, 270, 2, 0x00ff00);
        private var myArm3Dot:MyArm   = new MyArm(125, 270, 3, 0x0000ff);
        private var line:Shape        = new Shape();
        private var canvas:BitmapData = new BitmapData(stage.stageWidth, stage.stageHeight, false, 0x000000);
        
        public function FlashTest()
        {
            myCenterDot.x = centerX;
            myCenterDot.y = centerY;
            
            addChild(new Bitmap(canvas)).filters = [new BlurFilter(2, 2)];
            addChild(myCenterDot);
            addChild(myArm1Dot);
            addChild(myArm2Dot);
            addChild(myArm3Dot);
            
            addEventListener(Event.ENTER_FRAME, onEnterFrame);
        }
        
        private function onEnterFrame(e:Event):void
        {
            line.graphics.clear();
            line.graphics.moveTo(centerX, centerY);
            
            moveArm(myCenterDot, myArm1Dot);
            moveArm(myArm1Dot, myArm2Dot);
            moveArm(myArm2Dot, myArm3Dot);
            
            canvas.draw(line, null, null, BlendMode.ADD);
        }
        
        public function moveArm(from:MyArm, to:MyArm):void
        {
            var radian:Number = to.angle * D2R;
            
            to.x = from.x + to.length * Math.cos(radian);
            to.y = from.y + to.length * Math.sin(radian);
            
            line.graphics.lineStyle(2, to.color, 1/16);
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
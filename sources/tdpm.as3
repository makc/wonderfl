package {
    
    import flash.display.Sprite;
    import flash.events.Event;
    
    public class FlashTest extends Sprite {
        
        private var centerX:int = stage.stageWidth / 2;
        private var centerY:int = stage.stageWidth / 2;
        
        private var arm1X:int = 0;
        private var arm2Y:int = 0;
        
        private var arm1Length:int = 100;
        private var arm1Angle:Number = 0;
        private var arm1AngleChange:Number = 2;
        
        private var arm2Length:int = 100;
        private var arm2Angle:Number = 90;
        private var arm2AngleChange:Number = 4;
        
        private var arm3Length:int = 200;
        private var arm3Angle:Number = 180;
        private var arm3AngleChange:Number = 6;
        
        private var myCenterDot:Sprite = new Sprite();
        
        private var myArm1Dot:Sprite = new Sprite();
        private var myArm1Line:Sprite = new Sprite();
        
        private var myArm2Dot:Sprite = new Sprite();
        private var myArm2Line:Sprite = new Sprite();
        
        private var myArm3Dot:Sprite = new Sprite();
        private var myArm3Line:Sprite = new Sprite();
        
        public function FlashTest() {
            
            myCenterDot.graphics.beginFill(0x000000,1);
            myCenterDot.graphics.drawCircle(centerX,centerY,4);
            
            myArm1Dot.graphics.beginFill(0xFF0000,1);
            myArm1Dot.graphics.drawCircle(0,0,4);
            
            myArm2Dot.graphics.beginFill(0x00FF00,1);
            myArm2Dot.graphics.drawCircle(0,0,4);
            
            myArm3Dot.graphics.beginFill(0x0000FF,1);
            myArm3Dot.graphics.drawCircle(0,0,4);
            
            this.addChild(myCenterDot);
            
            this.addChild(myArm1Dot);
            this.addChild(myArm2Dot);
            this.addChild(myArm3Dot);
            
            addEventListener(Event.ENTER_FRAME, moveArm1);
            addEventListener(Event.EXIT_FRAME, moveArm2);
            addEventListener(Event.EXIT_FRAME, moveArm3);
            
        }
        
        public function moveArm1(e:Event):void{
            
            var radian:Number = degree2radian(arm1Angle);

            myArm1Dot.x = centerX + arm1Length * Math.cos(radian);
            myArm1Dot.y = centerY + arm1Length * Math.sin(radian);
            
            myArm1Line = new Sprite();
            myArm1Line.graphics.lineStyle(1,0xFF0000,.25);
            myArm1Line.graphics.moveTo(centerX,centerY);
            myArm1Line.graphics.lineTo(myArm1Dot.x,myArm1Dot.y);
            this.addChild(myArm1Line);
            
            arm1Angle += arm1AngleChange;
            arm1AngleChange %= 360;
            
        }
        
        public function moveArm2(e:Event):void{
            
            var radian:Number = degree2radian(arm2Angle);

            myArm2Dot.x = myArm1Dot.x + arm1Length * Math.cos(radian);
            myArm2Dot.y = myArm1Dot.y + arm1Length * Math.sin(radian);
            
            myArm2Line = new Sprite();
            myArm2Line.graphics.lineStyle(1,0x00FF00,.25);
            myArm2Line.graphics.moveTo(myArm1Dot.x,myArm1Dot.y);
            myArm2Line.graphics.lineTo(myArm2Dot.x,myArm2Dot.y);
            this.addChild(myArm2Line);
            
            arm2Angle += arm2AngleChange;
            arm2AngleChange %= 360;
            
        }
        
        public function moveArm3(e:Event):void{
            
            var radian:Number = degree2radian(arm3Angle);

            myArm3Dot.x = myArm2Dot.x + arm3Length * Math.cos(radian);
            myArm3Dot.y = myArm2Dot.y + arm3Length * Math.sin(radian);
            
            myArm3Line = new Sprite();
            myArm3Line.graphics.lineStyle(1,0x0000FF,.25);
            myArm3Line.graphics.moveTo(myArm2Dot.x,myArm2Dot.y);
            myArm3Line.graphics.lineTo(myArm3Dot.x,myArm3Dot.y);
            this.addChild(myArm3Line);
            
            arm3Angle += arm3AngleChange;
            arm3AngleChange %= 360;
            
        }
        
        public function degree2radian( whatDegree:Number ):Number{
            return whatDegree * (Math.PI / 180);
        }


        
        
    }
}
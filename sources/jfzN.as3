package
{
    
    import flash.display.MovieClip;
    import flash.display.Shape;
    import flash.display.Stage;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.text.TextField;
        [SWF(frameRate="60")] 
    public class Dots extends MovieClip
    {
        //コンテナ
        private var container:MovieClip;
        //噴出位置とリミット位置
        private var xLimit:Number;
        private var yLimit:Number;
        private var xAxis :Number;
        private var yAxis :Number;
        //色
        private var colors:Array = new Array("0xE89A0A", "0xE910DE", "0x0EEB10", "0xE9C010", "0xE2160F", "0xD6EB0B", "0xEB117C", "0xE81167", "0x7E11E8");
        //クリックで切り替え
        private var clickFlug:Boolean = false;
        
        public function Dots()
        {
           addEventListener(Event.ADDED_TO_STAGE, onAddedStage);
        }
        
        private function onAddedStage(e:Event):void 
        {
            removeEventListener(Event.ADDED_TO_STAGE, onAddedStage);
            stage.addEventListener (MouseEvent.MOUSE_DOWN, _onMouseDown);
            stage.addEventListener (MouseEvent.MOUSE_MOVE, _onMouseMove);
            
            container = new MovieClip();
            addChild (container);
            
            xLimit = stage.stageWidth * 2;
            yLimit = stage.stageHeight * 2;
            xAxis  = stage.mouseX;
            yAxis  = stage.mouseY;
            
            var textField:TextField=new TextField();
            textField.text="クリックしてね";
            addChild(textField);
        }
        private function _onMouseDown (e:Event):void
        {
            addEventListener(Event.ENTER_FRAME, _onEnterFrame);
            stage.addEventListener(MouseEvent.MOUSE_UP, _onMouseUp);
            clickFlug = ! clickFlug
        }
        private function _onMouseUp (e:Event):void
        {
            removeEventListener(Event.ENTER_FRAME, _onEnterFrame);
            stage.removeEventListener(MouseEvent.MOUSE_UP, _onMouseUp);
        }
        private function _onMouseMove (e:Event):void
        {
            xAxis = stage.mouseX;
            yAxis = stage.mouseY;
        }
        private function _onEnterFrame(e:Event):void
        {
            createClip (container, xAxis, yAxis);
        }
        
        private function createClip (a:MovieClip, b:Number, c:Number):void
        {
            //ランダムな数値
            var value1:Number = Math.floor(Math.random() * 10);
            var value2:Number = Math.floor(Math.random() * 10);
            var value3:Number = Math.floor(Math.random() * 10);
            //速さ [X軸,Y軸,回転]
            var xSpeed:Number = value1 - value2;
            var ySpeed:Number = value3 - 10;
            var ratationSpeed:Number =10;
            if (clickFlug)
            {
                xSpeed = value1 - value2;
                ySpeed = value3 - 10;
                ratationSpeed =10;
            }
            else
            {
                xSpeed = 1;
                ySpeed = -10;
                ratationSpeed =10;
            }
            //減速率 [X軸,Y軸,回転]
            var xDeceleration:Number = 0.98;
            var yDeceleration:Number = 0.98;
            var rotationDeceleration:Number = 0.98;
            //重力
            var gravity:Number = 0.35;
            var ms:Number = 0.98;
            var sc:Number = 0.25;
            var sa:Number = 0.05 * Math.random ();
            //shape生成と
            var shape:Shape = new Shape();
            a.addChild(shape);
            shape.graphics.beginFill(0xf00000 * Math.random());
            shape.graphics.drawCircle(0, 0, 10);
            shape.graphics.endFill();
            shape.x = b;
            shape.y = c;
            shape.rotation = 30;
            shape.alpha=0;
            //流れ落ちる動き
            shape.addEventListener (Event.ENTER_FRAME,__onEnterFrame);
            function __onEnterFrame (e:Event):void
            {
                shape.alpha=1;
                xSpeed = xSpeed * xDeceleration;
                ySpeed = ySpeed * yDeceleration + gravity;
                ratationSpeed = ratationSpeed * rotationDeceleration;
                e.target.x = e.target.x + xSpeed;
                e.target.y = e.target.y + ySpeed;
                e.target.rotation = e.target.rotation + ratationSpeed;
                sc = sc + sa;
                e.target.scaleX = 1 * Math.sin (3.141593 * sc);
                e.target.scaleY = 1 * Math.cos (3.141593 * sc);
                if (e.target.x + 100 > xLimit || e.target.y + 100 > yLimit )
                {
                    e.target.alpha = Math.round (yLimit - e.target.y);
                    if (e.target.alpha<=0)
                    {
                        shape.removeEventListener (Event.ENTER_FRAME, __onEnterFrame);
                        removeMC ();
                    }
                }
            }
            function removeMC ():void
            {
                a.removeChild (shape);
            }
        }
        private function randomInt(max:int,min:int):int
        {
            var value:int = min + Math.floor(Math.random() * (max - min));
            return value;
        }
    }
}
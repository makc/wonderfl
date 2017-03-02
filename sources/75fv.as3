/*
    マウスから逃げます。
*/
package
{
    import flash.display.BlendMode;
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.filters.BlurFilter;
    
    [SWF(width="465", height="465", backgroundColor="0x000000", frameRate="40")]    
    public class Main extends Sprite
    {
        private static const num:int=500;
        private var firstPointX:Array;
        private var firstPointY:Array;
        private var circles:Array;
        
        public function Main()
        {
            firstPointX = [];
            firstPointY = [];
            circles = [];
            for(var i:int=0; i < num; i++)
            {
                var circle:Shape=addChild(new Shape) as Shape;
                circle.graphics.beginFill(Math.random() * 0xFFFFFF);
                circle.graphics.drawCircle(0, 0, Math.random() * 18 + 5);
                circle.graphics.endFill();
                circle.blendMode=BlendMode.ADD;
                
                circle.x=Math.round(Math.random() * stage.stageWidth);
                circle.y=Math.round(Math.random() * stage.stageHeight);
                circle.name="circle" + i.toString();
                circle.filters=[new BlurFilter(10, 10, 1)];
                circles[i] = circle;
                
                firstPointX[i]=circle.x;
                firstPointY[i]=circle.y;
            }
            
            addEventListener(Event.ENTER_FRAME, onFrame);
        }
        
        
        public function onFrame(e:Event):void
        {
            for(var i:int=0; i < num; i++)
            {
                var circle:Shape= circles[i] as Shape;
                var theta:Number=Math.atan2(circle.y - mouseY, circle.x - mouseX);
                var d:Number=1000 / Math.sqrt(Math.pow(mouseX - circle.x, 2) + Math.pow(mouseY - circle.y, 2));
                
                circle.x+=d * Math.cos(theta) + (firstPointX[i] - circle.x) * 0.1;
                circle.y+=d * Math.sin(theta) + (firstPointY[i] - circle.y) * 0.1;
            }
        }
    }
}


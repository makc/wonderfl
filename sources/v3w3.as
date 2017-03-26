package
{
    import com.bit101.components.Panel;
    import com.bit101.components.PushButton;
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.geom.Rectangle;
    
    public class Main extends Sprite
    {
        private const DIR:Array = 
        [
            [ 1,  0],
            [-1,  0],
            [ 0,  1],
            [ 0, -1]
        ];
        
        private var panel:Panel;
        private var bmd:BitmapData;
        private var bitmap:Bitmap;
        private var list:Array = new Array();
        
        public function Main()
        {
            panel = new Panel(this);
            panel.width = panel.height = 465;
            
            stage.frameRate = 25;
            bmd = new BitmapData(305, 305, false, Status.FIELD);
            
            
            bitmap = new Bitmap(bmd);
            bitmap.scaleX = bitmap.scaleY = 1;
            bitmap.x = (465 - bitmap.width) / 2;
            panel.content.addChild(bitmap);
            
            var button2:PushButton = new PushButton(panel.content, 182, 310, "anahori", dig1);
        }
        
        private function dig1(event:Event = null):void
        {
            list = new Array();
            bmd = new BitmapData(305, 305, false, Status.FIELD);
            bmd.fillRect(new Rectangle(1, 1, bmd.width - 2, bmd.height - 2), Status.WALL);
            
            bitmap.bitmapData = bmd;
            
            var px:int = int(Math.random() * (bmd.width - 3) / 2) * 2 + 2;
            var py:int = int(Math.random() * (bmd.width - 3) / 2) * 2 + 2;
            
            bmd.setPixel(px, py, Status.FIELD);

            var random:Array = shakedIntegers(4);
            list.push([px, py], random);
            
            addEventListener(Event.ENTER_FRAME, loop);
        }
        
        private function loop(e:Event):void 
        {
            var date:Date = new Date();
            do
            {
                if (list.length == 0)
                {
                    trace("END");
                    removeEventListener(Event.ENTER_FRAME, loop);
                    break;
                }
                _dig1();
            }while (new Date().time - date.time < 40);
        }
        
        private function _dig1():void
        {
            var len:int = list.length;
            var random:int = list[len - 1].pop();
            var pos:Array = list[len - 2];
            
            if (bmd.getPixel(pos[0] + DIR[random][0] * 2, pos[1] + DIR[random][1] * 2) == Status.WALL)
            {
                bmd.setPixel(pos[0] + DIR[random][0], pos[1] + DIR[random][1], Status.FIELD);
                bmd.setPixel(pos[0] + DIR[random][0] * 2, pos[1] + DIR[random][1] * 2, Status.FIELD);
                
                list.push([pos[0] + DIR[random][0] * 2, pos[1] + DIR[random][1] * 2], shakedIntegers(4));
            }
            else if(list[len - 1].length == 0)
            {
                list.pop();
                list.pop();
            }
        }
        
        private function shakedIntegers(size:int):Array
        {
            var arr:Array = new Array(size);
            for ( var i:int = 0; i < size; i++ )
                arr[i] = i;
                
            var temp:int;
            while(--size)
            {
                i = Math.random()*(size+1);
                temp = arr[size];
                arr[size] = arr[i];
                arr[i] = temp;
            }
            return arr;
        }
    }
}

class Status
{
    public static const FIELD:int = 0xF3F3F3;
    public static const WALL:int = 0x393939;
}
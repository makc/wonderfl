package
{
    import flash.display.Sprite;
    import flash.text.TextField;
    import flash.text.TextFormat;
 
    public class Main extends Sprite
    {
        private const WIDTH:int = 50;
        private const HEIGHT:int = 50;
        private var map/*Array*/:Array;
        
        public function Main()
        {
            map = [];
            for (var y:int = 0; y < HEIGHT; y++)
            {
                map[y] = [];
                for (var x:int = 0; x < WIDTH; x++)
                {
                    map[y][x] = " ";
                }
            }
            
            var partitions/*Rect*/:Array = split(new Rect(0, 0, WIDTH - 1, HEIGHT - 1));
            var rooms/*Rect*/:Array = [];
            for (var i:int = 0; i < partitions.length; i++)
            {
                rooms.push(createRoom(partitions[i]));
                //fill(partitions[i], ".");
                fill(rooms[i], "*");
            }
            
            makeCorridor(partitions, rooms);
            
            var tf:TextField = new TextField();
            var format:TextFormat = new TextFormat("_typeWriter", 12, 0x0, true);
            format.leading = -8;
            tf.defaultTextFormat = format;
            tf.autoSize = "left";
            addChild(tf);
            
            for (i = 0; i < map.length; i++)
            {
                tf.appendText(map[i].join("") + "\n");
            }
        }
        
        private function createRoom(rect:Rect):Rect
        {
            const MIN_SIZE:int = 6;
            
            var width:int = MIN_SIZE + getIntRandom(rect.width - MIN_SIZE - 2);
            var height:int = MIN_SIZE + getIntRandom(rect.height - MIN_SIZE - 2);
            
            var startX:int = rect.left + 1 + getIntRandom(rect.width - width - 2);
            var startY:int = rect.top + 1 + getIntRandom(rect.height - height - 2);
            
            return new Rect(startX, startY, startX + width - 1, startY + height - 1);
        }
        
        private function fill(rect:Rect, char:String):void
        {
            var minY:int = Math.min(rect.top, rect.bottom);
            var maxY:int = Math.max(rect.top, rect.bottom);
            
            var minX:int = Math.min(rect.left, rect.right);
            var maxX:int = Math.max(rect.left, rect.right);
            
            for (var y:int = minY; y <= maxY; y++)
            {
                for (var x:int = minX; x <= maxX; x++)
                {
                    map[y][x] = char;
                }
            }
        }
        
        private function makeCorridor(partitions/*Rect*/:Array, rooms/*Rect*/:Array):void
        {
            var list/*Array*/:Array = [];
            for (var i:int = 0; i < partitions.length - 1; i++)
            {
                list.push([i, i + 1]);
            }
            
            list.forEach
            (
                function(item:Array, ...args):void
                {
                    connect(partitions[item[0]], partitions[item[1]], rooms[item[0]], rooms[item[1]]);
                }
            );
        }
        
        private function connect(part0:Rect, part1:Rect, room0:Rect, room1:Rect):void
        {
            var char:String = "+";
            var posA:int;
            var posB:int;
            
            // 縦に分割している場合
            if (part0.bottom + 1 == part1.top - 1)
            {
                posA = room0.left + getIntRandom(room0.width - 1);
                posB = room1.left + getIntRandom(room1.width - 1);
                
                fill(new Rect(posA, room0.bottom + 1, posA, part0.bottom + 1), char);
                fill(new Rect(posB, room1.top - 1, posB, part1.top - 1), char);
                fill(new Rect(posA, part0.bottom + 1, posB, part1.top - 1), char);
            }
            // 横に分割している場合
            else if (part0.right + 1 == part1.left - 1)
            {
                posA = room0.top + getIntRandom(room0.height - 1);
                posB = room1.top + getIntRandom(room1.height - 1);
                
                fill(new Rect(room0.right + 1, posA, part0.right + 1, posA), char);
                fill(new Rect(room1.left - 1, posB, part1.left - 1, posB), char);
                fill(new Rect(part0.right + 1, posA, part1.left - 1, posB), char);
            }
        }
        
        private function split(rect:Rect, ...args):Array
        {
            const MIN_SIZE:int = 8;
            
            if (rect.height < MIN_SIZE * 2 + 1 ||
                rect.width    < MIN_SIZE * 2 + 1)
            {
                return [rect];
            }
            
            var rectA:Rect;
            var rectB:Rect;
            
            var dirSplitFlag:Boolean = true; // true = 縦に分割, false = 横に分割
            if (rect.height < MIN_SIZE * 2 + 1) dirSplitFlag = false;
            else if (rect.width < MIN_SIZE * 2 + 1) dirSplitFlag = true;
            else dirSplitFlag = (rect.width < rect.height) ? true : false;
            
            // 縦に分割
            if (dirSplitFlag)
            {
                var height:int = rect.top + (MIN_SIZE - 1) + getIntRandom(rect.height - MIN_SIZE * 2 - 1);
                rectA = new Rect(rect.left, rect.top, rect.right, height);
                rectB = new Rect(rect.left, height + 2, rect.right, rect.bottom);
            }
            // 横に分割
            else
            {
                var width:int = rect.left + (MIN_SIZE - 1) + getIntRandom(rect.width - MIN_SIZE * 2 - 1);
                rectA = new Rect(rect.left, rect.top, width, rect.bottom);
                rectB = new Rect(width + 2, rect.top, rect.right, rect.bottom)
            }
            
            return flatten([rectA, rectB].map(split));
        }
        
        private function getIntRandom(n:int):int
        {
            n += (n < 0) ? -1 : 1;
            return n * Math.random();
        }
        
        private function flatten(data:Array):Array
        {
            var src:Array = data.slice();
            var dest:Array = [];
            
            while (true)
            {
                var element:* = src.shift();
                if (element == undefined) break;
                else if (element is Array) src = src.concat(element);
                else dest.push(element);
            }
            
            return dest;
        }
    }
}

class Rect
{
    public var left:int;
    public var top:int;
    public var right:int;
    public var bottom:int;
    
    public function Rect(left:int = 0, top:int = 0, right:int = 0, bottom:int = 0):void
    {
        this.left = left;
        this.top = top;
        this.right = right;
        this.bottom = bottom;
    }
    
    public function get height():int
    {
        return bottom - top + 1;
    }
    
    public function get width():int
    {
        return right - left + 1;
    }
}
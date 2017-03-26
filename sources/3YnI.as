package
{
    import flash.events.Event;
    import flash.geom.Point;
    import flash.display.Sprite;
    
    public class LineThing extends Sprite
    {
        public var points:Array = [new Point, new Point, new Point, new Point];
        public var mids:Array = [new Point, new Point, new Point, new Point];
        public var speeds:Array = [];
        
        public function LineThing()
        {
            for each (var p:Point in points)
            {
                p.x = Math.random() * stage.stageWidth;
                p.y = Math.random() * stage.stageHeight;
                speeds.push(Point.polar(5, Math.random() * Math.PI * 2));
            }
            
            addEventListener(Event.ENTER_FRAME, update);
        }
        
        public function update(e:Event):void
        {
            var i:int;
            
            for (i = 0; i < points.length; i++)
            {
                points[i].x += speeds[i].x;
                points[i].y += speeds[i].y;
                
                if (points[i].x < 0)
                    speeds[i].x = Math.abs(speeds[i].x);
                if (points[i].y < 0)
                    speeds[i].y = Math.abs(speeds[i].y);
                if (points[i].x > stage.stageWidth)
                    speeds[i].x = -Math.abs(speeds[i].x);
                if (points[i].y > stage.stageHeight)
                    speeds[i].y = -Math.abs(speeds[i].y);
            }
            
            for (i = 0; i < points.length; i++)
            {
                var j:int = (i + 1) % points.length;
                mids[i].x = (points[i].x + points[j].x) / 2;
                mids[i].y = (points[i].y + points[j].y) / 2;
            }
            
            graphics.clear();
            drawLines(points, 0xFF0000, 1);
            drawLines(mids, 0x0000FF, 2);
        }
        
        public function drawLines(points:Array, color:uint, thickness:Number):void
        {
            graphics.lineStyle(thickness, color);
            graphics.moveTo(points[points.length-1].x, points[points.length-1].y);
            for (var i:int = 0; i < points.length; i++)
                graphics.lineTo(points[i].x, points[i].y);
            graphics.lineStyle();
            graphics.beginFill(color);
            for (i = 0; i < points.length; i++)
                graphics.drawCircle(points[i].x, points[i].y, thickness * 2);
            graphics.endFill();
        }
    }
}
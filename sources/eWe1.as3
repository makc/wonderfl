package {
    import flash.display.Sprite;
    import flash.geom.Point;
    
    public class FlashTest extends Sprite {
        private var a:Point = new Point(100, 250);
        private var b:Point = new Point(200, 0);
        private var c:Point = new Point(400, 300);
        
        public function FlashTest() {
            graphics.lineStyle(1);
            graphics.moveTo(a.x, a.y);
            graphics.curveTo(b.x, b.y, c.x, c.y);
            
            for (var t:Number=0; t<1; t+=0.04) {
                var d:Point = Point.interpolate(b, a, t);
                var e:Point = Point.interpolate(c, b, t);
                var f:Point = Point.interpolate(e, d, t);
                graphics.drawCircle(f.x, f.y, 3);
            }
        }
    }
}
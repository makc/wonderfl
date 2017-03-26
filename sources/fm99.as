package {
    import flash.display.*;
    import flash.events.Event;
    import flash.geom.Point;
    [SWF(width=465, height=465, backgroundColor=0x000000, frameRate=60)]
    public class Liquid extends Sprite {
        private const NUM_OF_PARTICLES: int = 1000000;
       




























        // 冗談です
        
        
        public function Liquid() {
            var screen:BitmapData = new BitmapData(465, 465, false, 0x000000);
            var offset:Array = [new Point(), new Point()];
            addChild(new Bitmap(screen));
            addEventListener(Event.ENTER_FRAME, function (event:Event):void {
                offset[0].x += 3; offset[1].y += 3;
                screen.perlinNoise(100, 100, 2, 0, false, true, 3, false, offset);
            });
        } 
    }
}


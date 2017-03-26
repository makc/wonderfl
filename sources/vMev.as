package {
    import flash.display.*;
    public class FlashTest extends Sprite {
        public function FlashTest() {
            var a:BitmapData = new BitmapData(465, 465, true);
            a.perlinNoise(100, 100, 5, 12345, true, true, 7, true);
            addChild(new Bitmap(a));
            
            var b:BitmapData = a.clone();
            addChild(new Bitmap(b));
            addEventListener("enterFrame", function(...right):void {
                b.threshold(a, a.rect, a.rect.topLeft, "<", Math.min(255, Math.max(0, mouseX * 0.5483 + 5)), 0xFFFF7700, 0xFF, true);
                b.threshold(a, a.rect, a.rect.topLeft, "<", Math.min(255, Math.max(0, mouseX * 0.5483 - 5)), 0x33FF7700, 0xFF, false);
            });            
        }
    }
}
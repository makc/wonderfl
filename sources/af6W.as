package {
    import flash.text.TextFormat;
    import flash.text.TextField;
    import flash.display.Shape;
    import flash.events.Event;
    import flash.filters.BlurFilter;
    import flash.geom.Matrix;
    import flash.display.Sprite;
    import flash.display.BitmapData;
    import flash.display.Bitmap;
    
    [SWF(backgroundColor="#000000", frameRate="60", width="465", height="465")]
    public class FlashTest extends Sprite {
        public function FlashTest() {
            // write as3 code here..
            for(var x:Number=0;x<6;x++) {
                for(var y:Number=0;y<6;y++) {
                    map.graphics.beginFill(0);
                    map.graphics.drawCircle(50 + 100 * x, 50 + 100 * y, 40);
                    map.graphics.endFill();
                }

            }
            
            var bg:Shape = new Shape();
            bg.graphics.beginFill(0);
            bg.graphics.drawRect(0, 0, size, size);
            bg.graphics.endFill();
            stage.addChild(bg);
            stage.addChild(map);
            stage.addChild(bitmap);

            stage.addEventListener(Event.ENTER_FRAME, updateHandler);
        }
        
        private var count:Number=1;
        private function updateHandler(event:Event):void
        {
            var src_x:Number = Math.floor(stage.mouseX / 465 / 2);
            var src_y:Number = Math.floor(stage.mouseY / 465 / 2);
            
            var colors:Array = [0x100c08, 0x0];
            var alphas:Array = [1, 0];
            var ratios:Array = [0, 255];
            matrix.createGradientBox(465, 465, 0, (size - stage.mouseX)/4,  (size - stage.mouseY)/4);
            with(gradient.graphics) {
                clear();
                beginGradientFill("radial", colors, alphas, ratios, matrix);
                drawRect(0, 0, size, size);
                endFill();
            }
            with(source) {
                fillRect(source.rect, 0);
                draw(gradient);
                draw(map, null, null, "erase");
            }
            
            bitmap.bitmapData = light(source, -1 * src_x, -1 * src_y);
        }

        
        private function light(src:BitmapData, sx:Number, sy:Number):BitmapData
        {
            matrix.identity();
            matrix.translate(-465 * 1/512, -465 * 1/512);
            matrix.translate(sx, sy);
            matrix.scale(257/256, 257/256);
        
            for(var i:Number=7;i>0;i--) {
                matrix.concat(matrix);
                target.copyPixels(source, source.rect, source.rect.topLeft);
                target.draw(source, matrix, null, "add");
                target.applyFilter(target, target.rect, target.rect.topLeft, blue);
                
                var temp:BitmapData = target;
                target = source;
                source = temp;
            }
           
            return source;
        }
        
        private var map:Shape = new Shape();
        private var gradient:Shape = new Shape();
        private var size:Number = 465;
        private var base:BitmapData = new BitmapData(size, size, true, 0);
        private var source:BitmapData = new BitmapData(size, size, true, 0);
        private var canvas:BitmapData = new BitmapData(size, size, true, 0);
        private var bitmap:Bitmap = new Bitmap(canvas);
        private var matrix:Matrix = new Matrix();
        private var blue:BlurFilter = new BlurFilter();
        
        private var target:BitmapData = new BitmapData(size, size, true, 0);
    }
}
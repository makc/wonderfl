// forked from http://zozuar.org/las3rfl/node/97

package {
    import flash.display.*;
    import flash.filters.*;
    import flash.geom.*;
    import flash.utils.*;
    import net.hires.debug.Stats;

    [SWF(width="465", height="465", frameRate="60")]
    public class LightEffect extends Sprite {
        private static const SIZE:int = 465;
        private var base:BitmapData = new BitmapData(SIZE, SIZE, false, 0);
        private var rot:BitmapData  = new BitmapData(SIZE, SIZE, false, 0);
        private var canvas:Bitmap = new Bitmap(base);
        private var mtx:Matrix = new Matrix;
        private var blur:BlurFilter = new BlurFilter;
        private var stats:Stats = new Stats;

        public function LightEffect() {
            graphics.beginFill(0);
            graphics.drawRect(0, 0, SIZE, SIZE);
            graphics.endFill();
            addChild(canvas);
            addChild(stats);
            stats.visible = false;

            var c:uint;
            var r:Rectangle = new Rectangle(0, 0, 32, 32);
            for(var x:int = 0; x < 5; x++) {
                for(var y:int = 0; y < 5; y++) {
                    c = 1 | x*0x100 | y*0x10000;
                    r.x = 456/4 + x*50;
                    r.y = 456/4 + y*50;
                    base.fillRect(r, c);
                }
            }
            addEventListener("enterFrame", frameHandler);
            stage.addEventListener("click", function(e:*):void { stats.visible = !stats.visible });
        }

        private var dst:BitmapData = new BitmapData(SIZE, SIZE, false, 0);
        private function process(src:BitmapData, cx:Number, cy:Number):BitmapData {
            var dst:BitmapData = this.dst;
            mtx.identity();
            mtx.translate(-SIZE * 1/512, -SIZE * 1/512);
            mtx.translate(cx, cy);
            mtx.scale(257/256, 257/256);
            var cnt:int = 8;
            var tmp:BitmapData;
            src.lock(); dst.lock();
            while(cnt--) {
                mtx.concat(mtx);
                dst.copyPixels(src, src.rect, src.rect.topLeft);
                dst.draw(src, mtx, null, "add");
                dst.applyFilter(dst, dst.rect, dst.rect.topLeft, blur);
                tmp = src;
                src = dst;
                dst = tmp;
            }
            src.unlock(); dst.unlock();
            return src;
        }

        private function frameHandler(e:*):void {
            mtx.identity();
            mtx.translate(-SIZE/2, -SIZE/2);
            mtx.rotate(getTimer() / 1000);
            mtx.translate(SIZE/2, SIZE/2);
            rot.fillRect(rot.rect, 0);
            rot.draw(base, mtx);
            canvas.bitmapData = process(rot, 0.5 - mouseX/SIZE, 0.5 - mouseY/SIZE);
        }
    }
}
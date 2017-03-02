package {
    import flash.display.*;
    import flash.events.*;
    import flash.geom.*;
    public class FlashTest extends Sprite {
        
        private static const INNER:Number = 12;
        private static const OUTER:Number = 16;
        private static const FAR_OUT:int = 18;
        
        private var w:int;
        private var h:int;
        private var drawing:Boolean;
        private var mx:Number;
        private var my:Number;
        private var fx:int;
        private var fy:int;
        private var back:BitmapData;
        private var middle:BitmapData;
        private var front:BitmapData;
        private var mb:Bitmap;
        private var fb:Bitmap;
        private var periphery:Shape;
        private var core:Shape;
        private var m:Matrix;
        private var r:Rectangle;
        
        public function FlashTest() {
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
            stage.quality = StageQuality.LOW;
            stage.frameRate = 1;
            
            w = stage.stageWidth;
            h = stage.stageHeight;
            
            drawing = false;
            mx = 0;
            my = 0;
            fx = 0;
            fy = 0;
            
            back = new BitmapData(w, h, false, 0x404040);
            middle = new BitmapData(2 * FAR_OUT, 2 * FAR_OUT, true, 0x00000000);
            front = new BitmapData(2 * FAR_OUT, 2 * FAR_OUT, true, 0x00000000);
            mb = new Bitmap(middle);
            fb = new Bitmap(front);
            addChild(new Bitmap(back));
            addChild(mb);
            addChild(fb);
            
            periphery = new Shape();
            core = new Shape();
            m = new Matrix();
            r = new Rectangle();
            
            stage.addEventListener(MouseEvent.MOUSE_DOWN, down);
            stage.addEventListener(MouseEvent.MOUSE_UP, up);
            stage.addEventListener(MouseEvent.MOUSE_MOVE, move);
        }
        
        private function down(e:MouseEvent):void {
            drawing = true;
            mx = e.stageX;
            my = e.stageY;
        }
        
        private function up(e:MouseEvent):void {
            drawing = false;
            mx = 0;
            my = 0;
            
            m.tx = fx;
            m.ty = fy;
            back.lock();
            back.draw(middle, m);
            back.draw(front, m);
            back.draw(periphery);
            back.draw(core);
            back.unlock();
            
            middle.fillRect(middle.rect, 0x00000000);
            front.fillRect(front.rect, 0x00000000);
            
            fx = 0;
            fy = 0;
            
            e.updateAfterEvent();
        }
        
        private function move(e:MouseEvent):void {
            if (!drawing) return;
            
            var x:Number = e.stageX;
            var y:Number = e.stageY;
            periphery.graphics.lineStyle(2 * OUTER, 0x000000, 1.0, false, LineScaleMode.NORMAL, CapsStyle.ROUND);
            periphery.graphics.moveTo(mx, my);
            periphery.graphics.lineTo(x, y);
            core.graphics.lineStyle(2 * INNER, 0xffffff, 1.0, false, LineScaleMode.NORMAL, CapsStyle.ROUND);
            core.graphics.moveTo(mx, my);
            core.graphics.lineTo(x, y);
            
            m.tx = fx;
            m.ty = fy;
            back.lock();
            back.draw(periphery);
            back.draw(middle, m);
            back.draw(front, m);
            back.draw(core);
            back.unlock();
            
            var fx1:int = x - FAR_OUT;
            var fy1:int = y - FAR_OUT;
            
            m.tx = -fx1;
            m.ty = -fy1;
            middle.lock();
            scroll2(middle, fx - fx1, fy - fy1);
            middle.draw(periphery, m);
            middle.unlock();
            front.lock();
            scroll2(front, fx - fx1, fy - fy1);
            front.draw(core, m);
            front.unlock();
            mb.x = fx1;
            mb.y = fy1;
            fb.x = fx1;
            fb.y = fy1;
            
            fx = fx1;
            fy = fy1;
            
            periphery.graphics.clear();
            core.graphics.clear();
            
            mx = x;
            my = y;
            
            e.updateAfterEvent();
        }
        
        private function scroll2(bd:BitmapData, dx:int, dy:int):void {
            bd.scroll(dx, dy);
            
            if (dx < 0) {
                r.setTo(bd.width + dx, 0, -dx, bd.height);
                bd.fillRect(r, 0x00000000);
            } else if (dx > 0) {
                r.setTo(0, 0, dx, bd.height);
                bd.fillRect(r, 0x00000000);
            }
            
            if (dy < 0) {
                r.setTo(0, bd.height + dy, bd.width, -dy);
                bd.fillRect(r, 0x00000000);
            } else if (dy > 0) {
                r.setTo(0, 0, bd.width, dy);
                bd.fillRect(r, 0x00000000);
            }
        }
        
    }
}
package {
    import flash.events.Event;
    import flash.display.Sprite;
    public class FlashTest extends Sprite {
        
        public function FlashTest() {
            stage.frameRate = 60;
            graphics.beginFill(0x000000);
            graphics.drawRect(0, 0, 465, 465);
            addEventListener(Event.ENTER_FRAME, frame);
        }
        
        private function frame(e:Event):void {
            addChild(new Dot());
        }
        
    }
}

import flash.display.*;
import flash.events.*;
import flash.filters.*;
import flash.geom.*;
internal class Dot extends Shape {
    
    private static const bf:BlurFilter = new BlurFilter(0, 0, BitmapFilterQuality.HIGH);
    private static const map:BitmapData = prepareMap();
    
    private static function prepareMap():BitmapData {
        var map:BitmapData = new BitmapData(256, 1, false, 0x000000);
        var sh:Shape = new Shape();
        sh.graphics.beginGradientFill(
            GradientType.LINEAR,
            [0xffffc0, 0xffcf00, 0xc00000, 0x000000],
            [       1,        1,        1,        1],
            [       8,       32,      128,      255],
            new Matrix(-256 * 10. / 0x4000, 0, 0, 1, 128, 0)
        );
        sh.graphics.drawRect(0, 0, 256, 1);
        map.draw(sh);
        return map;
    }
    
    private var vx:Number;
    private var vy:Number;
    private var vz:Number;
    private var px:Number;
    private var py:Number;
    private var pz:Number;
    private var energy:int;
    
    public function Dot() {
        vz = Math.random() * 0.04 - 0.03;
        vy = Math.random() * 0.04 - 0.02;
        vx = Math.random() * 0.04 - 0.02;
        px = Math.random() * 0.1 - 0.05;
        py = Math.random() * 0.1 + 0.45;
        pz = 0.5;
        energy = Math.min(255, 255 - Math.random() * Math.random() * 40);
        blendMode = BlendMode.ADD;
        alpha = 0;
        addEventListener(Event.ENTER_FRAME, frame);
    }
    
    private function frame(e:Event):void {
        var w:Number = pz + 1;
        if (energy <= 0 || w < 0) {
            removeEventListener(Event.ENTER_FRAME, frame);
            parent.removeChild(this);
            return;
        }
        
        graphics.clear();
        graphics.lineStyle(
            8 / w,
            map.getPixel(energy, 0),
            1,
            false,
            LineScaleMode.NORMAL,
            CapsStyle.ROUND
        );
        bf.blurX = bf.blurY = Math.abs(12 * pz / w);
        filters = [bf];
        if (alpha < 1) alpha += 0.125;
        
        graphics.moveTo(
            (px / w + 1) * 232.5,
            465 - (py / w + 1) * 232.5
        );
        
        px += vx;
        py += vy;
        pz += vz;
        w = pz + 1;
        vy -= 0.005;
        if (py < -0.5 && vy < 0) {
            vy = -0.3 * vy;
            py = -0.5;
            vx *= 0.7;
            vz *= 0.7;
            energy *= 0.9;
        } else {
            --energy;
        }
        
        graphics.lineTo(
            (px / w + 1) * 232.5,
            465 - (py / w + 1) * 232.5
        );
    }
    
}
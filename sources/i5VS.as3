package {
    
    import flash.display.Sprite;
    
    [SWF(width=465, height=465, backgroundColor=0xffffff, frameRate=120)]

    public class GradationTest1 extends Sprite {
        
        public function GradationTest1() {
            // Gradationクラスを作る。任意の数のカラー値を渡すことができる。
            var grad:Gradation = new Gradation(0xff0000, 0x00ff00, 0x0000ff);
            for (var y:int = 0; y < 465; y++) {
                // getColorでグラデーションを構成する中間色を取り出す。渡す値は0〜1。滑らかにこの値を変化させることでグラデーションを作り出す。
                graphics.beginFill(grad.getColor(y / 464));
                graphics.drawRect(0, y, 465, 1);
                graphics.endFill();
            }
        }
    }
}


import frocessing.color.ColorLerp;

import org.libspark.betweenas3.core.easing.IEasing;
import org.libspark.betweenas3.easing.Linear;

class Gradation {
    
    private var _colors:Array;
    private var _easing:IEasing;
    
    public function Gradation(...args) {
        _colors = args.concat();
        _easing = Linear.linear;
    }
    
    public function setEasing(easing:IEasing):void {
        _easing = easing;
    }
    
    public function getColor(position:Number):uint {
        position = (position < 0 ? 0 : position > 1 ? 1 : position) * (_colors.length - 1);
        var idx:int = position;
        var alpha:Number = _easing.calculate(position - idx, 0, 1, 1);
        if (alpha == 0) {
            return _colors[idx];
        } else {
            return ColorLerp.lerp(_colors[idx], _colors[idx + 1], alpha);
        }
    }
}
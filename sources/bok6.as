////////////////////////////////////////////////////////////////////////////////
// Ball
////////////////////////////////////////////////////////////////////////////////

package {

    import flash.display.Sprite;
    import flash.display.Shape;
    import flash.geom.Rectangle;

    [SWF(backgroundColor="#EEEEEE", width="465", height="465", frameRate="30")]

    public class Main extends Sprite {
        private static var radius:uint = 160;

        public function Main() {
            init();
        }

        private function init():void {
            var ball:Ball = new Ball(radius, 0x3366CC);
            addChild(ball);
            ball.x = 232;
            ball.y = 232;
        }

    }

}


//////////////////////////////////////////////////
// Ballクラス
//////////////////////////////////////////////////

import flash.display.Sprite;
import flash.display.Shape;
import flash.filters.DropShadowFilter;
import flash.filters.GlowFilter;
import flash.geom.Matrix;
import flash.display.GradientType;
import flash.display.SpreadMethod;
import flash.display.InterpolationMethod;
import flash.display.BlendMode;

class Ball extends Sprite {
    private var radius:uint;
    private var color:uint;
    private var ball:Sprite;
    private var base:Shape;
    private var shadow:Shape;
    private var light:Shape;
    private var reflection:Shape;
    private var shade:Shape;
    private static var bColor:uint = 0xFFFFFF;
    private static var sColor:uint = 0x000000;

    public function Ball(r:uint, c:uint) {
        radius = r;
        color = c;
        draw();
    }

    private function draw():void {
        shade = new Shape();
        addChild(shade);
        shade.y = radius;
        createShade();
        ball = new Sprite();
        addChild(ball);
        base = new Shape();
        ball.addChild(base);
        shadow = new Shape();
        ball.addChild(shadow);
        light = new Shape();
        ball.addChild(light);
        reflection = new Shape();
        ball.addChild(reflection);
        createBase();
        createShadow();
        createLight();
        createReflect();
    }
    private function createBase():void {
        base.graphics.clear();
        base.graphics.beginFill(color, 0.8);
        base.graphics.drawCircle(0, 0, radius);
        base.graphics.endFill();
    }
    private function createShadow():void {
        var colors:Array = [sColor, sColor, sColor];
        var alphas:Array = [0, 0.2, 0.3];
        var ratios:Array = [0, 191, 255];
        var matrix:Matrix = new Matrix();
        matrix.createGradientBox(radius*3.2, radius*3.2, 0, -radius*2, -radius*2);
        shadow.graphics.beginGradientFill(GradientType.RADIAL, colors, alphas, ratios, matrix, SpreadMethod.PAD, InterpolationMethod.RGB, 0);
        shadow.graphics.drawCircle(0, 0, radius);
        shadow.graphics.endFill();
        shadow.blendMode = BlendMode.HARDLIGHT;
    }
    private function createLight():void {
        var colors:Array = [bColor, bColor, bColor];
        var alphas:Array = [1, 0.2, 0];
        var ratios:Array = [0, 191, 255];
        var matrix:Matrix = new Matrix();
        matrix.createGradientBox(radius*3.2, radius*3.2, 0, -radius*2, -radius*2);
        light.graphics.beginGradientFill(GradientType.RADIAL, colors, alphas, ratios, matrix, SpreadMethod.PAD, InterpolationMethod.RGB, 0);
        light.graphics.drawCircle(0, 0, radius);
        light.graphics.endFill();
        light.blendMode = BlendMode.OVERLAY;
    }
    private function createReflect():void {
        var colors:Array = [bColor, bColor];
        var alphas:Array = [0.7, 0];
        var ratios:Array = [0, 191];
        var matrix:Matrix = new Matrix();
        var w:Number = radius*1.44;
        var h:Number = radius*1.35;
        var yOffset:Number = radius*0.95;
        matrix.createGradientBox(w, h, 0.5*Math.PI, -w*0.5, -yOffset);
        reflection.graphics.beginGradientFill(GradientType.LINEAR, colors, alphas, ratios, matrix, SpreadMethod.PAD, InterpolationMethod.RGB, 0);
        reflection.graphics.drawEllipse(-w*0.5, -yOffset, w, h);
        reflection.graphics.endFill();
    }
    private function createShade():void {
        shade.graphics.beginFill(sColor, 0.6);
        shade.graphics.drawEllipse(-radius*0.75, -radius*0.1775, radius*1.5, radius*0.375);
        shade.graphics.endFill();
        var shadow:DropShadowFilter = new DropShadowFilter(0, 90, sColor, 0.5, radius*0.15, radius*0.15, 1, 3, false, false, true);
        shade.filters = [shadow];
    }

}

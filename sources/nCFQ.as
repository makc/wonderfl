package{
    import flash.display.*;
    import flash.text.*;
    import flash.filters.*;
    import flash.geom.*;
    import caurina.transitions.Tweener;

    public class Foo extends Sprite{
        private var bd:BitmapData;
        public function Foo():void{
            var tf:TextField = new TextField();
            tf.textColor = 0x000000;
            tf.text = "Hello\nWorld!!!";
            tf.autoSize = "left";
            bd = new BitmapData(tf.width, tf.height, false, 0x3399ff);
            bd.draw(tf);
            bd.applyFilter(bd, bd.rect, new Point(), new BlurFilter());
            bd.draw(tf);

            for(var i:int = 0; i < bd.width; i++){
                for(var j:int = 0; j < bd.height; j++){
                    Tweener.addTween(
                        randomize(addChild(new Circle(bd.getPixel(i, j)))), 
                        {
                            x: i * 10,
                            y: j * 10,
                            alpha: 1,
                            delay: (i + j) * .2 * Math.random(),
                            time: 1
                        }
                    );
                }
            }
        }
        private function randomize(d:DisplayObject):DisplayObject{
            d.x = 400 * Math.random();
            d.y = 300 * Math.random();
            d.alpha = 0;
            return d;
        }
    }
}


import flash.display.Sprite;

class Circle extends Sprite{
    public function Circle(color:uint):void{
        graphics.beginFill(color);
        graphics.drawCircle(0, 0, 6);
        graphics.endFill();
    }
}

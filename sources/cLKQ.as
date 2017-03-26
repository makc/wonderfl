/*
    エフェクトの練習です。
    雲とかもやみたいなの作りたかった。
    カーブを描いての動きは、Tweenerのスペシャルプロパティを利用しています。
*/

package
{
    import caurina.transitions.Tweener;
    import caurina.transitions.properties.CurveModifiers;
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.BlendMode;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.TimerEvent;
    import flash.filters.BlurFilter;
    import flash.filters.ColorMatrixFilter;
    import flash.geom.Point;
    import flash.utils.Timer;

    [SWF(width="465", height="465", backgroundColor="0x000000", frameRate="40")]
    public class Main extends Sprite
    {
        private var bmpd:BitmapData;
        private var colorMatrix:ColorMatrixFilter;
        private var Blur:BlurFilter;

        public function Main()
        {
            bmpd = new BitmapData(stage.stageWidth, stage.stageHeight, true, 0x00000000);
            var bmp:Bitmap = new Bitmap(bmpd);
            addChild(bmp);

            var timer:Timer = new Timer(250);
            timer.addEventListener(TimerEvent.TIMER, onTimer);
            timer.start();

            CurveModifiers.init();

            colorMatrix = new ColorMatrixFilter([0.99, 0, 0, 0, 1, 0, 0.99, 0, 0, 1, 0, 0, 0.99, 0, 1, 0, 0, 0, 0.99]);
            Blur = new BlurFilter(8, 8, 1);
            
            addEventListener(Event.ENTER_FRAME, onFrame);
        }

        private function onTimer(e:TimerEvent):void
        {
            var sp:Sprite=new Sprite;
            sp.graphics.beginFill(0xffffff * Math.random(), 1);
            sp.graphics.drawCircle(0, 0, 20 * Math.random() + 4);
            sp.graphics.endFill();

            addChild(sp);
            sp.x = -10;
            sp.y = 495*Math.random()-30;
            sp.scaleX = sp.scaleY = sp.alpha = 0;
            sp.filters = [new BlurFilter(32, 32, 1)];
            sp.blendMode = BlendMode.ADD;

            var t:Number=(13 - 8) * Math.random() + 8;
            Tweener.addTween(sp, {alpha:0.5, scaleX:1, scaleY:1, time:1});
            Tweener.addTween(sp, {x:600, y:465*Math.random(), _bezier:[{x:232.5, y:665*Math.random()-100}], time:t})
            Tweener.addTween(sp, {alpha:0, scaleX:0, scaleY:0, time:1, delay:t-2, onComplete:function():void
                    {
                        removeChild(sp);
                        sp.filters = [];
                        sp.graphics.clear();
                        sp = null;
                    }});
        }

        private function onFrame(e:Event):void
        {
            bmpd.draw(this);
            bmpd.applyFilter(bmpd, bmpd.rect, new Point(0, 0), Blur);
            bmpd.applyFilter(bmpd, bmpd.rect, new Point(0, 0), colorMatrix);
        }
    }
}
package
{
    import flash.display.*;
    import flash.geom.*;
    import flash.events.Event;
    import net.hires.debug.Stats;

    [SWF(backgroundColor="0x000000")]
    public class Magic extends Sprite
    {
        private var item : Sprite;
        private var items : Array = [];

        public function Magic()
        {
            addEventListener(Event.ADDED_TO_STAGE, init);
        }

        private function init( e : Event ) : void
        {
            removeEventListener(Event.ADDED_TO_STAGE, init);

            stage.quality = "low";

            for (var i : int = 0; i < 500; i++)
            {
                items[i] = item = new Sprite();

                var xpos : int = Math.random() * stage.stageWidth;
                var ypos : int = Math.random() * stage.stageHeight;
                var size : int = Math.random() * 100;

                var fillType:String = GradientType.RADIAL;
                var colors:Array = [ Math.random() * 0xffffff , 0x000000];
                var alphas:Array = [100, 100];
                var ratios:Array = [0x00, 0xFF];
                var mtr:Matrix = new Matrix();
                mtr.createGradientBox(size * 2, size * 2, 0, -size, -size);
                var spreadMethod:String = SpreadMethod.PAD;

                item.graphics.beginGradientFill(fillType, colors, alphas, ratios, mtr, spreadMethod);
                item.graphics.drawCircle(0, 0, size);
                item.graphics.endFill();
                item.x = xpos;
                item.y = ypos;
                item.scaleX = item.scaleY = 0;

                item.blendMode = "add";

                addChild(item);
            }

            //addChild( new Stats );
            addEventListener(Event.ENTER_FRAME, loop);
        }


        private function loop( e : Event ) : void
        {
            for (var i : int = 0; i < items.length; i++)
            {
                item = items[i];
                var distance : int = Math.sqrt( Math.pow(mouseX - item.x, 2) + Math.pow(mouseY - item.y, 2));
                var scale : Number = 1 - (distance * 0.01);
                scale = (scale > 1) ? 1 : (scale < 0) ? 0 : scale;
                
                item.scaleX = item.scaleY += ( scale - item.scaleY ) * .3;

                item.visible = item.scaleX > 0;
            }
        }
    }
}
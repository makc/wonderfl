package
{
    import flash.display.*;
    import flash.events.*;
    import flash.filters.BlurFilter;
    import flash.filters.DropShadowFilter;
    import flash.geom.Matrix;
    import flash.net.URLRequest;
    import flash.system.ApplicationDomain;
    import flash.system.LoaderContext;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.utils.ByteArray;
    import flash.utils.getTimer;

    [SWF(frameRate="60", width="465", height="465")]
    public class Twoheaded extends Sprite
    {
        private var loader:Loader;

        private var eagle1:Bitmap, eagle2:Bitmap, eagle3:Bitmap, eagle4:Bitmap;
        private var bitmapData:BitmapData;
        private var container:Sprite;
        private var superContainer:Sprite = new Sprite();
        private var text0:TextField, text1:TextField, text2:TextField;
        private var textShadow:DropShadowFilter = new DropShadowFilter(2);

        private var period:int = 4000;
        private var periods:int;
        private var lastTime:int;
        private var lastT:Number = 0;
        private var lastT0:Number = 0;
        private var zoomIn:Boolean = true;

        public function Twoheaded()
        {
            var mask:Shape = new Shape();
            mask.graphics.beginFill(0xFFFFFF);
            mask.graphics.drawRect(0, 0, 465, 465);
            mask.graphics.endFill();
            superContainer.mask = mask;
            superContainer.graphics.beginFill(0x6F0000);
            superContainer.graphics.drawRect(-22, 0, 565, 565);
            superContainer.graphics.endFill();
            superContainer.x = 20;

            loader = new Loader();
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
            loader.load(new URLRequest("http://assets.wonderfl.net/images/related_images/1/1e/1ed6/1ed61f7de656303242dc9932bed1e0058f4d46d3"), new LoaderContext(true));
            addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void { zoomIn = !zoomIn; });
        }

        private function onComplete(event:Event):void
        {
            addChild(superContainer);
            superContainer.addChild(container = new Sprite());
            eagle4 = createEagle();
            eagle3 = createEagle();
            eagle2 = createEagle();
            eagle2.filters = [ new BlurFilter(1.5, 1.5) ];
            eagle1 = createEagle();
            eagle1.filters = [ new BlurFilter(2, 2) ];
            superContainer.scaleX = superContainer.scaleY = 465 / eagle1.height;
            
            eagle1.scaleX = 0.083;
            eagle1.scaleY = 0.083;
            eagle1.x = 7.1;
            eagle1.y = 290.1;
            eagle1.rotation = -21.4;
            
            var matrix3:Matrix = new Matrix();
            matrix3.createBox(eagle1.scaleX, eagle1.scaleY, eagle1.rotation * Math.PI / 180, eagle1.x, eagle1.y);
            matrix3.invert();
            eagle3.transform.matrix = matrix3;
            eagle3.alpha = 0;
            
            var matrix4:Matrix = matrix3.clone();
            matrix4.concat(matrix3);
            eagle4.transform.matrix = matrix4;
            eagle4.alpha = 0;

            var rus:Boolean = false;
            var msg1:String = rus ? "ГОСУДАРСТВЕННЫЙ ГЕРБ РОССИЙСКОЙ ФЕДЕРАЦИИ - ДВУГЛАВЫЙ ОРЁЛ, " : "NATIONAL EMBLEM OF RUSSIA IS THE TWO-HEADED EAGLE, ";
            var msg2:String = rus ? "КОТОРЫЙ В ПРАВОЙ ЛАПЕ ДЕРЖИТ ЖЕЗЛ, УВЕНЧАННЫЙ ДВУГЛАВЫМ ОРЛОМ, " : "WHICH HOLDS IN RIGHT LEG A SCEPTRE TOPPED BY TWO-HEADED EAGLE, ";
            text0 = createText(msg1);
            text0.x = 0;
            text1 = createText(msg2);
            text2 = createText(text1.text);
            text2.filters = text1.filters = text0.filters = [ textShadow ];
            addEventListener(Event.ENTER_FRAME, onFrame);
        }

        private function createText(message:String):TextField
        {
            var text:TextField = new TextField();
            text.selectable = false;
            text.defaultTextFormat = new TextFormat("Verdana", 18, 0xFFFFFF, true);
            superContainer.addChild(text);
            text.x = 700;
            text.y = 445;
            text.text = message;
            text.width = text.textWidth;
            return text;
        }

        private function createEagle():Bitmap
        {
            var eagle:Bitmap = new Bitmap();
            if (!bitmapData)
            {
                bitmapData = new BitmapData(loader.content.width, loader.content.height, true, 0);
                bitmapData.draw(loader.content);
            }
            eagle.bitmapData = bitmapData;
            eagle.smoothing = true;
            container.addChild(eagle);
            return eagle;
        }

        private function onFrame(event:Event):void
        {
            var currentTime:int = getTimer();
            if (currentTime < 2000)
                return;

            var deltaT:int = currentTime - lastTime;
            if (deltaT > 30) deltaT = 30;

            var t0:Number = lastT + deltaT / period;
            var master:TextField, slave:TextField;
            if (!periods)
            {
                master = text0;
                slave = text1;
            }
            else
            {
                text0.x = 700;
                master = periods & 1 > 0 ? text2 : text1;
                slave = periods & 1 > 0 ? text1 : text2;
            }
            master.x = -master.textWidth * t0;
            slave.x = master.x + master.textWidth;


            var reset:Boolean;
            if (t0 >= 1)
            {
                t0 -= int(t0);
                periods++;
                reset = true;
                if (periods == 4)
                {
                    master.filters = slave.filters = [ new BlurFilter(3, 0, 2), textShadow ];
                }
                if (periods == 8)
                {
                    master.filters = slave.filters = [ new BlurFilter(6, 0, 2), textShadow ];
                }
                if (periods == 12)
                {
                    master.filters = slave.filters = [ new BlurFilter(10, 0, 2), textShadow ];
                }
            }

            if (periods > 1)
            {
                if (reset)
                {
                    reset = false;
                    period *= 0.9;
                    if (period < 400) period = 400;
                    container.scaleX = container.scaleY = 1;
                    container.x = container.y = 0;
                    container.rotation = 0;
                }
                var t:Number;
                if (zoomIn)
                {
                    t = t0 * t0;
                    moveContainer(t);
                    eagle3.alpha = 1 - t;
                    eagle4.alpha = t;
                }
                else
                {
                    t = Math.sqrt(t0);
                    moveContainer(1.0 - t);
                    eagle3.alpha = t;
                    eagle4.alpha = 1 - t;
                }
            }
            lastTime = currentTime;
            lastT = t0;
        }

        private function moveContainer(t1:Number):void
        {
            container.scaleX = container.scaleY = scaleT(t1);
            container.x = xT(t1);
            container.y = yT(t1);
            container.rotation = rotT(t1);
        }

        private function scaleT(t:Number):Number
        {
            return (1 - 0.083) * t + 0.083;
        }

        private function xT(t:Number):Number
        {
            return -7.1 * t + 7.1;
        }

        private function yT(t:Number):Number
        {
            return -290.1 * t + 290.1;
        }

        private function rotT(t:Number):Number
        {
            return 21.4 * t - 21.4;
        }
    }
}
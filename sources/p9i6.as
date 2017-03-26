/*

クリックで再描写！
パラメータによって見づらかったり綺麗だったり。
アトラクタっていいですよね。

*/


package
{
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.events.TimerEvent;
    import flash.filters.BlurFilter;
    import flash.utils.Timer;
    import org.papervision3d.core.effects.BitmapLayerEffect;
    import org.papervision3d.core.effects.utils.BitmapClearMode;
    import org.papervision3d.core.geom.Pixels;
    import org.papervision3d.core.geom.renderables.Pixel3D;
    import org.papervision3d.view.BasicView;
    import org.papervision3d.view.layer.BitmapEffectLayer;

    [SWF(width="465", height="465", backgroundColor="0x000000", frameRate="30")]
    public class main extends BasicView
    {
        private const NUM:int=600;
        private var pixels:Pixels;
        private var a:Number, b:Number, c:Number, d:Number;
        private var dot:Dot;
        private var timer:Timer;

        public function main()
        {
            super(0, 0, true, true);
            camera.focus=50;
            camera.zoom=47;

            var layer:BitmapEffectLayer=new BitmapEffectLayer(viewport, stage.stageWidth, stage.stageHeight, true, 0, BitmapClearMode.CLEAR_PRE, true);
            viewport.containerSprite.addLayer(layer);
            layer.addEffect(new BitmapLayerEffect(new BlurFilter(4, 4, 4), false));
            pixels=new Pixels(layer);
            scene.addChild(pixels);

            resetData();

            addEventListener(Event.ENTER_FRAME, onFrame);
            stage.addEventListener(MouseEvent.CLICK, resetData);
        }

        private function onTimer(e:TimerEvent):void
        {
            var dd:Dot=dot;
            var p:Pixel3D;
            while((dd=dd.next) != null)
            {
                dd.x1=Math.sin(a * dd.y0) - dd.z0 * Math.cos(b * dd.x0);
                dd.y1=dd.z0 * Math.sin(c * dd.x0) - Math.cos(d * dd.y0);
                dd.z1=Math.sin(dd.x0);
                p=new Pixel3D((0xff << 24 | 0xff * Math.random() << 16 | 0xff << 8 | 0xff * Math.random()), dd.x1 * 60, dd.y1 * 60 + 20, dd.z1 * 60);
                pixels.addPixel3D(p);
                dd.x0=dd.x1;
                dd.y0=dd.y1;
                dd.z0=dd.z1;
            }
        }

        private function resetData(e:MouseEvent=null):void
        {
            var prev:Dot=dot=new Dot();
            var dd:Dot;
            var i:int=0;
            while(++i <= NUM)
            {
                dd=new Dot;
                dd.x0=Math.random() * 2.0 - 1.0;
                dd.y0=Math.random() * 2.0 - 1.0;
                dd.z0=Math.random() * 2.0 - 1.0;
                prev.next=dd;
                prev=dd;
            }

            a=(Math.random() - 0.5) * 4;
            if (Math.abs(a) < 1) a*=2;
            b=(Math.random() - 0.5) * 4;
            if (Math.abs(b) < 1) b*=2;
            c=(Math.random() - 0.5) * 4;
            if (Math.abs(c) < 1) c*=2;
            d=(Math.random() - 0.5) * 4;
            if (Math.abs(d) < 1) d*=2;

            if (timer)
            {
                timer.stop();
                timer.removeEventListener(TimerEvent.TIMER, onTimer);
            }
            if (pixels) pixels.removeAllpixels();

            timer=new Timer(200, 20);
            timer.addEventListener(TimerEvent.TIMER, onTimer);
            timer.start();
        }

        private function onFrame(e:Event):void
        {
            singleRender();
            pixels.rotationY+=0.5;
        }
    }
}


class Dot
{
    public var x0:Number;
    public var y0:Number;
    public var z0:Number;
    public var x1:Number;
    public var y1:Number;
    public var z1:Number;
    public var next:Dot;
        
    public function Dot()
    {
    }

}
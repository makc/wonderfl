package  
{
    import flash.display.BitmapData;
    import flash.system.LoaderContext;
    import flash.display.LoaderInfo;
    import flash.display.Loader;
    import flash.display.StageScaleMode;
    import flash.display.Sprite;
    import flash.display.BlendMode;
    import flash.display.Bitmap;
    import flash.net.URLRequest;
       import flash.geom.ColorTransform;
    import flash.events.Event;
    import flash.filters.BlurFilter;

    import com.bit101.components.ColorChooser;
    import com.bit101.components.RadioButton;
    import com.bit101.components.HUISlider;
    import com.bit101.components.CheckBox;
    import com.bit101.components.Panel;

    import org.libspark.thread.EnterFrameThreadExecutor;
    import org.libspark.thread.Thread;
    

    [SWF(backgroundColor="#000000", frameRate=60)]
    public class FireFlyEffect extends Sprite 
    {
        private var sSpeed : HUISlider;
        private var sLife : HUISlider;
        private var canvas : AmplifierCanvas;
        private var sFrequency : HUISlider;
        private var sStrength : HUISlider;
        
        public function FireFlyEffect()
        {
            // take a capture after 10 sec
            Wonderfl.capture_delay( 10 );
            
            stage.scaleMode = StageScaleMode.NO_SCALE;
            
            Thread.initialize(new EnterFrameThreadExecutor());
            
            addChild(new Bitmap(new BitmapData(460, 460, false, 0)));
            
            var loader:Loader = addChild(new Loader()) as Loader;
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, start);
            loader.load(new URLRequest("http://www.imajuk.com/images/GillSans.png"), new LoaderContext(true));
        }

        private function start(event : Event) : void 
        {
            //=================================
            // the Bitmap as resource
            //=================================
            var sourceBMP : Bitmap = 
                LoaderInfo(event.target).loader.content as Bitmap;
                
            sourceBMP.x = 80;
            sourceBMP.y = 50;
            sourceBMP.transform.colorTransform = 
                new ColorTransform(1, 1, 1, 1, 0, 0, -20, 0);
            
            //=================================
            // UI
            //=================================
            var panel:Panel = new Panel(this, 50, 330);
            panel.setSize(200, 100);
            panel.color = 0;
            
            //=================================
            // slider for strength
            //=================================
            sStrength = new HUISlider(panel, 0, 0, "strength", updateParams);
            sStrength.setSliderParams(1, 10, 10);
            
            //=================================
            // slider for speed
            //=================================
            sSpeed = new HUISlider(panel, 0, 11, "speed", updateParams);
            sSpeed.setSliderParams(1, 50, 5);
            
            //=================================
            // slider for life time of effect
            //=================================
            sLife = new HUISlider(panel, 0, 22, "life", updateParams);
            sLife.setSliderParams(1, 200, 3);
                
            //=================================
            // slider for frequency of effect
            //=================================
            sFrequency = new HUISlider(panel, 0, 33, "frequency", updateParams);
            sFrequency.setSliderParams(0.01, 1, 1);
            
            //=================================
            // color chooser
            //=================================
            var colorChooser:ColorChooser = 
                new ColorChooser(panel, 280, 5, 0x00FF00);
                
            //=================================
            // toggle text visible
            //=================================
            var checkBox:CheckBox = 
                new CheckBox(
                    panel, 280, 30, "hide text",
                    function():void
                    {
                        sourceBMP.alpha = checkBox.selected ? 0 : 1;
                    }
                );
                
            //=================================
            // preset : TWINKLE
            //=================================
            new RadioButton(
                panel, 200, 5, "TWINKLE", true, 
                function(event:Event):void
                {
                    sStrength.value = 10;
                    sSpeed.value = 5;
                    sLife.value = 3;
                    sFrequency.value = .7;
                    updateParams();
                    canvas.filters = [new BlurFilter(2, 2, 4)];
                }
            );
            
            //=================================
            // preset : SOFT
            //=================================
            new RadioButton(
                panel, 200, 16, "SOFT", false, 
                function(event:Event):void
                {
                    sStrength.value = 5;
                    sSpeed.value = 1;
                    sLife.value = 160;
                    sFrequency.value = .05;
                    updateParams();
                    canvas.filters = [new BlurFilter(4, 4, 4)];
                }
            );
            
            //=================================
            // preset : HARD
            //=================================
            new RadioButton(
                panel, 200, 27, "HARD", false, 
                function(event:Event):void
                {
                    sStrength.value = 4;
                    sSpeed.value = 30;
                    sLife.value = 70;
                    sFrequency.value = .4;
                    updateParams();
                    canvas.filters = [new BlurFilter(2, 2, 4)];
                }
            );
            
            //=================================
            // effect
            //=================================
            var effectFactory:Function = 
                function():Thread
                {
                    return new FireFlyLightThread(
                        sourceBMP.bitmapData,
                        canvas.canvas,
                        sStrength.value,
                        sSpeed.value,
                        colorChooser.value | 0xFF000000, 
                        sLife.value);
                };

            //=================================
            // canvas
            //=================================
            canvas = 
                addChild(
                    new AmplifierCanvas(
                        sourceBMP.width,
                        sourceBMP.height,
                        effectFactory,
                        0x000000, 
                        0xFF, 
                        sFrequency.value,
                        4
                    )
                ) as AmplifierCanvas;
                
            canvas.filters = [new BlurFilter(2, 2, 4)];
            canvas.blendMode = BlendMode.ADD;
            canvas.x = sourceBMP.x;
            canvas.y = sourceBMP.y;
            
            updateParams();
            
        }

        private function updateParams(...param) : void
        {
            canvas.refreshRate = Math.min(.3, sSpeed.value / 50);
            canvas.effectFrequency = sFrequency.value;
        }
    }
}

import flash.display.Sprite;
import flash.display.BlendMode;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.ColorTransform;
import flash.geom.Rectangle;
import flash.geom.Point;

import org.libspark.thread.Thread;
    
class RefreshCanvas extends Sprite 
{
    protected var _refresh : CanvasRefreshThread;
    
    public function get refreshRate() : Number
    {
        return _refresh.refreshRate;
    }
    
    public function set refreshRate(value : Number) : void
    {
        _refresh.refreshRate = value;
    }
    
    public function set effectFrequency(value : Number) : void
    {
        _refresh.frequency = value;
    }
    
    protected var _canvas : BitmapData;

    public function get canvas() : BitmapData
    {
        return _canvas;
    }
    
    public function RefreshCanvas(
                        width : int,
                        height : int,
                        effectFactory:Function, 
                        canvasColor:uint = 0x000000,
                        refreshRate:Number = .2,
                        frequensy:Number = 1
                    )
    {
        _canvas = new BitmapData(width, height, true, canvasColor);
        
        _refresh = 
            new CanvasRefreshThread(
                _canvas, 
                canvasColor,
                refreshRate, 
                frequensy,
                effectFactory
                );
                
        _refresh.start();
    }
    
}

class AmplifierCanvas extends RefreshCanvas 
{
    public function AmplifierCanvas(
                        width : int,
                        height : int,
                        effectFactory : Function, 
                        canvasColor:uint = 0x000000,
                        refreshRate : Number = .2,
                        frequensy : Number = 1,
                        amplifier : int = 2
                    )
    {
        super(width, height, effectFactory, canvasColor, refreshRate, frequensy);
        
        var bmp : Bitmap;
        while(amplifier-- > 0)
        {
            bmp = addChild(new Bitmap(_canvas)) as Bitmap;
            bmp.blendMode = BlendMode.ADD;
        }
    }
}

class CanvasRefreshThread extends Thread 
{
    private var canvas : BitmapData;
    private var getEffect : Function;
    private var rect : Rectangle;
    private var canvasColor : uint;
    private var refresh : ColorTransform;
    private var _refreshRate : Number;

    public function get refreshRate() : Number
    {
        return _refreshRate;
    }

    public function set refreshRate(value : Number) : void
    {
        _refreshRate = value;
        refresh = new ColorTransform(1, 1, 1, 1, 0, 0, 0, -value * 0xFF);
    }

    private var _frequency : Number;

    public function set frequency(frequency : Number) : void
    {
        _frequency = frequency;
    }

    public function CanvasRefreshThread(
                        canvas:BitmapData, 
                        canvasColor:uint,
                        refreshRate:Number, 
                        frequency:Number,
                        getEffect:Function
                    )
    {
        super();
        
        _frequency = frequency;
        this.canvas = canvas;
        this.getEffect = getEffect;
        this.rect = canvas.rect;
        this.canvasColor = canvasColor;
        this.refreshRate = refreshRate;
    }

    override protected function run() : void
    {
        canvas.lock();
        canvas.colorTransform(rect, refresh);
        
        if (Math.random() <= _frequency)
            getEffect().start();
        
        canvas.unlock();

        next(run);
    }

    override protected function finalize() : void
    {
    }
}

class FireFlyLightThread extends Thread 
{
    private static var white : Array = [];
    private var source : BitmapData;
    private var canvas : BitmapData;
    private var pos : Point;
    private var vec : Number;
    private var life : int;
    private var speed : int;
    private var color : uint;
    private var cnt : int = 0;
    private var stength : int;

    public function FireFlyLightThread(
                        source : BitmapData, 
                        canvas : BitmapData, 
                        strength : int = 2,
                        speed : int = 1, 
                        color : uint = 0xFFFFFFFF,
                        life:int = 100
                    )
    {
        super();
        this.canvas = canvas;
        this.source = source;
        this.vec = Math.PI;
        this.color = color;
        this.speed = speed;
        this.stength = strength;
        this.life = int(Math.random() * life);
        
        if (white.length == 0)
            prepare();

        this.pos = white[Math.floor(Math.random() * white.length)];
    }
    
    private function prepare() : void
    {
        var x:int = -1;    
        var y:int = -1;
        while(++x <= source.width)
        {
            while(++y <= source.height)
            {
                if(source.getPixel32(x, y) > 0)
                    white.push(new Point(x,y));
            }
            y = 0;
        }
    }

    override protected function run() : void
    {
        if (life-- < 0)
            return;
            
        if (++cnt % 2 != 0)
        {
            next(run);
            return;
        }
        
        var sp : int = speed;
        while(sp-- > 0)
        {
            goAhead();
        }
    }

    private function goAhead() : void
    {
        //ベクトル方向の座標増分
        var ax : int = Math.round(Math.cos(vec));
        var ay : int = Math.round(Math.sin(vec));
        
        if (ax == 0 && ay == 0)
            return;
            
        //移動するつもりの座標
        var dx:int = pos.x + ax;
        var dy:int = pos.y + ay;
        
        //ピクセルがあれば移動
        if (source.getPixel32(dx, dy) > 0)
        {
            //現在位置を更新
            pos.x = dx;
            pos.y = dy;
            
            var argb : uint = color;
            var a : uint = (argb >> 24) & 0xFF;
            
            var px:int;
            var py:int;
            
            var rad2:Number = vec += .2;
            var s:int = 0;
                
            while(++s <= stength && a > 0x01)
            {
                var c:int = 0;
                while(c++ < 4)
                {
                    px = Math.cos(rad2) * s + pos.x;
                    py = Math.sin(rad2) * s + pos.y;
                    canvas.setPixel32(px, py, argb);
                    rad2 += Math.PI * .5;
                }

                a = (argb >> 24) & 0xFF;
                a *= .8;
                
                argb = (a << 24) | (argb & 0x00FFFFFF);
            }

            next(run);
        }
        else
        {
            //ピクセルがなければ方向を変える
            vec += Math.PI * .25 * ((Math.random() > .5) ? 1 : -1);
            next(run);
        }
    }

    override protected function finalize() : void
    {
    }
}

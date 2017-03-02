package  
{
    /**
     * @author imajuk
     */
    import com.bit101.components.PushButton;

    import flash.system.LoaderContext;
    import flash.display.StageScaleMode;
    import flash.display.StageAlign;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.geom.ColorTransform;
    import flash.filters.BlurFilter;
    import flash.utils.Dictionary;
    import flash.net.URLRequest;
    import flash.display.Loader;
    import flash.display.BlendMode;
    import flash.display.BitmapData;
    import flash.events.Event;
    import flash.display.Sprite;
    import flash.display.Bitmap;

    public class WaterColorsMain_wonderfl extends Sprite 
    {
    		private static const POINT : Point = new Point();
        //=================================
        // view 
        //=================================
        private var artBoard : Sprite;
        private var canvas : BitmapData;
        private var canvas2 : BitmapData;
        private var canvas3 : BitmapData;
        //=================================
        // drawing
        //=================================
        public var drawingMaterial : Brush;
        private var brushes : Array;
        private var cursor : Point = new Point();
        //=================================
        // coloring
        //=================================
        private var hue : Number = 0;
        private var tone : String;
        private var time : Number = 0;
        private var bIndex : int = 0;
        private var tIndex : Dictionary = new Dictionary(true);
        private var palette : Dictionary;
        private var palette1 : Array = [ ColorTone.LIGHT, ColorTone.SOFT ];
        private var palette2 : Array = [ ColorTone.PALE, ColorTone.LIGHT ];
        //=================================
        // effect
        //=================================
        private var stencil : BitmapData;
        private var rect : Rectangle;
        private var transparent : ColorTransform = new ColorTransform(1, 1, 1, 1, 0, 0, 0, -240);
        private var transparent2 : ColorTransform = new ColorTransform(1, 1, 1, 1, 1, 1, 1, -1);
        private var blur : BlurFilter = new BlurFilter(1, 2);
        private var resetTone : Function;
        
        public function WaterColorsMain_wonderfl()
        {
        		Wonderfl.capture_delay(90); 
        		
        	    //=================================
            // stage setting
            //=================================
            stage.align = StageAlign.TOP_LEFT;
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.frameRate = 60;
            var sw:int = stage.stageWidth; 
            var sh:int = stage.stageHeight;

            //=================================
            // background
            //=================================
            var loader : Loader = addChild(new Loader()) as Loader;
            loader.load(new URLRequest("http://www.imajuk.com/images/paper.png"), new LoaderContext(true));
			
            //=================================
            // canvas
            //=================================
            canvas = new BitmapData(sw, sh, true, 0);
            canvas2 = canvas.clone();
            canvas3 = canvas.clone();
            rect = canvas.rect;
            
            artBoard = addChild(new Sprite()) as Sprite;
            artBoard.addChild(new Bitmap(canvas)).blendMode = BlendMode.MULTIPLY;
            
            //=================================
            // stencil
            //=================================
            stencil = canvas.clone();
            stencil.copyPixels(Stencil.getStencil(stencil, sw, sh), rect, POINT);
            
            //=================================
            // drawing materials
            //=================================
            var spray : Brush  = new Brush(3,   5, .95, BlendMode.NORMAL, null, "spray");
            var crayon : Brush = new Brush(20, 30, .3,  BlendMode.NORMAL, null, "crayon");
            brushes = [ crayon, spray ];
            
            //=================================
            // palette
            //=================================
            palette = new Dictionary(true);
            palette[spray] = palette1;
            palette[crayon] = palette2;
            resetTone = function():void
            {
                tIndex[spray] = 0;
                tIndex[crayon] = 0;
            };
            resetTone();

            //=================================
            // drawing material
            //=================================             
            var me : WaterColorsMain_wonderfl = this;
            drawingMaterial = spray;
            drawingMaterial.addEventListener(Event.INIT, function():void
            {
                drawingMaterial = brushes[0];
                new CanvasInteraction(artBoard, me, cursor);
                var clear:PushButton = addChild(new PushButton(stage, sw - 55, sh-25, "clear", clearCanvas)) as PushButton;
                clear.setSize(50, 20);
            });
            
            //=================================
            // main loop
            //=================================            
            addEventListener(Event.ENTER_FRAME, function():void
            {
                if (!drawingMaterial || !drawingMaterial.initialized)
                   return;
                
                changeColor();
                moveCursor();
                drawBrush();
                effectCanvas();
            });
        }
        
        private function drawBrush() : void 
        {
            drawingMaterial.drawTo( canvas, cursor.x, cursor.y, true);
            drawingMaterial.drawTo(canvas3, cursor.x, cursor.y, true);
        }

        private function clearCanvas(...param) : void 
        {
            canvas.fillRect(rect, 0);
            canvas2.fillRect(rect, 0);
            canvas3.fillRect(rect, 0);
            resetTone();
            bIndex = 0;
        }

        private function effectCanvas() : void 
        {
            //顔料の流れ
            canvas3.scroll(0, 1);
            
            //アートボードの湿り気を調整
            var wet : Number = .9;
            if (Math.random() > wet)
                canvas3.colorTransform(rect, transparent2);
            
            //ステンシルで抜く
            canvas2.copyPixels(canvas3, rect, POINT, stencil, POINT, true);
            
            //エッジのにじみ
            canvas2.applyFilter(canvas2, rect, POINT, blur);
           
            //キャンバスに描画
            canvas.draw(canvas2, null, transparent, BlendMode.SCREEN);
        }

        public function changeDrawingMaterial() : void 
        {
            bIndex++;
            if (bIndex >= brushes.length)
                bIndex = 0;
            drawingMaterial = brushes[bIndex];
            drawingMaterial.changeBrushSizeTo(MathUtil.random(drawingMaterial.minBrushSize, drawingMaterial.maxBlushSize), 2);
        }

        public function changeTone() : void
        {
            var tones : Array = palette[drawingMaterial]; 
            tIndex[drawingMaterial] ++;
            if (tIndex[drawingMaterial] >= tones.length)
                tIndex[drawingMaterial] = 0;
                
            tone = tones[tIndex[drawingMaterial]];
        }

        private function changeColor() : void 
        {
            if (!tone)
                return;
                
            time += .001;
            drawingMaterial.color = ColorTone.getToneAs2(tone, hue += .2, Math.sin(time));
            if (hue >= 360)
                hue -= 360;
        }

        private function moveCursor() : void 
        {
            var vx : Number = mouseX - cursor.x;
            var vy : Number = mouseY - cursor.y;
            cursor.x += vx * .1;
            cursor.y += vy * .1;
        }
    }
}


import org.libspark.thread.Monitor;
import org.libspark.thread.EnterFrameThreadExecutor;
import org.libspark.thread.Thread;

import com.flashdynamix.motion.TweensyTimeline;
import com.flashdynamix.motion.Tweensy;

import flash.events.MouseEvent;
import flash.display.Sprite;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import flash.events.Event;
import flash.utils.clearInterval;
import flash.utils.setInterval;
import flash.display.BlendMode;
import flash.geom.ColorTransform;
import flash.filters.BlurFilter;
import flash.display.BitmapData;
import flash.geom.Point;
import flash.events.EventDispatcher;

import fl.motion.easing.Exponential;
import fl.motion.easing.Linear;

import frocessing.color.ColorHSV;

class CanvasInteraction 
{
    private var canvas : Sprite;
    private var cursor : Point;
    private var sample : WaterColorsMain_wonderfl;

    public function CanvasInteraction(
                        canvas : Sprite, 
                        sample : WaterColorsMain_wonderfl, 
                        cursor : Point
                    ) 
    {
        this.sample = sample;
        this.canvas = canvas;
        this.cursor = cursor;
        
        canvas.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
        canvas.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
    }

    private function mouseUpHandler(event : MouseEvent) : void 
    {
        sample.drawingMaterial.changeBrushSizeTo(0);
    }

    private function mouseDownHandler(event : MouseEvent) : void 
    {
        cursor.x = event.localX;
        cursor.y = event.localY;
        
        sample.changeDrawingMaterial();
        sample.changeTone();
    }

    public function interrpt() : void 
    {
        canvas.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
        canvas.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
    }
}

class Stencil 
{
    private static var data : String = "082004400fe01bb03ff82fe8282806c0";
    public static  function getStencil(b : BitmapData, width : int, height : int) : BitmapData 
    {
        var data2 : String = MathUtil.hexToBinary(data);
        
        var b2 : BitmapData = new BitmapData(b.width, b.height, true, 0);
        var w:int = 16;
        var h:int = 8;
        var size : int = 18;
        var px : int = 0;
        var py : int = 0;
        var sx : int = (b.width - size * w) * .5;
        var sy : int = (b.height - size * h) * .5;
        b2.fillRect(new Rectangle(0, 0, sx, height), 0xFF000000);
        b2.fillRect(new Rectangle(width - sx, 0, sx, height), 0xFF000000);
        b2.fillRect(new Rectangle(0, 0, width, sy), 0xFF000000);
        b2.fillRect(new Rectangle(0, height - sy, width, sy), 0xFF000000);
        var c : int = 0;
        while(py < h)
        {
            while(px < w)
            {
                var cl : uint;
                switch(data2.charAt(c++))
                {
                    case "0" :
                        cl = int(MathUtil.random(0xEE, 0xAA)) << 24;
                        break;
                    case "1" :
                        cl = int(Math.random() * 0x15) << 24;
                        break;
                }
                b2.fillRect(new Rectangle(sx + px * size, sy + py * size, size, size), cl);
                px++;
            }
            px = 0;
            py++;
        }
        b2.applyFilter(b2, b2.rect, new Point(), new BlurFilter(8, 8));
        
        return b2;
    }
}

class Brush extends EventDispatcher 
{
    private static const POINT : Point = new Point();
    public var initialized : Boolean = false;
    private var name : String = "unnamed";
    private var mat : Vector.<BitmapData>;
    private var materialCanvas : BitmapData;
    private var growBrushSize : TweensyThread;
    private var spread : Number;
    private var blend : String;
    private var blur : BlurFilter;

    private var _minBrushSize : int;
    public function get minBrushSize() : int
    {
        return _minBrushSize;
    }
    
    private var _maxBlushSize : int;
    public function get maxBlushSize() : int
    {
        return _maxBlushSize;
    }

    private var _blushSize : Number = 0;
    public function get blushSize() : Number
    {
        return _blushSize;
    }
    public function set blushSize(value : Number) : void
    {
        if (value > _maxBlushSize)
            return;
            
        _blushSize = value;
    }

    private var _color : ColorTransform = new ColorTransform();
    public function set color(value : uint) : void
    {
        _color.color = value;
    }

    public function Brush(
                        minBrushSize : int,
                        maxBlushSize : int,
                        spread : Number = .9, //顔料の広がり (値が大きいほど広い　.1 ~ .9)
                        blend : String = BlendMode.NORMAL,
                        blur : BlurFilter = null,
                        name : String = ""
                    )
    {
        if (maxBlushSize <= 0)
            throw new Error("the max size of brush should be more than 1");
        
        this._minBrushSize = minBrushSize;
        this._maxBlushSize = maxBlushSize;
        this.spread = spread;
        this.blend = blend;
        this.blur = blur;
        this.name = (name == "") ? this.name : name;
        
        if (!Thread.isReady)
            Thread.initialize(new EnterFrameThreadExecutor());
       
        build();
    }

    override public function toString() : String 
    {
        return "Brush[" + name + "(" + spread + ")]";
    }

    private function build() : void
    {
        materialCanvas = new BitmapData(400, 400);
        
        if (mat)
            return;
            
        //preare material
        mat = Vector.<BitmapData>([ new BitmapData(1, 1, true, 0) ]);
        
        var bs : int = 1;
        var intval : uint = 
            setInterval(
                function():void
                {
                    var material : BitmapData = getBrushMaterial(bs);
                    mat.push(material);
                        
                    if (++bs > _maxBlushSize)
                    {
                        initialized = true;
                        clearInterval(intval);
                        dispatchEvent(new Event(Event.INIT));
                    }
                }, 10);
    }

    private function getBrushMaterial(size : int) : BitmapData
    {
        var rad : Number = 0;
        var dis : Number = 0;
        
        //center of Bitmap
        var cx : Number = materialCanvas.width * .5;
        var cy : Number = materialCanvas.height * .5;
        
        //密度
        var density : Number = Exponential.easeIn(spread, 0.01, .1, 1);
        
        materialCanvas.lock();
        materialCanvas.fillRect(materialCanvas.rect, 0);
        while(dis < size)
        {
            rad += MathUtil.random(.05, .35);
            dis += (size / maxBlushSize) * density;
            var alp : Number = MathUtil.random(0x22, 0xCC);
            var t : Number = 0;
            while(alp > .3)
            {
                t += .8;
                drawPixel(materialCanvas, rad, dis + t, cx, cy, alp << 24);
                alp *= spread;
            }
        }
        materialCanvas.unlock();
        
        if (blur)
            materialCanvas.applyFilter(materialCanvas, materialCanvas.rect, POINT, blur);
        
        var bounce : Rectangle = materialCanvas.getColorBoundsRect(0xFF000000, 0x00000000, false);
        var trimed : BitmapData = new BitmapData(bounce.width, bounce.height, true, 0);
        trimed.copyPixels(materialCanvas, bounce, POINT);
        
        return trimed;
    }

    private function drawPixel(
                        target : BitmapData, 
                        rad : Number, 
                        dis : Number, 
                        x : int, 
                        y : int, 
                        cl : uint
                    ) : void
    {
        x += Math.cos(rad) * dis;
        y += Math.sin(rad) * dis;
        target.setPixel32(x, y, cl);
    }

    /**
     * draw spray effect
     * @param cx            center x
     * @param cy            center y
     * @param instability   instability brush size (never be bigger than max brush size)
     */
    public function drawTo(
                        canvas : BitmapData, 
                        cx : int, 
                        cy : int, 
                        instable : Boolean = true
                    ) : void
    {
        if (!initialized)
            throw new Error("not initialized still.");
            
        if (_blushSize <= 1)
             return;
             
        if (mat.length <= _blushSize)
            return;
             
        
        var brushMaterial : BitmapData = (instable) ? mat[int(Math.random() * _blushSize)] : mat[mat.length - 1]; 
        var m : Matrix = new Matrix();
        m.translate(-brushMaterial.width * .5, -brushMaterial.height * .5);
        m.rotate(MathUtil.random(-Math.PI, Math.PI));
        m.translate(brushMaterial.width * .5, brushMaterial.height * .5);
        m.translate(cx - brushMaterial.width * .5, cy - brushMaterial.height * .5);
        canvas.draw(brushMaterial, m, _color, blend);
    }

    public function changeBrushSizeTo(size : Number, duration:Number = .4, easing : Function = null) : void 
    {
        if (easing == null)
            easing = Exponential.easeOut;
            
        if (growBrushSize)
            growBrushSize.interrupt();
        
        growBrushSize = new TweensyThread(this, 0, duration, easing, null, {blushSize:size});
        growBrushSize.start();
    }
}
    
class ColorTone 
{
    //=================================
    // all kind of Color Tone
    //=================================
    public static const PALE : String           = "PALE";
    public static const LIGHT_GRAYISH : String  = "LIGHT_GRAYISH";
    public static const GRAYISH : String        = "GRAYISH";
    public static const DARK_GRAYISH : String   = "DARK_GRAYISH";
    
    public static const LIGHT : String          = "LIGHT";
    public static const SOFT : String           = "SOFT";
    public static const DULL : String           = "DULL";
    public static const DARK : String           = "DARK";
    
    public static const BRIGHT : String         = "BRIGHT";
    public static const STRONG : String         = "STRONG";
    public static const DEEP : String           = "DEEP";
    public static const VIVID : String          = "VIVID";
    
    //=================================
    // defination of Color Tone
    // [彩度min, 彩度max, 明度min, 明度max]
    //=================================
    internal static const DEF_PALE : Array            = [7, 20, 100, 100];
    internal static const DEF_LIGHT_GRAYISH : Array   = [5, 20, 70, 90];
    internal static const DEF_GRAYISH : Array         = [5, 20, 40, 50];
    internal static const DEF_DARK_GRAYISH : Array    = [5, 10, 7, 32];
    
    internal static const DEF_LIGHT : Array           = [30, 68, 100, 100];
    internal static const DEF_SOFT : Array            = [30, 68, 80, 90];
    internal static const DEF_DULL : Array            = [30, 50, 40, 70];
    internal static const DEF_DARK : Array            = [50, 65, 10, 30];
    
    internal static const DEF_BRIGHT : Array          = [90, 100, 77, 90];
    internal static const DEF_STRONG : Array          = [100, 100, 47, 67];
    internal static const DEF_DEEP : Array            = [100, 100, 40, 45];
    internal static const DEF_VIVID : Array           = [100, 100, 100, 100];
    
    /**
     * 任意のトーンのカラーを返します
     * @param n 明度と彩度の微調整
     */
    public static function getToneAs2(toneKind : String, hue : Number, n:Number = 0) : uint 
    {
        var tone:Array = ColorTone["DEF_" + toneKind];
        var satiation : Number = Linear.easeNone(n, tone[0], tone[1] - tone[0], 1);
        var value : Number = Linear.easeNone(n, tone[2], tone[3] - tone[2], 1);
        
        return new ColorHSV(hue, satiation*.01, value*.01, .1).value32;
    }

    public static function getAll() : Array 
    {
        return [PALE, LIGHT_GRAYISH, GRAYISH, DARK_GRAYISH, LIGHT, SOFT, DULL, DARK, BRIGHT, STRONG, DEEP, VIVID];
    }

    public var label : String;
    public var value : Number;
    
    /**
     * コンストラクタ
     * @param kind  トーンの種類. すべてのトーンの種類はColorToneに定義されています.
     * @param value 全体に占めるこのトーンの割合
     */
    public function ColorTone(kind : String, value : Number) 
    {
        this.label = kind;
        this.value = value;
    }
    
    public function toString() : String 
    {
        return label + " : " + int(value) + "%";
    }

    public function clone() : ColorTone 
    {
        return new ColorTone(label, value);
    }

    
}
    
class MathUtil
{
	/**
     * 任意の範囲からランダムな数値を返す
     */
    public static function random(min:Number, max:Number):Number
    {
        return Math.random() * (max - min) + min;
    }
    
    public static function hexToBinary(hex : String) : String 
    {
        var bin : String = "";
        for (var i : int = 0;i < hex.length;i++) 
        {
            var buff : String = hex.substr(i, 1);
            var temp : String = parseInt(buff, 16).toString(2);
            while(temp.length < 4)
            {
                temp = "0" + temp;
            }
            bin += temp;
        }
        return bin;
    }
}

class TweensyThread extends Thread 
{
    private var target:*;
    private var optionalProp:*;
    private var _monitor:Monitor;
    private var delay:Number;
    private var duration:Number;
    private var to:Object;
    private var from:Object;
    private var easing:Function;
    private var tt:TweensyTimeline;

    public function TweensyThread(
                        target:*,
                        delay:Number,
                        duration:Number,
                        easing:Function,
                        from:Object=null,
                        to:Object=null,
                        optionalProp:* = null)
    {
        super();
        this.target = target;
        this.delay = delay;
        this.duration = duration;
        this.easing = easing;
        this.to = to;
        this.from = from;
        this.optionalProp = optionalProp;
        _monitor = new Monitor();
    }
    
    override protected function run():void
    {
        if (isInterrupted)
            return;
            
        interrupted(function():void
        {
            if (tt)
               Tweensy.remove(tt);
        });
        
        error(Error, function(e:Error):void
        {
            throw new Error("TweensyThreadエラー", e);
            interrupt();
        });
        
        _monitor.wait();
        
        var mainTarget:*;
        var subTarget:*;
        if (optionalProp)
        {
            mainTarget = optionalProp;
            subTarget = target;
        }
        else
        {
            mainTarget = target;
            subTarget = optionalProp;
        }
        
        try
        {          
            if (from != null && to != null)
                tt = Tweensy.fromTo(mainTarget, from, to, duration, easing, delay, subTarget, _monitor.notifyAll);
            else if(from != null)
                tt = Tweensy.from(mainTarget, to, duration, easing, delay, subTarget, _monitor.notifyAll);
            else if(to != null)
                tt = Tweensy.to(mainTarget, to, duration, easing, delay, subTarget, _monitor.notifyAll);
        }
        catch(e:Error)
        {
            trace("$$$$", e.message); 
        }
    }

    override protected function finalize() : void
    {
        target = null;
        optionalProp = null;
        _monitor = null;
        to = null;
        from = null;
        easing = null;
        tt = null;
    }
}
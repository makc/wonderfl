// forked from berian's Particleでメニューさせてみる
package
{
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Graphics;
    import flash.display.MovieClip;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.events.TimerEvent;
    import flash.filters.BitmapFilterQuality;
    import flash.filters.BlurFilter;
    import flash.geom.ColorTransform;
    import flash.geom.Point;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
    import flash.utils.Dictionary;
    import flash.utils.Timer;

    import net.hires.debug.Stats;

    [SWF(frameRate=60, width=465, height=465, backgroundColor=0x000000)]

    public class Main extends MovieClip
    {
        private static var POINT_ZERO:Point = new Point();
        private static var TRANSFORM_COLOR:ColorTransform = new ColorTransform(1, .7, .7, .85, 0, 0, 0, 0);
        private static var FILTER_BLUR:BlurFilter = new BlurFilter(4, 4, BitmapFilterQuality.LOW);

        private static var MENU_LIST:Array = [
            "Home",
            "News",
            "About",
            "Contact",
        ];

        private var menus:Vector.<MovieClip>;
        private var menuParticles:Dictionary;
        private var film:BitmapData;

        public function Main()
        {
            addEventListener(Event.ADDED_TO_STAGE, initialize);
        }

        private function initialize(evt:Event):void
        {
            stage.align = StageAlign.TOP_LEFT;
            stage.scaleMode = StageScaleMode.NO_SCALE;

            film = new BitmapData(stage.stageWidth, stage.stageHeight, true, 0);
            addChild(new Bitmap(film));

            var i:uint,
                l:uint,
                mc:MovieClip,
                fmt:TextFormat,
                txt:TextField,
                bmd:BitmapData;

            fmt = new TextFormat(null, 64, 0xffffff, true);
            txt = new TextField();
            txt.autoSize = TextFieldAutoSize.LEFT;
            txt.defaultTextFormat = fmt;

            l = MENU_LIST.length;
            menus = new Vector.<MovieClip>(l, true);
            for (i=0; i<l; i++)
            {
                txt.text = MENU_LIST[i];
                bmd = new BitmapData(txt.width, txt.height, true, 0);
                bmd.draw(txt);

                mc = new MovieClip();
                mc.addChild(new Bitmap(bmd));
                mc.alpha = .2;
                mc.x = 30;
                mc.y = 30 + mc.height * i;

                menus[i] = mc;
                addChild(mc);
            }

            //addChild(new Stats());

            createParticle();

            drawCanvas();

            var timer:Timer = new Timer(300, 1);
            timer.addEventListener(TimerEvent.TIMER, timerHandler);
            timer.start();
        }

        private function timerHandler(event:TimerEvent):void
        {
            event.target.removeEventListener(TimerEvent.TIMER, timerHandler);

            addEventListener(Event.ENTER_FRAME, step);

            var i:uint,
                mc:MovieClip;

            i = menus.length;
            while (i--)
            {
                mc = menus[i];
                mc.buttonMode = true;
                mc.mouseChildren = false;
                mc.addEventListener(MouseEvent.ROLL_OVER, offReverse);
                mc.addEventListener(MouseEvent.ROLL_OUT, onReverse);
            }
        }

        private function createParticle():void
        {
            var i:uint,
                w:uint,
                h:uint,
                baseX:Number,
                baseY:Number,
                len:Number,
                angle:Number,
                color:uint,
                mc:MovieClip,
                p:Particle,
                ps:Vector.<Particle>,
                original:BitmapData;

            menuParticles = new Dictionary();

            len = 600;
            i = menus.length;
            while (i--)
            {
                mc = menus[i];
                original = new BitmapData(mc.width, mc.height, true, 0);
                original.draw(mc);
                ps = new Vector.<Particle>();

                baseX = mc.x;
                baseY = mc.y;
                for (w=0; w<original.width; w++)
                {
                    for (h=0; h<original.height; h++)
                    {
                        color = original.getPixel32(w, h);
                        if (!color) continue;

                        angle = Math.random() * Math.PI * 2;

                        p = new Particle();
                        p.color = color;
                        p.x = w + baseX;
                        p.y = h + baseY;
                        p.end = new Point(p.x, p.y);
                        p.start = new Point(Math.cos(angle) * len + baseX, Math.sin(angle) * len + baseY);

                        ps.push(p);
                    }
                }
                original.dispose();
                menuParticles[mc] = ps;
            }
        }

        private function step(event:Event):void
        {
            drawCanvas();
        }

        private function drawCanvas():void
        {
            var l:uint,
                m:uint,
                p:Particle,
                ps:Vector.<Particle>,
                mc:MovieClip;

            film.lock();
            //film.fillRect(film.rect, 0);
            film.colorTransform(film.rect, TRANSFORM_COLOR);
            film.applyFilter(film, film.rect, POINT_ZERO, FILTER_BLUR);

            l = menus.length;
            while (l--)
            {
                mc = menus[l];
                ps = menuParticles[mc];
                m = ps.length;
                while (m--)
                {
                    p = ps[m];

                    film.setPixel32(p.x, p.y, p.color);

                    p.update();
                }
            }
            film.unlock();
        }

        private function onReverse(event:MouseEvent):void
        {
            var i:uint,
                ps:Vector.<Particle>;

            ps = menuParticles[event.target];
            i = ps.length;

            while (i--)
            {
                ps[i].reverse = true;
            }
        }

        private function offReverse(event:MouseEvent):void
        {
            var i:uint,
                ps:Vector.<Particle>;

            ps = menuParticles[event.target];
            i = ps.length;

            while (i--)
            {
                ps[i].reverse = false;
            }
        }
    }
}

import flash.geom.Point;
class Particle
{
    public var mcName:String;
    public var isAlive:Boolean = true;
    public var x:Number = 0;
    public var y:Number = 0;
    public var color:uint = 0;
    public var start:Point;
    public var end:Point;

    private var _reverse:Boolean = true;
    private var _vx:Number = 0;
    private var _vy:Number = 0;
    private var _tick:uint = 0;

    public function get reverse():Boolean
    {
        return _reverse;
    }

    public function set reverse(reverse:Boolean):void
    {
        _reverse = reverse;
        isAlive = true;
    }

    public function Particle()
    {
        var strength:Number = Math.random() * 4;
        var angle:Number = Math.random() * Math.PI * 2;
        _vx = strength * Math.cos(angle);
        _vy = strength * Math.sin(angle);
    }

    public function update():void
    {
        if (!isAlive) return;

        var speed:Number,
            target:Point,
            delta:Point;

        target = _reverse ? start : end;
        if (_reverse)
        {
            _tick++;
            var t:Number = _tick / 60;

            x += 9 * t + _vx;
            y += -3 * t + _vy;
        }
        else
        {
            _tick = 0;

            delta = target.subtract(new Point(x, y));

            x += delta.x * .5;
            y += delta.y * .5;
        }

        if (Math.abs(target.x - x) <= 1 && Math.abs(target.y - y) <= 1)
        {
            x = target.x;
            y = target.y;
            isAlive = false;
        }
    }
}


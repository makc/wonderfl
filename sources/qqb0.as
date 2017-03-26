package 
{
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.events.MouseEvent;
    
    /**
     * Sand Traveler
     * stage click to reset
     * 
     * @see http://www.complexification.net/gallery/machines/sandTraveler/index.php
     * Special commission for Sónar 2004, Barcelona
     * sand painter implementation of City Traveler + complexification.net
     * 
     * j.tarbell   May, 2004
     * Albuquerque, New Mexico
     * complexification.net
     * 
     * Processing 0085 Beta syntax update
     * j.tarbell   April, 2005
     * 
     * @mxmlc -o bin/SandTraveler.swf -load-config+=obj\Alltest3Config.xml
     * @author jc at bk-zen.com
     */
    [SWF (backgroundColor = "0xFFFFFF", frameRate = "60", width = "465", height = "465")]
    public class SandTraveler extends Sprite
    {
        private var cities:Vector.<City>;
        private var bmd: BitmapData;
        private var w: int;
        private var h: int;
        private var size: int;
        private var bmp:Bitmap;
        private var cnt:int;
        
        public function SandTraveler() 
        {
            Wonderfl.capture_delay( 30 );
            if (stage) init();
            else addEventListener(Event.ADDED_TO_STAGE, init);
        }
        
        private function init(e: Event = null): void 
        {
            removeEventListener(Event.ADDED_TO_STAGE, init);
            //
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
            cities = new Vector.<City>(LENGTH, true);
            addChild(bmp = new Bitmap(null, "auto", true));
            resetAll();
            addEventListener(Event.ENTER_FRAME, loop);
            stage.addEventListener(Event.RESIZE, onResize);
            stage.addEventListener(MouseEvent.CLICK, onClick);
        }
        
        private function onClick(e: MouseEvent): void 
        {
            resetAll();
        }
        
        private function onResize(e: Event): void 
        {
            resetAll();
        }
        
        private function loop(e: Event): void 
        {
            var c: City, f: City, i: int, j: int, k: int, t: Number, dx: Number, dy: Number, dst: uint, src: uint, tdx: int, tdy: int;
            var rd: int, gd: int, bd: int, rs: int, gs: int, bs: int, s: SandPainter, ww: Number, a: Number;
            bmd.lock();
            for (i = 0; i < LENGTH; i++) 
            {
                c = cities[i], f = c.friend;
                c.x += (c.vx = (c.vx + (f.x - c.x) / size) * 0.936);
                c.y += (c.vy = (c.vy + (f.y - c.y) / size) * 0.936);
                for (j = 0; j < RLENGTH; j++) 
                {
                    t = random(PI2);
                    dx = tdx = (Math.sin(t) * (c.x - f.x) + (c.x + f.x)) * 0.5;
                    dy = tdy = (Math.sin(t) * (c.y - f.y) + (c.y + f.y)) * 0.5;
                    if (random(1000) > 990) dx += random(3) - random(3), dy += random(3) - random(3);
                    dst = bmd.getPixel(dx, dy);
                    src = f.color;
                    rd = (dst >> 16) & 0xFF;
                    gd = (dst >>  8) & 0xFF;
                    bd =  dst        & 0xFF;
                    rs = (src >> 16) & 0xFF;
                    gs = (src >>  8) & 0xFF;
                    bs =  src        & 0xFF;
                    bmd.setPixel(dx, dy, ((rd * 0.8125 + rs * 0.1875) << 16) | ((gd * 0.8125 + gs * 0.1875) << 8) | (bd * 0.8125 + bs * 0.1875));
                    dx = -1 * tdx;
                    dy = -1 * tdy;
                    if (random(1000) > 990) dx += random(3) - random(3), dy += random(3) - random(3);
                    dst = bmd.getPixel(dx, dy);
                    src = f.color;
                    rd = (dst >> 16) & 0xFF;
                    gd = (dst >>  8) & 0xFF;
                    bd =  dst        & 0xFF;
                    rs = (src >> 16) & 0xFF;
                    gs = (src >>  8) & 0xFF;
                    bs =  src        & 0xFF;
                    bmd.setPixel(dx, dy, ((rd * 0.8125 + rs * 0.1875) << 16) | ((gd * 0.8125 + gs * 0.1875) << 8) | (bd * 0.8125 + bs * 0.1875));
                }
                for (j = 0; j < SLENGTH; j++) 
                {
                    s = c.sands[j];
                    dx = f.x + (c.x - f.x) * Math.sin(s.p);
                    dy = f.y + (c.y - f.x) * Math.sin(s.p);
                    dst = bmd.getPixel(dx, dy);
                    src = s.c;
                    rd = (dst >> 16) & 0xFF;
                    gd = (dst >>  8) & 0xFF;
                    bd =  dst        & 0xFF;
                    rs = (src >> 16) & 0xFF;
                    gs = (src >>  8) & 0xFF;
                    bs =  src        & 0xFF;
                    bmd.setPixel(dx, dy, ((rd * 0.890625 + rs * 0.109375) << 16) | ((gd * 0.890625 + gs * 0.109375) << 8) | (bd * 0.890625 + bs * 0.109375));
                    s.g += random( -0.05, 0.05);
                    if (s.g < -0.22) s.g = -0.22;
                    if (s.g >  0.22) s.g =  0.22;
                    s.p += random( -0.05, 0.05);
                    if (s.p < 0) s.p = 0;
                    if (s.p > 1) s.p = 1;
                    ww = s.g * 0.1;
                    for (k = 0; k < RLENGTH; k++) 
                    {
                        a = (0.1 - k * 0.009) * 0.00390625;
                        dx = f.x + (c.x - f.x) * Math.sin(s.p + Math.sin(k * ww));
                        dy = f.y + (c.y - f.y) * Math.sin(s.p + Math.sin(k * ww));
                        dst = bmd.getPixel(dx, dy);
                        rd = (dst >> 16) & 0xFF;
                        gd = (dst >>  8) & 0xFF;
                        bd =  dst        & 0xFF;
                        bmd.setPixel(dx, dy, ((rd * (1 - a) + rs * a) << 16) | ((gd * (1-a) + gs * a) << 8) | (bd * (1 - a) + bs * a));
                        
                        dx = f.x + (c.x - f.x) * Math.sin(s.p - Math.sin(k * ww));
                        dy = f.y + (c.y - f.y) * Math.sin(s.p - Math.sin(k * ww));
                        dst = bmd.getPixel(dx, dy);
                        rd = (dst >> 16) & 0xFF;
                        gd = (dst >>  8) & 0xFF;
                        bd =  dst        & 0xFF;
                        bmd.setPixel(dx, dy, ((rd * (1 - a) + rs * a) << 16) | ((gd * (1-a) + gs * a) << 8) | (bd * (1 - a) + bs * a));
                    }
                }
            }
            bmd.unlock();
            if (cnt++ > 5000) resetAll();
        }
        
        private function resetAll():void
        {
            var vt: Number, vvt: Number = 0.2, ot: Number = random(PI2);
            var t: int, tinc: Number, vx: Number, vy: Number, c: City;
            cnt = 0;
            if (w != stage.stageWidth || h != stage.stageHeight)
            {
                if (bmd) bmd.dispose();
                bmd = new BitmapData(w = stage.stageWidth, h = stage.stageHeight, false);
                bmp.bitmapData = bmd;
                bmp.smoothing = true;
                size = (w + h) / 2;
            }
            vt = size / 40;
            bmd.lock();
            bmd.fillRect(bmd.rect, 0xFFFFFF);
            bmd.unlock();
            for (t = 0; t < LENGTH; t++) 
            {
                tinc = ot + (3.1 - t / LENGTH) * 2 * t * PI2 / LENGTH;
                vx = vt * Math.sin(tinc), vy = vt * Math.cos(tinc);
                cities[t] = new City(w / 2 + vx * 2, h / 2 + vy * 2, vx, vy, t);
                vvt -= 0.00033;
                vt += vvt;
            }
            for (t = 0; t < LENGTH; t++) 
            {
                c = cities[t];
                c.friend = cities[(c.idx + int(random(LENGTH / 5))) % LENGTH];
            }
        }
        
    }

}

class City
{
    public var x: Number, y: Number, vx: Number, vy: Number, idx: int, color: uint;
    public var friend: City;
    public var sands: Vector.<SandPainter>;
    function City(x: Number, y: Number, vx: Number, vy: Number, idx: int)
    {
        this.x = x, this.y = y, this.vx = vx, this.vy = vy, this.idx = idx;
        color = goodcolor[int(random(goodcolor.length))];
        sands = new Vector.<SandPainter>(SLENGTH, true);
        for (var i:int = 0; i < SLENGTH; i++) sands[i] = new SandPainter();
    }
}

class SandPainter
{
    public var p: Number, c: uint, g: Number;
    function SandPainter() { p = random(1), c = goodcolor[int(random(goodcolor.length))], g = random(0.01, 0.1); }
}

const PI2: Number = 6.28318530717958647693;
const LENGTH: int = 100;
const SLENGTH: int = 3;
const RLENGTH: int = 11;
const goodcolor: Array = [
    0x3a242b, 0x3b2426, 0x352325, 0x836454, 0x7d5533, 0x8b7352, 0xb1a181, 0xa4632e, 0xbb6b33, 
    0xb47249, 0xca7239, 0xd29057, 0xe0b87e, 0xd9b166, 0xf5eabe, 0xfcfadf, 0xd9d1b0, 0xfcfadf, 
    0xd1d1ca, 0xa7b1ac, 0x879a8c, 0x9186ad, 0x776a8e, 0x000000, 0x000000, 0x000000, 0x000000, 
    0x000000, 0xFFFFFF, 0xFFFFFF, 0xFFFFFF, 0xFFFFFF, 0xFFFFFF, 0x000000, 0x000000, 0x000000, 
    0x000000, 0x000000, 0xFFFFFF, 0xFFFFFF, 0xFFFFFF, 0xFFFFFF, 0xFFFFFF
];

function random(...args: Array): Number
{
    switch (args.length)
    {
        case 1:
            return Math.random() * args[0];
        break;
        case 2:
        default:
            var min: Number = args[0];
            return Math.random() * (args[1] - min) - min;
        break;
    }
    return Math.random();
}
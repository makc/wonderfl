// SUBSTRATE
// Original: http://www.complexification.net/gallery/machines/substrate/
// Substrate Watercolor
// j.tarbell   June, 2004
// Albuquerque, New Mexico
// complexification.net
// Processing 0085 Beta syntax update
// j.tarbell   April, 2005
// j.tarbell   June, 2004
// Albuquerque, New Mexico
// complexification.net
// AS3 ported by flashrod
package {
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.geom.Rectangle;
    [SWF(width="465", height="465", backgroundColor="0xFFFFFF", frameRate="30")]
    public class Substrate extends Sprite {

        private var dimx:int = 465;
        private var dimy:int = 465;
        private var num:int = 0;
        private var maxnum:int = 200;
        private var cgrid:Array;
        private var cracks:Array;
        private var numpal:int = 205;
        private var goodcolor:Array = [
             0xFFF0D0, 0xFFC828, 0xFFE898, 0xF0C898, 0xFFFFD0, 0xA07800, 0xE8C898,
             0xF8E070, 0xFFF0C8, 0xD0B080, 0xFFF8D0, 0xF8E8E0, 0xFFD8B0, 0xD0B078,
             0xF0D8C0, 0xF0D8D0, 0xFFFFD8, 0xC8C098, 0xD0C058, 0xE0C8A8, 0xD8D0B0,
             0xF8F8D0, 0xB0A098, 0xFFF0C0, 0xF0E8B8, 0x986870, 0xFFF8D8, 0xFFE8C8,
             0xF0E8C0, 0xF0E8D8, 0xE0D8B8, 0xE0D0A0, 0xE0D0B0, 0xD0C8A0, 0xE8E8D8,
             0xF0D898, 0xF8F0D8, 0xFFF0A0, 0xF8E878, 0xFFE878, 0xE8C848, 0xE8B878,
             0xF8E050, 0x585048, 0xFFFFC8, 0xA8A078, 0xE8E098, 0xF8F0C8, 0xE8D8A8,
             0xFFF8C8, 0xF0F8A8, 0xF0F0C0, 0xFFE078, 0xF0E8C8, 0xE8E080, 0xFFE868,
             0xD0C0A0, 0xF0E080, 0xFFE890, 0xE0C858, 0xF8E0B8, 0xF0E0B8, 0xD8C898,
             0xFFF0B8, 0xC8B078, 0xF8E8B8, 0xE8D8C8, 0xF0C868, 0xA09078, 0xFFF8C0,
             0xF0F0C8, 0xFFE8B0, 0xE8E0B0, 0xFFD028, 0xB09030, 0xF0F0D0, 0xC0C090,
             0xF8E0C0, 0xD0B890, 0xC0B078, 0xB0B098, 0xA8A880, 0xF0E0C0, 0xE0E0B8,
             0x585838, 0xD0D0C0, 0x382810, 0x383828, 0xB8B8B0, 0xC0B090, 0x98A0B8,
             0xE0B080, 0xC8C8B8, 0xF8E0B0, 0xD8C070, 0xF8E8C0, 0xE0D098, 0xE0D8B0,
             0x586868, 0xE8F0C0, 0x906848, 0xB08868, 0xE8B828, 0xFFE8C0, 0xB0B078,
             0xE0E0B0, 0x686870, 0xE0D8A0, 0xA0A0A8, 0xE0A060, 0x685858, 0xFF9828,
             0xC0A060, 0x905818, 0xF8F0B8, 0xA89868, 0xA89070, 0xB0A870, 0xF0F0E0,
             0xA89848, 0x586858, 0xE0B850, 0xC8B060, 0xB09020, 0xD8C088, 0xFFD070,
             0xFFE8B8, 0xF0D890, 0xE0C8A0, 0xF8F0D0, 0xA07848, 0xF8E0A0, 0xF8E8D0,
             0xF8E0A8, 0x100000, 0xE8C088, 0xE8F0D8, 0xB0C0B8, 0xFFD8A8, 0xF0E8D0,
             0xE8D078, 0xC8A078, 0xA8B0A0, 0xE8D8C0, 0xB0A890, 0x001000, 0xA03810,
             0xA08078, 0xD8C0A8, 0xD0B0B0, 0xE0E0C0, 0x906070, 0xA07078, 0xB88868,
             0xF8E0D8, 0xC09888, 0xFFE8D0, 0xD8C0A0, 0xC0C0B0, 0xE8C880, 0xC8B8A0,
             0xD0C8B0, 0xFFF0E8, 0xE8F0E0, 0xF8B828, 0x384030, 0x302008, 0x505860,
             0xD8C0B0, 0xF0E0B0, 0xFFD0B8, 0xA05810, 0x501000, 0xE8C078, 0xF8B888,
             0xE8D050, 0xFFF0D8, 0xF0D870, 0x984008, 0x805800, 0xE8E0C8, 0xB8B8A8,
             0xF0E8A0, 0x102028, 0x708080, 0xD8C8A0, 0xB0B8B0, 0xFFD8A0, 0x582800,
             0xD8C8B0, 0xFFF098, 0xD0C8A8, 0xFFF8B0, 0x687078, 0xF0D098, 0x607070,
             0x484858, 0x787880, 0x983010, 0xFFF8E0, 0x905048, 0xA82818, 0x603810,
             0xF8F8F8, 0xFFF0F8
             ];
        private var bmd:BitmapData;

        public function Substrate() {
            cgrid = new Array(dimx*dimy);
            cracks = new Array(maxnum);
            bmd = new BitmapData(dimx, dimy, true);
            addChild(new Bitmap(bmd));
            begin();
            addEventListener(Event.ENTER_FRAME, enterFrame);
        }

        public function restart():void {
            begin();
            bmd.fillRect(new Rectangle(0, 0, 640, 480), 0xFFFFFFFF);
        }

        private function begin():void {
            for (var y:int = 0; y < dimy; y++) {
                for (var x:int = 0; x < dimx; x++) {
                    cgrid[y * dimx + x] = 10001;
                }
            }
            for (var k:int = 0; k < 16; k++) {
                var i:int = int(random(dimx * dimy - 1));
                cgrid[i] = int(random(360));
            }
            num = 0;
            for (var j:int = 0; j < 3; j++) {
                makeCrack();
            }
        }

        public function makeCrack():void {
            if (num<maxnum) {
                cracks[num] = new Crack(this);
                num++;
            }
        }

        private function enterFrame(evt:Event):void {
            for (var n:int=0;n<num;n++) {
                cracks[n].move();
            }
        }
        public function somecolor():uint {
            return goodcolor[int(random(numpal))];
        }
        public function randomx():int { return int(random(dimx)); }
        public function randomy():int { return int(random(dimy)); }
        public function containsxy(x:int, y:int):Boolean {
            return (x>=0) && (x<dimx) && (y>=0) && (y<dimy);
        }
        public function getCGrid(x:int, y:int):int {
            return cgrid[y * dimx + x];
        }
        public function setCGrid(x:int, y:int, value:int):void {
            cgrid[y * dimx + x] = value;
        }
        public function setPixel(x:int, y:int, c:uint, a:Number):void {
            bmd.setPixel(x, y, alphablend(bmd.getPixel(x, y), c, a));
        }
        private function alphablend(dst:uint, src:uint, a:Number):uint {
            var rd:int = (dst >> 16) & 0xFF;
            var gd:int = (dst >> 8) & 0xFF;
            var bd:int = dst & 0xFF;
            var rs:int = (src >> 16) & 0xFF;
            var gs:int = (src >> 8) & 0xFF;
            var bs:int = src & 0xFF;
            var e:Number = 1 - a;
            var r:int = rd * e + rs * a;
            var g:int = gd * e + gs * a;
            var b:int = bd * e + bs * a;
            return (r << 16) | (g << 8) | b;
        }
    }
}

class Crack {
    private var mediator:Substrate;
    private var x:Number;
    private var y:Number;
    private var t:Number;
    private var sp:SandPainter;

    public function Crack(mediator:Substrate) {
        this.mediator = mediator;
        findStart();
        sp = new SandPainter(mediator);
    }

    private function findStart():void {
        var px:int = 0;
        var py:int = 0;
        var found:Boolean = false;
        var timeout:int = 0;
        while ((!found) || (timeout++ > 1000)) {
            px = mediator.randomx();
            py = mediator.randomy();
            if (mediator.getCGrid(px, py) < 10000) {
                found=true;
            }
        }
        if (found) {
            var a:int = mediator.getCGrid(px, py);
            if (random(100) < 50) {
                a -= 90 + int(random(-2, 2.1));
            } else {
                a += 90 + int(random(-2, 2.1));
            }
            startCrack(px, py, a);
        }
    }

    private function startCrack(X:int, Y:int, T:int):void {
        x = X;
        y = Y;
        t = T;
        x += 0.61 * Math.cos(t * Math.PI / 180);
        y += 0.61 * Math.sin(t * Math.PI / 180);
    }

    public function move():void {
        x += 0.42 * Math.cos(t * Math.PI / 180);
        y += 0.42 * Math.sin(t * Math.PI / 180);
        var z:Number = 0.33;
        var cx:int = int(x + random(-z, z));
        var cy:int = int(y + random(-z, z));
        regionColor();
        var px:int = x + random(-z, z);
        var py:int = y + random(-z, z);
        mediator.setPixel(px, py, 0, 85 / 256.0);
        if (mediator.containsxy(cx, cy)) {
            var cg:int = mediator.getCGrid(cx, cy);
            var acgt:int = Math.abs(cg - t);
            if ((cg > 10000) || (acgt < 5)) {
                mediator.setCGrid(cx, cy, int(t));
            } else if (acgt > 2) {
                findStart();
                mediator.makeCrack();
            }
        } else {
            findStart();
            mediator.makeCrack();
        }
    }

    private function regionColor():void {
        var rx:Number = x;
        var ry:Number = y;
        while (true) {
            rx += 0.81 * Math.sin(t * Math.PI / 180);
            ry -= 0.81 * Math.cos(t * Math.PI / 180);
            var cx:int = int(rx);
            var cy:int = int(ry);
            if (mediator.containsxy(cx, cy)) {
                var a:int = mediator.getCGrid(cx, cy);
                if (a > 10000) {
                    ;
                } else {
                    break;
                }
            } else {
                break;
            }
        }
        sp.render(rx, ry, x, y);
    }
}

class SandPainter {
    private var mediator:Substrate;
    private var c:uint;
    private var g:Number;

    public function SandPainter(mediator:Substrate) {
        this.mediator = mediator;
        c = mediator.somecolor();
        g = random(0.01, 0.1);
    }

    public function render(x:Number, y:Number, ox:Number, oy:Number):void {
        var dx:int = x - ox;
        var dy:int = y - oy;
        g += random(-0.050, 0.050);
        g = Math.min(1.0, Math.max(0, g))
            var grains:int = 64;
        var w:Number = g / (grains - 1);
        for (var i:int = 0; i < grains; i++) {
            var a:Number = 0.1 - i / (grains * 10.0);
            var b:Number = Math.sin(Math.sin(i * w));
            var px:int = ox + dx * b;
            var py:int = oy + dy * b;
            mediator.setPixel(px, py, c, a);
        }
    }
}

function random(...args):Number {
    switch (args.length) {
    case 2:
        var min:Number = args[0];
        var max:Number = args[1];
        return Math.random() * (max - min) - min;
    case 1:
        return Math.random() * Number(args[0]);
    }
    return Math.random();
}

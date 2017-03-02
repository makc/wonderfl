// forked from bkzen's Minecraft4kAS Extreme Hills Map
// forked from yonatan's Minecraft4kAS
// ported from notch's javascript version: http://jsdo.it/notch/dB1E
// added some brightness change (shadow) on top of the tiles if needed.

package {
    import flash.display.*;
    import flash.events.*;
    import flash.geom.Point;
    import flash.text.TextField;
    import flash.utils.*;

    [SWF(width="465", height="465", backgroundColor="0", frameRate="60")]
    public class main extends Sprite {
        private var w:int = 200;
        private var h:int = 200;
        private var bmd: BitmapData = new BitmapData(w, h, false, 0);
        private var bmp: Bitmap = new Bitmap(bmd);

        private var f: int = 0;
        private var label: TextField = new TextField();
        private var input: TextField = new TextField();

        private var map: Vector.<int> = new Vector.<int>(128 * 64 * 64, true);
        private var texmap: Vector.<int> = new Vector.<int>(16 * 16 * 3 * 16, true);
        private var waitTimer:Timer;

        function main() {
            addChild(bmp);
            bmp.scaleX = bmp.scaleY = 2;
            bmp.x = bmp.y = 32;
            initTexMap();
            label.autoSize = "left", label.textColor = 0xFFFFFF, label.text = "seed : ";
            input.textColor = 0xFFFFFF, input.type = "input", input.restrict = "0-9";
            input.height = 30, input.width = 100, input.x = label.width + 10;
            initMap();
            addChild(label);
            addChild(input);
            input.addEventListener(Event.CHANGE, onChange);
            
            waitTimer = new Timer(1000, 1);
            waitTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onCompTimer);
            addEventListener("enterFrame", renderMinecraft);
        }
        
        private function onChange(e: Event): void 
        {
            removeEventListener(Event.ENTER_FRAME, renderMinecraft);
            waitTimer.reset();
            waitTimer.start();
        }
        
        private function onCompTimer(e: TimerEvent): void 
        {
            initMap(int(input.text));
            addEventListener(Event.ENTER_FRAME, renderMinecraft);
        }

        private function initTexMap():void {
            for ( var i:int = 1; i < 16; i++) {
                var br:int = 255 - ((Math.random() * 96) | 0);
                for ( var y:int = 0; y < 16 * 3; y++) {
                    for ( var x:int = 0; x < 16; x++) {
                        var color:int = 0x966C4A;
                        if (i == 4)
                        color = 0x7F7F7F;
                        if (i != 4 || ((Math.random() * 3) | 0) == 0) {
                            br = 255 - ((Math.random() * 96) | 0);
                        }
                        if ((i == 1 && y < (((x * x * 3 + x * 81) >> 2) & 3) + 18)) {
                            color = 0x6AAA40;
                        } else if ((i == 1 && y < (((x * x * 3 + x * 81) >> 2) & 3) + 19)) {
                            br = br * 2 / 3;
                        }
                        if (i == 7) {
                            color = 0x675231;
                            if (x > 0 && x < 15
                                && ((y > 0 && y < 15) || (y > 32 && y < 47))) {
                                color = 0xBC9862;
                                var xd:int = (x - 7);
                                var yd:int = ((y & 15) - 7);
                                if (xd < 0)
                                xd = 1 - xd;
                                if (yd < 0)
                                yd = 1 - yd;
                                if (yd > xd)
                                xd = yd;

                                br = 196 - ((Math.random() * 32) | 0) + xd % 3 * 32;
                            } else if (((Math.random() * 2) | 0) == 0) {
                                br = br * (150 - (x & 1) * 100) / 100;
                            }
                        }

                        if (i == 5) {
                            color = 0xB53A15;
                            if ((x + (y >> 2) * 4) % 8 == 0 || y % 4 == 0) {
                                color = 0xBCAFA5;
                            }
                        }
                        if (i == 9) {
                            color = 0x4040ff;
                        }
                        var brr:int = br;
                        if (y >= 32)
                        brr /= 2;

                        if (i == 8) {
                            color = 0x50D937;
                            if (((Math.random() * 2) | 0) == 0) {
                                color = 0;
                                brr = 255;
                            }
                        }

                        var col:int = (((color >> 16) & 0xff) * brr / 255) << 16
                        | (((color >> 8) & 0xff) * brr / 255) << 8
                        | (((color) & 0xff) * brr / 255);
                        texmap[x + y * 16 + i * 256 * 3] = col;
                    }
                }
            }
        }

        private function initMap(s: int = 0): void {
            var noise: BitmapData = new BitmapData(64, 64, false);
            noise.lock();
            var p1: Point = new Point(), p2: Point = new Point();
            var offset: Array = [p1, p2];
            var seed: int = s || Math.random() * 0xFFFFFF;
            input.text = "" + seed;
            for ( var z: int = 0; z < 128; z++) 
            {
                // 擬似PerlinNoise3D
                p1.x = z, p2.x = -z;
                noise.perlinNoise(32, 32, 2, seed, false, true, 7, true, offset);
                for ( var x: int = 0; x < 64; x++) 
                {
                    for ( var y: int = 0; y < 64; y++) 
                    {
                        var i:int = z << 12 | y << 6 | x;
                        var yd:Number = (y - 32.5) * 0.4;
                        var zd:Number = (z - 32.5) * 0.4;
                        map[i] = 4; //(Math.random() * 16) | 0;
                        if (Math.random() > Math.sqrt(Math.sqrt(yd * yd + zd * zd)) - 0.8 || 
                            ((noise.getPixel(x, y) & 0xFF)*4/5) < ((64 - y) << 2))
                            map[i] = 0;
                    }
                }
            }
            noise.dispose();
           for ( z = 0; z < 128; z++) 
           {
                for ( x = 0; x < 64; x++) 
                {
                    for ( y = 0; y < 64; y++) 
                    {
                        i = z << 12 | y << 6 | x;
                        if (map[i] != 0)
                       {
                            var j:int = z << 12 | (y-1) << 6 | x;
                            if (map[j] == 0)
                                map[i] = 1;
                            else
                           {
                               j = z << 12 | (y-2) << 6 | x;
                               if (map[j] == 0)
                                   map[i] = 2;
                               else
                                   map[i] = Math.random()*3+2;
                           }
                        }
                    }
                }
            }

        }
        
        private function renderMinecraft(e: Event): void {
            var speed: int = 20000;
            var xRot:Number = Math.sin(getTimer() % speed / speed * Math.PI * 2) * 0.4 + Math.PI / 2;
            var yRot:Number = Math.cos(getTimer() % speed / speed * Math.PI * 2) * 0.2 - Math.PI/8;
            var yCos:Number = Math.cos(yRot);
            var ySin:Number = Math.sin(yRot);
            var xCos:Number = Math.cos(xRot);
            var xSin:Number = Math.sin(xRot);

            speed = 10000;
            var ox:Number = 32.5 + getTimer() % speed / speed * 64;
            var oy:Number = 32.5;
            var oz:Number = 32.5;

            f++;
            for ( var x:int = 0; x < w; x++) {
                var ___xd:Number = (x - w / 2) / h;
                for ( var y:int = 0; y < h; y++) {
                    var __yd:Number = (y - h / 2) / h;
                    var __zd:Number = 1;

                    var ___zd:Number = __zd * yCos + __yd * ySin;
                    var _yd:Number = __yd * yCos - __zd * ySin;

                    var _xd:Number = ___xd * xCos + ___zd * xSin;
                    var _zd:Number = ___zd * xCos - ___xd * xSin;

                    var col:int = 0;
                    var br:int = 255;
                    var ddist:int = 0;

                    var closest:Number = 32;
                    for ( var d:int = 0; d < 3; d++) {
                        var dimLength:Number = _xd;
                        if (d == 1)
                        dimLength = _yd;
                        if (d == 2)
                        dimLength = _zd;

                        var ll:Number = 1 / (dimLength < 0 ? -dimLength : dimLength);
                        var xd:Number = (_xd) * ll;
                        var yd:Number = (_yd) * ll;
                        var zd:Number = (_zd) * ll;

                        var initial:Number = ox - (ox | 0);
                        if (d == 1)
                        initial = oy - (oy | 0);
                        if (d == 2)
                        initial = oz - (oz | 0);
                        if (dimLength > 0)
                        initial = 1 - initial;

                        var dist:Number = ll * initial;

                        var xp:Number = ox + xd * initial;
                        var yp:Number = oy + yd * initial;
                        var zp:Number = oz + zd * initial;

                        if (dimLength < 0) {
                            if (d == 0)
                            xp--;
                            if (d == 1)
                            yp--;
                            if (d == 2)
                            zp--;
                        }

                        while (dist < closest) {
                            var tex:int = map[(zp & 127) << 12 | (yp & 63) << 6 | (xp & 63)];

                            if (tex > 0) {
                                var u:int = ((xp + zp) * 16) & 15;
                                var v:int = ((yp * 16) & 15) + 16;
                                if (d == 1) {
                                    u = (xp * 16) & 15;
                                    v = ((zp * 16) & 15);
                                    if (yd < 0)
                                    v += 32;
                                }

                                var cc:int = texmap[u + v * 16 + tex * 256 * 3];
                                if (cc > 0) {
                                    col = cc;
                                    ddist = 255 - ((dist / 32 * 255) | 0);
                                    //ddist = 255;
                                    br = 255 * (255 - ((d + 2) % 3) * 50) / 255;
                                    closest = dist;
                                }
                                if (d == 1)
                               { 
                                    //yp-=2;                                                         
                                    tex = map[(zp & 127) << 12 | ((yp-2) & 63) << 6 | (xp & 63)];
                                    if (tex > 0)
                                        br *= 0.5;
                                    else
                                   {
                                    //yp--;                                                         
                                    tex = map[(zp & 127) << 12 | ((yp-3) & 63) << 6 | (xp & 63)];
                                    if (tex > 0)
                                        br *= 0.7;                                   
                                   }
                                }
                            }
                            xp += xd;
                            yp += yd;
                            zp += zd;
                            dist += ll;
                        }
                    }

                    var r:int = ((col >> 16) & 0xff) * br * ddist / (255 * 255);
                    var g:int = ((col >> 8) & 0xff) * br * ddist / (255 * 255);
                    var b:int = ((col) & 0xff) * br * ddist / (255 * 255);

                    bmd.setPixel(x, y, r << 16 | g << 8 | b);
                }
            }
        }
    }
}
​
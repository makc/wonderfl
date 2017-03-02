// forked from makc3d's flash on 2014-5-25
package {
    import flash.display.Sprite;
    [SWF(backgroundColor=0x0)]
    public class FlashTest extends Sprite {
        public var colors:Array = [0xff, 0xff00, 0xff0000];
        public function FlashTest() {
            // replicating http://24.media.tumblr.com/6eb269049611b937d6c6e5eab34feed7/tumblr_n5rkyjTZOO1r2geqjo1_500.gif
            var t:Number = 0, p:Array = [], cnt:int = 8, i:int, n:int;
            for(i=0; i<cnt; i++) {
                colors[i] = hsv2rgb(i/cnt, 1, 1);
                p[i] = {};
            }
            addEventListener("enterFrame", function(e:*):void {
                t += 0.01; if (t > 1) t -= 1.0;
                graphics.clear();
                for (n = cnt * 6, i = 0; i < n; i++) {
                    var T:Number = t + Number(i) / n;
                    for (var j:int = 0; j < cnt; j++) {
                        ;
                        var A:Number = 2 * (T + j / cnt) * Math.PI;
                        var R:Number = 1 + 0.33 * Math.sin(A);
                        var H:Number = 0.2 * Math.cos(A);
                        var B:Number = 2 * Number(i) / n * Math.PI;
                        p[j].X = 465 / 2 + 150 * R * Math.sin(B);
                        p[j].Y = 465 / 2 + 150 * R * Math.cos(B);
                        p[j].Z = H;
                        p[j].C = colors[j];
                    }
                    p.sortOn("Z");
                    for (var k:int = 0; k < cnt; k++) {
                        graphics.beginFill(p[k].C);
                        graphics.drawCircle(p[k].X, p[k].Y, (15/cnt) / (0.5 - p[k].Z));
                    }
                }
            });
        }
    }
}

// from http://wonderfl.net/c/eMzU
function hsv2rgb(h:Number, s:Number, v:Number) : uint {
    var ht:Number=(h-int(h)+int(h<0))*6, hi:int=int(ht), vt:Number=v*255;
    switch(hi) {
        case 0: return 0xff000000|(vt<<16)|(int(vt*(1-(1-ht+hi)*s))<<8)|int(vt*(1-s));
        case 1: return 0xff000000|(vt<<8)|(int(vt*(1-(ht-hi)*s))<<16)|int(vt*(1-s));
        case 2: return 0xff000000|(vt<<8)|int(vt*(1-(1-ht+hi)*s))|(int(vt*(1-s))<<16);
        case 3: return 0xff000000|vt|(int(vt*(1-(ht-hi)*s))<<8)|(int(vt*(1-s))<<16);
        case 4: return 0xff000000|vt|(int(vt*(1-(1-ht+hi)*s))<<16)|(int(vt*(1-s))<<8);
        case 5: return 0xff000000|(vt<<16)|int(vt*(1-(ht-hi)*s))|(int(vt*(1-s))<<8);
    }
    return 0;
}

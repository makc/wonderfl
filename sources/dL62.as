package {
    import flash.display.Sprite;
    [SWF(backgroundColor=0x0)]
    public class FlashTest extends Sprite {
        public var colors:Array = [0xff, 0xff00, 0xff0000];
        public function FlashTest() {
            // replicating http://24.media.tumblr.com/6eb269049611b937d6c6e5eab34feed7/tumblr_n5rkyjTZOO1r2geqjo1_500.gif
            var t:Number = 0, p:Array = [{},{},{}];
            addEventListener("enterFrame", function(e:*):void {
                t += 0.01; if (t > 1) t -= 1.0;
                graphics.clear();
                for (var i:int = 0, n:int = 20; i < n; i++) {
                    var T:Number = t + Number(i) / n;
                    for (var j:int = 0; j < 3; j++) {
                        ;
                        var A:Number = 2 * (T + j / 3.0) * Math.PI;
                        var R:Number = 1 + 0.2 * Math.sin(A);
                        var H:Number = 0.2 * Math.cos(A);
                        var B:Number = 2 * Number(i) / n * Math.PI;
                        p[j].X = 465 / 2 + 150 * R * Math.sin(B);
                        p[j].Y = 465 / 2 + 150 * R * Math.cos(B);
                        p[j].Z = H;
                        p[j].C = colors[j];
                    }
                    p.sortOn("Z");
                    for (var k:int = 0; k < 3; k++) {
                        graphics.beginFill(p[k].C);
                        graphics.drawCircle(p[k].X, p[k].Y, 5 / (0.5 - p[k].Z));
                    }
                }
            });
        }
    }
}
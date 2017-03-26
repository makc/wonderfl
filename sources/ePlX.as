package {
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageQuality;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.geom.Rectangle;

    [SWF(width = '465', height = '465')]
    public class LilBoxes01 extends Sprite
    {
        private const STW : uint = 465;
        private const STH : uint = 465;
        private const GD : uint = 24;
        private const GSX : uint = STW / GD;
        private const GSY : uint = STH / GD;
        private const NUM_BOXES : uint = GSX * GSY;
        private const VARIANTS : uint = 3;
        /* */
        private var boxes : Vector.<Box>;
        private var occupation : Vector.<Boolean>;
        private var fcnt : int;

        function LilBoxes01()
        {
            stage.stageFocusRect = tabChildren = tabEnabled = mouseChildren = mouseEnabled = false;
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
            stage.quality = StageQuality.LOW;
            stage.fullScreenSourceRect = new Rectangle(0, 0, 465, 465);
            stage.frameRate = 32;
            opaqueBackground = 0x0;

            /* */

            occupation = new Vector.<Boolean>(GSX * GSY, true);

            boxes = new Vector.<Box>(NUM_BOXES, true);
            var n : uint = boxes.length;
            while (n-- != 0) {
                boxes[n] = new Box();
            }

            addEventListener(Event.ENTER_FRAME, oef);
        }

        private function oef(e : Event) : void
        {
            fcnt++;
            if ((fcnt & 31) == 1) reset();
        }

        private function reset() : void
        {
            /* reset occupation map */

            var i : uint = occupation.length;
            while (i-- != 0) occupation[i] = false;

            /* reset boxes */
            var box : Box;

            for each (box in boxes) {
                var h : int = 2 + ((VARIANTS - 1) * Math.random());
                var v : int = 2 + ((VARIANTS - 1) * Math.random());
                box.sx = h;
                box.sy = v;
            }

            /* layout */

            pack();

            /* draw */

            graphics.clear();

            for each (box in boxes)
            {
                var c : uint = Math.random() * 0xFFFFFF;

                graphics.lineStyle(2, c, 0.5, false, 'none', 'none');
                graphics.beginFill(c, 0.5);
                graphics.drawRect((box.x * GD), (box.y * GD), (box.sx * GD), (box.sy * GD));
            }

            graphics.endFill();
        }

        private function pack() : void
        {
            var ox : uint;
            var oy : uint;
            var gsx : int = GSX;
            var gsy : int = GSY;
            var maxx : int = (gsx - 1);
            var maxy : int = (gsy - 1);

            for each (var box : Box in boxes)
            {
                grid_scan:
                for (var gy : uint = 0; gy < maxy; gy++)
                {
                    for (var gx : uint = 0; gx < maxx; gx++)
                    {
                        if (occupation[gx + (gy * gsx)] == false)
                        {
                            var empty : Boolean = true;
                            for (var ax : uint = 0; ax < box.sx; ax++)
                            {
                                for (var ay : uint = 0; ay < box.sy; ay++)
                                {
                                    ox = (gx + ax);
                                    oy = (gy + ay);

                                    if (ox >= maxx) ox = maxx;
                                    if (oy >= maxy) oy = maxy;

                                    if (occupation[ox + (oy * gsx)] == true)
                                    {
                                        empty = false;
                                        break;
                                    }
                                }
                                if (empty == false) break;
                            }

                            if (empty == true)
                            {
                                box.x = gx;
                                box.y = gy;

                                for (ax = 0; ax < box.sx; ax++)
                                {
                                    for (ay = 0; ay < box.sy; ay++)
                                    {
                                        ox = (gx + ax);
                                        oy = (gy + ay);

                                        if (ox >= maxx) ox = maxx;
                                        if (oy >= maxy) oy = maxy;

                                        occupation[ox + (oy * gsx)] = true;
                                    }
                                }
                                break grid_scan;
                            }
                        }
                    }
                }
            }
        }
    }
}

internal class Box {
    public var x : uint;
    public var y : uint;
    public var sx : uint;
    public var sy : uint;

    function Box() {
    }
}
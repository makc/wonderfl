package {
    import flash.display.*;
    import flash.filters.*;
    import flash.geom.Point;
    [SWF(backgroundColor=0xE5CA9B)]
    public class FlashTest extends Sprite {
        
        public function FlashTest() {
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
            var w:Number = stage.stageWidth;
            var h:Number = stage.stageHeight;
            var c:Cell = new Cell(
                new Point(0, 0),
                new Point(w, 0),
                new Point(0, h),
                new Point(w, h)
            );
            for (var i:int = 0; i < 31; i++) {
                c.leaf(new Point(Math.random() * w, Math.random() * h)).divide();
            }
            var s:Shape = new Shape();
            c.render(s.graphics, graphics);
            s.filters = [
                new DropShadowFilter(2, 60, 0x000000, 1, 4, 4, 1, BitmapFilterQuality.HIGH, true),
                new DropShadowFilter(1, 60, 0xffffff, 0.5, 0, 0)
            ];
            addChild(s);
        }
        
    }
}

import flash.display.Graphics;
import flash.geom.Point;
internal class Cell {
    
    private var tl:Point;
    private var tr:Point;
    private var bl:Point;
    private var br:Point;
    
    private var d0:Point;
    private var d1:Point;
    private var c0:Cell;
    private var c1:Cell;
    
    public function Cell(tl:Point, tr:Point, bl:Point, br:Point) {
        this.tl = tl;
        this.tr = tr;
        this.bl = bl;
        this.br = br;
    }
    
    private function get width():Number {
        return (tr.subtract(tl).length + br.subtract(bl).length) / 2;
    }
    
    private function get height():Number {
        return (bl.subtract(tl).length + br.subtract(tr).length) / 2;
    }
    
    private function get ratio():Number {
        var w:Number = width;
        var h:Number = height;
        return w * w / (w * w + h * h);
    }
    
    public function leaf(p:Point):Cell {
        if (!c0) return this;
        var dp:Point = p.subtract(d0);
        var dd:Point = d1.subtract(d0);
        if (dd.x * dp.y - dd.y * dp.x >= 0) return c0.leaf(p);
        else return c1.leaf(p);
    }
    
    public function divide():void {
        var i0:Number = Math.random() * 0.5 + 0.25;
        var i1:Number = i0 + Math.random() * 0.3 - 0.15;
        if (Math.random() < ratio) {
            // vertical
            d0 = interpolate(tl, tr, i0);
            d1 = interpolate(bl, br, i1);
            c0 = new Cell(tl, d0, bl, d1);
            c1 = new Cell(d0, tr, d1, br);
        } else {
            // horizontal
            d0 = interpolate(br, tr, i0);
            d1 = interpolate(bl, tl, i1);
            c0 = new Cell(tl, tr, d1, d0);
            c1 = new Cell(d1, d0, bl, br);
        }
    }
    
    public function render(s:Graphics, f:Graphics, d:int=0):void {
        if (c0) {
            s.lineStyle(10 - d, 0x40382B);
            s.moveTo(d0.x, d0.y);
            s.lineTo(d1.x, d1.y);
            c0.render(s, f, d + 1);
            c1.render(s, f, d + 1);
        } else {
            f.beginFill(0x40382B, Math.random() * 0.6);
            f.moveTo(tl.x, tl.y);
            f.lineTo(tr.x, tr.y);
            f.lineTo(br.x, br.y);
            f.lineTo(bl.x, bl.y);
            f.endFill();
        }
    }
    
    private static function interpolate(p0:Point, p1:Point, i:Number):Point {
        var j:Number = 1 - i;
        return new Point(p0.x * j + p1.x * i, p0.y * j + p1.y * i);
    }
    
}
// forked from wh0's abstract cells
package {
    import flash.net.IDynamicPropertyOutput;
    import flash.display.*;
    import flash.filters.*;
    import flash.geom.Point;

    [SWF(backgroundColor=0x40382B)]
    public class FlashTest extends Sprite {
        
        public function FlashTest() {
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
            var w:Number = stage.stageWidth;
            var h:Number = stage.stageHeight;
            // セルを作成
            var s:Sprite = new Sprite();
            addChild(s);
            var cs:Array = [];
            s.y = 0;
            s.rotationX = -50;
                        
            for(var i:int=0;i< 2; i++) {
                cs.push(new Block().set(
                    new Point(0, 0),
                    new Point(w, 0),
                    new Point(0, h),
                    new Point(w, h)
                ));
            }
            cs[1].y = -h;
            for each(var c:Block in cs) {
                s.addChild(c)
            }
            var ship:Ship = new Ship();
            ship.x = w/2-30;
            ship.y = h/2+150;
            ship.scaleX = 0.25;
            ship.scaleY = 0.25
            addChild(ship);
            
            addEventListener("enterFrame", function():void {
                for(var i:int=0;i< cs.length; i++) {
                    cs[i].y+=16;
                    if(cs[i].y >= h) {
                        cs[i].set(
                            new Point(0, 0),
                            new Point(w, 0),
                            new Point(0, h),
                            new Point(w, h)
                        );
                        cs[i].y = -h;
                    }
                }
                ship.y = h/2+150 + Math.random()*2;
                ship.x = w/2-30 + Math.random()*2-1;
            });
        }
        
    }
}

import flash.display.*;
import flash.geom.Point;
class Block extends Shape {
    public var c:Cell;
    public var s:Shape = new Shape();
    public function set(p1:Point,p2:Point,p3:Point,p4:Point):Block {
        c = new Cell(p1, p2, p3, p4);
        for(var i:int=0;i<250;i++) {
            c.leaf(new Point(Math.random() * c.width, Math.random() * c.height)).divide();
        }
        graphics.clear();
        s.graphics.clear();
        c.render(s.graphics, graphics);
        return this;
    }
}

internal class Cell {
    
    private var tl:Point;
    private var tr:Point;
    private var bl:Point;
    private var br:Point;
    
    private var d0:Point;
    private var d1:Point;
    private var c0:Cell;
    private var c1:Cell;
    private var color:Number;
        
    public function Cell(tl:Point, tr:Point, bl:Point, br:Point) {
        this.tl = tl;
        this.tr = tr;
        this.bl = bl;
        this.br = br;
        var a1:Number = 0.8*Math.random()+0.8;
        var a2:Number = 0.1*Math.random()+0.9*a1;
        var a3:Number = 0.1*Math.random()+0.9*a1;
        this.color = (((0x40 * a1)&0xff)<<16)|(((0x38*a2)&0xff)<<8)|((0x2B*a3)&0xff)
    }
    
    public function get width():Number {
        return (tr.subtract(tl).length + br.subtract(bl).length) / 2;
    }
    
    public function get height():Number {
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
            f.beginFill(color);
            f.lineStyle(10 - d, 0x40382B);
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

class Ship extends Sprite {
    private function beginFill2(c:int, a:Number):void {
        var r:int = ((c>>16)&0xff)
        var g:int = ((c>>8)&0xff)
        var b:int = (c&0xff)
        r = r * r / 255
        g = g * g / 255
        b = b * b / 255
        var c2:int = (r<<16)|(g<<8)|b
        graphics.beginFill(c2,a);
    }

    public function Ship() {
        with(graphics) {
// --------------------------
beginFill2 (0x81a2c1, 100);
moveTo(145, 216);
lineTo(161, 229);
lineTo(176, 230);
lineTo(185, 215);
lineTo(173, 183);
lineTo(153, 184);
lineTo(145, 216);
endFill ();
// --------------------------
beginFill2 (0x404040, 100);
moveTo(195, 118);
lineTo(198, 96);
lineTo(218, 119);
lineTo(230, 177);
lineTo(208, 200);
lineTo(195, 118);
endFill ();
// --------------------------
beginFill2 (0xc8c8c8, 100);
moveTo(120, 117);
lineTo(203, 118);
lineTo(211, 159);
lineTo(120, 190);
lineTo(120, 117);
endFill ();
// --------------------------
beginFill2 (0xb7b1b1, 100);
moveTo(120, 70);
lineTo(170, 118);
lineTo(120, 190);
lineTo(120, 70);
endFill ();
// --------------------------
beginFill2 (0xb7b1b1, 100);
moveTo(120, 10);
lineTo(123, 10);
lineTo(127, 49);
lineTo(120, 48);
lineTo(120, 10);
endFill ();
// --------------------------
beginFill2 (0x808080, 100);
moveTo(141, 123);
lineTo(146, 137);
lineTo(121, 144);
lineTo(121, 125);
lineTo(141, 123);
endFill ();
// --------------------------
beginFill2 (0x404040, 100);
moveTo(120, 70);
lineTo(139, 71);
lineTo(142, 124);
lineTo(126, 129);
lineTo(126, 179);
lineTo(120, 180);
lineTo(120, 70);
endFill ();
// --------------------------
beginFill2 (0x404040, 100);
moveTo(120, 190);
lineTo(211, 158);
lineTo(205, 167);
lineTo(120, 200);
lineTo(120, 190);
endFill ();
// --------------------------
beginFill2 (0x808080, 100);
moveTo(120, 178);
lineTo(124, 177);
lineTo(130, 190);
lineTo(120, 190);
lineTo(120, 178);
endFill ();
// --------------------------
beginFill2 (0xe4efd8, 100);
moveTo(120, 43);
lineTo(128, 44);
lineTo(133, 88);
lineTo(120, 87);
lineTo(120, 43);
endFill ();
// --------------------------
beginFill2 (0xb7b1b1, 100);
moveTo(145, 214);
lineTo(156, 199);
lineTo(174, 200);
lineTo(174, 199);
lineTo(185, 216);
lineTo(179, 166);
lineTo(166, 143);
lineTo(154, 143);
lineTo(145, 161);
lineTo(143, 165);
lineTo(145, 214);
endFill ();
// --------------------------
beginFill2 (0xc8c8c8, 100);
moveTo(155, 198);
lineTo(153, 143);
lineTo(145, 158);
lineTo(145, 213);
lineTo(145, 213);
lineTo(155, 198);
endFill ();
// --------------------------
beginFill2 (0x9fbbd3, 100);
moveTo(151, 213);
lineTo(161, 222);
lineTo(175, 222);
lineTo(181, 213);
lineTo(174, 201);
lineTo(156, 201);
lineTo(151, 213);
endFill ();
// --------------------------
beginFill2 (0xcfe2dc, 100);
moveTo(151, 211);
lineTo(161, 219);
lineTo(173, 218);
lineTo(178, 211);
lineTo(172, 202);
lineTo(156, 202);
lineTo(151, 211);
endFill ();
// --------------------------
beginFill2 (0xffffff, 100);
moveTo(161, 205);
lineTo(162, 205);
lineTo(163, 205);
lineTo(164, 205);
lineTo(170, 206);
lineTo(172, 210);
lineTo(180, 335);
lineTo(158, 211);
lineTo(160, 207);
lineTo(161, 205);
endFill ();
// --------------------------
beginFill2 (0x81a2c1, 100);
moveTo(95, 216);
lineTo(78, 229);
lineTo(63, 230);
lineTo(55, 215);
lineTo(66, 183);
lineTo(86, 184);
lineTo(95, 216);
endFill ();
// --------------------------
beginFill2 (0x404040, 100);
moveTo(44, 118);
lineTo(41, 96);
lineTo(21, 119);
lineTo(10, 177);
lineTo(31, 200);
lineTo(44, 118);
endFill ();
// --------------------------
beginFill2 (0xc8c8c8, 100);
moveTo(120, 117);
lineTo(36, 118);
lineTo(28, 159);
lineTo(120, 190);
lineTo(120, 117);
endFill ();
// --------------------------
beginFill2 (0xb7b1b1, 100);
moveTo(120, 70);
lineTo(69, 118);
lineTo(120, 190);
lineTo(120, 70);
endFill ();
// --------------------------
beginFill2 (0xb7b1b1, 100);
moveTo(120, 10);
lineTo(117, 10);
lineTo(112, 49);
lineTo(120, 48);
lineTo(120, 10);
endFill ();
// --------------------------
beginFill2 (0x808080, 100);
moveTo(98, 123);
lineTo(93, 137);
lineTo(118, 144);
lineTo(118, 125);
lineTo(98, 123);
endFill ();
// --------------------------
beginFill2 (0x404040, 100);
moveTo(120, 70);
lineTo(100, 71);
lineTo(97, 124);
lineTo(113, 129);
lineTo(113, 179);
lineTo(120, 180);
lineTo(120, 70);
endFill ();
// --------------------------
beginFill2 (0x404040, 100);
moveTo(120, 190);
lineTo(28, 158);
lineTo(34, 167);
lineTo(120, 200);
lineTo(120, 190);
endFill ();
// --------------------------
beginFill2 (0x808080, 100);
moveTo(120, 178);
lineTo(115, 177);
lineTo(110, 190);
lineTo(120, 190);
lineTo(120, 178);
endFill ();
// --------------------------
beginFill2 (0xe4efd8, 100);
moveTo(120, 43);
lineTo(111, 44);
lineTo(106, 88);
lineTo(120, 87);
lineTo(120, 43);
endFill ();
// --------------------------
beginFill2 (0xb7b1b1, 100);
moveTo(95, 214);
lineTo(83, 199);
lineTo(65, 200);
lineTo(65, 199);
lineTo(54, 216);
lineTo(60, 166);
lineTo(73, 143);
lineTo(85, 143);
lineTo(95, 161);
lineTo(96, 165);
lineTo(95, 214);
endFill ();
// --------------------------
beginFill2 (0xc8c8c8, 100);
moveTo(84, 198);
lineTo(86, 143);
lineTo(94, 158);
lineTo(94, 213);
lineTo(94, 213);
lineTo(84, 198);
endFill ();
// --------------------------
beginFill2 (0x9fbbd3, 100);
moveTo(88, 213);
lineTo(78, 222);
lineTo(64, 222);
lineTo(58, 213);
lineTo(65, 201);
lineTo(83, 201);
lineTo(88, 213);
endFill ();
// --------------------------
beginFill2 (0xcfe2dc, 100);
moveTo(88, 211);
lineTo(78, 219);
lineTo(66, 218);
lineTo(61, 211);
lineTo(67, 202);
lineTo(83, 202);
lineTo(88, 211);
endFill ();
// --------------------------
beginFill2 (0xffffff, 100);
moveTo(78, 205);
lineTo(77, 205);
lineTo(76, 205);
lineTo(75, 205);
lineTo(69, 206);
lineTo(67, 210);
lineTo(60, 340);
lineTo(81, 211);
lineTo(79, 207);
lineTo(78, 205);
endFill ();


        }
    }
}

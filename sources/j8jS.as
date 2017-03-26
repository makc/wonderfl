package {
    import flash.display.*;
    import flash.events.*;
    import flash.ui.ContextMenu;
    import flash.ui.ContextMenuItem;
    import net.hires.debug.Stats;
    
    /**
     * Stable Fluids
     * @author saharan
     */
    [SWF(width = "465", height = "465", frameRate = "60")]
    public class Stable extends Sprite {
        private var grid:Vector.<Vector.<Cell>>;
        private var grid2:Vector.<Vector.<Cell>>;
        private const num:uint = 96;
        private const scale:Number = 3;
        private var press:Boolean;
        private var mx:Number;
        private var my:Number;
        private var pmx:Number;
        private var pmy:Number;
        private var bmd:BitmapData;
        
        public function Stable() {
            if (stage) initialize();
            else addEventListener(Event.ADDED_TO_STAGE, initialize);
        }
        
        private function initialize(e:Event = null):void {
            removeEventListener(Event.ADDED_TO_STAGE, initialize);
            stage.addEventListener(MouseEvent.MOUSE_DOWN, function(e:Event = null):void { press = true; } );
            stage.addEventListener(MouseEvent.MOUSE_UP, function(e:Event = null):void { press = false; } );
            var reset:ContextMenuItem = new ContextMenuItem("Reset");
            reset.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, function():void {
                    initSim();
                });
            contextMenu = new ContextMenu();
            contextMenu.hideBuiltInItems();
            contextMenu.customItems = [reset];
            /*var s:Stats = new Stats();
            s.alpha = 0.5;
            addChild(s);*/
            initSim();
            bmd = new BitmapData(num, num, false, 0);
            graphics.clear();
            graphics.beginFill(0);
            graphics.drawRect(0, 0, 465, 465);
            graphics.endFill();
            graphics.beginBitmapFill(bmd, null, false, true);
            var min:Number = (465 - num * scale) * 0.5;
            var max:Number = min + num * scale;
            graphics.drawTriangles(new <Number>[min, min, max, min, max, max, min, max],
                new <int>[0, 1, 2, 0, 2, 3],
                new <Number>[0, 0, 1, 0, 1, 1, 0, 1]);
            graphics.endFill();
            addEventListener(Event.ENTER_FRAME, frame);
        }
        
        private function initSim():void {
            grid = new Vector.<Vector.<Cell>>(num + 2, true);
            grid2 = new Vector.<Vector.<Cell>>(num + 2, true);
            var last:Cell;
            var last2:Cell;
            var lastB:Cell;
            var lastB2:Cell;
            var r1:Number = Math.random() * 0.5 + 0.5; // brighter
            var g1:Number = Math.random() * 0.5 + 0.5;
            var b1:Number = Math.random() * 0.5 + 0.5;
            var r2:Number = Math.random() * 0.5; // darker
            var g2:Number = Math.random() * 0.5;
            var b2:Number = Math.random() * 0.5;
            var r3:Number = Math.random() * 0.5 + 0.5; // brighter
            var g3:Number = Math.random() * 0.5 + 0.5;
            var b3:Number = Math.random() * 0.5 + 0.5;
            var r4:Number = Math.random() * 0.5; // darker
            var g4:Number = Math.random() * 0.5;
            var b4:Number = Math.random() * 0.5;
            for (var i:int = 0; i < num + 2; i++) {
                grid[i] = new Vector.<Cell>(num + 2, true);
                grid2[i] = new Vector.<Cell>(num + 2, true);
                for (var j:int = 0; j < num + 2; j++) {
                    var calc:Boolean = !(i == 0 || i == num + 1 || j == 0 || j == num + 1);
                    grid[i][j] = new Cell(i, j, (j - 1) * num + i - 1);
                    if (calc) {
                        if ((i - (num + 1) * 0.5) > 0 && (j - (num + 1) * 0.5) > 0) grid[i][j].cr = r1, grid[i][j].cg = g1, grid[i][j].cb = b1;
                        else if ((i - (num + 1) * 0.5) < 0 && (j - (num + 1) * 0.5) > 0) grid[i][j].cr = r2, grid[i][j].cg = g2, grid[i][j].cb = b2;
                        else if ((i - (num + 1) * 0.5) < 0 && (j - (num + 1) * 0.5) < 0) grid[i][j].cr = r3, grid[i][j].cg = g3, grid[i][j].cb = b3;
                        else grid[i][j].cr = r4, grid[i][j].cg = g4, grid[i][j].cb = b4;
                        if (last) last.next = grid[i][j];
                        last = grid[i][j];
                    } else {
                        if (lastB) lastB.next = grid[i][j];
                        lastB = grid[i][j];
                    }
                    if (i != 0) {
                        grid[i][j].l = grid[i - 1][j];
                        grid[i - 1][j].r = grid[i][j];
                    }
                    if (j != 0) {
                        grid[i][j].t = grid[i][j - 1];
                        grid[i][j - 1].b = grid[i][j];
                    }
                    grid2[i][j] = new Cell(i, j, (j - 1) * num + i - 1);
                    if (calc) {
                        if (last2) last2.next = grid2[i][j];
                        last2 = grid2[i][j];
                    } else {
                        if (lastB2) lastB2.next = grid2[i][j];
                        lastB2 = grid2[i][j];
                    }
                    if (i != 0) {
                        grid2[i][j].l = grid2[i - 1][j];
                        grid2[i - 1][j].r = grid2[i][j];
                    }
                    if (j != 0) {
                        grid2[i][j].t = grid2[i][j - 1];
                        grid2[i][j - 1].b = grid2[i][j];
                    }
                }
            }
            for (i = 1; i <= num; i++) {
                grid[0][i].gf = grid[1][i];
                grid[num + 1][i].gf = grid[num][i];
                grid[i][0].gf = grid[i][1];
                grid[i][num + 1].gf = grid[i][num];
                grid2[0][i].gf = grid2[1][i];
                grid2[num + 1][i].gf = grid2[num][i];
                grid2[i][0].gf = grid2[i][1];
                grid2[i][num + 1].gf = grid2[i][num];
            }
        }
        
        private function frame(e:Event = null):void {
            var cell:Cell;
            var cell2:Cell;
            var size:Number = scale * (num - 1);
            var center:Number = (465 - size) * 0.5;
            var tmp:Vector.<Vector.<Cell>>;
            
            pmx = mx;
            pmy = my;
            mx = mouseX;
            my = mouseY;
            cell = grid[1][1];
            var px:Vector.<uint> = bmd.getVector(bmd.rect);
            while (cell) {
                var x:Number = (cell.x - 1) * scale + center;
                var y:Number = (cell.y - 1) * scale + center;
                px[cell.idx] = cell.cr * 255 << 16 | cell.cg * 255 << 8 | cell.cb * 255;
                if (press) {
                    var d:Number = (mx - x) * (mx - x) + (my - y) * (my - y);
                    if (d < 400) {
                        var pow:Number = (d / 400 - 1) * 1;
                        cell.vx += pow * (pmx - mx);
                        cell.vy += pow * (pmy - my);
                    }
                }
                cell = cell.next;
            }
            bmd.setVector(bmd.rect, px);
            cell = grid[0][0];
            while (cell) {
                if (cell.gf) cell.cr = cell.gf.cr, cell.cg = cell.gf.cg, cell.cb = cell.gf.cb;
                cell = cell.next;
            }
            const num1:int = num + 1;
            var c1:Cell = grid[0][0];
            var c2:Cell = grid[1][0];
            var c3:Cell = grid[0][1];
            c1.cr = (c2.cr + c3.cr) * 0.5;
            c1.cg = (c2.cg + c3.cg) * 0.5;
            c1.cb = (c2.cb + c3.cb) * 0.5;
            c1 = grid[num1][0];
            c2 = grid[num][0];
            c3 = grid[num1][1];
            c1.cr = (c2.cr + c3.cr) * 0.5;
            c1.cg = (c2.cg + c3.cg) * 0.5;
            c1.cb = (c2.cb + c3.cb) * 0.5;
            c1 = grid[0][num1];
            c2 = grid[1][num1];
            c3 = grid[0][num];
            c1.cr = (c2.cr + c3.cr) * 0.5;
            c1.cg = (c2.cg + c3.cg) * 0.5;
            c1.cb = (c2.cb + c3.cb) * 0.5;
            c1 = grid[num1][num1];
            c2 = grid[num][num1];
            c3 = grid[num1][num];
            c1.cr = (c2.cr + c3.cr) * 0.5;
            c1.cg = (c2.cg + c3.cg) * 0.5;
            c1.cb = (c2.cb + c3.cb) * 0.5;
            
            tmp = grid;
            grid = grid2;
            grid2 = tmp;
            
            advect();
            
            project();
        }
        
        private function project():void {
            var cell:Cell;
            var cell2:Cell;
            for (var j:int = 1; j <= num; j++) {
                grid[0][j].vx = -grid[1][j].vx;
                grid[num + 1][j].vx = -grid[num][j].vx;
                grid[j][0].vy = -grid[j][1].vy;
                grid[j][num + 1].vy = -grid[j][num].vy;
            }
            cell = grid[1][1];
            cell2 = grid2[1][1];
            while (cell) {
                // divergence
                cell2.vx = -(cell.r.vx - cell.l.vx + cell.b.vy - cell.t.vy);
                cell2.vy = 0;
                cell = cell.next;
                cell2 = cell2.next;
            }
            for (var i:int = 0; i < 8; i++) {
                cell2 = grid2[1][1];
                while (cell2) {
                    // pressure
                    cell2.vy = (cell2.vx + cell2.l.vy + cell2.r.vy + cell2.t.vy + cell2.b.vy) * 0.25;
                    cell2 = cell2.next;
                }
                cell2 = grid2[0][0];
                while (cell2) {
                    if (cell2.gf) cell2.vy = cell2.gf.vy;
                    cell2 = cell2.next;
                }
            }
            cell = grid[1][1];
            cell2 = grid2[1][1];
            while (cell) {
                cell.vx -= (cell2.r.vy - cell2.l.vy) * 0.5;
                cell.vy -= (cell2.b.vy - cell2.t.vy) * 0.5;
                cell = cell.next;
                cell2 = cell2.next;
            }
        }
        
        private function advect():void {
            var cell:Cell = grid[1][1];
            var cell2:Cell = grid2[1][1];
            while (cell) {
                var px:Number = cell.x - cell2.vx * 0.04;
                var py:Number = cell.y - cell2.vy * 0.04;
                var ix:int = px = px < 0.5 ? 0.5 : px > num + 0.5 ? num + 0.5 : px;
                var iy:int = py = py < 0.5 ? 0.5 : py > num + 0.5 ? num + 0.5 : py;
                var dx:Number = px - ix; // bi-linear interpolation
                var dy:Number = py - iy;
                var adv1:Cell = grid2[ix][iy];
                var adv2:Cell = grid2[ix + 1][iy];
                var adv3:Cell = grid2[ix][iy + 1];
                var adv4:Cell = grid2[ix + 1][iy + 1];
                var vx12:Number = adv1.vx + dx * (adv2.vx - adv1.vx);
                var vy12:Number = adv1.vy + dx * (adv2.vy - adv1.vy);
                var cr12:Number = adv1.cr + dx * (adv2.cr - adv1.cr);
                var cg12:Number = adv1.cg + dx * (adv2.cg - adv1.cg);
                var cb12:Number = adv1.cb + dx * (adv2.cb - adv1.cb);
                var vx34:Number = adv3.vx + dx * (adv4.vx - adv3.vx);
                var vy34:Number = adv3.vy + dx * (adv4.vy - adv3.vy);
                var cr34:Number = adv3.cr + dx * (adv4.cr - adv3.cr);
                var cg34:Number = adv3.cg + dx * (adv4.cg - adv3.cg);
                var cb34:Number = adv3.cb + dx * (adv4.cb - adv3.cb);
                cell.vx = vx12 + dy * (vx34 - vx12);
                cell.vy = vy12 + dy * (vy34 - vy12);
                cell.cr = cr12 + dy * (cr34 - cr12);
                cell.cg = cg12 + dy * (cg34 - cg12);
                cell.cb = cb12 + dy * (cb34 - cb12);
                cell = cell.next;
                cell2 = cell2.next;
            }
        }
    }
}

class Cell {
    public var x:int;
    public var y:int;
    public var idx:int;
    public var vx:Number;
    public var vy:Number;
    public var next:Cell;
    public var gf:Cell; // get from
    public var l:Cell;
    public var r:Cell;
    public var t:Cell;
    public var b:Cell;
    public var cr:Number;
    public var cg:Number;
    public var cb:Number;
    
    public function Cell(x:int, y:int, idx:int) {
        this.x = x;
        this.y = y;
        this.idx = idx;
        vx = 0;
        vy = 0;
        cr = 0;
        cg = 0;
        cb = 0;
    }
}

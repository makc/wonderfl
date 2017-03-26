package {
    import flash.display.Sprite;
    [SWF(width="465", height="465", backgroundColor="0", frameRate="30")]
        public class Main extends Sprite {
        public function Main() { main = this; initializeFirst(); }
    }
}
class Actor {
    public var pos:Vec = new Vec, color:uint;
}
////----
const RANK_CYCLE_SCORE:int = 100;
const RANK_CYCLE_INCREMENT:Number = 1;
const RANK_NEXT_CYCLE_INCREMENT:Number = 0.2;
function initialize():void {
    wall = new Wall;
    man = new Man;
    blocks = new Vector.<Block>;
    scrollLength = 0;
}
function update():void {
    updateActor(man);
    wall.update();
    addBlock();
    updateActors(blocks);
}
function addBlock():void {
    if (isStarted && randi(90 / (rank + 2)) == 0) blocks.push(new Block);
}
var man:Man;
class Man extends Actor {
    private const Y:int = sc.HEIGHT * 0.75;
    private var isOnWall:Boolean = true, isOnLeft:Boolean = true, isFalling:Boolean;
    private var angle:Number;
    public function Man() {
        color = 0xf00;
        pos.y = Y;
        pos.x = wall.getLeftX(pos.y) + 1;
    }
    public function update():void {
        if (isFalling) {
            pos.y++;
            if (!sc.isIn(pos)) endGame();
            return;
        }
        scroll((Y - pos.y) * 0.25);
        if (isOnWall) {
            if (isOnLeft && mouse.x < pos.x + 2) return;
            if (!isOnLeft && mouse.x > pos.x - 2) return;
            angle = pos.angle(mouse);
            if (abs(angle) < PI / 2) return; 
            sc.line(pos, mouse, 0x722);
            if (isMouseClicked) {
                isOnWall = false; 
                start();
            }
        } else {
            pos.addAngle(angle, 1);
            if (isOnLeft) {
                if (pos.x >= wall.getRightX(pos.y)) {
                    pos.x = wall.getRightX(pos.y) - 1;
                    isOnWall = true; isOnLeft = false;
                }
            } else {
                if (pos.x <= wall.getLeftX(pos.y)) {
                    pos.x = wall.getLeftX(pos.y) + 1;
                    isOnWall = true; isOnLeft = true;
                }
            }
        }
    }
    public function hit():void {
        isFalling = true;
    }
}
var wall:Wall;
class Wall {
    private var lefts:Vector.<int> = new Vector.<int>(sc.HEIGHT);
    private var rights:Vector.<int> = new Vector.<int>(sc.HEIGHT);
    private var leftSize:int, rightSize:int;
    public function Wall() {
        leftSize = rightSize = sc.WIDTH * 0.15;
        for (var y:int = 0; y < sc.HEIGHT; y++) {
            lefts[y] = leftSize; rights[y] = rightSize;
        }
    }
    public function getLeftX(y:int):int {
        return lefts[y] - 1;
    }
    public function getRightX(y:int):int {
        return sc.WIDTH - rights[y];
    }
    public function update():void {
        for (var y:int = 0; y < sc.HEIGHT; y++) {
            sc.rect(0, y, lefts[y], 1, 0xfff);
            sc.rect(sc.WIDTH - rights[y], y, rights[y], 1, 0xfff);
        }
    }
    public function scroll():void {
        for (var y:int = sc.HEIGHT - 2; y >= 0; y--) {
            lefts[y + 1] = lefts[y];
            rights[y + 1] = rights[y];
        }
        lefts[0] = leftSize; rights[0] = rightSize;
        if (randi(sc.HEIGHT * 2) == 0) leftSize = rands(0.2, 0.1);
        if (randi(sc.HEIGHT * 2) == 0) rightSize = rands(0.2, 0.1);
    }
}
var blocks:Vector.<Block>;
class Block extends Actor {
    private var angle:Number, speed:Number;
    public function Block() {
        color = 0xfd4;
        pos.x = randn(wall.getRightX(0) - wall.getLeftX(0) - 1, wall.getLeftX(0) + 1);
        pos.y = 0;
        angle = randn(PI * 0.6, -PI * 0.3);
        speed = randn(0.1, 0.1);
    }
    public function update():Boolean {
        pos.addAngle(angle, speed);
        if (!sc.isIn(pos)) return false;
        if ((angle > 0 && int(pos.x) >= wall.getRightX(pos.y)) ||
            (angle < 0 && int(pos.x) <= wall.getLeftX(pos.y))) {
            pos.addAngle(angle, -speed);
            angle *= -1;
            pos.addAngle(angle, speed);
        }
        if (pos.equalsi(man.pos)) man.hit();
        return true;
    }
}
var scrollLength:Number;
function scroll(l:Number):void {
    scrollLength += l;
    while (scrollLength >= 1) {
        man.pos.y++;
        wall.scroll();
        for each (var b:Block in blocks) b.pos.y++;
        scrollLength--;
        addBlock();
        score++;
    }
}
////----
import flash.display.*;
import flash.events.*;
import flash.geom.*;
import flash.filters.BlurFilter;
var main:Sprite;
var bd:BitmapData, blurBd:BitmapData;
var blurFilter:BlurFilter;
var score:Number, rank:Number;
var mouse:Vec = new Vec, isMousePressed:Boolean, isMouseClicked:Boolean;
var isStarted:Boolean;
function initializeFirst():void {
    bd = new BitmapData(465, 465);
    blurBd = new BitmapData(465, 465);
    blurFilter = new BlurFilter(7, 7);
    main.addChild(new Bitmap(blurBd));
    reset();
    main.stage.addEventListener(MouseEvent.MOUSE_DOWN, onMousePressed);
    main.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseReleased);
    main.addEventListener(Event.ENTER_FRAME, updateFrame);
}
function onMousePressed(e:MouseEvent):void { isMousePressed = isMouseClicked = true; }
function onMouseReleased(e:MouseEvent):void { isMousePressed = false; }
function reset():void {
    isStarted = false;
    initialize();
}
function start():void {
    if (isStarted) return;
    score = 0; isStarted = true;
}
function endGame():void {
    sc.end();
}
var zeroPoint:Point = new Point;
function updateFrame():void {
    mouse.x = int(main.stage.mouseX / sc.INTERVAL);
    mouse.y = int(main.stage.mouseY / sc.INTERVAL);
    rank = 1 + sawtoothWave(score / RANK_CYCLE_SCORE,
        RANK_NEXT_CYCLE_INCREMENT) * RANK_CYCLE_INCREMENT;
    sc.clear();
    update();
    isMouseClicked = false;
    bd.lock();
    bd.fillRect(bd.rect, 0);
    sc.draw();
    blurBd.lock();
    blurBd.copyPixels(bd, bd.rect, zeroPoint);
    blurBd.applyFilter(blurBd, blurBd.rect, zeroPoint, blurFilter);
    blurBd.copyPixels(bd, bd.rect, zeroPoint, null, null, true);
    blurBd.unlock();
    bd.unlock();
}
var sc:Screen = new Screen;
class Screen {
    public const WIDTH:int = 15, HEIGHT:int = 15;
    public function dot(p:Vec, c:uint):void {
        if (!sc.isIn(p)) return;
        cells[int(p.x)][int(p.y)] = convertColor(c);
    }
    public function rect(x:int, y:int, w:int, h:int, c:uint):void {
        c = convertColor(c);
        for (var cy:int = y; cy < y + h; cy++) {
            for (var cx:int = x; cx < x + w; cx++) {
                cells[cx][cy] = c;
            }
        }
    }
    public function line(p1:Vec, p2:Vec, c:uint):void {
        c = convertColor(c);
        lp.xy = p1;
        lv.xy = p2; lv.decrementBy(lp);
        var lc:int = Math.max(abs(lv.x), abs(lv.y));
        lv.scaleBy(1 / lc);
        for (var i:int = 0; i <= lc; i++) {
            if (!isIn(lp)) return;
            cells[int(lp.x)][int(lp.y)] = c;
            lp.incrementBy(lv);
        }
    }
    public function isIn(p:Vec):Boolean {
        return (p.x >= 0 && p.x < WIDTH && p.y >= 0 && p.y < HEIGHT);
    }
    public const INTERVAL:int = 31, SIZE:int = 26, OFFSET:int = (INTERVAL - SIZE) / 2;
    public var cells:Vector.<Vector.<uint>> = new Vector.<Vector.<uint>>(HEIGHT);
    private var cr:Rectangle = new Rectangle(0, 0, SIZE, SIZE);
    private var lp:Vec = new Vec, lv:Vec = new Vec;
    private var beginY:int = 0, endY:int = 0;
    public function Screen() {
        for (var y:int = 0; y < HEIGHT; y++) cells[y] = new Vector.<uint>(WIDTH);
    }
    public function draw():void {
        cr.y = OFFSET + beginY * INTERVAL;
        for (var y:int = beginY; y < endY; y++, cr.y += INTERVAL) {
            cr.x = OFFSET;
            for (var x:int = 0; x < WIDTH; x++, cr.x += INTERVAL) {
                var c:uint = cells[x][y];
                if (c > 0) bd.fillRect(cr, c);
            }
        }
        if (beginY > 0) {
            if (++beginY >= HEIGHT) {
                beginY = endY = 0;
                reset();
            }
        } else if (endY < HEIGHT) {
            endY++;
        }
        drawScore();
    }
    public function clear():void {
        for (var y:int = 0; y < HEIGHT; y++) for (var x:int = 0; x < WIDTH; x++) cells[x][y] = 0;
    }
    public function end():void {
        if (beginY > 0) return;
        beginY = 1;
    }
    private var sp:Vec = new Vec;
    private var scoreCellColors:Array =
        [[100, 0xf00], [50, 0x0f0], [20, 0x0ff], [10, 0x00f], [1, 0xff0]];
    private function drawScore():void {
        sp.x = sp.y = 0;
        var s:int = score;
        for each (var scc:Array in scoreCellColors) s -= addScoreCells(s, scc[0], scc[1]);
    }
    private function addScoreCells(s:int, unit:int, c:uint):int {
        var cc:int = s / unit;
        c = convertColor(c);
        for (var i:int = 0; i < cc; i++) {
            cr.x = OFFSET + sp.x * INTERVAL; cr.y = OFFSET + sp.y * INTERVAL;
            bd.fillRect(cr, c);
            if (++sp.x >= WIDTH) { sp.x = 0; sp.y++; }    
        }
        return cc * unit;
    }
    private function convertColor(c:uint):uint {
        var r:uint = c >> 8, g:uint = (c & 0xf0) >> 4, b:uint = c & 0xf;
        return 0xff000000 | r * 0x110000 | g * 0x1100 | b * 0x11;
    }
}
function updateActors(actors:*):void {
    for (var i:int = 0; i < actors.length; i++) {
        if (!updateActor(actors[i])) actors.splice(i--, 1);
    }
}
function updateActor(a:*):Boolean {
    var uf:Boolean = a.update();
    sc.dot(a.pos, a.color);
    return uf;
}
var abs:Function = Math.abs;
var sin:Function = Math.sin, cos:Function = Math.cos, atan2:Function = Math.atan2;
var PI:Number = Math.PI;
function randi(n:int, s:int = 0):int { return Math.random() * n + s; }
function randn(n:Number = 1, s:Number = 0):Number { return Math.random() * n + s; }
function rands(s:Number, w:Number):Number { return (s + randn(w)) * sc.WIDTH }
function sawtoothWave(x:Number, increment:Number = 0.2):Number {
    return (x % 1) + int(x) * increment;
}
class Vec extends Vector3D {
    public function Vec(x:Number = 0, y:Number = 0) {
        super(x, y);
    }
    public function distance(p:Vector3D):Number {
        var ox:Number = x - p.x, oy:Number = y - p.y;
        return Math.sqrt(ox * ox + oy * oy);
    }
    public function angle(p:Vector3D):Number {
        return Math.atan2(p.x - x, p.y - y);
    }
    public function addAngle(a:Number, s:Number):void {
        x += Math.sin(a) * s; y += Math.cos(a) * s;
    }
    public function set xy(v:Vector3D):void {
        x = v.x; y = v.y;
    }
    public function equalsi(p:Vector3D):Boolean {
        return (int(p.x) == int(x) && int(p.y) == int(y));
    }
}